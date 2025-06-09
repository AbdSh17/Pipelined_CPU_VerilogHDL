module Reg_File(RA, RB, RW, C, RegW, CLK, BusA, BusB, BusW);
	input wire CLK, RegW,C;
    input wire [3:0] RA, RB, RW;
    input wire [31:0] BusW;
    output wire [31:0] BusA, BusB;
	reg [31:0] registers [15:0];   

    assign BusA = registers[RA];
    assign BusB = registers[RB];

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : reg_block
            wire en_i = RegW && (RW == i);  
            register #(.n(32)) R1(.data(BusW),.en(en_i),.clk(CLK), .clear(C), .out(registers[i]));
        end
    endgenerate
	
	initial begin
		
		#5000; // Or wait for enough cycles
        $writememh("reg.hex", registers);
		
	end

endmodule