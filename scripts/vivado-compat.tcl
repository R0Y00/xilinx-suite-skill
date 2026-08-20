# Vivado run-command compatibility helpers.
# Source this file from a project Tcl script before using the procedures below.

proc vivado_reset_run {run_name} {
    if {[llength [info commands reset_runs]] > 0} {
        reset_runs $run_name
    } elseif {[llength [info commands reset_run]] > 0} {
        reset_run $run_name
    } else {
        error "This Vivado release exposes neither reset_runs nor reset_run"
    }
}

proc vivado_wait_on_run {run_name} {
    if {[llength [info commands wait_on_runs]] > 0} {
        wait_on_runs $run_name
    } elseif {[llength [info commands wait_on_run]] > 0} {
        wait_on_run $run_name
    } else {
        error "This Vivado release exposes neither wait_on_runs nor wait_on_run"
    }
}

proc vivado_assert_run_complete {run_name} {
    set run_obj [get_runs -quiet $run_name]
    if {[llength $run_obj] == 0} {
        error "Run '$run_name' does not exist"
    }

    set progress [get_property PROGRESS $run_obj]
    set status [get_property STATUS $run_obj]
    puts "RUN_RESULT name=$run_name progress=$progress status={$status}"

    if {$progress ne "100%"} {
        error "Run '$run_name' is incomplete: progress=$progress status={$status}"
    }
    if {[regexp -nocase {error|fail|cancel} $status]} {
        error "Run '$run_name' failed: status={$status}"
    }
}
