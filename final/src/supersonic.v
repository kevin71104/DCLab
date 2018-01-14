module supersonic(clk, rst_n, valid, echo, trigger, distance);
// a clock cycle is 20 ns
// After every detection, keep 50 ms spacing for prevention of interference

//==== input/output definition ============================
    input         clk;
    input         rst_n;
    input         trigger;  // keep high for at least 10 us
    input         echo;     // after triggered, it will send 8 pulse and raise
                            // high 'echo'
    output        valid;
    output [31:0] distance; // number of cycles
//==== wire/reg definition ================================
    reg  [31:0] distance_cur;
    reg  [31:0] distance_nxt;
    reg         valid_cur;
    wire        valid_nxt;

    reg         state_cur;  // after trigger high for 500 cycle
    reg         state_nxt;
    reg  [ 8:0] counter;    // needs at least 500 cycles to trigger
    reg  [ 8:0] counter_nxt;
//==== combinational circuit
    // output
    assign valid = valid_cur;
    assign distance = distance_cur;

    // distance
    assign valid_nxt = (~ echo & state_cur);

    // trigger part

    always @ ( * ) begin
        distance_nxt = distance_cur;
        state_nxt = state_cur;
        case (state_cur)
            1'b0: begin
                if (counter == 9'd500)begin
                    state_nxt = 1'b1;
                    distance_nxt = 32'd0;
                end
                else begin
                    state_nxt = state_cur;
                    distance_nxt = distance_cur;
                end

                if (counter == 9'd500 | ~ trigger)begin
                    counter_nxt = 9'd0;
                end
                else begin
                    counter_nxt = counter + 1;
                end
            end
            1'b1: begin
                if (echo)begin
                    distance_nxt = distance_cur + 1;
                    state_nxt = state_cur;
                end
                else begin
                    distance_nxt = distance_cur + 1;
                    state_nxt = 1'b0;
                end
            end
        endcase
    end

//==== synchronous circuit
    always @(posedge clk or negedge rst_n) begin
        // asynchronous reset
        if (~rst_n) begin
            counter      <=  9'b0;
            state_cur    <=  1'b0;
            valid_cur    <=  1'b0;
            distance_cur <= 32'b0;
        end
        else begin
            counter      <= counter_nxt;
            state_cur    <= state_nxt;
            valid_cur    <= valid_nxt;
            distance_cur <= distance_nxt;
        end
    end


endmodule
