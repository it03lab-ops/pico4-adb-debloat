@echo off
title Pico 4 ADB Debloat Script 0.24
color 0b
setlocal enabledelayedexpansion

:: Path to script directory
set "SCRIPT_DIR=%~dp0"

:: Log and config files in script directory
set "LOG=%SCRIPT_DIR%pico4_debloat.log"
set "CFG=%SCRIPT_DIR%pico4_config.txt"

:: Enable ANSI colors if supported (Windows 10+)
set "USE_COLORS=1"
call :SetESC

:: ==========================================================
:: GLOBAL PACKAGE LISTS (used in sections and SaveConfig)
:: ==========================================================
set "S1_LIST=com.android.bips com.android.bookmarkprovider com.android.carrierconfig.overlay.common com.android.egg com.android.ondevicepersonalization.services com.android.printservice.recommendation com.android.providers.blockednumber com.android.providers.userdictionary com.android.role.notes.enabled com.android.safetycenter.resources com.android.server.telecom.overlay.common com.android.simappdialog com.android.theme.font.notoserifsource com.android.traceur com.android.uwb.resources com.android.wallpaperbackup com.android.wallpapercropper com.pvr.tobactivate os.teatracker com.sohu.inputmethod.sogou.car com.picovr.guide com.pvr.ZeroIsland.scene com.pvr.MoonshadowDunes.scene com.pvr.ZeroIslandNight.scene com.pvr.WoodenHouse.scene com.pvr.SeaviewVilla.scene com.pvr.MountainVilla.scene com.pico.performancetool com.picovr.factorytest com.picovr.preview com.picoxr.ControllerTest com.bytedance.os.slardar com.bytedance.os.feedback com.bytedance.pico.screencapture com.pico.developerhubservice com.picovr.share com.picovr.provision com.pvr.camera com.pvr.roomcapture com.pico.syncappdata.service com.pvr.swift"
set "S2_LIST=com.picovr.firmwareupdate com.picovr.updatesystem com.picovr.picostreamassistant com.picoxr.bstreamassistant com.pico.browser.overseas com.pvr.pvrfit com.pvr.avatareditor com.pvr.picocast com.picopui.im com.pvr.home com.pvr.filemanager com.bytedance.pico.tob.userservice com.picovr.enterpriseassistant com.picovr.tobvrusercenter com.picoxr.tobmdm com.picoxr.tobstore com.pvr.tobhome com.pvr.tobservice"
set "S3_LIST=com.android.inputmethod.latin com.android.hotspot2.osulogin com.android.musicfx com.picoxr.mirrorcast com.pvr.lanserver com.qualcomm.wfd.service com.qualcomm.qti.qms.service.trustzoneaccess vendor.qti.qesdk.sysservice com.qualcomm.qti.dynamicddsservice com.quicinc.voice.activation"
set "S4_LIST=com.picovr.store com.picovr.vrusercenter com.picovr.settings com.android.documentsui com.picovr.keyguard com.android.vpndialogs com.picovr.mdm"

:Start
cls
echo ==========================================
echo PICO 4 ADB DEBLOAT SCRIPT 0.24
echo ==========================================
echo.
echo This script will help you manage your Pico 4.
echo You can disable/enable packages, view lists, save and apply configs.
echo.
echo Make sure your Pico 4 is connected through USB.
echo.
pause
echo.
echo [+] Checking ADB and connection to your Pico 4 headset...

:: Check ADB availability and set ADB_CMD
where adb >nul 2>nul
if %errorlevel% neq 0 (
    if exist "%SCRIPT_DIR%adb.exe" (
        set "ADB_CMD=%SCRIPT_DIR%adb.exe"
    ) else (
        color 0c
        echo.
        echo [ERROR] ADB not found! Please install ADB and add to PATH.
        echo.
        echo Press any key to exit...
        pause >nul
        exit /b
    )
) else (
    set "ADB_CMD=adb"
)

:: Check device connection
%ADB_CMD% devices | findstr /r "device$" >nul
if %errorlevel% neq 0 (
    color 0c
    echo.
    echo [ERROR] No Pico 4 detected!
    echo 1. Make sure it is connected via USB.
    echo 2. Make sure USB Debugging is ON in Developer Options on the headset.
    echo 3. Check if you have allowed USB debugging on the headset dialog.
    echo.
    echo Press any key to try again...
    pause >nul
    color 0b
    goto :Start
)

echo [OK] Device detected!
echo.

echo [+] Ensuring Developer mode and ADB are enabled on the device...
%ADB_CMD% shell settings put global development_settings_enabled 1
%ADB_CMD% shell settings put global adb_enabled 1

%ADB_CMD% shell echo devcheck >nul 2>&1
if %errorlevel% neq 0 (
    color 0c
    echo.
    echo [WARNING] Unable to execute ADB shell commands properly.
    echo Make sure:
    echo  - Developer mode is enabled on the Pico 4
    echo  - USB Debugging is turned on
    echo  - You allowed the computer in the USB debugging dialog.
    echo.
    echo Press any key to retry...
    pause >nul
    color 0b
    goto :Start
)

echo [OK] Developer settings / ADB flag applied (if supported by firmware).
echo.
timeout /t 1 >nul

:MainMenu
cls
echo =============== MAIN MENU ===============
echo.
echo [1] SECTION 1: SAFE REMOVALS (unused / demo / telemetry)
echo [2] SECTION 2: CORE APPS (preinstalled by manufacturer)
echo [3] SECTION 3: OPTIONAL - PROCEED WITH CARE
echo [4] SECTION 4: KIOSK MODE (lockdown for kiosk)
echo [5] Show DISABLED packages
echo [6] Show ENABLED packages
echo [7] REVERT ALL CHANGES
echo [8] SAVE CURRENT CONFIGURATION TO FILE
echo [9] APPLY CONFIGURATION FROM FILE
echo [0] EXIT
echo [A] INSTALL APKs FROM "apk" FOLDER
echo.
choice /c 0123456789A /n /m "Enter your choice: "

if %errorlevel%==1  goto :ExitScript       & rem 0
if %errorlevel%==2  goto :Section1         & rem 1
if %errorlevel%==3  goto :Section2         & rem 2
if %errorlevel%==4  goto :Section3         & rem 3
if %errorlevel%==5  goto :Section4         & rem 4
if %errorlevel%==6  goto :ShowDisabled     & rem 5
if %errorlevel%==7  goto :ShowEnabled      & rem 6
if %errorlevel%==8  goto :ConfirmRevertAll & rem 7
if %errorlevel%==9  goto :SaveConfig       & rem 8
if %errorlevel%==10 goto :ApplyConfig      & rem 9
if %errorlevel%==11 goto :InstallApks      & rem A

goto :MainMenu

:ExitScript
echo Exiting script.
exit /b

