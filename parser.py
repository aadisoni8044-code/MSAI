"""
Parser (AST Builder) for Jps script.
Constructs an Abstract Syntax Tree (AST) from a sequence of tokens.
"""

from typing import List, Any
from lexer import Token, TokenType

class ASTNode:
    pass

class ProgramNode(ASTNode):
    def __init__(self, statements: List[ASTNode]):
        self.statements = statements

    def __repr__(self):
        return f"ProgramNode({self.statements})"

class ImportNode(ASTNode):
    def __init__(self, module_name: str, line: int):
        self.module_name = module_name
        self.line = line

    def __repr__(self):
        return f"ImportNode('{self.module_name}', line={self.line})"

class AssignmentNode(ASTNode):
    def __init__(self, var_name: str, expr: ASTNode, line: int):
        self.var_name = var_name
        self.expr = expr
        self.line = line

    def __repr__(self):
        return f"AssignmentNode('{self.var_name}' = {self.expr}, line={self.line})"

class FunctionCallNode(ASTNode):
    def __init__(self, action: str, module: str, arguments: List[ASTNode], line: int):
        self.action = action
        self.module = module
        self.arguments = arguments
        self.line = line

    def __repr__(self):
        return f"FunctionCallNode('{self.action}.{self.module}', args={self.arguments}, line={self.line})"

class PrintNode(ASTNode):
    def __init__(self, arguments: List[ASTNode], line: int):
        self.arguments = arguments
        self.line = line

    def __repr__(self):
        return f"PrintNode({self.arguments}, line={self.line})"

class LiteralNode(ASTNode):
    def __init__(self, value: Any, line: int):
        self.value = value
        self.line = line

    def __repr__(self):
        return f"LiteralNode({repr(self.value)}, line={self.line})"

class IdentifierNode(ASTNode):
    def __init__(self, name: str, line: int):
        self.name = name
        self.line = line

    def __repr__(self):
        return f"IdentifierNode('{self.name}', line={self.line})"

class ParserError(Exception):
    def __init__(self, message: str, line: int, column: int):
        super().__init__(f"ParserError at line {line}, column {column}: {message}")
        self.message = message
        self.line = line
        self.column = column

class Parser:
    def __init__(self, tokens: List[Token]):
        self.tokens = tokens
        self.current = 0

    def peek(self, offset: int = 0) -> Token:
        pos = self.current + offset
        if pos >= len(self.tokens):
            return self.tokens[-1] # Return EOF token
        return self.tokens[pos]

    def match(self, *types: TokenType) -> bool:
        if self.peek().type in types:
            self.advance()
            return True
        return False

    def check(self, type_: TokenType) -> bool:
        return self.peek().type == type_

    def advance(self) -> Token:
        token = self.peek()
        if self.current < len(self.tokens) - 1:
            self.current += 1
        return token

    def consume(self, type_: TokenType, message: str) -> Token:
        if self.check(type_):
            return self.advance()
        token = self.peek()
        raise ParserError(message, token.line, token.column)

    def parse(self) -> ProgramNode:
        statements = []
        while not self.check(TokenType.EOF):
            if self.match(TokenType.NEWLINE):
                continue
            stmt = self.statement()
            if stmt:
                statements.append(stmt)
        return ProgramNode(statements)

    def statement(self) -> ASTNode:
        token = self.peek()

        if self.check(TokenType.IMPORT):
            return self.import_statement()

        if self.check(TokenType.PRINT):
            return self.print_statement()

        if self.check(TokenType.IDENTIFIER):
            # Check if assignment or standalone call
            if self.peek(1).type == TokenType.ASSIGN:
                return self.assignment_statement()
            elif self.peek(1).type == TokenType.DOT:
                return self.function_call_statement()
            else:
                raise ParserError(f"Unexpected identifier '{token.value}'. Expected assignment or function call.", token.line, token.column)

        raise ParserError(f"Unexpected token '{token.value}'", token.line, token.column)

    def import_statement(self) -> ImportNode:
        import_tok = self.consume(TokenType.IMPORT, "Expected 'import'")
        self.consume(TokenType.DOT, "Expected '.' after 'import'")
        mod_tok = self.consume(TokenType.IDENTIFIER, "Expected module name after 'import.'")
        return ImportNode(mod_tok.value, import_tok.line)

    def print_statement(self) -> PrintNode:
        print_tok = self.consume(TokenType.PRINT, "Expected 'print'")
        args = []
        if self.match(TokenType.LPAREN):
            if not self.check(TokenType.RPAREN):
                args.append(self.expression())
                while self.match(TokenType.COMMA):
                    args.append(self.expression())
            self.consume(TokenType.RPAREN, "Expected ')' after print arguments")
        return PrintNode(args, print_tok.line)

    def assignment_statement(self) -> AssignmentNode:
        var_tok = self.consume(TokenType.IDENTIFIER, "Expected variable name")
        self.consume(TokenType.ASSIGN, "Expected '='")

        expr = self.expression()
        return AssignmentNode(var_tok.value, expr, var_tok.line)

    def function_call_statement(self) -> FunctionCallNode:
        action_tok = self.consume(TokenType.IDENTIFIER, "Expected action name")
        self.consume(TokenType.DOT, "Expected '.' after action name")
        mod_tok = self.consume(TokenType.IDENTIFIER, "Expected module name after '.'")

        args = []
        if self.match(TokenType.LPAREN):
            if not self.check(TokenType.RPAREN):
                args.append(self.expression())
                while self.match(TokenType.COMMA):
                    args.append(self.expression())
            self.consume(TokenType.RPAREN, "Expected ')' after function arguments")

        return FunctionCallNode(action_tok.value, mod_tok.value, args, action_tok.line)

    def expression(self) -> ASTNode:
        token = self.peek()

        if self.check(TokenType.NUMBER) or self.check(TokenType.STRING):
            val_tok = self.advance()
            return LiteralNode(val_tok.value, val_tok.line)

        if self.check(TokenType.IDENTIFIER):
            if self.peek(1).type == TokenType.DOT:
                return self.function_call_statement()
            var_tok = self.advance()
            return IdentifierNode(var_tok.value, var_tok.line)

        raise ParserError(f"Invalid expression starting with token '{token.value}'", token.line, token.column)
