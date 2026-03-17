# Create work library
vlib work

# Set UVM_HOME environment variable
set UVM_HOME "$env(MTI_HOME)/verilog_src/uvm-1.1d"

# Common include directories
set COMMON_INCDIR "+incdir+./src/common"
set SLAVE_INCDIR "+incdir+./src/slave"
set MASTER_INCDIR "+incdir+./src/master"
set TB_INCDIR "+incdir+./tb"
set UVM_INCDIR "+incdir+$UVM_HOME/src"

# 1. Compile common files first
echo "Compiling common files..."
vlog -work work -L mtiUvm -sv -cover bcesft -mfcu -suppress 2181 -suppress 8386 \
    $UVM_INCDIR $COMMON_INCDIR \
    ./src/common/apb_defines.svh \
    ./src/common/apb_if.sv \
    ./src/common/apb_base_seq_item.svh \
    ./src/common/apb_coverage.svh \
    ./src/common/apb_common_pkg.sv

# 2. Compile slave files
echo "Compiling slave files..."
vlog -work work -L mtiUvm -sv -cover bcesft -mfcu -suppress 2181 -suppress 8386 \
    $UVM_INCDIR $COMMON_INCDIR $SLAVE_INCDIR \
    ./src/slave/apb_slave_config.svh \
    ./src/slave/apb_slave_seq_item.svh \
    ./src/slave/apb_slave_sequencer.svh \
    ./src/slave/apb_slave_driver.svh \
    ./src/slave/apb_slave_monitor.svh \
    ./src/slave/apb_slave_agent.svh \
    ./src/slave/apb_slave_seq.svh \
    ./src/slave/apb_slave_pkg.sv

# 3. Compile master files
echo "Compiling master files..."
vlog -work work -L mtiUvm -sv -cover bcesft -mfcu -suppress 2181 -suppress 8386 \
    $UVM_INCDIR $COMMON_INCDIR $SLAVE_INCDIR $MASTER_INCDIR \
    ./src/master/apb_master_config.svh \
    ./src/master/apb_master_seq_item.svh \
    ./src/master/apb_master_sequencer.svh \
    ./src/master/apb_master_driver.svh \
    ./src/master/apb_master_monitor.svh \
    ./src/master/apb_master_agent.svh \
    ./src/master/apb_master_seq.svh \
    ./src/master/apb_master_read_seq.svh \
    ./src/master/apb_master_write_seq.svh \
    ./src/master/apb_master_pkg.sv

# 4. Compile testbench files
echo "Compiling testbench files..."
vlog -work work -L mtiUvm -sv -cover bcesft -mfcu -suppress 2181 -suppress 8386 \
    $UVM_INCDIR $COMMON_INCDIR $SLAVE_INCDIR $MASTER_INCDIR $TB_INCDIR \
    ./tb/apb_scoreboard.svh \
    ./tb/apb_env.svh \
    ./tb/tests/apb_basic_test.svh \
    ./tb/tests/apb_reset_test.svh \
    ./tb/tests/apb_read_only_test.svh \
    ./tb/tests/apb_write_only_test.svh \
    ./tb/tests/apb_stress_test.svh \
    ./tb/tests/apb_enhanced_coverage_test.svh \
    ./tb/apb_test_pkg.sv \
    ./tb/testbench.sv

# Optimize the design
echo "Optimizing design..."
vopt +acc testbench -o testbench_opt

echo "Compilation completed successfully!"
