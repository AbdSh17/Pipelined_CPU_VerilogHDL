module forward_and_stall(rs, rd2, rd3, rd4, rt, rw2, rw3, rw4, op_code, stall, fwb, fwa);
	input [3:0] rs, rd2, rd3, rd4, rt;
	input rw2, rw3, rw4;
	input [5:0] op_code;
	
	output [1:0] fwa, fwb;
	output stall;
	
	wire null_wire;
	wire cmp_rs2, cmp_rs3, cmp_rs4, cmp_rt2, cmp_rt3, cmp_rt4;
	wire and_rs2, and_rs3, and_rs4, and_rt2, and_rt3, and_rt4;
	wire [1:0] rs_zero_buf, rs_one_buf, rs_two_buf, rs_three_buf;
	wire [1:0] rt_zero_buf, rt_one_buf, rt_two_buf, rt_three_buf;
	wire lw_op_code;

	// ===== CMP =====
	assign cmp_rs2 = (rs == rd2);
	assign cmp_rs3 = (rs == rd3);
	assign cmp_rs4 = (rs == rd4);
	
	assign cmp_rt2 = (rt == rd2);
	assign cmp_rt3 = (rt == rd3);
	assign cmp_rt4 = (rt == rd4);
	// ===== CMP =====
	
	// ===== AND =====
	assign and_rs2 = (cmp_rs2 & rw2);
	assign and_rs3 = (cmp_rs3 & rw3);
	assign and_rs4 = (cmp_rs4 & rw4);
	
	assign and_rt2 = (cmp_rt2 & rw2);
	assign and_rt3 = (cmp_rt3 & rw3);
	assign and_rt4 = (cmp_rt4 & rw4);
	// ===== AND =====
	
	// ===== BUF =====
	assign rs_zero_buf = (~(and_rs2 | and_rs3 | and_rs4)) ? 2'b00 : 2'b00;
	assign rs_one_buf = (and_rs2) ? 2'b01 : 2'b00;
	assign rs_two_buf = (~and_rs2 & and_rs3) ? 2'b10 : 2'b00;
	assign rs_three_buf = (~and_rs2 & ~and_rs3 & and_rs4) ? 2'b11 : 2'b00;
	
	assign rt_zero_buf = (~(and_rt2 | and_rt3 | and_rt4)) ? 2'b00 : 2'b00;
	assign rt_one_buf = (and_rt2) ? 2'b01 : 2'b00;
	assign rt_two_buf = (~and_rt2 & and_rt3) ? 2'b10 : 2'b00;
	assign rt_three_buf = (~and_rt2 & ~and_rt3 & and_rt4) ? 2'b11 : 2'b00;
	// ===== BUF =====
	
	// ===== FW =====
	assign fwa = rs_three_buf | rs_one_buf | rs_two_buf | rs_zero_buf;
	assign fwb = rt_three_buf | rt_one_buf | rt_two_buf | rt_zero_buf;
	// ===== FW =====
	
	assign lw_op_code = (op_code == 'd6 | op_code == 'd8);
	assign stall = (lw_op_code & and_rs2) | (lw_op_code & and_rt2);
		
endmodule

module test_forward_and_stall;
	wire [1:0] fwa, fwb; wire stall;
	
	reg [3:0] rs, rd2, rd3, rd4, rt;
	reg rw2, rw3, rw4;
	reg [5:0] op_code;
	
	forward_and_stall fas(rs, rd2, rd3, rd4, rt, rw2, rw3, rw4, op_code, stall, fwb, fwa);
	
	initial begin
		
		{rs, rd2, rd3, rd4, rt, rw2, rw3, rw4, op_code} = 0;
		
		#10	 // 10
		rw2 = 1; rw3 = 1; // fwa: 01, fwb: 01
		
		#10	 // 20
		rw2 = 0; // fwa: 10, fwb: 10  (rw3 is on)
		
		#10	 // 30
		rt = 4'b0010; // fwa: 10, fwb: 00
		
		#10	// 40
		rd3 = 4'b0010; // fwa: 00, fwb: 10
		
		#10	// 50
		rs = 4'd3; rt = 4'd5;
		rd2 = 4'd1; rd3 = 4'd2; rd4 = 4'd6;
		rw2 = 1; rw3 = 1; rw4 = 1; // fwa: 00, fwb: 00
		
		#10	// 60
		rs = 4'd6; rt = 4'd5;
		rd2 = 4'd1; rd3 = 4'd2; rd4 = 4'd6;
		rw2 = 1; rw3 = 1; rw4 = 1; // fwa: 11, fwb: 00
		
		#10	// 70
		rs = 4'd2; rt = 4'd5;
		rd2 = 4'd1; rd3 = 4'd2; rd4 = 4'd2;
		rw2 = 0; rw3 = 1; rw4 = 1; // fwa: 10, fwb: 00
		
		#10 // 80
		rs = 4'd1; rt = 4'd5;
		rd2 = 4'd1; rd3 = 4'd2; rd4 = 4'd1;
		rw2 = 1; rw3 = 0; rw4 = 1;	// fwa: 01, fwb: 00
		
		#10	// 90
		rs = 4'd0; rt = 4'd3;
		rd2 = 4'd1; rd3 = 4'd3; rd4 = 4'd4;
		rw2 = 1; rw3 = 1; rw4 = 0; // fwa: 00, fwb: 10
		
		#10	// 100
		rs = 4'd2; rt = 4'd4;
		rd2 = 4'd7; rd3 = 4'd2; rd4 = 4'd4;
		rw2 = 0; rw3 = 1; rw4 = 1; // fwa: 10, fwb: 11 
		
		#10
		rs = 4'd3; rt = 4'd5;
		rd2 = 4'd5; rd3 = 4'd3; rd4 = 4'd3;
		rw2 = 1; rw3 = 0; rw4 = 0; // fwa: 00, fwb: 01
		
	end
	
	initial begin
		
		$monitor("Time: %d Rs: %d, Rt: %d, Rd2: %d, Rd3: %d, Rd4: %d, {Rw2, Rw3, Rw4}: %b\n FWA: %b, FWB: %b \n", $time, rs, rd2, rd3, rd4, rt, {rw2, rw3, rw4}, fwa, fwb);  
	
	end
	
endmodule