.data

Loop2List:	.byte	33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64	#number of the second "not used list" to combine the user chosen list
displayList:	.byte	99,99,3,4,5,6,7,8,9,99,11,12,13,14,99,16,99,18,19,20,99,22,23,24,25,99,27,28,29,30,31,99# list contain the number displayList
space:		.ascii	" "

.text

	
main:	
	
	la	$a0, displayList	#means the $t2 displayList
	la	$a1, Loop2List	#load numbers in Loop2List to register $t4
	addi	$t0, $zero, 0	#counter
	jal	reFill	
	
	addi 	$t1, $zero, 0
	lb 	$t0 displayList
	jal 	printList
	
	li 	$v0, 10
	syscall

	
printList:
	li $v0, 1
	addi $a0, $t0, 0
	syscall
	
	li $v0, 4
	la $a0, space
	syscall
	
	addi	$t1, $t1, 1
	lb	$t0, displayList($t1)
	blt	$t1, 32, printList
	jr	$ra 

	#$a0:	address for display list
	#$a1:	address for unuser list
	#$t0:	i
	#$t1:	register to set addres of array[i]
	#$t2:	array[i]
	#$t3:	pointer for unuser array
	#$t4:	number from unused list
	#$t5:	register to set address of unused list
reFill:
	beq	$t0, 32, endRefill	#if i = 32, end loop
	add 	$t1, $a0, $t0		#get address of array[i]
	lb	$t2, ($t1)		#load array[i]
	beq	$t2, 99, replace	#if array[i] = 99, replace the number
	addi	$t0, $t0, 1		#i++
	j	reFill
	
replace:
	add 	$t5, $a1, $t3		#get adderss for unused list
	lb	$t4, ($t5)		#temp number for unused list
	sb	$t4, ($t1)		#replace the number 99 from unused list 
	addi	$t0, $t0, 1		#i++
	addi	$t3, $t3, 1		#address of unused list ++
	j	reFill
	
endRefill:
	jr $ra
	
	
	
