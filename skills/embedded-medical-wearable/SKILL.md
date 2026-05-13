---
name: embedded-medical-wearable
description: Architecture, component selection, firmware design, and regulatory considerations for a medical wearable device (smartwatch-class) that records patient vital signs (SpO2, ECG, heart rate, temperature, motion). Covers MCU selection (ESP32-S3, nRF52840, RP2040), medical sensor selection with regulatory implications, BLE 5.x design, power management, IEC 60601-1 electrical safety, IEC 62304 software lifecycle, and validation against certified reference devices. Use when designing, prototyping, or documenting a medical wearable.
version: 0.1.0
---

# Embedded Medical Wearable

## When to use
- Designing or prototyping a wrist-worn medical wearable.
- Choosing components for a vital-signs monitoring device.
- Planning the regulatory pathway for a wearable that will be used clinically.
- Validating sensor accuracy against reference devices.

## Process

### Phase 1 — Define the device classification first

Before touching hardware, decide what this device IS legally:

| Use case | Likely classification (EU MDR 2017/745) | Implications |
|---|---|---|
| Personal wellness, no diagnosis | Not a medical device | No CE-MDR needed; standard CE-RED for radio still applies |
| Vital signs monitoring for diagnosis | Class IIa or IIb SaMD | Notified Body involvement, IEC 60601, IEC 62304, ISO 13485, ISO 14971 |
| Connected to clinical decision-making | Class IIa minimum | Full MDR documentation, post-market surveillance |
| Continuous monitoring of intensive care patients | Class IIb or III | Higher rigor; consider partnering with established manufacturer |

Decision rule: if the device output **changes clinical decisions**, it is medical-grade. The bar is high — sensor accuracy must be validated, software must follow IEC 62304, and the entire QMS must follow ISO 13485.

For a research-grade prototype intended only for studies, you can proceed without full certification but must:
- State explicitly "research use only, not for diagnosis".
- Get IRB/CEIm approval for any human use.
- Validate against a CE-marked reference device.

### Phase 2 — MCU selection

| MCU | Strengths | Weaknesses | Best for |
|---|---|---|---|
| **ESP32-S3** | WiFi + BLE, dual-core, cheap, FreeRTOS, large ecosystem, AI accelerator | High power consumption (~50mA active), poor battery life | Prototyping, hospital wifi-connected device |
| **nRF52840** | Excellent BLE 5.x, very low power (~3-7 µA sleep), Zephyr RTOS first-class | More complex toolchain, no WiFi | Production wearable, battery-critical |
| **nRF5340** | Dual-core (app + network), nRF52840 successor, better security | Newer, less example code | Production, future-proof |
| **RP2040 / RP2350** | Cheap, MicroPython-friendly, dual-core ARM | No native BLE on RP2040 (need module), limited libraries for medical sensors | Educational, internal projects |
| **STM32WB55** | BLE + Cortex-M4, FreeRTOS or bare-metal | Steeper learning curve | Industrial-grade, when stability matters |

**Recommendation for your prototype**: nRF52840 (DK or Adafruit Feather Sense) running Zephyr RTOS. Migrate to nRF5340 for production.

For ML inference on-device (anomaly detection, arrhythmia classification): nRF52840 + TensorFlow Lite Micro is feasible for small models; for larger models consider nRF5340 or external accelerator.

### Phase 3 — Sensor selection

#### Pulse oximetry (SpO2) and heart rate (PPG)
| Sensor | Grade | Notes |
|---|---|---|
| MAX30102 | Consumer | Hobbyist standard. NOT certified medical. PPG signal quality acceptable for HR; SpO2 needs careful calibration |
| MAX30101 | Consumer | More LEDs (red/green/IR), better for skin tone variability |
| MAXM86161 | Reference design (medical) | Maxim's medical reference; better SNR, dedicated AFE |
| MAX86150 | Combined PPG + ECG | Useful for combined wearable |

For a research wearable, MAX30102 + good algorithm + reference validation is the practical choice. For a medical product, you need a sensor with a documented datasheet stating intended medical use AND must validate per ISO 80601-2-61 (pulse oximeter standard).

#### ECG
| Sensor | Grade | Notes |
|---|---|---|
| AD8232 | Educational | Single-lead, hobbyist. NOT for clinical use |
| MAX30003 | Medical-grade AFE | Used in many Class II products; supports ECG analytics |
| ADS1292R | Medical-grade | 2-channel, 24-bit, used in commercial wearables |
| TI AFE4900 | Combined ECG + PPG | One-chip biosensor AFE |

