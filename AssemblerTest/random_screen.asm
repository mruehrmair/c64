;This routine places a character randomly on the screen 
;and makes sure that the defined character is not already present 
;in that randomly determined screen position
;The routine runs a predetermined number of times
;
;*** Variablen
;SCREENMIN  = #$0428         ;Start position of the screen value
;SCREENMAX  = #$07E7         ;End position of the screen value
SCREEN = $0428 ; screen position
SCREENZEROADR   = $fb; Zero page addr. for start of screen ram
CHAR    = $18           ;X char
CHROUT  = $FFD2 ; kernal table for Write byte to default output.
LOOPCOUNTER = 5     ; loop counter value
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
;X:Min screen
;Y:Max screen
;Output: Y random screen pos between min and max
rndpos
;        LDA #<SCREENRAM ;screen ram in zero page
;        STA SCREENZEROADR
;        ADC $D41B ; add random number
;        CMP SCREENMAX
        
;        LDX SCREEN,y ; load value from randomly determined address into x
;        CPX #CHAR ;compare x with CHAR
;        BEQ loop; if equal try again
        LDY RANDOMNUMBER;
        LDA SCREEN,y ; load value from randomly determined address into x
        CMP #CHAR ;compare a with CHAR
        BEQ rndpos; if equal try again
        LDA #CHAR ; load char
        STA SCREEN,y ; Print to screen if not equal
        
        RTS
        
          