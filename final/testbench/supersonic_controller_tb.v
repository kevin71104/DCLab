`timescale 1ns/100ps
`define CYCLE  20.0
`define H_CYCLE (`CYCLE/2)
`include   "../src/supersonic_controller.v"
`include   "../src/supersonic.v"
`include   "../src/controller.v"

module test_supersonic_controller;

/*=============== reg/wire declaration =============*/
	reg         clk;
    reg         rst_n;
    reg         start_i;
    reg         pause_i;
    reg [4:0]   slice_num_i;
    
    // I/O with move driver
    wire        move_o;
    wire        back_o;
    
    // I/O with cut controller
    reg         cut_end_i;
    wire        cut_o;
    
    // I/O with supersonic
    reg         echo_i;
    
    wire        finish_o;

/*================ module instantiation ================*/

	supersonic_controller DUT (
		.clk        (clk),
		.rst_n      (rst_n),
		.start_i    (start_i),
		.pause_i    (pause_i),
		.slice_num_i(slice_num_i),
		.move_o     (move_o),
		.back_o     (back_o),
		.cut_end_i  (cut_end_i),
		.cut_o      (cut_o),
		.echo_i     (echo_i),
		.finish_o   (finish_o)
	);

	// Dump waveform file
	initial begin
		$dumpfile("supersonic_controller.vcd");
		$dumpvars;			
	end
	
	// clock signal settings
	initial begin
        clk = 1'b0;
        forever #(`H_CYCLE) clk = ~clk;
    end

	// test_supersonic_controller
	initial begin         
        slice_num_i = 5'd3;
        pause_i     = 0;
        
        rst_n = 0;
		#(`CYCLE*1.2);
		rst_n = 1;		
        #(`CYCLE*2); 

        start_i = 1;
        #(`CYCLE*1)
        start_i = 0;
        
        // echo & cut_end_i
        
        
        
        @(finish_o) $display("\nfinish\n");
		$finish;
	end
    
    // abort if the design cannot halt
    initial begin
        #(`CYCLE * 10000000 );
        $display( "\n" );
        $display( "Your design doesn't finish all operations in reasonable interval." );
        $display( "Terminated at: ", $time, " ns" );
        $display( "\n" );
        $finish;
    end
 
endmodule