"""
Main Interpreter Engine for the OpenMS Language
"""

import re
from openms.models import OpenMSError
from openms.interpreter.evaluator import eval_expr
from openms.interpreter.renderer import OpenMSRenderer
from openms.interpreter.builtins_1d import Builtins1D
from openms.interpreter.builtins_2d3d import Builtins2D3D


class OpenMSInterpreter:
    """Tokenizer -> Parser -> Executor interpreter engine for OpenMS script execution."""

    def __init__(self, root, terminal_write):
        self.root = root
        self.terminal_write = terminal_write
        self.variables = {}
        self.functions = {}
        self.renderer = OpenMSRenderer(root, terminal_write)
        self.b1d = Builtins1D(root, terminal_write)
        self.b2d3d = Builtins2D3D(self.renderer)

    def run(self, code):
        """Executes a block of OpenMS code string."""
        self.variables = {}
        self.functions = {}

        raw_lines = code.splitlines()
        clean_lines = []
        for line in raw_lines:
            # Strip comments that are not inside string literals
            no_comment = self._strip_comment(line)
            clean_lines.append(no_comment)

        self.exec_block(clean_lines, 0, len(clean_lines), self.variables)

    @staticmethod
    def _strip_comment(line):
        in_quote = None
        for i, char in enumerate(line):
            if char in ("'", '"'):
                if in_quote is None:
                    in_quote = char
                elif in_quote == char:
                    in_quote = None
            elif char == "#" and in_quote is None:
                return line[:i]
        return line

    @staticmethod
    def get_indent(line):
        return len(line) - len(line.lstrip(" "))

    def collect_block(self, lines, start, end, parent_indent):
        block_lines = []
        idx = start
        while idx < end:
            line = lines[idx]
            if not line.strip():
                idx += 1
                continue
            indent = self.get_indent(line)
            if indent <= parent_indent:
                break
            block_lines.append((idx, line))
            idx += 1
        return block_lines, idx

    def exec_block(self, lines, start, end, local_vars):
        i = start
        while i < end:
            line = lines[i]
            stripped = line.strip()

            if not stripped:
                i += 1
                continue

            current_indent = self.get_indent(line)

            # Block construct: function def
            fn_match = re.match(r"^function\s+([A-Za-z_]\w*)\s*\((.*?)\)\s*:$", stripped)
            if fn_match:
                fname = fn_match.group(1)
                params_str = fn_match.group(2)
                params = [p.strip() for p in params_str.split(",") if p.strip()]
                block, next_i = self.collect_block(lines, i + 1, end, current_indent)
                self.functions[fname] = {"params": params, "lines": [b[1] for b in block]}
                self.terminal_write(f"[engine] Defined function '{fname}({', '.join(params)})'")
                i = next_i
                continue

            # Block construct: if statement
            if_match = re.match(r"^if\s*\((.*?)\)\s*:$", stripped) or re.match(r"^if\s+(.*?):$", stripped)
            if if_match:
                cond_str = if_match.group(1)
                cond_val = self.eval_expr(cond_str, local_vars)
                block, next_i = self.collect_block(lines, i + 1, end, current_indent)
                if cond_val:
                    sub_lines = [b[1] for b in block]
                    self.exec_block(sub_lines, 0, len(sub_lines), local_vars)
                i = next_i
                continue

            # Simple statement
            self.exec_statement(stripped, local_vars)
            i += 1

    def exec_statement(self, stripped, local_vars):
        # Match assignment like: var_name = expr (and not ==, !=, <=, >=)
        assign_match = re.match(r"^([A-Za-z_]\w*)\s*=(?!=)\s*(.*)$", stripped)
        if assign_match and not stripped.startswith("if"):
            var_name = assign_match.group(1).strip()
            expr_str = assign_match.group(2).strip()

            val = self.eval_expr(expr_str, local_vars)
            local_vars[var_name] = val
            self.terminal_write(f"[assign] {var_name} = {val!r}")
            return val
        else:
            return self.eval_expr(stripped, local_vars)

    def eval_expr(self, expr_str, local_vars=None):
        if local_vars is None:
            local_vars = self.variables
        return eval_expr(expr_str, local_vars, self.call_function)

    def call_function(self, fname, args, kwargs, local_vars):
        # 1D built-in functions
        if fname == "machine":
            return self.b1d.b_machine(*args)
        if fname == "input":
            return self.b1d.b_input(*args, **kwargs)
        if fname == "open":
            return self.b1d.b_open(*args, **kwargs)
        if fname == "function":
            return self.b1d.b_function(*args, **kwargs)
        if fname == "if":
            return self.b1d.b_if(*args, **kwargs)

        # 2D/3D built-in functions
        if fname == "box":
            return self.b2d3d.b_box(*args, **kwargs)
        if fname == "bol":
            return self.b2d3d.b_bol(*args, **kwargs)
        if fname == "size":
            return self.b2d3d.b_size(*args, **kwargs)
        if fname == "photo":
            return self.b2d3d.b_photo(*args, **kwargs)
        if fname == "time":
            return self.b2d3d.b_time(*args, **kwargs)
        if fname == "house":
            return self.b2d3d.b_house(*args, **kwargs)
        if fname == "game":
            return self.b2d3d.b_game(*args, **kwargs)
        if fname == "boody_2D":
            return self.b2d3d.b_boody_2D(*args, **kwargs)
        if fname == "boody_3D":
            return self.b2d3d.b_boody_3D(*args, **kwargs)

        # Custom defined function in user script
        if fname in self.functions:
            fn_def = self.functions[fname]
            params = fn_def["params"]
            fn_lines = fn_def["lines"]

            if len(args) != len(params):
                raise OpenMSError(
                    f"Function '{fname}' expected {len(params)} arguments, got {len(args)}"
                )

            fn_vars = dict(local_vars)
            for p, a in zip(params, args):
                fn_vars[p] = a

            self.exec_block(fn_lines, 0, len(fn_lines), fn_vars)
            return None

        raise OpenMSError(f"Unknown function '{fname}()'")
