########################################################################################################################################
# Created by: 	Zhu, Jessie
#		jelzhu
#		11 February 2021
#
# Assignment: 	Lab3: ASCII-risks (Asterisks)
#		CSE 12, Computer Systems and Assembly Language
#		UCSC, Winter 2021
#
# Description:	This program prints a triangle made of asterisks and numbers. 
#
# Notes:	This program is intended to be run from the MARS IDE. 
########################################################################################################################################
.data 

prompt:    .asciiz "Enter the height of the pattern (must be greater than 0):\t"
invalid:   .asciiz "Invalid Entry!\n"
left: 	   .asciiz "*\t"
right: 	   .asciiz "\t*"

.text

# Register Usage:
# $t0: user input height, becomes height+1 for loop to iterate over
# $t1: 1, starting point and counter for the main loop
# $t2: new line (not really sure how this works, but thats what it does in my code)
# $t3: 1, starting point and counter for sub-function (for *s on left and right)



li  $t1  1                                           # Setting $t1 to initial value for main function (later) 
li  $t2  0xa                                         # Setting $t2 to new line in ascii

# GETS THE HEIGHT FOR TRIANGLE
prompt_height: NOP				
               li  $v0  4                            # 4, printing string
               la  $a0  prompt                       # Sets $a0 to prompt statement for printing 
               syscall                               # Prints prompt statement
	
               li  $v0  5                            # 5, reads input
               syscall                               # Lets user input a height
    
               move $t0  $v0                         # Stores height to $t0	
               ble  $t0  0    invalid_input          # Checks if input is valid, calls invalid_input if invalid
               addi $t0  $t0  1                      # Adds 1 to height for iterating in main function
               j    pattern_loop                     # Calls the main function to printing lines of the triangle

# NOTIFIES USER OF INVALID INPUT
invalid_input: NOP			
               li  $v0  4                            # 4, printing string     
               la  $a0  invalid                      # sets $a0 to invalid statement for printing
               syscall                               # Prints "invalid input"
               j   prompt_height                     # Restarts prompt_height 


# MAIN LOOP, PRINTS EACH LINE OF TRIANGLE
pattern_loop: NOP			
              bge  $t1  $t0  program_exit            # Makes sure function is looped n times for every line in n heighted triangle
              li   $t3  1                            # Sets (resets) $t3 to 1 for next loop's counter. 
              # PRINTS ASTERISKS ON LEFT
              left_side: NOP 			
                         bge  $t3  $t1  number       # Makes sure correct number of asterisks are printed, dependent on counter
                         li   $v0  4                 # 4, printing string
                         la   $a0  left              # Sets $a0 to left asterisks for printing
                         syscall                     # Prints * on left side of number
		
                         addi $t3  $t3  1 	     # Increment counter
                         j    left_side              # Returns to beginning of loop
		
              # PRINTS THE CURRENT NUMBER
              number: NOP 
                      li   $v0  1                    # 1, printing integer
                      move $a0  $t1                  # $a0 is now the value of $t1
                      syscall                        # Prints the number
		
                      li   $t3  1                    # Resets $t3 to 1 for next loop's counter. 
                      j    right_side                # Jumps to function right_side
                      
              # PRINTS ASTERISKS ON RIGHT 
              right_side: NOP			
                          bge  $t3  $t1  new_line    # Makes sure correct number of asterisks are printed
                          li   $v0  4                # 4, printing string
                          la   $a0  right            # Sets $a0 to left asterisks for printing
                          syscall                    # Prints * on right side of number
		
                          addi $t3  $t3  1           # Increment counter
                          j    right_side            # Returns to beginning of loop
		
              # MOVES TO NEW LINE FOR NEXT LINE OF TRIANGLE
              new_line: NOP
                        li    $v0  11                # 11, Prints an ascii character
                        move  $a0  $t2               # Sets $a0 to new line
                        syscall                      # Prints new line
                        addi  $t1  $t1  1            # Adds 1 to main function counter. 
                        j pattern_loop               # Returns to beginning of loop

# EXITS PROGRAM
program_exit: NOP
              li $v0, 10                             # 10, exit, terminates execution
              syscall                                # Ends everything





