"""
MSAI Studio - AI Assistant Engine
"""
from typing import Tuple, Optional
from ai.ai_provider import AIProvider

class AIAssistant:
    """Provides high-level AI capabilities for Python development."""

    def __init__(self, provider: Optional[AIProvider] = None):
        self.provider = provider or AIProvider()

    def set_provider(self, provider: AIProvider):
        self.provider = provider

    def explain_code(self, code_snippet: str) -> Tuple[bool, str]:
        prompt = f"Explain the following Python code in detail:\n\n```python\n{code_snippet}\n```"
        return self.provider.generate_response(prompt)

    def fix_code(self, code_snippet: str, error_message: str = "") -> Tuple[bool, str]:
        prompt = f"Fix the issues in the following Python code:\n\n```python\n{code_snippet}\n```"
        if error_message:
            prompt += f"\n\nError Message:\n{error_message}"
        return self.provider.generate_response(prompt)

    def refactor_code(self, code_snippet: str) -> Tuple[bool, str]:
        prompt = f"Refactor the following Python code for better efficiency, readability, and PEP 8 compliance:\n\n```python\n{code_snippet}\n```"
        return self.provider.generate_response(prompt)

    def generate_docstrings(self, code_snippet: str) -> Tuple[bool, str]:
        prompt = f"Generate complete docstrings and comments for this Python code:\n\n```python\n{code_snippet}\n```"
        return self.provider.generate_response(prompt)

    def generate_code_from_prompt(self, description: str) -> Tuple[bool, str]:
        prompt = f"Write clean, idiomatic Python code based on this request:\n\n{description}"
        return self.provider.generate_response(prompt)
