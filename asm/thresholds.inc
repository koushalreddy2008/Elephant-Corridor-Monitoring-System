; ==============================================================================
; Elephant Corridor Monitoring System - Shared Thresholds & Constants
; ==============================================================================
; Both the Logisim digital circuit and the x86-64 assembly program reference 
; these identical values to ensure unified conflict detection rules.
; ==============================================================================

; --- Software Buffer & Pipeline Sizing
MAX_FILE_BYTES              equ 65536   ; 64 KB maximum CSV ingestion buffer

; --- Corridors
NUM_CORRIDORS               equ 4       ; Corridors: 0=A, 1=B, 2=C, 3=D
TOTAL_CORRIDORS             equ 4
CORRIDOR_A                  equ 0
CORRIDOR_B                  equ 1
CORRIDOR_C                  equ 2
CORRIDOR_D                  equ 3

; --- Proximity & Distance Thresholds
DANGER_DIST_M               equ 500     ; <= 500 meters is within settlement danger zone
WATCH_DIST_M                equ 800     ; 501 - 800 meters is watch / buffer zone
SAFE_DIST_M                 equ 1500    ; > 800 meters is safe forest

; 4-bit bus equivalent (for Logisim digital circuit: 0 to 15, lower = closer)
PROXIMITY_DANGER_THRESHOLD  equ 4       ; <= 4 indicates elephant in immediate danger zone (< 400m)
PROXIMITY_WATCH_THRESHOLD   equ 8       ; 5 - 8 indicates watch zone (buffer zone, 500m - 800m)
PROXIMITY_SAFE_THRESHOLD    equ 15      ; > 8 indicates safe forest corridor

; --- Temporal Risk Bins (24-hour clock)
NIGHT_START_HR              equ 18      ; 18:00 (6 PM) - night monitoring starts
NIGHT_END_HR                equ 6       ; 06:00 (6 AM) - day monitoring starts
TOD_NIGHT_FLAG              equ 1       ; 1-bit hardware flag: Night
TOD_DAY_FLAG                equ 0       ; 1-bit hardware flag: Day

; --- Movement Direction Codes (2-bit digital input)
DIR_TOWARD_SETTLEMENT       equ 0       ; 00b: Moving directly toward human settlement
DIR_AWAY_FROM_SETTLEMENT    equ 1       ; 01b: Moving away from human settlement
DIR_PARALLEL                equ 2       ; 10b: Moving parallel to settlement boundary
DIR_CROSSING_CORRIDOR       equ 3       ; 11b: Crossing through dedicated corridor path

; --- Movement Speed (km/h)
SPEED_NORMAL_MAX            equ 6       ; <= 6 km/h: Normal grazing / foraging speed
SPEED_FAST_THRESHOLD        equ 9       ; 7 - 9 km/h: Rapid movement / marching
SPEED_CHARGE_THRESHOLD      equ 10      ; >= 10 km/h: High speed / stampede / charge

; --- Conflict Risk Assessment Levels (Percentage of danger zone incursions)
HIGH_RISK_PCT               equ 30      ; >= 30% danger-zone readings -> HIGH RISK (EMERGENCY)
MED_RISK_PCT                equ 10      ; >= 10% danger-zone readings -> MEDIUM RISK (WARNING)
                                        ; < 10% -> LOW RISK (NORMAL)

; --- Hardware Warning Alert Levels
ALERT_NORMAL                equ 0       ; Green LED: All clear
ALERT_WATCH                 equ 1       ; Yellow LED: Animal active in corridor/buffer
ALERT_DANGER                equ 2       ; Red LED + Siren: Imminent human-wildlife conflict
