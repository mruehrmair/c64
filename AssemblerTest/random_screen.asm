;This routine places a character randomly on the screen 
;and makes sure that the defined character is not already present 
;in that randomly determined screen position
;
;*** Variablen
SCREENMIN  = #$0428         ;Start position of the screen value
SCREENMAX  = #$07E7         ;End position of the screen value
SCREEN = $0428 ; screen position
CHAR    = $18           ;X char
CHROUT  = $FFD2 ; kernal table for Write byte to default output.
;LOOPCOUNTER = $6fff     ; loop counter register
 
;*** Startadresse BASIC-Zeile
*=$7000 ;
;       !byte $0c,$08,$e2,$07,$9e,$20,$32,$30,$36,$32,$00,$00,$00

;Random noise with SID
         LDA #$FF  ; maximum frequency value
         STA $D40E ; voice 3 frequency low byte
         STA $D40F ; voice 3 frequency high byte
         LDA #$80  ; noise waveform, gate bit off
         STA $D412 ; voice 3 control register

;clear screen
         LDA #$93
         JSR CHROUT
         
;loop counter (POKED in basic to #7000 => 28672) 
;         LDA #5
;         STA LOOPCOUNTER 
         
;start of screen population    => 28685     
         LDX SCREENMIN
         LDY SCREENMAX
                  
loop             
         JSR rndpos
         LDX SCREEN,y ; load value from randomly determined address into x
         CPX #CHAR ;compare x with CHAR
         BEQ loop; if equal try again
         LDA #CHAR ; load char
         STA y ; Print to screen if not equal
;         LDX LOOPCOUNTER ; loop counter    
         RTS
;****sub routine determine random screen position
;X:Min screen
;Y:Max screen
;Output: Y random screen pos between min and max
rndpos
        LDA SCREENMIN ; Load screen min into a
        CLC
        ADC $D41B ; add random number
        CMP SCREENMAX
        
        
          