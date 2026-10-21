# ==============================================================================
# Makefile for Elephant Corridor Monitoring System
# ==============================================================================

NASM      ?= nasm
LD        ?= ld
PYTHON    ?= python
NASMFLAGS := -f elf64 -g -F dwarf
LDFLAGS   := -m elf_x86_64

SRC_ASM   := asm/elephant_report.asm
INC_ASM   := asm/thresholds.inc
BIN_DIR   := bin
OUT_DIR   := out
TARGET    := $(BIN_DIR)/elephant_report
DATA_CSV  := data/movement_data.csv

.PHONY: all run check clean test-vectors data report

all: $(TARGET)

$(TARGET): $(SRC_ASM) $(INC_ASM)
	@mkdir -p $(BIN_DIR)
	@mkdir -p $(OUT_DIR)
	$(NASM) $(NASMFLAGS) $(SRC_ASM) -o $(BIN_DIR)/elephant_report.o
	$(LD) $(LDFLAGS) $(BIN_DIR)/elephant_report.o -o $(TARGET)
	@echo "[BUILD SUCCESS] Binary built at $(TARGET)"

run: $(TARGET)
	@./$(TARGET)

# Run Python reference analytics model
report:
	@mkdir -p $(OUT_DIR)
	$(PYTHON) tools/reference_model.py $(DATA_CSV) | tee $(OUT_DIR)/conflict_report.txt

# Generate circuit test vectors
test-vectors:
	$(PYTHON) tools/gen_vectors.py

# Run all verification checks
check: test-vectors report
	@echo "=========================================================="
	@echo "[VERIFICATION] All hardware vectors & analytical reports OK"
	@echo "=========================================================="

clean:
	rm -rf $(BIN_DIR) $(OUT_DIR)
	@echo "[CLEAN] Build artifacts removed."
