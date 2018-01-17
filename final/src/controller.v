module controller#(
    parameter DisLen = 16,
	parameter TotLen = DisLen + 1
)
(
    input        clk,
    input        rst_n,
    input        start,
    input        pause,      // after 2 pauses will start again
    input  [4:0] slice_num,  // number of pieces (power of 2)

    // I/O with supersonic
    input            valid,
	 input            fail,   // not receive valid -> re-trigger
    input unsigned [DisLen:0] distance,
    input            triggerSuc,
    output           trigger,    // hold high for at least 10 us (500 cycles)

    // I/O with Move Controller
    output       move,
    output       back,

    // I/O with Cut controller
    input        cut_end,
    output       cut,

    output       finish,
	 
	 //for testing !!!!!!!!!!
	 output	[3:0]  state_o,
	 output  [11:0] stable_cnt_o,
	 output  [DisLen:0] location_o,
	 output  smallornot_o
);

//==== Parameter declaration ============================
    localparam IDLE     = 4'd0;
    localparam INIT_TRI = 4'd1;
    localparam INIT_MEA = 4'd2;
    localparam TRIGGER  = 4'd3;
    localparam MEASURE  = 4'd4;
    localparam CUT      = 4'd5;
    localparam PAUSE    = 4'd6;
    localparam BACK_TRI = 4'd7;
    localparam BACK     = 4'd8;

//==== wire/reg declaration =============================
    // Output registers
    reg trigger_cur;
    reg trigger_nxt;
    reg move_cur;
    reg move_nxt;
    reg cut_cur;
    reg cut_nxt;
    reg finish_cur;
    reg finish_nxt;
    reg back_cur;
    reg back_nxt;

    // FSM
    reg  [3:0] state_cur;
    reg  [3:0] state_nxt;
    reg  [3:0] stateTem_cur;  // temporarily stored state for restoration from PAUSE
    reg  [3:0] stateTem_nxt;

    // DISTANCE-RELATED
    reg unsigned [DisLen:0] length_cur;
    reg unsigned [DisLen:0] length_nxt;
    reg unsigned [DisLen:0] segment_cur;
    reg unsigned [DisLen:0] segment_nxt;
    reg unsigned [DisLen:0] location_cur;  // location of start point
    reg unsigned [DisLen:0] location_nxt;

    // CUT-counter
    reg  [4:0] counter;
    reg  [4:0] counter_nxt;
	
	 // Stable-counter : keep at least 50ms spacing -> 2500 cycles
	 reg [11:0] stable_counter;
    reg [11:0] stable_counter_nxt;

