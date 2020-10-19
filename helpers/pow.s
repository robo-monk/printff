pow: # base, expo
	# prologue
	pushq %rbp		 
	pushq %r11	
	movq %rsp, %rbp	


	movq $0, %rax
	cmpq $0, %rdi
	je pow_ret

	movq $1, %rax
	cmpq $0, %rsi
	je pow_ret
	
	decq %rsi
	pushq %rdi
	call pow
	mulq (%rsp)
	
	pow_ret:
	movq %rbp, %rsp
	popq %r11
	popq %rbp
	ret

