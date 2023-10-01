`timescale 1ns / 1ps

//Ejemplo obtenido de la seccion 4.3.2 del libro FPGA Prototyping by Verilog examples
//Listado 4.11

module baud_rate_generator 
    #(
        parameter N = 4, M = 10 //M = clock / (16 * baud rate)
    )(
        input wire clk, reset,
        output wire max_tick,
        output wire [N-1 : 0] q
    );

    reg [N-1 : 0] r_reg;
    wire [N-1 : 0] r_next;

    always @(posedge clk, posedge reset)
        if (reset)
            r_reg <= 0;
        else
            r_reg <= r_next;

    assign r_next = (r_reg == (M-1))? 0 : r_reg + 1;

    assign q = r_reg;
    assign max_rick = (r_reg == M-1) ? 1'b1 : 1'b0;
endmodule
 