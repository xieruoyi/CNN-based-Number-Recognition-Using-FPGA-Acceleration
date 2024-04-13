@echo off
REM ****************************************************************************
REM Vivado (TM) v2018.3 (64-bit)
REM
REM Filename    : elaborate.bat
REM Simulator   : Xilinx Vivado Simulator
REM Description : Script for elaborating the compiled design
REM
REM Generated by Vivado on Mon Mar 18 17:45:12 -0400 2024
REM SW Build 2405991 on Thu Dec  6 23:38:27 MST 2018
REM
REM Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
REM
REM usage: elaborate.bat
REM
REM ****************************************************************************
call xelab  -wto 64a5cfd133b549d895d82bdc9f66d079 --incr --debug typical --relax --mt 2 -L xil_defaultlib -L microblaze_v11_0_0 -L lmb_v10_v3_0_9 -L lmb_bram_if_cntlr_v4_0_15 -L blk_mem_gen_v8_4_2 -L generic_baseblocks_v2_1_0 -L axi_infrastructure_v1_1_0 -L axi_register_slice_v2_1_18 -L fifo_generator_v13_2_3 -L axi_data_fifo_v2_1_17 -L axi_crossbar_v2_1_19 -L axi_lite_ipif_v3_0_4 -L axi_intc_v4_1_12 -L xlconcat_v2_1_1 -L mdm_v3_2_15 -L lib_cdc_v1_0_2 -L proc_sys_reset_v5_0_13 -L lib_pkg_v1_0_2 -L lib_fifo_v1_0_12 -L lib_srl_fifo_v1_0_2 -L axi_master_burst_v2_0_7 -L axi_tft_v2_0_21 -L xlconstant_v1_1_5 -L smartconnect_v1_0 -L interrupt_control_v3_1_4 -L axi_iic_v2_0_21 -L lib_bmg_v1_0_11 -L axi_datamover_v5_1_20 -L axi_vdma_v6_3_6 -L unisims_ver -L unimacro_ver -L secureip -L xpm --snapshot design_1_wrapper_behav xil_defaultlib.design_1_wrapper xil_defaultlib.glbl -log elaborate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
