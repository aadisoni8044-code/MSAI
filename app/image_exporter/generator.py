"""Image to EXE Generator module for Kora."""

import os
import shutil
from typing import Dict, Any, Optional, Callable
from models.project_info import ProjectInfo
from models.build_strategy import BuildStrategy, BuildResult
from models.settings import Settings, PermissionRequest
from app.build_engine.engine import BuildEngine
from app.logger import logger


SUPPORTED_IMAGE_EXTENSIONS = {".png", ".jpg", ".jpeg", ".bmp", ".gif", ".webp"}


def get_resource_path_code() -> str:
    """Returns Python helper code for resolving PyInstaller resource paths."""
    return '''import sys
import os

def resource_path(relative_path):
    """Get absolute path to resource, works for dev and for PyInstaller"""
    try:
        base_path = sys._MEIPASS
    except AttributeError:
        base_path = os.path.abspath(".")
    return os.path.join(base_path, relative_path)
'''


def generate_viewer_script(image_filename: str) -> str:
    """Generates a Python viewer script that loads and displays embedded image using Tkinter & Pillow with aspect ratio fitting."""
    res_code = get_resource_path_code()
    return f'''{res_code}
import tkinter as tk
from PIL import Image, ImageTk

class ImageViewer(tk.Tk):
    def __init__(self, image_path):
        super().__init__()
        self.title("KORA Image Viewer")
        self.geometry("800x600")
        self.configure(bg="#0F172A")

        self.image_path = image_path
        try:
            self.pil_image = Image.open(self.image_path)
        except Exception as e:
            tk.Label(self, text=f"Error loading image: {{e}}", fg="#EF4444", bg="#0F172A").pack(expand=True)
            return

        self.canvas = tk.Canvas(self, bg="#0F172A", highlightthickness=0)
        self.canvas.pack(fill=tk.BOTH, expand=True)

        self.tk_image = None
        self.bind("<Configure>", self.on_resize)

    def on_resize(self, event):
        if not hasattr(self, 'pil_image'):
            return
        c_width = event.width
        c_height = event.height
        if c_width <= 10 or c_height <= 10:
            return

        img_w, img_h = self.pil_image.size
        ratio = min(c_width / img_w, c_height / img_h)
        new_w = max(1, int(img_w * ratio))
        new_h = max(1, int(img_h * ratio))

        resized = self.pil_image.resize((new_w, new_h), Image.Resampling.LANCZOS)
        self.tk_image = ImageTk.PhotoImage(resized)

        self.canvas.delete("all")
        self.canvas.create_image(c_width // 2, c_height // 2, image=self.tk_image, anchor="center")

if __name__ == "__main__":
    img_file = resource_path("{image_filename}")
    app = ImageViewer(img_file)
    app.mainloop()
'''


class ImageExeExporter:
    """Handles packaging image files into standalone Windows executables."""

    def __init__(self, settings: Optional[Settings] = None):
        self.settings = settings or Settings()

    def validate_image_path(self, image_path: str) -> Dict[str, Any]:
        """Validates input image file format, size, and dimensions."""
        path_obj = os.path.abspath(image_path)
        if not os.path.isfile(path_obj):
            return {"valid": False, "error": "Image file does not exist."}

        ext = os.path.splitext(path_obj)[1].lower()
        if ext not in SUPPORTED_IMAGE_EXTENSIONS:
            return {"valid": False, "error": f"Unsupported image format: {ext}. Supported formats: {', '.join(sorted(SUPPORTED_IMAGE_EXTENSIONS))}"}

        size_bytes = os.path.getsize(path_obj)
        size_mb = round(size_bytes / (1024 * 1024), 2)

        dimensions = (0, 0)
        try:
            from PIL import Image
            with Image.open(path_obj) as img:
                dimensions = img.size
        except Exception:
            pass

        return {
            "valid": True,
            "image_path": path_obj,
            "filename": os.path.basename(path_obj),
            "extension": ext,
            "size_bytes": size_bytes,
            "size_mb": size_mb,
            "dimensions": dimensions
        }

    def export_image_to_exe(
        self,
        image_path: str,
        output_exe_name: str,
        output_dir: str,
        on_status_update: Optional[Callable[[str], None]] = None,
        on_log_line: Optional[Callable[[str], None]] = None
    ) -> BuildResult:
        """Packages image into standalone executable inside temporary workspace."""
        val = self.validate_image_path(image_path)
        if not val["valid"]:
            raise ValueError(val["error"])

        if not output_exe_name.lower().endswith(".exe"):
            app_name = output_exe_name
        else:
            app_name = output_exe_name[:-4]

        abs_output_dir = os.path.abspath(output_dir)
        os.makedirs(abs_output_dir, exist_ok=True)

        # Temporary Build Workspace
        workspace_dir = os.path.abspath(".kora_image_build")
        if os.path.exists(workspace_dir):
            shutil.rmtree(workspace_dir, ignore_errors=True)
        os.makedirs(workspace_dir, exist_ok=True)

        try:
            if on_status_update:
                on_status_update("Preparing image resource...")

            img_filename = os.path.basename(val["image_path"])
            target_img_path = os.path.join(workspace_dir, img_filename)
            shutil.copy2(val["image_path"], target_img_path)

            viewer_script_path = os.path.join(workspace_dir, "viewer.py")
            script_content = generate_viewer_script(img_filename)
            with open(viewer_script_path, "w", encoding="utf-8") as f:
                f.write(script_content)

            # Construct ProjectInfo for Kora Build Engine
            project_info = ProjectInfo(
                project_path=workspace_dir,
                project_name=app_name,
                python_files=["viewer.py"],
                entry_point_candidates=["viewer.py"],
                selected_entry_point="viewer.py",
                detected_assets=[img_filename],
                selected_assets=[img_filename],
                is_onefile=True,
                is_gui=True,
                app_name=app_name
            )

            # Configure Engine and execute build
            perms = PermissionRequest(folder_access=True, execute_commands=True, create_files=True, install_packages=True)
            engine = BuildEngine(settings=self.settings, permissions=perms)

            if on_status_update:
                on_status_update("Building Image EXE...")

            strat = BuildStrategy(builder_name="PyInstaller", mode="onefile", is_gui=True)
            result = engine.run_build(
                project_info=project_info,
                initial_strategy=strat,
                on_status_update=on_status_update,
                on_log_line=on_log_line
            )

            # Move produced EXE to user's desired output location
            if result.status == "SUCCESS" and result.output_exe and os.path.isfile(result.output_exe):
                target_exe = os.path.join(abs_output_dir, f"{app_name}.exe")
                shutil.move(result.output_exe, target_exe)
                result.output_exe = target_exe

            return result

        finally:
            # Clean up temporary build workspace
            if os.path.exists(workspace_dir):
                try:
                    shutil.rmtree(workspace_dir, ignore_errors=True)
                except Exception:
                    pass
