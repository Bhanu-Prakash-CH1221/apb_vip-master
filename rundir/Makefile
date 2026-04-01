# =============================================================================
# APB VIP Makefile — QuestaSim 10.7c, MinGW64, Windows
# =============================================================================
# PATHS: Use forward slashes throughout (MinGW64 compatible)
# Run: make all_tests    → compiles + runs all 13 tests (26 total runs) + report
#      make coverage     → all_tests + HTML report
#      make clean        → wipe work library and generated files
# =============================================================================

# -----------------------------------------------------------------------------
# QuestaSim executable paths
# -----------------------------------------------------------------------------
VSIM = C:/questasim64_10.7c/win64/vsim.exe
VLOG = C:/questasim64_10.7c/win64/vlog.exe
VLIB = C:/questasim64_10.7c/win64/vlib.exe
VOPT = C:/questasim64_10.7c/win64/vopt.exe
VCOVER = C:/questasim64_10.7c/win64/vcover.exe

# -----------------------------------------------------------------------
# Project root (Windows path with forward slashes for MinGW64 / QuestaSim)
# -----------------------------------------------------------------------
PROJ_ROOT = /d/Questa_Sim_projects/apb_vip-master

TB      = $(PROJ_ROOT)/tb
SRC     = $(PROJ_ROOT)/src
COMMON  = $(SRC)/common
MASTER  = $(SRC)/master
SLAVE   = $(SRC)/slave

# -----------------------------------------------------------------------
# QuestaSim UVM installation path
# -----------------------------------------------------------------------
UVM_HOME = /c/questasim64_10.7c/verilog_src/uvm-1.1d/src

# -----------------------------------------------------------------------
# Include directories (+incdir tells vlog where to look for `include files)
# -----------------------------------------------------------------------
INCDIRS = \
    +incdir+$(UVM_HOME) \
    +incdir+$(COMMON)   \
    +incdir+$(SLAVE)    \
    +incdir+$(MASTER)   \
    +incdir+$(TB)

# -----------------------------------------------------------------------
# Coverage instrumentation options
#   bcesft = branches, conditions, expressions, statements, FSMs, toggles
#   +assert = include assertion coverage
# -----------------------------------------------------------------------
COVERAGE_OPTS = -coverage -coveranalysis -voptargs="+cover=bcesft+assert"

# -----------------------------------------------------------------------
# Default target
# -----------------------------------------------------------------------
.PHONY: help clean clean_cover comp all_tests coverage coverage_report \
        timing_test protocol_test basic_test reset_test read_only_test  \
        write_only_test transaction_test factory_test passive_test       \
        nocfg_test master_passive_test uvm_macro_test field_auto_test    \
        gui_test gui_test_full gui_test_quiet test test_full test_quiet

help:
	@echo ""
	@echo "╔════════════════════════════════════════════════════════════════════════════════╗"
	@echo "║                    APB VIP - QuestaSim 10.7c Makefile                          ║"
	@echo "║                           Advanced Peripheral Bus VIP                          ║"
	@echo "╚════════════════════════════════════════════════════════════════════════════════╝"
	@echo ""
	@echo "QUICK START COMMANDS:"
	@echo "  make help              Show this help menu"
	@echo "  make all_tests         Run all 13 tests (26 total runs) + generate coverage report"
	@echo "  make coverage          Run all tests + create merged HTML coverage report"
	@echo "  make clean             Remove all build artifacts and coverage data"
	@echo ""
	@echo "INDIVIDUAL TESTS:"
	@echo "  make timing_test       make protocol_test      make basic_test"
	@echo "  make reset_test        make read_only_test     make write_only_test"
	@echo "  make transaction_test  make factory_test       make passive_test"
	@echo "  make nocfg_test        make master_passive_test"
	@echo "  make uvm_macro_test    make field_auto_test"
	@echo ""
	@echo "FLEXIBLE TEST EXECUTION:"
	@echo "  make test TEST=apb_basic_test         Run single test (FULL + QUIET) + coverage"
	@echo "  make test_full TEST=apb_basic_test    Run single test with full verbosity"
	@echo "  make test_quiet TEST=apb_basic_test   Run single test with quiet verbosity"
	@echo ""
	@echo "FLEXIBLE GUI SIMULATION:"
	@echo "  make gui_test_full TEST=apb_basic_test Open GUI with full verbosity"
	@echo "  make gui_test_quiet TEST=apb_basic_test Open GUI with quiet verbosity"
	@echo ""
	@echo "COVERAGE & REPORTING:"
	@echo "  • All tests generate coverage data automatically"
	@echo "  • HTML reports created in coverage_reports/ directory"
	@echo "  • GUI mode saves coverage to coverage_data/testname_gui.ucdb"
	@echo ""
	@echo "USAGE EXAMPLES:"
	@echo "  make gui_test test_full=apb_timing_test      # Debug timing test interactively"
	@echo "  make test TEST=apb_protocol_test         # Run protocol test with coverage"
	@echo ""

