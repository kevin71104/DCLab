module Rsa256Core(
	input i_clk,
	input i_rst,
	input         src_val,             // a, e, n valid
	output logic  src_rdy,             // get a, e, n
	input [255:0] i_a,
	input [255:0] i_e,
	input [255:0] i_n,
	output logic         result_val,   // result valid
	input                result_rdy,   // wrapper get result
	output logic [255:0] o_a_pow_e     // decode answer
    );
//==== logic declaration =======================================================
	logic [255:0] a_cur, a_nxt, e_cur, e_nxt, n_cur, n_nxt;
	logic         src_rdy_cur, src_rdy_nxt, result_val_cur, result_val_nxt;
	logic [255:0] ans_cur, ans_nxt;

	// I/O for sub-modules (block sub-module input)
	logic         mp_start_cur, mp_start_nxt;
	logic         mp_finish;
	logic [255:0] mp_result;

	logic         mont_start_c_cur, mont_start_c_nxt;
	logic         mont_start_s_cur, mont_start_s_nxt;
	logic         mont_finish_c, mont_finish_s;
	logic [255:0] mont_a_c_cur, mont_a_c_nxt, mont_a_s_cur, mont_a_s_nxt;
	logic [255:0] mont_b_c_cur, mont_b_c_nxt;
	logic [255:0] mont_result_c, mont_result_s;
//==== sub-modules =============================================================
	ModuloProduct i_mp(
	    .i_clk(i_clk),
	    .i_rst(i_rst),
	    .i_start(mp_start_cur),
	    .i_n({1'b0,n_cur}),        // since b = 2^256, a,b,n become 257 bits
	    .i_a({1'b0,a_cur}),
	    .i_b({1'b1,{256{1'b0}}}),  // b = 2^256
	    .o_result(mp_result),
	    .o_finish(mp_finish)
	);
	Montgometry i_mg_cross(
		.i_clk(i_clk),
	    .i_rst(i_rst),
	    .i_start(mont_start_c_cur),
	    .i_n(n_cur),
	    .i_a(mont_a_c_cur),
	    .i_b(mont_b_c_cur),
	    .o_result(mont_result_c),
	    .o_finish(mont_finish_c)
	);
	Montgometry i_mg_self(
		.i_clk(i_clk),
	    .i_rst(i_rst),
	    .i_start(mont_start_s_cur),
	    .i_n(n_cur),
	    .i_a(mont_a_s_cur),
	    .i_b(mont_a_s_cur),
	    .o_result(mont_result_s),
	    .o_finish(mont_finish_s)
	);
);
endmodule

module ModuloProduct(
	input         i_clk,
	input         i_rst,
	input         i_start,
	input [256:0] i_n,       // since b = 2^256, a,b,n become 257 bits
	input [256:0] i_a,
	input [256:0] i_b,       // b = 2^256
	output logic [255:0] o_result,
	output logic         o_finish
);

//==== logic declaration =======================================================
	logic                   finish_cur, finish_nxt;  // block output
	logic [256:0]           m_cur, m_nxt;	         // block output
	enum  {IDLE, RUN, DONE} state_cur, state_nxt;
	logic [  8:0]           counter_cur, counter_nxt;
	logic [256:0]           t_cur, t_nxt;
//==== Combinational Part ======================================================
	assign o_result = m_r[255:0];
	assign o_finish = finish_cur;
	always_comb begin
		// default value
		finish_nxt  = finish_cur;
		state_nxt   = state_cur;
		counter_nxt = counter_cur;
		t_nxt       = t_cur;
		m_nxt       = m_cur;
		// FSM
		case(state_r)
			IDLE: begin
				if(i_start) begin
					state_nxt = RUN;
					m_nxt = 0;       // Init
					t_nxt = i_b;     // Init
					counter_nxt = 0; // Init
				end
			end
			RUN: begin
				if(i_a[counter_cur] == 1) begin
					if(m_cur + t_cur; >= i_n)begin
						m_nxt = m_cur + t_cur; - i_n;
					end
					else begin
						m_nxt = m_cur + t_cur;;
					end
				end

				if((t_cur << 1) >= i_n)begin
					t_nxt = (t_cur << 1) - i_n;
				end
				else begin
					t_nxt = t_cur << 1;
				end

				if(counter_cur == 256)begin
					state_nxt = DONE;
					finish_nxt = 1;
				end
				else begin
					counter_nxt = counter_cur + 1;
				end
			end
			DONE: begin
				state_nxt = IDLE;
				finish_nxt = 0;
			end
		endcase
	end

//==== Synchronous Part ========================================================
	always_ff @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
			finish_cur  <= 0;
			m_cur       <= 0;
            state_cur   <= IDLE;
            counter_cur <= 0;
			t_cur       <= 0;
        end
		else begin
			finish_cur  <= finish_nxt;
			m_cur       <= m_nxt;
            state_cur   <= state_nxt;
            counter_cur <= counter_nxt;
			t_cur       <= t_nxt;
        end
    end
	
endmodule
