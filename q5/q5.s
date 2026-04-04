.section .rodata
filename:   .string "input.txt"
mode:       .string "r"
yes_string: .string "Yes\n"
no_string:  .string "No\n"

.section .text
.globl main

main:
    # s0 = FILE* fp
    # s1 = left pointer
    # s2 = right pointer
    # t0 = left char
    # t1 = right char

    addi sp, sp, -32
    sd ra, 24(sp)
    sd s0, 16(sp)
    sd s1, 8(sp)
    sd s2, 0(sp)

    # fopen("input.txt", "r")
    la a0, filename
    la a1, mode
    call fopen
    mv s0, a0               # s0 = FILE* fp

    # fseek(fp, 0, SEEK_END)
    mv a0, s0
    li a1, 0
    li a2, 2                # SEEK_END
    call fseek

    # size = ftell(fp)
    mv a0, s0
    call ftell
    mv s2, a0               # s2 = size
    addi s2, s2, -1         # right = size - 1

    # peek at last byte to check for trailing newline
    mv a0, s0
    mv a1, s2
    li a2, 0                # SEEK_SET
    call fseek

    mv a0, s0
    call fgetc              # read last char
    li t1, 10               # '\n'
    bne a0, t1, loop        # no newline, skip
    addi s2, s2, -1         # trailing newline, move left

    mv s1, x0               # left = 0

loop:
    # if left >= right, it's a palindrome
    bge s1, s2, yes

    # fseek to left, read char
    mv a0, s0
    mv a1, s1
    li a2, 0                # SEEK_SET
    call fseek
    mv a0, s0
    call fgetc
    mv t0, a0               # t0 = left char

    # fseek to right, read char
    mv a0, s0
    mv a1, s2
    li a2, 0                # SEEK_SET
    call fseek
    mv a0, s0
    call fgetc
    mv t1, a0               # t1 = right char

    bne t0, t1, no          # chars don't match → not palindrome

    addi s1, s1, 1          # left++
    addi s2, s2, -1         # right--
    j loop

yes:
    la a0, yes_string
    call printf
    j done

no:
    la a0, no_string
    call printf

done:
    ld ra, 24(sp)
    ld s0, 16(sp)
    ld s1, 8(sp)
    ld s2, 0(sp)
    addi sp, sp, 32

    li a0, 0
    li a7, 93
    ecall