"""Terminal and Log panel component for Kora GUI."""

import tkinter as tk
from tkinter import ttk, filedialog, messagebox


class TerminalView(ttk.Frame):
    """Terminal & Build Log display panel with controls."""

    def __init__(self, parent):
        super().__init__(parent)
        self._build_ui()

    def _build_ui(self):
        # Header bar
        header = ttk.Frame(self)
        header.pack(fill=tk.X, pady=(0, 5))

        lbl = ttk.Label(header, text="BUILD LOG & TERMINAL OUTPUT", font=("Segoe UI", 9, "bold"))
        lbl.pack(side=tk.LEFT)

        btn_copy = ttk.Button(header, text="Copy Logs", command=self.copy_logs)
        btn_copy.pack(side=tk.RIGHT, padx=2)

        btn_save = ttk.Button(header, text="Save Logs", command=self.save_logs)
        btn_save.pack(side=tk.RIGHT, padx=2)

        btn_clear = ttk.Button(header, text="Clear", command=self.clear_logs)
        btn_clear.pack(side=tk.RIGHT, padx=2)

        # Scrolled Text Box
        text_frame = ttk.Frame(self)
        text_frame.pack(fill=tk.BOTH, expand=True)

        self.text_area = tk.Text(
            text_frame,
            wrap=tk.WORD,
            bg="#0F172A",
            fg="#F8FAFC",
            insertbackground="#FFFFFF",
            font=("Consolas", 9),
            state=tk.DISABLED
        )
        scroll = ttk.Scrollbar(text_frame, orient=tk.VERTICAL, command=self.text_area.yview)
        self.text_area.configure(yscrollcommand=scroll.set)

        scroll.pack(side=tk.RIGHT, fill=tk.Y)
        self.text_area.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)

    def append_log(self, text: str):
        """Appends log text line into terminal view safely from any thread."""
        self.text_area.configure(state=tk.NORMAL)
        self.text_area.insert(tk.END, text + "\n")
        self.text_area.see(tk.END)
        self.text_area.configure(state=tk.DISABLED)

    def clear_logs(self):
        self.text_area.configure(state=tk.NORMAL)
        self.text_area.delete("1.0", tk.END)
        self.text_area.configure(state=tk.DISABLED)

    def get_logs(self) -> str:
        return self.text_area.get("1.0", tk.END)

    def copy_logs(self):
        logs = self.get_logs()
        self.clipboard_clear()
        self.clipboard_append(logs)
        messagebox.showinfo("Kora", "Build logs copied to clipboard.")

    def save_logs(self):
        file_path = filedialog.asksaveasfilename(
            defaultextension=".log",
            filetypes=[("Log Files", "*.log"), ("Text Files", "*.txt"), ("All Files", "*.*")]
        )
        if file_path:
            try:
                with open(file_path, "w", encoding="utf-8") as f:
                    f.write(self.get_logs())
                messagebox.showinfo("Kora", f"Logs saved to {file_path}")
            except Exception as e:
                messagebox.showerror("Kora", f"Failed to save logs: {e}")
