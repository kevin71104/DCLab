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
    wire [31:0] distance_nxt;
    reg         valid_cur;
    wire        valid_nxt;

    reg         state_cur;  // after trigger high for 500 cycle
    wire        state_nxt;
    reg  [ 8:0] counter;    // needs at least 500 cycles to trigger
    wire [ 8:0] counter_nxt;
//==== combinational circuit
    // output
    assign valid = valid_cur;
    assign distance = distance_cur;

    // distance
    assign distance_nxt = (state_cur & echo) ? distance_cur + 1 : 32'd0;
    assign valid_nxt = (~ echo & state_cur);

    // trigger part
    assign state_nxt = (counter == 9'd500) ? 1 : state_cur;
    assign counter_nxt = (counter == 9'd500 | ~ trigger) ? 9'd0 : counter + 1

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
