module phase_control(locked,increment, phase, pulse83kHz, standby);
output locked;
output [14:0] increment;
input signed [8:0] phase;
input pulse83kHz,standby;

//---------4kHz Lowpass Filter (z+1)/(8z-6),at the sample frequency 80kHz ---------//
reg signed [11:0] theta8;    // theta8=8*theta
reg signed [8:0] phase_1;    // phase_1=phase(k-1)
wire signed [11:0] temp_sum;
assign temp_sum={{3{phase[8]}},phase}+{{3{phase_1[8]}},phase_1}+
       {theta8[11],theta8[11:1]}+{{2{theta8[11]}},theta8[11:2]};
always @(posedge pulse83kHz) begin
	 theta8 <= temp_sum;
	 phase_1 <= phase;
end

//------------- Generate a 5kHz clock for control ------------------------//
reg [3:0] count;
always @(posedge pulse83kHz) count<=count+1;
wire pulse5kHz;
assign pulse5kHz=pulse83kHz&(count[3]&~count[2:0]);
//------- Anti-Resonant Frequency Tracking Control at the sample frequency 5kHz --------//
wire signed [11:0] theta8_set_point; //156*8 corresponds to 180 degrees 
assign theta8_set_point=11'b0;
wire signed [11:0] err8;
assign err8=theta8_set_point+theta8;
//parameter initial_value={15'b110111000000000,11'b0};//28160*50e6/2^24=83.92kHz
//reg signed [25:0] uI2048=initial_value;
reg [8:0] abs_err;
//wire signed [8:0] diff30, diff16;
//assign diff30=theta8[11:3]+11'b111000100;  //(theta-60)
//assign diff16=theta8[11:3]+11'b111100000;  //(theta-32)
always @(posedge pulse5kHz) begin
	  abs_err <= err8[11]? (1+~err8[11:3]):err8[11:3];
	//  if (standby==1)              uI2048 <= initial_value; 
	//  else if (diff30[8]==0) 		 uI2048 <= (uI2048-{{14{err8[11]}},err8});  			// kI=1   when theta>60
	//     else if (diff16[8]==0)    uI2048 <= (uI2048-{{15{err8[11]}},err8[11:1]});  	// kI=1/2 when 60>theta>32
	//	     else   	  				 uI2048 <= (uI2048-{{17{err8[11]}},err8[11:3]});  	// kI=1/8 otherwise
end 
//wire signed [25:0] u2048;
//assign u2048= uI2048-{{10{err8[11]}},err8,4'b0}-{{12{err8[11]}},err8,2'b0};// PI control
parameter initial_value=15'b110111000000000;
reg [14:0] increment=initial_value;
reg locked=1'b0;
always @(negedge pulse5kHz) begin
    increment <= standby? initial_value: increment-{{14{err8[11]}},1'b1};
    locked <= standby? 1'b0:(abs_err<20);   
	 // locked=1 when the absolute phase error is less than 20(24 degrees). 
end

endmodule