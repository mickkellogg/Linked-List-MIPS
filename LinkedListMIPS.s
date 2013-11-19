# Soul of the Machine - Fall 2013 - Programming Assignment 2
#
# Mick Kellog/Julian Sharifi
#
# MICK: I've tried to add  UPDATE notes to the functions I fucked with.  (or just apple-f name and they should pop up). 
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
#
main:        
#        lines commented out - not needed in simulation:
#        addi $sp, $sp, -12
#        sw $ra, 0($sp)
#        sw $s0, 4($sp) #$s0 will be linked list
#        sw $s1, 8($sp) #$s1 will be the current string
        li         $s0, 0 # initialize the list to NULL
        
Loop_main:
        la         $a0, STR_ENTER
        jal        print_string
        jal        read_string
        move       $s1, $v0
        jal        trim
        jal        strlen
        addi       $t0, $zero, 1 # Julian: Changed from two. We need to add an extra check for 0 below it as well (IF t0 < 2). 
        beq        $v0, $t0, Exit_loop_main
        jal        strcmp
        jal        insert
        # replace newline with null terminator
        # ...
        
        # check string length; exit loop if less than 2
        # ...

        # insert string into list
        # ...
        # reassign front of list
        move      $s0, $v0
        j         Loop_main
        
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
        addi       $sp, $sp, -8                     #allocate space for 2 items on the stack
        sw         $s0, 0($sp)                      #push the head of the list onto the stack
        add        $t0, $t0, $zero                  #$t0 gets 0
        la         $t1, MAX_STR_LEN                 #$a0 gets MAX_STR_LEN
        sw         $ra, 0($sp)                      #push the jump register onto the stack    ! we were storing                
        lw         $a0, 0($t1)                      #move MAX_STR_LEN from $t1 into $a0
        jal        malloc                           #jump to malloc to allocate space for string
        move       $a0, $v0                         #move pointer to allocated memory to $a0
        add        $t1, $t1, $zero                  #get zero
        move       $a1, $t1                         #move zero to a1
        la         $a1, MAX_STR_LEN                 #$a1 gets MAX_STR_LEN
        jal        get_string                       #get the string into $v0
        lw         $ra, 0($sp)                      #load the jump address
        lw         $s0, 4($sp)                      #load the head of the list
        addi       $sp, $sp, 8                      #push onto the stack space for 2 elements
        jr         $ra                              #jump back to caller function


# trim: modifies string stored at address in $a0 so that
# first occurrence of a newline is replaced by null terminator
# UPDATED
trim:
    li $s3, 0

strloop:
        li     $t0, 10                             #$t1 gets 10, ASCII value for newline
        lb     $t1, 0($a0)                         #get byte of character of string and loop
        beq    $t1, $t0, replace                   #if $a0 = go to replace
        addi   $a0, $a0, 1                         #increment $a0 by 8 to piont to first bit of next char
        addi   $s3, $s3, 1             # Julian: incriment s3 by 1 each time to store length of string
        j      strloop                             #jump back to beginning
replace:        
        add    $t2, $t2, $zero                     #$t2 is set to zero, ASCII value for null terminator
        sb     $t2, 0($a0)                         #$t2 is stored into the byte starting at $a0
        lb     $t1, 0($a0)                         #test byte to make sure it was changed
        jr     $ra                                 #jump back to caller

# strlen: given string stored at address in $a0
# returns its length in $v0 UPDATED. 
strlen:
        add      $t0, $zero, $s3                    #$t0 gets length of string that had been stored in s3
        add    $v0, $zero, $t0                     #store $t0 into $v0 to return lenght of string
        jr     $ra                                 #jump back to caller
        
        



# strcmp: given strings s, t stored at addresses in $a0, $a1
# returns -1 if s < t; 0 if s == t, 1 if s > t
strcmp:
        #lb     $t0, 0($a0)                         #get byte of first char in string s        
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
        #sw     $t4, 0($v0)                         #$v0 gets -1
        move   $v0, $t4 
        j      end                                 #jump to end
greaterthan:
        addi   $t4, $t4, 1                         #$t4 gets 1
        sw     $t4, 0($v0)                         #$v0 gets 1
        j      end                                 #jump to end
end:         
        jr     $ra

