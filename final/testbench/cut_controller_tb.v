`timescale 1ns/100ps
`define CYCLE  20.0
`define H_CYCLE (`CYCLE/2)

module test_cut_controller;

    localparam define_speed = 1000;

/*=============== reg/wire declaration =============*/
	reg   clk;
    reg   rst_n;
    
    // I/O with controller unit
    reg   cut_i;          
    wire  cut_end_o;     
    
    // I/O with cut driver
    wire  en_o;          
    wire  direction_o;   

/*================ module instantiation ================*/
	cut_controller #(
        .define_speed(define_speed)
        ) DUT (
		.clk        (clk),
		.rst_n      (rst_n),
		.cut_i      (cut_i),
		.cut_end_o  (cut_end_o),
		.en_o       (en_o),
		.direction_o(direction_o)
	);

	// Dump waveform file
	initial begin
		$dumpfile("cut_controller.vcd");
		$dumpvars;			
	end
	
	// clock signal settings
	initial begin
        clk = 1'b0;
        forever #(`H_CYCLE) clk = ~clk;
    end

	// test_supersonic
	initial begin 
        rst_n = 0;
		#(`CYCLE*1.2);
		rst_n = 1;		
        #(`CYCLE*2);

        cut_i = 1;        	
        #(`CYCLE*10000);
        cut_i = 0;	
        #(`CYCLE*10);
        cut_i = 1;        	
        #(`CYCLE*10000);
        cut_i = 0;     	
        #(`CYCLE*10);
        cut_i = 1;        	
        #(`CYCLE*10000);
        cut_i = 0;     	
        #(`CYCLE*10);
        cut_i = 1;        	
        #(`CYCLE*10000);
        cut_i = 0;     	
        #(`CYCLE*10);
        cut_i = 1;            
        
        @(cut_end_o) $display("\nfinish\n");
		$finish;
	end
    
    // abort if the design cannot halt
    initial begin
        #(`CYCLE * 100000000 );
        $display( "\n" );
        $display( "Your design doesn't finish all operations in reasonable interval." );
        $display( "Terminated at: ", $time, " ns" );
        $display( "\n" );
        $finish;
    end
 
endmodule