#!/usr/bin/env python3
"""
Test vector generator for Logisim digital circuit:
circuit/elephant_corridor_monitor.circ

Outputs test vectors in Logisim-compatible tab/space format.
"""

def evaluate_circuit_logic(prox, direction, speed, tod, cross_pulse):
    """
    Hardware Truth Logic:
    - prox: 0 to 15 (lower = closer to settlement)
    - direction: 0=Toward, 1=Away, 2=Parallel, 3=Crossing
    - speed: 0 to 15 km/h
    - tod: 0=Day, 1=Night
    - cross_pulse: 0 or 1
    
    Outputs:
    - led_green (safe), led_yellow (watch), led_red (danger)
    - buzzer
    - zone_status: 0=Settlement/Border, 1=Danger Zone, 2=Buffer Zone, 3=Safe Forest
    """
    # Zone classification
    if prox <= 2:
        zone_status = 0 # Settlement perimeter / immediate danger
    elif prox <= 4:
        zone_status = 1 # Danger Zone
    elif prox <= 8:
        zone_status = 2 # Buffer Zone
    else:
        zone_status = 3 # Safe Forest

    # Danger condition: In danger zone (prox <= 4) AND heading toward settlement (direction == 0)
    # Or charge speed towards settlement
    is_danger = (prox <= 4 and direction == 0) or (prox <= 6 and direction == 0 and speed >= 10)
    
    # Watch condition: In buffer zone (prox <= 8) OR crossing corridor OR heading towards settlement from afar
    is_watch = not is_danger and (prox <= 8 or direction == 0 or direction == 3)
    
    # Safe condition
    is_safe = not is_danger and not is_watch

    led_red = 1 if is_danger else 0
    led_yellow = 1 if is_watch else 0
    led_green = 1 if is_safe else 0

    # Buzzer triggers if danger, escalated if night
    buzzer = 1 if is_danger else 0

    return led_green, led_yellow, led_red, buzzer, zone_status

def generate_vectors(output_path="circuit/elephant_corridor_vectors.txt"):
    test_cases = [
        # (prox, dir, spd, tod, cross, description)
        (14, 1, 4, 0, 0, "Safe forest, moving away, day"),
        (12, 2, 3, 0, 1, "Safe forest, parallel movement, crossing line"),
        (8, 3, 5, 0, 1, "Buffer zone, crossing corridor"),
        (7, 0, 6, 0, 0, "Buffer zone, moving toward village (Watch)"),
        (4, 0, 8, 0, 0, "Danger boundary, moving toward village (DANGER)"),
        (3, 0, 9, 1, 0, "Danger zone, toward village at night (DANGER)"),
        (2, 0, 12, 1, 0, "Perimeter breach, charging toward village (DANGER)"),
        (3, 1, 5, 0, 0, "Close proximity, but moving away safely"),
        (10, 0, 4, 1, 0, "Distant, heading toward village at night (Watch)"),
        (1, 0, 14, 1, 0, "Extreme danger: close, high speed, night"),
    ]

    lines = []
    lines.append("# Logisim Test Vectors: Elephant Corridor Monitoring System")
    lines.append("# Format: prox[4] dir[2] spd[4] tod[1] cross[1] | green[1] yellow[1] red[1] buzzer[1] zone[2]")
    
    for prox, direction, spd, tod, cross, desc in test_cases:
        g, y, r, bz, zn = evaluate_circuit_logic(prox, direction, spd, tod, cross)
        lines.append(f"{prox:04b} {direction:02b} {spd:04b} {tod:01b} {cross:01b}   {g} {y} {r} {bz} {zn:02b}  # {desc}")

    with open(output_path, 'w') as f:
        f.write("\n".join(lines) + "\n")
    print(f"Generated {len(test_cases)} test vectors to {output_path}")

if __name__ == "__main__":
    generate_vectors()
