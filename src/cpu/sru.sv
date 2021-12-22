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
// 0x106 SRW scounteren Supervisor counter enable.
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
// 0x306 MRW mcounteren Machine counter enable.
// Machine Trap Handling
// 0x340 MRW mscratch Scratch register for machine trap handlers.
// 0x341 MRW mepc Machine exception program counter.
// 0x342 MRW mcause Machine trap cause.
// 0x343 MRW mtval Machine bad address or instruction.
// 0x344 MRW mip Machine interrupt pending.

`include "cpu_define.h"

module sru (
    input                           clk,
    input                           clk_free,
    input                           rstn,
    input                           sleep,
    input                           misaligned,
    output logic [             1:0] prv,
    output logic                    tsr,
    output logic                    tvm,
    output logic                    sum,
    output logic                    mprv,
    output logic [             1:0] mpp,

    // IRQ signal
    input                           ext_msip,
    input                           ext_mtip,
    input                           ext_meip,
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
    input        [       `XLEN-1:0] csr_wdata,
    output logic [       `XLEN-1:0] csr_rdata
);

logic                    trap_m_mode;
logic                    trap_s_mode;
logic                    ints_m_mode;
logic                    ints_s_mode;
logic [`IM_ADDR_LEN-1:0] vec_offset;
logic                    msip_d1;
logic                    mtip_d1;
logic                    meip_d1;

logic [       `XLEN-1:0] sstatus;
// logic [       `XLEN-1:0] sedeleg;
// logic [       `XLEN-1:0] sideleg;
logic [       `XLEN-1:0] sie;
logic [       `XLEN-1:0] sip;
logic [       `XLEN-1:0] stvec;
logic [       `XLEN-1:0] sscratch;
logic [       `XLEN-1:0] sepc;
logic [       `XLEN-1:0] scause;
logic [       `XLEN-1:0] stval;
logic [       `XLEN-1:0] mstatus;
logic [       `XLEN-1:0] misa;
logic [       `XLEN-1:0] medeleg;
logic [       `XLEN-1:0] mideleg;
logic [       `XLEN-1:0] mie;
logic [       `XLEN-1:0] mtvec;
logic [       `XLEN-1:0] mscratch;
logic [       `XLEN-1:0] mepc;
logic [       `XLEN-1:0] mcause;
logic [       `XLEN-1:0] mtval;
logic [       `XLEN-1:0] mip;

logic                    mstatus_sie;
logic                    mstatus_mie;
logic                    mstatus_spie;
logic                    mstatus_mpie;
logic                    mstatus_spp;
logic [             1:0] mstatus_mpp;
logic [             1:0] mstatus_fs;
logic [             1:0] mstatus_xs;
logic                    mstatus_mprv;
logic                    mstatus_sum;
logic                    mstatus_mxr;
logic                    mstatus_tvm;
logic                    mstatus_tw;
logic                    mstatus_tsr;
logic [             1:0] mstatus_uxl;
logic [             1:0] mstatus_sxl;
logic                    mstatus_sd;

logic                    medeleg_imisalign;
logic                    medeleg_bp;
logic                    medeleg_uecall;
logic                    medeleg_instpgfault;
logic                    medeleg_ldpgfault;
logic                    medeleg_stpgfault;

logic                    mideleg_ssip;
logic                    mideleg_stip;
logic                    mideleg_seip;

logic                    mie_ssie;
logic                    mie_msie;
logic                    mie_stie;
logic                    mie_mtie;
logic                    mie_seie;
logic                    mie_meie;

logic                    mip_ssip;
logic                    mip_msip;
logic                    mip_stip;
logic                    mip_mtip;
logic                    mip_seip;
logic                    mip_meip;

logic [            25:0] misa_ext;


logic [       `XLEN-2:0] mcause_code;
logic                    mcause_int;

logic [       `XLEN-2:0] scause_code;
logic                    scause_int;

