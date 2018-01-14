module cut_controller_driver#(
    parameter define_speed = 10
)(
    input       clk,
    input       rst_n,
    
    // I/O with controller
    input       cut_i,
    output      cut_end_o,
    
    // I/O with motor
    output [3:0]signal_o
);
    wire en, direction;
    wire new_clk;

    cut_controller #(
        .define_speed(define_speed)
    )cut_controller0(
		.clk        (clk),
		.rst_n      (rst_n),
		.cut_i      (cut_i),
		.cut_end_o  (cut_end_o),
		.en_o       (en),
        .direction_o(direction)
    );
    
    clock_div #(
        .define_speed(define_speed)
    )clock_div0(
		.clk        (clk),
		.rst_n      (rst_n),
		.new_clk    (new_clk) 
    );
    
    track_step_driver track_step_driver0(
		.clk        (new_clk),
		.rst_n      (rst_n),
		.en         (en),
		.direction  (direction), 
		.signal     (signal_o)
    );

endmodule