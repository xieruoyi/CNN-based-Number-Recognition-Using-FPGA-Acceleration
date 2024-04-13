`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/17/2024 11:16:40 PM
// Design Name: 
// Module Name: CNN_pu
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


module CNN_pu#(
    parameter DATA_WIDTH = 16


)(

    input clk,
    input reset,
    
    input conv1_start,
    input [5*DATA_WIDTH-1:0] col_data,
    output conv1_working,
    output [5:0] data_addr_col_out,
    output [4:0] data_addr_row_out,

    output CNN_out_valid,
    output [10 * DATA_WIDTH-1:0] CNN_out_data


    );
    localparam KERNEL_SIZE = 5;

    localparam l1_INC_COUNT = 1 ;
    localparam l1_OUTC_COUNT = 4 ;
    localparam l2_INC_COUNT = 4 ;
    localparam l2_OUTC_COUNT = 4 ;

    ///////////////////////////////////////
    // Signal declarations
    //////////////////////////////////////
    integer i,j,k; 

    // layer 1 module signals
    // some of the signals moved to input/output section 
    wire [DATA_WIDTH-1:0] pool_data;
    wire pool_valid;



    // layer 1 buffer signals
//    (* ram_style = "distributed" *) reg [DATA_WIDTH-1:0] l1_output_buffer [l1_OUTC_COUNT-1:0][0:11][0:11]; // (28-5+1)/2 = 12 => 12 x 12 BRAM x 4
//    reg [4:0]l1_buffer_row, l1_buffer_col;
//    reg [2:0]l1_buffer_channel;
    wire l1_buffer_data_ready;

    // reg [9:0] l1_buffer_addr;

    // layer 2 module signals
    // (* ram_style = "block" *)
    wire [5 * DATA_WIDTH - 1:0] col_data_inC [l2_INC_COUNT-1:0];
    wire conv2_working;
    wire [5:0]  data_addr_col_out_l2;
    wire [4:0]  data_addr_row_out_l2;
    wire [DATA_WIDTH-1:0] pool_data_l2;
    wire pool_valid_l2;


    // layer 2 buffer signals
    (* ram_style = "distributed" *) reg [DATA_WIDTH-1:0] l2_output_buffer [l2_OUTC_COUNT-1:0][0:15]; // (12-5+1)/2 = 4 x 4 BRAM x 4
    reg [3:0]l2_buffer_col;
    reg [2:0]l2_buffer_channel;
    reg l2_buffer_data_ready;

    // fc layer signals
    reg [DATA_WIDTH-1:0] fc_in_data [l2_OUTC_COUNT-1:0];
    wire fc_working;
    wire [5:0] fc_data_addr_out;
    wire fc_out_valid;
    wire [10 * DATA_WIDTH-1:0] fc_out_data;

    ///////////////////////////////////////
    // layer 1 module instantiation
    //////////////////////////////////////
    conv_layer1 #(

        .KERNEL_COUNT (4) ,
        .DATA_WIDTH (16),
        .WEIGHT_WIDTH (16),
        .KERNEL_SIZE (5),
        .IMAGE_SIZE (28), 
        .IMAGE_DEPTH (28)
        )
     conv_layer1_dut
    (
        .clk(clk),
        .reset(reset),
        .start_conv(conv1_start),
        .col_data(col_data),
        .conv1_working(conv1_working),
        .data_addr_col_out(data_addr_col_out),
        .data_addr_row_out(data_addr_row_out),
        .conv_pool_out(pool_data),
        .conv_pool_valid(pool_valid)
    );

    ///////////////////////////////////////
    // layer 1 output buffer 
    //////////////////////////////////////


    ////// bram receiver side 
    // data write

//    always @(posedge clk) begin
//        if (reset) begin
//            l1_buffer_row <= 0;
//            l1_buffer_col <= 0;
//            l1_buffer_channel <= 0;
//            // reset pool_data_ram
//            for ( k = 0; k < l1_OUTC_COUNT; k = k + 1) begin
//                for (i = 0; i < 12; i = i + 1) begin
//                    for (j = 0; j < 12; j = j + 1) begin
//                        l1_output_buffer[k][i][j] <= 0;
//                    end
//                end
//            end
//        end else if (pool_valid) begin
//            l1_output_buffer[l1_buffer_channel][l1_buffer_row][l1_buffer_col] <= pool_data;
//            if (l1_buffer_channel == l1_OUTC_COUNT-1 
//                && l1_buffer_row == 11 
//                && l1_buffer_col == 11) begin

//                    l1_buffer_data_ready <= 1;
//                    l1_buffer_row <= 0;
//                    l1_buffer_col <= 0;
//                    l1_buffer_channel <= 0;
//            end
//            else begin
//                if (l1_buffer_row == 11 && l1_buffer_col == 11) begin
//                    // Reset for next pool_out iteration
//                    l1_buffer_row <= 0;
//                    l1_buffer_col <= 0;
//                    l1_buffer_channel <= l1_buffer_channel + 1;
//                end
//                else if (l1_buffer_col == 11) begin
//                    // Move to the next row and reset col
//                    l1_buffer_col <= 0;
//                    l1_buffer_row <= l1_buffer_row + 1;
//                end
//                else begin
//                    // Increment col only if not at the end of a row or simulation
//                    l1_buffer_col <= l1_buffer_col + 1;
//                end
//            end
//        end
//        else begin
//            l1_buffer_data_ready <= 0; // bring it down for a pulse 
//        end
//    end


    // bram sender side
//    always @(posedge clk) begin
//        if (reset) begin
//            col_data_inC[0] <= 0;
//            col_data_inC[1] <= 0;
//            col_data_inC[2] <= 0;
//            col_data_inC[3] <= 0;

//        end else if (conv2_working) begin
//            // read from l1_output_buffer
//            for (j = 0; j < l2_INC_COUNT; j = j + 1) begin
//                for (i = 0; i < KERNEL_SIZE; i = i + 1) begin
//                    if (data_addr_col_out_l2 > 'd11)
//                        col_data_inC[j][i*DATA_WIDTH +: DATA_WIDTH] <= 'b0; 
//                        // to mimic address reading interface, which will handle all out of range address read
//                    else 
//                        col_data_inC[j][i*DATA_WIDTH +: DATA_WIDTH] <= l1_output_buffer[j][data_addr_row_out_l2+i][data_addr_col_out_l2];// send a col of 5 each tick
//        //                     col_data_inC[j][i*DATA_WIDTH +: DATA_WIDTH] <= (data_addr_row_out_l2+1)<<8;
//                end
//            end
//        end
//    end


    l1_bram_buffer #(
        .DATA_WIDTH(16),
        .KERNEL_SIZE(5)
    
    ) l1_buffer_inst (
         .clk(clk),
         .rst(reset),
         .wen(pool_valid),
         .write_data(pool_data),
        
        .conv_working(conv2_working),
        .data_ready(l1_buffer_data_ready),
        .read_row_addr(data_addr_row_out_l2),
        .read_col_addr(data_addr_col_out_l2),
        .out_data_inC0(col_data_inC[0]),
        .out_data_inC1(col_data_inC[1]),
        .out_data_inC2(col_data_inC[2]),
        .out_data_inC3(col_data_inC[3])
    
    
    );


    ///////////////////////////////////////
    // end of layer 1 buffer
    //////////////////////////////////////



    ///////////////////////////////////////
    // layer 2 module instantiation
    //////////////////////////////////////

    conv_layer2 #(
        .KERNEL_COUNT (4) ,
        .DATA_WIDTH (16),
        .WEIGHT_WIDTH (16),
        .KERNEL_SIZE (5),
        .IMAP_SIZE (12)
        )
     conv_layer2_dut
    (
        .clk(clk),
        .reset(reset),
        .start_conv(l1_buffer_data_ready),
        .col_data_inC0(col_data_inC[0]),
        .col_data_inC1(col_data_inC[1]),
        .col_data_inC2(col_data_inC[2]),
        .col_data_inC3(col_data_inC[3]),
        .conv2_working(conv2_working),
        .data_addr_col_out(data_addr_col_out_l2),
        .data_addr_row_out(data_addr_row_out_l2),
        .conv_pool_out(pool_data_l2),
        .conv_pool_valid(pool_valid_l2)
    );

    ///////////////////////////////////////
    // end of layer 2 module instantiation
    //////////////////////////////////////

    ///////////////////////////////////////
    // layer 2 output buffer
    ///////////////////////////////////////

    // bram receiver side
    always @(posedge clk) begin
        if (reset) begin
            l2_buffer_col <= 0;
            l2_buffer_channel <= 0;
            // reset buffer
            for ( k = 0; k < l2_OUTC_COUNT; k = k + 1) begin
                for (i = 0; i < 16; i = i + 1) begin
                    l2_output_buffer[k][i] <= 0;
                end
            end
        end else if (pool_valid_l2) begin
            l2_output_buffer[l2_buffer_channel][l2_buffer_col] <= pool_data_l2;
            if (l2_buffer_channel == l2_OUTC_COUNT-1 
                && l2_buffer_col == 15) begin

                    l2_buffer_data_ready <= 1;
                    l2_buffer_col <= 0;
                    l2_buffer_channel <= 0;
            end
            else begin
                if (l2_buffer_col == 15) begin
                    // Move to the next row and reset col
                    l2_buffer_col <= 0;
                    l2_buffer_channel <= l2_buffer_channel + 1;
                end
                else begin
                    // Increment col only if not at the end of a row or simulation
                    l2_buffer_col <= l2_buffer_col + 1;
                end
            end
        end
        else begin
            l2_buffer_data_ready <= 0; // bring it down for a pulse 
        end
    end

    // bram sender side
    always@(posedge clk) begin 

        if (reset) begin 
            for ( i = 0; i < l2_OUTC_COUNT; i = i + 1 ) begin
                fc_in_data[i] <= 0;
            end 
        end
        else if ( fc_working ) begin 
            for ( i = 0; i < l2_OUTC_COUNT; i = i + 1 ) begin
                if ( fc_data_addr_out < 16) begin

                    fc_in_data[i] <= l2_output_buffer[i][fc_data_addr_out];
                end 
                else 
                    fc_in_data[i] <= 0;
            end
        end
    end
    ///////////////////////////////////////
    // fc layer module instantiation
    //////////////////////////////////////
    fc_layer #(
        .DATA_WIDTH (16),
        .WEIGHT_WIDTH (16)
        )
     fc_layer_dut
    (
        .clk(clk),
        .reset(reset),
        .in_data_0(fc_in_data[0]),
        .in_data_1(fc_in_data[1]),
        .in_data_2(fc_in_data[2]),
        .in_data_3(fc_in_data[3]),
        .fc_start(l2_buffer_data_ready),
        .fc_working(fc_working),
        .data_addr_out(fc_data_addr_out),
        .out_valid(fc_out_valid),
        .out_data(fc_out_data)
    );

    ///////////////////////////////////////
    assign CNN_out_valid = fc_out_valid;
    assign CNN_out_data = fc_out_data;



endmodule
