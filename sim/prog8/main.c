#include <stdio.h>
#define CAUSE_SSIP     ( 1)
#define CAUSE_MSIP     ( 3)
#define CAUSE_STIP     ( 5)
#define CAUSE_MTIP     ( 7)
#define CAUSE_SEIP     ( 9)
#define CAUSE_MEIP     (11)

static int jiffies = 0;

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
    
    *DMA_CON_32P  |= 2 << 10 | // dest size
                     2 <<  8 | // src size
                     1 <<  6 | // dest type
                     1 <<  4 | // src size
                     1 <<  1 | // spi bypass
                     1 <<  0;  // start

    while (*DMA_CON_32P & 0x80000000);
}

int main(void) {
    /* TM_INFO="Into main function" */
    int len;

    plic_init();
    irq_init();

    *MAC_TXCTRL_32P = 1;

    *MAC_TXLEN_32P = 25;
    for (int i = 1; i < 8; i++) {
        *MAC_TXFIFO_32P = i << 24 | i << 16 | i << 8 | i;
    }
    *MAC_TXDIS_32P = 1;

    // *MAC_TXLEN_32P = 30;
    // for (int i = 10; i < 20; i++) {
    //     *MAC_TXFIFO_32P = i << 24 | i << 16 | i << 8 | i;
    // }

    while (*MAC_TXLEN_32P);

    *MAC_TXLEN_32P = 30;
    for (int i = 10; i < 20; i++) {
        *MAC_TXFIFO_32P = i << 24 | i << 16 | i << 8 | i;
    }

    *MAC_RXCTRL_32P = 1;
    
    for (len = 0; !len; len = *MAC_RXLEN_32P);
    /* TM_INFO="Get RX len: %d", len */
    for (int i = 0; i < len; i += 4) {
        /* TM_INFO="Get RX: %08x", *MAC_RXFIFO_32P */
    }
    *MAC_RXDIS_32P = 1;
    
    for (len = 0; !len; len = *MAC_RXLEN_32P);
    /* TM_INFO="Get RX len: %d", len */
    for (int i = 0; i < len; i += 4) {
        /* TM_INFO="Get RX: %08x", *MAC_RXFIFO_32P */
    }
    *MAC_RXDIS_32P = 1;
    
    for (len = 0; !len; len = *MAC_RXLEN_32P);
    /* TM_INFO="Get RX len: %d", len */
    for (int i = 0; i < len; i += 4) {
        /* TM_INFO="Get RX: %08x", *MAC_RXFIFO_32P */
    }
    *MAC_RXDIS_32P = 1;

    // while (jiffies < 2);

    *TMDL_TM_SIMEND_32P = 1;
    while (1);
    return 0;
}

void isr(int cause) {
    if (cause == CAUSE_MTIP) {
        /* TM_INFO="Receive timer interrupt" */
        set_mtimecmp_delay(0x100);
        jiffies++;
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
