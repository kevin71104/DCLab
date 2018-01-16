// Team number: 5
// Author: Frank Chuang
//
// Create Date: 01/14/2018
// Project Name: Kitchen's helper
// Module Name: cut_controller
// Target Devices: DE2-115
// Description: To controll cutting driver 

module cut_controller#(
    parameter define_speed = 10 // unit: ms, which means 10ms trun 0.9 degree
)
(
    input   clk,
    input   rst_n,
    
    // I/O with controller unit
    input   cut_i,          // determin whether needs to cut
    output  cut_end_o,      // cut action is complete
    
    // I/O with cut driver
    output  en_o,           // enable cut driver
    output  direction_o     // direction: 0 => clockwise, 1 => counterclockwise
);
    localparam define_clock = 2500000/define_speed;
    
    localparam STATE_CLKWISE    = 2'd0;
    localparam STATE_CNTCLKWISE = 2'd1;
    localparam STATE_CUTEND     = 2'd2;
    
    reg [1:0]   state, nxt_state;
    
    reg         cut_end, nxt_cut_end;
    reg         en, nxt_en;
    reg         direction, nxt_direction;
    reg [31:0]  clk_cnt, nxt_clk_cnt; // 0~define_clock, cnt how many clk cycles
    reg [6:0]   cnt, nxt_cnt; // 0~100 each cnt represents 0.9 degree

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
                if(cnt == 7'd100) 
                    nxt_state = STATE_CNTCLKWISE;
                else 
                    nxt_state = STATE_CLKWISE;
            end
            STATE_CNTCLKWISE: begin
                nxt_direction   = 1;
                nxt_cut_end     = 0;       
                if(cnt == 7'd100) 
                    nxt_state = STATE_CUTEND;
                else 
                    nxt_state = STATE_CNTCLKWISE;           
            end
            STATE_CUTEND: begin
                nxt_direction   = 0;
                nxt_cut_end     = 1;   
                nxt_state       = STATE_CLKWISE;          
            end
            default: begin
                nxt_direction   = 0;
                nxt_cut_end     = 0;   
                nxt_state       = state;            
            end
        endcase
    end
    
//================= Combinational ==================

    assign cut_end_o    = cut_end;
    assign en_o         = en;
    assign direction_o  = direction;
    
    always@(*) begin
        if(clk_cnt == define_clock)
            nxt_clk_cnt  = 0;
        else
        if((state == STATE_CLKWISE || state == STATE_CNTCLKWISE) && cut_i) 
            nxt_clk_cnt  = clk_cnt + 1'b1;
        else 
            nxt_clk_cnt  = clk_cnt;  
    end
    
    always@(*) begin
        if(cnt == 7'd100)
            nxt_cnt  = 0;
        else
        if(clk_cnt == define_clock) 
            nxt_cnt  = cnt + 1'b1;
        else 
            nxt_cnt  = cnt;   
    end
    
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
            clk_cnt     <= 0;
            cnt         <= 0;
        end
        else begin
            cut_end     <= nxt_cut_end;
            en          <= nxt_en;
            direction   <= nxt_direction;
            clk_cnt     <= nxt_clk_cnt;
            cnt         <= nxt_cnt;
        end    
    end   

endmodule