module Top#(
    parameter  define_cut_speed = 5, //ms
    parameter  define_motor_speed = 1000 //ms

)(
    input       clk,
    input       rst_n,
    input       start_i,
    input       pause_i,
    input       slice_i,
    output [4:0]slice_num_o,
    output      finish_o,
    
    // I/O with supersonic
    input       echo_i,
    output      trigger_o,
    
    // I/O with move motor
    output [3:0]  move_signal_o,
    
    // I/O with cut motor
    output [3:0]  cut_signal_o,
    
    // for testing
    output [16:0] distance_o,
	 output	      move_o,
	 output	      cut_o,
	 output  [3:0] state_o,
	 output        triggerSuc_o,
	 output [11:0] stable_cnt_o,
	 output        superState_o,
	 output [16:0] location_o,
	 output        smallornot_o
);

    wire        valid;
    wire [16:0] distance;
    wire        triggerSuc;
    wire        move;
    wire        back;
    wire        cut_end;
    wire        cut;
    
	 // for testing!!!!!!!!!!!!!!!!!!!!!
   assign distance_o = distance;
	assign move_o = move;
	assign cut_o = cut;
	assign triggerSuc_o = triggerSuc;


    controller controller(
      .clk        (clk),
		.rst_n      (rst_n),
		.start      (start_i),
		.pause      (pause_i),
		.slice_num  (slice_num_o),
		.valid      (valid),
		.distance   (distance),
		.triggerSuc (triggerSuc),
		.trigger    (trigger_o),
		.move       (move),
      .back       (back),
		.cut_end    (cut_end),
		.cut        (cut),
      .finish     (finish_o),
		  
		  // for testing!!!!!!!!!!!!!!!!!
		.state_o	(state_o),
		.stable_cnt_o(stable_cnt_o),
		.location_o(location_o),
		.smallornot_o(smallornot_o)
    );
    
    supersonic supersonic0(
		.clk        (clk),
		.rst_n      (rst_n),
		.echo       (echo_i),
		.valid      (valid),
		.distance   (distance),
      .triggerSuc (triggerSuc),
		.trigger    (trigger_o),
		// testing
		.superState (superState_o)
	);

    // cut    
    slice_counter slice_counter0(
        .clk        (clk),
        .rst_n      (rst_n),
        .slice_i    (slice_i),
        .slice_num_o(slice_num_o) 
    );
    
    cut_driver #(
        .define_cut_speed(define_cut_speed)
    )cut_driver0(
		.clk        (clk),
		.rst_n      (rst_n),
		.cut_i      (cut),
		.cut_end_o  (cut_end),
      .signal_o   (cut_signal_o)
    );
    
    // move 
    track_driver #(
        .define_motor_speed(define_motor_speed)
    )track_driverA(
		.clk        (clk),
		.rst_n      (rst_n),
		.move_i     (move),
		.back_i     (back),
		// .move_i     (1'b0),
		// .back_i     (1'b1),
        .signal_o (move_signal_o)
    );


endmodule