# -----------------------------------------------------------------------
# Clean
# -----------------------------------------------------------------------
clean_cover:
	-powershell -Command "if (Test-Path coverage_reports) { Remove-Item -Recurse -Force coverage_reports }"
	-powershell -Command "if (Test-Path coverage_data) { Remove-Item -Recurse -Force coverage_data }"
	-powershell -Command "Remove-Item -Force *.ucdb -ErrorAction SilentlyContinue"

clean: clean_cover
	-powershell -Command "if (Test-Path work) { Remove-Item -Recurse -Force work }"
	-powershell -Command "Remove-Item -Force certe_dump.*,vsim.*,*.log,*.tgz,*~,*.vstf,transcript -ErrorAction SilentlyContinue"

# -----------------------------------------------------------------------
# Compilation
# Compile order: interface → common pkg → slave pkg → master pkg → tb pkg → testbench
# APB_master.sv and APB_slave.sv are RTL DUTs compiled before testbench
# -----------------------------------------------------------------------
comp: clean
	$(VLIB) work
	$(VLOG) -work work -L mtiUvm -cover bcesft -sv \
		$(INCDIRS) \
		D:/Questa_Sim_projects/apb_vip-master/src/common/apb_if.sv \
		D:/Questa_Sim_projects/apb_vip-master/src/common/APB_master.sv \
		D:/Questa_Sim_projects/apb_vip-master/src/common/APB_slave.sv \
		D:/Questa_Sim_projects/apb_vip-master/src/common/apb_common_pkg.sv \
		D:/Questa_Sim_projects/apb_vip-master/src/slave/apb_slave_pkg.sv \
		D:/Questa_Sim_projects/apb_vip-master/src/master/apb_master_pkg.sv \
		D:/Questa_Sim_projects/apb_vip-master/tb/apb_test_pkg.sv \
		D:/Questa_Sim_projects/apb_vip-master/tb/testbench.sv
	$(VOPT) +acc -debugdb testbench -o testbench_opt


# -----------------------------------------------------------------------
# Simulation macros
#
# FULL  run: no suppression plusargs → hits the FALSE arm of
#            +DISABLE_CLOCK_DEBUG and +DISABLE_WAVES branches
#            (the $display and $dumpfile arms execute)
#
# QUIET run: suppression plusargs set → hits the TRUE arm of those branches
#            (the if-body is skipped; branch TRUE is exercised)
# -----------------------------------------------------------------------
define RUN_TEST_FULL
	@echo "--- $(1) [FULL verbosity] ---"
	@mkdir -p coverage_data
	$(VSIM) -c \
		-do "coverage save -onexit coverage_data/$(1)_full.ucdb \
		     -testname $(1)_full; run -all; quit -f" \
		testbench_opt \
		+UVM_TESTNAME=$(1) \
		+UVM_NO_RELNOTES \
		$(COVERAGE_OPTS)
endef

define RUN_TEST_QUIET
	@echo "--- $(1) [QUIET verbosity] ---"
	@mkdir -p coverage_data
	$(VSIM) -c \
		-do "coverage save -onexit coverage_data/$(1)_quiet.ucdb \
		     -testname $(1)_quiet; run -all; quit -f" \
		testbench_opt \
		+UVM_TESTNAME=$(1) \
		+UVM_NO_RELNOTES \
		+DISABLE_CLOCK_DEBUG \
		+DISABLE_MONITOR \
		+DISABLE_WAVES \
		+uvm_set_verbosity=_ALL_,_ALL_,UVM_NONE,build \
		+uvm_set_verbosity=_ALL_,_ALL_,UVM_NONE,run \
		$(COVERAGE_OPTS)
