# APB VIP - Advanced Peripheral Bus Verification IP

## Overview

This is a comprehensive UVM-based Verification IP (VIP) for the Advanced Peripheral Bus (APB) protocol, designed for SystemVerilog verification environments using QuestaSim 10.7c.

## Features

- **Complete UVM Architecture**: Full UVM 1.2 compliance with factory pattern, configuration database, and TLM communication
- **APB Protocol Support**: Full APB protocol implementation with proper timing and handshake mechanisms
- **Comprehensive Test Suite**: 12 different test scenarios covering protocol compliance, timing, reset, and edge cases
- **Code Coverage**: Functional and code coverage analysis with HTML reports
- **Master & Slave Agents**: Complete master and slave agent implementations with drivers, monitors, and sequencers
- **Scoreboard**: Automatic transaction checking and data integrity verification
- **Assertions**: Protocol assertions for runtime verification
- **Cross-Platform**: Windows-compatible with MinGW64 toolchain

## Project Structure

```
├── src/
│   ├── common/          # Shared components (interface, base items, coverage)
│   ├── master/          # Master agent implementation
│   └── slave/           # Slave agent implementation
├── tb/
│   ├── tests/           # Test suite (12 comprehensive tests)
│   ├── apb_env.svh      # Testbench environment
│   └── apb_scoreboard.svh # Transaction scoreboard
├── rundir/
│   ├── Makefile         # Build and simulation scripts
│   └── coverage_data/   # Coverage database files
└── work/                # Compiled simulation libraries
```

## Supported Tests

1. **apb_basic_test** - Basic APB protocol verification
2. **apb_factory_test** - UVM factory pattern testing
3. **apb_field_auto_test** - Field automation testing
4. **apb_master_passive_test** - Master agent passive mode
5. **apb_nocfg_test** - No configuration testing
6. **apb_passive_test** - Passive mode testing
7. **apb_protocol_test** - Protocol compliance verification
8. **apb_read_only_test** - Read-only transaction testing
9. **apb_reset_test** - Reset functionality testing
10. **apb_timing_test** - Timing parameter testing
11. **apb_transaction_test** - Transaction level testing
12. **apb_uvm_macro_test** - UVM macro testing

## Requirements

- **QuestaSim 10.7c** or later
- **Windows 10/11** with MinGW64
- **UVM 1.2** library (included with QuestaSim)

## Quick Start

### 1. Clone the Repository
```bash
git clone https://github.com/Bhanu-Prakash-CH1221/apb_vip-master.git
cd apb_vip-master
```

### 2. Run All Tests
```bash
cd rundir
make all_tests
```

### 3. Generate Coverage Report
```bash
make coverage
```

### 4. Clean Build Artifacts
```bash
make clean
```

## Makefile Targets

| Target | Description |
|--------|-------------|
| `all_tests` | Compile and run all 12 tests |
| `coverage` | Run tests + generate HTML coverage report |
| `clean` | Remove all generated files and libraries |
| `compile` | Compile all source files |
| Individual test names | Run specific test (e.g., `make apb_basic_test`) |

## Key Features

### UVM Compliance
- Full UVM 1.2 methodology implementation
- Factory pattern for object creation
- Configuration database for parameter management
- TLM communication between components

### APB Protocol Implementation
- Complete APB protocol state machine
- Proper PSEL/PENABLE/PREADY handshake
- Configurable timing parameters
- Support for both read and write transactions

### Verification Features
- Automatic transaction generation
- Real-time scoreboard checking
- Protocol assertions for runtime verification
- Functional and code coverage analysis
- Multiple test scenarios for comprehensive verification

### Debug Support
- Detailed logging and messaging
- Waveform generation support
- Coverage analysis with HTML reports
- Transaction tracking and debugging

## Known Issues & Fixes

This VIP includes fixes for common APB verification issues:
- **SIGSEGV crashes** during reset transitions
- **Race conditions** in transaction capture
- **Data mismatches** between master and slave
- **Deadlock conditions** in slave driver

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run the full test suite
5. Submit a pull request

## License

This project is released under the MIT License.

## Author

Bhanu Prakash CH - Verification Engineer

## Repository

https://github.com/Bhanu-Prakash-CH1221/apb_vip-master.git
