module comparator(a, b, less, eqauil, greater);
	parameter n = 32;
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