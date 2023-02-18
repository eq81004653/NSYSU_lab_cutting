// Bandpass filter tf([9 0 -9],[256 -457 238],1/325e3)
// output: out and out_inter data update @ posedge of clk325kHz
//         out is the current output; 
//         out_inter is the average of the current and previous output; 
module BPF_interpolation(out,out_inter, in, clk325kHz);
input clk325kHz;
input signed [12:0] in;
output signed [13:0] out, out_inter;
assign out=u256[21:8];
assign out_inter=sum[22:9];
wire signed [22:0] sum;
assign sum={u256[21],u256}+{u256_1[21], u256_1};

// 457=(1+1/2+1/4+1/32+1/256)*256
// 238=(1-1/16-1/128)*256
wire signed [21:0] u457, u238_1, in9;
assign in9={{9{in[12]}},in}+{{6{in[12]}},in,3'b0};
assign u457=u256+{u256[21],u256[21:1]}+{{2{u256[21]}},u256[21:2]}+{{5{u256[21]}},u256[21:5]}+{{8{u256[21]}},u256[21:8]};
assign u238_1=u256_1-{{4{u256_1[21]}},u256_1[21:4]}-{{7{u256_1[21]}},u256_1[21:7]};
reg signed [21:0] u256, u256_1,in9_1, in9_2;
always @(posedge clk325kHz) begin
    u256_1<=u256;
	 u256<=u457-u238_1+in9-in9_2;
	 in9_2<=in9_1;
	 in9_1<=in9;
end

endmodule