:: ==========================================================
:: HELPER: SET ESC FOR ANSI
:: ==========================================================
:SetESC
for /F %%a in ('"prompt $E & for %%b in (1) do rem"') do set "ESC=%%a"
exit /b

:: ==========================================================
:: HELPER: LOG AND ACTIONS (with error checking)
:: ==========================================================
:DoAction
:: %1 = action (disable/enable)
:: %2 = package
if "%~2"=="" exit /b

if /i "%~1"=="disable" (
    echo [%date% %time%] DISABLE %2>>"%LOG%"
    echo Disabling %2...
    %ADB_CMD% shell pm disable-user %2>>"%LOG%" 2>&1
    if !errorlevel! neq 0 echo [WARNING] Failed to disable %2>>"%LOG%"
    exit /b
)

if /i "%~1"=="enable" (
    echo [%date% %time%] ENABLE %2>>"%LOG%"
    echo Enabling %2...
    %ADB_CMD% shell pm enable %2>>"%LOG%" 2>&1
    if !errorlevel! neq 0 echo [WARNING] Failed to enable %2>>"%LOG%"
    exit /b
)

exit /b

:: ==========================================================
:: HELPER: CHECK PACKAGE STATUS (with optional colors)
:: ==========================================================
:CheckStatus
set "status=ENABLED"
set "statusColor=ENABLED"
%ADB_CMD% shell pm list packages -d 2>nul | findstr /i "package:%1$" >nul
if %errorlevel%==0 (
    set "status=DISABLED"
)
if "%USE_COLORS%"=="1" (
    if "%status%"=="ENABLED"  set "statusColor=%ESC%[32mENABLED%ESC%[0m"
    if "%status%"=="DISABLED" set "statusColor=%ESC%[31mDISABLED%ESC%[0m"
) else (
    set "statusColor=%status%"
)
exit /b

:: ==========================================================
:: HELPER: SHORT PACKAGE DESCRIPTION FOR LISTS
:: ==========================================================
:GetShortDesc
set "shortDesc="
if "%~1"=="com.android.bips"                      set "shortDesc=Print service"
if "%~1"=="com.android.bookmarkprovider"          set "shortDesc=Bookmarks"
if "%~1"=="com.android.carrierconfig.overlay.common" set "shortDesc=Carrier config"
if "%~1"=="com.android.egg"                       set "shortDesc=Android easter egg"
if "%~1"=="com.android.ondevicepersonalization.services" set "shortDesc=Personalization"
if "%~1"=="com.android.printservice.recommendation" set "shortDesc=Print recommend"
if "%~1"=="com.android.providers.blockednumber"   set "shortDesc=Blocked numbers"
if "%~1"=="com.android.providers.userdictionary"  set "shortDesc=User dictionary"
if "%~1"=="com.android.role.notes.enabled"        set "shortDesc=Notes role"
if "%~1"=="com.android.safetycenter.resources"    set "shortDesc=Safety center"
if "%~1"=="com.android.server.telecom.overlay.common" set "shortDesc=Telecom overlay"
if "%~1"=="com.android.simappdialog"              set "shortDesc=SIM dialog"
if "%~1"=="com.android.theme.font.notoserifsource" set "shortDesc=Noto font"
if "%~1"=="com.android.traceur"                   set "shortDesc=Tracing (dev)"
if "%~1"=="com.android.uwb.resources"             set "shortDesc=UWB resources"
if "%~1"=="com.android.wallpaperbackup"           set "shortDesc=Wallpaper backup"
if "%~1"=="com.android.wallpapercropper"          set "shortDesc=Wallpaper cropper"
if "%~1"=="com.pvr.tobactivate"                   set "shortDesc=Enterprise TOB"
if "%~1"=="os.teatracker"                         set "shortDesc=Telemetry"
if "%~1"=="com.sohu.inputmethod.sogou.car"        set "shortDesc=Sogou keyboard"
if "%~1"=="com.picovr.guide"                      set "shortDesc=Welcome guide"
if "%~1"=="com.pvr.ZeroIsland.scene"              set "shortDesc=Demo scene"
if "%~1"=="com.pvr.MoonshadowDunes.scene"         set "shortDesc=Demo scene"
if "%~1"=="com.pvr.ZeroIslandNight.scene"         set "shortDesc=Demo scene"
if "%~1"=="com.pvr.WoodenHouse.scene"             set "shortDesc=Demo scene"
if "%~1"=="com.pvr.SeaviewVilla.scene"            set "shortDesc=Demo scene"
if "%~1"=="com.pvr.MountainVilla.scene"           set "shortDesc=Demo scene"
if "%~1"=="com.pico.performancetool"              set "shortDesc=Perf tool"
if "%~1"=="com.picovr.factorytest"                set "shortDesc=Factory test"
if "%~1"=="com.picovr.preview"                    set "shortDesc=Preview app"
if "%~1"=="com.picoxr.ControllerTest"             set "shortDesc=Controller test"
if "%~1"=="com.bytedance.os.slardar"              set "shortDesc=Analytics"
if "%~1"=="com.bytedance.os.feedback"             set "shortDesc=Feedback"
if "%~1"=="com.bytedance.pico.screencapture"      set "shortDesc=Screen capture"
if "%~1"=="com.pico.developerhubservice"          set "shortDesc=Dev hub"
if "%~1"=="com.picovr.share"                      set "shortDesc=Share service"
if "%~1"=="com.picovr.provision"                  set "shortDesc=Provisioning"
if "%~1"=="com.pvr.camera"                        set "shortDesc=Camera/passthrough"
if "%~1"=="com.pvr.roomcapture"                   set "shortDesc=Room scan"
if "%~1"=="com.pico.syncappdata.service"          set "shortDesc=App data sync"
if "%~1"=="com.pvr.swift"                         set "shortDesc=Utility"

:: Core apps
if "%~1"=="com.picovr.firmwareupdate"             set "shortDesc=FW updater"
if "%~1"=="com.picovr.updatesystem"               set "shortDesc=System updates"
if "%~1"=="com.picovr.picostreamassistant"        set "shortDesc=PICO Connect"
if "%~1"=="com.picoxr.bstreamassistant"           set "shortDesc=Stream helper"
if "%~1"=="com.pico.browser.overseas"             set "shortDesc=Browser"
if "%~1"=="com.pvr.pvrfit"                        set "shortDesc=Fitness"
if "%~1"=="com.pvr.avatareditor"                  set "shortDesc=Avatar editor"
if "%~1"=="com.pvr.picocast"                      set "shortDesc=Cast/Miracast"
if "%~1"=="com.picopui.im"                        set "shortDesc=Friends/IM"
if "%~1"=="com.pvr.home"                          set "shortDesc=Main launcher"
if "%~1"=="com.pvr.filemanager"                   set "shortDesc=File manager"
if "%~1"=="com.bytedance.pico.tob.userservice"    set "shortDesc=TOB user svc"
if "%~1"=="com.picovr.enterpriseassistant"        set "shortDesc=Enterprise"
if "%~1"=="com.picovr.tobvrusercenter"            set "shortDesc=TOB center"
if "%~1"=="com.picoxr.tobmdm"                     set "shortDesc=TOB MDM"
if "%~1"=="com.picoxr.tobstore"                   set "shortDesc=TOB store"
if "%~1"=="com.pvr.tobhome"                       set "shortDesc=TOB home"
if "%~1"=="com.pvr.tobservice"                    set "shortDesc=TOB service"

