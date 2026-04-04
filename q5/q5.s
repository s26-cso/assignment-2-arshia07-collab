.section .rodata

filename: .string "input.txt"
yes_String:  .string "Yes"
no_String:   .string "No"

.section .text

.globl main

main:

    # s0 = fd tells which file
    # s1 = left pointer
    # s2 = right pointer
    # t0 = left character
    # t1 = right character

    addi sp, sp, -32
    sd ra, 24(sp)
    sd s0, 16(sp)
    sd s1, 8(sp)
    sd s2, 0(sp)

    # open("input.txt", O_RDONLY)
    la a0, filename       # a0 = filename
    li a1, 0              # a1 = O_RDONLY
    li a7, 1024           # syscall to open
    ecall
    mv s0, a0             # s0 = fd

    # size = lseek(fd, 0, SEEK_END)
    mv a0, s0
    li a1, 0
    li a2, 2              # SEEK_END
    li a7, 1025           # syscall to lseek
    ecall

    mv s2, a0             # s2 = size
    addi s2, s2, -1       # right = size - 1 (last byte index)
    mv s1, x0              # left = 0


loop:

    # if (left >= right) then it is a palindrome
    bge s1, s2, yes


    # lseek(fd, left, SEEK_SET)
    mv a0, s0
    mv a1, s1
    li a2, 0              # SEEK_SET
    li a7, 1025
    ecall


    # read(fd, &buf, 1)
    mv a0, s0
    addi a1, sp, 28       # temp buffer (inside stack frame)
    li a2, 1
    li a7, 63             # syscall: read
    ecall


    lb t0, 28(sp)         # t0 = left char


    # lseek(fd, right, SEEK_SET)
    mv a0, s0
    mv a1, s2
    li a2, 0
    li a7, 1025
    ecall

    # read(fd, &buf, 1)
    mv a0, s0
    addi a1, sp, 29       # temp buffer (inside stack frame)
    li a2, 1
    li a7, 63
    ecall

    lb t1, 29(sp)         # t1 = right char

    # if right char is newline, skip it and re-read
    li t2, 10             # '\n' = ASCII 10
    bne t1, t2, compare
    addi s2, s2, -1       # right-- to skip newline
    # lseek(fd, right, SEEK_SET)
    mv a0, s0
    mv a1, s2
    li a2, 0
    li a7, 1025
    ecall
    # read(fd, &buf, 1)
    mv a0, s0
    addi a1, sp, 29       # temp buffer (inside stack frame)
    li a2, 1
    li a7, 63
    ecall
    lb t1, 29(sp)         # t1 = right char (after skipping newline)

compare:
    bne t0, t1, no


    addi s1, s1, 1        # left++
    addi s2, s2, -1       # right--
    j loop


yes:
    la a0, yes_String
    li a7, 4              # syscall: print string
    ecall
    j done


no:
    la a0, no_String
    li a7, 4              # syscall: print string
    ecall

done:
    ld ra, 24(sp)
    ld s0, 16(sp)
    ld s1, 8(sp)
    ld s2, 0(sp)
    addi sp, sp, 32
    ret