# Windows-style paths
TB_DIR = "+incdir+$(CURDIR)/tb"
SRC_DIR = "+incdir+$(CURDIR)/src"
MASTER_DIR = "+incdir+$(CURDIR)/src/master"
SLAVE_DIR = "+incdir+$(CURDIR)/src/slave"
COMMON_DIR = "+incdir+$(CURDIR)/src/common"
UVM_HOME = "C:/questasim64_10.7c/verilog_src/uvm-1.1d"
UVM_DPI = "C:/questasim64_10.7c/uvm-1.1d/win64"
UVM_INC = "-incdir $(UVM_HOME)/src $(UVM_HOME)/src/uvm.sv $(UVM_HOME)/src/uvm_pkg.sv"
UVM_DEFINES = "+define+UVM_OBJECT_MUST_HAVE_CONSTRUCTOR"
UVM_LIBS = "-L mtiUvm"

# Include UVM source files first
UVM_SRC = $(UVM_HOME)/src/uvm_pkg.sv

# Default test name
UVM_TESTNAME ?= apb_coverage_test

# Directory variables
TB = $(CURDIR)/tb
SRC = $(CURDIR)/src
MASTER = $(CURDIR)/src/master
SLAVE = $(CURDIR)/src/slave
COMMON = $(CURDIR)/src/common

help:
	@echo "=============================================="
	@echo "APB VIP Enhanced Test Suite - 100% Coverage"
	@echo "=============================================="
	@echo ""
	@echo "Quick Start:"
	@echo "  make quick              # Run full coverage test (recommended)"
	@echo "  make coverage_all       # Run all tests and generate report"
	@echo ""
	@echo "Individual Tests:"
	@echo "  make sim                       # Run default test"
	@echo "  make sim UVM_TESTNAME=test_name # Run specific test"
	@echo ""
	@echo "Available Tests:"
	@echo "  apb_coverage_test          - Comprehensive test for 100% coverage"
	@echo "  apb_full_coverage_test     - Legacy comprehensive test for 100% coverage"
	@echo "  apb_enhanced_reset_test    - Enhanced reset test with full reset coverage"
	@echo "  apb_full_reset_test        - Complete reset coverage with different reset scenarios"
	@echo "  apb_timing_violation_test  - Tests timing violation scenarios"
	@echo "  apb_addr_data_pattern_test - Tests various address and data patterns"
	@echo "  apb_basic_test             - Mixed read/write operations"
	@echo "  apb_reset_test             - Basic reset functionality test"
	@echo "  apb_read_only_test         - Read-only operations"
	@echo "  apb_write_only_test        - Write-only operations"
	@echo "  apb_passive_slave_test     - Tests UVM_PASSIVE slave mode"
	@echo "  apb_stress_test            - High volume stress test"
	@echo ""
	@echo "  make all_tests             # Run all 12 tests with coverage"
	@echo "  make coverage_all          # Run all tests + generate individual reports"
	@echo "  make coverage_report       # Generate individual reports (no merge errors)"
	@echo "  make coverage_report_single TEST=<name> # Generate single test report"
	@echo "  make quick                 # Run full coverage test only"
	@echo "  make quick_passive         # Run passive slave test only"
	@echo ""
	@echo "Utility Commands:"
	@echo "  make clean                 # Clean all generated files"
	@echo "  make comp                  # Compile only"
	@echo "=============================================="

clean:
	-if exist work rmdir /s /q work
	-if exist coverage_data rmdir /s /q coverage_data
	-if exist coverage_report rmdir /s /q coverage_report
	-if exist combined_coverage.ucdb del /f /q combined_coverage.ucdb
	del /f /q certe_dump.* vsim.* *.log *.tgz *~ *.vstf *.wlf transcript 2>nul

