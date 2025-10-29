import re
from dataclasses import dataclass
from typing import List, Optional, Tuple

# ============ LEXER ============
@dataclass
class Token:
    type: str
    value: str
    line: int

class Lexer:
    def __init__(self, source: str):
        self.source = source
        self.pos = 0
        self.line = 1
        self.tokens = []
        
    def tokenize(self) -> List[Token]:
        token_patterns = [
            ('NUMBER', r'\d+(\.\d+)?'),
            ('ID', r'[a-zA-Z_][a-zA-Z0-9_]*'),
            ('ASSIGN', r'='),
            ('PLUS', r'\+'),
            ('MINUS', r'-'),
            ('MULTIPLY', r'\*'),
            ('DIVIDE', r'/'),
            ('LPAREN', r'\('),
            ('RPAREN', r'\)'),
            ('SEMICOLON', r';'),
            ('COMMA', r','),
            ('DOUBLE_QUOTE', r'"'),
            ('EXCLAMATION', r'!'),
            ('LT', r'<'),
            ('GT', r'>'),
            ('LE', r'<='),
            ('GE', r'>='),
            ('EQ', r'=='),
            ('NE', r'!='),
            ('LBRACE', r'\{'),
            ('RBRACE', r'\}'),
            ('NEWLINE', r'\n'),
            ('WHITESPACE', r'[ \t]+'),
        ]
        
        keywords = {'if', 'else', 'while', 'int', 'float'}
        
        while self.pos < len(self.source):
            matched = False
            for token_type, pattern in token_patterns:
                regex = re.compile(pattern)
                match = regex.match(self.source, self.pos)
                if match:
                    value = match.group(0)
                    if token_type == 'NEWLINE':
                        self.line += 1
                    elif token_type == 'WHITESPACE':
                        pass
                    elif token_type == 'ID' and value in keywords:
                        self.tokens.append(Token(value.upper(), value, self.line))
                    elif token_type != 'WHITESPACE':
                        self.tokens.append(Token(token_type, value, self.line))
                    self.pos = match.end()
                    matched = True
                    break
            
            if not matched:
                raise SyntaxError(f"Illegal character '{self.source[self.pos]}' at line {self.line}")
        
        self.tokens.append(Token('EOF', '', self.line))
        return self.tokens

