# Soul of the Machine - Fall 2013 - Programming Assignment 2
#
# Mick Kellog/Julian Sharifi
#
#  
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
        .globl plain_insert
        .globl print_list

        .globl main

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
STR_ENTER: .asciiz "enter a string: "



#################################################################
#################################################################
# Code
#
        .text 


##################################################
# main: repeatedly gets strings from user and enters them in list
# until a string of length less than two is entered;
# prints list in order when done

main:        
#        lines commented out - not needed in simulation:
#        addi $sp, $sp, -12
#        sw $ra, 0($sp)
#        sw $s0, 4($sp) #$s0 will be linked list
#        sw $s1, 8($sp) #$s1 will be the current string
	li 	   $a0, 8 # Prep for malloc
	jal	   malloc # Open space for first node
	move 	   $s0, $v0 # Copy address of memory segment into $s0
	li	   $t0, 0
	sw	   $t0, 0($s0)
	sw 	   $t0, 4($s0)
	#sw	   $zero, 0($s0)
	#sw 	   $zero, 4($s0) # Places zero in the second byte of the segment creating a NULL pointer       
        lb	   $t1, 0($s0)
        
        
Loop_main:
        la         $a0, STR_ENTER
        jal        print_string
        jal        read_string
        # string address is now stored in s1 and v0
        move 	   $a0, $v0
        jal        trim
        jal        strlen
        #move 	   $a0, $s1      # prep for print
        #jal  	   print_string
        addi       $t0, $zero, 1 
        slt        $t1, $v0, $t0                    #if less than 2 $t1 gets 0 
        bne        $t1, $zero, Exit_loop_main       #if $t1 != 0 (then it is = 1) jump to exit
        beq        $v0, $t0, Exit_loop_main
       
        move 	   $a0, $s0  # pass head of list into a0 to prepare for insert
        move	   $a1, $s1  # pass address of string to store
        jal        plain_insert
        move       $s0, $v0
        j          Loop_main
        
Exit_loop_main:
        move        $a0, $s0
        jal         print_list
        jal         print_newline
#        lines commented out - not needed in simulation:
#        lw         $s1, 8($sp)
#        lw         $s0, 4($sp)
#        lw         $ra, 0($sp)
#        addi $sp, $sp, 12
#        jr         $ra                
    # exit simulation via syscall
        li         $v0, 10
                   syscall


##################################################
# String routines
#

# read_string: allocates MAX_STR_LEN bytes for a string
# and then reads a string from standard input into that memory address
# and returns the address in $v0
# UPDATED
read_string:
        addi       $sp, $sp, -4                     #allocate space for 1 items on the stack
        #MICK changed immediate to -4 for only 1 space
        sw         $ra, 0($sp)                      #push the jump register onto the stack               
        add        $t0, $zero, $zero                #$t0 gets 0
        la         $t1, MAX_STR_LEN                 #$a0 gets MAX_STR_LEN
        lw         $a0, 0($t1)                      #move MAX_STR_LEN from $t1 into $a0
        jal        malloc                           #jump to malloc to allocate space for string
        move       $a0, $v0                         #move pointer to allocated memory to $a0 creating buffer
        la         $s1, 0($a0)                      #load the new address into reg
        #store the address into $s1
        add        $t1, $zero, $zero                #get zero
        move       $a1, $t1                         #move zero to a1
        la         $a1, MAX_STR_LEN                 #$a1 gets MAX_STR_LEN
        jal        get_string                       #get the string into $v0
        lw         $ra, 0($sp)                      #load the jump address
        addi       $sp, $sp, 4                      #push onto the stack space for 2 elements
        move       $v0, $s1                         #move new address into $v0 to return
        #move from $s1 into $v0 to return
        jr         $ra                              #jump back to caller function

# trim: modifies string stored at address in $a0 so that
# first occurrence of a newline is replaced by null terminator

trim:
    li $s3, 0

strloop:
        li     $t0, 10                             #$t1 gets 10, ASCII value for newline
        lb     $t1, 0($a0)                         #get byte of character of string and loop
        beq    $t1, $t0, replace                   #if $a0 = go to replace
        addi   $a0, $a0, 1                         #increment $a0 by 8 to piont to first bit of next char
        addi   $s3, $s3, 1                         #incriment s3 by 1 each time to store length of string
        j      strloop                             #jump back to beginning
