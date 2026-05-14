# pico4-adb-debloat
Windows ADB batch script to debloat and tune Pico 4 headset: disable bloatware, apply performance tweaks, manage configs and install APKs without root. \ Batch-скрипт для Windows, который очищает, настраивает и обслуживает Pico 4 по ADB: отключение bloatware, твики, работа с конфигами и установка APK без root.


# Pico 4 ADB Debloat Script

Windows batch script to **debloat** and tune a Pico 4 headset via ADB:  
disable unwanted system apps, apply performance tweaks, manage configs and install APKs, all **without root**. [web:98][web:109]

> Use at your own risk.  
> You are responsible for changes you make to your device.

---

## Features

- Disable / enable selected system and vendor apps via ADB (`pm disable-user` / `pm enable`). [web:98][web:109]  
- Four logical sections:
  - Section 1 – Safe removals (telemetry, demos, extra services).
  - Section 2 – Core apps (launcher, browser, services, TOB apps).
  - Section 3 – Optional packages, app compilation, performance tweaks.
  - Section 4 – Kiosk mode (lockdown: store, settings, etc.).
- Colored package status output (enabled/disabled).
- Centralized logging to `pico4_debloat.log`.
- Save current package state into `pico4_config.txt`.
- Apply configuration from `pico4_config.txt` later on another device.
- Revert function to re‑enable all known packages and reset some system settings.
- APK installer:
  - Detect `.apk` files in local `apk` folder.
  - Install a single APK or all APKs with `adb install` / `adb install -r`. [web:98][web:101]

---

## Requirements

- Windows 10/11.
- [Android Platform Tools (ADB)](https://developer.android.com/tools/adb) installed and added to `PATH`. [web:98]  
- Pico 4 headset with:
  - Developer mode enabled.
  - USB debugging enabled.
  - USB cable connection to your PC.
- Basic understanding of what you are disabling.

---

## Usage

1. Install ADB (Android platform-tools) and ensure `adb` is available in `cmd`. [web:98]  
2. Download this repository as ZIP or clone it:

   ```bash
   git clone https://github.com/<your-username>/pico4-adb-debloat.git
   ```

3. Connect your Pico 4 via USB and allow USB debugging on the headset if prompted.
4. Run `Pico4Debloat.bat` (or whatever you name the script) as a normal user (administrator is not required in most cases).
5. Follow on-screen menu:

   - Section 1: safe bloatware removal (telemetry, demo scenes, dev tools).
   - Section 2: core preinstalled apps (launcher, browser, fitness, TOB, etc.).
   - Section 3: optional packages, app compilation, performance & network tweaks.
   - Section 4: kiosk mode (lock down store, settings, file dialogs, etc.).
   - Save config / apply config.
   - Install APKs from `apk` folder.

---

## Configuration file

The script can save and reapply your current package state.

- `pico4_config.txt` is stored next to the script.
- Format (one command per line):

  ```text
  # Pico 4 configuration generated on YYYY-MM-DD HH:MM:SS
  # format: action package_name

  disable com.picovr.store
  disable com.bytedance.os.slardar
  ```

- `SAVE CURRENT CONFIGURATION TO FILE`:
  - Scans the known package lists and saves `disable` lines for all disabled packages.
- `APPLY CONFIGURATION FROM FILE`:
  - Reads `pico4_config.txt` and runs the corresponding ADB actions.

---

## APK installation

The script includes a simple APK installer:

- Create an `apk` folder next to the batch script.
- Put your `.apk` files into `apk/`.
- Choose `INSTALL APKs FROM "apk" FOLDER` in the main menu.

You can:

- Install a single APK by number.
- Install all APKs in the folder.
- Choose install mode:
  - `adb install` – fresh install.
  - `adb install -r` – reinstall while preserving app data. [web:98][web:101]

---

## Safety notes

- Always read the description shown for each package before disabling it.
- Disabling system components may:
  - Break some functionality.
  - Affect updates.
  - Require a reset or manual recovery using ADB.
- Use the **REVERT ALL CHANGES** option if you run into issues:
  - It re‑enables all packages known to this script.
  - It also resets several system `settings` / `device_config` keys back to defaults.

---

## Known limitations

- Script is tailored for Pico 4 and its stock firmware; other devices are not supported.
- Package lists may change between firmware versions; after OTA updates you may need to review them.
- Some system services can re‑enable or recreate components on updates or factory reset.

---

## License

MIT License
Copyright (c) 2026 <ProBot>
Permission is hereby granted, free of charge, to any person obtaining a copy
