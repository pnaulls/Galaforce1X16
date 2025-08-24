;;
;; Galaforce 1 ( BBC Micro ) from the original 6502 source code, adapted to assemble using beebasm
;;
;; (c) Kevin Edwards 1986-2019
;;
;; Twitter @KevEdwardsRetro
;;

;;REM SAVE"ZPWORK"

;;P%=0
;;P%=0O%=&3000

;;[OPT 6

;;.segment "ZEROPAGE"
.zeropage

.res $22

colour:
screen:
	.byte  0
savey:
.byte  0

data:
screen2:
.byte  0
.byte  0
temp:
temp1:
	.byte  0
length:
.byte  0

width:
temp2:
	.word  0

addres:
temp3:
	.word 0
addres1:
temp4:
	.word  0
wavbase:
.word  0
;stardat:
;.res 3 * 31
rand1:
	.res 3
whichstar:
.byte  0
counter:
.byte 0
expldelay:
.byte 0



initst:
	.res maxpatt
initx:
	.res maxpatt
inity:
	.res maxpatt
initdel:
.res maxpatt
initcount:
.res maxpatt
initnum:
.res maxpatt
initrelx:
.res maxpatt
initrely:
.res maxpatt
initgra:
.res maxpatt
initpnum:
.res maxpatt

.org $A9
.segment "ZP2" : zeropage

aliens:
.byte  0
aliensm1:
.byte  0

;stardat:
;.res 3 * 31

;; ]
;; PRINT'"Zero page from 0 to &";~P%-1
;; PAGE=&5800
;;RETURN

;; DEFFNres2(gap%)
;; P%=P%+gap%
;; P%=P%+gap%O%=O%+gap%
;; =6
