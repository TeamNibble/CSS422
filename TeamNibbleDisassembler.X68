*-----------------------------------------------------------
* Title      :Disassembler Project
* Written by :Anthony Luong, Jonathan Young, Lucas Buckeye, Uyen Minh Hoang
* Date       :7/11/2020
* Description:Team Nibble's CSS422 Disasembler Project
*-----------------------------------------------------------
stackPointer    EQU $0FFF    
    ORG    $1000
START:                  ; first instruction of program

* Put program code here
                    LEA     stackPointer,SP *Load stack address to the stack pointer
                    MOVEA.L #OutPut, A2     *Holds location for output values
                    
GET_INPUT           MOVE.B  #13,D0
                    LEA     PromptMess1, A1     *Get the starting address
                    TRAP    #15
                    LEA     StartAddr, A1
                    MOVE.B  #2,D0
                    TRAP    #15
                    JSR     TO_HEX          *Convert it to hex
                    BSR     CHECK_ADDRESS   *Check for valid address
                    MOVEA.L A0,A5           *Store the starting address in A5
                    MOVEA   A2,CurrentAddress *Copies the staring address to the address tracker 
                    
                    MOVE.B  #13,D0          *Get the ending address
                    LEA     PromptMess2, A1
                    TRAP    #15
                    LEA     EndAddr, A1
                    MOVE.B  #2,D0
                    TRAP    #15
                    JSR     TO_HEX          *Convert it to hex
                    BSR     CHECK_ADDRESS   *Check for valid address
                    MOVEA.L A0,A6           *Store the ending address in A6
                    MOVE.L  #0, D3          *Used for loop count
                    BRA     LOOPCOUNT

*-----------------------------------------------------
*Tracker to check screen line count and memory read end
*-----------------------------------------------------                     
LOOPCOUNT           *TO-DO Get instruction address address here (or call loop to do so)
                    MOVE.B  #$24, (A1)+         *Load the '$' symbol
                    *TO-DO Print address here
                    MOVE.B  #$9,(A1)+           *Tab over
                    JSR     START_DISASSEMBLE   *Call disassemble protocol
                    MOVE.B  #$D, (A1)+          *CR
                    MOVE.B  #$A, (A1)+          *LF
                    CMP.L   A5, A6              *checks compares starting and current address
                    BEQ     ENDOFFILE           *Loop back to start if the end is reached
                    ADD.B   #1, D3              *Screen counter
                    CMP.B   #30, D3             *Screens can/should only hold 30 lines
                    BEQ     USERENTER           *User will need to hit enter to continue
                    BRA     LOOPCOUNT           *Returns to the start of this loop

*-----------------------------------------------------
*Method to prompt user 
*-----------------------------------------------------                     
USERENTER           LEA     EnterMess, A1   *Lets the user know they are at the end of screen
                    MOVE.B  #14, D0
                    TRAP    #15
                    MOVE.B  #2, D0          *waits for user input (mainly the enter key)
                    TRAP    #15
                    RTS

*-------------------------------------------------------------------
*Prompts user if they would like to disassemble again or end program
*-------------------------------------------------------------------                    
ENDOFFILE           LEA     EndOfFileMess, A1 *Asks the user if they would like to disassemble again
                    MOVE.B  #13, D0
                    TRAP    #15
                    MOVE.B  #5, D0 *Read a single character from the keyboard into D1
                    TRAP    #15
                    CMP.B   D1, #$79 *If y is enetered restart program, else program will be terminated
                    BEQ     GET_INPUT
                    MOVE.B  #9, D0   *Terminate the program
                    TRAP    #15
                                    
*-----------------------------------------------------
*Check for out-of-range address.
*-----------------------------------------------------                   
CHECK_ADDRESS       *MOVE.L  #$00FFFFFE, D2
                    *CMPI.L  D2,(A0)
                    *BGT     INVALID_ADDRESS
                    RTS  

