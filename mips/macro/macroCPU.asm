.macro saveBeforeCall(%reg)
	addi $sp, $sp, -4
	sw %reg 0($sp)
.end_macro

.macro loadBeforeReturn(%reg)
	lw %reg 0($sp)
	addi $sp, $sp, 4
.end_macro

.macro sleep(%msec) # sleep for %msec ms
	la $v0, %msec
	jal sleep
.end_macro