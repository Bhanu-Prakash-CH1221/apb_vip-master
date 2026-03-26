`ifndef _APB_MASTER_DRIVER_
`define _APB_MASTER_DRIVER_

`include "uvm_macros.svh"
import uvm_pkg::*;

class apb_master_driver extends uvm_driver#(apb_master_seq_item);
    `uvm_component_utils(apb_master_driver)

    virtual apb_if      vif;
    apb_master_seq_item m_apb_seq_item;
    apb_coverage        apb_cov;

    extern function new(string name = "apb_master_driver", uvm_component parent = null);
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual task           run_phase(uvm_phase phase);
    extern virtual task           wait_for_reset();
    extern virtual task           get_and_drive();
    extern virtual task           init_signals();
endclass

function apb_master_driver::new(string name = "apb_master_driver", uvm_component parent = null);
    super.new(name, parent);
endfunction

function void apb_master_driver::build_phase(uvm_phase phase);
    super.build_phase(phase);
    void'(uvm_config_db#(virtual apb_if)::get(this, "", "apb_vif", vif));
    $display("Master driver: virtual interface obtained");
    apb_cov = apb_coverage::type_id::create("apb_cov", this);
    uvm_config_db#(apb_coverage)::set(this, "", "apb_cov", apb_cov);
    $display("Master driver: coverage instance created");
endfunction

task apb_master_driver::run_phase(uvm_phase phase);
    super.run_phase(phase);
    init_signals();
    wait_for_reset();
    get_and_drive();
endtask

task apb_master_driver::get_and_drive();
    $display("Master driver starting get_and_drive");
    forever begin
        $display("Waiting for sequence item");
        m_apb_seq_item = apb_master_seq_item::type_id::create("m_apb_seq_item", this);
        seq_item_port.get_next_item(m_apb_seq_item);
        $display($sformatf("Got item: %s", m_apb_seq_item.convert2string()));

        apb_cov.write(m_apb_seq_item);

        repeat(m_apb_seq_item.delay)
            @(posedge vif.PCLK);

        $display($sformatf("Driving: addr=%0h data=%0h write=%0b",
            m_apb_seq_item.addr, m_apb_seq_item.data, m_apb_seq_item.apb_tr));

        vif.PSEL   <= 1'b1;
        vif.PADDR  <= m_apb_seq_item.addr;
        vif.PWRITE <= (m_apb_seq_item.apb_tr == apb_base_seq_item::WRITE) ? 1'b1 : 1'b0;

        if (m_apb_seq_item.apb_tr == apb_base_seq_item::WRITE) begin
            vif.PWDATA <= m_apb_seq_item.data;
            $display("WRITE transaction: PWDATA set");
        end else begin
            vif.PWDATA <= '0;
            $display("READ transaction: PWDATA cleared");
        end

        @(posedge vif.PCLK);
        vif.PENABLE <= 1'b1;
        wait(vif.PREADY);

        @(posedge vif.PCLK);
        vif.PSEL    <= 1'b0;
        vif.PENABLE <= 1'b0;

        apb_cov.psel           = 1'b0;
        apb_cov.penable        = 1'b0;
        apb_cov.pwrite         = (m_apb_seq_item.apb_tr == apb_base_seq_item::WRITE) ? 1'b1 : 1'b0;
        apb_cov.protocol_phase = 0;
        apb_cov.sample_protocol_state();

        $display($psprintf(" %s", m_apb_seq_item.convert2string()));
        seq_item_port.item_done();
        $display("Transaction completed");
    end
endtask

task apb_master_driver::wait_for_reset();
    @(negedge vif.PRESET_N);
    $display("Reset asserted - holding signals");
    vif.PSEL    <= 1'b0;
    vif.PWRITE  <= 1'b0;
    vif.PENABLE <= 1'b0;
    vif.PWDATA  <= '0;
    vif.PADDR   <= '0;
    @(posedge vif.PRESET_N);
    $display("Reset released - ready to drive");
endtask

task apb_master_driver::init_signals();
    vif.PSEL    <= 1'b0;
    vif.PWRITE  <= 1'b0;
    vif.PENABLE <= 1'b0;
    vif.PWDATA  <= '0;
    vif.PADDR   <= '0;
endtask

`endif
