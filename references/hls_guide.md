# Vitis HLS component workflow

## Release selection

For Vitis HLS 2025.2 on Windows, use the supported launcher:

```powershell
./scripts/run-vitis-hls.ps1 -Source ./run_hls.tcl
```

It calls `Vitis/bin/vitis-run.bat --mode hls --tcl`. Do not invoke an
`unwrapped/win64.o/vitis-run.exe` directly: its environment is incomplete and
can produce an `xv_xocc_common.dll` dialog. The legacy standalone `vitis_hls`
command may not be installed.

## Create a GUI-openable component

Use the 2025.2 component API, and keep design and testbench sources inside the
component so batch and GUI builds resolve the same files:

```tcl
set component_dir [file normalize ./hls_component]
open_component -reset $component_dir -flow_target vivado
set_top hls_accel
add_files [file join $component_dir src hls_accel.cpp] \
  -cflags "-I[file join $component_dir src]"
add_files -tb [file join $component_dir tb hls_accel_tb.cpp] \
  -cflags "-I[file join $component_dir src]"
set_part {xc7z100ffg900-2}
create_clock -period 10
csim_design -clean
csynth_design
cosim_design
export_design -format ip_catalog -vendor codex.local -library hls -version 1.0
set component_xml [file join $component_dir hls impl ip component.xml]
if {![file exists $component_xml]} { error "Missing exported IP: $component_xml" }
puts HLS_FLOW_PASS
```

Replace the part and top function after local discovery. `vitis-comp.json` in
the component root is the GUI entry point. For 2025.2 the exported Vivado IP is
normally under `<component>/hls/impl/ip/`, including `component.xml` and a ZIP.
Do not report export success until those files exist.

## Interfaces and verification

- `s_axilite`: scalar control/status registers.
- `axis`: streaming data and sidebands.
- `m_axi`: burst access to external memory.
- Run a self-checking C simulation before synthesis.
- Check latency, interval, estimated clock and resource estimates after synthesis.
- Run C/RTL co-simulation when the generated RTL behavior matters.
- Add the directory containing `component.xml` to Vivado `ip_repo_paths`, run
  `update_ip_catalog`, and select the VLNV returned by `get_ipdefs`.

## Windows `Could not open 'C' for writing`

If HLS export launches Vivado and reports `Could not open 'C' for writing` or a
failure from `tclapp::load_apps`, compare the same probe inside and outside the
managed runner. This message can be Vivado's misleading rendering of a denied
write to its per-user data, not a corrupt `C:` path. Codex sandbox processes can
read `%USERPROFILE%/AppData/Roaming/Xilinx` while being unable to update it.

Use a clean writable `USERPROFILE` supplied before process startup, or run the
authorized tool process outside the sandbox. `-CleanUserProfile` provides the
first option. Do not delete or rewrite the real Tcl App manifest: the presence
of an older release's store is not proof that it caused the error.

An isolated profile can affect Windows helpers such as `cscript`; keep the
override scoped to HLS/Vivado startup and use the real profile for normal GUI
work when possible.