//==== combinational circuit ============================

    // for testing!!!!!!!!!!!!!!!!!1
	 assign state_o = state_cur;
	 assign stable_cnt_o = stable_counter;
	 assign location_o = location_cur;
	 assign smallornot_o = (distance < (location_cur - segment_cur));


    assign trigger = trigger_cur;
    assign move = move_cur;
    assign cut = cut_cur;
    assign finish = finish_cur;
    assign back = back_cur;

    // FSM
    always @ ( * ) begin
        state_nxt    = state_cur;
        stateTem_nxt = stateTem_cur;
        move_nxt     = 1'b0;
        cut_nxt      = 1'b0;
        length_nxt   = length_cur;
        location_nxt = location_cur;
        counter_nxt  = counter;
        finish_nxt   = 1'b0;
        back_nxt     = 1'b0;
        case(state_cur)
            IDLE: begin
                if(pause) begin
                    state_nxt = PAUSE;
                    stateTem_nxt = IDLE;
                end
                else begin
                    stateTem_nxt = stateTem_cur;
                    if(start) begin
                        state_nxt = INIT_TRI;
                    end
                    else begin
                        state_nxt = IDLE;
                    end
                end
            end
            INIT_TRI: begin
                if (pause) begin
                    state_nxt = PAUSE;
                    stateTem_nxt = INIT_TRI;
                end
                else begin
                    stateTem_nxt = stateTem_cur;
                    if(triggerSuc) begin
                        state_nxt = INIT_MEA;
                    end
                    else begin
                        state_nxt = INIT_TRI;
                    end
                end
            end
            INIT_MEA: begin
                if (pause) begin
                    state_nxt = PAUSE;
                    stateTem_nxt = INIT_TRI;
                    length_nxt = length_cur;
                    location_nxt = location_cur;
                end
                else begin
                    stateTem_nxt = stateTem_cur;
					     if (fail) begin
						      state_nxt = INIT_TRI;
                        length_nxt = length_cur;
                        location_nxt = location_cur;
					     end
                    else if(valid) begin
                        state_nxt = TRIGGER;
                        length_nxt = distance;
                        // WARNING : CRITICAL PATH !!!!!!!!!!!!!!
                        //segment_nxt = distance / slice_num;
                        location_nxt = distance;
                    end
                    else begin
                        state_nxt = INIT_MEA;
                        length_nxt = length_cur;
                        location_nxt = location_cur;
                    end
                end
            end
            TRIGGER: begin
                if (pause) begin
                    state_nxt = PAUSE;
                    stateTem_nxt = TRIGGER;
                    move_nxt = 1'b0;
                end
                else begin
                    stateTem_nxt = stateTem_cur;
                    if(triggerSuc) begin
                        state_nxt = MEASURE;
                        move_nxt = 1'b1;
                    end
                    else begin
                        state_nxt = TRIGGER;
                        move_nxt = 1'b0;
                    end
                end
            end
            MEASURE: begin
                if (pause) begin
                    state_nxt = PAUSE;
                    stateTem_nxt = TRIGGER;
                    move_nxt = 1'b0;
                    cut_nxt = 1'b0;
                    counter_nxt = counter;
                end
                else begin
                    stateTem_nxt = stateTem_cur;
					     if (fail) begin
						      move_nxt = 1'b0;
                        cut_nxt = 1'b0;
                        state_nxt = TRIGGER;
                        counter_nxt = counter;
					     end
                    else if(valid) begin
						      move_nxt = 1'b0;
                        if( distance < (location_cur - segment_cur))begin
                            // GO TO CUT
                            cut_nxt = 1'b1;
                            state_nxt = CUT;
                            counter_nxt = counter + 5'd1;
                        end
                        else begin
                            cut_nxt = 1'b0;
                            state_nxt = TRIGGER;
                            counter_nxt = counter;
                        end
                    end
                    else begin
                        move_nxt = 1'b1;
                        cut_nxt = 1'b0;
                        state_nxt = MEASURE;
                        counter_nxt = counter;
                    end
                end
            end
            CUT: begin
                if (pause) begin
                    state_nxt = PAUSE;
                    stateTem_nxt = CUT;
                    cut_nxt = 1'b0;
                    counter_nxt = counter;
                    location_nxt = location_cur;
                end
                else begin
                    stateTem_nxt = stateTem_cur;
                    if(cut_end) begin
                        cut_nxt = 1'b0;
                        location_nxt = location_cur - segment_cur;
                        if(counter == slice_num - 1) begin
                            state_nxt = BACK_TRI;
                            counter_nxt = 5'd0;
                        end
                        else begin
                            state_nxt = TRIGGER;
                            counter_nxt = counter;
                        end
                    end
                    else begin
                        state_nxt = CUT;
                        cut_nxt = 1'b1;
                        counter_nxt = counter;
                        location_nxt = location_cur;
                    end
                end
            end
            PAUSE: begin
                if(pause) begin
                    state_nxt = stateTem_cur;
                end
                else begin
                    state_nxt = PAUSE;
                end
            end
            BACK_TRI: begin
                if (pause) begin
                    state_nxt = PAUSE;
                    stateTem_nxt = BACK_TRI;
                    move_nxt = 1'b0;
                    back_nxt = 1'b0;
                end
                else begin
                    stateTem_nxt = stateTem_cur;
                    if(triggerSuc) begin
                        state_nxt = BACK;
                        move_nxt = 1'b1;
                        back_nxt = 1'b1;
                    end
                    else begin
                        state_nxt = BACK_TRI;
                        move_nxt = 1'b0;
                        back_nxt = 1'b0;
                    end
                end
            end
            BACK: begin
                if (pause) begin
                    state_nxt = PAUSE;
                    stateTem_nxt = BACK_TRI;
                    move_nxt = 1'b0;
                    back_nxt = 1'b0;
                    finish_nxt = 1'b0;
                end
                else begin
                    stateTem_nxt = stateTem_cur;
					if(fail) begin
						move_nxt = 1'b0;
                        state_nxt = BACK_TRI;
                        finish_nxt = 1'b0;
                        back_nxt = 1'b0;
					end
                    else if(valid) begin
						move_nxt = 1'b0;
						back_nxt = 1'b0;
                        if( distance >= length_cur)begin 
                            state_nxt = IDLE;
                            finish_nxt = 1'b1;
                        end
                        else begin
                            state_nxt = BACK_TRI;
                            finish_nxt = 1'b0;                          
                        end
                    end
                    else begin
                        move_nxt = 1'b1;
                        state_nxt = BACK;
                        finish_nxt = 1'b0;
                        back_nxt = 1'b1;
                    end
                end
            end
        endcase
    end
	 
	 
	 // trigger signal
    always @ ( * ) begin
        trigger_nxt = 1'b0;
        case(state_cur)
            INIT_TRI: begin
				if (pause) begin
					trigger_nxt = 1'b0;
				end
				else begin
					if (~triggerSuc) begin
						if(stable_counter >= 12'd2500) begin
					    	trigger_nxt = 1'b1;
					    end
						else begin
							trigger_nxt = 1'b0;
						end
					end
					else begin
						trigger_nxt = 1'b0;
					end
				end
            end
            TRIGGER: begin
                if (pause) begin
					trigger_nxt = 1'b0;
				end
				else begin
					if (~triggerSuc) begin
						if(stable_counter >= 12'd2500) begin
							trigger_nxt = 1'b1;
						end
						else begin
							trigger_nxt = 1'b0;
						end
					end
					else begin
						trigger_nxt = 1'b0;
					end
				end
            end
            BACK_TRI: begin
                if (pause) begin
					trigger_nxt = 1'b0;
				end
				else begin
					if (~triggerSuc) begin
						if(stable_counter >= 12'd2500) begin
							trigger_nxt = 1'b1;
						end
						else begin
							trigger_nxt = 1'b0;
						end
					end
					else begin
						trigger_nxt = 1'b0;
					end
				end
            end
				default: trigger_nxt = 1'b0;
        endcase
    end

    // segment_nxt
    always @ ( * ) begin
		if (pause) begin
		    segment_nxt = segment_cur;
		end
        else if(state_cur == INIT_MEA && valid) begin
            if (slice_num[4] == 1'b1)begin
                segment_nxt = {4'b0000,distance[DisLen:4]};
                end
            else if (slice_num[3] == 1'b1)begin
                segment_nxt = {3'b000,distance[DisLen:3]};
            end
            else if (slice_num[2] == 1'b1)begin
                segment_nxt = {2'b00,distance[DisLen:2]};
            end
            else if (slice_num[1] == 1'b1)begin
                segment_nxt = {1'b0,distance[DisLen:1]};
            end
			else begin
				segment_nxt = segment_cur;
			end
        end
        else begin
            segment_nxt = segment_cur;
        end
    end

	// stable_counter
	always @ ( * ) begin
	    stable_counter_nxt = 12'd0;
        case(state_cur)
            INIT_TRI: begin
                if (pause) begin
					     stable_counter_nxt = 12'd0;
				    end
				    else begin
					     if (~triggerSuc) begin
						      if(stable_counter < 12'd2500) begin
							       stable_counter_nxt = stable_counter + 12'd1;
						      end
						      else begin
                            stable_counter_nxt = 12'd2500;
						      end
					     end
					     else begin
						      stable_counter_nxt = 12'd0;
					     end
				    end
            end
            TRIGGER: begin
                if (pause) begin
					stable_counter_nxt = 12'd0;
				end
				else begin
					if (~triggerSuc) begin
						if(stable_counter < 12'd2500) begin
							stable_counter_nxt = stable_counter + 12'd1;
						end
						else begin
							stable_counter_nxt = 12'd2500;
						end
					end
					else begin
						stable_counter_nxt = 12'd0;
					end
				end
            end
            BACK_TRI: begin
               if (pause) begin
					stable_counter_nxt = 12'd0;
				end
				else begin
					if (~triggerSuc) begin
						if(stable_counter < 12'd2500) begin
							stable_counter_nxt = stable_counter + 12'd1;
						end
						else begin
							stable_counter_nxt = 12'd2500;
						end
					end
					else begin
						stable_counter_nxt = 12'd0;
					end
				end
            end
				default: stable_counter_nxt = 12'd0;
        endcase
	end

//==== synchronous circuit ==============================
    always @(posedge clk or negedge rst_n) begin
        // asynchronous reset
        if (~rst_n) begin
            trigger_cur    <= 1'b0;
            state_cur      <= 3'd0;
            stateTem_cur   <= 3'd0;
            move_cur       <= 1'b0;
            cut_cur        <= 1'b0;
				/*
            length_cur     <= {TotLen{1'b0}};
            segment_cur    <= {TotLen{1'b0}};
            location_cur   <= {TotLen{1'b0}};
				*/
				length_cur     <= 17'b0;
            segment_cur    <= 17'b0;
            location_cur   <= 17'b0;
            counter        <= 5'd0;
            finish_cur     <= 1'b0;
            back_cur       <= 1'b0;
			   stable_counter <= 12'd0;
        end
        else begin
            trigger_cur    <= trigger_nxt;
            state_cur      <= state_nxt;
            stateTem_cur   <= stateTem_nxt;
            move_cur       <= move_nxt;
            cut_cur        <= cut_nxt;
            length_cur     <= length_nxt;
            segment_cur    <= segment_nxt;
            location_cur   <= location_nxt;
            counter        <= counter_nxt;
            finish_cur     <= finish_nxt;
            back_cur       <= back_nxt;
			stable_counter <= stable_counter_nxt;
        end
    end

endmodule
