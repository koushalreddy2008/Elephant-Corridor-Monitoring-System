# Elephant Corridor Monitoring - Digital Circuit Subsystem

This directory contains the Logisim-Evolution digital design for the **Elephant Corridor Monitoring System**.

## Files
- `elephant_corridor_monitor.circ`: Primary Logisim-Evolution circuit file.
- `elephant_corridor_vectors.txt`: Standard test vectors to verify circuit behavior against truth specifications.

## Digital Inputs & Bit Widths
| Input Signal | Bit Width | Description |
|---|---|---|
| `Proximity[3..0]` | 4 bits | Distance level to settlement (0: 0-100m, ..., 15: >1500m) |
| `Direction[1..0]` | 2 bits | `00`=Toward Village, `01`=Away, `10`=Parallel, `11`=Crossing |
| `Speed[3..0]` | 4 bits | Movement speed in km/h (0 to 15) |
| `TimeOfDay` | 1 bit | `0` = Daylight, `1` = Night |
| `CorridorSelect[1..0]` | 2 bits | Corridor ID: 00 (C1), 01 (C2), 10 (C3), 11 (C4) |
| `CrossingPulse` | 1 bit | Trigger pulse from beam/PIR sensor on corridor line |
| `CLK` & `RESET` | 1 bit each | Global clock & reset for counters |

## Outputs & Indicators
| Output Signal | Component | Indication |
|---|---|---|
| `LED_GREEN` | Output Pin / Green LED | Safe: Animal at safe distance or moving away |
| `LED_YELLOW` | Output Pin / Yellow LED | Watch: Animal inside corridor or buffer zone |
| `LED_RED` | Output Pin / Red LED | Danger: Animal entering human-settlement danger zone |
| `BUZZER_ALARM` | Output Pin / Audio Buzzer | High-frequency alert for nearby residents |
| `ZoneDisplay[1..0]` | 7-Segment / Status LEDs | Current animal location: 00 (Border), 01 (Danger Zone), 10 (Buffer), 11 (Safe Forest) |
| `Counter_C1..C4[7..0]` | 8-bit Register Counters | Running count of elephant crossings per corridor |