INVALID_ADDRESS     LEA     InvalidMess,A1
                    MOVE.B  #13,D0
                    TRAP    #15
                    BRA     GET_INPUT

*-----------------------------------------------------
*Convert the current string to appropriate hex values.
*D2: stores the current char from the user's input.
*D3: stores the temperary converted address.
*A0: stores the final converted address.
*-----------------------------------------------------
START_CONVERT       MOVEM.L D2-D3,-(SP)
                    CLR     D2      *Clear the registers
                    CLR     D3
                    CLR     D4
                    *CLR     A0

TO_HEX              MOVE.B  (A1)+,D2
                    CMPI.B  #$30,D2         *If less than $30 -> error
                    BLT     HEX_ERROR
                    CMPI.B  #$39,D2         *If less than or equal to $39 -> convert to number
                    BLE     NUMBER
                    CMPI.B  #$41,D2         *If less than $41 -> error
                    BLT     HEX_ERROR
                    CMPI.B  #$46,D2         *If less than or equal to $46 -> convert to capital letter
                    BLE     CAP_LETTER
                    CMPI.B  #$67,D2         *If less than $67 -> convert to lowercase letter
                    BLT     LOWERCASE
                    CMPI.B  #$66,D2         *If higher than $66 -> error
                    BGT     HEX_ERROR

HEX_ERROR           LEA     ErrorMess,A1    *Print error message for invalid hex value
                    MOVE.B  #14,D0
                    TRAP    #15
                    MOVE.L  CurrentAddress, D1 * Move address into D1 to output
                    MOVE.B  #3,D0 * Display signed number in D1 in decimal. 
                    TRAP    #15   * Print out invalid address
                    LEA     NewLine, A1 *Create new line
                    MOVE.B  #13,D0
                    TRAP    #15
                    ADD.W  #$2, CurentAddress *Increment by Word Value for invalid opcode
                    BRA     GET_INPUT       *Prompt the user to input again
                    
NUMBER              SUBI.B  #$30,D2         *Convert to number in hex
                    ADD.B   D2,D3           *Copy it to D3
                    BRA     CONTINUE
                    
CAP_LETTER          SUBI.B  #$37,D2         *Convert to capital letter in hex
                    ADD.B   D2,D3           *Copy it to D3
                    BRA     CONTINUE
                    
LOWERCASE           SUBI.B  #$57,D2         *Convert to capital letter in hex
                    ADD.B   D2,D3           *Copy it to D3
                    BRA     CONTINUE
                    
CONTINUE            CMPI.W  #0,D1           *If the length of string = 0
                    BEQ     DONE_CONVERT
                    CMPI.B  #$0,(A1)        *If we get null terminator
                    BEQ     DONE_CONVERT
                    LSL.L   #4,D3           *Shift left 4 bits to store later values.
                    SUBI.W  #1,D1           *--length of string
                    BRA     TO_HEX          *Start another loop

DONE_CONVERT        MOVE.L  D3,A0           *Move the converted address to A0
                    MOVEM.L (SP)+,D2-D3
                    RTS        

START_DISASSEMBLE   MOVE.B  (A2)+,D4    *Move the instruction to D4
                    LSL.L   #$4,D4      *Move 4 bits for the next byte
                    MOVE.B  (A2)+,D4    *Need to move by byte because address can be odd
                    CMP.L   A2,A3       *If we reach the ending address
                    BEQ     DONE_DISASSEMBLE    *We're done
                    JSR     FIRST_FOUR_BITS     *Start opcode decoding
                    BRA     START_DISASSEMBLE        

