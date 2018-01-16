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
	output logic [6:0]  HEX7_o,
    
    
    // for testing HSCR04
    input     [31:0]   distance_i
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
	
	localparam IDLE = 2'd0;
	localparam GO   = 2'd1;
	localparam PAUSE= 2'd2;
	localparam DONE = 2'd3;
	
	logic [1:0] state, nxt_state;	

    logic [6:0] HEX0, nxt_HEX0;
    logic [6:0] HEX1, nxt_HEX1;
    logic [6:0] HEX2, nxt_HEX2;
    logic [6:0] HEX3, nxt_HEX3;
    logic [6:0] HEX4, nxt_HEX4;
    
	
//=========== FSM ====================
	always_ff@(posedge clk or negedge rst_n) begin
		if(!rst_n)
			state <= IDLE;
		else
			state <= nxt_state;
	end
	
	always_comb begin
		case(state)
			IDLE: begin
				if(start_i)
					nxt_state = GO;
				else
					nxt_state = IDLE;
			end
			GO: begin
				if(pause_i)
					nxt_state = PAUSE;
				else
				if(finish_i)
					nxt_state = DONE;
				else
					nxt_state = GO;			
			end
			PAUSE: begin
				if(pause_i)
					nxt_state = GO;
				else
					nxt_state = PAUSE;			
			end
			DONE: begin
					nxt_state = DONE;			
			end
			default: nxt_state = state;	
		endcase
	end

	always_comb begin
		// case(slice_num_i)
        case(distance_i[15:11])
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
        if(state == PAUSE) begin // PAUSE
            nxt_HEX0 = 7'b0000110;
            nxt_HEX1 = 7'b0010010;
            nxt_HEX2 = 7'b1000001;
            nxt_HEX3 = 7'b0001000;
            nxt_HEX4 = 7'b0001100;
        end
        else
        if(state == GO) begin // GO, press pause twice
            nxt_HEX0 = D0;
            nxt_HEX1 = D6;
            nxt_HEX2 = DARK;
            nxt_HEX3 = DARK;
            nxt_HEX4 = DARK;
        
        end
        else 
        if(state == DONE) begin //donE
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
		end else begin
			HEX0 <= nxt_HEX0;
			HEX1 <= nxt_HEX1;
			HEX2 <= nxt_HEX2;
			HEX3 <= nxt_HEX3;
			HEX4 <= nxt_HEX4;
		end
	end
    
endmodule
