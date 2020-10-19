.include "printff.s"
.global main

.data
	test: .asciz "yeeet(%d) = (50%% + 10%%)^%d + (%d)  %r  %s %d %d %d %d %% %d "
	test2: .asciz "\nlets count: "

main:
	/*pushq 	%r11*/
	movq	%rsp, %rbp		# copy stack pointer value to base pointer
	
	movq $test, %rdi
	movq $1420, %rsi
	movq $0, %rax
	movq $69, %rdx
	movq $-231, %rcx
	movq $test2, %r8
	movq $5, %r9

	pushq $4
	pushq $3
	pushq $2
	pushq $1
	call printff

	movq $0, %rdi			# load program exit code
	call exit			# exit the program

