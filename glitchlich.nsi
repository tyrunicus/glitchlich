;glitchlich.nsi
;
;
; Request application privileges for Windows
	RequestExecutionLevel admin
;
;
; I am so tired of installers that don't work. Maybe my work is shoddy too, let's find out!
;   
; 03/13/2020
;#################################
; Includes
; Tell NSIS which files to include as if they were part of this script
;#################################
	!include "UMUI.nsh" # Modern UI version 2
	!include "x64.nsh" # x64 specific commands
	!include "LogicLib.nsh" #LogicLib
	!include "nsDialogs.nsh" #custom pages for inputting server and whatnot
	!include "sections.nsh" #lets us abort if stuff unchecked, some other stuff
	!include "WinVer.nsh" #lets us check the windows version for installing correct drivers
	
	
;#################################
; Installer Definitions
; Define basic variables for project
;#################################

; Define basic information about the program and company
	!define APPNAME "Lich"
	!define COMPANYNAME "LichProject"
	!define DESCRIPTION ""
	
	Var /GLOBAL Image
	Var /GLOBAL ImageHandle
	
	
; Define the version that this installer will be using.  These three must be integers!
	!define VERSIONMAJOR 4
	!define VERSIONMINOR 6
	!define VERSIONBUILD 52
; Define the version of the installer itself
	!define INSTALLERVERSION "v${VERSIONMAJOR}.${VERSIONMINOR}.${VERSIONBUILD}"

; These will be displayed by the "Click here for support information" link in "Add/Remove Programs"
; It is possible to use "mailto:" links in here to open the email client
	!define HELPURL "http://lichproject.org" # "Support Information" link
	!define UPDATEURL "http://lichproject.org" # "Product Updates" link
	!define ABOUTURL "http://lichproject.org" # "Publisher" link
	
; Define the full name of the program
	Name "${APPNAME}"
	
; Define the installation directory
	InstallDir "$PROGRAMFILES\${COMPANYNAME}\${APPNAME}"

; The name of the file to write when you compile this script
	OutFile "${APPNAME}${INSTALLERVERSION}.exe"
	
;#################################
;General
;#################################

; Get installation folder from registry if available
	InstallDirRegKey HKCU "Software\${APPNAME}" ""

; Setting the font of the installer
	SetFont "Comic Sans MS" 8
	
; Setting License Information
	LicenseText "${COMPANYNAME} License Agreement"

;#################################
; Modern Interface Configuration
;#################################

; Setting icon image file for icon on all pages
	!define MUI_ICON "Resources\Images\${APPNAME}.ico"
	
	  !define UMUI_SKIN "blue"
  
; Set to use header image on installer74
	;!define MUI_HEADERIMAGE
	
; Set which header image to use
	;!define MUI_HEADERIMAGE_BITMAP "Resources\Images\${COMPANYNAME}banner.bmp"
	;!define MUI_HEADERIMAGE_BITMAP_NOSTRETCH
	
; Set where to display header image
	;!define MUI_HEADERIMAGE_LEFT
	
; Creating warning for user to confirm if installation is aborted
	!define MUI_ABORTWARNING
	

;#################################
; Pages
; Setting how many pages, what order, and what kind there will be during the installation process.
;#################################

	!insertmacro MUI_PAGE_LICENSE "Resources\Docs\License.rtf"
	
	
	
	
	!insertmacro MUI_PAGE_COMPONENTS
	!insertmacro MUI_PAGE_DIRECTORY
	!insertmacro MUI_PAGE_INSTFILES
	
	; Set installer to include finish pages
	
	!define MUI_FINISHPAGE_SHOWREADME_TEXT "Thanks for installing ${APPNAME}! I hope this was easier than before!"
	!define MUI_FINISHPAGE_RUN "$PROGRAMFILES32\${COMPANYNAME}\${APPNAME}\${APPNAME}.rbw"
	!insertmacro MUI_PAGE_FINISH
	
	!insertmacro MUI_UNPAGE_CONFIRM
	!insertmacro MUI_UNPAGE_INSTFILES

	
	
