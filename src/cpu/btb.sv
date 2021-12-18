module btb (
    input                           clk,
    input                           rstn,
    input                           flush,
    input        [`IM_ADDR_LEN-1:0] pc_in,
    output logic [`IM_ADDR_LEN-1:0] pc_out,
    output logic                    token,
    input                           wr,
    input        [`IM_ADDR_LEN-1:0] addr_in,
    input        [`IM_ADDR_LEN-1:0] target_in
);

`define BTB_ENTRY 4

logic [        `BTB_ENTRY-1:0] valid;
logic [      `IM_ADDR_LEN-1:0] tag    [`BTB_ENTRY];
logic [      `IM_ADDR_LEN-1:0] target [`BTB_ENTRY];
logic [$clog2(`BTB_ENTRY)-1:0] wptr;

always_ff @(posedge clk or negedge rstn) begin
    integer i;
    if (~rstn) begin
        for (i = 0; i < `BTB_ENTRY; i = i + 1) begin
            valid [i] <= 1'b0;
            tag   [i] <= `IM_ADDR_LEN'b0;
            target[i] <= `IM_ADDR_LEN'b0;
        end
        wptr <= {$clog2(`BTB_ENTRY){1'b0}};
    end
    else begin
        if (flush) begin
            for (i = 0; i < `BTB_ENTRY; i = i + 1) begin
                valid [i] <= 1'b0;
            end
        end
        else if (wr) begin
            valid [wptr] <= 1'b1;
            tag   [wptr] <= addr_in;
            target[wptr] <= target_in;
            wptr         <= wptr + {{$clog2(`BTB_ENTRY)-1{1'b0}}, 1'b1};
        end
    end
end

always_comb begin
    integer i;
    pc_out = `IM_ADDR_LEN'b0;
    token  = 1'b0;
    for (i = 0; i < `BTB_ENTRY; i = i + 1) begin
        pc_out = pc_out | ({`IM_ADDR_LEN{valid[i] && tag[i] == pc_in}} & target[i]);
        token  = token  | (valid[i] && tag[i] == pc_in);
    end
end


endmodule
