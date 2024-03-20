SHELL := /bin/bash

CC=$(shell which z88dk-z80asm z88dk.z88dk-z80asm | head -1)
DISASSEMBLER=$(shell which z88dk-dis z88dk.z88dk-dis | head -1)

ROOT_PATH=

MODULES := src inc
SRC_DIR := $(addprefix $(ROOT_PATH),$(MODULES)) .
BUILD_DIR := $(addprefix build/,$(MODULES))

SRC := $(foreach sdir,$(SRC_DIR),$(wildcard $(sdir)/*.asm))
OBJ := $(foreach sdir,$(BUILD_DIR),$(wildcard $(sdir)/*.o))
INCLUDES := $(addprefix -I,$(SRC_DIR))

export OS_PATH := $(PWD)
BIN=loader.bin
# As the first section of the OS  must be RST_VECTORS, the final binary is named os_RST_VECTORS.bin
BIN_GENERATED=loader_RST_VECTORS.bin
BINDIR=build
FULLBIN=$(BINDIR)/$(BIN)
INCLUDEDIRS:=../../z80-sdk/src ../../z80-sdk/inc
MAPFILE=loader.map


# We have to manually do it for the linker script
LINKERFILE_PATH=src/linker.asm
LINKERFILE_OBJ=$(patsubst %.asm,%.o,$(LINKERFILE_PATH))
LINKERFILE_BUILT=$(BINDIR)/$(LINKERFILE_OBJ)


all: 
	$(CC) $(INCLUDES) $(addprefix -I,$(INCLUDEDIRS)) -v -b -m -s  -O$(BINDIR) -o$(FULLBIN) src/linker.asm src/rst_vectors.asm
	@mv $(BINDIR)/$(BIN_GENERATED) $(FULLBIN)
	$(DISASSEMBLER) -o 0x0000 -x $(BINDIR)/$(MAPFILE) $(BINDIR)/$(BIN) > $(BINDIR)/loader.dump

dump:
	$(DISASSEMBLER) -o 0x0000 -x $(BINDIR)/$(MAPFILE) $(BINDIR)/$(BIN) | less

fdump:
	$(DISASSEMBLER) -o 0x0000 -x $(BINDIR)/$(MAPFILE) $(BINDIR)/$(BIN) > $(BINDIR)/loader.dump

clean:
	rm -rf $(BINDIR)
