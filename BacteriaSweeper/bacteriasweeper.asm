  ;Bacteria Sweeper
    
  ;game settings
  GAMESPEED = 18; 1 is fastest n is slower
  BACTERIACOUNTER = $2093 ;adress where the number of enemies to be spawned is found
  BACTERIACOUNTERTEMP = $20F3; temp storage for number of bacteria
  LEVEL = $2094
  BACTERIAINLEVEL = $2097
  BACTERIAINCREASE = 1; Bacteria spawn increase per level
  TIMELIMIT = $20 ; Time limit in seconds 20 using BCD to calculate timer
  MAXIMUMBACTERIA = $1E ;Maximum number of enemies allowed in level (30 decimal)
  INITIALPLAYERPOS1 = $F9; initial player pos lsb (screen memory)
  INITIALPLAYERPOS2 = $05; intial player pos msb (screen memory)
 
  ;kernal and system addresses 
  CHROUT  = $FFD2 ; kernal table for Write byte to default output.
  SETTIM = $FFDB ; kernal table set timer
  RDTIM = $FFDE ; kernal table rd timer
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
  LEVELSCREEN = $0415; Screen RAM address of Level in status bar
  TIMERSCREEN = $0422; Screen RAM address of Time in status bar
  PLAYERPOS = $2091; Address of player starting position on screen
  SCREENSTART = $0400 ; Beginning of message SCORE:
  SCREENLEVEL = $040D ; Beginning of message LEVEL:
  SCREENSPAWNPOS = $04E0 ; Screen RAM address where spawning starts 
  SCREENTIMER = $041C; Beginning of message TIME:
  SCREENGAMEOVER =$042A; Beginning of message Game Over
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
  STATUSBARMESSAGE = $2098
  LEVELMESSAGE = $209F
  TIMERMESSAGE = $20A7
  GAMEOVERMESSAGE1 = $20B1
  GAMEOVERMESSAGE2 = $20D0
  HIGHSCOREB1 = $208B
  HIGHSCOREB2 = $208C
  HIGHSCOREB3 = $208D
  SCOREB1 = $208E
  SCOREB2 = $208F
  SCOREB3 = $2090
  TIMER = $20AD
  TIMERSECONDS = $20B0
  
  ;startup address
    * = $0801
  ;create BASIC startup (SYS line)
    !basic
    
   * = $080D
    JSR init
   title 
    JSR titleScreen
    JSR prepareGame
    JSR gameLoop
  
  init:
    JSR initRandomSID
    JSR setColors
    ;  jsr loopcounter
    RTS
  
  prepareGame
    JSR initPlayer
    JSR resetTimer
    JSR nextLevel
    RTS
  
  initPlayer
    LDA #INITIALPLAYERPOS1 ; LSB
    STA SCREENPLAYERZEROA
    STA PLAYERPOS
    LDA #INITIALPLAYERPOS2 ; MSB
    STA SCREENPLAYERZEROA+1
    STA PLAYERPOS+1
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
    JSR checkSpawn  
    JSR checkTimer    
    JSR checkNextLevel
    JMP checkGameOver   
    
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
    JSR resetScore
    RTS
   @cmpScore2 
    LDA SCOREB2  ;load score 
    CMP HIGHSCOREB2 ;compare score with highscore (highscore - score)
    BEQ @cmpScore1
    BCS @copyScore    
    JSR resetScore
    RTS 
   @cmpScore1 
    LDA SCOREB1  ;load score lsb
    CMP HIGHSCOREB1 ;compare score lsb with highscore (highscore - score)
    BCS @copyScore
    JSR resetScore
    RTS     
   @copyScore
    LDA SCOREB1
    STA HIGHSCOREB1
    LDA SCOREB2
    STA HIGHSCOREB2
    LDA SCOREB3
    STA HIGHSCOREB3
    JSR resetScore
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
  
  printLevel    
    LDY #5
    LDX #0
    @sloop1
      LDA LEVEL,x
      PHA
      AND #$0F
      JSR plotDigitLevel
      PLA
      LSR
      LSR
      LSR
      LSR
      JSR plotDigitLevel   
      INX
      CPX #3
      BNE @sloop1
    RTS  
   
   printTimer   
    LDY #2
    LDA TIMERSECONDS,x
    PHA
    AND #$0F
    JSR plotTimerDigit
    PLA
    LSR
    LSR
    LSR
    LSR
    JSR plotTimerDigit               
    RTS
  
  plotTimerDigit
    CLC
    ADC #48 ; add $30 on petscii table
    STA TIMERSCREEN,y
    DEY
    RTS
    
  plotDigitS
     CLC
     ADC #48 ; add $30 on petscii table
     STA SCORESCREEN,y
     DEY
     RTS
  
  plotDigitLevel
     CLC
     ADC #48 ; add $30 on petscii table
     STA LEVELSCREEN,y
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
   
   incrementScore
     DEC BACTERIAINLEVEL ; decrease number of active bacteria
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
  
   checkSpawn
    ;chance of spawn increases with each level 
    ; load level to y
    LDY BACTERIACOUNTER 
    DEY
    DEY
    DEY
    CPY RANDOMNUMBER
    BCS @spawnSingle
    RTS
    @spawnSingle
    ;temp storage current bacteria counter
    LDA BACTERIACOUNTER
    STA BACTERIACOUNTERTEMP
    LDA #1
    STA BACTERIACOUNTER
    JSR spawnBacteria
    ;restore original bacteria counter
    LDA BACTERIACOUNTERTEMP
    STA BACTERIACOUNTER   
    RTS
    
   spawnBacteria                        
    LDX BACTERIACOUNTER ; loop counter
    screenpos         
    INC BACTERIAINLEVEL ; increase number of active bacteria
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
     
   nextLevel
    JSR clearScreen
    ; level +1
    SED ;Set to binary coded decimal
    CLC
    LDA LEVEL
    ADC #1
    STA LEVEL
    CLD
    ;set number of bacteria to be spawned
    LDA BACTERIACOUNTER
    ADC #BACTERIAINCREASE
    STA BACTERIACOUNTER
    ;reset number of active bacteria
    LDA #0
    STA BACTERIAINLEVEL
    JSR spawnBacteria
    JSR resetTimeSeconds
    RTS
   
   checkNextLevel
    LDA BACTERIAINLEVEL
    BEQ nextLevel
    RTS 
  
   checkTimer
    ;check if one second has passed, decrease timer by one
    ;Read time
    JSR readTime     
    LDA TIMER+2; lsb
    CMP #$3C ;one second 60 jiffys
    BCS @decrementTimer ; 
    RTS
   
    @decrementTimer
    SED ;Set to binary coded decimal
    LDA TIMERSECONDS
    SBC #1
    STA TIMERSECONDS
    CLD
    JSR resetTimer
    RTS
       
   readTime
    JSR RDTIM
    STY TIMER
    STX TIMER+1
    STA TIMER+2
    RTS
    
   resetTimer
    ;reset time from clock to 0
    LDA #0 ; MOST SIGNIFICANT
    LDX #0
    LDY #0; LEAST SIGNIFICANT
    JSR SETTIM
    RTS
   
   resetTimeSeconds
    ;reset the timer counting down per second
    LDA #TIMELIMIT ; 
    STA TIMERSECONDS
    RTS
   
   checkGameOver
    LDA TIMERSECONDS
    BEQ gameOverTime
    LDA #MAXIMUMBACTERIA
    CMP BACTERIAINLEVEL
    BCC gameOverMax
    JMP gameLoop
   
   gameOver 
    JSR wait4Seconds
    JSR resetGame
    JMP title
   
   gameOverTime
    JSR gameOverMessage
    JMP gameOver
   gameOverMax
    JSR gameOverMessageMax
    JMP gameOver
     
   resetGame
    ;reset LEVEL
    JSR initPlayer
    LDA #0
    STA LEVEL
    STA LEVEL+1
    STA LEVEL+2
    ;reset bacteria
    LDA #03
    STA BACTERIACOUNTER
    LDA #0
    STA BACTERIAINLEVEL
    RTS
   
   resetScore
    ;reset Score
    LDA #0
    STA SCOREB1
    STA SCOREB2
    STA SCOREB3
    RTS
    
   gameOverMessage
     LDX #$1E      ; initialize x to message length
      @GETCHARGO
        LDA GAMEOVERMESSAGE1,X     ; grab byte
        STA SCREENGAMEOVER,X       ; render text to screen
        DEX             ; decrement X
        BNE @GETCHARGO     ; loop until X goes negative        
    RTS
   
   gameOverMessageMax
     LDX #$22      ; initialize x to message length
      @GETCHARGO2
        LDA GAMEOVERMESSAGE2,X     ; grab byte
        STA SCREENGAMEOVER,X       ; render text to screen
        DEX             ; decrement X
        BNE @GETCHARGO2     ; loop until X goes negative        
    RTS 
    
   wait4Seconds
    JSR resetTimer
    @timer
    JSR readTime    
    LDA TIMER+2; lsb
    CMP #$F0 ;one second 60 jiffys, 4 seconds 240
    BCC @timer ; branch on carry clear
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
     LDX #$07       ; initialize x to message length
      @GETCHAR1
        LDA LEVELMESSAGE,X     ; grab byte
        STA SCREENLEVEL,X       ; render text to screen
        DEX             ; decrement X
        BNE @GETCHAR1     ; loop until X goes negative 
      JSR printLevel
      LDX #$05       ; initialize x to message length
      @GETCHAR2
        LDA TIMERMESSAGE,X     ; grab byte
        STA SCREENTIMER,X       ; render text to screen
        DEX             ; decrement X
        BNE @GETCHAR2     ; loop until X goes negative 
       JSR printTimer
    RTS
    
  * = $2000
  !byte $20,$3A,$59,$41,$44,$20,$45,$48,$54,$20,$46,$4F,$20,$45,$52,$4F,$43,$53,$48,$47,$49,$48
  !byte $9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D
  !byte $9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$11,$11,$11,$59,$41,$4C,$50,$20,$4F,$54,$20
  !byte $29,$32,$54,$52,$4F,$50,$20,$4B,$43,$49,$54,$53,$59,$4F,$4A,$28,$20,$45,$52,$49,$46
  !byte $20,$53,$53,$45,$52,$50,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D,$9D
  !byte $9D,$11,$11,$11,$52,$45,$50,$45,$45,$57,$53,$20,$41,$49,$52,$45,$54,$43,$41,$42,$11
  !byte $11,$11,$11,$11,$11,$11,$1D,$0 ;Title screen text
  !byte $00,$00,$00  ;Highscore
  !byte $00,$00,$00  ;Score
  !byte $00,$00 ; Player position
  !byte $03; number of bacteria to be spawned
  !byte $0,$0,$0;level
  !byte $0; current number of bacteria in level
  !byte $0,$13,$03,$0F,$12,$05,$3A     ; Status bar message SCORE:
  !byte $0,$20,$0C,$05,$16,$05,$0C,$3A ; Status bar message LEVEL:
  !byte $0,$14,$09,$0D,$05,$3A         ; Status bar message TIME:
  !byte $00,$00,$00; TIMER in jiffys
  !byte $20 ; Timer in seconds
  !byte $0,$14,$09,$0D,$05,$20,$09,$13,$20,$15,$10,$2C,$20,$19,$0F,$15,$20,$17,$05,$12,$05,$20,$14,$0F,$0F,$20,$13,$0C,$0F,$17,$21  ; Game over message TIME IS UP, YOU WERE TOO SLOW!
  !byte $0,$14,$08,$05,$12,$05,$20,$01,$12,$05,$20,$14,$F,$F,$20,$D,$01,$E,$19,$20,$02,$01,$03,$14,$05,$12,$09,$01,$21,$20,$01,$12,$07,$08,$21 ;Game over message THERE ARE TOO MANY BACTERIA! ARGH!
  !byte $0;temporary storage for number of bacteria to be spawned