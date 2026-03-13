#!/usr/bin/env python3
"""
Violet Void Color Blindness Simulation Tool

Simulates how the Violet Void palette appears to users with color vision deficiencies.

Usage: python3 colorblind-simulation.py [protanopia|deuteranopia|tritanopia|all|generate]

Requirements:
  - Python 3.6+
  - No external dependencies (uses built-in math and json)

References:
  - https://www.color-blindness.com/
  - https://ixora.io/projects/colorblindness/
  - Brettel, Viénot, Mollon (1997) simulation matrices
"""

import json
import math
import os
import sys
from pathlib import Path
from typing import Dict, List, Tuple

# Get script directory
SCRIPT_DIR = Path(__file__).parent.absolute()
PALETTE_FILE = SCRIPT_DIR.parent / "tokens" / "colors.json"
OUTPUT_DIR = SCRIPT_DIR.parent / "docs" / "accessibility"


def hex_to_rgb(hex_color: str) -> Tuple[int, int, int]:
    """Convert hex color to RGB tuple."""
    hex_color = hex_color.lstrip('#')
    return tuple(int(hex_color[i:i+2], 16) for i in (0, 2, 4))


def rgb_to_hex(r: int, g: int, b: int) -> str:
    """Convert RGB values to hex color."""
    r = max(0, min(255, int(r)))
    g = max(0, min(255, int(g)))
    b = max(0, min(255, int(b)))
    return f"#{r:02x}{g:02x}{b:02x}"


def simulate_protanopia(r: int, g: int, b: int) -> Tuple[int, int, int]:
    """
    Simulate protanopia (red-blind) - Missing L-cones.
    Affects ~1% of males.
    
    Brettel, Viénot, Mollon simulation matrix.
    """
    new_r = r * 0.567 + g * 0.433 + b * 0.0
    new_g = r * 0.558 + g * 0.442 + b * 0.0
    new_b = r * 0.0 + g * 0.242 + b * 0.758
    return (new_r, new_g, new_b)


def simulate_deuteranopia(r: int, g: int, b: int) -> Tuple[int, int, int]:
    """
    Simulate deuteranopia (green-blind) - Missing M-cones.
    Affects ~1% of males.
    
    Brettel, Viénot, Mollon simulation matrix.
    """
    new_r = r * 0.625 + g * 0.375 + b * 0.0
    new_g = r * 0.7 + g * 0.3 + b * 0.0
    new_b = r * 0.0 + g * 0.3 + b * 0.7
    return (new_r, new_g, new_b)


def simulate_tritanopia(r: int, g: int, b: int) -> Tuple[int, int, int]:
    """
    Simulate tritanopia (blue-blind) - Missing S-cones.
    Very rare, affects ~0.01% of population.
    
    Brettel, Viénot, Mollon simulation matrix.
    """
    new_r = r * 0.95 + g * 0.05 + b * 0.0
    new_g = r * 0.0 + g * 0.433 + b * 0.567
    new_b = r * 0.0 + g * 0.475 + b * 0.525
    return (new_r, new_g, new_b)


def process_color(hex_color: str, sim_type: str) -> str:
    """Process a single color through simulation."""
    r, g, b = hex_to_rgb(hex_color)
    
    if sim_type == "protanopia":
        new_r, new_g, new_b = simulate_protanopia(r, g, b)
    elif sim_type == "deuteranopia":
        new_r, new_g, new_b = simulate_deuteranopia(r, g, b)
    elif sim_type == "tritanopia":
        new_r, new_g, new_b = simulate_tritanopia(r, g, b)
    else:
        return hex_color
    
    return rgb_to_hex(new_r, new_g, new_b)


def extract_colors(palette_file: Path) -> List[Tuple[str, str]]:
    """Extract colors from palette JSON file."""
    if not palette_file.exists():
        raise FileNotFoundError(f"Palette file not found at {palette_file}")
    
    with open(palette_file, 'r') as f:
        data = json.load(f)
    
    colors = []
    
    def recurse_colors(obj, path=""):
        """Recursively extract color values."""
        if isinstance(obj, dict):
            if "value" in obj and "description" in obj:
                colors.append((obj["value"], obj["description"]))
            else:
                for key, value in obj.items():
                    recurse_colors(value, f"{path}.{key}" if path else key)
    
    recurse_colors(data.get("color", {}))
    return colors


