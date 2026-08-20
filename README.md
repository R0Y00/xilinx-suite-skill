# xilinx-suite

面向 Codex 的 AMD/Xilinx FPGA 全工具链 skill，覆盖 Vivado、Vitis HLS、
Vitis Unified 与 PetaLinux，并针对原生 Windows 和 Vivado 2025.2 提供
版本感知与兼容性保护。

> A version-aware Codex skill for AMD/Xilinx FPGA development across Vivado,
> Vitis HLS, Vitis Unified, and PetaLinux.

> [!IMPORTANT]
> This is an unofficial community project. It is not affiliated with or
> endorsed by AMD. AMD, Xilinx, Vivado, and Vitis are trademarks of their
> respective owners.

## 为什么需要它

Xilinx/AMD 工具链在不同版本之间存在明显差异：Tcl 命令会变化，IP VLNV
会升级，Vitis 工程模型会调整，Windows 子进程、路径长度和用户配置也可能
影响构建。这个 skill 不把旧例程直接套到新版本，而是先查询本机工具、器件
和命令，再生成和验证工程。

它特别关注以下问题：

- Vivado 2025.2 中已变化或弃用的 Tcl/IP Integrator 用法；
- BD Generate Output Products 的 Global/OOC 综合差异；
- Windows 长路径、受限运行环境和子进程启动问题；
- Vitis HLS 2025.2 的 component 工作流与官方启动器；
- Vitis Unified 的 platform/domain/application component；
- 老版本板卡工程向新工具链迁移；
- JTAG 编程与 UART 结果验证的安全边界；
- 生成真实可由 GUI 打开的 `.xpr`、`.bd` 和 `vitis-comp.json`，而不只是
  一组命令行脚本。

## 能力范围

| 领域 | 主要能力 |
|---|---|
| Vivado | RTL、XDC、IP Catalog、Block Design、AXI、仿真、综合、实现、时序、DRC、bitstream、XSA |
| Vitis HLS | C/C++ 仿真、综合、C/RTL 协同仿真、AXI 接口、IP 导出与 Vivado 集成 |
| Vitis Unified | 平台、domain、BSP、FSBL、应用组件、XPFM、ELF |
| Zynq/MPSoC | PS7/PSU、DDR、MIO、FCLK、复位、中断、地址映射、启动流程 |
| 硬件调试 | hw_server、目标枚举、JTAG 临时下载、UART 标记验证 |
| PetaLinux | XSA、BSP、设备树、内核、rootfs、BOOT.BIN 及常见数据通路参考 |
| 专项参考 | JESD204、VU9P、gRPC/ZMQ/udmabuf/AXI DMA |

## 已实测的基线

当前版本在以下环境完成过端到端验证：

- Windows 原生工具链；
- Vivado 2025.2；
- Vitis HLS 2025.2 component 模式；
- Vitis Unified 2025.2 Python component API；
- Zynq-7000 `xc7z100`；
- 自定义 HLS AXI4-Lite IP；
- Vivado BD、地址分配、中断、综合、布局布线、bitstream 与 XSA；
- standalone 应用、JTAG 下载与 UART 自检结果。

其他器件族和版本由版本发现规则与参考文档覆盖，但仍应在目标机器和目标器件
上重新验证。PetaLinux 通常要求匹配的 Linux 环境。

## 安装

将整个仓库复制或克隆到 Codex 的个人 skills 目录：

```powershell
$destination = Join-Path $env:USERPROFILE '.codex\skills\xilinx-suite'
Copy-Item -Recurse -Force . $destination
```

重新启动 Codex，或新建一个任务，使 skill 清单重新加载。

## 使用

可以显式指定：

```text
使用 $xilinx-suite，为 xc7z020 创建带 AXI DMA 的 Vivado 2025.2 Block Design。
```

安装后，下列请求也应自动触发该 skill：

```text
把这个 Vivado 2018.3 的 Zynq 工程迁移到 2025.2。
```

```text
把这个 C++ 模块做成 Vitis HLS AXI4-Lite IP，并集成到 BD。
```

```text
检查实现后的 timing、DRC，并生成 bitstream 和 XSA。
```

## 设计原则

