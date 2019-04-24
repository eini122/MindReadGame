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
yourNumber:	.asciiz "Do you see your number?\n" #24 characters

list1:   .space 64    	#store the display integer
list2:	.space 32	#store integers not used
displayList:	.space 32	#store the numbers based on user choose 
pList:  .space 280	#space for 128 digits and formating ascii characters and the 24 bytes from "Do you see yourNumber\n"

	.text
main:	li $s2, 0	#A global variable used in the "refill" subroutine to give the appearance of picking random numbers to fill out the array 
	#display instroduction
	li	$v0, 50
	la	$a0, introduction
	syscall
	
	jal playSound
	
	beq $a0, 1, main	#user choose no, go back main
	beq $a0, 2, Exit	#user choose cancel, exit the program
	addi $s0, $zero, 64	#stores the max size of the array
	jal initList
	
	addi $a1, $zero, 63	#the maximum number for generate - 1
	la $a2, list1		#$a2 is the list that will have its values moved
	la $a3, list2		#$a3 is the list that will have values moved into it
	addi $a0, $zero, 32	
	jal randGen
	
	la $a0, list1		#the list to be condensed
	addi $a1, $zero, 64	#the size of the list to be condensed
	jal condenseList
	
	li $s0, 0	#counter for the loop
	li $s1, 16	#the amount of numbers to be transfered to the new list with each "randGen" call
	li $s3, 32	#the amount of numbers to be transfered to the unused numbers list
playGame:
	la $a0, displayList
	jal emptyList
	
	la $a0, list1
	la $a1, displayList
	li $a2, 32
	jal copyList
	
	jal initilizeRefill
	
	la $a0, displayList
	jal insertionSort

	beq, $s0, 6, Exit
	addi $a0, $zero, 32	#tells the printList function to only print 32 numbers
	la $a2, displayList	#this is the list that will be printed
	jal printList
	
	beq $a0, 2, Exit
	beq $a0, 0, yes
	
no:	la $a0, list1
	addi $a1, $s3, 0
	jal storeUnusedNumbers	#stores the unused numbers to memory to be used later for filling out the list of numbers
	
	la $a0, list2	#list being copied from
	la $a1, list1	#list being copied to
	addi $a2,$s3,0	#number of elements to copy
	jal copyList
	
	la $a0, list2	#we moved list 2 to list 1 then emptied list 2
	jal emptyList	#this means list 1 will always store the possible numbers
	
	j result
	
yes:	la $a0, list2
	addi $a1, $s3, 0
	jal storeUnusedNumbers	#stores the unused numbers to memory to be used later for filling out the list of numbers
	
	la $a0, list2	
	jal emptyList	#empties list2 as it doesn't contain the number that the user is thinking of
	
result:
	addi $a1, $zero, 31	#the maximum number for generate - 1
	la $a2, list1		#$a2 is the list that will have its values moved
	la $a3, list2		#$a3 is the list that will have values moved into it
	addi $a0, $s1, 0	#how many elements to copy/move
	jal randGen
	
	la $a0, list1
	jal insertionSort
	
	addi $s0, $s0, 1
	move $s3, $s1
	srl $s1, $s1, 1
	j playGame
	#initilizes list1 with all possible numbers
initList:
    	addi $t0, $zero, 0    	#the counter for how many times to execute the loop
    	addi $t1, $zero, 1    	#the number being added to the array
    	la $t2, list1     #address of list start
loop1:  beq $t0, $s0, return    #if the loop counter is at the max size of the array, end the subroutine
    	sb $t1, ($t2)        	#list[$t0] = $t1
    	addi $t0, $t0, 1    	#increment the variables
    	addi $t1, $t1, 1
    	addi $t2, $t2, 1
    	j loop1
    	
    	#generates a random number between 1 and $a1
    	#PRE-CONDITION: $a2 is the address of the original array, $a3 is the address of the new/changed array
    	#		$a1 will contain the maximum number that can be generated - 1 (if you want 64 as the max number, $a1 should be 63)
    	#		$a0 will contain the number of times to execute this loop
    	#POST-CONDITION:	the array at $a2 will have half of its values set to 99 to denote that they were used,
 	#			the array at $a3 will contain the values extracted from $a2
randGen:
	addi $t0, $zero, 0	#$t0 is the counter for how many times the loop is run
	add $t1, $zero, $a0	#$t1 is the exit condition for the loop, when $t0 == $t1, exit loop
	move $t3, $a3		#moves the address for the new list into $t3
