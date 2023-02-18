//-------------   Voltage-Controlled Oscillator (VCO) ------------//
//                                                                //
//         frequency = increment*(50e6)/(2^24)  Hz                //
//         [example] increment=15'b110100011011100 (26844)        //
//                   corresponds to 80.001kHz.                    //

module VCO(out,increment,clk50MHz);
output out;
input [14:0] increment;
input clk50MHz;

//------------------------------------------------------------------------//
// A counter counts up and down, 0<=count<=2^23; with an increment.       //
// The up and down correspond to the positive and negative cycles         //
// of the output 												                       //
//                           out=up_count                                 // 

reg [23:0] count=24'b0;
reg up_count=1'b1; 

wire [23:0] delta,sum;
assign delta={9'b0,increment};	
assign sum=up_count?(count+delta):(count-delta);

always @(posedge clk50MHz) begin
    count 	<= sum[23]? ~(sum-1)	:sum;
	 up_count<= sum[23]? ~up_count:up_count;
end

wire out;
assign out=up_count;


endmodule 