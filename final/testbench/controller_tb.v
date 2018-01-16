`timescale 1ns/100ps
`define CYCLE  20.0
`define H_CYCLE (`CYCLE/2)
`include   "../src/controller.v"

module test_controller;

/*=============== reg/wire declaration =============*/
	reg	        clk;
	reg	        rst_n;
    reg         start;
    reg         pause;
    reg  [4:0]  slice_num;

    // I/O with supersonic
    reg         valid;
    reg  [16:0] distance;
    reg         triggerSuc;
    wire        trigger;

    // I/O with Move Controller
    wire        move;

    // I/O with Cut controller
    reg         cut_end;
    wire        cut;

    wire        finish;

/*================ module instantiation ================*/
	controller DUT(
		.clk        (clk),
		.rst_n      (rst_n),
		.start      (start),
		.pause      (pause),
		.slice_num  (slice_num),
		.valid      (valid),
		.distance   (distance),
		.trigger    (trigger),
		.triggerSuc (triggerSuc),
		.move       (move),
		.cut_end    (cut_end),
		.cut        (cut),
        .finish     (finish),
		.back       (back)
	);

	// Dump waveform file
	initial begin
		$dumpfile("controller.vcd");
		$dumpvars;
	end

	// clock signal settings
	initial begin
        clk = 1'b0;
        forever #(`H_CYCLE) clk = ~clk;
    end

	// test_supersonic
	initial begin
        slice_num   = 5'd4;
        pause       = 0;

        rst_n = 0;
		#(`CYCLE*1.2);
		rst_n = 1;

        #(`CYCLE*2);
        start = 1;
		triggerSuc = 0;
        // initial trigger
        @(posedge trigger) begin
            start = 0;

			#(`CYCLE*2);
            triggerSuc = 1;
            #(`CYCLE*1);
            triggerSuc = 0;
            #(`CYCLE*10);
            valid   = 1;
            distance= 32'd900;
			#(`CYCLE*1);
            valid = 0;
        end


		@(posedge trigger) begin
            #(`CYCLE*2);
            triggerSuc = 1;
            #(`CYCLE*1);
            triggerSuc = 0;

			// test pause
            #(`CYCLE*2);
            pause   = 1;
			#(`CYCLE*1);
			pause = 0;
			#(`CYCLE*2);
            pause = 1;
			#(`CYCLE*1);
            pause = 0;

			#(`CYCLE*2);
            triggerSuc = 1;
            #(`CYCLE*1);
            triggerSuc = 0;
            #(`CYCLE*10);
            valid   = 1;
            distance= 600;
			#(`CYCLE*1);
            valid = 0;

			//trigger cut
			#(`CYCLE*10);
            cut_end = 1'd1;
            #(`CYCLE*1);
            cut_end = 1'd0;
        end

        trigger_supersonic(32'd500);

        trigger_supersonic(32'd350);
        trigger_cut;

		trigger_supersonic(32'd200);
        trigger_cut;

		trigger_supersonic(32'd500);
		trigger_supersonic(32'd740);
		trigger_supersonic(32'd910);

        @(finish) $display("\nfinish\n");
		#(`CYCLE*2);
		$finish;
	end

    // abort if the design cannot halt
    initial begin
        #(`CYCLE * 10000 );
        $display( "\n" );
        $display( "Your design doesn't finish all operations in reasonable interval." );
        $display( "Terminated at: ", $time, " ns" );
        $display( "\n" );
        $finish;
    end

    task trigger_supersonic;
        input [31:0] set_distance;
        @(posedge trigger) begin
            #(`CYCLE*2);
            triggerSuc = 1;
            #(`CYCLE*1);
            triggerSuc = 0;
            #(`CYCLE*10);
            valid   = 1;
            distance= set_distance;
			#(`CYCLE*1);
            valid = 0;
        end
    endtask

    task trigger_cut;
        @(posedge cut) begin
            #(`CYCLE*10);
            cut_end = 1'd1;
            #(`CYCLE*1);
            cut_end = 1'd0;
        end
    endtask

endmodule
