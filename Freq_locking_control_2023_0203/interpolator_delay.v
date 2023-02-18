//    FIR Filter for Interpolation between Sampled Data
//    FIR coefficients multiplied by 1024 turn out to be
//    h0    h1    h2    h3
//   -58   843   281   -42    x1d25=(h0*x0+h1*x1+h2*x2+h3*x3)/1024
//   -67   579   579   -67    x1d5 =(h0*x0+h1*x1+h2*x2+h3*x3)/1024
//   -42   281   843   -58    x1d75=(h0*x0+h1*x1+h2*x2+h3*x3)/1024
module interpolator_delay(x1,x1d25,x1d5,x1d75, xin, clk325kHz_d1);
input clk325kHz_d1;
input signed [13:0] xin;
output signed [13:0] x1,x1d25,x1d5,x1d75;

assign x1d25=x1024_1d25[23:10];		// x(k-1.75), k=3
assign x1d5 =x1024_1d5[23:10];		// x(k-1.50), k=3
assign x1d75=x1024_1d75[23:10];   	// x(k-1.75), k=3

//   Hard-Wired Multipliers by a Bunch of Shifts and Adds
//   58 = 64-4-2; 843= 512+256+64+8+2+1; 281= 256+16+8+1; 42 = 32+8+2;       
//   67 = 64+2+1;     579= 512+64+2+1
wire signed [24:0] x58_0, x843_1, x281_2, x42_3;
wire signed [24:0] x67_0, x579_1, x579_2, x67_3;
wire signed [24:0] x42_0, x281_1, x843_2, x58_3;
assign x42_3={{6{x3[13]}},x3,5'b0}+{{8{x3[13]}},x3,3'b0}+{{10{x3[13]}},x3,1'b0};
assign x281_2={{3{x2[13]}},x2,8'b0}+{{7{x2[13]}},x2,4'b0}+{{8{x2[13]}},x2,3'b0}+{{11{x2[13]}},x2};
assign x843_1={{2{x1[13]}},x1,9'b0}+{{3{x1[13]}},x1,8'b0}+{{5{x1[13]}},x1,6'b0}+{{8{x1[13]}},x1,3'b0}+{{10{x1[13]}},x1,1'b0}+{{11{x1[13]}},x1};
assign x58_0={{5{x0[13]}},x0,6'b0}-{{9{x0[13]}},x0,2'b0}-{{10{x0[13]}},x0,1'b0};
assign x67_0={{5{x0[13]}},x0,6'b0}+{{10{x0[13]}},x0,1'b0}+{{11{x0[13]}},x0};
assign x579_1={{2{x1[13]}},x1,9'b0}+{{5{x1[13]}},x1,6'b0}+{{10{x1[13]}},x1,1'b0}+{{11{x1[13]}},x1};
assign x579_2={{2{x2[13]}},x2,9'b0}+{{5{x2[13]}},x2,6'b0}+{{10{x2[13]}},x2,1'b0}+{{11{x2[13]}},x2};
assign x67_3={{5{x3[13]}},x3,6'b0}+{{10{x3[13]}},x3,1'b0}+{{11{x3[13]}},x3};
assign x58_3={{5{x3[13]}},x3,6'b0}-{{9{x3[13]}},x3,2'b0}-{{10{x3[13]}},x3,1'b0};
assign x843_2={{2{x2[13]}},x2,9'b0}+{{3{x2[13]}},x2,8'b0}+{{5{x2[13]}},x2,6'b0}+{{8{x2[13]}},x2,3'b0}+{{10{x2[13]}},x2,1'b0}+{{11{x2[13]}},x2};
assign x281_1={{3{x1[13]}},x1,8'b0}+{{7{x1[13]}},x1,4'b0}+{{8{x1[13]}},x1,3'b0}+{{11{x1[13]}},x1};
assign x42_0={{6{x0[13]}},x0,5'b0}+{{8{x0[13]}},x0,3'b0}+{{10{x0[13]}},x0,1'b0};

reg signed [24:0] x1024_1d25, x1024_1d5, x1024_1d75;
always @(posedge clk325kHz_d1) begin
     x1024_1d75 <= -x42_0 +x281_1 +x843_2 -x58_3;
	  x1024_1d5  <= -x67_0 +x579_1 +x579_2 -x67_3;
	  x1024_1d25 <= -x58_0 +x843_1 +x281_2 -x42_3;
end

reg signed [13:0] x0, x1,x2,x3;//,x_temp;
always @(negedge clk325kHz_d1) begin
	  x0 <= x1;
	  x1 <= x2;
	  x2 <= x3;
	  x3 <= xin;
	 // x3 <= x_temp;
	 // x_temp <= xin;
end
endmodule
