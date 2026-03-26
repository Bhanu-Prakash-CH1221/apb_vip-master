`ifndef _APB_BASIC_TEST_
`define _APB_BASIC_TEST_

`include "uvm_macros.svh"
import uvm_pkg::*;
import apb_common_pkg::*;
import apb_slave_pkg::*;
import apb_master_pkg::*;

class apb_basic_test extends uvm_test;
    `uvm_component_utils(apb_basic_test)

    apb_env              env;
    apb_master_config    m_apb_master_config;
    apb_slave_config     m_apb_slave_config;
    virtual apb_if        vif;

    apb_master_seq       master_seq;
    apb_slave_seq        slave_seq;

    function new(string name = "apb_basic_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        m_apb_master_config = apb_master_config::type_id::create("m_apb_master_config");
        m_apb_slave_config  = apb_slave_config::type_id::create("m_apb_slave_config");

        m_apb_master_config.is_active = apb_master_config::UVM_ACTIVE;
        m_apb_slave_config.is_active  = apb_slave_config::UVM_ACTIVE;

        uvm_config_db#(apb_master_config)::set(null, "*", "apb_master_config", m_apb_master_config);
        uvm_config_db#(apb_slave_config)::set(null,  "*", "apb_slave_config",  m_apb_slave_config);

        env = apb_env::type_id::create("env", this);

        void'(uvm_config_db#(virtual apb_if)::get(this, "", "apb_vif", vif));
        $display("Virtual interface obtained");
    endfunction

    task run_phase(uvm_phase phase);
        apb_master_seq master_seq;
        apb_slave_seq  slave_seq;

        super.run_phase(phase);
        phase.raise_objection(this, "Starting apb_basic_test");

        $display("Phase 1: MIN_DELAY (delay=1)");
        repeat(12) begin
            master_seq = apb_master_seq::type_id::create("master_seq");
            slave_seq  = apb_slave_seq::type_id::create("slave_seq");
            fork
                master_seq.start(env.master_agent.m_sequencer);
                slave_seq.start(env.slave_agent.m_sequencer);
            join
            #1ns;
        end

        $display("Phase 2: MAX_DELAY (delay=2)");
        repeat(12) begin
            master_seq = apb_master_seq::type_id::create("master_seq");
            slave_seq  = apb_slave_seq::type_id::create("slave_seq");
            fork
                master_seq.start(env.master_agent.m_sequencer);
                slave_seq.start(env.slave_agent.m_sequencer);
            join
            #2ns;
        end

        $display("Phase 3: LONG_DELAY (delay=3-10)");
        repeat(12) begin
            master_seq = apb_master_seq::type_id::create("master_seq");
            slave_seq  = apb_slave_seq::type_id::create("slave_seq");
            fork
                master_seq.start(env.master_agent.m_sequencer);
                slave_seq.start(env.slave_agent.m_sequencer);
            join
            #7ns;
        end

        $display("Phase 4: Back-to-back (CONSECUTIVE)");
        repeat(12) begin
            master_seq = apb_master_seq::type_id::create("master_seq");
            slave_seq  = apb_slave_seq::type_id::create("slave_seq");
            fork
                master_seq.start(env.master_agent.m_sequencer);
                slave_seq.start(env.slave_agent.m_sequencer);
            join
        end

        $display("Phase 5: Mixed timing");
        repeat(12) begin
            master_seq = apb_master_seq::type_id::create("master_seq");
            slave_seq  = apb_slave_seq::type_id::create("slave_seq");
            void'(master_seq.randomize());
            void'(slave_seq.randomize());
            fork
                master_seq.start(env.master_agent.m_sequencer);
                slave_seq.start(env.slave_agent.m_sequencer);
            join
            #($urandom_range(0, 5));
        end

        phase.drop_objection(this, "Finished apb_basic_test");
    endtask

endclass

`endif
