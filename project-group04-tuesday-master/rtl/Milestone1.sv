
`timescale 1ns/100ps
`ifndef DISABLE_DEFAULT_NET
`default_nettype none
`endif

`include "define_state.h"

// This module monitors the data from UART
// It also assembles and writes the data into the SRAM
module Milestone1 (
   input  logic		      Clock,
	input  logic		      Resetn, 
	input  logic            start,
	input  logic   [15:0]   SRAM_read_data,//read data Y U V from Sram
	output logic   [17:0]	SRAM_address,
	output logic   [15:0]	SRAM_write_data,//write the rgb values when needed
	input  logic   [17:0]   SRAM_base_address,//not used
	output logic		      SRAM_we_n,
	output logic            finish
);

Milestone_1_state_type State;

logic    [7:0]    VGA_red_even, VGA_green_even, VGA_blue_even;//data that will written into the write_data
logic    [7:0]    VGA_red_odd, VGA_green_odd, VGA_blue_odd;
logic    [7:0]    U1,U2,U3,U4,U5,U6;//6 is most significant one, and will be updated every cc
logic  	[7:0]		V1,V2,V3,V4,V5,V6;
logic 	[31:0]	U_odd,V_odd,U_acc,V_acc,Green_temp,Blue_temp;
logic    [7:0]    U_even,V_even;
logic 	[31:0]   Y_even,Y_odd;
logic		[31:0]   Red_even,Red_odd,Green_even,Green_odd,Blue_even,Blue_odd;

logic [7:0] Utemp,Vtemp;
logic [19:0] U_offset,V_offset,Y_offset,RGB_offset;
logic [31:0] multiplierU,multiplierV,multiplierOdd,multiplierEven;
logic [7:0] a,b;
logic [9:0] c;
logic [31:0] op1,Uop2,Vop2;
logic [19:0] a00,a11,a21,a02,a12;
logic [31:0] opC,rgb_odd,rgb_even;
logic [2:0] uv_select;
logic [2:0] rgb_select;
logic [7:0] count;
logic [7:0] countRow;
logic read;

logic [7:0] clipRedE,clipRedO,clipGreenE,clipGreenO,clipBlueE,clipBlueO;


assign a = 8'd21;
assign b = -52;
assign c = 10'd159;

assign a00 = 20'd76284;
assign a11 = -25624;
assign a21 = 20'd132251;
assign a02 = 20'd104595;
assign a12 = -53281;


always_comb begin
	if(uv_select==3'd0)begin
	op1 = {24'b0,a[7:0]};
	Uop2 = {24'b0,U1[7:0]};
	Vop2 = {24'b0,V1[7:0]};
	end
	else if(uv_select==3'd1)begin
	op1 = {{24{b[7]}},b[7:0]};
	Uop2 = {24'b0,U2[7:0]};
	Vop2 = {24'b0,V2[7:0]};
	end
	else if(uv_select==3'd2)begin
	op1 = {{22{c[9]}},c[9:0]};
	Uop2 = {24'b0,U3[7:0]};
	Vop2 = {24'b0,V3[7:0]};
	end
	else if(uv_select==3'd3)begin
	op1 = {{22{c[9]}},c[9:0]};
	Uop2 = {24'b0,U4[7:0]};
	Vop2 = {24'b0,V4[7:0]};
	end
	else if(uv_select==3'd4)begin
	op1 = {{24{b[7]}},b[7:0]};
	Uop2 = {24'b0,U5[7:0]};
	Vop2 = {24'b0,V5[7:0]};
	end
	else if(uv_select==3'd5)begin
	op1 = {24'b0,a[7:0]};
	Uop2 = {24'b0,U6[7:0]};
	Vop2 = {24'b0,V6[7:0]};
	end
	
	else begin
	op1 = 32'd0;
	Uop2 = 32'd0;
	Vop2 = 32'd0;
	end

end

always_comb begin
	if(rgb_select==3'd0)begin
	opC = {{12{a00[19]}},a00[19:0]};
	rgb_odd = {24'b0,Y_odd[7:0]}-32'd16;
	rgb_even = {24'b0,Y_even[7:0]}-32'd16;
	end
	else if(rgb_select==3'd1)begin
	opC = {{12{a02[19]}},a02[19:0]};
	rgb_odd = {8'b0,V_odd[31:8]}-32'd128;
	rgb_even = {24'b0,V_even[7:0]}-32'd128;
	end
	else if(rgb_select==3'd2)begin
	opC = {{12{a11[19]}},a11[19:0]};
	rgb_odd = {8'b0,U_odd[31:8]}-32'd128;
	rgb_even = {24'b0,U_even[7:0]}-32'd128;
	end
	else if(rgb_select==3'd3)begin
	opC = {{12{a12[19]}},a12[19:0]};
	rgb_odd = {8'b0,V_odd[31:8]}-32'd128;
	rgb_even = {24'b0,V_even[7:0]}-32'd128;
	end
	else if(rgb_select==3'd4)begin
	opC = {{12{a21[19]}},a21[19:0]};
	rgb_odd = {8'b0,U_odd[31:8]}-32'd128;
	rgb_even = {24'b0,U_even[7:0]}-32'd128;
	end
	
	else begin
	opC = 32'd0;
	rgb_odd = 32'd0;
	rgb_even = 32'd0;
	end

end

assign multiplierU = $signed(op1)*$signed(Uop2);
assign multiplierV = $signed(op1)*$signed(Vop2);
assign multiplierOdd = $signed(opC)*$signed(rgb_odd);
assign multiplierEven = $signed(opC)*$signed(rgb_even);

//assign multiplierU = op1*Uop2;
//assign multiplierV = op1*Vop2;
//assign multiplierOdd = opC*rgb_odd;
//assign multiplierEven = opC*rgb_even;

always_comb begin
	clipBlueE = Blue_even[23:16];
	if(|Blue_even[30:24]==1'b1) clipBlueE=8'hFF;
	if(Blue_even[31]==1'b1) clipBlueE=8'h00;
	
	clipRedO = Red_odd[23:16];
	if(|Red_odd[30:24]==1'b1) clipRedO=8'hFF;
	if(Red_odd[31]==1'b1) clipRedO=8'h00;
	
	
	clipGreenO = Green_temp[23:16];
	if(|Green_temp[30:24]==1'b1) clipGreenO=8'hFF;
	if(Green_temp[31]==1'b1) clipGreenO=8'h00;
	
	clipBlueO = Blue_temp[23:16];
	if(|Blue_temp[30:24]==1'b1) clipBlueO=8'hFF;
	if(Blue_temp[31]==1'b1) clipBlueO=8'h00;
	
	clipRedE = Red_even[23:16];
	if(|Red_even[30:24]==1'b1) clipRedE=8'hFF;
	if(Red_even[31]==1'b1) clipRedE=8'h00;
	
	clipGreenE = Green_even[23:16];
	if(|Green_even[30:24]==1'b1) clipGreenE=8'hFF;
	if(Green_even[31]==1'b1) clipGreenE=8'h00;
end




always_ff @ (posedge Clock or negedge Resetn) begin
	if (~Resetn) begin
		SRAM_we_n <= 1'b1;//initially no writing
		SRAM_write_data <= 16'd0;
		SRAM_address <= 18'd0;
		U_acc<=32'd128;
		V_acc<=32'd128;
		uv_select<=3'd0;
		rgb_select<=3'd0;
		read <= 1'b1;
		Y_odd=32'd0;
		Y_even=32'd0;
		U_odd=32'd0;
		U_even=32'd0;
		V_odd=32'd0;
		V_even=32'd0;
		U1<=8'd0;
		U2<=8'd0;
		U3<=8'd0;
		U4<=8'd0;
		U5<=8'd0;
		U6<=8'd0;
		V1<=8'd0;
		V2<=8'd0;
		V3<=8'd0;
		V4<=8'd0;
		V5<=8'd0;
		V6<=8'd0;
		Red_even<=8'd0;
		Green_even<=8'd0;
		Blue_even<=8'd0;
		Red_odd<=8'd0;
		Green_odd<=8'd0;
		Blue_odd<=8'd0;
		Blue_temp<=8'd0;
		Green_temp<=8'd0;
		
		U_offset<=20'd38400;
		V_offset<=20'd57600;
		Y_offset<=20'd0;
		RGB_offset<=20'd146944;
		finish<=1'd0;
		State<=idle;
	
		
		count<=8'd0;//for lead in, count is 0
		countRow<=8'd0;
		

		end else begin
			case (State)
			
			idle: begin
				
			if(start==1'd1)begin
				State<=State_Lead_in_1;
				count<=8'd0;
				finish<=1'b0;
				SRAM_we_n<=1'd1;
				SRAM_address<=U_offset;
				U_offset<=U_offset+1'd1;
			end

			end
			
			
			
			State_Lead_in_1: begin
			SRAM_address<=V_offset;
			V_offset<=V_offset+1'd1;
			State<=State_Lead_in_2;
			end
			
			State_Lead_in_2: begin
			SRAM_address<=U_offset;
			U_offset<=U_offset+1'd1;
			State<=State_Lead_in_3;
			end
			
			State_Lead_in_3: begin
			SRAM_address<=V_offset;
			V_offset<=V_offset+1'd1;
			U1<=SRAM_read_data[15:8];//U0
			U2<=SRAM_read_data[15:8];//U0
			U3<=SRAM_read_data[15:8];//U0
			U4<=SRAM_read_data[7:0];//U1
			
			State<=State_Lead_in_4;
			end
			
			State_Lead_in_4: begin
			V1<=SRAM_read_data[15:8];//V0
			V2<=SRAM_read_data[15:8];//V0
			V3<=SRAM_read_data[15:8];//V0
			V4<=SRAM_read_data[7:0];//V1 			
			State<=State_Lead_in_5;
			end
			
			
			State_Lead_in_5: begin
			U5<=SRAM_read_data[15:8];//U2
			U6<=SRAM_read_data[7:0];//U3
			U_acc<=U_acc+multiplierU;
			V_acc<=V_acc+multiplierV;
			uv_select <= uv_select+3'd1;
			State<=State_Lead_in_6;
			end
			
			State_Lead_in_6:begin
			V5<=SRAM_read_data[15:8];//V2
			V6<=SRAM_read_data[7:0];//V3
			U_acc<=U_acc+multiplierU;
			V_acc<=V_acc+multiplierV;
			uv_select <= uv_select+3'd1;
			
			State<=State_Lead_in_7;
			end
			
			
			State_Lead_in_7: begin
			SRAM_address<=Y_offset;
			Y_offset<=Y_offset+1'd1;
			U_acc<=U_acc+multiplierU;
			V_acc<=V_acc+multiplierV;
			uv_select <= uv_select+3'd1;
			State<=State_Lead_in_8;
			end
			
			
			State_Lead_in_8: begin
			SRAM_address<=U_offset;
			U_offset<=U_offset+1'd1;
			U_acc<=U_acc+multiplierU;
			V_acc<=V_acc+multiplierV;
			uv_select <= uv_select+3'd1;
			State<=State_Lead_in_9;
			end
			

			
			State_Lead_in_9: begin
			SRAM_address<=V_offset;
			V_offset<=V_offset+1'd1;
			U_acc<=U_acc+multiplierU;
			V_acc<=V_acc+multiplierV;
			uv_select <= uv_select+3'd1;
			
			
			State<=State_Lead_in_10;
			end
			
			
			State_Lead_in_10: begin
			
			U_odd<=U_acc+multiplierU;
			V_odd<=V_acc+multiplierV;
			U_acc<=32'd128;//reset
			V_acc<=32'd128;//reset
			uv_select<=3'd0;
			
			U1<=U2;// shift for next cc
			U2<=U3;// shift for next cc
			U3<=U4;// shift for next cc
			U4<=U5;// shift for next cc
			U5<=U6;	// shift for next cc
			
			V1<=V2;// shift for next cc
			V2<=V3;// shift for next cc
			V3<=V4;// shift for next cc
			V4<=V5;// shift for next cc
			V5<=V6;	// shift for next cc
			U_even<=U3;
			V_even<=V3;
			Y_even=SRAM_read_data[15:8];
			Y_odd=SRAM_read_data[7:0];
			State<=Common_Case_1;
			end
	


	
			Common_Case_1: begin
			
			if(read==1'b1 && count<8'd156)begin
			U6<=SRAM_read_data[15:8];//new data
			Utemp<=SRAM_read_data[7:0];//store the other
			end
			
			if(count>8'd0)begin//not first iteration
			SRAM_address<=RGB_offset;
			RGB_offset<=RGB_offset+1'd1;
			SRAM_write_data<={clipBlueE,clipRedO};
			Green_temp<=Green_odd;
			Blue_temp<=Blue_odd;
			SRAM_we_n<=1'd0;
			end
			
			U_acc<=U_acc+multiplierU;
			V_acc<=V_acc+multiplierV;
			uv_select<=uv_select+3'd1;
	
			Red_odd<=multiplierOdd;//yodd, y=(even,odd)
			Green_odd<=multiplierOdd;//yodd
			Blue_odd<=multiplierOdd;
			Red_even<=multiplierEven;//yeven
			Green_even<=multiplierEven;
			Blue_even<=multiplierEven;
			rgb_select <= rgb_select+3'd1;
			
			State<=Common_Case_2;
			
			end
			
			
			
			
			Common_Case_2: begin
			if(read==1'b1 && count<8'd156)begin//every other cycle read U and V
			V6<=SRAM_read_data[15:8];//new data, (Veven,Vodd)
			Vtemp<=SRAM_read_data[7:0];//
			end
			
			if(count>8'd0)begin//not first iteration
			SRAM_address<=RGB_offset;
			RGB_offset<=RGB_offset+1'd1;
			SRAM_write_data<={clipGreenO,clipBlueO};
			SRAM_we_n<=1'd0;
			end
			
			U_acc<=U_acc+multiplierU;
			V_acc<=V_acc+multiplierV;
			uv_select<=uv_select+3'd1;
			
			Red_odd<=Red_odd + multiplierOdd;//yodd, y=(even,odd)
			Red_even<=Red_even + multiplierEven;//yeven
			rgb_select<=rgb_select+3'd1;
			State<=Common_Case_3;
			end
			
			
			
			
			
			
			
			Common_Case_3: begin
			SRAM_we_n<=1'd1;
			U_acc<=U_acc+multiplierU;
			V_acc<=V_acc+multiplierV;
			uv_select<=uv_select+3'd1;
			
			Green_odd<=Green_odd + multiplierOdd;//yodd, y=(even,odd)
			Green_even<=Green_even + multiplierEven;//yeven
			rgb_select <= rgb_select +3'd1;
			
			SRAM_address<=Y_offset;//read y for next cc
			Y_offset<=Y_offset+1'd1;
			
			count<=count + 8'd1;
			State<=Common_Case_4;
			end
			
			
			Common_Case_4: begin
			U_acc<=U_acc+multiplierU;
			V_acc<=V_acc+multiplierV;//accumulator
			uv_select<=uv_select+3'd1;
			
			Green_odd<=Green_odd + multiplierOdd;//yodd, y=(even,odd)
			Green_even<=Green_even + multiplierEven;//RGB
			rgb_select <= rgb_select + 3'd1;
			
			if(read==1'b0 && count<8'd156)begin//read for Next Cycle, only if read ==0
				SRAM_address<=U_offset;
				U_offset<=U_offset+1'd1;
			end
			
			State<=Common_Case_5;
			end
			
			
			Common_Case_5: begin
			U_acc<=U_acc+multiplierU;//accumulator
			V_acc<=V_acc+multiplierV;
			uv_select<=uv_select+3'd1;
			
			Blue_odd<=Blue_odd + multiplierOdd;//yodd, y=(even,odd)
			Blue_even<=Blue_even + multiplierEven;//yeven
			rgb_select <= 3'd0;

			
			if(read==1'b0 && count<8'd156)begin
				SRAM_address<=V_offset;//read V for next cc
				V_offset<=V_offset+1'd1;
			end
			
			
			State<=Common_Case_6;
			end
			
			
			Common_Case_6:begin
			
			Y_even<=SRAM_read_data[15:8];//read new Y
			Y_odd<=SRAM_read_data[7:0];
			
			U_odd<=U_acc+multiplierU;//U odd and Vodd values computed
			V_odd<=V_acc+multiplierV;
			uv_select<=3'd0;
			
			U_acc<=10'd128;//reset accumulator
			V_acc<=10'd128;
			
			SRAM_address<=RGB_offset;
			RGB_offset<=RGB_offset+1'd1;
			SRAM_write_data<={clipRedE,clipGreenE};
			SRAM_we_n<=1'd0;
			
			U1<=U2;// shift for next cc
			U2<=U3;// shift for next cc
			U3<=U4;// shift for next cc
			U4<=U5;// shift for next cc
			U5<=U6;// shift for next cc
			
			V1<=V2;// shift for next cc
			V2<=V3;// shift for next cc
			V3<=V4;// shift for next cc
			V4<=V5;// shift for next cc
			V5<=V6;	
			U_even<=U3;
			V_even<=V3;
			
			if(read==1'd1 && count<8'd156)begin
				U6<=Utemp;
				V6<=Vtemp;
			end
			
			read<=~read;

			if(count<8'd159) begin
			State<=Common_Case_1;//continue till border
			end else begin
			State<=Lead_out_1;
			end
			
			end
			
			Lead_out_1:begin
			SRAM_address<=RGB_offset;
			RGB_offset<=RGB_offset+1'd1;
			SRAM_write_data<={clipBlueE,clipRedO};
			
			Green_temp<=Green_odd;
			Blue_temp<=Blue_odd;
			
			Red_odd<=multiplierOdd;//yodd, y=(even,odd)
			Green_odd<=multiplierOdd;//yodd
			Blue_odd<=multiplierOdd;
			Red_even<=multiplierEven;//yeven
			Green_even<=multiplierEven;
			Blue_even<=multiplierEven;
			rgb_select <= rgb_select + 3'd1;

			
			State<=Lead_out_2;
			end
			
			Lead_out_2:begin
			SRAM_address<=RGB_offset;
			RGB_offset<=RGB_offset+1'd1;
			SRAM_write_data<={clipGreenO,clipBlueO};
			
			Red_odd<=Red_odd + multiplierOdd;//yodd, y=(even,odd)
			Red_even<=Red_even + multiplierEven;//yeven
			rgb_select <= rgb_select + 3'd1;
			
			
			State<=Lead_out_3;
			end
			
			Lead_out_3:begin
			Green_odd<=Green_odd + multiplierOdd;
			Green_even<=Green_even + multiplierEven;
			rgb_select <= rgb_select + 3'd1;
			SRAM_we_n<=1'd1;
			State<=Lead_out_4;
			end
			
			Lead_out_4:begin
			Green_odd<=Green_odd + multiplierOdd;
			Green_even<=Green_even + multiplierEven;
			rgb_select <= rgb_select + 3'd1;
			State<=Lead_out_5;
			end
			
			Lead_out_5:begin
			Blue_odd<=Blue_odd + multiplierOdd;
			Blue_even<=Blue_even + multiplierEven;
			rgb_select <= 3'd0;
			State<=Lead_out_6;
			end
			
			Lead_out_6:begin
			SRAM_address<=RGB_offset;
			RGB_offset<=RGB_offset+1'd1;
			SRAM_write_data<={clipRedE,clipGreenE};
			SRAM_we_n<=1'd0;
			State<=Lead_out_7;
			end
			
			Lead_out_7:begin
			SRAM_address<=RGB_offset;
			RGB_offset<=RGB_offset+1'd1;
			SRAM_write_data<={clipBlueE,clipRedO};
			Green_temp<=Green_odd;
			Blue_temp<=Blue_odd;
			countRow <= countRow + 8'd1;
			State<=Lead_out_8;
			end
			
			Lead_out_8:begin
			SRAM_address<=RGB_offset;
			RGB_offset<=RGB_offset+1'd1;
			SRAM_write_data<={clipGreenO, clipBlueO};

			State<= stop;
			
			end
			
			stop:begin
			if(countRow<8'd240)begin
				SRAM_address<=U_offset;
				U_offset<=U_offset+1'd1;
				SRAM_we_n<=1'd1;
				State<=State_Lead_in_1;
				U_acc<=32'd128;
				V_acc<=32'd128;
				count<=8'd0;//next line, counter goes back to 0
				read<=1'b1;//always read initially
			end
			
			else begin
				finish<=1'd1;
				SRAM_we_n<=1'd1;
				State<=idle;
			end
			end
			
			
			default: State <=idle;
			endcase
			
	end	
			
end



endmodule
