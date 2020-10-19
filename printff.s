.include "helpers/digits_helper.s"
.include "helpers/write.s"


printff_recursive:

	addq $8, %rsp
	movq %rdi, %r12 		# r12 holds the string andress

	movq $37, %rsi
	call write_until
	movq %rax, %rsi 		# write until returns index of until
	// if return of write_utnil is <0, break as string is over
	cmpq $0, %rax
	jle printff_recursive_ret

	movq %r12, %rdi			# move current cursor to rdi as first param of write_sequence

	addq %rax, %r12			# move cursor to index of until

	movq (%rsp), %rdx
	call write_sequence
	cmpq $0, %rax 			# if equal it means write sequence used the param
	jle recur

	popq %rdx			# pop first argument as last param for write_sequence 

	recur:
	mulq %rax			# rax = |rax|
	addq %rax, %r12

	movq %r12, %rdi 		# r12 holds the string andress
	/*popq %rsi*/
	/*popq %rdx*/
	/*popq %rcx*/
	call printff_recursive

	printff_recursive_ret:
	ret
	/*jmp printff_epilogue*/


# params: format_string, values
# ret: no
printff:
	# prologue
	/*pushq	%rbp 			# push the base pointer (and align the stack)*/
	/*pushq	%rbx			# push contents of rbx*/
	/*pushq	%r12			# push contents of r12*/
	/*pushq	%r13			# push contents of r13*/
	/*pushq	%r14			# push contents of r14*/
	/*movq	%rsp, %rbp		# copy stack pointer value to base pointer*/

	addq $8, %rsp
	# push all the arguments in the stack
	pushq %r9
	pushq %r8
	pushq %rcx
	pushq %rdx
	pushq %rsi
	call printff_recursive
	

	printff_epilogue:
	/*movq	%rbp, %rsp		# clear local variables from stack*/
	/*popq	%r14			# restore og r14 */
	/*popq	%r13			# restore og r13 */
	/*popq	%r12			# restore og r12 value */
	/*popq	%rbx			# restore og rbx */
	/*popq	%rbp			# restore base pointer location */
	ret

