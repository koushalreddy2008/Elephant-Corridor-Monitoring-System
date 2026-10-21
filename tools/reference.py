#!/usr/bin/env python3
"""
Elephant Corridor Monitoring System - Python Reference Analytical Engine
Mirrors the exact x86-64 assembly report logic in asm/elephant_report.asm
to guarantee 100% hardware/software test parity.
"""

import sys
import os

NUM_CORRIDORS = 4
DANGER_DIST_M = 500
NIGHT_START_HR = 18
NIGHT_END_HR = 6
HIGH_RISK_PCT = 30
MED_RISK_PCT = 10  # >= 10% indicates MEDIUM risk as specified in Section 6

def analyze_readings(csv_path="data/elephant_readings.csv"):
    if not os.path.exists(csv_path):
        print("error: cannot open input file")
        sys.exit(1)

    with open(csv_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    if not lines:
        print("error: cannot open input file")
        sys.exit(1)

    # Skip header
    data_lines = lines[1:]

    corr_cnt = [0] * NUM_CORRIDORS
    corr_dz = [0] * NUM_CORRIDORS
    hour_cnt = [0] * 24
    period_cnt = [0] * 4  # 0: Night, 1: Morning, 2: Afternoon, 3: Evening

    total = 0
    sum_speed = 0
    max_speed = 0
    dz_total = 0
    dz_night = 0

    for line in data_lines:
        line = line.strip()
        if not line or line.startswith('#'):
            continue
        parts = [p.strip() for p in line.split(',') if p.strip()]
        if len(parts) < 6:
            continue
        try:
            r_id = int(parts[0])
            corridor = int(parts[1])
            hour = int(parts[2])
            speed = int(parts[3])
            distance = int(parts[4])
            direction = int(parts[5])
        except ValueError:
            continue

        if corridor >= NUM_CORRIDORS or hour >= 24:
            continue

        total += 1
        sum_speed += speed
        if speed > max_speed:
            max_speed = speed

        corr_cnt[corridor] += 1
        hour_cnt[hour] += 1
        period = hour // 6
        period_cnt[period] += 1

        if distance <= DANGER_DIST_M:
            dz_total += 1
            corr_dz[corridor] += 1
            if hour >= NIGHT_START_HR or hour < NIGHT_END_HR:
                dz_night += 1

    if total == 0:
        print("error: cannot open input file")
        sys.exit(1)

    # argmax for corridor (lowest index wins ties, matching asm)
    best_corr_val = max(corr_cnt)
    best_corr_idx = corr_cnt.index(best_corr_val)

    # Average speed with 1 decimal (fixed-point integer division matching asm)
    avg_speed_int = sum_speed // total
    avg_speed_frac = ((sum_speed % total) * 10) // total

    # argmax for peak hour
    best_hour_val = max(hour_cnt)
    best_hour_idx = hour_cnt.index(best_hour_val)

    # argmax for peak period
    best_period_val = max(period_cnt)
    best_period_idx = period_cnt.index(best_period_val)
    period_labels = [
        "Night      00:00-05:59",
        "Morning    06:00-11:59",
        "Afternoon  12:00-17:59",
        "Evening    18:00-23:59"
    ]

    # Danger-zone percentage
    pct = (dz_total * 100) // total

    # Build exact report matching asm/elephant_report.asm
    out = []
    out.append("==============================================================")
    out.append("   ELEPHANT CORRIDOR MONITORING - HUMAN-WILDLIFE CONFLICT REPORT")
    out.append("==============================================================")
    out.append(f"Readings analysed          : {total}")
    out.append("Corridor crossings (readings per corridor):")
    for i in range(NUM_CORRIDORS):
        cor_letter = chr(ord('A') + i)
        out.append(f"  Corridor {cor_letter} : {corr_cnt[i]}   (danger-zone entries: {corr_dz[i]})")
    
    top_letter = chr(ord('A') + best_corr_idx)
    out.append(f"Most frequently used corridor : Corridor {top_letter}  ({best_corr_val} crossings)")
    out.append(f"Average movement speed       : {avg_speed_int}.{avg_speed_frac} km/h")
    out.append(f"Maximum movement speed       : {max_speed} km/h")
    out.append(f"Peak activity hour           : {best_hour_idx:02d}:00 - {best_hour_idx:02d}:59  ({best_hour_val} readings)")
    out.append(f"Peak activity period         : {period_labels[best_period_idx]}")
    out.append(f"Danger-zone entries         : {dz_total}  ({pct} % of all readings)")
    out.append(f"  of which at night (18-06h) : {dz_night}\n")
    
    if pct >= HIGH_RISK_PCT:
        out.append("Conflict risk level          : HIGH   -> EMERGENCY: alert residents, deploy forest-guard patrol")
    elif pct >= MED_RISK_PCT:
        out.append("Conflict risk level          : MEDIUM -> WARNING: sound siren at night, restrict movement near corridor")
    else:
        out.append("Conflict risk level          : LOW    -> NORMAL: routine monitoring only")
    out.append("==============================================================")

    return "\n".join(out)

if __name__ == "__main__":
    csv_file = sys.argv[1] if len(sys.argv) > 1 else "data/elephant_readings.csv"
    print(analyze_readings(csv_file))
