`ifndef __CSR_DEFINE__
`define __CSR_DEFINE__

`define CSR_WDATA(DEST, RANGE) \
        ((``DEST`` | csr_sdata[RANGE]) & ~csr_cdata[RANGE])

`endif
