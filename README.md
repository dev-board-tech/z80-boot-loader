# z80-boot-loader
 A simple asm boot loader for z80

In current configuration is mapping ROM page 0 as block 0 in MMU, last page of RAM as block 1 in MMU, and page 0 and 1 of RAM in block 2 and 3 in MMU.

The data transfer is happening in HEX, character 'r' will restart the boot-loader, the '\r' will jump to the address 7 of the ROM, address 7 in the application need to be a RST0 instruction.

The SIO can be replaced by a soft SIO in systems with no hardware serial interface.

The IO board configuration is in board_h.asm current repo and sio_h.asm in z80-sdk repo.

The PC application is a simple UI developed in Qt Community edition, has a simple built in terminal to avoid switching from boot-loader to terminal and vice-versa.

This boot loader is developed for this board: https://github.com/dev-board-tech/z80-pc-sch
