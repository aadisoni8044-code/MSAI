"""
main.py

Application entry point. Initiates QApplication, configures GUI signals,
creates secondary background QThreads for running pyOpenMS analysis and Google Drive I/O,
and integrates low-overhead text streams into custom GUI console logs.
"""

import sys
import os
import shutil
import logging
import tempfile
from typing import Dict, Any, Optional

from PyQt5.QtWidgets import QApplication, QMainWindow, QMessageBox, QFileDialog, QProgressDialog
from PyQt5.QtCore import QThread, pyqtSignal, pyqtSlot, QObject, Qt

import config
from ui_main_window import Ui_MainWindow
from ms_pipeline import run_full_pipeline
from drive_client import DriveClient
from drive_picker_dialog import DrivePickerDialog
from plot_widgets import SpectrumPlotWidget, ChromatogramPlotWidget, FeatureOverlayPlotWidget
from feature_table_model import FeatureTableModel
from report_generator import build_export_bundle

# Custom Qt Logging Stream to direct console output to QTextEdit Console tab
class QTextEditLogHandler(logging.Handler):
    def __init__(self, text_edit):
        super().__init__()
        self.text_edit = text_edit

    def emit(self, record):
        msg = self.format(record)
        # Append message thread-safely
        self.text_edit.append(msg)


# Background Pipeline QThread
class PipelineWorker(QThread):
    progress = pyqtSignal(int, str)
    completed = pyqtSignal(dict)
    failed = pyqtSignal(str)

    def __init__(self, filepath: str, options: dict):
        super().__init__()
        self.filepath = filepath
        self.options = options

    def run(self):
        try:
            results = run_full_pipeline(
                path=self.filepath,
                options=self.options,
                progress_callback=self._progress_relay
            )
            self.completed.emit(results)
        except Exception as e:
            import traceback
            err_details = traceback.format_exc()
            self.failed.emit(f"{str(e)}\n\n{err_details}")

    def _progress_relay(self, percent: int, msg: str):
        self.progress.emit(percent, msg)


# Background Google Drive Download QThread
class DriveDownloadWorker(QThread):
    progress = pyqtSignal(int)
    completed = pyqtSignal(str) # Local temp filepath
    failed = pyqtSignal(str)

    def __init__(self, drive_client: DriveClient, file_id: str, file_name: str):
        super().__init__()
        self.drive_client = drive_client
        self.file_id = file_id
        self.file_name = file_name

    def run(self):
        try:
            temp_dir = tempfile.gettempdir()
            local_path = os.path.join(temp_dir, self.file_name)
            self.drive_client.download_file(
                file_id=self.file_id,
                dest_path=local_path,
                progress_callback=self.progress.emit
            )
            self.completed.emit(local_path)
        except Exception as e:
            self.failed.emit(str(e))


# Background Google Drive Upload QThread
class DriveUploadWorker(QThread):
    completed = pyqtSignal(str)
    failed = pyqtSignal(str)

    def __init__(self, drive_client: DriveClient, local_dir_path: str, folder_name: str):
        super().__init__()
        self.drive_client = drive_client
        self.local_dir_path = local_dir_path
        self.folder_name = folder_name

    def run(self):
        try:
            # 1. Ensure target results folder exists
            folder_id = self.drive_client.create_results_folder(self.folder_name)

            # 2. Upload all files contained inside local bundle dir
            uploaded_files = []
            for item in os.listdir(self.local_dir_path):
                full_path = os.path.join(self.local_dir_path, item)
                if os.path.isfile(full_path):
                    self.drive_client.upload_file(full_path, folder_id=folder_id)
                    uploaded_files.append(item)

            # 3. Clean up the temp directory
            shutil.rmtree(self.local_dir_path, ignore_errors=True)

            self.completed.emit(f"Successfully uploaded {len(uploaded_files)} files to folder '{self.folder_name}'.")
        except Exception as e:
            self.failed.emit(str(e))


