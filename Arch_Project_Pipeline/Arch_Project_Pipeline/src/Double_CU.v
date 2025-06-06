module double_CU(op_code, rd, clk, add_pc, add_rd, add_imm, turn_off);
	
	input [5:0] op_code; input [3:0] rd; input clk; // Op code to check if operation is double typel; Clock for D-latch ; rd to check if it's ODD
	output add_pc, add_rd, add_imm, turn_off; // Flags that D_CU gives
	
	wire [3:0] splited_op_code;	// just need four bits (to make the comparator smaller)
	wire ff_in, ff_out, ff_xor;
	
	wire operation_is_double;
	wire compare_8_bit, compare_9_bit;
	wire null_wire;
	wire ff_and_op;
	
	// D_FF(clk, data, out);
	D_FF #(1) dff(clk, ff_in, ff_out);
	
	assign splited_op_code = op_code[3:0];
	// module comparator(a, b, less, eqauil, greater);
	comparator #(4) comp8(splited_op_code, 4'd8, null_wire, compare_8_bit, null_wire);
	comparator #(4) comp9(splited_op_code, 4'd9, null_wire, compare_9_bit, null_wire);
	
	
	assign operation_is_double = compare_8_bit | compare_9_bit;  // compare if the operation is double
	assign ff_xor = operation_is_double ^ ff_out;
	assign ff_in = operation_is_double & ff_xor;
	
	assign ff_and_op = ff_out & operation_is_double; // if operation is double and second cycle
	
	assign add_rd = ff_and_op; // if second cycle
	assign add_imm = ff_and_op;	// if second cycle
	assign add_pc = (~operation_is_double) | (ff_and_op) | (rd[0]); // if there's no double operation, or second cycle or odd RD
	assign turn_off = operation_is_double & rd[0]; // if odd RD while the operation is double type
	
endmodule 

module dcu(op_code, rd, clk, add_pc, add_rd, add_imm, turn_off);
	
	input [5:0] op_code; input [3:0] rd; input clk; // Op code to check if operation is double typel; Clock for D-latch ; rd to check if it's ODD
	output reg add_pc, add_rd, add_imm, turn_off; // Flags that D_CU gives
	
	wire wire_add_pc, wire_add_rd, wire_add_imm, wire_turn_off;
	
	double_CU dcu(op_code, rd, clk, wire_add_pc, wire_add_rd, wire_add_imm, wire_turn_off);
	
	always @(posedge clk) begin
		add_pc = wire_add_pc;
		add_rd = wire_add_rd;
		add_imm = wire_add_imm;
		turn_off = wire_turn_off;
	end
	
endmodule

	

module D_FF(clk, data, out);
	parameter n = 32;	
	
	input [n - 1: 0] data; input clk;
	output reg [n - 1 : 0] out;
	
	always @(posedge clk)
		out = data;
endmodule

module test_D_CU;
	wire add_pc, add_rd, add_imm, turn_off;
	reg [5:0] op_code; reg [3:0] rd; reg clk;
	
	// dcu dd(op_code, rd, clk, add_pc, add_rd, add_imm, turn_off);
    double_CU dd(op_code, rd, clk, add_pc, add_rd, add_imm, turn_off);	
	reg change;
	
	initial begin
		
		{op_code, rd, clk} = 0;
		change = 0;
		
		
		#10 clk = ~clk ;
		#10 op_code = 6'b000001;
		#1 change = ~change;
		#10 clk = ~clk ;
		
		
		
		#10 clk = ~clk ;
		#10 op_code = 6'b001000;
		#1 change = ~change;
		#10 clk = ~clk ;
		
		
		
		#10 clk = ~clk ;
		#10 op_code = 6'b001000;
		#1 change = ~change;
		#10 clk = ~clk ;
		
		#10 clk = ~clk ;
		#10 op_code = 6'b000000;
		#1 change = ~change;
		#10 clk = ~clk ;
		
		#10 clk = ~clk ;
		#10 op_code = 6'b001001;
		#1 change = ~change;
		#10 clk = ~clk ;
		
		#10 clk = ~clk ;
		#10 op_code = 6'b001001;
		#1 change = ~change;
		#10 clk = ~clk ;
		
		#10 clk = ~clk ;
		#10 op_code = 6'b000001;
		#1 change = ~change;
		#10 clk = ~clk ;
		
		
		#10 clk = ~clk ;
		#10 op_code = 6'b000001;
		#1 change = ~change;
		#10 clk = ~clk ;
		
		#10 clk = ~clk ;
		#10 op_code = 6'b001000;
		rd = 4'b0001;
		#1 change = ~change;
		#10 clk = ~clk ;
		
		#10 clk = ~clk ;
		#10 op_code = 6'b000001;
		#1 change = ~change;
		#10 clk = ~clk ;
		
		
		
	end
	
	always @(change)
	begin
		$display("%d OP: %b CLK: %b -- %b %b %b %b", $time, op_code, clk, add_pc, add_rd, add_imm, turn_off);
		
		
	end

endmodule