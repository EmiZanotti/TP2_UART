`timescale 1ns / 1ps

module alu #(
        parameter SIZE_OP = 6,
        parameter SIZE_BUS = 8
    )(
        input   [SIZE_BUS - 1:0]    i_a,
        input   [SIZE_BUS - 1:0]    i_b,
        input   [SIZE_OP - 1:0]     i_op,
        output  [SIZE_BUS - 1:0]    o_display, 
        output                      o_zero,
        output                      o_carry
    );
    
    reg [SIZE_BUS : 0]    res;
    assign o_display[SIZE_BUS - 1 : 0] = res[SIZE_BUS - 1 : 0];
    
    localparam ADD  = 6'b100000;
    localparam SUB  = 6'b100010;
    localparam AND  = 6'b100100;
    localparam OR   = 6'b100101;
    localparam XOR  = 6'b100110;
    localparam SRA  = 6'b000011;
    localparam SRL  = 6'b000010;
    localparam NOR  = 6'b000111;
    
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
    
