;;
;; Galaforce 1 ( BBC Micro ) from the original 6502 source code, adapted to assemble using beebasm
;;
;; (c) Kevin Edwards 1986-2019
;;
;; Twitter @KevEdwardsRetro
;;

;; REM SAVE"INIT"
;; B%=P%
;; [OPT pass


exec:

    ; Approximate BBC Mode 2 - 160x256 with 16 colors.
    ; The difference here is that the VERA bitmap is 320 pixels wide, and
    ; we're scaling that, so per-line access needs to increment by 160 pixels, not
    ; 80

    ;
    ; Configure a 160x256, 16-color bitmap mode
    ;
    ; Address autoincrement by 1
    lda #$10
    sta VERA_addr_bank
    lda #$00
    sta VERA_addr_high
    sta VERA_addr_low

    lda #0
    sta VERA_L0_vscroll_l
    sta VERA_L0_vscroll_h

    ;
    ; Configure Layer 0 for bitmap mode with 4-bit color
    ;
    lda #$06 ; bitmap mode, 4 bpp
    sta VERA_L0_config

    lda #$00 ; DCSEL = 0
    sta VERA_ctrl

    ; Set scaling for 160x256 resolution
    ;
    ; H-Scale = (160 / 640) * 256 = 0.25 * 256 = 64 = $40
    lda #$40
    sta VERA_dc_hscale

    ; V-Scale = (256 / 480) * 256 ~= 0.533 * 256 ~= 136 = $88
    lda #$88 ; Note that this gives inexact scaling.
    ;lda #$80
    sta VERA_dc_vscale

    lda #$00
    sta VERA_L0_mapbase
    sta VERA_L0_tilebase

    ; Enable video output, enable layer 0, 240p mode, RGB output
    lda #$11 ; Layer 0, VGA
    sta VERA_dc_video

;        jsr test_draw

    ldx #$00      ; Index register X = 0
    ldy #$00      ; Index register Y = 0


clear_vram:
    lda #$ee
    sta VERA_data0
    sta VERA_data0
    sta VERA_data0
    sta VERA_data0
    sta VERA_data0
    sta VERA_data0
    sta VERA_data0
    sta VERA_data0

    ; The screen is 160x256 pixels, which is (160 * 256) / 2 = 20480 bytes
    ; So we need to loop 20480 times
    inx
    cpx #160

    bne clear_vram
    ldx #$00
    iny
    cpy #60
    bne clear_vram

wait:
    wai
    jmp wait


charlist:
 LDA #18
showchars:
 JSR CHROUT
 INA
 CMP #100
 BNE showchars

; LDY #3
; JSR prnstr ; Entering wave

; WAI

; LDA #65
; JSR test_draw

done:
 WAI
 jmp done

 LDX #$FF
 TXS 
 JSR Stop
 SEI 
 LDA #(dem_sound .mod 256)
 STA $220
 LDA #(dem_sound / 256)
 STA $221
 CLI 
 LDY #$E
 LDA #0
setup_hiscore:
 STA myscore-1,Y
 DEY 
 BNE setup_hiscore
 LDA #3
 STA hiscore+2
; LDA#&90 LDX#0 LDY#1 JSRosbyte
 LDA #22
 JSR oswrch ; mode 2
 LDA #2
 JSR oswrch ; mode 2
 LDA #10
 STA $FE00
 LDA #32
 STA $FE01
 JSR seed_rnd
 JSR starinit
 LDY #2
 JSR prnstr ; SCRtext
 LDY #4
 JSR prnstr ; HItext
 LDA #$80
 STA sound_flag
 STA pause_flag
 STA key_joy_flag
 JSR display_sound_status
 JSR display_key_joy_status

 JSR init_score
 ;JSR wait_for_space
 TAY 

; The 'game' loop
 ;lda #66
 ;jmp test_loop

restart:
 LDA #3
 STA lives
 STA sixteen_flag
; +ve allows it to be printed
 STA extra_life_flag
 STY curwave
 LDA vecwavl,Y
 STA wavbase
 LDA vecwavh,Y
 STA wavbase+1
 JSR flagson
 LDA #14
 LDX #4
 JSR osbyte ; enable events
 LDA demo_flag
 BMI no_st_tune
 LDY #0
 JSR StartTune
no_st_tune:
 LDA #0
 STA wavoff
 LDY #process
 STY aliens
 DEY 
 STY aliensm1

 JSR init_score
 JMP first_life

next_life:
 JSR liveson
 LDY #0
 LDA (wavbase),Y
 STA aliens
 SEC 
 SBC #1
 STA aliensm1
 DEC wavoff
 DEC lives
 BNE first_life
 LDX #(lstman .mod 256)
 LDY #(lstman / 256)
 JSR mksound
first_life:
 JSR liveson
 JSR rstall
 JSR pokmypos
 LDA #$C0
 STA screen2+1
 LDA graph+36
 TAX 
 LDY graph+37
 STY temp1
 JSR sprite
 JSR message_loop

main_loop:
 CLI 
 INC counter
 JSR escape
 JSR rand
 JSR move_my_base
 JSR movestars
 JSR init_new_aliens
 JSR move_the_aliens
 JSR process_my_bombs
 JSR process_aliens_bombs
 JSR collision

 LDA myst
 BPL main_loop
 LDA almove
 BPL main_loop
 LDA albullact
 ORA mybullact
 BNE main_loop
 JSR die_loop
 LDA lives
 BNE next_life
 JSR check_new_high
 LDA #$31
 STA screen+1
 JSR poke_hi_scr
 JSR game_over_loop
 JSR ahigh
; src TEST
 JSR wait_for_space
 PHA 
 JSR flagson
 PLA 
 TAY 
 JMP restart

wait_for_space:
 JSR end_message
 LDA #0
 STA counter

space_loop:
 JSR srlp
 INC counter
 BEQ hsclp
 JSR chk_spc_fire
 BNE space_loop
 PHP 
 JSR end_message
jkch:
 JSR display_key_joy_status
 PLP 
 LDA #0
 ADC #19
 STA key_joy_letter
 LDX #$FF
 CMP #20
 BEQ set_kbd_negative
 INX 
set_kbd_negative:
 TXA 
 JSR key_joy2
 LDA #0
 STA demo_flag
 RTS 

hsclp:
 JSR end_message
 JSR pht
hscl2:
 JSR srlp
 INC counter
 BEQ into_demo
 JSR chk_spc_fire
 BNE hscl2
 PHP 
 JSR pht
 JMP jkch

into_demo:
 JSR pht
 LDX #$FF
 STX demo_flag
 STX demo_count
 INX 
 STX dem_section
 JSR rand
 AND #7
; Random start for demo
 RTS 

process_demo:
 LDA demo_flag
 BPL not_in_demo
 DEC demo_count
 BPL not_in_demo
 LDA rand1+1
 STA demo_direction
 AND #15
 ADC #10
 STA demo_count
not_in_demo:
 RTS 

; Event routine for Tune
; Refreshing

dem_sound:
 CMP #4
 BNE ex_dem2
 BIT pause_flag
 BPL ex_dem2
 TXA 
 PHA 
 TYA 
 PHA 
 JSR Refresh
 JSR MusicTest
 BNE ex_dem
 DEC dem_section
 BPL not_new_tune
 LDA #7
 STA dem_section
not_new_tune:
 LDX dem_section
 LDY dem_table,X
 LDA demo_flag
 BPL ex_dem
 JSR StartTune
 JSR Refresh
ex_dem:
 PLA 
 TAY 
 PLA 
 TAX 
ex_dem2:
 RTS 

; Backwards order for demo
; tunes ie 21,21,42,42,..

dem_table:
.byte 56
.byte 56
.byte 49
.byte 49
.byte 42
.byte 42
.byte 21
.byte 21

die_loop:
 BIT demo_flag
 BMI dl1
 LDY #28
 JSR StartTune
dl2:
 JSR movestars
 JSR pause
 LDX #22
 JSR delay2
 JSR MusicTest
 BNE dl2
dl1:
 RTS 

lstman:
.word  $13
.word  9
.word  160
.word  50

srlp:
 LDX #24
 JSR delay2
 JSR movestars
 JMP pause

;; ]
;; PRINT"Init from &";~B%;" to &";~P%-1;" (";P%-B%;")"
;; PAGE=&5800
;; RETURN
