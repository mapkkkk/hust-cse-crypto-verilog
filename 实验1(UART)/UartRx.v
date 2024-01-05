`timescale  1ns / 1ps

module UartRx(
    Clk                     ,
    Rst                     ,
    In_rx                   ,
    Out_data                ,
    Out_data_vld
    );

//---------------------------------------------------------------------------------------
//              Parameter
//--------------------------------------------------------------------------------------- 
parameter       TCQ                             = 1                     ;
parameter       CLK_FREQ                        = 100000000             ;    //100MHz
parameter       BAUND_RATE                      = 9600                  ;    //9600bps
//parameter       BAUND_EN_INTERVAL               = CLK_FREQ/BAUND_RATE   ;
parameter       BAUND_EN_INTERVAL               = 100   				;    //Just for simulation

//FSM-------------------------------------------------------------------
parameter       STA_IDLE                        = 2'h0                  ;
parameter       STA_RX_START                    = 2'h1                  ;
parameter       STA_RX_REC_DATA                 = 2'h2                  ;
parameter       STA_RX_STOP                     = 2'h3                  ;

//---------------------------------------------------------------------------------------
//              Port Define
//---------------------------------------------------------------------------------------
input   wire                                    Clk                     ;
input   wire                                    Rst                     ;
input   wire                                    In_rx                   ;
output  wire    [7:0]                           Out_data                ;
output  wire                                    Out_data_vld            ;

//---------------------------------------------------------------------------------------
//              Signals
//---------------------------------------------------------------------------------------
reg    [7:0]                           			out_data                ;
reg                                    			out_data_vld            ;

reg    [7:0]                                    rx_buf                  ;
wire                                            rx_data_bit             ;
reg    [3:0]                                    bit_value_sum           ;
wire                                            fall_detect_pulse       ;
reg                                             receiving               ;
reg    [15:0]                                   baund_cnt               ;
reg                                             baund_en                ;
reg    [2:0]                                    bit_cnt                 ;

reg    [7:0]                                   curr_state            	;
reg    [7:0]                                   next_state            	;

//---------------------------------------------------------------------------------------
//              Function Codes
//---------------------------------------------------------------------------------------
assign Out_data = out_data;
assign Out_data_vld = out_data_vld;

always @(posedge Clk) begin
    if(Rst == 1'b1)
        rx_buf       <= #TCQ 8'b0;
    else begin
        rx_buf[0]    <= #TCQ In_rx;
        rx_buf[7:1]  <= #TCQ rx_buf[6:0];
    end
end

assign fall_detect_pulse = (~rx_buf[3])&rx_buf[4];

always @(posedge Clk) begin
    bit_value_sum    <= #TCQ rx_buf[0] + rx_buf[1] + rx_buf[2] + rx_buf[3] + rx_buf[4] + rx_buf[5] + rx_buf[6] + rx_buf[7];
end

assign rx_data_bit = (bit_value_sum >= 4'h4) ? 1'b1 : 1'b0;

always @(posedge Clk) begin
    if(Rst == 1'b1) begin
        baund_cnt    <= #TCQ 16'b0;
        baund_en     <= #TCQ 1'b0;
    end
    else if(receiving == 1'b1) begin
        if(baund_cnt == BAUND_EN_INTERVAL - 1'b1)
            baund_cnt    <= #TCQ 16'b0;
        else
            baund_cnt    <= #TCQ baund_cnt + 1'b1;
        
        if(baund_cnt == BAUND_EN_INTERVAL/2 - 1'b1)
            baund_en     <= #TCQ 1'b1;
        else
            baund_en     <= #TCQ 1'b0;
    end
    else begin
        baund_cnt    <= #TCQ 16'b0;
        baund_en     <= #TCQ 1'b0;
    end
end

//---------------------------------------------------------------------------------------
//              FSM
//---------------------------------------------------------------------------------------
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
        STA_IDLE        : begin
            if(fall_detect_pulse == 1'b1)
                next_state = STA_RX_START;
            else
                next_state = STA_IDLE;
        end
        
        STA_RX_START    : begin
            if(baund_en == 1'b1) begin
                if(rx_data_bit == 1'b0)
                    next_state = STA_RX_REC_DATA;
                else
                    next_state = STA_IDLE;
            end
            else
                next_state = STA_RX_START;
        end
    
        STA_RX_REC_DATA : begin
            if((bit_cnt == 3'h7) && (baund_en == 1'b1))
                next_state = STA_RX_STOP;
            else
                next_state = STA_RX_REC_DATA;
        end
        
        STA_RX_STOP     : begin
            if(baund_en == 1'b1)
                next_state = STA_IDLE;
            else
                next_state = STA_RX_STOP;
        end
        
        default         : begin
            next_state = STA_IDLE;
        end
    endcase
end

//Output of the next state basing on current state
always @(posedge Clk) begin
    if(Rst == 1'b1) begin
        receiving     <= #TCQ 1'b0;
        bit_cnt       <= #TCQ 3'b0;
        out_data      <= #TCQ 8'b0;
        out_data_vld  <= #TCQ 1'b0;
    end
    else case(curr_state)
        STA_IDLE      : begin
			receiving    <= #TCQ 1'b0;
			bit_cnt      <= #TCQ 3'b0;
			out_data     <= #TCQ 8'b0;
			out_data_vld <= #TCQ 1'b0;
        end
        
        STA_RX_START    : begin
            if((baund_en == 1'b1) && (rx_data_bit == 1'b1))
                receiving   <= #TCQ 1'b0;
			else 
			    receiving   <= #TCQ 1'b1;
        end
    
        STA_RX_REC_DATA : begin
            if(baund_en == 1'b1) begin
                bit_cnt       <= #TCQ bit_cnt + 1'b1;
                out_data[7]   <= #TCQ rx_data_bit;
                out_data[6:0] <= #TCQ out_data[7:1];
            end
        end
        
        STA_RX_STOP     : begin
            if(baund_en == 1'b1) begin
                receiving    <= #TCQ 1'b0;
                bit_cnt      <= #TCQ 3'b0;
                if(rx_data_bit == 1'b1)
                    out_data_vld  <= #TCQ 1'b1;
                else
                    out_data_vld  <= #TCQ 1'b0;
            end
        end
        
        default         : begin
            receiving     <= #TCQ 1'b0;
            bit_cnt       <= #TCQ 3'b0;
            out_data      <= #TCQ 8'b0;
            out_data_vld  <= #TCQ 1'b0;
        end  
    endcase
end

endmodule