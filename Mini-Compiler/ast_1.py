# ast_builder_file_cli.py
import ast
import sys

# Node class for custom AST
class Node:
    def __init__(self, val, left=None, right=None):
        self.val = val
        self.left = left
        self.right = right

# Convert Python AST to custom Node tree
def build_tree(expr):
    if isinstance(expr, ast.BinOp):
        left = build_tree(expr.left)
        right = build_tree(expr.right)
        op = type(expr.op)
        op_map = {ast.Add:"+", ast.Sub:"-", ast.Mult:"*", ast.Div:"/"}
        return Node(op_map[op], left, right)
    elif isinstance(expr, ast.Name):
        return Node(expr.id)
    elif isinstance(expr, ast.Constant):
        return Node(str(expr.value))
    else:
        raise Exception(f"Unsupported expression: {expr}")

# Print AST
def print_ast(node, level=0):
    if not node:
        return
    print("  " * level + str(node.val))
    print_ast(node.left, level + 1)
    print_ast(node.right, level + 1)

# Parse a single statement
def parse_statement(statement, lineno):
    statement = statement.strip()
    if not statement:
        return
    if not statement.endswith(";"):
        print(f"❌ Syntax error at line {lineno}: Missing semicolon")
        return
    statement = statement[:-1]  # remove semicolon

    if "=" in statement:
        var, expr_str = statement.split("=", 1)
        var = var.strip()
        expr_str = expr_str.strip()
        try:
            expr_ast = ast.parse(expr_str, mode='eval').body
            tree = Node("=", Node(var), build_tree(expr_ast))
            print(f"→ Assignment statement at line {lineno}: {var} = ...")
            print_ast(tree)
            print()
        except Exception as e:
            print(f"❌ Syntax error at line {lineno}: {e}")
    else:
        print(f"❌ Syntax error at line {lineno}: Only assignment statements supported")

# Main function: read from file
def parse_file(filename):
    try:
        with open(filename, "r") as f:
            lines = f.readlines()
        print("=== AST Parser ===\n")
        for idx, line in enumerate(lines, start=1):
            parse_statement(line, idx)
        print("=== Parsing Complete ===")
    except FileNotFoundError:
        print(f"File '{filename}' not found!")

# Entry point
if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 ast_builder_file_cli.py <input_file.cpp>")
    else:
        parse_file(sys.argv[1])
