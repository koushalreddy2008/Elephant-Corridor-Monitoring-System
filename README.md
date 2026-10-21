# Elephant Corridor Monitoring System
### Group Project & Case Study: Digital Logic Design & Computer Organization

---

## Group Members
| # | Name | Roll No. |
|:---:|:---|:---:|
| 1 | Your Name | B25XXXXXX |
| 2 | Team Member 2 | B25XXXXXX |
| 3 | Team Member 3 | B25XXXXXX |
| 4 | Team Member 4 | B25XXXXXX |
| 5 | Team Member 5 | B25XXXXXX |
| 6 | Team Member 6 | B25XXXXXX |

---

## What This Repository Contains
An integrated digital monitoring and early-warning cyber-physical system designed to mitigate human-elephant conflict (HEC) near agrarian settlements. It senses animal proximity, movement trajectory, velocity, and time-of-day, classifies location zones, activates acoustic and visual alarms when elephants approach human dwellings, tracks corridor crossing counts using digital counters, and uses an x86-64 assembly analytics engine to process historical movement telemetry.

| Deliverable | Path | Description |
|---|---|---|
| **Logisim Digital Circuit** | `circuit/elephant_corridor_monitor.circ` | Combinational & sequential logic circuit |
| **Circuit Pinout & Specs** | `circuit/README.md` | Input bit-widths, output pin mappings & logic truth tables |
| **Logisim Test Vectors** | `circuit/elephant_corridor_vectors.txt` | Automated test vectors covering normal & conflict edge cases |
| **x86-64 Assembly Program** | `asm/elephant_report.asm` | Low-level data analysis & conflict reporting routine |
| **Shared Thresholds** | `asm/thresholds.inc` | Unified thresholds shared by hardware logic & software |
| **Recorded Movement Data** | `data/elephant_readings.csv` | Historical telemetry records (corridor, hour, speed, distance) |
| **Low-Activity Baseline Data**| `data/elephant_readings_quiet.csv` | Control dataset with minimal corridor movement |
| **Generated Conflict Report** | `out/conflict_report.txt` | Human-wildlife conflict assessment report |
| **System Architecture Guide** | `docs/ARCHITECTURE.md` | Deep dive into hardware logic, truth tables & register maps |
| **Written Project Report** | `docs/PROJECT_REPORT.md` | Academic submission report template |
| **Reference Python Engine** | `tools/reference_model.py` | Mathematical verification model & report generator |
| **Vector Generator** | `tools/gen_vectors.py` | Automated generator for Logisim test vectors |

---

## Quick Start

### 1. Build and Run the Software Analytics Engine
```bash
# Build the assembly executable
make

# Run the analytics engine
make run

# Run automated validation (generates vectors & checks reference parity)
make check
```

### 2. Simulate the Digital Circuit in Logisim-Evolution
Open the digital circuit in Logisim-Evolution:
```bash
logisim-evolution circuit/elephant_corridor_monitor.circ
```
In Logisim-Evolution:
1. Go to **Simulate** &rarr; **Test Vector...**
2. Load `circuit/elephant_corridor_vectors.txt`.
3. Verify that all test vectors pass with green indications.

---

## How the Pieces Fit Together

```
[LIVE HARDWARE PIPELINE]
Four Digital Inputs
  ├─ Proximity [3..0]  ──┐
  ├─ Direction [1..0]  ──┼──► Comparators & Logic Gates ──► Alert LEDs (Safe/Watch/Danger)
  ├─ Speed [3..0]      ──┤                                ├─ Audio Siren / Buzzer
  └─ Time-of-Day [0]   ──┘                                └─ Animal Location Display (7-Segment)
Crossing Beam Sensor   ──────► 2-to-4 Decoder ────────────► 4x Corridor Crossing Counters (8-bit)

[HISTORICAL SOFTWARE PIPELINE]
Recorded CSV Logs      ──────► x86-64 Assembly Engine  ───► Formal Incident Report (out/conflict_report.txt)
                               (asm/elephant_report.asm)     - Most frequently used corridor
                                                             - Average & max movement speed
                                                             - Peak activity time periods
                                                             - Risk assessment & warnings
```

Both halves read the exact same threshold definitions (`asm/thresholds.inc`), ensuring the digital circuit and the assembly analytics software are in 100% agreement on danger criteria. An independent Python model (`tools/reference_model.py`) verifies both.

---

## Current Status
- **Logisim Test Vectors**: `10 / 10` test cases pass
- **Assembly Historical Engine**: Bit-exact parity with Python analytical reference model
- **Corridor Bottleneck Identified**: Corridor #2 (8 detections, 3 crossings)
- **High-Risk Window**: Nocturnal period (22:00 – 06:00) with 47% of total movement
- **Overall Verdict on Active Dataset**: `HIGH ALERT` (6 imminent village border incursions recorded)

---

## Prerequisites
Before running or building the project, ensure you have:
1. **Python 3.8+** (for reference modeling and vector generation)
2. **NASM 2.15+** (Netwide Assembler for x86-64)
3. **GNU `ld` / standard build tools** (`make`)
4. **Logisim-Evolution 3.8.0+** to inspect and simulate the `.circ` schematic
