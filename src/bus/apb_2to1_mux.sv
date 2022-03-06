module apb_2to1_mux (
    input           clk,
    input           rstn,

    apb_intf.slave  s0_apb_intf,
    apb_intf.slave  s1_apb_intf,

    apb_intf.master m_apb_intf
);

localparam SLV_NUM = 2;

logic [SLV_NUM-1:0] s_lock;
logic [SLV_NUM-1:0] s_sel;

logic        s_psel    [SLV_NUM];
logic        s_penable [SLV_NUM];
logic [31:0] s_paddr   [SLV_NUM];
logic        s_pwrite  [SLV_NUM];
logic [ 3:0] s_pstrb   [SLV_NUM];
logic [ 2:0] s_pprot   [SLV_NUM];
logic [31:0] s_pwdata  [SLV_NUM];
logic [31:0] s_prdata  [SLV_NUM];
logic        s_pslverr [SLV_NUM];
logic        s_pready  [SLV_NUM];

assign s_psel   [0] = s0_apb_intf.psel;
assign s_penable[0] = s0_apb_intf.penable;
assign s_paddr  [0] = s0_apb_intf.paddr;
assign s_pwrite [0] = s0_apb_intf.pwrite;
assign s_pstrb  [0] = s0_apb_intf.pstrb;
assign s_pprot  [0] = s0_apb_intf.pprot;
assign s_pwdata [0] = s0_apb_intf.pwdata;

assign s_psel   [1] = s1_apb_intf.psel;
assign s_penable[1] = s1_apb_intf.penable;
assign s_paddr  [1] = s1_apb_intf.paddr;
assign s_pwrite [1] = s1_apb_intf.pwrite;
assign s_pstrb  [1] = s1_apb_intf.pstrb;
assign s_pprot  [1] = s1_apb_intf.pprot;
assign s_pwdata [1] = s1_apb_intf.pwdata;

assign s0_apb_intf.prdata  = s_prdata [0];
assign s0_apb_intf.pslverr = s_pslverr[0];
assign s0_apb_intf.pready  = s_pready [0];

assign s1_apb_intf.prdata  = s_prdata [1];
assign s1_apb_intf.pslverr = s_pslverr[1];
assign s1_apb_intf.pready  = s_pready [1];

logic [SLV_NUM - 1:0] prior;
logic [SLV_NUM - 1:0] prior_nxt;

assign prior_nxt = {prior[SLV_NUM - 2:0], prior[SLV_NUM - 1]};

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        prior <= {{(SLV_NUM-1){1'b0}}, 1'b1};
    end
    else begin
        if (m_apb_intf.penable & m_apb_intf.pready) begin
            prior <= prior_nxt;
        end
    end
end

logic [SLV_NUM - 1:0] grant_matrix [0:SLV_NUM - 1];

always_comb begin
    integer i, j, k;
    for (i = 0; i < SLV_NUM; i = i + 1) begin
        grant_matrix[i] = prior;
        for (j = 0; j < SLV_NUM - 1; j = j + 1) begin
            for (k = 1; k < SLV_NUM - j; k = k + 1) begin
                grant_matrix[i][(i + j + 1) % SLV_NUM] = grant_matrix[i][(i + j + 1) % SLV_NUM] &
                                                         ~s_psel[(i - k + SLV_NUM) % SLV_NUM];
            end
        end
    end
end

always_comb begin
    integer i;
    for (i = 0; i < SLV_NUM; i = i + 1) begin
        s_sel[i]  = s_psel[i] & (|grant_matrix[i]);
    end
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        s_lock <= {SLV_NUM{1'b0}};
    end
    else begin
        if (m_apb_intf.penable & m_apb_intf.pready) begin
            s_lock <= {SLV_NUM{1'b0}};
        end
        else if (~|s_lock) begin
            s_lock <= s_sel;
        end
    end
end

always_comb begin
    integer i;
    for (i = 0; i < SLV_NUM; i = i + 1) begin
        s_prdata [i] = {32{s_sel[i]}} & m_apb_intf.prdata;
        s_pslverr[i] = { 1{s_sel[i]}} & m_apb_intf.pslverr;
        s_pready [i] = { 1{s_sel[i]}} & m_apb_intf.pready & m_apb_intf.penable;
    end
end

always_comb begin
    integer i;
    m_apb_intf.psel   = 1'b0;
    m_apb_intf.paddr  = 32'b0;
    m_apb_intf.pwrite = 1'b0;
    m_apb_intf.pstrb  = 4'b0;
    m_apb_intf.pprot  = 3'b0;
    m_apb_intf.pwdata = 32'b0;
    for (i = 0; i < SLV_NUM; i = i + 1) begin
        m_apb_intf.psel   = m_apb_intf.psel   | ({ 1{s_sel[i]}} & s_psel  [i]);
        m_apb_intf.paddr  = m_apb_intf.paddr  | ({32{s_sel[i]}} & s_paddr [i]);
        m_apb_intf.pwrite = m_apb_intf.pwrite | ({ 1{s_sel[i]}} & s_pwrite[i]);
        m_apb_intf.pstrb  = m_apb_intf.pstrb  | ({ 4{s_sel[i]}} & s_pstrb [i]);
        m_apb_intf.pprot  = m_apb_intf.pprot  | ({ 3{s_sel[i]}} & s_pprot [i]);
        m_apb_intf.pwdata = m_apb_intf.pwdata | ({32{s_sel[i]}} & s_pwdata[i]);
    end
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        m_apb_intf.penable <= 1'b0;
    end
    else if (~m_apb_intf.penable) begin
        m_apb_intf.penable <= m_apb_intf.psel;
    end
    else begin
        m_apb_intf.penable <= ~m_apb_intf.pready;
    end
end

endmodule
