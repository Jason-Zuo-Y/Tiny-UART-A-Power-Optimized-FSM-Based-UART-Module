# Tiny-UART: 低功耗有限状态机 UART 收发器

[Click here to English version](#tiny-uart-a-power-optimized-fsm-based-uart-module)
## 📖 项目简介 (Introduction)

这是一个基于 FSM（有限状态机）设计的轻量级、低功耗 UART 通信模块。它非常适合用于基础模块间通信、SoC 外设学习，以及理解异步串行通信协议的底层实现。

本项目包含两个由独立状态机驱动的子模块，分别负责发送（TX）与接收（RX）任务。其核心亮点在于**动态功耗优化**：每个子模块内部均配有一个计数分频器，可根据任务需求按需唤醒；当收发任务均处于空闲状态时，分频器会自动关闭（Clock Gating），从而降低系统的静态功耗。

## ⚙️ 核心参数 (Specifications)

*   **通信协议**：发送端 (TX) 为 `8N2`（8数据位，无校验，2停止位）；接收端 (RX) 为 `8N1`（8数据位，无校验，1停止位）。
*   **RX 采样机制**：基于 2 倍波特率的中心对齐单次采样（2x Oversampling, center-aligned single-point sampling）。
*   **RX 输出行为**：若接收时未检测到有效数据帧（如帧错误），则输出 `0x00`；若接收成功，则输出有效数据帧并保持至下一帧接收完成。

## 📄 开源协议与交流 (License & Contact)

本项目基于 **MIT License** 分发。欢迎大家提交 Issue 交流改进见解或探讨设计思路。作者正在硬件设计的道路上努力探索，期待与各位交流！

---

# Tiny-UART: A Power-Optimized FSM-Based UART Module

[中文版本请点这里](#tiny-uart-低功耗有限状态机-uart-收发器)

## 📖 Introduction

This is a lightweight, low-power UART communication module implemented in SystemVerilog, designed using Finite State Machines (FSM). It is highly suitable for simple inter-module communication, SoC peripheral learning, and understanding the low-level implementation of asynchronous serial protocols.

The project consists of two independent sub-modules (TX and RX), each driven by its own FSM. A key architectural highlight is the **dynamic power optimization**: each sub-module features an internal counter-based clock divider that can be awakened on-demand. When both TX and RX tasks are idle, the clock dividers automatically shut down to minimize static power consumption.

## ⚙️ Specifications

*   **Protocol**: TX operates at `8N2` (8 data bits, no parity, 2 stop bits); RX operates at `8N1` (8 data bits, no parity, 1 stop bit).
*   **RX Sampling**: 2x oversampling with center-aligned single-point sampling.
*   **RX Output Behavior**: Outputs `0x00` if an invalid data frame is detected (e.g., dataframe error); otherwise, outputs the valid received byte and holds it until the next valid frame arrives.

## 📄 License & Contact

Distributed under the **MIT License**. Contributions, issues, and discussions are highly welcomed. The author is a student actively learning digital IC design and looks forward to any feedback!
