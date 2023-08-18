/*
Copyright by Henry Ko and Nicola Nicolici
Department of Electrical and Computer Engineering
McMaster University
Ontario, Canada
*/

`timescale 1ns/100ps
`ifndef DISABLE_DEFAULT_NET
`default_nettype none
`endif

`include "define_state.h"

// This is the top module
// It connects the UART, SRAM and VGA together.
// It gives access to the SRAM for UART and VGA
module experiment4 (
		/////// board clocks                      ////////////
		input logic CLOCK_50_I,                   // 50 MHz clock

		/////// pushbuttons/switches              ////////////
		input logic[3:0] PUSH_BUTTON_N_I,         // pushbuttons
		input logic[17:0] SWITCH_I,               // toggle switches

		/////// 7 segment displays/LEDs           ////////////
		output logic[6:0] SEVEN_SEGMENT_N_O[7:0], // 8 seven segment displays
		output logic[8:0] LED_GREEN_O,            // 9 green LEDs

		/////// VGA interface                     ////////////
		output logic VGA_CLOCK_O,                 // VGA clock
		output logic VGA_HSYNC_O,                 // VGA H_SYNC
		output logic VGA_VSYNC_O,                 // VGA V_SYNC
		output logic VGA_BLANK_O,                 // VGA BLANK
		output logic VGA_SYNC_O,                  // VGA SYNC
		output logic[7:0] VGA_RED_O,              // VGA red
		output logic[7:0] VGA_GREEN_O,            // VGA green
		output logic[7:0] VGA_BLUE_O,             // VGA blue
		
		/////// SRAM Interface                    ////////////
		inout wire[15:0] SRAM_DATA_IO,            // SRAM data bus 16 bits
		output logic[19:0] SRAM_ADDRESS_O,        // SRAM address bus 18 bits
		output logic SRAM_UB_N_O,                 // SRAM high-byte data mask 
		output logic SRAM_LB_N_O,                 // SRAM low-byte data mask 
		output logic SRAM_WE_N_O,                 // SRAM write enable
		output logic SRAM_CE_N_O,                 // SRAM chip enable
		output logic SRAM_OE_N_O,                 // SRAM output logic enable
		
		/////// UART                              ////////////
		input logic UART_RX_I,                    // UART receive signal
		output logic UART_TX_O                    // UART transmit signal
);
	
logic resetn;

top_state_type top_state;

// For Push button
logic [3:0] PB_pushed;

// For VGA SRAM interface
logic VGA_enable;
logic [17:0] VGA_base_address;
logic [17:0] VGA_SRAM_address;
logic start_M2,start_M1;//different for m1 and m2
logic finish_M1,finish_M2;
logic [17:0] SRAM_address_M1;
logic [15:0] SRAM_write_data_M1;
logic SRAM_we_n_M1;
//logic [15:0] SRAM_read_data_M1;

logic [17:0] SRAM_address_M2;
logic [15:0] SRAM_write_data_M2;
logic SRAM_we_n_M2;
//logic [15:0] SRAM_read_data_M2;

// For SRAM
logic [17:0] SRAM_address;
logic [15:0] SRAM_write_data;
logic SRAM_we_n;
logic [15:0] SRAM_read_data;
logic SRAM_ready;

// For UART SRAM interface
logic UART_rx_enable;
logic UART_rx_initialize;
logic [17:0] UART_SRAM_address;
logic [15:0] UART_SRAM_write_data;
logic UART_SRAM_we_n;
logic [25:0] UART_timer;
logic [6:0] value_7_segment [7:0];
//DUAL
logic [17:0] write_address_a,write_address_b,write_address_a_2,write_address_b_2,write_address_a_3,write_address_b_3;//writing address
logic [31:0] write_data_a,write_data_b,write_data_a_2,write_data_b_2,write_data_a_3,write_data_b_3;
logic write_en_a,write_en_b,write_en_a_2,write_en_b_2,write_en_a_3,write_en_b_3;
logic [31:0] read_data_a,read_data_b,read_data_a_2,read_data_b_2,read_data_a_3,read_data_b_3;

// For error detection in UART
logic Frame_error;

// For disabling UART transmit
assign UART_TX_O = 1'b1;

assign resetn = ~SWITCH_I[17] && SRAM_ready;

// Push Button unit
PB_controller PB_unit (
	.Clock_50(CLOCK_50_I),
	.Resetn(resetn),
	.PB_signal(PUSH_BUTTON_N_I),	
	.PB_pushed(PB_pushed)
);


VGA_SRAM_interface VGA_unit (
	.Clock(CLOCK_50_I),
	.Resetn(resetn),
	.VGA_enable(VGA_enable),
   
	// For accessing SRAM
	.SRAM_base_address(VGA_base_address),
	.SRAM_address(VGA_SRAM_address),
	.SRAM_read_data(SRAM_read_data),
   
	// To VGA pins
	.VGA_CLOCK_O(VGA_CLOCK_O),
	.VGA_HSYNC_O(VGA_HSYNC_O),
	.VGA_VSYNC_O(VGA_VSYNC_O),
	.VGA_BLANK_O(VGA_BLANK_O),
	.VGA_SYNC_O(VGA_SYNC_O),
	.VGA_RED_O(VGA_RED_O),
	.VGA_GREEN_O(VGA_GREEN_O),
	.VGA_BLUE_O(VGA_BLUE_O)
);

// UART SRAM interface
UART_SRAM_interface UART_unit(
	.Clock(CLOCK_50_I),
	.Resetn(resetn), 
   
	.UART_RX_I(UART_RX_I),
	.Initialize(UART_rx_initialize),
	.Enable(UART_rx_enable),
   
	// For accessing SRAM
	.SRAM_address(UART_SRAM_address),
	.SRAM_write_data(UART_SRAM_write_data),
	.SRAM_we_n(UART_SRAM_we_n),
	.Frame_error(Frame_error)
);

// SRAM unit
SRAM_controller SRAM_unit (
	.Clock_50(CLOCK_50_I),
	.Resetn(~SWITCH_I[17]),
	.SRAM_address(SRAM_address),
	.SRAM_write_data(SRAM_write_data),
	.SRAM_we_n(SRAM_we_n),
	.SRAM_read_data(SRAM_read_data),		
	.SRAM_ready(SRAM_ready),
		
	// To the SRAM pins
	.SRAM_DATA_IO(SRAM_DATA_IO),
	.SRAM_ADDRESS_O(SRAM_ADDRESS_O[17:0]),
	.SRAM_UB_N_O(SRAM_UB_N_O),
	.SRAM_LB_N_O(SRAM_LB_N_O),
	.SRAM_WE_N_O(SRAM_WE_N_O),
	.SRAM_CE_N_O(SRAM_CE_N_O),
	.SRAM_OE_N_O(SRAM_OE_N_O)
);


Milestone1 M1_unit(
	.Clock(CLOCK_50_I),
	.Resetn(~SWITCH_I[17]),
	.start(start_M1),
	.finish(finish_M1),
	.SRAM_address(SRAM_address_M1),//the outside is from milestone, inside is used within this module
	.SRAM_write_data(SRAM_write_data_M1),
	.SRAM_we_n(SRAM_we_n_M1),
	.SRAM_read_data(SRAM_read_data)
	);
	

Milestone2 M2_unit(
	.Clock(CLOCK_50_I),
	.Resetn(~SWITCH_I[17]),
	.start(start_M2),
	.finish(finish_M2),
	.SRAM_address(SRAM_address_M2),//the outside is from milestone, inside is used within this module
	.SRAM_write_data(SRAM_write_data_M2),
	.SRAM_we_n(SRAM_we_n_M2),
	.SRAM_read_data(SRAM_read_data),
	
	.DUAL_write(write_data_a),//the, output of m2 is write,address,write_en and it is stored in the following registers,then it is passed to dualport
	.DUAL_write_b(write_data_b),
	.DUAL_address(write_address_a),
	.DUAL_address_b(write_address_b),
	.DUAL_write_en(write_en_a),
	.DUAL_write_en_b(write_en_b),
	.DUAL_read_data( read_data_a),
	.DUAL_read_data_b(read_data_b),
	.DUAL_write_2_a(write_data_a_2),
	.DUAL_write_2_b(write_data_b_2),
	.DUAL_address_2_a(write_address_a_2),
	.DUAL_address_2_b(write_address_b_2),
	.DUAL_write_en_2_a(write_en_a_2),
	.DUAL_write_en_2_b(write_en_b_2),
	.DUAL_read_data_2_a( read_data_a_2),
	.DUAL_read_data_2_b(read_data_b_2),
	.DUAL_write_3_a(write_data_a_3),
	.DUAL_write_3_b(write_data_b_3),
	.DUAL_address_3_a(write_address_a_3),
	.DUAL_address_3_b(write_address_b_3),
	.DUAL_write_en_3_a(write_en_a_3),
	.DUAL_write_en_3_b(write_en_b_3),
	.DUAL_read_data_3_a( read_data_a_3),
	.DUAL_read_data_3_b(read_data_b_3)
	);

	dual_port_RAM RAM_inst0 (
	.address_a ( write_address_a ),//write address_a is passed from M2
	.address_b ( write_address_b),
	.clock ( CLOCK_50_I ),
	.data_a ( write_data_a),
	.data_b (  write_data_b),//second port not used
	.wren_a ( write_en_a),
	.wren_b ( write_en_b),//second port not write
	.q_a ( read_data_a ),
	.q_b ( read_data_b )
	);
	
	
	dual_port_RAM RAM_inst1 (
	.address_a (write_address_a_2 ),//write address_a is passed from M2
	.address_b (write_address_b_2 ),
	.clock ( CLOCK_50_I ),
	.data_a (write_data_a_2 ),
	.data_b (  write_data_b_2),//second port not write
	.wren_a ( write_en_a_2),
	.wren_b ( write_en_b_2),//second port not write
	.q_a ( read_data_a_2 ),
	.q_b ( read_data_b_2 )
	);
	
	dual_port_RAM RAM_inst2 (
	.address_a (write_address_a_3 ),//write address_a is passed from M2
	.address_b (write_address_b_3 ),
	.clock ( CLOCK_50_I ),
	.data_a (write_data_a_3 ),
	.data_b (  write_data_b_3),//second port not write
	.wren_a ( write_en_a_3),
	.wren_b ( write_en_b_3),//second port not write
	.q_a ( read_data_a_3 ),
	.q_b ( read_data_b_3 )
	);
	
	
assign SRAM_ADDRESS_O[19:18] = 2'b00;

always @(posedge CLOCK_50_I or negedge resetn) begin
	if (~resetn) begin
		top_state <= S_IDLE;
		
		UART_rx_initialize <= 1'b0;
		UART_rx_enable <= 1'b0;
		UART_timer <= 26'd0;
		start_M2<=1'd0;
		start_M1<=1'd0;
		VGA_enable <= 1'b1;
	end else begin

		// By default the UART timer (used for timeout detection) is incremented
		// it will be synchronously reset to 0 under a few conditions (see below)
		UART_timer <= UART_timer + 26'd1;

		case (top_state)
		S_IDLE: begin
			VGA_enable <= 1'b1;  
			if (~UART_RX_I) begin
				// Start bit on the UART line is detected
				UART_rx_initialize <= 1'b1;
				UART_timer <= 26'd0;
				VGA_enable <= 1'b0;
				top_state <= S_UART_RX;
			end
		end

		S_UART_RX: begin
			// The two signals below (UART_rx_initialize/enable)
			// are used by the UART to SRAM interface for 
			// synchronization purposes (no need to change)
			UART_rx_initialize <= 1'b0;
			UART_rx_enable <= 1'b0;
			if (UART_rx_initialize == 1'b1) 
				UART_rx_enable <= 1'b1;

			// UART timer resets itself every time two bytes have been received
			// by the UART receiver and a write in the external SRAM can be done
			if (~UART_SRAM_we_n) 
				UART_timer <= 26'd0;

			// Timeout for 1 sec on UART (detect if file transmission is finished)
			if (UART_timer == 26'd49999999) begin
				top_state <= S_M2;//change to m1 for m1, m2 for m2 ****************************************************
				start_M2<=1'd1;////////////////////////////////// change to M1 for M1 and M2 for M2
				UART_timer <= 26'd0;
			end
		end
			S_M2: begin
		if(finish_M2==1'd1)begin
		start_M2<=1'd0;
		top_state<=S_IDLE;
		end
		end		
		
		S_M1: begin
		if(finish_M1==1'd1)begin
		start_M1<=1'd0;
		top_state<=S_IDLE;
		end
		end
		
		default: top_state <= S_IDLE;

		endcase
	end
end

// for this design we assume that the RGB data starts at location 0 in the external SRAM
// if the memory layout is different, this value should be adjusted 
// to match the starting address of the raw RGB data segment
assign VGA_base_address = 18'd146944;

// Give access to SRAM for UART and VGA at appropriate time
assign SRAM_address = (top_state == S_UART_RX) ? UART_SRAM_address : (top_state == S_M1) ? SRAM_address_M1:(top_state == S_M2) ? SRAM_address_M2:VGA_SRAM_address;

assign SRAM_write_data = (top_state == S_UART_RX) ? UART_SRAM_write_data :(top_state == S_M1) ? SRAM_write_data_M1:(top_state == S_M2) ? SRAM_write_data_M2:16'd0;

assign SRAM_we_n = (top_state == S_UART_RX) ? UART_SRAM_we_n :(top_state == S_M1) ? SRAM_we_n_M1:(top_state == S_M2) ? SRAM_we_n_M2:1'b1;

// 7 segment displays
convert_hex_to_seven_segment unit7 (
	.hex_value(SRAM_read_data[15:12]), 
	.converted_value(value_7_segment[7])
);

convert_hex_to_seven_segment unit6 (
	.hex_value(SRAM_read_data[11:8]), 
	.converted_value(value_7_segment[6])
);

convert_hex_to_seven_segment unit5 (
	.hex_value(SRAM_read_data[7:4]), 
	.converted_value(value_7_segment[5])
);

convert_hex_to_seven_segment unit4 (
	.hex_value(SRAM_read_data[3:0]), 
	.converted_value(value_7_segment[4])
);

convert_hex_to_seven_segment unit3 (
	.hex_value({2'b00, SRAM_address[17:16]}), 
	.converted_value(value_7_segment[3])
);

convert_hex_to_seven_segment unit2 (
	.hex_value(SRAM_address[15:12]), 
	.converted_value(value_7_segment[2])
);

convert_hex_to_seven_segment unit1 (
	.hex_value(SRAM_address[11:8]), 
	.converted_value(value_7_segment[1])
);

convert_hex_to_seven_segment unit0 (
	.hex_value(SRAM_address[7:4]), 
	.converted_value(value_7_segment[0])
);

assign   
   SEVEN_SEGMENT_N_O[0] = value_7_segment[0],
   SEVEN_SEGMENT_N_O[1] = value_7_segment[1],
   SEVEN_SEGMENT_N_O[2] = value_7_segment[2],
   SEVEN_SEGMENT_N_O[3] = value_7_segment[3],
   SEVEN_SEGMENT_N_O[4] = value_7_segment[4],
   SEVEN_SEGMENT_N_O[5] = value_7_segment[5],
   SEVEN_SEGMENT_N_O[6] = value_7_segment[6],
   SEVEN_SEGMENT_N_O[7] = value_7_segment[7];

assign LED_GREEN_O = {resetn, VGA_enable, ~SRAM_we_n, Frame_error, UART_rx_initialize, PB_pushed};

endmodule
