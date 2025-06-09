//module of program counter control unit.
module PC_CU (ZF, NF, Jump_F, JR_F, CLL, BZ, GZ, LZ, PC_Src, Kill);

	input wire ZF;       // Zero flag
	input wire NF;       // Negative flag
	input wire Jump_F;   // Jump flag
	input wire JR_F;     // Jump register flag
	input wire CLL;      // Call instruction
	input wire BZ;       // Branch if zero
	input wire GZ;       // Branch if greater than zero
	input wire LZ;       // Branch if less than zero

	output reg [1:0] PC_Src;  // PC source control
	output wire Kill;         // kill signal when wait of one cycle.

	wire BZ_True   = BZ & ZF;
	wire BGZ_True  = GZ & ~ZF & ~NF;
	wire BLZ_True  = LZ & NF;
	wire Branch_True = BZ_True | BGZ_True | BLZ_True;
	wire J_True    = Jump_F | CLL;

	assign Kill = JR_F | J_True | Branch_True;

	always @(*) begin
    	if (JR_F)
        	PC_Src = 2'b10;         // Jump Register
    	else if (J_True)
        	PC_Src = 2'b11;         // Jump or Call
    	else if (Branch_True)
        	PC_Src = 2'b01;         // Branch
    	else
        	PC_Src = 2'b00;         // Default: PC + 4
	end

endmodule