;#################################
; Languages
; Setting which languages will be available for this installer to use.
;#################################

	!insertmacro MUI_LANGUAGE "English"	
	

;#################################
; Sections
;#################################


;Simutronics Game Launcher	
	Section "Simutronics Game Launcher SGL" SecSIMU
		
		; Set output path for Game Launcher Installer
			SetOutPath "$INSTDIR\SGL\"
		
		; Add SGL to this folder
			File /nonfatal /a /r "SGL\"
			
		;Execute installer silently
		nsExec::ExecToLog  '"$INSTDIR\SGL\lnchInst.exe" /S'
			
	SectionEnd

	
	
	
; Ruby Installation - extracts the ruby installer for 2.0.0p648, and tries to install it silently, or you ;gotta if it won't
	Section "Ruby 2.0.0-p648" SecRUBY
	
		; Set the shell context of the $SMPROGRAMS variable for All Users, not Current User
			SetShellVarContext all
			
		; Set output path for Ruby Files
			SetOutPath $INSTDIR\Ruby\
			
		; Add Ruby Files to be copied over here
			File /nonfatal /a /r "Ruby\"
			
		;Execute installer for Ruby silently (hopefully)
		nsExec::ExecToLog '"$INSTDIR\Ruby\rubyinstaller-2.0.0-p648.exe" /silent /tasks="assocfiles,modpath"' 
			
			
		
	SectionEnd

; Ruby DevKit Installer - extracts the ruby devkit installer and tries to install it silently, or you gotta if it won't, sorry guys
	Section "Ruby Dev Kit" SecRUBYDEV
	
		; Set the shell context of the $SMPROGRAMS variable for All Users, not Current User
			SetShellVarContext all
			
		; Set output path for Ruby Files
			SetOutPath "C:\Ruby200\"
			
		; Add Ruby Files to be copied over here
			File /nonfatal /a /r "RubyDevKit\"
			
		;Execute installer for Ruby silently (hopefully)
		nsExec::ExecToLog '"C:\Ruby200\RubyDevKitSFX.exe" -o"C:\Ruby200\" -y'
			
			
		
	SectionEnd

; Lich Application installation -- Includes registry entries, links, directories, and application files.
	Section "LichProject Files" SecLICH
		
		; Setting the shell context of the $SMPROGRAMS variable to apply to all users instead of current user only
			SetShellVarContext all
			
		; Set output path to the installation directory.
			SetOutPath $INSTDIR
			
		; ADD FILES TO INSTALL HERE!  Use syntax File followed by name of file to go in installation path.
			
			File /nonfatal /a /r "${APPNAME}\"
		
		; Create uninstaller
			WriteUninstaller "$INSTDIR\${APPNAME}Uninstall.exe"
		
		; Create desktop shortcut
			CreateShortCut "$DESKTOP\${APPNAME}.lnk" "$INSTDIR\${APPNAME}.rbw" "$INSTDIR\Lich.ico"
			
		; Create Start Menu Directory
			CreateDirectory "$SMPROGRAMS\${COMPANYNAME}"
		
		Sleep 1500
		
		; Create a shortcut in the start menu programs directory and point the shortcut at the program executable
			CreateShortCut "$SMPROGRAMS\${COMPANYNAME}\${APPNAME}.lnk" "$INSTDIR\${APPNAME}.rbw" "$INSTDIR\Lich.ico"
		
		; Create a shortcut in the start menu programs directory and point the shortcut at the program uninstaller
			CreateShortCut "$SMPROGRAMS\${COMPANYNAME}\${APPNAME}Uninstall.lnk" "$INSTDIR\${APPNAME}Uninstall.exe"
		
		Sleep 1500
		
		; Register DLLs or whater for Lich after installation
							
		
		; Grant Authenticated Users Full Access to the Application folder in Program Files
			AccessControl::GrantOnFile \
			"C:\Program Files (x86)\Lich" "(S-1-5-11)" "FullAccess"
			Pop $0
		
		; Grant Authenticated Users full access to the Desktop Shortcut
			AccessControl::GrantOnFile  \
			"$DESKTOP\${APPNAME}.lnk" "(S-1-5-11)" "FullAccess"
			Pop $0
		
		; Registry information for add/remove programs
			WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "DisplayName" "${APPNAME}"
			WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "UninstallString" "$INSTDIR\${APPNAME}Uninstall.exe"
			WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "QuietUninstallString" "$INSTDIR\${APPNAME}Uninstall.exe /S"
			WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "InstallLocation" $INSTDIR
			WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "DisplayIcon" "$INSTDIR\${APPNAME}.ico"
			WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "Publisher" ${COMPANYNAME}
			WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "HelpLink" ${HELPURL}"
			WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "URLUpdateInfo" ${UPDATEURL}
			WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "URLInfoAbout" ${ABOUTURL}
			WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "DisplayVersion" ${VERSIONMAJOR}.${VERSIONMINOR}.${VERSIONBUILD}
			WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "VersionMajor" ${VERSIONMAJOR}
			WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "VersionMinor" ${VERSIONMINOR}
			
		; There is no option for modifying or repairing the install
			WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "NoModify" 1
			WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "NoRepair" 1

	SectionEnd
	; end the section
	
	
