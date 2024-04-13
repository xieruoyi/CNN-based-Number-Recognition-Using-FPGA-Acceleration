//Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
//Date        : Thu Mar 28 18:48:39 2024
//Host        : cclaptop running 64-bit major release  (build 9200)
//Command     : generate_target design_1_wrapper.bd
//Design      : design_1_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module design_1_wrapper
   (CA_0,
    CB_0,
    CC_0,
    CD_0,
    CE_0,
    CF_0,
    CG_0,
    DDR2_0_addr,
    DDR2_0_ba,
    DDR2_0_cas_n,
    DDR2_0_ck_n,
    DDR2_0_ck_p,
    DDR2_0_cke,
    DDR2_0_cs_n,
    DDR2_0_dm,
    DDR2_0_dq,
    DDR2_0_dqs_n,
    DDR2_0_dqs_p,
    DDR2_0_odt,
    DDR2_0_ras_n,
    DDR2_0_we_n,
    DP_0,
    IIC_0_scl_io,
    IIC_0_sda_io,
    OV5640_D,
    OV5640_HREF,
    OV5640_PCLK,
    OV5640_PWDN,
    OV5640_RESET,
    OV5640_VSYNC,
    OV5640_XCLK,
    i_binary_sw_0,
    reset,
    sys_clock,
    vga_blue,
    vga_green,
    vga_hsync,
    vga_red,
    vga_vsync);
  output CA_0;
  output CB_0;
  output CC_0;
  output CD_0;
  output CE_0;
  output CF_0;
  output CG_0;
  output [12:0]DDR2_0_addr;
  output [2:0]DDR2_0_ba;
  output DDR2_0_cas_n;
  output [0:0]DDR2_0_ck_n;
  output [0:0]DDR2_0_ck_p;
  output [0:0]DDR2_0_cke;
  output [0:0]DDR2_0_cs_n;
  output [1:0]DDR2_0_dm;
  inout [15:0]DDR2_0_dq;
  inout [1:0]DDR2_0_dqs_n;
  inout [1:0]DDR2_0_dqs_p;
  output [0:0]DDR2_0_odt;
  output DDR2_0_ras_n;
  output DDR2_0_we_n;
  output DP_0;
  inout IIC_0_scl_io;
  inout IIC_0_sda_io;
  input [7:0]OV5640_D;
  input OV5640_HREF;
  input OV5640_PCLK;
  output OV5640_PWDN;
  output OV5640_RESET;
  input OV5640_VSYNC;
  output OV5640_XCLK;
  input i_binary_sw_0;
  input reset;
  input sys_clock;
  output [3:0]vga_blue;
  output [3:0]vga_green;
  output vga_hsync;
  output [3:0]vga_red;
  output vga_vsync;

  wire CA_0;
  wire CB_0;
  wire CC_0;
  wire CD_0;
  wire CE_0;
  wire CF_0;
  wire CG_0;
  wire [12:0]DDR2_0_addr;
  wire [2:0]DDR2_0_ba;
  wire DDR2_0_cas_n;
  wire [0:0]DDR2_0_ck_n;
  wire [0:0]DDR2_0_ck_p;
  wire [0:0]DDR2_0_cke;
  wire [0:0]DDR2_0_cs_n;
  wire [1:0]DDR2_0_dm;
  wire [15:0]DDR2_0_dq;
  wire [1:0]DDR2_0_dqs_n;
  wire [1:0]DDR2_0_dqs_p;
  wire [0:0]DDR2_0_odt;
  wire DDR2_0_ras_n;
  wire DDR2_0_we_n;
  wire DP_0;
  wire IIC_0_scl_i;
  wire IIC_0_scl_io;
  wire IIC_0_scl_o;
  wire IIC_0_scl_t;
  wire IIC_0_sda_i;
  wire IIC_0_sda_io;
  wire IIC_0_sda_o;
  wire IIC_0_sda_t;
  wire [7:0]OV5640_D;
  wire OV5640_HREF;
  wire OV5640_PCLK;
  wire OV5640_PWDN;
  wire OV5640_RESET;
  wire OV5640_VSYNC;
  wire OV5640_XCLK;
  wire i_binary_sw_0;
  wire reset;
  wire sys_clock;
  wire [3:0]vga_blue;
  wire [3:0]vga_green;
  wire vga_hsync;
  wire [3:0]vga_red;
  wire vga_vsync;

  IOBUF IIC_0_scl_iobuf
       (.I(IIC_0_scl_o),
        .IO(IIC_0_scl_io),
        .O(IIC_0_scl_i),
        .T(IIC_0_scl_t));
  IOBUF IIC_0_sda_iobuf
       (.I(IIC_0_sda_o),
        .IO(IIC_0_sda_io),
        .O(IIC_0_sda_i),
        .T(IIC_0_sda_t));
  design_1 design_1_i
       (.CA_0(CA_0),
        .CB_0(CB_0),
        .CC_0(CC_0),
        .CD_0(CD_0),
        .CE_0(CE_0),
        .CF_0(CF_0),
        .CG_0(CG_0),
        .DDR2_0_addr(DDR2_0_addr),
        .DDR2_0_ba(DDR2_0_ba),
        .DDR2_0_cas_n(DDR2_0_cas_n),
        .DDR2_0_ck_n(DDR2_0_ck_n),
        .DDR2_0_ck_p(DDR2_0_ck_p),
        .DDR2_0_cke(DDR2_0_cke),
        .DDR2_0_cs_n(DDR2_0_cs_n),
        .DDR2_0_dm(DDR2_0_dm),
        .DDR2_0_dq(DDR2_0_dq),
        .DDR2_0_dqs_n(DDR2_0_dqs_n),
        .DDR2_0_dqs_p(DDR2_0_dqs_p),
        .DDR2_0_odt(DDR2_0_odt),
        .DDR2_0_ras_n(DDR2_0_ras_n),
        .DDR2_0_we_n(DDR2_0_we_n),
        .DP_0(DP_0),
        .IIC_0_scl_i(IIC_0_scl_i),
        .IIC_0_scl_o(IIC_0_scl_o),
        .IIC_0_scl_t(IIC_0_scl_t),
        .IIC_0_sda_i(IIC_0_sda_i),
        .IIC_0_sda_o(IIC_0_sda_o),
        .IIC_0_sda_t(IIC_0_sda_t),
        .OV5640_D(OV5640_D),
        .OV5640_HREF(OV5640_HREF),
        .OV5640_PCLK(OV5640_PCLK),
        .OV5640_PWDN(OV5640_PWDN),
        .OV5640_RESET(OV5640_RESET),
        .OV5640_VSYNC(OV5640_VSYNC),
        .OV5640_XCLK(OV5640_XCLK),
        .i_binary_sw_0(i_binary_sw_0),
        .reset(reset),
        .sys_clock(sys_clock),
        .vga_blue(vga_blue),
        .vga_green(vga_green),
        .vga_hsync(vga_hsync),
        .vga_red(vga_red),
        .vga_vsync(vga_vsync));
endmodule
