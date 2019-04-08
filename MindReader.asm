#First version of the Mind Reader game
#@authour Kaitian Li
#update: 2019/4/6
.data
introduction:	.ascii "Hello This is a Mind Reader game. Before game start, think of a number between between 1 and 63."
		.ascii	"\nAnswer 6 simple questions, and the Mind Reader will knwo your number form your mind."
		.ascii	"You will see 32 numbers displayed on the screen, \nif your number shown, click yes,"
		.ascii	"If you cannot find the number, please click no. Click Cancel to exit the game."
		.ascii  "\n\nSelect"
    		.ascii  "\nYES - if you are ready to start"
    		.ascii  "\nNO - to see the rules again"
		.asciiz "\nCancel - to exit the Game\n"
thankYou:	.asciiz "Thank you!"
newLine:	.asciiz "\n"
space:		.asciiz " "



userArray: .space 128 #reserve space for 32 words
displayArray: .space 128 #array to store the number

.text
main:
	#display instroduction
	li	$v0, 55
	la	$a0, introduction
	li	$a1, 1
	syscall
	li	$v0, 50
	la	$a0, thankYou
	syscall
	
	beq $a0, 1, main	#user choose no, go back main
	beq $a0, 2, Exit	#user choose cancel, exit the progrom
	#jal initialRegisters #initial the register
	jal clearUserArray	#jump to clear User array
	jal setEvenNumberCard
	
#method to initial whole array to 0	
clearUserArray:
	sw $zero, userArray($t0) #store 0 to array
	addi $t0, $t0, 4	#go to the next index
	bne $t0, 128, clearUserArray	#loop to clear loop
	add $t0, $t0, $zero	#initial the register $t0
	jr $ra	#jump back to register
	
#method to set even number card
setEvenNumberCard:
	sw	$t1, displayArray($t0)
	addi	$t1, $t1, 2
	addi	$t0, $t0, 4
	bne	$t0, 128, setEvenNumberCard
	add	$t0, $t0, $zero
	add	$t1, $t1, $zero
	j displayCard
	
	
displayCard:
	
	

#method to set all user register to 0 for reuse purpose
initialRegisters:
	add $t0, $t0, $zero
	add $t1, $t1, $zero
	add $t2, $t2, $zero
	add $t3, $t3, $zero
	jr $ra

Exit:
	li	$v0, 55
	la 	$a0, thankYou
	li	$a1, 1
	syscall
	
	li	$v0, 10
	syscall
	

