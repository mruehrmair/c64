;This routine places a character randomly on the screen 
;and makes sure that the defined character is not already present 
;in that randomly determined screen position
;
;*** Variablen
SCREEN  = $0428         ;Start position of the screen
CHAR    = $18        ;X char
SIDRND  = $D41B ; address where SID generates the random number

;LOOPCOUNTER = $6fff     ; loop counter register
 
;*** Startadresse BASIC-Zeile
*=$7000
;       !byte $0c,$08,$e2,$07,$9e,$20,$32,$30,$36,$32,$00,$00,$00

;Random noise with SID
         LDA #$FF  ; maximum frequency value
         STA $D40E ; voice 3 frequency low byte
         STA $D40F ; voice 3 frequency high byte
         LDA #$80  ; noise waveform, gate bit off
         STA $D412 ; voice 3 control register
         
;loop counter (POKED in basic to #7000 => 28672) 
;         LDA #5
;         STA LOOPCOUNTER 
         
;start of screen population    => 28685     
         
loop             
;load random number into y, load screen start address into x, add y, transfer x to a
;repeat this three times                   
         LDA $D41B
         ADC $D41B         
         STA $6FFF
         LDX $D41B
         STA $6FFF,x
         
         LDX SCREEN,y ; load value from randomly determined address into x
         LDY SIDRND,x ; Load rnd into y          
         LDX SCREEN,y ; load value from randomly determined address into x
         LDY SIDRND,x ; Load rnd into y          
         LDX SCREEN,y ; load value from randomly determined address into x
         CPX #CHAR ;compare x with CHAR
         BEQ loop; if equal try again
         LDA #CHAR ; load char into a
         STA SCREEN,x ; Print char to screen if not equal

;         LDX LOOPCOUNTER ; loop counter
;loop2     
;         LDY $D41B ; Load rnd into y
;         STA SCREENLOWER,y ; Print to screen
;         NOP
;         NOP
;         NOP
;         DEX
;         BNE loop2     
         RTS