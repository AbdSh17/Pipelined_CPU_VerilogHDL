module write_back(clk, clear, turn_off, mem_out, rd_buf4, cu_flags4, rw, bus_w, reg_w);
	
	input [7:0] cu_flags4;
	input [3:0] rd_buf4;
	input [31:0] mem_out;
	input turn_off, clk, clear;
	
	output [3:0] rw;
	output reg_w;
	output [31:0] bus_w;
	
	wire [7:0] cu_flags5;
	
	
	register #(8) r1(cu_flags4, ~turn_off, clk, clear, cu_flags5);
	register #(32) r2(mem_out, ~turn_off, clk, clear, bus_w);
	register #(4) r3(rd_buf4, ~turn_off, clk, clear, rw);
	
	assign reg_w = cu_flags5[5];
	
	
endmodule