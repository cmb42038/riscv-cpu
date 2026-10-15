// io_test.c - tests the leds and switches

#define LEDS     (*(volatile unsigned int *)0x80000000)
#define SWITCHES (*(volatile unsigned int *)0x80000004)

int main(void) {
    LEDS = 5;                // turn on leds 0 and 2, binary 101
    int first = LEDS;        // read the leds back == 5
    LEDS = SWITCHES + 1;     // show switches on the leds, plus one
    return first;            // ends in a0
}