`include "intf_define.h"

module dbg_axi_arb_2to1 (
    input           clk,
    input           rstn,

    axi_intf.slave  s0_axi_intf,
    axi_intf.slave  s1_axi_intf,

    axi_intf.master m_axi_intf
);

`AXI_INTF_DEF(s0,  9)
`AXI_INTF_DEF(s1,  9)
`AXI_INTF_DEF( m, 10)

`AXI_MST_INTF_TO_PORT(s0_axi_intf, s0)
`AXI_MST_INTF_TO_PORT(s1_axi_intf, s1)
`AXI_MST_PORT_TO_INTF(m, m_axi_intf)

axi_2to1_mux u_axi_2to1_mux (
    .aclk       ( clk        ),
    .aresetn    ( rstn       ),

    `AXI_INTF_CONNECT(s0, s0),
    `AXI_INTF_CONNECT(s1, s1),
    `AXI_INTF_CONNECT( m,  m)
);

endmodule
