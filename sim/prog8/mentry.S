#define BACKUP_REGS     \
    addi sp, sp, -32*8; \
    sd x1, 1*8(sp);     \
    sd x3, 3*8(sp);     \
    sd x4, 4*8(sp);     \
    sd x5, 5*8(sp);     \
    sd x6, 6*8(sp);     \
    sd x7, 7*8(sp);     \
    sd x8, 8*8(sp);     \
    sd x9, 9*8(sp);     \
    sd x10, 10*8(sp);   \
    sd x11, 11*8(sp);   \
    sd x12, 12*8(sp);   \
    sd x13, 13*8(sp);   \
    sd x14, 14*8(sp);   \
    sd x15, 15*8(sp);   \
    sd x16, 16*8(sp);   \
    sd x17, 17*8(sp);   \
    sd x18, 18*8(sp);   \
    sd x19, 19*8(sp);   \
    sd x20, 20*8(sp);   \
    sd x21, 21*8(sp);   \
    sd x22, 22*8(sp);   \
    sd x23, 23*8(sp);   \
    sd x24, 24*8(sp);   \
    sd x25, 25*8(sp);   \
    sd x26, 26*8(sp);   \
    sd x27, 27*8(sp);   \
    sd x28, 28*8(sp);   \
    sd x29, 29*8(sp);   \
    sd x30, 30*8(sp);   \
    sd x31, 31*8(sp);

#define RESTORE_REGS   \
    ld x1, 1*8(sp);    \
    ld x3, 3*8(sp);    \
    ld x4, 4*8(sp);    \
    ld x5, 5*8(sp);    \
    ld x6, 6*8(sp);    \
    ld x7, 7*8(sp);    \
    ld x8, 8*8(sp);    \
    ld x9, 9*8(sp);    \
    ld x10, 10*8(sp);  \
    ld x11, 11*8(sp);  \
    ld x12, 12*8(sp);  \
    ld x13, 13*8(sp);  \
    ld x14, 14*8(sp);  \
    ld x15, 15*8(sp);  \
    ld x16, 16*8(sp);  \
    ld x17, 17*8(sp);  \
    ld x18, 18*8(sp);  \
    ld x19, 19*8(sp);  \
    ld x20, 20*8(sp);  \
    ld x21, 21*8(sp);  \
    ld x22, 22*8(sp);  \
    ld x23, 23*8(sp);  \
    ld x24, 24*8(sp);  \
    ld x25, 25*8(sp);  \
    ld x26, 26*8(sp);  \
    ld x27, 27*8(sp);  \
    ld x28, 28*8(sp);  \
    ld x29, 29*8(sp);  \
    ld x30, 30*8(sp);  \
    ld x31, 31*8(sp);  \
    addi sp, sp, 32*8; \
    mret;

.align 3
trap_table:
    .dc.a bad_trap # CAUSE_MISALIGNED_FETCH
    .dc.a bad_trap # CAUSE_INSTRUCTION_ACCESS
    .dc.a bad_trap # CAUSE_ILLEGAL_INSTRUCTION
    .dc.a bad_trap # CAUSE_BREAKPOINT
    .dc.a bad_trap # CAUSE_MISALIGNED_LOAD
    .dc.a bad_trap # CAUSE_LOAD_ACCESS
    .dc.a bad_trap # CAUSE_MISALIGNED_STORE
    .dc.a bad_trap # CAUSE_STORE_ACCESS
    .dc.a bad_trap # CAUSE_USER_ECALL
    .dc.a bad_trap # CAUSE_SUPERVISOR_ECALL
    .dc.a bad_trap # CAUSE_HYPERVISOR_ECALL
    .dc.a bad_trap # CAUSE_MACHINE_ECALL
    .dc.a bad_trap # CAUSE_INSTRUCTION_PAGE_FAULT
    .dc.a bad_trap # CAUSE_LOAD_PAGE_FAULT
    .dc.a bad_trap # RESERVED
    .dc.a bad_trap # CAUSE_STORE_PAGE_FAULT

.globl trap_entry
trap_entry:
    BACKUP_REGS
    csrr a0, mcause;
    slli a1, a0, 3;
    bltz a0, int_handle;
    la t0, trap_table;
    add a1, a1, t0;
    ld a1, (a1);
    jalr a1;
    j done;
int_handle:
    srli a0, a1, 3;
    jal isr 
done:
    RESTORE_REGS
