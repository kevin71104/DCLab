module SevenHexDecoder(
    input               clk,
    input               rst_n,
    input               start_i,
    input               pause_i,
	input [4:0]         slice_num_i, // 0~16
    input               finish_i,
    // GO / PAUSE / DONE
	output logic [6:0]  HEX0_o,
	output logic [6:0]  HEX1_o,
	output logic [6:0]  HEX2_o,
	output logic [6:0]  HEX3_o,
	output logic [6:0]  HEX4_o,
    // not used
	output logic [6:0]  HEX5_o,
    // 0~16
	output logic [6:0]  HEX6_o,
	output logic [6:0]  HEX7_o
);
	/* The layout of seven segment display, 1: dark
	 *    00
	 *   5  1
	 *    66
	 *   4  2
	 *    33
	 */
	localparam DARK = 7'b1111111;
    localparam D0   = 7'b1000000;
	localparam D1   = 7'b1111001;
	localparam D2   = 7'b0100100;
	localparam D3   = 7'b0110000;
	localparam D4   = 7'b0011001;
	localparam D5   = 7'b0010010;
	localparam D6   = 7'b0000010;
	localparam D7   = 7'b1011000;
	localparam D8   = 7'b0000000;
	localparam D9   = 7'b0010000;
	
	logic pre_pause;
	logic [2:0]cnt, nxt_cnt;
    
    logic [6:0] HEX0, nxt_HEX0;
    logic [6:0] HEX1, nxt_HEX1;
    logic [6:0] HEX2, nxt_HEX2;
    logic [6:0] HEX3, nxt_HEX3;
    logic [6:0] HEX4, nxt_HEX4;
    
	always_comb begin
		case(slice_num_i)
			5'd0: begin HEX7_o = D0; HEX6_o = D0; end
			5'd1: begin HEX7_o = D0; HEX6_o = D1; end
			5'd2: begin HEX7_o = D0; HEX6_o = D2; end
			5'd3: begin HEX7_o = D0; HEX6_o = D3; end
			5'd4: begin HEX7_o = D0; HEX6_o = D4; end
			5'd5: begin HEX7_o = D0; HEX6_o = D5; end
			5'd6: begin HEX7_o = D0; HEX6_o = D6; end
			5'd7: begin HEX7_o = D0; HEX6_o = D7; end
			5'd8: begin HEX7_o = D0; HEX6_o = D8; end
			5'd9: begin HEX7_o = D0; HEX6_o = D9; end
			5'd10: begin HEX7_o = D1; HEX6_o = D0; end
			5'd11: begin HEX7_o = D1; HEX6_o = D1; end
			5'd12: begin HEX7_o = D1; HEX6_o = D2; end
			5'd13: begin HEX7_o = D1; HEX6_o = D3; end
			5'd14: begin HEX7_o = D1; HEX6_o = D4; end
			5'd15: begin HEX7_o = D1; HEX6_o = D5; end
			5'd16: begin HEX7_o = D1; HEX6_o = D6; end
            default: begin HEX7_o = D0; HEX6_o = D0; end
		endcase
	end
    
    assign HEX0_o = HEX0;
    assign HEX1_o = HEX1;
    assign HEX2_o = HEX2;
    assign HEX3_o = HEX3;
    assign HEX4_o = HEX4;
    assign HEX5_o = DARK;
	 
	 always_comb begin
	   if(cnt == 3'd4)
			nxt_cnt = 0;
		if(pause_i ^ pre_pause)
			nxt_cnt = cnt + 1'b1;
		else
			nxt_cnt = cnt;
	 end
    
    always_comb begin
        if(pause_i && cnt == 0) begin // PAUSE
            nxt_HEX0 = 7'b0000110;
            nxt_HEX1 = 7'b0010010;
            nxt_HEX2 = 7'b1000001;
            nxt_HEX3 = 7'b0001000;
            nxt_HEX4 = 7'b0001100;
        end
        else
        if(start_i || (pause_i && cnt == 3'd2)) begin // GO, press pause twice
            nxt_HEX0 = D0;
            nxt_HEX1 = D6;
            nxt_HEX2 = DARK;
            nxt_HEX3 = DARK;
            nxt_HEX4 = DARK;
        
        end
        else 
        if(finish_i) begin //donE
            nxt_HEX0 = 7'b0000110;
            nxt_HEX1 = 7'b0101011;
            nxt_HEX2 = 7'b0100011;
            nxt_HEX3 = 7'b0100001;
            nxt_HEX4 = DARK;   
        end
        else begin
            nxt_HEX0 = HEX0;
            nxt_HEX1 = HEX1;
            nxt_HEX2 = HEX2;
            nxt_HEX3 = HEX3;
            nxt_HEX4 = HEX4;   
        end
	end
    
    always_ff @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin // RESET
			HEX0 <= 7'b1111000;
			HEX1 <= 7'b0000110;
			HEX2 <= 7'b0010010;
			HEX3 <= 7'b0000110;
			HEX4 <= 7'b0001000;
			pre_pause <= 0;
			cnt <= 0;
		end else begin
			HEX0 <= nxt_HEX0;
			HEX1 <= nxt_HEX1;
			HEX2 <= nxt_HEX2;
			HEX3 <= nxt_HEX3;
			HEX4 <= nxt_HEX4;
			pre_pause <= pause_i;
			cnt <= nxt_cnt;
		end
	end
    
endmodule
