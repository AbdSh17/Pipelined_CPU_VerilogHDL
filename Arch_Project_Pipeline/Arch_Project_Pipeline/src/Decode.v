module decode(pc, stall, clk, clear, inst_buff_data, pc_buff_tun, add_rd, add_imm, turn_off, pc_src, branch, jump, jr, rw, reg_w, fwa, fwb, bus_w, alu_fw, mem_fw, kill, cu_flags, imm_buf, bus_a, bus_b, rd_buf2, rb, rs, alu_op, op_code, reg_dst_out, call);
	
	input stall, clk, clear, reg_w, add_rd, add_imm, turn_off;
	input [1:0] fwa, fwb;
	input [31:0] bus_w, alu_fw, mem_fw, inst_buff_data, pc_buff_tun, pc;
	input [3:0] rw;

	
	// output eqz, ltz;
	// output [5:0] op_code;
	// output [31:0] branch;
	output [7:0] cu_flags;
	output signed [31:0] imm_buf, bus_a, bus_b, branch, jump, jr;
	output kill;
	output [1:0] pc_src, alu_op;
	output [5:0] op_code;
	output [3:0] rd_buf2, rs, rb;
	
	wire [5:0] d_opcode;
	wire [3:0] d_rd;
	wire eqz, ltz;
	wire [3:0] rd, rt;
	wire signed [13:0] imm;
	wire [31:0] rs_cmp, jr;
	 
	wire jump_f, jr_f, lz, gz, bz;

	wire imm_ext, reg_dst, imm_src, wire_call, dff_out;
	output reg_dst_out, call;
										   
	// module control_signals(instruction, stall, turn_off, clk, clear, op_code, rd, rs, rt, imm);
	control_signals cs(inst_buff_data, stall, turn_off, clk, clear, op_code, rd, rs, rt, imm);
	
	branch_and_jump baj(pc_buff_tun, turn_off, clk, clear, imm, rs_cmp, branch, jump, eqz, ltz);
	
	// module Main_Control (Opcode, Turn_OFF, stall, Flags, Call, jump_F, JR_F, LZ, GZ, BZ);
	Main_Control mcu(op_code, turn_off, stall, cu_flags, wire_call, jump_f, jr_f, lz, gz, bz);
	
	// module D_FF(clk, data, out);
	D_FF #(1) dff1(clk, call, dff_out);
	assign call = wire_call & ~(dff_out);
	
	// module PC_CU (ZF, NF, Jump_F, JR_F, CLL, BZ, GZ, LZ, PC_Src, Kill);
	PC_CU pcu(eqz, ltz, jump_f, jr_f, call, bz, gz, lz, pc_src, kill);
	
	assign imm_ext = cu_flags[4];
	assign reg_dst = cu_flags[6];
	assign reg_dst_out = rd_buf2;
	assign imm_src = cu_flags[7];
	
	// imm_value(imm, add_imm, imm_ext, imm_buf);
	imm_value imv1(imm, add_imm, imm_ext, imm_buf);	
	
//m     reg_file_buf(rs, rt, rd, rw, add_rd, call, reg_dst, clear, clk, reg_w, bus_w, alu_fw, mem_fw, fwa, fwb, rs_cmp, jr, bus_a, bus_b, rd_buf, rb);
	reg_file_buf rfb(pc, rs, rt, rd, rw, add_rd, call, reg_dst, clear, clk, reg_w, bus_w, alu_fw, mem_fw, fwa, fwb, rs_cmp, jr, bus_a, bus_b, rd_buf2, rb);  
	
	// module ALU_CU (OP, stall, ALU_OP);
	ALU_CU acu(op_code, stall, alu_op);
	
endmodule
																							 // output
