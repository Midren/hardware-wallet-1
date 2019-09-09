.DEFAULT_GOAL := help
.PHONY: clean-lib clean
.PHONY: build-deps firmware-deps bootloader bootloader-mem-protect
.PHONY: check check-version check-trng check-protob test check-ver
.PHONY: firmware sign full-firmware-mem-protect full-firmware
.PHONY: emulator run-emulator st-flash oflash
.PHONY: bootloader-clean release-bootloader release-bootloader-mem-protect
.PHONY: firmware-clean release-firmware
.PHONY: release-combined release-combined-mem-protect check-coverage

FIRMWARE_SIGNATURE_SEC_KEY  ?= ab01d85ecaa5c851ad1e7bd2ba4ca179bbac52588779880cf47b99c15faa729e
FIRMWARE_SIGNATURE_PUB_KEY1 ?= 03d7fe879bea92c657797881cc2437fea86337ed4dce19859f43d023c1772c81dd
FIRMWARE_SIGNATURE_PUB_KEY2 ?= 02ce15278b4d1cf5c20a2a518b95438bc1d497b1d55bddf69dbb253b538c131625
FIRMWARE_SIGNATURE_PUB_KEY3 ?= 02bebd3856b3fdadc54714220819946980d413edc8bc49f679b88fd2bf99ae0e15
FIRMWARE_SIGNATURE_PUB_KEY4 ?= 02015aa7da6acb423266a50db8821b42493cd2d874911c309209a003a1051c5d74
FIRMWARE_SIGNATURE_PUB_KEY5 ?= 03579beeeb075dcd20c63cbd3851ff0c81b1448c4f28597ce28924344a3f4bdbd4
FIRMWARE_SIGNATURE_PUB_KEYs = $(FIRMWARE_SIGNATURE_PUB_KEY1) $(FIRMWARE_SIGNATURE_PUB_KEY2) $(FIRMWARE_SIGNATURE_PUB_KEY3) $(FIRMWARE_SIGNATURE_PUB_KEY4) $(FIRMWARE_SIGNATURE_PUB_KEY5)

UNAME_S ?= $(shell uname -s)

PYTHON   ?= /usr/bin/python
PIP      ?= pip
PIPARGS  ?=
COVERAGE ?= 0

MKFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
MKFILE_DIR  := $(dir $(MKFILE_PATH))

FULL_FIRMWARE_PATH ?= releases/full-firmware-no-mem-protect.bin

VERSION_BOOTLOADER       =$(shell cat tiny-firmware/bootloader/VERSION | tr -d v)
VERSION_BOOTLOADER_MAJOR =$(shell echo $(VERSION_BOOTLOADER) | cut -d. -f1)
VERSION_BOOTLOADER_MINOR =$(shell echo $(VERSION_BOOTLOADER) | cut -d. -f2)
VERSION_BOOTLOADER_PATCH =$(shell echo $(VERSION_BOOTLOADER) | cut -d. -f3)
VERSION_FIRMWARE_RAW     =$(shell cat tiny-firmware/VERSION)
VERSION_FIRMWARE_MAJOR   =$(shell echo $(VERSION_FIRMWARE_RAW) | tr -d v | cut -d. -f1)
VERSION_FIRMWARE_MINOR   =$(shell echo $(VERSION_FIRMWARE_RAW) | cut -d. -f2)
VERSION_FIRMWARE_PATCH   =$(shell echo $(VERSION_FIRMWARE_RAW) | cut -d. -f3)
VERSION_FIRMWARE         =$(VERSION_FIRMWARE_MAJOR).$(VERSION_FIRMWARE_MINOR).$(VERSION_FIRMWARE_PATCH)
# https://semver.org/
# $(call is_version_correct,version)
define is_version_correct
$(if $(shell echo $1 | egrep '^[0-9]+\.[0-9]+\.[0-9]+$$'),1,0)
endef

VERSION_IS_SEMANTIC_COMPLIANT = 0
ifeq ($(call is_version_correct,$(VERSION_FIRMWARE)),0)
	VERSION_FIRMWARE = $(VERSION_FIRMWARE_RAW)
	ifeq ($(call is_version_correct,$(VERSION_FIRMWARE)),0)
		VERSION_IS_SEMANTIC_COMPLIANT=0
	else
		VERSION_IS_SEMANTIC_COMPLIANT=1
	endif
