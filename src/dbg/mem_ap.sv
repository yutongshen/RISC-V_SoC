module mem_ap (
    input               tck,
    input               dbgrstn,

    input               ap_upd,
    input        [31:0] ap_wdata,
    input        [ 7:2] ap_addr,
    input               ap_rnw,
    output logic [31:0] ap_rdata,
    output logic        ap_slverr,
    output logic        ap_busy,

    output logic        tx_tog,
    output logic [31:0] tx_mem_addr,
    output logic        tx_mem_write,
    output logic [31:0] tx_mem_wdata,
    output logic [ 2:0] tx_mem_size,
    output logic [ 6:0] tx_mem_prot,
    output logic        tx_mem_secen,
    input               rx_tog,
    input        [31:0] rx_mem_rdata,
    input               rx_mem_slverr,

    input               fixedsz,
    input               spiden,
    input               deviceen
);

logic [31:0] mem_ap_csw;
logic        mem_ap_csw_dbgswen;
logic [ 6:0] mem_ap_csw_prot;
logic [ 3:0] mem_ap_csw_mode;
logic [ 1:0] mem_ap_csw_addrinc;
logic [ 2:0] mem_ap_csw_size;
logic [31:0] mem_ap_tar;
logic [31:0] mem_ap_drw;
logic [31:0] mem_ap_bd0;
logic [31:0] mem_ap_bd1;
logic [31:0] mem_ap_bd2;
logic [31:0] mem_ap_bd3;

logic        tx_tog_pre;
logic        rx_tog_s1;
logic        rx_tog_s2;
logic        rx_tog_s3;
logic        rx_tog_s4;
logic [ 3:0] cnt;

