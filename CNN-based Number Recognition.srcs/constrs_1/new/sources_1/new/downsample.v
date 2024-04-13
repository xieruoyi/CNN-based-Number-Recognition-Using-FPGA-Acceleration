/*
modified 03-28 by Bowen
*/
`timescale 1ns / 1ps

module downsample(
    input clk,
    input arstn,
    input i_start_frame,
    input i_valid,
    input [7:0] i_data,

    output reg [7:0] o_data,
    output reg o_start_frame,
    output reg o_valid
    );
    // counter up to 128
    reg [6:0] col_cnt;
    reg [6:0] row_cnt;

    // col counter logic
    always @(posedge clk or negedge arstn) begin
        if (!arstn)
            col_cnt <= 'd0;
        else if (i_start_frame)
            col_cnt <= 'd0;
        else if (i_valid) begin
            if (col_cnt == 'd111)
                col_cnt <= 'd0;
            else
                col_cnt <= col_cnt + 1;
        end
    end

    // row counter logic
    always @(posedge clk or negedge arstn) begin
        if (!arstn)
            row_cnt <= 'd0;
        else if (i_start_frame)
            row_cnt <= 'd0;
        else if (i_valid && (col_cnt == 'd111)) begin
            if (row_cnt == 'd111)
                row_cnt <= 'd0;
            else
                row_cnt <= row_cnt + 1;
        end
    end

    always @(posedge clk or negedge arstn) begin
        if (!arstn) begin
            o_data <= 'd0;
            o_valid <= 1'b0;
            o_start_frame <= 1'b0;
        end
        else if (i_valid && (col_cnt[1:0] == 2'b11) && (row_cnt[1:0] == 2'b11)) begin
            o_valid <= 1'b1;
            o_data <= i_data;
            o_start_frame <= i_start_frame;    
        end
        else begin
            o_valid <= 1'b0;
            o_start_frame <= i_start_frame;   
        end


    end
endmodule