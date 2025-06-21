# Instruction to opcode mapping based on Project_Document.pdf
opcode_map = {
    "OR":   0x00,
    "ADD":  0x01,
    "SUB":  0x02,
    "CMP":  0x03,
    "ORI":  0x04,
    "ADDI": 0x05,
    "LW":   0x06,
    "SW":   0x07,
    "LDW":  0x08,
    "SDW":  0x09,
    "BZ":   0x0A,
    "BGZ":  0x0B,
    "BLZ":  0x0C,
    "JR":   0x0D,
    "J":    0x0E,
    "CLL":  0x0F
}

# Register name to number
reg_map = {f"R{i}": i for i in range(16)}

def to_signed_14bit(value):
    """Convert integer to signed 14-bit two's complement."""
    if value < 0:
        return (1 << 14) + value
    return value & 0x3FFF

def assemble_line(line):
    tokens = line.replace(',', '').split()
    if not tokens:
        return None

    instr = tokens[0].upper()
    opcode = opcode_map.get(instr)

    if opcode is None:
        raise ValueError(f"Unknown instruction: {instr}")

    # R-type (e.g., ADD R1, R2, R3)
    if instr in ["OR", "ADD", "SUB", "CMP"]:
        rd = reg_map[tokens[1]]
        rs = reg_map[tokens[2]]
        rt = reg_map[tokens[3]]
        imm = 0
        code = (opcode << 26) | (rd << 22) | (rs << 18) | (rt << 14) | imm

    # I-type (e.g., ADDI R1, R2, imm)
    elif instr in ["ORI", "ADDI", "LW", "SW", "LDW", "SDW"]:
        rd = reg_map[tokens[1]]
        rs = reg_map[tokens[2]]
        imm = to_signed_14bit(int(tokens[3]))
        code = (opcode << 26) | (rd << 22) | (rs << 18) | imm

    # Branches (e.g., BZ R2, imm)
    elif instr in ["BZ", "BGZ", "BLZ"]:
        rs = reg_map[tokens[1]]
        imm = to_signed_14bit(int(tokens[2]))
        rd = 0
        code = (opcode << 26) | (rd << 22) | (rs << 18) | imm

    # JR R3
    elif instr == "JR":
        rs = reg_map[tokens[1]]
        code = (opcode << 26) | (0 << 22) | (rs << 18)

    # J imm
    elif instr in ["J", "CLL"]:
        imm = to_signed_14bit(int(tokens[1]))
        code = (opcode << 26) | imm

    else:
        raise ValueError(f"Unsupported instruction format: {instr}")

    return f"{code:08X}"

# === Example usage ===
if __name__ == "__main__":
    program = [
        "LDW R0, R0, 00", #MEM ADDRESS FOR THE FIRST ARRAY
        "CLL 30", # FUNCTION THAT CHECK THE TWO ARRAYS

        # 30
        "LW R2, R13, 2",  # ARRAY LENGTH
        "LW R6, R13, 0",# STORE THE NUMBER FROM FIRST ARRAY
        "ADDI R0, R0, 1",
        "CLL 50",
        "ADDI R0, R0, 1",
        "ADDI R2, R2, -1",
        "BGZ R2, -4",
        "J 71",

        # 50
        "LW R3, R13, 2", # LOAD THE ARRAY LENGTH
        "LW R1, R13, 1", # LOAD THE ARRAY ADDRESS
        "LW R7, R1, 0", # LOAD THE ARRAY N'TH NUMBER
        "CMP R8, R6, R7", # SUB THE NUMBER A1 TO A2
        "BZ R8, 70",
        "ADDI R1, R1, 1",
        "ADDI R3, R3, -1",
        "BGZ R3, -5",
        "JR R14",


        #70
        "ADDI R10, R10, 1",
        #71
        "SW R10, R11, 0",

        "CMP R8, R7, R6",


        "LDW R0, R13, 0"

    ]
    all_code = []
    i = 0
    for line in program:
        i += 1
        try:
            hex_code = assemble_line(line)
            print(hex_code)
            #print(f"mem[{i}] = 32'h{hex_code}")
        except Exception as e:
            print(f"{line:<30} => Error: {e}")

   # for code in all
