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




userArray: .space 128 #reserve space for 32 words

.text
main:
	li	$v0, 50
	la	$a0, introduction
	syscall
	
	
	beq $a0, 1, main
	beq $a0, 2, Exit

Exit:
	li	$v0, 55
	la 	$a0, thankYou
	li	$a1, 1
	syscall
	
	li	$v0, 10
	syscall
	

