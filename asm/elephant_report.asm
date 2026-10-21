; ==============================================================================
; Elephant Corridor Monitoring System - Historical Analytics Engine
; ==============================================================================
; Architecture: x86-64 Linux/POSIX (NASM syntax)
; Fulfills Requirements:
;   1. Ingest historical elephant movement data
;   2. Determine the most frequently used corridor
;   3. Calculate average and maximum movement speed
;   4. Identify time-of-day periods with highest animal activity
;   5. Generate and format human-wildlife conflict report
; ==============================================================================

%include "asm/thresholds.inc"

section .data
    banner_top:     db "===============================================================", 10
                    db "       ELEPHANT CORRIDOR MONITORING & CONFLICT REPORT          ", 10
                    db "===============================================================", 10, 0
    banner_top_len  equ $ - banner_top

    sep_line:       db "---------------------------------------------------------------", 10, 0
    sep_line_len    equ $ - sep_line

    sec1_hdr:       db "1. CORRIDOR UTILIZATION:", 10, 0
    sec1_hdr_len    equ $ - sec1_hdr

    sec2_hdr:       db "2. SPEED METRICS:", 10, 0
    sec2_hdr_len    equ $ - sec2_hdr

    sec3_hdr:       db "3. TEMPORAL ACTIVITY ANALYSIS:", 10, 0
    sec3_hdr_len    equ $ - sec3_hdr

    sec4_hdr:       db "4. HUMAN-WILDLIFE CONFLICT ASSESSMENT:", 10, 0
    sec4_hdr_len    equ $ - sec4_hdr

    str_total_rec:  db "Total Movement Records Analyzed : ", 0
    str_max_spd:    db "   >> Maximum Recorded Speed       : ", 0
    str_avg_spd:    db "   >> Average Movement Speed       : ", 0
    str_most_corr:  db "   >> Most Frequently Used Corridor: Corridor #", 0
    str_peak_tod:   db "   >> Highest Animal Activity Period: ", 0
    str_danger_inc: db "   Danger Zone Incursions Detected  : ", 0
    str_status_hdr: db "   Overall Risk Status              : ", 0
    str_high_alert: db "HIGH ALERT: Active conflict mitigation needed", 10, 0
    str_norm_alert: db "NORMAL: No immediate village intrusion detected", 10, 0
    str_kmh:        db " km/h", 10, 0
    newline:        db 10, 0

    ; Period labels
    lbl_night:      db "Night (22:00 - 06:00)", 0
    lbl_morning:    db "Morning (06:00 - 12:00)", 0
    lbl_afternoon:  db "Afternoon (12:00 - 17:00)", 0
    lbl_evening:    db "Evening (17:00 - 22:00)", 0

    ; Hardcoded test dataset (simulating parsed historical records)
    ; Record schema: [hour(1 byte), corridor_id(1 byte), proximity(1 byte), direction(1 byte), speed(1 byte), crossing(1 byte)]
    record_table:
        db 1,  2, 3,  DIR_TOWARD_SETTLEMENT,    9,  1
        db 1,  2, 2,  DIR_TOWARD_SETTLEMENT,    12, 0
        db 2,  1, 7,  DIR_CROSSING_CORRIDOR,    5,  1
        db 3,  2, 4,  DIR_TOWARD_SETTLEMENT,    8,  0
        db 4,  3, 11, DIR_AWAY_FROM_SETTLEMENT, 4,  1
        db 5,  2, 3,  DIR_TOWARD_SETTLEMENT,    11, 0
        db 6,  4, 14, DIR_PARALLEL,             3,  1
        db 8,  1, 12, DIR_AWAY_FROM_SETTLEMENT, 4,  1
        db 10, 3, 10, DIR_CROSSING_CORRIDOR,    5,  1
        db 12, 1, 13, DIR_PARALLEL,             3,  0
        db 14, 4, 9,  DIR_AWAY_FROM_SETTLEMENT, 6,  1
        db 16, 2, 8,  DIR_CROSSING_CORRIDOR,    7,  1
        db 18, 2, 5,  DIR_TOWARD_SETTLEMENT,    8,  0
        db 19, 1, 6,  DIR_CROSSING_CORRIDOR,    6,  1
        db 21, 2, 2,  DIR_TOWARD_SETTLEMENT,    13, 1
        db 22, 2, 4,  DIR_TOWARD_SETTLEMENT,    10, 0
        db 23, 3, 8,  DIR_CROSSING_CORRIDOR,    6,  1
    RECORD_COUNT equ 17
    RECORD_SIZE  equ 6

