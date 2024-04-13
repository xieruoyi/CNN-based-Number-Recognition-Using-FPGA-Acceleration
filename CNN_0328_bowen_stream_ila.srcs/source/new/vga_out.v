/*
modified 03-28 by Bowen
*/

`timescale 1ns / 1ps
module vga_out #(
    // input and output bitwidth for RGB color
    parameter INPUT_RGB_WIDTH = 6,
    parameter OUTPUT_RGB_WIDTH = 4,
    parameter COUNTER_WIDTH = 10, // supports a frame up to 1024x1024

    // defines the VGA resolution
    parameter HORIZONTAL_PIXEL = 640,
    parameter VERTICAL_PIXEL = 480
) (
    input clk,
    input arstn, // clk and async active low reset
    input i_active, // for DE/active
    input i_vsync, // vertical sync, ==0 when a new frame starts, less frequent
    input i_hsync, // horizontal sync, ==0 when a new row starts, more frequent
    input [INPUT_RGB_WIDTH-1:0] i_red,
    input [INPUT_RGB_WIDTH-1:0] i_green,
    input [INPUT_RGB_WIDTH-1:0] i_blue,
    output reg [OUTPUT_RGB_WIDTH-1:0] o_red,
    output reg [OUTPUT_RGB_WIDTH-1:0] o_green,
    output reg [OUTPUT_RGB_WIDTH-1:0] o_blue,
    output reg [7:0] o_gray,
    output reg o_start_frame,
    output reg o_valid,

    output reg o_hsync,
    output reg o_vsync,

    input i_binary_sw
);
reg [COUNTER_WIDTH-1:0] col_cnt; // keeps track of COLs, faster
reg [COUNTER_WIDTH-1:0] row_cnt; // keeps track of ROWs, slower

// hsync and vsync logic
always @(posedge clk) begin
    o_hsync <= i_hsync;
    o_vsync <= i_vsync;
end

// column counter logic
always @(posedge clk or negedge arstn) begin
    if (!arstn)
        col_cnt <= 0; // resets when reset or hsync==1 which means a new line starts
    else if (!i_hsync)
            col_cnt <= 0;    
    else if (i_active)
            col_cnt <= col_cnt + 1; // increment when active_video==1
end

// row counter logic
always @(posedge clk or negedge arstn) begin
    if (!arstn)
        row_cnt <= 0; // resets when reset or hsync==1 which means a new line starts
    else if (!i_vsync)
            row_cnt <= 0;    
    else if (i_active && (col_cnt == HORIZONTAL_PIXEL-1))
            row_cnt <= row_cnt + 1; 
end

// gray conversion logic
wire [13:0] r_mult;
wire [13:0] g_mult;
wire [13:0] b_mult;
wire [13:0] gray_mult;
wire [7:0] gray;
assign r_mult = i_red * 8'd76; // 6 bit times 8 bit => 14 bit
assign g_mult = i_green * 8'd150;
assign b_mult = i_blue * 8'd29;
assign gray_mult = r_mult + g_mult + b_mult;
assign gray = gray_mult[13:6];


// video output logic
always @(posedge clk or negedge arstn) begin
    if (!arstn) begin
        o_red <= 4'b0000; // all black when reset
        o_green <= 4'b0000;
        o_blue <= 4'b0000;
        o_valid <= 0;
    end
    else begin
        if (i_active) begin
            // print out the 112x112 detection box in green
            if ((col_cnt == 10'd264 || col_cnt == 10'd377) && (row_cnt >= 10'd183 && row_cnt <= 10'd296)) begin
                o_red <= 4'b0000;  
                o_green <= 4'b1111;
                o_blue <= 4'b0000;
                o_valid <= 0;
            end
            else if ((col_cnt >= 10'd264 && col_cnt <= 10'd377) && (row_cnt == 10'd183 || row_cnt == 10'd296)) begin
                o_red <= 4'b0000;  
                o_green <= 4'b1111;
                o_blue <= 4'b0000;

                o_valid <= 0;
            end

            // print out gray
            else if (col_cnt > 'd264 && col_cnt < 'd377 && row_cnt > 'd183 && row_cnt < 'd296) begin
                if (i_binary_sw) begin
                    // original
                    o_red <= gray[7:4];
                    o_green <= gray[7:4];
                    o_blue <= gray[7:4];
                    o_gray <= gray[7:0];
                end
                else begin
                    // binary - modified 03-28
                    o_red <= {5{gray[7]}};
                    o_green <= {5{gray[7]}};
                    o_blue <= {5{gray[7]}};
                    o_gray <= {8{gray[7]}};
                end
                o_valid <= 1;
            end
           
            // pass the pixel information otherwise
            else begin
                o_red <= i_red[5:2];
                o_green <= i_green[5:2];
                o_blue <= i_blue[5:2];
                o_valid <= 0;
            end
        end
    end
end

//o_start_frame logic
always @(posedge clk or negedge arstn) begin
    if (!arstn)
        o_start_frame <= 1'b0;
    else if (row_cnt == 'd183 && col_cnt == 'd1) // assert as soon as it is on row 183
        o_start_frame <= 1;
    else
        o_start_frame <= 0;
end
   
endmodule