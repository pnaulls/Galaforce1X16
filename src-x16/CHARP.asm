;;
;; Galaforce 1 ( BBC Micro ) from the original 6502 source code, adapted to assemble using beebasm
;;
;; (c) Kevin Edwards 1986-2019
;;
;; Twitter @KevEdwardsRetro
;;

;; REM SAVE"CHARP"
;; B%=P%
;; [OPT pass

prnstr:
 LDA  strdat,Y
 STA  data
 LDA  strdat+1,Y
 STA  data+1
 LDY  #0
 LDA  (data),Y
 STA  addres
 INY 
 LDA  (data),Y
 STA  addres+1
 INY 
 LDA  (data),Y
 STA  length
 INY 
 LDA  (data),Y
 STA  colour
nxtchr:
 LDA  colour
 AND  #$AA
 STA  pixcolu+1
 INY 

prnchr:
 LDA  (data),Y
 STY  savey
 STA  temp
 ASL A
 ASL A
 ADC  temp
 TAX 
 LDA  #5
 STA  width
pixcolum:
 LDY  #7
 LDA  $700,X
 STA  temp
; Address of character set (spacey)

pixcolu:
 LDA  #0
 ; colour bits
 ASL  temp
 BCC  pixcol0
 EOR  (addres),Y
 STA  (addres),Y
pixcol0:
 DEY 
 BPL  pixcolu

 INX 
 DEC  width
 BEQ  chrdun
 LDA  pixcolu+1
 EOR  colour
 STA  pixcolu+1
 AND  #$AA
 BEQ  pixcolum
 LDA  addres
 CLC 
 ADC  #8
 STA  addres
 BCC  pixcolum
 INC  addres+1
 BNE  pixcolum

chrdun:
 LDA  addres
 CLC 
 ADC  #8
 STA  addres
 BCC  lab1
 INC  addres+1
lab1:
 LDY  savey
 DEC  length
 BNE  nxtchr
 RTS 

strdat:
.word  paustxt
.word  SCRtext
.word  HItext
.word  entering_wave
.word  gameover
.word  pressspace
.word  galaforce
.word  myname
.word  letter_S_Q
.word  letter_K_J
.word  pressspace2
.word  finish1
.word  finish2
.word  finish3
.word  finish4
.word  copyr
.word  za
.word  zb
.word  zc

paustxt:
.word  $7FE8
.byte 1
.byte 60
.byte 25

SCRtext:
.word  $3030
.byte  3
.byte  51
.byte 28
.byte 12
.byte 27
; 'SCR'

HItext:
.word  $3150
.byte  2
.byte  51
.byte 17
.byte 18
; 'HI'

entering_wave:
.word  $5108
.byte  16
.byte  63
.byte 14
.byte 23
.byte 29
.byte 14
; ENTE
.byte 27
.byte 18
.byte 23
.byte 16
; RING
.byte 38
.byte 35
.byte 24
.byte 23
; ZON
.byte 14
.byte 38
wave_text:
.byte 38
.byte 38
gameover:
.word  $4C58
.byte  9
.byte  60
.byte 16
.byte 10
.byte 22
.byte 14
; GAME
.byte 38
.byte 24
.byte 31
.byte 14
; OVE
.byte 27
; R

pressspace:
.word  $6760
.byte  19
.byte  12
.byte 25
.byte 27
.byte 14
.byte 28
; PRES
.byte 28
.byte 38
.byte 28
.byte 25
; S SP
.byte 10
.byte 12
.byte 14
.byte 38
; ACE
.byte 24
.byte 27
.byte 38
.byte 15
; OR F
.byte 18
.byte 27
.byte 14
; IRE

pressspace2:
.word  $6CF0
.byte  7
.byte  12
.byte 29
.byte 24
.byte 38
.byte 25
; TO P
.byte 21
.byte 10
.byte 34
; LAY

galaforce:
.word  $3FD8
.byte  9
.byte  $F
.byte 16
.byte 10
.byte 21
.byte 10
; GALA
.byte 15
.byte 24
.byte 27
.byte 12
.byte 14
; FORCE

myname:
.word  $4488
.byte  16
.byte  60
.byte 11
.byte 34
.byte 38
.byte 20
; BY K
.byte 14
.byte 31
.byte 18
.byte 23
; EVIN
.byte 38
.byte 14
.byte 13
.byte 32
; EDW
.byte 10
.byte 27
.byte 13
.byte 28
; ARDS

letter_S_Q:
.word  $7FD0
.byte  1
.byte  3
sound_letter:
.byte  28

letter_K_J:
.word  $7FB8
.byte  1
.byte  60
key_joy_letter:
.byte  20

finish1:
.word $5900
.byte  6
.byte  $C3
.byte 28
.byte 10
.byte 29
.byte 30
; SATU
.byte 27
.byte 23
; RN

finish2:
.word $58F0
.byte  7
.byte  $C3
.byte 11
.byte 10
.byte 29
.byte 29
; BATT
.byte 14
.byte 27
.byte 34
; ERY

finish3:
.word $5910
.byte  5
.byte  $C3
.byte 29
.byte 30
.byte 27
.byte 11
; TURB
.byte 24
; 0

finish4:

copyr:
.word $7678
.byte  17
.byte  51
.byte 28
.byte 30
.byte 25
.byte 14
;SUPE
.byte 27
.byte 18
.byte 24
.byte 27
;RIOR
.byte 38
.byte 28
.byte 24
.byte 15
; SOF
.byte 29
.byte 32
.byte 10
.byte 27
;TWAR
.byte 14
; E

za:
.word  $FFFF
.byte  1
.byte  3
zs:
.byte  $FF

zb:
.word  $FFFF
.byte  21
.byte  3
zt:
.byte  0
; 1 to 8
.byte  38
; space
.byte  "1234567"
; Score
.byte  38
.byte 38
; Spaces
.byte  "1234567890"
; Name

zc:
.word  $3D00
.byte  15
.byte  60
.byte 14
.byte 23
.byte 29
.byte 14
.byte 27
.byte 38
; ENTER
.byte 34
.byte 24
.byte 30
.byte 27
.byte 38
; YOUR
.byte 23
.byte 10
.byte 22
.byte 14
; NAME

;; ]
;; PRINT"Char print from &";~B%;" to &";~P%-1;" (";P%-B%;")"
;; PAGE=&5800
;; PAGE=&5800RETURN

