/* 
 * This file contains the various paramaters used to configure the firmware
 * project 
 * Written by David Bascelli
 * August 2018
 */

parameter FILTER_TAPS = 6; //Use a 6 tap moving average filter
parameter SYS_CLOCK_FREQ = 50000000; //System clock frequency is 50 MHz

// ADC paramaters
parameter ADC_DATA_WIDTH = 14; //14 bits of data for each adc sample
parameter SPI_CLOCK_FREQ = 10000000; //SPI clock frequency is 10 MHz
parameter ADC_CYCLE_TIME = 0.00001; //ADC cycle time (10 uS). Time between cycles
parameter ADC_SPI_TIMER_WAIT = 100; //How many cycles of SPI_CLK between adc cycles
                                    // $floor(SPI_CLOCK_FREQ*ADC_CYCLE_TIME); 
                                    // Not supported for synthesis
parameter SFIFO_WIDTH = 32; //Slow fifo data width
parameter SF_WIDTH = 32; //Single floating datat width
parameter FFIFO_WIDTH = 32; //fast fifo data width 32 bit
parameter FULL_WIDTH = 64; // data width for all 4 channel signals
parameter DATA_WIDTH = 16;

parameter FP100 = 32'h42c80000; 												