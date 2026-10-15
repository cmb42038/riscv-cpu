// test_c.c - first C program for the cpu
// uses loads, stores, branches, loops and a function call
// no * or / because rv32i has no multiply or divide instructions
// the answer is returned from main and ends up in register a0 (x10)

// adds up an array, this tests lw and a loop with a branch
int add_up(int *nums, int count) {
    int total = 0;
    for (int i = 0; i < count; i++) {
        total = total + nums[i];
    }
    return total;
}

int main(void) {
    // first 10 fibonacci numbers, kept on the stack so it uses sw and lw
    int fib[10];
    fib[0] = 0;
    fib[1] = 1;
    for (int i = 2; i < 10; i++) {
        fib[i] = fib[i - 1] + fib[i - 2];
    }

    // single bytes, tests sb, lb and lbu
    signed char neg = -3;      // lb has to sign extend this back to -3
    unsigned char big = 200;   // lbu must NOT sign extend, should stay 200

    // 0+1+1+2+3+5+8+13+21+34 = 88, then 88 - 3 + 200 = 285
    int result = add_up(fib, 10) + neg + big;

    return result;
}