:: Kiosk / system
if "%~1"=="com.picovr.store"                      set "shortDesc=PICO Store"
if "%~1"=="com.picovr.vrusercenter"               set "shortDesc=User center"
if "%~1"=="com.picovr.settings"                   set "shortDesc=System settings"
if "%~1"=="com.android.documentsui"               set "shortDesc=File picker"
if "%~1"=="com.picovr.keyguard"                   set "shortDesc=Lock screen"
if "%~1"=="com.picovr.mdm"                        set "shortDesc=MDM"
if "%~1"=="com.android.vpndialogs"                set "shortDesc=VPN dialogs"

:: Optional / network / input
if "%~1"=="com.android.inputmethod.latin"         set "shortDesc=System keyboard"
if "%~1"=="com.android.hotspot2.osulogin"         set "shortDesc=Captive portal"
if "%~1"=="com.android.musicfx"                   set "shortDesc=Audio FX"
if "%~1"=="com.picoxr.mirrorcast"                 set "shortDesc=Mirror cast"
if "%~1"=="com.pvr.lanserver"                     set "shortDesc=LAN server"
if "%~1"=="com.qualcomm.wfd.service"              set "shortDesc=Wi-Fi Display"
if "%~1"=="com.qualcomm.qti.qms.service.trustzoneaccess" set "shortDesc=TrustZone/DRM"
if "%~1"=="vendor.qti.qesdk.sysservice"           set "shortDesc=Qualcomm SDK"
if "%~1"=="com.qualcomm.qti.dynamicddsservice"    set "shortDesc=Dynamic DDS"
if "%~1"=="com.quicinc.voice.activation"          set "shortDesc=Voice activation"

if not defined shortDesc set "shortDesc=Misc"
exit /b

:: ==========================================================
:: SECTION 1: SAFE REMOVALS
:: ==========================================================
:Section1
cls
setlocal enabledelayedexpansion
echo ========== SECTION 1: SAFE REMOVALS ==========
echo.
echo These packages are NOT required for normal everyday VR use.
echo Demo scenes, telemetry, developer tools, extra services.
echo.
set "idx=0"
for %%p in (%S1_LIST%) do (
    set /a idx+=1
    set "pname=%%p"
    call :CheckStatus !pname!
    call :GetShortDesc !pname!
    echo !idx!. [!statusColor!] %%p - !shortDesc!
)
echo.
echo A - Apply action to ALL packages above
echo 0 - Back to main menu
echo.
set /p "pkg_choice=Enter number, A, or 0: "
if /i "%pkg_choice%"=="A" goto :AllPkgsSection1
if "%pkg_choice%"=="0" ( endlocal & goto :MainMenu )
set "valid=0"
for /l %%n in (1,1,%idx%) do if "%pkg_choice%"=="%%n" set "valid=1"
if "%valid%"=="0" ( echo Invalid choice. & pause & endlocal & goto :Section1 )
set "pkg="
if "%pkg_choice%"=="1"  set "pkg=com.android.bips"
if "%pkg_choice%"=="2"  set "pkg=com.android.bookmarkprovider"
if "%pkg_choice%"=="3"  set "pkg=com.android.carrierconfig.overlay.common"
if "%pkg_choice%"=="4"  set "pkg=com.android.egg"
if "%pkg_choice%"=="5"  set "pkg=com.android.ondevicepersonalization.services"
if "%pkg_choice%"=="6"  set "pkg=com.android.printservice.recommendation"
if "%pkg_choice%"=="7"  set "pkg=com.android.providers.blockednumber"
if "%pkg_choice%"=="8"  set "pkg=com.android.providers.userdictionary"
if "%pkg_choice%"=="9"  set "pkg=com.android.role.notes.enabled"
if "%pkg_choice%"=="10" set "pkg=com.android.safetycenter.resources"
if "%pkg_choice%"=="11" set "pkg=com.android.server.telecom.overlay.common"
if "%pkg_choice%"=="12" set "pkg=com.android.simappdialog"
if "%pkg_choice%"=="13" set "pkg=com.android.theme.font.notoserifsource"
if "%pkg_choice%"=="14" set "pkg=com.android.traceur"
if "%pkg_choice%"=="15" set "pkg=com.android.uwb.resources"
if "%pkg_choice%"=="16" set "pkg=com.android.wallpaperbackup"
if "%pkg_choice%"=="17" set "pkg=com.android.wallpapercropper"
if "%pkg_choice%"=="18" set "pkg=com.pvr.tobactivate"
if "%pkg_choice%"=="19" set "pkg=os.teatracker"
if "%pkg_choice%"=="20" set "pkg=com.sohu.inputmethod.sogou.car"
if "%pkg_choice%"=="21" set "pkg=com.picovr.guide"
if "%pkg_choice%"=="22" set "pkg=com.pvr.ZeroIsland.scene"
if "%pkg_choice%"=="23" set "pkg=com.pvr.MoonshadowDunes.scene"
if "%pkg_choice%"=="24" set "pkg=com.pvr.ZeroIslandNight.scene"
if "%pkg_choice%"=="25" set "pkg=com.pvr.WoodenHouse.scene"
if "%pkg_choice%"=="26" set "pkg=com.pvr.SeaviewVilla.scene"
if "%pkg_choice%"=="27" set "pkg=com.pvr.MountainVilla.scene"
if "%pkg_choice%"=="28" set "pkg=com.pico.performancetool"
if "%pkg_choice%"=="29" set "pkg=com.picovr.factorytest"
if "%pkg_choice%"=="30" set "pkg=com.picovr.preview"
if "%pkg_choice%"=="31" set "pkg=com.picoxr.ControllerTest"
if "%pkg_choice%"=="32" set "pkg=com.bytedance.os.slardar"
if "%pkg_choice%"=="33" set "pkg=com.bytedance.os.feedback"
if "%pkg_choice%"=="34" set "pkg=com.bytedance.pico.screencapture"
if "%pkg_choice%"=="35" set "pkg=com.pico.developerhubservice"
if "%pkg_choice%"=="36" set "pkg=com.picovr.share"
if "%pkg_choice%"=="37" set "pkg=com.picovr.provision"
if "%pkg_choice%"=="38" set "pkg=com.pvr.camera"
if "%pkg_choice%"=="39" set "pkg=com.pvr.roomcapture"
if "%pkg_choice%"=="40" set "pkg=com.pico.syncappdata.service"
if "%pkg_choice%"=="41" set "pkg=com.pvr.swift"
if "%pkg%"=="" ( echo Invalid choice. & pause & endlocal & goto :Section1 )
echo.
echo Selected: %pkg%
call :PrintDescSafe %pkg%
echo.
echo 1. Disable
echo 2. Enable
echo 0. Cancel
choice /c 012 /n /m "Action (1/2/0): "
if %errorlevel%==1 ( endlocal & goto :Section1 )
if %errorlevel%==2 (
    call :DoAction disable %pkg%
) else (
    call :DoAction enable %pkg%
)
echo Done.
pause
endlocal
goto :Section1

