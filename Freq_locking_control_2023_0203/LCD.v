 module LCD(clk50M,out0,out0_1,out1,out1_1,out2,out2_1,out3,out3_1,cs_n,cs_n1,out_clk,out_clk_1O5MHz
				,position_out,INT,PD,botton,botton_out,botton2,sweep,run,OFF,LOCK,freq_cho,current
				,current_flag,clk20MHz,TX_choose,power,max_channal,sweep_flag);
				
input clk50M,clk20MHz;
input [10:0]current;
inout reg out0=0,out1=0,out2=0,out3=0;
input botton,botton2,current_flag;
output cs_n1,position_out,botton_out,sweep,run,OFF,LOCK; 
output reg[3:0]freq_cho;
inout out0_1,out1_1,out2_1,out3_1;
input [5:0]TX_choose;
input [5:0]max_channal;
input sweep_flag;

reg sweep,run,OFF,LOCK;

reg alw=1;
reg botton_delay;
reg botton2_delay;

reg [4:0]botton2_counter=5'd0;



reg clk_1O5MHz;

reg [3:0] counter;

reg [9:0] clk_count;

wire clk_1O5Hz;
assign clk_1O5Hz=clk_1O5Hz_count[22];

reg [23:0] clk_1O5Hz_count;

always @(negedge clk50M)begin
 counter<=counter+1'b1;
 clk_1O5MHz=counter[2];
 
 clk_1O5Hz_count<=clk_1O5Hz_count+1'b1;
 
 if(cs_ready==0)begin out_clk_1O5MHz<=clk_1O5MHz;end
 else begin out_clk_1O5MHz<=0;end
  
end


output wire out_clk;
assign out_clk=out_clk_1O5MHz;
output reg out_clk_1O5MHz;

output reg cs_n=1,INT=1,PD=1;

assign cs_n1=cs_n;

assign out0_1=out0;
assign out1_1=out1;
assign out2_1=out2;
assign out3_1=out3;


assign botton_out=botton;



reg [3:0]state=0;
reg signed [9:0]position;
reg signed [9:0]position1;
reg signed [9:0]position2;
reg signed [9:0]position3;

reg [439:0]int;
reg [439:0]data;
reg cs_ready=0;

 
reg[19:0]count=20'd0;



reg [3:0]botton2_jump;
reg [3:0]botton_jump;

reg botton2_right;
reg botton_right;

reg [3:0]choice=4'd0;





reg [39:0]readdata;

reg[15:0]readdata_X;
reg[15:0]readdata_Y;
reg[15:0]readdata_true_Y;
reg[15:0]readdata_true_X;

reg[10:0]read_current;
reg[10:0]map_current;
reg[15:0]true_map_current[10:0];
reg[14:0]shift_map_current;