;SQLITE Install Section
	Section "SQLite" SecSQLITE
	; Set output path for LMI installer files
			SetOutPath "C:\Ruby200\bin\"
		
		; Add SQLite run command line with ruby to register it as the local database.
			File /nonfatal /a /r "SQLite\"
		nsExec::ExecToLog '"C:\Ruby200\bin\gem.bat" install --local *.gem'
		
		Sleep 10000
	
	SectionEnd
	
;GTK2 3.07 Installation
	Section "GTK2" SecGTK
	; Set output path for GTK gem file
		SetOutPath "C:\Ruby200\bin\"
		
		; Add GTK gem, use command line with ruby to register it. fuckyoufuckyoufuckyou
			File /nonfatal /a /r "GTK2\"
		nsExec::ExecToLog '"C:\Ruby200\bin\ruby" "C:\Ruby200\dk.rb" init'
		nsExec::ExecToLog '"C:\Ruby200\bin\ruby" "C:\Ruby200\dk.rb" review'
		nsExec::ExecToLog '"C:\Ruby200\bin\ruby" "C:\Ruby200\dk.rb" install'
		
		nsExec::ExecToLog '"C:\Ruby200\bin\gem.bat" install native-package-installer-1.0.9.gem'
		nsExec::ExecToLog '"C:\Ruby200\bin\gem.bat" install pkg-config-1.4.1.gem'
		nsExec::ExecToLog '"C:\Ruby200\bin\gem.bat" install gobject-introspection-3.4.1.gem'
		nsExec::ExecToLog '"C:\Ruby200\bin\gem.bat" install gio2-3.4.1.gem'
		nsExec::ExecToLog '"C:\Ruby200\bin\gem.bat" install atk-3.4.1.gem'
		nsExec::ExecToLog '"C:\Ruby200\bin\gem.bat" install gdk_pixbuf2-3.4.1.gem'
		nsExec::ExecToLog '"C:\Ruby200\bin\gem.bat" install glib2-3.4.1.gem'
		nsExec::ExecToLog '"C:\Ruby200\bin\gem.bat" install pango-3.0.7.gem'
		nsExec::ExecToLog '"C:\Ruby200\bin\gem.bat" install cairo-1.16.5.gem'
		nsExec::ExecToLog '"C:\Ruby200\bin\gem.bat" install gtk2-3.0.7.gem'
		
		
		Sleep 10000
	SectionEnd
		



