`include "cpu_define.h"

function string regs_name;
input [4:0] reg_id;

casex (reg_id)
    5'd0 :   return "zero";
    5'd1 :   return "ra";
    5'd2 :   return "sp";
    5'd3 :   return "gp";
    5'd4 :   return "tp";
    5'd5 :   return "t0";
    5'd6 :   return "t1";
    5'd7 :   return "t2";
    5'd8 :   return "s0";
    // 5'd8 :   return "fp";
    5'd9 :   return "s1";
    5'd10:   return "a0";
    5'd11:   return "a1";
    5'd12:   return "a2";
    5'd13:   return "a3";
    5'd14:   return "a4";
    5'd15:   return "a5";
    5'd16:   return "a6";
    5'd17:   return "a7";
    5'd18:   return "s2";
    5'd19:   return "s3";
    5'd20:   return "s4";
    5'd21:   return "s5";
    5'd22:   return "s6";
    5'd23:   return "s7";
    5'd24:   return "s8";
    5'd25:   return "s9";
    5'd26:   return "s10";
    5'd27:   return "s11";
    5'd28:   return "t3";
    5'd29:   return "t4";
    5'd30:   return "t5";
    5'd31:   return "t6";
    default: return "unknown reg";
endcase

endfunction

function string csr_name;
input [11:0] csr_addr;
string csr_id;
$sformat(csr_id, "0x%0x", csr_addr);

casex (csr_addr)
    `CSR_USTATUS_ADDR       : return "ustatus";       
    `CSR_UIE_ADDR           : return "uie";           
    `CSR_UTVEC_ADDR         : return "utvec";         
    `CSR_USCRATCH_ADDR      : return "uscratch";      
    `CSR_UEPC_ADDR          : return "uepc";          
    `CSR_UCAUSE_ADDR        : return "ucause";        
    `CSR_UTVAL_ADDR         : return "utval";         
    `CSR_UIP_ADDR           : return "uip";           
    `CSR_FFLAGS_ADDR        : return "fflags";        
    `CSR_FRM_ADDR           : return "frm";           
    `CSR_FCSR_ADDR          : return "fcsr";          
    `CSR_CYCLE_ADDR         : return "cycle";         
    `CSR_TIME_ADDR          : return "time";          
    `CSR_INSTRET_ADDR       : return "instret";       
    `CSR_HPMCOUNTER3_ADDR   : return "hpmcounter3";   
    `CSR_HPMCOUNTER4_ADDR   : return "hpmcounter4";   
    `CSR_HPMCOUNTER5_ADDR   : return "hpmcounter5";   
    `CSR_HPMCOUNTER6_ADDR   : return "hpmcounter6";   
    `CSR_HPMCOUNTER7_ADDR   : return "hpmcounter7";   
    `CSR_HPMCOUNTER8_ADDR   : return "hpmcounter8";   
    `CSR_HPMCOUNTER9_ADDR   : return "hpmcounter9";   
    `CSR_HPMCOUNTER10_ADDR  : return "hpmcounter10";  
    `CSR_HPMCOUNTER11_ADDR  : return "hpmcounter11";  
    `CSR_HPMCOUNTER12_ADDR  : return "hpmcounter12";  
    `CSR_HPMCOUNTER13_ADDR  : return "hpmcounter13";  
    `CSR_HPMCOUNTER14_ADDR  : return "hpmcounter14";  
    `CSR_HPMCOUNTER15_ADDR  : return "hpmcounter15";  
    `CSR_HPMCOUNTER16_ADDR  : return "hpmcounter16";  
    `CSR_HPMCOUNTER17_ADDR  : return "hpmcounter17";  
    `CSR_HPMCOUNTER18_ADDR  : return "hpmcounter18";  
    `CSR_HPMCOUNTER19_ADDR  : return "hpmcounter19";  
    `CSR_HPMCOUNTER20_ADDR  : return "hpmcounter20";  
    `CSR_HPMCOUNTER21_ADDR  : return "hpmcounter21";  
    `CSR_HPMCOUNTER22_ADDR  : return "hpmcounter22";  
    `CSR_HPMCOUNTER23_ADDR  : return "hpmcounter23";  
    `CSR_HPMCOUNTER24_ADDR  : return "hpmcounter24";  
    `CSR_HPMCOUNTER25_ADDR  : return "hpmcounter25";  
    `CSR_HPMCOUNTER26_ADDR  : return "hpmcounter26";  
    `CSR_HPMCOUNTER27_ADDR  : return "hpmcounter27";  
    `CSR_HPMCOUNTER28_ADDR  : return "hpmcounter28";  
    `CSR_HPMCOUNTER29_ADDR  : return "hpmcounter29";  
    `CSR_HPMCOUNTER30_ADDR  : return "hpmcounter30";  
    `CSR_HPMCOUNTER31_ADDR  : return "hpmcounter31";  
    `CSR_CYCLEH_ADDR        : return "cycleh";        
    `CSR_TIMEH_ADDR         : return "timeh";         
    `CSR_INSTRETH_ADDR      : return "instreth";      
    `CSR_HPMCOUNTER3H_ADDR  : return "hpmcounter3h";  
    `CSR_HPMCOUNTER4H_ADDR  : return "hpmcounter4h";  
    `CSR_HPMCOUNTER5H_ADDR  : return "hpmcounter5h";  
    `CSR_HPMCOUNTER6H_ADDR  : return "hpmcounter6h";  
    `CSR_HPMCOUNTER7H_ADDR  : return "hpmcounter7h";  
    `CSR_HPMCOUNTER8H_ADDR  : return "hpmcounter8h";  
    `CSR_HPMCOUNTER9H_ADDR  : return "hpmcounter9h";  
    `CSR_HPMCOUNTER10H_ADDR : return "hpmcounter10h"; 
    `CSR_HPMCOUNTER11H_ADDR : return "hpmcounter11h"; 
    `CSR_HPMCOUNTER12H_ADDR : return "hpmcounter12h"; 
    `CSR_HPMCOUNTER13H_ADDR : return "hpmcounter13h"; 
    `CSR_HPMCOUNTER14H_ADDR : return "hpmcounter14h"; 
    `CSR_HPMCOUNTER15H_ADDR : return "hpmcounter15h"; 
    `CSR_HPMCOUNTER16H_ADDR : return "hpmcounter16h"; 
    `CSR_HPMCOUNTER17H_ADDR : return "hpmcounter17h"; 
    `CSR_HPMCOUNTER18H_ADDR : return "hpmcounter18h"; 
    `CSR_HPMCOUNTER19H_ADDR : return "hpmcounter19h"; 
    `CSR_HPMCOUNTER20H_ADDR : return "hpmcounter20h"; 
    `CSR_HPMCOUNTER21H_ADDR : return "hpmcounter21h"; 
    `CSR_HPMCOUNTER22H_ADDR : return "hpmcounter22h"; 
    `CSR_HPMCOUNTER23H_ADDR : return "hpmcounter23h"; 
    `CSR_HPMCOUNTER24H_ADDR : return "hpmcounter24h"; 
    `CSR_HPMCOUNTER25H_ADDR : return "hpmcounter25h"; 
    `CSR_HPMCOUNTER26H_ADDR : return "hpmcounter26h"; 
    `CSR_HPMCOUNTER27H_ADDR : return "hpmcounter27h"; 
    `CSR_HPMCOUNTER28H_ADDR : return "hpmcounter28h"; 
    `CSR_HPMCOUNTER29H_ADDR : return "hpmcounter29h"; 
    `CSR_HPMCOUNTER30H_ADDR : return "hpmcounter30h"; 
    `CSR_HPMCOUNTER31H_ADDR : return "hpmcounter31h"; 
                                                     
    `CSR_SSTATUS_ADDR       : return "sstatus";       
    `CSR_SEDELEG_ADDR       : return "sedeleg";       
    `CSR_SIDELEG_ADDR       : return "sideleg";       
    `CSR_SIE_ADDR           : return "sie";           
    `CSR_STVEC_ADDR         : return "stvec";         
    `CSR_SCOUNTEREN_ADDR    : return "scounteren";    
    `CSR_SSCRATCH_ADDR      : return "sscratch";      
    `CSR_SEPC_ADDR          : return "sepc";          
    `CSR_SCAUSE_ADDR        : return "scause";        
    `CSR_STVAL_ADDR         : return "stval";         
    `CSR_SIP_ADDR           : return "sip";           
    `CSR_SATP_ADDR          : return "satp";          
                                                     
    `CSR_MVENDORID_ADDR     : return "mvendorid";     
    `CSR_MARCHID_ADDR       : return "marchid";       
    `CSR_MIMPID_ADDR        : return "mimpid";        
    `CSR_MHARTID_ADDR       : return "mhartid";       
    `CSR_MSTATUS_ADDR       : return "mstatus";       
    `CSR_MISA_ADDR          : return "misa";          
    `CSR_MEDELEG_ADDR       : return "medeleg";       
    `CSR_MIDELEG_ADDR       : return "mideleg";       
    `CSR_MIE_ADDR           : return "mie";           
    `CSR_MTVEC_ADDR         : return "mtvec";         
    `CSR_MCOUNTEREN_ADDR    : return "mcounteren";    
    `CSR_MSCRATCH_ADDR      : return "mscratch";      
    `CSR_MEPC_ADDR          : return "mepc";          
    `CSR_MCAUSE_ADDR        : return "mcause";        
    `CSR_MTVAL_ADDR         : return "mtval";         
    `CSR_MIP_ADDR           : return "mip";           
    `CSR_PMPCFG0_ADDR       : return "pmpcfg0";       
    `CSR_PMPCFG1_ADDR       : return "pmpcfg1";       
    `CSR_PMPCFG2_ADDR       : return "pmpcfg2";       
    `CSR_PMPCFG3_ADDR       : return "pmpcfg3";       
    `CSR_PMPADDR0_ADDR      : return "pmpaddr0";      
    `CSR_PMPADDR1_ADDR      : return "pmpaddr1";      
    `CSR_PMPADDR2_ADDR      : return "pmpaddr2";      
    `CSR_PMPADDR3_ADDR      : return "pmpaddr3";      
    `CSR_PMPADDR4_ADDR      : return "pmpaddr4";      
    `CSR_PMPADDR5_ADDR      : return "pmpaddr5";      
    `CSR_PMPADDR6_ADDR      : return "pmpaddr6";      
    `CSR_PMPADDR7_ADDR      : return "pmpaddr7";      
    `CSR_PMPADDR8_ADDR      : return "pmpaddr8";      
    `CSR_PMPADDR9_ADDR      : return "pmpaddr9";      
    `CSR_PMPADDR10_ADDR     : return "pmpaddr10";     
    `CSR_PMPADDR11_ADDR     : return "pmpaddr11";     
    `CSR_PMPADDR12_ADDR     : return "pmpaddr12";     
    `CSR_PMPADDR13_ADDR     : return "pmpaddr13";     
    `CSR_PMPADDR14_ADDR     : return "pmpaddr14";     
    `CSR_PMPADDR15_ADDR     : return "pmpaddr15";     
    `CSR_PMACFG0_ADDR       : return "pmacfg0";       
    `CSR_PMACFG1_ADDR       : return "pmacfg1";       
    `CSR_PMACFG2_ADDR       : return "pmacfg2";       
    `CSR_PMACFG3_ADDR       : return "pmacfg3";       
    `CSR_PMAADDR0_ADDR      : return "pmaaddr0";      
    `CSR_PMAADDR1_ADDR      : return "pmaaddr1";      
    `CSR_PMAADDR2_ADDR      : return "pmaaddr2";      
    `CSR_PMAADDR3_ADDR      : return "pmaaddr3";      
    `CSR_PMAADDR4_ADDR      : return "pmaaddr4";      
    `CSR_PMAADDR5_ADDR      : return "pmaaddr5";      
    `CSR_PMAADDR6_ADDR      : return "pmaaddr6";      
    `CSR_PMAADDR7_ADDR      : return "pmaaddr7";      
    `CSR_PMAADDR8_ADDR      : return "pmaaddr8";      
    `CSR_PMAADDR9_ADDR      : return "pmaaddr9";      
    `CSR_PMAADDR10_ADDR     : return "pmaaddr10";     
    `CSR_PMAADDR11_ADDR     : return "pmaaddr11";     
    `CSR_PMAADDR12_ADDR     : return "pmaaddr12";     
    `CSR_PMAADDR13_ADDR     : return "pmaaddr13";     
    `CSR_PMAADDR14_ADDR     : return "pmaaddr14";     
    `CSR_PMAADDR15_ADDR     : return "pmaaddr15";     
    `CSR_MCYCLE_ADDR        : return "mcycle";        
    `CSR_MINSTRET_ADDR      : return "minstret";      
    `CSR_MHPMCOUNTER3_ADDR  : return "mhpmcounter3";  
    `CSR_MHPMCOUNTER4_ADDR  : return "mhpmcounter4";  
    `CSR_MHPMCOUNTER5_ADDR  : return "mhpmcounter5";  
    `CSR_MHPMCOUNTER6_ADDR  : return "mhpmcounter6";  
    `CSR_MHPMCOUNTER7_ADDR  : return "mhpmcounter7";  
    `CSR_MHPMCOUNTER8_ADDR  : return "mhpmcounter8";  
    `CSR_MHPMCOUNTER9_ADDR  : return "mhpmcounter9";  
    `CSR_MHPMCOUNTER10_ADDR : return "mhpmcounter10"; 
    `CSR_MHPMCOUNTER11_ADDR : return "mhpmcounter11"; 
    `CSR_MHPMCOUNTER12_ADDR : return "mhpmcounter12"; 
    `CSR_MHPMCOUNTER13_ADDR : return "mhpmcounter13"; 
    `CSR_MHPMCOUNTER14_ADDR : return "mhpmcounter14"; 
    `CSR_MHPMCOUNTER15_ADDR : return "mhpmcounter15"; 
    `CSR_MHPMCOUNTER16_ADDR : return "mhpmcounter16"; 
    `CSR_MHPMCOUNTER17_ADDR : return "mhpmcounter17"; 
    `CSR_MHPMCOUNTER18_ADDR : return "mhpmcounter18"; 
    `CSR_MHPMCOUNTER19_ADDR : return "mhpmcounter19"; 
    `CSR_MHPMCOUNTER20_ADDR : return "mhpmcounter20"; 
    `CSR_MHPMCOUNTER21_ADDR : return "mhpmcounter21"; 
    `CSR_MHPMCOUNTER22_ADDR : return "mhpmcounter22"; 
    `CSR_MHPMCOUNTER23_ADDR : return "mhpmcounter23"; 
    `CSR_MHPMCOUNTER24_ADDR : return "mhpmcounter24"; 
    `CSR_MHPMCOUNTER25_ADDR : return "mhpmcounter25"; 
    `CSR_MHPMCOUNTER26_ADDR : return "mhpmcounter26"; 
    `CSR_MHPMCOUNTER27_ADDR : return "mhpmcounter27"; 
    `CSR_MHPMCOUNTER28_ADDR : return "mhpmcounter28"; 
    `CSR_MHPMCOUNTER29_ADDR : return "mhpmcounter29"; 
    `CSR_MHPMCOUNTER30_ADDR : return "mhpmcounter30"; 
    `CSR_MHPMCOUNTER31_ADDR : return "mhpmcounter31"; 
    `CSR_MCYCLEH_ADDR       : return "mcycleh";       
    `CSR_MINSTRETH_ADDR     : return "minstreth";     
    `CSR_MHPMCOUNTER3H_ADDR : return "mhpmcounter3h"; 
    `CSR_MHPMCOUNTER4H_ADDR : return "mhpmcounter4h"; 
    `CSR_MHPMCOUNTER5H_ADDR : return "mhpmcounter5h"; 
    `CSR_MHPMCOUNTER6H_ADDR : return "mhpmcounter6h"; 
    `CSR_MHPMCOUNTER7H_ADDR : return "mhpmcounter7h"; 
    `CSR_MHPMCOUNTER8H_ADDR : return "mhpmcounter8h"; 
    `CSR_MHPMCOUNTER9H_ADDR : return "mhpmcounter9h"; 
    `CSR_MHPMCOUNTER10H_ADDR: return "mhpmcounter10h";
    `CSR_MHPMCOUNTER11H_ADDR: return "mhpmcounter11h";
    `CSR_MHPMCOUNTER12H_ADDR: return "mhpmcounter12h";
    `CSR_MHPMCOUNTER13H_ADDR: return "mhpmcounter13h";
    `CSR_MHPMCOUNTER14H_ADDR: return "mhpmcounter14h";
    `CSR_MHPMCOUNTER15H_ADDR: return "mhpmcounter15h";
    `CSR_MHPMCOUNTER16H_ADDR: return "mhpmcounter16h";
    `CSR_MHPMCOUNTER17H_ADDR: return "mhpmcounter17h";
    `CSR_MHPMCOUNTER18H_ADDR: return "mhpmcounter18h";
    `CSR_MHPMCOUNTER19H_ADDR: return "mhpmcounter19h";
    `CSR_MHPMCOUNTER20H_ADDR: return "mhpmcounter20h";
    `CSR_MHPMCOUNTER21H_ADDR: return "mhpmcounter21h";
    `CSR_MHPMCOUNTER22H_ADDR: return "mhpmcounter22h";
    `CSR_MHPMCOUNTER23H_ADDR: return "mhpmcounter23h";
    `CSR_MHPMCOUNTER24H_ADDR: return "mhpmcounter24h";
    `CSR_MHPMCOUNTER25H_ADDR: return "mhpmcounter25h";
    `CSR_MHPMCOUNTER26H_ADDR: return "mhpmcounter26h";
    `CSR_MHPMCOUNTER27H_ADDR: return "mhpmcounter27h";
    `CSR_MHPMCOUNTER28H_ADDR: return "mhpmcounter28h";
    `CSR_MHPMCOUNTER29H_ADDR: return "mhpmcounter29h";
    `CSR_MHPMCOUNTER30H_ADDR: return "mhpmcounter30h";
    `CSR_MHPMCOUNTER31H_ADDR: return "mhpmcounter31h";
    `CSR_MHPMEVENT3_ADDR    : return "mhpmevent3";    
    `CSR_MHPMEVENT4_ADDR    : return "mhpmevent4";    
    `CSR_MHPMEVENT5_ADDR    : return "mhpmevent5";    
    `CSR_MHPMEVENT6_ADDR    : return "mhpmevent6";    
    `CSR_MHPMEVENT7_ADDR    : return "mhpmevent7";    
    `CSR_MHPMEVENT8_ADDR    : return "mhpmevent8";    
    `CSR_MHPMEVENT9_ADDR    : return "mhpmevent9";    
    `CSR_MHPMEVENT10_ADDR   : return "mhpmevent10";   
    `CSR_MHPMEVENT11_ADDR   : return "mhpmevent11";   
    `CSR_MHPMEVENT12_ADDR   : return "mhpmevent12";   
    `CSR_MHPMEVENT13_ADDR   : return "mhpmevent13";   
    `CSR_MHPMEVENT14_ADDR   : return "mhpmevent14";   
    `CSR_MHPMEVENT15_ADDR   : return "mhpmevent15";   
    `CSR_MHPMEVENT16_ADDR   : return "mhpmevent16";   
    `CSR_MHPMEVENT17_ADDR   : return "mhpmevent17";   
    `CSR_MHPMEVENT18_ADDR   : return "mhpmevent18";   
    `CSR_MHPMEVENT19_ADDR   : return "mhpmevent19";   
    `CSR_MHPMEVENT20_ADDR   : return "mhpmevent20";   
    `CSR_MHPMEVENT21_ADDR   : return "mhpmevent21";   
    `CSR_MHPMEVENT22_ADDR   : return "mhpmevent22";   
    `CSR_MHPMEVENT23_ADDR   : return "mhpmevent23";   
    `CSR_MHPMEVENT24_ADDR   : return "mhpmevent24";   
    `CSR_MHPMEVENT25_ADDR   : return "mhpmevent25";   
    `CSR_MHPMEVENT26_ADDR   : return "mhpmevent26";   
    `CSR_MHPMEVENT27_ADDR   : return "mhpmevent27";   
    `CSR_MHPMEVENT28_ADDR   : return "mhpmevent28";   
    `CSR_MHPMEVENT29_ADDR   : return "mhpmevent29";   
    `CSR_MHPMEVENT30_ADDR   : return "mhpmevent30";   
    `CSR_MHPMEVENT31_ADDR   : return "mhpmevent31";   
                                                     
    `CSR_TSELECT_ADDR       : return "tselect";       
    `CSR_TDATA1_ADDR        : return "tdata1";        
    `CSR_TDATA2_ADDR        : return "tdata2";        
    `CSR_TDATA3_ADDR        : return "tdata3";        
    `CSR_DCSR_ADDR          : return "dcsr";          
    `CSR_DPC_ADDR           : return "dpc";           
    `CSR_DSCRATCH_ADDR      : return "dscratch";      
    default: return csr_id;
