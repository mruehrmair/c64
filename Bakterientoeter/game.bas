10 PRINT""
20 PL%=1529:PC%=81:SP%=96
30 REM ****PLAYER POSITION****
40 IFPL%>2023THENPL%=PL%-40
50 IFPL%<1024THENPL%=PL%+40
60 POKEPL%,PC%
70 REM ****BACTERIA POSITION****
80 POKE1314,24
90 POKE1894,24
100 POKE1124,24
110 REM GENERATE 6 RND POSITIONS
120 REM STORE THEM IN AN ARRAY
130 REM LOOP AND POKE THEM
140 REM CHECK IF PL IS EQUAL TO ONE OF THEM
150 REM IF YES CLEAR THAT BACTERIA
160 REM ****JOYSTICK INPUT****
170 LE%=123:IFPEEK(56320)=LE%THENGOSUB240:PL%=PL%-1
180 RE%=119:IFPEEK(56320)=RE%THENGOSUB240:PL%=PL%+1
190 UP%=126:IFPEEK(56320)=UP%THENGOSUB240:PL%=PL%-40
200 DO%=125:IFPEEK(56320)=DO%THENGOSUB240:PL%=PL%+40
210 PRINT"BAKTERIENTOETER";" JOYSTICK PORT2:";PEEK(56320)
220 GOTO30
230 REM****CLEAR PLAYER POSITION****
240 POKEPL%,SP%:RETURN