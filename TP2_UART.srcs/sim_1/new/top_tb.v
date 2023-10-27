`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/25/2023 01:09:27 PM
// Design Name: 
// Module Name: top_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top_tb;

parameter TICKS      = 16 ;
parameter MOD_COUNT  = 651;
parameter CLK_PERIOD = 20; //ns
parameter DATA_TIME  = TICKS * MOD_COUNT * CLK_PERIOD*3;

localparam DATA_SIZE = 8;
localparam OP_ADD = 8'b00100000;
localparam OP_SUB = 8'b00100010;
localparam OP_AND = 8'b00100100;
localparam OP_OR = 8'b00100101;
localparam OP_XOR = 8'b00100110;
localparam OP_SRA = 8'b00000011;
localparam OP_SRL = 8'b00000010;
localparam OP_NOR = 8'b00100111;

reg i_clk, i_reset, r_wr;
wire i_wr, rx, tx;
wire o_zero, o_carry;
wire [DATA_SIZE - 1:0] o_data, r_data;
reg [DATA_SIZE - 1:0] w_data;

top top_unit(
    .i_clk(i_clk), .i_reset(i_reset), .rx(tx), .tx(rx),
    .o_zero(o_zero), .o_carry(o_carry), .o_data(o_data)
);

uart uart_pc_sim(
    .clk(i_clk), .reset(i_reset), .r_data(r_data), 
    .rx_empty(), .rd_uart(1'b1), .rx(rx),
    .w_data(w_data), .wr_uart(i_wr), .tx_full(), .tx(tx)
);

assign i_wr = r_wr;

initial begin
    i_clk = 1'b0;
    i_reset = 1'b1;
    #DATA_TIME
    i_reset = 1'b0;
    r_wr=1;
    w_data = 8'b00000010;
    #2
    r_wr=0;
    #DATA_TIME
    r_wr=1;
    w_data = 8'b00000001; // 255 representado en hexa de N bits
    #2
    r_wr=0;
    #DATA_TIME 
    r_wr=1;   
    w_data = OP_ADD;
    #2
    r_wr=0;
    #DATA_TIME
    #DATA_TIME
    #DATA_TIME
    #DATA_TIME
    #DATA_TIME
    #DATA_TIME
    $finish;


end
always begin
        #1
        i_clk = ~i_clk;
    end

endmodule
