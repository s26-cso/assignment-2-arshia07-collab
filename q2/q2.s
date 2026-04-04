.globl main
.section .rodata

fmt: .string "%lld "

newline: .string "\n"
.section .text

main:
    addi sp, sp, -64
    sd ra, 56(sp)
    sd s0, 48(sp)
    sd s1, 40(sp)
    sd s2, 32(sp)      
    sd s3, 24(sp)
    sd s4, 16(sp)
    sd s5, 8(sp)

    mv s0, a0          # s0 = argc
    mv s1, a1          # s1 = argv
    addi s0, s0, -1    # s0 = n = argc - 1

    # malloc arr
    slli a0, s0, 3
    call malloc
    mv s2, a0          # s2 = arr[]
    
    # malloc result
    slli a0, s0, 3
    call malloc
    mv s3, a0          # s3 = result[]

    # malloc stack 
    slli a0, s0, 3
    call malloc
    mv s4, a0          # s4 = stack[]

    li s5, -1          # s5 = top = -1
    li t0, 0           # loop counter

input_loop:
    bge t0, s0, read_done   # if loop counter = n-1 then go to read_done
    addi t1, t0, 1          # here t1 = t0 + 1 (we do this because we are skipping /a.out)

    slli t1, t1, 3          # to calculate offset
    add t1, s1, t1          # s1 acts as a pointer to argv so t1+s1 acts as pointer to that element
    ld a0, 0(t1)            # a0 = argv[i+1]

    addi sp, sp, -8         # save t0 around atoi call (atoi clobbers t registers)
    sd t0, 0(sp)
    call atoi               # converts a0 to int value as it reads it as string
    ld t0, 0(sp)            # restore t0

    addi sp, sp, 8
    slli t1, t0, 3          # we again restart the process 
    add t1, s2, t1          # this is for storing values in array
    sd a0, 0(t1)   

    slli t1, t0, 3          # yet again we do this this time for result (here we make all result as -1)
    add t1, s3, t1      
    li t2, -1
    sd t2, 0(t1)

    addi t0, t0, 1          # increment counter
    j input_loop

read_done:
    addi t0, s0, -1         # reset t0 to n-1

nge:
    blt t0, x0, nge_done    # we start from behind and the second it is less than 0 we got to nge_done
    
    slli t1, t0, 3
    add t1, s2, t1
    ld t3, 0(t1)

while:
    blt s5, x0, push        # initially s5 is -1 and when stack is empty it goes to push

    slli t1, s5, 3              # t1 = s5 * 8
    add t1, s4, t1              # t1 = t1 + s4 (t1 is the offset to reach top of stack)
    ld t4, 0(t1)                # t4 = index of value in array at top of stack

    slli t1, t4, 3              # here we are loading the value of that index from array into t5
    add t1, s2, t1
    ld t5, 0(t1)               

    bgt t5, t3, after_while     # arr[stack[top]] > arr[i] we continue to after-while

    addi s5, s5, -1             # s5 is basically maintaining count of the number of elements-1 in stack
    j while

after_while:
    slli t1, t0, 3              # t1 = offset which is i*8
    add t1, s3, t1              # we add this offset to the result array (t1 is now the address where we store the result)
    sd t4, 0(t1)      
    j push

push:
    addi s5, s5, 1              # increase size of stack
    slli t1, s5, 3
    add t1, s4, t1              # this is the top of stack memory location
    sd t0, 0(t1)                # we store t0 which is i in there
    addi t0, t0, -1             # decrease counter
    j nge

nge_done:
    mv t0, x0

print:
    bge t0, s0, done

    slli t1, t0, 3
    add t1, s3, t1              # result array
    ld a1, 0(t1)         

    la a0, fmt
    addi sp, sp, -8             # save t0 around printf call (printf clobbers t registers)
    sd t0, 0(sp)
    call printf

    ld t0, 0(sp)                # restore t0
    addi sp, sp, 8
    addi t0, t0, 1              # increment the loop
    j print

print_done:
    la a0, newline              # flush output with newline
    call printf

done:
    ld ra, 56(sp)
    ld s0, 48(sp)
    ld s1, 40(sp)
    ld s2, 32(sp)
    ld s3, 24(sp)
    ld s4, 16(sp)
    ld s5, 8(sp)
    addi sp, sp, 64
    ret
