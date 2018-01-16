`timescale 1ns/100ps
`define CYCLE  20.0
`define H_CYCLE (`CYCLE/2)
`include   "../src/controller.v"
`include   "../src/supersonic.v"
`include   "../src/cut_controller.v"
`include   "../src/cutting_step_driver.v"
`include   "../src/clock_div.v"
`include   "../src/slice_counter.v"
`include   "../src/track_step_driver.v"

module test_Top;

    localparam define_speed = 100000; // ms

/*=============== reg/wire declaration =============*/	
    reg         clk;
    reg         rst_n;
    reg         start_i;
    reg         pause_i;
    reg         slice_i;
    wire [4:0]  slice_num_o;
    wire        finish_o;
    
    // I/O with supersonic
    reg   echo_i;
    wire  trigger_o,
    
    // I/O with move motor
    wire  move_signal_o;
    
    // I/O with cut motor
    wire  cut_signal_o;

/*================ module instantiation ================*/

	Top #(
        .define_speed(define_speed)
    )DUT (
		.clk            (clk),
		.rst_n          (rst_n),
		.start_i        (start_i),
		.pause_i        (pause_i),
		.slice_i        (slice_i),
		.slice_num_o    (slice_num_o),
		.finish_o       (finish_o),
		.echo_i         (echo_i),
		.trigger_o      (trigger_o),
		.move_signal_o  (move_signal_o),
		.cut_signal_o   (cut_signal_o)
	);

	// Dump waveform file
	initial begin
		$dumpfile("Top.vcd");
		$dumpvars;			
	end
	
	// clock signal settings
	initial begin
        clk = 1'b0;
        forever #(`H_CYCLE) clk = ~clk;
    end

	// test_Top
	initial begin               
        rst_n = 0;
		#(`CYCLE*1.2);
		rst_n = 1;		
        #(`CYCLE*2); 
        
        
        
     
        
        @(finish_o) $display("\nfinish\n");
		$finish;
	end
    
    // abort if the design cannot halt
    initial begin
        #(`CYCLE * 100000 );
        $display( "\n" );
        $display( "Your design doesn't finish all operations in reasonable interval." );
        $display( "Terminated at: ", $time, " ns" );
        $display( "\n" );
        $finish;
    end
 
endmodule