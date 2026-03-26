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

## 📁 In-Depth Project Structure

### **🎯 Complete Directory Architecture**

```
apb_vip-master/
│
├── 📄 README.md                    # Comprehensive project documentation
├── 📄 .gitignore                   # Git ignore rules for simulation artifacts
│
├── 📂 src/                         # 🔧 Source code directory
│   │
│   ├── 📂 common/                  # 🔄 Shared components across agents
│   │   │
│   │   ├── 📄 APB_master.sv        # 🎛️ Master-side APB interface module
│   │   │   ├── Purpose: Physical interface instantiation for master side
│   │   │   ├── Signals: PCLK, PRESET_N, PSEL, PENABLE, PWRITE, PADDR, PWDATA
│   │   │   └── Features: Clock/reset generation, signal monitoring
│   │   │
│   │   ├── 📄 APB_slave.sv         # 🎛️ Slave-side APB interface module  
│   │   │   ├── Purpose: Physical interface instantiation for slave side
│   │   │   ├── Signals: PCLK, PRESET_N, PSEL, PENABLE, PWRITE, PADDR, PWDATA
│   │   │   │                     PREADY, PRDATA, PSLVERR
│   │   │   └── Features: Slave response generation, error injection
│   │   │
│   │   ├── 📄 apb_base_seq_item.svh # 📦 Base transaction item class
│   │   │   ├── Purpose: Base class for all APB transactions
│   │   │   ├── Properties: addr, data, write, enable, sel, error
│   │   │   ├── Methods: copy(), compare(), print(), pack/unpack
│   │   │   └── Inheritance: uvm_sequence_item
│   │   │
│   │   ├── 📄 apb_common_pkg.sv     # 📦 Common package with shared definitions
│   │   │   ├── Purpose: Central package for all shared components
│   │   │   ├── Contents: Typedefs, constants, utility functions
│   │   │   ├── Exports: All common classes and enums
│   │   │   └── Dependencies: None (base package)
│   │   │
│   │   ├── 📄 apb_coverage.svh     # 📊 Coverage collector for APB protocol
│   │   │   ├── Purpose: Functional coverage collection
│   │   │   ├── Covergroups: 
│   │   │   │   - cg_transaction: Address, data, operation coverage
│   │   │   │   - cg_timing: Setup/hold time coverage
│   │   │   │   - cg_reset: Reset state coverage
│   │   │   └── Features: Automatic coverage reporting
│   │   │
│   │   ├── 📄 apb_defines.svh      # 📋 Protocol-wide constants and definitions
│   │   │   ├── Purpose: Centralized constant definitions
│   │   │   ├── Contents: Timing parameters, address widths, data widths
│   │   │   ├── Parameters: APB_ADDR_WIDTH, APB_DATA_WIDTH, timing values
│   │   │   └── Usage: `include throughout all files
│   │   │
│   │   └── 📄 apb_if.sv            # 🔌 Main APB interface with assertions
│   │       ├── Purpose: Primary APB interface definition
│   │       ├── Signals: Complete APB protocol signal set
│   │       ├── Assertions: 
│   │       │   - PSEL before PENABLE
│   │       │   - Proper reset behavior
│   │       │   - Timing relationships
│   │       ├── Clocking blocks: Master and slave domains
│   │       └── Modports: Master, slave, monitor views
│   │
│   ├── 📂 master/                  # 🎯 Master agent implementation
│   │   │
│   │   ├── 📄 apb_master_agent.svh     # 🏢 Master agent component
│   │   │   ├── Purpose: Top-level master agent container
│   │   │   ├── Components: Driver, monitor, sequencer
│   │   │   ├── Configuration: apb_master_config
│   │   │   ├── Analysis ports: Transaction broadcasting
│   │   │   └── Inheritance: uvm_agent
│   │   │
│   │   ├── 📄 apb_master_config.svh    # ⚙️ Master configuration object
│   │   │   ├── Purpose: Master agent configuration
│   │   │   ├── Parameters: Active/passive mode, is_master
│   │   │   ├── Virtual interface: apb_if connection
│   │   │   ├── Features: Timing configuration, address mapping
│   │   │   └── Inheritance: uvm_object
│   │   │
│   │   ├── 📄 apb_master_driver.svh    # 🚗 Master driver (drives APB signals)
│   │   │   ├── Purpose: Drive master-side APB protocol
│   │   │   ├── Signals driven: PSEL, PENABLE, PWRITE, PADDR, PWDATA
│   │   │   ├── Sequencer interface: apb_master_seq_item
│   │   │   ├── Timing: Configurable setup/hold times
│   │   │   ├── Features: Reset handling, error injection
│   │   │   └── Inheritance: uvm_driver #(apb_master_seq_item)
│   │   │
│   │   ├── 📄 apb_master_monitor.svh   # 👁️ Master monitor (captures transactions)
│   │   │   ├── Purpose: Monitor master-side transactions
│   │   │   ├── Signals monitored: All APB signals
│   │   │   ├── Transaction capture: Edge-triggered with proper timing
│   │   │   ├── Analysis ports: Transaction broadcasting
│   │   │   ├── Features: Protocol checking, coverage collection
│   │   │   └── Inheritance: uvm_monitor
│   │   │
│   │   ├── 📄 apb_master_pkg.sv        # 📦 Master package with all components
│   │   │   ├── Purpose: Package all master agent components
│   │   │   ├── Contents: All master classes and sequences
│   │   │   ├── Imports: uvm_pkg, apb_common_pkg
│   │   │   └── Exports: Complete master agent API
│   │   │
│   │   ├── 📄 apb_master_read_seq.svh  # 📖 Read-only sequence
│   │   │   ├── Purpose: Generate read-only transactions
│   │   │   ├── Pattern: Random address reads
│   │   │   ├── Configuration: Number of transactions, address range
│   │   │   ├── Features: Sequential and random addressing
│   │   │   └── Inheritance: apb_master_seq
│   │   │
│   │   ├── 📄 apb_master_seq.svh       # 🔄 Base master sequence
│   │   │   ├── Purpose: Base class for all master sequences
│   │   │   ├── Sequencer: apb_master_sequencer
│   │   │   ├── Item type: apb_master_seq_item
│   │   │   ├── Methods: pre_body(), post_body()
│   │   │   └── Inheritance: uvm_sequence #(apb_master_seq_item)
│   │   │
│   │   ├── 📄 apb_master_seq_item.svh  # 📝 Master-specific transaction item
│   │   │   ├── Purpose: Master transaction with extended features
│   │   │   ├── Extensions: Master-specific fields, constraints
│   │   │   ├── Randomization: Constrained random generation
│   │   │   ├── Features: Address alignment, data patterns
│   │   │   └── Inheritance: apb_base_seq_item
│   │   │
│   │   ├── 📄 apb_master_sequencer.svh # 🎮 Master sequencer
│   │   │   ├── Purpose: Sequence arbitration and execution
│   │   │   ├── Sequencer type: uvm_sequencer #(apb_master_seq_item)
│   │   │   ├── Features: Priority arbitration, sequence locking
│   │   │   ├── Configuration: Default sequences, timing
│   │   │   └── Inheritance: uvm_sequencer
│   │   │
│   │   ├── 📄 apb_master_write_seq.svh # ✍️ Write-only sequence
│   │   │   ├── Purpose: Generate write-only transactions
│   │   │   ├── Pattern: Random address writes with data
│   │   │   ├── Configuration: Number of transactions, data patterns
│   │   │   ├── Features: Sequential and random addressing
│   │   │   └── Inheritance: apb_master_seq
│   │   │
│   │   └── 📄 apb_master_driver.sv     # 🚗 Master driver module
│   │       ├── Purpose: SystemVerilog module wrapper for driver
│   │       ├── Interface: apb_if connection
│   │       ├── Instantiation: apb_master_driver class
│   │       └── Features: Module-level connectivity
│   │
│   └── 📂 slave/                   # 🎯 Slave agent implementation
│       │
│       ├── 📄 apb_slave_agent.svh       # 🏢 Slave agent component
│       │   ├── Purpose: Top-level slave agent container
│       │   ├── Components: Driver, monitor, sequencer
│       │   ├── Configuration: apb_slave_config
│       │   ├── Analysis ports: Transaction broadcasting
│       │   └── Inheritance: uvm_agent
│       │
│       ├── 📄 apb_slave_config.svh      # ⚙️ Slave configuration object
│       │   ├── Purpose: Slave agent configuration
│       │   ├── Parameters: Active/passive mode, memory model
│       │   ├── Virtual interface: apb_if connection
│       │   ├── Features: Response timing, error injection
│       │   └── Inheritance: uvm_object
│       │
│       ├── 📄 apb_slave_driver.svh      # 🚗 Slave driver (drives slave responses)
│       │   ├── Purpose: Drive slave-side APB protocol
│       │   ├── Signals driven: PREADY, PRDATA, PSLVERR
│       │   ├── Sequencer interface: apb_slave_seq_item
│       │   ├── Response timing: Configurable PREADY delays
│       │   ├── Features: Memory modeling, error injection
│       │   └── Inheritance: uvm_driver #(apb_slave_seq_item)
│       │
│       ├── 📄 apb_slave_monitor.svh     # 👁️ Slave monitor (captures responses)
│       │   ├── Purpose: Monitor slave-side responses
│       │   ├── Signals monitored: PREADY, PRDATA, PSLVERR
│       │   ├── Transaction capture: Response completion timing
│       │   ├── Analysis ports: Response broadcasting
│       │   ├── Features: Protocol checking, coverage collection
│       │   └── Inheritance: uvm_monitor
│       │
│       ├── 📄 apb_slave_pkg.sv          # 📦 Slave package with all components
│       │   ├── Purpose: Package all slave agent components
│       │   ├── Contents: All slave classes and sequences
│       │   ├── Imports: uvm_pkg, apb_common_pkg
│       │   └── Exports: Complete slave agent API
│       │
│       ├── 📄 apb_slave_seq.svh         # 🔄 Slave response sequence
│       │   ├── Purpose: Generate slave response transactions
│       │   ├── Pattern: Respond to master transactions
│       │   ├── Configuration: Response delays, error rates
│       │   ├── Features: Memory responses, error injection
│       │   └── Inheritance: uvm_sequence #(apb_slave_seq_item)
│       │
│       ├── 📄 apb_slave_seq_item.svh    # 📝 Slave-specific transaction item
│       │   ├── Purpose: Slave transaction with response features
│       │   ├── Extensions: Response fields, timing parameters
│       │   ├── Randomization: Response delay, error injection
│       │   ├── Features: Memory modeling, status reporting
│       │   └── Inheritance: apb_base_seq_item
│       │
│       ├── 📄 apb_slave_sequencer.svh   # 🎮 Slave sequencer
│       │   ├── Purpose: Slave response sequence management
│       │   ├── Sequencer type: uvm_sequencer #(apb_slave_seq_item)
│       │   ├── Features: Response arbitration, timing control
│       │   ├── Configuration: Default response sequences
│       │   └── Inheritance: uvm_sequencer
│       │
│       └── 📄 apb_slave_driver.sv       # 🚗 Slave driver module
│           ├── Purpose: SystemVerilog module wrapper for driver
│           ├── Interface: apb_if connection
│           ├── Instantiation: apb_slave_driver class
│           └── Features: Module-level connectivity
│
├── 📂 tb/                          # 🧪 Testbench directory
│   │
│   ├── 📂 tests/                   # 📋 Comprehensive test suite
│   │   │
│   │   ├── 📄 apb_basic_test.svh       # 🔧 Basic APB protocol verification
│   │   │   ├── Purpose: Core functionality verification
│   │   │   ├── Test cases: Read/write operations
│   │   │   ├── Verification: Protocol compliance
│   │   │   ├── Duration: ~1000 transactions
│   │   │   └── Inheritance: apb_base_test
│   │   │
│   │   ├── 📄 apb_factory_test.svh     # 🏭 UVM factory pattern testing
│   │   │   ├── Purpose: Factory mechanism verification
│   │   │   ├── Test cases: Object creation, type overrides
│   │   │   ├── Verification: Factory registration
│   │   │   ├── Features: Dynamic configuration
│   │   │   └── Inheritance: apb_base_test
│   │   │
│   │   ├── 📄 apb_field_auto_test.svh  # 🤖 Field automation testing
│   │   │   ├── Purpose: UVM field macros verification
│   │   │   ├── Test cases: `uvm_field_* macro functionality
│   │   │   ├── Verification: Copy/compare/print operations
│   │   │   ├── Features: Automatic field registration
│   │   │   └── Inheritance: apb_base_test
│   │   │
│   │   ├── 📄 apb_master_passive_test.svh # 😴 Master agent passive mode
│   │   │   ├── Purpose: Master passive mode verification
│   │   │   ├── Configuration: Master passive, slave active
│   │   │   ├── Verification: Monitor-only functionality
│   │   │   ├── Features: Mixed active/passive agents
│   │   │   └── Inheritance: apb_base_test
│   │   │
│   │   ├── 📄 apb_nocfg_test.svh       # ⚠️ No configuration testing
│   │   │   ├── Purpose: Default configuration verification
│   │   │   ├── Test cases: VIP without explicit config
│   │   │   ├── Verification: Default parameter usage
│   │   │   ├── Features: Automatic configuration
│   │   │   └── Inheritance: apb_base_test
│   │   │
│   │   ├── 📄 apb_passive_test.svh     # 😴 Passive mode testing
│   │   │   ├── Purpose: Full passive mode verification
│   │   │   ├── Configuration: Both agents passive
│   │   │   ├── Verification: Monitor-only operation
│   │   │   ├── Features: External stimulus testing
│   │   │   └── Inheritance: apb_base_test
│   │   │
│   │   ├── 📄 apb_protocol_test.svh    # 📜 Protocol compliance verification
│   │   │   ├── Purpose: Comprehensive protocol checking
│   │   │   ├── Test cases: Edge cases, corner conditions
│   │   │   ├── Verification: Assertion coverage
│   │   │   ├── Features: Protocol violation detection
│   │   │   └── Inheritance: apb_base_test
│   │   │
│   │   ├── 📄 apb_read_only_test.svh   # 📖 Read-only transaction testing
│   │   │   ├── Purpose: Read operation verification
│   │   │   ├── Test cases: Various read patterns
│   │   │   ├── Verification: Address decoding, data return
│   │   │   ├── Features: Sequential/random reads
│   │   │   └── Inheritance: apb_base_test
│   │   │
│   │   ├── 📄 apb_reset_test.svh       # 🔄 Reset functionality testing
│   │   │   ├── Purpose: Reset behavior verification
│   │   │   ├── Test cases: Reset during transactions
│   │   │   ├── Verification: Reset recovery
│   │   │   ├── Features: Reset timing, state clearing
│   │   │   └── Inheritance: apb_base_test
│   │   │
│   │   ├── 📄 apb_timing_test.svh      # ⏱️ Timing parameter testing
│   │   │   ├── Purpose: Timing configuration verification
│   │   │   ├── Test cases: Various timing parameters
│   │   │   ├── Verification: Setup/hold time compliance
│   │   │   ├── Features: Configurable delays
│   │   │   └── Inheritance: apb_base_test
│   │   │
│   │   ├── 📄 apb_transaction_test.svh  # 📝 Transaction level testing
│   │   │   ├── Purpose: Transaction modeling verification
│   │   │   ├── Test cases: Transaction randomization
│   │   │   ├── Verification: Sequence item properties
│   │   │   ├── Features: Transaction constraints
│   │   │   └── Inheritance: apb_base_test
│   │   │
│   │   ├── 📄 apb_uvm_macro_test.svh   # 📋 UVM macro testing
│   │   │   ├── Purpose: UVM macro functionality verification
│   │   │   ├── Test cases: `uvm_info`, `uvm_error`, etc.
│   │   │   ├── Verification: Reporting mechanisms
│   │   │   ├── Features: Macro expansion testing
│   │   │   └── Inheritance: apb_base_test
│   │   │
│   │   └── 📄 apb_write_only_test.svh  # ✍️ Write-only transaction testing
│   │       ├── Purpose: Write operation verification
│   │       ├── Test cases: Various write patterns
│   │       ├── Verification: Data integrity, address mapping
│   │       ├── Features: Sequential/random writes
│   │       └── Inheritance: apb_base_test
│   │
│   ├── 📄 apb_env.svh               # 🌍 Testbench environment
│   │   ├── Purpose: Complete UVM testbench environment
│   │   ├── Components: Master agent, slave agent, scoreboard
│   │   ├── Configuration: Environment-level settings
│   │   ├── Analysis ports: Transaction routing
│   │   ├── Features: Agent management, configuration control
│   │   └── Inheritance: uvm_env
│   │
│   ├── 📄 apb_scoreboard.svh       # 📊 Transaction scoreboard
│   │   ├── Purpose: Transaction integrity verification
│   │   ├── Functionality: Master vs slave transaction comparison
│   │   ├── Analysis exports: Transaction collection
│   │   ├── Checking: Data integrity, protocol compliance
│   │   ├── Features: Mismatch detection, error reporting
│   │   └── Inheritance: uvm_scoreboard
│   │
│   ├── 📄 apb_test_pkg.sv          # 📦 Test package with all test registrations
│   │   ├── Purpose: Package all test classes
│   │   ├── Contents: All test classes and utilities
│   │   ├── Registration: UVM test factory registration
│   │   ├── Imports: uvm_pkg, all agent packages
│   │   └── Exports: Complete test suite API
│   │
│   └── 📄 testbench.sv             # 🏗️ Top-level testbench module
│       ├── Purpose: Top-level SystemVerilog testbench
│       ├── Components: DUT instance, interface connections
│       ├── Clock/reset: System clock and reset generation
│       ├── Instantiation: UVM testbench environment
│       ├── Features: DUT connection, signal routing
│       └── Module type: top-level SystemVerilog module
│
└── 📂 rundir/                      # 🚀 Run directory with build scripts
    │
    ├── 📄 Makefile                 # 🔨 Complete build and simulation automation
    │   ├── Purpose: Build automation and test execution
    │   ├── Tools: QuestaSim vlog, vsim, vcover
    │   ├── Targets: compile, test, coverage, clean
    │   ├── Features: Parallel execution, error handling
    │   └── Platform: Windows MinGW64 compatible
    │
    └── 📂 [Generated during simulation - .gitignored]
        ├── 📂 coverage_data/          # 📊 Coverage database files (.ucdb)
        │   ├── Purpose: Coverage collection database
        │   ├── Files: Individual test coverage (.ucdb)
        │   ├── Merged: Combined coverage database
        │   └── Usage: Coverage analysis and reporting
        │
        ├── 📂 coverage_reports/       # 📈 HTML coverage reports
        │   ├── Purpose: Human-readable coverage reports
        │   ├── Format: Interactive HTML with charts
        │   ├── Contents: Code coverage, functional coverage
        │   └── Access: Web browser viewing
        │
        └── 📂 work/                   # 🏗️ Compiled simulation libraries
            ├── Purpose: Compiled SystemVerilog libraries
            ├── Contents: Elaborated design, VIP libraries
            ├── Files: .qdb, .qpg, .qtl files
            └── Usage: Simulation execution
```

