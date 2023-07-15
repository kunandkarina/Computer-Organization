.data 
msg1: .asciiz "Enter the number n = "
msg2: .asciiz " is a prime"
msg3: .asciiz " is not a prime, the nearest prime is "
msg4:	.asciiz " "

.text
.globl main
#------------------------- main -----------------------------
main:
	li $v0, 4
	la $a0, msg1
	syscall
	li, $v0, 5
	syscall
	move $s0, $v0 			#s0 is the number
	li $s2, 2 
		
prime:
	mul $t0, $s2, $s2 
	bgt $t0, $s0, isP 
	#slt $t1, $s0, $t0
	#bne $t1, $zero, isP
	rem $t1, $s0, $s2
	beq $t1, $zero, notP
	addi $s2, $s2, 1
	j prime
	
isP:
	li, $v0, 1
	move $a0, $s0
	syscall
	li, $v0, 4
	la, $a0, msg2
	syscall
	li, $v0, 10
	syscall
	
notP:
	li, $v0, 1
	move $a0, $s0
	syscall
	li, $v0, 4
	la, $a0, msg3
	syscall
	li, $s2, 0
	j check2
	
check2:
	bne $s1, $zero, exit 		# s for flag
	li $s1, 0 			
	addi, $s2, $s2, 1
	add $s3, $s0, $s2 		# for n + i
	sub $s4, $s0, $s2 		# for n - i
	li, $s5, 2 		
	li, $s6, 2 			
	

prime_minus:
	mul $t0, $s6, $s6
	bgt $t0, $s3, pe
	#slt $t1, $s0, $t0
	#bne $t1, $zero, print_and_exit
	rem $t1, $s4, $s6
	beq $t1, $zero, prime_plus 
	addi $s6, $s6, 1
	j prime_minus
	
pe:
	li, $v0, 1
	move $a0, $s4
	syscall
	li $s1, 1
	li $v0, 4
	la $a0, msg4
	syscall

prime_plus:
	mul $t0, $s5, $s5
	bgt $t0, $s3, print 
	#slt $t1, $s0, $t0
	#bne $t1, $zero, print
	rem $t1, $s3, $s5  	
	beq $t1, $zero, check2 		
	addi $s5, $s5, 1
	j prime_plus
	
print:
	li, $v0, 1
	move $a0, $s3
	syscall
	li, $s1, 1 	
	
exit:
	li $v0, 10
	syscall
