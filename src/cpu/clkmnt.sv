module clkmnt (
    input        clk_free,
    input        rstn,
    input        wfi,
    input        wakeup,
    output logic clk_ret,
    output logic sleep
);

always_ff @(posedge clk_free or negedge rstn) begin
    if (~rstn)       sleep <= 1'b0;
    else if (wakeup) sleep <= 1'b0;
    else if (wfi)    sleep <= 1'b1;
end

CG u_cg(
    .CK   ( clk_free ),
    .EN   ( ~sleep   ),
    .CKEN ( clk_ret  )
);


endmodule
