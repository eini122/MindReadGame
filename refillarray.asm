.data

Loop2List:	.byte	33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64	#number of the second "not used list" to combine the user chosen list
displayList:	.byte	1,99,3,4,5,6,7,8,9,99,11,12,13,14,99,16,99,18,19,20,99,22,23,24,25,99,27,28,29,30,31,32# list contain the number displayList


.text

	
main:	
	
	la	$t1, displayList	#means the $t2 displayList
	la	$t4, Loop2List	#load numbers in Loop2List to register $t4
	addi	$a2, $zero, 99	#set $a2 to constant 99 for replacement
	addi	$a0, $zero, 0	#counter
	addi	$a1, $zero, 31	#space
	j	compare		


compare:
	beq	$a0, $a1, exit	#if the counter not reach the size, compare
	lb	$t3, ($t1)
	beq	$t3, $a2, replace
	addi	$t1, $t1, 1
	addi	$a0, $a0, 1
	j	compare
	
replace:
	lb	$t5, ($t4)
	sb	$t5, ($t1)	#store the number from not used list to $t5
	addi	$t1, $t1, 1
	addi	$t4, $t4, 1
	j	compare
	
exit:
	li	$v0, 10
	syscall
	
	
	