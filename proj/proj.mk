
SHELL           := /bin/bash

PROJ            := $(lastword $(subst /, ,${CURDIR}))
MODEL           ?= pdti8

TTY             := $(wildcard /dev/ttyUSB?)
UART_SPEED      := 921600
CRC             := --no-crc

#
# TODO: search upward until we find the root
# ... or get CFU_ROOT from an env variable
#
CFU_ROOT      := ../..
CFU_REAL_ROOT := $(realpath $(CFU_ROOT))


# Directory where we build the project-specific gateware
SOC_DIR   := $(CFU_ROOT)/soc
PLATFORM  := arty.$(PROJ)
GATEWARE  := $(SOC_DIR)/build/$(PLATFORM)/gateware
BITSTREAM := $(GATEWARE)/arty.bit


PROJ_DIR        := .
PROJ_REAL_DIR   := $(realpath $(PROJ_DIR))
CFU_NMIGEN      := $(PROJ_DIR)/cfu.py
CFU_NMIGEN_GEN  := $(PROJ_DIR)/cfu_gen.py
CFU_VERILOG     := $(PROJ_DIR)/cfu.v
BUILD           := $(PROJ_DIR)/build
THIRD_PARTY     := $(abspath $(PROJ_DIR)/third_party)
PYRUN           := $(CFU_REAL_ROOT)/scripts/pyrun

TFLM_SRC_DIR    := $(CFU_REAL_ROOT)/third_party/tflm_gen
TFLM_BLD_DIR    := $(abspath $(BUILD)/third_party/tflm_gen)
TFLM_OVERLAY_DIR:= $(abspath $(PROJ_DIR)/tflm_overlays)
TFLM_OVERLAYS   := $(shell cd tflm_overlays && find tensorflow -name "*.[hc]*")


CAM_BASES   := src ld Makefile
CAM_SRC_DIR := $(CFU_ROOT)/camera
CAM_FILES   := $(addprefix $(CAM_SRC_DIR)/, $(CAM_BASES))

HARNESS_BASES   := src ld Makefile interact.expect
HARNESS_SRC_DIR := $(CFU_ROOT)/tflm_harness
HARNESS_FILES   := $(addprefix $(HARNESS_SRC_DIR)/, $(HARNESS_BASES))
HARNESS_DIR     := $(BUILD)/tflm_harness_$(MODEL)
HARNESS_BIN     := $(BUILD)/tflm_harness_$(MODEL)/tflm_harness.bin
HARNESS_ELF     := $(BUILD)/tflm_harness_$(MODEL)/tflm_harness.elf
HARNESS_LOG     := $(BUILD)/tflm_harness_$(MODEL)/$(MODEL).LOG

LXTERM      := $(CFU_ROOT)/soc/bin/litex_term

#
# We maybe shouldn't ignore WIDTH errors
#   -- these can be fixed in the user nMigen code
#
VERILATOR_MAIN := verilator_main.cpp
VERILATOR_DIR  := verilator_sim
VERILATOR_LINT := -Wno-CASEINCOMPLETE -Wno-CASEOVERLAP -Wno-WIDTH


.PHONY:	proj harness-clean renode veri-clean


soc: $(BITSTREAM)

$(BITSTREAM): $(CFU_VERILOG)
	@echo Building SoC
	make -C $(CFU_ROOT) PROJ=$(PROJ) soc

$(CFU_VERILOG): $(CFU_NMIGEN) $(CFU_NMIGEN_GEN)
	$(PYRUN) $(CFU_NMIGEN_GEN)

prog: $(BITSTREAM)
	openocd -f $(CFU_REAL_ROOT)/prog/openocd_xc7_ft2232.cfg -c "init ; pld load 0 $(BITSTREAM) ; exit"

sim-basic: $(CFU_VERILOG)
	pushd $(SOC_DIR) && $(PYRUN) ./soc.py --cfu $(PROJ_REAL_DIR)/$(CFU_VERILOG) --sim-rom-dir $(CFU_REAL_ROOT)/basic_cfu && popd


