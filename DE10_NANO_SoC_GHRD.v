/*
 * Top Level system description for BL4N HSBPM  module.
 * Shengli Liu, 
 * Oct. 20,2022
 */

//----------------------------------
// notes: 
// Oct 20,2022: Copied from E_linac_RF_shield_upgrade project
// Nov 27, 2023:  - Added CHx_ADC_OFFSET parameters to account for channel offsets.
// Jan 05 2024 - added 15 tap FIR on ADC input to reduce noise. Filter has 4x gain to increase threshold.
// Jan 09 2024 - Added vertical (Y) channel. Not working/tested yet.
// 
//-----------------------------

//parameter FPGA_VERSION_NO = 32'd0047; //verification
parameter FPGA_VERSION_NO = 32'd20240123; // Modified on jan 23, 2024

module DE10_NANO_SoC_GHRD(

    //////////// CLOCK //////////
    input               FPGA_CLK1_50,
    input               FPGA_CLK2_50,
    input               FPGA_CLK3_50,

    //////////// HDMI //////////
    inout               HDMI_I2C_SCL,
    inout               HDMI_I2C_SDA,
    inout               HDMI_I2S,
    inout               HDMI_LRCLK,
    inout               HDMI_MCLK,
    inout               HDMI_SCLK,
    output              HDMI_TX_CLK,
    output   [23: 0]    HDMI_TX_D,
    output              HDMI_TX_DE,
    output              HDMI_TX_HS,
    input               HDMI_TX_INT,
    output              HDMI_TX_VS,

    //////////// HPS //////////
    inout               HPS_CONV_USB_N,
    output   [14: 0]    HPS_DDR3_ADDR,
    output   [ 2: 0]    HPS_DDR3_BA,
    output              HPS_DDR3_CAS_N,
    output              HPS_DDR3_CK_N,
    output              HPS_DDR3_CK_P,
    output              HPS_DDR3_CKE,
    output              HPS_DDR3_CS_N,
    output   [ 3: 0]    HPS_DDR3_DM,
    inout    [31: 0]    HPS_DDR3_DQ,
    inout    [ 3: 0]    HPS_DDR3_DQS_N,
    inout    [ 3: 0]    HPS_DDR3_DQS_P,
    output              HPS_DDR3_ODT,
    output              HPS_DDR3_RAS_N,
    output              HPS_DDR3_RESET_N,
    input               HPS_DDR3_RZQ,
    output              HPS_DDR3_WE_N,
    output              HPS_ENET_GTX_CLK,
    inout               HPS_ENET_INT_N,
    output              HPS_ENET_MDC,
    inout               HPS_ENET_MDIO,
    input               HPS_ENET_RX_CLK,
    input    [ 3: 0]    HPS_ENET_RX_DATA,
    input               HPS_ENET_RX_DV,
    output   [ 3: 0]    HPS_ENET_TX_DATA,
    output              HPS_ENET_TX_EN,
    inout               HPS_GSENSOR_INT,
    inout               HPS_I2C0_SCLK,
    inout               HPS_I2C0_SDAT,
    inout               HPS_I2C1_SCLK,
    inout               HPS_I2C1_SDAT,
    inout               HPS_KEY,
    inout               HPS_LED,
    inout               HPS_LTC_GPIO,
    output              HPS_SD_CLK,
    inout               HPS_SD_CMD,
    inout    [ 3: 0]    HPS_SD_DATA,
    output              HPS_SPIM_CLK,
    input               HPS_SPIM_MISO,
    output              HPS_SPIM_MOSI,
    inout               HPS_SPIM_SS,
    input               HPS_UART_RX,
    output              HPS_UART_TX,
    input               HPS_USB_CLKOUT,
    inout    [ 7: 0]    HPS_USB_DATA,
    input               HPS_USB_DIR,
    input               HPS_USB_NXT,
    output              HPS_USB_STP,

	 //////////// GPIO //////////
	 
	 input GPIO_1_0,  // Trigger
	 output GPIO_1_1, //
	 output GPIO_1_2, //
	 output GPIO_1_3, //

	 output GPIO_1_4, //VGA_GAIN_A1
	 output GPIO_1_7, //VGA_GAIN_A0
	 output GPIO_1_5, //ST_ON
	 
	//ADC 
	output GPIO_1_34, //ADC_CLKAB
	input  GPIO_1_21, //ADC_DA0
	input  GPIO_1_18, //ADC_DA1
	input  GPIO_1_19, //ADC_DA2
	input  GPIO_1_16, //ADC_DA3
	input  GPIO_1_17, //ADC_DA4
	input  GPIO_1_14, //ADC_DA5
	input  GPIO_1_15, //ADC_DA6
	input  GPIO_1_12, //ADC_DA7
	input  GPIO_1_13, //ADC_DA8
	input  GPIO_1_10, //ADC_DA9
	input  GPIO_1_11, //ADC_DA10
	input  GPIO_1_8, //ADC_DA11
	input  GPIO_1_9, //ADC_DA12
	input  GPIO_1_6, //ADC_DA13
	
	input  GPIO_1_35, //ADC_DB0
	input  GPIO_1_32, //ADC_DB1
	input  GPIO_1_33, //ADC_DB2
	input  GPIO_1_30, //ADC_DB3
	input  GPIO_1_31, //ADC_DB4
	input  GPIO_1_28, //ADC_DB5
	input  GPIO_1_29, //ADC_DB6
	input  GPIO_1_26, //ADC_DB7
	input  GPIO_1_27, //ADC_DB8
	input  GPIO_1_24, //ADC_DB9
	input  GPIO_1_25, //ADC_DB10
	input  GPIO_1_22, //ADC_DB11
	input  GPIO_1_23, //ADC_DB12
	input  GPIO_1_20, //ADC_DB13
	
	output GPIO_0_1, //ADC_CLKCD
	input  GPIO_0_14, //ADC_DC0
	input  GPIO_0_17, //ADC_DC1
	input  GPIO_0_16, //ADC_DC2
	input  GPIO_0_19, //ADC_DC3
	input  GPIO_0_18, //ADC_DC4
	input  GPIO_0_21, //ADC_DC5
	input  GPIO_0_20, //ADC_DC6
	input  GPIO_0_23, //ADC_DC7
	input  GPIO_0_22, //ADC_DC8
	input  GPIO_0_25, //ADC_DC9
	input  GPIO_0_24, //ADC_DC10
	input  GPIO_0_27, //ADC_DC11
	input  GPIO_0_26, //ADC_DC12
	input  GPIO_0_29, //ADC_DC13
	
	input  GPIO_0_0, //ADC_DD0
	input  GPIO_0_3, //ADC_DD1
	input  GPIO_0_2, //ADC_DD2
	input  GPIO_0_5, //ADC_DD3
	input  GPIO_0_4, //ADC_DD4
	input  GPIO_0_7, //ADC_DD5
	input  GPIO_0_6, //ADC_DD6
	input  GPIO_0_9, //ADC_DD7
	input  GPIO_0_8, //ADC_DD8
	input  GPIO_0_11, //ADC_DD9
	input  GPIO_0_10, //ADC_DD10
	input  GPIO_0_13, //ADC_DD11
	input  GPIO_0_12, //ADC_DD12
	input  GPIO_0_15, //ADC_DD13
	 
	 input  GPIO_0_32,  //HPS_Cold_Reset 
	 output GPIO_0_34,  //LED_RUNNING
	 output GPIO_0_35,  //LED_Fault
		 
	 //i2c eeprom
	 output GPIO_0_31, //SCL
	 inout  GPIO_0_33, //SDA
	 
	 input GPIO_0_28, //trigger 
	 inout GPIO_0_30, //temp	 
	 
    //////////// KEY //////////
    input    [ 1: 0]    KEY,

    //////////// LED //////////
    output   [ 7: 0]    LED,

    //////////// SW //////////
    input    [ 3: 0]    SW
);


