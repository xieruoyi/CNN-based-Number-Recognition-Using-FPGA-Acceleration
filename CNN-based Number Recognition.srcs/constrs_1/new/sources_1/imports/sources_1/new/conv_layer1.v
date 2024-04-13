`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/04/2024 09:40:50 PM
// Design Name: 
// Module Name: conv_layer1
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


module conv_layer1#(

    // Parameters
    parameter KERNEL_COUNT = 4 ,
    parameter DATA_WIDTH = 16,
    parameter WEIGHT_WIDTH = 16,
    parameter KERNEL_SIZE = 5,
    parameter IMAGE_SIZE = 28, 
    parameter IMAGE_DEPTH = 28, 
    parameter WEIGHT_DEPTH = KERNEL_COUNT*KERNEL_SIZE, 
    parameter LAYER1_OUT_M = 12
)
(
    input  clk,
    input  reset,
    input  start_conv,
    input wire [5*DATA_WIDTH-1:0] col_data,
    output conv1_working,
    output wire [5:0] data_addr_col_out,
    output wire [4:0] data_addr_row_out,
    output [DATA_WIDTH-1:0] conv_pool_out,
    output conv_pool_valid

    );
    // to become the top level for conv1+pool
    
    

    

    
    
    ///////////////////////////////////////
    // Signal declarations
    //////////////////////////////////////
    // conv1 pu signals
          
    wire [5*WEIGHT_WIDTH-1:0] col_weight;
    wire [WEIGHT_WIDTH-1:0] kernel1_bias;

    wire [1:0] kernel_count_out;
    wire [4:0] weight_addr_col_out;
    wire [2*DATA_WIDTH-1+5:0] output_data;
    wire output_valid;


    // pool1 signals
    wire [DATA_WIDTH-1:0] pool_data;
    wire pool_valid;
    
    
    
    // Instantiate the conv and pooling
    conv1_pu # (
        .data_width(DATA_WIDTH),
        .weight_width(WEIGHT_WIDTH),
        .kernel_size(KERNEL_SIZE),
        .kernel_total_count(KERNEL_COUNT)
    ) conv1_inst (
        .clk(clk),
        .reset(reset),
        .conv1_start(start_conv),
        .conv_started(conv1_working),
        .col_data(col_data),        //////////////////////// to be wired to a input image ram
        .col_weight(col_weight),
        .kernel_bias(kernel1_bias),
        .data_addr_col_out(data_addr_col_out),
        .data_addr_row_out(data_addr_row_out),
        .weight_addr_col_out(weight_addr_col_out),
        .kernel_count_out(kernel_count_out),
        .output_data_act(output_data),
        .output_valid(output_valid)
    );
    
    pooling1 #(
        .out_m(LAYER1_OUT_M)
    
    ) pool1_inst(
    
        .clk(clk),
        .reset(reset),
    
        .conv_valid(output_valid),
        .conv_in(output_data),
   
    
        .pool_valid(pool_valid),
        .pool_output(pool_data)
    );
    
    
    kernel_l1_roms kernel_l1_rom_inst(
    .clk(clk),
    .reset(reset),
    .bias_addr(kernel_count_out),
    .weight_addr(weight_addr_col_out),
    .weight_row0_out(col_weight[   WEIGHT_WIDTH -1 :               0 ]),
    .weight_row1_out(col_weight[ 2*WEIGHT_WIDTH -1 :    WEIGHT_WIDTH ]),
    .weight_row2_out(col_weight[ 3*WEIGHT_WIDTH -1 :  2*WEIGHT_WIDTH ]),
    .weight_row3_out(col_weight[ 4*WEIGHT_WIDTH -1 :  3*WEIGHT_WIDTH ]),
    .weight_row4_out(col_weight[ 5*WEIGHT_WIDTH -1 :  4*WEIGHT_WIDTH ]),
    .bias_out(kernel1_bias)
    );
    
    assign conv_pool_out = pool_data;
    assign conv_pool_valid = pool_valid;
    // TODO!!: 
    //   1.  a lot of signal width and path checking !!!
    //   2.  decide whether on store pool output using bram ip or just directive instantiation
    //   3.  connect input to a instantiated bram
    //   4.  edit top level constraint file , run synthesis and implementation
    //   5.  get stuff output on vga 
endmodule
