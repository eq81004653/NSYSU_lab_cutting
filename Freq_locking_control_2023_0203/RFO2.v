module RFO2(y, n, r, clk10MHz);
input r, clk10MHz;  // Get the injection r and frequency-setting parameter n at negedge of clk10MHz
input [4:0] n;      // and output y at negedge of clk10MHz
output y;
//
// A relay-feedback oscillator consists of a comparator & a bandpass 
// filter in feedback, and the bandpass filter is realized by the
// negative feedback of a lowpass F and an integrator G. The oscillator
// outputs a square wave y and its oscillation frequency dependent of 
// a 4-bit parameter n and a binary input r.
//
//                                     __________        
//                                    |    ___   |       
//        y <----------------+--------|   | |    |<------.
//                           |        |  _|_|    |       |
//                        .-----.     |__________|       |
//                        | 2^6 |      comparator        |      
//                        |_____|                        |
//                           |       ______________      |
//              .-----.   + \/  e   |    4(z+1)    |  f  |
//        r --->| 2^8 |----> O----->|  ----------- |-----+
//              |_____|     /\-     |   z(8192z-b) |     |
//                           |      |______________|     |
//                           |        F(z),fs=10MHz      |
//                           |         __________        |
//                           |   g    |  k(z+1)  |       |
//                           '--------|  ------- |<------'
//                                    | 256z-256 |
//                                    |__________|
//                                    G(z),fs=10MHz
//
// The parameter n sets the free-running frequency (without any injection r=0):
//
//      n =  0,   1,    2,    3,    4,    5,    6,    7,    8,  
//      f0=30.5, 31.1, 31.7, 32.3, 32.9, 33.5, 34.1, 34.6, 35.2,
//
//      n=    9,    10,   11,   12,   13,  14,    15 ;
//      f0= 35.7, 36.2, 36.8, 37.3, 37.8, 38.3, 38.8 kHz;
//
// Input r will fine-tune the frequency. The integrator gain is related to n by
// 
//                    k = n+0.5; 
//  
// Another parameter b in the diagram is set by the rule
//
//                    b = 8180+1, if n[4:3]=2'b00
//                        8180-1, if n[4:3]=2'b11
//                        8180(=8192-8-4) otherwise,
//
// intended for maintaining almost constant gain 1 & bandwidth 1kHz for
// the bandpass filter in the loop.    
//                                   Shiang-Hwua Yu, NSYSU, March 2021.



//------------------Generate 1.25MHz clock-----------------------//
//             clock frequency: 10MHz/8=1.25MHz                  //
reg [2:0] count;
always @(posedge clk10MHz) count<=count+1;
wire clk1d25MHz;
assign clk1d25MHz=count[2];

//-------60.5kHz Bandpass Filtering of injection signal r-------//
wire signed [13:0] injection;
wire signed [12:0] inj;
assign inj={{4{r}},1'b1,8'b0};
BPF60kHz U4(.out(injection), .in(inj), .clk1d25MHz(clk1d25MHz));

//-----------------Relay-Feedback Oscillator--------------------//
reg  signed [23:0] f8192;
reg  signed [23:0] g256;
wire y;
assign y=f8192[23];
wire signed [17:0] e4;
//assign e4= {{10{y}},1'b1,6'b0}-g256[22:6]+{{8{r}},1'b1,8'b0}; //+{{7{r&injection}},injection,9'b0}; 
assign e4= {{11{y}},1'b1,6'b0}-g256[23:6]+{{4{injection[13]}},injection};  // r=injection, y=relay_feedback, r:y=1:1
wire signed [23:0] f8180;
assign f8180=f8192-{{10{f8192[23]}},f8192[23:10]}-{{11{f8192[23]}},f8192[23:11]};
reg signed [17:0] e4_1;
reg [4:0] nn;
always @(negedge clk10MHz) begin
       f8192<= fb+{{6{e4[17]}},e4}+{{6{e4_1[17]}},e4_1};
		 e4_1 <= e4;
		 nn   <= n;
end

wire signed [18:0] f32,f128;//,f64;
assign f128={{1{y}},f8192[23: 6]};
assign f32={{3{y}},f8192[23: 8]};
//assign f64={{2{y}},f8192[22: 7]};//+  //{{2{y}},f8192[22: 8]}+{{3{y}},f8192[22:9]}+
           //+{{6{y}},f8192[22:12]};                      //{{5{y}},f8192[22:11]}+{{6{y}},f8192[22:12]};

wire signed [18:0] f0d5,f1,f2,f4,f8,f16; //f0d125,//f0d25,f0d5,
//assign f0d25={{10{y}},f8192[23:15]};
assign f0d5={{9{y}},f8192[23:14]}; 
//assign f0d125={{11{y}},f8192[23:16]}; 
assign f1 =nn[0]? {{8{y}},f8192[23:13]}:19'b0;
assign f2 =nn[1]? {{7{y}},f8192[23:12]}:19'b0;
assign f4 =nn[2]? {{6{y}},f8192[23:11]}:19'b0;
assign f8 =nn[3]? {{5{y}},f8192[23:10]}:19'b0;
assign f16=nn[4]? {{4{y}},f8192[23: 9]}:19'b0;
wire signed [18:0] fk;
assign fk=f1+f2+f4+f8+f16+f32+f128+f0d5;//+f0d25;//20.1kHz   //f0d125//-f0d25;//f0d5+
//assign fk=f64+f1+f2+f4+f8+f16;
reg signed [18:0] fk_1;
always @(posedge clk10MHz) begin
       g256 <= g256+{{5{fk[18]}},fk}+{{5{fk_1[18]}},fk_1};
		 fk_1 <= fk; 
end
		 
reg  signed [23:0] fb;
wire signed [10:0] f;
assign f=f8192[23:13];
always @(posedge clk10MHz) begin
   case (nn[4:3])
	    2'b00:   fb<=f8180+{{13{f[10]}},f};
	    2'b11:   fb<=f8180-{{13{f[10]}},f};
		 default: fb<=f8180;
	endcase
end
 
endmodule 