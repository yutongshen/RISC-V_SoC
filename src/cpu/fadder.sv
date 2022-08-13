module faddr (
    input                          clk,
    input                          rstn,
    input                          trig,
    input                          len_64,
    input                          flush,
    input        [           63:0] src1,
    input        [           63:0] src2,
    output logic [           63:0] out,
    output logic                   okay
);

logic [10:0] src1_exp;
logic [52:0] src1_frac;
logic [10:0] src2_exp;
logic [54:0] src2_frac;
logic [10:0] src1_src2_exp;
logic [10:0] src2_src1_exp;
logic [54:0] out_tmp;

assign src1_exp = len_64 ? src1[62:52] : {3'b0, src1[30:23]};
assign src2_exp = len_64 ? src2[62:52] : {3'b0, src2[30:23]};

assign src1_frac = len_64 ? ({2'b1, src1[51:0],  1'b0} ^ {55{src1[63]}}):
                            ({2'b1, src1[22:0], 30'b0} ^ {55{src1[31]}});
assign src2_frac = len_64 ? ({2'b1, src2[51:0],  1'b0} ^ {55{src1[63]}}):
                            ({2'b1, src2[22:0], 30'b0} ^ {55{src1[31]}});


assign src1_src2_exp = src1_exp - src2_exp;
assign src1_frac_sft = src1_src2_exp[10]       ?  src1_frac:
                       src1_src2_exp <= 11'd53 ? (src1_frac >> src1_src2_exp):
                                                 {55{src1_frac[54]}};

assign src2_src1_exp = src2_exp - src1_exp;
assign src2_frac_sft = src2_src1_exp[10]       ?  src2_frac:
                       src2_src1_exp <= 11'd53 ? (src2_frac >> src2_src1_exp):
                                                 {55{src2_frac[54]}};
assign out_tmp = src1_frac_sft + src2_frac_sft;

always_ff @(posedge clk or negedge rstn) begin: faddr_pipeline
    if (~rstn) begin
        out_exp <= 11'b0;
        out_tmp <= 55'b0;
    end
    else if (trig) begin
        out_exp <= src1_exp > src2_exp ? src1_exp : src2_exp;
        out_tmp <= src1_frac_sft + src2_frac_sft;
    end
    else begin
        
    end
end

endmodule
