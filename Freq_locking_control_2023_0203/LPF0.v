//---------------------1.25kHz Lowpass Filter------------------//
//                       z + 1                                 //
//                     ---------  , fs=60kHz                   //
//                     16 z - 14                               //

module LPF0(out,in,clk60kHz); 
input clk60kHz;
input signed [9:0] in;
output signed [9:0] out;
assign out=out16[13:4];
reg signed [13:0] out16;     				// out16 = 16*theta
reg signed [9:0] in_1;       				// in_1 = in(k-1)
wire signed [13:0] temp_sum;
assign temp_sum={{4{in[9]}},in}+{{4{in_1[9]}},in_1}+out16
                  -{{3{out16[13]}},out16[13:3]};
always @(posedge clk60kHz) begin
	 out16 <= temp_sum;
	 in_1 <= in;
end


endmodule
