"""
MSAI Studio - AI Assistant Sidebar View
"""
from PyQt6.QtWidgets import (
    QWidget, QVBoxLayout, QHBoxLayout, QLabel, QTextEdit, QPushButton, QComboBox
)
from PyQt6.QtCore import pyqtSignal
from ai.ai_assistant import AIAssistant

class AIView(QWidget):
    """
    MSAI AI Assistant sidebar view with prompts for code explanation, refactoring,
    fix errors, document generation, and code conversion.
    """
    def __init__(self, ai_assistant: AIAssistant, parent=None):
        super().__init__(parent)
        self.ai_assistant = ai_assistant

        layout = QVBoxLayout(self)
        layout.setContentsMargins(8, 8, 8, 8)

        title = QLabel("🤖 MSAI AI ASSISTANT")
        title.setStyleSheet("font-size: 11px; font-weight: bold; color: #89b4fa;")
        layout.addWidget(title)

        # Mode Selection
        self.combo_mode = QComboBox()
        self.combo_mode.addItems([
            "Explain Code",
            "Fix Code / Errors",
            "Refactor Code",
            "Generate Docstrings",
            "Generate Code from Request"
        ])
        layout.addWidget(self.combo_mode)

        # Input Code or Prompt
        self.input_edit = QTextEdit()
        self.input_edit.setPlaceholderText("Paste Python code or prompt here...")
        layout.addWidget(self.input_edit)

        # Action Button
        self.btn_submit = QPushButton("Ask AI Assistant")
        self.btn_submit.setStyleSheet("background-color: #89b4fa; color: #11111b; font-weight: bold; padding: 6px;")
        self.btn_submit.clicked.connect(self._process_ai_request)
        layout.addWidget(self.btn_submit)

        # Output Response
        layout.addWidget(QLabel("<b>AI Response</b>"))
        self.output_edit = QTextEdit()
        self.output_edit.setReadOnly(True)
        layout.addWidget(self.output_edit)

    def _process_ai_request(self):
        mode = self.combo_mode.currentText()
        text = self.input_edit.toPlainText().strip()

        if not text:
            self.output_edit.setText("Please enter code or prompt text.")
            return

        self.output_edit.setText("Processing AI Request...")

        if mode == "Explain Code":
            ok, res = self.ai_assistant.explain_code(text)
        elif mode == "Fix Code / Errors":
            ok, res = self.ai_assistant.fix_code(text)
        elif mode == "Refactor Code":
            ok, res = self.ai_assistant.refactor_code(text)
        elif mode == "Generate Docstrings":
            ok, res = self.ai_assistant.generate_docstrings(text)
        else: # Generate Code from Request
            ok, res = self.ai_assistant.generate_code_from_prompt(text)

        self.output_edit.setText(res)
