`include "cpu_define.h"
`include "intf_define.h"

module cpu_wrap (
    input                  clk,
    input                  rstn,

    // external AXI interface
    input         [  1: 0] axi_ext_awburst,
    input         [  9: 0] axi_ext_awid,
    input         [ 31: 0] axi_ext_awaddr,
    input         [  2: 0] axi_ext_awsize,
    input         [  7: 0] axi_ext_awlen,
    input                  axi_ext_awvalid,
    output logic           axi_ext_awready,
    input         [  3: 0] axi_ext_wstrb,
    input         [  9: 0] axi_ext_wid,
    input         [ 31: 0] axi_ext_wdata,
    input                  axi_ext_wlast,
    input                  axi_ext_wvalid,
    output logic           axi_ext_wready,
    output logic  [  9: 0] axi_ext_bid,
    output logic  [  1: 0] axi_ext_bresp,
    output logic           axi_ext_bvalid,
    input                  axi_ext_bready,
    input         [ 31: 0] axi_ext_araddr,
    input         [  1: 0] axi_ext_arburst,
    input         [  2: 0] axi_ext_arsize,
    input         [  9: 0] axi_ext_arid,
    input         [  7: 0] axi_ext_arlen,
    input                  axi_ext_arvalid,
    output logic           axi_ext_arready,
    output logic  [ 31: 0] axi_ext_rdata,
    output logic  [  1: 0] axi_ext_rresp,
    output logic  [  9: 0] axi_ext_rid,
    output logic           axi_ext_rlast,
    output logic           axi_ext_rvalid,
    input                  axi_ext_rready,

    // debug APB interface
    input                  dbg_psel,
    input                  dbg_penable,
    input         [ 31: 0] dbg_paddr,
    input                  dbg_pwrite,
    input         [  3: 0] dbg_pstrb,
    input         [  2: 0] dbg_pprot,
    input         [ 31: 0] dbg_pwdata,
    output logic  [ 31: 0] dbg_prdata,
    output logic           dbg_pslverr,
    output logic           dbg_pready,

    // UART interface
    output logic           uart_tx,
    input                  uart_rx
);

