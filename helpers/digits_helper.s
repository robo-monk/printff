.include "helpers/pow.s"

get_digit_count: # (int)
	# rets the digit count of int

	# prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	pushq 	%r11
	pushq 	%r12
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

	movq $0, %rsi 
	call get_nth_digit

	movq %rdi, %r12
	movq $0, %r11
	count_digit:
		movq %r12, %rdi
		movq %r11, %rsi
		call get_nth_digit
		incq %r11
		cmpq $-1, %rax
		jne count_digit

	movq %r11, %rax

	movq	%rbp, %rsp		# clear local variables from stack
	popq    %r12
	popq    %r11
	popq	%rbp			# restore base pointer location 
	ret

get_nth_digit: # ( number, n )
	# returns if number is n digits or smaller (number/10^n) % 10
	# other wise -1

	# prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	pushq 	%r11
	push    %r12
	movq	%rsp, %rbp		# copy stack pointer value to base pointer
	
	pushq %rdi
	movq $10, %rdi
	# rsi is already n
	call pow
	popq %r11
	pushq %rax

	movq %r11, %rax
	movq $0, %rdx
	popq %r12 
	divq %r12

	cmpq $0, %rax
	jne digit_exists

	movq $-1, %rax
	jmp nth_digit_epilogue

	digit_exists:
	movq $0, %rdx
	movq $10, %r11
	pushq $10
	divq (%rsp)
	movq %rdx, %rax

	nth_digit_epilogue:
	movq	%rbp, %rsp		# clear local variables from stack
	popq 	%r12
	popq    %r11

	popq	%rbp			# restore base pointer location 
	ret

