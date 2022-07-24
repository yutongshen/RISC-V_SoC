#include "mmap_soc.h"

int verif(int *test, int *golden, int size) {
    for (int i = 0; i < size; ++i) {
        if (test[i] != golden[i]) {
            /* TM_ERROR="[%d] = %x, expect is %x, fail", i, test[i], golden[i] */
        }
        else {
            /* TM_INFO="[%d] = %x, expect is %x, pass", i, test[i], golden[i] */
        }
    }
    *TMDL_TM_SIMEND_32P = 1;
    return 1;
}
