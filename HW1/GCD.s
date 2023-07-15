.data
msg1:	.asciiz "Enter first number: "
msg2:	.asciiz "Enter second number: "
msg3:	.asciiz "The GCD is: "

.text
.globl main
#------------------------- main -----------------------------
main:
# print msg1 on the console interface
	li	$v0, 4
	la	$a0, msg1
	syscall
# read the input integer in $v0
	li	$v0, 5
	syscall
	move	$a1, $v0
# print msg2 on the console interface
	li	$v0, 4
	la	$a0, msg2
	syscall
# read the input integer in $v0
	li	$v0, 5
	syscall
	move	$a2, $v0
# jump to GCD
	jal GCD
	
# print msg3 on the console interface
	li	$v0, 4
	la	$a0, msg3
	syscall
# print the result of procedure factorial on the console interface
	move $a0 $a1
	li $v0, 1
	syscall
	
	li $v0, 10
	syscall

#------------------------- GCD-----------------------------
.text
GCD:	
	rem $t0, $a1, $a2
	
	move $t1, $a1
	move $a1, $a2
	rem $a2, $t1,$a2
	
	bne $t0, $zero, GCD
	jr $ra 
	
	
