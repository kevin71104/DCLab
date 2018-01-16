module supersonic(
    input         clk,
    input         rst_n,
    input         trigger,  // keep high for at least 10 us
    input         echo,     // after triggered, it will send 8 pulse and raise
                            // high 'echo'
    output        valid,
    output        triggerSuc,
    output [31:0] distance  // number of cycles
);

// a clock cycle is 20 ns
// After every detection, keep 50 ms spacing for prevention of interference

//==== wire/reg definition ================================
    reg  [31:0] distance_cur;
    reg  [31:0] distance_nxt;
    reg         valid_cur;
    reg         valid_nxt;

    reg         state_cur;  // after trigger high for 500 cycle
    reg         state_nxt;
    reg  [ 8:0] counter;    // needs at least 500 cycles to trigger
    reg  [ 8:0] counter_nxt;
    reg         triggerSuc_cur;
    reg         triggerSuc_nxt;
    
//==== combinational circuit
    // output
    assign valid        = valid_cur;
    assign distance     = distance_cur;
    assign triggerSuc   = triggerSuc_cur;

    always @ ( * ) begin
        distance_nxt    = distance_cur;
        state_nxt       = state_cur;
        valid_nxt       = 1'b0;
        counter_nxt     = 9'd0;
        triggerSuc_nxt  = 1'b0;
        case (state_cur)
            1'b0: begin
                if (counter == 9'd500)begin
                    state_nxt       = 1'b1;
                    distance_nxt    = 32'd0;
                    triggerSuc_nxt  = 1'b1;
                end
                else begin
                    state_nxt       = state_cur;
                    distance_nxt    = distance_cur;
                    triggerSuc_nxt  = 1'b0;
                end

                if (counter == 9'd500 | ~trigger)begin
                    counter_nxt = 9'd0;
                end
                else begin
                    counter_nxt = counter + 1;
                end
            end
            1'b1: begin
                triggerSuc_nxt = 1'b0;
                if (distance_cur != 32'hFFFFFFFF)begin
                    if (echo)begin
                        distance_nxt= distance_cur + 1;
                        state_nxt   = state_cur;
                        valid_nxt   = 1'b0;
                    end
                    else begin
                        distance_nxt= distance_cur + 1;
                        state_nxt   = 1'b0;
                        valid_nxt   = 1'b1;
                    end
                end
                else begin
                    distance_nxt= 32'd0;
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
            counter        <=  9'b0;
            state_cur      <=  1'b0;
            valid_cur      <=  1'b0;
            distance_cur   <= 32'b0;
            triggerSuc_cur <= 1'b0;
        end
        else begin
            counter        <= counter_nxt;
            state_cur      <= state_nxt;
            valid_cur      <= valid_nxt;
            distance_cur   <= distance_nxt;
            triggerSuc_cur <= triggerSuc_nxt;
        end
    end

endmodule