*-----------------------------------------------------
*Reads first four bits of OP-Code instruction and branches appropriately 
*-----------------------------------------------------
FIRST_FOUR_BITS     MOVE.W  D4,D5   *Move the instruction to decode
                    LSR.W   #8,D5   *Shift right 8 bits to get the first four bits
                    LSR.W   #4,D5   *Shift again to access first 4 bits
                    CMPI.B  #$00,D5 *If first 4 bits = 0000 error
                    BEQ     HEX_ERROR
                    CMPI.B  #$04,D5 *If first 4 bits = Less than 4
                    BLT     MOVESIZE 
                    CMPI.B  #$04,D5 *If first 4 bits = 0100
                    BEQ     IS_0100
                    CMPI.B  #$06,D5 *If first 4 bits = 0110
                    BEQ     IS_0110
                    CMPI.B  #$13,D5 *If first 4 bits = 1101 (13-ADD)
                    BEQ     IS_1101
                    BRA     HEX_ERROR *If none of the bits match print error
                    RTS
                    
*-----------------------------------------------------
*First four bits are equal to 0001 - prompt MOVE (byte)
*-----------------------------------------------------
IS_0001     MOVE.B  #$42,(A1)+  *Move char B
            MOVE.B  #$9,(A1)+  *Tab over
            MOVE.B  D5, OpSize  *Store size of instruction
            JSR BIT876          *Looks at mode for move
            CMPI.B  #$00,D5     *If next 3 bits = 000
            BEQ     MODE_000
            *Move Bits 8 7 6 do not allow for 001 mode type - An
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
IS_0010     MOVE.B  #$4C,(A1)+  *Move char L
            MOVE.B  #$9,(A1)+  *Tab over
            MOVE.B  D5, OpSize  *Store size of instruction

*-----------------------------------------------------
*First four bits are equal to 0011 - prompt MOVE
*-----------------------------------------------------
IS_0011     MOVE.B  #$57,(A1)+  *Move char W
            MOVE.B  #$9,(A1)+  *Tab over
            MOVE.B  D5, OpSize  *Store size of instruction


*-----------------------------------------------------
*First four bits are equal to 0100 - 
* Possible OPCodes: MOVEM, NOP, JSR, RTS, LEA, NOT, MULS.L, DIVU.L
*-----------------------------------------------------
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
            
            
OPCODE_LEA  MOVE.B  #$4C,(A1)+  *Move char L
            MOVE.B  #$45,(A1)+  *Move char E
            MOVE.B  #$41,(A1)+  *Move char A
            MOVE.B  #$9,(A1)+   *Tab over
            BRA     GET_EA      *Decode EA

*-----------------------------------------------------
*First four bits are equal to 0110 - 
*Possible OP-Codes:Bcc, BRA
*-----------------------------------------------------
IS_0110     MOVE.W  D4,D5
            LSR.W   #8,D5
            CMPI.B  #$60,D5     *Check for BRA
            BEQ     OPCODE_BRA  

OPCODE_BRA  MOVE.B  #$42,(A1)+  *Move char B
            MOVE.B  #$52,(A1)+  *Move char R
            MOVE.B  #$41,(A1)+  *Move char A
            MOVE.B  #$9,(A1)+   *Tab over
            MOVE.W  D4,D5       
            ADD.W   (A2),D5     *<PC> + Displacement
            
*-----------------------------------------------------
*Handles the last portion of opcode read - Effective Address
*-----------------------------------------------------            
GET_EA      JSR     BIT543
            CMPI.B  #$0,D5
            BEQ     MODE_000
            CMPI.B  #$1,D5
            BEQ     MODE_001
            CMPI.B  #$2,D5
            BEQ     MODE_010
            CMPI.B  #$3,D5      *Check for the mode
            BEQ     MODE_011
            CMPI.B  #$4,D5
            BEQ     MODE_100
            CMPI.B  #$7,D5
            BEQ     MODE_111
            RTS    

*-----------------------------------------------------
*Handles the mode for EA data register - retrieves Bits 2 1 0 and associated reg number
*-----------------------------------------------------       

*000 = Dn
MODE_000    MOVE.B  D5, EAMODE  *Assign mode val to variable
            JSR     BIT210      *Get the data register
            MOVE.B  D5, EARegNum *Assign register val to varaible
            MOVE.B  #$44,(A1)+  *Move char D
            ADDI.B  #$30,D5     *Convert number to string
            MOVE.B  D5, (A1)+   *Load converted string
            RTS

