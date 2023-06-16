/* CSR information */
// User Trap Setup
// 0x000 URW ustatus User status register.
// 0x004 URW uie User interrupt-enable register.
// 0x005 URW utvec User trap handler base address.
// User Trap Handling
// 0x040 URW uscratch Scratch register for user trap handlers.
// 0x041 URW uepc User exception program counter.
// 0x042 URW ucause User trap cause.
// 0x043 URW utval User bad address or instruction.
// 0x044 URW uip User interrupt pending.
// Supervisor Trap Setup
// 0x100 SRW sstatus Supervisor status register.
// 0x102 SRW sedeleg Supervisor exception delegation register.
// 0x103 SRW sideleg Supervisor interrupt delegation register.
// 0x104 SRW sie Supervisor interrupt-enable register.
// 0x105 SRW stvec Supervisor trap handler base address.
// Supervisor Trap Handling
// 0x140 SRW sscratch Scratch register for supervisor trap handlers.
// 0x141 SRW sepc Supervisor exception program counter.
// 0x142 SRW scause Supervisor trap cause.
// 0x143 SRW stval Supervisor bad address or instruction.
// 0x144 SRW sip Supervisor interrupt pending
// Machine Trap Setup
// 0x300 MRW mstatus Machine status register.
// 0x301 MRW misa ISA and extensions
// 0x302 MRW medeleg Machine exception delegation register.
// 0x303 MRW mideleg Machine interrupt delegation register.
// 0x304 MRW mie Machine interrupt-enable register.
// 0x305 MRW mtvec Machine trap-handler base address.
// Machine Trap Handling
// 0x340 MRW mscratch Scratch register for machine trap handlers.
// 0x341 MRW mepc Machine exception program counter.
// 0x342 MRW mcause Machine trap cause.
// 0x343 MRW mtval Machine bad address or instruction.
// 0x344 MRW mip Machine interrupt pending.

`include "cpu_define.h"
`include "csr_define.h"

