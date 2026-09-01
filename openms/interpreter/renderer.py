"""
Canvas Renderers for OpenMS 2D and 3D shapes
"""

import os
import tkinter as tk
from openms.models import OMSBox, OMSBall, OMSHouse, OMSGame, OMSPhoto, OMSBody2D, OMSBody3D


class OpenMSRenderer:
    """Handles rendering OpenMS objects into native Toplevel Tkinter Canvas windows."""

    def __init__(self, root, terminal_write_cb=None):
        self.root = root
        self.terminal_write = terminal_write_cb or (lambda msg: print(msg))
        self._render_window_count = 0

    def render_2d(self, obj):
        self._render_window_count += 1
        win = tk.Toplevel(self.root)
        win.title(f"OpenMS - 2D Render #{self._render_window_count}")
        win.configure(bg="#1e1e1e")
        win.geometry("520x440")
        canvas = tk.Canvas(win, width=490, height=380, bg="#f4f4f4", highlightthickness=0)
        canvas.pack(padx=12, pady=12)
        self._draw_shape_2d(canvas, obj, 245, 180)
        self.terminal_write(f"[boody_2D] Rendered {obj!r} -> new 2D window")

    def render_3d(self, obj):
        self._render_window_count += 1
        win = tk.Toplevel(self.root)
        win.title(f"OpenMS - 3D Render #{self._render_window_count}")
        win.configure(bg="#1e1e1e")
        win.geometry("520x440")
        canvas = tk.Canvas(win, width=490, height=380, bg="#0d0d10", highlightthickness=0)
        canvas.pack(padx=12, pady=12)
        self._draw_shape_3d(canvas, obj, 245, 200)
        self.terminal_write(f"[boody_3D] Rendered {obj!r} -> new 3D window")

    def _draw_shape_2d(self, canvas, obj, cx, cy):
        if isinstance(obj, OMSBox):
            s = max(min(obj.size, 300), 20)
            canvas.create_rectangle(cx - s / 2, cy - s / 2, cx + s / 2, cy + s / 2,
                                     fill=obj.color, outline="#222222", width=2)
            canvas.create_text(cx, cy + s / 2 + 22, text=f"Box  size={obj.size}", fill="#222222")
        elif isinstance(obj, OMSBall):
            r = max(min(obj.radius, 150), 10)
            canvas.create_oval(cx - r, cy - r, cx + r, cy + r,
                                fill=obj.color, outline="#222222", width=2)
            canvas.create_text(cx, cy + r + 22, text=f"Ball  radius={obj.radius}", fill="#222222")
        elif isinstance(obj, OMSHouse):
            w, h = obj.width / 2, obj.height / 2
            canvas.create_rectangle(cx - w / 2, cy - h / 4, cx + w / 2, cy + h / 2,
                                     fill="#d9b382", outline="#222222", width=2)
            canvas.create_polygon(cx - w / 2 - 12, cy - h / 4, cx + w / 2 + 12, cy - h / 4,
                                   cx, cy - h, fill="#b5482a", outline="#222222", width=2)
            canvas.create_text(cx, cy + h / 2 + 22, text=f"House  {obj.width}x{obj.height}", fill="#222222")
        elif isinstance(obj, OMSPhoto):
            canvas.create_rectangle(cx - 100, cy - 70, cx + 100, cy + 70,
                                     outline="#222222", width=2, dash=(4, 2))
            canvas.create_text(cx, cy, text=f"PHOTO\n{os.path.basename(str(obj.path))}",
                                fill="#222222", justify="center")
        elif isinstance(obj, OMSGame):
            canvas.create_rectangle(18, 18, 472, 362, outline="#4a90e2", width=3)
            canvas.create_text(cx, 40, text=obj.title, fill="#2f5f9e",
                                font=("Consolas", 14, "bold"))
            if obj.objects:
                for sub in obj.objects:
                    self._draw_shape_2d(canvas, sub, cx, cy)
            else:
                canvas.create_text(cx, cy, text="(empty game world)", fill="#888888")
        elif isinstance(obj, (OMSBody2D, OMSBody3D)):
            self._draw_shape_2d(canvas, obj.source, cx, cy)
        else:
            canvas.create_text(cx, cy, text=str(obj), fill="#222222")

    def _draw_shape_3d(self, canvas, obj, cx, cy):
        if isinstance(obj, OMSBox):
            s = max(min(obj.size, 200), 30) / 2.0
            off = s * 0.55
            top = [(cx - s, cy - s + off), (cx, cy - s), (cx + s, cy - s + off), (cx, cy)]
            canvas.create_polygon(top, fill="#6fb1fc", outline="#ffffff")
            left = [(cx - s, cy - s + off), (cx, cy), (cx, cy + s * 1.2), (cx - s, cy + off)]
            canvas.create_polygon(left, fill="#4a90e2", outline="#ffffff")
            right = [(cx + s, cy - s + off), (cx, cy), (cx, cy + s * 1.2), (cx + s, cy + off)]
            canvas.create_polygon(right, fill="#357ab8", outline="#ffffff")
            canvas.create_text(cx, cy + s * 1.6 + 18, text=f"Box(3D)  size={obj.size}", fill="#e3e3e3")
        elif isinstance(obj, OMSBall):
            r = max(min(obj.radius, 120), 15)
            canvas.create_oval(cx - r, cy - r * 0.65, cx + r, cy + r * 0.65,
                                fill="#e94e77", outline="#ffffff")
            canvas.create_oval(cx - r * 0.4, cy - r * 0.55, cx + r * 0.1, cy - r * 0.15,
                                fill="#ff9fb6", outline="")
            canvas.create_text(cx, cy + r * 0.9, text=f"Ball(3D)  radius={obj.radius}", fill="#e3e3e3")
        elif isinstance(obj, OMSHouse):
            w, h = obj.width * 0.4, obj.height * 0.4
            canvas.create_rectangle(cx - w / 2, cy - h / 4, cx + w / 2, cy + h / 2,
                                     fill="#d9b382", outline="#ffffff")
            canvas.create_polygon(cx + w / 2, cy - h / 4, cx + w / 2 + 18, cy - h / 4 - 12,
                                   cx + w / 2 + 18, cy + h / 2 - 12, cx + w / 2, cy + h / 2,
                                   fill="#b58a5a", outline="#ffffff")
            canvas.create_polygon(cx - w / 2 - 12, cy - h / 4, cx + w / 2 + 12, cy - h / 4,
                                   cx, cy - h, fill="#b5482a", outline="#ffffff")
            canvas.create_text(cx, cy + h / 2 + 26, text=f"House(3D)  {obj.width}x{obj.height}", fill="#e3e3e3")
        elif isinstance(obj, OMSPhoto):
            canvas.create_rectangle(cx - 100, cy - 70, cx - 90, cy + 70, fill="#333333", outline="")
            canvas.create_rectangle(cx - 90, cy - 70, cx + 100, cy + 70,
                                     outline="#ffffff", width=2, dash=(4, 2))
            canvas.create_text(cx + 5, cy, text=f"PHOTO(3D)\n{os.path.basename(str(obj.path))}",
                                fill="#e3e3e3", justify="center")
        elif isinstance(obj, OMSGame):
            canvas.create_text(cx, 30, text=f"{obj.title}  (3D World)", fill="#4fc1ff",
                                font=("Consolas", 14, "bold"))
            if obj.objects:
                for sub in obj.objects:
                    self._draw_shape_3d(canvas, sub, cx, cy)
            else:
                canvas.create_text(cx, cy, text="(empty 3D world)", fill="#888888")
        elif isinstance(obj, (OMSBody2D, OMSBody3D)):
            self._draw_shape_3d(canvas, obj.source, cx, cy)
        else:
            canvas.create_text(cx, cy, text=str(obj), fill="#e3e3e3")
