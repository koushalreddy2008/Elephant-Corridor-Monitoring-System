; ============================================================================
; elephant_report.asm  -  Elephant Corridor Monitoring System (software half)
; x86-64 Linux, NASM.  No libc: only raw syscalls.
;
; Reads a CSV of historical elephant sightings:
;     id,corridor,hour,speed_kmh,distance_m,direction
; and prints a human-wildlife conflict report:
;     * crossings per corridor + most frequently used corridor
;     * average and maximum movement speed
;     * hour / period with the highest animal activity
;     * danger-zone entries (distance <= DANGER_DIST_M) and risk level
;
; Usage:  ./build/elephant_report [csv_file]    (default data/elephant_readings.csv)
; ============================================================================
%include "thresholds.inc"

SYS_READ   equ 0
SYS_WRITE  equ 1
SYS_OPEN   equ 2
SYS_CLOSE  equ 3
SYS_EXIT   equ 60

%macro STR 2+                       ; STR label, "text", 10
%1:      db %2
%1_len   equ $ - %1
%endmacro

%macro PRINT 1                      ; print a STR constant
    mov  rsi, %1
    mov  rdx, %1_len
    call print_str
%endmacro

section .data
default_path: db "data/elephant_readings.csv", 0

STR s_line,    "==============================================================", 10
STR s_title,   "   ELEPHANT CORRIDOR MONITORING - HUMAN-WILDLIFE CONFLICT REPORT", 10
STR s_total,   "Readings analysed          : "
STR s_cross,   "Corridor crossings (readings per corridor):", 10
STR s_corr,    "  Corridor "
STR s_colon,   " : "
STR s_dz,      "   (danger-zone entries: "
STR s_rpar,    ")", 10
STR s_topcor,  "Most frequently used corridor : Corridor "
STR s_with,    "  ("
STR s_cr,      " crossings)", 10
STR s_avg,     "Average movement speed       : "
STR s_max,     "Maximum movement speed       : "
STR s_kmh,     " km/h", 10
STR s_peakh,   "Peak activity hour           : "
STR s_00,      ":00 - "
STR s_59,      ":59  ("
STR s_rd,      " readings)", 10
STR s_peakp,   "Peak activity period         : "
STR s_night,   "Night      00:00-05:59", 10
STR s_morn,    "Morning    06:00-11:59", 10
STR s_aft,     "Afternoon  12:00-17:59", 10
STR s_eve,     "Evening    18:00-23:59", 10
STR s_dzone,   "Danger-zone entries         : "
STR s_pct1,    "  ("
STR s_pct2,    " % of all readings)", 10
STR s_nightdz, "  of which at night (18-06h) : "
STR s_risk,    "Conflict risk level          : "
STR s_high,    "HIGH   -> EMERGENCY: alert residents, deploy forest-guard patrol", 10
STR s_med,     "MEDIUM -> WARNING: sound siren at night, restrict movement near corridor", 10
STR s_low,     "LOW    -> NORMAL: routine monitoring only", 10
STR s_err,     "error: cannot open input file", 10
STR s_nl,      10
STR dot, "."

section .bss
buf:         resb MAX_FILE_BYTES
numbuf:      resb 24
chbuf:       resb 4
corr_cnt:    resq NUM_CORRIDORS
corr_dz:     resq NUM_CORRIDORS
hour_cnt:    resq 24
period_cnt:  resq 4
total:       resq 1
sum_speed:   resq 1
max_speed:   resq 1
dz_total:    resq 1
dz_night:    resq 1
best_val:    resq 1
best_idx:    resq 1
tmp_a:       resq 1

section .text
global _start

; ---------------------------------------------------------------- _start ----
_start:
    mov  rax, [rsp]                 ; argc
    lea  rdi, [default_path]
    cmp  rax, 2
    jb   .open
    mov  rdi, [rsp + 16]            ; argv[1]
