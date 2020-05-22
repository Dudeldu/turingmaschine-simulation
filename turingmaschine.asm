; Define constants
STATE_POINTER EQU R0
TAPE_POINTER EQU DPTR

; Load state table
    MOV R0, #30h ; Current memory pointer
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
    MOV DPTR, #0h
clear_tape:
    MOV A, #0h
    MOVX @DPTR, A
    INC DPTR
    MOV A, DPH
    ANL A, DPL
    ANL A, #11111111b
    INC A
    JNZ clear_tape
    
    ; Set initial state to 0
    MOV STATE_POINTER, #0h
    ; Set initial tape pointer to 0
    MOV TAPE_POINTER, #00000h
    ; Set external memory to 0
simulate:
    ;
    ; Calculate new state address
    ; Load character from tape into A
    MOVX A, @DPTR
    ; Add current state to A
    ADD A, STATE_POINTER
    ; Add offset and load cell
    ADD A, #08h
    MOV STATE_POINTER, A
    MOV A, @R0
    ; A contains state-change-info
    MOV R2, A ;temporarilty store A in R2
    ;
    ; Write byte to tape
    ;
    ANL A, #01100000b
    RRC A
    RRC A
    RRC A
    RRC A
    RRC A

    MOVX @DPTR, A

    MOV A, R2 ; Restore A from R2

; L/R -> Increment/descrement tape pointer
    ANL A, #10000000b
    DEC DPL
    MOV R3, DPL
    CJNE R3, #0ffh, skip_underflow
    DEC DPH
skip_underflow:
    JNZ skip_increment
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
    jmp end

end:
END