*001 = An         
MODE_001    MOVE.B  D5, EAMODE  *Assign mode val to variable
            JSR     BIT210      *Get the address register
            MOVE.B  D5, EARegNum *Assign register val to varaible
            MOVE.B  #$41,(A1)+  *Move char A
            ADDI.B  #$30,D5     *Convert number to string
            MOVE.B  D5, (A1)+   *Load converted string
            RTS 

*010 = (An)      
MODE_010    MOVE.B  D5, EAMODE  *Assign mode val to variable
            JSR     BIT210      *Get the data register
            MOVE.B  D5, EARegNum *Assign register val to varaible
            MOVE.B  #$28,(A1)+  *Move '('
            MOVE.B  #$41,(A1)+  *Move char A
            ADDI.B  #$30,D5     *Convert number to string
            MOVE.B  D5, (A1)+   *Load converted string
            MOVE.B  #$29,(A1)+  *Move ')'
            RTS

*100 = -(An)
MODE_100    MOVE.B  D5, EAMODE  *Assign mode val to variable
            JSR     BIT210      *Get the data register
            MOVE.B  D5, EARegNum *Assign register val to varaible
            MOVE.B  #$2D,(A1)+  *Move '-'
            MOVE.B  #$28,(A1)+  *Move '('
            MOVE.B  #$41,(A1)+  *Move char A
            ADDI.B  #$30,D5     *Convert number to string
            MOVE.B  D5, (A1)+   *Load converted string
            MOVE.B  #$29,(A1)+  *Move ')'
            RTS

*011 = (An)+          
MODE_011    MOVE.B  D5, EAMODE  *Assign mode val to variable
            JSR     BIT210      *Get the data register
            MOVE.B  D5, EARegNum *Assign register val to varaible
            MOVE.B  #$28,(A1)+  *Move '('
            MOVE.B  #$41,(A1)+  *Move char A
            ADDI.B  #$30,D5     *Convert number to string
            MOVE.B  D5, (A1)+   *Load converted string
            MOVE.B  #$29,(A1)+  *Move ')'
            MOVE.B  #$2B,(A1)+  *Move '+'
            RTS

*111 = (xxx).W, (xxx).L, #<data>
MODE_111    MOVE.B  D5, EAMODE          *Assign mode val to variable
            JSR     BIT210              *Get the register 
            MOVE.B  D5, EARegNum        *Assign register val to varaible
            CMPI.B  #$00,D5             *Is it a word addressing?
            BEQ     GET_WORD_ADDRESS
            CMPI.B  #1,D5               *Is it a long addressing?
            BEQ     GET_LONG_ADDRESS
            CMPI.B  #4,D5               *Is it immediate addressing?
            BEQ     GET_IMMEDIATE
            RTS

*-----------------------------------------------------
*Stores EA, if any to be prepared for output - 
*----------------------------------------------------- 
EA_APPEND   *TO-DO read how many bits are in the size
            *TO-DO read if the source mode has an address or val to append
            *TO-DO read if the destination mode has an address or val to append
            *EXAMPLE ==MOVE.B #8, BitLen== ->13FC 0008 00009076
            *          ^instruction     ^   Op-Code - source val - address
    
