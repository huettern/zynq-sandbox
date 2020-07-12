set xsa           [lindex $argv 0]
set xpr           [lindex $argv 1]

open_project $xpr

write_hw_platform -fixed -force -file $xsa

close_project
