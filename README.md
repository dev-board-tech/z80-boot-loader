# z80-boot-loader
 A simple asm boot loader for z80

In current configuration is mapping ROM page 0 as block 0 in MMU, last page of RAM as  block 1 in MMU, and page 0 and 1 of RAM in block 2 and 3 in MMU.

The data transfer is happening in HEX, character 'r' will restart the boot-loader, the '\r' will execute rst 8, rst 8 need to be the same in user application as in bootloader cuz after rst 8 will change page 0 of ROM with page 0 of RAM, the application need to do a rst 0 to run the application from address 0.

The SIO can be replaced by a soft SIO in systems with no hardware serial interface.

The IO board configuration is in board_h.asm current repo and sio_h.asm in z80-sdk repo.

The PC application is a simple UI developed in Qt Community edition, has a simple built in terminal to avoid switching from boot-loader to terminal and vice-versa.