loop2:	beq $t0, $t1, return	#exit condition for the loop, when $t0 == $t1, exit loop
	addi $v0, $zero, 42	#loads the system function number for the random number generator into $v0
	syscall
	
	addi $a0, $a0, 1	#changes the range of the random number from 0-63 to 1-64
	move $t2, $a2		#loads the address of the original array into $t2
	add $t2, $t2, $a0	#offsets the address by the random number
	lb $t4, ($t2)		#loads the number stored at the new address within the array
	beq $t4, 99, loop2	#if the number that was randomly selected was already selected, try another random number
	addi $a0, $zero, 99	#$a0 is not used for the rest of the loop so it is repourposed to temporarily store 99
	sb $a0, ($t2)		#replaces the number extracted from the original array with 99 so we know its been used
	sb $t4, ($t3)		#stores the extracted value into the new array
	
	addi $t3, $t3, 1	#increments the address of the new array
	addi $t0, $t0, 1	#increments the counter for the loop
	j loop2			#return to the head of the loop
	
	#Pre-Condition:		$a0 contains the adress of the list to be emptied
	#Post-Condition:	the array at $a0 will be filled with 99's
emptyList:
	li $t0, 0	#the counter for the loop
	li $t1, 99	#$t2 will be stored to every index of list $a0
	addi $t2, $a0, 0	#the address of the array to be emptied
emptyLoop:
	beq $t0, 32, return	#when the loop has executed 32 times, return
	sb $t1, ($t2)		#stores 99 into the current index
	addi $t0, $t0, 1	#increment the variables
	addi $t2, $t2, 1
	j emptyLoop
	
	
initilizeRefill:
	li $t0, 0	#counter for loop
	li $t1, 0	#number extracted from display list numbers
	la $t2, list1	#address of unused numbers list
	addi $t2, $t2, 32
	li $t3, 0	#number extracted from unused nubers list
	la $t4, displayList	#address of the display list
	li $t5, 32	#constant 32 used for divions later
refill:
	beq	$t0, 32, return		#if i = 32, end loop
	lb	$t1, ($t4)		#load array[i]
	beq	$t1, 99, replace	#if array[i] = 99, replace the number
	addi	$t0, $t0, 1		#i++
	addi 	$t4, $t4, 1
	j	refill
	
replace:
	div  	$s2, $t5	
	mfhi	$s2		# $s2%32 to ensure its within range of the unused list
	addi	$t2, $s2, 32	#offsets the unused number array by $s2
	lb	$t3, list1($t2)
	sb	$t3, ($t4)	#replace the number 99 from unused list 
	addi	$t0, $t0, 1	#i++
	addi	$s2, $s2, 1	#address of unused list ++
	addi 	$t4, $t4, 1
	j	refill

	#Pre-Condition:		$a0 is the address of the list being copied from
	#			$a1 is the address of the list being copied to
	#			$a2 is the number of elements to copy
	#Post-Condition:	the list at $a1 will have $a2 numbers copied into it from $a0
copyList:
	li $t0, 0		#counter for the loop
	addi $t1, $a2, 0	#exit condition for loop
	addi $t2, $a0, 0	#address of list to copy from
	li $t3, 0		#stores the element being copied
	addi $t4, $a1,0		#address of the list being copied to
copyLoop:
	beq $t0, $t1, return	#when the counter is at the limit set by the user, exit the loop
	lb $t3, ($t2)		#extract the number from the first list
	sb $t3, ($t4)		#store the number into the second list
	
	addi $t0, $t0, 1	#increment the variables
	addi $t2, $t2, 1	
	addi $t4, $t4, 1
	j copyLoop

	#PRE-CONDITION:	$a2 will contain the address of the list to be printed
	#		$s0 is the amount of numbers to be printed
	#POST-CONDITION:	pList will contain the ascii equivilent of the numbers stored at $a2
	#			the contents of pList will be displayed
printList:
	addi $t0, $zero, 0	#counter for how many times the loop is executed
	la $t5, pList		#stores address of pList into $t5
	la $t2, yourNumber	#stores address of "Do you see your numer?\n"
	addi $t3, $zero, 0 	#stores the letters from yourNumber to be put in pList
	addi $t4, $zero, 24	#stores how many times the loop will be executed
loadQuestion:		#this loop loads "do you see your number?\n" into pList before the numbers
	lb $t3, ($t2)		#loads the letters into $t3
	sb $t3, ($t5)		#stores the letters to pList
	
	addi $t0, $t0, 1	#increments the variables
	addi $t5, $t5, 1
	addi $t2, $t2, 1
	bne $t0, $t4, loadQuestion
	
	addi $t0, $zero, 0	#counter for how many times the loop executed
	addi $t1, $zero, 0	#stores the value at list[$t0]
	move $t2, $a2		#address of the start for list
	addi $t3, $zero, 0	#stores the lower didgit of $t1
	addi $t4, $zero, 0	#stores the upper didgit of $t1
	addi $t6, $zero, 10	#stores the number 10 for divion later
	addi $t7, $zero, 0x30	#stores a value for a comparison later
	addi $t8, $zero, 0x20	#stores the value of the ' ' character
	addi $t9, $zero, 3	#counter for when to add a "next line" character to the string
	
