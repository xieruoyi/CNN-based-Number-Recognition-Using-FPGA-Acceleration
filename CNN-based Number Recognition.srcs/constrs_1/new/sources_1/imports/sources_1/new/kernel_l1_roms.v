`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/06/2024 12:23:10 AM
// Design Name: 
// Module Name: kernel_l1_roms
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


module kernel_l1_roms(
    input clk,
    input reset,
    input [1:0] bias_addr,
    input [4:0] weight_addr,
    output [15:0] weight_row0_out,
    output [15:0] weight_row1_out,
    output [15:0] weight_row2_out,
    output [15:0] weight_row3_out,
    output [15:0] weight_row4_out,
    output [15:0] bias_out
    );
    
    kernel_l1_rom0 rom0 (
      .clka(clk),    // input wire clka
      .addra(weight_addr),  // input wire [4 : 0] addra
      .douta(weight_row0_out)  // output wire [15 : 0] douta
    );
    
    kernel_l1_rom1 rom1 (
      .clka(clk),    // input wire clka
      .addra(weight_addr),  // input wire [4 : 0] addra
      .douta(weight_row1_out)  // output wire [15 : 0] douta
    );
    
    kernel_l1_rom2 rom2 (
      .clka(clk),    // input wire clka
      .addra(weight_addr),  // input wire [4 : 0] addra
      .douta(weight_row2_out)  // output wire [15 : 0] douta
    );
    kernel_l1_rom3 rom3 (
      .clka(clk),    // input wire clka
      .addra(weight_addr),  // input wire [4 : 0] addra
      .douta(weight_row3_out)  // output wire [15 : 0] douta
    );
    kernel_l1_rom4 rom4 (
      .clka(clk),    // input wire clka
      .addra(weight_addr),  // input wire [4 : 0] addra
      .douta(weight_row4_out)  // output wire [15 : 0] douta
    );
    kernel_l1_rom_bias bias_rom (
      .clka(clk),    // input wire clka
      .addra(bias_addr),  // input wire [1 : 0] addra
      .douta(bias_out)  // output wire [15 : 0] douta
    );
endmodule
