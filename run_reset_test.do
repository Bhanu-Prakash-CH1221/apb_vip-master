# Script to run APB reset test with 100% reset coverage
# Usage: vsim -c -do run_reset_test.do

# Compile the design
vlib work
vlog -work work -L mtiUvm -cover bcesft -sv +incdir+c:\questasim64_10.7c\verilog_src\uvm-1.1d\src +incdir+d:\Questa_Sim_projects\apb_vip-master\src\common +incdir+d:\Questa_Sim_projects\apb_vip-master\src\slave +incdir+d:\Questa_Sim_projects\apb_vip-master\src\master +incdir+d:\Questa_Sim_projects\apb_vip-master\tb d:\Questa_Sim_projects\apb_vip-master\src\common\apb_if.sv d:\Questa_Sim_projects\apb_vip-master\src\common\apb_common_pkg.sv d:\Questa_Sim_projects\apb_vip-master\src\slave\apb_slave_pkg.sv d:\Questa_Sim_projects\apb_vip-master\src\master\apb_master_pkg.sv d:\Questa_Sim_projects\apb_vip-master\tb\apb_test_pkg.sv d:\Questa_Sim_projects\apb_vip-master\tb\testbench.sv

# Optimize the design
vopt +acc -debugdb testbench -o testbench_opt

# Create coverage directory
file mkdir coverage_data

# Run the reset test with coverage
vsim -c -voptargs=+acc -classdebug -msgmode both -uvmcontrol=all +UVM_NO_RELNOTES +UVM_TESTNAME=apb_reset_test -coverage -coveranalysis -coverstore coverage_data/reset_test testbench_opt -do "run -all; coverage save -onexit coverage_data/reset_test.ucdb; exit"

# Generate coverage report
vcover report -html -htmldir coverage_report/reset_test coverage_data/reset_test.ucdb

# Display completion message
echo "APB Reset Test Completed Successfully!"
echo "Coverage Report: coverage_report/reset_test/index.html"
