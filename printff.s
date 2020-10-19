.text
	value: .asciz "the value is %s"
	string: .asciz "%s"
	charn: .asciz "%c\n"
	char: .asciz "%c"
	digit: .asciz "%ld\n"
	hexa: .asciz "%lX"

.data
	test: .asciz "yeeet(%d) = (50%% + 10%%)^%d + %d - %r = %s"
	test2: .asciz "yeet256\n"
	ch_table: .asciz "0123456789%-"
	test_ch: .asciz "e"


/*.include "final.s"*/
.include "pow.s"

.global main


# HELPER SUBROUTINES
get_digit_count:
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
	popq %r12
	popq    %r11

	popq	%rbp			# restore base pointer location 
	ret


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
	pushq 	%r11

	movq $0, %rsi
	call find

	movq $-1, %r11
	mulq %r11

	# epilogue
	popq    %r11
	popq	%rbx			# restore og rbx 
	popq	%rbp			# restore base pointer location 
	ret

# writes '%(rsi)' sequences
# ascii: | % - 32 | 0 - 0 | d - 64 | u - 32 | s - 74 |
write_sequence: #( memory andress, index of %, replace_with)
# ret: bytes written, if negative or did not use replace-with
	
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
		movq $10, %rdi
		call write_from_table # write a %

		movq $0, %rax
		jmp wseq_epilogue

	write_percentage:
		movq $10, %rdi
		call write_from_table # write a %

		movq $-1, %rax
		jmp wseq_epilogue

	write_d:
		movq (%rsp),  %r12
		cmpq $0, %r12
		jge write_u

		movq $11, %rdi
		call write_from_table

		movq $-1, %rax
		mulq %r12
		pushq %rax

	write_u:
		popq %r12		# pop rdx ( value ) to table
		movq %r12, %rdi
		call get_digit_count
		movq %rax, %r11
		/*decq %r11*/
		push_digit:
			pushq %r11
			movq %r12, %rdi
			movq %r11, %rsi
			call get_nth_digit
			movq %rax, %rdi
			/*movq $1, %rdi*/
			call write_from_table
			popq %r11
			decq %r11
			cmpq $-1, %r11
			jg push_digit

		movq $1, %rax
		jmp wseq_epilogue

	write_s:
		popq %rdi	
		call write
		movq $1, %rax
		jmp wseq_epilogue

	/*je*/
	# epilogue
	wseq_epilogue:
	movq	%rbp, %rsp		# clear local variables from stack
	popq    %r12
	popq    %r11
	popq	%rbp			# restore base pointer location 
	ret


# params:  andress of thing to search, andress of thing to find 
# ret: returns relative address of the thing to find in the thing to search (in ascii decimal)
# 	or -length if string doesnt contain it
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
		movq $-1, %rax
		mulq %r12		# return -%r12, aka -length of string


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
	
# params: string to print, ascii code of until, 0 if string doestn contain it
# ret:  until index (-1 if it doenst contain it)
write_until:
	# prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	pushq	%rbx			# push contents of rbx
	pushq 	%r11

	pushq %rdi			# push string to print to the stack
	call find
	movq %rax, %r11			# hold find ret value to r11

	popq %rdi			# memory to print
	cmpq $0, %rax 			# string doesnt contain provided ascii
	jge write_until_bytes		# write string until the end

	# means that find returned negative 
	# inverse output of find and print 
	# length-n bytes
	movq $-1, %rax
	mulq %r11


	write_until_bytes:
	movq %rax, %rsi
	decq %rsi 			# write until (not including)

	pushq %r11
	call write_bytes
	popq %rax			# return the until index
	# epilogue
	popq 	%r11
	popq	%rbx			# restore og rbx 
	popq	%rbp			# restore base pointer location 
	ret


write_from_table: # ( index of character in table)

	# prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	pushq	%rbx			# push contents of rbx
	pushq 	%r11

	pushq %rdi
	movq $ch_table, %rdi
	popq %rsi
	addq %rsi, %rdi
	movq $1, %rsi			# write 1 byte
	call write_bytes

	# epilogue
	popq %r11
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

	# push all the arguments in the stack
	pushq %r9
	pushq %r8
	pushq %rcx
	pushq %rdx
	pushq %rsi

	movq %rdi, %r12 		# r12 holds the string andress

	movq $37, %rsi
	call write_until
	movq %rax, %rsi 		# write until returns index of until
	// if return of write_utnil is <0, break as string is over
	cmpq $0, %rax
	jle printff_epilogue

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
	popq %rsi
	popq %rdx
	popq %rcx
	call printff

	printff_epilogue:
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
	movq $1420, %rsi
	movq $69, %rdx
	movq $-2131, %rcx
	movq $test2, %r8
	call printff

	popq %rbp			# restore base pointer location 
	movq $0, %rdi		# load program exit code
	call exit			# exit the program

