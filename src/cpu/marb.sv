`include "intf_define.h"

module marb (
    input                  clk,
    input                  rstn,

    axi_intf.slave         s0_axi_intf,
    axi_intf.slave         s1_axi_intf,
    axi_intf.slave         s2_axi_intf,
    axi_intf.slave         s3_axi_intf,
    axi_intf.slave         s4_axi_intf,

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

    apb_intf.master        m_core_apb,
    apb_intf.master        m_peri_apb,
    axi_intf.master        m_ddr_axi
);

`AXI_INTF_DEF(s0, 10)
`AXI_INTF_DEF(s1, 10)
`AXI_INTF_DEF(s2, 10)
`AXI_INTF_DEF(s3, 10)
`AXI_INTF_DEF(s4, 10)
`AXI_INTF_DEF(m0, 13)
`AXI_INTF_DEF(m1, 13)
`AXI_INTF_DEF(m2, 13)
`AXI_INTF_DEF(m3, 13)
`AXI_INTF_DEF(m4, 13)

`AXI_MST_INTF_TO_PORT(s0_axi_intf, s0)
`AXI_MST_INTF_TO_PORT(s1_axi_intf, s1)
`AXI_MST_INTF_TO_PORT(s2_axi_intf, s2)
`AXI_MST_INTF_TO_PORT(s3_axi_intf, s3)
`AXI_MST_INTF_TO_PORT(s4_axi_intf, s4)
`AXI_MST_PORT_TO_INTF(m0, m0_axi)
`AXI_MST_PORT_TO_INTF(m1, m1_axi)
`AXI_MST_PORT_TO_INTF(m2, m2_axi)
`AXI_MST_PORT_TO_INTF(m3, m3_axi)
`AXI_MST_PORT_TO_INTF(m4, m_ddr_axi)

axi_intf#(.ID_WIDTH(13)) m0_axi();
axi_intf#(.ID_WIDTH(13)) m1_axi();
axi_intf#(.ID_WIDTH(13)) m2_axi();
axi_intf#(.ID_WIDTH(13)) m3_axi();

axi_5to5_biu u_axi_5to5_biu (
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
    `AXI_INTF_CONNECT(m3, m3),
    `AXI_INTF_CONNECT(m4, m4)
);

axi2mem_bridge u_axi2mem0 (
    .aclk       ( clk           ),
    .aresetn    ( rstn          ),
    // AXI slave port
    .s_axi_intf ( m0_axi.slave  ),

    // Memory intface master port
    .m_cs       ( m0_cs         ),
    .m_we       ( m0_we         ),
    .m_addr     ( m0_addr       ),
    .m_byte     ( m0_byte       ),
    .m_di       ( m0_di         ),
    .m_do       ( m0_do         ),
    .m_busy     ( m0_busy       )
);

axi2mem_bridge u_axi2mem1 (
    .aclk       ( clk           ),
    .aresetn    ( rstn          ),
    // AXI slave port
    .s_axi_intf ( m1_axi.slave  ),

    // Memory intface master port
    .m_cs       ( m1_cs         ),
    .m_we       ( m1_we         ),
    .m_addr     ( m1_addr       ),
    .m_byte     ( m1_byte       ),
    .m_di       ( m1_di         ),
    .m_do       ( m1_do         ),
    .m_busy     ( m1_busy       )
);

axi2apb_bridge u_axi2apb_m2 (
    .aclk       ( clk             ),
    .aresetn    ( rstn            ),
    .s_axi_intf ( m2_axi.slave    ),

    // APB master port
    .m_apb_intf ( m_core_apb      )
);

axi2apb_bridge u_axi2apb_m3 (
    .aclk       ( clk             ),
    .aresetn    ( rstn            ),
    .s_axi_intf ( m3_axi.slave    ),

    // APB master port
    .m_apb_intf ( m_peri_apb      )
);

endmodule
