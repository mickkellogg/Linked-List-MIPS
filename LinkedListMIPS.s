# Soul of the Machine - Fall 2013 - Programming Assignment 2
#
# Mick Kellog/Julian Sharifi
#
# MICK: I've tried to add  UPDATE notes to the functions I played with.  (or just apple-f name and they should pop up). 
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

#MICK Commented out the code below to add in Mike's main

# main:  la $a0, STR_ENTER
#        jal print_string
#        jal read_string
#        move $s0, $v0
       
#        move $a0, $s0
#        jal print_string
        
#        li $v0, 10
#        syscall

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
        slt        $t1, $v0, $t0                    #if less than 2 $t1 gets 0 
        bne        $t1, $zero, Exit_loop_main       #if $t1 != 0 (then it is = 1) jump to exit
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
        addi       $sp, $sp, -4                     #allocate space for 1 items on the stack
        #MICK changed immediate to -4 for only 1 space
        sw         $ra, 0($sp)                      #push the jump register onto the stack               
       # sw         $s0, 0($sp)                      #push the head of the list onto the stack
        add        $t0, $zero, $zero                #$t0 gets 0
        la         $t1, MAX_STR_LEN                 #$a0 gets MAX_STR_LEN
        lw         $a0, 0($t1)                      #move MAX_STR_LEN from $t1 into $a0
        #MICk moved the lw up underneath la as Mike said
        jal        malloc                           #jump to malloc to allocate space for string
        move       $a0, $v0                         #move pointer to allocated memory to $a0
        la         $s1, 0($a0)                      #load the new address into reg
        #store the address into $s1
        add        $t1, $zero, $zero                  #get zero
        #changed both of these add codes to make sure its zero
        move       $a1, $t1                         #move zero to a1
        la         $a1, MAX_STR_LEN                 #$a1 gets MAX_STR_LEN
        jal        get_string                       #get the string into $v0
        lw         $ra, 0($sp)                      #load the jump address
        #lw         $s0, 4($sp)                      #load the head of the list
        addi       $sp, $sp, 4                      #push onto the stack space for 2 elements
        move       $v0, $s1                         #move new address into $v0 to return
        #move from $s1 into $v0 to return
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
    la      $t0, 0($a0)         #get the address of the front of the list 
    la      $t1, 0($a1)         #get the address of the string to insert
    lb      $t2, 0($t0)         #get the byte at address in $a0
    beq     $s0, $zero, new     #if list is empty, put it at the front
    addi    $t4, $t0, 4         #get the next 4 bits associated with pointer to the next node
    addi    $t5, $zero, 1       #$t5 gets 1 to compare
    addi    $t6, $zero, -1      #$t6 gets -1 to compare
    add     $t8, $zero, $zero   #get incrementer to check if the node is at the front of the list
    addi    $sp, $sp, -4        #allocate for 1 on the stack
    sw      $ra, 0($sp)         #store $ra on the stack 
alphloop: 
    addi    $sp, $sp, -4        #allocate space for one item on stack
    sw      $a0, 0($sp)         #store the front of the list on the stack 
    la      $a1, 0($a0)         #load address of string in node via the lw done in main
    la      $a0, 0($t1)         #get address of insert string
    beq     $a1, $zero, put     #if pointer is null append at end and dont compare
    jal     strcmp              #jump to string compare
    beq     $v0, $t6, put       #if the string to compare > string in
    beq     $v0, $zero, close   #if they are the same, end the loop without insert
    la      $a0, 0($sp)         #get $a0 off the stack (address of last node)
    #lb     $t2, 0($a0)         #get the byte of the string 
    lw      $t4, 4($a0)         #get second 4bits in the node for pointer to next node
    la      $a0, 0($t4)         #move the address of the next node in to $t1 for next computation
    addi    $sp, $sp, 4         #deallocate the stack 
    beq     $t4, $zero, close   #close if next node == null 
    addi    $t8, $t8, 1         #increment
    j       alphloop    
front: 
    sw      $s4, 0($v0)         #store the pointer to the new node (which in this case is front) to return 
    lw      $ra, 0($sp)         #pop $ra off the stack
    addi    $sp, $sp, 4         #deallocate
    jr      $ra
new: 
    addi    $sp, $sp, 4         #add to the stack for new value
    sw      $ra, 0($sp)         #store $ra on stack
    li      $t7, 8              #get 8 for byte init
    move    $a0, $t7            #move $t7 into $a0
    jal     malloc              #allocate the memory
    move    $t7, $v0            #get memory address
    lw      $t3, 0($a1)         #get word addressing for the new string
    add     $t1, $zero, $zero   #$t1 gets zero    
    sw      $t3, 0($t7)         #store the address for string into the first 4 bits of node
    sw      $t1, 4($t7)         #store the address for string into the last 4 bits of node
    move    $v0, $t7            #move $t7 to $v0
    lw      $ra, 0($sp)         #get $ra back from the stack
    addi    $sp, $sp, 4         #deallocate
    jr      $ra 
put: 
    lw      $t1, 0($sp)         #load $a0 off the stack into $t1
    addi    $sp, $sp, 4         #deallocate the stack
    li      $t7, 8              #load in 8 to $t7
    move    $a0, $t7            #put 8 into $a0 for malloc
    jal     malloc              #allocate memory for the new node
    move    $s4, $v0            #move $s4 to $v0
    lw      $t3, 0($t1)         #get a word associated with address for insert string
    sw      $t3, 0($s4)         #store the string address into the first 4 bits of the new node
    sw      $t4, 4($s4)         #store the point to the next node
    beq     $t8, $zero, front   #if the address is at the front of the list, then return
    lw      $t3, 0($v0)         #get address word into $t3 for new node
    lb      $t1, 0($t1)         #get byte of conductor node's address
    sw      $t3, 4($t1)         #store the pointer to the address of next node into the 
close: 
    la      $v0, 0($t0)         #put front of the list into $v0
    lw      $ra, 0($sp)         #get $ra off stack
    addi    $sp, $sp, 4         #deallocate the stack
    jr      $ra 
    

# print_list: given address of front of list in $a0
# prints each string in list, one per line, in order
print_list:
        add        $sp, $sp, -8
        sw         $ra, 0($sp)
        sw         $s0, 4($sp)
       # move      $s0, $a0
        beq        $a0, $zero, Exit_print_list
Loop_print_list:
        la         $t0, 0($s0)
        la         $a0, 0($s0)
        jal        print_string
        jal        print_newline
        #lb         $t0, 0($s0)            # node = node->next
        lw         $s0, 4($t0)
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


