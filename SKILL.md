---
name: xilinx-suite
description: "Version-aware Xilinx/AMD FPGA and MPSoC development for Vivado, Vitis HLS, Vitis Unified, and PetaLinux. Use for RTL, SystemVerilog/VHDL, XDC, Block Design, IP Integrator, AXI, synthesis, implementation, timing, simulation, bitstreams, XSA, hardware-manager/JTAG, Zynq, UltraScale, Versal, HLS, embedded software, device trees, JESD204, or PetaLinux workflows. Includes native-Windows and Vivado 2025.2 compatibility guardrails."
---

# Xilinx full-toolchain workflow

Treat the installed tool version, target part, board wiring, and local tool output as authoritative. Never reuse a Tcl/IP example across releases without checking it in the target release.

## Start every task with preflight

1. Determine the exact tool and stage: Vivado, Vitis HLS, Vitis Unified, or PetaLinux.
2. Determine the exact version with the installed executable; do not infer it from a project filename.
3. Determine the full FPGA part number or board part before creating a project or XDC.
4. Determine whether the requested action is read-only, builds artifacts, or touches hardware.
5. Read the routed references below before generating Tcl, XSCT, XDC, or build commands.

For Vivado, first run or generate:

```tcl
puts "VIVADO_VERSION=[version -short]"
puts "VIVADO_FULL_VERSION=[version]"
```

Use `help -syntax <command>` inside that same Vivado release when a command or option matters. Lazy-loaded commands may appear only after `create_project`, `open_project`, or `load_features`; test them in the required context.

## Route to references

| Task | Read first |
|---|---|
| Any Vivado task, especially Windows or 2025.2 | `references/vivado_version_compat.md` |
| Migrating an old or vendor board example; JTAG/UART validation | `references/board_migration_and_hardware_validation.md` |
| Project creation, IP, Block Design, synthesis, implementation, reports, bitstream | `references/vivado_guide.md` |
| Zynq-7000 / PS7 / Cortex-A9 / ZC702, ZC706, ZedBoard | `references/zynq7_ps_workflow.md` |
| Zynq/MPSoC Block Design automation | `references/mpsoc_bd_guide.md` |
| Virtex UltraScale+ VU9P-specific work | `references/vu9p_guide.md` |
| Tcl command lookup and scripting patterns | `references/tcl_commands.md` |
| IO and timing constraints | `references/xdc_constraints.md` and `references/xdc_guide.md` |
| Zynq UltraScale+ PS, DDR, MIO, clocks | `references/mpsoc_ps_config.md` |
| JESD204B/C migration | `references/jesd204b_to_c_migration.md` |
| Vitis HLS C/C++ to IP | `references/hls_guide.md` |
| Vitis Unified platform/domain/application | `references/vitis_unified_guide.md` |
| PetaLinux BSP, XSA, kernel, rootfs, boot image | `references/petalinux_guide.md` |
| PetaLinux gRPC/ZMQ/udmabuf/AXI DMA | `references/grpc_on_petalinux.md` |
| Official UG/PG/DS/XAPP lookup | `references/official-docs/index.md` |

Load only the references needed for the task.

## Vivado execution rules

- On native Windows, prefer `scripts/run-vivado-batch.ps1` for batch work. It compensates for restricted shells that omit `PROCESSOR_ARCHITECTURE` and uses the bundled Tcl driver to propagate failures.
- Automation must create native GUI-openable artifacts: Vivado `.xpr` plus `.bd`, HLS `vitis-comp.json` plus exported `component.xml`, and Vitis Unified workspace/components plus `.xpfm`/`.elf`. Tcl/Python scripts are reproducibility aids, not substitutes for these artifacts.
- Copy `scripts/vivado-compat.tcl` into generated projects and source it before Project Mode run control.
- For Vivado 2025.2, use `reset_runs` and `wait_on_runs`; do not emit the removed singular forms. The compatibility helpers select the available spelling for older releases.
- Check both `PROGRESS` and `STATUS` after every synthesis or implementation run. Do not rely only on the Vivado process exit code.
- Put project paths well below the Windows 260-character limit; prefer a short root such as `D:/fpga/<project>`.
- For BD output products on Windows, prefer Global synthesis when OOC generation reports `Could not open 'C' for writing`: `set_property synth_checkpoint_mode None [get_files <design>.bd]` (GUI: Generate Output Products -> Synthesis Options -> Global).
- Treat Board Store warnings separately from target-part availability. Confirm the selected part with `get_parts`.
- Do not suppress `UCIO-1` or `NSTD-1` for a real board build. Only synthetic tool-smoke tests may downgrade them, and the output must be labelled non-deployable.
- Never call `program_hw_devices`, write configuration memory, or alter a connected target unless the user explicitly requests programming and identifies the target.

## Version-sensitive rules

- Use the IP VLNV returned by `get_ipdefs`; do not hardcode a version unless validated locally.
- In Vivado 2025.2 Block Design, prefer Inline HDL blocks such as `xilinx.com:inline_hdl:ilconstant:1.0` where Vivado recommends them instead of legacy `xlconstant`.
- Use `write_hw_platform`; do not generate legacy `write_sysdef` for modern releases.
- Keep PetaLinux and exported XSA/Vivado releases aligned unless AMD documentation explicitly supports the combination.
- For Vitis Unified 2025.2 embedded project creation, prefer the Python component API via `scripts/run-vitis-python.ps1`; keep XSCT for discovery, debug, and legacy workspaces.
- For Vitis HLS 2025.2, use `scripts/run-vitis-hls.ps1` and the component API (`open_component`); do not assume the removed standalone `vitis_hls` command or old `open_project/open_solution` flow.
- Require Vitis Python scripts to print `VITIS_SCRIPT_OK` only after verifying XPFM/ELF artifacts. Vitis and XSCT can print a traceback while returning native exit code 0.
- Treat `xc7z*` as Zynq-7000 with PS7/Cortex-A9, not as a pure-PL 7-series part.

## Verification ladder

Apply the smallest sufficient ladder, stopping on failure:

1. Version, part, command syntax, and IP catalog discovery.
2. HDL compile/elaboration or Block Design validation.
3. Behavioral simulation with an explicit, machine-checkable assertion.
4. Synthesis and post-synthesis DRC/timing/utilization.
5. Implementation and post-route timing/DRC/methodology/CDC/power as relevant.
6. Bitstream or XSA generation only with valid constraints and the correct target.
7. Hardware-server connection and target enumeration before any programming.
8. When hardware access is authorized, validate volatile JTAG programming and the ELF with an unambiguous UART marker; do not infer success from download commands alone.

## Deliverables

For generated work, provide:

- Complete runnable source, Tcl/XDC/XSCT, or shell files.
- Native projects/components that can be opened in the installed GUI, not only regenerated from a command line.
- Exact command line and required environment.
- Expected artifacts and where they are written.
- Validation evidence, including Vivado version, part, run status, and key report metrics.
- Any skipped stages and why they were skipped.

Keep generated projects organized by stage (`hls/`, `vivado/`, `vitis/`, `petalinux/`) only when those stages are actually used.
