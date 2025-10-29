import ast
import re
import sys

class Node:
    def __init__(self, val, left=None, right=None):
        self.val = val
        self.left = left
        self.right = right

def print_ast(node, level=0):
    if not node:
        return
    print("  " * level + str(node.val))
    print_ast(node.left, level + 1)
    print_ast(node.right, level + 1)

def build_expr_tree(expr):
    if isinstance(expr, ast.BinOp):
        op_type = type(expr.op)
        op_map = {ast.Add: "+", ast.Sub: "-", ast.Mult: "*", ast.Div: "/"}
        op_symbol = op_map.get(op_type, "?")
        left = build_expr_tree(expr.left)
        right = build_expr_tree(expr.right)
        return Node(op_symbol, left, right)
    elif isinstance(expr, ast.Name):
        return Node(expr.id)
    elif isinstance(expr, ast.Constant):
        return Node(str(expr.value))
    else:
        return Node("UNKNOWN")

def analyze_line(line, lineno):
    line = line.strip()
    if not line:
        return

    # Match assignment statements only
    assign_match = re.match(r"([a-zA-Z_]\w*)\s*=\s*(.+);", line)
    if assign_match:
        var, expr = assign_match.groups()
        try:
            expr_ast = ast.parse(expr, mode='eval').body
            tree = Node("=", Node(var), build_expr_tree(expr_ast))
            print(f"--- Line {lineno} ---")
            print_ast(tree)
            print()
        except Exception as e:
            print(f"❌ Invalid expression at line {lineno}: {e}")

def analyze_file(filename):
    try:
        with open(filename, "r") as f:
            lines = f.readlines()
    except FileNotFoundError:
        print(f"File '{filename}' not found!")
        return

    for idx, line in enumerate(lines, start=1):
        analyze_line(line, idx)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 script.py <input_file>")
    else:
        analyze_file(sys.argv[1])
