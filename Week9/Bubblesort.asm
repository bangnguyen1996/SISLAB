               .data        0x10010000
blank:                .asciiz        " "                                # 4097
newline:        .asciiz        "\n"                                # 4097 + 2

#input_start
Alength:        .word        13
Aarray:                .word        130, 202, 30, 4440, 530, 532, 33, 204, 8, 524, 8933, 92, 10
#input_end

               .text
Quicksort:        
               slt        $t0, $a1, $a2                        # a1(=p):starting position        a2(=r):ending position
               beq        $t0, $zero, Quicksort_end        # if a1>=a2 branch to Quicksort_end
               ori        $t0, $t0, 0                        # nop

               subu        $sp, $sp, 16
               sw        $ra, 16($sp)                        # save return address
               sw        $a0, 12($sp)                        # a0 is the base address of an array (=A[])
               sw        $a1, 8($sp)
               sw        $a2, 4($sp)                        # save a0, a1, a2 to call sub-procedure
               jal        Partition                        # call Partition(A[], p, r) : same argument as current procedure

               subu        $sp, $sp, 4
               sw        $v0, 4($sp)                        # save return value of Partition (=q)
               lw        $a0, 16($sp)
               lw        $a1, 12($sp)                        # load A[], p
               ori        $a2, $v0, 0                        # move q to a2
               jal        Quicksort                        # call Quicksort(A[], p, q)

               lw        $a0, 16($sp)                        # load A[]
               lw        $t0, 4($sp)                        # load q
               addi        $a1, $t0, 1                        # a1 = q + 1
               lw        $a2, 8($sp)                        # load r
               jal        Quicksort                        # Quicksort(A[], q+1, r)
               ori        $t0, $t0, 0                        # nop

               addu        $sp, $sp, 20                        # pop A[], p, r, q, ra
               lw        $ra, 0($sp)                        # restore reaturn address

Quicksort_end:        jr        $ra                                # return


Partition:
               add        $t0, $a1, $a1
               add        $t0, $t0, $t0                        # t0 = a1 * 4
               add        $t0, $t0, $a0                        # t0 = A[] + t0
               lw        $t0, 0($t0)                        # t0 = A[p]        : x

               addi        $t1, $a1, -1                        # i = p-1
               addi        $t2, $a2, 1                        # j = r+1

               add        $t3, $t1, $t1
               add        $t3, $t3, $t3
               add        $t3, $t3, $a0                        # t3 = address of A[i] to minimize the loop
               add        $t4, $t2, $t2
               add        $t4, $t4, $t4
               add        $t4, $t4, $a0                        # t4 = address of A[j]

Loop1:                addi        $t1, $t1, 1                        # i = i+1
               addi        $t3, $t3, 4                        # t3 = t3 + 4 : reset the address of A[i]
               lw        $t5, 0($t3)
               slt        $t6, $t5, $t0
               bne        $t6, $zero, Loop1                # if A[i] < x, branch to Loop2
               ori        $t0, $t0, 0                        # nop

Loop2:                addi        $t2, $t2, -1                        # j = j-1
               addi        $t4, $t4, -4                        # t4 = t4 - 4 : reset the address of A[j]
               lw        $t5, 0($t4)
               slt        $t6, $t0, $t5
               bne        $t6, $zero, Loop2                # if A[j] > x, branch to Loop1

               slt        $t5, $t1, $t2
               beq        $t5, $zero, Partition_end        # if i >= j, branch to Partition_end

               lw        $t5, 0($t3)
               lw        $t6, 0($t4)
               sw        $t6, 0($t3)
               sw        $t5, 0($t4)                        # swap A[i] and A[j]
               beq        $zero, $zero, Loop1

Partition_end:        addu        $v0, $zero, $t2                        # v0 = j
               jr        $ra                                # return


PrintArray:
               beq        $a1, $zero, PrintArray_end        # if length == 0, branch to PrintArray_end
               addi        $s0, $a0, 0                        # move A[] to s0
               addi        $s1, $a1, 0                        # move length to s1
               addi        $t0, $zero, 0                        # t0 = 0

Loop3:                add        $t1, $s0, $t0                        # t1 = A[] + t0
               lw        $a0, 0($t1)                        # load A[] + t0
               ori        $v0, $zero, 1                        # v0 = 1
               syscall                                        # print int
               ori        $v0, $zero, 4                        # v0 = 4
               lui        $a0, 4097                        # address of blank
               syscall                                        # print string " "
               addi        $s1, $s1, -1                        # s1 = s1 -1
               addi        $t0, $t0, 4                        # t0 = t0 + 4 (next element)
               bne        $s1, $zero, Loop3                # if s1 != 0, branch to Loop3

PrintArray_end:        ori        $v0, $zero, 4                        # v0 = 4
               lui        $a0, 4097
               ori        $a0, $a0, 2                        # address of newline
               syscall                                        # print string "\n"
               jr        $ra                                # return


main:
               lui        $t0, 4097
               ori        $a0, $t0, 8                        # address of A[]
               lw        $a1, 4($t0)                        # load length
               jal        PrintArray

               lui        $t0, 4097
               ori        $a0, $t0, 8                        # address of A[]
               lw        $t0, 4($t0)                        # load length
               addi        $a2, $t0, -1                        # length - 1
               ori        $a1, $zero, 0                        # a1 = 0
               jal        Quicksort
               ori        $t0, $t0, 0                        # nop

               lui        $t0, 4097
               ori        $a0, $t0, 8                        # address of A[]
               lw        $a1, 4($t0)                        # address of length
               jal        PrintArray