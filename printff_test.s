.include "printff.s"

.global main

.data
	test: .asciz "yeeet(%d) = (50%% + 10%%)^%d + %d - %r = %s"
	test2: .asciz "yeet256\n"


main:
	pushq %rbp 			# push the base pointer (and align the stack)
	movq %rsp, %rbp			# copy stack pointer value to base pointer

	movq $test, %rdi
	movq $1420, %rsi
	movq $69, %rdx
	movq $-2131, %rcx
	movq $test2, %r8
	call printff

	popq %rbp			# restore base pointer location 
	movq $0, %rdi			# load program exit code
	call exit			# exit the program

