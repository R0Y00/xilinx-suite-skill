# Attribution and modification notice

This repository is a derivative of:

- **xilinx-skill** by QingquanYao
- Upstream repository: https://github.com/QingquanYao/xilinx-skill
- Upstream revision reviewed during attribution audit:
  `ccffd3704c0cd133a763a805eee893bd9c6fcf56`
- Upstream license declaration: MIT

The upstream project supplied the original Xilinx toolchain skill structure
and a substantial part of the reference-document corpus. Files retained from
or adapted from upstream include material covering Vivado, XDC, Tcl, MPSoC,
PetaLinux, VU9P, JESD204, and official-document routing.

## Major changes in this repository

The derivative work has been substantially tested, extended, and reorganized,
including:

- native-Windows and Vivado 2025.2 compatibility rules;
- supported Vivado/Vitis launcher wrappers and failure-marker checks;
- Vitis HLS 2025.2 component-mode workflow;
- Vitis Unified 2025.2 Python component workflow;
- GUI-openable Vivado, HLS, and Vitis artifact requirements;
- Block Design Global/OOC synthesis guidance;
- Zynq-7000 PS, JTAG, UART, and hardware-validation workflow;
- board-example migration and version-discovery rules;
- additional safety boundaries for volatile programming and persistent flash;
- corrections derived from local end-to-end tool and hardware validation.

Copyright (c) 2026 QingquanYao for upstream portions.

Copyright (c) 2026 Royoo for modifications and additions in this repository.

See `LICENSE` for the MIT License terms applying to this distribution.
