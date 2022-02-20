#include "mmap_soc.h"
#include "typedef.h"
#include "util.h"

__U32 __strcmp(const __U8P str1, const __U8P str2, __U32 len) {
    while (len--) {
        if      (*str1 < *str2) return -1;
        else if (*str1 > *str2) return  1;
        str1++, str2++;
    }
    return 0;
}

void *__memcpy(void *buff1, const void *buff2, __U32 len) {
    while (len >= 8) {
        *(__U64P) buff1 = *(__U64P) buff2;
        buff1 += 8;
        buff2 += 8;
        len -= 8;
    }
    if (len >= 4) {
        *(__U32P) buff1 = *(__U32P) buff2;
        buff1 += 4;
        buff2 += 4;
        len -= 4;
    }
    if (len >= 2) {
        *(__U16P) buff1 = *(__U16P) buff2;
        buff1 += 2;
        buff2 += 2;
        len -= 2;
    }
    if (len) *(__U8P) buff1 = *(__U8P) buff2;
    return buff1;
}

void __delay(__U32 __ms) {
    *CLINT_TIMECMP_64P = *CLINT_TIME_64P + __ms * 1000000/30;
    __CSR_SET(mie, 1 << 7);
    __WFI();
    __CSR_CLR(mie, 1 << 7);
}
