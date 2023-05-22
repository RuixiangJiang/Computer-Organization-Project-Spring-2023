.include "/mips/macro/macroCPU.asm"
.include "/mips/macro/macroLED.asm"

.data
.text
    jal initCPU
init:
    lui $26, 0xFFFF
    ori $26, $26, 0xFC00
begin:
    lw $1, 0x72($26)
    sw $1, 0x62($26)
    j begin

.include "/mips/include/incCPU.asm"