.include "helpers/digits_helper.s"
.include "helpers/write.s"

# params: format_string, values
# ret: no
printff:
	popq %r14	# pop return andress of this to r14	 
	movq %rsp, %r15

	pushq %r9
	pushq %r8
	pushq %rcx
	pushq %rdx
	pushq %rsi

	/*call printf*/
	printff_stack:
		/*addq $8, %rsp			# move stack pointer to skip return andress of this func*/
		movq %rdi, %r12 		# r12 holds the string andress

		movq $37, %rsi
		call write_until		# write until %	
		movq %rax, %rsi 		# returning index to rsi	

		cmpq $0, %rax			# if index < 0, string ended, end this
		jle printff_end

		movq %r12, %rdi			# string andress as first param of write_sequence
		movq (%rsp), %rdx

		addq %rax, %r12			# increment cursor before calling write sequence

		call write_sequence
		cmpq $0, %rax
		jle recur

		// if write sequence used the param, point to next argument stored in the stack
		addq $8, %rsp

		recur:
			mulq %rax		# rax = |rax| ( -1 < rax < 1)
			addq %rax, %r12		# increment andress by how many bytes the write
						# sequence returns
			movq %r12, %rdi		# r12 holds the string andress
			jmp printff_stack


	printff_end:

	movq %r15, %rsp
	pushq %r14	# push this andress back

	ret

