`include "cpu_define.h"
`include "intf_define.h"
`include "cache_define.h"

module cpu_wrap (
    input                  clk,
    input                  rstn,

    // DDR AXI interface
    output logic  [  1: 0] ddr_m_awburst,
    output logic  [  5: 0] ddr_m_awid,
    output logic  [ 31: 0] ddr_m_awaddr,
    output logic  [  2: 0] ddr_m_awsize,
    output logic  [  7: 0] ddr_m_awlen,
    output logic  [  1: 0] ddr_m_awlock,
    output logic  [  3: 0] ddr_m_awcache,
    output logic  [  2: 0] ddr_m_awprot,
    output logic           ddr_m_awvalid,
    input                  ddr_m_awready,
    output logic  [  3: 0] ddr_m_wstrb,
    output logic  [  5: 0] ddr_m_wid,
    output logic  [ 31: 0] ddr_m_wdata,
    output logic           ddr_m_wlast,
    output logic           ddr_m_wvalid,
    input                  ddr_m_wready,
    input         [  5: 0] ddr_m_bid,
    input         [  1: 0] ddr_m_bresp,
    input                  ddr_m_bvalid,
    output logic           ddr_m_bready,
    output logic  [ 31: 0] ddr_m_araddr,
    output logic  [  1: 0] ddr_m_arburst,
    output logic  [  2: 0] ddr_m_arsize,
    output logic  [  5: 0] ddr_m_arid,
    output logic  [  7: 0] ddr_m_arlen,
    output logic  [  1: 0] ddr_m_arlock,
    output logic  [  3: 0] ddr_m_arcache,
    output logic  [  2: 0] ddr_m_arprot,
    output logic           ddr_m_arvalid,
    input                  ddr_m_arready,
    input         [ 31: 0] ddr_m_rdata,
    input         [  1: 0] ddr_m_rresp,
    input         [  5: 0] ddr_m_rid,
    input                  ddr_m_rlast,
    input                  ddr_m_rvalid,
    output logic           ddr_m_rready,

    // external AXI interface
    input         [  1: 0] ext_s_awburst,
    input         [  7: 0] ext_s_awid,
    input         [ 31: 0] ext_s_awaddr,
    input         [  2: 0] ext_s_awsize,
    input         [  7: 0] ext_s_awlen,
    input         [  1: 0] ext_s_awlock,
    input         [  3: 0] ext_s_awcache,
    input         [  2: 0] ext_s_awprot,
    input                  ext_s_awvalid,
    output logic           ext_s_awready,
    input         [  3: 0] ext_s_wstrb,
    input         [  7: 0] ext_s_wid,
    input         [ 31: 0] ext_s_wdata,
    input                  ext_s_wlast,
    input                  ext_s_wvalid,
    output logic           ext_s_wready,
    output logic  [  7: 0] ext_s_bid,
    output logic  [  1: 0] ext_s_bresp,
    output logic           ext_s_bvalid,
    input                  ext_s_bready,
    input         [ 31: 0] ext_s_araddr,
    input         [  1: 0] ext_s_arburst,
    input         [  2: 0] ext_s_arsize,
    input         [  7: 0] ext_s_arid,
    input         [  7: 0] ext_s_arlen,
    input         [  1: 0] ext_s_arlock,
    input         [  3: 0] ext_s_arcache,
    input         [  2: 0] ext_s_arprot,
    input                  ext_s_arvalid,
    output logic           ext_s_arready,
    output logic  [ 31: 0] ext_s_rdata,
    output logic  [  1: 0] ext_s_rresp,
    output logic  [  7: 0] ext_s_rid,
    output logic           ext_s_rlast,
    output logic           ext_s_rvalid,
    input                  ext_s_rready,

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
    input                  uart_rx,

    // SPI interface
    // inout                  sclk,
    // inout                  nss,
    // inout                  mosi,
    // inout                  miso
    output                 sclk,
    output                 nss,
    output                 mosi,
    input                  miso,

    // JTAG interface
    input                  tck,
    input                  tms,
    input                  tdi,
    output                 tdo
);

logic                             core_rstn;
logic                             srstn;
logic                             xrstn;
logic                             rv64_mode;
logic [              `XLEN - 1:0] core_bootvec;
logic [                     31:0] ddr_offset;

logic [                     63:0] systime;

logic                             msip;
logic                             mtip;
logic                             meip;
logic                             seip;

