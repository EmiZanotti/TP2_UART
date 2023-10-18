module alu_top #(
    parameter SIZE_OP = 6,
    parameter SIZE_BUS = 8
)(
    input     [SIZE_BUS - 1:0]    i_input,
    input                       i_a_btn, i_b_btn, i_op_btn, i_clk,
    output    [SIZE_BUS - 1:0]    o_display,
    output                       o_zero, o_carry
);
reg     [SIZE_BUS - 1:0]    A, B;
reg     [SIZE_OP - 1:0]     OP;

always @(posedge i_clk) begin
    A = i_a_btn == 1 ? i_input : A;
    B = i_b_btn == 1 ? i_input : B;
    OP = i_op_btn == 1 ? i_input[SIZE_OP - 1:0] : OP;
end


alu #(
    .SIZE_OP(SIZE_OP),
    .SIZE_BUS(SIZE_BUS)
) u_alu
(
    .i_a(A),
    .i_b(B),
    .i_op(OP),
    .o_display(o_display),
    .o_carry(o_carry),
    .o_zero(o_zero)
);
endmodule