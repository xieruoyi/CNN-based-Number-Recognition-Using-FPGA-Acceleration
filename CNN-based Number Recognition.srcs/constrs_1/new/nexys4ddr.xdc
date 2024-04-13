## OV5640 Interface
set_property -dict {PACKAGE_PIN C17 IOSTANDARD LVCMOS33} [get_ports OV5640_RESET]
set_property -dict {PACKAGE_PIN D17 IOSTANDARD LVCMOS33} [get_ports OV5640_PWDN]
set_property -dict {PACKAGE_PIN E17 IOSTANDARD LVCMOS33} [get_ports {OV5640_D[0]}]
set_property -dict {PACKAGE_PIN D18 IOSTANDARD LVCMOS33} [get_ports {OV5640_D[1]}]
set_property -dict {PACKAGE_PIN F18 IOSTANDARD LVCMOS33} [get_ports {OV5640_D[2]}]
set_property -dict {PACKAGE_PIN E18 IOSTANDARD LVCMOS33} [get_ports {OV5640_D[3]}]
set_property -dict {PACKAGE_PIN G18 IOSTANDARD LVCMOS33} [get_ports {OV5640_D[4]}]
set_property -dict {PACKAGE_PIN G17 IOSTANDARD LVCMOS33} [get_ports {OV5640_D[5]}]
set_property -dict {PACKAGE_PIN E16 IOSTANDARD LVCMOS33} [get_ports {OV5640_D[6]}]
set_property -dict {PACKAGE_PIN D14 IOSTANDARD LVCMOS33} [get_ports {OV5640_D[7]}]
set_property -dict {PACKAGE_PIN F16 IOSTANDARD LVCMOS33} [get_ports OV5640_PCLK]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets OV5640_PCLK]
create_clock -period 10.000 -name OV5640_PCLK -waveform {0.000 5.000} -add [get_ports OV5640_PCLK]
set_property -dict {PACKAGE_PIN G16 IOSTANDARD LVCMOS33} [get_ports OV5640_VSYNC]
set_property -dict {PACKAGE_PIN G13 IOSTANDARD LVCMOS33} [get_ports OV5640_HREF]
set_property -dict {PACKAGE_PIN F13 IOSTANDARD LVCMOS33} [get_ports OV5640_XCLK]
set_property -dict {PACKAGE_PIN H14 IOSTANDARD LVCMOS33} [get_ports IIC_0_scl_io]
set_property -dict {PACKAGE_PIN H16 IOSTANDARD LVCMOS33} [get_ports IIC_0_sda_io]
set_property PULLUP true [get_ports IIC_0_sda_io]

## System Clock and Reset
set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports sys_clock]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports sys_clock]
set_property -dict {PACKAGE_PIN C12 IOSTANDARD LVCMOS33} [get_ports reset]

# VGA Output
set_property -dict {PACKAGE_PIN A3 IOSTANDARD LVCMOS33} [get_ports {vga_red[0]}]
set_property -dict {PACKAGE_PIN B4 IOSTANDARD LVCMOS33} [get_ports {vga_red[1]}]
set_property -dict {PACKAGE_PIN C5 IOSTANDARD LVCMOS33} [get_ports {vga_red[2]}]
set_property -dict {PACKAGE_PIN A4 IOSTANDARD LVCMOS33} [get_ports {vga_red[3]}]

set_property -dict {PACKAGE_PIN C6 IOSTANDARD LVCMOS33} [get_ports {vga_green[0]}]
set_property -dict {PACKAGE_PIN A5 IOSTANDARD LVCMOS33} [get_ports {vga_green[1]}]
set_property -dict {PACKAGE_PIN B6 IOSTANDARD LVCMOS33} [get_ports {vga_green[2]}]
set_property -dict {PACKAGE_PIN A6 IOSTANDARD LVCMOS33} [get_ports {vga_green[3]}]

set_property -dict {PACKAGE_PIN B7 IOSTANDARD LVCMOS33} [get_ports {vga_blue[0]}]
set_property -dict {PACKAGE_PIN C7 IOSTANDARD LVCMOS33} [get_ports {vga_blue[1]}]
set_property -dict {PACKAGE_PIN D7 IOSTANDARD LVCMOS33} [get_ports {vga_blue[2]}]
set_property -dict {PACKAGE_PIN D8 IOSTANDARD LVCMOS33} [get_ports {vga_blue[3]}]

set_property -dict {PACKAGE_PIN B11 IOSTANDARD LVCMOS33} [get_ports vga_hsync]
set_property -dict {PACKAGE_PIN B12 IOSTANDARD LVCMOS33} [get_ports vga_vsync]

