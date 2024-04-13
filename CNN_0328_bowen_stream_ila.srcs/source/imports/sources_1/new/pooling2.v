`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/15/2024 11:20:46 PM
// Design Name: 
// Module Name: pooling2
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


module pooling2 # (
    

parameter data_width = 16,
parameter weight_width =16,
parameter out_m = 10,

parameter out_n = data_width - out_m,
parameter pool_size = 2
)
(
input clk,
input reset,

input conv_valid,
input [2 * data_width - 1 + 7 : 0] conv_in,


output pool_valid,
output [data_width-1:0] pool_output
);


/////////////////////////////////
// parameters    
////////////////////////////////

/////////////////////////////////
// local param
localparam inmap_size = 8;
localparam outmap_size = inmap_size / pool_size;
localparam reformat_shift = 15 + 12 - out_m;

reg signed [data_width - 1: 0] conv_in_reformat;
reg signed [data_width*2 - 1 + 7: 0] conv_in_tmp;

reg signed [data_width - 1: 0] row_tmp_pool [outmap_size-1:0]; // 8/2 = 4 after pool
reg pool_valid_reg;
reg [data_width - 1 : 0] pool_output_reg;

reg [5:0] col_count;
reg [5:0] row_count;

/////////////////////////////////
// logic    
////////////////////////////////

/////////////////////////////
// fixed point formatting

// input is sum of 100 products of Q1.15 & Q4.12 ==> Q5.27 // TODO: CHANGE!! input shouldnt be Q8.8, it should be Q4.12
// extended to Q12.27 for 39bits of sum width 
// target format :  for shrunk3: Q6.10    // TODO; maybe change to 6:10   


always@(*) begin 
    conv_in_tmp = conv_in >>> reformat_shift;
    // if input is positive and overflows, saturate to max
    if ( conv_in_tmp[data_width*2-1+7] == 0 && conv_in_tmp[data_width*2-1+7:15] != 0 )begin 
        conv_in_reformat = {1'b0,{(data_width-1){1'b1}}};
    end
    else if ( conv_in_tmp[data_width*2-1+7] == 1 && conv_in_tmp[data_width*2-1+7:15] != -1) begin 
        conv_in_reformat = {1'b1,{(data_width-1){1'b0}}};
    end
    else begin 
        conv_in_reformat = {conv_in_tmp[data_width*2-1+7],conv_in_tmp[data_width-2:0]};
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
    
    else if ( col_count == inmap_size-1) begin 
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
    else if ( col_count == inmap_size-1 && row_count == inmap_size-1) begin 
        row_count <= 'b0;
    end
    else if ( col_count == inmap_size-1) begin
        row_count <= row_count + 1;
    end

end

// pooling logic
integer i;
always@(posedge clk) begin 
    if ( reset ) begin 
        for ( i = 0; i < outmap_size; i = i + 1 ) begin
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


endmodule