;; REM 012345
;; DATA &7F,&41,&41,&79,&7F
;; DATA &00,&78,&7F,&00,&00
;; DATA &79,&79,&49,&49,&4F
;; DATA &63,&49,&49,&7F,&78
;; DATA &1F,&11,&71,&7F,&10
;; DATA &6F,&49,&49,&79,&79
;; REM 6789
;; DATA &7F,&49,&49,&49,&7B
;; DATA &01,&01,&01,&79,&7F
;; DATA &78,&4F,&49,&7F,&78
;; DATA &0F,&09,&09,&79,&7F
;; REM ABCDEF
;; DATA &78,&7F,&09,&0F,&78
;; DATA &7F,&79,&49,&4F,&78
;; DATA &7F,&79,&41,&41,&63
;; DATA &7F,&79,&41,&41,&7F
;; DATA &7F,&79,&49,&49,&49
;; DATA &7F,&79,&09,&09,&09
;; REM GHIJKL
;; DATA &7F,&79,&41,&49,&7B
;; DATA &7F,&78,&08,&08,&7F
;; DATA &00,&7F,&78,&00,&00
;; DATA &70,&40,&40,&7F,&78
;; DATA &7F,&78,&08,&0F,&78
;; DATA &7F,&78,&40,&40,&40
;; REM MNOPQR
;; DATA &7F,&01,&7F,&01,&7F
;; DATA &7F,&79,&01,&01,&7F
;; DATA &7F,&41,&41,&43,&7F
;; DATA &7F,&79,&09,&09,&0F
;; DATA &7F,&41,&61,&61,&7F
;; DATA &7F,&79,&09,&0F,&78
;; REM STUVWX
;; DATA &4F,&49,&49,&79,&79
;; DATA &01,&01,&7F,&79,&01
;; DATA &7F,&78,&40,&40,&7F
;; DATA &0F,&7F,&40,&70,&0F
;; DATA &7F,&40,&7F,&40,&7F
;; DATA &77,&78,&08,&08,&77
;; REM YZ.-(space)
;; DATA &0F,&08,&78,&08,&0F
;; DATA &7B,&79,&49,&49,&6F
;; DATA &00,&00,&60,&00,&00
;; DATA &08,&08,&08,&08,&08
;; DATA &00,&00,&00,&00,&00
;; REM ()
;; DATA &00,&18,&66,&81,&00
;; DATA &00,&81,&66,&18,&00
