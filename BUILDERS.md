# Builder Plugin Architecture

Kora features a modular builder architecture. Every builder inherits from `BaseBuilder` in `builders/base_builder.py`.

## Base Builder Interface

```python
class BaseBuilder(ABC):
    name: str

    @abstractmethod
    def is_available(self, python_path: str = "python") -> bool:
        pass

    @abstractmethod
    def can_build(self, project_info: ProjectInfo) -> bool:
        pass

    @abstractmethod
    def prepare(self, project_info: ProjectInfo, workspace_dir: str) -> bool:
        pass

    @abstractmethod
    def generate_command(
        self,
        project_info: ProjectInfo,
        strategy: BuildStrategy,
        python_path: str = "python"
    ) -> List[str]:
        pass

    @abstractmethod
    def detect_output(self, project_info: ProjectInfo, output_dir: str) -> Optional[str]:
        pass
```

## Supported Builders

1. **PyInstaller (`PyInstallerBuilder`)**: Primary build system supporting single-file (`--onefile`), directory (`--onedir`), console/windowed mode, icons, and bundled data assets (`--add-data`).
2. **Nuitka (`NuitkaBuilder`)**: High-performance Python compiler system supporting `--onefile` / `--standalone` modes and Windows resource bundling.
3. **cx_Freeze (`cxFreezeBuilder`)**: Fallback builder generating isolated setup scripts in Kora's temporary workspace without modifying user source code.

## Adding a New Builder

To add a new builder plugin:
1. Create a new file in `builders/my_new_builder.py`.
2. Implement `BaseBuilder`.
3. Register the instance in `builders/__init__.py` under `ALL_BUILDERS`.
