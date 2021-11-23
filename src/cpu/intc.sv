`include "soc_define.h"

module intc (
    input                        clk,
    input                        rstn,
    input                        psel,
    input                        penable,
    input        [        31: 0] paddr,
    input                        pwrite,
    input        [         3: 0] pstrb,
    input        [        31: 0] pwdata,
    output logic [        31: 0] prdata,
    output logic                 pslverr,
    output logic                 pready,

    output logic [`CPU_NUM-1: 0] msip,
    output logic [`CPU_NUM-1: 0] mtip,
    output logic [`CPU_NUM-1: 0] meip,
    input        [`INT_NUM-1: 0] ints
);

logic                 clint_psel;
logic                 clint_penable;
logic [        31: 0] clint_paddr;
logic                 clint_pwrite;
logic [         3: 0] clint_pstrb;
logic [        31: 0] clint_pwdata;
logic [        31: 0] clint_prdata;
logic                 clint_pslverr;
logic                 clint_pready;

logic                 plic_psel;
logic                 plic_penable;
logic [        31: 0] plic_paddr;
logic                 plic_pwrite;
logic [         3: 0] plic_pstrb;
logic [        31: 0] plic_pwdata;
logic [        31: 0] plic_prdata;
logic                 plic_pslverr;
logic                 plic_pready;

assign clint_psel    = ~paddr[26] & psel;
assign clint_penable = clint_psel & penable;
assign clint_paddr   = paddr;
assign clint_pwrite  = pwrite;
assign clint_pstrb   = pstrb;
assign clint_pwdata  = pwdata;

assign plic_psel     = paddr[26] & psel;
assign plic_penable  = plic_psel & penable;
assign plic_paddr    = paddr;
assign plic_pwrite   = pwrite;
assign plic_pstrb    = pstrb;
assign plic_pwdata   = pwdata;

assign prdata        = clint_prdata  | plic_prdata;
assign pslverr       = clint_pslverr | plic_pslverr;
assign pready        = (clint_psel & clint_pready) | (plic_psel & plic_pready);

clint u_clint (
    .clk     ( clk           ),
    .rstn    ( rstn          ),
    .psel    ( clint_psel    ),
    .penable ( clint_penable ),
    .paddr   ( clint_paddr   ),
    .pwrite  ( clint_pwrite  ),
    .pstrb   ( clint_pstrb   ),
    .pwdata  ( clint_pwdata  ),
    .prdata  ( clint_prdata  ),
    .pslverr ( clint_pslverr ),
    .pready  ( clint_pready  ),

    .msip    ( msip          ),
    .mtip    ( mtip          )
);

plic u_plic(
    .clk     ( clk          ),
    .rstn    ( rstn         ),
    .psel    ( plic_psel    ),
    .penable ( plic_penable ),
    .paddr   ( plic_paddr   ),
    .pwrite  ( plic_pwrite  ),
    .pstrb   ( plic_pstrb   ),
    .pwdata  ( plic_pwdata  ),
    .prdata  ( plic_prdata  ),
    .pslverr ( plic_pslverr ),
    .pready  ( plic_pready  ),

    .meip    ( meip         ),
    .ints    ( ints         )
);

endmodule