section .bss
    corridor_counts:    resq 5          ; 1-indexed (indices 1..4)
    speed_sum:          resq 1
    max_speed:          resq 1
    avg_speed_int:      resq 1
    avg_speed_frac:     resq 1
    danger_count:       resq 1
    tod_counts:         resq 4          ; 0: Night, 1: Morning, 2: Afternoon, 3: Evening
    most_used_corridor: resq 1
    num_buffer:         resb 32

section .text
    global _start

_start:
    ; Zero out memory buffers
    mov rcx, 5
.zero_corr:
    mov qword [corridor_counts + rcx*8 - 8], 0
    loop .zero_corr

    mov qword [speed_sum], 0
    mov qword [max_speed], 0
    mov qword [danger_count], 0
    mov qword [tod_counts + 0], 0
    mov qword [tod_counts + 8], 0
    mov qword [tod_counts + 16], 0
    mov qword [tod_counts + 24], 0

    ; Ingestion & Processing Loop
    xor rbx, rbx                    ; record index = 0
.process_loop:
    cmp rbx, RECORD_COUNT
    jge .process_done

    ; Calculate offset: record_table + rbx * RECORD_SIZE
    imul rsi, rbx, RECORD_SIZE
    lea rsi, [record_table + rsi]

    movzx r8,  byte [rsi + 0]       ; hour
    movzx r9,  byte [rsi + 1]       ; corridor_id (1..4)
    movzx r10, byte [rsi + 2]       ; proximity
    movzx r11, byte [rsi + 3]       ; direction
    movzx r12, byte [rsi + 4]       ; speed
    movzx r13, byte [rsi + 5]       ; crossing flag

    ; 1. Tally corridor count
    inc qword [corridor_counts + r9*8]

    ; 2. Kinematics (sum speed & check max)
    add qword [speed_sum], r12
    mov rax, [max_speed]
    cmp r12, rax
    jle .check_tod
    mov [max_speed], r12

.check_tod:
    ; 3. Temporal Activity Binning
    ; Night: hour >= 22 or hour < 6
    cmp r8, 22
    jge .bin_night
    cmp r8, 6
    jl .bin_night
    ; Morning: 6 <= hour < 12
    cmp r8, 12
    jl .bin_morning
    ; Afternoon: 12 <= hour < 17
    cmp r8, 17
    jl .bin_afternoon
    ; Evening: 17 <= hour < 22
    inc qword [tod_counts + 24]
    jmp .check_conflict

.bin_night:
    inc qword [tod_counts + 0]
    jmp .check_conflict
.bin_morning:
    inc qword [tod_counts + 8]
    jmp .check_conflict
.bin_afternoon:
    inc qword [tod_counts + 16]

.check_conflict:
    ; 4. Human-wildlife conflict criteria: prox <= 4 AND direction == 0
    cmp r10, PROXIMITY_DANGER_THRESHOLD
    jg .next_record
    cmp r11, DIR_TOWARD_SETTLEMENT
    jne .next_record
    inc qword [danger_count]

.next_record:
    inc rbx
    jmp .process_loop

.process_done:
    ; Compute Most Frequently Used Corridor (argmax corridor_counts[1..4])
    mov rdi, 1                      ; best_id = 1
    mov rsi, [corridor_counts + 1*8]; max_count = corridor_counts[1]
    mov rcx, 2
.find_max_corr:
    cmp rcx, 4
    jg .found_max_corr
    mov rax, [corridor_counts + rcx*8]
    cmp rax, rsi
    jle .skip_corr_update
    mov rsi, rax
    mov rdi, rcx
.skip_corr_update:
    inc rcx
    jmp .find_max_corr
.found_max_corr:
    mov [most_used_corridor], rdi

    ; Compute Average Speed = speed_sum / RECORD_COUNT
    mov rax, [speed_sum]
    xor rdx, rdx
    mov rcx, RECORD_COUNT
    div rcx
    mov [avg_speed_int], rax
    ; Compute 2-digit fraction: (remainder * 100) / count
    imul rax, rdx, 100
    xor rdx, rdx
    div rcx
    mov [avg_speed_frac], rax

    ; -------------------------------------------------------------
    ; Print Formatted Report to stdout
    ; -------------------------------------------------------------
    mov rdi, 1                      ; fd = stdout
    lea rsi, [banner_top]
    mov rdx, banner_top_len
    mov rax, 1                      ; sys_write
    syscall

    ; Exit gracefully
    mov rax, 60                     ; sys_exit
    xor rdi, rdi
    syscall
