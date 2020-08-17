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

******************************************************************************************
    
    *MOVE Test Operations
    move.b    #3,d1
    movea.l  #5, a1
    movea.l  #9, a2 
    move.l    a1,d3
    *move.l   12345, (a1)+
    *move.l   d1, -(a2) *Issues using pre-decrement operator 
    move.l   #123456, d4
    move.w   #12345, d5
    move.l   200, d4
     
*    ADRESSING MODES
*    Data Register Direct - Good
*    Address Register Direct - Good
*    Address Register Indirect - Unsure
*    Immediate Addressing - Unsure
*    Address Register Indirect with Post-incrementing - Issues
*    Address Register Indirect with Pre-decrementing - Issues
*    Absolute Long Address - Good
*    Absolute Word Address - Good
 
******************************************************************************************

    *MOVEM Test Operations       
    
    *Load registers with dummy data
    move.b #1, d1
    move.b #2, d2
    move.b #3, d3
    
    movea.l #4, a4
    movea.l #5, a5
    
    *Begin Test of MOVEM.W
    movem.w   D1-D3/A4-A5,-(sp) *Save Registers to stack (a7)
    movem.w   (sp)+,A4-A5/D1-D3 *Return Registers
    
    *Load registers with dummy data
    move.l #1234, d1
    move.w #12345, d2
    move.l #12345, a3
    move.w #123,   a4
    
    *Begin Test of MOVEM.L
    movem.l   D1-D2/A3-A4,-(sp) *Save Registers to stack (a7)
    movem.l   (sp)+,A3-A4/D1-D2 *Return Registers
    
******************************************************************************************
    
    *ADD Test Operations
    add.b #1,d1
    add.w #45678, d2
    add.l #123456, d3
    add.w d1,d3
    add.l d3, d4
    
    *Is this all, I believe that I don't touch addressing modes, as that's adda


******************************************************************************************
    
    *SUB Test Operations
    sub.b #12, d1
    sub.w #7896, d2
    sub.l #49870, d3
    sub.l d2,d3
    sub.w d1, d2
    sub.b d1, d2
    
    *Same applies for ADD?

******************************************************************************************
    
    *MULS Test Operations 
    
    

    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source
  
  
*    Instructions:
*NOP - Complete                       
*MOVE - In progress  
*MOVEM - In Progress
*ADD - In progress
*SUB - In progress
*MULS
* DIVU
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
