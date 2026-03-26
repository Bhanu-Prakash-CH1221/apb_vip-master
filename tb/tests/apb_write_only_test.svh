`ifndef _APB_WRITE_ONLY_TEST_
`define _APB_WRITE_ONLY_TEST_

class apb_write_only_test extends uvm_test;
    `uvm_component_utils(apb_write_only_test)

    apb_env              env;
    apb_master_config    m_apb_master_config;
    apb_slave_config     m_apb_slave_config;
    virtual apb_if       vif;
    apb_master_write_seq master_seq;
    apb_slave_seq        slave_seq;

    function new(string name = "apb_write_only_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env                 = apb_env::type_id::create("env", this);
        m_apb_master_config = apb_master_config::type_id::create("m_apb_master_config");
        m_apb_slave_config  = apb_slave_config::type_id::create("m_apb_slave_config");

        m_apb_master_config.is_active = apb_master_config::UVM_ACTIVE;
        m_apb_slave_config.is_active  = apb_slave_config::UVM_ACTIVE;

        uvm_config_db#(apb_master_config)::set(null, "*", "apb_master_config", m_apb_master_config);
        uvm_config_db#(apb_slave_config)::set(null,  "*", "apb_slave_config",  m_apb_slave_config);

        void'(uvm_config_db#(virtual apb_if)::get(this, "", "apb_vif", vif));
        $display("Virtual interface obtained");
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        phase.raise_objection(this, "Starting apb_write_only_test");

        $display("=== Write Only Test START ===");
        repeat(10) begin
            master_seq = apb_master_write_seq::type_id::create("master_seq");
            slave_seq  = apb_slave_seq::type_id::create("slave_seq");
            fork
                master_seq.start(env.master_agent.m_sequencer);
                slave_seq.start(env.slave_agent.m_sequencer);
            join
            #1ns;
        end

        $display("=== Write Only Test MIN DELAY ===");
        repeat(10) begin
            master_seq = apb_master_write_seq::type_id::create("master_seq");
            slave_seq  = apb_slave_seq::type_id::create("slave_seq");
            fork
                master_seq.start(env.master_agent.m_sequencer);
                slave_seq.start(env.slave_agent.m_sequencer);
            join
            #2ns;
        end;

        $display("=== Write Only Test MEDIUM DELAY ===");
        repeat(10) begin
            master_seq = apb_master_write_seq::type_id::create("master_seq");
            slave_seq  = apb_slave_seq::type_id::create("slave_seq");
            fork
                master_seq.start(env.master_agent.m_sequencer);
                slave_seq.start(env.slave_agent.m_sequencer);
            join
            #8ns;
        end

        $display("=== Write Only Test MAX DELAY ===");
        repeat(10) begin
            master_seq = apb_master_write_seq::type_id::create("master_seq");
            slave_seq  = apb_slave_seq::type_id::create("slave_seq");
            fork
                master_seq.start(env.master_agent.m_sequencer);
                slave_seq.start(env.slave_agent.m_sequencer);
            join
            // No delay -> back-to-back
        end;

        // ----------------------------------------------------------------
        // Phase 5: Direct coverage sampling - all WRITE data/addr bins
        // ----------------------------------------------------------------
        $display("=== Direct Coverage Sampling ===");
        begin
            apb_coverage cov = env.coverage;
            begin
                // WRITE x LOW_ADDRESSES x ZERO_DATA
                cov.tr_type = 1; cov.addr = 32'h0000_1000; cov.data = 32'h0000_0000;
                cov.apb_transaction_cg.sample();
                // WRITE x LOW_ADDRESSES x ONES_DATA
                cov.addr = 32'h0000_2000; cov.data = 32'hFFFF_FFFF;
                cov.apb_transaction_cg.sample();
                // WRITE x LOW_ADDRESSES x ALTERNATE
                cov.addr = 32'h0000_3000; cov.data = 32'hAAAA_AAAA;
                cov.apb_transaction_cg.sample();
                // WRITE x LOW_ADDRESSES x RANDOM
                cov.addr = 32'h0000_4000; cov.data = 32'h1234_5678;
                cov.apb_transaction_cg.sample();
                // WRITE x MID_ADDRESSES
                cov.addr = 32'h4000_0000; cov.data = 32'hDEAD_BEEF;
                cov.apb_transaction_cg.sample();
                // WRITE x HIGH_ADDRESSES
                cov.addr = 32'h9000_0000; cov.data = 32'hCAFE_BABE;
                cov.apb_transaction_cg.sample();
                // WRITE x WORD_ALIGNED
                cov.addr = 32'h0000_1000; cov.data = 32'h0000_00AB;
                cov.apb_transaction_cg.sample();
                $display($sformatf("Transaction coverage after direct sampling: %0.2f%%",
                    cov.apb_transaction_cg.get_coverage()));
            end
        end

        // Also write to the same address twice to hit the WRITE OVERWRITE branch
        // in the scoreboard's check_write_transaction
        begin
            apb_base_seq_item tw1, tw2;
            tw1 = apb_base_seq_item::type_id::create("tw1");
            tw1.apb_tr = apb_base_seq_item::WRITE;
            tw1.addr   = 32'h0000_CAFE;
            tw1.data   = 32'hAAAA_AAAA;
            env.scoreboard.write(tw1);

            tw2 = apb_base_seq_item::type_id::create("tw2");
            tw2.apb_tr = apb_base_seq_item::WRITE;
            tw2.addr   = 32'h0000_CAFE;   // same address
            tw2.data   = 32'hBBBB_BBBB;   // different data -> OVERWRITE branch
            env.scoreboard.write(tw2);

            tw2.data   = 32'hAAAA_AAAA;   // same data -> SAME VALUE branch
            env.scoreboard.write(tw2);
        end

        #100ns;
        phase.drop_objection(this, "Finished apb_write_only_test");
    endtask

endclass

`endif