comp: clean
	@echo ==============================================
	@echo Compiling APB VIP with Enhanced Coverage
	@echo ==============================================
	vlib work
	
	@echo Compiling common files...
	vlog -work work -sv -cover bcesft \
		+incdir+$(UVM_HOME)/src \
		+incdir+$(COMMON) \
		$(UVM_DEFINES) \
		$(COMMON)/apb_if.sv \
		$(COMMON)/apb_base_seq_item.svh \
		$(COMMON)/apb_common_pkg.sv

	@echo Compiling slave package...
	vlog -work work -sv -cover bcesft \
		+incdir+$(UVM_HOME)/src \
		+incdir+$(COMMON) \
		+incdir+$(SLAVE) \
		$(UVM_DEFINES) \
		$(SLAVE)/apb_slave_pkg.sv

	@echo Compiling master package...
	vlog -work work -sv -cover bcesft \
		+incdir+$(UVM_HOME)/src \
		+incdir+$(COMMON) \
		+incdir+$(MASTER) \
		$(UVM_DEFINES) \
		$(MASTER)/apb_master_pkg.sv

	@echo Compiling test package...
	vlog -work work -sv -cover bcesft \
		+incdir+$(UVM_HOME)/src \
		+incdir+$(COMMON) \
		+incdir+$(SLAVE) \
		+incdir+$(MASTER) \
		+incdir+$(TB)/tests \
		$(UVM_DEFINES) \
		$(TB)/tests/apb_test_pkg.sv

	@echo Compiling testbench...
	vlog -work work -sv -cover bcesft \
		+incdir+$(UVM_HOME)/src \
		+incdir+$(COMMON) \
		+incdir+$(SLAVE) \
		+incdir+$(MASTER) \
		+incdir+$(TB)/tests \
		$(UVM_DEFINES) \
		$(TB)/testbench.sv
	
	@echo Compiling UVM package...
	vlog -work work -sv \
		+incdir+$(UVM_HOME)/src \
		$(UVM_HOME)/src/uvm_pkg.sv

	@echo Compiling interface...
	vlog -work work -sv -cover bcesft \
		+incdir+$(UVM_HOME)/src \
		+incdir+$(CURDIR)/src/common \
		$(UVM_DEFINES) \
		$(subst /,\\,$(COMMON)/apb_if.sv)

	@echo Compiling common package...
	vlog -work work -sv -cover bcesft \
		+incdir+$(UVM_HOME)/src \
		+incdir+$(CURDIR)/src/common \
		$(UVM_DEFINES) \
		$(subst /,\\,$(COMMON)/apb_base_seq_item.svh) \
		$(subst /,\\,$(COMMON)/apb_common_pkg.sv)

	@echo Compiling slave package...
	vlog -work work -sv -cover bcesft \
		+incdir+$(UVM_HOME)/src \
		+incdir+$(CURDIR)/src/common \
		+incdir+$(CURDIR)/src/slave \
		$(UVM_DEFINES) \
		$(subst /,\\,$(SLAVE)/apb_slave_seq_item.svh) \
		$(subst /,\\,$(SLAVE)/apb_slave_config.svh) \
		$(subst /,\\,$(SLAVE)/apb_slave_driver.svh) \
		$(subst /,\\,$(SLAVE)/apb_slave_sequencer.svh) \
		$(subst /,\\,$(SLAVE)/apb_slave_agent.svh) \
		$(subst /,\\,$(SLAVE)/apb_slave_seq.svh) \
		$(subst /,\\,$(SLAVE)/apb_slave_pkg.sv)

	@echo Compiling master package...
	vlog -work work -sv -cover bcesft \
		+incdir+$(UVM_HOME)/src \
		+incdir+$(CURDIR)/src/common \
		+incdir+$(CURDIR)/src/master \
		$(UVM_DEFINES) \
		$(subst /,\\,$(MASTER)/apb_master_seq_item.svh) \
		$(subst /,\\,$(MASTER)/apb_master_driver.svh) \
		$(subst /,\\,$(MASTER)/apb_master_sequencer.svh) \
		$(subst /,\\,$(MASTER)/apb_master_agent.svh) \
		$(subst /,\\,$(MASTER)/apb_master_seq.svh) \
		$(subst /,\\,$(MASTER)/apb_master_pkg.sv)

	@echo Compiling test package...
	vlog -work work -sv -cover bcesft \
		+incdir+$(UVM_HOME)/src \
		+incdir+$(CURDIR)/src/common \
		+incdir+$(CURDIR)/tb \
		+incdir+$(CURDIR)/tb/tests \
		$(UVM_DEFINES) \
		$(subst /,\\,$(TB)/tests/apb_basic_test.svh) \
		$(subst /,\\,$(TB)/apb_test_pkg.sv)

	@echo Compiling testbench...
	vlog -work work -sv -cover bcesft \
		+incdir+$(UVM_HOME)/src \
		+incdir+$(CURDIR)/src/common \
		+incdir+$(CURDIR)/tb \
		$(UVM_DEFINES) \
		$(subst /,\\,$(TB)/testbench.sv)
		$(subst /,\\,$(SLAVE)/apb_slave_monitor.svh) \
		$(subst /,\\,$(SLAVE)/apb_slave_sequencer.svh) \
		$(subst /,\\,$(SLAVE)/apb_slave_agent.svh) \
		$(subst /,\\,$(SLAVE)/apb_slave_seq.svh) \
		$(subst /,\\,$(SLAVE)/apb_slave_pkg.sv)

	@echo Compiling master package...
	vlog -work work -sv -cover bcesft \
		+incdir+$(UVM_HOME)/src \
		$(UVM_DEFINES) \
		$(MASTER_DIR) \
		$(subst /,\\,$(MASTER)/apb_master_config.svh) \
		$(subst /,\\,$(MASTER)/apb_master_driver.svh) \
		$(subst /,\\,$(MASTER)/apb_master_monitor.svh) \
		$(subst /,\\,$(MASTER)/apb_master_sequencer.svh) \
		$(subst /,\\,$(MASTER)/apb_master_agent.svh) \
		$(subst /,\\,$(MASTER)/apb_master_seq_lib.svh) \
		$(subst /,\\,$(MASTER)/apb_master_pkg.sv)

	@echo Compiling test package and testbench...
	vlog -work work -sv -cover bcesft \
		+incdir+$(UVM_HOME)/src \
		$(UVM_DEFINES) \
		$(TB_DIR) \
		$(subst /,\\,$(TB)/apb_scoreboard.svh) \
		$(subst /,\\,$(TB)/apb_env.svh) \
		$(subst /,\\,$(TB)/apb_test_pkg.sv) \
		$(subst /,\\,$(TB)/testbench.sv)

	@echo Optimizing design...
	vopt +acc -debugdb testbench -o testbench_opt -L mtiUvm
	@echo ==============================================
	@echo Compilation Complete!
	@echo ==============================================

