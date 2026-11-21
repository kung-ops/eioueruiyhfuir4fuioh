TITLE := PS4 Emulator Lab
VERSION := 01.00
TITLE_ID := EMLB00001
CONTENT_ID := IV0000-EMLB00001_00-EMULATORLAB00001
TOOLCHAIN := $(OO_PS4_TOOLCHAIN)
PKGTOOLS := $(TOOLCHAIN)/bin/linux
CC ?= clang
LD ?= ld.lld
CFLAGS := -x c++ -std=c++11 --target=x86_64-pc-freebsd12-elf -fPIC -funwind-tables -c -isysroot $(TOOLCHAIN) -isystem $(TOOLCHAIN)/include -O2
LDFLAGS := -m elf_x86_64 -pie --script $(TOOLCHAIN)/link.x --eh-frame-hdr -L$(TOOLCHAIN)/lib -lc -lkernel -lSceVideoOut -lSceLibcInternal $(TOOLCHAIN)/lib/crt1.o
.PHONY: all clean
all: $(CONTENT_ID).pkg
build:
	mkdir -p build
build/main.o: src/main.c | build
	$(CC) $(CFLAGS) -o $@ $<
eboot.bin: build/main.o
	$(LD) build/main.o -o build/app.elf $(LDFLAGS)
	$(PKGTOOLS)/create-fself -in=build/app.elf -out=build/app.oelf --eboot eboot.bin --paid 0x3100000000000001
sce_sys/icon0.png: tools/make_icon.py
	mkdir -p sce_sys
	python3 tools/make_icon.py $@
sce_sys/param.sfo: Makefile
	mkdir -p sce_sys
	$(PKGTOOLS)/PkgTool.Core sfo_new $@
	$(PKGTOOLS)/PkgTool.Core sfo_setentry $@ APP_TYPE --type Integer --maxsize 4 --value 1
	$(PKGTOOLS)/PkgTool.Core sfo_setentry $@ APP_VER --type Utf8 --maxsize 8 --value '$(VERSION)'
	$(PKGTOOLS)/PkgTool.Core sfo_setentry $@ ATTRIBUTE --type Integer --maxsize 4 --value 0
	$(PKGTOOLS)/PkgTool.Core sfo_setentry $@ CATEGORY --type Utf8 --maxsize 4 --value gd
	$(PKGTOOLS)/PkgTool.Core sfo_setentry $@ CONTENT_ID --type Utf8 --maxsize 48 --value '$(CONTENT_ID)'
	$(PKGTOOLS)/PkgTool.Core sfo_setentry $@ DOWNLOAD_DATA_SIZE --type Integer --maxsize 4 --value 0
	$(PKGTOOLS)/PkgTool.Core sfo_setentry $@ SYSTEM_VER --type Integer --maxsize 4 --value 0
	$(PKGTOOLS)/PkgTool.Core sfo_setentry $@ TITLE --type Utf8 --maxsize 128 --value '$(TITLE)'
	$(PKGTOOLS)/PkgTool.Core sfo_setentry $@ TITLE_ID --type Utf8 --maxsize 12 --value '$(TITLE_ID)'
	$(PKGTOOLS)/PkgTool.Core sfo_setentry $@ VERSION --type Utf8 --maxsize 8 --value '$(VERSION)'
pkg.gp4: eboot.bin sce_sys/param.sfo sce_sys/icon0.png
	python3 tools/make_gp4.py --out $@ --content-id $(CONTENT_ID) eboot.bin sce_sys/param.sfo sce_sys/icon0.png
$(CONTENT_ID).pkg: pkg.gp4
	$(PKGTOOLS)/PkgTool.Core pkg_build $< .
clean:
	rm -rf build eboot.bin pkg.gp4 sce_sys/param.sfo sce_sys/icon0.png *.pkg