# insert_here: given address of front of list in $a0
# and address of string to insert in $a1,
# inserts new linked-list node in front of list;
# returns address of new front of list in $v0
insert_here:
        lw     $t0, 0($a0)                         #$t0 get $a0
        lw     $t1, 0($a1)                         #$t1 gets $a1
        addi   $t2, $zero, 8                       #$t2 gets 8
        sw     $t2, 0($a0)                         #$t2 gets stored into $a0
        addi   $sp, $sp, 4                         #allocate space for $ra
        sw     $ra, 0($sp)                         #store jump reg onto stack 
        jal    malloc                              #allocate 2 bytes for the memory
        move   $t3, $v0                            #get address of new memory from $v0 and move to $t3
        sw     $t1, 0($t3)                         #store the string pointer into bits 0-7 of the new memory
        sw     $t0, 4($t3)                         #store the pointer to the original front of the list
        #sw     $t3, 0($s0)                        #store the new node into $s0
        # ^^ I think this is supposed to be done in main
        lw     $ra, 0($sp)                         #pop the register to jump back to off the stack
        addi   $sp, $sp, -4                        #pop the stack
        jr     $ra                                 #jump back to caller



##################################################
# List routines
#


# insert: given address of front of list in $a0
# and address of string to insert in $a1,
# inserts new linked-list node in appropriate place in list
# ...
# returns address of new front of list in $v0 (which may be same as old)
# Julian: When we load a word (4 bytes) from a0, I'm getting an error i think because they'res only one byte there (the zero from the null).
# I've changed them all to LB's instead, but i'm not sure that's right. I'm still getting errors. See what you think?
insert:
        la      $t0, 0($a0)                #get the pointer to the string at the front of the list
        la      $t1, 0($a1)                #get the address of the string to insert
        addi    $t2, $t0, 4             #get the pointer to the next node in the list           #get address of string to compare to
        addi    $sp, $sp, 4             #allocate on stack
        sw      $ra, 0($sp)             #store jump reg onto stack
        addi    $t2, $zero, 1           #$t2 gets 1
        addi    $t3, $zero, -1          #$t2 gets -1

alphloop: 
        addi    $sp, $sp, -4                #add to stack
        sw      $a0, 0($sp)             #store $a0 onto the stack
        la      $a0, 0($t0)             #address of string 
        jal     strcmp                  #compare the strings
        beq     $v0, $t3, nextString    #if $v0 = -1, then value is less than string at node so put it in
        beq     $v0, $zero, close       #the values are equal, value is in list so exit
        beq     $v0, $t2, put
nextString:
        lw      $a0, 0($sp)             #pop a0 off stack
        addi    $sp, $sp, 4             #deallocate
        move    $a0, $t2                #get address of next node
        addi    $t2, $a0, 4
        addi    $t4, $t4, 1             #increment t4 to see if not front of list
        j       alphloop
put: 
        addi    $sp, $sp, -4             #add to the stack
        sw      $a0, 0($sp)             #store $a0 onto the stack
        li      $t5, 8                  #load 8 into $t5
        move    $a0, $t5                #move into $a0
        jal     malloc                  #allocate 1 byte for node
        lw      $a0, 0($sp)             #load $a0 off the stack
        addi    $sp, $sp, 4            #deallocate memory on stack
        la      $t5, 0($v0)             #move new memory byte to $t5
        sw      $a1, 0($t5)             #store the address of the string into $t5
       # lw      $t6, 4($a0)            #get pointer from $a0
        sw      $t2, 4($t5)             #store pointer into last 4 bits of $t5
        beq     $t4, $zero, close       #check if its at the front, if not continue
        addi    $a0, $a0, -12           #go back -12 to get the pointer to the next string
        sw      $v0, 0($a0)             #store the memory pointer into the parent node's pointer
        la      $v0, 0($t0)             #get the front of the list
        lw      $a0, 4($sp)
        lw      $ra, 0($sp)             #get jump reg
        addi    $sp, $sp, 8            #deallocate the stack
        jr      $ra
close: 
        lw      $a0, 0($sp)             #pop a0 off stack
        lw      $ra, 4($sp)             #get $ra off stack
        addi    $sp, $sp, 8             #deallocate
        jr      $ra 

# print_list: given address of front of list in $a0
# prints each string in list, one per line, in order
print_list:
        addi    $sp, $sp, -8
        sw      $ra, 0($sp)
        sw      $s0, 4($sp)
        move    $s0, $a0
        beq     $s0, $zero, Exit_print_list
Loop_print_list:
        lw         $a0, 0($s0)
        jal        print_string
        jal        print_newline
        lw         $s0, 4($s0) # node = node->next
        bne        $s0, $zero, Loop_print_list
Exit_print_list:
        lw         $s0, 4($sp)
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