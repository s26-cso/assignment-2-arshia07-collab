.section .rodata

filename: .string "input.txt"
yes_String:  .string "Yes\n"
no_String:   .string "No\n"
mode:      .string "r"

.section .text

.globl main

main:

    # s0 = FILE* fp
    # s1 = left pointer
    # s2 = right pointer
    # t0 = left character
    # t1 = right character

    addi sp, sp, -32
    sd ra, 24(sp)
    sd s0, 16(sp)
    sd s1, 8(sp)
    sd s2, 0(sp)

    # fp = fopen("input.txt", "r")
    la a0, filename       # a0 = filename
    la a1, mode         # a1 = "r"
    call fopen
    mv s0, a0             # s0 = FILE* fp

    # fseek(fp, 0, SEEK_END)
    mv a0, s0
    li a1, 0
    li a2, 2              # SEEK_END
    call fseek

    # size = ftell(fp)
    mv a0, s0
    call ftell
    mv s2, a0             # s2 = size
    addi s2, s2, -1       # right = size - 1 (last byte index)
    mv s1, x0              # left = 0


    # peek at last byte to check for trailing newline
    mv a0, s0
    mv a1, s2
    li a2, 0              # SEEK_SET
    call fseek
    
    mv a0, s0
    call fgetc
    li t1, 10             # '\n' = ASCII 10
    bne a0, t1, loop      # no trailing newline, right is already correct
    addi s2, s2, -1       # trailing newline found, skip it


loop:

    # if (left >= right) then it is a palindrome
    bge s1, s2, yes


    # fseek(fp, left, SEEK_SET)
    mv a0, s0
    mv a1, s1
    li a2, 0              # SEEK_SET
    call fseek

    # t0 = fgetc(fp)
    mv a0, s0
    call fgetc
    mv t0, a0             # t0 = left char


    # fseek(fp, right, SEEK_SET)
    mv a0, s0
    mv a1, s2
    li a2, 0              # SEEK_SET
    call fseek

    # t1 = fgetc(fp)
    mv a0, s0
    call fgetc
    mv t1, a0             # t1 = right char


    bne t0, t1, no


    addi s1, s1, 1        # left++
    addi s2, s2, -1       # right--
    j loop


yes:
    la a0, yes_String
    call printf           # printf("Yes\n")
    j done


no:
    la a0, no_String
    call printf           # printf("No\n")

done:
    ld ra, 24(sp)
    ld s0, 16(sp)
    ld s1, 8(sp)
    ld s2, 0(sp)
    addi sp, sp, 32
    li a0, 0              # return 0 from main
    ret