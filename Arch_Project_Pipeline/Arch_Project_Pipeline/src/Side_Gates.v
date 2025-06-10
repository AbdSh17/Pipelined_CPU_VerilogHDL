// General Comparator module
module comparator(a, b, less, eqauil, greater);
	parameter n = 32; // number of input bits
	input [n - 1: 0] a, b;
	output reg less, eqauil, greater;
	
	always @(*) begin
		greater = 0; less = 0; eqauil = 0;
		
		
		if (a > b)
			greater = 1;
		else if (a == b)
			eqauil = 1;
		else
			less = 1;
		
	end
	
endmodule	

// General MUX module
module MUX(in, sel, out);
	parameter WIDTH = 32; // number of input bits
	parameter INPUTS = 4; // number of inputs
	
	input  [WIDTH-1:0] in [INPUTS-1:0];
	input  [$clog2(INPUTS)-1:0] sel;
	output reg [WIDTH-1:0] out;
	
	always @(*) begin
        out = in[sel];
    end

endmodule 


// General Adder moduel
module adder(in1, in2, out);
	parameter n = 32;
	
	input [n - 1 : 0] in1, in2;
	output reg [n - 1 : 0] out;
	
	always @(*) begin
		out = in1 + in2;
	end
endmodule


// General Register module
module register(data, en, clk, clear, out);
	parameter n = 32;
	
	input [n - 1: 0] data;
	input en, clk, clear;
	
	output reg [n - 1: 0] out;
	
	always @(posedge clk) begin
		if (en != 0)
			out = data;
	end
	
	// The clear in the register is asynchronized; 
	always @(posedge clear) begin
		out = 0;
	end	
	
	initial begin
		out = 0;
	end
	
endmodule	