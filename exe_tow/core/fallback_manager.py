from typing import List, Dict, Any, Optional
from exe_tow.core.models import ProjectInfo, EnvironmentInfo, CommandExecution
from exe_tow.core.engines.base_engine import BaseEngine
from exe_tow.core.recovery_manager import RecoveryManager, ErrorCategory

class FallbackManager:
    def __init__(self, max_retries: int = 5):
        self.max_retries = max_retries

    def generate_strategy_sequence(
        self,
        engine: BaseEngine,
        project_info: ProjectInfo,
        env_info: EnvironmentInfo,
        exe_name: str,
        output_folder: str,
        build_mode: str
    ) -> List[Dict[str, Any]]:
        """Generates sequence of build attempts and potential recovery steps."""
        candidates = engine.build_command_candidates(
            project_info=project_info,
            env_info=env_info,
            exe_name=exe_name,
            output_folder=output_folder,
            build_mode=build_mode
        )

        strategies = []
        for idx, cmd in enumerate(candidates):
            if idx >= self.max_retries:
                break
            strategies.append({
                "attempt_index": idx + 1,
                "command": cmd,
                "reason": f"Build Strategy Candidate #{idx + 1}"
            })
        return strategies
