`ifndef DEFINE_STATE

// for top state - we have more states than needed
typedef enum logic [1:0] {
	S_IDLE,
	S_UART_RX,
	S_M1,
	S_M2
} top_state_type;

typedef enum logic [1:0] {
	S_RXC_IDLE,
	S_RXC_SYNC,
	S_RXC_ASSEMBLE_DATA,
	S_RXC_STOP_BIT
} RX_Controller_state_type;

typedef enum logic [2:0] {
	S_US_IDLE,
	S_US_STRIP_FILE_HEADER_1,
	S_US_STRIP_FILE_HEADER_2,
	S_US_START_FIRST_BYTE_RECEIVE,
	S_US_WRITE_FIRST_BYTE,
	S_US_START_SECOND_BYTE_RECEIVE,
	S_US_WRITE_SECOND_BYTE
} UART_SRAM_state_type;

typedef enum logic [3:0] {
	S_VS_WAIT_NEW_PIXEL_ROW,
	S_VS_NEW_PIXEL_ROW_DELAY_1,
	S_VS_NEW_PIXEL_ROW_DELAY_2,
	S_VS_NEW_PIXEL_ROW_DELAY_3,
	S_VS_NEW_PIXEL_ROW_DELAY_4,
	S_VS_NEW_PIXEL_ROW_DELAY_5,
	S_VS_FETCH_PIXEL_DATA_0,
	S_VS_FETCH_PIXEL_DATA_1,
	S_VS_FETCH_PIXEL_DATA_2,
	S_VS_FETCH_PIXEL_DATA_3
} VGA_SRAM_state_type;

typedef enum logic [4:0] {
	idle,
	State_Lead_in_1,
	State_Lead_in_2,
	State_Lead_in_3,
	State_Lead_in_4,
	State_Lead_in_5,
	State_Lead_in_6,
	State_Lead_in_7,
	State_Lead_in_8,
	State_Lead_in_9,
	State_Lead_in_10,
	Common_Case_1,
	Common_Case_2,
	Common_Case_3,
	Common_Case_4,
	Common_Case_5,
	Common_Case_6,
	Lead_out_1,
	Lead_out_2,
	Lead_out_3,
	Lead_out_4,
	Lead_out_5,
	Lead_out_6,
	Lead_out_7,
	Lead_out_8,
	stop
	
} Milestone_1_state_type;

typedef enum logic [6:0] {
	Idle,
	State_1,
	State_2,
	State_3,
	State_4,
	State_5,
	State_6,
	State_7,
	State_8,
	State_9,
	State_10,
	State_11,
	State_12,
	State_13,
	State_14,
	State_15,
	State_16,
	State_17,
	State_18,
	State_19,
	State_20,
	State_21,
	State_22,
	State_23,
	State_24,
	State_25,
	State_26,
	State_27,
	State_28,
	State_29,
	State_30,
	State_31,
	State_32,
	State_33,
	State_34,
	State_35,
	State_36,
	State_37,
	State_38,
	State_39,
	State_40,
	State_41,
	State_42,
	State_43,
	State_44,
	State_45,
	State_46,
	State_47,
	State_48,
	State_49,
	State_50,
	State_51,
	State_52,
	State_53,
	State_54,
	State_55,
	Buffer,
	Buffer_2,
	Buffer_3,
	Buffer_4,
	Lead_in1,
	Lead_in2,
	Lead_in3,
	Lead_in4,
	Stop
} Milestone_2_state_type;

parameter 
   VIEW_AREA_LEFT = 160,
   VIEW_AREA_RIGHT = 480,
   VIEW_AREA_TOP = 120,
   VIEW_AREA_BOTTOM = 360;

`define DEFINE_STATE 1
`endif
