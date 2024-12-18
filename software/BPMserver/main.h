#ifndef __COMMON_H__
#define __COMMON_H__

#include <stdint.h>
#include <semaphore.h>
#include <fcntl.h>
#include <sys/mman.h>
#include "hwlib.h"
#include "socal/socal.h"
#include "socal/hps.h"
#include "socal/alt_gpio.h"
#include "hps_0.h"

#define FW_VERSION 20230301 //firmware version 

#define BUFFER_MAX_SIZE 4000
#define STRING_MAX_LENGTH 36864

#define HW_REGS_BASE ( ALT_STM_OFST )
#define HW_REGS_SPAN ( 0x04000000 )
#define HW_REGS_MASK ( HW_REGS_SPAN - 1 )

#define FPGA_STATUS_REG_ADDR 4*0
#define FPGA_CONTROL_REG_ADDR 4*1
#define FPGA_MASK_REG_ADDR 4*2
#define FPGA_VER_ADDR 4*3
#define CH_SELECT_ADDR 4*4
#define PCA_GAIN_ADDR 4*5

#define SFIFO_WD_ADDR 4*7
#define SFIFO_ADDR 4*8

#define FIFO_CLR_ADDR 4*9
#define FIFO_WD_ADDR 4*10
#define FIFO_ADDR 4*11

#define EEPROM_RD_ADDR 4*15
#define EEPROM_WR_ADDR 4*16

#define FP_CH0_NF_ADDR 4*17
#define FP_CH1_NF_ADDR 4*18
#define FP_CH2_NF_ADDR 4*19
#define FP_CH3_NF_ADDR 4*20

#define FP_KXY_ADDR 4*21

#define	X_OFFSET_ADDR 4*22
#define	Y_OFFSET_ADDR 4*23

#define TRIG_TH_ADDR 4*30
#define TRANSITION_ADDR 4*31

#define CAL_WAVE_ADDR 4*33

#define BL_ADDR 4*34

#define IIR_OUT_K1_ADDR 4*47
#define IIR_OUT_K2_ADDR 4*48

//#define CH1_DAC_PEAK_OFFSET_ADDR 4*49
//#define CH1_DAC_AVG_OFFSET_ADDR 4*50

#define CH2_DAC_PEAK_OFFSET_ADDR 4*51
#define CH2_DAC_AVG_OFFSET_ADDR 4*52

#define CH1_ADL5513_OFFSET_ADDR 4*53
#define CH2_ADL5513_OFFSET_ADDR 4*54

#define MODULE_ID0_ADDR 4*71
#define MODULE_ID1_ADDR 4*72	

#define COMB_ALPHA_ADDR 4*73



#define CR  (( (unsigned long) ALT_LWFPGASLVS_OFST + MYAVALONBUS32_0_BASE + FPGA_CONTROL_REG_ADDR ) & (unsigned long) (HW_REGS_MASK))
#define SR  (( (unsigned long) ALT_LWFPGASLVS_OFST + MYAVALONBUS32_0_BASE + FPGA_STATUS_REG_ADDR ) & (unsigned long) (HW_REGS_MASK))
#define MR  (( (unsigned long) ALT_LWFPGASLVS_OFST + MYAVALONBUS32_0_BASE + FPGA_MASK_REG_ADDR ) & (unsigned long) (HW_REGS_MASK))
#define FPGA_VER  (( (unsigned long) ALT_LWFPGASLVS_OFST + MYAVALONBUS32_0_BASE + FPGA_VER_ADDR ) & (unsigned long) (HW_REGS_MASK))
#define CH_SEL  (( (unsigned long) ALT_LWFPGASLVS_OFST + MYAVALONBUS32_0_BASE + CH_SELECT_ADDR ) & (unsigned long) (HW_REGS_MASK))
#define PCA_GAIN  (( (unsigned long) ALT_LWFPGASLVS_OFST + MYAVALONBUS32_0_BASE + PCA_GAIN_ADDR ) & (unsigned long) (HW_REGS_MASK))

#define SFIFO_WD  (( (unsigned long) ALT_LWFPGASLVS_OFST + MYAVALONBUS32_0_BASE + SFIFO_WD_ADDR ) & (unsigned long) (HW_REGS_MASK))
#define SFIFO  (( (unsigned long) ALT_LWFPGASLVS_OFST + MYAVALONBUS32_0_BASE + SFIFO_ADDR ) & (unsigned long) (HW_REGS_MASK))

#define FIFO_WD  (( (unsigned long) ALT_LWFPGASLVS_OFST + MYAVALONBUS32_0_BASE + FIFO_WD_ADDR ) & (unsigned long) (HW_REGS_MASK))
#define FIFO  (( (unsigned long) ALT_LWFPGASLVS_OFST + MYAVALONBUS32_0_BASE + FIFO_ADDR ) & (unsigned long) (HW_REGS_MASK))
#define FIFO_CLR  (( (unsigned long) ALT_LWFPGASLVS_OFST + MYAVALONBUS32_0_BASE + FIFO_CLR_ADDR ) & (unsigned long) (HW_REGS_MASK))

