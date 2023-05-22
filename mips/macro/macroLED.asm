# 0xFFFFFC62 - left LED[8]
# 0xFFFFFC60 - right LED[8]
# 0xFFFFFC73 - button
# 0xFFFFFC72 - left switch[8]
# 0xFFFFFC70 - right switch[8]

.macro allLEDon()
    li $a0, 0xFF
    jal writeControltoLED
    li $a0, 0xFFFF
    jal writeDatatoLED
.end_macro

.macro allLEDoff()
    li $a0, 0
    jal writeControltoLED
    li $a0, 0
    jal writeDatatoLED
.end_macro

.macro flushLED() # name???
    lw $t0, 4($k0)
    sw $t0, 0x62($gp) # left LED
    lw $t0, 0($k0)
    sw $t0, 0x60($gp) # right LED
.end_macro

.macro warnLED() # left LED flashing means warning
    lw $t7, 4($k0) # save the state of left LED
    li $a0, 0xFFFF
    jal writeDatatoLED
    sleep(500) # holds for 500ms
    addi $a0, $t7, $0 # restitution
    jal writeDatatoLED

.macro setControlLEDtrue(%index)
    li $v0, $index
    li $v1, 1
    jal changeControlLEDto
.end_macro

.macro setControlLEDfalse(%index)
    li $v0, $index
    li $v1, 0
    jal changeControlLEDto
.end_macro

.macro setControlLEDneg(%index)
    li $v0, $index
    jal changeControlLEDneg
.end_macro