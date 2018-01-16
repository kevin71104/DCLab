// Team number: 5    
// Author: Edwin Chen
// 
// Create Date: 01/14/2018
// Project Name: Kitchen's helper
// Module Name: cut_driver
// Target Devices: DE2-115

module cut_driver#(
    parameter define_speed = 10
)(
    input       clk,
    input       rst_n,
    
    // I/O with controller
    input       cut_i,
    output      cut_end_o,
    
    // I/O with motor
    output [3:0]signal_o
);
    wire new_clk;
    
    clock_div0 #(
        .define_speed(define_speed)
    )clock_div0(
		.clk        (clk),
		.rst_n      (rst_n),
		.new_clk    (new_clk) 
    );
    
    cutting_step_driver #(
        .define_speed(define_speed)
    )cutting_step_driver0(
		.clk        (new_clk),
		.rst_n      (rst_n),
		.en_i       (cut_i),
		.cut_end_o  (cut_end_o), 
		.signal_o   (signal_o)
    );

endmodule


// Description: This is a clock divider. It takes the system clock 
// and divides that down to a slower clock. It counts at the rate of the 
// system clock to define_speed and toggles the output clock signal. 
module clock_div0#(
  parameter define_speed = 10 // Unit: ms 
)
(
    input clk,
    input rst_n,
    output reg new_clk
);
    
    // The constant that defines the clock speed. 
    // Since the system clock is 50MHZ, 
    // define_speed = (2*desired_clock_frequency)/50MHz
    // localparam desired_clock_freq = 50Hz
    localparam define_half_cycle = 25000*define_speed-1;
    
    // Count value that counts to define_speed
    reg [31:0] count;
    
    always @ (posedge clk or negedge rst_n) begin
        // When rst is low set count and new_clk to 0
        if (!rst_n) begin 
            count   <= 32'b0;   
            new_clk <= 1'b0;            
        end
        // When the count has reached the constant
        // reset count and toggle the output clock
        else if (count == define_half_cycle)
        begin
            count   <= 32'b0;
            new_clk <= ~new_clk;
        end
        // increment the clock and keep the output clock
        // the same when the constant hasn't been reached        
        else
        begin
            count   <= count + 1'b1;
            new_clk <= new_clk;
        end
    end
    
endmodule

// Description: This is the state machine that drives
// the output to the PmodSTEP. It alternates one of four pins being
// high at a rate set by the clock divider. 
module cutting_step_driver#(
    parameter define_speed = 10 // unit: ms, which means 10ms trun 0.9 degree
)
(
    input   clk,    // clk from clock driver
    input   rst_n,
    
    // I/O with controller
    input   en_i,    // enable motor to rotate
    output  cut_end_o,
    
    // I/O with step motor
    output  [3:0] signal_o
    );
    
    localparam define_clock_cycle = 50000*define_speed;
    
    // 4  3  2 1 -th bit
    // B' A' B A
    // clockwise
    // 4->3->2->1
    // counter-clockwise
    // 1->2->3->4
    localparam sig0     = 4'b0;
    // "Two phase mode"
    localparam sig1     = 4'b0011; // 3
    localparam sig2     = 4'b0110; // 6
    localparam sig3     = 4'b1100; // 12
    localparam sig4     = 4'b1001; // 9
    
    
    reg [3:0]   state, nxt_state;

    reg         cut_end, nxt_cut_end;
    reg [3:0]   signal, nxt_signal;
    
    reg         direction, nxt_direction;
    reg [31:0]  clk_cnt, nxt_clk_cnt; // 0~define_clock_cycle, cnt how many clk cycles
    reg [6:0]   cnt, nxt_cnt; // 0~100 each cnt represents 0.9 degree

// =========== Finite State Machine ============
 
    always @ (posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= sig0;
        else 
            state <= nxt_state;
    end

    always @ (*) begin
        case(state)
        sig0: begin
            if (en_i == 1'b1)
                nxt_state = sig1;
            else 
                nxt_state = sig0;
        end 
        sig1: begin
            if (direction == 1'b0 && en_i == 1'b1)
                nxt_state = sig4;
            else if (direction == 1'b1 && en_i == 1'b1)
                nxt_state = sig2;
            else 
                nxt_state = sig0;
        end
        sig2: begin
            if (direction == 1'b0 && en_i == 1'b1)
                nxt_state = sig1;
            else if (direction == 1'b1 && en_i == 1'b1)
                nxt_state = sig3;
            else 
                nxt_state = sig0;
        end 
        sig3: begin
            if (direction == 1'b0 && en_i == 1'b1)
                nxt_state = sig2;
            else if (direction == 1'b1 && en_i == 1'b1)
                nxt_state = sig4;
            else 
                nxt_state = sig0;
        end 
        // If the state is sig4, the state where
        // the fourth signal is held high.
        sig4: begin
            if (direction == 1'b0 && en_i == 1'b1)
                nxt_state = sig3;
            else if (direction == 1'b1 && en_i == 1'b1)
                nxt_state = sig1;
            else 
                nxt_state = sig0;
        end  
        default:
            nxt_state = sig0; 
        endcase
    end 
    
//============= Combitional LOgic ===============
    assign signal_o     = signal;
    assign cut_end_o    = cut_end;    
    
    // Output Logic, Depending on the state, output signal has a different value.     
    always @ (*) begin
        if (state == sig4)
            nxt_signal = sig4;
        else 
        if (state == sig3)
            nxt_signal = sig3;
        else 
        if (state == sig2)
            nxt_signal = sig2;  
        else 
        if (state == sig1)
            nxt_signal = sig1;
        else
            nxt_signal = 0;
    end
    
    always@(*) begin
        if(clk_cnt == define_clock_cycle)
            nxt_clk_cnt  = 0;
        else
        if(en_i) 
            nxt_clk_cnt  = clk_cnt + 1'b1;
        else 
            nxt_clk_cnt  = clk_cnt;  
    end
    
    // cnt && direction
    always@(*) begin
        if(cnt == 7'd100) begin // 90 / 0.9 = 100
            nxt_cnt         = 0;
            nxt_direction   = direction + 1'b1;
        end
        else
        if(clk_cnt == define_clock_cycle) begin
            nxt_cnt         = cnt + 1'b1;
            nxt_direction   = direction;
        end
        else begin
            nxt_cnt         = cnt;  
            nxt_direction   = direction; 
        end
    end
    
    // cut_end
    always@(*) begin
        if(cnt == 7'd100 && direction == 1) 
            nxt_cut_end     = 1;
        else
            nxt_cut_end     = 0;
    end
    


//=========== Sequential Logic =============    
    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            signal      <= 0;  
            cut_end     <= 0;
            direction   <= 0;
            clk_cnt     <= 0;
            cnt         <= 0;
        end
        else begin
            signal      <= nxt_signal;  
            cut_end     <= nxt_cut_end;
            direction   <= nxt_direction;
            clk_cnt     <= nxt_clk_cnt;
            cnt         <= nxt_cnt;        
        end
    end
endmodule