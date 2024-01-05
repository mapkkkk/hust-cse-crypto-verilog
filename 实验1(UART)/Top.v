`timescale  1ns / 1ps

module Top(
    Clk_p                   ,
	Clk_n                   ,
    //Rx and Tx  
	In_rx                   ,	
    Out_tx					
    );
//---------------------------------------------------------------------------------------
//              Parameter
//--------------------------------------------------------------------------------------- 
parameter       TCQ                             = 1                     ;

//---------------------------------------------------------------------------------------
//              Port Define
//---------------------------------------------------------------------------------------
input   wire                                    Clk_p                   ;
input   wire                                    Clk_n                   ;
//Rx and Tx
input   wire                                    In_rx                   ;
output  wire                                    Out_tx                  ;

//---------------------------------------------------------------------------------------
//              Signals
//---------------------------------------------------------------------------------------
//ClkWid
wire											clk200m							;
wire											clk100m							;
wire											clk50m							;
wire											locked							;
//RcvFifo		
wire    [7:0]                           		rcv_din							;
wire											rcv_wr_en						;
wire											rcv_full						;
wire    [5:0]                           		rcv_wr_data_count				;
wire    [31:0]                          		rcv_dout						;
wire											rcv_rd_en						;
wire											rcv_empty						;
wire    [3:0]                           		rcv_rd_data_count				;
//SndFifo		
wire    [31:0]                          		snd_din							;
wire											snd_wr_en						;
wire											snd_full						;
wire    [3:0]                           		snd_wr_data_count				;
wire    [7:0]                           		snd_dout						;
wire											snd_rd_en						;
wire											snd_empty						;
wire    [5:0]                           		snd_rd_data_count				;
//Computation
wire											comp_enable						;
wire											comp_done						;

//---------------------------------------------------------------------------------------
//              Instance
//---------------------------------------------------------------------------------------
IBUFGDS InstClkTrans
(
    .O(clk200m),
    .I(Clk_p),
    .IB(Clk_n)
);

ClkWiz InstClkWiz(
	.clk_out100m						(clk100m				),	// output clk_out100m
    .clk_out50m							(clk50m					),	// output clk_out50m
    .clk_in200m							(clk200m				),	// input clk_in100m
    .locked                             (locked                 )
);      

Uart InstUart(
	.Clk								(clk100m				),
	.Rst								(!locked				),
    //Rx and Tx  
	.In_rx                   			(In_rx					),	
    .Out_tx								(Out_tx					),	
	//FIFO
	.In_rcv_wr_data_count				(rcv_wr_data_count		),
	.In_rcv_full						(rcv_full				),
	.Out_rcv_wr_en						(rcv_wr_en				),
	.Out_rcv_din						(rcv_din				),
	.In_snd_rd_data_count				(snd_rd_data_count		),
	.In_snd_empty						(snd_empty				),
	.Out_snd_rd_en						(snd_rd_en				),
	.In_snd_dout						(snd_dout				),
	//Computation
	.In_comp_done						(comp_done				),
	.Out_comp_enable                	(comp_enable            )
);

RcvFifo InstRcvFifo(
	.rst								(!locked				),	// input wire rst
	.wr_clk								(clk100m				),	// input wire wr_clk
	.rd_clk								(clk50m					),	// input wire rd_clk
	.din								(rcv_din				),	// input wire [7 : 0] din
	.wr_en								(rcv_wr_en				),	// input wire wr_en
	.rd_en								(rcv_rd_en				),	// input wire rd_en
	.dout								(rcv_dout				),	// output wire [31 : 0] dout
	.full								(rcv_full				),	// output wire full
	.empty								(rcv_empty				),	// output wire empty
	.rd_data_count						(rcv_rd_data_count		),	// output wire [3 : 0] rd_data_count
	.wr_data_count						(rcv_wr_data_count		)	// output wire [5 : 0] wr_data_count
);

SndFifo InstSndFifo(
	.rst								(!locked				),	// input wire rst
	.wr_clk								(clk50m					),	// input wire wr_clk
	.rd_clk								(clk100m				),	// input wire rd_clk
	.din								(snd_din				),	// input wire [31 : 0] din
	.wr_en								(snd_wr_en				),	// input wire wr_en
	.rd_en								(snd_rd_en				),  // input wire rd_en
	.dout								(snd_dout				),	// output wire [7 : 0] dout
	.full								(snd_full				),	// output wire full
	.empty								(snd_empty				),	// output wire empty
	.rd_data_count						(snd_rd_data_count		),  // output wire [5 : 0] rd_data_count
	.wr_data_count						(snd_wr_data_count		)   // output wire [3 : 0] wr_data_count
);

Computation InstComputation(
	.Clk								(clk50m					),
	.Rst								(!locked				),
	.In_enable							(comp_enable			),
	.Out_done							(comp_done				),
	//FIFO
    .In_rcv_dout                   		(rcv_dout 				),
	.Out_rcv_rd_en                 		(rcv_rd_en				),
    .Out_snd_din                		(snd_din				),
    .Out_snd_wr_en						(snd_wr_en				)	
);
//ILA
TopIla InstTopIla(
	.clk								(clk100m				), // input wire         clk
	.probe0								(comp_enable			), // input wire [0:0]   probe0	  
	.probe1								(comp_done				), // input wire [0:0]   probe1	 
	.probe2								(rcv_dout				), // input wire [31:0]  probe2	 
	.probe3								(rcv_rd_en				), // input wire [0:0]   probe3		
	.probe4								(snd_din				), // input wire [31:0]  probe4	
	.probe5								(snd_wr_en				), // input wire [0:0]   probe5	
	.probe6								(snd_empty				), // input wire [0:0]   probe6	
	.probe7								(snd_rd_data_count		)  // input wire [5:0]   probe7	
	//.probe8							( ), // input wire [0:0]   probe8	
	//.probe9							( ), // input wire [0:0]   probe9	
	//.probe10							( ), // input wire [0:0]   probe10
	//.probe11							( ), // input wire [0:0]   probe11
	//.probe12							( ), // input wire [0:0]   probe12
	//.probe13							( ), // input wire [0:0]   probe13
	//.probe14							( ), // input wire [0:0]   probe14
	//.probe15							( ) // input wire [0:0]   probe15
);
//---------------------------------------------------------------------------------------
//              Function Codes
//---------------------------------------------------------------------------------------
	

//---------------------------------------------------------------------------------------
//              FSM
//---------------------------------------------------------------------------------------


endmodule

