# =============================================================================
# APB VIP Makefile — QuestaSim 10.7c, MinGW64, Windows
# =============================================================================
# PATHS: Use forward slashes throughout (MinGW64 compatible)
# Run: make all_tests    → compiles + runs all 12 tests (24 total runs) + report
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
        test test_full test_quiet

help:
	@echo ""
	@echo "APB VIP Coverage Makefile — QuestaSim 10.7c"
	@echo "============================================="
	@echo "  make all_tests          Run all 12 tests (FULL+QUIET = 24 runs) + report"
	@echo "  make coverage           all_tests + merged HTML report"
	@echo "  make clean              Wipe build artifacts"
	@echo ""
	@echo "Individual tests (dual-verbosity):"
	@echo "  make timing_test        make protocol_test     make basic_test"
	@echo "  make reset_test         make read_only_test    make write_only_test"
	@echo "  make transaction_test   make factory_test      make passive_test"
	@echo "  make nocfg_test         make master_passive_test"
	@echo "  make uvm_macro_test"
	@echo "  make field_auto_test    <<-- 100% field automation coverage"
	@echo "Flexible single test:"
	@echo "  make test TEST=apb_basic_test"
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
# ALL 12 TESTS — 24 total simulation runs
# -----------------------------------------------------------------------
all_tests: comp
	@echo ""
	@echo "==========================================================="
	@echo " Running 12 APB VIP tests  (FULL + QUIET = 24 total runs)"
	@echo "==========================================================="
	@rm -rf coverage_data coverage_reports
	@mkdir -p coverage_data coverage_reports
	$(call RUN_TEST_FULL,apb_timing_test)
	$(call RUN_TEST_QUIET,apb_timing_test)
	$(call RUN_TEST_FULL,apb_protocol_test)
	$(call RUN_TEST_QUIET,apb_protocol_test)
	$(call RUN_TEST_FULL,apb_basic_test)
	$(call RUN_TEST_QUIET,apb_basic_test)
	$(call RUN_TEST_FULL,apb_reset_test)
	$(call RUN_TEST_QUIET,apb_reset_test)
	$(call RUN_TEST_FULL,apb_read_only_test)
	$(call RUN_TEST_QUIET,apb_read_only_test)
	$(call RUN_TEST_FULL,apb_write_only_test)
	$(call RUN_TEST_QUIET,apb_write_only_test)
	$(call RUN_TEST_FULL,apb_transaction_test)
	$(call RUN_TEST_QUIET,apb_transaction_test)
	$(call RUN_TEST_FULL,apb_factory_test)
	$(call RUN_TEST_QUIET,apb_factory_test)
	$(call RUN_TEST_FULL,apb_passive_test)
	$(call RUN_TEST_QUIET,apb_passive_test)
	$(call RUN_TEST_FULL,apb_nocfg_test)
	$(call RUN_TEST_QUIET,apb_nocfg_test)
	$(call RUN_TEST_FULL,apb_master_passive_test)
	$(call RUN_TEST_QUIET,apb_master_passive_test)
	$(call RUN_TEST_FULL,apb_uvm_macro_test)
	$(call RUN_TEST_QUIET,apb_uvm_macro_test)
	$(call RUN_TEST_FULL,apb_field_auto_test)
	$(call RUN_TEST_QUIET,apb_field_auto_test)

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
	@echo "Report: coverage_reports/$(TEST)/index.html"