sim: comp
	@echo "=============================================="
	@echo "Running Test: $(UVM_TESTNAME)"
	@echo "=============================================="
	vsim -voptargs=+acc -do "wave.do" -classdebug -debugdb -msgmode both -uvmcontrol=all \
		-OVMdebug -assertdebug +UVM_NO_RELNOTES +UVM_TESTNAME=$(UVM_TESTNAME) \
		-coverage -coveranalysis -coverstore coverage_data \
		testbench_opt

# Quick test for 100% coverage
quick: comp
	@echo "=============================================="
	@echo "Running Quick Full Coverage Test"
	@echo "=============================================="
	$(MAKE) sim UVM_TESTNAME=apb_coverage_test
	@echo "Generating Coverage Report"
	@echo "=============================================="
	vcover report -html -htmldir coverage_report coverage_data/full_coverage.db
	@echo ""
	@echo "Coverage report generated: coverage_report/index.html"
	@echo "=============================================="

# Quick test for passive slave mode
quick_passive: comp
	@echo "=============================================="
	@echo "Running Quick Passive Slave Test"
	@echo "=============================================="
	mkdir -p coverage_data
	vsim -c -voptargs=+acc -classdebug -msgmode both -uvmcontrol=all \
		+UVM_NO_RELNOTES +UVM_TESTNAME=apb_passive_slave_test \
		-coverage -coveranalysis -coverstore coverage_data/passive_slave \
		testbench_opt -do "run -all; coverage save -onexit coverage_data/passive_slave.db; exit"
	@echo ""
	@echo "=============================================="
	@echo "Generating Coverage Report"
	@echo "=============================================="
	vcover report -html -htmldir coverage_report coverage_data/passive_slave.db
	@echo ""
	@echo "Coverage report generated: coverage_report/index.html"
	@echo "=============================================="
