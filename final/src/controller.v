module controller(clk, rst_n, start, pause, slice_num, valid, distance, trigger,
                  triggerSuc, move, cut, cut_end, finish);

//==== input/output declaration =========================
    input        clk;
    input        rst_n;
    input        start;
    input        pause;      // after 2 pauses will start again
    input  [4:0] slice_num;  // number of cut times

    // I/O with supersonic
    input        valid;
    input [31:0] distance;
    input        triggerSuc;
    output       trigger;    // hold high for at least 10 us (500 cycles)

    // I/O with Move Controller
    output       move;

    // I/O with Cut controller
    input        cut_end;
    output       cut;

    output       finish;

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

    // FSM
    reg  [3:0] state_cur;
    reg  [3:0] state_nxt;
    reg  [3:0] stateTem_cur;  // temporarily stored state for restoration from PAUSE
    reg  [3:0] stateTem_nxt;

    // DISTANCE-RELATED
    reg [31:0] length_cur;
    reg [31:0] length_nxt;
    reg [31:0] segment_cur;
    reg [31:0] segment_nxt;
    reg [31:0] location_cur;  // location of start point
    reg [31:0] location_nxt;

    // CUT-counter
    reg  [4:0] counter;
    reg  [4:0] counter_nxt;

//==== Parameter declaration ============================
    parameter IDLE     = 4'd0;
    parameter INIT_TRI = 4'd1;
    parameter INIT_MEA = 4'd2;
    parameter TRIGGER  = 4'd3;
    parameter MEASURE  = 4'd4;
    parameter CUT      = 4'd5;
    parameter PAUSE    = 4'd6;

//==== combinational circuit ============================
    assign trigger = trigger_cur;
    assign move = move_cur;
    assign cut = cut_cur;
    assign finish = finish_cur;

    // trigger signal
    always @ ( * ) begin
        trigger_nxt = 1'b0;
        case(state_cur)
            IDLE: begin
                if (start)begin
                    trigger_nxt = 1'b1;
                end
                else begin
                    trigger_nxt = 1'b0;
                end
            end
            INIT_TRI: begin
                if (~triggerSuc)begin
                    trigger_nxt = 1'b1;
                end
                else begin
                    trigger_nxt = 1'b0;
                end
            end
            INIT_MEA: begin
                if (valid)begin
                    trigger_nxt = 1'b1;
                end
                else begin
                    trigger_nxt = 1'b0;
                end
            end
            TRIGGER: begin
                if (~triggerSuc)begin
                    trigger_nxt = 1'b1;
                end
                else begin
                    trigger_nxt = 1'b0;
                end
            end
            MEASURE: begin
                if(valid) begin
                    if( distance <= location_cur - segment_cur)begin
                        // GO TO CUT
                        trigger_nxt = 1'b0;
                    end
                    else begin
                        trigger_nxt = 1'b1;
                    end
                end
                else begin
                    trigger_nxt = 1'b0;
                end
            end
            CUT: begin
                if(cut_end) begin
                    if(counter == slice_num) begin
                        trigger_nxt = 1'b0;
                    end
                    else begin
                        trigger_nxt = 1'b1;
                    end
                end
                else begin
                    trigger_nxt = 1'b0;
                end
            end
            PAUSE: begin
                if (stateTem_cur == INIT_TRI || stateTem_cur == TRIGGER) begin
                    trigger_nxt = 1'b1;
                end
                else begin
                    trigger_nxt = 1'b0;
                end
            end
        endcase
    end

    // FSM
    always @ ( * ) begin
        state_nxt    = state_cur;
        stateTem_nxt = stateTem_cur;
        move_nxt     = 1'b0;
        cut_nxt      = 1'b0;
        length_nxt   = length_cur;
        segment_nxt  = segment_cur;
        location_nxt = location_cur;
        counter_nxt  = counter;
        finish_nxt   = 1'b0;
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
                    segment_nxt = segment_cur;
                    move_nxt = 1'b0;
                    location_nxt = location_cur;
                end
                else begin
                    stateTem_nxt = stateTem_cur;
                    if(valid) begin
                        state_nxt = TRIGGER;
                        length_nxt = distance;
                        // WARNING : CRITICAL PATH !!!!!!!!!!!!!!
                        segment_nxt = distance / slice_num;
                        move_nxt = 1'b1;
                        location_nxt = distance;
                    end
                    else begin
                        state_nxt = INIT_MEA;
                        length_nxt = length_cur;
                        segment_nxt = segment_cur;
                        move_nxt = 1'b0;
                        location_nxt = location_cur;
                    end
                end
            end
            TRIGGER: begin
                if (pause) begin
                    state_nxt = PAUSE;
                    stateTem_nxt = TRIGGER;
                end
                else begin
                    stateTem_nxt = stateTem_cur;
                    if(triggerSuc) begin
                        state_nxt = MEASURE;
                    end
                    else begin
                        state_nxt = TRIGGER;
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
                    if(valid) begin
                        if( distance <= location_cur - segment_cur)begin
                            // GO TO CUT
                            move_nxt = 1'b0;
                            cut_nxt = 1'b1;
                            state_nxt = CUT;
                            counter_nxt = counter + 1;
                        end
                        else begin
                            move_nxt = 1'b1;
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
                    finish_nxt = 1'b0;
                    move_nxt = 1'b0;
                    counter_nxt = counter;
                    location_nxt = location_cur;
                end
                else begin
                    stateTem_nxt = stateTem_cur;
                    if(cut_end) begin
                        cut_nxt = 1'b0;
                        location_nxt = location_cur - segment_cur;
                        if(counter == slice_num) begin
                            finish_nxt = 1'b1;
                            move_nxt = 1'b0;
                            state_nxt = IDLE;
                            counter_nxt = 5'd0;
                        end
                        else begin
                            finish_nxt = 1'b0;
                            move_nxt = 1'b1;
                            state_nxt = TRIGGER;
                            counter_nxt = counter + 1;
                        end
                    end
                    else begin
                        state_nxt = CUT;
                        cut_nxt = 1'b1;
                        finish_nxt = 1'b0;
                        move_nxt = 1'b0;
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
        endcase
    end

//==== synchronous circuit ==============================
    always @(posedge clk or negedge rst_n) begin
        // asynchronous reset
        if (~rst_n) begin
            trigger_cur  <=  9'b0;
            state_cur    <=  3'd0;
            stateTem_cur <=  3'd0;
            move_cur     <=  1'b0;
            cut_cur      <=  1'b0;
            length_cur   <= 32'd0;
            segment_cur  <= 32'd0;
            location_cur <= 32'd0;
            counter      <=  5'd0;
            finish_cur   <=  1'b0;
        end
        else begin
            trigger_cur  <=  trigger_nxt;
            state_cur    <=  state_nxt;
            stateTem_cur <=  stateTem_nxt;
            move_cur     <=  move_nxt;
            cut_cur      <=  cut_nxt;
            length_cur   <=  length_nxt;
            segment_cur  <=  segment_nxt;
            location_cur <=  location_nxt;
            counter      <=  counter_nxt;
            finish_cur   <=  finish_nxt;
        end
    end

endmodule
