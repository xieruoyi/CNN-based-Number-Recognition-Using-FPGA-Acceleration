# CNN-based-Number-Recognition-Using-FPGA-Acceleration
Key files in project folder  
Root directory  
&ensp;CNN_0328_bowen_stream_ila.xpr - Vivado project file  
&ensp;CNN_0328_bowen_stream_ila.srcs - sources folder  
&ensp;&ensp;&ensp;constrs_1/new/nexys4ddr.xdc - constraints file  
&ensp;&ensp;&ensp;sources_1/bd/design1/hdl/design_1_wrapper.v - wrapper for block design  
&ensp;&ensp;&ensp;sources_1/new - custom verilog modules  
&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;capture_to_vdma.v  
&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;downsample.v  
&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;downscale_to_CNN.v  
&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;grayscale_bram_freeze.v  
&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;ov5640_capture.v  
&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;ov5640_capture_new.v  
&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;ov5640_powerup.v  
&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;ov5640_top.v  
&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;vga_out.v  
&ensp;&ensp;&ensp;sources_1/imports/sources_1/new - all CNN files are in here  
&ensp;&ensp;&ensp;sources_1/imports/sources_1/imports/CNN_hw - some later added verilog modules  
&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;choose_output.v  
&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;grayscale_rom.v  
&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;seven_seg.v  
&ensp;CNN_0328_bowen_stream_ila.sdk/project_1/src/test.c - MicroBlaze program code  
