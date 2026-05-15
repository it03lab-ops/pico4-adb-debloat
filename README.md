# pico4-adb-debloat

Windows ADB batch script to debloat and tune the **Pico 4** VR headset:  
disable bloatware, apply performance tweaks, manage package configs and install APKs — **without root**. [page:1]

> ⚠️ Use at your own risk. This script is tailored for stock Pico 4 firmware.  
> ❗ Do **not** run it on other Android devices.

A common use case is preparing the headset for kiosk deployments and then installing a kiosk launcher such as [PicoKiosk](https://github.com/it03lab-ops/PicoKiosk). [page:0][page:1]

---

## Features

- **Debloat via ADB:**
  - Disable / enable vendor and system packages using `pm disable-user` / `pm enable`. [page:1]
  - Grouped into sections (safe removals, optional apps, core services, etc.).

- **Kiosk‑oriented tweaks:**
  - Section dedicated to locking down the device for kiosk use:
    - Disable store and content discovery.
    - Block system settings and some file dialogs.
    - Remove obvious escape routes to the stock launcher. [page:1]

- **Configuration management:**
  - Save current package state (enabled/disabled) to `pico4_config.txt`.  
  - Apply the same configuration on another headset or after reset. [page:1]

- **APK management:**
  - Scan the local `apk/` folder.  
  - Install one or all APKs via `adb install` / `adb install -r`. [page:1]

- **No root required:**
  - Everything is done via standard ADB commands.

---

## Requirements

- Windows 10/11 PC.  
- ADB installed and available in `PATH` (or placed next to the script).  
- Pico 4 headset with:
  - Developer mode enabled.
  - USB debugging enabled. [page:1]

---

## Usage

1. **Clone or download the repo**

   ```bash
   git clone https://github.com/it03lab-ops/pico4-adb-debloat.git
   cd pico4-adb-debloat
   ```

2. **Connect the headset**

   - Connect Pico 4 to your PC via USB.  
   - Confirm the USB debugging prompt inside the headset (Allow USB debugging). [page:1]

3. **Run the script**

   - Double-click `pico4-debloat.bat` (actual filename per repo) or run from terminal:

     ```bat
     pico4-debloat.bat
     ```

   - Follow the on-screen menu:
     - Choose sections to debloat.
     - Apply kiosk-related tweaks if you plan to use a kiosk launcher.
     - Optionally save or load a configuration file.
     - Optionally install APKs from the `apk/` folder. [page:1]

4. **Combine with a kiosk launcher**

   For kiosk scenarios, it’s recommended to:

   - Run `pico4-adb-debloat` to harden the device.  
   - Install a kiosk launcher such as [PicoKiosk](https://github.com/it03lab-ops/PicoKiosk). [page:0][page:1]  
   - Set the launcher as the default home activity (via ADB).

---

## Kiosk mode workflow (short)

1. Debloat the device, disable store and extra system UI using `pico4-adb-debloat`. [page:1]  
2. Install your app(s) and the kiosk launcher APK.  
3. Configure the launcher (whitelist apps, protect settings with password). [page:0]  
4. Set the launcher as the default home app via `pm set-home-activity`.  
5. Test all potential escape paths (store, settings, dialogs, notifications).

---

## Relationship to PicoKiosk

`pico4-adb-debloat` is **not** a launcher itself. It prepares the system so that a kiosk launcher can work reliably.

Recommended combo:

- System level: `pico4-adb-debloat` for debloat + lock‑down.  
- UI level: [PicoKiosk](https://github.com/it03lab-ops/PicoKiosk) as the actual kiosk launcher. [page:0][page:1]

---

## Disclaimer

- This script is provided as‑is, without warranty of any kind.  
- You are responsible for any changes applied to your device.  
- Always test on non‑critical hardware before using in production.

---

## License

MIT – see [`LICENSE`](./LICENSE). [page:1]

---

# 🇷🇺 Описание на русском

`pico4-adb-debloat` — это batch‑скрипт для Windows, который управляет шлемом **Pico 4** через ADB:  
помогает убрать лишние приложения, применить твики, сохранить/применить конфиг и установить APK **без root‑прав**. [page:1]

Частый сценарий — подготовить шлем к киоск‑режиму и затем поставить лаунчер вроде [PicoKiosk](https://github.com/it03lab-ops/PicoKiosk). [page:0][page:1]

---

## Возможности

- **Debloat через ADB:**
  - отключение/включение пакетов (`pm disable-user` / `pm enable`);
  - структура по разделам: безопасное отключение, опциональные пакеты, core‑сервисы и т.п. [page:1]

- **Киоск‑режим:**
  - отдельный блок настроек под киоск:
    - отключение магазина и сервисов Discover;
    - блокировка системных настроек и части файловых диалогов;
    - закрытие очевидных выходов в стандартный лаунчер. [page:1]

- **Работа с конфигами:**
  - сохранение текущего состояния пакетов в `pico4_config.txt`;
  - последующее применение этого же набора на других шлемах. [page:1]

- **Установка APK:**
  - сканирование папки `apk/`;
  - установка выбранного или всех APK через `adb install` / `adb install -r`. [page:1]

- **Без root:**
  - используются только стандартные ADB‑команды.

---

## Требования

- ПК с Windows 10/11.  
- ADB в `PATH` или рядом со скриптом.  
- Шлем Pico 4 с включённым:
  - режимом разработчика,
  - USB‑отладкой. [page:1]

---

## Как пользоваться

1. **Склонировать репозиторий**

   ```bash
   git clone https://github.com/it03lab-ops/pico4-adb-debloat.git
   cd pico4-adb-debloat
   ```

2. **Подключить шлем**

   - Подключить Pico 4 по USB к ПК.  
   - В шлеме подтвердить запрос «Разрешить USB‑отладку». [page:1]

3. **Запустить скрипт**

   - Двойной клик по `.bat`‑файлу (например `pico4-debloat.bat`), либо запуск из терминала:

     ```bat
     pico4-debloat.bat
     ```

   - В меню выбрать:
     - какие пакеты отключать;
     - нужно ли включить киоск‑настройки;
     - сохранить ли текущий конфиг;
     - устанавливать ли APK из папки `apk/`. [page:1]

4. **Связка с киоск‑лаунчером**

   Для режима киоска рекомендуется:

   - сначала прогнать `pico4-adb-debloat`,  
   - затем установить [PicoKiosk](https://github.com/it03lab-ops/PicoKiosk) как лаунчер; [page:0][page:1]  
   - назначить его лаунчером по умолчанию через `pm set-home-activity`.

---

## Сценарий для киоск‑режима (коротко)

1. Отключить всё лишнее и заблокировать магазин/настройки через `pico4-adb-debloat`.  
2. Установить свои приложения и лаунчер (например, PicoKiosk).  
3. В лаунчере настроить белый список и пароль на настройки. [page:0]  
4. Назначить лаунчер home‑приложением.  
5. Проверить, что пользователь не может выйти в системный интерфейс.

---

## Отказ от ответственности

- Всё используется «как есть», без гарантий.  
- Ответственность за любые изменения с устройством несёте вы.  
- Перед боевым использованием тестируйте на резервном шлеме.

---

## Лицензия

MIT — см. [`LICENSE`](./LICENSE). [page:1]
