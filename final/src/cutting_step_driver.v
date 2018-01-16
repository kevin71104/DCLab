`timescale 1ns / 1ps

// Team number: 5    
// Author: Edwin Chen
// 
// Create Date: 01/14/2018
// Project Name: Kitchen's helper
// Module Name: track_step_driver
// Target Devices: DE2-115
// Description: This is the state machine that drives
// the output to the PmodSTEP. It alternates one of four pins being
// high at a rate set by the clock divider. 

module cutting_step_driver(
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
    // 4->3->2->1
    // counter-clockwise
    // 1->2->3->4

    localparam sig0     = 4'b0;
    // "One phase mode"
    localparam sig1_1   = 4'b0001;
    localparam sig2_1   = 4'b0010;
    localparam sig3_1   = 4'b0100;
    localparam sig4_1   = 4'b1000;
    // "Two phase mode"
    localparam sig1     = 4'b0011;
    localparam sig2     = 4'b0110;
    localparam sig3     = 4'b1100;
    localparam sig4     = 4'b1001;

// =========== Finite State Machine ============
    reg [3:0] curr_state, next_state;
 
    always @ (posedge clk or negedge rst_n) begin
        if (!rst_n)
            curr_state <= sig0;
        else 
            curr_state <= next_state;
    end

    always @ (*) begin
        case(curr_state)
        sig0: begin
            if (en == 1'b1)
                next_state = sig1;
            else 
                next_state = sig0;
        end 
        sig1: begin
            if (direction == 1'b0 && en == 1'b1)
                next_state = sig4;
            else if (direction == 1'b1 && en == 1'b1)
                next_state = sig2;
            else 
                next_state = sig0;
        end
        sig2: begin
            if (direction == 1'b0 && en == 1'b1)
                next_state = sig1;
            else if (direction == 1'b1 && en == 1'b1)
                next_state = sig3;
            else 
                next_state = sig0;
        end 
        sig3: begin
            if (direction == 1'b0 && en == 1'b1)
                next_state = sig2;
            else if (direction == 1'b1 && en == 1'b1)
                next_state = sig4;
            else 
                next_state = sig0;
        end 
        // If the state is sig4, the state where
        // the fourth signal is held high.
        sig4: begin
            if (direction == 1'b0 && en == 1'b1)
                next_state = sig3;
            else if (direction == 1'b1 && en == 1'b1)
                next_state = sig1;
            else 
                next_state = sig0;
        end  
        default:
            next_state = sig0; 
        endcase
    end 
    
    // Output Logic
    // Depending on the state
    // output signal has a different
    // value.     
    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n)
            signal <= sig0;        
        else if (curr_state == sig4)
            signal <= sig4;
            // signal = 4'b1000;
        else if (curr_state == sig3)
            signal <= sig3;
            // signal = 4'b0100;
        else if (curr_state == sig2)
            signal <= sig2;          
            // signal = 4'b0010;
        else if (curr_state == sig1)
            signal <= sig1;
            // signal = 4'b0001;
        else
            signal <= 0;
    end
endmodule