else
	VERSION_IS_SEMANTIC_COMPLIANT=1
endif

export VERSION_IS_SEMANTIC_COMPLIANT
export VERSION_FIRMWARE
ID_VENDOR=12602
ID_PRODUCT=1
#https://github.com/skycoin/skycoin-hardware-wallet/tree/55c50ceca0d5552ef4147eb2a26f8b12ee114749#supported-languages
LANG=1
COMBINED_VERSION=v$(VERSION_BOOTLOADER)-v$(VERSION_FIRMWARE)-$(ID_VENDOR)-$(ID_PRODUCT)-$(LANG)

ifeq ($(UNAME_S), Darwin)
	LD_VAR=DYLD_LIBRARY_PATH
else
	LD_VAR=LD_LIBRARY_PATH
endif
check-version: ## Check that the tiny-firmware/VERSION match the current tag
	@./ci-scripts/version.sh > tiny-firmware/VERSION
	@if [ $$VERSION_IS_SEMANTIC_COMPLIANT -eq 1 ]; then git diff --exit-code tiny-firmware/VERSION; fi
	@git checkout tiny-firmware/VERSION

install-linters-Darwin:
	brew install yamllint

install-linters-Linux:
	$(PIP) install $(PIPARGS) yamllint

install-linters: install-linters-$(UNAME_S) ## Install code quality checking tools

lint: ## Check code quality
	yamllint -d relaxed .travis.yml

build-deps: ## Build common dependencies (protob)
	make -C tiny-firmware/protob/ build-c
	# UNIX symbolic links don't supported by Windows, so the best way
	# to use them is to create proper one in the begining of build
