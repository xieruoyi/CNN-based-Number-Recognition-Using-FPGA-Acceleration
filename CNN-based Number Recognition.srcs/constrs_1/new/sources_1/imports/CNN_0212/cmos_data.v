// *********************************************************************************
// Project Name : OSXXXX
// Author       : dengkanwen
// Email        : dengkanwen@163.com
// Website      : http://www.opensoc.cn/
// Create Time  : 2021-05-09 09:54:24
// File Name    : .v
// Module Name  : 
// Called By    :
// Abstract     :
//
// CopyRight(c) 2018, OpenSoc Studio.. 
// All Rights Reserved
//
// *********************************************************************************
// Modification History:
// Date         By              Version                 Change Description
// -----------------------------------------------------------------------
// 2021-05-09    Kevin           1.0                     Original
//  
// *********************************************************************************
`timescale      1ns/1ns

module  cmos_data(
        //
        input                   arstn                 ,             
        // Camera
        input                   m_pclk                  ,             
        input           [5:0]  tft_r                  ,
        input           [5:0]  tft_g                  ,
        input           [5:0]  tft_b                  ,
        input                   m_vs                    ,       
        input                   m_hs                  ,   
        input                   active,
        output                  hsync,
        output                  vsync,
        output                  i_active, 
//        input                   m_wr_en                 ,
        //   
        // Video in Core   
        output  wire    [5:0]  vga_r,
        output wire [5:0] vga_g,
        output wire [5:0] vga_b                       
);

//========================================================================\
// =========== Define Parameter and Internal signals =========== 
//========================================================================/
// Gray = R*0.299 + G*0.587 + B*0.114
// Gray = R*76 + G*150 + B*29
reg     [ 9:0]                  row_cnt                         ;
reg     [ 9:0]                  col_cnt                         ;
wire m_wr_en ;

reg     [15:0]                  r_mult                          ;
reg     [15:0]                  g_mult                          ;
reg     [15:0]                  b_mult                          ;

wire    [7:0]                  gray                            ;


//=============================================================================
//**************    Main Code   **************
//=============================================================================
assign  gray            =      {8'b0, (r_mult + g_mult + b_mult) >> 8};
reg [5:0] vga_r_reg, vga_g_reg, vga_b_reg;

assign vga_r = vga_r_reg;
assign vga_g = vga_g_reg;
assign vga_b = vga_b_reg;
assign hsync = m_hs;
assign vsync = m_vs;
assign i_active = active;


always @(posedge m_pclk or negedge arstn) begin
    if (!arstn) begin
        vga_r_reg <= 6'd0;
        vga_g_reg <= 6'd0;
        vga_b_reg <= 6'd0;
    end else if (col_cnt >= 'd264 && col_cnt <= 'd376 && row_cnt >= 'd184 && row_cnt <= 'd296) begin
        vga_r_reg <= 5'b11111;
        vga_g_reg <= 5'b11111;
        vga_b_reg <= 5'b11111;
    end
    else begin
        vga_r_reg <= tft_r;
        vga_g_reg <= tft_g;
        vga_b_reg <= tft_b;
    end
end

always  @(posedge m_pclk or negedge arstn) begin
        if(!arstn)
                col_cnt <=      'd0;
        else if(m_hs == 1'b0)
                col_cnt <=      'd0;
        else if(m_hs == 1'b1 && active == 1'b1)
                col_cnt <=      col_cnt + 1'b1;
end

always  @(posedge m_pclk or negedge arstn) begin
        if(!arstn)
                row_cnt <=      'd0;
        else if(m_vs == 1'b1)
                row_cnt <=      'd0;
        else if(m_hs == 1'b1 && col_cnt == 'd639 && active == 1'b1)
                row_cnt <=      row_cnt + 1'b1;
end

always  @(posedge m_pclk or negedge arstn) begin
        if(!arstn) begin
                r_mult  <=      'd0;
                g_mult  <=      'd0;
                b_mult  <=      'd0;
        end
        else begin
                r_mult  <=      {tft_r, 3'b0} * 76;
                g_mult  <=      {tft_g, 3'b0} * 150;
                b_mult  <=      {tft_b, 3'b0} * 29;
        end
end


endmodule
