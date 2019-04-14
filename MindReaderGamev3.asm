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


displayList:   .space 64    	#store the display integer
storeList:	.space 64	#store integers not used
userList:	.space 64	#store the numbers based on user choose 
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
	
	addi $a1, $zero, 63	#the maximum number for generate - 1
	la $a2, displayList	#$a2 is the list that will have its values moved
	la $a3, userList	#$a3 is the list that will have values moved into it
	addi $s0, $zero, 32	
	jal randGen
	
	addi $s0, $zero, 32	#tells the printList function to only print 32 numbers
	la $a2, userList	#this is the list that will be printed
	jal printList
	j Exit
	
	#initilizes displayList with all possible numbers
initList:
    	addi $t0, $zero, 0    	#the counter for how many times to execute the loop
    	addi $t1, $zero, 1    	#the number being added to the array
    	la $t2, displayList     #address of list start
loop1:  beq $t0, $s0, return    #if the loop counter is at the max size of the array, end the subroutine
    	sb $t1, ($t2)        	#list[$t0] = $t1
    	addi $t0, $t0, 1    	#increment the variables
    	addi $t1, $t1, 1
    	addi $t2, $t2, 1
    	j loop1
    	
    	#generates a random number between 1 and $a1
    	#PRE-CONDITION: $a2 is the address of the original array, $a3 is the address of the new/changed array
    	#		$a1 will contain the maximum number that can be generated - 1 (if you want 64 as the max number, $a1 should be 63)
    	#		$s0 will contain the number of times to execute this loop
    	#POST-CONDITION:	the array at $a2 will have half of its values set to -1 to denote that they were used,
 	#			the array at $a3 will contain the values extracted from $a2
randGen:
	addi $t0, $zero, 0	#$t0 is the counter for how many times the loop is run
	add $t1, $zero, $s0	#$t1 is the exit condition for the loop, when $t0 == $t1, exit loop
	move $t3, $a3		#moves the address for the new list into $t3
loop2:	beq $t0, $t1, return	#exit condition for the loop, when $t0 == $t1, exit loop
	addi $v0, $zero, 42	#loads the system function number for the random number generator into $v0
	syscall
	
	addi $a0, $a0, 1	#changes the range of the random number from 0-63 to 1-64
	move $t2, $a2		#loads the address of the array into $t2
	add $t2, $t2, $a0	#offsets the address by the random number
	lb $t4, ($t2)		#loads the number stored at the new address within the array
	beq $t4, -1, loop2	#if the number that was randomly selected was already selected, try another random number
	addi $a0, $zero, -1	#$a0 is not used for the rest of the loop so it is repourposed to temporarily store -1
	sb $a0, ($t2)		#replaces the number extracted from the original array with -1 so we know its been used
	sb $t4, ($t3)		#stores the extracted value into the new array
	
	addi $t3, $t3, 1	#increments the address of the new array
	addi $t0, $t0, 1	#increments the counter for the loop
	j loop2			#return to the head of the loop
	
	#PRE-CONDITION:	$a2 will contain the address of the list to be printed
	#		$s0 is the amount of numbers to be printed
	#POST-CONDITION:	pList will contain the ascii equivilent of the numbers stored at $a2
	#			the contents of pList will be displayed
printList:
	addi $t0, $zero, 0	#counter for how many times the loop executed
	addi $t1, $zero, 0	#stores the value at list[$t0]
	move $t2, $a2		#address of the start for list
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
	addi $v0, $zero, 59	#loads the code for "Message Dialog Screen" into $v0
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
