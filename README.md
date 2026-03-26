# APB VIP - Advanced Peripheral Bus Verification IP

## 🎯 Project Overview

This is a **production-ready UVM-based Verification IP (VIP)** for the **Advanced Peripheral Bus (APB) protocol**, specifically designed for SystemVerilog verification environments using QuestaSim 10.7c. The VIP provides complete protocol compliance verification, comprehensive test coverage, and robust debugging capabilities for APB-based designs.

### 🏗️ Architecture Highlights
- **Full UVM 1.2 Compliance** with factory pattern, configuration database, and TLM communication
- **Complete APB Protocol Implementation** with proper timing and handshake mechanisms  
- **Dual-Agent Architecture** (Master & Slave) with independent drivers, monitors, and sequencers
- **Real-time Scoreboard** for automatic transaction checking and data integrity verification
- **Built-in Assertions** for runtime protocol verification
- **Comprehensive Coverage Analysis** with HTML reporting

### 🎯 Key Features
- ✅ **12 Comprehensive Test Scenarios** covering protocol compliance, timing, reset, and edge cases
- ✅ **Zero Data Mismatches** - Fixed race conditions and timing issues
- ✅ **Crash-Free Simulation** - Resolved SIGSEGV errors during reset transitions
- ✅ **Professional Documentation** with clear usage instructions
- ✅ **Windows-Compatible** with MinGW64 toolchain support
- ✅ **Production-Ready** with proven stability and reliability

## 📁 Complete Project Structure

```
apb_vip-master/
├── 📄 README.md                    # This file - comprehensive project documentation
├── 📄 .gitignore                   # Git ignore rules for simulation artifacts
│
├── 📂 src/                         # Source code directory
│   ├── 📂 common/                  # Shared components across agents
│   │   ├── 📄 APB_master.sv        # Master-side APB interface module
│   │   ├── 📄 APB_slave.sv         # Slave-side APB interface module  
│   │   ├── 📄 apb_base_seq_item.svh # Base transaction item class
│   │   ├── 📄 apb_common_pkg.sv     # Common package with shared definitions
│   │   ├── 📄 apb_coverage.svh     # Coverage collector for APB protocol
│   │   ├── 📄 apb_defines.svh      # Protocol-wide constants and definitions
│   │   └── 📄 apb_if.sv            # Main APB interface with assertions
│   │
│   ├── 📂 master/                  # Master agent implementation
│   │   ├── 📄 apb_master_agent.svh     # Master agent component
│   │   ├── 📄 apb_master_config.svh    # Master configuration object
│   │   ├── 📄 apb_master_driver.svh    # Master driver (drives PSEL/PENABLE/PWRITE)
│   │   ├── 📄 apb_master_monitor.svh   # Master monitor (captures transactions)
│   │   ├── 📄 apb_master_pkg.sv        # Master package with all components
│   │   ├── 📄 apb_master_read_seq.svh  # Read-only sequence
│   │   ├── 📄 apb_master_seq.svh       # Base master sequence
│   │   ├── 📄 apb_master_seq_item.svh  # Master-specific transaction item
│   │   ├── 📄 apb_master_sequencer.svh # Master sequencer
│   │   ├── 📄 apb_master_write_seq.svh # Write-only sequence
│   │   └── 📄 apb_master_driver.sv     # Master driver module
│   │
│   └── 📂 slave/                   # Slave agent implementation
│       ├── 📄 apb_slave_agent.svh       # Slave agent component
│       ├── 📄 apb_slave_config.svh      # Slave configuration object
│       ├── 📄 apb_slave_driver.svh      # Slave driver (drives PREADY/PRDATA)
│       ├── 📄 apb_slave_monitor.svh     # Slave monitor (captures responses)
│       ├── 📄 apb_slave_pkg.sv          # Slave package with all components
│       ├── 📄 apb_slave_seq.svh         # Slave response sequence
│       ├── 📄 apb_slave_seq_item.svh    # Slave-specific transaction item
│       ├── 📄 apb_slave_sequencer.svh   # Slave sequencer
│       └── 📄 apb_slave_driver.sv       # Slave driver module
│
├── 📂 tb/                          # Testbench directory
│   ├── 📂 tests/                   # Comprehensive test suite
│   │   ├── 📄 apb_basic_test.svh       # Basic APB protocol verification
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
│   │
│   ├── 📄 apb_env.svh               # Testbench environment (contains both agents)
│   ├── 📄 apb_scoreboard.svh       # Transaction scoreboard (data integrity checking)
│   ├── 📄 apb_test_pkg.sv          # Test package with all test registrations
│   └── 📄 testbench.sv             # Top-level testbench module
│
└── 📂 rundir/                      # Run directory with build scripts
    ├── 📄 Makefile                 # Complete build and simulation automation
    └── 📂 [Generated during simulation - .gitignored]
        ├── coverage_data/          # Coverage database files (.ucdb)
        ├── coverage_reports/       # HTML coverage reports
        └── work/                   # Compiled simulation libraries
```