def simulate_all_colors(sim_type: str) -> None:
    """Simulate all colors for a specific type."""
    print(f"=== {sim_type.title()} Simulation for Violet Void Palette ===")
    print()
    
    colors = extract_colors(PALETTE_FILE)
    
    for hex_color, description in colors:
        simulated = process_color(hex_color, sim_type)
        print(f"{description:30s} {hex_color} -> {simulated}")


def test_simulation() -> None:
    """Test simulation with sample colors."""
    print("=== Color Blindness Simulation Test ===")
    print()
    
    test_colors = [
        ("#ff1a67", "Red"),
        ("#42ff97", "Green"),
        ("#29adff", "Blue"),
        ("#7c60d1", "Purple"),
    ]
    
    for sim_type in ["protanopia", "deuteranopia", "tritanopia"]:
        print(f"--- {sim_type} ---")
        for hex_color, name in test_colors:
            simulated = process_color(hex_color, sim_type)
            print(f"{name:10s} ({hex_color}) -> {simulated}")
        print()


def generate_report(sim_type: str, output_file: Path) -> None:
    """Generate simulation report in Markdown."""
    colors = extract_colors(PALETTE_FILE)
    
    with open(output_file, 'w') as f:
        f.write(f"=== {sim_type.title()} Simulation ===\n\n")
        
        for hex_color, description in colors:
            simulated = process_color(hex_color, sim_type)
            f.write(f"- **{description}**\n")
            f.write(f"  - Original: `{hex_color}`\n")
            f.write(f"  - Simulated: `{simulated}`\n\n")


def generate_json(sim_type: str, output_file: Path) -> None:
    """Generate simulation output in JSON."""
    colors = extract_colors(PALETTE_FILE)
    
    result = {
        "simulation_type": sim_type,
        "generated_at": __import__('datetime').datetime.now().isoformat(),
        "colors": {}
    }
    
    for hex_color, description in colors:
        key = description.lower().replace(' ', '_').replace('-', '_')
        result["colors"][key] = {
            "original": hex_color,
            "simulated": process_color(hex_color, sim_type)
        }
    
    with open(output_file, 'w') as f:
        json.dump(result, f, indent=2)


def generate_all_outputs() -> None:
    """Generate all output files."""
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    
    for sim_type in ["protanopia", "deuteranopia", "tritanopia"]:
        md_file = OUTPUT_DIR / f"{sim_type}-simulation.md"
        json_file = OUTPUT_DIR / f"{sim_type}-simulation.json"
        
        print(f"Generating {sim_type} simulation...")
        generate_report(sim_type, md_file)
        generate_json(sim_type, json_file)
    
    print()
    print(f"Output files generated in {OUTPUT_DIR}:")
    for file in sorted(OUTPUT_DIR.glob("*")):
        size = file.stat().st_size
        print(f"  {file.name:40s} {size:>6,} bytes")


def main():
    """Main execution."""
    action = sys.argv[1] if len(sys.argv) > 1 else "all"
    
    if action == "test":
        test_simulation()
    elif action in ["protanopia", "deuteranopia", "tritanopia"]:
        simulate_all_colors(action)
    elif action == "generate":
        generate_all_outputs()
    elif action == "all":
        print("=== Color Blindness Simulation for Violet Void Theme ===")
        print()
        for sim_type in ["protanopia", "deuteranopia", "tritanopia"]:
            simulate_all_colors(sim_type)
            print()
    else:
        print("Violet Void Color Blindness Simulation Tool")
        print()
        print("Usage: python3 colorblind-simulation.py [test|protanopia|deuteranopia|tritanopia|generate|all]")
        print()
        print("Options:")
        print("  test         - Run a test simulation with sample colors")
        print("  protanopia   - Simulate red-blind vision (affects ~1% of males)")
        print("  deuteranopia - Simulate green-blind vision (affects ~1% of males)")
        print("  tritanopia   - Simulate blue-blind vision (very rare)")
        print("  generate     - Generate output files (Markdown and JSON)")
        print("  all          - Run all simulations (default)")
        sys.exit(1)


if __name__ == "__main__":
    main()
