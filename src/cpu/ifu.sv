module ifu (
    input                             clk,
    input                             rstn,
    input                             irq_en,
    input        [`IM_ADDR_LEN - 1:0] irq_vec,
    input                             eret_en,
    input        [`IM_ADDR_LEN - 1:0] ret_epc,
    input                             pc_jump_en,
    input        [`IM_ADDR_LEN - 1:0] pc_jump,
    input                             pc_alu_en,
    input        [`IM_ADDR_LEN - 1:0] pc_alu,
    input                             pl_restart_en,
    input        [`IM_ADDR_LEN - 1:0] pl_restart,
    output                            imem_req,
    output logic [`IM_ADDR_LEN - 1:0] imem_addr,
    input        [`IM_DATA_LEN - 1:0] imem_rdata,
    input        [               1:0] imem_bad,
    input                             imem_busy,
    output logic [`IM_ADDR_LEN - 1:0] pc,
    output logic [`IM_DATA_LEN - 1:0] inst,
    output logic                      inst_valid,
    output logic                      misaligned,
    output logic                      page_fault,
    output logic                      xes_fault,
    input                             flush,
    input                             stall
);

logic                      jump;
logic [`IM_ADDR_LEN - 1:0] jump_addr;
logic [`IM_ADDR_LEN - 1:0] pc_nxt;
logic [`IM_ADDR_LEN - 1:0] pc_d1;
logic [`IM_ADDR_LEN - 1:0] pc_d2;
logic                      inst_latch_valid;
logic [`IM_DATA_LEN - 1:0] inst_latch;
logic [               1:0] bad_latch;
logic                      imem_req_latch;
logic                      imem_req_tmp;
logic                      misaligned_tmp;


assign jump      = irq_en | pc_jump_en | pc_alu_en | eret_en | pl_restart_en;
assign jump_addr = pl_restart_en ? pl_restart:
                   eret_en       ? ret_epc:
                   irq_en        ? irq_vec:
                   pc_alu_en     ? pc_alu:
                                   pc_jump;
assign pc_nxt    = jump ? jump_addr : (pc_d1 + `IM_ADDR_LEN'h4);

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        pc_d1 <= {`IM_ADDR_LEN{1'b0}};
    end
    else if (imem_req | jump) begin
        pc_d1 <= {pc_nxt[`IM_ADDR_LEN - 1:1], 1'b0};
    end
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        pc_d2 <= {`IM_ADDR_LEN{1'b0}};
    end
    else if (jump) begin
        pc_d2 <= {jump_addr[`IM_ADDR_LEN - 1:1], 1'b0};
    end
    else if (inst_valid) begin
        pc_d2 <= pc_d1;
    end
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        inst_latch_valid <= 1'b0;
    end
    else if (inst_valid | jump) begin
        inst_latch_valid <= 1'b0;
    end
    else if (imem_req_latch & stall & ~imem_busy) begin
        inst_latch_valid <= 1'b1;
    end
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        inst_latch <= `IM_DATA_LEN'b0;
    end
    else if (~imem_busy & ~inst_latch_valid ) begin
        inst_latch <= imem_rdata;
    end
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        bad_latch <= 2'b0;
    end
    else if (~imem_busy & ~inst_latch_valid ) begin
        bad_latch <= imem_bad;
    end
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        imem_req_latch <= 1'b0;
    end
    else if (imem_req) begin
        imem_req_latch <= 1'b1;
    end
    else if (inst_valid | jump) begin
        imem_req_latch <= 1'b0;
    end
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        misaligned <= 1'b0;
    end
    else if (imem_req_tmp) begin
        misaligned <= misaligned_tmp;
    end
    else if (inst_valid | jump) begin
        misaligned <= 1'b0;
    end
end

assign misaligned_tmp = |pc_d1[1];

assign imem_addr      = pc_d1;
assign imem_req_tmp   = ~imem_busy & ~jump & (inst_valid | ~imem_req_latch);
assign imem_req       = imem_req_tmp & ~misaligned_tmp;

assign inst_valid = ((imem_req_latch & ~imem_busy) | inst_latch_valid | misaligned) & ~stall & ~jump;
assign inst       = inst_latch_valid ? inst_latch: 
                    ~imem_busy       ? imem_rdata:
                                       `IM_DATA_LEN'b0;
assign {xes_fault, page_fault} = inst_latch_valid ? bad_latch: 
                                 ~imem_busy       ? imem_bad:
                                                    2'b0;
assign pc         = pc_d2;

endmodule