:AllPkgsSection1
echo.
echo WARNING: Disabling ALL safe packages may remove telemetry and demos.
choice /c YN /m "Are you sure you want to proceed (Y/N)? "
if errorlevel 2 ( endlocal & goto :Section1 )
echo.
echo Apply action to ALL packages in this section.
echo 1. Disable ALL
echo 2. Enable ALL
echo 0. Cancel
choice /c 012 /n /m "Action (1/2/0): "
if %errorlevel%==1 ( endlocal & goto :Section1 )
if %errorlevel%==2 ( set "action=disable" ) else if %errorlevel%==3 ( set "action=enable" ) else ( endlocal & goto :Section1 )
echo.
echo %action%ing all packages (this may take a moment)...
for %%p in (%S1_LIST%) do call :DoAction %action% %%p
echo Done.
pause
endlocal
goto :Section1

:PrintDescSafe
if "%~1"=="com.android.bips" echo Description: Print service. Safe.
if "%~1"=="com.android.bookmarkprovider" echo Description: Bookmark provider. Safe.
if "%~1"=="com.android.carrierconfig.overlay.common" echo Description: Carrier config. Not needed.
if "%~1"=="com.android.egg" echo Description: Easter egg. Safe.
if "%~1"=="com.android.ondevicepersonalization.services" echo Description: Personalization. Safe.
if "%~1"=="com.android.printservice.recommendation" echo Description: Print service. Safe.
if "%~1"=="com.android.providers.blockednumber" echo Description: Blocked numbers. Not needed.
if "%~1"=="com.android.providers.userdictionary" echo Description: User dictionary. Safe.
if "%~1"=="com.android.role.notes.enabled" echo Description: Notes role. Safe.
if "%~1"=="com.android.safetycenter.resources" echo Description: Safety center. Safe.
if "%~1"=="com.android.server.telecom.overlay.common" echo Description: Telecom overlay. Not needed.
if "%~1"=="com.android.simappdialog" echo Description: SIM dialog. Not needed.
if "%~1"=="com.android.theme.font.notoserifsource" echo Description: Noto font. Safe.
if "%~1"=="com.android.traceur" echo Description: Tracing tool. Safe.
if "%~1"=="com.android.uwb.resources" echo Description: UWB resources. Not used.
if "%~1"=="com.android.wallpaperbackup" echo Description: Wallpaper backup. Safe.
if "%~1"=="com.android.wallpapercropper" echo Description: Wallpaper cropper. Safe.
if "%~1"=="com.pvr.tobactivate" echo Description: TOB activation. Safe if not enterprise.
if "%~1"=="os.teatracker" echo Description: Telemetry tracker. Disable for privacy.
if "%~1"=="com.sohu.inputmethod.sogou.car" echo Description: Sogou car keyboard. Unneeded.
if "%~1"=="com.picovr.guide" echo Description: Welcome guide. Safe.
if "%~1"=="com.pvr.ZeroIsland.scene" echo Description: Demo scene. Safe.
if "%~1"=="com.pvr.MoonshadowDunes.scene" echo Description: Demo scene. Safe.
if "%~1"=="com.pvr.ZeroIslandNight.scene" echo Description: Demo scene. Safe.
if "%~1"=="com.pvr.WoodenHouse.scene" echo Description: Demo scene. Safe.
if "%~1"=="com.pvr.SeaviewVilla.scene" echo Description: Demo scene. Safe.
if "%~1"=="com.pvr.MountainVilla.scene" echo Description: Demo scene. Safe.
if "%~1"=="com.pico.performancetool" echo Description: Performance tool. Safe.
if "%~1"=="com.picovr.factorytest" echo Description: Factory test. Safe.
if "%~1"=="com.picovr.preview" echo Description: Preview app. Safe.
if "%~1"=="com.picoxr.ControllerTest" echo Description: Controller test. Safe.
if "%~1"=="com.bytedance.os.slardar" echo Description: Analytics. Disable for privacy.
if "%~1"=="com.bytedance.os.feedback" echo Description: Feedback tool. Safe.
if "%~1"=="com.bytedance.pico.screencapture" echo Description: Screencapture. Safe.
if "%~1"=="com.pico.developerhubservice" echo Description: Developer hub. Safe.
if "%~1"=="com.picovr.share" echo Description: Share service. Safe.
if "%~1"=="com.picovr.provision" echo Description: Provisioning. Safe after setup.
if "%~1"=="com.pvr.camera" echo Description: Camera app (passthrough). Disabling may break camera features.
if "%~1"=="com.pvr.roomcapture" echo Description: Room capture/scan. Disabling breaks room scanning.
if "%~1"=="com.pico.syncappdata.service" echo Description: App data sync. Safe.
if "%~1"=="com.pvr.swift" echo Description: Utility. Safe.
exit /b