ifeq ($(OS),Windows_NT)
	( cd ./tiny-firmware/vendor && rm skycoin-crypto)
	( cd ./tiny-firmware/vendor && cmd /c 'mklink /d skycoin-crypto ..\..\skycoin-api\')
endif

firmware-deps: build-deps ## Build firmware dependencies
	make -C tiny-firmware/vendor/libopencm3/

generate-bitmaps:
	cd tiny-firmware/gen/bitmaps/ && python2 generate.py

MEMORY_PROTECT ?= 0
bootloader: firmware-deps ## Build bootloader (RDP level 0)
	rm -f tiny-firmware/memory.o tiny-firmware/gen/bitmaps.o # Force rebuild of these two files
	FIRMWARE_SIGNATURE_PUB_KEY1=$(FIRMWARE_SIGNATURE_PUB_KEY1) FIRMWARE_SIGNATURE_PUB_KEY2=$(FIRMWARE_SIGNATURE_PUB_KEY2) FIRMWARE_SIGNATURE_PUB_KEY3=$(FIRMWARE_SIGNATURE_PUB_KEY3) FIRMWARE_SIGNATURE_PUB_KEY4=$(FIRMWARE_SIGNATURE_PUB_KEY4) FIRMWARE_SIGNATURE_PUB_KEY5=$(FIRMWARE_SIGNATURE_PUB_KEY5) MEMORY_PROTECT=$(MEMORY_PROTECT) SIGNATURE_PROTECT=1 REVERSE_BUTTONS=1 VERSION_MAJOR=$(VERSION_BOOTLOADER_MAJOR) VERSION_MINOR=$(VERSION_BOOTLOADER_MINOR) VERSION_PATCH=$(VERSION_BOOTLOADER_PATCH) make -C tiny-firmware/bootloader/ align
	mv tiny-firmware/bootloader/bootloader.bin skybootloader-no-memory-protect.bin

bootloader-mem-protect: MEMORY_PROTECT=1
bootloader-mem-protect: bootloader ## Build bootloader (RDP level 2)
	mv skybootloader-no-memory-protect.bin skybootloader-memory-protected.bin

skycoin-crypto-lib:
	make -C tiny-firmware/vendor/skycoin-crypto/ libskycoin-crypto.a

arm-skycoin-crypto-lib:
	CC=arm-none-eabi-gcc AR=arm-none-eabi-ar make -C tiny-firmware/vendor/skycoin-crypto/ libskycoin-crypto.a

firmware: arm-skycoin-crypto-lib tiny-firmware/skyfirmware.bin ## Build skycoin wallet firmware

build-libc: tiny-firmware/bootloader/libskycoin-crypto.so ## Build the Skycoin cipher library for firmware

release-emulator: clean emulator ## Build emulator in release mode.
	cp emulator releases/emulator-$(UNAME_S)-v$(VERSION_FIRMWARE)

release-bootloader: ## Build bootloader in release mode.
	if [ "$(call is_version_correct,$(VERSION_BOOTLOADER))" -eq "0" ]; then echo "Wrong bootloader version format"; exit 1; fi
	DEBUG=0 VERSION_MAJOR=$(VERSION_BOOTLOADER_MAJOR) VERSION_MINOR=$(VERSION_BOOTLOADER_MINOR) VERSION_PATCH=$(VERSION_BOOTLOADER_PATCH) make bootloader
	mv skybootloader-no-memory-protect.bin releases/skywallet-bootloader-no-memory-protect-v$(VERSION_BOOTLOADER).bin

release-bootloader-mem-protect: ## Build bootloader(with memory protect enbled, make sure you know what you are doing).
	if [ "$(call is_version_correct,$(VERSION_BOOTLOADER))" -eq "0" ]; then echo "Wrong bootloader version format"; exit 1; fi
	DEBUG=0 VERSION_MAJOR=$(VERSION_BOOTLOADER_MAJOR) VERSION_MINOR=$(VERSION_BOOTLOADER_MINOR) VERSION_PATCH=$(VERSION_BOOTLOADER_PATCH) make bootloader-mem-protect
	mv bootloader-memory-protected.bin releases/skywallet-bootloader-mem-protect-v$(VERSION_BOOTLOADER).bin

release-firmware: check-version ## Build firmware in release mode.
	DEBUG=0 VERSION_MAJOR=$(VERSION_FIRMWARE_MAJOR) VERSION_MINOR=$(VERSION_FIRMWARE_MINOR) VERSION_PATCH=$(VERSION_FIRMWARE_PATCH) make firmware
	mv tiny-firmware/skyfirmware.bin releases/skywallet-firmware-v$(VERSION_FIRMWARE).bin

release-combined: release-bootloader release-firmware ## Build bootloader and firmware together in a combined file in released mode.
	cp releases/skywallet-bootloader-no-memory-protect-v$(VERSION_BOOTLOADER).bin tiny-firmware/bootloader/combine/bl.bin
	cp releases/skywallet-firmware-v$(VERSION_FIRMWARE).bin tiny-firmware/bootloader/combine/fw.bin
	cd tiny-firmware/bootloader/combine/ ; $(PYTHON) prepare.py && \
	mv tiny-firmware/bootloader/combine/combined.bin releases/skywallet-full-no-mem-protect-$(COMBINED_VERSION).bin

release-combined-mem-protect: release-bootloader-mem-protect release-firmware ## Build bootloader(with memory protect enbled, make sure you know what you are doing) and firmware together in a combined file in released mode.
	cp releases/skywallet-bootloader-mem-protect-v$(VERSION_BOOTLOADER).bin tiny-firmware/bootloader/combine/bl.bin
	cp releases/skywallet-firmware-v$(VERSION_FIRMWARE).bin tiny-firmware/bootloader/combine/fw.bin
	cd tiny-firmware/bootloader/combine/ ; $(PYTHON) prepare.py && \
	mv tiny-firmware/bootloader/combine/combined.bin releases/skywallet-full-mem-protect-$(COMBINED_VERSION).bin

release: release-combined release-combined-mem-protect release-emulator ## Create a release for production
	@cp tiny-firmware/VERSION releases/version.txt

release-sign: release # Create detached signatures for all the generated files for release
	gpg --armor --detach-sign releases/skywallet-firmware-v$(VERSION_FIRMWARE).bin
	gpg --armor --detach-sign releases/skywallet-full-no-mem-protect-$(COMBINED_VERSION).bin
	gpg --armor --detach-sign releases/skywallet-full-mem-protect-$(COMBINED_VERSION).bin
	gpg --armor --detach-sign releases/emulator-$(UNAME_S)-v$(VERSION_FIRMWARE)

tiny-firmware/bootloader/libskycoin-crypto.so:
	make -C skycoin-api clean
	make -C skycoin-api libskycoin-crypto.so
	cp skycoin-api/libskycoin-crypto.so tiny-firmware/bootloader/
	make -C skycoin-api clean

tiny-firmware/skyfirmware.bin: firmware-deps
	FIRMWARE_SIGNATURE_PUB_KEY1=$(FIRMWARE_SIGNATURE_PUB_KEY1) FIRMWARE_SIGNATURE_PUB_KEY2=$(FIRMWARE_SIGNATURE_PUB_KEY2) FIRMWARE_SIGNATURE_PUB_KEY3=$(FIRMWARE_SIGNATURE_PUB_KEY3) FIRMWARE_SIGNATURE_PUB_KEY4=$(FIRMWARE_SIGNATURE_PUB_KEY4) FIRMWARE_SIGNATURE_PUB_KEY5=$(FIRMWARE_SIGNATURE_PUB_KEY5) REVERSE_BUTTONS=1 VERSION_MAJOR=$(VERSION_FIRMWARE_MAJOR) VERSION_MINOR=$(VERSION_FIRMWARE_MINOR) VERSION_PATCH=$(VERSION_FIRMWARE_PATCH) make -C tiny-firmware/ add_meta_header

sign: tiny-firmware/bootloader/libskycoin-crypto.so tiny-firmware/skyfirmware.bin ## Sign skycoin wallet firmware
	FIRMWARE_SIGNATURE_PUB_KEY1=$(FIRMWARE_SIGNATURE_PUB_KEY1) FIRMWARE_SIGNATURE_PUB_KEY2=$(FIRMWARE_SIGNATURE_PUB_KEY2) FIRMWARE_SIGNATURE_PUB_KEY3=$(FIRMWARE_SIGNATURE_PUB_KEY3) FIRMWARE_SIGNATURE_PUB_KEY4=$(FIRMWARE_SIGNATURE_PUB_KEY4) FIRMWARE_SIGNATURE_PUB_KEY5=$(FIRMWARE_SIGNATURE_PUB_KEY5) make -C tiny-firmware sign

full-firmware-mem-protect: bootloader-mem-protect firmware ## Build full firmware (RDP level 2)
	cp bootloader-memory-protected.bin tiny-firmware/bootloader/combine/bl.bin
	cp tiny-firmware/skyfirmware.bin tiny-firmware/bootloader/combine/fw.bin
	cd tiny-firmware/bootloader/combine/ ; $(PYTHON) prepare.py
	mv tiny-firmware/bootloader/combine/combined.bin releases/full-firmware-memory-protected.bin

full-firmware: bootloader firmware ## Build full firmware (RDP level 0)
	cp skybootloader-no-memory-protect.bin tiny-firmware/bootloader/combine/bl.bin
	cp tiny-firmware/skyfirmware.bin tiny-firmware/bootloader/combine/fw.bin
	cd tiny-firmware/bootloader/combine/ ; $(PYTHON) prepare.py
	mv tiny-firmware/bootloader/combine/combined.bin releases/full-firmware-no-mem-protect.bin

emulator: skycoin-crypto-lib build-deps ## Build emulator
	EMULATOR=1 VERSION_MAJOR=$(VERSION_FIRMWARE_MAJOR) VERSION_MINOR=$(VERSION_FIRMWARE_MINOR) VERSION_PATCH=$(VERSION_FIRMWARE_PATCH) make -C tiny-firmware/
	mv tiny-firmware/skycoin-emulator emulator

run-emulator: emulator ## Run wallet emulator
	./emulator

test: clean firmware tiny-firmware/bootloader/libskycoin-crypto.so ## Run all project test suites.
	export LIBRARY_PATH="$(MKFILE_DIR)/skycoin-api/:$(shell echo $$$(LIBRARY_PATH))" && \
	export $(LD_VAR)="$(MKFILE_DIR)/skycoin-api/:$(shell echo $$$(LD_VAR))" && \
	./tiny-firmware/bootloader/firmware_sign.py -f ./tiny-firmware/skyfirmware.bin -pk $(FIRMWARE_SIGNATURE_PUB_KEYs) -s -sk $(FIRMWARE_SIGNATURE_SEC_KEY) -S 2 && \
	./tiny-firmware/bootloader/firmware_sign.py -f ./tiny-firmware/skyfirmware.bin -pk $(FIRMWARE_SIGNATURE_PUB_KEYs) && \
	rm ./tiny-firmware/skyfirmware.bin && \
	make -C skycoin-api/ clean && \
	make firmware && \
	make -C skycoin-api/ clean && \
	make -C skycoin-api/ libskycoin-crypto.so && \
	./tiny-firmware/bootloader/test_firmware_sign.py && \
	make -C skycoin-api/ libskycoin-crypto.so && \
	make clean && \
	make -C skycoin-api/ test && \
	VERSION_MAJOR=$(VERSION_FIRMWARE_MAJOR) VERSION_MINOR=$(VERSION_FIRMWARE_MINOR) VERSION_PATCH=$(VERSION_FIRMWARE_PATCH) make emulator && \
	EMULATOR=1 VERSION_MAJOR=$(VERSION_FIRMWARE_MAJOR) VERSION_MINOR=$(VERSION_FIRMWARE_MINOR) VERSION_PATCH=$(VERSION_FIRMWARE_PATCH) make -C tiny-firmware/ test

st-flash: ## Deploy (flash) firmware on physical wallet
	st-flash write $(FULL_FIRMWARE_PATH) 0x08000000

oflash: full-firmware
	openocd -f openocd.cfg

check-ver:
	echo "Bootloader : $(VERSION_BOOTLOADER_MAJOR).$(VERSION_BOOTLOADER_MINOR).$(VERSION_BOOTLOADER_PATCH)"
	echo "Firmware   : $(VERSION_FIRMWARE_MAJOR).$(VERSION_FIRMWARE_MINOR).$(VERSION_FIRMWARE_PATCH)"

check-trng: ## Run test tools over random buffers
	make -C trng-test trng-generate-buffers
	make -C trng-test run-tests

check-protob: ## verify protob submodule hash
	./ci-scripts/verify_protob_hash.sh

check-coverage: clean ## Generate test coverage reports HTML
	export LIBRARY_PATH="$(MKFILE_DIR)/skycoin-api/:$(shell echo $$$(LIBRARY_PATH))" && \
	export $(LD_VAR)="$(MKFILE_DIR)/skycoin-api/:$(shell echo $$$(LD_VAR))" && \
	COVERAGE=1 make -C $(MKFILE_DIR)/skycoin-api/ coverage && \
	COVERAGE=1 VERSION_MAJOR=$(VERSION_FIRMWARE_MAJOR) VERSION_MINOR=$(VERSION_FIRMWARE_MINOR) VERSION_PATCH=$(VERSION_FIRMWARE_PATCH) make emulator && \
	COVERAGE=1 EMULATOR=1 VERSION_MAJOR=$(VERSION_FIRMWARE_MAJOR) VERSION_MINOR=$(VERSION_FIRMWARE_MINOR) VERSION_PATCH=$(VERSION_FIRMWARE_PATCH) make -C $(MKFILE_DIR)/tiny-firmware/ coverage && \
	lcov -c --directory . --no-external --output-file coverage/coverage.info && \
	lcov --remove ./coverage/coverage.info -o ./coverage/coverage_filtered.info '*tiny-firmware/protob/nanopb/vendor/nanopb*' && \
	genhtml --title "Code coverage report for hardware wallet." ./coverage/coverage_filtered.info --output-directory coverage/

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

bootloader-clean:
	make -C tiny-firmware/bootloader/ clean

firmware-clean:
	make -C tiny-firmware/ clean

clean-lib: ## Delete all files generated by tiny-firmware library dependencies
	make -C tiny-firmware/vendor/libopencm3/ clean

clean: bootloader-clean firmware-clean ## Delete all files generated by build
	make -C skycoin-api/ clean
	make -C tiny-firmware/emulator/ clean
	make -C tiny-firmware/protob/ clean-c
	rm -f emulator.img
	rm -f emulator
	rm -f tiny-firmware/bootloader/libskycoin-crypto.so
	make -C trng-test clean
	rm -f $$(find . -name "*.bin" -o -path "./releases" -prune -type f )
	rm -f $$(find . -name '*.d' -type f )
	rm -vf $$(find . -name '*.gcda' -type f)
	rm -vf $$(find . -name '*.gcno' -type f)
	rm -rf coverage/*