# ============ PARSER & TAC GENERATOR ============
class TACGenerator:
    def __init__(self, tokens: List[Token]):
        self.tokens = tokens
        self.pos = 0
        self.current = self.tokens[0]
        self.temp_count = 0
        self.label_count = 0
        self.tac = []
        
    def new_temp(self) -> str:
        temp = f"t{self.temp_count}"
        self.temp_count += 1
        return temp
    
    def new_label(self) -> str:
        label = f"L{self.label_count}"
        self.label_count += 1
        return label
    
    def emit(self, op: str, arg1: str = '', arg2: str = '', result: str = ''):
        self.tac.append((op, arg1, arg2, result))
    
    def advance(self):
        self.pos += 1
        if self.pos < len(self.tokens):
            self.current = self.tokens[self.pos]
    
    def expect(self, token_type: str):
        if self.current.type != token_type:
            raise SyntaxError(f"Expected {token_type}, got {self.current.type} at line {self.current.line}")
        self.advance()
    
    def parse(self) -> List[Tuple]:
        self.program()
        return self.tac
    
    def program(self):
        while self.current.type != 'EOF':
            self.statement()
    
    def statement(self):
        if self.current.type == 'IF':
            self.if_statement()
        elif self.current.type == 'WHILE':
            self.while_statement()
        elif self.current.type == 'ID':
            self.assignment()
        elif self.current.type in ['INT', 'FLOAT']:
            self.declaration()
        elif self.current.type == 'LBRACE':
            self.block()
        else:
            self.advance()
    
    def block(self):
        self.expect('LBRACE')
        while self.current.type != 'RBRACE' and self.current.type != 'EOF':
            self.statement()
        self.expect('RBRACE')
    
    def declaration(self):
        self.advance()  # skip type
        var_name = self.current.value
        self.expect('ID')
        if self.current.type == 'ASSIGN':
            self.advance()
            expr_result = self.expression()
            self.emit('=', expr_result, '', var_name)
        self.expect('SEMICOLON')
    
    def assignment(self):
        var_name = self.current.value
        self.expect('ID')
        self.expect('ASSIGN')
        expr_result = self.expression()
        self.emit('=', expr_result, '', var_name)
        self.expect('SEMICOLON')
    
    def if_statement(self):
        self.expect('IF')
        self.expect('LPAREN')
        cond_result = self.condition()
        self.expect('RPAREN')
        
        label_else = self.new_label()
        label_end = self.new_label()
        
        self.emit('ifFalse', cond_result, '', label_else)
        self.statement()
        
        if self.current.type == 'ELSE':
            self.emit('goto', '', '', label_end)
            self.emit('label', '', '', label_else)
            self.advance()
            self.statement()
            self.emit('label', '', '', label_end)
        else:
            self.emit('label', '', '', label_else)
    
    def while_statement(self):
        self.expect('WHILE')
        self.expect('LPAREN')
        
        label_start = self.new_label()
        label_end = self.new_label()
        
        self.emit('label', '', '', label_start)
        cond_result = self.condition()
        self.expect('RPAREN')
        
        self.emit('ifFalse', cond_result, '', label_end)
        self.statement()
        self.emit('goto', '', '', label_start)
        self.emit('label', '', '', label_end)
    
    def condition(self) -> str:
        left = self.expression()
        
        if self.current.type in ['LT', 'GT', 'LE', 'GE', 'EQ', 'NE']:
            op = self.current.value
            self.advance()
            right = self.expression()
            temp = self.new_temp()
            self.emit(op, left, right, temp)
            return temp
        
        return left
    
    def expression(self) -> str:
        result = self.term()
        
        while self.current.type in ['PLUS', 'MINUS']:
            op = self.current.value
            self.advance()
            right = self.term()
            temp = self.new_temp()
            self.emit(op, result, right, temp)
            result = temp
        
        return result
    
    def term(self) -> str:
        result = self.factor()
        
        while self.current.type in ['MULTIPLY', 'DIVIDE']:
            op = self.current.value
            self.advance()
            right = self.factor()
            temp = self.new_temp()
            self.emit(op, result, right, temp)
            result = temp
        
        return result
    
    def factor(self) -> str:
        if self.current.type == 'NUMBER':
            value = self.current.value
            self.advance()
            return value
        elif self.current.type == 'ID':
            value = self.current.value
            self.advance()
            return value
        elif self.current.type == 'LPAREN':
            self.advance()
            result = self.expression()
            self.expect('RPAREN')
            return result
        else:
            raise SyntaxError(f"Unexpected token {self.current.type} at line {self.current.line}")

# ============ MAIN FUNCTION ============
def compile_to_tac(source_file: str):
    """Read source file and generate Three-Address Code"""
    try:
        with open(source_file, 'r') as f:
            source_code = f.read()
        
        print(f"Source Code from '{source_file}':")
        print("=" * 50)
        print(source_code)
        print("=" * 50)
        
        # Lexical Analysis
        lexer = Lexer(source_code)
        tokens = lexer.tokenize()
        
        print("\nTokens:")
        for token in tokens[:-1]:  # exclude EOF
            print(f"  {token.type}: {token.value}")
        
        # Parse and Generate TAC
        generator = TACGenerator(tokens)
        tac = generator.parse()
        
        print("\n" + "=" * 50)
        print("THREE-ADDRESS CODE (TAC):")
        print("=" * 50)
        for i, (op, arg1, arg2, result) in enumerate(tac):
            if op == 'label':
                print(f"{result}:")
            elif op == 'goto':
                print(f"  goto {result}")
            elif op == 'ifFalse':
                print(f"  if {arg1} == 0 goto {result}")
            elif op == '=':
                print(f"  {result} = {arg1}")
            else:
                print(f"  {result} = {arg1} {op} {arg2}")
        
        return tac
        
    except FileNotFoundError:
        print(f"Error: File '{source_file}' not found!")
    except Exception as e:
        print(f"Error: {e}")

# ============ USAGE ============
if __name__ == "__main__":
    import sys
    
    if len(sys.argv) < 2:
        print("Usage: python tac_compiler.py <source_file>")
        print("Example: python tac_compiler.py source.txt")
        sys.exit(1)
    
    source_file = sys.argv[1]
    compile_to_tac(source_file)