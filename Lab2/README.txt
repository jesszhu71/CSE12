Jessie Zhu
jelzhu
Winter 2021
Lab 2: Simple Data Path


DESCRIPTION:

In this lab, we implement a simple data path with a register file, ALU, and user inputs. The user can select numbers from the keypad to save into registers and perform bitwise left arithmetic shift using two selected registers; output arithmetic shift can be stored into the register. 

FILES:

Lab2.lgi - This file includes all needed circuits for the lab, interface for interacting with lab's circuits is displayed on page 1. 

INSTRUCTIONS:

This program is intended to run with Multimedia Logic (MML). The user begins by clearing all registers. Then registers can be updated either with the ALU output value or by entering keypad value (decided from the "Store Select" switch). User can select where this value is to be saved using "Write Register Address." Left bit arithmetic shift is automatically performed using registers selected under "Read Register 1 (and 2) Address." Address 1 is the number of left arithmetic shifts to perform, Address is the binary number to perform the shifts on.