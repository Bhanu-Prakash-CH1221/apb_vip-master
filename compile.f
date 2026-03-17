# UVM and Questa setup
+incdir+$MTI_HOME/verilog_src/uvm-1.1d/src
$MTI_HOME/verilog_src/uvm-1.1d/src/uvm_pkg.sv

# Common files
+incdir+./src/common
./src/common/apb_if.sv
./src/common/apb_common_pkg.sv

# Slave files
+incdir+./src/slave
./src/slave/apb_slave_pkg.sv

# Master files
+incdir+./src/master
./src/master/apb_master_pkg.sv
./src/master/apb_master_config.svh
./src/master/apb_master_seq_item.svh
./src/master/apb_master_seq.svh
./src/master/apb_master_read_seq.svh
./src/master/apb_master_write_seq.svh
./src/master/apb_master_sequencer.svh
./src/master/apb_master_driver.svh
./src/master/apb_master_monitor.svh
./src/master/apb_master_agent.svh

# Testbench files
+incdir+./tb
./tb/apb_test_pkg.sv
./tb/apb_scoreboard.svh
./tb/apb_env.svh

# Test files
./tb/tests/apb_basic_test.svh
./tb/tests/apb_reset_test.svh
./tb/tests/apb_read_only_test.svh
./tb/tests/apb_write_only_test.svh
./tb/tests/apb_stress_test.svh
./tb/tests/apb_enhanced_coverage_test.svh

# Top level testbench
./tb/testbench.sv
