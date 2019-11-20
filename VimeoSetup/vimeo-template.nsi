# ====================== Macro ==============================
!define PRODUCT_NAME           "vimeo"
!define EXE_NAME               "vimeo.exe"
!define PRODUCT_VERSION        "1.0.0.1"
!define PRODUCT_PUBLISHER      "vimeo"
!define PRODUCT_LEGAL          "Copyright (C) 1999-2014 vimeo, All Rights Reserved"

!ifdef DEBUG
!define UI_PLUGIN_NAME         nsQtPluginD
!define VC_RUNTIME_DLL_SUFFIX  d
!define QT_DLL_SUFFIX          d
!else
!define UI_PLUGIN_NAME         nsQtPlugin
!define VC_RUNTIME_DLL_SUFFIX
!define QT_DLL_SUFFIX
!endif

!include "LogicLib.nsh"
!include "nsDialogs.nsh"


# ===================== Setup Info =============================
VIProductVersion                    "${PRODUCT_VERSION}"
VIAddVersionKey "ProductVersion"    "${PRODUCT_VERSION}"
VIAddVersionKey "ProductName"       "${PRODUCT_NAME}"
VIAddVersionKey "CompanyName"       "${PRODUCT_PUBLISHER}"
VIAddVersionKey "FileVersion"       "${PRODUCT_VERSION}"
VIAddVersionKey "InternalName"      "${EXE_NAME}"
VIAddVersionKey "FileDescription"   "${PRODUCT_NAME}"
VIAddVersionKey "LegalCopyright"    "${PRODUCT_LEGAL}"

# ==================== NSIS Attribute ================================

Unicode True
SetCompressor LZMA
!ifdef DEBUG
Name "${PRODUCT_NAME} [Debug]"
OutFile "vimeo-setup-debug.exe"
!else
Name "${PRODUCT_NAME}"
OutFile "vimeo-setup.exe"
!endif

Icon              "vimeo.ico"
UninstallIcon     "vimeo.ico"

# UAC
# RequestExecutionLevel none|user|highest|admin
RequestExecutionLevel admin


# Custom Install Page
Page custom QtUiPage


# Show Uninstall details
UninstPage instfiles

# ======================= Qt Page =========================
Function QtUiPage
	MessageBox MB_ICONINFORMATION|MB_OK "[Debug Info] NSIS Plugin Dir: $PLUGINSDIR" /SD IDOK
	
	GetFunctionAddress $0 OnStartExtractFiles
	${UI_PLUGIN_NAME}::BindInstallEventToNsisFunc "START_EXTRACT_FILES" $0
	
	GetFunctionAddress $0 OnUserCancelInstall
	${UI_PLUGIN_NAME}::BindInstallEventToNsisFunc "USER_CANCEL" $0
	
    ${UI_PLUGIN_NAME}::ShowSetupUI $PLUGINSDIR
FunctionEnd


Function OnStartExtractFiles
	${UI_PLUGIN_NAME}::GetInstallDirectory
	Pop $0
	StrCmp $0 "" InstallAbort 0
    StrCpy $INSTDIR "$0"
	MessageBox MB_ICONINFORMATION|MB_OK "[Debug Info] Install Dir: $0"  /SD IDOK
	
	SetOutPath $INSTDIR
  
    GetFunctionAddress $0 ___ExtractFiles
    ${UI_PLUGIN_NAME}::BackgroundRun $0
		

InstallAbort:
FunctionEnd


Function OnUserCancelInstall
	MessageBox MB_ICONINFORMATION|MB_OK "[Debug Info] OnUserCancelInstall"  /SD IDOK
	Abort
FunctionEnd


# don't edit this function
# this function generated by python script
Function ___ExtractFiles
	Call OnAfterExtractFiles
FunctionEnd


Function OnAfterExtractFiles
	Call CreateUninstall
	Call CreateShortcut
FunctionEnd


Function CreateShortcut
  SetShellVarContext all
  CreateDirectory "$SMPROGRAMS\${PRODUCT_NAME}"
  CreateShortCut "$SMPROGRAMS\${PRODUCT_NAME}\${PRODUCT_NAME}.lnk" "$INSTDIR\Bin\${EXE_NAME}"
  CreateShortCut "$SMPROGRAMS\${PRODUCT_NAME}\Uninstall ${PRODUCT_NAME}.lnk" "$INSTDIR\uninst.exe"
  CreateShortCut "$DESKTOP\${PRODUCT_NAME}.lnk" "$INSTDIR\Bin\${EXE_NAME}"
  SetShellVarContext current
FunctionEnd


Function CreateUninstall
	WriteUninstaller "$INSTDIR\uninst.exe"
	
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" "DisplayName" "${PRODUCT_NAME}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" "UninstallString" "$INSTDIR\uninst.exe"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" "DisplayIcon" "$INSTDIR\${EXE_NAME}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" "Publisher" "$INSTDIR\${PRODUCT_PUBLISHER}"
FunctionEnd

# Add an empty section, avoid compile error.
Section "None"
SectionEnd


# Uninstall Section
Section "Uninstall"

  SetShellVarContext all
  Delete "$SMPROGRAMS\${PRODUCT_NAME}\${PRODUCT_NAME}.lnk"
  Delete "$SMPROGRAMS\${PRODUCT_NAME}\Uninstall ${PRODUCT_NAME}.lnk"
  RMDir "$SMPROGRAMS\${PRODUCT_NAME}\"
  Delete "$DESKTOP\${PRODUCT_NAME}.lnk"
  SetShellVarContext current
  
  SetOutPath "$INSTDIR"

  ; Delete installed files
  Delete "$INSTDIR\*.*"

  SetOutPath "$DESKTOP"

  RMDir /r "$INSTDIR"
  RMDir "$INSTDIR"
  
  SetAutoClose true