module reg_file_buf(pc, rs, rt, rd, rw, add_rd, call, reg_dst, clear, clk, reg_w, bus_w, alu_fw, mem_fw, fwa, fwb, rs_cmp, jr, bus_a, bus_b, rd_buf, rb); 
	
	input add_rd, reg_dst, call, clk, clear, reg_w;	  // 6
	input [1:0] fwa, fwb;  // 8
	input [3:0] rs, rd, rt, rw;	// 11
	input [31:0] alu_fw, mem_fw, bus_w, pc;	// 15
	
	output [31:0] bus_a, bus_b, rs_cmp, jr;	// 21
	output [3:0] rd_buf, rb;
	
	wire [3:0] rb_value, rd_value, rw_wire;
	wire [31:0] bus_a_wire, bus_b_wire, bus_w_wire;
	
	
	MUX #(.WIDTH(4), .INPUTS(2)) M1({(rd + 32'b1), rd}, add_rd, rd_value);
	MUX #(.WIDTH(4), .INPUTS(2)) M2({rd_value, rt}, reg_dst, rb_value);
	assign rd_buf = rd_value;
	
	
	assign rb = rb_value;
	
	
	// module Reg_File(RA, RB, RW, C, RegW, CLK, BusA, BusB, BusW);
	Reg_File rf1(rs, rb_value, rw_wire, clear, (reg_w | call), clk, bus_a_wire, bus_b_wire, bus_w_wire);
	
	MUX #(.WIDTH(32), .INPUTS(4)) M4({bus_w, mem_fw, alu_fw, bus_a_wire}, fwa, bus_a);
	MUX #(.WIDTH(32), .INPUTS(4)) M5({bus_w, mem_fw, alu_fw, bus_b_wire}, fwb, bus_b);
	MUX #(.WIDTH(32), .INPUTS(2)) M6({pc, bus_w}, call, bus_w_wire);
	MUX #(.WIDTH(4), .INPUTS(2)) M7({4'he, rw}, call, rw_wire);
	assign rs_cmp = bus_a;
	assign jr = bus_a;
	
	
endmodule

