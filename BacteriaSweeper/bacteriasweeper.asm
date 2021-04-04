  ;Bacteria Sweeper


  ;kernal addresses
  CHROUT  = $FFD2 ; kernal table for Write byte to default output.

  ;zeropage adresses
  JOYSTICKINPUT   = $02 ;0=nothing, 1=fire, 2=up, 4=right, 8=down, 16=left

  ;screen and color addresses
  BGCOLOR = $D021 ;
  BORDERCOLOR = $D020 ;
  CHRCOLOR = $0286 ;
  HSSCREEN = $0408 ;

  ;joystick addresses 
  CIAPRA = $DC00     ;joystick port 2
  JOYSMR = %00001000​;joystik mask right 
  JOYSML = %00000100​;joystick mask left 
  JOYSMU = %00000001​;joystick mask up 
  JOYSMD = %00000010​;joystick mask down 
  JOYSMB = %00010000​;joystick mask button
  
  ;data addresses
  TITLEMESSAGE = $2000
  HIGHSCORELB = $208B
  HIGHSCOREHB = $208C
  SCORELB = $208D
  SCOREHB = $208E
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
  
  readJoystick
    ;Load in y register
    LDY #0
    STY JOYSTICKINPUT ;Store input in zero page
    RTS
  
  setHighscore
    ;IFSC>HSTHEN HS=SC:SC=0
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
    JSR readJoystick
    RTS 
    
  * = $2000
  !byte $20,$3A,$59,$41,$44,$20,$45,$48,$54,$20,$46,$4F,$20,$45,$52,$4F,$43,$53,$48,$47,$49,$48
  !byte $9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D
  !byte $9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$11,$11,$11,$59,$41,$4C,$50,$20,$4F,$54,$20
  !byte $29,$32,$54,$52,$4F,$50,$20,$4B,$43,$49,$54,$53,$59,$4F,$4A,$28,$20,$45,$52,$49,$46
  !byte $20,$53,$53,$45,$52,$50,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D
  !byte $9D,$11,$11,$11,$52,$45,$50,$45,$45,$57,$53,$20,$41,$49,$52,$45,$54,$43,$41,$42,$11
  !byte $11,$11,$11,$11,$11,$11,$1D,$0 ;Title screen text
  !byte $0,$0  ;Highscore
  !byte $0,$0  ;Score