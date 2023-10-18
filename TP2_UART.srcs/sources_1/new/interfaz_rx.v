`timescale 1ns / 1ps


module interfaz_rx
# (
    parameter INPUT_SIZE = 8
)(
    input clk, reset, rx_fifo_empty,
    input [INPUT_SIZE - 1:0] i_rx_data,
    output o_OP, o_A, o_B,
    output [INPUT_SIZE - 1:0] o_alu_data,
    output o_rd_fifo_en
);

localparam [1:0]
    idle = 2'b00,
    A = 2'b01,
    B = 2'b10,
    OP = 2'b11;

reg [INPUT_SIZE - 1:0] r_data;
reg [INPUT_SIZE - 1:0] r_data_next;
reg [2:0] alu_params, alu_params_next;
reg r_rd_en;
reg [1:0] state_reg, state_next;

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
                alu_params <= 3'b0;
                r_data <= 8'd0;
                r_rd_en <= 1'd0;
            end
        else
            state_reg <= state_next;
            if (~rx_fifo_empty)
                begin
                    r_rd_en <= 1'd1;
                    alu_params <= alu_params_next;
                    r_data <= r_data_next;
                end
        
    end
always @(*)
    begin
        r_data_next = r_data;
        state_next = state_reg;
        alu_params_next = alu_params;
        case (state_reg)
            idle:
                if (~rx_fifo_empty)
                begin
                    state_next = A;
                    alu_params_next = 3'b100;
                end
            A:
                if (~rx_fifo_empty)
                begin
                    r_data_next = i_rx_data;
                    state_next = B;
                end
            B:
                if (~rx_fifo_empty)
                begin
                    alu_params_next = 3'b010;
                    r_data_next = i_rx_data;
                end
            OP:
                if (~rx_fifo_empty)
                begin
                    alu_params_next = 3'b001;
                    case (i_rx_data)
                        OP_ADD,
                        OP_SUB,
                        OP_AND,
                        OP_OR,
                        OP_XOR,
                        OP_SRA,
                        OP_SRL,
                        OP_NOR:
                            r_data_next = i_rx_data; 
                        default:
                            r_data_next = OP_ADD; 
                    endcase
                    state_next = idle;
                end
        endcase
    end

assign o_alu_data = r_data;
assign o_rd_fifo_en = r_rd_en;
assign o_OP = alu_params[2];
assign o_A = alu_params[0];
assign o_B = alu_params[1];

endmodule
