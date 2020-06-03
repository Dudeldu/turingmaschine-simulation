; Define constants
STATE_POINTER EQU R0
TAPE_POINTER EQU DPTR
; Load state table
    MOV R0, #10h ; Current memory pointer
    MOV R1, #50h ; Memory left
main_read:
    MOV A, P0
    CJNE R1, #0h, read
    JMP idle
read:
    MOV @R0, A
    INC R0 ; Next byte
    DEC R1 ; less memory left
    JMP main_read

 

idle:
;    MOV DPTR, #0h
;clear_tape:
;    MOV A, #0h
;    MOVX @DPTR, A
;    INC DPTR
;    MOV A, DPH
;    ANL A, DPL
;    ANL A, #11111111b
;    INC A
;    JNZ clear_tape
    
    ; Set initial state to 0
    MOV STATE_POINTER, #0h
    ; Set initial tape pointer to 0
    MOV TAPE_POINTER, #00000h
    ; Set external memory to 0

    ; init LCD display
    MOV A, #38H
    ACALL COMNWRT

    MOV A, #0EH
    ACALL COMNWRT

    MOV A, #01H
    ACALL COMNWRT

    MOV A, #06H
    ACALL COMNWRT

    MOV A, #80H
    ACALL COMNWRT
simulate:
    ;
    ; Calculate new state address
    ; Load character from tape into A
    MOVX A, @DPTR
    MOV R2, A
    ; Add current state to A
    MOV A, STATE_POINTER
    RL A
    RL A
    ADD A, R2
    ; Add offset and load cell
    ADD A, #10h
    MOV STATE_POINTER, A
    MOV A, @R0
    ; A contains state-change-info
    MOV R2, A ;temporarilty store A in R2
    ;
    ; Write byte to tape
    ;
    ANL A, #01100000b
    RR A
    RR A
    RR A
    RR A
    RR A

    MOVX @DPTR, A

    MOV A, R2 ; Restore A from R2

; L/R -> Increment/descrement tape pointer
    ANL A, #10000000b
    DEC DPL
    MOV R3, DPL
    CJNE R3, #0ffh, skip_underflow
    DEC DPH
skip_underflow:
    JZ skip_increment
    INC DPTR
    INC DPTR
    
skip_increment:
; Write next state into state pointer
    MOV A, R2 ; Restore A from R2
    ANL A, #00011111b
    MOV STATE_POINTER, A
    CJNE A, #00011111b, simulate

write:
    ; output

    MOV R7, #28h
    MOV R1, #10h
    
load_char:
    MOV A, R7
    JZ write_char
    MOVX A, @DPTR
    ADD A, #30h
    MOV @R1, A
    DEC R7
    INC R1
    INC DPTR
    jmp load_char

    
write_char:
    MOV R1, #10h
    MOV R7, #28h
write_char_loop:
    MOV A, R7
    jz end
    MOV A, @R1
    ACALL DATAWRT
    INC R1
    DEC R7
    jmp write_char_loop
    
COMNWRT: 
    ACALL READY
    MOV P1, A
    CLR P2.0
    CLR P2.1
    SETB P2.2
    CLR P2.2
    RET
DATAWRT: 
    ACALL READY
    MOV P1, A
    SETB P2.0
    CLR P2.1
    SETB P2.2
    CLR P2.2

    SETB P2.1
    RET
READY: 
    SETB P1.7
    CLR P2.0
    SETB P2.1
BACK: 
    SETB P2.2
    CLR P2.2
    JB P1.7, Back
    RET
    
end: JMP end
    END

