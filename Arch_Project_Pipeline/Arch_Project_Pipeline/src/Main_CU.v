module Main_Control (Opcode, Turn_OFF, stall, Flags, Call, jump_F, JR_F, LZ, GZ, BZ);	
	input wire [5:0] Opcode;
	input wire Turn_OFF;
	input wire stall; // This input to select between 0(if no stall cycle) or 1(if stall cycle).
		
	output reg [7:0] Flags; // Flags of selection of multipexers.
    output Call, jump_F, JR_F, LZ, GZ, BZ;

    reg [11:0] rom [0:31];
    reg [11:0] rom_out;

    initial begin
        rom[5'h00] = 12'h020;  // OR instruction(R-Type).
        rom[5'h01] = 12'h020;  // ADD instruction(R-Type).
        rom[5'h02] = 12'h020;  // SUB instruction(R-Type).
        rom[5'h03] = 12'h020;  // CMP instruction(R-Type).
        rom[5'h04] = 12'h038;  // ORI instruction(I-Type).
        rom[5'h05] = 12'h038;  // ADDI instruction(I-Type).
        rom[5'h06] = 12'h03D;  // LW instruction
        rom[5'h07] = 12'h05A;  // SW instruction
        rom[5'h08] = 12'h03d;  // LDW instruction
        rom[5'h09] = 12'h05a;  // SDW instruction
        rom[5'h0a] = 12'h198;  // BZ instruction
        rom[5'h0b] = 12'h298;  // BGZ instruction
        rom[5'h0c] = 12'h498;  // BLZ instruction
        rom[5'h0d] = 12'h898;  // JR instruction
        rom[5'h0e] = 12'h000;  // JUMP instruction
        rom[5'h0f] = 12'h000;  // CALL instruction
    end

    always @(*) begin
        rom_out = rom[Opcode];
    end

    always @(*) begin
        if (stall)
            Flags = 8'h00;
        else
            Flags = rom_out[7:0]; 
    end				 
	
	assign BZ     = (Opcode == 5'h0a);
    assign GZ     = (Opcode == 5'h0b);
    assign LZ     = (Opcode == 5'h0c); 
	assign JR_F   = (Opcode == 5'h0d);
    assign jump_F = (Opcode == 5'h0e);
	assign Call    = (Opcode == 5'h0f);

endmodule	
