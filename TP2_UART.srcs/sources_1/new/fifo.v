`timescale 1ns / 1ps

//Ejemplo obtenido de la seccion 4.5.3 del libro
//Listing 4.20
module fifo
    #(
        parameter B=8, W=4
    )(
        input wire i_clk, i_reset,
        input wire i_rd, i_wr,
        input wire [B-1:0] w_data,
        output wire o_empty, o_full,
        output wire [B-1:0] r_data
    );

    reg [B-1:0] array_reg [2**W-1:0]; //array de 2^W elementos, cada uno de tamanio B
    reg [W-1:0] w_ptr_reg, w_ptr_next, w_ptr_succ;
    reg [W-1:0] r_ptr_reg, r_ptr_next, r_ptr_succ;
    reg full_reg, empty_reg, full_next, empty_next;
    wire wr_en;

    always @(posedge i_clk)
        if (wr_en)
            array_reg[w_ptr_reg] <= w_data;
    
    assign r_data = array_reg[r_ptr_reg];
    assign wr_en = i_wr & ~full_reg;

    always @(posedge i_clk, posedge i_reset)
        if (i_reset)
            begin
                w_ptr_reg <= 0;
                r_ptr_next <= 0;
                full_reg <= 1'b0;
                empty_reg <= 1'b1;
            end
        else
            begin
                w_ptr_reg <= w_ptr_next;
                r_ptr_reg <= r_ptr_next;
                full_reg <= full_next;
                empty_reg <= empty_next;
            end

    always @*
        begin
            w_ptr_succ = w_ptr_reg + 1;
            r_ptr_succ = r_ptr_reg + 1;

            w_ptr_next = w_ptr_reg;
            r_ptr_next = r_ptr_reg;
            full_next = full_reg;
            empty_next = empty_reg;

            case ({i_wr, i_rd})
                2'b01: //lectura
                    if (~empty_reg)
                        begin
                        r_ptr_next = r_ptr_succ;
                        full_next = 1'b0;
                        if (r_ptr_succ == w_ptr_reg)
                            empty_next = 1'b1;
                        end
                2'b10: //escritura
                    if (~full_reg)
                        begin
                            w_ptr_next = w_ptr_succ;
                            empty_next = 1'b0;
                            if (w_ptr_succ == r_ptr_reg)
                                full_next = 1'b1;
                        end
                2'b11: //lectura y escritura
                    begin
                        w_ptr_next = w_ptr_succ;
                        r_ptr_next = r_ptr_succ;
                    end
            endcase
        end

    assign o_full = full_reg;
    assign o_empty = empty_reg;

endmodule
