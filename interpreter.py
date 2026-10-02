"""
Interpreter / Execution Backend for Jps script.
Evaluates AST nodes, manages runtime environment, and controls Pygame rendering engine.
"""

import os
import sys
from typing import Dict, Any, List, Callable, Optional
from parser import (
    ProgramNode, ImportNode, AssignmentNode, FunctionCallNode,
    PrintNode, LiteralNode, IdentifierNode, ASTNode
)

class InterpreterError(Exception):
    def __init__(self, message: str, line: int):
        super().__init__(f"RuntimeError at line {line}: {message}")
        self.message = message
        self.line = line

class Body2D:
    def __init__(self, module: str, x: float = 200, y: float = 200, size: float = 50):
        self.module = module
        self.x = x
        self.y = y
        self.size = size
        self.vx = 3
        self.vy = 3

    def __repr__(self):
        return f"<Body2D module={self.module} pos=({int(self.x)},{int(self.y)})>"

class Interpreter:
    def __init__(self, output_func: Optional[Callable[[str], None]] = None, interactive: bool = True):
        self.variables: Dict[str, Any] = {}
        self.imported_modules: set = set()
        self.output_func = output_func or (lambda s: sys.stdout.write(s))
        self.interactive = interactive

        # Engine settings
        self.box_size = (500, 500)
        self.game_size = (800, 600)
        self.box_bodies: List[Body2D] = []
        self.game_bodies: List[Body2D] = []
        self.active_mode = "default"

    def log(self, text: str):
        if self.output_func:
            self.output_func(str(text) + "\n")

    def execute(self, ast: ProgramNode):
        for stmt in ast.statements:
            self.execute_statement(stmt)

    def execute_statement(self, node: ASTNode) -> Any:
        if isinstance(node, ImportNode):
            self.imported_modules.add(node.module_name)
            self.log(f"[Compiler] Imported module '{node.module_name}'")
            return f"Module({node.module_name})"

        elif isinstance(node, AssignmentNode):
            val = self.evaluate_expression(node.expr)
            self.variables[node.var_name] = val
            return val

        elif isinstance(node, FunctionCallNode):
            return self.execute_function_call(node)

        elif isinstance(node, PrintNode):
            values = [str(self.evaluate_expression(arg)) for arg in node.arguments]
            output = " ".join(values)
            self.log(output)
            return output

        else:
            raise InterpreterError(f"Unknown statement type {type(node).__name__}", getattr(node, 'line', 0))

    def evaluate_expression(self, node: ASTNode) -> Any:
        if isinstance(node, LiteralNode):
            return node.value
        elif isinstance(node, IdentifierNode):
            if node.name in self.variables:
                return self.variables[node.name]
            raise InterpreterError(f"Undefined variable '{node.name}'", node.line)
        elif isinstance(node, FunctionCallNode):
            return self.execute_function_call(node)
        else:
            raise InterpreterError(f"Cannot evaluate expression of type {type(node).__name__}", getattr(node, 'line', 0))

    def execute_function_call(self, node: FunctionCallNode) -> Any:
        action = node.action
        module = node.module
        args = [self.evaluate_expression(arg) for arg in node.arguments]

        if module not in self.imported_modules:
            self.log(f"[Warning] Module '{module}' was not explicitly imported before calling '{action}.{module}'. Auto-importing.")
            self.imported_modules.add(module)

        if action == "body_2D":
            body = Body2D(module=module)
            if module == "box":
                self.box_bodies.append(body)
            else:
                self.game_bodies.append(body)
            return body

        elif action == "size":
            if len(args) >= 2:
                w, h = int(args[0]), int(args[1])
            elif len(args) == 1:
                w = h = int(args[0])
            else:
                w, h = (500, 500) if module == "box" else (800, 600)

            if module == "box":
                self.box_size = (w, h)
            else:
                self.game_size = (w, h)
            return (w, h)

        elif action == "run":
            return self.run_engine(module, node.line)

        elif action == "switch":
            self.active_mode = module
            self.log(f"[Engine] Switched active mode to '{module}'")
            return f"Switched({module})"

        else:
            raise InterpreterError(f"Unknown action '{action}' on module '{module}'", node.line)

    def run_engine(self, module: str, line: int) -> str:
        self.log(f"[Engine] Starting {module.upper()} engine rendering loop...")

        os.environ["PYGAME_HIDE_SUPPORT_PROMPT"] = "1"
        os.environ["SDL_AUDIODRIVER"] = "dummy"

        try:
            import pygame
        except ImportError:
            self.log("[Engine Error] Pygame module not installed.")
            return f"EngineRun({module}: Failed - Pygame missing)"

        # Initialize Pygame headless if display not active
        if not self.interactive or "DISPLAY" not in os.environ and sys.platform.startswith("linux"):
            os.environ["SDL_VIDEODRIVER"] = "dummy"

        try:
            pygame.init()
            width, height = self.box_size if module == "box" else self.game_size
            screen = pygame.display.set_mode((width, height))
            pygame.display.set_caption(f"Jps Script Engine - {module.upper()} Mode")
            clock = pygame.time.Clock()

            running = True
            frame_count = 0
            is_dummy = os.environ.get("SDL_VIDEODRIVER") == "dummy"
            max_frames = 60 if is_dummy else None

            bodies = self.box_bodies if module == "box" else self.game_bodies
            if not bodies:
                bodies = [Body2D(module, width // 2, height // 2, 50)]

            bg_color = (15, 23, 42) if module == "box" else (10, 15, 29)
            box_color = (0, 240, 255) if module == "box" else (255, 100, 50)

            while running:
                for event in pygame.event.get():
                    if event.type == pygame.QUIT or (event.type == pygame.KEYDOWN and event.key == pygame.K_ESCAPE):
                        running = False

                screen.fill(bg_color)

                for b in bodies:
                    b.x += b.vx
                    b.y += b.vy

                    if b.x <= 0 or b.x + b.size >= width:
                        b.vx *= -1
                    if b.y <= 0 or b.y + b.size >= height:
                        b.vy *= -1

                    rect = pygame.Rect(int(b.x), int(b.y), int(b.size), int(b.size))
                    pygame.draw.rect(screen, box_color, rect, border_radius=6)
                    pygame.draw.rect(screen, (255, 255, 255), rect, width=2, border_radius=6)

                pygame.display.flip()
                clock.tick(60)

                frame_count += 1
                if max_frames and frame_count >= max_frames:
                    running = False

            pygame.quit()
            self.log(f"[Engine] {module.upper()} engine execution completed.")
            return f"EngineRun({module}: Completed)"

        except Exception as e:
            self.log(f"[Engine Error] {e}")
            return f"EngineRun({module}: Error {e})"
