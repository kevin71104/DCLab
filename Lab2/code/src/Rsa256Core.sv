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
	// I/O of main module
	logic [255:0] a_cur, a_nxt, e_cur, e_nxt, n_cur, n_nxt;
	logic         src_val_cur, src_val_nxt, result_rdy_cur, result_rdy_nxt;
	logic         src_rdy_cur, src_rdy_nxt, result_val_cur, result_val_nxt;
	logic [255:0] ans_cur, ans_nxt;

	// I/O of sub-modules (block sub-module input)
	logic         mp_start_cur, mp_start_nxt;
	logic         mp_finish;
	logic [255:0] mp_result, t_cur, t_nxt;

	logic         mont_start_c_cur, mont_start_c_nxt;
	logic         mont_start_s_cur, mont_start_s_nxt;
	logic [255:0] mont_a_c_cur, mont_a_c_nxt, mont_a_s_cur, mont_a_s_nxt;
	logic [255:0] mont_b_c_cur, mont_b_c_nxt;
	logic         mont_finish_c, mont_finish_s;
	logic [255:0] mont_result_c, mont_result_s;

	// Others
	enum  {IDLE, MP, MONT, CHECK} state_cur, state_nxt;
	logic [  7:0] counter_cur, counter_nxt;
	logic [  1:0] status_cur, status_nxt; // record the status of 2 mont modules

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

//==== Combinational Part ======================================================
	assign o_a_pow_e = ans_r;
	always_comb begin
		// Default Value
		a_nxt = a_cur;
		e_nxt = e_cur;
		n_nxt = n_cur;
		src_val_nxt = src_val_cur;
		result_rdy_nxt = result_rdy_cur;
		src_rdy_nxt = src_rdy_cur;
		result_val_nxt = result_val_cur;
		ans_nxt = ans_cur;
		mp_start_cur <= mp_start_nxt;
		t_nxt = t_cur;
		mont_start_c_nxt = mont_start_c_cur;
		mont_start_s_nxt = mont_start_s_cur;
		mont_a_c_nxt = mont_a_c_cur;
		mont_a_s_nxt = mont_a_s_cur;
		mont_b_c_nxt = mont_b_c_cur;
		state_nxt = state_cur;
		counter_nxt = counter_cur;
		status_nxt = status_cur;
		// FSM
		case(state_r)
			IDLE: begin
				if(src_val_cur == 1)begin
					state_nxt = MP;
					a_nxt = i_a;
					e_nxt = i_e;
					n_nxt = i_n;
					src_rdy_nxt = 1;
					mp_start_nxt = 1;
				end
				else begin
					state_nxt = IDLE;
					src_val_nxt = src_val;
				end
			end
			MP: begin
				mp_start_nxt = 0;
				if(mp_finish == 1) begin
					state_nxt = MONT;
					t_nxt = mp_result;
					if(e_cur[0] == 1)begin
						mont_start_c_nxt = 1;
						mont_a_c_nxt = 1; // m = 1
						mont_b_c_nxt = mp_result;
						status_nxt = 2'b00;
					end
					else begin
						status_nxt = 2'b01;
					end
					mont_start_s_nxt = 1;
					mont_a_s_nxt = mp_result;
				end
			end
			MONT: begin
				mont_start_s_nxt = 0;
				mont_start_c_nxt = 0;
				if(mont_finish_c)begin

				end
				if(mont_finish_s)begin
				end
			end
		endcase
	end