*-----------------------------------------------------
*First four bits are equal to 1101 - prompt ADD
*Will fill values for: BitLen, DnRegNum, OpSize, EAMode, EARegNum
*-----------------------------------------------------
IS_1101     MOVEM.L D0-D7/A0-A6, -(SP)  *Copy contents of all registers into previous SP
            MOVE.B  #$41, (A1)+     *Move char A
            MOVE.B  #$44, (A1)+     *Move char D
            MOVE.B  #$44, (A1)+     *Move char D
            MOVE.B  #$2E, (A1)+     *Move char . 
            JSR     BIT11109
            MOVE.B  D5, DnRegNum    *Holds value for Dn#
            JSR     BIT876          *Jump to get OPMODE bits
            MOVE.B  D5, OpSize      *move OPMODE size to variable- This tells where Dn is
            
            
            MULU    #6, D5          *Form offset
            LEA     BWLOPM, A3      *Load OPMODE jump table - will print size
            JSR     0(A3, D5)
            
            CMPI.B  #3, OpSize      
            BGT     DNOut           *Branch operation for when Dn is first
            BLT     GET_EA          *When <ea> is first
            
            MOVE.B  #$2C, (A1)+     *Move char ,
            MOVE.B  #$20, (A1)+     *Move char ' '
            
            CMPI.B  #3, OpSize
            BGT     GET_EA          *Second part operation for when Dn is first
            BLT     DNOut           *Second part operation for when <ea> is first
            
            *TO-DO Append the <ea> value if any

*-----------------------------------------------------
*Bit shifting to access bits 11, 10, 9
*-----------------------------------------------------
BIT11109    CLR.L   D5
            MOVE.W  D4, D5
            LSL.W   #4, D5      *Drops first 4 bits
            LSR.W   #8, D5      *Pushes to the right 8
            LSR.W   #5, D5      *Pushes to the right 5 to finalize
            RTS          

*-----------------------------------------------------
*Bit shifting to access bits 8, 7, 6
*-----------------------------------------------------
BIT876      CLR.L   D5
            MOVE.W  D4, D5
            LSL.W   #7, D5      *Drop first 7 bits
            LSR.W   #8, D5      *Pushes to the right 8
            LSR.W   #5, D5      *Pushes to the right 5 to finalize
            RTS

*-----------------------------------------------------
*Bit shifting to access bits 5, 4, 3
*-----------------------------------------------------
BIT543      CLR.L   D5
            MOVE.W  D4, D5
            LSL.W   #8, D5      *Drop first 8 bits
            LSL.W   #2, D5      *Drop 10th bit
            LSR.W   #8, D5      *Pushes to the right 8
            LSR.W   #5, D5      *Pushes to the right 5 to finalize
            RTS 

*-----------------------------------------------------
*Bit shifting to access bits 2, 1, 0
*-----------------------------------------------------
BIT210      CLR.L   D5
            MOVE.W  D4, D5
            LSL.W   #8, D5      *Drop first 8 bits
            LSL.W   #5, D5      *Drop 13th bit
            LSR.W   #8, D5      *Pushes to the right 8
            LSR.W   #5, D5      *Pushes to the right 5 to finalize
            RTS 
            
OPCODE_NOT  JSR     BIT543
            MOVE.B  #$4E,(A1)+  *N
            MOVE.B  #$4F,(A1)+  *O
            MOVE.B  #$54,(A1)+  *T
            JSR     GET_EA

OPCODE_NOP  MOVE.B  #$4E,(A1)+  *N
            MOVE.B  #$4F,(A1)+  *O
            MOVE.B  #$50,(A1)+  *P
            

OPCODE_RTS  MOVE.B  #$52,(A1)+  *R
            MOVE.B  #$54,(A1)+  *T
            MOVE.B  #$53,(A1)+  *S

*-----------------------------------------------------	
*Op-code move size manager - first four bits are 01(B), 11(W), 10(L)	
*-----------------------------------------------------	
MOVESIZE    MOVEM.L D0-D7/A0-A6, -(SP)
            MOVE.B  #$4D,(A1)+  *Move char M	
            MOVE.B  #$4F,(A1)+  *Move char O	
            MOVE.B  #$56,(A1)+  *Move char V	
            MOVE.B  #$45,(A1)+  *Move char E	
            MOVE.B  #$2E,(A1)+  *Move char .	
            	


            CMPI.B  #$01,D5     *If first 4 bits = 0001 - Byte	
            BEQ     IS_0001	
            CMPI.B  #$03,D5     *If first 4 bits = 0011 - Word	
            BEQ     IS_0011	
            CMPI.B  #$02,D5     *If first 4 bits = 0010 - Long	
            BEQ     IS_0010	
            JSR     BIT876	
            MOVE.B  D5, DestRegNum

            LEA     stackPointer, SP    *how to reset our stack pointer 	
            MOVE.L  CurAddr, DestAddr
            
