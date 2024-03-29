#version 2 of the Mind Reader game
#@authour Kaitian Li
#update: 2019/4/6
	.data
introduction:
	.ascii  "Welcome to the Mind Reader game, think of a number between 1 and 64 and after 6 simple"
	.ascii	"\nquestions, the mind reader will know your number."
	.ascii  "\n\nSelect"
	.ascii  "\nYES - if you are ready to start"
	.ascii  "\nNO - to see the rules again"
	.asciiz "\nCancel - to exit the Game\n"
thankYou:	.asciiz "Thank you!"
newLine:	.asciiz "\n"
space:		.asciiz " "
yourNumber:	.asciiz "Do you see your number?\n"


list:   .space 64    	#space to store 64 integers
sList:	.space 64	#space for comparing numbers generated with possible numbers
pList:  .space 256	#space for 128 digits and formating ascii characters

	.text
main:
	#display instroduction
	li	$v0, 50
	la	$a0, introduction
	syscall
	
	beq $a0, 1, main	#user choose no, go back main
	beq $a0, 2, Exit	#user choose cancel, exit the program
	addi $s0, $zero, 64	#stores the max size of the array
	jal initList
	addi $a1, $zero, 64
	jal randGen
	jal printList
	j Exit
	
	#initilizes the list with all possible numbers
initList:
    	addi $t0, $zero, 0    	#the counter for how many times to execute the loop
    	addi $t1, $zero, 1    	#the number being added to the array
    	la $t2, list        	#address of list start
loop1:  beq $t0, $s0, return    #if the loop counter is at the max size of the array, end the subroutine
    	sb $t1, ($t2)        	#list[$t0] = $t1
    	addi $t0, $t0, 1    	#increment the variables
    	addi $t1, $t1, 1
    	addi $t2, $t2, 1
    	j loop1
    	
    	#generates a random number between 0 and $a0
randGen:
	addi $t0, $zero, 0
	addi $t1, $zero, 10
	la $t2, list
	la $t3, sList
loop2:	beq $t0, $t1, return
	addi $v0, $zero, 42
	addi $a0, $zero, 100
	syscall
	
	addi $v0, $zero, 1
	syscall
	
	addi $v0, $zero, 4
	la $a0, space
	syscall
	
	addi $t0, $t0, 1
	j loop2
	

printList:
	addi $t0, $zero, 0	#counter for how many times the loop executed
	addi $t1, $zero, 0	#stores the value at list[$t0]
	la $t2, list		#address of the start for list
	addi $t3, $zero, 0	#stores the lower didgit of $t1
	addi $t4, $zero, 0	#stores the upper didgit of $t1
	la $t5, pList		#address of the start of pList
	addi $t6, $zero, 10	#stores the number 10 for divion later
	addi $t7, $zero, 0x30	#stores a value for a comparison later
	addi $t8, $zero, 0x20	#stores the value of the ' ' character
	addi $t9, $zero, 3	#counter for when to add a "next line" character to the string
	
loop3:	beq $t0, $s0, display	#ends the loop once $t0 is at the end of the array
	lb $t1, ($t2)		#sets $t1 to the item at list[$t0]
	div $t1, $t6		
	mfhi $t3		#sets $t3 to the lower digit of $t1
	mflo $t4		#sets $t4 to the upper digit of t1
	
	addi $t3, $t3, 0x30	#converts the integers to their ascii equivilent
	addi $t4, $t4, 0x30	
	
	bne $t4, $t7, nxtLn	#if the upper digit is 0, change it to a ' ' character
	addi $t4, $zero, 0x20	
	
nxtLn:	sb $t4, ($t5)		#stores the upper digit or a ' ' into pList
	sb $t3, 1($t5)		#stores the lower digit into pList
	sb $t8, 2($t5)		#stores a ' ' character after the numbers
	
	bne $t9, $t6, increment	#after 8 integers are printed, add a "new line" character
	sb $t9, 3($t5)		#stores the "new line" character
	addi $t5, $t5, 1	#increments the pList pointer
	addi $t9, $zero, 2	#resets the counter for when to add a "new line" character
increment:
	addi $t0, $t0, 1	#increments all of the counters used
	addi $t2, $t2, 1
	addi $t5, $t5, 3
	addi $t9, $t9, 1
	j loop3
	
display:
	addi $v0, $zero, 59
	la $a0, yourNumber
	la $a1, pList
	syscall
	jr $ra

return:
	jr $ra

Exit:
	li	$v0, 55
	la 	$a0, thankYou
	li	$a1, 1
	syscall
	
	li	$v0, 10
	syscall
