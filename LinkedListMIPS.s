# Soul of the Machine - Fall 2013 - Programming Assignment 2
#
# <your name here>
#


##################################################
# Global symbols
#
	# string routines
	.globl read_string
	.globl strcmp
	.globl strlen
	.globl trim
	.globl strloop
	.globl replace

	# list routines
	.globl insert
	.globl insert_here
	.globl print_list

	.globl  main

	# pseudo-standard library
	.globl get_string
	.globl malloc
	.globl print_newline
	.globl print_string

	
##################################################
# Constants
#
        .data
MAX_STR_LEN: .word 50
STR_NEWLINE: .asciiz "\n"
STR_ENTER:   .asciiz "enter a string: "



#################################################################
#################################################################
# Code
#
	.text


##################################################
# main: repeatedly gets strings from user and enters them in list
# until a string of length less than two is entered;
# prints list in order when done
#
main:	
#	lines commented out - not needed in simulation:
#	addi $sp, $sp, -12
#	sw   $ra, 0($sp)
#	sw   $s0, 4($sp) #$s0 will be linked list
#	sw   $s1, 8($sp) #$s1 will be the current string
	li   	$s0, 0  # initialize the list to NULL
	
Loop_main:
	la   	$a0, STR_ENTER
	jal  	print_string
	jal  	read_string
	move 	$s1, $v0
	jal 	trim
	jal 	strlen
	addi 	$t0, $zero, 2
	beq 	$v0, $t0, Exit_loop_main
	jal 	strcmp
	jal 	insert
	# replace newline with null terminator
	# ...
	
	# check string length; exit loop if less than 2
	# ...

	# insert string into list
	# ...
	# reassign front of list
	j    	Loop_main
	
Exit_loop_main:
	move 	$a0, $s0
	jal  	print_list
	jal  	print_newline
#	lines commented out - not needed in simulation:
#	lw	 $s1, 8($sp)
#	lw	 $s0, 4($sp)
#	lw	 $ra, 0($sp)
#	addi $sp, $sp, 12
#	jr	 $ra		
    # exit simulation via syscall
    li   	$v0, 10
    syscall



##################################################
# String routines
#

# read_string: allocates MAX_STR_LEN bytes for a string
# and then reads a string from standard input into that memory address
# and returns the address in $v0
read_string:
	addi 	$sp, $sp, -8			#allocate space for 2 items on the stack
	sw   	$ra, 0($sp)				#push the jump register onto the stack
	sw   	$s0, 4($sp)				#push the head of the list onto the stack
	add  	$t0, $t0, $zero    		#$t0 gets 0  
    la   	$a0, MAX_STR_LEN  		#$a0 gets MAX_STR_LEN
    jal  	malloc		 			#jump to malloc to allocate space for string
    move 	$a0, $v0				#move pointer to allocated memory to $a0
    add  	$t1, $t1, $zero 		#get zero
    move 	$a1, $t1				#move zero to a1
    la   	$a1, MAX_STR_LEN    	#$a1 gets MAX_STR_LEN
    jal  	get_string				#get the string into $v0
	lw   	$s0, 4($sp)				#load the head of the list
	lw   	$ra, 0($sp)				#load the jump address
	addi 	$sp, $sp, 8				#push onto the stack space for 2 elements
	jr 		$ra 					#jump back to caller function


# trim: modifies string stored at address in $a0 so that
# first occurrence of a newline is replaced by null terminator
trim:
 	li		$t0, 10					#$t1 gets 10, ASCII value for newline
strloop:   
	lb      $t1, 0($a0)				#get byte of character of string and loop 
	beq		$t1, $t0, replace 		#if $a0 = go to replace
	addi	$a0, $a0, 8  			#increment $a0 by 8 to piont to first bit of next char
	j 		strloop 				#jump back to beginning
replace:	
	add		$t2, $t2, $zero  		#$t2 is set to zero, ASCII value for null terminator
	sb      $t2, 0($a0) 			#$t2 is stored into the byte starting at $a0
	jr		$ra 					#jump back to caller

# strlen: given string stored at address in $a0
# returns its length in $v0
strlen: 
	add 	$t0, $t0, $zer0			#$t0 gets zero
lenloop:	
	lb 		$t1, 0($a0)				#get the first byte for first char in $a0
	beq		$t1, $zero, exitline	#if $t1 == 0 (null terminator), jump to exit
	addi	$a0, $a0, 8				#else, increment to next byte of string for next char
	addi 	$t0, $t0, 1             #increment $t0 for each character in string
	j       lenloop					#jump back up to loop 
exitline: 	
	sw 		$t0, 0($v0)				#store $t0 into $v0 to return lenght of string
	jr		$ra 					#jump back to caller 



