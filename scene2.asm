.data 0x0000
.text 0x0000
start:
    lui $26, 0xFFFF
    ori $26, $26, 0xF000
    ori $27, $zero, 10000
    ori $s0, $zero, 0
    ori $s1, $zero, 1
    ori $s2, $zero, 2
    ori $s3, $zero, 3
    ori $s4, $zero, 4
    ori $s5, $zero, 5
    ori $s6, $zero, 6
    ori $s7, $zero, 7
    ori $t0, $zero, 0
    ori $sp, $zero, 0x8000

    caseloop:
        lw $t1, 0xC70($26)
        lw $t0, 0xC73($26)
        beq $t0, $s0, caseloop
        sw $zero, 0xC60($26)
        sw $zero, 0xC62($26)

        beq $t1, $s0, case0
		beq $t1, $s1, case1
		beq $t1, $s2, case2
		beq $t1, $s3, case3
		beq $t1, $s4, case4
		beq $t1, $s5, case5
		beq $t1, $s6, case6
		beq $t1, $s7, case7
        j caseloop

    case0:
        jal sleep
        case0loop:
            lw $t6, 0xC72($26)
            sw $t6, 0xC60($26)
            lw $t0, 0xC73($26)
            beq $t0, $s0, case0loop
        ori $t1, $zero, 0
        ori $t2, $zero, 0
        beq $t6, $zero, case0sum
        slt $t1, $t6, $zero
        beq $t1, $zero, case0calc
        jal sleep
        j case0neg
        case0calc:
            addi $t2, $t2, 1
            add $t1, $t1, $t2
            bne $t2, $t6, case0calc
        j case0sum
        case0neg:
            ori $t4, $zero, 0
            case0flickerloop1:
                ori $t3, $zero, 0xFF
                sw $t3, 0xC62($26)
                addi $t4, $t4, 1
                bne $t4, $27, case0flickerloop1
            ori $t5, $zero, 0
            ori $t6, $zero, 100
            case0flickerignore:
                ori $t4, $zero, 0
                case0flickerloop2:
                    ori $t3, $zero, 0
                    sw $t3, 0xC62($26)
                    addi $t4, $t4, 1
                    bne $t4, $27, case0flickerloop2
                addi $t5, $t5, 1
                bne $t5, $t6, case0flickerignore
            lw $t0, 0xC73($26)
            beq $t0, $s0, case0neg
            sw $zero, 0xC60($26)
            jal sleep
            j caseloop
        case0sum:
            sw $t1, 0xC60($26)
            srl $t1, $t1, 8
            sw $t1, 0xC62($26)
            jal sleep
            j caseloop
    
    case1:
        jal sleep
        case1loop:
            lw $t6, 0xC72($26)
            sw $t6, 0xC60($26)
            lw $t0, 0xC73($26)
            beq $t0, $s0, case1loop
        andi $t6, $t6, 0xFF
        ori $t1, $zero, 0
        addu $a0, $t6, $zero
        jal case1rec
        j case1exit
        case1rec:
            addi $sp, $sp, -8
            sw $ra, 4($sp)
            sw $a0, 0($sp)
            addi $t1, $t1, 2
            bne $a0, $zero, case1label
            addiu $v0, $v0, 0
            addi $sp, $sp, 8
            jr $ra
        case1label:
            addi $a0, $a0, -1
            jal case1rec
            lw $a0, 0($sp)
            lw $ra, 4($sp)
            addi $t1, $t1, 2
            addi $sp, $sp, 8
            addu $v0, $v0, $a0
            jr $ra
        case1exit:
            sw $t1, 0xC60($26)
            srl $t1, $t1, 8
            sw $t1, 0xC62($26)
            jal sleep
            j caseloop

    case2:
        jal sleep
        case2loop:
            lw $t6, 0xC72($26)
            sw $t6, 0xC62($26)
            lw $t0, 0xC73($26)
            beq $t0, $s0, case2loop
        andi $t6, $t6, 0xFF
        ori $v0, $zero, 0
        addu $a0, $t6, $zero
        jal case2rec
        j case2exit
        case2rec:
            addi $sp, $sp, -8
            sw $ra, 4($sp)
            sw $a0, 0($sp)
            ori $t2, $zero, 0
            ori $t4, $zero, 400
            case2showo:
                ori $t3, $zero, 0
                case2showi:
                    sw $a0, 0xC60($26)
                    srl $t7, $a0, 8
                    sw $t7, 0xC62($26)
                    addi $t3, $t3, 1
                    bne $t3, $27, case2showi
                addi $t2, $t2, 1
                bne $t2, $t4, case2showo
            bne $a0, $zero, case2label
            
            addiu $v0, $v0, 0
            addi $sp, $sp, 8
            jr $ra
        case2label:
            addi $a0, $a0, -1
            jal case2rec
            lw $a0, 0($sp)
            lw $ra, 4($sp)
            addi $sp, $sp, 8
            addu $v0, $a0, $v0
            jr $ra
        case2exit:
            jal sleep
            sw $zero, 0xC60($26)
            j caseloop

    case3:
        jal sleep
        case3loop:
            lw $t6, 0xC72($26)
            sw $t6, 0xC62($26)
            lw $t0, 0xC73($26)
            beq $t0, $s0, case3loop
        andi $t6, $t6, 0xFF
        ori $t1, $zero, 0
        addu $a0, $t6, $zero
        jal case3rec
        j case3exit
        case3rec:
            addi $sp, $sp, -8
            sw $ra, 4($sp)
            sw $a0, 0($sp)
            bne $a0, $zero, case3label
            addiu $v0, $v0, 0
            addi $sp, $sp, 8
            jr $ra
        case3label:
            addi $a0, $a0, -1
            jal case3rec
            lw $a0, 0($sp)
            lw $ra, 4($sp)
            addi $sp, $sp, 8
            addu $v0, $a0, $v0
            ori $t2, $zero, 0
            ori $t4, $zero, 400
            case3showo:
                ori $t3, $zero, 0
                case3showi:
                    sw $a0, 0xC60($26)
                    srl $t7, $a0, 8
                    sw $t7, 0xC62($26)
                    addi $t3, $t3, 1
                    bne $t3, $27, case3showi
                addi $t2, $t2, 1
                bne $t2, $t4, case3showo
            jr $ra
        case3exit:
            jal sleep
            sw $zero, 0xC60($26)
            j caseloop

    case4:
        jal sleep
        case4loopa:
            lw $t6, 0xC72($26)
            sw $t6, 0xC60($26)
            lw $t0, 0xC73($26)
            beq $t0, $s0, case4loopa
        jal sleep
        case4loopb:
            lw $t7, 0xC72($26)
            sw $t7, 0xC60($26)
            lw $t0, 0xC73($26)
            beq $t0, $s0, case4loopb
        ori $t5, $zero, 0
        add $t1, $t6, $t7
        xor $t2, $t6, $t7
        andi $t2, $t2, 0x80
        bne $t2, $zero, case4exit
        xor $t3, $t1, $t6
        andi $t3, $t3, 0x80
        beq $t3, $zero, case4exit
        ori $t5, $zero, 1
        case4exit:
            sw $t1, 0xC60($26)
            sw $t5, 0xC62($26)
            jal sleep
            j caseloop

    case5:
        jal sleep
        case5loopa:
            lw $t6, 0xC72($26)
            sw $t6, 0xC60($26)
            lw $t0, 0xC73($26)
            beq $t0, $s0, case5loopa
        jal sleep
        case5loopb:
            lw $t7, 0xC72($26)
            sw $t7, 0xC60($26)
            lw $t0, 0xC73($26)
            beq $t0, $s0, case5loopb
        ori $t5, $zero, 0
        sub $t1, $t6, $t7
        xor $t2, $t6, $t7
        andi $t2, $t2, 0x80
        beq $t2, $zero, case5exit
        xor $t3, $t1, $t6
        andi $t3, $t3, 0x80
        beq $t3, $zero, case5exit
        ori $t5, $zero, 1
        case5exit:
            sw $t1, 0xC60($26)
            sw $t5, 0xC62($26)
            jal sleep
            j caseloop

    case6:
        jal sleep
        case6loopa:
            lw $t6, 0xC72($26)
            sw $t6, 0xC60($26)
            lw $t0, 0xC73($26)
            beq $t0, $s0, case6loopa
        jal sleep
        case6loopb:
            lw $t7, 0xC72($26)
            sw $t7, 0xC60($26)
            lw $t0, 0xC73($26)
            beq $t0, $s0, case6loopb
        mult $t6, $t7
        mflo $t1
        sw $t1, 0xC60($26)
        srl $t1, $t1, 8
        sw $t1, 0xC62($26)
        jal sleep
        j caseloop

    case7:
        jal sleep
        case7loopa:
            lw $t6, 0xC72($26)
            sw $t6, 0xC60($26)
            lw $t0, 0xC73($26)
            beq $t0, $s0, case7loopa
        jal sleep
        case7loopb:
            lw $t7, 0xC72($26)
            sw $t7, 0xC60($26)
            lw $t0, 0xC73($26)
            beq $t0, $s0, case7loopb
        sw $zero, 0xC62($26)
        div $t6, $t7
        jal sleep
        mflo $t6
        mfhi $t7
        ori $t3, $zero, 1000
        ori $t4, $zero, 4
        ori $t5, $zero, 0
        case7show:
            ori $t1, $zero, 0
            case7showquotiento:
                ori $t2, $zero, 0
                case7showquotienti:
                    sw $t6, 0xC60($26)
                    addi $t2, $t2, 1
                    bne $t2, $27, case7showquotienti
                addi $t1, $t1, 1
                bne $t1, $t3, case7showquotiento
            ori $t1, $zero, 0
            case7showremaindero:
                ori $t2, $zero, 0
                case7showremainderi:
                    sw $t7, 0xC60($26)
                    addi $t2, $t2, 1
                    bne $t2, $27, case7showremainderi
                addi $t1, $t1, 1
                bne $t1, $t3, case7showremaindero
            addi $t5, $t5, 1
            bne $t5, $t4, case7show
        sw $zero, 0xC60($26)
        jal sleep
        j caseloop

            
    sleep:
        ori $t0, $zero, 100
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