:: ==========================================================
:: SECTION 2: CORE APPS
:: ==========================================================
:Section2
cls
setlocal enabledelayedexpansion
echo ========== SECTION 2: CORE APPS ==========
echo.
echo Base preinstalled applications from PICO.
echo Browser, Fitness, Avatar, Screencast, Friends, Launcher, File Manager, TOB apps.
echo.
set "idx=0"
for %%p in (%S2_LIST%) do (
    set /a idx+=1
    set "pname=%%p"
    call :CheckStatus !pname!
    call :GetShortDesc !pname!
    echo !idx!. [!statusColor!] %%p - !shortDesc!
)
echo.
echo A - Apply action to ALL packages above
echo 0 - Back to main menu
echo.
set /p "pkg_choice=Enter number, A, or 0: "
if /i "%pkg_choice%"=="A" goto :AllPkgsSection2
if "%pkg_choice%"=="0" ( endlocal & goto :MainMenu )
set "valid=0"
for /l %%n in (1,1,%idx%) do if "%pkg_choice%"=="%%n" set "valid=1"
if "%valid%"=="0" ( echo Invalid choice. & pause & endlocal & goto :Section2 )
set "pkg="
if "%pkg_choice%"=="1"  set "pkg=com.picovr.firmwareupdate"
if "%pkg_choice%"=="2"  set "pkg=com.picovr.updatesystem"
if "%pkg_choice%"=="3"  set "pkg=com.picovr.picostreamassistant"
if "%pkg_choice%"=="4"  set "pkg=com.picoxr.bstreamassistant"
if "%pkg_choice%"=="5"  set "pkg=com.pico.browser.overseas"
if "%pkg_choice%"=="6"  set "pkg=com.pvr.pvrfit"
if "%pkg_choice%"=="7"  set "pkg=com.pvr.avatareditor"
if "%pkg_choice%"=="8"  set "pkg=com.pvr.picocast"
if "%pkg_choice%"=="9"  set "pkg=com.picopui.im"
if "%pkg_choice%"=="10" set "pkg=com.pvr.home"
if "%pkg_choice%"=="11" set "pkg=com.pvr.filemanager"
if "%pkg_choice%"=="12" set "pkg=com.bytedance.pico.tob.userservice"
if "%pkg_choice%"=="13" set "pkg=com.picovr.enterpriseassistant"
if "%pkg_choice%"=="14" set "pkg=com.picovr.tobvrusercenter"
if "%pkg_choice%"=="15" set "pkg=com.picoxr.tobmdm"
if "%pkg_choice%"=="16" set "pkg=com.picoxr.tobstore"
if "%pkg_choice%"=="17" set "pkg=com.pvr.tobhome"
if "%pkg_choice%"=="18" set "pkg=com.pvr.tobservice"
if "%pkg%"=="" ( echo Invalid choice. & pause & endlocal & goto :Section2 )
echo.
echo Selected: %pkg%
if "%pkg%"=="com.picovr.firmwareupdate" echo Description: Firmware update service. Disabling prevents OTA updates.
if "%pkg%"=="com.picovr.updatesystem" echo Description: System update manager.
if "%pkg%"=="com.picovr.picostreamassistant" echo Description: PICO Connect (Streaming Assistant).
if "%pkg%"=="com.picoxr.bstreamassistant" echo Description: Backup streaming assistant.
if "%pkg%"=="com.pico.browser.overseas" echo Description: PICO web browser.
if "%pkg%"=="com.pvr.pvrfit" echo Description: Fitness app.
if "%pkg%"=="com.pvr.avatareditor" echo Description: Avatar editor.
if "%pkg%"=="com.pvr.picocast" echo Description: Screencast / Miracast.
if "%pkg%"=="com.picopui.im" echo Description: Friends app and messaging.
if "%pkg%"=="com.pvr.home" echo Description: Default launcher. WARNING: Disable only if you have another launcher!
if "%pkg%"=="com.pvr.filemanager" echo Description: Built-in file manager.
if "%pkg%"=="com.bytedance.pico.tob.userservice" echo Description: TOB user service.
if "%pkg%"=="com.picovr.enterpriseassistant" echo Description: Enterprise assistant.
if "%pkg%"=="com.picovr.tobvrusercenter" echo Description: TOB VR user center.
if "%pkg%"=="com.picoxr.tobmdm" echo Description: TOB MDM.
if "%pkg%"=="com.picoxr.tobstore" echo Description: TOB enterprise store.
if "%pkg%"=="com.pvr.tobhome" echo Description: TOB home launcher.
if "%pkg%"=="com.pvr.tobservice" echo Description: TOB background service.
echo.
echo 1. Disable
echo 2. Enable
echo 0. Cancel
choice /c 012 /n /m "Action (1/2/0): "
if %errorlevel%==1 ( endlocal & goto :Section2 )
if %errorlevel%==2 (
    call :DoAction disable %pkg%
) else (
    call :DoAction enable %pkg%
)
echo Done.
pause
endlocal
goto :Section2

:AllPkgsSection2
echo.
echo WARNING: Disabling ALL core apps may severely affect system usability.
echo You may lose launcher, updates, and key system components.
choice /c YN /m "Are you sure you want to proceed (Y/N): "
if errorlevel 2 ( endlocal & goto :Section2 )
echo.
echo Apply action to ALL core packages.
echo 1. Disable ALL
echo 2. Enable ALL
echo 0. Cancel
choice /c 012 /n /m "Action (1/2/0): "
if %errorlevel%==1 ( endlocal & goto :Section2 )
if %errorlevel%==2 ( set "action=disable" ) else if %errorlevel%==3 ( set "action=enable" ) else ( endlocal & goto :Section2 )
echo.
echo %action%ing all core packages (this may take a moment)...
for %%p in (%S2_LIST%) do call :DoAction %action% %%p
echo Done.
pause
endlocal
goto :Section2

:: ==========================================================
:: SECTION 3: OPTIONAL - PROCEED WITH CARE
:: ==========================================================
:Section3
cls
setlocal enabledelayedexpansion
echo ========== SECTION 3: OPTIONAL - PROCEED WITH CARE ==========
echo.
echo These packages may affect specific functionality.
echo Disable only if you understand the consequences.
echo.
echo In this section you also have:
echo  - C: app compilation (speed / speed-profile modes)
echo  - P: performance ^& network tweaks
echo  - A: bulk enable/disable for optional packages
echo.
set "idx=0"
for %%p in (%S3_LIST%) do (
    set /a idx+=1
    set "pname=%%p"
    call :CheckStatus !pname!
    call :GetShortDesc !pname!
    echo !idx!. [!statusColor!] %%p - !shortDesc!
)
echo.
echo C - Compile our app set for speed (speed / speed-profile)
echo P - Performance and network tweaks
echo A - Apply action to ALL packages above
echo 0 - Back to main menu
echo.
set /p "pkg_choice=Enter number, C, P, A, or 0: "
if /i "%pkg_choice%"=="A" goto :AllPkgsSection3
if /i "%pkg_choice%"=="C" goto :CompileAction
if /i "%pkg_choice%"=="P" goto :PerfTweaks
if "%pkg_choice%"=="0" ( endlocal & goto :MainMenu )
set "valid=0"
for /l %%n in (1,1,%idx%) do if "%pkg_choice%"=="%%n" set "valid=1"
if "%valid%"=="0" ( echo Invalid choice. & pause & endlocal & goto :Section3 )
set "pkg="
if "%pkg_choice%"=="1"  set "pkg=com.android.inputmethod.latin"
if "%pkg_choice%"=="2"  set "pkg=com.android.hotspot2.osulogin"
if "%pkg_choice%"=="3"  set "pkg=com.android.musicfx"
if "%pkg_choice%"=="4"  set "pkg=com.picoxr.mirrorcast"
if "%pkg_choice%"=="5"  set "pkg=com.pvr.lanserver"
if "%pkg_choice%"=="6"  set "pkg=com.qualcomm.wfd.service"
if "%pkg_choice%"=="7"  set "pkg=com.qualcomm.qti.qms.service.trustzoneaccess"
if "%pkg_choice%"=="8"  set "pkg=vendor.qti.qesdk.sysservice"
if "%pkg_choice%"=="9"  set "pkg=com.qualcomm.qti.dynamicddsservice"
if "%pkg_choice%"=="10" set "pkg=com.quicinc.voice.activation"
if "%pkg%"=="" ( echo Invalid choice. & pause & endlocal & goto :Section3 )
echo.
echo Selected: %pkg%
if "%pkg%"=="com.android.inputmethod.latin" echo Description: AOSP keyboard. WARNING: Only disable if you have another keyboard.
if "%pkg%"=="com.android.hotspot2.osulogin" echo Description: Captive portal login. Disabling may break public Wi-Fi login.
if "%pkg%"=="com.android.musicfx" echo Description: System equalizer. May affect audio quality.
if "%pkg%"=="com.picoxr.mirrorcast" echo Description: Mirror cast to TV. Disabling breaks screen mirroring.
if "%pkg%"=="com.pvr.lanserver" echo Description: LAN server for Pico mobile app. Disable if not using mobile app.
if "%pkg%"=="com.qualcomm.wfd.service" echo Description: Qualcomm Wi-Fi Display (Miracast). Disabling breaks wireless display.
if "%pkg%"=="com.qualcomm.qti.qms.service.trustzoneaccess" echo Description: TrustZone (DRM). May break DRM and in-app purchases.
if "%pkg%"=="vendor.qti.qesdk.sysservice" echo Description: Qualcomm QE SDK. Usually safe.
if "%pkg%"=="com.qualcomm.qti.dynamicddsservice" echo Description: Dynamic DDS service. Network-related.
if "%pkg%"=="com.quicinc.voice.activation" echo Description: Voice activation. May break voice input.
echo.
echo 1. Disable
echo 2. Enable
echo 0. Cancel
choice /c 012 /n /m "Action (1/2/0): "
if %errorlevel%==1 ( endlocal & goto :Section3 )
if %errorlevel%==2 (
    call :DoAction disable %pkg%
) else (
    call :DoAction enable %pkg%
)
echo Done.
pause
endlocal
goto :Section3

