import sys
import re

# --------------------------
# Regex patterns
# --------------------------
type_pattern = r"(?:int|float|double|char|bool)"   # non-capturing
id_pattern = r"[a-zA-Z_][a-zA-Z0-9_]*"
number_pattern = r"\d+(\.\d+)?"

decl_pattern = re.compile(rf"^\s*({type_pattern})\s+({id_pattern})\s*;\s*$")
assign_pattern = re.compile(rf"^\s*({id_pattern})\s*=\s*(.+);\s*$")

# --------------------------
# Analyze a single line
# --------------------------
def analyze_line(line, lineno):
    line = line.strip()
    if not line:
        return

    # Declaration check
    m = decl_pattern.match(line)
    if m:
        typ, var = m.groups()
        print(f"[TOKEN] TYPE ({typ})")
        print(f"[TOKEN] ID ({var})")
        print(f"[TOKEN] SEMI (;)")
        print(f"→ Declaration statement found at line {lineno}: {var}")
        return

    # Assignment check
    m = assign_pattern.match(line)
    if m:
        var, expr_str = m.groups()
        print(f"[TOKEN] ID ({var})")
        print(f"[TOKEN] ASSIGN (=)")
        # Tokenize expression roughly
        tokens = re.findall(rf"{number_pattern}|{id_pattern}|[\+\-\*/]", expr_str)
        for t in tokens:
            if re.fullmatch(number_pattern, t):
                print(f"[TOKEN] NUMBER ({t})")
            elif re.fullmatch(id_pattern, t):
                print(f"[TOKEN] ID ({t})")
            else:
                print(f"[TOKEN] OP ({t})")
        print(f"[TOKEN] SEMI (;)")
        print(f"→ Assignment statement found at line {lineno}: {var} = ...")
        return

    # Syntax error
    print(f"❌ Syntax error at line {lineno}: {line}")

# --------------------------
# Analyze file
# --------------------------
def analyze_file(filename):
    try:
        with open(filename, "r") as f:
            lines = f.readlines()
        print("=== Starting Syntax Analysis ===\n")
        for idx, line in enumerate(lines, start=1):
            analyze_line(line, idx)
        print("\n=== Parsing Complete ===")
    except FileNotFoundError:
        print(f"File '{filename}' not found!")

# --------------------------
# Entry point
# --------------------------
if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 syntax_analyzer.py <input_file.cpp>")
    else:
        analyze_file(sys.argv[1])
