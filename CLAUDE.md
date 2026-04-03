# CLAUDE.md — eHealth Repository Guide

## Project Overview

This is a **C++ biomedical data collection application** for the Cooking-Hacks e-Health Sensor Platform, targeting Raspberry Pi hardware. It collects time-series sensor data and writes it to CSV files. The project also includes the official Arduino eHealth library (v2.0), Arduino sketches, Python/shell utility scripts, and full platform documentation.

- **Binary**: `eHdc` (eHealth Data Collector)
- **Version**: 0.0.13
- **License**: GNU GPL v3
- **Language**: C++98/C++03 (uses `-fpermissive`), Python 2 (scripts)
- **Hardware target**: Raspberry Pi (BCM2835 ARM SoC), Arduino Uno/Duemilanove/Mega
- **Hardware kit**: Cooking-Hacks e-Health Sensor Platform **V1** (9 sensors, no EMG)

---

## Repository Structure

```
ehealth/
├── src/                          # C++ source for the eHdc Raspberry Pi binary
├── arduino/                      # Arduino content
│   ├── eHealth.ino               # Sketch: reads sensors, outputs semicolon-delimited serial data
│   └── libraries/                # Arduino libraries (install into Arduino IDE)
│       ├── eHealth/              # Main eHealth library v2.0 (Libelium/Cooking Hacks)
│       │   ├── eHealth.h/.cpp    # Sensor API — identical public interface to src/eHealth.h
│       │   ├── eHealthDisplay.h/.cpp  # Optional LCD display support
│       │   ├── examples/         # 20 example sketches (one per sensor/use-case)
│       │   └── utils/            # Custom I2C implementation for Arduino
│       ├── PinChangeInt/         # Required for SPO2/pulsioximeter sensor
│       └── SoftwareSerial/       # Optional: for communication modules
├── scripts/                      # Python and shell utilities
│   ├── csv2wav.py                # Convert CSV sensor data to WAV audio
│   ├── csv2wav.sh                # Shell wrapper for csv2wav.py (recursive)
│   ├── eHdc-gui.py               # PyQt4 touch-screen GUI frontend
│   ├── record.sh                 # Data recording helper
│   ├── statistic.py              # Statistical analysis on CSV output
│   ├── statistic.sh              # Shell wrapper for statistic.py
│   └── vid-repack.sh             # Repack h264 video to mp4
├── imgs/                         # Images for GUIDE.md (downloaded from projects-raspberry.com)
│   └── download-imgs.sh          # Script to re-download all 60 images if needed
├── CLAUDE.md                     # This file — AI assistant guide
├── GUIDE.md                      # Full e-Health V2.0 documentation (from post.html)
├── MANUAL.md                     # Sensor API reference manual
├── V1-NOTES.md                   # V1 hardware errata + Arduino IDE 2.x install guide
├── post.html                     # Saved source HTML page (projects-raspberry.com)
├── configure.ac                  # Autoconf configuration
├── Makefile.am                   # Automake build rules
├── doxyfile                      # Doxygen documentation config
├── README.md                     # Project README
└── COPYING                       # GNU GPL v3 license
```

---

## Hardware Context

### Kit Version: V1

The owner has the **e-Health Sensor Shield V1**, which has 9 sensors (no EMG). Key V1
differences from the V2.0 documentation in GUIDE.md:

| Sensor | V1 status |
|--------|-----------|
| SPO2 / Pulse oximeter | ✅ Works — Model A (no yellow sticker) |
| Airflow | ✅ Works — identical to V2 |
| Body temperature | ✅ Works — identical to V2 |
| ECG | ✅ Works — no jumper needed (V1 has no ECG/EMG jumper) |
| GSR / Skin conductance | ✅ Works — identical to V2 |
| Patient position | ✅ Works — identical to V2 |
| Glucometer | ✅ Works — UART shared (disconnect other UART devices first) |
| Blood pressure | ⚠️ Works via **GLCD connector + adapter cable** (not dedicated connector) |
| **EMG** | ❌ **Not present on V1** — skip all EMG sections in GUIDE.md |

See [V1-NOTES.md](V1-NOTES.md) for full details and Arduino IDE installation instructions.

---

## Library Versions

There are two versions of the eHealth library in this repo, targeting different platforms:

| Location | Version | Platform | Notes |
|----------|---------|----------|-------|
| `src/eHealth.h/.cpp` | 2.0 (+Anartz Nuin) | Raspberry Pi | Uses `arduPi.h`, `Wire`, `printf` |
| `arduino/libraries/eHealth/` | 2.0 | Arduino | Uses `Arduino.h`, custom I2C, `Serial` |

Both expose an **identical public API** — same function names, same sensor set. The differences
are internal platform adaptations only. Use `arduino/libraries/eHealth/` for Arduino IDE.

---

## Build System (Raspberry Pi binary)

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
| `eHealth.h/cpp` | `eHealth` | Cooking-Hacks sensor library (Raspberry Pi build) |
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

## Arduino Library Examples

The `arduino/libraries/eHealth/examples/` directory contains 20 ready-to-use sketches:

| Sketch | Sensor |
|--------|--------|
| `PulsioximeterExample` | SPO2 + BPM |
| `ECGExampleSerial` / `ECGExampleKST` | ECG |
| `AirFlowExampleSerial` / `AirFlowExampleKST` | Airflow |
| `TemperatureExample` | Body temperature |
| `GSRExampleSerial` / `GSRExampleKST` | Skin conductance |
| `BloodPressureExample` | Blood pressure |
| `BodyPositionExample` | Patient position |
| `GlucometerExample` | Glucometer |
| `EMGExampleSerial` / `EMGExampleKST` | EMG (**V2 only, skip on V1**) |
| `SerialTerminalExample` | All sensors via serial |
| `LCDExample` | LCD display output |
| `AndroidAppExample` / `IphoneAppExample` | Mobile app integration |
| `GprsSmsSendExample` | GPRS SMS |
| `Server3GConnectionExample` | 3G cloud upload |
| `ZigBeeCommunicationExample` | ZigBee/802.15.4 |

---

## Documentation Files

| File | Contents |
|------|---------|
| `GUIDE.md` | Full sensor platform documentation converted from `post.html` (V2.0 focused) |
| `MANUAL.md` | Sensor API reference with all library functions and code examples |
| `V1-NOTES.md` | **Start here if using V1 hardware** — errata, differences, IDE install guide |
| `post.html` | Original saved HTML source page from projects-raspberry.com |

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
- The `master` branch is the main branch.
- AI-assisted work branches use the pattern `claude/<description>-<id>`.

---

## Future Development Notes (from codebase TODOs)

- Migrate from C++98 to a modern C++ standard (`src/main.cpp:107`).
- Add a baseline/calibration mark mechanism for ECG and skin conductance.
- Target fixed measurement intervals (e.g., 100 ms) across all sensors simultaneously.
- Investigate/remove residual `arduPi` artifacts (the `loop()` stub in `main.cpp`).
- Improve bcm2835 library version detection in `configure.ac`.
