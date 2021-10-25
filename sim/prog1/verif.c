int verif(int *test, int *golden, int size) {
    for (int i = 0; i < size; ++i) {
        if (test[i] != golden[i]) 
            return 0xdead << 16 | i;
    }
    return 0xcafecafe;
}
