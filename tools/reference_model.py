#!/usr/bin/env python3
"""
Elephant Corridor Monitoring System - Reference Model
Provides an independent verification model for Logisim digital circuit and x86-64 assembly report.
"""

import sys
import os

PROXIMITY_DANGER_THRESHOLD = 4
DIR_TOWARD_SETTLEMENT = 0
SPEED_CHARGE_THRESHOLD = 10

def analyze_movement_file(csv_path):
    corridor_counts = {1: 0, 2: 0, 3: 0, 4: 0}
    corridor_crossings = {1: 0, 2: 0, 3: 0, 4: 0}
    speeds = []
    danger_events = 0
    total_records = 0
    
    # Activity bins: Night (22:00-06:00), Morning (06:00-12:00), Afternoon (12:00-17:00), Evening (17:00-22:00)
    activity_bins = {
        "Night (22:00 - 06:00)": 0,
        "Morning (06:00 - 12:00)": 0,
        "Afternoon (12:00 - 17:00)": 0,
        "Evening (17:00 - 22:00)": 0
    }

    if not os.path.exists(csv_path):
        print(f"Error: File {csv_path} does not exist.")
        sys.exit(1)

    with open(csv_path, 'r') as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith('#'):
                continue
            parts = line.split(',')
            if len(parts) < 7:
                continue

            time_str, corr_id_str, prox_str, dir_str, speed_str, tod_str, cross_str = parts[:7]
            
            corr_id = int(corr_id_str)
            prox = int(prox_str)
            direction = int(dir_str)
            speed = int(speed_str)
            tod = int(tod_str)
            cross = int(cross_str)

            total_records += 1
            speeds.append(speed)
            corridor_counts[corr_id] = corridor_counts.get(corr_id, 0) + 1
            if cross == 1:
                corridor_crossings[corr_id] = corridor_crossings.get(corr_id, 0) + 1

            # Time of day binning
            hour = int(time_str.split(':')[0])
            if hour >= 22 or hour < 6:
                activity_bins["Night (22:00 - 06:00)"] += 1
            elif 6 <= hour < 12:
                activity_bins["Morning (06:00 - 12:00)"] += 1
            elif 12 <= hour < 17:
                activity_bins["Afternoon (12:00 - 17:00)"] += 1
            else:
                activity_bins["Evening (17:00 - 22:00)"] += 1

            # Conflict condition: animal close to settlement and moving towards it
            if prox <= PROXIMITY_DANGER_THRESHOLD and direction == DIR_TOWARD_SETTLEMENT:
                danger_events += 1

    # Analysis results
    most_used_corridor = max(corridor_counts, key=corridor_counts.get) if total_records else 0
    max_speed = max(speeds) if speeds else 0
    avg_speed = sum(speeds) / len(speeds) if speeds else 0.0
    peak_period = max(activity_bins, key=activity_bins.get) if total_records else "N/A"

    report = []
    report.append("===============================================================")
    report.append("       ELEPHANT CORRIDOR MONITORING & CONFLICT REPORT          ")
    report.append("===============================================================")
    report.append(f"Total Movement Records Analyzed : {total_records}")
    report.append("---------------------------------------------------------------")
    report.append("1. CORRIDOR UTILIZATION:")
    for cid in range(1, 5):
        report.append(f"   Corridor #{cid} : {corridor_counts.get(cid, 0)} detections | {corridor_crossings.get(cid, 0)} crossings recorded")
    report.append(f"   >> Most Frequently Used Corridor: Corridor #{most_used_corridor}")
    report.append("---------------------------------------------------------------")
    report.append("2. SPEED METRICS:")
    report.append(f"   >> Maximum Recorded Speed       : {max_speed} km/h")
    report.append(f"   >> Average Movement Speed       : {avg_speed:.2f} km/h")
    report.append("---------------------------------------------------------------")
    report.append("3. TEMPORAL ACTIVITY ANALYSIS:")
    for period, count in activity_bins.items():
        report.append(f"   {period:<25} : {count} detections")
    report.append(f"   >> Highest Animal Activity Period: {peak_period}")
    report.append("---------------------------------------------------------------")
    report.append("4. HUMAN-WILDLIFE CONFLICT ASSESSMENT:")
    report.append(f"   Danger Zone Incursions Detected  : {danger_events}")
    verdict = "HIGH ALERT: Active conflict mitigation needed" if danger_events > 0 else "NORMAL: No immediate village intrusion detected"
    report.append(f"   Overall Risk Status              : {verdict}")
    report.append("===============================================================")
    
    return "\n".join(report)

if __name__ == "__main__":
    dataset = sys.argv[1] if len(sys.argv) > 1 else "data/movement_data.csv"
    print(analyze_movement_file(dataset))