*-----------------------------------------------------
*Jump table for OP-Mode source size code when bits 876 can be B W L
* Works for SUB, AND, and ADD
*-----------------------------------------------------
BWLOPM      
            *000 - 010 = <ea> + Dn -> Dn
            JMP     OM000    *Byte 
            JMP     OM001    *Word 
            JMP     OM010    *Long
            JMP     OM011    *Not a valid OP-Mode code
            *100 - 110 = Dn + <ea> -> <ea>
            JMP     OM100    *Byte
            JMP     OM101    *Word
            JMP     OM110    *Long
            *for word or long addressing mode
            *JMP     876OM111   *Not a valid OP-Mode code
OPMRET      RTS

*-----------------------------------------------------
*OP-Mode when destination is Dn
* Works for SUB, AND, and ADD
*-----------------------------------------------------
OM000   MOVE.B  #$42,(A1)+  *Move char B
        MOVE.B  #$9,(A1)+   *Tab over
        MOVE.B  #8, BitLen
        JSR    OPMRET   

OM001   MOVE.B  #$57,(A1)+  *Move char W
        MOVE.B  #$9,(A1)+   *Tab over
        MOVE.B  #16, BitLen
        JSR    OPMRET

OM010   MOVE.B  #$4C,(A1)+  *Move char L
        MOVE.B  #$9,(A1)+   *Tab over
        MOVE.B  #32, BitLen
        JSR    OPMRET

*-----------------------------------------------------
*Bad OP mode for table
*-----------------------------------------------------
OM011

*-----------------------------------------------------
*OP-Mode when destination is ea, source is Dn
* Works for SUB, AND, and ADD
*-----------------------------------------------------
OM100   MOVE.B  #$42,(A1)+  *Move char B
        MOVE.B  #$9,(A1)+   *Tab over
        MOVE.B  #8, BitLen
        JSR    OPMRET


OM101   MOVE.B  #$57,(A1)+  *Move char W
        MOVE.B  #$9,(A1)+   *Tab over
        MOVE.B  #16, BitLen
        JSR    OPMRET


OM110   MOVE.B  #$4C,(A1)+  *Move char L
        MOVE.B  #$9,(A1)+   *Tab over
        MOVE.B  #32, BitLen
        JSR    OPMRET
        
*-----------------------------------------------------
*Loads Dn and Dn reg num
*-----------------------------------------------------
DNOUT       MOVE.B  #$44, (A1)+     *Load char D
            CLR.L   D5
            MOVE.B  DnRegNum, D5    *move register value into D5
            ADDI.B  #$30,D5         *Convert number to string
            MOVE.B  D5, (A1)+       *Load register value to output
            RTS


GET_WORD_ADDRESS    MOVE.B  (A2)+,D6    *Move the address to D6 to convert to string
                    LSL.L   #$4,D6
                    MOVE.B  (A2)+,D6
                    JSR     TO_ASCII_WORD    *Convert to string
                    RTS

GET_LONG_ADDRESS    MOVE.B  (A2)+,D6    *Move the address to D6 to convert to string
                    LSL.L   #$4,D6
                    MOVE.B  (A2)+,D6
                    LSL.L   #$4,D6
                    MOVE.B  (A2)+,D6    *Move the address to D6 to convert to string
                    LSL.L   #$4,D6
                    MOVE.B  (A2)+,D6
                    LSL.L   #$4,D6
                    JSR     TO_ASCII_LONG    *Convert to string
                    
GET_IMMEDIATE       