#define EEPROM_RD  (( (unsigned long) ALT_LWFPGASLVS_OFST + MYAVALONBUS32_0_BASE + EEPROM_RD_ADDR ) & (unsigned long) (HW_REGS_MASK))
#define EEPROM_WR  (( (unsigned long) ALT_LWFPGASLVS_OFST + MYAVALONBUS32_0_BASE + EEPROM_WR_ADDR ) & (unsigned long) (HW_REGS_MASK))

#define FP_CH0_NF  (( (unsigned long) ALT_LWFPGASLVS_OFST + MYAVALONBUS32_0_BASE + FP_CH0_NF_ADDR ) & (unsigned long) (HW_REGS_MASK))
#define FP_CH1_NF  (( (unsigned long) ALT_LWFPGASLVS_OFST + MYAVALONBUS32_0_BASE + FP_CH1_NF_ADDR ) & (unsigned long) (HW_REGS_MASK))
#define FP_CH2_NF  (( (unsigned long) ALT_LWFPGASLVS_OFST + MYAVALONBUS32_0_BASE + FP_CH2_NF_ADDR ) & (unsigned long) (HW_REGS_MASK))
#define FP_CH3_NF  (( (unsigned long) ALT_LWFPGASLVS_OFST + MYAVALONBUS32_0_BASE + FP_CH3_NF_ADDR ) & (unsigned long) (HW_REGS_MASK))

#define FP_KXY  (( (unsigned long) ALT_LWFPGASLVS_OFST + MYAVALONBUS32_0_BASE + FP_KXY_ADDR ) & (unsigned long) (HW_REGS_MASK))
#define X_OFFSET  (( (unsigned long) ALT_LWFPGASLVS_OFST + MYAVALONBUS32_0_BASE + X_OFFSET_ADDR ) & (unsigned long) (HW_REGS_MASK))
#define Y_OFFSET  (( (unsigned long) ALT_LWFPGASLVS_OFST + MYAVALONBUS32_0_BASE + Y_OFFSET_ADDR ) & (unsigned long) (HW_REGS_MASK))


#define TRIG_TH  (( (unsigned long) ALT_LWFPGASLVS_OFST + MYAVALONBUS32_0_BASE + TRIG_TH_ADDR ) & (unsigned long) (HW_REGS_MASK))
#define TRANSITION (( (unsigned long) ALT_LWFPGASLVS_OFST + MYAVALONBUS32_0_BASE + TRANSITION_ADDR ) & (unsigned long) (HW_REGS_MASK))

#define CAL_WAVE  (( (unsigned long) ALT_LWFPGASLVS_OFST + MYAVALONBUS32_0_BASE + CAL_WAVE_ADDR ) & (unsigned long) (HW_REGS_MASK))

#define BL (( (unsigned long) ALT_LWFPGASLVS_OFST + MYAVALONBUS32_0_BASE + BL_ADDR ) & (unsigned long) (HW_REGS_MASK))

#define IIR_OUT_K1  (( (unsigned long) ALT_LWFPGASLVS_OFST + MYAVALONBUS32_0_BASE + IIR_OUT_K1_ADDR ) & (unsigned long) (HW_REGS_MASK))
#define IIR_OUT_K2  (( (unsigned long) ALT_LWFPGASLVS_OFST + MYAVALONBUS32_0_BASE + IIR_OUT_K2_ADDR ) & (unsigned long) (HW_REGS_MASK))

#define MODULE_ID0  (( (unsigned long) ALT_LWFPGASLVS_OFST + MYAVALONBUS32_0_BASE + MODULE_ID0_ADDR ) & (unsigned long) (HW_REGS_MASK))
#define MODULE_ID1  (( (unsigned long) ALT_LWFPGASLVS_OFST + MYAVALONBUS32_0_BASE + MODULE_ID1_ADDR ) & (unsigned long) (HW_REGS_MASK))

//#define CH0_ADC_OFFSET  (( (unsigned long) ALT_LWFPGASLVS_OFST + MYAVALONBUS32_0_BASE + CH0_ADC_OFFSET_ADDR ) & (unsigned long) (HW_REGS_MASK)) // HJ (Nov 27, 2023)
//#define CH1_ADC_OFFSET  (( (unsigned long) ALT_LWFPGASLVS_OFST + MYAVALONBUS32_0_BASE + CH1_ADC_OFFSET_ADDR ) & (unsigned long) (HW_REGS_MASK)) // HJ (Nov 27, 2023)

#define COMB_ALPHA_OFFSET  (( (unsigned long) ALT_LWFPGASLVS_OFST + MYAVALONBUS32_0_BASE + COMB_ALPHA_ADDR ) & (unsigned long) (HW_REGS_MASK)) // Apr 9 2024

extern sem_t       buffer_1_sem;
extern uint8_t*    buffer_1;
extern int         buffer_1_currentSize;

extern sem_t       buffer_2_sem;
extern uint8_t*    buffer_2;
extern int         buffer_2_currentSize;

 


#endif/*__COMMON_H__ */
