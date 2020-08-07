*-----------------------------------------------------------
* Title      : Testing file for Group project
* Written by : Lucas Buckeye
* Date       : 7.17.20
* Description: File to test our disassembler program
*-----------------------------------------------------------
    ORG    $400
START:                  ; first instruction of program

* Program Execution Starts Here
    
    *NOP Test Operations
    nop                 ;Test the NOP OPCODE
    
    *MOVE Test Operations
    move    #3,d1 
    move    d1,d2
    move    a1,a2 ;no Good! 
*    Data Register Direct - good
*    Address Register Direct - 
*    Address Register Indirect - 
*    Immediate Addressing - 
*    Address Register Indirect with Post-incrementing
*    Address Register Indirect with Pre-decrementing
*    Absolute Long Address
*    Absolute Word Address
        
    

    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source
  
  
*    Instructions:
*NOP                        
*MOVE, MOVEM
*ADD
*SUB
*MULS, DIVU
*LEA
*AND, NOT
*LSL, ASL
*Bcc (BGT, BLE, BEQ)
*JSR, RTS
*BRA


*    Addressing Modes to Test

*    Data Register Direct
*    Address Register Direct
*    Address Register Indirect
*    Immediate Addressing
*    Address Register Indirect with Post-incrementing
*    Address Register Indirect with Pre-decrementing
*    Absolute Long Address
*    Absolute Word Address

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
