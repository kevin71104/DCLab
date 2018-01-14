`timescale 1ns/100ps
`define CYCLE  20.0
`define H_CYCLE (`CYCLE/2)

module test_controller;

/*=============== reg/wire declaration =============*/
	reg	        clk;
	reg	        rst_n;    
    reg         start;
    reg         pause;   
    reg  [4:0]  slice_num;  
    
    // I/O with supersonic
    reg         valid;  
    reg         distance;  
    reg         triggerSuc;  
    wire        trigger;
    
    // I/O with Move Controller
    wire        move;
    
    // I/O with Cut controller
    reg         cut_end;    
    wire        cut;

/*================ module instantiation ================*/
	controller DUT(
		.clk        (clk),
		.rst_n      (rst_n),
		.start      (start),
		.pause      (pause),
		.slice_num  (slice_num),
		.valid      (valid),
		.distance   (distance),
		.triggerSuc (triggerSuc),
		.trigger    (trigger),
		.move       (move),
		.cut_end    (cut_end),
		.cut        (cut)
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
        rst_n = 0;
		#(`CYCLE*1.2);
		rst_n = 1;
		

        
        @(posedge valid) begin                
            $display("%d",distance);                 
        end
		$finish;
	end
 
endmodule