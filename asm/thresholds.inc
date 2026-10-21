; ==============================================================================
; Elephant Corridor Monitoring System - Shared Thresholds & Constants
; ==============================================================================
; Both the Logisim digital circuit and the x86-64 assembly program reference 
; these identical values to ensure unified conflict detection rules.
; ==============================================================================

; --- Proximity Zones (4-bit value: 0 to 15, lower means closer to human settlements)
PROXIMITY_DANGER_THRESHOLD  equ 4       ; <= 4 indicates elephant in immediate danger zone (< 400m)
PROXIMITY_WATCH_THRESHOLD   equ 8       ; 5 - 8 indicates watch zone (buffer zone, 500m - 800m)
PROXIMITY_SAFE_THRESHOLD    equ 15      ; > 8 indicates safe forest corridor

; --- Movement Direction Codes (2-bit digital input)
DIR_TOWARD_SETTLEMENT       equ 0       ; 00b: Moving directly toward human settlement
DIR_AWAY_FROM_SETTLEMENT    equ 1       ; 01b: Moving away from human settlement
DIR_PARALLEL                equ 2       ; 10b: Moving parallel to settlement boundary
DIR_CROSSING_CORRIDOR       equ 3       ; 11b: Crossing through dedicated corridor path

; --- Movement Speed (4-bit km/h: 0 to 15)
SPEED_NORMAL_MAX            equ 6       ; <= 6 km/h: Normal grazing / foraging speed
SPEED_FAST_THRESHOLD        equ 9       ; 7 - 9 km/h: Rapid movement / marching
SPEED_CHARGE_THRESHOLD      equ 10      ; >= 10 km/h: High speed / stampede / charge

; --- Time of Day Bins (2-bit / 4-bit)
TOD_NIGHT_FLAG              equ 1       ; Night hours (elevated risk due to low human visibility)
TOD_DAY_FLAG                equ 0       ; Daylight hours

; --- Corridors
TOTAL_CORRIDORS             equ 4       ; Corridor 1, Corridor 2, Corridor 3, Corridor 4
CORRIDOR_1                  equ 1
CORRIDOR_2                  equ 2
CORRIDOR_3                  equ 3
CORRIDOR_4                  equ 4

; --- Warning Alert Levels
ALERT_NORMAL                equ 0       ; Green LED: All clear
ALERT_WATCH                 equ 1       ; Yellow LED: Animal active in corridor/buffer
ALERT_DANGER                equ 2       ; Red LED + Siren: Imminent human-wildlife conflict
