  ;Bacteria Sweeper


  ;kernal addresses
  CHROUT  = $FFD2 ; kernal table for Write byte to default output.

  ;zeropage adresses
  JOYSTICKINPUT   = $02 ;0=nothing, 1=fire, 2=up, 4=right, 8=down, 16=left, 32 = down right, 64 = down left, 128 = up right, 255 = up left

  ;screen and color addresses
  BGCOLOR = $D021 ;
  BORDERCOLOR = $D020 ;
  CHRCOLOR = $0286 ;
  HSSCREEN = $061F ;

  ;joystick addresses 
  CIAPRA = $DC00     ;joystick port 2
  JOYSMR = %00001000​;joystik mask right 
  JOYSML = %00000100​;joystick mask left 
  JOYSMU = %00000001​;joystick mask up 
  JOYSMD = %00000010​;joystick mask down
  JOYSMUR = %00001001​;joystik mask up right 
  JOYSMUL = %00000101​;joystick mask up left 
  JOYSMDR = %00001010​;joystick mask down right 
  JOYSMDL = %00000110​;joystick mask down left
  JOYSMB = %00010000​;joystick mask button
  
  ;data addresses
  TITLEMESSAGE = $2000
  HIGHSCOREB1 = $208B
  HIGHSCOREB2 = $208C
  HIGHSCOREB3 = $208D
  SCOREB1 = $208E
  SCOREB2 = $208F
  SCOREB3 = $2090
  
  
  ;startup address
    * = $0801
  ;create BASIC startup (SYS line)
    !basic
    
   * = $080D
    JSR init
    JSR titleScreen
    ;JSR gameloop
    RTS
  
  init:
    JSR initRandomSID
    JSR setColors
    ;  jsr loopcounter
    RTS
  
  clearScreen
    LDA #$93
    JSR CHROUT   
    RTS  
  
  setColors
    LDA #0
    STA BGCOLOR
    STA BORDERCOLOR
    LDA #3
    STA CHRCOLOR
    RTS
    
  initRandomSID 
    ;Random noise with SID
    LDA #$FF  ; maximum frequency value
    STA $D40E ; voice 3 frequency low byte
    STA $D40F ; voice 3 frequency high byte
    LDA #$80  ; noise waveform, gate bit off
    STA $D412 ; voice 3 control register
    RTS
  
  readJoystickFire
    ;Load in y register
    LDY #0
    STY JOYSTICKINPUT ;Store input in zero page
    LDA CIAPRA        ;** Read port 2
    AND #JOYSMB
    BEQ @joyFire
    JMP readJoystickFire
   @joyFire
    LDY #1
    STY JOYSTICKINPUT
    RTS
  
  setHighscore
    ;IFSC>HSTHEN HS=SC:SC=0
    ;compare msb
    CLC
    LDA SCOREB3  ;load score msb
    CMP HIGHSCOREB3 ;compare score msb with highscore (highscore - score)
    BEQ @cmpScore2
    BCS @copyScore    
    RTS
   @cmpScore2 
    LDA SCOREB2  ;load score 
    CMP HIGHSCOREB2 ;compare score with highscore (highscore - score)
    BEQ @cmpScore1
    BCS @copyScore    
    RTS 
   @cmpScore1 
    LDA SCOREB1  ;load score lsb
    CMP HIGHSCOREB1 ;compare score lsb with highscore (highscore - score)
    BCS @copyScore
    RTS     
   @copyScore
    LDA SCOREB1
    STA HIGHSCOREB1
    LDA SCOREB2
    STA HIGHSCOREB2
    LDA SCOREB3
    STA HIGHSCOREB3
    RTS
  
  printHighscore    
    LDY #5
    LDX #0
    sloop
      LDA HIGHSCOREB1,x
      PHA
      AND #$0F
      JSR plotDigitHS
      PLA
      LSR
      LSR
      LSR
      LSR
      JSR plotDigitHS
      INX
      CPX #3
      BNE sloop 
    RTS
  
  plotDigitHS
     CLC
     ADC #48 ; add $30 on petscii table
     STA HSSCREEN,y
     DEY
     RTS
  
  incrementScore
     SED ;Set to binary coded decimal
     CLC
     LDA SCOREB1
     ADC #10
     STA SCOREB1
     BCS @carryDecScore
     CLD
     RTS
     
    @carryDecScore
     CLC
     LDA SCOREB2
     ADC #1
     STA SCOREB2
     BCS @carryDecScore2
     RTS
     
    @carryDecScore2
     CLC
     LDA SCOREB3
     ADC #1
     STA SCOREB3 
     RTS
             
  printMessages 
    LDX #$8A       ; initialize x to message length
      GETCHAR
        LDA TITLEMESSAGE,X     ; grab byte
        JSR CHROUT       ; render text in A with Subroutine:CLRCHN
        DEX             ; decrement X
        BNE GETCHAR     ; loop until X goes negative
      ;convert 16bit value to decimal
      ;print HS to clearScreen      
      RTS
    
  titleScreen
    JSR clearScreen
    JSR setHighscore
    JSR printMessages
    JSR printHighscore
    JSR incrementScore    
    JSR readJoystickFire
    RTS 
    
  * = $2000
  !byte $20,$3A,$59,$41,$44,$20,$45,$48,$54,$20,$46,$4F,$20,$45,$52,$4F,$43,$53,$48,$47,$49,$48
  !byte $9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D
  !byte $9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$11,$11,$11,$59,$41,$4C,$50,$20,$4F,$54,$20
  !byte $29,$32,$54,$52,$4F,$50,$20,$4B,$43,$49,$54,$53,$59,$4F,$4A,$28,$20,$45,$52,$49,$46
  !byte $20,$53,$53,$45,$52,$50,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D
  !byte $9D,$11,$11,$11,$52,$45,$50,$45,$45,$57,$53,$20,$41,$49,$52,$45,$54,$43,$41,$42,$11
  !byte $11,$11,$11,$11,$11,$11,$1D,$0 ;Title screen text
  !byte $0,$07,$0  ;Highscore
  !byte $93,$08,$0  ;Score