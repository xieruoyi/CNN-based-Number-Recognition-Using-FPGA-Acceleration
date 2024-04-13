`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/18/2024 02:08:52 PM
// Design Name: 
// Module Name: pooling1
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


module pooling1 # (
    

    parameter data_width = 16,
    parameter weight_width =16,
    parameter out_m = 12,

    parameter out_n = data_width - out_m,
    parameter pool_size = 2
)
(
    input clk,
    input reset,
    
    input conv_valid,
    input [2 * data_width - 1 + 5 : 0] conv_in,
    
    
    output pool_valid,
    output [data_width-1:0] pool_output
    );
    
    
/////////////////////////////////
// parameters    
////////////////////////////////

/////////////////////////////////
// local param
    localparam reformat_shift = 15 + 8 - out_m;

    reg signed [data_width - 1: 0] conv_in_reformat;
    reg signed [data_width*2 - 1 + 5: 0] conv_in_tmp;

    reg signed [data_width - 1: 0] row_tmp_pool [11:0]; // 24 / 2 = 12 after pool
    reg pool_valid_reg;
    reg [data_width - 1 : 0] pool_output_reg;

    reg [5:0] col_count;
    reg [5:0] row_count;
    
/////////////////////////////////
// logic    
////////////////////////////////

/////////////////////////////
// fixed point formatting

// input is sum of 25 products of Q1.15 & Q8.8 ==> Q9.23
// extended to Q14.23 for 37bits of sum width 
// target format :  for shrunk3: Q4:12        


    always@(*) begin 
        conv_in_tmp = conv_in >>> reformat_shift;
        // if input is positive and overflows, saturate to max
        if ( conv_in_tmp[data_width*2-1+5] == 0 && conv_in_tmp[data_width*2-1+5:15] != 0 )begin 
            conv_in_reformat = {1'b0,{(data_width-1){1'b1}}};
        end
        else if ( conv_in_tmp[data_width*2-1+5] == 1 && conv_in_tmp[data_width*2-1+5:15] != -1) begin 
            conv_in_reformat = {1'b1,{(data_width-1){1'b0}}};
        end
        else begin 
            conv_in_reformat = {conv_in_tmp[data_width*2-1+5],conv_in_tmp[data_width-2:0]};
        end
    end
// fixed point formatting ends here
/////////////////////////////

/////////////////////////////
// pooling logic starts here

    always@(posedge clk) begin 
        if ( reset ) begin 
            col_count <= 'b0;
        end
        
        else if ( col_count == 'd23) begin 
            col_count <= 'b0;
        
        end
        else if ( conv_valid ) begin
            col_count <= col_count + 1;
        end


    end

    always@(posedge clk) begin 
        if ( reset ) begin 
            row_count <= 'b0;
        end
        else if ( col_count == 'd23 && row_count == 'd23) begin 
            row_count <= 'b0;
        end
        else if ( col_count == 'd23) begin
            row_count <= row_count + 1;
        end

    end

    // pooling logic
    integer i;
    always@(posedge clk) begin 
        if ( reset ) begin 
            for ( i = 0; i < 12; i = i + 1 ) begin
                row_tmp_pool[i] <= 'b0;
            end 
        end
        else if ( conv_valid ) begin 
            if ( row_count[0] == 0 ) begin 
                if ( col_count[0] == 0 ) begin 
                    row_tmp_pool[col_count[5:1]] <= conv_in_reformat;
                end
                else begin 
                    row_tmp_pool[col_count[5:1]] <= row_tmp_pool[col_count[5:1]] > conv_in_reformat ? row_tmp_pool[col_count[5:1]] : conv_in_reformat;
                    // print out the comparison 
                    // $display("row_tmp_pool[%d] = %d, conv_in_ref = %d, result: %d\n",col_count[5:1],row_tmp_pool[col_count[5:1]],conv_in_reformat,row_tmp_pool[col_count[5:1]] > conv_in_reformat ? row_tmp_pool[col_count[5:1]] : conv_in_reformat);

                    
                end
            end

            else if (row_count[0] == 1) begin 
                if ( col_count[0] == 0 ) begin 
                    row_tmp_pool[col_count[5:1]] <= row_tmp_pool[col_count[5:1]] > conv_in_reformat ? row_tmp_pool[col_count[5:1]] : conv_in_reformat;
                    //$display("row_tmp_pool[%d] = %d, conv_in_ref = %d, result: %d\n",col_count[5:1],row_tmp_pool[col_count[5:1]],conv_in_reformat,row_tmp_pool[col_count[5:1]] > conv_in_reformat ? row_tmp_pool[col_count[5:1]] : conv_in_reformat);
                    
                end
                else if ( col_count[0] == 1) begin 
                    pool_output_reg <= row_tmp_pool[col_count[5:1]] > conv_in_reformat ? row_tmp_pool[col_count[5:1]] : conv_in_reformat;
                end
            end
        end
    end
    // pooling signal
    always@(posedge clk) begin 
        if ( reset ) begin
            pool_valid_reg <= 'b0;
        end
        else if (row_count[0] == 1 && col_count[0] == 1) begin 
            pool_valid_reg <= 'b1;
        end
        else begin 
            pool_valid_reg <= 'b0;
        end

    end

    assign pool_valid = pool_valid_reg;
    assign pool_output = pool_output_reg;

    /////////////////////////////
    // TODO: verify and refine the signalings of pooling input and output 
    // for now , output only has pool_valid for control , need more to indicate when a new pool has started
    
endmodule
