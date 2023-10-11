`timescale 1ns / 1ps

module uart #(        
        parameter DATA_BITS = 8, // size data bus uart
        parameter STOP_TICKS = 16
    )(
        input clk, rx, reset,
        output tx,

        // rx
        output  [DATA_BITS - 1:0] rx_fifo_dout, // read rx fifo
        output  rx_fifo_empty,
        input   rx_fifo_rd_en, // read enable rx fifo 

        // tx
        input   [DATA_BITS - 1:0] tx_fifo_din, // entrada a fifo tx
        input   tx_fifo_wr_en, // write enable tx fifo 
    );

    localparam  N = 4, 
                M = 5;

    wire max_tick;
    reg [N - 1:0] q;
   
    wire [DATA_BITS - 1:0]  rx_dout, // salida del rx
                            tx_fifo_dout; // salida de tx fifo 
                            
    wire                    rx_done_tick, // done del rx
                            tx_done_tick, // donde del tx
                            tx_fifo_empty, // flag empty tx fifo
                            
    reg rx_full,
        rx_fifo_empty, 
        tx_full;

    // baudrate generator
    baud_rate_generator 
    # (
        .N(N),
        .M(M) //M = clock / (16 * baud rate)
    )(
        .clk(clk),
        .reset(reset),
        .max_tick(max_tick),
        .q(q)
    );
    
    // modulo de rx
    uart_rx
    # (
        .DATA_BITS(DATA_BITS), 
        .STOP_TICKS(STOP_TICKS)
    )(
        .clk(clk), 
        .reset(rx_reset),
        .rx(rx), 
        .s_tick(max_tick),
        .rx_done_tick(rx_done_tick),
        .o_data(rx_dout)
    );
      
    fifo rx_fifo (
      .clk(clk),      
      .srst(srst),    
      .din(rx_dout),      
      .wr_en(rx_done_tick),
      .rd_en(rx_fifo_rd_en),  
      .dout(rx_fifo_dout),     
      .full(rx_full),     
      .empty(rx_fifo_empty)  
    );
    
    // modulo de tx
    uart_tx 
    #(
        .DATA_BITS(DATA_BITS), 
        .STOP_TICKS(STOP_TICKS)
    )
    (   
        .clk(clk),
        .reset(tx_reset),
        .tx_start(~tx_fifo_empty),
        .s_tick(max_tick),
        .din(tx_fifo_dout),
        .tx_done_tick(tx_done_tick),
        .tx(tx)
    );

    fifo tx_fifo (
      .clk(clk),      
      .srst(srst),    
      .din(tx_fifo_din),
      .wr_en(tx_fifo_wr_en), 
      .rd_en(tx_done_tick), 
      .dout(tx_fifo_dout), 
      .full(tx_full),   
      .empty(tx_fifo_empty) 
    );
   
endmodule
