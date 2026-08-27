from __future__ import annotations

from collections import deque
from pathlib import Path

from PIL import Image


PROJECT_ROOT = Path(__file__).resolve().parents[1]
SOURCE = PROJECT_ROOT / "docs" / "visual-proposals" / "phase161" / "daily-challenge-clean-plate-source-v3-neutral.png"
OUTPUT = PROJECT_ROOT / "assets" / "ui" / "visual" / "phase161" / "daily_challenge" / "daily_challenge_clean_backdrop_v3.png"


def is_exterior(rgb: tuple[int, int, int]) -> bool:
    low = min(rgb)
    high = max(rgb)
    return low >= 218 and high - low <= 34


def main() -> None:
    if OUTPUT.exists():
        raise SystemExit(f"Refusing to overwrite append-only asset: {OUTPUT}")

    source = Image.open(SOURCE).convert("RGBA")
    width, height = source.size
    pixels = source.load()
    exterior = bytearray(width * height)
    queue: deque[tuple[int, int]] = deque()

    def enqueue(x: int, y: int) -> None:
        index = y * width + x
        if exterior[index]:
            return
        rgb = pixels[x, y][:3]
        if not is_exterior(rgb):
            return
        exterior[index] = 1
        queue.append((x, y))

    for x in range(width):
        enqueue(x, 0)
        enqueue(x, height - 1)
    for y in range(height):
        enqueue(0, y)
        enqueue(width - 1, y)

    while queue:
        x, y = queue.popleft()
        if x > 0:
            enqueue(x - 1, y)
        if x + 1 < width:
            enqueue(x + 1, y)
        if y > 0:
            enqueue(x, y - 1)
        if y + 1 < height:
            enqueue(x, y + 1)

    result = source.copy()
    result_pixels = result.load()
    removed = 0
    for y in range(height):
        row = y * width
        for x in range(width):
            if exterior[row + x]:
                red, green, blue, _alpha = result_pixels[x, y]
                result_pixels[x, y] = (red, green, blue, 0)
                removed += 1

    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    result.save(OUTPUT, optimize=True)

    bounds = result.getbbox()
    if bounds is None:
        raise SystemExit("Generated asset is fully transparent")
    if result.getpixel((0, 0))[3] != 0:
        raise SystemExit("Exterior background removal failed")
    if result.getpixel((width // 2, height // 2))[3] != 255:
        raise SystemExit("Interior painting was unexpectedly removed")
    if removed < width * height // 20:
        raise SystemExit("Exterior mask removed too few pixels")

    print(f"PHASE161_ASSET_BUILD=PASSED")
    print(f"SOURCE={SOURCE}")
    print(f"OUTPUT={OUTPUT}")
    print(f"SIZE={width}x{height}")
    print(f"ALPHA_BOUNDS={bounds}")
    print(f"REMOVED_PIXELS={removed}")


if __name__ == "__main__":
    main()
