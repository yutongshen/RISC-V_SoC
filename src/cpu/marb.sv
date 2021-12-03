`include "intf_define.h"

module marb (
    input                  clk,
    input                  rstn,

    `AXI_INTF_SLV_DEF(s0, 10),
    `AXI_INTF_SLV_DEF(s1, 10),
    `AXI_INTF_SLV_DEF(s2, 10),
    `AXI_INTF_SLV_DEF(s3, 10),
    `AXI_INTF_SLV_DEF(s4, 10),
    // input                  s0_cs, 
    // input                  s0_we, 
    // input         [ 31: 0] s0_addr,
    // input         [  3: 0] s0_byte,
    // input         [ 31: 0] s0_di,
    // output logic  [ 31: 0] s0_do,
    // output logic           s0_busy,
    // output logic           s0_err,

    // input                  s1_cs, 
    // input                  s1_we, 
    // input         [ 31: 0] s1_addr,
    // input         [  3: 0] s1_byte,
    // input         [ 31: 0] s1_di,
    // output logic  [ 31: 0] s1_do,
    // output logic           s1_busy,
    // output logic           s1_err,

    output logic           m0_cs, 
    output logic           m0_we, 
    output logic  [ 31: 0] m0_addr,
    output logic  [  3: 0] m0_byte,
    output logic  [ 31: 0] m0_di,
    input         [ 31: 0] m0_do,
    input                  m0_busy,

    output logic           m1_cs, 
    output logic           m1_we, 
    output logic  [ 31: 0] m1_addr,
    output logic  [  3: 0] m1_byte,
    output logic  [ 31: 0] m1_di,
    input         [ 31: 0] m1_do,
    input                  m1_busy,

    output logic           m2_psel,
    output logic           m2_penable,
    output logic  [ 31: 0] m2_paddr,
    output logic           m2_pwrite,
    output logic  [  3: 0] m2_pstrb,
    output logic  [ 31: 0] m2_pwdata,
    input         [ 31: 0] m2_prdata,
    input                  m2_pslverr,
    input                  m2_pready,

    output logic           m3_psel,
    output logic           m3_penable,
    output logic  [ 31: 0] m3_paddr,
    output logic           m3_pwrite,
    output logic  [  3: 0] m3_pstrb,
    output logic  [ 31: 0] m3_pwdata,
    input         [ 31: 0] m3_prdata,
    input                  m3_pslverr,
    input                  m3_pready
);

`AXI_INTF_DEF(m0, 13)
`AXI_INTF_DEF(m1, 13)
`AXI_INTF_DEF(m2, 13)
`AXI_INTF_DEF(m3, 13)

// l1c u_l1ic (
//     .clk         ( clk        ),
//     .rstn        ( rstn       ),
// 
//     .core_req    ( s0_cs      ),
//     .core_bypass ( 1'b0       ),
//     .core_wr     ( s0_we      ),
//     .core_addr   ( s0_addr    ),
//     .core_wdata  ( s0_di      ),
//     .core_byte   ( s0_byte    ),
//     .core_rdata  ( s0_do      ),
//     .core_err    ( s0_err     ),
//     .core_busy   ( s0_busy    ),
// 
//     `AXI_INTF_CONNECT(m, m0)
// );
// 
// l1c u_l1dc (
//     .clk         ( clk        ),
//     .rstn        ( rstn       ),
// 
//     .core_req    ( s1_cs      ),
//     .core_bypass ( 1'b0       ),
//     .core_wr     ( s1_we      ),
//     .core_addr   ( s1_addr    ),
//     .core_wdata  ( s1_di      ),
//     .core_byte   ( s1_byte    ),
//     .core_rdata  ( s1_do      ),
//     .core_err    ( s1_err     ),
//     .core_busy   ( s1_busy    ),
// 
//     `AXI_INTF_CONNECT(m, m1)
// );

axi_5to4_biu u_axi_5to4_biu (
    .aclk       ( clk        ),
    .aresetn    ( rstn       ),

    `AXI_INTF_CONNECT(s0, s0),
    `AXI_INTF_CONNECT(s1, s1),
    `AXI_INTF_CONNECT(s2, s2),
    `AXI_INTF_CONNECT(s3, s3),
    `AXI_INTF_CONNECT(s4, s4),
    `AXI_INTF_CONNECT(m0, m0),
    `AXI_INTF_CONNECT(m1, m1),
    `AXI_INTF_CONNECT(m2, m2),
    `AXI_INTF_CONNECT(m3, m3)
);

axi2mem_bridge u_axi2mem0 (
    .aclk      ( clk        ),
    .aresetn   ( rstn       ),
    // AXI slave port
    `AXI_INTF_CONNECT(s, m0),

    // Memory intface master port
    .m_cs      ( m0_cs      ),
    .m_we      ( m0_we      ),
    .m_addr    ( m0_addr    ),
    .m_byte    ( m0_byte    ),
    .m_di      ( m0_di      ),
    .m_do      ( m0_do      ),
    .m_busy    ( m0_busy    )
);

axi2mem_bridge u_axi2mem1 (
    .aclk      ( clk        ),
    .aresetn   ( rstn       ),
    // AXI slave port
    `AXI_INTF_CONNECT(s, m1),

    // Memory intface master port
    .m_cs      ( m1_cs      ),
    .m_we      ( m1_we      ),
    .m_addr    ( m1_addr    ),
    .m_byte    ( m1_byte    ),
    .m_di      ( m1_di      ),
    .m_do      ( m1_do      ),
    .m_busy    ( m1_busy    )
);

axi2apb_bridge u_axi2apb_m2 (
    .aclk      ( clk        ),
    .aresetn   ( rstn       ),
    `AXI_INTF_CONNECT(s, m2),

    // APB master port
    .psel    ( m2_psel    ),
    .penable ( m2_penable ),
    .paddr   ( m2_paddr   ),
    .pwrite  ( m2_pwrite  ),
    .pstrb   ( m2_pstrb   ),
    .pwdata  ( m2_pwdata  ),
    .prdata  ( m2_prdata  ),
    .pslverr ( m2_pslverr ),
    .pready  ( m2_pready  )
);

axi2apb_bridge u_axi2apb_m3 (
    .aclk      ( clk        ),
    .aresetn   ( rstn       ),
    `AXI_INTF_CONNECT(s, m3),

    // APB master port
    .psel    ( m3_psel    ),
    .penable ( m3_penable ),
    .paddr   ( m3_paddr   ),
    .pwrite  ( m3_pwrite  ),
    .pstrb   ( m3_pstrb   ),
    .pwdata  ( m3_pwdata  ),
    .prdata  ( m3_prdata  ),
    .pslverr ( m3_pslverr ),
    .pready  ( m3_pready  )
);

endmodule
