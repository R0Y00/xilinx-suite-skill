# Zynq-7000 PS7 workflow

Zynq-7000 parts use `processing_system7` and Cortex-A9. Never classify `xc7z*`
as a pure-PL 7-series device.

## Local Vivado resources

For a standard 2025.2 Windows installation, locate rather than assume:

```text
<Vivado>/data/ip/xilinx/processing_system7_v5_5
<Vivado>/data/ip/xilinx/processing_system7_v5_5/preset
```

Typical installed presets include ZedBoard, ZC702, and ZC706. Query board parts
with `get_board_parts` before setting `BOARD_PART`.

## Minimal PS7 Block Design

```tcl
create_bd_design system
set ps7 [get_ipdefs -all -filter {NAME == processing_system7}]
set vlnv [get_property VLNV [lindex $ps7 end]]
create_bd_cell -type ip -vlnv $vlnv processing_system7_0
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 \
    -config {apply_board_preset "1" make_external "FIXED_IO, DDR"} \
    [get_bd_cells processing_system7_0]
```

Board presets may enable `M_AXI_GP0`. If no PL slave is attached, either disable
the unused master or connect `FCLK_CLK0` to `M_AXI_GP0_ACLK`; otherwise BD
validation fails. An unaddressed but clocked GP0 may still produce an incomplete
address-path warning, so disable it for a genuinely PS-only design.

After validation, generate the wrapper and export the XSA:

```tcl
validate_bd_design
save_bd_design
generate_target all [get_files system.bd]
set wrapper [make_wrapper -files [get_files system.bd] -top]
add_files -norecurse $wrapper
write_hw_platform -fixed -force -file ./output/zynq7.xsa
```

Use `ps7_cortexa9_0` when creating the Vitis standalone domain.

## Installed software examples

Application templates are under:

```text
<Vitis>/data/embeddedsw/lib/sw_apps
```

Relevant entries include `hello_world`, `peripheral_tests`, `memory_tests`,
`zynq_fsbl`, and `zynq_dram_test`.

PS driver examples are under versioned directories in:

```text
<Vitis>/data/embeddedsw/XilinxProcessorIPLib/drivers
```

Search the latest installed `uartps`, `gpiops`, `scutimer`, `scugic`, `qspips`,
`sdps`, and `emacps` directory rather than hardcoding its version suffix.

`ps7_init.c`, `ps7_init.h`, and related initialization data are generated from
the actual PS configuration. They are outputs of the platform/FSBL flow, not a
single universal source file to copy between boards.
