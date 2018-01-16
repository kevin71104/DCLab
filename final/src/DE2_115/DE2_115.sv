module DE2_115(
	input CLOCK_50,
	input CLOCK2_50,
	input CLOCK3_50,
	input ENETCLK_25,
	input SMA_CLKIN,
	output SMA_CLKOUT,
	output [8:0] LEDG,
	output [17:0] LEDR,
	input [3:0] KEY,
	input [17:0] SW,
	output [6:0] HEX0,
	output [6:0] HEX1,
	output [6:0] HEX2,
	output [6:0] HEX3,
	output [6:0] HEX4,
	output [6:0] HEX5,
	output [6:0] HEX6,
	output [6:0] HEX7,
	output LCD_BLON,
	inout [7:0] LCD_DATA,
	output LCD_EN,
	output LCD_ON,
	output LCD_RS,
	output LCD_RW,
	output UART_CTS,
	input UART_RTS,
	input UART_RXD,
	output UART_TXD,
	inout PS2_CLK,
	inout PS2_DAT,
	inout PS2_CLK2,
	inout PS2_DAT2,
	output SD_CLK,
	inout SD_CMD,
	inout [3:0] SD_DAT,
	input SD_WP_N,
	output [7:0] VGA_B,
	output VGA_BLANK_N,
	output VGA_CLK,
	output [7:0] VGA_G,
	output VGA_HS,
	output [7:0] VGA_R,
	output VGA_SYNC_N,
	output VGA_VS,
	input AUD_ADCDAT,
	inout AUD_ADCLRCK,
	inout AUD_BCLK,
	output AUD_DACDAT,
	inout AUD_DACLRCK,
	output AUD_XCK,
	output EEP_I2C_SCLK,
	inout EEP_I2C_SDAT,
	output I2C_SCLK,
	inout I2C_SDAT,
	output ENET0_GTX_CLK,
	input ENET0_INT_N,
	output ENET0_MDC,
	input ENET0_MDIO,
	output ENET0_RST_N,
	input ENET0_RX_CLK,
	input ENET0_RX_COL,
	input ENET0_RX_CRS,
	input [3:0] ENET0_RX_DATA,
	input ENET0_RX_DV,
	input ENET0_RX_ER,
	input ENET0_TX_CLK,
	output [3:0] ENET0_TX_DATA,
	output ENET0_TX_EN,
	output ENET0_TX_ER,
	input ENET0_LINK100,
	output ENET1_GTX_CLK,
	input ENET1_INT_N,
	output ENET1_MDC,
	input ENET1_MDIO,
	output ENET1_RST_N,
	input ENET1_RX_CLK,
	input ENET1_RX_COL,
	input ENET1_RX_CRS,
	input [3:0] ENET1_RX_DATA,
	input ENET1_RX_DV,
	input ENET1_RX_ER,
	input ENET1_TX_CLK,
	output [3:0] ENET1_TX_DATA,
	output ENET1_TX_EN,
	output ENET1_TX_ER,
	input ENET1_LINK100,
	input TD_CLK27,
	input [7:0] TD_DATA,
	input TD_HS,
	output TD_RESET_N,
	input TD_VS,
	inout [15:0] OTG_DATA,
	output [1:0] OTG_ADDR,
	output OTG_CS_N,
	output OTG_WR_N,
	output OTG_RD_N,
	input OTG_INT,
	output OTG_RST_N,
	input IRDA_RXD,
	output [12:0] DRAM_ADDR,
	output [1:0] DRAM_BA,
	output DRAM_CAS_N,
	output DRAM_CKE,
	output DRAM_CLK,
	output DRAM_CS_N,
	inout [31:0] DRAM_DQ,
	output [3:0] DRAM_DQM,
	output DRAM_RAS_N,
	output DRAM_WE_N,
	output [19:0] SRAM_ADDR,
	output SRAM_CE_N,
	inout [15:0] SRAM_DQ,
	output SRAM_LB_N,
	output SRAM_OE_N,
	output SRAM_UB_N,
	output SRAM_WE_N,
	output [22:0] FL_ADDR,
	output FL_CE_N,
	inout [7:0] FL_DQ,
	output FL_OE_N,
	output FL_RST_N,
	input FL_RY,
	output FL_WE_N,
	output FL_WP_N,
	inout [35:0] GPIO, // external output
	input HSMC_CLKIN_P1,
	input HSMC_CLKIN_P2,
	input HSMC_CLKIN0,
	output HSMC_CLKOUT_P1,
	output HSMC_CLKOUT_P2,
	output HSMC_CLKOUT0,
	inout [3:0] HSMC_D,
	input [16:0] HSMC_RX_D_P,
	output [16:0] HSMC_TX_D_P,
	inout [6:0] EX_IO
);
//=========== wire declaration ============
    localparam define_speed = 10;
    
    // KEY[1] KEY[2]
    logic       start;
    logic       pause;
    
    // slice_counter
    logic       slice;
    logic [4:0] slice_num;
    
    // controller 
    logic           trigger;
    logic           valid;
    logic           triggerSuc;
    logic [31:0]    distance;
    logic           finish;
    logic           cut;
    logic           cut_end;
    logic           move;
    logic           back;
    
    // cut
    logic   new_clk0;
    logic   en_cut;
    logic   direction_cut;
    
    // move
    logic   new_clk1;

