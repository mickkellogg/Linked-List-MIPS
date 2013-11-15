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

	li   $s0, 0  # initialize the list to NULL
	
Loop_main:
	la   $a0, STR_ENTER
	jal  print_string
	jal  read_string
	move $s1, $v0
	jal trim
	jal strlen
	addi $t0, $zero, 2
	beq $v0, $t0, Exit_loop_main
	jal strcmp
	jal insert

	# replace newline with null terminator
	# ...
	
	# check string length; exit loop if less than 2
	# ...

	# insert string into list
	# ...
	# reassign front of list
	# ...

	j    Loop_main
	
Exit_loop_main:
	move $a0, $s0
	jal  print_list

	jal  print_newline

#	lines commented out - not needed in simulation:
#	lw	 $s1, 8($sp)
#	lw	 $s0, 4($sp)
#	lw	 $ra, 0($sp)
#	addi $sp, $sp, 12
#	jr	 $ra
		
        # exit simulation via syscall
        li   $v0, 10
        syscall



##################################################
# String routines
#

# read_string: allocates MAX_STR_LEN bytes for a string
# and then reads a string from standard input into that memory address
# and returns the address in $v0
read_string:
	addi $sp, $sp, -8
	sw   $ra, 0($sp)
	sw   $s0, 4($sp)

	# ...

	lw   $s0, 4($sp)
	lw   $ra, 0($sp)
	addi $sp, $sp, 8
	jr $ra


# trim: modifies string stored at address in $a0 so that
# first occurrence of a newline is replaced by null terminator
trim:
	#addi 	$t0, $s1, $zero <-- this should just be add bc we aren't using and immediate
 	add 	$t0, $s1, $zero
 strloop:   li		$t1, 10
			beq		$t0, $t1, replace
			addi	$t0, $t0, 1
   			j 		strloop
replace:	#lw		$t2, $zero <-- we should just use the add initialization instead
			add		$t2, $t2, $zero  #make $t2 zero this way
			sw      $t2, 0($s1) #for some reason this guy is giving us issues, the value in memory is not valid.
			sw      $t2, 0($s1)
			jr		$ra

# strlen: given string stored at address in $a0
# returns its length in $v0
strlen: 
	lw		$t1, 0($s1)
lenloop:	beq		$t1, $zero, exitline
			addi	$t1, $t1, 1
			j       lenloop
exitline: 	sw 		$t1, 0($v0)
			jr		$ra



# strcmp: given strings s, t stored at addresses in $a0, $a1
# returns -1 if s < t; 0 if s == t, 1 if s > t
strcmp:
    lw		$t0, 0($a0)
    lw		$t1, 0($a1)
    lb 		$t3, 0($t0)
    lb 		$t4, 0($t1)
    slt 	$t2, $t3, $t4
    bne		$t2, $zero, lessthan
    slt     $t2, $t4, $t3
	beq     $t2, $t4, equalto
	li      $v0, 1
	j 		end
lessthan: li 	$v0, -1
		   j    end
equalto:  li    $v0, 0
		   j 	end
end: 	  jr	$ra
# insert_here: given address of front of list in $a0 
# and address of string to insert in $a1, 
# inserts new linked-list node in front of list;
# returns address of new front of list in $v0
insert_here:
	lw		$t0, 0($a0)
	lw 		$t1, 0($a1)
	addi    $t2, $zero, 8
	sw      $t2, 0($a0)
	jal		malloc
	move 	$t3, $v0
	sw      $t1, 0($t3)
	sw 		$t0, 4($t3)
	sw		$t3, 0($s0)
	sw      $t4, 4($s0)
	lw 		$ra, 0($sp)
	addi	$sp, $sp, -4
	jr $ra



##################################################
# List routines
#


# insert: given address of front of list in $a0 
# and address of string to insert in $a1, 
# inserts new linked-list node in appropriate place in list 
# ...
# returns address of new front of list in $v0 (which may be same as old)
insert: 
	
	lw	  $t0, 0($a0) 	#get the address of front of the list
	lw	  $t1, 0($a1) 
	addi  $t3, $zero, 1	
	addi  $t4, $zero, -1 #get the string address out of $a1
alphloop:	slt   $t2, $t1, $t0  #we had this as 0($t0)...idk why 
			beq   $t2, $t3, put
			beq   $t2, $zero, nextchar
			sw 	  $t1, 0($a0)
			sw 	  $t0, 0($a1)
			jal   strcmp
			move  $v0, $
			addi  $t0, $t0, 8
			j 	  alphloop



	# addi $sp, $sp, -12
	# sw   $ra, 8($sp)
	# sw   $a0, 4(sp)
	# sw   $a1, 0(sp)
	# jal  strcmp


nextchar: addi	$t0, $t0, 4
	      addi  $t1, $t1, 4
	      j 	alphloop
put: 	  li    $t5, 8   
		  move  $a0, $t5
		  jal   malloc	
		  move  $t5, $v0
		  sw    $t1, 0($t5)
		  sw 	$t0, 4($t5)
		  addi  $t0, $t0, -12
		  lw    $t6, 8($t0)
		  bne   $t0, $t6, close
		  sw    $t5, 0($t0) #we forgot to put an offset here 
		  jr 	$ra
close:    jr   $ra


# print_list: given address of front of list in $a0
# prints each string in list, one per line, in order
print_list:
	addi $sp, $sp, -8
	sw   $ra, 0($sp)
	sw   $s0, 4($sp)

	move $s0, $a0
	beq  $s0, $zero, Exit_print_list
Loop_print_list:
	lw   $a0, 0($s0)
	jal  print_string
	jal  print_newline
	lw   $s0, 4($s0) # node = node->next
	bne  $s0, $zero, Loop_print_list
Exit_print_list:
	lw   $s0, 4($sp)
	lw   $ra, 0($sp)
	addi $sp, $sp, 8
	jr   $ra



##################################################
# Pseudo-standard library routines:
#   wrappers around SPIM/MARS syscalls
#

# assumes buffer to read into is in $a0, and max length is in $a1
get_string:
	li   $v0, 8
        syscall
	jr $ra

# malloc: takes one argument (in $a0) which indicates how many bytes
# to allocate; returns a pointer to the allocated memory (in $v0)
malloc: li $v0, 9  # SPIM/MARS code for "sbrk" memory allocation
        syscall
        jr $ra

# print_newline: displays newline to standard output
print_newline:
	li   $v0, 4
	la   $a0, STR_NEWLINE
	syscall
	jr $ra

# print_string: displays supplied string (in $a0) to standard output
print_string:
	li   $v0, 4
	syscall  
	jr $ra