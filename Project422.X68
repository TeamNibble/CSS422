*-----------------------------------------------------------
* Title      :Final project for CSS 422 - Diassembler
* Written by :Uyen Hoang
* Date       :07/17/20
* Description:Dissameble the machine code
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here
FIRST_FOUR_BITS     MOVE.W  D4,D5   *Move the instruction to decode
                    LSR.W   #12,D5  *Shift right 12 bits to get the first four bits
                    CMPI.B  #$00,D5 *If first 4 bits = 0000
                    BEQ     IS_0000
                    CMPI.B  #$01,D5 *If first 4 bits = 0001
                    BEQ     IS_0001
                    CMPI.B  #$02,D5 *If first 4 bits = 0010
                    BEQ     IS_0010 
                    CMPI.B  #$04,D5 *If first 4 bits = 0010
                    BEQ     IS_0100
                    CMPI.B  #$06,D5 *If first 4 bits = 0110
                    BEQ     IS_0110
   
IS_0100     MOVE.W  D4,D5       *Move the instruction to decode
            BTST.L  #$08,D5     *Test the 8th bit for LEA
            BNE     OPCODE_LEA  *If the 8th bit = 1 -> It's LEA
            LSR.W   #8,D5       *Shift to get the second four bits
            LSL.B   #4,D5
            LSR     #4,D5
            CMPI.B  #$E,D5      *It's either NOP, JSR, or RTS
            BEQ     DECODE_4E
            CMPI.B  #$C,D5      *Its's either MULS.L, DIVU.L
            BEQ     DECODE_4C   
            CMPI.B  #$06,D5     *It's NOT
            BEQ     OPCODE_NOT  
            
DECODE_4E   MOVE.W  D4,D5
            CMPI.W  #$4E71,D5   *Check for NOP
            BEQ     OPCODE_NOP
            CMPI.W  #$4E75,D5   *Check for RTS
            BEQ     OPCODE_RTS
            
            
OPCODE_LEA  MOVE.B  #$4C,(A1)+  *Move char L
            MOVE.B  #$45,(A1)+  *Move char E
            MOVE.B  #$41,(A1)+  *Move char A
            BRA     GET_EA      *Decode EA

IS_0110     MOVE.W  D4,D5
            LSR.W   #8,D5
            CMPI.B  #$60,D5     *Check for BRA
            BEQ     OPCODE_BRA  

OPCODE_BRA  MOVE.B  #$42,(A1)+  *Move char B
            MOVE.B  #$52,(A1)+  *Move char R
            MOVE.B  #$41,(A1)+  *Move char A
            MOVE.W  D4,D5       
            ADD.W   (A2),D5     *<PC> + Displacement
            
           
GET_EA      MOVE.W  D4,D5       *Move the instruction to decode
            LSR.B   #3,D5       *Shift to get the mode
            LSL.B   #4,D5
            LSR.B   #4,D5
            CMPI.B  #$3,D5      *Check for the mode
            BEQ     MODE_000    
            
MODE_000    

    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