`include "src/param.v"

`define 	FP_CH0_NF {configuration[3],configuration[2],configuration[1],configuration[0]}
`define 	FP_CH1_NF {configuration[7],configuration[6],configuration[5],configuration[4]}
`define 	FP_CH2_NF {configuration[11],configuration[10],configuration[9],configuration[8]}
`define 	FP_CH3_NF {configuration[15],configuration[14],configuration[13],configuration[12]}

`define 	TRANSITION {configuration[17],configuration[16]}

`define 	CON_REG_L configuration[18]
`define 	CON_REG_H configuration[19]

`define 	TRIG_TH  {configuration[21],configuration[20]}

`define 	FP_KXY {configuration[25],configuration[24],configuration[23],configuration[22]}
`define 	X_OFFSET {configuration[27],configuration[26]}
`define 	Y_OFFSET {configuration[29],configuration[28]}

`define 	MODULE_ID0  {configuration[33],configuration[32],configuration[31],configuration[30]}
`define 	MODULE_ID1  {configuration[37],configuration[36],configuration[35],configuration[34]}
`define 	MODULE_ID2  {configuration[41],configuration[40],configuration[39],configuration[38]}
`define 	MODULE_ID3  {configuration[45],configuration[44],configuration[43],configuration[42]}

`define 	IIR_OUT_K2 {configuration[49],configuration[48],configuration[47],configuration[46]}
`define 	CAL_DC   configuration[50]
`define 	CAL_AMP  configuration[51]

`define 	CH0_ADC_OFFSET  {configuration[53],configuration[52]}
`define 	CH1_ADC_OFFSET  {configuration[55],configuration[54]}

//=======================================================
//  REG/WIRE declarations
//=======================================================
wire hps_fpga_reset_n;
wire     [1: 0]     fpga_debounced_buttons;
wire     [6: 0]     fpga_led_internal;
wire     [2: 0]     hps_reset_req;
wire                hps_cold_reset;
wire                hps_warm_reset;
wire                hps_debug_reset;
wire     [27: 0]    stm_hw_events;
wire                fpga_clk_50;

// connection of internal logics

assign LED[7: 1] = fpga_led_internal;
assign fpga_clk_50 = FPGA_CLK1_50;
assign stm_hw_events = {{15{1'b0}}, SW, fpga_led_internal, fpga_debounced_buttons};


/////////////////// GPIO pin mapping ://///////////////////////////////////////////////////////////////////
//GPIO mapping start:
wire ext_trigger = GPIO_1_0;	 
wire LED_RUNNING;
wire LED_Fault = Cold_Reset_Req;
wire Cold_Reset_Req = ~GPIO_0_32;  //cold reset push button from front panel 
assign GPIO_0_34 = LED_RUNNING;  //LED_COMM, indicating communication activity, not implemented yet.
assign GPIO_0_35 = LED_Fault;  //should response to reset_push button action? 

wire VGA_GAIN_A1,VGA_GAIN_A0;
assign GPIO_1_4 = VGA_GAIN_A1;
assign GPIO_1_7 = VGA_GAIN_A0;

//ADC interface
wire [13:0] ADC_DA,ADC_DB,ADC_DC,ADC_DD;

assign GPIO_1_34 = ADC_CLK;
assign GPIO_0_1 = ADC_CLK;
	
assign ADC_DA[0] = GPIO_1_21; //ADC_DA0
assign ADC_DA[1] = GPIO_1_18; //ADC_DA1
assign ADC_DA[2] = GPIO_1_19; //ADC_DA2
assign ADC_DA[3] = GPIO_1_16; //ADC_DA3
assign ADC_DA[4] = GPIO_1_17; //ADC_DA4
assign ADC_DA[5] = GPIO_1_14; //ADC_DA5
assign ADC_DA[6] = GPIO_1_15; //ADC_DA6
assign ADC_DA[7] = GPIO_1_12; //ADC_DA7
assign ADC_DA[8] = GPIO_1_13; //ADC_DA8
assign ADC_DA[9] = GPIO_1_10; //ADC_DA9
assign ADC_DA[10] = GPIO_1_11; //ADC_DA10
assign ADC_DA[11] = GPIO_1_8; //ADC_DA11
assign ADC_DA[12] = GPIO_1_9; //ADC_DA12
assign ADC_DA[13] = GPIO_1_6; //ADC_DA13
	
assign ADC_DB[0] = GPIO_1_35; //ADC_DB0
assign ADC_DB[1] = GPIO_1_32; //ADC_DB1
assign ADC_DB[2] = GPIO_1_33; //ADC_DB2
assign ADC_DB[3] = GPIO_1_30; //ADC_DB3
assign ADC_DB[4] = GPIO_1_31; //ADC_DB4
assign ADC_DB[5] = GPIO_1_28; //ADC_DB5
assign ADC_DB[6] = GPIO_1_29; //ADC_DB6
assign ADC_DB[7] = GPIO_1_26; //ADC_DB7
assign ADC_DB[8] = GPIO_1_27; //ADC_DB8
assign ADC_DB[9] = GPIO_1_24; //ADC_DB9
assign ADC_DB[10] = GPIO_1_25; //ADC_DB10
assign ADC_DB[11] = GPIO_1_22; //ADC_DB11
assign ADC_DB[12] = GPIO_1_23; //ADC_DB12
assign ADC_DB[13] = GPIO_1_20; //ADC_DB13

assign ADC_DC[0] = GPIO_0_14; //ADC_DC0
assign ADC_DC[1] = GPIO_0_17; //ADC_DC1
assign ADC_DC[2] = GPIO_0_16; //ADC_DC2
assign ADC_DC[3] = GPIO_0_19; //ADC_DC3
assign ADC_DC[4] = GPIO_0_18; //ADC_DC4
assign ADC_DC[5] = GPIO_0_21; //ADC_DC5
assign ADC_DC[6] = GPIO_0_20; //ADC_DC6
assign ADC_DC[7] = GPIO_0_23; //ADC_DC7
assign ADC_DC[8] = GPIO_0_22; //ADC_DC8
assign ADC_DC[9] = GPIO_0_25; //ADC_DC9
assign ADC_DC[10] = GPIO_0_24; //ADC_DC10
assign ADC_DC[11] = GPIO_0_27; //ADC_DC11
assign ADC_DC[12] = GPIO_0_26; //ADC_DC12
assign ADC_DC[13] = GPIO_0_29; //ADC_DC13
	
assign ADC_DD[0] = GPIO_0_0; //ADC_DD0
assign ADC_DD[1] = GPIO_0_3; //ADC_DD1
assign ADC_DD[2] = GPIO_0_2; //ADC_DD2
assign ADC_DD[3] = GPIO_0_5; //ADC_DD3
assign ADC_DD[4] = GPIO_0_4; //ADC_DD4
assign ADC_DD[5] = GPIO_0_7; //ADC_DD5
assign ADC_DD[6] = GPIO_0_6; //ADC_DD6
assign ADC_DD[7] = GPIO_0_9; //ADC_DD7
assign ADC_DD[8] = GPIO_0_8; //ADC_DD8
assign ADC_DD[9] = GPIO_0_11; //ADC_DD9
assign ADC_DD[10] = GPIO_0_10; //ADC_DD10
assign ADC_DD[11] = GPIO_0_13; //ADC_DD11
assign ADC_DD[12] = GPIO_0_12; //ADC_DD12
assign ADC_DD[13] = GPIO_0_15; //ADC_DD13

////GPIO mapping end/////////////////////////////////
	
// clock generation
	
reg ST_on;	// This signal controls the input selector switch on the AFE. 
assign GPIO_1_5 = clk_10Hz; // Slightly advanced copy of ST_ON.  
	
wire pll_locked; 
wire SYS_RST = ~hps_fpga_reset_n;

wire SYS_CLK; // 50 MHz clock, locked to internal FPGA clock.
wire self_CLK; // 20 MHz clock, locked to internal FPGA clock.
wire ex_CLK; // Buffered copy of 23.05 MHz LO.
wire syn_CLK; // 20 MHz clock, locked to LO.
wire Sampling_CLK; // 20 MHz sampling clock for ADC. Either syn_CLK or self_CLK.

assign ADC_CLK = Sampling_CLK; //ADC clock 20 MHz, for AD9248-20.
wire SCLK = Sampling_CLK; //processing clock.

wire ADC_clksel;

clk20_pll clk_pll_inst0 
	(
		.refclk(FPGA_CLK1_50),
		.rst(SYS_RST),
		.outclk_0(SYS_CLK), // 50 MHz system clock
		.outclk_1(self_CLK),   // 20.0 Mhz created internally
		.locked()  //locked output
	);
	
clk_control clkcon_inst  //using external clk to drive GCLK network, since GPIO_0_28 is not dedicated clk pin
	(
	 .inclk(GPIO_0_28),  //External RF clk 23.05 MHz from Cyclotron
	 .outclk(ex_CLK)
	 );
	
	
clk23_pll clk23_pll_inst1
	(
		.refclk(ex_CLK), 
		.rst(SYS_RST),
		.outclk_0(syn_CLK), // 20.0 MHz, locked to external RF 23.05MHz
		.locked(pll_locked)  //locked output
	);	
	
clk_sel clk_sel_inst
	(
	.inclk2x(syn_CLK),  //20 MHz locked to external RF clk 23.05 MHz from Cyclotron
	.inclk3x(self_CLK),  //20 MHz internal clock
	.clkselect({1'b1,ADC_clksel}),
	.outclk(Sampling_CLK)
	 );

wire d_clk; 
wire DCLK/*synthesis keep*/; //2.5 MHz clk for demodulated envelop signal

clk_control clkbuf_inst  //buf to GCLK network 
	(
	 .inclk(d_clk),  //decimated clk, generated from DDC module
	 .outclk(DCLK)
	 );
	

reg [ADC_DATA_WIDTH-1:0] Ch0_ADC_DATA,	Ch1_ADC_DATA,Ch2_ADC_DATA,	Ch3_ADC_DATA/*synthesis keep*/;
// Sample 14 bit parallel ADC (AD9248-20). Data output format = two's compl.
always @ (posedge ADC_CLK) 
	begin 
		Ch0_ADC_DATA <= ADC_DA; Ch1_ADC_DATA <= ADC_DB; 
		Ch2_ADC_DATA <= ADC_DC; Ch3_ADC_DATA <= ADC_DD;
	end

//							================ I2C EEPROM Interface ===============
parameter CONF_BUF_SIZE = 128; //max = 128 bytes for 24AA025E48T

reg  [7:0] configuration [CONF_BUF_SIZE-1:0]; //configuration data 
wire [7:0] eeprom_buffer [CONF_BUF_SIZE-1:0];

wire eeprom_busy,eeprom_data_valid;
wire rd_eeprom,wr_eeprom /*synthesis keep*/;

	I2C_eeprom eeprom_inst(
          .clk(SYS_CLK),   
          .rst(SYS_RST),
          .conf_data(configuration),
          .read(rd_eeprom),
          .write(wr_eeprom),
			 
			 .buffer(eeprom_buffer),
			 .busy(eeprom_busy),
			 .valid(eeprom_data_valid),

          .SDA(GPIO_0_33),
          .SCL(GPIO_0_31)               
                     );
							

//							================ Defining CPU to FPGA interface ===============

//Avalon Memory Mapped Slave Bus declariation	
wire avalon_read, avalon_write,avalon_cs/*synthesis keep*/;
wire [31:0] avalon_addr,avalon_readdata,avalon_writedata/*synthesis keep*/;

reg [31:0] dout;
assign avalon_readdata = dout;

parameter integer 	SR_ADDR = 0;
parameter integer 	CR_ADDR = 1;
parameter integer 	MR_ADDR = 2;

parameter integer    FPGA_VER_ADDR = 3;  //FPGA version # 
parameter integer 	CH_SELECT_ADDR = 4; //select channel for FIFO transfer to host 
parameter integer 	PCA_GAIN_ADDR = 5;

parameter integer 	SFIFO_WD_ADDR = 7;
parameter integer 	SFIFO_ADDR = 8;

parameter integer 	FIFO_CLR_ADDR = 9;
parameter integer 	FIFO_WD_ADDR = 10;
parameter integer 	FIFO_ADDR = 11;

parameter integer 	EEPROM_RD_ADDR = 15;
parameter integer 	EEPROM_WR_ADDR = 16;

parameter integer 	FP_CH0_NF_ADDR = 17;
parameter integer 	FP_CH1_NF_ADDR = 18;
parameter integer 	FP_CH2_NF_ADDR = 19;
parameter integer 	FP_CH3_NF_ADDR = 20;

parameter integer 	FP_KXY_ADDR = 21;
parameter integer 	X_OFFSET_ADDR = 22;
parameter integer 	Y_OFFSET_ADDR = 23;

parameter integer 	TRIG_TH_ADDR = 30;
parameter integer 	TRANSITION_ADDR = 31;

parameter integer 	CAL_WAVE_ADDR = 33;

parameter integer 	IIR_OUT_K1_ADDR = 47;
parameter integer 	IIR_OUT_K2_ADDR = 48;

parameter integer 	CH0_ADC_OFFSET_ADDR = 49; // HJ changed name from CH1_DAC_PEAK_OFFSET_ADDR
parameter integer 	CH1_ADC_OFFSET_ADDR = 50; // CH1_DAC_AVG_OFFSET_ADDR

parameter integer 	CH2_DAC_PEAK_OFFSET_ADDR = 51;
parameter integer 	CH2_DAC_AVG_OFFSET_ADDR = 52;
	
parameter integer MODULE_ID0_ADDR = 71;
parameter integer MODULE_ID1_ADDR = 72;	

//===========================  Avalon Bus interface 	============================ 
soc_system u0(
               //Clock&Reset
               .clk_clk(FPGA_CLK1_50),                                      //                            clk.clk
               .reset_reset_n(hps_fpga_reset_n),                            //                          reset.reset_n
               //HPS ddr3
               .memory_mem_a(HPS_DDR3_ADDR),                                //                         memory.mem_a
               .memory_mem_ba(HPS_DDR3_BA),                                 //                               .mem_ba
               .memory_mem_ck(HPS_DDR3_CK_P),                               //                               .mem_ck
               .memory_mem_ck_n(HPS_DDR3_CK_N),                             //                               .mem_ck_n
               .memory_mem_cke(HPS_DDR3_CKE),                               //                               .mem_cke
               .memory_mem_cs_n(HPS_DDR3_CS_N),                             //                               .mem_cs_n
               .memory_mem_ras_n(HPS_DDR3_RAS_N),                           //                               .mem_ras_n
               .memory_mem_cas_n(HPS_DDR3_CAS_N),                           //                               .mem_cas_n
               .memory_mem_we_n(HPS_DDR3_WE_N),                             //                               .mem_we_n
               .memory_mem_reset_n(HPS_DDR3_RESET_N),                       //                               .mem_reset_n
               .memory_mem_dq(HPS_DDR3_DQ),                                 //                               .mem_dq
               .memory_mem_dqs(HPS_DDR3_DQS_P),                             //                               .mem_dqs
               .memory_mem_dqs_n(HPS_DDR3_DQS_N),                           //                               .mem_dqs_n
               .memory_mem_odt(HPS_DDR3_ODT),                               //                               .mem_odt
               .memory_mem_dm(HPS_DDR3_DM),                                 //                               .mem_dm
               .memory_oct_rzqin(HPS_DDR3_RZQ),                             //                               .oct_rzqin
               //HPS ethernet
               .hps_0_hps_io_hps_io_emac1_inst_TX_CLK(HPS_ENET_GTX_CLK),    //                   hps_0_hps_io.hps_io_emac1_inst_TX_CLK
               .hps_0_hps_io_hps_io_emac1_inst_TXD0(HPS_ENET_TX_DATA[0]),   //                               .hps_io_emac1_inst_TXD0
               .hps_0_hps_io_hps_io_emac1_inst_TXD1(HPS_ENET_TX_DATA[1]),   //                               .hps_io_emac1_inst_TXD1
               .hps_0_hps_io_hps_io_emac1_inst_TXD2(HPS_ENET_TX_DATA[2]),   //                               .hps_io_emac1_inst_TXD2
               .hps_0_hps_io_hps_io_emac1_inst_TXD3(HPS_ENET_TX_DATA[3]),   //                               .hps_io_emac1_inst_TXD3
               .hps_0_hps_io_hps_io_emac1_inst_RXD0(HPS_ENET_RX_DATA[0]),   //                               .hps_io_emac1_inst_RXD0
               .hps_0_hps_io_hps_io_emac1_inst_MDIO(HPS_ENET_MDIO),         //                               .hps_io_emac1_inst_MDIO
               .hps_0_hps_io_hps_io_emac1_inst_MDC(HPS_ENET_MDC),           //                               .hps_io_emac1_inst_MDC
               .hps_0_hps_io_hps_io_emac1_inst_RX_CTL(HPS_ENET_RX_DV),      //                               .hps_io_emac1_inst_RX_CTL
               .hps_0_hps_io_hps_io_emac1_inst_TX_CTL(HPS_ENET_TX_EN),      //                               .hps_io_emac1_inst_TX_CTL
               .hps_0_hps_io_hps_io_emac1_inst_RX_CLK(HPS_ENET_RX_CLK),     //                               .hps_io_emac1_inst_RX_CLK
               .hps_0_hps_io_hps_io_emac1_inst_RXD1(HPS_ENET_RX_DATA[1]),   //                               .hps_io_emac1_inst_RXD1
               .hps_0_hps_io_hps_io_emac1_inst_RXD2(HPS_ENET_RX_DATA[2]),   //                               .hps_io_emac1_inst_RXD2
               .hps_0_hps_io_hps_io_emac1_inst_RXD3(HPS_ENET_RX_DATA[3]),   //                               .hps_io_emac1_inst_RXD3
               //HPS SD card
               .hps_0_hps_io_hps_io_sdio_inst_CMD(HPS_SD_CMD),              //                               .hps_io_sdio_inst_CMD
               .hps_0_hps_io_hps_io_sdio_inst_D0(HPS_SD_DATA[0]),           //                               .hps_io_sdio_inst_D0
               .hps_0_hps_io_hps_io_sdio_inst_D1(HPS_SD_DATA[1]),           //                               .hps_io_sdio_inst_D1
               .hps_0_hps_io_hps_io_sdio_inst_CLK(HPS_SD_CLK),              //                               .hps_io_sdio_inst_CLK
               .hps_0_hps_io_hps_io_sdio_inst_D2(HPS_SD_DATA[2]),           //                               .hps_io_sdio_inst_D2
               .hps_0_hps_io_hps_io_sdio_inst_D3(HPS_SD_DATA[3]),           //                               .hps_io_sdio_inst_D3
               //HPS USB
               .hps_0_hps_io_hps_io_usb1_inst_D0(HPS_USB_DATA[0]),          //                               .hps_io_usb1_inst_D0
               .hps_0_hps_io_hps_io_usb1_inst_D1(HPS_USB_DATA[1]),          //                               .hps_io_usb1_inst_D1
               .hps_0_hps_io_hps_io_usb1_inst_D2(HPS_USB_DATA[2]),          //                               .hps_io_usb1_inst_D2
               .hps_0_hps_io_hps_io_usb1_inst_D3(HPS_USB_DATA[3]),          //                               .hps_io_usb1_inst_D3
               .hps_0_hps_io_hps_io_usb1_inst_D4(HPS_USB_DATA[4]),          //                               .hps_io_usb1_inst_D4
               .hps_0_hps_io_hps_io_usb1_inst_D5(HPS_USB_DATA[5]),          //                               .hps_io_usb1_inst_D5
               .hps_0_hps_io_hps_io_usb1_inst_D6(HPS_USB_DATA[6]),          //                               .hps_io_usb1_inst_D6
               .hps_0_hps_io_hps_io_usb1_inst_D7(HPS_USB_DATA[7]),          //                               .hps_io_usb1_inst_D7
               .hps_0_hps_io_hps_io_usb1_inst_CLK(HPS_USB_CLKOUT),          //                               .hps_io_usb1_inst_CLK
               .hps_0_hps_io_hps_io_usb1_inst_STP(HPS_USB_STP),             //                               .hps_io_usb1_inst_STP
               .hps_0_hps_io_hps_io_usb1_inst_DIR(HPS_USB_DIR),             //                               .hps_io_usb1_inst_DIR
               .hps_0_hps_io_hps_io_usb1_inst_NXT(HPS_USB_NXT),             //                               .hps_io_usb1_inst_NXT
               //HPS SPI
               .hps_0_hps_io_hps_io_spim1_inst_CLK(HPS_SPIM_CLK),           //                               .hps_io_spim1_inst_CLK
               .hps_0_hps_io_hps_io_spim1_inst_MOSI(HPS_SPIM_MOSI),         //                               .hps_io_spim1_inst_MOSI
               .hps_0_hps_io_hps_io_spim1_inst_MISO(HPS_SPIM_MISO),         //                               .hps_io_spim1_inst_MISO
               .hps_0_hps_io_hps_io_spim1_inst_SS0(HPS_SPIM_SS),            //                               .hps_io_spim1_inst_SS0
               //HPS UART
               .hps_0_hps_io_hps_io_uart0_inst_RX(HPS_UART_RX),             //                               .hps_io_uart0_inst_RX
               .hps_0_hps_io_hps_io_uart0_inst_TX(HPS_UART_TX),             //                               .hps_io_uart0_inst_TX
               //HPS I2C1
               .hps_0_hps_io_hps_io_i2c0_inst_SDA(HPS_I2C0_SDAT),           //                               .hps_io_i2c0_inst_SDA
               .hps_0_hps_io_hps_io_i2c0_inst_SCL(HPS_I2C0_SCLK),           //                               .hps_io_i2c0_inst_SCL
               //HPS I2C2
               .hps_0_hps_io_hps_io_i2c1_inst_SDA(HPS_I2C1_SDAT),           //                               .hps_io_i2c1_inst_SDA
               .hps_0_hps_io_hps_io_i2c1_inst_SCL(HPS_I2C1_SCLK),           //                               .hps_io_i2c1_inst_SCL
               //GPIO
               .hps_0_hps_io_hps_io_gpio_inst_GPIO09(HPS_CONV_USB_N),       //                               .hps_io_gpio_inst_GPIO09
               .hps_0_hps_io_hps_io_gpio_inst_GPIO35(HPS_ENET_INT_N),       //                               .hps_io_gpio_inst_GPIO35
               .hps_0_hps_io_hps_io_gpio_inst_GPIO40(HPS_LTC_GPIO),         //                               .hps_io_gpio_inst_GPIO40
               .hps_0_hps_io_hps_io_gpio_inst_GPIO53(HPS_LED),              //                               .hps_io_gpio_inst_GPIO53
               .hps_0_hps_io_hps_io_gpio_inst_GPIO54(HPS_KEY),              //                               .hps_io_gpio_inst_GPIO54
               .hps_0_hps_io_hps_io_gpio_inst_GPIO61(HPS_GSENSOR_INT),      //                               .hps_io_gpio_inst_GPIO61
               //FPGA Partion
               .led_pio_external_connection_export(fpga_led_internal),      //    led_pio_external_connection.export
               .dipsw_pio_external_connection_export(SW),                   //  dipsw_pio_external_connection.export
               .button_pio_external_connection_export(fpga_debounced_buttons),
                                                                            // button_pio_external_connection.export
               //.hps_0_h2f_reset_reset_n(hps_fpga_reset_n),                  //                hps_0_h2f_reset.reset_n
               
					.hps_0_f2h_cold_reset_req_reset_n(~Cold_Reset_Req),          //       hps_0_f2h_cold_reset_req.reset_n
               .hps_0_f2h_debug_reset_req_reset_n(~hps_debug_reset),        //      hps_0_f2h_debug_reset_req.reset_n
               .hps_0_f2h_stm_hw_events_stm_hwevents(stm_hw_events),        //        hps_0_f2h_stm_hw_events.stm_hwevents
               .hps_0_f2h_warm_reset_req_reset_n(~hps_warm_reset),          //       hps_0_f2h_warm_reset_req.reset_n
									                      
					.myavalonbus32_0_conduit_end_addr       (avalon_addr),       //myavalonbus32_0_avalon_slave.address
					.myavalonbus32_0_conduit_end_read       (avalon_read),      // .read
					.myavalonbus32_0_conduit_end_write      (avalon_write),     // .write
					.myavalonbus32_0_conduit_end_readdata   (avalon_readdata),   // .readdata
					.myavalonbus32_0_conduit_end_writedata  (avalon_writedata), // .writedata
					.myavalonbus32_0_conduit_end_cs 			 (avalon_cs),        // .chipselect
					.myavalonbus32_0_conduit_end_bus_clk    ()           //  myavalonbus32_0_clk.clk
		
				
           );



//							================ Configuration Register ===============
wire [15:0] status_reg = {channel_error[7:0],pll_locked,No_beam};

assign VGA_GAIN_A0 = `CON_REG_L[0];// CHANGE FOR V3
assign VGA_GAIN_A1 = `CON_REG_L[1];// CHANGE FOR V3

wire ch_select = `CON_REG_L[2];
assign ADC_clksel =  `CON_REG_L[3]; //select external clk or internal 23 Mhz clk
wire waveform_select = `CON_REG_L[4];
//`CON_REG[5]: not used for now.
wire Ena_ST = `CON_REG_L[6];
wire auto_trig_sel = `CON_REG_L[7];

