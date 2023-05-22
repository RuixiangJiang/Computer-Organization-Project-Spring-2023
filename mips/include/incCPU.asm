.include "/mips/macro/macroCPU.asm"
.include "/mips/macro/macroLED.asm"

initCPU:
	la $gp 0xFFFFFC00 # io relative address
	la $sp 256 # stack ptr
	la $fp 512 # data base ptr
    li $s0, 44
	addi $sp, $sp, -16 # suppurt 4 variables
	addi $k0, $sp, 0 # LED ptr
	saveBeforeCall($ra)

    allLEDoff()
    sleep(100)
    allLEDon()
    sleep(1000)
    allLEDoff()
    loadBeforeReturn($ra)
    jr $ra

sleep:
	sll $t1 $v0 4  # 23=16+8-1
	sll $t0 $v0 3
	add $t0 $t0 $t1 
	sub $v0 $t0 $v0 
	sll $t1 $v0 10 # 1000=1024-16-8
	sll $t2 $v0 4
	sll $t0 $v0 3
	sub $v0  $t1 $t2
	sub $v0  $v0 $t0
	loop_sleep:
		addi $v0 $v0 -1
		bne $v0 $zero loop_sleep
	jr $ra

decode: # switch -> $a0  enter -> $a1
	lw $a0, 0xC70($gp) # rightmost switch[3] - control
	lw $a1, 0xC73($gp) # enter button
	jr $ra

read: # data -> $a0
	saveBeforeCall($ra)
    setControlLEDtrue(4)
	readWhile:
		sleep(100) # wait till switch signal be stable
		jal decode
		beq $a0, $a2, ifCaseEditedEnd # the input case is edited
			loadBeforeReturn($ra)
            setControlLEDfalse(4)
			j start
		ifCaseEditedEnd:
	bne $a1, $0, readWhile # wait till $a1 = 0
    setControlLEDfalse(4)
	readWaitEnter:
		sleep(300)
        setControlLEDneg(4)
		jal decode
		loadBeforeReturn($ra)
		bne $a0, $a2, start
		saveBeforeCall($ra)
		lw $a0, 0xC70($gp)
		srl $a0, $a0, 16
		jal writeDatatoLED
	beq $a1, $0, readWaitEnter # wait till enter = 1
	saveBeforeCall($a0)
	li $a0, 0
	jal writeDatatoLED # empty the input
    setControlLEDfalse(4)
    setControlLEDneg(3)
    setControlLEDneg(2)
	sleep(400)
    setControlLEDneg(3)
    setControlLEDneg(2)
	loadBeforeReturn($a0)
	loadBeforeReturn($ra)
	jr $ra

writeControltoLED: # print $a0 to right LED
    sw $a0, 0($k0)
    flushLED()
    jr $ra

writeDatatoLED: # print $a0 to left LED
    sw $a0, 4($k0)
    flushLED()
    jr $ra

changeControlLEDto: # change Control LED[$v0] to $v1
    lw $t1, 0($k0)
    andi $v1, $v1, 1
    bne $v1, $0, ifChangetrue
        # change to 0
        li $t2, 0xFFFFFFFF
        sllv $v1, $v1, $v0
        and $v1, $v1, $t2
        and $t1, $t1, $v1
        j ifEndchange
    ifChangetrue:
        # change to 1
        sllv $v1, $v1, $v0
        or $t1, $t1, $v1
    ifEndchange:
    sw $t1, 0($k0)
    flushLED()
    jr $ra

changeControlLEDneg: # change Control LED[$v0] to the negation
    lw $t1, 0($k0)
    li $t0, 1
    sllv $v1, $t0, $v0
    xor $t1, $t1, $v1
    sw $t1, 0($k0)
    flushLED()
    jr $ra

exception: # the input data causes exception
    saveBeforeCall($ra)
    warnLED()
    sleep(500)
    warnLED()
    loadBeforeReturn($ra)
    jr $ra