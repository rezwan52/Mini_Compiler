import sys

def generate_arm(icg_lines):
    """
    Generate ARM assembly code from ICG lines.
    Supports simple arithmetic and assignment.
    """
    var_map = {}   # hashmap to track loaded variables
    asm_lines = [] # list to hold ARM assembly code
    reg_count = 0

    def get_reg(var):
        """Get or assign a register to a variable."""
        nonlocal reg_count
        if var.isdigit():      # constants use immediate
            return f"#{var}"
        if var not in var_map:
            reg_name = f"r{reg_count}"
            var_map[var] = reg_name
            reg_count += 1
        return var_map[var]

    for line in icg_lines:
        if '=' not in line:
            continue

        lhs, rhs = [x.strip() for x in line.split('=', 1)]
        tokens = rhs.split()

        if len(tokens) == 1:
            # simple assignment: a = 5 or a = b
            src = get_reg(tokens[0])
            dst = get_reg(lhs)
            asm_lines.append(f"MOV {dst}, {src}")

        elif len(tokens) == 3:
            op1, op, op2 = tokens
            r1 = get_reg(op1)
            r2 = get_reg(op2)
            dst = get_reg(lhs)

            if op == '+':
                asm_lines.append(f"ADD {dst}, {r1}, {r2}")
            elif op == '-':
                asm_lines.append(f"SUB {dst}, {r1}, {r2}")
            elif op == '*':
                asm_lines.append(f"MUL {dst}, {r1}, {r2}")
            elif op == '/':
                asm_lines.append(f"SDIV {dst}, {r1}, {r2}")
        else:
            asm_lines.append(f"; Unsupported: {line}")

    return asm_lines


def main():
    if len(sys.argv) < 2:
        print("Usage: python assemble.py <input_file>")
        return

    input_file = sys.argv[1]
    output_file = input_file.rsplit('.', 1)[0] + ".s"

    # Read ICG input
    with open(input_file, 'r') as f:
        icg_lines = [line.strip() for line in f if line.strip()]

    # Generate assembly
    asm_lines = generate_arm(icg_lines)

    # Print to terminal
    print("=== Generated ARM Assembly ===")
    for line in asm_lines:
        print(line)
    print("==============================")

    # Save to file
    with open(output_file, 'w') as f:
        for line in asm_lines:
            f.write(line + "\n")

    print(f"\nAssembly saved to: {output_file}")


if __name__ == "__main__":
    main()