:AllPkgsSection3
echo.
echo Apply action to ALL optional packages.
choice /c YN /m "Are you sure you want to proceed (Y/N)? "
if errorlevel 2 ( endlocal & goto :Section3 )
echo.
echo 1. Disable ALL
echo 2. Enable ALL
echo 0. Cancel
choice /c 012 /n /m "Action (1/2/0): "
if %errorlevel%==1 ( endlocal & goto :Section3 )
if %errorlevel%==2 ( set "action=disable" ) else if %errorlevel%==3 ( set "action=enable" ) else ( endlocal & goto :Section3 )
echo.
echo %action%ing all optional packages (may take a moment)...
for %%p in (%S3_LIST%) do call :DoAction %action% %%p
echo Done.
pause
endlocal
goto :Section3

:CompileAction
echo.
echo ========== APP COMPILATION ==========
echo.
echo You can compile apps from script package lists (S1/S2/S3/S4) with:
echo  - Soft mode   : speed-profile  (balanced, recommended)
echo  - Heavy mode  : speed          (maximum AOT, longer time ^& more storage)
echo.
echo NOTE:
echo  - This may take several minutes depending on the number of apps.
echo  - Do NOT disconnect the headset or close this window during compilation.
echo.
echo 1. Soft compile   (speed-profile)
echo 2. Heavy compile  (speed)
echo 0. Cancel
choice /c 012 /n /m "Choose mode (1/2/0): "

set "COMP_MODE="
if %errorlevel%==1 (
    endlocal
    goto :Section3
)
if %errorlevel%==2 set "COMP_MODE=speed-profile"
if %errorlevel%==3 set "COMP_MODE=speed"

if "%COMP_MODE%"=="" (
    echo Invalid choice.
    pause
    endlocal
    goto :Section3
)

echo.
echo Selected mode: %COMP_MODE%
echo.
echo Compiling apps from script package lists...
echo [%date% %time%] COMPILE SCRIPT_PACKAGES MODE=%COMP_MODE%>>"%LOG%"

set "ALL_LIST=%S1_LIST% %S2_LIST% %S3_LIST% %S4_LIST%"
set /a total=0
for %%p in (%ALL_LIST%) do set /a total+=1

set /a current=0
for %%p in (%ALL_LIST%) do (
    set /a current+=1
    cls
    echo ========== APP COMPILATION IN PROGRESS ==========
    echo.
    echo Mode     : %COMP_MODE%
    echo Package  : %%p
    echo Progress : !current! / !total!
    echo.
    echo (This may take several minutes. Do NOT disconnect the headset.)
    echo.
    %ADB_CMD% shell pm compile -f -m %COMP_MODE% %%p>>"%LOG%" 2>&1
)

echo.
echo Compile command finished. Check log if needed: "%LOG%"
pause
endlocal
goto :Section3

:PerfTweaks
echo.
echo ========== PERFORMANCE AND NETWORK TWEAKS ==========
echo.
echo The following settings will be applied:
echo  - Disable auto Wi-Fi connecting and wakeup
echo  - Disable some network stats collection
echo  - Shorten long / multi press timeouts (UI responsiveness)
echo  - Disable phantom process monitoring (fewer background kills)
echo  - Allow maximum phantom processes for better background / ADB stability
echo  - Run background dexopt job to optimize apps
echo.
choice /c YN /m "Apply these tweaks now? (Y/N): "
if %errorlevel%==2 goto :Section3

echo.
echo [+] Applying network ^& UI tweaks...
%ADB_CMD% shell settings put global auto_wifi 0
%ADB_CMD% shell settings put global netstats_enabled 0
%ADB_CMD% shell settings put global wifi_wakeup_enabled 0
%ADB_CMD% shell settings put secure long_press_timeout 250
%ADB_CMD% shell settings put secure multi_press_timeout 250
%ADB_CMD% shell settings put global settings_enable_monitor_phantom_procs false

echo.
echo [+] Optimizing performance...
%ADB_CMD% shell device_config put activity_manager max_phantom_processes 2147483647
%ADB_CMD% shell pm bg-dexopt-job

echo.
echo Tweaks applied.
echo Press any key to return to Section 3...
pause >nul
goto :Section3