endef

# -----------------------------------------------------------------------
# GUI run: opens QuestaSim GUI with waves and debugging enabled
# -----------------------------------------------------------------------
define RUN_TEST_GUI
	@echo "--- $(1) [GUI MODE] ---"
	@mkdir -p coverage_data
	$(VSIM) \
		-do "log -r /*; do wave.do; coverage save -onexit coverage_data/$(1)_gui.ucdb -testname $(1)_gui" \
		testbench_opt \
		+UVM_TESTNAME=$(1) \
		+UVM_NO_RELNOTES \
		$(COVERAGE_OPTS)
endef

# -----------------------------------------------------------------------
# GUI run with full verbosity: opens QuestaSim GUI with maximum debug output
# -----------------------------------------------------------------------
define RUN_TEST_GUI_FULL
	@echo "--- $(1) [GUI FULL MODE] ---"
	@mkdir -p coverage_data
	$(VSIM) \
		-do "log -r /*; do wave.do; coverage save -onexit coverage_data/$(1)_gui_full.ucdb -testname $(1)_gui_full" \
		testbench_opt \
		+UVM_TESTNAME=$(1) \
		+UVM_NO_RELNOTES \
		$(COVERAGE_OPTS)
endef

# -----------------------------------------------------------------------
# GUI run with quiet verbosity: opens QuestaSim GUI with minimal output
# -----------------------------------------------------------------------
define RUN_TEST_GUI_QUIET
	@echo "--- $(1) [GUI QUIET MODE] ---"
	@mkdir -p coverage_data
	$(VSIM) \
		-do "log -r /*; do wave.do; coverage save -onexit coverage_data/$(1)_gui_quiet.ucdb -testname $(1)_gui_quiet" \
		testbench_opt \
		+UVM_TESTNAME=$(1) \
		+UVM_NO_RELNOTES \
		+DISABLE_CLOCK_DEBUG \
		+DISABLE_MONITOR \
		+DISABLE_WAVES \
		+uvm_set_verbosity=_ALL_,_ALL_,UVM_NONE,build \
		+uvm_set_verbosity=_ALL_,_ALL_,UVM_NONE,run \
		$(COVERAGE_OPTS)
endef

