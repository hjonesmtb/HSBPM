/*
 * cmd_proc.c  
 * modified March 5 2025. added NL correction.
 */
 


#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "main.h"

#define BLOCK_SIZE 1024 //block transfer size for FAST FIFO
#define PACKET_SIZE 14 //block transfer size for PACKET

static inline void writeReg(void* addr, uint32_t value)
{
    *(uint32_t*) (addr) = value;
}

static inline uint32_t readReg(void* addr)
{

    return *(uint32_t*) (addr);
}

float correction (float x, float y){
	float a = 0.994 ;
	float c = 0.000258;
	
	return a + c*(x^2 + y^2);
	
}


union Data {
	int i;
	float f;
};
	
int dataArray[1024];
extern void* VR_BASE;

void Load_Conf()
{
     writeReg(VR_BASE+EEPROM_RD,0);
}
	 

int cmd_proc(char *cmdString_in , int *value_back, char **string_back, int **array_Ptr, int *array_Dim)
{
	union Data xpos;
	union Data ypos;
	float corr;
		
	char cmd[50],*sdp,*chp;

  //uint32_t trash;
  //uint32_t fifo_wd;

   uint32_t cmdlen, val_len;
   uint32_t invalue,cntr;
    
	strcpy(cmd, cmdString_in);
	chp = strchr(cmd,'\r');
	*chp = '\0';
	cmdlen = strlen(cmd);

	//printf("\n\r cmd_porc.c:Your command is %s, Len=%d\n\r",cmd, cmdlen);

	  
	if ( cmdlen == 0 ){
    	printf("\n\r Error: Your command doesn't contain any characters \n\r" );  return 0;}
	else {
		if ((sdp = strchr(cmd,' ')) != NULL){				  // There is a space in the command
			*sdp = '\0';
			sdp++;
			if ((chp = strchr(sdp,' ')) != NULL){
				chp = strrchr(sdp,' ');                       // Check if there were more than one spaces
				sdp = ++chp;
			}

			val_len = strlen(sdp);
			if (val_len > 0){
				if (val_len == strspn(sdp,"-1234567890")) {
					invalue = atoi(sdp);
				}
				else { printf("\n\r Error: There is a non digit character in value \n\r" ); return 0;
				}
			}
		}
        
		//printf("\n\r cmd_porc.c:Your command is %s %d\n\r",cmd,invalue );
		
		if ( strcmp(cmd,"CR")== 0 ) {writeReg(VR_BASE+CR,invalue);return 0;}
		if ( strcmp(cmd,"CR?")== 0 ) {*value_back = readReg(VR_BASE+CR);return 1;}
		if ( strcmp(cmd,"SR?")== 0 ) {*value_back = readReg(VR_BASE+SR);return 1;}
		if ( strcmp(cmd,"MR")== 0 ) {writeReg(VR_BASE+MR,invalue);return 0;}
		if ( strcmp(cmd,"MR?")== 0 ) {*value_back = readReg(VR_BASE+MR);return 1;}
		if ( strcmp(cmd,"FPGA_VER?")== 0 ) {*value_back = readReg(VR_BASE+FPGA_VER);return 1;}
		if ( strcmp(cmd,"FW_VER?")== 0 ) {*value_back = FW_VERSION;return 1;}
				
		if ( strcmp(cmd,"CH:SEL")== 0 ) {writeReg(VR_BASE+CH_SEL,invalue);return 0;}
		
		if ( strcmp(cmd,"PCA:GAIN")== 0 ) {writeReg(VR_BASE+PCA_GAIN,invalue);return 0;}
		if ( strcmp(cmd,"PCA:GAIN?")== 0 ) {*value_back = readReg(VR_BASE+PCA_GAIN);return 1;}
		
	
		if ( strcmp(cmd,"CONF2EEPROM")== 0 ) {writeReg(VR_BASE+EEPROM_WR,invalue);return 0;}
		if ( strcmp(cmd,"EEPROM2CONF")== 0 ) {writeReg(VR_BASE+EEPROM_RD,invalue);return 0;}
		 

		if ( strcmp(cmd,"SFIFO:WD?")== 0 ) {*value_back = readReg(VR_BASE+SFIFO_WD);return 1;}
		if ( strcmp(cmd,"SFIFO?")== 0 ) {
			
				for(cntr=0;cntr<PACKET_SIZE;cntr++){
					if(cntr == 6) {
						xpos.i = readReg(VR_BASE+SFIFO); // read X position into memory;	
					}
					else if(cntr == 7) {
							ypos.i = readReg(VR_BASE+SFIFO); // read Y position into memory;	
						}


					else{
						dataArray[cntr]= readReg(VR_BASE+SFIFO);	
					}
				}
			// apply corrections to X and Y positions
			corr = correction(xpos.f,ypos.f); //corr ~ (1 + c*r^2)
			xpos.f = xpos.f*corr;
			ypos.f = ypos.f*corr;
				
			dataArray[6] = xpos.i;	
			dataArray[7] = ypos.i;	
			
			*array_Ptr = &dataArray[0]; *array_Dim = PACKET_SIZE;
    		return 3;}
		
		if ( strcmp(cmd,"FIFO:CLR")== 0 ) {writeReg(VR_BASE+FIFO_CLR,invalue);return 0;}
		if ( strcmp(cmd,"FIFO:WD?")== 0 ) {*value_back = readReg(VR_BASE+FIFO_WD);return 1;}	
		if ( strcmp(cmd,"FIFO?")== 0 ) {
    		for(cntr=0;cntr<BLOCK_SIZE;cntr++)  dataArray[cntr]= readReg(VR_BASE+FIFO);
			*array_Ptr = &dataArray[0]; *array_Dim = BLOCK_SIZE;
    		return 3;}
		
        if ( strcmp(cmd,"TRIG:TH")== 0 ) {writeReg(VR_BASE+TRIG_TH,invalue);return 0;}
		if ( strcmp(cmd,"TRIG:TH?")== 0 ) {*value_back = readReg(VR_BASE+TRIG_TH);return 1;}
		
        if ( strcmp(cmd,"TRANSITION")== 0 ) {writeReg(VR_BASE+TRANSITION,invalue);return 0;}
		if ( strcmp(cmd,"TRANSITION?")== 0 ) {*value_back = readReg(VR_BASE+TRANSITION);return 1;}


        if ( strcmp(cmd,"CAL_WAVE")== 0 ) {writeReg(VR_BASE+CAL_WAVE,invalue);return 0;}
		if ( strcmp(cmd,"CAL_WAVE?")== 0 ) {*value_back = readReg(VR_BASE+CAL_WAVE);return 1;}
		
		if ( strcmp(cmd,"IIR_OUT_K1")== 0 ) {writeReg(VR_BASE+IIR_OUT_K1,invalue);return 0;}
		if ( strcmp(cmd,"IIR_OUT_K1?")== 0 ) {*value_back = readReg(VR_BASE+IIR_OUT_K1);return 1;}

		if ( strcmp(cmd,"BL")== 0 ) {writeReg(VR_BASE+BL,invalue);return 0;}
		if ( strcmp(cmd,"BL?")== 0 ) {*value_back = readReg(VR_BASE+BL);return 1;}
		
		if ( strcmp(cmd,"IIR_OUT_K2")== 0 ) {writeReg(VR_BASE+IIR_OUT_K2,invalue);return 0;}
		if ( strcmp(cmd,"IIR_OUT_K2?")== 0 ) {*value_back = readReg(VR_BASE+IIR_OUT_K2);return 1;}
		
		if ( strcmp(cmd,"MODULE_ID0")== 0 ) {writeReg(VR_BASE+MODULE_ID0,invalue);return 0;}
		if ( strcmp(cmd,"MODULE_ID0?")== 0 ) {*value_back = readReg(VR_BASE+MODULE_ID0);return 1;}
		
		if ( strcmp(cmd,"MODULE_ID1")== 0 ) {writeReg(VR_BASE+MODULE_ID1,invalue);return 0;}
		if ( strcmp(cmd,"MODULE_ID1?")== 0 ) {*value_back = readReg(VR_BASE+MODULE_ID1);return 1;}
		
		if ( strcmp(cmd,"FP_KXY")== 0 ) {writeReg(VR_BASE+FP_KXY,invalue);return 0;}
		if ( strcmp(cmd,"FP_KXY?")== 0 ) {*value_back = readReg(VR_BASE+FP_KXY);return 1;}
		
		if ( strcmp(cmd,"X_OFFSET")== 0 ) {writeReg(VR_BASE+X_OFFSET,invalue);return 0;}
		if ( strcmp(cmd,"X_OFFSET?")== 0 ) {*value_back = readReg(VR_BASE+X_OFFSET);return 1;}
		
		if ( strcmp(cmd,"Y_OFFSET")== 0 ) {writeReg(VR_BASE+Y_OFFSET,invalue);return 0;}
		if ( strcmp(cmd,"Y_OFFSET?")== 0 ) {*value_back = readReg(VR_BASE+Y_OFFSET);return 1;}
			
        if ( strcmp(cmd,"FP_CH0_NF")== 0 ) {writeReg(VR_BASE+FP_CH0_NF,invalue);return 0;}
		if ( strcmp(cmd,"FP_CH0_NF?")== 0 ) {*value_back = readReg(VR_BASE+FP_CH0_NF);return 1;}

		if ( strcmp(cmd,"FP_CH1_NF")== 0 ) {writeReg(VR_BASE+FP_CH1_NF,invalue);return 0;}
		if ( strcmp(cmd,"FP_CH1_NF?")== 0 ) {*value_back = readReg(VR_BASE+FP_CH1_NF);return 1;}
		
		if ( strcmp(cmd,"FP_CH2_NF")== 0 ) {writeReg(VR_BASE+FP_CH2_NF,invalue);return 0;}
		if ( strcmp(cmd,"FP_CH2_NF?")== 0 ) {*value_back = readReg(VR_BASE+FP_CH2_NF);return 1;}

		if ( strcmp(cmd,"FP_CH3_NF")== 0 ) {writeReg(VR_BASE+FP_CH3_NF,invalue);return 0;}
		if ( strcmp(cmd,"FP_CH3_NF?")== 0 ) {*value_back = readReg(VR_BASE+FP_CH3_NF);return 1;}

//		if ( strcmp(cmd,"CH0_OFFSET")== 0 ) {writeReg(VR_BASE+CH0_ADC_OFFSET,invalue);return 0;}
//		if ( strcmp(cmd,"CH0_OFFSET?")== 0 ) {*value_back = readReg(VR_BASE+CH0_ADC_OFFSET);return 1;}
//			
//		if ( strcmp(cmd,"CH1_OFFSET")== 0 ) {writeReg(VR_BASE+CH1_ADC_OFFSET,invalue);return 0;}
//		if ( strcmp(cmd,"CH1_OFFSET?")== 0 ) {*value_back = readReg(VR_BASE+CH1_ADC_OFFSET);return 1;}
		
		// Apr 9 2024
		if ( strcmp(cmd,"COMB_ALPHA")== 0 ) {writeReg(VR_BASE+COMB_ALPHA_OFFSET,invalue);return 0;}
		if ( strcmp(cmd,"COMB_ALPHA?")== 0 ) {*value_back = readReg(VR_BASE+COMB_ALPHA_OFFSET);return 1;}
		
    	printf("\n\r Error: Bad command %s \n\r", cmd);
		
		}

    return 0;

}