//==== Synchronous Part ========================================================
	always_ff @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
			a_cur <= 0;
			e_cur <= 0;
			n_cur <= 0;
			src_val_cur <= 0;
			result_rdy_cur <= 0;
			src_rdy_cur <= 0;
			result_val_cur <= 0;
			ans_cur <= 0;
			mp_start_cur <= 0;
			t_cur <= 0;
			mont_start_c_cur <= 0;
			mont_start_s_cur <= 0;
			mont_a_c_cur <= 0;
			mont_a_s_cur <= 0;
			mont_b_c_cur <= 0;
			state_cur <= IDLE;
			counter_cur <= 0;
			status_cur <= 0;
        end
		else begin
			a_cur <= a_nxt;
			e_cur <= e_nxt;
			n_cur <= n_nxt;
			src_val_cur <= src_val_nxt;
			result_rdy_cur <= result_rdy_nxt;
			src_rdy_cur <= src_rdy_nxt;
			result_val_cur <= result_val_nxt;
			ans_cur <= ans_nxt;
			mp_start_cur <= mp_start_nxt;
			t_cur <= t_nxt;
			mont_start_c_cur <= mont_start_c_nxt;
			mont_start_s_cur <= mont_start_s_nxt;
			mont_a_c_cur <= mont_a_c_nxt;
			mont_a_s_cur <= mont_a_s_nxt;
			mont_b_c_cur <= mont_b_c_nxt;
			state_cur <= state_nxt;
			counter_cur <= counter_nxt;
			status_cur <= status_nxt;
        end
    end
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
	assign o_result = m_cur[255:0];
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
				if(i_start == 1) begin
					state_nxt = RUN;
					m_nxt = 0;       // Init
					t_nxt = i_b;     // Init
					counter_nxt = 0; // Init
				end
			end
			RUN: begin
				if(i_a[counter_cur] == 1) begin
					if(m_cur + t_cur >= i_n)begin
						m_nxt = m_cur + t_cur - i_n;
					end
					else begin
						m_nxt = m_cur + t_cur;
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

module Montgometry(
	input         i_clk,
	input         i_rst,
	input         i_start,
	input [255:0] i_n,
	input [255:0] i_a,
	input [255:0] i_b,
	output logic [255:0] o_result,
	output logic         o_finish
);

//==== logic declaration =======================================================
	logic                   finish_cur, finish_nxt;  // block output
	logic [255:0]           m_cur, m_nxt;	         // block output
	enum  {IDLE, RUN, DONE} state_cur, state_nxt;
	logic [  7:0]           counter_cur, counter_nxt;
	logic [255:0]           a_cur, a_nxt, b_cur, b_nxt, n_cur, n_nxt;
	logic [255:0]           m_tmp, m_EvenOdd, m_half;
//==== Combinational Part ======================================================
	assign o_finish = finish_cur;
	assign o_result = m_cur;
	assign m_tmp = a_cur[0] ? m_cur + b_cur : m_cur;
	assign m_EvenOdd = m_tmp[0] ? m_EvenOdd + n_cur : m_EvenOdd;
	assign m_half = m_EvenOdd >> 1;
	always_comb begin
		// Default Value
		finish_nxt = finish_cur;
		m_nxt = m_cur;
		a_nxt = a_cur;
		b_nxt = b_cur;
		n_nxt = n_cur;
		state_nxt = state_cur;
		counter_nxt = counter_cur;

		// FSM
		case(state_r)
			IDLE: begin
				if(i_start == 1) begin
					state_nxt = RUN;
					a_nxt = i_a;
					b_nxt = i_b;
					n_nxt = i_n;
					m_nxt = 0;       // Init
					counter_nxt = 0; // Init
				end
			end
			RUN: begin
				m_nxt = m_half;
				a_nxt = a_cur >> 1;
				if(counter_cur == 255)begin
					if(m_half >= n_cur)begin
						m_nxt = m_half - n_cur;
					end
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
			a_cur       <= 0;
			b_cur       <= 0;
			n_cur       <= 0;
            state_cur   <= IDLE;
            counter_cur <= 0;
        end
		else begin
			finish_cur  <= finish_nxt;
			m_cur       <= m_nxt;
			a_cur       <= a_nxt;
			b_cur       <= b_nxt;
			n_cur       <= n_nxt;
            state_cur   <= state_nxt;
            counter_cur <= counter_nxt;
        end
    end

endmodule
