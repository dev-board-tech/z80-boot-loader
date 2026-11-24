SHELL := /bin/bash

CC=$(shell which z88dk-z80asm z88dk.z88dk-z80asm | head -1)
DISASSEMBLER=$(shell which z88dk-dis z88dk.z88dk-dis | head -1)

ROOT_PATH=

MODULES := src inc
SRC_DIR := $(addprefix $(ROOT_PATH),$(MODULES)) .
BUILD_DIR := $(addprefix build/,$(MODULES))

SRC := $(foreach sdir,$(SRC_DIR),$(wildcard $(sdir)/*.asm))
INCLUDES := $(addprefix -I,$(SRC_DIR))

BIN_GENERATED=os_KERNEL_RST_VECTORS.bin

export OS_PATH := $(PWD)
BIN=tinybasic2dms.bin
BINDIR=build
FULLBIN=$(BINDIR)/$(BIN)
MAPFILE=tinybasic2dms.map


all: 
	$(CC) $(INCLUDES) -v -b -m -s -O$(BINDIR) -o$(FULLBIN) src/tinybasic2dms.asm
	$(DISASSEMBLER) -o 0x0000 -x $(BINDIR)/$(MAPFILE) $(BINDIR)/$(BIN) > $(BINDIR)/tinybasic2dms.dump

dump:
	$(DISASSEMBLER) -o 0x0000 -x $(BINDIR)/$(MAPFILE) $(BINDIR)/$(BIN) | less

fdump:
	$(DISASSEMBLER) -o 0x0000 -x $(BINDIR)/$(MAPFILE) $(BINDIR)/$(BIN) > $(BINDIR)/tinybasic2dms.dump

clean:
	rm -rf $(BINDIR)
