`timescale  1ns / 1ps

module Uart(
    Clk                     ,
    Rst                     ,
    //Rx and Tx  
	In_rx                   ,	
    Out_tx					,
	//FIFO
	In_rcv_wr_data_count	,
	In_rcv_full				,
	Out_rcv_wr_en			,	
	Out_rcv_din				,
	
	In_snd_rd_data_count	,
	In_snd_empty			,
	Out_snd_rd_en			,
	In_snd_dout				,
	//Computation
	In_comp_done			,
	Out_comp_enable
);


//---------------------------------------------------------------------------------------
//              Parameter
//--------------------------------------------------------------------------------------- 
parameter       TCQ                             = 1                     ;


//---------------------------------------------------------------------------------------
//              Port Define
//---------------------------------------------------------------------------------------
input   wire                                    Clk                     ;
input   wire                                    Rst                     ;
//Rx and Tx
input   wire                                    In_rx                   ;
output  wire                                    Out_tx                  ;
//FIFO
input   wire   [5:0]                           	In_rcv_wr_data_count	;
input   wire   		                           	In_rcv_full				;
output	wire									Out_rcv_wr_en			;		
output  wire   [7:0]                           	Out_rcv_din				;
		
input   wire   [5:0]                           	In_snd_rd_data_count	;
input   wire									In_snd_empty			;
output	wire									Out_snd_rd_en			;		
input   wire   [7:0]                            In_snd_dout             ;
//Computation
input	wire									In_comp_done			;
output  wire                                    Out_comp_enable  		;
//---------------------------------------------------------------------------------------
//              Signals
//---------------------------------------------------------------------------------------
//UartRx
wire    [7:0]									rx_data					;
wire											rx_data_vld				;
//UartTx		
reg     [7:0] 									tx_data					;
reg									    		tx_data_vld				;
wire											tx_send_done			;
reg                                             tx_send_flag            ;
reg                                             tx_send_flag_r          ;
//FIFO
reg												out_rcv_wr_en			;
reg     [7:0] 									out_rcv_din				;
reg												out_snd_rd_en			;
//Computation
reg												out_comp_enable  		;

//---------------------------------------------------------------------------------------
//              Instance
//---------------------------------------------------------------------------------------
UartRx InstUartRx(
	.Clk								(Clk					),
	.Rst								(Rst					),	
    .In_rx                   			(In_rx					),
    .Out_data                			(rx_data				),
    .Out_data_vld						(rx_data_vld			)
    );
	
UartTx InstUartTx(
	.Clk								(Clk					),
	.Rst								(Rst					),	
    .Out_tx                  			(Out_tx					),
    .In_data                 			(tx_data				),
    .In_data_vld             			(tx_data_vld			),
    .Out_send_done						(tx_send_done			)
    );	

//UartIla InstUartIla(
//	.clk								(Clk					), // input wire         clk
//	.probe0								(In_comp_done			), // input wire [0:0]   probe0  
//	.probe1								(In_snd_rd_data_count	), // input wire [5:0]   probe1 
//	.probe2								(In_snd_empty			), // input wire [0:0]   probe2 
//	.probe3								(Out_snd_rd_en			), // input wire [0:0]   probe3	
//	.probe4								(In_snd_dout			)  // input wire [7:0]   probe4	
//);

//---------------------------------------------------------------------------------------
//              Function Codes
//---------------------------------------------------------------------------------------
assign Out_rcv_wr_en 	= out_rcv_wr_en;
assign Out_rcv_din   	= out_rcv_din;
assign Out_snd_rd_en 	= out_snd_rd_en;

assign Out_comp_enable 	= out_comp_enable;

//For receiving FIFO
always @(posedge Clk) begin
    if(Rst == 1'b1) begin		
		out_rcv_wr_en  <= #TCQ 1'b0;
		out_rcv_din    <= #TCQ 8'd0;
	end
	else if(!In_rcv_full) begin
		out_rcv_wr_en  <= #TCQ rx_data_vld;
		out_rcv_din    <= #TCQ rx_data;
	end
    else begin		
		out_rcv_wr_en  <= #TCQ 1'b0;
		out_rcv_din    <= #TCQ 8'd0;
	end	
end

//For sending FIFO
always @(posedge Clk) begin
    if(Rst == 1'b1) begin
		tx_send_flag   <= #TCQ 1'b0;	
		tx_send_flag_r <= #TCQ 1'b0;
	end
	else begin
	   	tx_send_flag   <= #TCQ In_comp_done;	
	   	tx_send_flag_r <= #TCQ tx_send_flag;
	end
end

always @(posedge Clk) begin
    if(Rst == 1'b1) begin
		out_snd_rd_en  	<= #TCQ 1'b0;	
		tx_data        	<= #TCQ 8'b0;
		tx_data_vld    	<= #TCQ 1'b0;
	end
	else if((tx_send_flag == 1'b1) && (tx_send_flag_r == 1'b0)) begin
		out_snd_rd_en  <= #TCQ 1'b1;	
		tx_data        <= #TCQ In_snd_dout;
		tx_data_vld    <= #TCQ 1'b1;		
	end	
	else if((!In_snd_empty) && (tx_send_done)) begin
		out_snd_rd_en  	<= #TCQ 1'b1;	
		tx_data        	<= #TCQ In_snd_dout;
		tx_data_vld    	<= #TCQ 1'b1;		
	end
	else begin
		out_snd_rd_en  	<= #TCQ 1'b0;	
		tx_data        	<= #TCQ 8'd0;
		tx_data_vld    	<= #TCQ 1'b0;	
	end
end		

//For computation
always @(posedge Clk) begin
    if(Rst == 1'b1) begin
		out_comp_enable	<= #TCQ 1'b0;
	end
	else if((In_rcv_wr_data_count > 6'd32) && (In_snd_rd_data_count < 6'd32)) begin
		out_comp_enable	<= #TCQ 1'b1;		
	end
	else begin
		out_comp_enable	<= #TCQ 1'b0;	
	end
end		
	
//---------------------------------------------------------------------------------------
//              FSM
//---------------------------------------------------------------------------------------




endmodule

