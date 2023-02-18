// 60.5kHz, BW=9kHz Bandpass filter
//           6 z^2 - 6
//     ---------------------
//     256 z^2 - 478 z + 245
//
//     Sample rate = 1.25 MHz 

module BPF60kHz(out, in, clk1d25MHz);
input clk1d25MHz;
input signed [12:0] in;
output signed [13:0] out;
assign out=u256[21:8];
// 478=512-32-2=(2-1/8-1/128)*256
// 245=256-8-4+1=(1-1/32-1/64+1/256)*256
wire signed [21:0] u478, u245_1, in6;
assign in6={{8{in[12]}},in,1'b0}+{{7{in[12]}},in,2'b0};
assign u478={u256[20:0],1'b0}-{{3{u256[21]}},u256[21:3]}-{{7{u256[21]}},u256[21:7]};
assign u245_1=u256_1-{{5{u256_1[21]}},u256_1[21:5]}-{{6{u256_1[21]}},u256_1[21:6]}
              +{{8{u256_1[21]}},u256_1[21:8]};
reg signed [21:0] u256, u256_1,in6_1, in6_2;
always @(posedge clk1d25MHz) begin
    u256_1<=u256;
	 u256<=u478-u245_1+in6-in6_2;
	 in6_2<=in6_1;
	 in6_1<=in6;
end

endmodule
