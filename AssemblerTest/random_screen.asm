;This routine places a character randomly on the screen 
;and makes sure that the defined character is not already present 
;in that randomly determined screen position
;The routine runs a predetermined number of times
;
;*** Variablen
SCREEN = $04E0 ; screen position
SCREENZEROADR   = $fb; Zero page addr. for start of screen ram
CHAR    = $18           ;X char
CHROUT  = $FFD2 ; kernal table for Write byte to default output.
LOOPCOUNTER = $6fff     ; loop counter address
RANDOMNUMBER = $D41B ; SID random number
 
;*** start adress 
*=$7000 ; => 28672 

  jsr init
  jsr loop
  rts

init:
  jsr initRandomSID
;  jsr loopcounter
  rts

initRandomSID ;=> 28683
;Random noise with SID
         LDA #$FF  ; maximum frequency value
         STA $D40E ; voice 3 frequency low byte
         STA $D40F ; voice 3 frequency high byte
         LDA #$80  ; noise waveform, gate bit off
         STA $D412 ; voice 3 control register
         RTS

;loopcounter
         ;loop counter (POKED in basic to $6fff => 28671) 
;         LDA #20
;         STA LOOPCOUNTER
;         RTS
                                            
loop     ;=>28697                        
         LDX LOOPCOUNTER ; loop counter
screenpos         
         JSR rndpos
         DEX
         BNE screenpos
         RTS

;****sub routine determine random screen position
rndpos        
        CLC
        LDA #<SCREEN ;load screen ram in zero page into a - low byte
        ADC RANDOMNUMBER
        STA SCREENZEROADR
        LDA #>SCREEN ;
        STA SCREENZEROADR+1
        BCC carryzero
        INC SCREENZEROADR+1     
carryzero                
        CLC
        LDA SCREENZEROADR
        ADC RANDOMNUMBER
        STA SCREENZEROADR
        BCC carryzero2
        INC SCREENZEROADR+1
carryzero2
        CLC
        LDA SCREENZEROADR
        ADC RANDOMNUMBER
        STA SCREENZEROADR
        BCC carryzero3
        INC SCREENZEROADR+1
carryzero3                
        LDY #$0
        LDA (SCREENZEROADR),y
        CMP #CHAR ;compare a with CHAR
        BEQ rndpos;
        LDA #CHAR ; load char
        STA (SCREENZEROADR),y ; Print to screen if not equal        
        RTS