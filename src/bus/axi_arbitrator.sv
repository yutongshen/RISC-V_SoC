module axi_arbitrator #(
    parameter SLV_NUM = 2
)(
    input                        aclk,
    input                        aresetn,
    input        [SLV_NUM - 1:0] s_arvalid,
    output logic [SLV_NUM - 1:0] s_arready,
    input        [SLV_NUM - 1:0] s_awvalid,
    output logic [SLV_NUM - 1:0] s_awready,
    input        [SLV_NUM - 1:0] s_wlast,
    input        [SLV_NUM - 1:0] s_wvalid,
    output logic [SLV_NUM - 1:0] s_wready,

    output logic                 m_arvalid,
    input                        m_arready,
    output logic                 m_awvalid,
    input                        m_awready,
    output logic                 m_wlast,
    output logic                 m_wvalid,
    input                        m_wready
);

// AR arbitrator
logic [SLV_NUM - 1:0] ar_prior;
logic [SLV_NUM - 1:0] ar_prior_nxt;

assign ar_prior_nxt = {ar_prior[SLV_NUM - 2:0], ar_prior[SLV_NUM - 1]};

always_ff @(posedge aclk or negedge aresetn) begin
    if (~aresetn) begin
        ar_prior <= {{(SLV_NUM-1){1'b0}}, 1'b1};
    end
    else begin
        if (m_arvalid & m_arready) begin
            ar_prior <= ar_prior_nxt;
        end
    end
end

logic [SLV_NUM - 1:0] ar_grant_matrix [0:SLV_NUM - 1];

always_comb begin
    integer i, j, k;
    for (i = 0; i < SLV_NUM; i = i + 1) begin
        ar_grant_matrix[i] = ar_prior;
        for (j = 1; j < SLV_NUM; j = j + 1) begin
            for (k = 1; k < SLV_NUM; k = k + 1) begin
                ar_grant_matrix[i][(i + j) % SLV_NUM] =  ar_grant_matrix[i][(i + j) % SLV_NUM] &
                                                         ~s_arvalid[(i + k) % SLV_NUM];
            end
        end
    end
end

always_comb begin
    integer i;
    for (i = 0; i < SLV_NUM; i = i + 1) begin
        s_arready[i]  = s_arvalid[i] & (|ar_grant_matrix[i]) & m_arready;
    end
end

assign m_arvalid = |(s_arready & s_arvalid);

// AR arbitrator
logic [SLV_NUM - 1:0] aw_prior;
logic [SLV_NUM - 1:0] aw_prior_nxt;

assign aw_prior_nxt = {aw_prior[SLV_NUM - 2:0], aw_prior[SLV_NUM - 1]};

always_ff @(posedge aclk or negedge aresetn) begin
    if (~aresetn) begin
        aw_prior <= {{(SLV_NUM-1){1'b0}}, 1'b1};
    end
    else begin
        if (m_wlast & m_wvalid & m_wready) begin
            aw_prior <= aw_prior_nxt;
        end
    end
end
logic [SLV_NUM - 1:0] aw_grant_matrix [0:SLV_NUM - 1];

always_comb begin
    integer i, j, k;
    for (i = 0; i < SLV_NUM; i = i + 1) begin
        aw_grant_matrix[i] = aw_prior;
        for (j = 1; j < SLV_NUM; j = j + 1) begin
            for (k = 1; k < SLV_NUM; k = k + 1) begin
                aw_grant_matrix[i][(i + j) % SLV_NUM] =  aw_grant_matrix[i][(i + j) % SLV_NUM] &
                                                         ~s_awvalid[(i + k) % SLV_NUM];
            end
        end
    end
end

logic [SLV_NUM - 1:0] s_wsel;

always_comb begin
    integer i;
    for (i = 0; i < SLV_NUM; i = i + 1) begin
        s_awready[i]  = s_awvalid[i] & (|aw_grant_matrix[i]) & ~|s_wsel & m_awready;
    end
end

assign m_awvalid = |(s_awready & s_awvalid);

always_ff @(posedge aclk or negedge aresetn) begin
    if (~aresetn) begin
        s_wsel <= {SLV_NUM{1'b0}};
    end
    else begin
        if (m_wready & m_wvalid & m_wlast) begin
            s_wsel <= {SLV_NUM{1'b0}};
        end
        else if (~|s_wsel & m_awvalid & m_awready) begin
            s_wsel <= s_awready;
        end
    end
end

assign s_wready = s_wsel & {SLV_NUM{m_wready}};

assign m_wvalid = |(s_wsel & s_wvalid) & m_wready;
assign m_wlast  = |(s_wsel & s_wlast);

endmodule
