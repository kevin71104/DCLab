module slice_counter(
    input       clk,
    input       rst_n,
    input       slice_i,
    output [4:0]slice_num_o // cut into how many pieces 0-16
);

    reg [4:0] slice_num, nxt_slice_num;
    
    assign slice_num_o = slice_num;
    
    always@(*) begin
		  if(slice_num == 5'd17) // can cut into 0-16 slices
            nxt_slice_num = 0;			
		  else
        if(slice_i)
            nxt_slice_num = slice_num + 1'b1;
        else 
            nxt_slice_num = slice_num;
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