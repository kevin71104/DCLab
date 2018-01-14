/*============================================================
TESTBENCH for DOUBLE_MUL module:

 ============================================================*/
`timescale 1ns/100ps
`define CYCLE  20.0
`define H_CYCLE (`CYCLE/2)

module test_supersonic;


/*=============== reg/wire declaration =============*/
	reg	        clk;
	reg	        rst_n;    
    reg         trigger;
    reg         echo;    
    wire        valid;
    wire [31:0] distance;

/*================ module instantiation ================*/
	DOUBLE_MUL DUT(
		.clk        (clk),
		.rst_n      (rst_n),
		.trigger    (trigger), 
		.echo       (echo),
		.valid      (valid),
		.distance   (distance)
	);

	// Dump waveform file
	initial begin
		$dumpfile("supersonic.vcd");
		$dumpvars;			
	end
	
	// clock signal settings
	initial begin
        clk = 1'b0;
        forever #(`H_CYCLE) clk = ~clk;
    end

	// test_supersonic
	initial begin          
        rst = 0;
		#(`CYCLE*1.2);
		rst = 1;
		
        trigger = 1;
        #(`CYCLE * 500 );
        trigger = 0;
        
        echo = 1;
        #(`CYCLE * 25 );
        echo = 0;
        
        @(posedge valid) begin                
            $display("%d",distance);                 
        end
		$finish;
	end
 
endmodule