endcase

endfunction

function string fence_flag;
input [3:0] arg;

string str;
str = "";

if (arg[3])
    str = {str, "i"};
if (arg[2])
    str = {str, "o"};
if (arg[1])
    str = {str, "r"};
if (arg[0])
    str = {str, "w"};
if (str == "")
    str = {str, "-"};

return str;

endfunction

function string inst_dec;
input [31:0] pc;
input [31:0] inst;

string result;
`include "opcode.sv"
`include "funct.sv"

parameter [4:0] REG_ZERO = 5'd0;
parameter [4:0] REG_RA   = 5'd1;
parameter [4:0] REG_SP   = 5'd2;
parameter [4:0] REG_GP   = 5'd3;
parameter [4:0] REG_TP   = 5'd4;
parameter [4:0] REG_T0   = 5'd5;
parameter [4:0] REG_T1   = 5'd6;
parameter [4:0] REG_T2   = 5'd7;
parameter [4:0] REG_S0   = 5'd8;
parameter [4:0] REG_FP   = 5'd8;
parameter [4:0] REG_S1   = 5'd9;
parameter [4:0] REG_A0   = 5'd10;
parameter [4:0] REG_A1   = 5'd11;
parameter [4:0] REG_A2   = 5'd12;
parameter [4:0] REG_A3   = 5'd13;
parameter [4:0] REG_A4   = 5'd14;
parameter [4:0] REG_A5   = 5'd15;
parameter [4:0] REG_A6   = 5'd16;
parameter [4:0] REG_A7   = 5'd17;
parameter [4:0] REG_S2   = 5'd18;
parameter [4:0] REG_S3   = 5'd19;
parameter [4:0] REG_S4   = 5'd20;
parameter [4:0] REG_S5   = 5'd21;
parameter [4:0] REG_S6   = 5'd22;
parameter [4:0] REG_S7   = 5'd23;
parameter [4:0] REG_S8   = 5'd24;
parameter [4:0] REG_S9   = 5'd25;
parameter [4:0] REG_S10  = 5'd26;
parameter [4:0] REG_S11  = 5'd27;
parameter [4:0] REG_T3   = 5'd28;
parameter [4:0] REG_T4   = 5'd29;
parameter [4:0] REG_T5   = 5'd30;
parameter [4:0] REG_T6   = 5'd31;

