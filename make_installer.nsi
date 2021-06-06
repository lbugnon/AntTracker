; Build Unicode installer
Unicode True
!include "LogicLib.nsh"
!include "StrFunc.nsh"
${StrLoc}

!define VERSION "0.99.6" ; Se incrementa automáticamente por bump2version

LoadLanguageFile "${NSISDIR}\Contrib\Language files\Spanish.nlf"

; Nombre del instalador

Name "AntTracker v${VERSION}"

; Nombre de archivo del instalador
OutFile "AntTracker_v${VERSION}_installer.exe"

; Request application privileges for Windows Vista and higher
RequestExecutionLevel admin

; The default installation directory
InstallDir $PROGRAMFILES64\AntTracker

; Registry key to check for directory (so if you install again, it will
; overwrite the old one automatically)
InstallDirRegKey HKLM "Software\AntTracker" "Install_Dir"

;--------------------------------

; Pages

Page license
LicenseData "LICENSE"
Page components
Page directory
Page instfiles

UninstPage uninstConfirm
UninstPage instfiles

;--------------------------------

; The stuff to install
Section "AntTracker & AntLabeler (requerido)"
  SectionIn RO

  ; Agregar forzosamente la carpeta \AntTracker al directorio
  ; de instalación si el usuario no lo especifica
  ${StrLoc} $0 $INSTDIR "\AntTracker" ">"
  ${If} $0 == ""
    ${StrLoc} $0 "$INSTDIR" "\" "<"
    ${If} $0 != 0
      StrCpy $INSTDIR "$INSTDIR\AntTracker"
    ${Else}
      StrCpy $INSTDIR "$INSTDIRAntTracker"
    ${EndIf}
  ${EndIf}
  SetOutPath $INSTDIR

  ; Put files there
  File /r "dist\AntTracker\*"

  ; Write the installation path into the registry
  WriteRegStr HKLM SOFTWARE\AntTracker "Install_Dir" "$INSTDIR"

  ; Write the uninstall keys for Windows
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\AntTracker" "DisplayName" "AntTracker"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\AntTracker" "UninstallString" '"$INSTDIR\uninstall.exe"'
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\AntTracker" "NoModify" 1
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\AntTracker" "NoRepair" 1
  WriteUninstaller "$INSTDIR\uninstall.exe"

SectionEnd

Section "Visual C++ Redistributable para Visual Studio 2017"
  SectionIn RO
  NSISdl::download https://aka.ms/vs/15/release/vc_redist.x64.exe "$INSTDIR\vc_redist.x64.exe"
  ExecWait '"$INSTDIR\vc_redist.x64.exe" /install /passive /norestart'
SectionEnd

; Optional section (can be disabled by the user)
Section "Accesos directos (Menu Inicio)"
  CreateDirectory "$SMPROGRAMS\AntTracker"
  CreateShortcut "$SMPROGRAMS\AntTracker\Uninstall.lnk" "$INSTDIR\uninstall.exe"
  CreateShortcut "$SMPROGRAMS\AntTracker\AntTracker.lnk" "$INSTDIR\AntTracker.exe"
  CreateShortcut "$SMPROGRAMS\AntTracker\AntLabeler.lnk" "$INSTDIR\AntLabeler.exe"
SectionEnd

;--------------------------------

; Uninstaller

Section "Uninstall"
  ; Remove registry keys
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\AntTracker"
  DeleteRegKey HKLM SOFTWARE\AntTracker

  ; Remove files and uninstaller
  Delete "$INSTDIR\*"

  ; Remove shortcuts, if any
  Delete "$SMPROGRAMS\AntTracker\*.lnk"

  ; Remove directories
  RMDir "$SMPROGRAMS\AntTracker"
  RMDir /r "$INSTDIR"
SectionEnd
