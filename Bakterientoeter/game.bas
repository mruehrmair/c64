10 PRINT""
20 PL%=1529:PC%=81:SP%=96:BA%=15:SC=0:LO%=0
30 GOSUB210
40 REM ****MAIN LOOP****
50 PRINT"SCORE: ";SC
60 REM ****PLAYER POSITION****
70 IFPEEK(PL%)=24 THEN SC=SC+10:LO%=LO%-1
80 IFPL%>2023THENPL%=PL%-40
90 IFPL%<1024THENPL%=PL%+40
100 POKEPL%,PC%
110 REM ****JOYSTICK INPUT****
120 LE%=123:IFPEEK(56320)=LE%THENGOSUB250:PL%=PL%-1
130 RE%=119:IFPEEK(56320)=RE%THENGOSUB250:PL%=PL%+1
140 UP%=126:IFPEEK(56320)=UP%THENGOSUB250:PL%=PL%-40
150 DO%=125:IFPEEK(56320)=DO%THENGOSUB250:PL%=PL%+40
160 REM *****CHECK FOR NEW BACTERIA****
170 IF INT(RND(1)*7)=2THENGOSUB270
175 REM CHECK END
176 IF LO% > 50 THEN GOTO320 
180 REM ****MAIN LOOP****
190 GOTO50
200 REM ****BACTERIA POSITIONS****
210 FOR I = 0 TO BA%
220 POKE 1024+INT(RND(1)*40)+INT(RND(1)*25)*40,24:LO%=LO%+1
230 NEXT I
240 RETURN
250 REM****CLEAR PLAYER POSITION****
260 POKEPL%,SP%:RETURN
270 REM****SPAWN BACTERIA****
290 POKE 1024+INT(RND(1)*40)+INT(RND(1)*25)*40,24:LO%=LO%+1
310 RETURN
320 PRINT"THERE ARE TOO MANY BACTERIA! ARGH!": END