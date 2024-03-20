INCLUDE "board_h.asm"

SECTION KERNEL_BSS
BOARD_IO_CFG_REG_BACK: 
DB 0
SECTION KERNEL_IO

;-----------------------------------------------------------------------
; Result:
; h = minor
; l = major
;-----------------------------------------------------------------------
board_version:
	ld hl, 0x0001
	ret
;-----------------------------------------------------------------------
; Altered:
; a
;-----------------------------------------------------------------------
board_SetLcdRstAsserted:
	ld a, (BOARD_IO_CFG_REG_BACK)
	and !IO_CFG_REG_LCD_RESET_bm
	jr board_WriteCfgReg

;-----------------------------------------------------------------------
; Altered:
; a
;-----------------------------------------------------------------------
board_SetLcdRstDeAsserted:
	ld a, (BOARD_IO_CFG_REG_BACK)
	or IO_CFG_REG_LCD_RESET_bm
	jr board_WriteCfgReg

;-----------------------------------------------------------------------
; Altered:
; a
;-----------------------------------------------------------------------
board_SelectSioaRs232:
	ld a, (BOARD_IO_CFG_REG_BACK)
	and !IO_CFG_REG_MOUSE_bm
	jr board_WriteCfgReg

;-----------------------------------------------------------------------
; Altered:
; a
;-----------------------------------------------------------------------
board_SelectSioaMouse:
	ld a, (BOARD_IO_CFG_REG_BACK)
	or IO_CFG_REG_MOUSE_bm
	jr board_WriteCfgReg

;-----------------------------------------------------------------------
; Altered:
; a
;-----------------------------------------------------------------------
board_SelectSioaClk2:
	ld a, (BOARD_IO_CFG_REG_BACK)
	and !IO_CFG_REG_CTC_bm
	jr board_WriteCfgReg

;-----------------------------------------------------------------------
; Altered:
; a
;-----------------------------------------------------------------------
board_SelectSioaCtc:
	ld a, (BOARD_IO_CFG_REG_BACK)
	or IO_CFG_REG_CTC_bm
board_WriteCfgReg:
	ld (BOARD_IO_CFG_REG_BACK), a
	out (IO_CFG_REG), a
	ret




