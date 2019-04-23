.data
space: .asciiz " "
testList:	.space 32
.text
main:
	#store 32 numbers
	addi $t2, $t2, 32
	add $t3, $t3, $zero
	jal setNumber
	#print 32 number before sort
	lbu $t1, testList
	addi $t2, $t2, 1
	jal printList
	#BubbleSort
	jal insertionSort
	addi $t2,$zero,1
	lbu $t1, testList
	jal printList
	
	#program end
	li $v0, 10
	syscall
printList:
	li $v0, 1
	move $a0, $t1
	syscall
	
	li $v0, 4
	la $a0, space
	syscall
	
	lb $t1, testList($t2)
	addi $t2, $t2, 1
	bne $t2, 33, printList
	jr $ra
	
	
setNumber:
	sb $t2, testList($t3) 	
	subi $t2, $t2, 1
	addi $t3, $t3, 1
	bne $t3, 32, setNumber
	jr $ra

#	$t0: i
#	$t1: j
#	$t2: j+1
#	$t3: temp
#	$t4: array[j]
#	$t5: array[j+1]
insertionSort:
	li $t0, 1 #set i = 1
	j endLoop1
forLoop1:
	lb $t3, testList($t0) #temp = arr[i]
	addi $t1, $t0, -1
	j next
	forLoop2:
		lb $t4, testList($t1) #array[j]
		addi $t2, $t1, 1 #j+1
		sb $t4, testList($t2) #store array[j] to array[j+1]
		addi $t1, $t1, -1 #j--
		
	next:
		blt $t1, $zero, endLoop2 #if j = 0, end loop2
		lb $t4, testList($t1) #Array[j]
		bgt $t4, $t3, forLoop2 #if temp < array[j] , startloop 2
		
	endLoop2:
		addi $t5, $t1, 1
		sb $t3, testList($t5)
		addi $t0, $t0, 1 #i++
endLoop1:
	blt $t0, 32, forLoop1
	jr $ra


	
	
	
