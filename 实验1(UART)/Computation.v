`timescale  1ns / 1ps

module Computation(
    Clk                     ,
    Rst                     ,
	In_enable				,
	Out_done				,
	// FIFO
	In_rcv_dout				,
	Out_rcv_rd_en			,
	Out_snd_din				,
	Out_snd_wr_en			
);

//---------------------------------------------------------------------------------------
//              Parameter
//--------------------------------------------------------------------------------------- 
parameter       TCQ                             = 1                     ;
//FSM-------------------------------------------------------------------
parameter       STA_IDLE                        = 4'h0                  ;
parameter       STA_READING                   	= 4'h1                  ;
parameter       STA_ROUND                   	= 4'h2                  ;
parameter       STA_ROUND_DONE                  = 4'h3                  ;
parameter       STA_WRITING                     = 4'h4                  ;
parameter       STA_COMPUTING_DONE              = 4'h5                  ;

//---------------------------------------------------------------------------------------
//              Port Define
//---------------------------------------------------------------------------------------
input   wire                                    Clk                     ;
input   wire                                    Rst                     ;
input   wire                                    In_enable               ;
output  wire                                    Out_done                ;
// FIFO		
input   wire   [31:0]                           In_rcv_dout				;
output  wire									Out_rcv_rd_en			;	
output  wire   [31:0]                           Out_snd_din				;
output  wire									Out_snd_wr_en			;

//---------------------------------------------------------------------------------------
//              Signals
//---------------------------------------------------------------------------------------
reg												out_done				;
reg                                         	out_rcv_rd_en			;
reg    [31:0]                                  	out_snd_din				;
reg											    out_snd_wr_en			;

reg    [31:0]                                  	rcv_dout				;
reg    [31:0]                                  	tmp						;
reg    [7:0]									cnt_round				;

//---------------------------------------------------------------------------------------
//              Instance
//---------------------------------------------------------------------------------------
//CompIla InstCompIla(
//	.clk				(Clk					), // input wire         clk
//	.probe0				(In_enable				), // input wire [0:0]   probe0  
//	.probe1				(Out_done				), // input wire [0:0]   probe1 
//	.probe2				(In_rcv_dout			), // input wire [31:0]  probe2 
//	.probe3				(Out_rcv_rd_en			), // input wire [0:0]   probe3 
//	.probe4				(Out_snd_din			), // input wire [31:0]  probe4 
//	.probe5				(Out_snd_wr_en			), // input wire [0:0]   probe5
//	.probe6				(curr_state				), // input wire [7:0]   probe6
//	.probe7				(cnt_round				)  // input wire [7:0]   probe7
//);

//---------------------------------------------------------------------------------------
//              Function Codes
//---------------------------------------------------------------------------------------
assign Out_done = out_done;
assign Out_rcv_rd_en = out_rcv_rd_en;
assign Out_snd_din = out_snd_din;
assign Out_snd_wr_en = out_snd_wr_en;

//---------------------------------------------------------------------------------------
//              FSM
//---------------------------------------------------------------------------------------
reg     [7:0]                           curr_state            			;
reg     [7:0]                           next_state            			;

//State Tranfer
always @(posedge Clk) begin
    if(Rst == 1'b1)
        curr_state <= #TCQ STA_IDLE;
    else
        curr_state <= #TCQ next_state;
end

//Calculate the next state
always @( * ) begin
    case(curr_state)
        STA_IDLE            : begin
            if(In_enable)
                next_state = STA_READING;
            else
                next_state = STA_IDLE;
        end
        
        STA_READING         : begin
            next_state = STA_ROUND;
        end
        
        STA_ROUND 			: begin
            next_state = STA_ROUND_DONE;
        end
		
        STA_ROUND_DONE   	: begin
			next_state = STA_WRITING;
        end
				
        STA_WRITING       	: begin
			if(cnt_round < 8'd4)
				next_state = STA_READING;
			else if(cnt_round == 8'd4) 
				next_state = STA_COMPUTING_DONE;
        end		
 
		STA_COMPUTING_DONE	: begin
			next_state = STA_IDLE;
		end
 
        default             : begin
            next_state = STA_IDLE;
        end
    endcase
end

//state output
always @(posedge Clk) begin
    if(Rst == 1'b1) begin
        out_rcv_rd_en       	<= #TCQ 1'b0;
		out_snd_wr_en 			<= #TCQ 1'b0;
        out_snd_din     		<= #TCQ 32'd0; 
		rcv_dout				<= #TCQ 32'd0;
		out_done       			<= #TCQ 1'b0;	
		cnt_round				<= #TCQ 8'd0;
    end

    else case(curr_state)
        STA_IDLE            : begin
			out_rcv_rd_en       	<= #TCQ 1'b0;
			out_snd_wr_en 			<= #TCQ 1'b0;
			out_snd_din     		<= #TCQ 32'd0; 
			rcv_dout				<= #TCQ 32'd0;
			out_done       			<= #TCQ 1'b0;	
			cnt_round				<= #TCQ 8'd0;
        end
        
        STA_READING       	: begin
			out_snd_wr_en     		<= #TCQ 1'b0;
			out_snd_din     		<= #TCQ 32'd0; 
			out_rcv_rd_en       	<= #TCQ 1'b1;
			rcv_dout				<= #TCQ In_rcv_dout;
        end

        STA_ROUND       	: begin
            out_rcv_rd_en       	<= #TCQ 1'b0;
			tmp       				<= #TCQ {rcv_dout[7:0], rcv_dout[15:8], rcv_dout[23:16], rcv_dout[31:24]};			
        end

		STA_ROUND_DONE  	: begin
			cnt_round				<= #TCQ cnt_round + 8'd1;
		end
     
        STA_WRITING        	: begin
			out_snd_wr_en     		<= #TCQ 1'b1;
			out_snd_din				<= #TCQ tmp;
			
        end
		
		STA_COMPUTING_DONE	: begin
		    out_snd_wr_en     		<= #TCQ 1'b0;
			out_done     			<= #TCQ 1'b1;
		end
    endcase
end

endmodule

