"""
ui_main_window.py

Declares the primary user interface structure of the OpenMS Analyzer application,
including menu items, parameters control box, result tabs (Plots, Features, Log),
and bottom status bar.
"""

from PyQt5.QtWidgets import (
    QMainWindow, QWidget, QVBoxLayout, QHBoxLayout, QTabWidget,
    QAction, QToolBar, QProgressBar, QLabel, QGroupBox, QDoubleSpinBox,
    QSpinBox, QCheckBox, QPushButton, QTextEdit, QTableView, QSplitter,
    QHeaderView
)
from PyQt5.QtCore import Qt

class Ui_MainWindow:
    """
    Constructs GUI components for the primary Main Window of OpenMS Analyzer.
    """
    def setupUi(self, MainWindow: QMainWindow):
        MainWindow.setObjectName("MainWindow")
        MainWindow.resize(1100, 750)
        MainWindow.setWindowTitle("OpenMS Analyzer")

        # 1. Central Widget and Layouts
        self.centralwidget = QWidget(MainWindow)
        self.main_layout = QHBoxLayout(self.centralwidget)

        # Splitter to balance settings panel and results panel dynamically
        self.splitter = QSplitter(Qt.Horizontal, self.centralwidget)

        # 2. Left side: Parameters / Settings Panel
        self.settings_widget = QWidget()
        self.settings_layout = QVBoxLayout(self.settings_widget)
        self.settings_widget.setMinimumWidth(280)
        self.settings_widget.setMaximumWidth(400)

        # Peak picking group
        self.peak_group = QGroupBox("Peak Picking (Centroiding)", self.settings_widget)
        self.peak_layout = QVBoxLayout(self.peak_group)
        self.chk_peak_picking = QCheckBox("Enable Peak Picking", self.peak_group)
        self.chk_peak_picking.setChecked(True)
        self.peak_layout.addWidget(self.chk_peak_picking)

        self.lbl_sn = QLabel("Signal to Noise Ratio Threshold:", self.peak_group)
        self.peak_layout.addWidget(self.lbl_sn)
        self.spin_sn = QDoubleSpinBox(self.peak_group)
        self.spin_sn.setRange(0.1, 100.0)
        self.spin_sn.setValue(1.0)
        self.spin_sn.setSingleStep(0.5)
        self.peak_layout.addWidget(self.spin_sn)
        self.settings_layout.addWidget(self.peak_group)

        # Feature finder group
        self.ff_group = QGroupBox("Feature Finder Options", self.settings_widget)
        self.ff_layout = QVBoxLayout(self.ff_group)

        self.lbl_min_spec = QLabel("Min Spectra (mass trace):", self.ff_group)
        self.ff_layout.addWidget(self.lbl_min_spec)
        self.spin_min_spec = QSpinBox(self.ff_group)
        self.spin_min_spec.setRange(2, 100)
        self.spin_min_spec.setValue(5)
        self.ff_layout.addWidget(self.spin_min_spec)

        self.lbl_charge_low = QLabel("Low Charge Limit:", self.ff_group)
        self.ff_layout.addWidget(self.lbl_charge_low)
        self.spin_charge_low = QSpinBox(self.ff_group)
        self.spin_charge_low.setRange(1, 10)
        self.spin_charge_low.setValue(1)
        self.ff_layout.addWidget(self.spin_charge_low)

        self.lbl_charge_high = QLabel("High Charge Limit:", self.ff_group)
        self.ff_layout.addWidget(self.lbl_charge_high)
        self.spin_charge_high = QSpinBox(self.ff_group)
        self.spin_charge_high.setRange(1, 10)
        self.spin_charge_high.setValue(4)
        self.ff_layout.addWidget(self.spin_charge_high)

        self.lbl_mz_tol = QLabel("m/z Tolerance (Da):", self.ff_group)
        self.ff_layout.addWidget(self.lbl_mz_tol)
        self.spin_mz_tol = QDoubleSpinBox(self.ff_group)
        self.spin_mz_tol.setRange(0.0001, 1.0)
        self.spin_mz_tol.setValue(0.03)
        self.spin_mz_tol.setDecimals(4)
        self.ff_layout.addWidget(self.spin_mz_tol)

        self.lbl_min_score = QLabel("Seed Minimum Score:", self.ff_group)
        self.ff_layout.addWidget(self.lbl_min_score)
        self.spin_min_score = QDoubleSpinBox(self.ff_group)
        self.spin_min_score.setRange(0.0, 1.0)
        self.spin_min_score.setValue(0.5)
        self.spin_min_score.setSingleStep(0.05)
        self.ff_layout.addWidget(self.spin_min_score)

        self.settings_layout.addWidget(self.ff_group)

        # Big "Run Pipeline" button
        self.btn_run_pipeline = QPushButton("🚀 Run Processing Pipeline", self.settings_widget)
        self.btn_run_pipeline.setStyleSheet("font-weight: bold; font-size: 14px; padding: 10px;")
        self.btn_run_pipeline.setEnabled(False)
        self.settings_layout.addWidget(self.btn_run_pipeline)

        # Add spacing stretching
        self.settings_layout.addStretch()

        # 3. Right side: Results Panel
        self.results_tab_widget = QTabWidget(self.splitter)

        # Tab 1: Spectrum & Chromatogram Plots (Internal splits)
        self.plot_tab_widget = QTabWidget()
        self.tab_spectrum = QWidget()
        self.tab_spectrum_layout = QVBoxLayout(self.tab_spectrum)
        self.plot_tab_widget.addTab(self.tab_spectrum, "Mass Spectrum View")

        self.tab_chromatogram = QWidget()
        self.tab_chromatogram_layout = QVBoxLayout(self.tab_chromatogram)
        self.plot_tab_widget.addTab(self.tab_chromatogram, "Chromatogram View (TIC)")

        self.tab_overlay = QWidget()
        self.tab_overlay_layout = QVBoxLayout(self.tab_overlay)
        self.plot_tab_widget.addTab(self.tab_overlay, "Feature Overlay Plot")

        self.results_tab_widget.addTab(self.plot_tab_widget, "📈 Visual Plots")

        # Tab 2: Feature Table
        self.tab_table = QWidget()
        self.tab_table_layout = QVBoxLayout(self.tab_table)
        self.table_view = QTableView(self.tab_table)
        self.table_view.setSortingEnabled(True)
        self.table_view.horizontalHeader().setSectionResizeMode(QHeaderView.Stretch)
        self.tab_table_layout.addWidget(self.table_view)
        self.results_tab_widget.addTab(self.tab_table, "📊 Feature Results Table")

        # Tab 3: Log Console Log
        self.tab_console = QWidget()
        self.tab_console_layout = QVBoxLayout(self.tab_console)
        self.console_output = QTextEdit(self.tab_console)
        self.console_output.setReadOnly(True)
        self.tab_console_layout.addWidget(self.console_output)
        self.results_tab_widget.addTab(self.tab_console, "💻 Console Logging")

        # Construct the layout using the splitter
        self.splitter.addWidget(self.settings_widget)
        self.splitter.addWidget(self.results_tab_widget)

        # Set proportions: 30% settings, 70% results
        self.splitter.setSizes([330, 770])

        self.main_layout.addWidget(self.splitter)
        MainWindow.setCentralWidget(self.centralwidget)

        # 4. Status Bar and Progress
        self.statusbar = MainWindow.statusBar()
        self.lbl_status = QLabel("Ready. Open a file to start processing.")
        self.progressbar = QProgressBar()
        self.progressbar.setMaximumWidth(200)
        self.progressbar.setVisible(False)
        self.progressbar.setRange(0, 100)

        self.statusbar.addWidget(self.lbl_status, 1)
        self.statusbar.addPermanentWidget(self.progressbar)

        # 5. Menu Bar Options
        self.menubar = MainWindow.menuBar()
        self.menuFile = self.menubar.addMenu("&File")

        self.actionOpenLocal = QAction("Open &Local File...", MainWindow)
        self.actionOpenLocal.setShortcut("Ctrl+O")
        self.actionOpenLocal.setStatusTip("Open a local mzML or mzXML file.")

        self.actionOpenDrive = QAction("Open from Google &Drive...", MainWindow)
        self.actionOpenDrive.setShortcut("Ctrl+D")
        self.actionOpenDrive.setStatusTip("Open an mzML or mzXML file from your Google Drive.")

        self.actionExportDrive = QAction("&Export Results to Drive...", MainWindow)
        self.actionExportDrive.setShortcut("Ctrl+E")
        self.actionExportDrive.setStatusTip("Saves features, plots, and metadata to Google Drive results folder.")
        self.actionExportDrive.setEnabled(False)

        self.actionExit = QAction("E&xit", MainWindow)
        self.actionExit.setShortcut("Ctrl+Q")
        self.actionExit.setStatusTip("Exit the application.")

        self.menuFile.addAction(self.actionOpenLocal)
        self.menuFile.addAction(self.actionOpenDrive)
        self.menuFile.addSeparator()
        self.menuFile.addAction(self.actionExportDrive)
        self.menuFile.addSeparator()
        self.menuFile.addAction(self.actionExit)

        # Toolbar setup
        self.toolbar = QToolBar("Main Operations", MainWindow)
        MainWindow.addToolBar(self.toolbar)
        self.toolbar.addAction(self.actionOpenLocal)
        self.toolbar.addAction(self.actionOpenDrive)
        self.toolbar.addSeparator()
        self.toolbar.addAction(self.actionExportDrive)