:: ==========================================================
:: SECTION 4: KIOSK MODE
:: ==========================================================
:Section4
cls
setlocal enabledelayedexpansion
echo ========== SECTION 4: KIOSK MODE ==========
echo.
echo Disable these packages to lock down the device for kiosk usage.
echo Store, user center, settings, file manager, lock screen, VPN dialogs, MDM.
echo.
set "idx=0"
for %%p in (%S4_LIST%) do (
    set /a idx+=1
    set "pname=%%p"
    call :CheckStatus !pname!
    call :GetShortDesc !pname!
    echo !idx!. [!statusColor!] %%p - !shortDesc!
)
echo.
echo A - Apply action to ALL packages above
echo 0 - Back to main menu
echo.
set /p "pkg_choice=Enter number, A, or 0: "
if /i "%pkg_choice%"=="A" goto :AllPkgsSection4
if "%pkg_choice%"=="0" ( endlocal & goto :MainMenu )
set "valid=0"
for /l %%n in (1,1,%idx%) do if "%pkg_choice%"=="%%n" set "valid=1"
if "%valid%"=="0" ( echo Invalid choice. & pause & endlocal & goto :Section4 )
set "pkg="
if "%pkg_choice%"=="1" set "pkg=com.picovr.store"
if "%pkg_choice%"=="2" set "pkg=com.picovr.vrusercenter"
if "%pkg_choice%"=="3" set "pkg=com.picovr.settings"
if "%pkg_choice%"=="4" set "pkg=com.android.documentsui"
if "%pkg_choice%"=="5" set "pkg=com.picovr.keyguard"
if "%pkg_choice%"=="6" set "pkg=com.android.vpndialogs"
if "%pkg_choice%"=="7" set "pkg=com.picovr.mdm"
if "%pkg%"=="" ( echo Invalid choice. & pause & endlocal & goto :Section4 )
echo.
echo Selected: %pkg%
if "%pkg%"=="com.picovr.store" echo Description: PICO App Store. Disabling removes installation/update capability.
if "%pkg%"=="com.picovr.vrusercenter" echo Description: User account center. Disable if no account switching needed.
if "%pkg%"=="com.picovr.settings" echo Description: System Settings. CAUTION: Disabling blocks all settings access.
if "%pkg%"=="com.android.documentsui" echo Description: File picker. Disabling prevents file open/save dialogs.
if "%pkg%"=="com.picovr.keyguard" echo Description: Lock screen. Disabling removes lock screen.
if "%pkg%"=="com.android.vpndialogs" echo Description: VPN permission dialog. Disabling removes VPN popups.
if "%pkg%"=="com.picovr.mdm" echo Description: Mobile Device Management. Disable if not managed.
echo.
echo 1. Disable
echo 2. Enable
echo 0. Cancel
choice /c 012 /n /m "Action (1/2/0): "
if %errorlevel%==1 ( endlocal & goto :Section4 )
if %errorlevel%==2 (
    call :DoAction disable %pkg%
) else (
    call :DoAction enable %pkg%
)
echo Done.
pause
endlocal
goto :Section4

:AllPkgsSection4
echo.
echo WARNING: Disabling ALL kiosk-related packages can lock the device UI.
echo You may lose access to store, settings and file dialogs.
choice /c YN /m "Are you sure you want to proceed (Y/N): "
if errorlevel 2 ( endlocal & goto :Section4 )
echo.
echo Apply action to ALL kiosk-related packages.
echo 1. Disable ALL
echo 2. Enable ALL
echo 0. Cancel
choice /c 012 /n /m "Action (1/2/0): "
if %errorlevel%==1 ( endlocal & goto :Section4 )
if %errorlevel%==2 ( set "action=disable" ) else if %errorlevel%==3 ( set "action=enable" ) else ( endlocal & goto :Section4 )
echo.
echo %action%ing all kiosk packages (this may take a moment)...
for %%p in (%S4_LIST%) do call :DoAction %action% %%p
echo Done.
pause
endlocal
goto :Section4

:: ==========================================================
:: SAVE CURRENT CONFIGURATION TO FILE (full state: both enable and disable)
:: ==========================================================
:SaveConfig
cls
echo ========== SAVE CURRENT CONFIGURATION ==========
echo.
echo Config file will be saved as:
echo   "%CFG%"
echo.
choice /c YN /m "Overwrite configuration file with current state? (Y/N): "
if %errorlevel%==2 goto :MainMenu

> "%CFG%" echo # Pico 4 configuration generated on %date% %time%
>>"%CFG%" echo # format: action package_name
>>"%CFG%" echo.

echo.
echo Scanning packages and writing configuration...

setlocal enabledelayedexpansion

set "ALL_LIST=%S1_LIST% %S2_LIST% %S3_LIST% %S4_LIST%"
for %%p in (%ALL_LIST%) do (
    set "pname=%%p"
    call :CheckStatus !pname!
    if "!status!"=="DISABLED" (
        >>"%CFG%" echo disable %%p
    ) else (
        >>"%CFG%" echo enable %%p
    )
)

endlocal

echo.
echo Configuration saved to "%CFG%".
echo Press any key to return to main menu...
pause >nul
goto :MainMenu

:: ==========================================================
:: APPLY CONFIGURATION FROM FILE (fixed: no labels inside FOR loop)
:: ==========================================================
:ApplyConfig
cls
echo ========== APPLY CONFIGURATION FROM FILE ==========
echo.
if not exist "%CFG%" (
    echo Configuration file not found:
    echo   "%CFG%"
    echo Nothing to apply.
    echo.
    echo Press any key to return to main menu...
    pause >nul
    goto :MainMenu
)

echo This will execute all actions listed in:
echo   "%CFG%"
echo.
echo Example line format:  disable com.picovr.store
echo.
choice /c YN /m "Proceed with applying configuration? (Y/N): "
if %errorlevel%==2 goto :MainMenu

echo.
echo Applying configuration...
for /f "usebackq tokens=1,2" %%A in ("%CFG%") do (
    if not "%%A"=="" if not "%%A"=="#" (
        if /i "%%A"=="disable" call :DoAction disable %%B
        if /i "%%A"=="enable"  call :DoAction enable %%B
    )
)

echo.
echo Configuration applied.
echo Press any key to return to main menu...
pause >nul
goto :MainMenu

:: ==========================================================
:: INSTALL APKs FROM "apk" FOLDER (with fixed ADB path)
:: ==========================================================
:InstallApks
cls
echo ========== INSTALL APKs ==========
echo.
set "APK_DIR=%SCRIPT_DIR%apk"

if not exist "%APK_DIR%" (
    echo Folder with APK files not found:
    echo   "%APK_DIR%"
    echo.
    echo Create this folder and put your .apk files there.
    echo.
    echo Press any key to return to main menu...
    pause >nul
    goto :MainMenu
)

pushd "%APK_DIR%" >nul

setlocal enabledelayedexpansion
set "idx=0"
for %%F in (*.apk) do (
    set /a idx+=1
    set "APK[!idx!]=%%F"
)

if %idx%==0 (
    echo No .apk files found in:
    echo   "%APK_DIR%"
    echo.
    echo Press any key to return to main menu...
    pause >nul
    endlocal
    popd >nul
    goto :MainMenu
)

