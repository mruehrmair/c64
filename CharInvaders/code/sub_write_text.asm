;============================================================
; sets character pointer to our new custom set, turn off 
; multicolor for characters, then output three lines of text
;============================================================

write_text 

loop_text  lda line1,x      ; read characters from line1 table of text...
           sta $0428,x      ; ...and store in screen ram near the center
           inx 
           cpx #$28         ; finished when all 40 cols of a line are processed
           bne loop_text
           rts