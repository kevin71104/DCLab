module controller(clk, rst_n, start, pause, slice_num, valid, distance, trigger,
                  triggerSuc, move, cut, cut_end);

//==== input/output declaration =========================
    input        clk;
    input        rst_n;
    input        start;
    input        pause;      // after 2 pauses will start again
    input  [4:0] slice_num;  // number of pieces we want

    // I/O with supersonic
    input        valid;
    input        distance;
    input        triggerSuc;
    output       trigger;    // hold high for at least 10 us (500 cycles)

    // I/O with Move Controller
    output       move;

    // I/O with Cut controller
    input        cutend;
    output       cut;

//==== wire/reg declaration =============================
    // Output registers
    reg trigger_cur;
    reg trigger_nxt;
    reg move_cur;
    reg move_nxt;
    reg cut_cur;
    reg cut_nxt;

    // FSM
    reg  [3:0] state_cur;
    reg  [3:0] state_nxt;
    reg  [3:0] stateTem_cur;  // temporarily stored state for restoration from PAUSE
    reg  [3:0] stateTem_nxt;

//==== Parameter declaration ============================
    parameter IDLE     = 4'd0;
    parameter INIT_TRI = 4'd1;
    parameter INIT_MEA = 4'd2;
    parameter TRIGGER  = 4'd3;
    parameter MEASURE  = 4'd4;
    parameter MOVE     = 4'd5;
    parameter CUT      = 4'd6;
    parameter PAUSE    = 4'd7;

//==== combinational circuit ============================
    assign trigger = trigger_cur;
    assign move = move_cur;
    assign cut = cut_cur;

    // trigger signal
    always @ ( * ) begin
        trigger_nxt = trigger_cur;
        case(state_cur)
            IDLE: begin

            end
            INIT_TRI: begin
            end
            INIT_MEA: begin
            end
            MEASURE: begin
            end
            TRIGGER: begin
            end
            MOVE: begin
            end
            CUT: begin
            end
            PAUSE: begin
            end
        endcase
    end
    // FSM
    always @ ( * ) begin
        state_nxt = state_cur;
        stateTem_nxt = stateTem_cur;
        move_nxt = 1'b0;
        cut_nxt  = 1'b0;
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
                    stateTem_nxt = ININ_TRI;
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
            MEASURE: begin
            end
            TRIGGER: begin
            end
            MOVE: begin
            end
            CUT: begin
            end
            PAUSE: begin
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
        end
        else begin
            trigger_cur  <=  trigger_nxt;
            state_cur    <=  state_nxt;
            stateTem_cur <=  stateTem_nxt;
            move_cur     <=  move_nxt;
            cut_cur      <=  cut_nxt;
        end
    end

endmodule