logic [       `XLEN-1:0] ints_en;
logic [       `XLEN-1:0] ints_m_en;
logic [       `XLEN-1:0] ints_s_en;

assign ints_en     = mie & mip;
assign ints_m_en   = mie & mip & ~mideleg;
assign ints_s_en   = mie & mip &  mideleg;

assign wakeup      = |ints_en;
assign irq_trigger = ~trap_en && (ints_m_mode || ints_s_mode);
assign ret_epc     = sret ? sepc : mepc;
assign eret_en     = ~trap_en && (sret || mret);

assign trap_m_mode = ~trap_s_mode;
assign trap_s_mode = prv <= `PRV_S && |(medeleg & (`XLEN'b1 << trap_cause[`XLEN-2:0]));
assign ints_m_mode = ((prv == `PRV_M && mstatus_mie) || prv < `PRV_M) && |(~mideleg & mip & mie);
assign ints_s_mode = ((prv == `PRV_S && mstatus_sie) || prv < `PRV_S) && |( mideleg & mip & mie) && !ints_m_mode;

assign trap_vec    = ((trap_en ? (trap_m_mode ? mtvec : stvec):
                                 (ints_m_mode ? mtvec : stvec)) & ~`IM_ADDR_LEN'h3) + vec_offset;

assign vec_offset  = trap_en     ? `IM_ADDR_LEN'd0:
                     ints_s_mode ? ints_s_en[`MIP_MEIP_BIT]      ? (`IM_ADDR_LEN'd`MIP_MEIP_BIT << 2) & {`IM_ADDR_LEN{stvec[0]}}:
                                   ints_s_en[`MIP_MSIP_BIT]      ? (`IM_ADDR_LEN'd`MIP_MSIP_BIT << 2) & {`IM_ADDR_LEN{stvec[0]}}:
                                   ints_s_en[`MIP_MTIP_BIT]      ? (`IM_ADDR_LEN'd`MIP_MTIP_BIT << 2) & {`IM_ADDR_LEN{stvec[0]}}:
                                   ints_s_en[`MIP_SEIP_BIT]      ? (`IM_ADDR_LEN'd`MIP_SEIP_BIT << 2) & {`IM_ADDR_LEN{stvec[0]}}:
                                   ints_s_en[`MIP_SSIP_BIT]      ? (`IM_ADDR_LEN'd`MIP_SSIP_BIT << 2) & {`IM_ADDR_LEN{stvec[0]}}:
                                   /*ints_s_en[`MIP_STIP_BIT] ? */ (`IM_ADDR_LEN'd`MIP_STIP_BIT << 2) & {`IM_ADDR_LEN{stvec[0]}}:
                     ints_m_mode ? ints_m_en[`MIP_MEIP_BIT]      ? (`IM_ADDR_LEN'd`MIP_MEIP_BIT << 2) & {`IM_ADDR_LEN{mtvec[0]}}:
                                   ints_m_en[`MIP_MSIP_BIT]      ? (`IM_ADDR_LEN'd`MIP_MSIP_BIT << 2) & {`IM_ADDR_LEN{mtvec[0]}}:
                                   ints_m_en[`MIP_MTIP_BIT]      ? (`IM_ADDR_LEN'd`MIP_MTIP_BIT << 2) & {`IM_ADDR_LEN{mtvec[0]}}:
                                   ints_m_en[`MIP_SEIP_BIT]      ? (`IM_ADDR_LEN'd`MIP_SEIP_BIT << 2) & {`IM_ADDR_LEN{mtvec[0]}}:
                                   ints_m_en[`MIP_SSIP_BIT]      ? (`IM_ADDR_LEN'd`MIP_SSIP_BIT << 2) & {`IM_ADDR_LEN{mtvec[0]}}:
                                   /*ints_m_en[`MIP_STIP_BIT] ? */ (`IM_ADDR_LEN'd`MIP_STIP_BIT << 2) & {`IM_ADDR_LEN{mtvec[0]}}:
                                   `IM_ADDR_LEN'd0;


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

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) prv <= `PRV_M;
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

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn)                                       stvec <= `XLEN'b0;
    else if (csr_wr && csr_waddr == `CSR_STVEC_ADDR) stvec <= (~`XLEN'h2  & csr_wdata);
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn)                                          sscratch <= `XLEN'b0;
    else if (csr_wr && csr_waddr == `CSR_SSCRATCH_ADDR) sscratch <= csr_wdata;
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        sepc <= `XLEN'b0;
    end
    else if (trap_en && trap_s_mode) begin
        sepc <= trap_epc;
    end
    else if (ints_s_mode) begin
        sepc <= trap_epc;
    end
    else if (csr_wr && csr_waddr == `CSR_SEPC_ADDR) begin
        sepc <= (~`XLEN'h1  & csr_wdata);
    end
end

assign scause = {scause_int, scause_code};

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        scause_int  <= 1'b0;
        scause_code <= {`XLEN-1{1'b0}};
    end
    else if (trap_en && trap_s_mode) begin
        scause_code <= trap_cause[0+:`XLEN-1];
        scause_int  <= trap_cause[`XLEN-1];
    end
    else if (ints_s_mode) begin
        scause_int  <= 1'b1;
        scause_code <= ints_s_en[`MIP_MEIP_BIT] ? `MCAUSE_CODE_WIDTH'd`MIP_MEIP_BIT:
                       ints_s_en[`MIP_MSIP_BIT] ? `MCAUSE_CODE_WIDTH'd`MIP_MSIP_BIT:
                       ints_s_en[`MIP_MTIP_BIT] ? `MCAUSE_CODE_WIDTH'd`MIP_MTIP_BIT:
                       ints_s_en[`MIP_SEIP_BIT] ? `MCAUSE_CODE_WIDTH'd`MIP_SEIP_BIT:
                       ints_s_en[`MIP_SSIP_BIT] ? `MCAUSE_CODE_WIDTH'd`MIP_SSIP_BIT:
                       ints_s_en[`MIP_STIP_BIT] ? `MCAUSE_CODE_WIDTH'd`MIP_STIP_BIT:
                                                  {(`XLEN-1){1'b1}};
    end
    else if (csr_wr && csr_waddr == `CSR_SCAUSE_ADDR) begin
        scause_code <= csr_wdata[0+:`XLEN-1];
        scause_int  <= csr_wdata[`XLEN-1];
    end
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        stval <= `XLEN'b0;
    end
    else if (trap_en && trap_s_mode) begin
        stval <= trap_val;
    end
    else if (ints_s_mode) begin
        stval <= `XLEN'b0;
    end
    else if (csr_wr && csr_waddr == `CSR_STVAL_ADDR) stval <= csr_wdata;
end

assign mstatus = {mstatus_sd, 8'b0, mstatus_tsr, /*mstatus_tw*/1'b0, mstatus_tvm,
                  mstatus_mxr, mstatus_sum, mstatus_mprv, mstatus_xs,
                  mstatus_fs, mstatus_mpp, 2'b0, mstatus_spp,
                  mstatus_mpie, 1'b0, mstatus_spie, 1'b0,
                  mstatus_mie, 1'b0, mstatus_sie, 1'b0};


assign sstatus = {1'b0, 8'b0, 1'b0, 1'b0, 1'b0,
                  mstatus_mxr, mstatus_sum, 1'b0, mstatus_xs,
                  mstatus_fs, 2'b0, 2'b0, mstatus_spp,
                  1'b0, 1'b0, mstatus_spie, 1'b0,
                  1'b0, 1'b0, mstatus_sie, 1'b0};

assign tvm     = mstatus_tvm;
assign tsr     = mstatus_tsr;
assign sum     = mstatus_sum;
assign mprv    = mstatus_mprv;
assign mpp     = mstatus_mpp;

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
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
        mstatus_uxl  <= 2'b0;
        mstatus_sxl  <= 2'b0;
        mstatus_sd   <= 1'b0;
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
        mstatus_sie  <= csr_wdata[`MSTATUS_SIE_BIT  ];
        mstatus_spie <= csr_wdata[`MSTATUS_SPIE_BIT ];
        mstatus_spp  <= csr_wdata[`MSTATUS_SPP_BIT  ];
        // mstatus_fs   <= csr_wdata[`MSTATUS_FS_BIT   ];
        // mstatus_xs   <= csr_wdata[`MSTATUS_XS_BIT   ];
        mstatus_sum  <= csr_wdata[`MSTATUS_SUM_BIT  ];
        mstatus_mxr  <= csr_wdata[`MSTATUS_MXR_BIT  ];
    end
    else if (csr_wr && csr_waddr == `CSR_MSTATUS_ADDR) begin
        mstatus_sie  <= csr_wdata[`MSTATUS_SIE_BIT  ];
        mstatus_mie  <= csr_wdata[`MSTATUS_MIE_BIT  ];
        mstatus_spie <= csr_wdata[`MSTATUS_SPIE_BIT ];
        mstatus_mpie <= csr_wdata[`MSTATUS_MPIE_BIT ];
        mstatus_spp  <= csr_wdata[`MSTATUS_SPP_BIT  ];
        mstatus_mpp  <= csr_wdata[`MSTATUS_MPP_BIT  ];
        // mstatus_fs   <= csr_wdata[`MSTATUS_FS_BIT   ];
        // mstatus_xs   <= csr_wdata[`MSTATUS_XS_BIT   ];
        mstatus_mprv <= csr_wdata[`MSTATUS_MPRV_BIT ];
        mstatus_sum  <= csr_wdata[`MSTATUS_SUM_BIT  ];
        mstatus_mxr  <= csr_wdata[`MSTATUS_MXR_BIT  ];
        mstatus_tvm  <= csr_wdata[`MSTATUS_TVM_BIT  ];
        mstatus_tw   <= csr_wdata[`MSTATUS_TW_BIT   ];
        mstatus_tsr  <= csr_wdata[`MSTATUS_TSR_BIT  ];
        mstatus_sd   <= csr_wdata[`MSTATUS_32_SD_BIT];
    end
end

assign misa = misa_mxl == 2'h1 ? {{`XLEN-32{1'b0}}, misa_mxl, 4'b0, misa_ext}:
              misa_mxl == 2'h2 ? {misa_mxl, {`XLEN-28{1'b0}}, misa_ext}:
                                 `XLEN'b0;
assign misa_ext = ({25'b0, misa_a_ext} << ("a" - "a")) |
                  ({25'b0, misa_c_ext} << ("c" - "a")) |
                  ({25'b0, misa_m_ext} << ("m" - "a"));

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        misa_mxl   <= 2'h1;
        misa_a_ext <= 1'b1;
        misa_c_ext <= 1'b1;
        misa_m_ext <= 1'b1;
    end
    else if (csr_wr && csr_waddr == `CSR_MISA_ADDR) begin
        misa_c_ext <= misaligned ? misa_c_ext : csr_wdata["c" - "a"];
        misa_m_ext <= csr_wdata["m" - "a"];
    end
end

assign medeleg = {{(`XLEN-16){1'b0}}, medeleg_stpgfault, 1'b0, medeleg_ldpgfault,
                  medeleg_instpgfault, 1'b0, 1'b0, 1'b0, medeleg_uecall, 1'b0, 1'b0,
                  1'b0, 1'b0, medeleg_bp, 1'b0, 1'b0, medeleg_imisalign};

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        medeleg_imisalign   <= 1'b0;
        medeleg_bp          <= 1'b0;
        medeleg_uecall      <= 1'b0;
        medeleg_instpgfault <= 1'b0;
        medeleg_ldpgfault   <= 1'b0;
        medeleg_stpgfault   <= 1'b0;
    end
    else if (csr_wr && csr_waddr == `CSR_MEDELEG_ADDR) begin
        medeleg_imisalign   <= csr_wdata[`CAUSE_MISALIGNED_FETCH      ];
        medeleg_bp          <= csr_wdata[`CAUSE_BREAKPOINT            ];
        medeleg_uecall      <= csr_wdata[`CAUSE_USER_ECALL            ];
        medeleg_instpgfault <= csr_wdata[`CAUSE_INSTRUCTION_PAGE_FAULT];
        medeleg_ldpgfault   <= csr_wdata[`CAUSE_LOAD_PAGE_FAULT       ];
        medeleg_stpgfault   <= csr_wdata[`CAUSE_STORE_PAGE_FAULT      ];
    end
end

assign mideleg = {{(`XLEN-10){1'b0}}, mideleg_seip, 3'b0, mideleg_stip, 3'b0, mideleg_ssip, 1'b0};

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        mideleg_ssip <= 1'b0;
        mideleg_stip <= 1'b0;
        mideleg_seip <= 1'b0;
    end
    else if (csr_wr && csr_waddr == `CSR_MIDELEG_ADDR) begin
        mideleg_ssip <= csr_wdata[1];
        mideleg_stip <= csr_wdata[5];
        mideleg_seip <= csr_wdata[9];
    end
end

assign mie = {{(`XLEN-12){1'b0}}, mie_meie, 1'b0, mie_seie, 1'b0, mie_mtie, 1'b0,
              mie_stie, 1'b0, mie_msie, 1'b0, mie_ssie, 1'b0};

assign sie = {{(`XLEN-10){1'b0}}, mie_seie, 3'b0, mie_stie, 3'b0, mie_ssie, 1'b0};

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        mie_ssie <= 1'b0;
        mie_msie <= 1'b0;
        mie_stie <= 1'b0;
        mie_mtie <= 1'b0;
        mie_seie <= 1'b0;
        mie_meie <= 1'b0;
    end
    else if (csr_wr && csr_waddr == `CSR_SIE_ADDR) begin
        mie_ssie <= csr_wdata[1];
        mie_stie <= csr_wdata[5];
        mie_seie <= csr_wdata[9];
    end
    else if (csr_wr && csr_waddr == `CSR_MIE_ADDR) begin
        mie_ssie <= csr_wdata[ 1];
        mie_msie <= csr_wdata[ 3];
        mie_stie <= csr_wdata[ 5];
        mie_mtie <= csr_wdata[ 7];
        mie_seie <= csr_wdata[ 9];
        mie_meie <= csr_wdata[11];
    end
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn)                                       mtvec <= `XLEN'b0;
    else if (csr_wr && csr_waddr == `CSR_MTVEC_ADDR) mtvec <= (~`XLEN'h2  & csr_wdata);
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn)                                          mscratch <= `XLEN'b0;
    else if (csr_wr && csr_waddr == `CSR_MSCRATCH_ADDR) mscratch <= csr_wdata;
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        mepc <= `XLEN'b0;
    end
    else if (trap_en && ~trap_s_mode) begin
        mepc <= trap_epc;
    end
    else if (ints_m_mode) begin
        mepc <= trap_epc;
    end
    else if (csr_wr && csr_waddr == `CSR_MEPC_ADDR) begin
        mepc <= (~`XLEN'h1  & csr_wdata);
    end
end

assign mcause = {mcause_int, mcause_code};

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        mcause_code <= {`XLEN-1{1'b0}};
        mcause_int  <= 1'b0;
    end
    else if (trap_en && ~trap_s_mode) begin
        mcause_code <= trap_cause[0+:`XLEN-1];
        mcause_int  <= trap_cause[`XLEN-1];
    end
    else if (ints_m_mode) begin
        mcause_int  <= 1'b1;
        mcause_code <= ints_m_en[`MIP_MEIP_BIT] ? `MCAUSE_CODE_WIDTH'd`MIP_MEIP_BIT:
                       ints_m_en[`MIP_MSIP_BIT] ? `MCAUSE_CODE_WIDTH'd`MIP_MSIP_BIT:
                       ints_m_en[`MIP_MTIP_BIT] ? `MCAUSE_CODE_WIDTH'd`MIP_MTIP_BIT:
                       ints_m_en[`MIP_SEIP_BIT] ? `MCAUSE_CODE_WIDTH'd`MIP_SEIP_BIT:
                       ints_m_en[`MIP_SSIP_BIT] ? `MCAUSE_CODE_WIDTH'd`MIP_SSIP_BIT:
                       ints_m_en[`MIP_STIP_BIT] ? `MCAUSE_CODE_WIDTH'd`MIP_STIP_BIT:
                                                  {(`XLEN-1){1'b1}};
    end
    else if (csr_wr && csr_waddr == `CSR_MCAUSE_ADDR) begin
        mcause_code <= csr_wdata[0+:`XLEN-1];
        mcause_int  <= csr_wdata[`XLEN-1];
    end
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        mtval <= `XLEN'b0;
    end
    else if (trap_en && ~trap_s_mode) begin
        mtval <= trap_val;
    end
    else if (ints_m_mode) begin
        mtval <= `XLEN'b0;
    end
    else if (csr_wr && csr_waddr == `CSR_MTVAL_ADDR) begin
        mtval <= csr_wdata;
    end
end

assign mip = {{(`XLEN-12){1'b0}}, mip_meip, 1'b0, mip_seip, 1'b0, mip_mtip, 1'b0,
              mip_stip, 1'b0, mip_msip, 1'b0, mip_ssip, 1'b0};

assign sip = {{(`XLEN-2){1'b0}}, mip_ssip, 1'b0};

always_ff @(posedge clk_free or negedge rstn) begin
    if (~rstn) begin
        msip_d1  <= 1'b0;
        mtip_d1  <= 1'b0;
        meip_d1  <= 1'b0;
        mip_msip <= 1'b0;
        mip_mtip <= 1'b0;
        mip_meip <= 1'b0;
    end
    else begin
        msip_d1  <= ext_msip;
        mtip_d1  <= ext_mtip;
        meip_d1  <= ext_meip;
        mip_msip <= msip_d1;
        mip_mtip <= mtip_d1;
        mip_meip <= meip_d1;
    end
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        mip_ssip <= 1'b0;
        mip_stip <= 1'b0;
        mip_seip <= 1'b0;
    end
    else if (~sleep) begin
        if (csr_wr && csr_waddr == `CSR_SIP_ADDR)  begin
            mip_ssip <= csr_wdata[1] & mideleg_ssip;
        end
        else if (csr_wr && csr_waddr == `CSR_MIP_ADDR) begin
            mip_ssip <= csr_wdata[1];
            mip_stip <= csr_wdata[5];
            mip_seip <= csr_wdata[9];
        end
    end
end

always_comb begin
    csr_rdata = `XLEN'b0;
    case (csr_raddr) 
        `CSR_SSTATUS_ADDR   : csr_rdata = sstatus;
        `CSR_SEDELEG_ADDR   : csr_rdata = `XLEN'b0;
        `CSR_SIDELEG_ADDR   : csr_rdata = `XLEN'b0;
        `CSR_SIE_ADDR       : csr_rdata = sie & mideleg;
        `CSR_STVEC_ADDR     : csr_rdata = stvec;
        `CSR_SCOUNTEREN_ADDR: csr_rdata = `XLEN'b0;
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
        `CSR_MCOUNTEREN_ADDR: csr_rdata = `XLEN'b0;
        `CSR_MSCRATCH_ADDR  : csr_rdata = mscratch;
        `CSR_MEPC_ADDR      : csr_rdata = mepc;
        `CSR_MCAUSE_ADDR    : csr_rdata = mcause;
        `CSR_MTVAL_ADDR     : csr_rdata = mtval;
        `CSR_MIP_ADDR       : csr_rdata = mip;
    endcase
end

endmodule
