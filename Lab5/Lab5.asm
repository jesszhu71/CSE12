########################################################################################################################################
# Created by:   Zhu, Jessie
#               jelzhu
#               08 March 2021
#
# Assignment:   Lab5: Functions and Graphics
#               CSE 12, Computer Systems and Assembly Language
#               UCSC, Winter 2021
#
# Description:  This program contains functions that perform primitive graphics operations on a simulated display. 
#
# Notes:        This program is intended to be run from the MARS IDE. 
########################################################################################################################################
#Pseudocode:
       #Macros:
                # getCoordinates:        takes in a coordinate in format 0x00XX00YY. Right logical shift of 4 bytes gives the x coordinate 
                #                        0x000000XX. Left logical shift of 4 bytes, then right logical shift of 4 bytes gives 
                #                        the y coordinate 0x000000YY. Returns the x and y coordinate
                # formatCoordinates:     takes in x and y coordinate in format 0x000000XX and 0x000000YY respectively. Logical left shift the x 
                #                        coordinate by 4 bytes and then add to y coordinate. Returns the coordinate in 0x00XX00YY format
                # getPixelAddress:       takes in position of of (0,0)in memory, x coordinate, and y coordinate. Multiply 128 to y coordinate, 
                #                        then add to x coordinate. Mutiply this number by 4, and finally add this to (0,0)'s position. 
                #                        Returns the position of a given pixel in memory.  
       #Subroutines:
                # clear_bitmap           takes in a color in format 0x00RRGGBB. Places that color value in each pixel's memory location
                # draw_pixel             takes in a pixel coordinate and color. Gets the x and y coordinate using getCoordinates, then uses 
                #                        getPixelAddress to get pixel location in memory and writes the color value in that memory location. 
                # get_pixel              takes in a coordinate, convert into x and y coordinate using getCoordinates. Then gets the memory location 
                #                        of pixel using getPixelAddress and retrieves and returns the color value at that memory location. 
                # draw_horizontal_line   takes in y coordinate, converts that into 0x00XX00YY format, where x coordinate is 0x00000000. 
                #                        Then gets the memory location for that coordinate(using getCoordinates and then getPixelAddress. 
                #                        Then it puts that color value in that value every 1 bytes starting in that memory location, 128 times. 
                # draw_vertical_line     takes in x coordinate, converts that into 0x00XX00YY format, where y coordinate is 0x00000000. 
                #                        Then gets the memory location for that coordinate and puts that color value in that value every 128 bytes
                #                        128 times. 
                # draw_crosshair         takes in color in format 0x00RRGGBB and intersection point. Using get_pixel, we save the current color at the 
                #                        intersection. Then using draw_vertical_line and draw_horizontal_line, we draw a vertical line and horizontal line.
                #                        Finally we take the saved color and at the intersection, we write the original color in that pixel position in memory. 

# Register Usage:
# $t0 - memory location of pixel at (0,0)
# $t1 - pixel counter, used for loops (unless specified at top of function)
# $t2 - x-coordinate (unless specified at top of function)
# $t3 - y-coordinate (unless specified at top of function)
# $t4 - location in memory of pixel at a coordinate (unless specified at top of function)
# $t7 - Address of originAddress
######################################################
# Macros for instructor use (you shouldn't need these)
######################################################

# Macro that stores the value in %reg on the stack 
#	and moves the stack pointer.
.macro push(%reg)
	subi $sp $sp 4
	sw %reg 0($sp)
.end_macro 

# Macro takes the value on the top of the stack and 
#	loads it into %reg then moves the stack pointer.
.macro pop(%reg)
	lw %reg 0($sp)
	addi $sp $sp 4	
.end_macro

#################################################
# Macros for you to fill in (you will need these)
#################################################

# Macro that takes as input coordinates in the format
#	(0x00XX00YY) and returns x and y separately.
# args: 
#	%input: register containing 0x00XX00YY
#	%x: register to store 0x000000XX in
#	%y: register to store 0x000000YY in
.macro getCoordinates(%input %x %y)
	# YOUR CODE HERE
	#sw %input (%y)
	srl %x %input 16                                    # Right logical shift of 16 bits => x coordinate
	sll %y %input 16                             
	srl %y %y     16                                    # Left logical shift of 16 bits then right logical shift of 16 bits => y coordinate    
	                           
.end_macro

# Macro that takes Coordinates in (%x,%y) where
#	%x = 0x000000XX and %y= 0x000000YY and
#	returns %output = (0x00XX00YY)
# args: 
#	%x: register containing 0x000000XX
#	%y: register containing 0x000000YY
#	%output: register to store 0x00XX00YY in
.macro formatCoordinates(%output %x %y)
	# YOUR CODE HERE
	sll %output %x      16                              # Left logical shift x coordinate by 16 bits
	add %output %output %y                              # Add y coordinate to shifted x coordinate
	