class OpenMSAnalyzerApp(QMainWindow, Ui_MainWindow):
    """
    Main Window controller managing application actions, processing workflows,
    plotting configurations, table listings, and background service loops.
    """
    def __init__(self):
        super().__init__()
        self.setupUi(self)

        # Core States
        self.drive_client = DriveClient()
        self.loaded_filepath = None
        self.pipeline_results = None

        # Setup Plots
        self.spectrum_plot = SpectrumPlotWidget(self)
        self.tab_spectrum_layout.addWidget(self.spectrum_plot)

        self.chromatogram_plot = ChromatogramPlotWidget(self)
        self.tab_chromatogram_layout.addWidget(self.chromatogram_plot)

        self.overlay_plot = FeatureOverlayPlotWidget(self)
        self.tab_overlay_layout.addWidget(self.overlay_plot)

        # Setup Table
        self.table_model = FeatureTableModel()
        self.table_view.setModel(self.table_model)

        # Setup Logs to direct to console text area
        self.setup_gui_logging()

        # Connect Actions and Buttons
        self.connect_signals()

    def setup_gui_logging(self):
        root_logger = logging.getLogger()
        handler = QTextEditLogHandler(self.console_output)
        formatter = logging.Formatter("%(asctime)s [%(levelname)s]: %(message)s", "%H:%M:%S")
        handler.setFormatter(formatter)
        root_logger.addHandler(handler)

    def connect_signals(self):
        # Menu / Toolbars
        self.actionOpenLocal.triggered.connect(self.on_open_local)
        self.actionOpenDrive.triggered.connect(self.on_open_drive)
        self.actionExportDrive.triggered.connect(self.on_export_drive)
        self.actionExit.triggered.connect(self.close)

        # Processing Trigger
        self.btn_run_pipeline.clicked.connect(self.on_run_pipeline)

    def on_open_local(self):
        options = QFileDialog.Options()
        filepath, _ = QFileDialog.getOpenFileName(
            self,
            "Open Local Mass-Spec File",
            "",
            "Mass-Spec Data Files (*.mzML *.mzXML *.xml);;All Files (*)",
            options=options
        )
        if filepath:
            self.set_current_file(filepath)

    def on_open_drive(self):
        # Trigger Authentication
        self.lbl_status.setText("Authenticating Google Drive...")
        QApplication.processEvents()

        if not self.drive_client.authenticate():
            QMessageBox.critical(
                self,
                "Authentication Failed",
                "Google Drive authentication failed. Ensure 'credentials.json' is present in the application directory."
            )
            self.lbl_status.setText("Drive connection failed.")
            return

        dialog = DrivePickerDialog(self.drive_client, self)
        if dialog.exec_() == DrivePickerDialog.Accepted:
            # Trigger Background Download
            file_id = dialog.selected_file_id
            file_name = dialog.selected_file_name

            # Setup Progress Dialog
            progress = QProgressDialog(f"Downloading {file_name} from Drive...", "Cancel", 0, 100, self)
            progress.setWindowModality(Qt.WindowModal)
            progress.show()

            self.download_worker = DriveDownloadWorker(self.drive_client, file_id, file_name)
            self.download_worker.progress.connect(progress.setValue)

            def on_download_success(local_path):
                progress.close()
                self.set_current_file(local_path)
                QMessageBox.information(self, "Download Complete", f"Successfully downloaded and loaded {file_name} from Google Drive.")

            def on_download_failed(err):
                progress.close()
                QMessageBox.critical(self, "Download Failed", f"Could not download file: {err}")
                self.lbl_status.setText("Download failed.")

            self.download_worker.completed.connect(on_download_success)
            self.download_worker.failed.connect(on_download_failed)

            # Stop worker on cancellation
            progress.canceled.connect(self.download_worker.terminate)

            self.download_worker.start()

    def set_current_file(self, filepath: str):
        self.loaded_filepath = filepath
        self.lbl_status.setText(f"Loaded raw file: {os.path.basename(filepath)}")
        self.btn_run_pipeline.setEnabled(True)

        # Clear previous stats and plots
        self.pipeline_results = None
        self.spectrum_plot.clear()
        self.chromatogram_plot.clear()
        self.overlay_plot.clear()
        self.table_model.setDataFrame(None)
        self.actionExportDrive.setEnabled(False)

    def on_run_pipeline(self):
        if not self.loaded_filepath:
            return

        # 1. Grab settings from UI controls
        options = {
            "peak_picking_enabled": self.chk_peak_picking.isChecked(),
            "peak_picking_signal_to_noise": self.spin_sn.value(),
            "ff_min_spectra": self.spin_min_spec.value(),
            "ff_charge_low": self.spin_charge_low.value(),
            "ff_charge_high": self.spin_charge_high.value(),
            "ff_mz_tolerance": self.spin_mz_tol.value(),
            "ff_min_score": self.spin_min_score.value(),
        }

        # Update progress indicators
        self.progressbar.setValue(0)
        self.progressbar.setVisible(True)
        self.btn_run_pipeline.setEnabled(False)
        self.actionOpenLocal.setEnabled(False)
        self.actionOpenDrive.setEnabled(False)

        # 2. Initiate Background Worker
        self.pipeline_worker = PipelineWorker(self.loaded_filepath, options)
        self.pipeline_worker.progress.connect(self.on_pipeline_progress)
        self.pipeline_worker.completed.connect(self.on_pipeline_completed)
        self.pipeline_worker.failed.connect(self.on_pipeline_failed)
        self.pipeline_worker.start()

    @pyqtSlot(int, str)
    def on_pipeline_progress(self, percent: int, msg: str):
        self.progressbar.setValue(percent)
        self.lbl_status.setText(msg)

    @pyqtSlot(dict)
    def on_pipeline_completed(self, results: dict):
        self.pipeline_results = results
        self.progressbar.setVisible(False)
        self.btn_run_pipeline.setEnabled(True)
        self.actionOpenLocal.setEnabled(True)
        self.actionOpenDrive.setEnabled(True)
        self.actionExportDrive.setEnabled(True)

        self.lbl_status.setText("Pipeline finished successfully!")

        # Update Table Model
        self.table_model.setDataFrame(results["dataframe"])

        # Render Plots
        # 1. Reconstruct chromatogram profile (TIC)
        self.chromatogram_plot.plot_tic(results["experiment"])

        # 2. Plot high fidelity spectrum profile of the first scan
        spectra = results["experiment"].getSpectra()
        if len(spectra) > 0:
            self.spectrum_plot.plot_spectrum(spectra[0], title=f"Spectrum (Scan 1, RT={spectra[0].getRT():.1f}s)")

        # 3. Draw features overlaid map
        self.overlay_plot.plot_features(results["experiment"], results["feature_map"])

        QMessageBox.information(
            self,
            "Success",
            f"Data processing complete!\n\nDetected features: {results['stats']['features_detected']}"
        )

    @pyqtSlot(str)
    def on_pipeline_failed(self, error_message: str):
        self.progressbar.setVisible(False)
        self.btn_run_pipeline.setEnabled(True)
        self.actionOpenLocal.setEnabled(True)
        self.actionOpenDrive.setEnabled(True)

        self.lbl_status.setText("Pipeline failed.")
        QMessageBox.critical(
            self,
            "Processing Error",
            f"An error occurred while running the pipeline:\n\n{error_message}"
        )

    def on_export_drive(self):
        if not self.pipeline_results:
            QMessageBox.warning(self, "No Data", "Run the pipeline first before exporting.")
            return

        # Authenticate Drive before upload
        self.lbl_status.setText("Connecting to Google Drive...")
        if not self.drive_client.authenticate():
            QMessageBox.critical(
                self,
                "Authentication Failed",
                "Cannot access Google Drive. Check 'credentials.json'."
            )
            return

        # Save current figures helper callbacks
        def save_spectrum_fig(path):
            self.spectrum_plot.figure.savefig(os.path.join(path, "spectrum_plot.png"), dpi=150)

        def save_tic_fig(path):
            self.chromatogram_plot.figure.savefig(os.path.join(path, "tic_plot.png"), dpi=150)

        def save_overlay_fig(path):
            self.overlay_plot.figure.savefig(os.path.join(path, "feature_overlay_plot.png"), dpi=150)

        # Bundle data to a local temporary folder
        local_bundle_dir = build_export_bundle(
            df=self.pipeline_results["dataframe"],
            stats=self.pipeline_results["stats"],
            plot_callbacks=[save_spectrum_fig, save_tic_fig, save_overlay_fig]
        )

        # Initialize background QThread to perform non-blocking multi-file upload
        self.lbl_status.setText("Uploading report and graphs to Google Drive...")

        self.upload_worker = DriveUploadWorker(
            drive_client=self.drive_client,
            local_dir_path=local_bundle_dir,
            folder_name=config.DEFAULT_RESULTS_FOLDER_NAME
        )

        # Display blocking processing dialog
        progress = QProgressDialog("Uploading files to Google Drive...", None, 0, 0, self)
        progress.setWindowModality(Qt.WindowModal)
        progress.setRange(0, 0) # Infinite busy/marquee indicator
        progress.show()

        def on_upload_success(msg):
            progress.close()
            self.lbl_status.setText("Upload complete!")
            QMessageBox.information(
                self,
                "Export Complete",
                f"{msg}\n\nFiles uploaded:\n- detected_features.csv\n- spectrum_plot.png\n- tic_plot.png\n- feature_overlay_plot.png\n- processing_summary.txt"
            )

        def on_upload_failed(err):
            progress.close()
            self.lbl_status.setText("Upload failed.")
            QMessageBox.critical(
                self,
                "Upload Failed",
                f"An error occurred while uploading: {err}"
            )

        self.upload_worker.completed.connect(on_upload_success)
        self.upload_worker.failed.connect(on_upload_failed)
        self.upload_worker.start()


def main():
    app = QApplication(sys.argv)
    window = OpenMSAnalyzerApp()
    window.show()
    sys.exit(app.exec_())

if __name__ == "__main__":
    main()
