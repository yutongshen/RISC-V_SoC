#ifndef __UART_H__
#define __UART_H__

void __uart_init(void);
void __putch(__U8 __ch);
__U32 __puts(const __U8P __s);

#endif
