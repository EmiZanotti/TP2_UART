`timescale 1ns / 1ps

module alu #(
        parameter SIZE_BUS = 8
    )(
        input   [SIZE_BUS - 1:0]    i_a,
        input   [SIZE_BUS - 1:0]    i_b,
        input   [SIZE_BUS - 1:0]     i_op,
        output  [SIZE_BUS - 1:0]    o_display, 
        output                      o_zero,
        output                      o_carry
    );
    
    reg [SIZE_BUS : 0]    res;
    assign o_display[SIZE_BUS - 1 : 0] = res[SIZE_BUS - 1 : 0];
    
    localparam ADD  = 8'b00100000;
    localparam SUB  = 8'b00100010;
    localparam AND  = 8'b00100100;
    localparam OR   = 8'b00100101;
    localparam XOR  = 8'b00100110;
    localparam SRA  = 8'b00000011;
    localparam SRL  = 8'b00000010;
    localparam NOR  = 8'b00000111;
    
    assign o_zero = ~|o_display;
    assign o_carry = res[SIZE_BUS];
    
    always @(*) begin
        case(i_op) 
            ADD     :   res = i_a + i_b; 
            SUB     :   res = i_a - i_b;
            AND     :   res = i_a & i_b;
            OR      :   res = i_a | i_b;
            XOR     :   res = i_a ^ i_b;
            SRA     :   res = $signed(i_a) >>> i_b;
            SRL     :   res = i_a >> i_b;
            NOR     :   res = ~(i_a | i_b);
            default :   res = {SIZE_BUS{1'b0}};
        endcase
    end
endmodule
    
