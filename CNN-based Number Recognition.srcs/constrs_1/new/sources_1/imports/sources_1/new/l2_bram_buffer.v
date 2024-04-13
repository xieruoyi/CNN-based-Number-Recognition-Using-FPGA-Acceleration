`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/24/2024 06:17:06 PM
// Design Name: 
// Module Name: l2_bram_buffer
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module l1_bram_buffer#(
    parameter DATA_WIDTH = 16,
    parameter KERNEL_SIZE = 5
)(
    input clk,
    input rst,
    input wen,
    input [DATA_WIDTH - 1:0] write_data,
    
    input conv_working,
    output reg data_ready,
    input [4:0] read_row_addr,
    input [5:0] read_col_addr,
    output [ DATA_WIDTH * KERNEL_SIZE - 1 : 0] out_data_inC0,
    output [ DATA_WIDTH * KERNEL_SIZE - 1 : 0] out_data_inC1,
    output [ DATA_WIDTH * KERNEL_SIZE - 1 : 0] out_data_inC2,
    output [ DATA_WIDTH * KERNEL_SIZE - 1 : 0] out_data_inC3

    );
    integer i, j, k;
    localparam inC_cnt = 4;
    localparam inC_size = 12;

    reg [inC_size * inC_cnt - 1 : 0] wen_inC;
    reg [5:0] write_row_addr;
    reg [5:0] write_col_addr;    

    reg [inC_size - 1 : 0] ren_inC [inC_cnt - 1 : 0];
    wire [DATA_WIDTH-1:0] read_ram_data[inC_cnt - 1 : 0][inC_size - 1 : 0];


    reg [ DATA_WIDTH * KERNEL_SIZE - 1 : 0] out_data_reg[3:0];



    // write data to the buffer
    always@(posedge clk) begin
        if (rst) begin 
            write_row_addr <= 0;
            write_col_addr <= 0;
            data_ready <= 0;
            wen_inC <= 'b1;
        end
        else if (wen) begin
            if (write_row_addr == inC_cnt * inC_size - 1 && write_col_addr == inC_size - 1) begin
                write_row_addr <= 0;
                write_col_addr <= 0;
                data_ready <= 'b1;
                wen_inC <= 'b1;
            end
            else if (write_col_addr == inC_size - 1) begin
                write_row_addr <= write_row_addr + 1;
                write_col_addr <= 0;
                wen_inC <= wen_inC << 1;
            end
            else begin
                write_col_addr <= write_col_addr + 1;
                data_ready <= 0;
            end

        end
        else 
            data_ready <= 'b0;
            
    end

    // read data from the buffer
    always@(*) begin 
        if (conv_working) begin
            for ( i = 0; i < inC_cnt; i = i + 1) begin
                for ( j = 0; j < KERNEL_SIZE; j = j + 1) begin
                    // ren_inC[i][read_row_addr + j] <= 1'b1;
                    if (read_row_addr > 'd11)
                        out_data_reg[i][j * DATA_WIDTH +: DATA_WIDTH] = 'd0;
                    else 
                        out_data_reg[i][j * DATA_WIDTH +: DATA_WIDTH] = read_ram_data[i][read_row_addr + j];
                end
            end
        end

    end



    genvar m,n;
    generate
        for (m = 0; m < inC_cnt ; m = m + 1) begin : inC
            for (n = 0; n < inC_size; n = n + 1) begin : inC_n
                my_bram #(
                    .DATA_WIDTH(DATA_WIDTH),
                    .DATA_DEPTH(inC_size)
                ) bram_inst(
                    .clk(clk),
                    .rst(rst),
                    .wen(wen_inC[m*inC_size + n]),
                    .write_data(write_data),
                    .write_addr(write_col_addr),
                    .ren(1'b1),
                    .read_addr(read_col_addr),
                    .read_data(read_ram_data[m][n])
                );
            end
        end
    endgenerate


    assign out_data_inC0 = out_data_reg[0];
    assign out_data_inC1 = out_data_reg[1];
    assign out_data_inC2 = out_data_reg[2];
    assign out_data_inC3 = out_data_reg[3];
endmodule
