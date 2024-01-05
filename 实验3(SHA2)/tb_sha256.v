`include "sha256.v"
module tb_sha256();

reg [31:0]input_data;
reg input_valid;
reg last_word;
reg [6:0]blocks;
reg clk;
reg rst;
wire [255:0]hash_data;
wire output_valid;
integer fd,scan_file;

initial begin
clk = 1'b0;
last_word = 1'b0;
input_valid = 1'b1;
blocks = 0;
fd = $fopen("C:/Users/rhett/Desktop/SHA-256/my_file.txt","r");  
rst = 1'b1;
#2;
rst = 1'b0;
end

initial
begin            
    $dumpfile("wave.vcd");        //生成的vcd文件名称
    $dumpvars();    //tb模块名称
end 

sha256 UUT(input_data,input_valid,input_ready,last_word,clk,rst,output_valid,hash_data);

always #10 clk = (~output_valid)^clk;

always @(posedge clk)
begin
	if(input_ready==1'b1 && last_word == 1'b0)
	begin
		scan_file = $fscanf(fd, "%x\n", input_data); 
		blocks <= blocks + 1;
	end
end

always @(blocks)
begin

	if(blocks == 24)						 /*  Change the no. of 32 bit blocks here*/
		last_word = 1'b1;
end

endmodule