# strcmp: given strings s, t stored at addresses in $a0, $a1
# returns -1 if s < t; 0 if s == t, 1 if s > t
strcmp:
    lb		$t0, 0($a0)				#get byte of first char in string s	
    lb		$t1, 0($a1)				#get byte of first char in string t
  #  lb 		$t3, 0($t0)
    #lb 		$t4, 0($t1)
    addi 	$t3, $t3, 1 			#get 1 to compare
    slt 	$t2, $t0, $t1			#if s[0] < t[0] $t2 = 1, else $t2 = 0
    bne		$t2, $t3, lessthan		#if $t2  == 1, jump to lessthan
    slt     $t2, $t1, $t0 			#if t[0] < s[1], $t2 = 1, else $t2 = 0
	beq     $t2, $t3, greaterthan	#if $t2 == 1, jump to greaterthan
	sw 		$zero, 0($v0)			#$v0 gets zero 
	j 		end
lessthan: 
	addi    $t4, $t4, -1 			#$t4 gets -1
	sw		$t4, 0($v0)				#$v0 gets -1 
	j   	end 					#jump to end
greaterthan: 
	addi    $t4, $t4, 1 			#$t4 gets 1
	sw 		$t4, 0($v0)				#$v0 gets 1
	j 		end 					#jump to end
end: 	  
	jr	 	$ra

# insert_here: given address of front of list in $a0 
# and address of string to insert in $a1, 
# inserts new linked-list node in front of list;
# returns address of new front of list in $v0
insert_here:
	lw		$t0, 0($a0)				#$t0 get $a0
	lw 		$t1, 0($a1)				#$t1 gets $a1
	addi    $t2, $zero, 8			#$t2 gets 8 
	sw      $t2, 0($a0)				#$t2 gets stored into $a0
	jal		malloc     				#allocate 1 byte for the memory
	move 	$t3, $v0 				#get address of new memory from $v0 and move to $t3
	sw      $t1, 0($t3) 			#store the string pointer into bytes 0-3 of the new memory
	sw 		$t0, 4($t3)				#store the pointer to the original front of the list 
	sw		$t3, 0($s0)				#store 
	sw      $t4, 4($s0)
	lw 		$ra, 0($sp)
	addi	$sp, $sp, -4
	jr 		$ra



##################################################
# List routines
#


# insert: given address of front of list in $a0 
# and address of string to insert in $a1, 
# inserts new linked-list node in appropriate place in list 
# ...
# returns address of new front of list in $v0 (which may be same as old)
insert: 
	lw	  	$t0, 0($a0) 		#get the address of front of the list
	lw	  	$t1, 0($a1) 
	addi  	$t3, $zero, 1	
	addi  	$t4, $zero, -1 		#get the string address out of $a1
alphloop:	
	slt   	$t2, $t1, $t0   
	beq   	$t2, $t3, put
	beq   	$t2, $zero, nextchar
	sw 	  	$t1, 0($a0)
	sw 	  	$t0, 0($a1)
	jal   	strcmp
	move  	$v0, $
	addi  	$t0, $t0, 8
	j 	  	alphloop	
nextchar: 	
	addi	$t0, $t0, 4
    addi  	$t1, $t1, 4
    j 		alphloop
put: 	
    li    	$t5, 8   
	move  	$a0, $t5
	jal   	malloc	
	move  	$t5, $v0
	sw    	$t1, 0($t5)
	sw 		$t0, 4($t5)
	addi  	$t0, $t0, -12
	lw    	$t6, 8($t0)
	bne   	$t0, $t6, close
	sw    	$t5, 0($t0) #we forgot to put an offset here 
	jr 		$ra
close:    
	jr   	$ra


# print_list: given address of front of list in $a0
# prints each string in list, one per line, in order
print_list:
	addi	$sp, $sp, -8
	sw  	$ra, 0($sp)
	sw   	$s0, 4($sp)
	move 	$s0, $a0
	beq  	$s0, $zero, Exit_print_list
Loop_print_list:
	lw   	$a0, 0($s0)
	jal  	print_string
	jal  	print_newline
	lw   	$s0, 4($s0) # node = node->next
	bne  	$s0, $zero, Loop_print_list
Exit_print_list:
	lw   	$s0, 4($sp)
	lw   	$ra, 0($sp)
	addi 	$sp, $sp, 8
	jr   	$ra



##################################################
# Pseudo-standard library routines:
#   wrappers around SPIM/MARS syscalls
#

# assumes buffer to read into is in $a0, and max length is in $a1
get_string:
	li 		$v0, 8
       		syscall
	jr 		$ra

# malloc: takes one argument (in $a0) which indicates how many bytes
# to allocate; returns a pointer to the allocated memory (in $v0)
malloc: 
	li 		$v0, 9  # SPIM/MARS code for "sbrk" memory allocation
       		syscall
    jr 		$ra

# print_newline: displays newline to standard output
print_newline:
	li   	$v0, 4
	la   	$a0, STR_NEWLINE
			syscall
	jr 		$ra

# print_string: displays supplied string (in $a0) to standard output
print_string:
	li   	$v0, 4
			syscall  
	jr 		$ra