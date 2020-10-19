.include "printff.s"
.global main

.data
	test: .asciz "yeeet(%d) = (50%% + 10%%)^%d + (%d) | %r %d %i  |  %s %d %d %d "
	test2: .asciz "\nlets count from the stack: "
	test3: .asciz "shiiiiiiiii%%"

main:
	/*pushq 	%r11*/
	movq	%rsp, %rbp		# copy stack pointer value to base pointer
	
	movq $test, %rdi

	movq $420, %rsi
	movq $69, %rdx
	movq $42, %rcx
	movq $7, %r8
	movq $test2, %r9

	pushq $6
	pushq $5
	pushq $4
	pushq $3
	pushq $2
	pushq $1

	call printff

	movq $0, %rdi			# load program exit code
	call exit			# exit the program

