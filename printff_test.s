.include "printff.s"

.global main

.data
	test: .asciz "yeeet(%d) = (50%% + 10%%)^%d + %d - %r = %s %r %d %d %d %d %d %d"
	test2: .asciz "yeet256\n"


main:
	pushq %rbp 			# push the base pointer (and align the stack)
	movq %rsp, %rbp			# copy stack pointer value to base pointer

	movq $0, %rax
	movq $test, %rdi
	movq $1420, %rsi
	movq $69, %rdx
	movq $-2131, %rcx
	movq $test2, %r8
	movq $5, %r9
	pushq $4
	pushq $3
	pushq $2
	pushq $1
	call printff

	popq %rbp			# restore base pointer location 
	movq $0, %rdi			# load program exit code
	call exit			# exit the program