always_ff @(posedge tck or negedge dbgrstn) begin: reg_rdata
    if (~dbgrstn) begin
        ap_rdata  <= 32'b0;
        ap_slverr <= 1'b0;
    end
    else if (~ap_busy && ap_upd) begin
        ap_rdata  <= ({32{ap_addr == 6'h0 && ap_rnw}} & mem_ap_csw)|
                    ({32{ap_addr == 6'h1 && ap_rnw}} & mem_ap_tar);
        ap_slverr <= 1'b0;
    end
    else if (rx_tog_s3 ^ rx_tog_s4) begin
        ap_rdata  <= rx_mem_rdata;
        ap_slverr <= rx_mem_slverr;
    end
end

always_ff @(posedge tck or negedge dbgrstn) begin: reg_busy
    if (~dbgrstn) begin
        ap_busy <= 1'b0;
    end
    else if (~ap_busy) begin
        if (ap_upd) begin
            ap_busy <= ap_addr == 6'h3 || ap_addr == 6'h4 ||
                       ap_addr == 6'h5 || ap_addr == 6'h6 ||
                       ap_addr == 6'h7;
        end
    end
    else if (rx_tog_s3 ^ rx_tog_s4) begin
        ap_busy <= 1'b0;
    end
end

assign mem_ap_csw = {mem_ap_csw_dbgswen,
                     mem_ap_csw_prot,
                     spiden,
                     11'b0,
                     mem_ap_csw_mode,
                     ap_busy,
                     deviceen,
                     mem_ap_csw_addrinc,
                     1'b0,
                     mem_ap_csw_size};

always_ff @(posedge tck or negedge dbgrstn) begin: reg_csw
    if (~dbgrstn) begin
        mem_ap_csw_dbgswen <= 1'b0;
        mem_ap_csw_prot    <= 7'b0;
        mem_ap_csw_mode    <= 4'b0;
        mem_ap_csw_addrinc <= 2'h0;
        mem_ap_csw_size    <= 3'h2;
    end
    else if (ap_upd && ap_addr == 6'h0) begin
        if (~ap_rnw) begin
            mem_ap_csw_dbgswen <= ap_wdata[31];
            mem_ap_csw_prot    <= ap_wdata[30:24];
            mem_ap_csw_addrinc <= ap_wdata[ 5: 4];
            mem_ap_csw_size    <= ~fixedsz ? ap_wdata[2:0] : mem_ap_csw_size;
        end
    end
end

always_ff @(posedge tck or negedge dbgrstn) begin: reg_tar
    if (~dbgrstn) begin
        mem_ap_tar <= 32'b0;
    end
    else if (ap_upd && ap_addr == 6'h1) begin
        if (~ap_rnw) begin
            mem_ap_tar <= ap_wdata & {{30{1'b1}}, {2{~fixedsz}}};
        end
    end
    else if (ap_upd && ap_addr == 6'h3 && mem_ap_csw_addrinc == 2'h1) begin
        mem_ap_tar <= mem_ap_tar + (32'b1 << mem_ap_csw_size);
    end
end

always_ff @(posedge tck or negedge dbgrstn) begin: reg_drw
    if (~dbgrstn) begin
        mem_ap_drw <= 32'b0;
    end
    else if (ap_upd && ap_addr == 6'h3) begin
        if (~ap_rnw) begin
            mem_ap_drw <= ap_wdata;
        end
    end
end

always_ff @(posedge tck or negedge dbgrstn) begin: reg_bd0
    if (~dbgrstn) begin
        mem_ap_bd0 <= 32'b0;
    end
    else if (ap_upd && ap_addr == 6'h4) begin
        if (~ap_rnw) begin
            mem_ap_bd0 <= ap_wdata;
        end
    end
end

always_ff @(posedge tck or negedge dbgrstn) begin: reg_bd1
    if (~dbgrstn) begin
        mem_ap_bd1 <= 32'b0;
    end
    else if (ap_upd && ap_addr == 6'h5) begin
        if (~ap_rnw) begin
            mem_ap_bd1 <= ap_wdata;
        end
    end
end

always_ff @(posedge tck or negedge dbgrstn) begin: reg_bd2
    if (~dbgrstn) begin
        mem_ap_bd2 <= 32'b0;
    end
    else if (ap_upd && ap_addr == 6'h6) begin
        if (~ap_rnw) begin
            mem_ap_bd2 <= ap_wdata;
        end
    end
end

always_ff @(posedge tck or negedge dbgrstn) begin: reg_bd3
    if (~dbgrstn) begin
        mem_ap_bd3 <= 32'b0;
    end
    else if (ap_upd && ap_addr == 6'h7) begin
        if (~ap_rnw) begin
            mem_ap_bd3 <= ap_wdata;
        end
    end
end

// always_ff @(posedge tck or negedge dbgrstn) begin: reg_tx_tog
//     if (~dbgrstn) begin
//         tx_tog_pre <= 1'b0;
//         tx_tog     <= 1'b0;
//     end
//     else begin
//         tx_tog_pre <= ((ap_addr == 6'h3 || ap_addr == 6'h4 ||
//                         ap_addr == 6'h5 || ap_addr == 6'h6 ||
//                         ap_addr == 6'h7) && ap_upd && ~ap_busy) ^ tx_tog_pre;
//         tx_tog     <= tx_tog_pre;
//     end
// end

always_ff @(posedge tck or negedge dbgrstn) begin: reg_tx_tog
    if (~dbgrstn) begin
        tx_tog <= 1'b0;
    end
    else begin
        tx_tog <= ((ap_addr == 6'h3 || ap_addr == 6'h4 ||
                    ap_addr == 6'h5 || ap_addr == 6'h6 ||
                    ap_addr == 6'h7) && ap_upd && ~ap_busy && deviceen) ^ tx_tog;
    end
end

always_ff @(posedge tck or negedge dbgrstn) begin: reg_tx_req
    if (~dbgrstn) begin
        tx_mem_addr  <= 32'b0;
        tx_mem_write <= 1'b0;
        tx_mem_wdata <= 32'b0;
        tx_mem_size  <= 3'b0;
        tx_mem_prot  <= 7'b0;
        tx_mem_secen <= 1'b0;
    end
    else if (~ap_busy) begin
        if (ap_upd) begin
            tx_mem_addr[31:4]  <= mem_ap_tar[31:4];
            tx_mem_addr[ 3:0]  <= ({4{ap_addr == 6'h3}} & mem_ap_tar[3:0])|
                                  ({4{ap_addr == 6'h4}} & 4'h0           )|
                                  ({4{ap_addr == 6'h4}} & 4'h4           )|
                                  ({4{ap_addr == 6'h4}} & 4'h8           )|
                                  ({4{ap_addr == 6'h4}} & 4'hc           );
            tx_mem_write       <= ~ap_rnw;
            tx_mem_wdata       <= ap_wdata;
            tx_mem_size        <= mem_ap_csw_size;
            tx_mem_prot        <= mem_ap_csw_prot;
            tx_mem_secen       <= spiden;
        end
    end
end

always_ff @(posedge tck or negedge dbgrstn) begin: reg_rx_tog
    if (~dbgrstn) begin
        rx_tog_s1 <= 1'b0;
        rx_tog_s2 <= 1'b0;
        rx_tog_s3 <= 1'b0;
        rx_tog_s4 <= 1'b0;
    end
    else begin
        rx_tog_s1 <= rx_tog;
        rx_tog_s2 <= rx_tog_s1;
        rx_tog_s3 <= rx_tog_s2;
        rx_tog_s4 <= rx_tog_s3;
    end
end

endmodule