### 📋 File Descriptions

#### **Core Source Files**
- **`apb_if.sv`** - Main APB interface with protocol assertions and timing checks
- **`apb_base_seq_item.svh`** - Base transaction class with common properties
- **`apb_defines.svh`** - Protocol-wide constants and timing parameters

#### **Master Agent**
- **`apb_master_driver.svh`** - Drives PSEL, PENABLE, PWRITE, PADDR, PWDATA signals
- **`apb_master_monitor.svh`** - Captures master transactions with proper timing
- **`apb_master_sequencer.svh`** - Manages master transaction sequences

#### **Slave Agent**  
- **`apb_slave_driver.svh`** - Drives PREADY, PRDATA, PSLVERR signals
- **`apb_slave_monitor.svh`** - Captures slave responses
- **`apb_slave_sequencer.svh`** - Manages slave response sequences

#### **Testbench Components**
- **`apb_env.svh`** - UVM environment containing master and slave agents
- **`apb_scoreboard.svh`** - Compares master transactions with slave responses
- **`testbench.sv`** - Top-level module with DUT instance and interface connections

## 🧪 Comprehensive Test Suite

### **Test Categories & Descriptions**

#### **🔧 Basic Functionality Tests**
1. **`apb_basic_test`** - **Core APB Protocol Verification**
   - Tests basic read/write transactions
   - Verifies PSEL/PENABLE/PREADY handshake
   - Validates proper timing relationships

2. **`apb_read_only_test`** - **Read-Only Transaction Testing**
   - Focuses exclusively on read operations
   - Tests address decoding and data return
   - Validates read timing compliance

3. **`apb_write_only_test`** - **Write-Only Transaction Testing**
   - Focuses exclusively on write operations  
   - Tests data integrity during writes
   - Validates write timing compliance

#### **⚙️ UVM Framework Tests**
4. **`apb_factory_test`** - **UVM Factory Pattern Testing**
   - Tests object creation via factory
   - Validates type override mechanisms
   - Verifies component instantiation

5. **`apb_field_auto_test`** - **Field Automation Testing**
   - Tests UVM field macros functionality
   - Validates automatic field registration
   - Verifies copy/compare/print utilities

6. **`apb_uvm_macro_test`** - **UVM Macro Testing**
   - Tests common UVM macros (`uvm_info`, `uvm_error`, etc.)
   - Validates reporting mechanisms
   - Verifies macro expansion

#### **🔄 Protocol Compliance Tests**
7. **`apb_protocol_test`** - **Protocol Compliance Verification**
   - Comprehensive APB protocol checking
   - Tests edge cases and corner conditions
   - Validates assertion coverage

8. **`apb_timing_test`** - **Timing Parameter Testing**
   - Tests configurable timing parameters
   - Validates setup/hold time requirements
   - Tests clock domain crossing

9. **`apb_reset_test`** - **Reset Functionality Testing**
   - Tests PRESET_N assertion/deassertion
   - Validates reset recovery behavior
   - Tests reset during active transactions

#### **🏗️ Architecture Tests**
10. **`apb_passive_test`** - **Passive Mode Testing**
    - Tests agents in passive monitoring mode
    - Validates monitor-only functionality
    - Tests scoreboard with passive agents

11. **`apb_master_passive_test`** - **Master Agent Passive Mode**
    - Tests master agent in passive mode
    - Validates slave agent active operation
    - Tests mixed active/passive configurations

12. **`apb_nocfg_test`** - **No Configuration Testing**
    - Tests VIP without explicit configuration
    - Validates default parameter usage
    - Tests automatic configuration mechanisms

#### **🎯 Advanced Testing**
13. **`apb_transaction_test`** - **Transaction Level Testing**
    - Tests transaction-level modeling
    - Validates sequence item properties
    - Tests transaction randomization

### **Test Execution Matrix**

| Test Category | Tests | Coverage Focus | Priority |
|---------------|-------|----------------|----------|
| Basic Functionality | 3 | Core protocol | 🔴 High |
| UVM Framework | 3 | Methodology compliance | 🟡 Medium |
| Protocol Compliance | 3 | Protocol verification | 🔴 High |
| Architecture | 3 | Agent configurations | 🟡 Medium |
| Advanced | 1 | Transaction modeling | 🟢 Low |

### **Expected Results**
- ✅ **All tests pass** with zero data mismatches
- ✅ **Zero simulation crashes** (SIGSEGV fixed)
- ✅ **Complete coverage** of APB protocol
- ✅ **Proper timing** relationships maintained

## 🛠️ Requirements & Setup

### **System Requirements**
- **QuestaSim 10.7c** or later (tested on Windows)
- **Windows 10/11** with MinGW64 toolchain
- **UVM 1.2** library (included with QuestaSim)
- **4GB+ RAM** recommended for full test suite
- **2GB+ Disk space** for coverage reports

