module execute(clk, clear, turn_off, alu_op, imm, bus_a, bus_b, rd_buf2, cu_flags, bus_b_buff, alu_out, rd_buf3, cu_flags3, reg_wr2);
	
	input clk ,clear, turn_off;														 
	input [1:0] alu_op;
	input [7:0] cu_flags;
	input [31:0]  imm, bus_a, bus_b;
	input [3:0] rd_buf2;
	
	output [31:0] bus_b_buff, alu_out;
	output [3:0] rd_buf3;
	output [7:0] cu_flags3;
	output reg_wr2;
	
	wire [31:0] imm_buff, bus_a_buff, input_1, input_2, alu_out;
	wire [1:0] alu_op_buff;
	wire turn_off, zero_falg, negative_flag, alu_src;
	
	
	register #(32) r1(imm, ~turn_off, clk, clear, imm_buff);
	register #(32) r2(bus_a, ~turn_off, clk, clear, bus_a_buff);
	register #(32) r3(bus_b, ~turn_off, clk, clear, bus_b_buff);
	register #(2) r4(alu_op, ~turn_off, clk, clear, alu_op_buff);
	register #(4) r5(rd_buf2, ~turn_off, clk, clear, rd_buf3);
	register #(8) r6(cu_flags, ~turn_off, clk, clear, cu_flags3);
	
	assign input_1 = bus_a_buff;
	assign input_2 = (alu_src) ? imm_buff : bus_b_buff;
	assign alu_src = cu_flags3[3];
	assign reg_wr2 = cu_flags3[5];
	
	// module ALU(input_1, input_2, alu_op, zero_falg, negative_flag, output_0);
	ALU alu1(input_1, input_2, alu_op_buff, zero_falg, negative_flag, alu_out);
	
endmodule


