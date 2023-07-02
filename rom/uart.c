#include "mmap_soc.h"
#include "typedef.h"

void __uart_init(void) {
    // Enable uart TX & RX
    *UART_TXCTRL_32P = 1;
    *UART_RXCTRL_32P = 1;

    // Disable interrupt enable
    *UART_IE_32P = 0;

    // Flush RX FIFO
    while ((int) *UART_RXFIFO_32P > 0);
}

void __putch(__U8 __ch) {
    int r;
    do {
      __asm__ __volatile__ (
        "amoor.w %0, %2, %1\n"
        : "=r" (r), "+A" (*UART_TXFIFO_32P)
        : "r" (__ch));
    } while (r < 0);
}

__U32 __puts(const __U8P __s) {
    __U32 __res = 0;
    while (*__s) {
        __putch(*__s++);
        ++__res;
    }
    __putch('\r');
    __putch('\n');
    return __res;
}
