import re
import sys

# -------------------------------
# LEXER
# -------------------------------
tokens = [
    ('NUMBER',   r'\d+'),
    ('ID',       r'[A-Za-z_][A-Za-z0-9_]*'),
    ('ASSIGN',   r'='),
    ('ADD',      r'\+'),
    ('SUB',      r'-'),
    ('MUL',      r'\*'),
    ('DIV',      r'/'),
    ('LE',       r'<='),
    ('GE',       r'>='),
    ('LT',       r'<'),
    ('GT',       r'>'),
    ('EQ',       r'=='),
    ('NE',       r'!='),
    ('LPAREN',   r'\('),
    ('RPAREN',   r'\)'),
    ('SEMICOLON',r';'),
    ('IF',       r'if'),
    ('ELSE',     r'else'),
    ('WS',       r'[ \t\n]+'),
]

def tokenize(code):
    token_spec = '|'.join(f'(?P<{name}>{pattern})' for name, pattern in tokens)
    regex = re.compile(token_spec)
    for match in regex.finditer(code):
        kind = match.lastgroup
        value = match.group()
        if kind != 'WS':
            yield (kind, value)

# -------------------------------
# GLOBALS
# -------------------------------
temp_count = 0
label_count = 0
output = []

def newTemp():
    global temp_count
    t = f"t{temp_count}"
    temp_count += 1
    return t

def newLabel():
    global label_count
    l = f"L{label_count}"
    label_count += 1
    return l

def emit(code):
    output.append(code)

# -------------------------------
# PARSER
# -------------------------------
class Parser:
    def __init__(self, tokens):
        self.tokens = list(tokens)
        self.pos = 0

    def peek(self):
        if self.pos < len(self.tokens):
            return self.tokens[self.pos]
        return ('EOF', '')

    def eat(self, kind):
        if self.peek()[0] == kind:
            val = self.peek()[1]
            self.pos += 1
            return val
        else:
            raise SyntaxError(f"Expected {kind}, got {self.peek()[0]}")

    def parse_program(self):
        while self.peek()[0] != 'EOF':
            self.statement()

    def statement(self):
        if self.peek()[0] == 'ID':
            self.assignment()
        elif self.peek()[0] == 'IF':
            self.if_statement()
        else:
            raise SyntaxError(f"Unexpected token {self.peek()}")

    def assignment(self):
        id_name = self.eat('ID')
        self.eat('ASSIGN')
        expr_val = self.expr()
        self.eat('SEMICOLON')
        emit(f"{id_name} = {expr_val}")

    def if_statement(self):
        self.eat('IF')
        self.eat('LPAREN')
        cond = self.condition()
        self.eat('RPAREN')

        l_true = newLabel()
        l_false = newLabel()
        l_end = newLabel()

        emit(f"if {cond} goto {l_true}")
        emit(f"goto {l_false}")
        emit(f"{l_true}:")

        self.statement()

        if self.peek()[0] == 'ELSE':
            emit(f"goto {l_end}")
            emit(f"{l_false}:")
            self.eat('ELSE')
            self.statement()
            emit(f"{l_end}:")
        else:
            emit(f"{l_false}:")

    def condition(self):
        left = self.expr()
        op = self.peek()[0]
        if op in ('LT', 'GT', 'LE', 'GE', 'EQ', 'NE'):
            self.eat(op)
            right = self.expr()
            return f"{left} {self.op_symbol(op)} {right}"
        else:
            raise SyntaxError("Expected relational operator")

    def op_symbol(self, op):
        return {
            'LT': '<', 'GT': '>', 'LE': '<=', 'GE': '>=',
            'EQ': '==', 'NE': '!='
        }[op]

    def expr(self):
        left = self.term()
        while self.peek()[0] in ('ADD', 'SUB'):
            op = self.peek()[0]
            self.eat(op)
            right = self.term()
            t = newTemp()
            emit(f"{t} = {left} {self.op_symbol_math(op)} {right}")
            left = t
        return left

    def term(self):
        left = self.factor()
        while self.peek()[0] in ('MUL', 'DIV'):
            op = self.peek()[0]
            self.eat(op)
            right = self.factor()
            t = newTemp()
            emit(f"{t} = {left} {self.op_symbol_math(op)} {right}")
            left = t
        return left

    def factor(self):
        tok = self.peek()
        if tok[0] == 'NUMBER':
            self.eat('NUMBER')
            return tok[1]
        elif tok[0] == 'ID':
            self.eat('ID')
            return tok[1]
        elif tok[0] == 'LPAREN':
            self.eat('LPAREN')
            val = self.expr()
            self.eat('RPAREN')
            return val
        else:
            raise SyntaxError("Invalid factor")

    def op_symbol_math(self, op):
        return {'ADD': '+', 'SUB': '-', 'MUL': '*', 'DIV': '/'}[op]


# -------------------------------
# MAIN
# -------------------------------
if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python3 icg_if_else_file.py <input_file>")
        sys.exit(1)

    file_path = sys.argv[1]
    with open(file_path, 'r') as f:
        code = f.read()

    parser = Parser(tokenize(code))
    parser.parse_program()

    print("=== THREE ADDRESS CODE (ICG) ===")
    for line in output:
        print(line)
