"""
SVG → Android & Windows icon converter
Uses Inkscape CLI for SVG→PNG, then Pillow for PNG→ICO

Usage: python convert_icons.py
"""
import subprocess
import os
import sys
from pathlib import Path

SCRIPT_DIR = Path(__file__).parent
SVG_FILE = SCRIPT_DIR / "app_icon.svg"
PROJECT_ROOT = SCRIPT_DIR.parent.parent

# Android icon sizes: name -> (size_px, resource_folder)
ANDROID_ICONS = {
    "mdpi": 48,
    "hdpi": 72,
    "xhdpi": 96,
    "xxhdpi": 144,
    "xxxhdpi": 192,
}

ANDROID_RES = PROJECT_ROOT / "android" / "app" / "src" / "main" / "res"
WINDOWS_RES = PROJECT_ROOT / "windows" / "runner" / "resources"


def find_inkscape():
    """Find Inkscape executable."""
    # Check common paths
    candidates = [
        r"C:\Program Files\Inkscape\bin\inkscape.exe",
        r"C:\Program Files (x86)\Inkscape\bin\inkscape.exe",
    ]
    for c in candidates:
        if os.path.exists(c):
            return c
    # Try PATH
    try:
        result = subprocess.run(["where", "inkscape"], capture_output=True, text=True)
        if result.returncode == 0:
            return result.stdout.strip().split("\n")[0]
    except FileNotFoundError:
        pass
    return None


def convert_svg_to_png(inkscape: str, svg: Path, output: Path, size: int):
    """Convert SVG to PNG at specific size using Inkscape."""
    cmd = [
        inkscape,
        str(svg),
        f"--export-filename={output}",
        f"--export-width={size}",
        f"--export-height={size}",
    ]
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        print(f"  ERROR: {result.stderr}")
        return False
    return True


def create_ico(png_files: list, ico_path: Path):
    """Create ICO file from multiple PNG files using Pillow."""
    try:
        from PIL import Image
    except ImportError:
        print("Installing Pillow...")
        subprocess.run([sys.executable, "-m", "pip", "install", "Pillow"], check=True)
        from PIL import Image

    images = []
    for png in png_files:
        img = Image.open(png)
        images.append(img)

    # Save as ICO with all sizes
    images[0].save(
        ico_path,
        format="ICO",
        sizes=[(img.size[0], img.size[1]) for img in images],
        append_images=images[1:],
    )


def main():
    print("=" * 50)
    print("  App Icon Converter: SVG → PNG + ICO")
    print("=" * 50)

    # Find Inkscape
    inkscape = find_inkscape()
    if not inkscape:
        print("\nERROR: Inkscape not found!")
        print("Please install Inkscape or add it to PATH.")
        print("Download: https://inkscape.org/release/")
        sys.exit(1)
    print(f"\nUsing Inkscape: {inkscape}")

    # Verify SVG exists
    if not SVG_FILE.exists():
        print(f"\nERROR: SVG file not found: {SVG_FILE}")
        sys.exit(1)
    print(f"SVG source: {SVG_FILE}")

    # --- Android Icons ---
    print(f"\n--- Android Icons → {ANDROID_RES} ---")
    generated_pngs = []

    for density, size in ANDROID_ICONS.items():
        out_dir = ANDROID_RES / f"mipmap-{density}"
        out_file = out_dir / "ic_launcher.png"
        print(f"  {density} ({size}×{size})... ", end="", flush=True)

        if convert_svg_to_png(inkscape, SVG_FILE, out_file, size):
            generated_pngs.append((size, out_file))
            print("✓")
        else:
            print("✗ FAILED")

    # --- Windows ICO ---
    print(f"\n--- Windows ICO → {WINDOWS_RES} ---")
    ico_file = WINDOWS_RES / "app_icon.ico"

    if generated_pngs:
        # Sort by size descending for ICO (largest first)
        generated_pngs.sort(key=lambda x: x[0], reverse=True)
        png_paths = [p for _, p in generated_pngs]
        print(f"  Creating ICO with sizes: {[s for s, _ in generated_pngs]}... ", end="", flush=True)
        try:
            create_ico(png_paths, ico_file)
            print("✓")
        except Exception as e:
            print(f"✗ FAILED: {e}")
    else:
        print("  Skipped (no PNGs generated)")

    print(f"\n{'=' * 50}")
    print("  Done! Restart your app to see the new icon.")
    print("=" * 50)


if __name__ == "__main__":
    main()
