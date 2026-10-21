# Project Report: Elephant Corridor Monitoring System

## Group Information
- **Course**: Computer Organization & Digital Logic Design
- **Project Topic**: Elephant Corridor Monitoring & Conflict Mitigation System

| S.No | Name | Roll Number | Contribution |
|---|---|---|---|
| 1 | Student 1 | B25XXXXXX | Digital Logic Design & Logisim Implementation |
| 2 | Student 2 | B25XXXXXX | x86-64 Assembly Historical Data Analysis Engine |
| 3 | Student 3 | B25XXXXXX | Circuit Simulation & Test Vector Validation |
| 4 | Student 4 | B25XXXXXX | Data Pipeline & Python Reference Modeling |
| 5 | Student 5 | B25XXXXXX | Report Writing, Documentation & Hardware Mapping |

---

## 1. Abstract
Human-elephant conflict (HEC) presents serious safety hazards to agrarian communities neighboring forested regions. This project implements a comprehensive two-tier monitoring solution: a real-time digital logic circuit that senses animal proximity, movement trajectory, and speed to dispatch acoustic and visual warnings, and a low-level x86-64 assembly analytics engine that processes historical telemetry logs to identify corridor bottlenecks, nocturnal peaks, and kinematic extremes.

---

## 2. Problem Statement & Functional Requirements
As specified in the system design rubric:
1. **Digital Inputs**: Represent animal proximity (4 bits), direction (2 bits), velocity (4 bits), and time-of-day (1 bit).
2. **Danger Detection**: Determine when an animal breaches the human-settlement buffer zone heading village-ward.
3. **Warning Signals**: Trigger multi-color status indicators and acoustic alarms.
4. **Hardware Counters**: Log sequential crossing events per corridor.
5. **Location Status**: Drive displays indicating animal proximity zones.
6. **Assembly Analysis**:
   - Ingest historical logs.
   - Identify the most frequently traversed corridor.
   - Calculate average and peak velocities.
   - Bin high-activity time windows.
   - Formulate a human-wildlife conflict assessment report.

---

## 3. Circuit Implementation & Truth Logic
*(Detailed schematic diagrams and pin configurations can be referenced in `circuit/elephant_corridor_monitor.circ` and `docs/ARCHITECTURE.md`)*.

---

## 4. Assembly Engine & Data Flow
*(Detailed register mapping and algorithmic pseudo-code can be referenced in `asm/elephant_report.asm`)*.

---

## 5. Simulation Results & Verification
- **Logisim Test Vectors**: Verified against 10 comprehensive edge cases in `circuit/elephant_corridor_vectors.txt` with zero discrepancies.
- **Assembly vs Python Reference Model**: Bit-exact parity achieved between `tools/reference_model.py` and compiled x86-64 binary output.

---

## 6. Conclusion
The dual-tier digital monitoring approach delivers both millisecond-level responsiveness for immediate threat warning and high-throughput computational analytics for environmental planning and wildlife management.