logic                             core_rstn;
logic [              `XLEN - 1:0] core_bootvec;

logic                             msip;
logic                             mtip;
logic                             meip;

logic                             imem_en;
logic [       `IM_ADDR_LEN - 1:0] imem_addr;
logic [       `IM_DATA_LEN - 1:0] imem_rdata;
logic [                      1:0] imem_bad;
logic                             imem_busy;

logic                             dmem_en;
logic [       `IM_ADDR_LEN - 1:0] dmem_addr;
logic                             dmem_write;
logic [(`IM_DATA_LEN >> 3) - 1:0] dmem_strb;
logic [       `IM_DATA_LEN - 1:0] dmem_wdata;
logic [       `IM_DATA_LEN - 1:0] dmem_rdata;
logic [                      1:0] dmem_bad;
logic                             dmem_busy;

logic [                  8 - 1:0] pmpcfg  [16];
logic [              `XLEN - 1:0] pmpaddr [16];
logic [                  8 - 1:0] pmacfg  [16];
logic [              `XLEN - 1:0] pmaaddr [16];

logic                             ipmp_v;
logic                             ipmp_l;
logic                             ipmp_x;
logic                             ipmp_w;
logic                             ipmp_r;
logic                             ipma_v;
logic                             ipma_l;
logic                             ipma_c;
logic                             ipma_e;

logic                             dpmp_v;
logic                             dpmp_l;
logic                             dpmp_x;
logic                             dpmp_w;
logic                             dpmp_r;
logic                             dpma_v;
logic                             dpma_l;
logic                             dpma_c;
logic                             dpma_e;

logic [    `SATP_PPN_WIDTH - 1:0] satp_ppn;
logic [   `SATP_ASID_WIDTH - 1:0] satp_asid;
logic [   `SATP_MODE_WIDTH - 1:0] satp_mode;
logic [                      1:0] prv;
logic                             sum;
logic                             mprv;
logic [                      1:0] mpp;
logic                             tlb_flush_req;
logic                             tlb_flush_all_vaddr;
logic                             tlb_flush_all_asid;
logic [              `XLEN - 1:0] tlb_flush_vaddr;
logic [              `XLEN - 1:0] tlb_flush_asid;
logic                             ic_flush;

logic          mem_ck_0;
logic          mem_ck_1;

logic          cs_0;
logic          we_0;
logic [ 31: 0] addr_0;
logic [  3: 0] byte_0;
logic [ 31: 0] di_0;
logic [ 31: 0] do_0;
logic          busy_0;
              
logic          cs_1;
logic          we_1;
logic [ 31: 0] addr_1;
logic [  3: 0] byte_1;
logic [ 31: 0] di_1;
logic [ 31: 0] do_1;
logic          busy_1;

logic          icache_bypass;
logic          immu_pa_vld;
logic [  1: 0] immu_pa_bad;
logic [ 55: 0] immu_pa;
logic [ 55: 0] immu_pa_pre;

logic          dcache_bypass;
logic          dmmu_pa_vld;
logic [  1: 0] dmmu_pa_bad;
logic [ 55: 0] dmmu_pa;
logic [ 55: 0] dmmu_pa_pre;

logic          core_psel;
logic          core_penable;
logic [ 31: 0] core_paddr;
logic          core_pwrite;
logic [  3: 0] core_pstrb;
logic [ 31: 0] core_pwdata;
logic [ 31: 0] core_prdata;
logic          core_pslverr;
logic          core_pready;

logic          intc_psel;
logic          intc_penable;
logic [ 31: 0] intc_paddr;
logic          intc_pwrite;
logic [  3: 0] intc_pstrb;
logic [ 31: 0] intc_pwdata;
logic [ 31: 0] intc_prdata;
logic          intc_pslverr;
logic          intc_pready;
logic [ 31: 0] ints;

logic          cfgreg_psel;
logic          cfgreg_penable;
logic [ 31: 0] cfgreg_paddr;
logic          cfgreg_pwrite;
logic [  3: 0] cfgreg_pstrb;
logic [ 31: 0] cfgreg_pwdata;
logic [ 31: 0] cfgreg_prdata;
logic          cfgreg_pslverr;
logic          cfgreg_pready;

logic          uart_psel;
logic          uart_penable;
logic [ 31: 0] uart_paddr;
logic          uart_pwrite;
logic [  3: 0] uart_pstrb;
logic [ 31: 0] uart_pwdata;
logic [ 31: 0] uart_prdata;
logic          uart_pslverr;
logic          uart_pready;
logic          uart_irq;

logic [ 11: 0] dbg_addr;
logic [ 31: 0] dbg_wdata;
logic          dbg_gpr_rd;
logic          dbg_gpr_wr;
logic [ 31: 0] dbg_gpr_rdata;
logic          dbg_csr_rd;
logic          dbg_csr_wr;
logic [ 31: 0] dbg_csr_rdata;
logic [ 31: 0] dbg_pc;
logic [ 31: 0] dbg_inst;
logic          dbg_exec;
logic          dbg_halted;
logic          dbg_attach;


`AXI_INTF_DEF(immu, 10)
`AXI_INTF_DEF(dmmu, 10)
`AXI_INTF_DEF(l1ic, 10)
`AXI_INTF_DEF(l1dc, 10)
`AXI_INTF_DEF(axi_ext_remap, 10)

cpu_top u_cpu_top (
    .clk                 ( clk                 ),
    .rstn                ( core_rstn           ),
    .cpu_id              ( `XLEN'd0            ),
    .bootvec             ( core_bootvec        ),

    // mpu csr
    .pmpcfg              ( pmpcfg              ),
    .pmpaddr             ( pmpaddr             ),
    .pmacfg              ( pmacfg              ),
    .pmaaddr             ( pmaaddr             ),

    // mmu csr
    .satp_ppn            ( satp_ppn            ),
    .satp_asid           ( satp_asid           ),
    .satp_mode           ( satp_mode           ),
    .prv                 ( prv                 ),
    .sum                 ( sum                 ),
    .mprv                ( mprv                ),
    .mpp                 ( mpp                 ),

    // TLB control
    .tlb_flush_req       ( tlb_flush_req       ),
    .tlb_flush_all_vaddr ( tlb_flush_all_vaddr ),
    .tlb_flush_all_asid  ( tlb_flush_all_asid  ),
    .tlb_flush_vaddr     ( tlb_flush_vaddr     ),
    .tlb_flush_asid      ( tlb_flush_asid      ),
   
    // interrupt interface
    .msip                ( msip                ),
    .mtip                ( mtip                ),
    .meip                ( meip                ),

    // inst interface
    .imem_en             ( imem_en             ),
    .imem_addr           ( imem_addr           ),
    .imem_rdata          ( imem_rdata          ),
    .imem_bad            ( imem_bad            ),
    .imem_busy           ( imem_busy           ),
    .ic_flush            ( ic_flush            ),

    // data interface
    .dmem_en             ( dmem_en             ),
    .dmem_addr           ( dmem_addr           ),
    .dmem_write          ( dmem_write          ),
    .dmem_strb           ( dmem_strb           ),
    .dmem_wdata          ( dmem_wdata          ),
    .dmem_rdata          ( dmem_rdata          ),
    .dmem_bad            ( dmem_bad            ),
    .dmem_busy           ( dmem_busy           ),

    // debug intface
    .dbg_addr            ( dbg_addr            ),
    .dbg_wdata           ( dbg_wdata           ),
    .dbg_gpr_rd          ( dbg_gpr_rd          ),
    .dbg_gpr_wr          ( dbg_gpr_wr          ),
    .dbg_gpr_out         ( dbg_gpr_rdata       ),
    .dbg_csr_rd          ( dbg_csr_rd          ),
    .dbg_csr_wr          ( dbg_csr_wr          ),
    .dbg_csr_out         ( dbg_csr_rdata       ),
    .dbg_pc_out          ( dbg_pc              ),
    .dbg_exec            ( dbg_exec            ),
    .dbg_inst            ( dbg_inst            ),
    .attach              ( dbg_attach          ),
    .halted              ( dbg_halted          )
);

