module Top#(
    parameter  define_speed = 10

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
    output      move_signal_o,
    
    // I/O with cut motor
    output      cut_signal_o
);

    wire        valid;
    wire [31:0] distance;
    wire        triggerSuc;
    wire        move;
    wire        back;
    wire        cut_end;
    wire        cut;
    
    wire        en_cut;
    wire        direction_cut;
    wire        new_clk0;
    
    wire        new_clk1;

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
        .finish     (finish_o)
    )
    
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
    )
    
    cut_controller #(
        .define_speed(define_speed)
    )cut_controller0(
		.clk        (clk),
		.rst_n      (rst_n),
		.cut_i      (cut),
		.cut_end_o  (cut_end),
		.en_o       (en_cut),
        .direction_o(direction_cut)
    );
    
    clock_div #(
        .define_speed(define_speed)
    )clock_div0(
		.clk        (clk),
		.rst_n      (rst_n),
		.new_clk    (new_clk0) 
    );
    
    cutting_step_driver cutting_step_driver0(
		.clk        (new_clk0),
		.rst_n      (rst_n),
		.en         (en_cut),
		.direction  (direction_cut), 
		.signal     (cut_signal_o)
    );    
    
    // move
    clock_div #(
        .define_speed(define_speed)
    )clock_div1(
		.clk        (clk),
		.rst_n      (rst_n),
		.new_clk    (new_clk1) 
    );
    
    track_step_driver track_step_driver0(
		.clk        (new_clk1),
		.rst_n      (rst_n),
		.en         (move),
		.direction  (back), 
		.signal     (move_signal_o)
    );


endmodule