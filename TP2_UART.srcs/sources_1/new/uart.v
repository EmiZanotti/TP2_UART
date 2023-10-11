`timescale 1ns / 1ps

module uart #(        
        parameter DATA_BITS = 8, // size data bus uart
                  STOP_TICKS = 16,
                  DIVISOR = 651,
                  DIVISOR_BIT = 10,
                  FIFO_W = 4
    )(
        input clk, reset,

        // rx
        output  [DATA_BITS - 1:0] rx_dout, // data rx
        output  rx_empty,                  // rx vacio
        input   rd_uart, rx,                // bit de lectura

        // tx
        input   [DATA_BITS - 1:0] tx_din, // data entrada tx
        input   wr_uart,                   // write enable
        output  tx_full, tx
    );

    wire tick, rx_done_tick, tx_done_tick;
    wire tx_empty, tx_fifo_not_empty;
    wire [DATA_BITS - 1:0] tx_fifo_out, rx_data_out;

    // baudrate generator
    baud_rate_generator 
    # (
        .N(DIVISOR_BIT),
        .M(DIVISOR) //M = clock / (16 * baud rate)
    ) baud_gen_unit (
        .clk(clk),
        .reset(reset),
        .max_tick(tick),
        .q()
    );
    
    // modulo de rx
    uart_rx
    # (
        .DATA_BITS(DATA_BITS), 
        .STOP_TICKS(STOP_TICKS)
    ) uart_rx_unit (
        .clk(clk), 
        .reset(rx_reset),
        .rx(rx), 
        .s_tick(max_tick),
        .rx_done_tick(rx_done_tick),
        .o_data(rx_dout)
    );
    
    fifo
    # (
        .B(DATA_BITS), .w(FIFO_W)
    ) fifo_rx_unit (
        .i_clk(clk), .i_reset(reset), .i_rd(rd_uart),
        .i_wr(rx_done_tick), .w_data(rx_data_out),
        .o_empty(rx_empty), .o_full(), .r_data(r_data)
    );
    
    // modulo de tx
    uart_tx 
    #(
        .DATA_BITS(DATA_BITS), 
        .STOP_TICKS(STOP_TICKS)
    ) uart_tx_unit (   
        .clk(clk),
        .reset(reset),
        .tx_start(tx_fifo_not_empty),
        .s_tick(tick),
        .din(tx_fifo_out),
        .tx_done_tick(tx_done_tick),
        .tx(tx)
    );

    fifo
    # (
        .B(DATA_BITS), .w(FIFO_W)
    ) fifo_tx_unit (
        .i_clk(clk), .i_reset(reset), .i_rd(tx_done_tick),
        .i_wr(wr_uart), .w_data(w_data),
        .o_empty(tx_empty), .o_full(tx_full), .r_data(tx_fifo_out)
    );
   
   assign tx_fifo_not_empty = ~tx_empty;
endmodule
