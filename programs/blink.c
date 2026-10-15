// blink.c - counts up in binary on the leds

#define LEDS (*(volatile unsigned int *)0x80000000)

// wastes time so the count is slow enough to see
void delay(void) {
    for (volatile int i = 0; i < 1000000; i++) {
    }
}

int main(void) {
    unsigned int count = 0;

    while (1) {
        LEDS = count;
        count = count + 1;
        delay();
    }

    return 0; 
}