TO_ASCII_WORD            MOVE.W     D6,D7
                         LSR.W      #$8,D7
                         LSR.W      #$4,D7  *Get the first bit/byte
                         CMPI.B     #$9,D7
                         BGT        ASCII_LETTER
                         ADDI.B     #$30,D7
                         MOVE.B     D7,(A1)+
                         MOVE.W     D6,D7
                         LSR.W      #$8,D7  *Get the second bit/byte
                         LSL.B      #$4,D7
                         LSR.B      #$4,D7
                         CMPI.B     #$9,D7
                         BGT        ASCII_LETTER
                         ADDI.B     #$30,D7
                         MOVE.B     D7,(A1)+
                         MOVE.W     D6,D7
                         LSR.W      #$4,D7  *Get the third bit/byte
                         LSL.W      #$8,D7
                         LSL.W      #$4,D7
                         LSR.W      #$8,D7
                         LSR.B      #$4,D7
                         CMPI.B     #$9,D7
                         BGT        ASCII_LETTER
                         ADDI.B     #$30,D7
                         MOVE.B     D7,(A1)+
                         LSL.W      #$8,D7  *Get the last bit/byte
                         LSL.W      #$4,D7
                         LSR.W      #$8,D7
                         LSR.B      #$4,D7
                         CMPI.B     #$9,D7
                         BGT        ASCII_LETTER
                         ADDI.B     #$30,D7
                         MOVE.B     D7,(A1)+
                         RTS
                         
TO_ASCII_LONG            MOVE.L     D6,D7
                         LSR.W      #$8,D7
                         LSR.W      #$4,D7  *Get the first bit/byte
                         CMPI.B     #$9,D7
                         BGT        ASCII_LETTER
                         ADDI.B     #$30,D7
                         MOVE.B     D7,(A1)+
                         MOVE.W     D6,D7
                         LSR.W      #$8,D7  *Get the second bit/byte
                         LSL.B      #$4,D7
                         LSR.B      #$4,D7
                         CMPI.B     #$9,D7
                         BGT        ASCII_LETTER
                         ADDI.B     #$30,D7
                         MOVE.B     D7,(A1)+
                         MOVE.W     D6,D7
                         LSR.W      #$4,D7  *Get the third bit/byte
                         LSL.W      #$8,D7
                         LSL.W      #$4,D7
                         LSR.W      #$8,D7
                         LSR.B      #$4,D7
                         CMPI.B     #$9,D7
                         BGT        ASCII_LETTER
                         ADDI.B     #$30,D7
                         MOVE.B     D7,(A1)+
                         LSL.W      #$8,D7  *Get the last bit/byte
                         LSL.W      #$4,D7
                         LSR.W      #$8,D7
                         LSR.B      #$4,D7
                         CMPI.B     #$9,D7
                         BGT        ASCII_LETTER
                         ADDI.B     #$30,D7
                         MOVE.B     D7,(A1)+
                         RTS
                         
ASCII_LETTER                                       

    SIMHALT             ; halt simulator

* Put variables and constants here
PromptMess1 DC.B    'Please enter an even starting address in hexadecimal format:',0
PromptMess2 DC.B    'Please enter an even ending address in hexadicimal format:',0
InvalidMess DC.B    'Error! The entered address is invalid!',0
ErrorMess   DC.B    'Error! Invalid input!',0
EnterMess   DC.B    'Press enter to continue',0

OutPut      DS.L    1
OpSize      DS.B    1
DnRegNum    DS.B    1
EAMode      DS.B    1
EARegNum    DS.B    1
BitLen      DS.B    1
DestRegNum  DS.B    1
CurVal      DS.L    1
DestAddr    DS.L    1
InstructL   DS.B    1   *This holds the length of how many bits current instruction holds
InstructSeg DS.B    1   *This holds the size of the first segment of bits to read from instruction

*Variables used for counters
CurrentAddress DS.L 1   *This holds the current address of the instruction being read
StartAddr      DC.L    $500 *Holds the start address of the input file
EndAddr        DC.L    $510 *Stores the ending addres of the input file

*END of Program Message
EndOfFileMess   DC.B     'Would you like to disassemble file again? [y/n]',0


    END    START        ; last line of source












*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