echo Found the following APK files:
echo.
for /l %%N in (1,1,%idx%) do (
    echo %%N. !APK[%%N]!
)
echo.
echo A - Install ALL APKs above
echo 0 - Back to main menu
echo.
set /p "apk_choice=Enter number, A, or 0: "

if /i "%apk_choice%"=="0" (
    endlocal
    popd >nul
    goto :MainMenu
)

if /i "%apk_choice%"=="A" goto :InstallAllApks

:: Install one APK by number
set "valid=0"
for /l %%N in (1,1,%idx%) do if "%apk_choice%"=="%%N" set "valid=1"
if "%valid%"=="0" (
    echo Invalid choice.
    pause
    endlocal
    popd >nul
    goto :InstallApks
)

set "APK_FILE="
for /l %%N in (1,1,%idx%) do (
    if "%apk_choice%"=="%%N" set "APK_FILE=!APK[%%N]!"
)

if "%APK_FILE%"=="" (
    echo Invalid selection.
    pause
    endlocal
    popd >nul
    goto :InstallApks
)

echo.
echo Selected APK: %APK_FILE%
echo.
echo 1. Install (new)
echo 2. Reinstall (keep app data, -r)
echo 0. Cancel
choice /c 012 /n /m "Action (1/2/0): "
if %errorlevel%==1 (
    endlocal
    popd >nul
    goto :InstallApks
)
set "INSTALL_CMD=%ADB_CMD% install"
if %errorlevel%==3 set "INSTALL_CMD=%ADB_CMD% install -r"

echo.
echo Running: %INSTALL_CMD% "%APK_DIR%\%APK_FILE%"
echo.
%INSTALL_CMD% "%APK_DIR%\%APK_FILE%"
echo.
echo Done. Check the output above for any errors.
echo.
pause
endlocal
popd >nul
goto :InstallApks

:InstallAllApks
echo.
echo Installing ALL APKs from:
echo   "%APK_DIR%"
echo.
echo 1. Install (new)
echo 2. Reinstall (keep app data, -r)
echo 0. Cancel
choice /c 012 /n /m "Action (1/2/0): "
if %errorlevel%==1 (
    endlocal
    popd >nul
    goto :InstallApks
)
set "INSTALL_CMD=%ADB_CMD% install"
if %errorlevel%==3 set "INSTALL_CMD=%ADB_CMD% install -r"

echo.
echo Starting installation of %idx% APK file(s)...
echo.
for /l %%N in (1,1,%idx%) do (
    echo --------------------------------------------------
    echo [%%N/%idx%] Installing !APK[%%N]! ...
    %INSTALL_CMD% "!APK[%%N]!"
    echo.
)

echo All APKs processed. Review output above for any errors.
echo.
pause
endlocal
popd >nul
goto :InstallApks

:: ==========================================================
:: SHOW DISABLED PACKAGES
:: ==========================================================
:ShowDisabled
cls
echo ========== DISABLED PACKAGES ==========
echo.
%ADB_CMD% shell pm list packages -d
echo.
echo Press any key to return to main menu...
pause >nul
goto :MainMenu

:: ==========================================================
:: SHOW ENABLED PACKAGES
:: ==========================================================
:ShowEnabled
cls
echo ========== ENABLED PACKAGES ==========
echo.
%ADB_CMD% shell pm list packages -e
echo.
echo Press any key to return to main menu...
pause >nul
goto :MainMenu

:: ==========================================================
:: REVERT ALL CHANGES
:: ==========================================================
:ConfirmRevertAll
cls
echo ========== REVERT ALL CHANGES ==========
echo.
echo This will enable ALL packages that could have been disabled by this script,
echo and reset some system settings to default.
echo.
choice /c YN /m "Are you sure? (Y/N): "
if %errorlevel%==2 goto :MainMenu

echo.
echo [+] Enabling all packages referenced by this script...

for %%i in (
    com.android.bips com.android.bookmarkprovider com.android.carrierconfig.overlay.common
    com.android.egg com.android.ondevicepersonalization.services com.android.printservice.recommendation
    com.android.providers.blockednumber com.android.providers.userdictionary com.android.role.notes.enabled
    com.android.safetycenter.resources com.android.server.telecom.overlay.common com.android.simappdialog
    com.android.theme.font.notoserifsource com.android.traceur com.android.uwb.resources
    com.android.wallpaperbackup com.android.wallpapercropper com.pvr.tobactivate os.teatracker
    com.sohu.inputmethod.sogou.car com.picovr.guide
    com.pvr.ZeroIsland.scene com.pvr.MoonshadowDunes.scene com.pvr.ZeroIslandNight.scene
    com.pvr.WoodenHouse.scene com.pvr.SeaviewVilla.scene com.pvr.MountainVilla.scene
    com.pico.performancetool com.picovr.factorytest com.picovr.preview com.picoxr.ControllerTest
    com.bytedance.os.slardar com.bytedance.os.feedback com.bytedance.pico.screencapture
    com.pico.developerhubservice com.picovr.share com.picovr.provision com.pvr.camera
    com.pvr.roomcapture com.pico.syncappdata.service com.pvr.swift
    com.picovr.firmwareupdate com.picovr.updatesystem
    com.picovr.picostreamassistant com.picoxr.bstreamassistant
    com.pico.browser.overseas com.pvr.pvrfit com.pvr.avatareditor
    com.pvr.picocast com.picopui.im com.pvr.home com.pvr.filemanager
    com.bytedance.pico.tob.userservice com.picovr.enterpriseassistant
    com.picovr.tobvrusercenter com.picoxr.tobmdm com.picoxr.tobstore
    com.pvr.tobhome com.pvr.tobservice
    com.android.inputmethod.latin com.android.hotspot2.osulogin
    com.android.musicfx com.picoxr.mirrorcast com.pvr.lanserver
    com.qualcomm.wfd.service com.qualcomm.qti.qms.service.trustzoneaccess
    vendor.qti.qesdk.sysservice com.qualcomm.qti.dynamicddsservice com.quicinc.voice.activation
    com.picovr.store com.picovr.vrusercenter com.picovr.settings
    com.android.documentsui com.picovr.keyguard com.android.vpndialogs
    com.picovr.mdm
) do call :DoAction enable %%i

echo [+] Resetting some system settings to defaults...
%ADB_CMD% shell settings delete global auto_wifi
%ADB_CMD% shell settings delete global netstats_enabled
%ADB_CMD% shell settings delete global wifi_wakeup_enabled
%ADB_CMD% shell settings delete secure long_press_timeout
%ADB_CMD% shell settings delete secure multi_press_timeout
%ADB_CMD% shell settings delete global settings_enable_monitor_phantom_procs
%ADB_CMD% shell device_config set_sync_disabled_for_tests none

echo.
echo ==========================================
echo REVERSION FINISHED!
echo ==========================================
echo All listed packages have been enabled and settings reset.
pause
goto :MainMenu