//For testing Top.sv

`timescale 1 ns/10 ps
`define CYCLE       20.0 // clock = 50 MHz
`define H_CYCLE     10.0

module tb_Top;

	logic clk;
	logic rst;
	logic start;
	logic [3:0] out;

	Top top(
		.i_clk(clk),
		.i_rst(rst),
		.i_start(start),
		.o_random_out(out)
	);
	
	// waveform dump
    initial begin
        $dumpfile("Top.vcd");
        $dumpvars;
	end
	
	// abort if the design cannot halt
    // initial begin
        // #(`CYCLE * 10000 );
        // $display( "\n" );
        // $display( "Your design doesn't finish all operations in reasonable interval." );
        // $display( "Terminated at: ", $time, " ns" );
        // $display( "\n" );
        // $finish;
    // end
	
	// clock
    initial begin
        clk = 1'b0;
        forever #(`H_CYCLE) clk = ~clk;
    end
	
	initial begin
		rst	  =	1;
		start = 0;
		#(`CYCLE*2) 	rst = 0;
		#(`CYCLE*2) 	rst = 1;
		#(`CYCLE*1.5) 	start = 1;
		#(`CYCLE) 	start = 0; 	
		#(`CYCLE*8)	start = 1;
		#(`CYCLE) 	start = 0;
		#10000000 $finish;
	end
endmodule
	