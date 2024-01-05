`timescale  1ns / 1ps

module UartTx(
    Clk                     ,
    Rst                     ,
    Out_tx                  ,
    In_data                 ,
    In_data_vld             ,
    Out_send_done
    );
//---------------------------------------------------------------------------------------
//              Parameter
//--------------------------------------------------------------------------------------- 
parameter       TCQ                             = 1                     ;
parameter       CLK_FREQ                        = 100000000             ;//100MHz
parameter       BAUND_RATE                      = 9600                  ;//9600bps
//parameter       BAUND_EN_INTERVAL               = CLK_FREQ/BAUND_RATE   ;
parameter       BAUND_EN_INTERVAL               = 100   				;    //Just for simulation

//---------------------------------------------------------------------------------------
//              Port Define
//---------------------------------------------------------------------------------------
input   wire                                    Clk                     ;
input   wire                                    Rst                     ;
output  wire                                    Out_tx                  ;
input   wire     [7:0]                          In_data                 ;
input   wire                                    In_data_vld             ;
output  wire                                    Out_send_done           ;

//---------------------------------------------------------------------------------------
//              Signals
//---------------------------------------------------------------------------------------
reg												out_tx					;
reg												out_send_done			;

reg     [9:0]                                   send_buf                ;
reg                                             sending                 ;
reg     [15:0]                                  baund_cnt               ;
reg                                             baund_en                ;
reg     [3:0]                                   bit_cnt                 ;
reg                                             send_done               ;
reg                                             send_done_r             ;

//---------------------------------------------------------------------------------------
//              Function Codes
//---------------------------------------------------------------------------------------
assign Out_tx = out_tx;
assign Out_send_done = out_send_done;

always @(posedge Clk) begin
    if(Rst == 1'b1) begin
        baund_cnt    <= #TCQ 16'b0;
        baund_en     <= #TCQ 1'b0;
    end
    else if(sending == 1'b1) begin
        if(baund_cnt == BAUND_EN_INTERVAL - 1'b1)
            baund_cnt    <= #TCQ 16'b0;
        else
            baund_cnt    <= #TCQ baund_cnt + 1'b1;
        
        if(baund_cnt == 16'b0)
            baund_en     <= #TCQ 1'b1;
        else
            baund_en     <= #TCQ 1'b0;
    end
    else begin
        baund_cnt    <= #TCQ 16'b0;
        baund_en     <= #TCQ 1'b0;
    end
end

always @(posedge Clk) begin
    if(Rst == 1'b1) begin
        out_tx       <= #TCQ 1'b1;
        send_buf     <= #TCQ 10'b0;
        sending      <= #TCQ 1'b0;
        bit_cnt      <= #TCQ 4'b0;
        send_done    <= #TCQ 1'b0;
    end
    else begin
        if(In_data_vld == 1'b1) begin
            send_buf      <= #TCQ {1'b1, In_data, 1'b0};
            sending       <= #TCQ 1'b1;
            bit_cnt       <= #TCQ 4'b0;
        end
        else if(baund_en == 1'b1) begin
            out_tx        <= #TCQ send_buf[0];
            send_buf[9:0] <= #TCQ {1'b1, send_buf[9:1]};
            bit_cnt       <= #TCQ bit_cnt + 1'b1;
            
            if(bit_cnt == 4'd10) begin
                sending     <= #TCQ 1'b0;
                send_done   <= #TCQ ~send_done;
            end
        end
    end
end

always @(posedge Clk) begin
    send_done_r     <= #TCQ send_done;
    out_send_done   <= #TCQ send_done^send_done_r;
end

endmodule