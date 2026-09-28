from PySide6.QtCore import QThread, Signal
from exe_tow.core.build_engine import BuildEngine
from exe_tow.core.models import CommandExecution

class BuildWorker(QThread):
    status_signal = Signal(str)
    log_signal = Signal(str)
    attempt_signal = Signal(object) # CommandExecution object
    finished_signal = Signal(object) # BuildRecord object

    def __init__(self, build_config: dict, parent=None):
        super().__init__(parent)
        self.build_config = build_config
        self.engine = BuildEngine()

    def run(self):
        record = self.engine.run_build(
            project_path=self.build_config["project_path"],
            exe_name=self.build_config["exe_name"],
            output_folder=self.build_config["output_folder"],
            build_mode=self.build_config.get("build_mode", "ONE FILE"),
            engine_name=self.build_config.get("engine_name", "PyInstaller"),
            status_callback=self.status_signal.emit,
            log_callback=self.log_signal.emit,
            attempt_callback=self.attempt_signal.emit
        )
        self.finished_signal.emit(record)

    def stop(self):
        self.engine.stop_build()
