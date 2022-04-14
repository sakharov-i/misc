################################################################################
# This script recreates vivado project from script,
# builds it and generate binaries.
#
################################################################################
# Required project script path: ./${script_dir}/${prj_name}${script_name_suffix}
# Output project path: ./${output_dir}
# Project binaries path: ./${output_dir}/bin
#
################################################################################

# Directory and file names parameters
set script_dir scripts
set output_dir out
set script_name_suffix _prj_script.tcl

# This procedure calculates processor cores count
proc numberOfCPUs {} {
    # Windows puts it in an environment variable
    global tcl_platform env
    if {$tcl_platform(platform) eq "windows"} {
        return $env(NUMBER_OF_PROCESSORS)
    }

    # Check for sysctl (OSX, BSD)
    set sysctl [auto_execok "sysctl"]
    if {[llength $sysctl]} {
        if {![catch {exec {*}$sysctl -n "hw.ncpu"} cores]} {
            return $cores
        }
    }

    # Assume Linux, which has /proc/cpuinfo, but be careful
    if {![catch {open "/proc/cpuinfo"} f]} {
        set cores [regexp -all -line {^processor\s} [read $f]]
        close $f
        if {$cores > 0} {
            return $cores
        }
    }

    # No idea what the actual number of cores is; exhausted all our options
    # Fall back to returning 1; there must be at least that because we're running on it!
    return 1
}

set scr_file [glob -tail -directory $script_dir *$script_name_suffix]
# If project found
if {[lsearch $scr_file *$script_name_suffix] >= 0 } {
        set prj_name [string range [lindex $scr_file 0] 0 \
                [expr [string first $script_name_suffix [lindex $scr_file 0]]-1]]
        puts "Found project script file ./${script_dir}/${prj_name}${script_name_suffix}"
        puts "Restoring Vivado project ${output_dir}/${prj_name}.xpr"

        # If project already exists - renaming existing directory
        if { [file exists $output_dir/${prj_name}.xpr] } {
            set xpr_time [file mtime $output_dir/${prj_name}.xpr]
            file rename -force $output_dir ${output_dir}_[clock format $xpr_time -format "%Y_%m_%d_%H_%M_%S"]
        }

        # setting maximum number of threads
        set_param synth.maxThreads 8
        set_param general.maxThreads 32

        # restoring project from script
        source scripts/${prj_name}$script_name_suffix

        # get actual synth number
        set run [get_runs synth*]
        # launch synth with maximum number of jobs
        launch_runs $run -jobs [numberOfCPUs]
        wait_on_run $run

        # get actual impl number
        set run [get_runs impl*]
        # launch impl with maximum number of jobs
        launch_runs $run -to_step write_bitstream -jobs [numberOfCPUs]
        wait_on_run $run

        # create directory for binaries
        file mkdir $output_dir/bin
        # copy bit file from project
        file copy -force $output_dir/${prj_name}.runs/${run}/main.bit $output_dir/bin/${prj_name}.bit

        # writing mcs file( for SPI x4 configuration)
        write_cfgmem -force -format mcs -size 256 -interface SPIx4 -loadbit \
                "up 0 ${output_dir}/bin/${prj_name}.bit" -file "${output_dir}/bin/${prj_name}.mcs"

        # writing hw_platform export for Vitis
        write_hw_platform -fixed -force  -include_bit -file $output_dir/bin/${prj_name}.xsa
    } else {
        puts "No project script files found"
    }