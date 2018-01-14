module cut_controller#(
    parameter define_speed = 10 // unit: ms
)
(
    input   clk,
    input   rst_n,
    
    // I/O with controller unit
    input   cut_i,          // determin whether needs to cut
    output  cut_end_o,      // cut action is complete
    
    // I/O with cut driver
    output  en_o,           // enable cut driver
    output  direction_o    // direction: 0 => clockwise 1 => counterclockwise
);
    localparam define_clock = 2500000/define_speed;
    
    localparam STATE_CLKWISE    = 2'd0;
    localparam STATE_CNTCLKWISE = 2'd1;
    localparam STATE_CUTEND     = 2'd2;
    
    reg [1:0]   state, nxt_state;
    
    reg         cut_end, nxt_cut_end;
    reg         en, nxt_en;
    reg         direction, nxt_direction;

//=================== FSM =====================  
  
    always@(posedge clk or negedge rst_n) begin
        if(!rst_n)begin
            state <= 0;
        end
        else begin
            state <= nxt_state;
        end    
    end 

    always@(*) begin
        case(state)
            STATE_CLKWISE: begin
                nxt_direction   = 0;
                nxt_cut_end     = 0;
            end
            STATE_CNTCLKWISE: begin
                nxt_direction   = 1;
                nxt_cut_end     = 0;            
            end
            STATE_CUTEND: begin
                nxt_direction   = 0;
                nxt_cut_end     = 1;            
            end
            default: begin
                nxt_direction   = 0;
                nxt_cut_end     = 0;            
            end
        endcase
    end
    
//================= Combinational ==================

    assign cut_end_o    = cut_end;
    assign en_o         = en;
    assign direction_o  = direction;
    
    always@(*) begin
        if(cut_i) begin
            nxt_en  = 1;
        end
        else begin
            nxt_en  = 0;        
        end
    end

//================== Sequential ====================

    always@(posedge clk or negedge rst_n) begin
        if(!rst_n)begin
            cut_end     <= 0;
            en          <= 0;
            direction   <= 0;
        end
        else begin
            cut_end     <= nxt_cut_end;
            en          <= nxt_en;
            direction   <= nxt_direction;        
        end    
    end   

endmodule