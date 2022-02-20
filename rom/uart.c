#include "mmap_soc.h"
#include "typedef.h"

void __uart_init(void) {
    // Enable uart TX & RX
    *UART_TXCTRL_32P = 1;
    *UART_RXCTRL_32P = 1;

}

void __putch(__U8 __ch) {
    while (*UART_TXFIFO_32P < 0);
    *UART_TXFIFO_32P = __ch;
}

__U32 __puts(const __U8P __s) {
    __U32 __res = 0;
    while (*__s) {
        __putch(*__s++);
        ++__res;
    }
    __putch('\n');
    return __res;
}

