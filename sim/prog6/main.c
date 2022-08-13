#include <stdio.h>
#define CAUSE_SSIP     ( 1)
#define CAUSE_MSIP     ( 3)
#define CAUSE_STIP     ( 5)
#define CAUSE_MTIP     ( 7)
#define CAUSE_SEIP     ( 9)
#define CAUSE_MEIP     (11)

extern int test_func(long long);

void plic_init() {
    // Set UART and SPI interrupt priority
    PLIC_INT_PRIOR_32P[1] = 1;
    PLIC_INT_PRIOR_32P[2] = 1;

    // Set interrupt 1~31 enable for M-mode
    PLIC_INT_EN_32P[0] = ~1;

    // Set interrupt type level-sensitive
    PLIC_INT_TYPE_32P[0] = ~1;
}

void irq_init() {
    asm volatile ("csrs mie, %[rs]"::[rs] "r" ((1 << 7) | (1 << 11)));
}

void set_mtimecmp_delay(long delay) {
    *CLINT_TIMECMP_64P = *CLINT_TIME_64P + delay;
}

void dma_mem_cpy(void *buf1, const void *buf2, int len) {
    *DMA_SRC_32P  = (unsigned int) buf2;
    *DMA_DEST_32P = (unsigned int) buf1;
    *DMA_LEN_32P  = len*4+2;
    
    *DMA_CON_32P  = 0;
    // Set SRC/DEST INCR
    *DMA_CON_32P  |= 0x5 << 4;

    // Set SRC/DEST HWORD
    *DMA_CON_32P  |= 0xa << 8;

    // Start
    *DMA_CON_32P  |= 0x1;

    while (*DMA_CON_32P & 0x80000000);
}

int main(void) {
    /* TM_INFO="Into main function" */

    int len = 21;

    /* TM_INFO="Test Start" */
    unsigned long long tmp;
    tmp = 0x0000000776000000;
    /* TM_INFO="value = %d", tmp */
    tmp = test_func(tmp);
    /* TM_INFO="value = %d", tmp */
    /* TN_INFO="Test Done" */

    plic_init();
    irq_init();

    for (int i = 0; i < (len + 10) * 4; i += 4)
        *((int *) (0x80001000 + i)) = i+3 << 24 | i+2 << 16 | i+1 << 8 | i+0;

    dma_mem_cpy((void *) 0x80002007, (const void *) 0x80001005, len);
    
    *TMDL_TM_SIMEND_32P = 1;
    while (1);
    return 0;
}

void isr(int cause) {
    if (cause == CAUSE_MTIP) {
        /* TM_INFO="Receive timer interrupt" */
        set_mtimecmp_delay(0x500);
    }
    else if (cause == CAUSE_MEIP) {
        int irq_id = PLIC_PRIOR_TH_32P[1];
        /* TM_INFO="Receive external interrupt ID: %d", irq_id */

        PLIC_PRIOR_TH_32P[1] = 0;
    }
    else {
        /* TM_ERROR="Receive unknown interrupt #%d", cause */
    }
}

void bad_trap(int cause) {
    /* TM_ERROR="#%d Bad trap!!!", cause */
}