.open:
    mov  rax, SYS_OPEN
    xor  esi, esi                   ; O_RDONLY
    xor  edx, edx
    syscall
    test rax, rax
    js   .err
    mov  rbx, rax                   ; fd
    mov  rax, SYS_READ
    mov  rdi, rbx
    lea  rsi, [buf]
    mov  rdx, MAX_FILE_BYTES
    syscall
    mov  r12, rax                   ; bytes read
    mov  rax, SYS_CLOSE
    mov  rdi, rbx
    syscall
    test r12, r12
    jle  .err
    lea  rsi, [buf]
    add  r12, rsi                   ; r12 = end of data

    ; skip header line
.hdr:
    cmp  rsi, r12
    jae  .analysed
    cmp  byte [rsi], 10
    je   .hdr_done
    inc  rsi
    jmp  .hdr
.hdr_done:
    inc  rsi

; ------------------------------------------------------- parse every row ----
.row:
    call next_num                   ; id (ignored)
    test ecx, ecx
    jnz  .analysed
    call next_num                   ; corridor
    mov  r13, rax
    call next_num                   ; hour
    mov  r14, rax
    call next_num                   ; speed
    mov  r15, rax
    call next_num                   ; distance
    mov  rbx, rax
    call next_num                   ; direction (parsed, not needed for stats)
    test ecx, ecx
    jnz  .analysed

    cmp  r13, NUM_CORRIDORS         ; validate row
    jae  .row
    cmp  r14, 24
    jae  .row

    inc  qword [total]
    add  [sum_speed], r15
    cmp  r15, [max_speed]
    jbe  .nomax
    mov  [max_speed], r15
.nomax:
    inc  qword [corr_cnt + r13*8]
    inc  qword [hour_cnt + r14*8]
    mov  rax, r14                   ; period = hour / 6
    xor  edx, edx
    mov  ecx, 6
    div  rcx
    inc  qword [period_cnt + rax*8]

    cmp  rbx, DANGER_DIST_M         ; inside danger zone?
    ja   .row
    inc  qword [dz_total]
    inc  qword [corr_dz + r13*8]
    cmp  r14, NIGHT_START_HR        ; night = hour>=18 or hour<6
    jae  .is_night
    cmp  r14, NIGHT_END_HR
    jae  .row
.is_night:
    inc  qword [dz_night]
    jmp  .row

; ---------------------------------------------------------- print report ----
.analysed:
    cmp  qword [total], 0
    je   .err
    PRINT s_line
    PRINT s_title
    PRINT s_line
    PRINT s_total
    mov  rax, [total]
    call print_num
    PRINT s_nl

    PRINT s_cross
    xor  r14, r14
.cl:
    PRINT s_corr
    lea  rax, [r14 + 'A']
    call print_char
    PRINT s_colon
    mov  rax, [corr_cnt + r14*8]
    call print_num
    PRINT s_dz
    mov  rax, [corr_dz + r14*8]
    call print_num
    PRINT s_rpar
    inc  r14
    cmp  r14, NUM_CORRIDORS
    jb   .cl

    ; most used corridor
    lea  rdi, [corr_cnt]
    mov  ecx, NUM_CORRIDORS
    call argmax
    PRINT s_topcor
    mov  rax, [best_idx]
    add  rax, 'A'
    call print_char
    PRINT s_with
    mov  rax, [best_val]
    call print_num
    PRINT s_cr

    ; average speed with one decimal
    PRINT s_avg
    mov  rax, [sum_speed]
    xor  edx, edx
    mov  rcx, [total]
    div  rcx                        ; rax = int part, rdx = remainder
    mov  [tmp_a], rdx
    call print_num
    PRINT dot
    mov  rax, [tmp_a]
    imul rax, rax, 10
    xor  edx, edx
    mov  rcx, [total]
    div  rcx
    call print_num
    PRINT s_kmh

    PRINT s_max
    mov  rax, [max_speed]
    call print_num
    PRINT s_kmh

    ; peak hour
    lea  rdi, [hour_cnt]
    mov  ecx, 24
    call argmax
    PRINT s_peakh
    mov  rax, [best_idx]
    call print_num2
    PRINT s_00
    mov  rax, [best_idx]
    call print_num2
    PRINT s_59
    mov  rax, [best_val]
    call print_num
    PRINT s_rd

    ; peak period
    lea  rdi, [period_cnt]
    mov  ecx, 4
    call argmax
    PRINT s_peakp
    mov  rax, [best_idx]
    cmp  rax, 0
    je   .p0
    cmp  rax, 1
    je   .p1
    cmp  rax, 2
    je   .p2
    PRINT s_eve
    jmp  .pdone
