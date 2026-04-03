# CLAUDE.md — eHealth Repository Guide

## Project Overview

This is a **C++ biomedical data collection application** for the Cooking-Hacks e-Health Sensor Platform, targeting Raspberry Pi hardware. It collects time-series sensor data and writes it to CSV files. The project also includes Arduino sketches and Python/shell utility scripts.

- **Binary**: `eHdc` (eHealth Data Collector)
- **Version**: 0.0.13
- **License**: GNU GPL v3
- **Language**: C++98/C++03 (uses `-fpermissive`), Python 2 (scripts)
- **Hardware target**: Raspberry Pi (BCM2835 ARM SoC), Arduino

---

## Repository Structure

```
ehealth/
├── src/                  # C++ source for the eHdc binary
├── arduino/              # Arduino sketch(es)
│   └── eHealth.ino       # Reads sensors, outputs semicolon-delimited data to serial
├── scripts/              # Python and shell utilities
│   ├── csv2wav.py        # Convert CSV sensor data to WAV audio
│   ├── csv2wav.sh        # Shell wrapper for csv2wav.py (recursive)
│   ├── eHdc-gui.py       # PyQt4 touch-screen GUI frontend
│   ├── record.sh         # Data recording helper
│   ├── statistic.py      # Statistical analysis on CSV output
│   ├── statistic.sh      # Shell wrapper for statistic.py
│   └── vid-repack.sh     # Repack h264 video to mp4
├── configure.ac          # Autoconf configuration
├── Makefile.am           # Automake build rules
├── doxyfile              # Doxygen documentation config
├── README.md             # Project README with known hardware issues
└── COPYING               # GNU GPL v3 license
```

---

## Build System

The project uses **GNU Autotools** (autoconf + automake).

### Prerequisites

