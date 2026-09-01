"""
AI Copilot Assistant Panel Component
"""

import tkinter as tk
from openms.config import FUNCTION_HELP


class AICopilotPanel(tk.Frame):
    """VS Code AI Assistant / Copilot drawer panel on right side."""

    def __init__(self, parent, theme_manager, on_insert_code_cb=None):
        self.theme_manager = theme_manager
        theme = theme_manager.theme
        super().__init__(parent, bg=theme["bg_sidebar"], width=300)
        self.pack_propagate(False)

        self.on_insert_code = on_insert_code_cb

        self.theme_manager.register(self.apply_theme)
        self._build_panel()

    def _build_panel(self):
        theme = self.theme_manager.theme

        # Header
        header = tk.Frame(self, bg=theme["bg_tab"], height=35)
        header.pack(fill="x", side="top")

        lbl = tk.Label(
            header,
            text="🤖 OPENMS AI COPILOT",
            font=("Segoe UI", 9, "bold"),
            bg=theme["bg_tab"],
            fg=theme["fg_sidebar"],
        )
        lbl.pack(side="left", padx=10)

        # Chat Log Box
        self.chat_log = tk.Text(
            self,
            bg=theme["bg_sidebar"],
            fg=theme["fg_sidebar"],
            font=("Segoe UI", 9),
            wrap="word",
            border=0,
            padx=10,
            pady=8,
            state="disabled",
        )
        self.chat_log.pack(fill="both", expand=True)

        self.chat_log.tag_configure("sender_user", font=("Segoe UI", 9, "bold"), foreground=theme["accent_blue"])
        self.chat_log.tag_configure("sender_ai", font=("Segoe UI", 9, "bold"), foreground=theme["accent_green"])
        self.chat_log.tag_configure("msg", font=("Segoe UI", 9), foreground=theme["fg_sidebar"])

        # Quick action suggestions
        quick_frame = tk.Frame(self, bg=theme["bg_sidebar"])
        quick_frame.pack(fill="x", padx=6, pady=2)

        btn1 = tk.Button(
            quick_frame,
            text="List Functions",
            font=("Segoe UI", 8),
            bg=theme["bg_main"],
            fg=theme["fg_text"],
            command=lambda: self._send_msg("list functions"),
        )
        btn1.pack(side="left", padx=2)

        btn2 = tk.Button(
            quick_frame,
            text="Insert Sample",
            font=("Segoe UI", 8),
            bg=theme["bg_main"],
            fg=theme["fg_text"],
            command=self._insert_sample,
        )
        btn2.pack(side="left", padx=2)

        # Input Area
        input_frame = tk.Frame(self, bg=theme["bg_tab"], height=40)
        input_frame.pack(fill="x", side="bottom")

        self.entry = tk.Entry(
            input_frame,
            bg=theme["bg_main"],
            fg=theme["fg_text"],
            insertbackground=theme["fg_text"],
            font=("Segoe UI", 9),
            bd=1,
            relief="solid",
        )
        self.entry.pack(side="left", fill="x", expand=True, padx=6, pady=6)
        self.entry.bind("<Return>", lambda e: self.send_message())

        btn_send = tk.Button(
            input_frame,
            text="Send",
            font=("Segoe UI", 8, "bold"),
            bg=theme["accent_blue"],
            fg="#ffffff",
            bd=0,
            padx=8,
            command=self.send_message,
        )
        btn_send.pack(side="right", padx=6, pady=6)

        # Initial greeting
        self.write_log("OpenMS AI", "Hello! I am your OpenMS AI Assistant. Ask me about any of the 14 functions or type 'list functions'.")

    def _send_msg(self, text):
        self.entry.delete(0, "end")
        self.entry.insert(0, text)
        self.send_message()

    def send_message(self):
        msg = self.entry.get().strip()
        if not msg:
            return
        self.entry.delete(0, "end")
        self.write_log("You", msg)
        reply = self.ai_respond(msg)
        self.write_log("OpenMS AI", reply)

    def write_log(self, sender, message):
        self.chat_log.configure(state="normal")
        tag = "sender_user" if sender.lower() == "you" else "sender_ai"
        self.chat_log.insert("end", f"{sender}:\n", tag)
        self.chat_log.insert("end", f"{message}\n\n", "msg")
        self.chat_log.see("end")
        self.chat_log.configure(state="disabled")

    def ai_respond(self, text):
        lower = text.lower()
        for fname, desc in FUNCTION_HELP.items():
            if fname.lower() in lower:
                return desc
        if "list" in lower and "function" in lower:
            names = ", ".join(FUNCTION_HELP.keys())
            return f"OpenMS built-in functions (14 total): {names}."
        if "3d" in lower:
            return "boody_3D(obj) renders shapes into a live pseudo-3D window."
        if "2d" in lower:
            return "boody_2D(obj) renders shapes into a flat 2D canvas window."
        if "hello" in lower or "hi" in lower:
            return "Hello! How can I assist with your OpenMS code today?"
        return ("I can help with OpenMS functions: machine, box, bol, size, photo, time, house, game, boody_2D, boody_3D, input, open, function, if. Try typing 'list functions'!")

    def _insert_sample(self):
        sample = "box1 = box(150, '#007acc')\nboody_2D(box1)\nmachine(box1)\n"
        if self.on_insert_code:
            self.on_insert_code(sample)

    def apply_theme(self, theme):
        self.config(bg=theme["bg_sidebar"])
        self.chat_log.config(bg=theme["bg_sidebar"], fg=theme["fg_sidebar"])