wire ena_avg = `CON_REG_H[1]; //enable input FIR
wire is10mmpV = `CON_REG_H[2]; //DAC ratio: 10mm /V, or 1mm/V
wire [1:0] AVG_select = `CON_REG_H[4:3]; //Averaging times: 4,16,32, 64 four selections
wire cal_sel = `CON_REG_H[5]; // choose calibration. 1 for autocal, 0 for manual

wire pulse1KHz,auto_trig; 
wire DAC_update = trig; //changed from auto_trig. HJ Nov 29, 2023

// Generate 1126 Hz test pulse with a given duty cycle. CHANGE FOR V3 - pulse1KHz should be assimilated with ST_en (not ST_on) somehow.
Self_Test Self_Test_inst(
					.clk(SYS_CLK),
					.Dcycle(`CAL_DC),
					.trig(auto_trig), // mark the start of pulse.
					.pulse(pulse1KHz) // 1126 Hz pulse
					);

//							================ CPU to FPGA Communication ===============

reg fifo_clr_reg; //needs to reset by itself after one SYS_CLK
reg trip_clr_reg; //needs to be reset by itself after one SYS_CLK

wire avalon_write_i = avalon_write & avalon_cs;
wire avalon_read_i = avalon_read & avalon_cs;

reg avalon_write_o,avalon_read_o /*synthesis keep*/;
wire fifo_rd /*synthesis keep*/;
assign fifo_rd = (avalon_addr == FIFO_ADDR & (avalon_read_i == 1));

wire sfifo_rd /*synthesis keep*/;
assign sfifo_rd = (avalon_addr == SFIFO_ADDR & (avalon_read_i == 1)); 

assign rd_eeprom = (avalon_addr == EEPROM_RD_ADDR & (avalon_write_o == 1)); //load eeprom -> buffer
assign wr_eeprom = (avalon_addr == EEPROM_WR_ADDR & (avalon_write_o == 1));//write buffer -> eeprom

always @ (posedge SYS_CLK)
     avalon_write_o <= avalon_write_i;
	  
always @ (posedge SYS_CLK)
     avalon_read_o <= avalon_read_i;	  

//Registers and Configuration data write/read    
always@(posedge SYS_CLK)
	if (~eeprom_busy && eeprom_data_valid) 
				configuration <= eeprom_buffer; 
	else begin
   /*   Write to Control Register   */
	if ((avalon_addr == CR_ADDR) & (avalon_write_o == 1) ) 
			{`CON_REG_H,`CON_REG_L} <= avalon_writedata[15:0]; 	
		
	/*   Read from Control Register   */		
	if ((avalon_addr == CR_ADDR) & (avalon_read_o == 1) ) 
			dout <= {16'b0,`CON_REG_H,`CON_REG_L}; 
	
			
   /*   Read FPGA version   */		
	if ((avalon_addr == FPGA_VER_ADDR) & (avalon_read_o == 1)) 
			dout <= FPGA_VERSION_NO; 

		
	/*   slow fifo occupancy     */		
	if ((avalon_addr == SFIFO_WD_ADDR) & (avalon_read_o == 1)) 
			begin comm_act <= ~comm_act; dout <= {16'b0,sfifo_wr_wd,sfifo_rd_wd}; end // HJ modified Nov 21,2023. Added sfifo_wr_wd.
	

	/*   Read slow fifo     */		
	if ((avalon_addr == SFIFO_ADDR) & (avalon_read_o == 1)) 
			dout <= sfifo_dout; 	
	
	
	/*   Reset fast fifo     */		
	if ((avalon_addr == FIFO_CLR_ADDR) & (avalon_write_o == 1)) 
			fifo_clr_reg <= 1; 
	else fifo_clr_reg <= 0; 

	/*   Read fast fifo occupancy    */		
	if ((avalon_addr == FIFO_WD_ADDR) & (avalon_read_o == 1)) 
			dout <= {16'b0,3'b0,fifo_word}; 
			
	/*   Read fast fifo   */		
	if ((avalon_addr == FIFO_ADDR) & (avalon_read_o == 1)) 
			dout <= {fast_fifo_dout}; 	
	
   /*   Write/Read to Thresh   */
	if ((avalon_addr == TRIG_TH_ADDR) & (avalon_write_o == 1) ) 
			`TRIG_TH <= avalon_writedata[15:0]; 
	if ((avalon_addr == TRIG_TH_ADDR) & (avalon_read_o == 1) ) 
			dout <= {16'b0,`TRIG_TH};  
			
   /*   Write/Read to Transition  */
	if ((avalon_addr == TRANSITION_ADDR) & (avalon_write_o == 1) ) 
			`TRANSITION <= avalon_writedata[15:0]; 
	if ((avalon_addr == TRANSITION_ADDR) & (avalon_read_o == 1) ) 
			dout <= {16'b0,`TRANSITION};  
			
	/*   Write/Read to CAL_WAVE  */
	if ((avalon_addr == CAL_WAVE_ADDR) & (avalon_write_o == 1) ) 
		  {`CAL_AMP,`CAL_DC} <= avalon_writedata[15:0]; 	
	if ((avalon_addr == CAL_WAVE_ADDR) & (avalon_read_o == 1) ) 
			dout <= {16'b0,`CAL_AMP,`CAL_DC}; 	
			
	/*   Write/Read to FP_CH0_NF  */
	if ((avalon_addr == FP_CH0_NF_ADDR) & (avalon_write_o == 1) ) 
			`FP_CH0_NF <= avalon_writedata; 
	if ((avalon_addr == FP_CH0_NF_ADDR) & (avalon_read_o == 1) ) 
			dout <= `FP_CH0_NF;  
			
	/*   Write/Read to FP_CH1_NF  */
	if ((avalon_addr == FP_CH1_NF_ADDR) & (avalon_write_o == 1) ) 
			`FP_CH1_NF <= avalon_writedata; 
	if ((avalon_addr == FP_CH1_NF_ADDR) & (avalon_read_o == 1) ) 
			dout <= `FP_CH1_NF;
			
	/*   Write/Read to FP_CH2_NF  */
	if ((avalon_addr == FP_CH2_NF_ADDR) & (avalon_write_o == 1) ) 
			`FP_CH2_NF <= avalon_writedata; 
	if ((avalon_addr == FP_CH2_NF_ADDR) & (avalon_read_o == 1) ) 
			dout <= `FP_CH2_NF;
			
	/*   Write/Read to FP_CH3_NF  */
	if ((avalon_addr == FP_CH3_NF_ADDR) & (avalon_write_o == 1) ) 
			`FP_CH3_NF <= avalon_writedata; 
	if ((avalon_addr == FP_CH3_NF_ADDR) & (avalon_read_o == 1) ) 
			dout <= `FP_CH3_NF;

	/*   Write/Read to CH0_ADC_OFFSET (HJ)  */
	if ((avalon_addr == CH0_ADC_OFFSET_ADDR) & (avalon_write_o == 1) ) 
			`CH0_ADC_OFFSET <= avalon_writedata[15:0]; 
	if ((avalon_addr == CH0_ADC_OFFSET_ADDR) & (avalon_read_o == 1) ) 
			dout <= {16'b0,`CH0_ADC_OFFSET};  	
	
	/*   Write/Read to CH1_ADC_OFFSET  (HJ) */
	if ((avalon_addr == CH1_ADC_OFFSET_ADDR) & (avalon_write_o == 1) ) 
			`CH1_ADC_OFFSET <= avalon_writedata[15:0]; 
	if ((avalon_addr == CH1_ADC_OFFSET_ADDR) & (avalon_read_o == 1) ) 
			dout <= {16'b0,`CH1_ADC_OFFSET};  	
			
			
	/*   Write/Read to FP_KXY  */
	if ((avalon_addr == FP_KXY_ADDR) & (avalon_write_o == 1) ) 
			`FP_KXY <= avalon_writedata; 
	if ((avalon_addr == FP_KXY_ADDR) & (avalon_read_o == 1) ) 
			dout <= `FP_KXY;  
			
	/*   Write/Read to X_OFFSET  */
	if ((avalon_addr == X_OFFSET_ADDR) & (avalon_write_o == 1) ) 
			`X_OFFSET <= avalon_writedata[15:0]; 
	if ((avalon_addr == X_OFFSET_ADDR) & (avalon_read_o == 1) ) 
			dout <= {16'b0,`X_OFFSET};  
			
	/*   Write/Read to IIR_OUT_K2  */
	if ((avalon_addr == IIR_OUT_K2_ADDR) & (avalon_write_o == 1) ) 
			`IIR_OUT_K2 <= avalon_writedata; 
	if ((avalon_addr == IIR_OUT_K2_ADDR) & (avalon_read_o == 1) ) 
			dout <= `IIR_OUT_K2;			
			
	/*   Write/Read to Y_OFFSET  */
	if ((avalon_addr == Y_OFFSET_ADDR) & (avalon_write_o == 1) ) 
			`Y_OFFSET <= avalon_writedata[15:0]; 
	if ((avalon_addr == Y_OFFSET_ADDR) & (avalon_read_o == 1) ) 
			dout <= {16'b0,`Y_OFFSET};  
		
				 /*   Write/Read to MODULE_ID0  */
	if ((avalon_addr == MODULE_ID0_ADDR) & (avalon_write_o == 1) ) 
			`MODULE_ID0 <= avalon_writedata; 
	if ((avalon_addr == MODULE_ID0_ADDR) & (avalon_read_o == 1) ) 
			dout <= `MODULE_ID0;  
	
   			 /*   Write/Read to MODULE_ID1  */
	if ((avalon_addr == MODULE_ID1_ADDR) & (avalon_write_o == 1) ) 
			`MODULE_ID1 <= avalon_writedata; 
	if ((avalon_addr == MODULE_ID1_ADDR) & (avalon_read_o == 1) ) 
			dout <= `MODULE_ID1;  			
			
