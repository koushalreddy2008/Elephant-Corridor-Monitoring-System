# Elephant Corridor Monitoring System - Architecture Specification

## 1. System Overview
The **Elephant Corridor Monitoring System** is an integrated cyber-physical early warning system designed to mitigate human-elephant conflict (HEC) near forest fringe settlements. 

The architecture is divided into two cooperative subsystems:
1. **Live Digital Hardware Monitoring Circuit (`circuit/`)**: Real-time combinational and sequential logic implemented in Logisim-Evolution. It decodes live sensor signals (proximity, direction, speed, time-of-day), triggers optical and acoustic alerts for villagers, and maintains hardware crossing tallies.
2. **Historical Movement & Conflict Analytical Software (`asm/`)**: An optimized x86-64 assembly routine designed to process batch telemetry logs, computing usage frequencies, movement kinematics (average and peak speeds), nocturnal activity distributions, and producing formal incident reports.

---

## 2. Hardware Subsystem (Logisim Digital Logic)

```
                       DIGITAL INPUT BUSES
   ┌─────────────────────────────────────────────────────────────┐
   │ Proximity [3..0]  Direction [1..0]  Speed [3..0]  TOD [0]   │
   └────────┬─────────────────┬──────────────┬────────────┬──────┘
            │                 │              │            │
            ▼                 ▼              ▼            ▼
   ┌─────────────────────────────────────────────────────────────┐
   │               ZONE CLASSIFIER & COMPARATORS                 │
   │  - Danger Comparator: Proximity <= 4                        │
   │  - Buffer Comparator: 4 < Proximity <= 8                   │
   │  - Direction Decoder: 00b (Toward Settlement)               │
   │  - Speed Comparator: Speed >= 10 km/h (Charging)            │
   └──────────────────────────────┬──────────────────────────────┘
                                  │
         ┌────────────────────────┼────────────────────────┐
         ▼                        ▼                        ▼
  ┌───────────────┐       ┌───────────────┐        ┌──────────────┐
  │ DANGER LOGIC  │       │  WATCH LOGIC  │        │  SAFE LOGIC  │
  └──────┬────────┘       └───────┬───────┘        └──────┬───────┘
         │                        │                       │
         ▼                        ▼                       ▼
  [RED LED + SIREN]         [YELLOW LED]             [GREEN LED]
         │
         ▼
  [ZONE STATUS DISPLAY (7-SEGMENT / LED BAR)]
```

### Digital Input Encoding
- **Proximity Sensor Bus (`Proximity[3..0]`)**: 4-bit unsigned integer (0–15).
  - `0 - 2`: Village Perimeter (<200m)
  - `3 - 4`: Immediate Danger Zone (200m - 400m)
  - `5 - 8`: Buffer Zone (500m - 800m)
  - `9 - 15`: Safe Forest Sanctuary (>800m)
- **Movement Direction Bus (`Direction[1..0]`)**: 2-bit code.
  - `00b`: Moving toward human settlement
  - `01b`: Moving away from human settlement
  - `10b`: Moving parallel along forest edge
  - `11b`: Crossing marked wildlife corridor
- **Movement Speed Bus (`Speed[3..0]`)**: 4-bit unsigned integer (km/h, 0–15).
  - `0 - 6`: Foraging / Walking
  - `7 - 9`: Rapid migration
  - `>= 10`: High-speed charge / panic stampede
- **Time of Day Flag (`TOD`)**: 1-bit signal (`0` = Daylight, `1` = Night).

### Sequential Logic (Corridor Counters)
- Four independent 8-bit digital counters track physical crossings across four distinct corridors ($C_1, C_2, C_3, C_4$).
- Each crossing beam interruption generates an edge-triggered `CLK` pulse routed via a 2-to-4 decoder to the designated corridor counter.

---

## 3. Software Subsystem (x86-64 Assembly Routine)

### Operational Flow
1. **Data Ingestion**: Parses record rows from `data/movement_data.csv`.
2. **Frequency Histogram**: Accumulates crossings per corridor index into memory arrays `corridor_counts` ($C_1 \dots C_4$).
3. **Kinematic Computation**:
   - Compares current speed against `max_speed` register.
   - Accumulates total velocity into 64-bit sum accumulator (`rax`), dividing by sample count to compute `avg_speed`.
4. **Temporal Classification**: Bins events into 4 time buckets (Night, Morning, Afternoon, Evening) based on hour timestamp.
5. **Report Generation**: Formats findings and writes structured conflict intelligence to `out/conflict_report.txt` using POSIX syscalls (`sys_write`, `sys_open`).

---

## 4. Hardware-Software Consistency
Both subsystems conform strictly to parameters defined in `asm/thresholds.inc`. 
The Python model in `tools/reference_model.py` and test generator `tools/gen_vectors.py` provide mathematical verification ensuring 100% agreement across circuit simulation and binary execution.
