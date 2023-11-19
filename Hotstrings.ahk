/* 
 	Author:      	Maciej Słojewski (mslonik, http://mslonik.pl)
 	Purpose:     	Facilitate maintenance of (triggerstring, hotstring) concept.
 	Description: 	Hotstrings AutoHotkey concept expanded, editable with GUI and many more options.
 	License:     	MIT License
	Year:		2022 / 2023
*/
; -----------Beginning of auto-execute section of the script, directives and general settings -------------------------------------------------
; After the script has been loaded, it begins executing at the top line, continuing until a Return, Exit, hotkey/hotstring label, or the physical end of the script is encountered (whichever comes first). 
#Requires AutoHotkey v1.1.34+ 		; Displays an error and quits if a version requirement is not met.    
#SingleInstance, 		force		; Only one instance of this script may run at a time!
#NoEnv  							; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  							; Enable warnings to assist with detecting common errors.
#LTrim							; Omits spaces and tabs at the beginning of each line. This is primarily used to allow the continuation section to be indented. Also, this option may be turned on for multiple continuation sections by specifying #LTrim on a line by itself. #LTrim is positional: it affects all continuation sections physically beneath it.
#KeyHistory, 			10			; KeyHistory is necessary for A_PriorKey
#HotkeyInterval, 		1000			; Specifies the rate of hotkey activations beyond which a warning dialog will be displayed. Default value = 2000 ms.
#MaxHotkeysPerInterval, 	200			; Specifies the rate of hotkey activations beyond which a warning dialog will be displayed. Default value = 70.
#MenuMaskKey, 			vkE8  		; vkE8 is something unassigned; this is important for F_Undo if triggerstring contained "l" and #z (Win + z) is applied as undo character
ListLines, 			Off			; ListLines is disabled to make it harder to determine how script works.
SendMode, 			Input		; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir, 		% A_ScriptDir	; Ensures a consistent starting directory.
FileEncoding, 			UTF-16		; Sets the default encoding for FileRead, FileReadLine, Loop Read, FileAppend, and FileOpen(). Unicode UTF-16, little endian byte order (BMP of ISO 10646). Useful for .ini files which by default are coded as UTF-16. https://docs.microsoft.com/pl-pl/windows/win32/intl/code-page-identifiers?redirectedfrom=MSDN Warning! UTF-16 is not recognized by Notepad++ editor (2021), which recognizes correctly UCS-2 (defined by the International Standard ISO/IEC 10646). BMP = Basic Multilingual Plane.
CoordMode, Caret,		Screen		; Only Screen makes sense for functiofirmadd/ns prepared in this script to handle position of on screen GUIs. 
CoordMode, ToolTip,		Screen		; Only Screen makes sense for functions prepared in this script to handle position of on screen GUIs. 
CoordMode, Mouse,		Screen		; Only Screen makes sense for functions prepared in this script to handle position of on screen GUIs.
;#c/* commercial only beginning
;#c*/ commercial only end
; - - - - - - - - - - - - - - - - - - - - - - - E X E  CONVERSION  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
;Parameters in this section can be used to prepare executable file of ahk2exe.exe without GUI interface. All options are set within this file. The executable is made as little as possible by exchanging .exe with .bin file. Also other tricks are applied. 
global AppIcon			:= "hotstrings.ico" ; Imagemagick: convert hotstrings.svg -alpha off -resize 96x96 -define icon:auto-resize="96,64,48,32,16" hotstrings.ico
;@Ahk2Exe-Let 			U_AppIcon=%A_PriorLine~U)^(.+"){1}(.+)".*$~$2% 	; Keep this line and the previous one together
;@Ahk2Exe-SetMainIcon  	%U_AppIcon%
global AppVersion		:= "3.6.19"	;starting on 2023-10-16 (Sunday). 
;@Ahk2Exe-Let 			U_AppVersion=%A_PriorLine~U)^(.+"){1}(.+)".*$~$2% ; Keep this line and the previous one together

;The compiler will be run at least once for each Base directive line. Only for .exe  Base it is possible to encrypt content!
; @Ahk2Exe-Base 			Unicode 64-bit.bin,, 65001 
;@Ahk2Exe-Base 			..\AutoHotkeyU64.exe,, 65001 

;EXE file header, settings common for commercial and free releases
;@Ahk2Exe-SetFileVersion 	%U_AppVersion% 
;@Ahk2Exe-SetInternalName 	Hotstrings
;@Ahk2Exe-SetLanguage 		0x0409
;@Ahk2Exe-SetLegalTrademarks 	Damian Damaszke Dam IT
;@Ahk2Exe-SetVersion 		%U_AppVersion% 
;@Ahk2Exe-SetDescription 	Advanced tool for text replacement management.
;@Ahk2Exe-Let	 			U_BinExe=%A_BasePath~.*[\.]%		;only extension
;@Ahk2Exe-Obey 			U_bits, = %A_PtrSize% * 8
;@Ahk2Exe-Obey 			U_type, = "%A_IsUnicode%" ? "Unicode" : "ANSI"
;@Ahk2Exe-ExeName 			%A_ScriptName~\.[^\.]+$%_%U_type%_%U_bits%_%U_BinExe%

;#c/* commercial only beginning
;#c*/ commercial only end

;#f/* free version only beginning
;@Ahk2Exe-SetCompanyName 	http://mslonik.pl Maciej Słojewski
;@Ahk2Exe-SetCopyright 		MIT License
;@Ahk2Exe-SetName 			%A_ScriptName~\.[^\.]+$%
;@Ahk2Exe-SetOrigFilename 	Free release
;@Ahk2Exe-SetProductName 	%A_ScriptName~\.[^\.]+$%
;@Ahk2Exe-SetProductVersion 	%U_AppVersion%
;#f*/ free version only end

;#c/* commercial only beginning
;#c*/ commercial only end

;@Ahk2Exe-Debug 		End of processing: %A_ScriptName~\.[^\.]+$%_%U_type%_%U_bits%_%U_BinExe%

; - - - - - - - - - - - - - - - - - - - - - - - S E C T I O N    O F    G L O B A L     V A R I A B L E S - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
;#c/* commercial only beginning
;#c*/ commercial only end
;#f/* free version only beginning
 global	v_SilentMode 				:= ""  
;#f*/ free version only end
,		v_LogCounter 			:= 0
,		v_CntCumGain			:= 0			;for logging, Counter Cumulative Gain
,		f_MainGUIresizing 		:= true 		;when Hotstrings Gui is displayed for the very first time; f_ stands for "flag"
,		TT_C1_Hwnd 			:= 0 
,		TT_C2_Hwnd 			:= 0
,		TT_C3_Hwnd 			:= 0
,		TT_C4_Hwnd 			:= 0 
,		HMenuCliHwnd 			:= 0 
,		HMenuAHKHwnd			:= 0 
,		HS3GuiHwnd 			:= 0 
,		HS3SearchHwnd			:= 0
,		HS4GuiHwnd 			:= 0 
,		MoveLibsHwnd			:= 0
,		TDemoHwnd 			:= 0 
,		HDemoHwnd 			:= 0 		;This is a trick to initialize global variables in order to not get warning (#Warn) message
,		ATDemoHwnd			:= 0
,		HotstringDelay			:= 0
,		WhichMenu 			:= "" 		;available values: CLI or MSI
,		v_EndChar 			:= "" 		;initialization of this variable is important in case user would like to hit "Esc" and GUI TT_C4 exists.
,		AppStartTime			:= "" 		;When application got started, this parameter is used for performance statistics
,		v_EnDis				:= true
, 		v_TotalHotstringCnt 	:= 0
,		v_LibHotstringCnt		:= 0 		;no of (triggerstring, hotstring) definitions in single library
,		ini_TTCn				:= 0 		;this variable could be triggered by left mouse click when script is initialized.
,		v_Qinput				:= "" 		; to store substring of v_InputString related to possible question mark (inside) option
,		c_MsgBoxIconError		:= 16		;constant, MsgBox icon hand (stop/error)
,		c_MsgBoxIconQuestion	:= 32		;constant, MsgBox icon question
,		c_MsgBoxIconExclamation	:= 48		;constant, MsgBox icon exclamation
,		c_MsgBoxIconInfo		:= 64		;constant, MsgBox icon asterisk (info)
,		c_MsgBoxButtYesNo		:= 4			;constant, MsgBox buttons, Yes/No
,		v_Triggerstring		:= ""		;to store d(t, o, h) -> t entered by user in GUI.
,		ini_ShowWhiteChars		:= false		;show white characters (e.g. space) within GUI in form of special characters. For example <space> = U+2423 (open box ␣)
;#f/* free version only beginning
 ,		v_LicenseType			:= "free"		"pro" or "free"
;#f*/ free version only end
;#c/* commercial only beginning
;#c*/ commercial only end
;#c/* commercial only beginning
;#c*/ commercial only end
;#f/* free version only beginning
 ,		v_LicenseName			:= "GNU GPL v3.x license"
;#f*/ free version only end
,		c_xmarg 				:= 10				;pixels, default value (it can be changed by user)
,		c_ymarg 				:= 10				;pixels, default value (it can be changed by user)
,		c_FontColor			:= "Black"
,		c_FontColorHighlighted	:= "Blue"
,		c_WindowColor			:= "Default"
,		c_ControlColor 		:= "Default"
,		c_FontSize 			:= 10 ;points
,		c_FontType 			:= "Consolas"
,		f_100msRun 			:= false				;global flag: timer is running, 100 ms, for concurrent press of Shift keys
,		f_WasReset			:= false				;global flag: Shift key memory reset (to reset hotstring recognizer)
,		c_MHDelimiter			:= "¦"				;global constant: unique character applied as delimiter for menu hotstrings
,		c_TextDelimiter		:= "‖"				;global constant: unique character applied as delimiter for text
,		c_dHK_UndoLH			:= "~#z"				;global constant: default (d) hotkey (HK) for Undo
,		c_dHK_CopyClip			:= "~^#c"				;global constant: default (d) hotkey (HK) for Copy to clipboard future hotstring content
,		c_dHK_CallGUI 			:= "#^h"				;global constant: default (d) hotkey (HK) for calling main application GUI
,		c_dHK_ToggleTt			:= "none"				;global constant: default (d) hotkey (HK) for toggling the triggestring tips
;#c/* commercial only beginning
;#c*/ commercial only end
; - - - - - - - - - - - - - - - - - - - - - - - B E G I N N I N G    O F    I N I T I A L I Z A T I O N - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
Critical, On
F_LoadCreateTranslationTxt() 			;default set of text string definitions (English) is loaded into memory at the very beginning in case if Config.ini doesn't exist yet, but some MsgBox have to be shown.
F_CheckCreateConfigIni() 			;Try to load up configuration file. If those files do not exist, create them. If it isn't possible, exit.
F_CheckIfMoveToProgramFiles()			;Checks if move Hotstrings folder to Program Files folder and then restarts application.
F_CheckIfRemoveOldDir()				;Checks content of Config.ini in order to remove old script directory.
F_CheckFileEncoding(A_ScriptFullPath)	;checks if script is utf-8 compliant. it has plenty to do wiith github download etc.
F_Load_ini_HADL()					;HADL = Hotstrings Application Data Libraries
F_Load_ini_GuiReload()
F_Load_ini_CheckRepo()
F_Load_ini_DownloadRepo()
F_LoadSignalingParams()

if (ini_CheckRepo)
	F_VerUpdCheckServ("OnStartUp")
if (ini_DownloadRepo) and (F_VerUpdCheckServ("ReturnResult"))
{
	ini_GuiReload := true
	IniWrite, % ini_GuiReload, % ini_HADConfig, GraphicalUserInterface, GuiReload
	F_VerUpdDownload()
}
if (ini_GuiReload) and (FileExist(A_ScriptDir . "\" . "temp.exe"))	;flag ini_GuiReload is set also if Update function is run with Hostrings.exe. So after restart temp.exe is removed.
{
	try
		FileDelete, % A_ScriptDir . "\" . "temp.exe"
	catch e
	{
		MsgBox, 16, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["error"], % "ErrorLevel" . A_Tab . ErrorLevel	;16 = Icon Hand (stop/error)
					. "`n`n" . "A_LastError" . A_Tab . A_LastError	;183 : Cannot create a file when that file already exists.
					. "`n`n" . "Exception" . A_Tab . e
	}
}

if ( !Instr(FileExist(A_ScriptDir . "\Languages"), "D"))				; if  there is no "Languages" subfolder 
{
	FileCreateDir, %A_ScriptDir%\Languages
	if (ErrorLevel)
	{
		MsgBox, % c_MsgBoxIconError, % SubStr(A_ScriptName, 1, -4) .  ":" . A_Space . TransA["error"], % TransA["""Languages"" subfolder wasn't created for some reason."]
		ExitApp, 9 ;""Languages"" subfolder wasn't created for some reason.
	}	
	else	
		MsgBox, 48, % SubStr(A_ScriptName, 1, -4) .  ":" . A_Space . TransA["warning"], % TransA["There was no Languages subfolder, so one now is created."] . A_Space . "`n" 
			. A_ScriptDir . "\Languages"
}

F_Load_ini_Language()
if (!FileExist(A_ScriptDir . "\Languages\" . ini_Language))			; if there is no ini_language .ini file, e.g. v_langugae == Polish.txt and there is no such file in Languages folder
{
	MsgBox, 48, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["warning"], % TransA["There is no"] . A_Space . ini_Language . A_Space . TransA["file in Languages subfolder!"]
		. "`n`n" 
		. TransA["The default"] . A_Space . "English.txt" . A_Space . TransA["file is now created in the following subfolder:"] 
		. "`n`n" 
		. A_ScriptDir . "\Languages\"
	ini_Language := "English.txt"
	if (!FileExist(A_ScriptDir . "\Languages\" . "English.txt"))
		F_LoadCreateTranslationTxt("create")
	else
		F_LoadCreateTranslationTxt("load")	
}
else
	F_LoadCreateTranslationTxt("load")

; 3. Load content of configuration file into configuration variables. The configuration variable names start with "ini_" prefix.
;Read all variables from specified language .ini file. In order to distinguish GUI text from any other string or variable used in this script, the GUI strings are defined with prefix "t_".

F_LoadGUIPos()
F_LoadGUIstyle()
F_LoadFontSize()
F_LoadSizeOfMargin()
F_LoadFontType()
F_LoadTTStyling()
F_LoadHMStyling()
F_LoadATStyling()
F_LoadHTStyling()
F_LoadUHStyling()
F_LoadConfiguration()
F_LoadEndChars() ; Read from Config.ini values of EndChars. Modifies the set of characters used as ending characters by the hotstring recognizer.

F_ValidateIniLibSections() ;create Libraries subfolder if it doesn't exist ; Load from / to Config.ini from Libraries folder
F_CreateLogFolder()

F_InitiateTrayMenus(v_SilentMode)

F_GuiHS3_Create()
F_HS3_DefineConstants()
F_GuiHS3_DetermineConstraints()
F_GuiHS4_Create()
F_GuiHS4_DetermineConstraints()
if (ini_Sandbox)
{
	GuiControl, Show, % IdEdit10
	GuiControl, Show, % IdEdit10b
}
else
{
	GuiControl, Hide, % IdEdit10
	GuiControl, Hide, % IdEdit10b
}

F_UpdateSelHotLibDDL()

if (ini_HK_IntoEdit != "none")
{
	Hotkey, IfWinExist, % "ahk_id" HS3GuiHwnd
	Hotkey, % ini_HK_IntoEdit, F_PasteFromClipboard, On
	Hotkey, IfWinExist, % "ahk_id" HS4GuiHwnd
	Hotkey, % ini_HK_IntoEdit, F_PasteFromClipboard, On
	Hotkey, IfWinExist			;To turn off context sensitivity (that is, to make subsequently-created hotkeys work in all windows)
}

; 4. Load definitions of (triggerstring, hotstring) from Library subfolder.
Gui, 1: Default				;this line is necessary to not show too many Guis on time of loading hotstrings from library
F_LoadHotstringsFromLibraries()	;→ F_LoadDefinitionsFromFile() -> F_CreateHotstring
F_LoadTTperLibrary()
F_Sort_a_Triggers(a_Combined, ini_TipsSortAlphabetically, ini_TipsSortByLength)
F_InitiateInputHook()

TrayTip, % A_ScriptName, % TransA["Hotstrings have been loaded"], , 1 ;1 = Info icon
SetTimer, HideTrayTip, -5000				;more general approach; for details see https://www.autohotkey.com/docs/commands/TrayTip.htm#Remarks

Loop, Files, %A_ScriptDir%\Languages\*.txt
	Menu, SubmenuLanguage, Add, %A_LoopFileName%, F_ChangeLanguage
F_ChangeLanguage()

Menu, Tray, UseErrorLevel	;This line is necessary for both Menus to make future use of UseErrorLevel parameter.
Menu, StyleGUIsubm, Add, % TransA["Light (default)"],	F_StyleOfGUI
Menu, StyleGUIsubm, Add, % TransA["Dark"],			F_StyleOfGUI
F_StyleOfGUI()

Menu, ConfGUI,		Add, % TransA["Save position of application window"] . "`tCtrl + S",				F_SaveGUIPos
Menu, ConfGUI,		Add, % TransA["Change language"], 											:SubmenuLanguage
Menu, ConfGUI, 	Add	;To add a menu separator line, omit all three parameters.
Menu, ConfGUI, 	Add, % TransA["Show Sandbox"] . "`tCtrl + F6", 									F_ToggleSandbox
if (ini_Sandbox)
	Menu, ConfGUI, Check, 	% TransA["Show Sandbox"] . "`tCtrl + F6"
else
	Menu, ConfGUI, UnCheck, 	% TransA["Show Sandbox"] . "`tCtrl + F6"

Menu, ConfGUI,		Add, 	% TransA["Toggle main GUI"] . "`tF4",								F_ToggleRightColumn
if (ini_WhichGui = "HS3")
	Menu, ConfGUI, Check, 	% TransA["Toggle main GUI"] . "`tF4"
else
	Menu, ConfGUI, UnCheck, 	% TransA["Toggle main GUI"] . "`tF4"

Menu, ConfGUI, 	Add	;To add a menu separator line, omit all three parameters.
Menu, ConfGUI,		Add, 	% TransA["Style of GUI"],										:StyleGUIsubm

F_CreateMenu_SizeOfMargin()

Menu, ConfGUI,		Add, 	% TransA["Size of margin:"] . A_Space . "x" . A_Space . TransA["pixels"],	:SizeOfMX
Menu, ConfGUI,		Add, 	% TransA["Size of margin:"] . A_Space . "y" . A_Space . TransA["pixels"],	:SizeOfMY

Menu, SizeOfFont,	Add,		8,															F_SizeOfFont
Menu, SizeOfFont,	Add,		9,															F_SizeOfFont
Menu, SizeOfFont,	Add,		10,															F_SizeOfFont
Menu, SizeOfFont,	Add,		11,															F_SizeOfFont
Menu, SizeOfFont,	Add,		12,															F_SizeOfFont
Menu, SizeOfFont, 	Check,	% c_FontSize						
Menu, ConfGUI,		Add, 	% TransA["Size of font"],										:SizeOfFont

Menu, FontTypeMenu,	Add,		Arial,														F_FontType
Menu, FontTypeMenu,	Add,		Calibri,														F_FontType
Menu, FontTypeMenu,	Add,		Consolas,														F_FontType
Menu, FontTypeMenu,	Add,		Courier,														F_FontType
Menu, FontTypeMenu, Add,		Verdana,														F_FontType
Menu, FontTypeMenu, Check,	% c_FontType						
Menu, ConfGUI,		Add, 	% TransA["Font type"],											:FontTypeMenu

Menu, Submenu1Shortcuts, Add, % TransA["Call Graphical User Interface"] 				. "`t" . F_ParseHotkey(ini_HK_Main, 	"space"),	F_GuiShortDef
Menu, Submenu1Shortcuts, Add, % TransA["Copy clipboard content into ""Enter hotstring"""] . "`t" . F_ParseHotkey(ini_HK_IntoEdit, "space"),	F_GuiShortDef
Menu, Submenu1Shortcuts, Add, % TransA["Undo the last hotstring"] 					. "`t" . F_ParseHotkey(ini_HK_UndoLH, 	"space"),	F_GuiShortDef
Menu, Submenu1Shortcuts, Add, % TransA["Toggle triggerstring tips"] 					. "`t" . F_ParseHotkey(ini_HK_ToggleTt, "space"),	F_GuiShortDef
Menu, Configuration, 	Add, % TransA["Shortcut (hotkey) definitions"],							:Submenu1Shortcuts

;Warning: order of SubmenuEndChars have to be alphabetical. Keep an eye on it. This is because after change of language specific menu items are related with associative array which also keeps to alphabetical order.
Menu, SubmenuEndChars, Add, % TransA["Apostrophe '"], 											F_ToggleEndChars
Menu, SubmenuEndChars, Add, % TransA["Backslash \"], 											F_ToggleEndChars
Menu, SubmenuEndChars, Add, % TransA["Closing Curly Bracket }"], 								F_ToggleEndChars
Menu, SubmenuEndChars, Add, % TransA["Closing Round Bracket )"],									F_ToggleEndChars
Menu, SubmenuEndChars, Add, % TransA["Closing Square Bracket ]"],								F_ToggleEndChars
Menu, SubmenuEndChars, Add, % TransA["Colon :"], 												F_ToggleEndChars
Menu, SubmenuEndChars, Add, % TransA["Comma ,"], 												F_ToggleEndChars
Menu, SubmenuEndChars, Add, % TransA["Dot ."], 												F_ToggleEndChars
Menu, SubmenuEndChars, Add, % TransA["Enter"],												F_ToggleEndChars
Menu, SubmenuEndChars, Add, % TransA["Exclamation Mark !"], 									F_ToggleEndChars
Menu, SubmenuEndChars, Add, % TransA["Minus -"], 												F_ToggleEndChars
Menu, SubmenuEndChars, Add, % TransA["Opening Curly Bracket {"], 								F_ToggleEndChars
Menu, SubmenuEndChars, Add, % TransA["Opening Round Bracket ("],									F_ToggleEndChars
Menu, SubmenuEndChars, Add, % TransA["Opening Square Bracket ["],								F_ToggleEndChars
Menu, SubmenuEndChars, Add, % TransA["Question Mark ?"], 										F_ToggleEndChars
Menu, SubmenuEndChars, Add, % TransA["Quote """], 											F_ToggleEndChars
Menu, SubmenuEndChars, Add, % TransA["Semicolon `;"], 											F_ToggleEndChars
Menu, SubmenuEndChars, Add, % TransA["Slash /"], 												F_ToggleEndChars
Menu, SubmenuEndChars, Add, % TransA["Space"],												F_ToggleEndChars
Menu, SubmenuEndChars, Add, % TransA["Tab"], 												F_ToggleEndChars
Menu, SubmenuEndChars, Add, % TransA["Underscore _"], 											F_ToggleEndChars
F_ToggleEndChars()
Func_GuiEventsMenu		:= func("F_GuiEvents")
Menu, Configuration,		Add, % TransA["Events: signalling"],									% Func_GuiEventsMenu
Func_GuiEventsMenu.Call(true)
Func_GuiStylingMenu		:= func("F_EventsStyling")
Menu, Configuration,		Add, % TransA["Events: styling"],										% Func_GuiStylingMenu
Func_GuiStylingMenu.Call(true)		
Menu, Configuration,		Add, % TransA["Graphical User Interface"], 								:ConfGUI
Menu, Configuration,		Add		
Menu, Configuration,  	   	Add, % TransA["Toggle trigger characters (↓ or EndChars)"], 				:SubmenuEndChars
Menu, Configuration,  	   	Add		
Menu, Configuration,	 	Add, % TransA["Restore default configuration"],							F_RestoreDefaultConfig
Menu, Configuration,		Add, % TransA["Open Config.ini folder in Windows Explorer"],				F_OpenConfigIniLocation	
Menu, Configuration,		Add, % TransA["Open Config.ini in your default editor"],					F_OpenConfigIniInEditor
Menu, Configuration,		Add, % TransA["Copy Config.ini folder path to Clipboard"],					F_PathtoClipboard
Menu, Configuration,		Add	;line separator		
;#c/* commercial only beginning
;#c*/ commercial only end
;#f/* free version only beginning
 Menu, SubmenuPath,		Add, % TransA["User Data: restore it to default location"], 			F_Empty
 Menu, SubmenuPath,		Add, % TransA["User Data: move it to new location"],					F_Empty
 Menu, SubmenuPath,		Add		
 Menu, SubmenuPath,		Add, % TransA["Config.ini file: restore it to default location"],			F_Empty
 Menu, SubmenuPath,		Add, % TransA["Config.ini file: move it to script / app location"],			F_Empty
 Menu, SubmenuPath,		Add
 Menu, SubmenuPath,		Add, % TransA["Application Data: restore it to default location"],	F_Empty
 Menu, SubmenuPath,		Add, % TransA["Application Data: move it to new location"],			F_Empty
 Menu, Configuration, 		Add, % TransA["Location of application specific data"],					:SubmenuPath
 Menu, SubmenuPath,		Disable, % TransA["User Data: restore it to default location"]
 Menu, SubmenuPath,		Disable, % TransA["User Data: move it to new location"]
 Menu, SubmenuPath,		Add
 Menu, SubmenuPath,		Disable, % TransA["Config.ini file: restore it to default location"]
 Menu, SubmenuPath,		Disable, % TransA["Config.ini file: move it to script / app location"]
 Menu, SubmenuPath,		Add
 Menu, SubmenuPath,		Disable, % TransA["Application Data: restore it to default location"]
 Menu, SubmenuPath,		Disable, % TransA["Application Data: move it to new location"]
 Menu, Configuration, 		Disable, % TransA["Location of application specific data"]
;#f*/ free version only end
Menu, HSMenu, 			Add, % TransA["Configuration"], 										:Configuration
Menu, HSMenu, 			Add, % TransA["Search (F3)"], 										F_Searching
;#c/* commercial only beginning
;#c*/ commercial only end
;#f/* free version only beginning
 Menu, LibrariesSubmenu,	Add, % TransA["Enable/disable libraries"], 								F_Empty
 Menu, LibrariesSubmenu,	Disable, % TransA["Enable/disable libraries"]
;#f*/ free version only end
;#c/* commercial only beginning
;#c*/ commercial only end
;#f/* free version only beginning
 Menu, LibrariesSubmenu, 	Add, % TransA["Enable/disable triggerstring tips"], 						F_Empty
 Menu, LibrariesSubmenu, 	Disable, % TransA["Enable/disable triggerstring tips"]
;#f*/ free version only end
F_RefreshListOfLibraries()	; this function calls F_RefreshListOfLibraryTips() as both options are interrelated
Menu, LibrariesSubmenu,	Add	;To add a menu separator line, omit all three parameters.
Menu, LibrariesSubmenu,	Add, % TransA["Visit public libraries webpage"],							F_PublicLibraries
Menu, LibrariesSubmenu,	Add, % TransA["Open libraries folder in Windows Explorer"], 				F_OpenLibrariesFolderInExplorer
Menu, LibrariesSubmenu,	Add, % TransA["Download public libraries"],								F_DownloadPublicLibraries
Menu, LibrariesSubmenu,	Add	;To add a menu separator line, omit all three parameters.
Menu, LibrariesSubmenu, 	Add, % TransA["Import from .ahk to .csv"],								F_ImportLibrary
Menu, ExportSubmenu, 	Add, % TransA["Static hotstrings"],  									F_ExportLibraryStatic
Menu, ExportSubmenu, 	Add, % TransA["Dynamic hotstrings"],  									F_ExportLibraryDynamic
Menu, LibrariesSubmenu, 	Add, % TransA["Export from .csv to .ahk"],								:ExportSubmenu
Menu, LibrariesSubmenu,	Add	;line separator
Menu, LibrariesSubmenu,	Add,	% TransA["Add new library file"],									F_GuiAddLibrary
Menu, LibrariesSubmenu,	Add, % TransA["Rename selected library filename"],						F_RenameLibrary
Menu, LibrariesSubmenu,	Add, % TransA["Delete selected library file"],							F_DeleteLibrary
Menu, LibrariesSubmenu,	Add, % TransA["Copy Libraries folder path to Clipboard"],					F_PathtoClipboard
Menu, LibrariesSubmenu,	Add	;line separator
Menu, LibrariesSubmenu,	Add, % TransA["Edit library header"],									F_EditLibHeader
Menu, LibrariesSubmenu,	Add, % TransA["Show library header"],									F_ShowLibHeader

Menu, HSMenu, 			Add, % TransA["Libraries"], 											:LibrariesSubmenu
Menu, HSMenu, 			Add, % TransA["Clipboard Delay (F7)"], 									F_GuiHSdelay

Menu, SubmenuReload, 	Add,	% TransA["Reload in default mode"] . "`tShift + Ctrl + R",				F_ReloadApplication
;#c/* commercial only beginning
;#c*/ commercial only end
;#f/* free version only beginning
 Menu, SubmenuReload, 	Add,	% TransA["Reload in silent mode"],									F_Empty
 Menu, SubmenuReload, 	Disable,	% TransA["Reload in silent mode"]
;#f*/ free version only end
Menu, AppSubmenu, 		Add,	% TransA["Reload"],												:SubmenuReload

Menu, AppSubmenu,		Add, % TransA["Suspend Hotstrings and all tips"] . "`tF10",					F_SuspendTipsAndHotkeys
Menu, AppSubmenu,		Add, % TransA["Suspend all tips"] . "`tF11",								F_SuspendAllTips
Menu, AppSubmenu,		Add, % TransA["Exit"],												F_Exit
Menu, AppSubmenu,		Add	;To add a menu separator line, omit all three parameters.
Menu, AppSubmenu,		Add, % TransA["Application hotstrings && hotkeys"],						F_InternalHot
Menu, AppSubmenu,		Add	;To add a menu separator line, omit all three parameters.
Menu, AutoStartSub,		Add, % TransA["Default mode"],										F_AddToAutostart
Menu, AutoStartSub,		Add,	% TransA["Silent mode"],											F_AddToAutostart
Menu, AppSubmenu, 		Add, % TransA["Add to Autostart"],										:AutoStartSub

; F_CompileSubmenu()	;no longer used
;#c/* commercial only beginning
;#c*/ commercial only end
;#f/* free version only beginning
 Menu, AppSubmenu,		Add, % TransA["Log triggered hotstrings"],								F_Empty
 Menu, AppSubmenu,		Add, % TransA["Open log folder in Windows Explorer"], 						F_Empty
 Menu, AppSubmenu,		Add, % TransA["Open current log (view only)"],							F_Empty
 Menu, AppSubmenu,		Add, % TransA["Copy Log folder path to Clipboard"],						F_Empty
 Menu, AppSubmenu,		Disable, % TransA["Log triggered hotstrings"]
 Menu, AppSubmenu,		Disable, % TransA["Open log folder in Windows Explorer"]
 Menu, AppSubmenu,		Disable, % TransA["Open current log (view only)"]					
 Menu, AppSubmenu,		Disable, % TransA["Copy Log folder path to Clipboard"]
;#f*/ free version only end
Menu, AppSubmenu,		Add
Menu, AppSubmenu,		Add, % TransA["Application statistics"] . "`tShift + Ctrl + S",				F_AppStats
Menu, AboutHelpSub,		Add,	% TransA["Help: Hotstrings application"] . "`tF1",					F_GuiAboutLink1
Menu, AboutHelpSub,		Add,	% TransA["Help: AutoHotkey Hotstrings reference guide"] . "`tCtrl+F1",	F_GuiAboutLink2
Menu, AboutHelpSub,		Add
;#c/* commercial only beginning
;#c*/ commercial only end
Menu, AboutHelpSub,		Add,	% TransA["About this application..."],								F_GuiAbout
Menu, AboutHelpSub,		Add
Menu, AboutHelpSub,		Add, % TransA["Show intro"],											F_GuiShowIntro 
Menu, HSMenu,			Add, % TransA["Application"],											:AppSubmenu
Menu, HSMenu, 			Add, % TransA["About / Help"], 										:AboutHelpSub
Gui,  HS3: Menu, HSMenu
Gui,  HS4: Menu, HSMenu

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - Menu / Context menus - - - - - - - - - - - - - - - - - -
Menu, ListView1_ContextMenu, Add, % TransA["Show library header"],								F_ShowLibHeader
Menu, ListView1_ContextMenu, Add, % TransA["Edit library header"],								F_EditLibHeader
Menu, ListView1_ContextMenu, Add	
Menu, ListView1_ContextMenu, Add, % TransA["Move definition to another library"],					F_MoveList
Menu, ListView1_ContextMenu, Add, % TransA["Delete selected definition"],							F_DeleteHotstring
Menu, ListView1_ContextMenu, Add, % TransA["Enable/disable selected definition"],					F_LV1_EnDisDefinition
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - Menu / Context menus - - - - - - - - - - - - - - - - - -
F_MenuLogEnDis()	;Position in Menu about loging
F_GuiAbout_CreateObjects()
F_GuiAbout_DetermineConstraints()
F_GuiVersionUpdate_CreateObjects()
F_GuiVersionUpdate_DetermineConstraints()

if (ini_ShowIntro)
	F_GuiShowIntro()
if (ini_OHTtEn)	;Ordinary Hostring Tooltip Enable
	F_Tt_HWT()	;prepare Gui → Tooltip (HWT = Hotstring Was Triggered)
if (ini_UHTtEn)	;Undid Hotstring Tooltip Enable
	F_Tt_ULH()	;prepare Gui → Tooltip (ULH = Undid the Last Hotstring)

F_LoadGUIstatic()
if (ini_TTCn = 4)	;static triggerstring / hotstring GUI 
	F_GuiTrigTipsMenuDefC4()
if (ini_GuiReload) and (v_SilentMode != "l")
	F_GUIInit()

;#c/* commercial only beginning
;#c*/ commercial only end

AppStartTime := A_Now	;Date and time math can be performed with EnvAdd and EnvSub. Also, FormatTime can format the date and/or time according to your locale or preferences.
Critical, Off
; -------------------------- SECTION OF HOTKEYS ---------------------------
#If WinExist("ahk_id" TT_C1_Hwnd) or WinExist("ahk_id" TT_C2_Hwnd) or WinExist("ahk_id" TT_C3_Hwnd)	;active triggerstring tips
	or WinExist("ahk_id" TT_C4_Hwnd)													;static triggerstring tips

	^Tab::	;new thread starts here
	+^Tab::
	^Up::
	^Down::
	^Enter::
	^WheelUp::
	^WheelDown::
	^MButton::
		Critical, On
		; OutputDebug, % "1)A_ThisHotkey:" . A_ThisHotKey . "`n"
		SetTimer, TurnOff_Ttt, Off
		F_TTMenu_Keyboard()
		return
		
	~*Control::
		; OutputDebug, % "2)A_ThisHotkey:" . A_ThisHotKey . "`n"
		Hotstring("Reset")
	return	

	~LButton::			;if LButton is pressed outside of MenuTT then MenuTT is destroyed; but when mouse click is on/in, it runs hotstring as expected → F_TTMenu_Mouse().
		F_TTMenu_Mouse()	;the priority of g F_TTMenuStatic_Mouse is lower than this "interrupt"
	return
;#c/* commercial only beginning		
;#c*/ commercial only end		
#If
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#If WinExist("ahk_id" HMenuAHKHwnd) or WinExist("ahk_id" HMenuCliHwnd)	;this part of code will be run after InputHook processed a character; If HMenu is present on the screen

	Esc::
		Gui, HMenuAHK: Destroy
		SendRaw, % v_InputString	;SendRaw in order to correctly produce escape sequences from v_InputString ({}^!+#)
		v_InputString 			:= ""
	,	v_InputH.VisibleText 	:= true
	return

	Tab::	;new thread starts here
	+Tab::
	Up::
	Down::
	WheelUp::
	WheelDown::
	MButton::
	1::
	2::
	3::
	4::
	5::
	6::
	7::
		Critical, On
		; OutputDebug, % "A_ThisHotkey:" . A_ThisHotKey . "`n"
		SetTimer, TurnOff_Ttt, Off
		if (WinExist("ahk_id" HMenuAHKHwnd))
			F_HMenu_Keyboard("MSI")
		if (WinExist("ahk_id" HMenuCliHwnd))
			F_HMenu_Keyboard("MCL")
	return

	Enter::
		if (WinExist(SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"]))	;if msgbox explaining shortcuts for this menu is open, close it upon enter
		{
			WinClose, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"]
			return
		}	
		else	;if not, handle choice made by user
		{
			Critical, On
			; OutputDebug, % "A_ThisHotkey:" . A_ThisHotKey . "`n"
			SetTimer, TurnOff_Ttt, Off
			if (WinExist("ahk_id" HMenuAHKHwnd))
				F_HMenu_Keyboard("MSI")
			if (WinExist("ahk_id" HMenuCliHwnd))
				F_HMenu_Keyboard("MCL")
			return
		}	

	~LButton UP::				;if LButton is UP; the UP modifier is crucial here
		Critical, On
		if (WinExist("ahk_id" HMenuAHKHwnd))
			F_HMenu_Mouse("MSI")
		if (WinExist("ahk_id" HMenuCliHwnd))
			F_HMenu_Mouse("MCL")
	return

	?::						;to display short-hand information about hotkeys active for HMenu
		MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["Shortcuts available for hotstring menu:"] . "`n`n" ;it cannot be modal (always on top) as HMenuAHKHwnd has already feature "always on top"
			. "Tab" . A_Tab . A_Tab . A_Tab .	 	 TransA["down"] . "`n"
			. "Shift + Tab" . A_Tab . A_Tab . 	 	 TransA["up"] . "`n"
			. "↓" . A_Tab . A_Tab . A_Tab .   	 	 TransA["down"] . "`n"
			. "↑" . A_Tab . A_Tab . A_Tab .   	 	 TransA["up"] . "`n"
			. "Enter" . A_Tab . A_Tab . A_Tab .	 TransA["enter selected hotstring"] . "`n"
			. "Left Mouse Button" . A_Tab . A_Tab .	 TransA["enter selected hotstring"] . "`n"
			. "Esc" . A_Tab . A_Tab . A_Tab .		 TransA["Close and interrupt"]
	return
#If
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#If WinActive("ahk_id" HS3SearchHwnd)
	^f::
	^s::
	F3::		;To disable all hotstrings definitions within search window.
		Suspend, Permit		;Any hotkey/hotstring subroutine whose very first line is Suspend, Permit  will be exempt from suspension. In other words, the hotkey will remain enabled even while suspension is ON.
		HS3SearchGuiEscape()
	return	;end of this thread
	Down::
		Suspend, Permit		;Any hotkey/hotstring subroutine whose very first line is Suspend, Permit will be exempt from suspension. In other words, the hotkey will remain enabled even while suspension is ON.
		F_DestroyTriggerstringTips(ini_TTCn)
		F_HS3Search_Down()
	return
	Up::
		Suspend, Permit		;Any hotkey/hotstring subroutine whose very first line is Suspend, Permit will be exempt from suspension. In other words, the hotkey will remain enabled even while suspension is ON.
		F_DestroyTriggerstringTips(ini_TTCn)
		F_HS3Search_Up()
	return
	Right::
		Suspend, Permit		;Any hotkey/hotstring subroutine whose very first line is Suspend, Permit will be exempt from suspension. In other words, the hotkey will remain enabled even while suspension is ON.
		F_DestroyTriggerstringTips(ini_TTCn)
		F_HS3SearchRight()
	return
	Left::
		Suspend, Permit		;Any hotkey/hotstring subroutine whose very first line is Suspend, Permit will be exempt from suspension. In other words, the hotkey will remain enabled even while suspension is ON.
		F_DestroyTriggerstringTips(ini_TTCn)
		F_HS3SearchLeft()
	return
	Tab::
		Suspend, Permit		;Any hotkey/hotstring subroutine whose very first line is Suspend, Permit will be exempt from suspension. In other words, the hotkey will remain enabled even while suspension is ON.
	return
#If


#If WinActive("ahk_id" HotstringDelay)
	F7::
		HSDelGuiClose()	;Gui event!
		HSDelGuiEscape()	;Gui event!
	return
#If

#If WinActive("ahk_id" HS3GuiHwnd) or WinActive("ahk_id" HS4GuiHwnd) ; the following hotkeys will be active only if Hotstrings windows are active at the moment. 
	F1::	;new thread starts here
		F_GuiAboutLink1()
	return

	^F1:: ;new thread starts here
		F_GuiAboutLink2()
	return

	F2:: ;new thread starts here
		Switch F_WhichGui()
		{
			Case "HS3":
				Gui, HS3: Submit, NoHide
				if (!v_SelectHotstringLibrary) or (v_SelectHotstringLibrary = TransA["↓ Click here to select hotstring library ↓"])
				{
					MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["In order to display library content please at first select hotstring library"] . "."
					return
				}
				GuiControl, HS3: Focus, v_SelectHotstringLibrary
				GuiControl, Focus, % IdListView1
				if (LV_GetNext(0, "Focused"))
					LV_Modify(LV_GetNext(0, "Focused"), "+Select +Focus")
				else
					LV_Modify(1, "+Select +Focus")
				return
			Case "HS4": return
		}
	^s::	;new thread starts here
		F_SaveGUIPos()
	return

	^f::
	F3:: ;new thread starts here
		Suspend, Permit		;Any hotkey/hotstring subroutine whose very first line is Suspend, Permit will be exempt from suspension. In other words, the hotkey will remain enabled even while suspension is ON.
		F_Searching()	;To disable all hotstrings definitions within search window.
	return

	F4::	;new thread starts here
		F_ToggleRightColumn()
	return

	F5::	;new thread starts here
		F_WhichGui()
		F_Clear()
	return

	F6::	;new thread starts here
		if (!ini_Sandbox) or (A_Gui = "HS4")
			return
		else
		{
			GuiControl, Focus, % IdEdit10
		}
	return

	F7:: ;new thread starts here
		Gui, % F_WhichGui() . ": +Disabled"	;thanks to this line user won't be able to interact with main hotstring window if TTStyling window is available
		F_GuiHSdelay()
	return

	F8::	;new thread starts here
	~Del::
		GuiControlGet, FocusedControl, HS3: Focus
		; OutputDebug, % "FocusedControl2:" . FocusedControl2 . "`n"
		if (FocusedControl = "SysListView321")
			F_DeleteHotstring()
	return

	F9::	;new thread starts here
		F_AddHotstring()
		v_InputString := ""	;in order to reset internal recognizer and let triggerstring tips to appear
	return
	
	F10:: ;new thread starts here
		F_SuspendTipsAndHotkeys()							;suspend hotstrings
	return

	F11::
		F_SuspendAllTips("toggle", true)
	return	

	^+r::	;new thread starts here
		F_ReloadApplication()							;reload into default mode of operation
	return

	^F6::	;new thread starts here; only on time of degugging HS3GuiSize will be initiated!
		F_ToggleSandbox()
	return
	+^s::
		F_AppStats()									;show application statistics
	return
#If

#If WinActive("ahk_id" MoveLibsHwnd)
	F8::
		F_Move()
	return
#If

#If F_IsItEdit()
	AppsKey::	;blocks default context menu for Edit fields
#If

;section of build-in hotstrings (system wide!)
:*:hshelp/::										;run web browser and enter Hotstrings application help on Github.
	F_GuiAboutLink2()
return

:*:hsquit/::
:*:hsstop/::
:*:hsexit/::										;exit Hotststrings application
	F_Exit()
return

:*:hstoggle/::										;toggle triggerstring tips
:*:hstrig/::										;toggle triggerstring tips
	ini_TTTtEn := !ini_TTTtEn
	MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["Triggerstring tips  are now"] . A_Space . (ini_TTTtEn ? TransA["ENABLED"] : TransA["DISABLED"]) . "."
	if (ini_TTTtEn)
	{
		v_InputString := ""
		Hotstring("Reset")
	}
return

:*:hsenable/::
	F_SuspendTipsAndHotkeys("enable")
return

:*:hsdisable/::
	F_SuspendTipsAndHotkeys("disable")
return

:*:hssuspend/::									;toggle suspend hotstrings and triggerstrings
	F_SuspendTipsAndHotkeys()
return

:*:hsrestart/::									;reload into default mode of operation
:*:hsreload/::										;reload into default mode of operation
	F_ReloadApplication()
return
:*:hsstats/::										;show application statistics
	F_AppStats()
return

~*LShift::
~*RShift::			;Actually "Shifts" work a bit different as some keys like @ or ? are available only after pressing Shift.
	ToolTip,			;this line is necessary to close tooltips.
	Gui, Tt_HWT: Hide	;Tooltip _ Hotstring Was Triggered
	Gui, Tt_ULH: Hide	;Tooltip _ Undid the Last Hotstring
	F_DestroyTriggerstringTips(ini_TTCn)
return

~*F1::		;pressed any function key destroy triggerstring tips
~*F2::
~*F3::
~*F4::
~*F5::
~*F6::
~*F7::
~*F8::
~*F9::
~*F10::
~*F11::
~*F12::
~*F13::
~*F14::
~*F15::
~*F16::
~*F17::
~*F18::
~*F19::
~*F20::
~*F21::
~*F22::
~*F23::
~*F24::
~*LAlt::		;if commented out, only for debugging reasons
~RAlt::		;no * allowed as it is part of AltGr (LControl & RAlt) and AltGr is used for diacritic letters in many keyboard layouts
~*WheelDown::
~*WheelUp::
~*MButton::
~*RButton::
~*LWin::
~*RWin::
~*Down::
~*Up::
~*Left::
~*Right::
~*Insert::
~*Del::
~*Home::
~*End::
~*PgUp::
~*PgDn::
~*WheelLeft::
~*WheelRight::
~*LButton::
	; OutputDebug, % "LButton down:" . "`n"
	ToolTip,	;this line is necessary to close tooltips.
	Gui, Tt_HWT: Hide	;Tooltip _ Hotstring Was Triggered
	Gui, Tt_ULH: Hide	;Tooltip _ Undid the Last Hotstring
	F_DestroyTriggerstringTips(ini_TTCn)
	if (!WinExist("ahk_id" HMenuCliHwnd)) and (!WinExist("ahk_id" HMenuAHKHwnd))
		v_InputString := ""
	; OutputDebug, % "v_InputString after:" . v_InputString . "|" . "`n"
return

 ~*Control::	;whenever any combination with control (e.g. ctrl + v) is applied on time when triggestring is entered AND active triggerstrings are disabled, hotstring recognizer is reset. Without "UP" modifier it is in conflict with other hotkeys
	ToolTip,	;this line is necessary to close tooltips.
	Gui, Tt_HWT: Hide	;Tooltip _ Hotstring Was Triggered
	Gui, Tt_ULH: Hide	;Tooltip _ Undid the Last Hotstring
	F_DestroyTriggerstringTips(ini_TTCn)
	if (!WinExist("ahk_id" HMenuCliHwnd)) and (!WinExist("ahk_id" HMenuAHKHwnd))
	{
		; OutputDebug, % "Hotstring(""reset"")" . "`n"
		Hotstring("Reset")
		v_InputString := ""
	}	
return		

~*Esc::	;the only difference in comparison to previous section is that Esc also resets hotstring recognizer.
	; OutputDebug, % "~Esc:" . "`n"
	ToolTip,	;this line is necessary to close tooltips.
	Gui, Tt_HWT: Hide	;Tooltip _ Hotstring Was Triggered
	Gui, Tt_ULH: Hide	;Tooltip _ Undid the Last Hotstring
	F_DestroyTriggerstringTips(ini_TTCn)
	if (!WinExist("ahk_id" HMenuCliHwnd)) and (!WinExist("ahk_id" HMenuAHKHwnd))
		v_InputString := ""
	Hotstring("Reset")
return

~*LButton UP::	;if user switches between windows by mouse clicking and e.g. "Search Hotstring" window was active
	; OutputDebug, % "LButton UP:" . "`n"
	Suspend, Permit	;Suspend, On is set for "Search Hotstrings" window
	if (WinActive("ahk_id" HS3SearchHwnd))
		{
			; OutputDebug, % "A_ThisHotkey:" . A_ThisHotkey . A_Space . "!WinActive(""ahk_id"" HS3GuiHwnd):" . !WinActive("ahk_id" HS3SearchHwnd) . A_Space . "!WinExist(""ahk_id"" HS3SearchHwnd):" . !WinExist("ahk_id" HS3SearchHwnd) . "`n"
			Suspend, On
			; OutputDebug, % "S On" . "`n"
		}	
		else
		{
			Suspend, Off
			; OutputDebug, % "S Off" . "`n"
		}	
return
	
~*Enter UP::	;if user switches between windows by keyboard (Alt+Tab or Win+Alt) clicking and e.g. "Search Hotstring" window was active
~*Alt UP::	;for hotkeys applicable to switch between operating system windows it is important to add "up" modifier. When windows are switched, switch off suspend for hotkeys and hotstrings.
	Suspend, Permit	;Suspend, On is set for "Search Hotstrings" window
	; OutputDebug, % "A_ThisHotkey:" . A_ThisHotkey . "`n"
	Sleep, 100	;100 ms = default value of SetWinDelay; for some reasons SetWinDelay isn't set for WinActive command. A window sometimes needs a period of "rest" after being activated (description copied from SetWinDelay).
	if (WinActive("ahk_id" HS3SearchHwnd))
	{
		Suspend, On
		; OutputDebug, % "S On" . "`n"
	}	
	else
	{
		Suspend, Off
		; OutputDebug, % "S Off" . "`n"
	}	
return
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#If WinActive("ahk_id" TT_C4_Hwnd)	;Static triggerstring tips (inside separate window). User case scenario: if user decided to switch into static window (makes it active)
	Tab::	
	+Tab::
	1::
	2::
	3::
	4::
	5::
	6::
	7::
	Enter:: 
	Up::
	Down::
		; OutputDebug, % "WinActive(ahk_id TT_C4_Hwnd)" . "`n"
		F_StaticMenu_Keyboard(CheckPreviousWindowID := true)
		return
#If
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#If WinExist("ahk_id" TT_C4_Hwnd)	;Static triggerstring tips (inside separate window)
	~Tab::	;There must be "~" as this code will be run even if IdTT_C4_LB4 is empty
	~+Tab::
	~1::
	~2::
	~3::
	~4::
	~5::
	~6::
	~7::
	~Enter::
	~^Enter:: 	;valid only for Triggerstring Menu
	~Up::
	~^Up::		;valid only for Triggerstring Menu
	~Down::
	~^Down::		;valid only for Triggerstring Menu
		F_StaticMenu_Keyboard()
		return
	~Esc::	;tilde in order to run function TT_C4GuiEscape
		GuiControl,, % IdTT_C4_LB4, % c_MHDelimiter
		;OutputDebug, % "v_InputString:" . A_Tab . v_InputString . A_Tab . "v_EndChar:" . A_Tab . v_EndChar
		v_InputString 			:= ""	
		return
#If
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#If ActiveControlIsOfClass("Edit")	;https://www.autohotkey.com/docs/commands/_If.htm
	^BS::
		Send, ^+{Left}{Del}
		F_DestroyTriggerstringTips(ini_TTCn)
		return
	^Del::
		Send, ^+{Right}{Del}
		F_DestroyTriggerstringTips(ini_TTCn)
		return
#If

; ------------------------- SECTION OF FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------------------
;#c/* commercial only beginning
;#c*/ commercial only end
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;#c/* commercial only beginning
;#c*/ commercial only end
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;#c/* commercial only beginning
;#c*/ commercial only end
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_SupportContact()
{
	global						;assume-global mode of operation

	c_ASCII_NewLine 	:= "`%0A"
,	c_ASCII_HorTab 	:= "`%09"
,	c_ASCII_Space		:= "`%20"
,	c_MailToTechnical	:= "support@hotstrings.technology"

	Run, % "mailto:" . c_MailToTechnical . "?subject=Request for Hotstrings technical support&body="
		. "Logon user name:" 	. c_ASCII_HorTab . A_UserName 	. c_ASCII_NewLine
		. "Computer name:" 		. c_ASCII_HorTab . A_ComputerName 	. c_ASCII_NewLine
		. "First and second name of license owner or company name (please fill in manually):" . c_ASCII_Space .  c_ASCII_NewLine . c_ASCII_NewLine
		. "This e-mail will be processed as soon as possible, within ~1 working day (24 hours). Nevertheless please be patient." . c_ASCII_NewLine . c_ASCII_NewLine
		. "The proud Hotstrings team and Maciej Słojewski", , UseErrorLevel
	if (ErrorLevel = "ERROR")
	{
		MsgBox, % c_MsgBoxIconError, % SubStr(A_ScriptName, 1, -4) . A_Space . "error", % "Something went wrong, e-mail client wasn't found?" . "`n`n"
			. "Please prepare it manually: press Ctrl + C, open your e-mail application and press Ctrl + V." . "`n`n"
			. "To:" . A_Tab . c_MailToTechnical			. "`n"
			. "Logon user name:" . A_Tab . A_UserName 		. "`n"
			. "Computer name:" 	. A_Tab . A_ComputerName 	. "`n"
			. "First and second name of license owner or company name (please fill in manually):" . A_Space . "`n`n"
			. "This e-mail will be processed as soon as possible, within ~1 working day (24 hours). Nevertheless please be patient." . "`n`n"
			. "The proud Hotstrings team and Maciej Słojewski" . "`n"
	}
}
;#c*/ commercial only end
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_SetMinSendLevel()
{
	global	;assume-global mode of operation

	Loop, 4
	{
		if (A_Index - 1 = A_ThisMenuItem)
		{
			Menu, MinSendLevelSubm, Check, 	% A_Index - 1
			ini_MinSendLevel 		:= A_Index - 1
		,	v_InputH.MinSendLevel 	:= ini_MinSendLevel
			IniWrite, % ini_MinSendLevel, % ini_HADConfig, Configuration, MinSendLevel
		}
		else
			Menu, MinSendLevelSubm, UnCheck, 	% A_Index - 1
	}
	OutputDebug, % "ini_MinSendLevel:" . ini_MinSendLevel . "`n"

}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_SetSendLevel()
{
	global	;assume-global mode of operation

	Loop, 4
	{
		if (A_Index - 1 = A_ThisMenuItem)
		{
			Menu, SendLevelSumbmenu, Check, 	% A_Index - 1
			ini_SendLevel := A_Index - 1
			IniWrite, % ini_SendLevel, % ini_HADConfig, Configuration, SendLevel
		}
		else
			Menu, SendLevelSumbmenu, UnCheck, 	% A_Index - 1
	}
	; OutputDebug, % "ini_SendLevel:" . ini_SendLevel . "`n"
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;#c/* commercial only beginning
;#c*/ commercial only end
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;#c/* commercial only beginning
;#c*/ commercial only end
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;#c/* commercial only beginning
;#c*/ commercial only end
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;#c/* commercial only beginning
;#c*/ commercial only end
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;#c/* commercial only beginning
;#c*/ commercial only end
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;#c/* commercial only beginning
;#c*/ commercial only end
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_Empty()	;empty / dummy function. Applicable for debugging purposes or as destination for Menu command.
{	
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_InternalHot()
{
	global	;assume-global mode of operation
	MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["Application hotstrings"] . "." . A_Space . TransA["All of them are ""immediate execute"" (*)"] . "`n"
		. TransA["and active in whole operating system (any window)"] . ":"										. "`n"
		. "`n`n"
		. "hshelp/" . A_Tab . A_Tab . 	TransA["run web browser, enter Hotstrings webpage"]					 	. "`n"
		. "hsstop/" . A_Tab . A_Tab . 	TransA["exit Hotstrings application"]				 					. "`n"
		. "hsquit/" . A_Tab . A_Tab . 	TransA["exit Hotstrings application"]				 					. "`n"
		. "hsexit/" . A_Tab . A_Tab . 	TransA["exit Hotstrings application"]				 					. "`n"
		. "hstoggle/" . A_Tab . 	 		TransA["toggle triggerstrings tips and hotstrings"]						. "`n"
		. "hssuspend/" . A_Tab . 	 	TransA["suspend triggerstrings tips and hotstrings"]						. "`n"
		. "hsdisable/" . A_Tab . 		TransA["disable triggerstring tips and hotstrings"]						. "`n"
		. "hsenable/" . A_Tab . 			TransA["enable triggerstring tips and hotstrings"]						. "`n"
		. "hsrestart/" . A_Tab . 		TransA["reload Hotstrings application"]									. "`n"
		. "hsreload/" . A_Tab .			TransA["reload Hotstrings application"]									. "`n"
		. "hsstats/" . A_Tab . A_Tab . 	TransA["show application statistics"]									. "`n"
		. "`n`n"
		. "Application hotkeys" . ":"																		. "`n"
		. "Ctrl + Win + H" . A_Tab . 		TransA["show main application GUI"]
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_HS3SearchLeft()
{
	global	;assume-global mode of operation
	local	FocusedControl := "", NextRow := 0

	Gui, HS3Search: Default
	GuiControlGet, FocusedControl, HS3Search: Focus
	
	Switch FocusedControl
	{
		Case "Button1":	;Triggerstring
			GuiControl, Focus, % IdSearchE1
		Case "Button2":	;Hotstring
			GuiControl, , % IdSearchR1, 1
			GuiControl, Focus, % IdSearchR1
			F_SearchPhrase()
		Case "Button3":	;Library
			GuiControl, , % IdSearchR2, 1
			GuiControl, Focus, % IdSearchR2
			F_SearchPhrase()
		Case "Edit1":		;Phrase to search for
			ControlSend, Edit1, {left}	;send to a guicontrol cursor pressing
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_HS3SearchRight()
{
	global	;assume-global mode of operation
	local	FocusedControl := "", CaretPos := 0, LineText := ""
	
	Gui, HS3Search: Default
	GuiControlGet, FocusedControl, HS3Search: Focus
	Switch FocusedControl
	{
		Case "Button1":	;Triggerstring
			GuiControl, , % IdSearchR2, 1
			GuiControl, Focus, % IdSearchR2
			F_SearchPhrase()
		Case "Button2":	;Hotstring
			GuiControl, , % IdSearchR3, 1
			GuiControl, Focus, % IdSearchR3
			F_SearchPhrase()
		Case "Button3":	;Library

		Case "Edit1":		;Phrase to search for
			ControlGet, CaretPos, CurrentCol,, Edit1	;get current position of the caret
			ControlGet, LineText, Line, 1, Edit1		;get current text from edit field
			if (StrLen(LineText) >= CaretPos)
				ControlSend, Edit1, {right}	;send to a guicontrol cursor pressing
			else
			{
				GuiControl, , % IdSearchR1, 1
				GuiControl, Focus, % IdSearchR1
				F_SearchPhrase()
			}
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_HS3Search_Up()
{
	global	;assume-global mode of operation
	local	FocusedControl := "", NextRow := 0

	GuiControlGet, FocusedControl, HS3Search: Focus

	if (FocusedControl = "SysListView321")
	{
		Gui, HS3Search: Default
		NextRow := LV_GetNext()

		if (NextRow = 1)
			GuiControl, Focus, % IdSearchE1
		else
			LV_Modify(--NextRow, "Select")
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_HS3Search_Down()
{
	global	;assume-global mode of operation
	local	FocusedControl := "", NextRow := 0

	Gui, HS3Search: Default
	GuiControlGet, FocusedControl, HS3Search: Focus
	Switch FocusedControl
	{
		Case "Edit1", "Button1", "Button2", "Button3":	;Button2 = Hotstring, Button3 = Library
			Gui, HS3Search: Default
			NextRow := LV_GetCount()
			; OutputDebug, % "NextRow case 1:" . NextRow . "|" . "`n"			
			if (NextRow = 0)
				GuiControl, Focus, % IdSearchE1
			else
			{
				GuiControl, Focus, % IdSearchLV1
				LV_Modify(1, "+Select +Focus")
			}
		Case "SysListView321":
			NextRow := LV_GetNext()
			; OutputDebug, % "NextRow case 2:" . NextRow . "|" . "`n"
			LV_Modify(++NextRow, "Select")
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_PathtoClipboard()
{
	global	;assume-global mode of operation

	Clipboard := ""
	Switch A_ThisMenuItem
	{
		Case TransA["Copy Log folder path to Clipboard"]:
			Clipboard := HADLog

		Case TransA["Copy Libraries folder path to Clipboard"]:
			Clipboard := ini_HADL
		
		Case TransA["Copy Config.ini folder path to Clipboard"]:
			Clipboard := SubStr(ini_HADConfig, 1, -10)	;-10 = length of "Config.ini" text string
	}
	ClipWait	; Wait for the clipboard to contain text.
	MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["Required content is copied to the Clipboard"]
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;#c/* commercial only beginning
;#c*/ commercial only end
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
ShowLogGuiSize(GuiHwnd, EventInfo, Width, Height)	;Gui event
{
	global	;assume-global mode of operation

	Switch EventInfo
	{
		Case 1: 		;The window has been minimized.
		Case 2: 		;The window has been maximized.
			F_AutoXYWH("*wh", 	IdSL_Edit1)
			F_AutoXYWH("*x", 	IdSL_Button1)
		Default:		;Any other case, e.g. manual window size manipulation or window is restored
			F_AutoXYWH("*wh", 	IdSL_Edit1)
			F_AutoXYWH("*x", 	IdSL_Button1)
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
ShowLogGuiClose(GuiHwnd)	;Gui event
{
	F_SL_ButtonOK()
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_SL_ButtonOK()
{
	global	;assume-global mode of operation
	local	WhichGui := ""

	WhichGui := F_WhichGui()
	Gui,			% WhichGui . ": -Disabled"
	Gui,			ShowLog: 	+Disabled
	Gui, 		ShowLog: 	Destroy
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_IsItEdit()
{
	global	;assume-global mode of operation
	local 	ControlClass := ""

	F_WhichGui()
	GuiControlGet, ControlClass, Focus
	if (InStr(ControlClass, "Edit"))
		return true
	else
		return false
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_RenameLibrary()
{
	global	;assume-global mode of operation
	local	SelectedLibraryName := ""
	GuiControlGet, SelectedLibraryName, , % IdDDL2	;Select hotstring library (drop down list), retrieves the conntents of the control. v_SelectHotstringLibrary
	if (!SelectedLibraryName) or (SelectedLibraryName = TransA["↓ Click here to select hotstring library ↓"])	;if SelectedLibraryName is empty
	{
		MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["In order to change existing library filename at first select one from drop down list."]
		return
	}
	F_GuiAddLibrary(TransA["Choose new library file name:"])
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_ChangeLibNameOK()
{
	global	;assume-global mode of operation
	local	SelectedLibraryName := "", key := 0

	Gui, ALib: Submit, NoHide
	if (v_NewLib == "")
	{
		MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["Enter a new library name"]
		return
	}
	v_NewLib .= ".csv"
	GuiControlGet, SelectedLibraryName, , % IdDDL2	;Select hotstring library (drop down list), retrieves the conntents of the control.
	FileMove, % ini_HADL . "\" . SelectedLibraryName, % ini_HADL . "\" . v_NewLib
	if (ErrorLevel)
	{
		MsgBox, 48, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["error"], % TransA["Something went wrong on time of file rename. Perhaps file was occupied by any process?"]
		return
	}
	else
	{
		MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["The library"] . "`n`n" . SelectedLibraryName . "`n`n" . TransA["has been renamed to"] . "`n`n" . v_NewLib
		if (WinExist("ahk_id" HS3GuiHwnd))
			Gui, HS3: -Disabled
		if (WinExist("ahk_id" HS4GuiHwnd))
			Gui, HS4: -Disabled
		Gui, ALib: Destroy
		F_ValidateIniLibSections()
		F_RefreshListOfLibraries()	; this function calls F_RefreshListOfLibraryTips() as both options are interrelated
		F_UpdateSelHotLibDDL()
		for key in a_Library
			if (a_Library[key] = SubStr(SelectedLibraryName, 1, -4))
				a_Library[key] := SubStr(v_NewLib, 1, -4)
	}	
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EditLibHeader()
{
	global	;assume-global mode of operation
	local	SelectedLibraryName := "", TheWholeFile := "", LibraryHeader := "", Xpos := 0, Ypos := 0, Wwidth := 0, Height := 0
	,		WidthOfClient := 0, MaxPrimaryMon := 0
	, 		SM_CXFULLSCREEN 	:= 16 ;Width of the client area for a full-screen window on the primary display monitor, in pixels.
	,		SM_CXMAXIMIZED 	:= 61 ;Default dimensions, in pixels, of a maximized top-level window on the primary display monitor.
	,		ControlPos1		:= 0, ControlPos1X := 0, ControlPos1Y := 0, ControlPos1W := 0, ControlPos1H := 0
	,		ControlPos2		:= 0, ControlPos2X := 0, ControlPos2Y := 0, ControlPos2W := 0, ControlPos2H := 0
	,		MaxButtonWidth		:= 0

	GuiControlGet, SelectedLibraryName, , % IdDDL2	;Select hotstring library (drop down list), retrieves the conntents of the control.
	if (!SelectedLibraryName) or (SelectedLibraryName = TransA["↓ Click here to select hotstring library ↓"])	;if SelectedLibraryName is empty
	{
		MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["In order to edit library header please at first select library name from drop down list."]
		return
	}
	if (InStr(SelectedLibraryName, "DISABLED", true))
	{
		MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["Editing of library header is possible only if library is enabled (not DISABLED)."]
		return
	}

	FileRead, TheWholeFile, % ini_HADL . "\" . SelectedLibraryName
	LibraryHeader := F_ExtractHeader(TheWholeFile)

	SysGet, WidthOfClient, % SM_CXFULLSCREEN	;Width of the client area for a full-screen window on the primary display monitor, in pixels.
	SysGet, MaxPrimaryMon, % SM_CXMAXIMIZED		;Default dimensions, in pixels, of a maximized top-level window on the primary display monitor.
	WinGetPos, Xpos, Ypos, Wwidth, , A
	Gui, 	LibHeader: New, 	+Resize +HwndLibHeaderGuiHwnd +Owner -DPIScale, % A_ScriptName . ":" . A_Space . TransA["Edit library header"] . "." . A_Space . TransA["Library name:"] A_Space . SelectedLibraryName ;DPI scaling only applies to Gui sub-commands and related variables, so coordinates coming directly from other sources such WinGetPos will not work. There are a number of ways to deal with this, e.g. disable (Gui -DPIScale) scaling on the fly, as needed.
	Gui,		LibHeader: Margin, 	% c_xmarg, % c_ymarg
	Gui,		LibHeader: Add,	Button,	x0 y0 HwndIdLHB_Button1 gLHB_Button_Save, 	% TransA["Save && Close"]	;double ampersand in order to display literal ampersand
	Gui,		LibHeader: Add,	Button,	x0 y0 HwndIdLHB_Button2 gLHB_Button_Cancel, 	% TransA["Cancel"]
	GuiControlGet, ControlPos1, Pos, % IdLHB_Button1
	GuiControlGet, ControlPos2, Pos, % IdLHB_Button2
	MaxButtonWidth := Max(ControlPos1W, ControlPos2W)
,	EditWidth 	:= Wwidth - (MaxPrimaryMon - WidthOfClient) - 3 * c_xmarg - MaxButtonWidth
	Gui,		LibHeader: Add,	Edit,  	% "x" . c_xmarg . A_Space . "y" . c_ymarg . A_Space . "HwndIdLHG_Edit1 r10" . A_Space . "w" . EditWidth
	GuiControlGet, ControlPos1, Pos, % IdLHG_Edit1
	GuiControl, Move, % IdLHB_Button1, % "x" . ControlPos1X + ControlPos1W + c_xmarg . A_Space . "y" . ControlPos1Y
	GuiControlGet, ControlPos2, Pos, % IdLHB_Button1
	GuiControl, Move, % IdLHB_Button2, % "x" . ControlPos1X + ControlPos1W + c_xmarg . A_Space . "y" . ControlPos2Y + ControlPos2H + c_ymarg
	GuiControl, , % IdLHG_Edit1, % LibraryHeader
	Gui, HS3: +Disabled	;To prevent the user from interacting with the owner while one of its owned window is visible, disable the owner via Gui +Disabled.
	Gui, 	LibHeader: Show, % "x" . Xpos . A_Space . "y" . Ypos . A_Space . "w" . Wwidth - (MaxPrimaryMon - WidthOfClient)
	GuiControl, Focus, % IdLHG_Edit1
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
LibHeaderGuiEscape()
{
	global	;assume-global mode of operation
	local	LibraryHeader := ""

	GuiControlGet, LibraryHeader,, % IdLHG_Edit1
	if (LibraryHeader)
	{
		MsgBox, 68, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % "You've pressed Esc key which cancels header edition. However edit field isn't empty. Would you like to save it?"
		IfMsgBox, Yes
			LHB_Button_Save()
		IfMsgBox, No
		{
			Gui, HS3: 		-Disabled
			Gui, LibHeader: 	Destroy
		}
	}
	else
	{
		Gui, HS3: 		-Disabled
		Gui, LibHeader: 	Destroy
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
LHB_Button_Save()
{
	global	;assume-global mode of operation
	local	SelectedLibraryName := "", TheWholeFile := "", LibraryHeader := "", LibFileBody := "", BegCom := false

	GuiControlGet, SelectedLibraryName, , % IdDDL2	;Select hotstring library (drop down list), retrieves the conntents of the control.
	if (!SelectedLibraryName) or (SelectedLibraryName = TransA["↓ Click here to select hotstring library ↓"])	;if SelectedLibraryName is empty
	{
		MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["In order to edit library header please at first select library name from drop down list."]
		return
	}
	GuiControlGet, LibraryHeader,, % IdLHG_Edit1

	FileRead, TheWholeFile, % ini_HADL . "\" . SelectedLibraryName
	Loop, Parse, TheWholeFile, `n, `r%A_Space%%A_Tab%
	{
		if (SubStr(A_LoopField, 1, 2) = "/*")	;ignore comments
		{
			BegCom := true
			Continue
		}
		if (BegCom) and (SubStr(A_LoopField, -1) = "*/") ;ignore comments
		{
			BegCom := false
			Continue
		}
		if (BegCom)
			Continue
		if (SubStr(A_LoopField, 1, 1) = ";")	;ignore comments
			Continue
		if (!A_LoopField)	;ignore empty lines
			Continue
		
          LibFileBody .= A_LoopField . "`n"
	}
	TheWholeFile := "/*" . "`n" . LibraryHeader . "`n" . "*/" . "`n" . LibFileBody
	FileDelete, % ini_HADL . "\" . SelectedLibraryName
	FileAppend, % TheWholeFile, % ini_HADL . "\" . SelectedLibraryName, UTF-8
	LHB_Button_Cancel()
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
LHB_Button_Cancel()
{
	Gui, HS3: 		-Disabled
	Gui,	LibHeader: 	Destroy
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_ShowLibHeader()	;button: Show header
{
	global	;assume-global mode of operation
	local	SelectedLibraryName := "", TheWholeFile := "", LibraryHeader := ""

	GuiControlGet, SelectedLibraryName, , % IdDDL2	;Select hotstring library (drop down list), retrieves the conntents of the control.
	if (!SelectedLibraryName) or (SelectedLibraryName = TransA["↓ Click here to select hotstring library ↓"])	;if SelectedLibraryName is empty
	{
		MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["In order to display library header please at first select library name from drop down list."]
		return
	}
	if (InStr(SelectedLibraryName, "DISABLED", true))
		SelectedLibraryName := StrReplace(SelectedLibraryName, "DISABLED", "")
	FileRead, TheWholeFile, % ini_HADL . "\" . SelectedLibraryName
	LibraryHeader := F_ExtractHeader(TheWholeFile)
	if (LibraryHeader)
		MsgBox,64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["Header of library"] . A_Space . SelectedLibraryName . ":" . "`n`n"  LibraryHeader
	else
		MsgBox,64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["Header of library"] . A_Space . SelectedLibraryName . A_Space . TransA["is empty at the moment."]
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_ExtractHeader(TheWholeFile)
{
	local LibraryHeader := "", BegCom := false
	Loop, Parse, TheWholeFile, `n, `r%A_Space%%A_Tab%
	{
		if (SubStr(A_LoopField, 1, 1) = ";")	;catch the comments
		{
			if (LibraryHeader)
				LibraryHeader .= "`n" . SubStr(A_LoopField, 2)
			else
				LibraryHeader .=  SubStr(A_LoopField, 2)
			Continue
		}
		if (SubStr(A_LoopField, 1, 2) = "/*")	;catch beginning of the first comment in the file = beginning of header
		{
			BegCom := true
			LibraryHeader .= SubStr(A_LoopField, 3)
			Continue
		}
		if (BegCom) and (SubStr(A_LoopField, -1) = "*/") ;catch the end of the last comment in the file = end of of header
		{
			BegCom := false
			if (SubStr(A_LoopField, 1, -2))
				LibraryHeader .= SubStr(A_LoopField, 1, -2)
			else
				LibraryHeader := SubStr(LibraryHeader, 1, -1)
			Continue
		}
		if (BegCom)
		{
			LibraryHeader .= A_LoopField . "`n"
			Continue
		}
		if (!A_LoopField)	;ignore empty lines
			Continue
		if (!BegCom) and (!(SubStr(A_LoopField, 1, 1) = ";"))
			Break
	}
	return LibraryHeader
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_DelLibByButton()
{
	global	;assume-global mode of operation

	Gui, % F_WhichGui() . ":" . A_Space . "Submit", NoHide
	if (!v_SelectHotstringLibrary) or (v_SelectHotstringLibrary = TransA["↓ Click here to select hotstring library ↓"])
	{
		MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["At first select library name which you intend to delete."]
		return
	}
	MsgBox, % 32+4, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["question"], % TransA["The selected library file will be permanently deleted."] . "`n"
		. TransA["Are you sure?"] . "`n`n"
		. v_SelectHotstringLibrary
	IfMsgBox, Yes
	{
		Critical, On
		F_GuiHS3_EnDis("Disable")	;EnDis = "Disable" or "Enable"
		F_UnloadHotstringsFromFile(v_SelectHotstringLibrary)
		FileDelete, % ini_HADL . "\" . v_SelectHotstringLibrary
		if (ErrorLevel)
			MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["Something went wrong on time of file removal."			]
		F_ValidateIniLibSections()
		F_RefreshListOfLibraries()	; this function calls F_RefreshListOfLibraryTips() as both options are interrelated
		F_UpdateSelHotLibDDL()	
		a_Combined := []				;in order to refresh arrays of triggerstring tips
		F_LoadHotstringsFromLibraries()	;in order to refresh arrays of triggerstring tips
		F_LoadTTperLibrary()
		F_Sort_a_Triggers(a_Combined, ini_TipsSortAlphabetically, ini_TipsSortByLength)	;in order to refresh arrays of triggerstring tips
		LV_Delete()
		F_GuiHS3_EnDis("Enable")	;EnDis = "Disable" or "Enable"
		MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["The library has been deleted, its content have been removed from memory."] . "`n`n"
			. v_SelectHotstringLibrary
		Critical, Off
		return
	}
	IfMsgBox, No
		return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_AppStats()
{
	global	;assume-global mode of operation
	local	TimeNow := A_Now, HowManyHours := TimeNow, HowManyMinutes := TimeNow
	EnvSub, HowManyHours, 	% AppStartTime, Hours
	EnvSub, HowManyMinutes, 	% AppStartTime, Minutes
	MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["Application statistics"] . ":" . "`n`n"
		. TransA["Start-up time"] . A_Tab . A_Tab . A_Tab . SubStr(AppStartTime, 1, 4) . "-" . SubStr(AppStartTime, 5, 2) . "-" . SubStr(AppStartTime, 7, 2) . A_Space . SubStr(AppStartTime, 9, 2) . ":" . SubStr(AppStartTime, 11, 2) . "`n"
		. TransA["Current time"]  . A_Tab . A_Tab . A_Tab . SubStr(TimeNow, 1, 4) . "-" . SubStr(TimeNow, 5, 2) . "-" . SubStr(TimeNow, 7, 2) . A_Space . SubStr(TimeNow, 9, 2) . ":" . SubStr(TimeNow, 11, 2) . "`n"
		. TransA["Application has been running since"] . A_Tab . HowManyHours . A_Space . "[h]" . A_Space . TransA["or"] . A_Space . HowManyMinutes . A_Space . "[min.]"
		. "`n`n"
		. TransA["Number of loaded d(t, o, h)"] . A_Tab . A_Tab . v_TotalHotstringCnt . "`n"
		. TransA["Number of fired hotstrings"]  . A_Tab . A_Tab . v_LogCounter . "`n" 
		. TransA["Cumulative gain [characters]"] . A_Tab . v_CntCumGain . "`n"
;#f/* free version only beginning
		. TransA["Logging of d(t, o, h)"] . A_Tab . A_Tab . TransA["no"]
;#f*/ free version only end
;#c/* commercial only beginning
;#c*/ commercial only end		
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_ToggleTt()
{
	global	;assume-global mode of operation
	ini_TTTtEn := !ini_TTTtEn
	IniWrite, % ini_TTTtEn, 	% ini_HADConfig, Event_TriggerstringTips, 	TTTtEn
	F_UpdateStateOfLockKeys(ini_HK_ToggleTt, ini_TTTtEn)	
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_Tt_ULH()
{
	global	;assume-global mode of operation
	local	TempText := TransA["Undid the last hotstring"]
		,	OutputVarTemp := 0, OutputVarTempX := 0, OutputVarTempY := 0, OutputVarTempW := 0, OutputVarTempH := 0

	Gui, Tt_ULH: New, -Caption +ToolWindow HwndTt_ULHHwnd	+AlwaysOnTop ;Tt_ULH = Tooltip_Undid the Last Hotstring
	Gui, Tt_ULH: Margin, 0, 0
	Gui, Tt_ULH: Color,, % ini_UHBgrCol
	Gui, Tt_ULH: Font, % "s" . ini_UHTySize . A_Space . "c" . ini_UHTyFaceCol, % ini_UHTyFaceFont
	Gui, Tt_ULH: Add, Text, 		HwndIdTt_ULH_T1, % TempText
	GuiControlGet, OutputVarTemp, Pos, % IdTt_ULH_T1
	GuiControl, Hide, % IdTt_ULH_T1
	Gui, Tt_ULH: Add, Listbox, 	% "HwndIdTt_ULH_LB1" . A_Space . "r1" . A_Space . "x" . OutputVarTempX . A_Space . "y" . OutputVarTempX . A_Space . "w" . OutputVarTempW + 4, % TempText
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_Tt_HWT()	;Tt_HWT = Tooltip_Hostring Was Triggered
{
	global	;assume-global mode of operation
	local	TempText := TransA["Hotstring was triggered!"] . A_Space . "[" . F_ParseHotkey(ini_HK_UndoLH) . "]" . A_Space . TransA["to undo."]
,			OutputVarTemp := 0, OutputVarTempX := 0, OutputVarTempY := 0, OutputVarTempW := 0, OutputVarTempH := 0

	Gui, Tt_HWT: New, -Caption +ToolWindow HwndTt_HWTHwnd	+AlwaysOnTop ;Tt_HWT = Tooltip_Hostring Was Triggered
	Gui, Tt_HWT: Margin, 0, 0
	Gui, Tt_HWT: Color,, % ini_HTBgrCol
	Gui, Tt_HWT: Font, % "s" . ini_HTTySize . A_Space . "c" . ini_HTTyFaceCol, % ini_HTTyFaceFont
	Gui, Tt_HWT: Add, Text, 		HwndIdTt_HWT_T1, % TempText
	GuiControlGet, OutputVarTemp, Pos, % IdTt_HWT_T1
	GuiControl, Hide, % IdTt_HWT_T1
	Gui, Tt_HWT: Add, Listbox, 	% "HwndIdTt_HWT_LB1" . A_Space . "r1" . A_Space . "x" . OutputVarTempX . A_Space . "y" . OutputVarTempX . A_Space . "w" . OutputVarTempW + 4, % TempText
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_StaticMenu_Keyboard(IsPreviousWindowIDvital*)	;future: get rid of ControlGet, ControlSend, determine number of items in ListBox: https://www.autohotkey.com/boards/viewtopic.php?t=43057
{
;#c/* commercial only beginning
;#c*/ commercial only end
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_HMenu_Keyboard(SendFun)
{
	global	;assume-global mode of operation
	local	Temp1 := ""
		, 	ShiftTabIsFound := false
		,	ReplacementString := ""
		, 	temp := 0
		,	WhichControl := ""
		,	PressedKey := A_ThisHotkey
	static 	IfUpF := false
		,	IfDownF := false
		,	IsCursorPressed := false
		,	IntCnt := 1
	
	; OutputDebug, % A_ThisFunc . A_Space . "B" . "`n"
	if (InStr(PressedKey, "Up") or InStr(PressedKey, "+Tab"))	;the same as "up"
	{
		IsCursorPressed := true
,		IntCnt--
		ControlSend, , {Up}, % "ahk_id" . A_Space . HMenuAHKHwnd
		ShiftTabIsFound := true
	}
	if (InStr(PressedKey, "Down") or InStr(PressedKey, "Tab")) and (!ShiftTabIsFound)	;the same as "down"
	{
		IsCursorPressed := true
,		IntCnt++
		ControlSend, , {Down}, % "ahk_id" . A_Space . HMenuAHKHwnd
		ShiftTabIsFound := false
	}
	if ((v_MenuMax = 1) and IsCursorPressed)
	{
		IntCnt := 1
		return
	}
	if (IsCursorPressed)
	{
		if (IntCnt > v_MenuMax)
		{
			IntCnt := v_MenuMax
			if (ini_MHSEn)
				SoundBeep, % ini_MHSF, % ini_MHSD	
		}
		if (IntCnt < 1)
		{
			IntCnt := 1
			if (ini_MHSEn)
				SoundBeep, % ini_MHSF, % ini_MHSD	
		}
		IsCursorPressed := false
		return
	}		
	if (InStr(PressedKey, "Enter"))
	{
		PressedKey 		:= IntCnt
,		IsCursorPressed 	:= false
,		IntCnt 			:= 1
		Process, Exist, Hotstrings2.exe	;This is very dirty trick. As <Enter> is pressed physically for the second instance of Hotstrings application and last character is send back by ShiftFunctions, the second instance of Hotstrings (Hotstrings2) and its library S2_CapitalLetters will detect it as (`n . letter) and trigger corresponding hotkey what in turn will alter last letter into capital letter. So in case there is running second instance of Hotstrings application (Hotstrings2.exe) the {BS} is send back. name is not case sensitive; it must be executable
		if (ErrorLevel)	;name of the process is returned in ErrorLevel variable if it is different than 0
		{
			SendLevel, % ini_SendLevel	;send it back to Hotstrings2.exe
			Send, {BS}
			SendLevel, 0
		}	
	}
	if (PressedKey > v_MenuMax)
	{
		if (ini_MHSEn)
			SoundBeep, % ini_MHSF, % ini_MHSD	
		return false ;if function returns false, characters still be invisible
	}
	ControlGet, Temp1, List, , , % "ahk_id" . A_Space . HMenuAHKHwnd
	Loop, Parse, Temp1, `n
	{
		if (A_Index = PressedKey)
		{
			Temp1 := SubStr(A_LoopField, 4)
			break
		}
	}
	; OutputDebug, % "Temp1:" . Temp1 . "`n"
	v_UndoHotstring 	:= Temp1
	Temp1 			:= F_ReplaceAHKconstants(Temp1)
,	Temp1 			:= F_FollowCaseConformity(Temp1, v_InputString, v_Options)
,	Temp1 			:= F_ConvertEscapeSequences(Temp1)
	if (ini_TTCn = 4)
		WinActivate, % "ahk_id" PreviousWindowID
	Gui, HMenuAHK: Destroy
	v_InputH.VisibleText 	:= true
	Switch SendFun
	{
		Case "MSI":
			F_SendIsOflag(Temp1, Ovar, "SI")
		Case "MCL":
			F_ClipboardPaste(Temp1, Ovar, v_EndChar)
	}
	if (ini_MHSEn)
		SoundBeep, % ini_MHSF, % ini_MHSD
	if (InStr(v_Options, "z", false))	;fundamental change, now "z" parameter metters
		Hotstring("Reset")
	v_InputString := ""
,	temp := F_DetermineGain2(v_InputString, Temp1)
	v_CntCumGain += temp
;#c/* commercial only beginning
;#c*/ commercial only end		
	return true	; v_InputString will be cleared only if function returns true if function returns false, characters still will be invisible
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_TTMenu_Mouse()	;the priority of g F_TTMenuStatic_MouseMouse is lower than this "interrupt"
{
	global	;assume-global mode of operation
	local	OutputVar := 0, OutputVarWin := 0, OutputVarControl := "", OutputVarTemp := ""
	; OutputDebug, % "LButton:" . A_Tab . "v_InputString:" . A_Tab . v_InputString . "`n"
	if (!ini_ATEn)
		return
	if (WinExist("ahk_id" TT_C1_Hwnd) or WinExist("ahk_id" TT_C2_Hwnd) or WinExist("ahk_id" TT_C3_Hwnd))
	{
		MouseGetPos, , , OutputVarWin, OutputVarControl
		Switch ini_TTCn
		{
			Case 1: WinGet, OutputVar, ID, % "ahk_id" TT_C1_Hwnd 
			Case 2: WinGet, OutputVar, ID, % "ahk_id" TT_C2_Hwnd
			Case 3: WinGet, OutputVar, ID, % "ahk_id" TT_C3_Hwnd
		}
		
		if (OutputVarWin != OutputVar)
			Switch ini_TTCn
			{
				Case 1: Gui, TT_C1: Destroy
				Case 2: Gui, TT_C2: Destroy
				Case 3: Gui, TT_C3: Destroy
			}
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
ActiveControlIsOfClass(Class)	;https://www.autohotkey.com/docs/commands/_If.htm
{
	local	
    	ControlGetFocus, FocusedControl, A
    	ControlGet, FocusedControlHwnd, Hwnd,, %FocusedControl%, A
    	WinGetClass, FocusedControlClass, ahk_id %FocusedControlHwnd%
    	return (FocusedControlClass=Class)
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_ConvertEscapeSequences2(string)	;This function is called whenever feed back (SendLevel) is applied and then triggerstring is send by SendInput and cannot therefore contain any escape characters.
{
	if (InStr(string, "{"))
		string := StrReplace(string, "{", "{{}}")
	if (InStr(string, "}"))
		string := StrReplace(string, "}", "{}}")
	if (InStr(string, "^"))
		string := StrReplace(string, "^", "{^}")
	if (InStr(string, "!"))
		string := StrReplace(string, "!", "{!}")
	if (InStr(string, "+"))
		string := StrReplace(string, "+", "{+}")
	if (InStr(string, "#"))
		string := StrReplace(string, "#", "{#}")
	return string
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_ConvertEscapeSequences(string)	;now from file are read sequences like "`" . "t" which are 2x characters. now we have to convert this pair into single character "`t" = single Tab character. 
{	;theese lines are necessary to handle rear definitions of hotstrings such as those finished with `n, `r etc. https://www.autohotkey.com/docs/misc/EscapeChar.htm
	StringCaseSense, On	;necessary as without it ``A is converted to `a and `a is "Go to" or "/BEL".
	string := StrReplace(string, "``n", "`n") 
,	string := StrReplace(string, "``r", "`r")
,	string := StrReplace(string, "``b", "`b")
,	string := StrReplace(string, "``t", "`t")
,	string := StrReplace(string, "``v", "`v")
,	string := StrReplace(string, "``a", "`a")
,	string := StrReplace(string, "``f", "`f")
,	string := RegExReplace(string, "[[:blank:]].*\K`$", "")	;hottring finished with back-tick (`) prededing by blanks 
,	string := StrReplace(string, "``", "``")				;it seems to be exception
	StringCaseSense, Off
	return string
}	;future: https://www.autohotkey.com/boards/viewtopic.php?f=76&t=91953
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_DeleteLibrary()
{
	global	;assume-global mode of operation
	local	SelectedLibraryName := "", SelectedLibraryFile := "", temp := 0

	GuiControlGet, SelectedLibraryName, , % IdDDL2	;Select hotstring library (drop down list), retrieves the conntents of the control. v_SelectHotstringLibrary
	if (!SelectedLibraryName) or (SelectedLibraryName = TransA["↓ Click here to select hotstring library ↓"])	;if SelectedLibraryName is empty
	{
		MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["In order to Delete selected library filename at first select one from drop down list."]
		return
	}
	F_UnloadHotstringsFromFile(SelectedLibraryName)
	FileDelete, % ini_HADL . "\" . SelectedLibraryName
	if (ErrorLevel)
		MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["Something went wrong on time of file removal."	]
	F_ValidateIniLibSections()
	F_RefreshListOfLibraries()		; this function calls F_RefreshListOfLibraryTips() as both options are interrelated
	F_UpdateSelHotLibDDL()
	a_Combined := []				;in order to refresh arrays of triggerstring tips
	F_LoadHotstringsFromLibraries()	;in order to refresh arrays of triggerstring tips
	F_LoadTTperLibrary()
	F_Sort_a_Triggers(a_Combined, ini_TipsSortAlphabetically, ini_TipsSortByLength)	;in order to refresh arrays of triggerstring tips
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_CheckIfMoveToProgramFiles()
{
	global	;assume-global mode of operation
	local	IsProgramFiles := "", Destination := "C:\Program Files\Hotstrings"

	IniRead, IsProgramFiles, % ini_HADConfig, Configuration, OldScriptDir, % A_Space
	if (A_IsAdmin) and (IsProgramFiles = Destination)
	{
		IniWrite, % A_Space, % ini_HADConfig, Configuration, OldScriptDir
		; OutputDebug, % "A_ScriptDir:" . A_Space . A_ScriptDir . "Destination:" . A_Space . Destination
		FileMoveDir, % A_ScriptDir, % Destination, 2		;2 = overwrite
		if (!ErrorLevel)
		{
			MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["The ""Hotstrings"" folder was successfully moved to the new location."]
				. "`n`n" . TransA["Now application must be restarted (into default mode) in order to exit administrator mode."]
			F_ReloadApplication("Run from new location", Destination)						;reload into default mode of operation
		}
		else
		{
			MsgBox, 48, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["error"], % TransA["Something went wrong with moving of ""Libraries"" folder. This operation is aborted."]
			return
		}
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_CheckIfRemoveOldDir()
{	;The problem is this function generates error if run "too quickly". I've tried a trick with Process and WaitClose, but it seems it's not enough to wait for old scrpt to finish.
	global	;assume-global mode of operation
	local	OldAppFolder := "", OldScriptPID := 0

	IniRead, OldAppFolder, 	% ini_HADConfig, Configuration, OldScriptDir, % A_Space
	; OutputDebug, % "OldAppFolder:" . A_Tab . OldAppFolder . "`n"
	if (OldAppFolder != "")
	{
		FileRemoveDir, % OldAppFolder, 1	;Remove all files and subdirectories
		if (ErrorLevel)
		{
			MsgBox, 48, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["error"], % TransA["Something went wrong with removal of old ""Hotstrings"" folder."]
				. A_Space . TransA["Perhaps check if any other application (like File Manager) do not occupy folder to be removed."]
				. "`n" . TransA["This operation is aborted."]
			return
		}
		else
		{
			IniWrite, % A_Space, % ini_HADConfig, Configuration, OldScriptDir
			MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["The old ""Hotstrings"" folder was successfully removed."]
				. "`n`n" . OldAppFolder
		}
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;#c/* commercial only beginning
;#c*/ commercial only end
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;#c/* commercial only beginning
;#c*/ commercial only end
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;#c/* commercial only beginning
;#c*/ commercial only end
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_Load_ini_HADL()	;HADL = Hotstrings Application Data Library
{
	global	;assume-global mode
	local	LibLocation_ScriptDir := false, LibLocation_AppData := false, IsLibraryFolderEmpty1 := true, IsLibraryFolderEmpty2 := true, LibCounter1 := 0, LibCounter2 := 0

	IniRead, ini_HADL, % ini_HADConfig, Configuration, HADL, % A_Space	;Inexplicite declaration of global variable  ini_HADL. Default parameter. The value to store in OutputVar (ini_HADL) if the requested key is not found. If omitted, it defaults to the word ERROR. To store a blank value (empty string), specify %A_Space%.
	if (ini_HADL = "")	;thanks to this trick existing Config.ini do not have to be erased if new configuration parameters are added.
	{	;folder Libraries can be present only in 2 locations: by default in A_AppData or in A_ScriptDir
		ini_HADL := c_AppDataLocal . "\" . SubStr(A_ScriptName, 1, -4) . "\" . "Libraries" 	; Hotstrings Application Data Libraries	default location ;global variable
		IniWrite, % ini_HADL, % ini_HADConfig, Configuration, HADL
		return
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;#c/* commercial only beginning
;#c*/ commercial only end
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
GuiEventsGuiClose()	;GUI event (close)
{
	global	;assume-global mode of operation
	if (WinExist("ahk_id" HS3GuiHwnd))
		Gui, HS3: -Disabled
	if (WinExist("ahk_id" HS4GuiHwnd))
		Gui, HS4: -Disabled	
	Gui, TTDemo: 		Destroy
	Gui, GuiEvents: 	Destroy
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
GuiEventsGuiEscape()	;GUI event (close)	;this function is somehow blocked (dead code)
{
	global	;assume-global mode of operation
	if (WinExist("ahk_id" HS3GuiHwnd))
		Gui, HS3: -Disabled	
	if (WinExist("ahk_id" HS4GuiHwnd))
		Gui, HS4: -Disabled	
	Gui, TTDemo: 		Destroy
	Gui, GuiEvents: 	Destroy
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_WhereDisplayMenu(ini_TTTP)
{
	local MenuX := 0, MenuY := 0, MouseX := 0, MouseY := 0

	Switch ini_TTTP
	{
		Case 1:	;caret The problem is that some windows, even those containing text editors, do not enable A_CaretX and A_CaretY. Then, as backup scenario, the triggerstring menu is dispplayed at cursor.
			if (A_CaretX and A_CaretY)
				{
					MenuX := A_CaretX + 20
					MenuY := A_CaretY - 20
				}
				else
				{
					MouseGetPos, MouseX, MouseY
					MenuX := MouseX + 20
					MenuY := MouseY - 20
				}

		Case 2:	;cursor
			MouseGetPos, MouseX, MouseY
			MenuX := MouseX + 20
			MenuY := MouseY - 20
	}
	; OutputDebug, % "ini_TTTP:" . A_Tab . ini_TTTP . A_Tab . "A_CaretX:" . A_Tab . A_CaretX . A_Tab . "A_CaretY:" . A_Tab . A_CaretY . A_Tab . "MenuX:" . A_Tab . MenuX . A_Tab . "MenuY" . A_Tab . MenuY . "`n"
	return [MenuX, MenuY]
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_TrigTipsSecondColumn(a_array1, a_array2)
{
	global	;assume-global mode of operation
	local key := 0, value := "", ThisValue := "", AmountOfItems := a_array1.Count()

	for key, value in a_array1
	{
		; OutputDebug, % "value:" . value . "|" . "key:" . key . "|" . "a_array2[key]:" . a_array2[key] . "`n"
		if (a_array2[key] = "En") and (InStr(value, "*")) and (InStr(value, "?"))
		{
			if (key != AmountOfItems)
				ThisValue .= "?" . c_TextDelimiter
			else
				ThisValue .= "?"
			; OutputDebug, % "First c" . "`n"
			Continue	;Skips the rest of a loop statement's current iteration and begins a new one.
		}	
		if (a_array2[key] = "En") and (InStr(value, "*"))
		{
			if (key != AmountOfItems)
				ThisValue .= "✓" . c_TextDelimiter
			else
				ThisValue .= "✓"
			; OutputDebug, % "Second c" . "`n"
			Continue	;Skips the rest of a loop statement's current iteration and begins a new one.
		}	
		if (a_array2[key] = "En") and (InStr(value, "?"))
		{
			if (key != AmountOfItems)
				ThisValue .= "?" . c_TextDelimiter
			else
				ThisValue .= "?"
			; OutputDebug, % "First ?" . "`n"
			Continue
		}	
		if (a_array2[key] = "En") and (!InStr(value, "*"))
		{
			if (key != AmountOfItems)
				ThisValue .= "↓" . c_TextDelimiter
			else
				ThisValue .= "↓"
			; OutputDebug, % "First ↓" . "`n"
		}	
		if (a_array2[key] = "Dis")
		{
			if (key != AmountOfItems)
				ThisValue .= "╳" . c_TextDelimiter
			else
				ThisValue .= "╳"
		}	
	}
	return ThisValue
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_ConvertArrayToString(a_array)
{
	global	;global-mode of operation
	local	key := 0, value := "", ThisValue := "", AmountOfItems := a_array.Count()

	for key, value in a_array
	{
		if (key != AmountOfItems)
			ThisValue .= value . c_TextDelimiter
		else
			ThisValue .= value
	}
	; OutputDebug, % "ThisValue:" . ThisValue . "`n"
	return ThisValue
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_LongestTrigTipString(a_array)	
{
	local	
	key := 0, value := "", ThisValue := "", MaxValue := 0, WhichKey := 0, WhichValue := ""

	for key, value in a_array
	{
		ThisValue := StrLen(value)
		if (ThisValue > MaxValue)
		{
			MaxValue 		:= ThisValue
,			WhichKey		:= key
,			WhichValue 	:= value
		}
	}
	return WhichValue
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_FlipMenu(WindowHandle, MenuX, MenuY, GuiName)
{
	local 	Window1X := 0, Window1Y := 0, Window1W := 0, Window1H := 0
		,	Window2X := 0, Window2Y := 0, Window2W := 0, Window2H := 0
		,	NewX := 0,	NewY := 0,	NewW := 0,	NewH := 0
	;1. determine size of window on top of which triggerstring tips GUI will be displayed
	WinGetPos, Window1X, Window1Y, Window1W, Window1H, A		
	;2. determine position and size of triggerstring window
	Gui, % GuiName . ": Show", Hide x%MenuX% y%MenuY%
	DetectHiddenWindows, On
	WinGetPos, Window2X, Window2Y, Window2W, Window2H, % "ahk_id" . A_Space . WindowHandle
	NewX := Window2X, NewY := Window2Y - Window2H, NewW := Window2W, NewH := Window2H	;bottom -> top
	if (NewX = "") or (NewY = "")
		{
			; OutputDebug, % "A_ThisFunc:" . A_Space . A_ThisFunc . A_Tab . "return" . "`n"
			return
		}
	Gui, % GuiName . ": Show", Hide x%NewX%  y%NewY%	;coordinates: screen
	WinGetPos, Window2X, Window2Y, Window2W, Window2H, % "ahk_id" . A_Space . WindowHandle
	;3. determine if triggerstring tips menu fits to this window
	if (Window2Y < Window1Y)	;if triggerstring tips are above the window
	{
		NewY += Window2H + 40	;top -> bottom
		Gui, % GuiName . ": Show", Hide x%NewX% y%NewY% 	;coordinates: screen
		WinGetPos, Window2X, Window2Y, Window2W, Window2H, % "ahk_id" . A_Space . WindowHandle
	}
	if (Window2X + Window2W > Window1X + Window1W)	;if triggerstring tips are too far to the right
		NewX -= Window2W + 40	;right -> left
	DetectHiddenWindows, Off
	Gui, % GuiName . ": Show", x%NewX% y%NewY% NoActivate
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_CheckBeforeLastChar(InputString) ;check if before last character is EndChar
{
	local TwoLastChar := "", BeforeLast := ""
	TwoLastChar := SubStr(InputString, -1)
,	BeforeLast := SubStr(TwoLastChar, 1, 1)	;two last chars and then first char
	if (InStr(HotstringEndChars, BeforeLast))
		return true
	else
		return false
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_OneCharPressed(ih, Char)
{	;This function is always run BEFORE the hotstring functions (eg. F_Simple_Output, F_Simple_Output etc.). Therefore v_InputString cannot be cleared by this function. The algorithm: two buffers: v_IS and v_Q. At first triggerstring tips are searched over v_IS. v_IS is longer by one character each time user presses something. When no longer characters are found among v_IS, then v_Q is incremented by one character per loop. Always at the first priority v_Q is searched as the string which could be used to display triggerstring tips.
	global	;assume-global mode of operation
	Critical, On
	static	FoundTips		:= false
	local	f_EndCharDetected := false	;flag set when EndChar is detected
		,	index := 0, value := ""	;usual set of variables applicable for "for" function
		, 	BeforeLast 	:= ""	;not last, but one before last character
		,	LastChar		:= ""	;last character of input buffer (v_InputString)
		,	TwoLastChar	:= ""	;two last characters of input buffer (v_InputString)

	; OutputDebug, % "1)IS:" . v_InputString . "|" . A_Space 
		; . "QS:" . v_Qinput . "|" . A_Space 
		; . "f_EC:" . f_EndCharDetected . A_Space 
		; . "Char:" . Char . "|" 
		; . "`n"
	if (WinActive("ahk_id" TT_C4_Hwnd)) or (WinExist("ahk_id" HMenuCliHwnd)) or (WinExist("ahk_id" HMenuAHKHwnd))
		return

	if (v_InputString = "")	;always true after any hotstring
		v_Qinput 	:= ""
	
	v_InputString .= Char
	if (v_Qinput)
		v_Qinput .= Char

	if (StrLen(v_InputString) > 1)
		f_EndCharDetected := F_CheckBeforeLastChar(v_InputString)

	if (f_EndCharDetected) and (!FoundTips)	;exception: TS = "-/" (starts from EndChar). It is necessary to remember (static variable) if in previous step was found any triggerstring tip.
	{
		v_InputString 	:= Char
	,	v_Qinput 		:= ""
	}
	if (f_EndCharDetected) and (FoundTips) and (v_Qinput) ;exception: triggerstring contains double space (e.g. S2_DoubleSpace.csv)
	{
		v_InputString 	:= Char
	,	v_Qinput 		:= ""
	}	

	; OutputDebug, % "2)v_IS:" . v_InputString . "|" . A_Space 
	; 			. "f_EC:" . f_EndCharDetected . A_Space 
	; 			 . "v_QI:" . v_Qinput . "|" 
	; 			 . "FoundTips:" . FoundTips . "|"
	; 			 . "`n"
	Gui, Tt_HWT: Hide	;Tooltip: Basic hotstring was triggered
	Gui, Tt_ULH: Hide	;Undid the last hotstring
	if (ini_TTTtEn)
	{
		if (v_Qinput)
			F_PTTTQ(v_Qinput)
		else
			F_PTTT(v_InputString)	;Variant when new sequence starts from EndChar.

		; OutputDebug, % "IS:" . v_InputString . "|" . A_Space 
		; . "`n"
		F_DestroyTriggerstringTips(ini_TTCn)
		if (a_Tips.Count())	;if tips are available display then
		{
			FoundTips := true
			F_ShowTriggerstringTips2(a_Tips, a_TipsOpt, a_TipsEnDis, a_TipsHS, ini_TTCn)
			
			if (ini_TTTD > 0)
				SetTimer, TurnOff_Ttt, % "-" . ini_TTTD
		}
		else
			FoundTips := false
	}
	; OutputDebug, % A_ThisFunc . A_Space . "E" 
	; 	. A_Space . "Char:" . Char . "|" 
	; 	. A_Space . "v_IS:" . v_InputString . "|" 
	; 	. A_Space . "v_QI:" . v_Qinput . "|" 
	; 	. A_Space . "FoundTips:" . FoundTips . "|"
	; 	. A_Space . "f_EC:" . f_EndCharDetected 
	; 	. "`n"
	Critical, Off
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_InitiateInputHook()	;why InputHook: to process triggerstring tips.
{
	global	;assume-global mode of operation
	v_InputString := "", v_TrigTipsInput := "", v_UndoHotstring := "", v_UndoTriggerstring := ""	;used by output functions: F_HMenu_Output, F_HMenu_Output
,	v_InputH 				:= InputHook("V L0")			
,	v_InputH.MinSendLevel 	:= ini_MinSendLevel			;I1 by default
,	v_InputH.OnChar 		:= Func("F_OneCharPressed")
,	v_InputH.OnKeyDown		:= Func("F_OnKeyDown")
,	v_InputH.OnKeyUp 		:= Func("F_BackspaceProcessing")	;this function is run whenever Backspace key or LShift or RShift is up 
,	v_InputH.OnEnd			:= Func("F_InputHookOnEnd")
	v_InputH.KeyOpt("{Backspace}{LShift}{RShift}", "N")				;Backspace is not Char ;N: Notify. Causes the OnKeyDown and OnKeyUp callbacks to be called each time the key is pressed.
	v_InputH.Start()
	; OutputDebug, % A_ThisFunc . A_Space . "ini_MinSendLevel:" . ini_MinSendLevel . "|" . A_Space . v_InputH.MinSendLevel . "`n"
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_OnKeyDown(ih, VK, SC)	;On Key Down
{
	global		;assume-global mode of operation
	Critical, On	;This function starts as the first one (prior to "On Character Down"), but unfortunately can be interrupted by it. To prevent it Critical command is applied.
	local 	WhatWasDown := GetKeyName(Format("vk{:x}sc{:x}", VK, SC))
		,	KeyIsDownPhysically := 0
	
	Sleep, 1	;sequence of events: function F_OnKeyDown is run automatically (like interruption), next we need to read-out physical state of key, so some time is necessary (sleep) to set keyboard state before it can be read. Interestingly 1 ms seems to be enough. It looks like any sleep (delay) is required.
	KeyIsDownPhysically := GetKeyState(WhatWasDown, "P")	;it is necessary to recognize if key was pressed physically or logically as 3x scripts run on the same time and ShiftFunctions sends out many Shift key presses.
	; OutputDebug, % A_ThisFunc . A_Space . "B" . "`n"
	; OutputDebug, % A_ThisFunc . A_Space . "WhatWasDown:" . WhatWasDown . A_Space . "KeyIsDownPhysically:" . KeyIsDownPhysically . A_Space .  "B" . "`n"
	if (KeyIsDownPhysically)
		Switch WhatWasDown
		{
			Case "LShift":
				f_LShiftDown := true
				F_CheckIf100ms()
			Case "RShift":
				f_RShiftDown := true
				F_CheckIf100ms()
			Default:
				f_LShiftDown := false
			,	f_RShiftDown := false	
		}
	; OutputDebug, % A_ThisFunc . A_Space . "E" . "`n"
	Critical, Off
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_100msTimeout()
{
	global		;assume-global mode of operation

	f_100msRun 	:= false
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_CheckIf100ms()	;To check if defined time elapsed for concurrent Shift keys press (LShift + RShift)
{
	global		;assume-global mode of operation

	if (f_100msRun)
	{
		SetTimer, F_100msTimeout, Off
		f_100msRun := false
		if (f_LShiftDown) and (f_RShiftDown)
		{
			f_WasReset := true
		,	f_LShiftDown := false
		,	f_RShiftDown := false	
		}	
		; OutputDebug, % "concurrent" . "`n"
	}
	else
	{
		SetTimer, F_100msTimeout, -100	;100 ms once
		f_100msRun 	:= true
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_InputHookOnEnd(ih)	;for debugging purposes
{
	global	;assume-global mode of operation
	local 	KeyName 	:= ih.EndKey, Reason	:= ih.EndReason
;#c/* commercial only beginning	
;#c*/ commercial only end			
	if (Reason = "Max")
		ih.Start()
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_BackspaceProcessing(ih, VK, SC)	;this function is run whenever Backspace key or LShift or RShift is up 
{
	global	;assume-global mode of operation
	Critical, On
	local	WhatWasUp := GetKeyName(Format("vk{:x}sc{:x}", VK, SC))

	; OutputDebug, % "Q:" . v_Qinput . "|" . A_Space . "I:" . v_InputString . "|" . "`n"
	if (f_WasReset)
	{
		Hotstring("Reset")
		v_InputString 	:= ""
	,	f_WasReset 	:= false
		; OutputDebug, % "Double Shift reset" . "`n"
		SoundPlay, *16	;future: add option to choose behavior (play sound or not, how long to play sound, what sound) and to define time to wait for reset scenario
		return
	}
	if (WhatWasUp = "Backspace") and (v_InputString)
	{
		v_Qinput := SubStr(v_Qinput, 1, -1)
	,	v_InputString := SubStr(v_InputString, 1, -1)
	
		if (ini_TTTtEn) and (v_Qinput)
			F_PTTTQ(v_Qinput)

		if (a_Tips.Count())
		{
			F_ShowTriggerstringTips2(a_Tips, a_TipsOpt, a_TipsEnDis, a_TipsHS, ini_TTCn)
			if ((ini_TTTtEn) and (ini_TTTD > 0))
				SetTimer, TurnOff_Ttt, % "-" . ini_TTTD ;, 200 ;Priority = 200 to avoid conflicts with other threads 
		}
		if (!v_Qinput)	;if v_InputString = "" = empty
		{
			if (ini_TTTtEn) and (v_InputString)
				F_PTTT(v_InputString)

			if (a_Tips.Count())
			{
				F_ShowTriggerstringTips2(a_Tips, a_TipsOpt, a_TipsEnDis, a_TipsHS, ini_TTCn)
				if ((ini_TTTtEn) and (ini_TTTD > 0))
					SetTimer, TurnOff_Ttt, % "-" . ini_TTTD ;, 200 ;Priority = 200 to avoid conflicts with other threads 
			}
			if (!v_InputString)	;if v_InputString = "" = empty
				F_DestroyTriggerstringTips(ini_TTCn)
		}
		Critical, Off
		return
	}

	if (WhatWasUp = "LShift") 
	{
		f_LShiftDown := false
		; OutputDebug, % "LShift Up" . "`n"
	}	
	if (WhatWasUp = "RShift")
	{
		f_RShiftDown := false
		; OutputDebug, % "RShift Up" . "`n"
	}
	Critical, Off
	; OutputDebug, % A_ThisFunc . A_Space . GetKeyName(Format("vk{:x}sc{:x}", VK, SC)) . A_Space . "E" . "`n"
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_DetermineMonitors()	; Multi monitor environment, initialization of monitor width and height parameters
{
	global	;assume-global mode
	local	NoOfMonitors
		,	Temp := 0, TempLeft := 0, TempRight := 0, TempTop := 0, TempBottom := 0, TempWidth := 0, TempHeight := 0
		,	Left := 0, Right := 0, Top := 0, Bottom := 0, Width := 0, Height := 0
	
	MonitorCoordinates := {} ;global variable
	
	SysGet, NoOfMonitors, MonitorCount	
	Loop, % NoOfMonitors
	{
		SysGet, Temp, Monitor, % A_Index
		MonitorCoordinates[A_Index] 			:= {}
,		MonitorCoordinates[A_Index].Left 		:= TempLeft
,		MonitorCoordinates[A_Index].Right 		:= TempRight
,		MonitorCoordinates[A_Index].Top 		:= TempTop
,		MonitorCoordinates[A_Index].Bottom 	:= TempBottom
,		MonitorCoordinates[A_Index].Width 		:= TempRight - TempLeft
,		MonitorCoordinates[A_Index].Height	 	:= TempBottom - TempTop
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_GUIInit()
{
	global	;assume-global mode
	local	f_FitsToAnyMonitor := false, key := 0, 		WinX := 0, WinY := 0, WinW := 0, WinH := 0

	if (f_MainGUIresizing) ;if run for the very first time
	{
		; OutputDebug, % A_ThisFunc . A_Space . "ini_HS3GuiMaximized:" . A_Space . ini_HS3GuiMaximized . A_Space . "ini_WhichGui:" . A_Space . ini_WhichGui . A_Space . "ini_HS3WindoPos.X:" . A_Space . ini_HS3WindoPos.X . "ini_HS3WindoPos.Y:" . A_Space . ini_HS3WindoPos.Y  . A_Space . "ini_HS3WindoPos.W:" . ini_HS3WindoPos.W . A_Space . "ini_HS3WindoPos.H:" . ini_HS3WindoPos.H . "`n"
		Gui, HS3: +MinSize%HS3MinWidth%x%HS3MinHeight%
		Gui, HS4: +MinSize%HS4MinWidth%x%HS4MinHeight%
		if (ini_HS3GuiMaximized)	;after restart if window was maximized
		{
			Gui, % ini_WhichGui . ": Show", % "X" . ini_HS3WindoPos.X . A_Space . "Y" . ini_HS3WindoPos.Y . A_Space . "W" . ini_HS3WindoPos.W . A_Space . "H" . ini_HS3WindoPos.H
			Gui, HS3: Default
			F_GuiHS3_LVcolumnScale()
			return
		}
		;OutputDebug, % "ini_GuiReload:" . A_Tab . ini_GuiReload . A_Tab . "ini_WhichGui:" . A_Tab . ini_WhichGui
		ini_GuiReload := false
		IniWrite, % ini_GuiReload,		% ini_HADConfig, GraphicalUserInterface, GuiReload

		if (ini_HS3WindoPos.X = "") or (ini_HS3WindoPos.Y = "")
		{
			Gui, % ini_WhichGui . ": Show", AutoSize Center	;initiates HS3GuiSize
			if (ini_WhichGui = "HS3")
				{
					Gui, HS3: Default
					F_GuiHS3_LVcolumnScale()
				}
			if (ini_ShowIntro)
				Gui, ShowIntro: Show, AutoSize Center
			f_MainGUIresizing := false
			return
		}
		F_DetermineMonitors()	;This function is present in library only!
		for key in MonitorCoordinates	;check if X variable read from ini file is not from outside of current monitor coordinates. This is useful if you unplugged your laptop from docking station or changed on the fly in any other way your workplace setup and now amount of available monitor differs.
		{
			if (ini_HS3WindoPos.X > MonitorCoordinates[key].Left) and (ini_HS3WindoPos.X < MonitorCoordinates[key].Right)
				f_FitsToAnyMonitor := true
		}
		if (f_FitsToAnyMonitor)
		{
			if (ini_HS3WindoPos.W = "") or (ini_HS3WindoPos.H = "")
			{
				Gui,	% ini_WhichGui . ": Show", % "X" . ini_HS3WindoPos.X . A_Space . "Y" . ini_HS3WindoPos.Y . A_Space . "AutoSize"
				if (ini_WhichGui = "HS3")
				{
					Gui, HS3: Default
					F_GuiHS3_LVcolumnScale()
				}
			}
			else
			{
				Gui,	% ini_WhichGui . ": Show", % "X" . ini_HS3WindoPos.X . A_Space . "Y" . ini_HS3WindoPos.Y . A_Space . "W" . ini_HS3WindoPos.W . A_Space . "H" . ini_HS3WindoPos.H
				if (ini_WhichGui = "HS3")
				{
					Gui, HS3: Default
					F_GuiHS3_LVcolumnScale()
				}
			}
		}
		else
		{
			Gui, % ini_WhichGui . ": Show", Center AutoSize
			if (ini_WhichGui = "HS3")
				{
					Gui, HS3: Default
					F_GuiHS3_LVcolumnScale()
				}
			MsgBox, 48, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["warning"], % TransA["Your current screen coordinates have changed. For example you've unplugged your laptop from docking station. Your settings in .ini file will be adjusted accordingly."]
			F_SaveGUIPos()
			ini_HS3WindoPos.X := WinX
,			ini_HS3WindoPos.Y := WinY
,			ini_HS3WindoPos.W := WinW
,			ini_HS3WindoPos.H := WinY
		}
		if (ini_ShowIntro)
			Gui, ShowIntro: Show, AutoSize Center
		f_MainGUIresizing := false
	}
	else
	{
		if (ini_HS3GuiMaximized)
		{
			Gui, HS3: Show, Maximize
			; Gui, % ini_WhichGui . ": Show", % "X" . ini_HS3WindoPos.X . A_Space . "Y" . ini_HS3WindoPos.Y . A_Space . "Maximize"
			Gui, HS3: Default
			F_GuiHS3_LVcolumnScale()
		}
		else
			Gui, % ini_WhichGui . ": Show", Restore ;Unminimizes or unmaximizes the window, if necessary. The window is also shown and activated, if necessary.		
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;#c/* commercial only beginning
;#c*/ commercial only end
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_OpenConfigIniLocation()
{
	global	;assume-global mode of operation
	Run, % "explore" . A_Space . c_AppDataLocal . "\" . SubStr(A_ScriptName, 1, -4)	
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_OpenConfigIniInEditor()
{
	global	;assume-global mode of operation
	Run, edit %ini_HADConfig%
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
MoveLibsGuiCancel()	;Gui event
{
	global	;assume-global mode of operation
	if (WinExist("ahk_id" MoveLibsHwnd))
		Gui, HS3SearchHwnd: -Disabled
	Gui, MoveLibs: Destroy
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
MoveLibsGuiEscape()	;Gui event
{
	MoveLibsGuiCancel()	
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
HS4GuiEscape()	;Gui event
{
	global	;assume-global mode
	ini_WhichGui := "HS4"
	Gui,		HS4: Show, Hide
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
HS4GuiClose()	;Gui event
{
	HS4GuiEscape()
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
HS3GuiEscape()	;Gui event
{
	global	;assume-global mode
	ini_WhichGui := "HS3"
	Gui,		HS3: Show, Hide
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
HS3GuiClose()	;Gui event
{
	HS3GuiEscape()
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_ALibOK()
{
	global	;assume-global mode
	local	LastChosenLibraryName := "", WhichGui := F_WhichGui()

	Gui, ALib: Submit, NoHide
	if (v_NewLib == "")
	{
		MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["Enter a name for the new library"]
		if (WhichGui = "HS3")
			Gui, HS3: -Disabled
		if (WhichGui = "HS4")
			Gui, HS4: -Disabled
		return
	}
	v_NewLib .= ".csv"
	IfNotExist, % ini_HADL . "\" . v_NewLib
	{
		FileAppend,, % ini_HADL . "\" . v_NewLib, UTF-8
		MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["The library"] . A_Space . v_NewLib . A_Space . TransA["has been created."]
		if (WhichGui = "HS3")
		{
			Gui, HS3: -Disabled
			GuiControlGet, LastChosenLibraryName, , % IdDDL2
		}
		if (WhichGui = "HS4")
		{
			Gui, HS4: -Disabled
			GuiControlGet, LastChosenLibraryName, , % IdDDL2b
		}
		Gui, ALib: Destroy
		
		F_ValidateIniLibSections()
		F_RefreshListOfLibraries()	; this function calls F_RefreshListOfLibraryTips() as both options are interrelated
		F_UpdateSelHotLibDDL()
		if (WhichGui = "HS3")
			GuiControl, ChooseString, % IdDDL2, % LastChosenLibraryName
		if (WhichGui = "HS4")
			GuiControl, ChooseString, % IdDDL2b, % LastChosenLibraryName
	}
	else
		MsgBox, 48, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["warning"], % TransA["A library with that name already exists!"]
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
ALibGuiEscape()	;Gui event
{
	global	;assume-global mode
	if (WinExist("ahk_id" HS3GuiHwnd))
		Gui, HS3: -Disabled
	if (WinExist("ahk_id" HS4GuiHwnd))
		Gui, HS4: -Disabled	
	Gui, ALib: Destroy
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
ALibGuiClose()	;Gui event
{
	ALibGuiEscape()
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
VersionUpdateGuiEscape()	;Gui event
{
	global	;assume-global mode
	if (WinExist("ahk_id" HS3GuiHwnd))
		Gui, HS3: -Disabled
	if (WinExist("ahk_id" HS4GuiHwnd))
		Gui, HS4: -Disabled	
	Gui, VersionUpdate: Hide
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
VersionUpdateGuiClose()	;Gui event
{
	VersionUpdateGuiEscape()
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_OpenLibrariesFolderInExplorer()
{
	global	;assume global-mode
	Run, explore %ini_HADL%
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_PublicLibraries()
{
	Run, https://github.com/mslonik/Hotstrings-Libraries
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_PasteFromClipboard()
{
	global	;assume-global mode
	local	ContentOfClipboard := ""
	
	if (ini_HK_IntoEdit != c_dHK_CopyClip)
		Send, ^c
	Sleep, % ini_CPDelay
	ContentOfClipboard := Clipboard

	if (InStr(ContentOfClipboard, "`r`n") or InStr(ContentOfClipboard, "`n"))
	{
		MsgBox, 67, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["Content of clipboard contain new line characters. Do you want to remove them?"] . "`n`n" 
			. TransA["Tip: If you copy text from PDF file it's adviced to remove them."]
		IfMsgBox, Cancel
			return
		IfMsgBox, Yes
			ContentOfClipboard := StrReplace(ContentOfClipboard, "`r`n", " ")
		IfMsgBox, No
			ContentOfClipboard := StrReplace(ContentOfClipboard, "`r`n", "``n")
	}
	ControlSetText, Edit2, % ContentOfClipboard
	Gui, % F_WhichGui() . ":" . A_Space . "Show"
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
HSDelGuiClose()	;Gui event!
{
	HSDelGuiEscape()
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
HSDelGuiEscape()	;Gui event!
{
	global	;assume global mode
	IniWrite, %ini_CPDelay%, % ini_HADConfig, Configuration, ClipBoardPasteDelay
	if (WinExist("ahk_id" HS3GuiHwnd))
		Gui, HS3: -Disabled
	if (WinExist("ahk_id" HS4GuiHwnd))
		Gui, HS4: -Disabled		
	Gui, HSDel: Destroy
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_GuiAboutLink1()
{
	Run, https://github.com/mslonik/Hotstrings
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_GuiAboutLink2()
{
	Run, https://www.autohotkey.com/docs/Hotstrings.htm
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_TrayExit()
{
	ExitApp, 2	;2 = by Tray
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_SuspendTipsAndHotkeys(parameter*)	;F10
{
	global	;assume-global mode: v_InputH
	static	PreviousState := true

	Switch parameter[1]
	{
		Case "enable":
		EnableTipsAndHotkeys:
			v_InputH.Start()
			F_SuspendAllTips(true, false)	;enable all triggerstring tips
			F_SwitchHotstrings("enabled")
			Switch WhichGuiEnable := F_WhichGui()	;Disable all GuiControls for time of adding / editing of d(t, o, h)	
			{
				Case "HS3":	F_GuiHS3_EnDis("Enable")
				Case "HS4": 	F_GuiHS4_EnDis("Enaable")
			}
			Hotstring("Reset")
			v_InputString := ""
			Menu, Tray, 		UnCheck, % TransA["Suspend Hotstrings and all tips"] . "`tF10"
			Menu, AppSubmenu, 	UnCheck, % TransA["Suspend Hotstrings and all tips"] . "`tF10"
			MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["Hotstring definitions are now ACTIVE."]
				. "`n`n" . TransA["It means triggerstring tips state is restored and hotstring definitions will be triggered as usual."]

		Case "disable":
		DisableTipsAndHotkeys:
			v_InputH.Stop()
			F_SuspendAllTips(false, false)	;disable all triggerstring tips
			F_DestroyTriggerstringTips(ini_TTCn)
			F_SwitchHotstrings("disabled")
			Switch WhichGuiEnable := F_WhichGui()	;Disable all GuiControls for time of adding / editing of d(t, o, h)	
			{
				Case "HS3":	F_GuiHS3_EnDis("Disable")
				Case "HS4": 	F_GuiHS4_EnDis("Disable")
			}
			Menu, Tray, 		Check, % TransA["Suspend Hotstrings and all tips"] . "`tF10"
			Menu, AppSubmenu, 	Check, % TransA["Suspend Hotstrings and all tips"] . "`tF10"
			MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["Hotstring definitions are now SUSPENDED."]
				. "`n`n" . TransA["It means other script threads are still running. Triggerstring tips are off for your convenience."]

		Default:	;including "toggle"
			PreviousState := !PreviousState
			if (PreviousState)
				Goto EnableTipsAndHotkeys
			else
				Goto DisableTipsAndHotkeys
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_SuspendAllTips(AllTipsState, MsgBoxState)	;F11
{
	global	;assume global mode
	static	temp_ini_OHTtEn := true	;set of variables to store in memory state of variables
		,	temp_ini_UHTtEn := true
		,	temp_ini_TTTtEn := true
		,	PreviousState := true

	Switch AllTipsState
	{
		Case true:	;enable previously disabled tooltips
		enable:
			if (temp_ini_OHTtEn)
				ini_OHTtEn := true
			if (temp_ini_UHTtEn)
				ini_UHTtEn := true
			if (temp_ini_TTTtEn)
				ini_TTTtEn := true
			Hotstring("Reset")
			v_InputString := ""
			Menu, Tray, 		UnCheck, % TransA["Suspend all tips"] . "`tF11"
			Menu, AppSubmenu, 	UnCheck, % TransA["Suspend all tips"] . "`tF11"
			if (MsgBoxState)
				MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["All tips (e.g. triggerstring tips, tips displayed after definition is completed, udno) are now ACTIVE."]
					. "`n`n" . TransA["Hotstring definitions are still active."]

		Case false: 	;disable tooltips
		disable:
			temp_ini_OHTtEn := ini_OHTtEn
		,	temp_ini_UHTtEn := ini_UHTtEn
		,	temp_ini_TTTtEn := ini_TTTtEn

			if (ini_OHTtEn)	;Ordinary Hotstring Triggerstring tip Enable
				ini_OHTtEn := false
			if (ini_UHTtEn)	;Undid Hotstring Triggerstring tip Enable
				ini_UHTtEn := false
			if (ini_TTTtEn)	;Triggerstring Tips Enable
				ini_TTTtEn := false
			F_DestroyTriggerstringTips(ini_TTCn)
			Menu, Tray, 		Check, % TransA["Suspend all tips"] . "`tF11"
			Menu, AppSubmenu, 	Check, % TransA["Suspend all tips"] . "`tF11"
			if (MsgBoxState)
				MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["All tips (e.g. triggerstring tips, tips displayed after definition is completed, udno) are now SUSPENDED."]
					. "`n`n" . TransA["Hotstring definitions are still active."]
		Default:		;including "toggle"
			PreviousState := !PreviousState
			if (PreviousState)
				Goto enable
			else
				Goto disable
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_SwitchHotstrings(decision)	;to enable or disable all hotstring definitions
{
	global	;assume global mode
	local key := 0, value := ""

	for key, value in a_EnableDisable
	{
		if (value = "En")	;turn off existing hotstring
		{
			Try
				Hotstring(":" . a_TriggerOptions[key] . ":" . F_ConvertEscapeSequences(a_Triggerstring[key]), , (decision = "disabled" ? "Off" : "On"))
			Catch
				MsgBox, 16, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["Error"], % TransA["Function"] . ":" . A_Space . A_ThisFunc 
					. "`n" . (decision = "disabled" ? TransA["Something went wrong with disabling of existing hotstring"] : TransA["Something went wrong with enabling of existing hotstring"]) . ":" . "`n`n"
					. "Hotstring(:" . a_TriggerOptions[key] . ":" . a_Triggerstring[key] . "," . A_Space . (decision = "disabled" ? "Off" : "On") . ")"
		}	
	}	
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
ShowIntroGuiEscape()	;Gui event
{
	global	;assume global mode
	if (WinExist("ahk_id" HS3GuiHwnd))
		Gui, HS3: -Disabled
	if (WinExist("ahk_id" HS4GuiHwnd))
		Gui, HS4: -Disabled	
	Gui, ShowIntro: Hide
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
ShowIntroGuiClose()
{
	ShowIntroGuiEscape()
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
ShortDefGuiEscape()
{
	global	;assume global mode
	if (WinExist("ahk_id" HS3GuiHwnd))
		Gui, HS3: -Disabled
	if (WinExist("ahk_id" HS4GuiHwnd))
		Gui, HS4: -Disabled	
	Gui, ShortDef: Destroy
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
ShortDefGuiClose()
{
	ShortDefGuiEscape()
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
HS3SearchGuiEscape() ; Gui event!
{
	Gui, HS3Search:	+Disabled
	Gui, HS3: 		-Disabled
	Gui, HS3Search: 	Hide
	Suspend, Off	;Enabling all hoststrings again
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
HS3SearchGuiClose() ; Gui event!
{
	HS3SearchGuiEscape()
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
MyAboutGuiClose() ; Gui event!
{
	global	;assume-global mode of operation
	if (WinExist("ahk_id" HS3GuiHwnd))
		Gui, HS3: -Disabled
	if (WinExist("ahk_id" HS4GuiHwnd))
		Gui, HS4: -Disabled	
	Gui, MyAbout: Hide
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
MyAboutGuiEscape()	; Gui event!
{
	MyAboutGuiClose()
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_LoadGUIstatic()
{
	global	;assume-global mode
	local	ini_ReadTemp := 0
	ini_SWPos 	:= {"X": 0, "Y": 0, "W": 0, "H": 0} ;at the moment associative arrays are not supported in AutoHotkey as parameters of Commands
	IniRead, ini_ReadTemp, 						% ini_HADConfig, StaticTriggerstringHotstring, SWPosX, % A_Space
	if (ini_ReadTemp = "")	;thanks to this trick existing Config.ini do not have to be erased if new configuration parameters are added.
		IniWrite, % ini_ReadTemp, % ini_HADConfig, StaticTriggerstringHotstring, SWPosX
	ini_SWPos.X := ini_ReadTemp
	IniRead, ini_ReadTemp, 						% ini_HADConfig, StaticTriggerstringHotstring, SWPosY, % A_Space
	if (ini_ReadTemp = "")	;thanks to this trick existing Config.ini do not have to be erased if new configuration parameters are added.
		IniWrite, % ini_ReadTemp, % ini_HADConfig, StaticTriggerstringHotstring, SWPosY
	ini_SWPos["Y"] := ini_ReadTemp
	IniRead, ini_ReadTemp, 						% ini_HADConfig, StaticTriggerstringHotstring, SWPosW, % A_Space
	if (ini_ReadTemp = "")	;thanks to this trick existing Config.ini do not have to be erased if new configuration parameters are added.
		IniWrite, % ini_ReadTemp, % ini_HADConfig, StaticTriggerstringHotstring, SWPosW
	ini_SWPos.W := ini_ReadTemp
	IniRead, ini_ReadTemp, 						% ini_HADConfig, StaticTriggerstringHotstring, SWPosH, % A_Space
	if (ini_ReadTemp = "")	;thanks to this trick existing Config.ini do not have to be erased if new configuration parameters are added.
		IniWrite, % ini_ReadTemp, % ini_HADConfig, StaticTriggerstringHotstring, SWPosH
	ini_SWPos.H := ini_ReadTemp
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_RecreateGuiStatic()
{
	global	;assume-global mode
	local	f_TT_C4visible := false,	f_TT_C4hidden := false
	if (ini_TTCn = 4)	;static triggerstring / hostring menu
	{
		if (WinExist("ahk_id" TT_C4_Hwnd))
			f_TT_C4visible := true
		if (f_TT_C4visible)
		{
			Gui, TT_C4: Destroy
			F_GuiTrigTipsMenuDefC4()
			return
		}
		DetectHiddenWindows, On
		if (WinExist("ahk_id" TT_C4_Hwnd))
			f_TT_C4hidden := true
		DetectHiddenWindows, Off
		if (f_TT_C4hidden)
		{
			Gui, TT_C4: Destroy
			F_GuiTrigTipsMenuDefC4()
			Gui, TT_C4: Hide
		}
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_DestroyTriggerstringTips(ini_TTCn)
{
	global	;assume-global mode
	Switch ini_TTCn
	{
		Case 1: Gui, TT_C1: Destroy
		Case 2: Gui, TT_C2: Destroy
		Case 3: Gui, TT_C3: Destroy
		Case 4:
			GuiControl,, % IdTT_C4_LB1, % c_MHDelimiter
			GuiControl,, % IdTT_C4_LB2, % c_MHDelimiter
			GuiControl,, % IdTT_C4_LB3, % c_MHDelimiter
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_InitiateTrayMenus(v_SilentMode)
{
	global	;assume-global mode
	Switch v_SilentMode
	{
;#c/* commercial only beginning		
;#c*/ commercial only end
		Case "":
			Menu, Tray, NoStandard									; remove all the rest of standard tray menu
			; OutputDebug, % "AppIcon:" . AppIcon . "`n" . "A_ScriptDir:" . A_Tab . A_ScriptDir .  "`n" . "A_WorkingDir:" . A_Tab . A_WorkingDir . "`n" . "FileExist(AppIcon):" . A_Tab . FileExist(AppIcon) . "`n"
			if (!FileExist(AppIcon)) and (!A_IsCompiled)				; if the file is compiled, then icon is inside of .exe file.
			{
				MsgBox, 68, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["Information"], % TransA["The icon file"] . ":" . "`n`n" . AppIcon . "`n`n" . TransA["doesn't exist in application folder"] . "." 
					. A_Space . TransA["Would you like to download the icon file?"] . "`n`n" . TransA["If you answer ""Yes"", the icon file will be downloaded. If you answer ""No"", the default AutoHotkey icon will be used."]
				IfMsgBox, Yes
				{
					; OutputDebug, % "AppIcon:" . A_Tab . AppIcon
					URLDownloadToFile, 	https://raw.githubusercontent.com/mslonik/Hotstrings/master/hotstrings.ico, % AppIcon
					Menu, Tray, Icon,		% AppIcon 				;GUI window uses the tray icon that was in effect at the time the window was created. FlatIcon: https://www.flaticon.com/ Cloud Convert: https://www.cloudconvert.com/
				}
				IfMsgBox, No
					Menu, Tray, Icon,		* 						;Specify an asterisk (*) for FileName to restore the script to its default icon.
			}
			if (A_IsCompiled)
				Menu, Tray, Icon,			* 						;Specify an asterisk (*) for FileName to restore the script to its default icon.
			else
				Menu, Tray, Icon,			% AppIcon 				;GUI window uses the tray icon that was in effect at the time the window was created. FlatIcon: https://www.flaticon.com/ Cloud Convert: https://www.cloudconvert.com/

			Menu, Tray, Add,		% SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["Default mode"], 	F_GuiAbout
			Menu, Tray, Add																	;line separator 
			Menu, Tray, Add, 		% TransA["Edit Hotstrings"] . "`tCtrl + Win + H",						F_GUIinit
			Menu, Tray, Default, 	% TransA["Edit Hotstrings"] . "`tCtrl + Win + H"
			Menu, Tray, Add																	;line separator 
			Menu, Tray, Add,		% TransA["Help: Hotstrings application"] . "`tF1",					F_GuiAboutLink1
			Menu, Tray, Add,		% TransA["Help: AutoHotkey Hotstrings reference guide"] . "`tCtrl + F1", 	F_GuiAboutLink2
			Menu, Tray, Add																	;line separator 
			Menu, TraySubmenuReload,	Add,		% TransA["Reload in default mode"] . "`tShift+Ctrl+R",			F_ReloadApplication
			Menu, TraySubmenuReload,	Add,		% TransA["Reload in silent mode"],							F_ReloadApplication
			Menu, Tray, Add,		% TransA["Reload"],												:TraySubmenuReload
			Menu  Tray, Add																	;line separator 
			Menu, Tray, Add, 		% TransA["Application statistics"],								F_AppStats
			Menu, Tray, Add																	;line separator 
			Menu, Tray, Add,		% TransA["Suspend Hotstrings and all tips"] . "`tF10",					F_SuspendTipsAndHotkeys
			Menu, Tray, Add,		% TransA["Suspend all tips"] . "`tF11", 							F_SuspendAllTips
			Menu  Tray, Add,		% TransA["Exit application"],										F_TrayExit
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_ChangeLanguage()
{
	global	;assume-global mode
	static	OneTimeOnly := true
	
	if (OneTimeOnly)
	{
		Loop, Files, %A_ScriptDir%\Languages\*.txt
		{
			if (ini_Language == A_LoopFileName)
				Menu, SubmenuLanguage, Check, %A_LoopFileName%
			else
				Menu, SubmenuLanguage, UnCheck, %A_LoopFileName%
		}
		OneTimeOnly := false
	}
	else
	{
		ini_Language := A_ThisMenuitem
		IniWrite, %ini_Language%, % ini_HADConfig, GraphicalUserInterface, Language
		Loop, Files, %A_ScriptDir%\Languages\*.txt
		{
			if (ini_Language == A_LoopFileName)
				Menu, SubmenuLanguage, Check, %A_LoopFileName%
			else
				Menu, SubmenuLanguage, UnCheck, %A_LoopFileName%
		}
		MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"],  % TransA["Application language changed to:"] . A_Space 
			. SubStr(ini_Language, 1, -4) . "`n`n" . TransA["The application will be reloaded with the new language file."]
		F_SaveFontType()
		F_SaveGUIPos("reset")
		ini_GuiReload := true
		IniWrite, % ini_GuiReload,		% ini_HADConfig, GraphicalUserInterface, GuiReload
		Reload
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_Load_ini_DownloadRepo()
{
	global	;assume-global mode
	ini_DownloadRepo			:= false		;global variable
	IniRead, ini_DownloadRepo,				% ini_HADConfig, Configuration, DownloadRepo,			% A_Space
	if (ini_DownloadRepo = "") ;thanks to this trick existing Config.ini do not have to be erased if new configuration parameters are added.
	{
		ini_DownloadRepo := false
		IniWrite, % ini_DownloadRepo, % ini_HADConfig, Configuration, DownloadRepo
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_Load_ini_CheckRepo()
{
	global	;assume-global mode
	ini_CheckRepo			:= false			;global variable
	IniRead, ini_CheckRepo,					% ini_HADConfig, Configuration, CheckRepo,				% A_Space
	if (ini_CheckRepo = "")	;thanks to this trick existing Config.ini do not have to be erased if new configuration parameters are added.
	{
		ini_CheckRepo := false
		IniWrite, % ini_CheckRepo, % ini_HADConfig, Configuration, CheckRepo
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_Load_ini_GuiReload()
{
	global	;assume-global mode
	ini_GuiReload			:= false			;global variable
	IniRead, ini_GuiReload, 					% ini_HADConfig, GraphicalUserInterface, GuiReload,		% A_Space
	if (ini_GuiReload = "")	;thanks to this trick existing Config.ini do not have to be erased if new configuration parameters are added.
	{
		ini_GuiReload := false
		IniWrite, % ini_GuiReload, % ini_HADConfig, GraphicalUserInterface, GuiReload
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_Load_ini_Language()
{
	global	;assume global-mode
	IniRead ini_Language, % ini_HADConfig, GraphicalUserInterface, Language, 		% A_Space		; Load from Config.ini file specific parameter: language into variable ini_Language, e.g. ini_Language = English.txt
	if (ini_Language = "")	;thanks to this trick existing Config.ini do not have to be erased if new configuration parameters are added.
	{
		ini_Language := "English.txt"
		IniWrite, % ini_Language, % ini_HADConfig, GraphicalUserInterface, Language
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_GuiTrigTipsMenuDefC4()	;static gui for triggerstring tips and hotstrings
{
;#c/* commercial only beginning	
;#c*/ commercial only end		
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_TT_C4_B1()	;Button: save position of "static" triggerstring / hotstring window
{	
	global	;assume-global mode
	local	WinX := 0, WinY := 0
	WinGetPos, WinX, WinY, , , % "ahk_id" . TT_C4_Hwnd
	IniWrite, % WinX, 			  	% ini_HADConfig, StaticTriggerstringHotstring, SWPosX
	IniWrite, % WinY, 			  	% ini_HADConfig, StaticTriggerstringHotstring, SWPosY
	MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["Position of this window is saved in Config.ini."]
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_GuiTrigTipsMenuDefC3(AmountOfRows, LongestTriggerstring, LongestHotstring)
{
	global	;assume-global mode of operation
	local  	vOutput1 := 0, vOutput1X := 0, vOutput1Y := 0, vOutput1W := 0, vOutput1H := 0
		, 	W_LB1 := 0, W_LB2 := 0, W_LB3 := 0, X_LB2 := 0, Y_LB2 := 0, X_LB3 := 0, Y_LB3 := 0
		,	cListboxMargin := 4
	
	Gui, TT_C3: New, +AlwaysOnTop -Caption +ToolWindow +HwndTT_C3_Hwnd +Delimiter%c_TextDelimiter%	;This trick changes delimiter for GuiControl,, ListBox from default "|" to that one
	Gui, TT_C3: Margin, 0, 0
	if (ini_ATEn)
	{
		if (ini_ATBgrCol = "custom")
			Gui, TT_C3: Color,, % ini_ATBgrColCus	;background of listbox
		else
			Gui, TT_C3: Color,, % ini_ATBgrCol	;background of listbox
		if (ini_TTTyFaceCol = "custom")		
			Gui, TT_C3: Font, % "s" . ini_ATTySize . A_Space . "c" . ini_ATTyFaceColCus, % ini_ATTyFaceFont
		else
			Gui, TT_C3: Font, % "s" . ini_ATTySize . A_Space . "c" . ini_ATTyFaceCol, % ini_ATTyFaceFont
	}
	else
	{
		if (ini_TTBgrCol = "custom")
			Gui, TT_C3: Color,, % ini_TTBgrColCus	;background of listbox
		else
			Gui, TT_C3: Color,, % ini_TTBgrCol	;background of listbox
		if (ini_TTTyFaceCol = "custom")		
			Gui, TT_C3: Font, % "s" . ini_TTTySize . A_Space . "c" . ini_TTTyFaceColCus, % ini_TTTyFaceFont
		else
			Gui, TT_C3: Font, % "s" . ini_TTTySize . A_Space . "c" . ini_TTTyFaceCol, % ini_TTTyFaceFont
	}
	; OutputDebug, % "LongestTriggerstring:" . A_Space . LongestTriggerstring . A_Space . "|" . A_Space . "LongestHotstring:" . A_Space . LongestHotstring . "`n"
	Gui, TT_C3: Add, Text, 		% "HwndIdTT_C3_T1 x0 y0", % LongestTriggerstring	;use dummy Text field to check how wide it is actually
	; Gui, TT_C3: Show, x0 y0	;for debugging purpose only
	GuiControlGet, vOutput1, Pos, % IdTT_C3_T1
	W_LB1 	:= vOutput1W + cListboxMargin
	Gui, TT_C3: Add, Text, 		% "HwndIdTT_C3_T2 x0 y0", % LongestHotstring
	GuiControlGet, vOutput1, Pos, % IdTT_C3_T2
	W_LB3	:= vOutput1W + cListboxMargin
	Gui, TT_C3: Add, Listbox, 	% "HwndIdTT_C3_LB1 x0 y0" . A_Space . "r" . AmountOfRows . A_Space . "w" . W_LB1 + cListboxMargin . A_Space . "g" . "F_TTMenuStatic_Mouse"
	Gui, TT_C3: Add, Text, 		% "HwndIdTT_C3_T3 x0 y0", W	;the widest latin letter; unfortunately once set Text has width which can not be easily changed. Therefore it's easiest to add the next one to measure its width.
	GuiControlGet, vOutput1, Pos, % IdTT_C3_T3
	W_LB2 	:= vOutput1W + cListboxMargin
	; OutputDebug, % "W_LB2:" . W_LB2 . "`n"
	GuiControlGet, vOutput1, Pos, % IdTT_C3_LB1
	X_LB2 	:= vOutput1X + vOutput1W, Y_LB2	:= vOutput1Y
	Gui, TT_C3: Add, Listbox, 	% "HwndIdTT_C3_LB2" . A_Space . "x" . X_LB2 . A_Space . "y" . Y_LB2 . A_Space . "r" . AmountOfRows . A_Space . "w" . W_LB2 + cListboxMargin . A_Space . "g" . "F_TTMenuStatic_Mouse"
	GuiControlGet, vOutput1, Pos, % IdTT_C3_LB2
	X_LB3	:= vOutput1X + vOutput1W, Y_LB3	:= Y_LB2
	if (W_LB3 > 3 * W_LB1)	;future: instead of "3" apply ini parameter defining maximum length as multiplication of W_LB1
		W_LB3 := 3 * W_LB1
	Gui, TT_C3: Add, Listbox, 	% "HwndIdTT_C3_LB3" . A_Space . "x" . X_LB3 . A_Space . "y" . Y_LB3 . A_Space . "r" . AmountOfRows . A_Space . "w" . W_LB3 + cListboxMargin . A_Space . "g" . "F_TTMenuStatic_Mouse"
	; Gui, TT_C3: Show, x0 y0	;for debugging purpose only
	Gui, TT_C3: Destroy	;unfortunately even when gui object are hidden, still background is visible; I don't want to have temporary (dummy) text object to be visible. therefore I destroy the whole gui and create it again.
	Gui, TT_C3: New, +AlwaysOnTop -Caption +ToolWindow +HwndTT_C3_Hwnd +Delimiter%c_TextDelimiter%	;This trick changes delimiter for GuiControl,, ListBox from default "|" to that one
	Gui, TT_C3: Margin, 0, 0
	if (ini_ATEn)
	{
		if (ini_ATBgrCol = "custom")
			Gui, TT_C3: Color,, % ini_ATBgrColCus	;background of listbox
		else
			Gui, TT_C3: Color,, % ini_ATBgrCol	;background of listbox
		if (ini_TTTyFaceCol = "custom")		
			Gui, TT_C3: Font, % "s" . ini_ATTySize . A_Space . "c" . ini_ATTyFaceColCus, % ini_ATTyFaceFont
		else
			Gui, TT_C3: Font, % "s" . ini_ATTySize . A_Space . "c" . ini_ATTyFaceCol, % ini_ATTyFaceFont
	}
	else
	{
		if (ini_TTBgrCol = "custom")
			Gui, TT_C3: Color,, % ini_TTBgrColCus	;background of listbox
		else
			Gui, TT_C3: Color,, % ini_TTBgrCol	;background of listbox
		if (ini_TTTyFaceCol = "custom")		
			Gui, TT_C3: Font, % "s" . ini_TTTySize . A_Space . "c" . ini_TTTyFaceColCus, % ini_TTTyFaceFont
		else
			Gui, TT_C3: Font, % "s" . ini_TTTySize . A_Space . "c" . ini_TTTyFaceCol, % ini_TTTyFaceFont
	}
	Gui, TT_C3: Add, Listbox, 	% "HwndIdTT_C3_LB1 x0 y0" 									. A_Space . "r" . AmountOfRows . A_Space . "w" . W_LB1 + cListboxMargin . A_Space . "g" . "F_TTMenuStatic_Mouse"
	Gui, TT_C3: Add, Listbox, 	% "HwndIdTT_C3_LB2" . A_Space . "x" . X_LB2 . A_Space . "y" . Y_LB2 	. A_Space . "r" . AmountOfRows . A_Space . "w" . W_LB2 + cListboxMargin . A_Space . "g" . "F_TTMenuStatic_Mouse"
	Gui, TT_C3: Add, Listbox, 	% "HwndIdTT_C3_LB3" . A_Space . "x" . X_LB3 . A_Space . "y" . Y_LB3 	. A_Space . "r" . AmountOfRows . A_Space . "w" . W_LB3 + cListboxMargin . A_Space . "g" . "F_TTMenuStatic_Mouse"
	GuiControl, Font, % IdTT_C3_LB1		;fontcolor of listbox
	GuiControl, Font, % IdTT_C3_LB2		;fontcolor of listbox
	GuiControl, Font, % IdTT_C3_LB3		;fontcolor of listbox
	; Gui, TT_C3: Show, x0 y0	;for debugging purpose only
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_GuiTrigTipsMenuDefC2(AmountOfRows, LongestString)
{
	global	;assume-global mode
	local  	vOutput := 0, vOutputX := 0, vOutputY := 0, vOutputW := 0, vOutputH := 0, OutputString := ""
		,	W_LB1 := 0, W_LB2 := 0, X_LB2 := 0, Y_LB2 := 0
		,	cListboxMargin := 4
	
	Loop, Parse, LongestString	;exchange all letters into "w" which is the widest letter in latin alphabet (the worst case scenario)
		OutputString .= "w"		;the widest ordinary letter in alphabet
	Gui, TT_C2: New, +AlwaysOnTop -Caption +ToolWindow +HwndTT_C2_Hwnd +Delimiter%c_TextDelimiter%	;This trick changes delimiter for GuiControl,, ListBox from default "|" to that one
	Gui, TT_C2: Margin, 0, 0
	if (ini_ATEn)
	{
		if (ini_ATBgrCol = "custom")
			Gui, TT_C2: Color,, % ini_ATBgrColCus	;background of listbox
		else
			Gui, TT_C2: Color,, % ini_ATBgrCol	;background of listbox
		if (ini_TTTyFaceCol = "custom")		
			Gui, TT_C2: Font, % "s" . ini_ATTySize . A_Space . "c" . ini_ATTyFaceColCus, % ini_ATTyFaceFont
		else
			Gui, TT_C2: Font, % "s" . ini_ATTySize . A_Space . "c" . ini_ATTyFaceCol, % ini_ATTyFaceFont
	}
	else
	{
		if (ini_TTBgrCol = "custom")
			Gui, TT_C2: Color,, % ini_TTBgrColCus	;background of listbox
		else
			Gui, TT_C2: Color,, % ini_TTBgrCol	;background of listbox
		if (ini_TTTyFaceCol = "custom")		
			Gui, TT_C2: Font, % "s" . ini_TTTySize . A_Space . "c" . ini_TTTyFaceColCus, % ini_TTTyFaceFont
		else
			Gui, TT_C2: Font, % "s" . ini_TTTySize . A_Space . "c" . ini_TTTyFaceCol, % ini_TTTyFaceFont
	}

	Gui, TT_C2: Add, Text, % "HwndIdTT_C2_T1 x0 y0", % OutputString
	GuiControlGet, vOutput, Pos, % IdTT_C2_T1
	W_LB1 	:= vOutputW + cListboxMargin
	Gui, TT_C2: Add, Listbox, 	% "HwndIdTT_C2_LB1 x0 y0" . A_Space . "r" . AmountOfRows . A_Space . "w" . W_LB1 + 4 . A_Space . "g" . "F_TTMenuStatic_Mouse"	;thanks to "g" it will not be a separate thread even upon mouse click
	Gui, TT_C2: Add, Text, 		% "HwndIdTT_C2_T2 x0 y0", W	;the widest latin letter; unfortunately once set Text has width which can not be easily changed. Therefore it's easiest to add the next one to measure its width.
	GuiControlGet, vOutput, Pos, % IdTT_C2_T2
	W_LB2 	:= vOutputW + cListboxMargin
	GuiControlGet, vOutput, Pos, % IdTT_C2_LB1
	X_LB2 	:= vOutputX + vOutputW, Y_LB2	:= vOutputY
	Gui, TT_C2: Add, Listbox, % "HwndIdTT_C2_LB2" . A_Space . "x" . X_LB2 . A_Space . "y" . Y_LB2 . A_Space . "r" . AmountOfRows . A_Space . "w" . W_LB2 + 4 . A_Space . "g" . "F_TTMenuStatic_Mouse"
	GuiControl, Hide, % IdTT_C2_T1
	GuiControl, Hide, % IdTT_C2_T2
	GuiControl, Font, % IdTT_C2_LB1		;fontcolor of listbox
	GuiControl, Font, % IdTT_C2_LB2		;fontcolor of listbox
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_GuiTrigTipsMenuDefC1(AmountOfRows, LongestString)
{
	global	;assume-global mode of operation
	local 	vOutput := 0, vOutputX := 0, vOutputY := 0, vOutputW := 0, vOutputH := 0, OutputString := ""
	
	Loop, Parse, LongestString	;exchange all letters into "w" which is the widest letter in latin alphabet (the worst case scenario)
		OutputString .= "w"		;the widest ordinary letter in alphabet
	Gui, TT_C1: New, +AlwaysOnTop -Caption +ToolWindow +HwndTT_C1_Hwnd +Delimiter%c_TextDelimiter%	;This trick changes delimiter for GuiControl,, ListBox from default "|" to that one
	Gui, TT_C1: Margin, 0, 0
	if (ini_ATEn)
	{
		if (ini_ATBgrCol = "custom")
			Gui, TT_C1: Color,, % ini_ATBgrColCus	;background of listbox
		else
			Gui, TT_C1: Color,, % ini_ATBgrCol	;background of listbox
		if (ini_ATTyFaceCol = "custom")		
			Gui, TT_C1: Font, % "s" . ini_ATTySize . A_Space . "c" . ini_ATTyFaceColCus, % ini_ATTyFaceFont
		else
			Gui, TT_C1: Font, % "s" . ini_ATTySize . A_Space . "c" . ini_ATTyFaceCol, % ini_ATTyFaceFont
	}
	else
	{
		if (ini_TTBgrCol = "custom")
			Gui, TT_C1: Color,, % ini_TTBgrColCus	;background of listbox
		else
			Gui, TT_C1: Color,, % ini_TTBgrCol	;background of listbox
		if (ini_TTTyFaceCol = "custom")		
			Gui, TT_C1: Font, % "s" . ini_TTTySize . A_Space . "c" . ini_TTTyFaceColCus, % ini_TTTyFaceFont
		else
			Gui, TT_C1: Font, % "s" . ini_TTTySize . A_Space . "c" . ini_TTTyFaceCol, % ini_TTTyFaceFont
	}
	Gui, TT_C1: Add, Text, % "x0 y0 HwndIdTT_C1_T1", % OutputString
	GuiControlGet, vOutput, Pos, % IdTT_C1_T1
	Gui, TT_C1: Add, Listbox, % "x0 y0 HwndIdTT_C1_LB1" . A_Space . "r" . AmountOfRows . A_Space . "w" . vOutputW + 4 . A_Space . "g" . "F_TTMenuStatic_Mouse"	;thanks to "g" it will not be a separate thread even upon mouse click
	GuiControl, Hide, % IdTT_C1_T1
	GuiControl, Font, % IdTT_C1_LB1		;fontcolor of listbox
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_MenuLogEnDis()
{
;#c/* commercial only beginning
;#c*/ commercial only end
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_TTMenu_Keyboard()	;this is separate, dedicated function to handle "interrupt" coming from "g" event
{
	global	;assume-global mode
	local	PressedKey := A_ThisHotkey, Temp1 := "", DynVarRef := ""
	static 	IsCursorPressed := false, IntCnt := 0, MenuMax := 0

	; OutputDebug, % A_ThisFunc . "`n"
	if (!ini_ATEn)
		return
	MenuMax 	:= a_Tips.Count()
,	DynVarRef := "IdTT_C" . ini_TTCn . "_LB1"
	; OutputDebug, % "IntCnt:" . A_Space . IntCnt . "`n"

	Switch PressedKey
	{
		Case "^Down", "^Tab", "^WheelDown":
			GuiControl, Choose, % %DynVarRef%, % ++IntCnt
			IsCursorPressed := true
		Case "^Up", "+^Tab", "^WheelUp":
			GuiControl, Choose, % %DynVarRef%, % (--IntCnt = 0) ? (IntCnt := 1) : IntCnt
			IsCursorPressed := true
		Case "^Enter", "^MButton":
			PressedKey 		:= IntCnt
,			IsCursorPressed	:= false
,			IntCnt 			:= 0
	}

	if ((MenuMax = 1) and IsCursorPressed)
	{
		IntCnt := 1
		return
	}
	if (IsCursorPressed)
	{
		if (IntCnt > MenuMax)
		{
			IntCnt := MenuMax
			if (ini_MHSEn)
				SoundBeep, % ini_MHSF, % ini_MHSD	
		}
		if (IntCnt = 1)
		{
			if (ini_MHSEn)
				SoundBeep, % ini_MHSF, % ini_MHSD	
		}
		IsCursorPressed := false
		return
	}
	if (PressedKey > MenuMax) or (PressedKey = 0)
		return

	GuiControlGet, Temp1, , % %DynVarRef%
	if (ini_TTCn = 4)
		WinActivate, % "ahk_id" PreviousWindowID
	F_DestroyTriggerstringTips(ini_TTCn)
	; OutputDebug, % "Temp1:" . Temp1 . "|" . "v_Qinput:" . v_Qinput . "|" . "v_InputString:" . v_InputString . "|" . "`n"
	IsCursorPressed 	:= false
, 	IntCnt 			:= 0
, 	MenuMax 			:= 0
	F_BackFeed(Temp1)
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_BackFeed(MyInput)
{
	global 	;assume-global mode of operation
	if (v_Qinput != "")
		SendInput, % "{BackSpace" . A_Space . StrLen(v_Qinput) . "}"
	else
		SendInput, % "{BackSpace" . A_Space . StrLen(v_InputString) . "}"
	Hotstring("Reset")
	MyInput 		:= F_ConvertEscapeSequences(MyInput)
,	MyInput 		:= F_ConvertEscapeSequences2(MyInput)
,	v_InputString 	:= ""
	SendLevel, 	% ini_SendLevel	;to backtrigger it must be higher than the input level of the hotstrings
	SendInput,	% MyInput			;If a script other than the one executing SendInput has a low-level keyboard hook installed, SendInput automatically reverts to SendEvent 
	SendLevel, 	0
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_LoadConfiguration()
{
	global ;assume-global mode

	ini_SendLevel				:= 1			;SendLevel by default
	IniRead, ini_SendLevel, 					% ini_HADConfig, Configuration, SendLevel, 				% A_Space	;To store a blank value (empty string), specify % A_Space.
	if (ini_SendLevel = "")	;thanks to this trick existing Config.ini do not have to be erased if new configuration parameters are added.
	{
		ini_SendLevel := 1
		IniWrite, % ini_SendLevel, % ini_HADConfig, Configuration, SendLevel
	}

	ini_MinSendLevel			:= 1			;MinSendLevel (InputHook) by default
	IniRead, ini_MinSendLevel, 				% ini_HADConfig, Configuration, MinSendLevel,			% A_Space	;To store a blank value (empty string), specify % A_Space.
	if (ini_MinSendLevel = "")	;thanks to this trick existing Config.ini do not have to be erased if new configuration parameters are added.
	{
		ini_MinSendLevel := 1
		IniWrite, % ini_MinSendLevel, % ini_HADConfig, Configuration, MinSendLevel
	}

	ini_CPDelay 				:= 300		;1-1000 [ms], default: 300
	IniRead, ini_CPDelay, 					% ini_HADConfig, Configuration, ClipBoardPasteDelay,		% A_Space	;To store a blank value (empty string), specify % A_Space.
	if (ini_CPDelay = "")	;thanks to this trick existing Config.ini do not have to be erased if new configuration parameters are added.
	{
		ini_CPDelay := 300
		IniWrite, % ini_CPDelay, % ini_HADConfig, Configuration, ClipBoardPasteDelay 
	}

	ini_HotstringUndo			:= true
	IniRead, ini_HotstringUndo,				% ini_HADConfig, Configuration, HotstringUndo,			% A_Space	;To store a blank value (empty string), specify % A_Space.
	if (ini_HotstringUndo = "")	;thanks to this trick existing Config.ini do not have to be erased if new configuration parameters are added.
	{
		ini_HotstringUndo 		:= true
		Iniwrite, % ini_HotstringUndo, % ini_HADConfig, Configuration, HotstringUndo
	}
	ini_ShowIntro				:= true
	IniRead, ini_ShowIntro,					% ini_HADConfig, Configuration, ShowIntro,				% A_Space	;To store a blank value (empty string), specify % A_Space.
	if (ini_ShowIntro = "")	;thanks to this trick existing Config.ini do not have to be erased if new configuration parameters are added.
	{
		ini_ShowIntro 			:= true
		Iniwrite, % ini_ShowIntro, % ini_HADConfig, Configuration, ShowIntro
	}
	ini_HK_Main				:= c_dHK_CallGUI	;set default (d) hotkey (HK) for calling main application GUI 
	IniRead, ini_HK_Main,					% ini_HADConfig, Configuration, HK_Main,				% A_Space	;To store a blank value (empty string), specify % A_Space.
	if (ini_HK_Main = "")	;thanks to this trick existing Config.ini do not have to be erased if new configuration parameters are added.
	{
		ini_HK_Main 			:= c_dHK_CallGUI
		IniWrite, % ini_HK_Main, % ini_HADConfig, Configuration, HK_Main
	}
	if (ini_HK_Main != "none")
	{
		#If v_SilentMode != "l"
		Hotkey, If, v_SilentMode != "l" 
		Hotkey, % ini_HK_Main, F_GUIInit, On
		Hotkey, If			;To turn off context sensitivity (that is, to make subsequently-created hotkeys work in all windows)
	}
	
	ini_HK_IntoEdit			:= c_dHK_CopyClip	;set default (d) hotkey (HK) for copying content of future hotstring
	IniRead, ini_HK_IntoEdit,				% ini_HADConfig, Configuration, HK_IntoEdit,				% A_Space	;To store a blank value (empty string), specify % A_Space.
	if (ini_HK_IntoEdit = "")	;thanks to this trick existing Config.ini do not have to be erased if new configuration parameters are added.
	{
		ini_HK_IntoEdit := c_dHK_CopyClip
		IniWrite, % ini_HK_IntoEdit, % ini_HADConfig, Configuration, HK_IntoEdit
	}
	
	ini_HK_UndoLH				:= c_dHK_UndoLH	;set default (d) hotkey (HK) for F_Undo
	IniRead, ini_HK_UndoLH,					% ini_HADConfig, Configuration, HK_UndoLH,				% A_Space	;To store a blank value (empty string), specify % A_Space.
	if (ini_HK_UndoLH = "")		;thanks to this trick existing Config.ini do not have to be erased if new configuration parameters are added.
	{
		ini_HK_UndoLH 			:= c_dHK_UndoLH	;set default (d) hotkey (HK) for F_Undo
		IniWrite, % ini_HK_UndoLH, % ini_HADConfig, Configuration, HK_UndoLH
	}
	if (ini_HK_UndoLH != "none")
		Hotkey, % ini_HK_UndoLH, F_Undo, On

	ini_HK_ToggleTt			:= c_dHK_ToggleTt	; c (constant), d (default), HK = HotKey, ToggleTt = Toggle Triggerstring tips
	IniRead, ini_HK_ToggleTt,				% ini_HADConfig, Configuration, HK_ToggleTt,				% A_Space	;To store a blank value (empty string), specify % A_Space.
	if (ini_HK_ToggleTt = "")	;thanks to this trick existing Config.ini do not have to be erased if new configuration parameters are added.
	{
		ini_HK_ToggleTt 		:= c_dHK_ToggleTt
		IniWrite, % ini_HK_ToggleTt, % ini_HADConfig, Configuration, HK_ToggleTt
	}
	if (ini_HK_ToggleTt != "none")
     {
		Hotkey, % ini_HK_ToggleTt, F_ToggleTt, On
          F_UpdateStateOfLockKeys(ini_HK_ToggleTt, ini_TTTtEn)
     }
;#c/* commercial only beginning
;#c*/ commercial only end	
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_GuiEvents(OneTime*)
{
	global ;assume-global mode
	local Window1X := 0, Window1Y := 0, Window1W := 0, Window1H := 0, Window2X := 0, Window2Y := 0, Window2W := 0, Window2H := 0, NewWinPosX := 0, NewWinPosY := 0
	if (OneTime[3])	;this is a trick: if F_GuiEvents is called from menu, its parameter is Array of 3 elements.
		Gui, % A_Gui . ": +Disabled"	;in order to block user interaction with background window
	F_GuiEvents_CreateObjects()
	F_GuiEvents_DetermineConstraints()
	F_GuiEvents_LoadValues()	;load values to guicontrols
	F_EvBH_R1R2()
	F_EvBH_R3R4()
	F_EvBH_R7R8()
	F_EvBH_S1()
	F_EvBH_S2()
	F_EvBH_S3()
	F_EvMH_R3R4()
	F_EvMH_S1()
	F_EvMH_S2()
	F_EvUH_R1R2()
	F_EvUH_R3R4()
	F_EvUH_R7R8()
	F_EvUH_S1()
	F_EvUH_S2()
	F_EvUH_S3()
	F_EvTt_R1R2()
	F_EvTt_R3R4()
	F_EvTt_S1()
	F_EvTt_S2()
	F_EvSM_R1R2()
;#c/* commercial only beginning	
;#c*/ commercial only end
	F_EvTab3(OneTime[1])	;OneTime is used
	
	if (OneTime[3])
	{
		if (WinExist("ahk_id" . HS3GuiHwnd) or WinExist("ahk_id" . HS4GuiHwnd))
			WinGetPos, Window1X, Window1Y, Window1W, Window1H, A
		Gui, GuiEvents: Show, Hide
		
		DetectHiddenWindows, On
		WinGetPos, Window2X, Window2Y, Window2W, Window2H, % "ahk_id" . GuiEventsHwnd
		DetectHiddenWindows, Off
		if (Window1W)
		{
			NewWinPosX := Round(Window1X + (Window1W / 2) - (Window2W / 2))
,			NewWinPosY := Round(Window1Y + (Window1H / 2) - (Window2H / 2))
			Gui, GuiEvents: Show, % "AutoSize" . A_Space . "x" . NewWinPosX . A_Space . "y" . NewWinPosY, % A_ScriptName . ":" . A_Space . TransA["Events: styling"]
		}
		else
			Gui, GuiEvents: Show, Center AutoSize, % A_ScriptName . ":" . A_Space . TransA["Events: styling"]
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_GuiEvents_CreateObjects()
{
	global ;assume-global mode
	local TickInterval := (32767 - 37) / 9
	;1. Prepare Gui
	Gui, GuiEvents: New, 	-Resize +HwndGuiEventsHwnd +Owner +OwnDialogs -MaximizeBox -MinimizeBox	;+OwnDialogs: for tooltips.
	Gui, GuiEvents: Margin,	% c_xmarg, % c_ymarg
	Gui,	GuiEvents: Color,	% c_WindowColor, % c_ControlColor
	Gui,	GuiEvents: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, 			% c_FontType
	Gui, GuiEvents: Add,	Tab3, vEvTab3 gF_EvTab3,						% TransA["Basic hotstring is triggered"] . "|" 
																. TransA["Menu hotstring is triggered"] . "|" 
																. TransA["Undid the last hotstring"] . "|" 
																. TransA["Triggerstring tips"] . "||" 
;#c/* commercial only beginning
;#c*/ commercial only end	
																. TransA["Static triggerstring / hotstring menus"] . "|"
	Gui, GuiEvents: Tab, 											% TransA["Basic hotstring is triggered"]
	Gui, GuiEvents: Font,	% "s" . c_FontSize . A_Space . "bold" . A_Space . "c" . c_FontColor, % c_FontType
	Gui, GuiEvents: Add,	Text, 	HwndIdEvBH_T1,						% TransA["Tooltip enable"] . ":"
	Gui, GuiEvents: Font,	% "s" . c_FontSize + 2 . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, GuiEvents: Add,	Text, 	HwndIdEvBH_T2, 					ⓘ
	T_TooltipEnable := func("F_ShowLongTooltip").bind(TransA["T_TooltipEnable"])
	GuiControl, +g, % IdEvBH_T2, % T_TooltipEnable
	Gui, GuiEvents: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, % c_FontType
	Gui, GuiEvents: Add,	Radio,	HwndIdEvBH_R1 vEvBH_R1R2 gF_EvBH_R1R2,	% TransA["yes"]
	Gui, GuiEvents: Add,	Radio, 	HwndIdEvBH_R2 gF_EvBH_R1R2,			% TransA["no"]
	Gui, GuiEvents: Add,	Text, 	HwndIdEvBH_T15 0x7					; horizontal line → black
	Gui, GuiEvents: Font,	% "s" . c_FontSize . A_Space . "bold" . A_Space . "c" . c_FontColor, % c_FontType
	Gui, GuiEvents: Add,	Text,	HwndIdEvBH_T3,						% TransA["Tooltip timeout"] . ":"
	Gui, GuiEvents: Font,	% "s" . c_FontSize + 2 . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, GuiEvents: Add,	Text,	HwndIdEvBH_T4,						ⓘ
	T_TooltipTimeout := func("F_ShowLongTooltip").bind(TransA["T_TooltipTimeout"])
	GuiControl, +g, % IdEvBH_T4, % T_TooltipTimeout
	Gui, GuiEvents: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, % c_FontType
	Gui, GuiEvents: Add,	Text,	HwndIdEvBH_T5,						% TransA["Finite timeout?"]
	Gui, GuiEvents: Add,	Radio,	HwndIdEvBH_R3 vEvBH_R3R4 gF_EvBH_R3R4,	% TransA["yes"]
	Gui, GuiEvents: Add,	Radio,	HwndIdEvBH_R4 gF_EvBH_R3R4,			% TransA["no"]
	Gui, GuiEvents: Add,	Text,	HwndIdEvBH_T6,						% TransA["If not finite, define tooltip timeout"] . ":"
	Gui, GuiEvents: Add, 	Slider, 	HwndIdEvBH_S1 vEvBH_S1 gF_EvBH_S1 Line1 Page500 Range500-10000 TickInterval500 ToolTipBottom Buddy1EvBH_S1 ;, % EvBH_S1	
	Gui, GuiEvents: Add,	Text,	HwndIdEvBH_T7,						% TransA["Timeout value [ms]"] . ":" . A_Space . 10000
	Gui, GuiEvents: Add,	Text, 	HwndIdEvBH_T16 0x7					; horizontal line → black
	Gui, GuiEvents: Font,	% "s" . c_FontSize . A_Space . "bold" . A_Space . "c" . c_FontColor, % c_FontType
	Gui, GuiEvents: Add,	Text,	HwndIdEvBH_T8,						% TransA["Tooltip position"] . ":"
	Gui, GuiEvents: Font,	% "s" . c_FontSize + 2 . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, GuiEvents: Add,	Text,	HwndIdEvBH_T9,						ⓘ
	T_TooltipPosition := func("F_ShowLongTooltip").bind(TransA["T_TooltipPosition"])
	GuiControl, +g, % IdEvBH_T9, % T_TooltipPosition
	Gui, GuiEvents: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, % c_FontType
	Gui, GuiEvents: Add,	Radio,	HwndIdEvBH_R5 vEvBH_R5R6,			% TransA["caret"]
	Gui, GuiEvents: Add,	Radio,	HwndIdEvBH_R6,						% TransA["cursor"]
	Gui, GuiEvents: Add,	Text, 	HwndIdEvBH_T17 0x7					; horizontal line → black
	Gui, GuiEvents: Font,	% "s" . c_FontSize . A_Space . "bold" . A_Space . "c" . c_FontColor, % c_FontType
	Gui, GuiEvents: Add,	Text,	HwndIdEvBH_T10,					% TransA["Sound enable"] . "?"
	Gui, GuiEvents: Font,	% "s" . c_FontSize + 2 . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, GuiEvents: Add,	Text,	HwndIdEvBH_T11,					ⓘ
	T_SoundEnable := func("F_ShowLongTooltip").bind(TransA["T_SoundEnable"])
	GuiControl, +g, % IdEvBH_T11, % T_SoundEnable
	Gui, GuiEvents: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, % c_FontType
	Gui, GuiEvents: Add,	Radio,	HwndIdEvBH_R7 vEvBH_R7R8 gF_EvBH_R7R8,	% TransA["yes"]
	Gui, GuiEvents: Add,	Radio,	HwndIdEvBH_R8 gF_EvBH_R7R8,			% TransA["no"]
	Gui, GuiEvents: Add,	Text,	HwndIdEvBH_T12,					% TransA["If sound is enabled, define it"]	. ":"
	Gui, GuiEvents: Add, 	Slider, 	HwndIdEvBH_S2 vEvBH_S2 gF_EvBH_S2 Line1 Page50 Range37-32767 TickInterval%TickInterval% ToolTipBottom Buddy1EvBH_S2 ;, % EvBH_S2
	Gui, GuiEvents: Add, 	Text, 	HwndIdEvBH_T13, 					% TransA["Sound frequency"] . ":" . A_Space . "32768"
	Gui, GuiEvents: Add, 	Slider, 	HwndIdEvBH_S3 vEvBH_S3 gF_EvBH_S3 Line1 Page50 Range50-2000 TickInterval50 ToolTipBottom Buddy1EvBH_S3 ;, % EvBH_S3
	Gui, GuiEvents: Add, 	Text, 	HwndIdEvBH_T14, 					% TransA["Sound duration [ms]"] . ":" . A_Space . "2000"
	Gui, GuiEvents: Add, 	Button, 	HwndIdEvBH_B1 gF_EvBH_B1,			% TransA["Tooltip test"]
	Gui, GuiEvents: Add, 	Button, 	HwndIdEvBH_B2 gF_EvBH_B2,			% TransA["Sound test"]
	Gui, GuiEvents: Add,	Button,	HwndIdEvBH_B3 gF_EvBH_B3 +Default,		% TransA["Apply"]
	Gui, GuiEvents: Add,	Button,	HwndIdEvBH_B4 gF_EvBH_B4,			% TransA["Close"]
	Gui, GuiEvents: Add,	Button,	HwndIdEvBH_B5 gF_EvBH_B5,			% TransA["Cancel"]
	
	Gui, GuiEvents: Tab, 											% TransA["Menu hotstring is triggered"]
	Gui, GuiEvents: Font,	% "s" . c_FontSize . A_Space . "bold" . A_Space . "c" . c_FontColor, % c_FontType
	Gui, GuiEvents: Add,	Text,	HwndIdEvMH_T1,						% TransA["Menu position"] . ":"
	Gui, GuiEvents: Font,	% "s" . c_FontSize + 2 . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, GuiEvents: Add,	Text,	HwndIdEvMH_T2,						ⓘ
	T_HMenuPosition := func("F_ShowLongTooltip").bind(TransA["T_HMenuPosition"])
	GuiControl, +g, % IdEvMH_T2, % T_HMenuPosition
	Gui, GuiEvents: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, % c_FontType
	Gui, GuiEvents: Add,	Radio,	HwndIdEvMH_R1 vEvMH_R1R2,			% TransA["caret"]
	Gui, GuiEvents: Add,	Radio,	HwndIdEvMH_R2,						% TransA["cursor"]
	Gui, GuiEvents: Add,	Text, 	HwndIdEvMH_T3 0x7					; horizontal line → black
	Gui, GuiEvents: Font,	% "s" . c_FontSize . A_Space . "bold" . A_Space . "c" . c_FontColor, % c_FontType
	Gui, GuiEvents: Add,	Text,	HwndIdEvMH_T4,						% TransA["Sound enable"] . "?"
	Gui, GuiEvents: Font,	% "s" . c_FontSize + 2 . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, GuiEvents: Add,	Text,	HwndIdEvMH_T5,						ⓘ
	T_SoundEnable := func("F_ShowLongTooltip").bind(TransA["T_SoundEnable"])
	GuiControl, +g, % IdEvMH_T5, % T_SoundEnable
	Gui, GuiEvents: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, % c_FontType
	Gui, GuiEvents: Add,	Radio,	HwndIdEvMH_R3 vEvMH_R3R4 gF_EvMH_R3R4,	% TransA["yes"]
	Gui, GuiEvents: Add,	Radio,	HwndIdEvMH_R4 gF_EvMH_R3R4,			% TransA["no"]
	Gui, GuiEvents: Add,	Text,	HwndIdEvMH_T6,						% TransA["If sound is enabled, define it"]	. ":"
	Gui, GuiEvents: Add, 	Slider, 	HwndIdEvMH_S1 vEvMH_S1 gF_EvMH_S1 Line1 Page50 Range37-32767 TickInterval%TickInterval% ToolTipBottom Buddy1EvMH_S1 ;, % EvMH_S1
	Gui, GuiEvents: Add, 	Text, 	HwndIdEvMH_T7, 					% TransA["Sound frequency"] . ":" . A_Space . "32768"
	Gui, GuiEvents: Add, 	Slider, 	HwndIdEvMH_S2 vEvMH_S2 gF_EvMH_S2 Line1 Page50 Range50-2000 TickInterval50 ToolTipBottom Buddy1EvMH_S2 ;, % EvMH_S2
	Gui, GuiEvents: Add, 	Text, 	HwndIdEvMH_T8, 					% TransA["Sound duration [ms]"] . ":" . A_Space . "2000"
	Gui, GuiEvents: Add, 	Button, 	HwndIdEvMH_B1 gF_EvMH_B1,			% TransA["Sound test"]
	Gui, GuiEvents: Add,	Button,	HwndIdEvMH_B2 gF_EvMH_B2 +Default,		% TransA["Apply"]
	Gui, GuiEvents: Add,	Button,	HwndIdEvMH_B3 gF_EvMH_B3,			% TransA["Close"]
	Gui, GuiEvents: Add,	Button,	HwndIdEvMH_B4 gF_EvMH_B4,			% TransA["Cancel"]
	
	Gui, GuiEvents: Tab,											%  TransA["Undid the last hotstring"]
	Gui, GuiEvents: Font,	% "s" . c_FontSize . A_Space . "bold" . A_Space . "c" . c_FontColor, % c_FontType
	Gui, GuiEvents: Add,	Text, 	HwndIdEvUH_T1,						% TransA["Tooltip enable"] . ":"
	Gui, GuiEvents: Font,	% "s" . c_FontSize + 2 . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, GuiEvents: Add,	Text, 	HwndIdEvUH_T2, 					ⓘ
	T_TooltipEnable := func("F_ShowLongTooltip").bind(TransA["T_TooltipEnable"])
	GuiControl, +g, % IdEvUH_T2, % T_TooltipEnable
	Gui, GuiEvents: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, % c_FontType
	Gui, GuiEvents: Add,	Radio,	HwndIdEvUH_R1 vEvUH_R1R2 gF_EvUH_R1R2,	% TransA["yes"]
	Gui, GuiEvents: Add,	Radio, 	HwndIdEvUH_R2 gF_EvUH_R1R2,			% TransA["no"]
	Gui, GuiEvents: Add,	Text, 	HwndIdEvUH_T15 0x7					; horizontal line → black
	Gui, GuiEvents: Font,	% "s" . c_FontSize . A_Space . "bold" . A_Space . "c" . c_FontColor, % c_FontType
	Gui, GuiEvents: Add,	Text,	HwndIdEvUH_T3,						% TransA["Tooltip timeout"] . ":"
	Gui, GuiEvents: Font,	% "s" . c_FontSize + 2 . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, GuiEvents: Add,	Text,	HwndIdEvUH_T4,						ⓘ
	T_TooltipTimeout := func("F_ShowLongTooltip").bind(TransA["T_TooltipTimeout"])
	GuiControl, +g, % IdEvUH_T4, % T_TooltipTimeout
	Gui, GuiEvents: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, % c_FontType
	Gui, GuiEvents: Add,	Text,	HwndIdEvUH_T5,						% TransA["Finite timeout?"]
	Gui, GuiEvents: Add,	Radio,	HwndIdEvUH_R3 vEvUH_R3R4 gF_EvUH_R3R4,	% TransA["yes"]
	Gui, GuiEvents: Add,	Radio,	HwndIdEvUH_R4 gF_EvUH_R3R4,			% TransA["no"]
	Gui, GuiEvents: Add,	Text,	HwndIdEvUH_T6,						% TransA["If not finite, define tooltip timeout"] . ":"
	Gui, GuiEvents: Add, 	Slider, 	HwndIdEvUH_S1 vEvUH_S1 gF_EvUH_S1 Line1 Page500 Range500-10000 TickInterval500 ToolTipBottom Buddy1EvUH_S1 ;, % EvUH_S1
	Gui, GuiEvents: Add,	Text,	HwndIdEvUH_T7,						% TransA["Timeout value [ms]"] . ":" . A_Space . 10000
	Gui, GuiEvents: Add,	Text, 	HwndIdEvUH_T16 0x7					; horizontal line → black
	Gui, GuiEvents: Font,	% "s" . c_FontSize . A_Space . "bold" . A_Space . "c" . c_FontColor, % c_FontType
	Gui, GuiEvents: Add,	Text,	HwndIdEvUH_T8,						% TransA["Tooltip position"] . ":"
	Gui, GuiEvents: Font,	% "s" . c_FontSize + 2 . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, GuiEvents: Add,	Text,	HwndIdEvUH_T9,						ⓘ
	T_TooltipPosition := func("F_ShowLongTooltip").bind(TransA["T_TooltipPosition"])
	GuiControl, +g, % IdEvUH_T9, % T_TooltipPosition
	Gui, GuiEvents: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, % c_FontType
	Gui, GuiEvents: Add,	Radio,	HwndIdEvUH_R5 vEvUH_R5R6,			% TransA["caret"]
	Gui, GuiEvents: Add,	Radio,	HwndIdEvUH_R6,						% TransA["cursor"]
	Gui, GuiEvents: Add,	Text, 	HwndIdEvUH_T17 0x7					; horizontal line → black
	Gui, GuiEvents: Font,	% "s" . c_FontSize . A_Space . "bold" . A_Space . "c" . c_FontColor, % c_FontType
	Gui, GuiEvents: Add,	Text,	HwndIdEvUH_T10,					% TransA["Sound enable"] . "?"
	Gui, GuiEvents: Font,	% "s" . c_FontSize + 2 . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, GuiEvents: Add,	Text,	HwndIdEvUH_T11,					ⓘ
	T_SoundEnable := func("F_ShowLongTooltip").bind(TransA["T_SoundEnable"])
	GuiControl, +g, % IdEvUH_T11, % T_SoundEnable
	Gui, GuiEvents: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, % c_FontType
	Gui, GuiEvents: Add,	Radio,	HwndIdEvUH_R7 vEvUH_R7R8 gF_EvUH_R7R8,	% TransA["yes"]
	Gui, GuiEvents: Add,	Radio,	HwndIdEvUH_R8 gF_EvUH_R7R8,			% TransA["no"]
	Gui, GuiEvents: Add,	Text,	HwndIdEvUH_T12,					% TransA["If sound is enabled, define it"]	. ":"
	Gui, GuiEvents: Add, 	Slider, 	HwndIdEvUH_S2 vEvUH_S2 gF_EvUH_S2 Line1 Page50 Range37-32767 TickInterval%TickInterval% ToolTipBottom Buddy1EvUH_S2 ;, % EvUH_S2
	Gui, GuiEvents: Add, 	Text, 	HwndIdEvUH_T13, 					% TransA["Sound frequency"] . ":" . A_Space . "32768"
	Gui, GuiEvents: Add, 	Slider, 	HwndIdEvUH_S3 vEvUH_S3 gF_EvUH_S3 Line1 Page50 Range50-2000 TickInterval50 ToolTipBottom Buddy1EvUH_S3 ;, % EvUH_S3
	Gui, GuiEvents: Add, 	Text, 	HwndIdEvUH_T14, 					% TransA["Sound duration [ms]"] . ":" . A_Space . "2000"
	Gui, GuiEvents: Add, 	Button, 	HwndIdEvUH_B1 gF_EvUH_B1,			% TransA["Tooltip test"]
	Gui, GuiEvents: Add, 	Button, 	HwndIdEvUH_B2 gF_EvUH_B2,			% TransA["Sound test"]	
	Gui, GuiEvents: Add,	Button,	HwndIdEvUH_B3 gF_EvUH_B3 +Default,		% TransA["Apply"]	
	Gui, GuiEvents: Add,	Button,	HwndIdEvUH_B4 gF_EvUH_B4,			% TransA["Close"]
	Gui, GuiEvents: Add,	Button,	HwndIdEvUH_B5 gF_EvUH_B5,			% TransA["Cancel"]
	
	Gui, GuiEvents: Tab,											%  TransA["Triggerstring tips"]
	Gui, GuiEvents: Font,	% "s" . c_FontSize . A_Space . "bold" . A_Space . "c" . c_FontColor, % c_FontType
	Gui, GuiEvents: Add,	Text, 	HwndIdEvTt_T1,						% TransA["Tooltip enable"] . ":"
	Gui, GuiEvents: Font,	% "s" . c_FontSize + 2 . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, GuiEvents: Add,	Text, 	HwndIdEvTt_T2, 					ⓘ
	T_TriggerstringTips := func("F_ShowLongTooltip").bind(TransA["T_TriggerstringTips"])
	GuiControl, +g, % IdEvTt_T2, % T_TriggerstringTips
	Gui, GuiEvents: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, % c_FontType
	Gui, GuiEvents: Add,	Radio,	HwndIdEvTt_R1 vEvTt_R1R2 gF_EvTt_R1R2,	% TransA["yes"]
	Gui, GuiEvents: Add,	Radio, 	HwndIdEvTt_R2 gF_EvTt_R1R2,			% TransA["no"]	
	Gui, GuiEvents: Add,	Text, 	HwndIdEvTt_T3 0x7					; horizontal line → black
	Gui, GuiEvents: Font,	% "s" . c_FontSize . A_Space . "bold" . A_Space . "c" . c_FontColor, % c_FontType
	Gui, GuiEvents: Add,	Text,	HwndIdEvTt_T4,						% TransA["Tooltip timeout"] . ":"
	Gui, GuiEvents: Font,	% "s" . c_FontSize + 2 . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, GuiEvents: Add,	Text,	HwndIdEvTt_T5,						ⓘ
	T_TooltipTimeout := func("F_ShowLongTooltip").bind(TransA["T_TooltipTimeout"])	
	GuiControl, +g, % IdEvTt_T5, % T_TooltipTimeout
	Gui, GuiEvents: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, % c_FontType
	Gui, GuiEvents: Add,	Text,	HwndIdEvTt_T6,						% TransA["Finite timeout?"]
	Gui, GuiEvents: Add,	Radio,	HwndIdEvTt_R3 vEvTt_R3R4 gF_EvTt_R3R4,	% TransA["yes"]
	Gui, GuiEvents: Add,	Radio,	HwndIdEvTt_R4 gF_EvTt_R3R4,			% TransA["no"]
	Gui, GuiEvents: Add,	Text,	HwndIdEvTt_T7,						% TransA["If not finite, define tooltip timeout"] . ":"
	Gui, GuiEvents: Add, 	Slider, 	HwndIdEvTt_S1 vEvTt_S1 gF_EvTt_S1 Line1 Page500 Range500-10000 TickInterval500 ToolTipBottom Buddy1EvTt_S1 ;, % EvTt_S1
	Gui, GuiEvents: Add,	Text,	HwndIdEvTt_T8,						% TransA["Timeout value [ms]"] . ":" . A_Space . 10000
	Gui, GuiEvents: Add,	Text, 	HwndIdEvTt_T9 0x7					; horizontal line → black
	Gui, GuiEvents: Font,	% "s" . c_FontSize . A_Space . "bold" . A_Space . "c" . c_FontColor, % c_FontType
	Gui, GuiEvents: Add,	Text,	HwndIdEvTt_T10,					% TransA["Tooltip position"] . ":"
	Gui, GuiEvents: Font,	% "s" . c_FontSize + 2 . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, GuiEvents: Add,	Text,	HwndIdEvTt_T11,					ⓘ
	T_TooltipPosition := func("F_ShowLongTooltip").bind(TransA["T_TooltipPosition"])
	GuiControl, +g, % IdEvTt_T11, % T_TooltipPosition
	Gui, GuiEvents: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, % c_FontType
	Gui, GuiEvents: Add,	Radio,	HwndIdEvTt_R5 vEvTt_R5R6,			% TransA["caret"]
	Gui, GuiEvents: Add,	Radio,	HwndIdEvTt_R6,						% TransA["cursor"]
	Gui, GuiEvents: Add,	Text, 	HwndIdEvTt_T12 0x7					; horizontal line → black
	Gui, GuiEvents: Font,	% "s" . c_FontSize . A_Space . "bold" . A_Space . "c" . c_FontColor, % c_FontType
	Gui, GuiEvents: Add,	Text,	HwndIdEvTt_T13,					% TransA["Sorting order"] . ":"
	Gui, GuiEvents: Font,	% "s" . c_FontSize + 2 . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, GuiEvents: Add,	Text,	HwndIdEvTt_T14,					ⓘ
	T_TtSortingOrder := func("F_ShowLongTooltip").bind(TransA["T_TtSortingOrder"])
	GuiControl, +g, % IdEvTt_T14, % T_TtSortingOrder
	Gui, GuiEvents: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, % c_FontType
	Gui, GuiEvents: Add,	Checkbox, HwndIdEvTt_C1 vEvTt_C1,				% TransA["Alphabetically"]
	Gui, GuiEvents: Add,	Checkbox, HwndIdEvTt_C2 vEvTt_C2,				% TransA["By length"]
	Gui, GuiEvents: Font,	% "s" . c_FontSize . A_Space . "bold" . A_Space . "c" . c_FontColor, % c_FontType
	Gui, GuiEvents: Add,	Text, 	HwndIdEvTt_T15 0x7					; horizontal line → black
	Gui, GuiEvents: Add,	Text, 	HwndIdEvTt_T16,					% TransA["Max. no. of shown tips"] . ":"
	Gui, GuiEvents: Font,	% "s" . c_FontSize + 2 . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, GuiEvents: Add,	Text,	HwndIdEvTt_T17,					ⓘ
	T_TtMaxNoOfTips := func("F_ShowLongTooltip").bind(TransA["T_TtMaxNoOfTips"])
	GuiControl, +g, % IdEvTt_T17, % T_TtMaxNoOfTips
	Gui, GuiEvents: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, % c_FontType
	Gui, GuiEvents: Add,	Slider,	HwndIdEvTt_S2 vEvTt_S2 gF_EvTt_S2 Line1 Page1 Range1-25 TickInterval1 ToolTipBottom Buddy1EvTt_S2 ;, % EvTt_S2
	Gui, GuiEvents: Add,	Text,	HwndIdEvTt_T18,					20
	Gui, GuiEvents: Add,	Text, 	HwndIdEvTt_T19 0x7					; horizontal line → black
	Gui, GuiEvents: Font,	% "s" . c_FontSize . A_Space . "bold" . A_Space . "c" . c_FontColor, % c_FontType
	Gui, GuiEvents: Add,	Text,	HwndIdEvTt_T20,					% TransA["Tips are shown after no. of characters"] . ":"
	Gui, GuiEvents: Font,	% "s" . c_FontSize + 2 . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, GuiEvents: Add,	Text,	HwndIdEvTt_T21,					ⓘ
	T_TtNoOfChars := func("F_ShowLongTooltip").bind(TransA["T_TtNoOfChars"])
	GuiControl, +g, % IdEvTt_T21, % T_TtNoOfChars
	Gui, GuiEvents: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, % c_FontType
	Gui, GuiEvents: Add,	DropDownList, HwndIdEvTt_DDL1 vEvTt_DDL1 AltSubmit,		1|2|3|4|5	
	Gui, GuiEvents: Add,	Text, 	HwndIdEvTt_T22 0x7					; horizontal line → black
	Gui, GuiEvents: Font,	% "s" . c_FontSize . A_Space . "bold" . A_Space . "c" . c_FontColor, % c_FontType
	Gui, GuiEvents: Add,	Text,	HwndIdEvTt_T23,					% TransA["Composition of triggerstring tips"] . ":"
	Gui, GuiEvents: Font,	% "s" . c_FontSize + 2 . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType	
	Gui, GuiEvents: Add,	Text,	HwndIdEvTt_T24,					ⓘ
	T_TtComposition := func("F_ShowLongTooltip").bind(TransA["T_TtComposition"])
	GuiControl, +g, % IdEvTt_T24, % T_TtComposition
	Gui, GuiEvents: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, % c_FontType
	Gui, GuiEvents: Add,	DropDownList, HwndIdEvTt_DDL2 vEvTt_DDL2 AltSubmit, % TransA["Triggerstring tips"] . "|" . TransA["Triggerstring tips"] . A_Space . "+" . A_Space 
		. TransA["Triggers"] . "|" . TransA["Triggerstring tips"] . A_Space . "+" . A_Space . TransA["Triggers"] . A_Space . "+" . A_Space . TransA["Hotstrings"]
	Gui, GuiEvents: Add, 	Button, 	HwndIdEvTt_B1 gF_EvTt_B1,			% TransA["Tooltip test"]	
	Gui, GuiEvents: Add,	Button,	HwndIdEvTt_B2 gF_EvTt_B2 +Default,		% TransA["Apply"]
	Gui, GuiEvents: Add,	Button,	HwndIdEvTt_B3 gF_EvTt_B3,			% TransA["Close"]
	Gui, GuiEvents: Add,	Button,	HwndIdEvTt_B4 gF_EvTt_B4,			% TransA["Cancel"]
	
	Gui, GuiEvents: Add,	Text,	HwndIdEvTt_T25,					% TransA["Triggerstring tips"] . A_Space . "+" . A_Space . TransA["Triggers"] . A_Space . "+" . A_Space . TransA["Hotstrings"] ;fake text, just to measure its width, but unfortunately as it cannot be deleted, it has to be shifted somewhere
;#c/* commercial only beginning
;#c*/ commercial only end
	
	Gui, GuiEvents: Tab,											% TransA["Static triggerstring / hotstring menus"]
	Gui, GuiEvents: Font,	% "s" . c_FontSize . A_Space . "bold" . A_Space . "c" . c_FontColor, % c_FontType
	Gui, GuiEvents: Add,	Text, 	HwndIdEvSM_T1,						% TransA["Static triggerstring / hotstring menus"] . ":"
	Gui, GuiEvents: Font,	% "s" . c_FontSize + 2 . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, GuiEvents: Add,	Text, 	HwndIdEvSM_T2, 					ⓘ
	T_SMT2 := func("F_ShowLongTooltip").bind(TransA["T_SMT2"])
	GuiControl, +g, % IdEvSM_T2, % T_SMT2
	Gui, GuiEvents: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, % c_FontType
	Gui, GuiEvents: Add,	Radio,	HwndIdEvSM_R1 vEvSM_R1R2 gF_EvSM_R1R2,	% TransA["enable"]
	Gui, GuiEvents: Add,	Radio, 	HwndIdEvSM_R2 gF_EvSM_R1R2,			% TransA["disable"]	
	Gui, GuiEvents: Add, 	Button, 	HwndIdEvSM_B1 gF_EvSM_B1,			% TransA["Preview"]
	Gui, GuiEvents: Add,	Button,	HwndIdEvSM_B2 gF_EvSM_B2 +Default,		% TransA["Apply"]
	Gui, GuiEvents: Add,	Button,	HwndIdEvSM_B3 gF_EvSM_B3,			% TransA["Close"]
	Gui, GuiEvents: Add,	Button,	HwndIdEvSM_B4 gF_EvSM_B4,			% TransA["Cancel"]
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_CloseSubGui(WhatGuiToDestroy)
{
     global ;assume-global mode of operation
	if (WinExist("ahk_id" HS3GuiHwnd))
     {
		Gui, HS3: -Disabled 
          WinActivate, % "ahk_id" HS3GuiHwnd
     }
	if (WinExist("ahk_id" HS4GuiHwnd))
     {
		Gui, HS4: -Disabled	
          WinActivate, % "ahk_id" HS4GuiHwnd
     }
	Gui, % WhatGuiToDestroy . ":" . A_Space . "Destroy"
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EvTab3(OneTime*)
{
	global ;assume-global mode of operation
	static PreviousEvTab3 := ""
			, PreviousEvBH_R1R2 := "", PreviousEvBH_R3R4 := "", PreviousEvBH_R5R6 := "", PreviousEvBH_R7R8 := "", PreviousEvBH_S1 := "", PreviousEvBH_S2 := "", PreviousEvBH_S3 := ""
			, PreviousEvMH_R1R2 := "", PreviousEvMH_R3R4 := "", PreviousEvMH_S1 := "", PreviousEvMH_S2 := ""
			, PreviousEvUH_R1R2 := "", PreviousEvUH_R3R4 := "", PreviousEvUH_R5R6 := "", PreviousEvUH_R7R8 := "", PreviousEvUH_S1 := "", PreviousEvUH_S2 := "", PreviousEvUH_S3 := ""
			, PreviousEvTt_R1R2 := "", PreviousEvTt_R3R4 := "", PreviousEvTt_R5R6 := "", PreviousEvTt_C1 := "", PreviousEvTt_C2 := "", PreviousEvTt_S1 := "", PreviousEvTt_S2 := "", PreviousEvTt_DDL1 := "", PreviousEvTt_DDL2 := ""
;#c/* commercial only beginning
;#c*/ commercial only end
			, PreviousEvSM_R1R2 := ""
	;OutputDebug, % "OneTime[1]:" . A_Tab . OneTime[1]
	Gui, GuiEvents: Submit, NoHide	;Loads EvTab3 with current value 
	if (OneTime[1] = true)
	{
		PreviousEvTab3 := EvTab3
		, PreviousEvBH_R1R2 := EvBH_R1R2, PreviousEvBH_R3R4 := EvBH_R3R4, PreviousEvBH_R5R6 := EvBH_R5R6, PreviousEvBH_R7R8 := EvBH_R7R8, PreviousEvBH_S1 := EvBH_S1, PreviousEvBH_S2 := EvBH_S2, PreviousEvBH_S3 := EvBH_S3
		, PreviousEvMH_R1R2 := EvMH_R1R2, PreviousEvMH_R3R4 := EvMH_R3R4, PreviousEvMH_S1 := EvMH_S1, PreviousEvMH_S2 := EvMH_S1
		, PreviousEvUH_R1R2 := EvUH_R1R2, PreviousEvUH_R3R4 := EvUH_R3R4, PreviousEvUH_R5R6 := EvUH_R5R6, PreviousEvUH_R7R8 := EvUH_R7R8, PreviousEvUH_S1 := EvUH_S1, PreviousEvUH_S2 := EvUH_S2, PreviousEvUH_S3 := EvUH_S3
		, PreviousEvTt_R1R2 := EvTt_R1R2, PreviousEvTt_R3R4 := EvTt_R3R4, PreviousEvTt_R5R6 := EvTt_R5R6, PreviousEvTt_C1 := EvTt_C1, PreviousEvTt_C2 := EvTt_C2, PreviousEvTt_S1 := EvTt_S1, PreviousEvTt_S2 := EvTt_S2, PreviousEvTt_DDL1 := EvTt_DDL1, PreviousEvTt_DDL2 := EvTt_DDL2
;#c/* commercial only beginning		
;#c*/ commercial only end		
		, PreviousEvSM_R1R2 := EvSM_R1R2
		return
	}
	
	; OutputDebug, % "EvTab3:" . A_Tab . EvTab3 . A_Tab . "PreviousEvTab3" . A_Tab . PreviousEvTab3 . "`n"
	F_EvUpdateTab()
	if (EvTab3 != PreviousEvTab3)
	{
		Switch PreviousEvTab3
		{
			Case % TransA["Basic hotstring is triggered"]:
				if (EvBH_R1R2 != PreviousEvBH_R1R2) or (EvBH_R3R4 != PreviousEvBH_R3R4) or (EvBH_R5R6 != PreviousEvBH_R5R6) or (EvBH_R7R8 != PreviousEvBH_R7R8) or (EvBH_S1 != PreviousEvBH_S1) or (EvBH_S2 != PreviousEvBH_S2) or (EvBH_S3 != PreviousEvBH_S3)
				{
					MsgBox, 68, % SubStr(A_ScriptName, 1, -4) .  ":" . A_Space . TransA["warning"], % TransA["You've changed at least one configuration parameter, but didn't yet apply it."] 
						. A_Space . TransA["If you don't apply it, previous changes will be lost."]
						. "`n`n" . TransA["Do you wish to apply your changes?"]
					IfMsgBox, Yes
					{
						F_EvBH_B3()	;Apply changes
						F_EvUpdateTab()
					}
					IfMsgBox, No	;restore previous values to each GuiControl
					{
						if (EvBH_R1R2 != PreviousEvBH_R1R2)
						{
							Switch PreviousEvBH_R1R2	
							{
								Case 1: GuiControl, , % IdEvBH_R1, 1
								Case 2: GuiControl, , % IdEvBH_R2, 1
							}
						}
						if (EvBH_R3R4 != PreviousEvBH_R3R4)
						{
							Switch PreviousEvBH_R3R4
							{
								Case 1: GuiControl, , % IdEvBH_R3, 1
								Case 2: GuiControl, , % IdEvBH_R4, 1
							}
						}
						if (EvBH_R5R6 != PreviousEvBH_R5R6)
						{
							Switch PreviousEvBH_R5R6
							{
								Case 1: GuiControl, , % IdEvBH_R5, 1
								Case 2: GuiControl, , % IdEvBH_R6, 1
							}
						}
						if (EvBH_R7R8 != PreviousEvBH_R7R8)
						{
							Switch PreviousEvBH_R7R8
							{
								Case 1: GuiControl, , % IdEvBH_R7, 1
								Case 2: GuiControl, , % IdEvBH_R8, 1
							}
						}
						if (EvBH_S1 != PreviousEvBH_S1)
							GuiControl, , % IdEvBH_S1, % PreviousEvBH_S1	
						if (EvBH_S2 != PreviousEvBH_S2)
							GuiControl, , % IdEvBH_S2, % PreviousEvBH_S2
						if (EvBH_S3 != PreviousEvBH_S3)
							GuiControl, , % IdEvBH_S3, % PreviousEvBH_S3
					}
				}
				else
				{
					F_EvUpdateTab()
				}
				PreviousEvTab3 := EvTab3
			
			Case % TransA["Menu hotstring is triggered"]:
				if (EvMH_R1R2 != PreviousEvMH_R1R2) or (EvMH_R3R4 != PreviousEvMH_R3R4) or (EvMH_S1 != PreviousEvMH_S1) or (EvMH_S1 != PreviousEvMH_S2)
				{
					MsgBox, 68, % SubStr(A_ScriptName, 1, -4) .  ":" . A_Space . TransA["warning"], % TransA["You've changed at least one configuration parameter, but didn't yet apply it."] 
						. TransA["If you don't apply it, previous changes will be lost."]
						. "`n`n" . TransA["Do you wish to apply your changes?"]
					IfMsgBox, Yes
					{
						F_EvMH_B2()	;Apply changes
						F_EvUpdateTab()
					}
					IfMsgBox, No	;restore previous values to each GuiControl
					{
						if (EvMH_R1R2 != PreviousEvMH_R1R2)
						{
							Switch PreviousEvMH_R1R2
							{
								Case 1: GuiControl, , % IdEvMH_R1, 1
								Case 2: GuiControl, , % IdEvMH_R2, 1
							}
						}
						if (EvMH_R3R4 != PreviousEvMH_R3R4)
						{
							Switch PreviousEvMH_R3R4
							{
								Case 1: GuiControl, , % IdEvMH_R3, 1
								Case 2: GuiControl, , % IdEvMH_R4, 1
							}
						}
						if (EvMH_S1 != PreviousEvMH_S1)
							GuiControl, , % IdEvMH_S1, % PreviousEvMH_S1
						if (EvMH_S1 != PreviousEvMH_S2)
							GuiControl, , % IdEvMH_S2, % PreviousEvMH_S2
					}			
				}
				else
				{
					F_EvUpdateTab()
				}
				PreviousEvTab3 := EvTab3
			
			Case % TransA["Undid the last hotstring"]:
				if (EvUH_R1R2 != PreviousEvUH_R1R2) or (EvUH_R3R4 != PreviousEvUH_R3R4) or (EvUH_R5R6 != PreviousEvUH_R5R6) or (EvUH_R7R8 != PreviousEvUH_R7R8) or (EvUH_S1 != PreviousEvUH_S1) or (EvUH_S2 != PreviousEvUH_S2) or (EvUH_S3 != PreviousEvUH_S3)
				{
					MsgBox, 68, % SubStr(A_ScriptName, 1, -4) .  ":" . A_Space . TransA["warning"], % TransA["You've changed at least one configuration parameter, but didn't yet apply it."] 
						. TransA["If you don't apply it, previous changes will be lost."]
						. "`n`n" . TransA["Do you wish to apply your changes?"]
					IfMsgBox, Yes
					{
						F_EvUH_B3() ;Apply changes
						F_EvUpdateTab()
					}
					IfMsgBox, No	;restore previous values to each GuiControl
					{
						if (EvUH_R1R2 != PreviousEvUH_R1R2)
						{
							Switch PreviousEvUH_R1R2
							{
								Case 1: GuiControl, , % IdEvUH_R1, 1
								Case 2: GuiControl, , % IdEvUH_R2, 1
							}
						}
						if (EvUH_R3R4 != PreviousEvUH_R3R4)
						{
							Switch PreviousEvUH_R3R4
							{
								Case 1: GuiControl, , % IdEvUH_R3, 1
								Case 2: GuiControl, , % IdEvUH_R4, 1
							}
						}
						if (EvUH_R5R6 != PreviousEvUH_R5R6)
						{
							Switch PreviousEvUH_R5R6
							{
								Case 1: GuiControl, , % IdEvUH_R5, 1
								Case 2: GuiControl, , % IdEvUH_R6, 1
							}
						}
						if (EvUH_R7R8 != PreviousEvUH_R7R8)
						{
							Switch PreviousEvUH_R7R8
							{
								Case 1: GuiControl, , % IdEvUH_R7, 1
								Case 2: GuiControl, , % IdEvUH_R8, 1
							}
						}
						if (EvUH_S1 != PreviousEvUH_S1)
							GuiControl, , % IdEvUH_S1, % PreviousEvUH_S1
						if (EvUH_S2 != PreviousEvUH_S2)
							GuiControl, , % IdEvUH_S2, % PreviousEvUH_S2
						if (EvUH_S3 != PreviousEvUH_S3)
							GuiControl, , % IdEvUH_S3, % PreviousEvUH_S3
					}			
				}
				else
				{
					F_EvUpdateTab()
				}
				PreviousEvTab3 := EvTab3
			
			Case % TransA["Triggerstring tips"]:
				if (EvTt_R1R2 != PreviousEvTt_R1R2) or (EvTt_R3R4 != PreviousEvTt_R3R4) or (EvTt_R5R6 != PreviousEvTt_R5R6) or (EvTt_C1 != PreviousEvTt_C1) or (EvTt_C2 != PreviousEvTt_C2) or (EvTt_S1 != PreviousEvTt_S1) or (EvTt_S2 != PreviousEvTt_S2) or (EvTt_DDL1 != PreviousEvTt_DDL1) or (EvTt_DDL2 != PreviousEvTt_DDL2)
				{
					MsgBox, 68, % SubStr(A_ScriptName, 1, -4) .  ":" . A_Space . TransA["warning"], % TransA["You've changed at least one configuration parameter, but didn't yet apply it."] 
						. TransA["If you don't apply it, previous changes will be lost."]
						. "`n`n" . TransA["Do you wish to apply your changes?"]
					IfMsgBox, Yes
					{
						F_EvTt_B2() ;Apply changes
						F_EvUpdateTab()
					}
					IfMsgBox, No	;restore previous values to each GuiControl
					{
						if (EvTt_R1R2 != PreviousEvTt_R1R2)
						{
							Switch PreviousEvTt_R1R2
							{
								Case 1: GuiControl, , % IdEvTt_R1, 1
								Case 2: GuiControl, , % IdEvTt_R2, 1
							}
						}
						if (EvTt_R3R4 != PreviousEvTt_R3R4)
						{
							Switch PreviousEvTt_R3R4
							{
								Case 1: GuiControl, , % IdEvTt_R3, 1
								Case 2: GuiControl, , % IdEvTt_R4, 1
							}
						}
						if (EvTt_R5R6 != PreviousEvTt_R5R6)
						{
							Switch PreviousEvTt_R5R6
							{
								Case 1: GuiControl, , % IdEvTt_R5, 1
								Case 2: GuiControl, , % IdEvTt_R6, 1
							}
						}
						if (EvTt_C1 != PreviousEvTt_C1)
						{
							Switch PreviousEvTt_C1
							{
								Case 0: GuiControl, , % IdEvTt_C1, 0
								Case 1: GuiControl, , % IdEvTt_C1, 1
							}
						}
						if (EvTt_C2 != PreviousEvTt_C2)
						{
							Switch PreviousEvTt_C2
							{
								Case 0: GuiControl, , % IdEvTt_C2, 0
								Case 1: GuiControl, , % IdEvTt_C2, 1
							}
						}
						if (EvTt_S1 != PreviousEvTt_S1)
							GuiControl, , % IdEvTt_S1, % PreviousEvTt_S1
						if (EvTt_S2 != PreviousEvTt_S2)
							GuiControl, , % IdEvTt_S2, % PreviousEvTt_S2
						if (EvTt_DDL1 != PreviousEvTt_DDL1)
							GuiControl, ChooseString, % IdEvTt_DDL1, % PreviousEvTt_S2 
						if (EvTt_DDL2 != PreviousEvTt_DDL2)
							GuiControl, ChooseString, % IdEvTt_DDL2, % PreviousEvTt_S2 
					}			
				}
				else
				{
					F_EvUpdateTab()
				}
				PreviousEvTab3 := EvTab3
			
			Case % TransA["Active triggerstring tips"]:
				if (EvAT_R1R2 != PreviousEvAT_R1R2)
				{
					MsgBox, 68, % SubStr(A_ScriptName, 1, -4) .  ":" . A_Space . TransA["warning"], % TransA["You've changed at least one configuration parameter, but didn't yet apply it."] 
						. TransA["If you don't apply it, previous changes will be lost."]
						. "`n`n" . TransA["Do you wish to apply your changes?"]
					IfMsgBox, Yes
					{
;#c/* commercial only beginning						
;#c*/ commercial only end
						F_EvUpdateTab()
					}
					IfMsgBox, No	;restore previous values to each GuiControl
					{ 
						if (EvAT_R1R2 != PreviousEvAT_R1R2)
						{
							Switch PreviousEvAT_R1R2
							{
								Case 1: GuiControl, , % IdEvAT_R1, 1
								Case 2: GuiControl, , % IdEvAT_R2, 1
							}
						}
					}			
				}
				else
				{
					F_EvUpdateTab()
				}
				PreviousEvTab3 := EvTab3
			
			Case % TransA["Static triggerstring / hotstring menus"]:
				if (EvSM_R1R2 != PreviousEvSM_R1R2)
				{
					MsgBox, 68, % SubStr(A_ScriptName, 1, -4) .  ":" . A_Space . TransA["warning"], % TransA["You've changed at least one configuration parameter, but didn't yet apply it."] 
						. TransA["If you don't apply it, previous changes will be lost."]
						. "`n`n" . TransA["Do you wish to apply your changes?"]
					IfMsgBox, Yes
					{
						F_EvSM_B2() ;Apply changes
						F_EvUpdateTab()
					}
					IfMsgBox, No	;restore previous values to each GuiControl
					{
						if (EvSM_R1R2 != PreviousEvSM_R1R2)
						{
							Switch PreviousEvSM_R1R2
							{
								Case 1: GuiControl, , % IdEvSM_R1, 1
								Case 2: GuiControl, , % IdEvSM_R2, 1
							}
						}
					}			
				}
				else
				{
					F_EvUpdateTab()
				}
				PreviousEvTab3 := EvTab3
		}
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EvUpdateTab()
{
	global ;assume-global mode
	Switch EvTab3
	{
		Case % TransA["Basic hotstring is triggered"]:
			GuiControl, +Default, % IdEvBH_B3	;default button Apply
			Switch EvSM_R1R2
			{
				Case 1:	;enable
				GuiControl, Disable, 	% IdEvBH_T1
				GuiControl, Disable, 	% IdEvBH_T2
				GuiControl, Disable, 	% IdEvBH_R1
				GuiControl, Disable, 	% IdEvBH_R2
				GuiControl, Disable, 	% IdEvBH_T3
				GuiControl, Disable, 	% IdEvBH_T4
				GuiControl, Disable, 	% IdEvBH_T5
				GuiControl, Disable, 	% IdEvBH_R3
				GuiControl, Disable, 	% IdEvBH_R4
				GuiControl, Disable, 	% IdEvBH_T6
				GuiControl, Disable, 	% IdEvBH_S1
				GuiControl, Disable, 	% IdEvBH_T7
				GuiControl, Disable, 	% IdEvBH_T8
				GuiControl, Disable, 	% IdEvBH_T9
				GuiControl, Disable, 	% IdEvBH_R5
				GuiControl, Disable, 	% IdEvBH_R6
				GuiControl, Disable, 	% IdEvMH_T1
				GuiControl, Disable, 	% IdEvMH_T2
				GuiControl, Disable, 	% IdEvMH_R1
				GuiControl, Disable, 	% IdEvMH_R2

				Case 2:	;disable
				GuiControl, Enable, 	% IdEvBH_T1
				GuiControl, Enable, 	% IdEvBH_T2
				GuiControl, Enable, 	% IdEvBH_R1
				GuiControl, Enable, 	% IdEvBH_R2
				GuiControl, Enable, 	% IdEvBH_T3
				GuiControl, Enable, 	% IdEvBH_T4
				GuiControl, Enable, 	% IdEvBH_T5
				GuiControl, Enable, 	% IdEvBH_R3
				GuiControl, Enable, 	% IdEvBH_R4
				GuiControl, Enable, 	% IdEvBH_T6
				GuiControl, Enable, 	% IdEvBH_S1
				GuiControl, Enable, 	% IdEvBH_T7
				GuiControl, Enable, 	% IdEvBH_T8
				GuiControl, Enable, 	% IdEvBH_T9
				GuiControl, Enable, 	% IdEvBH_R5
				GuiControl, Enable, 	% IdEvBH_R6
				F_EvBH_R1R2()
				F_EvBH_R3R4()
				F_EvBH_R7R8()
				F_EvBH_S1()
				F_EvBH_S2()
				F_EvBH_S3()
			}
		Case % TransA["Menu hotstring is triggered"]:
			GuiControl, +Default, % IdEvMH_B2	;default button Apply
			Switch EvSM_R1R2
			{
				Case 1:	;enable
				GuiControl, Disable, 	% IdEvMH_T1
				GuiControl, Disable, 	% IdEvMH_T2
				GuiControl, Disable, 	% IdEvMH_R1
				GuiControl, Disable, 	% IdEvMH_R2

				Case 2:	;disable
				GuiControl, Enable, 	% IdEvMH_T1
				GuiControl, Enable, 	% IdEvMH_T2
				GuiControl, Enable, 	% IdEvMH_R1
				GuiControl, Enable, 	% IdEvMH_R2
				F_EvMH_R3R4()
				F_EvMH_S1()
				F_EvMH_S2()
			}
		Case % TransA["Undid the last hotstring"]:
			GuiControl, +Default, % IdEvUH_B3	;default button Apply
			F_EvUH_R1R2()
			F_EvUH_R3R4()
			F_EvUH_R7R8()
			F_EvUH_S1()
			F_EvUH_S2()
			F_EvUH_S3()
		Case % TransA["Triggerstring tips"]:
			GuiControl, +Default, % IdEvTt_B2	;default button Apply
			F_EvTt_R1R2()
			F_EvTt_R3R4()
			F_EvTt_S1()
			F_EvTt_S2()
;#c/* commercial only beginning			
;#c*/ commercial only end			
		Case % TransA["Static triggerstring / hotstring menus"]:
			GuiControl, +Default, % IdEvSM_B2	;default button Apply
;#c/* commercial only beginning			
;#c*/ commercial only end			
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EvSM_B4()	;static menus, button Cancel
{
	global ;assume-global mode
	Gui, Tt_HWT: Hide			;Tooltip: Basic hotstring was triggered
     F_CloseSubGui(WhatGuiToDestroy := "GuiEvents")
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EvSM_B2()	;static menus, button Apply
{
	global ;assume-global mode
	Gui, GuiEvents: Submit, NoHide
	Switch EvSM_R1R2	;static triggerstring / hostring menu enable / disable
	{
		Case 1:	;enable
		Switch ini_TTCn	;previous value of ini_TTCn
		{
			Case 1: Gui, TT_C1:		Destroy
			Case 2: Gui, TT_C2:		Destroy
			Case 3: Gui, TT_C3:		Destroy
		}
		ini_TTCn := 4	;enable
		F_GuiTrigTipsMenuDefC4()	
		Case 2:	;disable: 
		Gui, TT_C4:		Destroy
		ini_TTCn := 2	; default value: Composition of triggerstring tips = Triggerstring tips + triggers
	}
	IniWrite, % ini_TTCn,	% ini_HADConfig, Event_TriggerstringTips,	TTCn
	Gui, Tt_HWT: Hide			;Tooltip: Basic hotstring was triggered	
	F_EvTab3(true)	;to memory that something was applied
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EvSM_B3()	;static menus, button Close
{
	global ;assume-global mode
	Gui, GuiEvents: Submit
	Switch EvSM_R1R2	;static triggerstring / hostring menu enable / disable
	{
		Case 1:	;enable
		Switch ini_TTCn	;previous value of ini_TTCn
		{
			Case 1: Gui, TT_C1:		Destroy
			Case 2: Gui, TT_C2:		Destroy
			Case 3: Gui, TT_C3:		Destroy
		}
		ini_TTCn := 4	;enable
		F_GuiTrigTipsMenuDefC4()	
		Case 2:	;disable: 
		Gui, TT_C4:		Destroy
		ini_TTCn := 2	; default value: Composition of triggerstring tips = Triggerstring tips + triggers
	}
	IniWrite, % ini_TTCn,	% ini_HADConfig, Event_TriggerstringTips,	TTCn
	Gui, Tt_HWT: Hide			;Tooltip: Basic hotstring was triggered
	F_EvTab3(true)	;to memory that something was applied
     F_CloseSubGui(WhatGuiToDestroy := "GuiEvents")
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EvSM_B1()	;static menus, button Preview	
{
	global ;assume-global mode
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EvSM_R1R2()
{
	global ;assume-global mode
	Gui, GuiEvents: Submit, NoHide
	;OutputDebug, % "EvTt_R1R2 after submit:" . A_Tab . EvTt_R1R2
	Switch EvSM_R1R2
	{
		Case 1:	;static triggering / hotstring menu Enable
			GuiControl, Disable, 	% IdEvTt_R1
			GuiControl, Disable, 	% IdEvTt_R2
			GuiControl, Disable, 	% IdEvTt_T6
			GuiControl, Disable, 	% IdEvTt_R3
			GuiControl, Disable, 	% IdEvTt_R4
			GuiControl, Disable, 	% IdEvTt_T7
			GuiControl, Disable, 	% IdEvTt_S1
			GuiControl, Disable, 	% IdEvTt_T8
			GuiControl, Disable, 	% IdEvTt_R5
			GuiControl, Disable, 	% IdEvTt_R6
			GuiControl, Disable, 	% IdEvTt_DDL2
			GuiControl, Disable, 	% IdEvMH_R1
			GuiControl, Disable, 	% IdEvMH_R2
		Case 2:	;static triggering / hotstring menu Disable
			GuiControl, Enable, 	% IdEvTt_R1
			GuiControl, Enable, 	% IdEvTt_R2
			GuiControl, Enable, 	% IdEvTt_T6
			GuiControl, Enable, 	% IdEvTt_R3
			GuiControl, Enable, 	% IdEvTt_R4
			GuiControl, Enable, 	% IdEvTt_T7
			GuiControl, Enable, 	% IdEvTt_S1
			GuiControl, Enable, 	% IdEvTt_T8
			GuiControl, Enable, 	% IdEvTt_R5
			GuiControl, Enable, 	% IdEvTt_R6
			GuiControl, Enable, 	% IdEvTt_DDL2
			GuiControl, Enable, 	% IdEvMH_R1
			GuiControl, Enable, 	% IdEvMH_R2
	}
}	
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;#c/* commercial only beginning
;#c*/ commercial only end
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;#c/* commercial only beginning
;#c*/ commercial only end
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;#c/* commercial only beginning
;#c*/ commercial only end
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;#c/* commercial only beginning
;#c*/ commercial only end
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;#c/* commercial version only beginning
;#c*/ commercial version only end
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EvTt_B1()	;Event Tooltip (is triggered) Button Tooltip test 
{
	global ;assume-global mode of operation
	local a_Tips 		:= []
		, a_TipsOpt	:= []	;collect withing global array a_TipsOpt subset from full set a_TriggerOptions; next it will be used to show triggering character in F_ShowTriggerstringTips2()
		, a_TipsEnDis	:= []
		, a_TipsHS	:= []	;HS = Hotstrings
		, a_Combined	:= []
	
	Gui, GuiEvents: Submit, NoHide
	if (EvTt_R1R2 = 1)
	{
		Loop, % EvTt_S2
		{
			if (A_Index = 1)
			{
				a_Tips[A_Index] 		:= "A" . Chr(65 + EvTt_S2 - A_Index) . A_Space . "Demo" . A_Space . A_Index
				, a_TipsOpt[A_Index] 	:= "C"
				, a_TipsEnDis[A_Index]	:= "Dis"
				, a_TipsHS[A_Index]		:= "Ex HotString" . A_Index
			}
			else
			{
				a_Tips[A_Index] 		:= Chr(65 + EvTt_S2 - A_Index) . A_Space . "Demo" . A_Space . A_Index
				, a_TipsOpt[A_Index]	:= "*"
				, a_TipsEnDis[A_Index]	:= "En"
				, a_TipsHS[A_Index]		:= "Ex HotString" . A_Index
			}
			a_Combined[A_Index]			:= a_Tips[A_Index] . c_TextDelimiter . a_TipsOpt[A_Index] . c_TextDelimiter . a_TipsEnDis[A_Index] . c_TextDelimiter . a_TipsHS[A_Index]
		}
		F_Sort_a_Triggers(a_Combined, EvTt_C1, EvTt_C2)
		F_ShowTriggerstringTips2(a_Tips, a_TipsOpt, a_TipsEnDis, a_TipsHS, EvTt_DDL2)
		if ((EvTt_R1R2 = 1) and (EvTt_R3R4 = 1))
			SetTimer, TurnOff_Ttt, % "-" . EvTt_S1	 ;, 200 ;Priority = 200 to avoid conflicts with other threads 
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EvTt_B2()	;Event Tooltip (is triggered) Button Apply
{
	global ;assume-global mode
	Gui, GuiEvents: Submit, NoHide
	Switch EvTt_R1R2	;Tooltip enable
	{
		Case 1:	ini_TTTtEn := true
		Case 2:	ini_TTTtEn := false
	}
	Switch EvTt_R3R4	;Finite timeout
	{
		Case 1:	ini_TTTD := EvTt_S1
		Case 2:	ini_TTTD := 0
	}
	Switch EvTt_R5R6	;Tooltip position
	{
		Case 1:	ini_TTTP := 1
		Case 2:	ini_TTTP := 2
	}
	ini_TipsSortAlphabetically := EvTt_C1, ini_TipsSortByLength := EvTt_C2, ini_MNTT := EvTt_S2,	ini_TASAC := EvTt_DDL1,	ini_TTCn := EvTt_DDL2
	IniWrite, % ini_TTTtEn, 	% ini_HADConfig, Event_TriggerstringTips, 	TTTtEn
	IniWrite, % ini_TTTD,	% ini_HADConfig, Event_TriggerstringTips,	TTTD
	IniWrite, % ini_TTTP,	% ini_HADConfig, Event_TriggerstringTips,	TTTP
	IniWrite, % ini_TipsSortAlphabetically, 	% ini_HADConfig, Event_TriggerstringTips,	TipsSortAlphabetically
	IniWrite, % ini_TipsSortByLength,	% ini_HADConfig, Event_TriggerstringTips,	TipsSortByLength
	IniWrite, % ini_MNTT,	% ini_HADConfig, Event_TriggerstringTips,	MNTT
	IniWrite, % ini_TASAC,	% ini_HADConfig, Event_TriggerstringTips,	TipsAreShownAfterNoOfCharacters
	IniWrite, % ini_TTCn,	% ini_HADConfig, Event_TriggerstringTips,	TTCn
	Gui, Tt_HWT: Hide			;Tooltip: Basic hotstring was triggered	
	F_EvTab3(true)	;to memory that something was applied
	F_UpdateStateOfLockKeys(ini_HK_ToggleTt, ini_TTTtEn)
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EvTt_B3()	;Event Tooltip (is triggered) Button Close
{
	global ;assume-global mode
	Gui, GuiEvents: Submit
	Switch EvTt_R1R2	;Tooltip enable
	{
		Case 1:	ini_TTTtEn := true
		Case 2:	ini_TTTtEn := false
	}
	Switch EvTt_R3R4	;Finite timeout
	{
		Case 1:	ini_TTTD := EvTt_S1
		Case 2:	ini_TTTD := 0
	}
	Switch EvTt_R5R6	;Tooltip position
	{
		Case 1:	ini_TTTP := 1
		Case 2:	ini_TTTP := 2
	}
	ini_TipsSortAlphabetically := EvTt_C1, ini_TipsSortByLength := EvTt_C2, ini_MNTT := EvTt_S2,	ini_TASAC := EvTt_DDL1,	ini_TTCn := EvTt_DDL2
	IniWrite, % ini_TTTtEn, 	% ini_HADConfig, Event_TriggerstringTips, 	TTTtEn
	IniWrite, % ini_TTTD,	% ini_HADConfig, Event_TriggerstringTips,	TTTD
	IniWrite, % ini_TTTP,	% ini_HADConfig, Event_TriggerstringTips,	TTTP
	IniWrite, % ini_TipsSortAlphabetically, 	% ini_HADConfig, Event_TriggerstringTips,	TipsSortAlphabetically
	IniWrite, % ini_TipsSortByLength,	% ini_HADConfig, Event_TriggerstringTips,	TipsSortByLength
	IniWrite, % ini_MNTT,	% ini_HADConfig, Event_TriggerstringTips,	MNTT
	IniWrite, % ini_TASAC,	% ini_HADConfig, Event_TriggerstringTips,	TipsAreShownAfterNoOfCharacters
	IniWrite, % ini_TTCn,	% ini_HADConfig, Event_TriggerstringTips,	TTCn
	Gui, Tt_HWT: Hide			;Tooltip: Basic hotstring was triggered
	F_EvTab3(true)	;to memory that something was applied
     F_CloseSubGui(WhatGuiToDestroy := "GuiEvents")
	F_UpdateStateOfLockKeys(ini_HK_ToggleTt, ini_TTTtEn)
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EvTt_B4()	;Event Tooltip (is triggered) Button Cancel
{
	global ;assume-global mode
	Gui, Tt_HWT: Hide			;Tooltip: Basic hotstring was triggered
     F_CloseSubGui(WhatGuiToDestroy := "GuiEvents")
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EvTt_S2()
{
	global ;assume-global mode
	GuiControl,, % IdEvTt_T18, % EvTt_S2
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EvTt_S1()
{
	global ;assume-global mode
	GuiControl,, % IdEvTt_T8, % TransA["Timeout value [ms]"] . ":" . A_Space . EvTt_S1	
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EvTt_R3R4()
{
	global ;assume-global mode
	Gui, GuiEvents: Submit, NoHide
	Switch EvTt_R3R4
	{
		Case 1:
		GuiControl, Enable,		% IdEvTt_T7
		GuiControl, Enable,		% IdEvTt_S1
		GuiControl, Enable,		% IdEvTt_T8
		F_EvTt_S1()
		Case 2:
		GuiControl, Disable,	% IdEvTt_T7
		GuiControl, Disable,	% IdEvTt_S1
		GuiControl, Disable,	% IdEvTt_T8
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EvTt_R1R2()
{
	global ;assume-global mode
	;OutputDebug, % "EvTt_R1R2 before submit:" . A_Tab . EvTt_R1R2
	Gui, GuiEvents: Submit, NoHide
	;OutputDebug, % "EvTt_R1R2 after submit:" . A_Tab . EvTt_R1R2
	Switch EvTt_R1R2
	{
		Case 1:
			GuiControl, Enable, 	% IdEvTt_T3
			GuiControl, Enable, 	% IdEvTt_T4
			GuiControl, Enable, 	% IdEvTt_T5
			GuiControl, Enable, 	% IdEvTt_R3
			GuiControl, Enable, 	% IdEvTt_R4
			GuiControl, Enable, 	% IdEvTt_T6
			GuiControl, Enable, 	% IdEvTt_S1
			GuiControl, Enable, 	% IdEvTt_T7
			GuiControl, Enable, 	% IdEvTt_T8
			GuiControl, Enable, 	% IdEvTt_T9
			GuiControl, Enable, 	% IdEvTt_T10
			GuiControl, Enable, 	% IdEvTt_T11
			GuiControl, Enable, 	% IdEvTt_R5
			GuiControl, Enable, 	% IdEvTt_R6
			GuiControl, Enable, 	% IdEvTt_T13
			GuiControl, Enable, 	% IdEvTt_T14
			GuiControl, Enable, 	% IdEvTt_C1
			GuiControl, Enable, 	% IdEvTt_C2
			GuiControl, Enable, 	% IdEvTt_T16
			GuiControl, Enable, 	% IdEvTt_T17
			GuiControl, Enable, 	% IdEvTt_S2
			GuiControl, Enable, 	% IdEvTt_T18
			GuiControl, Enable, 	% IdEvTt_T20
			GuiControl, Enable, 	% IdEvTt_T21
			GuiControl, Enable, 	% IdEvTt_DDL1
			GuiControl, Enable,		% IdEvTt_T23
			GuiControl, Enable,		% IdEvTt_T24
			GuiControl, Enable, 	% IdEvTt_DDL2
			Switch EvTt_R3R4
			{
				Case 1:
					GuiControl, Enable,		% IdEvTt_T7
					GuiControl, Enable,		% IdEvTt_S1
					GuiControl, Enable,		% IdEvTt_T8
				Case 2:
					GuiControl, Disable,	% IdEvTt_T7
					GuiControl, Disable,	% IdEvTt_S1
					GuiControl, Disable,	% IdEvTt_T8
			}
			
		Case 2:
			GuiControl, Disable, 	% IdEvTt_T3
			GuiControl, Disable, 	% IdEvTt_T4
			GuiControl, Disable, 	% IdEvTt_T5
			GuiControl, Disable, 	% IdEvTt_R3
			GuiControl, Disable, 	% IdEvTt_R4
			GuiControl, Disable, 	% IdEvTt_T6
			GuiControl, Disable, 	% IdEvTt_S1
			GuiControl, Disable, 	% IdEvTt_T7
			GuiControl, Disable, 	% IdEvTt_T8
			GuiControl, Disable, 	% IdEvTt_T9
			GuiControl, Disable, 	% IdEvTt_T10
			GuiControl, Disable, 	% IdEvTt_T11
			GuiControl, Disable, 	% IdEvTt_R5
			GuiControl, Disable, 	% IdEvTt_R6
			GuiControl, Disable, 	% IdEvTt_T13
			GuiControl, Disable, 	% IdEvTt_T14
			GuiControl, Disable, 	% IdEvTt_C1
			GuiControl, Disable, 	% IdEvTt_C2
			GuiControl, Disable, 	% IdEvTt_T16
			GuiControl, Disable, 	% IdEvTt_T17
			GuiControl, Disable, 	% IdEvTt_S2
			GuiControl, Disable, 	% IdEvTt_T18
			GuiControl, Disable, 	% IdEvTt_T20
			GuiControl, Disable, 	% IdEvTt_T21
			GuiControl, Disable, 	% IdEvTt_DDL1
			GuiControl, Disable,	% IdEvTt_T23
			GuiControl, Disable,	% IdEvTt_T24
			GuiControl, Disable, 	% IdEvTt_DDL2
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EvUH_B1() ;Event Undo Hotstring (is triggered) Button Tooltip test
{
	global ;assume-global mode
	local	tmp_UHTtEn := false, tmp_UHTD := 0, tmp_UHTP := 0 ;temporary variables, for testing purpose
	Gui, GuiEvents: Submit, NoHide
	if (EvUH_R1R2 = 1)
	{
		if (EvUH_R5R6 = 1)
		{
			if (A_CaretX and A_CaretY)
			{
				Gui, Tt_ULH: Show, % "x" . A_CaretX + 20 . A_Space . "y" . A_CaretY - 20
				if (ini_UHTD > 0)
					SetTimer, TurnOff_UHE, % "-" . ini_UHTD, 60 ;Priority = 60 to avoid conflicts with other threads 
			}
			else
			{
				MouseGetPos, v_MouseX, v_MouseY
				Gui, Tt_ULH: Show, % "x" . v_MouseX + 20 . A_Space . "y" . v_MouseY - 20
				if (ini_UHTD > 0)
					SetTimer, TurnOff_UHE, % "-" . ini_UHTD, 60 ;Priority = 60 to avoid conflicts with other threads 
			}
		}
		if (EvUH_R5R6 = 2)
		{
			MouseGetPos, v_MouseX, v_MouseY
			Gui, Tt_ULH: Show, % "x" . v_MouseX + 20 . A_Space . "y" . v_MouseY - 20
			if (ini_UHTD > 0)
				SetTimer, TurnOff_UHE, % "-" . ini_UHTD, 60 ;Priority = 60 to avoid conflicts with other threads 
		}
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EvUH_B2()	;Event Undo Hotstring (is triggered) Button Sound test
{
	global ;assume-global mode
	SoundBeep, % EvUH_S2, % EvUH_S3
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EvUH_B3()	;Event Undo Hotstring (is triggered) Button Apply
{
	global ;assume-global mode
	Gui, GuiEvents: Submit, NoHide
	Switch EvUH_R1R2	;Tooltip enable
	{
		Case 1:	ini_UHTtEn := true
		Case 2:	ini_UHTtEn := false
	}
	Switch EvUH_R3R4	;Finite timeout
	{
		Case 1:	ini_UHTD := EvUH_S1
		Case 2:	ini_UHTD := 0
	}
	Switch EvUH_R5R6	;Tooltip position
	{
		Case 1:	ini_UHTP := 1
		Case 2:	ini_UHTP := 2
	}
	Switch EvUH_R7R8	;Sound enable
	{
		Case 1:	ini_UHSEn := 1
		Case 2:	ini_UHSEn := 0
	}
	ini_UHSF := EvUH_S2, ini_UHSD := EvUH_S3
	IniWrite, % ini_UHTtEn, 	% ini_HADConfig, Event_UndoHotstring, 	UHTtEn
	IniWrite, % ini_UHTD,	% ini_HADConfig, Event_UndoHotstring,	UHTD
	IniWrite, % ini_UHTP,	% ini_HADConfig, Event_UndoHotstring,	UHTP
	IniWrite, % ini_UHSEn, 	% ini_HADConfig, Event_UndoHotstring,	UHSEn
	IniWrite, % ini_UHSF,	% ini_HADConfig, Event_UndoHotstring,	UHSF
	IniWrite, % ini_UHSD,	% ini_HADConfig, Event_UndoHotstring,	UHSD
	Gui, Tt_HWT: Hide			;Tooltip: Basic hotstring was triggered	
	F_EvTab3(true)	;to memory that something was applied
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EvUH_B4()	;Event Undo Hotstring (is triggered) Button Close
{
	global ;assume-global mode
	Gui, GuiEvents: Submit
	Switch EvUH_R1R2	;Tooltip enable
	{
		Case 1:	ini_UHTtEn := true
		Case 2:	ini_UHTtEn := false
	}
	Switch EvUH_R3R4	;Finite timeout
	{
		Case 1:	ini_UHTD := EvUH_S1
		Case 2:	ini_UHTD := 0
	}
	Switch EvUH_R5R6	;Tooltip position
	{
		Case 1:	ini_UHTP := 1
		Case 2:	ini_UHTP := 2
	}
	Switch EvUH_R7R8	;Sound enable
	{
		Case 1:	ini_UHSEn := 1
		Case 2:	ini_UHSEn := 0
	}
	ini_UHSF := EvUH_S2, ini_UHSD := EvUH_S3
	IniWrite, % ini_UHTtEn, 	% ini_HADConfig, Event_UndoHotstring, 	UHTtEn
	IniWrite, % ini_UHTD,	% ini_HADConfig, Event_UndoHotstring,	UHTD
	IniWrite, % ini_UHTP,	% ini_HADConfig, Event_UndoHotstring,	UHTP
	IniWrite, % ini_UHSEn, 	% ini_HADConfig, Event_UndoHotstring,	UHSEn
	IniWrite, % ini_UHSF,	% ini_HADConfig, Event_UndoHotstring,	UHSF
	IniWrite, % ini_UHSD,	% ini_HADConfig, Event_UndoHotstring,	UHSD
	Gui, Tt_HWT: Hide			;Tooltip: Basic hotstring was triggered
	F_EvTab3(true)	;to memory that something was applied
     F_CloseSubGui(WhatGuiToDestroy := "GuiEvents")
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EvUH_B5()	;Event Undo Hotstring (is triggered) Button Cancel
{
	global ;assume-global mode
	Gui, Tt_HWT: Hide			;Tooltip: Basic hotstring was triggered
     F_CloseSubGui(WhatGuiToDestroy := "GuiEvents")
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EvUH_S3()
{
	global ;assume-global mode
	GuiControl,, % IdEvUH_T14, % TransA["Sound duration [ms]"] . ":" . A_Space . EvUH_S3
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EvUH_S2()
{
	global ;assume-global mode
	GuiControl,, % IdEvUH_T13, % TransA["Sound frequency"] . ":" . A_Space . EvUH_S2
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EvUH_S1()
{
	global ;assume-global mode
	GuiControl,, % IdEvUH_T7, % TransA["Timeout value [ms]"] . ":" . A_Space . EvUH_S1
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EvUH_R3R4()
{
	global ;assume-global mode
	Gui, GuiEvents: Submit, NoHide
	Switch EvUH_R3R4
	{
		Case 1:
		GuiControl, Enable,		% IdEvUH_T6
		GuiControl, Enable,		% IdEvUH_S1
		GuiControl, Enable,		% IdEvUH_T7
		F_EvUH_S2()
		Case 2:
		GuiControl, Disable,	% IdEvUH_T6
		GuiControl, Disable,	% IdEvUH_S1
		GuiControl, Disable,	% IdEvUH_T7
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EvUH_R7R8()
{
	global ;assume-global mode
	Gui, GuiEvents: Submit, NoHide
	Switch EvUH_R7R8
	{
		Case 1:
		GuiControl, Enable,		% IdEvUH_T12
		GuiControl, Enable,		% IdEvUH_S2
		GuiControl, Enable,		% IdEvUH_T13
		GuiControl, Enable,		% IdEvUH_S3
		GuiControl, Enable,		% IdEvUH_T14
		GuiControl, Enable,		% IdEvUH_B2
		Case 2:
		GuiControl, Disable,	% IdEvUH_T12
		GuiControl, Disable,	% IdEvUH_S2
		GuiControl, Disable,	% IdEvUH_T13
		GuiControl, Disable,	% IdEvUH_S3
		GuiControl, Disable,	% IdEvUH_T14
		GuiControl, Disable,	% IdEvUH_B2
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EvUH_R1R2()
{
	global ;assume-global mode
	Gui, GuiEvents: Submit, NoHide
	Switch EvUH_R1R2
	{
		Case 1:
		GuiControl, Enable, 	% IdEvUH_T3
		GuiControl, Enable, 	% IdEvUH_T4
		GuiControl, Enable, 	% IdEvUH_T5
		GuiControl, Enable, 	% IdEvUH_R3
		GuiControl, Enable, 	% IdEvUH_R4
		GuiControl, Enable, 	% IdEvUH_T6
		GuiControl, Enable, 	% IdEvUH_S1
		GuiControl, Enable, 	% IdEvUH_T7
		GuiControl, Enable, 	% IdEvUH_T8
		GuiControl, Enable, 	% IdEvUH_T9
		GuiControl, Enable, 	% IdEvUH_R5
		GuiControl, Enable, 	% IdEvUH_R6
		GuiControl, Enable, 	% IdEvUH_B2
		Switch EvUH_R3R4
		{
			Case 1:
			GuiControl, Enable,		% IdEvUH_T6
			GuiControl, Enable,		% IdEvUH_S1
			GuiControl, Enable,		% IdEvUH_T7
			Case 2:
			GuiControl, Disable,	% IdEvUH_T6
			GuiControl, Disable,	% IdEvUH_S1
			GuiControl, Disable,	% IdEvUH_T7
		}
		Case 2:
		GuiControl, Disable, 	% IdEvUH_T3
		GuiControl, Disable, 	% IdEvUH_T4
		GuiControl, Disable, 	% IdEvUH_T5
		GuiControl, Disable, 	% IdEvUH_R3
		GuiControl, Disable, 	% IdEvUH_R4
		GuiControl, Disable, 	% IdEvUH_T6
		GuiControl, Disable, 	% IdEvUH_S1
		GuiControl, Disable, 	% IdEvUH_T7
		GuiControl, Disable, 	% IdEvUH_T8
		GuiControl, Disable, 	% IdEvUH_T9
		GuiControl, Disable, 	% IdEvUH_R5
		GuiControl, Disable, 	% IdEvUH_R6
		GuiControl, Disable, 	% IdEvUH_B2
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EvMH_B4()	;Menu Hotstring (is triggered) Button Cancel
{
	global ;assume-global mode
	Gui, Tt_HWT: Hide			;Tooltip: Basic hotstring was triggered
     F_CloseSubGui(WhatGuiToDestroy := "GuiEvents")
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EvMH_B2()	;Apply Button
{
	global ;assume-global mode
	Gui, GuiEvents: Submit, NoHide
	Switch EvMH_R1R2	;Tooltip position
	{
		Case 1:	ini_MHMP := 1
		Case 2:	ini_MHMP := 2
	}
	Switch EvMH_R3R4	;Sound enable
	{
		Case 1:	ini_MHSEn := 1
		Case 2:	ini_MHSEn := 0
	}
	ini_MHSF := EvMH_S1, ini_MHSD := EvMH_S2
	IniWrite, % ini_MHMP,	% ini_HADConfig, Event_MenuHotstring,		MHMP
	IniWrite, % ini_MHSEn, 	% ini_HADConfig, Event_MenuHotstring,		MHSEn
	IniWrite, % ini_MHSF,	% ini_HADConfig, Event_MenuHotstring,		MHSF
	IniWrite, % ini_MHSD,	% ini_HADConfig, Event_MenuHotstring,		MHSD
	Gui, Tt_HWT: Hide			;Tooltip: Basic hotstring was triggered	
	F_EvTab3(true)	;to memory that something was applied
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EvMH_B3()	;Button Close	
{
	global ;assume-global mode
	Gui, GuiEvents: Submit
	Switch EvMH_R1R2	;Tooltip position
	{
		Case 1:	ini_MHMP := 1
		Case 2:	ini_MHMP := 2
	}
	Switch EvMH_R3R4	;Sound enable
	{
		Case 1:	ini_MHSEn := 1
		Case 2:	ini_MHSEn := 0
	}
	ini_MHSF := EvMH_S1, ini_MHSD := EvMH_S2
	IniWrite, % ini_MHMP,	% ini_HADConfig, Event_MenuHotstring,		MHMP
	IniWrite, % ini_MHSEn, 	% ini_HADConfig, Event_MenuHotstring,		MHSEn
	IniWrite, % ini_MHSF,	% ini_HADConfig, Event_MenuHotstring,		MHSF
	IniWrite, % ini_MHSD,	% ini_HADConfig, Event_MenuHotstring,		MHSD
	Gui, Tt_HWT: Hide			;Tooltip: Basic hotstring was triggered
	F_EvTab3(true)	;to memory that something was applied
     F_CloseSubGui(WhatGuiToDestroy := "GuiEvents")
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EvMH_B1()	;Sound test
{
	global ;assume-global mode
	SoundBeep, % EvMH_S1, % EvMH_S2
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EvMH_S2()	;Sound duration
{
	global ;assume-global mode
	GuiControl,, % IdEvMH_T8, % TransA["Sound duration [ms]"] . ":" . A_Space . EvMH_S2
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EvMH_S1()	;Sound frequency
{
	global ;assume-global mode
	GuiControl,, % IdEvMH_T7, % TransA["Sound frequency"] . ":" . A_Space . EvMH_S1
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EvMH_R3R4()
{
	global ;assume-global mode
	Gui, GuiEvents: Submit, NoHide
	Switch EvMH_R3R4
	{
		Case 1:
		GuiControl, Enable,		% IdEvMH_T6
		GuiControl, Enable,		% IdEvMH_S1
		GuiControl, Enable,		% IdEvMH_T7
		GuiControl, Enable,		% IdEvMH_S2
		GuiControl, Enable,		% IdEvMH_T8
		GuiControl, Enable,		% IdEvMH_B1
		Case 2:
		GuiControl, Disable,	% IdEvMH_T6
		GuiControl, Disable,	% IdEvMH_S1
		GuiControl, Disable,	% IdEvMH_T7
		GuiControl, Disable,	% IdEvMH_S2
		GuiControl, Disable,	% IdEvMH_T8
		GuiControl, Disable,	% IdEvMH_B1
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_GuiEvents_DetermineConstraints()
{
	global ;assume-global mode
	local v_OutVarTemp := 0, 	v_OutVarTempX := 0, 	v_OutVarTempY := 0, 	v_OutVarTempW := 0, 	v_OutVarTempH := 0
		,v_OutVarTemp1 := 0,	v_OutVarTemp1X := 0, 	v_OutVarTemp1Y := 0, 	v_OutVarTemp1W := 0, 	v_OutVarTemp1H := 0
		,v_OutVarTemp2 := 0, 	v_OutVarTemp2X := 0, 	v_OutVarTemp2Y := 0, 	v_OutVarTemp2W := 0, 	v_OutVarTemp2H := 0
		,v_OutVarTemp3 := 0, 	v_OutVarTemp3X := 0, 	v_OutVarTemp3Y := 0, 	v_OutVarTemp3W := 0, 	v_OutVarTemp3H := 0
		,v_OutVarTemp4 := 0, 	v_OutVarTemp4X := 0, 	v_OutVarTemp4Y := 0, 	v_OutVarTemp4W := 0, 	v_OutVarTemp4H := 0
		,maxY1 := 0, 	maxY2 := 0, 	maxY3 := 0, 	maxY4 := 0, 	maxY5 := 0,	maxY6 := 0
		,v_xNext := 0, 		v_yNext := 0, 			v_wNext := 0, 			v_hNext := 0, TheWidestText := 0, TotalWidth := 0
		,MaxY := 0
	
	GuiControlGet, v_OutVarTemp1, Pos, % IdEvBH_T6
	GuiControlGet, v_OutVarTemp2, Pos, % IdEvBH_T11
	TheWidestText 	:= Max(v_OutVarTemp1W, v_OutVarTemp2W)
	GuiControlGet, v_OutVarTemp3, Pos, % IdEvBH_T7
	TotalWidth 	:= v_OutVarTemp1W + v_OutVarTemp3W + 2 * c_xmarg
	
	v_xNext := c_xmarg, v_yNext := c_ymarg
	GuiControl, Move, % IdEvBH_T1, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvBH_T1
	v_xNext += v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvBH_T2, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += c_HofText
	GuiControl, Move, % IdEvBH_R1, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvBH_R1
	v_xNext += v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvBH_R2, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += 3 * c_HofText
	GuiControl, Move, % IdEvBH_T15, % "x+" . v_xNext . A_Space . "y+" . v_yNext - 2 . A_Space . "w+" . TotalWidth . A_Space . "h+" . 1
	GuiControl, Move, % IdEvBH_T3, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvBH_T3
	v_xNext += v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvBH_T4, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += c_HofText
	GuiControl, Move, % IdEvBH_T5, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += c_HofText
	GuiControl, Move, % IdEvBH_R3, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvBH_R3
	v_xNext += v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvBH_R4, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += c_HofText
	GuiControl, Move, % IdEvBH_T6, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += c_HofText, v_wNext := TheWidestText
	GuiControl, Move, % IdEvBH_S1, % "x+" . v_xNext . A_Space . "y+" . v_yNext . A_Space . "w+" . v_wNext
	v_xNext += 2 * c_xmarg + TheWidestText
	GuiControl, Move, % IdEvBH_T7, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += 3 * c_HofText
	GuiControl, Move, % IdEvBH_T16, % "x+" . v_xNext . A_Space . "y+" . v_yNext - 2 . A_Space . "w+" . TotalWidth . A_Space . "h+" . 1
	GuiControl, Move, % IdEvBH_T8, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvBH_T8
	v_xNext += v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvBH_T9, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += c_HofText
	GuiControl, Move, % IdEvBH_R5, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvBH_R5
	v_xNext += v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvBH_R6, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += 3 * c_HofText
	GuiControl, Move, % IdEvBH_T17, % "x+" . v_xNext . A_Space . "y+" . v_yNext - 2 . A_Space . "w+" . TotalWidth . A_Space . "h+" . 1
	GuiControl, Move, % IdEvBH_T10, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvBH_T10
	v_xNext += v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvBH_T11, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += c_HofText
	GuiControl, Move, % IdEvBH_R7, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvBH_R7
	v_xNext += v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvBH_R8, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += c_HofText
	GuiControl, Move, % IdEvBH_T12, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_yNext += c_HofText
	GuiControl, Move, % IdEvBH_S2, % "x+" . v_xNext . A_Space . "y+" . v_yNext . A_Space . "w+" . v_wNext
	v_xNext += 2 * c_xmarg + TheWidestText
	GuiControl, Move, % IdEvBH_T13, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg
	GuiControlGet, v_OutVarTemp, Pos, % IdEvBH_S2
	v_yNext += v_OutVarTempH
	GuiControl, Move, % IdEvBH_S3, % "x+" . v_xNext . A_Space . "y+" . v_yNext . A_Space . "w+" . v_wNext	
	v_xNext += 2 * c_xmarg + TheWidestText
	GuiControl, Move, % IdEvBH_T14, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += 3 * c_HofText
	GuiControl, Move, % IdEvBH_B1, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvBH_B1
	v_xNext += v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvBH_B2, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvBH_B2
	v_xNext += v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvBH_B3, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvBH_B3
	v_xNext += v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvBH_B4, % "x+" . v_xNext . A_Space . "y+" . v_yNext	
	GuiControlGet, v_OutVarTemp, Pos, % IdEvBH_B4
	v_xNext += v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvBH_B5, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	maxY1 := v_yNext
	
	v_xNext := c_xmarg, v_yNext := c_ymarg
	GuiControl, Move, % IdEvMH_T1, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvMH_T1
	v_xNext += v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvMH_T2, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += c_HofText
	GuiControl, Move, % IdEvMH_R1, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvMH_R1
	v_xNext += v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvMH_R2, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += 3 * c_HofText
	GuiControl, Move, % IdEvMH_T3, % "x+" . v_xNext . A_Space . "y+" . v_yNext - 2 . A_Space . "w+" . TotalWidth . A_Space . "h+" . 1
	GuiControl, Move, % IdEvMH_T4, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvMH_T4
	v_xNext += v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvMH_T5, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += c_HofText
	GuiControl, Move, % IdEvMH_R3, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvMH_R3
	v_xNext += v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvMH_R4, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += c_HofText
	GuiControl, Move, % IdEvMH_T6, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_yNext += c_HofText
	GuiControl, Move, % IdEvMH_S1, % "x+" . v_xNext . A_Space . "y+" . v_yNext . A_Space . "w+" . v_wNext
	v_xNext += 2 * c_xmarg + TheWidestText
	GuiControl, Move, % IdEvMH_T7, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg
	GuiControlGet, v_OutVarTemp, Pos, % IdEvMH_S1
	v_yNext += v_OutVarTempH
	GuiControl, Move, % IdEvMH_S2, % "x+" . v_xNext . A_Space . "y+" . v_yNext . A_Space . "w+" . v_wNext	
	v_xNext += 2 * c_xmarg + TheWidestText
	GuiControl, Move, % IdEvMH_T8, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += 3 * c_HofText
	GuiControl, Move, % IdEvMH_B1, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvMH_B1	
	v_xNext += v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvMH_B2, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvMH_B2
	v_xNext += v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvMH_B3, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvMH_B3
	v_xNext += v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvMH_B4, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	maxY2 := v_yNext
	
	GuiControlGet, v_OutVarTemp1, Pos, % IdEvUH_T6
	GuiControlGet, v_OutVarTemp2, Pos, % IdEvUH_T11
	TheWidestText 	:= Max(v_OutVarTemp1W, v_OutVarTemp2W)
	GuiControlGet, v_OutVarTemp3, Pos, % IdEvUH_T7
	TotalWidth 	:= v_OutVarTemp1W + v_OutVarTemp3W + 2 * c_xmarg
	
	v_xNext := c_xmarg, v_yNext := c_ymarg
	GuiControl, Move, % IdEvUH_T1, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvUH_T1
	v_xNext += v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvUH_T2, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += c_HofText
	GuiControl, Move, % IdEvUH_R1, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvUH_R1
	v_xNext += v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvUH_R2, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += 3 * c_HofText
	GuiControl, Move, % IdEvUH_T15, % "x+" . v_xNext . A_Space . "y+" . v_yNext - 2 . A_Space . "w+" . TotalWidth . A_Space . "h+" . 1
	GuiControl, Move, % IdEvUH_T3, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvUH_T3
	v_xNext += v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvUH_T4, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += c_HofText
	GuiControl, Move, % IdEvUH_T5, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += c_HofText
	GuiControl, Move, % IdEvUH_R3, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvUH_R3
	v_xNext += v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvUH_R4, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += c_HofText
	GuiControl, Move, % IdEvUH_T6, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += c_HofText, v_wNext := TheWidestText
	GuiControl, Move, % IdEvUH_S1, % "x+" . v_xNext . A_Space . "y+" . v_yNext . A_Space . "w+" . v_wNext
	v_xNext += 2 * c_xmarg + TheWidestText
	GuiControl, Move, % IdEvUH_T7, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += 3 * c_HofText
	GuiControl, Move, % IdEvUH_T16, % "x+" . v_xNext . A_Space . "y+" . v_yNext - 2 . A_Space . "w+" . TotalWidth . A_Space . "h+" . 1
	GuiControl, Move, % IdEvUH_T8, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvUH_T8
	v_xNext += v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvUH_T9, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += c_HofText
	GuiControl, Move, % IdEvUH_R5, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvUH_R5
	v_xNext += v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvUH_R6, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += 3 * c_HofText
	GuiControl, Move, % IdEvUH_T17, % "x+" . v_xNext . A_Space . "y+" . v_yNext - 2 . A_Space . "w+" . TotalWidth . A_Space . "h+" . 1
	GuiControl, Move, % IdEvUH_T10, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvUH_T10
	v_xNext += v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvUH_T11, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += c_HofText
	GuiControl, Move, % IdEvUH_R7, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvUH_R7
	v_xNext += v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvUH_R8, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += c_HofText
	GuiControl, Move, % IdEvUH_T12, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_yNext += c_HofText
	GuiControl, Move, % IdEvUH_S2, % "x+" . v_xNext . A_Space . "y+" . v_yNext . A_Space . "w+" . v_wNext
	v_xNext += 2 * c_xmarg + TheWidestText
	GuiControl, Move, % IdEvUH_T13, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg
	GuiControlGet, v_OutVarTemp, Pos, % IdEvUH_S2
	v_yNext += v_OutVarTempH
	GuiControl, Move, % IdEvUH_S3, % "x+" . v_xNext . A_Space . "y+" . v_yNext . A_Space . "w+" . v_wNext	
	v_xNext += 2 * c_xmarg + TheWidestText
	GuiControl, Move, % IdEvUH_T14, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += 3 * c_HofText
	GuiControl, Move, % IdEvUH_B1, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvUH_B1
	v_xNext += v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvUH_B2, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvUH_B2
	v_xNext += v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvUH_B3, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvUH_B3
	v_xNext += v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvUH_B4, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvUH_B4
	v_xNext += v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvUH_B5, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	maxY3 := v_yNext
	
	v_xNext := c_xmarg, v_yNext := c_ymarg
	GuiControl, Move, % IdEvTt_T1, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvTt_T1
	v_xNext += v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvTt_T2, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += c_HofText
	GuiControl, Move, % IdEvTt_R1, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvTt_R1
	v_xNext += v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvTt_R2, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += 3 * c_HofText
	GuiControl, Move, % IdEvTt_T3, % "x+" . v_xNext . A_Space . "y+" . v_yNext - 2 . A_Space . "w+" . TotalWidth . A_Space . "h+" . 1
	GuiControl, Move, % IdEvTt_T4, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvTt_T4
	v_xNext += v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvTt_T5, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += c_HofText
	GuiControl, Move, % IdEvTt_T6, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += c_HofText
	GuiControl, Move, % IdEvTt_R3, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvTt_R3
	v_xNext += v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvTt_R4, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += c_HofText
	GuiControl, Move, % IdEvTt_T7, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += c_HofText, v_wNext := TheWidestText
	GuiControl, Move, % IdEvTt_S1, % "x+" . v_xNext . A_Space . "y+" . v_yNext . A_Space . "w+" . v_wNext
	v_xNext += 2 * c_xmarg + TheWidestText
	GuiControl, Move, % IdEvTt_T8, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += 3 * c_HofText
	GuiControl, Move, % IdEvTt_T9, % "x+" . v_xNext . A_Space . "y+" . v_yNext - 2 . A_Space . "w+" . TotalWidth . A_Space . "h+" . 1
	GuiControl, Move, % IdEvTt_T10, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvTt_T10
	v_xNext += v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvTt_T11, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += c_HofText
	GuiControl, Move, % IdEvTt_R5, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvTt_R5
	v_xNext += v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvTt_R6, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += 3 * c_HofText
	GuiControl, Move, % IdEvTt_T12, % "x+" . v_xNext . A_Space . "y+" . v_yNext - 2 . A_Space . "w+" . TotalWidth . A_Space . "h+" . 1
	GuiControl, Move, % IdEvTt_T13, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvTt_T13
	v_xNext += v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvTt_T14, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += c_HofText
	GuiControl, Move, % IdEvTt_C1, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvTt_C1
	v_xNext += v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvTt_C2, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += 3 * c_HofText
	GuiControl, Move, % IdEvTt_T15, % "x+" . v_xNext . A_Space . "y+" . v_yNext - 2 . A_Space . "w+" . TotalWidth . A_Space . "h+" . 1
	GuiControl, Move, % IdEvTt_T16, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvTt_T16
	v_xNext += v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvTt_T17, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += c_HofText, v_wNext := TheWidestText
	GuiControl, Move, % IdEvTt_S2, % "x+" . v_xNext . A_Space . "y+" . v_yNext . A_Space . "w+" . v_wNext
	v_xNext += 2 * c_xmarg + TheWidestText
	GuiControl, Move, % IdEvTt_T18, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += 3 * c_HofText
	GuiControl, Move, % IdEvTt_T19, % "x+" . v_xNext . A_Space . "y+" . v_yNext - 2 . A_Space . "w+" . TotalWidth . A_Space . "h+" . 1
	GuiControl, Move, % IdEvTt_T20, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvTt_T20
	v_xNext += v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvTt_T21, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += c_HofText, v_wNext := TheWidestText
	GuiControl, Move, % IdEvTt_DDL1, % "x+" . v_xNext . A_Space . "y+" . v_yNext . A_Space . "w+" . v_wNext	
	v_xNext := c_xmarg, v_yNext += 3 * c_HofText
	GuiControl, Move, % IdEvTt_T22, % "x+" . v_xNext . A_Space . "y+" . v_yNext - 2 . A_Space . "w+" . TotalWidth . A_Space . "h+" . 1
	GuiControl, Move, % IdEvTt_T23, % "x+" . v_xNext . A_Space . "y+" . v_yNext	
	GuiControlGet, v_OutVarTemp, Pos, % IdEvTt_T23
	v_xNext += v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvTt_T24, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvTt_T25	;fake text, just to measure its width, but unfortunately as it cannot be deleted, it has to be shifted somewhere
	v_xNext := c_xmarg, v_yNext += c_HofText, v_wNext := v_OutVarTempW + 3 * c_ymarg
	GuiControl, Move, % IdEvTt_T25, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControl, Hide, % IdEvTt_T25
	GuiControl, Move, % IdEvTt_DDL2, % "x+" . v_xNext . A_Space . "y+" . v_yNext . A_Space . "w+" . v_wNext
	v_xNext := c_xmarg, v_yNext += 3 * c_HofText
	GuiControl, Move, % IdEvTt_B1, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvTt_B1
	v_xNext += v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvTt_B2, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvTt_B2
	v_xNext += v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvTt_B3, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvTt_B3
	v_xNext += v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvTt_B4, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	maxY4 := v_yNext
;#c/* commercial only beginning
;#c*/ commercial only end
	v_xNext := c_xmarg, v_yNext := c_ymarg ;beginning of static triggerstring / hostring menus
	GuiControl, Move, % IdEvSM_T1, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvSM_T1
	v_xNext += v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvSM_T2, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += c_HofText
	GuiControl, Move, % IdEvSM_R1, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvSM_R1
	v_xNext += v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvSM_R2, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += 3 * c_HofText
	GuiControl, Move, % IdEvSM_B1, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvSM_B1
	v_xNext += v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvSM_B2, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvSM_B2
	v_xNext += v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvSM_B3, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvSM_B3
	v_xNext += v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvSM_B4, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	maxY6 := v_yNext
	
	;Bottom alignment of buttons over all tabs.
	MaxY := Max(maxY1, maxY2, maxY3, maxY4, maxY5, maxY6)
	
	v_xNext := c_xmarg, v_yNext := MaxY	;alignment of tab 1:
	GuiControl, Move, % IdEvBH_B1, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvBH_B1
	v_xNext += v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvBH_B2, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvBH_B2
	v_xNext += v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvBH_B3, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvBH_B3
	v_xNext += v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvBH_B4, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvBH_B4
	v_xNext += v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvBH_B5, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext := MaxY
	
	GuiControl, Move, % IdEvMH_B1, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvMH_B1
	v_xNext += v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvMH_B2, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvMH_B2
	v_xNext += v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvMH_B3, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvMH_B3
	v_xNext += v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvMH_B4, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext := MaxY
	
	GuiControl, Move, % IdEvUH_B1, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvUH_B1
	v_xNext += v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvUH_B2, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvUH_B2
	v_xNext += v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvUH_B3, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvUH_B3
	v_xNext += v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvUH_B4, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvUH_B4
	v_xNext += v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvUH_B5, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	
	v_xNext := c_xmarg, v_yNext := MaxY
	GuiControl, Move, % IdEvTt_B1, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvTt_B1
	v_xNext += v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvTt_B2, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvTt_B2
	v_xNext += v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvTt_B3, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvTt_B3
	v_xNext += v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvTt_B4, % "x+" . v_xNext . A_Space . "y+" . v_yNext	
;#c/* commercial only beginning	
;#c*/ commercial only end	
	v_xNext := c_xmarg, v_yNext := MaxY	;alignment of tab 6: static triggerstring tips / hotstring menus
	GuiControl, Move, % IdEvSM_B1, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvSM_B1
	v_xNext += v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvSM_B2, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvSM_B2
	v_xNext += v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvSM_B3, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvSM_B3
	v_xNext += v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvSM_B4, % "x+" . v_xNext . A_Space . "y+" . v_yNext
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EvBH_R3R4()
{
	global ;assume-global mode
	Gui, GuiEvents: Submit, NoHide
	Switch EvBH_R3R4
	{
		Case 1:
		GuiControl, Enable,		% IdEvBH_T6
		GuiControl, Enable,		% IdEvBH_S1
		GuiControl, Enable,		% IdEvBH_T7
		F_EvBH_S2()
		Case 2:
		GuiControl, Disable,	% IdEvBH_T6
		GuiControl, Disable,	% IdEvBH_S1
		GuiControl, Disable,	% IdEvBH_T7
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EvBH_R7R8()
{
	global ;assume-global mode
	Gui, GuiEvents: Submit, NoHide
	Switch EvBH_R7R8
	{
		Case 1:
		GuiControl, Enable,		% IdEvBH_T12
		GuiControl, Enable,		% IdEvBH_S2
		GuiControl, Enable,		% IdEvBH_T13
		GuiControl, Enable,		% IdEvBH_S3
		GuiControl, Enable,		% IdEvBH_T14
		GuiControl, Enable,		% IdEvBH_B2
		Case 2:
		GuiControl, Disable,	% IdEvBH_T12
		GuiControl, Disable,	% IdEvBH_S2
		GuiControl, Disable,	% IdEvBH_T13
		GuiControl, Disable,	% IdEvBH_S3
		GuiControl, Disable,	% IdEvBH_T14
		GuiControl, Disable,	% IdEvBH_B2
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EvBH_R1R2()
{
	global ;assume-global mode
	Gui, GuiEvents: Submit, NoHide
	Switch EvBH_R1R2
	{
		Case 1:	;left dot
			GuiControl, Enable, 	% IdEvBH_T3
			GuiControl, Enable, 	% IdEvBH_T4
			GuiControl, Enable, 	% IdEvBH_T5
			GuiControl, Enable, 	% IdEvBH_R3
			GuiControl, Enable, 	% IdEvBH_R4
			GuiControl, Enable, 	% IdEvBH_T6
			GuiControl, Enable, 	% IdEvBH_S1
			GuiControl, Enable, 	% IdEvBH_T7
			GuiControl, Enable, 	% IdEvBH_T8
			GuiControl, Enable, 	% IdEvBH_T9
			GuiControl, Enable, 	% IdEvBH_R5
			GuiControl, Enable, 	% IdEvBH_R6
			GuiControl, Enable, 	% IdEvBH_B2
			Switch EvBH_R3R4
			{
				Case 1:
				GuiControl, Enable,		% IdEvBH_T6
				GuiControl, Enable,		% IdEvBH_S1
				GuiControl, Enable,		% IdEvBH_T7
				Case 2:
				GuiControl, Disable,	% IdEvBH_T6
				GuiControl, Disable,	% IdEvBH_S1
				GuiControl, Disable,	% IdEvBH_T7
			}
			GuiControl, Enable,		% IdEvBH_T10
			GuiControl, Enable,		% IdEvBH_R7
			GuiControl, Enable,		% IdEvBH_R8
			GuiControl, Enable,		% IdEvBH_T12
			GuiControl, Enable,		% IdEvBH_S2
			GuiControl, Enable,		% IdEvBH_T13
			GuiControl, Enable,		% IdEvBH_S3
			GuiControl, Enable,		% IdEvBH_T14

		Case 2:	;right dot
			GuiControl, Disable, 	% IdEvBH_T3
			GuiControl, Disable, 	% IdEvBH_T4
			GuiControl, Disable, 	% IdEvBH_T5
			GuiControl, Disable, 	% IdEvBH_R3
			GuiControl, Disable, 	% IdEvBH_R4
			GuiControl, Disable, 	% IdEvBH_T6
			GuiControl, Disable, 	% IdEvBH_S1
			GuiControl, Disable, 	% IdEvBH_T7
			GuiControl, Disable, 	% IdEvBH_T8
			GuiControl, Disable, 	% IdEvBH_T9
			GuiControl, Disable, 	% IdEvBH_R5
			GuiControl, Disable, 	% IdEvBH_R6

			GuiControl, Disable,	% IdEvBH_T10
			GuiControl, Disable,	% IdEvBH_R7
			GuiControl, Disable,	% IdEvBH_R8
			GuiControl, Disable,	% IdEvBH_T12
			GuiControl, Disable,	% IdEvBH_S2
			GuiControl, Disable,	% IdEvBH_T13
			GuiControl, Disable,	% IdEvBH_S3
			GuiControl, Disable,	% IdEvBH_T14
			GuiControl, Disable, 	% IdEvBH_B2
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EvBH_B1() ;Events Basic Hotstring (is triggered) Button Tooltip test
{
	global ;assume-global mode
	local	tmp_OHTtEn := false, tmp_OHTD := 0, tmp_OHTP := 0 ;temporary variables, for testing purpose
	Gui, GuiEvents: Submit, NoHide
	if (EvBH_R1R2 = 1)
	{
		if (EvBH_R5R6 = 1)
		{
			if (A_CaretX and A_CaretY)
			{
				Gui, Tt_HWT: Show, % "x" . A_CaretX + 20 . A_Space . "y" . A_CaretY - 20	;Tooltip _ Hotstring Was Triggered
				if (EvBH_R3R4 = 1)
					SetTimer, TurnOff_OHE, % "-" . EvBH_S1, 40 ;Priority = 40 to avoid conflicts with other threads 
			}
			else
			{
				MouseGetPos, v_MouseX, v_MouseY
				OutputDebug, % "EvBH_R3R4:" . EvBH_R3R4 . A_Space . "ini_OHTD:" . ini_OHTD . A_Space . "EvBH_S1:" . EvBH_S1 . "`n"
				Gui, Tt_HWT: Show, % "x" v_MouseX + 20 . A_Space . "y" . v_MouseY - 20 	;Tooltip _ Hotstring Was Triggered
				if (EvBH_R3R4 = 1)
					SetTimer, TurnOff_OHE, % "-" . EvBH_S1, 40 ;Priority = 40 to avoid conflicts with other threads 
			}
		}
		if (EvBH_R5R6 = 2)
		{
			MouseGetPos, v_MouseX, v_MouseY
			Gui, Tt_HWT: Show, % "x" v_MouseX + 20 . A_Space . "y" . v_MouseY - 20 	;Tooltip _ Hotstring Was Triggered
			if (EvBH_R3R4 = 1)
				SetTimer, TurnOff_OHE, % "-" . EvBH_S1, 40 ;Priority = 40 to avoid conflicts with other threads 
		}
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EvBH_B2()	;Events Basic Hotstring (is triggered) Button Sound test
{
	global ;assume-global mode
	SoundBeep, % EvBH_S2, % EvBH_S3
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EvBH_B5()	;Events Basic Hotstring (is triggered) Button Cancel
{
	global ;assume-global mode
	Gui, Tt_HWT: Hide			;Tooltip: Basic hotstring was triggered
     F_CloseSubGui(WhatGuiToDestroy := "GuiEvents")
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EvBH_B3()	;Events Basic Hotstring (is triggered) Button Apply
{
	global ;assume-global mode
	Gui, GuiEvents: Submit, NoHide
	Switch EvBH_R1R2	;Tooltip enable
	{
		Case 1:	ini_OHTtEn := true
		Case 2:	ini_OHTtEn := false
	}
	Switch EvBH_R3R4	;Finite timeout
	{
		Case 1:	ini_OHTD := EvBH_S1
		Case 2:	ini_OHTD := 0
	}
	Switch EvBH_R5R6	;Tooltip position
	{
		Case 1:	ini_OHTP := 1
		Case 2:	ini_OHTP := 2
	}
	Switch EvBH_R7R8	;Sound enable
	{
		Case 1:	ini_OHSEn := 1
		Case 2:	ini_OHSEn := 0
	}
	ini_OHSF := EvBH_S2, ini_OHSD := EvBH_S3
	IniWrite, % ini_OHTtEn, 	% ini_HADConfig, Event_BasicHotstring, 	OHTtEn
	IniWrite, % ini_OHTD,	% ini_HADConfig, Event_BasicHotstring,	OHTD
	IniWrite, % ini_OHTP,	% ini_HADConfig, Event_BasicHotstring,	OHTP
	IniWrite, % ini_OHSEn, 	% ini_HADConfig, Event_BasicHotstring,	OHSEn
	IniWrite, % ini_OHSF,	% ini_HADConfig, Event_BasicHotstring,	OHSF
	IniWrite, % ini_OHSD,	% ini_HADConfig, Event_BasicHotstring,	OHSD
	Gui, Tt_HWT: Hide			;Tooltip: Basic hotstring was triggered
	F_EvTab3(true)	;to memory that something was applied
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EvBH_B4()	;Events Basic Hotstring (is triggered) Button Close
{
	global ;assume-global mode
	Gui, GuiEvents: Submit
	Switch EvBH_R1R2	;Tooltip enable
	{
		Case 1:	ini_OHTtEn := true
		Case 2:	ini_OHTtEn := false
	}
	Switch EvBH_R3R4	;Finite timeout
	{
		Case 1:	ini_OHTD := EvBH_S1
		Case 2:	ini_OHTD := 0
	}
	Switch EvBH_R5R6	;Tooltip position
	{
		Case 1:	ini_OHTP := 1
		Case 2:	ini_OHTP := 2
	}
	Switch EvBH_R7R8	;Sound enable
	{
		Case 1:	ini_OHSEn := 1
		Case 2:	ini_OHSEn := 0
	}
	ini_OHSF := EvBH_S2, ini_OHSD := EvBH_S3
	IniWrite, % ini_OHTtEn, 	% ini_HADConfig, Event_BasicHotstring, 	OHTtEn
	IniWrite, % ini_OHTD,	% ini_HADConfig, Event_BasicHotstring,	OHTD
	IniWrite, % ini_OHTP,	% ini_HADConfig, Event_BasicHotstring,	OHTP
	IniWrite, % ini_OHSEn, 	% ini_HADConfig, Event_BasicHotstring,	OHSEn
	IniWrite, % ini_OHSF,	% ini_HADConfig, Event_BasicHotstring,	OHSF
	IniWrite, % ini_OHSD,	% ini_HADConfig, Event_BasicHotstring,	OHSD
	Gui, Tt_HWT: Hide			;Tooltip: Basic hotstring was triggered
	F_EvTab3(true)	;to memory that something was applied
     F_CloseSubGui(WhatGuiToDestroy := "GuiEvents")
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EvBH_S3()
{
	global ;assume-global mode
	GuiControl,, % IdEvBH_T14, % TransA["Sound duration [ms]"] . ":" . A_Space . EvBH_S3
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EvBH_S2()
{
	global ;assume-global mode
	GuiControl,, % IdEvBH_T13, % TransA["Sound frequency"] . ":" . A_Space . EvBH_S2
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EvBH_S1()
{
	global ;assume-global mode
	GuiControl,, % IdEvBH_T7, % TransA["Timeout value [ms]"] . ":" . A_Space . EvBH_S1
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_GuiEvents_LoadValues()
{	;This function loads state of ini_* configuration parameter into GuiControls
	global ;assume-global mode
	
	Switch ini_OHTtEn
	{
		Case true: 	GuiControl,, % IdEvBH_R1, 1
		Case false: 	GuiControl,, % IdEvBH_R2, 1
	}
	Switch ini_OHTD
	{
		Case 0: 		GuiControl,, % IdEvBH_R4, 1
		Default:		GuiControl,, % IdEvBH_R3, 1
	}
	GuiControl,, % IdEvBH_S1, 	% ini_OHTD
	GuiControl,, % IdEvBH_T7, 	% TransA["Timeout value [ms]"] . ":" . A_Space . ini_OHTD
	Switch ini_OHTP
	{
		Case 1: 		GuiControl,, % IdEvBH_R5, 1
		Case 2: 		GuiControl,, % IdEvBH_R6, 1
	}
	Switch ini_OHSEn
	{
		Case true: 	GuiControl,, % IdEvBH_R7, 1
		Case false: 	GuiControl,, % IdEvBH_R8, 1
	}
	GuiControl,, % IdEvBH_S2, 	% ini_OHSF
	GuiControl,, % IdEvBH_T13, 	% TransA["Sound frequency"] . ":" 		. A_Space . ini_OHSF
	GuiControl,, % IdEvBH_S3, 	% ini_OHSD
	GuiControl,, % IdEvBH_T14, 	% TransA["Sound duration [ms]"] . ":" 	. A_Space . ini_OHSD
	
	Switch ini_MHMP
	{
		Case 1: 		GuiControl,, % IdEvMH_R1, 1
		Case 2: 		GuiControl,, % IdEvMH_R2, 1
	}
	Switch ini_MHSEn
	{
		Case true: 	GuiControl,, % IdEvMH_R3, 1
		Case false: 	GuiControl,, % IdEvMH_R4, 1
	}
	GuiControl,, % IdEvMH_S1, 	% ini_MHSF
	GuiControl,, % IdEvMH_T7, 	% TransA["Sound frequency"] . ":" 		. A_Space . ini_MHSF
	GuiControl,, % IdEvMH_S2, 	% ini_MHSD
	GuiControl,, % IdEvMH_T8, 	% TransA["Sound duration [ms]"] . ":" 	. A_Space . ini_MHSD
	
	Switch ini_UHTtEn
	{
		Case true: 	GuiControl,, % IdEvUH_R1, 1
		Case false: 	GuiControl,, % IdEvUH_R2, 1
	}
	Switch ini_UHTD
	{
		Case 0: 		GuiControl,, % IdEvUH_R4, 1
		Default:		GuiControl,, % IdEvUH_R3, 1
	}
	GuiControl,, % IdEvUH_S1, 	% ini_UHTD
	GuiControl,, % IdEvUH_T7, 	% TransA["Timeout value [ms]"] . ":" . A_Space . ini_UHTD
	Switch ini_UHTP
	{
		Case 1: 		GuiControl,, % IdEvUH_R5, 1
		Case 2: 		GuiControl,, % IdEvUH_R6, 1
	}
	Switch ini_UHSEn
	{
		Case true: 	GuiControl,, % IdEvUH_R7, 1
		Case false: 	GuiControl,, % IdEvUH_R8, 1
	}
	GuiControl,, % IdEvUH_S2, 	% ini_UHSF
	GuiControl,, % IdEvUH_T13, 	% TransA["Sound frequency"] . ":" 		. A_Space . ini_UHSF
	GuiControl,, % IdEvUH_S3, 	% ini_UHSD
	GuiControl,, % IdEvUH_T14, 	% TransA["Sound duration [ms]"] . ":" 	. A_Space . ini_UHSD
	Switch ini_TTTtEn
	{
		Case true: 	GuiControl,, % IdEvTt_R1, 1
		Case false: 	GuiControl,, % IdEvTt_R2, 1
	}
	Switch ini_TTTD
	{
		Case 0: 		GuiControl,, % IdEvTt_R4, 1
		Default:		GuiControl,, % IdEvTt_R3, 1
	}
	GuiControl,, % IdEvTt_S1, 	% ini_TTTD
	GuiControl,, % IdEvTt_T8, 	% TransA["Timeout value [ms]"] . ":" . A_Space . ini_TTTD
	Switch ini_TTTP
	{
		Case 1: 		GuiControl,, % IdEvTt_R5, 1
		Case 2: 		GuiControl,, % IdEvTt_R6, 1
	}
	GuiControl,, % IdEvTt_C1,	% ini_TipsSortAlphabetically
	GuiControl,, % IdEvTt_C2,	% ini_TipsSortByLength
	GuiControl,, % IdEvTt_S2,	% ini_MNTT
	GuiControl,, % IdEvTt_T18,	% ini_MNTT
	GuiControl, ChooseString, % IdEvTt_DDL1, % ini_TASAC
	Switch ini_TTCn
	{
		Case 1:	
		GuiControl, ChooseString, % IdEvTt_DDL2, % TransA["Triggerstring tips"]
		GuiControl,, % IdEvSM_R2, 1
		Case 2:	
		GuiControl, ChooseString, % IdEvTt_DDL2, % TransA["Triggerstring tips"] . A_Space . "+" . A_Space . TransA["Triggers"]
		GuiControl,, % IdEvSM_R2, 1
		Case 3:	
		GuiControl, ChooseString, % IdEvTt_DDL2, % TransA["Triggerstring tips"] . A_Space . "+" . A_Space . TransA["Triggers"] . A_Space . "+" . A_Space . TransA["Hotstrings"]
		GuiControl,, % IdEvSM_R2, 1
		Case 4:	
		GuiControl,, % IdEvSM_R1, 1
	}
;#c/* commercial only beginning	
;#c*/ commercial only end
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_LoadATStyling()
{
	global ;assume-global mode
	ini_ATBgrCol		:= "green"
,	ini_ATTyFaceCol	:= "black"
,	ini_ATTyFaceFont	:= "Consolas"
,	ini_ATTySize		:= 10
	
	IniRead, ini_ATBgrCol, 			% ini_HADConfig, EvStyle_AT, ATBackgroundColor, green
	if (!ini_ATBgrCol)
		ini_ATBgrCol := "green"
	if (ini_ATBgrCol = "custom")
		IniRead, ini_ATBgrColCus,	% ini_HADConfig, EvStyle_AT, ATBackgroundColorCustom
	IniRead, ini_ATTyFaceCol, 		% ini_HADConfig, EvStyle_AT, ATTypefaceColor, black
	if (!ini_ATTyFaceCol)
		ini_ATTyFaceCol := "black"
	if (ini_ATTyFaceCol = "custom")
		IniRead, ini_ATTyFaceColCus,	% ini_HADConfig, EvStyle_AT, ATTypefaceColorCustom
	IniRead, ini_ATTyFaceFont, 		% ini_HADConfig, EvStyle_AT, ATTypefaceFont, Consolas
	if (!ini_ATTyFaceFont)
		ini_ATTyFaceFont := "Consolas"
	IniRead, ini_ATTySize,	 		% ini_HADConfig, EvStyle_AT, ATTypefaceSize, 10
	if (!ini_ATTySize)
		ini_ATTySize := 10
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_LoadHTStyling()
{
	global ;assume-global mode of operation
	ini_HTBgrCol		:= "yellow"
,	ini_HTTyFaceCol	:= "black"
,	ini_HTTyFaceFont	:= "Courier"
,	ini_HTTySize		:= 10
	
	IniRead, ini_HTBgrCol, 			% ini_HADConfig, EvStyle_HT, HTBackgroundColor, yellow
	if (!ini_HTBgrCol)
		ini_HTBgrCol := "yellow"
	if (ini_HTBgrCol = "custom")
		IniRead, ini_HTBgrColCus,	% ini_HADConfig, EvStyle_HT, HTBackgroundColorCustom
	IniRead, ini_HTTyFaceCol, 		% ini_HADConfig, EvStyle_HT, HTTypefaceColor, black
	if (!ini_HTTyFaceCol)
		ini_HTTyFaceCol := "black"
	if (ini_HTTyFaceCol = "custom")
		IniRead, ini_HTTyFaceColCus,	% ini_HADConfig, EvStyle_HT, HTTypefaceColorCustom
	IniRead, ini_HTTyFaceFont, 		% ini_HADConfig, EvStyle_HT, HTTypefaceFont, Courier
	if (!ini_HTTyFaceFont)
		ini_HTTyFaceFont := "Courier"
	IniRead, ini_HTTySize,	 		% ini_HADConfig, EvStyle_HT, HTTypefaceSize, 10
	if (!ini_HTTySize)
		ini_HTTySize := 10
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_LoadUHStyling()
{
	global ;assume-global mode
	ini_UHBgrCol		:= "yellow"
,	ini_UHTyFaceCol	:= "black"
,	ini_UHTyFaceFont	:= "Courier"
,	ini_UHTySize		:= 10
	
	IniRead, ini_UHBgrCol, 			% ini_HADConfig, EvStyle_UH, UHBackgroundColor, yellow
	if (!ini_UHBgrCol)
		ini_UHBgrCol := "yellow"
	if (ini_UHBgrCol = "custom")
		IniRead, ini_UHBgrColCus,	% ini_HADConfig, EvStyle_UH, UHBackgroundColorCustom
	IniRead, ini_UHTyFaceCol, 		% ini_HADConfig, EvStyle_UH, UHTypefaceColor, black
	if (!ini_UHTyFaceCol)
		ini_UHTyFaceCol := "black"
	if (ini_UHTyFaceCol = "custom")
		IniRead, ini_UHTyFaceColCus,	% ini_HADConfig, EvStyle_UH, UHTypefaceColorCustom
	IniRead, ini_UHTyFaceFont, 		% ini_HADConfig, EvStyle_UH, UHTypefaceFont, Courier
	if (!ini_UHTyFaceFont)
		ini_UHTyFaceFont := "Courier"
	IniRead, ini_UHTySize,	 		% ini_HADConfig, EvStyle_UH, UHTypefaceSize, 10
	if (!ini_UHTySize)
		ini_UHTySize := 10
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_LoadHMStyling()
{
	global ;assume-global mode
	ini_HMBgrCol		:= "white"
,	ini_HMTyFaceCol	:= "black"
,	ini_HMTyFaceFont	:= "Consolas"
,	ini_HMTySize		:= 10
	
	IniRead, ini_HMBgrCol, 			% ini_HADConfig, EvStyle_HM, HMBackgroundColor, white
	if (!ini_HMBgrCol)
		ini_HMBgrCol := "white"
	if (ini_HMBgrCol = "custom")
		IniRead, ini_HMBgrColCus,	% ini_HADConfig, EvStyle_HM, HMBackgroundColorCustom
	IniRead, ini_HMTyFaceCol, 		% ini_HADConfig, EvStyle_HM, HMTypefaceColor, black
	if (!ini_HMTyFaceCol)
		ini_HMTyFaceCol := "black"
	if (ini_HMTyFaceCol = "custom")
		IniRead, ini_HMTyFaceColCus,	% ini_HADConfig, EvStyle_HM, HMTypefaceColorCustom
	IniRead, ini_HMTyFaceFont, 		% ini_HADConfig, EvStyle_HM, HMTypefaceFont, Consolas
	if (!ini_HMTyFaceFont)
		ini_HMTyFaceFont := "Consolas"
	IniRead, ini_HMTySize,	 		% ini_HADConfig, EvStyle_HM, HMTypefaceSize, 10
	if (!ini_HMTySize)
		ini_HMTySize := 10
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_LoadTTStyling()
{
	global ;assume-global mode of operation
	ini_TTBgrCol		:= "white"
,	ini_TTTyFaceCol	:= "black"
,	ini_TTTyFaceFont	:= "Consolas"
,	ini_TTTySize		:= 10
	
	IniRead, ini_TTBgrCol, 			% ini_HADConfig, EvStyle_TT, TTBackgroundColor, white
	if (!ini_TTBgrCol)
		ini_TTBgrCol := "white"
	if (ini_TTBgrCol = "custom")
		IniRead, ini_TTBgrColCus,	% ini_HADConfig, EvStyle_TT, TTBackgroundColorCustom
	IniRead, ini_TTTyFaceCol, 		% ini_HADConfig, EvStyle_TT, TTTypefaceColor, black
	if (!ini_TTTyFaceCol)
		ini_TTTyFaceCol := "black"
	if (ini_TTTyFaceCol = "custom")
		IniRead, ini_TTTyFaceColCus,	% ini_HADConfig, EvStyle_TT, TTTypefaceColorCustom
	IniRead, ini_TTTyFaceFont, 		% ini_HADConfig, EvStyle_TT, TTTypefaceFont, Consolas
	if (!ini_TTTyFaceFont)
		ini_TTTyFaceFont := "Consolas"
	IniRead, ini_TTTySize,	 		% ini_HADConfig, EvStyle_TT, TTTypefaceSize, 10
	if (!ini_TTTySize)
		ini_TTTySize := 10
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_GuiStyling_Section(TabId)
{
	global ;assume-global mode of operation
	local DynVarRef := ""	;dynamic variable: https://www.autohotkey.com/docs/Language.htm#dynamic-variables

	Gui, EventsStyling: Add,	Text, 		% "HwndId" . TabId . "styling_T1",				% TransA["Background color"] . ":"
	Gui, EventsStyling: Font,	% "s" . c_FontSize + 2 . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, EventsStyling: Add,	Text, 		% "HwndId" . TabId . "styling_T2",				ⓘ
	T_SBackgroundColorInfo 	:= func("F_ShowLongTooltip").bind(TransA["T_SBackgroundColorInfo"])
,	DynVarRef 			:= "Id" . TabId . "styling_T2"
	GuiControl, +g, 					% %DynVarRef%, 							% T_SBackgroundColorInfo
	Gui, EventsStyling: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, % c_FontType
	Gui, EventsStyling: Add,	DropDownList,	% "HwndId" . TabId . "styling_DDL1" . A_Space . "v" . TabId . "S_DDL1" . A_Space . "g" . "F_EventsStyling_DDL1"
,		% TransA["black"] . "|" . TransA["silver"] . "|" . TransA["gray"] . "|" . TransA["white"] . "||" . TransA["maroon"] . "|" . TransA["red"] . "|" . TransA["purple"] . "|" . TransA["fuchsia"] . "|" . TransA["green"] . "|" . TransA["lime"] . "|" . TransA["olive"] . "|" . TransA["yellow"] . "|" . TransA["navy"] . "|" . TransA["blue"] . "|" . TransA["teal"] . "|" . TransA["aqua"] . "|" . TransA["custom"]
	Gui, EventsStyling: Add,	Edit,		% "HwndId" . TabId . "styling_E1" . A_Space . "Limit6"
,	% TransA["HTML color RGB value, e.g. 00FF00"]
	Gui, EventsStyling: Add,	Button,		% "HwndId" . TabId . "styling_B1" . A_Space . "g" . "F_EventsStyling_B1"
,		% TransA["Restore default"]
	Gui, EventsStyling: Add,	Text, 		% "HwndId" . TabId . "styling_T3",				% TransA["Typeface color"] . ":"
	Gui, EventsStyling: Font,	% "s" . c_FontSize + 2 . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, EventsStyling: Add,	Text,		% "HwndId" . TabId . "styling_T4",				ⓘ
	T_STypefaceColor 	:= func("F_ShowLongTooltip").bind(TransA["T_STypefaceColor"])
,	DynVarRef 		:= "Id" . TabId . "styling_T4"
	GuiControl +g, 					% %DynVarRef%,								% T_STypefaceColor
	Gui, EventsStyling: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, % c_FontType
	Gui, EventsStyling: Add,	DropDownList,	% "HwndId" . TabId . "styling_DDL2" . A_Space . "v" . TabId . "S_DDL2" . A_Space . "g" . "F_EventsStyling_DDL2"
,		% TransA["black"] . "||" . TransA["silver"] . "|" . TransA["gray"] . "|" . TransA["white"] . "|" . TransA["maroon"] . "|" . TransA["red"] . "|" . TransA["purple"] . "|" . TransA["fuchsia"] . "|" . TransA["green"] . "|" . TransA["lime"] . "|" . TransA["olive"] . "|" . TransA["yellow"] . "|" . TransA["navy"] . "|" . TransA["blue"] . "|" . TransA["teal"] . "|" . TransA["aqua"] . "|" . TransA["custom"]
	Gui, EventsStyling: Add,	Edit,		% "HwndId" . TabId . "styling_E2" . A_Space . "Limit6"
,		% TransA["HTML color RGB value, e.g. 00FF00"]
	Gui, EventsStyling: Add,	Button,		% "HwndId" . TabId . "styling_B2" . A_Space . "g" . "F_EventsStyling_B2"
,		% TransA["Restore default"]
	Gui, EventsStyling: Add,	Text, 		% "HwndId" . TabId . "styling_T5",				% TransA["Typeface font"] . ":"
	Gui, EventsStyling: Font,	% "s" . c_FontSize + 2 . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, EventsStyling: Add,	Text, 		% "HwndId" . TabId . "styling_T6",				ⓘ
	T_STypefaceFont 	:= func("F_ShowLongTooltip").bind(TransA["T_STypefaceFont"])
,	DynVarRef 		:= "Id" . TabId . "styling_T6"
	GuiControl +g, 					% %DynVarRef%, 							% T_STypefaceFont
	Gui, EventsStyling: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, % c_FontType
	Gui, EventsStyling: Add,	DropDownList,	% "HwndId" . TabId . "styling_DDL3" . A_Space . "v" . TabId . "S_DDL3"
,		Arial|Calibri|Comic Sans MS|Consolas||Courier|Fixedsys|Lucida Console|Microsoft Sans Serif|Script|System|Tahoma|Times New Roman|Verdana
	Gui, EventsStyling: Add,	Button,		% "HwndId" . TabId . "styling_B3" . A_Space . "g" . "F_EventsStyling_B3" 
,		% TransA["Restore default"]
	Gui, EventsStyling: Add,	Text, 		% "HwndId" . TabId . "styling_T7",				% TransA["Typeface size"] . ":"
	Gui, EventsStyling: Font,	% "s" . c_FontSize + 2 . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, EventsStyling: Add,	Text, 		% "HwndId" . TabId . "styling_T8",				ⓘ
	T_STypefaceSize 	:= func("F_ShowLongTooltip").bind(TransA["T_STypefaceSize"])
,	DynVarRef 		:= "Id" . TabId . "styling_T8"
	GuiControl +g, 		% %DynVarRef%,											% T_STypefaceSize
	Gui, EventsStyling: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, % c_FontType
	Gui, EventsStyling: Add,	DropDownList,	% "HwndId" . TabId . "styling_DDL4" . A_Space . "v" . TabId . "S_DDL4"
,		7|8|9|10||11|12|13|14|15|16|17|18|19|20
	Gui, EventsStyling: Add,	Button,		% "HwndId" . TabId . "styling_B4" . A_Space . "g" . "F_EventsStyling_B4"
,		% TransA["Restore default"]
	Gui, EventsStyling: Add,	Text, 		% "HwndId" . TabId . "styling_T9",				% TransA["Preview"] . ":"
	Gui, EventsStyling: Font,	% "s" . c_FontSize + 2 . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, EventsStyling: Add,	Text, 		% "HwndId" . TabId . "styling_T10",			ⓘ
	T_StylPreview 		:= func("F_ShowLongTooltip").bind(TransA["T_StylPreview"])
,	DynVarRef 		:= "Id" . TabId . "styling_T10"
	GuiControl +g, 		% %DynVarRef%, 										% T_StylPreview
	Gui, EventsStyling: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, % c_FontType
	Gui, EventsStyling: Add,	Listbox, 		% "HwndId" . TabId . "styling_LB1" . A_Space . "r5"
,		% TransA["Row"] . " 1|" . TransA["Row"] . " 2|" . TransA["Row"] . " 3|" . TransA["Row"] . " 4|" . TransA["Row"] . " 5"
	Gui, EventsStyling: Add,	Button,		% "HwndId" . TabId . "styling_B5" . A_Space . "g" . "F_EventsStyling_B5"
,		% TransA["Test styling"]
	Gui, EventsStyling: Add,	Button,		% "HwndId" . TabId . "styling_B6" . A_Space . "g" . "F_EventsStyling_B6" . A_Space . "+Default"
,		% TransA["Apply"]
	Gui, EventsStyling: Add,	Button,		% "HwndId" . TabId . "styling_B7" . A_Space . "g" . "F_EventsStyling_B7"
,		% TransA["Close"]
	Gui, EventsStyling: Add,	Button,		% "HwndId" . TabId . "styling_B8" . A_Space . "g" . "F_EventsStyling_B8"
,		% TransA["Cancel"]
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EventsStyling_DDL_TypefaceCol(WhichItem)
{
	global ;assume-global mode of operation
	local OutputVarTemp := "",	DynVarRef1 := ""		;dynamic variable: https://www.autohotkey.com/docs/Language.htm#dynamic-variables

	DynVarRef1 := "Id" . WhichItem . "styling_DDL2"
	GuiControlGet, OutputVarTemp,, % %DynVarRef1%
	DynVarRef1 := "Id" . WhichItem . "styling_E2"
	if (OutputVarTemp = "custom")
		GuiControl, Enable, % %DynVarRef1%
	else
	{
		GuiControl,, % %DynVarRef1%, % TransA["HTML color RGB value, e.g. 00FF00"] 
		GuiControl, Disable, % %DynVarRef1%
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EventsStyling_DDL2()
{
	global ;assume-global mode of operation
	local OutputVarTemp := ""
	Switch EventsStylingTab3
	{
		Case % TransA["Triggerstring tips styling"]:				F_EventsStyling_DDL_TypefaceCol("TT")
		Case % TransA["Hotstring menu styling"]:				F_EventsStyling_DDL_TypefaceCol("HM")
;#c/* commercial only beginning		
;#c*/ commercial only end		
		Case % TransA["Tooltip: ""Hotstring was triggered"""]:		F_EventsStyling_DDL_TypefaceCol("HT")
		Case % TransA["Tooltip: ""Undid the last hotstring"""]:	F_EventsStyling_DDL_TypefaceCol("UH")
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EventsStyling_DDL_BackgCol(WhichItem)
{
	global ;assume-global mode of operation
	local OutputVarTemp := "",	DynVarRef1 := ""		;dynamic variable: https://www.autohotkey.com/docs/Language.htm#dynamic-variables

	DynVarRef1 := "Id" . WhichItem . "styling_DDL1"
	GuiControlGet, OutputVarTemp,, % %DynVarRef1%
	DynVarRef1 := "Id" . WhichItem . "styling_E1"
	if (OutputVarTemp = "custom")
		GuiControl, Enable, % %DynVarRef1%
	else
	{
		GuiControl,, % %DynVarRef1%, % TransA["HTML color RGB value, e.g. 00FF00"] 
		GuiControl, Disable, % %DynVarRef1%
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EventsStyling_DDL1()
{
	global ;assume-global mode of operation
	local OutputVarTemp := ""
	Switch EventsStylingTab3
	{
		Case % TransA["Triggerstring tips styling"]:				F_EventsStyling_DDL_BackgCol("TT")
		Case % TransA["Hotstring menu styling"]:				F_EventsStyling_DDL_BackgCol("HM")
;#c/* commercial only beginning
;#c*/ commercial only end
		Case % TransA["Tooltip: ""Hotstring was triggered"""]:		F_EventsStyling_DDL_BackgCol("HT")
		Case % TransA["Tooltip: ""Undid the last hotstring"""]:	F_EventsStyling_DDL_BackgCol("UH")
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EventsStyling_B1()	;button: Restore default, background color
{
	global ;assume-global mode of operation
	Switch EventsStylingTab3
	{
		Case % TransA["Triggerstring tips styling"]:
			ini_TTBgrCol := "white"
			GuiControl, ChooseString, % IdTTstyling_DDL1, % ini_TTBgrCol
			GuiControl,, % IdTTstyling_E1, % TransA["HTML color RGB value, e.g. 00FF00"] 
			GuiControl, Disable, % IdTTstyling_E1

		Case % TransA["Hotstring menu styling"]:
			ini_HMBgrCol := "white"
			GuiControl, ChooseString, % IdHMstyling_DDL1, % ini_HMBgrCol
			GuiControl,, % IdHMstyling_E1, % TransA["HTML color RGB value, e.g. 00FF00"] 
			GuiControl, Disable, % IdHMstyling_E1
;#c/* commercial only beginning
;#c*/ commercial only end		
		Case % TransA["Tooltip: ""Hotstring was triggered"""]:
			ini_HTBgrCol := "yellow"
			GuiControl, ChooseString, % IdHTstyling_DDL1, % ini_HTBgrCol
			GuiControl,, % IdHTstyling_E1, % TransA["HTML color RGB value, e.g. 00FF00"] 
			GuiControl, Disable, % IdHTstyling_E1

		Case % TransA["Tooltip: ""Undid the last hotstring"""]:
			ini_UHBgrCol := "yellow"
			GuiControl, ChooseString, % IdUHstyling_DDL1, % ini_UHBgrCol
			GuiControl,, % IdUHstyling_E1, % TransA["HTML color RGB value, e.g. 00FF00"] 
			GuiControl, Disable, % IdUHstyling_E1
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EventsStyling_B2()	;button: Restore default, typeface color
{
	global ;assume-global mode of operation

	Switch EventsStylingTab3
	{
		Case % TransA["Triggerstring tips styling"]:
			ini_TTTyFaceCol := "black"
			GuiControl, ChooseString, % IdTTstyling_DDL2, % ini_TTTyFaceCol
			GuiControl,, % IdTTstyling_E2, % TransA["HTML color RGB value, e.g. 00FF00"] 
			GuiControl, Disable, % IdTTstyling_E2

		Case % TransA["Hotstring menu styling"]:
			ini_HMTyFaceCol := "black"
			GuiControl, ChooseString, % IdHMstyling_DDL2, % ini_HMTyFaceCol
			GuiControl,, % IdHMstyling_E2, % TransA["HTML color RGB value, e.g. 00FF00"] 
			GuiControl, Disable, % IdHMstyling_E2
;#c/* commercial only beginning
;#c*/ commercial only end
		Case % TransA["Tooltip: ""Hotstring was triggered"""]:
			ini_HTTyFaceCol := "black"
			GuiControl, ChooseString, % IdHTstyling_DDL2, % ini_HTTyFaceCol
			GuiControl,, % IdHTstyling_E2, % TransA["HTML color RGB value, e.g. 00FF00"] 
			GuiControl, Disable, % IdHTstyling_E2

		Case % TransA["Tooltip: ""Undid the last hotstring"""]:
			ini_UHTyFaceCol := "black"
			GuiControl, ChooseString, % IdUHstyling_DDL2, % ini_UHTyFaceCol
			GuiControl,, % IdUHstyling_E2, % TransA["HTML color RGB value, e.g. 00FF00"] 
			GuiControl, Disable, % IdUHstyling_E2
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EventsStyling_B3()	;button: Restore default, typeface font
{
	global ;assume-global mode of operation

	Switch EventsStylingTab3
	{
		Case % TransA["Triggerstring tips styling"]:
			ini_TTTyFaceFont := "Consolas"
			GuiControl, ChooseString, % IdTTstyling_DDL3, % ini_TTTyFaceFont

		Case % TransA["Hotstring menu styling"]:
			ini_HMTyFaceFont := "Consolas"
			GuiControl, ChooseString, % IdHMstyling_DDL3, % ini_HMTyFaceFont
;#c/* commercial only beginning
;#c*/ commercial only end
		Case % TransA["Tooltip: ""Hotstring was triggered"""]:
			ini_HTTyFaceFont := "Courier"
			GuiControl, ChooseString, % IdHTstyling_DDL3, % ini_HTTyFaceFont

		Case % TransA["Tooltip: ""Undid the last hotstring"""]:	
			ini_UHTyFaceFont := "Courier"
			GuiControl, ChooseString, % IdUHstyling_DDL3, % ini_UHTyFaceFont
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EventsStyling_B4()	;button: Restore default, font size
{
	global ;assume-global mode of operation

	Switch EventsStylingTab3
	{
		Case % TransA["Triggerstring tips styling"]:
			ini_TTTySize := 10
			GuiControl, ChooseString, % IdTTstyling_DDL4, % ini_TTTySize

		Case % TransA["Hotstring menu styling"]:
			ini_HMTySize := 10
			GuiControl, ChooseString, % IdHMstyling_DDL4, % ini_HMTySize
;#c/* commercial only beginning
;#c*/ commercial only end		
		Case % TransA["Tooltip: ""Hotstring was triggered"""]:
			ini_HTTySize := 10
			GuiControl, ChooseString, % IdHTstyling_DDL4, % ini_HTTySize
		
		Case % TransA["Tooltip: ""Undid the last hotstring"""]:
			ini_UHTySize := 10
			GuiControl, ChooseString, % IdUHstyling_DDL4, % ini_UHTySize
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EventsStyling_B5()	;button: Test styling
{
	global ;assume-global mode of operation
	local 	Window1X := 0, Window1Y := 0, Window1W := 0, Window1H := 0
,			OutputVarTemp := 0, OutputVarTempX := 0, OutputVarTempY := 0, OutputVarTempW := 0, OutputVarTempH := 0
,			TTS_TTBgrColCus := "", TTS_TTTyFaceColCus := "" 
,			HMS_TTBgrColCus := "", HMS_TTTyFaceColCus := "" 
;#c/* commercial only beginning 	
;#c*/ commercial only end
,			HTS_TTBgrColCus := "", HTS_TTTyFaceColCus := "" 
,			UHS_TTBgrColCus := "", UHS_TTTyFaceColCus := "" 
, 			a_TTMenuPos 	 := []
,			TempText := TransA["Hotstring was triggered!"] . A_Space . "[" . F_ParseHotkey(ini_HK_UndoLH) . "]" . A_Space . TransA["to undo."]

	IdHTDemo_LB1 := 0, IdHTDemo_T1 := 0	;global variables

	Gui, EventsStyling: Submit, NoHide
	Switch EventsStylingTab3
	{
		Case % TransA["Triggerstring tips styling"]:
			if (TTS_DDL1 = "custom")
			{
				GuiControlGet, OutputVarTemp,, % IdTTstyling_E1
				if (!RegExMatch(OutputVarTemp, "^[[:xdigit:]]{6}"))
				{
					MsgBox, 48, % SubStr(A_ScriptName, 1, -4) .  ":" . A_Space . TransA["warning"], % TransA["Incorrect value. Select custom RGB hex value. Please try again."] . A_Space . "`n" 
					Gui, TTDemo: Destroy
					return
				}
				else 
					TTS_TTBgrColCus := OutputVarTemp
			}
			if (TTS_DDL2 = "custom")
			{
				GuiControlGet, OutputVarTemp,, % IdTTstyling_E2
				if (!RegExMatch(OutputVarTemp, "^[[:xdigit:]]{6}"))
				{
					MsgBox, 48, % SubStr(A_ScriptName, 1, -4) .  ":" . A_Space . TransA["warning"], % TransA["Incorrect value. Select custom RGB hex value. Please try again."] . A_Space . "`n" 
					Gui, TTDemo: Destroy
					return
				}
				else 
					TTS_TTTyFaceColCus := OutputVarTemp
			}
			WinGetPos, Window1X, Window1Y, Window1W, Window1H, % "ahk_id" . EvStylingHwnd
			ControlGetPos, OutputVarTempX, OutputVarTempY, , , , ahk_id %IdTTstyling_LB1%
			Gui, TTDemo: New, -Caption +ToolWindow +HwndTDemoHwnd
			Gui, TTDemo: Margin, 0, 0
			if (TTS_DDL1 = "custom")
				Gui, TTDemo: Color,, % TTS_TTBgrColCus
			else
				Gui, TTDemo: Color,, % TTS_DDL1
			if (TTS_DDL2 = "custom")		
				Gui, TTDemo: Font, % "s" . TTS_DDL4 . A_Space . "c" . TTS_TTTyFaceColCus, % TTS_DDL3
			else
				Gui, TTDemo: Font, % "s" . TTS_DDL4 . A_Space . "c" . TTS_DDL2, % TTS_DDL3
			Gui, TTDemo: Add, Listbox, HwndIdTDemo r5, % TransA["Row"] . " 1|" . TransA["Row"] . " 2|" . TransA["Row"] . " 3|" . TransA["Row"] . " 4|" . TransA["Row"] . " 5"
			Gui, TTDemo: Show, % "x" . Window1X + OutputVarTempX . A_Space . "y" . Window1Y + OutputVarTempY . A_Space "NoActivate"	;future: prevent parent window from moving: https://autohotkey.com/board/topic/17759-window-system-menu-manipulator-library-v20/

		Case % TransA["Hotstring menu styling"]:
			if (HMS_DDL1 = "custom")
			{
				GuiControlGet, OutputVarTemp,, % IdHMstyling_E1
				if (!RegExMatch(OutputVarTemp, "^[[:xdigit:]]{6}"))
				{
					MsgBox, 48, % SubStr(A_ScriptName, 1, -4) .  ":" . A_Space . TransA["warning"], % TransA["Incorrect value. Select custom RGB hex value. Please try again."] . A_Space . "`n" 
					Gui, HMDemo: Destroy
					return
				}
				else 
					HMS_TTBgrColCus := OutputVarTemp
			}
			if (HMS_DDL2 = "custom")
			{
				GuiControlGet, OutputVarTemp,, % IdHMstyling_E2
				if (!RegExMatch(OutputVarTemp, "^[[:xdigit:]]{6}"))
				{
					MsgBox, 48, % SubStr(A_ScriptName, 1, -4) .  ":" . A_Space . TransA["warning"], % TransA["Incorrect value. Select custom RGB hex value. Please try again."] . A_Space . "`n" 
					Gui, HMDemo: Destroy
					return
				}
				else 
					HMS_TTTyFaceColCus := OutputVarTemp
			}
			WinGetPos, Window1X, Window1Y, Window1W, Window1H, % "ahk_id" . EvStylingHwnd
			ControlGetPos, OutputVarTempX, OutputVarTempY, , , , ahk_id %IdHMstyling_LB1%
			Gui, HMDemo: New, -Caption +ToolWindow +HwndHDemoHwnd
			Gui, HMDemo: Margin, 0, 0
			if (HMS_DDL1 = "custom")
				Gui, HMDemo: Color,, % HMS_TTBgrColCus
			else
				Gui, HMDemo: Color,, % HMS_DDL1
			if (HMS_DDL2 = "custom")		
				Gui, HMDemo: Font, % "s" . HMS_DDL4 . A_Space . "c" . HMS_TTBgrColCus, % HMS_DDL3
			else
				Gui, HMDemo: Font, % "s" . HMS_DDL4 . A_Space . "c" . HMS_DDL2, % HMS_DDL3
			Gui, HMDemo: Add, Listbox, HwndIdHDemo r5, % TransA["Row"] . " 1|" . TransA["Row"] . " 2|" . TransA["Row"] . " 3|" . TransA["Row"] . " 4|" . TransA["Row"] . " 5"
			Gui, HMDemo: Show, % "x" . Window1X + OutputVarTempX . A_Space . "y" . Window1Y + OutputVarTempY . A_Space "NoActivate"	;future: prevent parent window from moving: https://autohotkey.com/board/topic/17759-window-system-menu-manipulator-library-v20/
;#c/* commercial only beginning
;#c*/ commercial only end
		Case % TransA["Tooltip: ""Hotstring was triggered"""]:
			if (HTS_DDL1 = "custom")
			{
				GuiControlGet, OutputVarTemp,, % IdHTstyling_E1
				if (!RegExMatch(OutputVarTemp, "^[[:xdigit:]]{6}"))
				{
					MsgBox, 48, % SubStr(A_ScriptName, 1, -4) .  ":" . A_Space . TransA["warning"], % TransA["Incorrect value. Select custom RGB hex value. Please try again."] . A_Space . "`n" 
					Gui, HTDemo: Destroy
					return
				}
				else 
					HTS_TTBgrColCus := OutputVarTemp
			}
			if (HTS_DDL2 = "custom")
			{
				GuiControlGet, OutputVarTemp,, % IdHTstyling_E2
				if (!RegExMatch(OutputVarTemp, "^[[:xdigit:]]{6}"))
				{
					MsgBox, 48, % SubStr(A_ScriptName, 1, -4) .  ":" . A_Space . TransA["warning"], % TransA["Incorrect value. Select custom RGB hex value. Please try again."] . A_Space . "`n" 
					Gui, HTDemo: Destroy
					return
				}
				else 
					HTS_TTTyFaceColCus := OutputVarTemp
			}
			WinGetPos, Window1X, Window1Y, Window1W, Window1H, % "ahk_id" . EvStylingHwnd
			Gui, HTDemo: New, -Caption +ToolWindow +HwndHTDemoHwnd
			Gui, HTDemo: Margin, 0, 0
			if (HTS_DDL1 = "custom")
				Gui, HTDemo: Color,, % HTS_TTBgrColCus
			else
				Gui, HTDemo: Color,, % HTS_DDL1
			if (HTS_DDL2 = "custom")		
				Gui, HTDemo: Font, % "s" . HTS_DDL4 . A_Space . "c" . HTS_TTTyFaceColCus, 	% HTS_DDL3
			else
				Gui, HTDemo: Font, % "s" . HTS_DDL4 . A_Space . "c" . HTS_DDL2, 			% HTS_DDL3

			Gui, HTDemo: Add, Text, HwndIdHTDemo_T1, % TempText
			GuiControlGet, OutputVarTemp, Pos, % IdHTDemo_T1
			GuiControl, Hide, % IdHTDemo_T1
			Gui, HTDemo: Add, ListBox, % "HwndIdHTDemo_LB1" . A_Space . "r1" . A_Space . "x" . OutputVarTempX . A_Space . "y" . OutputVarTempX . A_Space . "w" . OutputVarTempW + 4, % TempText
			a_TTMenuPos := F_WhereDisplayMenu(ini_TTTP)
			F_FlipMenu(WindowHandle := HTDemoHwnd, MenuX := a_TTMenuPos[1], MenuY := a_TTMenuPos[2], GuiName := "HTDemo")	

		Case % TransA["Tooltip: ""Undid the last hotstring"""]:
			if (UHS_DDL1 = "custom")
			{
				GuiControlGet, OutputVarTemp,, % IdUHstyling_E1
				if (!RegExMatch(OutputVarTemp, "^[[:xdigit:]]{6}"))
				{
					MsgBox, 48, % SubStr(A_ScriptName, 1, -4) .  ":" . A_Space . TransA["warning"], % TransA["Incorrect value. Select custom RGB hex value. Please try again."] . A_Space . "`n" 
					Gui, UHDemo: Destroy
					return
				}
				else 
					UHS_TTBgrColCus := OutputVarTemp
			}
			if (UHS_DDL2 = "custom")
			{
				GuiControlGet, OutputVarTemp,, % IdUHstyling_E2
				if (!RegExMatch(OutputVarTemp, "^[[:xdigit:]]{6}"))
				{
					MsgBox, 48, % SubStr(A_ScriptName, 1, -4) .  ":" . A_Space . TransA["warning"], % TransA["Incorrect value. Select custom RGB hex value. Please try again."] . A_Space . "`n" 
					Gui, UHDemo: Destroy
					return
				}
				else 
					UHS_TTTyFaceColCus := OutputVarTemp
			}
			WinGetPos, Window1X, Window1Y, Window1W, Window1H, % "ahk_id" . EvStylingHwnd
			Gui, UHDemo: New, -Caption +ToolWindow +HwndUHDemoHwnd
			Gui, UHDemo: Margin, 0, 0
			if (UHS_DDL1 = "custom")
				Gui, UHDemo: Color,, % UHS_TTBgrColCus
			else
				Gui, UHDemo: Color,, % UHS_DDL1
			if (HTS_DDL2 = "custom")		
				Gui, UHDemo: Font, % "s" . UHS_DDL4 . A_Space . "c" . UHS_TTTyFaceColCus, 	% UHS_DDL3
			else
				Gui, UHDemo: Font, % "s" . UHS_DDL4 . A_Space . "c" . UHS_DDL2, 			% UHS_DDL3

			TempText := TransA["Undid the last hotstring"]
			Gui, UHDemo: Add, Text, HwndIdUHDemo_T1, % TempText
			GuiControlGet, OutputVarTemp, Pos, % IdUHDemo_T1
			GuiControl, Hide, % IdUHDemo_T1
			Gui, UHDemo: Add, ListBox, % "HwndIdUHDemo_LB1" . A_Space . "r1" . A_Space . "x" . OutputVarTempX . A_Space . "y" . OutputVarTempX . A_Space . "w" . OutputVarTempW + 4, % TempText
			a_TTMenuPos := F_WhereDisplayMenu(ini_TTTP)
			F_FlipMenu(WindowHandle := UHDemoHwnd, MenuX := a_TTMenuPos[1], MenuY := a_TTMenuPos[2], GuiName := "UHDemo")	
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EventsStyling_Apply(WhichTab)
{
	global ;assume-global mode of operation
	local	DynVarRef1 := "", DynVarRef2 := ""		;dynamic variable: https://www.autohotkey.com/docs/Language.htm#dynamic-variables
		,	TTS_TTBgrColCus := "", TTS_TTTyFaceColCus := "" 
		,	HMS_TTBgrColCus := "", HMS_TTTyFaceColCus := ""  
		, 	ATS_TTBgrColCus := "", ATS_TTTyFaceColCus := ""  
		, 	HTS_TTBgrColCus := "", HTS_TTTyFaceColCus := ""  
		, 	UHS_TTBgrColCus := "", UHS_TTTyFaceColCus := ""  
		,	OutputVarTemp   := ""

	DynVarRef1 := WhichTab . "S_DDL1"
	if ( %DynVarRef1% = "custom")
	{
		DynVarRef1 := "Id" . WhichTab . "styling_E1"
		GuiControlGet, OutputVarTemp,, % %DynVarRef1%
		if (!RegExMatch(OutputVarTemp, "^[[:xdigit:]]{6}"))
			{
				MsgBox, 48, % SubStr(A_ScriptName, 1, -4) .  ":" . A_Space . TransA["warning"], % TransA["Incorrect value. Select custom RGB hex value. Please try again."] . A_Space . "`n" 
				Gui, % WhichTab . "Demo: Destroy"
				return
			}
		else
		{
			DynVarRef1   := WhichTab . "S_TTBgrColCus"
,			%DynVarRef1% := OutputVarTemp
		}
	}

	DynVarRef1 := WhichTab . "S_DDL2"
	if (%DynVarRef1% = "custom")
	{
		DynVarRef1 := "Id" . WhichTab . "styling_E2"
		GuiControlGet, OutputVarTemp,, % %DynVarRef1%
		if (!RegExMatch(OutputVarTemp, "^[[:xdigit:]]{6}"))
			{
				MsgBox, 48, % SubStr(A_ScriptName, 1, -4) .  ":" . A_Space . TransA["warning"], % TransA["Incorrect value. Select custom RGB hex value. Please try again."] . A_Space . "`n" 
				Gui, % WhichTab . "Demo: Destroy"
				return
			}
		else
		{
			DynVarRef1   := WhichTab . "S_TTTyFaceColCus"
,			%DynVarRef1% := OutputVarTemp			
		}
	}

	DynVarRef1 	:= "ini_" . WhichTab . "BgrCol"
,	DynVarRef2 	:= WhichTab . "S_DDL1"
,	%DynVarRef1% 	:= %DynVarRef2%

,	DynVarRef1 	:= "ini_" . WhichTab . "BgrColCus"
,	DynVarRef2 	:= WhichTab . "S_TTBgrColCus"
,	%DynVarRef1% 	:= %DynVarRef2%

,	DynVarRef1 	:= "ini_" . WhichTab . "TyFaceCol"
,	DynVarRef2 	:= WhichTab . "S_DDL2"
,	%DynVarRef1% 	:= %DynVarRef2%

,	DynVarRef1 	:= "ini_" . WhichTab . "TyFaceColCus"
,	DynVarRef2 	:= WhichTab . "S_TTTyFaceColCus"
,	%DynVarRef1% 	:= %DynVarRef2%

,	DynVarRef1 	:= "ini_" . WhichTab . "TyFaceFont"
,	DynVarRef2 	:= WhichTab . "S_DDL3"
,	%DynVarRef1% 	:= %DynVarRef2%

,	DynVarRef1 	:= "ini_" . WhichTab . "TySize"
,	DynVarRef2 	:= WhichTab . "S_DDL4"
,	%DynVarRef1% 	:= %DynVarRef2%

	DynVarRef1 	:= "ini_" . WhichTab . "BgrCol"
	IniWrite, % %DynVarRef1%, % ini_HADConfig, % "EvStyle_" . WhichTab, % WhichTab . "BackgroundColor"
	DynVarRef1 	:= "ini_" . WhichTab . "BgrColCus"
	IniWrite, % %DynVarRef1%, % ini_HADConfig, % "EvStyle_" . WhichTab, % WhichTab . "BackgroundColorCustom"
	DynVarRef1 	:= "ini_" . WhichTab . "TyFaceCol"
	IniWrite, % %DynVarRef1%, % ini_HADConfig, % "EvStyle_" . WhichTab, % WhichTab . "TypefaceColor"
	DynVarRef1 	:= "ini_" . WhichTab . "TyFaceColCus"
	IniWrite, % %DynVarRef1%, % ini_HADConfig, % "EvStyle_" . WhichTab, % WhichTab . "TypefaceColorCustom"
	DynVarRef1 	:= "ini_" . WhichTab . "TyFaceFont"
	IniWrite, % %DynVarRef1%, % ini_HADConfig, % "EvStyle_" . WhichTab, % WhichTab . "TypefaceFont"
	DynVarRef1 	:= "ini_" . WhichTab . "TySize"
	IniWrite, % %DynVarRef1%, % ini_HADConfig, % "EvStyle_" . WhichTab, % WhichTab . "TypefaceSize"

	Gui, % WhichTab . "Demo: Destroy"
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EventsStyling_B6(Parameter*)	;button: Apply
{
	global ;assume-global mode of operation
	local 	Decision := "", IsInteger := false, var := Parameter[1]	;unfortunately this var is necessary

	if var is number
		IsInteger := true
	
	if (IsInteger)
		Decision := EventsStylingTab3
	else
		Decision := Parameter[1]

	Gui, EventsStyling: 	Submit, NoHide
	Switch Decision
	{
		Case % TransA["Triggerstring tips styling"]:				F_EventsStyling_Apply("TT")
		Case % TransA["Hotstring menu styling"]:				F_EventsStyling_Apply("HM")
;#c/* commercial only beginning
;#c*/ commercial only end		
		Case % TransA["Tooltip: ""Hotstring was triggered"""]:		
			F_EventsStyling_Apply("HT")
			Gui, Tt_HWT: Destroy
			F_Tt_HWT()	;prepare Gui → Tt_HWT = Tooltip_Hostring Was Triggered
		Case % TransA["Tooltip: ""Undid the last hotstring"""]:	
			F_EventsStyling_Apply("UH")
			Gui, Tt_ULH: Destroy
			F_Tt_ULH()	;prepare Gui → Tooltip (ULH = Undid the Last Hotstring)
	}
	F_EventsStylingTab3(true)	;something was changed
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EventsStyling_Close(WhichTab)
{
	global ;assume-global mode of operation
	local 	DynVarRef1 := "", DynVarRef2 := ""		;dynamic variable: https://www.autohotkey.com/docs/Language.htm#dynamic-variables
,			OutputVarTemp := ""
,			TTS_TTBgrColCus := "", TTS_TTTyFaceColCus := "" 
,			HMS_TTBgrColCus := "", HMS_TTTyFaceColCus := ""  
,			ATS_TTBgrColCus := "", ATS_TTTyFaceColCus := ""  
,			HTS_TTBgrColCus := "", HTS_TTTyFaceColCus := ""  
,			UHS_TTBgrColCus := "", UHS_TTTyFaceColCus := ""  

	DynVarRef1 := WhichTab . "S_DDL1"
	if (%DynVarRef1% = "custom")
	{
		DynVarRef1 := "Id" . WhichTab . "styling_E1"
		GuiControlGet, OutputVarTemp, , % %DynVarRef1%
		if (!RegExMatch(OutputVarTemp, "^[[:xdigit:]]{6}"))
		{
			MsgBox, 48, % SubStr(A_ScriptName, 1, -4) .  ":" . A_Space . TransA["warning"], % TransA["Incorrect value. Select custom RGB hex value. Please try again."] . A_Space . "`n" 
			Gui, % WhichTab . "Demo: Destroy"
			return
		}
		else
		{
			DynVarRef1 	:= WhichTab . "S_TTBgrColCus"
,			%DynVarRef1% 	:= OutputVarTemp
		}
	}

	DynVarRef1 := WhichTab . "S_DDL2"
	if (%DynVarRef1% = "custom")
	{
		DynVarRef1 := "Id" . WhichTab . "styling_E2"
		GuiControlGet, OutputVarTemp, , % %DynVarRef1%
		if (!RegExMatch(OutputVarTemp, "^[[:xdigit:]]{6}"))
		{
			MsgBox, 48, % SubStr(A_ScriptName, 1, -4) .  ":" . A_Space . TransA["warning"], % TransA["Incorrect value. Select custom RGB hex value. Please try again."] . A_Space . "`n" 
			Gui, % WhichTab . "Demo: Destroy"
			return
		}
		else
		{
			DynVarRef1 	:= WhichTab . "S_TTTyFaceColCus"
,			%DynVarRef1% 	:= OutputVarTemp
		}
	}

	DynVarRef1 	:= "ini_" . WhichTab . "BgrCol"
,	DynVarRef2 	:= WhichTab . "S_DDL1"
,	%DynVarRef1%	:= %DynVarRef2%

,	DynVarRef1	:= "ini_" . WhichTab . "BgrColCus"
,	DynVarRef2	:= WhichTab . "S_TTBgrColCus"
,	%DynVarRef1%	:= %DynVarRef2%

,	DynVarRef1	:= "ini_" . WhichTab . "TyFaceCol"
,	DynVarRef2	:= WhichTab . "S_DDL2"
,	%DynVarRef1%	:= %DynVarRef2%

,	DynVarRef1	:= "ini_" . WhichTab . "TyFaceColCus"
,	DynVarRef2	:= WhichTab . "S_TTTyFaceColCus"
,	%DynVarRef1%	:= %DynVarRef2%

,	DynVarRef1	:= "ini_" . WhichTab . "TyFaceFont"
,	DynVarRef2	:= WhichTab . "S_DDL3"
,	%DynVarRef1%	:= %DynVarRef2%

,	DynVarRef1	:= "ini_" . WhichTab . "TySize"
,	DynVarRef2	:= WhichTab . "S_DDL4"
,	%DynVarRef1%	:= %DynVarRef2%

	DynVarRef1 	:= "ini_" . WhichTab . "BgrCol"
	IniWrite, % %DynVarRef1%, % ini_HADConfig, % "EvStyle_" . WhichTab, % WhichTab . "BackgroundColor"
	DynVarRef1 	:= "ini_" . WhichTab . "BgrColCus"
	IniWrite, % %DynVarRef1%, % ini_HADConfig, % "EvStyle_" . WhichTab, % WhichTab . "BackgroundColorCustom"
	DynVarRef1 	:= "ini_" . WhichTab . "TyFaceCol"
	IniWrite, % %DynVarRef1%, % ini_HADConfig, % "EvStyle_" . WhichTab, % WhichTab . "TypefaceColor"
	DynVarRef1 	:= "ini_" . WhichTab . "TyFaceColCus"
	IniWrite, % %DynVarRef1%, % ini_HADConfig, % "EvStyle_" . WhichTab, % WhichTab . "TypefaceColorCustom"
	DynVarRef1 	:= "ini_" . WhichTab . "TyFaceFont"
	IniWrite, % %DynVarRef1%, % ini_HADConfig, % "EvStyle_" . WhichTab, % WhichTab . "TypefaceFont"
	DynVarRef1 	:= "ini_" . WhichTab . "TySize"
	IniWrite, % %DynVarRef1%, % ini_HADConfig, % "EvStyle_" . WhichTab, % WhichTab . "TypefaceSize"
	F_CloseSubGui(WhatGuiToDestroy := WhichTab . "Demo")
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EventsStyling_B7()	;button: Close
{
	global ;assume-global mode of operation

	Gui, EventsStyling: 	Submit
	Switch EventsStylingTab3
	{
		Case % TransA["Triggerstring tips styling"]:				F_EventsStyling_Close("TT")
		Case % TransA["Hotstring menu styling"]:				F_EventsStyling_Close("HM")
;#c/* commercial only beginning		
;#c*/ commercial only end		
		Case % TransA["Tooltip: ""Hotstring was triggered"""]:		
			F_EventsStyling_Close("HT")
			Gui, Tt_HWT: Destroy
			F_Tt_HWT()	;prepare Gui → Tt_HWT = Tooltip_Hostring Was Triggered
		Case % TransA["Tooltip: ""Undid the last hotstring"""]:	
			F_EventsStyling_Close("UH")
			Gui, Tt_ULH: Destroy
			F_Tt_ULH()	;prepare Gui → Tooltip (ULH = Undid the Last Hotstring)
 	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EventsStyling_B8()	;button: Cancel
{
	global ;assume-global mode of operation
	Switch EventsStylingTab3
	{
		Case % TransA["Triggerstring tips styling"]:				
			F_CloseSubGui(WhatGuiToDestroy := "TTDemo")
			F_CloseSubGui(WhatGuiToDestroy := "EventsStyling")
		Case % TransA["Hotstring menu styling"]:				
			F_CloseSubGui(WhatGuiToDestroy := "HMDemo")
			F_CloseSubGui(WhatGuiToDestroy := "EventsStyling")
;#c/* commercial only beginning			
;#c*/ commercial only end			
		Case % TransA["Tooltip: ""Hotstring was triggered"""]:		
			F_CloseSubGui(WhatGuiToDestroy := "HTDemo")
			F_CloseSubGui(WhatGuiToDestroy := "EventsStyling")
		Case % TransA["Tooltip: ""Undid the last hotstring"""]:	
			F_CloseSubGui(WhatGuiToDestroy := "UHDemo")
			F_CloseSubGui(WhatGuiToDestroy := "EventsStyling")
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_GuiEventsStyling_CreateObjects()
{
	global ;assume-global mode of operation
	local	TabId := ""
	Gui, EventsStyling: New, 	-Resize +HwndEvStylingHwnd +Owner +OwnDialogs -MaximizeBox -MinimizeBox	;+OwnDialogs: for tooltips.
	Gui, EventsStyling: Margin,	% c_xmarg, % c_ymarg
	Gui,	EventsStyling: Color,	% c_WindowColor, % c_ControlColor
	Gui,	EventsStyling: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, 			% c_FontType
	Gui, EventsStyling: Add,	Tab3, vEventsStylingTab3 gF_EventsStylingTab3
,		% TransA["Triggerstring tips styling"] . "||" 
		. TransA["Hotstring menu styling"] . "|"
;#c/* commercial only beginning		
;#c*/ commercial only end		 
		. TransA["Tooltip: ""Hotstring was triggered"""] . "|"
		. TransA["Tooltip: ""Undid the last hotstring"""] . "|"

	Gui, EventsStyling: Tab, 			% TransA["Triggerstring tips styling"]
	F_GuiStyling_Section(TabId := "TT")
	Gui, EventsStyling: Tab, 			% TransA["Hotstring menu styling"]
	F_GuiStyling_Section(TabId := "HM")
;#c/* commercial only beginning	
;#c*/ commercial only end	
	Gui, EventsStyling: Tab,				% TransA["Tooltip: ""Hotstring was triggered"""]
 	F_GuiStyling_Section(TabId := "HT")
	Gui, EventsStyling: Tab,				% TransA["Tooltip: ""Undid the last hotstring"""]
 	F_GuiStyling_Section(TabId := "UH")
 }
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EventsStylingTab3_Update(WhichItem, OneTime*)
{
	global ;assume-global mode of operation
	local 	DynVarRef1 := "", DynVarRef2 := "", DynVarRef3 := "", DynVarRef4 := "", DynVarRef5 := "", DynVarRef6 := "", DynVarRef7 := "", DynVarRef8 := ""		;dynamic variable: https://www.autohotkey.com/docs/Language.htm#dynamic-variables
	static PreviousTTS_DDL1 := "", PreviousTTS_DDL2 := "", PreviousTTS_DDL3 := "", PreviousTTS_DDL4 := ""
		, PreviousHMS_DDL1 := "", PreviousHMS_DDL2 := "", PreviousHMS_DDL3 := "", PreviousHMS_DDL4 := ""
;#c/* commercial only beginning		
;#c*/ commercial only end		
		, PreviousHTS_DDL1 := "", PreviousHTS_DDL2 := "", PreviousHTS_DDL3 := "", PreviousHTS_DDL4 := ""
		, PreviousUHS_DDL1 := "", PreviousUHS_DDL2 := "", PreviousUHS_DDL3 := "", PreviousUHS_DDL4 := ""

	if (OneTime[1] = true)
	{
		  PreviousTTS_DDL1 := TTS_DDL1, PreviousTTS_DDL2 := TTS_DDL2, PreviousTTS_DDL3 := TTS_DDL3, PreviousTTS_DDL4 := TTS_DDL4
		, PreviousHMS_DDL1 := HMS_DDL1, PreviousHMS_DDL2 := HMS_DDL2, PreviousHMS_DDL3 := HMS_DDL3, PreviousHMS_DDL4 := HMS_DDL4
;#c/* commercial only beginning		
;#c*/ commercial only end		
		, PreviousHTS_DDL1 := HTS_DDL1, PreviousHTS_DDL2 := HTS_DDL2, PreviousHTS_DDL3 := HTS_DDL3, PreviousHTS_DDL4 := HTS_DDL4
		, PreviousUHS_DDL1 := UHS_DDL1, PreviousUHS_DDL2 := UHS_DDL2, PreviousUHS_DDL3 := UHS_DDL3, PreviousUHS_DDL4 := UHS_DDL4
		return
	}

	DynVarRef1 := WhichItem . "S_DDL1"
,	DynVarRef2 := "Previous"	. WhichItem . "S_DDL1"
,	DynVarRef3 := WhichItem . "S_DDL2"
,	DynVarRef4 := "Previous"	. WhichItem . "S_DDL2"
,	DynVarRef5 := WhichItem . "S_DDL3"
,	DynVarRef6 := "Previous"	. WhichItem . "S_DDL3"
,	DynVarRef7 := WhichItem . "S_DDL4"
,	DynVarRef8 := "Previous"	. WhichItem . "S_DDL4"

	if (%DynVarRef1% != %DynVarRef2%) or (%DynVarRef3% != %DynVarRef4%) or (%DynVarRef5% != %DynVarRef6%) or (%DynVarRef7% != %DynVarRef8%)
	{
		MsgBox, 68, % SubStr(A_ScriptName, 1, -4) .  ":" . A_Space . TransA["warning"], % TransA["You've changed at least one configuration parameter, but didn't yet apply it."] 
			. TransA["If you don't apply it, previous changes will be lost."]
			. "`n`n" . TransA["Do you wish to apply your changes?"]
		IfMsgBox, Yes	;here MsgBox threadis over
			F_EventsStyling_B6(TransA["Triggerstring tips styling"])	;button: Apply 
		IfMsgBox, No	;restore previous values to each GuiControl
		{
			if (%DynVarRef1% != %DynVarRef2%)	;if (TTS_DDL1 != PreviousTTS_DDL1)
			{
				GuiControl, ChooseString, % %DynVarRef1%, % %DynVarRef2%
				if (%DynVarRef2% = "custom")
				{
					DynVarRef1 := "Id" . WhichItem . "styling_E1"
					GuiControl,, % %DynVarRef1%, % TransA["HTML color RGB value, e.g. 00FF00"] 
				}
			}
			if (%DynVarRef3% != %DynVarRef4%)	;if (TTS_DDL2 != PreviousTTS_DDL2)
			{
				GuiControl, ChooseString, % %DynVarRef3%, % %DynVarRef4%
				if (%DynVarRef4% = "custom")
				{
					DynVarRef3 := "Id" . WhichItem . "styling_E2"
					GuiControl,, % %DynVarRef3%, % TransA["HTML color RGB value, e.g. 00FF00"] 
				}
			}
			if (%DynVarRef5% != %DynVarRef6%) ;if (TTS_DDL3 != PreviousTTS_DDL3)
			{
				DynVarRef5 := "Id" . WhichItem . "styling_DDL3"
				GuiControl, ChooseString, % %DynVarRef5%, % %DynVarRef6%
			}
			if (%DynVarRef7% != %DynVarRef8%) ;if (TTS_DDL4 != PreviousTTS_DDL4)
			{
				DynVarRef7 := "Id" . WhichItem . "styling_DDL4" 
				GuiControl, ChooseString, % %DynVarRef7%, % %DynVarRef8%	;GuiControl, ChooseString, % IdTTstyling_DDL4, % PreviousTTS_DDL4
			}
		}
	}
	else
	{
		F_GS_LV_Dynamic("TT")
		F_GS_LV_Dynamic("HM")
;#c/* commercial only beginning		
;#c*/ commercial only end		
		F_GS_LV_Dynamic("HT")
		F_GS_LV_Dynamic("UH")
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EventsStylingTab3(OneTime*)
{
	global ;assume-global mode
	static PreviousTab3 := "", OneTimeTTS := true
	if (OneTime[1] = true)
	{
		PreviousTab3 := EventsStylingTab3
		F_EventsStylingTab3_Update("TT", true)
		OneTimeTTS := false
		return
	}
	if (WinExist("ahk_id" TDemoHwnd))
		Gui, TTDemo: 		Destroy
	if (WinExist("ahk_id" HDemoHwnd))
		Gui, HMDemo: 		Destroy
;#c/* commercial only beginning		
;#c*/ commercial only end		
	
	Gui, EventsStyling: Submit, NoHide
	if (EventsStylingTab3 != PreviousTab3)
	{
		Switch PreviousTab3
		{
			Case % TransA["Triggerstring tips styling"]:				F_EventsStylingTab3_Update("TT")
			Case % TransA["Hotstring menu styling"]:				F_EventsStylingTab3_Update("HM")
;#c/* commercial only beginning			
;#c*/ commercial only end			
			Case % TransA["Tooltip: ""Hotstring was triggered"""]:		F_EventsStylingTab3_Update("HT")
			Case % TransA["Tooltip: ""Undid the last hotstring"""]:	F_EventsStylingTab3_Update("UH")
		}
		PreviousTab3 := EventsStylingTab3
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
EventsStylingGuiClose()
{
	global	;assume-global mode of operation
	if (WinExist("ahk_id" HS3GuiHwnd))
		Gui, HS3: -Disabled	
	if (WinExist("ahk_id" HS4GuiHwnd))
		Gui, HS4: -Disabled	
	Gui, EventsStyling: 	Destroy
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
EventsStylingGuiEscape()
{
	global	;assume-global mode of operation
	if (WinExist("ahk_id" HS3GuiHwnd))
		Gui, HS3: -Disabled	
	if (WinExist("ahk_id" HS4GuiHwnd))
		Gui, HS4: -Disabled	
	Gui, EventsStyling: 	Destroy
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_GuiEventsStyling_DetermineConstants(Which)
{
	global ;assume-global mode of operation
	local v_OutVarTemp := 0, 	v_OutVarTempX := 0, 	v_OutVarTempY := 0, 	v_OutVarTempW := 0, 	v_OutVarTempH := 0
		,v_OutVarTemp1 := 0, 	v_OutVarTemp1X := 0, 	v_OutVarTemp1Y := 0, 	v_OutVarTemp1W := 0, 	v_OutVarTemp1H := 0
		,v_OutVarTemp2 := 0, 	v_OutVarTemp2X := 0, 	v_OutVarTemp2Y := 0, 	v_OutVarTemp2W := 0, 	v_OutVarTemp2H := 0
		,v_OutVarTemp3 := 0, 	v_OutVarTemp3X := 0, 	v_OutVarTemp3Y := 0, 	v_OutVarTemp3W := 0, 	v_OutVarTemp3H := 0
		,v_OutVarTemp4 := 0, 	v_OutVarTemp4X := 0, 	v_OutVarTemp4Y := 0, 	v_OutVarTemp4W := 0, 	v_OutVarTemp4H := 0
							,v_xNext := 0, 		v_yNext := 0, 			v_wNext := 0, 			v_hNext := 0
		,TheWidestText := 0, DynVarRef := ""	;dynamic variable: https://www.autohotkey.com/docs/Language.htm#dynamic-variables

	DynVarRef := "Id" . Which . "styling_T3"
	GuiControlGet, v_OutVarTemp2, Pos, % %DynVarRef%
	DynVarRef := "Id" . Which . "styling_T5"
	GuiControlGet, v_OutVarTemp3, Pos, % %DynVarRef%
	DynVarRef := "Id" . Which . "styling_T7"
	GuiControlGet, v_OutVarTemp4, Pos, % %DynVarRef%
	TheWidestText := Max(v_OutVarTemp1W, v_OutVarTemp2W, v_OutVarTemp3W, v_OutVarTemp4W)
	
	v_xNext := c_xmarg
,	v_yNext := c_ymarg
,	DynVarRef := "Id" . Which . "styling_T1"
	GuiControl, Move, % %DynVarRef%, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext += TheWidestText + 2 * c_xmarg
,	DynVarRef := "Id" . Which . "styling_T2"
	GuiControl, Move, % %DynVarRef%, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg
,	v_yNext += c_HofText
,	DynVarRef := "Id" . Which . "styling_DDL1"
	GuiControl, Move, % %DynVarRef%, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % %DynVarRef%
	v_xNext += v_OutVarTempW + 2 * c_xmarg
,	DynVarRef := "Id" . Which . "styling_E1"
	GuiControl, Move, % %DynVarRef%, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % %DynVarRef%
	v_xNext := v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
,	DynVarRef := "Id" . Which . "styling_B1"	
	GuiControl, Move, % %DynVarRef%, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	
	v_xNext := c_xmarg
,	DynVarRef := "Id" . Which . "styling_B1"
	GuiControlGet, v_OutVarTemp, Pos, % %DynVarRef%
	v_yNext += v_OutVarTempH + 2 * c_ymarg
,	DynVarRef := "Id" . Which . "styling_T3"
	GuiControl, Move, % %DynVarRef%, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext += TheWidestText + 2 * c_xmarg
,	DynVarRef := "Id" . Which . "styling_T4"
	GuiControl, Move, % %DynVarRef%, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg
,	v_yNext += c_HofText
,	DynVarRef := "Id" . Which . "styling_DDL2"
	GuiControl, Move, % %DynVarRef%, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % %DynVarRef%
	v_xNext += v_OutVarTempW + 2 * c_xmarg
,	DynVarRef := "Id" . Which . "styling_E2"
	GuiControl, Move, % %DynVarRef%, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % %DynVarRef%
	v_xNext := v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
,	DynVarRef := "Id" . Which . "styling_B2"
	GuiControl, Move, % %DynVarRef%, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	
	v_xNext := c_xmarg
,	DynVarRef := "Id" . Which . "styling_B1"
	GuiControlGet, v_OutVarTemp, Pos, % %DynVarRef%
	v_yNext += v_OutVarTempH + 2 * c_ymarg
,	DynVarRef := "Id" . Which . "styling_T5"
	GuiControl, Move, % %DynVarRef%, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext += TheWidestText + 2 * c_xmarg
,	DynVarRef := "Id" . Which . "styling_T6"
	GuiControl, Move, % %DynVarRef%, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg
,	v_yNext += c_HofText
,	DynVarRef := "Id" . Which . "styling_DDL3"
	GuiControl, Move, % %DynVarRef%, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % %DynVarRef%
	v_xNext := v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
,	DynVarRef := "Id" . Which . "styling_B3"
	GuiControl, Move, % %DynVarRef%, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % %DynVarRef%

	v_xNext := v_OutVarTempX + v_OutVarTempW + 5 * c_xmarg
,	DynVarRef := "Id" . Which . "styling_T9"
	GuiControl, Move, % %DynVarRef%, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % %DynVarRef%
	v_xNext := v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
,	DynVarRef := "Id" . Which . "styling_T10"
	GuiControl, Move, % %DynVarRef%, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	DynVarRef := "Id" . Which . "styling_B3"
	GuiControlGet, v_OutVarTemp, Pos, % %DynVarRef%
	v_xNext := v_OutVarTempX + v_OutVarTempW + 5 * c_xmarg
,	v_yNext += c_HofText
,	DynVarRef := "Id" . Which . "styling_LB1"
	GuiControl, Move, % %DynVarRef%, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	
	v_xNext := c_xmarg
,	DynVarRef := "Id" . Which . "styling_B1"
	GuiControlGet, v_OutVarTemp, Pos, % %DynVarRef%
	v_yNext += v_OutVarTempH + 2 * c_ymarg
,	DynVarRef := "Id" . Which . "styling_T7"
	GuiControl, Move, % %DynVarRef%, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext += TheWidestText + 2 * c_xmarg
,	DynVarRef := "Id" . Which . "styling_T8"
	GuiControl, Move, % %DynVarRef%, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg
,	v_yNext += c_HofText
,	DynVarRef := "Id" . Which . "styling_DDL4"
	GuiControl, Move, % %DynVarRef%, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % %DynVarRef%
	v_xNext := v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
,	DynVarRef := "Id" . Which . "styling_B4"
	GuiControl, Move, % %DynVarRef%, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	
	v_xNext := c_xmarg
,	DynVarRef := "Id" . Which . "styling_B1"
	GuiControlGet, v_OutVarTemp, Pos, % %DynVarRef%
	v_yNext += v_OutVarTempH + 2 * c_ymarg
,	DynVarRef := "Id" . Which . "styling_B5"
	GuiControl, Move, % %DynVarRef%, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % %DynVarRef%
	v_xNext := v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
,	DynVarRef := "Id" . Which . "styling_B6"
	GuiControl, Move, % %DynVarRef%, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % %DynVarRef%
	v_xNext := v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
,	DynVarRef := "Id" . Which . "styling_B7"
	GuiControl, Move, % %DynVarRef%, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % %DynVarRef%
	v_xNext := v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
,	DynVarRef := "Id" . Which . "styling_B8"
	GuiControl, Move, % %DynVarRef%, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	
	DynVarRef := "Id" . Which . "styling_E1"
	GuiControl, Disable, % %DynVarRef%
	DynVarRef := "Id" . Which . "styling_E2"
	GuiControl, Disable, % %DynVarRef%
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_GS_LV_Dynamic(TabId)
{
	global	;assume-global mode of operation
	local	DynVarRef1 := "", DynVarRef2 := "", DynVarRef3 := "", DynVarRef4 := ""

	DynVarRef1 := "Id" . 	TabId . "styling_DDL1"
,	DynVarRef2 := "ini_" . 	TabId . "BgrCol"
,	DynVarRef3 := "Id" .  	TabId . "styling_E1"
,	DynVarRef4 := "ini_" . 	TabId . "BgrColCus"
	GuiControl, ChooseString, % %DynVarRef1%, % %DynVarRef2%
	if (DynVarRef2 = "custom")
	{
		GuiControl,, % %DynVarRef3%, % %DynVarRef4%
		GuiControl, Enable, % %DynVarRef3%
	}

	DynVarRef1 := "Id" . 	TabId . "styling_DDL2"
,	DynVarRef2 := "ini_" . 	TabId . "TyFaceCol"
,	DynVarRef3 := "Id" .  	TabId . "styling_E2"
,	DynVarRef4 := "ini_" . 	TabId . "TyFaceColCus"
	GuiControl, ChooseString, % %DynVarRef1%, % %DynVarRef2%
	if (DynVarRef2 = "custom")
	{
		GuiControl,, % %DynVarRef3%, % %DynVarRef4%
		GuiControl, Enable, % %DynVarRef3%
	}

	DynVarRef1 := "Id" . 	TabId . "styling_DDL3"
,	DynVarRef2 := "ini_" . 	TabId . "TyFaceFont"
	GuiControl, ChooseString, % %DynVarRef1%, % %DynVarRef2%

	DynVarRef1 := "Id" . 	TabId . "styling_DDL4"
,	DynVarRef2 := "ini_" . 	TabId . "TySize"
	GuiControl, ChooseString, % %DynVarRef1%, % %DynVarRef2%
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EventsStyling(OneTime*)
{
	global	;assume-global mode
	local 	Window1X := 0, Window1Y := 0, Window1W := 0, Window1H := 0
		,	Window2X := 0, Window2Y := 0, Window2W := 0, Window2H := 0
		,	NewWinPosX := 0, NewWinPosY := 0
	
	if (OneTime[3])
		Gui, % A_Gui . ": +Disabled"	;thanks to this line user won't be able to interact with main hotstring window if TTStyling window is available
	F_GuiEventsStyling_CreateObjects()
	F_GuiEventsStyling_DetermineConstants("TT")	;TT = Triggerstring Tips
	F_GuiEventsStyling_DetermineConstants("HM")	;HM = Hotsring Menu
;#c/* commercial only beginning	
;#c*/ commercial only end	
	F_GuiEventsStyling_DetermineConstants("HT")	;HT = Tooltip: Hostring is triggered
	F_GuiEventsStyling_DetermineConstants("UH")	;UH = Tooltip: Unid the last hostring
	F_GS_LV_Dynamic("TT")
	F_GS_LV_Dynamic("HM")
;#c/* commercial only beginning	
;#c*/ commercial only end	
	F_GS_LV_Dynamic("HT")
	F_GS_LV_Dynamic("UH")

	Gui, EventsStyling: Submit				;this line is necessary to correctly initialize some global variables
	F_EventsStylingTab3(OneTime[1])			;OneTime is used now
	
	if (WinExist("ahk_id" . HS3GuiHwnd) or WinExist("ahk_id" . HS4GuiHwnd))
		WinGetPos, Window1X, Window1Y, Window1W, Window1H, A
	Gui, EventsStyling: Show, Hide
	
	if (OneTime[3])
	{
		DetectHiddenWindows, On
		WinGetPos, Window2X, Window2Y, Window2W, Window2H, % "ahk_id" . EvStylingHwnd
		DetectHiddenWindows, Off
		if (Window1W)
		{
			NewWinPosX := Round(Window1X + (Window1W / 2) - (Window2W / 2))
			NewWinPosY := Round(Window1Y + (Window1H / 2) - (Window2H / 2))
			Gui, EventsStyling: Show, % "AutoSize" . A_Space . "x" . NewWinPosX . A_Space . "y" . NewWinPosY, % A_ScriptName . ":" . A_Space . TransA["Events: styling"]
		}
		else
		{
			Gui, EventsStyling: Show, Center AutoSize, % A_ScriptName . ":" . A_Space . TransA["Events: styling"]
		}
		GuiControl, Hide, % IdTTstyling_LB1	
		GuiControl, Hide, % IdHMstyling_LB1
;#c/* commercial only beginning		
;#c*/ commercial only end		
		GuiControl, Hide, % IdHTstyling_LB1
		GuiControl, Hide, % IdUHstyling_LB1
		Gui, TTDemo: Hide
		Gui, HMDemo: Hide
;#c/* commercial only beginning		
;#c*/ commercial only end		
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_ShowTriggerstringTips2(a_Tips, a_TipsOpt, a_TipsEnDis, a_TipsHS, ini_TTCn)
{
	global ;assume-global mode of operation
	local a_TTMenuPos 		:= []
	
	Switch ini_TTCn
	{
		Case 1:
			Gui, TT_C1: Destroy	;this line is necessary to display new menu each time this function is called.
			F_GuiTrigTipsMenuDefC1(a_Tips.Count(), F_LongestTrigTipString(a_Tips))	;Each time new list of triggerstring tips is created also new gui is created. as a consequence new set of hotkeys is created.
			GuiControl,, % IdTT_C1_LB1, % F_ConvertArrayToString(a_Tips)
			a_TTMenuPos := F_WhereDisplayMenu(ini_TTTP)
			F_FlipMenu(TT_C1_Hwnd, a_TTMenuPos[1], a_TTMenuPos[2], "TT_C1")

		Case 2:
			Gui, TT_C2: Destroy
			F_GuiTrigTipsMenuDefC2(a_Tips.Count(), F_LongestTrigTipString(a_Tips))	;Each time new list of triggerstring tips is created also new gui is created. as a consequence new set of hotkeys is created.
			GuiControl,, % IdTT_C2_LB1, % F_ConvertArrayToString(a_Tips)
			GuiControl,, % IdTT_C2_LB2, % F_TrigTipsSecondColumn(a_TipsOpt, a_TipsEnDis)
			a_TTMenuPos := F_WhereDisplayMenu(ini_TTTP)
			F_FlipMenu(TT_C2_Hwnd, a_TTMenuPos[1], a_TTMenuPos[2], "TT_C2")

		Case 3: 
			Gui, TT_C3: Destroy
			F_GuiTrigTipsMenuDefC3(a_Tips.Count(), F_LongestTrigTipString(a_Tips), F_LongestTrigTipString(a_TipsHS))	;Each time new list of triggerstring tips is created also new gui is created. as a consequence new set of hotkeys is created.
			GuiControl,, % IdTT_C3_LB1, % F_ConvertArrayToString(a_Tips)
			GuiControl,, % IdTT_C3_LB2, % F_TrigTipsSecondColumn(a_TipsOpt, a_TipsEnDis)
			GuiControl,, % IdTT_C3_LB3, % F_ConvertArrayToString(a_TipsHS)
			a_TTMenuPos := F_WhereDisplayMenu(ini_TTTP)
			F_FlipMenu(TT_C3_Hwnd, a_TTMenuPos[1], a_TTMenuPos[2], "TT_C3")	

		Case 4:
			PreviousWindowID := WinExist("A")
			GuiControl,, % IdTT_C4_LB1, % F_ConvertArrayToString(a_Tips)
			GuiControl,, % IdTT_C4_LB2, % F_TrigTipsSecondColumn(a_TipsOpt, a_TipsEnDis)
			GuiControl,, % IdTT_C4_LB3, % F_ConvertArrayToString(a_TipsHS)
			GuiControl, Choose, % IdTT_C4_LB1, 1
			GuiControl, Choose, % IdTT_C4_LB2, 1
			GuiControl, Choose, % IdTT_C4_LB3, 1
			Gui, TT_C4: Show, NoActivate AutoSize
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_UpdateTT_C3()
{
	global ;assume-global mode of operation
	local a_TTMenuPos 		:= [], LongestValue := 0, CurrentValue := 0, key := 0, value := ""
,		ControlPosition := 0, ControlPositionX := 0, ControlPositionY := 0, ControlPositionW := 0, ControlPositionH := 0
,		ControlHeight 		:= RHpx * a_Tips.Count
,		NoOfRows 			:= a_Tips.Count

	GuiControl,, % IdTT_C3_LB1, ¦¦
	GuiControl,, % IdTT_C3_LB2, ¦¦
	GuiControl,, % IdTT_C3_LB3, ¦¦
	for key, value in a_Tips
	{
		CurrentValue := StrLen(a_Tips[key])
		if (CurrentValue > LongestValue)
			LongestValue := CurrentValue
	}
	GuiControl, Move, % IdTT_C3_LB1, % "w" . A_Space . WLpx * LongestValue . A_Space . "r" . A_Space . NoOfRows
	GuiControl,, % IdTT_C3_LB1, % F_ConvertArrayToString(a_Tips)
	GuiControlGet, ControlPosition, Pos, % IdTT_C3_LB1
	GuiControl, Move, % IdTT_C3_LB2, % "x" . A_Space . ControlPositionX + ControlPositionW . A_Space . "w" . A_Space . WLpx . A_Space . "r" . A_Space . NoOfRows
	GuiControl,, % IdTT_C3_LB2, % F_TrigTipsSecondColumn(a_TipsOpt, a_TipsEnDis)
	GuiControlGet, ControlPosition, Pos, % IdTT_C3_LB2
	GuiControl, Move, % IdTT_C3_LB3, % "x" . A_Space . ControlPositionX + ControlPositionW . A_Space . "w" . A_Space . WLpx * LongestValue . A_Space . "r" . A_Space . NoOfRows
	GuiControl,, % IdTT_C3_LB3, % F_ConvertArrayToString(a_TipsHS)
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
TT_C4GuiEscape()
{
	if (WinActive("ahk_id" TT_C4_Hwnd))
		Gui, TT_C4: Hide
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_CheckFileEncoding(FullFilePath)
{	;https://www.autohotkey.com/boards/viewtopic.php?t=65049
	local file := "", RetrievedEncoding := "", FilePos := 0

	if (!A_IsCompiled)
	{
		file := FileOpen(FullFilePath, "r")
	,	RetrievedEncoding := file.Encoding
	,	FilePos := file.Pos
		if !(((RetrievedEncoding = "UTF-8") and (FilePos = 3)) or ((RetrievedEncoding = "UTF-16") and (FilePos = 2)))
		{
			MsgBox, 16, % A_ScriptName . ":" . A_Space . TransA["Error"], % TransA["Recognized encoding of the file:"] 
				. "`n" . FullFilePath
				. "`n`n" . RetrievedEncoding . A_Space . "no-BOM"
				. "`n`n" . TransA["Required encoding: UTF-8 with BOM. Application will exit now."]
			try	;if no try, some warnings are still catched; with try no more warnings
				ExitApp, 3	;no-bom
		}
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_GuiVersionUpdate()
{
	global ;assume-global mode
	local Window1X := 0, Window1Y := 0, Window1W := 0, Window1H := 0
		,Window2X := 0, Window2Y := 0, Window2W := 0, Window2H := 0
		,NewWinPosX := 0, NewWinPosY := 0
	
	if (WinExist("ahk_id" . HS3GuiHwnd) or WinExist("ahk_id" . HS3GuiHwnd) or WinExist("ahk_id" . HS4GuiHwnd) or WinExist("ahk_id" . HS4GuiHwnd))
		WinGetPos, Window1X, Window1Y, Window1W, Window1H, A
	Gui, VersionUpdate: Show, Hide
	
	DetectHiddenWindows, On
	WinGetPos, Window2X, Window2Y, Window2W, Window2H, % "ahk_id" . VersionUpdateHwnd
	DetectHiddenWindows, Off
	Gui, % A_Gui . ": +Disabled"	;thanks to this line user won't be able to interact with main hotstring window if TTStyling window is available
	if (Window1W)
	{
		NewWinPosX := Round(Window1X + (Window1W / 2) - (Window2W / 2))
		NewWinPosY := Round(Window1Y + (Window1H / 2) - (Window2H / 2))
		Gui, VersionUpdate: Show, % "AutoSize" . A_Space . "x" . NewWinPosX . A_Space . "y" . NewWinPosY, % A_ScriptName . ":" . A_Space . TransA["Version / Update"]
	}
	else
	{
		Gui, VersionUpdate: Show, Center AutoSize, % A_ScriptName . ":" . A_Space . TransA["Version / Update"]
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_GuiVersionUpdate_DetermineConstraints()
{
	global	;assume-global mode
;Within a function, to create a set of variables that is local instead of global, declare OutputVar as a local variable prior to using command GuiControlGet, Pos. However, it is often also necessary to declare each variable in the set, due to a common source of confusion.
	local v_OutVarTemp := 0, 	v_OutVarTempX := 0, 	v_OutVarTempY := 0, 	v_OutVarTempW := 0, 	v_OutVarTempH := 0
		,v_OutVarTemp1 := 0, 	v_OutVarTemp1X := 0, 	v_OutVarTemp1Y := 0, 	v_OutVarTemp1W := 0, 	v_OutVarTemp1H := 0
		,v_OutVarTemp2 := 0, 	v_OutVarTemp2X := 0, 	v_OutVarTemp2Y := 0, 	v_OutVarTemp2W := 0, 	v_OutVarTemp2H := 0
		,v_OutVarTemp3 := 0, 	v_OutVarTemp3X := 0, 	v_OutVarTemp3Y := 0, 	v_OutVarTemp3W := 0, 	v_OutVarTemp3H := 0
							,v_xNext := 0, 		v_yNext := 0, 			v_wNext := 0, 			v_hNext := 0
		,WhichIsWider := 0
	
; Determine constraints, according to mock-up
	v_xNext := c_xmarg
	v_yNext := c_ymarg
	GuiControl, Move, % IdVerUpd1, % "x" . v_xNext . "y" . v_yNext
	v_yNext += c_HofText
	GuiControl, Move, % IdVerUpd3, % "x" . v_xNext . "y" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdVerUpd3
	v_xNext := v_OutVarTempX + v_OutVarTempW + c_xmarg
	GuiControl, Move, % IdVerUpd4, % "x" . v_xNext . "y" . v_yNext
	v_yNext := c_ymarg
	GuiControl, Move, % IdVerUpd2, % "x" . v_xNext . "y" . v_yNext
	v_yNext := v_OutVarTempY + c_HofText + c_ymarg
	v_xNext := c_xmarg
	GuiControl, Move, % IdVerUpdCheckServ, % "x" . v_xNext . "y" . v_yNext
	v_yNext += c_HofButton + c_ymarg
	GuiControl, Move, % IdVerUpdDownload, % "x" . v_xNext . "y" . v_yNext
	GuiControlGet, v_OutVarTemp1, Pos, % IdVerUpdCheckServ
	GuiControlGet, v_OutVarTemp2, Pos, % IdVerUpdDownload
	WhichIsWider := Max(v_OutVarTemp1W, v_OutVarTemp2W)
	v_xNext := v_OutVarTemp1X + WhichIsWider + 2 * c_xmarg
	v_yNext := v_OutVarTemp1Y
	GuiControl, Move, % IdVerUpdCheckOnStart, % "x" . v_xNext . "y" . v_yNext
	v_yNext := v_OutVarTemp2Y
	GuiControl, Move, % IdVerUpdDwnlOnStart, % "x" . v_xNext . "y" . v_yNext
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_GuiVersionUpdate_CreateObjects()
{
	global	;assume-global mode
	local	ServerVer := "?.??.??"
	
	;1. Prepare MyAbout Gui
	Gui, VersionUpdate: New, 	-Resize +HwndVersionUpdateHwnd +Owner -MaximizeBox -MinimizeBox
	Gui, VersionUpdate: Margin,	% c_xmarg, % c_ymarg
	Gui,	VersionUpdate: Color,	% c_WindowColor, % c_ControlColor
	
	;2. Prepare all text objects according to mock-up.
	Gui,	VersionUpdate: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, 				% c_FontType
	Gui, VersionUpdate: Add, 	Text,    	x0 y0 HwndIdVerUpd1,											% TransA["Local version"] . ":"
	Gui, VersionUpdate: Add, 	Text,    	x0 y0 HwndIdVerUpd2, 											% AppVersion
	Gui, VersionUpdate: Add, 	Text,    	x0 y0 HwndIdVerUpd3,											% TransA["Repository version"] . ":"
	Gui, VersionUpdate: Add, 	Text,    	x0 y0 HwndIdVerUpd4, 											% ServerVer
	Gui, VersionUpdate: Add, 	Button,  	x0 y0 HwndIdVerUpdCheckServ gF_VerUpdCheckServ,						% TransA["Check repository version"]
	Gui, VersionUpdate: Add, 	Button,  	x0 y0 HwndIdVerUpdDownload  gF_VerUpdDownload,						% TransA["Download repository version"]
	Gui, VersionUpdate: Add,		Checkbox,	x0 y0 HwndIdVerUpdCheckOnStart gF_CheckUpdOnStart Checked%ini_CheckRepo%,	% TransA["Check if update is available on startup?"]
	Gui, VersionUpdate: Add,		Checkbox, x0 y0 HwndIdVerUpdDwnlOnStart gF_DwnlUpdOnStart Checked%ini_DownloadRepo%,	% TransA["Download if update is available on startup?"]
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_DwnlUpdOnStart()	
{
	global	;assume-global mode
	ini_DownloadRepo := !ini_DownloadRepo
	IniWrite, % ini_DownloadRepo, % ini_HADConfig, Configuration, DownloadRepo
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_CheckUpdOnStart() 
{
	global	;assume-global mode
	ini_CheckRepo := !ini_CheckRepo
	Iniwrite, % ini_CheckRepo, % ini_HADConfig, Configuration, CheckRepo
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_VerUpdDownload()	
{
	global	;assume-global mode
	local	URLscript := 	"https://raw.githubusercontent.com/mslonik/Hotstrings/master/Hotstrings/Hotstrings.ahk"
			,URLexe := 	"https://raw.githubusercontent.com/mslonik/Hotstrings/master/Hotstrings/Hotstrings.exe"
			,whr := "", Result := "", e := ""
	
	if (A_IsCompiled)
	{
		try
			FileMove, % A_ScriptFullPath, % A_ScriptDir . "\" . "temp.exe"
		catch e
		{
			MsgBox, , Error, % "ErrorLevel" . A_Tab . ErrorLevel
					. "`n`n" . "A_LastError" . A_Tab . A_LastError	;183 : Cannot create a file when that file already exists.
					. "`n`n" . "Exception" . A_Tab . e
			try	;if no try, some warnings are still catched; with try no more warnings		
				ExitApp, 4 ; File move unsuccessful.		
		}
		try
			URLDownloadToFile, % URLexe, % A_ScriptFullPath
		catch e
			MsgBox, 16, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["error"], % A_ThisFunc . A_Space TransA["caused problem on line URLDownloadToFile."]
		if (!ErrorLevel)		
		{
			MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["According to your wish the new version of application was found on the server and downloaded."]
			. A_Space . TransA["The old version is already overwritten."]
			. "`n" . TransA["Next the default language file (English.txt) will be deleted,"]
			. "`n" . TransA["reloaded and fresh language file (English.txt) will be recreated."]
			FileDelete, % A_ScriptDir . "\Languages\English.txt" 	;this file is deleted because often after update of Hotstrings.exe the language definitions are updated too.
			Gui, VersionUpdate: Hide
			F_ReloadApplication()
		}
		return
	}
	else
	{
		try
			URLDownloadToFile, % URLscript, 		% A_ScriptFullPath
		catch
			MsgBox, 17, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["error"], % "Something went wrong on time of downloading AutoHotkey script file."
		if (!ErrorLevel)
		{
			MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["According to your wish the new version of application was found on the server and downloaded."]
			. A_Space . TransA["The old version is already overwritten."]
			. "`n" . TransA["Next the default language file (English.txt) will be deleted,"]
			. "`n" . TransA["reloaded and fresh language file (English.txt) will be recreated."]
			FileDelete, % A_ScriptDir . "\Languages\English.txt" 	;this file is deleted because often after update of Hotstrings.exe the language definitions are updated too.
			Gui, VersionUpdate: Hide
			F_ReloadApplication()
			return
		}
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_VerUpdCheckServ(param*)
{
	global	;assume-global mode
	local	whr := "", URLscript := "https://raw.githubusercontent.com/mslonik/Hotstrings/master/Hotstrings.ahk", ToBeFiltered := "", ServerVer := "", StartingPos := 0
			, ServerVer1 := 0, ServerVer2 := 0, ServerVer3 := 0, AppVersion1 := 0, AppVersion2 := 0, AppVersion3 := 0,	
	whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	whr.Open("GET", URLscript, true)
	whr.Send()	; Using 'true' above and the call below allows the script to remain responsive.
	whr.WaitForResponse()
	ToBeFiltered := whr.ResponseText
	
	Loop, Parse, ToBeFiltered, `n
		if (InStr(A_LoopField, "AppVersion"))
		{
			RegExMatch(A_LoopField, "\d+.\d+.\d+", ServerVer)
			Break
		}
	Switch param[1]
	{
		Case "OnStartUp":
		if (ServerVer != AppVersion)
		{
			MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["On start-up the local version of application was compared with repository version and difference was discovered:"]  
					. "`n`n" . TransA["Local version"] . ":"	 . A_Tab . A_Tab . AppVersion
					. "`n" .   TransA["Repository version"] . ":" . A_Tab . A_Tab . ServerVer
		}
		whr := ""		
		return
		Case "ReturnResult":
		whr := ""
		if (ServerVer != AppVersion)
		{
			Loop, Parse, ServerVer, .
			{
				Switch A_Index
				{
					Case 1: ServerVer1 := A_LoopField
					Case 2: ServerVer2 := A_LoopField
					Case 3: ServerVer3 := A_LoopField
				}
			}
			Loop, Parse, AppVersion, .
			{
				Switch A_Index
				{
					Case 1: AppVersion1 := A_LoopField
					Case 2: AppVersion2 := A_LoopField
					Case 3: AppVersion3 := A_LoopField
				}
			}
			if (ServerVer1 > AppVersion1)	
				return true
			if (ServerVer1 = AppVersion1) and (ServerVer2 > AppVersion2)
				return true
			if (ServerVer1 = AppVersion1) and (ServerVer2 = AppVersion2) and (ServerVer3 > AppVersion3)
				return true
		}
		return false
		Default:
		whr := ""
		GuiControl, , % IdVerUpd4, % ServerVer
		return
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_GuiShortDef_DetermineConstraints() 
{
	global	;assume-global mode
;Within a function, to create a set of variables that is local instead of global, declare OutputVar as a local variable prior to using command GuiControlGet, Pos. However, it is often also necessary to declare each variable in the set, due to a common source of confusion.
	local v_OutVarTemp := 0, 	v_OutVarTempX := 0, 	v_OutVarTempY := 0, 	v_OutVarTempW := 0, 	v_OutVarTempH := 0
		,v_OutVarTemp1 := 0, 	v_OutVarTemp1X := 0, 	v_OutVarTemp1Y := 0, 	v_OutVarTemp1W := 0, 	v_OutVarTemp1H := 0
		,v_OutVarTemp2 := 0, 	v_OutVarTemp2X := 0, 	v_OutVarTemp2Y := 0, 	v_OutVarTemp2W := 0, 	v_OutVarTemp2H := 0
		,v_OutVarTemp3 := 0, 	v_OutVarTemp3X := 0, 	v_OutVarTemp3Y := 0, 	v_OutVarTemp3W := 0, 	v_OutVarTemp3H := 0
							,v_xNext := 0, 		v_yNext := 0, 			v_wNext := 0, 			v_hNext := 0
		,WhichIsWider := 0
	
; Determine constraints, according to mock-up
	v_xNext := c_xmarg
,	v_yNext := c_ymarg
	GuiControl, Move, % IdShortDefT1, % "x" . v_xNext . "y" . v_yNext		;Call Graphical User Interface
	GuiControlGet, v_OutVarTemp, Pos, % IdShortDefT1
	v_xNext := v_OutVarTempX + v_OutVarTempW + c_xmarg
	GuiControl, Move, % IdShortDefT4, % "x" . v_xNext . "y" . v_yNext		;ⓘ
	v_xNext := c_xmarg
,	v_yNext += 2 * c_HofText
	GuiControl, Move, % IdShortDefT2, % "x" . v_xNext . "y" . v_yNext		;Current shortcut (hotkey):
	GuiControlGet, v_OutVarTemp, Pos, % IdShortDefT2
	v_xNext := v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdShortDefT3, % "x" . v_xNext . "y" . v_yNext		;% ShortcutLong
	v_xNext := c_xmarg
,	v_yNext += c_HofText
	GuiControl, Move, % IdShortDefT9, % "x" . v_xNext . "y" . v_yNext		;Default shortcut (hotkey):
	v_xNext := v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdShortDefT10, % "x" . v_xNext . "y" . v_yNext		;Default shortcut (hotkey):
	GuiControlGet, v_OutVarTemp, Pos, % IdShortDefT10
	v_xNext := c_xmarg
	v_yNext += 2 * c_HofText
	GuiControl, Move, % IdShortDefT5, % "x" . v_xNext . "y" . v_yNext		;New shortcut (hotkey)
	GuiControlGet, v_OutVarTemp, Pos, % IdShortDefT5
	v_xNext := v_OutVarTempX + v_OutVarTempW + c_xmarg
	GuiControl, Move, % IdShortDefT6, % "x" . v_xNext . "y" . v_yNext		;ⓘ
	v_xNext := c_xmarg
,	v_yNext += 2 * c_HofText
	GuiControl, Move, % IdShortDefCB1, % "x" . v_xNext . "y" . v_yNext		;Windows key modifier
	GuiControlGet, v_OutVarTemp, Pos, % IdShortDefCB1						
	v_xNext := v_OutVarTempX + v_OutVarTempW + c_xmarg
	GuiControl, Move, % IdShortDefH1, % "x" . v_xNext . "y" . v_yNext		;HotkeyVar
	v_xNext := c_xmarg
,	v_yNext := v_OutVarTempY + v_OutVarTempH
	GuiControl, Move, % IdShortDefCB2, % "x" . v_xNext . "y" . v_yNext		;Tilde (~) key modifier
	GuiControlGet, v_OutVarTemp1, Pos, % IdShortDefH1						;reserve more space for text string
	v_wNext := v_OutVarTemp1W
	GuiControl, Move, % IdShortDefT3, % "w" . v_wNext
	GuiControlGet, v_OutVarTemp, Pos, % IdShortDefCB2
	v_xNext := v_OutVarTempX + v_OutVarTempW 
,	v_yNext := v_OutVarTempY 
	GuiControl, Move, % IdShortDefT7, % "x" . v_xNext . "y" . v_yNext
	v_xNext := c_xmarg
,	v_yNext := v_OutVarTempY + v_OutVarTempH + c_HofText

	GuiControl, Move, % IdShortDefCB3, % "x" . v_xNext . "y" . v_yNext	;ScrollLock
	GuiControlGet, v_OutVarTemp, Pos, % IdShortDefCB3
	v_xNext += v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdShortDefCB4, % "x" . v_xNext . "y" . v_yNext	;CapsLock
	GuiControlGet, v_OutVarTemp, Pos, % IdShortDefCB4
	v_xNext += v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdShortDefCB5, % "x" . v_xNext . "y" . v_yNext	;NumLock
	v_xNext := c_xmarg
,	v_yNext += 2 * c_HofText

	GuiControl, Move, % IdShortDefB1, % "x" . v_xNext . "y" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdShortDefB1
	v_xNext := v_OutVarTempX + v_OutVarTempW + c_xmarg
	GuiControl, Move, % IdShortDefB2, % "x" . v_xNext . "y" . v_yNext
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_ParseHotkey(WhichItem, space*)
{
	local Mini := false, ShortcutLong := "", HotkeyVar := ""
	
	if (WhichItem != "none")
	{
		Loop, Parse, WhichItem
		{
			Mini := false
			Switch A_LoopField
			{
				Case "~":
					Mini := true
					if (space[1])
						ShortcutLong .= "~"
					else
						Continue
				Case "^":	
					Mini := true
,					ShortcutLong .= "Ctrl"
				Case "!":	
					Mini := true
,					ShortcutLong .= "Alt"	
				Case "+":	
					Mini := true
,					ShortcutLong .= "Shift"
				Case "#":
					Mini := true
,					ShortcutLong .= "Win"
				Default:
					StringUpper, HotkeyVar, A_LoopField 
					ShortcutLong .= HotkeyVar
			}
			if (Mini)
			{
				if (space[1])
				{
					if (ShortcutLong = "~")
						Continue
					else
						ShortcutLong .= "+"
						; ShortcutLong .= " + "
				}
				else
					ShortcutLong .= "+"
			}
		}
		StringCaseSense, On
		ShortcutLong := StrReplace(ShortcutLong, "SCROLLLOCK", "ScrollLock")
		ShortcutLong := StrReplace(ShortcutLong, "CAPSLOCK", 	"CapsLock")
		ShortcutLong := StrReplace(ShortcutLong, "NUMLOCK", 	"NumLock")
		StringCaseSense, Off
	}
	else
		ShortcutLong := "None"
	return ShortcutLong
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_GuiShortDef_WhichModifier(WhichItem)
{
	global	;assume-global mode of operation
	local	IfWinModifier := false, IfTildeModifier := false, HotkeyVar := ""
,			IfScrollLock := false, IfCapsLock := false, IfNumLock := false
,			DynVarRef1 := "", a_ReturnVector := []

	DynVarRef1 := "ini_HK_" . WhichItem
	if (%DynVarRef1% != "")
	{
		if (InStr(%DynVarRef1%, "#"))
		{
			IfWinModifier 		:= true
,			HotkeyVar 		:= StrReplace(%DynVarRef1%, "#")
		}
		else
			HotkeyVar 		:= %DynVarRef1%
		if (InStr(%DynVarRef1%, "~"))
		{
			IfTildeModifier 	:= true
,			HotkeyVar 		:= StrReplace(%DynVarRef1%, "~")
		}
		else
			HotkeyVar 		:= %DynVarRef1%
		if (InStr(%DynVarRef1%, "CapsLock"))
		{
			IfCapsLock 		:= true
,			HotkeyVar			:= "none"				
		}
		if (InStr(%DynVarRef1%, "ScrollLock"))
		{
			IfScrollLock		:= true
,			HotkeyVar			:= "none"				
		}
		if (InStr(%DynVarRef1%, "NumLock"))
		{
			IfNumLock			:= true
,			HotkeyVar			:= "none"			
		}
	}
	a_ReturnVector[1] := IfWinModifier
,	a_ReturnVector[2] := IfTildeModifier
, 	a_ReturnVector[3] := IfCapsLock 
,	a_ReturnVector[4] := IfScrollLock
,	a_ReturnVector[5] := IfNumLock
,	a_ReturnVector[6] := HotkeyVar
	return a_ReturnVector
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_GuiShortDef_CreateObjects(ItemName)
{
	global	;assume-global mode of operation
	local	IfWinModifier := false, IfTildeModifier := false, Mini := false, HotkeyVar := ""
,			IfScrollLock := false, IfCapsLock := false, IfNumLock := false
,			a_WhichKeys := []	;a_WhichKeys[1] := IfWinModifier, a_WhichKeys[2] := IfTildeModifer, a_WhichKeys[3] := IfCapsLock, a_WhichKeys[4] := IfScrollLock, a_WhichKeys[5] := HotkeyVar
	
	;1. Prepare Gui
	Gui, ShortDef: New, 	-Resize +HwndShortDefHwnd +Owner -MaximizeBox -MinimizeBox
	Gui, ShortDef: Margin,	% c_xmarg, % c_ymarg
	Gui,	ShortDef: Color,	% c_WindowColor, % c_ControlColor
	
	;2. Prepare all text objects according to mock-up.
	Gui,	ShortDef: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, 			% c_FontType
	
	if (InStr(ItemName, TransA["Call Graphical User Interface"]))
		Gui, ShortDef: Add, 	Text,    	x0 y0 HwndIdShortDefT1,	% TransA["Call Graphical User Interface"]
	if (InStr(ItemName, TransA["Copy clipboard content into ""Enter hotstring"""]))
		Gui, ShortDef: Add, 	Text,    	x0 y0 HwndIdShortDefT1,	% TransA["Copy clipboard content into ""Enter hotstring"""]
	if (InStr(ItemName, TransA["Undo the last hotstring"]))
		Gui, ShortDef: Add, 	Text,    	x0 y0 HwndIdShortDefT1,	% TransA["Undo the last hotstring"]
	if (InStr(ItemName, TransA["Toggle triggerstring tips"]))
		Gui, ShortDef: Add,		Text,	x0 y0 HwndIdShortDefT1,	% TransA["Toggle triggerstring tips"]
	
	Gui, ShortDef: Add, 	Text,    	x0 y0 HwndIdShortDefT2,				% TransA["Current shortcut (hotkey):"]
	Gui, ShortDef: Add,		Text,	x0 y0 HwndIdShortDefT9,				% TransA["Default shortcut (hotkey):"]
	
	if (InStr(ItemName, TransA["Call Graphical User Interface"]))
	{
		Gui, ShortDef: Add, 	Text,    	x0 y0 HwndIdShortDefT3, 	% F_ParseHotkey(ini_HK_Main, 		"space")
		Gui, ShortDef: Add,		Text,	x0 y0 HwndIdShortDefT10,	% F_ParseHotkey(c_dHK_CallGUI, 	"space")
	}	
	if (InStr(ItemName, TransA["Copy clipboard content into ""Enter hotstring"""]))
	{
		Gui, ShortDef: Add, 	Text,    	x0 y0 HwndIdShortDefT3, 	% F_ParseHotkey(ini_HK_IntoEdit, 	"space")
		Gui, ShortDef: Add,		Text,	x0 y0 HwndIdShortDefT10,	% F_ParseHotkey(c_dHK_CopyClip, 	"space")
	}	
	if (InStr(ItemName, TransA["Undo the last hotstring"]))
	{
		Gui, ShortDef: Add, 	Text,    	x0 y0 HwndIdShortDefT3, 	% F_ParseHotkey(ini_HK_UndoLH, 	"space")
		Gui, ShortDef: Add,		Text,	x0 y0 HwndIdShortDefT10,	% F_ParseHotkey(c_dHK_UndoLH, 	"space")
	}	
	if (InStr(ItemName, TransA["Toggle triggerstring tips"]))
	{
		Gui, ShortDef: Add,		Text,	x0 y0 HwndIdShortDefT3,	% F_ParseHotkey(ini_HK_ToggleTt, 	"space")
		Gui, ShortDef: Add,		Text,	x0 y0 HwndIdShortDefT10,	% F_ParseHotkey(c_dHK_ToggleTt, 	"space")
	}	

	Gui, ShortDef: Font, 	% "s" . c_FontSize + 2 . A_Space . "cBlue",		% c_FontType
	Gui, ShortDef: Add, 	Text,    	x0 y0 HwndIdShortDefT4,				ⓘ
	Gui,	ShortDef: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, 	% c_FontType
	
	if (InStr(ItemName, TransA["Call Graphical User Interface"]))
	{
		F_HK_CallGUIInfo := func("F_ShowLongTooltip").bind(TransA["F_HK_CallGUIInfo"])
		GuiControl +g, % IdShortDefT4, % F_HK_CallGUIInfo
		a_WhichKeys := F_GuiShortDef_WhichModifier("Main")
	}
	if (InStr(ItemName, TransA["Copy clipboard content into ""Enter hotstring"""]))
	{
		F_HK_ClipCopyInfo := func("F_ShowLongTooltip").bind(TransA["F_HK_ClipCopyInfo"])
		GuiControl +g, % IdShortDefT4, % F_HK_ClipCopyInfo
		a_WhichKeys := F_GuiShortDef_WhichModifier("IntoEdit")
	}
	if (InStr(ItemName, TransA["Undo the last hotstring"]))
	{
		F_HK_UndoInfo := func("F_ShowLongTooltip").bind(TransA["F_HK_UndoInfo"])
		GuiControl +g, % IdShortDefT4, % F_HK_UndoInfo
		a_WhichKeys := F_GuiShortDef_WhichModifier("UndoLH")
	}
	if (InStr(ItemName, TransA["Toggle triggerstring tips"]))
	{
		F_HK_UndoInfo := func("F_ShowLongTooltip").bind(TransA["F_HK_ToggleTtInfo"])
		GuiControl +g, % IdShortDefT4, % F_HK_UndoInfo
		a_WhichKeys := F_GuiShortDef_WhichModifier("ToggleTt")	
	}
	
	IfWinModifier 	 := a_WhichKeys[1]
, 	IfTildeModifier := a_WhichKeys[2]
, 	IfCapsLock 	 := a_WhichKeys[3]
, 	IfScrollLock 	 := a_WhichKeys[4]
,	IfNumLock		 := a_WhichKeys[5]
, 	HotkeyVar 	 := a_WhichKeys[6]
	
	Gui, ShortDef: Add, 	Text,    	x0 y0 HwndIdShortDefT5,										% TransA["New shortcut (hotkey)"] . ":"
	Gui, ShortDef: Font, 	% "s" . c_FontSize + 2 . A_Space . "cBlue",								% c_FontType
	Gui, ShortDef: Add,		Text,	x0 y0 HwndIdShortDefT6,										ⓘ
	Gui,	ShortDef: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, 			% c_FontType
	F_HK_GeneralInfo := func("F_ShowLongTooltip").bind(TransA["F_HK_GeneralInfo"])
	GuiControl +g, % IdShortDefT6, % F_HK_GeneralInfo
	Gui, ShortDef: Add,		Checkbox,	x0 y0 HwndIdShortDefCB1 Checked%IfWinModifier%,					% TransA["Windows key modifier"]
	Gui, ShortDef: Add,		Hotkey,	x0 y0 HwndIdShortDefH1,										% HotkeyVar
	Gui, ShortDef: Add,		Checkbox, x0 y0 HwndIdShortDefCB2 Checked%IfTildeModifier%,					% TransA["Tilde (~) key modifier"]
	Gui, ShortDef: Add,		Checkbox, x0 y0 HwndIdShortDefCB3 Checked%IfScrollLock%,					Scroll Lock
	Gui, ShortDef:	Add,		Checkbox,	x0 y0 HwndIdShortDefCB4 Checked%IfCapsLock%,						Caps Lock
	Gui, ShortDef:	Add,		Checkbox,	x0 y0 HwndIdShortDefCB5 Checked%IfNumLock%,						Num Lock
	Gui, ShortDef: Font, 	% "s" . c_FontSize + 2 . A_Space . "cBlue",								% c_FontType
	Gui, ShortDef: Add,		Text,	x0 y0 HwndIdShortDefT7,										ⓘ
	Gui,	ShortDef: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, 			% c_FontType
	F_HK_TildeModInfo := func("F_ShowLongTooltip").bind(TransA["F_HK_TildeModInfo"])
	GuiControl +g, % IdShortDefT7, % F_HK_TildeModInfo
	Gui, ShortDef: Add, 	Button,  	x0 y0 HwndIdShortDefB1 gF_ShortDefB1_SaveHotkey,					% TransA["Apply new hotkey"]
	Gui, ShortDef: Add, 	Button,  	x0 y0 HwndIdShortDefB2 gF_ShortDefB2_RestoreHotkey,				% TransA["Restore default hotkey"]
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_ChangeMainWindowTitle()
{
	global	;assume-global mode of operation

	Switch F_WhichGui()
	{
		Case "HS3":
			Gui, HS3: Show, Hide, % A_ScriptName . A_Space . A_Space . A_Space . A_Space . A_Space . "(" . F_ParseHotkey(ini_HK_Main, "space") . ")"
			Gui, HS3: Show
			Gui, HS4: Show, Hide, % A_ScriptName . A_Space . A_Space . A_Space . A_Space . A_Space . "(" . F_ParseHotkey(ini_HK_Main, "space") . ")"
		Case "HS4": 
			Gui, HS4: Show, Hide, % A_ScriptName . A_Space . A_Space . A_Space . A_Space . A_Space . "(" . F_ParseHotkey(ini_HK_Main, "space") . ")"
			Gui, HS4: Show
			Gui, HS3: Show, Hide, % A_ScriptName . A_Space . A_Space . A_Space . A_Space . A_Space . "(" . F_ParseHotkey(ini_HK_Main, "space") . ")"
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_ShortDefB2_RestoreHotkey()
{
	global	;assume-global mode of operation
	local	OldHotkey := "", WindowKey := false
	
	GuiControlGet, OldHotkey, , % IdShortDefT3
	OldHotkey := StrReplace(OldHotkey, "Shift", 	"+")
,	OldHotkey := StrReplace(OldHotkey, "Ctrl", 	"^")
,	OldHotkey := StrReplace(OldHotkey, "Alt", 	"!")
,	OldHotkey := StrReplace(OldHotkey, "Win", 	"#")
,	OldHotkey := StrReplace(OldHotkey, "+")
,	OldHotkey := StrReplace(OldHotkey, " ")

	if (InStr(A_ThisMenuItem, TransA["Call Graphical User Interface"]))
	{
		if (OldHotkey != "none")	
			Hotkey, % OldHotkey, F_GUIInit, Off
		ini_HK_Main := c_dHK_CallGUI
		GuiControl,, % IdShortDefCB3, 0
		GuiControl,, % IdShortDefCB4, 0
		GuiControl,, % IdShortDefCB5, 0
		Hotkey, If, v_SilentMode != "l" 
		Hotkey, % ini_HK_Main, F_GUIInit, On
		Hotkey, If						;To turn off context sensitivity (that is, to make subsequently-created hotkeys work in all windows)
		GuiControl, , % IdShortDefT3, % F_ParseHotkey(ini_HK_Main, "space")
		IniWrite, % ini_HK_Main, % ini_HADConfig, Configuration, HK_Main
		Menu, Submenu1Shortcuts, Rename, % A_ThisMenuItem, % TransA["Call Graphical User Interface"] . "`t" . F_ParseHotkey(ini_HK_Main, 	"space")
		F_ChangeMainWindowTitle()
	}

	if (InStr(A_ThisMenuitem, TransA["Copy clipboard content into ""Enter hotstring"""]))
	{
		if (OldHotkey != "none")
		{
			Hotkey, IfWinExist, % "ahk_id" HS3GuiHwnd
			Hotkey, % OldHotkey, F_PasteFromClipboard, Off
			Hotkey, IfWinExist, % "ahk_id" HS4GuiHwnd
			Hotkey, % OldHotkey, F_PasteFromClipboard, Off
			Hotkey, IfWinExist				;To turn off context sensitivity (that is, to make subsequently-created hotkeys work in all windows)
		}
		ini_HK_IntoEdit := c_dHK_CopyClip
		GuiControl,, % IdShortDefCB3, 0
		GuiControl,, % IdShortDefCB4, 0
		GuiControl,, % IdShortDefCB5, 0
		Hotkey, IfWinExist, % "ahk_id" HS3GuiHwnd
		Hotkey, % ini_HK_IntoEdit, F_PasteFromClipboard, On
		Hotkey, IfWinExist, % "ahk_id" HS4GuiHwnd
		Hotkey, % ini_HK_IntoEdit, F_PasteFromClipboard, On
		Hotkey, IfWinExist					;To turn off context sensitivity (that is, to make subsequently-created hotkeys work in all windows)
		GuiControl, , % IdShortDefT3, % F_ParseHotkey(ini_HK_IntoEdit, "space")
		IniWrite, % ini_HK_IntoEdit, % ini_HADConfig, Configuration, HK_IntoEdit
		Menu, Submenu1Shortcuts, Rename, % A_ThisMenuItem, % TransA["Copy clipboard content into ""Enter hotstring"""] . "`t" . F_ParseHotkey(ini_HK_IntoEdit, "space")
	}

	if (InStr(A_ThisMenuitem, TransA["Undo the last hotstring"]))
	{
		if (ini_HotstringUndo)
		{
			; OutputDebug, % "OldHotkey:" . A_Space . OldHotkey . "`n"
			if (OldHotkey != "none")
				Hotkey, % OldHotkey, 	F_Undo, Off
			ini_HK_UndoLH := c_dHK_UndoLH	;set default (d) hotkey (HK)
			Hotkey, % ini_HK_UndoLH, F_Undo, On
		}
		else
		{
			if (OldHotkey != "none")
				Hotkey, % OldHotkey, 	F_Undo, Off
			ini_HK_UndoLH := c_dHK_UndoLH	;set default (d) hotkey (HK)
			Hotkey, % ini_HK_UndoLH, F_Undo, Off
		}
		GuiControl,, % IdShortDefCB3, 0
		GuiControl,, % IdShortDefCB4, 0
		GuiControl,, % IdShortDefCB5, 0
		GuiControl,, % IdShortDefT3, % F_ParseHotkey(ini_HK_UndoLH, "space")
		IniWrite, % ini_HK_UndoLH, % ini_HADConfig, Configuration, HK_UndoLH
		; OutputDebug, % "A_ThisMenuItem:" . A_Space . A_ThisMenuItem . "ini_HK_UndoLH:" . A_Space . ini_HK_UndoLH . "`n"
		Menu, Submenu1Shortcuts, Rename, % A_ThisMenuItem, % TransA["Undo the last hotstring"] . "`t" . F_ParseHotkey(ini_HK_UndoLH, "space")
	}

	if (InStr(A_ThisMenuitem, TransA["Toggle triggerstring tips"]))
	{
		if (OldHotkey != "none")	
			Hotkey, % OldHotkey, F_ToggleTt, Off
		ini_HK_ToggleTt := "none"
		GuiControl,, % IdShortDefT3, % F_ParseHotkey(ini_HK_ToggleTt, "space")
		GuiControl,, % IdShortDefCB1, 0
		GuiControl,, % IdShortDefCB2, 0
		GuiControl,, % IdShortDefCB3, 0
		GuiControl,, % IdShortDefCB4, 0
		GuiControl,, % IdShortDefCB5, 0
		IniWrite, % ini_HK_ToggleTt, % ini_HADConfig, Configuration, HK_ToggleTt
		Menu, Submenu1Shortcuts, Rename, % A_ThisMenuItem, % TransA["Toggle triggerstring tips"] . "`t" . F_ParseHotkey(ini_HK_ToggleTt, "space")
	}
	ShortDefGuiEscape()
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_InterpretNewDynHK(WhichHK)
{
	global	;assume-global mode of operation
	local	DynVarRef1 := "", DynVarRef2 := "", WindowKey := false, TildeKey := false, vCapsLock := false , vScrollLock := false, vNumLock := false, WhichHotkey := ""

	DynVarRef1 := "ini_HK_" . WhichHK
,	DynVarRef2 := "HK_" . WhichHK
	GuiControlGet, WindowKey, , 	% IdShortDefCB1
	GuiControlGet, TildeKey, , 	% IdShortDefCB2
	GuiControlGet, vScrollLock, ,	% IdShortDefCB3	;ScrollLock
	GuiControlGet, vCapsLock, , 	% IdShortDefCB4	;CapsLock
	GuiControlGet, vNumLock, , 	% IdShortDefCB5	;NumLock
	GuiControlGet, WhichHotkey, , % IdShortDefH1		;hotkey edit field

	if (WhichHotkey and vCapsLock) or (WhichHotkey and vScrollLock) or (WhichHotkey and vNumLock)
		MsgBox, 48, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["warning"], % TransA["Sorry, it's not allowed to use ordinary hotkey combined with Caps Lock or Scroll Lock or Num Lock."]
			. "`n`n"  . TransA["Please try again."]
	if (WhichHotkey)
	{
		%DynVarRef1% := WhichHotkey
		if (WindowKey)
			%DynVarRef1% := "#" . %DynVarRef1%
		if (TildeKey)
			%DynVarRef1% := "~" . %DynVarRef1%
	}
	if (vCapsLock and vScrollLock) or (vCapsLock and vNumLock) or (vScrollLock and vNumLock) or (vCapsLock and vScrollLock and vNumLock) ;impossible to have both settings at the same time
		MsgBox, 48, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["warning"], % TransA["Sorry, it's not allowed to use combination of Caps Lock, Scroll Lock and Num Lock for the same purpose."]
			. "`n`n"  . TransA["Please try again."]
	if (vCapsLock or vScrollLock or vNumLock)
	{
		if (vScrollLock)
		{
			%DynVarRef1% := "ScrollLock"
			GuiControl,, % IdShortDefH1, "none"
		}
		if (vCapsLock)
		{
			%DynVarRef1% := "CapsLock"
			GuiControl,, % IdShortDefH1, "none"
		}
		if (vNumLock)
		{
			%DynVarRef1% := "NumLock"
			GuiControl,, % IdShortDefH1, "none"
		}
		if (WindowKey)
			%DynVarRef1% := "#" . %DynVarRef1%
		if (TildeKey)
			%DynVarRef1% := "~" . %DynVarRef1%
	}
	if (!WhichHotkey) and (!vCapsLock) and (!vScrollLock) and (!vNumLock)
		%DynVarRef1% := "none"
	if (%DynVarRef1% != "")
		IniWrite, % %DynVarRef1%, % ini_HADConfig, Configuration, %DynVarRef2%
	else
	{
		%DynVarRef1% := "none"
		IniWrite, % %DynVarRef1%, % ini_HADConfig, Configuration, %DynVarRef2%
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_ShortDefB1_SaveHotkey()
{
	global	;assume-global mode of operation
	local	OldHotkey := "", WindowKey := false, TildeKey := false
	
	if (InStr(A_ThisMenuItem, TransA["Call Graphical User Interface"]))
		F_InterpretNewDynHK(WhichHK := "Main")
	if (InStr(A_ThisMenuitem, TransA["Copy clipboard content into ""Enter hotstring"""]))
		F_InterpretNewDynHK(WhichHK := "IntoEdit")
	if (InStr(A_ThisMenuitem, TransA["Undo the last hotstring"]))
		F_InterpretNewDynHK(WhichHK := "UndoLH")
	if (InStr(A_ThisMenuitem, TransA["Toggle triggerstring tips"]))
		F_InterpretNewDynHK(WhichHK := "ToggleTt")

	GuiControlGet, OldHotkey, , % IdShortDefT3	;OldHotkey := RegExReplace(OldHotkey, "(Ctrl)|(Shift)|(Win)|(\+)|( )")	;future: trick from AutoHotkey forum after my question
	OldHotkey := StrReplace(OldHotkey, "Shift", 	"+")
,	OldHotkey := StrReplace(OldHotkey, "Ctrl", 	"^")
,	OldHotkey := StrReplace(OldHotkey, "Alt", 	"!")
,	OldHotkey := StrReplace(OldHotkey, "Win", 	"#")
,	OldHotkey := StrReplace(OldHotkey, "+")
,	OldHotkey := StrReplace(OldHotkey, " ")

	if (InStr(A_ThisMenuItem, TransA["Call Graphical User Interface"]))
	{
		GuiControl, , % IdShortDefT3, % F_ParseHotkey(ini_HK_Main, "space")
		if (ini_HK_Main != "none")
		{
			Hotkey, If, v_SilentMode != "l"
			if (OldHotkey != "None")
				Hotkey, % OldHotkey, F_GUIInit, Off
			Hotkey, % ini_HK_Main, F_GUIInit, On
			Hotkey, If				;To turn off context sensitivity (that is, to make subsequently-created hotkeys work in all windows)
		}
		else
		{
			Hotkey, If, v_SilentMode != "l"
			Hotkey, % OldHotkey, F_GUIInit, Off
			Hotkey, If				;To turn off context sensitivity (that is, to make subsequently-created hotkeys work in all windows)
		}	
		Menu, Submenu1Shortcuts, Rename, % A_ThisMenuItem, % TransA["Call Graphical User Interface"] . "`t" . F_ParseHotkey(ini_HK_Main, "space")
		F_ChangeMainWindowTitle()
	}

	if (InStr(A_ThisMenuitem, TransA["Copy clipboard content into ""Enter hotstring"""]))
	{
		GuiControl, , % IdShortDefT3, % F_ParseHotkey(ini_HK_IntoEdit, "space")
		if (ini_HK_IntoEdit != "none")
		{
			Hotkey, IfWinExist, % "ahk_id" HS3GuiHwnd
			if (OldHotkey != "None")
				Hotkey, % OldHotkey, F_PasteFromClipboard, Off
			Hotkey, % ini_HK_IntoEdit, F_PasteFromClipboard, On
			Hotkey, IfWinExist, % "ahk_id" HS4GuiHwnd
			if (OldHotkey != "None")
				Hotkey, % OldHotkey, F_PasteFromClipboard, Off
			Hotkey, % ini_HK_IntoEdit, F_PasteFromClipboard, On
			Hotkey, IfWinExist			;To turn off context sensitivity (that is, to make subsequently-created hotkeys work in all windows)
		}
		else
		{
			Hotkey, IfWinExist, % "ahk_id" HS3GuiHwnd
			if (OldHotkey != "None")
				Hotkey, % OldHotkey, F_PasteFromClipboard, Off
			Hotkey, IfWinExist, % "ahk_id" HS4GuiHwnd
			if (OldHotkey != "None")
				Hotkey, % OldHotkey, F_PasteFromClipboard, Off
			Hotkey, IfWinExist			;To turn off context sensitivity (that is, to make subsequently-created hotkeys work in all windows)
		}
		Menu, Submenu1Shortcuts, Rename, % A_ThisMenuItem, % TransA["Copy clipboard content into ""Enter hotstring"""] . "`t" . F_ParseHotkey(ini_HK_IntoEdit, "space")
	}

	if (InStr(A_ThisMenuitem, TransA["Undo the last hotstring"]))
	{
		GuiControl, , % IdShortDefT3, % F_ParseHotkey(ini_HK_UndoLH, "space")
		; OutputDebug, % "ini_HK_UndoLH:" . ini_HK_UndoLH . "`n"
		if (ini_HK_UndoLH != "none")
		{
			if (OldHotkey != "None")
				Hotkey, % OldHotkey, 	F_Undo, Off
			Hotkey, % ini_HK_UndoLH, F_Undo, On
		}
		else
		{
			if (OldHotkey != "None")
				Hotkey, % OldHotkey, 	F_Undo, Off
		}	
		Menu, Submenu1Shortcuts, Rename, % A_ThisMenuItem, % TransA["Undo the last hotstring"] . "`t" . F_ParseHotkey(ini_HK_UndoLH, "space")
	}

	if (InStr(A_ThisMenuitem, TransA["Toggle triggerstring tips"]))
	{
		GuiControl, , % IdShortDefT3, % F_ParseHotkey(ini_HK_ToggleTt, "space")
		if (ini_HK_ToggleTt != "none")
		{
			Hotkey, % OldHotkey, F_ToggleTt, Off
			Hotkey, % ini_HK_ToggleTt, F_ToggleTt, On
			F_UpdateStateOfLockKeys(ini_HK_ToggleTt, ini_TTTtEn)
			Switch ini_HK_ToggleTt
			{
				Case "ScrollLock":	SetScrollLockState, AlwaysOff
				Case "CapsLock":	SetCapsLockState, 	AlwaysOff
				Case "NumLock":	SetNumLockState, 	AlwaysOff
			}
		}
		else
		{
			Hotkey, % OldHotkey, F_ToggleTt, Off
			Switch OldHotkey
			{
				Case "ScrollLock":	SetScrollLockState,	;If last parameter is omitted, the AlwaysOn/Off attribute of the key is removed (if present). 
				Case "CapsLock":	SetCapsLockState,	;If last parameter is omitted, the AlwaysOn/Off attribute of the key is removed (if present). 
				Case "NumLock":	SetNumLockState,	;If last parameter is omitted, the AlwaysOn/Off attribute of the key is removed (if present). 
			}	
		}
		Menu, Submenu1Shortcuts, Rename, % A_ThisMenuItem, % TransA["Toggle triggerstring tips"] . "`t" . F_ParseHotkey(ini_HK_ToggleTt, "space")
	}
	ShortDefGuiEscape()
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_UpdateStateOfLockKeys(ini_HK_ToggleTt, ini_TTTtEn)
{
	Switch ini_HK_ToggleTt
	{
		Case "~ScrollLock":
			if (ini_TTTtEn)
				SetScrollLockState, On
			else	
				SetScrollLockState, Off

		Case "~CapsLock":
			if (ini_TTTtEn)
				SetCapsLockState, On
			else	
				SetCapsLockState, Off

		Case "~NumLock":
			if (ini_TTTtEn)
				SetNumLockState, On
			else	
				SetNumLockState, Off
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_GuiShortDef(ItemName)
{
	global	;assume-global mode of operation
	local Window1X := 0, Window1Y := 0, Window1W := 0, Window1H := 0
		,Window2X := 0, Window2Y := 0, Window2W := 0, Window2H := 0
		,NewWinPosX := 0, NewWinPosY := 0
	
	; OutputDebug, % "ItemName:" . A_Space . ItemName . "`n"
	F_GuiShortDef_CreateObjects(ItemName)
	F_GuiShortDef_DetermineConstraints()
	
	Gui, % A_Gui . ": +Disabled"	;thanks to this line user won't be able to interact with main hotstring window if TTStyling window is available
	if (WinExist("ahk_id" . HS3GuiHwnd) or WinExist("ahk_id" . HS3GuiHwnd) or WinExist("ahk_id" . HS4GuiHwnd) or WinExist("ahk_id" . HS4GuiHwnd))
		WinGetPos, Window1X, Window1Y, Window1W, Window1H, A
	Gui, ShortDef: Show, Hide
	
	DetectHiddenWindows, On
	WinGetPos, Window2X, Window2Y, Window2W, Window2H, % "ahk_id" . ShortDefHwnd
	DetectHiddenWindows, Off
	if (Window1W)
	{
		NewWinPosX := Round(Window1X + (Window1W / 2) - (Window2W / 2))
		NewWinPosY := Round(Window1Y + (Window1H / 2) - (Window2H / 2))
		Gui, ShortDef: Show, % "AutoSize" . A_Space . "x" . NewWinPosX . A_Space . "y" . NewWinPosY, % A_ScriptName . ":" . A_Space . TransA["Shortcut (hotkey) definition"]
	}
	else
	{
		Gui, ShortDef: Show, Center AutoSize, % A_ScriptName . ":" . A_Space . TransA["Shortcut (hotkey) definition"]
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_Sort_a_Triggers(ByRef a_Table, f_SortAlpha, f_SortByLength)
{	;sort now so it's not necessary each time when user gets triggerstring tips; it should speed-up process significantly
	global	;assume-global mode
	local	key := "", value := "", s_SelectedTriggers := ""
	
	if (f_SortByLength)
		a_Table := F_SortArrayByLength(a_Table)

	if (f_SortAlpha)
	{
		;a_SelectedTriggers := F_SortArrayAlphabetically(a_SelectedTriggers)
		for key, value in a_Table	;table to string Conversion
			s_SelectedTriggers .= value . "`n"
		Sort, s_SelectedTriggers
		Loop, Parse, s_SelectedTriggers, `n	;string to table Conversion
			if (A_LoopField)
				a_Table[A_Index] := A_LoopField
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_DownloadPublicLibraries()
{
	global	;assume-global mode
	local	ToBeFiltered := "",	Result := "",	ToBeDownloaded := [], DownloadedFile := "", whr := ""
		,	URLconst 	:= "https://github.com/mslonik/Hotstrings-Libraries/"
		,	URLraw 	:= "https://raw.githubusercontent.com/mslonik/Hotstrings-Libraries/main/"
		,	ExistingLibraries := "", NewLibraries := "", part := 0, key := "", value := "", rest := 0
	
	whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	whr.Open("GET", URLconst, true)
	whr.Send()	; Using 'true' above and the call below allows the script to remain responsive.
	whr.WaitForResponse()
	ToBeFiltered := whr.ResponseText
	
	Loop, Parse, ToBeFiltered, `n
		if (InStr(A_LoopField, ".csv"))
		{
			RegExMatch(A_LoopField, "i)title="".*.csv"" ", Result)	;i) = case sensitive matching
			if (Result != "")
				ToBeDownloaded.Push(SubStr(Result, 8, -2))			;start from 8th character, omit last 2 characters
		}
	
	Gui, DLG: New, +HwndDLGHwnd +OwnDialogs,	% A_ScriptName	;DLG: Download Libraries Gui
	Gui, DLG: Add, Text,, % TransA["Downloading public library files"] . A_Space . "(0 ÷ 100%):"
	Gui, DLG: Add, Progress, w400 h20 HwndLibProgress, cBlue, 0
	Gui, DLG: Show, AutoSize
	part := 100 // ToBeDownloaded.Count()		;floor divide, because progress bar requires integer values
,	rest := 100 - ToBeDownloaded.Count() * part	;rest which have to be used to reach 100
	for key, value in ToBeDownloaded
	{
		if (rest)
		{
			GuiControl,, % LibProgress, % "+" . part + 1
			rest--
		}
		else
			GuiControl,, % LibProgress, % "+" . part
		if (FileExist(ini_HADL . "\" . value))
			ExistingLibraries .= value . "`n"
		else
		{
			NewLibraries  .= value . "`n"
			URLDownloadToFile, % URLraw . value, % ini_HADL . "\" . value
		}
	}
	Gui, DLG: Destroy
	if (ExistingLibraries)
		MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["The following file(s) haven't been downloaded as they are already present in the location"] . ":" 
			. "`n" . ini_HADL
			. "`n`n" . ExistingLibraries
	
	if (NewLibraries)
		MsgBox, 68, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["Public library:"] . "`n`n" . NewLibraries . "`n" . TransA["has been downloaded to the location"] 
			. "`n" . ini_HADL
			. "`n`n" . TransA["After downloading libraries aren't automaticlly loaded into memory. Would you like to upload content of libraries folder into memory?"]
	
	IfMsgBox, Yes
	{
		F_ValidateIniLibSections()
		F_LoadHotstringsFromLibraries()
		F_LoadTTperLibrary()
		F_Sort_a_Triggers(a_Combined, ini_TipsSortAlphabetically, ini_TipsSortByLength)
		F_RefreshListOfLibraries()	; this function calls F_RefreshListOfLibraryTips() as both options are interrelated
		F_UpdateSelHotLibDDL()
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_MenuShowIntro()
{
	global	;assume-global mode
	static	FirstRun := true
	
	if (FirstRun)
	{
		if (ini_ShowIntro)
		{
			Menu,	IntroSubDecision, Check, 	% TransA["Yes"]
			Menu,	IntroSubDecision, UnCheck, 	% TransA["No"]
		}
		else
		{
			Menu,	IntroSubDecision, UnCheck, 	% TransA["Yes"]
			Menu,	IntroSubDecision, Check, 	% TransA["No"]
		}
		FirstRun := false
	}
	else
	{
		ini_ShowIntro := !ini_ShowIntro
		if (ini_ShowIntro)
		{
			Menu,	IntroSubDecision, Check, 	% TransA["Yes"]
			Menu,	IntroSubDecision, UnCheck, 	% TransA["No"]
		}
		else
		{
			Menu,	IntroSubDecision, UnCheck, 	% TransA["Yes"]
			Menu,	IntroSubDecision, Check, 	% TransA["No"]
		}
		Iniwrite, % ini_ShowIntro, % ini_HADConfig, Configuration, ShowIntro
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_GuiShowIntro()
{
	global	;assume-global mode
	local	v_xNext := 0,	v_yNext := 0, v_wNext := 0,	v_hNext := 0
			,v_OutVarTemp := 0, 	v_OutVarTempX := 0, 	v_OutVarTempY := 0, 	v_OutVarTempW := 0, 	v_OutVarTempH := 0
			,v_OutVarTemp1 := 0, 	v_OutVarTemp1X := 0, 	v_OutVarTemp1Y := 0, 	v_OutVarTemp1W := 0, 	v_OutVarTemp1H := 0
			,WhichGui := ""
	
	;1. Prepare MyAbout Gui
	Gui, ShowIntro: New, 	-Resize +HwndShowIntroGuiHwnd +Owner -MaximizeBox -MinimizeBox, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["Introduction"]
	Gui, ShowIntro: Margin,	% c_xmarg, % c_ymarg
	Gui,	ShowIntro: Color,	% c_WindowColor, % c_ControlColor
	
	TransA["ShowInfoText"] := StrReplace(TransA["ShowInfoText"], "``n", "`n")
	;2. Prepare all text objects according to mock-up.
	Gui,	ShowIntro: Font,	% "s" . c_FontSize . A_Space . "bold" . A_Space . "c" . c_FontColor, 		% c_FontType
	Gui, ShowIntro: Add, 	Text,    x0 y0 HwndIdIntroLine1, 									% TransA["Welcome to Hotstrings application!"]
	Gui,	ShowIntro: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, 		% c_FontType
	Gui, ShowIntro: Add, 	Text,    x0 y0 HwndIdIntroLine2,									% TransA["ShowInfoText"]
	Gui, ShowIntro: Add, 	Text,    x0 y0 HwndIdIntroLine3,									% TransA["I wish you good work with Hotstrings and DFTBA (Don't Forget to be Awsome)!"]
	Gui, ShowIntro: Add, 	Button,  x0 y0 HwndIdIntroOkButton gShowIntroGuiClose,					% TransA["OK"]
	if (A_IsCompiled)
		Gui, ShowIntro: Add,		Picture, 	x0 y0 HwndIdIntroPicture w96 h96 Icon,				% A_ScriptFullPath
	else
		Gui, ShowIntro: Add,		Picture, 	x0 y0 HwndIdIntroPicture w96 h96, 					% AppIcon

	Gui, ShowIntro: Add,	CheckBox, x0 y0 HwndIdIntroCheckbox vIntroCheckbox gF_ShowIntroCheckbox,	% TransA["Show Introduction window after application is restarted?"]

	;3. Determine constraints
	v_xNext := c_xmarg
,	v_yNext := c_ymarg
	GuiControl, Move,			% IdIntroLine1, % "x" . v_xNext . "y" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdIntroLine1
	v_yNext := v_OutVarTempY + v_OutVarTempH + 2 * c_ymarg
	GuiControl, Move,			% IdIntroLine2, % "x" . v_xNext . "y" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdIntroLine2
	v_yNext := v_OutVarTempY + v_OutVarTempH + 2 * c_ymarg
	GuiControl, Move,			% IdIntroLine3, % "x" . v_xNext . "y" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdIntroLine3
	v_xNext := v_OutVarTempW // 2
,	v_yNext := v_OutVarTempY + v_OutVarTempH + 2 * c_ymarg
	GuiControlGet, v_OutVarTemp1, Pos, % IdIntroOkButton
	v_wNext := v_OutVarTemp1W + 2 * c_xmarg
	GuiControl, Move,			% IdIntroOkButton, % "x" . v_xNext . "y" . v_yNext . "w" . v_wNext
	v_xNext := v_OutVarTempX + v_OutVarTempW + 10 * c_xmarg
,	v_yNext := v_OutVarTempY
	GuiControl, Move,			% IdIntroPicture, % "x" . v_xNext . "y" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdIntroOkButton
	v_xNext := c_xmarg
,	v_yNext := v_OutVarTempY + v_OutVarTempH + c_ymarg
	GuiControl, Move,			% IdIntroCheckbox, % "x" . v_xNext . "y" . v_yNext
	
	GuiControl,, % IdIntroCheckbox, % ini_ShowIntro	;load initial value
	if (WhichGui := F_WhichGui() )
		Gui, % WhichGui . ": +Disabled"	;thanks to this line user won't be able to interact with main hotstring window if TTStyling window is available
	Gui, ShowIntro: Show, AutoSize Center
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_ShowIntroCheckbox()
{
	global	;assume-global mode
	Gui, ShowIntro: Submit, NoHide
	ini_ShowIntro := IntroCheckbox
	IniWrite, % ini_ShowIntro, % ini_HADConfig, Configuration, ShowIntro
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_ShowLongTooltip(string)
{
	ToolTip, % StrReplace(string, "``n", "`n")
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_Undo()	;turning off of * option requires special conditions.
{
	global	;assume-global mode
	local	TriggerOpt := "", HowManyBackSpaces := 0, HowManyBackSpaces2 := 0
			,ThisHotkey := A_ThisHotkey, PriorHotkey := A_PriorHotkey, OrigTriggerstring := "", HowManySpecials := 0
	
	; OutputDebug, % "v_UndoTriggerstring:" . v_UndoTriggerstring . "|" . A_Space . "v_UndoHotstring:" . v_UndoHotstring . "|" . "`n"
	if (v_UndoTriggerstring)
	{	
		if (!(InStr(v_Options, "*")) and !(InStr(v_Options, "O")))
			Send, {BackSpace}
		if (v_UndoHotstring)
		{
			HowManySpecials := F_CountSpecialChar("{left}", v_UndoHotstring)	;counts special characters and filters them out of v_UndoHotstring
			if (HowManySpecials)
				Send, % "{right" . A_Space . HowManySpecials . "}"

			HowManySpecials := F_CountSpecialChar("{right}", v_UndoHotstring)	;counts special characters and filters them out of v_UndoHotstring
			if (HowManySpecials)
				Send, % "{left" . A_Space . HowManySpecials . "}"

			HowManyBackSpaces += F_CountSpecialChar("{enter}", 	v_UndoHotstring)	;counts special characters and filters them out of v_UndoHotstring
			 			   +  F_CountSpecialChar("{tab}", 		v_UndoHotstring)	;counts special characters and filters them out of v_UndoHotstring
						   +  F_CountSpecialChar("{space}", 	v_UndoHotstring)	;counts special characters and filters them out of v_UndoHotstring

			F_CountSpecialChar("{Shift}", v_UndoHotstring)	;counts special characters and filters them out of v_UndoHotstring
,			F_CountSpecialChar("{Ctrl}", 	v_UndoHotstring)	;counts special characters and filters them out of v_UndoHotstring
,			F_CountSpecialChar("{Alt}", 	v_UndoHotstring)	;counts special characters and filters them out of v_UndoHotstring
,			F_CountSpecialChar("{LWin}", 	v_UndoHotstring)	;counts special characters and filters them out of v_UndoHotstring
,			F_CountSpecialChar("{RWin}", 	v_UndoHotstring)	;counts special characters and filters them out of v_UndoHotstring

			if (F_CountSpecialChar("{Up}", 	v_UndoHotstring))
			or (F_CountSpecialChar("{Down}", 	v_UndoHotstring))
			or (F_CountSpecialChar("{Home}", 	v_UndoHotstring))
			or (F_CountSpecialChar("{End}", 	v_UndoHotstring))
			or (F_CountSpecialChar("{PgUp}", 	v_UndoHotstring))
			or (F_CountSpecialChar("{PgDown}", v_UndoHotstring))
			{
				MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["Your hotstring definition contain one of the following characters:"] . "`n`n"
					. TransA["{Up} or {Down} or {Home} or {End} or {PgUp} or {PgDown}"] . "`n`n"
					. TransA["Last hotstring undo function is currently unsuported for those characters, sorry."]
				return
			}

			if (InStr(v_UndoHotstring, "``r``n"))
			{
				v_UndoHotstring := StrReplace(v_UndoHotstring, "``r``n", "", HowManyBackSpaces2)
				HowManyBackSpaces += HowManyBackSpaces2 + 1
			}
			if (InStr(v_UndoHotstring, "``r"))
			{
				v_UndoHotstring := StrReplace(v_UndoHotstring, "``r", "", HowManyBackSpaces2)
				HowManyBackSpaces += HowManyBackSpaces2
			}
			if (InStr(v_UndoHotstring, "``n"))
			{
				v_UndoHotstring := StrReplace(v_UndoHotstring, "``n", "", HowManyBackSpaces2)
				HowManyBackSpaces += HowManyBackSpaces2
			}
			if (InStr(v_UndoHotstring, "``b"))
			{
				v_UndoHotstring := StrReplace(v_UndoHotstring, "``b", "", HowManyBackSpaces2)
				HowManyBackSpaces -= HowManyBackSpaces2
			}

			if (InStr(v_UndoHotstring, "``v"))
				v_UndoHotstring := StrReplace(v_UndoHotstring, "``v", "")

			if (InStr(v_UndoHotstring, "``a"))
				v_UndoHotstring := StrReplace(v_UndoHotstring, "``a", "")
			
			if (InStr(v_UndoHotstring, "``f"))
				v_UndoHotstring := StrReplace(v_UndoHotstring, "``f", "")

			if (InStr(v_UndoHotstring, "``t"))
			{
				v_UndoHotstring := StrReplace(v_UndoHotstring, "``t", "", HowManyBackSpaces2)
				HowManyBackSpaces += HowManyBackSpaces2
			}
			if (v_SendFun != "MCL") and (v_SendFun != "CL") and (v_SendFun != "SR")
			{
				v_UndoHotstring 	:= F_ReplaceAHKconstants(v_UndoHotstring)
			,	v_UndoHotstring 	:= F_PrepareUndo(v_UndoHotstring)
			,	v_UndoHotstring 	:= RegExReplace(v_UndoHotstring, "{U+.*}", " ")
			}
			HowManyBackSpaces 	+= StrLenUnicode(v_UndoHotstring)
			Send, % "{BackSpace " . HowManyBackSpaces . "}"
			Loop, Parse, v_UndoTriggerstring
				Switch A_LoopField
				{
					Case "^", "+", "!", "#", "{", "}":	SendRaw, 	% A_LoopField
					Case "l":						if A_LoopField is lower	; This is dirty trick to block Win + l behavior. Nothing else worked. `Switch` is not case sensitive, but if I turn on / off case sentitiveness temporarily it didn't work either. Hotkeys using the "reg" method are incapable of distinguishing physical and artificial input, so are not affected by SendLevel. However, hotkeys above level 0 always use the keyboard or mouse hook.
													Send, {U+006C}	; small latin letter 'l'
												else if A_LoopField is upper
													Send, {U+004C} ; capital latin letter 'L'
					Default:						Send, 		% A_LoopField
				}
		}
		v_UndoTriggerstring := ""
		F_UndoSignalling()
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_UndoSignalling()
{
	global	;assume-global mode
	if (ini_UHTtEn)
	{
		Gui, Tt_HWT: Hide	;Tooltip: Basic hotstring was triggered	;Tooltip: Basic hotstring was triggered
		if (ini_UHTP = 1)	;Undo Hotstring Tooltip Position
		{
			if (A_CaretX and A_CaretY)
			{
				Gui, Tt_ULH: Show, % "x" . A_CaretX + 20 . A_Space . "y" . A_CaretY - 20 . A_Space . "NoActivate"	;Undid the last hotstring
				if (ini_UHTD > 0)
					SetTimer, TurnOff_UHE, % "-" . ini_UHTD, 60 ;Priority = 60 to avoid conflicts with other threads 
			}
			else
			{
				MouseGetPos, v_MouseX, v_MouseY
				Gui, Tt_ULH: Show, % "x" . v_MouseX + 20 . A_Space . "y" . v_MouseY - 20 . A_Space . "NoActivate"	;Undid the last hotstring
				if (ini_UHTD > 0)
					SetTimer, TurnOff_UHE, % "-" . ini_UHTD, 60 ;Priority = 60 to avoid conflicts with other threads 
			}
		}
		if (ini_UHTP = 2)
		{
			MouseGetPos, v_MouseX, v_MouseY
			Gui, Tt_ULH: Show, % "x" . v_MouseX + 20 . A_Space . "y" . v_MouseY - 20 . A_Space . "NoActivate"	;Undid the last hotstring
			if (ini_UHTD > 0)
				SetTimer, TurnOff_UHE, % "-" . ini_UHTD, 60 ;Priority = 60 to avoid conflicts with other threads 
		}
	}
	
	if (ini_UHSEn)	;Basic Hotstring % TransA["Sound Enable"]
		SoundBeep, % ini_UHSF, % ini_UHSD
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
StrLenUnicode(data) ;https://www.autohotkey.com/boards/viewtopic.php?t=22036
{
	RegExReplace(data, "s).", "", i)
	return i
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EventSigOrdHotstring()
{
	global	;assume-global mode of operation
	local 	v_MouseX := 0, v_MouseY := 0

	if (ini_OHTtEn)	;Ordinary Hostring Tooltip Enable
	{
		if (ini_OHTP = 1)
		{
			if (A_CaretX and A_CaretY)
			{
				Gui, Tt_HWT: Show, % "x" . A_CaretX + 20 . A_Space . "y" . A_CaretY - 20 . A_Space . "NoActivate"	;Tooltip _ Hotstring Was Triggered
				if (ini_OHTD > 0)
					SetTimer, TurnOff_OHE, % "-" . ini_OHTD, 40 ;Priority = 40 to avoid conflicts with other threads 
			}
			else
			{
				MouseGetPos, v_MouseX, v_MouseY
				Gui, Tt_HWT: Show, % "x" . v_MouseX + 20 . A_Space . "y" . v_MouseY - 20 . A_Space . "NoActivate" 	;Tooltip _ Hotstring Was Triggered
				if (ini_OHTD > 0)
					SetTimer, TurnOff_OHE, % "-" . ini_OHTD, 40 ;Priority = 40 to avoid conflicts with other threads 
			}
		}
		if (ini_OHTP = 2)
		{
			MouseGetPos, v_MouseX, v_MouseY
			Gui, Tt_HWT: Show, % "x" . v_MouseX + 20 . A_Space . "y" . v_MouseY - 20 . A_Space . "NoActivate" 	;Tooltip _ Hotstring Was Triggered
			if (ini_OHTD > 0)
				SetTimer, TurnOff_OHE, % "-" . ini_OHTD, 40 ;Priority = 40 to avoid conflicts with other threads 
		}
	}
	
	if (ini_OHSEn)	;Basic Hotstring Sound Enable
		SoundBeep, % ini_OHSF, % ini_OHSD
	; OutputDebug, % A_ThisFunc . A_Space . "E" . "`n"
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_PTTT(string)	; Function_ Prepare Triggerstring Tips Tables
{
	global	;assume-global mode of operation
	local	HitCnt 			:= 0
		,	f_FirstPart		:= false
		,	LastChar			:= SubStr(string, 0)
		,	InStrLen			:= StrLen(string)
		,	f_EndCharDetected	:= false
		,	AllButFirstChar	:= SubStr(string, 2)

	; OutputDebug, % A_ThisFunc . A_Space . "string:" . string . "|" . A_Space . "QS:" . v_Qinput . "|" . A_Space . "LC:" . LastChar . "|" . A_Space . "ini_MNTT:" . ini_MNTT "`n"
	if (InStrLen > 1)
		f_EndCharDetected := F_CheckBeforeLastChar(string)

	if (StrLen(string) > ini_TASAC - 1)	;TASAC = TipsAreShownAfterNoOfCharacters
	{
		a_Tips 		:= []	;collect within global array a_Tips subset from full set a_Combined
		, a_TipsOpt	:= []	;collect withing global array a_TipsOpt subset from full set a_TriggerOptions; next it will be used to show triggering character in F_ShowTriggerstringTips2()
		, a_TipsEnDis	:= []
		, a_TipsHS	:= []	;HS = Hotstrings
		Loop, % a_Combined.MaxIndex()
		{
			; OutputDebug, % "v_InputString:" . v_InputString . A_Space . "a_Combined.MaxIndex():" . a_Combined.MaxIndex() . "`n"
			if (InStr(a_Combined[A_Index], string) = 1)	;This comparison cannot be case sensitive. This is the reason why triggerstring tips aren't shown for triggerstring definitions containing option "?"
			{
				; OutputDebug, % "a_Combined[A_Index]:" . a_Combined[A_Index] . "`n"
				Switch ini_TTCn
				{
					Case 1:	;only column 1: Triggerstring Tips
					     Loop, Parse, % a_Combined[A_Index], % c_TextDelimiter
					     	if (A_Index = 1)
					     		a_Tips.Push(A_LoopField)
					Case 2:	;2 columns: Triggerstring Tips + Triggerstring Trigger
					     Loop, Parse, % a_Combined[A_Index], % c_TextDelimiter
					     {
					     	if (A_Index = 1)
					     		a_Tips.Push(A_LoopField)
					     	if (A_Index = 2) 
					     		a_TipsOpt.Push(A_LoopField)
					     	if (A_Index = 3) 
					     		a_TipsEnDis.Push(A_LoopField)
					     }
					Case 3, 4:	;3 columns: Triggerstring Tips + Triggerstring Trigger + Triggerstring Hotstring
					     Loop, Parse, % a_Combined[A_Index], % c_TextDelimiter
					     {
					     	if (A_Index = 1)
					     		a_Tips.Push(A_LoopField)
					     	if (A_Index = 2) 
					     		a_TipsOpt.Push(A_LoopField)
					     	if (A_Index = 3) 
					     		a_TipsEnDis.Push(A_LoopField)
					     	if (A_Index = 4)
					     		a_TipsHS.Push(A_LoopField)
					     }
				}
				HitCnt++
				if (HitCnt = ini_MNTT)	; MNTT = Maximum Number of Triggerstring Tips
					Break
				f_FirstPart := true	;if string was not found among available strings within a_Combined tables, then try to search for a substring related to question mark triggerstrings (Q)
			}
		}

		; OutputDebug, % A_ThisFunc . A_Space . "f_FirstPart:" . f_FirstPart . "|" . A_Space . "f_EndCharDetected:" . f_EndCharDetected . "`n"
		if (!f_FirstPart) and (InStrLen > 1) and (f_EndCharDetected)
		{
			F_PTTT(v_InputString := LastChar)
			return
		}	
		if (!f_FirstPart) and (InStrLen > 1)
		{
			; OutputDebug, % A_ThisFunc . A_Space . "InStrLen:" . InStrLen . "|" . A_Space . "f_FirstPart:" . f_FirstPart . A_Space . "v_Qinput:" . LastChar . "|" . "`n"
			F_PTTTQ(v_Qinput := AllButFirstChar)
		}
	}
	; OutputDebug, % A_ThisFunc . A_Space . "E" . "`n"
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_PTTTQ(string) ;Function_ Prepare Triggerstring Tips Tables Question mark (related to ? option)
{
	global	;assume-global mode of operation
	local	HitCnt 			:= 0
		,	QuestionMarkPos	:= 0
		,	NoOccurrence		:= 2
		,	SecSeparatorPos	:= 0
		,	Qlength			:= StrLen(string)

	; OutputDebug, % A_ThisFunc . A_Space . "B" . A_Space . "string:" . string . "`n"
	if (StrLen(string) > ini_TASAC - 1)	;TASAC = TipsAreShownAfterNoOfCharacters
	{
		a_Tips 		:= []	;collect within global array a_Tips subset from full set a_Combined
		, a_TipsOpt	:= []	;collect withing global array a_TipsOpt subset from full set a_TriggerOptions; next it will be used to show triggering character in F_ShowTriggerstringTips2()
		, a_TipsEnDis	:= []
		, a_TipsHS	:= []	;HS = Hotstrings

		Loop, % a_Combined.MaxIndex()
		{
			QuestionMarkPos 	:= InStr(a_Combined[A_Index], "?")
		,	SecSeparatorPos	:= InStr(a_Combined[A_Index], c_TextDelimiter, false, 1, NoOccurrence)
			if (QuestionMarkPos) and (QuestionMarkPos < SecSeparatorPos) and (InStr(a_Combined[A_Index], string) = 1)
			{
				; OutputDebug, % "a_Combined[A_Index]:" . a_Combined[A_Index] . "`n"
				Switch ini_TTCn
				{
					Case 1:	;only column 1: Triggerstring Tips
					     Loop, Parse, % a_Combined[A_Index], % c_TextDelimiter
					     	if (A_Index = 1)
					     		a_Tips.Push(A_LoopField)
					Case 2:	;2 columns: Triggerstring Tips + Triggerstring Trigger
					     Loop, Parse, % a_Combined[A_Index], % c_TextDelimiter
					     {
					     	if (A_Index = 1)
					     		a_Tips.Push(A_LoopField)
					     	if (A_Index = 2) 
					     		a_TipsOpt.Push(A_LoopField)
					     	if (A_Index = 3) 
					     		a_TipsEnDis.Push(A_LoopField)
					     }
					Case 3, 4:	;3 columns: Triggerstring Tips + Triggerstring Trigger + Triggerstring Hotstring
					     Loop, Parse, % a_Combined[A_Index], % c_TextDelimiter
					     {
					     	if (A_Index = 1)
					     		a_Tips.Push(A_LoopField)
					     	if (A_Index = 2) 
					     		a_TipsOpt.Push(A_LoopField)
					     	if (A_Index = 3) 
					     		a_TipsEnDis.Push(A_LoopField)
					     	if (A_Index = 4)
					     		a_TipsHS.Push(A_LoopField)
					     }
				}
				HitCnt++
				if (HitCnt = ini_MNTT)	; MNTT = Maximum Number of Triggerstring Tips
					Break
			}
		}
	}
	if (a_Tips.Count() = 0) and (Qlength > 1)
	{
		; OutputDebug, % A_ThisFunc . A_Space . "1 branch" . "`n"
		string := SubStr(string, 2)	;all but first
		F_PTTTQ(v_Qinput := string)	;recursive call
	}
	if (a_Tips.Count() = 0) and (Qlength = 1)
	{
		v_Qinput := ""
		; OutputDebug, % A_ThisFunc . A_Space . "2 branch" . "`n"
	}
	; OutputDebug, % A_ThisFunc . A_Space . "E" . A_Space . "string:" . string . "`n"
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_LoadSignalingParams()
{
	global	;assume-global mode
	ini_OHTtEn := 1, 	ini_OHTD := 0, 	ini_OHTP := 1, 	ini_OHSEn := 1, 	ini_OHSF := 500, 	ini_OHSD := 250, 	ini_MHMP := 1, 	ini_MHSEn := 1
	,ini_MHSF := 500, 	ini_MHSD := 250, 	ini_UHTtEn := 1, 	ini_UHTD := 0, 	ini_UHTP := 1, 	ini_UHSEn := 1, 	ini_UHSF := 500, 	ini_UHSD := 250
	,ini_TTTP := 1, 	ini_TTTtEn := 1, 	ini_TTTD := 0, 	ini_TipsSortAlphabetically := 1, 	ini_TipsSortByLength := 1, 	ini_TASAC := 1,	ini_MNTT := 5
	,ini_ATEn := 0
	
	IniRead, ini_OHTtEn, 	% ini_HADConfig, Event_BasicHotstring, 	OHTtEn, 	% A_Space
	if (ini_OHTtEn = "")
	{
		ini_OHTtEn := 1
		IniWrite, % ini_OHTtEn, % ini_HADConfig, Event_BasicHotstring,	OHTtEn
	}
	IniRead, ini_OHTD,		% ini_HADConfig, Event_BasicHotstring,		OHTD,	% A_Space
	if (ini_OHTD = "")
	{
		ini_OHTD := 0
		IniWrite, % ini_OHTD, % ini_HADConfig, Event_BasicHotstring,	OHTD
	}
	IniRead, ini_OHTP,		% ini_HADConfig, Event_BasicHotstring,		OHTP,	% A_Space
	if (ini_OHTP = "")
	{
		ini_OHTP := 1
		IniWrite, % ini_OHTP, % ini_HADConfig, Event_BasicHotstring,	OHTP
	}
	IniRead, ini_OHSEn, 	% ini_HADConfig, Event_BasicHotstring,		OHSEn, 	% A_Space
	if (ini_OHSEn = "")
	{
		ini_OHSEn := 1
		IniWrite, % ini_OHSEn, % ini_HADConfig, Event_BasicHotstring,	OHSEn
	}
	IniRead, ini_OHSF,		% ini_HADConfig, Event_BasicHotstring,		OHSF,	% A_Space
	if (ini_OHSF = "")
	{
		ini_OHSF := 500
		IniWrite, % ini_OHSF, % ini_HADConfig, Event_BasicHotstring,	OHSF
	}
	IniRead, ini_OHSD,		% ini_HADConfig, Event_BasicHotstring,		OHSD,	% A_Space
	if (ini_OHSD = "")
	{
		ini_OHSD := 250
		IniWrite, % ini_OHSD, % ini_HADConfig, Event_BasicHotstring,	OHSD
	}
	IniRead, ini_MHMP,		% ini_HADConfig, Event_MenuHotstring,		MHMP,	% A_Space
	if (ini_MHMP = "")
	{
		ini_MHMP := 1
		IniWrite, % ini_MHMP, % ini_HADConfig, Event_MenuHotstring,	MHMP
	}
	IniRead, ini_MHSEn,		% ini_HADConfig, Event_MenuHotstring,		MHSEn,	% A_Space
	if (ini_MHSEn = "")
	{
		ini_MHSEn := 1
		IniWrite, % ini_MHSEn, % ini_HADConfig, Event_MenuHotstring,	MHSEn
	}
	IniRead, ini_MHSF,		% ini_HADConfig, Event_MenuHotstring,		MHSF,	% A_Space
	if (ini_MHSF = "")
	{
		ini_MHSF := 500
		IniWrite, % ini_MHSF, % ini_HADConfig, Event_MenuHotstring,	MHSF
	}
	IniRead, ini_MHSD,		% ini_HADConfig, Event_MenuHotstring,		MHSD,	% A_Space
	if (ini_MHSD = "")
	{
		ini_MHSD := 250
		IniWrite, % ini_MHSD, % ini_HADConfig, Event_MenuHotstring,	MHSD
	}
	IniRead, ini_UHTtEn, 	% ini_HADConfig, Event_UndoHotstring, 		UHTtEn, 	% A_Space
	if (ini_UHTtEn = "")
	{
		ini_UHTtEn := 1
		IniWrite, % ini_UHTtEn, % ini_HADConfig, Event_UndoHotstring, 	UHTtEn
	}
	IniRead, ini_UHTD,		% ini_HADConfig, Event_UndoHotstring,		UHTD,	% A_Space
	if (ini_UHTD = "")
	{
		ini_UHTD := 0
		IniWrite, % ini_UHTD, % ini_HADConfig, Event_UndoHotstring,	UHTD
	}
	IniRead, ini_UHTP,		% ini_HADConfig, Event_UndoHotstring,		UHTP,	% A_Space
	if (ini_UHTP = "")
	{
		ini_UHTP := 1
		IniWrite, % ini_UHTP, % ini_HADConfig, Event_UndoHotstring,	UHTP
	}
	IniRead, ini_UHSEn,		% ini_HADConfig, Event_UndoHotstring,		UHSEn,	% A_Space
	if (ini_UHSEn = "")
	{
		ini_UHSEn := 1
		IniWrite, % ini_UHSEn, % ini_HADConfig, Event_UndoHotstring,	UHSEn
	}
	IniRead, ini_UHSF,		% ini_HADConfig, Event_UndoHotstring,		UHSF,	% A_Space
	if (ini_UHSF = "")
	{
		ini_UHSF := 500
		IniWrite, % ini_UHSF, % ini_HADConfig, Event_UndoHotstring,	UHSF
	}
	IniRead, ini_UHSD,		% ini_HADConfig, Event_UndoHotstring,		UHSD,	% A_Space
	if (ini_UHSD = "")
	{
		ini_UHSD := 250
		IniWrite, % ini_UHSD, % ini_HADConfig, Event_UndoHotstring,	UHSD
	}
	IniRead, ini_TTTP,		% ini_HADConfig, Event_TriggerstringTips,	TTTP,	% A_Space
	if (ini_TTTP = "")
	{
		ini_TTTP := 1
		IniWrite, % ini_TTTP, % ini_HADConfig, Event_TriggerstringTips,	TTTP
	}
	IniRead, ini_TTTtEn, 	% ini_HADConfig, Event_TriggerstringTips,	TTTtEn, 	% A_Space
	if (ini_TTTtEn = "")
	{
		ini_TTTtEn := 1
		IniWrite, % ini_TTTtEn, % ini_HADConfig, Event_TriggerstringTips,	TTTtEn
	}
	IniRead, ini_TTTD,		% ini_HADConfig, Event_TriggerstringTips,	TTTD,	% A_Space
	if (ini_TTTD = "")
	{
		ini_TTTD := 0
		IniWrite, % ini_TTTD, % ini_HADConfig, Event_TriggerstringTips,	TTTD
	}
	IniRead, ini_TipsSortAlphabetically, % ini_HADConfig, Event_TriggerstringTips, TipsSortAlphabetically, % A_Space
	if (ini_TipsSortAlphabetically = "")
	{
		ini_TipsSortAlphabetically := 1
		IniWrite, % ini_TipsSortAlphabetically, % ini_HADConfig, Event_TriggerstringTips, TipsSortAlphabetically
	}
	IniRead, ini_TipsSortByLength, % ini_HADConfig, Event_TriggerstringTips, TipsSortByLength, % A_Space
	if (ini_TipsSortByLength = "")
	{
		ini_TipsSortByLength := 1
		IniWrite, % ini_TipsSortByLength, % ini_HADConfig, Event_TriggerstringTips, TipsSortByLength
	}
	IniRead, ini_TASAC, 	% ini_HADConfig, Event_TriggerstringTips, 	TipsAreShownAfterNoOfCharacters, % A_Space
	if (ini_TASAC = "")
	{
		ini_TASAC := 1
		Iniwrite, % ini_TASAC, % ini_HADConfig, Event_TriggerstringTips, 	TipsAreShownAfterNoOfCharacters
	}
	IniRead, ini_MNTT,		% ini_HADConfig, Event_TriggerstringTips,	MNTT,	% A_Space
	if (ini_MNTT = "")
	{
		ini_MNTT := 5
		IniWrite, % ini_MNTT, % ini_HADConfig, Event_TriggerstringTips,	MNTT
	}
	IniRead, ini_TTCn,		% ini_HADConfig, Event_TriggerstringTips, TTCn,		% A_Space
	if (ini_TTCn = "")
	{
		ini_TTCn := 2
		IniWrite, % ini_TTCn, % ini_HADConfig, Event_TriggerstringTips,	TTCn
	}
	IniRead, ini_ATEn,		% ini_HADConfig, Event_ActiveTriggerstringTips, ATEn, % A_Space
	if (ini_ATEn = "")
	{
		ini_ATEn := 0
		IniWrite, % ini_ATEn, % ini_HADConfig, Event_ActiveTriggerstringTips, ATEn
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_ToggleEndChars()
{	
	global	;assume-global mode
	local	key := "", val := ""
	static OneTimeMemory := true, NextName := []
	
	if (OneTimeMemory)
	{
		for key, val in a_HotstringEndChars
		{
			NextName[A_Index] := key
			if (a_HotstringEndChars[key])
				Menu, SubmenuEndChars, Check, % TransA[key]
			else
				Menu, SubmenuEndChars, UnCheck, % TransA[key]
		}
		OneTimeMemory := false
	}
	else
	{
		if (a_HotstringEndChars[A_ThisMenuItem])
		{
			Menu, SubmenuEndChars, UnCheck, % A_ThisMenuitem
			a_HotstringEndChars[A_ThisMenuItem] := false
			IniWrite, % false, % ini_HADConfig, EndChars, % NextName[A_ThisMenuItemPos]	
		}
		else
		{
			Menu, SubmenuEndChars, Check, % A_ThisMenuitem
			a_HotstringEndChars[A_ThisMenuItem] := true
			IniWrite, % true, % ini_HADConfig, EndChars, % NextName[A_ThisMenuItemPos]	
		}
		F_LoadEndChars()
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_AddToAutostart()
{
	global	;assume-global mode
	local 	Target 		:= A_ScriptFullPath
	,		LinkFile_DM	:= A_Startup . "\" . SubStr(A_ScriptName, 1, -4) . "_DM" . "." . "lnk"
	,		LinkFile_SM	:= A_Startup . "\" . SubStr(A_ScriptName, 1, -4) . "_SM" . "." . "lnk"
	,		WorkingDir 	:= A_ScriptDir
	,		Args_DM 		:= ""
	,		Args_SM		:= "l"
	,		Description 	:= TransA["Facilitate working with AutoHotkey triggerstring and hotstring concept, with GUI and libraries"] . "."
	,		IconFile 		:= AppIcon
	
	Switch A_ThisMenuItem
	{
		Case TransA["Default mode"]:
			Try
			{
				if (A_IsCompiled)
					FileCreateShortcut, % Target, % LinkFile_SM, % WorkingDir, % Args_SM, % Description, A_ScriptFullPath, h, , 7 ;h = shortcut: Ctrl + Shift + h, 7 = Minimized
				else	
					FileCreateShortcut, % Target, % LinkFile_DM, % WorkingDir, % Args_DM, % Description, % IconFile, h, , 7 ;h = shortcut: Ctrl + Shift + h, 7 = Minimized
			}
			Catch
			{
				MsgBox, 16, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["Error"], % A_ThisFunc . A_Space . TransA["Something went wrong with link file (.lnk) creation"] . ":" 
					. A_Space . ErrorLevel
			}
			F_WhichGui()
			if (!ErrorLevel)
				MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["Link file (.lnk) was created in AutoStart folder"] . ":" . "`n`n"
					. A_Startup . "\" . SubStr(A_ScriptName, 1, -4) . "_DM" . "." . "lnk" . "," . A_Space . TransA["Default mode"]
		Case TransA["Silent mode"]:
			Try
			{
				if (A_IsCompiled)
					FileCreateShortcut, % Target, % LinkFile_SM, % WorkingDir, % Args_SM, % Description, A_ScriptFullPath, h, , 7 ;h = shortcut: Ctrl + Shift + h, 7 = Minimized
				else	
					FileCreateShortcut, % Target, % LinkFile_SM, % WorkingDir, % Args_SM, % Description, % IconFile, h, , 7 ;h = shortcut: Ctrl + Shift + h, 7 = Minimized
			}
			Catch
			{
				MsgBox, 16, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["Error"], % A_ThisFunc . A_Space . TransA["Something went wrong with link file (.lnk) creation"] . ":" 
					. A_Space . ErrorLevel
			}
			F_WhichGui()
			if (!ErrorLevel)
				MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["Link file (.lnk) was created in AutoStart folder"] . ":" . "`n`n"
					. A_Startup . "\" . SubStr(A_ScriptName, 1, -4) . "_SM" . "." . "lnk" . "," . A_Space . TransA["Silent mode"]
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
F_CreateMenu_SizeOfMargin()
{
	global	;assume-global mode
	local	key := 0, value := 0
	
	for key, value in SizeOfMargin
		Menu, SizeOfMX, Add, % SizeOfMargin[key], F_SizeOfMargin
	for key, value in SizeOfMargin
		Menu, SizeOfMY, Add, % SizeOfMargin[key], F_SizeOfMargin
	
	Menu, SizeOfMX,	Check,	% c_xmarg
	Menu, SizeOfMY,	Check,	% c_ymarg
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_AddHotstring()
{
	global ;v_EnDis ;assume-global mode of operation
	local 	vHotstring := "", NewOptions := "", OldOptions := "", f_ChangeExistingDef := false
 		,	SendFun := "", Overwrite := "",	key := 0, value := "", WhichGuiEnable := "", TheWholeFile := "", LibraryHeader := ""
		,	HC2SubstOpt := ""	;hotstring (definition) C2 substitute options (string); variable to keep that user wants to set up C2 option for order of letters; actually what is set for Hotstring function is "" option instead of "C2" option

	;1. Read all inputs.
	WhichGuiEnable := F_WhichGui()
	if (F_ReadUserInputs(vHotstring, NewOptions, SendFun))	;return true (1) in case of any problem. 
		return
	
	;2. Create or modify (triggerstring, hotstring) definition according to inputs. 
	Gui, HS3: Default			;All of the ListView function operate upon the current default GUI window.
	for key, value in a_Triggerstring
	{
		if (a_Triggerstring[key] == v_Triggerstring) and (a_Library[key] = SubStr(v_SelectHotstringLibrary, 1, -4))	;case sensitive string comparison!
		{
			OldOptions 		:= a_TriggerOptions[key]
		,	f_ChangeExistingDef := true
			break
		}
		if (a_Triggerstring[key] = v_Triggerstring) and (a_Library[key] = SubStr(v_SelectHotstringLibrary, 1, -4))	;case insensitive string comparison!
		{
			OldOptions 		:= a_TriggerOptions[key]
			if (InStr(OldOptions, "C", false)) and (InStr(NewOptions, "C", false))	;if old definitions had C option set and new definition has C option set and they are not identical.
			{
				f_ChangeExistingDef := false
				break
			}
			else
			{
				MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"]
					, % TransA["In order to add similar definition to existing one use C option for both definitions (old and new) and change the case of triggerstrings."]
				return
			}
		}
		if (a_Triggerstring[key] = v_Triggerstring) and (a_Library[key] != SubStr(v_SelectHotstringLibrary, 1, -4))	;case insensitive string comparison!
		{
			f_ChangeExistingDef := false
			MsgBox, 68, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"]
				, % TransA["The triggerstring"] . A_Space . """" .  v_Triggerstring . """" . A_Space .  TransA["already exists in another library"] . ":" . A_Space . a_Library[key] . "." . "csv" . "`n`n" 
				. TransA["Do you want to proceed?"] . "`n`n" . TransA["If you answer ""No"" edition of the current definition will be interrupted."]
				. "`n" . TransA["If you answer ""Yes"" definition existing in another library will not be changed."]
			IfMsgBox, No
			{
				Switch WhichGuiEnable	;Enable all GuiControls for time of adding / editing of d(t, o, h)	
				{
					Case "HS3":
						GuiControl, +Redraw, % IdListView1 ; -Readraw: This option serves as a hint to the control that allows it to allocate memory only once rather than each time a row is added, which greatly improves row-adding performance (it may also improve sorting performance). 
						F_GuiHS3_EnDis("Enable")
					Case "HS4": 	F_GuiHS4_EnDis("Enable")
				}
				return
			}
			IfMsgBox, Yes
				break
		}
	}
	
	; 3. Modify existing definition
	if (f_ChangeExistingDef)	;modify existing definition
	{
		if (NewOptions = OldOptions) and (vHotstring == a_Hotstring[key]) and (SendFun = a_OutputFunction[key]) and (v_Comment == a_Comment[key])
		{
			MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"]
				, % TransA["New definition is identical with existing one. Please try again."]
			return
		}
		Switch WhichGuiEnable	;Disable all GuiControls for time of adding / editing of d(t, o, h)	
		{
			Case "HS3":	F_GuiHS3_EnDis("Disable")
			Case "HS4": 	F_GuiHS4_EnDis("Disable")
		}

		Overwrite := F_ChangeExistingDef(OldOptions, NewOptions, a_Triggerstring[key], a_Library[key], SendFun, vHotstring, a_EnableDisable[key])
		if (Overwrite = "Yes")
		{
			F_ChangeDefInArrays(key, NewOptions, SendFun, vHotstring, v_Comment)
			F_ModifyLV(v_Triggerstring, NewOptions, SendFun, vHotstring, v_Comment)

			;7. Delete library file.
			FileRead, TheWholeFile, % ini_HADL . "\" . v_SelectHotstringLibrary
			LibraryHeader 	:= F_ExtractHeader(TheWholeFile)
			if (LibraryHeader)
				LibraryHeader 	:= "/*`n" . LibraryHeader . "`n*/`n`n"
			,	TheWholeFile	:= ""
			FileDelete, % ini_HADL . "\" . v_SelectHotstringLibrary

			;8. Save List View into the library file.
			if (LibraryHeader)
				FileAppend, % LibraryHeader, % ini_HADL . "\" . v_SelectHotstringLibrary, UTF-8
			F_SaveLVintoLibFile()
			Switch WhichGuiEnable	;Enable all GuiControls for time of adding / editing of d(t, o, h)
			{
				Case "HS3":	F_GuiHS3_EnDis("Enable")	
				Case "HS4": 	F_GuiHS4_EnDis("Enable")
			}
			MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . A_Space . TransA["information"], % TransA["New settings are now applied."], 10	;dissapears after 10 s
			return
		}
		if (Overwrite = "No")
		{
			Switch WhichGuiEnable	;Enable all GuiControls for time of adding / editing of d(t, o, h)	
			{
				Case "HS3":
                         GuiControl, +Redraw, % IdListView1 ; -Readraw: This option serves as a hint to the control that allows it to allocate memory only once rather than each time a row is added, which greatly improves row-adding performance (it may also improve sorting performance). 
                         F_GuiHS3_EnDis("Enable")	
				Case "HS4": 	F_GuiHS4_EnDis("Enable")
			}
			return
		}
	}

	; 4. Create new definition
	Switch WhichGuiEnable	;Disable all GuiControls for time of adding / editing of d(t, o, h)	
	{
		Case "HS3":	F_GuiHS3_EnDis("Disable")
		Case "HS4": 	F_GuiHS4_EnDis("Disable")
	}
	;OutputDebug, % "NewOptions:" . A_Space . NewOptions . A_Tab . "OldOptions:" . A_Space . OldOptions . A_Tab . "v_Triggerstring:" . A_Space . v_Triggerstring
	if (InStr(NewOptions, "C2"))	;actually "C2" isn't allowed / existing argument of "Hotstring" function can understand so just before this function is called the "NewOptions" string is checked if there is "C2" available. If it does, "C2" is replaced with "".
		HC2SubstOpt := StrReplace(NewOptions, "C2", "")
	else
		HC2SubstOpt := NewOptions
	if (InStr(NewOptions, "O"))
	{
		if (SendFun = "SI") or (SendFun = "SE") or (SendFun = "SP") or (SendFun = "SR") or (SendFun = "CL") or (SendFun = "S1") or (SendFun = "S2")
		{
			Try
				Hotstring(":" . HC2SubstOpt . ":" . F_ConvertEscapeSequences(v_Triggerstring), func("F_SimpleOutput").bind(vHotstring, true, SendFun), true)
			Catch
				MsgBox, 16, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["Error"], % TransA["Function"] . ":" . A_Space . A_ThisFunc . "`n" 
					. TransA["Something went wrong with (triggerstring, hotstring) creation"] . ":" . "`n`n"
					. "Hotstring(:" . NewOptions . ":" . vTriggerstring . "," . A_Space . "func(""SimpleOutput"").bind(" . vHotstring . "," . A_Space . true . "," . A_Space . SendFun . ")," . A_Space . v_EnDis . ")"
					. "`n`n" . TransA["Library name:"] . A_Tab . v_SelectHotstringLibrary
		}
;#c/* commercial only beginning		
;#c*/ commercial only end		
	}
	else
	{
		if (SendFun = "SI") or (SendFun = "SE") or (SendFun = "SP") or (SendFun = "SR") or (SendFun = "CL") or (SendFun = "S1") or (SendFun = "S2")
		{
			Try
				Hotstring(":" . HC2SubstOpt . ":" . F_ConvertEscapeSequences(v_Triggerstring), func("F_SimpleOutput").bind(vHotstring, false, SendFun), true)
			Catch
				MsgBox, 16, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["Error"], % TransA["Function"] . ":" . A_Space . A_ThisFunc . "`n" 
					. TransA["Something went wrong with (triggerstring, hotstring) creation"] . ":" . "`n`n"
					. "Hotstring(:" . NewOptions . ":" . v_Triggerstring . "," . A_Space . "func(""F_SimpleOutput"").bind(" . vHotstring . "," . A_Space . false . "," . A_Space . SendFun . ")," . A_Space . true . ")"
					. "`n`n" . TransA["Library name:"] . A_Tab . v_SelectHotstringLibrary
		}
;#c/* commercial only beginning		
;#c*/ commercial only end		
	}
	; 5. Update global arrays
	F_UpdateGlobalArrays(NewOptions, SendFun, "En", vHotstring)

	;6. Update and sort List View. ;future: gui parameter for sorting
	LV_Add("Select",  "En", v_Triggerstring, NewOptions, SendFun, vHotstring, v_Comment)
	LV_ModifyCol(2, "Sort")
	F_LV1_CopyContentToHS3()

	;7. Delete library file. 
	FileRead, TheWholeFile, % ini_HADL . "\" . v_SelectHotstringLibrary
	LibraryHeader	:= F_ExtractHeader(TheWholeFile)
	if (LibraryHeader)
		LibraryHeader 	:= "/*`n" . LibraryHeader . "`n*/`n`n"
,		TheWholeFile	:= ""	

	FileDelete, % ini_HADL . "\" . v_SelectHotstringLibrary

	;8. Save List View into the library file.
	if (LibraryHeader)
		FileAppend, % LibraryHeader, % ini_HADL . "\" . v_SelectHotstringLibrary, UTF-8
	F_SaveLVintoLibFile()

	;9. Increment library counter.
	UpdateLibraryCounter(++v_LibHotstringCnt, ++v_TotalHotstringCnt)
	Switch WhichGuiEnable	;Enable all GuiControls for time of adding / editing of d(t, o, h)	
	{
		Case "HS3":	F_GuiHS3_EnDis("Enable")
		Case "HS4": 	F_GuiHS4_EnDis("Enable")
	}
	MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["Hotstring added to the file"] . A_Space . v_SelectHotstringLibrary . "!", 10 ;this line should be the very last and user confirmation shouldn't be required (10 s, last parameter)
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
UpdateLibraryCounter(v_LibHotstringCnt, v_TotalHotstringCnt)
{
	global	;assume-global mode of operation
	GuiControl, , % IdText12,  % Format("{:11}", v_LibHotstringCnt . " / " . v_TotalHotstringCnt) ;Text: Puts new contents into the control.
	GuiControl, , % IdText12b, % Format("{:11}", v_LibHotstringCnt . " / " . v_TotalHotstringCnt) ;Text: Puts new contents into the control.
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_SaveLVintoLibFile()
{
	global	;assume-global mode of operation

	FileAppend, % F_ConvertListViewIntoTxt(), % ini_HADL . "\" . v_SelectHotstringLibrary, UTF-8
	GuiControl, +Redraw, % IdListView1 ;Afterward, use GuiControl, +Redraw to re-enable redrawing (which also repaints the control).
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_UpdateGlobalArrays(NewOptions, SendFunFileFormat, EnDis, TextInsert)
{
	global	;assume-global mode of operation
	local	temp := ""
	a_Library			.Push(SubStr(v_SelectHotstringLibrary, 1, -4))
	a_Triggerstring	.Push(v_Triggerstring)
	a_TriggerOptions	.Push(NewOptions)
	a_OutputFunction	.Push(SendFunFileFormat)
	a_EnableDisable	.Push(EnDis)
	a_Hotstring		.Push(TextInsert)
	a_Comment			.Push(v_Comment)
	a_Combined		.Push(v_Triggerstring . c_TextDelimiter . NewOptions . c_TextDelimiter . EnDis . c_TextDelimiter . TextInsert)
	F_Sort_a_Triggers(a_Combined, ini_TipsSortAlphabetically, ini_TipsSortByLength)
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_ChangeDefInArrays(key, NewOptions, SendFun, TextInsert, v_Comment)
{
	global	;assume-global mode of operation
	local	index := 0

	a_Triggerstring[key] 	:= v_Triggerstring
, 	a_TriggerOptions[key] 	:= NewOptions
, 	a_OutputFunction[key] 	:= SendFun
, 	a_Hotstring[key] 		:= TextInsert
, 	a_Comment[key] 		:= v_Comment
	for index in a_Combined	;recreate array a_Combined
		a_Combined[index] := a_Triggerstring[index] . c_TextDelimiter . a_TriggerOptions[index] . c_TextDelimiter . a_EnableDisable[index] . c_TextDelimiter . a_Hotstring[index]
	F_Sort_a_Triggers(a_Combined, ini_TipsSortAlphabetically, ini_TipsSortByLength)	
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_ModifyLV(v_Triggerstring, NewOptions, SendFun, TextInsert, v_Comment)
{
	global	;assume-global mode of operation
	local	Triggerstring := ""
	
	GuiControl, +Redraw, % IdListView1 ; -Readraw: This option serves as a hint to the control that allows it to allocate memory only once rather than each time a row is added, which greatly improves row-adding performance (it may also improve sorting performance). 
	Loop, % LV_GetCount()
	{
		LV_GetText(Triggerstring, A_Index, 2)
		if (Triggerstring = v_Triggerstring)	;non-case sensitive comparison
		{
			LV_Modify(A_Index, "Col2", v_Triggerstring, NewOptions, SendFun, TextInsert, v_Comment)	;do not affect the first column (EnDis)
			Break
		}
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_PictureShow(PHotstring, Oflag, SendFun)
{
;#c/* commercial only beginning
;#c*/ commercial only end
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_RunApplication(PHotstring, Oflag, SendFun)
{
;#c/* commercial only beginning
;#c*/ commercial only end
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_ChangeExistingDef(OldOptions, NewOptions, FoundTriggerstring, Library, SendFun, TextInsert, OldEnDis)	;FoundTriggerstring = a_Triggerstring[key]; Library = a_Library[key]
{
	global	;assume-global mode of operation
	local	OnOffToggle := false
		,	HC2SubstOpt := ""	;hotstring (definition) C2 substitute options (string); variable to keep that user wants to set up C2 option for order of letters; actually what is set for Hotstring function is "" option instead of "C2" option

	MsgBox, 68, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"]
		, % TransA["The triggerstring"] . A_Space . """" .  FoundTriggerstring . """" . A_Space .  TransA["exists in the currently selected library"] . ":" . A_Space . Library 
		. ".csv" . "." . "`n`n" . TransA["Do you want to proceed?"]	. "`n`n" . TransA["If you answer ""Yes"" it will be overwritten with chosen settings."]
	IfMsgBox, No
		return, "No"

	IfMsgBox, Yes
	{
		FoundTriggerstring := F_ConvertEscapeSequences(FoundTriggerstring)
		if (OldEnDis = "Dis")	;if old definition is disabled, do not try to change Hotstring definition. Change only definition parameters.
			return, "Yes"
		if (InStr(OldOptions, "*") and !InStr(NewOptions,"*"))
			OldOptions := StrReplace(OldOptions, "*", "*0")
		if (InStr(OldOptions, "B0") and !InStr(NewOptions, "B0"))
			NewOptions := StrReplace(OldOptions, "B0", "B")
		if (InStr(OldOptions, "Z") and !InStr(NewOptions, "Z"))
			NewOptions := StrReplace(OldOptions, "Z", "Z0")
		if (InStr(OldOptions, "C2")) 	;actually "C2" isn't allowed / existing argument of "Hotstring" function can understand so just before this function is called the "NewOptions" string is checked if there is "C2" available. If it does, "C2" is replaced with "".
			OldOptions := StrReplace(OldOptions, "C2", "")

		;turn off existing hotstring
		Try
			Hotstring(":" . OldOptions . ":" . F_ConvertEscapeSequences(FoundTriggerstring), , "Off")
		Catch
			MsgBox, 16, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["Error"], % TransA["Function"] . ":" . A_Space . A_ThisFunc 
				. "`n" . TransA["Something went wrong with (triggerstring, hotstring) creation"] . ":" . "`n`n"
				. "Hotstring(:" . OldOptions . ":" . FoundTriggerstring . "," . A_Space . "Off" . ")"
				. "`n`n" . TransA["Library name:"] . A_Tab . Library

		Switch OldEnDis
		{
			Case "En":	OnOffToggle := "On"
			Case "Dis":	OnOffToggle := "Off"
		}

		if (InStr(NewOptions, "C2"))	;actually "C2" isn't allowed / existing argument of "Hotstring" function can understand so just before this function is called the "NewOptions" string is checked if there is "C2" available. If it does, "C2" is replaced with "".
			HC2SubstOpt := StrReplace(NewOptions, "C2", "")
		else
			HC2SubstOpt := NewOptions
	
		if (InStr(NewOptions, "O"))	;Add new hotstring which replaces the old one
		{
			if (SendFun = "SI") or (SendFun = "SE") or (SendFun = "SP") or (SendFun = "SR") or (SendFun = "CL") or (SendFun = "S1") or (SendFun = "S2")
			{
				Try
					Hotstring(":" . HC2SubstOpt . ":" . F_ConvertEscapeSequences(FoundTriggerstring), func("F_SimpleOutput").bind(TextInsert, true, SendFun), OnOffToggle)
				Catch
					MsgBox, 16, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["Error"], % TransA["Function"] . ":" . A_Space . A_ThisFunc 
						. "`n" . TransA["Something went wrong with (triggerstring, hotstring) creation"] . ":" . "`n`n"
						. "Hotstring(:" . NewOptions . ":" . FoundTriggerstring . "," . "func(""F_SimpleOutput"").bind(" . TextInsert . "," . A_Space . Oflag . "," . A_Space . SendFun . ")," . A_Space . OnOffToggle . ")"
						. "`n`n" . TransA["Library name:"] . A_Tab .  Library
			}
;#c/* commercial only beginning			
;#c*/ commercial only end			
		}
		else
		{
			if (SendFun = "SI") or (SendFun = "SE") or (SendFun = "SP") or (SendFun = "SR") or (SendFun = "CL") or (SendFun = "S1") or (SendFun = "S2")
			{
				Try
					Hotstring(":" . HC2SubstOpt . ":" . F_ConvertEscapeSequences(FoundTriggerstring), func("F_SimpleOutput").bind(TextInsert, false, SendFun), OnOffToggle)
				Catch
					MsgBox, 16, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["Error"], % TransA["Function"] . ":" . A_Space . A_ThisFunc . "`n" 
						. TransA["Something went wrong with (triggerstring, hotstring) creation"] . ":" . "`n`n"
						. "Hotstring(:" . NewOptions . ":" . FoundTriggerstring . "," . "func(""F_SimpleOutput"").bind(" . TextInsert . "," . A_Space . Oflag . "," . A_Space . v_SendFun . ")," . A_Space . OnOffToggle . ")"
						. "`n`n" . TransA["Library name:"] . A_Tab .  Library
			}
;#c/* commercial only beginning			
;#c*/ commercial only end			
		}
		return, "Yes"
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_ReadUserInputs(ByRef TextInsert, ByRef NewOptions, ByRef SendFun)
{
	global 	;assume-global mode of operation
	local	WhichGUI := F_WhichGui()

	Gui, % WhichGUI . ":" . A_Space . "Submit", NoHide	;I don't know how to combine these 2x lines into 1.
	Gui, % WhichGUI . ":" . A_Space . "+OwnDialogs"

	if (v_Triggerstring = "")
	{
		MsgBox, % 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"],  % TransA["Triggerstring cannot be empty if you wish to add new hotstring"] . "."
		return, true
	}
	if (Trim(v_Triggerstring) = "")
		MsgBox, % 48 + 4, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"],  % TransA["Triggerstring contains only white characters. Are you sure to continue?"]
		IfMsgBox, No
			return, true
	if InStr(v_SelectFunction, "Menu")
	{
		if ((RTrim(v_EnterHotstring) = "") and (RTrim(v_EnterHotstring1) = "") and (RTrim(v_EnterHotstring2) = "") and (RTrim(v_EnterHotstring3) = "") and (RTrim(v_EnterHotstring4) = "") and (RTrim(v_EnterHotstring5) = "") and (RTrim(v_EnterHotstring6) = "")) ;hotstring can start from white character
		{
			MsgBox, 324, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["Hotstring text is blank. Do you want to proceed?"]
			IfMsgBox, No
				return, true
		}
		v_EnterHotstring := RTrim(v_EnterHotstring) ;hotstring can start from white character
		if (v_EnterHotstring != "")
		{
			v_EnterHotstring := StrReplace(v_EnterHotstring, "`n", "``n")	;in case of multiline content all CR & LF are automatically converted to `n
			TextInsert .=  v_EnterHotstring
		}
		v_EnterHotstring1 := RTrim(v_EnterHotstring1) ;hotstring can start from white character
		if (v_EnterHotstring1 != "")
		{
			v_EnterHotstring1 := StrReplace(v_EnterHotstring1, "`n", "``n")	;in case of multiline content all CR & LF are automatically converted to `n
			TextInsert .= c_MHDelimiter . v_EnterHotstring1
		}
		v_EnterHotstring2 := RTrim(v_EnterHotstring2) ;hotstring can start from white character
		if (v_EnterHotstring2 != "")
		{
			v_EnterHotstring2 := StrReplace(v_EnterHotstring2, "`n", "``n")	;in case of multiline content all CR & LF are automatically converted to `n
			TextInsert .= c_MHDelimiter . v_EnterHotstring2
		}
		v_EnterHotstring3 := RTrim(v_EnterHotstring3) ;hotstring can start from white character
		if (v_EnterHotstring3 != "")
		{
			v_EnterHotstring3 := StrReplace(v_EnterHotstring3, "`n", "``n")	;in case of multiline content all CR & LF are automatically converted to `n
			TextInsert .= c_MHDelimiter . v_EnterHotstring3
		}
		v_EnterHotstring4 := RTrim(v_EnterHotstring4) ;hotstring can start from white character
		if (v_EnterHotstring4 != "")
		{
			v_EnterHotstring4 := StrReplace(v_EnterHotstring4, "`n", "``n")	;in case of multiline content all CR & LF are automatically converted to `n
			TextInsert .= c_MHDelimiter . v_EnterHotstring4
		}
		v_EnterHotstring5 := RTrim(v_EnterHotstring5) ;hotstring can start from white character
		if (v_EnterHotstring5 != "")
		{
			v_EnterHotstring5 := StrReplace(v_EnterHotstring5, "`n", "``n")	;in case of multiline content all CR & LF are automatically converted to `n
			TextInsert .= c_MHDelimiter . v_EnterHotstring5
		}
		v_EnterHotstring6 := RTrim(v_EnterHotstring6) ;hotstring can start from white character
		if (v_EnterHotstring6 != "")
		{
			v_EnterHotstring6 := StrReplace(v_EnterHotstring6, "`n", "``n")	;in case of multiline content all CR & LF are automatically converted to `n
			TextInsert .= c_MHDelimiter . v_EnterHotstring6
		}
	}
	else
	{
		v_EnterHotstring := RTrim(v_EnterHotstring)
		if (v_EnterHotstring = "") and (v_SelectFunction != TransA["Picture (P)"]) and (v_SelectFunction != TransA["Run (R)"])
		{
			MsgBox, % c_MsgBoxIconQuestion + c_MsgBoxButtYesNo, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["Hotstring text is blank. Do you want to proceed?"] 
			IfMsgBox, No
				return, true
		}
		else
		{
			v_EnterHotstring := StrReplace(v_EnterHotstring, "`n", "``n")	;in case of multiline content all CR & LF are automatically converted to `n
		,	TextInsert := v_EnterHotstring
		}
	}
	if (v_SelectFunction == TransA["Picture (P)"])	;validation of v_EnterHotstring
	{
		if (v_EnterHotstring = "")
		{
			MsgBox, % c_MsgBoxIconQuestion + c_MsgBoxButtYesNo, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["Path to picture file is blank. Do you want to select it now from inteactive GUI?"] 
			IfMsgBox, No
				return, true
			IfMsgBox, Yes
				FileSelectFile, v_EnterHotstring, 3, % A_MyDocuments, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["Select picture filename"], *.jpg; *.png; *.gif	;3 = 1 (File Must Exist) + 2 (Path Must Exist)
			TextInsert := v_EnterHotstring
		}
		else
		{
			v_EnterHotstring := Trim(v_EnterHotstring)
		,	TextInsert := v_EnterHotstring
		}
		if (!FileExist(v_EnterHotstring))
		{
			MsgBox, % c_MsgBoxIconQuestion, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["Content of this text field is not file path or file wasn't found. For ouput function ""Picture (P)"" it is required to enter correct filepath."] 
				. "`n`n"	
				. TransA["Leave this field empty and then press ""Add/Edit hotstring (F9)"" again to get GUI enabling file selection."] 
			return, true
		}	
	}
	if (v_SelectFunction == TransA["Run (R)"])
	{
		if (v_EnterHotstring = "")
		{
			MsgBox, % c_MsgBoxIconQuestion + c_MsgBoxButtYesNo, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["Path to executable file is blank. Do you want to select it now from inteactive GUI?"] 
			IfMsgBox, No
				return, true
			IfMsgBox, Yes
				FileSelectFile, v_EnterHotstring, 3, % A_MyDocuments, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["Select executable file"], *.exe	;3 = 1 (File Must Exist) + 2 (Path Must Exist)
			TextInsert := v_EnterHotstring
		}
		else
		{
			v_EnterHotstring := Trim(v_EnterHotstring)
		,	TextInsert := v_EnterHotstring
		}
		if (!FileExist(v_EnterHotstring))
		{
			MsgBox, % c_MsgBoxIconQuestion, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["Content of this text field is not file path or file wasn't found. For ouput function ""Run (R)"" it is required to enter correct filepath."] 
				. "`n`n"	
				. TransA["Leave this field empty and then press ""Add/Edit hotstring (F9)"" again to get GUI enabling file selection."] 
			return, true
		}	
	}	
	if (!v_SelectHotstringLibrary) or (v_SelectHotstringLibrary = TransA["↓ Click here to select hotstring library ↓"])
	{
		MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["Choose existing hotstring library file before saving new (triggerstring, hotstring) definition!"]
		return, true
	}
	if (v_OptionImmediateExecute)
		NewOptions .= "*"
	Switch v_RadioCaseGroup
	{
		Case 2: NewOptions .= "C"
		Case 3: NewOptions .= "C1"
		Case 4: NewOptions .= "C2"
	}
	if (v_OptionNoBackspace)
		NewOptions .= "B0"
	if (v_OptionInsideWord)
		NewOptions .= "?"
	if (v_OptionNoEndChar)
		NewOptions .= "O"
	if (v_OptionReset)
		NewOptions .= "Z"
	Switch v_SelectFunction
	{
		Case "Clipboard (CL)":				SendFun := "CL"
		Case "SendInput (SI)": 				SendFun := "SI"
		Case "Menu & Clipboard (MCL)": 		SendFun := "MCL"
		Case "Menu & SendInput (MSI)": 		SendFun := "MSI"
		Case "SendRaw (SR)":				SendFun := "SR"
		Case "SendPlay (SP)":				SendFun := "SP"
		Case "SendEvent (SE)":				SendFun := "SE"
		Case TransA["Special function 1 (S1)"]: SendFun := "S1"
		Case TransA["Special function 2 (S2)"]: SendFun := "S2"
		Case TransA["Picture (P)"]:			SendFun := "P"
		Case TransA["Run (R)"]:				SendFun := "R"
	}

	if (SendFun = "SI") or (SendFun = "MSI") or (SendFun = "SE") or (SendFun = "S1") or (SendFun = "S2")
		{	; provide warning to user if definition contains one of the escaped characters: {}^!+#
			WhichEscape := "{"
			if (InStr(TextInsert, WhichEscape))
				{
					if (RegExMatch(TextInsert, "[^{]\" . WhichEscape . "|\" . WhichEscape . "[^}]|[^}]\" . WhichEscape . "$"))
						return, F_MessageAboutEscapedCharacter(WhichEscape)
				}
			WhichEscape := "}"
			if (InStr(TextInsert, WhichEscape))
				{
					if (RegExMatch(TextInsert, "[^{]\" . WhichEscape . "|\" . WhichEscape . "[^}]|[^}]\" . WhichEscape . "$"))
						return, F_MessageAboutEscapedCharacter(WhichEscape)
				}
			WhichEscape := "^"
			if (InStr(TextInsert, WhichEscape))
				{
					if (RegExMatch(TextInsert, "[^{]\" . WhichEscape . "|\" . WhichEscape . "[^}]|[^}]\" . WhichEscape . "$"))
						return, F_MessageAboutEscapedCharacter(WhichEscape)
				}
			WhichEscape := "!"
			if (InStr(TextInsert, WhichEscape))
				{
					if (RegExMatch(TextInsert, "[^{]\" . WhichEscape . "|\" . WhichEscape . "[^}]|[^}]\" . WhichEscape . "$"))
						return, F_MessageAboutEscapedCharacter(WhichEscape)
				}
			WhichEscape := "+"
			if (InStr(TextInsert, WhichEscape))
				{
					if (RegExMatch(TextInsert, "[^{]\" . WhichEscape . "|\" . WhichEscape . "[^}]|[^}]\" . WhichEscape . "$"))
						return, F_MessageAboutEscapedCharacter(WhichEscape)
				}
			WhichEscape := "#"
			if (InStr(TextInsert, WhichEscape))
				{
					if (RegExMatch(TextInsert, "[^{]\" . WhichEscape . "|\" . WhichEscape . "[^}]|[^}]\" . WhichEscape . "$"))
						return, F_MessageAboutEscapedCharacter(WhichEscape)
				}
		}
	if (SendFun = "SP")
		{
			MsgBox, 48, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["warning"], % TransA["""SP"" or SendPlay may have no effect at all if UAC is enabled, even if the script is running as an administrator. For more information, refer to the AutoHotkey FAQ (help)."]
			WhichEscape := "{"
			if (InStr(TextInsert, WhichEscape))
				{
					if (RegExMatch(TextInsert, "[^{]\" . WhichEscape . "|\" . WhichEscape . "[^}]|[^}]\" . WhichEscape . "$"))
						return, F_MessageAboutEscapedCharacter(WhichEscape)
				}
			WhichEscape := "}"
			if (InStr(TextInsert, WhichEscape))
				{
					if (RegExMatch(TextInsert, "[^{]\" . WhichEscape . "|\" . WhichEscape . "[^}]|[^}]\" . WhichEscape . "$"))
						return, F_MessageAboutEscapedCharacter(WhichEscape)
				}
			WhichEscape := "^"
			if (InStr(TextInsert, WhichEscape))
				{
					if (RegExMatch(TextInsert, "[^{]\" . WhichEscape . "|\" . WhichEscape . "[^}]|[^}]\" . WhichEscape . "$"))
						return, F_MessageAboutEscapedCharacter(WhichEscape)
				}
			WhichEscape := "!"
			if (InStr(TextInsert, WhichEscape))
				{
					if (RegExMatch(TextInsert, "[^{]\" . WhichEscape . "|\" . WhichEscape . "[^}]|[^}]\" . WhichEscape . "$"))
						return, F_MessageAboutEscapedCharacter(WhichEscape)
				}
			WhichEscape := "+"
			if (InStr(TextInsert, WhichEscape))
				{
					if (RegExMatch(TextInsert, "[^{]\" . WhichEscape . "|\" . WhichEscape . "[^}]|[^}]\" . WhichEscape . "$"))
						return, F_MessageAboutEscapedCharacter(WhichEscape)
				}
			WhichEscape := "#"
			if (InStr(TextInsert, WhichEscape))
				{
					if (RegExMatch(TextInsert, "[^{]\" . WhichEscape . "|\" . WhichEscape . "[^}]|[^}]\" . WhichEscape . "$"))
						return, F_MessageAboutEscapedCharacter(WhichEscape)
				}
		}
	return, false
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_MessageAboutEscapedCharacter(WhichEscape)
{
	global	;assume-global mode of operation
	MsgBox, % 4 + 32 + 256, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["question"], % TransA["If you apply ""SI"" or ""MSI"" or ""SE"" output function then some characters like"]
			. A_Space . WhichEscape . A_Space . TransA["have to be escaped in the following form:"] . A_Space . "{" . WhichEscape . "}" . "." . "`n`n"
			. TransA["Do you want to proceed?"] . "`n`n"
			. TransA["If you answer ""Yes"", then new definition will be created, but seleced special character will not be visible."] . "`n`n"
			. TransA["If you answer ""No"", then you will get a chance to fix your new created definition."]
		IfMsgBox, No
			return, 1
		IfMsgBox, Yes
			return, 0
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_Clear()
{
	global	;assume-global mode of operation
	Gui,		  HS3: Font, % "c" . c_FontColor
	GuiControl, HS3:, % IdEdit1,  				;v_Triggerstring
	GuiControl, HS3: Font, % IdCheckBox1
	GuiControl, HS3:, % IdCheckBox1, 0
	GuiControl, HS3: Font, % IdRadioCaseCC
	GuiControl, HS3: Font, % IdRadioCaseCS
	GuiControl, HS3: Font, % IdRadioCaseC1
	GuiControl, HS3:, v_RadioCaseGroup, 1
	GuiControl, HS3: Font, % IdCheckBox3
	GuiControl, HS3:, % IdCheckBox3, 0
	GuiControl, HS3: Font, % IdCheckBox4
	GuiControl, HS3:, % IdCheckBox4, 0
	GuiControl, HS3: Font, % IdCheckBox5
	GuiControl, HS3:, % IdCheckBox5, 0
	; GuiControl, HS3: Font, % IdCheckBox6
	; GuiControl, HS3:, % IdCheckBox6, 0
	GuiControl, HS3: Font, % IdCheckBox8
	GuiControl, HS3:, % IdCheckBox8, 0
	GuiControl, HS3: Choose, % IdDDL1, SendInput (SI) ;v_SelectFunction 
	GuiControl, HS3:, % IdEdit2,  				;v_EnterHotstring
	GuiControl, HS3:, % IdEdit3, 					;v_EnterHotstring1
	GuiControl, HS3: Disable, % IdEdit3 			;v_EnterHotstring1
	GuiControl, HS3:, % IdEdit4, 					;v_EnterHotstring2
	GuiControl, HS3: Disable, % IdEdit4 			;v_EnterHotstring2
	GuiControl, HS3:, % IdEdit5, 					;v_EnterHotstring3
	GuiControl, HS3: Disable, % IdEdit5 			;v_EnterHotstring3
	GuiControl, HS3:, % IdEdit6, 					;v_EnterHotstring4
	GuiControl, HS3: Disable, % IdEdit6 			;v_EnterHotstring4
	GuiControl, HS3:, % IdEdit7, 					;v_EnterHotstring5
	GuiControl, HS3: Disable, % IdEdit7 			;v_EnterHotstring5
	GuiControl, HS3:, % IdEdit8, 					;v_EnterHotstring6
	GuiControl, HS3: Disable, % IdEdit8 			;v_EnterHotstring6
	GuiControl, HS3:, % IdEdit9,  				;Comment
	GuiControl, HS3:, % IdEdit10,  				;Sandbox
	GuiControl, HS3: ChooseString, % IdDDL2, % TransA["↓ Click here to select hotstring library ↓"]
	if (F_WhichGui() = "HS3")
		LV_Delete()
	
	Gui,		  HS4: Font, % "c" . c_FontColor
	GuiControl, HS4:, % IdEdit1b,  				;v_Triggerstring
	GuiControl, HS4: Font, % IdCheckBox1b
	GuiControl, HS4: Font, % IdRadioCaseCCb
	GuiControl, HS4: Font, % IdRadioCaseCSb
	GuiControl, HS4:, v_RadioCaseGroup, 1
	GuiControl, HS4: Font, % IdRadioCaseC1b
	GuiControl, HS4:, % IdRadioCaseC1b, 0
	GuiControl, HS4: Font, % IdCheckBox3b
	GuiControl, HS4:, % IdCheckBox3b, 0
	GuiControl, HS4: Font, % IdCheckBox4b
	GuiControl, HS4:, % IdCheckBox4b, 0
	GuiControl, HS4: Font, % IdCheckBox5b
	GuiControl, HS4:, % IdCheckBox5b, 0
	; GuiControl, HS4: Font, % IdCheckBox6b
	; GuiControl, HS4:, % IdCheckBox6b, 0
	GuiControl, HS4: Font, % IdCheckBox8b
	GuiControl, HS4:, % IdCheckBox8b, 0
	GuiControl, HS4: Choose, % IdDDL1b, SendInput (SI) 	;v_SelectFunction 
	GuiControl, HS4: , % IdEdit2b,  					;v_EnterHotstring
	GuiControl, HS4: , % IdEdit3b, 					;v_EnterHotstring1
	GuiControl, HS4: Disable, % IdEdit3b 				;v_EnterHotstring1
	GuiControl, HS4: , % IdEdit4b, 					;v_EnterHotstring2
	GuiControl, HS4: Disable, % IdEdit4b 				;v_EnterHotstring2
	GuiControl, HS4: , % IdEdit5b, 					;v_EnterHotstring3
	GuiControl, HS4: Disable, % IdEdit5b 				;v_EnterHotstring3
	GuiControl, HS4: , % IdEdit6b, 					;v_EnterHotstring4
	GuiControl, HS4: Disable, % IdEdit6b 				;v_EnterHotstring4
	GuiControl, HS4: , % IdEdit7b, 					;v_EnterHotstring5
	GuiControl, HS4: Disable, % IdEdit7b 				;v_EnterHotstring5
	GuiControl, HS4: , % IdEdit8b, 					;v_EnterHotstring6
	GuiControl, HS4: Disable, % IdEdit8b 				;v_EnterHotstring6
	GuiControl, HS4: , % IdEdit9b,  					;Comment
	GuiControl, HS4: , % IdEdit10b,  					;Sandbox
	GuiControl, HS4: ChooseString, % IdDDL2b, % TransA["↓ Click here to select hotstring library ↓"]
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_Move()	;activated by pressing button "Move (F8)" within GUI window MoveLibs
{
	global	;assume-global mode
	local 	NoOnTheList := 0, Temp1 := "", SourceLibrary := "", DestinationLibrary := "", SearchedTriggerstring := ""
,			Triggerstring := "", TriggOpt := "", OutFun := "", EnDis := "", Hotstring := "", Comment := ""
,			WhichRow := 0, TheWholeFile := "", LibraryHeader := ""

	F_GuiHS3_EnDis("Disable")			;Disable all GuiControls for deletion time d(t, o, h)
	DetectHiddenWindows, On
	if WinExist("ahk_id"  HS3SearchHwnd)	;In case HS3Search was available (only hidden) on time of Move, it must be destroyed. If it is not destroyed, it shows old search results, so before Move.
		Gui, HS3Search: Destroy
	DetectHiddenWindows, Off
	Gui, HS3:			+Disabled
	Gui, MoveLibs: 	Default
	Gui, MoveLibs: 	Submit, NoHide
	NoOnTheList := LV_GetNext()
	LV_GetText(DestinationLibrary, NoOnTheList) ;row number DestinationLibrary into OutputVar = v_SelectHotstringLibrary
	if (!DestinationLibrary) 
	{
		MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"],  % TransA["Select a row in the list-view, please!"]
		return
	}
	Gui, HS3:			-Disabled
	Gui, MoveLibs: 	Destroy
	GuiControlGet, SourceLibrary, , % IdDDL2

	Gui, HS3:			Default
	WhichRow := LV_GetNext(, "Focused")
	LV_GetText(EnDis, 			WhichRow, 1)
	LV_GetText(Triggerstring, 	WhichRow, 2)
	LV_GetText(TriggOpt, 		WhichRow, 3)
	LV_GetText(OutFun, 			WhichRow, 4)
	LV_GetText(Hotstring, 		WhichRow, 5)
	LV_GetText(Comment, 		WhichRow, 6)

	GuiControl, ChooseString, % IdDDL2, % DestinationLibrary
	Gui, HS3: 		Submit, NoHide	;this line is necessary to v_SelectHotstringLibrary <- DestinationLibrary
	F_SelectLibrary()	;DestinationLibrary 
	Loop, % LV_GetCount()
	{
		LV_GetText(Temp1, A_Index, 2)
		if (Temp1 == Triggerstring)
		{
			MsgBox, 308, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["warning"], % TransA["The selected triggerstring already exists in destination library file:"]
				. "`n`n" 	. Triggerstring
				. "`n" 	. DestinationLibrary . "`n`n"
				. TransA["Do you want to replace it with source definition?"]
			IfMsgBox, Yes
			{
				LV_Delete(A_Index)
			}
			IfMsgBox, No
			{
				Gui, HS3:			-Disabled
				Gui, HS3:			Default
				F_GuiHS3_EnDis("Enable")
				return
			}
		}
	}
	
	LV_Add("", EnDis, Triggerstring, TriggOpt, OutFun, Hotstring, Comment) ;add to ListView
	LV_ModifyCol(2, "Sort")
	FileRead, TheWholeFile, % ini_HADL . "\" . DestinationLibrary

	LibraryHeader	:= F_ExtractHeader(TheWholeFile)
	if (LibraryHeader)
		LibraryHeader 	:= "/*`n" . LibraryHeader . "`n*/`n`n"
,		TheWholeFile	:= ""	
	FileDelete, % ini_HADL . "\" . DestinationLibrary	;delete the old destination file.
	if (LibraryHeader)
		FileAppend, % LibraryHeader, % ini_HADL . "\" . DestinationLibrary, UTF-8
	FileAppend, % F_ConvertListViewIntoTxt(), % ini_HADL . "\" . DestinationLibrary, UTF-8
	
	GuiControl, ChooseString, % IdDDL2, % SourceLibrary
	Gui, HS3: 		Submit, NoHide	;this line is necessary to v_SelectHotstringLibrary <- SourceLibrary
	F_SelectLibrary() ;Remove the definition from source table / file.
	Loop, % LV_GetCount()
	{
		LV_GetText(Temp1, A_Index, 2)
		if (Temp1 == Triggerstring)
		{
			LV_Delete(A_Index)
			break
		}
	}
	FileRead, TheWholeFile, % ini_HADL . "\" . SourceLibrary
	LibraryHeader	:= F_ExtractHeader(TheWholeFile)
	if (LibraryHeader)
		LibraryHeader 	:= "/*`n" . LibraryHeader . "`n*/`n`n"
,		TheWholeFile	:= ""	
	FileDelete, % ini_HADL . "\" . SourceLibrary	;delete the old source filename.
	if (LibraryHeader)
		FileAppend, % LibraryHeader, % ini_HADL . "\" . SourceLibrary, UTF-8
	FileAppend, % F_ConvertListViewIntoTxt(), % ini_HADL . "\" . SourceLibrary, UTF-8
	F_LoadLibrariesToTables()	; Hotstrings are already loaded by function F_LoadHotstringsFromLibraries(), but auxiliary tables have to be loaded again. Those (auxiliary) tables are used among others to fill in LV_ variables.
	GuiControl, ChooseString, % IdDDL2, % DestinationLibrary
	Gui, HS3: 		Submit, NoHide	;this line is necessary to v_SelectHotstringLibrary <- DestinationLibrary
	F_SelectLibrary()	;DestinationLibrary
	Loop, % LV_GetCount()
	{
		LV_GetText(v_SearchedTriggerString, A_Index, 2)
		if (v_SearchedTriggerString == Triggerstring)
		{
			LV_Modify(A_Index, "Vis +Select +Focus")
			break
		}
	}
	F_GuiHS3_EnDis("Enable")			;Enable all GuiControls after deletion
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_GuiMoveLibs_CreateDetermine()
{
	global	;assume-global mode
	local v_OutVarTemp1 := 0, 	v_OutVarTemp1X := 0, 	v_OutVarTemp1Y := 0, 	v_OutVarTemp1W := 0, 	v_OutVarTemp1H := 0
		,v_OutVarTemp2 := 0, 	v_OutVarTemp2X := 0, 	v_OutVarTemp2Y := 0, 	v_OutVarTemp2W := 0, 	v_OutVarTemp2H := 0
		,v_OutVarTemp3 := 0, 	v_OutVarTemp3X := 0, 	v_OutVarTemp3Y := 0, 	v_OutVarTemp3W := 0, 	v_OutVarTemp3H := 0
							,v_xNext := 0, 		v_yNext := 0, 			v_wNext := 0, 			v_hNext := 0
		,v_WB1 := 0,			v_WB2 := 0,			v_DB := 0
		,key := "",			value := 0,			v_SelectedRow := 0
	,	SourceLibrary := ""	
	
	Gui, MoveLibs: New, 	-Caption +Border -Resize +HwndMoveLibsHwnd +Owner
	Gui, MoveLibs: Margin,	% c_xmarg, % c_ymarg
	Gui,	MoveLibs: Color,	% c_WindowColor, % c_ControlColor
	Gui,	MoveLibs: Font, 	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, 	% c_FontType
	Gui, MoveLibs: Default
	
	Gui, MoveLibs: Add, Text,     x0 y0 HwndIdMoveLibs_T1, 						% TransA["Select the target library:"]
	Gui, MoveLibs: Add, ListView, x0 y0 HwndIdMoveLibs_LV LV0x1 +AltSubmit -Hdr -Multi, 	| 	;-Hdr (minus Hdr) to omit the header (the special top row that contains column titles). "|" is required! ;LV0x1 +/-Grid. Displays gridlines around rows and columns.
	Gui, MoveLibs: Add, Button, 	x0 y0 HwndIdMoveLibs_B1 Default gF_Move,			% TransA["Move (F8)"]
	Gui, MoveLibs: Add, Button, 	x0 y0 HwndIdMoveLibs_B2 gMoveLibsGuiCancel,			% TransA["Cancel"]
	
	v_xNext := c_xmarg
,	v_yNext := c_ymarg
	GuiControl, Move, % IdMoveLibs_T1, % "x" v_xNext "y" v_yNext
	
	GuiControlGet, v_OutVarTemp2, Pos, % IdMoveLibs_LV
	v_yNext := c_HofText + c_ymarg
,	v_hNext := v_OutVarTemp2H * 4
	GuiControl, Move, % IdMoveLibs_LV, % "x" v_xNext "y" v_yNext "h" v_hNext ; by default ListView shows just 5 rows
	
	GuiControlGet, v_OutVarTemp1, Pos, % IdMoveLibs_LV
	GuiControlGet, v_OutVarTemp2, Pos, % IdMoveLibs_B1
	GuiControlGet, v_OutVarTemp3, Pos, % IdMoveLibs_B2
	
	v_WB1 := v_OutVarTemp2W + 2 * c_xmarg
,	v_WB2 := v_OutVarTemp3W + 2 * c_xmarg
,	v_DB  := v_OutVarTemp1W - (v_WB1 + v_WB2)
	
,	v_xNext := c_xmarg
,	v_yNext := v_OutVarTemp1Y + v_OutVarTemp1H + c_ymarg
,	v_wNext := v_WB1
	GuiControl, Move, % IdMoveLibs_B1, % "x" v_xNext "y" v_yNext "w" v_wNext
	
	v_xNext := c_xmarg + v_WB1 + v_DB
,	v_wNext := v_WB2
	GuiControl, Move, % IdMoveLibs_B2, % "x" v_xNext "y" v_yNext "w" v_wNext
	
	; Fill in IdMoveLibs_LV with values
	GuiControlGet, SourceLibrary, , % IdDDL2
	for key, value in ini_LoadLib
		if (value) and (key != SourceLibrary)
			LV_Add("", key)
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_MoveList()
{
	global	;assume-global mode
	local 	v_SelectedRow := 0
		,	Window1X := 0, Window1Y := 0, Window1W := 0, Window1H := 0
		,	Window2X := 0, Window2Y := 0, Window2W := 0, Window2H := 0
		,	NewWinPosX := 0, NewWinPosY := 0
	
	WinGetPos, Window1X, Window1Y, Window1W, Window1H, A
	F_GuiMoveLibs_CreateDetermine()
	Gui, MoveLibs: Show, Hide
	
	DetectHiddenWindows, On
	WinGetPos, Window2X, Window2Y, Window2W, Window2H, % "ahk_id" . MoveLibsHwnd
	DetectHiddenWindows, Off
	NewWinPosX := Round(Window1X + (Window1W / 2) - (Window2W / 2))
	NewWinPosY := Round(Window1Y + (Window1H / 2) - (Window2H / 2))
	
	Gui, MoveLibs: Show, % "AutoSize" . A_Space . "X" . NewWinPosX . A_Space . "Y" . NewWinPosY . A_Space
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_HSLV2() ; copy content of List View 1 to editable fields of HS3 Gui
{
	global	;assume-global mode
	; OutputDebug, % "A_ThisFunc:" . A_Space . A_ThisFunc . A_Tab . "A_GuiEvent:" . A_Space . A_GuiEvent . A_Tab . "A_GuiControl:" . A_Space . A_GuiControl . A_Tab . "A_EventInfo:" . A_Space . A_EventInfo . A_Tab . "ErrorLevel:" . A_Space . ErrorLevel . "`n"
	Switch A_GuiEvent
	{
		Default:
			return
		Case "Normal":
			if (LV_GetNext())
				LV2_CopyContentToHS3LV()
			else	;if just Enter is pressed, without selecting any row
			{
				LV_Modify(1, "Vis +Select +Focus")
				GuiControl, Focus, % IdSearchLV1
				return
			}
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
LV2_CopyContentToHS3LV() ;load content of chosen row from Search Gui into HS3 Gui
{
	global	;assume-global mode
	local SelectedRow := 0, Library := "", Triggerstring := "", SearchedTriggerString := "", SelectHotstringLibrary := ""
	
	SelectedRow 		:= LV_GetNext()
	Switch v_RadioGroup
	{
		Case 1:	;search by Triggerstring
			LV_GetText(Library, 		SelectedRow, 3)
			LV_GetText(Triggerstring, 	SelectedRow, 1)
		Case 2:	;search by Hotstring
			LV_GetText(Library, 		SelectedRow, 3)
			LV_GetText(Triggerstring, 	SelectedRow, 4)
		Case 3:	;search by Library
			LV_GetText(Library, 		SelectedRow, 1)
			LV_GetText(Triggerstring, 	SelectedRow, 3)
	}
	SelectHotstringLibrary := % Library . ".csv"
	GuiControl, Choose, % IdDDL2, % SelectHotstringLibrary
	Gui, HS3: 		Submit, NoHide	;this line is necessary to v_SelectHotstringLibrary <- SelectHotstringLibrary
	F_SelectLibrary()
	Gui, HS3: 		-Disabled
	Gui, HS3Search:	Hide
	GuiControl, Focus, % IdListView1
	
	SearchedTriggerString := Triggerstring
	Loop
	{
		LV_GetText(Triggerstring, A_Index, 2)
		if (Triggerstring == SearchedTriggerString)
		{
			LV_Modify(A_Index, "Vis +Select +Focus")
			break
		}
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_HS3Search_PlotWindow()
{
	global	;assume-global mode
	local	PreviousGui := ""

	PreviousGui := F_WhichGui()
	WinGetPos, Window1X, Window1Y, Window1W, Window1H, A	;Retrieves the position of the active window.
	Gui, % PreviousGui . ": +Disabled"	;thanks to this line user won't be able to interact with main hotstring window if TTStyling window is available
	Gui, HS3Search: -Disabled
	Gui, HS3Search: Default
	Switch PreviousGui
	{
		Case "HS3": Gui, HS3Search: Show, % "x" . Window1X + 2 * c_xmarg . "y" . Window1Y + 2 * c_ymarg . "w" . HS3_GuiWidth . "h" . HS3_GuiHeight
		Case "HS4": Gui, HS3Search: Show, % "x" . Window1X + 2 * c_xmarg . "y" . Window1Y + 2 * c_ymarg . "w" . HS4_GuiWidth * 2 . "h" . HS4_GuiHeight
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_HS3Search_LoadLV()
{	;code separation: here LV is loaded with data accordingly to user choice, with specific order of columns
	global	;assume-global mode
	local	index := 0, value := ""

	Switch v_RadioGroup
	{
		Case 1:	;search by Triggerstring which is default
			for index, value in a_Triggerstring
			{
				if (v_SearchTerm)
				{
					if (InStr(value, v_SearchTerm) = 1) ; for matching at the start ;for overall matching without = 1
						LV_Add("", value, a_EnableDisable[index], a_Library[index], a_TriggerOptions[index], a_OutputFunction[index], a_Hotstring[index], a_Comment[index])
				}
				else
					LV_Add("", value, a_EnableDisable[index], a_Library[index], a_TriggerOptions[index], a_OutputFunction[index], a_Hotstring[index], a_Comment[index])
			}
		Case 2:	;search by Hotstring
			for index, value in a_Hotstring
			{
				if (v_SearchTerm)
				{
					if (InStr(value, v_SearchTerm)) ; for overall matching
						LV_Add("", value, a_EnableDisable[index], a_Library[index], a_Triggerstring[index], a_TriggerOptions[index], a_OutputFunction[index], a_Comment[index])
				}
				else
					LV_Add("", value, a_EnableDisable[index], a_Library[index], a_Triggerstring[index], a_TriggerOptions[index], a_OutputFunction[index], a_Comment[index])
			}
		Case 3:	;search by Library
			for index, value in a_Library
			{
				if (v_SearchTerm)
				{
					if (InStr(value, v_SearchTerm)) ; for overall matching
						LV_Add("", value, a_EnableDisable[index], a_Triggerstring[index], a_TriggerOptions[index], a_OutputFunction[index], a_Hotstring[index], a_Comment[index])
				}
				else
					LV_Add("", value, a_EnableDisable[index], a_Triggerstring[index], a_TriggerOptions[index], a_OutputFunction[index], a_Hotstring[index], a_Comment[index])
			}
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_GuiHS3Search_LVcolumnScale()
{	;changes width and order of columns depending on user decision (choice of radio button)
	global	;assume-global mode
	local	ListViewWidth := 0, OutVarTemp := 0, OutVarTempX := 0, OutVarTempY := 0, OutVarTempW := 0, OutVarTempH := 0 ;Within a function, to create a set of variables that is local instead of global, declare OutputVar as a local variable prior to using command GuiControlGet, Pos. However, it is often also necessary to declare each variable in the set, due to a common source of confusion.		
,			c1 := 0, c2 := 0, c3 := 0, c4 := 0, c5 := 0, c6 := 0, c7 := 0, LVM_GETCOLUMNWIDTH = 0x1000 + 29 ;https://www.autohotkey.com/boards/viewtopic.php?p=25857#p25857
,			SM_CXVSCROLL := 2, WidthVerScrollBar := 0 ;Width of a vertical scroll bar, in pixels
,			ListViewWidth := 0, TheRest := 0

	SysGet, WidthVerScrollBar, % SM_CXVSCROLL ;returns value 26
	Gui, HS3Search: -DPIScale	;switch off dpiscale temporarily to get the same values from SendMessage command	
	GuiControlGet, OutVarTemp, Pos, % IdSearchLV1 ;This line will be used for "if" and "else" statement.	
	ListViewWidth := OutVarTempW
	
	Switch v_RadioGroup
	{
		Case 1:	;search by Triggerstring which is default
			LV_ModifyCol(2, "AutoHdr" . A_Space . "Center", TransA["En. / Dis."])	;Adjusts the column's width to fit its contents and the column's header text, whichever is wider.
			SendMessage, LVM_GETCOLUMNWIDTH, 1, 0, , ahk_id %IdSearchLV1%
			c2 := ErrorLevel
			LV_ModifyCol(4, "AutoHdr" . A_Space . "Center", TransA["Trigger Opt."])
			SendMessage, LVM_GETCOLUMNWIDTH, 3, 0, , ahk_id %IdSearchLV1%
			c4 := ErrorLevel
			LV_ModifyCol(5, "AutoHdr" . A_Space . "Center", TransA["Out. Fun."])
			SendMessage, LVM_GETCOLUMNWIDTH, 4, 0, , ahk_id %IdSearchLV1%
			c5 := ErrorLevel

			TheRest := ListViewWidth - (c2 + c4 + c5 + WidthVerScrollBar + 4)
			LV_ModifyCol(1, TheRest / 4 . A_Space . "Left", TransA["Triggerstring"])
			LV_ModifyCol(3, TheRest / 4 . A_Space . "Left", TransA["Library"])
			LV_ModifyCol(6, TheRest / 4 . A_Space . "Left", TransA["Hotstring"])
			LV_ModifyCol(7, TheRest / 4 . A_Space . "Left", TransA["Comment"])

		Case 2:	;search by Hotstring
			LV_ModifyCol(2, "AutoHdr" . A_Space . "Center", TransA["En. / Dis."])
			SendMessage, LVM_GETCOLUMNWIDTH, 1, 0, , ahk_id %IdSearchLV1%
			c2 := ErrorLevel
			LV_ModifyCol(5, "AutoHdr" . A_Space . "Center", TransA["Trigger Opt."])
			SendMessage, LVM_GETCOLUMNWIDTH, 4, 0, , ahk_id %IdSearchLV1%
			c5 := ErrorLevel
			LV_ModifyCol(6, "AutoHdr" . A_Space . "Center", TransA["Out. Fun."])
			SendMessage, LVM_GETCOLUMNWIDTH, 5, 0, , ahk_id %IdSearchLV1%
			c6 := ErrorLevel

			TheRest := ListViewWidth - (c2 + c5 + c6 + WidthVerScrollBar + 4)
			LV_ModifyCol(1, TheRest / 4 . A_Space . "Left", TransA["Hotstring"])
			LV_ModifyCol(3, TheRest / 4 . A_Space . "Left", TransA["Library"])
			LV_ModifyCol(4, TheRest / 4 . A_Space . "Left", TransA["Triggerstring"])
			LV_ModifyCol(7, TheRest / 4 . A_Space . "Left", TransA["Comment"])

		Case 3:	;search by Library
			LV_ModifyCol(2, "AutoHdr" . A_Space . "Center", TransA["En. / Dis."])
			SendMessage, LVM_GETCOLUMNWIDTH, 1, 0, , ahk_id %IdSearchLV1%
			c2 := ErrorLevel
			LV_ModifyCol(4, "AutoHdr" . A_Space . "Center", TransA["Trigger Opt."])
			SendMessage, LVM_GETCOLUMNWIDTH, 3, 0, , ahk_id %IdSearchLV1%
			c4 := ErrorLevel
			LV_ModifyCol(5, "AutoHdr" . A_Space . "Center", TransA["Out. Fun."])
			SendMessage, LVM_GETCOLUMNWIDTH, 4, 0, , ahk_id %IdSearchLV1%
			c5 := ErrorLevel

			TheRest := ListViewWidth - (c2 + c4 + c5 + WidthVerScrollBar + 4)
			LV_ModifyCol(1, TheRest / 4 . A_Space . "Left", TransA["Library"])
			LV_ModifyCol(3, TheRest / 4 . A_Space . "Left", TransA["Triggerstring"])
			LV_ModifyCol(6, TheRest / 4 . A_Space . "Left", TransA["Hotstring"])
			LV_ModifyCol(7, TheRest / 4 . A_Space . "Left", TransA["Comment"])
	}
	Gui, HS3Search: +DPIScale
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_SearchPhrase()	;handles 2x GUI events: HS3Search: Edit and Radio.
{
	global	;assume-global mode

	; OutputDebug, % A_ThisFunc . "`n"
	Gui, HS3Search: Submit, NoHide
	LV_Delete()
	GuiControl, -Redraw, % IdSearchLV1
	F_HS3Search_LoadLV()
	F_GuiHS3Search_LVcolumnScale()
	LV_ModifyCol(1, "Sort")
	GuiControl, +Redraw, % IdSearchLV1
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_Searching()	;after pressing F3
{
	DetectHiddenWindows, On
	Suspend, On			;To disable all hotstrings definitions within search window.
	if (A_IsCompiled)
		Menu, Tray, Icon,		% A_ScriptFullPath, , 1	;When a script's hotkeys are suspended, its tray icon changes to the letter S. This can be avoided by freezing the icon, which is done by specifying 1 for the last parameter of the Menu command.
	else	
		Menu, Tray, Icon,		% AppIcon, , 1	;When a script's hotkeys are suspended, its tray icon changes to the letter S. This can be avoided by freezing the icon, which is done by specifying 1 for the last parameter of the Menu command.
	if (WinExist("ahk_id" HS3SearchHwnd))
		{
			Gui, HS3: 		+Disabled
			Gui, HS3Search:	-Disabled
			Gui, HS3Search: 	Show
		}
	else	;if not exists, create it
	{
		F_Gui_HS3Search_Create()
		F_HS3Search_DetermineConstraints()
		F_HS3Search_PlotWindow()
		F_SearchPhrase()
	}
	DetectHiddenWindows, Off
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_Gui_HS3Search_Create()
{
	global	;assume-global mode
	
	;1. Prepare Gui general parameters
	Gui, HS3Search: New, 	+Resize +HwndHS3SearchHwnd +OwnerHS3, % TransA["Search Hotstrings"]
	Gui, HS3Search: Margin,	% c_xmarg, % c_ymarg
	Gui,	HS3Search: Color,	% c_WindowColor, % c_ControlColor
	
	;2. Prepare alll Gui objects
	Gui,	HS3Search: Font, % "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, HS3Search: Add, Text, 		x0 y0 HwndIdSearchT1,								% TransA["Phrase to search for:"]
	Gui, HS3Search: Add, Text, 		x0 y0 HwndIdSearchT2,								% TransA["Search by:"]
	Gui,	HS3Search: Font, % "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, 	% c_FontType
	Gui, HS3Search: Add, Edit, 		x0 y0 HwndIdSearchE1 vv_SearchTerm gF_SearchPhrase Limit	;Restricts the user's input to the visible width of the edit field.
	Gui, HS3Search: Add, Radio, 		x0 y0 HwndIdSearchR1 vv_RadioGroup gF_SearchPhrase Checked, % TransA["Triggerstring"]
	Gui, HS3Search: Add, Radio, 		x0 y0 HwndIdSearchR2 gF_SearchPhrase, 					% TransA["Hotstring"]
	Gui, HS3Search: Add, Radio, 		x0 y0 HwndIdSearchR3 gF_SearchPhrase, 					% TransA["Library"]
	Gui, HS3Search: Add, ListView, 	x0 y0 HwndIdSearchLV1 gF_HSLV2 +AltSubmit Grid BackgroundE1E1E1 -Multi,	% TransA["En. / Dis."] . "|" . TransA["Library"] . "|" . TransA["Triggerstring"] . "|" . TransA["Trigger Opt."] . "|" . TransA["Out. Fun."] . "|" . TransA["Hotstring"] . "|" . TransA["Comment"]	;Trick with "BackgroundE1E1E1": There is no simple way to distinguish ListView header from the rest of table, but to change background color.
	Gui, HS3Search: Add, Text, 		x0 y0 HwndIdSearchT4, 								% TransA["F3 or Esc: Close Search hotstrings | ↓ ↑ → ←: to change position | Enter: Select definition and close"]
	Gui, HS3Search: Add, Button, 		Hidden Default gF_HSLV2	;trick to catch if user presses Enter on ListView
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_HS3Search_DetermineConstraints()
{
	global	;assume-global mode
	local 	OutVarTemp := 0, 	OutVarTempX := 0, 	OutVarTempY := 0, 	OutVarTempW := 0, 	OutVarTempH := 0
,			xNext := 0, 		yNext := 0, 			wNext := 0, 			hNext := 0
	
	xNext := c_xmarg
,	yNext := c_ymarg
	GuiControl, Move, % IdSearchT1, % "x" . xNext . "y" . yNext ;Phrase to search
	GuiControlGet, OutVarTemp, Pos, % IdSearchT1
	yNext += c_HofText
	wNext := OutVarTempW * 2
	GuiControl, Move, % IdSearchE1, % "x" xNext "y" yNext "w" wNext

	GuiControlGet, OutVarTemp, Pos, % IdSearchE1
	xNext := c_xmarg + OutVarTempW + 2 * c_xmarg
,	yNext := c_ymarg
	GuiControl, Move, % IdSearchT2, % "x" xNext "y" yNext	;Search by
	yNext += c_HofText
	GuiControl, Move, % IdSearchR1, % "x" xNext "y" yNext
	
	GuiControlGet, OutVarTemp, Pos, % IdSearchR1
	xNext += OutVarTempW + c_xmarg
	GuiControl, Move, % IdSearchR2, % "x" xNext "y" yNext
	GuiControlGet, OutVarTemp, Pos, % IdSearchR2
	xNext += OutVarTempW + c_xmarg
	GuiControl, Move, % IdSearchR3, % "x" xNext "y" yNext
	
	HofRadio 		:= OutVarTempH
,	OutVarTemp 	:= Max(HofRadio, c_HofEdit)
,	xNext 		:= c_xmarg
,	yNext 		+= OutVarTemp + c_ymarg
	Switch F_WhichGui()
	{
		Case "HS3": 
			wNext := HS3_GuiWidth - 2 * c_ymarg
			hNext := HS3_GuiHeight - (c_ymarg + c_HofText + OutVarTemp + c_ymarg + c_HofText * 2)
		Case "HS4": 
			wNext := HS4_GuiWidth * 2 - 2 * c_ymarg
			hNext := HS4_GuiHeight - (c_ymarg + c_HofText + OutVarTemp + c_ymarg + c_HofText * 2)
	}
	; OutputDebug, % "wNext:" . A_Space . wNext . A_Space . "hNext:" . A_Space . wNext . "`n"
	GuiControl, MoveDraw, % IdSearchLV1, % "x" xNext "y" yNext "w" wNext "h" hNext
	
	Gui, HS3Search: Default	;in order to enable LV_ModifyCol
	GuiControlGet, OutVarTemp, Pos, % IdSearchLV1
	xNext 	:= c_xmarg
,	yNext 	:= OutVarTempY + OutVarTempH + c_ymarg
	GuiControl, Move, % IdSearchT4, % "x" xNext "y" yNext ;information about shortcuts
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
HS3SearchGuiSize(GuiHwnd, EventInfo, Width, Height)	;Gui event (automatically generated)
{
	global	;assume-global mode
	local 	OutVarTemp1 := 0, OutVarTemp1X := 0, OutVarTemp1Y := 0, OutVarTemp1W := 0, OutVarTemp1H := 0
,			OutVarTemp2 := 0, OutVarTemp2X := 0, OutVarTemp2Y := 0, OutVarTemp2W := 0, OutVarTemp2H := 0
,			xNext := 0, 		yNext := 0, 			wNext := 0, 			hNext := 0

	; OutputDebug, % A_ThisFunc . A_Space . " EventInfo:" . A_Space .  EventInfo . "`n" 
	Switch EventInfo
	{
		Case 1: 		;The window has been minimized.
		Case 2: 		;The window has been maximized.
			F_AutoXYWH("*wh", 	IdSearchLV1)
			F_AutoXYWH("*y", 	IdSearchT4)
		Default:		;Any other case, e.g. manual window size manipulation or window is restored
			F_AutoXYWH("*wh", 	IdSearchLV1)
			F_AutoXYWH("*y", 	IdSearchT4)
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_RestoreDefaultConfig()
{
	global	;assume-global mode

	MsgBox, 308, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["warning"]
		, % TransA["In order to restore default configuration, the current Config.ini file will be deleted. This action cannot be undone. Next application will be reloaded and upon start the Config.ini with default settings will be created."] 
		. "`n`n" .  TransA["Are you sure?"]
	IfMsgBox, Yes
	{
		FileDelete, % ini_HADConfig
		F_CheckCreateConfigIni()
		Reload
	}
	IfMsgBox, No
		return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_Checkbox()	
{
	global	;assume-global
	local v_OutputVar := 0
	GuiControlGet, v_OutputVar, % A_Gui . ":", % A_GuiControl
	
	if (v_OutputVar)
	{
		if (A_GuiControl = "v_EnDis")
		{
			Gui, HS3: Font, % "s" . c_FontSize . A_Space . "cRed Norm", % c_FontType
			Gui, HS4: Font, % "s" . c_FontSize . A_Space . "cRed Norm", % c_FontType
		}
		else
		{
			Gui, HS4: Font, % "s" . c_FontSize . A_Space . "cGreen Norm", % c_FontType
			Gui, HS3: Font, % "s" . c_FontSize . A_Space . "cGreen Norm", % c_FontType
		}
	}
	else 
	{
		Gui, HS3: Font, % "s" . c_FontSize . A_Space . "c" . c_FontColor . A_Space . "Norm", % c_FontType
		Gui, HS4: Font, % "s" . c_FontSize . A_Space . "c" . c_FontColor . A_Space . "Norm", % c_FontType
	}
	GuiControl, HS3: Font, % A_GuiControl
	GuiControl, HS3:, % A_GuiControl, % v_OutputVar
	GuiControl, HS4: Font, % A_GuiControl
	GuiControl, HS4:, % A_GuiControl, % v_OutputVar
	;OutputDebug, F_Checkbox()
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_GuiHSdelay()
{
	global	;assume-global mode
	local Window1X := 0, Window1Y := 0, Window1W := 0, Window1H := 0
		,Window2X := 0, Window2Y := 0, Window2W := 0, Window2H := 0
		,NewWinPosX := 0, NewWinPosY := 0
		,v_OutVarTemp := 0, 	v_OutVarTempX := 0, 	v_OutVarTempY := 0, 	v_OutVarTempW := 0, 	v_OutVarTempH := 0
		,v_xNext := 0, 		v_yNext := 0, 			v_wNext := 0, 			v_hNext := 0
	;+Owner to prevent display of a taskbar button
	Gui, HSDel: New, -MinimizeBox -MaximizeBox +Owner +HwndHotstringDelay, % TransA["Set Clipboard Delay"]
	Gui, HSDel: Margin,	% c_xmarg, % c_ymarg
	Gui,	HSDel: Color,	% c_WindowColor, % c_ControlColor
	Gui,	HSDel: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, % c_FontType
	
	Gui, HSDel: Add, Slider, x0 y0 HwndIdHD_S1 vini_CPDelay gF_HSdelay Range100-1000 ToolTipBottom Buddy1999, % ini_CPDelay
	TransA["This option is valid"] := StrReplace(TransA["This option is valid"], "``n", "`n")
	Gui, HSDel: Add, Text, HwndIdHD_T1, % TransA["Clipboard paste delay in [ms]:"] . A_Space . ini_CPDelay . "`n`n" . TransA["This option is valid"]
	GuiControlGet, v_OutVarTemp, Pos, % IdHD_T1
	v_xNext := c_xmarg
,	v_yNext := c_ymarg
,	v_wNext := v_OutVarTempW
	GuiControl, Move, % IdHD_S1, % "x" v_xNext . A_Space . "y" v_yNext . A_Space "w" v_wNext
	GuiControl, Move, % IdHD_T1, % "x" v_xNext
	
	WinGetPos, Window1X, Window1Y, Window1W, Window1H, A
	Gui, HSDel: Show, Hide
	DetectHiddenWindows, On
	WinGetPos, Window2X, Window2Y, Window2W, Window2H, % "ahk_id" . HotstringDelay
	DetectHiddenWindows, Off
	
	NewWinPosX := Round(Window1X + (Window1W / 2) - (Window2W / 2))
,	NewWinPosY := Round(Window1Y + (Window1H / 2) - (Window2H / 2))
	
	Gui, HSDel: Show, % "x" . NewWinPosX . A_Space . "y" . NewWinPosY . A_Space . "AutoSize"	
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_HSdelay()
{
	global	;assume-global mode
	GuiControl,, % IdHD_T1, % TransA["Clipboard paste delay in [ms]:"] . A_Space . ini_CPDelay . "`n`n" . TransA["This option is valid"]
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_WhichGui()
{	;This version is more robust: it doesn't take into account just "last active window" (A parameter), but just checks if there are active windows.
	global	;assume-global mode
	local	WinHWND := 0
	
	WinGet, WinHWND, ID, % "ahk_id" HS3GuiHwnd
	if (WinHWND)
	{
		Gui, HS3: Default
		return "HS3"
	}
	WinGet, WinHWND, ID, % "ahk_id" HS4GuiHwnd
	if (WinHWND)
	{
		Gui, HS4: Default
		return "HS4"
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_GuiAddLibrary(TextString*)
{
	global	;assume-global mode
	local OutVarTemp := 0, OutVarTempX := 0, OutVarTempY := 0, OutVarTempW := 0, OutVarTempH := 0
		,OutVarTemp2 := 0, OutVarTemp2X := 0, OutVarTemp2Y := 0, OutVarTemp2W := 0, OutVarTemp2H := 0
		,TempWidth := 2 * c_xmarg, WidthButt1 := 0, WidthButt2 := 0, xButt2 := 0
		,Window1X := 0, Window1Y := 0, Window1W := 0, Window1H := 0
		,Window2X := 0, Window2Y := 0, Window2W := 0, Window2H := 0
		,NewWinPosX := 0, NewWinPosY := 0
	
	;+Owner to prevent display of a taskbar button
	Gui, ALib: New, -Caption +Border +Owner +HwndAddLibrary
	Gui, ALib: Margin,	% c_xmarg, % c_ymarg
	Gui,	ALib: Color,	% c_WindowColor, % c_ControlColor
	Gui,	ALib: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, % c_FontType
	
	Switch TextString[1]
	{
		Case "": Gui, ALib: Add, Text, HwndIdALibText1, % TransA["Enter a name for the new library"]
		Default: Gui, ALib: Add, Text, HwndIdALibText1, % TextString[1]
	}
	Gui, ALib: Add, Edit, HwndIdALibEdit1 vv_NewLib
	
	GuiControlGet, OutVarTemp, ALib: Pos, % IdALibText1
	GuiControl, ALib: Move, % IdALibEdit1, % "w" c_xmarg + OutVarTempW
	
	Gui, ALib: Add, Text, HwndIdALibText2, .csv
	GuiControlGet, OutVarTemp, ALib: Pos, % IdALibEdit1
	TempWidth += OutVarTempW
	GuiControl, ALib: Move, % IdALibText2, % "x" OutVarTempX + OutVarTempW . A_Space . "y" OutVarTempY
	GuiControlGet, OutVarTemp, ALib: Pos, % IdALibText2
	TempWidth += OutVarTempW
	
	Switch TextString[1]
	{
		Case "Choose new library file name:": 	Gui, ALib: Add, Button, HwndIdALibButt1 Default gF_ChangeLibNameOK,		% TransA["OK"]
		Default: 							Gui, ALib: Add, Button, HwndIdALibButt1 Default gF_ALibOK,				% TransA["OK"]
	}
	Gui, ALib: Add, Button, HwndIdALibButt2 gALibGuiClose, % TransA["Cancel"]
	GuiControlGet, OutVarTemp, ALib: Pos, % IdALibButt1
	GuiControlGet, OutVarTemp2, ALib: Pos, % IdALibButt2
	
	WidthButt1 := OutVarTempW + 2 * c_xmarg
,	WidthButt2 := OutVarTemp2W + 2 * c_xmarg
,	xButt2	   := c_xmarg + WidthButt1 + TempWidth - (2 * c_xmarg + WidthButt1 + WidthButt2)
	
	GuiControl, ALib: Move, % IdALibButt1, % "x" c_xmarg . A_Space . "w" WidthButt1
	GuiControl, ALib: Move, % IdALibButt2, % "x" xButt2  . A_Space . "y" OutVarTempY . A_Space . "w" WidthButt2
	
	WinGetPos, Window1X, Window1Y, Window1W, Window1H, A
	Gui, ALib: Show, Hide
	DetectHiddenWindows, On
	WinGetPos, Window2X, Window2Y, Window2W, Window2H, % "ahk_id" . AddLibrary
	DetectHiddenWindows, Off
	
	NewWinPosX := Round(Window1X + (Window1W / 2) - (Window2W / 2))
,	NewWinPosY := Round(Window1Y + (Window1H / 2) - (Window2H / 2))
	Gui, % A_Gui . ": +Disabled"	;thanks to this line user won't be able to interact with main hotstring window if TTStyling window is available
	Gui, ALib: Show, % "x" . NewWinPosX . A_Space . "y" . NewWinPosY . A_Space . "AutoSize"
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_RefreshListOfLibraryTips()
{
;#c/* commercial only beginning
;#c*/ commercial only end	
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_RefreshListOfLibraries()
{
;#c/* commercial only beginning
;#c*/ commercial only end
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_DeleteHotstring()
{
	;1. Remove selected library file.
	;2. Create library file of the same name as selected. its content will contain List View but without selected row.
	;3. Remove selected row from List View.
	;4. Disable selected hotstring.
	;5. Remove trigger hint.
	;6. Decrement library counter.
	global ;assume-global mode
	local 	LibraryFullPathAndName := ini_HADL . "\" . v_SelectHotstringLibrary, TheWholeFile := "", LibraryHeader := ""
	,		SelectedRow := 0, index := 0
	,		key := 0, val := "", options := "", triggerstring := "", EnDis := "", hotstring := "", OldOptions := ""
	,		key2 := 0

	Gui, HS3: Default
	F_GuiHS3_EnDis("Disable")			;Disable all GuiControls for deletion time d(t, o, h)	
	Gui, HS3: +OwnDialogs
	
	SelectedRow := LV_GetNext()
	if (!SelectedRow) 
	{
		MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"],  % TransA["Select a row in the list-view, please!"]
		F_GuiHS3_EnDis("Enable")			;Enable all GuiControls for deletion time d(t, o, h)	
		return
	}
	LV_GetText(triggerstring, 	SelectedRow, 2)	;triggerstring
	LV_GetText(options, 		SelectedRow, 3)	;options
	LV_GetText(EnDis,			SelectedRow, 1)	;enabled or disabled definition
	LV_GetText(hotstring, 		SelectedRow, 5)
	MsgBox, % 256 + 64 + 4, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["Selected definition d(t, o, h) will be deleted. Do you want to proceed?"] . "`n`n"
		. TransA["triggerstring"] . ":" 	. A_Space . triggerstring . "`n" 
		. TransA["options"] . ":" 		. A_Space . options . "`n"
		. TransA["hotstring"] . ":" 		. A_Space . hotstring	. "`n`n" 
		. TransA["If you remove one of the definitions which was multiplied (e.g. duplicated), none of definitions will be active. Therefore It is suggested in order to to enable the second one to reload the application."]
	OldOptions := options		
	IfMsgBox, No
	{
		F_GuiHS3_EnDis("Enable")			;Enable all GuiControls for deletion time d(t, o, h)	
		return
	}	
	
	;1. Remove selected library file.
	FileRead, TheWholeFile, % LibraryFullPathAndName
	LibraryHeader :=  F_ExtractHeader(TheWholeFile)
	if (LibraryHeader)
		LibraryHeader 	:= "/*`n" . LibraryHeader . "`n*/`n`n"
	,	TheWholeFile	:= ""
	FileDelete, % LibraryFullPathAndName

	;2. Disable selected hotstring.

	;In order to switch off, some options have to run in "reversed" state:
	if (EnDis = "En")	;only if definition is enabled, at first try to disable it (if it is disabled, just delete it)
	{
		if (InStr(options, "C2"))
			options := StrReplace(options, "C2", "")	;actually "C2" isn't allowed / existing argument of "Hotstring" function can understand so just before this function is called the "NewOptions" string is checked if there is "C2" available. If it does, "C2" is replaced with "".
		if (InStr(options, "*"))
			options := StrReplace(options, "*", "*0")
		if (InStr(options, "B0"))
			options := StrReplace(options, "B0", "B")
		if (InStr(options, "O"))
			options := StrReplace(options, "O", "O0")
		if (InStr(options, "Z"))
			options := StrReplace(options, "Z", "Z0")
		Try
			Hotstring(":" . options . ":" . F_ConvertEscapeSequences(triggerstring), , "Off")	;if duplicated definition exists, only one is active. As a consequence if one is removed, the second one is not activated automatically: none is enabled anymore till application is restarted.
		Catch
			MsgBox, 16, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["Error"], % TransA["Function"] . ":" . A_Space . A_ThisFunc . "`n`n" 
				. TransA["Something went wrong with hotstring deletion"] . ":" . "`n`n" 
				. TransA["riggerstring"] . ":" 	. A_Space . triggerstring . "`n" 
				. TransA["options"] . ":" 		. A_Space . options . "`n" 
				. TransA["hotstring"] . ":"		. A_Space . hotstring . "`n"
				. TransA["Library name:"] 		. A_Space . v_SelectHotstringLibrary 
				, 10	;10 s timeout
	}
	
	;3. Remove selected row from List View.
	LV_Delete(SelectedRow)
	
	;4. Save List View into the library file.
	if (LibraryHeader)
		FileAppend, % LibraryHeader, % LibraryFullPathAndName, UTF-8
	FileAppend, % F_ConvertListViewIntoTxt(), % LibraryFullPathAndName, UTF-8
	
	;5. Decrement library counter.
	UpdateLibraryCounter(--v_LibHotstringCnt, --v_TotalHotstringCnt)
	
	;6. Remove from "Search" tables. Unfortunately index (SelectedRow) is sufficient only for one table, and in Searching there is "super table" containing all definitions from all available tables.
	for key, val in a_Triggerstring
		if (val == triggerstring)
		{
			a_Library			.RemoveAt(key)
			a_Triggerstring	.RemoveAt(key)
			a_TriggerOptions	.RemoveAt(key)
			a_OutputFunction	.RemoveAt(key)
			a_EnableDisable	.RemoveAt(key)
			a_Hotstring		.RemoveAt(key)
			a_Comment			.RemoveAt(key)
		}
	;7. Recreate triggerstring tips.
	F_Recreate_CombinedTable()
	F_Sort_a_Triggers(a_Combined, ini_TipsSortAlphabetically, ini_TipsSortByLength)	
	F_GuiHS3_EnDis("Enable")			;Enable all GuiControls for deletion time d(t, o, h)
	MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["The definition"] . ":" . "`n`n"
			. TransA["Triggerstring"] . ":" 	. A_Space . v_Triggerstring . "`n" 
			. TransA["options"] . ":" 		. A_Space . OldOptions . "`n"
			. TransA["hotstring"] . ":" 		. A_Space . hotstring . "`n`n"
			. TransA["was just deleted from"] . "`n`n"
			. TransA["Library name:"] 		. A_Space . v_SelectHotstringLibrary
			, 10	;10 s timeout
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_ConvertListViewIntoTxt()
{
	local txt := "", txt1 := "", txt2 := "", txt3 := "", txt4 := "", txt5 := "", txt6 := ""
	Loop, % LV_GetCount()
	{
		LV_GetText(txt1, A_Index, 3)	;options
		LV_GetText(txt2, A_Index, 2)	;triggerstring
		LV_GetText(txt3, A_Index, 4)	;function
		LV_GetText(txt4, A_Index, 1)	;EnDis
		LV_GetText(txt5, A_Index, 5)	;hotstring
		LV_GetText(txt6, A_Index, 6)	;comment
		txt .= txt1 . c_TextDelimiter . txt2 . c_TextDelimiter . txt3 . c_TextDelimiter . txt4 . c_TextDelimiter . txt5 . c_TextDelimiter . txt6 . "`n"	;library file format: options‖triggerstring‖function‖EnDis‖hotstring‖comment
	}
	return txt
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_ToggleRightColumn() ;Label of Button IdButton5, to toggle left part of gui
{
	global 	;assume-global mode
	local 	WinX := 0, WinY := 0
	
	Switch F_WhichGui()
	{
		Case "HS3":
			WinGetPos, WinX, WinY, , , % "ahk_id" . HS3GuiHwnd
			Gui, HS3: Submit, NoHide
			Gui, HS4: Default
			F_UpdateSelHotLibDDL()
			GuiControl,, % IdEdit1b, % v_Triggerstring
			GuiControl,, % IdEdit2b, % v_EnterHotstring
			GuiControl, ChooseString, % IdDDL2b, % v_SelectHotstringLibrary
			Gui, HS3: Show, Hide
			HS4GuiSize(GuiHwnd := HS4GuiHwnd, EventInfo := 0, Width := LeftColumnW + c_ymarg + c_WofMiddleButton, Height := ini_Sandbox ? LeftColumnH + 2 * c_ymarg + c_HofText + c_HofSandbox : LeftColumnH + 2 * c_ymarg + c_HofText)
			Gui, HS4: Show, % "X" . WinX . A_Space . "Y" . WinY . A_Space . "AutoSize"
			F_HS4RadioCaseGroup(v_RadioCaseGroup)
			ini_WhichGui := "HS4"
		Case "HS4":
			WinGetPos, WinX, WinY, , , % "ahk_id" . HS4GuiHwnd
			Gui, HS4: Submit, NoHide
			Gui, HS3: Default
			F_UpdateSelHotLibDDL()
			GuiControl,, % IdEdit1, % v_Triggerstring
			GuiControl,, % IdEdit2, % v_EnterHotstring
			GuiControl, ChooseString, % IdDDL2, % v_SelectHotstringLibrary
			Gui, HS4: Show, Hide
			Gui, HS3: Show, % "X" WinX . A_Space . "Y" WinY . A_Space . "AutoSize"
			F_HS3RadioCaseGroup(v_RadioCaseGroup)
			ini_WhichGui := "HS3"
	}
	if (ini_WhichGui = "HS3")
		Menu, ConfGUI, Check, 	% TransA["Toggle main GUI"] . "`tF4"
	else
		Menu, ConfGUI, UnCheck, % TransA["Toggle main GUI"] . "`tF4"
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
HS4GuiSize(GuiHwnd, EventInfo, Width, Height) ;Gui event (automatically generated)
{
	global 	;assume-global mode of operation
	local	xNext := 0, yNext := 0, hNext := 0

	; OutputDebug, 	% A_ThisFunc . A_Space . "EventInfo:" . A_Space . EventInfo . "`n"
	HS4_GuiWidth  	:= Width	;used by F_SaveGUIPos() Width 	is local variable, HS4_GuiWidth 	is global
,	HS4_GuiHeight 	:= Height	;used by F_SaveGUIPos() Height	is local variable, HS4_GuiHeight 	is global

	Switch EventInfo
	{
		Case 1: ini_WhichGui := "HS4"		;The window has been minimized.
		Default:
			xNext := LeftColumnW
,			yNext := c_ymarg
,			hNext := Height - 2 * c_ymarg 
			GuiControl, MoveDraw, % IdButton5b, % "x" . xNext . "y" . yNext . "h" . hNext 
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_GuiHS3_LVcolumnScale()
{ ;future: https://www.autohotkey.com/board/topic/30486-listview-tooltip-on-mouse-hover/
	global ;assume-global mode
	local OutVarTemp := 0, OutVarTempX := 0, OutVarTempY := 0, OutVarTempW := 0, OutVarTempH := 0 ;Within a function, to create a set of variables that is local instead of global, declare OutputVar as a local variable prior to using command GuiControlGet, Pos. However, it is often also necessary to declare each variable in the set, due to a common source of confusion.		
		, c1 := 0, c2 := 0, c3 := 0, c4 := 0, c5 := 0, c6 := 0, LVM_GETCOLUMNWIDTH = 0x1000 + 29 ;https://www.autohotkey.com/boards/viewtopic.php?p=25857#p25857
		, SM_CXVSCROLL := 2, WidthVerScrollBar := 0 ;Width of a vertical scroll bar, in pixels
		, ListViewWidth := 0, TheRest := 0

	SysGet, WidthVerScrollBar, % SM_CXVSCROLL ;returns value 26
	Gui, HS3: -DPIScale	;switch off dpiscale temporarily to get the same values from SendMessage command
	GuiControlGet, OutVarTemp, Pos, % IdListView1 ;This line will be used for "if" and "else" statement.	
	ListViewWidth := OutVarTempW

	LV_ModifyCol(1, "AutoHdr" . A_Space . "Center", TransA["En/Dis"])	;EnDis
	SendMessage, LVM_GETCOLUMNWIDTH, 0, 0, , ahk_id %IdListView1%	;columns are counted from 0 (not from 1); result (column width) is returned within ErrorLevel system variable
	c1 := ErrorLevel
	LV_ModifyCol(3, "AutoHdr" . A_Space . "Center", TransA["Trigger Opt."])	;Trigg Opt
	SendMessage, LVM_GETCOLUMNWIDTH, 2, 0, , ahk_id %IdListView1%
	c3 := ErrorLevel
	LV_ModifyCol(4, "AutoHdr" . A_Space . "Center", TransA["Out. Fun."])	;Out Fun
	SendMessage, LVM_GETCOLUMNWIDTH, 3, 0, , ahk_id %IdListView1%
	c4 := ErrorLevel

	TheRest := ListViewWidth - (c1 + c3 + c4 + WidthVerScrollBar + 4)
	LV_ModifyCol(2, TheRest / 3 . A_Space . "Left", TransA["Triggerstring"])
	LV_ModifyCol(5, TheRest / 3 . A_Space . "Left", TransA["Hotstring"])
	LV_ModifyCol(6, TheRest / 3 . A_Space . "Left", TransA["Comment"])
	Gui, HS3: +DPIScale
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_GuiHS3_Resize2(Width, Height)	;if (ini_Sandbox) and (!SbAtLeft)
{
	global ;assume-global mode
	local OutVarTemp := 0, OutVarTempX := 0, OutVarTempY := 0, OutVarTempW := 0, OutVarTempH := 0 ;Within a function, to create a set of variables that is local instead of global, declare OutputVar as a local variable prior to using command GuiControlGet, Pos. However, it is often also necessary to declare each variable in the set, due to a common source of confusion.	
		,xNext := 0, yNext := 0, wNext := 0, hNext := 0

	; OutputDebug, % A_ThisFunc . "`n"
	;Place TABLE (ListView)
	xNext := LeftColumnW + c_WofMiddleButton + c_xmarg
,	yNext := c_ymarg + c_HofText
,	wNext := Width - (2 * c_xmarg + LeftColumnW + c_WofMiddleButton)
,	hNext := Height - (c_ymarg + c_HofText + c_ymarg + c_HofText + c_HofSandbox + c_ymarg)
	GuiControl, MoveDraw, % IdListView1, % "x" . xNext . "y" . yNext . "w" . wNext . "h" . hNext

	;Place SANDBOX LABEL + info
	xNext := LeftColumnW + c_xmarg + c_WofMiddleButton
,	yNext := Height - (c_ymarg + c_HofText + c_HofSandbox)
	GuiControl, MoveDraw, % IdText10, % "x" . xNext . "y" . yNext
	GuiControlGet, OutVarTemp, Pos, % IdText10
	xNext := OutVarTempX + OutVarTempW + c_xmarg
	GuiControl, MoveDraw, % IdTextInfo17, % "x" . xNext . "y" . yNext

	;Place SANDBOX
	GuiControlGet, OutVarTemp, Pos, % IdText10
	xNext := OutVarTempX
,	yNext := OutVarTempY + OutVarTempH
,	wNext := Width - (2 * c_xmarg + LeftColumnW + c_WofMiddleButton)
	GuiControl, MoveDraw, % IdEdit10, % "x" . xNext . "y" . yNext . "w" . wNext

	;PLACE MB (Middle Button)
	xNext := LeftColumnW
,	yNext := c_ymarg
,	hNext := Height - 2 * c_ymarg 
	GuiControl, MoveDraw, % IdButton5, % "x" . xNext . "y" . yNext . "h" . hNext 

	F_GuiHS3_LVcolumnScale()
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_GuiHS3_Resize4(Width, Height)	;(ini_Sandbox) and (SbAtLeft)
{
	global ;assume-global mode
	local wNext := 0, hNext := 0
	
	; OutputDebug, % A_ThisFunc . "`n"
	;Place TABLE (ListView)
	xNext := LeftColumnW + c_WofMiddleButton + c_xmarg
,	yNext := c_ymarg + c_HofText
,	wNext := Width - (2 * c_xmarg + LeftColumnW + c_WofMiddleButton)
,	hNext := Height - (c_ymarg + c_HofText + c_ymarg)
	GuiControl, MoveDraw, % IdListView1, % "x" . xNext . "y" . yNext . "w" . wNext . "h" . hNext

	;Place SANDBOX LABEL + info
	xNext := c_xmarg
,	yNext := LeftColumnH + c_ymarg
	GuiControl, MoveDraw, % IdText10, % "x" . xNext . "y" . yNext
	GuiControlGet, OutVarTemp, Pos, % IdText10
	xNext := OutVarTempX + OutVarTempW + c_xmarg
	GuiControl, MoveDraw, % IdTextInfo17, % "x" . xNext . "y" . yNext
	
	;Place SANDBOX
	xNext := c_xmarg
,	yNext := LeftColumnH + c_ymarg + c_HofText
,	wNext := LeftColumnW - 2 * c_ymarg
	GuiControl, MoveDraw, % IdEdit10, % "x" . xNext . "y" . yNext . "w" . wNext

	;PLACE MB (Middle Button)
	xNext := LeftColumnW
,	yNext := c_ymarg
,	hNext := Height - 2 * c_ymarg 
	GuiControl, MoveDraw, % IdButton5, % "x" . xNext . "y" . yNext . "h" . hNext 

	F_GuiHS3_LVcolumnScale()
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_GuiHS3_Resize6(Width, Height)	;(!ini_Sandbox and !SbAtLeft)
{
	global ;assume-global mode
	local	xNext := 0, yNext := 0, wNext := 0, hNext := 0
		,	OutVarTemp := 0, 	OutVarTempX := 0, 	OutVarTempY := 0, 	OutVarTempW := 0, 	OutVarTempH := 0

	; OutputDebug, % A_ThisFunc . "`n"
	;Place TABLE (ListView)
	xNext := LeftColumnW + c_WofMiddleButton + c_xmarg
,	yNext := c_ymarg + c_HofText
,	wNext := Width - (2 * c_xmarg + LeftColumnW + c_WofMiddleButton)
,	hNext := Height - (c_ymarg + 2 * c_HofText + 2 * c_ymarg)
	GuiControl, MoveDraw, % IdListView1, % "x" . xNext . "y" . yNext . "w" . wNext . "h" . hNext

	;Place SANDBOX LABEL + info
	xNext := LeftColumnW + c_WofMiddleButton + c_xmarg
,	yNext := Height - (c_ymarg + c_HofText)
	GuiControl, MoveDraw, % IdText10, % "x" . xNext . "y" . yNext
	GuiControlGet, OutVarTemp, Pos, % IdText10
	xNext := OutVarTempX + OutVarTempW + c_xmarg
	GuiControl, MoveDraw, % IdTextInfo17, % "x" . xNext . "y" . yNext

	;Place SANDBOX (void)

	;PLACE MB (Middle Button)
	xNext := LeftColumnW
,	yNext := c_ymarg
,	hNext := Height - 2 * c_ymarg 
	GuiControl, MoveDraw, % IdButton5, % "x" . xNext . "y" . yNext . "h" . hNext 

	F_GuiHS3_LVcolumnScale()
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_GuiHS3_Resize8(Width, Height)	;(!ini_Sandbox and SbAtLeft)
{
	global ;assume-global mode
	local	xNext := 0, yNext := 0, wNext := 0, hNext := 0
		,	OutVarTemp := 0, 	OutVarTempX := 0, 	OutVarTempY := 0, 	OutVarTempW := 0, 	OutVarTempH := 0

	; OutputDebug, % A_ThisFunc . "`n"
	;Place TABLE (ListView)
	xNext := LeftColumnW + c_WofMiddleButton + c_xmarg
,	yNext := c_ymarg + c_HofText
,	wNext := Width - (2 * c_xmarg + LeftColumnW + c_WofMiddleButton)
,	hNext := Height - (c_ymarg + c_HofText + c_ymarg)
	GuiControl, MoveDraw, % IdListView1, % "x" . xNext . "y" . yNext . "w" . wNext . "h" . hNext

	;Place SANDBOX LABEL + info
	xNext := c_ymarg
,	yNext := LeftColumnH + c_ymarg
	GuiControl, MoveDraw, % IdText10, % "x" . xNext . "y" . yNext
	GuiControlGet, OutVarTemp, Pos, % IdText10
	xNext := OutVarTempX + OutVarTempW + c_xmarg
	GuiControl, MoveDraw, % IdTextInfo17, % "x" . xNext . "y" . yNext

	;Place SANDBOX (void)

	;Place MB (Middle Button)
	xNext := LeftColumnW
,	yNext := c_ymarg
,	hNext := Height - 2 * c_ymarg 
	GuiControl, MoveDraw, % IdButton5, % "x" . xNext . "y" . yNext . "h" . hNext 
	
	F_GuiHS3_LVcolumnScale()
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
HS3GuiSize(GuiHwnd, EventInfo, Width, Height) ;Gui event (automatically generated)
{	;This function toggles static flag f_SbAtLeft
	global 	;assume-global mode of operation
	static	f_SbAtLeft := false

	; OutputDebug, 	% A_ThisFunc . A_Space . "EventInfo:" . A_Space . EventInfo . "`n"
	HS3_GuiWidth  	:= Width	;used by F_SaveGUIPos() Width 	is local variable, HS3_GuiWidth 	is global
,	HS3_GuiHeight 	:= Height	;used by F_SaveGUIPos() Height	is local variable, HS3_GuiHeight 	is global

	Switch EventInfo
	{
		Case 1: 
			ini_HS3GuiMaximized := false
,			ini_WhichGui 		:= "HS3"		;The window has been minimized.
			Critical, Off
			Sleep, -1

		Case 2: 
			ini_HS3GuiMaximized 	:= true		;The window has been maximized.
			if (ini_Sandbox)
			{
				if (Height < LeftColumnH + 2 * c_ymarg + c_HofText + c_HofSandbox)
				{
					f_SbAtLeft := false
					F_GuiHS3_Resize2(Width, Height)
					return
				}
				else	;if (Height >= LeftColumnH + 2 * c_ymarg + c_HofText + c_HofSandbox)
				{
					f_SbAtLeft := true
					F_GuiHS3_Resize4(Width, Height)
					return
				}
			}
			else		;(!iniSandbox)
			{
				if (Height < LeftColumnH + c_ymarg + c_HofText + c_ymarg)
				{
					f_SbAtLeft := false
					F_GuiHS3_Resize6(Width, Height)
					return
				}
				else	;if (Height > LeftColumnH + c_ymarg + c_HofText)
				{
					f_SbAtLeft := true
					F_GuiHS3_Resize8(Width, Height)
					return
				}
			}
		Default:	;E.G. window has been restored
			ini_HS3GuiMaximized := false
			if (ini_Sandbox)
			{
				if (Height < LeftColumnH + 2 * c_ymarg + c_HofText + c_HofSandbox)
				{
					f_SbAtLeft := false
					F_GuiHS3_Resize2(Width, Height)
					return
				}
				else	;if (Height >= LeftColumnH + 2 * c_ymarg + c_HofText + c_HofSandbox)
				{
					f_SbAtLeft := true
					F_GuiHS3_Resize4(Width, Height)
					return
				}
			}
			else		;(!iniSandbox)
			{
				if (Height < LeftColumnH + c_ymarg + c_HofText + c_ymarg)
				{
					f_SbAtLeft := false
					F_GuiHS3_Resize6(Width, Height)
					return
				}
				else	;if (Height > LeftColumnH + c_ymarg + c_HofText)
				{
					f_SbAtLeft := true
					F_GuiHS3_Resize8(Width, Height)
					return
				}
			}
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_SelectLibrary()
{
	global 	;assume-global mode
	local	key := 0, value := "", name := "", str1 := []
	
	Gui, % F_WhichGui() . ":" . A_Space . "Submit", NoHide
	Gui, HS3: Default			;All of the ListView function operate upon the current default GUI window.
	LV_Delete()
	v_LibHotstringCnt 	:= 0
,	name 			:= SubStr(v_SelectHotstringLibrary, 1, -4)
	for key, value in a_Library
	{
		if (value = name)
		{
			str1[1] := a_EnableDisable[key]
,			str1[2] := a_Triggerstring[key]
,			str1[3] := a_TriggerOptions[key]
,			str1[4] := a_OutputFunction[key]
,			str1[5] := a_Hotstring[key]
,			str1[6] := a_Comment[key]
			LV_Add("", str1[1], str1[2], str1[3], str1[4], str1[5], str1[6])
			v_LibHotstringCnt++
		}
	}
	UpdateLibraryCounter(v_LibHotstringCnt, v_TotalHotstringCnt)
	GuiControl, +Redraw, % IdListView1 ;Afterward, use GuiControl, +Redraw to re-enable redrawing (which also repaints the control).
	LV_ModifyCol(2, "Sort")	;without this line content of library is loaded in the same order as it was saved last time; keep in mind that after any change (e.g. change of exiting definition) the whole file is sorted and saved again
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_HSLV() ; copy content of List View 1 to editable fields of HS3 Gui
{
	global	;assume global mode of operation
	Critical, On
	; OutputDebug, % "A_ThisFunc:" . A_Space . A_ThisFunc . A_Tab . "A_GuiEvent:" . A_Space . A_GuiEvent . A_Tab . "A_GuiControl:" . A_Space . A_GuiControl . A_Tab . "A_EventInfo:" . A_Space . A_EventInfo . A_Tab . "ErrorLevel:" . A_Space . ErrorLevel . "`n"
	Switch A_GuiEvent
	{
		Default:
			Critical, Off
			return
		Case "Normal", "C":		
			F_LV1_CopyContentToHS3()
			GuiControl, Focus, % IdListView1
	}
	Critical, Off
}	
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_LV1_EnDisDefinition()
{
	global	;a_Triggerstring, a_TriggerOptions, a_EnableDisable, a_Combined, a_Hotstring, ini_TipsSortAlphabetically, ini_TipsSortByLength, v_SelectHotstringLibrary ;assume-global mode of operation
	local	EnDis := "", SelectedRow := 0, OnOffToggle := false, Triggerstring := "", Options := "", key := 0, value := "", index := 0, Temp1 := "", vHotstring := "", SendFun := "", Oflag := false, TheWholeFile	:= "", LibraryHeader := ""

	F_GuiHS3_EnDis("Disable")
	Gui, HS3: Default	;in order to activate ListView
	if !(SelectedRow := LV_GetNext())
		return
	LV_GetText(EnDis, 			SelectedRow, 	1)
	Switch EnDis
	{
		Case "En":
			OnOffToggle 	:= false	;reverse logic
,			EnDis		:= "Dis"
		Case "Dis":
			OnOffToggle 	:= true	;reverse logic
,			EnDis		:= "En"
	}
	LV_GetText(Triggerstring, 	SelectedRow, 	2)
	LV_GetText(Options, 		SelectedRow, 	3)
	LV_GetText(SendFun,			SelectedRow, 	4)
	LV_GetText(vHotstring, 		SelectedRow, 	5)

	if (EnDis = "Dis")	;;the following lines are necessary for the scenario when definition is swtiched off in one library and created with different set of options in another one.
	{
		if (InStr(Options, "*"))
			Options := StrReplace(Options, "*", "*0")
		if (InStr(Options, "B0"))
			Options := StrReplace(Options, "B0", "B")
		if (InStr(Options, "Z"))
			Options := StrReplace(Options, "Z", "Z0")
	}

	;1. Modify Hotstring definition
	; OutputDebug, % "Options:" . Options . A_Space . "Triggerstring:" . Triggerstring . A_Space . "OnOffToggle:" . OnOffToggle . "`n"
	if (InStr(Options, "O"))
	{
		if (SendFun = "SI") or (SendFun = "SE") or (SendFun = "SP") or (SendFun = "SR") or (SendFun = "CL") or (SendFun = "S1") or (SendFun = "S2")
		{
			Try
				Hotstring(":" . Options . ":" . Triggerstring, func("F_SimpleOutput").bind(vHotstring, true, SendFun), OnOffToggle)
			Catch
				MsgBox, 16, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["Error"], % A_ThisFunc . A_Space . TransA["Something went wrong with (triggerstring, hotstring) creation"] . ":" . "`n`n"
					. "Hotstring(:" . Options . ":" . Triggerstring . "," . A_Space . "func(""SimpleOutput"").bind(" . vHotstring . "," . A_Space . true . "," . A_Space . SendFun . ")," . A_Space . OnOffToggle . ")"
					. "`n`n" . TransA["Library name:"] . A_Tab . v_SelectHotstringLibrary
		}
		if (SendFun = "MSI") or (SendFun = "MCL")
		{
			Try
				Hotstring(":" . Options . ":" . Triggerstring, func("F_HMenu_Output").bind(vHotstring, true, SendFun), OnOffToggle)
			Catch
				MsgBox, 16, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["Error"], % A_ThisFunc . A_Space . TransA["Something went wrong with (triggerstring, hotstring) creation"] . ":" . "`n`n"
					. "Hotstring(:" . Options . ":" . Triggerstring . "," . A_Space . "func(""F_HMenu_Output"").bind(" . vHotstring . "," . A_Space . true . A_Space . SendFun . ")," . A_Space . OnOffToggle . ")"
					. "`n`n" . TransA["Library name:"] . A_Tab . v_SelectHotstringLibrary
		}
		if (SendFun = "P")
		{
			Try
				Hotstring(":" . Options . ":" . Triggerstring, func("F_PictureShow").bind(vHotstring, true, SendFun), OnOffToggle)
			Catch
				MsgBox, 16, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["Error"], % A_ThisFunc . A_Space . TransA["Something went wrong with (triggerstring, hotstring) creation"] . ":" . "`n`n"
					. "Hotstring(:" . Options . ":" . Triggerstring . "," . A_Space . "func(""F_PictureShow"").bind(" . vHotstring . "," . A_Space . true . A_Space . SendFun . ")," . A_Space . OnOffToggle . ")"
					. "`n`n" . TransA["Library name:"] . A_Tab . v_SelectHotstringLibrary
		}
		if (SendFun = "R")
		{
			Try
				Hotstring(":" . Options . ":" . Triggerstring, func("F_RunApplication").bind(vHotstring, true, SendFun), OnOffToggle)
			Catch
				MsgBox, 16, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["Error"], % A_ThisFunc . A_Space . TransA["Something went wrong with (triggerstring, hotstring) creation"] . ":" . "`n`n"
					. "Hotstring(:" . Options . ":" . Triggerstring . "," . A_Space . "func(""F_RunApplication"").bind(" . vHotstring . "," . A_Space . true . A_Space . SendFun . ")," . A_Space . OnOffToggle . ")"
					. "`n`n" . TransA["Library name:"] . A_Tab . v_SelectHotstringLibrary
		}
	}
	else
	{
		if (SendFun = "SI") or (SendFun = "SE") or (SendFun = "SP") or (SendFun = "SR") or (SendFun = "CL") or (SendFun = "S1") or (SendFun = "S2")
		{
			Try
				Hotstring(":" . Options . ":" . Triggerstring, func("F_SimpleOutput").bind(vHotstring, false, SendFun), OnOffToggle)
			Catch
				MsgBox, 16, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["Error"], % A_ThisFunc . A_Space . TransA["Something went wrong with (triggerstring, hotstring) creation"] . ":" . "`n`n"
					. "Hotstring(:" . Options . ":" . Triggerstring . "," . A_Space . "func(""F_SimpleOutput"").bind(" . vHotstring . "," . A_Space . false . "," . A_Space . SendFun . ")," . A_Space . OnOffToggle . ")"
					. "`n`n" . TransA["Library name:"] . A_Tab . v_SelectHotstringLibrary
		}
		if (SendFun = "MSI") or (SendFun = "MCL")
		{
			Try
				Hotstring(":" . Options . ":" . Triggerstring, func("F_HMenu_Output").bind(vHotstring, false, SendFun), OnOffToggle)
			Catch
				MsgBox, 16, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["Error"], % A_ThisFunc . A_Space . TransA["Something went wrong with (triggerstring, hotstring) creation"] . ":" . "`n`n"
					. "Hotstring(:" . Options . ":" . Triggerstring . "," . A_Space . "func(""F_HMenu_Output"").bind(" . vHotstring . "," . A_Space . false . A_Space . SendFun . ")," . A_Space . OnOffToggle . ")"
					. "`n`n" . TransA["Library name:"] . A_Tab . v_SelectHotstringLibrary
		}
		if (SendFun = "P")
		{
			Try
				Hotstring(":" . Options . ":" . Triggerstring, func("F_PictureShow").bind(vHotstring, false, SendFun), OnOffToggle)
			Catch
				MsgBox, 16, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["Error"], % A_ThisFunc . A_Space . TransA["Something went wrong with (triggerstring, hotstring) creation"] . ":" . "`n`n"
					. "Hotstring(:" . Options . ":" . Triggerstring . "," . A_Space . "func(""F_PictureShow"").bind(" . vHotstring . "," . A_Space . false . A_Space . SendFun . ")," . A_Space . OnOffToggle . ")"
					. "`n`n" . TransA["Library name:"] . A_Tab . v_SelectHotstringLibrary
		}
		if (SendFun = "R")
		{
			Try
				Hotstring(":" . Options . ":" . Triggerstring, func("F_RunApplication").bind(vHotstring, false, SendFun), OnOffToggle)
			Catch
				MsgBox, 16, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["Error"], % A_ThisFunc . A_Space . TransA["Something went wrong with (triggerstring, hotstring) creation"] . ":" . "`n`n"
					. "Hotstring(:" . Options . ":" . Triggerstring . "," . A_Space . "func(""F_RunApplication"").bind(" . vHotstring . "," . A_Space . false . A_Space . SendFun . ")," . A_Space . OnOffToggle . ")"
					. "`n`n" . TransA["Library name:"] . A_Tab . v_SelectHotstringLibrary
		}
	}

	;2. Modify a_tables
	for key, value in a_Triggerstring
	{
		if (a_Triggerstring[key] = Triggerstring) and (a_Library[key] = SubStr(v_SelectHotstringLibrary, 1, -4))	;if matched within current library
			break
	}
	
	a_EnableDisable[key] := EnDis
	for index in a_Combined	;recreate array a_Combined
		a_Combined[index] := a_Triggerstring[index] . c_TextDelimiter . a_TriggerOptions[index] . c_TextDelimiter . a_EnableDisable[index] . c_TextDelimiter . a_Hotstring[index]
	F_Sort_a_Triggers(a_Combined, ini_TipsSortAlphabetically, ini_TipsSortByLength)
	;3. Modify content of ListView
	Loop, % LV_GetCount()
	{
		LV_GetText(Temp1, A_Index, 2)
		if (Temp1 = Triggerstring)	;non-case sensitive comparison
		{
			LV_Modify(A_Index, "Col1", EnDis)
			key := A_Index
			Break
		}
	}
	;4. Modify content of library file
	FileRead, TheWholeFile, % ini_HADL . "\" . v_SelectHotstringLibrary
	LibraryHeader 	:= F_ExtractHeader(TheWholeFile)
	if (LibraryHeader)
		LibraryHeader 	:= "/*`n" . LibraryHeader . "`n*/`n`n"
,		TheWholeFile	:= ""
	FileDelete, % ini_HADL . "\" . v_SelectHotstringLibrary	;delete library file. 
	if (LibraryHeader)
		FileAppend, % LibraryHeader, % ini_HADL . "\" . v_SelectHotstringLibrary, UTF-8	
	F_SaveLVintoLibFile()
	F_GuiHS3_EnDis("Enable")	;Enable all GuiControls
	GuiControl, Focus, % IdListView1
	LV_Modify(key, "Select" . A_Space . "Focus")
	MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . A_Space . TransA["information"], % TransA["New settings are now applied."], 10	;dissapears after 10 s
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_LV1_CopyContentToHS3()
{
	global ;v_EnDis ;assume-global mode of operation
	local Options := "", Fun := "", EnDis := "", vHotstring := "", OTextMenu := "", Comment := "", SelectedRow := 0

	if !(SelectedRow := LV_GetNext())
		return
	
	LV_GetText(v_Triggerstring, 	SelectedRow, 2)
	GuiControl, HS3:, % IdEdit1, % v_Triggerstring
	GuiControl, HS4:, % IdEdit1, % v_Triggerstring
	LV_GetText(Options, 		SelectedRow, 3)
	if (InStr(Options, "*"))
	{
		Gui, HS3: Font, % "s" . c_FontSize . A_Space . "cGreen Norm", % c_FontType
		Gui, HS4: Font, % "s" . c_FontSize . A_Space . "cGreen Norm", % c_FontType
		GuiControl, HS3: Font, % IdCheckBox1
		GuiControl, HS4: Font, % IdCheckBox1b
		GuiControl, HS3:, % IdCheckBox1, 	1
		GuiControl, HS4:, % IdCheckBox1b, 	1
		Gui, HS3: Font, % "s" . c_FontSize . A_Space . "c" . c_FontColor . A_Space . "Norm", % c_FontType
		Gui, HS4: Font, % "s" . c_FontSize . A_Space . "c" . c_FontColor . A_Space . "Norm", % c_FontType
	}
	else
	{
		Gui, HS3: Font, % "s" . c_FontSize . A_Space . "c" . c_FontColor . A_Space . "Norm", % c_FontType
		Gui, HS4: Font, % "s" . c_FontSize . A_Space . "c" . c_FontColor . A_Space . "Norm", % c_FontType
		GuiControl, HS3: Font, % IdCheckBox1
		GuiControl, HS4: Font, % IdCheckBox1b
		GuiControl, HS3:, % IdCheckBox1, 	0
		GuiControl, HS4:, % IdCheckBox1b, 	0
	}
	if (InStr(Options, "C"))
	{
		Gui, HS3: Font, % "s" . c_FontSize . A_Space . "cGreen Norm", % c_FontType
		Gui, HS4: Font, % "s" . c_FontSize . A_Space . "cGreen Norm", % c_FontType
		GuiControl, HS3: Font, % TransA["Case Sensitive (C)"]
		GuiControl, HS4: Font, % TransA["Case Sensitive (C)"]
		GuiControl, HS3:, % TransA["Case Sensitive (C)"], 1
		GuiControl, HS4:, % TransA["Case Sensitive (C)"], 1
		Gui, HS3: Font, % "s" . c_FontSize . A_Space . "c" . c_FontColor . A_Space . "Norm", % c_FontType
		Gui, HS4: Font, % "s" . c_FontSize . A_Space . "c" . c_FontColor . A_Space . "Norm", % c_FontType
	}
	if (InStr(Options, "C1"))
	{
		Gui, HS3: Font, % "s" . c_FontSize . A_Space . "cGreen Norm", % c_FontType
		Gui, HS4: Font, % "s" . c_FontSize . A_Space . "cGreen Norm", % c_FontType
		GuiControl, HS3: Font, % TransA["Not Case-Conforming (C1)"]
		GuiControl, HS4: Font, % TransA["Not Case-Conforming (C1)"]
		GuiControl, HS3:, % TransA["Not Case-Conforming (C1)"], 1
		GuiControl, HS4:, % TransA["Not Case-Conforming (C1)"], 1
		Gui, HS3: Font, % "s" . c_FontSize . A_Space . "c" . c_FontColor . A_Space . "Norm", % c_FontType
		Gui, HS4: Font, % "s" . c_FontSize . A_Space . "c" . c_FontColor . A_Space . "Norm", % c_FontType
	}
	if (InStr(Options, "C2"))
		{
			Gui, HS3: Font, % "s" . c_FontSize . A_Space . "cGreen Norm", % c_FontType
			Gui, HS4: Font, % "s" . c_FontSize . A_Space . "cGreen Norm", % c_FontType
			GuiControl, HS3: Font, % TransA["Capitalize each word (C2)"]
			GuiControl, HS4: Font, % TransA["Capitalize each word (C2)"]
			GuiControl, HS3:, % TransA["Capitalize each word (C2)"], 1
			GuiControl, HS4:, % TransA["Capitalize each word (C2)"], 1
			Gui, HS3: Font, % "s" . c_FontSize . A_Space . "c" . c_FontColor . A_Space . "Norm", % c_FontType
			Gui, HS4: Font, % "s" . c_FontSize . A_Space . "c" . c_FontColor . A_Space . "Norm", % c_FontType
		}
	if (!InStr(Options, "C1")) and (!InStr(Options, "C")) and (!InStr(Options, "C2"))
	{
		Gui, HS3: Font, % "s" . c_FontSize . A_Space . "c" . c_FontColor . A_Space . "Norm", % c_FontType
		Gui, HS4: Font, % "s" . c_FontSize . A_Space . "c" . c_FontColor . A_Space . "Norm", % c_FontType
		GuiControl, HS3: Font, % TransA["Case Sensitive (C)"]
		GuiControl, HS4: Font, % TransA["Case Sensitive (C)"]
		GuiControl, HS3: Font, % TransA["Case-Conforming"]
		GuiControl, HS4: Font, % TransA["Case-Conforming"]
		GuiControl, HS3: Font, % TransA["Not Case-Conforming (C1)"]
		GuiControl, HS4: Font, % TransA["Not Case-Conforming (C1)"]
		GuiControl, HS3: Font, % TransA["Capitalize each word (C2)"]
		GuiControl, HS4: Font, % TransA["Capitalize each word (C2)"]
		GuiControl, HS3:, % TransA["Case-Conforming"], 1
		GuiControl, HS4:, % TransA["Case-Conforming"], 1
	}
	if (InStr(Options, "B0"))
	{
		Gui, HS3: Font, % "s" . c_FontSize . A_Space . "cGreen Norm", % c_FontType
		Gui, HS4: Font, % "s" . c_FontSize . A_Space . "cGreen Norm", % c_FontType
		GuiControl, HS3: Font, % IdCheckBox3
		GuiControl, HS4: Font, % IdCheckBox3b
		GuiControl, HS3:, % IdCheckBox3, 	1
		GuiControl, HS4:, % IdCheckBox3b, 	1
		Gui, HS3: Font, % "s" . c_FontSize . A_Space . "c" . c_FontColor . A_Space . "Norm", % c_FontType
		Gui, HS4: Font, % "s" . c_FontSize . A_Space . "c" . c_FontColor . A_Space . "Norm", % c_FontType
	}
	else
	{
		Gui, HS3: Font, % "s" . c_FontSize . A_Space . "c" . c_FontColor . A_Space . "Norm", % c_FontType
		Gui, HS4: Font, % "s" . c_FontSize . A_Space . "c" . c_FontColor . A_Space . "Norm", % c_FontType
		GuiControl, HS3: Font, % IdCheckBox3
		GuiControl, HS4: Font, % IdCheckBox3b
		GuiControl, HS3:, % IdCheckBox3, 	0
		GuiControl, HS4:, % IdCheckBox3b, 	0
	}
	if (InStr(Options, "?"))
	{
		Gui, HS3: Font, % "s" . c_FontSize . A_Space . "cGreen Norm", % c_FontType
		Gui, HS4: Font, % "s" . c_FontSize . A_Space . "cGreen Norm", % c_FontType
		GuiControl, HS3: Font, % IdCheckBox4
		GuiControl, HS4: Font, % IdCheckBox4b
		GuiControl, HS3:, % IdCheckBox4, 	1
		GuiControl, HS4:, % IdCheckBox4b, 	1
		Gui, HS3: Font, % "s" . c_FontSize . A_Space . "c" . c_FontColor . A_Space . "Norm", % c_FontType
		Gui, HS4: Font, % "s" . c_FontSize . A_Space . "c" . c_FontColor . A_Space . "Norm", % c_FontType
	}
	else
	{
		Gui, HS3: Font, % "s" . c_FontSize . A_Space . "c" . c_FontColor . A_Space . "Norm", % c_FontType
		Gui, HS4: Font, % "s" . c_FontSize . A_Space . "c" . c_FontColor . A_Space . "Norm", % c_FontType
		GuiControl, HS3: Font, % IdCheckBox4
		GuiControl, HS4: Font, % IdCheckBox4b
		GuiControl, HS3:, % IdCheckBox4, 	0
		GuiControl, HS4:, % IdCheckBox4b, 	0
	}
	if (InStr(Options, "O"))
	{
		Gui, HS3: Font, % "s" . c_FontSize . A_Space . "cGreen Norm", % c_FontType
		Gui, HS4: Font, % "s" . c_FontSize . A_Space . "cGreen Norm", % c_FontType
		GuiControl, HS3: Font, % IdCheckBox5
		GuiControl, HS4: Font, % IdCheckBox5b
		GuiControl, HS3:, % IdCheckBox5, 	1
		GuiControl, HS4:, % IdCheckBox5b, 	1
		Gui, HS3: Font, % "s" . c_FontSize . A_Space . "c" . c_FontColor . A_Space . "Norm", % c_FontType
		Gui, HS4: Font, % "s" . c_FontSize . A_Space . "c" . c_FontColor . A_Space . "Norm", % c_FontType
	}
	else
	{
		Gui, HS3: Font, % "s" . c_FontSize . A_Space . "c" . c_FontColor . A_Space . "Norm", % c_FontType
		Gui, HS4: Font, % "s" . c_FontSize . A_Space . "c" . c_FontColor . A_Space . "Norm", % c_FontType
		GuiControl, HS3: Font, % IdCheckBox5
		GuiControl, HS4: Font, % IdCheckBox5b
		GuiControl, HS3:, % IdCheckBox5, 	0
		GuiControl, HS4:, % IdCheckBox5b, 	0
	}
	if (InStr(Options, "Z"))
	{
		Gui, HS3: Font, % "s" . c_FontSize . A_Space . "cGreen Norm", % c_FontType
		Gui, HS4: Font, % "s" . c_FontSize . A_Space . "cGreen Norm", % c_FontType
		GuiControl, HS3: Font, % IdCheckBox8
		GuiControl, HS4: Font, % IdCheckBox8b
		GuiControl, HS3:, % IdCheckBox8,  1
		GuiControl, HS4:, % IdCheckBox8b, 1
		Gui, HS3: Font, % "s" . c_FontSize . A_Space . "c" . c_FontColor . A_Space . "Norm", % c_FontType
		Gui, HS4: Font, % "s" . c_FontSize . A_Space . "c" . c_FontColor . A_Space . "Norm", % c_FontType
	}
	else
	{
		Gui, HS3: Font, % "s" . c_FontSize . A_Space . "c" . c_FontColor . A_Space . "Norm", % c_FontType
		Gui, HS4: Font, % "s" . c_FontSize . A_Space . "c" . c_FontColor . A_Space . "Norm", % c_FontType
		GuiControl, HS3: Font, % IdCheckBox8
		GuiControl, HS4: Font, % IdCheckBox8b
		GuiControl, HS3:, % IdCheckBox8,  0
		GuiControl, HS4:, % IdCheckBox8b, 0
	}
	
	LV_GetText(Fun, 			SelectedRow, 4)
	Switch Fun
	{
		Case "SI":	;SendFun := "F_Simple_Output"
			GuiControl, HS3: ChooseString, % IdDDL1, 	SendInput (SI)
			GuiControl, HS4: ChooseString, % IdDDL1b, 	SendInput (SI)
		Case "CL":	;SendFun := "F_Simple_Output"
			GuiControl, HS3: ChooseString, % IdDDL1, 	Clipboard (CL)
			GuiControl, HS4: ChooseString, % IdDDL1b, 	Clipboard (CL)
		Case "MCL":	;SendFun := "F_HMenu_Output"
			GuiControl, HS3: ChooseString, % IdDDL1, 	Menu & Clipboard (MCL)
			GuiControl, HS4: ChooseString, % IdDDL1b, 	Menu & Clipboard (MCL)
		Case "MSI":	;SendFun := "F_HMenu_Output"
			GuiControl, HS3: ChooseString, % IdDDL1, 	Menu & SendInput (MSI)
			GuiControl, HS4: ChooseString, % IdDDL1b, 	Menu & SendInput (MSI)
		Case "SR":	;SendFun := "F_Simple_Output"
			GuiControl, HS3: ChooseString, % IdDDL1, 	SendRaw (SR)
			GuiControl, HS4: ChooseString, % IdDDL1b, 	SendRaw (SR)
		Case "SP":	;SendFun := "F_Simple_Output"
			GuiControl, HS3: ChooseString, % IdDDL1, 	SendPlay (SP)
			GuiControl, HS4: ChooseString, % IdDDL1b, 	SendPlay (SP)
		Case "SE":	;SendFun := "F_Simple_Output"
			GuiControl, HS3: ChooseString, % IdDDL1, 	SendEvent (SE)
			GuiControl, HS4: ChooseString, % IdDDL1b, 	SendEvent (SE)
		Case "S1":	;SendFun := "F_Simple_Output"
			GuiControl, HS3: ChooseString, % IdDDL1, 	% TransA["Special function 1 (S1)"]
			GuiControl, HS4: ChooseString, % IdDDL1b, 	% TransA["Special function 1 (S1)"]
		Case "S2":	;SendFun := "F_Simple_Output"
			GuiControl, HS3: ChooseString, % IdDDL1, 	% TransA["Special function 2 (S2)"]
			GuiControl, HS4: ChooseString, % IdDDL1b, 	% TransA["Special function 2 (S2)"]
		Case "P":		;SendFun := "F_PictureShow"
			GuiControl, HS3: ChooseString, % IdDDL1, 	% TransA["Picture (P)"]
			GuiControl, HS4: ChooseString, % IdDDL1b, 	% TransA["Picture (P)"]
		Case "R":		;SendFun := "F_RunApplication"
			GuiControl, HS3: ChooseString, % IdDDL1, 	% TransA["Run (R)"]
			GuiControl, HS4: ChooseString, % IdDDL1b, 	% TransA["Run (R)"]
	}
	
	LV_GetText(EnDis,		SelectedRow, 1)
	if (EnDis = "En")		;local variable
		v_EnDis := true	;global variable
	if (EnDis = "Dis")		;local variable
		v_EnDis := false	;global variable
	
	LV_GetText(vHotstring, 	SelectedRow, 5)
	if ((Fun = "MCL") or (Fun = "MSI"))
	{
		OTextMenu := StrSplit(vHotstring, c_MHDelimiter)
		GuiControl, HS3:, v_EnterHotstring,  % OTextMenu[1]
		GuiControl, HS4:, v_EnterHotstring,  % OTextMenu[1]
		GuiControl, HS3:, v_EnterHotstring1, % OTextMenu[2]
		GuiControl, HS4:, v_EnterHotstring1, % OTextMenu[2]
		GuiControl, HS3:, v_EnterHotstring2, % OTextMenu[3]
		GuiControl, HS4:, v_EnterHotstring2, % OTextMenu[3]
		GuiControl, HS3:, v_EnterHotstring3, % OTextMenu[4]
		GuiControl, HS4:, v_EnterHotstring3, % OTextMenu[4]
		GuiControl, HS3:, v_EnterHotstring4, % OTextMenu[5]
		GuiControl, HS4:, v_EnterHotstring4, % OTextMenu[5]
		GuiControl, HS3:, v_EnterHotstring5, % OTextMenu[6]
		GuiControl, HS4:, v_EnterHotstring5, % OTextMenu[6]
		GuiControl, HS3:, v_EnterHotstring6, % OTextMenu[7]
		GuiControl, HS4:, v_EnterHotstring6, % OTextMenu[7]
	}
	else
	{
		GuiControl, HS3:, v_EnterHotstring, % vHotstring
		GuiControl, HS4:, v_EnterHotstring, % vHotstring
	}
	
	LV_GetText(Comment, 	SelectedRow, 6)
	GuiControl, HS3:, v_Comment, %Comment%
	GuiControl, HS4:, v_Comment, %Comment%
	
	F_SelectFunction()
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_SelectFunction()
{
	global ;assume-global mode
	
	GuiControlGet, v_SelectFunction, % F_WhichGui() . ":" ;Retrieves the contents of the control. 
	
	if InStr(v_SelectFunction, "Menu")
	{
		GuiControl, HS3: Enable, v_EnterHotstring1
		GuiControl, HS4: Enable, v_EnterHotstring1
		GuiControl, HS3: Enable, v_EnterHotstring2
		GuiControl, HS4: Enable, v_EnterHotstring2
		GuiControl, HS3: Enable, v_EnterHotstring3
		GuiControl, HS4: Enable, v_EnterHotstring3
		GuiControl, HS3: Enable, v_EnterHotstring4
		GuiControl, HS4: Enable, v_EnterHotstring4
		GuiControl, HS3: Enable, v_EnterHotstring5
		GuiControl, HS4: Enable, v_EnterHotstring5
		GuiControl, HS3: Enable, v_EnterHotstring6
		GuiControl, HS4: Enable, v_EnterHotstring6
	}
	else
	{
		GuiControl, HS3:, v_EnterHotstring1 ;Puts new contents into the control. Value := "". Makes empty this control.
		GuiControl, HS4:, v_EnterHotstring1 ;Puts new contents into the control. Value := "". Makes empty this control.
		GuiControl, HS3:, v_EnterHotstring2
		GuiControl, HS4:, v_EnterHotstring2
		GuiControl, HS3:, v_EnterHotstring3
		GuiControl, HS4:, v_EnterHotstring3
		GuiControl, HS3:, v_EnterHotstring4
		GuiControl, HS4:, v_EnterHotstring4
		GuiControl, HS3:, v_EnterHotstring5
		GuiControl, HS4:, v_EnterHotstring5
		GuiControl, HS3:, v_EnterHotstring6
		GuiControl, HS4:, v_EnterHotstring6
		GuiControl, HS3: Disable, v_EnterHotstring1
		GuiControl, HS4: Disable, v_EnterHotstring1
		GuiControl, HS3: Disable, v_EnterHotstring2
		GuiControl, HS4: Disable, v_EnterHotstring2
		GuiControl, HS3: Disable, v_EnterHotstring3
		GuiControl, HS4: Disable, v_EnterHotstring3
		GuiControl, HS3: Disable, v_EnterHotstring4
		GuiControl, HS4: Disable, v_EnterHotstring4
		GuiControl, HS3: Disable, v_EnterHotstring5
		GuiControl, HS4: Disable, v_EnterHotstring5
		GuiControl, HS3: Disable, v_EnterHotstring6
		GuiControl, HS4: Disable, v_EnterHotstring6
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_FontType()
{
	global	;assume-global mode
	local a_FontType := {1: "Arial", 2: "Calibri", 3: "Consolas", 4: "Courier", 5: "Verdana"}
		, key := 0, value := 0
	
	for key, value in a_FontType
		if (a_FontType[key] = A_ThisMenuItem)
			Menu, FontTypeMenu, Check, % a_FontType[key]
	else
		Menu, FontTypeMenu, UnCheck, % a_FontType[key]
	
	c_FontType := A_ThisMenuItem
	MsgBox, 36, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["question"], % TransA["In order to aplly new font type it's necesssary to reload the application."]
		. "`n" . TransA["(Current configuration will be saved befor reload takes place)."]
		. "`n`n" . TransA["Do you want to reload application now?"]
	IfMsgBox, Yes
	{
		F_SaveFontType()
		F_SaveGUIPos("reset")
		ini_GuiReload := true
		IniWrite, % ini_GuiReload,		% ini_HADConfig, GraphicalUserInterface, GuiReload
		Reload
	}
	IfMsgBox, No
		return	
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_LoadFontType()
{
	global	;assume-global mode
	
	IniRead, c_FontType, 			% ini_HADConfig, GraphicalUserInterface, GuiFontType, Consolas
	if (!c_FontType)
		c_FontType := "Consolas"
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_SaveFontType()
{
	global	;assume-global mode
	IniWrite, % c_FontType,			% ini_HADConfig, GraphicalUserInterface, GuiFontType
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_SizeOfMargin()
{
	global	;assume-global mode
	local key := 0, value := 0
	
	Switch A_ThisMenu
	{
		Case "SizeOfMX": 
		for key, value in SizeOfMargin
			if (SizeOfMargin[key] = A_ThisMenuItem)
				Menu, SizeOfMX,	Check,	% SizeOfMargin[key]
		else
			Menu, SizeOfMX,	UnCheck,	% SizeOfMargin[key]
		c_xmarg := A_ThisMenuItem
		Case "SizeOfMY":
		for key, value in SizeOfMargin
			if (SizeOfMargin[key] = A_ThisMenuItem)
				Menu, SizeOfMY,	Check,	% SizeOfMargin[key]
		else
			Menu, SizeOfMY,	UnCheck,	% SizeOfMargin[key]
		c_ymarg := A_ThisMenuItem
	}
	MsgBox, 36, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["question"], % TransA["In order to aplly new size of margin it's necesssary to reload the application."]
		. "`n" . TransA["(Current configuration will be saved befor reload takes place)."]
		. "`n`n" . TransA["Do you want to reload application now?"]
	IfMsgBox, Yes
	{
		F_SaveSizeOfMargin()
		F_SaveGUIPos("reset")
		ini_GuiReload := true
		IniWrite, % ini_GuiReload,		% ini_HADConfig, GraphicalUserInterface, GuiReload
		Reload
	}
	IfMsgBox, No
		return	
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_SaveSizeOfMargin()
{
	global	;assume-global mode
	IniWrite, % c_xmarg,				% ini_HADConfig, GraphicalUserInterface, GuiSizeOfMarginX
	IniWrite, % c_ymarg,				% ini_HADConfig, GraphicalUserInterface, GuiSizeOfMarginY
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
F_LoadSizeOfMargin()
{
	global	;assume-global mode
	SizeOfMargin				:= {1: 0, 2: 5, 3: 10, 4: 15, 5: 20} ;pixels
	
	IniRead, c_xmarg, 			% ini_HADConfig, GraphicalUserInterface, GuiSizeOfMarginX, 10	;10 = default value
	IniRead, c_ymarg,			% ini_HADConfig, GraphicalUserInterface, GuiSizeOfMarginY, 10	;10 = default value
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  
F_SizeOfFont()
{
	global ;assume-global mode
	local a_SizeOfFont := {1: 8, 2: 9, 3: 10, 4: 11, 5: 12}
		, key := 0, value := 0
	
	for key, value in a_SizeOfFont
		if (a_SizeOfFont[key] = A_ThisMenuItem)
			Menu, SizeOfFont, Check, % a_SizeOfFont[key]
	else
		Menu, SizeOfFont, UnCheck, % a_SizeOfFont[key]
	
	c_FontSize := A_ThisMenuItem
	MsgBox, 36, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["question"], % TransA["In order to aplly new font style it's necesssary to reload the application."]
		. "`n" . TransA["(Current configuration will be saved befor reload takes place)."]
		. "`n`n" . TransA["Do you want to reload application now?"]
	IfMsgBox, Yes
	{
		F_SaveFontSize()
		F_SaveGUIPos("reset")
		ini_GuiReload := true
		IniWrite, % ini_GuiReload,		% ini_HADConfig, GraphicalUserInterface, GuiReload
		Reload
	}
	IfMsgBox, No
		return	
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
F_SaveFontSize()
{
	global ;assume-global mode
	IniWrite, % c_FontSize,				% ini_HADConfig, GraphicalUserInterface, GuiFontSize
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
F_LoadFontSize()
{
	global ;assume-global mode
		
	IniRead, c_FontSize, 			% ini_HADConfig, GraphicalUserInterface, GuiFontSize, 10	;10 points, default value
	if (!c_FontSize)
		c_FontSize := 10
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  
F_StyleOfGUI()
{
	global ;assume-global mode
	static OneTimeMemory := true
	
	if (OneTimeMemory)
	{
		Switch c_FontColor
		{
			Case "Black": ;Light (default)
			Menu, StyleGUIsubm, Check,   % TransA["Light (default)"]
			Menu, StyleGUIsubm, UnCheck, % TransA["Dark"]
			Case "White": ;Dark
			Menu, StyleGUIsubm, UnCheck, % TransA["Light (default)"]
			Menu, StyleGUIsubm, Check,   % TransA["Dark"]
		}
		OneTimeMemory := false
		return
	}	
	else
	{
		Switch A_ThisMenuItemPos
		{
			Case 1: ;Light (default)
			c_FontColor				:= "Black"
			c_FontColorHighlighted		:= "Blue"
			c_WindowColor				:= "Default"
			c_ControlColor 			:= "Default"
			Menu, StyleGUIsubm, Check,   % TransA["Light (default)"]
			Menu, StyleGUIsubm, UnCheck, % TransA["Dark"]
			Case 2: ;Dark
			c_FontColor				:= "White"
			c_FontColorHighlighted		:= "Teal"
			c_WindowColor				:= "Black"
			c_ControlColor 			:= "Gray"
			Menu, StyleGUIsubm, UnCheck, % TransA["Light (default)"]
			Menu, StyleGUIsubm, Check,   % TransA["Dark"]
		}
		MsgBox, 36, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["question"], % TransA["In order to aplly new style it's necesssary to reload the application."]
		. "`n" . TransA["(Current configuration will be saved befor reload takes place)."]
		. "`n`n" . TransA["Do you want to reload application now?"]
		IfMsgBox, Yes
		{
			F_SaveGUIstyle()
			ini_GuiReload := true
			IniWrite, % ini_GuiReload,		% ini_HADConfig, GraphicalUserInterface, GuiReload
			Reload
		}
		IfMsgBox, No
			return	
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_SaveGUIstyle()
{
	global ;assume-global mode
	
	IniWrite, % c_FontColor,				% ini_HADConfig, GraphicalUserInterface, GuiFontColor
	IniWrite, % c_FontColorHighlighted,	% ini_HADConfig, GraphicalUserInterface, GuiFontColorHighlighted
	IniWrite, % c_WindowColor, 	  		% ini_HADConfig, GraphicalUserInterface, GuiWindowColor
	Iniwrite, % c_ControlColor,			% ini_HADConfig, GraphicalUserInterface, GuiControlColor	
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_LoadGUIstyle()
{
	global ;assume-global mode
	
	IniRead, c_FontColor, 			% ini_HADConfig, GraphicalUserInterface, GuiFontColor, 		 Black
	IniRead, c_FontColorHighlighted, 	% ini_HADConfig, GraphicalUserInterface, GuiFontColorHighlighted, Blue
	IniRead, c_WindowColor, 			% ini_HADConfig, GraphicalUserInterface, GuiWindowColor, 		 Default
	IniRead, c_ControlColor, 		% ini_HADConfig, GraphicalUserInterface, GuiControlColor, 		 Default
	
	if (!c_FontColor)
		c_FontColor := "Black"
	if (!c_FontColorHighlighted)
		c_FontColorHighlighted := "Blue"
	if (!c_WindowColor)
		c_WindowColor := "Default"
	if (!c_ControlColor)
		c_ControlColor := "Default"
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;#c/* commercial only beginning
;#c*/ commercial only end
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;#c/* commercial only beginning
;#c*/ commercial only end
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_ReloadApplication(params*)	;ItemName, ItemPos, MenuName
{
	global ;assume-global mode

 	if (params[1] = "Run from new location")
	 {
		Switch A_IsCompiled
		{
			Case % true:
				Run, % "" . params[2] . "\" . SubStr(A_ScriptName, 1, -4) . ".exe" . ""
			; Case % true:	Run, % A_AhkPath . A_Space . """" . params[2] . """" . "\" . SubStr(A_ScriptName, 1, -4) . ".exe"
			Case "": 		Run, % A_AhkPath . A_Space . """" . params[2] . """" . "\" . A_ScriptName	;double quotes ("") are necessary to escape " and to run script if its path contains space.
		}
		try	;if no try, some warnings are still catched; with try no more warnings
			ExitApp, 0
	 }
	
	if (WinExist("ahk_id" HS3GuiHwnd) or WinExist("ahk_id" HS4GuiHwnd))
	{
		MsgBox, 36, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["question"], % TransA["Are you sure you want to reload this application now?"]
		. "`n" . TransA["(Current configuration will be saved befor reload takes place)."]
		IfMsgBox, Yes
		{
			F_SaveGUIPos()
			ini_GuiReload := true
			IniWrite, % ini_GuiReload,		% ini_HADConfig, GraphicalUserInterface, GuiReload
			Switch A_ThisMenuItem
			{
				Case % TransA["Reload in default mode"]:
				Switch A_IsCompiled
				{
					Case % true:	Run, % A_ScriptFullPath . A_Space . "/r"
					Case "":		Reload
				}
				Case % TransA["Reload in silent mode"]:
				Switch A_IsCompiled
				{
					Case % true:	Run, % A_ScriptFullPath . A_Space . "l"
					Case "": 		Run, % A_AhkPath . A_Space . """" . A_ScriptFullPath . """" . A_Space . "l"	;double quotes ("") are necessary to escape " and to run script if its path contains space.
				}
				Default:	;when button was pressed "Download repository version"
				Switch A_IsCompiled
				{
					Case % true:	Run, % A_ScriptFullPath . A_Space . "/r"
					Case "": 		Reload
				}
			}
			try	;if no try, some warnings are still catched; with try no more warnings
				ExitApp, 0
		}
		IfMsgBox, No
			return
	}
	else	;source of event: SysTray
	{
		Switch params[1]
		{
			Case TransA["Reload in silent mode"]:
				Switch A_IsCompiled
				{
					Case % true:	Run, % A_ScriptFullPath . A_Space . "l"
					Case "": 		Run, % A_AhkPath . A_Space . """" . A_ScriptFullPath . """" . A_Space . "l"	;double quotes ("") are necessary to escape " and to run script if its path contains space.
				}
			Default:	;if params[1] = ""
				Switch A_IsCompiled
				{
					Case % true:	Run, % A_ScriptFullPath . A_Space . "/r"
					Case "": 		Reload
				}
		}
		try	;if no try, some warnings are still catched; with try no more warnings
			ExitApp, 0
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_Exit()
{
	global ;assume-global mode
	MsgBox, 36, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["question"], % TransA["Are you sure you want to exit this application now?"]
	IfMsgBox, Yes
		ExitApp, 0 ;Zero is traditionally used to indicate success.
	IfMsgBox, No
		return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_ToggleSandbox()
{
	global ;assume-global mode
	
	Menu, ConfGUI, ToggleCheck, % TransA["Show Sandbox"] . "`tCtrl + F6"
	ini_Sandbox := !(ini_Sandbox)
	if (ini_Sandbox)
	{
		GuiControl, Show, % IdEdit10
		GuiControl, Show, % IdEdit10b
	}
	else
	{
		GuiControl, Hide, % IdEdit10
		GuiControl, Hide, % IdEdit10b
	}

	Switch F_WhichGui()
	{
		Case "HS3":
			HS3GuiSize(GuiHwnd := HS3GuiHwnd, EventInfo := 0, Width := HS3_GuiWidth, Height := HS3_GuiHeight)
		Case "HS4": 
			HS4GuiSize(GuiHwnd := HS4GuiHwnd, EventInfo := 0, Width := LeftColumnW + c_ymarg + c_WofMiddleButton, Height := ini_Sandbox ? LeftColumnH + 2 * c_ymarg + c_HofText + c_HofSandbox : LeftColumnH + 2 * c_ymarg + c_HofText)
			Gui, HS4: Show, AutoSize
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_LoadGUIPos()
{
	global ;assume-global mode
	local ini_ReadTemp := 0
	
	ini_HS3WindoPos 	:= {"X": 0, "Y": 0, "W": 0, "H": 0} ;at the moment associative arrays are not supported in AutoHotkey as parameters of Commands
,	ini_ListViewPos 	:= {"X": 0, "Y": 0, "W": 0, "H": 0} ;at the moment associative arrays are not supported in AutoHotkey as parameters of Commands
,	ini_WhichGui 		:= ""
,	ini_Sandbox 		:= true
	;after loading values (empty by default) those parameters are further used in F_GUIInit()
	IniRead, ini_ReadTemp, 					% ini_HADConfig, GraphicalUserInterface, MainWindowPosX, 	% A_Space	;empty by default
	ini_HS3WindoPos.X := ini_ReadTemp
	IniRead, ini_ReadTemp, 					% ini_HADConfig, GraphicalUserInterface, MainWindowPosY, 	% A_Space	;empty by default
	ini_HS3WindoPos.Y := ini_ReadTemp
	IniRead, ini_ReadTemp, 					% ini_HADConfig, GraphicalUserInterface, MainWindowPosW, 	% A_Space	;empty by default
	ini_HS3WindoPos.W := ini_ReadTemp
	IniRead, ini_ReadTemp, 					% ini_HADConfig, GraphicalUserInterface, MainWindowPosH, 	% A_Space	;empty by default
	ini_HS3WindoPos.H := ini_ReadTemp
	
	IniRead, ini_Sandbox, 					% ini_HADConfig, GraphicalUserInterface, Sandbox,			1
	IniRead, ini_WhichGui,					% ini_HADConfig, GraphicalUserInterface, WhichGui, 		% A_Space
	if (ini_WhichGui = "")
		ini_WhichGui := "HS3"
	IniRead, ini_HS3GuiMaximized,				% ini_HADConfig, GraphicalUserInterface, GuiMaximized, 	0
	; OutputDebug, % A_ThisFunc . A_Space . "ini_HS3WindoPos.X:" . A_Space . ini_HS3WindoPos.X . A_Space . "ini_HS3WindoPos.Y:" . A_Space . ini_HS3WindoPos.Y . "`n"
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_CheckCreateConfigIni(params*)
{
	global ;assume-global mode
	local  ConfigIni 	:= ""	; variable which is used as default content of Config.ini
		, HADConfig_App		:= A_ScriptDir . "\" . "Config.ini"

;#c/* commercial only beginning
;#c*/ commercial version only end
		
;#f/* free version only beginning
	 ConfigIni := "			
	 	( LTrim
	 	[Configuration]
	 	ClipBoardPasteDelay=300
	 	HotstringUndo=1
	 	ShowIntro=1
	 	CheckRepo=0
	 	DownloadRepo=0
	 	HK_Main=#^h
	 	HK_IntoEdit=~^#c
	 	HK_UndoLH=~#z
	 	HK_ToggleTt=none
	 	THLog=0
	 	HADConfig=
	 	HADL=
	 	[EvStyle_TT]
	 	TTBackgroundColor=white
	 	TTBackgroundColorCustom=
	 	TTTypefaceColor=black
	 	TTTypefaceColorCustom=
	 	TTTypefaceFont=Consolas
	 	TTTypefaceSize=10
	 	[EvStyle_HM]
	 	HMBackgroundColor=white
	 	HMBackgroundColorCustom=
	 	HMTypefaceColorCustom=
	 	HMTypefaceColor=black
	 	HMTypefaceFont=Consolas
	 	HMTypefaceSize=10
	 	[EvStyle_AT]
	 	ATBackgroundColor=green
	 	ATBackgroundColorCustom=
	 	ATTypefaceColorCustom=
	 	ATTypefaceColor=black
	 	ATTypefaceFont=Consolas
	 	ATTypefaceSize=10
	 	[EvStyle_HT]
	 	HTBackgroundColor=green
	 	HTBackgroundColorCustom=
	 	HTTypefaceColorCustom=
	 	HTTypefaceColor=black
	 	HTTypefaceFont=Consolas
	 	HTTypefaceSize=11
	 	[EvStyle_UH]
	 	UHBackgroundColor=green
	 	UHBackgroundColorCustom=
	 	UHTypefaceColorCustom=
	 	UHTypefaceColor=black
	 	UHTypefaceFont=Consolas
	 	UHTypefaceSize=11
	 	[Event_ActiveTriggerstringTips]
	 	ATEn=0
	 	[Event_BasicHotstring]
	 	OHTtEn=1
	 	OHTD=2000
	 	OHTP=1
	 	OHSEn=0
	 	OHSF=500
	 	OHSD=250
	 	[Event_MenuHotstring]
	 	MHMP=1
	 	MHSEn=1
	 	MHSF=400
	 	MHSD=250
	 	[Event_UndoHotstring]
	 	UHTtEn=1
	 	UHTD=2000
	 	UHTP=1
	 	UHSEn=0
	 	UHSF=600
	 	UHSD=250
	 	[Event_TriggerstringTips]
	 	TTTtEn=1
	 	TTTD=2000
	 	TTTP=1
	 	TipsSortAlphabetically=1
	 	TipsSortByLength=1
	 	TipsAreShownAfterNoOfCharacters=1
	 	MNTT=20
	 	TTCn=2
	 	[StaticTriggerstringHotstring]
	 	SWPosX=
	 	SWPosY=
	 	SWPosW=
	 	SWPosH=
	 	[GraphicalUserInterface]
	 	Language=English.txt
	 	MainWindowPosX=
	 	MainWindowPosY=
	 	MainWindowPosW=
	 	MainWindowPosH=
	 	Sandbox=1
	 	WhichGui=HS3
	 	GuiFontColor=Black
	 	GuiFontColorHighlighted=Blue
	 	GuiWindowColor=Default
	 	GuiControlColor=Default
	 	GuiSizeOfMarginX=10
	 	GuiSizeOfMarginY=10
	 	GuiFontType=Calibri
	 	GuiFontSize=10
	 	GuiReload=
	 	GuiMaximized=0
	 	[EndChars]
	 	Apostrophe '=1
	 	Backslash \=1
	 	Closing Curly Bracket }=1
	 	Closing Round Bracket )=1
	 	Closing Square Bracket ]=1
	 	Colon :=1
	 	Comma ,=1
	 	Dot .=1
	 	Enter=1
	 	Exclamation Mark !=1
	 	Minus -=1
	 	Opening Curly Bracket {=1
	 	Opening Round Bracket (=1
	 	Opening Square Bracket [=1
	 	Question Mark ?=1
	 	Quote ""=1
	 	Semicolon =1
	 	Slash /=0
	 	Space=1
	 	Tab=1
	 	Underscore _=1
	 	[LoadLibraries]
	 	[ShowTipsLibraries]
	 	)"
;#f*/ free version only end

	if (!FileExist(HADConfig_App))
	{
		FileAppend, % ConfigIni, % HADConfig_App
		if (ErrorLevel)
		{
			MsgBox, % c_MsgBoxIconError, % SubStr(A_ScriptName, 1, -4) .  ":" . A_Space . TransA["error"], % TransA["Config.ini file couldn't be created for some reason. Exiting."]
				. "`n`n"
				. HADConfig_App
			ExitApp, 14		;Config.ini file couldn't be created for some reason. Exiting.
		}	
		MsgBox, 48, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["warning"], % TransA["Config.ini wasn't found. The default Config.ini has now been created in location:"]
			. HADConfig_App
			. "`n`n" 
			. TransA["As a consequence the default language file English.txt will be recreated."]
		if (FileExist(A_ScriptDir . "\Languages\English.txt"))	;if there is no Config.ini, then English.txt should be recreated.
		{
			FileDelete, % A_ScriptDir . "\Languages\English.txt"
			if (ErrorLevel)
			{
				MsgBox, % c_MsgBoxIconError, % SubStr(A_ScriptName, 1, -4) .  ":" . A_Space . TransA["error"], % TransA["Unexpected problem on time of deleting the file ""\Languages\English.txt"". Exiting."]
				ExitApp, 15	;Unexpected problem on time of deleting the file ""\Languages\English.txt"".
			}	
		}	
		ini_HADConfig := HADConfig_App
		return
	}
	if (FileExist(HADConfig_App))
	{
		ini_HADConfig := HADConfig_App
		return
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
F_SaveGUIPos(param*) ;Save to Config.ini
{
	global 	;assume-global mode
	local 	WinX := 0, WinY := 0
	
	WinGetPos, WinX, WinY, , , A
	if (param[1] = "reset") ;if AutoSize option will be used for Gui after reload
	{
		IniWrite, % WinX, 			  	% ini_HADConfig, GraphicalUserInterface, MainWindowPosX
		IniWrite, % WinY, 			  	% ini_HADConfig, GraphicalUserInterface, MainWindowPosY
		IniWrite, % "", 				% ini_HADConfig, GraphicalUserInterface, MainWindowPosW
		IniWrite, % "", 				% ini_HADConfig, GraphicalUserInterface, MainWindowPosH
		return
	}
	Switch F_WhichGui()		;This line is necessary in case when last Gui is not equal to HS3 or HS4. This is a case e.g. if Gui_VersionUpdate is active
	{
		Case "HS3":
			IniWrite,  HS3,			% ini_HADConfig, GraphicalUserInterface, WhichGui
			IniWrite, % HS3_GuiWidth, 	% ini_HADConfig, GraphicalUserInterface, MainWindowPosW
			IniWrite, % HS3_GuiHeight, 	% ini_HADConfig, GraphicalUserInterface, MainWindowPosH
			IniWrite, % ini_HS3GuiMaximized, 	% ini_HADConfig, GraphicalUserInterface, GuiMaximized
		Case "HS4":
			IniWrite,  HS4,			% ini_HADConfig, GraphicalUserInterface, WhichGui
			IniWrite, % HS4_GuiWidth, 	% ini_HADConfig, GraphicalUserInterface, MainWindowPosW
			IniWrite, % HS4_GuiHeight, 	% ini_HADConfig, GraphicalUserInterface, MainWindowPosH
	}
	IniWrite, % WinX, 			  % ini_HADConfig, GraphicalUserInterface, MainWindowPosX
	IniWrite, % WinY, 			  % ini_HADConfig, GraphicalUserInterface, MainWindowPosY
	IniWrite, % ini_Sandbox, 	  % ini_HADConfig, GraphicalUserInterface, Sandbox
	MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["Position of this window is saved in Config.ini."]
	; OutputDebug, % A_ThisFunc . A_Space . "WinX:" . A_Space . WinX . A_Space . "WinY:" . A_Space . WinY . A_Space . "HS3_GuiWidth:" . A_Space . HS3_GuiWidth . A_Space . "HS3_GuiHeight:" . A_Space . HS3_GuiHeight . "`n"
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_LoadHotstringsFromLibraries()
{
	global ; assume-global mode of operation
	local key := "", value := ""

	a_Library 		:= []	;initialization of global variable
, 	a_TriggerOptions 	:= []
, 	a_Triggerstring 	:= []
, 	a_OutputFunction 	:= []
, 	a_EnableDisable 	:= []
, 	a_Hotstring		:= []
, 	a_Comment 		:= []
, 	a_Combined		:= []
,	v_LibHotstringCnt 	:= 0
,	v_TotalHotstringCnt := 0
	
	; Prepare TrayTip message taking into account value of command line parameter.
	if (v_SilentMode == "l")
		TrayTip, %A_ScriptName% - Lite mode, 	% TransA["Loading hotstrings from libraries..."], 1
	else	
		TrayTip, %A_ScriptName%,				% TransA["Loading hotstrings from libraries..."], 1
	
	for key, value in ini_LoadLib ; Load (triggerstring, hotstring) definitions if enabled
		if (value)
			F_LoadDefinitionsFromFile(key)
}
; ------------------------------------------------------------------------------------------------------------------------------------
F_LoadTTperLibrary()	;Load Triggerstring Tips per library, as specified in Config.ini (variable ini_ShowTipsLib)
{
	global 	;assume-global mode
	local 	key := "", value := ""

	for key, value in ini_ShowTipsLib
		if (value) and (ini_LoadLib[key])
			F_LoadTriggTipsFromFile(key)
}
; ------------------------------------------------------------------------------------------------------------------------------------
F_UpdateSelHotLibDDL()
{	;Load content of DDL2 and mark disabled libraries
	global ;assume-global mode
	local key := "", value := "", FinalString := ""
	
	if (ini_LoadLib.Count()) ;if ini_LoadLib isn't empty
	{
		FinalString .= TransA["↓ Click here to select hotstring library ↓"] . "||"
		for key, value in ini_LoadLib
		{
			if !(value)
				FinalString .= key . A_Space . TransA["DISABLED"]
			else
				FinalString .= key 

			FinalString .= "|"
		}
	}
	else ;if ini_LoadLib is empty
		FinalString .=  TransA["No libraries have been found!"] . "||" 
	
	GuiControl, , % IdDDL2, 	% "|" . FinalString 	;To replace (overwrite) the list instead, include a pipe as the first character
	GuiControl, , % IdDDL2b, % "|" . FinalString		;To replace (overwrite) the list instead, include a pipe as the first character
}
; ------------------------------------------------------------------------------------------------------------------------------------
F_ToggleLibraryTips()
{
	global ;assume-global mode of operation
	local v_LibraryFlag := 0 
	
	Menu, ToggleLibTrigTipsSubmenu, ToggleCheck, %A_ThisMenuItem%
	IniRead, v_LibraryFlag, % ini_HADConfig, ShowTipsLibraries, %A_ThisMenuItem%
	v_LibraryFlag := !(v_LibraryFlag)
	IniWrite, %v_LibraryFlag%, % ini_HADConfig, ShowTipsLibraries, %A_ThisMenuItem%
	F_ValidateIniLibSections()

	if (v_LibraryFlag)
	{
		F_LoadTriggTipsFromFile(A_ThisMenuItem)	
		MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["Triggerstring tips have been loaded from the following library file to memory:"]
			. "`n`n" . A_ThisMenuItem
	}
	else
	{
		F_UnloadTriggTipsFromMemory(A_ThisMenuItem)
		MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["Triggerstring tips related to the following library file have been unloaded from memory:"]
			. "`n`n" . A_ThisMenuItem
	}

	F_Sort_a_Triggers(a_Combined, ini_TipsSortAlphabetically, ini_TipsSortByLength)
}
; ------------------------------------------------------------------------------------------------------------------------------------
F_LoadTriggTipsFromFile(LibraryFilename)
{
	global ;assume-global mode of operation
	local	key := 0,	value := "", TheWholeFile := ""	;LibraryFilename containts extenstion
,			BegCom := false, ExternalIndex := 0
,			tmp1 := "", tmp2 := "", tmp3 := "", tmp4 := ""
,			LibraryName := SubStr(LibraryFilename, 1, -4)	;LibraryFilename without extension

	FileRead, TheWholeFile, % ini_HADL . "\" . LibraryFilename
	Loop, Parse, TheWholeFile, `n, `r%A_Space%%A_Tab%
	{
		if (SubStr(A_LoopField, 1, 2) = "/*")	;ignore comments
		{
			BegCom := true
			Continue
		}
		if (BegCom) and (SubStr(A_LoopField, -1) = "*/") ;ignore comments
		{
			BegCom := false
			Continue
		}
		if (BegCom)
			Continue
		if (SubStr(A_LoopField, 1, 1) = ";")	;ignore comments
			Continue
		if (!A_LoopField)	;ignore empty lines
			Continue
		
          ExternalIndex++
		Loop, Parse, A_LoopField, % c_TextDelimiter
		{
			Switch A_Index
			{
				Case 1:	tmp2 := A_LoopField
				Case 2:	tmp1 := A_LoopField
				Case 4:	tmp3 := A_LoopField
				Case 5:	tmp4 := A_LoopField
			}
		}
		a_Combined.Push(tmp1 . c_TextDelimiter . tmp2 . c_TextDelimiter . tmp3 . c_TextDelimiter . tmp4)
	}	
}
; ------------------------------------------------------------------------------------------------------------------------------------
F_UnloadTriggTipsFromMemory(LibraryFilename)
{
	global ;assume-global mode of operation
	local	key := 0,	value := ""
		, 	LibraryName := SubStr(LibraryFilename, 1, -4)	;remove extension
		,	key2 := 0
	
	for key, value in a_Library
	{
		if (value = LibraryName)
		{
			while (a_Library[key] = LibraryName)
				{
					a_Library			.RemoveAt(key)
					a_Triggerstring	.RemoveAt(key)
					a_TriggerOptions	.RemoveAt(key)
					a_EnableDisable	.RemoveAt(key)
					a_OutputFunction	.RemoveAt(key)
					a_Hotstring		.RemoveAt(key)
					a_Comment			.RemoveAt(key)
				}
		}
	}
	F_Recreate_CombinedTable()
}
; ------------------------------------------------------------------------------------------------------------------------------------
F_Recreate_CombinedTable()
{
	global ;assume-global mode of operation
	local	key := 0,	key2 := 0, value := ""

	a_Combined := []
	for key, value in ini_ShowTipsLib
	{
		if (value)
		{
			for key2 in a_Library
				if (a_Library[key2] = SubStr(key, 1, -4))	;remove extension
					a_Combined.Push(a_Triggerstring[key2] . c_TextDelimiter . a_TriggerOptions[key2] . c_TextDelimiter . a_EnableDisable[key2] . c_TextDelimiter . a_Hotstring[key2])
		}
	}
}
; ------------------------------------------------------------------------------------------------------------------------------------
F_ToggleLibrary()	;load / unload d(t, o, h)
{
	global ;assume-global mode of operation
	local 	v_LibraryFlag := 0, name := SubStr(A_ThisMenuItem, 1, -4)	;without file extension
	
	Menu, EnDisLib, ToggleCheck, %A_ThisMenuItem%	;future: don't ready .ini file, instead use appropriate table
	IniRead, v_LibraryFlag,		% ini_HADConfig, LoadLibraries, %A_ThisMenuitem%
	v_LibraryFlag := !(v_LibraryFlag)
	Iniwrite, %v_LibraryFlag%,	% ini_HADConfig, LoadLibraries, %A_ThisMenuItem%
	
	if (v_LibraryFlag)
	{
 		F_LoadDefinitionsFromFile(A_ThisMenuItem)	; load definitions from library file (.csv) into memory and to tables: -> F_CreateHotstring
		F_LoadTriggTipsFromFile(A_ThisMenuItem)
		MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["The (triggerstring, hotstring) definitions have been uploaded from library file"] . ":"
			. "`n`n" . A_ThisMenuItem
	}
	else
	{
		F_UnloadHotstringsFromFile(A_ThisMenuItem)
		F_UnloadTriggTipsFromMemory(A_ThisMenuItem)
		MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["The (triggerstring, hotstring) definitions stored in the following library file have been unloaded from memory"]
			. ":" . "`n`n" . A_ThisMenuItem
	}
	F_ValidateIniLibSections()	; Load from / to Config.ini from Libraries folder
	F_UpdateSelHotLibDDL()
	F_Clear()					;clear all fields of HS3 / HS4 GUI
	F_RefreshListOfLibraryTips()
}
; ------------------------------------------------------------------------------------------------------------------------------------
F_UnloadHotstringsFromFile(nameoffile)
{	
	global ;assume-global mode of operation
	local	v_TheWholeFile := "",	Options := "",	TriggerString := "", key := 0, value := ""
, 			FilenameWitoutExt := SubStr(nameoffile, 1, -4)
	
	for key, value in a_Library
	{
		if (value = FilenameWitoutExt)
		{
			Options := a_TriggerOptions[key]
			if (InStr(Options, "*"))
				Options := StrReplace(Options, "*", "*0")
			if (InStr(Options, "B0"))
				Options := StrReplace(Options, "B0", "B")
			if (InStr(Options, "O"))
				Options := StrReplace(Options, "O", "O0")
			if (InStr(Options, "Z"))
				Options := StrReplace(Options, "Z", "Z0")
			TriggerString := a_Triggerstring[key]
			if (a_EnableDisable[key] = "En")
			{
				Try
					Hotstring(":" . Options . ":" . F_ConvertEscapeSequences(TriggerString), , "Off") ;Disable existing hotstring definitions: only those which have been configured to be off.
				Catch
					MsgBox, 16, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["Error"], % A_ThisFunc . A_Space . TransA["Something went wrong with disabling of existing hotstring"] 
					. ":" . "`n`n" . "TriggerString:" . A_Space . TriggerString . "`n" . A_Space . "Options:" . A_Space . Options . "`n`n" . TransA["Library name:"] 
					. A_Space . nameoffile 				
			}
		}
	}
	key := 0, value := ""
	for key, value in a_Library
	{
		if (value = FilenameWitoutExt)
		{
			while (a_Library[key] = FilenameWitoutExt)
				{
					a_Library			.RemoveAt(key)
					a_Triggerstring	.RemoveAt(key)
					a_TriggerOptions	.RemoveAt(key)
					a_EnableDisable	.RemoveAt(key)
					a_OutputFunction	.RemoveAt(key)
					a_Hotstring		.RemoveAt(key)
					a_Comment			.RemoveAt(key)
					--v_TotalHotstringCnt
				}
		}
	}
	UpdateLibraryCounter(v_LibHotstringCnt, v_TotalHotstringCnt)
}
; ------------------------------------------------------------------------------------------------------------------------------------
F_LoadCreateTranslationTxt(decision*)
{
	global ;assume-global mode
	local TransConst := "" ; variable which is used as default content of Languages/English.ini. Join lines with `n separator and escape all ` occurrences. Thanks to that string lines where 'n is present 'aren't separated.
	,	v_TheWholeFile := "", key := "", val := "", tick := false
	
;Warning. If right side contains `n chars it's necessary to replace them with StrReplace, e.g. TransA["Enables Convenient Definition"] := StrReplace(TransA["Enables Convenient Definition"], "``n", "`n")
	TransConst := "
(Join`n `
; This file contains definitions of text strings used by Hotstrings application. The left column (preceding equal sign) contains definitions of text strings as defined in source code. 
; The right column contains text strings which are replaced instead of left column definitions. Exchange text strings in right columnt with localized translations of text strings. 
; You don't have to remove lines starting with semicolon. Those lines won't be read by Hotstrings application.
)"

	TransConst .= "`n`n
(Join`n `
About / Help 											= &About / Help
About this application...								= About this application...
Above information is saved to configuration file.				= Above information is saved to configuration file.
According to your wish the new version of application was found on the server and downloaded. = According to your wish the new version of application was found on the server and downloaded.
Activation limit										= Activation limit
Activation usage										= Activation usage
Active triggerstring tips								= Active triggerstring tips
Active triggerstring tips styling							= Active triggerstring tips styling
Actual computer name									= Actual computer name
Actual logon name										= Actual logon name
Actually the ""Libraries"" folder is already located in default location, so it won't be moved. = Actually the ""Libraries"" folder is already located in default location, so it won't be moved.
Add comment (optional) 									= Add comment (optional)
Add / Edit hotstring (F9) 								= Add / Edit hotstring (F9)
Add new library file									= Add new library file
Add to Autostart										= Add to Autostart
After downloading libraries aren't automaticlly loaded into memory. Would you like to upload content of libraries folder into memory? = After downloading libraries aren't automaticlly loaded into memory. Would you like to upload content of libraries folder into memory?
A library with that name already exists! 					= A library with that name already exists!
All of them are ""immediate execute"" (*)					= All of them are ""immediate execute"" (*)
All tips (e.g. triggerstring tips, tips displayed after definition is completed, udno) are now ACTIVE. = All tips (e.g. triggerstring tips, tips displayed after definition is completed, udno) are now ACTIVE.
All tips (e.g. triggerstring tips, tips displayed after definition is completed, udno) are now SUSPENDED. = All tips (e.g. triggerstring tips, tips displayed after definition is completed, udno) are now SUSPENDED.
Alphabetically 										= Alphabetically
already exists in another library							= already exists in another library
and active in whole operating system (any window)				= and active in whole operating system (any window)
Apostrophe ' 											= Apostrophe '
""AppData\Hotstrings"" subfolder wasn't created for some reason. Exiting. = ""AppData\Hotstrings"" subfolder wasn't created for some reason. Exiting.
Application											= A&pplication
Application has been running since							= Application has been running since
Application help										= Application help
Application hotkeys										= Application hotkeys
Application hotstrings									= Application hotstrings
Application hotstrings && hotkeys							= Application hotstrings && hotkeys
Application language changed to: 							= Application language changed to:
Application mode										= Application mode
Application statistics									= Application statistics
Application will exit now.								= Application will exit now.
Apply												= &Apply
Restore default hotkey									= Restore default hotkey
Apply new hotkey										= Apply new hotkey
aqua													= aqua
Are you sure?											= Are you sure?
Are you sure you want to close this window?					= Are you sure you want to close this window?
Are you sure you want to exit this application now?			= Are you sure you want to exit this application now?
Are you sure you want to move ""Hotstrings"" folder and all its content to the new location? = Are you sure you want to move ""Hotstrings"" folder and all its content to the new location?
Are you sure you want to reload this application now?			= Are you sure you want to reload this application now?
As a consequence the default language file English.txt will be recreated. = As a consequence the default language file English.txt will be recreated.
At first select library name which you intend to delete.		= At first select library name which you intend to delete.
AutoHotkey version										= AutoHotkey version
Background color										= Background color
Backslash \ 											= Backslash \
Basic hotstring is triggered								= Basic hotstring is triggered
black												= black
blue													= blue
Both optional locations for library folder are empty (do not contain any library files). The second one will be used. = Both optional locations for library folder are empty (do not contain any library files). The second one will be used.
Both optional library folder locations contain *.csv files. Would you like to use the first one? = Both optional library folder locations contain *.csv files. Would you like to use the first one?
Built with Autohotkey.exe version							= Built with Autohotkey.exe version
By default library files (*.csv) are located in Users subfolder which is protected against other computer users. = By default library files (*.csv) are located in Users subfolder which is protected against other computer users.
By length 											= By length
Call Graphical User Interface								= Call Graphical User Interface
Cancel 												= &Cancel
Cancel												= Cancel
caret												= caret
Case Sensitive (C) 										= Case Sensitive (C)
Case-Conforming										= Case-Conforming
caused problem on line URLDownloadToFile.					= caused problem on line URLDownloadToFile.
Change language 										= Change language
Check if update is available on startup?					= Check if update is available on startup?
Check repository version									= Check repository version
Choose existing hotstring library file before saving new (triggerstring, hotstring) definition!	= Choose existing hotstring library file before saving new (triggerstring, hotstring) definition!
Choose (.ahk) file containing (triggerstring, hotstring) definitions for import	= Choose (.ahk) file containing (triggerstring, hotstring) definitions for import
Choose library file (.csv) for export 						= Choose library file (.csv) for export
Choose new library file name:								= Choose new library file name:
Choose menu position 									= Choose menu position
Choose sending function! 								= Choose sending function!
Choose the method of sending the hotstring! 					= Choose the method of sending the hotstring!
Choose tips location 									= Choose tips location
Clear (F5) 											= Clear (F5)
Clipboard Delay (F7)									= Clipboard &Delay (F7)
Clipboard paste delay in [ms]:  							= Clipboard paste delay in [ms]:
Close												= Cl&ose
Close and interrupt										= Close and interrupt
Closing Curly Bracket } 									= Closing Curly Bracket }
Closing it will exit application.							= Closing it will exit application.
Closing Round Bracket ) 									= Closing Round Bracket )
Closing Square Bracket ] 								= Closing Square Bracket ]
Colon : 												= Colon :
Comma , 												= Comma ,
Comment												= Comment
Composition of triggerstring tips							= Composition of triggerstring tips
Compressed executable (upx.exe)							= Compressed executable (upx.exe)
Compressed executable (mpress.exe)							= Compressed executable (mpress.exe)
Computer name											= Computer name
Config.ini file: move it to script / app location				= Config.ini file: move it to script / app location
Config.ini file: restore it to default location				= Config.ini file: restore it to default location
Config.ini file was successfully moved to the new location.		= Config.ini file was successfully moved to the new location.
Config.ini file couldn't be created for some reason. Exiting.	= Config.ini file couldn't be created for some reason. Exiting.
Config.ini wasn't found. The default Config.ini has now been created in location: = Config.ini wasn't found. The default Config.ini has now been created in location:
Configuration 											= &Configuration
Content of current log file (read only)						= Content of current log file (read only)
Convert to executable (.exe)								= Convert to executable (.exe)
Content of clipboard contain new line characters. Do you want to remove them? = Content of clipboard contain new line characters. Do you want to remove them?
Content of this text field is not file path or file wasn't found. For ouput function ""Picture (P)"" it is required to enter correct filepath. = Content of this text field is not file path or file wasn't found. For ouput function ""Picture (P)"" it is required to enter correct filepath.
Content of this text field is not file path or file wasn't found. For ouput function ""Run (R)"" it is required to enter correct filepath. = Content of this text field is not file path or file wasn't found. For ouput function ""Run (R)"" it is required to enter correct filepath.
Continue reading the library file? If you answer ""No"" then application will exit! = Continue reading the library file? If you answer ""No"" then application will exit!
Conversion of .ahk file into new .csv file (library) and loading of that new library = Conversion of .ahk file into new .csv file (library) and loading of that new library
Conversion of .csv library file into new .ahk file containing static (triggerstring, hotstring) definitions = Conversion of .csv library file into new .ahk file containing static (triggerstring, hotstring) definitions
Conversion of .csv library file into new .ahk file containing dynamic (triggerstring, hotstring) definitions = Conversion of .csv library file into new .ahk file containing dynamic (triggerstring, hotstring) definitions
Converted												= Converted
Copy clipboard content into ""Enter hotstring""				= Copy clipboard content into ""Enter hotstring""
Copy Config.ini folder path to Clipboard					= Copy Config.ini folder path to Clipboard
Copy Libraries folder path to Clipboard						= Copy Libraries folder path to Clipboard
Copy Log folder path to Clipboard							= Copy Log folder path to Clipboard
Open picture in MSPaint and copy to Clipboard				= Open picture in MSPaint and copy to Clipboard
Copy picture to Clipboard								= Copy picture to Clipboard
Copy picture path to Clipboard							= Copy picture path to Clipboard
""Languages"" subfolder wasn't created for some reason.		= ""Languages"" subfolder wasn't created for some reason.
Created at											= Created at
Cumulative gain [characters]								= Cumulative gain [characters]
Current Config.ini file location:							= Current Config.ini file location:
(Current configuration will be saved befor reload takes place).	= (Current configuration will be saved befor reload takes place).
Current ""Libraries"" location:							= Current ""Libraries"" location:
Current script / application location:						= Current script / application location:
Current shortcut (hotkey):								= Current shortcut (hotkey):
Current time											= Current time
cursor												= cursor
custom												= custom
Customer id											= Customer id
Customer name											= Customer name
Dark													= Dark
default 												= default
Default Config.ini file location:							= Default Config.ini file location:
Default shortcut (hotkey):								= Default shortcut (hotkey):
Default mode											= Default mode
Delete selected library file								= Delete selected library file
Delete hotstring (F8) 									= Delete hotstring (F8)
Delete selected definition								= Delete selected definition
Deleting hotstring... 									= Deleting hotstring...
Deleting hotstring. Please wait... 						= Deleting hotstring. Please wait...
Disable 												= Disable
disable												= disable
disable triggerstring tips and hotstrings					= disable triggerstring tips and hotstrings
DISABLED												= DISABLED
Do you want to replace it with source definition?				= Do you want to replace it with source definition?
Download if update is available on startup?					= Download if update is available on startup?
Download public libraries								= Download public libraries
Do you wish to apply your changes?							= Do you wish to apply your changes?
Do you want to overwrite it?								= Do you want to overwrite it?
Do you want to proceed? 									= Do you want to proceed?
Dot . 												= Dot .
Do you want to reload application now?						= Do you want to reload application now?
doesn't exist in application folder						= doesn't exist in application folder
down													= down
Download repository version								= Download repository version
Downloading public library files							= Downloading public library files
Dynamic hotstrings 										= &Dynamic hotstrings
Edit library header										= Edit library header
Edit Hotstrings 										= Edit Hotstrings
Editing of library header is possible only if library is enabled (not DISABLED). = Editing of library header is possible only if library is enabled (not DISABLED).
En/Dis|Triggerstring|Trigg Opt|Out Fun|Hotstring|Comment 		= En/Dis|Triggerstring|Trigg Opt|Out Fun|Hotstring|Comment
Enable												= Enable
enable												= enable
ENABLED												= ENABLED
En/Dis												= En/Dis
En. / Dis.											= En. / Dis.
Enable/disable libraries									= Enable/disable &libraries
Enable/disable selected definition							= Enable/disable selected definition
Enable/disable triggerstring tips 							= Enable/disable triggerstring tips	
Enables Convenient Definition 							= Enables convenient definition and use of hotstrings (triggered by shortcuts longer text strings). `n2022 Copyright  by Maciej Słojewski (🐘).
enable triggerstring tips and hotstrings					= enable triggerstring tips and hotstrings
EnDis parameter is missing								= EnDis parameter is missing
Enter 												= Enter 
Enter a name for the new library 							= Enter a name for the new library
Enter a new library name									= Enter a new library name
Enter hotstring 										= Enter hotstring
enter selected hotstring									= enter selected hotstring
Enter triggerstring										= Enter triggerstring
Entered license key										= Entered license key
Entered license key was not found.							= Entered license key was not found.
Error												= Error
ErrorLevel was triggered by NewInput error. 					= ErrorLevel was triggered by NewInput error.
Error reading library file:								= Error reading library file:
Events: styling										= Events: styling
Exclamation Mark ! 										= Exclamation Mark !
exists in the currently selected library					= exists in the currently selected library
exists in the library									= exists in the library
Exit													= Exit
Exit application										= Exit application
exit Hotstrings application								= exit Hotstrings application
Exiting												= Exiting
Expiration date										= Expiration date
Expires at											= Expires at
Export from .csv to .ahk 								= &Export from .csv to .ahk
Export to .ahk with static definitions of hotstrings			= Export to .ahk with static definitions of hotstrings
Export to .ahk with dynamic definitions of hotstrings			= Export to .ahk with dynamic definitions of hotstrings
Exported												= Exported
Facilitate working with AutoHotkey triggerstring and hotstring concept, with GUI and libraries = Facilitate working with AutoHotkey triggerstring and hotstring concept, with GUI and libraries
F3 or Esc: Close Search hotstrings | ↓ ↑ → ←: to change position | Enter: Select definition and close = F3 or Esc: Close Search hotstrings | ↓ ↑ → ←: to change position | Enter: Select definition and close
file! 												= file!
file in Languages subfolder!								= file in Languages subfolder!
file is now created in the following subfolder:				= file is now created in the following subfolder:
Finite timeout?										= Finite timeout?
folder is now created									= folder is now created
Font type												= Font type
fuchsia												= fuchsia
Function												= Function
free													= free
Graphical User Interface									= Graphical User Interface
gray													= gray
green												= green
)"	;A continuation section cannot produce a line whose total length is greater than 16,383 characters. See documentation for workaround.
	TransConst .= "`n
(Join`n `
has been created. 										= has been created.
has been downloaded to the location						= has been downloaded to the location
has been renamed to										= has been renamed to
have to be escaped in the following form:					= have to be escaped in the following form:
Header of library										= Header of library
Help: AutoHotkey Hotstrings reference guide					= Help: AutoHotkey Hotstrings reference guide
Help: Hotstrings application								= Help: Hotstrings application
Hotstring 											= Hotstring
Hotstring added to the file								= Hotstring added to the file
Hotstrings application technical support e-mail: support@hotstrings.com = Hotstrings application technical support e-mail: support@hotstrings.com
Hotstring definitions are now ACTIVE.						= Hotstring definitions are now ACTIVE.
Hotstring definitions are now SUSPENDED.					= Hotstring definitions are now SUSPENDED.
Hotstring definitions are still active.						= Hotstring definitions are still active.
Hotstring has been deleted. Now application will restart itself in order to apply changes, reload the libraries (.csv) = Hotstring has been deleted. Now application will restart itself in order to apply changes, reload the libraries (.csv)
Hotstring menu styling									= Hotstring menu styling
Hotstring was triggered! 								= Hotstring was triggered!
Hotstring moved to the 									= Hotstring moved to the
Hotstring paste from Clipboard delay 1 s 					= Hotstring paste from Clipboard delay 1 s
Hotstring paste from Clipboard delay 						= Hotstring paste from Clipboard delay
Hotstrings											= Hotstrings
Hotstrings have been loaded 								= Hotstrings have been loaded
HTML color RGB value, e.g. 00FF00							= HTML color RGB value, e.g. 00FF00
I wish you good work with Hotstrings and DFTBA (Don't Forget to be Awsome)! = I wish you good work with Hotstrings and DFTBA (Don't Forget to be Awsome)!
If not finite, define tooltip timeout						= If not finite, define tooltip timeout
If sound is enabled, define it							= If sound is enabled, define it
(Any existing files in destination folder will be overwritten). 	= (Any existing files in destination folder will be overwritten).
If you answer ""Yes"" it will overwritten.					= If you answer ""Yes"" it will overwritten.
If you answer ""Yes"" definition existing in another library will not be changed. = If you answer ""Yes"" definition existing in another library will not be changed.
If you answer ""Yes"" it will be overwritten with chosen settings. = If you answer ""Yes"" it will be overwritten with chosen settings.
If you answer ""Yes"", the icon file will be downloaded. If you answer ""No"", the default AutoHotkey icon will be used. = If you answer ""Yes"", the icon file will be downloaded. If you answer ""No"", the default AutoHotkey icon will be used.
If you answer ""Yes"", the existing file will be overwritten. This is recommended choice. If you answer ""No"", new content will be added to existing file. = If you answer ""Yes"", the existing file will be overwritten. This is recommended choice. If you answer ""No"", new content will be added to existing file.
If you answer ""Yes"", then new definition will be created, but seleced special character will not be visible. = If you answer ""Yes"", then new definition will be created, but seleced special character will not be visible.
If you answer ""No"" application will exit.					= If you answer ""No"" application will exit.
If you answer ""No"" edition of the current definition will be interrupted. = If you answer ""No"" edition of the current definition will be interrupted.
(If you answer ""No"", the second one will be used).			= (If you answer ""No"", the second one will be used).
If you answer ""No"", then you will get a chance to fix your new created definition. = If you answer ""No"", then you will get a chance to fix your new created definition.
If you apply ""SI"" or ""MSI"" or ""SE"" output function then some characters like = If you apply ""SI"" or ""MSI"" or ""SE"" output function then some characters like
If you don't apply it, previous changes will be lost.			= If you don't apply it, previous changes will be lost.
If you remove one of the definitions which was multiplied (e.g. duplicated), none of definitions will be active. Therefore It is suggested in order to to enable the second one to reload the application. = If you remove one of the definitions which was multiplied (e.g. duplicated), none of definitions will be active. Therefore It is suggested in order to to enable the second one to reload the application.
Immediate Execute (*) 									= Immediate Execute (*)
Import from .ahk to .csv 								= &Import from .ahk to .csv
Incorrect value. Select custom RGB hex value. Please try again.	= Incorrect value. Select custom RGB hex value. Please try again.
(In default folder Config.ini is protected among others against changes implied by other users). = (In default folder Config.ini is protected among others against changes implied by other users).
In order to display library content please at first select hotstring library = In order to display library content please at first select hotstring library
In order to restore default configuration, the current Config.ini file will be deleted. This action cannot be undone. Next application will be reloaded and upon start the Config.ini with default settings will be created. = In order to restore default configuration, the current Config.ini file will be deleted. This action cannot be undone. Next application will be reloaded and upon start the Config.ini with default settings will be created.
information											= information
Inside Word (?) 										= Inside Word (?)
In order to add similar definition to existing one use C option for both definitions (old and new) and change the case of triggerstrings. = In order to add similar definition to existing one use C option for both definitions (old and new) and change the case of triggerstrings.
In order to aplly new font style it's necesssary to reload the application. 	= In order to aplly new font style it's necesssary to reload the application.
In order to aplly new font type it's necesssary to reload the application. 	= In order to aplly new font type it's necesssary to reload the application.
In order to aplly new size of margin it's necesssary to reload the application. = In order to aplly new size of margin it's necesssary to reload the application.
In order to aplly new style it's necesssary to reload the application. 		= In order to aplly new style it's necesssary to reload the application.
In order to change existing library filename at first select one from drop down list. = In order to change existing library filename at first select one from drop down list.
In order to edit library header please at first select library name from drop down list. = In order to edit library header please at first select library name from drop down list.
In order to Delete selected library filename at first select one from drop down list. = In order to Delete selected library filename at first select one from drop down list.
In order to display library header please at first select library name from drop down list. = In order to display library header please at first select library name from drop down list.
Insufficient length of license key. Do you want to try again?	= Insufficient length of license key. Do you want to try again?
is added in section  [GraphicalUserInterface] of Config.ini		= is added in section  [GraphicalUserInterface] of Config.ini
is empty at the moment.									= is empty at the moment.
Introduction											= Introduction
It had expired.										= It had expired.
It means other script threads are still running. Triggerstring tips are off for your convenience. = It means other script threads are still running. Triggerstring tips are off for your convenience.
It means triggerstring tips state is restored and hotstring definitions will be triggered as usual.		= It means triggerstring tips state is restored and hotstring definitions will be triggered as usual.
Keyboard or mouse scrolling								= Keyboard or mouse scrolling
Keyboard or mouse selection								= Keyboard or mouse selection
\Languages\`nMind that Config.ini Language variable is equal to 	= \Languages\`nMind that Config.ini Language variable is equal to
Last hotstring undo function is currently unsuported for those characters, sorry. = Last hotstring undo function is currently unsuported for those characters, sorry.
Leave this field empty and then press ""Add/Edit hotstring (F9)"" again to get GUI enabling file selection. = Leave this field empty and then press ""Add/Edit hotstring (F9)"" again to get GUI enabling file selection.
Let's make your PC personal again... 						= Let's make your PC personal again...
User Data: move it to new location					= User Data: move it to new location
User Data: restore it to default location				= User Data: restore it to default location
Libraries 											= &Libraries
Library content (F2, context menu)							= Library content (F2, context menu)
Library 												= Library
Library name:											= Library name:
Library export. Please wait... 							= Library export. Please wait...
Library has been exported 								= Library has been exported
Library has been imported. 								= Library has been imported.
License												= License
License activation unsuccessful.							= License activation unsuccessful.
License activated										= License activated
License details										= License details
License instance was not found on this PC / user domain account.	= License instance was not found on this PC / user domain account.
License key was										= License key was
License key was validated								= License key was validated
License ID											= License ID
License key											= License key
License server response do not contain correct id of store or product. = License server response do not contain correct id of store or product.
License status											= License status
License type											= License type
Licensed to											= Licensed to
Light (default)										= Light (default)
lime													= lime
Link file (.lnk) was created in AutoStart folder				= Link file (.lnk) was created in AutoStart folder
Location of application specific data						= Location of application specific data
Loading of (triggerstring, hotstring) definitions from the library file = Loading of (triggerstring, hotstring) definitions from the library file
Loading file											= Loading file
Loaded hotstrings: 										= Loaded hotstrings:
Loading hotstrings from libraries... 						= Loading hotstrings from libraries...
Loading imported library. Please wait...					= Loading imported library. Please wait...
Loaded												= Loaded
Local version											= Local version
Logging of d(t, o, h)									= Logging of d(t, o, h)
Logon name					= Logon name
Log triggered hotstrings									= Log triggered hotstrings
LS:													= LS:
maroon												= maroon
Max. no. of shown tips									= Max. no. of shown tips
Menu hotstring is triggered								= Menu hotstring is triggered
Menu position											= Menu position
Menu position: caret									= Menu position: caret
Menu position: cursor									= Menu position: cursor
MinSendLevel value										= MinSendLevel value
Minus - 												= Minus -
MIT license											= MIT license
Mode of operation										= Mode of operation
Move definition to another library							= Move definition to another library
Move (F8)												= Move (F8)
MSPaint.exe (Paint application) wasn't found or couldn't be run. = MSPaint.exe (Paint application) wasn't found or couldn't be run.
navy													= navy
New definition is identical with existing one. Please try again.	= New definition is identical with existing one. Please try again.
New location:											= New location:
New location (default):									= New location (default):
New settings are now applied.							     = New settings are now applied.
New shortcut (hotkey)									= New shortcut (hotkey)
never												= never
Next the default language file (English.txt) will be deleted,	= Next the default language file (English.txt) will be deleted,
No													= No
no													= no
No Backspace (B0) 										= No Backspace (B0)
No EndChar (O) 										= No EndChar (O)
No libraries have been found!								= No libraries have been found!
No license key was found in Config.ini.						= No license key was found in Config.ini.
Not Case-Conforming (C1)									= Not Case-Conforming (C1)
not relevant											= not relevant
Capitalize each word (C2)								= Capitalize each word (C2)
Nothing to do to me, Config.ini is already where you want it to be.	= Nothing to do to me, Config.ini is already where you want it to be.
Now application must be restarted (into default mode) in order to apply settings from new location. = Now application must be restarted (into default mode) in order to apply settings from new location.
Now application must be restarted (into default mode) in order to exit administrator mode. = Now application must be restarted (into default mode) in order to exit administrator mode.
Now application must be restarted (into default mode) in order to reload libary files from new location. = Now application must be restarted (into default mode) in order to reload libary files from new location.
Number of characters for tips 							= &Number of characters for tips
Number of fired hotstrings								= Number of fired hotstrings
Number of loaded d(t, o, h)								= Number of loaded d(t, o, h)
of													= of
OK													= &OK
Old location:											= Old location:
olive												= olive
On start-up the local version of application was compared with repository version and difference was discovered: = On start-up the local version of application was compared with repository version and difference was discovered:
Open current log (view only)								= Open current log (view only)
Open Config.ini in your default editor						= Open Config.ini in your default editor
Open Config.ini folder in Windows Explorer					= Open Config.ini folder in Windows Explorer
Open log folder in Windows Explorer						= Open log folder in Windows Explorer
Open libraries folder in Windows Explorer					= Open libraries folder in Windows Explorer
Opening Curly Bracket { 									= Opening Curly Bracket {
Opening Round Bracket ( 									= Opening Round Bracket (
Opening Square Bracket [ 								= Opening Square Bracket [
options												= options
or													= or
Out. Fun.												= Out. Fun.
question												= question
Question Mark ? 										= Question Mark ?
Quote "" 												= Quote ""
Path to executable file is blank. Do you want to select it now from inteactive GUI? = Path to executable file is blank. Do you want to select it now from inteactive GUI?
Path to picture file is blank. Do you want to select it now from inteactive GUI?			= Path to picture file is blank. Do you want to select it now from inteactive GUI?
Pause												= Pause
Perhaps check if any other application (like File Manager) do not occupy folder to be removed. = Perhaps check if any other application (like File Manager) do not occupy folder to be removed.
Phrase to search for:									= Phrase to search for:
Picture (P)											= Picture (P)
pixels												= pixels
Please contact support at support@hotstrings.com if in doubts. Press Ctrl + C to copy this message into clipboard for future reference. = Please contact support at support@hotstrings.com if in doubts. Press Ctrl + C to copy this message into clipboard for future reference.
Please enter below your license number						= Please enter below your license number
Please try again.										= Please try again.
Please wait, uploading .csv files... 						= Please wait, uploading .csv files...
Position of this window is saved in Config.ini.				= Position of this window is saved in Config.ini.	
premium												= premium
Preview												= &Preview
Programm												= Programm
Public library:										= Public library:
purple												= purple
question												= question
)"
	TransConst .= "`n
(Join`n `
Recognized encoding of the file:							= Recognized encoding of the file:
red													= red
Reload												= Reload
reload Hotstrings application								= reload Hotstrings application
Reload in default mode									= Reload in default mode
Reload in silent mode									= Reload in silent mode
reloaded and fresh language file (English.txt) will be recreated. = reloaded and fresh language file (English.txt) will be recreated.
Rename selected library filename							= Rename selected library filename
Hotstring text is blank. Do you want to proceed? 				= Hotstring text is blank. Do you want to proceed?
Repository version										= Repository version
Required content is copied to the Clipboard					= Required content is copied to the Clipboard
Required encoding: UTF-8 with BOM. Application will exit now.	= Required encoding: UTF-8 with BOM. Application will exit now.
Reset Recognizer (Z)									= Reset Recognizer (Z)
Restore default										= Restore default
Restore default configuration								= Restore default configuration
Row													= Row
Run (R)												= Run (R)
run web browser, enter Hotstrings webpage					= run web browser, enter Hotstrings webpage
Sandbox												= Sandbox
Save && Close											= Save && Close
Save position of application window	 					= &Save position of application window
Save window position									= Save window position
Saved												= Saved
Saving of sorted content into .csv file (library)				= Saving of sorted content into .csv file (library)
Application Data: move it to new location			= Application Data: move it to new location
Application Data: restore it to default location		= Application Data: restore it to default location
Search by: 											= Search by:
Search Hotstrings 										= Search Hotstrings
Search (F3)											= &Search (F3)
Select a row in the list-view, please! 						= Select a row in the list-view, please!
Select executable file									= Select executable file
Select folder where ""Hotstrings"" folder will be moved.		= Select folder where ""Hotstrings"" folder will be moved.
Select folder where libraries (*.csv  files) will be moved.		= Select folder where libraries (*.csv  files) will be moved.
Select hotstring library									= Select hotstring library
Selected definition d(t, o, h) will be deleted. Do you want to proceed? 	= Selected definition d(t, o, h) will be deleted. Do you want to proceed?
Select hotstring output function 							= Select hotstring output function
Select library file to be deleted							= Select library file to be deleted
Select picture filename									= Select picture filename
Select the target library: 								= Select the target library:
Select triggerstring option(s)							= Select triggerstring option(s)
selection												= selection
Semicolon ; 											= Semicolon ;
SendLevel value										= SendLevel value
Send Raw (R)											= Send Raw (R)
Set Clipboard Delay										= Set Clipboard Delay
Set delay												= Set delay
Set triggerstring tip(s) tooltip timeout					= Set triggerstring tip(s) tooltip timeout
Set parameters of menu sound								= Set parameters of menu sound
Set parameters of triggerstring sound						= Set parameters of triggerstring sound
Shortcut (hotkey) definition								= Shortcut (hotkey) definition
Shortcut (hotkey) definitions								= Shortcut (hotkey) definitions
Shortcuts available for active triggerstring tips:			= Shortcuts available for active triggerstring tips:
Shortcuts available for hotstring menu:						= Shortcuts available for hotstring menu:
show application statistics								= show application statistics
Show intro											= Show intro
Show Introduction window after application is restarted?		= Show Introduction window after application is restarted?
Show library header										= Show library header
show main application GUI								= show main application GUI
Show Sandbox											= Show Sandbox
Events: signalling										= Events: signalling
Silent mode											= Silent mode
silver												= silver
Size of font											= Size of font
Size of margin:										= Size of margin:
Slash / 												= Slash /
Something went wrong during hotstring setup					= Something went wrong during hotstring setup
Something went wrong on time of file removal.				= Something went wrong on time of file removal.
Something went wrong on time of library file selection or you've cancelled. = Something went wrong on time of library file selection or you've cancelled.
Something went wrong on time of file rename. Perhaps file was occupied by any process? = Something went wrong on time of file rename. Perhaps file was occupied by any process?
Something went wrong on time of moving Config.ini file. This operation is aborted. = Something went wrong on time of moving Config.ini file. This operation is aborted.
Something went wrong with disabling of existing hotstring		= Something went wrong with disabling of existing hotstring
Something went wrong with enabling of existing hotstring		= Something went wrong with enabling of existing hotstring
Something went wrong with (triggerstring, hotstring) creation	= Something went wrong with (triggerstring, hotstring) creation
Something went wrong with hotstring deletion					= Something went wrong with hotstring deletion
Something went wrong with hotstring EndChars					= Something went wrong with hotstring EndChars
Something went wrong with link file (.lnk) creation			= Something went wrong with link file (.lnk) creation
Something went wrong with moving of ""Hotstrings"" folder. This operation is aborted. = Something went wrong with moving of ""Hotstrings"" folder. This operation is aborted.
Something went wrong with moving of ""Libraries"" folder. This operation is aborted. = Something went wrong with moving of ""Libraries"" folder. This operation is aborted.
Something went wrong with removal of old ""Hotstrings"" folder.	= Something went wrong with removal of old ""Hotstrings"" folder.
Sound disable											= Sound disable
Sound duration [ms]										= Sound duration [ms]
Sound enable											= Sound enable
Sound frequency										= Sound frequency
Sound test											= Sound test
Sorting order											= Sorting order
Sorry, it's not allowed to use combination of Caps Lock, Scroll Lock and Num Lock for the same purpose. = Sorry, it's not allowed to use combination of Caps Lock, Scroll Lock and Num Lock for the same purpose.
Sorry, it's not allowed to use ordinary hotkey combined with Caps Lock or Scroll Lock or Num Lock. = Sorry, it's not allowed to use ordinary hotkey combined with Caps Lock or Scroll Lock or Num Lock.
Sorry, your computer data do not match with license information. Application will exit now. If you think this is application error please contact our support showing the following data. If you press Ctrl + C content of this message for your convenience will be copied in text mode to clipboard. = Sorry, your computer data do not match with license information. Application will exit now. If you think this is application error please contact our support showing the following data. If you press Ctrl + C content of this message for your convenience will be copied in text mode to clipboard.
Sorry, your license is no longer active.					= Sorry, your license is no longer active.
""SP"" or SendPlay may have no effect at all if UAC is enabled, even if the script is running as an administrator. For more information, refer to the AutoHotkey FAQ (help). = ""SP"" or SendPlay may have no effect at all if UAC is enabled, even if the script is running as an administrator. For more information, refer to the AutoHotkey FAQ (help).
Space												= Space
Special function 1 (S1)									= Special function 1 (S1)
Special function 2 (S2)									= Special function 2 (S2)
Specified definition of hotstring has been deleted			= Specified definition of hotstring has been deleted
Standard executable (Ahk2Exe.exe)							= Standard executable (Ahk2Exe.exe)
started												= started
Start-up time											= Start-up time
Static hotstrings 										= &Static hotstrings
Static triggerstring / hotstring menus						= Static triggerstring / hotstring menus
Style of GUI											= Style of GUI
Such file already exists									= Such file already exists
Support: technical issue request							= Support: technical issue request
Suspend all tips										= Suspend all tips
Suspend Hotstrings and all tips							= Suspend Hotstrings and all tips
suspend triggerstrings tips and hotstrings					= suspend triggerstrings tips and hotstrings
)"

TransConst .= "`n
(Join`n `
Tab 													= Tab 
teal													= teal
Test styling											= Test styling
The application										= The application
The application will be reloaded with the new language file. 	= The application will be reloaded with the new language file.
The default											= The default
The default language file (English.txt) will be deleted (it will be automatically recreated after restart). However if you use localized version of language file, you'd need to download it manually. = The default language file (English.txt) will be deleted (it will be automatically recreated after restart). However if you use localized version of language file, you'd need to download it manually.
The definition											= The definition
The executable file is prepared by Ahk2Exe and compressed by mpress.exe: = The executable file is prepared by Ahk2Exe and compressed by mpress.exe:
The executable file is prepared by Ahk2Exe and compressed by upx.exe: = The executable file is prepared by Ahk2Exe and compressed by upx.exe:
The executable file is prepared by Ahk2Exe, but not compressed:	= The executable file is prepared by Ahk2Exe, but not compressed:
The file which you want to download from Internet, already exists on your local harddisk. Are you sure you want to download it? = The file which you want to download from Internet, already exists on your local harddisk. Are you sure you want to download it? `n`n If you answer ""yes"", your local file will be overwritten. If you answer ""no"", download will be continued.
The ""Hotstrings"" folder was successfully moved to the new location. = The ""Hotstrings"" folder was successfully moved to the new location.
The icon file											= The icon file
The already imported file already existed. As a consequence some (triggerstring, hotstring) definitions could also exist and ""Total"" could be incredible. Therefore application will be now restarted in order to correctly apply the changes. = The already imported file already existed. As a consequence some (triggerstring, hotstring) definitions could also exist and ""Total"" could be incredible. Therefore application will be now restarted in order to correctly apply the changes.
The ""Libraries"" folder was successfully moved to the new location. = The ""Libraries"" folder was successfully moved to the new location.
The library  											= The library 
The file path is: 										= The file path is:
The following file(s) haven't been downloaded as they are already present in the location = The following file(s) haven't been downloaded as they are already present in the location
the following line is found:								= the following line is found:
The ""Hotstrings"" folder was successfully moved to the new location: = The ""Hotstrings"" folder was successfully moved to the new location:
The ""Libraries"" folder was successfully moved to the new location. = The ""Libraries"" folder was successfully moved to the new location.
The library has been deleted, its content have been removed from memory. = The library has been deleted, its content have been removed from memory.
The [LicenseInfo] section will be removed from Congig.ini. When run next time, prompt to enter valid license key will be displayed. = The [LicenseInfo] section will be removed from Congig.ini. When run next time, prompt to enter valid license key will be displayed.
The old ""Hotstrings"" folder was successfully removed.		= The old ""Hotstrings"" folder was successfully removed.
There is no Libraries subfolder and no lbrary (*.csv) file exists! = There is no Libraries subfolder and no lbrary (*.csv) file exists!
There is no ""Log"" subfolder. It is now created in parallel with Libraries subfolder. = There is no ""Log"" subfolder. It is now created in parallel with Libraries subfolder.
The parameter Language in section [GraphicalUserInterface] of Config.ini is missing. = The parameter Language in section [GraphicalUserInterface] of Config.ini is missing.
The selected library file will be deleted. The content of this library will be unloaded from memory. = The selected library file will be deleted. The content of this library will be unloaded from memory.
The script											= The script
The selected file is empty. Process of import will be interrupted. = The selected file is empty. Process of import will be interrupted.
At first select library name which you intend to delete.		= At first select library name which you intend to delete.
The selected triggerstring already exists in destination library file: = The selected triggerstring already exists in destination library file:
The triggerstring										= The triggerstring
The (triggerstring, hotstring) definitions have been uploaded from library file = The (triggerstring, hotstring) definitions have been uploaded from library file
The (triggerstring, hotstring) definitions stored in the following library file have been unloaded from memory = The (triggerstring, hotstring) definitions stored in the following library file have been unloaded from memory
There is no											= There is no
There was no Languages subfolder, so one now is created.		= There was no Languages subfolder, so one now is created.
This instance of Hotstrings application is licensed for the following data = This instance of Hotstrings application is licensed for the following data
This isn't correct license key. Do you want to try again?		= This isn't correct license key. Do you want to try again?
This library:											= This library:
This line do not comply to format required by this application.  = This line do not comply to format required by this application.
This operation is aborted.								= This operation is aborted.
The old version is already overwritten.						= The old version is already overwritten.
This option is valid 									= In case you observe some hotstrings aren't pasted from clipboard increase this value. `nThis option is valid for CL and MCL hotstring output functions. 
Timeout value [ms]										= Timeout value [ms]
Tilde (~) key modifier									= Tilde (~) key modifier
Tip: If you copy text from PDF file it's adviced to remove them. = Tip: If you copy text from PDF file it's adviced to remove them.
Tips are shown after no. of characters						= Tips are shown after no. of characters
(Together with accompanying files and subfolders).			= (Together with accompanying files and subfolders).
to activate											= to activate
To move folder into ""Program Files"" folder you must allow admin privileges to ""Hotstrings"", which will restart to move its folder. = To move folder into ""Program Files"" folder you must allow admin privileges to ""Hotstrings"", which will restart to move its folder.
to toggle												= to toggle
toggle triggerstrings tips and hotstrings					= toggle triggerstrings tips and hotstrings
Toggle main GUI										= Toggle main GUI
Toggle trigger characters (↓ or EndChars)					= &Toggle trigger characters (↓ or EndChars)
Toggle triggerstring tips								= Toggle triggerstring tips
Tooltip: ""Hotstring was triggered""						= Tooltip: ""Hotstring was triggered""
Tooltip: ""Undid the last hotstring""						= Tooltip: ""Undid the last hotstring""
Tooltip disable										= Tooltip disable
Tooltip enable											= Tooltip enable
Tooltip position										= Tooltip position
Tooltip test											= Tooltip test
Tooltip timeout										= Tooltip timeout
to undo.												= to undo.
(triggerstring, hotstring) definitions						= (triggerstring, hotstring) definitions
Trigger Opt.											= Trigger Opt.
Triggers												= Triggers
Triggerstring 											= Triggerstring
Triggerstring cannot be empty if you wish to add new hotstring	= Triggerstring cannot be empty if you wish to add new hotstring
Triggerstring contains only white characters. Are you sure to continue? = Triggerstring contains only white characters. Are you sure to continue?
Triggerstring / hotstring behaviour						= Triggerstring / hotstring behaviour
Triggerstring sound duration [ms]							= Triggerstring sound duration [ms]
Triggerstring sound frequency range						= Triggerstring sound frequency range
Triggerstring tips 										= Triggerstring tips
Triggerstring tips  are now								= Triggerstring tips  are now
Triggerstring tips have been loaded from the following library file to memory: = Triggerstring tips have been loaded from the following library file to memory:
Triggerstring tips related to the following library file have been unloaded from memory: = Triggerstring tips related to the following library file have been unloaded from memory:
Triggerstring tips styling								= Triggerstring tips styling
Triggerstring tooltip timeout in [ms]						= Triggerstring tooltip timeout in [ms]
Type													= Type
Typeface color											= Typeface color
Typeface font											= Typeface font
Typeface size											= Typeface size
)"

TransConst .= "`n
(Join`n `
Underscore _											= Underscore _
Undo the last hotstring									= Undo the last hotstring
Undo the last hotstring									= Undo the last hotstring
up													= up
Undid the last hotstring 								= Undid the last hotstring
Unexpected problem on time of deleting the file ""\Languages\English.txt"". Exiting. = Unexpected problem on time of deleting the file ""\Languages\English.txt"". Exiting.
valid												= valid
Valid till											= Valid till
Version / Update										= Version / Update
Version												= Version
Visit public libraries webpage							= Visit public libraries webpage
warning												= warning
Warning, code generated automatically for definitions based on menu, see documentation of Hotstrings application for further details. = Warning, code generated automatically for definitions based on menu, see documentation of Hotstrings application for further details.
was just deleted from									= was just deleted from
was successfully downloaded.								= was successfully downloaded.
wasn't found or couldn't be run							= wasn't found or couldn't be run
Welcome to Hotstrings application!							= Welcome to Hotstrings application!
Windows key modifier									= Windows key modifier
When triggerstring event takes place, sound is emitted according to the following settings. = When triggerstring event takes place, sound is emitted according to the following settings.
white												= white
Would you like to change the current ""Libraries"" folder location? = Would you like to change the current ""Libraries"" folder location?
Would you like to change Config.ini file location to default one? = Would you like to change Config.ini file location to default one?
Would you like to change Config.ini file location to folder where is ""Hotstrings"" script / app? = Would you like to change Config.ini file location to folder where is ""Hotstrings"" script / app?
Would you like to download the icon file?					= Would you like to download the icon file?
Would you like to move ""Libraries"" folder and all *.csv files to the new location? = Would you like to move ""Libraries"" folder and all *.csv files to the new location?
Would you like now to reload it in order to run the just downloaded version? = Would you like now to reload it in order to run the just downloaded version?
Would you like to move ""Hotstrings"" script / application to default location? = Would you like to move ""Hotstrings"" script / application to default location?
Would you like to move ""Hotstrings"" script / application somewhere else? = Would you like to move ""Hotstrings"" script / application somewhere else?
Would you like to move ""Libraries"" folder to this location?	= Would you like to move ""Libraries"" folder to this location?
yellow												= yellow
Yes													= Yes
yes													= yes
You cannot move existing definition to library which is DISABLED. = You cannot move existing definition to library which is DISABLED.
You should receive it by e-mail							= You should receive it by e-mail
You've cancelled this process.							= You've cancelled this process.
You've changed at least one configuration parameter, but didn't yet apply it. = You've changed at least one configuration parameter, but didn't yet apply it.
Your hotstring definition contain one of the following characters: = Your hotstring definition contain one of the following characters:
Your current screen coordinates have changed. For example you've unplugged your laptop from docking station. Your settings in .ini file will be adjusted accordingly. = Your current screen coordinates have changed. For example you've unplugged your laptop from docking station. Your settings in .ini file will be adjusted accordingly.
↓ Click here to select hotstring library ↓					= ↓ Click here to select hotstring library ↓
{Up} or {Down} or {Home} or {End} or {PgUp} or {PgDown}		= {Up} or {Down} or {Home} or {End} or {PgUp} or {PgDown}
ShowInfoText											= In order to display graphical user interface (GUI) of the application just press shortcut: Win + Ctrl + H. `n`nSuggested steps after installation: `n`n1. Download some libraries (files containing (triggerstring, hotstring) definitions. You can do it from application menu:  → Libraries. `n`n2. After downloading of libraries restart application to apply the changes. Again, you can do it from application menu: Application → Restart. `n`n3. Application is preconfigured on the first start. Options available to be configured area available from GUI, application menu → Configuration. `n`n4. Application runs by default in default mode. If you don't wish to modify configuration, `nmay consider to run it in simplified mode: application menu → Application → Reload → Reload in silent mode.
)"
	TransConst .= "`n
(Join`n `
F_TI_ImmediateExecute									= * (asterisk): An EndChar (e.g. Space, ., or Enter) is not required to trigger the hotstring. For example:`n`n:*:j@::jsmith@somedomain.com`n`nThe example above would send its replacement the moment you type the @ character.
F_TI_InsideWord										= ? (question mark): The hotstring will be triggered even when it is inside another word; `n`nthat is, when the character typed immediately before it is alphanumeric. `nFor example, if :?:al::airline is a hotstring, `ntyping ""practical "" would produce ""practicairline "".
F_TI_NoBackSpace										= B0: Automatic backspacing is not done to erase the abbreviation you type. `n`nOne may send ← five times via {left 5}. For example, the following hotstring produces ""<em></em>"" and `nmoves the caret 5 places to the left (so that it's between the tags) `n`n::*b0:<em>::</em>{left 5}
F_TI_NoEndChar											= O: Omit the ending character of auto-replace hotstrings when the replacement is produced. `n`nThis is useful when you want a hotstring to be kept unambiguous by still requiring an ending character, `nbut don't actually want the ending character to be shown on the screen. `nFor example, if :o:ar::aristocrat is a hotstring, typing ""ar"" followed by the spacebar will produce ""aristocrat"" with no trailing space, `nwhich allows you to make the word plural or possessive without having to press Backspace.
F_TI_OptionResetRecognizer								= Z: Resets the hotstring recognizer after each triggering of the hotstring. `n`nIn other words, the script will begin waiting for an entirely new hotstring, eliminating from consideration anything you previously typed. `nThis can prevent unwanted triggerings of hotstrings. 
F_TI_CaseConforming										= By default (if option Case-Sensitive (C) or Not-Case-Sensitive (C1) aren't set) `ncase-conforming hotstrings produce their replacement text in all caps `nif you type the triggerstring in all caps. `n`nIf you type the first letter in caps, `nthe first letter of the replacement will also be capitalized (if it is a letter). `n`nIf you type the case in any other way, the replacement is sent exactly as defined.
F_TI_CaseSensitive										= C: Case sensitive: `n`nWhen you type a triggerstring, `nit must exactly match the case defined.
F_TI_NotCaseConforming									= C1: Do not conform to typed case. `n`nUse this option to make hotstrings case insensitive `nand prevent them from conforming to the case of the characters you actually type.
F_TI_CapitalizeEachWord									= C2: Capitalize each word. `n`nUse this option to capitalize first letter of each word in hotstring `nif the first letter in triggerstring is capital. `nIf the first letter is ordinary, the hotstring will conform casing.
F_TI_EnterTriggerstring									= Enter text of triggerstring. `n`nTip1: If you want to change capitalization in abbreviation, use no triggerstring options. `nE.g. ascii → ASCII. `n`nTip2: If you want exchange triggerstring of abbreviation into full phrase, `nend your triggerstring with ""/"" and `napply Immediate Execute (*) triggerstring option.
F_TI_OptionDisable										= Disables the hotstring. `n`nIf ticked, this option is shown in red color. `nBe aware that triggerstring tooltips (if enabled) `nare displayed even for disabled (triggerstring, hotstring) definitions.
TI_SHOF												= Select function, which will be used to show up hotstring. `n`nAvailable options: `n`nSendInput (SI): SendInput is generally the preferred method because of its superior speed and reliability. `nUnder most conditions, SendInput is nearly instantaneous, even when sending long strings. `nSince SendInput is so fast, it is also more reliable because there is less opportunity for some other window to pop up unexpectedly `nand intercept the keystrokes. Reliability is further improved by the fact `nthat anything the user types during a SendInput is postponed until afterward. `n`nClipboard (CL): hotstring is copied from clipboard. `nIn case of long hotstrings this is the fastest method. The downside of this method is delay `nrequired for operating system to paste content into specific window. `nIn order to change value of this delay see ""Clipboard Delay (F7)"" option in menu. `n`nMenu and SendInput (MSI): One triggerstring can be used to enter up to 7 hotstrings which are desplayed in form of list (menu). `nFor entering of chosen hotstring again SendInput (SI) is used. `n`nMenu & Clipboard (MCL): One triggerstring can be used to enter up to 7 hotstrings which are desplayed in form of list (menu). `nFor entering of chosen hotstring Clipboard (CL) is used. `n`nSenRaw (R): All subsequent characters, including the special characters ^+!#{}, `nto be interpreted literally rather than translating {Enter} to Enter, ^c to Ctrl+C, etc. `n`nSendPlay (SP): SendPlay's biggest advantage is its ability to ""play back"" keystrokes and mouse clicks in a broader variety of games `nthan the other modes. `nFor example, a particular game may accept hotstrings only when they have the SendPlay option. `n`nSendEvent (SE): SendEvent sends keystrokes using the same method as the pre-1.0.43 Send command.
TI_EnterHotstring										= Enter hotstring corresponding to the triggerstring. `n`nTip: You can use special key names in curved brackets. E.g.: {left 5} will move caret by 5x characters to the left.`n{Backspace 3} or {BS 3} will remove 3 characters from the end of triggerstring. `n`nTo send an extra space or tab after a replacement, include the space or tab at the end of the replacement `nbut make the last character an accent/backtick (`). `nFor example: `n:*:btw::By the way ``n`nBy default (that is, if SendRaw isn't used), the characters ^+!#{} have a special meaning. `nTo send those keys on its own, enclose the name in curly braces. `nFor example: {+}48 600 000.
TI_AddComment											= You can add optional (not mandatory) comment to new (triggerstring, hotstring) definition. `n`nThe comment can be max. 96 characters long. `n`nTip: Put here link to Wikipedia definition or any other external resource containing reference to entered definition.
TI_SelectHotstringLib									= Select .csv file containing (triggerstring, hotstring) definitions. `nBy default those files are located in C:\Users\<UserName>\Documents folder.
TI_LibraryContent										= After pressing (F2) you can move up or down in the table by pressing ↑ or ↓ keys. `n`nIf you press Enter key when any row is selected, its content will be automatically loaded to left part of this window. `n`nPress context key or Shift + F10 to display context menu with additional options: `n     * Show library header `n     * Edit library header `n`n     * Move definition to another library `n     * Delete selected definition `n     * Enable/disable selected definition
TI_Sandbox											= Sandbox is used as editing field where you can test `nany (triggerstring, hotstring) definition, e.g. for testing purposes. `nThis area can be switched on/off and moves when you rescale `nthe main application window.
TI_LibStats											= Amount of definitions in currently selected library to `ntotal amount of currently loaded definitions from all libraries.
F_HK_CallGUIInfo										= Remark: this hotkey is operating system wide, so before changing it be sure it's not in conflict with any other system wide hotkey.`n`nIt opens Graphical User Interface (GUI) of Hotstrings, even if window is minimized or invisible.
F_HK_GeneralInfo										= You can enter any hotkey as combination of Shift, Ctrl, Alt modifier and any other keyboard key. `nIf you wish to have hotkey where Win modifier key is applied, use the checkbox separately.
F_HK_ClipCopyInfo										= Remark: this hotkey is operating system wide, so before changing it be sure it's not in conflict with any other system wide hotkey. `n`nWhen Hotstrings window exists (it could be minimized) pressing this hotkey copies content of clipboard to ""Enter hotstring"" field. `nThanks to that you can prepare new definition much quicker.
F_HK_UndoInfo											= Remark: this hotkey is operating system wide, so before changing it be sure it's not in conflict with any other system wide hotkey.`n`n When pressed, it undo the very last hotstring. Please note that result of undo depends on cursor position.
F_HK_TildeModInfo										= When the hotkey fires, its key's native function will not be blocked (hidden from the system). 
F_HK_ToggleTtInfo										= Toggle visibility of all triggerstring tips. Advice: use ScrollLock or CapsLock for that purpose.
T_HMenuPosition										= Specify where ""hotstring menu"" should be displayed by default.`n`nWarning: some applications do not accept ""caret"" position. `n`nThen automatically ""cursor"" position is followed.
T_SBackgroundColorInfo									= Select from drop down list predefined color (one of 16 HTML colors) `nor select Custom one and then provide RGB value in HEX format (e.g. FF0000 for red). `nThe selected color will be displayed as background for on-screen menu.
T_STypefaceColor										= Select from drop down list predefined color (one of 16 HTML colors) `nor select Custom one and then provide RGB value in HEX format (e.g. FF0000 for red). `nThe selected color will be displayed as font color for on-screen menu.
T_STypefaceFont										= Select from drop down list predefined font type. `nThe selected font type will be used in on screen menu.
T_STypefaceSize										= Select from drop down list predefined size of font. `nThe selected font size will be used in on screen menu.
T_StylPreview											= Press the ""Test styling"" button to get look & feel of selected styling settings below.
T_SoundEnable											= Sound can be emitted each time when event takes place. `nOne can specify sound frequency and duration.`n`nYou may slide the control by the following means: `n`n1) dragging the bar with the mouse; `n2) clicking inside the bar's track area with the mouse; `n3) turning the mouse wheel while the control has focus or `n4) pressing the following keys while the control has focus: ↑, →, ↓, ←, PgUp, PgDn, Home, and End. `n`nPgUp / PgDn step: 50 [ms]; `nInterval:         150 [ms]; `nRange:            50 ÷ 2 000 [ms]. `n`nTip: Recommended time is between 200 to 400 ms. `n`nPgUp / PgDn step: 50 [ms]; `nInterval:         150 [ms]; `nRange:            50 ÷ 2 000 [ms]. `n`nTip: Recommended time is between 200 to 400 ms.
T_TooltipEnable										= You can enable or disable the following tooltip: ""Hotstring was triggered! [Shortcut] to undo."" `nIf enabled, this tooltip is shown each time when even of displaying hotstring upon triggering it takes place. `nNext you can set accompanying features like timeout, position and even sound. 
T_TooltipPosition										= Specify where tooltip should be displayed by default.`n`nWarning: some applications do not accept ""caret"" position. `n`nThen automatically ""cursor"" position is followed.
T_TooltipTimeout										= The infinite tooltip stays displayed on a screen till next event is triggered. `nIt's adviced to set finite tooltip. `n`nYou may slide the control by the following means: `n`n1) dragging the bar with the mouse; `n2) clicking inside the bar's track area with the mouse; `n3) turning the mouse wheel while the control has focus or `n4) pressing the following keys while the control has focus: ↑, →, ↓, ←, PgUp, PgDn, Home, and End. `n`nPgUp / PgDn step: 500 [ms]; `nInterval:         500 [ms]; `nRange:            1000 ÷ 10 000 [ms].
T_TriggerstringTips										= The triggerstring tips are displayed to help you recognize which triggerstrings are defined or available. `nThey are displayed in form of short list (tooltips).`n`nYou can define styling of triggerstring tips: Menu → Configuration.
T_TtSortingOrder										= The sorting order let you define how the triggerstring tips list positions are sorted out. `nThere are two options, which can be active on the same time: alphabetically or by length. `nYou can check out the differences by pressing the Tooltip test button.
T_TtMaxNoOfTips										= Maximum length of the triggerstring tips list. `n`nIf currently available list is longer, only the specified amount of triggerstring tips is displayed. `nPlease mind that displayed list could be just shorter.
T_TtNoOfChars											= It is possible to configure triggerstring tips to be displayed only if some first characters are already entered. `nE.g. if this parameter is set to 2, the first list appears if 2 or more characters of any existing triggerstring tip are entered.
T_ATT1												= If active triggerstring tips are enabled, then it is possible to use keyboard shortcuts `nto enter one of the triggerstrings from currently displayed list. `n`nActive triggerstring shortcuts: `n`nControl + Enter to enter any of the triggerstring tips `nControl + ↓ or Control + ↑ to move down or up on the list `n Control + Tab or Control + Shift + Tab to move down or up on the list.
T_TtComposition										= `n`nOf course if additional columns are chosen, window will become wider.
T_SMT2												= This option let's you to display permanent, ""static"" window `nwhere you can always find up-to-date ""triggerstring tips"" and ""hotstring menus"". `n`nOptions are combinations of other ""events"" options (set in other tabs).
)"	
	TransA					:= {}	;this associative array (global) is used to store translations of this application text strings
	
	if (decision[1] = "create")
		FileAppend, % TransConst, % A_ScriptDir . "\Languages\English.txt", UTF-8 
	
	if (decision[1] = "load")
	{
		FileRead, v_TheWholeFile, % A_ScriptDir . "\Languages\" . ini_Language
		F_ParseLanguageFile(v_TheWholeFile)
		return
	}
	F_ParseLanguageFile(TransConst)
}
; ------------------------------------------------------------------------------------------------------------------------------------
F_ParseLanguageFile(argument)
{
	global	;assume-global mode
	local 	tick := false, key := "", val := ""
			,WithoutLastChar := 0,	AllChars := 0,		LastChar := ""
	
	Loop, Parse, argument, =`n, %A_Space%%A_Tab%`r
	{
		if ((InStr((LTrim(A_LoopField)), ";") = 1) or ((StrLen(A_LoopField) = 1) and (A_LoopField = "`r"))) ;this line don't take into account lines starting with semicolon (;) or empty
			Continue
		if (A_LoopField)	;this line is necessary for variant with plain variable (without file loading)
		{
			if !(tick)
			{
				key := A_LoopField
,				tick := true
			}
			else
			{
				val := A_LoopField
,				tick := false
			}			
			TransA[key] := val
		}
	}
}
; ------------------------------------------------------------------------------------------------------------------------------------
F_LoadDefinitionsFromFile(nameoffile) ; load definitions d(t, o, h) from library file (.csv) into memory and to tables: -> F_CreateHotstring
{
	global ;assume-global mode
	local 	name := SubStr(nameoffile, 1, -4) ;filename without extension
, 			TheWholeFile := ""
,			BegCom := false
,			Triggerstring := "", Hotstring := "", options := ""
	
	F_CheckFileEncoding(ini_HADL . "\" . nameoffile)	;additional check if library files encoding is equal to UTF-8 with BOM 
	FileRead, TheWholeFile, % ini_HADL . "\" . nameoffile

	Loop, Parse, TheWholeFile, `n, `r%A_Space%%A_Tab%
	{
		if (SubStr(A_LoopField, 1, 2) = "/*")	;ignore comments
		{
			BegCom := true
			Continue
		}
		if (BegCom) and (SubStr(A_LoopField, -1) = "*/") ;ignore comments
		{
			BegCom := false
			Continue
		}
		if (BegCom)
			Continue
		if (SubStr(A_LoopField, 1, 1) = ";")	;ignore comments
			Continue
		if (!A_LoopField)	;ignore empty lines
			Continue
		
		F_CreateHotstring(A_LoopField, nameoffile)
		Loop, Parse, A_LoopField, % c_TextDelimiter
		{
			Switch A_Index
			{
				Case 1:	
					options := A_LoopField
					a_TriggerOptions.Push(A_LoopField)
				Case 2:	
					Triggerstring := A_LoopField
					a_Triggerstring.Push(Triggerstring)
				Case 3:	a_OutputFunction.Push(A_LoopField)
				Case 4:	a_EnableDisable.Push(A_LoopField)
				Case 5:	
					Hotstring := A_LoopField
					if (InStr(A_LoopField, c_MHDelimiter))
						options := "multi"
					else
						options := ""
					a_Hotstring.Push(A_LoopField)
				Case 6:	a_Comment.Push(A_LoopField)
			}
		}
		++v_TotalHotstringCnt
		a_Library.Push(name) ;for function Search
	}
	UpdateLibraryCounter(v_LibHotstringCnt, v_TotalHotstringCnt)
}
 ; ------------------------------------------------------------------------------------------------------------------------------------
F_CountUnicodeChars(ByRef String)
{
	HowManyCharacters := 0, Result := 0
	if (RegExMatch(String, "i)\{U\+[[:xdigit:]]{4,6}}") = 0)
		return, 0
	else
	{
		String := RegExReplace(String, "i)\{U\+[[:xdigit:]]{4,6}}", Replacement := "", HowManyCharacters := "")
		return, HowManyCharacters
	}
}
; ------------------------------------------------------------------------------------------------------------------------------------
F_CountTrigConstants(ByRef String)
{
	HowManyCharacters := 0, Result := 0
	if (InStr(String, "``n"))
	{
		String := StrReplace(String, "``n", "", HowManyCharacters)
,		Result += HowManyCharacters			
,		HowManyCharacters := 0
	}
	if (InStr(String, "``t"))
	{
		String := StrReplace(String, "``t", "", HowManyCharacters)
,		Result += HowManyCharacters			
,		HowManyCharacters := 0
	}
	return, Result
}
; ------------------------------------------------------------------------------------------------------------------------------------
F_CountAHKconstants(ByRef String)
{
	HowManyCharacters := 0, Result := 0

	if (InStr(String, "``r``n"))
	{
		String := StrReplace(String, "``r``n", "", HowManyCharacters)
,		Result += HowManyCharacters
,		HowManyCharacters := 0
	}
	if (InStr(String, "``r"))
	{
		String := StrReplace(String, "``r", "", HowManyCharacters)
,		Result += HowManyCharacters			
,		HowManyCharacters := 0
	}
	if (InStr(String, "``n"))
	{
		String := StrReplace(String, "``n", "", HowManyCharacters)
,		Result += HowManyCharacters			
,		HowManyCharacters := 0
	}
	if (InStr(String, "``b"))
	{
		String := StrReplace(String, "``b", "", HowManyCharacters)
,		Result += HowManyCharacters			
,		HowManyCharacters := 0
	}
	if (InStr(String, "``t"))
	{
		String := StrReplace(String, "``t", "", HowManyCharacters)
,		Result += HowManyCharacters			
,		HowManyCharacters := 0
	}
	if (InStr(String, "A_YYYY"))
	{
		String := StrReplace(String, "A_YYYY", "")
,		HowManyCharacters := StrLen(A_YYYY)
,		Result += HowManyCharacters
,		HowManyCharacters := 0
	}
	if (InStr(String, "A_MMMM"))
	{
		String := StrReplace(String, "A_MMMM", "")
,		HowManyCharacters := StrLen(A_MMMM)
,		Result += HowManyCharacters
,		HowManyCharacters := 0
	}
	if (InStr(String, "A_MMM"))
	{
		String := StrReplace(String, "A_MMM", "")
,		HowManyCharacters := StrLen(A_MMM)		
,		Result += HowManyCharacters
,		HowManyCharacters := 0
	}
	if (InStr(String, "A_MM"))
	{
		String := StrReplace(String, "A_MM", "")
,		HowManyCharacters := StrLen(A_MM)		
,		Result += HowManyCharacters
,		HowManyCharacters := 0
	}
	if (InStr(String, "A_DDDD"))
	{
		String := StrReplace(String, "A_DDDD", "")
,		HowManyCharacters := StrLen(A_DDDD)		
,		Result += HowManyCharacters
,		HowManyCharacters := 0
	}
	if (InStr(String, "A_DDD"))
	{
		String := StrReplace(String, "A_DDD", "")
,		HowManyCharacters := StrLen(A_DDD)		
,		Result += HowManyCharacters
,		HowManyCharacters := 0
	}
	if (InStr(String, "A_DD"))
	{
		String := StrReplace(String, "A_DD", "")
,		HowManyCharacters := StrLen(A_DD)		
,		Result += HowManyCharacters
,		HowManyCharacters := 0
	}
	if (InStr(String, "A_WDay"))
	{
		String := StrReplace(String, "A_WDay", "")
,		HowManyCharacters := StrLen(A_WDay)		
,		Result += HowManyCharacters
,		HowManyCharacters := 0
	}
	if (InStr(String, "A_YDay"))
	{
		String := StrReplace(String, "A_YDay", "")
,		HowManyCharacters := StrLen(A_YDay)		
,		Result += HowManyCharacters
,		HowManyCharacters := 0
	}
	if (InStr(String, "A_YWeek"))
	{
		String := StrReplace(String, "A_YWeek", "")
,		HowManyCharacters := StrLen(A_YWeek)		
,		Result += HowManyCharacters
,		HowManyCharacters := 0
	}
	if (InStr(String, "A_Hour"))
	{
		String := StrReplace(String, "A_Hour", "")
,		HowManyCharacters := StrLen(A_Hour)		
,		Result += HowManyCharacters
,		HowManyCharacters := 0
	}
	if (InStr(String, "A_Min"))
	{
		String := StrReplace(String, "A_Min", "")
,		HowManyCharacters := StrLen(A_Min)		
,		Result += HowManyCharacters
,		HowManyCharacters := 0
	}
	if (InStr(String, "A_Sec"))
	{
		String := StrReplace(String, "A_Sec", "")
,		HowManyCharacters := StrLen(A_Sec)		
,		Result += HowManyCharacters
,		HowManyCharacters := 0
	}
	if (InStr(String, "A_MSec"))
	{
		String := StrReplace(String, "A_MSec", "")
,		HowManyCharacters := StrLen(A_MSec)		
,		Result += HowManyCharacters
,		HowManyCharacters := 0
	}
	if (InStr(String, "A_Now"))
	{
		String := StrReplace(String, "A_Now", "")
,		HowManyCharacters := StrLen(A_Now)		
,		Result += HowManyCharacters
,		HowManyCharacters := 0
	}
	if (InStr(String, "A_NowUTC"))
	{
		String := StrReplace(String, "A_NowUTC", "")
,		HowManyCharacters := StrLen(A_NowUTC)		
,		Result += HowManyCharacters
,		HowManyCharacters := 0
	}
	if (InStr(String, "A_TickCount"))
	{
		String := StrReplace(String, "A_TickCount", "")
,		HowManyCharacters := StrLen(A_TickCount)		
,		Result += HowManyCharacters
	}
	return, Result
}
; ------------------------------------------------------------------------------------------------------------------------------------
F_CountSpecialChar(ToFilter, ByRef Haystack)	;counts special characters and filters them out of Haystack
{
	temp			:= SubStr(ToFilter, 1, -1)
,	NeedleRegEx1	:= temp . "}" . "|" . temp . "[[:blank:]]+\d+}" . "|" . temp . "[[:blank:]]+down}" . "|" . temp . "[[:blank:]]+up}"
,	NeedleRegEx2	:= temp . "}" . "|" . temp . "[[:blank:]]+down}" . "|" . temp . "[[:blank:]]+up}"
,	RERCount		:= 0
, 	ToFilterCnt	:= 0
, 	OutputVar   	:= 0

	if (!InStr(Haystack, ToFilter, false)) and (!RegExMatch(Haystack, "i)" . NeedleRegEx1))
		return, 0

	if (RegExMatch(Haystack, "i)" . temp . "[[:blank:]]+\K\d+", OutputVar))	;filter out such sequences as {Shift 5}
	{
		ToFilterCnt += OutputVar
,		Haystack := RegExReplace(Haystack, "i)" . temp . "[[:blank:]]+\d+}", "")
	}
	Haystack := RegExReplace(Haystack, "i)" . NeedleRegEx2, "", RERCount)		;filter out such sequences as "{Sift up}"
	return, ToFilterCnt += RERCount
}
; ------------------------------------------------------------------------------------------------------------------------------------
F_GuiHS4_EnDis(EnDis)	;EnDis = "Disable" or "Enable"
{
	global ;assume-global mode of operation
	static	PS_IdEdit3b := false, PS_IdEdit4b := false, PS_IdEdit5b := false, PS_IdEdit6b := false, PS_IdEdit7b := false, PS_IdEdit8b := false

	Menu, HSMenu, % EnDis, % TransA["Configuration"]
	Menu, HSMenu, % EnDis, % TransA["Search (F3)"]
	Menu, HSMenu, % EnDis, % TransA["Libraries"]
	Menu, HSMenu, % EnDis, % TransA["Clipboard Delay (F7)"]
	Menu, HSMenu, % EnDis, % TransA["Application"]
	Menu, HSMenu, % EnDis, % TransA["About / Help"]

	GuiControl, % EnDis, % IdText1b
	GuiControl, % EnDis, % IdTextInfo1b
	GuiControl, % EnDis, % IdEdit1b
	GuiControl, % EnDis, % IdGroupBox1b
	GuiControl, % EnDis, % IdCheckBox1b
	GuiControl, % EnDis, % IdTextInfo2b
	GuiControl, % EnDis, % IdRadioCaseCCb
	GuiControl, % EnDis, % IdRadioCaseCSb
	GuiControl, % EnDis, % IdRadioCaseC1b
	GuiControl, % EnDis, % IdRadioCaseC2b
	GuiControl, % EnDis, % IdTextInfo3b
	GuiControl, % EnDis, % IdCheckBox3b
	GuiControl, % EnDis, % IdTextInfo4b
	GuiControl, % EnDis, % IdTextInfo5b
	GuiControl, % EnDis, % IdCheckBox4b
	GuiControl, % EnDis, % IdTextInfo6b
	GuiControl, % EnDis, % IdTextInfo7b
	GuiControl, % EnDis, % IdCheckBox5b
	GuiControl, % EnDis, % IdTextInfo8b
	GuiControl, % EnDis, % IdCheckBox8b
	GuiControl, % EnDis, % IdTextInfo9b
	GuiControl, % EnDis, % IdTextInfo10b
	GuiControl, % EnDis, % IdText3b
	GuiControl, % EnDis, % IdTextInfo12b
	GuiControl, % EnDis, % IdDDL1b
	GuiControl, % EnDis, % IdText4b
	GuiControl, % EnDis, % IdTextInfo13b
	GuiControl, % EnDis, % IdEdit2b
	if (EnDis = "Disable")
	{
		GuiControlGet, PS_IdEdit3b, Enabled, % IdEdit3b
		GuiControlGet, PS_IdEdit4b, Enabled, % IdEdit4b
		GuiControlGet, PS_IdEdit5b, Enabled, % IdEdit5b
		GuiControlGet, PS_IdEdit6b, Enabled, % IdEdit6b
		GuiControlGet, PS_IdEdit7b, Enabled, % IdEdit7b
		GuiControlGet, PS_IdEdit8b, Enabled, % IdEdit8b
	}
	if (EnDis = "Enable") and (PS_IdEdit3b)	
		GuiControl, % EnDis, % IdEdit3b
	if (EnDis = "Enable") and (PS_IdEdit4b)	
		GuiControl, % EnDis, % IdEdit4b
	if (EnDis = "Enable") and (PS_IdEdit5b)
		GuiControl, % EnDis, % IdEdit5b
	if (EnDis = "Enable") and (PS_IdEdit6b)	
		GuiControl, % EnDis, % IdEdit6b
	if (EnDis = "Enable") and (PS_IdEdit7b)	
		GuiControl, % EnDis, % IdEdit7b
	if (EnDis = "Enable") and (PS_IdEdit8b)	
		GuiControl, % EnDis, % IdEdit8b

	GuiControl, % EnDis, % IdText5b
	GuiControl, % EnDis, % IdTextInfo14b
	GuiControl, % EnDis, % IdEdit9b
	GuiControl, % EnDis, % IdText6b
	GuiControl, % EnDis, % IdTextInfo15b
	GuiControl, % EnDis, % IdDDL2b
	GuiControl, % EnDis, % IdButton2b
	GuiControl, % EnDis, % IdButton3b
	GuiControl, % EnDis, % IdButton5b
	GuiControl, % EnDis, % IdText10b
	GuiControl, % EnDis, % IdTextInfo17b
	GuiControl, % EnDis, % IdEdit10b
	GuiControl, % EnDis, % IdText2b
	GuiControl, % EnDis, % IdText12b
}
; ------------------------------------------------------------------------------------------------------------------------------------
F_GuiHS4_Create()
{
	global ;assume-global mode of operation
	local x0 := 0, y0 := 0
	
;1. Definition of HS4 GUI.
	Gui, 	HS4: New, 	-Resize +HwndHS4GuiHwnd +OwnDialogs -MaximizeBox, % A_ScriptName . A_Space . A_Space . A_Space . A_Space . A_Space . "(" . F_ParseHotkey(ini_HK_Main, "space") . ")"
	Gui, 	HS4: Margin,	% c_xmarg, % c_ymarg
	Gui,		HS4: Color,	% c_WindowColor, % c_ControlColor
	
;2. Prepare all text objects according to mock-up.
	Gui,		HS4: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, 	HS4: Add, 	Text, 		x0 y0 HwndIdText1b,										% TransA["Enter triggerstring"]
	Gui, 	HS4: Font, 	% "s" . c_FontSize + 2
	Gui,		HS4: Add,		Text,		x0 y0 HwndIdTextInfo1b,									ⓘ
	GuiControl +g, % IdTextInfo1b, % F_TI_EnterTriggerstring
	
	Gui,		HS4: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, 			% c_FontType
	Gui, 	HS4: Add, 	Edit, 		x0 y0 HwndIdEdit1b vv_TriggerString 
	
	Gui,		HS4: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui,		HS4: Add,		GroupBox, 	x0 y0 HwndIdGroupBox1b, 									% TransA["Select triggerstring option(s)"]
	Gui,		HS4: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, 			% c_FontType
	
	Gui, 	HS4: Add, 	CheckBox, 	x0 y0 HwndIdCheckBox1b gF_Checkbox vv_OptionImmediateExecute,	% TransA["Immediate Execute (*)"]
	Gui, 	HS4: Font, 	% "s" . c_FontSize + 2
	Gui,		HS4: Add,		Text,		x0 y0 HwndIdTextInfo2b,									ⓘ
	GuiControl +g, % IdTextInfo2b, % F_TI_ImmediateExecute
	
	Gui, 	HS4: Font, 	% "s" . c_FontSize
	Gui,		HS4: Add,		Radio,		x0 y0 HwndIdRadioCaseCCb AltSubmit vv_RadioCaseGroup Checked gF_RadioCaseCol,	% TransA["Case-Conforming"]	;these lines have to stay together in order to keep the same variable for group of radios
	Gui,		HS4: Add,		Radio,		x0 y0 HWndIdRadioCaseCSb AltSubmit gF_RadioCaseCol,			% TransA["Case Sensitive (C)"]
	Gui,		HS4: Add,		Radio,		x0 y0 HwndIdRadioCaseC1b AltSubmit gF_RadioCaseCol,			% TransA["Not Case-Conforming (C1)"]
	Gui,		HS4: Add,		Radio,		x0 y0 HwndIdRadioCaseC2b AltSubmit gF_RadioCaseCol,			% TransA["Capitalize each word (C2)"]
	Gui, 	HS4: Font, 	% "s" . c_FontSize + 2
	Gui,		HS4: Add,		Text,		x0 y0 HwndIdTextInfo3b,									ⓘ
	GuiControl +g, % IdTextInfo3b, % F_TI_CaseConforming
	
	Gui, 	HS4: Font, 	% "s" . c_FontSize
	Gui, 	HS4: Add,		CheckBox, 	x0 y0 HwndIdCheckBox3b gF_Checkbox vv_OptionNoBackspace,		% TransA["No Backspace (B0)"]
	Gui, 	HS4: Font, 	% "s" . c_FontSize + 2
	Gui,		HS4: Add,		Text,		x0 y0 HwndIdTextInfo4b,									ⓘ
	GuiControl +g, % IdTextInfo4b, % F_TI_NoBackSpace
	
	Gui, 	HS4: Font, 	% "s" . c_FontSize
	Gui, 	HS4: Font, 	% "s" . c_FontSize + 2
	Gui,		HS4: Add,		Text,		x0 y0 HwndIdTextInfo5b,									ⓘ
	GuiControl +g, % IdTextInfo5b, % F_TI_CaseSensitive
	
	Gui, 	HS4: Font, 	% "s" . c_FontSize
	Gui, 	HS4: Add,		CheckBox, 	x0 y0 HwndIdCheckBox4b gF_Checkbox vv_OptionInsideWord, 		% TransA["Inside Word (?)"]
	Gui, 	HS4: Font, 	% "s" . c_FontSize + 2
	Gui,		HS4: Add,		Text,		x0 y0 HwndIdTextInfo6b,									ⓘ
	GuiControl +g, % IdTextInfo6b, % F_TI_InsideWord
	
	Gui, 	HS4: Font, 	% "s" . c_FontSize
	Gui, 	HS4: Font, 	% "s" . c_FontSize + 2
	Gui,		HS4: Add,		Text,		x0 y0 HwndIdTextInfo7b,									ⓘ
	GuiControl +g, % IdTextInfo7b, % F_TI_NotCaseConforming

	Gui, 	HS4: Font, 	% "s" . c_FontSize
	Gui, 	HS4: Font, 	% "s" . c_FontSize + 2
	Gui,		HS4: Add,		Text,		x0 y0 HwndIdTextInfo9b,									ⓘ
	GuiControl +g, % IdTextInfo9b, % F_TI_CapitalizeEachWord

	Gui, 	HS4: Font, 	% "s" . c_FontSize
	Gui, 	HS4: Add,		CheckBox, 	x0 y0 HwndIdCheckBox5b gF_Checkbox vv_OptionNoEndChar, 		% TransA["No EndChar (O)"]
	Gui, 	HS4: Font, 	% "s" . c_FontSize + 2
	Gui,		HS4: Add,		Text,		x0 y0 HwndIdTextInfo8b,									ⓘ
	GuiControl +g, % IdTextInfo8b, % F_TI_NoEndChar
	
	Gui, 	HS4: Font, 	% "s" . c_FontSize
	Gui,		HS4: Add,		CheckBox,		x0 y0 HwndIdCheckBox8b gF_Checkbox vv_OptionReset,			% TransA["Reset Recognizer (Z)"]
	Gui, 	HS4: Font, 	% "s" . c_FontSize + 2
	Gui,		HS4: Add,		Text,		x0 y0 HwndIdTextInfo10b,									ⓘ
	GuiControl +g, % IdTextInfo10b, % F_TI_OptionResetRecognizer
	
	Gui,		HS4: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, 	HS4: Add, 	Text, 		x0 y0 HwndIdText3b,						 				% TransA["Select hotstring output function"]
	Gui, 	HS4: Font, 	% "s" . c_FontSize + 2
	Gui,		HS4: Add,		Text,		x0 y0 HwndIdTextInfo12b,									ⓘ
	GuiControl +g, % IdTextInfo12b, % TI_SHOF
	Gui,		HS4: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, 			% c_FontType
	
	Gui, 	HS4: Add, 	DropDownList, 	x0 y0 HwndIdDDL1b vv_SelectFunction gF_SelectFunction, 		% "SendInput (SI)||Clipboard (CL)|"
;#c/* commercial only beginning	
;#c*/ commercial only end																						
																						. "SendRaw (SR)|SendPlay (SP)|SendEvent (SE)"
	
	Gui,		HS4: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, 	HS4: Add, 	Text, 		x0 y0 HwndIdText4b,					 					% TransA["Enter hotstring"]
	Gui, 	HS4: Font, 	% "s" . c_FontSize + 2
	Gui,		HS4: Add,		Text,		x0 y0 HwndIdTextInfo13b,									ⓘ
	GuiControl +g, % IdTextInfo13b, % TI_EnterHotstring
	Gui,		HS4: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, 			% c_FontType
	
	Gui, 	HS4: Add, 	Edit, 		x0 y0 HwndIdEdit2b vv_EnterHotstring	r2
	Gui, 	HS4: Add, 	Edit, 		x0 y0 HwndIdEdit3b vv_EnterHotstring1	r2 Disabled
	Gui, 	HS4: Add, 	Edit, 		x0 y0 HwndIdEdit4b vv_EnterHotstring2	r2 Disabled
	Gui, 	HS4: Add, 	Edit, 		x0 y0 HwndIdEdit5b vv_EnterHotstring3	r2 Disabled
	Gui, 	HS4: Add, 	Edit, 		x0 y0 HwndIdEdit6b vv_EnterHotstring4	r2 Disabled
	Gui, 	HS4: Add, 	Edit, 		x0 y0 HwndIdEdit7b vv_EnterHotstring5	r2 Disabled
	Gui, 	HS4: Add, 	Edit, 		x0 y0 HwndIdEdit8b vv_EnterHotstring6	r2 Disabled
	
	Gui,		HS4: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, 	HS4: Add, 	Text, 		x0 y0 HwndIdText5b,				 						% TransA["Add comment (optional)"]
	Gui, 	HS4: Font, 	% "s" . c_FontSize + 2	
	Gui,		HS4: Add,		Text,		x0 y0 HwndIdTextInfo14b,									ⓘ
	GuiControl +g, % IdTextInfo14b, % TI_AddComment
	Gui,		HS4: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, 			% c_FontType
	
	Gui, 	HS4: Add, 	Edit, 		x0 y0 HwndIdEdit9b vv_Comment Limit64 
	
	Gui,		HS4: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, 	HS4: Add, 	Text, 		x0 y0 HwndIdText6b,						 				% TransA["Select hotstring library"]
	Gui, 	HS4: Font, 	% "s" . c_FontSize + 2
	Gui,		HS4: Add,		Text,		x0 y0 HwndIdTextInfo15b,									ⓘ
	GuiControl +g, % IdTextInfo15b, % TI_SelectHotstringLib

	Gui,		HS4: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, 			% c_FontType 
	Gui, 	HS4: Add, 	Text, 		x0 y0 HwndIdText12b, 									% 0000 . " / " . 0000	;0000 are placeholders
	Gui, 	HS4: Font, 	% "s" . c_FontSize + 2
	Gui, 	HS4: Add, 	Text, 		x0 y0 HwndIdText2b,										% " ⓘ"
	TI_LibStats		:= func("F_ShowLongTooltip").bind(TransA["TI_LibStats"])
	GuiControl +g, % IdText2b, % TI_LibStats
	
	Gui,		HS4: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, 			% c_FontType
	Gui,		HS4: Add,		DropDownList,	x0 y0 HwndIdDDL2b vv_SelectHotstringLibrary gF_SelectLibrary Sort
	
	Gui, 	HS4: Add,		Button, 		x0 y0 HwndIdButton2b gF_AddHotstring,						% TransA["Add / Edit hotstring (F9)"]
	Gui, 	HS4: Add, 	Button, 		x0 y0 HwndIdButton3b gF_Clear,							% TransA["Clear (F5)"]
	
	Gui,		HS4: Add,		Button,		x0 y0 HwndIdButton5b gF_ToggleRightColumn,					⯈`nF4
	Gui,		HS4: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, 	HS4: Add, 	Text, 		x0 y0 HwndIdText10b,			 						% TransA["Sandbox"] . A_Space . "(" . "F6" . A_Space . TransA["to activate"] . A_Space . "or" . A_Space . "Ctrl + F6" . A_Space . TransA["to toggle"] . ")"
	Gui, 	HS4: Font, 	% "s" . c_FontSize + 2	
	Gui,		HS4: Add,		Text,		x0 y0 HwndIdTextInfo17b,									ⓘ
	GuiControl +g, % IdTextInfo17b, % TI_Sandbox
	Gui,		HS4: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, 			% c_FontType
	
	Gui, 	HS4: Add, 	Edit, 		x0 y0 HwndIdEdit10b vv_Sandbox r3 							; r3 = 3x rows of text
}
; ------------------------------------------------------------------------------------------------------------------------------------
F_GuiHS3_EnDis(EnDis)	;EnDis = "Disable" or "Enable"
{
	global ;assume-global mode of operation
	static	PS_IdEdit3 := false, PS_IdEdit4 := false, PS_IdEdit5 := false, PS_IdEdit6 := false, PS_IdEdit7 := false, PS_IdEdit8 := false

	Menu, HSMenu, % EnDis, % TransA["Configuration"]
	Menu, HSMenu, % EnDis, % TransA["Search (F3)"] 
	Menu, HSMenu, % EnDis, % TransA["Libraries"]
	Menu, HSMenu, % EnDis, % TransA["Clipboard Delay (F7)"]
	Menu, HSMenu, % EnDis, % TransA["Application"]
	Menu, HSMenu, % EnDis, % TransA["About / Help"]

	GuiControl, %  EnDis, % IdText1
	GuiControl, %  EnDis, % IdTextInfo1
	GuiControl, %  EnDis, % IdEdit1
	GuiControl, %  EnDis, % IdGroupBox1
	GuiControl, %  EnDis, % IdCheckBox1
	GuiControl, %  EnDis, % IdTextInfo2
	GuiControl, %  EnDis, % IdRadioCaseCC
	GuiControl, %  EnDis, % IdRadioCaseCS
	GuiControl, %  EnDis, % IdRadioCaseC1
	GuiControl, %  EnDis, % IdRadioCaseC2
	GuiControl, %  EnDis, % IdTextInfo3
	GuiControl, %  EnDis, % IdTextInfo5
	GuiControl, %  EnDis, % IdTextInfo7
	GuiControl, %  EnDis, % IdCheckBox3
	GuiControl, %  EnDis, % IdCheckBox4
	GuiControl, %  EnDis, % IdCheckBox5
	GuiControl, %  EnDis, % IdTextInfo4
	GuiControl, %  EnDis, % IdTextInfo6
	GuiControl, %  EnDis, % IdTextInfo8
	GuiControl, %  EnDis, % IdTextInfo9
	GuiControl, %  EnDis, % IdCheckBox8
	GuiControl, %  EnDis, % IdTextInfo10
	GuiControl, %  EnDis, % IdText3
	GuiControl, %  EnDis, % IdTextInfo12
	GuiControl, %  EnDis, % IdDDL1
	GuiControl, %  EnDis, % IdText4
	GuiControl, %  EnDis, % IdTextInfo13
	GuiControl, %  EnDis, % IdEdit2
	if (EnDis = "Disable")
	{
		GuiControlGet, PS_IdEdit3, Enabled, % IdEdit3
		GuiControlGet, PS_IdEdit4, Enabled, % IdEdit4
		GuiControlGet, PS_IdEdit5, Enabled, % IdEdit5
		GuiControlGet, PS_IdEdit6, Enabled, % IdEdit6
		GuiControlGet, PS_IdEdit7, Enabled, % IdEdit7
		GuiControlGet, PS_IdEdit8, Enabled, % IdEdit8
	}
	if (PS_IdEdit3)	
		GuiControl, % EnDis, % IdEdit3
	if (PS_IdEdit4)	
		GuiControl, % EnDis, % IdEdit4
	if (PS_IdEdit5)
		GuiControl, % EnDis, % IdEdit5
	if (PS_IdEdit6)	
		GuiControl, % EnDis, % IdEdit6
	if (PS_IdEdit7)	
		GuiControl, % EnDis, % IdEdit7
	if (PS_IdEdit8)	
		GuiControl, % EnDis, % IdEdit8
	GuiControl, % EnDis, % IdText5
	GuiControl, % EnDis, % IdTextInfo14
	GuiControl, % EnDis, % IdEdit9
	GuiControl, % EnDis, % IdText6
	GuiControl, % EnDis, % IdTextInfo15
	GuiControl, % EnDis, % IdDDL2
	GuiControl, % EnDis, % IdButton2
	GuiControl, % EnDis, % IdButton3
	GuiControl, % EnDis, % IdButton5
	GuiControl, % EnDis, % IdText7
	GuiControl, % EnDis, % IdTextInfo16
	GuiControl, % EnDis, % IdText2
	GuiControl, % EnDis, % IdText12
	GuiControl, % EnDis, % IdListView1
	if (EnDis = "Disable")	;Text font of ListView isn't grayed out automatically.
	{	; SendMessage, 0x1024, 0, 0x808080,, ahk_id %IdListView1% ; this is alternative
		Gui, HS3: Font, cGray
		GuiControl, Font, % IdListView1
		Gui, HS3: Font, cBlack
	}
  		
	if (EnDis = "Enable")	; SendMessage, 0x1024, 0, 0,, ahk_id %IdListView1% ;this is alternative ala  fikolek bic ale pwd abcd 
		GuiControl, Font, % IdListView1

	GuiControl, % EnDis, % IdText10
	GuiControl, % EnDis, % IdTextInfo17
	GuiControl, % EnDis, % IdEdit10
}
; ------------------------------------------------------------------------------------------------------------------------------------
F_GuiHS3_Create()
{
	global 	;assume-global mode of operation
	local 	x0 := 0, y0 := 0

	HS3_GuiWidth  				:= 0
,	HS3_GuiHeight 				:= 0
	
;1. Definition of HS3 GUI.
;+Border doesn't work in Microsoft Windows 10
	Gui, 		HS3: New, 		+Resize +HwndHS3GuiHwnd +OwnDialogs,			 						% A_ScriptName . A_Space . A_Space . A_Space . A_Space . A_Space . "(" . F_ParseHotkey(ini_HK_Main, "space") . ")"
	Gui, 		HS3: Margin,		% c_xmarg, % c_ymarg
	Gui,			HS3: Color,		% c_WindowColor, % c_ControlColor
	
;2. Prepare all text objects according to mock-up.
	Gui,			HS3: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, 		HS3: Add, 		Text, 		x0 y0 HwndIdText1, 										% TransA["Enter triggerstring"]
	Gui, 		HS3: Font, 		% "s" . c_FontSize + 2
	Gui,			HS3: Add,			Text,		x0 y0 HwndIdTextInfo1,									ⓘ
	F_TI_EnterTriggerstring	:= func("F_ShowLongTooltip").bind(TransA["F_TI_EnterTriggerstring"])
	GuiControl +g, % IdTextInfo1, % F_TI_EnterTriggerstring
	
	Gui,			HS3: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, 			% c_FontType
	Gui, 		HS3: Add, 		Edit, 		x0 y0 HwndIdEdit1 vv_TriggerString Limit gF_TriggerString	;Limit: Restricts the user's input to the visible width of the edit field.
	
	Gui,			HS3: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui,			HS3: Add,			GroupBox, 	x0 y0 HwndIdGroupBox1, 									% TransA["Select triggerstring option(s)"]
	Gui,			HS3: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, 			% c_FontType
	
	Gui, 		HS3: Add, 		CheckBox, 	x0 y0 HwndIdCheckBox1 gF_Checkbox vv_OptionImmediateExecute,	% TransA["Immediate Execute (*)"]
	Gui, 		HS3: Font, 		% "s" . c_FontSize + 2
	Gui,			HS3: Add,			Text,		x0 y0 HwndIdTextInfo2,									ⓘ
	F_TI_ImmediateExecute	:= func("F_ShowLongTooltip").bind(TransA["F_TI_ImmediateExecute"])
	GuiControl +g, % IdTextInfo2, % F_TI_ImmediateExecute
	
	Gui, 		HS3: Font, 		% "s" . c_FontSize
	Gui,			HS3: Add,			Radio,		x0 y0 HwndIdRadioCaseCC AltSubmit vv_RadioCaseGroup Checked gF_RadioCaseCol,	% TransA["Case-Conforming"]
	Gui,			HS3: Add,			Radio,		x0 y0 HWndIdRadioCaseCS AltSubmit gF_RadioCaseCol,			% TransA["Case Sensitive (C)"]
	Gui,			HS3: Add,			Radio,		x0 y0 HwndIdRadioCaseC1 AltSubmit gF_RadioCaseCol,			% TransA["Not Case-Conforming (C1)"]
	Gui,			HS3: Add,			Radio,		x0 y0 HwndIdRadioCaseC2 AltSubmit gF_RadioCaseCol,			% TransA["Capitalize each word (C2)"]
	Gui, 		HS3: Font, 		% "s" . c_FontSize + 2
	Gui,			HS3: Add,			Text,		x0 y0 HwndIdTextInfo3,									ⓘ
	Gui,			HS3: Add,			Text,		x0 y0 HwndIdTextInfo5,									ⓘ
	Gui,			HS3: Add,			Text,		x0 y0 HwndIdTextInfo7,									ⓘ
	Gui,			HS3: Add,			Text,		x0 y0 HwndIdTextInfo9,									ⓘ
	F_TI_CaseConforming 	:= func("F_ShowLongTooltip").bind(TransA["F_TI_CaseConforming"])
,	F_TI_CaseSensitive		:= func("F_ShowLongTooltip").bind(TransA["F_TI_CaseSensitive"])
,	F_TI_NotCaseConforming	:= func("F_ShowLongTooltip").bind(TransA["F_TI_NotCaseConforming"])
,	F_TI_CapitalizeEachWord	:= func("F_ShowLongTooltip").bind(TransA["F_TI_CapitalizeEachWord"])
	GuiControl +g, % IdTextInfo3, % F_TI_CaseConforming
	GuiControl +g, % IdTextInfo5, % F_TI_CaseSensitive
	GuiControl +g, % IdTextInfo7, % F_TI_NotCaseConforming
	GuiControl +g, % IdTextInfo9, % F_TI_CapitalizeEachWord
	
	Gui, 		HS3: Font, 		% "s" . c_FontSize
	Gui, 		HS3: Add,			CheckBox, 	x0 y0 HwndIdCheckBox3 gF_Checkbox vv_OptionNoBackspace,		% TransA["No Backspace (B0)"]
	Gui, 		HS3: Add,			CheckBox, 	x0 y0 HwndIdCheckBox4 gF_Checkbox vv_OptionInsideWord, 		% TransA["Inside Word (?)"]
	Gui, 		HS3: Add,			CheckBox, 	x0 y0 HwndIdCheckBox5 gF_Checkbox vv_OptionNoEndChar, 			% TransA["No EndChar (O)"]
	Gui, 		HS3: Font, 		% "s" . c_FontSize + 2
	Gui,			HS3: Add,			Text,		x0 y0 HwndIdTextInfo4,									ⓘ
	F_TI_NoBackSpace 		:= func("F_ShowLongTooltip").bind(TransA["F_TI_NoBackSpace"])
	GuiControl +g, % IdTextInfo4, % F_TI_NoBackSpace
	Gui,			HS3: Add,			Text,		x0 y0 HwndIdTextInfo6,									ⓘ
	F_TI_InsideWord 		:= func("F_ShowLongTooltip").bind(TransA["F_TI_InsideWord"])
	GuiControl +g, % IdTextInfo6, % F_TI_InsideWord
	Gui,			HS3: Add,			Text,		x0 y0 HwndIdTextInfo8,									ⓘ
	F_TI_NoEndChar 		:= func("F_ShowLongTooltip").bind(TransA["F_TI_NoEndChar"]) 
	GuiControl +g, % IdTextInfo8, % F_TI_NoEndChar						
	
	Gui, 		HS3: Font, 		% "s" . c_FontSize
	Gui,			HS3: Add,			CheckBox,		x0 y0 HwndIdCheckBox8 gF_Checkbox vv_OptionReset,				% TransA["Reset Recognizer (Z)"]
	Gui, 		HS3: Font, 		% "s" . c_FontSize + 2
	Gui,			HS3: Add,			Text,		x0 y0 HwndIdTextInfo10,									ⓘ
	F_TI_OptionResetRecognizer := func("F_ShowLongTooltip").bind(TransA["F_TI_OptionResetRecognizer"])
	GuiControl +g, % IdTextInfo10, % F_TI_OptionResetRecognizer
	
	Gui,			HS3: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, 		HS3: Add, 		Text, 		x0 y0 HwndIdText3,						 				% TransA["Select hotstring output function"]
	Gui, 		HS3: Font, 		% "s" . c_FontSize + 2
	Gui,			HS3: Add,			Text,		x0 y0 HwndIdTextInfo12,									ⓘ
	TI_SHOF				:= func("F_ShowLongTooltip").bind(TransA["TI_SHOF"])
	GuiControl +g, % IdTextInfo12, % TI_SHOF
	Gui,			HS3: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, 			% c_FontType
	
	Gui, 		HS3: Add, 		DropDownList, 	x0 y0 HwndIdDDL1 vv_SelectFunction gF_SelectFunction, 			% "SendInput (SI)||Clipboard (CL)|"
;#c/* commercial only beginning
;#c*/ commercial only end																								
																								. "SendRaw (SR)|SendPlay (SP)|SendEvent (SE)"
	Gui,			HS3: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, 		HS3: Add, 		Text, 		x0 y0 HwndIdText4,					 					% TransA["Enter hotstring"]
	Gui, 		HS3: Font, 		% "s" . c_FontSize + 2	
	Gui,			HS3: Add,			Text,		x0 y0 HwndIdTextInfo13,									ⓘ
	TI_EnterHotstring		:= func("F_ShowLongTooltip").bind(TransA["TI_EnterHotstring"])
	GuiControl +g, % IdTextInfo13, % TI_EnterHotstring
	Gui,			HS3: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, 			% c_FontType
	
	Gui, 		HS3: Add, 		Edit, 		x0 y0 HwndIdEdit2 vv_EnterHotstring   r2								;r2 important to create multi-line edit field and enable entering long text.
	Gui, 		HS3: Add, 		Edit, 		x0 y0 HwndIdEdit3 vv_EnterHotstring1  r2 Disabled
	Gui, 		HS3: Add, 		Edit, 		x0 y0 HwndIdEdit4 vv_EnterHotstring2  r2 Disabled
	Gui, 		HS3: Add, 		Edit, 		x0 y0 HwndIdEdit5 vv_EnterHotstring3  r2 Disabled
	Gui, 		HS3: Add, 		Edit, 		x0 y0 HwndIdEdit6 vv_EnterHotstring4  r2 Disabled
	Gui, 		HS3: Add, 		Edit, 		x0 y0 HwndIdEdit7 vv_EnterHotstring5  r2 Disabled
	Gui, 		HS3: Add, 		Edit, 		x0 y0 HwndIdEdit8 vv_EnterHotstring6  r2 Disabled
	
	Gui,			HS3: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, 		HS3: Add, 		Text, 		x0 y0 HwndIdText5,				 						% TransA["Add comment (optional)"]
	Gui, 		HS3: Font, 		% "s" . c_FontSize + 2	
	Gui,			HS3: Add,			Text,		x0 y0 HwndIdTextInfo14,									ⓘ
	TI_AddComment			:= func("F_ShowLongTooltip").bind(TransA["TI_AddComment"])
	GuiControl +g, % IdTextInfo14, % TI_AddComment
	
	Gui,			HS3: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, 			% c_FontType
	
	Gui, 		HS3: Add, 		Edit, 		x0 y0 HwndIdEdit9 vv_Comment Limit96 
	
	Gui,			HS3: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, 		HS3: Add, 		Text, 		x0 y0 HwndIdText6,						 				% TransA["Select hotstring library"]
	Gui, 		HS3: Font, 		% "s" . c_FontSize + 2	
	Gui,			HS3: Add,			Text,		x0 y0 HwndIdTextInfo15,									ⓘ
	TI_SelectHotstringLib	:= func("F_ShowLongTooltip").bind(TransA["TI_SelectHotstringLib"])
	GuiControl +g, % IdTextInfo15, % TI_SelectHotstringLib

	Gui,			HS3: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, 			% c_FontType 
	Gui, 		HS3: Add, 		Text, 		x0 y0 HwndIdText12, 									%  0000 . " / " . 0000	;0000 just to occupy some space / reserve it for future use
	Gui, 		HS3: Font, 		% "s" . c_FontSize + 2
	Gui, 		HS3: Add, 		Text, 		x0 y0 HwndIdText2,										% " ⓘ"
	TI_LibStats		:= func("F_ShowLongTooltip").bind(TransA["TI_LibStats"])
	GuiControl +g, % IdText2, % TI_LibStats
	
	Gui,			HS3: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, 			% c_FontType
	
	Gui,			HS3: Add,			DropDownList,	x0 y0 HwndIdDDL2 vv_SelectHotstringLibrary gF_SelectLibrary Sort
	
	Gui, 		HS3: Add, 		Button, 		x0 y0 HwndIdButton2 gF_AddHotstring,						% TransA["Add / Edit hotstring (F9)"]
	Gui, 		HS3: Add, 		Button, 		x0 y0 HwndIdButton3 gF_Clear,								% TransA["Clear (F5)"]
	Gui,			HS3: Add,			Button,		x0 y0 HwndIdButton5 gF_ToggleRightColumn,					⯇`nF4
	
	Gui,			HS3: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, 		HS3: Add, 		Text, 		x0 y0 HwndIdText7,		 								% TransA["Library content (F2, context menu)"]
	Gui, 		HS3: Font, 		% "s" . c_FontSize + 2	
	Gui,			HS3: Add,			Text,		x0 y0 HwndIdTextInfo16,									ⓘ
	TI_LibraryContent		:= func("F_ShowLongTooltip").bind(TransA["TI_LibraryContent"])
	GuiControl +g, % IdTextInfo16, % TI_LibraryContent
	
	Gui,			HS3: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, 			% c_FontType
	Gui, 		HS3: Add, 		ListView, 	x0 y0 HwndIdListView1 LV0x1 vv_LibraryContent AltSubmit gF_HSLV -Multi Grid BackgroundE1E1E1, % TransA["En/Dis|Triggerstring|Trigg Opt|Out Fun|Hotstring|Comment"]	;Trick with "BackgroundE1E1E1": There is no simple way to distinguish ListView header from the rest of table, but to change background color.
	
	Gui,			HS3: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, 		HS3: Add, 		Text, 		x0 y0 HwndIdText10,			 							% TransA["Sandbox"] . A_Space . "(" . "F6" . A_Space . TransA["to activate"] . A_Space . "or" . A_Space . "Ctrl + F6" . A_Space . TransA["to toggle"] . ")"
	Gui, 		HS3: Font, 		% "s" . c_FontSize + 2
	Gui,			HS3: Add,			Text,		x0 y0 HwndIdTextInfo17,									ⓘ
	TI_Sandbox		:= func("F_ShowLongTooltip").bind(TransA["TI_Sandbox"])
	GuiControl +g, % IdTextInfo17, % TI_Sandbox
	
	Gui,			HS3: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, 			% c_FontType
	Gui, 		HS3: Add, 		Edit, 		x0 y0 HwndIdEdit10 vv_Sandbox r3 						; r3 = 3x rows of text
	Gui, 		HS3: Add, 		Button, Hidden Default gF_HSLV	;trick to catch if user presses Enter on ListView1
}
; ------------------------------------------------------------------------------------------------------------------------------------
F_TriggerString()	; To be launched automatically whenever the user or the script changes the contents of the control. Replace space with U+2423 (open box ␣)
{
	global ;assume-global mode 

	if (ini_ShowWhiteChars)
	{
		Gui, % A_Gui . ": Submit", NoHide	;Saves the contents of each control to its associated variable
		if (InStr(v_TriggerString, A_Space)) ;If <space> is detected within v_TriggerString
		{
			v_TriggerString := StrReplace(v_TriggerString, A_Space, "␣") ;Replace <space> with U+2423 (open box ␣)
			GuiControl, % A_Gui . ":", % IdEdit1, % v_TriggerString ;put new value into GuiControl
			ControlSend, Edit1, {End}, A	;send to Edit1 {End} character. Without that cursor is moved to the beginning of Edit field.
		}	
	}	
}
; ------------------------------------------------------------------------------------------------------------------------------------
HS3GuiContextMenu(GuiHwnd, CtrlHwnd, EventInfo, IsRightClick, X, Y)
{
	global ;assume-global mode 
	if (CtrlHwnd != IdListView1)
		return
	Menu, ListView1_ContextMenu, Show, %X%, %Y%
}
; ------------------------------------------------------------------------------------------------------------------------------------
F_HS3_DefineConstants()
{
	global ;assume-global mode
	local OutVarTemp := 0, OutVarTempX := 0, OutVarTempY := 0, OutVarTempW := 0, OutVarTempH := 0	;Within a function, to create a set of variables that is local instead of global, declare OutputVar as a local variable prior to using command GuiControlGet, Pos. However, it is often also necessary to declare each variable in the set, due to a common source of confusion.	
	
;Determine weight / height of main types of text objects. Convention: global variables which are in fact constants, will have "c_" prefix.
	GuiControlGet, OutVarTemp, Pos, % IdText1
	c_HofText			:= OutVarTempH
	GuiControlGet, OutVarTemp, Pos, % IdEdit1
	c_HofEdit			:= OutVarTempH
	GuiControlGet, OutVarTemp, Pos, % IdButton3	;button "Clear (F5)"
	c_HofButton		:= OutVarTempH
	GuiControlGet, OutVarTemp, Pos, % IdCheckBox1
	c_HofCheckBox		:= OutVarTempH
	GuiControlGet, OutVarTemp, Pos, % IdDDL1
	c_HofDropDownList 	:= OutVarTempH
	GuiControlGet, OutVarTemp, Pos, % IdEdit10
	c_HofSandbox		:= OutVarTempH
	GuiControlGet, OutVarTemp, Pos, % IdButton5
	c_WofMiddleButton  	:= OutVarTempW
}
; ------------------------------------------------------------------------------------------------------------------------------------
F_RadioCaseCol()
{
	global ;assume-global mode
	Switch F_WhichGui()
	{
		Case "HS3": 
			Gui, HS3: Submit, NoHide
			F_HS3RadioCaseGroup(v_RadioCaseGroup)
		Case "HS4": 
			Gui, HS4: Submit, NoHide
			F_HS4RadioCaseGroup(v_RadioCaseGroup)
	}
}
; ------------------------------------------------------------------------------------------------------------------------------------
F_HS3RadioCaseGroup(v_RadioCaseGroup)
{
	global ;assume-global mode
	Switch v_RadioCaseGroup
	{
		Case 1:
			Gui, HS3: Font, % "s" . c_FontSize . A_Space . "c" . c_FontColor . A_Space . "Norm", % c_FontType
			GuiControl, HS3: Font, % TransA["Case Sensitive (C)"]
			GuiControl, HS3: Font, % TransA["Case-Conforming"]
			GuiControl, HS3: Font, % TransA["Not Case-Conforming (C1)"]
			GuiControl, HS3: Font, % TransA["Capitalize each word (C2)"]
			GuiControl, HS3:, % TransA["Case-Conforming"], 1
		Case 2:
			Gui, HS3: Font, % "s" . c_FontSize . A_Space . "cGreen Norm", % c_FontType
			GuiControl, HS3: Font, % TransA["Case Sensitive (C)"]
			GuiControl, HS3:, % TransA["Case Sensitive (C)"], 1
			Gui, HS3: Font, % "s" . c_FontSize . A_Space . "c" . c_FontColor . A_Space . "Norm", % c_FontType
			GuiControl, HS3: Font, % TransA["Case-Conforming"]
			GuiControl, HS3: Font, % TransA["Not Case-Conforming (C1)"]
			GuiControl, HS3: Font, % TransA["Capitalize each word (C2)"]
		Case 3:
			Gui, HS3: Font, % "s" . c_FontSize . A_Space . "cGreen Norm", % c_FontType
			GuiControl, HS3: Font, % TransA["Not Case-Conforming (C1)"]
			GuiControl, HS3:, % TransA["Not Case-Conforming (C1)"], 1
			Gui, HS3: Font, % "s" . c_FontSize . A_Space . "c" . c_FontColor . A_Space . "Norm", % c_FontType					
			GuiControl, HS3: Font, % TransA["Case Sensitive (C)"]
			GuiControl, HS3: Font, % TransA["Case-Conforming"]
			GuiControl, HS3: Font, % TransA["Capitalize each word (C2)"]
		Case 4: 
			Gui, HS3: Font, % "s" . c_FontSize . A_Space . "cGreen Norm", % c_FontType
			GuiControl, HS3: Font, % TransA["Capitalize each word (C2)"]
			GuiControl, HS3:, % TransA["Capitalize each word (C2)"], 1
			Gui, HS3: Font, % "s" . c_FontSize . A_Space . "c" . c_FontColor . A_Space . "Norm", % c_FontType
			GuiControl, HS3: Font, % TransA["Case Sensitive (C)"]
			GuiControl, HS3: Font, % TransA["Case-Conforming"]
			GuiControl, HS3: Font, % TransA["Not Case-Conforming (C1)"]
		}
}
; ------------------------------------------------------------------------------------------------------------------------------------
F_HS4RadioCaseGroup(v_RadioCaseGroup)
{
	global ;assume-global mode
	Switch v_RadioCaseGroup
	{
		Case 1:
			Gui, HS4: Font, % "s" . c_FontSize . A_Space . "c" . c_FontColor . A_Space . "Norm", % c_FontType
			GuiControl, HS4: Font, % TransA["Case Sensitive (C)"]
			GuiControl, HS4: Font, % TransA["Case-Conforming"]
			GuiControl, HS4: Font, % TransA["Not Case-Conforming (C1)"]
			GuiControl, HS4: Font, % TransA["Capitalize each word (C2)"]
			GuiControl, HS4:, % TransA["Case-Conforming"], 1
		Case 2:
			Gui, HS4: Font, % "s" . c_FontSize . A_Space . "cGreen Norm", % c_FontType
			GuiControl, HS4: Font, % TransA["Case Sensitive (C)"]
			GuiControl, HS4:, % TransA["Case Sensitive (C)"], 1
			Gui, HS4: Font, % "s" . c_FontSize . A_Space . "c" . c_FontColor . A_Space . "Norm", % c_FontType
			GuiControl, HS4: Font, % TransA["Case-Conforming"]
			GuiControl, HS4: Font, % TransA["Not Case-Conforming (C1)"]
			GuiControl, HS4: Font, % TransA["Capitalize each word (C2)"]
		Case 3: 
			Gui, HS4: Font, % "s" . c_FontSize . A_Space . "cGreen Norm", % c_FontType
			GuiControl, HS4: Font, % TransA["Not Case-Conforming (C1)"]
			GuiControl, HS4:, % TransA["Not Case-Conforming (C1)"], 1
			Gui, HS4: Font, % "s" . c_FontSize . A_Space . "c" . c_FontColor . A_Space . "Norm", % c_FontType
			GuiControl, HS4: Font, % TransA["Case Sensitive (C)"]
			GuiControl, HS4: Font, % TransA["Case-Conforming"]
			GuiControl, HS4: Font, % TransA["Capitalize each word (C2)"]
		Case 4: 
			Gui, HS4: Font, % "s" . c_FontSize . A_Space . "cGreen Norm", % c_FontType
			GuiControl, HS4: Font, % TransA["Capitalize each word (C2)"]
			GuiControl, HS4:, % TransA["Capitalize each word (C2)"], 1
			Gui, HS4: Font, % "s" . c_FontSize . A_Space . "c" . c_FontColor . A_Space . "Norm", % c_FontType
			GuiControl, HS4: Font, % TransA["Case Sensitive (C)"]
			GuiControl, HS4: Font, % TransA["Case-Conforming"]
			GuiControl, HS4:, % TransA["Not Case-Conforming (C1)"]
	}
}
;------------------------------------------------------------------------------------------------------------------------------------
F_GuiHS4_DetermineConstraints()
{
	global ;assume-global mode
	local OutVarTemp := 0, 	OutVarTempX := 0, 	OutVarTempY := 0, 	OutVarTempW := 0, 	OutVarTempH := 0 ;Within a function, to create a set of variables that is local instead of global, declare OutputVar as a local variable prior to using command GuiControlGet, Pos. However, it is often also necessary to declare each variable in the set, due to a common source of confusion.
		,OutVarTemp1 := 0, 	OutVarTemp1X := 0, 	OutVarTemp1Y := 0, 	OutVarTemp1W := 0, 	OutVarTemp1H := 0
		,OutVarTemp2 := 0, 	OutVarTemp2X := 0, 	OutVarTemp2Y := 0, 	OutVarTemp2W := 0, 	OutVarTemp2H := 0
		,OutVarTemp3 := 0, 	OutVarTemp3X := 0, 	OutVarTemp3Y := 0, 	OutVarTemp3W := 0, 	OutVarTemp3H := 0
		,OutVarTemp4 := 0, 	OutVarTemp4X := 0, 	OutVarTemp4Y := 0, 	OutVarTemp4W := 0, 	OutVarTemp4H := 0
		,OutVarTemp5 := 0, 	OutVarTemp5X := 0, 	OutVarTemp5Y := 0, 	OutVarTemp5W := 0, 	OutVarTemp5H := 0
		,OutVarTemp6 := 0, 	OutVarTemp6X := 0, 	OutVarTemp6Y := 0, 	OutVarTemp6W := 0, 	OutVarTemp6H := 0
		,xNext := 0, 		yNext := 0, 			wNext := 0, 			hNext := 0
		,WleftMiniColumn := 0,	WrightMiniColumn := 0,	SpaceBetweenColumns := 0
		,W_InfoSign := 0, 		W_C1 := 0,			W_C2 := 0,			GPB := 0
		,LeftColumnW := 0,		LeftColumnH := 0
	
;4. Determine constraints, according to mock-up
;4.1. Determine left columnt width
	GuiControlGet, OutVarTemp1, Pos, % IdTextInfo1b
	W_InfoSign := OutVarTemp1W
	
	GuiControlGet, OutVarTemp1, Pos, % IdCheckBox1b
	GuiControlGet, OutVarTemp2, Pos, % IdCheckBox3b
	GuiControlGet, OutVarTemp3, Pos, % IdCheckBox4b
	GuiControlGet, OutVarTemp4, Pos, % IdCheckBox5b
	GuiControlGet, OutVarTemp6, Pos, % IdCheckBox8b
	W_C1 := Max(OutVarTemp1W, OutVarTemp2W, OutVarTemp3W, OutVarTemp4W, OutVarTemp6W) + c_xmarg + W_InfoSign
	
	GuiControlGet, OutVarTemp1, Pos, % IdRadioCaseCCb
	GuiControlGet, OutVarTemp2, Pos, % IdRadioCaseCSb
	GuiControlGet, OutVarTemp3, Pos, % IdRadioCaseC1b
	; GuiControlGet, OutVarTemp4, Pos, % IdCheckBox6b
	W_C2 := Max(OutVarTemp1W, OutVarTemp2W, OutVarTemp3W, OutVarTemp4W) + c_xmarg + W_InfoSign
	
,	LeftColumnW := 2 * c_xmarg + W_C1 + c_xmarg + W_C2 + c_xmarg
	
;5. Move text objects to correct position
;5.1. Left column
;5.1.1. Enter triggerstring
	xNext := c_xmarg
,	yNext := c_ymarg
	GuiControl, Move, % IdText1b, % "x" . xNext . "y" . yNext
	
	GuiControlGet, OutVarTemp1, Pos, % IdText1b
	xNext += OutVarTemp1W + c_xmarg
	GuiControl, Move, % IdTextInfo1b, % "x" . xNext . "y" . yNext
	xNext += W_InfoSign + c_xmarg
,	wNext := LeftColumnW - xNext - c_xmarg
	GuiControl, Move, % IdEdit1b, % "x" . xNext . "y" . yNext . "w" . wNext
	
;5.1.2. Select trigger options
	xNext := c_xmarg 
,	yNext := c_ymarg + c_HofEdit + c_HofText 
,	wNext := c_xmarg + W_C1 + c_xmarg  + W_C2
,	hNext := c_HofText + c_ymarg + c_HofCheckBox * 5 + c_ymarg
	GuiControl, Move, % IdGroupBox1b, % "x" . xNext . "y" . yNext . "w" . wNext . "h" . hNext
;5.1.2.1. Raw 1: Immediate execute (*) + Case-Conforming
	xNext += c_xmarg
,	yNext += c_HofText + c_ymarg
	GuiControl, Move, % IdCheckBox1b, % "x" . xNext . "y" . yNext 
	GuiControlGet, OutVarTemp1, Pos, % IdCheckBox1
	xNext += OutVarTemp1W
	GuiControl, Move, % IdTextInfo2b, % "x" . xNext . "y" . yNext 
	xNext := c_xmarg * 2 + W_C1 + c_xmarg
	GuiControl, Move, % IdRadioCaseCCb, % "x" . xNext . "y" . yNext
	GuiControlGet, OutVarTemp1, Pos, % IdRadioCaseCCb
	xNext += OutVarTemp1W
	GuiControl, Move, % IdTextInfo3b, % "x" . xNext . "y" . yNext
;5.1.2.2. Raw 2: No Backspace (B0)	+ Case Sensitive (C)
	xNext := c_xmarg * 2
,	yNext += c_HofCheckBox
	GuiControl, Move, % IdCheckBox3b, % "x" . xNext . "y" . yNext
	GuiControlGet, OutVarTemp1, Pos, % IdCheckBox3b
	xNext += OutVarTemp1W
	GuiControl, Move, % IdTextInfo4b, % "x" . xNext . "y" . yNext 
	xNext := c_xmarg * 2 + W_C1 + c_xmarg
	GuiControl, Move, % IdRadioCaseCSb, % "x" . xNext . "y" . yNext
	GuiControlGet, OutVarTemp1, Pos, % IdRadioCaseCSb
	xNext += OutVarTemp1W
	GuiControl, Move, % IdTextInfo5b, % "x" . xNext . "y" . yNext
;5.1.2.3. Raw 3: Inside Word (?) + Not Case-Conforming (C1)
	xNext := c_xmarg * 2
,	yNext += c_HofCheckBox
	GuiControl, Move, % IdCheckBox4b, % "x" . xNext . "y" . yNext	
	GuiControlGet, OutVarTemp1, Pos, % IdCheckBox4b
	xNext += OutVarTemp1W
	GuiControl, Move, % IdTextInfo6b, % "x" . xNext . "y" . yNext 
	xNext := c_xmarg * 2 + W_C1 + c_xmarg
	GuiControl, Move, % IdRadioCaseC1b, % "x" . xNext . "y" . yNext
	GuiControlGet, OutVarTemp1, Pos, % IdRadioCaseC1b
	xNext += OutVarTemp1W
	GuiControl, Move, % IdTextInfo7b, % "x" . xNext . "y" . yNext
;5.1.2.4. Raw 4: No EndChar (O) + Capitalize each word (C2)
	xNext := c_xmarg * 2
,	yNext += c_HofCheckBox
	GuiControl, Move, % IdCheckBox5b, % "x" . xNext . "y" . yNext	
	GuiControlGet, OutVarTemp1, Pos, % IdCheckBox5
	xNext += OutVarTemp1W
	GuiControl, Move, % IdTextInfo8b, % "x" . xNext . "y" . yNext 
	xNext := c_xmarg * 2 + W_C1 + c_xmarg
	GuiControl, Move, % IdRadioCaseC2b, % "x" . xNext . "y" . yNext
	GuiControlGet, OutVarTemp1, Pos, % IdRadioCaseC2b
	xNext += OutVarTemp1W
	GuiControl, Move, % IdTextInfo9b, % "x" . xNext . "y" . yNext
;5.1.2.6. Raw 5: Reset Recognizer (Z) + Disable
	xNext := c_xmarg * 2
,	yNext += c_HofCheckBox
	GuiControl, Move, % IdCheckBox8b, % "x" . xNext . "y" . yNext	
	GuiControlGet, OutVarTemp1, Pos, % IdCheckBox8
	xNext += OutVarTemp1W
	GuiControl, Move, % IdTextInfo10b, % "x" . xNext . "y" . yNext 
;5.1.3. Select hotstring output function
	xNext := c_xmarg
,	yNext += c_HofCheckBox + c_ymarg * 2
	GuiControl, Move, % IdText3b, % "x" . xNext . "y" . yNext
	GuiControlGet, OutVarTemp1, Pos, % IdText3b
	xNext += OutVarTemp1W + c_xmarg
	GuiControl, Move, % IdTextInfo12b, % "x" . xNext . "y" . yNext
	xNext := c_xmarg
,	yNext += c_HofText
,	wNext := LeftColumnW - 2 * c_xmarg
	GuiControl, Move, % IdDDL1b, % "x" . xNext . "y" . yNext . "w" . wNext
	
;5.1.4. Enter hotstring
	yNext += c_HofDropDownList + c_ymarg
,	xNext := c_xmarg
	GuiControl, Move, % IdText4b, % "x" . xNext . "y" . yNext
	GuiControlGet, OutVarTemp1, Pos, % IdText4b
	xNext += OutVarTemp1W + c_xmarg
	GuiControl, Move, % IdTextInfo13b, % "x" . xNext . "y" . yNext
	xNext := c_xmarg
,	yNext += c_HofText
,	wNext := LeftColumnW - 2 * c_xmarg
	GuiControl, Move, % IdEdit2b, % "x" . xNext . "y" . yNext . "w" . wNext
	yNext += c_HofEdit
	GuiControl, Move, % IdEdit3b, % "x" . xNext . "y" . yNext . "w" . wNext
	yNext += c_HofEdit
	GuiControl, Move, % IdEdit4b, % "x" . xNext . "y" . yNext . "w" . wNext
	yNext += c_HofEdit
	GuiControl, Move, % IdEdit5b, % "x" . xNext . "y" . yNext . "w" . wNext
	yNext += c_HofEdit
	GuiControl, Move, % IdEdit6b, % "x" . xNext . "y" . yNext . "w" . wNext
	yNext += c_HofEdit
	GuiControl, Move, % IdEdit7b, % "x" . xNext . "y" . yNext . "w" . wNext
	yNext += c_HofEdit
	GuiControl, Move, % IdEdit8b, % "x" . xNext . "y" . yNext . "w" . wNext
;5.1.5. Add comment (optional)
	GuiControlGet, OutVarTemp1, Pos, % IdEdit8b
	yNext += OutVarTemp1H + c_ymarg
,	xNext := c_xmarg
	GuiControl, Move, % IdText5b, % "x" . xNext . "y" . yNext	;Add comment (optional)
	GuiControlGet, OutVarTemp1, Pos, % IdText5b
	xNext += OutVarTemp1W + c_xmarg
	GuiControl, Move, % IdTextInfo14b, % "x" . xNext . "y" . yNext	;i
	xNext := c_xmarg
,	yNext += c_HofText
,	wNext := LeftColumnW - 2 * c_xmarg
	GuiControl, Move, % IdEdit9b, % "x" . xNext . "y" . yNext . "w" . wNext	;edit comment field
;5.1.6. Select hotstring library
	yNext += c_HofEdit + c_ymarg
,	xNext := c_xmarg
	GuiControl, Move, % IdText6b, % "x" . xNext . "y" . yNext
	GuiControlGet, OutVarTemp1, Pos, % IdText6b
	xNext += OutVarTemp1W + c_xmarg
	GuiControl, Move, % IdTextInfo15b, % "x" . xNext . "y" . yNext
;5.1.7. Library statistics
	GuiControlGet, OutVarTemp1, Pos, % IdText2b	;% IdText2	;info about libraries statistics
	xNext := LeftColumnW - c_xmarg - OutVarTemp1W
	GuiControl, Move, % IdText2b, % "x" . xNext . "y" . yNext
	GuiControlGet, OutVarTemp1, Pos, % IdText12b
	xNext -= OutVarTemp1W
	GuiControl, MoveDraw, % IdText12b, % "x" . xNext . "y" . yNext	;IdText12, value of this library statistics (ratio)
;5.1.8. Hotstring library drop-down list
	yNext += c_HofText
,	xNext := c_xmarg
,	wNext := LeftColumnW - xNext - c_xmarg
	GuiControl, Move, % IdDDL2b, % "x" xNext "y" yNext "w" . wNext
;5.1.9. Buttons
	yNext += c_HofDropDownList + c_ymarg
,	xNext := c_xmarg
	GuiControl, Move, % IdButton2b, % "x" . xNext . "y" . yNext
	GuiControlGet, OutVarTemp1, Pos, % IdButton3b
	xNext := LeftColumnW - (OutVarTemp1W + c_xmarg)
	GuiControl, Move, % IdButton3b, % "x" . xNext . "y" . yNext
	yNext += c_HofButton
,	LeftColumnH := yNext
	; OutputDebug, % "HS4 LeftColumnH:" . A_Space . LeftColumnH . "`n"
;5.1.10 SANDBOX LABEL
	xNext := c_xmarg
,	yNext := LeftColumnH + c_ymarg
	GuiControl, Move, % IdText10b, % "x" . xNext . "y" . yNext	;sandobx text
	GuiControlGet, OutVarTemp, Pos, % IdText10b
	xNext := OutVarTempX + OutVarTempW + c_xmarg
	GuiControl, Move, % IdTextInfo17b, % "x" . xNext . "y" . yNext	;i close to sandbox
;5.1.11 SANDBOX	
	xNext := c_xmarg
,	yNext := LeftColumnH + c_HofText + c_ymarg
,	wNext := LeftColumnW - 2 * c_ymarg
	GuiControl, Move, % IdEdit10b, % "x" . xNext . "y" . yNext . "w" . wNext	;sandbox edit field
;5.1.12. MB (Middle Button)
	xNext := LeftColumnW
,	yNext := c_ymarg
,	hNext := LeftColumnH + 2 * c_ymarg + c_HofText + c_HofSandbox
	GuiControl, MoveDraw, % IdButton5b, % "x" . xNext . "y" . yNext . "h" . hNext 

	;OutputDebug, % "LeftColumnH:" . A_Space . LeftColumnH
	HS4MinWidth		:= LeftColumnW 
,	HS4MinHeight		:= LeftColumnH
}
;------------------------------------------------------------------------------------------------------------------------------------
F_GuiHS3_DetermineConstraints()
{
	global ;assume-global mode
	local OutVarTemp := 0, 	OutVarTempX := 0, 	OutVarTempY := 0, 	OutVarTempW := 0, 	OutVarTempH := 0 ;Within a function, to create a set of variables that is local instead of global, declare OutputVar as a local variable prior to using command GuiControlGet, Pos. However, it is often also necessary to declare each variable in the set, due to a common source of confusion.
		,OutVarTemp1 := 0, 	OutVarTemp1X := 0, 	OutVarTemp1Y := 0, 	OutVarTemp1W := 0, 	OutVarTemp1H := 0
		,OutVarTemp2 := 0, 	OutVarTemp2X := 0, 	OutVarTemp2Y := 0, 	OutVarTemp2W := 0, 	OutVarTemp2H := 0
		,OutVarTemp3 := 0, 	OutVarTemp3X := 0, 	OutVarTemp3Y := 0, 	OutVarTemp3W := 0, 	OutVarTemp3H := 0
		,OutVarTemp4 := 0, 	OutVarTemp4X := 0, 	OutVarTemp4Y := 0, 	OutVarTemp4W := 0, 	OutVarTemp4H := 0
		,OutVarTemp5 := 0, 	OutVarTemp5X := 0, 	OutVarTemp5Y := 0, 	OutVarTemp5W := 0, 	OutVarTemp5H := 0
		,OutVarTemp6 := 0, 	OutVarTemp6X := 0, 	OutVarTemp6Y := 0, 	OutVarTemp6W := 0, 	OutVarTemp6H := 0
		,xNext := 0, 		yNext := 0, 			wNext := 0, 			hNext := 0
		,WleftMiniColumn := 0,	WrightMiniColumn := 0,	SpaceBetweenColumns := 0
		,W_InfoSign := 0, 		W_C1 := 0,			W_C2 := 0,			GPB := 0
	
;4. Determine constraints, according to mock-up
;4.1. Determine left columnt width
	GuiControlGet, OutVarTemp1, Pos, % IdTextInfo1
	W_InfoSign := OutVarTemp1W
	
	GuiControlGet, OutVarTemp1, Pos, % IdCheckBox1
	GuiControlGet, OutVarTemp2, Pos, % IdCheckBox3
	GuiControlGet, OutVarTemp3, Pos, % IdCheckBox4
	GuiControlGet, OutVarTemp4, Pos, % IdCheckBox5
	GuiControlGet, OutVarTemp6, Pos, % IdCheckBox8
	W_C1 := Max(OutVarTemp1W, OutVarTemp2W, OutVarTemp3W, OutVarTemp4W, OutVarTemp6W) + c_xmarg + W_InfoSign
	
	GuiControlGet, OutVarTemp1, Pos, % IdRadioCaseCC
	GuiControlGet, OutVarTemp2, Pos, % IdRadioCaseCS
	GuiControlGet, OutVarTemp3, Pos, % IdRadioCaseC1
	; GuiControlGet, OutVarTemp4, Pos, % IdCheckBox6
	W_C2 := Max(OutVarTemp1W, OutVarTemp2W, OutVarTemp3W, OutVarTemp4W) + c_xmarg + W_InfoSign
	
,	LeftColumnW := 2 * c_xmarg + W_C1 + c_xmarg + W_C2 + c_xmarg
	
;4.2. Determine right column width
	RightColumnW := LeftColumnW
	
;5. Move text objects to correct position
;5.1. Left column
;5.1.1. Enter triggerstring
	xNext := c_xmarg
,	yNext := c_ymarg
	GuiControl, Move, % IdText1, % "x" . xNext . "y" . yNext
	
	GuiControlGet, OutVarTemp1, Pos, % IdText1
	xNext += OutVarTemp1W + c_xmarg
	GuiControl, Move, % IdTextInfo1, % "x" . xNext . "y" . yNext
	xNext += W_InfoSign + c_xmarg
,	wNext := LeftColumnW - xNext - c_xmarg
	GuiControl, Move, % IdEdit1, % "x" . xNext . "y" . yNext . "w" . wNext
	
;5.1.2. Select trigger options
	xNext := c_xmarg 
,	yNext := c_ymarg + c_HofEdit + c_HofText 
,	wNext := c_xmarg + W_C1 + c_xmarg  + W_C2
,	hNext := c_HofText + c_ymarg + c_HofCheckBox * 5 + c_ymarg
	GuiControl, Move, % IdGroupBox1, % "x" . xNext . "y" . yNext . "w" . wNext . "h" . hNext
;5.1.2.1. Raw 1: Immediate execute (*) + Case-Conforming
	xNext += c_xmarg
,	yNext += c_HofText + c_ymarg
	GuiControl, Move, % IdCheckBox1, % "x" . xNext . "y" . yNext 
	GuiControlGet, OutVarTemp1, Pos, % IdCheckBox1
	xNext += OutVarTemp1W
	GuiControl, Move, % IdTextInfo2, % "x" . xNext . "y" . yNext 
	xNext := c_xmarg * 2 + W_C1 + c_xmarg
	GuiControl, Move, % IdRadioCaseCC, % "x" . xNext . "y" . yNext
	GuiControlGet, OutVarTemp1, Pos, % IdRadioCaseCC
	xNext += OutVarTemp1W
	GuiControl, Move, % IdTextInfo3, % "x" . xNext . "y" . yNext
;5.1.2.2. Raw 2: No Backspace (B0)	+ Case Sensitive (C)
	xNext := c_xmarg * 2
,	yNext += c_HofCheckBox
	GuiControl, Move, % IdCheckBox3, % "x" . xNext . "y" . yNext
	GuiControlGet, OutVarTemp1, Pos, % IdCheckBox3
	xNext += OutVarTemp1W
	GuiControl, Move, % IdTextInfo4, % "x" . xNext . "y" . yNext 
	xNext := c_xmarg * 2 + W_C1 + c_xmarg
	GuiControl, Move, % IdRadioCaseCS, % "x" . xNext . "y" . yNext
	GuiControlGet, OutVarTemp1, Pos, % IdRadioCaseCS
	xNext += OutVarTemp1W
	GuiControl, Move, % IdTextInfo5, % "x" . xNext . "y" . yNext
;5.1.2.3. Raw 3: Inside Word (?) + Not Case-Conforming (C1)
	xNext := c_xmarg * 2
,	yNext += c_HofCheckBox
	GuiControl, Move, % IdCheckBox4, % "x" . xNext . "y" . yNext	
	GuiControlGet, OutVarTemp1, Pos, % IdCheckBox4
	xNext += OutVarTemp1W
	GuiControl, Move, % IdTextInfo6, % "x" . xNext . "y" . yNext 
	xNext := c_xmarg * 2 + W_C1 + c_xmarg
	GuiControl, Move, % IdRadioCaseC1, % "x" . xNext . "y" . yNext
	GuiControlGet, OutVarTemp1, Pos, % IdRadioCaseC1
	xNext += OutVarTemp1W
	GuiControl, Move, % IdTextInfo7, % "x" . xNext . "y" . yNext
;5.1.2.4. Raw 4: No EndChar (O) + Capitalize each word (C2)
	xNext := c_xmarg * 2
,	yNext += c_HofCheckBox
	GuiControl, Move, % IdCheckBox5, % "x" . xNext . "y" . yNext	
	GuiControlGet, OutVarTemp1, Pos, % IdCheckBox5
	xNext += OutVarTemp1W
	GuiControl, Move, % IdTextInfo8, % "x" . xNext . "y" . yNext 
	xNext := c_xmarg * 2 + W_C1 + c_xmarg
	GuiControl, Move, % IdRadioCaseC2, % "x" . xNext . "y" . yNext
	GuiControlGet, OutVarTemp1, Pos, % IdRadioCaseC2
	xNext += OutVarTemp1W
	GuiControl, Move, % IdTextInfo9, % "x" . xNext . "y" . yNext
;5.1.2.6. Raw 5: Reset Recognizer (Z) + Disable
	xNext := c_xmarg * 2
,	yNext += c_HofCheckBox
	GuiControl, Move, % IdCheckBox8, % "x" . xNext . "y" . yNext	
	GuiControlGet, OutVarTemp1, Pos, % IdCheckBox8
	xNext += OutVarTemp1W
	GuiControl, Move, % IdTextInfo10, % "x" . xNext . "y" . yNext 
;5.1.3. Select hotstring output function
	xNext := c_xmarg
,	yNext += c_HofCheckBox + c_ymarg * 2
	GuiControl, Move, % IdText3, % "x" . xNext . "y" . yNext
	GuiControlGet, OutVarTemp1, Pos, % IdText3
	xNext += OutVarTemp1W + c_xmarg
	GuiControl, Move, % IdTextInfo12, % "x" . xNext . "y" . yNext
	xNext := c_xmarg
,	yNext += c_HofText
,	wNext := LeftColumnW - 2 * c_xmarg
	GuiControl, Move, % IdDDL1, % "x" . xNext . "y" . yNext . "w" . wNext
	
;5.1.4. Enter hotstring
	yNext += c_HofDropDownList + c_ymarg
,	xNext := c_xmarg
	GuiControl, Move, % IdText4, % "x" . xNext . "y" . yNext
	GuiControlGet, OutVarTemp1, Pos, % IdText4
	xNext += OutVarTemp1W + c_xmarg
	GuiControl, Move, % IdTextInfo13, % "x" . xNext . "y" . yNext
	xNext := c_xmarg
,	yNext += c_HofText
,	wNext := LeftColumnW - 2 * c_xmarg
	GuiControl, Move, % IdEdit2, % "x" . xNext . "y" . yNext . "w" . wNext
	yNext += c_HofEdit
	GuiControl, Move, % IdEdit3, % "x" . xNext . "y" . yNext . "w" . wNext
	yNext += c_HofEdit
	GuiControl, Move, % IdEdit4, % "x" . xNext . "y" . yNext . "w" . wNext
	yNext += c_HofEdit
	GuiControl, Move, % IdEdit5, % "x" . xNext . "y" . yNext . "w" . wNext
	yNext += c_HofEdit
	GuiControl, Move, % IdEdit6, % "x" . xNext . "y" . yNext . "w" . wNext
	yNext += c_HofEdit
	GuiControl, Move, % IdEdit7, % "x" . xNext . "y" . yNext . "w" . wNext
	yNext += c_HofEdit
	GuiControl, Move, % IdEdit8, % "x" . xNext . "y" . yNext . "w" . wNext
;5.1.5. Add comment (optional)
	GuiControlGet, OutVarTemp1, Pos, % IdEdit8
	yNext += OutVarTemp1H + c_ymarg
,	xNext := c_xmarg
	GuiControl, Move, % IdText5, % "x" . xNext . "y" . yNext
	GuiControlGet, OutVarTemp1, Pos, % IdText5
	xNext += OutVarTemp1W + c_xmarg
	GuiControl, Move, % IdTextInfo14, % "x" . xNext . "y" . yNext
	xNext := c_xmarg
,	yNext += c_HofText
,	wNext := LeftColumnW - 2 * c_xmarg
	GuiControl, Move, % IdEdit9, % "x" . xNext . "y" . yNext . "w" . wNext
;5.1.6. Select hotstring library text
	yNext += c_HofEdit + c_ymarg
,	xNext := c_xmarg
	GuiControl, Move, % IdText6, % "x" . xNext . "y" . yNext
	GuiControlGet, OutVarTemp1, Pos, % IdText6
	xNext += OutVarTemp1W + c_xmarg
	GuiControl, Move, % IdTextInfo15, % "x" . xNext . "y" . yNext
;5.1.7. Definitions in libraries statistics
	GuiControlGet, OutVarTemp1, Pos, % IdText2	;% IdText2	;info about libraries statistics
	xNext := LeftColumnW - c_xmarg - OutVarTemp1W
	GuiControl, Move, % IdText2, % "x" . xNext . "y" . yNext
	GuiControlGet, OutVarTemp1, Pos, % IdText12
	xNext -= OutVarTemp1W
	GuiControl, MoveDraw, % IdText12, % "x" . xNext . "y" . yNext	;IdText12, value of this library statistics (ratio)
;5.1.8. Drop-down list, select hotstrings library
	yNext += c_HofText
,	xNext := c_xmarg
,	wNext := LeftColumnW - xNext - c_xmarg
	GuiControl, Move, % IdDDL2, % "x" xNext "y" yNext "w" . wNext
;5.1.7. Buttons	
	yNext += c_HofDropDownList + c_ymarg
,	xNext := c_xmarg
	GuiControl, Move, % IdButton2, % "x" . xNext . "y" . yNext
	GuiControlGet, OutVarTemp1, Pos, % IdButton2
	GuiControlGet, OutVarTemp1, Pos, % IdButton3
	xNext := LeftColumnW - (OutVarTemp1W + c_xmarg)
	GuiControl, Move, % IdButton3, % "x" . xNext . "y" . yNext
	yNext += c_HofButton
,	LeftColumnH := yNext
	; OutputDebug, % "HS3 LeftColumnH:" . A_Space . LeftColumnH . "`n"
	
;5.3. Right column
;5.3.1. Position the text "Library content (F2, context menu)"
	yNext := c_ymarg
,	xNext := LeftColumnW + c_WofMiddleButton + c_xmarg
	GuiControl, Move, % IdText7, % "x" . xNext . "y" . yNext
	GuiControlGet, OutVarTemp1, Pos, % IdText7
	xNext += OutVarTemp1W + c_xmarg
	GuiControl, Move, % IdTextInfo16, % "x" . xNext . "y" . yNext	;IdTextInfo16 = i
	
	HS3MinWidth		:= LeftColumnW + c_WofMiddleButton + RightColumnW
,	HS3MinHeight		:= LeftColumnH + c_ymarg
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_GuiAbout_CreateObjects()
{
	global ;assume-global mode
	
	;1. Prepare MyAbout Gui
	Gui, MyAbout: New, 		-Resize +HwndMyAboutGuiHwnd +Owner -MaximizeBox -MinimizeBox
	Gui, MyAbout: Margin,	% c_xmarg, % c_ymarg
	Gui,	MyAbout: Color,	% c_WindowColor, % c_ControlColor
	
	TransA["Enables Convenient Definition"] := StrReplace(TransA["Enables Convenient Definition"], "``n", "`n")
	;2. Prepare all text objects according to mock-up.
	Gui,	MyAbout: Font,		% "s" . c_FontSize . A_Space . "bold" . A_Space . "c" . c_FontColor, 		% c_FontType
	Gui, MyAbout: Add, 		Text,    x0 y0 HwndIdLine1, 										% TransA["Let's make your PC personal again..."]
	Gui,	MyAbout: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, 		% c_FontType
	Gui, MyAbout: Add, 		Text,    	x0 y0 HwndIdLine2, 										% TransA["Enables Convenient Definition"]
	Gui, MyAbout: Add, 		Button,  	x0 y0 HwndIdAboutOkButton gMyAboutGuiClose Default,			% TransA["OK"]
	if (A_IsCompiled)
		Gui, MyAbout: Add,		Picture, 	x0 y0 HwndIdAboutPicture w96 h96 Icon,					% A_ScriptFullPath
	else
		Gui, MyAbout: Add,		Picture, 	x0 y0 HwndIdAboutPicture w96 h96, 						% AppIcon
	Gui, MyAbout: Add,		Text,	x0 y0 HwndIdAboutT1,									% TransA["Version"] . ":"
	Gui, MyAbout: Add,		Text,	x0 y0 HwndIdAboutT2,									% AppVersion
	Gui, MyAbout: Add,		Text,	x0 y0 HwndIdAboutT3,									% TransA["Mode of operation"] . ":"
	Gui, MyAbout: Add,		Text,	x0 y0 HwndIdAboutT4,									% TransA["default"]
	Gui, MyAbout: Add,		Text,	x0 y0 HwndIdAboutT5,									% TransA["Application mode"] . ":"
	Gui, MyAbout: Add,		Text,	x0 y0 HwndIdAboutT6,									ahk
	Gui, MyAbout: Add,		Text,	x0 y0 HwndIdAboutT7,									% TransA["AutoHotkey version"] . ":"
	Gui, MyAbout: Add,		Text,	x0 y0 HwndIdAboutT8,									% A_AhkVersion
	Gui, MyAbout: Add,		Text,	x0 y0 HwndIdAboutT9,									% TransA["License"] . ":"
	Gui, MyAbout: Add,		Text,	x0 y0 HwndIdAboutT10,									% v_LicenseName
	Gui, MyAbout: Add,		Text,	x0 y0 HwndIdAboutT11,									% TransA["License type"] . ":"
	Gui, MyAbout: Add,		Text,	x0 y0 HwndIdAboutT12,									% v_LicenseType
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_GuiAbout_DetermineConstraints()
{
	global ;assume-global mode
	local OutVarTemp := 0, 	OutVarTempX := 0, 	OutVarTempY := 0, 	OutVarTempW := 0, 	OutVarTempH := 0	;Within a function, to create a set of variables that is local instead of global, declare OutputVar as a local variable prior to using command GuiControlGet, Pos. However, it is often also necessary to declare each variable in the set, due to a common source of confusion.
	,	OutVarTemp1 := 0, 	OutVarTemp1X := 0, 	OutVarTemp1Y := 0, 	OutVarTemp1W := 0, 	OutVarTemp1H := 0
	,	OutVarTemp2 := 0, 	OutVarTemp2X := 0, 	OutVarTemp2Y := 0, 	OutVarTemp2W := 0, 	OutVarTemp2H := 0
	,	OutVarTemp3 := 0, 	OutVarTemp3X := 0, 	OutVarTemp3Y := 0, 	OutVarTemp3W := 0, 	OutVarTemp3H := 0
	,	OutVarTemp4 := 0, 	OutVarTemp4X := 0, 	OutVarTemp4Y := 0, 	OutVarTemp4W := 0, 	OutVarTemp4H := 0
	,	xNext := 0, yNext := 0, wNext := 0, hNext := 0
	,	HwndIdLongest := 0, 	IdLongest := 0, MaxText := 0
	
;4. Determine constraints, according to mock-up
	xNext := c_xmarg, yNext := c_ymarg
	GuiControl, Move, % IdLine1, % "x" . xNext . "y"  . yNext	;Let's make your PC personal again...
	GuiControlGet, OutVarTemp, Pos, % IdLine1
	yNext += OutVarTempH + c_ymarg
	GuiControl, Move, % IdLine2, % "x" . xNext . "y" . yNext	;Enables Convenient Definition
	
	;Find the longest substring:
	Loop, Parse, % TransA["Enables Convenient Definition"], % "`n"
	{
		OutVarTemp1 := StrLen(Trim(A_LoopField))
		if (OutVarTemp1 > OutVarTemp)
			OutVarTemp := OutVarTemp1
	}
	Loop, Parse, % TransA["Enables Convenient Definition"], % "`n"
	{
		if (StrLen(Trim(A_LoopField)) = OutVarTemp)
		{
			Gui, MyAbout: Add, Text, x0 y0 HwndIdLongest, % Trim(A_LoopField)
			GuiControlGet, OutVarTemp, Pos, % IdLine1
			xNext := c_xmarg, yNext := c_ymarg + OutVarTempH + c_ymarg
			GuiControl, Move, % IdLongest, % "x" . xNext . "y" . yNext 
			GuiControl, Hide, % IdLongest
			Break
		}
	}
	GuiControlGet, OutVarTemp1, Pos, % IdAboutT1	;Version
	GuiControlGet, OutVarTemp2, Pos, % IdAboutT3	;Mode of operation
	GuiControlGet, OutVarTemp3, Pos, % IdAboutT5	;Application mode
	GuiControlGet, OutVarTemp4, Pos, % IdAboutT7	;AutoHotkey version
	MaxText := Max(OutVarTemp1W, OutVarTemp2W, OutVarTemp3W, OutVarTemp4W)
	GuiControlGet, OutVarTemp, Pos, % IdLine2
	xNext := c_xmarg, yNext := OutVarTempY + OutVarTempH + 2 * c_ymarg
	GuiControl, Move, % IdAboutT1, % "x" . xNext . A_Space . "y" . yNext	;Version
	xNext := MaxText + 3 * c_xmarg
	GuiControl, Move, % IdAboutT2, % "x" . xNext . A_Space . "y" . yNext
	xNext := c_xmarg, yNext += c_HofText
	GuiControl, Move, % IdAboutT3, % "x" . xNext . A_Space . "y" . yNext
	xNext := MaxText + 3 * c_xmarg
	if (v_SilentMode = "l")
		GuiControl, , % IdAboutT4, % TransA["silent"]
	else
		GuiControl, , % IdAboutT4, % TransA["default"]
	GuiControl, Move, % IdAboutT4, % "x" . xNext . A_Space . "y" . yNext
	xNext := c_xmarg, yNext += c_HofText
	GuiControl, Move, % IdAboutT5, % "x" . xNext . A_Space . "y" . yNext
	xNext := MaxText + 3 * c_xmarg
	if (A_IsCompiled)
		GuiControl, , % IdAboutT6, exe
	else
		GuiControl, , % IdAboutT6, ahk
	GuiControl, Move, % IdAboutT6, % "x" . xNext . A_Space . "y" . yNext
	xNext := c_xmarg, yNext += c_HofText
	GuiControl, Move, % IdAboutT7, % "x" . xNext . A_Space . "y" . yNext	;AutoHotkey version
	xNext := MaxText + 3 * c_xmarg
	GuiControl, Move, % IdAboutT8, % "x" . xNext . A_Space . "y" . yNext
	xNext := c_xmarg, yNext += c_HofText
	GuiControl, Move, % IdAboutT9, % "x" . xNext . A_Space . "y" . yNext	;License:
	xNext := MaxText + 3 * c_xmarg
	GuiControl, Move, % IdAboutT10, % "x" . xNext . A_Space . "y" . yNext	;EULA or MIT 
	if (v_LicenseType = "pro")
		GuiControl, , % IdAboutT10, % "EULA" . A_Space . TransA["license"]
	if (v_LicenseType = "free")
		GuiControl, , % IdAboutT10, % "MIT" . A_Space . TransA["license"]
	xNext := c_xmarg, yNext += c_HofText
	GuiControl, Move, % IdAboutT11, % "x" . xNext . A_Space . "y" . yNext	;License type:
	xNext := MaxText + 3 * c_xmarg
	GuiControl, Move, % IdAboutT12, % "x" . xNext . A_Space . "y" . yNext	;type
	if (v_LicenseType = "pro")
		GuiControl, , % IdAboutT12, % TransA["pro"]
	if (v_LicenseType = "free")
		GuiControl, , % IdAboutT12, % TransA["free"]
	xNext := c_xmarg, yNext += c_HofText
	GuiControlGet, OutVarTemp1, Pos, % IdLongest ; weight of the longest text
	GuiControlGet, OutVarTemp2, Pos, % IdAboutOkButton 
	wNext := OutVarTemp2W + 2 * c_xmarg
,	xNext := (OutVarTemp1W // 2) - (wNext // 2)
	GuiControlGet, OutVarTemp, Pos, % IdLine2
	yNext := OutVarTempY + OutVarTempH + 7 * c_HofText + c_ymarg
	GuiControl, Move, % IdAboutOkButton, % "x" . xNext . "y" . A_Space . yNext . "w" . wNext
	GuiControlGet, OutVarTemp3, Pos, % IdAboutT1	;Version
	xNext := OutVarTemp1X + OutVarTemp1W - 96 ;96 = chosen size of icon
,	yNext := OutVarTemp3Y
	GuiControl, Move, % IdAboutPicture, % "x" . xNext . A_Space . "y" . yNext 
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
F_GuiAbout()
{
	global ;assume-global mode
	local Window1X := 0, Window1Y := 0, Window1W := 0, Window1H := 0
		,Window2X := 0, Window2Y := 0, Window2W := 0, Window2H := 0
		,NewWinPosX := 0, NewWinPosY := 0
	
	if (WinExist("ahk_id" . HS3GuiHwnd) or WinExist("ahk_id" . HS3GuiHwnd) or WinExist("ahk_id" . HS4GuiHwnd) or WinExist("ahk_id" . HS4GuiHwnd))
		WinGetPos, Window1X, Window1Y, Window1W, Window1H, A
	Gui, MyAbout: Show, Hide
	
	DetectHiddenWindows, On
	WinGetPos, Window2X, Window2Y, Window2W, Window2H, % "ahk_id" . MyAboutGuiHwnd
	DetectHiddenWindows, Off
	Gui, % A_Gui . ": +Disabled"	;thanks to this line user won't be able to interact with main hotstring window if TTStyling window is available
	if (Window1W)
	{
		NewWinPosX := Round(Window1X + (Window1W / 2) - (Window2W / 2))
		NewWinPosY := Round(Window1Y + (Window1H / 2) - (Window2H / 2))
		Gui, MyAbout: Show, % "AutoSize" . A_Space . "x" . NewWinPosX . A_Space . "y" . NewWinPosY, % A_ScriptName . ":" . A_Space . TransA["About this application..."]
	}
	else
		Gui, MyAbout: Show, Center AutoSize, % A_ScriptName . ":" . A_Space . TransA["About this application..."]
}
; ------------------------------------------------------------------------------------------------------------------------------------
F_CreateLogFolder()
{
	global ;assume-global mode of operation

	HADLog := SubStr(ini_HADL, 1, -StrLen("Libraries")) . "Log"	;global variable
	if (!InStr(FileExist(HADLog), "D"))	; if there is no Log subfolder
	{
		FileCreateDir, % HADLog	;future: check against errors
		MsgBox, 48, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["warning"], % TransA["There is no ""Log"" subfolder. It is now created in parallel with Libraries subfolder."]
			. "`n`n" . HADLog
	}
}
; ------------------------------------------------------------------------------------------------------------------------------------
F_ValidateIniLibSections() ;create Libraries subfolder if it doesn't exist; Load from / to Config.ini from Libraries folder
{
	global ;assume-global mode of operation
	local 		v_ConfigLibrary 	:= ""
			,	o_Libraries 		:= {}
			,	v_LibFileName 		:= ""
			,	key 				:= 0
			,	value 			:= ""
			,	TempLoadLib 		:= ""
			,	TempShowTipsLib 	:= ""
			,	v_LibFlagTemp 		:= ""
			,	FlagFound 		:= false
			,	PriorityFlag 		:= false
			, 	ValueTemp 		:= 0
			,	SectionTemp 		:= ""
			
	ini_LoadLib := {}, ini_ShowTipsLib := {}	; this associative array is used to store information about Libraries\*.csv files to be loaded
	
	IniRead, TempLoadLib,	% ini_HADConfig, LoadLibraries
	
	;Check if Libraries subfolder exists. If not, create it and display warning.
	if (!InStr(FileExist(ini_HADL), "D"))				; if  there is no "Libraries" subfolder 
	{
		FileCreateDir, % ini_HADL							; Future: check against errors
		MsgBox, 48, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["warning"], % TransA["There is no Libraries subfolder and no lbrary (*.csv) file exists!"] 
			. "`n`n" . ini_HADL . "`n`n" . TransA["folder is now created"] . "."
	}
	else
	{
		Loop, Files, % ini_HADL . "\*.csv"
			o_Libraries.Push(A_LoopFileName)
	}

;Check if Config.ini contains in section [Libraries] file names which are actually in library subfolder. Synchronize [Libraries] section with content of subfolder.
;Parse the TempLoadLib.
	for key, value in o_Libraries
	{
		FlagFound := false
		Loop, Parse, TempLoadLib, `n, `r
		{
			v_LibFileName 	:= SubStr(A_LoopField, 1, InStr(A_LoopField, "=") - 1)
,			v_LibFlagTemp 	:= SubStr(A_LoopField, InStr(A_LoopField, "=",, v_LibFileName) + 1)
			if (value == v_LibFileName)
			{
				ini_LoadLib[value] 	:= v_LibFlagTemp
,				FlagFound 		:= true
			}
		}	
		if !(FlagFound)
			ini_LoadLib[value] := 1
	}
	
;Delete and recreate [Libraries] section of Config.ini mirroring ini_LoadLib associative table.
	IniDelete, % ini_HADConfig, LoadLibraries
	for key, value in ini_LoadLib
		SectionTemp .= key . "=" . value . "`n"
	
	IniWrite, % SectionTemp, % ini_HADConfig, LoadLibraries
	
	SectionTemp := ""
;Check if Config.ini contains in section [ShowTipsLibraries] file names which are actually in library subfolder. Synchronize [Libraries] section with content of subfolder.
;Parse the TempLoadLib.
	IniRead, TempShowTipsLib, % ini_HADConfig, ShowTipsLibraries
	for key, value in o_Libraries
	{
		FlagFound := false
		Loop, Parse, TempShowTipsLib, `n, `r
		{
			v_LibFileName 	:= SubStr(A_LoopField, 1, InStr(A_LoopField, "=") - 1)
,			v_LibFlagTemp 	:= SubStr(A_LoopField, InStr(A_LoopField, "=",, v_LibFileName) + 1)
			if (value == v_LibFileName)
			{
				ini_ShowTipsLib[value] 	:= v_LibFlagTemp
,				FlagFound 			:= true
			}
		}
		if !(FlagFound)
			ini_ShowTipsLib[value] := 1
	}
	
;Delete and recreate [ShowTipsLibraries] section of Config.ini mirroring ini_ShowTipsLib associative table.
	IniDelete, % ini_HADConfig, ShowTipsLibraries
	for key, value in ini_ShowTipsLib
		SectionTemp .= key . "=" . value . "`n"

	IniWrite, % SectionTemp, % ini_HADConfig, ShowTipsLibraries
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_LoadLibrariesToTables()
{ 
	global	;assume-global mode
	local 	name := "", varSearch := "", tabSearch := "", BegCom := false

		a_Library 				:= []
	,	a_TriggerOptions 			:= []
	,	a_Triggerstring 			:= []
	,	a_OutputFunction 			:= []
	,	a_EnableDisable 			:= []
	,	a_Hotstring				:= []
	,	a_Comment 				:= []
	
	; Prepare TrayTip message taking into account value of command line parameter.
	if (v_SilentMode == "l")
		TrayTip, %A_ScriptName% - Lite mode, 	% TransA["Loading hotstrings from libraries..."], 1
	else	
		TrayTip, %A_ScriptName%,				% TransA["Loading hotstrings from libraries..."], 1
	
	;Here content of libraries is loaded into set of tables
	Loop, Files, % ini_HADL . "\*.csv"
	{
		Loop
		{
			FileReadLine, varSearch, %A_LoopFileFullPath%, %A_Index%
			if (ErrorLevel)
				break
			if (SubStr(varSearch, 1, 1) = ";")	;catch the comments
				continue
			if (SubStr(varSearch, 1, 2) = "/*")	;catch beginning of the first comment in the file = beginning of header
			{
				BegCom := true
				continue
			}
			if (BegCom) and (SubStr(varSearch, -1) = "*/") ;catch the end of the last comment in the file = end of of header
			{
				BegCom := false
				continue
			}
			if (BegCom)
				continue
			if (!varSearch)	;ignore empty lines
				continue

			name 	:= SubStr(A_LoopFileName, 1, -4)
,			tabSearch := StrSplit(varSearch, c_TextDelimiter)
,			a_Library			.Push(name)
,			a_TriggerOptions	.Push(tabSearch[1])
,			a_Triggerstring	.Push(tabSearch[2])
,			a_OutputFunction	.Push(tabSearch[3])
,			a_EnableDisable	.Push(tabSearch[4])
,			a_Hotstring		.Push(tabSearch[5])
,			a_Comment			.Push(tabSearch[6])
		}
	}
	TrayTip, %A_ScriptName%, % TransA["Hotstrings have been loaded"], 1
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_CreateHotstring(txt, nameoffile)
{ 
	global	;assume-global mode
	local Options := "", SendFun := "", EnDis := "", TextInsert := "", Oflag := false, Triggerstring := "", LenStr := 0

	Loop, Parse, txt, % c_TextDelimiter
	{
		Switch A_Index
		{
			Case 1:
				Options 	:= A_LoopField
			,	Oflag 	:= false
				if (InStr(Options, "O", false))
					Oflag := true
				else
					Oflag := false
				if (InStr(Options, "C2"))	;actually "C2" isn't allowed / existing argument of "Hotstring" function can understand so just before this function is called the "NewOptions" string is checked if there is "C2" available. If it does, "C2" is replaced with "".
					Options := StrReplace(Options, "C2", "")
			Case 2:
				Triggerstring := F_ConvertEscapeSequences(A_LoopField)
			Case 3:
				SendFun := A_LoopField
			Case 4: 
				Switch A_LoopField
				{
					Case "En":	EnDis := true
					Case "Dis":	EnDis := false
				}
			Case 5:
				TextInsert := A_LoopField
		}
	}
	
	if ((Triggerstring == "") and (Options or SendFun or EnDis or TextInsert))	; previous version: if ((!Triggerstring) and (Options or SendFun or EnDis or TextInsert))
	{
		MsgBox, 262420, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["Error"], % TransA["Error reading library file:"] . "`n`n" . nameoffile . "`n`n" . TransA["the following line is found:"] 
					. "`n" . txt . "`n`n" . TransA["This line do not comply to format required by this application."] . "`n`n" 
					. TransA["Continue reading the library file? If you answer ""No"" then application will exit!"]
		IfMsgBox, No
			try	;if no try, some warnings are still catched; with try no more warnings
				ExitApp, 1	;error reading library file
		IfMsgBox, Yes
			return
	}
	if (EnDis = "")	;This is consequence of hard lesson: mismatch of "column name". This line hopefully protects against this kind of event in the future.
		MsgBox, 16, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["Error"], % A_ThisFunc . "`n`n" . A_Space . TransA["Something went wrong with (triggerstring, hotstring) creation"] . ":" . "`n`n"
			. "Hotstring(:" . Options . ":" . Triggerstring . "," . "func(" . SendFun . ").bind(" . TextInsert . "," . A_Space . Oflag . ")," . A_Space . EnDis . ")" . "`n"
			. TransA["OnOff parameter is missing."]
			. "`n`n" . TransA["Library name:"] . A_Tab . nameoffile
	
	if (Triggerstring != "") and (EnDis)
	{
		if (SendFun = "SI") or (SendFun = "SE") or (SendFun = "SP") or (SendFun = "SR") or (SendFun = "CL") or (SendFun = "S1") or (SendFun = "S2")
		{
			Try
				Hotstring(":" . Options . ":" . Triggerstring, func("F_SimpleOutput").bind(TextInsert, Oflag, SendFun), EnDis)
			Catch
				MsgBox, 16, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["Error"], % A_ThisFunc . A_Space . TransA["Something went wrong with (triggerstring, hotstring) creation"] . ":" . "`n`n"
					. "Hotstring(:" . Options . ":" . Triggerstring . "," . "func(""F_SimpleOutput"").bind(" . TextInsert . "," . A_Space . Oflag . "," . A_Space . SendFun . ")," . A_Space . EnDis . ")"
		}
		if (SendFun = "MSI") or (SendFun = "MCL")
		{
			Try
				Hotstring(":" . Options . ":" . Triggerstring, func("F_HMenu_Output").bind(TextInsert, Oflag, SendFun), EnDis)
			Catch
				MsgBox, 16, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["Error"], % A_ThisFunc . A_Space . TransA["Something went wrong with (triggerstring, hotstring) creation"] . ":" . "`n`n"
					. "Hotstring(:" . Options . ":" . Triggerstring . "," . "func(""F_HMenu_Output"").bind(" . TextInsert . "," . A_Space . Oflag . ")," . A_Space . EnDis . ")"
					. "`n`n" . TransA["Library name:"] . A_Tab . nameoffile
		}
		if (SendFun = "P")
		{
			Try
				Hotstring(":" . Options . ":" . Triggerstring, func("F_PictureShow").bind(TextInsert, Oflag, SendFun), EnDis)
			Catch
				MsgBox, 16, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["Error"], % A_ThisFunc . A_Space . TransA["Something went wrong with (triggerstring, hotstring) creation"] . ":" . "`n`n"
					. "Hotstring(:" . Options . ":" . Triggerstring . "," . "func(""F_PictureShow"").bind(" . TextInsert . "," . A_Space . Oflag . ")," . A_Space . EnDis . ")"
					. "`n`n" . TransA["Library name:"] . A_Tab . nameoffile
		}
		if (SendFun = "R")
		{
			Try
				Hotstring(":" . Options . ":" . Triggerstring, func("F_RunApplication").bind(TextInsert, Oflag, SendFun), EnDis)
			Catch
				MsgBox, 16, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["Error"], % A_ThisFunc . A_Space . TransA["Something went wrong with (triggerstring, hotstring) creation"] . ":" . "`n`n"
					. "Hotstring(:" . Options . ":" . Triggerstring . "," . "func(""F_RunApplication"").bind(" . TextInsert . "," . A_Space . Oflag . ")," . A_Space . EnDis . ")"
					. "`n`n" . TransA["Library name:"] . A_Tab . nameoffile
		}
	}
}

; =================================================================================
; Function: AutoXYWH
;   Move and resize control automatically when GUI resizes.
; Parameters:
;   DimSize - Can be one or more of x/y/w/h  optional followed by a fraction
;             add a '*' to DimSize to 'MoveDraw' the controls rather then just 'Move', this is recommended for Groupboxes
;   cList   - variadic list of ControlIDs
;             ControlID can be a control HWND, associated variable name, ClassNN or displayed text.
;             The later (displayed text) is possible but not recommend since not very reliable 
; Examples:
;   AutoXYWH("xy", "Btn1", "Btn2")
;   AutoXYWH("w0.5 h 0.75", hEdit, "displayed text", "vLabel", "Button1")
;   AutoXYWH("*w0.5 h 0.75", hGroupbox1, "GrbChoices")
; ---------------------------------------------------------------------------------
; Version: 2015-5-29 / Added 'reset' option (by tmplinshi)
;          2014-7-03 / toralf
;          2014-1-2  / tmplinshi
; requires AHK version : 1.1.13.01+
; =================================================================================
F_AutoXYWH(DimSize, cList*){       ; http://ahkscript.org/boards/viewtopic.php?t=1079
	static cInfo := {}
	AutoXYWHOptions := 0
	
	If (DimSize = "reset")
		Return cInfo := {}
	
	For i, ctrl in cList 
	{
		ctrlID                    := A_Gui ":" ctrl
		If ( cInfo[ctrlID].x = "" ){
			GuiControlGet, i, %A_Gui%:Pos, %ctrl%
			MMD              := InStr(DimSize, "*") ? "MoveDraw" : "Move"
			fx               := fy := fw := fh := 0
			For i, dim in (a := StrSplit(RegExReplace(DimSize, "i)[^xywh]")))
				If !RegExMatch(DimSize, "i)" dim "\s*\K[\d.-]+", f%dim%)
					f%dim% := 1
			cInfo[ctrlID]     := { x:ix, fx:fx, y:iy, fy:fy, w:iw, fw:fw, h:ih, fh:fh, gw:A_GuiWidth, gh:A_GuiHeight, a:a , m:MMD}
		}
		Else If ( cInfo[ctrlID].a.1) 
		{
			dgx              := dgw := A_GuiWidth  - cInfo[ctrlID].gw  , dgy := dgh := A_GuiHeight - cInfo[ctrlID].gh
			For i, dim in cInfo[ctrlID]["a"]
				AutoXYWHOptions .= dim (dg%dim% * cInfo[ctrlID]["f" dim] + cInfo[ctrlID][dim]) A_Space
			GuiControl, % A_Gui ":" cInfo[ctrlID].m , % ctrl, % AutoXYWHOptions
		} 
	} 
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_ReplaceAHKconstants(String)
{
	String := StrReplace(String, "A_YYYY", 		A_YYYY)
,	String := StrReplace(String, "A_Year", 		A_Year)
,	String := StrReplace(String, "A_MMMM", 		A_MMMM)
,	String := StrReplace(String, "A_MMM", 		A_MMM)
,	String := StrReplace(String, "A_MM", 		A_MM)
,	String := StrReplace(String, "A_Mon", 		A_Mon)
,	String := StrReplace(String, "A_DDDD", 		A_DDDD)
,	String := StrReplace(String, "A_DDD", 		A_DDD)
,	String := StrReplace(String, "A_DD", 		A_DD)
,	String := StrReplace(String, "A_MDay", 		A_MDay)
,	String := StrReplace(String, "A_WDay", 		A_WDay)
,	String := StrReplace(String, "A_YDay", 		A_YDay)
,	String := StrReplace(String, "A_YWeek", 	A_YWeek)
,	String := StrReplace(String, "A_Hour",		A_Hour)
,	String := StrReplace(String, "A_Min", 		A_Min)
,	String := StrReplace(String, "A_Sec", 		A_Sec)
,	String := StrReplace(String, "A_MSec", 		A_MSec)
,	String := StrReplace(String, "A_Now", 		A_Now)
,	String := StrReplace(String, "A_NowUTC", 	A_NowUTC)
,	String := StrReplace(String, "A_TickCount", 	A_TickCount)
	return String
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_PrepareUndo(string)
{	;this function replaces from hotstring definition all characters which aren't necessary to undo last hotstring
	string := RegExReplace(string, "Ui)({Backspace.*})|({BS.*})")
	if (InStr(string, "{!}")) or (InStr(string, "{^}")) or (InStr(string, "{+}")) or (InStr(string, "{#}")) or (InStr(string, "{{}")) or (InStr(string, "{}}"))
		string := RegExReplace(string, "U)({)|(})")
	return string
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_HMenu_Mouse(SendFun) ; Handling of mouse events for F_HMenu_Output;The subroutine may consult the following built-in variables: A_Gui, A_GuiControl, A_GuiEvent, and A_EventInfo.
{	
	global	;assume-global mode of operation
	Critical, On
	local	OutputVarTemp := "", ReplacementString := "", ChoicePos := 0, temp := 0, ThisHotkey := A_ThisHotkey
		,	OutputVarControl := 0	; OutputVarControl: to store the name (ClassNN) of the control under the mouse cursor.
		,	OutputVarWin := ""		;The name of the output variable in which to store the unique ID number of the window under the mouse cursor. If the window cannot be determined, this variable will be made blank.

	; OutputDebug, % A_ThisFunc . A_Space . "B" . A_Space . "ThisHotkey:" . ThisHotkey . "`n"
	if (InStr(ThisHotkey, "LButton"))
	{
		MouseGetPos, , , OutputVarWin, OutputVarControl
		if (InStr(OutputVarControl, "Button"))
			return
		SendMessage, 0x0188, 0, 0, % OutputVarControl, % "ahk_id" . OutputVarWin	;retrieve the position of the selected item; https://www.autohotkey.com/docs/v1/lib/ControlGet.htm
		ChoicePos := (ErrorLevel<<32>>32) + 1			;Convert UInt to Int to have -1 if there is no item selected and convert from 0-based to 1-based, i.e. so that the first item is known as 1, not 0.
		GuiControlGet, OutputVarTemp, HMenuAHK:, % OutputVarControl ;alternative: GuiControlGet, OutputVarTemp, , % Id_LB_HMenuAHK	
		OutputVarTemp := SubStr(OutputVarTemp, 4)
		Gui, HMenuAHK: Destroy
		v_UndoHotstring 	:= OutputVarTemp
	,	OutputVarTemp 		:= F_ReplaceAHKconstants(OutputVarTemp)
	,	OutputVarTemp 		:= F_FollowCaseConformity(OutputVarTemp, v_InputString, v_Options)
	,	OutputVarTemp 		:= F_ConvertEscapeSequences(OutputVarTemp)
	,	v_InputH.VisibleText 	:= true
		Switch SendFun
		{
			Case "MSI":
				; OutputDebug, % "OutputVarTemp:" . OutputVarTemp . "|" . "SendFun:" . SendFun . "|" . "`n"
				F_SendIsOflag(OutputVarTemp, Ovar, "SI")
			Case "MCL":
				; OutputDebug, % "OutputVarTemp:" . OutputVarTemp . "|" . "SendFun:" . SendFun . "|" . "`n"
				F_ClipboardPaste(OutputVarTemp, Ovar, v_EndChar)
		}

		if (ini_MHSEn)
			SoundBeep, % ini_MHSF, % ini_MHSD
		if (InStr(ThisHotkey, "?"))
			v_InputString := SubStr(ThisHotkey, InStr(ThisHotkey, ":", , 2) + 1)	;A_ThisHotkey: the most recently executed non-auto-replace hotstring (blank if none).
		temp := F_DetermineGain2(v_InputString, OutputVarTemp)
		v_CntCumGain += temp
;#c/* commercial only beginning		
;#c*/ commercial only end			
		v_UndoTriggerstring 	:= v_InputString
	,	v_InputString 			:= ""
	}
	; OutputDebug, % A_ThisFunc . A_Space . "E" . A_Space . "ErrorLevel:" . ErrorLevel . "|" . "`n"
	Critical, Off
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_HMenu_Output(ReplacementString, Oflag, SendFun)
{
	global	;assume-global mode
	Critical, On	;This line is necessary to protect against two concurretnt Hotstrings listboxes on the screen: HMenu and triggerstring tips. Without this line the F_OneCharPressed interrupts this function.
	local	a_MCSIMenuPos := [], ThisHotkey := A_ThisHotkey, EndChar := A_EndChar
		,	SingleKey := ""
		,	WhatWasPressed := ""
		,	f_Shift := false

	; OutputDebug, % A_ThisFunc . A_Space . "v_InputString:" . v_InputString . "|" . "`n"
	v_InputH.VisibleText 	:= false
,	v_UndoHotstring		:= ReplacementString	;important for F_Undo	
,	v_Options 			:= F_DetermineOptions(Triggerstring := SubStr(ThisHotkey, InStr(ThisHotkey, ":", true, 2, 1) + 1))
,	v_EndChar 			:= F_DetermineEndChar(ThisHotkey, v_Options, EndChar)
	if (InStr(v_Options, "?"))
		v_InputString := ProcessQuestionMark(v_Options, ThisHotkey, v_InputString, v_EndChar)
	v_UndoTriggerstring 	:= v_InputString		;important for F_Undo
,	v_SendFun				:= SendFun			;important for F_Undo
,	v_MenuMax				:= 0	;global variable used in F_HMenuAHK

	F_DestroyTriggerstringTips(ini_TTCn)
	if (ini_MHSEn)		;Second beep will be produced on purpose by main loop 
		SoundBeep, % ini_MHSF, % ini_MHSD
	Loop, Parse, ReplacementString, % c_MHDelimiter	;determine amount of rows for Listbox
		v_MenuMax := A_Index
	
	if (ini_TTCn != 4)	;if not static window, draw small simple GUI
	{
		Gui, HMenuAHK: New, +AlwaysOnTop -Caption +ToolWindow +HwndHMenuAHKHwnd +Delimiter%c_MHDelimiter%	;This trick changes delimiter for GuiControl,, ListBox from default "|" to that one
		Gui, HMenuAHK: Margin, 0, 0
		if (ini_HMBgrCol = "custom")
			Gui, HMenuAHK: Color,, % ini_HMBgrColCus
		else
			Gui, HMenuAHK: Color,, % ini_HMBgrCol
		if (ini_HMTyFaceCol = "custom")	
			Gui, HMenuAHK: Font, % "s" . ini_HMTySize . A_Space . "c" . ini_HMTyFaceColCus, % ini_HMTyFaceFont
		else
			Gui, HMenuAHK: Font, % "s" . ini_HMTySize . A_Space . "c" . ini_HMTyFaceCol, % ini_HMTyFaceFont
		Gui, HMenuAHK: Add, Listbox, % "x0 y0 w250 HwndId_LB_HMenuAHK" . A_Space . "r" . v_MenuMax
		Func_HMenu_Mouse := func("F_HMenu_Mouse").bind(SendFun)
		GuiControl +g, % Id_LB_HMenuAHK, % Func_HMenu_Mouse
		Loop, Parse, ReplacementString, % c_MHDelimiter	;second parse of the same variable, this time in order to fill in the Listbox
			GuiControl,, % Id_LB_HMenuAHK, % A_Index . ". " . A_LoopField . c_MHDelimiter
		
		a_MCSIMenuPos := F_WhereDisplayMenu(ini_MHMP)
		F_FlipMenu(HMenuAHKHwnd, a_MCSIMenuPos[1], a_MCSIMenuPos[2], "HMenuAHK")
		GuiControl, Choose, % Id_LB_HMenuAHK, 1
	}
	else	;(ini_TTCn = 4)
	{
		; OutputDebug, % "PreviousWindowID1:" . A_Tab . PreviousWindowID . "`n"
		Loop, Parse, ReplacementString, % c_MHDelimiter	;second parse of the same variable, this time in order to fill in the Listbox
			GuiControl,, % IdTT_C4_LB4, % A_Index . ". " . A_LoopField . c_MHDelimiter
		GuiControl, Choose, % IdTT_C4_LB4, 1
		Gui, TT_C4: Flash	;future: flashing (blinking) in a loop until user do not take action
		WhichMenu := "SI"	;this setting will be used within F_MouseMenuCombined() to handle mouse event
	}
	Ovar := Oflag
	; OutputDebug, % A_ThisFunc . A_Space . "end" . A_Space . "v_InputString:" . v_InputString . "|" . "`n"
	Critical, Off
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_DetermineOptions(Triggerstring)	;
{
	global	;assume-global mode of operation
	local	key := 0, value := "", Options := ""

	for key, value in a_Triggerstring
		if (Triggerstring = a_Triggerstring[key])
			{
				Options := a_TriggerOptions[key]
				break
			}
	return Options
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_DetermineEndChar(ThisHotkey, v_Options, EndChar)
{
	if (InStr(v_Options, "*"))
		return SubStr(ThisHotkey, 0) ;extracts the last character; This form is important to run correctly F_Undo 
	else
		return EndChar
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
ProcessQuestionMark(v_Options, ThisHotkey, v_InputString, v_EndChar)
{ ;https://www.autohotkey.com/docs/commands/Hotstring.htm: When a hotstring is first created -- either by the Hotstring function or a double-colon label in the script -- its trigger string and sequence of option characters becomes the permanent name of that hotstring as reflected by A_ThisHotkey. This name does not change even if the Hotstring function later accesses the hotstring with different option characters. Therefore it is imperative to store otpions in a separate variable / array.
	local	WhatPartTriggered := "", LengthToBeCut := 0, ShorterInputString := ""

	if (!InStr(v_Options, "*"))
		v_InputString	:= SubStr(v_InputString, 1, -1)
	WhatPartTriggered 	:= SubStr(ThisHotkey, InStr(ThisHotkey, ":", , 2) + 1)	
,	LengthToBeCut 		:= StrLen(WhatPartTriggered)
,	ShorterInputString	:= SubStr(v_InputString, -LengthToBeCut + 1)
	return ShorterInputString
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_SendIsOflag(OutputString, Oflag, SendFun)	;F_HMenu_Output() -> F_SendIsOflag; F_HMenu_Mouse -> F_SendIsOflag; F_SimpleOutput -> F_SendIsOflag
{
	global	;assume-global mode of operation
	local	LastChar := "", IsLCalpha := false, IsLower := false

	SetKeyDelay, -1, -1	;Delay = -1, PressDuration = -1, -1: no delay at all; this can be necessary if SendInput is reduced to SendEvent (in case low level input hook is active in another script)
	Switch SendFun
	{
		Case "SI":	;SendInput
			; OutputDebug, % "A_SendLevel:" . A_Tab . A_SendLevel . "`n"
			; OutputDebug, % "SendInput:" . OutputString . "|" . A_Space . "A_EndChar:" . A_EndChar . "|" . "`n"
			if (Oflag = false)
			{
				if (A_EndChar)
				{
					SendInput, 	% OutputString
					SendRaw, 		% A_EndChar		;Some of the EndChars require escaping (e.g. {}! etc.). Therefore it is better to send out EndChar in SendRaw mode.
				}
				else	;immediate definitions (*) option:
				{
					Process, Exist, ShiftFunctions.exe	;detects if ShiftFunctions.exe exists. Answer to this question is available in ErrorLevel. If it exists, send out the last character with SendLevel high enough to get to ShiftFunctions. Caveat: also second instance of Hotstrings will get it.
					if (ErrorLevel)
					{
						LastChar 		:= SubStr(OutputString, 0)		;only last character is copied
						if LastChar is alpha
							IsLCalpha := true
						if (IsLCalpha)
						{
							if LastChar is lower
								IsLower := true
							if (IsLower)
							{
								OutputString 	:= SubStr(OutputString, 1, -1)	;all but last characters are copied back to OutputString
								; OutputDebug, % "A_SendLevel:" . A_SendLevel . "|" . A_Space . "LastChar:" . LastChar . "|" . A_Space . "OutputString:" . OutputString . "|" . "`n"
								SendInput, 	% OutputString
								SendLevel, 	2	;only for ShiftFunctions for which InputLevel MinSendLevel is set to 2.
								SendInput, 	% LastChar	;only last character of definition is send with different level of SendLevel; thanks to that ShiftFunctions can alter it into diacritics.
								SendLevel, 	0
							}
							else
							{	
								OutputString 	:= SubStr(OutputString, 1, -1)	;all but last characters are copied back to OutputString
								; OutputDebug, % "A_SendLevel:" . A_SendLevel . "|" . A_Space . "LastChar:" . LastChar . "|" . A_Space . "OutputString:" . OutputString . "|" . "`n"
								SendInput, 	% OutputString	
								SendLevel, 2
								Switch LastChar				
								{
									Case "A":	Send, {U+0041}	;A
									Case "B":	Send, {U+0042}	;B
									Case "C":	Send, {U+0043}	;C
									Case "D":	Send, {U+0044}	;D
									Case "E":	Send, {U+0045}	;E
									Case "F":	Send, {U+0046}	;F
									Case "G":	Send, {U+0047}	;G
									Case "H":	Send, {U+0048}	;H
									Case "I":	Send, {U+0049}	;I
									Case "J":	Send, {U+004a}	;J
									Case "K":	Send, {U+004b}	;K
									Case "L":	Send, {U+004c}	;L
									Case "M":	Send, {U+004d}	;M
									Case "N":	Send, {U+004e}	;N
									Case "O":	Send, {U+004f}	;O
									Case "P":	Send, {U+0050}	;P
									Case "Q":	Send, {U+0051}	;Q
									Case "R":	Send, {U+0052}	;R
									Case "S":	Send, {U+0053}	;S
									Case "T":	Send, {U+0054}	;T
									Case "U":	Send, {U+0055}	;U
									Case "V":	Send, {U+0056}	;V
									Case "W":	Send, {U+0057}	;W
									Case "X":	Send, {U+0058}	;X
									Case "Y":	Send, {U+0059}	;Y
									Case "Z":	Send, {U+005a}	;Z
								}
								SendLevel, 0
							}
						}
						else
							SendInput, 	% OutputString
					}
					else
						SendInput, 	% OutputString
				}	
				; OutputDebug, % "Finished SendInput" . "`n"
			}
			else
				SendInput, % OutputString
		Case "SE":	;SendEvent
			if (Oflag = false)
			{
				SendEvent, 	% OutputString
				if (A_EndChar)
					SendRaw,		% A_EndChar		;Some of the EndChars require escaping (e.g. {}! etc.). Therefore it is better to send out EndChar in SendRaw mode.
			}
			else
				SendEvent, % OutputString
		Case "SP":	;SendPlay does not trigger hotkeys or hotstrings
			if (Oflag = false)
			{
				SendPlay, % OutputString . A_EndChar	;It seems that for SendPlay EndChars do not require escaping
				; OutputDebug, % "SendPlay:" . A_Space . OutputString . "`n"
			}
			else
				SendPlay, % OutputString
		Case "SR":	;SendRaw
			if (Oflag = false)
				SendRaw, % OutputString . A_EndChar
			else
				SendRaw, % OutputString
		Case "CL":
			; OutputDebug, % "OutputString:" . OutputString . "|" . A_Space . "Oflag:" . Oflag . "|" . A_Space . "v_EndChar:" . v_EndChar . "|" . "`n"
			F_ClipboardPaste(OutputString, Oflag, v_EndChar)
		Case "S1":
			FirstPart			:= SubStr(OutputString, 1, -1) ;omits last character
			SecondPart		:= SubStr(OutputString, 0)	 ;extracts the last character
			; OutputDebug, % "First part:" . FirstPart . A_Space . "Second part:" . SecondPart . "|" . "`n"
			if (Oflag = false)
			{
				SendInput, 	% FirstPart 
				if (A_EndChar)
					SendRaw,		% A_EndChar		;Some of the EndChars require escaping (e.g. {}! etc.). Therefore it is better to send out EndChar in SendRaw mode.
			}
			else
				SendInput, % FirstPart
			Hotstring("Reset")
			SendLevel, % ini_SendLevel
			if (Oflag = false)
			{
				SendInput, 	% SecondPart
				if (A_EndChar)
					SendRaw,		% A_EndChar		;Some of the EndChars require escaping (e.g. {}! etc.). Therefore it is better to send out EndChar in SendRaw mode.
			}
			else
				SendInput, % SecondPart
			SendLevel, 0
		Case "S2":
			; OutputDebug, % "ini_SendLevel:" . A_Space . ini_SendLevel . "`n"
			SendLevel, % ini_SendLevel
			if (OutputString = "{NumLock}") or (OutputString = "{ScrollLock}") or (OutputString = "{CapsLock}")
				Switch OutputString
				{
					Case "{NumLock}":
						Send, {NumLock}
     					SendLevel, 0
						return
					Case "{ScrollLock}":
						Send, {ScrollLock}
						SendLevel, 0
						return
					Case "{CapsLock}":
						SetStoreCapslockMode, Off	;it doesn't work on all keyboards!
						Send, {CapsLock}
						SendLevel, 0
						return
				}
			if (Oflag = false)
			{
				SendInput, 	% OutputString
				if (A_EndChar)
					SendRaw,		% A_EndChar		;Some of the EndChars require escaping (e.g. {}! etc.). Therefore it is better to send out EndChar in SendRaw mode.
			}
			else
				SendInput, % OutputString
			SendLevel, 0
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_SimpleOutput(ReplacementString, Oflag, SendFun)	;Function _ Hotstring Output Function _ SendInput
{
	global	;assume-global mode of operation
	Critical, On
	local	ThisHotkey := A_ThisHotkey, EndChar := A_EndChar, temp := 0

	; OutputDebug, % A_ThisFunc . A_Space . "ReplacementString:" . ReplacementString . "|" . "SendFun:" . SendFun . "|" . "`n"
	F_DestroyTriggerstringTips(ini_TTCn)
	v_UndoHotstring	:= ReplacementString	;important for F_Undo
,	v_SendFun			:= SendFun			;important for F_Undo
,	v_Options 		:= F_DetermineOptions(Triggerstring := SubStr(ThisHotkey, InStr(ThisHotkey, ":", true, 2, 1) + 1))
,	v_EndChar 		:= F_DetermineEndChar(ThisHotkey, v_Options, EndChar)
	if (InStr(v_Options, "?"))
		v_InputString := ProcessQuestionMark(v_Options, ThisHotkey, v_InputString, v_EndChar)
	
	v_UndoTriggerstring := v_InputString
,	ReplacementString 	:= F_ReplaceAHKconstants(ReplacementString)
	; OutputDebug, % "F_ReplaceAHKconstants" . A_Space . "ReplacementString:" . ReplacementString . "|" . "`n"
,	ReplacementString 	:= F_FollowCaseConformity(ReplacementString, v_InputString, v_Options)
	; OutputDebug, % "F_FollowCaseConformity" . A_Space . "ReplacementString:" . ReplacementString . "|" . "`n"
,	ReplacementString 	:= F_ConvertEscapeSequences(ReplacementString)
	; OutputDebug, % "F_ConvertEscapeSequences" . A_Space . "ReplacementString:" . ReplacementString . "|" . "`n"
	if (SubStr(ReplacementString, 0) = "``")	;extracts the last character
		ReplacementString := SubStr(ReplacementString, 1, StrLen(ReplacementString) - 1)	;without last character
	
	; OutputDebug, % A_ThisFunc . A_Space . "SendFun:" . SendFun . "|" . "`n"
	F_SendIsOflag(ReplacementString, Oflag, SendFun)
	F_EventSigOrdHotstring()
	temp := F_DetermineGain2(v_InputString, ReplacementString)
	v_CntCumGain += temp
	; OutputDebug, % A_ThisFunc . A_Space . "ThisHotkey:" . ThisHotkey . A_Space . "v_EndChar:" . v_EndChar . "`n"
;#c/* commercial only beginning	
;#c*/ commercial only end		
	v_InputString 		:= ""
	; OutputDebug, % "v_Options:" . v_Options . "|" . "`n"
	if (InStr(v_Options, "z", false))	;fundamental change, now "z" parameter metters
		Hotstring("Reset")
	Critical, Off
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_DetermineGain2(Triggerstring, Hotstring)
{
	CntUpper := 0, LenHots := 0, LenTrig := 0
	Loop, Parse, % Triggerstring
	{
		if A_LoopField is upper
			CntUpper++
	}
	LenTrig += StrLen(Triggerstring) + CntUpper
,	CntUpper := 0
	LenHots 	:= 	F_CountSpecialChar("{Enter}", 	Hotstring)
			+ 	F_CountSpecialChar("{Left}", 		Hotstring)
			+ 	F_CountSpecialChar("{Right}", 	Hotstring)
			+ 	F_CountSpecialChar("{Up}", 		Hotstring)
			+	F_CountSpecialChar("{Down}", 		Hotstring)
			+	F_CountSpecialChar("{Backspace}", 	Hotstring)
			+	F_CountSpecialChar("{BS}",	 	Hotstring)
			+	F_CountSpecialChar("{Shift}", 	Hotstring)
			+	F_CountSpecialChar("{Ctrl}", 		Hotstring)
			+	F_CountSpecialChar("{Alt}", 		Hotstring)
			+	F_CountSpecialChar("{LWin}", 		Hotstring)
			+	F_CountSpecialChar("{RWin}", 		Hotstring)
			+	F_CountSpecialChar("{+}", 		Hotstring)
			+	F_CountSpecialChar("{!}", 		Hotstring)
			+	F_CountSpecialChar("{{}", 		Hotstring)
			+	F_CountSpecialChar("{}}", 		Hotstring)
			+	F_CountSpecialChar("{Space}", 	Hotstring)
			+	F_CountSpecialChar("{Tab}", 		Hotstring)
			+	F_CountSpecialChar("{Home}", 		Hotstring)
			+	F_CountSpecialChar("{End}", 		Hotstring)
			+	F_CountSpecialChar("{PgUp}", 		Hotstring)
			+	F_CountSpecialChar("{PgDn}", 		Hotstring)
			+	F_CountAHKconstants(Hotstring)
			+	F_CountUnicodeChars(Hotstring)

	Loop, Parse, % Hotstring
	{
		if A_LoopField is upper
			CntUpper++
	}
	LenHots += StrLen(Hotstring) + CntUpper
     return, LenHots - LenTrig
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_FollowCaseConformity(ReplacementString, InputString, Options)
{
	global	;assume-global mode
	local vFirstLetter1 := "", vFirstLetter2 := "", NewReplacementString := "", vRestOfLetters := "", fRestOfLettersCap := false, fFirstLetterCap := false, key := "", value := "", ThisHotkey := ""
	
	if  (!InStr(Options, "C")) and (!InStr(Options, "C1")) and (!InStr(Options, "C2"))	;v_Options is global variable, which value comes from F_DeterminePartStrings
	{
		vFirstLetter1 		:= SubStr(InputString, 1, 1)	;it must be v_InputString, because A_ThisHotkey do not preserve letter size!
	,	vRestOfLetters 	:= SubStr(InputString, 2)		;it must be v_InputString, because A_ThisHotkey do not preserve letter size!
		if vFirstLetter1 is upper
			fFirstLetterCap 	:= true
		if (RegExMatch(InputString, "^[[:punct:][:digit:][:upper:][:space:]]*$"))
			fRestOfLettersCap 	:= true

		if (fFirstLetterCap and fRestOfLettersCap)
		{
			StringUpper, NewReplacementString, ReplacementString
			NewReplacementString := StrReplace(NewReplacementString, "``N", "``n")	;if hotstring contains special combination "`n" it is initially converted to "`N" and then again it must be converted to "`n" in order to work correctly.
			return NewReplacementString
		}
		if (fFirstLetterCap and !fRestOfLettersCap)
		{
			vFirstLetter2 := SubStr(ReplacementString, 1, 1)
			StringUpper, vFirstLetter2, vFirstLetter2
			NewReplacementString := vFirstLetter2 . SubStr(ReplacementString, 2)
			return NewReplacementString
		}
		if (!fFirstLetterCap)
			return ReplacementString
	}
	if (InStr(v_Options, "C2"))
	{
		vFirstLetter1 		:= SubStr(InputString, 1, 1)	;it must be v_InputString, because A_ThisHotkey do not preserve letter size!
	,	vRestOfLetters 	:= SubStr(InputString, 2)		;it must be v_InputString, because A_ThisHotkey do not preserve letter size!		
		if vFirstLetter1 is upper
			fFirstLetterCap 	:= true
		if (RegExMatch(InputString, "^[[:punct:][:digit:][:upper:][:space:]]*$"))
			fRestOfLettersCap 	:= true
		if (fFirstLetterCap and fRestOfLettersCap)
		{
			StringUpper, NewReplacementString, ReplacementString
			NewReplacementString := StrReplace(NewReplacementString, "``N", "``n")	;if hotstring contains special combination "`n" it is initially converted to "`N" and then again it must be converted to "`n" in order to work correctly.
			return NewReplacementString
		}
		if (fFirstLetterCap and !fRestOfLettersCap)
		{
			NewReplacementString := RegexReplace(ReplacementString, "(^[a-z])|((\s)[a-z])|(-[a-z])", "$U0")
			return NewReplacementString
		}				
	}	
	if (InStr(v_Options, "C") or InStr(v_Options, "C1"))
		return ReplacementString
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_ClipboardPaste(string, Oflag, v_EndChar)
{
	global	;assume-global mode
	local ClipboardBackup := ClipboardAll
	if (Oflag = false)
		Clipboard := string . A_EndChar
	else
		Clipboard := string
	ClipWait
	Send, ^v
	Sleep, %ini_CPDelay% ; this sleep is required surprisingly
	Clipboard := ClipboardBackup	
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_TTMenuStatic_Mouse() ;The subroutine may consult the following built-in variables: A_Gui, A_GuiControl, A_GuiEvent, and A_EventInfo.
{
	global	;assume-global mode
	local	OutputVarTemp := ""
		,	ThisHotkey := A_ThisHotkey
		,	ChoicePos := 0

	; OutputDebug, % A_ThisFunc . A_Space . "B" . "`n"
	if (!ini_ATEn)
		return
	; OutputDebug, % "ThisHotkey:" . ThisHotkey . "|" . A_Space . "v_InputString:" . A_Tab . v_InputString . "`n"
	MouseGetPos, , , , OutputVarTemp			;to store the name (ClassNN) of the control under the mouse cursor
	SendMessage, 0x0188, 0, 0, % OutputVarTemp	;retrieve the position of the selected item
	ChoicePos := (ErrorLevel<<32>>32) + 1		;Convert UInt to Int to have -1 if there is no item selected. Convert from 0-based to 1-based, i.e. so that the first item is known as 1, not 0.
	; OutputDebug, % "OutputVarTemp:" . OutputVarTemp . "|" . A_Space . "ChoicePos:" . ChoicePos . "|" . "`n"
	if (InStr(ThisHotkey, "LButton"))
	{
		Critical, On
		Switch ini_TTCn
		{
			Case 1: 
				GuiControl, 	Choose, 			% IdTT_C1_LB1, % ChoicePos
				GuiControlGet, OutputVarTemp, , 	% IdTT_C1_LB1
				Gui, TT_C1: Destroy
			Case 2: 
				GuiControl, 	Choose, 			% IdTT_C2_LB1, % ChoicePos
				GuiControlGet, OutputVarTemp, , 	% IdTT_C2_LB1 
				Gui, TT_C2: Destroy
			Case 3: 
				GuiControl, 	Choose, 			% IdTT_C3_LB1, % ChoicePos
				GuiControlGet, OutputVarTemp, , 	% IdTT_C3_LB1
				Gui, TT_C3: Destroy
			Case 4:
				GuiControl, 	Choose, 			% IdTT_C4_LB1, % ChoicePos
				GuiControlGet, OutputVarTemp, , 	% IdTT_C4_LB1 
				WinActivate, % "ahk_id" PreviousWindowID
		}
		; OutputDebug, % "ini_TTCn:" . ini_TTCn . A_Space . "OutputVarTemp:" . OutputVarTemp . "`n"
		F_BackFeed(OutputVarTemp)
		v_InputString := ""
		Critical, Off
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_MouseMenuCombined() ;Handling of mouse events for static menus window; Valid if static triggerstring / hotstring menus GUI is available. "Combined" because it chooses between "MSI" and "MCL".
{
	global	;assume-global mode of operation
	local	OutputVarControl := 0, OutputVarTemp := "", ReplacementString := "", ChoicePos := 0, temp := 0

	; OutputDebug, % A_ThisFunc . "`n"
	if (A_PriorKey = "LButton")
	{
		MouseGetPos, , , , OutputVarControl			;to store the name (ClassNN) of the control under the mouse cursor
		SendMessage, 0x0188, 0, 0, % OutputVarControl	;retrieve the position of the selected item
		ChoicePos := (ErrorLevel<<32>>32) + 1			;Convert UInt to Int to have -1 if there is no item selected and convert from 0-based to 1-based, i.e. so that the first item is known as 1, not 0.
		GuiControl, Choose, % OutputVarControl, % ChoicePos
		GuiControlGet, OutputVarTemp, , % OutputVarControl
		OutputVarTemp := SubStr(OutputVarTemp, 4)
		GuiControl,, % IdTT_C4_LB4, % c_MHDelimiter
		WinActivate, % "ahk_id" PreviousWindowID
		v_UndoHotstring 	:= OutputVarTemp
	,	ReplacementString 	:= F_ReplaceAHKconstants(OutputVarTemp)
	,	ReplacementString 	:= F_FollowCaseConformity(ReplacementString, v_InputString, v_Options)
	,	ReplacementString 	:= F_ConvertEscapeSequences(ReplacementString)
		Switch WhichMenu	;this parameter is set wihin F_HMenu_Output and F_HMenu_Output
		{
			Case "SI":	F_SendIsOflag(ReplacementString, Ovar, "SI")
			Case "CLI":	F_ClipboardPaste(ReplacementString, Ovar, v_EndChar)
		}
		if (ini_MHSEn)
			SoundBeep, % ini_MHSF, % ini_MHSD
		if (InStr(A_ThisHotkey, "?"))
			v_InputString := SubStr(A_ThisHotkey, InStr(A_ThisHotkey, ":", , 2) + 1)	;A_ThisHotkey: the most recently executed non-auto-replace hotstring (blank if none).
		temp := F_DetermineGain2(v_InputString, ReplacementString)
		v_CntCumGain += temp
;#c/* commercial only beginning		
;#c*/ commercial only end			
		v_UndoTriggerstring 	:= v_InputString
	,	v_InputString 			:= ""
	,	v_InputH.VisibleText 	:= true
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_LoadEndChars() ;Load from Config.ini 
{
	global	;assume-global mode
	local	vOutputVarSection := "", key := "", val := "", tick := false, LastKey := ""
	
	HotstringEndChars 	:= ""
	a_HotstringEndChars := {}
	
	IniRead, vOutputVarSection, % ini_HADConfig, EndChars
	Loop, Parse, vOutputVarSection, =`n, `r%A_Tab%
	{
		if !(tick)
		{
			key := A_LoopField
			tick := true
		}
		else
		{
			val := A_LoopField
			tick := false
			if (val)
			{
				Switch key
				{
					Case "Space": 	HotstringEndChars .= A_Space
					Case "Enter": 	HotstringEndChars .= "`n"
					Case "Tab":	HotstringEndChars .= "`t"
					Default:
					LastKey := SubStr(key, 0)
					HotstringEndChars .= LastKey
				}
			}
		}			
		a_HotstringEndChars[key] := val
	}
	
	Try
		Hotstring("EndChars", HotstringEndChars)
	Catch
		MsgBox, 16, % SubStr(A_ScriptName, 1, -4) . A_Space . TransA["Error"], % A_ThisFunc . A_Space . TransA["Something went wrong with hotstring EndChars"] . ":" . "`n`n"
			. "EndChars" . ":" . A_Space . HotstringEndChars
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_SortArrayByLength(a_array)
{
	local a_TempArray, v_Length, v_ActLen
	a_TempArray := []
	v_Length := 0
	Loop, % a_array.MaxIndex()
	{
		v_Length := Max(StrLen(a_array[A_Index]), v_Length)
	}
	Loop, % v_Length
	{
		v_ActLen := A_Index
		Loop, % a_array.MaxIndex()
		{
			if StrLen(a_array[A_Index]) == v_ActLen
			{
				a_TempArray.Push(a_array[A_Index])
			}
		}
	}
	return a_TempArray
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_ImportLibrary()
{
	global	;assume-global mode
	local 	IdImport_P1 := 0, IdImport_T1 := 0
,			HS3GuiWinX := 0, HS3GuiWinY := 0, HS3GuiWinW := 0, HS3GuiWinH := 0
,			ImportGuiWinW := 0, ImportGuiWinH := 0
,			OutputFile := "", OutNameNoExt := ""
,			TotalLines := 9999, line := "", Progress := 100
,			a_Hotstring := [], Options := "", Trigger := "", Hotstring := ""
,			TheWholeFile := ""
,			OutVarTemp := 0, 	OutVarTempX := 0, 	OutVarTempY := 0, 	OutVarTempW := 0, 	OutVarTempH := 0
,			xNext := 0, 		yNext := 0, 			wNext := 0, 			hNext := 0
,			NewStr := "", LibraryName := ""
,			key := "", value := 0, f_ExistedLib := false, BegCom := false
,			EnDis := "En", OutFun := "SI", Comment := "", WhichGUI := ""

	WhichGUI := F_WhichGui()
	Gui, % WhichGUI . ":" . A_Space . "+OwnDialogs"
	FileSelectFile, LibraryName, 3, %A_ScriptDir%, % TransA["Choose (.ahk) file containing (triggerstring, hotstring) definitions for import"], AutoHotkey (*.ahk)
	if (!LibraryName)
		return
	SplitPath, LibraryName, ,,, OutNameNoExt
	OutputFile := % ini_HADL . "\" . OutNameNoExt . ".csv"
	
	if (FileExist(OutputFile))
	{
		MsgBox, 52, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["warning"], % TransA["Such file already exists"] . ":" . "`n`n" . OutputFile . "`n`n" . TransA["Do you want to overwrite it?"] . "`n`n" 
			. TransA["If you answer ""Yes"", the existing file will be overwritten. This is recommended choice. If you answer ""No"", new content will be added to existing file."]
		IfMsgBox, Yes	;check if it was loaded. if yes, recommend restart of application, because "Total" counter and Hotstrings definitions will be incredible. 
		{
			for key, value in ini_LoadLib
				if (key = OutNameNoExt)
					f_ExistedLib := true
			FileDelete, % OutputFile
		}
	}
	
	NewStr := RegExReplace(TransA["Import from .ahk to .csv"], "&", "")
	
	Gui, Import: New, 	+Border -Resize -MaximizeBox -MinimizeBox +HwndImportGuiHwnd +Owner +OwnDialogs, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . NewStr
	Gui, Import: Margin,	% c_xmarg, % c_ymarg
	Gui,	Import: Color,	% c_WindowColor, % c_ControlColor
	Gui,	Import: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, 					% c_FontType
	
	Gui, Import: Add, Text,		x0 y0 HwndIdImport_T1, % TransA["Conversion of .ahk file into new .csv file (library) and loading of that new library"]
	Gui, Import: Add, Progress, 	x0 y0 HwndIdImport_P1 cBlue, 0
	Gui, Import: Add, Text, 		x0 y0 HwndIdImport_T2, % TransA["Converted"] . A_Space . Progress . A_Space . TransA["of"] . A_Space . TotalLines . A_Space . TransA["(triggerstring, hotstring) definitions"]
		. A_Space . "(" . Progress . A_Space . "%" . ")"
	TotalLines := 0
, 	Progresss := 0
	GuiControlGet, OutVarTemp, Pos, % IdImport_T1
	xNext := c_xmarg
,	yNext := c_ymarg
	GuiControl, Move, % IdImport_T1, % "x" xNext . A_Space . "y" yNext
;Gui, Import: Show, Center AutoSize
	yNext += c_HofText + c_ymarg
	GuiControl, Move, % IdImport_T2, % "x" xNext . A_Space . "y" yNext
	GuiControlGet, OutVarTemp, Pos, % IdImport_T1
	wNext := OutVarTempW
,	hNext := c_HofText
	GuiControl, Move, % IdImport_P1, % "x" xNext . A_Space . "y" yNext . A_Space . "w" wNext . A_Space . "h" . hNext
	yNext += c_HofText + c_ymarg
	GuiControl, Move, % IdImport_T2, % "x" xNext . A_Space . "y" yNext
;Gui, Import: Show, Center AutoSize
	Gui, Import: Show, Hide
	
	Switch WhichGUI
	{
		Case "HS3": WinGetPos, HS3GuiWinX, HS3GuiWinY, HS3GuiWinW, HS3GuiWinH, % "ahk_id" . HS3GuiHwnd
		Case "HS4": WinGetPos, HS3GuiWinX, HS3GuiWinY, HS3GuiWinW, HS3GuiWinH, % "ahk_id" . HS4GuiHwnd 
	}
	DetectHiddenWindows, On
	WinGetPos, , , ImportGuiWinW, ImportGuiWinH, % "ahk_id" . ImportGuiHwnd
	DetectHiddenWindows, Off
	Gui, % WhichGUI . ":" . A_Space . "+Disabled"
	Gui, Import: Show, % "x" . HS3GuiWinX + (HS3GuiWinW - ImportGuiWinW) / 2 . A_Space . "y" . HS3GuiWinY + (HS3GuiWinH - ImportGuiWinH) / 2 . A_Space . "AutoSize"
	
	FileRead, TheWholeFile, % LibraryName
	TotalLines := F_HowManyLines(TheWholeFile)
	
	if (TotalLines = 0)
	{
		MsgBox, 48, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["warning"], % TransA["The selected file is empty. Process of import will be interrupted."]
		return
	}
	if (WhichGui = "HS4") ;in order to have access to ListView even when HS4 is active, temporarily default gui is switched to HS3.
		Gui, HS3: Default
	GuiControl, % "Count" . TotalLines . A_Space . "-Redraw", % IdListView1 ;This option serves as a hint to the control that allows it to allocate memory only once rather than each time a row is added, which greatly improves row-adding performance (it may also improve sorting performance). 
	LV_Delete()
	
	BegCom := false
	Loop, Parse, TheWholeFile, `n, `r%A_Space%%A_Tab%
	{
		if (!A_LoopField)							;ignore empty lines
			Continue
		if (SubStr(A_LoopField, 1, 2) = "/*") ;don't read lines containing comments
		{
			BegCom := true
			Continue
		}
		if (BegCom) and (SubStr(A_LoopField, -1) = "*/") ;ignore lines containing comments
		{
			BegCom := false
			Continue
		}
		if (BegCom)								;ignore lines containing comments
			Continue
		if (SubStr(A_LoopField, 1, 1) = ";")			;ignore lines containing comments
			Continue
		Loop, Parse, A_LoopField, :, `r
		{
			Switch A_Index
			{
				Case 2: Options := A_LoopField
				Case 3: Trigger := A_LoopField
				Case 5: Hotstring := A_LoopField
			}
		}
		LV_Add("", EnDis, Trigger, Options, OutFun, Hotstring)
		Progress := Round((A_Index / TotalLines) * 100)
		GuiControl,, % IdImport_T2, % TransA["Converted"] . A_Space . A_Index . A_Space . TransA["of"] . A_Space . TotalLines . A_Space . TransA["(triggerstring, hotstring) definitions"]
			. A_Space . "(" . Progress . A_Space . "%" . ")"
		GuiControl,, % IdImport_P1, % Progress
	}
	LV_ModifyCol(2, "Sort")
	TheWholeFile := ""
	GuiControl,, % IdImport_T1, % TransA["Saving of sorted content into .csv file (library)"]
	Loop, % LV_GetCount()
	{
		LV_GetText(Options, 	A_Index, 1)
		LV_GetText(Trigger, 	A_Index, 2)
		LV_GetText(Hotstring, 	A_Index, 3)
		line := Options . c_TextDelimiter . Trigger . c_TextDelimiter . OutFun . c_TextDelimiter . EnDis . c_TextDelimiter . Hotstring . c_TextDelimiter . Comment
		TheWholeFile .= line . "`n"
		Progress := Round((A_Index / TotalLines) * 100)
		GuiControl,, % IdImport_P1, % Progress
		GuiControl,, % IdImport_T2, % TransA["Saved"] . A_Space . A_Index . A_Space . TransA["of"] . A_Space . TotalLines . A_Space . TransA["(triggerstring, hotstring) definitions"]
		. A_Space . "(" . Progress . A_Space . "%" . ")"
	}	
	FileAppend, % TheWholeFile, % OutputFile, UTF-8
	
	LV_Delete()
	GuiControl, +Redraw, % IdListView1 ;Afterward, use GuiControl, +Redraw to re-enable redrawing (which also repaints the control).
	Gui, % WhichGUI . ":" . A_Space . "-Disabled"
	Gui, Import: Destroy
	
	MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["Library has been imported."]
	if (f_ExistedLib)
	{
		MsgBox, , 48, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["warning"], TransA["The already imported file already existed. As a consequence some (triggerstring, hotstring) definitions could also exist and ""Total"" could be incredible. Therefore application will be now restarted in order to correctly apply the changes."]
		F_SaveGUIPos()
		ini_GuiReload := true
		IniWrite, % ini_GuiReload,		% ini_HADConfig, GraphicalUserInterface, GuiReload
		Reload
	}
	else	
	{
		F_ValidateIniLibSections()
		F_RefreshListOfLibraries()	; this function calls F_RefreshListOfLibraryTips() as both options are interrelated
		F_UpdateSelHotLibDDL()
		F_LoadDefinitionsFromFile(OutNameNoExt . ".csv")
		F_LoadTriggTipsFromFile(OutNameNoExt . ".csv")
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_HowManyLines(TheWholeFile) ;how many not empty lines, not commented out, contains a file
{
	local BegCom := false, TotalLines := 0
	
	Loop, Parse, TheWholeFile, `n, `r%A_Space%%A_Tab%
	{
		if (!A_LoopField)	;ignore empty lines
			Continue
		if (SubStr(A_LoopField, 1, 2) = "/*")	;ignore comments
		{
			BegCom := true
			Continue
		}
		if (BegCom) and (SubStr(A_LoopField, -1) = "*/") ;ignore comments
		{
			BegCom := false
			Continue
		}
		if (BegCom)
			Continue
		if (SubStr(A_LoopField, 1, 1) = ";")	;ignore comments
			Continue
		TotalLines++
	}
	return TotalLines
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_ExportLibraryStatic()
{
	global	;assume-global mode
	local	LibraryName := "", Progress := 100, TotalLines := 9999
,			OutVarTemp := 0, OutVarTempX := 0, OutVarTempY := 0, OutVarTempW := 0, OutVarTempH := 0
,			HS3GuiWinX := 0, HS3GuiWinY := 0, HS3GuiWinW := 0, HS3GuiWinH := 0, ExportGuiWinW := 0, ExportGuiWinH := 0
,			OutFileName := "", OutNameNoExt := "", LibrariesDir := "", OutputFile := "", TheWholeFile := "", line := ""
,			Options := "", Trigger := "", Function := "", EnDis := "", Hotstring := "", Comment := "", a_MenuHotstring := []
,			WhichGUI := ""		
,			Header := "
(
; This file is result of export from Hotstrings.ahk application (https://github.com/mslonik/Hotstrings).
#SingleInstance force 			; Only one instance of this script may run at a time!
#NoEnv  						; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  						; Enable warnings to assist with detection of common errors.
SendMode Input  				; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%		; Ensures a consistent starting directory.
FileEncoding, UTF-8		 		; Sets the default encoding for FileRead, FileReadLine, Loop Read, FileAppend, and FileOpen(). Unicode UTF-16, little endian byte order (BMP of ISO 10646). Useful for .ini files which by default are coded as UTF-16. https://docs.microsoft.com/pl-pl/windows/win32/intl/code-page-identifiers?redirectedfrom=MSDN
)"
	WhichGUI := F_WhichGui()
	Gui, % WhichGUI . ":" . A_Space . "+OwnDialogs"
	FileSelectFile, LibraryName, 3, % ini_HADL . "\", % TransA["Choose library file (.csv) for export"], CSV Files (*.csv)]
	if (!LibraryName)
		return
	
	SplitPath, LibraryName, OutFileName, , , OutNameNoExt
	LibrariesDir := % ini_HADL . "\ExportedLibraries"
	if !InStr(FileExist(LibrariesDir), "D")
		FileCreateDir, %LibrariesDir%
	OutputFile := % ini_HADL . "\ExportedLibraries\" . OutNameNoExt . "." . "ahk"
	
	if (FileExist(OutputFile))
	{
		MsgBox, 52, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["warning"], % TransA["Such file already exists"] . ":" . "`n`n" . OutputFile . "`n`n" . TransA["Do you want to overwrite it?"] . "`n`n" 
		. TransA["If you answer ""Yes"", the existing file will be deleted. If you answer ""No"", the current task will be continued and new content will be added to existing file."]
		IfMsgBox, Yes
			FileDelete, % OutputFile
	}	
	
	Gui, Export: New, 		+Border -Resize -MaximizeBox -MinimizeBox +HwndExportGuiHwnd +Owner +OwnDialogs, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["Export to .ahk with static definitions of hotstrings"] 
	Gui, Export: Margin,	% c_xmarg, % c_ymarg
	Gui,	Export: Color,		% c_WindowColor, % c_ControlColor
	Gui,	Export: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, 					% c_FontType	
	
	Gui, Export: Add, Text,		x0 y0 HwndIdExport_T1, TransA["Conversion of .csv library file into new .ahk file containing static (triggerstring, hotstring) definitions"]
	Gui, Export: Add, Progress, 	x0 y0 HwndIdExport_P1 cBlue, 0
	Gui, Export: Add, Text, 		x0 y0 HwndIdExport_T2, % TransA["Exported"] . A_Space . TotalLines . A_Space . TransA["of"] . A_Space . TotalLines . A_Space . TransA["(triggerstring, hotstring) definitions"]
		. A_Space . "(" . Progress . A_Space . "%" . ")"
	Progress 		:= 0
,	TotalLines 	:= 0

	GuiControlGet, OutVarTemp, Pos, % IdExport_T1
	v_xNext := c_xmarg
,	v_yNext := c_ymarg
	GuiControl, Move, % IdExport_T1, % "x" v_xNext . A_Space . "y" v_yNext
	;Gui, Export: Show, Center AutoSize
	v_yNext += c_HofText + c_ymarg
	GuiControl, Move, % IdExport_T2, % "x" v_xNext . A_Space . "y" v_yNext
	;Gui, Export: Show, Center AutoSize
	GuiControlGet, OutVarTemp, Pos, % IdExport_T2
	v_wNext := OutVarTempW
,	v_hNext := c_HofText
	GuiControl, Move, % IdExport_P1, % "x" v_xNext . A_Space . "y" v_yNext . A_Space . "w" v_wNext . A_Space . "h" . v_hNext
	v_yNext += c_HofText + c_ymarg
	GuiControl, Move, % IdExport_T2, % "x" v_xNext . A_Space . "y" v_yNext
	;Gui, Export: Show, Center AutoSize
	Progress   := 0
,	TotalLines := 0
	GuiControl,, % IdExport_T2, % TransA["Exported"] . A_Space . TotalLines . A_Space . TransA["of"] . A_Space . TotalLines . A_Space . TransA["(triggerstring, hotstring) definitions"] . A_Space . "(" . Progress . A_Space . "%" . ")"
	;Gui, Export: Show, Center AutoSize	
	Gui, Export: Show, Hide
	
	Switch WhichGUI
	{
		Case "HS3": WinGetPos, HS3GuiWinX, HS3GuiWinY, HS3GuiWinW, HS3GuiWinH, % "ahk_id" . HS3GuiHwnd
		Case "HS4": WinGetPos, HS3GuiWinX, HS3GuiWinY, HS3GuiWinW, HS3GuiWinH, % "ahk_id" . HS4GuiHwnd 
	}
	DetectHiddenWindows, On
	WinGetPos, , , ExportGuiWinW, ExportGuiWinH, % "ahk_id" . ExportGuiHwnd
	DetectHiddenWindows, Off
	Gui, Export: Show, % "x" . HS3GuiWinX + (HS3GuiWinW - ExportGuiWinW) / 2 . A_Space . "y" . HS3GuiWinY + (HS3GuiWinH - ExportGuiWinH) / 2 . A_Space . "AutoSize"
	Gui, % WhichGUI . ":" . A_Space . "+Disabled"
	
	FileRead, TheWholeFile, % LibraryName
	TotalLines := F_HowManyLines(TheWholeFile)
	
	if (TotalLines = 0)
	{
		MsgBox, 48, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["warning"], % TransA["The selected file is empty. Process of export will be interrupted."]
		return
	}
	line .= Header . "`n`n"
	Loop, Parse, TheWholeFile, `n, `r%A_Space%%A_Tab%
	{
		if (SubStr(A_LoopField, 1, 2) = "/*")	;ignore comments
		{
			BegCom := true
			Continue
		}
		if (BegCom) and (SubStr(A_LoopField, -1) = "*/") ;ignore comments
		{
			BegCom := false
			Continue
		}
		if (BegCom)
			Continue
		if (SubStr(A_LoopField, 1, 1) = ";")	;ignore comments
			Continue
		if (!A_LoopField)	;ignore empty lines
			Continue
		
		Loop, Parse, A_LoopField, % c_TextDelimiter, %A_Space%%A_Tab%
		{
			Switch A_Index
			{
				Case 1: Options 	:= A_LoopField
				Case 2: Trigger 	:= A_LoopField
				Case 3: Function 	:= A_LoopField
				Case 4: EnDis 		:= A_LoopField
				Case 5: Hotstring 	:= A_LoopField
				Case 6: Comment 	:= A_LoopField
			}
		}
		if (EnDis = "Dis")
		{
			line .= ";" . A_Space
		}
		if (InStr(Function, "M"))
		{
			a_MenuHotstring := StrSplit(Hotstring, c_MHDelimiter)
			Loop, % a_MenuHotstring.MaxIndex()
			{
				if (A_Index = 1)
				{
					line .= ":" Options . ":" . Trigger . "::" . a_MenuHotstring[A_Index] . A_Space
					if (Comment)
						line .= ";" . Comment . A_Space . ";" . TransA["Warning, code generated automatically for definitions based on menu, see documentation of Hotstrings application for further details."]
					else
						line .= ";" . TransA["Warning, code generated automatically for definitions based on menu, see documentation of Hotstrings application for further details."]
					line .= "`n"
				}
				else
				{
					line .=  ";" . A_Space . ":" Options . ":" . Trigger . "::" . a_MenuHotstring[A_Index] . A_Space 
					if (Comment)
						line .= ";" . Comment . A_Space . ";" . TransA["Warning, code generated automatically for definitions based on menu, see documentation of Hotstrings application for further details."]
					else
						line .= ";" . TransA["Warning, code generated automatically for definitions based on menu, see documentation of Hotstrings application for further details."]
					line .= "`n"
				}
			}
		}
		else
		{
			line .= ":" . Options . ":" . Trigger . "::" . Hotstring . A_Space
			if (Comment)
				line .= ";" . Comment
			line .= "`n"
		}
		
		Progress := Round((A_Index / TotalLines) * 100)
		GuiControl,, % IdExport_T2, % TransA["Exported"] . A_Space . A_Index . A_Space . TransA["of"] . A_Space . TotalLines . A_Space . TransA["(triggerstring, hotstring) definitions"]
			. A_Space . "(" . Progress . A_Space . "%" . ")"
		GuiControl,, % IdExport_P1, % Progress
	}
	FileAppend, % line, % OutputFile, UTF-8
	Gui, % WhichGUI . ":" . A_Space . "-Disabled"
	Gui, Export: Destroy
	MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["Library has been exported"] . ":" . "`n`n" . OutputFile
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_ExportLibraryDynamic()
{
	global	;assume-global mode
	local	LibraryName := "", Progress := 100, TotalLines := 9999
,			OutVarTemp := 0, OutVarTempX := 0, OutVarTempY := 0, OutVarTempW := 0, OutVarTempH := 0
,			HS3GuiWinX := 0, HS3GuiWinY := 0, HS3GuiWinW := 0, HS3GuiWinH := 0, ExportGuiWinW := 0, ExportGuiWinH := 0
,			OutFileName := "", OutNameNoExt := "", LibrariesDir := "", OutputFile := "", TheWholeFile := "", line := ""
,			Options := "", Trigger := "", Function := "", EnDis := "", Hotstring := "", Comment := "", a_MenuHotstring := []
,			WhichGUI := ""
,			Header := "
(
; This file is result of export from Hotstrings.ahk application (https://github.com/mslonik/Hotstrings).
#SingleInstance force 			; Only one instance of this script may run at a time!
#NoEnv  						; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  						; Enable warnings to assist with detection of common errors.
SendMode Input  				; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%		; Ensures a consistent starting directory.
FileEncoding, UTF-8		 		; Sets the default encoding for FileRead, FileReadLine, Loop Read, FileAppend, and FileOpen(). Unicode UTF-16, little endian byte order (BMP of ISO 10646). Useful for .ini files which by default are coded as UTF-16. https://docs.microsoft.com/pl-pl/windows/win32/intl/code-page-identifiers?redirectedfrom=MSDN
)"

	WhichGUI := F_WhichGui()
	Gui, % WhichGUI . ":" . A_Space . "+OwnDialogs"
	FileSelectFile, LibraryName, 3, % ini_HADL, % TransA["Choose library file (.csv) for export"], CSV Files (*.csv)]
	if (!LibraryName)
		return
	
	SplitPath, LibraryName, OutFileName, , , OutNameNoExt
	LibrariesDir := % ini_HADL . "\ExportedLibraries"
	if !InStr(FileExist(LibrariesDir),"D")
		FileCreateDir, %LibrariesDir%
	OutputFile := % ini_HADL . "\ExportedLibraries\" . OutNameNoExt . "." . "ahk"
	
	if (FileExist(OutputFile))
	{
		MsgBox, 52, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["warning"], % TransA["Such file already exists"] . ":" . "`n`n" . OutputFile . "`n`n" . TransA["Do you want to overwrite it?"] . "`n`n" 
			. TransA["If you answer ""Yes"", the existing file will be deleted. If you answer ""No"", the current task will be continued and new content will be added to existing file."]
		IfMsgBox, Yes
			FileDelete, % OutputFile
	}	
	
	Gui, Export: New, 		+Border -Resize -MaximizeBox -MinimizeBox +HwndExportGuiHwnd +Owner +OwnDialogs, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["Export to .ahk with dynamic definitions of hotstrings"] 
	Gui, Export: Margin,	% c_xmarg, % c_ymarg
	Gui,	Export: Color,		% c_WindowColor, % c_ControlColor
	Gui,	Export: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, 					% c_FontType	
	
	Gui, Export: Add, Text,		x0 y0 HwndIdExport_T1, TransA["Conversion of .csv library file into new .ahk file containing dynamic (triggerstring, hotstring) definitions"]
	Gui, Export: Add, Progress, 	x0 y0 HwndIdExport_P1 cBlue, 0
	Gui, Export: Add, Text, 		x0 y0 HwndIdExport_T2, % TransA["Exported"] . A_Space . TotalLines . A_Space . TransA["of"] . A_Space . TotalLines . A_Space . TransA["(triggerstring, hotstring) definitions"]
		. A_Space . "(" . Progress . A_Space . "%" . ")"
	TotalLines 	:= 0
,	Progress 		:= 0	
	
	GuiControlGet, OutVarTemp, Pos, % IdExport_T1
	v_xNext := c_xmarg
	v_yNext := c_ymarg
	GuiControl, Move, % IdExport_T1, % "x" v_xNext . A_Space . "y" v_yNext
	;Gui, Export: Show, Center AutoSize
	v_yNext += c_HofText + c_ymarg
	GuiControl, Move, % IdExport_T2, % "x" v_xNext . A_Space . "y" v_yNext
	;Gui, Export: Show, Center AutoSize
	GuiControlGet, OutVarTemp, Pos, % IdExport_T2
	v_wNext := OutVarTempW
	v_hNext := c_HofText
	GuiControl, Move, % IdExport_P1, % "x" v_xNext . A_Space . "y" v_yNext . A_Space . "w" v_wNext . A_Space . "h" . v_hNext
	v_yNext += c_HofText + c_ymarg
	GuiControl, Move, % IdExport_T2, % "x" v_xNext . A_Space . "y" v_yNext
	;Gui, Export: Show, Center AutoSize
	Progress   := 0
	TotalLines := 0
	GuiControl,, % IdExport_T2, % TransA["Exported"] . A_Space . TotalLines . A_Space . TransA["of"] . A_Space . TotalLines . A_Space . TransA["(triggerstring, hotstring) definitions"] . A_Space . "(" . Progress . A_Space . "%" . ")"
	;Gui, Export: Show, Center AutoSize	
	Gui, Export: Show, Hide
	
	Switch WhichGUI
	{
		Case "HS3": WinGetPos, HS3GuiWinX, HS3GuiWinY, HS3GuiWinW, HS3GuiWinH, % "ahk_id" . HS3GuiHwnd
		Case "HS4": WinGetPos, HS3GuiWinX, HS3GuiWinY, HS3GuiWinW, HS3GuiWinH, % "ahk_id" . HS4GuiHwnd 
	}
	DetectHiddenWindows, On
	WinGetPos, , , ExportGuiWinW, ExportGuiWinH, % "ahk_id" . ExportGuiHwnd
	DetectHiddenWindows, Off
	Gui, Export: Show, % "x" . HS3GuiWinX + (HS3GuiWinW - ExportGuiWinW) / 2 . A_Space . "y" . HS3GuiWinY + (HS3GuiWinH - ExportGuiWinH) / 2 . A_Space . "AutoSize"
	Gui, % WhichGUI . ":" . A_Space . "+Disabled"
	
	FileRead, TheWholeFile, % LibraryName
	TotalLines := F_HowManyLines(TheWholeFile)
	
	if (TotalLines = 0)
	{
		MsgBox, 48, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["warning"], % TransA["The selected file is empty. Process of export will be interrupted."]
		return
	}
	line .= Header . "`n`n"
	Loop, Parse, TheWholeFile, `n, `r%A_Space%%A_Tab%
	{
		if (!A_LoopField)	;ignore empty lines
			Continue
		if (SubStr(A_LoopField, 1, 2) = "/*")	;ignore comments
		{
			BegCom := true
			Continue
		}
		if (BegCom) and (SubStr(A_LoopField, -1) = "*/") ;ignore comments
		{
			BegCom := false
			Continue
		}
		if (BegCom)
			Continue
		if (SubStr(A_LoopField, 1, 1) = ";")	;ignore comments
			Continue
		
		Loop, Parse, A_LoopField, % c_TextDelimiter, %A_Space%%A_Tab%
		{
			Switch A_Index
			{
				Case 1: Options 	:= A_LoopField
				Case 2: Trigger 	:= A_LoopField
				Case 3: Function 	:= A_LoopField
				Case 4: EnDis 		:= A_LoopField
				Case 5: Hotstring 	:= A_LoopField
				Case 6: Comment 	:= A_LoopField
			}
		}
		if (EnDis = "Dis")
		{
			line .= ";" . A_Space
		}
		if (InStr(Function, "M"))
		{
			a_MenuHotstring := StrSplit(Hotstring, c_MHDelimiter)
			Loop, % a_MenuHotstring.MaxIndex()
			{
				if (A_Index = 1)
				{
						;line .= ":" Options . ":" . Trigger . "::" . a_MenuHotstring[A_Index] . A_Space
					line .= "Hotstring(" . """" . ":" . Options . ":" . Trigger . """" . "," . A_Space . """" . a_MenuHotstring[A_Index] . """" . "," . A_Space . EnDis . ")"
					if (Comment)
						line .= ";" . Comment . A_Space . ";" . TransA["Warning, code generated automatically for definitions based on menu, see documentation of Hotstrings application for further details."]
					else
						line .= ";" . TransA["Warning, code generated automatically for definitions based on menu, see documentation of Hotstrings application for further details."]
					line .= "`n"
				}
				else
				{
					line .=  ";" . A_Space . "Hotstring(" . """" . ":" . Options . ":" . Trigger . """" . "," . A_Space . """" . a_MenuHotstring[A_Index] . """" . "," . A_Space . EnDis . ")"
					if (Comment)
						line .= ";" . Comment . A_Space . ";" . TransA["Warning, code generated automatically for definitions based on menu, see documentation of Hotstrings application for further details."]
					else
						line .= ";" . TransA["Warning, code generated automatically for definitions based on menu, see documentation of Hotstrings application for further details."]
					line .= "`n"
				}
			}
		}
		else
		{
			line .= "Hotstring(" . """" . ":" . Options . ":" . Trigger . """" . "," . A_Space . """" . Hotstring . """" . "," . A_Space . EnDis . ")"
			if (Comment)
				line .= ";" . Comment
			line .= "`n"
		}
		
		Progress := Round((A_Index / TotalLines) * 100)
		GuiControl,, % IdExport_T2, % TransA["Exported"] . A_Space . A_Index . A_Space . TransA["of"] . A_Space . TotalLines . A_Space . TransA["(triggerstring, hotstring) definitions"]
			. A_Space . "(" . Progress . A_Space . "%" . ")"
		GuiControl,, % IdExport_P1, % Progress
	}
	FileAppend, % line, % OutputFile, UTF-8
	Gui, % WhichGUI . ":" . A_Space . "-Disabled"
	Gui, Export: Destroy
	MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["Library has been exported"] . ":" . "`n`n" . OutputFile
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
HideTrayTip() 
{
    TrayTip  ; Attempt to hide it the normal way.
    if SubStr(A_OSVersion,1,3) = "10." 
	{
        Menu Tray, NoIcon
        Sleep 200  ; It may be necessary to adjust this sleep.
        Menu Tray, Icon
    }
}

; --------------------------- SECTION OF LABELS ------------------------------------------------------------------------------------------------------------------------------
TurnOff_OHE:
	Gui, Tt_HWT: Hide	;Tooltip: Basic hotstring was triggered
	return

TurnOff_UHE:
	Gui, Tt_ULH: Hide	;Undid the last hotstring
	return

TurnOff_Ttt:
	F_DestroyTriggerstringTips(ini_TTCn)
	return	


