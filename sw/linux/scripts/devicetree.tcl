
set project_name [lindex $argv 0]

set proc_name [lindex $argv 1]

set repo_path [lindex $argv 2]


set hard_path [lindex $argv 3]
set tree_path [lindex $argv 4]

set boot_args {console=ttyPS0,115200 earlyprintk}

file copy -force $hard_path $tree_path/$project_name.hwdef

set_repo_path $repo_path

open_hw_design $tree_path/$project_name.hwdef
create_sw_design -proc $proc_name -os device_tree devicetree

set_property CONFIG.kernel_version {2018.2} [get_os]
set_property CONFIG.bootargs $boot_args [get_os]

generate_bsp -dir $tree_path

close_sw_design [current_sw_design]
close_hw_design [current_hw_design]