// ============ On Board FPGA =============
 
    // KEY + Debounce
	Debounce deb1(
		.i_in(KEY[1]),
		.i_rst(KEY[0]),
		.i_clk(CLOCK_50),
		.o_neg(start) // Debounce output
	);
    Debounce deb2(
		.i_in(KEY[2]),
		.i_rst(KEY[0]),
		.i_clk(CLOCK_50),
		.o_neg(pause)
	);
    Debounce deb3(
		.i_in(KEY[3]),
		.i_rst(KEY[0]),
		.i_clk(CLOCK_50),
		.o_neg(slice)
	);
    
    // 7 segment displayer
	SevenHexDecoder seven_dec0(
        .clk        (CLOCK_50)
        .rst_n      (KEY[0])
        .start_i    (start),
        .pause_i    (pause),
        .slice_num_i(slice_num), // cut into how many pieces
        .finish_i   (finish),
        .HEX0_o     (HEX0),  
        .HEX1_o     (HEX1),
        .HEX2_o     (HEX2),
        .HEX3_o     (HEX3),
        .HEX4_o     (HEX4),
        .HEX5_o     (HEX5),
        .HEX6_o     (HEX6),
        .HEX7_o     (HEX7)
	);

//========== FPGA Logic Design =============
   
    controller controller(
        .clk        (CLOCK_50),
		.rst_n      (KEY[0]),
		.start      (start),
		.pause      (pause),
		.slice_num  (slice_num),
		.valid      (valid),
		.distance   (distance),
		.triggerSuc (triggerSuc),
		.trigger    (trigger),
		.move       (move),
        .back       (back),
		.cut_end    (cut_end),
		.cut        (cut),
        .finish     (finish)
    )
    
    supersonic supersonic0(
		.clk        (CLOCK_50),
		.rst_n      (KEY[0]),
		.echo       (),
		.valid      (valid),
		.distance   (distance),
        .triggerSuc (triggerSuc),
		.trigger    (trigger)
	);

    // cut
    cut_controller #(
        .define_speed(define_speed)
    )cut_controller0(
		.clk        (CLOCK_50),
		.rst_n      (KEY[0]),
		.cut_i      (cut),
		.cut_end_o  (cut_end),
		.en_o       (en_cut),
        .direction_o(direction_cut)
    );
    
    clock_div #(
        .define_speed(define_speed)
    )clock_div0(
		.clk        (CLOCK_50),
		.rst_n      (KEY[0]),
		.new_clk    (new_clk0) 
    );
    
    track_step_driver cutting_step_driver0(
		.clk        (new_clk0),
		.rst_n      (KEY[0]),
		.en         (en_cut),
		.direction  (direction_cut), 
		.signal     ()
    );
    
    slice_counter slice_counter0(
        .clk        (CLOCK_50),
        .rst_n      (KEY[0]),
        .slice_i    (slice),
        .slice_num_o(slice_num) 
    )
    
    // move
    clock_div #(
        .define_speed(define_speed)
    )clock_div1(
		.clk        (CLOCK_50),
		.rst_n      (KEY[0]),
		.new_clk    (new_clk1) 
    );
    
    track_step_driver track_step_driver0(
		.clk        (new_clk1),
		.rst_n      (KEY[0]),
		.en         (move),
		.direction  (back), 
		.signal     ()
    );

    
endmodule