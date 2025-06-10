module IF(call, branch, jr, jump, pc_src, stall, clk, clear, kill, inst_buff_data, pc_buff_tun, add_rd_buf, add_imm_buf, turn_off, pc_out);
	input stall, clk, clear, kill, call;
	input [1:0] pc_src;
	input [31:0] branch, jr, jump;
	

	output [31:0] inst_buff_data, pc_buff_tun;
	output add_rd_buf, add_imm_buf, turn_off;
	
	
	wire [31:0] program_counter_data;
	wire [31:0] pc;
	wire [31:0] pc_plus_one;
	wire [5:0] d_opcode;
	wire [3:0] d_rd;
	wire add_pc;
	wire temp_turn_off;
	
	wire add_rd, add_imm;
	
	output [31:0] pc_out;
	assign pc_out = pc;
	
	
//modue program_counter(add_pc, pc_plus_one, pc_in, branch, jr, jump, pc_src, stall, clk, clear, pc);
	program_counter pc1(add_pc, pc_plus_one, pc, branch, jr, jump, pc_src, stall, clk, clear, pc);
	
	// module pc_next(pc, clk, turn_off, clear, pc_plus_one, pc_buff_tun);
	pc_next pn1(pc, clk, temp_turn_off, clear, pc_plus_one, pc_buff_tun);
	
	// module IS_MEM (address, kill, instruction, d_opcode, d_rd);
	IS_MEM ism1(pc, kill, inst_buff_data, d_opcode, d_rd);
	
	// module double_CU(op_code, rd, clk, add_pc, add_rd, add_imm, turn_off);
	double_CU dcu(call, stall, d_opcode, d_rd, clk, add_pc, add_rd, add_imm, turn_off);
	
	register #(1) r1(add_imm, ~(temp_turn_off | stall), clk, clear, add_imm_buf);
	register #(1) r2(add_rd, ~(temp_turn_off | stall), clk, clear, add_rd_buf);
	
	
	assign temp_turn_off = turn_off;

	
endmodule


module program_counter(add_pc, pc_plus_one, pc_in, branch, jr, jump, pc_src, stall, clk, clear, pc);
	parameter n = 32;
	
	input [n - 1: 0] pc_plus_one, pc_in, branch, jr, jump;
	input add_pc, stall, clk, clear;
	input [1:0] pc_src;
	
	output [n - 1 : 0] pc;
	
	wire [n - 1 : 0] add_pc_mux, pc_src_mux;
	
	// MUX(in, sel, out);
	MUX #(.WIDTH(32), .INPUTS(2)) M1({pc_plus_one, pc_in}, add_pc, add_pc_mux);
	MUX #(.WIDTH(32), .INPUTS(4)) M2({jump, jr, branch, add_pc_mux}, pc_src, pc_src_mux);
	
	//module register(data, en, clk, clear, out);
	register R1(pc_src_mux, ~stall, clk, clear, pc);
	
endmodule

module IS_MEM (address, kill, instruction, d_opcode, d_rd);
	input [31:0] address; input kill;
	output [5:0] d_opcode; output [3:0] d_rd;
	output [31:0] instruction;
	
	wire [31:0] mem_is;
	
	// module InstructionMemory (address, instruction);
	InstructionMemory IM1(address[7:0], mem_is);
	assign d_opcode = mem_is[31:26];
	assign d_rd = mem_is[25:22];
	
	// MUX(in, sel, out);
	MUX #(.WIDTH(32), .INPUTS(2)) M1({32'b0, mem_is}, kill, instruction);
	

endmodule


