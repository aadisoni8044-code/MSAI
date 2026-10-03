from typing import List, Any, Optional
from lexer import Token, TokenType

class ASTNode:
    def __init__(self, line: int, column: int):
        self.line = line
        self.column = column

class ProgramNode(ASTNode):
    def __init__(self, statements: List[ASTNode], line: int = 1, column: int = 1):
        super().__init__(line, column)
        self.statements = statements

    def __repr__(self) -> str:
        return f"ProgramNode({self.statements})"

class ImportNode(ASTNode):
    def __init__(self, module_name: str, line: int, column: int):
        super().__init__(line, column)
        self.module_name = module_name

    def __repr__(self) -> str:
        return f"ImportNode('{self.module_name}')"

class LiteralNode(ASTNode):
    def __init__(self, value: Any, line: int, column: int):
        super().__init__(line, column)
        self.value = value

    def __repr__(self) -> str:
        return f"LiteralNode({repr(self.value)})"

class IdentifierNode(ASTNode):
    def __init__(self, name: str, line: int, column: int):
        super().__init__(line, column)
        self.name = name

    def __repr__(self) -> str:
        return f"IdentifierNode('{self.name}')"

class CallNode(ASTNode):
    def __init__(self, action: str, module: str, args: List[ASTNode], line: int, column: int):
        super().__init__(line, column)
        self.action = action
        self.module = module
        self.args = args

    def __repr__(self) -> str:
        return f"CallNode('{self.action}.{self.module}', args={self.args})"

class AssignmentNode(ASTNode):
    def __init__(self, var_name: str, value: ASTNode, line: int, column: int):
        super().__init__(line, column)
        self.var_name = var_name
        self.value = value

    def __repr__(self) -> str:
        return f"AssignmentNode('{self.var_name}' = {self.value})"

class PrintNode(ASTNode):
    def __init__(self, args: List[ASTNode], line: int, column: int):
        super().__init__(line, column)
        self.args = args

    def __repr__(self) -> str:
        return f"PrintNode(args={self.args})"


class ParserError(Exception):
    def __init__(self, message: str, line: int, column: int):
        self.message = message
        self.line = line
        self.column = column
        super().__init__(f"Parser Error [Line {line}, Col {column}]: {message}")


class Parser:
    def __init__(self, tokens: List[Token]):
        self.tokens = tokens
        self.pos = 0

    def _peek(self, offset: int = 0) -> Token:
        if self.pos + offset < len(self.tokens):
            return self.tokens[self.pos + offset]
        return self.tokens[-1]  # EOF token

    def _advance(self) -> Token:
        token = self._peek()
        if token.type != TokenType.EOF:
            self.pos += 1
        return token

    def _match(self, *token_types: TokenType) -> bool:
        if self._peek().type in token_types:
            self._advance()
            return True
        return False

    def _expect(self, token_type: TokenType, error_msg: str) -> Token:
        token = self._peek()
        if token.type == token_type:
            return self._advance()
        raise ParserError(error_msg, token.line, token.column)

    def parse(self) -> ProgramNode:
        statements: List[ASTNode] = []
        while self._peek().type != TokenType.EOF:
            # Skip empty newlines
            if self._peek().type == TokenType.NEWLINE:
                self._advance()
                continue

            stmt = self._parse_statement()
            if stmt:
                statements.append(stmt)

            # Statements may be separated by newlines or EOF
            if self._peek().type == TokenType.NEWLINE:
                self._advance()
            elif self._peek().type != TokenType.EOF:
                # If next token is not newline or EOF or start of next statement, check syntax
                pass

        return ProgramNode(statements, line=1, column=1)

    def _parse_statement(self) -> ASTNode:
        token = self._peek()

        if token.type == TokenType.IMPORT:
            return self._parse_import()

        if token.type == TokenType.PRINT:
            return self._parse_print()

        if token.type == TokenType.IDENTIFIER:
            # Check if assignment `<var> = ...` vs standalone call `<action>.<module>(...)`
            if self._peek(1).type == TokenType.EQUALS:
                return self._parse_assignment()
            elif self._peek(1).type == TokenType.DOT:
                return self._parse_call_expression()

        raise ParserError(f"Unexpected token '{token.value}'", token.line, token.column)

    def _parse_import(self) -> ImportNode:
        import_token = self._expect(TokenType.IMPORT, "Expected 'import'")
        self._expect(TokenType.DOT, "Expected '.' after 'import'")
        module_token = self._expect(TokenType.IDENTIFIER, "Expected module name after 'import.'")
        return ImportNode(module_token.value, import_token.line, import_token.column)

    def _parse_print(self) -> PrintNode:
        print_token = self._expect(TokenType.PRINT, "Expected 'print'")
        args: List[ASTNode] = []

        if self._peek().type == TokenType.LPAREN:
            self._advance()  # consume '('
            if self._peek().type != TokenType.RPAREN:
                args.append(self._parse_expression())
                while self._peek().type == TokenType.COMMA:
                    self._advance()  # consume ','
                    args.append(self._parse_expression())
            self._expect(TokenType.RPAREN, "Expected ')' after print arguments")
        elif self._peek().type not in (TokenType.NEWLINE, TokenType.EOF):
            # Fallback for print without parens if any
            args.append(self._parse_expression())
            while self._peek().type == TokenType.COMMA:
                self._advance()
                args.append(self._parse_expression())

        return PrintNode(args, print_token.line, print_token.column)

    def _parse_assignment(self) -> AssignmentNode:
        var_token = self._expect(TokenType.IDENTIFIER, "Expected variable name")
        self._expect(TokenType.EQUALS, "Expected '=' in assignment")
        expr = self._parse_expression()
        return AssignmentNode(var_token.value, expr, var_token.line, var_token.column)

    def _parse_expression(self) -> ASTNode:
        token = self._peek()

        if token.type == TokenType.NUMBER:
            self._advance()
            return LiteralNode(token.value, token.line, token.column)

        if token.type == TokenType.STRING:
            self._advance()
            return LiteralNode(token.value, token.line, token.column)

        if token.type == TokenType.IDENTIFIER:
            if self._peek(1).type == TokenType.DOT:
                return self._parse_call_expression()
            else:
                self._advance()
                return IdentifierNode(token.value, token.line, token.column)

        raise ParserError(f"Invalid expression '{token.value}'", token.line, token.column)

    def _parse_call_expression(self) -> CallNode:
        action_token = self._expect(TokenType.IDENTIFIER, "Expected action identifier")
        self._expect(TokenType.DOT, "Expected '.' between action and module")
        module_token = self._expect(TokenType.IDENTIFIER, "Expected module identifier")

        args: List[ASTNode] = []
        if self._peek().type == TokenType.LPAREN:
            self._advance()  # consume '('
            if self._peek().type != TokenType.RPAREN:
                args.append(self._parse_expression())
                while self._peek().type == TokenType.COMMA:
                    self._advance()  # consume ','
                    args.append(self._parse_expression())
            self._expect(TokenType.RPAREN, "Expected ')' after arguments")

        return CallNode(action_token.value, module_token.value, args, action_token.line, action_token.column)
