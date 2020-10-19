.include "helpers/digits_helper.s"
.include "helpers/write.s"

# params: format_string, values
# ret: no
printff:
	# prologue
	popq %r14		# pop return andress of this to r14	 
	movq %rsp, %rbp		# store stack pointer to rbp

	# pushing all possible paramters to the stack
	pushq %r9
	pushq %r8
	pushq %rcx
	pushq %rdx
	pushq %rsi

	printff_stack: 
		movq %rdi, %r12 		# r12 holds the string andress

		# write until a % or the end of the string
		movq $37, %rsi
		call write_until		# write until %	

		cmpq $0, %rax			# if index < 0, string ended, end
		jle printff_end

		# means we hit a %, writing sequence...
		movq %r12, %rdi			# string andress as first param of write_sequence
		movq %rax, %rsi 		# 2nd param is index of % stored in rsi already
		movq (%rsp), %rdx		# value that rsp points as 3rd param of write sequence

		addq %rax, %r12			# increment cursor by % index, before calling write sequence

		call write_sequence

		cmpq $0, %rax	
		jle recur	# write_sequence did not use the param

		/* if write sequence used the param, point to next argument stored in the stack */
		addq $8, %rsp

		recur:
			mulq %rax		# rax = |rax| ( -1 < rax < 1)
			addq %rax, %r12		# increment andress by how many bytes the write
						# sequence returns
			movq %r12, %rdi		# r12 holds the string andress
			jmp printff_stack


	# epilogue
	printff_end:
	movq %rbp, %rsp
	pushq %r14	# push this andress back

	ret

