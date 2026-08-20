# Execute a user Tcl script and convert Tcl errors into a reliable process code.
# The sourced script must return normally and must not call exit itself.

if {$argc != 1} {
    puts stderr "VIVADO_DRIVER_ERROR expected one Tcl script path, got $argc"
    exit 2
}

set body [file normalize [lindex $argv 0]]
if {![file isfile $body]} {
    puts stderr "VIVADO_DRIVER_ERROR script does not exist: $body"
    exit 2
}

if {[catch {source $body} message options]} {
    puts stderr "VIVADO_DRIVER_ERROR $message"
    if {[dict exists $options -errorinfo]} {
        puts stderr [dict get $options -errorinfo]
    }
    exit 1
}

puts "VIVADO_DRIVER_OK script=$body"
exit 0
