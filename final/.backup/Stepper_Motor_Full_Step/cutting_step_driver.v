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

module track_step_driver(
    input rst_n,
    input direction,
    input clk,
    input en,
    output reg [3:0] signal
    );
 
    // input rst_n
    // input clk
    // input en: 1 enable motor to rotate
    // input direction: 0 enable motor to rotate clockwisely
    // input motor_mode
    // output reg [3:0] signal
    // or output reg [7:0] signal


    // local parameters that hold the values of
    // each of the states. This way the states
    // can be referenced by name.
    localparam stop = 4'b0;
    localparam begin_sig_1 = 4'b0001;
    localparam begin_sig_2 = 4'b0011;
        
    // 1 2 3 4 -th bit
    // A B A'B'
    // clockwise
    // 4->3->2->1
    // counter-clockwise
    // 1->2->3->4

    localparam sig0 = 4'b0;
    // "One phase mode"
    localparam sig1_1 = 4'b0001;
    localparam sig2_1 = 4'b0010;
    localparam sig3_1 = 4'b0100;
    localparam sig4_1 = 4'b1000;
    // "Two phase mode"
    localparam sig1 = 4'b0011;
    localparam sig2 = 4'b0110;
    localparam sig3 = 4'b1100;
    localparam sig4 = 4'b1001;

    //*********************************************************
    // Finite State machine method

    // Use registers to hold the values of the present and next states
    reg [2:0] curr_state, next_state;

    // Run when the present state, direction or enable signals change.
    always @ (*) begin
        case(curr_state)
        // If the state is sig4, the state where
        // the fourth signal is held high. 
        sig4: begin
            // If direction is 0 and enable is high
            // the next state is sig3. If direction
            // is high and enable is high
            // next state is sig1. If enable is low
            // next state is sig0.
            if (direction == 1'b0 && en == 1'b1)
                next_state = sig3;
            else if (direction == 1'b1 && en == 1'b1)
                next_state = sig1;
            else 
                next_state = sig0;
        end  
        sig3: begin
            // If direction is 0 and enable is high
            // the next state is sig2. If direction
            // is high and enable is high
            // next state is sig4. If enable is low
            // next state is sig0.
            if (direction == 1'b0 && en == 1'b1)
                next_state = sig2;
            else if (direction == 1'b1 && en == 1'b1)
                next_state = sig4;
            else 
                next_state = sig0;
        end 
        sig2: begin
            // If direction is 0 and enable is high
            // the next state is sig1. If direction
            // is high and enable is high
            // next state is sig3. If enable is low
            // next state is sig0.
            if (direction == 1'b0 && en == 1'b1)
                next_state = sig1;
            else if (direction == 1'b1 && en == 1'b1)
                next_state = sig3;
            else 
                next_state = sig0;
        end 
        sig1: begin
            // If direction is 0 and enable is high
            // the next state is sig4. If direction
            // is high and enable is high
            // next state is sig2. If enable is low
            // next state is sig0.
            if (direction == 1'b0 && en == 1'b1)
                next_state = sig4;
            else if (direction == 1'b1 && en == 1'b1)
                next_state = sig2;
            else 
                next_state = sig0;
        end
        sig0: begin
            // If enable is high
            // the next state is sig1. 
            // If enable is low
            // next state is sig0.
            if (en == 1'b1)
                next_state = sig1;
            else 
                next_state = sig0;
        end
        default:
            next_state = sig0; 
        endcase
    end 
    
    // State register that passes the next
    // state value to the present state 
    // on the positive edge of clock
    // or reset. 
    always @ (posedge clk or negedge rst_n) begin
        if (rst_n == 1'b0)
            curr_state = sig0;
        else 
            curr_state = next_state;
    end
    
    // Output Logic
    // Depending on the state
    // output signal has a different
    // value.     
    always @ (posedge clk)
    begin
        if (curr_state == sig4)
            signal = 4'b1001;
            // signal = 4'b1000;
        else if (curr_state == sig3)
            signal = 4'b1100;
            // signal = 4'b0100;
        else if (curr_state == sig2)
            signal = 4'b0110;          
            // signal = 4'b0010;
        else if (curr_state == sig1)
            signal = 4'b0011;
            // signal = 4'b0001;
        else
            signal = 4'b0000;
    end
endmodule
