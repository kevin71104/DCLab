`timescale 1ns/100ps
`define CYCLE  20.0
`define H_CYCLE (`CYCLE/2)
`include   "../src/cut_driver.v"

module test_cut_controller_driver;

    localparam define_speed = 0.0002; // ms 200ns

/*=============== reg/wire declaration =============*/
	reg         clk;
    reg         rst_n;
    
    // I/O with controller
    reg         cut_i;
    wire        cut_end_o;
    
    // I/O with motor
    wire [3:0]  signal_o;

/*================ module instantiation ================*/

	cut_driver #(
        .define_speed(define_speed)
    )DUT (
		.clk        (clk),
		.rst_n      (rst_n),
		.cut_i      (cut_i),
		.cut_end_o  (cut_end_o),
		.signal_o   (signal_o)
	);

	// Dump waveform file
	initial begin
		$dumpfile("cut_controller_driver.vcd");
		$dumpvars;			
	end
	
	// clock signal settings
	initial begin
        clk = 1'b0;
        forever #(`H_CYCLE) clk = ~clk;
    end

	// test_cut_controller_driver
	initial begin               
        rst_n = 0;
		#(`CYCLE*1.2);
		rst_n = 1;		
        #(`CYCLE*2); 
        
        // cut_i
        cut_i = 1;        	
        #(`CYCLE*5);
        cut_i = 0;  	
        #(`CYCLE*2); 
        cut_i = 1;         
        
        @(cut_end_o) $display("\nfinish\n");
		$finish;
	end
    
    // abort if the design cannot halt
    initial begin
        #(`CYCLE * 1000000 );
        $display( "\n" );
        $display( "Your design doesn't finish all operations in reasonable interval." );
        $display( "Terminated at: ", $time, " ns" );
        $display( "\n" );
        $finish;
    end
 
endmodule