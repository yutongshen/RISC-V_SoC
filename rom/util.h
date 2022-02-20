#ifndef __UTIL_H__
#define __UTIL_H__

#define __CSR_SET(__CSR__, __VAL__) do { asm volatile("csrs " #__CSR__ ", %[rs]"::[rs] "r" (__VAL__)); } while (0);
#define __CSR_WR(__CSR__, __VAL__)  do { asm volatile("csrw " #__CSR__ ", %[rs]"::[rs] "r" (__VAL__)); } while (0);
#define __CSR_CLR(__CSR__, __VAL__) do { asm volatile("csrc " #__CSR__ ", %[rs]"::[rs] "r" (__VAL__)); } while (0);
#define __WFI() do { asm volatile("wfi"); } while (0);

__U32 __strcmp(const __U8P str1, const __U8P str2, __U32 len);
void *__memcpy(void *buff1, const void *buff2, __U32 len);
void __delay(__U32 __ms);

#endif
