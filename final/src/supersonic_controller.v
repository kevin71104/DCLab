module supersonic_controller(
    input       clk,
    input       rst_n,
    input       start_i,
    input       pause_i,
    input [4:0] slice_num_i,
    
    // I/O with move driver
    output      move_o,
    output      back_o,
    
    // I/O with cut controller
    input       cut_end_i,
    output      cut_o,
    
    // I/O with supersonic
    input       echo_i,
    
    output      finish_o
);
    
    wire trigger, triggerSuc;
    wire valid;
    wire [31:0] distance;

    supersonic supersonic0(
		.clk        (clk),
		.rst_n      (rst_n),
		.trigger    (trigger),
		.echo       (echo_i),
		.valid      (valid),
        .triggerSuc (triggerSuc),
		.distance   (distance)
    );
    
    controller controller0(
		.clk        (clk),
		.rst_n      (rst_n),
		.start      (start_i),
		.pause      (pause_i),
		.slice_num  (slice_num_i),
		.valid      (valid),
		.distance   (distance),
		.triggerSuc (triggerSuc),
		.trigger    (trigger),
		.move       (move_o),
        .back       (back_o),
		.cut_end    (cut_end_i),
		.cut        (cut_o),
        .finish     (finish_o)    
    );

endmodule