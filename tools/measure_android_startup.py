"""Measure installed Android builds without clearing logs or changing saves."""
import argparse
import hashlib
import json
import pathlib
import re
import subprocess
import time


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--adb-path", required=True)
    parser.add_argument("--serial", required=True)
    parser.add_argument("--output-dir", required=True)
    parser.add_argument("--runs", type=int, default=3)
    args = parser.parse_args()
    if not 1 <= args.runs <= 10:
        parser.error("runs must be between 1 and 10")
    output = pathlib.Path(args.output_dir)
    output.mkdir(parents=True, exist_ok=True)
    base = [args.adb_path, "-s", args.serial]

    def adb(*command):
        return subprocess.check_output(base + list(command), timeout=45)

    def validate_save():
        raw = adb("exec-out", "run-as", "com.howtogrow.game", "cat",
                  "files/how_to_grow_save.json")
        try:
            save = json.loads(raw)
        except (ValueError, UnicodeError) as error:
            raise RuntimeError("Startup benchmark requires a readable player save") from error
        if not isinstance(save, dict) or save.get("schema") != 41 or not save.get("intro_completed"):
            raise RuntimeError("Startup benchmark requires schema 41 and completed intro")
        return {"schema": save["schema"], "bytes": len(raw),
                "sha256": hashlib.sha256(raw).hexdigest()}

    runs = []
    for index in range(args.runs):
        adb("shell", "am", "force-stop", "com.howtogrow.game")
        before = validate_save()
        marker = f"BAZAL_STARTUP_{time.time_ns()}"
        adb("shell", "log", "-t", "BAZAL_AUDIT", marker)
        launcher = adb("shell", "am", "start", "-W", "-n",
                       "com.howtogrow.game/com.godot.game.GodotAppLauncher").decode()
        if "Status: ok" not in launcher:
            raise RuntimeError("Android launcher did not confirm a successful start")
        deadline = time.monotonic() + 40
        while True:
            log = adb("logcat", "-d", "-v", "epoch", "Godot:D", "godot:D",
                      "BAZAL_AUDIT:I", "AndroidRuntime:E", "*:S").decode(errors="replace")
            lines = log.splitlines()
            start = next((n for n, line in enumerate(lines) if marker in line), None)
            current = lines[start:] if start is not None else []
            if any("STARTUP_MAIN_READY_MS=" in line for line in current):
                break
            if time.monotonic() >= deadline:
                raise RuntimeError("Main scene did not become ready within 40 seconds")
            time.sleep(0.5)
        text = "\n".join(current)
        (output / f"start-{index + 1}.log").write_text(text, encoding="utf8")
        if any(error in text for error in
               ("SCRIPT ERROR", "FATAL EXCEPTION", "Program linking failed")):
            raise RuntimeError("Android runtime/rendering error in start log")
        metrics = {m.group(1): int(m.group(2)) for m in
                   re.finditer(r"(STARTUP_[A-Z_]+)=(\d+)", text)}
        ready_line = next(line for line in current if "STARTUP_MAIN_READY_MS=" in line)
        metrics["launcher_marker_to_main_ready_ms"] = round(
            (float(ready_line.split()[0]) - float(current[0].split()[0])) * 1000)
        metrics["launcher_report"] = launcher.strip()
        metrics["save_before"] = before
        runs.append(metrics)
        print(f"STARTUP_RUN={index + 1} " + json.dumps(metrics), flush=True)
        time.sleep(1.2)
        (output / f"room-{index + 1}.png").write_bytes(adb("exec-out", "screencap", "-p"))
        metrics["save_after"] = validate_save()
        final_log = adb("logcat", "-d", "-v", "epoch", "Godot:D", "godot:D",
                        "BAZAL_AUDIT:I", "AndroidRuntime:E", "*:S").decode(errors="replace")
        final_lines = final_log.splitlines()
        final_start = next((n for n, line in enumerate(final_lines) if marker in line), None)
        if final_start is None:
            raise RuntimeError("Audit marker disappeared from Android logs")
        final_text = "\n".join(final_lines[final_start:])
        (output / f"start-{index + 1}.log").write_text(final_text, encoding="utf8")
        if any(error in final_text for error in
               ("SCRIPT ERROR", "FATAL EXCEPTION", "Program linking failed")):
            raise RuntimeError("Android error during transition to the room")
    (output / "metrics.json").write_text(json.dumps({
        "mode": "Force-stopped cold processes, warm filesystem cache; MAIN_READY excludes cloud transition",
        "serial": args.serial, "runs": runs,
    }, indent=2), encoding="utf8")
    (output / "meminfo.txt").write_bytes(adb("shell", "dumpsys", "meminfo", "com.howtogrow.game"))
    print("ANDROID_STARTUP_MEASUREMENT=PASSED", flush=True)


if __name__ == "__main__":
    main()
