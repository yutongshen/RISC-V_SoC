`include "dbgapb_define.h"
`include "dbgapb_mmap.h"

module dbgapb (
    input                 pclk,
    input                 presetn,
    input                 psel,
    input                 penable,
    input        [ 31: 0] paddr,
    input                 pwrite,
    input        [  3: 0] pstrb,
    input        [ 31: 0] pwdata,
    output logic [ 31: 0] prdata,
    output logic          pslverr,
    output logic          pready,

    output logic [ 11: 0] addr_out,
    output logic [ 31: 0] wdata_out,
    output logic          gpr_rd,
    output logic          gpr_wr,
    input        [ 31: 0] gpr_in,
    output logic          csr_rd,
    output logic          csr_wr,
    input        [ 31: 0] csr_in,
    input        [ 31: 0] pc,
    output logic [ 31: 0] inst_out,
    output logic          exec,
    input                 halted,
    output logic          attach
);

logic        dbg_en;
logic [31:0] dbg_inst;
logic        dbg_inst_wr;
logic [31:0] dbg_wdata;
logic        dbg_wdata_wr;
logic [31:0] dbg_rdata;

logic [31:0] wdata_reg;
logic [31:0] rdata_reg;
logic [31:0] status_reg;

logic        rdata_sel;
logic        pc_rd;

logic        nxt_attach;
logic [31:0] nxt_inst_out;
logic        nxt_exec;
logic        nxt_rdata_sel;
logic        nxt_pc_rd;
logic [12:0] nxt_addr_out;
logic        nxt_gpr_rd;
logic        nxt_csr_rd;
logic        nxt_gpr_wr;
logic        nxt_csr_wr;

logic [ 9:0] nxt_ready_cnt;
logic [ 9:0] ready_cnt;