set_property -dict {PACKAGE_PIN T10 IOSTANDARD LVCMOS33} [get_ports CA_0]
set_property -dict {PACKAGE_PIN R10 IOSTANDARD LVCMOS33} [get_ports CB_0]
set_property -dict {PACKAGE_PIN K16 IOSTANDARD LVCMOS33} [get_ports CC_0]
set_property -dict {PACKAGE_PIN K13 IOSTANDARD LVCMOS33} [get_ports CD_0]
set_property -dict {PACKAGE_PIN P15 IOSTANDARD LVCMOS33} [get_ports CE_0]
set_property -dict {PACKAGE_PIN T11 IOSTANDARD LVCMOS33} [get_ports CF_0]
set_property -dict {PACKAGE_PIN L18 IOSTANDARD LVCMOS33} [get_ports CG_0]
set_property -dict {PACKAGE_PIN H15 IOSTANDARD LVCMOS33} [get_ports DP_0]
#set_property IOSTANDARD LVCMOS33 [get_ports i_en_0]
#set_property PACKAGE_PIN J15 [get_ports i_en_0]

set_property PACKAGE_PIN V10 [get_ports i_binary_sw_0]
set_property IOSTANDARD LVCMOS33 [get_ports i_binary_sw_0]

set_property MARK_DEBUG true [get_nets design_1_i/grayscale_bram_freeze_0/i_conv_working]
set_property MARK_DEBUG true [get_nets design_1_i/grayscale_bram_freeze_0/i_start_frame]
set_property MARK_DEBUG true [get_nets design_1_i/grayscale_bram_freeze_0/i_valid]
set_property MARK_DEBUG true [get_nets design_1_i/grayscale_bram_freeze_0/o_frame_ready]
set_property MARK_DEBUG true [get_nets {design_1_i/grayscale_bram_freeze_0/inst/counter[1]}]
set_property MARK_DEBUG true [get_nets {design_1_i/grayscale_bram_freeze_0/inst/counter[3]}]
set_property MARK_DEBUG true [get_nets {design_1_i/grayscale_bram_freeze_0/inst/counter[4]}]
set_property MARK_DEBUG true [get_nets {design_1_i/grayscale_bram_freeze_0/inst/counter[8]}]
set_property MARK_DEBUG true [get_nets {design_1_i/grayscale_bram_freeze_0/inst/counter[9]}]
set_property MARK_DEBUG true [get_nets {design_1_i/grayscale_bram_freeze_0/inst/current_state[0]}]
set_property MARK_DEBUG true [get_nets {design_1_i/grayscale_bram_freeze_0/inst/counter[0]}]
set_property MARK_DEBUG true [get_nets {design_1_i/grayscale_bram_freeze_0/inst/counter[2]}]
set_property MARK_DEBUG true [get_nets {design_1_i/grayscale_bram_freeze_0/inst/counter[5]}]
set_property MARK_DEBUG true [get_nets {design_1_i/grayscale_bram_freeze_0/inst/counter[6]}]
set_property MARK_DEBUG true [get_nets {design_1_i/grayscale_bram_freeze_0/inst/counter[7]}]
set_property MARK_DEBUG true [get_nets {design_1_i/grayscale_bram_freeze_0/inst/current_state[1]}]
create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 65536 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list design_1_i/clk_wiz_1/inst/clk_out_100]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 2 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {design_1_i/grayscale_bram_freeze_0/inst/current_state[0]} {design_1_i/grayscale_bram_freeze_0/inst/current_state[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 10 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {design_1_i/grayscale_bram_freeze_0/inst/counter[0]} {design_1_i/grayscale_bram_freeze_0/inst/counter[1]} {design_1_i/grayscale_bram_freeze_0/inst/counter[2]} {design_1_i/grayscale_bram_freeze_0/inst/counter[3]} {design_1_i/grayscale_bram_freeze_0/inst/counter[4]} {design_1_i/grayscale_bram_freeze_0/inst/counter[5]} {design_1_i/grayscale_bram_freeze_0/inst/counter[6]} {design_1_i/grayscale_bram_freeze_0/inst/counter[7]} {design_1_i/grayscale_bram_freeze_0/inst/counter[8]} {design_1_i/grayscale_bram_freeze_0/inst/counter[9]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 1 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list design_1_i/grayscale_bram_freeze_0/i_conv_working]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 1 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list design_1_i/grayscale_bram_freeze_0/i_start_frame]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 1 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list design_1_i/grayscale_bram_freeze_0/i_valid]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 1 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list design_1_i/grayscale_bram_freeze_0/o_frame_ready]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets u_ila_0_clk_out_100]