loop3:	beq $t0, $a0, display	#ends the loop once $t0 is at the end of the array
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
	li $t1, 0x00
	sb $t1, ($t5)	#stores a null byte into the end of the string
	
	addi $v0, $zero, 50	#loads the code for "Message Dialog Screen" into $v0
	la $a0, pList
	syscall
	jr $ra
	
	#Pre-Condition:		$a0 will have the address of the list to be sorted
	#			$a1 will have the size of the list
	#Post-Condition:	The list given to the function will have all of its numbers next to eachother with no 0xff number in between
condenseList:
	li $t0, 0		#$t0 is the counter for the loop
	addi $t1, $a1, 0	#$t1 contains the size of the list
	addi $t2, $a0, 0	#$t2 contains the address of the list
	addi $t3, $zero, 0	#$t3 will store the number taken from the list for comparison
	addi $t4, $a1, 0	#$t4 is an iterator for the list
	addi $t5, $zero, 99	#t5, contains 99 for comparison and storage later
	add $t6, $a0, $a1	#stores the end of the list for comparison later
	
loop4:	lb $t3, ($t2)
	bne $t3, $t5, increment2
	addi $t4, $t2, 1	#sets $t4 to the address of the next element of $t2
findNumber:
	beq $t4, $t6, return	#when the array reaches the user defined end of the array, return to the main code
	lb $t3, ($t4)		#stores the current element of $t4 to $t3
	addi $t4, $t4, 1	#increments the array iterator, $t4
	beq $t3, 99, findNumber#if the element at $t4 is also already used, go through the loop again
	sb $t3, ($t2)		#stores the unused number at $t3 into the currently already used number at the address of $t2
	sb $t5, -1($t4)		#changes the former address of $t3 to 99 so we know its been used/moved
increment2:
	addi $t0, $t0, 1
	addi $t2, $t2, 1
	bne $t0, $t1, loop4	#if the array isn't at its end yet, run the loop again
	j return
	
	#Pre-Condition:		$a0 will contain the address of the list to store
	#			$a1 will contain the size of the list to store
	#Post-Condition:	the "storeList" array will contain the elements of the array at $a0
storeUnusedNumbers:
	li $t0, 0		#$t0 is the counter for the loop
	addi $t1, $a1, 0	#$t1 is the exit condition for the loop
	addi $t2, $a0, 0	#$t2 contains the address of the array to be copied
	la $t3, list1
	addi $t3, $t3, 32	#$t3 contains the address of "storeList"
	addi $t4, $zero, 0	#$t4 will store the element being transfered to "storeList"
loop5:
	beq $t0, $t1, return
	lb $t4, ($t2)
	sb $t4, ($t3)
	addi $t0, $t0, 1
	addi $t2, $t2, 1
	addi $t3, $t3, 1
	j loop5
	
	
	#Pre-Condition: 	No nessecary pre-conditions must be met
	#Post Condition:	Two notes will be played to the user
playSound:
	addi $v0, $zero, 31	#syscall function number
	addi $a0, $zero, 67	#pitch
	addi $a1, $zero, 250	#duration
	addi $a2, $zero, 60	#instument
	addi $a3, $zero, 50	#volume
	syscall
	
	addi $a0, $zero, 66	#pitch
	addi $a1, $zero, 500	#duration
	addi $a2, $zero, 60	#instument
	addi $a3, $zero, 50	#volume
	syscall
	
	j return
	
#	$t0: i
#	$t1: j
#	$t2: j+1
#	$t3: temp
#	$t4: array[j]
#	$t5: array[j+1]
#	$a0: adderss of array
insertionSort:
	li $t0, 1 #set i = 1
	j endLoop1
forLoop1:
	add $t9, $a0, $t0
	lb $t3, ($t9) #temp = arr[i]
	addi $t1, $t0, -1
	j next1
	forLoop2:
		add $t9, $a0, $t1
		lb $t4, ($t9) #array[j]
		addi $t2, $t1, 1 #j+1
		add $t9, $a0, $t2
		sb $t4, ($t9) #store array[j] to array[j+1]
		addi $t1, $t1, -1 #j--
		
	next1:
		blt $t1, $zero, endLoop2 #if j = 0, end loop2
		add $t9, $a0, $t1
		lb $t4, ($t9) #Array[j]
		bgt $t4, $t3, forLoop2 #if temp < array[j] , startloop 2
		
	endLoop2:
		addi $t5, $t1, 1
		add $t9, $a0, $t5
		sb $t3, ($t9)
		addi $t0, $t0, 1 #i++
endLoop1:
	blt $t0, 32, forLoop1
	jr $ra

return:
	jr $ra

Exit:
	li	$v0, 55
	la 	$a0, thankYou
	li	$a1, 1
	syscall
	
	jal playSound
	
	li	$v0, 10
	syscall
