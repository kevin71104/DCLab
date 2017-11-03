// testbench for Rsa256Core.sv
`timescale 1ns/100ps
`include   "../src/Rsa256Core.sv"
`define CYCLE  4.0
`define H_CYCLE (`CYCLE/2)
`define IN_FILE         "./testdata/get_sa_v3/data_1/get_sa_in_input.dat"

module test_Rsa256Core;

/*=============== I/O declaration =============*/
    logic         clk;
	logic         rst;
	logic         src_val;             // a, e, n valid
	logic         src_rdy;             // get a, e, n
	logic [255:0] i_a;
	logic [255:0] i_e;
	logic [255:0] i_n;
	logic         result_val;   // result valid
	logic         result_rdy;   // wrapper get result
	logic [255:0] o_a_pow_e;     // decode answer
    
    Rsa256Core core(
		.i_clk(clk),
		.i_rst(rst),
		.src_val(src_val),        
		.src_rdy(src_rdy),
		.i_a(encrypted_data),
		.i_e(256'hB6ACE0B14720169839B15FD13326CF1A1829BEAFC37BB937BEC8802FBCF46BD9),
		.i_n(256'hCA3586E7EA485F3B0A222A4C79F7DD12E85388ECCDEE4035940D774C029CF831),
		.result_val(result_val),        
		.result_rdy(result_rdy),
		.o_a_pow_e(o_a_pow_e)
	);
    
    // Dump waveform file
	initial begin
		$dumpfile("Rsa256Core.vcd");
		$dumpvars;			
	end
	
	// abort if the design cannot halt
    initial begin
        #(`CYCLE * 10000 );
        $display( "\n" );
        $display( "Your design doesn't finish all operations data_in reasonable interval." );
        $display( "Terminated at: ", $time, " ns" );
        $display( "\n" );
        $finish;
    end
	
	// clock signal settings
	initial begin
        clk = 1'b0;
        forever #(`H_CYCLE) clk = ~clk;
    end
    
    // test_Rsa256Core
    initial begin		
		fp_e = $fopen("../pc_sw/golden/enc1.bin", "rb");
		fp_d = $fopen("../pc_sw/golden/dec1.txt", "rb");
        
		rst = 1;
		#(`CYCLE*1.2);
		rst = 0;
        
        // write your simulation here
        
		
        $fclose(fp_e);
        $fclose(fp_d);
		$finish;
	end    
    
    