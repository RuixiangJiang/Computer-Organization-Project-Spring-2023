.include "/mips/macro/macroCPU.asm"
.include "/mips/macro/macroLED.asm"

init:
	la $gp 0xFFFFFC00 # io relative address
	la $sp 256 # stack ptr
	la $fp 512 # data base ptr
    li $s0, 44
	addi $sp, $sp, -16 # suppurt 4 variables
	addi $k0, $sp, 0 # LED ptr
	saveBeforeCall($ra)

writeControltoLED: # print $a0
    sw $a0, 4($k0)
