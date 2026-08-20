# Vivado version and Windows compatibility

Use runtime discovery instead of assuming that Tcl accepted by one Vivado
release is valid in another.

## Preflight

Run these commands inside Vivado Tcl:

```tcl
puts [version -short]
puts [version]
puts [help -syntax reset_runs]
puts [help -syntax wait_on_runs]
```

Also confirm the exact part or board, project mode, and whether physical hardware
access is authorized. Treat a command that exists only after opening a project or
feature as lazily loaded; retry discovery in the relevant context.

## Important Vivado 2025.2 behavior

| Area | Version-aware rule |
|---|---|
| Run reset | Prefer `reset_runs`; use `vivado_reset_run` from `scripts/vivado-compat.tcl` for legacy fallback. |
| Run wait | Prefer `wait_on_runs`; use `vivado_wait_on_run` for legacy fallback. |
| Constant in Block Design | Prefer `xilinx.com:inline_hdl:ilconstant:1.0`; Vivado 2025.2 reports `xlconstant` as deprecated. Query the catalog before instantiation. |
| Batch result | Do not trust the process exit code alone. Assert run `PROGRESS` and `STATUS`, and use the supplied batch driver. |
| Feature commands | Some IP Integrator and hardware commands appear only after loading the feature or opening a project. |
| BD output products | Set the BD file's `synth_checkpoint_mode` to `None` for Global synthesis when OOC generation fails with the Windows `C` error. |
| Interrupt concat | Query and prefer the 2025.2 inline `ilconcat` IP; legacy `xlconcat` can synthesize but is reported unsupported/deprecated. |

This behavior was locally verified with Vivado 2025.2 build 6299465 on Windows.
Re-query future releases rather than treating the table as permanent.

## Windows and Codex-managed shells

AMD's Windows loader may silently return code 1 if a managed process lacks
`PROCESSOR_ARCHITECTURE`. Use:

```powershell
./scripts/run-vivado-batch.ps1 -Source ./build.tcl
```

The wrapper supplies `AMD64` only when the variable is absent. It invokes
`scripts/vivado-batch-driver.tcl`, which catches top-level Tcl errors and returns
a nonzero process code. A sourced build script must not call `exit` itself.

Keep generated project paths short. Vivado may warn when Windows paths approach
the legacy 260-character limit.

If startup reports `Could not open 'C' for writing` and Tcl App loading errors,
first test the identical command outside the managed sandbox. Vivado can emit
this truncated path when a sandboxed process cannot write its per-user Vivado
or Tcl Store state. Confirm by comparing ACLs and by using a clean writable
`USERPROFILE`. Do not attribute the error to an older Vivado release merely
because its versioned cache exists, and do not edit the real manifest by
default.

In restricted Windows runners, Project Mode may fail in the generated run
wrapper because `cscript` cannot load its settings. This is distinct from a
design error. A valid fallback is an in-process Global flow using
`synth_design`, `opt_design`, `place_design`, `phys_opt_design`, `route_design`,
DRC/timing checks, and `write_bitstream`. Keep the `.xpr` and `.bd` so the result
remains GUI-openable. A bitstream written this way may not be associated with
`impl_1`; if `write_hw_platform -include_bit` rejects it, export a standard XSA
and deliver the separately verified `.bit` instead of claiming it is embedded.

## Run verification

```tcl
source ./scripts/vivado-compat.tcl
launch_runs synth_1 -jobs 4
vivado_wait_on_run synth_1
vivado_assert_run_complete synth_1
```

For implementation, also inspect timing summaries and DRC reports. A successful
shell process is not proof of successful synthesis, implementation, simulation,
or bitstream generation.

Never lower `UCIO-1` or `NSTD-1` severity for a real board design. That exception
is acceptable only for an explicitly labeled synthetic smoke test with no
physical programming.

## Hardware safety ladder

1. Open hardware manager.
2. Connect `hw_server` and enumerate targets/devices.
3. Report what is visible.
4. Program, reset, or modify a device only when the user explicitly requests it.

## Official references

- UG835 Vivado Tcl Commands: https://docs.amd.com/r/en-US/ug835-vivado-tcl-commands/Support-Resources
- UG835 `help`: https://docs.amd.com/r/en-US/ug835-vivado-tcl-commands/help
- UG994 Inline HDL: https://docs.amd.com/r/en-US/ug994-vivado-ip-subsystems/Inline-HDL