### **Quick Start Guide**

#### **1. Clone the Repository**
```bash
git clone https://github.com/Bhanu-Prakash-CH1221/apb_vip-master.git
cd apb_vip-master
```

#### **2. Run Complete Test Suite**
```bash
cd rundir
make all_tests
```

#### **3. Generate Coverage Report**
```bash
make coverage
# Open: rundir/covhtmlreport/index.html
```

#### **4. Run Individual Tests**
```bash
make apb_basic_test        # Basic protocol test
make apb_protocol_test     # Protocol compliance
make apb_reset_test        # Reset functionality
```

#### **5. Clean Build Artifacts**
```bash
make clean                 # Remove all generated files
```

## 📋 Makefile Targets Reference

| Target | Description | Usage |
|--------|-------------|------|
| `all_tests` | Compile and run all 13 tests | `make all_tests` |
| `coverage` | Run tests + generate HTML coverage | `make coverage` |
| `clean` | Remove all generated files and libraries | `make clean` |
| `compile` | Compile all source files only | `make compile` |
| Individual test names | Run specific test | `make apb_basic_test` |

### **Advanced Makefile Options**
```bash
# Run with specific seed
make apb_basic_test SEED=12345

# Run with verbose logging
make apb_basic_test UVM_VERBOSITY=UVM_HIGH

# Generate debug waveforms
make apb_basic_test WAVES=1
```

## 🏗️ Technical Architecture

### **UVM Compliance**
- **Full UVM 1.2** methodology implementation
- **Factory pattern** for flexible object creation
- **Configuration database** for parameter management
- **TLM communication** between components
- **Phased simulation** with proper build/connect/run phases

### **APB Protocol Implementation**
- **Complete APB protocol** state machine
- **Proper PSEL/PENABLE/PREADY** handshake
- **Configurable timing** parameters
- **Support for both read and write** transactions
- **Error handling** with PSLVERR support

### **Verification Features**
- **Automatic transaction generation** with constrained randomization
- **Real-time scoreboard checking** for data integrity
- **Protocol assertions** for runtime verification
- **Functional and code coverage** analysis
- **Multiple test scenarios** for comprehensive verification

### **Debug Support**
- **Detailed logging** and messaging system
- **Waveform generation** support (.vcd files)
- **Coverage analysis** with HTML reports
- **Transaction tracking** and debugging utilities

## 🐛 Known Issues & Solutions

This VIP includes fixes for common APB verification issues:

### **Fixed Issues**
- ✅ **SIGSEGV crashes** during reset transitions
  - **Solution**: Fixed assertion handling with proper `$rose(PRESET_N)` timing
- ✅ **Race conditions** in transaction capture
  - **Solution**: Capture transaction type immediately when PSEL goes high
- ✅ **Data mismatches** between master and slave
  - **Solution**: Fixed monitor timing and transaction object handling
- ✅ **Deadlock conditions** in slave driver
  - **Solution**: Removed problematic wait conditions and fixed handshake timing

### **Performance Optimizations**
- **Zero-copy transaction handling** for improved performance
- **Efficient coverage collection** without simulation overhead
- **Optimized assertion checking** with proper disable conditions

## 📊 Coverage Metrics

### **Coverage Goals**
- **Code Coverage**: Target 95%+ achievable
- **Functional Coverage**: Complete APB protocol coverage
- **Assertion Coverage**: All protocol assertions verified
- **Branch Coverage**: All conditional paths tested

### **Coverage Reports**
- **HTML Reports**: Generated in `rundir/covhtmlreport/`
- **Text Reports**: Summary in `rundir/coverage_report.txt`
- **Database Files**: `.ucdb` files for detailed analysis

## 🤝 Contributing Guidelines

### **Development Workflow**
1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/new-feature`)
3. **Make** your changes following coding standards
4. **Run** the full test suite (`make all_tests`)
5. **Add** tests for new functionality
6. **Submit** a pull request with detailed description

### **Coding Standards**
- **Snake_case** for all SV/UVM identifiers
- **Header comments** required for every file
- **UVM factory** usage for all object creation
- **No program blocks** - use modules only
- **Virtual interfaces** encapsulated via config objects

## 📄 License & Author

### **License**
This project is released under the **MIT License** - see LICENSE file for details.

### **Author**
**Bhanu Prakash CH**  
Verification Engineer  
Specialized in UVM-based verification IP development

### **Contact & Repository**
- **GitHub Repository**: https://github.com/Bhanu-Prakash-CH1221/apb_vip-master.git
- **Issues & Support**: Use GitHub Issues for bug reports and feature requests

## 🎉 Acknowledgments

- **QuestaSim Team** for excellent simulation tool support
- **UVM Community** for methodology guidance and best practices
- **Verification Engineers** worldwide for feedback and improvements

---

**🚀 Ready to verify your APB designs with this production-ready VIP!**
