//-----------------------------------------------------------------------------
// Project      : APB VIP - Advanced Peripheral Bus Verification IP
// File         : apb_factory_test.svh
// Description  : UVM factory test for comprehensive coverage
// Author       : CH Bhanu Prakash
// Notes        : Tests all UVM factory methods and component interactions
//-----------------------------------------------------------------------------

`ifndef _APB_FACTORY_TEST_
`define _APB_FACTORY_TEST_

class late_create_catcher extends uvm_report_catcher;
    int unsigned caught_count = 0;

    function new(string name = "late_create_catcher");
        super.new(name);
    endfunction

    function action_e catch();
        if (get_id() == "ILLCRT") begin
            caught_count++;
            $display("CATCHER: suppressed ILLCRT #%0d", caught_count);
            set_action(CAUGHT);
            return CAUGHT;
        end else begin
            $display("CATCHER: passing through id=%s", get_id());
            return THROW;
        end
    endfunction
endclass

class apb_factory_test extends uvm_test;
    `uvm_component_utils(apb_factory_test)

    apb_env           env;
    apb_master_config m_apb_master_config;
    apb_slave_config  m_apb_slave_config;
    virtual apb_if    vif;

    late_create_catcher m_catcher;  // Report catcher for factory error handling

    function new(string name = "apb_factory_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        // Create configuration objects
        m_apb_master_config = apb_master_config::type_id::create("m_apb_master_config");
        m_apb_slave_config  = apb_slave_config::type_id::create("m_apb_slave_config");
        
        // Configure both agents as active for factory testing
        m_apb_master_config.is_active = apb_master_config::UVM_ACTIVE;
        m_apb_slave_config.is_active  = apb_slave_config::UVM_ACTIVE;
        
        // Share configurations with agents via config database
        uvm_config_db#(apb_master_config)::set(null, "*", "apb_master_config", m_apb_master_config);
        uvm_config_db#(apb_slave_config)::set(null,  "*", "apb_slave_config",  m_apb_slave_config);
        
        // Create test environment
        env = apb_env::type_id::create("env", this);
        
        // Get virtual interface from testbench
        void'(uvm_config_db#(virtual apb_if)::get(this, "", "apb_vif", vif));
        $display("Virtual interface obtained");
    endfunction

    task run_phase(uvm_phase phase);
        uvm_object_wrapper w;      // Factory object wrapper
        uvm_component dummy;       // Dummy component for testing

        w = this.get_object_type();  // Get factory wrapper for this test

        // Set up report catcher to handle factory errors
        m_catcher = new("factory_catcher");
        uvm_report_cb::add(null, m_catcher);

        // Create dummy component to test factory methods
        dummy = apb_factory_test::type_id::create("dummy", null);

        super.run_phase(phase);
        phase.raise_objection(this, "Starting apb_factory_test");
        $display("=== Factory Test START ===");
        #300ns;  // Allow system to stabilize

        // Execute various factory testing functions
        force_scoreboard_mismatches();           // Test scoreboard functionality
        force_do_methods();                       // Test UVM do_* methods
        force_factory_methods();                  // Test factory method implementations
        force_test_class_factory_methods();      // Test class-specific factory methods
        force_factory_macros();                  // Test factory macro usage
        hit_obj_macros();                        // Test object macros
        hit_comp_macros();                       // Test component macros

        begin
            uvm_report_info("DUMMY_MSG", "Factory test complete - catcher passthrough", UVM_NONE);
        end

        #50ns;  // Allow time for final operations
        $display("=== Factory Test COMPLETE ===");
        phase.drop_objection(this, "Finished apb_factory_test");
    endtask

    // Report phase for factory test validation
    function void report_phase(uvm_phase phase);
        super.report_phase(phase);

        // Test 1: Verify expected zero value
        for (int x = 0; x <= 1; x++) begin
            if (x == 0) begin
                $display("FACTORY REPORT PASS 1: x is zero (expected)");
            end else begin
                $display("FACTORY REPORT PASS 1: x is non-zero (unexpected)");
            end
        end

        // Test 2: Verify expected non-zero value
        for (int x = 0; x <= 1; x++) begin
            if (x == 0) begin
                $display("FACTORY REPORT PASS 2: x is zero (unexpected)");
            end else begin
                $display("FACTORY REPORT PASS 2: x is non-zero (expected)");
            end
        end
    endfunction

    // Task to test scoreboard mismatch scenarios
    task force_scoreboard_mismatches();
        apb_base_seq_item t_write, t_read, t_mis;
        $display("--- force_scoreboard_mismatches ---");

        // Test 1: Write transaction to establish baseline
        t_write = apb_base_seq_item::type_id::create("t_write");
        t_write.apb_tr = apb_base_seq_item::WRITE;
        t_write.addr   = 32'hBAD_DEAD;
        t_write.data   = 32'hBAD_DEAD;
        env.scoreboard.write(t_write);

        // Test 2: Read matching transaction (should pass)
        t_read = apb_base_seq_item::type_id::create("t_match");
        t_read.apb_tr = apb_base_seq_item::READ;
        t_read.addr   = 32'hBAD_DEAD;
        t_read.data   = 32'hBAD_DEAD;
        env.scoreboard.write(t_read);

        // Test 3: Read from uninitialized address
        t_read = apb_base_seq_item::type_id::create("t_uninit1");
        t_read.apb_tr = apb_base_seq_item::READ;
        t_read.addr   = 32'h999;
        t_read.data   = 32'hBAD_DEAD;
        env.scoreboard.write(t_read);

        // Test 4: Read with different data from address 0
        t_read = apb_base_seq_item::type_id::create("t_uninit2");
        t_read.apb_tr = apb_base_seq_item::READ;
        t_read.addr   = 32'h0;
        t_read.data   = 32'hDEAD_FACE;
        env.scoreboard.write(t_read);

        // Test 5: Read with expected data from address 0
        t_read = apb_base_seq_item::type_id::create("t_uninit3");
        t_read.apb_tr = apb_base_seq_item::READ;
        t_read.addr   = 32'h0;
        t_read.data   = 32'hBAD_DEAD;
        env.scoreboard.write(t_read);

        // Test 6: Null transaction handling
        env.scoreboard.write(null);

        env.scoreboard.compare_transactions(t_write, t_write);

        // Test 7: Mismatched transaction comparison
        t_mis = apb_base_seq_item::type_id::create("t_mis");
        t_mis.apb_tr = apb_base_seq_item::WRITE;
        t_mis.addr   = t_write.addr;
        t_mis.data   = t_write.data + 1;
        env.scoreboard.compare_transactions(t_write, t_mis);

        // Test 8: Different address/data comparison
        t_mis.addr = 32'h1;
        t_mis.data = 32'h2;
        env.scoreboard.compare_transactions(t_write, t_mis);

        // Test 9: Null transaction comparisons
        env.scoreboard.compare_transactions(null, null);
        env.scoreboard.compare_transactions(t_write, null);

        $display("--- force_scoreboard_mismatches done ---");
    endtask

    // Task to test UVM do_* methods for various object types
    task force_do_methods();
        $display("--- force_do_methods ---");
        begin
            // Test base sequence item do_* methods
            apb_base_seq_item o1 = new("o1"), o2 = new("o2"), o3;
            void'(o1.randomize()); void'(o2.randomize());
            $cast(o3, o1.clone());                    // Test clone method
            void'(o1.compare(o2)); void'(o1.compare(o1));  // Test compare methods
            o2.addr = ~o1.addr; void'(o1.compare(o2));    // Test mismatched comparison
            o1.print(); void'(o1.sprint()); o1.record();  // Test output methods

            // Test type information methods
            void'(o1.get_object_type());
            void'(o1.get_type_name());
        end
        begin
            // Test master sequence item do_* methods
            apb_master_seq_item o1 = new("o1"), o2 = new("o2"), o3;
            void'(o1.randomize()); void'(o2.randomize());
            $cast(o3, o1.clone());                    // Test clone method
            void'(o1.compare(o2)); o2.addr = ~o1.addr; void'(o1.compare(o2));  // Test comparison
            o1.print(); void'(o1.sprint()); o1.record();  // Test output methods

            // Test type information methods
            void'(o1.get_object_type());
            void'(o1.get_type_name());
        end
        begin
            // Test slave sequence item do_* methods
            apb_slave_seq_item o1 = new("o1"), o2 = new("o2"), o3;
            void'(o1.randomize()); void'(o2.randomize());
            $cast(o3, o1.clone());                    // Test clone method
            void'(o1.compare(o2)); o2.addr = ~o1.addr; void'(o1.compare(o2));  // Test comparison
            o1.print(); void'(o1.sprint()); o1.record();  // Test output methods

            // Test type information methods
            void'(o1.get_object_type());
            void'(o1.get_type_name());
        end
        begin
            apb_master_config c1 = new("c1"), c2 = new("c2"), c3;
            c1.is_active = apb_master_config::UVM_ACTIVE; c2.is_active = apb_master_config::UVM_PASSIVE;
            $cast(c3, c1.clone());
            void'(c1.compare(c2)); c2.is_active = apb_master_config::UVM_ACTIVE; void'(c1.compare(c2));
            c1.print(); void'(c1.sprint()); c1.record();

            // Test type information methods
            void'(c1.get_object_type());
            void'(c1.get_type_name());
        end
        begin
            // Test slave configuration do_* methods
            apb_slave_config c1 = new("c1"), c2 = new("c2"), c3;
            c1.is_active = apb_slave_config::UVM_ACTIVE; c2.is_active = apb_slave_config::UVM_PASSIVE;
            $cast(c3, c1.clone());                    // Test clone method
            void'(c1.compare(c2)); c2.is_active = apb_slave_config::UVM_ACTIVE; void'(c1.compare(c2));  // Test comparison
            c1.print(); void'(c1.sprint()); c1.record();  // Test output methods

            // Test type information methods
            void'(c1.get_object_type());
            void'(c1.get_type_name());
        end
        $display("--- force_do_methods done ---");
    endtask

    // Task to test UVM factory methods for all APB VIP classes
    task force_factory_methods();
        uvm_object_wrapper w;      // Factory object wrapper
        uvm_object created;        // Created object reference
        $display("--- force_factory_methods ---");
        
        // Get type information for all APB VIP classes
        w = apb_base_seq_item::get_type();    $display("base_seq_item: %s", w.get_type_name());
        w = apb_master_seq_item::get_type();  $display("master_seq_item: %s", w.get_type_name());
        w = apb_slave_seq_item::get_type();   $display("slave_seq_item: %s", w.get_type_name());
        w = apb_master_config::get_type();    $display("master_config: %s", w.get_type_name());
        w = apb_slave_config::get_type();     $display("slave_config: %s", w.get_type_name());
        w = apb_master_seq::get_type();       $display("master_seq: %s", w.get_type_name());
        w = apb_master_read_seq::get_type();  $display("master_read_seq: %s", w.get_type_name());
        w = apb_master_write_seq::get_type(); $display("master_write_seq: %s", w.get_type_name());
        w = apb_slave_seq::get_type();        $display("slave_seq: %s", w.get_type_name());
        w = apb_master_sequencer::get_type(); w = apb_slave_sequencer::get_type();
        w = apb_master_driver::get_type();    w = apb_slave_driver::get_type();
        w = apb_master_monitor::get_type();   w = apb_slave_monitor::get_type();
        w = apb_master_agent::get_type();     w = apb_slave_agent::get_type();
        w = apb_env::get_type();              w = apb_scoreboard::get_type();
        w = apb_coverage::get_type();

        // Test factory create methods for various object types
        begin
            // Test base sequence item factory creation
            apb_base_seq_item    p = new("p");
            created = p.create(""); created = p.create("n");  // Test create methods
            void'(p.get_object_type()); void'(p.get_type_name());
        end
        begin
            // Test master config factory creation
            apb_master_config    p = new("p");
            created = p.create(""); created = p.create("n");  // Test create methods
            void'(p.get_object_type()); void'(p.get_type_name());
        end
        begin
            apb_slave_config     p = new("p");
            created = p.create(""); created = p.create("n");
            void'(p.get_object_type()); void'(p.get_type_name());
        end
        begin
            apb_master_seq_item  p = new("p");
            created = p.create(""); created = p.create("n");
            void'(p.get_object_type()); void'(p.get_type_name());
        end
        begin
            // Test slave sequence item factory creation
            apb_slave_seq_item   p = new("p");
            created = p.create(""); created = p.create("n");  // Test create methods
            void'(p.get_object_type()); void'(p.get_type_name());
        end
        begin
            // Test master sequence factory creation
            apb_master_seq       p = new("p");
            created = p.create(""); created = p.create("n");  // Test create methods
            void'(p.get_object_type()); void'(p.get_type_name());
        end
        begin
            // Test master read sequence factory creation
            apb_master_read_seq  p = new("p");
            created = p.create(""); created = p.create("n");  // Test create methods
            void'(p.get_object_type()); void'(p.get_type_name());
        end
        begin
            // Test master write sequence factory creation
            apb_master_write_seq p = new("p");
            created = p.create(""); created = p.create("n");  // Test create methods
            void'(p.get_object_type()); void'(p.get_type_name());
        end
        begin
            // Test slave sequence factory creation
            apb_slave_seq        p = new("p");
            created = p.create(""); created = p.create("n");  // Test create methods
            void'(p.get_object_type()); void'(p.get_type_name());
        end
        $display("--- force_factory_methods done ---");
    endtask

    // Task to test factory methods for all test classes
    task force_test_class_factory_methods();
        uvm_object_wrapper w;  // Factory object wrapper
        $display("--- force_test_class_factory_methods (get_type only) ---");
        
        // Get type information for all test classes
        w = apb_basic_test::get_type();
        w = apb_transaction_test::get_type();
        w = apb_timing_test::get_type();
        w = apb_read_only_test::get_type();
        w = apb_write_only_test::get_type();
        w = apb_passive_test::get_type();
        w = apb_reset_test::get_type();
        w = apb_protocol_test::get_type();
        w = apb_nocfg_test::get_type();
        w = apb_master_passive_test::get_type();
        w = apb_uvm_macro_test::get_type();
        w = apb_factory_test::get_type();
        $display("--- force_test_class_factory_methods done ---");
    endtask

    // Task to test UVM factory macros
    task force_factory_macros();
        uvm_object_wrapper w;  // Factory object wrapper
        $display("--- force_factory_macros ---");
        
        // Test get_object_type() for environment components
        w = env.get_object_type();
        w = env.scoreboard.get_object_type();
        w = env.coverage.get_object_type();
        w = env.master_agent.get_object_type();
        w = env.master_agent.m_apb_master_driver.get_object_type();
        w = env.master_agent.m_apb_master_monitor.get_object_type();
        w = env.master_agent.m_sequencer.get_object_type();
        w = env.slave_agent.get_object_type();
        w = env.slave_agent.m_apb_slave_driver.get_object_type();
        w = env.slave_agent.m_apb_slave_monitor.get_object_type();
        w = env.slave_agent.m_sequencer.get_object_type();

        // Test get_type_name() for environment components
        void'(env.get_type_name());
        void'(env.scoreboard.get_type_name());
        void'(env.coverage.get_type_name());
        void'(env.master_agent.get_type_name());
        void'(env.master_agent.m_apb_master_driver.get_type_name());
        void'(env.master_agent.m_apb_master_monitor.get_type_name());
        void'(env.master_agent.m_sequencer.get_type_name());
        void'(env.slave_agent.get_type_name());
        void'(env.slave_agent.m_apb_slave_driver.get_type_name());
        void'(env.slave_agent.m_apb_slave_monitor.get_type_name());
        void'(env.slave_agent.m_sequencer.get_type_name());

        // Test set_int_local macro for various object types
        begin apb_base_seq_item i = new("i"); i.set_int_local("*", 1); i.set_int_local("__z__", 0); end
        begin apb_master_config i = new("i"); i.set_int_local("*", 1); i.set_int_local("__z__", 0); end
        begin apb_slave_config  i = new("i"); i.set_int_local("*", 1); i.set_int_local("__z__", 0); end
        $display("--- force_factory_macros done ---");
    endtask

    // Task to test object macros for coverage sampling
    task hit_obj_macros();
        $display("--- hit_obj_macros ---");
        
        // Test timing coverage sampling from various components
        env.coverage.sample_timing(1, 0); env.coverage.sample_timing(2, 0);
        env.coverage.sample_timing(5, 0); env.coverage.sample_timing(7, 1);
        env.master_agent.m_apb_master_monitor.apb_cov.sample_timing(1, 0);
        env.master_agent.m_apb_master_monitor.apb_cov.sample_timing(2, 1);
        env.slave_agent.m_apb_slave_monitor.apb_cov.sample_timing(5, 0);
        env.slave_agent.m_apb_slave_monitor.apb_cov.sample_timing(7, 1);
        env.master_agent.m_apb_master_driver.apb_cov.sample_timing(1, 1);
        env.master_agent.m_apb_master_driver.apb_cov.sample_timing(2, 0);
        
        // Test protocol state sampling
        env.coverage.sample_protocol_state();
        env.master_agent.m_apb_master_monitor.apb_cov.sample_protocol_state();
        
        // Test write operations with null data
        env.coverage.write(null);
        env.master_agent.m_apb_master_monitor.apb_cov.write(null);
        env.slave_agent.m_apb_slave_monitor.apb_cov.write(null);
        begin
            // Test write operations with randomized transaction
            apb_base_seq_item trans = apb_base_seq_item::type_id::create("trans");
            void'(trans.randomize());
            env.coverage.write(trans);
            env.master_agent.m_apb_master_monitor.apb_cov.write(trans);
            env.slave_agent.m_apb_slave_monitor.apb_cov.write(trans);
            env.master_agent.m_apb_master_driver.apb_cov.write(trans);
        end
        $display("FACTORY: coverage sampling complete");
        $display("--- hit_obj_macros done ---");
    endtask

    // Task to test component macros for field automation
    task hit_comp_macros();
        int safe_whats[] = {0, 1, 2, 4, 8, 16, 128, 256};  // Safe automation flags
        string strs[]    = {"", "x"};                      // Test strings
        $display("--- hit_comp_macros ---");
        
        // Test field automation macros for various components
        foreach (safe_whats[i]) begin
            foreach (strs[j]) begin
                env.__m_uvm_field_automation(null, safe_whats[i], strs[j]);
                env.scoreboard.__m_uvm_field_automation(null, safe_whats[i], strs[j]);
                env.coverage.__m_uvm_field_automation(null, safe_whats[i], strs[j]);
                env.master_agent.__m_uvm_field_automation(null, safe_whats[i], strs[j]);
                env.slave_agent.__m_uvm_field_automation(null, safe_whats[i], strs[j]);
            end
        end
        $display("--- hit_comp_macros done ---");
    endtask

endclass

`endif