o:
	@echo TFLM OVERLAYS: $(TFLM_OVERLAYS)
	for i in $(TFLM_OVERLAYS); do echo $$i; done

#
# Copy TFLM harness sources and Makefile.
# They will use this proj's tflm library.
#
harness: $(HARNESS_BIN)

$(HARNESS_BIN): $(HARNESS_DIR)
	@echo Building TFLM harness app, under build/, for model $(MODEL)
	make -C $(HARNESS_DIR) TFLM_DIR=$(TFLM_BLD_DIR) CFU_ROOT=$(CFU_REAL_ROOT) PLATFORM=$(PLATFORM) MODEL=$(MODEL) PROJ=$(PROJ)

$(HARNESS_DIR):
	@echo Building TFLM harness app, under build/, for model $(MODEL)
	mkdir -p $(HARNESS_DIR)
	/bin/cp -r $(HARNESS_FILES) $(HARNESS_DIR)
	make -C $(TFLM_SRC_DIR) clean
	mkdir -p $(BUILD)/third_party
	/bin/rm -rf $(TFLM_BLD_DIR)
	/bin/cp -r $(TFLM_SRC_DIR) $(TFLM_BLD_DIR)
	/bin/cp -r $(TFLM_SRC_DIR)/../include/riscv.h $(TFLM_BLD_DIR)
	#/bin/cp -r $(TFLM_OVERLAY_DIR)/tensorflow $(TFLM_BLD_DIR)
	for i in $(TFLM_OVERLAYS);                           \
        do                                                   \
          echo "$$i";                                        \
          /bin/rm $(TFLM_BLD_DIR)/$$i;                       \
          ln -s $(TFLM_OVERLAY_DIR)/$$i $(TFLM_BLD_DIR)/$$i; \
        done

harness-clean:
	/bin/rm -rf $(HARNESS_DIR)
	-make -C $(TFLM_BLD_DIR) clean

clean-all:
	/bin/rm -rf $(BUILD)

renode: $(HARNESS_BIN)
	/bin/cp $(HARNESS_ELF) $(PROJ_DIR)/renode/
	pushd $(PROJ_DIR)/renode/ && renode -e "s @litex-vexriscv-cfu.resc" && popd


#
# Copy program sources and Makefile
# TODO(avg): cam will will fail now
#
cam:
	@echo building tflm harness app, under build/, for model $(MODEL)
	mkdir -p $(BUILD)/camera
	/bin/cp -r $(CAM_FILES) $(BUILD)/camera/
	pushd $(BUILD)/camera; make TFLM_DIR=$(TFLM_BLD_DIR) CFU_ROOT=$(CFU_REAL_ROOT); popd

loadcam:
	$(LXTERM) --speed $(UART_SPEED) $(CRC) --kernel $(BUILD)/camera/camera.bin /dev/ttyUSB1

ifeq '1' '$(words $(TTY))'
load: $(HARNESS_BIN)
	$(LXTERM) --speed $(UART_SPEED) $(CRC) --kernel $(HARNESS_BIN) $(TTY)

run: $(HARNESS_BIN)
	$(HARNESS_DIR)/interact.expect $(HARNESS_BIN) $(TTY) |& tee $(HARNESS_LOG)

else
load:
	@echo Error: could not determine unique TTY
	@echo TTY possibilities: $(TTY)

run:
	@echo Error: could not determine unique TTY
	@echo TTY possibilities: $(TTY)

endif


verilate: cfu.v $(VERILATOR_MAIN)
	verilator $(VERILATOR_LINT) -cc cfu.v --exe verilator_main.cpp --Mdir $(VERILATOR_DIR) --trace && \
	cp verilator_main.cpp $(VERILATOR_DIR) && \
	make TRACE=1 -C $(VERILATOR_DIR) -f Vcfu.mk && \
	./$(VERILATOR_DIR)/Vcfu

veri-clean:
	/bin/rm -rf ./$(VERILATOR_DIR) ./cfu.vcd

ls:
	ls -sAFC


clean:
	/bin/rm -rf ./build

proj:
	echo $(PROJ)
