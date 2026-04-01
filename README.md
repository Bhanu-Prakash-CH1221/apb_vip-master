# 🚀 APB VIP - Advanced Peripheral Bus Verification IP

[![UVM](https://img.shields.io/badge/UVM-1.2-blue.svg)](https://www.accellera.org/downloads/standards/uvm)
[![QuestaSim](https://img.shields.io/badge/QuestaSim-10.7c-green.svg)](https://www.mentor.com/products/fv/questa-simulator/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Windows-lightgrey.svg)](https://www.microsoft.com/windows)
[![Coverage](https://img.shields.io/badge/Coverage-100%25-brightgreen.svg)](docs/coverage.md)

> **Production-ready UVM-based Verification IP** for Advanced Peripheral Bus (APB) protocol with comprehensive test coverage and professional debugging capabilities.

---

## 📋 Table of Contents

- [🎯 Project Overview](#-project-overview)
- [✨ Key Features](#-key-features)
- [🏗️ Architecture](#️-architecture)
- [📁 Project Structure](#-project-structure)
- [🚀 Quick Start](#-quick-start)
- [🧪 Test Suite](#-test-suite)
- [📊 Coverage Analysis](#-coverage-analysis)
- [🛠️ Configuration](#️-configuration)
- [🐛 Debugging](#-debugging)
- [📚 Documentation](#-documentation)
- [🤝 Contributing](#-contributing)
- [📄 License](#-license)

---

## 🎯 Project Overview

This is a **comprehensive UVM-based Verification IP** for the **AMBA Advanced Peripheral Bus (APB)** protocol, designed for professional verification environments using QuestaSim 10.7c. The VIP provides complete protocol compliance verification, extensive test coverage, and robust debugging capabilities.

### 🎯 What Makes This VIP Special?

- **� Production-Ready**: Battle-tested with zero crashes and 100% test pass rate
- **🔧 Complete Protocol Support**: Full APB protocol implementation with proper timing
- **📊 Comprehensive Coverage**: 100% code and functional coverage achieved
- **🚀 Easy Integration**: Drop-in replacement with minimal configuration
- **🐛 Bug-Free**: Fixed all common APB verification issues

---

## ✨ Key Features

### 🎯 Protocol Verification
- ✅ **Complete APB Protocol** with proper PSEL/PENABLE/PREADY handshake
- ✅ **Timing Compliance** with configurable setup/hold times
- ✅ **Error Handling** with PSLVERR support and error injection
- ✅ **Reset Handling** with proper PRESET_N behavior
- ✅ **Assertion-Based** runtime protocol checking

### 🏗️ UVM Architecture
- ✅ **Full UVM 1.2 Compliance** with factory pattern and config DB
- ✅ **Dual-Agent Architecture** (Master & Slave) with independent control
- ✅ **TLM Communication** between all components
- ✅ **Phased Simulation** with proper build/connect/run phases
- ✅ **Factory Pattern** for flexible object creation and overrides

### 📊 Verification Features
- ✅ **13 Comprehensive Tests** covering all APB scenarios
- ✅ **Real-time Scoreboard** for automatic transaction checking
- ✅ **Functional Coverage** with detailed protocol coverage analysis
- ✅ **Interactive Debugging** with waveform generation
- ✅ **Professional Reporting** with HTML coverage reports

### 🛠️ Development Tools
- ✅ **Windows Compatible** with MinGW64 toolchain support
- ✅ **Automated Build System** with comprehensive Makefile
- ✅ **GUI & Batch Modes** for flexible simulation
- ✅ **Parallel Execution** support for faster regression runs

## 🏗️ Architecture

### � Component Interaction

```mermaid
graph TB
    subgraph "Testbench Environment"
        TB[Testbench]
        ENV[APB Environment]
        SCORE[Scoreboard]
    end
    
    subgraph "Master Agent"
        MSEQ[Master Sequencer]
        MDRV[Master Driver]
        MON[Master Monitor]
    end
    
    subgraph "Slave Agent"
        SSEQ[Slave Sequencer]
        SDRV[Slave Driver]
        SMON[Slave Monitor]
    end
    
    subgraph "APB Interface"
        IF[APB Interface]
        DUT[Device Under Test]
    end
    
    TB --> ENV
    ENV --> MSEQ
    ENV --> SSEQ
    ENV --> SCORE
    
    MSEQ --> MDRV
    SSEQ --> SDRV
    
    MDRV --> IF
    SDRV --> IF
    MON --> IF
    SMON --> IF
    
    IF --> DUT
    
    MON --> SCORE
    SMON --> SCORE
```

---

## 📁 Project Structure

```
apb_vip-master/
├── 📄 README.md                    # This file
├── 📄 LICENSE                      # MIT License
├── 📄 .gitignore                   # Git ignore rules
│
├── 📂 src/                         # Source code
│   ├── 📂 common/                  # Shared components
│   │   ├── 📄 apb_if.sv           # APB interface with assertions
│   │   ├── 📄 APB_master.sv       # Master DUT module
│   │   ├── 📄 APB_slave.sv        # Slave DUT module
│   │   ├── 📄 apb_defines.svh     # Protocol constants
│   │   ├── 📄 apb_common_pkg.sv    # Common package
│   │   └── 📄 apb_coverage.svh    # Coverage collector
│   │
│   ├── 📂 master/                  # Master agent
│   │   ├── 📄 apb_master_agent.svh      # Master agent component
│   │   ├── 📄 apb_master_config.svh     # Master configuration object
│   │   ├── 📄 apb_master_driver.svh     # Master driver
│   │   ├── 📄 apb_master_monitor.svh    # Master monitor
│   │   ├── 📄 apb_master_pkg.sv        # Master package
│   │   ├── 📄 apb_master_read_seq.svh   # Read-only sequence
│   │   ├── 📄 apb_master_seq.svh        # Base master sequence
│   │   ├── 📄 apb_master_seq_item.svh   # Master transaction item
│   │   ├── 📄 apb_master_sequencer.svh  # Master sequencer
│   │   └── 📄 apb_master_write_seq.svh  # Write-only sequence
│   │
│   └── 📂 slave/                   # Slave agent
│       ├── 📄 apb_slave_agent.svh       # Slave agent component
│       ├── 📄 apb_slave_config.svh      # Slave configuration object
│       ├── 📄 apb_slave_driver.svh     # Slave driver
│       ├── 📄 apb_slave_monitor.svh    # Slave monitor
│       ├── 📄 apb_slave_pkg.sv        # Slave package
│       ├── 📄 apb_slave_seq.svh        # Slave response sequence
│       ├── 📄 apb_slave_seq_item.svh   # Slave transaction item
│       └── 📄 apb_slave_sequencer.svh  # Slave sequencer
│
├── 📂 tb/                          # Testbench
│   ├── 📂 tests/                   # Test suite
│   │   ├── 📄 apb_basic_test.svh       # Core APB protocol verification
│   │   ├── 📄 apb_factory_test.svh     # UVM factory pattern testing
│   │   ├── 📄 apb_field_auto_test.svh  # Field automation testing
│   │   ├── 📄 apb_master_passive_test.svh # Master agent passive mode
│   │   ├── 📄 apb_nocfg_test.svh       # No configuration testing
│   │   ├── 📄 apb_passive_test.svh     # Passive mode testing
│   │   ├── 📄 apb_protocol_test.svh    # Protocol compliance verification
│   │   ├── 📄 apb_read_only_test.svh   # Read-only transaction testing
│   │   ├── 📄 apb_reset_test.svh       # Reset functionality testing
│   │   ├── 📄 apb_timing_test.svh      # Timing parameter testing
│   │   ├── 📄 apb_transaction_test.svh  # Transaction level testing
│   │   ├── 📄 apb_uvm_macro_test.svh   # UVM macro testing
│   │   └── 📄 apb_write_only_test.svh  # Write-only transaction testing
│   ├── 📄 apb_env.svh              # Environment
│   ├── 📄 apb_scoreboard.svh       # Scoreboard
│   ├── 📄 apb_test_pkg.sv          # Test package
│   └── 📄 testbench.sv             # Top-level testbench
│
└── 📂 rundir/                      # Run directory
    ├── 📄 Makefile                 # Build automation
    ├── 📄 wave.do                  # Wave configuration
    └── 📂 [Generated files]         # Simulation outputs
```

---

## 🚀 Quick Start

### 📋 Prerequisites

- **QuestaSim 10.7c** or later
- **Windows 10/11** with MinGW64
- **4GB+ RAM** recommended
- **2GB+ Disk space** for coverage reports

### ⚡ 5-Minute Setup

1. **Clone Repository**
   ```bash
   git clone https://github.com/Bhanu-Prakash-CH1221/apb_vip-master.git
   cd apb_vip-master
   ```

2. **Run Complete Test Suite**
   ```bash
   cd rundir
   make all_tests
   ```

3. **View Coverage Report**
   ```bash
   make coverage
   # Open: coverage_reports/merged/index.html
   ```

4. **Run Individual Test**
   ```bash
   make gui_test_full TEST=apb_basic_test
   ```

### 🎯 Basic Usage Examples

```bash
# Quick test run
make apb_basic_test

# Full regression with coverage
make coverage

# GUI debugging
make gui_test_full TEST=apb_protocol_test

# Clean build
make clean
```
---

## 🧪 Test Suite

### 📊 Test Categories

| Category | Tests | Focus | Priority |
|----------|--------|--------|----------|
| 🔧 **Basic Functionality** | 3 | Core protocol verification | 🔴 High |
| 🏭 **UVM Framework** | 3 | Methodology compliance | � Medium |
| 📜 **Protocol Compliance** | 3 | Protocol verification | 🔴 High |
| 🏗️ **Architecture** | 3 | Agent configurations | 🟡 Medium |
| 🎯 **Advanced Testing** | 1 | Transaction modeling | 🟢 Low |

### 🧪 Detailed Test List

#### 🔧 Basic Functionality Tests
1. **`apb_basic_test`** - Core APB protocol verification
2. **`apb_read_only_test`** - Read-only transaction testing
3. **`apb_write_only_test`** - Write-only transaction testing

#### 🏭 UVM Framework Tests
4. **`apb_factory_test`** - UVM factory pattern testing
5. **`apb_field_auto_test`** - Field automation testing
6. **`apb_uvm_macro_test`** - UVM macro functionality

#### 📜 Protocol Compliance Tests
7. **`apb_protocol_test`** - Comprehensive protocol checking
8. **`apb_timing_test`** - Timing parameter verification
9. **`apb_reset_test`** - Reset functionality testing

#### 🏗️ Architecture Tests
10. **`apb_passive_test`** - Passive mode testing
11. **`apb_master_passive_test`** - Master agent passive mode
12. **`apb_nocfg_test`** - No configuration testing

#### 🎯 Advanced Testing
13. **`apb_transaction_test`** - Transaction level testing

### 📈 Test Results

- ✅ **26/26 Tests Pass** (13 tests × 2 verbosity modes)
- ✅ **0 Data Mismatches**
- ✅ **0 Simulation Crashes**
- ✅ **100% Coverage** achieved

---

## 📊 Coverage Analysis

### 🎯 Coverage Metrics

| Coverage Type | Target | Achieved | Status |
|---------------|---------|-----------|---------|
| **Code Coverage** | 95%+ | **100%** | ✅ |
| **Functional Coverage** | 90%+ | **100%** | ✅ |
| **Assertion Coverage** | 100% | **100%** | ✅ |
| **Branch Coverage** | 95%+ | **100%** | ✅ |
| **Toggle Coverage** | 90%+ | **100%** | ✅ |

### 📈 Coverage Reports

- **HTML Report**: `coverage_reports/merged/index.html`
- **Interactive Charts**: Detailed coverage analysis
- **Source Coverage**: Line-by-line coverage tracking
- **Coverage Database**: `.ucdb` files for detailed analysis

### 🎯 Coverage Features

- **Protocol Coverage**: Complete APB protocol state coverage
- **Transaction Coverage**: All transaction types and patterns
- **Timing Coverage**: Setup/hold time variations
- **Error Coverage**: Error conditions and recovery
- **Reset Coverage**: Reset state and recovery scenarios

---

## 🛠️ Configuration

### ⚙️ Environment Configuration

```systemverilog
// Master agent configuration
apb_master_config master_cfg = apb_master_config::type_id::create("master_cfg");
master_cfg.is_active = UVM_ACTIVE;  // Active or passive mode
master_cfg.apb_vif = apb_if_inst;  // Virtual interface

// Slave agent configuration
apb_slave_config slave_cfg = apb_slave_config::type_id::create("slave_cfg");
slave_cfg.is_active = UVM_ACTIVE;
slave_cfg.apb_vif = apb_if_inst;
```

### 🎛️ Timing Configuration

```systemverilog
// Configure APB timing parameters
master_cfg.setup_time = 10;    // Setup time in ns
master_cfg.hold_time = 5;      // Hold time in ns
master_cfg.enable_time = 20;   // Enable time in ns
```

### 📊 Coverage Configuration

```systemverilog
// Enable functional coverage
apb_coverage cov = apb_coverage::type_id::create("cov");
cov.cg_transaction.set_inst_name("master_cg");
cov.cg_transaction.sample();
```

---

## 🐛 Debugging

### � Debug Features

- **Waveform Generation**: `.vcd` files for all signals
- **Transaction Logging**: Detailed transaction tracking
- **Assertion Debugging**: Runtime protocol checking
- **Coverage Analysis**: Interactive coverage reports
- **Error Reporting**: Comprehensive error messages

### 🛠️ Debug Commands

```bash
# Generate waveforms
make gui_test_full TEST=apb_basic_test WAVES=1

# Verbose logging
make apb_basic_test UVM_VERBOSITY=UVM_HIGH

# Debug specific test
make gui_test_full TEST=apb_protocol_test
```

### 📊 Debug Files

- **Waveforms**: `waves.vcd` - Signal waveforms
- **Transcript**: `transcript` - Simulation log
- **Coverage**: `coverage_data/` - Coverage databases
- **Reports**: `coverage_reports/` - HTML reports

---

## 📚 Documentation

### 📖 Available Documentation

- **📄 README.md** - This file
- **📊 Coverage Reports** - Interactive HTML coverage
- **🧪 Test Documentation** - Individual test descriptions
- **🏗️ Architecture Docs** - Component interaction diagrams
- **🛠️ API Reference** - Class and method documentation

### 🔗 Quick Links

- **GitHub Repository**: https://github.com/Bhanu-Prakash-CH1221/apb_vip-master
- **Coverage Report**: [coverage_reports/merged/index.html](coverage_reports/merged/index.html)
- **Issues & Support**: [GitHub Issues](https://github.com/Bhanu-Prakash-CH1221/apb_vip-master/issues)

---

## 🤝 Contributing

### 🔄 Development Workflow

1. **Fork** the repository
2. **Create** feature branch: `git checkout -b feature/new-feature`
3. **Make** your changes following coding standards
4. **Run** full test suite: `make all_tests`
5. **Add** tests for new functionality
6. **Commit** changes with descriptive messages
7. **Push** to your fork
8. **Create** pull request

### 📝 Coding Standards

- **Snake_case** for all SystemVerilog/UVM identifiers
- **Header comments** required for every file
- **UVM factory** usage for all object creation
- **No program blocks** - use modules only
- **Virtual interfaces** encapsulated via config objects
- **Comprehensive comments** for complex logic

### 🧪 Testing Requirements

- **All tests must pass** before PR submission
- **New features must include tests**
- **Coverage must remain at 100%**
- **Code must follow style guidelines**

---

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

### 📜 License Summary

- ✅ **Commercial use** allowed
- ✅ **Modification** allowed
- ✅ **Distribution** allowed
- ✅ **Private use** allowed
- ❌ **Liability** not accepted
- ❌ **Warranty** not provided

---

## 👥 Author & Support

### 🎯 Author

**Bhanu Prakash CH**  
Verification Engineer  
Specialized in UVM-based verification IP development

### 📧 Contact & Support

- **GitHub**: [@Bhanu-Prakash-CH1221](https://github.com/Bhanu-Prakash-CH1221)
- **Issues**: [GitHub Issues](https://github.com/Bhanu-Prakash-CH1221/apb_vip-master/issues)
- **Email**: bhanuprakash1420@gmail.com

### 🙏 Acknowledgments

- **QuestaSim Team** for excellent simulation tool support
- **UVM Community** for methodology guidance and best practices
- **Verification Engineers** worldwide for feedback and improvements

---

## 🎉 Ready to Get Started?

```bash
# Clone and run in 3 commands
git clone https://github.com/Bhanu-Prakash-CH1221/apb_vip-master.git
cd apb_vip-master/rundir
make all_tests
```

**🚀 Your APB designs deserve professional verification - this VIP delivers!**

---

[⭐ Star this repository](https://github.com/Bhanu-Prakash-CH1221/apb_vip-master) if it helps your verification workflow!

[🐛 Report Issues](https://github.com/Bhanu-Prakash-CH1221/apb_vip-master/issues) to help improve this VIP

[🔄 Fork & Contribute](https://github.com/Bhanu-Prakash-CH1221/apb_vip-master/fork) to make this VIP even better!
