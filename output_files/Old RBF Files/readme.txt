
soc_system_jan25.rbf (Jan 23)
	Last working compile

soc_system_fpga_cal.rbf (Jan 23)
	added 46.1 Mhz clk on FPGA output for autocal

soc_system_jan23.rbf
	added a reset to autocal. increased freq from 1Hz --> 10Hz
soc_system_cal_3.rbf (Jan 19)
	autocalibration using subtraction from position. Seems to work quite well.

soc_system_cal_2.rbf (Jan 19)
	autocalibration using division to scale ch1.

soc_system_cal_1.rbf (Jan 18)
	first attempt at auto calibration

soc_system_jan18.rbf (Jan 18 2024)
	Same as Jan 9

soc_system_2chan.rbf (Jan 9 2024)
	Added vertical (Y) channel.

soc_system_jan9.rbf (Jan 9 2024)
	Changed some floating point divides to multiplies, to reduce DSP usage.

soc_system_FIR_gain.rbf (Jan 8 2024)
	Added a gain of 4x to the FIR filter. It helps to reduce the noise of the demodulated pulse, so I think it's worth keeping.

soc_system_IIR.rbf
	Output 3rd order IIR does not work at all. Gives INF. Otherwise the same as FIR

soc_system_FIR.rbf
	15 tap input FIR seems to work, but doesn't do much.

soc_system_jan5.rbf
	Last standard working compile.