### **🔍 File Purpose & Functionality Matrix**

| **Category** | **Component** | **Primary Purpose** | **Key Features** | **Dependencies** |
|--------------|--------------|-------------------|-----------------|-----------------|
| **Interface** | `apb_if.sv` | Protocol definition | Assertions, clocking blocks | SystemVerilog |
| **Common** | `apb_base_seq_item.svh` | Base transaction | Common properties, utilities | uvm_pkg |
| **Common** | `apb_defines.svh` | Constants | Protocol parameters | None |
| **Master** | `apb_master_driver.svh` | Protocol driving | PSEL/PENABLE control | apb_master_seq_item |
| **Master** | `apb_master_monitor.svh` | Transaction capture | Edge detection, timing | apb_if |
| **Slave** | `apb_slave_driver.svh` | Response generation | PREADY/PRDATA control | apb_slave_seq_item |
| **Slave** | `apb_slave_monitor.svh` | Response capture | Response timing | apb_if |
| **Environment** | `apb_env.svh` | Testbench container | Agent management | All agent packages |
| **Verification** | `apb_scoreboard.svh` | Data integrity | Transaction comparison | apb_base_seq_item |
| **Tests** | `apb_*_test.svh` | Verification scenarios | Specific test cases | apb_env, apb_test_pkg |