end //else

//							================ Self Trigger ===============					

wire bpm_trig,gate,new_gate/* synthesis keep */; 
wire No_beam;

wire trig = auto_trig_sel? auto_trig : bpm_trig;

// Generated trigger signal based on demodulated envelope amplitude
self_trigger self_trigger_inst(
	.signal(Amp_avg), 
	.threshold(`TRIG_TH),
	.transition(`TRANSITION),	
	.clk(DCLK), //SCLK
	.reset(SYS_RST),
	.no_beam(No_beam), //if not triggered for 1 seconds, assert this signal.
	.gate(gate), //window during which the signal is above the TRIG_TH
	.all_trig(bpm_trig) //one clk pulse
	
);

// ================ Processing ==============
reg clk_10Hz; // 10Hz pulse with 0.8% duty cycle (0.8ms width)
reg [21:0] count_10Hz; // count to 2.5 million

// generate 10Hz period pulse, and an extended version (ST_on) to account for calculate_position latency
always @ (posedge DCLK) begin
	count_10Hz <= count_10Hz + 1;
	
	if(count_10Hz == 25'd248000) begin
		clk_10Hz <= 1'b1;
		ST_on <= 1'b1;
	end
	else if(count_10Hz == 25'd250000) begin
		clk_10Hz <= 1'b0;
	end
	
	else if(count_10Hz == 25'd250100)begin
		count_10Hz <= 25'b0;
		ST_on <= 1'b0;
	end	
end

wire [DATA_WIDTH-1:0] Ch0_Din_FIR, Ch1_Din_FIR;
wire [DATA_WIDTH-1:0] Ch0_Din/*synthesis keep*/;
wire [DATA_WIDTH-1:0] Ch1_Din/*synthesis keep*/; 
wire [DATA_WIDTH-1:0] Ch2_Din/*synthesis keep*/; 
wire [DATA_WIDTH-1:0] Ch3_Din/*synthesis keep*/; 

// ----------------------- Filter and store raw data ------------------------------

// Input FIR bandpass filters to clean up raw ADC data.
FIR BPF0(
    .clk(SCLK),
    .reset(SYS_RST),
	 .ena_gain(1'b1), 
    .data_in(Ch0_ADC_DATA),
    .data_out(Ch0_Din_FIR)
    );

FIR BPF1(
    .clk(SCLK),
    .reset(SYS_RST),
	 .ena_gain(1'b1),
    .data_in(Ch1_ADC_DATA),
    .data_out(Ch1_Din_FIR)
    );	 

FIR BPF2(
    .clk(SCLK),
    .reset(SYS_RST),
	 .ena_gain(1'b1), 
    .data_in(Ch2_ADC_DATA),
    .data_out(Ch2_Din_FIR)
    );

FIR BPF3(
    .clk(SCLK),
    .reset(SYS_RST),
	 .ena_gain(1'b1), 
    .data_in(Ch3_ADC_DATA),
    .data_out(Ch3_Din_FIR)
    );	 
	 
assign Ch0_Din = ena_avg? Ch0_Din_FIR: {Ch0_ADC_DATA[13],Ch0_ADC_DATA[13],Ch0_ADC_DATA};
assign Ch1_Din = ena_avg? Ch1_Din_FIR: {Ch1_ADC_DATA[13],Ch1_ADC_DATA[13],Ch1_ADC_DATA};
assign Ch2_Din = ena_avg? Ch2_Din_FIR: {Ch2_ADC_DATA[13],Ch2_ADC_DATA[13],Ch2_ADC_DATA};
assign Ch3_Din = ena_avg? Ch3_Din_FIR: {Ch3_ADC_DATA[13],Ch3_ADC_DATA[13],Ch3_ADC_DATA};

wire [FULL_WIDTH-1:0] channel_din = {Ch3_Din,Ch2_Din,Ch1_Din,Ch0_Din}; // 64 bit signal with raw data for all 4 channels.
wire [FULL_WIDTH-1:0] channel_dout; // 64 bit signal with 4 channel data for fast FIFO. Can be raw data or demodulated data, depending on waveform_select.

//all four channels circular buffer frozen by trig at the same time, 
//and start transfering waveform to fast_fifo at the same time.
//wire [FULL_WIDTH-1:0] Amp;  //64 bit , 4 channel amplitude data
wire [DATA_WIDTH-1:0] channel_error;
wire [DATA_WIDTH-1:0] Amp_avg/*synthesis keep*/;
wire [SF_WIDTH-1:0] fp_ch0_Amp; // FP format, Demodulated waveform 
wire [SF_WIDTH-1:0] fp_ch1_Amp;
wire [SF_WIDTH-1:0] fp_ch2_Amp;
wire [SF_WIDTH-1:0] fp_ch3_Amp;


// ----------------------- Convert raw data into demodulated signal ------------------------------

channel_block Ch_XY_inst(
 .clk(SCLK), //ADC clock
 .DCLK(DCLK), //clk for decimated signal
 .SYS_RST(SYS_RST),
 
 .din(channel_din), //64 bit
 .trig(sfifo_trig), // modified DEC 18 2023. From trig

 //from fast fifo
 .fast_fifo_full(fast_fifo_full),
 .fast_fifo_empty(fast_fifo_empty),
 
 .waveform_select(waveform_select),
 
 //to fast fifo
 .fast_fifo_din(channel_dout),//64 bit
 .fast_fifo_wr(fifo_wr),
 
 .error(channel_error),
 .d_clk(d_clk), //clk for decimated signal
 .Amp_avg(Amp_avg), //16bit int, avg of 4 channel signanl, used as trigger input
 .fp_ch0_Amp(fp_ch0_Amp), // Demodulated waveform , in same data rate as din
 .fp_ch1_Amp(fp_ch1_Amp),
 .fp_ch2_Amp(fp_ch2_Amp),
 .fp_ch3_Amp(fp_ch3_Amp)
);


// Remove noisy transitions from demodulated signal. CHANGE FOR V3 - does each channel need it's own gate?

wire [FULL_WIDTH-1:0] signal_delayed_X;
alignment align_X(
	.signal({fp_ch1_Amp,fp_ch0_Amp}), //demodulated signal
	.gate(gate), 
	.transition(), //not in use 
	.clk(DCLK), //clock is ADC_clk/8 = 2.5 MHz 
	.reset(SYS_RST),
	.signal_delayed(signal_delayed_X),
	.new_gate(new_gate)
);

wire [FULL_WIDTH-1:0] signal_delayed_Y;
alignment align_Y(
	.signal({fp_ch3_Amp,fp_ch2_Amp}), //demodulated signal
	.gate(gate), 
	.transition(), //not in use 
	.clk(DCLK), //clock is ADC_clk/8 = 2.5 MHz 
	.reset(SYS_RST),
	.signal_delayed(signal_delayed_Y),
	.new_gate()
);

// ----------------------- Calculate beam position, and slow FIFO values ------------------------------

wire [SF_WIDTH-1:0] peak_A,peak_B,peak_C,peak_D/*synthesis keep*/; // Slow FIFO values for demodulated envelopes
wire [SF_WIDTH-1:0] X_fp_pos,Y_fp_pos/*synthesis keep*/; // slow FIFO values for beam position
wire [SF_WIDTH-1:0] X_fp_pos_uncal; // uncalibrated beam position (no autocal)
wire [SF_WIDTH-1:0] max_A,max_B,min_A,min_B,max_C,max_D,min_C,min_D/*synthesis keep*/; 

// CHANGE FOR V3 - remove these signals.
wire [DATA_WIDTH-1:0] Xdac, Ydac/* synthesis keep */; //16 bit position signed, two's complement. Modified (removed sign) Nov 23,2023
wire signed [DATA_WIDTH-1:0] X_Position, Y_Position; //16 bit position signed, two's complement.

wire maxmin_rst; //for debug use, to clear the maxmin register
//the fifo_clr_reg is one clk SYS_CLK, needs to be streched to one DCLK 
pulse_shaper pulse_inst(
	.data_in(SYS_RST | fifo_clr_reg),
	.clk(SYS_CLK),
	.data_out(maxmin_rst)
    );

// beam position is updated after each trig plus 80 ADC clk.
// if no beam, then no trig, and the "position" signal in the following module is not updated, but the DAC output has noise
// which indicating the electronics is alive on Xtpage.

// LPF TC = 0.434 ms, 9.5 ms,100 ms, 1000 ms, see "lpf_IIR.v" CHANGE FOR V3 - remove these parameters.
parameter fpd1 = 32'H3dcccccd; //0.1 in fp
parameter fpd9 = 32'H3f666666; //0.9 in fp
parameter fpd99 = 32'H3f7d70a4; //0.99 in fp
parameter fpd999 = 32'H3f7fbe77; //0.999 in fp

// CHANGE FOR V3 - These seem unused?
wire [DATA_WIDTH-1:0] delayed_ch0,delayed_ch1/*synthesis keep*/;
altfp_fp2int conv_inst0(.dataa(signal_delayed_X[31:0]), .clock(DCLK),.result(delayed_ch0));
altfp_fp2int conv_inst1(.dataa(signal_delayed_X[63:32]),.clock(DCLK),.result(delayed_ch1));

wire [DATA_WIDTH-1:0] delayed_ch2,delayed_ch3/*synthesis keep*/;
altfp_fp2int conv_inst2(.dataa(signal_delayed_Y[31:0]), .clock(DCLK),.result(delayed_ch2));
altfp_fp2int conv_inst3(.dataa(signal_delayed_Y[63:32]),.clock(DCLK),.result(delayed_ch3));

// CHANGE FOR V3 - remove unused inputs from this module.	 
calculate_position cal_position_X(
	.A_amp(signal_delayed_X[31:0]), //
	.B_amp(signal_delayed_X[63:32]),//
	.data_valid(), 
	.OFFSET(`X_OFFSET),//offset adjust, um
	.FP_CH0_NF(`FP_CH0_NF), //gain compensation, around 1.0
	.FP_CH1_NF(`FP_CH1_NF), //
	.FP_KXY(`FP_KXY), // 32 bit fp, BPM sensitivity, i.g. 0.42 dB/mm for ISAC BPM
	.is10mmpV(is10mmpV), //10mm/V or 1mm/V DAC
	.AVG_select(AVG_select), //Not in use, March 8,2023
	.clk(DCLK),  
	.rst(maxmin_rst),
	.gate(new_gate), //only calculate position inside this signal
   .IIR_OUT_K2(`IIR_OUT_K2),	
	.CH0_ADC_OFFSET(`CH0_ADC_OFFSET), // HJ Nov 27, 2023
	.CH1_ADC_OFFSET(`CH1_ADC_OFFSET), // HJ Nov 27, 2023
	.cal_sel(cal_sel),
	.clk_10Hz(clk_10Hz),
	.A_comp(peak_A),
	.B_comp(peak_B),
	.A_max(max_A),
	.B_max(max_B),
	.A_min(min_A),
	.B_min(min_B),
	.fp_pos_mm_LPF(X_fp_pos_uncal),
	.fp_pos_mm_cal(X_fp_pos)
	
    );
	 
calculate_position cal_position_Y(
	.A_amp(signal_delayed_Y[31:0]), //
	.B_amp(signal_delayed_Y[63:32]),//
	.data_valid(), 
	.OFFSET(`Y_OFFSET),//offset adjust, um
	.FP_CH0_NF(`FP_CH2_NF), //gain compensation, around 1.0
	.FP_CH1_NF(`FP_CH3_NF), //
	.FP_KXY(`FP_KXY), // 32 bit fp, BPM sensitivity, i.g. 0.42 dB/mm for ISAC BPM
	.is10mmpV(is10mmpV), //10mm/V or 1mm/V DAC
	.AVG_select(AVG_select), //Not in use, March 8,2023
	.clk(DCLK),  
	.rst(maxmin_rst),
	.gate(new_gate), //only calculate position inside this signal
   .IIR_OUT_K2(`IIR_OUT_K2),	
	.CH0_ADC_OFFSET(16'b0), // HJ Nov 27, 2023
	.CH1_ADC_OFFSET(16'b0), // HJ Nov 27, 2023
	.cal_sel(cal_sel),
	.clk_10Hz(clk_10Hz),
	.A_comp(peak_C),
	.B_comp(peak_D),
	.A_max(max_C),
	.B_max(max_D),
	.A_min(min_C),
	.B_min(min_D),
	.fp_pos_mm_LPF(),
	.fp_pos_mm_cal(Y_fp_pos)
	
    );
	 
/* OLD declaration from Shengli
calculate_position cal_position_Y(
	.A_amp(ch2), //
	.B_amp(ch3),//16 bit, amplitude signal 
	.data_valid(), 
	.OFFSET(`Y_OFFSET),//offset adjust, um
	.FP_CH0_NF(`FP_CH2_NF), //gain compensation, around 1.0
	.FP_CH1_NF(`FP_CH3_NF), //
	.FP_KXY(`FP_KXY), // 32 bit fp, BPM sensitivity, i.g. 0.42 dB/mm for ISAC BPM
	.is10mmpV(is10mmpV), //10mm/V or 1mm/V DAC
	.AVG_select(AVG_select), //Not in use, March 8,2023
	.clk(SCLK),  
	.rst(SYS_RST),
   .trig(bpm_trig), //start to integrate the signal at trig,
   .IIR_OUT_K2(`IIR_OUT_K2),	
	
	.A_comp(peak_C),
	.B_comp(peak_D),
	.fp_pos_mm_LPF(Y_fp_pos),
	.position(Y_Position)  //16 bit signed DAC value
	
    );
	 
*/
	 
//================ Fast FIFO to transfer 20 MHz data from FPGA to SoC ===================

	wire fast_FIFO_rst = SYS_RST | fifo_clr_reg;
   wire fast_fifo_full, fast_fifo_empty;
	
	wire [FFIFO_WIDTH-1:0] fast_fifo_din,fast_fifo_dout;
	
	wire [12:0] fifo_word /*synthesis keep*/;

	wire [FFIFO_WIDTH-1:0] fifo_din = ch_select? channel_dout[63:32] : channel_dout[31:0];
	wire fifo_wr;		 
	
	fifo4096 Fast_FIFO (
		.aclr(fast_FIFO_rst), //
		.wrclk(SCLK), //
		.rdclk(SYS_CLK), //
		.data(fifo_din), // 32 bit
		.wrreq(fifo_wr), //
		.rdreq(fifo_rd),
		.q(fast_fifo_dout), // 32 bit
		.rdfull(fast_fifo_full), //
		.rdempty(fast_fifo_empty),
		.wrusedw(fifo_word) //
	);
	
//================ Slow FIFO to transfer demodulated data from FPGA to SoC ===================

	reg sFIFO_wr;
	reg [SFIFO_WIDTH-1:0] sfifo_data_in;
	wire [SFIFO_WIDTH-1:0] sfifo_dout;
	
	wire [7:0] sfifo_wr_wd, sfifo_rd_wd /*synthesis keep*/;
	wire sfifo_half_full = sfifo_wr_wd[6]; // 64   
	
	slfifo Slow_FIFO (
		.aclr(SYS_RST), //adding a reset here would be useful.
		.data(sfifo_data_in),
		.wrclk(SCLK),
		.rdclk(SYS_CLK),
		.wrreq(sFIFO_wr),
		.rdreq(sfifo_rd),
		.q(sfifo_dout),
		.rdusedw(sfifo_rd_wd), 
		.wrusedw(sfifo_wr_wd)
	);  
//	output [7:0]  rdusedw;
//	output [7:0]  wrusedw;
// slfifo is 128 words(32bit) deep, Nov.29,2018
	
//============ Packing Slow FIFO=================================
	parameter PID = 32'h4142504d; // "ABPM"
	
	reg [7:0] p_state;
	
	reg new_gate_last;
	wire sfifo_trig;
	
	always @(posedge SCLK)
		new_gate_last <= new_gate;
	
	assign sfifo_trig = ((!new_gate) && new_gate_last) && (!ST_on); // load sfifo when new_gate is falling, but not when calibrating

//data packet size is 8 words (32bit)

	always @(posedge SCLK)
	begin
		if(SYS_RST)
			begin
				p_state <= 0;
				sFIFO_wr<= 0;
			end
		else
			begin
				case(p_state)
					0:if(sfifo_trig && sfifo_wr_wd < 100) // Modified on Dec 18, 2023
						begin sFIFO_wr<= 1; sfifo_data_in <= PID; p_state <= 1; end
					1: begin sfifo_data_in <= {`CON_REG_H,`CON_REG_L,status_reg}; p_state <= 2; end
					2: begin sfifo_data_in <= peak_A; p_state <= 3; end
					3: begin sfifo_data_in <= peak_B; p_state <= 4; end			
					4: begin sfifo_data_in <= peak_C; p_state <= 5; end
					5: begin sfifo_data_in <= peak_D; p_state <= 6; end
					6: begin sfifo_data_in <= X_fp_pos; p_state <= 7; end
					7: begin sfifo_data_in <= Y_fp_pos; p_state <= 8; end
					8: begin sfifo_data_in <= X_fp_pos_uncal; p_state <= 9; end
					9: begin sfifo_data_in <= {humi,temp}; p_state <= 10; end
					10: begin sfifo_data_in <= max_A; p_state <= 11; end
					11: begin sfifo_data_in <= max_B; p_state <= 12; end
					12: begin sfifo_data_in <= min_A; p_state <= 13; end
					13: begin sfifo_data_in <= min_B; p_state <= 14; end
					14: begin sFIFO_wr<= 0; p_state <= 0; end
					
					default:
						begin sFIFO_wr<= 0; p_state <= 0; end
				endcase
			end

	end

//=========== DHT11 sensor ========================

reg [15:0] temp, humi;

dht11 temp_sensor(
	.i_clk(SYS_CLK),
	.i_rst_n(1'b1), //always enable
	.io_data(GPIO_0_30),
	.o_temp(temp),
	.o_humi(humi)
	);

//============== Status LED ============================
reg comm_act;
assign LED_RUNNING = comm_act;
	
// Debounce logic to clean out glitches within 1ms		
debounce debounce_inst(
             .clk(fpga_clk_50),
             .reset_n(hps_fpga_reset_n),
             .data_in(KEY),
             .data_out(fpga_debounced_buttons)
         );
defparam debounce_inst.WIDTH = 2;
defparam debounce_inst.POLARITY = "LOW";
defparam debounce_inst.TIMEOUT = 50000;               // at 50Mhz this is a debounce time of 1ms
defparam debounce_inst.TIMEOUT_WIDTH = 16;            // ceil(log2(TIMEOUT))

// Source/Probe megawizard instance
hps_reset hps_reset_inst(
              .source_clk(fpga_clk_50),
              .source(hps_reset_req)
          );

altera_edge_detector pulse_cold_reset(
                         .clk(fpga_clk_50),
                         .rst_n(hps_fpga_reset_n),
                         .signal_in(Cold_Reset_Req),
                         .pulse_out(hps_cold_reset)
                     );
defparam pulse_cold_reset.PULSE_EXT = 6;
defparam pulse_cold_reset.EDGE_TYPE = 1;
defparam pulse_cold_reset.IGNORE_RST_WHILE_BUSY = 1;

altera_edge_detector pulse_warm_reset(
                         .clk(fpga_clk_50),
                         .rst_n(hps_fpga_reset_n),
                         .signal_in(hps_reset_req[1]),
                         .pulse_out(hps_warm_reset)
                     );
defparam pulse_warm_reset.PULSE_EXT = 2;
defparam pulse_warm_reset.EDGE_TYPE = 1;
defparam pulse_warm_reset.IGNORE_RST_WHILE_BUSY = 1;

altera_edge_detector pulse_debug_reset(
                         .clk(fpga_clk_50),
                         .rst_n(hps_fpga_reset_n),
                         .signal_in(hps_reset_req[2]),
                         .pulse_out(hps_debug_reset)
                     );
defparam pulse_debug_reset.PULSE_EXT = 32;
defparam pulse_debug_reset.EDGE_TYPE = 1;
defparam pulse_debug_reset.IGNORE_RST_WHILE_BUSY = 1;


	
endmodule




	 
		