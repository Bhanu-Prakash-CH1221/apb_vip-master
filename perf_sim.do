# Performance-optimized simulation script for APB VIP
# This script runs the simulation with all performance optimizations enabled

# Clean and compile
make comp

# Run performance-optimized simulation
# Usage: make sim_perf UVM_TESTNAME=<test_name> [PERFORMANCE_MODE=1]
make sim_perf UVM_TESTNAME=$(UVM_TESTNAME) +PERFORMANCE_MODE

# To enable waveform dumping during performance testing (if needed for debugging):
# make sim_perf UVM_TESTNAME=$(UVM_TESTNAME) +PERFORMANCE_MODE +ENABLE_WAVES

# To enable signal monitoring during performance testing (if needed for debugging):
# make sim_perf UVM_TESTNAME=$(UVM_TESTNAME) +PERFORMANCE_MODE +DEBUG_MONITOR