logic                             imem_en;
logic [       `IM_ADDR_LEN - 1:0] imem_addr;
logic [  `CACHE_DATA_WIDTH - 1:0] imem_rdata;
logic [                      1:0] imem_bad;
logic                             imem_busy;

logic                             xmon_xstate;
logic                             dmem_en;
logic [       `IM_ADDR_LEN - 1:0] dmem_addr;
logic                             dmem_write;
logic                             dmem_ex;
logic                             dmem_xstate;
logic [`CACHE_DATA_WIDTH/8 - 1:0] dmem_strb;
logic [  `CACHE_DATA_WIDTH - 1:0] dmem_wdata;
logic [  `CACHE_DATA_WIDTH - 1:0] dmem_rdata;
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
logic          immu_pa_pre_vld;
logic [ 63: 0] immu_pa_pre;

logic          dcache_bypass;
logic          dmmu_pa_vld;
logic [  1: 0] dmmu_pa_bad;
logic [ 55: 0] dmmu_pa;
logic          dmmu_pa_pre_vld;
logic          dmmu_pa_pre_wr;
logic          dmmu_pa_pre_rd;
logic [ 63: 0] dmmu_pa_pre;

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

logic [ 31: 0] m0_snp_addr;
logic          m0_snp_valid;
logic          m0_snp_ready;

logic [ 31: 0] m1_snp_addr;
logic          m1_snp_valid;
logic          m1_snp_ready;

logic          uart_irq;
logic          spi_irq;

logic [       11: 0] dbg_addr;
logic [`XLEN - 1: 0] dbg_wdata;
logic                dbg_gpr_rd;
logic                dbg_gpr_wr;
logic [`XLEN - 1: 0] dbg_gpr_rdata;
logic                dbg_csr_rd;
logic                dbg_csr_wr;
logic [`XLEN - 1: 0] dbg_csr_rdata;
logic [`XLEN - 1: 0] dbg_pc;
logic [       31: 0] dbg_inst;
logic                dbg_exec;
logic                dbg_halted;
logic                dbg_attach;


`AXI_INTF_DEF(immu, 10)
`AXI_INTF_DEF(dmmu, 10)
`AXI_INTF_DEF(l1ic, 10)
`AXI_INTF_DEF(l1dc, 10)
`AXI_INTF_DEF(ext_s_remap, 9)

`AXI_MST_PORT_TO_INTF(ext_s,         ext_axi);
`AXI_MST_INTF_TO_PORT(ddr_remap_axi, ddr_m);
`APB_MST_PORT_TO_INTF(dbg,           ext_dbg_apb);

apb_intf ext_dbg_apb();
apb_intf dbg_apb();
apb_intf core_apb();
apb_intf cfgreg_apb();
apb_intf intc_apb();
apb_intf peri_apb();
apb_intf dap_apb();
axi_intf#(.ID_WIDTH( 8)) ext_axi();
axi_intf#(.ID_WIDTH( 8)) ext_remap_axi();
axi_intf#(.ID_WIDTH(13)) ddr_axi();
axi_intf#(.ID_WIDTH( 6)) ddr_remap_axi();
axi_intf#(.ID_WIDTH( 9)) dma_axi();
axi_intf#(.ID_WIDTH(10)) immu_axi();
axi_intf#(.ID_WIDTH(10)) dmmu_axi();
axi_intf#(.ID_WIDTH(10)) l1ic_axi();
axi_intf#(.ID_WIDTH(10)) l1dc_axi();
axi_intf#(.ID_WIDTH( 8)) dap_axi();
axi_intf#(.ID_WIDTH( 9)) dbg_axi();
axi_intf#(.ID_WIDTH(10)) peri_axi();
axi_intf#(.ID_WIDTH(10)) peri_scu_axi();