.end_macro 

# Macro that converts pixel coordinate to address
# 	output = origin + 4 * (x + 128 * y)
# args: 
#	%x: register containing 0x000000XX
#	%y: register containing 0x000000YY
#	%origin: register containing address of (0, 0)
#	%output: register to store memory address in
.macro getPixelAddress(%output %x %y %origin)
	# YOUR CODE HERE
	
	mul %output %y      0x00000080                      # output = y * 128 (in hex)
	add %output %output %x                              # output = output + x
	mul %output %output 0x00000004                      # output = output * 4 (in hex)
	add %output %output %origin                         # output (which is pixel address) = output + origin
	
.end_macro


.data
originAddress: .word 0xFFFF0000

.text
# prevent this file from being run as main
li $v0 10 
syscall

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#  Subroutines defined below
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#*****************************************************
# Clear_bitmap: Given a color, will fill the bitmap 
#	display with that color.
# -----------------------------------------------------
# Inputs:
#	$a0 = Color in format (0x00RRGGBB) 
# Outputs:
#	No register outputs
#*****************************************************
clear_bitmap: nop
              # YOUR CODE HERE, only use t registers (and a, v where appropriate) 
              la  $t7  originAddress                       # Loads address of originAddress into $t7             
              lw  $t0  ($t7)                               # Loads item in originAddress location. 
              li  $t1  16384                               # Pixel counter, 16384 pixels in image, we loop once for each pixel
              loop_all_pixels: nop                         # Loops through all pixels and changes the color. 
                               beqz $t1 end_loop_all       # ends loop when each pixel is colored
                               nop
                               sw   $a0 ($t0)              # stores the color value at that pixel's memory location
                               addi $t0 $t0   4            # adds 4 to memory location to go to next pixel
                               addi $t1 $t1   -1           # decrements pixel counter
                               j    loop_all_pixels        # repeat loop
              end_loop_all: nop
                            jr  $ra                        # returns back to where this function was called. 

#*****************************************************
# draw_pixel: Given a coordinate in $a0, sets corresponding 
#	value in memory to the color given by $a1
# -----------------------------------------------------
#	Inputs:
#		$a0 = coordinates of pixel in format (0x00XX00YY)
#		$a1 = color of pixel in format (0x00RRGGBB)
#	Outputs:
#		No register outputs
#*****************************************************
draw_pixel: nop                                           
	    # YOUR CODE HERE, only use t registers (and a, v where appropriate)
	    
	    # Here $t1 is x coordinate, $t2 is y coordinate, $t3 is pixel address
	    la $t7 originAddress                          # Loads address of originAddress into $t7  
	    lw $t0 ($t7)                                  # Loads item in originAddress location. 
	    getCoordinates($a0, $t1, $t2)                 # gets individual x,y coordinate
	    getPixelAddress($t3, $t1, $t2, $t0)           # Gets pixel memory address
	    sw $a1 ($t3)                                  # Stores color value at this pixels memory address
	    jr $ra                                        # returns back to position where this function was called 
	
#*****************************************************
# get_pixel:
#  Given a coordinate, returns the color of that pixel	
#-----------------------------------------------------
#	Inputs:
#		$a0 = coordinates of pixel in format (0x00XX00YY)
#	Outputs:
#		Returns pixel color in $v0 in format (0x00RRGGBB)
#*****************************************************
get_pixel: nop
           # YOUR CODE HERE, only use t registers (and a, v where appropriate)
	
           # Here $t1 is x coordinate, $t2 is y coordinate, $t3 is pixel address 
           la $t7 originAddress                            # Loads address of originAddress into $t7
           lw $t0 ($t7)                                    # Loads item in originAddress location. 
           getCoordinates($a0, $t1, $t2)                   # gets individual x,y coordinate
           getPixelAddress($t3, $t1, $t2, $t0)             # Gets pixel memory address
           lw $v0 ($t3)                                    # Gets color value at this pixels memory address, returns color value in $v0
           jr $ra                                          # returns back to position where this function was called 

