# 0xFFFFFC62 - left LED[8]
# 0xFFFFFC60 - right LED[8]
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
    sw $t0, 0x62($gp)
    lw $t0, 0($k0)
    sw $t0, 0x60($gp)
.end_macro