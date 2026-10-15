# start.S - the first code the cpu runs after reset
# C can't run until the stack pointer is set up, so this does that
# and then calls main()

    .section .text.start
    .globl _start
_start:
    li   sp, 0x400        # stack starts at the top of the 1 KB data memory
    call main             # run the C program, its return value ends up in a0 (x10)
done:
    j    done             # nothing left to do, so loop here forever
