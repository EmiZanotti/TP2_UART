`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/13/2023 05:29:40 PM
// Design Name: 
// Module Name: top
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


module top # (
    parameter DATA_SIZE = 8
)(
        input i_clk, i_reset,
        input rx,
        output tx, o_zero, o_carry,
        output [DATA_SIZE - 1:0] o_data
);

    wire [DATA_SIZE - 1:0] rx_data; //Datos recibidos
    wire [DATA_SIZE - 1:0] tx_data; //Datos a transmitir
    wire [DATA_SIZE - 1:0] alu_data; //Datos de entrada a ALU

    //Seniales ALU
    wire w_a;
    wire w_b;
    wire w_op;
    wire w_carry_bit;
    wire w_zero_bit;

    //Seniales FIFO UART
    wire w_wr;
    wire w_full;
    wire w_rd;
    wire w_empty;

uart uart_unit(
    .clk(i_clk), .reset(i_reset), .r_data(rx_data), .rx_empty(w_empty),
    .rd_uart(w_rd), .rx(rx), .w_data(tx_data), .wr_uart(w_wr), .tx_full(w_full), .tx(tx)
);

interfaz_rx interfaz_rx_alu(
    .clk(i_clk), .reset(i_reset), .rx_fifo_empty(w_empty), .i_rx_data(rx_data), .o_OP(w_op),
    .o_A(w_a), .o_B(w_b), .o_alu_data(alu_data), .o_rd_fifo_en(w_rd)
);

alu_top alu_unit(
    .i_input(alu_data), .i_a_btn(w_a), .i_b_btn(w_b), .i_op_btn(w_op), .i_clk(i_clk),
    .o_display(o_data), .o_zero(o_zero), .o_carry(o_carry)
);
endmodule
