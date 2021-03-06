/*========================================
version 1.0

Course : Digital circuit design experiment
Project: Random roll call machine
Module : Top
Author : Yu Chuan, Chuang
Date   : 2017/9/19

Abstract: 

==========================================*/
`timescale 1 ns/10 ps

module Top (
	input i_clk,
	input i_rst,
	input i_start,
	output [3:0] o_random_out
);

`ifdef FAST_SIM
	parameter FREQ_HZ = 1; //(kHz) original is 1000, but the unit of seconds is millisecond; thus 1000 -> 1
`elsif
	parameter FREQ_HZ = 50000;
`endif
	
	parameter DELAY1 	= 200;	// how many seconds (ms) keep numbers
	parameter DELAY2 	= 300;
	parameter DELAY3 	= 400;
	parameter DELAY4 	= 500;
	parameter DELAY5 	= 600;
	parameter DELAY6 	= 800;
	parameter DELAY7 	= 1000;
	parameter DELAY8 	= 1000;
	parameter NUM 		= 8;	// how many numbers to be generated.

	localparam CNT_SIZE = NUM*DELAY8*FREQ_HZ;
	localparam IDLE 	= 1'd0;
	localparam RUN  	= 1'd1;
	
	logic						curr_state,next_state;  // record the state in FSM
	logic [3:0]					curr_random,next_random; // record the random number generated by the random generator
	logic [$clog2(NUM):0]		curr_num,next_num; // indicate how many random numbers have already been generated, whose value is from 1 to NUM
	logic [$clog2(CNT_SIZE):0] 	curr_cnt,next_cnt; // to count clock cycles, which used in time delay
	logic [$clog2(NUM):0]		curr_stage,next_stage; // in different stages, numbers will be kept in different time, which achieves to change frequency  
	logic						en; // when enable=1, random generator will generate a random number
	logic						done; // when done = 1, it means that the last random number has beem output
	
	assign 	done = (curr_num == NUM) ? 1'b1 : 1'b0;

/*=============== FSM ===================*/

	always_ff @(posedge i_clk or negedge i_rst) begin
		if(!i_rst) begin
			curr_state <= IDLE;
		end
		else begin
			curr_state <= next_state;
		end
	end

	always_comb begin
		if(i_start) begin
			next_state = RUN;
		end
		else if (done) begin
			next_state = IDLE;
		end
		else begin
			next_state = curr_state;
		end
	end
	
/*============= Random Generator ==============*/	
	
	assign o_random_out = curr_random;
	
	always_ff @(posedge i_clk or negedge i_rst) begin
		if(!i_rst) begin
			curr_random <= 0;
			curr_num	<= 0;
		end
		else begin
			curr_random <= next_random;
			curr_num	<= next_num;
		end
	end
	
	always_comb begin
		if (curr_state == IDLE) begin
			next_random = curr_random;
			next_num	= 0;
		end
		else begin // state = RUN
			if(en)begin
				if(i_start) begin // restart
					next_random = (curr_random + 3) % 16;
					next_num	= 1; // reset
				end
				else begin
					next_random = (curr_random + 3) % 16;
					next_num	= curr_num + 1;
				end
			end
			else begin
				next_random = curr_random;
				next_num	= curr_num;
			end
		end
	end

	
/*=============== Time delay =================*/
	
	always_ff @(posedge i_clk or negedge i_rst) begin
		if(!i_rst) begin
			curr_cnt 	<= 0;
			curr_stage 	<= 0;
		end
		else begin
			curr_cnt 	<= next_cnt;
			curr_stage 	<= next_stage;
		end		
	end
	
	always_comb begin
		if(curr_state ==  IDLE) begin 
			next_cnt 	= 0;
			next_stage 	= 0;
			en		 	= 0;
		end
		else if(curr_state == RUN && i_start) begin
			next_cnt 	= 1;
			next_stage 	= 1;
			en		 	= 1;
		end
		else begin
			next_cnt 	= curr_cnt + 1;
			next_stage	= curr_stage;
			en			= 0;
			case(curr_stage)
				0: begin // to prevent if stage is initiated to 1, curr_stage will directly add 1, which isn't I want
					next_stage	= curr_stage +1;
					en = 1; // restart
				end
				1: begin
					if((curr_cnt % (DELAY1*FREQ_HZ)) == 0) begin
						next_cnt 	= 1;
						next_stage	= curr_stage +1;
						en 			= 1;
					end
					else
						en = 0;
				end
				2: begin
					if((curr_cnt % (DELAY2*FREQ_HZ)) == 0) begin
						next_cnt 	= 1;
						next_stage	= curr_stage +1;
						en 			= 1;
					end
					else
						en = 0;
				end
				3: begin
					if((curr_cnt % (DELAY3*FREQ_HZ)) == 0) begin
						next_cnt 	= 1;
						next_stage	= curr_stage +1;
						en 			= 1;
					end
					else
						en = 0;
				end
				4: begin
					if((curr_cnt % (DELAY4*FREQ_HZ)) == 0) begin
						next_cnt 	= 1;
						next_stage	= curr_stage +1;
						en 			= 1;
					end
					else
						en = 0;
				end
				5: begin
					if((curr_cnt % (DELAY5*FREQ_HZ)) == 0) begin
						next_cnt 	= 1;
						next_stage	= curr_stage +1;
						en 			= 1;
					end
					else
						en = 0;
				end
				6: begin
					if((curr_cnt % (DELAY6*FREQ_HZ)) == 0) begin
						next_cnt 	= 1;
						next_stage	= curr_stage +1;
						en 			= 1;
					end
					else
						en = 0;
				end
				7: begin
					if((curr_cnt % (DELAY7*FREQ_HZ)) == 0) begin
						next_cnt 	= 1;
						next_stage	= curr_stage +1;
						en 			= 1;
					end
					else
						en = 0;
				end
				8: begin
					if((curr_cnt % (DELAY8*FREQ_HZ)) == 0) begin
						next_cnt 	= 1;
						next_stage	= curr_stage +1;
						en 			= 1;
					end
					else
						en = 0;
				end
				default:
					en = 0;
			endcase			
		end
	end
	


endmodule
