.section .rodata

filename: .string "input.txt"
yes_String:  .string "Yes\n"
no_String:   .string "No\n"

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

    # openat(AT_FDCWD, "input.txt", O_RDONLY)
    li a0, -100           # AT_FDCWD
    la a1, filename       # a1 = filename
    li a2, 0              # a2 = O_RDONLY
    li a3, 0
    li a7, 56             # syscall: openat
    ecall
    mv s0, a0             # s0 = fd

    # size = lseek(fd, 0, SEEK_END)
    mv a0, s0
    li a1, 0
    li a2, 2              # SEEK_END
    li a7, 62             # syscall: lseek
    ecall

    mv s2, a0             # s2 = size
    addi s2, s2, -1       # right = size - 1 (last byte index)
    mv s1, x0              # left = 0

    # peek at last byte to check for trailing newline
    mv a0, s0
    mv a1, s2
    li a2, 0              # SEEK_SET
    li a7, 62             # syscall: lseek
    ecall
    mv a0, s0
    addi a1, sp, 28       # temp buffer (inside stack frame)
    li a2, 1
    li a7, 63             # syscall: read
    ecall
    lb t0, 28(sp)
    li t1, 10             # '\n' = ASCII 10
    bne t0, t1, loop      # no trailing newline, right is already correct
    addi s2, s2, -1       # trailing newline found, skip it


loop:

    # if (left >= right) then it is a palindrome
    bge s1, s2, yes


    # lseek(fd, left, SEEK_SET)
    mv a0, s0
    mv a1, s1
    li a2, 0              # SEEK_SET
    li a7, 62             # syscall: lseek
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
    li a7, 62             # syscall: lseek
    ecall

    # read(fd, &buf, 1)
    mv a0, s0
    addi a1, sp, 29       # temp buffer (inside stack frame)
    li a2, 1
    li a7, 63
    ecall

    lb t1, 29(sp)         # t1 = right char


    bne t0, t1, no


    addi s1, s1, 1        # left++
    addi s2, s2, -1       # right--
    j loop


yes:
    li a0, 1              # fd = stdout
    la a1, yes_String
    li a2, 4              # length of "Yes\n"
    li a7, 64             # syscall: write
    ecall
    j done


no:
    li a0, 1              # fd = stdout
    la a1, no_String
    li a2, 3              # length of "No\n"
    li a7, 64             # syscall: write
    ecall

done:
    ld ra, 24(sp)
    ld s0, 16(sp)
    ld s1, 8(sp)
    ld s2, 0(sp)
    addi sp, sp, 32
    li a0, 0              # exit code 0
    li a7, 93             # syscall: exit
    ecall
    