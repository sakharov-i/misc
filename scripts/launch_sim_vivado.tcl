# This scriptc creates vivado simulation project with sources listed below
# and runs behavioral simaulation using existing waveform file(.wcfg)
# If waveform file is missing, new blank waveform file will be created

# REQUIRMNTS:
#   Defined system variables:
#     XILINX_VIVADO='C:\Xilinx\Vivado\2019.2'
#     PATH='C:\Xilinx\Vivado\2019.2\bin'
#     PATH='C:\Xilinx\Vivado\2019.2\lib\win64.o'

# ADDING PROJECT SOURCES ---------------------------------------------------------------------------
set module_under_test counter

# Testbench and other test sources
read_verilog -sv ${module_under_test}_tb.sv
read_verilog -sv <tb_routine>.svh

# design sources
read_verilog -sv ${module_under_test}.sv
read_verilog -sv <submodule_0>.sv
read_verilog -sv <submodule_1>.sv

# design ip cores
add_files -norecurse <ip_core>.xci

# PROJECT SETTINGS ---------------------------------------------------------------------------------
# design part
set part_number xc7a200tfbg484-2

# waveform file name
set file_name <module_under_test>.wcfg


# CREATE PROJECT AND LAUNCH SIM---------------------------------------------------------------------
save_project_as sim sim_prj -force
set_property PART $part_number [current_project]
set_property top ${module_under_test}_tb [get_fileset sim_1]

launch_simulation -simset sim_1 -mode behavioral
close_wave_config

    if { [file exists $file_name] == 1} {
      open_wave_config $file_name
    } else { create_wave_config $file_name }

run all