# PicoKiosk

**Kiosk-mode launcher for PICO 4 (and possibly Meta Quest) VR headsets**  
Based on [PicoZen](https://github.com/barnabwhy/PicoZen) by [barnabwhy](https://github.com/barnabwhy), with major modifications for restricted public use.

> ⚠️ Unofficial project – not affiliated with PICO or Meta.  
> ✅ Designed for scenarios where a VR headset is shared by multiple users (museums, showrooms, training, demo stands, etc.).  
> 🔒 Locks the user into approved apps only – no access to system settings, home button, notification bar.

PicoKiosk is usually used **together** with the companion tool  
[`pico4-adb-debloat`](https://github.com/it03lab-ops/pico4-adb-debloat),  
which prepares the headset for kiosk deployment (disables bloatware, locks the store and system UI, applies tweaks, installs required APKs). [page:1]

---

## Why two projects?

PicoKiosk and `pico4-adb-debloat` solve different parts of the kiosk puzzle:

| Layer                      | Tool                         | Purpose |
|---------------------------|------------------------------|---------|
| System / firmware level   | `pico4-adb-debloat`          | Clean and harden the system via ADB (disable bloatware, lock store and settings, apply performance tweaks, manage configs, install APKs). [page:1] |
| Application / UI level    | PicoKiosk (this repo)        | Replace the default launcher with a locked-down app selector (whitelist), block access to system UI and restrict user navigation. [page:0] |

You can use PicoKiosk alone, but **for a real kiosk-like, tamper-resistant setup on Pico 4** it is strongly recommended to run `pico4-adb-debloat` first and then install and configure PicoKiosk. [page:0][page:1]

---

## 🎯 Features (vs original PicoZen)

| Feature                                               | PicoZen (original) | PicoKiosk (this fork) |
|-------------------------------------------------------|--------------------|------------------------|
| Show all installed apps                               | ✅                 | ❌ (whitelist only)    |
| Admin-controlled app whitelist                        | ❌                 | ✅                     |
| Block system settings access                          | ❌                 | ✅                     |
| Block notification bar / quick settings               | ❌                 | ✅                     |
| Prevent exit to system launcher (HOME button)         | ❌                 | ✅                     |
| Sideloading APKs                                      | ✅                 | ✅ (optional)          |
| Password-protected settings                           | ❌                 | ✅                     |
| Password-protected “Hidden” apps list                 | ❌                 | ✅                     |

---

## 🔗 Companion tool: pico4-adb-debloat

[`pico4-adb-debloat`](https://github.com/it03lab-ops/pico4-adb-debloat) is a Windows batch script to **debloat and tune** a Pico 4 headset via ADB. [page:1]

Key capabilities:

- Disable / enable selected system and vendor apps (`pm disable-user` / `pm enable`). [page:1]  
- Several logical sections, including:
  - Safe removals (telemetry, demos, extra services).
  - Core apps (launcher, browser, TOB apps, etc.).
  - Optional packages and performance/network tweaks.
  - **Kiosk mode** section – lock down store, settings, file dialogs and other escape routes. [page:1]
- Configuration file support:
  - Save current package state into `pico4_config.txt`.  
  - Apply the same configuration on another device. [page:1]
- Simple APK installer:
  - Scan `apk/` folder and install one or all APKs via `adb install` / `adb install -r`. [page:1]

Using it before deploying PicoKiosk allows you to:

- Remove distractions and bloatware from system UI.  
- Disable system store and built-in launchers that can be used to escape.  
- Apply the same hardened config to multiple headsets.

See the full documentation in the [`pico4-adb-debloat` README](https://github.com/it03lab-ops/pico4-adb-debloat). [page:1]

---

## ⚙️ Recommended deployment flow (Pico 4)

1. **Prepare the headset with `pico4-adb-debloat`:** [page:1]  
   - Enable developer mode and USB debugging on Pico 4.  
   - Connect the headset to a Windows PC with ADB installed.  
   - Run the script, go through the sections:
     - Remove / disable bloatware and non-essential apps.
     - Lock down store, system settings and file dialogs (kiosk section).
     - Install required APKs (your app, PicoKiosk, additional tools) from the `apk/` folder.

2. **Install and configure PicoKiosk:** [page:0]  
   - Build or download the PicoKiosk APK (see below).  
   - Sideload it via ADB or SideQuest.  
   - Launch PicoKiosk from the system launcher.  
   - Open the settings (protected by password) and:
     - Set / change admin password.  
     - Configure the app whitelist (only apps you want users to see).  
     - Adjust other options (start on boot, icon caching, etc.).  

3. **Set PicoKiosk as default launcher (home app):**  
   - On Pico 4, you may need ADB to force PicoKiosk as the home activity, for example:  
     `adb shell pm set-home-activity com.yourname.picokiosk/.MainActivity`  
   - Confirm that pressing the Home or system button always returns to PicoKiosk and not to the stock launcher.

4. **Test escape paths:**  
   - Try notification bar, quick settings, store, system dialogs, etc.  
   - If you find an escape path, adjust:
     - ADB debloat configuration (disable another package or feature).  
     - PicoKiosk whitelist / hidden apps.

---

## ⚠️ Compatibility & Caveats

- **Primary target:** PICO 4 (tested on PICO 4). Should also work on Pico Neo 3 family, but not guaranteed. [page:0]  
- **Meta Quest (Quest 2/3/Pro):** Untested. PicoZen was reported to work on Quest, so PicoKiosk may run, but system UI blocking will be limited because Meta’s VROS behaves differently. Use at your own risk. [page:0]  
- **Android version requirement:** Android 10+ (typical for modern XR headsets). [page:0]  
- `pico4-adb-debloat` is tailored specifically for Pico 4 stock firmware; do not use it on other devices. [page:1]  

---

## 📥 Installation

1. **Build or download PicoKiosk APK**

   At the moment there are no prebuilt releases; you are expected to build from source:

   ```bash
   git clone https://github.com/it03lab-ops/PicoKiosk.git
   cd PicoKiosk
   # Open in Android Studio, sync Gradle, then:
   # Build -> Build APK(s)
   ```

   The APK will be located under `app/build/outputs/apk/…`. [page:0]

2. **Sideload the APK**

   Use ADB or SideQuest to install the APK on your headset:

   ```bash
   adb install PicoKiosk-release.apk
   ```

3. **Launch PicoKiosk**

   - Find PicoKiosk in the system app list and launch it once.  
   - Grant any overlay / notification or storage permissions if requested (depending on your build config).

4. **Set as default launcher**

   - Use ADB to set PicoKiosk as the home activity, e.g.:

     ```bash
     adb shell pm set-home-activity com.yourname.picokiosk/.MainActivity
     ```

   Replace `com.yourname.picokiosk` with the actual package name used in your build.

5. (Optional but recommended) **Run `pico4-adb-debloat`** before or after installing PicoKiosk to harden the system and remove escape paths. [page:1]

---

## 🔧 Building from source

- Clone the repository:

  ```bash
  git clone https://github.com/it03lab-ops/PicoKiosk.git
  cd PicoKiosk
  ```

- Open the project in **Android Studio**, let Gradle sync.  
- Adjust `applicationId` and signing configs if you plan to distribute the APK.  
- Build → **Build APK(s)** or **Generate Signed Bundle / APK**. [page:0]

---

## 🧩 Relationship to PicoZen

This project is a fork of [PicoZen](https://github.com/barnabwhy/PicoZen), which is a general-purpose VR launcher. PicoKiosk focuses specifically on **kiosk / locked-down deployments**, and therefore:

- Removes or hides features that are not needed in kiosk scenarios.  
- Adds password-protected settings and hidden apps pages.  
- Integrates better with ADB-based hardening flows like `pico4-adb-debloat`. [page:0][page:1]

---

## ❗ Disclaimer

- This software is provided **as is**, without any warranty.  
- You are fully responsible for changes you apply to your devices, both via PicoKiosk and via `pico4-adb-debloat`.  
- Always test on non-critical hardware before rolling out to public setups.

---

## License

- **PicoKiosk:** GPL-3.0, see [`LICENSE`](./LICENSE). [page:0]  
- **pico4-adb-debloat:** MIT, see its [`LICENSE`](https://github.com/it03lab-ops/pico4-adb-debloat/blob/main/LICENSE). [page:1]
