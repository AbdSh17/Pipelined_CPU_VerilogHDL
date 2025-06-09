module mem(clk, clear, turn_off, alu_out, bus_b_buff, rd_buf3, cu_flags3, mem_out, rd_buf4, cu_flags4, reg_wr3, out);
	
	input clk, clear, turn_off;
	input [3:0] rd_buf3;
	input [7:0] cu_flags3;
	input [31:0] bus_b_buff, alu_out;
	
	output [31:0] mem_out;
	output [7:0] cu_flags4;
	output [3:0] rd_buf4;
	output reg_wr3;
	
	output [31:0] out;
	
	assign out = address;
	
	
	wire [31:0] address, data, out_data;
	wire mem_rd, mem_wr, wb_src;
	
	register #(32) r1(alu_out, ~turn_off, clk, clear, address);
	register #(32) r2(bus_b_buff, ~turn_off, clk, clear, data);
	register #(8) r3(cu_flags3, ~turn_off, clk, clear, cu_flags4);
	register #(4) r4(rd_buf3, ~turn_off, clk, clear, rd_buf4);
	
	assign wb_src = cu_flags4[0];
	assign mem_wr = cu_flags4[1];
	assign mem_rd = cu_flags4[2];
	assign reg_wr3 = cu_flags4[5];
	
	
	
//modu ram_single (clk, clear, MemWr, MemRd, in_data, address,out_data);
	ram_single rms(clk, clear, mem_wr, mem_rd, data, address[23:0], out_data);

	
	assign mem_out = (wb_src) ? out_data : address;
	
endmodule


module ram_single (clk, clear, MemWr, MemRd, in_data, address, mem_out);

	input wire clk, clear, MemWr, MemRd;
    input wire [31:0] in_data;
    input wire [23:0]  address;         
    reg [31:0] mem [0:127];

    output [31:0] mem_out;

    always @(posedge clk) begin
        if (MemWr)
            mem[address] <= in_data;
    	end

    assign mem_out = (MemRd) ? mem[address] : 32'b0;
	
	initial begin
		
		integer i;
    	for (i = 0; i < 128; i = i + 1)
        	mem[i] = 32'b0;
	
		
        #50000; // Or wait for enough cycles
        $writememh("mem_out.hex", mem);
    end

endmodule