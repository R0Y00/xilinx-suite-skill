# Board migration and hardware validation

## Migrate evidence, not assumptions

Treat a vendor's old project as board evidence, not as a reusable release-pinned
solution. Extract the exact part, PS preset, DDR/MIO configuration, XDC pinout,
IP parameters, address map, clocks, resets, and external interfaces from its
`.xpr`, `.bd`, `.xci`, Tcl, and XDC files. Keep these facts in a board-specific
layer; keep the general flow reusable across boards.

If Vivado Tcl cannot reliably source an asset from a Unicode path, copy only the
required source/preset into a short ASCII task workspace and record its origin.
Do not modify the vendor archive.

For an old PS7 preset, apply it first, then discover current properties with
`list_property` and override only the additions needed by the new PL design,
such as GP AXI, FCLK, reset, or fabric IRQ. Query `get_ipdefs` for current VLNVs
and validate the BD after every connection/address phase.

## GUI-native acceptance

The migrated result must include a normal `.xpr`, editable `.bd`, complete IP
repository, sources/constraints/runs, and a Vitis workspace with component
metadata. Opening the GUI must not depend on rerunning the automation script.

## Hardware safety and proof

1. Enumerate `hw_server` targets and exact devices read-only.
2. Match the enumerated silicon to the project part.
3. Obtain explicit authorization before programming, reset, or ELF download.
4. Distinguish volatile FPGA/JTAG programming from persistent QSPI/eMMC/flash
   writes. Never perform the latter unless specifically requested.
5. Program the bitstream, initialize PS/DDR as required, download the exact ELF,
   and run it.
6. Capture UART with the board's verified port and settings. Require a fresh boot
   marker followed by a deterministic PASS value; stale serial text is not proof.

Keep JTAG and UART logs. Report the target selector, part, bit/ELF paths, baud
rate, and marker. Disconnect tools cleanly when done; volatile code may continue
running after `hw_server` disconnects.
