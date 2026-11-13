#**************************************************************
# This .sdc file is created by Terasic Tool.
# Users are recommended to modify this file to match users logic.
#**************************************************************

#**************************************************************
# Create Clock
#**************************************************************
#create_clock -period "50.0 MHz" [get_ports FPGA_CLK1_50]
#create_clock -period "50.0 MHz" [get_ports FPGA_CLK2_50]
#create_clock -period "50.0 MHz" [get_ports FPGA_CLK3_50]

create_clock -name FPGA_CLK1_50 -period 20.000 [get_ports FPGA_CLK1_50]
create_clock -name FPGA_CLK2_50 -period 20.000 [get_ports FPGA_CLK2_50]
create_clock -name FPGA_CLK3_50 -period 20.000 [get_ports FPGA_CLK3_50]


# for enhancing USB BlasterII to be reliable, 25MHz
create_clock -name {altera_reserved_tck} -period 40 {altera_reserved_tck}
set_input_delay -clock altera_reserved_tck -clock_fall 3 [get_ports altera_reserved_tdi]
set_input_delay -clock altera_reserved_tck -clock_fall 3 [get_ports altera_reserved_tms]
set_output_delay -clock altera_reserved_tck 3 [get_ports altera_reserved_tdo]

# added Nov 6 - HJ
create_clock -name LO_CLK -period 43.383 [get_ports {GPIO_0_32}] 

#**************************************************************
# Create Generated Clock
#**************************************************************
derive_pll_clocks


#=== clk_slow: XY_cic, two ÷8 stages per axis (DCLK/8 then DCLK/64) ===
# X axis

#=== DCLK = Sampling_CLK / 8  (~2.5 MHz) ===
create_generated_clock -name DCLK_from_self -divide_by 8 \
  -source [get_pins {clk_pll_inst0|clk20_pll_inst|altera_pll_i|general[1].gpll~PLL_OUTPUT_COUNTER|divclk}] \
  [get_registers {channel_block:Ch_XY_inst|DDC:DDC_inst|CIC38:ch0_CIC_I|d_clk}]

create_generated_clock -name DCLK_from_syn -divide_by 8 -add \
  -source [get_pins {clk23_pll_inst1|clk23_pll_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}] \
  [get_registers {channel_block:Ch_XY_inst|DDC:DDC_inst|CIC38:ch0_CIC_I|d_clk}]
  
#=== clk_slow: XY_cic, two ÷8 stages per axis, one def per DCLK master ===
# ---- X axis ----
create_generated_clock -name cic_x1_self -divide_by 8 -master_clock DCLK_from_self \
  -source [get_registers {channel_block:Ch_XY_inst|DDC:DDC_inst|CIC38:ch0_CIC_I|d_clk}] \
  [get_registers {XY_cic:xy_cic_inst|CIC:cic_x1|d_clk}]
create_generated_clock -name cic_x1_syn -divide_by 8 -master_clock DCLK_from_syn -add \
  -source [get_registers {channel_block:Ch_XY_inst|DDC:DDC_inst|CIC38:ch0_CIC_I|d_clk}] \
  [get_registers {XY_cic:xy_cic_inst|CIC:cic_x1|d_clk}]

create_generated_clock -name cic_x2_self -divide_by 8 -master_clock cic_x1_self \
  -source [get_registers {XY_cic:xy_cic_inst|CIC:cic_x1|d_clk}] \
  [get_registers {XY_cic:xy_cic_inst|CIC:cic_x2|d_clk}]
create_generated_clock -name cic_x2_syn -divide_by 8 -master_clock cic_x1_syn -add \
  -source [get_registers {XY_cic:xy_cic_inst|CIC:cic_x1|d_clk}] \
  [get_registers {XY_cic:xy_cic_inst|CIC:cic_x2|d_clk}]

## ---- Y axis (confirm the cic_y* node names) ----
#create_generated_clock -name cic_y1_self -divide_by 8 -master_clock DCLK_from_self \
#  -source [get_registers {channel_block:Ch_XY_inst|DDC:DDC_inst|CIC38:ch0_CIC_I|d_clk}] \
#  [get_registers {XY_cic:xy_cic_inst|CIC:cic_y1|d_clk}]
#create_generated_clock -name cic_y1_syn -divide_by 8 -master_clock DCLK_from_syn -add \
#  -source [get_registers {channel_block:Ch_XY_inst|DDC:DDC_inst|CIC38:ch0_CIC_I|d_clk}] \
#  [get_registers {XY_cic:xy_cic_inst|CIC:cic_y1|d_clk}]
#
#create_generated_clock -name cic_y2_self -divide_by 8 -master_clock cic_y1_self \
#  -source [get_registers {XY_cic:xy_cic_inst|CIC:cic_y1|d_clk}] \
#  [get_registers {XY_cic:xy_cic_inst|CIC:cic_y2|d_clk}]
#create_generated_clock -name cic_y2_syn -divide_by 8 -master_clock cic_y1_syn -add \
#  -source [get_registers {XY_cic:xy_cic_inst|CIC:cic_y1|d_clk}] \
#  [get_registers {XY_cic:xy_cic_inst|CIC:cic_y2|d_clk}]

#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************
derive_clock_uncertainty



#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************
#set_clock_groups -asynchronous  \
#    -group [get_clocks {<syn_CLK name from clk23_pll>}] \
#    -group [get_clocks {<self_CLK name from clk20_pll>}]

#set_clock_groups -asynchronous \
#    -group [get_clocks {clk23_pll_inst1|clk23_pll_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}] \
#    -group [get_clocks {clk_pll_inst0|clk20_pll_inst|altera_pll_i|general[1].gpll~PLL_OUTPUT_COUNTER|divclk}]

set_clock_groups -asynchronous \
  -group [get_clocks {FPGA_CLK1_50 FPGA_CLK2_50 FPGA_CLK3_50 clk_pll_inst0|clk20_pll_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}] \
  -group [get_clocks {clk_pll_inst0|clk20_pll_inst|altera_pll_i|general[1].gpll~PLL_OUTPUT_COUNTER|divclk DCLK_from_self cic_x1_self cic_x2_self cic_y1_self cic_y2_self}] \
  -group [get_clocks {LO_CLK clk23_pll_inst1|clk23_pll_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk DCLK_from_syn cic_x1_syn cic_x2_syn cic_y1_syn cic_y2_syn}]
  
#**************************************************************
# Set False Path
#**************************************************************



#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************



#**************************************************************
# Set Load
#**************************************************************
