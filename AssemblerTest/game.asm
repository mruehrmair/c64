;*** Variablen
SCREENUPPER  = $0428         ;Start des Bildschirmspeichers
SCREENLOWER  = $0626         ;
CHAR    = $18           ;X char
LOOPCOUNTER = $6fff     ; loop counter register
 
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
         LDA #5
         STA LOOPCOUNTER 
         
;start of screen population    => 28685     
         LDA #CHAR ; load char
         LDX LOOPCOUNTER ; loop counter
loop     
         LDY $D41B ; Load rnd into y
         STA SCREENUPPER,y ; Print to screen
         NOP
         NOP
         NOP
         DEX
         BNE loop
         LDX LOOPCOUNTER ; loop counter
loop2     
         LDY $D41B ; Load rnd into y
         STA SCREENLOWER,y ; Print to screen
         NOP
         NOP
         NOP
         DEX
         BNE loop2     
         rts