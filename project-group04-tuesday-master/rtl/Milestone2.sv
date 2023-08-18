


`timescale 1ns/100ps
`ifndef DISABLE_DEFAULT_NET
`default_nettype none
`endif



`include "define_state.h"

// This module monitors the data from UART
// It also assembles and writes the data into the SRAM
module Milestone2 (
   input  logic		      Clock,
	input  logic		      Resetn, 
	input  logic            start,
	input  logic   [15:0]   SRAM_read_data,//both dual port ports
	input logic    [31:0]	DUAL_read_data,DUAL_read_data_b,DUAL_read_data_2_a,DUAL_read_data_2_b,DUAL_read_data_3_a,DUAL_read_data_3_b,
	output logic   [17:0]	SRAM_address,
	output logic   [15:0]	SRAM_write_data,//write the rgb values when needed
	output logic 				SRAM_we_n,
	output logic  	[17:0]   DUAL_address,DUAL_address_b,DUAL_address_2_a,DUAL_address_2_b,DUAL_address_3_a,DUAL_address_3_b,//address for both ports in dual port
	output logic   [31:0] 	DUAL_write,DUAL_write_b,DUAL_write_2_a,DUAL_write_2_b,DUAL_write_3_a,DUAL_write_3_b,//write for only top port for first instance
	output logic		      DUAL_write_en,DUAL_write_en_b,DUAL_write_en_2_a,DUAL_write_en_2_b,DUAL_write_en_3_a,DUAL_write_en_3_b,//write only top port
	output logic            finish
);

	Milestone_2_state_type State;
	

logic state_count;
logic [3:0] coeff_counter;//for what c coefficent from matrix
logic [6:0]	c_counter;
logic [7:0] counter,cb,rb,loop,cb2,rb2;

logic [15:0] ca,ra;
logic [31:0] acc1,acc2,acc3,acc4;
logic [19:0] Y_offset;

logic [15:0] DUAL_offset,DUAL_offset_b,DUAL_offset_2_a,DUAL_offset_2_b,DUAL_offset_3_a,DUAL_offset_3_b;
logic [8:0] offset;//for DUAL offset 1 resest

logic [31:0] multiplier_1,multiplier_2,multiplier_3,multiplier_4;
logic [15:0] c00,c01,c02,c03,c04,c05,c06,c07,c10,c11,c12,c13,c14,c15,c16,c17,temp;
logic [15:0] c20,c21,c22,c23,c24,c25,c26,c27,c30,c31,c32,c33,c34,c35,c36,c37;
logic [15:0] c40,c41,c42,c43,c44,c45,c46,c47,c50,c51,c52,c53,c54,c55,c56,c57;
logic [15:0] c60,c61,c62,c63,c64,c65,c66,c67,c70,c71,c72,c73,c74,c75,c76,c77;
logic Ct,invert;
logic [17:0] YUV_offset;
assign c00=1448;assign c01=1448;assign c02=1448;assign c03=1448;assign c04=1448;assign c05=1448;assign c06=1448;assign c07=1448;
assign c10=2008;assign c11=1702;assign c12=1137;assign c13=399;assign c14=-399;assign c15=-1137;assign c16=-1702;assign c17=-2008;
assign c20=1892;assign c21=783;assign c22=-783;assign c23=-1892;assign c24=-1892;assign c25=-783;assign c26=783;assign c27=1892;
assign c30=1702;assign c31=-399;assign c32=-2008;assign c33=-1137;assign c34=1137;assign c35=2008;assign c36=399;assign c37=-1702;
assign c40=1448;assign c41=-1448;assign c42=-1448;assign c43=1448;assign c44=1448;assign c45=-1448;assign c46=-1448;assign c47=1448;
assign c50=1137;assign c51=-2008;assign c52=399;assign c53=1702;assign c54=-1702;assign c55=-399;assign c56=2008;assign c57=-1137;
assign c60=783;assign c61=-1892;assign c62=1892;assign c63=-783;assign c64=-783;assign c65=1892;assign c66=-1892;assign c67=783;
assign c70=399;assign c71=-1137;assign c72=1702;assign c73=-2008;assign c74=2008;assign c75=-1702;assign c76=1137;assign c77=-399;

logic[31:0] op2,op3,op4,op5;
logic[31:0] op1;


always_comb begin


	if(coeff_counter==4'd0 && Ct==1'd0) begin
		op2 = {{16{c00[15]}},c00[15:0]};
		op3 = {{16{c01[15]}},c01[15:0]};
		op4 = {{16{c02[15]}},c02[15:0]};
		op5 = {{16{c03[15]}},c03[15:0]};
	end
	else if(coeff_counter==4'd1 && Ct==1'd0) begin
		op2 = {{16{c10[15]}},c10[15:0]};
		op3 = {{16{c11[15]}},c11[15:0]};
		op4 = {{16{c12[15]}},c12[15:0]};
		op5 = {{16{c13[15]}},c13[15:0]};
	end
	else if(coeff_counter==4'd2 && Ct==1'd0) begin
		op2 = {{16{c20[15]}},c20[15:0]};
		op3 = {{16{c21[15]}},c21[15:0]};
		op4 = {{16{c22[15]}},c22[15:0]};
		op5 = {{16{c23[15]}},c23[15:0]};
	end
	else if(coeff_counter==4'd3 && Ct==1'd0) begin
		op2 = {{16{c30[15]}},c30[15:0]};
		op3 = {{16{c31[15]}},c31[15:0]};
		op4 = {{16{c32[15]}},c32[15:0]};
		op5 = {{16{c33[15]}},c33[15:0]};
	end
	else if(coeff_counter==4'd4 && Ct==1'd0) begin
		op2 = {{16{c40[15]}},c40[15:0]};
		op3 = {{16{c41[15]}},c41[15:0]};
		op4 = {{16{c42[15]}},c42[15:0]};
		op5 = {{16{c43[15]}},c43[15:0]};
	end
	else if(coeff_counter==4'd5&& Ct==1'd0) begin
		op2 = {{16{c50[15]}},c50[15:0]};
		op3 = {{16{c51[15]}},c51[15:0]};
		op4 = {{16{c52[15]}},c52[15:0]};
		op5 = {{16{c53[15]}},c53[15:0]};
	end
	else if(coeff_counter==4'd6&& Ct==1'd0) begin
		op2 = {{16{c60[15]}},c60[15:0]};//####Can change C_count to c[3:0]
		op3 = {{16{c61[15]}},c61[15:0]};
		op4 = {{16{c62[15]}},c62[15:0]};
		op5 = {{16{c63[15]}},c63[15:0]};
	end
	else if(coeff_counter==4'd7&& Ct==1'd0) begin
		op2 = {{16{c70[15]}},c70[15:0]};
		op3 = {{16{c71[15]}},c71[15:0]};
		op4 = {{16{c72[15]}},c72[15:0]};
		op5 = {{16{c73[15]}},c73[15:0]};
	end
	else if(coeff_counter==4'd8&& Ct==1'd0) begin
		op2 = {{16{c04[15]}},c04[15:0]};
		op3 = {{16{c05[15]}},c05[15:0]};
		op4 = {{16{c06[15]}},c06[15:0]};
		op5 = {{16{c07[15]}},c07[15:0]};
	end
	else if(coeff_counter==4'd9&& Ct==1'd0) begin
		op2 = {{16{c14[15]}},c14[15:0]};
		op3 = {{16{c15[15]}},c15[15:0]};
		op4 = {{16{c16[15]}},c16[15:0]};
		op5 = {{16{c17[15]}},c17[15:0]};
	end
	else if(coeff_counter==4'd10&& Ct==1'd0) begin
		op2 = {{16{c24[15]}},c24[15:0]};
		op3 = {{16{c25[15]}},c25[15:0]};
		op4 = {{16{c26[15]}},c26[15:0]};
		op5 = {{16{c27[15]}},c27[15:0]}; 
	end
	else if(coeff_counter==4'd11&& Ct==1'd0) begin
		op2 = {{16{c34[15]}},c34[15:0]};
		op3 = {{16{c35[15]}},c35[15:0]};
		op4 = {{16{c36[15]}},c36[15:0]};
		op5 = {{16{c37[15]}},c37[15:0]};
	end
	else if(coeff_counter==4'd12&& Ct==1'd0) begin
		op2 = {{16{c44[15]}},c44[15:0]};
		op3 = {{16{c45[15]}},c45[15:0]};
		op4 = {{16{c46[15]}},c46[15:0]};
		op5 = {{16{c47[15]}},c47[15:0]};
	end
	else if(coeff_counter==4'd13&& Ct==1'd0) begin
		op2 = {{16{c54[15]}},c54[15:0]};
		op3 = {{16{c55[15]}},c55[15:0]};
		op4 = {{16{c56[15]}},c56[15:0]};
		op5 = {{16{c57[15]}},c57[15:0]};
	end
	else if(coeff_counter==4'd14&& Ct==1'd0) begin
		op2 = {{16{c64[15]}},c64[15:0]};
		op3 = {{16{c65[15]}},c65[15:0]};
		op4 = {{16{c66[15]}},c66[15:0]};
		op5 = {{16{c67[15]}},c67[15:0]};
	end
	else if(coeff_counter==4'd15&& Ct==1'd0) begin
		op2 = {{16{c74[15]}},c74[15:0]};
		op3 = {{16{c75[15]}},c75[15:0]};
		op4 = {{16{c76[15]}},c76[15:0]};
		op5 = {{16{c77[15]}},c77[15:0]};
	end
	else if(Ct==1'd1) begin
	op2=DUAL_read_data_2_a;
	op3=DUAL_read_data_2_b;
	op4=DUAL_read_data_3_a;
	op5=DUAL_read_data_3_b;
	end
	
	else begin
	op2=DUAL_read_data_2_a;
	op3=DUAL_read_data_2_b;
	op4=DUAL_read_data_3_a;
	op5=DUAL_read_data_3_b;
	end
	
	end
	
always_comb begin


	if(Ct==1'd0)begin
	op1=DUAL_read_data;
	end
	else if({c_counter[6:4],c_counter[2:0]}==7'd0)begin
	op1={{16{c00[15]}},c00[15:0]};
	end
	else if({c_counter[6:4],c_counter[2:0]}==7'd1)begin
	op1={{16{c10[15]}},c10[15:0]};
	end
	else if({c_counter[6:4],c_counter[2:0]}==7'd2)begin
	op1={{16{c20[15]}},c20[15:0]};
	end
	
	else if({c_counter[6:4],c_counter[2:0]}==7'd3)begin
	op1={{16{c30[15]}},c30[15:0]};
	end
	else if({c_counter[6:4],c_counter[2:0]}==7'd4)begin
	op1={{16{c40[15]}},c40[15:0]};
	end
	
	else if({c_counter[6:4],c_counter[2:0]}==7'd5)begin
	op1={{16{c50[15]}},c50[15:0]};
	end
	
	else if({c_counter[6:4],c_counter[2:0]}==7'd6)begin
	op1={{16{c60[15]}},c60[15:0]};
	end
	
	else if({c_counter[6:4],c_counter[2:0]}==7'd7)begin
	op1={{16{c70[15]}},c70[15:0]};
	end
	
	else if({c_counter[6:4],c_counter[2:0]}==7'd8)begin
	op1={{16{c01[15]}},c01[15:0]};
	end

	else if({c_counter[6:4],c_counter[2:0]}==7'd9)begin
	op1={{16{c11[15]}},c11[15:0]};
	end
	
	else if({c_counter[6:4],c_counter[2:0]}==7'd10)begin
	op1={{16{c21[15]}},c21[15:0]};
	end
	
	else if({c_counter[6:4],c_counter[2:0]}==7'd11)begin
	op1={{16{c31[15]}},c31[15:0]};
	end
	
	else if({c_counter[6:4],c_counter[2:0]}==7'd12)begin
	op1={{16{c41[15]}},c41[15:0]};
	end
	
	else if({c_counter[6:4],c_counter[2:0]}==7'd13)begin
	op1={{16{c51[15]}},c51[15:0]};
	end
	
	else if({c_counter[6:4],c_counter[2:0]}==7'd14)begin
	op1={{16{c61[15]}},c61[15:0]};
	end
	
	else if({c_counter[6:4],c_counter[2:0]}==7'd15)begin
	op1={{16{c71[15]}},c71[15:0]};
	end
	
	///////////////////
	
	else if({c_counter[6:4],c_counter[2:0]}==7'd16)begin
	op1={{16{c02[15]}},c02[15:0]};
	end

	else if({c_counter[6:4],c_counter[2:0]}==7'd17)begin
	op1={{16{c12[15]}},c12[15:0]};
	end
	
	else if({c_counter[6:4],c_counter[2:0]}==7'd18)begin
	op1={{16{c22[15]}},c22[15:0]};
	end
	
	else if({c_counter[6:4],c_counter[2:0]}==7'd19)begin
	op1={{16{c32[15]}},c32[15:0]};
	end
	
	else if({c_counter[6:4],c_counter[2:0]}==7'd20)begin
	op1={{16{c42[15]}},c42[15:0]};
	end
	
	else if({c_counter[6:4],c_counter[2:0]}==7'd21)begin
	op1={{16{c52[15]}},c52[15:0]};
	end
	
	else if({c_counter[6:4],c_counter[2:0]}==7'd22)begin
	op1={{16{c62[15]}},c62[15:0]};
	end
	
	else if({c_counter[6:4],c_counter[2:0]}==7'd23)begin
	op1={{16{c72[15]}},c72[15:0]};
	end
	////
	else if({c_counter[6:4],c_counter[2:0]}==7'd24)begin
	op1={{16{c03[15]}},c03[15:0]};
	end

	else if({c_counter[6:4],c_counter[2:0]}==7'd25)begin
	op1={{16{c13[15]}},c13[15:0]};
	end
	
	else if({c_counter[6:4],c_counter[2:0]}==7'd26)begin
	op1={{16{c23[15]}},c23[15:0]};
	end
	
	else if({c_counter[6:4],c_counter[2:0]}==7'd27)begin
	op1={{16{c33[15]}},c33[15:0]};
	end
	
	else if({c_counter[6:4],c_counter[2:0]}==7'd28)begin
	op1={{16{c43[15]}},c43[15:0]};
	end
	
	else if({c_counter[6:4],c_counter[2:0]}==7'd29)begin
	op1={{16{c53[15]}},c53[15:0]};
	end
	
	else if({c_counter[6:4],c_counter[2:0]}==7'd30)begin
	op1={{16{c63[15]}},c63[15:0]};
	end
	
	else if({c_counter[6:4],c_counter[2:0]}==7'd31)begin
	op1={{16{c73[15]}},c73[15:0]};
	end
	/////
	else if({c_counter[6:4],c_counter[2:0]}==7'd32)begin
	op1={{16{c04[15]}},c04[15:0]};
	end

	else if({c_counter[6:4],c_counter[2:0]}==7'd33)begin
	op1={{16{c14[15]}},c14[15:0]};
	end
	
	else if({c_counter[6:4],c_counter[2:0]}==7'd34)begin
	op1={{16{c24[15]}},c24[15:0]};
	end
	
	else if({c_counter[6:4],c_counter[2:0]}==7'd35)begin
	op1={{16{c34[15]}},c34[15:0]};
	end
	
	else if({c_counter[6:4],c_counter[2:0]}==7'd36)begin
	op1={{16{c44[15]}},c44[15:0]};
	end
	
	else if({c_counter[6:4],c_counter[2:0]}==7'd37)begin
	op1={{16{c54[15]}},c54[15:0]};
	end
	
	else if({c_counter[6:4],c_counter[2:0]}==7'd38)begin
	op1={{16{c64[15]}},c64[15:0]};
	end
	
	else if({c_counter[6:4],c_counter[2:0]}==7'd39)begin
	op1={{16{c74[15]}},c74[15:0]};
	end
	//
	else if({c_counter[6:4],c_counter[2:0]}==7'd40)begin
	op1={{16{c05[15]}},c05[15:0]};
	end

	else if({c_counter[6:4],c_counter[2:0]}==7'd41)begin
	op1={{16{c15[15]}},c15[15:0]};
	end
	
	else if({c_counter[6:4],c_counter[2:0]}==7'd42)begin
	op1={{16{c25[15]}},c25[15:0]};
	end
	
	else if({c_counter[6:4],c_counter[2:0]}==7'd43)begin
	op1={{16{c35[15]}},c35[15:0]};
	end
	
	else if({c_counter[6:4],c_counter[2:0]}==7'd44)begin
	op1={{16{c45[15]}},c45[15:0]};
	end
	
	else if({c_counter[6:4],c_counter[2:0]}==7'd45)begin
	op1={{16{c55[15]}},c55[15:0]};
	end
	
	else if({c_counter[6:4],c_counter[2:0]}==7'd46)begin
	op1={{16{c65[15]}},c65[15:0]};
	end
	
	else if({c_counter[6:4],c_counter[2:0]}==7'd47)begin
	op1={{16{c75[15]}},c75[15:0]};
	end
	
	//
	else if({c_counter[6:4],c_counter[2:0]}==7'd48)begin
	op1={{16{c06[15]}},c06[15:0]};
	end

	else if({c_counter[6:4],c_counter[2:0]}==7'd49)begin
	op1={{16{c16[15]}},c16[15:0]};
	end
	
	else if({c_counter[6:4],c_counter[2:0]}==7'd50)begin
	op1={{16{c26[15]}},c26[15:0]};
	end
	
	else if({c_counter[6:4],c_counter[2:0]}==7'd51)begin
	op1={{16{c36[15]}},c36[15:0]};
	end
	
	else if({c_counter[6:4],c_counter[2:0]}==7'd52)begin
	op1={{16{c46[15]}},c46[15:0]};
	end
	
	else if({c_counter[6:4],c_counter[2:0]}==7'd53)begin
	op1={{16{c56[15]}},c56[15:0]};
	end
	
	else if({c_counter[6:4],c_counter[2:0]}==7'd54)begin
	op1={{16{c66[15]}},c66[15:0]};
	end
	
	else if({c_counter[6:4],c_counter[2:0]}==7'd55)begin
	op1={{16{c76[15]}},c76[15:0]};
	end
	//
	else if({c_counter[6:4],c_counter[2:0]}==7'd56)begin
	op1={{16{c07[15]}},c07[15:0]};
	end

	else if({c_counter[6:4],c_counter[2:0]}==7'd57)begin
	op1={{16{c17[15]}},c17[15:0]};
	end
	
	else if({c_counter[6:4],c_counter[2:0]}==7'd58)begin
	op1={{16{c27[15]}},c27[15:0]};
	end
	
	else if({c_counter[6:4],c_counter[2:0]}==7'd59)begin
	op1={{16{c37[15]}},c37[15:0]};
	end
	
	else if({c_counter[6:4],c_counter[2:0]}==7'd60)begin
	op1={{16{c47[15]}},c47[15:0]};
	end
	
	else if({c_counter[6:4],c_counter[2:0]}==7'd61)begin
	op1={{16{c57[15]}},c57[15:0]};
	end
	
	else if({c_counter[6:4],c_counter[2:0]}==7'd62)begin
	op1={{16{c67[15]}},c67[15:0]};
	end
	
	else if({c_counter[6:4],c_counter[2:0]}==7'd63)begin
	op1={{16{c77[15]}},c77[15:0]};
	end
	else
	op1=DUAL_read_data;
	end
	
	
	
	
	


assign multiplier_1=op1*op2;
assign multiplier_2=op1*op3;
assign multiplier_3=op1*op4;
assign multiplier_4=op1*op5;


//put into if statement,





always_ff @ (posedge Clock or negedge Resetn) begin
	if (~Resetn) begin
	counter<=8'd0;
	loop<=8'd0;
	acc1<=10'd0;
	acc2<=10'd0;
	acc3<=10'd0;
	acc4<=10'd0;
	SRAM_we_n <= 1'b1;//initially no writing
	SRAM_write_data <= 16'd0;
	SRAM_address <= 18'd0;
	State<=Idle;
	Ct<=1'd0;
	c_counter<=7'd0;
	coeff_counter<=4'd0;
	YUV_offset<=18'd76800;
	cb<=8'd0;
	rb<=8'd0;
	ra<=15'd0;
	ca<=15'd0;
	rb<=8'd0;
	cb<=8'd0;
	DUAL_address<=8'd0;
	DUAL_offset<=8'd0;//offset 
	DUAL_write<=32'd0;
	DUAL_write_en<=1'd0;
	
	DUAL_address_b<=8'd0;
	DUAL_offset_b<=8'd64;//offset 
	DUAL_write_b<=32'd0;
	DUAL_write_en_b<=1'd0;
	
	
	DUAL_address_2_a<=8'd0;
	DUAL_offset_2_a<=8'd0;//offset 
	DUAL_write_2_a<=32'd0;
	DUAL_write_en_2_a<=1'd0;
	
	DUAL_address_2_b<=8'd0;
	DUAL_offset_2_b<=8'd1;//offset 
	DUAL_write_2_b<=32'd0;
	DUAL_write_en_2_b<=1'd0;
	
	DUAL_address_3_a<=8'd0;
	DUAL_offset_3_a<=8'd0;//offset 
	DUAL_write_3_a<=32'd0;
	DUAL_write_en_3_a<=1'd0;
	
	DUAL_address_3_b<=8'd0;
	DUAL_offset_3_b<=8'd1;//offset 
	DUAL_write_3_b<=32'd0;
	DUAL_write_en_3_b<=1'd0;
	
	invert<=1'd0;
	state_count<=1'd0;
	
	temp<=16'd0;
	
	end else begin
	case (State)
	
			Idle: begin
			if(start==1'd1)begin
			counter<=6'd0;
			State<=State_1;
			end 
			end
					
	
			State_1:begin
			counter<=counter+1'd1;
			ra<={rb,3'd0}+counter[5:3];
			ca<={cb,3'd0}+counter[2:0];//computing Ca 
			State<=State_2;
			end
			
			State_2:begin
			counter<=counter+1'd1;
			ra<={rb,3'd0}+counter[5:3];
			ca<={cb,3'd0}+counter[2:0];
			SRAM_address<=18'd76800+{ra,8'd0}+{ra,6'd0}+ca;//the address fed to the sram address regisete,(320*ra+ca)
			State<=State_3;
			end
			
			State_3:begin//previous address updates
			counter<=counter+1'd1;
			ra<={rb,3'd0}+counter[5:3];
			ca<={cb,3'd0}+counter[2:0];
			SRAM_address<=18'd76800+{ra,8'd0}+{ra,6'd0}+ca;
			State<=State_4;
			end
			
			State_4:begin
			counter<=counter+1'd1;
			ra<={rb,3'd0}+counter[5:3];
			ca<={cb,3'd0}+counter[2:0];
			SRAM_address<=18'd76800+{ra,8'd0}+{ra,6'd0}+ca;
			State<=State_5;
			end
			
			State_5:begin//get read data from the sram address passed and then use that to write to dual port with according address
			counter<=counter+1'd1;
			ra<={rb,3'd0}+counter[5:3];//8*rb+ri
			ca<={cb,3'd0}+counter[2:0];
			SRAM_address<=18'd76800+{ra,8'd0}+{ra,6'd0}+ca;//addy=320*ra+ca
			DUAL_address<=DUAL_offset;//get read data on this cycle as first intiated in state 2
			DUAL_offset<=DUAL_offset+1'd1;//increase for the next write address
			DUAL_write<={{16{SRAM_read_data[15]}},SRAM_read_data};//signed
			
			DUAL_write_en<=1'd1;//turn writing on to dua port ram 1a
			if(counter>8'd63)begin
			State<=State_6;

			end
			end
			
			State_6:begin//u10
			
			DUAL_address<=DUAL_offset;//finishwrite
			DUAL_offset<=DUAL_offset+1'd1;
			DUAL_write<={{16{SRAM_read_data[15]}},SRAM_read_data};
			DUAL_write_en<=1'd1;
			State<=State_7;
			end
			
			
			State_7:begin
			
			DUAL_address<=DUAL_offset;
			DUAL_offset<=DUAL_offset+1'd1;
			DUAL_write<={{16{SRAM_read_data[15]}},SRAM_read_data};
			DUAL_write_en<=1'd1;
			State<=State_8;
			end
			
			State_8:begin
			DUAL_address<=DUAL_offset;
			DUAL_offset<=DUAL_offset+1'd1;
			DUAL_write<={{16{SRAM_read_data[15]}},SRAM_read_data};
			DUAL_write_en<=1'd1;
			
			State<=Buffer;
			end
		
		
		
		
		
		
		
	
		
		
	
			
			Buffer:begin//for updating last write, reset offset to 0, and turn off writnig to top port
			State<=State_10;
			DUAL_address<=7'd0;
			DUAL_offset<=7'd1;
			DUAL_write_en<=1'd0;//no more writes to dual port 1
			loop<=8'd0;
			Ct<=1'd0;//have to make op2-5 = coefficient
			
			
			if(state_count>1'd0)begin//only on second iteration, do write

			DUAL_write_en_b<=1'd0;//turn off,only reading
			DUAL_address_b<=8'd64;//Write from dual address 64 to sram
			DUAL_offset_b<=8'd65;
			counter<=8'd0;
			end
			
			coeff_counter<=4'd0;//reset 
			
			DUAL_address_2_a<=8'd0;//reset so writing always starts at 0 and 1
			DUAL_offset_2_a<=8'd0;
			DUAL_address_2_b<=8'd0;
			DUAL_offset_2_b<=8'd1;
			
			DUAL_address_2_a<=8'd0;
			DUAL_offset_2_a<=8'd0;
			DUAL_address_2_b<=8'd0;
			DUAL_offset_2_b<=8'd1;
			
			DUAL_address_3_a<=8'd0;
			DUAL_offset_3_a<=8'd0;
			DUAL_address_3_b<=8'd0;
			DUAL_offset_3_b<=8'd1;
			
			DUAL_address_3_a<=8'd0;
			DUAL_offset_3_a<=8'd0;
			DUAL_address_3_b<=8'd0;
			DUAL_offset_3_b<=8'd1;
			end
			
			
					
			State_10:begin
			DUAL_address<={DUAL_offset[6:4],DUAL_offset[2:0]};//0-7,0-7
			DUAL_offset<=DUAL_offset+1'd1;
			State<=State_11;
			end
			
			
			State_11:begin
			DUAL_address<={DUAL_offset[6:4],DUAL_offset[2:0]};
			DUAL_offset<=DUAL_offset+1'd1;
			
			if(state_count>1'd0)begin
			DUAL_address_b<=DUAL_offset_b;
			DUAL_offset_b<=DUAL_offset_b+1'd1;
			ra<={rb2,3'd0}+counter[4:2];
			ca<={cb2,2'd0}+counter[1:0];
			counter<=counter+1'd1;
			end
				
			acc1<=multiplier_1;
			acc2<=multiplier_2;
			acc3<=multiplier_3;
			acc4<=multiplier_4;
			coeff_counter<=coeff_counter+1'd1;
			State<=State_12;
			end
			
			
			
			State_12:begin
			if(state_count>1'd0 &&counter<8'd33)begin
			DUAL_address_b<=DUAL_offset_b;
			DUAL_offset_b<=DUAL_offset_b+1'd1;
			ra<={rb2,3'd0}+counter[4:2];
			ca<={cb2,2'd0}+counter[1:0];
			SRAM_we_n<=1'd0;
			SRAM_address<={ra,7'd0}+{ra,5'd0}+ca;
			SRAM_write_data<=DUAL_read_data_b;
			counter<=counter+1'd1;
			end
			else begin
			SRAM_we_n<=1'd1;
			end
			
			DUAL_address<={DUAL_offset[6:4],DUAL_offset[2:0]};
			DUAL_offset<=DUAL_offset+1'd1;
			
			State<=State_13;
			acc1<=acc1+multiplier_1;
			acc2<=acc2+multiplier_2;
			acc3<=acc3+multiplier_3;
			acc4<=acc4+multiplier_4;
			
			DUAL_write_en_2_a<=1'd0;
			DUAL_write_en_2_b<=1'd0;
			DUAL_write_en_3_a<=1'd0;
			DUAL_write_en_3_b<=1'd0;
			coeff_counter<=coeff_counter+1'd1;
			end
			
			
			State_13:begin
			if(state_count>1'd0 &&counter<8'd33)begin
			DUAL_address_b<=DUAL_offset_b;
			DUAL_offset_b<=DUAL_offset_b+1'd1;
			ra<={rb2,3'd0}+counter[4:2];
			ca<={cb2,2'd0}+counter[1:0];
			SRAM_address<={ra,7'd0}+{ra,5'd0}+ca;
			SRAM_write_data<=DUAL_read_data_b;
			counter<=counter+1'd1;
			end
			else begin
			SRAM_we_n<=1'd1;
			end
			
			DUAL_address<={DUAL_offset[6:4],DUAL_offset[2:0]};
			DUAL_offset<=DUAL_offset+1'd1;
			State<=State_14;
			acc1<=acc1+multiplier_1;
			acc2<=acc2+multiplier_2;
			acc3<=acc3+multiplier_3;
			acc4<=acc4+multiplier_4;
			
			coeff_counter<=coeff_counter+1'd1;
			end
		
			
			
			State_14:begin
			if(state_count>1'd0 &&counter<8'd33)begin
			DUAL_address_b<=DUAL_offset_b;
			DUAL_offset_b<=DUAL_offset_b+1'd1;
			ra<={rb2,3'd0}+counter[4:2];
			ca<={cb2,2'd0}+counter[1:0];
			SRAM_address<={ra,7'd0}+{ra,5'd0}+ca;
			SRAM_write_data<=DUAL_read_data_b;
			counter<=counter+1'd1;
			end
			else begin
			SRAM_we_n<=1'd1;
			end
			
			DUAL_address<={DUAL_offset[6:4],DUAL_offset[2:0]};
			DUAL_offset<=DUAL_offset+1'd1;
			State<=State_15;
			acc1<=acc1+multiplier_1;
			acc2<=acc2+multiplier_2;
			acc3<=acc3+multiplier_3;
			acc4<=acc4+multiplier_4;
			
			coeff_counter<=coeff_counter+1'd1;
			end
		
			
			
			
			State_15:begin
			if(state_count>1'd0 &&counter<8'd33)begin
			DUAL_address_b<=DUAL_offset_b;
			DUAL_offset_b<=DUAL_offset_b+1'd1;
			ra<={rb2,3'd0}+counter[4:2];
			ca<={cb2,2'd0}+counter[1:0];
			SRAM_address<={ra,7'd0}+{ra,5'd0}+ca;
			SRAM_write_data<=DUAL_read_data_b;
			counter<=counter+1'd1;
			end
			else begin
			SRAM_we_n<=1'd1;
			end
			
			DUAL_address<={DUAL_offset[6:4],DUAL_offset[2:0]};
			DUAL_offset<=DUAL_offset+1'd1;
			State<=State_16;
			acc1<=acc1+multiplier_1;
			acc2<=acc2+multiplier_2;
			acc3<=acc3+multiplier_3;
			acc4<=acc4+multiplier_4;
			
			coeff_counter<=coeff_counter+1'd1;

			end
			
			State_16:begin//The last address updatd for the current row, first iteration
			if(state_count>1'd0 &&counter<8'd33)begin
			DUAL_address_b<=DUAL_offset_b;
			DUAL_offset_b<=DUAL_offset_b+1'd1;
			ra<={rb2,3'd0}+counter[4:2];
			ca<={cb2,2'd0}+counter[1:0];
			SRAM_address<={ra,7'd0}+{ra,5'd0}+ca;
			SRAM_write_data<=DUAL_read_data_b;
			counter<=counter+1'd1;
			end
			else begin
			SRAM_we_n<=1'd1;
			end
			
			DUAL_address<={DUAL_offset[6:4],DUAL_offset[2:0]};
			DUAL_offset<=DUAL_offset+1'd1;//set back to initial
			State<=State_17;
			acc1<=acc1+multiplier_1;
			acc2<=acc2+multiplier_2;
			acc3<=acc3+multiplier_3;
			acc4<=acc4+multiplier_4;
			
			coeff_counter<=coeff_counter+1'd1;
			end
			
			State_17:begin
			if(state_count>1'd0 &&counter<8'd33)begin
			DUAL_address_b<=DUAL_offset_b;
			DUAL_offset_b<=DUAL_offset_b+1'd1;
			ra<={rb2,3'd0}+counter[4:2];
			ca<={cb2,2'd0}+counter[1:0];
			SRAM_address<={ra,7'd0}+{ra,5'd0}+ca;
			SRAM_write_data<=DUAL_read_data_b;
			counter<=counter+1'd1;
			end
			
			else begin
			SRAM_we_n<=1'd1;
			end
			DUAL_address<={DUAL_offset[6:4],DUAL_offset[2:0]};//will go back to inital offset
			DUAL_offset<=DUAL_offset+1'd1;
			State<=State_18;
			coeff_counter<=coeff_counter+1'd1;

			acc1<=acc1+multiplier_1;
			acc2<=acc2+multiplier_2;
			acc3<=acc3+multiplier_3;
			acc4<=acc4+multiplier_4;
			
			end
			
			State_18:begin
			if(state_count>1'd0&&counter<8'd33)begin
			DUAL_address_b<=DUAL_offset_b;
			DUAL_offset_b<=DUAL_offset_b+1'd1;
			ra<={rb2,3'd0}+counter[4:2];
			ca<={cb2,2'd0}+counter[1:0];
			SRAM_address<={ra,7'd0}+{ra,5'd0}+ca;
			SRAM_write_data<=DUAL_read_data_b;
			counter<=counter+1'd1;
			end
			
			else begin
			SRAM_we_n<=1'd1;
			end
			DUAL_address<={DUAL_offset[6:4],DUAL_offset[2:0]};
			DUAL_offset<=DUAL_offset+1'd1;
			State<=State_19;
			acc1<=acc1+multiplier_1;
			acc2<=acc2+multiplier_2;
			acc3<=acc3+multiplier_3;
			acc4<=acc4+multiplier_4;
			coeff_counter<=coeff_counter+1'd1;
			end
			
			
			State_19:begin
			if(state_count>1'd0 &&counter<8'd33)begin//only write on second iteration (state_count==1), counter<33 because writing 2 values per location (64/2)
			DUAL_address_b<=DUAL_offset_b;
			DUAL_offset_b<=DUAL_offset_b+1'd1;
			ra<={rb2,3'd0}+counter[4:2];
			ca<={cb2,2'd0}+counter[1:0];
			SRAM_address<={ra,7'd0}+{ra,5'd0}+ca;
			SRAM_write_data<=DUAL_read_data_b;
			counter<=counter+1'd1;
			end
			
			else begin
			SRAM_we_n<=1'd1;
			end
			DUAL_address<={DUAL_offset[6:4],DUAL_offset[2:0]};//now compute the acc 5,6,7,8
			DUAL_offset<=DUAL_offset+1'd1;
			coeff_counter<=coeff_counter+1'd1;

			DUAL_address_2_a<=DUAL_offset_2_a;
			DUAL_offset_2_a<=DUAL_offset_2_a+2'd2;
			DUAL_write_2_a<={{8{acc1[31]}},acc1[31:8]};
			DUAL_write_en_2_a<=1'd1;
			
			DUAL_address_2_b<=DUAL_offset_2_b;
			DUAL_offset_2_b<=DUAL_offset_2_b+2'd2;
			DUAL_write_2_b<={{8{acc2[31]}},acc2[31:8]};
			DUAL_write_en_2_b<=1'd1;

			DUAL_address_3_a<=DUAL_offset_3_a;
			DUAL_offset_3_a<=DUAL_offset_3_a+2'd2;
			DUAL_write_3_a<={{8{acc3[31]}},acc3[31:8]};
			DUAL_write_en_3_a<=1'd1;
			
			DUAL_address_3_b<=DUAL_offset_3_b;
			DUAL_offset_3_b<=DUAL_offset_3_b+2'd2;
			DUAL_write_3_b<={{8{acc4[31]}},acc4[31:8]};
			DUAL_write_en_3_b<=1'd1;
			
			loop<=loop+1'd1;//loop for iterations of Ct
			State<=Buffer_2;
			
			if(loop<8'd15)begin
			
			acc1<=multiplier_1;
			acc2<=multiplier_2;
			acc3<=multiplier_3;
			acc4<=multiplier_4;
			State<=State_12;
			end
			
			end
			
			
			//Start of acc 5-8
			
			
		
			
			
			
			
			
		
			
			Buffer_2:begin
			DUAL_offset_2_a<=3'd4;
			DUAL_offset_2_b<=3'd5;
			DUAL_offset_3_a<=3'd4;
			DUAL_offset_3_b<=3'd5;
			SRAM_we_n<=1'd1;
			DUAL_address_2_a<=1'd0;
			DUAL_address_2_b<=1'd1;
			DUAL_address_3_a<=1'd0;
			DUAL_address_3_b<=1'd1;
			
			c_counter<=7'd0;//change coefficient(0-63) twice
			counter<=7'd0;//looping Fs
			loop<=8'd0;//for looping Ct		
			state_count<=1'd1;//1
			acc1<=32'd0;
			acc2<=32'd0;
			acc3<=32'd0;
			acc4<=32'd0;	
			
			DUAL_write_en_2_a<=1'd0;//no writin
			DUAL_write_en_2_b<=1'd0; 
			DUAL_write_en_3_a<=1'd0;
			DUAL_write_en_3_b<=1'd0;	
			
			DUAL_address_b<=8'd0;//start at address 64(writing),bottom half
			DUAL_offset_b<=8'd64;
			
			DUAL_address<=7'd0;//write to top half of memory
			DUAL_offset<=7'd0;
			
			State<=Lead_in1;
		//increase block every 40 state counts
			cb<=cb+1'd1;//increase block
			rb2<=rb;//for writing the previous block
			cb2<=cb;
			Ct<=1'd1;//if states are at Ct or Cs
			
			if(cb>8'd38)begin
			rb<=rb+1'd1;
			cb<=8'd0;
			end
			
			if(rb>8'd28)begin
			State<=State_51;
			
			end
			end
		
		
		
		
	
		
		
			Lead_in1:begin
			counter<=counter+1'd1;
			ra<={rb,3'd0}+counter[5:3];
			ca<={cb,3'd0}+counter[2:0];//computing Ca 
			State<=Lead_in2;
			end
			
			Lead_in2:begin
			counter<=counter+1'd1;
			ra<={rb,3'd0}+counter[5:3];
			ca<={cb,3'd0}+counter[2:0];
			SRAM_address<=18'd76800+{ra,8'd0}+{ra,6'd0}+ca;//the address fed to the sram address regisete,(320*ra+ca)
			State<=Lead_in3;
			end
			
			Lead_in3:begin
			counter<=counter+1'd1;
			ra<={rb,3'd0}+counter[5:3];
			ca<={cb,3'd0}+counter[2:0];
			SRAM_address<=18'd76800+{ra,8'd0}+{ra,6'd0}+ca;
			State<=Lead_in4;
			end
			
			Lead_in4:begin
			counter<=counter+1'd1;
			ra<={rb,3'd0}+counter[5:3];
			ca<={cb,3'd0}+counter[2:0];
			SRAM_address<=18'd76800+{ra,8'd0}+{ra,6'd0}+ca;
			State<=State_30;
			end

			
			
			State_30:begin
			DUAL_address_2_a<=DUAL_offset_2_a;
			DUAL_address_2_b<=DUAL_offset_2_b;
			DUAL_address_3_a<=DUAL_offset_3_a;
			DUAL_address_3_b<=DUAL_offset_3_b;
			
			DUAL_offset_2_a<=DUAL_offset_2_a+3'd4;
			DUAL_offset_2_b<=DUAL_offset_2_b+3'd4;
			DUAL_offset_3_a<=DUAL_offset_3_a+3'd4;
			DUAL_offset_3_b<=DUAL_offset_3_b+3'd4;
			
			if(counter<8'd65)begin
			counter<=counter+1'd1;
			DUAL_write_en<=1'd1;
			ra<={rb,3'd0}+counter[5:3];
			ca<={cb,3'd0}+counter[2:0];
			SRAM_address<=18'd76800+{ra,8'd0}+{ra,6'd0}+ca;
			DUAL_address<=DUAL_offset;//get read data on this cycle as first intiated in state 2
			DUAL_offset<=DUAL_offset+1'd1;//increase for the next write address
			DUAL_write<={{16{SRAM_read_data[15]}},SRAM_read_data};
			end
			State<=State_31;
			end
			
			State_31:begin
			DUAL_address_2_a<=DUAL_offset_2_a;
			DUAL_address_2_b<=DUAL_offset_2_b;
			DUAL_address_3_a<=DUAL_offset_3_a;
			DUAL_address_3_b<=DUAL_offset_3_b;
			
			DUAL_offset_2_a<=DUAL_offset_2_a+3'd4;
			DUAL_offset_2_b<=DUAL_offset_2_b+3'd4;
			DUAL_offset_3_a<=DUAL_offset_3_a+3'd4;
			DUAL_offset_3_b<=DUAL_offset_3_b+3'd4;
			c_counter<=c_counter+1'd1;
			acc1<=multiplier_1;
			acc2<=multiplier_2;
			acc3<=multiplier_3;
			acc4<=multiplier_4;
			
			if(counter<8'd65)begin
			counter<=counter+1'd1;
			ra<={rb,3'd0}+counter[5:3];
			ca<={cb,3'd0}+counter[2:0];
			SRAM_address<=18'd76800+{ra,8'd0}+{ra,6'd0}+ca;
			DUAL_address<=DUAL_offset;//get read data on this cycle as first intiated in state 2
			DUAL_offset<=DUAL_offset+1'd1;//increase for the next write address
			DUAL_write<={{16{SRAM_read_data[15]}},SRAM_read_data};
			end
			
			State<=State_32;
			end
			
			
			State_32:begin
			DUAL_address_2_a<=DUAL_offset_2_a;
			DUAL_address_2_b<=DUAL_offset_2_b;
			DUAL_address_3_a<=DUAL_offset_3_a;
			DUAL_address_3_b<=DUAL_offset_3_b;
			
			DUAL_offset_2_a<=DUAL_offset_2_a+3'd4;
			DUAL_offset_2_b<=DUAL_offset_2_b+3'd4;
			DUAL_offset_3_a<=DUAL_offset_3_a+3'd4;
			DUAL_offset_3_b<=DUAL_offset_3_b+3'd4;
			c_counter<=c_counter+1'd1;
			acc1<=multiplier_1+acc1;
			acc2<=multiplier_2+acc2;
			acc3<=multiplier_3+acc3;
			acc4<=multiplier_4+acc4;
			State<=State_33;
			
			if(loop>1'd0)begin//write acc 5,6 7, 8 after first iteration
			DUAL_address_b<=DUAL_offset_b;//d64 and continue
			DUAL_write_b<=temp;
			DUAL_write_en_b<=1'd1;
			DUAL_offset_b<=DUAL_offset_b+1'd1;
			end
			
			if(counter<8'd65)begin
			counter<=counter+1'd1;
			ra<={rb,3'd0}+counter[5:3];
			ca<={cb,3'd0}+counter[2:0];
			SRAM_address<=18'd76800+{ra,8'd0}+{ra,6'd0}+ca;
			DUAL_address<=DUAL_offset;//get read data on this cycle as first intiated in state 2
			DUAL_offset<=DUAL_offset+1'd1;//increase for the next write address
			DUAL_write<={{16{SRAM_read_data[15]}},SRAM_read_data};
			end
			
			end
			
					
			State_33:begin
			DUAL_address_2_a<=DUAL_offset_2_a;
			DUAL_address_2_b<=DUAL_offset_2_b;
			DUAL_address_3_a<=DUAL_offset_3_a;
			DUAL_address_3_b<=DUAL_offset_3_b;
			
			DUAL_offset_2_a<=DUAL_offset_2_a+3'd4;
			DUAL_offset_2_b<=DUAL_offset_2_b+3'd4;
			DUAL_offset_3_a<=DUAL_offset_3_a+3'd4;
			DUAL_offset_3_b<=DUAL_offset_3_b+3'd4;
			c_counter<=c_counter+1'd1;
			acc1<=multiplier_1+acc1;
			acc2<=multiplier_2+acc2;
			acc3<=multiplier_3+acc3;
			acc4<=multiplier_4+acc4;
			DUAL_write_en_b<=1'd0;
				if(counter<8'd65)begin
			counter<=counter+1'd1;
			ra<={rb,3'd0}+counter[5:3];
			ca<={cb,3'd0}+counter[2:0];
			SRAM_address<=18'd76800+{ra,8'd0}+{ra,6'd0}+ca;
			DUAL_address<=DUAL_offset;//get read data on this cycle as first intiated in state 2
			DUAL_offset<=DUAL_offset+1'd1;//increase for the next write address
			DUAL_write<={{16{SRAM_read_data[15]}},SRAM_read_data};
			end
			
			State<=State_34;
			end
			
					
			State_34:begin
			DUAL_address_2_a<=DUAL_offset_2_a;
			DUAL_address_2_b<=DUAL_offset_2_b;
			DUAL_address_3_a<=DUAL_offset_3_a;
			DUAL_address_3_b<=DUAL_offset_3_b;
			
			DUAL_offset_2_a<=DUAL_offset_2_a+3'd4;
			DUAL_offset_2_b<=DUAL_offset_2_b+3'd4;
			DUAL_offset_3_a<=DUAL_offset_3_a+3'd4;
			DUAL_offset_3_b<=DUAL_offset_3_b+3'd4;
			c_counter<=c_counter+1'd1;
			acc1<=multiplier_1+acc1;
			acc2<=multiplier_2+acc2;
			acc3<=multiplier_3+acc3;
			acc4<=multiplier_4+acc4;
				if(counter<8'd65)begin
			counter<=counter+1'd1;
			ra<={rb,3'd0}+counter[5:3];
			ca<={cb,3'd0}+counter[2:0];
			SRAM_address<=18'd76800+{ra,8'd0}+{ra,6'd0}+ca;
			DUAL_address<=DUAL_offset;//get read data on this cycle as first intiated in state 2
			DUAL_offset<=DUAL_offset+1'd1;//increase for the next write address
			DUAL_write<={{16{SRAM_read_data[15]}},SRAM_read_data};
			end
			
			State<=State_35;
			end
			
					
			State_35:begin
			DUAL_address_2_a<=DUAL_offset_2_a;
			DUAL_address_2_b<=DUAL_offset_2_b;
			DUAL_address_3_a<=DUAL_offset_3_a;
			DUAL_address_3_b<=DUAL_offset_3_b;
			
			DUAL_offset_2_a<=DUAL_offset_2_a+3'd4;
			DUAL_offset_2_b<=DUAL_offset_2_b+3'd4;
			DUAL_offset_3_a<=DUAL_offset_3_a+3'd4;
			DUAL_offset_3_b<=DUAL_offset_3_b+3'd4;
			c_counter<=c_counter+1'd1;
			acc1<=multiplier_1+acc1;
			acc2<=multiplier_2+acc2;
			acc3<=multiplier_3+acc3;
			acc4<=multiplier_4+acc4;
			DUAL_write_en_b<=1'd0;
				if(counter<8'd65)begin
			counter<=counter+1'd1;
			ra<={rb,3'd0}+counter[5:3];
			ca<={cb,3'd0}+counter[2:0];
			SRAM_address<=18'd76800+{ra,8'd0}+{ra,6'd0}+ca;
			DUAL_address<=DUAL_offset;//get read data on this cycle as first intiated in state 2
			DUAL_offset<=DUAL_offset+1'd1;//increase for the next write address
			DUAL_write<={{16{SRAM_read_data[15]}},SRAM_read_data};
			end
			
			State<=State_36;
			end
			
			State_36:begin
			DUAL_address_2_a<=DUAL_offset_2_a;
			DUAL_address_2_b<=DUAL_offset_2_b;
			DUAL_address_3_a<=DUAL_offset_3_a;
			DUAL_address_3_b<=DUAL_offset_3_b;
			
			if(invert==1'd0)begin//first iteration, go to odd values
			DUAL_offset_2_a<=8'd2;
			DUAL_offset_2_b<=8'd3;
			DUAL_offset_3_a<=8'd2;
			DUAL_offset_3_b<=8'd3;
			end
			if(invert==1'd1)begin
			DUAL_offset_2_a<=8'd0;
			DUAL_offset_2_b<=8'd1;
			DUAL_offset_3_a<=8'd0;
			DUAL_offset_3_b<=8'd1;
			end
			invert<=~invert;
			c_counter<=c_counter+1'd1;
			acc1<=multiplier_1+acc1;
			acc2<=multiplier_2+acc2;
			acc3<=multiplier_3+acc3;
			acc4<=multiplier_4+acc4;
				if(counter<8'd65)begin
			counter<=counter+1'd1;
			ra<={rb,3'd0}+counter[5:3];
			ca<={cb,3'd0}+counter[2:0];
			SRAM_address<=18'd76800+{ra,8'd0}+{ra,6'd0}+ca;
			DUAL_address<=DUAL_offset;//get read data on this cycle as first intiated in state 2
			DUAL_offset<=DUAL_offset+1'd1;//increase for the next write address
			DUAL_write<={{16{SRAM_read_data[15]}},SRAM_read_data};
			end
			
			
			
			State<=State_37;
			end
			
			State_37:begin
			DUAL_address_2_a<=DUAL_offset_2_a;
			DUAL_address_2_b<=DUAL_offset_2_b;
			DUAL_address_3_a<=DUAL_offset_3_a;
			DUAL_address_3_b<=DUAL_offset_3_b;
			
			DUAL_offset_2_a<=DUAL_offset_2_a+3'd4;
			DUAL_offset_2_b<=DUAL_offset_2_b+3'd4;
			DUAL_offset_3_a<=DUAL_offset_3_a+3'd4;
			DUAL_offset_3_b<=DUAL_offset_3_b+3'd4;
			c_counter<=c_counter+1'd1;
			acc1<=multiplier_1+acc1;
			acc2<=multiplier_2+acc2;
			acc3<=multiplier_3+acc3;
			acc4<=multiplier_4+acc4;
				if(counter<8'd65)begin
			counter<=counter+1'd1;
			ra<={rb,3'd0}+counter[5:3];
			ca<={cb,3'd0}+counter[2:0];
			SRAM_address<=18'd76800+{ra,8'd0}+{ra,6'd0}+ca;
			DUAL_address<=DUAL_offset;//get read data on this cycle as first intiated in state 2
			DUAL_offset<=DUAL_offset+1'd1;//increase for the next write address
			DUAL_write<={{16{SRAM_read_data[15]}},SRAM_read_data};
			end
			
			State<=State_38;
			end
			
			State_38:begin
			DUAL_address_2_a<=DUAL_offset_2_a;
			DUAL_address_2_b<=DUAL_offset_2_b;
			DUAL_address_3_a<=DUAL_offset_3_a;
			DUAL_address_3_b<=DUAL_offset_3_b;
			
			DUAL_offset_2_a<=DUAL_offset_2_a+3'd4;
			DUAL_offset_2_b<=DUAL_offset_2_b+3'd4;
			DUAL_offset_3_a<=DUAL_offset_3_a+3'd4;
			DUAL_offset_3_b<=DUAL_offset_3_b+3'd4;
			c_counter<=c_counter+1'd1;
			acc1<=multiplier_1+acc1;
			acc2<=multiplier_2+acc2;
			acc3<=multiplier_3+acc3;
			acc4<=multiplier_4+acc4;
			
			if(counter<8'd65)begin
			counter<=counter+1'd1;
			ra<={rb,3'd0}+counter[5:3];
			ca<={cb,3'd0}+counter[2:0];
			SRAM_address<=18'd76800+{ra,8'd0}+{ra,6'd0}+ca;
			DUAL_address<=DUAL_offset;//get read data on this cycle as first intiated in state 2
			DUAL_offset<=DUAL_offset+1'd1;//increase for the next write address
			DUAL_write<={{16{SRAM_read_data[15]}},SRAM_read_data};
			end
			
			State<=State_39;
			end
			
			State_39:begin
			DUAL_address_2_a<=DUAL_offset_2_a;
			DUAL_address_2_b<=DUAL_offset_2_b;
			DUAL_address_3_a<=DUAL_offset_3_a;
			DUAL_address_3_b<=DUAL_offset_3_b;
			
			DUAL_offset_2_a<=DUAL_offset_2_a+3'd4;
			DUAL_offset_2_b<=DUAL_offset_2_b+3'd4;
			DUAL_offset_3_a<=DUAL_offset_3_a+3'd4;
			DUAL_offset_3_b<=DUAL_offset_3_b+3'd4;
			c_counter<=c_counter+1'd1;
				
			DUAL_address_b<=DUAL_offset_b;//write to bottom half of dual port 1
			DUAL_write_b<={acc1[23:16],acc2[23:16]};//write the first 2
			DUAL_write_en_b<=1'd1;
			DUAL_offset_b<=DUAL_offset_b+1'd1;
			
			loop<=loop+1'd1;
			State<=Buffer_3;
			
			if(loop<8'd15)begin
			temp<={acc3[23:16],acc4[23:16]};
			acc1<=multiplier_1;
			acc2<=multiplier_2;
			acc3<=multiplier_3;
			acc4<=multiplier_4;
			State<=State_32;
			end
			
			if(counter<8'd65)begin
			counter<=counter+1'd1;
			ra<={rb,3'd0}+counter[5:3];
			ca<={cb,3'd0}+counter[2:0];
			SRAM_address<=18'd76800+{ra,8'd0}+{ra,6'd0}+ca;
			DUAL_address<=DUAL_offset;//get read data on this cycle as first intiated in state 2
			DUAL_offset<=DUAL_offset+1'd1;//increase for the next write address
			DUAL_write<={{16{SRAM_read_data[15]}},SRAM_read_data};
			end
			
			end//do the last write
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			Buffer_3:begin
			DUAL_address_b<=DUAL_offset_b;//write to bottom half of dual port 1
			DUAL_write_b<={acc3[23:16],acc4[23:16]};//write the first 2
			DUAL_write_en_b<=1'd1;
			DUAL_offset_b<=DUAL_offset_b+1'd1;
			State<=Buffer_4;
			end
	
			
			Buffer_4:begin
			DUAL_write_en_b<=1'd0;//turn off
			DUAL_address_b<=8'd64;
			DUAL_offset_b<=8'd65;//same for both in this case
			counter<=8'd0;
			State<=Buffer;//back to cs
			
			
			
			//ct to cs
			end
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			State_51:begin
			DUAL_address_b<=DUAL_offset_b;
			DUAL_offset_b<=DUAL_offset_b+1'd1;
			ra<={rb,3'd0}+counter[4:2];
			ca<={cb,2'd0}+counter[1:0];
			
			counter<=counter+1'd1;
			State<=State_52;
			end
			
			State_52:begin
			DUAL_address_b<=DUAL_offset_b;			
			DUAL_offset_b<=DUAL_offset_b+1'd1;
			ra<={rb,3'd0}+counter[4:2];
			ca<={cb,2'd0}+counter[1:0];
			SRAM_address<={ra,7'd0}+{ra,5'd0}+ca;
			SRAM_we_n<=1'd0;
			SRAM_write_data<=DUAL_read_data_b;
			counter<=counter+1'd1;
			if(counter>8'd30)begin
			State<=State_54;
			end
			end
			
		
			State_54:begin
			SRAM_address<={ra,7'd0}+{ra,5'd0}+ca;
			ra<={rb,3'd0}+counter[4:2];
			ca<={cb,2'd0}+counter[1:0];
			
			SRAM_write_data<=DUAL_read_data_b;
			State<=State_55;
			end
					
					
			State_55:begin
			SRAM_address<={ra,7'd0}+{ra,5'd0}+ca;
			SRAM_write_data<=DUAL_read_data_b;
			State<=Stop;
			end
			
			
			
			Stop:begin
			finish<=1'd1;
			SRAM_we_n<=1'd0;//trn writes to sram off
			end
			
						
			
			
				default: State <=Idle;
				
		endcase
			end	
			end


	endmodule

	
	
			
