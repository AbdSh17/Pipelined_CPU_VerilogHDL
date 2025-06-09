module IF(branch, jr, jump, pc_src, stall, clk, clear, kill, inst_buff_data, pc_buff_tun, add_rd_buf, add_imm_buf, turn_off, pc_out);
	input stall, clk, clear, kill;
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
	
	
	// module program_counter(add_pc, pc_plus_one, pc_in, branch, jr, jump, pc_src, stall, clk, clear, pc);
	program_counter pc1(add_pc, pc_plus_one, pc, branch, jr, jump, pc_src, stall, clk, clear, pc);
	
	// module pc_next(pc, clk, turn_off, clear, pc_plus_one, pc_buff_tun);
	pc_next pn1(pc, clk, temp_turn_off, clear, pc_plus_one, pc_buff_tun);
	
	// module IS_MEM (address, kill, instruction, d_opcode, d_rd);
	IS_MEM ism1(pc, kill, inst_buff_data, d_opcode, d_rd);
	
	// module double_CU(op_code, rd, clk, add_pc, add_rd, add_imm, turn_off);
	double_CU dcu(stall, d_opcode, d_rd, clk, add_pc, add_rd, add_imm, turn_off);
	
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
   // parameter INSTRUCTIONS_FILE = "program.mem";
	
    input  [7 : 0] address;
    output [WIDTH - 1 : 0] instruction;

    reg [WIDTH-1:0] mem [0:DEPTH-1];

	
    initial begin
       // $readmemh(INSTRUCTIONS_FILE, mem); // Load instructions from file
	   /*
mem[0]  = 32'h14440005; // ADDI R1, R1, 5
mem[1]  = 32'h1C400000; // SW R1, [R0 + 0]
mem[2]  = 32'h14000001; // ADDI R0, 1
mem[3]  = 32'h24000001; // SWD R0, [R0 + 0]
mem[4]  = 32'h14803FFD;	// ADDI R2, R0, -3
mem[5]  = 32'h30083FFB;	// BLZ R2, -6
mem[6]  = 32'h20000000;	// LWD R0, [R0 + 0]
mem[7]  = 32'h20400000;
mem[8]  = 32'h24000004;	// BLZ R2, -6 
*/

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


    end
	
    assign instruction = mem[address];
endmodule

/*
  mem[0]  = 32'h14440005; // ADDI R1, R1, 5
mem[1]  = 32'h11111111;
mem[2]  = 32'h11111111;
mem[3]  = 32'h11111111;
mem[4]  = 32'h11111111;

mem[5]  = 32'h1C400000; // SW R1, [R0 + 0]
mem[6]  = 32'h11111111;
mem[7]  = 32'h11111111;
mem[8]  = 32'h11111111;
mem[9]  = 32'h11111111;

mem[10] = 32'h14000001; // ADDI R0, 1
mem[11] = 32'h11111111;
mem[12] = 32'h11111111;
mem[13] = 32'h11111111;
mem[14] = 32'h11111111;

mem[15] = 32'h24000001; // SWD R0, [R0 + 1]
mem[16] = 32'h11111111;
mem[17] = 32'h11111111;
mem[18] = 32'h11111111;
mem[19] = 32'h11111111;

mem[20] = 32'h14803FFD; // ADDI R2, R0, -3
mem[21] = 32'h11111111;
mem[22] = 32'h11111111;
mem[23] = 32'h11111111;
mem[24] = 32'h11111111;

mem[25] = 32'h30083FFA; // BLZ R2, -6
mem[26] = 32'h20000000; // LWD R0, [R0 + 0]
mem[27] = 32'h11111111;
mem[28] = 32'h11111111;
mem[29] = 32'h11111111;
mem[30] = 32'h11111111;

mem[31] = 32'h24000004; // SWD R0, [R0 + 4]

*/

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
	register R1(pc_add, ~turn_off, clk, clear, pc_buff_tun);
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
	IF if1(branch, jr, jump, pc_src, stall, clk, clear, kill, inst_buff_data, pc_buff_tun,add_rd, add_imm, turn_off, null_d);
		
		
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