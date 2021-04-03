; INCBIN "..\sprite.spr"
;startup address
  * = $0801

  ;create BASIC startup (SYS line)
;  !basic
  
  
  ;increase border color
  REPEAT 2
  inc $d020
  REPEND
  
  ;return to BASIC
  rts
