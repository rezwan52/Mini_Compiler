import argparse

def load_icg(filename):
    """Load ICG from file into a list of lines."""
    with open(filename, 'r') as f:
        lines = [line.strip() for line in f if line.strip()]
    return lines

def optimize_icg(lines):
    """
    Perform simple optimizations:
    1. Remove assignments of the form x = x
    2. Constant folding: t1 = 2 + 3 => t1 = 5
    3. Remove unused temporaries (optional, simple version)
    """
    optimized = []
    for line in lines:
        # Remove assignments like x = x
        if '=' in line:
            lhs, rhs = [x.strip() for x in line.split('=', 1)]
            if lhs == rhs:
                continue

            # Constant folding for expressions like t1 = 2 + 3
            tokens = rhs.split()
            if len(tokens) == 3:
                a, op, b = tokens
                if a.isdigit() and b.isdigit():
                    a, b = int(a), int(b)
                    if op == '+': rhs = str(a + b)
                    elif op == '-': rhs = str(a - b)
                    elif op == '*': rhs = str(a * b)
                    elif op == '/': rhs = str(a // b)
        optimized.append(f"{lhs} = {rhs}" if '=' in line else line)
    return optimized

def save_icg(lines, filename="optimized_icg.txt"):
    """Save optimized ICG back to file."""
    with open(filename, 'w') as f:
        for line in lines:
            f.write(line + '\n')

def main():
    parser = argparse.ArgumentParser(description="ICG Code Optimizer")
    parser.add_argument("input_file", help="Input ICG file")
    parser.add_argument("--print", action="store_true", help="Print optimized ICG to terminal")
    args = parser.parse_args()

    lines = load_icg(args.input_file)
    optimized = optimize_icg(lines)
    save_icg(optimized)

    if args.print:
        print("\n".join(optimized))

if __name__ == "__main__":
    main()