always @(negedge clk50M)begin

	readdata_X<=readdata[15:0];
	readdata_Y<=readdata[31:16];
	readdata_true_X[15:0]<={readdata_X[7:0],readdata_X[15:8]};
	readdata_true_Y[15:0]<={readdata_Y[7:0],readdata_Y[15:8]};

	if(current_flag==1'b1)
	begin 
		read_current<=current;
		map_current<={4'd0,11'd320-((read_current-11'd256)+((read_current-11'd256)>>5)+11'd60)};	
//		map_current<={4'd0,11'd600-((read_current<<1)+read_current)};
	end
	
	else begin
		read_current<=read_current;
		map_current<=map_current;
	end
	
	shift_map_current<={map_current,4'd0};
	true_map_current[botton2_counter]<=(TX_choose<=4'd13&&TX_choose>=4'd3)?{shift_map_current[7:0],1'b0,shift_map_current[14:8]}:true_map_current[botton2_counter];


end

reg [3:0]sweep_count;
reg current_flag_delay;






always @(posedge clk20MHz) begin 
	current_flag_delay<=current_flag;
	sweep_count<=(sweep)?5'd0:(sweep_count<=4'd12&&current_flag==1'b1&&current_flag_delay==1'b0)?sweep_count+4'd1:sweep_count; 
	botton2_counter<=(sweep)?5'd0:(sweep_count>=4'd3&&botton2_counter<=5'd10&&current_flag==1'b1&&current_flag_delay==1'b0&&TX_choose>=6'd3)?TX_choose[4:0]-5'd3:botton2_counter;

end





reg [1:0]RUN_choice=2'd0;
reg [1:0]SWEEP_choice=2'd0;

reg rest_RUN=1'd0;
reg rest_SWEEP=1'd0;
reg rest_fre=1'd0;

reg max_channal_chose;

output reg [2:0]power=1'd0;


always @(negedge clk_1O5MHz) begin
   
	readdata[39:0]<={readdata[38:0],out1};
	
	/////////////////////////////////////////RUN//////////////////////////////////
	
	if((count>=20'd62&&count<=20'd67)&&readdata_true_X<=16'd210&&readdata_true_X>=16'd84&&readdata_true_Y<=16'd871&&readdata_true_Y>=16'd768&&readdata[39:32]==8'h42)    
		begin run<=1'd1;OFF<=1'd0;sweep<=1'd0;LOCK<=1'd0;freq_cho<=4'd0;choice<=choice;RUN_choice<=1'd1;SWEEP_choice<=SWEEP_choice;rest_RUN<=(!rest_RUN)?1'd1:rest_RUN;rest_SWEEP<=rest_SWEEP;rest_fre<=rest_fre;power<=power;end
	/////////////////////////////////////////OFF//////////////////////////////////

	else if((count>=20'd62&&count<=20'd67)&&readdata_true_X<=16'd210&&readdata_true_X>=16'd75&&readdata_true_Y<=16'd643&&readdata_true_Y>=16'd545&&readdata[39:32]==8'h42)
		begin run<=1'd0;OFF<=1'd1;sweep<=1'd0;LOCK<=1'd0;freq_cho<=4'd0;choice<=choice;RUN_choice<=1'd2;SWEEP_choice<=SWEEP_choice;rest_RUN<=(!rest_RUN)?1'd1:rest_RUN;rest_SWEEP<=rest_SWEEP;rest_fre<=rest_fre;power<=power;end
	/////////////////////////////////////////SWEEP//////////////////////////////////	

	else if((count>=20'd62&&count<=20'd67)&&readdata_true_X<=16'd210&&readdata_true_X>=16'd75&&readdata_true_Y<=16'd415&&readdata_true_Y>=16'd312&&readdata[39:32]==8'h42)	
		begin run<=1'd0;OFF<=1'd0;sweep<=1'd1;LOCK<=1'd0;freq_cho<=4'd0;choice<=choice;RUN_choice<=RUN_choice;SWEEP_choice<=1'd1;rest_RUN<=rest_RUN;rest_SWEEP<=(!rest_SWEEP)?1'd1:rest_SWEEP;rest_fre<=rest_fre;power<=power;end
	/////////////////////////////////////////LOCK//////////////////////////////////	
	
	else if((count>=20'd62&&count<=20'd67)&&readdata_true_X<=16'd210&&readdata_true_X>=16'd75&&readdata_true_Y<=16'd187&&readdata_true_Y>=16'd84&&readdata[39:32]==8'h42)
		begin run<=1'd0;OFF<=1'd0;sweep<=1'd0;LOCK<=1'd1;freq_cho<=4'd0;choice<=choice;RUN_choice<=RUN_choice;SWEEP_choice<=1'd2;rest_RUN<=rest_RUN;rest_SWEEP<=(!rest_SWEEP)?1'd1:rest_SWEEP;rest_fre<=rest_fre;power<=power;end		
	/////////////////////////////////////////30k//////////////////////////////////	

	else if((count>=20'd62&&count<=20'd67)&&readdata_true_X<=16'd348&&readdata_true_X>=16'd311&&readdata[39:32]==8'h42&&readdata_true_Y<=16'd730)
		begin run<=1'd0;OFF<=1'd0;sweep<=1'd0;LOCK<=1'd0;freq_cho<=4'd1;choice<=4'd1;RUN_choice<=RUN_choice;SWEEP_choice<=SWEEP_choice;rest_RUN<=rest_RUN;rest_SWEEP<=rest_SWEEP;rest_fre<=(!rest_fre)?1'd1:rest_fre;power<=power;end	
	/////////////////////////////////////////31k//////////////////////////////////	

	else if((count>=20'd62&&count<=20'd67)&&readdata_true_X<=16'd412&&readdata_true_X>=16'd372&&readdata[39:32]==8'h42&&readdata_true_Y<=16'd730)	
		begin run<=1'd0;OFF<=1'd0;sweep<=1'd0;LOCK<=1'd0;freq_cho<=4'd2;choice<=4'd2;RUN_choice<=RUN_choice;SWEEP_choice<=SWEEP_choice;rest_RUN<=rest_RUN;rest_SWEEP<=rest_SWEEP;rest_fre<=(!rest_fre)?1'd1:rest_fre;power<=power;end
	/////////////////////////////////////////32k//////////////////////////////////	

	else if((count>=20'd62&&count<=20'd67)&&readdata_true_X<=16'd468&&readdata_true_X>=16'd432&&readdata[39:32]==8'h42&&readdata_true_Y<=16'd730)	
		begin run<=1'd0;OFF<=1'd0;sweep<=1'd0;LOCK<=1'd0;freq_cho<=4'd3;choice<=4'd3;RUN_choice<=RUN_choice;SWEEP_choice<=SWEEP_choice;rest_RUN<=rest_RUN;rest_SWEEP<=rest_SWEEP;rest_fre<=(!rest_fre)?1'd1:rest_fre;power<=power;end	
	/////////////////////////////////////////33k//////////////////////////////////
	
	else if((count>=20'd62&&count<=20'd67)&&readdata_true_X<=16'd523&&readdata_true_X>=16'd492&&readdata[39:32]==8'h42&&readdata_true_Y<=16'd730)
		begin run<=1'd0;OFF<=1'd0;sweep<=1'd0;LOCK<=1'd0;freq_cho<=4'd4;choice<=4'd4;RUN_choice<=RUN_choice;SWEEP_choice<=SWEEP_choice;rest_RUN<=rest_RUN;rest_SWEEP<=rest_SWEEP;rest_fre<=(!rest_fre)?1'd1:rest_fre;power<=power;end		
	///////////////////////////////////////////34k//////////////////////////////////	

	else if((count>=20'd62&&count<=20'd67)&&readdata_true_X<=16'd587&&readdata_true_X>=16'd553&&readdata[39:32]==8'h42&&readdata_true_Y<=16'd730)	
		begin run<=1'd0;OFF<=1'd0;sweep<=1'd0;LOCK<=1'd0;freq_cho<=4'd5;choice<=4'd5;RUN_choice<=RUN_choice;SWEEP_choice<=SWEEP_choice;rest_RUN<=rest_RUN;rest_SWEEP<=rest_SWEEP;rest_fre<=(!rest_fre)?1'd1:rest_fre;power<=power;end
	///////////////////////////////////////////35k//////////////////////////////////	

	else if((count>=20'd62&&count<=20'd67)&&readdata_true_X<=16'd652&&readdata_true_X>=16'd616&&readdata[39:32]==8'h42&&readdata_true_Y<=16'd730)	
		begin run<=1'd0;OFF<=1'd0;sweep<=1'd0;LOCK<=1'd0;freq_cho<=4'd6;choice<=4'd6;RUN_choice<=RUN_choice;SWEEP_choice<=SWEEP_choice;rest_RUN<=rest_RUN;rest_SWEEP<=rest_SWEEP;rest_fre<=(!rest_fre)?1'd1:rest_fre;power<=power;end	
	///////////////////////////////////////////36k//////////////////////////////////	
	
	else if((count>=20'd62&&count<=20'd67)&&readdata_true_X<=16'd707&&readdata_true_X>=16'd670&&readdata[39:32]==8'h42&&readdata_true_Y<=16'd730)	
		begin run<=1'd0;OFF<=1'd0;sweep<=1'd0;LOCK<=1'd0;freq_cho<=4'd7;choice<=4'd7;RUN_choice<=RUN_choice;SWEEP_choice<=SWEEP_choice;rest_RUN<=rest_RUN;rest_SWEEP<=rest_SWEEP;rest_fre<=(!rest_fre)?1'd1:rest_fre;power<=power;end
	///////////////////////////////////////////37k//////////////////////////////////	

	else if((count>=20'd62&&count<=20'd67)&&readdata_true_X<=16'd768&&readdata_true_X>=16'd736&&readdata[39:32]==8'h42&&readdata_true_Y<=16'd730)	
		begin run<=1'd0;OFF<=1'd0;sweep<=1'd0;LOCK<=1'd0;freq_cho<=4'd8;choice<=4'd8;RUN_choice<=RUN_choice;SWEEP_choice<=SWEEP_choice;rest_RUN<=rest_RUN;rest_SWEEP<=rest_SWEEP;rest_fre<=(!rest_fre)?1'd1:rest_fre;power<=power;end	
	///////////////////////////////////////////38k//////////////////////////////////	

	else if((count>=20'd62&&count<=20'd67)&&readdata_true_X<=16'd816&&readdata_true_X>=16'd791&&readdata[39:32]==8'h42&&readdata_true_Y<=16'd730)	
		begin run<=1'd0;OFF<=1'd0;sweep<=1'd0;LOCK<=1'd0;freq_cho<=4'd9;choice<=4'd9;RUN_choice<=RUN_choice;SWEEP_choice<=SWEEP_choice;rest_RUN<=rest_RUN;rest_SWEEP<=rest_SWEEP;rest_fre<=(!rest_fre)?1'd1:rest_fre;power<=power;end		
	///////////////////////////////////////////39k//////////////////////////////////	

	else if((count>=20'd62&&count<=20'd67)&&readdata_true_X<=16'd880&&readdata_true_X>=16'd848&&readdata[39:32]==8'h42&&readdata_true_Y<=16'd730)	
		begin run<=1'd0;OFF<=1'd0;sweep<=1'd0;LOCK<=1'd0;freq_cho<=4'd10;choice<=4'd10;RUN_choice<=RUN_choice;SWEEP_choice<=SWEEP_choice;rest_RUN<=rest_RUN;rest_SWEEP<=rest_SWEEP;rest_fre<=(!rest_fre)?1'd1:rest_fre;power<=power;end
	//////////////////////////////////////////40k//////////////////////////////////	

	else if((count>=20'd62&&count<=20'd67)&&readdata_true_X<=16'd940&&readdata_true_X>=16'd909&&readdata[39:32]==8'h42&&readdata_true_Y<=16'd730)	
		begin run<=1'd0;OFF<=1'd0;sweep<=1'd0;LOCK<=1'd0;freq_cho<=4'd11;choice<=4'd11;RUN_choice<=RUN_choice;SWEEP_choice<=SWEEP_choice;rest_RUN<=rest_RUN;rest_SWEEP<=rest_SWEEP;rest_fre<=(!rest_fre)?1'd1:rest_fre;power<=power;end
	//////////////////////////////////////////power_5//////////////////////////////////
	
	else if((count>=20'd62&&count<=20'd67)&&readdata_true_X<=16'd568&&readdata_true_X>=16'd488&&readdata_true_Y<=16'd895&&readdata_true_Y>=16'd776&&readdata[39:32]==8'h42)
		begin run<=1'd0;OFF<=1'd0;sweep<=1'd0;LOCK<=1'd0;freq_cho<=4'd0;choice<=choice;RUN_choice<=RUN_choice;SWEEP_choice<=SWEEP_choice;rest_RUN<=rest_RUN;rest_SWEEP<=rest_SWEEP;rest_fre<=(!rest_fre)?1'd1:rest_fre;power<=3'd0;end
	
	//////////////////////////////////////////power_25//////////////////////////////////
	else if((count>=20'd62&&count<=20'd67)&&readdata_true_X<=16'd681&&readdata_true_X>=16'd620&&readdata_true_Y<=16'd895&&readdata_true_Y>=16'd776&&readdata[39:32]==8'h42)
		begin run<=1'd0;OFF<=1'd0;sweep<=1'd0;LOCK<=1'd0;freq_cho<=4'd0;choice<=choice;RUN_choice<=RUN_choice;SWEEP_choice<=SWEEP_choice;rest_RUN<=rest_RUN;rest_SWEEP<=rest_SWEEP;rest_fre<=(!rest_fre)?1'd1:rest_fre;power<=3'd1;end
		
	//////////////////////////////////////////power_50//////////////////////////////////
	else if((count>=20'd62&&count<=20'd67)&&readdata_true_X<=16'd781&&readdata_true_X>=16'd718&&readdata_true_Y<=16'd895&&readdata_true_Y>=16'd776&&readdata[39:32]==8'h42)
		begin run<=1'd0;OFF<=1'd0;sweep<=1'd0;LOCK<=1'd0;freq_cho<=4'd0;choice<=choice;RUN_choice<=RUN_choice;SWEEP_choice<=SWEEP_choice;rest_RUN<=rest_RUN;rest_SWEEP<=rest_SWEEP;rest_fre<=(!rest_fre)?1'd1:rest_fre;power<=3'd2;end
	
	//////////////////////////////////////////power_75//////////////////////////////////
	else if((count>=20'd62&&count<=20'd67)&&readdata_true_X<=16'd860&&readdata_true_X>=16'd802&&readdata_true_Y<=16'd895&&readdata_true_Y>=16'd776&&readdata[39:32]==8'h42)
		begin run<=1'd0;OFF<=1'd0;sweep<=1'd0;LOCK<=1'd0;freq_cho<=4'd0;choice<=choice;RUN_choice<=RUN_choice;SWEEP_choice<=SWEEP_choice;rest_RUN<=rest_RUN;rest_SWEEP<=rest_SWEEP;rest_fre<=(!rest_fre)?1'd1:rest_fre;power<=3'd3;end

	//////////////////////////////////////////power_100//////////////////////////////////
	else if((count>=20'd62&&count<=20'd67)&&readdata_true_X<=16'd947&&readdata_true_X>=16'd887&&readdata_true_Y<=16'd895&&readdata_true_Y>=16'd776&&readdata[39:32]==8'h42)
		begin run<=1'd0;OFF<=1'd0;sweep<=1'd0;LOCK<=1'd0;freq_cho<=4'd0;choice<=choice;RUN_choice<=RUN_choice;SWEEP_choice<=SWEEP_choice;rest_RUN<=rest_RUN;rest_SWEEP<=rest_SWEEP;rest_fre<=(!rest_fre)?1'd1:rest_fre;power<=3'd4;end
	
	else
		begin run<=1'd0;OFF<=1'd0;sweep<=1'd0;LOCK<=1'd0;freq_cho<=4'd0;choice<=(TX_choose==6'd14&&sweep_flag)?max_channal-6'd2:choice;RUN_choice<=RUN_choice;SWEEP_choice<=SWEEP_choice;rest_RUN<=rest_RUN;rest_SWEEP<=rest_SWEEP;rest_fre<=(!rest_fre)?1'd1:rest_fre;power<=power;end  
	
	
	
	
	
	
	

	
	
	
	if(state==4'd0) begin
//		if({botton_delay,botton_right}==2'b01)begin
		if(alw==1)begin
			state<=4'd1;
			cs_n<=1;
			position<=10'd439;
			position1<=10'd438;
			position2<=10'd437;
			position3<=10'd436;
			
		end	  
	end
	
	else if(state==4'd1)begin
	
		if(count>20'd67)begin
			state<=4'd0;
			cs_n<=1;
			count<=0;
			out0<=0;
			out1<=0;
			out2<=0;
			out3<=0;
			clk_count<=0;end

			
		else begin
		  case (count)
				20'd0:begin int<=440'h0;end   																							 //commemd        AVTIVE
				20'd1:begin int<=440'h0;end   																							 //commemd        AVTIVE
				20'd2:begin int<={416'h0,24'h614500};end   																			 //SPI commemd        CLKEXT 
				20'd3:begin int<={376'h0,64'h302008DEDEDEDEDE};end   																 //SPI 64bit
				20'd4:begin int<={384'h0,56'hB0200C00870004};end   																 //SPI 56bit				REG_FREQUENCY
				20'd5:begin int<={400'h0,40'hB0202CA003};end   																		 //SPI 40bit				REG_HCYCLE 
				20'd6:begin int<={400'h0,40'hB020305800};end   																		 //SPI 40bit				REG_HOFFSET 
				20'd7:begin int<={400'h0,40'hB020380000};end   																		 //SPI 40bit				REG_HSYNC0
				20'd8:begin int<={400'h0,40'hB0203C3000};end   																		 //SPI 40bit				REG_HSYNC1
				20'd9:begin int<={400'h0,40'hB020400D02};end   																	 	 //SPI 40bit				REG_VCYCLE
				20'd10:begin int<={400'h0,40'hB020442000};end   																	 //SPI 40bit				REG_VOFFSET			
				20'd11:begin int<={400'h0,40'hB0204C0000};end   																	 //SPI 40bit				REG_VSYNCO
				20'd12:begin int<={400'h0,40'hB020500300};end   																	 //SPI 40bit				REG_VSYNC1			
				20'd13:begin int<={408'h0,32'hB0206400};end   																		 //SPI 32bit				REG_SWIZZLF
				20'd14:begin int<={408'h0,32'hB0206C01};end   																		 //SPI 32bit				REG_PCLK_POL
				20'd15:begin int<={400'h0,40'hB020342003};end   															 		 //SPI 40bit				REG_HSIZE
				20'd16:begin int<={400'h0,40'hB02048E001};end   																 	 //SPI 40bit				REG_VSIZE
				20'd17:begin int<={400'h0,40'hB020680000};end   																	 //SPI 40bit				REG_CSPREAD
				20'd18:begin int<={400'h0,40'hB020600100};end   																	 //SPI 40bit				REG_DITHER
				20'd19:begin int<={400'h0,40'hB021180807};end   																	 //SPI 40bit				REG_TOUCH_RZTHRESH
				20'd20:begin int<={408'h0,32'hB02090FF};end   																		 //SPI 32bit				REG_GPIO_DIR
				20'd21:begin int<={408'h0,32'hB02094FF};end   																		 //SPI 32bit				REG_GPIO	
				20'd22:begin int<={352'h0,88'hB00000070000260100001F};end                                           //SPI 88bit
				
		
				
				20'd23:begin int<=(choice==4'd1&&rest_fre==1'd1)?{288'h0,152'hB000080000FF04335BDC9C305B1C9E6B5B5C9F}:{288'h0,152'hB00008FFFFFF04335BDC9C305B1C9E6B5B5C9F};end		//SPI 152bit	30k	
				20'd24:begin int<=(choice==4'd2&&rest_fre==1'd1)?{288'h0,152'hB000180000FF04335B1CA3315B5CA46B5B9CA5}:{288'h0,152'hB00018FFFFFF04335B1CA3315B5CA46B5B9CA5};end		//SPI 152bit	31k
				20'd25:begin int<=(choice==4'd3&&rest_fre==1'd1)?{288'h0,152'hB000280000FF04335B5CA9325B9CAA6B5BDCAB}:{288'h0,152'hB00028FFFFFF04335B5CA9325B9CAA6B5BDCAB};end		//SPI 152bit	32k
				20'd26:begin int<=(choice==4'd4&&rest_fre==1'd1)?{288'h0,152'hB000380000FF04335B9CAF335BDCB06B5B1CB2}:{288'h0,152'hB00038FFFFFF04335B9CAF335BDCB06B5B1CB2};end		//SPI 152bit	33k
				20'd27:begin int<=(choice==4'd5&&rest_fre==1'd1)?{288'h0,152'hB000480000FF04335BDCB5345B1CB76B5B5CB8}:{288'h0,152'hB00048FFFFFF04335BDCB5345B1CB76B5B5CB8};end		//SPI 152bit	34k
				20'd28:begin int<=(choice==4'd6&&rest_fre==1'd1)?{288'h0,152'hB000580000FF04335B1CBC355B5CBD6B5B9CBE}:{288'h0,152'hB00058FFFFFF04335B1CBC355B5CBD6B5B9CBE};end		//SPI 152bit	35k
				20'd29:begin int<={320'h0,120'hB00068000000210100001F2021002B};end  //SPI 120bit
				20'd30:begin int<=(choice==4'd7&&rest_fre==1'd1)?{288'h0,152'hB000740000FF04335B1C80365B5C816B5B9C82}:{288'h0,152'hB00074FFFFFF04335B1C80365B5C816B5B9C82};end		//SPI 152bit	36k
				20'd31:begin int<=(choice==4'd8&&rest_fre==1'd1)?{288'h0,152'hB000840000FF04335B5C86375B9C876B5BDC88}:{288'h0,152'hB00084FFFFFF04335B5C86375B9C876B5BDC88};end		//SPI 152bit	37k
				20'd32:begin int<=(choice==4'd9&&rest_fre==1'd1)?{288'h0,152'hB000940000FF04335B9C8C385BDC8D6B5B1C8F}:{288'h0,152'hB00094FFFFFF04335B9C8C385BDC8D6B5B1C8F};end		//SPI 152bit	38k
				20'd33:begin int<=(choice==4'd10&&rest_fre==1'd1)?{288'h0,152'hB000A40000FF04335BDC92395B1C946B5B5C95}:{288'h0,152'hB000A4FFFFFF04335BDC92395B1C946B5B5C95};end		//SPI 152bit	39k
				20'd34:begin int<=(choice==4'd11&&rest_fre==1'd1)?{288'h0,152'hB000B40000FF04345B1C99305B5C9A6B5B9C9B}:{288'h0,152'hB000B4FFFFFF04345B1C99305B5C9A6B5B9C9B};end		//SPI 152bit	40k
				20'd35:begin int<={352'h0,88'hB000C4000000210000002B};end  //SPI 88bit	
			

				20'd36:begin int<={128'h0,312'hB000CC0300001FFFFFFF041E00000E00001C99001C705700001C9900E00599000000210900001F};end   //SPI 312bit  LINES_X、LINES_Y
					
				20'd37:begin int<=(RUN_choice==1'd1&&rest_RUN==1'd1)?{288'h0,152'hB000F0646400045000000E0000C28300004790}:{288'h0,152'hB000F0646464045000000E0000C28300004790};end   	//SPI 152bit
				20'd38:begin int<=(RUN_choice==1'd2&&rest_RUN==1'd1)?{288'h0,152'hB00100646400045000000E0009F040000E1044}:{288'h0,152'hB00100646464045000000E0009F040000E1044};end   	//SPI 152bit
				20'd39:begin int<=(SWEEP_choice==1'd1&&rest_SWEEP==1'd1)?{288'h0,152'hB00110646400045000000E0000D08300005590}:{288'h0,152'hB00110646464045000000E0000D08300005590};end   	//SPI 152bit
				20'd40:begin int<=(SWEEP_choice==1'd2&&rest_SWEEP==1'd1)?{288'h0,152'hB00120646400045000000E0000D78300005C90}:{288'h0,152'hB00120646464045000000E0000D78300005C90};end   	//SPI 152bit

				
				20'd41:begin int<={192'h0,248'hB00130000000210100001FFFFFFF04418B9996308B59952E8BB994348B7993};end				 //SPI 248bit	4.0A	
				20'd42:begin int<={160'h0,280'hB0014C410B9796350B57952E0BB794340B7793418B9496308B54952E8BB494358B7493};end   //SPI 280bit	4.5A、5.0A	
				20'd43:begin int<={160'h0,280'hB0016C410B9296350B52952E0BB294350B7293418B8F96308B4F952E8BAF94368B6F93};end   //SPI 280bit	5.5A、6.0A	
				20'd44:begin int<={160'h0,280'hB0018C410B8D96350B4D952E0BAD94360B6D93418B8A96308B4A952E8BAA94378B6A93};end   //SPI 280bit	6.5A、7.0A	
				20'd45:begin int<={160'h0,280'hB001AC410B8896350B48952E0BA894370B6893418B8596308B45952E8BA594388B6593};end   //SPI 280bit	7.5A、8.0A	
				20'd46:begin int<={160'h0,280'hB001CC4F9CEA86469C6A89469CEA8B529CE386559C63894E9CE38B4C9C18854F9C9887};end   //SPI 280bit	
				20'd47:begin int<={160'h0,280'hB001EC439C188A4B9C988C539CB185579C9187459C118A459CF18B509CD18D00000021};end   //SPI 280bit	
				
				
				
				20'd48:begin int<=(choice==4'd0)?{224'h0,216'hB0020C0000FF041000000E0300001F000000400100004000000021}:					//SPI 216bit
										(choice==4'd1)?{224'h0,216'hB0020C0000FF041000000E0300001FE0058047001C804700000021}:					//SPI 216bit
										(choice==4'd2)?{224'h0,216'hB0020C0000FF041000000E0300001FE0051049001C104900000021}:					//SPI 216bit
										(choice==4'd3)?{224'h0,216'hB0020C0000FF041000000E0300001FE005A04A001CA04A00000021}:					//SPI 216bit
										(choice==4'd4)?{224'h0,216'hB0020C0000FF041000000E0300001FE005304C001C304C00000021}:					//SPI 216bit
										(choice==4'd5)?{224'h0,216'hB0020C0000FF041000000E0300001FE005C04D001CC04D00000021}:					//SPI 216bit
										(choice==4'd6)?{224'h0,216'hB0020C0000FF041000000E0300001FE005504F001C504F00000021}:					//SPI 216bit
										(choice==4'd7)?{224'h0,216'hB0020C0000FF041000000E0300001FE005E050001CE05000000021}:					//SPI 216bit
										(choice==4'd8)?{224'h0,216'hB0020C0000FF041000000E0300001FE0057052001C705200000021}:					//SPI 216bit
										(choice==4'd9)?{224'h0,216'hB0020C0000FF041000000E0300001FE0050054001C005400000021}:					//SPI 216bit
										(choice==4'd10)?{224'h0,216'hB0020C0000FF041000000E0300001FE0059055001C905500000021}:					//SPI 216bit
										(choice==4'd11)?{224'h0,216'hB0020C0000FF041000000E0300001FE0052057001C205700000021}:440'd0;end 	//SPI 216bit
															
										
				20'd49:begin int<={256'h0,184'hB002240900001F646464045000000EC003F04A10047057};end 			//SPI 184bit
				
				
				
				
				20'd50:begin int<=(power==3'd0)?{288'h0,152'hB00238FFFFFF045000000E4003084DD004584D}:  					//SPI 152bit
										(power==3'd1)?{288'h0,152'hB00238FFFFFF045000000E4003704FD004C04F}:
										(power==3'd2)?{288'h0,152'hB00238FFFFFF045000000E4003D851D0042852}:
										(power==3'd3)?{288'h0,152'hB00238FFFFFF045000000E40034054D0049054}:
										(power==3'd4)?{288'h0,152'hB00238FFFFFF045000000E4003A856D004F856}:440'd0;end
				
				
	
				20'd51:begin int<={96'h0,344'hB00248000000210100001FFFFFFF04CC0F429AC50F229DD60F02A0C50FE2A2CC0FC2A5BA0FA2A800000021};end  //SPI 344bit
				
								
										
										
				20'd52:begin int<={256'h0,184'hB002700100001FFFFFFF04352C41B3252C01B500000021};end  //SPI 184bit					
				20'd53:begin int<={224'h0,216'hB002840100001FFFFFFF04322CA1BC352C61BE252CC1BF00000021};end  //SPI 216bit
				20'd54:begin int<={192'h0,248'hB0029C0100001F2023002BFFFFFF04352C0180302CC181252C818300000021};end  //SPI 248bit	
				20'd55:begin int<={224'h0,216'hB002B80100001FFFFFFF04372CA189352C618B252C218D00000021};end  //SPI 216bit
				20'd56:begin int<={160'h0,280'hB002D00100001FFFFFFF04312C8191302C4193302C0195252CC196000000210000002B};end  //SPI 280bit				
				
				
				
				
				20'd57:begin int<={320'h0,120'hB002F00400001F00FFFF043000000E};end  //SPI 120bit
				
				
				20'd58:begin int<=(botton2_counter==5'd0)?{320'h0,24'hB002FC,true_map_current[0],16'h8047,64'h0000002100000000}:  //SPI 120bit
										 (botton2_counter==5'd1)?{288'h0,24'hB002FC,true_map_current[0],16'h8047,true_map_current[1],16'h1049,64'h0000002100000000}: //SPI 152bit
										 (botton2_counter==5'd2)?{256'h0,24'hB002FC,true_map_current[0],16'h8047,true_map_current[1],16'h1049,true_map_current[2],16'hA04A,64'h0000002100000000}: //SPI 184bit
										 (botton2_counter==5'd3)?{224'h0,24'hB002FC,true_map_current[0],16'h8047,true_map_current[1],16'h1049,true_map_current[2],16'hA04A,true_map_current[3],16'h304C,64'h0000002100000000}: //SPI 216bit
										 (botton2_counter==5'd4)?{192'h0,24'hB002FC,true_map_current[0],16'h8047,true_map_current[1],16'h1049,true_map_current[2],16'hA04A,true_map_current[3],16'h304C,true_map_current[4],16'hC04D,64'h0000002100000000}:  //SPI 248bit
										 (botton2_counter==5'd5)?{160'h0,24'hB002FC,true_map_current[0],16'h8047,true_map_current[1],16'h1049,true_map_current[2],16'hA04A,true_map_current[3],16'h304C,true_map_current[4],16'hC04D,true_map_current[5],16'h504F,64'h0000002100000000}:  //SPI 280bit
										 (botton2_counter==5'd6)?{128'h0,24'hB002FC,true_map_current[0],16'h8047,true_map_current[1],16'h1049,true_map_current[2],16'hA04A,true_map_current[3],16'h304C,true_map_current[4],16'hC04D,true_map_current[5],16'h504F,true_map_current[6],16'hE050,64'h0000002100000000}:  //SPI 312bit
										 (botton2_counter==5'd7)?{96'h0,24'hB002FC,true_map_current[0],16'h8047,true_map_current[1],16'h1049,true_map_current[2],16'hA04A,true_map_current[3],16'h304C,true_map_current[4],16'hC04D,true_map_current[5],16'h504F,true_map_current[6],16'hE050,true_map_current[7],16'h7052,64'h0000002100000000}:  //SPI 344bit
										 (botton2_counter==5'd8)?{64'h0,24'hB002FC,true_map_current[0],16'h8047,true_map_current[1],16'h1049,true_map_current[2],16'hA04A,true_map_current[3],16'h304C,true_map_current[4],16'hC04D,true_map_current[5],16'h504F,true_map_current[6],16'hE050,true_map_current[7],16'h7052,true_map_current[8],16'h0054,64'h0000002100000000}:  //SPI 376bit
										 (botton2_counter==5'd9)?{32'h0,24'hB002FC,true_map_current[0],16'h8047,true_map_current[1],16'h1049,true_map_current[2],16'hA04A,true_map_current[3],16'h304C,true_map_current[4],16'hC04D,true_map_current[5],16'h504F,true_map_current[6],16'hE050,true_map_current[7],16'h7052,true_map_current[8],16'h0054,true_map_current[9],16'h9055,64'h0000002100000000}:  //SPI 408bit
										 (botton2_counter==5'd10)?{24'hB002FC,true_map_current[0],16'h8047,true_map_current[1],16'h1049,true_map_current[2],16'hA04A,true_map_current[3],16'h304C,true_map_current[4],16'hC04D,true_map_current[5],16'h504F,true_map_current[6],16'hE050,true_map_current[7],16'h7052,true_map_current[8],16'h0054,true_map_current[9],16'h9055,true_map_current[10],16'h2057,64'h0000002100000000}:int;end  	 //SPI 440bit					 
				
				
		
				20'd59:begin int<={408'h0,32'hB0205402};end   																		 //SPI 32bit  REG_DLSWAP 
				20'd60:begin int<={408'h0,32'hB0207002};end   																		 //SPI 32bit  REG_PCLK
				20'd61:begin int<=440'h0;end   																							 //commemd        AVTIVE
				20'd62:begin int<={376'h0,64'h3021240000000000};end   																 //SPI 64bit
				20'd63:begin int<={376'h0,64'h3021240000000000};end   																 //SPI 64bit
				20'd64:begin int<={376'h0,64'h3021240000000000};end   																 //SPI 64bit
				20'd65:begin int<={376'h0,64'h3021240000000000};end   																 //SPI 64bit
				20'd66:begin int<={376'h0,64'h3021240000000000};end   																 //SPI 64bit
				20'd67:begin int<={376'h0,64'h3021240000000000};end   																 //SPI 64bit
				
		
					
		  
		  default:begin int<=440'd0;end
		  endcase
		  
	
			
			if(position[9]==1)begin
				cs_n<=1;
				cs_ready<=1;
				position<=10'd439;
				position1<=10'd438;
				position2<=10'd437;
				position3<=10'd436;
				count<=count+1;
				clk_count<=0;

			end
			/////////////////////////////////////////////////////SPI commemd 24bit
			else begin
				if(count==20'd0||count==20'd1||count==20'd2||count==20'd61)begin
					cs_ready<=0;
					data<=int;
					if(position==10'd439)begin					
						position<=10'd23;
						position1<=10'd22;
						position2<=10'd21;
						position3<=10'd20;end
					else begin
						clk_count<=clk_count+10'd1;
						if(clk_count>=10'd24 && clk_count<=10'd30)begin cs_ready<=1;end
						else begin cs_ready<=0;end
						
						if(cs_ready==0)begin
						cs_n<=0;
						position<=position-10'd1;
						out0<=int[position];
						position1<=position1-10'd1;
						out1<=1'bz;
						position2<=position2-10'd1;
						out2<=0;
						position3<=position3-10'd1;
						out3<=0;end
					end
				end
				/////////////////////////////////////////////////////SPI 32bit
				else if(count==20'd13||count==20'd14||count==20'd20||count==20'd21||count==20'd59||count==20'd60)begin
					data<=int;
					cs_ready<=0;
					if(position==10'd439)begin					
						position<=10'd31;
						position1<=10'd30;
						position2<=10'd29;
						position3<=10'd28;
					end
					else begin
						clk_count<=clk_count+10'd1;
						if(clk_count>=10'd24 && clk_count<=10'd30)begin cs_ready<=1;end
						else begin cs_ready<=0;end
					
						if(cs_ready==0)begin
						cs_n<=0;
						position<=position-10'd1;
						out0<=int[position];
						position1<=position1-10'd1;
						out1<=1'bz;
						position2<=position2-10'd1;
						out2<=0;
						position3<=position3-10'd1;
						out3<=0;end
					end
				end
				
					/////////////////////////////////////////////////////SPI 40bit
				else if((count>=20'd5&&count<=20'd12)||(count>=20'd15&&count<=20'd19))begin
					data<=int;
					cs_ready<=0;
					if(position==10'd439)begin					
						position<=10'd39;
						position1<=10'd38;
						position2<=10'd37;
						position3<=10'd36;
					end
					else begin
						clk_count<=clk_count+10'd1;
						if(clk_count>=10'd24 && clk_count<=10'd30)begin cs_ready<=1;end
						else begin cs_ready<=0;end
					
						if(cs_ready==0)begin
						cs_n<=0;
						position<=position-10'd1;
						out0<=int[position];
						position1<=position1-10'd1;
						out1<=1'bz;
						position2<=position2-10'd1;
						out2<=0;
						position3<=position3-10'd1;
						out3<=0;end
					end
				end
				///////////////////////////////////////////////////SPI 64bit
				else if(count==20'd3||(count>=20'd62&&count<=20'd67))begin
					data<=int;
					cs_ready<=0;
					if(position==10'd439)begin					
						position<=10'd63;
						position1<=10'd62;
						position2<=10'd61;
						position3<=10'd60;end
					else begin
						clk_count<=clk_count+10'd1;
						if(clk_count>=10'd24 && clk_count<=10'd30)begin cs_ready<=1;end
						else begin cs_ready<=0;end
					
						if(cs_ready==0)begin
						cs_n<=0;
						position<=position-10'd1;
						out0<=int[position];
						position1<=position1-10'd1;
						out1<=1'bz;
						position1<=position2-10'd1;
						out2<=0;
						position1<=position3-10'd1;
						out3<=0;end
					end
				end
				///////////////////////////////////////////////////SPI 56bit
				else if(count==20'd4)begin
					data<=int;
					cs_ready<=0;
					if(position==10'd439)begin					
						position<=10'd55;
						position1<=10'd54;
						position2<=10'd53;
						position3<=10'd52;end
					else begin
						clk_count<=clk_count+10'd1;
						if(clk_count>=10'd24 && clk_count<=10'd30)begin cs_ready<=1;end
						else begin cs_ready<=0;end
					
						if(cs_ready==0)begin
						cs_n<=0;
						position<=position-10'd1;
						out0<=int[position];
						position1<=position1-10'd1;
						out1<=1'bz;
						position1<=position2-10'd1;
						out2<=0;
						position1<=position3-10'd1;
						out3<=0;end
					end
				end
				///////////////////////////////////////////////////SPI 88bit
				else if(count==20'd22||count==20'd35)begin
					data<=int;
					cs_ready<=0;
					if(position==10'd439)begin					
						position<=10'd87;
						position1<=10'd86;
						position2<=10'd85;
						position3<=10'd84;end
					else begin
						clk_count<=clk_count+10'd1;
						if(clk_count>=10'd24 && clk_count<=10'd30)begin cs_ready<=1;end
						else begin cs_ready<=0;end
					
						if(cs_ready==0)begin
						cs_n<=0;
						position<=position-10'd1;
						out0<=int[position];
						position1<=position1-10'd1;
						out1<=1'bz;
						position1<=position2-10'd1;
						out2<=0;
						position1<=position3-10'd1;
						out3<=0;end
					end
				end
				/////////////////////////////////////////////////////SPI 280bit
				else if((count==20'd58&&botton2_counter==5'd5)||(count>=20'd42&&count<=20'd47)||count==20'd56)begin
					data<=int;
					cs_ready<=0;
					if(position==10'd439)begin					
						position<=10'd279;
						position1<=10'd278;
						position2<=10'd277;
						position3<=10'd276;
					end
					else begin
						clk_count<=clk_count+10'd1;
						if(clk_count>=10'd24 && clk_count<=10'd30)begin cs_ready<=1;end
						else begin cs_ready<=0;end
					
						if(cs_ready==0)begin
						cs_n<=0;
						position<=position-10'd1;
						out0<=int[position];
						position1<=position1-10'd1;
						out1<=1'bz;
						position2<=position2-10'd1;
						out2<=0;
						position3<=position3-10'd1;
						out3<=0;end
					end
				end
				/////////////////////////////////////////////////////SPI 120bit
				else if((count==20'd58&&botton2_counter==5'd0)||count==20'd29||count==20'd57)begin
					data<=int;
					cs_ready<=0;
					if(position==10'd439)begin					
						position<=10'd119;
						position1<=10'd118;
						position2<=10'd117;
						position3<=10'd116;
					end
					else begin
						clk_count<=clk_count+10'd1;
						if(clk_count>=10'd24 && clk_count<=10'd30)begin cs_ready<=1;end
						else begin cs_ready<=0;end
					
						if(cs_ready==0)begin
						cs_n<=0;
						position<=position-10'd1;
						out0<=int[position];
						position1<=position1-10'd1;
						out1<=1'bz;
						position2<=position2-10'd1;
						out2<=0;
						position3<=position3-10'd1;
						out3<=0;end
					end
				end
				/////////////////////////////////////////////////////SPI 152bit
				else if((count==20'd58&&botton2_counter==5'd1)||(count>=20'd23&&count<=20'd28)||(count>=20'd30&&count<=20'd34)||(count>=20'd37&&count<=20'd40)||count==20'd50)begin
					data<=int;
					cs_ready<=0;
					if(position==10'd439)begin					
						position<=10'd151;
						position1<=10'd150;
						position2<=10'd149;
						position3<=10'd148;
					end
					else begin
						clk_count<=clk_count+10'd1;
						if(clk_count>=10'd24 && clk_count<=10'd30)begin cs_ready<=1;end
						else begin cs_ready<=0;end
					
						if(cs_ready==0)begin
						cs_n<=0;
						position<=position-10'd1;
						out0<=int[position];
						position1<=position1-10'd1;
						out1<=1'bz;
						position2<=position2-10'd1;
						out2<=0;
						position3<=position3-10'd1;
						out3<=0;end
					end
				end
				/////////////////////////////////////////////////////SPI 184bit
				else if((count==20'd58&&botton2_counter==5'd2)||count==20'd49||count==20'd52)begin
					data<=int;
					cs_ready<=0;
					if(position==10'd439)begin					
						position<=10'd183;
						position1<=10'd182;
						position2<=10'd181;
						position3<=10'd180;
					end
					else begin
						clk_count<=clk_count+10'd1;
						if(clk_count>=10'd24 && clk_count<=10'd30)begin cs_ready<=1;end
						else begin cs_ready<=0;end
					
						if(cs_ready==0)begin
						cs_n<=0;
						position<=position-10'd1;
						out0<=int[position];
						position1<=position1-10'd1;
						out1<=1'bz;
						position2<=position2-10'd1;
						out2<=0;
						position3<=position3-10'd1;
						out3<=0;end
					end
				end
				////////////////////////////////////////////////////SPI 216bit
				else if((count==20'd58&&botton2_counter==5'd3)||count==20'd48||count==20'd53||count==20'd55)begin
					data<=int;
					cs_ready<=0;
					if(position==10'd439)begin					
						position<=10'd215;
						position1<=10'd214;
						position2<=10'd213;
						position3<=10'd212;
					end
					else begin
						clk_count<=clk_count+10'd1;
						if(clk_count>=10'd24 && clk_count<=10'd30)begin cs_ready<=1;end
						else begin cs_ready<=0;end
					
						if(cs_ready==0)begin
						cs_n<=0;
						position<=position-10'd1;
						out0<=int[position];
						position1<=position1-10'd1;
						out1<=1'bz;
						position2<=position2-10'd1;
						out2<=0;
						position3<=position3-10'd1;
						out3<=0;end
					end
				end
				/////////////////////////////////////////////////////SPI 248bit
				else if((count==20'd58&&botton2_counter==5'd4)||count==20'd41||count==20'd54)begin
					data<=int;
					cs_ready<=0;
					if(position==10'd439)begin					
						position<=10'd247;
						position1<=10'd246;
						position2<=10'd245;
						position3<=10'd244;
					end
					else begin
						clk_count<=clk_count+10'd1;
						if(clk_count>=10'd24 && clk_count<=10'd30)begin cs_ready<=1;end
						else begin cs_ready<=0;end
					
						if(cs_ready==0)begin
						cs_n<=0;
						position<=position-10'd1;
						out0<=int[position];
						position1<=position1-10'd1;
						out1<=1'bz;
						position2<=position2-10'd1;
						out2<=0;
						position3<=position3-10'd1;
						out3<=0;end
					end
				end
				/////////////////////////////////////////////////////SPI 312bit
				else if((count==20'd58&&botton2_counter==5'd6)||count==20'd36)begin
					data<=int;
					cs_ready<=0;
					if(position==10'd439)begin					
						position<=10'd311;
						position1<=10'd310;
						position2<=10'd309;
						position3<=10'd308;
					end
					else begin
						clk_count<=clk_count+10'd1;
						if(clk_count>=10'd24 && clk_count<=10'd30)begin cs_ready<=1;end
						else begin cs_ready<=0;end
					
						if(cs_ready==0)begin
						cs_n<=0;
						position<=position-10'd1;
						out0<=int[position];
						position1<=position1-10'd1;
						out1<=1'bz;
						position2<=position2-10'd1;
						out2<=0;
						position3<=position3-10'd1;
						out3<=0;end
					end
				end
				/////////////////////////////////////////////////////SPI 344bit
				else if((count==20'd58&&botton2_counter==5'd7)||count==20'd51)begin
					data<=int;
					cs_ready<=0;
					if(position==10'd439)begin					
						position<=10'd343;
						position1<=10'd342;
						position2<=10'd341;
						position3<=10'd340;
					end
					else begin
						clk_count<=clk_count+10'd1;
						if(clk_count>=10'd24 && clk_count<=10'd30)begin cs_ready<=1;end
						else begin cs_ready<=0;end
					
						if(cs_ready==0)begin
						cs_n<=0;
						position<=position-10'd1;
						out0<=int[position];
						position1<=position1-10'd1;
						out1<=1'bz;
						position2<=position2-10'd1;
						out2<=0;
						position3<=position3-10'd1;
						out3<=0;end
					end
				end
				/////////////////////////////////////////////////////SPI 376bit
				else if(count==20'd58&&botton2_counter==5'd8)begin
					data<=int;
					cs_ready<=0;
					if(position==10'd439)begin					
						position<=10'd375;
						position1<=10'd374;
						position2<=10'd373;
						position3<=10'd372;
					end
					else begin
						clk_count<=clk_count+10'd1;
						if(clk_count>=10'd24 && clk_count<=10'd30)begin cs_ready<=1;end
						else begin cs_ready<=0;end
					
						if(cs_ready==0)begin
						cs_n<=0;
						position<=position-10'd1;
						out0<=int[position];
						position1<=position1-10'd1;
						out1<=1'bz;
						position2<=position2-10'd1;
						out2<=0;
						position3<=position3-10'd1;
						out3<=0;end
					end
				end
				/////////////////////////////////////////////////////SPI 408bit
				else if(count==20'd58&&botton2_counter==5'd9)begin
					data<=int;
					cs_ready<=0;
					if(position==10'd439)begin					
						position<=10'd407;
						position1<=10'd406;
						position2<=10'd405;
						position3<=10'd404;
					end
					else begin
						clk_count<=clk_count+10'd1;
						if(clk_count>=10'd24 && clk_count<=10'd30)begin cs_ready<=1;end
						else begin cs_ready<=0;end
					
						if(cs_ready==0)begin
						cs_n<=0;
						position<=position-10'd1;
						out0<=int[position];
						position1<=position1-10'd1;
						out1<=1'bz;
						position2<=position2-10'd1;
						out2<=0;
						position3<=position3-10'd1;
						out3<=0;end
					end
				end
				///////////////////////////////////////////////////SPI 440bit
				else begin
					data<=int;
					cs_ready<=0;
					
						clk_count<=clk_count+10'd1;
						if(clk_count>=10'd25 && clk_count<=10'd29)begin cs_ready<=1;end
						else begin cs_ready<=0;end
					
						if(cs_ready==0)begin
						cs_n<=0;
						position<=position-10'd1;
						out0<=int[position];
						position1<=position1-10'd1;
						out1<=1'bz;
						position1<=position2-10'd1;
						out2<=0;
						position1<=position3-10'd1;
						out3<=0;end
					
				end
			end	
				
				
		end
	end
//////////////////////////////////////////////////////////////////////////////////// 
			

end


endmodule