replace:        
        li     $t2, 0                     #$t2 is set to zero, ASCII value for null terminator
        sb     $t2, 0($a0)                         #$t2 is stored into the byte starting at $a0
        lb     $t1, 0($a0)                         #test byte to make sure it was changed
        jr     $ra                                 #jump back to caller

# strlen: given string stored at address in $a0
# returns its length in $v0 . 
strlen:
        add      $t0, $zero, $s3                   #$t0 gets length of string that had been stored in s3
        add    $v0, $zero, $t0                     #store $t0 into $v0 to return lenght of string
        jr     $ra                                 #jump back to caller
        
        



# strcmp: given strings s, t stored at addresses in $a0, $a1
# returns -1 if s < t; 0 if s == t, 1 if s > t
strcmp:
        #lb     $t0, 0($a0)                        #get byte of first char in string s        
        #w     $t1, 0($a1)                         #get byte of first char in string t
        lb     $t5, ($a0)
        lb     $t6, ($a1)
        addi   $t3, $t3, 1                         #get 1 to compare
        slt    $t2, $t5, $t6                       #if s[0] < t[0] $t2 = 1, else $t2 = 0
        bne    $t2, $t3, lessthan                  #if $t2 == 1, jump to lessthan
        slt    $t2, $t6, $t5                       #if t[0] < s[1], $t2 = 1, else $t2 = 0
        beq    $t2, $t3, greaterthan               #if $t2 == 1, jump to greaterthan
        li     $v0, 0                              #$v0 gets zero
        j      end
lessthan:
        addi   $t4, $t4, -1                        #$t4 gets -1
        #sw     $t4, 0($v0)                        #$v0 gets -1
        move   $v0, $t4 
        j      end                                 #jump to end
greaterthan:
        addi   $t4, $t4, 1                         #$t4 gets 1
        sw     $t4, 0($v0)                         #$v0 gets 1
        j      end                                 #jump to end
end:         
        jr     $ra


##################################################
# List routines
#

# insert: given address of front of list in $a0
# and address of string to insert in $a1,
# inserts new linked-list node in appropriate place in list
# ...
# returns address of new front of list in $v0 (which may be same as old)


plain_insert:
	
	
	add $sp, $sp, -4 # Clear space on the stack
	sw   $ra, 0($sp)
	move $t0, $a0    # copy address of head
	move $t1, $a1    # copy address of string
	li   $a0, 8      # prep for malloc
	jal  malloc
	move $t2, $v0    # copy address of new node into t2
	sw   $t1, 0($t2) # Copy address of string into node creating new head
	sw   $s0, 4($t2) # point to old head
	move $s0, $t2	 # Asign head
	
	#sw   $t0, 4($t2) # Copy address of Head
	#move $s0, $t2    # create new head
	move $v0, $s0    # Store new head in v0
	lw   $ra, 0($sp)
	add  $sp, $sp, 4
	jr   $ra   
	

# print_list: given address of front of list in $a0
# prints each string in list, one per line, in order
print_list:
        #add        $sp, $sp, -8
        #sw         $ra, 0($sp)
        #sw         $s0, 4($sp)
        #move       $s0, $a0
        #beq        $a0, $zero, Exit_print_list 
        
        add        $sp, $sp, -4
        sw         $ra, 0($sp)
      
Loop_print_list:
        #move       $t0, $s0
        lw         $a0, 0($s0)
        lw	   $t5, 0($a0) # Check to see what is in string
        jal        print_string
        jal        print_newline
        #lb         $t0, 0($s0)            # node = node->next
        lw         $s0,  4($s0)
        lw	   $t2, 0($s0)
        bne        $t2, $zero, Loop_print_list
Exit_print_list:
        #lw         $s0, 4($sp)
        lw         $ra, 0($sp)
        addi       $sp, $sp, 8
        jr         $ra



##################################################
# Pseudo-standard library routines:
# wrappers around SPIM/MARS syscalls
#

# assumes buffer to read into is in $a0, and max length is in $a1
get_string:
        li         $v0, 8
                   syscall
        jr         $ra

# malloc: takes one argument (in $a0) which indicates how many bytes
# to allocate; returns a pointer to the allocated memory (in $v0)
malloc:
        li         $v0, 9                           # SPIM/MARS code for "sbrk" memory allocation
                   syscall
        jr         $ra

# print_newline: displays newline to standard output
print_newline:
        li         $v0, 4
        la         $a0, STR_NEWLINE
                   syscall
        jr         $ra

# print_string: displays supplied string (in $a0) to standard output
print_string:
        li         $v0, 4
                   syscall
        jr         $ra