cpu_top u_cpu_top (
    .clk                 ( clk                    ),
    .srstn               ( srstn                  ),
    .xrstn               ( xrstn                  ),
    .cpu_id              ( `XLEN'd0               ),
    .rv64_mode           ( rv64_mode              ),
    .bootvec             ( core_bootvec           ),
    .warm_rst_trigger    ( warm_rst_trigger       ),
    .systime             ( systime                ),

    // mpu csr
    .pmpcfg              ( pmpcfg                 ),
    .pmpaddr             ( pmpaddr                ),
    .pmacfg              ( pmacfg                 ),
    .pmaaddr             ( pmaaddr                ),

    // mmu csr
    .satp_ppn            ( satp_ppn               ),
    .satp_asid           ( satp_asid              ),
    .satp_mode           ( satp_mode              ),
    .prv                 ( prv                    ),
    .sum                 ( sum                    ),
    .mprv                ( mprv                   ),
    .mpp                 ( mpp                    ),

    // TLB control
    .tlb_flush_req       ( tlb_flush_req          ),
    .tlb_flush_all_vaddr ( tlb_flush_all_vaddr    ),
    .tlb_flush_all_asid  ( tlb_flush_all_asid     ),
    .tlb_flush_vaddr     ( tlb_flush_vaddr        ),
    .tlb_flush_asid      ( tlb_flush_asid         ),
   
    // interrupt interface
    .msip                ( msip                   ),
    .mtip                ( mtip                   ),
    .meip                ( meip                   ),
    .seip                ( seip                   ),

    // inst interface
    .imem_en             ( imem_en                ),
    .imem_addr           ( imem_addr              ),
    .imem_rdata          ( imem_rdata             ),
    .imem_bad            ( imem_bad               ),
    .imem_busy           ( imem_busy              ),
    .ic_flush            ( ic_flush               ),

    // data interface
    .dmem_en             ( dmem_en                ),
    .dmem_addr           ( dmem_addr              ),
    .dmem_write          ( dmem_write             ),
    .dmem_ex             ( dmem_ex                ),
    .dmem_strb           ( dmem_strb              ),
    .dmem_wdata          ( dmem_wdata             ),
    .dmem_rdata          ( dmem_rdata             ),
    .dmem_bad            ( dmem_bad               ),
    .dmem_xstate         ( dmem_xstate            ),
    .dmem_busy           ( dmem_busy              ),

    // debug intface
    .dbg_addr            ( dbg_addr               ),
    .dbg_wdata           ( dbg_wdata              ),
    .dbg_gpr_rd          ( dbg_gpr_rd             ),
    .dbg_gpr_wr          ( dbg_gpr_wr             ),
    .dbg_gpr_out         ( dbg_gpr_rdata          ),
    .dbg_csr_rd          ( dbg_csr_rd             ),
    .dbg_csr_wr          ( dbg_csr_wr             ),
    .dbg_csr_out         ( dbg_csr_rdata          ),
    .dbg_pc_out          ( dbg_pc                 ),
    .dbg_exec            ( dbg_exec               ),
    .dbg_inst            ( dbg_inst               ),
    .attach              ( dbg_attach             ),
    .halted              ( dbg_halted             )
);

mmu u_immu (
    .clk                 ( clk                 ),
    .rstn                ( srstn               ),
    
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
    .rv64_mode           ( rv64_mode           ),
    .satp_ppn            ( satp_ppn            ),
    .satp_asid           ( satp_asid           ),
    .satp_mode           ( satp_mode           ),
    .prv                 ( prv                 ),
    .sum                 ( sum                 ),
    .mprv                ( mprv                ),
    .mpp                 ( mpp                 ),

    // virtual address
    .va_valid            ( imem_en             ),
`ifdef RV32
    .va                  ( {{32{imem_addr[31]}}, imem_addr}  ),
`else
    .va                  ( imem_addr           ),
`endif

    // Cache bypass
    .cache_bypass        ( icache_bypass       ),

    // physical address
    .pa_valid            ( immu_pa_vld         ),
    .pa_bad              ( immu_pa_bad         ),
    .pa                  ( immu_pa             ),
    .pa_pre_vld          ( immu_pa_pre_vld     ),
    .pa_pre              ( immu_pa_pre         ),
    
    // AXI interface
    .m_axi_intf          ( immu_axi.master     )
);

mmu u_dmmu (
    .clk                 ( clk                 ),
    .rstn                ( srstn               ),
    
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
    .rv64_mode           ( rv64_mode           ),
    .satp_ppn            ( satp_ppn            ),
    .satp_asid           ( satp_asid           ),
    .satp_mode           ( satp_mode           ),
    .prv                 ( prv                 ),
    .sum                 ( sum                 ),
    .mprv                ( mprv                ),
    .mpp                 ( mpp                 ),

    // virtual address
    .va_valid            ( dmem_en             ),
`ifdef RV32
    .va                  ( {{32{dmem_addr[31]}}, dmem_addr}  ),
`else
    .va                  ( dmem_addr           ),
`endif

    // Cache bypass
    .cache_bypass        ( dcache_bypass       ),

    // physical address
    .pa_valid            ( dmmu_pa_vld         ),
    .pa_bad              ( dmmu_pa_bad         ),
    .pa                  ( dmmu_pa             ),
    .pa_pre_vld          ( dmmu_pa_pre_vld     ),
    .pa_pre_wr           ( dmmu_pa_pre_wr      ),
    .pa_pre_rd           ( dmmu_pa_pre_rd      ),
    .pa_pre              ( dmmu_pa_pre         ),
    
    // AXI interface
    .m_axi_intf          ( dmmu_axi.master     )
);

mpu u_impu (
    .clk      ( clk                        ),
    .rstn     ( srstn                      ),
    .pmpcfg   ( pmpcfg                     ),
    .pmpaddr  ( pmpaddr                    ),
    .pmacfg   ( pmacfg                     ),
    .pmaaddr  ( pmaaddr                    ),
    .paddr    ( immu_pa_pre[0+:`PADDR_LEN] ),

    .pmp_v    ( ipmp_v                     ),
    .pmp_l    ( ipmp_l                     ),
    .pmp_x    ( ipmp_x                     ),
    .pmp_w    ( ipmp_w                     ),
    .pmp_r    ( ipmp_r                     ),
        
    .pma_v    ( ipma_v                     ),
    .pma_l    ( ipma_l                     ),
    .pma_c    ( ipma_c                     ),
    .pma_e    ( ipma_e                     )
        
);

