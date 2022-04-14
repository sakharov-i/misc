################################################################################
# This script converts Vivado project to script
# Execute this script before commiting project to Git repository.
# Required project path: ./${output_dir}
# Output project script path: ./${script_dir}/${prj_name}${script_name_suffix}
#
################################################################################

set script_dir scripts
set output_dir out
set script_name_suffix _prj_script.tcl
set viavdo_prj_ext *.xpr

# Searching Vivado projects
set prj_file [glob -tail -directory out ${viavdo_prj_ext}]
# If project found
if {[lsearch $prj_file ${viavdo_prj_ext}] >= 0 } {
  set prj_name [file rootname [lindex $prj_file 0]]
  puts "Found Vivado project ${prj_name}.xpr"
  puts "Creating project script ./${script_dir}/${prj_name}${script_name_suffix}"
    # Opening vivado project
  open_project $output_dir/$prj_name.xpr

  # Workaround fow Xilinx MIG Configuration file:
  # Such files mustn't get to procject script, because it will be regenerated automaticaly
    # Finding MIG configuration file in project
    set mig_file [get_files *mig_*.prj]
    set files_cnt [llength $mig_file]

    if {$files_cnt > 0} {
      # Vivado file name string bug workaround
      for {set i 0} {$i<[expr $files_cnt]} {incr i} {
        set file($i) [format %s [lindex $mig_file $i]]
      }

      # Remove this file from project
      remove_files $mig_file
    }

  # Creating project script in directory "${script_dir}" one higher than "$output_dir" direcory
  write_project_tcl -force ${output_dir}/../${script_dir}/${prj_name}${script_name_suffix} \
      -target_proj_dir ${output_dir} -paths_relative_to {${script_dir}} -origin_dir_override {${script_dir}}

    if {$files_cnt > 0} {
      # Adding deletd MIG configuration file back to project
      for {set i 0} {$i<[expr $files_cnt]} {incr i} {
        add_files -norecurse $file($i)
      }
    }

    # Closing vivado project
  close_project
  puts "==============================================================================="
  puts "Project scipt file./${script_dir}/${prj_name}${script_name_suffix} file succesfully created"
  puts "==============================================================================="
} else {
  # Project not found
  puts "No Vivado projects found"
}