For arrhythmia detection, MAX30003 or ADS1292R are the realistic minimum.

#### Temperature
| Sensor | Type | Notes |
|---|---|---|
| MAX30205 | Body contact (skin) | ±0.1°C, designed for wearables |
| MLX90614 | Infrared (forehead) | Non-contact, used in clinical thermometers |
| TMP117 | Contact, ultra-precise | ±0.1°C, often used as reference |

Skin temperature is NOT core temperature. Document this limitation explicitly. For research, MAX30205 on the wrist + a calibration model to estimate something proxy-like is acceptable; for clinical use, this is harder.

#### Motion
| Sensor | Notes |
|---|---|
| BMI270 | 6-axis IMU (accel + gyro), low power, used in commercial wearables |
| ICM-20948 | 9-axis (with mag), heavier on power |
| LSM6DSO | ST equivalent, good ecosystem |

For activity recognition, fall detection, sleep staging: BMI270 or LSM6DSO with embedded ML features (some have on-chip activity classifiers).

#### GPS (optional, for outdoor mode)
- u-blox NEO-M9N: best in class accuracy and consumption profile.
- u-blox MAX-M10S: smaller, very low power.
- Avoid NEO-6M for production: outdated, weaker sensitivity.

### Phase 4 — Communication architecture

#### BLE 5.x (primary)
- Use as **GATT peripheral**: device exposes services, app/gateway is client.
- Standard services to consider:
  - **Heart Rate Service** (0x180D) — standardized, interoperable.
  - **Pulse Oximeter Service** (0x1822).
  - **Health Thermometer Service** (0x1809).
  - For custom data, define a **custom service UUID** with characteristics for SpO2 raw, ECG samples, etc.
- Use **L2CAP CoC** (connection-oriented channels) for high-throughput streaming (raw ECG/PPG).
- BLE 5.0 PHY: use **Coded PHY** for range, **2M PHY** for throughput.

#### Wi-Fi (secondary, hospital deployments)
- Only for non-portable mode (charging dock with WiFi), or hospital-fixed devices.
- Wi-Fi consumption (~50-150 mA) kills battery.

#### LoRa (option for rural/remote monitoring)
- Long-range, low data rate.
- Useful only if patient is far from a smartphone gateway.

### Phase 5 — Power management

A wearable should target **5-7 days battery life** minimum.

Power budget for a typical wrist device:
- nRF52840 sleep (interval connection 1s): ~5-15 µA average.
- BLE advertising: ~10-30 µA average depending on interval.
- PPG sensor active (1Hz sample): ~1-2 mA average duty-cycled.
- ECG sensor active: ~5-10 mA when measuring.
- Display (OLED): 5-15 mA when ON; e-paper: ~0 mA between updates.

Strategies:
- **Duty cycling**: take vitals every N minutes, sleep otherwise. 1-min PPG every 5 min is a sane default.
- **Event-driven activation**: motion sensor wakes the device only when needed.
- **OLED off most of the time**, wake on wrist tilt or button.
- **Battery**: 100-200 mAh LiPo for compact wrist device. With proper duty cycling, 5+ days achievable.
- **Charging**: USB-C with TP4056 or BQ24074 (the latter handles power path, prevents over-discharge).
- **Fuel gauge**: MAX17048 (simple, software-only) or MAX17260 (better accuracy).

### Phase 6 — Software architecture

Recommended stack:
- **Zephyr RTOS** on nRF52840/nRF5340. Active community, BLE first-class, huge sample base.
- **PlatformIO** or **west** for build system.
- **Bluetooth host stack**: Zephyr's built-in.
- **Sensor drivers**: Zephyr has built-in sensor API; add custom drivers only when necessary.
- **Logging**: Zephyr's logging subsystem.
- **DFU (over-the-air firmware update)**: MCUboot + nRF Connect SDK provides this out of the box.
- **Storage**: NVS (Non-Volatile Storage) for config; littlefs for log files; external flash if storing raw waveforms.
- **Time sync**: BLE Current Time Service from the gateway/app.

Source code structure:
```
src/
├── main.c               // App entry, RTOS init
├── ble/
│   ├── ble_init.c       // GAP, GATT services init
│   ├── service_hrs.c    // Heart Rate Service
│   ├── service_pls.c    // Pulse Oximeter Service
│   └── service_custom.c // Custom service for raw data
├── sensors/
│   ├── ppg.c
│   ├── ecg.c
│   ├── temp.c
│   └── imu.c
├── algorithms/
│   ├── hr_estimation.c  // PPG -> HR
│   ├── spo2.c
│   └── arrhythmia.c
├── power/
│   ├── battery.c        // Fuel gauge
│   └── lp_mgmt.c        // Sleep state machine
├── ui/
│   └── display.c        // OLED/e-paper UI
└── storage/
    └── log.c
```

