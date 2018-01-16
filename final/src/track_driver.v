`timescale 1ns / 1ps

// Team number: 5    
// Author: Edwin Chen
// 
// Create Date: 01/14/2018
// Project Name: Kitchen's helper
// Module Name: track_step_driver
// Target Devices: DE2-115

module track_driver#(
    parameter define_speed = 10
)(
    input       clk,
    input       rst_n,
    
    // I/O with controller
    input       move_i,
    input       back_i,
    
    // I/O with motor
    output [3:0]signal_o
);
    wire new_clk;
    
    clock_div1 #(
        .define_speed(define_speed)
    )clock_div1(
		.clk        (clk),
		.rst_n      (rst_n),
		.new_clk    (new_clk) 
    );
    
    track_step_driver track_step_driver0(
		.clk        (new_clk),
		.rst_n      (rst_n),
		.en         (move_i),
		.direction  (back_i), 
		.signal     (signal_o)
    );
endmodule


// Description: This is a clock divider. It takes the system clock 
// and divides that down to a slower clock. It counts at the rate of the 
// system clock to define_speed and toggles the output clock signal. 
module clock_div1#(
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
// the output to the LEGO motor.  
module track_step_driver(
    input clk,                  // clk from clock driver
    input rst_n,
    
    // I/O with cut controller
    input direction,            // 0 enable motor to rotate clockwisely
    input en,                   // enable motor to rotate
    
    // I/O with step motor
    output reg [3:0] signal
    );
    
    // 1 2 3 4 -th bit
    // A B A'B'
    // clockwise
    // sig1 -> sig2 -> sig3 -> sig4
    // counter-clockwise
    // sig4 -> sig3 -> sig2 -> sig1
    
    // "Two phase mode"
    localparam pos     = 4'b0101;
    localparam neg     = 4'b1010;
    localparam stop    = 4'b0000;

// =========== Finite State Machine ============
    reg [3:0] curr_state, next_state;
 
    always @ (posedge clk or negedge rst_n) begin
        if (!rst_n)
            curr_state <= stop;
        else 
            curr_state <= next_state;
    end

    always @ (*) begin
        case(curr_state)
        stop: begin
            if (direction == 1'b0 && en == 1'b1)
                next_state = pos;
            else if (direction == 1'b1 && en == 1'b1)
                next_state = neg;
            else 
                next_state = stop;
        end 
        pos: begin
            if (direction == 1'b0 && en == 1'b1)
                next_state = pos;
            else if (direction == 1'b1 && en == 1'b1)
                next_state = neg;
            else 
                next_state = pos;
        end
        neg: begin
            if (direction == 1'b0 && en == 1'b1)
                next_state = pos;
            else if (direction == 1'b1 && en == 1'b1)
                next_state = neg;
            else 
                next_state = neg;
        end 
        default:
            next_state = stop; 
        endcase
    end 
    
    // Output Logic
    // Depending on the state
    // output signal has a different
    // value.     
    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n)
            signal <= 0;        
        else if (curr_state == stop)
            signal <= stop;
        else if (curr_state == pos)
            signal <= pos;
        else if (curr_state == neg)
            signal <= neg;       
        else
            signal <= 0;
    end
endmodule