module sru (
    input                           clk,
    input                           clk_free,
    input                           srstn,
    input                           xrstn,
    input                           sleep,
    input                           misaligned,
    output logic [             1:0] prv,
    output logic                    tsr,
    output logic                    tvm,
    output logic                    sum,
    output logic                    mprv,
    output logic [             1:0] mpp,
    output logic                    warm_rst_trigger,

    // IRQ signal
    input                           ext_msip,
    input                           ext_mtip,
    input                           ext_meip,
    input                           ext_seip,
    input                           int_mask,
    output logic                    wakeup,
    output logic                    irq_trigger,
    output logic [       `XLEN-1:0] cause,
    output logic [       `XLEN-1:0] tval,

    // PC control
    output logic [`IM_ADDR_LEN-1:0] trap_vec,
    output logic [`IM_ADDR_LEN-1:0] ret_epc,

    // Trap signal
    input        [`IM_ADDR_LEN-1:0] trap_epc,
    input                           trap_en,
    input        [       `XLEN-1:0] trap_cause,
    input        [       `XLEN-1:0] trap_val,
    input                           sret,
    input                           mret,
    output logic                    eret_en,

    // Extension flag
    output logic [             1:0] misa_mxl,
    output logic                    misa_a_ext,
    output logic                    misa_c_ext,
    output logic                    misa_m_ext,
    
    // CSR interface
    input                           csr_wr,
    input        [            11:0] csr_waddr,
    input        [            11:0] csr_raddr,
    // input        [       `XLEN-1:0] csr_wdata,
    input        [       `XLEN-1:0] csr_sdata,
    input        [       `XLEN-1:0] csr_cdata,
    output logic [       `XLEN-1:0] csr_rdata,
    output logic                    csr_hit
);

logic                          trap_m_mode;
logic                          trap_s_mode;
logic                          ints_m_mode_pre;
logic                          ints_s_mode_pre;
logic                          ints_m_mode;
logic                          ints_s_mode;
logic [      `IM_ADDR_LEN-1:0] vec_offset;
logic                          msip_d1;
logic                          mtip_d1;
logic                          meip_d1;
logic                          seip_d1;
logic                          seip_d2;

logic [             `XLEN-1:0] sstatus;
logic [                  30:0] sstatus_low;
// logic [       `XLEN-1:0] sedeleg;
// logic [       `XLEN-1:0] sideleg;
logic [             `XLEN-1:0] sie;
logic [             `XLEN-1:0] sip;
logic [             `XLEN-1:0] stvec;
logic [             `XLEN-1:0] sscratch;
logic [             `XLEN-1:0] sepc;
logic [             `XLEN-1:0] scause;
logic [             `XLEN-1:0] stval;
logic [             `XLEN-1:0] mstatus;
logic [                  30:0] mstatus_low;
logic [             `XLEN-1:0] misa;
logic [             `XLEN-1:0] medeleg;
logic [             `XLEN-1:0] mideleg;
logic [             `XLEN-1:0] mie;
logic [             `XLEN-1:0] mtvec;
logic [             `XLEN-1:0] mscratch;
logic [             `XLEN-1:0] mepc;
logic [             `XLEN-1:0] mcause;
logic [             `XLEN-1:0] mtval;
logic [             `XLEN-1:0] mip;

logic                          mstatus_sie;
logic                          mstatus_mie;
logic                          mstatus_spie;
logic                          mstatus_mpie;
logic                          mstatus_spp;
logic [                   1:0] mstatus_mpp;
logic [                   1:0] mstatus_fs;
logic [                   1:0] mstatus_xs;
logic                          mstatus_mprv;
logic                          mstatus_sum;
logic                          mstatus_mxr;
logic                          mstatus_tvm;
logic                          mstatus_tw;
logic                          mstatus_tsr;
logic [                   1:0] mstatus_uxl;
logic [                   1:0] mstatus_sxl;
logic                          mstatus_sd;

logic                          medeleg_imisalign;
logic                          medeleg_bp;
logic                          medeleg_uecall;
logic                          medeleg_instpgfault;
logic                          medeleg_ldpgfault;
logic                          medeleg_stpgfault;

logic                          mideleg_ssip;
logic                          mideleg_stip;
logic                          mideleg_seip;

logic                          mie_ssie;
logic                          mie_msie;
logic                          mie_stie;
logic                          mie_mtie;
logic                          mie_seie;
logic                          mie_meie;

logic                          mip_ssip;
logic                          mip_msip;
logic                          mip_stip;
logic                          mip_mtip;
logic                          mip_seip;
logic                          mip_seip_sw;
logic                          mip_meip;

logic [                  25:0] misa_ext;
logic [                   1:0] nxt_misa_mxl;


logic [`MCAUSE_CODE_WIDTH-1:0] mcause_code;
logic                          mcause_int;

logic [`MCAUSE_CODE_WIDTH-1:0] scause_code;
logic                          scause_int;

logic [             `XLEN-1:0] ints_en;
logic [             `XLEN-1:0] ints_m_en;
logic [             `XLEN-1:0] ints_s_en;

assign ints_en     = mie & mip;
assign ints_m_en   = ints_en & ~mideleg;
assign ints_s_en   = ints_en &  mideleg;

assign wakeup      = |ints_en;
assign irq_trigger = ~trap_en && (ints_m_mode || ints_s_mode);
assign ret_epc     = sret ? sepc : mepc;
assign eret_en     = ~trap_en && (sret || mret);

assign trap_m_mode     = ~trap_s_mode;
assign trap_s_mode     = prv <= `PRV_S && |(medeleg & (`XLEN'b1 << trap_cause[`XLEN-2:0]));
assign ints_m_mode_pre = ((prv == `PRV_M && mstatus_mie) || prv < `PRV_M) && |ints_m_en;
assign ints_s_mode_pre = ((prv == `PRV_S && mstatus_sie) || prv < `PRV_S) && |ints_s_en && !ints_m_mode_pre;
assign ints_m_mode     = ints_m_mode_pre && ~int_mask;
assign ints_s_mode     = ints_s_mode_pre && ~int_mask;

assign trap_vec    = ((trap_en ?  (trap_m_mode     ? mtvec : stvec):
                                 ((ints_m_mode_pre ? mtvec : stvec) + vec_offset)) &
                     ~`IM_ADDR_LEN'h3);

assign vec_offset  = /*trap_en     ? `IM_ADDR_LEN'd0:*/
                     ints_s_mode_pre ?     ints_s_en[`MIP_MEIP_BIT]      ? (`IM_ADDR_LEN'd`MIP_MEIP_BIT << 2) & {`IM_ADDR_LEN{stvec[0]}}:
                                           ints_s_en[`MIP_MSIP_BIT]      ? (`IM_ADDR_LEN'd`MIP_MSIP_BIT << 2) & {`IM_ADDR_LEN{stvec[0]}}:
                                           ints_s_en[`MIP_MTIP_BIT]      ? (`IM_ADDR_LEN'd`MIP_MTIP_BIT << 2) & {`IM_ADDR_LEN{stvec[0]}}:
                                           ints_s_en[`MIP_SEIP_BIT]      ? (`IM_ADDR_LEN'd`MIP_SEIP_BIT << 2) & {`IM_ADDR_LEN{stvec[0]}}:
                                           ints_s_en[`MIP_SSIP_BIT]      ? (`IM_ADDR_LEN'd`MIP_SSIP_BIT << 2) & {`IM_ADDR_LEN{stvec[0]}}:
                                           /*ints_s_en[`MIP_STIP_BIT] ? */ (`IM_ADDR_LEN'd`MIP_STIP_BIT << 2) & {`IM_ADDR_LEN{stvec[0]}}:
                     /*ints_m_mode_pre ?*/ ints_m_en[`MIP_MEIP_BIT]      ? (`IM_ADDR_LEN'd`MIP_MEIP_BIT << 2) & {`IM_ADDR_LEN{mtvec[0]}}:
                                           ints_m_en[`MIP_MSIP_BIT]      ? (`IM_ADDR_LEN'd`MIP_MSIP_BIT << 2) & {`IM_ADDR_LEN{mtvec[0]}}:
                                           ints_m_en[`MIP_MTIP_BIT]      ? (`IM_ADDR_LEN'd`MIP_MTIP_BIT << 2) & {`IM_ADDR_LEN{mtvec[0]}}:
                                           ints_m_en[`MIP_SEIP_BIT]      ? (`IM_ADDR_LEN'd`MIP_SEIP_BIT << 2) & {`IM_ADDR_LEN{mtvec[0]}}:
                                           ints_m_en[`MIP_SSIP_BIT]      ? (`IM_ADDR_LEN'd`MIP_SSIP_BIT << 2) & {`IM_ADDR_LEN{mtvec[0]}}:
                                           /*ints_m_en[`MIP_STIP_BIT] ? */ (`IM_ADDR_LEN'd`MIP_STIP_BIT << 2) & {`IM_ADDR_LEN{mtvec[0]}};
                                           /*`IM_ADDR_LEN'd0;*/


assign cause       = trap_en     ? trap_cause : 
                     ints_s_mode ? ints_s_en[`MIP_MEIP_BIT]      ? (`XLEN'd`MIP_MEIP_BIT | (`XLEN'd1 << 31)):
                                   ints_s_en[`MIP_MSIP_BIT]      ? (`XLEN'd`MIP_MSIP_BIT | (`XLEN'd1 << 31)):
                                   ints_s_en[`MIP_MTIP_BIT]      ? (`XLEN'd`MIP_MTIP_BIT | (`XLEN'd1 << 31)):
                                   ints_s_en[`MIP_SEIP_BIT]      ? (`XLEN'd`MIP_SEIP_BIT | (`XLEN'd1 << 31)):
                                   ints_s_en[`MIP_SSIP_BIT]      ? (`XLEN'd`MIP_SSIP_BIT | (`XLEN'd1 << 31)):
                                   /*ints_s_en[`MIP_STIP_BIT] ? */ (`XLEN'd`MIP_STIP_BIT | (`XLEN'd1 << 31)):
                     ints_m_mode ? ints_m_en[`MIP_MEIP_BIT]      ? (`XLEN'd`MIP_MEIP_BIT | (`XLEN'd1 << 31)):
                                   ints_m_en[`MIP_MSIP_BIT]      ? (`XLEN'd`MIP_MSIP_BIT | (`XLEN'd1 << 31)):
                                   ints_m_en[`MIP_MTIP_BIT]      ? (`XLEN'd`MIP_MTIP_BIT | (`XLEN'd1 << 31)):
                                   ints_m_en[`MIP_SEIP_BIT]      ? (`XLEN'd`MIP_SEIP_BIT | (`XLEN'd1 << 31)):
                                   ints_m_en[`MIP_SSIP_BIT]      ? (`XLEN'd`MIP_SSIP_BIT | (`XLEN'd1 << 31)):
                                   /*ints_m_en[`MIP_STIP_BIT] ? */ (`XLEN'd`MIP_STIP_BIT | (`XLEN'd1 << 31)):
                                   `XLEN'd0;

assign tval         = trap_en ? trap_val : `XLEN'd0;

always_ff @(posedge clk or negedge srstn) begin
    if (~srstn) prv <= `PRV_M;
    else if (trap_en) begin
        if (trap_s_mode) begin
            prv <= `PRV_S;
        end
        else begin
            prv <= `PRV_M;
        end
    end
    else if (ints_m_mode) begin
        prv <= `PRV_M;
    end
    else if (ints_s_mode) begin
        prv <= `PRV_S;
    end
    else if (sret) begin
        prv <= {1'b0, mstatus_spp};
    end
    else if (mret) begin
        prv <= mstatus_mpp;
    end
end

always_ff @(posedge clk or negedge srstn) begin
    if (~srstn) 
        stvec <= `XLEN'b0;
    else if (csr_wr && csr_waddr == `CSR_STVEC_ADDR)
        stvec <= `CSR_WDATA(stvec, `XLEN-1:0) & ~`XLEN'h2;
end

always_ff @(posedge clk or negedge srstn) begin
    if (~srstn)
        sscratch <= `XLEN'b0;
    else if (csr_wr && csr_waddr == `CSR_SSCRATCH_ADDR)
        sscratch <= `CSR_WDATA(sscratch, `XLEN-1:0);
end

always_ff @(posedge clk or negedge srstn) begin
    if (~srstn) begin
        sepc <= `XLEN'b0;
    end
    else if (trap_en && trap_s_mode) begin
        sepc <= trap_epc;
    end
    else if (ints_s_mode) begin
        sepc <= trap_epc;
    end
    else if (csr_wr && csr_waddr == `CSR_SEPC_ADDR) begin
        sepc <= `CSR_WDATA(sepc, `XLEN-1:0) & ~`XLEN'h1;
    end
end

`ifdef RV32
assign scause = {scause_int, {`XLEN-`MCAUSE_CODE_WIDTH-1{1'b0}}, scause_code};
`else
assign scause = misa_mxl == 2'h1 ? {32'b0, scause_int, {   32-`MCAUSE_CODE_WIDTH-1{1'b0}}, scause_code}:
                misa_mxl == 2'h2 ? {       scause_int, {`XLEN-`MCAUSE_CODE_WIDTH-1{1'b0}}, scause_code}:
                                   `XLEN'b0;
`endif

always_ff @(posedge clk or negedge srstn) begin
    if (~srstn) begin
        scause_int  <= 1'b0;
        scause_code <= `MCAUSE_CODE_WIDTH'b0;
    end
    else if (trap_en && trap_s_mode) begin
        scause_int  <= trap_cause[`XLEN-1];
        scause_code <= trap_cause[0+:`MCAUSE_CODE_WIDTH];
    end
    else if (ints_s_mode) begin
        scause_int  <= 1'b1;
        scause_code <= ints_s_en[`MIP_MEIP_BIT] ? `MCAUSE_CODE_WIDTH'd`MIP_MEIP_BIT:
                       ints_s_en[`MIP_MSIP_BIT] ? `MCAUSE_CODE_WIDTH'd`MIP_MSIP_BIT:
                       ints_s_en[`MIP_MTIP_BIT] ? `MCAUSE_CODE_WIDTH'd`MIP_MTIP_BIT:
                       ints_s_en[`MIP_SEIP_BIT] ? `MCAUSE_CODE_WIDTH'd`MIP_SEIP_BIT:
                       ints_s_en[`MIP_SSIP_BIT] ? `MCAUSE_CODE_WIDTH'd`MIP_SSIP_BIT:
                       ints_s_en[`MIP_STIP_BIT] ? `MCAUSE_CODE_WIDTH'd`MIP_STIP_BIT:
                                                  `MCAUSE_CODE_WIDTH'b1;
    end
    else if (csr_wr && csr_waddr == `CSR_SCAUSE_ADDR) begin
        scause_int  <= misa_mxl == 2'h1 ? `CSR_WDATA(scause_int, 31):
                                          `CSR_WDATA(scause_int, `XLEN-1);
        scause_code <= `CSR_WDATA(scause_code, 0+:`MCAUSE_CODE_WIDTH);
    end
end

always_ff @(posedge clk or negedge srstn) begin
    if (~srstn) begin
        stval <= `XLEN'b0;
    end
    else if (trap_en && trap_s_mode) begin
        stval <= trap_val;
    end
    else if (ints_s_mode) begin
        stval <= `XLEN'b0;
    end
    else if (csr_wr && csr_waddr == `CSR_STVAL_ADDR)begin
        stval <= `CSR_WDATA(stval, `XLEN-1: 0);
    end
end

assign mstatus_low = {mstatus_sd, 8'b0, mstatus_tsr, /*mstatus_tw*/1'b0, mstatus_tvm,
                      mstatus_mxr, mstatus_sum, mstatus_mprv, mstatus_xs,
                      mstatus_fs, mstatus_mpp, 2'b0, mstatus_spp,
                      mstatus_mpie, 1'b0, mstatus_spie, 1'b0,
                      mstatus_mie, 1'b0, mstatus_sie, 1'b0};

assign sstatus_low = {1'b0, 8'b0, 1'b0, 1'b0, 1'b0,
                      mstatus_mxr, mstatus_sum, 1'b0, mstatus_xs,
                      mstatus_fs, 2'b0, 2'b0, mstatus_spp,
                      1'b0, 1'b0, mstatus_spie, 1'b0,
                      1'b0, 1'b0, mstatus_sie, 1'b0};

`ifdef RV32
assign mstatus     = {mstatus_sd, mstatus_low};
assign sstatus     = {mstatus_sd, sstatus_low};
`else
assign mstatus     = misa_mxl == 2'h1 ? {{`XLEN-32{1'b0}}, mstatus_sd, mstatus_low}:
                     misa_mxl == 2'h2 ? {mstatus_sd, {`XLEN-37{1'b0}}, mstatus_sxl, mstatus_uxl, 1'b0, mstatus_low}:
                                        `XLEN'b0;
assign sstatus     = misa_mxl == 2'h1 ? {{`XLEN-32{1'b0}}, mstatus_sd, sstatus_low}:
                     misa_mxl == 2'h2 ? {mstatus_sd, {`XLEN-37{1'b0}},        2'b0, mstatus_uxl, 1'b0, sstatus_low}:
                                        `XLEN'b0;
`endif

assign tvm     = mstatus_tvm;
assign tsr     = mstatus_tsr;
assign sum     = mstatus_sum;
assign mprv    = mstatus_mprv;
assign mpp     = mstatus_mpp;
assign mstatus_sd   = (|mstatus_fs) | (|mstatus_xs);

always_ff @(posedge clk or negedge srstn) begin
    if (~srstn) begin
        mstatus_sie  <= 1'b0;
        mstatus_mie  <= 1'b0;
        mstatus_spie <= 1'b0;
        mstatus_mpie <= 1'b0;
        mstatus_spp  <= 1'b0;
        mstatus_mpp  <= 2'b0;
        mstatus_fs   <= 2'b0;
        mstatus_xs   <= 2'b0;
        mstatus_mprv <= 1'b0;
        mstatus_sum  <= 1'b0;
        mstatus_mxr  <= 1'b0;
        mstatus_tvm  <= 1'b0;
        mstatus_tw   <= 1'b0;
        mstatus_tsr  <= 1'b0;
        mstatus_uxl  <= 2'h2;
        mstatus_sxl  <= 2'h2;
    end
    else if (trap_en) begin
        if (trap_s_mode) begin
            mstatus_spp  <= prv[0];
            mstatus_spie <= mstatus_sie;
            mstatus_sie  <= 1'b0;
        end
        else begin
            mstatus_mpp  <= prv;
            mstatus_mpie <= mstatus_mie;
            mstatus_mie  <= 1'b0;
        end
    end
    else if (ints_m_mode) begin
        mstatus_mpp  <= prv;
        mstatus_mpie <= mstatus_mie;
        mstatus_mie  <= 1'b0;
    end
    else if (ints_s_mode) begin
        mstatus_spp  <= prv[0];
        mstatus_spie <= mstatus_sie;
        mstatus_sie  <= 1'b0;
    end
    else if (sret) begin
        mstatus_spp  <= 1'b0;
        mstatus_sie  <= mstatus_spie;
        mstatus_spie <= 1'b1;
    end
    else if (mret) begin
        mstatus_mpp  <= `PRV_U;
        mstatus_mie  <= mstatus_mpie;
        mstatus_mpie <= 1'b1;
    end
    else if (csr_wr && csr_waddr == `CSR_SSTATUS_ADDR) begin
        mstatus_sie  <= `CSR_WDATA(mstatus_sie , `MSTATUS_SIE_BIT );
        mstatus_spie <= `CSR_WDATA(mstatus_spie, `MSTATUS_SPIE_BIT);
        mstatus_spp  <= `CSR_WDATA(mstatus_spp , `MSTATUS_SPP_BIT );
        mstatus_fs   <= `CSR_WDATA(mstatus_fs  , `MSTATUS_FS_BIT  );
        // mstatus_xs   <= `CSR_WDATA(mstatus_xs  , `MSTATUS_XS_BIT );
        mstatus_sum  <= `CSR_WDATA(mstatus_sum , `MSTATUS_SUM_BIT );
        mstatus_mxr  <= `CSR_WDATA(mstatus_mxr , `MSTATUS_MXR_BIT );
    end
    else if (csr_wr && csr_waddr == `CSR_MSTATUS_ADDR) begin
        mstatus_sie  <= `CSR_WDATA(mstatus_sie , `MSTATUS_SIE_BIT );
        mstatus_mie  <= `CSR_WDATA(mstatus_mie , `MSTATUS_MIE_BIT );
        mstatus_spie <= `CSR_WDATA(mstatus_spie, `MSTATUS_SPIE_BIT);
        mstatus_mpie <= `CSR_WDATA(mstatus_mpie, `MSTATUS_MPIE_BIT);
        mstatus_spp  <= `CSR_WDATA(mstatus_spp , `MSTATUS_SPP_BIT );
        mstatus_mpp  <= `CSR_WDATA(mstatus_mpp , `MSTATUS_MPP_BIT );
        mstatus_fs   <= `CSR_WDATA(mstatus_fs  , `MSTATUS_FS_BIT  );
        mstatus_xs   <= `CSR_WDATA(mstatus_xs  , `MSTATUS_XS_BIT  );
        mstatus_mprv <= `CSR_WDATA(mstatus_mprv, `MSTATUS_MPRV_BIT);
        mstatus_sum  <= `CSR_WDATA(mstatus_sum , `MSTATUS_SUM_BIT );
        mstatus_mxr  <= `CSR_WDATA(mstatus_mxr , `MSTATUS_MXR_BIT );
        mstatus_tvm  <= `CSR_WDATA(mstatus_tvm , `MSTATUS_TVM_BIT );
        mstatus_tw   <= `CSR_WDATA(mstatus_tw  , `MSTATUS_TW_BIT  );
        mstatus_tsr  <= `CSR_WDATA(mstatus_tsr , `MSTATUS_TSR_BIT );
    end
end

assign misa = misa_mxl == 2'h1 ? {{`XLEN-32{1'b0}}, misa_mxl, 4'b0, misa_ext}:
              misa_mxl == 2'h2 ? {misa_mxl, {`XLEN-28{1'b0}}, misa_ext}:
                                 `XLEN'b0;
assign misa_ext = ({25'b0,       1'b1} << ("i" - "a"))|
                  ({25'b0,       1'b1} << ("e" - "a"))|
                  ({25'b0,       1'b1} << ("s" - "a"))|
                  ({25'b0,       1'b1} << ("u" - "a"))|
                  ({25'b0, misa_a_ext} << ("a" - "a"))|
                  ({25'b0, misa_c_ext} << ("c" - "a"))|
                  ({25'b0, misa_m_ext} << ("m" - "a"));

assign warm_rst_trigger = 
`ifdef RV32
                          1'b0;
`else
                          csr_wr && csr_waddr == `CSR_MISA_ADDR && 
                          ((misa_mxl == 2'h1 && `CSR_WDATA(misa_mxl, 31:30) != 2'h1)||
                           (misa_mxl == 2'h2 && `CSR_WDATA(misa_mxl, 63:62) != 2'h2));
`endif

assign nxt_misa_mxl = ({2{misa_mxl == 2'h1}} & `CSR_WDATA(misa_mxl, 31:30))|
                      ({2{misa_mxl == 2'h2}} & `CSR_WDATA(misa_mxl, 63:62));

always_ff @(posedge clk or negedge xrstn) begin
    if (~xrstn) begin
`ifdef RV32
        misa_mxl   <= 2'h1;
`else
        misa_mxl   <= 2'h2;
`endif
        misa_a_ext <= 1'b1;
        misa_c_ext <= 1'b1;
        misa_m_ext <= 1'b1;
    end
    else if (csr_wr && csr_waddr == `CSR_MISA_ADDR) begin
`ifndef RV32
        misa_mxl   <= nxt_misa_mxl == 2'h1 ? 2'h1:
                      nxt_misa_mxl == 2'h2 ? 2'h2:
                                             misa_mxl;
`endif
        misa_c_ext <= misaligned ? misa_c_ext : `CSR_WDATA(misa_c_ext, "c" - "a");
        misa_m_ext <= `CSR_WDATA(misa_m_ext, "m" - "a");
    end
end

assign medeleg = {{(`XLEN-16){1'b0}}, medeleg_stpgfault, 1'b0, medeleg_ldpgfault,
                  medeleg_instpgfault, 1'b0, 1'b0, 1'b0, medeleg_uecall, 1'b0, 1'b0,
                  1'b0, 1'b0, medeleg_bp, 1'b0, 1'b0, medeleg_imisalign};

always_ff @(posedge clk or negedge srstn) begin
    if (~srstn) begin
        medeleg_imisalign   <= 1'b0;
        medeleg_bp          <= 1'b0;
        medeleg_uecall      <= 1'b0;
        medeleg_instpgfault <= 1'b0;
        medeleg_ldpgfault   <= 1'b0;
        medeleg_stpgfault   <= 1'b0;
    end
    else if (csr_wr && csr_waddr == `CSR_MEDELEG_ADDR) begin
        medeleg_imisalign   <= `CSR_WDATA(medeleg_imisalign  , `CAUSE_MISALIGNED_FETCH      );
        medeleg_bp          <= `CSR_WDATA(medeleg_bp         , `CAUSE_BREAKPOINT            );
        medeleg_uecall      <= `CSR_WDATA(medeleg_uecall     , `CAUSE_USER_ECALL            );
        medeleg_instpgfault <= `CSR_WDATA(medeleg_instpgfault, `CAUSE_INSTRUCTION_PAGE_FAULT);
        medeleg_ldpgfault   <= `CSR_WDATA(medeleg_ldpgfault  , `CAUSE_LOAD_PAGE_FAULT       );
        medeleg_stpgfault   <= `CSR_WDATA(medeleg_stpgfault  , `CAUSE_STORE_PAGE_FAULT      );
    end
end

assign mideleg = {{(`XLEN-10){1'b0}}, mideleg_seip, 3'b0, mideleg_stip, 3'b0, mideleg_ssip, 1'b0};

always_ff @(posedge clk or negedge srstn) begin
    if (~srstn) begin
        mideleg_ssip <= 1'b0;
        mideleg_stip <= 1'b0;
        mideleg_seip <= 1'b0;
    end
    else if (csr_wr && csr_waddr == `CSR_MIDELEG_ADDR) begin
        mideleg_ssip <= `CSR_WDATA(mideleg_ssip, 1);
        mideleg_stip <= `CSR_WDATA(mideleg_stip, 5);
        mideleg_seip <= `CSR_WDATA(mideleg_seip, 9);
    end
end

assign mie = {{(`XLEN-12){1'b0}}, mie_meie, 1'b0, mie_seie, 1'b0, mie_mtie, 1'b0,
              mie_stie, 1'b0, mie_msie, 1'b0, mie_ssie, 1'b0};

assign sie = {{(`XLEN-10){1'b0}}, mie_seie, 3'b0, mie_stie, 3'b0, mie_ssie, 1'b0};

always_ff @(posedge clk or negedge srstn) begin
    if (~srstn) begin
        mie_ssie <= 1'b0;
        mie_msie <= 1'b0;
        mie_stie <= 1'b0;
        mie_mtie <= 1'b0;
        mie_seie <= 1'b0;
        mie_meie <= 1'b0;
    end
    else if (csr_wr && csr_waddr == `CSR_SIE_ADDR) begin
        mie_ssie <= `CSR_WDATA(mie_ssie, 1);
        mie_stie <= `CSR_WDATA(mie_stie, 5);
        mie_seie <= `CSR_WDATA(mie_seie, 9);
    end
    else if (csr_wr && csr_waddr == `CSR_MIE_ADDR) begin
        mie_ssie <= `CSR_WDATA(mie_ssie,  1);
        mie_msie <= `CSR_WDATA(mie_msie,  3);
        mie_stie <= `CSR_WDATA(mie_stie,  5);
        mie_mtie <= `CSR_WDATA(mie_mtie,  7);
        mie_seie <= `CSR_WDATA(mie_seie,  9);
        mie_meie <= `CSR_WDATA(mie_meie, 11);
    end
end

always_ff @(posedge clk or negedge srstn) begin
    if (~srstn)
        mtvec <= `XLEN'b0;
    else if (csr_wr && csr_waddr == `CSR_MTVEC_ADDR)
        mtvec <= `CSR_WDATA(mtvec, `XLEN-1:0) & ~`XLEN'h2;
end

always_ff @(posedge clk or negedge srstn) begin
    if (~srstn)
        mscratch <= `XLEN'b0;
    else if (csr_wr && csr_waddr == `CSR_MSCRATCH_ADDR)
        mscratch <= `CSR_WDATA(mscratch, `XLEN-1:0);
end

always_ff @(posedge clk or negedge srstn) begin
    if (~srstn) begin
        mepc <= `XLEN'b0;
    end
    else if (trap_en && ~trap_s_mode) begin
        mepc <= trap_epc;
    end
    else if (ints_m_mode) begin
        mepc <= trap_epc;
    end
    else if (csr_wr && csr_waddr == `CSR_MEPC_ADDR) begin
        mepc <= `CSR_WDATA(mepc, `XLEN-1:0) & ~`XLEN'h1;
    end
end

`ifdef RV32
assign mcause = {mcause_int, {`XLEN-`MCAUSE_CODE_WIDTH-1{1'b0}}, mcause_code};
`else
assign mcause = misa_mxl == 2'h1 ? {32'b0, mcause_int, {   32-`MCAUSE_CODE_WIDTH-1{1'b0}}, mcause_code}:
                misa_mxl == 2'h2 ? {       mcause_int, {`XLEN-`MCAUSE_CODE_WIDTH-1{1'b0}}, mcause_code}:
                                   `XLEN'b0;
`endif

always_ff @(posedge clk or negedge srstn) begin
    if (~srstn) begin
        mcause_int  <= 1'b0;
        mcause_code <= `MCAUSE_CODE_WIDTH'b0;
    end
    else if (trap_en && ~trap_s_mode) begin
        mcause_int  <= trap_cause[`XLEN-1];
        mcause_code <= trap_cause[0+:`MCAUSE_CODE_WIDTH];
    end
    else if (ints_m_mode) begin
        mcause_int  <= 1'b1;
        mcause_code <= ints_m_en[`MIP_MEIP_BIT] ? `MCAUSE_CODE_WIDTH'd`MIP_MEIP_BIT:
                       ints_m_en[`MIP_MSIP_BIT] ? `MCAUSE_CODE_WIDTH'd`MIP_MSIP_BIT:
                       ints_m_en[`MIP_MTIP_BIT] ? `MCAUSE_CODE_WIDTH'd`MIP_MTIP_BIT:
                       ints_m_en[`MIP_SEIP_BIT] ? `MCAUSE_CODE_WIDTH'd`MIP_SEIP_BIT:
                       ints_m_en[`MIP_SSIP_BIT] ? `MCAUSE_CODE_WIDTH'd`MIP_SSIP_BIT:
                       ints_m_en[`MIP_STIP_BIT] ? `MCAUSE_CODE_WIDTH'd`MIP_STIP_BIT:
                                                  `MCAUSE_CODE_WIDTH'd1;
    end
    else if (csr_wr && csr_waddr == `CSR_MCAUSE_ADDR) begin
        mcause_int  <= misa_mxl == 2'h1 ? `CSR_WDATA(mcause_int, 31):
                                          `CSR_WDATA(mcause_int, `XLEN-1);
        mcause_code <= `CSR_WDATA(mcause_code, 0+:`MCAUSE_CODE_WIDTH);
    end
end

always_ff @(posedge clk or negedge srstn) begin
    if (~srstn) begin
        mtval <= `XLEN'b0;
    end
    else if (trap_en && ~trap_s_mode) begin
        mtval <= trap_val;
    end
    else if (ints_m_mode) begin
        mtval <= `XLEN'b0;
    end
    else if (csr_wr && csr_waddr == `CSR_MTVAL_ADDR) begin
        mtval <= `CSR_WDATA(mtval, `XLEN-1:0);
    end
end

assign mip = {{(`XLEN-12){1'b0}}, mip_meip, 1'b0, mip_seip, 1'b0, mip_mtip, 1'b0,
              mip_stip, 1'b0, mip_msip, 1'b0, mip_ssip, 1'b0};

assign sip = {{(`XLEN-10){1'b0}}, mip_seip, 3'b0, mip_stip, 3'b0, mip_ssip, 1'b0};

assign mip_seip = seip_d1 | mip_seip_sw;

always_ff @(posedge clk_free or negedge srstn) begin
    if (~srstn) begin
        msip_d1  <= 1'b0;
        mtip_d1  <= 1'b0;
        meip_d1  <= 1'b0;
        seip_d1  <= 1'b0;
        seip_d2  <= 1'b0;
        mip_msip <= 1'b0;
        mip_mtip <= 1'b0;
        mip_meip <= 1'b0;
    end
    else begin
        msip_d1  <= ext_msip;
        mtip_d1  <= ext_mtip;
        meip_d1  <= ext_meip;
        seip_d1  <= ext_seip;
        seip_d2  <= seip_d1;
        mip_msip <= msip_d1;
        mip_mtip <= mtip_d1;
        mip_meip <= meip_d1;
    end
end

always_ff @(posedge clk or negedge srstn) begin
    if (~srstn) begin
        mip_ssip    <= 1'b0;
        mip_stip    <= 1'b0;
        mip_seip_sw <= 1'b0;
    end
    else if (~sleep) begin
        if (csr_wr && csr_waddr == `CSR_SIP_ADDR)  begin
            mip_ssip    <= (mip_ssip    | csr_sdata[1]) & ~csr_cdata[1];
            mip_seip_sw <= (mip_seip_sw | csr_sdata[9]) & ~csr_cdata[9];
        end
        else if (csr_wr && csr_waddr == `CSR_MIP_ADDR) begin
            mip_ssip    <= (mip_ssip    | csr_sdata[1]) & ~csr_cdata[1];
            mip_stip    <= (mip_stip    | csr_sdata[5]) & ~csr_cdata[5];
            mip_seip_sw <= (mip_seip_sw | csr_sdata[9]) & ~csr_cdata[9];
        end
    end
end

always_comb begin
    csr_rdata = `XLEN'b0;
    csr_hit   = 1'b1;
    case (csr_raddr) 
        `CSR_SSTATUS_ADDR   : csr_rdata = sstatus;
        `CSR_SEDELEG_ADDR   : csr_rdata = `XLEN'b0;
        `CSR_SIDELEG_ADDR   : csr_rdata = `XLEN'b0;
        `CSR_SIE_ADDR       : csr_rdata = sie & mideleg;
        `CSR_STVEC_ADDR     : csr_rdata = stvec;
        `CSR_SSCRATCH_ADDR  : csr_rdata = sscratch;
        `CSR_SEPC_ADDR      : csr_rdata = sepc;
        `CSR_SCAUSE_ADDR    : csr_rdata = scause;
        `CSR_STVAL_ADDR     : csr_rdata = stval;
        `CSR_SIP_ADDR       : csr_rdata = sip & mideleg;
        `CSR_MSTATUS_ADDR   : csr_rdata = mstatus;
        `CSR_MISA_ADDR      : csr_rdata = misa;
        `CSR_MEDELEG_ADDR   : csr_rdata = medeleg;
        `CSR_MIDELEG_ADDR   : csr_rdata = mideleg;
        `CSR_MIE_ADDR       : csr_rdata = mie;
        `CSR_MTVEC_ADDR     : csr_rdata = mtvec;
        `CSR_MSCRATCH_ADDR  : csr_rdata = mscratch;
        `CSR_MEPC_ADDR      : csr_rdata = mepc;
        `CSR_MCAUSE_ADDR    : csr_rdata = mcause;
        `CSR_MTVAL_ADDR     : csr_rdata = mtval;
        `CSR_MIP_ADDR       : csr_rdata = mip;
        default             : csr_hit   = 1'b0;
    endcase
end

endmodule