assign status_reg = {30'b0, halted, attach};

always_ff @(posedge pclk or negedge presetn) begin
    if (~presetn) begin
        rdata_reg <= 32'b0;
    end
    else if (pc_rd) begin
        rdata_reg <= pc;
    end
    else if (gpr_rd) begin
        rdata_reg <= gpr_in;
    end
    else if (csr_rd) begin
        rdata_reg <= csr_in;
    end
end

assign dbg_rdata = rdata_sel ? status_reg : rdata_reg;

always_ff @(posedge pclk or negedge presetn) begin
    if (~presetn) begin
        wdata_reg <= 32'b0;
    end
    else if (dbg_wdata_wr) begin
        wdata_reg <= dbg_wdata;
    end
end

assign wdata_out = wdata_reg;

always_ff @(posedge pclk or negedge presetn) begin
    if (~presetn) begin
        attach     <= 1'b0;
        inst_out   <= 32'b0;
        exec       <= 1'b0;
        rdata_sel  <= 1'b0;
        pc_rd      <= 1'b0;
        addr_out   <= 12'b0;
        gpr_rd     <= 1'b0;
        csr_rd     <= 1'b0;
        gpr_wr     <= 1'b0;
        csr_wr     <= 1'b0;
    end
    else if (dbg_inst_wr) begin
        attach     <= nxt_attach;
        inst_out   <= nxt_inst_out;
        exec       <= nxt_exec;
        rdata_sel  <= nxt_rdata_sel;
        pc_rd      <= nxt_pc_rd;
        addr_out   <= nxt_addr_out;
        gpr_rd     <= nxt_gpr_rd;
        csr_rd     <= nxt_csr_rd;
        gpr_wr     <= nxt_gpr_wr;
        csr_wr     <= nxt_csr_wr;
    end
    else begin
        exec       <= 1'b0;
        pc_rd      <= 1'b0;
        gpr_rd     <= 1'b0;
        csr_rd     <= 1'b0;
        gpr_wr     <= 1'b0;
        csr_wr     <= 1'b0;
    end
end

always_comb begin
    nxt_attach    = attach;
    nxt_inst_out  = inst_out;
    nxt_exec      = 1'b0;
    nxt_rdata_sel = rdata_sel;
    nxt_pc_rd     = 1'b0;
    nxt_addr_out  = addr_out;
    nxt_gpr_rd    = 1'b0;
    nxt_csr_rd    = 1'b0;
    nxt_gpr_wr    = 1'b0;
    nxt_csr_wr    = 1'b0;
    case (dbg_inst[11:0])
        `INST_ATTACH: begin
            nxt_attach    = 1'b1;
        end
        `INST_RESUME: begin
            nxt_attach    = 1'b0;
        end
        `INST_INSTREG_WR: begin
            nxt_inst_out  = wdata_reg;
        end
        `INST_EXECUTE: begin
            nxt_exec      = 1'b1;
        end
        `INST_STATUS_RD: begin
            nxt_rdata_sel = 1'b1;
        end
        `INST_PC_RD: begin
            nxt_rdata_sel = 1'b0;
            nxt_pc_rd     = 1'b1;
        end
        `INST_GPR_RD: begin
            nxt_rdata_sel = 1'b0;
            nxt_addr_out  = {4'b0, dbg_inst[23:16]};
            nxt_gpr_rd    = 1'b1;
        end
        `INST_CSR_RD: begin
            nxt_rdata_sel = 1'b0;
            nxt_addr_out  = dbg_inst[27:16];
            nxt_csr_rd    = 1'b1;
        end
        `INST_GPR_WR: begin
            nxt_addr_out  = {7'b0, dbg_inst[20:16]};
            nxt_gpr_wr    = 1'b1;
        end
        `INST_CSR_WR: begin
            nxt_addr_out  = dbg_inst[27:16];
            nxt_csr_wr    = 1'b1;
        end
    endcase
end

logic        apb_wr;
logic        dbgapb_wr;

assign apb_wr    = ~penable && psel && pwrite;
assign dbgapb_wr = dbg_en && apb_wr;

always_ff @(posedge pclk or negedge presetn) begin
    if (~presetn) begin
        dbg_en <= 1'b0;
    end
    else if (apb_wr && paddr[11:0] == `DBGAPB_DBG_EN) begin
        dbg_en <= pwdata[0];
    end
end

always_ff @(posedge pclk or negedge presetn) begin
    if (~presetn) begin
        dbg_inst <= 32'b0;
    end
    else if (dbgapb_wr && paddr[11:0] == `DBGAPB_INST) begin
        dbg_inst <= pwdata;
    end
end

always_ff @(posedge pclk or negedge presetn) begin
    if (~presetn) begin
        dbg_inst_wr <= 1'b0;
    end
    else if (dbgapb_wr && paddr[11:0] == `DBGAPB_INST_WR) begin
        dbg_inst_wr <= 1'b1;
    end
    else begin
        dbg_inst_wr <= 1'b0;
    end
end

always_ff @(posedge pclk or negedge presetn) begin
    if (~presetn) begin
        dbg_wdata <= 32'b0;
    end
    else if (dbgapb_wr && paddr[11:0] == `DBGAPB_WDATA) begin
        dbg_wdata <= pwdata;
    end
end

always_ff @(posedge pclk or negedge presetn) begin
    if (~presetn) begin
        dbg_wdata_wr <= 1'b0;
    end
    else if (dbgapb_wr && paddr[11:0] == `DBGAPB_WDATA_WR) begin
        dbg_wdata_wr <= 1'b1;
    end
    else begin
        dbg_wdata_wr <= 1'b0;
    end
end

logic [31:0] prdata_t;

always_comb begin
    prdata_t = 32'b0;
    case (paddr[11:0])
        `DBGAPB_DBG_EN  : prdata_t = {31'b0, dbg_en};
        `DBGAPB_INST    : prdata_t = dbg_inst;
        `DBGAPB_INST_WR : prdata_t = {31'b0, dbg_inst_wr};
        `DBGAPB_WDATA   : prdata_t = dbg_wdata;
        `DBGAPB_WDATA_WR: prdata_t = {31'b0, dbg_wdata_wr};
        `DBGAPB_RDATA   : prdata_t = dbg_rdata;
    endcase
end

always_ff @(posedge pclk or negedge presetn) begin
    if (~presetn) begin
        prdata <= 32'b0;
    end
    else begin
        prdata <= dbg_en ? prdata_t : 32'b0;
    end
end

always_ff @(posedge pclk or negedge presetn) begin
    if (~presetn) begin
        ready_cnt <= 10'b0;
    end
    else if (~penable && psel) begin
        ready_cnt <= nxt_ready_cnt;
    end
    else if (|ready_cnt) begin
        ready_cnt <= ready_cnt - 10'b1;
    end
end

assign pslverr = 1'b0;
// assign pready  = ~|ready_cnt;
assign pready  = 1'b0;

endmodule
