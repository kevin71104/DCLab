module Top#(
    parameter  define_speed = 10000 //ms

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
    output [16:0]     distance_o,
	output	move_o,
	output	cut_o,
	output [3:0] state_o
);

    wire        valid;
    wire [16:0] distance;
    wire        triggerSuc;
    wire        move;
    wire        back;
    wire        cut_end;
    wire        cut;
    
    wire        en_cut;
    wire        direction_cut;
    wire        new_clk0;    
    wire        new_clk1;
    
    assign distance_o = distance;
	assign move_o = move;
	assign cut_o = cut;

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
		  .state_o	(state_o)
    );
    
    supersonic supersonic0(
		.clk        (clk),
		.rst_n      (rst_n),
		.echo       (echo_i),
		.valid      (valid),
		.distance   (distance),
        .triggerSuc (triggerSuc),
		.trigger    (trigger_o)
	);

    // cut    
    slice_counter slice_counter0(
        .clk        (clk),
        .rst_n      (rst_n),
        .slice_i    (slice_i),
        .slice_num_o(slice_num_o) 
    );
    
    cut_driver #(
        .define_speed(define_speed)
    )cut_driver0(
		.clk        (clk),
		.rst_n      (rst_n),
		.cut_i      (1'b1),
		.cut_end_o  (cut_end),
        .signal_o   (cut_signal_o)
    );
    
    // move
    track_driver #(
        .define_speed(define_speed)
    )track_driver0(
		.clk        (clk),
		.rst_n      (rst_n),
		.move_i     (1'b1),
		.back_i     (back),
        .signal_o   (move_signal_o)
    );

endmodule