### Phase 7 — Validation

For a research device, validation against a reference is mandatory:

- **HR**: against a 12-lead ECG (Holter) for 24h; report Bland-Altman LoA, MAPE, sensitivity for arrhythmias.
- **SpO2**: against a CE-marked pulse oximeter (e.g., Masimo Rad-7 or similar) under controlled hypoxia or with clinical data; report bias and ARMS (Accuracy Root-Mean-Square per ISO 80601-2-61).
- **ECG**: against a clinical 1-lead or 12-lead ECG; report waveform morphology correlation, R-peak detection sensitivity/PPV.
- **Temperature**: against a CE-marked thermometer; report mean bias and 95% LoA.

For ANY clinical claim, you need IRB/CEIm approval and informed consent.

### Phase 8 — Regulatory checklist (for the medical pathway)

If you decide to go medical-grade:

- [ ] **ISO 13485 QMS** (quality management system) — most expensive single thing.
- [ ] **ISO 14971** risk management process documented (FMEA, risk analysis per intended use).
- [ ] **IEC 60601-1** general safety (electrical, mechanical, EMC IEC 60601-1-2).
- [ ] **IEC 60601-2-X** particular standards (e.g., 60601-2-49 for multifunction patient monitor, 80601-2-61 for SpO2).
- [ ] **IEC 62304** software lifecycle (Class B if non-life-supporting; Class C if life-supporting).
- [ ] **IEC 62366-1** usability engineering.
- [ ] **ISO 10993** biocompatibility for skin-contact materials.
- [ ] **MDR Annex II** technical documentation.
- [ ] **Clinical evaluation** (literature + own evidence).
- [ ] **Notified Body** for Class IIa+.

This is multi-year, multi-€100K-1M effort. For a research wearable, document your gaps but skip certification.

## Anti-patterns

| Pattern | Why it fails | Correction |
|---|---|---|
| MAX30102 marketed as "medical SpO2" | Not certified, misleading | State "research-grade", validate, disclose limitations |
| AD8232 with claims of arrhythmia detection | Single-lead consumer AFE, not medical | Use MAX30003 or ADS1292R for any clinical claim |
| Skin temp reported as "body temperature" | Categorically different metric | Report skin temp explicitly; build calibration model if you want core temp estimate |
| ESP32 in always-on mode "for simplicity" | Battery dies in hours | Design for sleep mode from day 1 |
| BLE custom protocol when GATT services exist | Interoperability lost | Use standard services where possible |
| No DFU (firmware update) plan | Cannot fix bugs in deployed devices | MCUboot + signed updates from day 1 |
| Validation = "I tested it on myself" | Anecdotal, no evidence | Bland-Altman vs CE-marked reference; n ≥ 10 subjects minimum |
| No risk management documentation | Reviewers reject any clinical study | ISO 14971 FMEA from prototype stage |
| Antenna as afterthought | Range issues, FCC/CE-RED failures | RF design from PCB layout stage; consider chip antenna with manufacturer reference design |

## Verification gates

Before declaring a prototype "ready":

- [ ] MCU + sensors + battery + charging on the same PCB (or modular but stable).
- [ ] BLE GATT working, tested with nRF Connect mobile app.
- [ ] Sleep current measured and matches budget (<20 µA target).
- [ ] DFU procedure tested end-to-end.
- [ ] At least 24h continuous logging without reset.
- [ ] Validation data collected against reference for HR + SpO2 + temp (n ≥ 10 if humans, with IRB).
- [ ] Risk register documented (even if informal).

## Resources

- **Zephyr RTOS**: https://docs.zephyrproject.org/
- **nRF Connect SDK**: https://www.nordicsemi.com/Products/Development-software/nRF-Connect-SDK
- **KiCad** for schematic + PCB.
- **JLCPCB / PCBWay** for low-volume manufacturing (assembly with SMT possible).
- **IEC 62304 simplified**: AAMI TIR45 for agile within 62304.
- **ISO 14971 templates**: https://www.iso.org/standard/72704.html
- **MDR**: https://eur-lex.europa.eu/eli/reg/2017/745/oj
