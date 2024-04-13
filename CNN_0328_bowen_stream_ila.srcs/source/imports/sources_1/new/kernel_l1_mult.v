`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/10/2024 10:59:00 PM
// Design Name: 
// Module Name: kernel_l1_mult
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


module kernel_l1_mult #(

    parameter data_width = 16,
    parameter weight_width = 16
)

(

    input clk,
    input reset,
    
    input [5*data_width - 1 :0] col_data_0,
    input [5*data_width - 1 :0] col_data_1,
    input [5*data_width - 1 :0] col_data_2,
    input [5*data_width - 1 :0] col_data_3,
    input [5*data_width - 1 :0] col_data_4,
                 
    input [5*weight_width - 1 : 0] row_weights_0,
    input [5*weight_width - 1 : 0] row_weights_1,
    input [5*weight_width - 1 : 0] row_weights_2,
    input [5*weight_width - 1 : 0] row_weights_3,
    input [5*weight_width - 1 : 0] row_weights_4,
    input [weight_width - 1 : 0] kernel_bias,
    
    output [2*data_width - 1 + 5: 0] out_data

    );
    
    wire [5*data_width - 1 : 0] data_matrix[4:0];
    wire [5*weight_width - 1 : 0] weight_matrix[4:0];
    
    wire signed [2*data_width-1+5:0] kernel_bias_extended;
    wire signed [2*data_width-1 : 0] out_products[4:0][4:0];
    wire signed [2*data_width-1 + 5 : 0] out_kernel_sum;
    
    reg signed [2*data_width - 1 + 5 : 0 ] out_data_reg; // width +5 as it can contain at most 32x bigger number, 
    
    genvar i,j; 
    generate 
    for ( i = 0; i < 5; i = i + 1) begin: loop
    
        assign data_matrix[i] = {
                                    col_data_4[i*data_width+:data_width],
                                    col_data_3[i*data_width+:data_width],
                                    col_data_2[i*data_width+:data_width],
                                    col_data_1[i*data_width+:data_width],
                                    col_data_0[i*data_width+:data_width]
                                    
                                 };
     end
     endgenerate
     
     assign weight_matrix[0] =    row_weights_0; 
     assign weight_matrix[1] =    row_weights_1; 
     assign weight_matrix[2] =    row_weights_2; 
     assign weight_matrix[3] =    row_weights_3; 
     assign weight_matrix[4] =    row_weights_4;
     
     generate
     for (i = 0; i < 5; i = i + 1) begin : row_loop
        for (j = 0; j < 5; j = j + 1) begin : col_loop
            dsp_mult_blk mult_unit (
              .CLK(clk),  // input wire CLK
              .A(data_matrix[i][ j*data_width +: data_width]),      // input wire [15 : 0] A
              .B(weight_matrix[i][ j*weight_width +: weight_width]),      // input wire [15 : 0] B
              .P(out_products[i][j])      // output wire [31 : 0] P
            );
        end
    end
    endgenerate
    
    

    reg signed [2*data_width-1 + 5: 0] partial_sums_reg[4:0];
    integer cnt;
    always@(posedge clk) begin 
        if (reset) begin 
            for ( cnt = 0; cnt < 5; cnt = cnt + 1) begin 
                partial_sums_reg[cnt] <= 'b0;
            end
        end
        
        else begin 
            for ( cnt = 0; cnt < 5; cnt = cnt + 1) begin 
                partial_sums_reg[cnt] <=     out_products[cnt][0] 
                                        +   out_products[cnt][1] 
                                        +   out_products[cnt][2] 
                                        +   out_products[cnt][3] 
                                        +   out_products[cnt][4] ;
            end          
        end
    end
    
//    wire signed [2*data_width-1 + 5:0] partial_sums[4:0];
//    generate
//    for (i = 0; i < 5; i = i + 1) begin : partial_sum_loop
//        assign partial_sums[i] =    out_products[i][0] 
//                                +   out_products[i][1] 
//                                +   out_products[i][2] 
//                                +   out_products[i][3] 
//                                +   out_products[i][4] ;
//        // same as above, functionality wise
//        // assign partial_sums[i] =    {{5{out_products[i][0][ 2*data_width-1 ]}},out_products[i][0]} 
//        //                         +   {{5{out_products[i][1][ 2*data_width-1 ]}},out_products[i][1]} 
//        //                         +   {{5{out_products[i][2][ 2*data_width-1 ]}},out_products[i][2]} 
//        //                         +   {{5{out_products[i][3][ 2*data_width-1 ]}},out_products[i][3]} 
//        //                         +   {{5{out_products[i][4][ 2*data_width-1 ]}},out_products[i][4]} ;
//    end
//    endgenerate
    //    assign out_kernel_sum = partial_sums[0] + partial_sums[1] + partial_sums[2] + partial_sums[3] + partial_sums[4] + kernel_bias_extended;

    // 37 - 16-8
    assign kernel_bias_extended = {{(13){kernel_bias[weight_width-1]}},kernel_bias,{8{1'b1}}};
    
    
    
    assign out_kernel_sum = partial_sums_reg[0] + partial_sums_reg[1] + partial_sums_reg[2] + partial_sums_reg[3] + partial_sums_reg[4] + kernel_bias_extended;

    
//    always@(posedge clk) begin 
//        if ( reset ) begin 
//            out_data_reg <= 'b0;
//        end
        
//        else begin 
//            out_data_reg <= out_kernel_sum;
//        end
        
//    end
    
//    assign out_data = out_data_reg;
    assign out_data = out_kernel_sum;
    
endmodule
