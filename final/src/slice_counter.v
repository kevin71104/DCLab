module slice_counter(
    input       clk,
    input       rst_n,
    input       slice_i,
    output [4:0]slice_num_o // cut into how many pieces 0 2 4 8 16
);

    reg [4:0] slice_num, nxt_slice_num;
    
    assign slice_num_o = slice_num;
    
    always@(*) begin
		  case({slice_i,slice_num})
		  {1'b1,5'd0}: nxt_slice_num = 5'd2;
		  {1'b1,5'd2}: nxt_slice_num = 5'd4;
		  {1'b1,5'd4}: nxt_slice_num = 5'd8;
		  {1'b1,5'd8}: nxt_slice_num = 5'd16;
		  {1'b1,5'd16}: nxt_slice_num = 5'd0;
		  default: nxt_slice_num = slice_num;
		  endcase
    end
    
    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            slice_num <= 0;
        end
        else begin
            slice_num <= nxt_slice_num;
        end
    end
endmodule