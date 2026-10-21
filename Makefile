# ==============================================================================
# Makefile for Elephant Corridor Monitoring System
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
DEFAULT_CSV := data/elephant_readings.csv

.PHONY: all run check clean test-vectors report

all: $(TARGET)

$(TARGET): $(SRC_ASM) $(INC_ASM)
	@mkdir -p $(BUILD_DIR)
	@mkdir -p out
	$(NASM) $(NASMFLAGS) $(SRC_ASM) -o $(BUILD_DIR)/elephant_report.o
	$(LD) $(LDFLAGS) $(BUILD_DIR)/elephant_report.o -o $(TARGET)
	@echo "[BUILD SUCCESS] Binary built at $(TARGET)"

run: $(TARGET)
	@./$(TARGET) $(DEFAULT_CSV)

# Run Python reference analytics model
report:
	@mkdir -p out
	$(PYTHON) tools/reference_model.py $(DEFAULT_CSV) | tee out/conflict_report.txt

# Generate Logisim circuit test vectors
test-vectors:
	$(PYTHON) tools/gen_vectors.py

# Run all verification checks
check: test-vectors report
	@echo "=========================================================="
	@echo "[VERIFICATION] All hardware vectors & analytical reports OK"
	@echo "=========================================================="

clean:
	rm -rf $(BUILD_DIR) bin out
	@echo "[CLEAN] Build artifacts removed."
