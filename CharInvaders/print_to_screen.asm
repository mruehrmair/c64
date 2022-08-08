;startup address
  * = $0801

  ;create BASIC startup (SYS line)
  !basic
  
  jsr WriteString
  rts
  
  ;text
  MyText !scr "hello world",0
  
  WriteString
  ldx #0
  
  Loop
  lda MyText,x
  sta $0400,x
  inx
  cpx #11
  bne Loop
  rts
