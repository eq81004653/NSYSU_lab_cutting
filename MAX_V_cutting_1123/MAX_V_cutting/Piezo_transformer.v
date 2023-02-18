module Piezo_transformer(S1,S2,P1,P2,R_led,G_led,B_led,SW,Vs,Is,Short,clk50MHz);
output S1,S2,P1,P2,R_led,G_led,B_led;
input SW,Vs,Is,Short,clk50MHz;

reg P1,P2,G_led,B_led;//R_led,
initial begin
  // S1=1;S2=1;
	P1=0;P2=0;
	//R_led=0;
	G_led=0;
	B_led=0;
end

//-----------Clock Generator---------------//
wire clk12d5MHz;
assign clk12d5MHz=count0[1];
reg [2:0] count0;
always @(posedge clk50MHz) count0<=count0+1; 
//divide_by_5_60duty U1(.Out(clk10MHz),.In(clk50MHz));

//-------- status determined by SW ---------//
reg [11:0] count;
always @(posedge count0[2])  	count<=count+1;//{11'b0,1'b1};
wire clk1280Hz;
assign clk1280Hz=count[11];

reg debounce_switch=0;
always @(posedge clk1280Hz) 	debounce_switch<=~SW;
reg [1:0] status=2'b0;
wire [1:0] sum;
assign sum=status+{1'b0,1'b1};
always @(negedge debounce_switch) 	status<=sum; 

wire enable;
assign enable=|status;
always @(negedge count[9]) begin
   case(status)
	   2'b00: begin G_led=1;B_led=1;P1=0;P2=0;end //R_led=count[23];
		2'b01: begin G_led=0;B_led=1; P1=0;P2=0;end //R_led=1;
		2'b10: begin G_led=count[11]&count[10];B_led=1;P1=1;P2=0;end //R_led=0;
		2'b11: begin G_led=1;B_led=count[10];P1=1;P2=1;end //R_led=0;
		default: begin G_led=1;B_led=1;P1=0;P2=0;end //R_led=count[22];
	endcase
end

//---------
wire S1, S2;
assign S2=~S1;
//parameter set_value=15'b110100011011100;  //26844
//reg [14:0] increment=15'b110100011011100;
//always @(posedge clk1280Hz) increment<=set_value;
VCO  U1(.out(S1),.increment(increment),.clk50MHz(clk50MHz));
wire R_led;

wire signed [8:0] theta;
reg I, V, I_temp, V_temp;
always @(posedge clk12d5MHz) begin
    I<=I_temp; I_temp<=Is;
	 V<=V_temp; V_temp<=Vs;
end
	 
wire pulse83kHz;
wire signed [8:0] phase;
phase_estimator U2(.theta(theta),.pulse83kHz(pulse83kHz),.Is(I),.Vs(V),.clk12d5MHz(clk12d5MHz));

//--------------- Phase Control --------------------//
wire [14:0] increment;
assign increment=15'b110100011011100;//80kHz
//wire locked, standby;
//assign standby=1'b1;
//phase_control  U3(.locked(locked),.increment(increment),.phase(phase),.pulse83kHz(pulse83kHz),.standby(standby));
endmodule
