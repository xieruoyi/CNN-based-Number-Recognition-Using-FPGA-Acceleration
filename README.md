# CNN-based-Number-Recognition-Using-FPGA-Acceleration
Key files in project folder  
Root directory  
CNN_0328_bowen_stream_ila.xpr - Vivado project file  
CNN_0328_bowen_stream_ila.srcs - sources folder  
constrs_1/new/nexys4ddr.xdc - constraints file  
sources_1/bd/design1/hdl/design_1_wrapper.v - wrapper for block design  
sources_1/new - custom verilog modules  
capture_to_vdma.v  
downsample.v  
downscale_to_CNN.v  
grayscale_bram_freeze.v  
ov5640_capture.v  
ov5640_capture_new.v  
ov5640_powerup.v  
ov5640_top.v  
vga_out.v  
sources_1/imports/sources_1/new - all CNN files are in here  
sources_1/imports/sources_1/imports/CNN_hw - some later added verilog modules  
choose_output.v  
grayscale_rom.v  
seven_seg.v  
CNN_0328_bowen_stream_ila.sdk/project_1/src/test.c - MicroBlaze program code  