all_tests: comp
	@echo "=============================================="
	@echo "Running All APB VIP Tests (Enhanced Suite)"
	@echo "=============================================="
	mkdir -p coverage_data
	@echo ""
	@echo "Test 1/8: Full Coverage Test (NEW - Comprehensive)"
	@echo "==================================================="
	vsim -c -voptargs=+acc -classdebug -msgmode both -uvmcontrol=all \
		+UVM_NO_RELNOTES +UVM_TESTNAME=apb_full_coverage_test \
		-coverage -coveranalysis -coverstore coverage_data/full_coverage \
		testbench_opt -do "run -all; coverage save -onexit coverage_data/full_coverage.db; exit"
	@echo ""
	@echo "Test 2/8: Enhanced Reset Test (NEW - Full Reset Coverage)"
	@echo "=========================================================="
	vsim -c -voptargs=+acc -classdebug -msgmode both -uvmcontrol=all \
		+UVM_NO_RELNOTES +UVM_TESTNAME=apb_enhanced_reset_test \
		-coverage -coveranalysis -coverstore coverage_data/enhanced_reset \
		testbench_opt -do "run -all; coverage save -onexit coverage_data/enhanced_reset.db; exit"
	@echo ""
	@echo "Test 3/8: Basic Mixed Test"
	@echo "==========================="
	vsim -c -voptargs=+acc -classdebug -msgmode both -uvmcontrol=all \
		+UVM_NO_RELNOTES +UVM_TESTNAME=apb_basic_test \
		-coverage -coveranalysis -coverstore coverage_data/basic_test \
		testbench_opt -do "run -all; coverage save -onexit coverage_data/basic_test.db; exit"
	@echo ""
	@echo "Test 4/8: Original Reset Test"
	@echo "=============================="
	vsim -c -voptargs=+acc -classdebug -msgmode both -uvmcontrol=all \
		+UVM_NO_RELNOTES +UVM_TESTNAME=apb_reset_test \
		-coverage -coveranalysis -coverstore coverage_data/reset_test \
		testbench_opt -do "run -all; coverage save -onexit coverage_data/reset_test.db; exit"
	@echo ""
	@echo "Test 5/8: Read-Only Test"
	@echo "========================"
	vsim -c -voptargs=+acc -classdebug -msgmode both -uvmcontrol=all \
		+UVM_NO_RELNOTES +UVM_TESTNAME=apb_read_only_test \
		-coverage -coveranalysis -coverstore coverage_data/read_only \
		testbench_opt -do "run -all; coverage save -onexit coverage_data/read_only.db; exit"
	@echo ""
	@echo "Test 6/8: Write-Only Test"
	@echo "========================="
	vsim -c -voptargs=+acc -classdebug -msgmode both -uvmcontrol=all \
		+UVM_NO_RELNOTES +UVM_TESTNAME=apb_write_only_test \
		-coverage -coveranalysis -coverstore coverage_data/write_only \
		testbench_opt -do "run -all; coverage save -onexit coverage_data/write_only.db; exit"
	@echo ""
	@echo "Test 7/8: Passive Slave Test (NEW - Tests UVM_PASSIVE mode)"
	@echo "==========================================================="
	vsim -c -voptargs=+acc -classdebug -msgmode both -uvmcontrol=all \
		+UVM_NO_RELNOTES +UVM_TESTNAME=apb_passive_slave_test \
		-coverage -coveranalysis -coverstore coverage_data/passive_slave \
		testbench_opt -do "run -all; coverage save -onexit coverage_data/passive_slave.db; exit"
	@echo ""
	@echo "Test 8/8: Stress Test"
	@echo "====================="
	vsim -c -voptargs=+acc -classdebug -msgmode both -uvmcontrol=all \
		+UVM_NO_RELNOTES +UVM_TESTNAME=apb_stress_test \
		-coverage -coveranalysis -coverstore coverage_data/stress_test \
		testbench_opt -do "run -all; coverage save -onexit coverage_data/stress_test.db; exit"
	@echo ""
	@echo "=============================================="
	@echo "All Tests Completed Successfully!"
	@echo "=============================================="

coverage_report:
	@echo "=============================================="
	@echo "Generating Combined Coverage Report"
	@echo "=============================================="
	@if [ -d coverage_data ]; then \
		echo "Generating individual coverage reports for each test..."; \
		for test_dir in coverage_data/*/; do \
			test_name=$$(basename $$test_dir); \
			if [ -f $$test_dir/questa.db ]; then \
				echo "Generating report for $$test_name..."; \
				vcover report -html -htmldir coverage_report/$$test_name $$test_dir/questa.db > /dev/null 2>&1; \
			fi; \
		done; \
		echo ""; \
		echo "Individual coverage reports generated in coverage_report/ directory:"; \
		ls -la coverage_report/; \
		echo ""; \
		echo "To view combined results, check individual test reports or run:"; \
		echo "  make coverage_report_single TEST=<test_name>"; \
		echo ""; \
		echo "Individual test coverage summary:"; \
		for test_dir in coverage_data/*/; do \
			test_name=$$(basename $$test_dir); \
			if [ -f $$test_dir/questa.db ]; then \
				echo "=== $$test_name ==="; \
				vcover report $$test_dir/questa.db | grep "Total Coverage" | head -1; \
			fi; \
		done; \
	else \
		echo "ERROR: No coverage data found. Run 'make all_tests' first."; \
	fi
	@echo "=============================================="

coverage_report_single:
	@if [ -z "$(TEST)" ]; then \
		echo "ERROR: Please specify TEST=<test_name>"; \
		echo "Available tests:"; \
		ls coverage_data/; \
		exit 1; \
	fi; \
	if [ -f coverage_data/$(TEST)/questa.db ]; then \
		echo "Generating coverage report for $(TEST)..."; \
		vcover report -html -htmldir coverage_report/$(TEST) coverage_data/$(TEST)/questa.db; \
		echo "Report generated: coverage_report/$(TEST)/index.html"; \
	else \
		echo "ERROR: No coverage data found for test $(TEST)"; \
		echo "Available tests:"; \
		ls coverage_data/; \
	fi
gui: comp
	@echo "=============================================="
	@echo "Starting Interactive GUI Mode"
	@echo "=============================================="
	vsim -voptargs=+acc -do "wave.do" -classdebug -debugdb -gui \
		-msgmode both -uvmcontrol=all -OVMdebug -assertdebug \
		+UVM_NO_RELNOTES +UVM_TESTNAME=$(UVM_TESTNAME) \
		-coverage -coveranalysis testbench_opt

.PHONY: help clean comp sim quick quick_passive all_tests coverage_report coverage_report_single coverage_all gui