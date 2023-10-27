`timescale 1ns / 1ps


module interfaz
# (
    parameter INPUT_SIZE = 8
)(
    input clk, reset, rx_fifo_empty, tx_fifo_full,
    input [INPUT_SIZE - 1:0] i_rx_data, i_alu_result,
    output [INPUT_SIZE - 1:0] o_OP, o_A, o_B,
    output [INPUT_SIZE - 1:0] o_tx_data,
    output o_rd_fifo_en, o_wr_fifo_en
);

localparam [2:0]
    idle = 3'b000,
    A = 3'b001,
    B = 3'b010,
    OP = 3'b011,
    cycle = 3'b100,
    send = 3'b101;

reg [INPUT_SIZE - 1:0]  alu_a_data, alu_a_data_next, 
                        alu_b_data, alu_b_data_next,
                        alu_op_data, alu_op_data_next;
reg r_rd_en, r_wr_en;
reg [2:0] state_reg, state_next, state_last, state_last_next;

localparam OP_ADD = 8'b00100000;
localparam OP_SUB = 8'b00100010;
localparam OP_AND = 8'b00100100;
localparam OP_OR  = 8'b00100101;
localparam OP_XOR = 8'b00100110;
localparam OP_SRA = 8'b00000011;
localparam OP_SRL = 8'b00000010;
localparam OP_NOR = 8'b00100111;

always @(posedge clk)
    begin
        if (reset)
            begin
                alu_a_data <= {INPUT_SIZE - 1 {1'b0}};
                alu_b_data <= {INPUT_SIZE - 1 {1'b0}};
                alu_op_data <= {INPUT_SIZE - 1 {1'b0}};
                r_rd_en <= 1'b0;
                state_reg <= idle;
            end
        else
            state_reg <= state_next;
            state_last <= state_last_next;
            if (~rx_fifo_empty)
                begin
                    alu_a_data <= alu_a_data_next;
                    alu_b_data <= alu_b_data_next;
                    alu_op_data <= alu_op_data_next;
                    r_rd_en <= 1'b1;
                end
            else
                r_rd_en <= 1'b0;
    end

always @(*)
    begin        
        alu_a_data_next = alu_a_data;
        alu_b_data_next = alu_b_data;
        alu_op_data_next = alu_op_data;
        state_next = state_reg;
        state_last_next = state_last;
        r_wr_en = 1'b0;
        
        case (state_reg)
            idle:
                if (~rx_fifo_empty)
                begin
                    state_next = A;
                    state_last_next = idle;
                end
            A:
                if (~rx_fifo_empty)
                begin
                    alu_a_data_next = i_rx_data;
                    state_next = cycle;
                    state_last_next = A;
                end
            B:
                if (~rx_fifo_empty)
                begin
                    alu_b_data_next = i_rx_data;
                    state_next = cycle;
                    state_last_next = B;
                end
            OP:
                if (~rx_fifo_empty)
                begin
                    case (i_rx_data)
                        OP_ADD,
                        OP_SUB,
                        OP_AND,
                        OP_OR,
                        OP_XOR,
                        OP_SRA,
                        OP_SRL,
                        OP_NOR:
                            alu_op_data_next = i_rx_data; 
                        default:
                            alu_op_data_next = OP_ADD; 
                    endcase
                    state_next = send;
                    state_last_next = OP;
                end
            cycle:
                case (state_last)
                    A: state_next = B;
                    B: state_next = OP;
                endcase
            send:
                if (~tx_fifo_full)
                begin
                    r_wr_en = 1'b1;
                    state_next = idle;
                    state_last_next = send;
                end
        endcase
    end

assign o_tx_data = i_alu_result;
assign o_rd_fifo_en = r_rd_en;
assign o_wr_fifo_en = r_wr_en;
assign o_OP = alu_op_data;
assign o_A = alu_a_data;
assign o_B = alu_b_data;

endmodule
