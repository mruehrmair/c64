;Bacteria Sweeper

CHROUT  = $FFD2 ; kernal table for Write byte to default output.
BGCOLOR = $D021 ;
BORDERCOLOR = $D020 ;
CHARCOLOR = $0286 ;

    ;startup address
    * = $0801

    ;create BASIC startup (SYS line)
    !basic
    
    JSR init
    ;JSR gameloop
    RTS
  
  
  init:
    JSR initRandomSID
    JSR clearScreen
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
    STA CHARCOLOR
    RTS
    
  initRandomSID 
    ;Random noise with SID
    LDA #$FF  ; maximum frequency value
    STA $D40E ; voice 3 frequency low byte
    STA $D40F ; voice 3 frequency high byte
    LDA #$80  ; noise waveform, gate bit off
    STA $D412 ; voice 3 control register
    RTS