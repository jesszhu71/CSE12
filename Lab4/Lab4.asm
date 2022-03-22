########################################################################################################################################
# Created by:   Zhu, Jessie
#               jelzhu
#               22 February 2021
#
# Assignment:   Lab4: Syntax Checker
#               CSE 12, Computer Systems and Assembly Language
#               UCSC, Winter 2021
#
# Description:  This program checks if a program has balanced braces, brackets, and parenthesis. 
#
# Notes:        This program is intended to be run from the MARS IDE. 
########################################################################################################################################

#Pseudocode:
# 1. Check for valid file name, and count each character of file name
      # if first character is letter, then valid, continue
      # check each character of the file name. If character is not letter, number, underscore, or period, print error (invalid argument), end program (skip to #6). 
      # if the length of the file name is more than 20, print error (invalid argument), end program (skip to #6).
# 2. Then open the file for reading. 
# 3. Read 128 characters, this is buffer, and iterate through each character read. 
      # a. If character is open parethesis/bracket/brace add character to stack, and increment stack counter. 
      # b. If character is closed parenthesis/bracket/brace:
           # 1. If character matches (open brace type match close brace type) the most recent character on the stack
                # The item is removed from the stack and stack counter is decremented
           # 2. Otherwise character doesn't match, and print error (mismatched), end program (skip to #6).
      # c. Otherwise character is not brace, nothing happends, continue to check the next charcter, increment index counter. 
# 4. If buffer has full 128 character, repeat #3, reading the next 128 characters and iterating again, otherwise continue to evaluate success. 
# 5. Check for success. 
      # a. if stack is empty, then print success message, all braces are closed, end program
      # b. if stack is not empty, print error message, and print braces left on stack, end program (#6)
# 6.  End program: close file, syscall end program. 

.data 
file_prompt:              .asciiz    "You entered the file:\n"
invalid_file:             .asciiz    "ERROR: Invalid program argument."
buffer:                   .space     128
mismatch_1:               .asciiz    "ERROR - There is a brace mismatch: "
mismatch_2:               .asciiz    " at index " 
stack_remaining:          .asciiz    "ERROR - Brace(s) still on stack: "
success_1:                .asciiz    "SUCCESS: There are "
success_2:                .asciiz    " pairs of braces."
new_line:                 .asciiz    "\n"


.text
# Register Usage:
# $t0: file name address
# $t1: file name
# $t2: index count
# $t3: intermediate value holder
# $t4: first character of file name/current character being checked
# $t5: Buffer
# $t6: Number of braces
# $t7: item restored from stack
# $t8: UNUSED
# $t9: file descriptor


move $t0, $a1                                                     # Put program argument address into $t0
# Prints the file entered
prompt_file: NOP
             lw   $t1  ($t0)                                      # Puts file name into $t1
             li   $v0  4                                          # 4, printing string
             la   $a0  file_prompt                                # Prints file prompt
             syscall
	    
             li   $v0  4                                          # 4, printing string
             la   $a0  ($t1)                                      # Prints the file name
             syscall
             
             li   $v0  4                                          # 4, printing string
             la   $a0  new_line                                   # Prints new line
             syscall 
             
             li   $v0  4                                          # 4, printing string
             la   $a0  new_line                                   # Prints new line
             syscall 
             
             lb   $a0  ($t1)                                      # Loads the first character of file name             
             move $t4  $a0                                        # Save the first character to $t4
             j    valid_first_character                           # Check if first character is valid
             
            
# CHeck if first character of file name is valid ($t5, $t6, $t7 as used as intermediate value holders)      
valid_first_character: NOP
                       ble  $t4  64   invalid_file_name           # if character has value <=64, character is invalid
                       NOP
                       bge  $t4  123  invalid_file_name           # if character has value >=123, character is invalid
                       NOP
                       sge  $t5  $t4  91                          # $t5 = 1 if $t4 is greater than or equal to 91
                       sle  $t6  $t4  96                          # $t6 = 1 if $t4 is less than or equal to 96
                       and  $t7  $t5  $t6                         # if 91 <= $t4 <= 96, $t7 = 1
                       beq  $t7  1    invalid_file_name           # if 91 <= character <= 96, character is invalid
                       NOP
                       li   $t2, 0
                       j    length_file_loop                      # Character is valid
 
