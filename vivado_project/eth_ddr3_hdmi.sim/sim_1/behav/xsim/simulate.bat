@echo off
REM ****************************************************************************
REM Vivado (TM) v2019.1 (64-bit)
REM
REM Filename    : simulate.bat
REM Simulator   : Xilinx Vivado Simulator
REM Description : Script for simulating the design by launching the simulator
REM
REM Generated by Vivado on Fri Jan 20 22:16:22 +0800 2023
REM SW Build 2552052 on Fri May 24 14:49:42 MDT 2019
REM
REM Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
REM
REM usage: simulate.bat
REM
REM ****************************************************************************
echo "xsim tb_bram_ddr3_hdmi_test_behav -key {Behavioral:sim_1:Functional:tb_bram_ddr3_hdmi_test} -tclbatch tb_bram_ddr3_hdmi_test.tcl -log simulate.log"
call xsim  tb_bram_ddr3_hdmi_test_behav -key {Behavioral:sim_1:Functional:tb_bram_ddr3_hdmi_test} -tclbatch tb_bram_ddr3_hdmi_test.tcl -log simulate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