module imm_value(imm, add_imm, imm_ext, imm_buf);
	
	input signed [13:0] imm;
	input add_imm, imm_ext;
	
	output [31:0] imm_buf;
	
	wire signed [13:0] imm_mux;
	wire [31:0] unsign_extened_imm;
	wire signed [31:0] sign_extened_imm;
	
	
	MUX #(.WIDTH(14), .INPUTS(2)) M1({imm + 14'b1, imm}, add_imm, imm_mux);
	
	
	assign sign_extened_imm = {{18{imm_mux[13]}}, imm_mux};
	assign unsign_extened_imm = {{18{1'b0}}, imm_mux};
	
	MUX #(.WIDTH(32), .INPUTS(2)) M2({sign_extened_imm, unsign_extened_imm}, imm_ext, imm_buf);
	
endmodule


module control_signals(instruction, stall, turn_off, clk, clear, op_code, rd, rs, rt, imm);
	
	input [31:0] instruction;
	input stall, turn_off, clk, clear;
	
	output [5:0] op_code;
	output [3:0] rd, rs, rt;
	output signed [13:0] imm;
	
	wire en_reg;
	wire [31:0] instruction_buff;
	
	assign en_reg = ~(stall | turn_off);
	
	// module register(data, en, clk, clear, out);
	register r1(instruction, en_reg, clk, clear, instruction_buff);
	
	assign op_code = instruction_buff[31:26];
	assign rd = instruction_buff[25:22];
	assign rs = instruction_buff[21:18];
	assign rt = instruction_buff[17:14];
	assign imm = instruction_buff[13:0];
	
endmodule

module branch_and_jump(pc_buff, turn_off, clk, clear, imm, rs, branch, jump, eqz, ltz);
	
	input [31:0] pc_buff;
	input turn_off, clk, clear;
	input signed [13:0] imm;
	input [31:0] rs;
	
	output [31:0] branch, jump;
	output eqz, ltz;
	
	wire [31:0] pc_buff2;
	wire signed [31:0] imm_extened, add_value;
	
	// module register(data, en, clk, clear, out);
	// register r1(pc_buff, ~turn_off, clk, clear, pc_buff2);
	
	assign imm_extened = {{18{imm[13]}}, imm};
	assign add_value = imm_extened + pc_buff;
	
	assign branch = add_value;
	assign jump = add_value;
	
	assign eqz = (rs == 0);
	assign ltz = ($signed(rs) < 0);

	
endmodule 

// =========================================================================================================================
// =========================================================================================================================
// =========================================================================================================================
// =========================================================================================================================
// =========================================================================================================================
// =========================================================================================================================
// =========================================================================================================================
// =========================================================================================================================
// =========================================================================================================================
// =========================================================================================================================
// =========================================================================================================================
// =========================================================================================================================
// =========================================================================================================================
// =========================================================================================================================
// =========================================================================================================================
// =========================================================================================================================
// =========================================================================================================================
// =========================================================================================================================
// =========================================================================================================================
// =========================================================================================================================
// =========================================================================================================================
// =========================================================================================================================
// =========================================================================================================================
// =========================================================================================================================


// Testbench for PC_CU
module test_PC_CU;

    reg ZF, NF, Jump_F, JR_F, CLL, BZ, GZ, LZ;

    wire [1:0] PC_Src;
    wire Kill;

    PC_CU f1(ZF, NF, Jump_F, JR_F, CLL, BZ, GZ, LZ, PC_Src, Kill);

    reg [7:0] temp;

    initial begin
        temp = 8'b0; // To test all casses from 0 to 2^8, where the 8 is number of inputs.

        repeat (256) begin
            {ZF, NF, Jump_F, JR_F, CLL, BZ, GZ, LZ} = temp;
            #10; 
            temp = temp + 1;
        end
    end

    initial begin
        $monitor("Time: %0t | ZF=%b NF=%b JF=%b JR=%b CLL=%b BZ=%b GZ=%b LZ=%b || Kill=%b PC_Src=%b%b",
                  $time, ZF, NF, Jump_F, JR_F, CLL, BZ, GZ, LZ,
                  Kill, PC_Src[1], PC_Src[0]);
    end

endmodule

module test_Main_Control;

    reg [4:0] Opcode;
    reg Turn_OFF;
    reg stall;

    wire [7:0] Flags;
    wire Call, jump_F, JR_F, LZ, GZ, BZ;
	Main_Control f1(Opcode, Turn_OFF, stall, Flags, Call, jump_F, JR_F, LZ, GZ, BZ);

    integer i;

    initial begin
        $display("==== case with out off(Turn_OFF = 0, stall = 0) ====");
        Turn_OFF = 0;
        stall = 0;

        for (i = 0; i < 16; i = i + 1) begin
            Opcode = i[4:0];
            #10;
        end

        $display("==== case with out off (Turn_OFF = 1, stall = 1) ====");
        Turn_OFF = 1;
        stall = 1;

        for (i = 0; i < 16; i = i + 1) begin
            Opcode = i[4:0];
            #10;
        end

        $finish;
    end

    initial begin
        $display("Time | Opcode | Flags    | BZ GZ LZ | JR_F JUMP CALL");
        $monitor("%4t |  0x%02h  | %08b |  %b  %b  %b |   %b     %b    %b",
                 $time, Opcode, Flags, BZ, GZ, LZ, JR_F, jump_F, Call);
    end

endmodule




module test_bj;
	reg [31:0] pc_buff;
	reg turn_off, clk, clear;
	reg [13:0] imm;
	reg [3:0] rs;
	
	wire [31:0] branch, jump;
	wire eqz, ltz;
	
	branch_and_jump baj(pc_buff, turn_off, clk, clear, imm, rs, branch, jump, eqz, ltz);
	
	
	initial begin
		clk = 0;
		repeat (6)
			#5 clk = ~clk;
	end
	
	
	initial begin
		
		{pc_buff, turn_off, clk, clear, imm, rs} = 0;
		
		#1 $display("Time: %d, pc_buff: %d, Branch: %d, flags: %b", $time, pc_buff, branch, {eqz, ltz});
		
		#4
		pc_buff = 32'd10;
		imm = 14'd8;
		rs = 4'd0;
		
		#10
		pc_buff = 32'd13;
		imm = 14'd8;
		rs = 4'd5;
		
	end
	
	always @(posedge clk) begin
		
		#1 $display("Time: %d, pc_buff: %d, Branch: %d, flags: %b", $time, pc_buff, branch, {eqz, ltz}); 
		
	end
	
endmodule  

// test bench of register file.
module test_Reg_File;

    reg CLK, RegW, C;
    reg [3:0] RA, RB, RW;             
    reg [31:0] BusW;
    wire [31:0] BusA, BusB;

    Reg_File f1(RA, RB, RW, C, RegW, CLK, BusA, BusB, BusW);

    // Generate clock
    initial begin
        CLK = 0;
        forever #5 CLK = ~CLK;
    end

    integer i;

    initial begin
        // Reset all inputs to zeros for initial. 
        {RegW, C, RA, RB, RW, BusW} = 0;
        $display("time: %0t | Reset all registers", $time);
        #2 C = 1; #2 C = 0;

       // write and read from the same reg.
        for (i = 0; i < 16; i = i + 1) begin
            RW = i;
            RA = i;   
            RB = i;   
            BusW = 32'hA0000000 + i;
            RegW = 1;
            #10 RegW = 0; 
        end

        $finish;
    end

    always @(posedge CLK) begin
        #1 $display("Time: %0t | RA[%0d] = %h | RB[%0d] = %h | RW[%0d] = %h",
                    $time, RA, BusA, RB, BusB, RW, BusW);
    end

endmodule
