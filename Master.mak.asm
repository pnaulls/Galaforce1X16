;;
;; Galaforce 1 BBC
;;
;; (C) Kevin Edwards 1986-2019
;;

objstrt =$800  ; Start of actual code, data is loaded below this later ( to &900 and &A00 )
objend  =$3000 ; End of code, where the Downloader is positioned
objexec =$4000 ; Execution address when loaded to &1900 rather than &900 ( objend% + &1900 - &900 )

.include "x16.inc"

.include "src-x16/CONST.asm"
.include "src-x16/ZPWORK.asm"
.include "src-x16/ABSWORK.asm"

;; Normal ASCII
;.charmap ' ','Z', 32

spfont:
.org  objstrt - $200
.incbin "object/O.SPFONT"

spdigit:
.org  objstrt - $100
.incbin "object/O.DIGITS"

.org  $80D

;; Main Code block - source files assembled in the same order as the original
.segment "STARTUP"
.segment "INIT"
.segment "ONCE"
.segment "CODE"

 jmp exec

.include "src-x16/SPRITES.asm"
.include "src-x16/INIT.asm"
.include "src-x16/ALIENS1.asm"
.include "src-x16/ALIENS2.asm"
.include "src-x16/ALIENS3.asm"
.include "src-x16/ALIENS4.asm"
.include "src-x16/ROUT1.asm"
.include "src-x16/ROUT2.asm"
.include "src-x16/ROUT3.asm"
.include "src-x16/ROUT4.asm"
.include "src-x16/STARS.asm"
.include "src-x16/BOMBS1.asm"
.include "src-x16/BOMBS2.asm"
.include "src-x16/CHARP.asm"
.include "src-x16/FLAGS.asm"
.include "src-x16/MUSIC1.asm"
.include "src-x16/MUSIC2.asm"
.include "src-x16/MUSIC3.asm"
.include "src-x16/TITLE.asm"
.include "src-x16/HIGH.asm"
.include "src-x16/WAVE.asm"
.include "src-x16/PATT.asm"
.include "src-x16/PATDAT.asm"
.include "src-x16/VECTORS.asm"

test_loop:
 ;LDA #65
 JSR CHROUT
 JMP test_loop

test_draw:
 LDY #0
test_draw_y:
 LDX #0

test_draw_x:
 ;LDA #$3f

 STX VERA_addr_low
 LDA #0
 STY VERA_addr_high
 STA VERA_addr_bank

 LDA #$ee
 STA VERA_data0

 INX
 CPX #250
 BCC test_draw_x
 INY
 CPY #1
 BCC test_draw_y

 LDA #65
 JSR CHROUT

 RTS

vera_addr_lo:
 .res 1
vera_addr_hi:
 .res 1
vera_addr_bank:
 .res 1


osword:
osbyte:
oswrch:
  RTS

stardat:    ;; Doesn't fit in zeropage and moving before code causes overflow
.res 3 * 31

objcodeend = *
 ; PRINT not implemented"Code start  = ",~objstrt
.out .sprintf("Code start  = %x", objstrt)
.out .sprintf("End of code = %x", objcodeend - 1)
.out .sprintf("Length      = %x  (%d) bytes", objcodeend-objstrt, objcodeend-objstrt)
.out .sprintf("Bytes left  = %x   (%d) bytes", $297A-objcodeend, $297A-objcodeend)

 ; PRINT not implemented"End of code = ",~objcodeend-1
 ; PRINT not implemented"Length      = ",~objcodeend-objstrt,"    (",objcodeend-objstrt%,") bytes"
 ; PRINT not implemented"Bytes left  = ",~$297A-objcodeend,"   (",$297A-objcodeend,") bytes"

;; Include the graphics object file ( From &297A to &2FFF )
.org  $297A
.incbin "object/O.GRAPHIC"

;; Include the Downloader binary at its GENUINE load address
;.org  objend
;.incbin "O.DOWN"

;; SAVE out everything
 ; PRINT not implemented "Saving GAME ", ~objstrt - $200, ~objend% + $200, ~objexec%, ~$1900
 ; SAVE not implemented "GAME", objstrt - $200, objend% + $200, objexec%, $1900

;; Save Main Basic Loader ( gets tokenised first )
 ; PUTBASIC not implemented "bas_extra\LOADER.bas.txt","$.L"

