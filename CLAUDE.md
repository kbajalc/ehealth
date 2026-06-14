# CLAUDE.md — eHealth Repository Guide

## Project Overview

This repository aggregates **two found open-source projects** built around the Cooking-Hacks e-Health Sensor Platform V1. Our primary work is on the **Arduino library and sketch**; the Raspberry Pi binary is kept as read-only reference under `ardupi/`.

- **Hardware kit**: Cooking-Hacks e-Health Sensor Platform **V1** (9 sensors, no EMG)
- **Primary focus**: Arduino library (`arduino/libraries/eHealth/`) and the companion sketch (`arduino/eHealth.ino`)
- **Reference only**: Raspberry Pi binary `eHdc` — source lives in `ardupi/`, treat as read-only

---

## Repository Structure

```
ehealth/
├── arduino/                      # PRIMARY FOCUS — Arduino content
│   ├── eHealth.ino               # Sketch: reads sensors, outputs semicolon-delimited serial data
│   └── libraries/                # Arduino libraries (install into Arduino IDE)
│       ├── eHealth/              # Main eHealth library v2.0 (Libelium/Cooking Hacks)
│       │   ├── eHealth.h/.cpp    # Sensor API
│       │   ├── eHealthDisplay.h/.cpp  # Optional LCD display support
│       │   ├── examples/         # 20 example sketches (one per sensor/use-case)
│       │   └── utils/            # Custom I2C implementation for Arduino
│       ├── PinChangeInt/         # Required for SPO2/pulsioximeter sensor
│       └── SoftwareSerial/       # Optional: for communication modules
│
├── ardupi/                       # READ-ONLY REFERENCE — Raspberry Pi binary (found project)
│   ├── src/                      # C++ source for eHdc binary (C++98, bcm2835)
│   │   ├── eHealth.h/.cpp        # RPi build of sensor library (same public API as arduino/)
│   │   ├── arduPi.h/.cpp         # Arduino/RPi compatibility layer
│   │   ├── main.cpp              # CLI entry point (argp)
│   │   ├── AbstractCollector.h   # Base sensor collector
│   │   └── ...                   # Collector subclasses, CsvWriter, TimeSpan, etc.
│   ├── scripts/                  # Python 2 + bash utilities (csv2wav, GUI, stats)
│   ├── configure.ac              # Autoconf configuration
│   ├── Makefile.am               # Automake build rules
│   ├── doxyfile                  # Doxygen config
│   ├── COPYING                   # GNU GPL v3
│   └── README.md                 # RPi project README
│
├── iot/                          # READ-ONLY REFERENCE — SUTD IoT course project (found project)
│   ├── src/
│   │   ├── Arduino/              # Arduino source (empty placeholder)
│   │   └── Web/SerialToBrowser/  # Node.js web dashboard (reads Arduino serial, shows live charts)
│   ├── doc/                      # Course tutorials: Udoo, sensors, XBee, Android
│   ├── pic/                      # Diagrams and screenshots
│   └── README.md                 # SUTD-IoT project overview
│
├── imgs/                         # Images for GUIDE.md
├── CLAUDE.md                     # This file — AI assistant guide
├── README.md                     # Full e-Health V2.0 documentation (from V2-POST.html)
├── MANUAL.md                     # Consolidated API reference (function table, structs, NTC table)
├── V1-NOTES.md                   # V1 hardware errata + Arduino IDE 2.x install guide
├── V1-DOCS.html                  # Saved Wayback Machine copy of original V1 documentation
└── V2-POST.html                     # Original saved HTML source page (projects-raspberry.com)
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
| Glucometer | ✅ Works — UART shared (disconnect other UART devices first); max 32 records; "P-C" on screen when connected |
| Blood pressure | ⚠️ **Wrist cuff** — set SPHY jumper, call `initBloodPressureSensor(float parameter)` (live measurement, blocks until ON pressed) |
| Patient position | ⚠️ Works — **set POS jumper** before connecting |
| **EMG** | ❌ **Not present on V1** — skip all EMG sections in GUIDE.md |

See [V1-NOTES.md](V1-NOTES.md) for full details and Arduino IDE installation instructions.

---

## Library Versions

There are two builds of the eHealth library in this repo:

| Location | Version | Platform | Status |
|----------|---------|----------|--------|
| `arduino/libraries/eHealth/` | 2.0 | Arduino | **Active — primary target** |
| `ardupi/src/eHealth.h/.cpp` | 2.0 (+Anartz Nuin) | Raspberry Pi | Read-only reference |

Both expose an **identical public API** — same function names, same sensor set. Internal differences are platform adaptations only (`Arduino.h` / custom I2C / `Serial` vs `arduPi.h` / `Wire` / `printf`). When in doubt about library behavior, consult `ardupi/src/eHealth.cpp` as a reference, but make changes only in `arduino/libraries/eHealth/`.

---

## Raspberry Pi Binary (`ardupi/`) — Reference Only

The `ardupi/` subtree is a standalone C++98 project built with GNU Autotools. **We do not build or modify it.** It is kept as reference for understanding the sensor library internals.

Build artifacts would land under `ardupi/` (binary `eHdc`). Prerequisites on RPi: bcm2835 library, g++, pthread, librt, argp. See `ardupi/README.md` for build instructions if needed.

---

## RPi Source Architecture (`ardupi/src/`) — Reference

The RPi binary uses Factory + Strategy patterns with one pthread per sensor. Key files for reference when understanding sensor library internals:

| File | Role |
|------|------|
| `ardupi/src/eHealth.h/.cpp` | Sensor library (RPi build) — same API as `arduino/libraries/eHealth/` |
| `ardupi/src/arduPi.h/.cpp` | Arduino/RPi compatibility shim (GPIO, I2C, SPI, Serial) |
| `ardupi/src/AbstractCollector.h` | Base class with collect loop, mutex, CsvWriter |
| `ardupi/src/main.cpp` | CLI entry point (argp) |

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
| `README.md` | Full sensor platform documentation converted from `V2-POST.html` (V2.0 focused) |
| `MANUAL.md` | Consolidated API reference: function table with return types, struct definitions, NTC temperature table, body position illustrations |
| `V1-NOTES.md` | **Start here if using V1 hardware** — errata, full V1 API reference, GLCD display library, IDE install guide |
| `V1-DOCS.html` | Saved Wayback Machine copy of original V1 Cooking Hacks documentation page |
| `V2-POST.html` | Original saved HTML source page from projects-raspberry.com |

---

## Scripts (`ardupi/scripts/`) — Reference Only

Python 2 + bash utilities bundled with the RPi binary. Not used in our Arduino workflow.

| Script | Purpose |
|--------|---------|
| `csv2wav.py` | Converts CSV time-series to WAV; splits at signal discontinuities |
| `csv2wav.sh` | Recursively runs `csv2wav.py` on a directory |
| `eHdc-gui.py` | PyQt4 GUI for touch-screen control; launches `eHdc` subprocess |
| `record.sh` | Shell wrapper to start a recording session |
| `statistic.py` | Computes statistics (min, max, mean, etc.) from CSV data |
| `statistic.sh` | Batch statistics runner |
| `vid-repack.sh` | Repacks h264 streams into mp4 containers |

## IoT Web Dashboard (`iot/`) — Reference Only

The `iot/` subtree is the **SUTD-IoT** project (ISTD 50.001 course). It contains:
- `iot/doc/` — course tutorials covering Udoo board, sensor platform, XBee, Android integration
- `iot/src/Web/SerialToBrowser/` — Node.js + Socket.io web dashboard that reads Arduino serial output and displays live sensor charts in a browser (Chart.js, Material Design)
- `iot/src/Arduino/` — placeholder for Arduino sketches (empty)

The `SerialToBrowser` app is interesting as a potential companion to `arduino/eHealth.ino` — it expects semicolon-delimited serial data matching what the sketch outputs.

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

There is **no automated test suite**. Validation is by direct hardware measurement on an Arduino.

When making changes to the library or sketch, manually verify:
- The sketch compiles without errors in the Arduino IDE.
- On hardware: serial output contains plausible sensor values.

---

## Code Conventions

### Arduino library (`arduino/libraries/eHealth/`)
- Follows Arduino library conventions: `Arduino.h` includes, `Serial` for output, `Wire` for I2C.
- **Header guards**: `#ifndef FOO_H` / `#define FOO_H` throughout.
- **Naming**: `_camelCase` private members; `PascalCase` for classes; `camelCase` for methods.
- **License header**: Source files carry GPLv3 boilerplate. Maintain this on new files.

### RPi source (`ardupi/src/`) — read-only reference
- C++98/C++03 with `-fpermissive`. Raw pointers, no smart pointers. Doxygen `@todo`/`@param` tags.

---

## Git Conventions

- Commit messages are short, imperative-ish descriptions: `"X improved."`, `"X added."`, `"X fixed."`.
- The `master` branch is the main branch.
- AI-assisted work branches use the pattern `claude/<description>-<id>`.

---

## Future Development Notes

- Improve the `arduino/eHealth.ino` sketch (sensor selection, output format, calibration).
- Explore wiring `arduino/eHealth.ino` serial output to the `iot/src/Web/SerialToBrowser/` dashboard.
- Add a baseline/calibration mark mechanism for ECG and skin conductance in the Arduino library.
- (RPi reference) `ardupi/src/main.cpp:107` has a TODO to migrate to modern C++ — not our concern.
