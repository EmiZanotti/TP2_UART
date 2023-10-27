`timescale 1ns / 1ps

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

    //Seniales ALU
    wire [DATA_SIZE - 1:0] w_a; // operando A
    wire [DATA_SIZE - 1:0] w_b; // operando BB
    wire [DATA_SIZE - 1:0] w_op; // operacion

    //Seniales FIFO UART
    wire w_wr; // write
    wire w_full; // tx fifo full 
    wire w_rd; // read
    wire w_empty; // rx fifo empty 

uart uart_unit(
    .clk(i_clk), .reset(i_reset), .r_data(rx_data), .rx_empty(w_empty),
    .rd_uart(w_rd), .rx(rx), .w_data(tx_data), .wr_uart(w_wr), .tx_full(w_full), .tx(tx)
);

interfaz interfaz_alu(
    .clk(i_clk), .reset(i_reset), .rx_fifo_empty(w_empty), .tx_fifo_full(w_full),
    .i_rx_data(rx_data), .i_alu_result(o_data), .o_OP(w_op), .o_A(w_a), .o_B(w_b),
    .o_tx_data(tx_data), .o_rd_fifo_en(w_rd), .o_wr_fifo_en(w_wr)
);

alu alu_unit(
    .i_a(w_a), .i_b(w_b), .i_op(w_op),
    .o_display(o_data), .o_zero(o_zero), .o_carry(o_carry)
);

  
endmodule
