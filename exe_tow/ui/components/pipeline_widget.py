from PySide6.QtWidgets import QWidget, QHBoxLayout, QVBoxLayout, QLabel, QFrame
from PySide6.QtCore import Qt

PIPELINE_STEPS_LABELS = [
    "PROJECT SCANNED",
    "ENTRY FILE DETECTED",
    "DEPENDENCIES COLLECTED",
    "ASSETS PREPARED",
    "PACKAGING EXE",
    "FINALIZING",
    "COMPLETE"
]

class PipelineStepItem(QFrame):
    """Individual step card in the build pipeline display."""

    def __init__(self, step_index: int, label_text: str, parent=None):
        super().__init__(parent)
        self.step_index = step_index
        self.label_text = label_text

        layout = QHBoxLayout(self)
        layout.setContentsMargins(8, 6, 8, 6)
        layout.setSpacing(8)

        self.icon_label = QLabel("○")
        self.icon_label.setStyleSheet("font-size: 13px; font-weight: bold; color: #4A5060;")
        layout.addWidget(self.icon_label)

        self.text_label = QLabel(label_text)
        self.text_label.setStyleSheet("font-size: 11px; font-weight: 700; color: #4A5060;")
        layout.addWidget(self.text_label)

        self.set_state("pending")

    def set_state(self, state: str):
        """state can be 'pending', 'active', 'completed', 'failed'"""
        if state == "completed":
            self.setStyleSheet("""
                PipelineStepItem {
                    background-color: #0E1A14;
                    border: 1px solid #143322;
                    border-radius: 6px;
                }
            """)
            self.icon_label.setText("✓")
            self.icon_label.setStyleSheet("font-size: 13px; font-weight: bold; color: #00FF66;")
            self.text_label.setStyleSheet("font-size: 11px; font-weight: 700; color: #00FF66;")

        elif state == "active":
            self.setStyleSheet("""
                PipelineStepItem {
                    background-color: #122B1E;
                    border: 1px solid #00FF66;
                    border-radius: 6px;
                }
            """)
            self.icon_label.setText("●")
            self.icon_label.setStyleSheet("font-size: 13px; font-weight: bold; color: #00FF66;")
            self.text_label.setStyleSheet("font-size: 11px; font-weight: 800; color: #FFFFFF;")

        elif state == "failed":
            self.setStyleSheet("""
                PipelineStepItem {
                    background-color: #2A1215;
                    border: 1px solid #FF4D4D;
                    border-radius: 6px;
                }
            """)
            self.icon_label.setText("✕")
            self.icon_label.setStyleSheet("font-size: 13px; font-weight: bold; color: #FF4D4D;")
            self.text_label.setStyleSheet("font-size: 11px; font-weight: 800; color: #FF4D4D;")

        else: # pending
            self.setStyleSheet("""
                PipelineStepItem {
                    background-color: #0E1015;
                    border: 1px solid #1A1D26;
                    border-radius: 6px;
                }
            """)
            self.icon_label.setText("○")
            self.icon_label.setStyleSheet("font-size: 13px; font-weight: bold; color: #4A5060;")
            self.text_label.setStyleSheet("font-size: 11px; font-weight: 600; color: #6A7082;")

class PipelineWidget(QFrame):
    """Horizontal/Vertical pipeline steps display container."""

    def __init__(self, parent=None):
        super().__init__(parent)
        self.setStyleSheet("""
            PipelineWidget {
                background-color: #0A0C10;
                border: 1px solid #1C202C;
                border-radius: 8px;
                padding: 8px;
            }
        """)

        layout = QHBoxLayout(self)
        layout.setContentsMargins(10, 8, 10, 8)
        layout.setSpacing(6)

        self.step_items = []
        for i, text in enumerate(PIPELINE_STEPS_LABELS):
            item = PipelineStepItem(i, text)
            self.step_items.append(item)
            layout.addWidget(item)

    def set_current_step(self, current_index: int, is_failed: bool = False):
        """Updates pipeline states up to current_index."""
        for i, item in enumerate(self.step_items):
            if is_failed and i == current_index:
                item.set_state("failed")
            elif i < current_index:
                item.set_state("completed")
            elif i == current_index:
                item.set_state("active")
            else:
                item.set_state("pending")

    def reset_pipeline(self):
        for item in self.step_items:
            item.set_state("pending")
