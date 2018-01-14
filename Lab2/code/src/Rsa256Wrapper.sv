module ReadPipeline(
	input i_clk,
	input i_rst,
	output logic         data_val,
	input                data_rdy,
	output logic [255:0] o_a,
	output logic [255:0] o_n,
	output logic [255:0] o_e,
	output logic [4:0]  o_address,
	output logic        o_ren,
	input               i_wait,
	input               i_readdatavalid,
	input        [31:0] i_readdata,
	input i_sent
);
  /*=====================================
    Detail information about I/O
    =====================================
  ***** the name ReadPipeline is misleading, beacuse read/write operaton can be
        performed at the same time

  output  data_val:         If 1, it means data (o_a,o_n,o_e) is ready for 
                            Rsa256Core to be gathered
    
  input   data_rdy:         If 1, it means data(o_a,o_n,o_e) is gathered by 
                              Rsa256Core, thus next data (o_a) can be gathered
    
  output  [255:0]           o_a(data for de/encryption), o_n(n), o_e(e)
    
  output  [4:0] o_address:  We want to check Status(0x8) first. If rrdy is 1, 
                            it means data is ready in reciever and we can get 
                            Rxdata(0x0)
    
  output  o_ren:            Force Avalon interface to fetch data from address. 
                            First set 1 then set 0 after knowing rrdy is 1 and 
                            getting Rxdata(0x0) to avoid Rxdata retransmitted
                            by Avalon master
    
  input   i_wait:           If 1, it means Avalon interface is not prepared for 
                            request(read/write/check_status request)
    
  input   i_readdatavalid:  If 1, it means data requested by o_address from 
                            Avalon interface is prepared
    
  input   [31:0] i_readdata:  Rxdata/Txdata(1B) or Status from Avalon master 
                              which is requested by o_address 

  input   i_sent:           If 1, it means cipher text is decoded and it is 
                            ready to be sent
  ======================================*/

  parameter KEY_LEN = 256;                // Number of bits for key and cipher 
                                          // text
  parameter TRANS_LEN = 8;                // Number of bits for per data 
                                          // transmission

  parameter TRANS_NUM = KEY_LEN/TRANS_LEN;// Times of transmission required for
                                          // gathering $KEY_LEN bits by 
                                          // transmitting $TRANS_LEN bits per time

<<<<<<< HEAD
  localparam CHECK_READ = 1'd0;           // check whether rrdy = 1 for data 
                                          // retrevial

  localparam GET_KEY = 1'd1;              // check whether key already gotten
  localparam GET_DATA = 1'd2;             // check whether data already gotten
  localparam WAIT_CALC = 1'd3;            // check whether calculation in 
=======
  localparam CHECK_READ = 2'd0;           // check whether rrdy = 1 for data 
                                          // retrevial

  localparam GET_KEY = 2'd1;              // check whether key already gotten
  localparam GET_DATA = 2'd2;             // check whether data already gotten
  localparam WAIT_CALC = 2'd3;            // check whether calculation in 
