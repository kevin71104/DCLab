module supersonic#(
    parameter DisLen = 26,
	 parameter TotLen = DisLen + 1
)
(
    input             clk,
    input             rst_n,
    input             trigger,   // keep high for at least 10 us
    input             echo,      // after triggered, it will send 8 pulse and raise
                                 // high 'echo'
    output            valid,
    output            triggerSuc,
    output [DisLen:0] distance,  // number of cycles
	output            fail,	     // no detection -> need re-trigger
	
	// testing
	output            superState
);

// a clock cycle is 20 ns
// After every detection, keep 50 ms spacing for prevention of interference

//==== wire/reg definition ================================
    // Output
    reg  [DisLen:0] distance_cur;
    reg  [DisLen:0] distance_nxt;
    reg  valid_cur;
    reg  valid_nxt;
	reg  triggerSuc_cur;
    reg  triggerSuc_nxt;
	reg  fail_cur;
	reg  fail_nxt;

    reg  state_cur;  // after trigger high for 500 cycle
    reg  state_nxt;
    reg  prev_echo_cur;
    wire prev_echo_nxt;  
    
//==== combinational circuit
    // output
    assign valid      = valid_cur;
    assign distance   = distance_cur;
    assign triggerSuc = triggerSuc_cur;
	assign fail       = fail_cur;
	// testing
	assign superState = state_cur;
	
	assign prev_echo_nxt = echo;

    always @ ( * ) begin
        distance_nxt    = distance_cur;
        state_nxt       = state_cur;
        valid_nxt       = 1'b0;
        triggerSuc_nxt  = 1'b0;
		  fail_nxt        = 1'b0;
        case (state_cur)
            1'b0: begin
                //if (prev_echo_cur ^ echo && echo)begin
				if (echo)begin
                    state_nxt       = 1'b1;
                    distance_nxt    = {TotLen{1'b0}};
                    triggerSuc_nxt  = 1'b1;
                end
                else begin
                    state_nxt       = state_cur;
                    distance_nxt    = {TotLen{1'b0}};
                    triggerSuc_nxt  = 1'b0;
                end
            end
            1'b1: begin
                triggerSuc_nxt = 1'b0;
                if (distance_cur != {TotLen{1'b1}})begin
					distance_nxt= distance_cur + {{DisLen{1'b0}},1'b1};
					fail_nxt    = 1'b0; 
                    if (/*(prev_echo_cur ^ echo ) &&*/ ~echo)begin
                        state_nxt   = 1'b0;
                        valid_nxt   = 1'b1;
                    end
                    else begin
                        state_nxt   = 1'b1;
                        valid_nxt   = 1'b0;
                    end
                end
                else begin
					fail_nxt    = 1'b1; 
                    distance_nxt= {TotLen{1'b0}};
                    state_nxt   = 1'b0;
                    valid_nxt   = 1'b0;
                end
            end
        endcase
    end

//============= Sequential circuit ===============
    always @(posedge clk or negedge rst_n) begin
        // asynchronous reset
        if (~rst_n) begin
			   prev_echo_cur  <= 1'b0;
            state_cur      <= 1'b0;
            valid_cur      <= 1'b0;
            distance_cur   <= {TotLen{1'b0}};
            triggerSuc_cur <= 1'b0;
			   fail_cur       <= 1'b0;
        end
        else begin
			   prev_echo_cur  <= prev_echo_nxt;
            state_cur      <= state_nxt;
            valid_cur      <= valid_nxt;
            distance_cur   <= distance_nxt;
            triggerSuc_cur <= triggerSuc_nxt;
			   fail_cur       <= fail_nxt;
        end
    end

endmodule
