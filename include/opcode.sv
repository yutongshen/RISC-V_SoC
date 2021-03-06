parameter [4:0] OP_LOAD      = 5'b00_000,
                OP_LOAD_FP   = 5'b00_001,
                OP_CUST_0    = 5'b00_010,
                OP_MISC_MEM  = 5'b00_011,
                OP_OP_IMM    = 5'b00_100,
                OP_AUIPC     = 5'b00_101,
                OP_OP_IMM_32 = 5'b00_110,
                OP_STORE     = 5'b01_000,
                OP_STORE_FP  = 5'b01_001,
                OP_CUST_1    = 5'b01_010,
                OP_AMO       = 5'b01_011,
                OP_OP        = 5'b01_100,
                OP_LUI       = 5'b01_101,
                OP_OP_32     = 5'b01_110,
                OP_MADD      = 5'b10_000,
                OP_MSUB      = 5'b10_001,
                OP_NMSUB     = 5'b10_010,
                OP_NMADD     = 5'b10_011,
                OP_OP_FP     = 5'b10_100,
                OP_RSV_0     = 5'b10_101,
                OP_CUST_2    = 5'b10_110,
                OP_BRANCH    = 5'b11_000,
                OP_JALR      = 5'b11_001,
                OP_RSV_1     = 5'b11_010,
                OP_JAL       = 5'b11_011,
                OP_SYSTEM    = 5'b11_100,
                OP_RSV_2     = 5'b11_101,
                OP_CUST_3    = 5'b11_110;

parameter [1:0] OP16_C0      = 2'b00,
                OP16_C1      = 2'b01,
                OP16_C2      = 2'b10;