mmu u_immu(
    .clk                 ( clk                 ),
    .rstn                ( core_rstn           ),
    
    // access type
    .access_w            ( 1'b0                ),
    .access_x            ( 1'b1                ),

    // TLB control
    .tlb_flush_req       ( tlb_flush_req       ),
    .tlb_flush_all_vaddr ( tlb_flush_all_vaddr ),
    .tlb_flush_all_asid  ( tlb_flush_all_asid  ),
    .tlb_flush_vaddr     ( tlb_flush_vaddr     ),
    .tlb_flush_asid      ( tlb_flush_asid      ),

    // mpu csr
    .pmp_v               ( ipmp_v              ),
    .pmp_l               ( ipmp_l              ),
    .pmp_x               ( ipmp_x              ),
    .pmp_w               ( ipmp_w              ),
    .pmp_r               ( ipmp_r              ),

    .pma_v               ( ipma_v              ),
    .pma_l               ( ipma_l              ),
    .pma_c               ( ipma_c              ),
    .pma_e               ( ipma_e              ),

    // mmu csr
    .satp_ppn            ( satp_ppn            ),
    .satp_asid           ( satp_asid           ),
    .satp_mode           ( satp_mode           ),
    .prv                 ( prv                 ),
    .sum                 ( sum                 ),
    .mprv                ( mprv                ),
    .mpp                 ( mpp                 ),

    // virtual address
    .va_valid            ( imem_en             ),
    .va                  ( {16'b0, imem_addr}  ),

    // Cache bypass
    .cache_bypass        ( icache_bypass       ),

    // physical address
    .pa_valid            ( immu_pa_vld         ),
    .pa_bad              ( immu_pa_bad         ),
    .pa                  ( immu_pa             ),
    .pa_pre              ( immu_pa_pre         ),
    
    // AXI interface
    `AXI_INTF_CONNECT(m, immu)
);

mmu u_dmmu(
    .clk                 ( clk                 ),
    .rstn                ( core_rstn           ),
    
    // access type
    .access_w            ( dmem_write          ),
    .access_x            ( 1'b0                ),

    // TLB control
    .tlb_flush_req       ( tlb_flush_req       ),
    .tlb_flush_all_vaddr ( tlb_flush_all_vaddr ),
    .tlb_flush_all_asid  ( tlb_flush_all_asid  ),
    .tlb_flush_vaddr     ( tlb_flush_vaddr     ),
    .tlb_flush_asid      ( tlb_flush_asid      ),

    // mpu csr
    .pmp_v               ( dpmp_v              ),
    .pmp_l               ( dpmp_l              ),
    .pmp_x               ( dpmp_x              ),
    .pmp_w               ( dpmp_w              ),
    .pmp_r               ( dpmp_r              ),

    .pma_v               ( dpma_v              ),
    .pma_l               ( dpma_l              ),
    .pma_c               ( dpma_c              ),
    .pma_e               ( dpma_e              ),

    // mmu csr
    .satp_ppn            ( satp_ppn            ),
    .satp_asid           ( satp_asid           ),
    .satp_mode           ( satp_mode           ),
    .prv                 ( prv                 ),
    .sum                 ( sum                 ),
    .mprv                ( mprv                ),
    .mpp                 ( mpp                 ),

    // virtual address
    .va_valid            ( dmem_en             ),
    .va                  ( {16'b0, dmem_addr}  ),

    // Cache bypass
    .cache_bypass        ( dcache_bypass       ),

    // physical address
    .pa_valid            ( dmmu_pa_vld         ),
    .pa_bad              ( dmmu_pa_bad         ),
    .pa                  ( dmmu_pa             ),
    .pa_pre              ( dmmu_pa_pre         ),
    
    // AXI interface
    `AXI_INTF_CONNECT(m, dmmu)
);

mpu u_impu (
    .clk      ( clk         ),
    .rstn     ( core_rstn   ),
    .pmpcfg   ( pmpcfg      ),
    .pmpaddr  ( pmpaddr     ),
    .pmacfg   ( pmacfg      ),
    .pmaaddr  ( pmaaddr     ),
    .paddr    ( immu_pa_pre[33:0] ),

    .pmp_v    ( ipmp_v      ),
    .pmp_l    ( ipmp_l      ),
    .pmp_x    ( ipmp_x      ),
    .pmp_w    ( ipmp_w      ),
    .pmp_r    ( ipmp_r      ),
        
    .pma_v    ( ipma_v      ),
    .pma_l    ( ipma_l      ),
    .pma_c    ( ipma_c      ),
    .pma_e    ( ipma_e      )
        
);

mpu u_dmpu (
    .clk      ( clk         ),
    .rstn     ( core_rstn   ),
    .pmpcfg   ( pmpcfg      ),
    .pmpaddr  ( pmpaddr     ),
    .pmacfg   ( pmacfg      ),
    .pmaaddr  ( pmaaddr     ),
    .paddr    ( dmmu_pa_pre[33:0] ),

    .pmp_v    ( dpmp_v      ),
    .pmp_l    ( dpmp_l      ),
    .pmp_x    ( dpmp_x      ),
    .pmp_w    ( dpmp_w      ),
    .pmp_r    ( dpmp_r      ),
        
    .pma_v    ( dpma_v      ),
    .pma_l    ( dpma_l      ),
    .pma_c    ( dpma_c      ),
    .pma_e    ( dpma_e      )

);

l1c u_l1ic (
    .clk         ( clk           ),
    .rstn        ( core_rstn     ),

    .core_bypass ( icache_bypass ),
    .core_flush  ( ic_flush      ),
    .core_pa_vld ( immu_pa_vld   ),
    .core_pa_bad ( immu_pa_bad   ),
    .core_paddr  ( immu_pa[31:0] ),
    .core_req    ( imem_en       ),
    .core_wr     ( 1'b0          ),
    .core_vaddr  ( imem_addr     ),
    .core_byte   ( 4'hf          ),
    .core_wdata  ( 32'b0         ),
    .core_rdata  ( imem_rdata    ),
    .core_bad    ( imem_bad      ),
    .core_busy   ( imem_busy     ),

    `AXI_INTF_CONNECT(m, l1ic)
);

l1c u_l1dc (
    .clk         ( clk           ),
    .rstn        ( core_rstn     ),

    .core_bypass ( dcache_bypass ),
    .core_flush  ( 1'b0          ),
    .core_pa_vld ( dmmu_pa_vld   ),
    .core_paddr  ( dmmu_pa[31:0] ),
    .core_pa_bad ( dmmu_pa_bad   ),
    .core_req    ( dmem_en       ),
    .core_wr     ( dmem_write    ),
    .core_vaddr  ( dmem_addr     ),
    .core_byte   ( dmem_strb     ),
    .core_wdata  ( dmem_wdata    ),
    .core_rdata  ( dmem_rdata    ),
    .core_bad    ( dmem_bad      ),
    .core_busy   ( dmem_busy     ),

    `AXI_INTF_CONNECT(m, l1dc)
);

assign intc_psel      = core_paddr[27] && core_psel;
assign intc_penable   = core_paddr[27] && core_penable;
assign intc_paddr     = core_paddr;
assign intc_pwrite    = core_pwrite;
assign intc_pstrb     = core_pstrb;
assign intc_pwdata    = core_pwdata;

assign cfgreg_psel    = ~core_paddr[27] && core_psel;
assign cfgreg_penable = ~core_paddr[27] && core_penable;
assign cfgreg_paddr   = core_paddr;
assign cfgreg_pwrite  = core_pwrite;
assign cfgreg_pstrb   = core_pstrb;
assign cfgreg_pwdata  = core_pwdata;

assign core_prdata    = core_paddr[27] ? intc_prdata  : cfgreg_prdata;
assign core_pslverr   = core_paddr[27] ? intc_pslverr : cfgreg_pslverr;
assign core_pready    = core_paddr[27] ? intc_pready  : cfgreg_pready;

cfgreg u_cfgreg (
    .pclk         ( clk            ),
    .presetn      ( rstn           ),
    .psel         ( cfgreg_psel    ),
    .penable      ( cfgreg_penable ),
    .paddr        ( cfgreg_paddr   ),
    .pwrite       ( cfgreg_pwrite  ),
    .pstrb        ( cfgreg_pstrb   ),
    .pwdata       ( cfgreg_pwdata  ),
    .prdata       ( cfgreg_prdata  ),
    .pslverr      ( cfgreg_pslverr ),
    .pready       ( cfgreg_pready  ),

    .core_bootvec ( core_bootvec   ),
    .core_rstn    ( core_rstn      )
);

iommu u_iommu (
    .aclk       ( clk          ),
    .aresetn    ( rstn         ),

    `AXI_INTF_CONNECT(s, axi_ext),
    `AXI_INTF_CONNECT(m, axi_ext_remap)
);

marb u_marb (
    .clk        ( clk          ),
    .rstn       ( rstn         ),

    `AXI_INTF_CONNECT(s0, immu),
    `AXI_INTF_CONNECT(s1, dmmu),
    `AXI_INTF_CONNECT(s2, l1ic),
    `AXI_INTF_CONNECT(s3, l1dc),
    `AXI_INTF_CONNECT(s4, axi_ext_remap),

    .m0_cs      ( cs_0         ),
    .m0_we      ( we_0         ),
    .m0_addr    ( addr_0       ),
    .m0_byte    ( byte_0       ),
    .m0_di      ( di_0         ),
    .m0_do      ( do_0         ),
    .m0_busy    ( busy_0       ),

    .m1_cs      ( cs_1         ),
    .m1_we      ( we_1         ),
    .m1_addr    ( addr_1       ),
    .m1_byte    ( byte_1       ),
    .m1_di      ( di_1         ),
    .m1_do      ( do_1         ),
    .m1_busy    ( busy_1       ),

    .m2_psel    ( core_psel    ),
    .m2_penable ( core_penable ),
    .m2_paddr   ( core_paddr   ),
    .m2_pwrite  ( core_pwrite  ),
    .m2_pstrb   ( core_pstrb   ),
    .m2_pwdata  ( core_pwdata  ),
    .m2_prdata  ( core_prdata  ),
    .m2_pslverr ( core_pslverr ),
    .m2_pready  ( core_pready  ),

    .m3_psel    ( uart_psel    ),
    .m3_penable ( uart_penable ),
    .m3_paddr   ( uart_paddr   ),
    .m3_pwrite  ( uart_pwrite  ),
    .m3_pstrb   ( uart_pstrb   ),
    .m3_pwdata  ( uart_pwdata  ),
    .m3_prdata  ( uart_prdata  ),
    .m3_pslverr ( uart_pslverr ),
    .m3_pready  ( uart_pready  )
);

// assign msip = 1'b0;
// assign mtip = 1'b0;
// assign meip = 1'b0;
// 
// assign core_rstn = rstn;
// 
// assign imem_bad  = 2'b0;
// assign imem_busy = 1'b0;
// 
// always_ff @(posedge clk or negedge rstn) begin
//     if (~rstn) begin
//         imem_rdata <= 32'b0;
//     end
//     else begin
//         imem_rdata <= u_sram_0.memory[imem_addr[15:2]];
//     end
// end
// 
// assign dmem_bad  = 2'b0;
// assign dmem_busy = 1'b0;
// 
// always_ff @(posedge clk or negedge rstn) begin
//     if (~rstn) begin
//         dmem_rdata <= 32'b0;
//     end
//     else begin
//         dmem_rdata <= dmem_addr[16] ? u_sram_1.memory[dmem_addr[15:2]] : u_sram_0.memory[dmem_addr[15:2]];
//     end
// end
// 
// always_ff @(posedge clk or negedge rstn) begin
//     if (dmem_write & dmem_en & dmem_addr[16]) begin
//         if (dmem_strb[0]) u_sram_1.memory[dmem_addr[15:2]][ 0+:8] <= dmem_wdata[ 0+:8];
//         if (dmem_strb[1]) u_sram_1.memory[dmem_addr[15:2]][ 8+:8] <= dmem_wdata[ 8+:8];
//         if (dmem_strb[2]) u_sram_1.memory[dmem_addr[15:2]][16+:8] <= dmem_wdata[16+:8];
//         if (dmem_strb[3]) u_sram_1.memory[dmem_addr[15:2]][24+:8] <= dmem_wdata[24+:8];
//     end
// end
// 
// assign cs_0 = 1'b0;
// assign cs_1 = 1'b0;

CG u_mem_cg_0 (
    .CK   ( clk      ),
    .EN   ( cs_0     ),
    .CKEN ( mem_ck_0 )
);

CG u_mem_cg_1 (
    .CK   ( clk      ),
    .EN   ( cs_1     ),
    .CKEN ( mem_ck_1 )
);

assign busy_0 = 1'b0;

sram u_sram_0 (
    .CK   ( mem_ck_0      ),
    .CS   ( cs_0          ),
    .A    ( addr_0[2+:14] ),
    .BYTE ( byte_0        ),
    .WE   ( we_0          ),
    .DI   ( di_0          ),
    .DO   ( do_0          )
);

assign busy_1 = 1'b0;

sram u_sram_1 (
    .CK   ( mem_ck_1      ),
    .CS   ( cs_1          ),
    .A    ( addr_1[2+:14] ),
    .BYTE ( byte_1        ),
    .WE   ( we_1          ),
    .DI   ( di_1          ),
    .DO   ( do_1          )
);

assign ints = {
    30'b0,
    uart_irq,
    1'b0 // reserve
};

intc u_intc(
    .clk    ( clk          ),
    .rstn   ( core_rstn    ),
    .psel   ( intc_psel    ),
    .penable( intc_penable ),
    .paddr  ( intc_paddr   ),
    .pwrite ( intc_pwrite  ),
    .pstrb  ( intc_pstrb   ),
    .pwdata ( intc_pwdata  ),
    .prdata ( intc_prdata  ),
    .pslverr( intc_pslverr ),
    .pready ( intc_pready  ),
                            
    .msip   ( msip         ),
    .mtip   ( mtip         ),
    .meip   ( meip         ),
    .ints   ( ints         )
);

dbgapb u_dbgapb (
    .pclk      ( clk           ),
    .presetn   ( core_rstn     ),
    .psel      ( dbg_psel      ),
    .penable   ( dbg_penable   ),
    .paddr     ( dbg_paddr     ),
    .pwrite    ( dbg_pwrite    ),
    .pstrb     ( dbg_pstrb     ),
    .pwdata    ( dbg_pwdata    ),
    .prdata    ( dbg_prdata    ),
    .pslverr   ( dbg_pslverr   ),
    .pready    ( dbg_pready    ),

    .addr_out  ( dbg_addr      ),
    .wdata_out ( dbg_wdata     ),
    .gpr_rd    ( dbg_gpr_rd    ),
    .gpr_wr    ( dbg_gpr_wr    ),
    .gpr_in    ( dbg_gpr_rdata ),
    .csr_rd    ( dbg_csr_rd    ),
    .csr_wr    ( dbg_csr_wr    ),
    .csr_in    ( dbg_csr_rdata ),
    .pc        ( dbg_pc        ),
    .inst_out  ( dbg_inst      ),
    .exec      ( dbg_exec      ),
    .halted    ( dbg_halted    ),
    .attach    ( dbg_attach    )
);

uart u_uart(
    .pclk    ( clk          ),
    .presetn ( rstn         ),
    .psel    ( uart_psel    ),
    .penable ( uart_penable ),
    .paddr   ( uart_paddr   ),
    .pwrite  ( uart_pwrite  ),
    .pstrb   ( uart_pstrb   ),
    .pwdata  ( uart_pwdata  ),
    .prdata  ( uart_prdata  ),
    .pslverr ( uart_pslverr ),
    .pready  ( uart_pready  ),

    .irq_out ( uart_irq     ),
    .uart_rx ( uart_rx      ),
    .uart_tx ( uart_tx      )
);
endmodule
