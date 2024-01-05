module sha_engine(word,clk,index,rst,output_valid,hash_data,last_word,last_next);

input [31:0]word;
input clk,rst,last_word;
input [1:0]last_next;

reg [31:0]W[63:0];
output reg [6:0] index;
output [255:0]hash_data;
output reg output_valid;
reg [31:0]p,q,r,x,a,b,c,d,e,f,g,h,sum0,Ch,sum1,Maj,T1,T2;
reg [31:0]H[7:0];
reg [31:0]K[63:0];
reg D;

always @(negedge rst)
begin 
D = 1'b0;
index = 7'd126;
output_valid = 1'b0;
H[0] = 32'h6a09e667;
H[1] = 32'hbb67ae85;
H[2] = 32'h3c6ef372;
H[3] = 32'ha54ff53a;
H[4] = 32'h510e527f;
H[5] = 32'h9b05688c;
H[6] = 32'h1f83d9ab;
H[7] = 32'h5be0cd19;

K[0] = 32'h428a2f98; 
K[1] = 32'h71374491;
K[2] = 32'hb5c0fbcf;
K[3] = 32'he9b5dba5;
K[4] = 32'h3956c25b;
K[5] = 32'h59f111f1;
K[6] = 32'h923f82a4;
K[7] = 32'hab1c5ed5;
K[8] = 32'hd807aa98;
K[9] = 32'h12835b01;
K[10] = 32'h243185be;
K[11] = 32'h550c7dc3;
K[12] = 32'h72be5d74;
K[13] = 32'h80deb1fe;
K[14] = 32'h9bdc06a7;
K[15] = 32'hc19bf174;
K[16] = 32'he49b69c1;
K[17] = 32'hefbe4786;
K[18] = 32'h0fc19dc6;
K[19] = 32'h240ca1cc;
K[20] = 32'h2de92c6f;
K[21] = 32'h4a7484aa;
K[22] = 32'h5cb0a9dc;
K[23] = 32'h76f988da;
K[24] = 32'h983e5152;
K[25] = 32'ha831c66d;
K[26] = 32'hb00327c8;
K[27] = 32'hbf597fc7;
K[28] = 32'hc6e00bf3;
K[29] = 32'hd5a79147;
K[30] = 32'h06ca6351;
K[31] = 32'h14292967;
K[32] = 32'h27b70a85;
K[33] = 32'h2e1b2138;
K[34] = 32'h4d2c6dfc;
K[35] = 32'h53380d13;
K[36] = 32'h650a7354;
K[37] = 32'h766a0abb;
K[38] = 32'h81c2c92e;
K[39] = 32'h92722c85;
K[40] = 32'ha2bfe8a1;
K[41] = 32'ha81a664b;
K[42] = 32'hc24b8b70;
K[43] = 32'hc76c51a3;
K[44] = 32'hd192e819;
K[45] = 32'hd6990624;
K[46] = 32'hf40e3585;
K[47] = 32'h106aa070;
K[48] = 32'h19a4c116;
K[49] = 32'h1e376c08;
K[50] = 32'h2748774c;
K[51] = 32'h34b0bcb5;
K[52] = 32'h391c0cb3;
K[53] = 32'h4ed8aa4a;
K[54] = 32'h5b9cca4f;
K[55] = 32'h682e6ff3;
K[56] = 32'h748f82ee;
K[57] = 32'h78a5636f;
K[58] = 32'h84c87814;
K[59] = 32'h8cc70208;
K[60] = 32'h90befffa;
K[61] = 32'ha4506ceb;
K[62] = 32'hbef9a3f7;
K[63] = 32'hc67178f2;
end

always @(posedge clk)
begin
	if(index == 127)
	begin
		a <= H[0];
		b <= H[1];
		c <= H[2];
		d <= H[3];
		e <= H[4];
		f <= H[5];
		g <= H[6];
		h <= H[7];
	end
	if(index<16)
		W[index] <= word;
	else if(index<64)
	begin
		p = {W[index-2][16:0],W[index-2][31:17]}^{W[index-2][18:0],W[index-2][31:19]}^(W[index-2]>>10);
		q = W[index-7];
		r = {W[index-15][6:0],W[index-15][31:7]}^{W[index-15][17:0],W[index-15][31:18]}^(W[index-15]>>3);
		x = W[index-16];
		W[index] <= p + q + r +x;
	end
	index <= index + 1;
end

always @(posedge clk)
begin 
	if(index>0 && index <65)
	begin
		sum1 = {e[5:0],e[31:6]}^{e[10:0],e[31:11]}^{e[24:0],e[31:25]};
		sum0 = {a[1:0],a[31:2]}^{a[12:0],a[31:13]}^{a[21:0],a[31:22]};
		Ch = (e&f)^((~e)&g);
		Maj = (a&b)^(b&c)^(c&a);
		T1 = h + sum1 + Ch +K[index-1] + W[index-1];
		T2 = sum0 + Maj;
		h <= g;
		g <= f;
		f <= e;
		e <= d + h + sum1 + Ch + K[index-1]+ W[index-1];
		d <= c;
		c <= b;
		b <= a;
		a <= T1 + T2;
		
	end
	if(index == 65)
	begin
		H[0] <= a + H[0];
		H[1] <= b + H[1];
		H[2] <= c + H[2];
		H[3] <= d + H[3];
		H[4] <= e + H[4];
		H[5] <= f + H[5];
		H[6] <= g + H[6];
		H[7] <= h + H[7];
		index <= 127;
		if(last_word == 1 && (last_next[0] == 1'b1 || D == 1'b1))
		begin
			output_valid = 1'b1;
		end
		if(last_next[1] == 1'b1)
		begin
			D <= 1'b1;
		end
	end
end

assign hash_data = {H[0],H[1],H[2],H[3],H[4],H[5],H[6],H[7]};
endmodule