module InstructionMemory (address, instruction);
	
	parameter WIDTH = 32;
    parameter DEPTH = 256;
	
    input  [7 : 0] address;
    output [WIDTH - 1 : 0] instruction;

    reg [WIDTH-1:0] mem [0:DEPTH-1];

	
    initial begin

    end
    assign instruction = mem[address];
	
	initial begin
		
		integer i;
    	for (i = 0; i < 128; i = i + 1)
        	mem[i] = 32'b0;
			
			
		// $readmemh("Duplicate_Nums.mem", mem);
		// $readmemh("Summation.mem", mem);
		// $readmemh("Edge_LDW.mem", mem);
		// $readmemh("Nested_Loops.mem", mem);
		
		
			
  /*	Test if two memories are eqauil (raise an error in mem[5])
mem[0] = 32'h00000000;
mem[1] = 32'h20000000; // LDW R0, R13, 0
mem[2] = 32'h3C000021; // CLL 30   

mem[35] = 32'h18B40002; // LW R2, R13, 2
mem[36] = 32'h14880001; // ADDI R2, R2, 1
mem[37] = 32'h19800000; // LW R6, R0, 0
mem[38] = 32'h3C00000f; // CLL 50
mem[39] = 32'h19800000; // LW R6, R0, 0
mem[40] = 32'h14000001; // ADDI R0, R0, 1
mem[41] = 32'h14883FFF; // ADDI R2, R2, -1
mem[42] = 32'h2C083FFC; // BGZ R2, -4
mem[43] = 32'h38000021; // J 71	 

mem[53] = 32'h18F40002; // LW R3, R13, 2
mem[54] = 32'h18740001; // LW R1, R13, 1
mem[55] = 32'h19C40000; // LW R7, R1, 0
mem[56] = 32'h0E1D8000; // CMP R8, R6, R7
mem[57] = 32'h28200011; // BZ R8, 74
mem[58] = 32'h14440001; // ADDI R1, R1, 1
mem[59] = 32'h14CC3FFF; // ADDI R3, R3, -1
mem[60] = 32'h2C0C3FFB; // BGZ R3, -5
mem[61] = 32'h34380000; // JR R14

mem[74] = 32'h16A80001; // ADDI R10, R10, 1
mem[75] = 32'h1EAC0005; // SW R10, R11, 0
 */

			
/*	LDW, SDW
mem[0]  = 32'h14440005; // ADDI R1, R1, 5
mem[1]  = 32'h1C400000; // SW R1, [R0 + 0]
mem[2]  = 32'h14000001; // ADDI R0, 1
mem[3]  = 32'h24000001; // SWD R0, [R0 + 0]
mem[4]  = 32'h14803FFD;	// ADDI R2, R0, -3
mem[5]  = 32'h30083FFB;	// BLZ R2, -6
mem[6]  = 32'h20000000;	// LWD R0, [R0 + 0]
mem[7]  = 32'h20400000; // LDW R1, [R0 + 0]
mem[8]  = 32'h24000004;	// SDW R0, [R0 + 4]  

*/ 

/*	   CALL
mem[0]  = 32'h3C000010;
mem[1]  = 32'h3C00001F;
mem[2] = 32'h3C00002F;
mem[16]  = 32'h14440005;
mem[17]  = 32'h1C400000;
mem[18]  = 32'h14000001;
mem[19]  = 32'h14803FFD;
mem[20]  = 32'h30083FFC;
mem[21]  = 32'h34380000;
mem[32]  = 32'h18C00000;
mem[33]  = 32'h0510C000;
mem[34] = 32'h14003FFF;
mem[35] = 32'h2C003FFD;
mem[36] = 32'h28003FFC;
mem[37] = 32'h1D200005;
mem[38] = 32'h34380000;
*/

/*	  NESTED LOOPS
mem[0]  = 32'h15980003; // ADDI R6, R0, 3
mem[1]  = 32'h15540003; // ADDI R5, R0, 3
mem[2]  = 32'h14440005; // ADDI R1, R1, 5
mem[3]  = 32'h1C400000; // SW R1, [R0 + 0]
mem[4]  = 32'h14000001; // ADDI R0, R0, 1
mem[5]  = 32'h1C000000; // SW R0, [R0 + 1]
mem[6]  = 32'h15543FFF; // ADDI R5, R5, -1
mem[7]  = 32'h2C143FFD; // BGZ R5, -3
mem[8]  = 32'h14000001; // ADDI R0, R0, 1
mem[9]  = 32'h15983FFF; // ADDI R6, R6, -1
mem[10] = 32'h2C183FF7; // BGZ R6, -8
*/
		
	end
	
	
endmodule


