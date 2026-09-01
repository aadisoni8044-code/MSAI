"""
AST Expression Evaluator for OpenMS Interpreter
"""

import ast
import operator as _op
from openms.models import OpenMSError

SAFE_OPS = {
    ast.Add: _op.add,
    ast.Sub: _op.sub,
    ast.Mult: _op.mul,
    ast.Div: _op.truediv,
    ast.FloorDiv: _op.floordiv,
    ast.Mod: _op.mod,
    ast.Pow: _op.pow,
    ast.USub: _op.neg,
    ast.UAdd: _op.pos,
    ast.Not: _op.not_,
    ast.Eq: _op.eq,
    ast.NotEq: _op.ne,
    ast.Lt: _op.lt,
    ast.LtE: _op.le,
    ast.Gt: _op.gt,
    ast.GtE: _op.ge,
}


def eval_expr(expr_str, local_vars, call_func_cb):
    """Parses and evaluates a Python-like expression string using local_vars."""
    expr_str = expr_str.strip()
    if not expr_str:
        return None
    try:
        parsed = ast.parse(expr_str, mode="eval")
    except Exception as e:
        raise OpenMSError(f"Syntax error in expression '{expr_str}': {e}")
    return _eval_node(parsed.body, local_vars, call_func_cb)


def _eval_node(node, local_vars, call_func_cb):
    """Recursively evaluates an AST node."""
    if isinstance(node, ast.Constant):
        return node.value

    if isinstance(node, ast.Name):
        if node.id in local_vars:
            return local_vars[node.id]
        if node.id in ("True", "true"):
            return True
        if node.id in ("False", "false"):
            return False
        if node.id in ("None", "none", "null"):
            return None
        raise OpenMSError(f"Undefined variable or symbol '{node.id}'")

    if isinstance(node, ast.BinOp):
        left = _eval_node(node.left, local_vars, call_func_cb)
        right = _eval_node(node.right, local_vars, call_func_cb)
        op_type = type(node.op)
        if op_type in SAFE_OPS:
            return SAFE_OPS[op_type](left, right)
        raise OpenMSError(f"Unsupported binary operator: {op_type.__name__}")

    if isinstance(node, ast.UnaryOp):
        operand = _eval_node(node.operand, local_vars, call_func_cb)
        op_type = type(node.op)
        if op_type in SAFE_OPS:
            return SAFE_OPS[op_type](operand)
        raise OpenMSError(f"Unsupported unary operator: {op_type.__name__}")

    if isinstance(node, ast.Compare):
        left = _eval_node(node.left, local_vars, call_func_cb)
        for op, comparator in zip(node.ops, node.comparators):
            right = _eval_node(comparator, local_vars, call_func_cb)
            op_type = type(op)
            if op_type not in SAFE_OPS:
                raise OpenMSError(f"Unsupported comparison operator: {op_type.__name__}")
            if not SAFE_OPS[op_type](left, right):
                return False
            left = right
        return True

    if isinstance(node, ast.Call):
        if not isinstance(node.func, ast.Name):
            raise OpenMSError("Only direct function calls are supported (e.g. box(100)).")
        fname = node.func.id
        args = [_eval_node(arg, local_vars, call_func_cb) for arg in node.args]
        kwargs = {}
        for kw in node.keywords:
            kwargs[kw.arg] = _eval_node(kw.value, local_vars, call_func_cb)
        return call_func_cb(fname, args, kwargs, local_vars)

    if isinstance(node, ast.List):
        return [_eval_node(elt, local_vars, call_func_cb) for elt in node.elts]

    if isinstance(node, ast.Tuple):
        return tuple(_eval_node(elt, local_vars, call_func_cb) for elt in node.elts)

    raise OpenMSError(f"Unsupported syntax construct: {type(node).__name__}")
