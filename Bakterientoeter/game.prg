

 �"�" 6 PL�1529:PC�81:SP�96:BA�5:SC�0:LO�0:LV�1 ? �250 W( � ****MAIN LOOP**** x2 �"SCORE: ";SC;" LEVEL: ";LV �< � ****PLAYER POSITION**** �F ��(PL)�24�SC�SC�10:LO�LO�1 �P �PL�2023�PL�PL�40 �Z �PL�1024�PL�PL�40 �d �PL,PC 		n � ****JOYSTICK INPUT**** .	x LE�123:��(56320)�LE��290:PL�PL�1 S	� RE�119:��(56320)�RE��290:PL�PL�1 y	� UP�126:��(56320)�UP��290:PL�PL�40 �	� DO�125:��(56320)�DO��290:PL�PL�40 �	� � *****CHECK FOR NEW BACTERIA**** �	� RN�LV�5:��(�(1)�(100�RN))�5��310 �	� � CHECK END 
� �LO�BA�35��340 #
� � CHECK NEW LEVEL 2
� �LO�0��350 J
� � ****MAIN LOOP**** R
� �50 {
� � ****INITIAL BACTERIA POSITIONS**** �
� � FOR I = 0 TO BA �
� POKE 1024+INT(RND(1)*40)+INT(RND(1)*25)*40,24:LO=LO+1 �
� NEXT I �
�N�7000�7017 �
�W:�N,W:�N 8�169,24,141,20,4,141,83,7,141,84,7,141,187,6,141,109,5,96 JLO�LO�5:�7000 P� s"�****CLEAR PLAYER POSITION**** �,�PL,SP:� �6�****SPAWN BACTERIA**** �@�1024��(�(1)�40)��(�(1)�25)�40,24:LO�LO�1 �J� �T�"THERE ARE TOO MANY BACTERIA! ARGH!":� ^�****NEW LEVEL**** h�"�" 7rLV�LV�1:BA�BA�5:�274:�   