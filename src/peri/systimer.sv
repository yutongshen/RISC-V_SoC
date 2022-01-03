module systimer (
    input               clk,
    input               rstn,
    output logic [63:0] systime
);

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) systime <= 64'b0;
    else       systime <= systime + 64'b1;
end

endmodule
