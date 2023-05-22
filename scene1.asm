.data 0x0000
.text 0x0000
start:
    lui $26, 0xFFFF
    ori $26, $26, 0xF000
    ori $27, $zero, 32767
    ori $s0, $zero, 0
    ori $s1, $zero, 1
    ori $s2, $zero, 2
    ori $s3, $zero, 3
    ori $s4, $zero, 4
    ori $s5, $zero, 5
    ori $s6, $zero, 6
    ori $s7, $zero, 7
    ori $t0, $zero, 0

    caseloop:
        lw $t1, 0xC70($26)
        lw $t0, 0xC73($26)
        beq $t0, $s0, caseloop
        sw $zero, 0xC60($26)

        beq $t1, $s0, case0
		beq $t1, $s1, case1
		beq $t1, $s2, case2
		beq $t1, $s3, case3
		beq $t1, $s4, case4
		beq $t1, $s5, case5
		beq $t1, $s6, case6
		beq $t1, $s7, case7

    case0:
        jal sleep
        case0loop:
            lw $t6, 0xC72($26)
            sw $t6, 0xC62($26)
            lw $t0, 0xC73($26)
            beq $t0, $s0, case0loop
        case0continue:
            addi $t3, $t6, -1
            and $t3, $t3, $t6
            beq $t3, $zero, case0power
            jal sleep
            j caseloop
        case0power:
            sw $s1, 0xC60($26)
            jal sleep
            j caseloop

    case1:
        jal sleep
        case1loop:
            lw $t6, 0xC72($26)
            sw $t6, 0xC62($26)
            lw $t0, 0xC73($26)
            beq $t0, $s0, case1loop
        case1continue:
            andi $t3, $t6, 1
            bne $t3, $zero, case1odd
            jal sleep
            j caseloop
        case1odd:
            sw $s1, 0xC60($26)
            jal sleep
            j caseloop

    case2:
        jal sleep
        case2loopa:
            lw $t6, 0xC72($26)
            sw $t6, 0xC62($26)
            lw $t0, 0xC73($26)
            beq $t0, $s0, case2loopa
        jal sleep
        case2loopb:
            lw $t7, 0xC72($26)
            sw $t7, 0xC62($26)
            lw $t0, 0xC73($26)
            beq $t0, $s0, case2loopb
        or $t3, $t6, $t7
        sw $t3, 0xC60($26)
        jal sleep
        j caseloop
    
    case3:
        jal sleep
        case3loopa:
            lw $t6, 0xC72($26)
            sw $t6, 0xC62($26)
            lw $t0, 0xC73($26)
            beq $t0, $s0, case3loopa
        jal sleep
        case3loopb:
            lw $t7, 0xC72($26)
            sw $t7, 0xC62($26)
            lw $t0, 0xC73($26)
            beq $t0, $s0, case3loopb
        nor $t3, $t6, $t7
        sw $t3, 0xC60($26)
        jal sleep
        j caseloop

    case4:
        jal sleep
        case4loopa:
            lw $t6, 0xC72($26)
            sw $t6, 0xC62($26)
            lw $t0, 0xC73($26)
            beq $t0, $s0, case4loopa
        jal sleep
        case4loopb:
            lw $t7, 0xC72($26)
            sw $t7, 0xC62($26)
            lw $t0, 0xC73($26)
            beq $t0, $s0, case4loopb
        xor $t3, $t6, $t7
        sw $t3, 0xC60($26)
        jal sleep
        j caseloop

    case5:
        jal sleep
        case5loopa:
            lw $t6, 0xC72($26)
            sw $t6, 0xC62($26)
            lw $t0, 0xC73($26)
            beq $t0, $s0, case5loopa
        jal sleep
        case5loopb:
            lw $t7, 0xC72($26)
            sw $t7, 0xC62($26)
            lw $t0, 0xC73($26)
            beq $t0, $s0, case5loopb
        slt $t3, $t6, $t7
        sw $t3, 0xC60($26)
        jal sleep
        j caseloop

    case6:
        jal sleep
        case6loopa:
            lw $t6, 0xC72($26)
            sw $t6, 0xC62($26)
            lw $t0, 0xC73($26)
            beq $t0, $s0, case6loopa
        jal sleep
        case6loopb:
            lw $t7, 0xC72($26)
            sw $t7, 0xC62($26)
            lw $t0, 0xC73($26)
            beq $t0, $s0, case6loopb
        sltu $t3, $t6, $t7
        sw $t3, 0xC60($26)
        jal sleep
        j caseloop
    
    case7:
        jal sleep
        case7loopa:
            lw $t6, 0xC72($26)
            sw $t6, 0xC62($26)
            lw $t0, 0xC73($26)
            beq $t0, $s0, case7loopa
        jal sleep
        case7loopb:
            lw $t7, 0xC72($26)
            sw $t7, 0xC62($26)
            lw $t0, 0xC73($26)
            beq $t0, $s0, case7loopb
        jal sleep
        j caseloop

    sleep:
        ori $t0, $zero, 500
        ori $t4, $zero, 0
        ori $t5, $zero, 0
        sleepo:
            ori $t4, $zero, 0
            sleepi:
                addi $t4, $t4, 1
                bne $t4, $27, sleepi
            addi $t5, $t5, 1
            bne $t5, $t0, sleepo
        jr $ra

