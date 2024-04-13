`timescale 1ns / 1ps

/*
0 - 0
1 - 1
2 - 4
3 - 5
*/
module grayscale_rom #(
    parameter DATA_WIDTH = 8,
    parameter FRAME_SIZE = 784 // 28x28
)
 (  

    // system signal
    input clk,
    input arstn,

    // switch signal
    input [1:0] rom_sel,

    // to the CNN
    output wire o_frame_ready,
    input [4:0] i_row_addr,
    input [4:0] i_col_addr,
    output wire [79 : 0] o_data

);

assign o_frame_ready = 1'b1;

reg [DATA_WIDTH-1 : 0] rom0 [0 : FRAME_SIZE-1];
reg [DATA_WIDTH-1 : 0] rom1 [0 : FRAME_SIZE-1];
reg [DATA_WIDTH-1 : 0] rom2 [0 : FRAME_SIZE-1];
reg [DATA_WIDTH-1 : 0] rom3 [0 : FRAME_SIZE-1];

reg [DATA_WIDTH-1 : 0] index_data0;
reg [DATA_WIDTH-1 : 0] index_data1;
reg [DATA_WIDTH-1 : 0] index_data2;
reg [DATA_WIDTH-1 : 0] index_data3;
reg [DATA_WIDTH-1 : 0] index_data4;

assign o_data = {8'h00, index_data4, 8'h00, index_data3,  8'h00, index_data2, 8'h00, index_data1,  8'h00, index_data0 };

// use mem files 
initial begin
    $readmemh("rom0.mem", rom0);
    $readmemh("rom1.mem", rom1);
    $readmemh("rom2.mem", rom2);
    $readmemh("rom3.mem", rom3);
end

// output to CNN logic
always @(posedge clk or negedge arstn) begin
    if (!arstn) begin
        index_data0 <= 'd0;
        index_data1 <= 'd0;
        index_data2 <= 'd0;
        index_data3 <= 'd0;
        index_data4 <= 'd0;
    end
    else begin
        if (i_row_addr < 'd24 && i_col_addr < 'd28) begin

            case (rom_sel)
                2'b00 : begin
                    index_data0 <= rom0[i_row_addr*28 + i_col_addr];
                    index_data1 <= rom0[(i_row_addr+1)*28 + i_col_addr];
                    index_data2 <= rom0[(i_row_addr+2)*28 + i_col_addr];
                    index_data3 <= rom0[(i_row_addr+3)*28 + i_col_addr];
                    index_data4 <= rom0[(i_row_addr+4)*28 + i_col_addr];
                end

                2'b01 : begin
                    index_data0 <= rom1[i_row_addr*28 + i_col_addr];
                    index_data1 <= rom1[(i_row_addr+1)*28 + i_col_addr];
                    index_data2 <= rom1[(i_row_addr+2)*28 + i_col_addr];
                    index_data3 <= rom1[(i_row_addr+3)*28 + i_col_addr];
                    index_data4 <= rom1[(i_row_addr+4)*28 + i_col_addr];
                end

                2'b10 : begin
                    index_data0 <= rom2[i_row_addr*28 + i_col_addr];
                    index_data1 <= rom2[(i_row_addr+1)*28 + i_col_addr];
                    index_data2 <= rom2[(i_row_addr+2)*28 + i_col_addr];
                    index_data3 <= rom2[(i_row_addr+3)*28 + i_col_addr];
                    index_data4 <= rom2[(i_row_addr+4)*28 + i_col_addr];
                end

                default : begin
                    index_data0 <= rom3[i_row_addr*28 + i_col_addr];
                    index_data1 <= rom3[(i_row_addr+1)*28 + i_col_addr];
                    index_data2 <= rom3[(i_row_addr+2)*28 + i_col_addr];
                    index_data3 <= rom3[(i_row_addr+3)*28 + i_col_addr];
                    index_data4 <= rom3[(i_row_addr+4)*28 + i_col_addr];
                end
                
            endcase
        end
        else begin
            index_data0 <= 'd0;
            index_data1 <= 'd0;
            index_data2 <= 'd0;
            index_data3 <= 'd0;
            index_data4 <= 'd0;
        end
    end
end


endmodule