`include "soc_define.h"

module intc (
    input                        clk,
    input                        rstn,
    apb_intf.slave               s_apb_intf,

    input        [        63: 0] systime,
    output logic [`CPU_NUM-1: 0] msip,
    output logic [`CPU_NUM-1: 0] mtip,
    output logic [`CPU_NUM-1: 0] meip,
    output logic [`CPU_NUM-1: 0] seip,
    input        [`INT_NUM-1: 0] ints
);

apb_intf clint_apb();
apb_intf plic_apb();

intc_apb_conn u_intc_apb_conn (
    .intc_apb  ( s_apb_intf       ),
    .clint_apb ( clint_apb.master ),
    .plic_apb  ( plic_apb.master  )
);

clint u_clint (
    .clk      ( clk             ),
    .rstn     ( rstn            ),
    .apb_intf ( clint_apb.slave ),

    .systime  ( systime         ),
    .msip     ( msip            ),
    .mtip     ( mtip            )
);

plic u_plic(
    .clk      ( clk             ),
    .rstn     ( rstn            ),
    .apb_intf ( plic_apb.slave  ),

    .meip     ( meip            ),
    .seip     ( seip            ),
    .ints     ( ints            )
);

endmodule
