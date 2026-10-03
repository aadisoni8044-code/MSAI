import sys
import os
from typing import List, Dict, Any, Callable, Optional
from parser import (
    ProgramNode, ImportNode, LiteralNode, IdentifierNode, CallNode,
    AssignmentNode, PrintNode, ASTNode
)

class RuntimeErrorJps(Exception):
    def __init__(self, message: str, line: int = 1, column: int = 1):
        self.message = message
        self.line = line
        self.column = column
        super().__init__(f"Runtime Error [Line {line}, Col {column}]: {message}")


class BoxObject:
    def __init__(self, obj_id: int):
        self.id = obj_id
        self.x = 200.0
        self.y = 200.0
        self.width = 100
        self.height = 100
        self.vx = 3.0
        self.vy = 2.0
        self.is_moving = False
        self.draggable = False
        self.is_dragging = False
        self.drag_offset_x = 0.0
        self.drag_offset_y = 0.0

    def __repr__(self) -> str:
        return f"<Box id={self.id} pos=({self.x}, {self.y}) moving={self.is_moving} drag={self.draggable}>"


class Interpreter:
    def __init__(self, output_callback: Optional[Callable[[str], None]] = None):
        self.imported_modules = set()
        self.variables: Dict[str, Any] = {}
        self.output_callback = output_callback or (lambda text: print(text, end=''))

        # Engine configuration
        self.window_width = 800
        self.window_height = 600
        self.window_title = "Jps Script 2D Engine"
        self.is_game_mode = False

        self.boxes: List[BoxObject] = []
        self._next_box_id = 1

    def print_output(self, text: str):
        self.output_callback(text)

    def evaluate(self, program: ProgramNode, run_gui_loop: bool = True):
        for stmt in program.statements:
            self._exec_statement(stmt)

        # After evaluating statements, if interactive/running engine components were initialized,
        # we launch the Pygame engine loop if requested.
        if run_gui_loop and (self.is_game_mode or any(b.is_moving or b.draggable for b in self.boxes) or self.boxes):
            self._start_pygame_loop()

    def _exec_statement(self, node: ASTNode) -> Any:
        if isinstance(node, ImportNode):
            if node.module_name not in ("game", "box"):
                raise RuntimeErrorJps(f"Unsupported module '{node.module_name}'", node.line, node.column)
            self.imported_modules.add(node.module_name)
            if node.module_name == "game":
                self.is_game_mode = True
            return None

        elif isinstance(node, PrintNode):
            values = [self._eval_expression(arg) for arg in node.args]
            out_str = " ".join(str(v) for v in values) + "\n"
            self.print_output(out_str)
            return None

        elif isinstance(node, AssignmentNode):
            val = self._eval_expression(node.value)
            self.variables[node.var_name] = val
            return val

        elif isinstance(node, CallNode):
            return self._eval_call(node)

        else:
            raise RuntimeErrorJps(f"Unknown AST node {type(node).__name__}", node.line, node.column)

    def _eval_expression(self, node: ASTNode) -> Any:
        if isinstance(node, LiteralNode):
            return node.value

        elif isinstance(node, IdentifierNode):
            if node.name in self.variables:
                return self.variables[node.name]
            raise RuntimeErrorJps(f"Undefined variable '{node.name}'", node.line, node.column)

        elif isinstance(node, CallNode):
            return self._eval_call(node)

        else:
            raise RuntimeErrorJps(f"Invalid expression type {type(node).__name__}", node.line, node.column)

    def _eval_call(self, node: CallNode) -> Any:
        module = node.module
        action = node.action
        args = [self._eval_expression(a) for a in node.args]

        if module not in self.imported_modules:
            raise RuntimeErrorJps(f"Module '{module}' not imported. Call 'import.{module}' first.", node.line, node.column)

        if module == "box":
            if action == "body_2D":
                box = BoxObject(self._next_box_id)
                self._next_box_id += 1
                self.boxes.append(box)
                return box

            elif action == "size":
                if len(args) >= 2:
                    w, h = int(args[0]), int(args[1])
                    if self.boxes:
                        self.boxes[-1].width = w
                        self.boxes[-1].height = h
                    return (w, h)
                elif len(args) == 1:
                    w = int(args[0])
                    if self.boxes:
                        self.boxes[-1].width = w
                        self.boxes[-1].height = w
                    return (w, w)
                return (100, 100)

            elif action == "run":
                if self.boxes:
                    self.boxes[-1].is_moving = True
                    return f"<Box {self.boxes[-1].id} Running>"
                return "<Engine Running>"

            elif action == "switch":
                if self.boxes:
                    self.boxes[-1].draggable = True
                    return f"<Box {self.boxes[-1].id} Switch/Drag Enabled>"
                return "<Switch Enabled>"

            else:
                raise RuntimeErrorJps(f"Unsupported action '{action}' for module 'box'", node.line, node.column)

        elif module == "game":
            if action == "size":
                if len(args) >= 2:
                    self.window_width = int(args[0])
                    self.window_height = int(args[1])
                elif len(args) == 1:
                    self.window_width = int(args[0])
                    self.window_height = int(args[0])
                return (self.window_width, self.window_height)

            elif action == "run":
                self.is_game_mode = True
                return "<Game Engine Active>"

            else:
                raise RuntimeErrorJps(f"Unsupported action '{action}' for module 'game'", node.line, node.column)

        else:
            raise RuntimeErrorJps(f"Unsupported module '{module}'", node.line, node.column)

    def _start_pygame_loop(self):
        # Try importing Pygame for rendering
        try:
            import pygame
        except ImportError:
            self.print_output("[Warning] Pygame not available. Skipping GUI rendering loop.\n")
            return

        # Check if headless / no display environment
        if not os.environ.get("DISPLAY") and sys.platform.startswith("linux"):
            os.environ["SDL_VIDEODRIVER"] = "dummy"

        try:
            pygame.init()
            screen = pygame.display.set_mode((self.window_width, self.window_height))
            pygame.display.set_caption(f"Jps Script Engine - {'Game Mode' if self.is_game_mode else 'Standard Mode'}")
            clock = pygame.time.Clock()

            running = True
            frame_count = 0

            # If headless dummy driver, run a couple frames then exit
            is_headless = os.environ.get("SDL_VIDEODRIVER") == "dummy"

            while running:
                dt = clock.tick(60) / 1000.0

                for event in pygame.event.get():
                    if event.type == pygame.QUIT:
                        running = False

                    elif event.type == pygame.MOUSEBUTTONDOWN:
                        if event.button == 1:  # Left click
                            mx, my = event.pos
                            for box in reversed(self.boxes):
                                if box.draggable:
                                    rect = pygame.Rect(box.x, box.y, box.width, box.height)
                                    if rect.collidepoint(mx, my):
                                        box.is_dragging = True
                                        box.drag_offset_x = box.x - mx
                                        box.drag_offset_y = box.y - my
                                        break

                    elif event.type == pygame.MOUSEBUTTONUP:
                        if event.button == 1:
                            for box in self.boxes:
                                box.is_dragging = False

                    elif event.type == pygame.MOUSEMOTION:
                        mx, my = event.pos
                        for box in self.boxes:
                            if box.is_dragging:
                                box.x = mx + box.drag_offset_x
                                box.y = my + box.drag_offset_y

                # Update physics/movement
                for box in self.boxes:
                    if box.is_moving and not box.is_dragging:
                        box.x += box.vx
                        box.y += box.vy

                        # Bounce off screen edges
                        if box.x <= 0 or box.x + box.width >= self.window_width:
                            box.vx *= -1
                        if box.y <= 0 or box.y + box.height >= self.window_height:
                            box.vy *= -1

                # Drawing
                if self.is_game_mode:
                    screen.fill((15, 23, 42))  # Dark Slate Blue Game Background
                else:
                    screen.fill((30, 30, 30))  # VS Code Dark Canvas Background

                # Render boxes
                for i, box in enumerate(self.boxes):
                    if self.is_game_mode:
                        color = (0, 240, 255) if not box.is_dragging else (255, 200, 0)
                        border_color = (255, 255, 255)
                    else:
                        color = (86, 156, 214) if not box.is_dragging else (220, 220, 170)
                        border_color = (200, 200, 200)

                    rect = pygame.Rect(box.x, box.y, box.width, box.height)
                    pygame.draw.rect(screen, color, rect, border_radius=8 if self.is_game_mode else 0)
                    pygame.draw.rect(screen, border_color, rect, width=2, border_radius=8 if self.is_game_mode else 0)

                pygame.display.flip()

                if is_headless:
                    frame_count += 1
                    if frame_count > 10:
                        running = False

            pygame.quit()
        except Exception as e:
            self.print_output(f"[Engine Warning] Pygame display loop ended: {e}\n")
