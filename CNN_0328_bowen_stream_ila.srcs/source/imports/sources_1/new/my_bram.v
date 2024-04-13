`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/24/2024 06:18:36 PM
// Design Name: 
// Module Name: my_bram
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


module my_bram#(
    parameter DATA_WIDTH = 16,
    parameter DATA_DEPTH = 12
)(
    input clk,
    input rst,
    input wen,
    input [DATA_WIDTH - 1:0] write_data,
    input [5:0] write_addr,
    input ren,
    input [5:0] read_addr,
    output reg [DATA_WIDTH - 1:0] read_data
    );

    (* ram_style = "block" *) reg [DATA_WIDTH - 1:0] mem [DATA_DEPTH - 1:0];

    always @(posedge clk)
    begin
        if (rst)
            read_data <= 0;
        else
        begin
            if (wen)
            begin
                mem[write_addr] <= write_data;
            end
            if (ren)
            begin
                if (read_addr > DATA_DEPTH -1)
                    read_data <= 'b0;
                else 
                    read_data <= mem[read_addr];
            end
        end
    end
  

endmodule
