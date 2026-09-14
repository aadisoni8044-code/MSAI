"""
OpenMS AI Copilot / Assistant Panel
"""

import tkinter as tk
from openms.config import FUNCTION_HELP


class AICopilot(tk.Frame):
    """Rule-based OpenMS AI Assistant chat panel."""

    def __init__(self, parent, theme_manager, on_insert_code=None):
        theme = theme_manager.theme
        super().__init__(parent, bg=theme["bg_side"])
        self.theme_manager = theme_manager
        self.on_insert_code = on_insert_code

        self._build_ui()
        self.theme_manager.subscribe(self.apply_theme)

    def _build_ui(self):
        theme = self.theme_manager.theme

        header = tk.Label(
            self,
            text="OPENMS AI ASSISTANT",
            font=("Segoe UI", 9, "bold"),
            bg=theme["bg_side"],
            fg=theme["fg_text"],
            pady=6,
        )
        header.pack(side="top", fill="x")

        # Chat Log
        self.ai_log = tk.Text(
            self,
            bg=theme["bg_side"],
            fg=theme["fg_text"],
            font=("Segoe UI", 9),
            wrap="word",
            state="disabled",
            bd=0,
            highlightthickness=0,
            padx=8,
            pady=8,
        )
        self.ai_log.pack(side="top", fill="both", expand=True)

        self.ai_log.tag_configure("sender_user", font=("Segoe UI", 9, "bold"), foreground=theme["accent"])
        self.ai_log.tag_configure("sender_ai", font=("Segoe UI", 9, "bold"), foreground="#50fa7b")

        # Entry area
        entry_frame = tk.Frame(self, bg=theme["bg_side"])
        entry_frame.pack(side="bottom", fill="x", padx=6, pady=6)

        self.ai_entry = tk.Entry(
            entry_frame,
            bg=theme["bg_main"],
            fg=theme["fg_text"],
            insertbackground=theme["fg_text"],
            font=("Segoe UI", 9),
            bd=1,
            relief="solid",
        )
        self.ai_entry.pack(side="left", fill="x", expand=True, padx=(0, 4))
        self.ai_entry.bind("<Return>", lambda e: self.send_message())

        btn_send = tk.Button(
            entry_frame,
            text="Send",
            font=("Segoe UI", 8, "bold"),
            bg=theme["accent"],
            fg="#ffffff",
            bd=0,
            command=self.send_message,
            cursor="hand2",
        )
        btn_send.pack(side="right")

        self.write_log("OpenMS AI", "Hello! Ask me about any OpenMS function (e.g. box, boody_2D, machine) or ask 'list functions'.")

    def write_log(self, sender, message):
        self.ai_log.configure(state="normal")
        tag = "sender_user" if sender.lower() == "you" else "sender_ai"
        self.ai_log.insert("end", f"{sender}:\n", tag)
        self.ai_log.insert("end", f"{message}\n\n")
        self.ai_log.see("end")
        self.ai_log.configure(state="disabled")

    def send_message(self):
        msg = self.ai_entry.get().strip()
        if not msg:
            return
        self.ai_entry.delete(0, "end")
        self.write_log("You", msg)
        reply = self.respond(msg)
        self.write_log("OpenMS AI", reply)

    def respond(self, text):
        lower = text.lower()

        if "list" in lower and "function" in lower:
            names = ", ".join(FUNCTION_HELP.keys())
            return f"OpenMS built-in functions ({len(FUNCTION_HELP)}): {names}."

        for fname, desc in FUNCTION_HELP.items():
            if fname.lower() in lower:
                return desc

        if "run" in lower and "error" in lower:
            return "Check the Terminal Log panel at the bottom for exact line and error details."
        if "hello" in lower or "hi" == lower or "hey" in lower:
            return "Hello! How can I help you write OpenMS scripts today?"
        if "3d" in lower:
            return "boody_3D(obj) takes a shape or game object and renders a pseudo-3D viewport window."
        if "2d" in lower:
            return "boody_2D(obj) takes a shape or game object and renders a 2D viewport window."
        if "syntax" in lower:
            return "OpenMS syntax uses Python style: 'var = box(100)', 'if(cond):', and 'function name(params):'."
        return "Try asking about a specific function name or type 'list functions'."

    def apply_theme(self, theme):
        self.config(bg=theme["bg_side"])
        self.ai_log.config(bg=theme["bg_side"], fg=theme["fg_text"])