#*****************************************************
# draw_horizontal_line: Draws a horizontal line
# ----------------------------------------------------
# Inputs:
#	$a0 = y-coordinate in format (0x000000YY)
#	$a1 = color in format (0x00RRGGBB) 
# Outputs:
#	No register outputs
#*****************************************************
draw_horizontal_line: nop
	              # YOUR CODE HERE, only use t registers (and a, v where appropriate)
                      li   $t1  128                                # Counter for pixels in horizontal line, 128 pixels in a line
                      la   $t7  originAddress                      # Loads address of originAddress into $t7
                      lw   $t0  ($t7)                              # Loads item in originAddress location.
                      li   $t2  0x00000000                         # x coordinate is 0
                      move $t3  $a0                                # Puts y coordinate in $t3
                      getPixelAddress($t4, $t2, $t3, $t0)          # Gets the memory address of (0, y), which is starting point
                      horizontal_loop: nop
                                       beqz  $t1  end_horizontal   # Stops loops when we color all 128 pixels
                                       nop
                                       sw    $a1  ($t4)            # Puts color value in current pixels memory value.
                                       addi  $t1  $t1  -1          # Decrements pixel counter. 
                                       addi  $t4  $t4  4           # adds 4 to memory location to get next pixel's memory location
                                       j     horizontal_loop       # repeat loop
                      end_horizontal: nop
                                      jr  $ra                      # returns back to where draw_horizontal_line was called. 


#*****************************************************
# draw_vertical_line: Draws a vertical line
# ----------------------------------------------------
# Inputs:
#	$a0 = x-coordinate in format (0x000000XX)
#	$a1 = color in format (0x00RRGGBB) 
# Outputs:
#	No register outputs
#*****************************************************
draw_vertical_line: nop
                    # YOUR CODE HERE, only use t registers (and a, v where appropriate)
                    li   $t1  128                          # Counter for pixels in vertical line, 128 pixels in a line
                    la   $t7  originAddress                # Loads address of originAddress into $t7
                    lw   $t0  ($t7)                        # Loads item in originAddress location.
                    move $t2  $a0                          # Puts x coordinate in $t3
                    li   $t3  0x00000000                   # x coordinate is 0
                    getPixelAddress($t4, $t2, $t3, $t0)    # Gets the memory address of (x, 0), which is starting point
                    vertical_loop: nop
                                   beqz $t1 end_vertical   # Stops loops when we color all 128 pixels
                                   nop
                                   sw   $a1 ($t4)          # Puts color value in current pixels memory value.
                                   addi $t1 $t1 -1         # Decrements pixel counter. 
                                   addi $t4 $t4 512        # adds 512 to memory location to get next pixel's memory location
                                   j    vertical_loop      # Repeats loop
                    end_vertical: nop
                                  jr $ra                   # returns back to where draw_horizontal_line was called.


#*****************************************************
# draw_crosshair: Draws a horizontal and a vertical 
#	line of given color which intersect at given (x, y).
#	The pixel at (x, y) should be the same color before 
#	and after running this function.
# -----------------------------------------------------
# Inputs:
#	$a0 = (x, y) coords of intersection in format (0x00XX00YY)
#	$a1 = color in format (0x00RRGGBB) 
# Outputs:
#	No register outputs
#*****************************************************
draw_crosshair: nop
                push($ra)
                push($s0)
                push($s1)
                push($s2)
                push($s3)
                push($s4)
                push($s5)
                move $s5 $sp

                move $s0 $a0                      # store 0x00XX00YY in s0
                move $s1 $a1                      # store 0x00RRGGBB in s1
                getCoordinates($a0 $s2 $s3)       # store x and y in s2 and s3 respectively
	
                # get current color of pixel at the intersection, store it in s4
                # YOUR CODE HERE, only use the s0-s4 registers (and a, v where appropriate)
                jal  get_pixel                    # gets color at intersection pixel
                move $s4 $v0                      # stores the color in $s4
	
                # draw horizontal line (by calling your `draw_horizontal_line`) function
                # YOUR CODE HERE, only use the s0-s4 registers (and a, v where appropriate)
                move $a0 $s3                      # puts y coordinate in $a0
                move $a1 $s1                      # puts cross color in $a1
                jal  draw_horizontal_line         # draws horizontal line of cross
	
                # draw vertical line (by calling your `draw_vertical_line`) function
                # YOUR CODE HERE, only use the s0-s4 registers (and a, v where appropriate)
                move $a0 $s2                      # puts x coordinate in $a0
                move $a1 $s1                      # puts cross color in $a1
                jal  draw_vertical_line           # draws vertical line of cross
	
                # restore pixel at the intersection to its previous color
                # YOUR CODE HERE, only use the s0-s4 registers (and a, v where appropriate)
                move $a0 $s0                     # puts intersection pixel coordinate in $a0
                move $a1 $s4                     # puts previous color in $a1
                jal  draw_pixel                  # colors intersection pixel in previous color

                move $sp $s5
                pop($s5)
                pop($s4)
                pop($s3)
                pop($s2)
                pop($s1)
                pop($s0)
                pop($ra)
                jr $ra
