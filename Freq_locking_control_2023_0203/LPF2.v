//--------------------- Lowpass Filter-------------------------//
//                z + 1                                        //
//              ---------  , fs, cutoff=1.25/60*fs kHz         //
//              16 z - 14                                      //

module LPF2(out,in,clk); 
input clk;
input signed [23:0] in;
output signed [23:0] out;
assign out=out16[27:4];
reg signed [27:0] out16;     				// out16 = 16*theta
reg signed [23:0] in_1;       				// in_1 = in(k-1)
wire signed [27:0] temp_sum;
assign temp_sum={{4{in[23]}},in}+{{4{in_1[23]}},in_1}+out16
                  -{{3{out16[27]}},out16[27:3]};
always @(posedge clk) begin
	 out16 <= temp_sum;
	 in_1 <= in;
end


endmodule
