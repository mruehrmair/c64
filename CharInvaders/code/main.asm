;===================================
; main.asm triggers all subroutines 
; and runs the Interrupt Routine
;===================================

          jsr clear_screen  ; clear the screen
          jsr write_text    ; write three lines of text

main_loop

          jmp main_loop