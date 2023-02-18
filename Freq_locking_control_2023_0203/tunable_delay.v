module tunable_delay(u,r,Is, phase, pulse20kHz, pulse1kHz, clk10MHz, standby);
output r;//,locked;
output [7:0] u;
//output signed [9:0] theta4;
input signed [7:0] phase;
input Is, pulse20kHz, pulse1kHz, clk10MHz, standby;//,standby;

//-------1kHz Lowpass Filter (z+1)/(8z-6),at the sample frequency 20kHz-------//
reg signed [10:0] theta8;    // theta8=8*theta
reg signed [7:0] phase_1;    // phase_1=phase(k-1)
wire signed [10:0] temp_sum;
assign temp_sum={{3{phase[7]}},phase}+{{3{phase_1[7]}},phase_1}+
       {theta8[10],theta8[10:1]}+{{2{theta8[10]}},theta8[10:2]};
always @(posedge pulse20kHz) begin
	 theta8 <= temp_sum;
	 phase_1 <= phase;
end

//---------------Digital delay line for the bianry injection signal-----------//
//   Tunable delay range:  u = [225 239 255];                                 //
//                         u/10e6*20e3 = [0.45 0.478 0.51] period of delay    //
reg [255:0] Is_delay;   // save Is on registers
wire [7:0] next;  		// next time index
assign next=now+1;
reg [7:0] now;    		// current time index
always @(posedge clk10MHz) begin
   Is_delay[now]<=Is;
	now<=next;
end

//-------------Tune the delay to make phase roughly equal to zero-------------//
wire signed [10:0] theta8_set_point; 
assign theta8_set_point=11'b0;   	    //11'b00001100000; //12*8, 28 deg;
wire signed [10:0] err8;
assign err8=-theta8_set_point+theta8;
wire signed  [10:0] diff;
assign diff=theta8-11'b00001001000;     //8*(theta-9) 
wire higher_than_25deg;
assign higher_than_25deg=~diff[10];
reg [7:0] u=8'b0;
always @(posedge standby) begin//always @(posedge pulse1kHz) begin
          u<=u+1;//5'b01110;;//higher_than_25deg? (u+1):u;//5'b01110;//
end

reg [7:0] index;
always @(negedge pulse1kHz) begin
          index<=now-u;//temp_index-u;//8'b11101111;//{3'b0,u};//now-{3'b0,u}-8'b11100000; //now-u-224;
end
reg r;
reg [7:0] temp_index;
always @(negedge clk10MHz) begin
    r<=~Is_delay[index];
	 temp_index<=now-8'b11100000;
end

endmodule