mpu u_dmpu (
    .clk      ( clk                        ),
    .rstn     ( srstn                      ),
    .pmpcfg   ( pmpcfg                     ),
    .pmpaddr  ( pmpaddr                    ),
    .pmacfg   ( pmacfg                     ),
    .pmaaddr  ( pmaaddr                    ),
    .paddr    ( dmmu_pa_pre[0+:`PADDR_LEN] ),

    .pmp_v    ( dpmp_v                     ),
    .pmp_l    ( dpmp_l                     ),
    .pmp_x    ( dpmp_x                     ),
    .pmp_w    ( dpmp_w                     ),
    .pmp_r    ( dpmp_r                     ),
        
    .pma_v    ( dpma_v                     ),
    .pma_l    ( dpma_l                     ),
    .pma_c    ( dpma_c                     ),
    .pma_e    ( dpma_e                     )

);

xmon u_xmon(
    .clk    ( clk         ),
    .rstn   ( rstn        ),

    .ac     ( dmmu_pa_pre_vld & dmem_ex & dmmu_pa_pre_rd),
    .rl     ( dmmu_pa_pre_vld & dmmu_pa_pre_wr),
    .addr   ( dmmu_pa_pre[31:0] ),
    .xstate ( xmon_xstate )
);

l1c u_l1ic (
    .clk         ( clk             ),
    .rstn        ( srstn           ),

    .core_bypass ( icache_bypass   ),
    .core_flush  ( ic_flush        ),
    .core_pa_vld ( immu_pa_vld     ),
    .core_pa_bad ( immu_pa_bad     ),
    .core_paddr  ( immu_pa[31:0]   ),
    .core_req    ( imem_en         ),
    .core_wr     ( 1'b0            ),
    .core_ex     ( 1'b0            ),
    .core_vaddr  ( imem_addr[31:0] ),
    .core_byte   ( {`XLEN/8{1'b1}} ),
    .core_wdata  ( `XLEN'b0        ),
    .core_rdata  ( imem_rdata      ),
    .core_bad    ( imem_bad        ),
    .core_busy   ( imem_busy       ),
    .xmon_xstate ( 1'b0            ),

    .snp_addr    ( m0_snp_addr     ),
    .snp_valid   ( m0_snp_valid    ),
    .snp_ready   ( m0_snp_ready    ),

    .m_axi_intf  ( l1ic_axi.master )
);

l1c u_l1dc (
    .clk         ( clk             ),
    .rstn        ( srstn           ),

    .core_bypass ( dcache_bypass   ),
    .core_flush  ( 1'b0            ),
    .core_pa_vld ( dmmu_pa_vld     ),
    .core_paddr  ( dmmu_pa[31:0]   ),
    .core_pa_bad ( dmmu_pa_bad     ),
    .core_req    ( dmem_en         ),
    .core_wr     ( dmem_write      ),
    .core_ex     ( dmem_ex         ),
    .core_xstate ( dmem_xstate     ),
    .core_vaddr  ( dmem_addr[31:0] ),
    .core_byte   ( dmem_strb       ),
    .core_wdata  ( dmem_wdata      ),
    .core_rdata  ( dmem_rdata      ),
    .core_bad    ( dmem_bad        ),
    .core_busy   ( dmem_busy       ),
    .xmon_xstate ( xmon_xstate     ),

    .snp_addr    ( m1_snp_addr     ),
    .snp_valid   ( m1_snp_valid    ),
    .snp_ready   ( m1_snp_ready    ),

    .m_axi_intf  ( l1dc_axi.master )
);

core_apb_conn u_core_apb_conn (
    .core_apb   ( core_apb.slave    ),
    .cfgreg_apb ( cfgreg_apb.master ),
    .intc_apb   ( intc_apb.master   )
);

cfgreg u_cfgreg (
    .clk          ( clk              ),
    .rstn         ( rstn             ),
    .apb_intf     ( cfgreg_apb.slave ),

    .ddr_offset   ( ddr_offset       ),
    .core_bootvec ( core_bootvec     ),
    .core_rstn    ( core_rstn        )
);

rgu u_rgu (
    .clk              ( clk              ),
    .pwr_rstn         ( core_rstn        ),
    .warm_rst_trigger ( warm_rst_trigger ),
    .xrstn            ( xrstn            ),
    .srstn            ( srstn            )
);

iommu_ext u_iommu_ext (
    .s_axi_intf ( ext_axi.slave        ),
    .m_axi_intf ( ext_remap_axi.master )
);

iommu_ddr u_iommu_ddr (
    .s_axi_intf ( ddr_axi.slave        ),
    .m_axi_intf ( ddr_remap_axi.master ),
    .offset     ( ddr_offset           )
);

dbg_axi_arb_2to1 u_dbg_axi_arb_2to1 (
    .clk         ( clk                 ),
    .rstn        ( rstn                ),

    .s0_axi_intf ( ext_remap_axi.slave ),
    .s1_axi_intf ( dap_axi.slave       ),

    .m_axi_intf  ( dbg_axi.master      )
);

peri_axi_arb_2to1 u_peri_axi_arb_2to1 (
    .clk         ( clk             ),
    .rstn        ( rstn            ),

    .s0_axi_intf ( dma_axi.slave   ),
    .s1_axi_intf ( dbg_axi.slave   ),

    .m_axi_intf  ( peri_axi.master )
);

scu u_scu (
    .clk          ( clk                ),
    .rstn         ( rstn               ),

    .s_axi_intf   ( peri_axi.slave     ),
    .m_axi_intf   ( peri_scu_axi.master),

    .m0_snp_addr  ( m0_snp_addr        ),
    .m0_snp_valid ( m0_snp_valid       ),
    .m0_snp_ready ( m0_snp_ready       ),
                                
    .m1_snp_addr  ( m1_snp_addr        ),
    .m1_snp_valid ( m1_snp_valid       ),
    .m1_snp_ready ( m1_snp_ready       )
);

marb u_marb (
    .clk        ( clk                  ),
    .rstn       ( rstn                 ),


    .s0_axi_intf ( immu_axi.slave      ),
    .s1_axi_intf ( dmmu_axi.slave      ),
    .s2_axi_intf ( l1ic_axi.slave      ),
    .s3_axi_intf ( l1dc_axi.slave      ),
    .s4_axi_intf ( peri_scu_axi.slave  ),

    .m0_cs       ( cs_0                ),
    .m0_we       ( we_0                ),
    .m0_addr     ( addr_0              ),
    .m0_byte     ( byte_0              ),
    .m0_di       ( di_0                ),
    .m0_do       ( do_0                ),
    .m0_busy     ( busy_0              ),

    .m1_cs       ( cs_1                ),
    .m1_we       ( we_1                ),
    .m1_addr     ( addr_1              ),
    .m1_byte     ( byte_1              ),
    .m1_di       ( di_1                ),
    .m1_do       ( do_1                ),
    .m1_busy     ( busy_1              ),

    .m_core_apb  ( core_apb.master     ),
    .m_peri_apb  ( peri_apb.master     ),
    .m_ddr_axi   ( ddr_axi.master      )
);

// assign msip = 1'b0;
// assign mtip = 1'b0;
// assign meip = 1'b0;
// 
// assign core_rstn = rstn;
// assign core_bootvec = 32'b0;
// 
// assign imem_bad  = 2'b0;
// assign imem_busy = 1'b0;
// 
// always_ff @(posedge clk or negedge rstn) begin
//     if (~rstn) begin
//         imem_rdata <= 32'b0;
//     end
//     else begin
//         imem_rdata <= imem_addr[16] ? u_sram_1.memory[imem_addr[15:2]] : u_sram_0.memory[imem_addr[15:2]];
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
//     if (dmem_write & dmem_en) begin
//         if (~dmem_addr[16]) begin
//             if (dmem_strb[0]) u_sram_0.memory[dmem_addr[15:2]][ 0+:8] <= dmem_wdata[ 0+:8];
//             if (dmem_strb[1]) u_sram_0.memory[dmem_addr[15:2]][ 8+:8] <= dmem_wdata[ 8+:8];
//             if (dmem_strb[2]) u_sram_0.memory[dmem_addr[15:2]][16+:8] <= dmem_wdata[16+:8];
//             if (dmem_strb[3]) u_sram_0.memory[dmem_addr[15:2]][24+:8] <= dmem_wdata[24+:8];
//         end
//         else begin
//             if (dmem_strb[0]) u_sram_1.memory[dmem_addr[15:2]][ 0+:8] <= dmem_wdata[ 0+:8];
//             if (dmem_strb[1]) u_sram_1.memory[dmem_addr[15:2]][ 8+:8] <= dmem_wdata[ 8+:8];
//             if (dmem_strb[2]) u_sram_1.memory[dmem_addr[15:2]][16+:8] <= dmem_wdata[16+:8];
//             if (dmem_strb[3]) u_sram_1.memory[dmem_addr[15:2]][24+:8] <= dmem_wdata[24+:8];
//         end
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

/*
sram u_sram_0 (
    .CK   ( mem_ck_0      ),
    .CS   ( cs_0          ),
    .A    ( addr_0[2+:14] ),
    .BYTE ( byte_0        ),
    .WE   ( we_0          ),
    .DI   ( di_0          ),
    .DO   ( do_0          )
);
*/
rom32x2048 u_brom (
    // .CK ( mem_ck_0      ),
    .CK ( clk           ),
    .CS ( cs_0          ),
    .A  ( addr_0[2+:11] ),
    .DO ( do_0          )
);


assign busy_1 = 1'b0;

sram u_sram (
    // .CK   ( mem_ck_1      ),
    .CK   ( clk           ),
    .CS   ( cs_1          ),
    .A    ( addr_1[2+:15] ),
    .BYTE ( byte_1        ),
    .WE   ( we_1          ),
    .DI   ( di_1          ),
    .DO   ( do_1          )
);

assign ints = {
    29'b0,
    spi_irq,
    uart_irq,
    1'b0 // reserve
};

intc u_intc (
    .clk        ( clk            ),
    .rstn       ( srstn          ),
    .s_apb_intf ( intc_apb.slave ),

    .systime    ( systime        ),
    .msip       ( msip           ),
    .mtip       ( mtip           ),
    .meip       ( meip           ),
    .seip       ( seip           ),
    .ints       ( ints           )
);

systimer u_systimer (
    .clk     ( clk     ),
    .rstn    ( rstn    ),
    .systime ( systime )
);

apb_2to1_mux u_dbg_apb_arb_2to1 (
    .clk         ( clk                ),
    .rstn        ( rstn               ),

    .s0_apb_intf ( ext_dbg_apb.slave  ),
    .s1_apb_intf ( dap_apb.slave      ),

    .m_apb_intf  ( dbg_apb.master     )
);

dbgapb u_dbgapb (
    .clk       ( clk           ),
    .rstn      ( srstn         ),
    .apb_intf  ( dbg_apb.slave ),

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

peri u_peri (
    .clk            ( clk            ),
    .rstn           ( rstn           ),
    .s_apb_intf     ( peri_apb.slave ),

    .uart_rx        ( uart_rx        ),
    .uart_tx        ( uart_tx        ),

    .sclk           ( sclk           ),
    .nss            ( nss            ),
    .mosi           ( mosi           ),
    .miso           ( miso           ),
    .m_dma_axi_intf ( dma_axi.master ),

    .uart_irq       ( uart_irq       ),
    .spi_irq        ( spi_irq        )
);

assign trstn = 1'b1;

dap u_dap (
    // clock and reset
    .clk          ( clk            ),
    .rstn         ( rstn           ),

    // DP port
    .tck          ( tck            ),
    .trstn        ( trstn          ),
    .tms          ( tms            ),
    .tdi          ( tdi            ),
    .tdo          ( tdo            ),

    // Other
    .apb_spiden   ( 1'b1           ),
    .apb_deviceen ( 1'b1           ),
    .axi_spiden   ( 1'b1           ),
    .axi_deviceen ( 1'b1           ),

    // APB_AP port
    .m_apb_intf   ( dap_apb.master ),

    // AXI_AP port
    .m_axi_intf   ( dap_axi.master )

);

endmodule
