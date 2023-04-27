module mac_crc32 (
    input              clk,
    input              rstn,
    input              ctrl,
    input        [1:0] d_in,
    output logic [1:0] d_out,
    output logic       flag
);

parameter [31:0] CRC32_POLY = 32'h04c1_1db7;
parameter [31:0] CRC32_CHK  = 32'hc704_dd7b;

logic [ 1:0] d_int;
logic [31:0] crc;

assign d_int = d_in ^ {crc[30], crc[31]};

always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) crc <= 32'hffff_ffff;
    else begin
        if (!ctrl) crc <= {crc[29:0], 2'b11};
        else       crc <= {crc[29:0], 2'b0} ^ ({32{d_int[0]}} & {CRC32_POLY[30:0],1'b0})
                                            ^ ({32{d_int[1]}} &  CRC32_POLY);
    end
end

assign d_out = ~{crc[30], crc[31]};
assign flag  = crc == CRC32_CHK;

endmodule
