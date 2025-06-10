module data_path(clk, clear, resault_1, resault_2, resault_3, resault_4, resault_5, resault_6);
	
	input clk, clear;
	
	output signed [31:0] resault_1, resault_2, resault_3, resault_4, resault_5, resault_6;
	wire reg_dst_out;
	wire [31:0] pc_out;
	
	wire kill, add_rd, add_imm, turn_off, reg_w, reg_wr2, reg_wr3, stall, stall_before;
	wire [1:0] pc_src, alu_op, fwa, fwb;
	wire [3:0] rd_buf2, rd_buf3, rd_buf4, rw, rs, rb;
	wire [31:0] branch, jr, jump, inst_buff_data, pc_buff_tun, bus_a, bus_b,  alu_out, bus_b_buff, imm_buf, mem_out, bus_w;
	wire [7:0] cu_flags, cu_flags3, cu_flags4;
	wire [5:0] op_code, op_code_buf;
	wire [31:0] out;
	wire call;
	
	assign resault_1 = inst_buff_data;
	assign resault_2 = call;
	assign resault_3 = reg_w;
	assign resault_4 = rd_buf3;
	assign resault_5 = rd_buf4;
	assign resault_6 = rw;
	
	 
	
	//  IF(branch, jr, jump, pc_src, stall, clk, clear, kill, inst_buff_data, pc_buff_tun,add_rd, add_imm, turn_off);
	IF if1 (call, branch, jr, jump, pc_src, stall, clk, clear, kill, inst_buff_data, pc_buff_tun, add_rd, add_imm, turn_off, pc_out);
		
//module decode(stall, clk, clear, inst_buff_data, pc_buff_tun, add_rd, add_imm, turn_off, pc_src, branch, jump, jr, rw, reg_w, fwa, fwb, bus_w, alu_fw, mem_fw, kill, cu_flags, imm_buf, bus_a, bus_b, rd_buf, rb);
	decode DC1 (pc_out, stall, clk, clear, inst_buff_data, pc_buff_tun, add_rd, add_imm, turn_off, pc_src, branch, jump, jr, rw, reg_w, fwa, fwb, bus_w, alu_out, mem_out, kill, cu_flags, imm_buf, bus_a, bus_b, rd_buf2, rb, rs, alu_op, op_code, reg_dst_out, call);
	
// module execute(clk, clear, stall, turn_off, alu_op, imm, bus_a, bus_b, rd_buf2, cu_flags, bus_b_buff, alu_out, rd_buf3, cu_flags3, reg_wr2);
	execute exc1 (clk, clear, turn_off, alu_op, imm_buf, bus_a, bus_b, rd_buf2, cu_flags, bus_b_buff, alu_out, rd_buf3, cu_flags3, reg_wr2);
	
// module mem(clk, clear, turn_off, alu_out, bus_b_buff, rd_buf3, cu_flags3, mem_out, rd_buf4, cu_flags4, reg_wr3);
	mem M1 (clk, clear, turn_off, alu_out, bus_b_buff, rd_buf3, cu_flags3, mem_out, rd_buf4, cu_flags4, reg_wr3, out);
	
// module write_back(turn_off, mem_out, rd_buf4, cu_flags4, rw, bus_w, reg_w);
    write_back wb (clk, clear, turn_off, mem_out, rd_buf4, cu_flags4, rw, bus_w, reg_w);
	
	register #(6) r1(op_code, ~turn_off, clk, clear, op_code_buf);
	
// module forward_and_stall(rs, rd2, rd3, rd4, rt, rw2, rw3,  rw4, op_code, stall, fwb, fwa);
	forward_and_stall fas(rs, rd_buf3, rd_buf4, rw, rb, reg_wr2, reg_wr3, reg_w, op_code_buf, stall_before, fwb, fwa);
	assign stall = stall_before & (~turn_off);
	
	
endmodule

module test_decode;
	
	reg clk, clear;
	wire signed [31:0] resault_1, resault_2, resault_3, resault_4, resault_5, resault_6;

	data_path dp1(clk, clear, resault_1, resault_2, resault_3, resault_4, resault_5, resault_6);
	
	
	initial begin
		#10 clk = 0;
		repeat (1000)
			#10 clk = ~clk;
	end
	
	initial begin
		
		// { stall, clk, clear, reg_w, fwa, fwb, bus_w, mem_fw, rw} = 0; 
		#1 $display("FWA: %h FWB: %d, BUS_A %d, BUS_B: %d, ALU_OUT %d , DATA: %d", resault_1, resault_2, resault_3, resault_4, resault_5, resault_6);
		
		
	end
	
	always @(posedge clk) begin
		#1 $display("FWA: %h FWB: %d, BUS_A %d, BUS_B: %d, ALU_OUT %d , DATA: %d", resault_1, resault_2, resault_3, resault_4, resault_5, resault_6);
	end
	
endmodule
