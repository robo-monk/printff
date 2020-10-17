.text
	value: .asciz "the value is %s"
	string: .asciz "%s"
	charn: .asciz "%c\n"
	char: .asciz "%c"
	digit: .asciz "%ld\n"
	hexa: .asciz "%lX"

.data
	test: .asciz "yeeet %d%%"
	test_ch: .asciz "e"


/*.include "final.s"*/

.global main


# HELPER SUBROUTINES

# params: memory_andress, relative_byte 
# ret: the byte 
get_byte:
	# prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	pushq 	%r11
	movq	%rsp, %rbp		# copy stack pointer value to base pointer
	
	movq $1, %rax			# 8 for 8 bits
	mulq %rsi			# 8bits * relative address stored in rsi
	addq %rax, %rdi			# go to the correct block
	movq (%rdi), %rax		# contents of calculated address to rax

	shl $56, %rax			# chop off address + times
	shr $56, %rax			# shift right to compensate for the previous chopping

	# epilogue
	movq	%rbp, %rsp		# clear local variables from stack
	popq    %r11
	popq	%rbp			# restore base pointer location 
	ret


count: # (string to count)
	# prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	pushq	%rbx			# push contents of rbx

	movq $0, %rsi
	call find

	# epilogue
	popq	%rbx			# restore og rbx 
	popq	%rbp			# restore base pointer location 
	ret

# writes '%(rsi)' sequences
# ascii: | % - 32 | 0 - 0 | d - 64 | u - 32 | s - 74 |
write_sequence: #( memory andress, index of %, replace_with)
	
	# prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	pushq 	%r11
	pushq 	%r12
	movq	%rsp, %rbp		# copy stack pointer value to base pointer
	
	
	pushq %rdi
	pushq %rsi
	pushq %rdx

	# read the byte-character after %
	/*incq %rsi*/
	call get_byte

	# %d
	cmpq $100, %rax
	je write_d

	# %u
	cmpq $117, %rax
	je write_u

	# %s
	cmpq $115, %rax
	je write_s
	
	# %%
	cmpq $37, %rax
	je write_percentage

	// if none of the above jump:
	no_templ_match:
	// prints %(rax) and returns	
		movq $0, %rax
		jmp wseq_epilogue

	write_percentage:
		movq $1, %rax
		jmp wseq_epilogue

	write_d:
		movq $1, %rax
		movq $2, %rsi
		movq $digit, %rdi
		movq $0, %rax
		call printf
		jmp wseq_epilogue

	write_u:
		movq $1, %rax
		jmp wseq_epilogue

	write_s:
		movq $1, %rax
		jmp wseq_epilogue

	/*je*/
	# epilogue
	wseq_epilogue:
	movq	%rbp, %rsp		# clear local variables from stack
	popq    %r11
	popq    %r12
	popq	%rbp			# restore base pointer location 
	ret


# params:  andress of thing to search, andress of thing to find 
# ret: returns relative address of the thing to find in the thing to search (in ascii decimal)
# 	or -1 if string doesnt contain it
# ascii: | % - 32 | 0 - 0 | d - 64 | u - 32 | s - 74 |
find:
	# prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	pushq	%r11
	pushq	%r12			
	pushq	%r13
	pushq	%r14
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

	movq %rdi, %r11			# move the og thing to search to r12
	movq $0, %r12			# start scanning from the first byte			
	movq %rsi, %r13			# mov ascii character to find

	# (r11) = thing to search
	# r12 = byte count
	# (r13) = thing to find
	get_next_byte:

		movq %r11, %rdi		# address for stream byte			
		movq %r12, %rsi		# byte count as displacement
		call get_byte

		incq %r12		# incremenet byte_count

		cmpq $0, %rax 		# string is over and we dindt find shit 
		je did_not_find

		cmpq %rax, %r13
		jne get_next_byte

	return_index:
		movq %r12, %rax
		jmp find_epilogue

	did_not_find:
		cmpq $0, %r13 		# if we were looking for 0, we found it :)
		je return_index

		movq $-1, %rax 		# otherwise return -1

	find_epilogue:
	movq	%rbp, %rsp		# clear local variables from stack
	popq	%r14
	popq	%r13
	popq	%r12
	popq	%r11
	popq	%rbp			# restore base pointer location 
	ret
# MAIN CODE

# params: string to print, how many bytes 
# ret: no
write_bytes:
	pushq	%rbp 			# push the base pointer (and align the stack)
	pushq	%rbx			# push contents of rbx
	pushq   %r11

	movq %rsi, %rdx			# bytes to write
	movq %rdi, %rsi
	movq $1, %rax			# sys_write
	movq $1, %rdi			# stdout
	syscall
	
	# epilogue
	popq 	%r11
	popq	%rbx			# restore og rbx 
	popq	%rbp			# restore base pointer location 
	ret
	
# params: string to print, ascii code of until 
# ret: no
write_until:
	# prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	pushq	%rbx			# push contents of rbx

	pushq %rdi			# push string to print to the stack
	call find
	movq %rax, %rsi
	decq %rsi 			# write until (not including)
	
	popq %rdi

	pushq %rax
	call write_bytes

	popq %rax 			# return the until index
	# epilogue
	popq	%rbx			# restore og rbx 
	popq	%rbp			# restore base pointer location 
	ret
# params: string to print
# ret: no
write:
	# prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	pushq	%rbx			# push contents of rbx

	pushq %rdi			# push string to print to the stack
	call count
	movq %rax, %rsi
	popq %rdi
	call write_bytes

	# epilogue
	popq	%rbx			# restore og rbx 
	popq	%rbp			# restore base pointer location 
	ret

# params: format_string, values
# ret: no
printff:
	# prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	pushq	%rbx			# push contents of rbx
	pushq	%r12			# push contents of r12
	pushq	%r13			# push contents of r13
	pushq	%r14			# push contents of r14
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

	pushq %rsi
	pushq %rdi

	movq $37, %rsi
	call write_until

	popq %rdi # andress
	movq %rax, %rsi # write until returns index of until
	movq $5, %rdx
	call write_sequence

	/*popq %rdi*/
	/*movq $100, %rsi*/
	/*call find_sequence*/
	/*movq %rax, %rsi*/
	/*movq $digit, %rdi*/
	/*movq $0, %rax*/
	/*call printf*/
	/*popq %rsi*/

	#
	movq	%rbp, %rsp		# clear local variables from stack
	popq	%r14			# restore og r14 
	popq	%r13			# restore og r13 
	popq	%r12			# restore og r12 value 
	popq	%rbx			# restore og rbx 
	popq	%rbp			# restore base pointer location 
	ret

main:
	pushq %rbp 			# push the base pointer (and align the stack)
	movq %rsp, %rbp		# copy stack pointer value to base pointer

	movq $test, %rdi
	movq $0, %rsi
	call printff

	/*movq $4, %rsi*/
	/*movq $test, %rdi*/
	/*call find*/
	
	movq %rax, %rsi
	movq $digit, %rdi
	movq $0, %rax
	call printf

	popq %rbp			# restore base pointer location 
	movq $0, %rdi		# load program exit code
	call exit			# exit the program

