## Overview

This repository contains scripts and configuration for creating a development environment targeting the Realtek [`r8169_rs`](https://github.com/guilherme-n-l/r8169_rs) kernel driver using [Nix](https://nixos.org). It allows researchers and kernel developers to iteratively build, test, and debug driver changes with a [QEMU](https://www.qemu.org/) virtualization setup, streamlining the process of porting and prototyping driver enhancements in Rust.

## Features

- QEMU-based virtual test platform for isolated driver development.
- Scripts for automating builds and integration with Linux kernel source trees.
- Shell and Nix-based components for reproducible environments.

## Getting Started

1. **Clone the repository:**
   ```
   git clone https://github.com/guilherme-n-l/linuxdrivers.git
   ```
2. **Review environment dependencies:**
   - Linux based operating system (NixOS or Nix environment friendly system)
   - Nix package manager

3. **Enter development environment**
   - For default environment:
   ```
   nix develop
   ```
   - For QEMU environment:
   ``` 
   nix develop .#virt
   ```