;Uninstaller Section - Handles the uninstalling of Lich, hopefully I did this right
	Section "Uninstall"

		; Setting the shell context of the $SMPROGRAMS variable to apply to all users instead of current user only
			SetShellVarContext all
			
		; Delete uninstaller file we created (always do first)
			Delete "$INSTDIR\${APPNAME}Uninstall.exe"
	
		; Now delete installed files added here with "Delete" command followed by file to delete ex (Delete $INSTDIR\test.txt)
			Delete "$SMPROGRAMS\${COMPANYNAME}\${APPNAME}.lnk"
			Delete "$DESKTOP\${APPNAME}.lnk"
		
		; Remove uninstaller link from Start menu
			Delete "$SMPROGRAMS\${COMPANYNAME}\${APPNAME}Uninstall.lnk"
		
		; Remove Company directory from Start Menu
			Delete "$SMPROGRAMS\${COMPANYNAME}"
		
		
		; Remove start menu directory we created
			RMDir /r "$SMPROGRAMS\${COMPANYNAME}\"
		
		; Remove installation directory we created
			RMDir /r "$INSTDIR\${COMPANYNAME}\"
		
		; Delete registry key we created if empty
			DeleteRegKey /ifempty HKCU "Software\${APPNAME}"
	
	SectionEnd


;#################################
;Descriptions
;#################################
; Language strings for SGL Section
	LangString DESC_SecSGL ${LANG_ENGLISH} "This will initiliaze the Simutronics Game Launcher."

; Language strings for Ruby Section
	LangString DESC_SecRUBY ${LANG_ENGLISH} "This will install Ruby2.0.0p648 at C:\Ruby200, and set up .rbw and PATH"
	
; Language strings for RubyDevKit Section
	LangString DESC_SecRUBYDEV ${LANG_ENGLISH} "This will run the Ruby 7Zip extract installer in C:\Ruby200\"	

; Language strings for SQLite
	LangString DESC_SecSQLITE ${LANG_ENGLISH} "This will install SQLite to C:\Ruby200\."	
	
; Language strings for LICH Section
	LangString DESC_SecLICH ${LANG_ENGLISH} "This will install Lich to Program Files and give admin access to the folder, create shortcuts, etc."

; Language strings for ODBC Section
	LangString DESC_SecGTK ${LANG_ENGLISH} "This will install the GTK Components."		

	
; Assign Language Strings to sections
	!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
		!insertmacro MUI_DESCRIPTION_TEXT ${SecSGL} $(DESC_SecSGL)
		!insertmacro MUI_DESCRIPTION_TEXT ${SecRUBY} $(DESC_SecRUBY)
		!insertmacro MUI_DESCRIPTION_TEXT ${SecRUBYDEV} $(DESC_SecRUBYDEV)
		!insertmacro MUI_DESCRIPTION_TEXT ${SecLICH} $(DESC_SecLICH)
		!insertmacro MUI_DESCRIPTION_TEXT ${SecSQLITE} $(DESC_SecSQLITE)
		!insertmacro MUI_DESCRIPTION_TEXT ${SecGTK} $(DESC_SecGTK)
	!insertmacro MUI_FUNCTION_DESCRIPTION_END

;--------------------------------
;Installer Functions


Function .onInit
	;make sure this damn this is admin
	UserInfo::GetAccountType
	pop $0
	${If} $0 != "admin" ;Require admin rights on NT4+
    MessageBox mb_iconstop "Administrator rights required!"
    SetErrorLevel 740 ;ERROR_ELEVATION_REQUIRED
    Quit
	${EndIf}
	
	;InitPluginsDir
	;File /oname=$PLUGINSDIR\image.bmp "${NSISDIR}\Contrib\Graphics\Wizard\PICTUREFORINSTALLER.bmp"
	
FunctionEnd