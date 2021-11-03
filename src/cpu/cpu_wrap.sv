`include "cpu_define.h"
`include "intf_define.h"

module cpu_wrap (
    input clk,
    input rstn
);

logic                             imem_en;
logic [       `IM_ADDR_LEN - 1:0] imem_addr;
logic [       `IM_DATA_LEN - 1:0] imem_rdata;
logic                             imem_busy;

logic                             dmem_en;
logic [       `IM_ADDR_LEN - 1:0] dmem_addr;
logic                             dmem_write;
logic [(`IM_DATA_LEN >> 3) - 1:0] dmem_strb;
logic [       `IM_DATA_LEN - 1:0] dmem_wdata;
logic [       `IM_DATA_LEN - 1:0] dmem_rdata;
logic                             dmem_busy;
logic [    `SATP_PPN_WIDTH - 1:0] satp_ppn;
logic [   `SATP_ASID_WIDTH - 1:0] satp_asid;
logic [   `SATP_MODE_WIDTH - 1:0] satp_mode;
logic                             mstatus_tvm;
logic [                      1:0] prv;

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
logic [ 55: 0] immu_pa;
logic          dmmu_pa_vld;
logic [ 55: 0] dmmu_pa;

`AXI_INTF_DEF(immu, 10)
`AXI_INTF_DEF(dmmu, 10)
`AXI_INTF_DEF(l1ic, 10)
`AXI_INTF_DEF(l1dc, 10)

cpu_top u_cpu_top (
    .clk         ( clk         ),
    .rstn        ( rstn        ),
    .cpu_id      ( `XLEN'd0    ),

    // mmu csr
    .satp_ppn    ( satp_ppn    ),
    .satp_asid   ( satp_asid   ),
    .satp_mode   ( satp_mode   ),
    .mstatus_tvm ( mstatus_tvm ),
    .prv         ( prv         ),
   
    // interrupt interface
    .msip        ( 1'b0        ),
    .mtip        ( 1'b0        ),
    .meip        ( 1'b0        ),
    // inst interface
    .imem_en     ( imem_en     ),
    .imem_addr   ( imem_addr   ),
    .imem_rdata  ( imem_rdata  ),
    .imem_busy   ( imem_busy   ),
    // data interface
    .dmem_en     ( dmem_en     ),
    .dmem_addr   ( dmem_addr   ),
    .dmem_write  ( dmem_write  ),
    .dmem_strb   ( dmem_strb   ),
    .dmem_wdata  ( dmem_wdata  ),
    .dmem_rdata  ( dmem_rdata  ),
    .dmem_busy   ( dmem_busy   )
);

mmu u_immu(
    .clk         ( clk                ),
    .rstn        ( rstn               ),
    
    // mmu csr
    .satp_ppn    ( satp_ppn           ),
    .satp_asid   ( satp_asid          ),
    .satp_mode   ( satp_mode          ),
    .mstatus_tvm ( mstatus_tvm        ),
    .prv         ( prv                ),

    // virtual address
    .va_valid    ( imem_en            ),
    .va          ( {16'b0, imem_addr} ),

    // physical address
    .pa_valid    ( immu_pa_valid      ),
    .pa          ( immu_pa            ),
    
    // AXI interface
    `AXI_INTF_CONNECT(m, immu)
);

mmu u_dmmu(
    .clk         ( clk                ),
    .rstn        ( rstn               ),
    
    // mmu csr
    .satp_ppn    ( satp_ppn           ),
    .satp_asid   ( satp_asid          ),
    .satp_mode   ( satp_mode          ),
    .mstatus_tvm ( mstatus_tvm        ),
    .prv         ( prv                ),

    // virtual address
    .va_valid    ( dmem_en            ),
    .va          ( {16'b0, dmem_addr} ),

    // physical address
    .pa_valid    ( dmmu_pa_valid      ),
    .pa          ( dmmu_pa            ),
    
    // AXI interface
    `AXI_INTF_CONNECT(m, dmmu)
);

l1c u_l1ic (
    .clk         ( clk           ),
    .rstn        ( rstn          ),

    .core_bypass ( 1'b0          ),
    .core_pa_vld ( immu_pa_vld   ),
    .core_paddr  ( immu_pa[31:0] ),
    .core_req    ( imem_en       ),
    .core_wr     ( 1'b0          ),
    .core_vaddr  ( imem_addr     ),
    .core_byte   ( 4'hf          ),
    .core_wdata  ( 32'b0         ),
    .core_rdata  ( imem_rdata    ),
    .core_err    (               ),
    .core_busy   ( imem_busy     ),

    `AXI_INTF_CONNECT(m, l1ic)
);

l1c u_l1dc (
    .clk         ( clk           ),
    .rstn        ( rstn          ),

    .core_bypass ( 1'b0          ),
    .core_pa_vld ( dmmu_pa_vld   ),
    .core_paddr  ( dmmu_pa[31:0] ),
    .core_req    ( dmem_en       ),
    .core_wr     ( dmem_write    ),
    .core_vaddr  ( dmem_addr     ),
    .core_byte   ( dmem_strb     ),
    .core_wdata  ( dmem_wdata    ),
    .core_rdata  ( dmem_rdata    ),
    .core_err    (               ),
    .core_busy   ( dmem_busy     ),

    `AXI_INTF_CONNECT(m, l1dc)
);

// assign imem_busy = 1'b0;
// assign dmem_busy = 1'b0;
// 
// always_ff @(posedge clk or negedge rstn) begin
//     if (~rstn) begin
//         imem_rdata <= 32'b0;
//     end
//     else if (imem_addr >= 32'h0000_0000 && imem_addr < 32'h0001_0000) begin
//         /*if (imem_en)*/ imem_rdata <= u_sram_0.memory[imem_addr[2+:14]];
//     end
//     else if (imem_addr >= 32'h0001_0000 && imem_addr < 32'h0002_0000) begin
//         if (imem_en) imem_rdata <= u_sram_1.memory[imem_addr[2+:14]];
//     end
// end
// 
// always_ff @(posedge clk or negedge rstn) begin
//     if (~rstn) begin
//         dmem_rdata <= 32'b0;
//     end
//     else if (dmem_addr >= 32'h0000_0000 && dmem_addr < 32'h0001_0000) begin
//         if (dmem_en) begin
//             if (~dmem_write) dmem_rdata <= u_sram_0.memory[dmem_addr[2+:14]];
//             else begin
//                 if (dmem_strb[0]) u_sram_0.memory[dmem_addr[2+:14]][ 7: 0] <= dmem_wdata[ 7: 0];
//                 if (dmem_strb[1]) u_sram_0.memory[dmem_addr[2+:14]][15: 8] <= dmem_wdata[15: 8];
//                 if (dmem_strb[2]) u_sram_0.memory[dmem_addr[2+:14]][23:16] <= dmem_wdata[23:16];
//                 if (dmem_strb[3]) u_sram_0.memory[dmem_addr[2+:14]][31:24] <= dmem_wdata[31:24];
//             end
//         end
//     end
//     else if (dmem_addr >= 32'h0001_0000 && dmem_addr < 32'h0002_0000) begin
//         if (dmem_en) begin
//             if (~dmem_write) dmem_rdata <= u_sram_1.memory[dmem_addr[2+:14]];
//             else begin
//                 if (dmem_strb[0]) u_sram_1.memory[dmem_addr[2+:14]][ 7: 0] <= dmem_wdata[ 7: 0];
//                 if (dmem_strb[1]) u_sram_1.memory[dmem_addr[2+:14]][15: 8] <= dmem_wdata[15: 8];
//                 if (dmem_strb[2]) u_sram_1.memory[dmem_addr[2+:14]][23:16] <= dmem_wdata[23:16];
//                 if (dmem_strb[3]) u_sram_1.memory[dmem_addr[2+:14]][31:24] <= dmem_wdata[31:24];
//             end
//         end
//     end
// end
// 
// initial begin
//     force mem_ck_0 = 1'b0;
//     force mem_ck_1 = 1'b0;
// end



marb u_marb (
    .clk     ( clk        ),
    .rstn    ( rstn       ),

    `AXI_INTF_CONNECT(s0, l1ic),
    `AXI_INTF_CONNECT(s1, l1dc),
    // .s0_cs   ( imem_en    ),
    // .s0_we   ( 1'b0       ),
    // .s0_addr ( imem_addr  ),
    // .s0_byte ( 4'hf       ),
    // .s0_di   ( 32'b0      ),
    // .s0_do   ( imem_rdata ),
    // .s0_err  (            ),
    // .s0_busy ( imem_busy  ),

    // .s1_cs   ( dmem_en    ),
    // .s1_we   ( dmem_write ),
    // .s1_addr ( dmem_addr  ),
    // .s1_byte ( dmem_strb  ),
    // .s1_di   ( dmem_wdata ),
    // .s1_do   ( dmem_rdata ),
    // .s1_err  (            ),
    // .s1_busy ( dmem_busy  ),

    .m0_cs   ( cs_0       ),
    .m0_we   ( we_0       ),
    .m0_addr ( addr_0     ),
    .m0_byte ( byte_0     ),
    .m0_di   ( di_0       ),
    .m0_do   ( do_0       ),
    .m0_busy ( busy_0     ),

    .m1_cs   ( cs_1       ),
    .m1_we   ( we_1       ),
    .m1_addr ( addr_1     ),
    .m1_byte ( byte_1     ),
    .m1_di   ( di_1       ),
    .m1_do   ( do_1       ),
    .m1_busy ( busy_1     )
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

endmodule
