; 10 SYS (2084)
*=$0801
        !BYTE    $0E, $08, $0A, $00, $9E, $20, $28,  $32, $30, $38, $34, $29, $00, $00, $00
*=$0824
;
;  INITALIZATION
;
MAIN            LDA #$20 ; Snake start position
                STA $2000
                LDA #$12
                STA $2001
                LDX #$FF
L4              STA $2100,X
                STA $2200,X
                DEX
                BNE L4
                LDA #$7B
                STA $2002 ; Initial Snake direction
                LDX #$03 ; Initial Snake length
                STX $2003
                LDA #$20
                JSR CLEARSCREEN
                JSR TITLE
                CLC
                CLD
                CLV
                JSR FIRE
                LDA #$20
                JSR CLEARSCREEN
                LDA #$FF  ; maximum frequency value
                STA $D40E ; voice 3 frequency low byte
                STA $D40F ; voice 3 frequency high byte
                LDA #$80  ; noise waveform, gate bit off
                STA $D412 ; voice 3 control register
                JSR PILL
                CLC
                CLD
                CLV
;
;  MAIN LOOP
;
MAINLOOP        JSR GETJOYSTICK
                JSR MOVESNAKE
                JSR DRAWCHR
                JSR PAUSE
                JSR GAMEOVER1
                JSR STOREPOS
                JMP MAINLOOP
;
; Clear screen
;
CLEARSCREEN     LDX #$00
L2              STA $0400,X
                STA $0500,X
                STA $0600,X
                STA $0700,X
                INX
                BNE L2
                RTS
;
;  DRAW NEW SNAKE BLOCK
;
DRAWCHR         LDA #$04
                STA POINTER+2
                STA POINTER2+2
                LDA #$00
                STA POINTER+1
                STA POINTER2+1
                LDY $2001
                LDA #$00
                CPY #$00
                BEQ BACK3
LOOP            CLC
                ADC #$28
                BCS YOVERFLOW1
BACK1           DEY
                BNE LOOP
BACK3           CLC
                ADC $2000
                BCS YOVERFLOW2
BACK2           STA POINTER+1
                STA POINTER2+1
                CLC
POINTER2        LDA $0400
                CMP #$A0 ; Test if Snake eats itself
                BEQ GO3  ; Yes: Game Over!
                CMP #$2A ; Test if Snake eats pill
                BNE CHAR
                INC $2003 ; Yes: Pill eaten, Snake gets longer
                JSR PILL
CHAR            LDA #$A0
POINTER         STA $0400
                RTS
YOVERFLOW1      INC POINTER+2
                INC POINTER2+2
                JMP BACK1
YOVERFLOW2      INC POINTER+2
                INC POINTER2+2
                JMP BACK2
GO3             JMP GAMEOVER
;
;  UNDRAW LAST SNAKE BLOCK
;
UNDRAWCHR       LDA #$04
                STA UNPOINTER+2
                LDA #$00
                STA UNPOINTER+1
                LDX $2003
                CLV
                LDA $2200,X
                CMP #$00
                BEQ GO4
                TAY
                LDA #$00
UNLOOP          CLC
                ADC #$28
                BCS UNYOVERFLOW1
UNBACK1         DEY
                BNE UNLOOP
GO4             CLC
                ADC $2100,X
                BCS UNYOVERFLOW2
UNBACK2         STA UNPOINTER+1
UNCHAR          LDA #$20
UNPOINTER       STA $0400
                RTS
UNYOVERFLOW1    INC UNPOINTER+2
                JMP UNBACK1
UNYOVERFLOW2    INC UNPOINTER+2
                JMP UNBACK2
;
;  GET JOYSTICK MOvEMENT
;
GETJOYSTICK     LDA $DC00
                CMP #$7B
                BEQ STOREDIRECTION
                CMP #$77
                BEQ STOREDIRECTION
                CMP #$7E
                BEQ STOREDIRECTION
                CMP #$7D
                BEQ STOREDIRECTION
                RTS
STOREDIRECTION  STA $2002
                RTS
;
;  MOvE THE SNAKE TO NEW POSITION
;
MOVESNAKE       LDA $2002
                CMP #$7B
                BEQ LEFT
                CMP #$77
                BEQ RIGHT
                CMP #$7E
                BEQ UP
                CMP #$7D
                BEQ DOWN
                RTS
LEFT            DEC $2000
                RTS
RIGHT           INC $2000
                RTS
UP              DEC $2001
                RTS
DOWN            INC $2001
                RTS
;
;  WIPE SNAKE LAST BLOCK, MOvE STORED SNAKE BLOCKS STACK AND ADD NEW HEAD START
;
STOREPOS        JSR UNDRAWCHR
                LDX $2003
                CLC
L3              LDA $20FF,X
                STA $2100,X
                LDA $21FF,X
                STA $2200,X
                DEX
                BNE L3
                LDA $2000
                STA $2100
                LDA $2001
                STA $2200
                RTS
;
; PAUSE TO MAKE THE GAME SLOWER
;
PAUSE           LDY #$40
                LDX #$00
L1              INX
                BNE L1
                DEY
                BNE L1
                CLC
                CLD
                CLV
                RTS
;
;  GAME OVER IF SNAKE HITS THE BORDER
;
GAMEOVER1       LDA $2000
                CLC
                SBC #$27
                BCS GO2
                LDA $2001
                CLC
                SBC #$18
                BCS GO2
                RTS
GO2             JMP GAMEOVER
;
; Random pill
;
PILL            LDA $D41B
                CLC
                CMP #$04
                BCS PILL
                CLC
                CMP #$03
                BCS PILL1
                CLC
                CMP #$02
                BCS PILL2
                CLC
                CMP #01
                BCS PILL3
                LDX $D41B
                LDA $0400,X
                CMP #$20
                BNE PILL
                LDA #$2A
                STA $0400,X
                RTS
PILL1           LDA $0400,X
                CMP #$20
                BNE PILL
                LDX $D41B
                LDA #$2A
                STA $0500,X
                RTS
PILL2           LDA $0400,X
                CMP #$20
                BNE PILL
                LDX $D41B
                LDA #$2A
                STA $0600,X
                RTS
PILL3           LDA $0400,X
                CMP #$20
                BNE PILL
                LDX $D41B
                LDA #$2A
                STA $0700,X
                RTS
;
; SHOW TITLESCREEN
;
TITLE           LDX #$0
CYCLE           LDA TITLETXT,X
                CMP #0
                BEQ EXIT
                STA $0400,X
                INX
                JMP CYCLE
EXIT            RTS
TITLETXT        TEXT '              SNAKE BY VMA'
                BYTE 0
;
; SHOW GAMEOVER SCREEN
;
GAMEOVER        LDX #$0
CYCLE2          LDA GAMEOVERTXT,X
                CMP #0
                BEQ EXIT2
                STA $0400,X
                INX
                JMP CYCLE2
EXIT2           JSR FIRE
                JSR PAUSE
                JMP MAIN
GAMEOVERTXT     TEXT '               GAME OVER!'
                BYTE 0
;
; GET FIRE BUTTON
;
FIRE            LDA $DC00
                CMP #$6F
                BNE FIRE
                RTS