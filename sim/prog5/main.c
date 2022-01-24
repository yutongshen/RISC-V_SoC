#include <stdio.h>
#define IRQ_UART       ( 1)
#define IRQ_SPI        ( 2)
#define CAUSE_SSIP     ( 1)
#define CAUSE_MSIP     ( 3)
#define CAUSE_STIP     ( 5)
#define CAUSE_MTIP     ( 7)
#define CAUSE_SEIP     ( 9)
#define CAUSE_MEIP     (11)
#define UART_TXWM_IP   ( 1)
#define UART_RXWM_IP   ( 2)
#define UART_PERROR_IP ( 4)
#define CPHA_BIT       ( 0)
#define CPOL_BIT       ( 1)
#define MSTR_BIT       ( 2)
#define SPE_BIT        ( 6)
#define LSBFIRST_BIT   ( 7)
#define DFF_BIT        (11)

int cnt = 0;
const char str[20] = "Hello World";

void plic_init() {
    // Set UART and SPI interrupt priority
    PLIC_INT_PRIOR_32P[1] = 1;
    PLIC_INT_PRIOR_32P[2] = 1;

    // Set interrupt 1~31 enable for M-mode
    PLIC_INT_EN_32P[0] = ~1;

    // Set interrupt type level-sensitive
    PLIC_INT_TYPE_32P[0] = ~1;
}

void uart_init() {
    // Enable uart TX & RX
    *UART_TXCTRL_32P = 1;
    *UART_RXCTRL_32P = 1;

    // Enable interrupt
    *UART_IE_32P = 0x7;
}

char getch() {
    int res;
    while ((res = *UART_RXFIFO_32P) < 0);
    return (char) res;
}

void putch(char ch) {
    while (*UART_TXFIFO_32P < 0);
    *UART_TXFIFO_32P = ch;
}

int puts(const char *s) {
    int res = 0;
    while (*s) {
        putch(*s++);
        ++res;
    }
    putch('\n');
    return res;
}

void irq_init() {
    asm volatile ("csrs mie, %[rs]"::[rs] "r" ((1 << 7) | (1 << 11)));
}

void set_mtimecmp_delay(long delay) {
    *CLINT_TIMECMP_64P = *CLINT_TIME_64P + delay;
}

void spi_init(int cpha, int cpol, int lsb, int dff) {
    *SPI_CR1_32P = 0;
    *SPI_CR1_32P = (        0x1  << SPE_BIT     )|
                   (        0x1  << MSTR_BIT    )|
                   ((dff  & 0x1) << DFF_BIT     )|
                   ((lsb  & 0x1) << LSBFIRST_BIT)|
                   ((cpol & 0x1) << CPOL_BIT    )|
                   ((cpha & 0x1) << CPHA_BIT    );
}

void spi_halt() {
    *SPI_CR1_32P &= ~(1 << 6);
}

int spi_readwritebyte(int byte) {
    /* TM_INFO="SPI send date: %hx", byte */
    while (!(*SPI_SR_32P & 0x1));
    *SPI_DR_32P = byte;
    while (!(*SPI_SR_32P & 0x2));
    return *SPI_DR_32P;
}

int main() {
    /* TM_INFO="Into main function" */
    int spi_rdata, spi_wdata, tmp;
    plic_init();
    irq_init();
    /* TM_INFO="UART test (wait interrupt)" */
    // uart_init();
    // while (cnt != 2) {
    //     asm volatile ("wfi");
    // }

    /* TM_INFO="SPI test" */
    for (int i = 0; i <= 0xf; ++i) {
        /* TM_INFO="Set SPI CPHA: %c, CPOL: %c, LSBFIRST: %c, DFF: %c", (i&0x8)?'1':'0', (i&0x4)?'1':'0', (i&0x2)?'1':'0', (i&0x1)?'1':'0' */
        spi_init(!!(i&0x8), !!(i&0x4), !!(i&0x2), !!(i&0x1));
        spi_rdata = spi_readwritebyte(spi_wdata = 0x01234567);
        tmp = spi_wdata;
        spi_rdata = spi_readwritebyte(spi_wdata = 0x89abcdef);
        if (spi_rdata != (tmp & ((i&0x1)?0xffff:0xff))) {
            /* TM_ERROR="Receive data from SPI %hx, expect is %hx", spi_rdata, (tmp & ((i&0x1)?0xffff:0xff)) */
        }
        else {
            /* TM_INFO="Receive data from SPI %hx ... pass", spi_rdata */
        }
        tmp = spi_wdata;
        spi_rdata = spi_readwritebyte(spi_wdata = 0xbeefcafe);
        if (spi_rdata != (tmp & ((i&0x1)?0xffff:0xff))) {
            /* TM_ERROR="Receive data from SPI %hx, expect is %hx", spi_rdata, (tmp & ((i&0x1)?0xffff:0xff)) */
        }
        else {
            /* TM_INFO="Receive data from SPI %hx ... pass", spi_rdata */
        }
    }
    /*
    asm volatile (
        "li t0, 0x10001000;\n"
        "li t1, 0xaa;\n"
        "sh t1, 0xc(t0);\n"
        "li t1, 0xbb;\n"
        "sh t1, 0xc(t0);\n"
    );
    */
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

        switch (irq_id) {
            case IRQ_UART:
                if (*UART_IE_32P & *UART_IP_32P & UART_TXWM_IP) {
                    /* TM_INFO="Sent Hello World from UART TX" */
                    puts(str);
                    *UART_IE_32P &= ~0x1;
                    ++cnt;
                }
                else if (*UART_IE_32P & *UART_IP_32P & UART_RXWM_IP) {
                    /* TM_INFO="Receive Hello World from UART RX" */
                    const char *str_ptr = str;
                    char ch;
                    while ((ch = getch()) != '\n') {
                        if (ch == *str_ptr) {
                            /* TM_INFO="Receive data: %c ... pass", ch */
                        }
                        else {
                            /* TM_ERROR="Receive data: %c, expect is %c", ch, *str_ptr */
                        }
                        ++str_ptr;
                    }
                    *UART_IE_32P &= ~0x2;
                    ++cnt;
                }
                else if (*UART_IE_32P & *UART_IP_32P & UART_PERROR_IP) {
                    *UART_IE_32P &= ~0x4;
                }
                else {
                    /* TM_ERROR="Unknown UART IRQ" */
                }
            case IRQ_SPI:
        }

        PLIC_PRIOR_TH_32P[1] = 0;
    }
    else {
        /* TM_ERROR="Receive unknown interrupt #%d", cause */
    }
}

void bad_trap(int cause) {
    /* TM_ERROR="#%d Bad trap!!!", cause */
}
