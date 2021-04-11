  ;Bacteria Sweeper
    
  ;game settings
  GAMESPEED = 10; 1 is fastest n is slower
  BACTERIACOUNTER = $2093 ;adress where the number of enemies to be spawned is found
  LEVEL = $2094
  BACTERIAINCREASE = 2; Bacteria spawn increase per level
  
  ;kernal and system addresses 
  CHROUT  = $FFD2 ; kernal table for Write byte to default output.
  RANDOMNUMBER = $D41B ; SID random number
  
  ;zeropage adresses
  JOYSTICKINPUT      = $02 ;0=nothing, 1=fire, 2=up, 4=right, 8=down, 16=left, 32 = down right, 64 = down left, 128 = up right, 255 = up left
  SCREENSPAWNZEROA   = $fb ; Zero page addr. to store random spawning position ($fb,$fc)
  SCREENPLAYERZEROA  = $fd ; Zero page addr. to store player position ($fd,$fe)
  
  ;characters
  PLAYERCHAR = $51
  XCHAR = $18
  SPACECHAR = $20
  
  ;screen and color addresses
  BGCOLOR = $D021 ;
  BORDERCOLOR = $D020 ;
  CHRCOLOR = $0286 ;
  HSSCREEN = $061F ;
  SCORESCREEN = $0407; Screen RAM address of Score in status bar
  PLAYERPOS = $2091; Address of player starting position on screen
  SCREENSTART = $0400
  SCREENSPAWNPOS = $04E0 ; Screen RAM address where spawning starts 
  RASTER = $D012
  
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
  STATUSBARMESSAGE = $2095
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
    JSR prepareGame
    JSR gameLoop
    RTS
  
  init:
    JSR initRandomSID
    JSR setColors
    ;  jsr loopcounter
    RTS
  
  prepareGame
    JSR initPlayer
    JSR nextLevel
    RTS
  
  initPlayer
    LDA PLAYERPOS ; LSB
    STA SCREENPLAYERZEROA
    LDA PLAYERPOS+1 ; MSB
    STA SCREENPLAYERZEROA+1
    RTS
  
  gameLoop    
    JSR printStatusBar
    JSR readJoystick       
    JSR clearPlayer ; clear previous position
    JSR savePlayer ; save player position before movement 
    JSR movePlayer ; adjust zero page values according to joystick movement    
    JSR checkScreenMinAddress
    JSR checkScreenMaxAddress
    JSR checkIncrementScore 
    JSR drawPlayer ; draw new position
    LDX #GAMESPEED
    @waitLoop      
      JSR waitForRaster
      DEX
      BNE @waitLoop    
    JMP gameLoop
    
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
    LDA CIAPRA        ;** Read port 2
    AND #JOYSMUR
    BEQ @joyUpRight
    LDA CIAPRA        ;** Read port 2
    AND #JOYSMUL
    BEQ @joyUpLeft
    LDA CIAPRA        ;** Read port 2
    AND #JOYSMDL
    BEQ @joyDownLeft
    LDA CIAPRA        ;** Read port 2
    AND #JOYSMDR
    BEQ @joyDownRight
    LDA CIAPRA        ;** Read port 2
    AND #JOYSMB
    BEQ @joyFire
    LDA CIAPRA        ;** Read port 2
    AND #JOYSMR
    BEQ @joyRight
    LDA CIAPRA        ;** Read port 2
    AND #JOYSMU
    BEQ @joyUp
    LDA CIAPRA        ;** Read port 2
    AND #JOYSML
    BEQ @joyLeft
    LDA CIAPRA        ;** Read port 2
    AND #JOYSMD
    BEQ @joyDown
    RTS
    
   @joyFire
    LDY #1
    STY JOYSTICKINPUT
    RTS
   @joyRight
    LDY #4
    STY JOYSTICKINPUT
    RTS
   @joyUp
    LDY #2
    STY JOYSTICKINPUT
    RTS
   @joyLeft
    LDY #16
    STY JOYSTICKINPUT
    RTS   
   @joyDown
    LDY #8
    STY JOYSTICKINPUT
    RTS
   @joyUpRight
    LDY #128
    STY JOYSTICKINPUT
    RTS
   @joyUpLeft
    LDY #255
    STY JOYSTICKINPUT
    RTS
   @joyDownRight
    LDY #32
    STY JOYSTICKINPUT
    RTS
   @joyDownLeft
    LDY #64
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
    
  printScore    
    LDY #5
    LDX #0
    @sloop
      LDA SCOREB1,x
      PHA
      AND #$0F
      JSR plotDigitS
      PLA
      LSR
      LSR
      LSR
      LSR
      JSR plotDigitS
      INX
      CPX #3
      BNE @sloop 
    RTS
    
    
  plotDigitS
     CLC
     ADC #48 ; add $30 on petscii table
     STA SCORESCREEN,y
     DEY
     RTS
     
  plotDigitHS
     CLC
     ADC #48 ; add $30 on petscii table
     STA HSSCREEN,y
     DEY
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
  
  waitForFire
     JSR readJoystick
     LDA #1
     CMP JOYSTICKINPUT
     BEQ @go
     JMP waitForFire
    @go
     RTS
      
  titleScreen
    JSR clearScreen
    JSR setHighscore
    JSR printMessages
    JSR printHighscore
    ;JSR incrementScore ; does not belong here      
    JSR waitForFire
    RTS
    
  waitForRaster
    LDA RASTER
    BNE waitForRaster
    RTS
  
  savePlayer
    LDA SCREENPLAYERZEROA
    STA PLAYERPOS
    LDA SCREENPLAYERZEROA+1
    STA PLAYERPOS+1
    RTS
    
  movePlayer  
    LDA #2
    CMP JOYSTICKINPUT
    BEQ @goUp
    LDA #4
    CMP JOYSTICKINPUT
    BEQ @goRight
    LDA #16
    CMP JOYSTICKINPUT
    BEQ @goLeft
    LDA #8
    CMP JOYSTICKINPUT
    BEQ @goDown   
    LDA #128
    CMP JOYSTICKINPUT
    BEQ @goUpRight
    LDA #255
    CMP JOYSTICKINPUT
    BEQ @goUpLeft
    LDA #32
    CMP JOYSTICKINPUT
    BEQ @goDownRight
    LDA #64
    CMP JOYSTICKINPUT
    BEQ @goDownLeft    
    RTS
   @goUp
    LDA #40; Value 
    PHA
    LDA #1 ; Minus
    PHA
    JMP @move
   @goRight
    LDA #1; Value 
    PHA
    LDA #0 ; Plus
    PHA
    JMP @move
   @goDown
    LDA #40; Value 
    PHA
    LDA #0 ; Plus
    PHA
    JMP @move
   @goLeft
    LDA #1; Value 
    PHA
    LDA #1 ; Minus
    PHA
    JMP @move
   @goUpLeft
    LDA #41; Value 
    PHA
    LDA #1 ; Minus
    PHA
    JMP @move
   @goUpRight
    LDA #39; Value 
    PHA
    LDA #1 ; Minus
    PHA
    JMP @move
   @goDownLeft
    LDA #39; Value 
    PHA
    LDA #0 ; Plus
    PHA
    JMP @move
   @goDownRight
    LDA #41; Value 
    PHA
    LDA #0 ; plus
    PHA
    JMP @move 
   @move
    ; change values in zero page
    PLA
    CMP #1
    BEQ @minusPosition; Minus
    CMP #0
    BEQ @plusPosition
    
  @minusPosition ; A = Value - A
    PLA ;value into a
    EOR #$FF
    SEC
    ADC SCREENPLAYERZEROA
    STA SCREENPLAYERZEROA
    BCC @carrynotset
    RTS
  
  @plusPosition
    CLC
    PLA
    ADC SCREENPLAYERZEROA
    STA SCREENPLAYERZEROA
    BCS @carryset    
    RTS
  
   @carryset
    INC SCREENPLAYERZEROA+1
    RTS
    
  @carrynotset
    DEC SCREENPLAYERZEROA+1
    RTS
    
  clearPlayer
    LDY #$0
    LDA #SPACECHAR ; load char
    STA (SCREENPLAYERZEROA),y ; Print to screen        
    RTS
    
   restorePlayerPosition ;don't draw new position use saved old one
    LDA PLAYERPOS
    STA SCREENPLAYERZEROA
    LDA PLAYERPOS+1
    STA SCREENPLAYERZEROA+1
    RTS
   
   checkIncrementScore
    LDY #$0
    LDA #XCHAR
    CMP (SCREENPLAYERZEROA),y
    BEQ incrementScore
    RTS
    
   drawPlayer
    LDY #$0
    LDA #PLAYERCHAR ; load char 
    STA (SCREENPLAYERZEROA),y ; Print to screen
    RTS
    
   checkScreenMaxAddress
    LDY #$07 ;check screen bottom
    CPY SCREENPLAYERZEROA+1 ; load msb
    BEQ @checkLsb ;is equal to 7 check further
    BMI restorePlayerPosition   ;is more than 7 - not ok
    RTS
    @checkLsb
     CLC
     LDY #$E7
     CPY SCREENPLAYERZEROA
     BCC restorePlayerPosition ;is more than E7 - not ok
    RTS
   
   checkScreenMinAddress
    LDY #$04 ;check screen bottom
    CPY SCREENPLAYERZEROA+1 ; load msb
    BEQ @draw ; is equal to 4 - still ok
    BPL restorePlayerPosition   ;is less than 4 - not ok
    @draw
    RTS
  
   spawnBacteria                        
    LDX BACTERIACOUNTER ; loop counter
    screenpos         
    JSR rndpos
    DEX
    BNE screenpos
    RTS

    ;****sub routine determine random screen position
    rndpos        
    CLC
    LDA #<SCREENSPAWNPOS ;load screen ram in zero page into a - low byte
    ADC RANDOMNUMBER
    STA SCREENSPAWNZEROA
    LDA #>SCREENSPAWNPOS ;
    STA SCREENSPAWNZEROA+1
    BCC carryzero
    INC SCREENSPAWNZEROA+1     
    carryzero                
    CLC
    LDA SCREENSPAWNZEROA
    ADC RANDOMNUMBER
    STA SCREENSPAWNZEROA
    BCC carryzero2
    INC SCREENSPAWNZEROA+1
    carryzero2
    CLC
    LDA SCREENSPAWNZEROA
    ADC RANDOMNUMBER
    STA SCREENSPAWNZEROA
    BCC carryzero3
    INC SCREENSPAWNZEROA+1
    carryzero3                
    LDY #$0
    LDA (SCREENSPAWNZEROA),y
    CMP #XCHAR ;compare a with CHAR
    BEQ rndpos;
    LDA #XCHAR ; load char
    STA (SCREENSPAWNZEROA),y ; Print to screen if not equal        
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
     CLD
     RTS
     
    @carryDecScore2
     CLC
     LDA SCOREB3
     ADC #1
     STA SCOREB3      
     CLD
     RTS   
     
   nextLevel
    JSR clearScreen
    ; level +1
    LDA LEVEL
    ADC #1
    STA LEVEL
    ;set number of bacteria to be spawned
    LDA BACTERIACOUNTER
    ADC #BACTERIAINCREASE
    STA BACTERIACOUNTER 
    JSR spawnBacteria
    RTS
   
   printStatusBar   
    LDX #$06       ; initialize x to message length
      @GETCHAR
        LDA STATUSBARMESSAGE,X     ; grab byte
        STA SCREENSTART,X       ; render text to screen
        DEX             ; decrement X
        BNE @GETCHAR     ; loop until X goes negative
      ;convert 16bit value to decimal
      JSR printScore        
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
  !byte $F9,$05 ; Player position
  !byte $03; number of bacteria to be spawned
  !byte $0;level
  !byte $0,$13,$03,$0F,$12,$05,$3A;Status bar message SCORE: