  ;Bacteria Sweeper


  ;kernal addresses
  CHROUT  = $FFD2 ; kernal table for Write byte to default output.

  ;zeropage adresses
  JOYSTICKINPUT   = $02 ;0=nothing, 1=fire, 2=up, 4=right, 8=down, 16=left

  ;screen and color addresses
  BGCOLOR = $D021 ;
  BORDERCOLOR = $D020 ;
  CHRCOLOR = $0286 ;

  ;joystick addresses 
  CIAPRA = $DC00     ;joystick port 2
  JOYSMR = %00001000​;joystik mask right 
  JOYSML = %00000100​;joystick mask left 
  JOYSMU = %00000001​;joystick mask up 
  JOYSMD = %00000010​;joystick mask down 
  JOYSMB = %00010000​;joystick mask button
  
  ;data addresses
  ;$0801  
  ;  !byte 17
  
    
  ;startup address
    * = $0801
  ;create BASIC startup (SYS line)
    !basic
    
    
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
 
  printMessages
    LDA #$11
    JSR CHROUT  
    LDA #$42
    JSR CHROUT
    RTS 
  ;  LDX #$04        ; initialize x to message length
  ;    GETCHAR
  ;      LDA TITLEMESSAGE,X     ; grab byte
  ;      JSR $FFD2       ; render text in A with Subroutine:CLRCHN
  ;      DEX             ; decrement X
  ;      BPL GETCHAR     ; loop until X goes negative
  ;      RTS
    
  titleScreen
    JSR clearScreen
    ;JSR setHighscore
    JSR printMessages
    JSR readJoystick
    RTS 
    