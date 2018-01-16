// Team number: 5
// Author: Edwin Chen
//
// Create Date: 01/14/2018
// Project Name: Kitchen's helper
// Module Name: clock_div
// Target Devices: DE2-115
// Description: This is a clock divider. It takes the system clock 
// and divides that down to a slower clock. It counts at the rate of the 
// system clock to define_speed and toggles the output clock signal. 

module clock_div#(
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
    localparam define_half_cycle = 25000*define_speed;
    
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