logic [        4: 0] rs1;
logic [        4: 0] rs2;
logic [        4: 0] rd;
logic [       11: 0] csr_addr;

logic [`XLEN - 1:0] imm_i;
logic [`XLEN - 1:0] imm_s;
logic [`XLEN - 1:0] imm_b;
logic [`XLEN - 1:0] imm_u;
logic [`XLEN - 1:0] imm_j;

logic [`XLEN - 1:0] imm_ci_lsp;
logic [`XLEN - 1:0] imm_ci_li;
logic [`XLEN - 1:0] imm_ci_lui;
logic [`XLEN - 1:0] imm_ci_addi16sp;
logic [`XLEN - 1:0] imm_css;
logic [`XLEN - 1:0] imm_ciw;
logic [`XLEN - 1:0] imm_cl;
logic [`XLEN - 1:0] imm_cs;
logic [`XLEN - 1:0] imm_cb;
logic [`XLEN - 1:0] imm_cj;

logic [      14:12] funct3;
logic [      31:25] funct7;

logic [      15:13] funct3_16;
logic [      15:13] funct2_16_op_imm;
logic [      15:13] funct2_16_op;

logic [       6: 2] opcode_32;
logic [       1: 0] opcode_16;

logic [        3: 0] pred;
logic [        3: 0] succ;
logic [        4: 0] shamt;

rs1      = inst[19:15];
rs2      = inst[24:20];
rd       = inst[11: 7];
csr_addr = inst[31:20];

imm_i     = {{(`XLEN-11){inst[31]}}, inst[30:25], inst[24:21], inst[20]};
imm_s     = {{(`XLEN-11){inst[31]}}, inst[30:25], inst[11:8],  inst[7]};
imm_b     = {{(`XLEN-12){inst[31]}}, inst[7],     inst[30:25], inst[11:8], 1'b0};
imm_u     = {{(`XLEN-31){inst[31]}}, inst[30:20], inst[19:12], 12'b0};
imm_j     = {{(`XLEN-20){inst[31]}}, inst[19:12], inst[20],    inst[30:25], inst[24:21], 1'b0};

imm_ci_lsp      = {{(`XLEN-8){1'b0}},      inst[3:2], inst[12], inst[6:4], 2'b0};
imm_ci_li       = {{(`XLEN-5){inst[12]}},  inst[6:2]};
imm_ci_lui      = {{(`XLEN-17){inst[12]}}, inst[6:2], 12'b0};
imm_ci_addi16sp = {{(`XLEN-9){inst[12]}},  inst[4:3], inst[5], inst[2], inst[6], 4'b0};
imm_css         = {{(`XLEN-8){1'b0}},      inst[8:7], inst[12:9], 2'b0};
imm_ciw         = {{(`XLEN-10){1'b0}},     inst[10:7], inst[12:11], inst[5], inst[6], 2'b0};
imm_cl          = {{(`XLEN-7){1'b0}},      inst[5], inst[12:10], inst[6], 2'b0};
imm_cs          = {{(`XLEN-7){1'b0}},      inst[5], inst[12:10], inst[6], 2'b0};
imm_cb          = {{(`XLEN-8){inst[12]}},  inst[6:5], inst[2], inst[11:10], inst[4:3], 1'b0};
imm_cj          = {{(`XLEN-11){inst[12]}}, inst[8], inst[10:9], inst[6], inst[7], inst[2], inst[11], inst[5:3], 1'b0};

funct3           = inst[14:12];
funct7           = inst[31:25];

funct3_16        = inst[15:13];
funct2_16_op_imm = inst[11:10];
funct2_16_op     = inst[ 6: 5];

opcode_16 = inst[1:0];
opcode_32 = inst[6:2];

pred   = inst[27:24];
succ   = inst[23:20];

shamt  = inst[24:20];

result = "unknown inst";
case (opcode_16)
    OP16_C0: begin
        rs1            = {2'b1, inst[ 9: 7]};
        rs2            = {2'b1, inst[ 4: 2]};
        rd             = {2'b1, inst[ 4: 2]};
        case (funct3_16)
            FUNCT3_C0_ADDI4SPN: begin
                $sformat(result, "c.addi4spn %s,%s,%0d", regs_name(rd), regs_name(REG_SP), $signed(imm_ciw));
            end
            FUNCT3_C0_FLD     : begin
                return "illigal inst";
            end
            FUNCT3_C0_LW      : begin
                $sformat(result, "c.lw %s,%0d(%s)", regs_name(rd), imm_cl, regs_name(rs1));
            end
            FUNCT3_C0_FLW     : begin
                return "illigal inst";
            end
            FUNCT3_C0_FSD     : begin
                return "illigal inst";
            end
            FUNCT3_C0_SW      : begin
                $sformat(result, "c.sw %s,%0d(%s)", regs_name(rs2), imm_cs, regs_name(rs1));
            end
            FUNCT3_C0_FSW     : begin
                return "illigal inst";
            end
            default           : begin
                return "illigal inst";
            end
        endcase
    end
    OP16_C1: begin
        rs1            = {2'b1, inst[ 9: 7]};
        rs2            = {2'b1, inst[ 4: 2]};
        rd             = {2'b1, inst[ 9: 7]};
        case (funct3_16)
            FUNCT3_C1_ADDI: begin
                rs1     = inst[ 11: 7];
                rd      = inst[ 11: 7];
                if (~|rd && ~|imm_ci_li)
                    $sformat(result, "c.nop");
                else
                    $sformat(result, "c.addi %s,%0d", regs_name(rd), $signed(imm_ci_li));
            end
            FUNCT3_C1_JAL : begin
                $sformat(result, "c.jal %08x", pc + imm_cj);
            end
            FUNCT3_C1_LI  : begin
                rd      = inst[ 11: 7];
                $sformat(result, "c.li %s,%0d", regs_name(rd), imm_ci_li);
            end
            FUNCT3_C1_LUI : begin
                rs1     = inst[ 11: 7];
                rd      = inst[ 11: 7];
                if (rd_addr == `GPR_SP_ADDR) begin
                    $sformat(result, "c.addi16sp %s,%0d", regs_name(REG_SP), imm_ci_addi16sp);
                end
                else begin
                    $sformat(result, "c.lui %s,0x%0x", regs_name(rd), imm_ci_lui >> 12 & 20'hfffff);
                end
            end
            FUNCT3_C1_OP  : begin
                case (funct2_16_op_imm)
                    FUNCT2_OP_IMM_C_SRLI: begin
                        $sformat(result, "c.srli %s,0x%0x", regs_name(rd), imm_ci_li[4:0]);
                    end
                    FUNCT2_OP_IMM_C_SRAI: begin
                        $sformat(result, "c.srai %s,0x%0x", regs_name(rd), imm_ci_li[4:0]);
                    end
                    FUNCT2_OP_IMM_C_ANDI: begin
                        $sformat(result, "c.andi %s,%0d", regs_name(rd), imm_ci_li);
                    end
                    FUNCT2_OP_IMM_C_OP  : begin
                        if (inst[12] == 1'b0) begin
                            case (funct2_16_op)
                                FUNCT2_OP_C_SUB: begin
                                    $sformat(result, "c.sub %s,%s", regs_name(rd), regs_name(rs2));
                                end
                                FUNCT2_OP_C_XOR: begin
                                    $sformat(result, "c.xor %s,%s", regs_name(rd), regs_name(rs2));
                                end
                                FUNCT2_OP_C_OR : begin
                                    $sformat(result, "c.or %s,%s", regs_name(rd), regs_name(rs2));
                                end
                                FUNCT2_OP_C_AND: begin
                                    $sformat(result, "c.and %s,%s", regs_name(rd), regs_name(rs2));
                                end
                                default        : begin
                                    return "illigal inst";
                                end
                            endcase
                        end
                        else begin
                            return "illigal inst";
                        end
                    end
                    default             : begin
                        return "illigal inst";
                    end
                endcase
            end
            FUNCT3_C1_J   : begin
                $sformat(result, "c.j %08x", pc + imm_cj & -32'b1);
            end
            FUNCT3_C1_BEQZ: begin
                $sformat(result, "c.beqz %s,%08x", regs_name(rs1), pc + imm_cb & -32'b1);
            end
            FUNCT3_C1_BNEZ: begin
                $sformat(result, "c.bnez %s,%08x", regs_name(rs1), pc + imm_cb & -32'b1);
            end
            default       : begin
                return "illigal inst";
            end
        endcase
    end
    OP16_C2: begin
        rs1            = {inst[11: 7]};
        rs2            = {inst[ 6: 2]};
        rd             = {inst[11: 7]};
        case (funct3_16)
            FUNCT3_C2_SLLI : begin
                $sformat(result, "c.slli %s,0x%0x", regs_name(rd), imm_ci_li[4:0]);
            end
            FUNCT3_C2_FLDSP: begin
                return "illigal inst";
            end
            FUNCT3_C2_LWSP : begin
                $sformat(result, "c.lwsp %s,%0d(%s)", regs_name(rd), imm_ci_lsp, regs_name(REG_SP));
            end
            FUNCT3_C2_FLWSP: begin
                return "illigal inst";
            end
            FUNCT3_C2_OP   : begin
                if (~inst[12]) begin
                    if (rs2 == REG_ZERO) begin
                        $sformat(result, "c.jr %s", regs_name(rs1));
                    end
                    else begin
                        $sformat(result, "c.mv %s,%s", regs_name(rd), regs_name(rs2));
                    end
                end
                else begin
                    if (rs2 == REG_ZERO) begin
                        if (rs1 == REG_ZERO) begin
                            $sformat(result, "c.ebreak");
                        end
                        else begin
                            $sformat(result, "c.jalr %s", regs_name(rs1));
                        end
                    end
                    else begin
                        $sformat(result, "c.add %s,%s", regs_name(rd), regs_name(rs2));
                    end
                end
            end
            FUNCT3_C2_FSDSP: begin
                return "illigal inst";
            end
            FUNCT3_C2_SWSP : begin
                $sformat(result, "c.swsp %s,%0d(%s)", regs_name(rs2), imm_css, regs_name(REG_SP));
            end
            FUNCT3_C2_FSWSP: begin
                return "illigal inst";
            end
            default        : begin
                return "illigal inst";
            end
        endcase
    end
    default: begin
        case (opcode_32)
            OP_LOAD     : begin
                case (funct3)
                    FUNCT3_LB : begin
                        $sformat(result, "lb %s,%0d(%s)", regs_name(rd), imm_i, regs_name(rs1));
                    end
                    FUNCT3_LH : begin
                        $sformat(result, "lh %s,%0d(%s)", regs_name(rd), imm_i, regs_name(rs1));
                    end
                    FUNCT3_LW : begin
                        $sformat(result, "lw %s,%0d(%s)", regs_name(rd), imm_i, regs_name(rs1));
                    end
                    FUNCT3_LBU: begin
                        $sformat(result, "lbu %s,%0d(%s)", regs_name(rd), imm_i, regs_name(rs1));
                    end
                    FUNCT3_LHU: begin
                        $sformat(result, "lhu %s,%0d(%s)", regs_name(rd), imm_i, regs_name(rs1));
                    end
                    default   : begin
                        return "illigal inst";
                    end
                endcase
            end
            OP_LOAD_FP  : begin
            end
            OP_CUST_0   : begin
            end
            OP_MISC_MEM : begin
                case ({funct3, inst[11:7], inst[19:15], inst[31:28]})
                    {FUNCT3_FENCE  , 5'b0, 5'b0, 4'b0}: begin
                        if (pred != 4'hf | succ != 4'hf)
                            $sformat(result, "fence %s,%s", fence_flag(pred), fence_flag(succ));
                        else
                            $sformat(result, "fence");
                    end
                    {FUNCT3_FENCE_I, 5'b0, 5'b0, 4'b0}: begin
                        if (inst[27:20] == 8'b0) begin
                            $sformat(result, "fence.i");
                        end
                        else return "illigal inst";
                    end
                    default       : begin
                        return "illigal inst";
                    end
                endcase
            end
            OP_OP_IMM   : begin
                case (funct3)
                    FUNCT3_ADDI : begin
                        if (!rd && !rs1 && !imm_i)
                            $sformat(result, "nop");
                        else if (!rs1)
                            $sformat(result, "li %s,%0d", regs_name(rd), $signed(imm_i));
                        else if (!imm_i)
                            $sformat(result, "mv %s,%s", regs_name(rd), regs_name(rs1));
                        else
                            $sformat(result, "addi %s,%s,%0d", regs_name(rd), regs_name(rs1), $signed(imm_i));
                    end
                    FUNCT3_SLTI : begin
                        $sformat(result, "slti %s,%s,%0d", regs_name(rd), regs_name(rs1), imm_i);
                    end
                    FUNCT3_SLTIU: begin
                        $sformat(result, "sltiu %s,%s,%0d", regs_name(rd), regs_name(rs1), imm_i);
                    end
                    FUNCT3_XORI : begin
                        if (imm_i == -`XLEN'd1)
                            $sformat(result, "not %s,%s", regs_name(rd), regs_name(rs1));
                        else
                            $sformat(result, "xori %s,%s,%0d", regs_name(rd), regs_name(rs1), imm_i);
                    end
                    FUNCT3_ORI  : begin
                        $sformat(result, "ori %s,%s,%0d", regs_name(rd), regs_name(rs1), imm_i);
                    end
                    FUNCT3_ANDI : begin
                        $sformat(result, "andi %s,%s,%0d", regs_name(rd), regs_name(rs1), imm_i);
                    end
                    FUNCT3_SLLI : begin
                        case (funct7)
                            FUNCT7_SLLI: begin
                                $sformat(result, "slli %s,%s,0x%0x", regs_name(rd), regs_name(rs1), shamt);
                            end
                            default    : begin
                                return "illigal inst";
                            end
                        endcase
                    end
                    FUNCT3_SRLI : begin
                        case (funct7)
                            FUNCT7_SRLI: begin
                                $sformat(result, "srli %s,%s,0x%0x", regs_name(rd), regs_name(rs1), shamt);
                            end
                            FUNCT7_SRAI: begin
                                $sformat(result, "srai %s,%s,0x%0x", regs_name(rd), regs_name(rs1), shamt);
                            end
                            default    : begin
                                return "illigal inst";
                            end
                        endcase
                    end
                    default     : begin
                        return "illigal inst";
                    end
                endcase
            end
            OP_AUIPC    : begin
                $sformat(result, "auipc %s,0x%0x", regs_name(rd), imm_u >> 12 & 20'hfffff);
            end
            OP_OP_IMM_32: begin
            end
            OP_STORE    : begin
                case (funct3)
                    FUNCT3_SB: begin
                        $sformat(result, "sb %s,%0d(%s)", regs_name(rs2), imm_s, regs_name(rs1));
                    end
                    FUNCT3_SH: begin
                        $sformat(result, "sh %s,%0d(%s)", regs_name(rs2), imm_s, regs_name(rs1));
                    end
                    FUNCT3_SW: begin
                        $sformat(result, "sw %s,%0d(%s)", regs_name(rs2), imm_s, regs_name(rs1));
                    end
                    default  : begin
                        return "illigal inst";
                    end
                endcase
            end
            OP_STORE_FP : begin
            end
            OP_CUST_1   : begin
            end
            OP_AMO      : begin
            end
            OP_OP       : begin
                case (funct3)
                    FUNCT3_ADD : begin
                        case (funct7)
                            FUNCT7_ADD: begin
                                $sformat(result, "add %s,%s,%s", regs_name(rd), regs_name(rs1), regs_name(rs2));
                            end
                            FUNCT7_SUB: begin
                                $sformat(result, "sub %s,%s,%s", regs_name(rd), regs_name(rs1), regs_name(rs2));
                            end
                            default   : begin
                                return "illigal inst";
                            end
                        endcase
                    end
                    FUNCT3_SLL : begin
                        case (funct7)
                            FUNCT7_SLL: begin
                                $sformat(result, "sll %s,%s,%s", regs_name(rd), regs_name(rs1), regs_name(rs2));
                            end
                            default   : begin
                                return "illigal inst";
                            end
                        endcase
                    end
                    FUNCT3_SLT : begin
                        case (funct7)
                            FUNCT7_SLT: begin
                                 $sformat(result, "slt %s,%s,%s", regs_name(rd), regs_name(rs1), regs_name(rs2));
                            end
                            default   : begin
                                return "illigal inst";
                            end
                        endcase
                    end
                    FUNCT3_SLTU: begin
                        case (funct7)
                            FUNCT7_SLTU: begin
                                 $sformat(result, "sltu %s,%s,%s", regs_name(rd), regs_name(rs1), regs_name(rs2));
                            end
                            default    : begin
                                return "illigal inst";
                            end
                        endcase
                    end
                    FUNCT3_XOR : begin
                        case (funct7)
                            FUNCT7_XOR: begin
                                 $sformat(result, "xor %s,%s,%s", regs_name(rd), regs_name(rs1), regs_name(rs2));
                            end
                            default   : begin
                                return "illigal inst";
                            end
                        endcase
                    end
                    FUNCT3_SRL : begin
                        case (funct7)
                            FUNCT7_SRL: begin
                                 $sformat(result, "srl %s,%s,%s", regs_name(rd), regs_name(rs1), regs_name(rs2));
                            end
                            FUNCT7_SRA: begin
                                 $sformat(result, "sra %s,%s,%s", regs_name(rd), regs_name(rs1), regs_name(rs2));
                            end
                            default   : begin
                                return "illigal inst";
                            end
                        endcase
                    end
                    FUNCT3_OR  : begin
                        case (funct7)
                            FUNCT7_OR: begin
                                 $sformat(result, "or %s,%s,%s", regs_name(rd), regs_name(rs1), regs_name(rs2));
                            end
                            default  : begin
                                return "illigal inst";
                            end
                        endcase
                    end
                    FUNCT3_AND : begin
                        case (funct7)
                            FUNCT7_AND: begin
                                 $sformat(result, "and %s,%s,%s", regs_name(rd), regs_name(rs1), regs_name(rs2));
                            end
                            default    : begin
                                return "illigal inst";
                            end
                        endcase
                    end
                    default    : begin
                        return "illigal inst";
                    end
                endcase
            end
            OP_LUI      : begin
                $sformat(result, "lui %s,0x%0x", regs_name(rd), imm_u >> 12 & 20'hfffff);
            end
            OP_OP_32    : begin
            end
            OP_MADD     : begin
            end
            OP_MSUB     : begin
            end
            OP_NMSUB    : begin
            end
            OP_NMADD    : begin
            end
            OP_OP_FP    : begin
            end
            OP_CUST_2   : begin
            end
            OP_BRANCH   : begin
                case (funct3)
                    FUNCT3_BEQ : begin
                        if (rs2)
                            $sformat(result, "beq %s,%s,%08x", regs_name(rs1), regs_name(rs2), pc + imm_b & -32'b1);
                        else
                            $sformat(result, "beqz %s,%08x", regs_name(rs1), pc + imm_b & -32'b1);
                    end
                    FUNCT3_BNE : begin
                        if (rs2)
                            $sformat(result, "bne %s,%s,%08x", regs_name(rs1), regs_name(rs2), pc + imm_b & -32'b1);
                        else
                            $sformat(result, "bnez %s,%08x", regs_name(rs1), pc + imm_b & -32'b1);
                    end
                    FUNCT3_BLT : begin
                        if (!rs1)
                            $sformat(result, "bgtz %s,%08x", regs_name(rs2), pc + imm_b & -32'b1);
                        else if (!rs2)
                            $sformat(result, "bltz %s,%08x", regs_name(rs1), pc + imm_b & -32'b1);
                        else
                            $sformat(result, "blt %s,%s,%08x", regs_name(rs1), regs_name(rs2), pc + imm_b & -32'b1);
                    end
                    FUNCT3_BGE : begin
                        if (!rs1)
                            $sformat(result, "blez %s,%08x", regs_name(rs2), pc + imm_b & -32'b1);
                        else if (!rs2)
                            $sformat(result, "bgez %s,%08x", regs_name(rs1), pc + imm_b & -32'b1);
                        else
                            $sformat(result, "bge %s,%s,%08x", regs_name(rs1), regs_name(rs2), pc + imm_b & -32'b1);
                    end
                    FUNCT3_BLTU: begin
                        $sformat(result, "bltu %s,%s,%08x", regs_name(rs1), regs_name(rs2), pc + imm_b & -32'b1);
                    end
                    FUNCT3_BGEU: begin
                        $sformat(result, "bgeu %s,%s,%08x", regs_name(rs1), regs_name(rs2), pc + imm_b & -32'b1);
                    end
                    default    : begin
                        return "illigal inst";
                    end
                endcase
            end
            OP_JALR     : begin
                if (imm_i || !(rd == REG_ZERO || rd == REG_RA))
                    $sformat(result, "jalr %s,%0d(%s)", regs_name(rd), imm_i, regs_name(rs1));
                else if (rd == REG_RA)
                    $sformat(result, "jalr %s", regs_name(rs1));
                else if (rs1 == REG_RA)
                    $sformat(result, "ret");
                else
                    $sformat(result, "jr %s", regs_name(rs1));
            end
            OP_JAL      : begin
                if (!rd)
                    $sformat(result, "j %08x", pc + imm_j & -32'b1);
                else if (rd == REG_RA)
                    $sformat(result, "jal %08x", pc + imm_j & -32'b1);
                else
                    $sformat(result, "jal %s,%08x", regs_name(rd), pc + imm_j & -32'b1);
            end
            OP_SYSTEM   : begin
                case (funct3)
                    FUNCT3_PRIV  : begin
                        if (funct7 == FUNCT7_SFENCE_VMA) begin
                            if (!rs1 & !rs2)
                                $sformat(result, "sfence.vma");
                            else if (!rs2)
                                $sformat(result, "sfence.vma %s", regs_name(rs1));
                            else
                                $sformat(result, "sfence.vma %s,%s", regs_name(rs1), regs_name(rs2));
                        end
                        else if ({inst[11:7], inst[19:15]} == {5'b0, 5'b0}) begin
                            case (inst[31:20])
                                FUNCT12_ECALL: begin
                                    $sformat(result, "ecall");
                                end
                                FUNCT12_EBREAK: begin
                                    $sformat(result, "ebreak");
                                end
                                FUNCT12_WFI   : begin
                                    $sformat(result, "wfi");
                                end
                                FUNCT12_SRET  : begin
                                    $sformat(result, "sret");
                                end
                                FUNCT12_MRET  : begin
                                    $sformat(result, "mret");
                                end
                                default       : begin
                                    return "illigal inst";
                                end
                            endcase
                        end
                        else begin
                            return "illigal inst";
                        end
                    end
                    FUNCT3_CSRRW : begin
                        if (rd)
                            $sformat(result, "csrrw %s,%s,%s", regs_name(rd), csr_name(csr_addr), regs_name(rs1));
                        else
                            $sformat(result, "csrw %s,%s", csr_name(csr_addr), regs_name(rs1));
                    end
                    FUNCT3_CSRRS : begin
                        if (!rs1)
                            $sformat(result, "csrr %s,%s", regs_name(rd), csr_name(csr_addr));
                        else if (!rd)
                            $sformat(result, "csrs %s,%s", csr_name(csr_addr), regs_name(rs1));
                        else
                            $sformat(result, "csrrs %s,%s,%s", regs_name(rd), csr_name(csr_addr), regs_name(rs1));
                    end
                    FUNCT3_CSRRC : begin
                        if (rd)
                            $sformat(result, "csrrc %s,%s,%s", regs_name(rd), csr_name(csr_addr), regs_name(rs1));
                        else
                            $sformat(result, "csrc %s,%s", csr_name(csr_addr), regs_name(rs1));
                    end
                    FUNCT3_CSRRWI: begin
                        if (rd)
                            $sformat(result, "csrrwi %s,%s,%0d", regs_name(rd), csr_name(csr_addr), rs1);
                        else
                            $sformat(result, "csrwi %s,%0d", csr_name(csr_addr), rs1);
                    end
                    FUNCT3_CSRRSI: begin
                        if (rd)
                            $sformat(result, "csrrsi %s,%s,%0d", regs_name(rd), csr_name(csr_addr), rs1);
                        else
                            $sformat(result, "csrsi %s,%0d", csr_name(csr_addr), rs1);
                    end
                    FUNCT3_CSRRCI: begin
                        if (rd)
                            $sformat(result, "csrrci %s,%s,%0d", regs_name(rd), csr_name(csr_addr), rs1);
                        else
                            $sformat(result, "csrci %s,%0d", csr_name(csr_addr), rs1);
                    end
                    default       : begin
                        return "illigal inst";
                    end
                endcase
            end
            OP_CUST_3   : begin
            end
            default     : begin
                return "illigal inst";
            end
        endcase
    end
endcase

return result;

endfunction
