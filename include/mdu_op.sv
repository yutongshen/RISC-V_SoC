parameter [`MDU_OP_LEN - 1:0] MDU_MUL    = `MDU_OP_LEN'b0000,
                              MDU_MULHU  = `MDU_OP_LEN'b0001,
                              MDU_MULHSU = `MDU_OP_LEN'b0011,
                              MDU_MULH   = `MDU_OP_LEN'b0111,
                              MDU_DIVU   = `MDU_OP_LEN'b1000,
                              MDU_REMU   = `MDU_OP_LEN'b1001,
                              MDU_DIV    = `MDU_OP_LEN'b1110,
                              MDU_REM    = `MDU_OP_LEN'b1111;
