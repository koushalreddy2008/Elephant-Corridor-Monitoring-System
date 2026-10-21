B = build
NASM  = nasm -f elf64 -g -F dwarf -I asm/
DATA  = data/elephant_readings.csv data/elephant_quiet.csv

.PHONY: all run check clean

all: $(B)/elephant_report

$(B)/elephant_report: asm/elephant_report.asm asm/thresholds.inc
	mkdir -p $(B) out
	$(NASM) asm/elephant_report.asm -o $(B)/elephant_report.o
	ld -o $@ $(B)/elephant_report.o

run: all
	$(B)/elephant_report data/elephant_readings.csv | tee out/conflict_report.txt

check: all
	@for f in $(DATA); do \
	  $(B)/elephant_report $$f > $(B)/asm.out; \
	  python3 tools/reference.py $$f > $(B)/ref.out; \
	  if diff -q $(B)/asm.out $(B)/ref.out >/dev/null; then \
	    echo "PASS  $$f"; \
	    rm -f $(B)/asm.out $(B)/ref.out; \
	  else \
	    echo "FAIL  $$f"; \
	    diff $(B)/asm.out $(B)/ref.out; \
	    exit 1; \
	  fi; \
	done

clean:
	rm -rf $(B)
