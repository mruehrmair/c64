  !cpu 6502
  
  ;joystick addresses 
  CIAPRA = $DC00     ;joystick port 2
  
  ;startup address SYS 49152
  * = $C000
 
  LDA #$93  
  JSR $FFD2              ; clear screen
  
  LDA #$01                ; White
  STA $d021               ; Border
  STA $d020               ; Background
  
readjoystick 
  LDA CIAPRA              ;** Read port 2
  AND #$1
  BEQ joystickmoveup        
  JMP readjoystick 
  
joystickmoveup
  LDA #$00                ; Black
  STA $d021               ; Border
  STA $d020               ; Background
  RTS