# Counts each character in file name, also validates each character     
length_file_loop: NOP
                  lb   $a0  ($t1)                                 # Loads the current character of file name
                  beqz $a0  return_file_length                    # Stops the loop at the end of the file name
                  NOP
                  move $t4  $a0                                   # Stores current character in $t4
                  addi $t1  $t1  1                                # Increment to next character
                  addi $t2  $t2  1                                # Increments counter for length of file name
                  j    valid_file_name                            # Validates the current character
    
    
# Checks if the current character is valid ($t5, $t6, $t7 as used as intermediate value holders)
valid_file_name: NOP
                 beq  $t4  95   length_file_loop                  # if curr character is _ , character is valid
                 NOP
                 beq  $t4  46   length_file_loop                  # if curr character is . , character id valid
                 NOP
                 sge  $t5  $t4  48                                # $t5 = 1 if $t4 is greater than or equal to 48
                 sle  $t6  $t4  57                                # $t6 = 1 if $t4 is less than or equal to 57
                 and  $t7  $t5  $t6                               # if 91 <= $t4 <= 96, $t7 = 1
                 beq  $t7  1    length_file_loop                  # if 91 <= curr<= 96, character is integer, character is valid
                 NOP
                 ble  $t4  64   invalid_file_name                 # if curr character has value <=64, character is invalid
                 NOP
                 bge  $t4  123  invalid_file_name                 # if curr character has value >=123, character is invalid
                 NOP
                 sge  $t5  $t4  91                                # if curr character has value <=91, character is invalid
                 sle  $t6  $t4  96                                # if curr character has value >=123, character is invalid
                 and  $t7  $t5  $t6                               # if 91 <= $t4 <= 96, $t7 = 1
                 beq  $t7  1    invalid_file_name                 # if 91 <= curr<= 96, character is invalid
                 NOP
                 j    length_file_loop                            # Curr character is valid (since it didn't get caught earlier in function)

# Checks length of file name             
return_file_length: NOP
                    ble   $t2  20   open_file                     # Proceeds to open file if file length is 20 or less
                    NOP
                    j     invalid_file_name                       # File name length is greater than 20, ERROR
    
# Error message, invalid file name    
invalid_file_name: NOP
                   li   $v0   4
                   la   $a0   invalid_file                        # Error Message
                   syscall
                   j    program_exit                              # Exits program
             
# Opens file for reading        
open_file: NOP
           lw   $t1  ($t0)                                        # Loads the file name into $t1          
           li   $v0  13                                           # 13, reading file
           move $a0  $t1                                          # Gets file name, puts into $a0
           li   $a1  0                                            # Flag = 0, open for reading
           li   $a2  0                                            # Mode register is ignored
           syscall
           move $t9  $v0
           li   $t2  0                                            # Index tracker is zeroed
           li   $t6  0                                            # Pairs of braces found counter is zeroed
           li   $t1  0                                            # Number of braces on stack counter is zeroed
           
# Reads file and stores info       
read_file:
           li   $v0  14                                           # 14, read file
           move $a0  $t9                                          # File descriptor set
           la   $a1  buffer                                       # Buffer set
           la   $a2  128                                          # Buffer length set
           syscall
           
           move $t0  $v0                                          # Stores number of characters read in $t0, counter for iterating buffer loop
           move $t3  $v0                                          # Stores number of characters read in $t3, used to check if end of file is reached

           
           
           la   $t5  buffer                                       # Loads buffer into $t5
           j loop_buffer                                          # Goes to loop that checks for braces

           
# Iterates for each character in buffer     
loop_buffer: NOP
             lb   $a0   ($t5)                                     # Gets character from buffer
             beq  $t0   0     check_success                       # If null, we have finished reading the buffer
             NOP
             move $t4   $a0                                       # Move current character into $t4
             addi $t5   $t5   1                                   # Increment to next character of buffer
             addi $t2   $t2   1                                   # Increment index counter
             addi $t0   $t0   -1                                  # Decrements the buffer index counter
             j    check_if_brace                                  # Checks the current character if it is a brace
# Checks if current character is open or closed brace or not brace
check_if_brace: NOP     
                beq $t4  40   add_brace                           # Current character is open parenthesis, branch to add brace 
                NOP
                beq $t4  41   remove_brace                        # Current character is close parenthesis, branch to remove brace
                NOP
                beq $t4  91   add_brace                           # Current character is open parenthesis, branch to add brace
                NOP
                beq $t4  93   remove_brace                        # Current character is close parenthesis, branch to remove brace
                NOP
                beq $t4  123  add_brace                           # Current character is open parenthesis, branch to add brace
                NOP
                beq $t4  125  remove_brace                        # Current character is close parenthesis, branch to remove brace
                NOP
     
                j loop_buffer                                     # Not brace, continue buffer loop
     
     