module pc_next(pc, clk, turn_off, clear, pc_plus_one, pc_buff_tun);
	input [31:0] pc;
	input turn_off, clk;
	input clear;
	
	output [31:0] pc_buff_tun, pc_plus_one;
	
	wire [31:0] pc_add;
	
	// module adder(in1, in2, out);
	adder a1(pc, 32'b1, pc_add);
	assign pc_plus_one = pc_add;
	
	//module register(data, en, clk, clear, out);
	register R1(pc, 1'b1, clk, clear, pc_buff_tun);
endmodule
	
module test_if;
	// module IF(add_pc, branch, jr, jump, pc_src, stall, clk, clear, kill, turn_off, d_opcode, d_rd, inst_buff_data, pc_buff_tun);
	reg stall, clk, clear, kill, turn_off;
	reg [1:0] pc_src;
	reg [31:0] branch, jr, jump;
	
	wire [31:0] inst_buff_data, pc_buff_tun;
	wire add_rd, add_imm;
	wire [31:0] null_d;
	
	
	// IF(branch, jr, jump, pc_src, stall, clk, clear, kill, inst_buff_data, pc_buff_tun,add_rd, add_imm, turn_off);
//	IF if1(branch, jr, jump, pc_src, stall, clk, clear, kill, inst_buff_data, pc_buff_tun,add_rd, add_imm, turn_off, null_d);
		
		
	initial begin
        clk = 0;
		// repeat (14)
        // #5 clk = ~clk;
    end

		
	initial begin
		
		clk = 0;
		{stall, clk, clear, kill, pc_src, branch, jr, jump} = 0;
		
		#5 clk = ~clk;
		#5 clk = ~clk;
		
		#5 clk = ~clk;
		#5 clk = ~clk;
		
		#5 clk = ~clk;
		#5 clk = ~clk;
		
		#5 clk = ~clk;
		#5 clk = ~clk;
		
		#5 clk = ~clk;
		#5 clk = ~clk;
		
		#5 clk = ~clk;
		#5 clk = ~clk;
		
		// pc_src = 1;
		// branch = 2;
		
		#5 clk = ~clk;
		#5 clk = ~clk;
		
		#5 clk = ~clk;
		#5 clk = ~clk;
		
		#1 $display("time: %d, Instruction: %h, add_imm: %b, PC: %d", $time, inst_buff_data, add_imm, pc_buff_tun);
		
	end	
	
	always @(posedge clk) begin
		
		 #1 $display("time: %d, Instruction: %h, add_imm: %b, PC: %d", $time, inst_buff_data, add_imm, pc_buff_tun); 
		
	end
	
	
endmodule
	


module test_IS_MEM;
	reg [7:0] address; reg kill;
	wire [5:0] d_opcode; wire [3:0] d_rd;
	wire [31:0] instruction;
	
	// module IS_MEM (address, kill, instruction, d_opcode, d_rd);
		
	IS_MEM ISM1(address, kill, instruction, d_opcode, d_rd);
	
	initial begin
		{address, kill} = 0;
		
		
		#10
		address = 0;
		
		#10
		address = 1;
		
		#10
		kill = 1; address = 2;
		
		#10
		address = 2;
		
		#10
		kill = 0; address = 2;
		
		#10
		address = 3;
		
		
	end
	
	
	initial begin
		
		$monitor("Time: %d, Address: %d, OP: %d, RD: %d, Instruction: %h", $time, address, d_opcode, d_rd, instruction);
		
	end
	
endmodule	

module test_pc;
	parameter n = 32;
	wire [n - 1: 0]pc;
	reg [n - 1: 0] pc_plus_one, pc_in, branch, jr, jump;
	reg add_pc, stall, clk, clear;
	reg [1:0] pc_src;
	
	program_counter p1(add_pc, pc_plus_one, pc_in, branch, jr, jump, pc_src, stall, clk, clear, pc);
	
	
	initial begin
		
		clk = 0;
		#1 clk = ~clk;
		#1 clk = ~clk;
		{pc_plus_one, pc_in, branch, jr, jump, add_pc, stall, clk, clear, pc_src} = 0;
		
		/*
		#10
		pc_in = 10; pc_plus_one = 11; branch = 2; jr = 3; jump = 4;
		pc_src = 0; add_pc = 1;
		#1 clk = ~clk;
		#10 clk = ~clk;
		
		#10
		pc_in = 10; pc_plus_one = 11; branch = 2; jr = 3; jump = 4;
		pc_src = 2; add_pc = 1;
		#1 clk = ~clk;
		#10 clk = ~clk;
		
		#10
		pc_in = 10; pc_plus_one = 11; branch = 2; jr = 3; jump = 4;
		pc_src = 1; add_pc = 0;
		#1 clk = ~clk;
		#10 clk = ~clk;
		
		#10
		pc_in = 10; pc_plus_one = 11; branch = 2; jr = 3; jump = 4;
		pc_src = 0; add_pc = 0;
		#1 clk = ~clk;
		#10 clk = ~clk;
		
		#10
		pc_in = 10; pc_plus_one = 11; branch = 2; jr = 3; jump = 4;
		pc_src = 3; add_pc = 1;
		#1 clk = ~clk;
		#10 clk = ~clk;
		*/
		
	end
	
	
	always @(posedge clk or posedge clear)
	begin
		#1 $display("Time: %d, -- S1: %b, S2 %d  out: %d", $time, add_pc, pc_src, pc);
		
	end
endmodule	