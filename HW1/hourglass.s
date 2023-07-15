.data
msg1:	.asciiz "Enter the number n = "
msg2:   .asciiz "*"
msg3:	.asciiz " "
newrow: .asciiz "\n"

.text
.globl main
#------------------------- main -----------------------------
main:
# print msg1 on the console interface
		li      $v0, 4				
		la      $a0, msg1			
		syscall 
# read the input integer in $v0
		li      $v0, 5          	
  		syscall      
  		     
  		move 	$a1, $v0 
  		srl 	$t0, $a1, 1 
  		
  		add $t2, $0, $0		
		addi $t5, $0, 1 
		add $t3, $0, $0 
		add $t4, $0, $0
  		jal glass
  		
  		li $v0, 10	
  		syscall	
  		
#------------------------- function----------------------------- 	
.text
glass:		
	addi $sp, $sp, -4		
	sw $ra, 4($sp)
	jal up

up:		
	add $t3, $0, $0 
	add $t4, $0, $0 
	slt $t6, $t2, $t0
	beq $t6, $0, botinitial
	jal one
	add $t2, $t2, $t5
	beq $0, $0, up


one:		
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal space


space:	
	slt $t6, $t3, $t2
	beq $t6, $0, two
	li  $v0, 4				
	la  $a0, msg3			
	syscall 
	add $t3, $t3, $t5
	beq $0, $0, space
		

two:		
	li $s1, 2 
	mul $t7, $t2, $s1 
	sub $s2, $a1, $t7
	jal star
		

star:	
	slt $t6, $t4, $s2
	beq $t6, $0, Exit
	li  $v0, 4				
	la  $a0, msg2			
	syscall 
	add $t4, $t4, $t5
	beq $0, $0, star


Exit:		
	li $v0, 4
	la $a0, newrow
	syscall
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra


botinitial:	
	addi $t2, $a1, 1
  	srl $t2, $t2, 1
  	addi $t2, $t2, -1 
  	jal botstar


botstar:	
	add $t3, $0, $0 
	add $t4, $0, $0 
	slt $t6, $t2, $0
	bne $t6, $0, end
	jal one
	addi $t2, $t2, -1
	beq $0, $0, botstar
end:		
	lw $ra, 4($sp)
	addi $sp, $sp, 4
	jr $ra