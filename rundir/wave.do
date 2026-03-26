# Basic wave.do for APB VIP
# Add all signals from the testbench
add wave -position insertpoint sim:/testbench/*

# Optional: Add specific hierarchies if needed
# add wave sim:/testbench/env/master_agent/*
# add wave sim:/testbench/env/slave_agent/*

# Configure view
configure wave -signalnamewidth 0
configure wave -timelineunits ns

# Run the simulation
run -all

# Quit after run (optional)
# quit -f