INCLUDE "boot_h.asm"
INCLUDE "mmu_h.asm"
INCLUDE "mmu.asm"
INCLUDE "board_h.asm"
INCLUDE "board.asm"
INCLUDE "sio_h.asm"
INCLUDE "sio.asm"
INCLUDE "semaphore.asm"
INCLUDE "util_h.asm"
INCLUDE "util.asm"
INCLUDE "str.asm"

EXTERN __KERNEL_BSS_head
EXTERN __KERNEL_BSS_size
EXTERN __STACK_tail

SECTION KERNEL_BSS

SIOA_ADDRESS:
DEFB 0

RECV_CNT:
DEFW 0

SECTION LOADER

NEW_LINE_STR:
DEFB "\r\n\0"
SET_SCREEN_SIZE_STR:
DEFB "\e[8;64;128t"
CLEAR_SCREEN_STR:
DEFB "\ec"
CLEAR_BACKLOG_STR:
DEFB "\e[3J\0"
START_MSG_STR:
DEFB "Waiting for upload\r\n\0"
RECV_HEX_ERR_MSG_STR:
DEFB "\r\nERROR:Not HEX character\r\n\0"

boot:
	MMU_INIT()
	; Boot loader will use the last RAM page as bank 1
	MMU_SET_ADDR(MMU_RAM_ADDR + MMU_RAM_SIZE - MMU_PAGE_SIZE, IO_MMU_BANK_1)
	; Application RAM address 0 maped as bank 2
	MMU_SET_ADDR(MMU_RAM_ADDR, IO_MMU_BANK_2)
	; Application RAM address 16384 maped as bank 3
	MMU_SET_ADDR(MMU_RAM_ADDR + MMU_PAGE_SIZE, IO_MMU_BANK_3)
	MMU_ENABLE()
BOOT_CLEAR_KERNEL_BSS:
	ld hl, __KERNEL_BSS_head
	ld de, __KERNEL_BSS_head + 1
	ld bc, __KERNEL_BSS_size - 1
	ld (hl), 0
	ldir
BOOT_SET_SP:
	ld sp, __STACK_tail
	call board_SetLcdRstDeAsserted

	; Init RECV counter
	ld hl, 32768
	ld (RECV_CNT), hl

BOOT_INIT_SIO:	
	call sio_Init
BOOT_INIT_SIOA:	
	SIO_INIT(SIO_BASE_ADDR, 0, SIO_DEG4_CLOCK_MODE_X32_m, SIO_DEG3_RX_CHAR_LEN_8BIT_m, SIO_DEG5_TX_CHAR_LEN_8BIT_m, SIOA_ADDRESS)
	
BOOT_INIT_SET_SCREEN_SIZE:	
	BOARD_LOAD_IO_ADDR(SIOA_ADDRESS)
	;ld hl, SET_SCREEN_SIZE_STR
	;call sio_PrintStr
BOOT_INIT_PRINT_START_MSG:	
	ld hl, START_MSG_STR
	call sio_PrintStr

loop:
	BOARD_LOAD_IO_ADDR(SIOA_ADDRESS)
	call sio_ReadCBlocking
	jr charRecv1
charRecv1_Ret:
	call sio_ReadCBlocking
	jr charRecv2
charRecv2_Ret:
	jr loop
	
charRecv1:
	cp a, '\r'
	jr z, charRecv_Enter
	cp a, 'r'
	jr z, charRecv_R
	call GetHex
	jr c, loop
	rlc a
	rlc a
	rlc a
	rlc a
	ld b, a
	jr charRecv1_Ret

charRecv2:
	cp a, 'r'
	jr z, charRecv_R
	call GetHex
	jr c, loop
	or b
	push af
	BOARD_LOAD_IO_ADDR(SIOA_ADDRESS)
	pop af
	ld hl, (RECV_CNT)
	ld (hl), a
	inc hl
	ld (RECV_CNT), hl
	; call sio_PrintHHexChar
	jr charRecv2_Ret

GetHex:
	cp '0'
	jr c, errorMessage
	cp '9' + 1
	jr c, IsFirstHexChar_0
	cp 'A'
	jr c, errorMessage
	cp 'F' + 1
	jr c, IsFirstHexChar_A
	cp 'a'
	jr c, errorMessage
	cp 'f' + 1
	jr c, IsFirstHexChar_a
	jr errorMessage

IsFirstHexChar_0:
	sub '0'
	jr IsFirstHexChar
IsFirstHexChar_A:
	sub 'A' - 10
	jr IsFirstHexChar
IsFirstHexChar_a:
	sub 'a' - 10
	jr IsFirstHexChar
IsFirstHexChar:
	scf
	ccf
	ret

errorMessage:
	BOARD_LOAD_IO_ADDR(SIOA_ADDRESS)
	;ld hl, RECV_HEX_ERR_MSG_STR
	;call sio_PrintStr
	ld a, 'E'
	call sio_SendC
	scf
	ret

; Self reset
charRecv_R:
	rst 0
	ret

; Jump to the application
charRecv_Enter:
	rst 8
	ret



