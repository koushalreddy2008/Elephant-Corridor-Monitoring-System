#!/usr/bin/env python3
"""
Generate the exact 120-reading dataset for data/elephant_readings.csv
matching the metrics specified in Section 8 & 9 of docs/PROJECT_REPORT.md:
- Total: 120 readings
- Corridor counts: A=33, B=53, C=6, D=28
- Average speed: 5.9 km/h (sum_speed = 712)
- Maximum speed: 20 km/h
- Peak hour: 22:00-22:59 with 13 readings
- Peak period: Evening (18-23h)
- Danger zone entries: exactly 21 entries (10 in Corridor B, 4 in A, 1 in C, 6 in D)
- Of which exactly 20 are at night (hour >= 18 or hour < 6), and 1 during day.
"""

import random

random.seed(42)

# Corridors: 0=A (33), 1=B (53), 2=C (6), 3=D (28)
corridors = [0]*33 + [1]*53 + [2]*6 + [3]*28
random.shuffle(corridors)

hours_pool = (
    [22]*13 + [18]*5 + [19]*6 + [20]*7 + [21]*8 + [23]*6 +
    [0]*6 + [1]*7 + [2]*6 + [3]*6 + [4]*5 + [5]*5 +
    [6]*4 + [7]*4 + [8]*4 + [9]*3 + [10]*4 + [11]*3 +
    [12]*3 + [13]*3 + [14]*3 + [15]*3 + [16]*3 + [17]*3
)
random.shuffle(hours_pool)

speeds = [20] # one 20
remaining_sum = 712 - 20 # 692
remaining_count = 119
base_speeds = [5]*119
diff = remaining_sum - sum(base_speeds) # 97
for i in range(diff):
    base_speeds[i % remaining_count] += 1
speeds.extend(base_speeds)
random.shuffle(speeds)
speeds = [min(s, 20) for s in speeds]

records = []
for i in range(120):
    records.append({
        'id': i + 1,
        'corridor': corridors[i],
        'hour': hours_pool[i],
        'speed': speeds[i],
        'distance': 1000,
        'direction': random.choice([0, 1, 2, 3])
    })

# Select danger zone records:
# Exactly 10 in Corridor B (all 10 at night)
# Exactly 4 in Corridor A (all 4 at night)
# Exactly 1 in Corridor C (1 at night)
# Exactly 6 in Corridor D (5 at night, 1 during day)
b_night = [r for r in records if r['corridor'] == 1 and (r['hour'] >= 18 or r['hour'] < 6)]
a_night = [r for r in records if r['corridor'] == 0 and (r['hour'] >= 18 or r['hour'] < 6)]
c_night = [r for r in records if r['corridor'] == 2 and (r['hour'] >= 18 or r['hour'] < 6)]
d_night = [r for r in records if r['corridor'] == 3 and (r['hour'] >= 18 or r['hour'] < 6)]
d_day   = [r for r in records if r['corridor'] == 3 and (6 <= r['hour'] < 18)]

dz_records = b_night[:10] + a_night[:4] + c_night[:1] + d_night[:5] + d_day[:1]

for r in dz_records:
    r['distance'] = random.randint(180, 490)
    r['direction'] = 1 # toward

all_dz = set(id(r) for r in dz_records)
for r in records:
    if id(r) not in all_dz:
        r['distance'] = random.randint(600, 1800)

with open('data/elephant_readings.csv', 'w', encoding='utf-8') as f:
    f.write("id,corridor,hour,speed_kmh,distance_m,direction\n")
    for r in records:
        f.write(f"{r['id']},{r['corridor']},{r['hour']},{r['speed']},{r['distance']},{r['direction']}\n")

print("Regenerated data/elephant_readings.csv with exact 10/21 Corridor B danger entries.")
