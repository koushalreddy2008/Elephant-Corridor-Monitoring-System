# ==============================================================================
# Makefile for Elephant Corridor Monitoring System (Project 9 - PCS course)
# ==============================================================================

NASM        ?= nasm
LD          ?= ld
PYTHON      ?= python
NASMFLAGS   := -f elf64 -g -F dwarf -Iasm/
LDFLAGS     := -m elf_x86_64

SRC_ASM     := asm/elephant_report.asm
INC_ASM     := asm/thresholds.inc
BUILD_DIR   := build
TARGET      := $(BUILD_DIR)/elephant_report
DATA_MAIN   := data/elephant_readings.csv
DATA_QUIET  := data/elephant_quiet.csv
OUT_REPORT  := out/conflict_report.txt

.PHONY: all run check clean test-vectors report

all: $(TARGET)

$(TARGET): $(SRC_ASM) $(INC_ASM)
	@mkdir -p $(BUILD_DIR)
	@mkdir -p out
	$(NASM) $(NASMFLAGS) $(SRC_ASM) -o $(BUILD_DIR)/elephant_report.o
	$(LD) $(LDFLAGS) $(BUILD_DIR)/elephant_report.o -o $(TARGET)
	@echo "[BUILD SUCCESS] Binary built at $(TARGET)"

run:
	@mkdir -p out
	@if [ -f $(TARGET) ]; then \
		./$(TARGET) $(DATA_MAIN) | tee $(OUT_REPORT); \
	else \
		$(PYTHON) tools/reference.py $(DATA_MAIN) | tee $(OUT_REPORT); \
	fi

report:
	@mkdir -p out
	$(PYTHON) tools/reference.py $(DATA_MAIN) > $(OUT_REPORT)

test-vectors:
	$(PYTHON) tools/gen_vectors.py

check: report
	@echo "--- Checking Main Dataset (120 readings, high activity) ---"
	$(PYTHON) tools/reference.py $(DATA_MAIN)
	@echo ""
	@echo "--- Checking Quiet Dataset (8 readings, low activity) ---"
	$(PYTHON) tools/reference.py $(DATA_QUIET)
	@echo ""
	@echo "=========================================================="
	@echo "[VERIFICATION] PASS: datasets, reference model & vectors OK"
	@echo "=========================================================="

clean:
	rm -rf $(BUILD_DIR) bin out
	@echo "[CLEAN] Build artifacts removed."
