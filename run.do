UVM_DIR = C:\questasim64_10.7c\verilog_src\uvm-1.1d\src
TB_DIR = +incdir+d:\Questa Sim projects\apb_vip-master\tb
SRC_DIR = +incdir+d:\Questa Sim projects\apb_vip-master\src
MASTER_DIR = +incdir+d:\Questa Sim projects\apb_vip-master\src\master
SLAVE_DIR = +incdir+d:\Questa Sim projects\apb_vip-master\src\slave
COMMON_DIR = +incdir+d:\Questa Sim projects\apb_vip-master\src\common
UVM_TESTNAME=apb_test

TB = d:\Questa Sim projects\apb_vip-master\tb
SRC = d:\Questa Sim projects\apb_vip-master\src
MASTER =d:\Questa Sim projects\apb_vip-master\src\master
SLAVE = d:\Questa Sim projects\apb_vip-master\src\slave
COMMON = d:\Questa Sim projects\apb_vip-master\src\common

clean:
	rmdir work /s /q
	del certe_dump.* vsim.* *.log *.tgz *~ *.vstf
	
comp: clean
	vlib work
	vlog -work work -sv $(UVM_DIR) $(COMMON_DIR) $(SLAVE_DIR) $(MASTER_DIR) $(TB_DIR) \
	$(COMMON)/apb_if.sv $(COMMON)/apb_common_pkg.sv $(MASTER)/apb_master_pkg.sv $(SLAVE)/apb_slave_pkg.sv \
	$(TB)/apb_env.svh $(TB)/apb_test.svh $(TB)/testbench.sv
	vopt +acc -debugdb testbench -o testbench_opt
	

sim: comp
	vsim  -voptargs=+acc -do "wave.do" -classdebug -debugdb -msgmode both -uvmcontrol=all  -OVMdebug -assertdebug +UVM_TESTNAME=$(UVM_TESTNAME) -coverage -coveranalysis testbench_opt

# Performance-optimized simulation (no debug options)
sim_perf: comp
	vsim -voptargs=+acc -msgmode both +UVM_TESTNAME=$(UVM_TESTNAME) testbench_opt

# Coverage report generation
coverage_report:
	vcover report -html -output coverage_report testbench_opt.ucdb
	@echo "Coverage report generated: coverage_report/index.html"