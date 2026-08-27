"""
Plugin base classes and plugin loading system for PyCodeStudio.
"""

import importlib
import inspect
from pathlib import Path
from typing import Dict, List, Type

from utils.logger import logger


class BasePlugin:
    """Base class that all PyCodeStudio plugins should inherit from."""

    name: str = "Base Plugin"
    version: str = "1.0.0"
    author: str = "PyCodeStudio"
    description: str = "Base plugin class"

    def __init__(self, main_window=None) -> None:
        self.main_window = main_window

    def on_load(self) -> None:
        """Called when the plugin is loaded into PyCodeStudio."""
        pass

    def on_unload(self) -> None:
        """Called when the plugin is unloaded or during shutdown."""
        pass


class PluginManager:
    """Manages searching, loading, and lifetime of plugins."""

    def __init__(self, main_window=None) -> None:
        self.main_window = main_window
        self.loaded_plugins: Dict[str, BasePlugin] = {}
        self.plugin_dirs: List[Path] = [
            Path(__file__).parent,
            Path.home() / ".pycodestudio" / "plugins"
        ]

    def discover_and_load_plugins(self) -> None:
        """Discovers plugin files and instantiates plugin classes."""
        for p_dir in self.plugin_dirs:
            if not p_dir.exists():
                try:
                    p_dir.mkdir(parents=True, exist_ok=True)
                except Exception:
                    continue

            for py_file in p_dir.glob("*.py"):
                if py_file.name.startswith("__"):
                    continue
                self._load_plugin_file(py_file)

    def _load_plugin_file(self, file_path: Path) -> None:
        """Loads a single plugin python file."""
        module_name = file_path.stem
        try:
            spec = importlib.util.spec_from_file_location(module_name, str(file_path))
            if spec and spec.loader:
                module = importlib.util.module_from_spec(spec)
                spec.loader.exec_module(module)

                for _, obj in inspect.getmembers(module):
                    if (inspect.isclass(obj) and
                        issubclass(obj, BasePlugin) and
                        obj is not BasePlugin):
                        instance = obj(self.main_window)
                        instance.on_load()
                        self.loaded_plugins[instance.name] = instance
                        logger.info(f"Loaded plugin: {instance.name} v{instance.version}")
        except Exception as e:
            logger.error(f"Failed to load plugin from {file_path}: {e}")

    def unload_all(self) -> None:
        """Unloads all currently active plugins."""
        for name, plugin in list(self.loaded_plugins.items()):
            try:
                plugin.on_unload()
            except Exception as e:
                logger.error(f"Error unloading plugin {name}: {e}")
        self.loaded_plugins.clear()
