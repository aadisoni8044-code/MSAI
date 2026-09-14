"""
OpenMS Interpreter Engine
"""

import ast
import re
import operator as _op
from openms.runtime.errors import OpenMSError
from openms.runtime.builtins import OMSBuiltins

_BIN_OPS = {
    ast.Add: _op.add,
    ast.Sub: _op.sub,
    ast.Mult: _op.mul,
    ast.Div: _op.truediv,
    ast.FloorDiv: _op.floordiv,
    ast.Mod: _op.mod,
    ast.Pow: _op.pow,
}

_CMP_OPS = {
    ast.Eq: _op.eq,
    ast.NotEq: _op.ne,
    ast.Lt: _op.lt,
    ast.LtE: _op.le,
    ast.Gt: _op.gt,
    ast.GtE: _op.ge,
}

_IF_HEADER_RE = re.compile(r'^if\s*\((?P<cond>.*)\)\s*:$')
_FUNC_HEADER_RE = re.compile(r'^function\s+(?P<name>[A-Za-z_]\w*)\s*\((?P<params>.*)\)\s*:$')
_ASSIGN_RE = re.compile(r'^([A-Za-z_]\w*)\s*=(?!=)\s*(.+)$')


class OpenMSInterpreter:
    """
    Executes OpenMS source code.
    Tokenizes expressions safely using standard AST nodes,
    parses indentation-based blocks for functions and conditionals.
    """

    def __init__(self, root=None, terminal_write=None):
        self.root = root
        self.terminal_write = terminal_write or (lambda msg: None)
        self.variables = {}
        self.functions = {}
        self.builtins_handler = OMSBuiltins(self.root, self.terminal_write)
        self.builtins = self.builtins_handler.get_builtins_map()

    def run(self, code):
        self.variables = {}
        self.functions = {}
        lines = code.replace("\r\n", "\n").replace("\r", "\n").split("\n")
        try:
            self.exec_block(lines, 0, len(lines), None)
        except OpenMSError as e:
            self.terminal_write(f"[OpenMS Error] {e}")
        except Exception as e:
            self.terminal_write(f"[Fatal Error] {type(e).__name__}: {e}")

    @staticmethod
    def get_indent(line):
        return len(line) - len(line.lstrip(" "))

    def collect_block(self, lines, start, end, parent_indent):
        block = []
        i = start
        while i < end:
            line = lines[i]
            if line.strip() == "":
                block.append(line)
                i += 1
                continue
            if self.get_indent(line) <= parent_indent:
                break
            block.append(line)
            i += 1
        return block, i

    def exec_block(self, lines, start, end, parent_scope=None):
        i = start
        while i < end:
            raw_line = lines[i]
            line = raw_line.strip()

            if not line or line.startswith("#") or line.startswith("//"):
                i += 1
                continue

            # Check if line is a function definition
            m_func = _FUNC_HEADER_RE.match(line)
            if m_func:
                name = m_func.group("name")
                params_str = m_func.group("params").strip()
                params = [p.strip() for p in params_str.split(",") if p.strip()]
                indent = self.get_indent(raw_line)
                block, next_i = self.collect_block(lines, i + 1, end, indent)
                self.functions[name] = {"params": params, "block": block}
                i = next_i
                continue

            # Check if line is an if statement
            m_if = _IF_HEADER_RE.match(line)
            if m_if:
                cond_src = m_if.group("cond")
                indent = self.get_indent(raw_line)
                block, next_i = self.collect_block(lines, i + 1, end, indent)
                val = self.eval_expr(cond_src, parent_scope)
                if bool(val):
                    self.exec_block(block, 0, len(block), parent_scope)
                i = next_i
                continue

            # Check if assignment statement
            m_ass = _ASSIGN_RE.match(line)
            if m_ass:
                var = m_ass.group(1).strip()
                expr = m_ass.group(2).strip()
                val = self.eval_expr(expr, parent_scope)
                if parent_scope is not None:
                    parent_scope[var] = val
                else:
                    self.variables[var] = val
                i += 1
                continue

            # Otherwise, evaluate line as expression / function call
            self.eval_expr(line, parent_scope)
            i += 1

    def eval_expr(self, src, scope=None):
        try:
            tree = ast.parse(src, mode="eval")
        except SyntaxError as e:
            raise OpenMSError(f"Syntax error in expression '{src}': {e}") from e

        return self._eval_node(tree.body, scope)

    def _eval_node(self, node, scope=None):
        # Numeric / String / Boolean / Constant literals
        if isinstance(node, ast.Constant):
            return node.value

        # Identifiers / Variables
        elif isinstance(node, ast.Name):
            var_name = node.id
            if var_name in ("True", "true"):
                return True
            if var_name in ("False", "false"):
                return False
            if var_name in ("None", "null"):
                return None
            if scope is not None and var_name in scope:
                return scope[var_name]
            if var_name in self.variables:
                return self.variables[var_name]
            if var_name in self.builtins:
                return self.builtins[var_name]
            raise OpenMSError(f"Undefined variable or symbol '{var_name}'")

        # Binary math ops (+, -, *, /, %, **)
        elif isinstance(node, ast.BinOp):
            left = self._eval_node(node.left, scope)
            right = self._eval_node(node.right, scope)
            op_type = type(node.op)
            if op_type in _BIN_OPS:
                return _BIN_OPS[op_type](left, right)
            raise OpenMSError(f"Unsupported binary operator: {op_type.__name__}")

        # Unary math ops (+, -)
        elif isinstance(node, ast.UnaryOp):
            val = self._eval_node(node.operand, scope)
            if isinstance(node.op, ast.USub):
                return -val
            if isinstance(node.op, ast.UAdd):
                return +val
            if isinstance(node.op, ast.Not):
                return not val
            raise OpenMSError(f"Unsupported unary operator: {type(node.op).__name__}")

        # Comparisons (==, !=, <, <=, >, >=)
        elif isinstance(node, ast.Compare):
            left = self._eval_node(node.left, scope)
            for op, comparator in zip(node.ops, node.comparators):
                right = self._eval_node(comparator, scope)
                op_type = type(op)
                if op_type not in _CMP_OPS or not _CMP_OPS[op_type](left, right):
                    return False
                left = right
            return True

        # Function Calls
        elif isinstance(node, ast.Call):
            if isinstance(node.func, ast.Name) and node.func.id in self.functions:
                fdef = self.functions[node.func.id]
                params = fdef["params"]
                block = fdef["block"]
                args = [self._eval_node(a, scope) for a in node.args]

                if len(args) != len(params):
                    raise OpenMSError(
                        f"Function '{node.func.id}' expects {len(params)} args, got {len(args)}"
                    )

                local_scope = dict(zip(params, args))
                self.exec_block(block, 0, len(block), local_scope)
                return local_scope.get("return_val", None)

            func_obj = self._eval_node(node.func, scope)
            args = [self._eval_node(a, scope) for a in node.args]

            if callable(func_obj):
                return func_obj(*args)

            raise OpenMSError(f"'{node.func}' is not callable")

        raise OpenMSError(f"Unsupported AST node expression type: {type(node).__name__}")
