.data 0x0000
.text 0x0000
start:
lui $26, 0xFFFF
ori $26, $26, 0xF000
ori $t1, $zero, 1
ori $t2, $zero, 0
ori $t3, $zero, 10000
ori $t4, $zero, 0
ori $t5, $zero, 256
ori $t6, $zero, 50

loopo:
addi $t4, $t4, 1
loopi:
sw $t1, 0xC60($26)
sw $t1, 0xC62($26)
addi $t2, $t2, 1
bne $t2, $t3, loopi
ori $t2, $zero, 0
bne $t4, $t6, loopo

next:
ori $t4, $zero, 0
add $t1, $t1, $t1
bne $t1, $t5, loopo

j start