>>>>>>> 7854cc16d125a44362affbf28899a49c08ba1c5c
                                          // RSACore finished


  logic                         curr_state,next_state;
  logic                         rrdy;                   
                                // If rrdy = 1, we can successsfully retrieve data

  logic [TRANS_NUM-1:0]         curr_cnt,next_cnt;      
                                // count how many bytes are already gotten          
                                // In order to avoid adder being synthsized
                                // (large area occupied), we modified "add 1"
                                // to "set 1 bit to 1"

  logic [2:0]                   curr_infostatus,next_infostatus;
                                // each bit indicate whether (a,e,n) is gotten
  logic [255:0]                 curr_a, next_a, curr_n, next_n, curr_e, next_e;
    
  
  assign rrdy = (i_readdatavalid) ? i_readdata[7] : 1'b0 ;
    
  assign o_a = curr_a;
  assign o_n = curr_n;
  assign o_e = curr_e;     

  always_ff @(posedge i_clk or negedge i_rst) begin
    if(!i_rst) begin
      // curr_rdy <= 0;
      curr_state <= CHECK_READ;
      curr_cnt <= 0;
            
      curr_a <= 0;
      curr_n <= 0;
      curr_e <= 0; 
    end    
    else begin 
      curr_state <= next_state;
    end
  end

  /*===== State transition ====*/
  always_comb begin 
    // default: next_state = curr_state
    next_state = curr_state;
    
    if(curr_state == CHECK_READ) begin
      if(i_wait) begin
        next_state = curr_state;
      end
      else if(!i_wait & rrdy & !curr_infostatus[1]) begin
        // curr_infostatus[1] == 1'b0 means nothing or only n is gotten
        next_state = GET_KEY;
      end
      else if(!i_wait & rrdy & !curr_infostatus[2] & (&curr_infostatus[1:0])) begin
        // curr_infostatus[1:0] == 2'b1 means n,e are already gotten
        next_state = GET_DATA;
      end
      else if(&curr_infostatus) begin
        // curr_infostatus == 3'b1 means n,e,d are all gotten
        next_state = WAIT_CALC;
      end
      else begin
        next_state = curr_state;
      end
    end
    
    else if(curr_state == GET_KEY) begin
      if(!i_wait & i_readdatavalid) begin
        next_state = CHECK_READ;
      end
      else begin
        next_state = curr_state;
      end
    end
    
    else if(curr_state == GET_DATA) begin
      if(!i_wait & i_readdatavalid) begin
        next_state = CHECK_READ;
      end
      else begin
        next_state = curr_state;
      end
    end
    
    else if(curr_state == WAIT_CALC) begin
      if(i_sent) begin
        // i_sent == 1 means decrypted already sent, thus, we can request next
        // cipher text for decryption
        next_state = CHECK_READ;
      end
      else begin
        next_state = curr_state;    
      end
    end
  
  end
       
  always_comb begin
    o_ren = 1'b1;
    o_address = 5'b01000;   // read STATUS
    data_val = 1'b0;        // (o_a,n,e is not ready)
    next_cnt = curr_cnt;    
    next_infostatus = curr_infostatus;

    next_a = curr_a;
    next_n = curr_n;
    next_e = curr_e;

        
    if(curr_state == GET_KEY) begin
      o_address = 5'b0;   // read RX_DATA
      if(i_readdatavalid) begin
        o_ren = 1'b0;
        if(&curr_cnt) begin
          // already gather 31 times
          next_cnt = 0;
          if(!curr_infostatus[0]) begin
            next_infostatus[0] = 1'b1;
            next_n = {curr_n[247:0], i_readdata[7:0]};
          end
          else if(!curr_infostatus[1] & curr_infostatus[0]) begin
            next_infostatus[1] = 1'b1;
            next_e = {curr_e[247:0], i_readdata[7:0]};
          end
        end
        else begin
          // gather less than 31 times
          next_cnt = {curr_cnt[TRANS_NUM-2:0],1'b1};
          if(!curr_infostatus[0]) begin
            next_n = {curr_n[247:0], i_readdata[7:0]}; // n not yet gathered
          end
          else if(!curr_infostatus[1] & curr_infostatus[0]) begin
            next_e = {curr_e[247:0], i_readdata[7:0]}; // e not yet gathered
          end
        end
      end
    end
    
    else if(curr_state == GET_DATA) begin
      o_address = 5'b0;   // read RX_DATA
      if(i_readdatavalid) begin
        o_ren = 1'b0;
        next_a = {curr_a[247:0], i_readdata[7:0]};
        if(&curr_cnt) begin
          next_cnt = 0;
          next_infostatus[2] = 1'b1;
        end
        else begin
          next_cnt = {curr_cnt[TRANS_NUM-2:0],1'b1};
        end  
      end
    end
    
    else if(curr_state == WAIT_CALC) begin
      o_ren = 1'b0;
      data_val = 1'b1;
    end
        
    else begin // CHECK_READ
      // pass
      o_ren = 1'b1;
    end
  end
endmodule

module WritePipeline(
	input i_clk,
	input i_rst,
	input                result_val,
	output logic         result_rdy,
	input        [255:0] i_a_pow_e,
	output logic [4:0]  o_address,
	output logic        o_ren,
	output logic        o_wen,
	input               i_wait,
	input               i_readdatavalid,
	input        [31:0] i_readdata,
	output logic [31:0] o_writedata,
	output logic o_sent
);
/*=====================================
  Detail information about I/O
  =====================================
  ***** the name ReadPipeline is misleading, beacuse read/write operaton can be  
        performed at the same time
  
  input   result_val:       If 1, it means data(i_a_pow_e) from RSA256Core is 
                            ready for writepipeline to be gathered

  output  result_rdy:       If 1, it means decrypted data(i_a_pow_e) is gathered 
                            by writepipeline, thus RSACore can discard i_a_pow_e
  
  input   [255:0] i_a_pow_e
  
  output  [4:0] o_address:  We want to check Status(0x8) first. If trdy is 1,
                            it means receiver is ready to be gather data, thus
                            next data(i_a_pow_e) can be inserted into Txdata(0x4)
  
  output  o_ren:            Force Avalon interface to fetch data from address
                            First set 1 then set 0 after knowing trdy is 1

  output  o_wen:            Enable writing data to TXdata(0x4). First set 1 then 
                            set 0 after finishing writing to avoid Txdata(0x4)
                            being overwrited
                            
  input   i_wait:           If 1, means Avalon interface is not prepared for 
                            request(read/write/check_status request)
  
  input   i_readdatavalid:  If 1, means data requested by o_address from Avalon
                            interface is prepared
  
  input   [31:0] i_readdata:  Rxdata/Txdata(1B) or Status from Avalon master which
                              is requested o_address
  
  output  [31:0] o_writedata: data to be written into Txdata
  
  output  o_sent:             If 1, means decrypted data is already sent
  ======================================*/
  parameter KEY_LEN = 256;                // Number of bits for key and cipher 
                                          // text
  parameter TRANS_LEN = 8;                // Number of bits for per data 
                                          // transmission
  parameter TRANS_NUM = KEY_LEN/TRANS_LEN;// Times of transmission required for
                                          // gathering $KEY_LEN bits by
                                          // transmitting $TRANS_LEN bits per
                                          // time
  parameter CHECK_WRITE = 2'd0;           // check whether rrdy = 1 for data 
                                          // retrieve
  parameter FEED_DEC = 2'd1;              // check whether decrypted data already
                                          // gotten
  parameter WAIT_CALC = 2'd2;             // check whether calculation in RSACore
                                          // finished
  
  logic                       curr_state,next_state;
  logic                       trdy;
                              // If trdy = 1, we can successfully retrieve data
  logic [TRANS_NUM-1:0]       curr_cnt,next_cnt;
                              // count how many bytes are already gotten
                              // In order to avoid adder being synthesized
                              // (large area occupied), we modified "add 1"
                              // to "set 1 bit to 1"
  logic                       cntinfo;
                              // indicate whether counter reached 32
  logic [255:0]               curr_dec_data,next_dec_data;
  
  assign cntinfo = &curr_cnt;
  assign trdy = (i_readdatavalid) ? i_readdata[6] : 1'b0 ;
  // how to determine the front 24 bits
  assign o_writedata = {24'b0, curr_dec_data[255:248]};
  
  always_ff @(posedge i_clk or negedge i_rst) begin
    if(!i_rst) begin
      // curr_rdy <= 0;
      curr_state <= WAIT_CALC;
      curr_cnt <= 0;
      curr_dec_data <= 0;
    end
    else begin
      curr_state <= next_state;
    end
  end

  /*===== State transition =====*/
  always_comb begin
    // default: next_state = curr_state
    next_state = curr_state;
    if(curr_state == CHECK_WRITE) begin
      if(cntinfo) begin
        next_state = WAIT_CALC;
      end
      else if(!i_wait & trdy & !cntinfo) begin
        next_state = FEED_DEC;
      end
      else begin
        next_state = curr_state;
      end
    end
    else if (curr_state == FEED_DEC) begin
      if(!i_wait & i_readdatavalid) begin
        next_state = CHECK_WRITE;
      end
      else begin
        next_state = curr_state;
      end
    end
    else if (curr_state == WAIT_CALC) begin
      if(result_val) begin
        next_state = CHECK_WRITE;
      end
      else begin
        next_state = curr_state;
      end
    end
    else begin
      next_state = curr_state;
    end
  end
  
  always_comb begin
    o_ren = 1'b1;
    o_wen = 1'b0;
    o_address = 5'b01000;
    result_rdy = 1'b0;
    next_cnt = curr_cnt;
    next_dec_data = curr_dec_data;
    
    o_sent = 1'b0;

    if(curr_state == WAIT_CALC) begin
      o_ren = 1'b0;
      if(result_val) begin
        next_dec_data = {i_a_pow_e[247:0], 8'b0};
        result_rdy = 1'b1;
      end
      if(cntinfo) begin
        next_cnt = 0;
        o_sent = 1'b1;
      end
    end
    else if(curr_state == CHECK_WRITE) begin
      o_ren =1'b1;
    end
    else if(curr_state == FEED_DEC) begin
      o_wen = 1'b1;
      o_ren = 1'b0;
      o_address = 5'b0100;
      next_cnt = {curr_cnt[TRANS_NUM-2:0], 1'b1};
      next_dec_data = {curr_dec_data[247:0], 8'b0};
    end
  end
endmodule

module Rsa256Wrapper(
	input avm_rst,
	input avm_clk,
	output logic [4:0]  avm_address,
	output logic        avm_read,
	output logic        avm_write,
	input               avm_waitrequest,
	input logic         avm_readdatavalid,
	input        [31:0] avm_readdata,
	output logic [31:0] avm_writedata
);
	// Feel free to use TA's template, of course you can use yours
	logic        wp_ren;
	logic        wp_wen;
	logic [4:0]  wp_addr;
	logic        rp_ren;
	logic [4:0]  rp_addr;
	logic sent;
	logic rsa_out_val;
	logic rsa_out_rdy;
	logic [255:0] rsa_enc;
	logic [255:0] rsa_e;
	logic [255:0] rsa_n;
	logic rsa_in_val;
	logic rsa_in_rdy;
	logic [255:0] rsa_dec;
	assign avm_read = rp_ren || wp_ren;
	assign avm_write = wp_wen;
	always_comb begin
		unique case (1'b1)
			(wp_ren||wp_wen): begin avm_address = wp_addr; end
			rp_ren: begin avm_address = rp_addr; end
			default: begin avm_address = 0; end
		endcase
	end
	Rsa256Core u_core(
		.i_clk(avm_clk),
		.i_rst(avm_rst),
		.src_val(rsa_in_val),
		.src_rdy(rsa_in_rdy),
		.i_a(rsa_enc),
		.i_e(rsa_e),
		.i_n(rsa_n),
		.result_val(rsa_out_val),
		.result_rdy(rsa_out_rdy),
		.o_a_pow_e(rsa_dec)
	);
	ReadPipeline u_read(
		.i_clk(avm_clk),
		.i_rst(avm_rst),
		// to core
		.data_val(rsa_in_val),
		.data_rdy(rsa_in_rdy),
		.o_a(rsa_enc),
		.o_e(rsa_e),
		.o_n(rsa_n),
		// avalon
		.o_address(rp_addr),
		.o_ren(rp_ren),
		.i_wait(avm_waitrequest),
		.i_readdatavalid(avm_readdatavalid),
		.i_readdata(avm_readdata),
		// write pipeline
		.i_sent(sent)
	);
	WritePipeline u_write(
		.i_clk(avm_clk),
		.i_rst(avm_rst),
		// from core
		.result_val(rsa_out_val),
		.result_rdy(rsa_out_rdy),
		.i_a_pow_e(rsa_dec),
		// avalon
		.o_address(wp_addr),
		.o_ren(wp_ren),
		.o_wen(wp_wen),
		.i_wait(avm_waitrequest),
		.i_readdatavalid(avm_readdatavalid),
		.i_readdata(avm_readdata),
		.o_writedata(avm_writedata),
		// read pipeline
		.o_sent(sent)
	);
endmodule
