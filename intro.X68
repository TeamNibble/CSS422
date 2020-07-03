*-----------------------------------------------------------
* Title      :Hello World
* Written by :Jonathan Young
* Date       :6/25/2020
* Description:This is the tutorial Program
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here
        LEA     MESSAGE, A1
        MOVE.B  #14, D0
        TRAP    #15
    
        MOVE.B  #9, D0
        TRAP    #15
    
CR      EQU     $0D
LF      EQU     $0A

MESSAGE DC.B    'WE GET SIGNAL', CR, LF
        DC.B    'MAIN SCREEN TURN ON', CR, LF, CR, LF
        DC.B    'HOW ARE YOU GENTLEMEN', CR, LF
        DC.B    'ALL YOUR BASE ARE BELONG TO US', CR, LF
        DC.B    'YOU ARE ON THE WAY TO DESTRUCTION', CR, LF, CR, LF
        DC.B    'WHAT YOU SAY', CR, LF, CR, LF
        DC.B    'YOU HAVE NO CHANCE TO SURVIVE MAKE YOUR TIME', CR, LF, 0

    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
