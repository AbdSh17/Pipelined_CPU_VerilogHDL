module ALU(input_1, input_2, alu_op, zero_falg, negative_flag, output_0);
	parameter n = 32;
	
	localparam OR = 2'b00, ADD = 2'b01, SUB = 2'b10, CMP = 2'b11;

	
	input [n - 1:0] input_1, input_2; input [1:0] alu_op;
	output reg zero_falg, negative_flag;   //
	output reg [n - 1: 0] output_0; 
	
	always @(*)
		begin
		
			case (alu_op)
				OR:
					output_0 = input_1 | input_2;
				ADD: 
					output_0 = input_1 + input_2;
				SUB:
					output_0 = input_1 - input_2;
				CMP:
				begin
					// output_0 = input_1 == input_2;
					if (input_1 == input_2)
						output_0 = 0;
					else if (input_1 < input_2)
						output_0 = -1;
					else if (input_1 > input_2)
						output_0 = 1;
						
					zero_falg = input_1 == input_2;
					negative_flag = input_1 < input_2;
				end
			endcase
		end
	
	
endmodule	 

module test_ALU;
	parameter n = 32;
	reg [n - 1:0] input_1, input_2; reg [1:0] alu_op; 
	wire [n - 1: 0] output_0;
	wire zero_falg, negative_flag;
	
	ALU f1(input_1, input_2, alu_op, zero_falg, negative_flag, output_0);
	
	initial begin
		{input_2, input_1} = 64'b0;
		//alu_op = 2'b00;
		//alu_op = 2'b01;
		//alu_op = 2'b10;
		alu_op = 2'b11;
		
		repeat(64) 
			begin
				#10 input_1 += 1; input_2 += 2;
			end
	end		   
	
	initial 
		begin
		   $monitor("time: %d, %d -- %d, OP: %d ____ Resault: %d", $time, input_2, input_1, alu_op, output_0); // USE When ADD/SUB/CMP
		   // $monitor("time: %d, %b -- %b, OP: %d ____ Resault: %b", $time, input_2, input_1, alu_op, output_0);	  // USE When OR
		end
	
	
endmodule