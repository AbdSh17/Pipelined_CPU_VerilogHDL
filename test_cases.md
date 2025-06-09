## Assembly Instruction Examples with HEX Codes and Final Results

### EX1 – Test Basic Functionality

| Instruction      | HEX Code |
| ---------------- | -------- |
| ADDI R1, R1, 5   | 14440005 |
| SW R1, \[R0 + 1] | 1C400001 |
| ADDI R0, 1       | 14000001 |
| BZ R6, -4        | 28CCFFFD |

**Final Value:** The loop will continue storing 5, A, F, 10....

---

### EX2 – Test Branch with LDW, SDW and Hazard Detection

| Instruction       | HEX Code |
| ----------------- | -------- |
| ADDI R1, R1, 5    | 14440005 |
| SW R1, \[R0 + 0]  | 1C400000 |
| ADDI R0, 1        | 14000001 |
| SWD R0, \[R0 + 1] | 24000001 |
| ADDI R2, R0, -3   | 14803FFD |
| BLZ R2, -6        | 30083FFB |
| LWD R0, \[R0 + 0] | 20000000 |
| SWD R0, \[R0 + 4] | 24000004 |

**Final Result:**

```
MEM[0]: 5
MEM[1]: 10
MEM[2]: 15
MEM[3]: 2
MEM[4]: 3
MEM[5]: 15
MEM[6]: 2
MEM[7]: 2
```

---

### EX3 – Important: Hazard Detection When ODD

| Instruction       | HEX Code |
| ----------------- | -------- |
| ADDI R1, R1, 5    | 14440005 |
| SW R1, \[R0 + 0]  | 1C400000 |
| ADDI R0, 1        | 14000001 |
| SWD R0, \[R0 + 1] | 24000001 |
| ADDI R2, R0, -3   | 14803FFD |
| BLZ R2, -6        | 30083FFB |
| LWD R0, \[R0 + 0] | 20000000 |
| LWD R1, \[R0 + 0] | 20400000 |
| SWD R0, \[R0 + 4] | 24000004 |

**Final Result:**

```
MEM[0]: 5
MEM[1]: 10
MEM[2]: 15
MEM[3]: 2
MEM[4]: 3
MEM[5]: 15
MEM[6]: 2
MEM[7]: 2
```

---

### EX4 – Test Nested Loops

| Instruction      | HEX Code |
| ---------------- | -------- |
| ADDI R6, 3       | 15980003 |
| ADDI R5, 3       | 15540003 |
| ADDI R1, R1, 5   | 14440005 |
| SW R1, \[R0 + 0] | 1C400000 |
| ADDI R0, 1       | 14000001 |
| SW R0, \[R0 + 1] | 1C000000 |
| ADDI R5, -1      | 15543FFF |
| BGZ R5, -3       | 2C143FFD |
| ADDI R0, 1       | 14000001 |
| ADDI R6, -1      | 15983FFF |
| BGZ R6, -8       | 2C183FF7 |

**Final Result:**

```
MEM[0]: 5
MEM[1]: 1
MEM[2]: 2
MEM[3]: 3
MEM[4]: a
MEM[5]: 5
MEM[6]: 6
MEM[7]: 7
MEM[8]: f
MEM[9]: 9 
MEM[10]: a
MEM[11]: b
```
