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
4. [Complete V1 API Reference](#4-complete-v1-api-reference)
5. [Sensor-by-Sensor V1 Errata](#5-sensor-by-sensor-v1-errata)
   - [SPO2 / Pulse Oximeter](#51-spo2--pulse-oximeter)
   - [ECG — No Jumper Selection Needed](#52-ecg--no-jumper-selection-needed)
   - [EMG — Not Present on V1](#53-emg--not-present-on-v1)
   - [Blood Pressure — Wrist Cuff, Different API](#54-blood-pressure--wrist-cuff-different-api)
   - [Patient Position — Jumper Required](#55-patient-position--jumper-required)
   - [Body Temperature — Calibration](#56-body-temperature--calibration)
   - [GSR / Skin Conductance — Calibration](#57-gsr--skin-conductance--calibration)
   - [Glucometer — 32 Records, P-C Indicator](#58-glucometer--32-records-p-c-indicator)
   - [All Other Sensors](#59-all-other-sensors)
6. [GLCD Display Library](#6-glcd-display-library)
7. [UART Port Sharing Limitations](#7-uart-port-sharing-limitations)
8. [Power Supply Notes](#8-power-supply-notes)
9. [Compatible Arduino Boards](#9-compatible-arduino-boards)

---

## 1. V1 vs V2 — What Is Different

| Feature | V1 Shield | V2.0 Shield |
|---------|-----------|-------------|
| Number of sensors | **9** (7 non-invasive + 1 invasive + position) | 10 |
| EMG sensor | **Not present** | Added |
| ECG/EMG jumper selector | **Not present** | Required to switch between ECG and EMG |
| Blood pressure sensor | **Wrist cuff — SPHY jumper required** | Arm/bicep cuff — dedicated connector |
| Blood pressure API | **`initBloodPressureSensor(float parameter)`** | `readBloodPressureSensor()` |
| Blood pressure reading | **Single live measurement** | Reads stored vector from memory |
| Patient position jumper | **POS gateway position required** | Different |
| SPO2 sensor model | **Model A** (no sticker) | Model A or Model B (yellow sticker) |
| Glucometer max records | **32** | 8 |
| Glucometer connection indicator | **"P-C" on screen** | "UUU" on screen |

> **Bottom line for V1 users:** ignore all EMG references in GUIDE.md; use the SPHY jumper and
> wrist cuff for blood pressure; use the POS jumper for patient position; and use the
> **V2.0 library** (the one in this repository).

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

## 4. Complete V1 API Reference

The following are all library functions available on V1 hardware. Note that `getEMG()` does
**not** appear here — it does not exist on V1.

**Pulsioximeter (SPO2) functions:**

```cpp
eHealth.initPulsioximeter();    // Initialize the pulsioximeter sensor
eHealth.readPulsioximeter();    // Read a value from pulsioximeter (call from ISR)
eHealth.getBPM();               // Returns heart beats per minute
eHealth.getOxygenSaturation(); // Returns oxygen saturation in blood (%)
```

**ECG function:**

```cpp
eHealth.getECG();               // Returns analogue value representing electrocardiography
```

**Airflow functions:**

```cpp
eHealth.getAirFlow();           // Returns analogue value representing air flow
eHealth.airFlowWave();          // Prints air flow waveform to serial monitor
```

**Temperature function:**

```cpp
eHealth.getTemperature();       // Returns corporal temperature (float, °C)
```

**Blood pressure functions (V1 — live wrist measurement):**

```cpp
eHealth.initBloodPressureSensor(float parameter);  // Init and wait for ON button press
eHealth.getSystolicPressure();   // Returns systolic pressure (int, mm Hg)
eHealth.getDiastolicPressure();  // Returns diastolic pressure (int, mm Hg)
```

**Patient position functions:**

```cpp
eHealth.initPositionSensor();   // Initialize the position sensor
eHealth.getBodyPosition();      // Returns body position (uint8_t, 1–5)
eHealth.printPosition(uint8_t position);  // Prints position name to serial
```

**GSR / Skin conductance functions:**

```cpp
eHealth.getSkinConductance();        // Returns skin conductance (float)
eHealth.getSkinResistance();         // Returns skin resistance (float)
eHealth.getSkinConductanceVoltage(); // Returns skin conductance in voltage (float)
```

**Glucometer functions:**

```cpp
eHealth.readGlucometer();            // Read all values stored in the glucometer
eHealth.getGlucometerLength();       // Returns number of stored measurements (max 32)
eHealth.numberToMonth(uint8_t month); // Convert month number to name string
// Data accessed via: eHealth.glucoseDataVector[i].glucose / .day / .month / .year / .hour / .minutes / .meridian
```

---

## 5. Sensor-by-Sensor V1 Errata

### 5.1 SPO2 / Pulse Oximeter

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

### 5.2 ECG — No Jumper Selection Needed

**Works on V1 — no wiring change, but ignore the jumper instructions.**

GUIDE.md states:
> *"The EMG sensor and the ECG can't work simultaneously. Use the jumpers integrated
> in the board to use one or the other."*

On V1 there are **no ECG/EMG jumpers** — ECG is always active. Ignore all jumper
references. The ECG example code works unchanged.

---

### 5.3 EMG — Not Present on V1

**⚠ Skip entirely. The EMG sensor and its connector do not exist on the V1 shield.**

All EMG references in GUIDE.md (section *Muscle/Electromyography sensor*,
`getEMG()`, `EMGExampleSerial`, `EMGExampleKST`) are **V2.0 only**.

Do not call `eHealth.getEMG()` on V1 hardware — the pin it reads (A0) is shared with
ECG and will return ECG data, not EMG.

---

### 5.4 Blood Pressure — Wrist Cuff, Different API

**Works on V1 but the connector, jumper, sensor position, and API are all different from V2.**

#### Key differences from GUIDE.md (V2)

| | V1 | V2 |
|--|----|----|
| Cuff position | **Wrist** (5–10 mm from palm) | Arm / bicep |
| Jumper | **SPHY gateway position** | Dedicated connector |
| API to call | **`initBloodPressureSensor(float parameter)`** | `readBloodPressureSensor()` |
| When reading happens | **Live measurement** — waits for ON button | Reads stored memory |
| Calibration | **`float parameter` offset** in code | No parameter |

#### Jumper setup

Before connecting the sensor, set the jumpers on the e-Health shield to the **SPHY gateway
position**.

#### Wearing the sensor

Place the sphygmomanometer on your **wrist**, palm facing up, with the right side of the
blood-pressure meter facing up. Wrap the cuff around the left wrist **5–10 mm from the palm**
(about the width of a pinky finger). To get an accurate reading, keep the heart and wrist on the
same horizontal plane — do not hold the arm up or let it hang down.

#### Taking a measurement

1. Press the ON/OFF button on the sphygmomanometer and **wait** while it takes the measurement.
2. After a few seconds the result appears on the sphygmomanometer screen.
3. The Arduino reads the measurement independently — values will be very similar but may not
   match exactly. Do not make abrupt movements during the measurement.

> **Important:** The library reads the measurement in real time while the cuff is inflating/
> deflating — it does **not** read stored memory. Call `initBloodPressureSensor()` in `loop()`
> and it will block until the ON button is pressed and a reading completes.

#### Calibration

Each sphygmomanometer has a device-specific calibration offset. The Libelium team provides this
value. To calibrate manually:

1. Take several readings and record: the Arduino voltage value, the blood pressure reading on the
   screen, and the corresponding voltage in `eHealth.cpp`.
2. Calculate the average difference — this is your calibration offset.
3. Set `float parameter` to the negative of the offset (e.g. `float parameter = -0.1`).

#### Blood pressure classification

| Category | Systolic (mm Hg) | Diastolic (mm Hg) |
|----------|-----------------|-------------------|
| Hypotension | < 90 | < 60 |
| Desired | 90–119 | 60–79 |
| Prehypertension | 120–139 | 80–89 |
| Stage 1 Hypertension | 140–159 | 90–99 |
| Stage 2 Hypertension | 160–179 | 100–109 |
| Hypertensive Crisis | ≥ 180 | ≥ 110 |

#### Arduino code example

```cpp
#include <eHealth.h>

// Device-specific calibration offset — see tutorial for how to determine this.
// Positive measured deviation → use negative offset (e.g. deviation +0.07 → parameter -0.07)
float parameter = 0.0;

void setup() {
  Serial.begin(115200);
  Serial.println("Press On/Off button on the sphygmomanometer...");
}

void loop() {
  // Blocks until the ON/OFF button is pressed and measurement completes
  eHealth.initBloodPressureSensor(parameter);

  Serial.println("****************************");
  Serial.print("Systolic blood pressure value : ");
  Serial.println(eHealth.getSystolicPressure());

  Serial.println("****************************");
  Serial.print("Diastolic blood pressure value : ");
  Serial.println(eHealth.getDiastolicPressure());

  delay(3000);
}
```

> **UART note:** On V1 the blood pressure sensor uses the same hardware UART as the GLCD,
> glucometer, and communication modules. Only one can be active at a time.
> See [Section 7](#7-uart-port-sharing-limitations).

---

### 5.5 Patient Position — Jumper Required

**Works on V1 — but jumpers must be set first.**

Before connecting the body position sensor, set the jumpers on the e-Health shield to the
**POS gateway position**. GUIDE.md does not mention this V1 jumper requirement.

Once the jumpers are set, connect the ribbon cable from the body position sensor to the e-Health
board. Place the sensor around the chest with the connector facing down.

The library code is identical to GUIDE.md:

```cpp
#include <eHealth.h>

void setup() {
  Serial.begin(115200);
  eHealth.initPositionSensor();
}

void loop() {
  Serial.print("Current position : ");
  uint8_t position = eHealth.getBodyPosition();
  eHealth.printPosition(position);
  Serial.print("\n");
  delay(1000);
}
```

Body position values returned:

| Value | Position |
|-------|---------|
| 1 | Supine (lying on back) |
| 2 | Left lateral decubitus |
| 3 | Right lateral decubitus |
| 4 | Prone (lying face down) |
| 5 | Standing or sitting |

---

### 5.6 Body Temperature — Calibration

**Works on V1 — no wiring change. Calibration is optional but improves accuracy.**

To calibrate the temperature sensor, edit `eHealth.cpp` and adjust the resistor and voltage
constants in `getTemperature()`:

- **Ra** and **Rb** — measure these resistor values with a multimeter placed at the resistor
  extremes. Example measured values: `Ra = 4640`, `Rb = 819`.
- **RefTension** — measure the voltage between the 3 V red cable and GND with a multimeter
  in voltage mode. Update only if different from the default.

The sensor code in GUIDE.md applies directly to V1:

```cpp
float temperature = eHealth.getTemperature();
```

---

### 5.7 GSR / Skin Conductance — Calibration

**Works on V1 — no wiring change. Calibration is optional but improves accuracy.**

The `getSkinConductance()` and `getSkinResistance()` functions in `eHealth.cpp` use a
reference voltage that defaults to `0.5`. To calibrate:

1. Place a multimeter between the **0.5 V red cable** and **GND (black cable)** on the shield.
2. Read the actual voltage. Example: `0.498`.
3. In `eHealth.cpp`, change `0.5` to the measured value (e.g. `0.498`).

The sensor code in GUIDE.md applies directly to V1:

```cpp
float conductance = eHealth.getSkinConductance();
float resistance = eHealth.getSkinResistance();
float conductanceVol = eHealth.getSkinConductanceVoltage();
```

If `getSkinConductance()` returns `-1`, no patient is connected.

---

### 5.8 Glucometer — 32 Records, P-C Indicator

**Works on V1 — no wiring change, but two details differ from GUIDE.md.**

1. **Maximum stored records: 32** (GUIDE.md says 8, which is the V2 limit).
2. **Connection indicator: "P-C"** — when the glucometer is correctly connected to the e-Health
   board via the data cable, the glucometer screen shows **"P-C"**. GUIDE.md mentions "UUU"
   which is the V2 blood pressure sensor indicator.

**V1 rule:** Only one UART device active at a time — glucometer, blood pressure sensor, GLCD,
or communication module. Disconnect the others before reading.

The library code is identical to GUIDE.md:

```cpp
#include <eHealth.h>

void setup() {
  // Must be called before Serial.begin()
  eHealth.readGlucometer();
  Serial.begin(115200);
}

void loop() {
  uint8_t numberOfData = eHealth.getGlucometerLength(); // max 32 on V1
  for (int i = 0; i < numberOfData; i++) {
    Serial.print("Glucose value : ");
    Serial.print(eHealth.glucoseDataVector[i].glucose);
    Serial.println(" mg/dL");
  }
  delay(20000);
}
```

---

### 5.9 All Other Sensors

The following sensors work **identically on V1 and V2** with no wiring or code changes:

| Sensor | GUIDE.md section | Notes |
|--------|-----------------|-------|
| Airflow | *Airflow: breathing* | No changes |
| Body temperature | *Body temperature* | Calibration optional — see [Section 5.6](#56-body-temperature--calibration) |
| ECG | *Electrocardiogram (ECG)* | Ignore jumper instructions |
| GSR / Skin conductance | *Galvanic Skin Response* | Calibration optional — see [Section 5.7](#57-gsr--skin-conductance--calibration) |

---

## 6. GLCD Display Library

The V1 e-Health shield supports a 128×64 pixel Serial Graphic LCD (GLCD) connected via the GLCD
connector. The `eHealthDisplay` library (included in `arduino/libraries/eHealth/`) provides all
the display functions.

> **Note:** When the GLCD is connected, the GLCD connector is in use. On V1 the blood pressure
> sensor also uses this connector via the UART — they **cannot be used simultaneously**.

### Three display screens

The GLCD presents data across three screens, cycled by pressing the push button (digital pin 4):

| Screen | Contents |
|--------|---------|
| 1 — Values | Temperature, pulse (BPM), oxygen saturation (%), body position graphic |
| 2 — Airflow | Breathing waveform, breaths-per-minute counter, apnea alert when no breathing detected |
| 3 — ECG | Electrocardiogram waveform |

Pressing the button again from screen 3 returns to screen 1.

### Including the library

```cpp
#include <PinChangeInt.h>
#include <eHealth.h>
#include <eHealthDisplay.h>
```

### API functions

**Initialization (call once in `setup()`):**

```cpp
eHealthDisplay.init();
```

**Values screen:**

```cpp
eHealthDisplay.initValuesScreen();   // Initialize — call when switching to this screen
eHealthDisplay.printValuesScreen();  // Refresh values — call in loop
```

**Airflow screen:**

```cpp
eHealthDisplay.initAirFlowScreen();  // Initialize — call when switching to this screen
eHealthDisplay.printAirFlowScreen(); // Refresh waveform — call in loop
```

**ECG screen:**

```cpp
eHealthDisplay.initECGScreen();      // Initialize — call when switching to this screen
eHealthDisplay.printECGScreen();     // Refresh waveform — call in loop
```

### Complete GLCD example

```cpp
#include <PinChangeInt.h>
#include <eHealth.h>
#include <eHealthDisplay.h>

#define pushButton 4

uint8_t screenNumber = 1;
uint8_t cont = 0;

void readPulsioximeter() {
  cont++;
  if (cont == 50) {
    eHealth.readPulsioximeter();
    cont = 0;
  }
}

void setup() {
  Serial.begin(115200);
  eHealthDisplay.init();
}

void loop() {
  // Screen 1: numerical values and body position
  eHealthDisplay.initValuesScreen();
  PCintPort::attachInterrupt(6, readPulsioximeter, RISING);
  while (screenNumber == 1) {
    if (digitalRead(pushButton) == 1) screenNumber++;
    eHealthDisplay.printValuesScreen();
    delay(10);
  }
  PCintPort::detachInterrupt(6);

  // Screen 2: airflow waveform
  eHealthDisplay.initAirFlowScreen();
  while (screenNumber == 2) {
    if (digitalRead(pushButton) == 1) screenNumber++;
    eHealthDisplay.printAirFlowScreen();
    delay(10);
  }

  // Screen 3: ECG waveform
  eHealthDisplay.initECGScreen();
  while (screenNumber == 3) {
    if (digitalRead(pushButton) == 1) screenNumber++;
    eHealthDisplay.printECGScreen();
    delay(10);
  }

  screenNumber = 1;
}
```

---

## 7. UART Port Sharing Limitations

The e-Health V1 shield has a single hardware UART shared between several peripherals.
**Only one can be active at a time:**

| Peripheral | UART user |
|-----------|-----------|
| LCD / GLCD screen | Yes |
| Blood pressure sensor (via UART on V1) | Yes |
| Glucometer | Yes |
| Bluetooth module | Yes |
| GPRS module | Yes |
| 3G module | Yes |
| ZigBee / 802.15.4 | Yes |

Practical rules:
- Disconnect the GLCD before reading blood pressure or glucometer data.
- Do not have both the blood pressure sensor and glucometer connected at once.
- Communication modules (Bluetooth, GPRS, etc.) must be disconnected when reading
  from the blood pressure sensor or glucometer.

---

## 8. Power Supply Notes

The V1 shield can be powered via USB from the PC, but some USB ports cannot supply
enough current for all sensors simultaneously.

If the shield behaves erratically or resets unexpectedly, use an **external 12V – 2A**
power supply connected to the Arduino barrel jack instead of USB power.

---

## 9. Compatible Arduino Boards

The V1 shield is compatible with:

- Arduino Uno (Atmega328, recommended)
- Arduino Duemilanove
- Arduino Mega

> The `PinChangeInt` library is required for the SPO2 sensor and works on all three boards.
> On Arduino Mega the pin change interrupt behaviour may differ slightly — prefer Uno or
> Duemilanove for simplest setup.
