;This routine places a character randomly on the screen 
;and makes sure that the defined character is not already present 
;in that randomly determined screen position
;The routine runs a predetermined number of times
;
;*** Variablen
;SCREENMIN  = #$0428         ;Start position of the screen value
;SCREENMAX  = #$07E7         ;End position of the screen value
SCREEN = $048C ; screen position
SCREENZEROADR   = $fb; Zero page addr. for start of screen ram
CHAR    = $18           ;X char
CHROUT  = $FFD2 ; kernal table for Write byte to default output.
LOOPCOUNTER = 15     ; loop counter value
RANDOMNUMBER = $D41B ; SID random number
 
;*** start adress 
*=$7000 ; => 28685 

  jsr init
  jsr loop
  rts

init:
  jsr initRandomSID
  jsr clearScreen
  rts

initRandomSID 
;Random noise with SID
         LDA #$FF  ; maximum frequency value
         STA $D40E ; voice 3 frequency low byte
         STA $D40F ; voice 3 frequency high byte
         LDA #$80  ; noise waveform, gate bit off
         STA $D412 ; voice 3 control register
         RTS
         
clearScreen
         LDA #$93
         JSR CHROUT
         RTS
                                   
loop                             
         LDX #LOOPCOUNTER ; loop counter
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
        BCC carryzero   
        INC SCREENZEROADR+1     
carryzero        
        STA SCREENZEROADR+1
        CLC
        LDA SCREENZEROADR
        ADC RANDOMNUMBER
        STA SCREENZEROADR
        BCC carryzero2
        INC SCREENZEROADR+1
carryzero2        
        LDY RANDOMNUMBER
        LDA (SCREENZEROADR),y
        CMP #CHAR ;compare a with CHAR
        BEQ rndpos;
        LDA #CHAR ; load char
        STA (SCREENZEROADR),y ; Print to screen if not equal
        
        ;if BCS then SCREENZEROADR+1 is inc by one
        ;repeat this with 3 random numbers
;        ADC $D41B ; add random number
;        CMP SCREENMAX
        
;        LDX SCREEN,y ; load value from randomly determined address into x
;        CPX #CHAR ;compare x with CHAR
;        BEQ loop; if equal try again
;        LDY RANDOMNUMBER;
;        LDA SCREEN,y ; load value from randomly determined address into x
;        CMP #CHAR ;compare a with CHAR
;        BEQ rndpos; if equal try again
;        LDA #CHAR ; load char
;        STA SCREEN,y ; Print to screen if not equal
        
        RTS
        
          