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

void spi_init(int cpha, int cpol) {
    *SPI_CR1_32P = (1 << 6) | ((cpol & 0x1) << 1) | ((cpha & 0x1) << 0);
}

void spi_halt() {
    *SPI_CR1_32P &= ~(1 << 6);
}

int spi_readwritebyte(int byte) {
    while (!(*SPI_SR_32P & 0x1));
    *SPI_DR_32P = byte;
    while (!(*SPI_SR_32P & 0x2));
    return *SPI_DR_32P;
}

int main() {
    /* TM_PRINT="Into main function\n" */
    plic_init();
    irq_init();
    uart_init();
    spi_init(1, 0);
    // set_mtimecmp_delay(0x1800 * puts("hello"));
    asm volatile (
        "li t0, 0x10001000;\n"
        "li t1, 0xaa;\n"
        "sh t1, 0xc(t0);\n"
        "li t1, 0xbb;\n"
        "sh t1, 0xc(t0);\n"
    );
    while (cnt != 2) {
        asm volatile ("wfi");
    }
    return 0;
}

void isr(int cause) {
    if (cause == CAUSE_MTIP) {
        /* TM_PRINT="Receive timer interrupt\n" */
        set_mtimecmp_delay(0x500);
    }
    else if (cause == CAUSE_MEIP) {
        int irq_id = PLIC_PRIOR_TH_32P[1];
        /* TM_PRINT="Receive external interrupt ID: %d\n", irq_id */

        switch (irq_id) {
            case IRQ_UART:
                if (*UART_IE_32P & *UART_IP_32P & UART_TXWM_IP) {
                    /* TM_PRINT="Sent Hello World from UART TX\n" */
                    puts(str);
                    *UART_IE_32P &= ~0x1;
                    ++cnt;
                }
                else if (*UART_IE_32P & *UART_IP_32P & UART_RXWM_IP) {
                    /* TM_PRINT="Receive Hello World from UART RX\n" */
                    const char *str_ptr = str;
                    char ch;
                    while ((ch = getch()) != '\n') {
                        if (ch == *str_ptr) {
                            /* TM_PRINT="Receive data: %c ... pass\n", ch */
                        }
                        else {
                            /* TM_PRINT="Receive data: %c, expect is %c\n", ch, *str_ptr */
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
                    /* TM_PRINT="Unknown UART IRQ\n" */
                }
            case IRQ_SPI:
        }

        PLIC_PRIOR_TH_32P[1] = 0;
    }
    else {
        /* TM_PRINT="Receive unknown interrupt #%d\n", cause */
    }
}

void bad_trap(int cause) {
    /* TM_PRINT="#%d Bad trap!!!\n", cause */
}
