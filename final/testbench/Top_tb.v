`timescale 1ns/100ps
`define CYCLE  20.0
`define H_CYCLE (`CYCLE/2)
`include   "../src/Top.v"
`include   "../src/controller.v"
`include   "../src/supersonic.v"
`include   "../src/cut_driver.v"
`include   "../src/slice_counter.v"
`include   "../src/track_driver.v"

module test_Top;

    localparam define_speed = 0.0002; // ms

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
    wire  trigger_o;
    
    // I/O with move motor
    wire [3:0]  move_signal_o;
    
    // I/O with cut motor
    wire [3:0]  cut_signal_o;

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
    
    
    reg [31:0] cnt;

	// test_Top
	initial begin               
        rst_n = 0;
		#(`CYCLE*1.2);
		rst_n = 1;		
        #(`CYCLE*2); 
        
        // slice_num = 4
        slice;
        slice;
        start;
        
        // test
        trigger;
        echo(900);  
        trigger;
        echo(600);  
        trigger;
        echo(500);  
        trigger;
        echo(350);  
        trigger;
        echo(200);  
        trigger;
        echo(500);  
        trigger;
        echo(740);  
        trigger;
        echo(910);    
        
        @(finish_o) $display("\nfinish\n");
		$finish;
	end
    
    task slice;
    begin
        slice_i = 1; 	
        #(`CYCLE*1);
        slice_i = 0;  
    end
    endtask
    
    
    task start;
    begin
        start_i = 1; 	
        #(`CYCLE*0.5);
        start_i = 0;  
    end        
    endtask
    
    task trigger;
    begin
        cnt     = 0;
        while(cnt!=32'd500)begin 
            @(posedge clk) begin
                if(trigger_o) 
                    cnt = cnt + 1;       
            end 
        end
    end
    endtask
    
    task echo;
        input [31:0] set_cycle;
    begin
        echo_i = 1;
        #(`CYCLE*set_cycle);
        echo_i = 0;
    end
    endtask
    
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