# -----------------------------------------------------------------------
# ALL 13 TESTS — 26 total simulation runs
# -----------------------------------------------------------------------
all_tests: comp
	@echo ""
	@echo "==========================================================="
	@echo " Running 13 APB VIP tests  (FULL + QUIET = 26 total runs)"
	@echo "==========================================================="
	@rm -rf coverage_data coverage_reports
	@mkdir -p coverage_data coverage_reports
	
	@echo "=== BASIC FUNCTIONALITY TESTS ==="
	$(call RUN_TEST_FULL,apb_basic_test)
	$(call RUN_TEST_QUIET,apb_basic_test)
	$(call RUN_TEST_FULL,apb_read_only_test)
	$(call RUN_TEST_QUIET,apb_read_only_test)
	$(call RUN_TEST_FULL,apb_write_only_test)
	$(call RUN_TEST_QUIET,apb_write_only_test)
	
	@echo "=== PROTOCOL & TIMING TESTS ==="
	$(call RUN_TEST_FULL,apb_protocol_test)
	$(call RUN_TEST_QUIET,apb_protocol_test)
	$(call RUN_TEST_FULL,apb_timing_test)
	$(call RUN_TEST_QUIET,apb_timing_test)
	$(call RUN_TEST_FULL,apb_reset_test)
	$(call RUN_TEST_QUIET,apb_reset_test)
	
	@echo "=== TRANSACTION & COVERAGE TESTS ==="
	$(call RUN_TEST_FULL,apb_transaction_test)
	$(call RUN_TEST_QUIET,apb_transaction_test)
	
	@echo "=== UVM FRAMEWORK TESTS ==="
	$(call RUN_TEST_FULL,apb_factory_test)
	$(call RUN_TEST_QUIET,apb_factory_test)
	$(call RUN_TEST_FULL,apb_field_auto_test)
	$(call RUN_TEST_QUIET,apb_field_auto_test)
	$(call RUN_TEST_FULL,apb_uvm_macro_test)
	$(call RUN_TEST_QUIET,apb_uvm_macro_test)
	
	@echo "=== CONFIGURATION & MODE TESTS ==="
	$(call RUN_TEST_FULL,apb_passive_test)
	$(call RUN_TEST_QUIET,apb_passive_test)
	$(call RUN_TEST_FULL,apb_master_passive_test)
	$(call RUN_TEST_QUIET,apb_master_passive_test)
	$(call RUN_TEST_FULL,apb_nocfg_test)
	$(call RUN_TEST_QUIET,apb_nocfg_test)

	@echo ""
	@echo "Merging coverage databases..."
	$(VCOVER) merge -out coverage_data/merged.ucdb coverage_data/*.ucdb
	@echo "Done. Run 'make coverage_report' for HTML output."

coverage_report:
	@mkdir -p coverage_reports/merged
	$(VCOVER) merge -out coverage_data/merged.ucdb coverage_data/*.ucdb
	$(VCOVER) report -html -htmldir coverage_reports/merged coverage_data/merged.ucdb
	@echo "Report: coverage_reports/merged/index.html"

coverage: all_tests coverage_report

# -----------------------------------------------------------------------
# Individual test targets (each runs FULL + QUIET + per-test report)
# -----------------------------------------------------------------------
timing_test: comp
	@mkdir -p coverage_data
	$(call RUN_TEST_FULL,apb_timing_test)
	$(call RUN_TEST_QUIET,apb_timing_test)
	$(VCOVER) merge -out coverage_data/apb_timing_test_merged.ucdb \
	    coverage_data/apb_timing_test_full.ucdb \
	    coverage_data/apb_timing_test_quiet.ucdb
	@mkdir -p coverage_reports/apb_timing_test
	$(VCOVER) report -html -htmldir coverage_reports/apb_timing_test \
	    coverage_data/apb_timing_test_merged.ucdb

protocol_test: comp
	@mkdir -p coverage_data
	$(call RUN_TEST_FULL,apb_protocol_test)
	$(call RUN_TEST_QUIET,apb_protocol_test)
	$(VCOVER) merge -out coverage_data/apb_protocol_test_merged.ucdb \
	    coverage_data/apb_protocol_test_full.ucdb \
	    coverage_data/apb_protocol_test_quiet.ucdb
	@mkdir -p coverage_reports/apb_protocol_test
	$(VCOVER) report -html -htmldir coverage_reports/apb_protocol_test \
	    coverage_data/apb_protocol_test_merged.ucdb

basic_test: comp
	@mkdir -p coverage_data
	$(call RUN_TEST_FULL,apb_basic_test)
	$(call RUN_TEST_QUIET,apb_basic_test)
	$(VCOVER) merge -out coverage_data/apb_basic_test_merged.ucdb \
	    coverage_data/apb_basic_test_full.ucdb \
	    coverage_data/apb_basic_test_quiet.ucdb
	@mkdir -p coverage_reports/apb_basic_test
	$(VCOVER) report -html -htmldir coverage_reports/apb_basic_test \
	    coverage_data/apb_basic_test_merged.ucdb

reset_test: comp
	@mkdir -p coverage_data
	$(call RUN_TEST_FULL,apb_reset_test)
	$(call RUN_TEST_QUIET,apb_reset_test)
	$(VCOVER) merge -out coverage_data/apb_reset_test_merged.ucdb \
	    coverage_data/apb_reset_test_full.ucdb \
	    coverage_data/apb_reset_test_quiet.ucdb
	@mkdir -p coverage_reports/apb_reset_test
	$(VCOVER) report -html -htmldir coverage_reports/apb_reset_test \
	    coverage_data/apb_reset_test_merged.ucdb

read_only_test: comp
	@mkdir -p coverage_data
	$(call RUN_TEST_FULL,apb_read_only_test)
	$(call RUN_TEST_QUIET,apb_read_only_test)
	$(VCOVER) merge -out coverage_data/apb_read_only_test_merged.ucdb \
	    coverage_data/apb_read_only_test_full.ucdb \
	    coverage_data/apb_read_only_test_quiet.ucdb
	@mkdir -p coverage_reports/apb_read_only_test
	$(VCOVER) report -html -htmldir coverage_reports/apb_read_only_test \
	    coverage_data/apb_read_only_test_merged.ucdb

write_only_test: comp
	@mkdir -p coverage_data
	$(call RUN_TEST_FULL,apb_write_only_test)
	$(call RUN_TEST_QUIET,apb_write_only_test)
	$(VCOVER) merge -out coverage_data/apb_write_only_test_merged.ucdb \
	    coverage_data/apb_write_only_test_full.ucdb \
	    coverage_data/apb_write_only_test_quiet.ucdb
	@mkdir -p coverage_reports/apb_write_only_test
	$(VCOVER) report -html -htmldir coverage_reports/apb_write_only_test \
	    coverage_data/apb_write_only_test_merged.ucdb

transaction_test: comp
	@mkdir -p coverage_data
	$(call RUN_TEST_FULL,apb_transaction_test)
	$(call RUN_TEST_QUIET,apb_transaction_test)
	$(VCOVER) merge -out coverage_data/apb_transaction_test_merged.ucdb \
	    coverage_data/apb_transaction_test_full.ucdb \
	    coverage_data/apb_transaction_test_quiet.ucdb
	@mkdir -p coverage_reports/apb_transaction_test
	$(VCOVER) report -html -htmldir coverage_reports/apb_transaction_test \
	    coverage_data/apb_transaction_test_merged.ucdb

factory_test: comp
	@mkdir -p coverage_data
	$(call RUN_TEST_FULL,apb_factory_test)
	$(call RUN_TEST_QUIET,apb_factory_test)
	$(VCOVER) merge -out coverage_data/apb_factory_test_merged.ucdb \
	    coverage_data/apb_factory_test_full.ucdb \
	    coverage_data/apb_factory_test_quiet.ucdb
	@mkdir -p coverage_reports/apb_factory_test
	$(VCOVER) report -html -htmldir coverage_reports/apb_factory_test \
	    coverage_data/apb_factory_test_merged.ucdb

passive_test: comp
	@mkdir -p coverage_data
	$(call RUN_TEST_FULL,apb_passive_test)
	$(call RUN_TEST_QUIET,apb_passive_test)
	$(VCOVER) merge -out coverage_data/apb_passive_test_merged.ucdb \
	    coverage_data/apb_passive_test_full.ucdb \
	    coverage_data/apb_passive_test_quiet.ucdb
	@mkdir -p coverage_reports/apb_passive_test
	$(VCOVER) report -html -htmldir coverage_reports/apb_passive_test \
	    coverage_data/apb_passive_test_merged.ucdb

nocfg_test: comp
	@mkdir -p coverage_data
	$(call RUN_TEST_FULL,apb_nocfg_test)
	$(call RUN_TEST_QUIET,apb_nocfg_test)
	$(VCOVER) merge -out coverage_data/apb_nocfg_test_merged.ucdb \
	    coverage_data/apb_nocfg_test_full.ucdb \
	    coverage_data/apb_nocfg_test_quiet.ucdb
	@mkdir -p coverage_reports/apb_nocfg_test
	$(VCOVER) report -html -htmldir coverage_reports/apb_nocfg_test \
	    coverage_data/apb_nocfg_test_merged.ucdb

master_passive_test: comp
	@mkdir -p coverage_data
	$(call RUN_TEST_FULL,apb_master_passive_test)
	$(call RUN_TEST_QUIET,apb_master_passive_test)
	$(VCOVER) merge -out coverage_data/apb_master_passive_test_merged.ucdb \
	    coverage_data/apb_master_passive_test_full.ucdb \
	    coverage_data/apb_master_passive_test_quiet.ucdb
	@mkdir -p coverage_reports/apb_master_passive_test
	$(VCOVER) report -html -htmldir coverage_reports/apb_master_passive_test \
	    coverage_data/apb_master_passive_test_merged.ucdb

uvm_macro_test: comp
	@mkdir -p coverage_data
	$(call RUN_TEST_FULL,apb_uvm_macro_test)
	$(call RUN_TEST_QUIET,apb_uvm_macro_test)
	$(VCOVER) merge -out coverage_data/apb_uvm_macro_test_merged.ucdb \
	    coverage_data/apb_uvm_macro_test_full.ucdb \
	    coverage_data/apb_uvm_macro_test_quiet.ucdb
	@mkdir -p coverage_reports/apb_uvm_macro_test
	$(VCOVER) report -html -htmldir coverage_reports/apb_uvm_macro_test \
	    coverage_data/apb_uvm_macro_test_merged.ucdb

field_auto_test: comp
	@mkdir -p coverage_data
	$(call RUN_TEST_FULL,apb_field_auto_test)
	$(call RUN_TEST_QUIET,apb_field_auto_test)
	$(VCOVER) merge -out coverage_data/apb_field_auto_test_merged.ucdb \
	    coverage_data/apb_field_auto_test_full.ucdb \
	    coverage_data/apb_field_auto_test_quiet.ucdb
	@mkdir -p coverage_reports/apb_field_auto_test
	$(VCOVER) report -html -htmldir coverage_reports/apb_field_auto_test \
	    coverage_data/apb_field_auto_test_merged.ucdb

# -----------------------------------------------------------------------
# Flexible single-test targets
# -----------------------------------------------------------------------
test_full: comp
	@test -n "$(TEST)" || (echo "Usage: make test_full TEST=apb_basic_test" && exit 1)
	@mkdir -p coverage_data
	$(call RUN_TEST_FULL,$(TEST))
	@mkdir -p coverage_reports/$(TEST)_full
	$(VCOVER) report -html -htmldir coverage_reports/$(TEST)_full \
	    coverage_data/$(TEST)_full.ucdb

test_quiet: comp
	@test -n "$(TEST)" || (echo "Usage: make test_quiet TEST=apb_basic_test" && exit 1)
	@mkdir -p coverage_data
	$(call RUN_TEST_QUIET,$(TEST))
	@mkdir -p coverage_reports/$(TEST)_quiet
	$(VCOVER) report -html -htmldir coverage_reports/$(TEST)_quiet \
	    coverage_data/$(TEST)_quiet.ucdb

test: comp
	@test -n "$(TEST)" || (echo "Usage: make test TEST=apb_basic_test" && exit 1)
	@mkdir -p coverage_data
	$(call RUN_TEST_FULL,$(TEST))
	$(call RUN_TEST_QUIET,$(TEST))
	$(VCOVER) merge -out coverage_data/$(TEST)_merged.ucdb \
	    coverage_data/$(TEST)_full.ucdb \
	    coverage_data/$(TEST)_quiet.ucdb
	@mkdir -p coverage_reports/$(TEST)
	$(VCOVER) report -html -htmldir coverage_reports/$(TEST) \
	    coverage_data/$(TEST)_merged.ucdb

# -----------------------------------------------------------------------
# GUI simulation target - opens QuestaSim GUI
# -----------------------------------------------------------------------
gui_test_full: comp
	@test -n "$(TEST)$(Test)$(test)" || (echo "Usage: make gui_test_full TEST=apb_basic_test" && exit 1)
	@mkdir -p coverage_data
	$(call RUN_TEST_GUI_FULL,$(or $(TEST),$(Test),$(test)))
	@echo "GUI simulation complete. Coverage will be saved when you close QuestaSim."
	@echo "Run 'make coverage_report' to generate HTML reports after closing GUI."

gui_test_quiet: comp
	@test -n "$(TEST)$(Test)$(test)" || (echo "Usage: make gui_test_quiet TEST=apb_basic_test" && exit 1)
	@mkdir -p coverage_data
	$(call RUN_TEST_GUI_QUIET,$(or $(TEST),$(Test),$(test)))
	@echo "GUI simulation complete. Coverage will be saved when you close QuestaSim."
	@echo "Run 'make coverage_report' to generate HTML reports after closing GUI."