1. **本机工具输出优先**：先查询版本、命令语法、器件和 IP Catalog。
2. **按版本生成**：不默认复用旧版 Tcl、XSCT 或 HLS 示例。
3. **GUI 与自动化并存**：自动化结果必须保留标准 GUI 工程和组件。
4. **逐级验证**：从语法、BD validation、仿真到综合、实现和硬件验证。
5. **硬件操作需授权**：枚举目标可以只读执行；编程、复位、下载 ELF 或写
   Flash 必须得到明确许可。
6. **易失与持久操作分离**：JTAG 临时加载不等同于 QSPI/eMMC/Flash 写入。

## Vivado 2025.2 / Windows 注意事项

- 原生 Windows 启动器可能依赖 `PROCESSOR_ARCHITECTURE=AMD64`；仓库中的
  PowerShell wrapper 会在缺失时为子进程补充该变量。
- 不要直接运行 `unwrapped/win64.o/vitis-run.exe`。使用官方
  `Vitis/bin/vitis-run.bat`，否则可能缺少 `xv_xocc_common.dll`。
- Vitis HLS 2025.2 优先使用 `open_component`，不要假定旧版
  `open_project/open_solution` 流程仍然适用。
- BD OOC 输出生成遇到 `Could not open 'C' for writing` 时，可改用 Global：

  ```tcl
  set_property synth_checkpoint_mode None [get_files <design>.bd]
  ```

- Windows 工程根目录应尽量短。Vitis BSP/CMake 的最终对象路径远长于工作区
  路径，短组件名也很重要。
- 不要只检查进程退出码；Vivado/Vitis 某些失败仍可能返回 0。应同时验证 run
  状态和实际产物。

## 仓库结构

```text
xilinx-suite/
├── SKILL.md                 # skill 入口、路由、执行与安全规则
├── agents/
│   └── openai.yaml          # 展示名称和默认提示
├── references/              # 按任务加载的工具链参考
│   ├── hls_guide.md
│   ├── vitis_unified_guide.md
│   ├── vivado_version_compat.md
│   ├── board_migration_and_hardware_validation.md
│   └── ...
└── scripts/
    ├── run-vivado-batch.ps1
    ├── run-vitis-hls.ps1
    ├── run-vitis-python.ps1
    ├── vivado-batch-driver.tcl
    └── vivado-compat.tcl
```

## 辅助脚本

```powershell
# Vivado Tcl batch
./scripts/run-vivado-batch.ps1 -Source ./build.tcl

# Vitis HLS 2025.2
./scripts/run-vitis-hls.ps1 -Source ./run_hls.tcl

# Vitis Unified Python API
./scripts/run-vitis-python.ps1 -Source ./build_vitis.py
```

HLS 脚本应在成功验证导出 IP 后打印 `HLS_FLOW_PASS`；Vitis Python 脚本应在
确认 XPFM/ELF 存在后打印 `VITIS_SCRIPT_OK`。wrapper 会把缺少这些标记视为
失败。

## 安全说明

该 skill 可以生成硬件编程命令，但不会把“构建 bitstream”自动解释为“修改已
连接设备”。写配置存储器、烧录 QSPI/eMMC/Flash、复位处理器或运行 ELF 都是
独立的硬件操作，需要用户明确授权和目标确认。

请始终核对完整 FPGA part、板卡电源与 JTAG/UART 连接，并保留原始约束和厂商
资料。

## 贡献

欢迎提交针对其他 Vivado/Vitis 版本、器件族和板卡的可复现实测结果。新增规则
时请说明：

- 工具完整版本；
- 目标 part/board；
- 原始错误或行为；
- 最小复现步骤；
- 验证过的修复及产物。

避免把用户名、绝对工程路径、板卡私有资料或生成产物提交到仓库。

## 来源与致谢

本项目基于
[QingquanYao/xilinx-skill](https://github.com/QingquanYao/xilinx-skill)
修改和扩展。感谢原作者 QingquanYao 提供的 Xilinx 工具链 skill 结构与参考
资料。

本项目在上游基础上重点增加和重构了 Vivado/Vitis 2025.2、原生 Windows、
GUI 可打开工程、Vitis HLS component、Vitis Unified、Zynq-7000、JTAG/UART
实机验证、版本兼容和安全执行等内容。

上游项目声明采用 MIT License。具体来源、保留内容和主要修改见
[NOTICE.md](NOTICE.md)。

## 许可证

本项目采用 [MIT License](LICENSE)，并保留上游项目的来源与版权说明。