- C++ compiler (g++)
- [`bcm2835` library](http://www.airspayce.com/mikem/bcm2835/) — Broadcom BCM2835 ARM peripheral library
- `pthread` and `librt`
- `argp` (part of glibc)

### Build Steps

```sh
# Generate configure script (only needed once or after modifying configure.ac)
autoreconf -i

# Configure and build
./configure
make

# The binary is placed at ./eHdc
```

The build sets `CXXFLAGS=-fpermissive -lpthread -lrt`. The `-fpermissive` flag is intentional — the codebase relies on older C++ idioms.

---

## Running eHdc

```sh
# Collect BPM and ECG, 1000 measurements each, at default 200ms interval
sudo ./eHdc --bpm 200000 --ecg 200000 --count 1000 --postfix session1

# Options:
#   -a INTERVAL   Airflow sensor (microseconds between readings)
#   -b INTERVAL   BPM / pulse sensor
#   -O INTERVAL   Oxygen saturation (SpO2)
#   -e INTERVAL   ECG (electrocardiogram)
#   -s INTERVAL   Skin conductance voltage
#   -t INTERVAL   Corporal temperature
#   -p POSTFIX    CSV filename suffix (e.g. "session1" → "bpm-session1.csv")
#   -c COUNT      Number of measurements (0 = run indefinitely)
#   -v            Verbose output
```

**Output files**: `{sensor}-{postfix}.csv` in the current directory.  
Each CSV has two columns: `timeSpan (sec)`, `<sensor-value>`.  
Default interval: `200000` microseconds (0.2 s). `INACTIVE = 0` disables a sensor.

**Requires `sudo`** — the bcm2835 library needs direct hardware access.

---

## Source Architecture (`src/`)

### Design Patterns

- **Factory Pattern**: `CollectorFactory` reads `eHdcParams` and instantiates the appropriate `AbstractCollector` subclasses.
- **Strategy Pattern**: Each sensor type is a concrete subclass of `AbstractCollector`, overriding `value()` and `type()`.
- **Thread-per-collector**: `Controller` spawns one `pthread` per active collector and joins all threads before exiting.

### Key Classes

| File | Class | Responsibility |
|------|-------|---------------|
| `main.cpp` | — | CLI argument parsing via `argp`, wires factory + controller |
| `eHdcParams.h` | `eHdcParams` | Holds parsed CLI parameters (intervals, count, postfix, verbosity) |
| `CollectorFactory.h` | `CollectorFactory` | Creates `AbstractCollector*` vector from `eHdcParams` |
| `Controller.h` | `Controller` | Spawns and joins pthreads, one per collector |
| `AbstractCollector.h` | `AbstractCollector` | Base class: `collect()` loop, `CsvWriter`, `TimeSpan`, mutex |
| `AbstractPulsioximeterCollector.h` | `AbstractPulsioximeterCollector` | Intermediate base for pulse/oxygen sensors |
| `AirflowCollector.h` | `AirflowCollector` | Airflow voltage (0–1023 raw ADC) |
| `BpmCollector.h` | `BpmCollector` | Beats per minute |
| `EcgCollector.h` | `EcgCollector` | ECG voltage (0–5 V) |
| `OxygenCollector.h` | `OxygenCollector` | Oxygen saturation (%) |
| `SkinConductanceCollector.h` | `SkinConductanceCollector` | Skin conductance voltage |
| `TemperatureCollector.h` | `TemperatureCollector` | Corporal temperature (°C) |
| `CsvWriter.h` | `CsvWriter` | Writes time-stamped rows to CSV file |
| `TimeSpan.h` | `TimeSpan` | Elapsed time calculation |
| `eHealth.h/cpp` | `eHealth` | Cooking-Hacks sensor library |
| `arduPi.h/cpp` | — | Raspberry Pi / Arduino compatibility layer (serial, GPIO, I2C, SPI) |

### Concurrency Note

A single `pthread_mutex_t` is declared as a file-scope static in `AbstractCollector.h`. All collectors share this mutex for serialized hardware access.

### Adding a New Sensor

1. Create `src/MySensorCollector.h` subclassing `AbstractCollector` (or `AbstractPulsioximeterCollector`).
2. Implement `virtual double value()` and `virtual int type()`.
3. Add an enum value to `AbstractCollector::Type` and a case in `AbstractCollector::map()`.
4. Add a parameter field to `eHdcParams.h` (getter + setter).
5. Add a CLI option in `main.cpp` (`program_options[]` + `parse_option()`).
6. Instantiate in `CollectorFactory::create()`.
7. Add the new `.h` file to `eHdc_SOURCES` in `Makefile.am`.

---

## Scripts

All scripts live in `scripts/` and are **Python 2** or bash.

| Script | Purpose |
|--------|---------|
| `csv2wav.py` | Converts CSV time-series to WAV; splits at signal discontinuities |
| `csv2wav.sh` | Recursively runs `csv2wav.py` on a directory |
| `eHdc-gui.py` | PyQt4 GUI for touch-screen control; launches `eHdc` subprocess |
| `record.sh` | Shell wrapper to start a recording session |
| `statistic.py` | Computes statistics (min, max, mean, etc.) from CSV data |
| `statistic.sh` | Batch statistics runner |
| `vid-repack.sh` | Repacks h264 streams into mp4 containers |

---

## Known Platform Issues

These are **hardware/firmware limitations**, not code bugs:

1. **Non-linear timeline** — inter-sample interval is not constant.
2. **Airflow range** — sensor misses low-breathing data.
3. **Sensor mutual interference** — combining sensors on Raspberry Pi v1/2/3 causes crosstalk.
4. **Safety concern** — some sensors may pass unsafe current through subjects with medical implants.
5. **Noisy signals** — ECG and skin conductance require post-processing.
6. **Pulse/SpO2 quality** — insufficient measurement quality for reliable use.

---

## Testing

There is **no automated test suite**. The project is validated by direct hardware measurement on a Raspberry Pi.

When making changes, manually verify:
- `./configure && make` completes without errors.
- The binary runs with `--help` and prints the correct usage.
- On hardware: output CSV files contain plausible values.

---

## Code Conventions

- **C++ standard**: C++98/C++03. Do not introduce C++11 or later features without updating the build flags and verifying compiler support on the target Raspberry Pi.
- **Header guards**: `#ifndef FOO_H` / `#define FOO_H` pattern throughout.
- **Naming**: `_camelCase` private members with leading underscore; `PascalCase` for classes; `camelCase` for methods.
- **Memory management**: Raw pointers with `new`/`delete`. No smart pointers (C++98 constraint).
- **License header**: All source files carry the GPLv3 boilerplate comment block. Maintain this on new files.
- **Doxygen**: `@todo` and `@param` tags used in comments. The `doxyfile` is configured for HTML output.

---

## Git Conventions

- Commit messages are short, imperative-ish descriptions: `"X improved."`, `"X added."`, `"X fixed."`.
- Development branch for AI-assisted work: `claude/add-claude-documentation-PV9DS`.
- The `master` branch tracks the upstream remote.

---

## Future Development Notes (from codebase TODOs)

- Migrate from C++98 to a modern C++ standard (`src/main.cpp:107`).
- Add a baseline/calibration mark mechanism for ECG and skin conductance.
- Target fixed measurement intervals (e.g., 100 ms) across all sensors simultaneously.
- Investigate/remove residual `arduPi` artifacts (the `loop()` stub in `main.cpp`).
- Improve bcm2835 library version detection in `configure.ac`.
