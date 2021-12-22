module xmon (
    input               clk,
    input               rstn,

    input               ac,
    input               rl,
    input        [31:0] addr,
    output logic        xstate
);

`define MON_NWAY 4

logic [        `MON_NWAY-1:0] reserv_valid;
logic [                 31:0] reserv_addr [`MON_NWAY];
logic [        `MON_NWAY-1:0] hit;

always_comb begin
    integer i;
    for (i = 0; i < `MON_NWAY; i = i + 1) begin
        hit[i] = reserv_valid[i] && reserv_addr[i] == addr;
    end
end

always_ff @(posedge clk or negedge rstn) begin
    integer i;
    if (~rstn) begin
        for (i = 0; i < `MON_NWAY; i = i + 1) begin
            reserv_valid[i] <= 1'b0;
            reserv_addr [i] <= 32'b0;
        end
    end
    else begin
        if (ac & ~|hit) begin
            reserv_valid[0] <= 1'b1;
            reserv_addr [0] <= addr;
            for (i = 1; i < `MON_NWAY - 1; i = i + 1) begin
                reserv_valid[i] <= reserv_valid[i-1];
                reserv_addr [i] <= reserv_addr [i-1];
            end
        end
        else if (rl & |hit) begin
            for (i = 0; i < `MON_NWAY - 1; i = i + 1) begin
                reserv_addr [i] <= |hit & (~`MON_NWAY'b0 >> (`MON_NWAY - 1 - i)) ?
                                    reserv_addr [i+1] : reserv_addr [i];
            end
            reserv_valid[`MON_NWAY - 1] <= 1'b0;
        end
    end
end

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) xstate <= 1'b0;
    else       xstate <= |hit;
end

endmodule