.p0: PRINT s_night
    jmp  .pdone
.p1: PRINT s_morn
    jmp  .pdone
.p2: PRINT s_aft
.pdone:

    ; danger-zone summary
    PRINT s_dzone
    mov  rax, [dz_total]
    call print_num
    PRINT s_pct1
    mov  rax, [dz_total]
    imul rax, rax, 100
    xor  edx, edx
    mov  rcx, [total]
    div  rcx
    mov  r15, rax                   ; r15 = percentage (kept for risk level)
    call print_num
    PRINT s_pct2
    PRINT s_nightdz
    mov  rax, [dz_night]
    call print_num
    PRINT s_nl
    PRINT s_nl

    ; risk level
    PRINT s_risk
    cmp  r15, HIGH_RISK_PCT
    jae  .high
    cmp  r15, MED_RISK_PCT
    jae  .med
    PRINT s_low
    jmp  .end
.med:
    PRINT s_med
    jmp  .end
.high:
    PRINT s_high
.end:
    PRINT s_line
    xor  edi, edi
    mov  eax, SYS_EXIT
    syscall
.err:
    PRINT s_err
    mov  edi, 1
    mov  eax, SYS_EXIT
    syscall

; ----------------------------------------------------------- subroutines ----
; next_num: rsi = cursor, r12 = end.  Returns rax = next unsigned number,
;           ecx = 0 ok / 1 end-of-data.  Clobbers rax, rcx, rdx.
next_num:
.skip:
    cmp  rsi, r12
    jae  .eof
    movzx edx, byte [rsi]
    sub  edx, '0'
    cmp  edx, 9
    jbe  .digits
    inc  rsi
    jmp  .skip
.digits:
    xor  eax, eax
.dl:
    cmp  rsi, r12
    jae  .done
    movzx edx, byte [rsi]
    sub  edx, '0'
    cmp  edx, 9
    ja   .done
    imul rax, rax, 10
    add  rax, rdx
    inc  rsi
    jmp  .dl
.done:
    xor  ecx, ecx
    ret
.eof:
    mov  ecx, 1
    ret

; argmax: rdi = array of qwords, ecx = length.  Sets best_val / best_idx
; (lowest index wins ties).
argmax:
    xor  eax, eax
    mov  qword [best_val], 0
    mov  qword [best_idx], 0
.l:
    mov  rdx, [rdi + rax*8]
    cmp  rdx, [best_val]
    jbe  .n
    mov  [best_val], rdx
    mov  [best_idx], rax
.n:
    inc  eax
    cmp  eax, ecx
    jb   .l
    ret

; print_str: rsi = text, rdx = length
print_str:
    push rax
    push rdi
    push rcx
    push r11
    mov  eax, SYS_WRITE
    mov  edi, 1
    syscall
    pop  r11
    pop  rcx
    pop  rdi
    pop  rax
    ret

; print_char: al = character
print_char:
    push rsi
    push rdx
    mov  [chbuf], al
    lea  rsi, [chbuf]
    mov  edx, 1
    call print_str
    pop  rdx
    pop  rsi
    ret

; print_num: rax = unsigned value, printed in decimal
print_num:
    push rbx
    push rcx
    push rdx
    push rsi
    lea  rsi, [numbuf + 23]
    mov  rbx, 10
    xor  ecx, ecx
.d:
    xor  edx, edx
    div  rbx
    add  dl, '0'
    dec  rsi
    mov  [rsi], dl
    inc  rcx
    test rax, rax
    jnz  .d
    mov  rdx, rcx
    call print_str
    pop  rsi
    pop  rdx
    pop  rcx
    pop  rbx
    ret

; print_num2: rax = value 0..99 printed with 2 digits (zero padded)
print_num2:
    cmp  rax, 10
    jae  .two
    push rax
    mov  al, '0'
    call print_char
    pop  rax
.two:
    jmp  print_num