SectionEnd



Function .onInit
	# makesure plugin directory exist
	InitPluginsDir
	
	# place Qt dlls to plugin directory
    File /oname=$PLUGINSDIR\Qt5Core${QT_DLL_SUFFIX}.dll "$%QTDIR%\bin\Qt5Core${QT_DLL_SUFFIX}.dll"
	File /oname=$PLUGINSDIR\Qt5Gui${QT_DLL_SUFFIX}.dll "$%QTDIR%\bin\Qt5Gui${QT_DLL_SUFFIX}.dll"
	File /oname=$PLUGINSDIR\Qt5Widgets${QT_DLL_SUFFIX}.dll "$%QTDIR%\bin\Qt5Widgets${QT_DLL_SUFFIX}.dll"
	File /oname=$PLUGINSDIR\Qt5Svg${QT_DLL_SUFFIX}.dll "$%QTDIR%\bin\Qt5Svg${QT_DLL_SUFFIX}.dll"
	
	CreateDirectory $PLUGINSDIR\platforms
	File /oname=$PLUGINSDIR\platforms\qwindows${QT_DLL_SUFFIX}.dll "$%QTDIR%\plugins\platforms\qwindows${QT_DLL_SUFFIX}.dll"
	
	CreateDirectory $PLUGINSDIR\styles
	File /oname=$PLUGINSDIR\styles\qwindowsvistastyle${QT_DLL_SUFFIX}.dll "$%QTDIR%\plugins\styles\qwindowsvistastyle${QT_DLL_SUFFIX}.dll"
	
	CreateDirectory $PLUGINSDIR\imageformats
	File /oname=$PLUGINSDIR\imageformats\qgif${QT_DLL_SUFFIX}.dll "$%QTDIR%\plugins\imageformats\qgif${QT_DLL_SUFFIX}.dll"
	File /oname=$PLUGINSDIR\imageformats\qicns${QT_DLL_SUFFIX}.dll "$%QTDIR%\plugins\imageformats\qicns${QT_DLL_SUFFIX}.dll"
	File /oname=$PLUGINSDIR\imageformats\qico${QT_DLL_SUFFIX}.dll "$%QTDIR%\plugins\imageformats\qico${QT_DLL_SUFFIX}.dll"
	File /oname=$PLUGINSDIR\imageformats\qjpeg${QT_DLL_SUFFIX}.dll "$%QTDIR%\plugins\imageformats\qjpeg${QT_DLL_SUFFIX}.dll"
	File /oname=$PLUGINSDIR\imageformats\qsvg${QT_DLL_SUFFIX}.dll "$%QTDIR%\plugins\imageformats\qsvg${QT_DLL_SUFFIX}.dll"
	CreateDirectory $PLUGINSDIR\iconengines
	
	File /oname=$PLUGINSDIR\iconengines\qsvgicon${QT_DLL_SUFFIX}.dll "$%QTDIR%\plugins\iconengines\qsvgicon${QT_DLL_SUFFIX}.dll"
	
	# place vc runtime dlls to plugin directory
	File /oname=$PLUGINSDIR\concrt140${VC_RUNTIME_DLL_SUFFIX}.dll "VCRuntimeDLL\concrt140${VC_RUNTIME_DLL_SUFFIX}.dll"
	File /oname=$PLUGINSDIR\msvcp140${VC_RUNTIME_DLL_SUFFIX}.dll "VCRuntimeDLL\msvcp140${VC_RUNTIME_DLL_SUFFIX}.dll"
	File /oname=$PLUGINSDIR\msvcp140_1${VC_RUNTIME_DLL_SUFFIX}.dll "VCRuntimeDLL\msvcp140_1${VC_RUNTIME_DLL_SUFFIX}.dll"
	File /oname=$PLUGINSDIR\msvcp140_2${VC_RUNTIME_DLL_SUFFIX}.dll "VCRuntimeDLL\msvcp140_2${VC_RUNTIME_DLL_SUFFIX}.dll"
	File /oname=$PLUGINSDIR\ucrtbase${VC_RUNTIME_DLL_SUFFIX}.dll "VCRuntimeDLL\ucrtbase${VC_RUNTIME_DLL_SUFFIX}.dll"
	File /oname=$PLUGINSDIR\vccorlib140${VC_RUNTIME_DLL_SUFFIX}.dll "VCRuntimeDLL\vccorlib140${VC_RUNTIME_DLL_SUFFIX}.dll"
	File /oname=$PLUGINSDIR\vcruntime140${VC_RUNTIME_DLL_SUFFIX}.dll "VCRuntimeDLL\vcruntime140${VC_RUNTIME_DLL_SUFFIX}.dll"
FunctionEnd



Function .onInstSuccess

FunctionEnd


Function .onInstFailed
    MessageBox MB_ICONQUESTION|MB_YESNO "Install Failed!" /SD IDYES IDYES +2 IDNO +1
FunctionEnd



# Before Uninstall
Function un.onInit
    MessageBox MB_ICONQUESTION|MB_YESNO "Are you sure to uninstall ${PRODUCT_NAME}?" /SD IDYES IDYES +2 IDNO +1
    Abort
FunctionEnd

Function un.onUninstSuccess

FunctionEnd


