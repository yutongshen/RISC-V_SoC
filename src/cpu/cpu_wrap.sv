`include "cpu_define.h"
`include "intf_define.h"

module cpu_wrap (
    input clk,
    input rstn
);

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

logic                             ipmp_v;
logic                             ipmp_l;
logic                             ipmp_x;
logic                             ipmp_w;
logic                             ipmp_r;

logic                             dpmp_v;
logic                             dpmp_l;
logic                             dpmp_x;
logic                             dpmp_w;
logic                             dpmp_r;

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

logic          immu_pa_vld;
logic [  1: 0] immu_pa_bad;
logic [ 55: 0] immu_pa;
logic [ 55: 0] immu_pa_pre;
logic          dmmu_pa_vld;
logic [  1: 0] dmmu_pa_bad;
logic [ 55: 0] dmmu_pa;
logic [ 55: 0] dmmu_pa_pre;

logic           intc_psel;
logic           intc_penable;
logic  [ 31: 0] intc_paddr;
logic           intc_pwrite;
logic  [  3: 0] intc_pstrb;
logic  [ 31: 0] intc_pwdata;
logic  [ 31: 0] intc_prdata;
logic           intc_pslverr;
logic           intc_pready;

logic           uart_psel;
logic           uart_penable;
logic  [ 31: 0] uart_paddr;
logic           uart_pwrite;
logic  [  3: 0] uart_pstrb;
logic  [ 31: 0] uart_pwdata;
logic  [ 31: 0] uart_prdata;
logic           uart_pslverr;
logic           uart_pready;


`AXI_INTF_DEF(immu, 10)
`AXI_INTF_DEF(dmmu, 10)
`AXI_INTF_DEF(l1ic, 10)
`AXI_INTF_DEF(l1dc, 10)

cpu_top u_cpu_top (
    .clk                 ( clk                 ),
    .rstn                ( rstn                ),
    .cpu_id              ( `XLEN'd0            ),

    // mpu csr
    .pmpcfg              ( pmpcfg              ),
    .pmpaddr             ( pmpaddr             ),

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
    .dmem_busy           ( dmem_busy           )
);

mmu u_immu(
    .clk                 ( clk                 ),
    .rstn                ( rstn                ),
    
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
    .rstn                ( rstn                ),
    
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
    .rstn     ( rstn        ),
    .pmpcfg   ( pmpcfg      ),
    .pmpaddr  ( pmpaddr     ),
    .paddr    ( immu_pa_pre ),

    .pmp_v    ( ipmp_v      ),
    .pmp_l    ( ipmp_l      ),
    .pmp_x    ( ipmp_x      ),
    .pmp_w    ( ipmp_w      ),
    .pmp_r    ( ipmp_r      )
        
);

mpu u_dmpu (
    .clk      ( clk         ),
    .rstn     ( rstn        ),
    .pmpcfg   ( pmpcfg      ),
    .pmpaddr  ( pmpaddr     ),
    .paddr    ( dmmu_pa_pre ),

    .pmp_v    ( dpmp_v      ),
    .pmp_l    ( dpmp_l      ),
    .pmp_x    ( dpmp_x      ),
    .pmp_w    ( dpmp_w      ),
    .pmp_r    ( dpmp_r      )
        
);

l1c u_l1ic (
    .clk         ( clk           ),
    .rstn        ( rstn          ),

    .core_bypass ( 1'b0          ),
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
    .rstn        ( rstn          ),

    .core_bypass ( 1'b1          ),
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

intc u_intc(
    .clk    ( clk          ),
    .rstn   ( rstn         ),
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
    .ints   ( 32'b0        )
);

marb u_marb (
    .clk        ( clk          ),
    .rstn       ( rstn         ),

    `AXI_INTF_CONNECT(s0, immu),
    `AXI_INTF_CONNECT(s1, dmmu),
    `AXI_INTF_CONNECT(s2, l1ic),
    `AXI_INTF_CONNECT(s3, l1dc),

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

    .m2_psel    ( intc_psel    ),
    .m2_penable ( intc_penable ),
    .m2_paddr   ( intc_paddr   ),
    .m2_pwrite  ( intc_pwrite  ),
    .m2_pstrb   ( intc_pstrb   ),
    .m2_pwdata  ( intc_pwdata  ),
    .m2_prdata  ( intc_prdata  ),
    .m2_pslverr ( intc_pslverr ),
    .m2_pready  ( intc_pready  ),

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

sram u_sram_0 (
    .CK   ( mem_ck_0      ),
    .CS   ( cs_0          ),
    .A    ( addr_0[2+:14] ),
    .BYTE ( byte_0        ),
    .WE   ( we_0          ),
    .DI   ( di_0          ),
    .DO   ( do_0          )
);

assign busy_0 = 1'b0;

sram u_sram_1 (
    .CK   ( mem_ck_1      ),
    .CS   ( cs_1          ),
    .A    ( addr_1[2+:14] ),
    .BYTE ( byte_1        ),
    .WE   ( we_1          ),
    .DI   ( di_1          ),
    .DO   ( do_1          )
);

assign busy_1 = 1'b0;

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

    .uart_rx ( 1'b0 ),
    .uart_tx (  )
);
endmodule
