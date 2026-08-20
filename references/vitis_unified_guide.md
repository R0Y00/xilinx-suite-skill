# Vitis Unified embedded workflow

## Vitis 2025.2 interface

Use the Python component API through `scripts/run-vitis-python.ps1`. Keep XSCT
for target discovery, JTAG download/debug, and legacy workspaces. Discover the
installed API with `inspect.signature`; do not reuse old `platform create`
examples blindly.

The generated workspace must be GUI-openable and contain `_ide` metadata and
`vitis-comp.json` for each platform/application component.

## Windows path budget

Vitis BSP/CMake builds create deep paths. Before creation, estimate the longest
object path, not just the workspace path. Use a short ASCII root and short
component/domain names when necessary, for example `D:/v/p`, `p`, `d`, `a`.
Paths that look reasonable at the workspace level can still exceed Windows'
roughly 260-character legacy limit in BSP objects and dependency files.

## Platform and application pattern

```python
from pathlib import Path
import vitis

ws = Path(r"D:\v")
xsa = Path(r"D:\hw\design.xsa")
client = vitis.create_client()
try:
    client.set_workspace(path=str(ws))
    platform = client.create_platform_component(
        name="p", hw_design=str(xsa), os="standalone",
        cpu="ps7_cortexa9_0", domain_name="d",
        template="hello_world", generate_dtb=False, compiler="gcc")
    platform.build()
    xpfm = ws / "p" / "export" / "p" / "p.xpfm"
    if not xpfm.is_file(): raise FileNotFoundError(xpfm)
    app = client.create_app_component(
        name="a", platform=str(xpfm), domain="d", template="hello_world")
    app.build()
    if not list((ws / "a").rglob("*.elf")):
        raise FileNotFoundError("ELF not generated")
    print("VITIS_SCRIPT_OK")
finally:
    vitis.dispose()
```

The wrapper requires `VITIS_SCRIPT_OK` because some Vitis/XSCT failures still
return native exit code zero. Verify BSP headers/library, XPFM, FSBL when needed,
and ELF before printing it.

## HLS driver and console details

With the 2025.2 SDT flow, generated HLS drivers may initialize with an address,
for example `XHls_accel_Initialize(&instance, UINTPTR BaseAddress)`, rather than
an older device-ID lookup. Read the generated header before writing the app.

The minimal standalone `xil_printf` is not full `printf`. Prefer `%d`, `%x`,
`%s`, and `%c`; do not rely on `%u`, `%lu`, floating point, width, or precision
without verifying the selected library implementation.

## Workspace locks

If Vitis reports a locked workspace, first identify whether a live Vitis server
or GUI owns it. Never remove a live owner's lock. After confirming the owner is
gone, remove only the stale lock for that exact workspace and retry.

Typical processors: Zynq-7000 `ps7_cortexa9_0`; Zynq UltraScale+
`psu_cortexa53_0` or `psu_cortexr5_0`; for Versal, query the XSA.
