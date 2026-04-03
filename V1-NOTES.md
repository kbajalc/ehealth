# e-Health Sensor Platform V1 — Notes & Errata

This document is for users with the **e-Health Sensor Shield V1** kit. The main documentation
([GUIDE.md](GUIDE.md)) covers the V2.0 hardware. Most of it applies directly to V1, but several
sections need adjustment. This file documents every difference and provides a complete
Arduino IDE 2.x installation guide for the libraries in this repository.

---

## Table of Contents

1. [V1 vs V2 — What Is Different](#1-v1-vs-v2--what-is-different)
2. [Which Library to Use](#2-which-library-to-use)
3. [Installing the Libraries in Arduino IDE 2.3.8](#3-installing-the-libraries-in-arduino-ide-238)
4. [Sensor-by-Sensor V1 Errata](#4-sensor-by-sensor-v1-errata)
   - [SPO2 / Pulse Oximeter](#41-spo2--pulse-oximeter)
   - [ECG — No Jumper Selection Needed](#42-ecg--no-jumper-selection-needed)
   - [EMG — Not Present on V1](#43-emg--not-present-on-v1)
   - [Blood Pressure — Different Connector](#44-blood-pressure--different-connector)
   - [Glucometer — UART Sharing](#45-glucometer--uart-sharing)
   - [All Other Sensors](#46-all-other-sensors)
5. [UART Port Sharing Limitations](#5-uart-port-sharing-limitations)
6. [Power Supply Notes](#6-power-supply-notes)
7. [Compatible Arduino Boards](#7-compatible-arduino-boards)

---

## 1. V1 vs V2 — What Is Different

| Feature | V1 Shield | V2.0 Shield |
|---------|-----------|-------------|
| Number of sensors | **9** | 10 |
| EMG sensor | **Not present** | Added |
| ECG/EMG jumper selector | **Not present** | Required to switch between ECG and EMG |
| Blood pressure connector | **Uses GLCD connector + adapter** | Dedicated connector |
| SPO2 sensor model | **Model A** (no sticker) | Model A or Model B (yellow sticker) |
| Glucometer connector | Shared UART | **Own dedicated connector** |

> **Bottom line for V1 users:** ignore all EMG references in GUIDE.md, use the GLCD connector
> for blood pressure, and use the **V2.0 library** (the one in this repository).

---

## 2. Which Library to Use

The library in this repository (`arduino/libraries/eHealth/`) is the **eHealth library V2.0 (2013)**.
This is the **correct version for V1 hardware** and for V2 hardware with SPO2 model A (no yellow
sticker).

> If your SPO2 sensor has a **yellow sticker** on it, you have model B and need the
> **V2.3 (July 2014)** library instead, which Cooking Hacks distributed separately.
> The V2.0 library in this repo will **not** read model B SPO2 sensors correctly.

The three libraries you need from `arduino/libraries/`:

| Library | Required for |
|---------|-------------|
| `eHealth` | All sensors |
| `PinChangeInt` | SPO2 / Pulse oximeter only |
| `SoftwareSerial` | Only if using Bluetooth/GPRS communication modules |

---

## 3. Installing the Libraries in Arduino IDE 2.3.8

Arduino IDE 2.x uses the same sketchbook libraries folder as 1.x. There are two methods.

### Method A — Manual copy (recommended, no ZIP needed)

**Step 1 — Find your Arduino libraries folder**

| OS | Default path |
|----|-------------|
| Windows | `C:\Users\<YourName>\Documents\Arduino\libraries\` |
| macOS | `~/Documents/Arduino/libraries/` |
| Linux | `~/Arduino/libraries/` |

If the `libraries` folder does not exist, create it.

> You can verify the path in Arduino IDE 2: go to **File → Preferences** and check the
> **Sketchbook location** field. The libraries folder is inside that location.

**Step 2 — Copy the library folders**

From this repository, copy these three folders into your Arduino `libraries` folder:

```
arduino/libraries/eHealth        →  <sketchbook>/libraries/eHealth
arduino/libraries/PinChangeInt   →  <sketchbook>/libraries/PinChangeInt
arduino/libraries/SoftwareSerial →  <sketchbook>/libraries/SoftwareSerial  (optional)
```

The result should look like:

```
libraries/
├── eHealth/
│   ├── eHealth.h
│   ├── eHealth.cpp
│   ├── eHealthDisplay.h
│   ├── eHealthDisplay.cpp
│   ├── keywords.txt
│   ├── utils/
│   └── examples/
├── PinChangeInt/
│   ├── PinChangeInt.h
│   ├── PinChangeInt.cpp
│   └── PinChangeIntConfig.h
└── SoftwareSerial/          (optional)
```

**Step 3 — Restart Arduino IDE 2**

Close and reopen Arduino IDE 2. The libraries will appear under
**Sketch → Include Library** and their example sketches will appear under
**File → Examples** at the bottom of the list.

**Step 4 — Verify**

Open **File → Examples → eHealth → PulsioximeterExample**. If it opens without errors,
the library is installed correctly.

---

### Method B — ZIP install via IDE

**Step 1 — Create ZIP files**

From the repository root, zip each library folder:

```bash
cd arduino/libraries
zip -r eHealth.zip eHealth/
zip -r PinChangeInt.zip PinChangeInt/
```

**Step 2 — Install in Arduino IDE**

In Arduino IDE 2: **Sketch → Include Library → Add .ZIP Library…**

Select `eHealth.zip` and click Open. Repeat for `PinChangeInt.zip`.

**Step 3 — Restart Arduino IDE 2**

---

### Verifying the installation

After installation, open the Serial Terminal example to confirm everything compiles:

**File → Examples → eHealth → SerialTerminalExample → SerialTerminalExample**

Select your board (**Tools → Board → Arduino Uno**) and click **Verify** (✓). If it compiles
without errors, the library is installed correctly.

---

## 4. Sensor-by-Sensor V1 Errata

### 4.1 SPO2 / Pulse Oximeter

**Works on V1 — no wiring change.**

The GUIDE.md SPO2 section applies fully to V1. The sensor has only one possible connection
orientation, so plugging it in incorrectly is not possible.

Confirm your sensor model:
- **No sticker** → Model A → use V2.0 library (this repo) ✓
- **Yellow sticker** → Model B → you need the V2.3 library (not in this repo)

The code example in GUIDE.md works as-is:

```cpp
#include <PinChangeInt.h>
#include <eHealth.h>
```

---

### 4.2 ECG — No Jumper Selection Needed

**Works on V1 — no wiring change, but ignore the jumper instructions.**

GUIDE.md states:
> *"The EMG sensor and the ECG can't work simultaneously. Use the jumpers integrated
> in the board to use one or the other."*

On V1 there are **no ECG/EMG jumpers** — ECG is always active. Ignore all jumper
references. The ECG example code works unchanged.

---

### 4.3 EMG — Not Present on V1

**⚠ Skip entirely. The EMG sensor and its connector do not exist on the V1 shield.**

All EMG references in GUIDE.md (section *Muscle/Electromyography sensor*,
`getEMG()`, `EMGExampleSerial`, `EMGExampleKST`) are **V2.0 only**.

Do not call `eHealth.getEMG()` on V1 hardware — the pin it reads (A0) is shared with
ECG and will return ECG data, not EMG.

---

### 4.4 Blood Pressure — Different Connector

**Works on V1 but requires the GLCD connector and an adapter cable.**

On V2.0 the blood pressure sensor has its own dedicated connector. On V1 it does not.

**V1 connection procedure:**

1. You need the **two-part adapter cable** that came with the blood pressure sensor.
2. Connect the **jack terminal** of the adapter to the **GLCD connector** on the V1 shield
   (the same connector used for the LCD screen — they cannot be used simultaneously).
3. Connect the **mini-USB terminal** of the adapter to the sphygmomanometer.
4. When connected correctly, the sphygmomanometer screen shows **"UUU"**.

![V1 blood pressure adapter connection](imgs/The-connection-of-this-sensor-in-other-e-Health-versions-is-very-simple.png)

![GLCD connector wiring for V1](imgs/ou-must-use-the-GLCD-connector-and-connect-the-device-as-shown-in-the-next-picture.png)

> **Important:** Take at least one measurement with the cuff before connecting it to the
> Arduino. The library reads data stored in the sensor's memory — it does not trigger a
> live measurement. Press ON, wait for the reading to complete and store, then connect.

The library code is **identical** for V1 and V2:

```cpp
#include <eHealth.h>

void setup() {
    eHealth.readBloodPressureSensor();
    Serial.begin(115200);
}
```

> **UART note:** On V1 the blood pressure sensor uses the same UART as the LCD and
> communication modules. You cannot use the LCD, blood pressure sensor, and a radio
> module at the same time. See [Section 5](#5-uart-port-sharing-limitations).

---

### 4.5 Glucometer — UART Sharing

**Works on V1 — no wiring change, but UART is shared.**

On V2.0 the glucometer has its own dedicated connector and does not conflict with other
UART devices (except the sphygmomanometer). On V1 the glucometer shares the UART port.

**V1 rule:** only one UART device active at a time — glucometer, blood pressure sensor,
LCD screen, or communication module. Disconnect the others before reading.

The library code is identical for V1 and V2.

---

### 4.6 All Other Sensors

The following sensors work **identically on V1 and V2** with no wiring or code changes:

| Sensor | GUIDE.md section | Notes |
|--------|-----------------|-------|
| Airflow | *Airflow: breathing* | No changes |
| Body temperature | *Body temperature* | No changes |
| ECG | *Electrocardiogram (ECG)* | Ignore jumper instructions |
| GSR / Skin conductance | *Galvanic Skin Response* | No changes |
| Patient position | *Patient position and falls* | No changes |

---

## 5. UART Port Sharing Limitations

The e-Health V1 shield has a single hardware UART shared between several peripherals.
**Only one can be active at a time:**

| Peripheral | UART user |
|-----------|-----------|
| LCD / GLCD screen | Yes |
| Blood pressure sensor | Yes (via GLCD connector on V1) |
| Glucometer | Yes |
| Bluetooth module | Yes |
| GPRS module | Yes |
| 3G module | Yes |
| ZigBee / 802.15.4 | Yes |

Practical rules:
- Disconnect the LCD before reading blood pressure or glucometer data.
- Do not have both the blood pressure sensor and glucometer connected at once.
- Communication modules (Bluetooth, GPRS, etc.) must be disconnected when reading
  from the blood pressure sensor or glucometer.

---

## 6. Power Supply Notes

The V1 shield can be powered via USB from the PC, but some USB ports cannot supply
enough current for all sensors simultaneously.

If the shield behaves erratically or resets unexpectedly, use an **external 12V – 2A**
power supply connected to the Arduino barrel jack instead of USB power.

---

## 7. Compatible Arduino Boards

The V1 shield is compatible with:

- Arduino Uno (Atmega328, recommended)
- Arduino Duemilanove
- Arduino Mega

> The `PinChangeInt` library is required for the SPO2 sensor and works on all three boards.
> On Arduino Mega the pin change interrupt behaviour may differ slightly — prefer Uno or
> Duemilanove for simplest setup.
