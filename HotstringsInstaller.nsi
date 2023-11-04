!include "FileFunc.nsh"
!include "LogicLib.nsh"

; Script Header
Outfile "HotstringsInstaller.exe"
RequestExecutionLevel user ; Install only for the current user

!define APP_NAME "Hotstrings"
!define SILENT_PARAMETER "/s"
Var WHERE_INSTALL

; Silent installation section
Function SilentInstall
    ; Write uninstaller
    WriteUninstaller "$INSTDIR\uninstaller.exe"

    SetOutPath "$APPDATA\Hotstrings" ; Set the installation directory to the user's Roaming AppData

    StrCpy $WHERE_INSTALL "$APPDATA\Hotstrings"

    ; Create Libraries and Log folders
    CreateDirectory "$WHERE_INSTALL"
    CreateDirectory "$WHERE_INSTALL\Libraries"
    CreateDirectory "$WHERE_INSTALL\Log"
    CreateDirectory "$WHERE_INSTALL\Languages"

    ; Source
    File "Hotstrings.exe"                                           ;Adds file(s) to be extracted to the current output path ($OUTDIR).
    File "C:\Users\macie\AppData\Roaming\Hotstrings\Config.ini"     ;Adds file(s) to be extracted to the current output path ($OUTDIR).
    File "LICENSE_EULA.md"                                          ;Adds file(s) to be extracted to the current output path ($OUTDIR). 
    File "Languages\English.txt"
    
    ; Add uninstall information to the registry
    WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "DisplayName" "${APP_NAME}"
    WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "UninstallString" "$INSTDIR\uninstaller.exe"
    WriteRegDWORD HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "NoModify" 1
    WriteRegDWORD HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "NoRepair" 1

    ; Create a shortcut on the desktop
    CreateShortCut "$DESKTOP\Hotstrings.lnk" "$APPDATA\Hotstrings\Hotstrings.exe"
FunctionEnd

; Default section
Section
    SetOutPath $WHERE_INSTALL ; Set the installation directory to the user's Roaming AppData

    ; Create subfolders
    CreateDirectory "$WHERE_INSTALL\Libraries"
    CreateDirectory "$WHERE_INSTALL\Log"
    CreateDirectory "$WHERE_INSTALL\Languages"

    ; Source
    File "Hotstrings.exe"
    File "C:\Users\macie\AppData\Roaming\Hotstrings\Config.ini"
    File "LICENSE_EULA.md"
    File "Languages\English.txt"

    ; Call the SilentInstall function
    Call SilentInstall
SectionEnd

; Uninstaller section
Section "Uninstall"
    ; Remove files and directories
    Delete "$APPDATA\Hotstrings\Hotstrings.exe"
    Delete "$APPDATA\Hotstrings\Config.ini"
    Delete "$APPDATA\Hotstrings\LICENSE_EULA.md"
    Delete "$APPDATA\Hotstrings\Languages\English.txt"
    RMDir "$APPDATA\Hotstrings\Languages"
    RMDir "$APPDATA\\Hotstrings"

    ; Remove uninstall information from the registry
    DeleteRegKey HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}"

    ; Remove desktop shortcut
    Delete "$DESKTOP\Hotstrings.lnk"
SectionEnd

; Define the silent installation parameter
Function .onInit
    ClearErrors
    ${GetParameters} $0
    ${If} ${Errors}
        StrCpy $0 0
    ${EndIf}

    ${If} $0 == ${SILENT_PARAMETER}
        Call SilentInstall
        Quit ; Quit the installer after silent installation
    ${EndIf}
FunctionEnd