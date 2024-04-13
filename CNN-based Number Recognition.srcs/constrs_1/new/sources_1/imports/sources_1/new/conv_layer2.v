`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/16/2024 01:22:37 AM
// Design Name: 
// Module Name: conv_layer2
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


module conv_layer2#(
    // Parameters
    parameter KERNEL_COUNT = 4 ,
    parameter DATA_WIDTH = 16,
    parameter WEIGHT_WIDTH = 16,
    parameter KERNEL_SIZE = 5,
    parameter IMAP_SIZE = 12, 
    parameter WEIGHT_DEPTH = KERNEL_COUNT*KERNEL_SIZE, 
    parameter LAYER2_OUT_M = 10
)


(
    input  clk,
    input  reset,
    input  start_conv,
    input wire [5*DATA_WIDTH-1:0] col_data_inC0,
    input wire [5*DATA_WIDTH-1:0] col_data_inC1,
    input wire [5*DATA_WIDTH-1:0] col_data_inC2,
    input wire [5*DATA_WIDTH-1:0] col_data_inC3,

    output conv2_working,
    output wire [5:0] data_addr_col_out,
    output wire [4:0] data_addr_row_out,
    output [DATA_WIDTH-1:0] conv_pool_out,
    output conv_pool_valid
    );
    ///////////////////////////////////////
    // Signal declarations
    //////////////////////////////////////
    reg [5*WEIGHT_WIDTH-1:0] col_weight_inC0;      
    reg [5*WEIGHT_WIDTH-1:0] col_weight_inC1;      
    reg [5*WEIGHT_WIDTH-1:0] col_weight_inC2;      
    reg [5*WEIGHT_WIDTH-1:0] col_weight_inC3;      

    reg [WEIGHT_WIDTH-1:0] kernel_bias_reg;

    wire [4:0] kernel_count_out;
    wire [5:0] weight_addr_col_out;
    wire [2*DATA_WIDTH-1+7:0] output_data;
    wire output_valid;


    // pool signals
    wire [DATA_WIDTH-1:0] pool_data;
    wire pool_valid;




    conv2_pu # (
        .DATA_WIDTH      (DATA_WIDTH)    ,
        .WEIGHT_WIDTH    (WEIGHT_WIDTH)  ,
        .KERNEL_SIZE     (KERNEL_SIZE)   ,
        .KERNEL_INC      (KERNEL_COUNT)  ,
        .KERNEL_OUTC     (KERNEL_COUNT)  
    ) conv2_inst (
        .clk(clk),
        .reset(reset),

        .col_data_inC0(col_data_inC0),        //////////////////////// to be wired to a input image ram
        .col_data_inC1(col_data_inC1), 
        .col_data_inC2(col_data_inC2), 
        .col_data_inC3(col_data_inC3), 
        .col_weight_inC0(col_weight_inC0),
        .col_weight_inC1(col_weight_inC1),
        .col_weight_inC2(col_weight_inC2),
        .col_weight_inC3(col_weight_inC3),
        .kernel_bias_inC(kernel_bias_reg),

        .conv2_start(start_conv),
        .conv_started(conv2_working),
        .data_addr_col_out(data_addr_col_out),
        .data_addr_row_out(data_addr_row_out),
        .weight_addr_col_out(weight_addr_col_out),
        .kernel_count_out(kernel_count_out),
        .output_data_act(output_data),
        .output_valid(output_valid)
    );

    pooling2 pool2_inst(
    
        .clk(clk),
        .reset(reset),
    
        .conv_valid(output_valid),
        .conv_in(output_data),
   
    
        .pool_valid(pool_valid),
        .pool_output(pool_data)
    );

    // kernel bram instantiation // block ram not infered due to non-formal HDL coding style to infer bram 
    // (* ram_style = "block" *) reg [WEIGHT_WIDTH-1:0] kernel_bram_inC0[0:KERNEL_SIZE-1][0:WEIGHT_DEPTH-1];
    // (* ram_style = "block" *) reg [WEIGHT_WIDTH-1:0] kernel_bram_inC1[0:KERNEL_SIZE-1][0:WEIGHT_DEPTH-1];
    // (* ram_style = "block" *) reg [WEIGHT_WIDTH-1:0] kernel_bram_inC2[0:KERNEL_SIZE-1][0:WEIGHT_DEPTH-1];
    // (* ram_style = "block" *) reg [WEIGHT_WIDTH-1:0] kernel_bram_inC3[0:KERNEL_SIZE-1][0:WEIGHT_DEPTH-1];     
    (* ram_style = "block" *) reg [WEIGHT_WIDTH-1:0] kernel_bram_inC0[KERNEL_SIZE * WEIGHT_DEPTH - 1:0];
    (* ram_style = "block" *) reg [WEIGHT_WIDTH-1:0] kernel_bram_inC1[KERNEL_SIZE * WEIGHT_DEPTH - 1:0];
    (* ram_style = "block" *) reg [WEIGHT_WIDTH-1:0] kernel_bram_inC2[KERNEL_SIZE * WEIGHT_DEPTH - 1:0];
    (* ram_style = "block" *) reg [WEIGHT_WIDTH-1:0] kernel_bram_inC3[KERNEL_SIZE * WEIGHT_DEPTH - 1:0];     
    (* ram_style = "block" *) reg [WEIGHT_WIDTH-1:0] kernel_bram_bias[0:KERNEL_COUNT-1];

    // initialize kernel bram with readmemb

    initial begin
        $readmemb("conv2_kernel_bram_inC0.mem", kernel_bram_inC0);
        $readmemb("conv2_kernel_bram_inC1.mem", kernel_bram_inC1);
        $readmemb("conv2_kernel_bram_inC2.mem", kernel_bram_inC2);
        $readmemb("conv2_kernel_bram_inC3.mem", kernel_bram_inC3);
        $readmemb("conv2_kernel_bram_bias0.mem", kernel_bram_bias);
//        $readmemb("../../../../memory_initializations/conv2_kernel_bram_inC0.mem", kernel_bram_inC0);
//        $readmemb("../../../../memory_initializations/conv2_kernel_bram_inC1.mem", kernel_bram_inC1);
//        $readmemb("../../../../memory_initializations/conv2_kernel_bram_inC2.mem", kernel_bram_inC2);
//        $readmemb("../../../../memory_initializations/conv2_kernel_bram_inC3.mem", kernel_bram_inC3);
//        $readmemb("../../../../memory_initializations/conv2_kernel_bram_bias0.mem", kernel_bram_bias);
    end

    integer i, j;

    always@(posedge clk) begin 
        if(conv2_working) begin 
            for (i = 0; i < KERNEL_SIZE; i = i + 1) begin 
                if (weight_addr_col_out >= WEIGHT_DEPTH) begin 
                    col_weight_inC0[i*WEIGHT_WIDTH +: WEIGHT_WIDTH] <= 'b0;
                    col_weight_inC1[i*WEIGHT_WIDTH +: WEIGHT_WIDTH] <= 'b0;
                    col_weight_inC2[i*WEIGHT_WIDTH +: WEIGHT_WIDTH] <= 'b0;
                    col_weight_inC3[i*WEIGHT_WIDTH +: WEIGHT_WIDTH] <= 'b0;
                end
                else begin
                    col_weight_inC0[i*WEIGHT_WIDTH +: WEIGHT_WIDTH] <= kernel_bram_inC0[i * WEIGHT_DEPTH + weight_addr_col_out];
                    col_weight_inC1[i*WEIGHT_WIDTH +: WEIGHT_WIDTH] <= kernel_bram_inC1[i * WEIGHT_DEPTH + weight_addr_col_out];
                    col_weight_inC2[i*WEIGHT_WIDTH +: WEIGHT_WIDTH] <= kernel_bram_inC2[i * WEIGHT_DEPTH + weight_addr_col_out];
                    col_weight_inC3[i*WEIGHT_WIDTH +: WEIGHT_WIDTH] <= kernel_bram_inC3[i * WEIGHT_DEPTH + weight_addr_col_out];
                end
            end
        end
    end

    always@(posedge clk) begin 
        if (conv2_working) begin 
            if (weight_addr_col_out >= WEIGHT_DEPTH)  
                kernel_bias_reg <= 'b0;
            else 
                kernel_bias_reg <= kernel_bram_bias[kernel_count_out];
        end

    end
//     always@(posedge clk) begin 

//         if (reset) begin 
//             for (i = 0 ; i < KERNEL_SIZE; i = i + 1) begin 
//                 col_weight_inC0[i*WEIGHT_WIDTH +: WEIGHT_WIDTH] <= 'b0;
//                 col_weight_inC1[i*WEIGHT_WIDTH +: WEIGHT_WIDTH] <= 'b0;
//                 col_weight_inC2[i*WEIGHT_WIDTH +: WEIGHT_WIDTH] <= 'b0;
//                 col_weight_inC3[i*WEIGHT_WIDTH +: WEIGHT_WIDTH] <= 'b0;
//             end
//             kernel_bias_reg <= 'b0;
//         end
//         else if(conv2_working) begin 
//             if (weight_addr_col_out >= WEIGHT_DEPTH) begin 
//                 for (i = 0; i < KERNEL_SIZE; i = i + 1)begin 
//                     col_weight_inC0[i*WEIGHT_WIDTH +: WEIGHT_WIDTH] <= 'b0;
//                     col_weight_inC1[i*WEIGHT_WIDTH +: WEIGHT_WIDTH] <= 'b0;
//                     col_weight_inC2[i*WEIGHT_WIDTH +: WEIGHT_WIDTH] <= 'b0;
//                     col_weight_inC3[i*WEIGHT_WIDTH +: WEIGHT_WIDTH] <= 'b0;

//                 end
//             end
//             else begin 
//                 for (i = 0; i < KERNEL_SIZE; i = i + 1) begin 
//                     col_weight_inC0[i*WEIGHT_WIDTH +: WEIGHT_WIDTH] <= kernel_bram_inC0[i * WEIGHT_DEPTH + weight_addr_col_out];
//                     col_weight_inC1[i*WEIGHT_WIDTH +: WEIGHT_WIDTH] <= kernel_bram_inC1[i * WEIGHT_DEPTH + weight_addr_col_out];
//                     col_weight_inC2[i*WEIGHT_WIDTH +: WEIGHT_WIDTH] <= kernel_bram_inC2[i * WEIGHT_DEPTH + weight_addr_col_out];
//                     col_weight_inC3[i*WEIGHT_WIDTH +: WEIGHT_WIDTH] <= kernel_bram_inC3[i * WEIGHT_DEPTH + weight_addr_col_out];
//                 end
//                 kernel_bias_reg <= kernel_bram_bias[kernel_count_out];
//             end
//         end
//     end
    

    assign conv_pool_out = pool_data;
    assign conv_pool_valid = pool_valid;
endmodule
