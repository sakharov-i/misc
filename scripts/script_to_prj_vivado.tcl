################################################################################
# This script recreates vivado project from script,
# and opens it in GUI
################################################################################
# Required project script path: ./${script_dir}/${prj_name}${script_name_suffix}
# Output project path: ./${output_dir}
#
################################################################################

set script_dir scripts
set output_dir out
set script_name_suffix _prj_script.tcl


set scr_file [glob -tail -directory $script_dir *$script_name_suffix]
# If project found
if {[lsearch $scr_file *${script_name_suffix}] >= 0 } {
        set prj_name [string range [lindex $scr_file 0] 0 \
                [expr [string first $script_name_suffix [lindex $scr_file 0]]-1]]
        puts "Found project script file ./${script_dir}/${prj_name}${script_name_suffix}"
        puts "Restoring Vivado project ${output_dir}/${prj_name}.xpr"

        # If project already exists - renaming existing directory
        if { [file exists ${output_dir}/${prj_name}.xpr] } {
            set xpr_time [file mtime ${output_dir}/${prj_name}.xpr]
            file rename -force ${output_dir} out_[clock format $xpr_time -format "%Y_%m_%d_%H_%M_%S"]
        }

        # setting maximum number of threads
        set_param synth.maxThreads 8
        set_param general.maxThreads 32

        # restoring project from script
        source ${script_dir}/${prj_name}${script_name_suffix}

  } else {
    puts "No project script files found"
  }
