;*** Variablen
SCREEN  = $0400         ;Start des Bildschirmspeichers
CHAR    = $41           ;Pik-Zeichen für die Ausgabe
 
;*** Startadresse BASIC-Zeile
*=$0801
        !byte $0c,$08,$e2,$07,$9e,$20,$32,$30,$36,$32,$00,$00,$00
 
;*** Start des Assemblerprogrammes
        lda #CHAR       ;Zeichen in den Akku laden
        ldx #$ff        ;Schleifenanzahl
 
loop
        sta SCREEN-1,x  ;Akku auf dem BS ausgeben
        dex           
        bne loop
        rts