### **🔗 Component Interaction Flow**

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Master Agent  │    │   Slave Agent   │    │   Scoreboard    │
│                 │    │                 │    │                 │
│ ┌─────────────┐ │    │ ┌─────────────┐ │    │ ┌─────────────┐ │
│ │   Driver    │─┼────┼─▶│   Driver    │ │    │   Compare    │ │
│ └─────────────┘ │    │ └─────────────┘ │    │ Transactions │ │
│        │        │    │        ▲        │    │ └─────────────┘ │
│        ▼        │    │        │        │    │        ▲        │
│ ┌─────────────┐ │    │ ┌─────────────┐ │    │        │        │
│ │  Monitor    │─┼────┼─▶│  Monitor    │─┼────┼────────┘        │
│ └─────────────┘ │    │ └─────────────┘ │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │   APB Interface │
                    │                 │
                    │ PCLK, PRESET_N  │
                    │ PSEL, PENABLE   │
                    │ PWRITE, PADDR   │
                    │ PWDATA, PRDATA  │
                    │ PREADY, PSLVERR │
                    └─────────────────┘
```

### **📊 Data Flow Architecture**

```
Master Sequencer → Master Driver → APB Interface → Slave Driver → Slave Sequencer
        │                   │              │              │                   │
        ▼                   ▼              ▼              ▼                   ▼
Transaction Generation   Signal Drive   Protocol      Response Drive    Response Generation
   (apb_master_seq)     (PSEL/PENABLE)   (APB)        (PREADY/PRDATA)   (apb_slave_seq)
        │                   │              │              │                   │
        └───────────────────┼──────────────┼──────────────┼───────────────────┘
                            │              │              │
                            ▼              ▼              ▼
                    Master Monitor   APB Protocol   Slave Monitor
                    (Transaction     (Physical      (Response
                     Capture)        Interface)     Capture)
                            │              │              │
                            └──────────────┼──────────────┘
                                           │
                                           ▼
                                    Scoreboard
                                 (Data Integrity
                                  Verification)
```

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