# Current character is open brace, add to stack
add_brace: NOP
           addi  $t1 $t1   1                                      # Increment counter for number of braces on stack
           addi  $sp $sp   -4                                     # Decrement stack counter position
           sw    $t4 ($sp)                                        # Puts brace in stack   
           j     loop_buffer                                      # Continues buffer loop
           
# Current character is close brace, and checks if current close brace and retrieved open brace are mismatched     
remove_brace: NOP
              addi $t1  $t1   -1                                  # Decrements stack count
              lw   $t7  ($sp)                                     # Gets most recent open brace in stack, store in $t7
              addi $sp  $sp   4                                   # Increments stack counter position
              
              seq  $a0  $t7   40                                  
              seq  $a1  $t4   41
              xor  $a2  $a0   $a1
              beq  $a2  1     brace_mismatch                      # Error if one is parethesis and other is not
              NOP
             
              seq  $a0  $t7   91
              seq  $a1  $t4   93
              xor  $a2  $a0   $a1 
              beq  $a2  1     brace_mismatch                      # Error if one is bracket and other is not
              NOP
              
              seq  $a0  $t7   123
              seq  $a1  $t4   125
              xor  $a2  $a0   $a1
              beq  $a2  1     brace_mismatch                      # Error if one is brace and other is not
              NOP
              add  $t6  $t6   1                                   # Successfully removes brace fromt stack, increments counter for pairs of braces
              j    loop_buffer                                    # Continues buffer loop
              
# Prints brace mismatch message
brace_mismatch: NOP
                li   $v0  4                                       # 4, prints string
                la   $a0  mismatch_1                              # Prints mismatch message part 1
                syscall
       
                li   $v0  11                                      # 11, prints character
                move $a0  $t4                                     # Prints character into $a0
                syscall
      
                li  $v0   4                                       # 4, prints string
                la  $a0   mismatch_2                              # Prints mismatch message part 2
                syscall
      
                li  $v0   1                                       # 1, prints integer
                la  $a0   ($t2)                                   # Prints the index of character in file
                syscall 
                j   program_exit                                  # Exits program
                
# Checks if end of file is read, and whether successful or not
check_success: NOP
               beq  $t3  128  read_file                           # If the current read buffer was 128 characters, continue reading
               NOP
               beq  $t1  0    success_message                     # Nothing left on stack, print success message
               NOP
               #NOT SUCCESSFUl
   
               li   $v0  4                                        # 4, print string   
               la   $a0  stack_remaining                          # Prints stack remaining message
               syscall
               
               j print_stack                                      # Gos to prints the stack
       
       
       

# Prints the stack  
print_stack: NOP
             beq   $t1  0    program_exit                         # If stack empty, end program
             NOP
             lw    $t7  ($sp)                                     # Loads the most recent item from stack        
             addi  $sp  $sp  4                                    # Increments the stack counter
       
             li    $v0  11                                        # 11, print character
             move  $a0  $t7                                       # Prints the most recent item from stack
             syscall
             addi  $t1  $t1  -1                                   # Decrements counter for number of braces in stack
             j     print_stack                                    # Continue to next item in stack
        
       
# Prints success message, with # of pairs of braces found     
success_message: NOP
                 li  $v0  4                                       # 4, print string        
                 la  $a0  success_1                               # Prints the success message part 1        
                 syscall                            
             
                 li  $v0  1                                       # 4, print integer      
                 la  $a0  ($t6)                                   # Prints number of brace pairs found
                 syscall   
             
                 li  $v0  4                                       # 4, print string        
                 la  $a0  success_2                               # Prints the success message part 2
                 syscall   

                 j program_exit                                   # Exits program
                 
# Exits Program
program_exit: NOP
              li $v0 4                                            # 4, print string    
              la $a0 new_line                                     # Prints new line
              syscall      
              
              li $v0 16                                           # 16, close file
              move $a0 $s0                                        # Closes file
              syscall
           
              li $v0, 10                                          # 10, exit, terminates execution
              syscall                                       
              
