*-----------------------------------------------------------
* Title      :Disassembler Project
* Written by :Anthony Luong, Jonathan Young, Lucas Buckeye, Uyen Minh Hoang
* Date       :7/11/2020
* Description:Team Nibble's CSS422 Disasembler Project
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here
FIRST_FOUR_BITS     MOVE.W  D4,D5   *Move the instruction to decode
                    LSR.W   #8,D5   *Shift right 8 bits to get the first four bits
                    LSR.W   #4,D5   *Shift again to access first 4 bits
*                    CMPI.B  #$00,D5 *If first 4 bits = 0000
*                    BEQ     IS_0000
                    CMPI.B  #$01,D5 *If first 4 bits = 0001
                    BEQ     IS_0001
                    CMPI.B  #$02,D5 *If first 4 bits = 0010
                    BEQ     IS_0010
                    CMPI.B  #$03,D5 *If first 4 bits = 0011
                    BEQ     IS_0011  
                    CMPI.B  #$04,D5 *If first 4 bits = 0100
                    BEQ     IS_0100
                    CMPI.B  #$06,D5 *If first 4 bits = 0110
                    BEQ     IS_0110
*IS_0000

*-----------------------------------------------------
*First four bits are equal to 0001 - prompt MOVE (byte)
*-----------------------------------------------------
IS_0001 
            JSR BIT876          *Looks at mode for move
            CMPI.B  #$00,D5     *If next 3 bits = 000
            BEQ     MODE_000
            *do not look at 1 since it is not valid
            CMPI.B  #$02,D5     *If next 3 bits = 010
            BEQ     IS_0011
            CMPI.B  #$03,D5     *If next 3 bits = 011
            BEQ     IS_0011  
            CMPI.B  #$04,D5     *If next 3 bits = 100
            BEQ     IS_0100
            CMPI.B  #$05,D5     *If next 3 bits = 101
            BEQ     IS_0110
            CMPI.B  #$06,D5     *If next 3 bits = 110
            BEQ     IS_0110
            CMPI.B  #$07,D5     *If next 3 bits = 111
            BEQ     IS_0110
            

*-----------------------------------------------------
*First four bits are equal to 0010 - prompt MOVE
*-----------------------------------------------------
IS_0010

*-----------------------------------------------------
*First four bits are equal to 0011 - prompt MOVE
*-----------------------------------------------------
IS_0011


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

DECODE_4C
            
DECODE_4E   MOVE.W  D4,D5
            CMPI.W  #$4E71,D5   *Check for NOP
            BEQ     OPCODE_NOP
            CMPI.W  #$4E75,D5   *Check for RTS
            BEQ     OPCODE_RTS
            
            
OPCODE_LEA  MOVE.B  #$4C,(A2)+  *Move char L
            MOVE.B  #$45,(A2)+  *Move char E
            MOVE.B  #$41,(A2)+  *Move char A
            BRA     GET_EA      *Decode EA

IS_0110     MOVE.W  D4,D5
            LSR.W   #8,D5
            CMPI.B  #$60,D5     *Check for BRA
            BEQ     OPCODE_BRA  

OPCODE_BRA  MOVE.B  #$42,(A2)+  *Move char B
            MOVE.B  #$52,(A2)+  *Move char R
            MOVE.B  #$41,(A2)+  *Move char A
            MOVE.W  D4,D5       
            ADD.W   (A2),D5     *<PC> + Displacement
            
           
GET_EA      MOVE.W  D4,D5       *Move the instruction to decode
            LSR.B   #3,D5       *Shift to get the mode
            LSL.B   #4,D5
            LSR.B   #4,D5
            CMPI.B  #$3,D5      *Check for the mode
            BEQ     MODE_000    

*-----------------------------------------------------
*Handles the mode for data register - 
*-----------------------------------------------------       
MODE_000    JSR BIT876
            
            

*-----------------------------------------------------
*First four bits are equal to 1101 - prompt add
*-----------------------------------------------------
OPCODE_ADD  MOVE.B  #$41, (A2)+     *Move char A
            MOVE.B  #$44, (A2)+     *Move char D
            MOVE.B  #$44, (A2)+     *Move char D
            JSR     BIT876          *Jump to check OPMODE

*-----------------------------------------------------
*Bit shifting to access bits 11, 10, 9
*-----------------------------------------------------
BIT11109    MOVE.W  D4, D5
            LSL.W   #4, D5      *Drops first 4 bits
            LSR.W   #8, D5      *Pushes to the right 8
            LSR.W   #5, D5      *Pushes to the right 5 to finalize
            RTS          

*-----------------------------------------------------
*Bit shifting to access bits 8, 7, 6
*-----------------------------------------------------
BIT876      MOVE.W  D4, D5
            LSL.W   #7, D5      *Drop first 7 bits
            LSR.W   #8, D5      *Pushes to the right 8
            LSR.W   #5, D5      *Pushes to the right 5 to finalize
            RTS

*-----------------------------------------------------
*Bit shifting to access bits 5, 4, 3
*-----------------------------------------------------
BIT543      MOVE.W  D4, D5
            LSL.W   #8, D5      *Drop first 8 bits
            LSL.W   #2, D5      *Drop 10th bit
            LSR.W   #8, D5      *Pushes to the right 8
            LSR.W   #5, D5      *Pushes to the right 5 to finalize
            RTS 

*-----------------------------------------------------
*Bit shifting to access bits 2, 1, 0
*-----------------------------------------------------
BIT210      MOVE.W  D4, D5
            LSL.W   #8, D5      *Drop first 8 bits
            LSL.W   #5, D5      *Drop 13th bit
            LSR.W   #8, D5      *Pushes to the right 8
            LSR.W   #5, D5      *Pushes to the right 5 to finalize
            RTS 
            
OPCODE_NOT

OPCODE_NOP

OPCODE_RTS   

    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
