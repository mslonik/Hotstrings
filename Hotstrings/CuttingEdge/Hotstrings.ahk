/* 
	Author:      Maciej Słojewski (mslonik, http://mslonik.pl)
	Purpose:     Facilitate maintenance of (triggerstring, hotstring) concept.
	Description: Hotstrings AutoHotkey concept expanded, editable with GUI and many more options.
	License:     GNU GPL v.3
*/
; -----------Beginning of auto-execute section of the script -------------------------------------------------
; After the script has been loaded, it begins executing at the top line, continuing until a Return, Exit, hotkey/hotstring label, or the physical end of the script is encountered (whichever comes first). 
#Requires AutoHotkey v1.1.33+ 	; Displays an error and quits if a version requirement is not met.    
#SingleInstance force 			; Only one instance of this script may run at a time!
#NoEnv  						; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  						; Enable warnings to assist with detecting common errors.
#LTrim						; Omits spaces and tabs at the beginning of each line. This is primarily used to allow the continuation section to be indented. Also, this option may be turned on for multiple continuation sections by specifying #LTrim on a line by itself. #LTrim is positional: it affects all continuation sections physically beneath it.
SendMode Input  				; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%		; Ensures a consistent starting directory.
FileEncoding, UTF-16			; Sets the default encoding for FileRead, FileReadLine, Loop Read, FileAppend, and FileOpen(). Unicode UTF-16, little endian byte order (BMP of ISO 10646). Useful for .ini files which by default are coded as UTF-16. https://docs.microsoft.com/pl-pl/windows/win32/intl/code-page-identifiers?redirectedfrom=MSDN
; Warning! UTF-16 is not recognized by Notepad++ editor (2021), which recognizes correctly UCS-2 (defined by the International Standard ISO/IEC 10646). 
; BMP = Basic Multilingual Plane.
CoordMode, Caret,	Screen 
CoordMode, ToolTip,	Screen
CoordMode, Mouse,	Screen
; - - - - - - - - - - - - - - - - - - - - - - - G L O B A L    V A R I A B L E S - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
global AppIcon					:= "hotstrings.ico" ; Imagemagick: convert hotstrings.svg -alpha off -resize 96x96 -define icon:auto-resize="96,64,48,32,16" hotstrings.ico
;@Ahk2Exe-Let vAppIcon=%A_PriorLine~U)^(.+"){1}(.+)".*$~$2% ; Keep these lines together
global AppVersion				:= "3.4.0"
;@Ahk2Exe-Let vAppVersion=%A_PriorLine~U)^(.+"){1}(.+)".*$~$2% ; Keep these lines together
;Overrides the custom EXE icon used for compilation
;@Ahk2Exe-SetMainIcon  %U_vAppIcon%
;@Ahk2Exe-SetCopyright GNU GPL 3.x
;@Ahk2Exe-SetDescription Advanced tool for hotstring management.
;@Ahk2Exe-SetProductName Original script name: %A_ScriptName%
;@Ahk2Exe-Set OriginalScriptlocation, https://github.com/mslonik/Hotstrings/tree/master/Hotstrings
;@Ahk2Exe-SetCompanyName  http://mslonik.pl
;@Ahk2Exe-SetFileVersion %U_vAppVersion%
FileInstall, hotstrings.ico, hotstrings.ico, 0
FileInstall, LICENSE, LICENSE, 0

global HADL 					:= A_AppData . "\" . SubStr(A_ScriptName, 1, -4) . "\" . "Libraries" 	; Hotstrings Application Data Libraries
global HADConfig  				:= A_AppData . "\" . SubStr(A_ScriptName, 1, -4) . "\"	. "Config.ini"	;Hotstrings Application Data Config .ini
global v_Param 				:= A_Args[1] ; the only one parameter of Hotstrings app available to user: l or d

global a_Triggers 				:= []		;Main loop of application
global v_HotstringFlag 			:= false		;Main loop of application
global v_InputString 			:= ""		;Main loop of application
global v_MouseX 				:= 0			;Main loop of application
global v_MouseY 				:= 0			;Main loop of application
global v_Tips 					:= ""		;Main loop of application
global v_TipsFlag 				:= false		;Main loop of application

global ini_GuiReload			:= false
global ini_Language 			:= "English.txt"

global v_IndexLog 				:= 1			;for logging, if Hotstrings application is run with d parameter.

global v_TypedTriggerstring 		:= ""		;used by output functions
global v_UndoHotstring 			:= ""		;used by output functions

;Flags to control application
global v_ResizingFlag 			:= true 		;when Hotstrings Gui is displayed for the very first time
global HMenuCliHwnd				:= 0
global HMenuAHKHwnd				:= 0
global TMenuAHKHwnd				:= 0 
; - - - - - - - - - - - - - - - - - - - - - - - B E G I N N I N G    O F    I N I T I A L I Z A T I O N - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
F_DetermineMonitors()
Critical, On
F_LoadCreateTranslationTxt() ;default set of translations (English) is loaded at the very beginning in case if Config.ini doesn't exist yet, but some MsgBox have to be shown.
F_CheckCreateConfigIni() ;1. Try to load up configuration file. If those files do not exist, create them.
F_CheckScriptEncoding()

if ( !Instr(FileExist(A_ScriptDir . "\Languages"), "D"))				; if  there is no "Languages" subfolder 
{
	FileCreateDir, %A_ScriptDir%\Languages							; Future: check against errors
	MsgBox, 48, % SubStr(A_ScriptName, 1, -4) .  ":" . A_Space . TransA["warning"], % TransA["There was no Languages subfolder, so one now is created."] . A_Space . "`n" 
	. A_ScriptDir . "\Languages"
}

IniRead ini_Language, % HADConfig, GraphicalUserInterface, Language				; Load from Config.ini file specific parameter: language into variable ini_Language, e.g. ini_Language = English.txt
if (!ini_Language) or (ini_Language == "ERROR")
{
	MsgBox, 16, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["Error"], % TransA["The parameter Language in section [GraphicalUserInterface] of Config.ini is missing."]
	. "`n`n" . TransA["The default"] . A_Space . "English.txt" . A_Space . TransA["is added in section  [GraphicalUserInterface] of Config.ini"]
	ini_Language := "English.txt"
	IniWrite, % ini_Language, % HADConfig,  GraphicalUserInterface, Language
}
	
if (!FileExist(A_ScriptDir . "\Languages\" . ini_Language))			; else if there is no ini_language .ini file, e.g. v_langugae == Polish.txt and there is no such file in Languages folder
{
	MsgBox, 48, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["warning"], % TransA["There is no"] . A_Space . ini_Language . A_Space . TransA["file in Languages subfolder!"]
	. "`n`n" . TransA["The default"] . A_Space . "English.txt" . A_Space . TransA["file is now created in the following subfolder:"] . "`n`n"  A_ScriptDir . "\Languages\"
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
F_LoadConfiguration()
F_LoadEndChars() ; Read from Config.ini values of EndChars. Modifies the set of characters used as ending characters by the hotstring recognizer.
F_LoadSignalingParams()

F_ValidateIniLibSections() 

;If application wasn't run with "l" parameter (standing for "light / lightweight"), prepare tray menu.
Switch v_Param
{
	Case "l":
		Menu, Tray, NoStandard									; remove all the rest of standard tray menu
		if (!FileExist(AppIcon))
		{
			MsgBox, 68, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["Information"], % TransA["The icon file"] . ":" . "`n`n" . AppIcon . "`n`n" . TransA["doesn't exist in application folder"] . "." 
				. A_Space . TransA["Would you like to download the icon file?"] . "`n`n" . TransA["If you answer ""Yes"", the icon file will be downloaded. If you answer ""No"", the default AutoHotkey icon will be used."]
			IfMsgBox, Yes
				URLDownloadToFile, https://raw.githubusercontent.com/mslonik/Hotstrings/master/Hotstrings/hotstrings.ico, % AppIcon
			IfMsgBox, No
				AppIcon := "*"
		}
		Menu, Tray, Icon,		% AppIcon 						;GUI window uses the tray icon that was in effect at the time the window was created. FlatIcon: https://www.flaticon.com/ Cloud Convert: https://www.cloudconvert.com/
		Menu, Tray, Add,		% SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["Silent mode"], F_GuiAbout
		Menu, Tray, Default,	% SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["Silent mode"]
		Menu, Tray, Add										;separator line
		Menu, Tray, Add,		% TransA["Suspend Hotkeys"],			L_TraySuspendHotkeys
		Menu, Tray, Add,		% TransA["Pause application"],		L_TrayPauseScript
		Menu  Tray, Add,		% TransA["Exit application"],			L_TrayExit		
	Case "", "d":
		Menu, Tray, NoStandard									; remove all the rest of standard tray menu
		if (!FileExist(AppIcon))
		{
			MsgBox, 68, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["Information"], % TransA["The icon file"] . ":" . "`n`n" . AppIcon . "`n`n" . TransA["doesn't exist in application folder"] . "." 
				. A_Space . TransA["Would you like to download the icon file?"] . "`n`n" . TransA["If you answer ""Yes"", the icon file will be downloaded. If you answer ""No"", the default AutoHotkey icon will be used."]
			IfMsgBox, Yes
				URLDownloadToFile, https://raw.githubusercontent.com/mslonik/Hotstrings/master/Hotstrings/hotstrings.ico, % AppIcon
			IfMsgBox, No
				AppIcon := "*"
		}
		Menu, Tray, Icon,		% AppIcon 						;GUI window uses the tray icon that was in effect at the time the window was created. FlatIcon: https://www.flaticon.com/ Cloud Convert: https://www.cloudconvert.com/
		Menu, Tray, Add,		% SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["Default mode"], F_GuiAbout
		Menu, Tray, Add										;separator line
		Menu, Tray, Add, 		% TransA["Edit Hotstrings"], 			L_GUIInit
		Menu, Tray, Default, 	% TransA["Edit Hotstrings"]
		Menu, Tray, Add										;separator line
		Menu, Tray, Add,		% TransA["Help: Hotstrings application"],			GuiAboutLink1
		Menu, Tray, Add,		% TransA["Help: AutoHotkey Hotstrings reference guide"], GuiAboutLink2
		Menu, Tray, Add										;separator line
		Menu, SubmenuReload, 	Add,		% TransA["Reload in default mode"],	L_TrayReload
		Menu, SubmenuReload, 	Add,		% TransA["Reload in silent mode"],		L_TrayReload
		Menu, Tray, Add,		% TransA["Reload"],					:SubmenuReload
		Menu, Tray, Add,		% TransA["Suspend Hotkeys"],			L_TraySuspendHotkeys
		Menu, Tray, Add,		% TransA["Pause application"],		L_TrayPauseScript
		Menu  Tray, Add,		% TransA["Exit application"],			L_TrayExit
}

F_GuiMain_CreateObject()
F_GuiMain_DefineConstants()
F_GuiMain_DetermineConstraints()
F_GuiMain_Redraw()
F_GuiHS4_CreateObject()
F_GuiHS4_DetermineConstraints()
F_GuiHS4_Redraw()
F_GuiShowIntro()
F_UpdateSelHotLibDDL()

if (ini_HK_IntoEdit != "none")
{
	Hotkey, IfWinExist, % "ahk_id" HS3GuiHwnd
	Hotkey, % ini_HK_IntoEdit, F_PasteFromClipboard, On
	Hotkey, IfWinExist, % "ahk_id" HS4GuiHwnd
	Hotkey, % ini_HK_IntoEdit, F_PasteFromClipboard, On
	Hotkey, IfWinExist
}

; 4. Load definitions of (triggerstring, hotstring) from Library subfolder.
Gui, 1: Default	;this line is necessary to not show too many Guis on time of loading hotstrings from library
v_LibHotstringCnt := 0	;dirty trick to show initially 0 instead of 0000
GuiControl, , % IdText13,  % v_LibHotstringCnt
GuiControl, , % IdText13b, % v_LibHotstringCnt
F_LoadHotstringsFromLibraries()	;→ F_LoadFile()
F_Sort_a_Triggers()
F_GuiSearch_CreateObject()	;When all tables are full, initialize GuiSearch
F_GuiSearch_DetermineConstraints()
F_Searching("Reload")			;prepare content of Search tables
TrayTip, %A_ScriptName%, % TransA["Hotstrings have been loaded"], 1
Critical, Off

if (v_Param == "d") ;If the script is run with command line parameter "d" like debug, prepare new folder and create file named as specified in the following pattern.
{	
	FileCreateDir, Logs
	v_LogFileName := % "Logs\Logs" . A_DD . A_MM . "_" . A_Hour . A_Min . ".txt"
	FileAppend, , %v_LogFileName%, UTF-8
}
Loop, Files, %A_ScriptDir%\Languages\*.txt
	Menu, SubmenuLanguage, Add, %A_LoopFileName%, F_ChangeLanguage
F_ChangeLanguage()

Menu, StyleGUIsubm, Add, % TransA["Light (default)"],	F_StyleOfGUI
Menu, StyleGUIsubm, Add, % TransA["Dark"],			F_StyleOfGUI
F_StyleOfGUI()

Menu, ConfGUI,		Add, % TransA["Save position of application window"], 	F_SaveGUIPos
Menu, ConfGUI,		Add, % TransA["Change language"], 					:SubmenuLanguage
Menu, ConfGUI, 	Add	;To add a menu separator line, omit all three parameters.
Menu, ConfGUI, 	Add, % TransA["Show Sandbox (F6)"], 				F_ToggleSandbox
if (ini_Sandbox)
	Menu, ConfGUI, Check, % TransA["Show Sandbox (F6)"]
else
	Menu, ConfGUI, UnCheck, % TransA["Show Sandbox (F6)"]

Menu, ConfGUI,		Add, % TransA["Show full GUI (F4)"],				F_ToggleRightColumn
if (ini_WhichGui = "HS3")
	Menu, ConfGUI, Check, % TransA["Show full GUI (F4)"]
else
	Menu, ConfGUI, UnCheck, % TransA["Show full GUI (F4)"]

Menu, ConfGUI, 	Add	;To add a menu separator line, omit all three parameters.
Menu, ConfGUI,		Add, % TransA["Style of GUI"],								:StyleGUIsubm

F_CreateMenu_SizeOfMargin()

Menu, ConfGUI,		Add, 	% TransA["Size of margin:"] . A_Space . "x" . A_Space . TransA["pixels"],	:SizeOfMX
Menu, ConfGUI,		Add, 	% TransA["Size of margin:"] . A_Space . "y" . A_Space . TransA["pixels"],	:SizeOfMY

Menu, SizeOfFont,	Add,		8,									F_SizeOfFont
Menu, SizeOfFont,	Add,		9,									F_SizeOfFont
Menu, SizeOfFont,	Add,		10,									F_SizeOfFont
Menu, SizeOfFont,	Add,		11,									F_SizeOfFont
Menu, SizeOfFont,	Add,		12,									F_SizeOfFont
Menu, SizeOfFont, 	Check,	% c_FontSize
Menu, ConfGUI,		Add, 	% TransA["Size of font"],				:SizeOfFont

Menu, FontTypeMenu,	Add,		Arial,								F_FontType
Menu, FontTypeMenu,	Add,		Calibri,								F_FontType
Menu, FontTypeMenu,	Add,		Consolas,								F_FontType
Menu, FontTypeMenu,	Add,		Courier,								F_FontType
Menu, FontTypeMenu, Add,		Verdana,								F_FontType
Menu, FontTypeMenu, Check,	% c_FontType
Menu, ConfGUI,		Add, 	% TransA["Font type"],					:FontTypeMenu

Menu, TrigSortOrder, 	Add, % TransA["Alphabetically"], 				F_SortTipsAlphabetically
Menu, TrigSortOrder, 	Add, % TransA["By length"], 					F_SortTipsByLength

Menu, OrdHisTrig,		Add, % TransA["Tooltip enable"],				F_EventTtEn
Menu, OrdHisTrig,		Add, % TransA["Tooltip disable"],				F_EventTtEn
Menu, OrdHisTrig,		Add
Menu, OrdHisTrig,		Add, % TransA["Tooltip timeout"],				F_GuiSetTooltipTimeout
Menu, OrdHisTrig,		Add, % TransA["Tooltip position: caret"],		F_EventTtPos
Menu, OrdHisTrig,		Add, % TransA["Tooltip position: cursor"],		F_EventTtPos
Menu, OrdHisTrig,		Add
Menu, OrdHisTrig,		Add, % TransA["Sound enable"],				F_EventSoEn
Menu, OrdHisTrig,		Add, % TransA["Sound disable"],				F_EventSoEn
Menu, OrdHisTrig,		Add
Menu, OrdHisTrig,		Add, % TransA["Sound parameters"],				F_EventSoPar

Menu, MenuHisTrig,		Add, % TransA["Menu position: caret"],			F_EventTtPos
Menu, MenuHisTrig,		Add, % TransA["Menu position: cursor"],			F_EventTtPos
Menu, MenuHisTrig,		Add
Menu, MenuHisTrig,		Add, % TransA["Sound enable"],				F_EventSoEn
Menu, MenuHisTrig,		Add, % TransA["Sound disable"],				F_EventSoEn
Menu, MenuHisTrig,		Add
Menu, MenuHisTrig,		Add, % TransA["Sound parameters"],				F_EventSoPar

Menu, UndoOfH,			Add, % TransA["Tooltip enable"],				F_EventTtEn
Menu, UndoOfH,			Add, % TransA["Tooltip disable"],				F_EventTtEn
Menu, UndoOfH,			Add
Menu, UndoOfH,			Add, % TransA["Tooltip timeout"],				F_GuiSetTooltipTimeout
Menu, UndoOfH,			Add, % TransA["Tooltip position: caret"],		F_EventTtPos
Menu, UndoOfH,			Add, % TransA["Tooltip position: cursor"],		F_EventTtPos
Menu, UndoOfH,			Add
Menu, UndoOfH,			Add, % TransA["Sound enable"],				F_EventSoEn
Menu, UndoOfH,			Add, % TransA["Sound disable"],				F_EventSoEn
Menu, UndoOfH,			Add
Menu, UndoOfH,			Add, % TransA["Sound parameters"],				F_EventSoPar

Menu, TrigTips,		Add, % TransA["Tooltip enable"],				F_EventTtEn
Menu, TrigTips,		Add, % TransA["Tooltip disable"],				F_EventTtEn
Menu, TrigTips,		Add
Menu, TrigTips,		Add, % TransA["Tooltip timeout"],				F_GuiSetTooltipTimeout
Menu, TrigTips,		Add, % TransA["Tooltip position: caret"],		F_EventTtPos
Menu, TrigTips,		Add, % TransA["Tooltip position: cursor"],		F_EventTtPos
Menu, TrigTips,		Add
Menu, TrigTips,		Add, % TransA["Sorting order"],				:TrigSortOrder								
Menu, TrigTips,		Add,	% TransA["Max. no. of shown tips"],		F_GuiTrigShowNoOfTips

Menu, Submenu4, 		Add, 1, 									F_AmountOfCharacterTips
Menu, Submenu4, 		Add, 2, 									F_AmountOfCharacterTips
Menu, Submenu4, 		Add, 3, 									F_AmountOfCharacterTips
Menu, Submenu4, 		Add, 4, 									F_AmountOfCharacterTips
Menu, Submenu4, 		Add, 5, 									F_AmountOfCharacterTips
Menu, TrigTips, 		Add, % TransA["Tips are shown after no. of characters"],		:Submenu4		

Menu, SigOfEvents,		Add, % TransA["Basic hotstring is triggered"],	:OrdHisTrig
Menu, SigOfEvents,		Add, % TransA["Menu hotstring is triggered"],	:MenuHisTrig
Menu, SigOfEvents,		Add, % TransA["Undid the last hotstring"],		:UndoOfH
Menu, SigOfEvents,		Add, % TransA["Triggerstring tips"],			:TrigTips
Menu, SigOfEvents,		Add, % TransA["Triggerstring tips and hotstring menu styling"],		F_TTstyling

F_SortTipsByLength()
F_SortTipsAlphabetically()
F_EventTtEn()
F_EventSoEn()
F_EventTtPos()
F_AmountOfCharacterTips()

Menu, Submenu1Shortcuts, Add, % TransA["Call Graphical User Interface"],					F_GuiShortDef
Menu, Submenu1Shortcuts, Add, % TransA["Copy clipboard content into ""Enter hotstring"""],	F_GuiShortDef
Menu, Submenu1Shortcuts, Add, % TransA["Undo the last hotstring"],						F_GuiShortDef
Menu, Submenu1, 		Add, % TransA["Shortcut (hotkey) definitions"],					:Submenu1Shortcuts
Menu, Submenu1, 		Add
F_MUndo()
;Warning: order of SubmenuEndChars have to be alphabetical. Keep an eye on it. This is because after change of language specific menu items are related with associative array which also keeps to alphabetical order.
Menu, SubmenuEndChars, Add, % TransA["Apostrophe '"], 					F_ToggleEndChars
Menu, SubmenuEndChars, Add, % TransA["Backslash \"], 					F_ToggleEndChars
Menu, SubmenuEndChars, Add, % TransA["Closing Curly Bracket }"], 		F_ToggleEndChars
Menu, SubmenuEndChars, Add, % TransA["Closing Round Bracket )"],			F_ToggleEndChars
Menu, SubmenuEndChars, Add, % TransA["Closing Square Bracket ]"],		F_ToggleEndChars
Menu, SubmenuEndChars, Add, % TransA["Colon :"], 						F_ToggleEndChars
Menu, SubmenuEndChars, Add, % TransA["Comma ,"], 						F_ToggleEndChars
Menu, SubmenuEndChars, Add, % TransA["Dot ."], 						F_ToggleEndChars
Menu, SubmenuEndChars, Add, % TransA["Enter"],						F_ToggleEndChars
Menu, SubmenuEndChars, Add, % TransA["Exclamation Mark !"], 			F_ToggleEndChars
Menu, SubmenuEndChars, Add, % TransA["Minus -"], 						F_ToggleEndChars
Menu, SubmenuEndChars, Add, % TransA["Opening Curly Bracket {"], 		F_ToggleEndChars
Menu, SubmenuEndChars, Add, % TransA["Opening Round Bracket ("],			F_ToggleEndChars
Menu, SubmenuEndChars, Add, % TransA["Opening Square Bracket ["],		F_ToggleEndChars
Menu, SubmenuEndChars, Add, % TransA["Question Mark ?"], 				F_ToggleEndChars
Menu, SubmenuEndChars, Add, % TransA["Quote """], 					F_ToggleEndChars
Menu, SubmenuEndChars, Add, % TransA["Semicolon `;"], 					F_ToggleEndChars
Menu, SubmenuEndChars, Add, % TransA["Slash /"], 						F_ToggleEndChars
Menu, SubmenuEndChars, Add, % TransA["Space"],						F_ToggleEndChars
Menu, SubmenuEndChars, Add, % TransA["Tab"], 						F_ToggleEndChars
Menu, SubmenuEndChars, Add, % TransA["Underscore _"], 					F_ToggleEndChars
F_ToggleEndChars()

Menu, Submenu1,		Add, % TransA["Signaling of events"],			:SigOfEvents
Menu, Submenu1,		Add, Events,								F_GuiEvents
Menu, Submenu1,		Add, % TransA["Graphical User Interface"], 		:ConfGUI
Menu, Submenu1,		Add
Menu, Submenu1,  	   	Add, % TransA["Toggle EndChars"], 				:SubmenuEndChars
Menu, Submenu1,  	   	Add
Menu, Submenu1,	 	Add, % TransA["Restore default configuration"],	F_RestoreDefaultConfig

Menu, HSMenu, 			Add, % TransA["Configuration"], 				:Submenu1
Menu, HSMenu, 			Add, % TransA["Search Hotstrings (F3)"], 		F_Searching

Menu, LibrariesSubmenu,	Add, % TransA["Enable/disable libraries"], 		F_RefreshListOfLibraries
F_RefreshListOfLibraries()
Menu, LibrariesSubmenu, 	Add, % TransA["Enable/disable triggerstring tips"], 	F_RefreshListOfLibraryTips
F_RefreshListOfLibraryTips()
Menu, LibrariesSubmenu,	Add	;To add a menu separator line, omit all three parameters.
Menu, LibrariesSubmenu,	Add, % TransA["Visit public libraries webpage"],	L_PublicLibraries
Menu, LibrariesSubmenu,	Add, % TransA["Open libraries folder in Explorer"], L_OpenLibrariesFolderInExplorer
Menu, LibrariesSubmenu,	Add, % TransA["Download public libraries"],		F_DownloadPublicLibraries
Menu, LibrariesSubmenu,	Add	;To add a menu separator line, omit all three parameters.
Menu, LibrariesSubmenu, 	Add, % TransA["Import from .ahk to .csv"],		F_ImportLibrary
Menu, ExportSubmenu, 	Add, % TransA["Static hotstrings"],  			F_ExportLibraryStatic
Menu, ExportSubmenu, 	Add, % TransA["Dynamic hotstrings"],  			F_ExportLibraryDynamic
Menu, LibrariesSubmenu, 	Add, % TransA["Export from .csv to .ahk"],		:ExportSubmenu

Menu, 	HSMenu, 		Add, % TransA["Libraries"], 					:LibrariesSubmenu
Menu, 	HSMenu, 		Add, % TransA["Clipboard Delay (F7)"], 			F_GuiHSdelay

if (v_Param != "l")
	Menu, 	AppSubmenu, 	Add,	% TransA["Reload"],						:SubmenuReload
Menu,	AppSubmenu,	Add, % TransA["Suspend Hotkeys"],				L_TraySuspendHotkeys
Menu,	AppSubmenu,	Add, % TransA["Pause"],						L_TrayPauseScript
Menu,	AppSubmenu,	Add, % TransA["Exit"],						F_Exit
Menu,	AppSubmenu,	Add	;To add a menu separator line, omit all three parameters.
Menu,	AutoStartSub,	Add, % TransA["Default mode"],				F_AddToAutostart
Menu,	AutoStartSub,	Add,	% TransA["Silent mode"],					F_AddToAutostart
Menu,	AppSubmenu, 	Add, % TransA["Add to Autostart"],				:AutoStartSub

F_CompileSubmenu()

Menu, AppSubmenu,		Add, % TransA["Version / Update"],				F_GuiVersionUpdate

Menu,	AboutHelpSub,	Add,	% TransA["Help: Hotstrings application"],	GuiAboutLink1
Menu,	AboutHelpSub,	Add,	% TransA["Help: AutoHotkey Hotstrings reference guide"], GuiAboutLink2
Menu,	AboutHelpSub,	Add
Menu,	AboutHelpSub,	Add,	% TransA["About this application..."],		F_GuiAbout
Menu,	AboutHelpSub,	Add
Menu,	AboutHelpSub,	Add, % TransA["Show intro"],					L_ShowIntro

Menu, 	HSMenu,			Add, % TransA["Application"],				:AppSubmenu
Menu, 	HSMenu, 			Add, % TransA["About / Help"], 			:AboutHelpSub
Gui, 	HS3: Menu, HSMenu
Gui, 	HS4: Menu, HSMenu

F_GuiAbout_CreateObjects()
F_GuiVersionUpdate_CreateObjects()
F_GuiAbout_DetermineConstraints()
F_GuiVersionUpdate_DetermineConstraints()

if (ini_CheckRepo)
	F_VerUpdCheckServ("OnStartUp")
if (ini_DownloadRepo) and (F_VerUpdCheckServ("ReturnResult"))
	F_VerUpdDownload()

IniRead, ini_GuiReload, 					% HADConfig, GraphicalUserInterface, GuiReload,		% A_Space
if (ini_GuiReload = "")	;thanks to this trick existing Config.ini do not have to be erased if new configuration parameters are added.
{
	ini_GuiReload := false
	IniWrite, % ini_GuiReload, % HADConfig, GraphicalUserInterface, GuiReload
}
if (ini_GuiReload) and (FileExist(A_ScriptDir . "\" . "temp.exe"))	;flag ini_GuiReload is set also if Update function is run with Hostrings.exe. So after restart temp.exe is removed.
	FileDelete, % A_ScriptDir . "\" . "temp.exe"
if (ini_GuiReload) and (v_Param != "l")
	Gosub, L_GUIInit

;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; The main application loop beginning .
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Loop,
{
	Input, out, V L1, {Esc} ; V = Visible, L1 = Length 1
	if (ErrorLevel = "NewInput")
		MsgBox, 16, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["Error"], % TransA["ErrorLevel was triggered by NewInput error."]
	
	;OutputDebug, % "out" . ":" . A_Space . Ord(out) . A_Space . out
	;OutputDebug, % "After:" . A_Space . v_InputString
	if (v_HotstringFlag)	;v_HotstringFlag = 1, triggerstring was fired = hotstring was shown
	{
		v_InputString := ""
		out := ""
		Gui, TMenuAHK: Destroy
		;ToolTip,	;Triggerstring Tips tooltip
		v_HotstringFlag := false
	}
	else
	{
		v_InputString .= out
		ToolTip, ,, , 4	;Basic triggerstring was triggered
		ToolTip, ,, , 6	;Undid the last hotstring
		;OutputDebug, % "Before F_PrepareTriggerstringTipsTables:" . A_Space . v_InputString
		;F_PrepareTriggerstringTipsTables()		
		F_PrepareTriggerstringTipsTables2()		
		;F_ShowTriggerstringTips()
		if (a_Tips.Count())
			F_ShowTriggerstringTips2()
		else
			Gui, TMenuAHK: Destroy
	}
	
	if (out and InStr(HotstringEndChars, out))	;if input contains EndChars set v_TipsFlag, if not, reset v_InputString. If "out" is empty, InStr returns true.
	{
		v_TipsFlag := false
		Loop, % a_Triggers.MaxIndex()
		{
			if (InStr(a_Triggers[A_Index], v_InputString) = 1) ;if in string a_Triggers is found v_InputString from the first position 
			{
				v_TipsFlag := true
				Break
			}
		}
		if !(v_TipsFlag)
			v_InputString := ""
	}		  
	if (v_Param == "d")
	{
		FileAppend, % v_IndexLog . "|" . v_InputString . "|" . ini_TASAC . "|" . ini_TTTtEn . "|" . v_Tips . "`n- - - - - - - - - - - - - - - - - - - - - - - - - -`n", %v_LogFileName%
		v_IndexLog++
	}
}
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; The end of the main loop of application.
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -



; -------------------------- SECTION OF HOTKEYS ---------------------------
#InputLevel 2	;Thanks to this line triggerstring tips will have lower priority; backspacing done in function F_TMenu() will not affect this label.
~BackSpace:: 
if (WinExist("ahk_id" HMenuCliHwnd) or WinExist("ahk_id" HMenuAHKHwnd))
{
	if (ini_MHSEn)
		SoundBeep, % ini_MHSF, % ini_MHSD
}
else
{
	v_InputString := SubStr(v_InputString, 1, -1)
	F_PrepareTriggerstringTipsTables2()
	if (a_Tips.Count())
		F_ShowTriggerstringTips2()
	
	if (v_Param == "d")
	{
		FileAppend, % v_IndexLog . "|" . v_InputString . "|" . ini_TASAC . "|" . ini_TTTtEn . "|" . v_Tips . "`n- - - - - - - - - - - - - - - - - - - - - - - - - -`n", %v_LogFileName%
		v_IndexLog++
	}
}
return
#InputLevel 2
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;#if WinExist("ahk_id" HS3GuiHwnd) or WinExist("ahk_id" HS4GuiHwnd) ; the following hotkeys will be active only if Hotstrings windows exist at the moment.
;~^c::			; copy to edit field "Enter hotstring" content of Clipboard. 
F_PasteFromClipboard()
{
	global	;assume-global mode
	local	ContentOfClipboard := ""
	
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
	F_WhichGui()
	Gui, % A_DefaultGui . ":" . A_Space . "Show"
	return
}
;#if

#if WinActive("ahk_id" HS3GuiHwnd) or WinActive("ahk_id" HS4GuiHwnd) ; the following hotkeys will be active only if Hotstrings windows are active at the moment. 

F1::	;new thread starts here
	Goto, GuiAboutLink1

F2:: ;new thread starts here
F_WhichGui()
if (A_DefaultGui = "HS4")
	return
if (A_DefaultGui = "HS3")
{
	Gui, HS3: Submit, NoHide
	if (!v_SelectHotstringLibrary) or (v_SelectHotstringLibrary = TransA["↓ Click here to select hotstring library ↓"])
	{
		MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["In order to display library content please at first select hotstring library"] . "."
		return
	}
	GuiControl, Focus, v_LibraryContent
	if (LV_GetNext(0,"Focused") == 0)
		LV_Modify(1, "+Select +Focus")
	return
}

^f::
^s::
F3:: ;new thread starts here
	F_Searching()
return

F4::	;new thread starts here
	F_WhichGui()
	F_ToggleRightColumn()
return

F5::	;new thread starts here
	F_WhichGui()
	F_Clear()
return

F6::	;new thread starts here
	F_WhichGui()
	F_ToggleSandbox()
return

F7:: ;new thread starts here
	F_WhichGui()
	F_GuiHSdelay()
return

F8::	;new thread starts here
	F_WhichGui()
	if (A_DefaultGui = "HS4")
		return
	if (A_DefaultGui = "HS3")
		F_DeleteHotstring()
return

F9::	;new thread starts here
	F_WhichGui()
	F_AddHotstring()
return

F11::	;for debugging purposes, internal shortcut
	SetTimer, TurnOff_UHE, Off
	SetTimer, TurnOff_OHE, Off
	SetTimer, TurnOff_Ttt, Off
return

#if

~Alt::
;Comment-out the following 3x lines (mouse buttons) in case of debugging the main loop of application.
~MButton::
~RButton::
~LButton::
~LWin::
~RWin::
~Down::
~Up::
~Left::
~Right::
~PgDn::
~PgUp::
~Home::
~End::
~Esc::
ToolTip,	;this line is necessary to close tooltips.
Gui, TMenuAHK: Destroy
ToolTip, ,, , 4
ToolTip, ,, , 6
;OutputDebug, % "v_InputString before" . ":" . A_Space . v_InputString
v_InputString := ""
;OutputDebug, % "v_InputString after" . ":" . A_Space . v_InputString
return

#if WinActive("ahk_id" HS3SearchHwnd)
F8:: ;new thread starts here
Gui, HS3Search: Default
F_MoveList()
#if

#if WinExist("AHK_id" TMenuAHKHwnd)
#InputLevel 1	;This trick enables back triggering of existing (triggerstring, hotstring) definitions; it rises up priority of calling existing triggerstrings
Tab::
+Tab::
Up::
Down::
+Enter::
^Enter::
F_TMenu()
{
	global	;assume-global moee
	local	v_PressedKey := "",		v_Temp1 := "",		ClipboardBack := ""
	static 	IfUpF := false,	IfDownF := false, IsCursorPressed := false, IntCnt := 1, v_MenuMax := 0, ShiftTabIsFound := false
	
	v_MenuMax := a_Tips.Count()
	v_PressedKey := A_ThisHotkey
	if (InStr(v_PressedKey, "+Tab"))	;the same as "up"
	{
		IsCursorPressed := true
		IntCnt--
		ControlSend, , {Up}, % "ahk_id" Id_LB_TMenuAHK
		ShiftTabIsFound := true
	}
	if (InStr(v_PressedKey, "Tab")) and (!ShiftTabIsFound)	;the same as "down"
	{
		IsCursorPressed := true
		IntCnt++
		ControlSend, , {Down}, % "ahk_id" Id_LB_TMenuAHK
	}
	if (InStr(v_PressedKey, "Up"))
	{
		IsCursorPressed := true
		IntCnt--
		ControlSend, , {Up}, % "ahk_id" Id_LB_TMenuAHK
	}
	if (InStr(v_PressedKey, "Down"))
	{
		IsCursorPressed := true
		IntCnt++
		ControlSend, , {Down}, % "ahk_id" Id_LB_TMenuAHK
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
	if (InStr(v_PressedKey, "+Enter") or InStr(v_PressedKey, "^Enter"))
	{
		v_PressedKey := IntCnt
		IsCursorPressed := false
		IntCnt := 1
	}
	if (v_PressedKey > v_MenuMax)
		return
	ControlGet, v_Temp1, List, , , % "ahk_id" Id_LB_TMenuAHK
	;OutputDebug, % "v_Temp1" . A_Tab . v_Temp1 . A_Tab . A_Tab . "v_PressedKey" . A_Tab . v_PressedKey
	Loop, Parse, v_Temp1, `n
	{
		if (A_Index = v_PressedKey)
			v_Temp1 := SubStr(A_LoopField, InStr(A_LoopField, " ") + 1)
	}
	SendInput, % "{BackSpace" . A_Space . StrLen(v_InputString) . "}"
	Hotstring("Reset")
	SendInput, % v_Temp1
	Gui, TMenuAHK: Destroy
	return
}
#InputLevel 0
	
#if

#if WinExist("ahk_id" HMenuCliHwnd)
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

F_HMenuCli()
{
	global	;assume-global moee
	local	v_PressedKey := "",		v_Temp1 := "",		ClipboardBack := ""
	static 	IfUpF := false,	IfDownF := false, IsCursorPressed := false, IntCnt := 1, ShiftTabIsFound := false
	
	v_PressedKey := A_ThisHotkey
	if (InStr(v_PressedKey, "+Tab"))	;the same as "up"
	{
		IsCursorPressed := true
		IntCnt--
		ControlSend, , {Up}, % "ahk_id" Id_LB_TMenuAHK
		ShiftTabIsFound := true
	}
	if (InStr(v_PressedKey, "Tab")) and (!ShiftTabIsFound)	;the same as "down"
	{
		IsCursorPressed := true
		IntCnt++
		ControlSend, , {Down}, % "ahk_id" Id_LB_TMenuAHK
	}
	if (InStr(v_PressedKey, "Up"))
	{
		IsCursorPressed := true
		IntCnt--
		ControlSend, , {Up}, % "ahk_id" Id_LB_HMenuCli
	}
	if (InStr(v_PressedKey, "Down"))
	{
		IsCursorPressed := true
		IntCnt++
		ControlSend, , {Down}, % "ahk_id" Id_LB_HMenuCli
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
	
	if (InStr(v_PressedKey, "Enter"))
	{
		v_PressedKey := IntCnt
		IsCursorPressed := false
		IntCnt := 1
	}
	if (v_PressedKey > v_MenuMax)
	{
		return
	}
	ClipboardBack := ClipboardAll ;backup clipboard
	ControlGet, v_Temp1, List, , , % "ahk_id" Id_LB_HMenuCli
	Loop, Parse, v_Temp1, `n
	{
		if (A_Index = v_PressedKey)
			v_Temp1 := SubStr(A_LoopField, 4)
	}
	Clipboard := v_Temp1
	Send, ^v ;paste the text
	if (Ovar = false)
		Send, % A_EndChar
	if (ini_MHSEn)
		SoundBeep, % ini_MHSF, % ini_MHSD	
	
	Sleep, %ini_CPDelay% ;Remember to sleep before restoring clipboard or it will fail
	Clipboard 		 := ClipboardBack
	v_UndoHotstring 	 := v_Temp1
	Hotstring("Reset")
	v_HotstringFlag := true
	Gui, HMenuCli: Destroy
	F_EventSigOrdHotstring()
	return
}

Esc::
	Gui, HMenuCli: Destroy
	Send, % SubStr(v_TypedTriggerstring, InStr(v_TypedTriggerstring, ":", false, 1, 2) + 1) 
	v_InputString := ""	;I'm not sure if this line is necessary anymore.
	v_HotstringFlag := true
return
#If

; ------------------------- SECTION OF FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------------------
F_LoadConfiguration()
{
	global ;assume-global mode
	ini_CPDelay 				:= 300		;1-1000 [ms], default: 300
	IniRead, ini_CPDelay, 					% HADConfig, Configuration, ClipBoardPasteDelay,		% A_Space
	if (ini_CPDelay = "")	;thanks to this trick existing Config.ini do not have to be erased if new configuration parameters are added.
	{
		ini_CPDelay := 300
		IniWrite, % ini_CPDelay, % HADConfig, Configuration, ClipBoardPasteDelay 
	}
	ini_HotstringUndo			:= true
	IniRead, ini_HotstringUndo,				% HADConfig, Configuration, HotstringUndo,			% A_Space
	if (ini_HotstringUndo = "")	;thanks to this trick existing Config.ini do not have to be erased if new configuration parameters are added.
	{
		ini_HotstringUndo := true
		Iniwrite, % ini_HotstringUndo, % HADConfig, Configuration, HotstringUndo
	}
	ini_ShowIntro			:= true
	IniRead, ini_ShowIntro,					% HADConfig, Configuration, ShowIntro,				% A_Space	;GUI with introduction to Hotstrings application.
	if (ini_ShowIntro = "")	;thanks to this trick existing Config.ini do not have to be erased if new configuration parameters are added.
	{
		ini_ShowIntro := true
		Iniwrite, % ini_ShowIntro, % HADConfig, Configuration, ShowIntro
	}
	ini_CheckRepo			:= false
	IniRead, ini_CheckRepo,					% HADConfig, Configuration, CheckRepo,				% A_Space
	if (ini_CheckRepo = "")	;thanks to this trick existing Config.ini do not have to be erased if new configuration parameters are added.
	{
		ini_CheckRepo := false
		IniWrite, % ini_CheckRepo, % HADConfig, Configuration, CheckRepo
	}
	ini_DownloadRepo			:= false
	IniRead, ini_DownloadRepo,				% HADConfig, Configuration, DownloadRepo,			% A_Space
	if (ini_DownloadRepo = "") ;thanks to this trick existing Config.ini do not have to be erased if new configuration parameters are added.
	{
		ini_DownloadRepo := false
		IniWrite, % ini_DownloadRepo, % HADConfig, Configuration, DownloadRepo
	}
	ini_HK_Main				:= "#^h"
	IniRead, ini_HK_Main,					% HADConfig, Configuration, HK_Main,				% A_Space
	if (ini_HK_Main = "")	;thanks to this trick existing Config.ini do not have to be erased if new configuration parameters are added.
	{
		ini_HK_Main := "#^h"
		IniWrite, % ini_HK_Main, % HADConfig, Configuration, HK_Main
	}
	if (ini_HK_Main != "none")
		Hotkey, % ini_HK_Main, L_GUIInit, On
	
	ini_HK_IntoEdit			:= "~^c"
	IniRead, ini_HK_IntoEdit,				% HADConfig, Configuration, HK_IntoEdit,			% A_Space
	if (ini_HK_IntoEdit = "")	;thanks to this trick existing Config.ini do not have to be erased if new configuration parameters are added.
	{
		ini_HK_IntoEdit := "~^c"
		IniWrite, % ini_HK_IntoEdit, % HADConfig, Configuration, HK_IntoEdit
	}
	
	ini_HK_UndoLH			:= "~^F12"
	IniRead, ini_HK_UndoLH,					% HADConfig, Configuration, HK_UndoLH,				% A_Space
	if (ini_HK_UndoLH = "")		;thanks to this trick existing Config.ini do not have to be erased if new configuration parameters are added.
	{
		ini_HK_UndoLH := "^F12"
		Iniwrite, % ini_HK_UndoLH, % HADConfig, Configuration, HK_UndoLH
	}
	if (ini_HK_UndoLH != "none")
		Hotkey, % ini_HK_UndoLH, F_Undo, On
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_GuiEvents()
{
	global ;assume-global mode
	local FoundPos := "", Window1X := 0, Window1Y := 0, Window1W := 0, Window1H := 0, Window2X := 0, Window2Y := 0, Window2W := 0, Window2H := 0, NewWinPosX := 0, NewWinPosY := 0
	
	F_GuiEvents_InitiateValues()	;initial values 
	F_GuiEvents_CreateObjects()
	F_GuiEvents_DetermineConstraints()
	F_GuiEvents_LoadValues()	;load values to guicontrols
	F_EvBH_R1R2()
	F_EvBH_R3R4()
	F_EvBH_R7R8()
	F_EvMH_R3R4()
	F_EvUH_R1R2()
	F_EvUH_R3R4()
	F_EvUH_R7R8()
	
	if (WinExist("ahk_id" . HS3GuiHwnd) or WinExist("ahk_id" . HS4GuiHwnd))
		WinGetPos, Window1X, Window1Y, Window1W, Window1H, A
	Gui, GuiEvents: Show, Hide Center AutoSize
	
	DetectHiddenWindows, On
	WinGetPos, Window2X, Window2Y, Window2W, Window2H, % "ahk_id" . GuiEventsHwnd
	DetectHiddenWindows, Off
	if (Window1W)
	{
		NewWinPosX := Round(Window1X + (Window1W / 2) - (Window2W / 2))
		NewWinPosY := Round(Window1Y + (Window1H / 2) - (Window2H / 2))
		Gui, GuiEvents: Show, % "AutoSize" . A_Space . "x" . NewWinPosX . A_Space . "y" . NewWinPosY, % A_ScriptName . ":" . A_Space . "Events configuration"
	}
	else
	{
		if (v_Param = "l")
			Gui, GuiEvents: Show, Center AutoSize, % A_ScriptName . ":" . A_Space . "Events configuration"
		else
			Gui, GuiEvents: Show, Center AutoSize, % A_ScriptName . ":" . A_Space . "Events configuration"
	}
	return  
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
	
	;2. Prepare all text objects according to mock-up.
	Gui,	GuiEvents: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, 			% c_FontType
	Gui, GuiEvents: Add,	Tab3,		,							% TransA["Basic hotstring is triggered"] . "||" . TransA["Menu hotstring is triggered"] . "|" . TransA["Undid the last hotstring"] . "|" . TransA["Triggerstring tips"]
	
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
	Gui, GuiEvents: Add, 	Slider, 	HwndIdEvBH_S1 vEvBH_S1 gF_EvBH_S1 Line1 Page500 Range1000-10000 TickInterval500 ToolTipBottom Buddy1EvBH_S1, % EvBH_S1
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
	Gui, GuiEvents: Add, 	Slider, 	HwndIdEvBH_S2 vEvBH_S2 gF_EvBH_S2 Line1 Page50 Range37-32767 TickInterval%TickInterval% ToolTipBottom Buddy1EvBH_S2, % EvBH_S2
	Gui, GuiEvents: Add, 	Text, 	HwndIdEvBH_T13, 					% TransA["Sound frequency"] . ":" . A_Space . "32768"
	Gui, GuiEvents: Add, 	Slider, 	HwndIdEvBH_S3 vEvBH_S3 gF_EvBH_S3 Line1 Page50 Range50-2000 TickInterval50 ToolTipBottom Buddy1EvBH_S3, % EvBH_S3
	Gui, GuiEvents: Add, 	Text, 	HwndIdEvBH_T14, 					% TransA["Sound duration [ms]"] . ":" . A_Space . "2000"
	Gui, GuiEvents: Add, 	Button, 	HwndIdEvBH_B1 gF_EvBH_B1,			% TransA["Tooltip test"]
	Gui, GuiEvents: Add, 	Button, 	HwndIdEvBH_B2 gF_EvBH_B2,			% TransA["Sound test"]
	Gui, GuiEvents: Add,	Button,	HwndIdEvBH_B3 gF_EvBH_B3,			% TransA["Apply && Close"]
	Gui, GuiEvents: Add,	Button,	HwndIdEvBH_B4 gF_EvBH_B4,			% TransA["Cancel"]
	
	Gui, GuiEvents: Tab, 											% TransA["Menu hotstring is triggered"]
	Gui, GuiEvents: Font,	% "s" . c_FontSize . A_Space . "bold" . A_Space . "c" . c_FontColor, % c_FontType
	Gui, GuiEvents: Add,	Text,	HwndIdEvMH_T1,						% TransA["Menu position"] . ":"
	Gui, GuiEvents: Font,	% "s" . c_FontSize + 2 . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, GuiEvents: Add,	Text,	HwndIdEvMH_T2,						ⓘ
	T_MenuPosition := func("F_ShowLongTooltip").bind(TransA["T_MenuPosition"])
	GuiControl, +g, % IdEvMH_T2, % T_MenuPosition
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
	Gui, GuiEvents: Add, 	Slider, 	HwndIdEvMH_S1 vEvMH_S1 gF_EvMH_S1 Line1 Page50 Range37-32767 TickInterval%TickInterval% ToolTipBottom Buddy1EvMH_S1, % EvMH_S1
	Gui, GuiEvents: Add, 	Text, 	HwndIdEvMH_T7, 					% TransA["Sound frequency"] . ":" . A_Space . "32768"
	Gui, GuiEvents: Add, 	Slider, 	HwndIdEvMH_S2 vEvMH_S2 gF_EvMH_S2 Line1 Page50 Range50-2000 TickInterval50 ToolTipBottom Buddy1EvMH_S2, % EvMH_S2
	Gui, GuiEvents: Add, 	Text, 	HwndIdEvMH_T8, 					% TransA["Sound duration [ms]"] . ":" . A_Space . "2000"
	Gui, GuiEvents: Add, 	Button, 	HwndIdEvMH_B1 gF_EvMH_B1,			% TransA["Sound test"]
	Gui, GuiEvents: Add,	Button,	HwndIdEvMH_B2 gF_EvMH_B2,			% TransA["Apply && Close"]
	Gui, GuiEvents: Add,	Button,	HwndIdEvMH_B3 gF_EvMH_B3,			% TransA["Cancel"]
	
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
	Gui, GuiEvents: Add, 	Slider, 	HwndIdEvUH_S1 vEvUH_S1 gF_EvUH_S1 Line1 Page500 Range1000-10000 TickInterval500 ToolTipBottom Buddy1EvUH_S1, % EvUH_S1
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
	Gui, GuiEvents: Add, 	Slider, 	HwndIdEvUH_S2 vEvUH_S2 gF_EvUH_S2 Line1 Page50 Range37-32767 TickInterval%TickInterval% ToolTipBottom Buddy1EvUH_S2, % EvUH_S2
	Gui, GuiEvents: Add, 	Text, 	HwndIdEvUH_T13, 					% TransA["Sound frequency"] . ":" . A_Space . "32768"
	Gui, GuiEvents: Add, 	Slider, 	HwndIdEvUH_S3 vEvUH_S3 gF_EvUH_S3 Line1 Page50 Range50-2000 TickInterval50 ToolTipBottom Buddy1EvUH_S3, % EvUH_S3
	Gui, GuiEvents: Add, 	Text, 	HwndIdEvUH_T14, 					% TransA["Sound duration [ms]"] . ":" . A_Space . "2000"
	Gui, GuiEvents: Add, 	Button, 	HwndIdEvUH_B1 gF_EvUH_B1,			% TransA["Tooltip test"]
	Gui, GuiEvents: Add, 	Button, 	HwndIdEvUH_B2 gF_EvUH_B2,			% TransA["Sound test"]
	Gui, GuiEvents: Add,	Button,	HwndIdEvUH_B3 gF_EvUH_B3,			% TransA["Apply && Close"]
	Gui, GuiEvents: Add,	Button,	HwndIdEvUH_B4 gF_EvUH_B4,			% TransA["Cancel"]
	return
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
				ToolTip, % TransA["Undid the last hotstring"], % A_CaretX + 20, % A_CaretY - 20, 6
				if (ini_UHTD > 0)
					SetTimer, TurnOff_UHE, % "-" . ini_UHTD, 60 ;Priority = 60 to avoid conflicts with other threads 
			}
			else
			{
				MouseGetPos, v_MouseX, v_MouseY
				ToolTip, % TransA["Undid the last hotstring"], % v_MouseX + 20, % v_MouseY - 20, 6
				if (ini_UHTD > 0)
					SetTimer, TurnOff_UHE, % "-" . ini_UHTD, 60 ;Priority = 60 to avoid conflicts with other threads 
			}
		}
	}
	if (EvUH_R5R6 = 2)
	{
		MouseGetPos, v_MouseX, v_MouseY
		ToolTip, % TransA["Undid the last hotstring"], % v_MouseX + 20, % v_MouseY - 20, 6
		if (ini_UHTD > 0)
			SetTimer, TurnOff_UHE, % "-" . ini_UHTD, 60 ;Priority = 60 to avoid conflicts with other threads 
	}
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EvUH_B2()	;Event Undo Hotstring (is triggered) Button Sound test
{
	global ;assume-global mode
	SoundBeep, % EvUH_S2, % EvUH_S3
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EvUH_B3()	;Event Undo Hotstring (is triggered) Button Apply & Close
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
	IniWrite, % ini_UHTtEn, 	% HADConfig, Event_UndoHotstring, 	UHTtEn
	IniWrite, % ini_UHTD,	% HADConfig, Event_UndoHotstring,	UHTD
	IniWrite, % ini_UHTP,	% HADConfig, Event_UndoHotstring,	UHTP
	IniWrite, % ini_UHSEn, 	% HADConfig, Event_UndoHotstring,	UHSEn
	IniWrite, % ini_UHSF,	% HADConfig, Event_UndoHotstring,	UHSF
	IniWrite, % ini_UHSD,	% HADConfig, Event_UndoHotstring,	UHSD
	Tooltip,,,, 4
	Gui, GuiEvents: Destroy
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EvUH_B4()	;Event Undo Hotstring (is triggered) Button Cancel
{
	global ;assume-global mode
	Tooltip,,,, 4
	Gui, GuiEvents: Destroy
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EvUH_S3()
{
	global ;assume-global mode
	GuiControl,, % IdEvUH_T14, % TransA["Sound duration [ms]"] . ":" . A_Space . EvUH_S3
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EvUH_S2()
{
	global ;assume-global mode
	GuiControl,, % IdEvUH_T13, % TransA["Sound frequency"] . ":" . A_Space . EvUH_S2
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EvUH_S1()
{
	global ;assume-global mode
	GuiControl,, % IdEvUH_T7, % TransA["Timeout value [ms]"] . ":" . A_Space . EvUH_S1
	return
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
		Case 2:
			GuiControl, Disable,	% IdEvUH_T6
			GuiControl, Disable,	% IdEvUH_S1
			GuiControl, Disable,	% IdEvUH_T7
	}
	return
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
	return
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
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EvMH_B3()	;Menu Hotstring (is triggered) Button Cancel
{
	global ;assume-global mode
	Tooltip,,,, 4
	Gui, GuiEvents: Destroy
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EvMH_B2()	;Apply & Close
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
	IniWrite, % ini_MHMP,	% HADConfig, Event_MenuHotstring,		MHMP
	IniWrite, % ini_MHSEn, 	% HADConfig, Event_MenuHotstring,		MHSEn
	IniWrite, % ini_MHSF,	% HADConfig, Event_MenuHotstring,		MHSF
	IniWrite, % ini_MHSD,	% HADConfig, Event_MenuHotstring,		MHSD
	Tooltip,,,, 4
	Gui, GuiEvents: Destroy
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EvMH_B1()	;Sound test
{
	global ;assume-global mode
	SoundBeep, % EvMH_S1, % EvMH_S2
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EvMH_S2()	;Sound duration
{
	global ;assume-global mode
	GuiControl,, % IdEvMH_T8, % TransA["Sound duration [ms]"] . ":" . A_Space . EvMH_S2
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EvMH_S1()	;Sound frequency
{
	global ;assume-global mode
	GuiControl,, % IdEvMH_T7, % TransA["Sound frequency"] . ":" . A_Space . EvMH_S1
	return
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
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_GuiEvents_DetermineConstraints()
{
	global ;assume-global mode
	local v_OutVarTemp := 0, 	v_OutVarTempX := 0, 	v_OutVarTempY := 0, 	v_OutVarTempW := 0, 	v_OutVarTempH := 0, v_OutVarTemp1 := 0, 	v_OutVarTemp1X := 0, 	v_OutVarTemp1Y := 0, 	v_OutVarTemp1W := 0, 	v_OutVarTemp1H := 0, v_OutVarTemp2 := 0, 	v_OutVarTemp2X := 0, 	v_OutVarTemp2Y := 0, 	v_OutVarTemp2W := 0, 	v_OutVarTemp2H := 0,v_OutVarTemp3 := 0, 	v_OutVarTemp3X := 0, 	v_OutVarTemp3Y := 0, 	v_OutVarTemp3W := 0, 	v_OutVarTemp3H := 0, v_OutVarTemp4 := 0, 	v_OutVarTemp4X := 0, 	v_OutVarTemp4Y := 0, 	v_OutVarTemp4W := 0, 	v_OutVarTemp4H := 0, v_xNext := 0, 		v_yNext := 0, 			v_wNext := 0, 			v_hNext := 0, TheWidestText := 0, TotalWidth := 0
	
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
	v_xNext := c_xmarg, v_yNext += HofText
	GuiControl, Move, % IdEvBH_R1, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvBH_R1
	v_xNext += v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvBH_R2, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += 3 * HofText
	GuiControl, Move, % IdEvBH_T15, % "x+" . v_xNext . A_Space . "y+" . v_yNext - 2 . A_Space . "w+" . TotalWidth . A_Space . "h+" . 1
	GuiControl, Move, % IdEvBH_T3, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvBH_T3
	v_xNext += v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvBH_T4, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += HofText
	GuiControl, Move, % IdEvBH_T5, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += HofText
	GuiControl, Move, % IdEvBH_R3, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvBH_R3
	v_xNext += v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvBH_R4, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += HofText
	GuiControl, Move, % IdEvBH_T6, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += HofText, v_wNext := TheWidestText
	GuiControl, Move, % IdEvBH_S1, % "x+" . v_xNext . A_Space . "y+" . v_yNext . A_Space . "w+" . v_wNext
	v_xNext += 2 * c_xmarg + TheWidestText
	GuiControl, Move, % IdEvBH_T7, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += 3 * HofText
	GuiControl, Move, % IdEvBH_T16, % "x+" . v_xNext . A_Space . "y+" . v_yNext - 2 . A_Space . "w+" . TotalWidth . A_Space . "h+" . 1
	GuiControl, Move, % IdEvBH_T8, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvBH_T8
	v_xNext += v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvBH_T9, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += HofText
	GuiControl, Move, % IdEvBH_R5, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvBH_R5
	v_xNext += v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvBH_R6, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += 3 * HofText
	GuiControl, Move, % IdEvBH_T17, % "x+" . v_xNext . A_Space . "y+" . v_yNext - 2 . A_Space . "w+" . TotalWidth . A_Space . "h+" . 1
	GuiControl, Move, % IdEvBH_T10, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvBH_T10
	v_xNext += v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvBH_T11, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += HofText
	GuiControl, Move, % IdEvBH_R7, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvBH_R7
	v_xNext += v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvBH_R8, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += HofText
	GuiControl, Move, % IdEvBH_T12, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_yNext += HofText
	GuiControl, Move, % IdEvBH_S2, % "x+" . v_xNext . A_Space . "y+" . v_yNext . A_Space . "w+" . v_wNext
	v_xNext += 2 * c_xmarg + TheWidestText
	GuiControl, Move, % IdEvBH_T13, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg
	GuiControlGet, v_OutVarTemp, Pos, % IdEvBH_S2
	v_yNext += v_OutVarTempH
	GuiControl, Move, % IdEvBH_S3, % "x+" . v_xNext . A_Space . "y+" . v_yNext . A_Space . "w+" . v_wNext	
	v_xNext += 2 * c_xmarg + TheWidestText
	GuiControl, Move, % IdEvBH_T14, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += 3 * HofText
	GuiControl, Move, % IdEvBH_B1, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvBH_B1
	v_xNext += v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvBH_B2, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvBH_B2
	v_xNext := v_OutVarTempX + v_OutVarTempW + 4 * c_xmarg
	GuiControl, Move, % IdEvBH_B3, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvBH_B3
	v_xNext := v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvBH_B4, % "x+" . v_xNext . A_Space . "y+" . v_yNext

	v_xNext := c_xmarg, v_yNext := c_ymarg
	GuiControl, Move, % IdEvMH_T1, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvMH_T1
	v_xNext += v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvMH_T2, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += HofText
	GuiControl, Move, % IdEvMH_R1, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvMH_R1
	v_xNext += v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvMH_R2, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += 3 * HofText
	GuiControl, Move, % IdEvMH_T3, % "x+" . v_xNext . A_Space . "y+" . v_yNext - 2 . A_Space . "w+" . TotalWidth . A_Space . "h+" . 1
	GuiControl, Move, % IdEvMH_T4, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvMH_T4
	v_xNext += v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvMH_T5, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += HofText
	GuiControl, Move, % IdEvMH_R3, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvMH_R3
	v_xNext += v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvMH_R4, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += HofText
	GuiControl, Move, % IdEvMH_T6, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_yNext += HofText
	GuiControl, Move, % IdEvMH_S1, % "x+" . v_xNext . A_Space . "y+" . v_yNext . A_Space . "w+" . v_wNext
	v_xNext += 2 * c_xmarg + TheWidestText
	GuiControl, Move, % IdEvMH_T7, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg
	GuiControlGet, v_OutVarTemp, Pos, % IdEvMH_S1
	v_yNext += v_OutVarTempH
	GuiControl, Move, % IdEvMH_S2, % "x+" . v_xNext . A_Space . "y+" . v_yNext . A_Space . "w+" . v_wNext	
	v_xNext += 2 * c_xmarg + TheWidestText
	GuiControl, Move, % IdEvMH_T8, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += 3 * HofText
	GuiControl, Move, % IdEvMH_B1, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvMH_B1
	v_xNext += v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvMH_B2, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvMH_B2
	v_xNext := v_OutVarTempX + v_OutVarTempW + 4 * c_xmarg
	GuiControl, Move, % IdEvMH_B3, % "x+" . v_xNext . A_Space . "y+" . v_yNext

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
	v_xNext := c_xmarg, v_yNext += HofText
	GuiControl, Move, % IdEvUH_R1, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvUH_R1
	v_xNext += v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvUH_R2, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += 3 * HofText
	GuiControl, Move, % IdEvUH_T15, % "x+" . v_xNext . A_Space . "y+" . v_yNext - 2 . A_Space . "w+" . TotalWidth . A_Space . "h+" . 1
	GuiControl, Move, % IdEvUH_T3, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvUH_T3
	v_xNext += v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvUH_T4, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += HofText
	GuiControl, Move, % IdEvUH_T5, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += HofText
	GuiControl, Move, % IdEvUH_R3, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvUH_R3
	v_xNext += v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvUH_R4, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += HofText
	GuiControl, Move, % IdEvUH_T6, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += HofText, v_wNext := TheWidestText
	GuiControl, Move, % IdEvUH_S1, % "x+" . v_xNext . A_Space . "y+" . v_yNext . A_Space . "w+" . v_wNext
	v_xNext += 2 * c_xmarg + TheWidestText
	GuiControl, Move, % IdEvUH_T7, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += 3 * HofText
	GuiControl, Move, % IdEvUH_T16, % "x+" . v_xNext . A_Space . "y+" . v_yNext - 2 . A_Space . "w+" . TotalWidth . A_Space . "h+" . 1
	GuiControl, Move, % IdEvUH_T8, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvUH_T8
	v_xNext += v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvUH_T9, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += HofText
	GuiControl, Move, % IdEvUH_R5, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvUH_R5
	v_xNext += v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvUH_R6, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += 3 * HofText
	GuiControl, Move, % IdEvUH_T17, % "x+" . v_xNext . A_Space . "y+" . v_yNext - 2 . A_Space . "w+" . TotalWidth . A_Space . "h+" . 1
	GuiControl, Move, % IdEvUH_T10, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvUH_T10
	v_xNext += v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvUH_T11, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += HofText
	GuiControl, Move, % IdEvUH_R7, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvUH_R7
	v_xNext += v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvUH_R8, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += HofText
	GuiControl, Move, % IdEvUH_T12, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_yNext += HofText
	GuiControl, Move, % IdEvUH_S2, % "x+" . v_xNext . A_Space . "y+" . v_yNext . A_Space . "w+" . v_wNext
	v_xNext += 2 * c_xmarg + TheWidestText
	GuiControl, Move, % IdEvUH_T13, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg
	GuiControlGet, v_OutVarTemp, Pos, % IdEvUH_S2
	v_yNext += v_OutVarTempH
	GuiControl, Move, % IdEvUH_S3, % "x+" . v_xNext . A_Space . "y+" . v_yNext . A_Space . "w+" . v_wNext	
	v_xNext += 2 * c_xmarg + TheWidestText
	GuiControl, Move, % IdEvUH_T14, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += 3 * HofText
	GuiControl, Move, % IdEvUH_B1, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvUH_B1
	v_xNext += v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvUH_B2, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvUH_B2
	v_xNext := v_OutVarTempX + v_OutVarTempW + 4 * c_xmarg
	GuiControl, Move, % IdEvUH_B3, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvUH_B3
	v_xNext := v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvUH_B4, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	return
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
		Case 2:
			GuiControl, Disable,	% IdEvBH_T6
			GuiControl, Disable,	% IdEvBH_S1
			GuiControl, Disable,	% IdEvBH_T7
	}
	return
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
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EvBH_R1R2()
{
	global ;assume-global mode
	Gui, GuiEvents: Submit, NoHide
	Switch EvBH_R1R2
	{
		Case 1:
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
		Case 2:
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
			GuiControl, Disable, 	% IdEvBH_B2
	}
	return
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
				ToolTip, % TransA["Hotstring was triggered!"] . A_Space . "[" . F_ParseHotkey(ini_HK_UndoLH) . "]" . A_Space . TransA["to undo."], % A_CaretX + 20, % A_CaretY - 20, 4
				if (EvBH_R3R4 > 0)
					SetTimer, TurnOff_OHE, % "-" . EvBH_S1, 40 ;Priority = 40 to avoid conflicts with other threads 
			}
			else
			{
				MouseGetPos, v_MouseX, v_MouseY
				ToolTip, % TransA["Hotstring was triggered!"] . A_Space . "[" . F_ParseHotkey(ini_HK_UndoLH) . "]" . A_Space . TransA["to undo."], % v_MouseX + 20, % v_MouseY - 20, 4
				if (EvBH_R3R4 > 0)
					SetTimer, TurnOff_OHE, % "-" . EvBH_S1, 40 ;Priority = 40 to avoid conflicts with other threads 
			}
		}
		if (EvBH_R5R6 = 2)
		{
			MouseGetPos, v_MouseX, v_MouseY
			ToolTip, % TransA["Hotstring was triggered!"] . A_Space . "[" . F_ParseHotkey(ini_HK_UndoLH) . "]" . A_Space . TransA["to undo."], % v_MouseX + 20, % v_MouseY - 20, 4
			if (EvBH_R3R4 > 0)
				SetTimer, TurnOff_OHE, % "-" . EvBH_S1, 40 ;Priority = 40 to avoid conflicts with other threads 
		}
	}
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EvBH_B2()	;Events Basic Hotstring (is triggered) Button Sound test
{
	global ;assume-global mode
	SoundBeep, % EvBH_S2, % EvBH_S3
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EvBH_B4()	;Events Basic Hotstring (is triggered) Button Cancel
{
	global ;assume-global mode
	Tooltip,,,, 4
	Gui, GuiEvents: Destroy
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EvBH_B3()	;Events Basic Hotstring (is triggered) Button Apply & Close
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
	IniWrite, % ini_OHTtEn, 	% HADConfig, Event_BasicHotstring, 	OHTtEn
	IniWrite, % ini_OHTD,	% HADConfig, Event_BasicHotstring,		OHTD
	IniWrite, % ini_OHTP,	% HADConfig, Event_BasicHotstring,		OHTP
	IniWrite, % ini_OHSEn, 	% HADConfig, Event_BasicHotstring,		OHSEn
	IniWrite, % ini_OHSF,	% HADConfig, Event_BasicHotstring,		OHSF
	IniWrite, % ini_OHSD,	% HADConfig, Event_BasicHotstring,		OHSD
	Tooltip,,,, 4
	Gui, GuiEvents: Destroy
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EvBH_S3()
{
	global ;assume-global mode
	GuiControl,, % IdEvBH_T14, % TransA["Sound duration [ms]"] . ":" . A_Space . EvBH_S3
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EvBH_S2()
{
	global ;assume-global mode
	GuiControl,, % IdEvBH_T13, % TransA["Sound frequency"] . ":" . A_Space . EvBH_S2
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EvBH_S1()
{
	global ;assume-global mode
	GuiControl,, % IdEvBH_T7, % TransA["Timeout value [ms]"] . ":" . A_Space . EvBH_S1
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_GuiEvents_InitiateValues()
{
	global ;assume-global mode
	EvBH_S1 := ini_OHTD, EvBH_S2 := ini_OHSF, EvBH_S3 := ini_OHSD, EvMH_S1 := ini_MHSF, EvMH_S2 := ini_MHSD, EvUH_S1 := ini_UHTD, EvUH_S2 := ini_UHSF, EvUH_S3 := ini_UHSD
	Switch ini_OHTtEn
	{
		Case false: 	EvBH_R1R2 := 1
		Case true: 	EvBH_R1R2 := 2
	}
	Switch ini_OHTD
	{
		Case 0: 		EvBH_R3R4 := 1
		Default:		EvBH_R3R4 := 2
	}
	Switch ini_OHTP
	{
		Case 1: 		EvBH_R5R6 := 1
		Case 2: 		EvBH_R5R6 := 2
	}
	Switch ini_OHSEn
	{
		Case false: 	EvBH_R7R8 := 1
		Case true: 	EvBH_R7R8 := 2
	}
	Switch ini_MHMP
	{
		Case 1:		EvMH_R1R2 := 1
		Case 2:		EvMH_R1R2 := 2
	}
	Switch ini_MHSEn
	{
		Case false:	EvMH_R3R4 := 1
		Case true:	EvMH_R3R4 := 2
	}
	Switch ini_UHTtEn
	{
		Case false: 	EvUH_R1R2 := 1
		Case true: 	EvUH_R1R2 := 2
	}
	Switch ini_UHTD
	{
		Case 0: 		EvUH_R3R4 := 1
		Default:		EvUH_R3R4 := 2
	}
	Switch ini_UHTP
	{
		Case 1: 		EvUH_R5R6 := 1
		Case 2: 		EvUH_R5R6 := 2
	}
	Switch ini_UHSEn
	{
		Case false: 	EvUH_R7R8 := 1
		Case true: 	EvUH_R7R8 := 2
	}
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_GuiEvents_LoadValues()
{
	global ;assume-global mode
	Switch ini_OHTtEn
	{
		Case false: 	GuiControl,, % IdEvBH_R2, 1
		Case true: 	GuiControl,, % IdEvBH_R1, 1
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
		Case 1: 		GuiControl,, % IdEvBH_R6, 1
		Case 2: 		GuiControl,, % IdEvBH_R5, 1
	}
	Switch ini_OHSEn
	{
		Case false: 	GuiControl,, % IdEvBH_R8, 1
		Case true: 	GuiControl,, % IdEvBH_R7, 1
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
		Case false: 	GuiControl,, % IdEvMH_R3, 1
		Case true: 	GuiControl,, % IdEvMH_R4, 1
	}
	GuiControl,, % IdEvMH_S1, 	% ini_MHSF
	GuiControl,, % IdEvMH_T7, 	% TransA["Sound frequency"] . ":" 		. A_Space . ini_MHSF
	GuiControl,, % IdEvMH_S2, 	% ini_MHSD
	GuiControl,, % IdEvMH_T8, 	% TransA["Sound duration [ms]"] . ":" 	. A_Space . ini_MHSD

	Switch ini_UHTtEn
	{
		Case false: 	GuiControl,, % IdEvUH_R2, 1
		Case true: 	GuiControl,, % IdEvUH_R1, 1
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
		Case 1: 		GuiControl,, % IdEvUH_R6, 1
		Case 2: 		GuiControl,, % IdEvUH_R5, 1
	}
	Switch ini_UHSEn
	{
		Case false: 	GuiControl,, % IdEvUH_R8, 1
		Case true: 	GuiControl,, % IdEvUH_R7, 1
	}
	GuiControl,, % IdEvUH_S2, 	% ini_UHSF
	GuiControl,, % IdEvUH_T13, 	% TransA["Sound frequency"] . ":" 		. A_Space . ini_UHSF
	GuiControl,, % IdEvUH_S3, 	% ini_UHSD
	GuiControl,, % IdEvUH_T14, 	% TransA["Sound duration [ms]"] . ":" 	. A_Space . ini_UHSD
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_LoadHMStyling()
{
	global ;assume-global mode
	ini_HMBgrCol		:= "white"
	ini_HMTyFaceCol	:= "black"
	ini_HMTyFaceFont	:= "Calibri"
	ini_HMTySize		:= 10
	
	IniRead, ini_HMBgrCol, 			% HADConfig, HotstringMenu_Styling, HotstringMenuBackgroundColor, white
	if (!ini_HMBgrCol)
		ini_HMBgrCol := "white"
	if (ini_HMBgrCol = "custom")
		IniRead, ini_HMBgrColCus,	% HADConfig, HotstringMenu_Styling, HotstringMenuBackgroundColorCustom
	IniRead, ini_HMTyFaceCol, 		% HADConfig, HotstringMenu_Styling, HotstringMenuTypefaceColor, black
	if (!ini_HMTyFaceCol)
		ini_HMTyFaceCol := "black"
	if (ini_HMTyFaceCol = "custom")
		IniRead, ini_HMTyFaceColCus,	% HADConfig, HotstringMenu_Styling, HotstringMenuTypefaceColorCustom
	IniRead, ini_HMTyFaceFont, 		% HADConfig, HotstringMenu_Styling, HotstringMenuTypefaceFont, Calibri
	if (!ini_HMTyFaceFont)
		ini_HMTyFaceFont := "Calibri"
	IniRead, ini_HMTySize,	 		% HADConfig, HotstringMenu_Styling, HotstringMenuTypefaceSize, 10
	if (!ini_HMTySize)
		ini_HMTySize := 10
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_LoadTTStyling()
{
	global ;assume-global mode
	ini_TTBgrCol		:= "white"
	ini_TTTyFaceCol	:= "black"
	ini_TTTyFaceFont	:= "Calibri"
	ini_TTTySize		:= 10
	
	IniRead, ini_TTBgrCol, 			% HADConfig, TriggerstringTips_Styling, TriggerstringTipsBackgroundColor, white
	if (!ini_TTBgrCol)
		ini_TTBgrCol := "white"
	if (ini_TTBgrCol = "custom")
		IniRead, ini_TTBgrColCus,	% HADConfig, TriggerstringTips_Styling, TriggerstringTipsBackgroundColorCustom
	IniRead, ini_TTTyFaceCol, 		% HADConfig, TriggerstringTips_Styling, TriggerstringTipsTypefaceColor, black
	if (!ini_TTTyFaceCol)
		ini_TTTyFaceCol := "black"
	if (ini_TTTyFaceCol = "custom")
		IniRead, ini_TTTyFaceColCus,	% HADConfig, TriggerstringTips_Styling, TriggerstringTipsTypefaceColorCustom
	IniRead, ini_TTTyFaceFont, 		% HADConfig, TriggerstringTips_Styling, TriggerstringTipsTypefaceFont, Calibri
	if (!ini_TTTyFaceFont)
		ini_TTTyFaceFont := "Calibri"
	IniRead, ini_TTTySize,	 		% HADConfig, TriggerstringTips_Styling, TriggerstringTipsTypefaceSize, 10
	if (!ini_TTTySize)
		ini_TTTySize := 10
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_GuiStyling_CreateObjects()
{
	global ;assume-global mode
	
	;1. Prepare Gui
	Gui, TTstyling: New, 	-Resize +HwndTTstylingHwnd +Owner +OwnDialogs -MaximizeBox -MinimizeBox	;+OwnDialogs: for tooltips.
	Gui, TTstyling: Margin,	% c_xmarg, % c_ymarg
	Gui,	TTstyling: Color,	% c_WindowColor, % c_ControlColor
	
	;2. Prepare all text objects according to mock-up.
	Gui,	TTstyling: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, 			% c_FontType
	Gui, TTstyling: Add,	Tab3,		gF_StylingSwitch,		% TransA["Triggerstring tips styling"] . "||" . TransA["Hotstring menu styling"]
	Gui, TTstyling: Tab, 									% TransA["Triggerstring tips styling"]
	Gui, TTstyling: Add,	Text, 		HwndIdTTstyling_T1,		% TransA["Background color"] . ":"
	Gui, TTstyling: Font,	% "s" . c_FontSize + 2 . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, TTstyling: Add,	Text, 		HwndIdTTstyling_T2, 	ⓘ
	T_SBackgroundColorInfo := func("F_ShowLongTooltip").bind(TransA["T_SBackgroundColorInfo"])
	GuiControl, +g, % IdTTstyling_T2, % T_SBackgroundColorInfo
	Gui, TTstyling: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, % c_FontType
	Gui, TTstyling: Add,	DropDownList,	HwndIdTTstyling_DDL1 vini_TTBgrCol gF_StylingTTDDL1,	% TransA["black"] . "|" . TransA["silver"] . "|" . TransA["gray"] . "|" . TransA["white"] . "||" . TransA["maroon"] . "|" . TransA["red"] . "|" . TransA["purple"] . "|" . TransA["fuchsia"] . "|" . TransA["green"] . "|" . TransA["lime"] . "|" . TransA["olive"] . "|" . TransA["yellow"] . "|" . TransA["navy"] . "|" . TransA["blue"] . "|" . TransA["teal"] . "|" . TransA["aqua"] . "|" . TransA["custom"]
	Gui, TTstyling: Add,	Edit,		HwndIdTTstyling_E1 Limit6,		% TransA["HTML color RGB value, e.g. 00FF00"]
	Gui, TTstyling: Add,	Button,		HwndIdTTstyling_B1 gF_ButtonTTstylingB1,	% TransA["Restore default"]
	
	Gui, TTstyling: Add,	Text, 		HwndIdTTstyling_T3,		% TransA["Typeface color"] . ":"
	Gui, TTstyling: Font,	% "s" . c_FontSize + 2 . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, TTstyling: Add,	Text, 		HwndIdTTstyling_T4, 	ⓘ
	T_STypefaceColor := func("F_ShowLongTooltip").bind(TransA["T_STypefaceColor"])
	GuiControl +g, % IdTTstyling_T4, % T_STypefaceColor
	Gui, TTstyling: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, % c_FontType
	Gui, TTstyling: Add,	DropDownList,	HwndIdTTstyling_DDL2 vini_TTTyFaceCol gF_StylingTTDDL2,	% TransA["black"] . "||" . TransA["silver"] . "|" . TransA["gray"] . "|" . TransA["white"] . "|" . TransA["maroon"] . "|" . TransA["red"] . "|" . TransA["purple"] . "|" . TransA["fuchsia"] . "|" . TransA["green"] . "|" . TransA["lime"] . "|" . TransA["olive"] . "|" . TransA["yellow"] . "|" . TransA["navy"] . "|" . TransA["blue"] . "|" . TransA["teal"] . "|" . TransA["aqua"] . "|" . TransA["custom"]
	Gui, TTstyling: Add,	Edit,		HwndIdTTstyling_E2 Limit6,		% TransA["HTML color RGB value, e.g. 00FF00"]
	Gui, TTstyling: Add,	Button,		HwndIdTTstyling_B2 gF_ButtonTTStylingB2,	% TransA["Restore default"]
	
	Gui, TTstyling: Add,	Text, 		HwndIdTTstyling_T5,		% TransA["Typeface font"] . ":"
	Gui, TTstyling: Font,	% "s" . c_FontSize + 2 . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, TTstyling: Add,	Text, 		HwndIdTTstyling_T6, 	ⓘ
	T_STypefaceFont := func("F_ShowLongTooltip").bind(TransA["T_STypefaceFont"])
	GuiControl +g, % IdTTstyling_T6, % T_STypefaceFont
	Gui, TTstyling: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, % c_FontType
	Gui, TTstyling: Add,	DropDownList,	HwndIdTTstyling_DDL3 vini_TTTyFaceFont,	Arial|Calibri||Comic Sans MS|Consolas|Courier|Fixedsys|Lucida Console|Microsoft Sans Serif|Script|System|Tahoma|Times New Roman|Verdana
	Gui, TTstyling: Add,	Button,		HwndIdTTstyling_B3 gFButtonTTStylingB3,		% TransA["Restore default"]
	
	Gui, TTstyling: Add,	Text, 		HwndIdTTstyling_T7,		% TransA["Typeface size"] . ":"
	Gui, TTstyling: Font,	% "s" . c_FontSize + 2 . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, TTstyling: Add,	Text, 		HwndIdTTstyling_T8, 	ⓘ
	T_STypefaceSize := func("F_ShowLongTooltip").bind(TransA["T_STypefaceSize"])
	GuiControl +g, % IdTTstyling_T8, % T_STypefaceSize
	Gui, TTstyling: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, % c_FontType
	Gui, TTstyling: Add,	DropDownList,	HwndIdTTstyling_DDL4 vini_TTTySize,	7|8|9|10||11|12|13|14|15|16
	Gui, TTstyling: Add,	Button,		HwndIdTTstyling_B4 gFButtonTTStylingB4,		% TransA["Restore default"]
	
	Gui, TTstyling: Add,	Text, 		HwndIdTTstyling_T9,		% TransA["Preview"] . ":"
	Gui, TTstyling: Font,	% "s" . c_FontSize + 2 . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, TTstyling: Add,	Text, 		HwndIdTTstyling_T10, 	ⓘ
	T_StylPreview := func("F_ShowLongTooltip").bind(TransA["T_StylPreview"])
	GuiControl +g, % IdTTstyling_T10, % T_StylPreview
	Gui, TTstyling: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, % c_FontType
	Gui, TTstyling: Add,	Listbox, 		HwndIdTTstyling_LB1 r5,	% TransA["Row"] . " 1|" . TransA["Row"] . " 2|" . TransA["Row"] . " 3|" . TransA["Row"] . " 4|" . TransA["Row"] . " 5"
	
	Gui, TTstyling: Add,	Button,		HwndIdTTstyling_B5 gF_ButtonTTTestStyling,	% TransA["Test styling"]
	Gui, TTstyling: Add,	Button,		HwndIdTTstyling_B6 gF_ButtonTTApplyClose,		% TransA["Apply && Close"]
	Gui, TTstyling: Add,	Button,		HwndIdTTstyling_B7 gF_ButtonTTCancel,		% TransA["Cancel"]
	
	Gui, TTstyling: Tab, 									% TransA["Hotstring menu styling"]
	Gui, TTstyling: Add,	Text, 		HwndIdHMstyling_T1,		% TransA["Background color"] . ":"
	Gui, TTstyling: Font,	% "s" . c_FontSize + 2 . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, TTstyling: Add,	Text, 		HwndIdHMstyling_T2, 	ⓘ
	GuiControl, +g, % IdHMstyling_T2, % T_SBackgroundColorInfo
	Gui, TTstyling: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, % c_FontType
	Gui, TTstyling: Add,	DropDownList,	HwndIdHMstyling_DDL1 vini_HMBgrCol gF_StylingHMDDL1,	% TransA["black"] . "|" . TransA["silver"] . "|" . TransA["gray"] . "|" . TransA["white"] . "||" . TransA["maroon"] . "|" . TransA["red"] . "|" . TransA["purple"] . "|" . TransA["fuchsia"] . "|" . TransA["green"] . "|" . TransA["lime"] . "|" . TransA["olive"] . "|" . TransA["yellow"] . "|" . TransA["navy"] . "|" . TransA["blue"] . "|" . TransA["teal"] . "|" . TransA["aqua"] . "|" . TransA["custom"]
	Gui, TTstyling: Add,	Edit,		HwndIdHMstyling_E1 Limit6,		% TransA["HTML color RGB value, e.g. 00FF00"]
	Gui, TTstyling: Add,	Button,		HwndIdHMstyling_B1 gF_ButtonHMstylingB1,	% TransA["Restore default"]
	
	Gui, TTstyling: Add,	Text, 		HwndIdHMstyling_T3,		% TransA["Typeface color"] . ":"
	Gui, TTstyling: Font,	% "s" . c_FontSize + 2 . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, TTstyling: Add,	Text, 		HwndIdHMstyling_T4, 	ⓘ
	GuiControl +g, % IdHMstyling_T4, % T_STypefaceColor
	Gui, TTstyling: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, % c_FontType
	Gui, TTstyling: Add,	DropDownList,	HwndIdHMstyling_DDL2 vini_HMTyFaceCol gF_StylingHMDDL2,	% TransA["black"] . "||" . TransA["silver"] . "|" . TransA["gray"] . "|" . TransA["white"] . "|" . TransA["maroon"] . "|" . TransA["red"] . "|" . TransA["purple"] . "|" . TransA["fuchsia"] . "|" . TransA["green"] . "|" . TransA["lime"] . "|" . TransA["olive"] . "|" . TransA["yellow"] . "|" . TransA["navy"] . "|" . TransA["blue"] . "|" . TransA["teal"] . "|" . TransA["aqua"] . "|" . TransA["custom"]
	Gui, TTstyling: Add,	Edit,		HwndIdHMstyling_E2 Limit6,		% TransA["HTML color RGB value, e.g. 00FF00"]
	Gui, TTstyling: Add,	Button,		HwndIdHMstyling_B2 gF_ButtonHMStylingB2,	% TransA["Restore default"]
	
	Gui, TTstyling: Add,	Text, 		HwndIdHMstyling_T5,		% TransA["Typeface font"] . ":"
	Gui, TTstyling: Font,	% "s" . c_FontSize + 2 . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, TTstyling: Add,	Text, 		HwndIdHMstyling_T6, 	ⓘ
	GuiControl +g, % IdHMstyling_T6, % T_STypefaceFont
	Gui, TTstyling: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, % c_FontType
	Gui, TTstyling: Add,	DropDownList,	HwndIdHMstyling_DDL3 vini_HMTyFaceFont,	Arial|Calibri||Comic Sans MS|Consolas|Courier|Fixedsys|Lucida Console|Microsoft Sans Serif|Script|System|Tahoma|Times New Roman|Verdana
	Gui, TTstyling: Add,	Button,		HwndIdHMstyling_B3 gF_ButtonHMStylingB3,		% TransA["Restore default"]
	
	Gui, TTstyling: Add,	Text, 		HwndIdHMstyling_T7,		% TransA["Typeface size"] . ":"
	Gui, TTstyling: Font,	% "s" . c_FontSize + 2 . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, TTstyling: Add,	Text, 		HwndIdHMstyling_T8, 	ⓘ
	GuiControl +g, % IdHMstyling_T8, % T_STypefaceSize
	Gui, TTstyling: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, % c_FontType
	Gui, TTstyling: Add,	DropDownList,	HwndIdHMstyling_DDL4 vini_HMTySize,	7|8|9|10||11|12|13|14|15|16
	Gui, TTstyling: Add,	Button,		HwndIdHMstyling_B4 gF_ButtonHMStylingB4,		% TransA["Restore default"]
	
	Gui, TTstyling: Add,	Text, 		HwndIdHMstyling_T9,		% TransA["Preview"] . ":"
	Gui, TTstyling: Font,	% "s" . c_FontSize + 2 . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, TTstyling: Add,	Text, 		HwndIdHMstyling_T10, 	ⓘ
	GuiControl +g, % IdHMstyling_T10, % T_StylPreview
	Gui, TTstyling: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, % c_FontType
	Gui, TTstyling: Add,	Listbox, 		HwndIdHMstyling_LB1 r5,	% TransA["Row"] . " 1|" . TransA["Row"] . " 2|" . TransA["Row"] . " 3|" . TransA["Row"] . " 4|" . TransA["Row"] . " 5"
	
	Gui, TTstyling: Add,	Button,		HwndIdHMstyling_B5 gF_ButtonHMTestStyling,	% TransA["Test styling"]
	Gui, TTstyling: Add,	Button,		HwndIdHMstyling_B6 gF_ButtonHMApplyClose,	% TransA["Apply && Close"]
	Gui, TTstyling: Add,	Button,		HwndIdHMstyling_B7 gF_ButtonHMCancel,		% TransA["Cancel"]
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_StylingHMDDL1()
{
	global ;assume-global mode
	local OutputVarTemp := ""
	GuiControlGet, OutputVarTemp,, % IdHMstyling_DDL1
	if (OutputVarTemp = "custom")
		GuiControl, Enable, % IdHMstyling_E1
	else
	{
		GuiControl,, % IdHMstyling_E1, % TransA["HTML color RGB value, e.g. 00FF00"] 
		GuiControl, Disable, % IdHMstyling_E1
	}
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_StylingHMDDL2()
{
	global ;assume-global mode
	local OutputVarTemp := ""
	GuiControlGet, OutputVarTemp,, % IdHMstyling_DDL2
	if (OutputVarTemp = "custom")
		GuiControl, Enable, % IdHMstyling_E2
	else
	{
		GuiControl,, % IdHMstyling_E2, % TransA["HTML color RGB value, e.g. 00FF00"] 
		GuiControl, Disable, % IdHMstyling_E2
	}
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_StylingTTDDL1()
{
	global ;assume-global mode
	local OutputVarTemp := ""
	GuiControlGet, OutputVarTemp,, % IdTTstyling_DDL1
	if (OutputVarTemp = "custom")
		GuiControl, Enable, % IdTTstyling_E1
	else
	{
		GuiControl,, % IdTTstyling_E1, % TransA["HTML color RGB value, e.g. 00FF00"] 
		GuiControl, Disable, % IdTTstyling_E1
	}
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_StylingTTDDL2()
{
	global ;assume-global mode
	local OutputVarTemp := ""
	GuiControlGet, OutputVarTemp,, % IdTTstyling_DDL2
	if (OutputVarTemp = "custom")
		GuiControl, Enable, % IdTTstyling_E2
	else
	{
		GuiControl,, % IdTTstyling_E2, % TransA["HTML color RGB value, e.g. 00FF00"] 
		GuiControl, Disable, % IdTTstyling_E2
	}
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_StylingSwitch()
{
	global ;assume-global mode
	if (WinExist("ahk_id" TDemoHwnd))
	{
		Gui, TDemo: 		Destroy
		F_ButtonHMTestStyling()
		return
	}
	if (WinExist("ahk_id" HDemoHwnd))
	{
		Gui, HDemo: 		Destroy
		F_ButtonTTTestStyling()
		return
	}
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_ButtonHMStylingB4()
{
	global ;assume-global mode
	local s_HMstyling_DDL4 := "|7|8|9|10||11|12|13|14|15|16"
	ini_HMTySize := 10
	GuiControl,, % IdHMstyling_DDL4, % s_HMStyling_DDL4
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_ButtonHMStylingB3()
{
	global ;assume-global mode
	local s_HMstyling_DDL3 := "|Arial|Calibri||Comic Sans MS|Consolas|Courier|Fixedsys|Lucida Console|Microsoft Sans Serif|Script|System|Tahoma|Times New Roman|Verdana"
	ini_HMTyFaceFont := "Calibri"
	GuiControl,, % IdHMstyling_DDL3, % s_HMStyling_DDL3
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_ButtonHMStylingB2()
{
	global ;assume-global mode
	local s_HMstyling_DDL2 := "|" . TransA["black"] . "||" . TransA["silver"] . "|" . TransA["gray"] . "|" . TransA["white"] . "|" . TransA["maroon"] . "|" . TransA["red"] . "|" . TransA["purple"] . "|" . TransA["fuchsia"] . "|" . TransA["green"] . "|" . TransA["lime"] . "|" . TransA["olive"] . "|" . TransA["yellow"] . "|" . TransA["navy"] . "|" . TransA["blue"] . "|" . TransA["teal"] . "|" . TransA["aqua"]
	ini_HMTyFaceCol := "black"
	GuiControl,, % IdHMstyling_DDL2, % s_HMStyling_DDL2
	GuiControl,, % IdHMstyling_E2, % TransA["HTML color RGB value, e.g. 00FF00"] 
	GuiControl, Disable, % IdHMstyling_E2
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_ButtonHMstylingB1()
{
	global ;assume-global mode
	local s_HMstyling_DDL1 := "|" . TransA["black"] . "|" . TransA["silver"] . "|" . TransA["gray"] . "|" . TransA["white"] . "||" . TransA["maroon"] . "|" . TransA["red"] . "|" . TransA["purple"] . "|" . TransA["fuchsia"] . "|" . TransA["green"] . "|" . TransA["lime"] . "|" . TransA["olive"] . "|" . TransA["yellow"] . "|" . TransA["navy"] . "|" . TransA["blue"] . "|" . TransA["teal"] . "|" . TransA["aqua"]
	ini_HMBgrCol := "white"
	GuiControl,, % IdHMstyling_DDL1, % s_HMStyling_DDL1
	GuiControl,, % IdHMstyling_E1, % TransA["HTML color RGB value, e.g. 00FF00"] 
	GuiControl, Disable, % IdHMstyling_E1
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
FButtonTTStylingB4()
{
	global ;assume-global mode
	local s_TTstyling_DDL4 := "|7|8|9|10||11|12|13|14|15|16"
	
	ini_TTTySize := 10
	GuiControl,, % IdTTstyling_DDL4, % s_TTStyling_DDL4
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
FButtonTTStylingB3()
{
	global ;assume-global mode
	local s_TTstyling_DDL3 := "|Arial|Calibri||Comic Sans MS|Consolas|Courier|Fixedsys|Lucida Console|Microsoft Sans Serif|Script|System|Tahoma|Times New Roman|Verdana"
	
	ini_TTTyFaceFont := "Calibri"
	GuiControl,, % IdTTstyling_DDL3, % s_TTStyling_DDL3
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_ButtonTTStylingB2()
{
	global ;assume-global mode
	local s_TTstyling_DDL2 := "|" . TransA["black"] . "||" . TransA["silver"] . "|" . TransA["gray"] . "|" . TransA["white"] . "|" . TransA["maroon"] . "|" . TransA["red"] . "|" . TransA["purple"] . "|" . TransA["fuchsia"] . "|" . TransA["green"] . "|" . TransA["lime"] . "|" . TransA["olive"] . "|" . TransA["yellow"] . "|" . TransA["navy"] . "|" . TransA["blue"] . "|" . TransA["teal"] . "|" . TransA["aqua"]
	ini_TTTyFaceCol := "black"
	GuiControl,, % IdTTstyling_DDL2, % s_TTStyling_DDL2
	GuiControl,, % IdTTstyling_E2, % TransA["HTML color RGB value, e.g. 00FF00"] 
	GuiControl, Disable, % IdTTstyling_E2
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_ButtonTTstylingB1()
{
	global ;assume-global mode
	local s_TTstyling_DDL1 := "|" . TransA["black"] . "|" . TransA["silver"] . "|" . TransA["gray"] . "|" . TransA["white"] . "||" . TransA["maroon"] . "|" . TransA["red"] . "|" . TransA["purple"] . "|" . TransA["fuchsia"] . "|" . TransA["green"] . "|" . TransA["lime"] . "|" . TransA["olive"] . "|" . TransA["yellow"] . "|" . TransA["navy"] . "|" . TransA["blue"] . "|" . TransA["teal"] . "|" . TransA["aqua"]
	ini_TTBgrCol := "white"
	GuiControl,, % IdTTstyling_DDL1, % s_TTStyling_DDL1
	GuiControl,, % IdTTstyling_E1, % TransA["HTML color RGB value, e.g. 00FF00"] 
	GuiControl, Disable, % IdTTstyling_E1
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_ButtonTTCancel()
{
	global ;assume-global mode
	Gui, TTstyling: 	Destroy
	Gui, TDemo: 		Destroy
	F_LoadTTStyling()	;restore previous values
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_ButtonHMCancel()
{
	global ;assume-global mode
	Gui, TTstyling: 	Destroy
	Gui, HDemo: 		Destroy
	F_LoadHMStyling()	;restore previous values
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_ButtonTTApplyClose()
{
	global ;assume-global mode
	
	Gui, TTstyling: 	Submit
	IniWrite, % ini_TTBgrCol, 	% HADConfig, TriggerstringTips_Styling, TriggerstringTipsBackgroundColor
	if (ini_TTBgrCol = "custom")
	{
		GuiControlGet, OutputVarTemp,, % IdTTstyling_E1
		if (!RegExMatch(OutputVarTemp, "^[[:xdigit:]]{6}"))
		{
			MsgBox, 48, % SubStr(A_ScriptName, 1, -4) .  ":" . A_Space . TransA["warning"], % TransA["Incorrect value. Select custom RGB hex value. Please try again."] . A_Space . "`n" 
			Gui, TDemo: Destroy
			return
		}
		else
		{
			ini_TTBgrColCus := OutputVarTemp
			IniWrite, % ini_TTBgrColCus, 	% HADConfig, TriggerstringTips_Styling, TriggerstringTipsBackgroundColorCustom
		}
	}
	else
		IniWrite, "", 	% HADConfig, TriggerstringTips_Styling, TriggerstringTipsBackgroundColorCustom

	IniWrite, % ini_TTTyFaceCol, 	% HADConfig, TriggerstringTips_Styling, TriggerstringTipsTypefaceColor
	if (ini_TTTyFaceCol = "custom")
	{
		GuiControlGet, OutputVarTemp,, % IdTTstyling_E2
		if (!RegExMatch(OutputVarTemp, "^[[:xdigit:]]{6}"))
		{
			MsgBox, 48, % SubStr(A_ScriptName, 1, -4) .  ":" . A_Space . TransA["warning"], % TransA["Incorrect value. Select custom RGB hex value. Please try again."] . A_Space . "`n" 
			Gui, TDemo: Destroy
			return
		}
		else
		{
			ini_TTTyFaceColCus := OutputVarTemp
			IniWrite, % ini_TTTyFaceColCus, 	% HADConfig, TriggerstringTips_Styling, TriggerstringTipsTypefaceColorCustom
		}
	}
	else
		IniWrite, "", 	% HADConfig, TriggerstringTips_Styling, TriggerstringTipsTypefaceColorCustom
	IniWrite, % ini_TTTyFaceFont, % HADConfig, TriggerstringTips_Styling, TriggerstringTipsTypefaceFont
	IniWrite, % ini_TTTySize,	% HADConfig, TriggerstringTips_Styling, TriggerstringTipsTypefaceSize
	Gui, TDemo: 		Destroy
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_ButtonHMApplyClose()
{
	global ;assume-global mode
	
	Gui, TTstyling: 	Submit
	IniWrite, % ini_HMBgrCol, 	% HADConfig, HotstringMenu_Styling, HotstringMenuBackgroundColor
	if (ini_HMBgrCol = "custom")
	{
		GuiControlGet, OutputVarTemp,, % IdHMstyling_E1
		if (!RegExMatch(OutputVarTemp, "^[[:xdigit:]]{6}"))
		{
			MsgBox, 48, % SubStr(A_ScriptName, 1, -4) .  ":" . A_Space . TransA["warning"], % TransA["Incorrect value. Select custom RGB hex value. Please try again."] . A_Space . "`n" 
			Gui, HDemo: Destroy
			return
		}
		else
		{
			ini_HMBgrColCus := OutputVarTemp
			IniWrite, % ini_HMBgrColCus, 	% HADConfig, HotstringMenu_Styling, HotstringMenuBackgroundColorCustom
		}
	}
	else
		IniWrite, "", 	% HADConfig, HotstringMenu_Styling, HotstringMenuBackgroundColorCustom

	IniWrite, % ini_HMTyFaceCol, 	% HADConfig, HotstringMenu_Styling, HotstringMenuTypefaceColor
	if (ini_HMTyFaceCol = "custom")
	{
		GuiControlGet, OutputVarTemp,, % IdHMstyling_E2
		if (!RegExMatch(OutputVarTemp, "^[[:xdigit:]]{6}"))
		{
			MsgBox, 48, % SubStr(A_ScriptName, 1, -4) .  ":" . A_Space . TransA["warning"], % TransA["Incorrect value. Select custom RGB hex value. Please try again."] . A_Space . "`n" 
			Gui, HDemo: Destroy
			return
		}
		else
		{
			ini_HMTyFaceColCus := OutputVarTemp
			IniWrite, % ini_HMTyFaceColCus, 	% HADConfig, HotstringMenu_Styling, HotstringMenuTypefaceColorCustom
		}
	}
	else
		IniWrite, "", 	% HADConfig, HotstringMenu_Styling, HotstringMenuTypefaceColorCustom
	IniWrite, % ini_HMTyFaceFont, % HADConfig, HotstringMenu_Styling, HotstringMenuTypefaceFont
	IniWrite, % ini_HMTySize,	% HADConfig, HotstringMenu_Styling, HotstringMenuTypefaceSize
	Gui, HDemo: 		Destroy
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_ButtonTTTestStyling()
{
	global ;assume-global mode
	local Window1X := 0, Window1Y := 0, Window1W := 0, Window1H := 0
		,OutputVarTemp := 0, OutputVarTempX := 0, OutputVarTempY := 0, OutputVarTempW := 0, OutputVarTempH := 0
	
	Gui, TTstyling: Submit, NoHide
	if (ini_TTBgrCol = "custom")
	{
		GuiControlGet, OutputVarTemp,, % IdTTstyling_E1
		if (!RegExMatch(OutputVarTemp, "^[[:xdigit:]]{6}"))
		{
			MsgBox, 48, % SubStr(A_ScriptName, 1, -4) .  ":" . A_Space . TransA["warning"], % TransA["Incorrect value. Select custom RGB hex value. Please try again."] . A_Space . "`n" 
			Gui, TDemo: Destroy
			return
		}
		else 
			ini_TTBgrColCus := OutputVarTemp
	}
	if (ini_TTTyFaceCol = "custom")
	{
		GuiControlGet, OutputVarTemp,, % IdTTstyling_E2
		if (!RegExMatch(OutputVarTemp, "^[[:xdigit:]]{6}"))
		{
			MsgBox, 48, % SubStr(A_ScriptName, 1, -4) .  ":" . A_Space . TransA["warning"], % TransA["Incorrect value. Select custom RGB hex value. Please try again."] . A_Space . "`n" 
			Gui, TDemo: Destroy
			return
		}
		else 
			ini_TTTyFaceColCus := OutputVarTemp
	}
	WinGetPos, Window1X, Window1Y, Window1W, Window1H, % "ahk_id" . TTstylingHwnd
	ControlGetPos, OutputVarTempX, OutputVarTempY, , , , ahk_id %IdTTstyling_LB1%
	Gui, TDemo: New, -Caption +ToolWindow +HwndTDemoHwnd
	Gui, TDemo: Margin, 0, 0
	if (ini_TTBgrCol = "custom")
		Gui, TDemo: Color,, % ini_TTBgrColCus
	else
		Gui, TDemo: Color,, % ini_TTBgrCol
	if (ini_TTTyFaceCol = "custom")		
		Gui, TDemo: Font, % "s" . ini_TTTySize . A_Space . "c" . ini_TTTyFaceColCus, % ini_TTTyFaceFont
	else
		Gui, TDemo: Font, % "s" . ini_TTTySize . A_Space . "c" . ini_TTTyFaceCol, % ini_TTTyFaceFont
	Gui, TDemo: Add, Listbox, HwndIdTDemo r5, % TransA["Row"] . " 1|" . TransA["Row"] . " 2|" . TransA["Row"] . " 3|" . TransA["Row"] . " 4|" . TransA["Row"] . " 5"
	Gui, TDemo: Show, % "x" . Window1X + OutputVarTempX . A_Space . "y" . Window1Y + OutputVarTempY . A_Space "NoActivate"	;future: prevent parent window from moving: https://autohotkey.com/board/topic/17759-window-system-menu-manipulator-library-v20/
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_ButtonHMTestStyling()
{
	global ;assume-global mode
	local Window1X := 0, Window1Y := 0, Window1W := 0, Window1H := 0
		,OutputVarTemp := 0, OutputVarTempX := 0, OutputVarTempY := 0, OutputVarTempW := 0, OutputVarTempH := 0
	
	Gui, TTstyling: Submit, NoHide
	if (ini_HMBgrCol = "custom")
	{
		GuiControlGet, OutputVarTemp,, % IdHMstyling_E1
		if (!RegExMatch(OutputVarTemp, "^[[:xdigit:]]{6}"))
		{
			MsgBox, 48, % SubStr(A_ScriptName, 1, -4) .  ":" . A_Space . TransA["warning"], % TransA["Incorrect value. Select custom RGB hex value. Please try again."] . A_Space . "`n" 
			Gui, HDemo: Destroy
			return
		}
		else 
			ini_HMBgrColCus := OutputVarTemp
	}
	if (ini_HMTyFaceCol = "custom")
	{
		GuiControlGet, OutputVarTemp,, % IdHMstyling_E2
		if (!RegExMatch(OutputVarTemp, "^[[:xdigit:]]{6}"))
		{
			MsgBox, 48, % SubStr(A_ScriptName, 1, -4) .  ":" . A_Space . TransA["warning"], % TransA["Incorrect value. Select custom RGB hex value. Please try again."] . A_Space . "`n" 
			Gui, HDemo: Destroy
			return
		}
		else 
			ini_HMTyFaceColCus := OutputVarTemp
	}
	WinGetPos, Window1X, Window1Y, Window1W, Window1H, % "ahk_id" . TTstylingHwnd
	ControlGetPos, OutputVarTempX, OutputVarTempY, , , , ahk_id %IdHMstyling_LB1%
	Gui, HDemo: New, -Caption +ToolWindow +HwndHDemoHwnd
	Gui, HDemo: Margin, 0, 0
	if (ini_HMBgrCol = "custom")
		Gui, HDemo: Color,, % ini_HMBgrColCus
	else
		Gui, HDemo: Color,, % ini_HMBgrCol
	if (ini_HMTyFaceCol = "custom")		
		Gui, HDemo: Font, % "s" . ini_HMTySize . A_Space . "c" . ini_HMTyFaceColCus, % ini_HMTyFaceFont
	else
		Gui, HDemo: Font, % "s" . ini_HMTySize . A_Space . "c" . ini_HMTyFaceCol, % ini_HMTyFaceFont
	Gui, HDemo: Add, Listbox, HwndIdHDemo r5, % TransA["Row"] . " 1|" . TransA["Row"] . " 2|" . TransA["Row"] . " 3|" . TransA["Row"] . " 4|" . TransA["Row"] . " 5"
	Gui, HDemo: Show, % "x" . Window1X + OutputVarTempX . A_Space . "y" . Window1Y + OutputVarTempY . A_Space "NoActivate"	;future: prevent parent window from moving: https://autohotkey.com/board/topic/17759-window-system-menu-manipulator-library-v20/
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_GuiHMstyling_DetermineConstraints()
{
	global ;assume-global mode
	local v_OutVarTemp := 0, 	v_OutVarTempX := 0, 	v_OutVarTempY := 0, 	v_OutVarTempW := 0, 	v_OutVarTempH := 0
		,v_OutVarTemp1 := 0, 	v_OutVarTemp1X := 0, 	v_OutVarTemp1Y := 0, 	v_OutVarTemp1W := 0, 	v_OutVarTemp1H := 0
		,v_OutVarTemp2 := 0, 	v_OutVarTemp2X := 0, 	v_OutVarTemp2Y := 0, 	v_OutVarTemp2W := 0, 	v_OutVarTemp2H := 0
		,v_OutVarTemp3 := 0, 	v_OutVarTemp3X := 0, 	v_OutVarTemp3Y := 0, 	v_OutVarTemp3W := 0, 	v_OutVarTemp3H := 0
		,v_OutVarTemp4 := 0, 	v_OutVarTemp4X := 0, 	v_OutVarTemp4Y := 0, 	v_OutVarTemp4W := 0, 	v_OutVarTemp4H := 0
							,v_xNext := 0, 		v_yNext := 0, 			v_wNext := 0, 			v_hNext := 0
		,TheWidestText := 0
	
	GuiControlGet, v_OutVarTemp1, Pos, % IdHMstyling_T1
	GuiControlGet, v_OutVarTemp2, Pos, % IdHMstyling_T3
	GuiControlGet, v_OutVarTemp3, Pos, % IdHMstyling_T5
	GuiControlGet, v_OutVarTemp4, Pos, % IdHMstyling_T7
	TheWidestText := Max(v_OutVarTemp1W, v_OutVarTemp2W, v_OutVarTemp3W, v_OutVarTemp4W)
	
	v_xNext := c_xmarg
	v_yNext := c_ymarg
	GuiControl, Move, % IdHMstyling_T1, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext += TheWidestText + 2 * c_xmarg
	GuiControl, Move, % IdHMstyling_T2, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg
	v_yNext += HofText
	GuiControl, Move, % IdHMstyling_DDL1, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdHMstyling_DDL1
	v_xNext += v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdHMstyling_E1, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdHMstyling_E1
	v_xNext := v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdHMstyling_B1, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	                    
	v_xNext := c_xmarg
	GuiControlGet, v_OutVarTemp, Pos, % IdHMstyling_B1
	v_yNext += v_OutVarTempH + 2 * c_ymarg
	GuiControl, Move, % IdHMstyling_T3, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext += TheWidestText + 2 * c_xmarg
	GuiControl, Move, % IdHMstyling_T4, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg
	v_yNext += HofText
	GuiControl, Move, % IdHMstyling_DDL2, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdHMstyling_DDL2
	v_xNext += v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdHMstyling_E2, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdHMstyling_E2
	v_xNext := v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdHMstyling_B2, % "x+" . v_xNext . A_Space . "y+" . v_yNext

	v_xNext := c_xmarg
	GuiControlGet, v_OutVarTemp, Pos, % IdHMstyling_B1
	v_yNext += v_OutVarTempH + 2 * c_ymarg
	GuiControl, Move, % IdHMstyling_T5, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext += TheWidestText + 2 * c_xmarg
	GuiControl, Move, % IdHMstyling_T6, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg
	v_yNext += HofText
	GuiControl, Move, % IdHMstyling_DDL3, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdHMstyling_DDL3
	v_xNext := v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdHMstyling_B3, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	
	GuiControlGet, v_OutputVarTemp, Pos, % IdTTstyling_B3
	v_xNext := v_OutputVarTempX + v_OutputVarTempW + 5 * c_xmarg
	GuiControl, Move, % IdHMstyling_T9, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutputVarTemp, Pos, % IdHMstyling_T9
	v_xNext := v_OutputVarTempX + v_OutputVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdHMstyling_T10, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutputVarTemp, Pos, % IdHMstyling_B3
	v_xNext := v_OutputVarTempX + v_OutputVarTempW + 5 * c_xmarg
	v_OutputVarTemp := v_yNext
	v_yNext += HofText
	GuiControl, Move, % IdHMstyling_LB1, % "x+" . v_xNext . A_Space . "y+" . v_yNext

	v_xNext := c_xmarg
	v_yNext := v_OutputVarTemp
	GuiControlGet, v_OutVarTemp, Pos, % IdHMstyling_B1
	v_yNext += v_OutVarTempH + 2 * c_ymarg
	GuiControl, Move, % IdHMstyling_T7, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext += TheWidestText + 2 * c_xmarg
	GuiControl, Move, % IdHMstyling_T8, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg
	v_yNext += HofText
	GuiControl, Move, % IdHMstyling_DDL4, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdHMstyling_DDL4
	v_xNext := v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdHMstyling_B4, % "x+" . v_xNext . A_Space . "y+" . v_yNext

	v_xNext := c_xmarg
	GuiControlGet, v_OutVarTemp, Pos, % IdHMstyling_B1
	v_yNext += v_OutVarTempH + 2 * c_ymarg
	GuiControl, Move, % IdHMstyling_B5, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdHMstyling_B5
	v_xNext := v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdHMstyling_B6, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdHMstyling_B6
	v_xNext := v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdHMstyling_B7, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	
	GuiControl, Disable, % IdHMstyling_E1
	GuiControl, Disable, % IdHMstyling_E2
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_GuiStyling_DetermineConstraints()
{
	global ;assume-global mode
	local v_OutVarTemp := 0, 	v_OutVarTempX := 0, 	v_OutVarTempY := 0, 	v_OutVarTempW := 0, 	v_OutVarTempH := 0
		,v_OutVarTemp1 := 0, 	v_OutVarTemp1X := 0, 	v_OutVarTemp1Y := 0, 	v_OutVarTemp1W := 0, 	v_OutVarTemp1H := 0
		,v_OutVarTemp2 := 0, 	v_OutVarTemp2X := 0, 	v_OutVarTemp2Y := 0, 	v_OutVarTemp2W := 0, 	v_OutVarTemp2H := 0
		,v_OutVarTemp3 := 0, 	v_OutVarTemp3X := 0, 	v_OutVarTemp3Y := 0, 	v_OutVarTemp3W := 0, 	v_OutVarTemp3H := 0
		,v_OutVarTemp4 := 0, 	v_OutVarTemp4X := 0, 	v_OutVarTemp4Y := 0, 	v_OutVarTemp4W := 0, 	v_OutVarTemp4H := 0
							,v_xNext := 0, 		v_yNext := 0, 			v_wNext := 0, 			v_hNext := 0
		,TheWidestText := 0
	
	GuiControlGet, v_OutVarTemp1, Pos, % IdTTstyling_T1
	GuiControlGet, v_OutVarTemp2, Pos, % IdTTstyling_T3
	GuiControlGet, v_OutVarTemp3, Pos, % IdTTstyling_T5
	GuiControlGet, v_OutVarTemp4, Pos, % IdTTstyling_T7
	TheWidestText := Max(v_OutVarTemp1W, v_OutVarTemp2W, v_OutVarTemp3W, v_OutVarTemp4W)
	
	v_xNext := c_xmarg
	v_yNext := c_ymarg
	GuiControl, Move, % IdTTstyling_T1, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext += TheWidestText + 2 * c_xmarg
	GuiControl, Move, % IdTTstyling_T2, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg
	v_yNext += HofText
	GuiControl, Move, % IdTTstyling_DDL1, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdTTstyling_DDL1
	v_xNext += v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdTTstyling_E1, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdTTstyling_E1
	v_xNext := v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdTTstyling_B1, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	                    
	v_xNext := c_xmarg
	GuiControlGet, v_OutVarTemp, Pos, % IdTTstyling_B1
	v_yNext += v_OutVarTempH + 2 * c_ymarg
	GuiControl, Move, % IdTTstyling_T3, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext += TheWidestText + 2 * c_xmarg
	GuiControl, Move, % IdTTstyling_T4, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg
	v_yNext += HofText
	GuiControl, Move, % IdTTstyling_DDL2, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdTTstyling_DDL2
	v_xNext += v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdTTstyling_E2, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdTTstyling_E2
	v_xNext := v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdTTstyling_B2, % "x+" . v_xNext . A_Space . "y+" . v_yNext

	v_xNext := c_xmarg
	GuiControlGet, v_OutVarTemp, Pos, % IdTTstyling_B1
	v_yNext += v_OutVarTempH + 2 * c_ymarg
	GuiControl, Move, % IdTTstyling_T5, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext += TheWidestText + 2 * c_xmarg
	GuiControl, Move, % IdTTstyling_T6, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg
	v_yNext += HofText
	GuiControl, Move, % IdTTstyling_DDL3, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdTTstyling_DDL3
	v_xNext := v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdTTstyling_B3, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	
	GuiControlGet, v_OutputVarTemp, Pos, % IdTTstyling_B3
	v_xNext := v_OutputVarTempX + v_OutputVarTempW + 5 * c_xmarg
	GuiControl, Move, % IdTTstyling_T9, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutputVarTemp, Pos, % IdTTstyling_T9
	v_xNext := v_OutputVarTempX + v_OutputVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdTTstyling_T10, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutputVarTemp, Pos, % IdTTstyling_B3
	v_xNext := v_OutputVarTempX + v_OutputVarTempW + 5 * c_xmarg
	v_OutputVarTemp := v_yNext
	v_yNext += HofText
	GuiControl, Move, % IdTTstyling_LB1, % "x+" . v_xNext . A_Space . "y+" . v_yNext

	v_xNext := c_xmarg
	v_yNext := v_OutputVarTemp
	GuiControlGet, v_OutVarTemp, Pos, % IdTTstyling_B1
	v_yNext += v_OutVarTempH + 2 * c_ymarg
	GuiControl, Move, % IdTTstyling_T7, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext += TheWidestText + 2 * c_xmarg
	GuiControl, Move, % IdTTstyling_T8, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg
	v_yNext += HofText
	GuiControl, Move, % IdTTstyling_DDL4, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdTTstyling_DDL4
	v_xNext := v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdTTstyling_B4, % "x+" . v_xNext . A_Space . "y+" . v_yNext

	v_xNext := c_xmarg
	GuiControlGet, v_OutVarTemp, Pos, % IdTTstyling_B1
	v_yNext += v_OutVarTempH + 2 * c_ymarg
	GuiControl, Move, % IdTTstyling_B5, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdTTstyling_B5
	v_xNext := v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdTTstyling_B6, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdTTstyling_B6
	v_xNext := v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdTTstyling_B7, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	
	GuiControl, Disable, % IdTTstyling_E1	;future: add options to define other colors
	GuiControl, Disable, % IdTTstyling_E2
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_GuiStyling_LoadValues()	
{
	global	;assume-global mode
	local a_Styling_DDL1 := [TransA["black"], TransA["silver"], TransA["gray"], TransA["white"], TransA["maroon"], TransA["red"], TransA["purple"], TransA["fuchsia"], TransA["green"], TransA["lime"], TransA["olive"], TransA["yellow"], TransA["navy"], TransA["blue"], TransA["teal"], TransA["aqua"], TransA["custom"]]
		,s_Styling_DDL1 := "|"
		,a_Styling_DDL2 := [TransA["black"], TransA["silver"], TransA["gray"], TransA["white"], TransA["maroon"], TransA["red"], TransA["purple"], TransA["fuchsia"], TransA["green"], TransA["lime"], TransA["olive"], TransA["yellow"], TransA["navy"], TransA["blue"], TransA["teal"], TransA["aqua"], TransA["custom"]]
		,s_Styling_DDL2 := "|"
		,a_Styling_DDL3 := ["Arial", "Calibri", "Comic Sans MS", "Consolas", "Courier", "Fixedsys", "Lucida Console", "Microsoft Sans Serif", "Script", "System", "Tahoma", "Times New Roman", "Verdana"]
		,s_Styling_DDL3 := "|"
		,a_Styling_DDL4 := [7, 8, 9, 10, 11, 12, 13, 14, 15, 16]
		,s_Styling_DDL4 := "|"
		,key := 0, value := ""
	
	for key, val in a_Styling_DDL1
		if (val = ini_TTBgrCol)
			s_Styling_DDL1 .= val . "||"
	else
		s_Styling_DDL1 .= val . "|"
	GuiControl,, % IdTTstyling_DDL1, % s_Styling_DDL1
	if (ini_TTBgrCol = "custom")
	{
		GuiControl,, % IdTTstyling_E1, % ini_TTBgrColCus
		GuiControl, Enable, % IdTTstyling_E1
	}
	
	s_Styling_DDL1 := "|"
	for key, val in a_Styling_DDL1
		if (val = ini_HMBgrCol)
			s_Styling_DDL1 .= val . "||"
	else
		s_Styling_DDL1 .= val . "|"
	GuiControl,, % IdHMstyling_DDL1, % s_Styling_DDL1
	if (ini_HMBgrCol = "custom")
	{
		GuiControl,, % IdHMstyling_E1, % ini_HMBgrColCus
		GuiControl, Enable, % IdHMstyling_E1
	}
	
	for key, val in a_Styling_DDL2
		if (val = ini_TTTyFaceCol)
			s_Styling_DDL2 .= val . "||"
	else
		s_Styling_DDL2 .= val . "|"
	GuiControl,, % IdTTstyling_DDL2, % s_Styling_DDL2
	if (ini_TTTyFaceCol = "custom")
	{
		GuiControl,, % IdTTstyling_E2, % ini_TTTyFaceColCus
		GuiControl, Enable, % IdTTstyling_E2
	}
	
	s_Styling_DDL2 := "|"
	for key, val in a_Styling_DDL2
		if (val = ini_HMTyFaceCol)
			s_Styling_DDL2 .= val . "||"
	else
		s_Styling_DDL2 .= val . "|"
	GuiControl,, % IdHMstyling_DDL2, % s_Styling_DDL2
	if (ini_HMTyFaceCol = "custom")
	{
		GuiControl,, % IdHMstyling_E2, % ini_HMTyFaceColCus
		GuiControl, Enable, % IdHMstyling_E2
	}
	
	for key, val in a_Styling_DDL3
		if (val = ini_TTTyFaceFont)
			s_Styling_DDL3 .= val . "||"
	else
		s_Styling_DDL3 .= val . "|"
	GuiControl,, % IdTTstyling_DDL3, % s_Styling_DDL3
	s_Styling_DDL3 := "|"
	for key, val in a_Styling_DDL3
		if (val = ini_HMTyFaceFont)
			s_Styling_DDL3 .= val . "||"
	else
		s_Styling_DDL3 .= val . "|"
	GuiControl,, % IdHMstyling_DDL3, % s_Styling_DDL3
	
	for key, val in a_Styling_DDL4
		if (val = ini_TTTySize)
			s_Styling_DDL4 .= val . "||"
	else
		s_Styling_DDL4 .= val . "|"
	GuiControl,, % IdTTstyling_DDL4, % s_Styling_DDL4
	s_Styling_DDL4 := "|"
	for key, val in a_Styling_DDL4
		if (val = ini_HMTySize)
			s_Styling_DDL4 .= val . "||"
	else
		s_Styling_DDL4 .= val . "|"
	GuiControl,, % IdHMstyling_DDL4, % s_Styling_DDL4
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_TTstyling()
{
	global	;assume-global mode
	local FoundPos := ""
		,Window1X := 0, Window1Y := 0, Window1W := 0, Window1H := 0
		,Window2X := 0, Window2Y := 0, Window2W := 0, Window2H := 0
		,NewWinPosX := 0, NewWinPosY := 0
	
	F_GuiStyling_CreateObjects()
	F_GuiStyling_DetermineConstraints()
	F_GuiHMstyling_DetermineConstraints()
	F_GuiStyling_LoadValues()
		
	if (WinExist("ahk_id" . HS3GuiHwnd) or WinExist("ahk_id" . HS4GuiHwnd))
		WinGetPos, Window1X, Window1Y, Window1W, Window1H, A
	Gui, TTstyling: Show, Hide Center AutoSize
	
	DetectHiddenWindows, On
	WinGetPos, Window2X, Window2Y, Window2W, Window2H, % "ahk_id" . TTstylingHwnd
	DetectHiddenWindows, Off
	if (Window1W)
	{
		NewWinPosX := Round(Window1X + (Window1W / 2) - (Window2W / 2))
		NewWinPosY := Round(Window1Y + (Window1H / 2) - (Window2H / 2))
		Gui, TTstyling: Show, % "AutoSize" . A_Space . "x" . NewWinPosX . A_Space . "y" . NewWinPosY, % A_ScriptName . ":" . A_Space . TransA["Triggerstring tips and hotstring menu styling"]
	}
	else
	{
		if (v_Param = "l")
			Gui, TTstyling: Show, Center AutoSize, % A_ScriptName . ":" . A_Space . TransA["Triggerstring tips and hotstring menu styling"]
		else
			Gui, TTstyling: Show, Center AutoSize, % A_ScriptName . ":" . A_Space . TransA["Triggerstring tips and hotstring menu styling"]
	}
	GuiControl, Hide, % IdTTstyling_LB1	
	GuiControl, Hide, % IdHMstyling_LB1
	F_ButtonTTTestStyling()
	Gui, TDemo: Hide
	F_ButtonHMTestStyling()
	Gui, HDemo: Hide
	return  
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_ShowTriggerstringTips2()
{
	global ;assume-global mode
	local key := 0, value := "", ThisValue := 0, MaxValue := 0, WhichKey := 0, LongestString := "", Window1X := 0, Window1Y := 0, Window1W := 0, Window1H := 0, Window2X := 0, Window2Y := 0, Window2W := 0, Window2H := 0
	
	Gui, TMenuAHK: Destroy
	for key, value in a_Tips
	{
		ThisValue := StrLen(value)
		if (ThisValue > MaxValue)
		{
			MaxValue := ThisValue
			WhichKey := key
			WhichValue := value
		}
	}
	LongestString := WhichValue
	F_GuiTrigTipsMenuDef(a_Tips.Count(), LongestString)
	
	for key, value in a_Tips
		GuiControl,, % Id_LB_TMenuAHK, % value . "|"
	
	if (ini_MHMP = 1)
	{
		if (A_CaretX and A_CaretY)
		{
			MenuX := A_CaretX + 20
			MenuY := A_CaretY - 20
		}
		else
		{
			MouseGetPos, v_MouseX, v_MouseY
			MenuX := v_MouseX + 20
			MenuY := v_MouseY + 20
		}
	}
	if (ini_MHMP = 2) 
	{
		MouseGetPos, v_MouseX, v_MouseY
		MenuX := v_MouseX + 20
		MenuY := v_MouseY + 20
	}
	
	Gui, TMenuAHK: Show, x%MenuX% y%MenuY% NoActivate Hide
	DetectHiddenWindows, On
	WinGetPos, Window2X, Window2Y, Window2W, Window2H, % "ahk_id" . TMenuAHKHwnd
	DetectHiddenWindows, Off
	
	Loop % MonitorCoordinates.Count()
		if ((MenuX >= MonitorCoordinates[A_Index].Left) and (MenuX <= MonitorCoordinates[A_Index].Right))
		{
			Window1X := MonitorCoordinates[A_Index].Left
			Window1H := MonitorCoordinates[A_Index].Height
			Window1Y := MonitorCoordinates[A_Index].Top 
			Window1W := MonitorCoordinates[A_Index].Width
			Break
		}
	if (MenuY + Window2H > Window1Y + Window1H) ;bottom edge of a screen 
		MenuY -= Window2H
	if (MenuX + Window2W > Window1X + Window1W) ;right edge of a screen
		MenuX -= Window2W
	GuiControl, Choose, % Id_LB_TMenuAHK, 1
	Gui, TMenuAHK: Show, x%MenuX% y%MenuY% NoActivate	
	if ((ini_TTTtEn) and (ini_TTTD > 0))
		SetTimer, TurnOff_Ttt, % "-" . ini_TTTD ;, 200 ;Priority = 200 to avoid conflicts with other threads 
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_CheckScriptEncoding()
{	;https://www.autohotkey.com/boards/viewtopic.php?t=65049
	local file := "", RetrievedEncoding := "", FilePos := 0
	
	if (!A_IsCompiled)
	{
		file := FileOpen(A_ScriptFullPath, "r")
		RetrievedEncoding := file.Encoding
		FilePos := File.Pos
		if !(((RetrievedEncoding = "UTF-8") and (FilePos = 3)) or ((RetrievedEncoding = "UTF-16") and (FilePos = 2)))
		{
			MsgBox, 16, % A_ScriptName . ":" . A_Space . TransA["Error"], % TransA["Recognized encoding of the script file:"] 
				. "`n`n" . RetrievedEncoding . A_Space . "no-BOM"
				. "`n`n" . TransA["Required encoding: UTF-8 with BOM. Application will exit now."]
			ExitApp, 3	;no-bom
		}
	}
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_GuiVersionUpdate()
{
	global ;assume-global mode
	local FoundPos := ""
		,Window1X := 0, Window1Y := 0, Window1W := 0, Window1H := 0
		,Window2X := 0, Window2Y := 0, Window2W := 0, Window2H := 0
		,NewWinPosX := 0, NewWinPosY := 0
	
	if (WinExist("ahk_id" . HS3GuiHwnd) or WinExist("ahk_id" . HS3GuiHwnd) or WinExist("ahk_id" . HS4GuiHwnd) or WinExist("ahk_id" . HS4GuiHwnd))
		WinGetPos, Window1X, Window1Y, Window1W, Window1H, A
	Gui, VersionUpdate: Show, Hide Center AutoSize
	
	DetectHiddenWindows, On
	WinGetPos, Window2X, Window2Y, Window2W, Window2H, % "ahk_id" . VersionUpdateHwnd
	DetectHiddenWindows, Off
	if (Window1W)
	{
		NewWinPosX := Round(Window1X + (Window1W / 2) - (Window2W / 2))
		NewWinPosY := Round(Window1Y + (Window1H / 2) - (Window2H / 2))
		Gui, VersionUpdate: Show, % "AutoSize" . A_Space . "x" . NewWinPosX . A_Space . "y" . NewWinPosY, % A_ScriptName . ":" . A_Space . TransA["Version / Update"]
	}
	else
	{
		if (v_Param = "l")
			Gui, VersionUpdate: Show, Center AutoSize, % A_ScriptName . ":" . A_Space . TransA["Version / Update"]
		else
			Gui, VersionUpdate: Show, Center AutoSize, % A_ScriptName . ":" . A_Space . TransA["Version / Update"]
	}
	return  
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
	v_yNext += HofText
	GuiControl, Move, % IdVerUpd3, % "x" . v_xNext . "y" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdVerUpd3
	v_xNext := v_OutVarTempX + v_OutVarTempW + c_xmarg
	GuiControl, Move, % IdVerUpd4, % "x" . v_xNext . "y" . v_yNext
	v_yNext := c_ymarg
	GuiControl, Move, % IdVerUpd2, % "x" . v_xNext . "y" . v_yNext
	v_yNext := v_OutVarTempY + HofText + c_ymarg
	v_xNext := c_xmarg
	GuiControl, Move, % IdVerUpdCheckServ, % "x" . v_xNext . "y" . v_yNext
	v_yNext += HofButton + c_ymarg
	GuiControl, Move, % IdVerUpdDownload, % "x" . v_xNext . "y" . v_yNext
	GuiControlGet, v_OutVarTemp1, Pos, % IdVerUpdCheckServ
	GuiControlGet, v_OutVarTemp2, Pos, % IdVerUpdDownload
	WhichIsWider := Max(v_OutVarTemp1W, v_OutVarTemp2W)
	v_xNext := v_OutVarTemp1X + WhichIsWider + 2 * c_xmarg
	v_yNext := v_OutVarTemp1Y
	GuiControl, Move, % IdVerUpdCheckOnStart, % "x" . v_xNext . "y" . v_yNext
	v_yNext := v_OutVarTemp2Y
	GuiControl, Move, % IdVerUpdDwnlOnStart, % "x" . v_xNext . "y" . v_yNext
	return
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
	Gui,	VersionUpdate: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, 			% c_FontType
	Gui, VersionUpdate: Add, 	Text,    	x0 y0 HwndIdVerUpd1,											% TransA["Local version:"]
	Gui, VersionUpdate: Add, 	Text,    	x0 y0 HwndIdVerUpd2, 										% AppVersion
	Gui, VersionUpdate: Add, 	Text,    	x0 y0 HwndIdVerUpd3,										% TransA["Repository version:"]
	Gui, VersionUpdate: Add, 	Text,    	x0 y0 HwndIdVerUpd4, 										% ServerVer
	Gui, VersionUpdate: Add, 	Button,  	x0 y0 HwndIdVerUpdCheckServ gF_VerUpdCheckServ,					% TransA["Check repository version"]
	Gui, VersionUpdate: Add, 	Button,  	x0 y0 HwndIdVerUpdDownload  gF_VerUpdDownload,					% TransA["Download repository version"]
	Gui, VersionUpdate: Add,		Checkbox,	x0 y0 HwndIdVerUpdCheckOnStart gF_CheckUpdOnStart Checked%ini_CheckRepo%,	% TransA["Check if update is available on startup?"]
	Gui, VersionUpdate: Add,		Checkbox, x0 y0 HwndIdVerUpdDwnlOnStart gF_DwnlUpdOnStart Checked%ini_DownloadRepo%,	% TransA["Download if update is available on startup?"]
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_DwnlUpdOnStart()	
{
	global	;assume-global mode
	ini_DownloadRepo := !ini_DownloadRepo
	IniWrite, % ini_DownloadRepo, % HADConfig, Configuration, DownloadRepo
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_CheckUpdOnStart() 
{
	global	;assume-global mode
	ini_CheckRepo := !ini_CheckRepo
	Iniwrite, % ini_CheckRepo, % HADConfig, Configuration, CheckRepo
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_VerUpdDownload()	
{
	global	;assume-global mode
	local	URLscript := "https://raw.githubusercontent.com/mslonik/Hotstrings/master/Hotstrings/Hotstrings.ahk"
			,URLexe := "https://github.com/mslonik/Hotstrings/raw/master/Hotstrings/Hotstrings.exe"
			,whr := "", Result := "", e := ""
	
	if (A_IsCompiled)
	{
		try
			FileMove, % A_ScriptFullPath, temp.exe
		Catch e
			MsgBox, , Error, % "ErrorLevel" . A_Tab . ErrorLevel
					. "`n`n" . "A_LastError" . A_Tab . A_LastError
					. "`n`n" . "Exception" . A_Tab . e
		try
			URLDownloadToFile, % URLexe, % A_ScriptFullPath
		catch
			MsgBox, 16, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["error"], % A_ThisFunc . A_Space TransA["caused problem on line URLDownloadToFile."]
		if (!ErrorLevel)		
		{
			MsgBox, 68, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["The application"] . A_Space . A_ScriptName . A_Space . TransA["was successfully downloaded."]
			. "`n" . TransA["The default language file (English.txt) will be deleted (it will be automatically recreated after restart). However if you use localized version of language file, you'd need to download it manually."]
			. "`n`n" . TransA["Would you like now to reload it in order to run the just downloaded version?"]
			IfMsgBox, Yes
			{
				FileDelete, % A_ScriptDir . "\Languages\English.txt" 	
				Gui, VersionUpdate: Hide
				F_Reload()
			}
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
			MsgBox, 68, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["The script"] . A_Space . A_ScriptName . A_Space . TransA["was successfully downloaded."]
			. "`n" . TransA["The default language file (English.txt) will be deleted (it will be automatically recreated after restart). However if you use localized version of language file, you'd need to download it manually."]
			. "`n`n" . TransA["Would you like now to reload it in order to run the just downloaded version?"]
			IfMsgBox, Yes
			{
				FileDelete, % A_ScriptDir . "\Languages\English.txt" 		
				Gui, VersionUpdate: Hide
				F_Reload()
			}
			return
		}
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_VerUpdCheckServ(param*)	
{
	global	;assume-global mode
	local	whr := "", URLscript := "https://raw.githubusercontent.com/mslonik/Hotstrings/master/Hotstrings/Hotstrings.ahk", ToBeFiltered := "", ServerVer := "", StartingPos := 0
	
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
				MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["On start-up the local version of"] . A_Space . SubStr(A_ScriptName, 1, -4) . A_Space . TransA["was compared with repository version and difference was discovered:"] 
					. "`n`n" . TransA["Local version:"]  . A_Tab . A_Tab . AppVersion
					. "`n" .   TransA["Repository version:"] . A_Tab . A_Tab . ServerVer
			whr := ""		
			return
		Case "ReturnResult":
			whr := ""
			if (ServerVer != AppVersion)
				return true
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
	v_yNext := c_ymarg
	GuiControl, Move, % IdShortDefT1, % "x" . v_xNext . "y" . v_yNext		;Call Graphical User Interface
	GuiControlGet, v_OutVarTemp, Pos, % IdShortDefT1
	v_xNext := v_OutVarTempX + v_OutVarTempW + c_xmarg
	GuiControl, Move, % IdShortDefT4, % "x" . v_xNext . "y" . v_yNext		;ⓘ
	v_xNext := c_xmarg
	v_yNext += 2 * HofText
	GuiControl, Move, % IdShortDefT2, % "x" . v_xNext . "y" . v_yNext		;Current shortcut (hotkey):
	GuiControlGet, v_OutVarTemp, Pos, % IdShortDefT2
	v_xNext := v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdShortDefT3, % "x" . v_xNext . "y" . v_yNext		;% ShortcutLong
	v_xNext := c_xmarg
	v_yNext += 2 * HofText
	GuiControl, Move, % IdShortDefT5, % "x" . v_xNext . "y" . v_yNext		;New shortcut (hotkey)
	GuiControlGet, v_OutVarTemp, Pos, % IdShortDefT5
	v_xNext := v_OutVarTempX + v_OutVarTempW + c_xmarg
	GuiControl, Move, % IdShortDefT6, % "x" . v_xNext . "y" . v_yNext		;ⓘ
	v_xNext := c_xmarg
	v_yNext += 2 * HofText
	GuiControl, Move, % IdShortDefCB1, % "x" . v_xNext . "y" . v_yNext		;Windows key modifier
	GuiControlGet, v_OutVarTemp, Pos, % IdShortDefCB1						
	v_xNext := v_OutVarTempX + v_OutVarTempW + c_xmarg
	GuiControl, Move, % IdShortDefH1, % "x" . v_xNext . "y" . v_yNext		;HotkeyVar
	v_xNext := c_xmarg
	v_yNext := v_OutVarTempY + v_OutVarTempH
	GuiControl, Move, % IdShortDefCB2, % "x" . v_xNext . "y" . v_yNext		;Tilde (~) key modifier
	GuiControlGet, v_OutVarTemp1, Pos, % IdShortDefH1						;reserve more space for text string
	v_wNext := v_OutVarTemp1W
	GuiControl, Move, % IdShortDefT3, % "w" . v_wNext
	GuiControlGet, v_OutVarTemp, Pos, % IdShortDefCB2
	v_xNext := v_OutVarTempX + v_OutVarTempW 
	v_yNext := v_OutVarTempY 
	GuiControl, Move, % IdShortDefT7, % "x" . v_xNext . "y" . v_yNext
	v_xNext := c_xmarg
	v_yNext := v_OutVarTempY + v_OutVarTempH + HofText
	GuiControl, Move, % IdShortDefB1, % "x" . v_xNext . "y" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdShortDefB1
	v_xNext := v_OutVarTempX + v_OutVarTempW + c_xmarg
	GuiControl, Move, % IdShortDefB2, % "x" . v_xNext . "y" . v_yNext
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_ParseHotkey(ini_HK_Main, space*)
{
	local Mini := false, ShortcutLong := "", HotkeyVar := ""
	
	if (ini_HK_Main != "none")
		Loop, Parse, ini_HK_Main
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
					ShortcutLong .= "Ctrl"
				Case "!":	
					Mini := true
					ShortcutLong .= "Alt"	
				Case "+":	
					Mini := true
					ShortcutLong .= "Shift"
				Case "#":
					Mini := true
					ShortcutLong .= "Win"
				Default:
					StringUpper, HotkeyVar, A_LoopField 
					ShortcutLong .= HotkeyVar
			}
			if (Mini)
			{
				if (space[1])
					if (ShortcutLong = "~")
						Continue
					else
						ShortcutLong .= " + "
				else
					ShortcutLong .= "+"
			}
		}
	else
		ShortcutLong := "None"
	return ShortcutLong
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_GuiShortDef_CreateObjects()
{
	global	;assume-global mode
	local	IfWinModifier := false, IfTildeModifier := false, Mini := false, HotkeyVar := ""
	
	;1. Prepare Gui
	Gui, ShortDef: New, 	-Resize +HwndShortDefHwnd +Owner -MaximizeBox -MinimizeBox
	Gui, ShortDef: Margin,	% c_xmarg, % c_ymarg
	Gui,	ShortDef: Color,	% c_WindowColor, % c_ControlColor
	
	;2. Prepare all text objects according to mock-up.
	Gui,	ShortDef: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, 			% c_FontType
	Switch A_ThisMenuItem
	{
		Case % TransA["Call Graphical User Interface"]:
		Gui, ShortDef: Add, 	Text,    	x0 y0 HwndIdShortDefT1,										% TransA["Call Graphical User Interface"]
		Case % TransA["Copy clipboard content into ""Enter hotstring"""]:	
		Gui, ShortDef: Add, 	Text,    	x0 y0 HwndIdShortDefT1,										% TransA["Copy clipboard content into ""Enter hotstring"""]
		Case % TransA["Undo the last hotstring"]:
		Gui, ShortDef: Add, 	Text,    	x0 y0 HwndIdShortDefT1,										% TransA["Undo the last hotstring"]
	}
	Gui, ShortDef: Add, 	Text,    	x0 y0 HwndIdShortDefT2,											% TransA["Current shortcut (hotkey):"]
	
	Switch A_ThisMenuItem
	{
		Case % TransA["Call Graphical User Interface"]:
		Gui, ShortDef: Add, 	Text,    	x0 y0 HwndIdShortDefT3, 										% F_ParseHotkey(ini_HK_Main, "space")
		Case % TransA["Copy clipboard content into ""Enter hotstring"""]:	
		Gui, ShortDef: Add, 	Text,    	x0 y0 HwndIdShortDefT3, 										% F_ParseHotkey(ini_HK_IntoEdit, "space")
		Case % TransA["Undo the last hotstring"]:
		Gui, ShortDef: Add, 	Text,    	x0 y0 HwndIdShortDefT3, 										% F_ParseHotkey(ini_HK_UndoLH, "space")
	}
	Gui, ShortDef: Font, 	% "s" . c_FontSize + 2 . A_Space . "cBlue",								% c_FontType
	Gui, ShortDef: Add, 	Text,    	x0 y0 HwndIdShortDefT4,										ⓘ
	Gui,	ShortDef: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, 			% c_FontType
	Switch A_ThisMenuItem
	{
		Case % TransA["Call Graphical User Interface"]:
			F_HK_CallGUIInfo := func("F_ShowLongTooltip").bind(TransA["F_HK_CallGUIInfo"])
			GuiControl +g, % IdShortDefT4, % F_HK_CallGUIInfo
			if (InStr(ini_HK_Main, "#"))
			{
				IfWinModifier := true
				HotkeyVar := StrReplace(ini_HK_Main, "#")
			}
			else
				HotkeyVar := ini_HK_Main
			if (InStr(ini_HK_Main, "~"))
			{
				IfTildeModifier := true
				HotkeyVar := StrReplace(ini_HK_Main, "~")
			}
			else
				HotkeyVar := ini_HK_Main
		Case % TransA["Copy clipboard content into ""Enter hotstring"""]:
			F_HK_ClipCopyInfo := func("F_ShowLongTooltip").bind(TransA["F_HK_ClipCopyInfo"])
			GuiControl +g, % IdShortDefT4, % F_HK_ClipCopyInfo
			if (InStr(ini_HK_IntoEdit, "#"))
			{
				IfWinModifier := true
				HotkeyVar := StrReplace(ini_HK_IntoEdit, "#")
			}
			else
				HotkeyVar := ini_HK_IntoEdit
			if (InStr(ini_HK_IntoEdit, "~"))
			{
				IfTildeModifier := true
				HotkeyVar := StrReplace(ini_HK_IntoEdit, "~")
			}
			else
				HotkeyVar := ini_HK_IntoEdit
		Case % TransA["Undo the last hotstring"]:
			F_HK_UndoInfo := func("F_ShowLongTooltip").bind(TransA["F_HK_UndoInfo"])
			GuiControl +g, % IdShortDefT4, % F_HK_UndoInfo
			if (InStr(ini_HK_UndoLH, "#"))
			{
				IfWinModifier := true
				HotkeyVar := StrReplace(ini_HK_UndoLH, "#")
			}
			else
				HotkeyVar := ini_HK_UndoLH
			if (InStr(ini_HK_UndoLH, "~"))
			{
				IfTildeModifier := true
				HotkeyVar := StrReplace(ini_HK_UndoLH, "~")
			}
			else
				HotkeyVar := ini_HK_UndoLH
	}
	
	Gui, ShortDef: Add, 	Text,    	x0 y0 HwndIdShortDefT5,										% TransA["New shortcut (hotkey)"] . ":"
	Gui, ShortDef: Font, 	% "s" . c_FontSize + 2 . A_Space . "cBlue",								% c_FontType
	Gui, ShortDef: Add,		Text,	x0 y0 HwndIdShortDefT6,										ⓘ
	Gui,	ShortDef: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, 			% c_FontType
	F_HK_GeneralInfo := func("F_ShowLongTooltip").bind(TransA["F_HK_GeneralInfo"])
	GuiControl +g, % IdShortDefT6, % F_HK_GeneralInfo
	Gui, ShortDef: Add,		Checkbox,	x0 y0 HwndIdShortDefCB1 Checked%IfWinModifier%,					% TransA["Windows key modifier"]
	Gui, ShortDef: Add,		Hotkey,	x0 y0 HwndIdShortDefH1,										% HotkeyVar
	Gui, ShortDef: Add,		Checkbox, x0 y0 HwndIdShortDefCB2 Checked%IfTildeModifier%,					% TransA["Tilde (~) key modifier"]
	Gui, ShortDef: Font, 	% "s" . c_FontSize + 2 . A_Space . "cBlue",								% c_FontType
	Gui, ShortDef: Add,		Text,	x0 y0 HwndIdShortDefT7,										ⓘ
	Gui,	ShortDef: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, 			% c_FontType
	F_HK_TildeModInfo := func("F_ShowLongTooltip").bind(TransA["F_HK_TildeModInfo"])
	GuiControl +g, % IdShortDefT7, % F_HK_TildeModInfo
	Gui, ShortDef: Add, 	Button,  	x0 y0 HwndIdShortDefB1 gF_ShortDefB1_SaveHotkey,					% TransA["Save hotkey"]
	Gui, ShortDef: Add, 	Button,  	x0 y0 HwndIdShortDefB2 gF_ShortDefB2_RestoreHotkey,				% TransA["Restore default hotkey"]
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_ShortDefB2_RestoreHotkey()
{
	global	;assume-global mode
	local	OldHotkey := "", WindowKey := false
	
	GuiControlGet, OldHotkey, , % IdShortDefT3
	OldHotkey := StrReplace(OldHotkey, "Shift", "+")
	OldHotkey := StrReplace(OldHotkey, "Ctrl", "^")
	OldHotkey := StrReplace(OldHotkey, "Alt", "!")
	OldHotkey := StrReplace(OldHotkey, "Win", "#")
	OldHotkey := StrReplace(OldHotkey, "+")
	OldHotkey := StrReplace(OldHotkey, " ")
	Switch A_ThisMenuItem
	{
		Case % TransA["Call Graphical User Interface"]:
			if (OldHotkey != "none")	
				Hotkey, % OldHotkey, L_GUIInit, Off
			ini_HK_Main := "#^h"
			Hotkey, % ini_HK_Main, L_GUIInit, On
			GuiControl, , % IdShortDefT3, % F_ParseHotkey(ini_HK_Main, "space")
			IniWrite, % ini_HK_Main, % HADConfig, Configuration, HK_Main
		Case % TransA["Copy clipboard content into ""Enter hotstring"""]:
			if (OldHotkey != "none")
			{
				Hotkey, IfWinExist, % "ahk_id" HS3GuiHwnd
				Hotkey, % OldHotkey, F_PasteFromClipboard, Off
				Hotkey, IfWinExist, % "ahk_id" HS4GuiHwnd
				Hotkey, % OldHotkey, F_PasteFromClipboard, Off
				Hotkey, IfWinExist
			}
			ini_HK_IntoEdit := "~^c"
			Hotkey, IfWinExist, % "ahk_id" HS3GuiHwnd
			Hotkey, % ini_HK_IntoEdit, F_PasteFromClipboard, On
			Hotkey, IfWinExist, % "ahk_id" HS4GuiHwnd
			Hotkey, % ini_HK_IntoEdit, F_PasteFromClipboard, On
			Hotkey, IfWinExist
			GuiControl, , % IdShortDefT3, % F_ParseHotkey(ini_HK_IntoEdit, "space")
			IniWrite, % ini_HK_IntoEdit, % HADConfig, Configuration, HK_IntoEdit
		Case % TransA["Undo the last hotstring"]:
			if (ini_HotstringUndo)
			{
				if (OldHotkey != "none")
					Hotkey, % OldHotkey, 	F_Undo, Off
				ini_HK_UndoLH := "~^F12"
				Hotkey, % ini_HK_UndoLH, F_Undo, On
			}
			else
			{
				if (OldHotkey != "none")
					Hotkey, % OldHotkey, 	F_Undo, Off
				ini_HK_UndoLH := "~^F12"
				Hotkey, % ini_HK_UndoLH, F_Undo, Off
			}
			GuiControl, , % IdShortDefT3, % F_ParseHotkey(ini_HK_UndoLH, "space")
			IniWrite, % ini_HK_UndoLH, % HADConfig, Configuration, HK_UndoLH
	}
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_ShortDefB1_SaveHotkey()	
{
	global	;assume-global mode
	local	OldHotkey := "", WindowKey := false, TildeKey := false
	
	GuiControlGet, WindowKey, , 	% IdShortDefCB1
	GuiControlGet, TildeKey, , 	% IdShortDefCB2
	Switch A_ThisMenuItem
	{
		Case % TransA["Call Graphical User Interface"]:
			GuiControlGet, ini_HK_Main, , % IdShortDefH1
			if (WindowKey)
				ini_HK_Main := "#" . ini_HK_Main
			if (TildeKey)
				ini_HK_Main := "~" . ini_HK_Main
			if (ini_HK_Main != "")
				IniWrite, % ini_HK_Main, % HADConfig, Configuration, HK_Main
			else
			{
				ini_HK_Main := "none"
				IniWrite, % ini_HK_Main, % HADConfig, Configuration, HK_Main
			}
		Case % TransA["Copy clipboard content into ""Enter hotstring"""]:
			GuiControlGet, ini_HK_IntoEdit, , % IdShortDefH1
			if (WindowKey)
				ini_HK_IntoEdit := "#" . ini_HK_IntoEdit
			if (TildeKey)
				ini_HK_IntoEdit := "~" . ini_HK_IntoEdit
			if (ini_HK_IntoEdit != "")
				IniWrite, % ini_HK_IntoEdit, % HADConfig, Configuration, HK_IntoEdit
			else
			{
				ini_HK_IntoEdit := "none"
				Iniwrite, % ini_HK_IntoEdit, % HADConfig, Configuration, HK_IntoEdit
			}
		Case % TransA["Undo the last hotstring"]:
			GuiControlGet, ini_HK_UndoLH, , % IdShortDefH1
			if (WindowKey)
				ini_HK_UndoLH := "#" . ini_HK_UndoLH
			if (TildeKey)
				ini_HK_UndoLH := "~" . ini_HK_UndoLH
			if (ini_HK_UndoLH != "")
				IniWrite, % ini_HK_UndoLH, % HADConfig, Configuration, HK_UndoLH
			else
			{
				ini_HK_UndoLH := "none"
				IniWrite, % ini_HK_UndoLH, % HADConfig, Configuration, HK_UndoLH
			}
	}
	GuiControlGet, OldHotkey, , % IdShortDefT3
	;OldHotkey := RegExReplace(OldHotkey, "(Ctrl)|(Shift)|(Win)|(\+)|( )")	;future: trick from forum after my question
	OldHotkey := StrReplace(OldHotkey, "Shift", "+")
	OldHotkey := StrReplace(OldHotkey, "Ctrl", "^")
	OldHotkey := StrReplace(OldHotkey, "Alt", "!")
	OldHotkey := StrReplace(OldHotkey, "Win", "#")
	OldHotkey := StrReplace(OldHotkey, "+")
	OldHotkey := StrReplace(OldHotkey, " ")
	Switch A_ThisMenuItem
	{
		Case % TransA["Call Graphical User Interface"]:
		GuiControl, , % IdShortDefT3, % F_ParseHotkey(ini_HK_Main, "space")
		Hotkey, % OldHotkey, L_GUIInit, Off
		if (ini_HK_Main != "none")
			Hotkey, % ini_HK_Main, L_GUIInit, On
		Case % TransA["Copy clipboard content into ""Enter hotstring"""]:
			GuiControl, , % IdShortDefT3, % F_ParseHotkey(ini_HK_IntoEdit, "space")
			Hotkey, IfWinExist, % "ahk_id" HS3GuiHwnd
			Hotkey, % OldHotkey, F_PasteFromClipboard, Off
			Hotkey, IfWinExist, % "ahk_id" HS4GuiHwnd
			Hotkey, % OldHotkey, F_PasteFromClipboard, Off
			Hotkey, IfWinExist
			if (ini_HK_IntoEdit != "none")
			{
				Hotkey, IfWinExist, % "ahk_id" HS3GuiHwnd
				Hotkey, % ini_HK_IntoEdit, F_PasteFromClipboard, On
				Hotkey, IfWinExist, % "ahk_id" HS4GuiHwnd
				Hotkey, % ini_HK_IntoEdit, F_PasteFromClipboard, On
				Hotkey, IfWinExist
			}
		Case % TransA["Undo the last hotstring"]:
			MsgBox,, Debug, % ini_HK_UndoLH
			GuiControl, , % IdShortDefT3, % F_ParseHotkey(ini_HK_UndoLH, "space")
			if (ini_HotstringUndo)
			{
				Hotkey, % OldHotkey, 	F_Undo, Off
				if (ini_HK_UndoLH != "none")
					Hotkey, % ini_HK_UndoLH, F_Undo, On
			}
			else
			{
				Hotkey, % OldHotkey, 	F_Undo, Off
				if (ini_HK_UndoLH != "none")
					Hotkey, % ini_HK_UndoLH, F_Undo, Off
			}
	}
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_GuiShortDef()	
{
	global	;assume-global mode
	local FoundPos := ""
		,Window1X := 0, Window1Y := 0, Window1W := 0, Window1H := 0
		,Window2X := 0, Window2Y := 0, Window2W := 0, Window2H := 0
		,NewWinPosX := 0, NewWinPosY := 0
	
	F_GuiShortDef_CreateObjects()
	F_GuiShortDef_DetermineConstraints()
	
	if (WinExist("ahk_id" . HS3GuiHwnd) or WinExist("ahk_id" . HS3GuiHwnd) or WinExist("ahk_id" . HS4GuiHwnd) or WinExist("ahk_id" . HS4GuiHwnd))
		WinGetPos, Window1X, Window1Y, Window1W, Window1H, A
	Gui, ShortDef: Show, Hide Center AutoSize
	
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
		if (v_Param = "l")
			Gui, ShortDef: Show, Center AutoSize, % A_ScriptName . ":" . A_Space . TransA["Shortcut (hotkey) definition"]
		else
			Gui, ShortDef: Show, Center AutoSize, % A_ScriptName . ":" . A_Space . TransA["Shortcut (hotkey) definition"]
	}
	return  
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_Sort_a_Triggers()
{	;sort now a_Triggers() so it's not necessary each time when user gets triggerstring tips; it should speed-up process significantly
	global	;assume-global mode
	local	key := "", value := "", s_SelectedTriggers := ""

	if (ini_TipsSortAlphabetically)
	{
		;a_SelectedTriggers := F_SortArrayAlphabetically(a_SelectedTriggers)
		for key, value in a_Triggers	;table to string Conversion
			s_SelectedTriggers .= value . "`n"
		Sort, s_SelectedTriggers
		Loop, Parse, s_SelectedTriggers, `n	;string to table Conversion
			a_Triggers[A_Index] := A_LoopField
	}
	if (ini_TipsSortByLength)
		a_Triggers := F_SortArrayByLength(a_Triggers)

	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_DownloadPublicLibraries()
{
	global	;assume-global mode
	local	ToBeFiltered := "",	Result := "",	ToBeDownloaded := [], DownloadedFile := "", whr := ""
			,URLconst 	:= "https://gitHub.com/mslonik/Hotstrings/blob/master/Hotstrings/Libraries/", temp := ""
			,URLraw 		:= "https://raw.githubusercontent.com/mslonik/Hotstrings/master/Hotstrings/Libraries/"
	
	whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	whr.Open("GET", URLconst, true)
	whr.Send()	; Using 'true' above and the call below allows the script to remain responsive.
	whr.WaitForResponse()
	ToBeFiltered := whr.ResponseText
	
	Loop, Parse, ToBeFiltered, `n
		if (InStr(A_LoopField, ".csv"))
		{
			RegExMatch(A_LoopField, "i)v"">.*.csv", Result)
			ToBeDownloaded.Push(SubStr(Result, 4))
		}
	
	for key, value in ToBeDownloaded
	{
		temp := URLraw . value
		if (FileExist(HADL . "\" . value))
		{
			MsgBox, 51, % SubStr(A_ScriptName, 1, -4) .  ":" . A_Space . TransA["warning"], % value . "`n`n" . TransA["The file which you want to download from Internet, already exists on your local harddisk. Are you sure you want to download it?"]
			IfMsgBox, Cancel
				return
			IfMsgBox, No
				Continue
			URLDownloadToFile, % temp, % HADL . "\" . value
		}
		else
		{
			URLDownloadToFile, % temp, % HADL . "\" . value
			MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["Public library:"] . A_Tab . value . "`n`n" . TransA["has been downloaded to the location"] 
			. "`n`n" . HADL
		}
	}
	MsgBox, 68, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["After downloading libraries aren't automaticlly loaded into memory. Would you like to upload content of libraries folder? into memory?"]
	IfMsgBox, Yes
	{
		F_LoadHotstringsFromLibraries()
		F_Sort_a_Triggers()
		F_ValidateIniLibSections()
		F_RefreshListOfLibraries()
		F_RefreshListOfLibraryTips()
		F_UpdateSelHotLibDDL()
		F_Searching("Reload")			;prepare content of Search tables
	}
	return
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
		Iniwrite, % ini_ShowIntro, % HADConfig, Configuration, ShowIntro
	}
return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_GuiShowIntro()
{
	global	;assume-global mode
	local	v_xNext := 0,	v_yNext := 0, v_wNext := 0,	v_hNext := 0
			,v_OutVarTemp := 0, 	v_OutVarTempX := 0, 	v_OutVarTempY := 0, 	v_OutVarTempW := 0, 	v_OutVarTempH := 0
			,v_OutVarTemp1 := 0, 	v_OutVarTemp1X := 0, 	v_OutVarTemp1Y := 0, 	v_OutVarTemp1W := 0, 	v_OutVarTemp1H := 0
	
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
	Gui, ShowIntro: Add, 	Button,  x0 y0 HwndIdIntroOkButton gF_IntroOkButton,					% TransA["OK"]
	Gui, ShowIntro: Add,	Picture, x0 y0 HwndIdAboutPicture w96 h96, 							% AppIcon
	Gui, ShowIntro: Add,	CheckBox, x0 y0 HwndIdIntroCheckbox gF_ShowIntroCheckbox,				% TransA["Show Introduction window after application is restarted?"]
	
	;3. Determine constraints
	v_xNext := c_xmarg
	v_yNext := c_ymarg
	GuiControl, Move,			% IdIntroLine1, % "x" . v_xNext . "y" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdIntroLine1
	v_yNext := v_OutVarTempY + v_OutVarTempH + 2 * c_ymarg
	GuiControl, Move,			% IdIntroLine2, % "x" . v_xNext . "y" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdIntroLine2
	v_yNext := v_OutVarTempY + v_OutVarTempH + 2 * c_ymarg
	GuiControl, Move,			% IdIntroLine3, % "x" . v_xNext . "y" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdIntroLine3
	v_xNext := v_OutVarTempW // 2
	v_yNext := v_OutVarTempY + v_OutVarTempH + 2 * c_ymarg
	GuiControlGet, v_OutVarTemp1, Pos, % IdIntroOkButton
	v_wNext := v_OutVarTemp1W + 2 * c_xmarg
	GuiControl, Move,			% IdIntroOkButton, % "x" . v_xNext . "y" . v_yNext . "w" . v_wNext
	v_xNext := v_OutVarTempX + v_OutVarTempW + 10 * c_xmarg
	v_yNext := v_OutVarTempY
	GuiControl, Move,			% IdAboutPicture, % "x" . v_xNext . "y" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdIntroOkButton
	v_xNext := c_xmarg
	v_yNext := v_OutVarTempY + v_OutVarTempH + c_ymarg
	GuiControl, Move,			% IdIntroCheckbox, % "x" . v_xNext . "y" . v_yNext
	F_ShowIntroCheckbox()
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_ShowIntroCheckbox()
{
	global	;assume-global mode
	static FirstRun := true
	
	Gui, ShowIntro: Submit, NoHide
	if (FirstRun)
	{
		GuiControl,, % IdIntroCheckbox, % ini_ShowIntro
		FirstRun := false
	}
	else
	{
		GuiControlGet, ini_ShowIntro,, % IdIntroCheckbox
		IniWrite, % ini_ShowIntro, % HADConfig, Configuration, ShowIntro
	}
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_IntroOkButton()
{
	Gui, ShowIntro: Destroy
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_ShowLongTooltip(string)
{
	ToolTip, % StrReplace(string, "``n", "`n")
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_DetermineMonitors()	; Multi monitor environment, initialization of monitor width and height parameters
{
	global	;assume-global mode
	local	NoOfMonitors
			,Temp := 0, TempLeft := 0, TempRight := 0, TempTop := 0, TempBottom := 0, TempWidth := 0, TempHeight := 0
	
	MonitorCoordinates := {}
	
	SysGet, NoOfMonitors, MonitorCount	
	Loop, % NoOfMonitors
	{
		SysGet, Temp, Monitor, % A_Index
		MonitorCoordinates[A_Index] 			:= {}
		MonitorCoordinates[A_Index].Left 		:= TempLeft
		MonitorCoordinates[A_Index].Right 		:= TempRight
		MonitorCoordinates[A_Index].Top 		:= TempTop
		MonitorCoordinates[A_Index].Bottom 	:= TempBottom
		MonitorCoordinates[A_Index].Width 		:= TempRight - TempLeft
		MonitorCoordinates[A_Index].Height 	:= TempBottom - TempTop
	}
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_Undo()
{
	global	;assume-global mode
	local	TriggerOpt := "", HowManyBackSpaces := 0, HowManyBackSpaces2 := 0
			,ThisHotkey := A_ThisHotkey, PriorHotkey := A_PriorHotkey, OrigTriggerstring := ""

	if (ini_UHTtEn and v_TypedTriggerstring and (ThisHotkey != PriorHotkey))
	{	
		TriggerOpt := SubStr(RegExReplace(v_TypedTriggerstring, ".*\K:.*"), 2)
		OrigTriggerstring := RegExReplace(v_TypedTriggerstring, ":.*:")
		if (!(InStr(TriggerOpt, "*")) and !(InStr(TriggerOpt, "O")))
			Send, {BackSpace}
		if (v_UndoHotstring)
		{
			if (v_LOF = "SI")
			{
				if (InStr(v_UndoHotstring, "{Enter}", false))
					v_UndoHotstring := StrReplace(v_UndoHotstring, "{Enter}", "", HowManyBackSpaces)
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
					HowManyBackSpaces += HowManyBackSpaces2
				}
				if (InStr(v_UndoHotstring, "``t"))
				{
					v_UndoHotstring := StrReplace(v_UndoHotstring, "``t", "", HowManyBackSpaces2)
					HowManyBackSpaces += HowManyBackSpaces2
				}
			}
			v_UndoHotstring := F_PrepareUndo(v_UndoHotstring)
			v_UndoHotstring := RegExReplace(v_UndoHotstring, "{U+.*}", " ")
			HowManyBackSpaces += StrLenUnicode(v_UndoHotstring)
			Send, % "{BackSpace " . HowManyBackSpaces . "}"
			Loop, Parse, OrigTriggerstring
				Switch A_LoopField
			{
				Case "^", "+", "!", "#", "{", "}":
				SendRaw, % A_LoopField
				Default:
				Send, % A_LoopField
			}
		}
		if (!(InStr(TriggerOpt, "*")) and !(InStr(TriggerOpt, "O"))) 
			Send, % A_EndChar
		
		if (ini_UHTtEn)
		{
			ToolTip, ,, , 4	;Basic triggerstring was triggered
			if (ini_UHTP = 1)	;Undo Hotstring Tooltip Position
			{
				if (A_CaretX and A_CaretY)
				{
					ToolTip, % TransA["Undid the last hotstring"], % A_CaretX + 20, % A_CaretY - 20, 6
					if (ini_UHTD > 0)
						SetTimer, TurnOff_UHE, % "-" . ini_UHTD, 60 ;Priority = 60 to avoid conflicts with other threads 
				}
				else
				{
					MouseGetPos, v_MouseX, v_MouseY
					ToolTip, % TransA["Undid the last hotstring"], % v_MouseX + 20, % v_MouseY - 20, 6
					if (ini_UHTD > 0)
						SetTimer, TurnOff_UHE, % "-" . ini_UHTD, 60 ;Priority = 60 to avoid conflicts with other threads 
				}
			}
			if (ini_UHTP = 2)
			{
				MouseGetPos, v_MouseX, v_MouseY
				ToolTip, % TransA["Undid the last hotstring"], % v_MouseX + 20, % v_MouseY - 20, 6
				if (ini_UHTD > 0)
					SetTimer, TurnOff_UHE, % "-" . ini_UHTD, 60 ;Priority = 60 to avoid conflicts with other threads 
			}
		}
		
		if (ini_UHSEn)	;Basic Hotstring % TransA["Sound Enable"]
			SoundBeep, % ini_UHSF, % ini_UHSD
		
		v_TypedTriggerstring := ""
		v_HotstringFlag := true
	}
	else
	{
		;ToolTip,
		Gui, TMenuAHK: Destroy
		If InStr(ThisHotkey, "^z")
			SendInput, ^z
		else if InStr(ThisHotkey, "!BackSpace")
			SendInput, !{BackSpace}
	}
	return
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
	global	;assume-global mode
	local 	v_MouseX := 0, v_MouseY := 0
	if (ini_OHTtEn)
	{
		if (ini_OHTP = 1)
		{
			if (A_CaretX and A_CaretY)
			{
				ToolTip, % TransA["Hotstring was triggered!"] . A_Space . "[" . F_ParseHotkey(ini_HK_UndoLH) . "]" . A_Space . TransA["to undo."], % A_CaretX + 20, % A_CaretY - 20, 4
				if (ini_OHTD > 0)
					SetTimer, TurnOff_OHE, % "-" . ini_OHTD, 40 ;Priority = 40 to avoid conflicts with other threads 
			}
			else
			{
				MouseGetPos, v_MouseX, v_MouseY
				ToolTip, % TransA["Hotstring was triggered!"] . A_Space . "[" . F_ParseHotkey(ini_HK_UndoLH) . "]" . A_Space . TransA["to undo."], % v_MouseX + 20, % v_MouseY - 20, 4
				if (ini_OHTD > 0)
					SetTimer, TurnOff_OHE, % "-" . ini_OHTD, 40 ;Priority = 40 to avoid conflicts with other threads 
			}
		}
		if (ini_OHTP = 2)
		{
			MouseGetPos, v_MouseX, v_MouseY
			ToolTip, % TransA["Hotstring was triggered!"] . A_Space . "[" . F_ParseHotkey(ini_HK_UndoLH) . "]" . A_Space . TransA["to undo."], % v_MouseX + 20, % v_MouseY - 20, 4
			if (ini_OHTD > 0)
				SetTimer, TurnOff_OHE, % "-" . ini_OHTD, 40 ;Priority = 40 to avoid conflicts with other threads 
		}
	}
	
	if (ini_OHSEn)	;Basic Hotstring Sound Enable
		SoundBeep, % ini_OHSF, % ini_OHSD
	
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_PrepareTriggerstringTipsTables2()
{
	global	;assume-global mode
	local	HitCnt := 0
	
	;OutputDebug, % "Length of v_InputString:" . A_Space . StrLen(v_InputString) . A_Tab . "v_InputString:" . A_Space . v_InputString
	if (StrLen(v_InputString) > ini_TASAC - 1) and (ini_TTTtEn)	;TASAC = TipsAreShownAfterNoOfCharacters
	{
		a_Tips := []		
		Loop, % a_Triggers.MaxIndex()
		{
			if (InStr(a_Triggers[A_Index], v_InputString) = 1)
			{
				a_Tips.Push(a_Triggers[A_Index])
				HitCnt++
				if (HitCnt = ini_MNTT)	; MNTT = Maximum Number of Triggerstring Tips
					Break
			}
		}
	}
	else
	{
		Gui, TMenuAHK: Destroy
		a_Tips := []
	}
	return
}	
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_PrepareTriggerstringTipsTables()
{
	global	;assume-global mode
	local	HitCnt := 0
	
	;OutputDebug, % "Length of v_InputString:" . A_Space . StrLen(v_InputString) . A_Tab . "v_InputString:" . A_Space . v_InputString
	if (StrLen(v_InputString) > ini_TASAC - 1) and (ini_TTTtEn)	;TASAC = TipsAreShownAfterNoOfCharacters
	{
		v_Tips := ""		
		Loop, % a_Triggers.MaxIndex()
		{
			if (InStr(a_Triggers[A_Index], v_InputString) = 1)
			{
			if (v_Tips)
				v_Tips .= "`n"
			v_Tips .= a_Triggers[A_Index]
			HitCnt++
			if (HitCnt = ini_MNTT)	; MNTT = Maximum Number of Triggerstring Tips
				Break
			}
		}
	}
	else
	{
		ToolTip,
		v_Tips := ""
	}
	return
}	
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_GuiTrigShowNoOfTips()
{
	global	;assume-global mode
	local Window1X := 0, Window1Y := 0, Window1W := 0, Window1H := 0
	,Window2X := 0, Window2Y := 0, Window2W := 0, Window2H := 0
	,NewWinPosX := 0, NewWinPosY := 0
	,v_OutVarTemp := 0, 	v_OutVarTempX := 0, 	v_OutVarTempY := 0, 	v_OutVarTempW := 0, 	v_OutVarTempH := 0
	,v_xNext := 0, 		v_yNext := 0, 			v_wNext := 0, 			v_hNext := 0
	,vWidthOfSliderAndInfo := 0, vWidthOfInfo := 0
	
;+Owner to prevent display of a taskbar button
	Gui, TMNT: New, -MinimizeBox -MaximizeBox +Owner +HwndMaxNoTrigTips, % TransA["Set maximum number of shown triggerstring tips"]
	Gui, TMNT: Margin,	% c_xmarg, % c_ymarg
	Gui,	TMNT: Color,	% c_WindowColor, % c_ControlColor
	Gui,	TMNT: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, % c_FontType
	Gui, TMNT: Add, Text, HwndIdTMNT_T1, % TransA["This is the maximum length of list displayed on the screen in form of tooltip containing triggerstring tips."]
	
	Gui, TMNT: Add, Slider, x0 y0 HwndIdTMNT_S1 vini_MNTT gF_SetNoOfTips Line1 Page1 Range1-25 TickInterval5 ToolTipBottom Buddy1ini_MNTT, % ini_MNTT
	Gui, TMNT: Font, % "cBlue underline" . A_Space . "s" . c_FontSize + 2
	Gui, TMNT: Add, Text, HwndIdTMNT_T4, ⓘ
	F_TooltipMNTTSliderInfo := func("F_ShowLongTooltip").bind(TransA["F_TooltipMNTTSliderInfo"])
	GuiControl +g, % IdTMNT_T4, % F_TooltipMNTTSliderInfo
	
	Gui,	TMNT: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, % c_FontType
	v_OutVarTemp := 25
	Gui, TMNT: Add, Text, HwndIdTMNT_T3, % TransA["Maximum number of shown triggerstring tips"] . ":" . A_Space . v_OutVarTemp
	
	v_xNext := c_xmarg
	v_yNext := c_ymarg
	GuiControl, Move, % IdTMNT_T1, % "x" . v_xNext . A_Space . "y" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdTMNT_T1
	vWidthOfSliderAndInfo := v_OutVarTempW
	GuiControlGet, v_OutVarTemp, Pos, % IdTMNT_T4
	vWidthOfInfo := v_OutVarTempW
	v_xNext := c_xmarg
	v_yNext += HofText
	v_wNext := vWidthOfSliderAndInfo - (vWidthOfInfo + c_xmarg)
	GuiControl, Move, % IdTMNT_S1, % "x" . v_xNext . A_Space . "y" . v_yNext . A_Space . "w" . v_wNext
	
	GuiControlGet, v_OutVarTemp, Pos, % IdTMNT_S1
	v_xNext := v_OutVarTempX + v_OutVarTempW
	GuiControl, Move, % IdTMNT_T4, % "x" . v_xNext . A_Space . "y" . v_yNext
	v_xNext := c_xmarg
	v_yNext := v_OutVarTempY + v_OutVarTempH
	GuiControl, Move, % IdTMNT_T3, % "x" v_xNext . A_Space . "y" v_yNext
	
	GuiControl,, % IdTMNT_T3, % TransA["Maximum number of shown triggerstring tips"] . ":" . A_Space . ini_MNTT
	
	WinGetPos, Window1X, Window1Y, Window1W, Window1H, A
	Gui, TMNT: Show, Hide AutoSize 
	DetectHiddenWindows, On
	WinGetPos, Window2X, Window2Y, Window2W, Window2H, % "ahk_id" . MaxNoTrigTips
	DetectHiddenWindows, Off
	
	NewWinPosX := Round(Window1X + (Window1W / 2) - (Window2W / 2))
	NewWinPosY := Round(Window1Y + (Window1H / 2) - (Window2H / 2))
	
	Gui, TMNT: Show, % "x" . NewWinPosX . A_Space . "y" . NewWinPosY . A_Space . "AutoSize"	
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_SetNoOfTips()
{
	global	;assume-global mode
	Gui, TMNT: Submit, NoHide
	GuiControl,, % IdTMNT_T3, % TransA["Maximum number of shown triggerstring tips"] . ":" . A_Space . ini_MNTT
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_ShowTriggerstringTips()
{
	global	;assume-global mode
	
	if ((ini_TTTtEn) and (ini_TTTP = 1))
	{
		if (A_CaretX and A_CaretY)
		{
			ToolTip, %v_Tips%, A_CaretX + 20, A_CaretY - 20
			if ((ini_TTTtEn) and (ini_TTTD > 0))
				SetTimer, TurnOff_Ttt, % "-" . ini_TTTD ;, 200 ;Priority = 200 to avoid conflicts with other threads 
		}
		else
		{
			MouseGetPos, v_MouseX, v_MouseY
			ToolTip, %v_Tips%, v_MouseX + 20, v_MouseY - 20
			if ((ini_TTTtEn) and (ini_TTTD > 0))
				SetTimer, TurnOff_Ttt, % "-" . ini_TTTD ;, 200 ;Priority = 200 to avoid conflicts with other threads 
		}
	}
	if ((ini_TTTtEn) and (ini_TTTP = 2))
	{
		MouseGetPos, v_MouseX, v_MouseY
		ToolTip, %v_Tips%, v_MouseX + 20, v_MouseY - 20
		if ((ini_TTTtEn) and (ini_TTTD > 0))
			SetTimer, TurnOff_Ttt, % "-" . ini_TTTD ;, 200 ;Priority = 200 to avoid conflicts with other threads 
	}
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_SortTipsByLength()
{
	global	;assume-global mode
	static OneTimeMemory := true
	
	if (OneTimeMemory)
	{
		if (ini_TipsSortByLength)
			Menu, TrigSortOrder, Check, % TransA["By length"]
		else
			Menu, TrigSortOrder, UnCheck, % TransA["By length"]
		OneTimeMemory := false
	}
	else
	{
		ini_TipsSortByLength := !(ini_TipsSortByLength)
		if (ini_TipsSortByLength)
			Menu, TrigSortOrder, Check, % TransA["By length"]
		else
			Menu, TrigSortOrder, UnCheck, % TransA["By length"]
		IniWrite, % ini_TipsSortByLength, % HADConfig, Event_TriggerstringTips, TipsSortByLength
	}
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_SortTipsAlphabetically()
{
global	;assume-global mode
	static OneTimeMemory := true
	
	if (OneTimeMemory)
	{
		if (ini_TipsSortAlphabetically)
			Menu, TrigSortOrder, Check, % TransA["Alphabetically"]
		else
			Menu, TrigSortOrder, UnCheck, % TransA["Alphabetically"]
		OneTimeMemory := false
	}
	else
	{
		ini_TipsSortAlphabetically := !(ini_TipsSortAlphabetically)
		if (ini_TipsSortAlphabetically)
			Menu, TrigSortOrder, Check, % TransA["Alphabetically"]
		else
			Menu, TrigSortOrder, UnCheck, % TransA["Alphabetically"]
		IniWrite, % ini_TipsSortAlphabetically, % HADConfig, Event_TriggerstringTips, TipsSortAlphabetically
	}
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_AmountOfCharacterTips()
{
	global	;assume-global mode
	static OneTimeMemory := true
	
	if (OneTimeMemory)
	{
		Switch ini_TASAC
		{
			Case 1:	Menu, Submenu4, Check, 1
			Case 2:	Menu, Submenu4, Check, 2
			Case 3:	Menu, Submenu4, Check, 3
			Case 4:	Menu, Submenu4, Check, 4
			Case 5:	Menu, Submenu4, Check, 5
		}
		OneTimeMemory := false
	}
	else
	{
		ini_TASAC := A_ThisMenuItem
		Switch ini_TASAC
		{
			Case 1:	Menu, Submenu4, Check, 1
			Case 2:	Menu, Submenu4, Check, 2
			Case 3:	Menu, Submenu4, Check, 3
			Case 4:	Menu, Submenu4, Check, 4
			Case 5:	Menu, Submenu4, Check, 5
		}
		IniWrite, % ini_TASAC, % HADConfig, Event_TriggerstringTips, TipsAreShownAfterNoOfCharacters
		Loop, 5
		{
			if (A_Index != ini_TASAC)
				Menu, Submenu4, UnCheck, %A_Index%
		}
	}
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EventTtPos()
{
	global	;assume-global mode
	static OneTimeMemory := true
	
	if (OneTimeMemory)
	{
		Switch (ini_OHTP)
		{
			Case 1:
			Menu, OrdHisTrig, Check, 	% TransA["Tooltip position: caret"]
			Menu, OrdHisTrig, UnCheck, 	% TransA["Tooltip position: cursor"]
			Case 2: 
			Menu, OrdHisTrig, Check, 	% TransA["Tooltip position: cursor"]
			Menu, OrdHisTrig, UnCheck, 	% TransA["Tooltip position: caret"]
		}
		Switch (ini_MHMP)
		{
			Case 1:
			Menu, MenuHisTrig, Check, % TransA["Menu position: caret"]
			Menu, MenuHisTrig, UnCheck, % TransA["Menu position: cursor"]
			Case 2:
			Menu, MenuHisTrig, Check, % TransA["Menu position: cursor"]
			Menu, MenuHisTrig, UnCheck, % TransA["Menu position: caret"]
		}
		Switch (ini_UHTP)
		{
			Case 1:
			Menu, UndoOfH, Check, 	% TransA["Tooltip position: caret"]
			Menu, UndoOfH, UnCheck, 	% TransA["Tooltip position: cursor"]
			Case 2:
			Menu, UndoOfH, Check, 	% TransA["Tooltip position: cursor"]
			Menu, UndoOfH, UnCheck, 	% TransA["Tooltip position: caret"]
		}
		Switch (ini_TTTP)
		{
			Case 1:
			Menu, TrigTips, Check, 	% TransA["Tooltip position: caret"]
			Menu, TrigTips, UnCheck, % TransA["Tooltip position: cursor"]
			Case 2:
			Menu, TrigTips, Check, 	% TransA["Tooltip position: cursor"]
			Menu, TrigTips, UnCheck, % TransA["Tooltip position: caret"]
		}
		OneTimeMemory := false
	}
	else
	{
		Switch (A_ThisMenu)
		{
			Case "OrdHisTrig":
			Switch (ini_OHTP)
			{
				Case 1:
				Menu, OrdHisTrig, Check, 	% TransA["Tooltip position: cursor"]
				Menu, OrdHisTrig, UnCheck, 	% TransA["Tooltip position: caret"]
				ini_OHTP := 2
				Case 2: 
				Menu, OrdHisTrig, Check, 	% TransA["Tooltip position: caret"]
				Menu, OrdHisTrig, UnCheck, 	% TransA["Tooltip position: cursor"]
				ini_OHTP := 1
			}
			IniWrite, % ini_OHTP, % HADConfig, Event_BasicHotstring, OHTP
			Case "MenuHisTrig":
			Switch (ini_MHMP)
			{
				Case 1:
				Menu, MenuHisTrig, Check, % TransA["Menu position: cursor"]
				Menu, MenuHisTrig, UnCheck, % TransA["Menu position: caret"]
				ini_MHMP := 2
				Case 2:
				Menu, MenuHisTrig, Check, % TransA["Menu position: caret"]
				Menu, MenuHisTrig, UnCheck, % TransA["Menu position: cursor"]
				ini_MHMP := 1
			}
			IniWrite, % ini_MHMP, % HADConfig, Event_MenuHotstring, MHMP
			Case "UndoOfH":
			Switch (ini_UHTP)
			{
				Case 1:
				Menu, UndoOfH, Check, 	% TransA["Tooltip position: cursor"]
				Menu, UndoOfH, UnCheck, 	% TransA["Tooltip position: caret"]
				ini_UHTP := 2
				Case 2:
				Menu, UndoOfH, Check, 	% TransA["Tooltip position: caret"]
				Menu, UndoOfH, UnCheck, 	% TransA["Tooltip position: cursor"]
				ini_UHTP := 1
			}
			IniWrite, % ini_UHTP, % HADConfig, Event_UndoHotstring, UHTP
			Case "TrigTips":
			Switch (ini_TTTP)
			{
				Case 1:
				Menu, TrigTips, Check, 	% TransA["Tooltip position: cursor"]
				Menu, TrigTips, UnCheck, % TransA["Tooltip position: caret"]
				ini_TTTP := 2
				Case 2:
				Menu, TrigTips, Check, 	% TransA["Tooltip position: caret"]
				Menu, TrigTips, UnCheck, % TransA["Tooltip position: cursor"]
				ini_TTTP := 1
			}
			IniWrite, % ini_TTTP, % HADConfig, Event_TriggerstringTips, TTTP
		}
	}
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_MUndo()
{
	global	;assume-global mode
	static OneTimeMemory := true
	
	if (OneTimeMemory)
	{
		if (ini_HotstringUndo)
		{
			Menu, SigOfEvents, Enable, % TransA["Undid the last hotstring"]
			Hotkey, % ini_HK_UndoLH, F_Undo, On	
		}
		else
		{
			Menu, SigOfEvents, Disable, % TransA["Undid the last hotstring"]
			Hotkey, % ini_HK_UndoLH, F_Undo, Off
		}
		OneTimeMemory := false	
	}
	else
	{
		if (ini_HotstringUndo)
		{
			Menu, SigOfEvents, Disable, % TransA["Undid the last hotstring"]				
			Hotkey, % ini_HK_UndoLH, F_Undo, Off
		}
		else
		{
			Menu, SigOfEvents, Enable, % TransA["Undid the last hotstring"]				
			Hotkey, % ini_HK_UndoLH, F_Undo, On
		}
		ini_HotstringUndo := !(ini_HotstringUndo)
		IniWrite, % ini_HotstringUndo, % HADConfig, Configuration, HotstringUndo
	}
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EventSoEn()
{
	global	;assume-global mode
	static OneTimeMemory := true
	
	if (OneTimeMemory)
	{
		if (ini_OHSEn)
		{
			Menu, OrdHisTrig, Check, % TransA["Sound enable"]
			Menu, OrdHisTrig, UnCheck, % TransA["Sound disable"]
			Menu, OrdHisTrig, Enable, % TransA["Sound parameters"]
		}
		else
		{
			Menu, OrdHisTrig, UnCheck, % TransA["Sound enable"]
			Menu, OrdHisTrig, Check, % TransA["Sound disable"]
			Menu, OrdHisTrig, Disable, % TransA["Sound parameters"]
		}
		if (ini_MHSEn)
		{
			Menu, MenuHisTrig, Check, % TransA["Sound enable"]
			Menu, MenuHisTrig, UnCheck, % TransA["Sound disable"]
			Menu, MenuHisTrig, Enable, % TransA["Sound parameters"]
		}
		else
		{
			Menu, MenuHisTrig, UnCheck, % TransA["Sound enable"]
			Menu, MenuHisTrig, Check, % TransA["Sound disable"]
			Menu, MenuHisTrig, Disable, % TransA["Sound parameters"]
		}
		if (ini_UHSEn)
		{
			Menu, UndoOfH, Check, % TransA["Sound enable"] 
			Menu, UndoOfH, UnCheck, % TransA["Sound disable"]
			Menu, UndoOfH, Enable, % TransA["Sound parameters"]
		}
		else
		{
			Menu, UndoOfH, UnCheck, % TransA["Sound enable"] 
			Menu, UndoOfH, Check, % TransA["Sound disable"]
			Menu, UndoOfH, Disable, % TransA["Sound parameters"]
		}
		OneTimeMemory := false
	}
	else
	{
		Switch A_ThisMenu
		{
			Case "OrdHisTrig":
			ini_OHSEn := !ini_OHSEn
			if (ini_OHSEn)
			{
				Menu, % A_ThisMenu, Check, % TransA["Sound enable"]
				Menu, % A_ThisMenu, UnCheck, % TransA["Sound disable"]
				Menu, % A_ThisMenu, Enable, % TransA["Sound parameters"]
			}
			else
			{
				Menu, % A_ThisMenu, UnCheck, % TransA["Sound enable"]
				Menu, % A_ThisMenu, Check, % TransA["Sound disable"]
				Menu, % A_ThisMenu, Disable, % TransA["Sound parameters"]
			}
			IniWrite, % ini_OHSEn, % HADConfig, Event_BasicHotstring, OHSEn
			Case "MenuHisTrig":
			ini_MHSEn := !ini_MHSEn
			if (ini_MHSEn)
			{
				Menu, % A_ThisMenu, Check, % TransA["Sound enable"]
				Menu, % A_ThisMenu, UnCheck, % TransA["Sound disable"]
				Menu, % A_ThisMenu, Enable, % TransA["Sound parameters"]
			}
			else
			{
				Menu, % A_ThisMenu, UnCheck, % TransA["Sound enable"]
				Menu, % A_ThisMenu, Check, % TransA["Sound disable"]
				Menu, % A_ThisMenu, Disable, % TransA["Sound parameters"]
			}
			IniWrite, % ini_MHSEn, % HADConfig, Event_MenuHotstring, MHSEn
			Case "UndoOfH":
			ini_UHSEn := !ini_UHSEn
			if (ini_UHSEn)
			{
				Menu, % A_ThisMenu, Check, % TransA["Sound enable"]
				Menu, % A_ThisMenu, UnCheck, % TransA["Sound disable"]
				Menu, % A_ThisMenu, Enable, % TransA["Sound parameters"]
			}
			else
			{
				Menu, % A_ThisMenu, UnCheck, % TransA["Sound enable"]
				Menu, % A_ThisMenu, Check, % TransA["Sound disable"]
				Menu, % A_ThisMenu, Disable, % TransA["Sound parameters"]
			}
			IniWrite, % ini_UHSEn, % HADConfig, Event_UndoHotstring, UHSEn
		}
	}
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EventTtEn()	;Event "tooltip enable"
{
	global	;assume-global mode
	static OneTimeMemory := true
	
	if (OneTimeMemory)
	{
		if (ini_OHTtEn)
		{
			Menu, OrdHisTrig, Check, 	% TransA["Tooltip enable"]
			Menu, OrdHisTrig, UnCheck, 	% TransA["Tooltip disable"]
			Menu, OrdHisTrig, Enable, 	% TransA["Tooltip timeout"]
			Menu, OrdHisTrig, Enable, 	% TransA["Tooltip position: caret"]
			Menu, OrdHisTrig, Enable, 	% TransA["Tooltip position: cursor"]
		}
		else
		{
			Menu, OrdHisTrig, UnCheck, 	% TransA["Tooltip enable"]
			Menu, OrdHisTrig, Check, 	% TransA["Tooltip disable"]
			Menu, OrdHisTrig, Disable, 	% TransA["Tooltip timeout"]
			Menu, OrdHisTrig, Disable, 	% TransA["Tooltip position: caret"]
			Menu, OrdHisTrig, Disable, 	% TransA["Tooltip position: cursor"]
		}
		
		if (ini_UHTtEn)
		{
			Menu, UndoOfH, Check, 	% TransA["Tooltip enable"]
			Menu, UndoOfH, UnCheck, 	% TransA["Tooltip disable"]
			Menu, UndoOfH, Enable, 	% TransA["Tooltip timeout"]
			Menu, UndoOfH, Enable, 	% TransA["Tooltip position: caret"]
			Menu, UndoOfH, Enable, 	% TransA["Tooltip position: cursor"]
		}
		else
		{
			Menu, UndoOfH, UnCheck, 	% TransA["Tooltip enable"]
			Menu, UndoOfH, Check, 	% TransA["Tooltip disable"]
			Menu, UndoOfH, Disable, 	% TransA["Tooltip timeout"]
			Menu, UndoOfH, Disable, 	% TransA["Tooltip position: caret"]
			Menu, UndoOfH, Disable, 	% TransA["Tooltip position: cursor"]
		}
		
		if (ini_TTTtEn)
		{
			Menu, TrigTips, Check, 	% TransA["Tooltip enable"]
			Menu, TrigTips, UnCheck, % TransA["Tooltip disable"]
			Menu, TrigTips, Enable, 	% TransA["Tooltip timeout"]
			Menu, TrigTips, Enable, 	% TransA["Tooltip position: caret"]
			Menu, TrigTips, Enable, 	% TransA["Tooltip position: cursor"]
			Menu, TrigTips, Enable, 	% TransA["Sorting order"]
			Menu, TrigTips, Enable, 	% TransA["Max. no. of shown tips"]
		}
		else
		{
			Menu, TrigTips, UnCheck, % TransA["Tooltip enable"]
			Menu, TrigTips, Check, 	% TransA["Tooltip disable"]
			Menu, TrigTips, Disable, % TransA["Tooltip timeout"]
			Menu, TrigTips, Disable, % TransA["Tooltip position: caret"]
			Menu, TrigTips, Disable, % TransA["Tooltip position: cursor"]
			Menu, TrigTips, Disable, % TransA["Sorting order"]
			Menu, TrigTips, Disable, % TransA["Max. no. of shown tips"]
		}		
		OneTimeMemory := false
	}
	else
		Switch A_ThisMenu
	{
		Case "OrdHisTrig":
		ini_OHTtEn := !ini_OHTtEn
		if (ini_OHTtEn)
		{
			Menu, % A_ThisMenu, Check, 	% TransA["Tooltip enable"]
			Menu, % A_ThisMenu, UnCheck, 	% TransA["Tooltip disable"]
			Menu, % A_ThisMenu, Enable, 	% TransA["Tooltip timeout"]
			Menu, % A_ThisMenu, Enable, 	% TransA["Tooltip position: caret"]
			Menu, % A_ThisMenu, Enable, 	% TransA["Tooltip position: cursor"]
		}
		else
		{
			Menu, % A_ThisMenu, UnCheck, 	% TransA["Tooltip enable"]
			Menu, % A_ThisMenu, Check, 	% TransA["Tooltip disable"]
			Menu, % A_ThisMenu, Disable, 	% TransA["Tooltip timeout"]
			Menu, % A_ThisMenu, Disable, 	% TransA["Tooltip position: caret"]
			Menu, % A_ThisMenu, Disable, 	% TransA["Tooltip position: cursor"]
		}
		IniWrite, % ini_OHTtEn, % HADConfig, Event_BasicHotstring, OHTtEn
		Case "UndoOfH":
		ini_UHTtEn := !ini_UHTtEn
		if (ini_UHTtEn)
		{
			Menu, % A_ThisMenu, Check, 	% TransA["Tooltip enable"]
			Menu, % A_ThisMenu, UnCheck, 	% TransA["Tooltip disable"]
			Menu, % A_ThisMenu, Enable, 	% TransA["Tooltip timeout"]
			Menu, % A_ThisMenu, Enable, 	% TransA["Tooltip position: caret"]
			Menu, % A_ThisMenu, Enable, 	% TransA["Tooltip position: cursor"]
		}
		else
		{
			Menu, % A_ThisMenu, UnCheck, % A_ThisMenuItem
			Menu, % A_ThisMenu, Disable, % TransA["Tooltip timeout"]
			Menu, % A_ThisMenu, Disable, % TransA["Tooltip position: caret"]
			Menu, % A_ThisMenu, Disable, % TransA["Tooltip position: cursor"]
		}
		IniWrite, % ini_UHTtEn, % HADConfig, Event_UndoHotstring, UHTtEn
		Case "TrigTips":
		ini_TTTtEn := !ini_TTTtEn
		if (ini_TTTtEn)
		{
			Menu, % A_ThisMenu, UnCheck, 	% TransA["Tooltip enable"]
			Menu, % A_ThisMenu, Check, 	% TransA["Tooltip disable"]
			Menu, % A_ThisMenu, Enable, 	% TransA["Tooltip timeout"]
			Menu, % A_ThisMenu, Enable, 	% TransA["Tooltip position: caret"]
			Menu, % A_ThisMenu, Enable, 	% TransA["Tooltip position: cursor"]
			Menu, % A_ThisMenu, Enable, % TransA["Sorting order"]
			Menu, % A_ThisMenu, Enable, % TransA["Max. no. of shown tips"]
		}
		else
		{
			Menu, % A_ThisMenu, UnCheck, % A_ThisMenuItem
			Menu, % A_ThisMenu, Disable, % TransA["Tooltip timeout"]
			Menu, % A_ThisMenu, Disable, % TransA["Tooltip position: caret"]
			Menu, % A_ThisMenu, Disable, % TransA["Tooltip position: cursor"]
			Menu, % A_ThisMenu, Disable, % TransA["Sorting order"]
			Menu, % A_ThisMenu, Disable, % TransA["Max. no. of shown tips"]
		}
		IniWrite, % ini_TTTtEn, % HADConfig, Event_TriggerstringTips, TTTtEn
	}
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_LoadSignalingParams()
{
	global	;assume-global mode
	ini_OHTtEn := 1, 	ini_OHTD := 0, 	ini_OHTP := 1, 	ini_OHSEn := 1, 	ini_OHSF := 500, 	ini_OHSD := 250, 	ini_MHMP := 1, 	ini_MHSEn := 1
	,ini_MHSF := 500, 	ini_MHSD := 250, 	ini_UHTtEn := 1, 	ini_UHTD := 0, 	ini_UHTP := 1, 	ini_UHSEn := 1, 	ini_UHSF := 500, 	ini_UHSD := 250
	,ini_TTTP := 1, 	ini_TTTtEn := 1, 	ini_TTTD := 0, 	ini_TipsSortAlphabetically := 1, 	ini_TipsSortByLength := 1, 	ini_TASAC := 1,	ini_MNTT := 5
	
	IniRead, ini_OHTtEn, 	% HADConfig, Event_BasicHotstring, 	OHTtEn, 	% A_Space
	if (ini_OHTtEn = "")
	{
		ini_OHTtEn := 1
		IniWrite, % ini_OHTtEn, % HADConfig, Event_BasicHotstring,	OHTtEn
	}
	IniRead, ini_OHTD,		% HADConfig, Event_BasicHotstring,		OHTD,	% A_Space
	if (ini_OHTD = "")
	{
		ini_OHTD := 0
		IniWrite, % ini_OHTD, % HADConfig, Event_BasicHotstring,	OHTD
	}
	IniRead, ini_OHTP,		% HADConfig, Event_BasicHotstring,		OHTP,	% A_Space
	if (ini_OHTP = "")
	{
		ini_OHTP := 1
		IniWrite, % ini_OHTP, % HADConfig, Event_BasicHotstring,	OHTP
	}
	IniRead, ini_OHSEn, 	% HADConfig, Event_BasicHotstring,		OHSEn, 	% A_Space
	if (ini_OHSEn = "")
	{
		ini_OHSEn := 1
		IniWrite, % ini_OHSEn, % HADConfig, Event_BasicHotstring,	OHSEn
	}
	IniRead, ini_OHSF,		% HADConfig, Event_BasicHotstring,		OHSF,	% A_Space
	if (ini_OHSF = "")
	{
		ini_OHSF := 500
		IniWrite, % ini_OHSF, % HADConfig, Event_BasicHotstring,	OHSF
	}
	IniRead, ini_OHSD,		% HADConfig, Event_BasicHotstring,		OHSD,	% A_Space
	if (ini_OHSD = "")
	{
		ini_OHSD := 250
		IniWrite, % ini_OHSD, % HADConfig, Event_BasicHotstring,	OHSD
	}
	IniRead, ini_MHMP,		% HADConfig, Event_MenuHotstring,		MHMP,	% A_Space
	if (ini_MHMP = "")
	{
		ini_MHMP := 1
		IniWrite, % ini_MHMP, % HADConfig, Event_MenuHotstring,	MHMP
	}
	IniRead, ini_MHSEn,		% HADConfig, Event_MenuHotstring,		MHSEn,	% A_Space
	if (ini_MHSEn = "")
	{
		ini_MHSEn := 1
		IniWrite, % ini_MHSEn, % HADConfig, Event_MenuHotstring,	MHSEn
	}
	IniRead, ini_MHSF,		% HADConfig, Event_MenuHotstring,		MHSF,	% A_Space
	if (ini_MHSF = "")
	{
		ini_MHSF := 500
		IniWrite, % ini_MHSF, % HADConfig, Event_MenuHotstring,	MHSF
	}
	IniRead, ini_MHSD,		% HADConfig, Event_MenuHotstring,		MHSD,	% A_Space
	if (ini_MHSD = "")
	{
		ini_MHSD := 250
		IniWrite, % ini_MHSD, % HADConfig, Event_MenuHotstring,	MHSD
	}
	IniRead, ini_UHTtEn, 	% HADConfig, Event_UndoHotstring, 		UHTtEn, 	% A_Space
	if (ini_UHTtEn = "")
	{
		ini_UHTtEn := 1
		IniWrite, % ini_UHTtEn, % HADConfig, Event_UndoHotstring, 	UHTtEn
	}
	IniRead, ini_UHTD,		% HADConfig, Event_UndoHotstring,		UHTD,	% A_Space
	if (ini_UHTD = "")
	{
		ini_UHTD := 0
		IniWrite, % ini_UHTD, % HADConfig, Event_UndoHotstring,	UHTD
	}
	IniRead, ini_UHTP,		% HADConfig, Event_UndoHotstring,		UHTP,	% A_Space
	if (ini_UHTP = "")
	{
		ini_UHTP := 1
		IniWrite, % ini_UHTP, % HADConfig, Event_UndoHotstring,	UHTP
	}
	IniRead, ini_UHSEn,		% HADConfig, Event_UndoHotstring,		UHSEn,	% A_Space
	if (ini_UHSEn = "")
	{
		ini_UHSEn := 1
		IniWrite, % ini_UHSEn, % HADConfig, Event_UndoHotstring,	UHSEn
	}
	IniRead, ini_UHSF,		% HADConfig, Event_UndoHotstring,		UHSF,	% A_Space
	if (ini_UHSF = "")
	{
		ini_UHSF := 500
		IniWrite, % ini_UHSF, % HADConfig, Event_UndoHotstring,	UHSF
	}
	IniRead, ini_UHSD,		% HADConfig, Event_UndoHotstring,		UHSD,	% A_Space
	if (ini_UHSD = "")
	{
		ini_UHSD := 250
		IniWrite, % ini_UHSD, % HADConfig, Event_UndoHotstring,	UHSD
	}
	IniRead, ini_TTTP,		% HADConfig, Event_TriggerstringTips,	TTTP,	% A_Space
	if (ini_TTTP = "")
	{
		ini_TTTP := 1
		IniWrite, % ini_TTTP, % HADConfig, Event_TriggerstringTips,	TTTP
	}
	IniRead, ini_TTTtEn, 	% HADConfig, Event_TriggerstringTips,	TTTtEn, 	% A_Space
	if (ini_TTTtEn = "")
	{
		ini_TTTtEn := 1
		IniWrite, % ini_TTTtEn, % HADConfig, Event_TriggerstringTips,	TTTtEn
	}
	IniRead, ini_TTTD,		% HADConfig, Event_TriggerstringTips,	TTTD,	% A_Space
	if (ini_TTTD = "")
	{
		ini_TTTD := 0
		IniWrite, % ini_TTTD, % HADConfig, Event_TriggerstringTips,	TTTD
	}
	IniRead, ini_TipsSortAlphabetically, % HADConfig, Event_TriggerstringTips, TipsSortAlphabetically, % A_Space
	if (ini_TipsSortAlphabetically = "")
	{
		ini_TipsSortAlphabetically := 1
		IniWrite, % ini_TipsSortAlphabetically, % HADConfig, Event_TriggerstringTips, TipsSortAlphabetically
	}
	IniRead, ini_TipsSortByLength, % HADConfig, Event_TriggerstringTips, TipsSortByLength, % A_Space
	if (ini_TipsSortByLength = "")
	{
		ini_TipsSortByLength := 1
		IniWrite, % ini_TipsSortByLength, % HADConfig, Event_TriggerstringTips, TipsSortByLength
	}
	IniRead, ini_TASAC, 	% HADConfig, Event_TriggerstringTips, 	TipsAreShownAfterNoOfCharacters, % A_Space
	if (ini_TASAC = "")
	{
		ini_TASAC := 1
		Iniwrite, % ini_TASAC, % HADConfig, Event_TriggerstringTips, 	TipsAreShownAfterNoOfCharacters
	}
	IniRead, ini_MNTT,		% HADConfig, Event_TriggerstringTips,	MNTT,	% A_Space
	if (ini_MNTT = "")
	{
		ini_MNTT := 5
		IniWrite, % ini_MNTT, % HADConfig, Event_TriggerstringTips,	MNTT
	}
	return
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
			IniWrite, % false, % HADConfig, EndChars, % NextName[A_ThisMenuItemPos]	
		}
		else
		{
			Menu, SubmenuEndChars, Check, % A_ThisMenuitem
			a_HotstringEndChars[A_ThisMenuItem] := true
			IniWrite, % true, % HADConfig, EndChars, % NextName[A_ThisMenuItemPos]	
		}
		F_LoadEndChars()
	}
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EventSoPar()
{
	global	;assume-global mode
	local Window1X := 0, Window1Y := 0, Window1W := 0, Window1H := 0
		,Window2X := 0, Window2Y := 0, Window2W := 0, Window2H := 0
		,NewWinPosX := 0, NewWinPosY := 0
		,v_OutVarTemp := 0, 	v_OutVarTempX := 0, 	v_OutVarTempY := 0, 	v_OutVarTempW := 0, 	v_OutVarTempH := 0
		,v_xNext := 0, 		v_yNext := 0, 			v_wNext := 0, 			v_hNext := 0
		,TickInterval := (32767 - 37) / 9, SliderWidth := 0, SliderHeight := 0, MaxWidth := 0, iWidth := 0, ButtonMar := 0, ButtonWidth := 0
	
	;+Owner to prevent display of a taskbar button
	Switch A_ThisMenu
	{
		Case "OrdHisTrig":	Gui, MSP: New, -MinimizeBox -MaximizeBox +Owner +HwndSoundPar, % TransA["Set sound parameters for event ""basic hotstring"""]
		Case "MenuHisTrig":	Gui, MSP: New, -MinimizeBox -MaximizeBox +Owner +HwndSoundPar, % TransA["Set sound parameters for event ""hotstring menu"""]
		Case "UndoOfH":	Gui, MSP: New, -MinimizeBox -MaximizeBox +Owner +HwndSoundPar, % TransA["Set sound parameters for event ""undo hotstring"""]
	}
	
	Gui, MSP: Margin,	% c_xmarg, % c_ymarg
	Gui,	MSP: Color,	% c_WindowColor, % c_ControlColor
	Gui,	MSP: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, % c_FontType
	
	Switch A_ThisMenu
	{
		Case "OrdHisTrig":	
		Gui, MSP: Add, Text, HwndIdMSP_T1, % TransA["When ""basic hotsring"" event takes place, sound is emitted according to the following settings."]
		Gui, MSP: Add, Slider, HwndIdMSP_S1 vini_OHSF gF_SetSoundFrequency Line1 Page50 Range37-32767 TickInterval%TickInterval% ToolTipBottom Buddy1ini_OHSF, % ini_OHSF
		Case "MenuHisTrig": 
		Gui, MSP: Add, Text, HwndIdMSP_T1, % TransA["When ""hotstring menu"" event takes place, sound is emitted according to the following settings."]
		Gui, MSP: Add, Slider, HwndIdMSP_S1 vini_MHSF gF_SetSoundFrequency Line1 Page50 Range37-32767 TickInterval%TickInterval% ToolTipBottom Buddy1ini_MHSF, % ini_MHSF
		Case "UndoOfH":	
		Gui, MSP: Add, Text, HwndIdMSP_T1, % TransA["When ""undo hotstring"" event takes place, sound is emitted according to the following settings."]
		Gui, MSP: Add, Slider, HwndIdMSP_S1 vini_UHSF gF_SetSoundFrequency Line1 Page50 Range37-32767 TickInterval%TickInterval% ToolTipBottom Buddy1ini_UHSF, % ini_UHSF
	}
	
	Gui, MSP: Font, % "cBlue underline" . A_Space . "s" . c_FontSize + 2
	Gui, MSP: Add, Text, HwndIdMSP_T2, ⓘ
	F_SoundFreqSliderInfo := func("F_ShowLongTooltip").bind(TransA["F_SoundFreqSliderInfo"])
	GuiControl +g, % IdMSP_T2, % F_SoundFreqSliderInfo
	Gui,	MSP: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, % c_FontType
	v_OutVarTemp := 10000
	
	Switch A_ThisMenu
	{
		Case "OrdHisTrig":
		Gui, MSP: Add, Text, HwndIdMSP_T3, % TransA["""Basic hotstring"" sound frequency"] . ":" . A_Space . v_OutVarTemp
		Gui, MSP: Add, Slider, HwndIdMSP_S2 vini_OHSD gF_SetSoundDuration Line1 Page50 Range50-2000 TickInterval50 ToolTipBottom Buddy1ini_OHSD, % ini_OHSD
		Case "MenuHisTrig":
		Gui, MSP: Add, Text, HwndIdMSP_T3, % TransA["""Hotstring menu"" sound frequency"] . ":" . A_Space . v_OutVarTemp
		Gui, MSP: Add, Slider, HwndIdMSP_S2 vini_MHSD gF_SetSoundDuration Line1 Page50 Range50-2000 TickInterval50 ToolTipBottom Buddy1ini_MHSD, % ini_MHSD
		Case "UndoOfH":
		Gui, MSP: Add, Text, HwndIdMSP_T3, % TransA["""Undo hotstring"" sound frequency"] . ":" . A_Space . v_OutVarTemp
		Gui, MSP: Add, Slider, HwndIdMSP_S2 vini_UHSD gF_SetSoundDuration Line1 Page50 Range50-2000 TickInterval50 ToolTipBottom Buddy1ini_UHSD, % ini_UHSD
	}
	Gui, MSP: Font, % "cBlue underline" . A_Space . "s" . c_FontSize + 2
	Gui, MSP: Add, Text, HwndIdMSP_T4, ⓘ
	F_SoundDurSliderInfo := func("F_ShowLongTooltip").bind(TransA["F_SoundDurSliderInfo"])
	GuiControl +g, % IdMSP_T4, % F_SoundDurSliderInfo
	Gui,	MSP: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, % c_FontType
	v_OutVarTemp := 10000
	
	Switch A_ThisMenu
	{
		Case "OrdHisTrig":	Gui, MSP: Add, Text, HwndIdMSP_T5, % TransA["""Basic hotstring"" sound duration [ms]"] . ":" . A_Space . v_OutVarTemp
		Case "MenuHisTrig":	Gui, MSP: Add, Text, HwndIdMSP_T5, % TransA["""Hotstring menu"" sound duration [ms]"] . ":" . A_Space . v_OutVarTemp
		Case "UndoOfH":	Gui, MSP: Add, Text, HwndIdMSP_T5, % TransA["""Undo hotstring"" sound duration [ms]"] . ":" . A_Space . v_OutVarTemp
	}
	Gui, MSP: Add, Button, HwndIdMSP_B1 gF_SoundTestBut, % TransA["Sound test"]
	
	GuiControlGet, v_OutVarTemp, Pos, % IdMSP_T1
	MaxWidth := v_OutVarTempW
	GuiControlGet, v_OutVarTemp, Pos, % IdMSP_T2
	iWidth := v_OutVarTempW
	SliderWidth := MaxWidth - (iWidth + 2 * c_xmarg)
	GuiControlGet, v_OutVarTemp, Pos, % IdMSP_S1
	SliderHeight := v_OutVarTempH
	GuiControlGet, v_OutVarTemp, Pos, % IdMSP_B1
	ButtonWidth := v_OutVarTempW + 2 * c_xmarg
	ButtonMar := Round((MaxWidth - ButtonWidth) / 2)
	
	v_xNext := c_xmarg
	v_yNext := c_ymarg
	GuiControl, Move, % IdMSP_T1, % "x" . v_xNext . A_Space . "y" . v_yNext
	v_yNext += 2 * HofText
	v_wNext := SliderWidth
	GuiControl, Move, % IdMSP_S1, % "x" . v_xNext . A_Space . "y" . v_yNext . A_Space . "w" . v_wNext
	v_xNext := c_xmarg + SliderWidth + c_xmarg
	GuiControl, Move, % IdMSP_T2, % "x" . v_xNext . A_Space . "y" . v_yNext 
	GuiControlGet, v_OutVarTemp, Pos, % IdMSP_S1
	v_xNext := c_xmarg
	v_yNext += SliderHeight
	GuiControl, Move, % IdMSP_T3, % "x" . v_xNext . A_Space . "y" . v_yNext 
	v_yNext += HofText + 4 * c_ymarg
	v_wNext := SliderWidth
	GuiControl, Move, % IdMSP_S2, % "x" . v_xNext . A_Space . "y" . v_yNext . A_Space . "w" . v_wNext
	v_xNext := c_xmarg + SliderWidth + c_xmarg
	GuiControl, Move, % IdMSP_T4, % "x" . v_xNext . A_Space . "y" . v_yNext 
	v_xNext := c_xmarg
	v_yNext += SliderHeight
	GuiControl, Move, % IdMSP_T5, % "x" . v_xNext . A_Space . "y" . v_yNext 
	v_xNext := ButtonMar
	v_yNext += HofText + c_ymarg
	v_wNext := ButtonWidth
	GuiControl, Move, % IdMSP_B1, % "x" . v_xNext . A_Space . "y" . v_yNext . A_Space . "w" . v_wNext
	
	Switch A_ThisMenu
	{
		Case "OrdHisTrig":
		GuiControl,, % IdMSP_T3, % TransA["""Basic hotstring"" sound frequency"] . ":" . A_Space . ini_OHSF
		GuiControl,, % IdMSP_T5, % TransA["""Basic hotstring"" sound duration [ms]"] . ":" . A_Space . ini_OHSD
		Case "MenuHisTrig":
		GuiControl,, % IdMSP_T3, % TransA["""Hotstring menu"" sound frequency"] . ":" . A_Space . ini_MHSF
		GuiControl,, % IdMSP_T5, % TransA["""Hotstring menu"" sound duration [ms]"] . ":" . A_Space . ini_MHSD
		Case "UndoOfH":
		GuiControl,, % IdMSP_T3, % TransA["""Undo hotstring"" sound frequency"] . ":" . A_Space . ini_UHSF
		GuiControl,, % IdMSP_T5, % TransA["""Undo hotstring"" sound duration [ms]"] . ":" . A_Space . ini_UHSD
	}
	
	WinGetPos, Window1X, Window1Y, Window1W, Window1H, A
	Gui, MSP: Show, Hide AutoSize 
	DetectHiddenWindows, On
	WinGetPos, Window2X, Window2Y, Window2W, Window2H, % "ahk_id" . SoundPar
	DetectHiddenWindows, Off
	
	NewWinPosX := Round(Window1X + (Window1W / 2) - (Window2W / 2))
	NewWinPosY := Round(Window1Y + (Window1H / 2) - (Window2H / 2))
	
	Gui, MSP: Show, % "x" . NewWinPosX . A_Space . "y" . NewWinPosY . A_Space . "AutoSize"	
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_SoundTestBut()
{
	global	;assume-global mode
	Switch A_ThisMenu
	{
		Case "OrdHisTrig":	SoundBeep, % ini_OHSF, % ini_OHSD
		Case "MenuHisTrig":	SoundBeep, % ini_MHSF, % ini_MHSD
		Case "UndoOfH":	SoundBeep, % ini_UHSF, % ini_UHSD
	}
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_SetSoundDuration()
{
	global	;assume-global mode
	Gui, MSP: Submit, NoHide
	Switch A_ThisMenu
	{
		Case "OrdHisTrig":	GuiControl,, % IdMSP_T5, % TransA["""Basic hotstring"" sound duration [ms]"] . ":" . A_Space . ini_OHSD
		Case "MenuHisTrig":	GuiControl,, % IdMSP_T5, % TransA["""Hotstring menu"" sound duration [ms]"] . ":" . A_Space . ini_MHSD
		Case "UndoOfH":	GuiControl,, % IdMSP_T5, % TransA["""Undo hotstring"" sound duration [ms]"] . ":" . A_Space . ini_UHSD
	}
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_SetSoundFrequency()
{
	global	;assume-global mode
	Gui, MSP: Submit, NoHide
	Switch A_ThisMenu
	{
		Case "OrdHisTrig":	GuiControl,, % IdMSP_T3, % TransA["""Basic hotstring"" sound frequency"] . ":" . A_Space . ini_OHSF
		Case "MenuHisTrig":	GuiControl,, % IdMSP_T3, % TransA["""Hotstring menu"" sound frequency"] . ":" . A_Space . ini_MHSF
		Case "UndoOfH":	GuiControl,, % IdMSP_T3, % TransA["""Undo hotstring"" sound frequency"] . ":" . A_Space . ini_UHSF
	}
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_GuiSetTooltipTimeout()
{
	global	;assume-global mode
	local Window1X := 0, Window1Y := 0, Window1W := 0, Window1H := 0
		,Window2X := 0, Window2Y := 0, Window2W := 0, Window2H := 0
		,NewWinPosX := 0, NewWinPosY := 0
		,v_OutVarTemp := 0, 	v_OutVarTempX := 0, 	v_OutVarTempY := 0, 	v_OutVarTempW := 0, 	v_OutVarTempH := 0
		,v_xNext := 0, 		v_yNext := 0, 			v_wNext := 0, 			v_hNext := 0
		,vRadioCheck := true
	
	;+Owner to prevent display of a taskbar button
	Switch (A_ThisMenu)
	{
		Case "OrdHisTrig":	Gui, STD: New, -MinimizeBox -MaximizeBox +Owner +HwndTooltipTimeout, % TransA["Set ""Hotstring was triggered"" tooltip timeout"]
		Case "UndoOfH":	Gui, STD: New, -MinimizeBox -MaximizeBox +Owner +HwndTooltipTimeout, % TransA["Set ""Undid the last hotstring!"" tooltip timeout"]
		Case "TrigTips":	Gui, STD: New, -MinimizeBox -MaximizeBox +Owner +HwndTooltipTimeout, % TransA["Set  triggerstring tip(s) tooltip timeout"]
	}
	Gui, STD: Margin,	% c_xmarg, % c_ymarg
	Gui,	STD: Color,	% c_WindowColor, % c_ControlColor
	Gui,	STD: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, % c_FontType
	
	Switch (A_ThisMenu)
	{
		Case "OrdHisTrig": 	Gui, STD: Add, Text, HwndIdSTD_T1, % TransA["When timeout is set, the tooltip ""Hotstring was triggered"" will dissapear after time reaches it."]
		Case "UndoOfH":	Gui, STD: Add, Text, HwndIdSTD_T1, % TransA["When timeout is set, the tooltip ""Undid the last hotstring!"" will dissapear after time reaches it."]
		Case "TrigTips":	Gui, STD: Add, Text, HwndIdSTD_T1, % TransA["When timeout is set, the triggerstring tip(s) will dissapear after time reaches it."]
	}
	Gui, STD: Add, Text, HwndIdSTD_T2, % TransA["Finite timeout?"]
	
	Switch (A_ThisMenu)
	{
		Case "OrdHisTrig":
		if (ini_OHTD = 0)
			vRadioCheck	:= false
		if (ini_OHTD > 0)
			vRadioCheck	:= true
		Case "UndoOfH":	
		if (ini_UHTD = 0)
			vRadioCheck	:= false
		if (ini_UHTD > 0)
			vRadioCheck	:= true
		Case "TrigTips":	
		if (ini_TTTD = 0)
			vRadioCheck	:= false
		if (ini_TTTD > 0)
			vRadioCheck	:= true
	}
	
	Gui, STD: Add, Radio, HwndIdSTD_R1 vFiniteTttimeout gF_STDRadio Checked%vRadioCheck% Group, % TransA["Yes"]
	vRadioCheck := !vRadioCheck
	Gui, STD: Add, Radio, HwndIdSTD_R2 gF_STDRadio Checked%vRadioCheck%, % TransA["No"]
	Switch (A_ThisMenu)	
	{
		;Case "OrdHisTrig": 	Gui, STD: Add, Slider, x0 y0 HwndIdSTD_S1 vini_OHTD gF_SetTooltipTimeout Line1 Page500 Range1000-10000 TickInterval500 ToolTipBottom Buddy1ini_OHTD, % ini_OHTD
		Case "UndoOfH":	Gui, STD: Add, Slider, x0 y0 HwndIdSTD_S1 vini_UHTD gF_SetTooltipTimeout Line1 Page500 Range1000-10000 TickInterval500 ToolTipBottom Buddy1ini_UHTD, % ini_UHTD
		Case "TrigTips":	Gui, STD: Add, Slider, x0 y0 HwndIdSTD_S1 vini_TTTD gF_SetTooltipTimeout Line1 Page500 Range1000-10000 TickInterval500 ToolTipBottom Buddy1ini_TTTD, % ini_TTTD
	}
	Gui, STD: Font, % "cBlue underline" . A_Space . "s" . c_FontSize + 2
	Gui, STD: Add, Text, HwndIdSTD_T4, ⓘ
	F_TooltipTimeoutSlider := func("F_ShowLongTooltip").bind(TransA["F_TooltipTimeoutSlider"])
	GuiControl +g, % IdSTD_T4, % F_TooltipTimeoutSlider
	Gui,	STD: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, % c_FontType
	v_OutVarTemp := 10000
	Switch (A_ThisMenu)
	{
		Case "OrdHisTrig": 	Gui, STD: Add, Text, HwndIdSTD_T3, % TransA["""Hotstring was triggered"" tooltip timeout in [ms]"] . ":" . A_Space . v_OutVarTemp
		Case "UndoOfH":	Gui, STD: Add, Text, HwndIdSTD_T3, % TransA["""Undid the last hotstring!"" tooltip timeout in [ms]"] . ":" . A_Space . v_OutVarTemp
		Case "TrigTips":	Gui, STD: Add, Text, HwndIdSTD_T3, % TransA["Triggerstring tip(s) tooltip timeout in [ms]"] . ":" . A_Space . v_OutVarTemp
	}
	
	v_xNext := c_xmarg
	v_yNext := c_ymarg
	GuiControl, Move, % IdSTD_T1, % "x" . v_xNext . A_Space . "y" . v_yNext
	v_yNext += HofText
	GuiControl, Move, % IdSTD_T2, % "x" . v_xNext . A_Space . "y" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdSTD_T2
	v_xNext += v_OutVarTempW + c_xmarg
	GuiControl, Move, % IdSTD_R1, % "x" . v_xNext . A_Space . "y" . v_yNext 
	GuiControlGet, v_OutVarTemp, Pos, % IdSTD_R1
	v_xNext += v_OutVarTempW + c_xmarg
	GuiControl, Move, % IdSTD_R2, % "x" . v_xNext . A_Space . "y" . v_yNext 
	GuiControlGet, v_OutVarTemp, Pos, % IdSTD_T1
	v_xNext := c_xmarg
	v_yNext += HofText
	v_wNext := v_OutVarTempW
	GuiControl, Move, % IdSTD_S1, % "x" . v_xNext . A_Space . "y" . v_yNext . A_Space . "w" . v_wNext
	
	GuiControlGet, v_OutVarTemp, Pos, % IdSTD_S1
	v_xNext := v_OutVarTempX + v_OutVarTempW
	GuiControl, Move, % IdSTD_T4, % "x" . v_xNext . A_Space . "y" . v_yNext
	v_xNext := c_xmarg
	v_yNext := v_OutVarTempY + v_OutVarTempH
	GuiControl, Move, % IdSTD_T3, % "x" v_xNext . A_Space . "y" v_yNext
	Switch (A_ThisMenu)
	{
		Case "OrdHisTrig": 	GuiControl,, % IdSTD_T3, % TransA["""Hotstring was triggered"" tooltip timeout in [ms]"] . ":" . A_Space . ini_OHTD
		Case "UndoOfH":	GuiControl,, % IdSTD_T3, % TransA ["""Undid the last hotstring!"" tooltip timeout in [ms]"] . ":" . A_Space . ini_UHTD
		Case "TrigTips":	GuiControl,, % IdSTD_T3, % TransA["Triggerstring tip(s) tooltip timeout in [ms]"] . ":" . A_Space . ini_TTTD
	}
	
	WinGetPos, Window1X, Window1Y, Window1W, Window1H, A
	Gui, STD: Show, Hide AutoSize 
	DetectHiddenWindows, On
	WinGetPos, Window2X, Window2Y, Window2W, Window2H, % "ahk_id" . TooltipTimeout
	DetectHiddenWindows, Off
	
	NewWinPosX := Round(Window1X + (Window1W / 2) - (Window2W / 2))
	NewWinPosY := Round(Window1Y + (Window1H / 2) - (Window2H / 2))
	
	Gui, STD: Show, % "x" . NewWinPosX . A_Space . "y" . NewWinPosY . A_Space . "AutoSize"	
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_STDRadio()
{
	global	;assume-global mode
	
	Gui, STD: Submit, NoHide
	Switch FiniteTttimeout
	{
		Case 1: 
		GuiControl, Enable, % IdSTD_S1
		Switch (A_ThisMenu)
		{
			Case "OrdHisTrig":
			GuiControl,, % IdSTD_T3, % TransA["""Hotstring was triggered"" tooltip timeout in [ms]"] . ":" . A_Space . ini_OHTD
			GuiControl,, % IdSTD_S1, % ini_OHTD
			Case "UndoOfH":
			GuiControl,, % IdSTD_T3, % TransA["""Undid the last hotstring!"" tooltip timeout in [ms]"] . ":" . A_Space . ini_UHTD
			GuiControl,, % IdSTD_S1, % ini_UHTD
			Case "TrigTips":
			GuiControl,, % IdSTD_T3, % TransA["Triggerstring tip(s) tooltip timeout in [ms]"] . ":" . A_Space . ini_TTTD
			GuiControl,, % IdSTD_S1, % ini_TTTD
		}
		Case 2: 
		GuiControl, Disable, % IdSTD_S1
		Switch (A_ThisMenu)
		{
			Case "OrdHisTrig":
			ini_OHTD := 0
			GuiControl,, % IdSTD_T3, % TransA["""Hotstring was triggered"" tooltip timeout in [ms]"] . ":" . A_Space . ini_OHTD
			Case "UndoOfH":
			ini_UHTD := 0
			GuiControl,, % IdSTD_T3, % TransA["""Undid the last hotstring!"" tooltip timeout in [ms]"] . ":" . A_Space . ini_UHTD
			Case "TrigTips":
			ini_TTTD := 0
			GuiControl,, % IdSTD_T3, % TransA["Triggerstring tip(s) tooltip timeout in [ms]"] . ":" . A_Space . ini_TTTD
		}
	}
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_SetTooltipTimeout()
{
	global	;assume-global mode
	Gui, STD: Submit, NoHide
	Switch (A_ThisMenu)
	{
		Case "OrdHisTrig":	GuiControl,, % IdSTD_T3, % TransA["""Hotstring was triggered"" tooltip timeout in [ms]"] . ":" . A_Space . ini_OHTD
		Case "UndoOfH":	GuiControl,, % IdSTD_T3, % TransA["""Undid the last hotstring!"" tooltip timeout in [ms]"] . ":" . A_Space . ini_UHTD
		Case "TrigTips":	GuiControl,, % IdSTD_T3, % TransA["Triggerstring tip(s) tooltip timeout in [ms]"] . ":" . A_Space . ini_TTTD
	}
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_AddToAutostart()
{
	global	;assume-global mode
	local v_Temp1 := true, Target := "", LinkFile_DM := "", LinkFile_SM := "", Args_DM := "", Args_SM := "", Description := "", IconFile := "", WorkingDir := ""
	
	Target 		:= A_ScriptFullPath
	LinkFile_DM	:= A_Startup . "\" . SubStr(A_ScriptName, 1, -4) . "_DM" . "." . "lnk"
	LinkFile_SM	:= A_Startup . "\" . SubStr(A_ScriptName, 1, -4) . "_SM" . "." . "lnk"
	WorkingDir 	:= A_ScriptDir
	Args_DM 		:= ""
	Args_SM		:= "l"
	Description 	:= TransA["Facilitate working with AutoHotkey triggerstring and hotstring concept, with GUI and libraries"] . "."
	IconFile 		:= A_ScriptDir . "\" . AppIcon
	
	Switch A_ThisMenuItem
	{
		Case TransA["Default mode"]:
		Try
			FileCreateShortcut, % Target, % LinkFile_DM, % WorkingDir, % Args_DM, % Description, % IconFile, h, , 7 ;h = shortcut: Ctrl + Shift + h, 7 = Minimized
		Catch
		{
			MsgBox, 16, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["Error"], % A_ThisFunc . A_Space . TransA["Something weng wrong with link file (.lnk) creation"] . ":" 
				. A_Space . ErrorLevel
		}
		F_WhichGui()
		if (!ErrorLevel)
			MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["Link file (.lnk) was created in AutoStart folder"] . ":" . "`n`n"
				. A_Startup . "\" . SubStr(A_ScriptName, 1, -4) . "_DM" . "." . "lnk" . "," . A_Space . TransA["Default mode"]
		Case TransA["Silent mode"]:
		Try
			FileCreateShortcut, % Target, % LinkFile_SM, % WorkingDir, % Args_SM, % Description, % IconFile, h, , 7 ;h = shortcut: Ctrl + Shift + h, 7 = Minimized
		Catch
		{
			MsgBox, 16, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["Error"], % A_ThisFunc . A_Space . TransA["Something weng wrong with link file (.lnk) creation"] . ":" 
				. A_Space . ErrorLevel
		}
		F_WhichGui()
		if (!ErrorLevel)
			MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["Link file (.lnk) was created in AutoStart folder"] . ":" . "`n`n"
				. A_Startup . "\" . SubStr(A_ScriptName, 1, -4) . "_SM" . "." . "lnk" . "," . A_Space . TransA["Silent mode"]
	}
	return
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
;1. Read all inputs. 
;2. Create Hotstring definition according to inputs. 
;3. Read the library file into List View. 
;4. Sort List View. 
;5. Delete library file. 
;6. Save List View into the library file.
;7. Increment library counter.
{
	global ;assume-global mode
	local 	TextInsert := "", Options := "", ModifiedFlag := false
			,OnOff := "", EnDis := ""
			,SendFunHotstringCreate := "", SendFunFileFormat := ""
			,OldOptions := "", TurnOffOldOptions := ""
			,txt := "", txt1 := "", txt2 := "", txt3 := "", txt4 := "", txt5 := "", txt6 := ""
			,v_TheWholeFile := "", v_TotalLines := 0
			,ExternalIndex := 0
			,name := "", key := 0, value := "", Counter := 0, key2 := 0, value2 := ""
			,f_GeneralMatch := false, f_CaseMatch := false
			,SelectedLibraryName := SubStr(v_SelectHotstringLibrary, 1, -4)
			,MaxTableElements	 := a_Library.Count()
			,NoOfIterations	 := MaxTableElements
			,FirstTableIndex	 := 0
	
	;1. Read all inputs. 
	Gui, % A_DefaultGui . ":" A_Space . "Submit", NoHide
	Gui, % A_DefaultGui . ":" A_Space . "+OwnDialogs"
	
	if (Trim(v_TriggerString) = "")
	{
		MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"],  % TransA["Enter triggerstring before hotstring is set"] . "."
		return
	}
	if InStr(v_SelectFunction, "Menu")
	{
		if ((Trim(v_EnterHotstring) = "") and (Trim(v_EnterHotstring1) = "") and (Trim(v_EnterHotstring2) = "") and (Trim(v_EnterHotstring3) = "") and (Trim(v_EnterHotstring4) = "") and (Trim(v_EnterHotstring5) = "") and (Trim(v_EnterHotstring6) = ""))
		{
			MsgBox, 324, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["Replacement text is blank. Do you want to proceed?"]
			IfMsgBox, No
				return
		}
		if (Trim(v_EnterHotstring) != "")
			TextInsert := % TextInsert . "¦" . v_EnterHotstring
		if (Trim(v_EnterHotstring1) != "")
			TextInsert := % TextInsert . "¦" . v_EnterHotstring1
		if (Trim(v_EnterHotstring2) != "")
			TextInsert := % TextInsert . "¦" . v_EnterHotstring2
		if (Trim(v_EnterHotstring3) != "")
			TextInsert := % TextInsert . "¦" . v_EnterHotstring3
		if (Trim(v_EnterHotstring4) != "")
			TextInsert := % TextInsert . "¦" . v_EnterHotstring4
		if (Trim(v_EnterHotstring5) != "")
			TextInsert := % TextInsert . "¦" . v_EnterHotstring5
		if (Trim(v_EnterHotstring6) != "")
			TextInsert := % TextInsert . "¦" . v_EnterHotstring6
		TextInsert := SubStr(TextInsert, 2, StrLen(TextInsert) - 1)
	}
	else
	{
		if (Trim(v_EnterHotstring) = "")
		{
			MsgBox, 324, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["Replacement text is blank. Do you want to proceed?"] 
			IfMsgBox, No
				return
		}
		else
		{
			TextInsert := v_EnterHotstring
		}
	}
	
	if (!v_SelectHotstringLibrary) or (v_SelectHotstringLibrary = TransA["↓ Click here to select hotstring library ↓"])
	{
		MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["Choose existing hotstring library file before saving new (triggerstring, hotstring) definition!"]
		return
	}
	
	if (v_OptionImmediateExecute)
		Options .= "*"
	Switch v_RadioCaseGroup
	{
		Case 2: Options .= "C"
		Case 3: Options .= "C1"
	}
	if (v_OptionNoBackspace)
		Options .= "B0"
	if (v_OptionInsideWord)
		Options .= "?"
	if (v_OptionNoEndChar)
		Options .= "O"
	if (v_OptionReset)
		Options .= "Z"
	if (v_OptionDisable)
	{
		OnOff := "Off"
		EnDis := "Dis"	
	}
	else
	{
		OnOff := "On"
		EnDis := "En"
	}
	Switch v_SelectFunction
	{
		Case "Clipboard (CL)": 			
		SendFunHotstringCreate 	:= "F_HOF_CLI"
		SendFunFileFormat 		:= "CL"
		Case "SendInput (SI)": 			
		SendFunHotstringCreate 	:= "F_HOF_SI"
		SendFunFileFormat 		:= "SI"
		Case "Menu & Clipboard (MCL)": 	
		SendFunHotstringCreate 	:= "F_HOF_MCLI"
		SendFunFileFormat 		:= "MCL"
		Case "Menu & SendInput (MSI)": 
		SendFunHotstringCreate 	:= "F_HOF_MSI"
		SendFunFileFormat 		:= "MSI"
		Case "SendRaw (SR)":
		SendFunHotstringCreate 	:= "F_HOF_SR"
		SendFunFileFormat 		:= "SR"
		Case "SendPlay (SP)":
		SendFunHotstringCreate 	:= "F_HOF_SP"
		SendFunFileFormat 		:= "SP"
		Case "SendEvent (SE)":
		SendFunHotstringCreate 	:= "F_HOF_SE"
		SendFunFileFormat 		:= "SE"
	}
	
	;2. Create or modify (triggerstring, hotstring) definition according to inputs. 
	Gui, HS3: Default			;All of the ListView function operate upon the current default GUI window.
	GuiControl, -Redraw, % IdListView1 ; -Readraw: This option serves as a hint to the control that allows it to allocate memory only once rather than each time a row is added, which greatly improves row-adding performance (it may also improve sorting performance). 
	for key, value in a_Triggerstring
	{
		f_GeneralMatch 	:= false
		f_CaseMatch 		:= false
		if (a_Triggerstring[key] = v_Triggerstring)	;case insensitive string comparison!
		{
			f_GeneralMatch := true
			if (a_Triggerstring[key] == v_Triggerstring)
				f_CaseMatch := true
			;*[One]
			if (a_Library[key] = SubStr(v_SelectHotstringLibrary, 1, -4))
			{
				OldOptions := a_TriggerOptions[key]
				if (f_CaseMatch and !InStr(OldOptions, "C1") and InStr(OldOptions, "C") and !InStr(Options, "C1") and InStr(Options, "C"))	;tu jestem 
				{
					ModifiedFlag 			:= false
				}				
				else 
				{
					MsgBox, 68, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"]
						, % TransA["The hostring"] . A_Space . """" .  a_Triggerstring[key] . """" . A_Space .  TransA["exists in the currently selected library"] . ":" . A_Space . a_Library[key] . ".csv" . "." . "`n`n" 
						. TransA["Do you want to proceed?"]
						. "`n`n" . TransA["If you answer ""Yes"" it will overwritten."]
					IfMsgBox, No
						Break
					IfMsgBox, Yes
					{
						if (InStr(OldOptions, "*") and !InStr(Options,"*"))
							OldOptions := StrReplace(OldOptions, "*", "*0")
						if (InStr(OldOptions, "B0") and !InStr(Options, "B0"))
							OldOptions := StrReplace(OldOptions, "B0", "B")
						if (InStr(OldOptions, "O") and !InStr(Options, "O"))
							OldOptions := StrReplace(OldOptions, "O", "O0")
						if (InStr(OldOptions, "Z") and !InStr(Options, "Z"))
							OldOptions := StrReplace(OldOptions, "Z", "Z0")
						Try
							Hotstring(":" . OldOptions . ":" . v_TriggerString, , "Off") ;Disables existing hotstring
						Catch
							MsgBox, 16, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["Error"], % A_ThisFunc . A_Space . TransA["Something went wrong with hotstring deletion"] . ":" . "`n`n" 
								. "v_TriggerString:" . A_Tab . v_TriggerString . "`n"
								. "OldOptions:" . A_Tab . OldOptions . "`n`n" . TransA["Library name:"] . A_Space . v_SelectHotstringLibrary
						if (InStr(Options, "O"))	;Add new hotstring which replaces the old one
						{
							Try
								Hotstring(":" . Options . ":" . v_TriggerString, func(SendFunHotstringCreate).bind(TextInsert, true), OnOff)
							Catch
								MsgBox, 16, % SubStr(A_ScriptName, 1, -4) . A_Space . TransA["Error"], % A_ThisFunc . A_Space . TransA["Something went wrong during hotstring setup"] . ":" . "`n`n"
								. "Hotstring(:" . Options . ":" . v_Triggerstring . "," . "func(" . SendFunHotstringCreate . ").bind(" . TextInsert . "," . A_Space . true . ")," . A_Space . OnOff . ")"
						}
						else
						{
							Try
								Hotstring(":" . Options . ":" . v_TriggerString, func(SendFunHotstringCreate).bind(TextInsert, false), OnOff)
							Catch
								MsgBox, 16, % SubStr(A_ScriptName, 1, -4) . A_Space . TransA["Error"], % A_ThisFunc . A_Space . TransA["Something went wrong during hotstring setup"] . ":" . "`n`n"
								. "Hotstring(:" . Options . ":" . v_Triggerstring . "," . "func(" . SendFunHotstringCreate . ").bind(" . TextInsert . "," . A_Space . false . ")," . A_Space . OnOff . ")"
						}
						a_TriggerOptions[key] 	:= Options
						a_OutputFunction[key] 	:= SendFunFileFormat
						a_Hotstring[key] 		:= TextInsert
						a_EnableDisable[key]	:= EnDis
						a_Comment[key] 		:= v_Comment
						ModifiedFlag 			:= true
						
						;*[One]
						Loop, % NoOfIterations
						{
							FirstTableIndex++
							if (a_Library[FirstTableIndex] = SelectedLibraryName)
							{
								Counter++
								if (a_Triggerstring[FirstTableIndex] = v_Triggerstring)	;case insensitive string comparison!
									Break
							}
						}
						NoOfIterations := MaxTableElements - FirstTableIndex
						;*[One]
						LV_Modify(Counter, "", v_TriggerString, Options, SendFunFileFormat, EnDis, TextInsert, v_Comment)		
					}
				}
			}
			else
			{
				MsgBox, 68, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"]
					, % TransA["The hostring"] . A_Space . """" .  v_TriggerString . """" . A_Space .  TransA["already exists in another library"] . ":" . A_Space . a_Library[key] . "." . "`n`n" 
					. TransA["Do you want to proceed?"] . "`n`n" . TransA["If you answer ""No"" edition of the current definition will be interrupted."]
					. "`n" . TransA["If you answer ""Yes"" definition existing in another library will not be changed."]
				IfMsgBox, No
					return
			}
		}
	}
	
	if !(ModifiedFlag) 
	{
	;OutputDebug, % "Options:" . A_Space . Options . A_Tab . "OldOptions:" . A_Space . OldOptions . A_Tab . "v_TriggerString:" . A_Space . v_TriggerString
		if (InStr(Options, "O"))
		{
			Try
				Hotstring(":" . Options . ":" . v_TriggerString, func(SendFunHotstringCreate).bind(TextInsert, true), OnOff)
			Catch
				MsgBox, 16, % SubStr(A_ScriptName, 1, -4) . A_Space . TransA["Error"], % A_ThisFunc . A_Space . TransA["Something went wrong during hotstring setup"] . ":" . "`n`n"
				. "Hotstring(:" . Options . ":" . v_Triggerstring . "," . "func(" . SendFunHotstringCreate . ").bind(" . TextInsert . "," . A_Space . true . ")," . A_Space . OnOff . ")"
		}
		else
		{
			Try
				Hotstring(":" . Options . ":" . v_TriggerString, func(SendFunHotstringCreate).bind(TextInsert, false), OnOff)
			Catch
				MsgBox, 16, % SubStr(A_ScriptName, 1, -4) . A_Space . TransA["Error"], % A_ThisFunc . A_Space . TransA["Something went wrong during hotstring setup"] . ":" . "`n`n"
				. "Hotstring(:" . Options . ":" . v_Triggerstring . "," . "func(" . SendFunHotstringCreate . ").bind(" . TextInsert . "," . A_Space . false . ")," . A_Space . OnOff . ")"
		}
		LV_Add("",  v_Triggerstring, Options, SendFunFileFormat, EnDis, TextInsert, v_Comment)
		a_Triggers.Push(v_TriggerString) ;added to table of hotstring recognizer (a_Triggers)
		F_Sort_a_Triggers()
		a_Library.Push(SubStr(v_SelectHotstringLibrary, 1, -4))
		a_Triggerstring.Push(v_Triggerstring)
		a_TriggerOptions.Push(Options)
		a_OutputFunction.Push(SendFunFileFormat)
		a_EnableDisable.Push(EnDis)	;here was a bug: OnOff instead of EnDis
		a_Hotstring.Push(TextInsert)
		a_Comment.Push(v_Comment)
	}
	
	;4. Sort List View. ;future: gui parameter for sorting 
	LV_ModifyCol(1, "Sort")
	;5. Delete library file. 
	FileDelete, % HADL . "\" . v_SelectHotstringLibrary
	
	;6. Save List View into the library file.
	Loop, % LV_GetCount()
	{
		LV_GetText(txt1, A_Index, 2)
		LV_GetText(txt2, A_Index, 1)
		LV_GetText(txt3, A_Index, 3)
		LV_GetText(txt4, A_Index, 4)
		LV_GetText(txt5, A_Index, 5)
		LV_GetText(txt6, A_Index, 6)
		txt .= txt1 . "‖" . txt2 . "‖" . txt3 . "‖" . txt4 . "‖" . txt5 . "‖" . txt6 . "`n"
	}
	FileAppend, % txt, % HADL . "\" . v_SelectHotstringLibrary, UTF-8
	GuiControl, +Redraw, % IdListView1 ;Afterward, use GuiControl, +Redraw to re-enable redrawing (which also repaints the control).
	;7. Increment library counter.
	if !(ModifiedFlag) 
	{
		++v_LibHotstringCnt
		++v_TotalHotstringCnt
		GuiControl, , % IdText13,  % v_LibHotstringCnt
		GuiControl, , % IdText13b, % v_LibHotstringCnt
		GuiControl, , % IdText12,  % v_TotalHotstringCnt
		GuiControl, , % IdText12b, % v_TotalHotstringCnt
	}
	MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["Hotstring added to the file"] . A_Space . v_SelectHotstringLibrary . "!" 
	
	return
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_Clear()
{
	global	;assume-global mode
	Gui,		  HS3: Font, % "c" . c_FontColor
	GuiControl, HS3:, % IdEdit1,  				;v_TriggerString
	GuiControl, HS3: Font, % IdCheckBox1
	GuiControl, HS3:, % IdCheckBox1, 0
	GuiControl, HS3: Font, % IdRadioCaseCC
	GuiControl, HS3: Font, % IdRadioCaseCS
	GuiControl, HS3: Font, % IdRadioCaseC1
	GuiControl, HS3:, v_RadioCaseGroup, 1
	;GuiControl, HS3:, % IdRadioCaseCC, 1
	;GuiControl, HS3:, % IdRadioCaseCS, 0
	;GuiControl, HS3:, % IdRadioCaseC1, 0
	GuiControl, HS3: Font, % IdCheckBox3
	GuiControl, HS3:, % IdCheckBox3, 0
	GuiControl, HS3: Font, % IdCheckBox4
	GuiControl, HS3:, % IdCheckBox4, 0
	GuiControl, HS3: Font, % IdCheckBox5
	GuiControl, HS3:, % IdCheckBox5, 0
	GuiControl, HS3: Font, % IdCheckBox6
	GuiControl, HS3:, % IdCheckBox6, 0
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
	GuiControl, HS3: Disable, % IdButton4
	GuiControl, HS3:, % IdEdit10,  				;Sandbox
	GuiControl, HS3: ChooseString, % IdDDL2, % TransA["↓ Click here to select hotstring library ↓"]
	if (A_DefaultGui = "HS3")
		LV_Delete()
	
	Gui,		  HS4: Font, % "c" . c_FontColor
	GuiControl, HS4:, % IdEdit1b,  				;v_TriggerString
	GuiControl, HS4: Font, % IdCheckBox1b
	GuiControl, HS4: Font, % IdRadioCaseCCb
	GuiControl, HS4: Font, % IdRadioCaseCSb
	GuiControl, HS4:, v_RadioCaseGroup, 1
	;GuiControl, HS4:, % IdCheckBox1b, 0
	;GuiControl, HS4:, % IdRadioCaseCCb, 1
	;GuiControl, HS4:, % IdRadioCaseCSb, 0
	GuiControl, HS4: Font, % IdRadioCaseC1b
	GuiControl, HS4:, % IdRadioCaseC1b, 0
	GuiControl, HS4: Font, % IdCheckBox3b
	GuiControl, HS4:, % IdCheckBox3b, 0
	GuiControl, HS4: Font, % IdCheckBox4b
	GuiControl, HS4:, % IdCheckBox4b, 0
	GuiControl, HS4: Font, % IdCheckBox5b
	GuiControl, HS4:, % IdCheckBox5b, 0
	GuiControl, HS4: Font, % IdCheckBox6b
	GuiControl, HS4:, % IdCheckBox6b, 0
	GuiControl, HS4: Font, % IdCheckBox8b
	GuiControl, HS4:, % IdCheckBox8b, 0
	GuiControl, HS4: Choose, % IdDDL1b, SendInput (SI) ;v_SelectFunction 
	GuiControl, HS4: , % IdEdit2b,  				;v_EnterHotstring
	GuiControl, HS4: , % IdEdit3b, 					;v_EnterHotstring1
	GuiControl, HS4: Disable, % IdEdit3b 			;v_EnterHotstring1
	GuiControl, HS4: , % IdEdit4b, 					;v_EnterHotstring2
	GuiControl, HS4: Disable, % IdEdit4b 			;v_EnterHotstring2
	GuiControl, HS4: , % IdEdit5b, 					;v_EnterHotstring3
	GuiControl, HS4: Disable, % IdEdit5b 			;v_EnterHotstring3
	GuiControl, HS4: , % IdEdit6b, 					;v_EnterHotstring4
	GuiControl, HS4: Disable, % IdEdit6b 			;v_EnterHotstring4
	GuiControl, HS4: , % IdEdit7b, 					;v_EnterHotstring5
	GuiControl, HS4: Disable, % IdEdit7b 			;v_EnterHotstring5
	GuiControl, HS4: , % IdEdit8b, 					;v_EnterHotstring6
	GuiControl, HS4: Disable, % IdEdit8b 			;v_EnterHotstring6
	GuiControl, HS4: , % IdEdit9b,  				;Comment
	GuiControl, HS4: Disable, % IdButton4b
	GuiControl, HS4: , % IdEdit10b,  				;Sandbox
	GuiControl, HS4: ChooseString, % IdDDL2b, % TransA["↓ Click here to select hotstring library ↓"]
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_Move()
{
	global	;assume-global mode
	local v_DestinationLibrary := 0, v_Temp1 := "", v_Temp2 := ""
		,txt := "", txt1 := "", txt2 := "", txt3 := "", txt4 := "", txt5 := "", txt6 := ""
	
	Gui, MoveLibs: Submit, NoHide
	v_DestinationLibrary := LV_GetNext()
	if (!v_DestinationLibrary) 
	{
		MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"],  % TransA["Select a row in the list-view, please!"]
		return
	}
	LV_GetText(v_SelectHotstringLibrary, v_DestinationLibrary) ;destination
	Gui, MoveLibs: Destroy
	Gui, HS3Search: Hide	
	F_SelectLibrary()
	Loop, % LV_GetCount()
	{
		v_Temp2 := LV_GetText(v_Temp1, A_Index, 1)
		if (v_Temp1 == v_TriggerString)
		{
			MsgBox, 308, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["warning"], % TransA["The hostring"] . ":" . "`n`n" . v_Triggerstring . "`n`n" . TransA["exists in a file and will now be replaced."] 
				. "`n" . v_SelectHotstringLibrary . "`n`n" . TransA["Do you want to proceed?"]
			IfMsgBox, Yes
			{
				LV_Delete(A_Index)
				LV_Add("",  v_Triggerstring, v_TriggOpt, v_OutFun, v_EnDis, v_Hotstring, v_Comment)
			}
			IfMsgBox, No
				return
		}
	}
	
	LV_Add("", v_Triggerstring, v_TriggOpt, v_OutFun, v_EnDis, v_Hotstring, v_Comment) ;add to ListView
	LV_ModifyCol(1, "Sort")
	FileDelete, % HADL . "\" . v_SelectHotstringLibrary	;delete the old destination file.
	
	Loop, % LV_GetCount() ;Saving the same destination filename but now containing moved (triggerstring, hotstring) definition.
	{
		LV_GetText(txt1, A_Index, 2)
		LV_GetText(txt2, A_Index, 1)
		LV_GetText(txt3, A_Index, 3)
		LV_GetText(txt4, A_Index, 4)
		LV_GetText(txt5, A_Index, 5)
		LV_GetText(txt6, A_Index, 6)
		txt .= txt1 . "‖" . txt2 . "‖" . txt3 . "‖" . txt4 . "‖" . txt5 . "‖" . txt6 . "`n"
	}
	FileAppend, % txt, % HADL . "\" . v_SelectHotstringLibrary, UTF-8
	
	F_SelectLibrary() ;Remove the definition from source table / file.
	Loop, % LV_GetCount()
	{
		LV_GetText(v_Temp1, A_Index, 1)
		if (v_Temp1 == v_TriggerString)
		{
			LV_Delete(A_Index)
			break
		}
	}
	FileDelete, % HADL . "\" . v_SourceLibrary	;delete the old source filename.
	Loop, % LV_GetCount() ;Saving the same filename but now without deleted (triggerstring, hotstring) definition.
	{
		LV_GetText(txt1, A_Index, 2)
		LV_GetText(txt2, A_Index, 1)
		LV_GetText(txt3, A_Index, 3)
		LV_GetText(txt4, A_Index, 4)
		LV_GetText(txt5, A_Index, 5)
		LV_GetText(txt6, A_Index, 6)
		txt .= txt1 . "‖" . txt2 . "‖" . txt3 . "‖" . txt4 . "‖" . txt5 . "‖" . txt6 . "`n"
	}
	FileAppend, % txt, % HADL . "\" . v_SourceLibrary, UTF-8
	F_Clear()
	F_LoadLibrariesToTables()	; Hotstrings are already loaded by function F_LoadHotstringsFromLibraries(), but auxiliary tables have to be loaded again. Those (auxiliary) tables are used among others to fill in LV_ variables.
	F_Searching("ReloadAndView")
	return 
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_GuiMoveLibs_CreateDetermine()
{
	global	;assume-global mode
	local v_OutVarTemp1 := 0, 	v_OutVarTemp1X := 0, 	v_OutVarTemp1Y := 0, 	v_OutVarTemp1W := 0, 	v_OutVarTemp1H := 0
		,v_OutVarTemp2 := 0, 	v_OutVarTemp2X := 0, 	v_OutVarTemp2Y := 0, 	v_OutVarTemp2W := 0, 	v_OutVarTemp2H := 0
		,v_OutVarTemp3 := 0, 	v_OutVarTemp3X := 0, 	v_OutVarTemp3Y := 0, 	v_OutVarTemp3W := 0, 	v_OutVarTemp3H := 0
							,v_xNext := 0, 		v_yNext := 0, 			v_wNext := 0, 			v_hNext := 0
		,v_WB1 := 0,			v_WB2 := 0,			v_DB := 0
		,key := "",			value := 0,			v_SelectedRow := 0
	
	Gui, MoveLibs: New, 	-Caption +Border -Resize +HwndMoveLibsHwnd +Owner
	Gui, MoveLibs: Margin,	% c_xmarg, % c_ymarg
	Gui,	MoveLibs: Color,	% c_WindowColor, % c_ControlColor
	Gui,	MoveLibs: Font, 	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, 	% c_FontType
	Gui, MoveLibs: Default
	
	Gui, MoveLibs: Add, Text,     x0 y0 HwndIdMoveLibs_T1, 						% TransA["Select the target library:"]
	Gui, MoveLibs: Add, ListView, x0 y0 HwndIdMoveLibs_LV LV0x1 +AltSubmit -Hdr -Multi, 	| 	;-Hdr (minus Hdr) to omit the header (the special top row that contains column titles). "|" is required!
	Gui, MoveLibs: Add, Button, 	x0 y0 HwndIdMoveLibs_B1 Default gF_Move,			% TransA["Move (F8)"]
	Gui, MoveLibs: Add, Button, 	x0 y0 HwndIdMoveLibs_B2 gCancelMove, 				% TransA["Cancel"]
	
	v_xNext := c_xmarg
	v_yNext := c_ymarg
	GuiControl, Move, % IdMoveLibs_T1, % "x" v_xNext "y" v_yNext
	
	GuiControlGet, v_OutVarTemp2, Pos, % IdMoveLibs_LV
	v_yNext := HofText + c_ymarg
	v_hNext := v_OutVarTemp2H * 4
	GuiControl, Move, % IdMoveLibs_LV, % "x" v_xNext "y" v_yNext "h" v_hNext ; by default ListView shows just 5 rows
	
	GuiControlGet, v_OutVarTemp1, Pos, % IdMoveLibs_LV
	GuiControlGet, v_OutVarTemp2, Pos, % IdMoveLibs_B1
	GuiControlGet, v_OutVarTemp3, Pos, % IdMoveLibs_B2
	
	v_WB1 := v_OutVarTemp2W + 2 * c_xmarg
	v_WB2 := v_OutVarTemp3W + 2 * c_xmarg
	v_DB  := v_OutVarTemp1W - (v_WB1 + v_WB2)
	
	v_xNext := c_xmarg
	v_yNext := v_OutVarTemp1Y + v_OutVarTemp1H + c_ymarg
	v_wNext := v_WB1
	GuiControl, Move, % IdMoveLibs_B1, % "x" v_xNext "y" v_yNext "w" v_wNext
	
	v_xNext := c_xmarg + v_WB1 + v_DB
	v_wNext := v_WB2
	GuiControl, Move, % IdMoveLibs_B2, % "x" v_xNext "y" v_yNext "w" v_wNext
	
	for key, value in ini_LoadLib
		if (value)
			LV_Add("", key)
	return
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

F_MoveList() 
{
	global	;assume-global mode
	local 	v_SelectedRow := 0
			,Window1X := 0, Window1Y := 0, Window1W := 0, Window1H := 0
			,Window2X := 0, Window2Y := 0, Window2W := 0, Window2H := 0
			,NewWinPosX := 0, NewWinPosY := 0
	
	Gui, HS3Search: Submit, NoHide 
	WinGetPos, Window1X, Window1Y, Window1W, Window1H, A
	F_GuiMoveLibs_CreateDetermine()
	Gui, MoveLibs: Show, Hide
	
	DetectHiddenWindows, On
	WinGetPos, Window2X, Window2Y, Window2W, Window2H, % "ahk_id" . MoveLibsHwnd
	DetectHiddenWindows, Off
	NewWinPosX := Round(Window1X + (Window1W / 2) - (Window2W / 2))
	NewWinPosY := Round(Window1Y + (Window1H / 2) - (Window2H / 2))
	
	Gui, HS3Search: Default
	v_SelectedRow := LV_GetNext()	;this variable now contains row number of source table
	if !(v_SelectedRow) 
	{
		MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"],  % TransA["Select a row in the list-view, please!"]
		return
	}
	;The following lines will be used by "next function": Move, moving of (triggerstrin, hotstring) definition between libraries.
	LV_GetText(v_SourceLibrary,	v_SelectedRow, 1)
	v_SourceLibrary .= ".csv"
	LV_GetText(v_Triggerstring, 	v_SelectedRow, 2)
	LV_GetText(v_TriggOpt,		v_SelectedRow, 3)
	LV_GetText(v_OutFun,		v_SelectedRow, 4)
	LV_GetText(v_EnDis,			v_SelectedRow, 5)
	LV_GetText(v_Hotstring,		v_SelectedRow, 6)
	LV_GetText(v_Comment,		v_SelectedRow, 7)
	
	Gui, MoveLibs: Show, % "AutoSize" . A_Space . "X" . NewWinPosX . A_Space . "Y" . NewWinPosY . A_Space . "yCenter"
	return
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_HSLV2() ;load content of chosen row from Search Gui into HS3 Gui
{
	global	;assume-global mode
	local v_SelectedRow2 := 0, v_Library := "", v_TriggerString := "", v_SearchedTriggerString := ""
	static v_PreviousSelectedRow2 := 0
;The following lines protect from refreshing of ListView if user chooses the same row couple of times.
	v_PreviousSelectedRow2 := v_SelectedRow2
	v_SelectedRow2 := LV_GetNext()
	If (!v_SelectedRow2) ;if empty
		return
	if (v_PreviousSelectedRow2 == v_SelectedRow2) ;if the same
		return
	
	LV_GetText(v_Library, 		v_SelectedRow2, 1)
	LV_GetText(v_TriggerString, 	v_SelectedRow2, 2)
	
	v_SelectHotstringLibrary := % v_Library . ".csv"
	
	GuiControl, Choose, % IdDDL2, % v_SelectHotstringLibrary
	F_SelectLibrary()
	
	v_SearchedTriggerString := v_TriggerString
	Loop
	{
		LV_GetText(v_TriggerString, A_Index, 1)
		if (v_TriggerString == v_SearchedTriggerString)
		{
			LV_Modify(A_Index, "Vis +Select +Focus")
			break
		}
	}
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_SearchPhrase()
{
	global	;assume-global mode
	local	Each := 0, FileName := ""
	
;Gui, HS3Search:Default
	Gui, HS3Search: Submit, NoHide
	if getkeystate("CapsLock","T") ;I don't understand it
		return
	GuiControlGet, v_SearchTerm
	GuiControl, -Redraw, % IdSearchLV1	;Trick: use GuiControl, -Redraw, MyListView prior to adding a large number of rows. Afterward, use GuiControl, +Redraw, MyListView to re-enable redrawing (which also repaints the control).
	LV_Delete()
	Switch v_RadioGroup
	{
		Case 1:
		For Each, FileName in a_Triggerstring
		{
			if (v_SearchTerm)
			{
				if (InStr(FileName, v_SearchTerm) = 1) ; for matching at the start ;for overall matching without = 1
					LV_Add("", a_Library[A_Index], FileName, a_TriggerOptions[A_Index], a_OutputFunction[A_Index], a_EnableDisable[A_Index], a_Hotstring[A_Index], a_Comment[A_Index])
			}
			else
				LV_Add("", a_Library[A_Index], FileName, a_TriggerOptions[A_Index], a_OutputFunction[A_Index], a_EnableDisable[A_Index], a_Hotstring[A_Index], a_Comment[A_Index])
		}
		LV_ModifyCol(2,"Sort") 	
		Case 2:
		For Each, FileName in a_Hotstring
		{
			if (v_SearchTerm)
			{
				if (InStr(FileName, v_SearchTerm) = 1) ; for overall matching
					LV_Add("", a_Library[A_Index], a_Triggerstring[A_Index], a_TriggerOptions[A_Index], a_OutputFunction[A_Index], a_EnableDisable[A_Index], FileName, a_Comment[A_Index])
			}
			else
				LV_Add("", a_Library[A_Index], a_Triggerstring[A_Index], a_TriggerOptions[A_Index], a_OutputFunction[A_Index], a_EnableDisable[A_Index], FileName, a_Comment[A_Index])
		}
		LV_ModifyCol(6, "Sort")	
		Case 3:
		For Each, FileName in a_Library
		{
			if (v_SearchTerm)
			{
				if (InStr(FileName, v_SearchTerm) = 1) ; for matching at the start
					LV_Add("", FileName, a_Triggerstring[A_Index], a_TriggerOptions[A_Index], a_OutputFunction[A_Index], a_EnableDisable[A_Index], a_Hotstring[A_Index], a_Comment[A_Index])
			}
			else
				LV_Add("", FileName, a_Triggerstring[A_Index], a_TriggerOptions[A_Index], a_OutputFunction[A_Index], a_EnableDisable[A_Index], a_Hotstring[A_Index], a_Comment[A_Index])
		}
		LV_ModifyCol(1,"Sort")
	}
	GuiControl, +Redraw, % IdSearchLV1 ;Trick: use GuiControl, -Redraw, MyListView prior to adding a large number of rows. Afterward, use GuiControl, +Redraw, MyListView to re-enable redrawing (which also repaints the control).
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_Searching(ReloadListView*)
{
	global	;assume-global mode
	local	Window1X := 0, 	Window1Y := 0, 	Window1W := 0, 	Window1H := 0
			,Window2X := 0, 	Window2Y := 0, 	Window2W := 0, 	Window2H := 0
			,NewWinPosX := 0, 	NewWinPosY := 0
			,WhichGui := ""
	
	Switch ReloadListView[1]
	{
		Case "ReloadAndView":
		WinGetPos, Window1X, Window1Y, Window1W, Window1H, % "ahk_id" . HS3GuiHwnd
		Gui, HS3Search: Default
		GuiControl, % "Count" . a_Library.MaxIndex() . A_Space . "-Redraw", % IdListView1 ;This option serves as a hint to the control that allows it to allocate memory only once rather than each time a row is added, which greatly improves row-adding performance (it may also improve sorting performance). 
		LV_Delete()
		Loop, % a_Library.MaxIndex() ; Those arrays have been loaded by F_LoadLibrariesToTables()
			LV_Add("", a_Library[A_Index], a_Triggerstring[A_Index], a_TriggerOptions[A_Index], a_OutputFunction[A_Index], a_EnableDisable[A_Index], a_Hotstring[A_Index], a_Comment[A_Index])
		GuiControl, +Redraw, % IdListView1 ;Afterward, use GuiControl, +Redraw to re-enable redrawing (which also repaints the control).
		Switch v_RadioGroup
		{
			Case 1: LV_ModifyCol(2, "Sort") ;by default: triggerstring
			Case 2: LV_ModifyCol(6, "Sort")
			Case 3: LV_ModifyCol(1, "Sort")
		}
		WinGetPos, Window1X, Window1Y, Window1W, Window1H, % "ahk_id" . HS3GuiHwnd
		Gui, HS3Search: Show, % "X" . Window1X . A_Space . "Y" . Window1Y . A_Space . "W" HS3MinWidth . A_Space . "H" HS3MinHeight	;no idea why twice, but then it shows correct size
		Gui, HS3Search: Show, % "X" . Window1X . A_Space . "Y" . Window1Y . A_Space . "W" HS3MinWidth . A_Space . "H" HS3MinHeight 
		Case "Reload":
		Gui, HS3Search: Default
		GuiControl, % "Count" . a_Library.MaxIndex() . A_Space . "-Redraw", % IdListView1 ;This option serves as a hint to the control that allows it to allocate memory only once rather than each time a row is added, which greatly improves row-adding performance (it may also improve sorting performance). 
		LV_Delete()
		Loop, % a_Library.MaxIndex() ; Those arrays have been loaded by F_LoadLibrariesToTables()
			LV_Add("", a_Library[A_Index], a_Triggerstring[A_Index], a_TriggerOptions[A_Index], a_OutputFunction[A_Index], a_EnableDisable[A_Index], a_Hotstring[A_Index], a_Comment[A_Index])
		GuiControl, +Redraw, % IdListView1 ;Afterward, use GuiControl, +Redraw to re-enable redrawing (which also repaints the control).
		Case TransA["Search Hotstrings (F3)"]:
		Goto, ViewOnly
		Case "": ;view only
		ViewOnly:
		F_WhichGui()
		Switch A_DefaultGui
		{
			Case "HS3": 
			WinGetPos, Window1X, Window1Y, Window1W, Window1H, % "ahk_id" . HS3GuiHwnd
			WhichGui := "HS3"
			Case "HS4": 
			WinGetPos, Window1X, Window1Y, Window1W, Window1H, % "ahk_id" . HS4GuiHwnd 
			WhichGui := "HS4"
		}
		Gui, HS3Search: Default
		Switch WhichGui
		{
			Case "HS3":
			Gui, HS3Search: Show, % "X" . Window1X . A_Space . "Y" . Window1Y . A_Space . "W" HS3MinWidth . A_Space . "H" HS3MinHeight	;no idea why twice, but then it shows correct size
			Gui, HS3Search: Show, % "X" . Window1X . A_Space . "Y" . Window1Y . A_Space . "W" HS3MinWidth . A_Space . "H" HS3MinHeight 
			Case "HS4":
			Gui, HS3Search: Show, % "X" . Window1X . A_Space . "Y" . Window1Y . A_Space . "W" HS4MinWidth . A_Space . "H" HS4MinHeight	;no idea why twice, but then it shows correct size
			Gui, HS3Search: Show, % "X" . Window1X . A_Space . "Y" . Window1Y . A_Space . "W" HS4MinWidth . A_Space . "H" HS4MinHeight 
		}
	}
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_GuiSearch_CreateObject()
{
	global	;assume-global mode
	
	;1. Prepare Gui general parameters
	Gui, HS3Search: New, 	% "+Resize +HwndHS3SearchHwnd +Owner +MinSize" HS3MinWidth + 3 * c_xmarg "x" HS3MinHeight, % TransA["Search Hotstrings"]
	Gui, HS3Search: Margin,	% c_xmarg, % c_ymarg
	Gui,	HS3Search: Color,	% c_WindowColor, % c_ControlColor
	
	;2. Prepare alll Gui objects
	Gui,	HS3Search: Font,% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, HS3Search: Add, Text, 		x0 y0 HwndIdSearchT1,								% TransA["Phrase to search for:"]
	Gui, HS3Search: Add, Text, 		x0 y0 HwndIdSearchT2,								% TransA["Search by:"]
	Gui,	HS3Search: Font, % "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, 	% c_FontType
	Gui, HS3Search: Add, Edit, 		x0 y0 HwndIdSearchE1 vv_SearchTerm gF_SearchPhrase
	Gui, HS3Search: Add, Radio, 		x0 y0 HwndIdSearchR1 vv_RadioGroup gF_SearchPhrase Checked, % TransA["Triggerstring"]
	Gui, HS3Search: Add, Radio, 		x0 y0 HwndIdSearchR2 gF_SearchPhrase, 					% TransA["Hotstring"]
	Gui, HS3Search: Add, Radio, 		x0 y0 HwndIdSearchR3 gF_SearchPhrase, 					% TransA["Library"]
	Gui, HS3Search: Add, Button, 		x0 y0 HwndIdSearchB1 gF_MoveList Default,				% TransA["Move (F8)"]
	Gui, HS3Search: Add, ListView, 	x0 y0 HwndIdSearchLV1 gF_HSLV2 +AltSubmit Grid -Multi,		% TransA["Library|Triggerstring|Trigger Options|Output Function|Enable/Disable|Hotstring|Comment"]
	;Gui, HS3Search: Add, Text, 		x0 y0 HwndIdSearchT3 0x7 vLine2						;0x7 = SS_BLACKFRAME Specifies a box with a frame drawn in the same color as the window frames. This color is black in the default color scheme.
	Gui, HS3Search: Add, Text, 		x0 y0 HwndIdSearchT4, 								% TransA["F3 or Esc: Close Search hotstrings | F8: Move hotstring between libraries"]
	
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_GuiSearch_DetermineConstraints()
{
	global	;assume-global mode
	local v_OutVarTemp := 0, 	v_OutVarTempX := 0, 	v_OutVarTempY := 0, 	v_OutVarTempW := 0, 	v_OutVarTempH := 0
		,v_xNext := 0, 		v_yNext := 0, 			v_wNext := 0, 			v_hNext := 0
		,v_ButtonW := 0
	
	v_xNext := c_xmarg
	v_yNext := c_ymarg
	GuiControl, Move, % IdSearchT1, % "x" v_xNext "y" v_yNext ;Phrase to search
	v_yNext += HofText
	GuiControlGet, v_OutVarTemp, Pos, % IdSearchE1
	v_wNext := v_OutVarTempW * 2
	GuiControl, Move, % IdSearchE1, % "x" v_xNext "y" v_yNext "w" v_wNext
	
	GuiControlGet, v_OutVarTemp, Pos, % IdSearchE1
	v_xNext := c_xmarg + v_OutVarTempW + 2 * c_xmarg
	v_yNext := c_ymarg
	GuiControl, Move, % IdSearchT2, % "x" v_xNext "y" v_yNext	;Search by
	v_yNext += HofText
	GuiControl, Move, % IdSearchR1, % "x" v_xNext "y" v_yNext
	
	GuiControlGet, v_OutVarTemp, Pos, % IdSearchR1
	v_xNext += v_OutVarTempW + c_xmarg
	GuiControl, Move, % IdSearchR2, % "x" v_xNext "y" v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdSearchR2
	v_xNext += v_OutVarTempW + c_xmarg
	GuiControl, Move, % IdSearchR3, % "x" v_xNext "y" v_yNext
	
	HofRadio := v_OutVarTempH
	v_OutVarTemp := Max(HofRadio, HofEdit)
	v_xNext := c_xmarg
	v_yNext += v_OutVarTemp + c_ymarg
	v_wNext := HS3MinWidth
	v_hNext := HS3MinHeight - (c_ymarg + HofText + v_OutVarTemp + c_ymarg + HofText * 2)
	GuiControl, Move, % IdSearchLV1, % "x" v_xNext "y" v_yNext "w" v_wNext "h" v_hNext
	
	GuiControlGet, v_OutVarTemp, Pos, % IdSearchLV1
	LV_ModifyCol(1, Round(0.2 * v_OutVarTempW))
	LV_ModifyCol(2, Round(0.1 * v_OutVarTempW))
	LV_ModifyCol(3, Round(0.1 * v_OutVarTempW))	
	LV_ModifyCol(4, Round(0.1 * v_OutVarTempW))
	LV_ModifyCol(5, Round(0.1 * v_OutVarTempW))
	LV_ModifyCol(6, Round(0.27 * v_OutVarTempW))
	LV_ModifyCol(7, Round(0.1 * v_OutVarTempW) - 3)
	v_xNext := c_xmarg
	v_yNext := v_OutVarTempY + v_OutVarTempH + c_ymarg
	GuiControl, Move, % IdSearchT4, % "x" v_xNext "y" v_yNext ;information about shortcuts
	
	GuiControlGet, v_OutVarTemp, Pos, % IdSearchB1
	v_ButtonW := v_OutVarTempW + 2 * c_ymarg
	v_xNext := HS3MinWidth + c_xmarg - v_ButtonW
	v_yNext -= c_ymarg
	GuiControl, Move, % IdSearchB1, % "x" v_xNext "y" v_yNext "w" v_ButtonW
	
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
HS3SearchGuiSize()
{
	global	;assume-global mode
	local v_OutVarTemp1 := 0, v_OutVarTemp1X := 0, v_OutVarTemp1Y := 0, v_OutVarTemp1W := 0, v_OutVarTemp1H := 0
		,v_OutVarTemp2 := 0, v_OutVarTemp2X := 0, v_OutVarTemp2Y := 0, v_OutVarTemp2W := 0, v_OutVarTemp2H := 0
		,v_xNext := 0, 		v_yNext := 0, 			v_wNext := 0, 			v_hNext := 0
	
	if (A_EventInfo = 1) ;The window has been minimized.
		return
	if (A_EventInfo = 2) ;The window has been maximized.
		return
	
	GuiControlGet, v_OutVarTemp1, Pos, % IdSearchLV1 
	F_AutoXYWH("*wh", IdSearchLV1)
	GuiControlGet, v_OutVarTemp2, Pos, % IdSearchLV1 ;Check position of ListView1 again after resizing
	if (v_OutVarTemp2W != v_OutVarTemp1W)
	{
		LV_ModifyCol(1, Round(0.2 * v_OutVarTemp2W))
		LV_ModifyCol(2, Round(0.1 * v_OutVarTemp2W))
		LV_ModifyCol(3, Round(0.1 * v_OutVarTemp2W))	
		LV_ModifyCol(4, Round(0.1 * v_OutVarTemp2W))
		LV_ModifyCol(5, Round(0.1 * v_OutVarTemp2W))
		LV_ModifyCol(6, Round(0.27 * v_OutVarTemp2W))
		LV_ModifyCol(7, Round(0.1 * v_OutVarTemp2W) - 3)
	}
	v_xNext := c_xmarg
	v_yNext := v_OutVarTemp2Y + v_OutVarTemp2H + c_ymarg
	GuiControl, MoveDraw, % IdSearchT4, % "x" v_xNext "y" v_yNext ;information about shortcuts
	
	GuiControlGet, v_OutVarTemp1, Pos, % IdSearchB1
	v_xNext := HS3MinWidth + c_xmarg - v_OutVarTemp1W
	v_yNext -= c_ymarg
	GuiControl, MoveDraw, % IdSearchB1, % "x" v_xNext "y" v_yNext 
	
	return
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_RestoreDefaultConfig()
{
	global	;assume-global mode
	if (FileExist(HADConfig))
	{
		MsgBox, 308, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["warning"]
			, % TransA["In order to restore default configuration, the current Config.ini file will be deleted. This action cannot be undone. Next application will be reloaded and upon start the Config.ini with default settings will be created."] 
			. "`n`n" .  TransA["Are you sure?"]
		IfMsgBox, Yes
		{
			FileDelete, % HADConfig
			Reload
		}
		IfMsgBox, No
			return
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_Checkbox()	
{
global	;assume-global
	local v_OutputVar := 0
	GuiControlGet, v_OutputVar, % A_Gui . ":", % A_GuiControl
	
	if (v_OutputVar)
	{
		if (A_GuiControl = "v_OptionDisable")
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
	return
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
	;Gui, HSDel: Add, Text, HwndIdHD_T1 vDelayText, % TransA["Clipboard paste delay in [ms]:"] . A_Space . ini_CPDelay . "`n`n" . TransA["This option is valid"]
		Gui, HSDel: Add, Text, HwndIdHD_T1, % TransA["Clipboard paste delay in [ms]:"] . A_Space . ini_CPDelay . "`n`n" . TransA["This option is valid"]
		GuiControlGet, v_OutVarTemp, Pos, % IdHD_T1
		v_xNext := c_xmarg
		v_yNext := c_ymarg
		v_wNext := v_OutVarTempW
		GuiControl, Move, % IdHD_S1, % "x" v_xNext . A_Space . "y" v_yNext . A_Space "w" v_wNext
		GuiControl, Move, % IdHD_T1, % "x" v_xNext
		
		WinGetPos, Window1X, Window1Y, Window1W, Window1H, A
		Gui, HSDel: Show, Hide AutoSize 
		DetectHiddenWindows, On
		WinGetPos, Window2X, Window2Y, Window2W, Window2H, % "ahk_id" . HotstringDelay
		DetectHiddenWindows, Off
		
		NewWinPosX := Round(Window1X + (Window1W / 2) - (Window2W / 2))
		NewWinPosY := Round(Window1Y + (Window1H / 2) - (Window2H / 2))
		
		Gui, HSDel: Show, % "x" . NewWinPosX . A_Space . "y" . NewWinPosY . A_Space . "AutoSize"	
		return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_HSdelay()
{
	global	;assume-global mode
	GuiControl,, % IdHD_T1, % TransA["Clipboard paste delay in [ms]:"] . A_Space . ini_CPDelay . "`n`n" . TransA["This option is valid"]
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_WhichGui()
;This version is more robust: it doesn't take into account just "last active window" (A parameter), but just checks if there are active windows.
{
	global	;assume-global mode
	local	WinHWND := 0
	
	WinGet, WinHWND, ID, % "ahk_id" HS3GuiHwnd
	if (WinHWND)
	{
		Gui, HS3: Default
		return
	}
	WinGet, WinHWND, ID, % "ahk_id" HS4GuiHwnd
	if (WinHWND)
	{
		Gui, HS4: Default
		return
	}
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_GuiAddLibrary()
{
	global	;assume-global mode
	local v_OutVarTemp1 := 0, v_OutVarTemp1X := 0, v_OutVarTemp1Y := 0, v_OutVarTemp1W := 0, v_OutVarTemp1H := 0
		,v_OutVarTemp2 := 0, v_OutVarTemp2X := 0, v_OutVarTemp2Y := 0, v_OutVarTemp2W := 0, v_OutVarTemp2H := 0
		,IdText1 := 0, IdText2 := 0, IdEdit1 := 0, IdButt1 := 0, IdButt2 := 0
		,vTempWidth := 2 * c_xmarg, v_WidthButt1 := 0, v_WidthButt2 := 0, xButt2 := 0
		,Window1X := 0, Window1Y := 0, Window1W := 0, Window1H := 0
		,Window2X := 0, Window2Y := 0, Window2W := 0, Window2H := 0
		,NewWinPosX := 0, NewWinPosY := 0
	
	;+Owner to prevent display of a taskbar button
	Gui, ALib: New, -Caption +Border +Owner +HwndAddLibrary
	Gui, ALib: Margin,	% c_xmarg, % c_ymarg
	Gui,	ALib: Color,	% c_WindowColor, % c_ControlColor
	Gui,	ALib: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, % c_FontType
	
	Gui, ALib: Add, Text, HwndIdText1, % TransA["Enter a name for the new library"]
	Gui, ALib: Add, Edit, HwndIdEdit1 vv_NewLib
	
	GuiControlGet, v_OutVarTemp1, ALib: Pos, % IdText1
	GuiControl, ALib: Move, % IdEdit1, % "w" c_xmarg + v_OutVarTemp1W
	
	Gui, ALib: Add, Text, HwndIdText2, .csv
	GuiControlGet, v_OutVarTemp1, ALib: Pos, % IdEdit1
	vTempWidth += v_OutVarTemp1W
	GuiControl, ALib: Move, % IdText2, % "x" v_OutVarTemp1X + v_OutVarTemp1W . A_Space . "y" v_OutVarTemp1Y
	GuiControlGet, v_OutVarTemp1, ALib: Pos, % IdText2
	vTempWidth += v_OutVarTemp1W
	
	Gui, ALib: Add, Button, HwndIdButt1 Default gALibOK, 	% TransA["OK"]
	Gui, ALib: Add, Button, HwndIdButt2 gALibGuiClose, 	% TransA["Cancel"]
	GuiControlGet, v_OutVarTemp1, ALib: Pos, % IdButt1
	GuiControlGet, v_OutVarTemp2, ALib: Pos, % IdButt2
	
	v_WidthButt1 := v_OutVarTemp1W + 2 * c_xmarg
	v_WidthButt2 := v_OutVarTemp2W + 2 * c_xmarg
	xButt2	   := c_xmarg + v_WidthButt1 + vTempWidth - (2 * c_xmarg + v_WidthButt1 + v_WidthButt2)
	
	GuiControl, ALib: Move, % IdButt1, % "x" c_xmarg . A_Space . "w" v_WidthButt1
	GuiControl, ALib: Move, % IdButt2, % "x" xButt2  . A_Space . "y" v_OutVarTemp1Y . A_Space . "w" v_WidthButt2
	
	WinGetPos, Window1X, Window1Y, Window1W, Window1H, A
	Gui, ALib: Show, Hide AutoSize
	DetectHiddenWindows, On
	WinGetPos, Window2X, Window2Y, Window2W, Window2H, % "ahk_id" . AddLibrary
	DetectHiddenWindows, Off
	
	NewWinPosX := Round(Window1X + (Window1W / 2) - (Window2W / 2))
	NewWinPosY := Round(Window1Y + (Window1H / 2) - (Window2H / 2))
	
	Gui, ALib: Show, % "x" . NewWinPosX . A_Space . "y" . NewWinPosY . A_Space . "AutoSize"
	return
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_RefreshListOfLibraryTips()
{
	global	;assume-global
	local	key := 0, value := 0
	
	if (ini_ShowTipsLib.Count())
	{
		for key, value in ini_ShowTipsLib
		{
			Menu, ToggleLibTrigTipsSubmenu, Add, %key%, F_ToggleTipsLibrary
			if (value)
				Menu, ToggleLibTrigTipsSubmenu, Check, %key%
			else
				Menu, ToggleLibTrigTipsSubmenu, UnCheck, %key%
		}
		Menu, % TransA["No libraries have been found!"], UseErrorLevel, On ;check if this menu exists
		if (!ErrorLevel)
			Menu, ToggleLibTrigTipsSubmenu, Delete, % TransA["No libraries have been found!"] ;if exists, delete it
		Menu, % TransA["No libraries have been found!"], UseErrorLevel, Off
	}
	else
		Menu, ToggleLibTrigTipsSubmenu, Add, % TransA["No libraries have been found!"], F_ToggleTipsLibrary
	Menu, 	LibrariesSubmenu, 	Add, % TransA["Enable/disable triggerstring tips"], 	:ToggleLibTrigTipsSubmenu
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

F_RefreshListOfLibraries()
{
	global	;assume-global
	local key := 0, value := 0
	
	if (ini_LoadLib.Count())
	{
		for key, value in ini_LoadLib
		{
			Menu, EnDisLib, Add, %key%, F_EnDisLib
			if (value)
				Menu, EnDisLib, Check, %key%
			else
				Menu, EnDisLib, UnCheck, %key%	
		}
		Menu, % TransA["No libraries have been found!"], UseErrorLevel, On ;check if this menu exists
		if (!ErrorLevel)
			Menu, EnDisLib, Delete, % TransA["No libraries have been found!"] ;if exists, delete it
		Menu, % TransA["No libraries have been found!"], UseErrorLevel, Off
	}
	else
		Menu, EnDisLib, Add, % TransA["No libraries have been found!"], F_EnDisLib
	
	Menu,	LibrariesSubmenu,	Add, % TransA["Enable/disable libraries"],			:EnDisLib
	return
}
	
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	
F_DeleteHotstring()
{
	;1. Remove selected library file.
	;2. Create library file of the same name as selected. its content will contain List View but without selected row.
	;3. Remove selected row from List View.
	;4. Disable selected hotstring.
	;5. Remove trigger hint.
	;6. Decrement library counter.
	global ;assume-global mode
	local 	LibraryFullPathAndName := "" 
			,txt := "", txt1 := "", txt2 := "", txt3 := "", txt4 := "", txt5 := "", txt6 := ""
			,v_SelectedRow := 0, v_Pointer := 0
			,key := 0, val := ""
	
	Gui, HS3: +OwnDialogs
	
	v_SelectedRow := LV_GetNext()
	if (!v_SelectedRow) 
	{
		MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"],  % TransA["Select a row in the list-view, please!"]
		return
	}
	MsgBox, 324, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["Selected Hotstring will be deleted. Do you want to proceed?"]
	IfMsgBox, No
		return
	TrayTip, %A_ScriptName%, % TransA["Deleting hotstring..."], 1
	
	;1. Remove selected library file.
	LibraryFullPathAndName := HADL . "\" . v_SelectHotstringLibrary
	FileDelete, % LibraryFullPathAndName
	
	;4. Disable selected hotstring.
	LV_GetText(txt2, v_SelectedRow, 2)	;tu jestem
	Try
		Hotstring(":" . txt2 . ":" . v_TriggerString, , "Off") 
	Catch
		MsgBox, 16, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["Error"], % A_ThisFunc . A_Space . TransA["Something went wrong with hotstring deletion"] . ":" . "`n`n" . v_TriggerString 
		. A_Space . txt2 . "`n" . TransA["Library name:"] . A_Space . v_SelectHotstringLibrary 
	
	;3. Remove selected row from List View.
	LV_Delete(v_SelectedRow)
	
	;4. Save List View into the library file.
	Loop, % LV_GetCount()
	{
		LV_GetText(txt1, A_Index, 2)
		LV_GetText(txt2, A_Index, 1)
		LV_GetText(txt3, A_Index, 3)
		LV_GetText(txt4, A_Index, 4)
		LV_GetText(txt5, A_Index, 5)
		LV_GetText(txt6, A_Index, 6)
		txt .= txt1 . "‖" . txt2 . "‖" . txt3 . "‖" . txt4 . "‖" . txt5 . "‖" . txt6 . "`n"
	}
	FileAppend, % txt, % HADL . "\" . v_SelectHotstringLibrary, UTF-8
	
	;5. Remove trigger hint. Remark: All trigger hints are deleted, so if triggerstring was duplicated, then all trigger hints are deleted!
	Loop, % a_Triggers.MaxIndex()
	{
		if (InStr(a_Triggers[A_Index], v_TriggerString, true))	;case sensitive comparison on purpose
			a_Triggers.RemoveAt(A_Index)
	}
	TrayTip, % A_ScriptName, % TransA["Specified definition of hotstring has been deleted"], 1
	
	;6. Decrement library counter.
	--v_LibHotstringCnt
	--v_TotalHotstringCnt
	GuiControl, , % IdText13,  % v_LibHotstringCnt
	GuiControl, , % IdText13b, % v_LibHotstringCnt
	GuiControl, , % IdText12,  % v_TotalHotstringCnt
	GuiControl, , % IdText12b, % v_TotalHotstringCnt
	
	;Remove from "Search" tables. Unfortunately index (v_SelectedRow) is sufficient only for one table, and in Searching there is "super table" containing all definitions from all available tables.
	for key, val in a_Library
		if (val = SubStr(v_SelectHotstringLibrary, 1, -4))
		{
			v_Pointer := key
			Break
		}
	v_Pointer += v_SelectedRow - 1
	
	a_Library.RemoveAt(v_Pointer)
	a_Triggerstring.RemoveAt(v_Pointer)
	a_TriggerOptions.RemoveAt(v_Pointer)
	a_OutputFunction.RemoveAt(v_Pointer)
	a_EnableDisable.RemoveAt(v_Pointer)
	a_Hotstring.RemoveAt(v_Pointer)
	a_Comment.RemoveAt(v_Pointer)
	
	;7. Update table for searching
	F_Searching("Reload")
	return
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_ToggleRightColumn() ;Label of Button IdButton5, to toggle left part of gui 
{
	global ;assume-global mode
	local WinX := 0, WinY := 0
		,OutputvarTemp := 0, OutputvarTempW := 0
	
	Switch A_DefaultGui
	{
		Case "HS3":
		WinGetPos, WinX, WinY, , , % "ahk_id" . HS3GuiHwnd
		Gui, HS3: Submit, NoHide
		Gui, HS4: Default
		F_UpdateSelHotLibDDL()
		GuiControl,, % IdEdit1b, % v_TriggerString
		GuiControl,, % IdEdit2b, % v_EnterHotstring
		GuiControl, ChooseString, % IdDDL2b, % v_SelectHotstringLibrary
		Gui, HS3: Show, Hide
		Gui, HS4: Show, % "X" WinX . A_Space . "Y" WinY . A_Space . "AutoSize"
		Gui, HS4: Show, AutoSize ;don't know why it has to be doubled to properly display...
		ini_WhichGui := "HS4"
		Case "HS4":
		WinGetPos, WinX, WinY, , , % "ahk_id" . HS4GuiHwnd
		Gui, HS4: Submit, NoHide
		Gui, HS3: Default
		F_UpdateSelHotLibDDL()
		GuiControl,, % IdEdit1, % v_TriggerString
		GuiControl,, % IdEdit2, % v_EnterHotstring
		GuiControl, ChooseString, % IdDDL2, % v_SelectHotstringLibrary
		Gui, HS4: Show, Hide
		Gui, HS3: Show, % "X" WinX . A_Space . "Y" WinY . A_Space . "AutoSize"
		Gui, HS3: Show, AutoSize ;don't know why it has to be doubled to properly display...
		ini_WhichGui := "HS3"
	}
	if (ini_WhichGui = "HS3")
		Menu, ConfGUI, Check, 	% TransA["Show full GUI (F4)"]
	else
		Menu, ConfGUI, UnCheck, % TransA["Show full GUI (F4)"]
	
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
HS4GuiSize() ;Gui event
{
	global ;assume-global mode
	
	if (A_EventInfo = 1) ; The window has been minimized.
	{
		;v_WhichGUIisMinimzed := "HS4"
		ini_WhichGui := "HS4"
		return
	}
	
	HS4_GuiWidth  := A_GuiWidth
	HS4_GuiHeight := A_GuiHeight
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_GuiMain_LVcolumnScale()
{
	global ;assume-global mode
	local v_OutVarTemp2 := 0, v_OutVarTemp2X := 0, v_OutVarTemp2Y := 0, v_OutVarTemp2W := 0, v_OutVarTemp2H := 0 ;Within a function, to create a set of variables that is local instead of global, declare OutputVar as a local variable prior to using command GuiControlGet, Pos. However, it is often also necessary to declare each variable in the set, due to a common source of confusion.		

	GuiControlGet, v_OutVarTemp2, Pos, % IdListView1 ;This line will be used for "if" and "else" statement.	
	ListViewWidth := v_OutVarTemp2W
	LV_ModifyCol(1, Round(0.1 * ListViewWidth))
	LV_ModifyCol(2, Round(0.1 * ListViewWidth))
	LV_ModifyCol(3, Round(0.1 * ListViewWidth))	
	LV_ModifyCol(4, Round(0.1 * ListViewWidth))
	LV_ModifyCol(5, Round(0.4 * ListViewWidth))
	LV_ModifyCol(6, Round(0.2 * (ListViewWidth - 6)))
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_GuiMain_Resize2()
{
	global ;assume-global mode
	local v_OutVarTemp1 := 0, v_OutVarTemp1X := 0, v_OutVarTemp1Y := 0, v_OutVarTemp1W := 0, v_OutVarTemp1H := 0 ;Within a function, to create a set of variables that is local instead of global, declare OutputVar as a local variable prior to using command GuiControlGet, Pos. However, it is often also necessary to declare each variable in the set, due to a common source of confusion.	
		,v_xNext := 0, v_yNext := 0, v_wNext := 0, v_hNext := 0

	v_wNext := A_GuiWidth - (2 * c_xmarg + LeftColumnW + c_WofMiddleButton)
	v_hNext := A_GuiHeight - (c_ymarg + HofText + c_ymarg + HofText + c_HofSandbox + c_ymarg)
	GuiControl, MoveDraw, % IdListView1, % "w" . v_wNext . "h" . v_hNext
	v_xNext := LeftColumnW + c_xmarg + c_WofMiddleButton
	v_yNext := A_GuiHeight - (c_ymarg + HofText + c_HofSandbox)
	GuiControl, MoveDraw, % IdText10, % "x" . v_xNext . "y" . v_yNext
	GuiControlGet, v_OutVarTemp1, Pos, % IdText10
	v_xNext := v_OutVarTemp1X + v_OutVarTemp1W + c_xmarg
	GuiControl, MoveDraw, % IdTextInfo17, % "x" . v_xNext . "y" . v_yNext
	v_xNext := LeftColumnW + c_WofMiddleButton + c_xmarg
	v_yNext += HofText
	v_wNext := A_GuiWidth - (2 * c_xmarg + LeftColumnW + c_WofMiddleButton)
	GuiControl, MoveDraw, % IdEdit10, % "x" . v_xNext . "y" . v_yNext . "w" . v_wNext
	v_hNext := A_GuiHeight - 2 * c_ymarg 
	GuiControl, MoveDraw, % IdButton5, % "h" . v_hNext 
	F_GuiMain_LVcolumnScale()
	OutputDebug, % "Two:" 
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_GuiMain_Resize4()
{
	global ;assume-global mode
	local v_xNext := 0
	
	v_hNext := A_GuiHeight - (2 * c_ymarg)
	GuiControl, MoveDraw, % IdButton5, % "h" . v_hNext 
	v_wNext := A_GuiWidth - (2 * c_xmarg + LeftColumnW + c_WofMiddleButton)
	GuiControl, MoveDraw, % IdListView1, % "w" . v_wNext
	v_hNext := A_GuiHeight - (2 * c_ymarg + HofText)
	GuiControl, MoveDraw, % IdListView1, % "h" . v_hNext  ;increase
	F_GuiMain_LVcolumnScale()
	OutputDebug, % "Four:" 
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_GuiMain_Resize1()
{
	global ;assume-global mode
	local	v_OutVarTemp1 := 0, v_OutVarTemp1X := 0, v_OutVarTemp1Y := 0, v_OutVarTemp1W := 0, v_OutVarTemp1H := 0 ;Within a function, to create a set of variables that is local instead of global, declare OutputVar as a local variable prior to using command GuiControlGet, Pos. However, it is often also necessary to declare each variable in the set, due to a common source of confusion.	
			,v_xNext := 0, v_yNext := 0, v_wNext := 0, v_hNext := 0
	
	v_wNext := A_GuiWidth - (2 * c_xmarg + LeftColumnW + c_WofMiddleButton)
	v_hNext := A_GuiHeight - (2 * c_ymarg + HofText)
	GuiControl, MoveDraw, % IdListView1, % "w" . v_wNext . "h" . v_hNext  ;increase
	v_xNext := c_xmarg
	v_yNext := LeftColumnH + c_ymarg
	GuiControl, MoveDraw, % IdText10, % "x" . v_xNext . "y" . v_yNext
	GuiControlGet, v_OutVarTemp1, Pos, % IdText10
	v_xNext := v_OutVarTemp1X + v_OutVarTemp1W + c_xmarg
	v_yNext := LeftColumnH + c_ymarg
	GuiControl, MoveDraw, % IdTextInfo17, % "x" . v_xNext . "y" . v_yNext
	v_xNext := c_xmarg
	v_yNext := LeftColumnH + c_ymarg + HofText 
	v_wNext := LeftColumnW - 2 * c_xmarg
	GuiControl, MoveDraw, % IdEdit10, % "x" . v_xNext . "y" . v_yNext . "w" . v_wNext
	v_hNext := A_GuiHeight - (2 * c_ymarg)
	GuiControl, MoveDraw, % IdButton5, % "h" . v_hNext 
	F_GuiMain_LVcolumnScale()
	OutputDebug, % "One:" . A_Tab . "ini_IsSandboxMoved" . A_Space . ini_IsSandboxMoved 
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_GuiMain_Resize3()
{
	global ;assume-global mode
	local	v_OutVarTemp1 := 0, v_OutVarTemp1X := 0, v_OutVarTemp1Y := 0, v_OutVarTemp1W := 0, v_OutVarTemp1H := 0 ;Within a function, to create a set of variables that is local instead of global, declare OutputVar as a local variable prior to using command GuiControlGet, Pos. However, it is often also necessary to declare each variable in the set, due to a common source of confusion.	
			,v_xNext := 0, v_yNext := 0, v_wNext := 0, v_hNext := 0
	
	v_hNext := A_GuiHeight - (c_ymarg + HofText + c_ymarg + HofText + c_HofSandbox + c_ymarg)
	GuiControl, MoveDraw, % IdListView1, % "h" . v_hNext ;decrease
	v_xNext := LeftColumnW + c_xmarg + c_WofMiddleButton
	v_yNext := A_GuiHeight - (c_ymarg + HofText + c_HofSandbox)
	GuiControl, MoveDraw, % IdText10, % "x" . v_xNext . "y" . v_yNext
	GuiControlGet, v_OutVarTemp1, Pos, % IdText10
	v_xNext := v_OutVarTemp1X + v_OutVarTemp1W + c_xmarg
	GuiControl, MoveDraw, % IdTextInfo17, % "x" . v_xNext . "y" . v_yNext
	v_xNext := LeftColumnW + c_WofMiddleButton + c_xmarg
	v_yNext += HofText
	v_wNext := A_GuiWidth - (2 * c_xmarg + LeftColumnW + c_WofMiddleButton)
	GuiControl, MoveDraw, % IdEdit10, % "x" . v_xNext . "y" . v_yNext . "w" . v_wNext
	v_hNext := A_GuiHeight - 2 * c_ymarg 
	GuiControl, MoveDraw, % IdButton5, % "h" . v_hNext 
	F_GuiMain_LVcolumnScale()
	OutputDebug, % "Three:" . A_Tab . "ini_IsSandboxMoved" . A_Space . ini_IsSandboxMoved 
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_GuiMain_Resize5()
{
	global ;assume-global mode
	local	v_xNext := 0, v_yNext := 0, v_wNext := 0, v_hNext := 0
	
	v_hNext := A_GuiHeight - (HofText + 2 * c_ymarg)
	v_wNext := A_GuiWidth - (2 * c_xmarg + LeftColumnW + c_WofMiddleButton)
	GuiControl, MoveDraw, % IdListView1, % "w" . v_wNext . "h" . v_hNext
	v_hNext := A_GuiHeight - (2 * c_ymarg)
	GuiControl, MoveDraw, % IdButton5, % "h" . v_hNext
	F_GuiMain_LVcolumnScale()
	OutputDebug, % "Five"
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
HS3GuiSize(GuiHwnd, EventInfo, Width, Height) ;Gui event
{	;This function toggles flag ini_IsSandboxMoved
	global ;assume-global mode
	local v_OutVarTemp2 := 0, v_OutVarTemp2X := 0, v_OutVarTemp2Y := 0, v_OutVarTemp2W := 0, v_OutVarTemp2H := 0 ;Within a function, to create a set of variables that is local instead of global, declare OutputVar as a local variable prior to using command GuiControlGet, Pos. However, it is often also necessary to declare each variable in the set, due to a common source of confusion.	
		,ListViewWidth := 0
		,v_xNext := 0, v_yNext := 0, v_wNext := 0, v_hNext := 0
	
	HS3_GuiWidth  := A_GuiWidth	;used by F_SaveGUIPos()
	HS3_GuiHeight := A_GuiHeight	;used by F_SaveGUIPos()
	if (v_ResizingFlag)
		return
	if (A_EventInfo = 1) ; The window has been minimized.
	{
		ini_WhichGui := "HS3"
		return
	}
	if (A_EventInfo = 2)	;The window has been maximized
	{
		ini_HS3GuiMaximized := true
		if (ini_Sandbox)
		{
			F_GuiMain_Resize1()
			ini_IsSandboxMoved := true
		}
		else
			F_GuiMain_Resize5()
		return
	}
	if (!A_EventInfo) and (ini_HS3GuiMaximized)	;Window is restored after maximizing
	{
		ini_HS3GuiMaximized := false
		if (ini_Sandbox) and (!ini_IsSandboxMoved)
			F_GuiMain_Resize2()
		if (ini_Sandbox) and (ini_IsSandboxMoved)
			F_GuiMain_Resize4()
		if (!ini_Sandbox)
			F_GuiMain_Resize5()
		return
	}
	
	if (!ini_Sandbox)
	{
		F_GuiMain_Resize5()		
		return
	}
	
	GuiControlGet, v_OutVarTemp2, Pos, % IdListView1 ;Check position of ListView1 again after resizing
	if (ini_Sandbox) and (!ini_IsSandboxMoved) 
	{
		if (v_OutVarTemp2H + HofText + c_ymarg >  LeftColumnH)
		{
			ini_IsSandboxMoved := true
			F_GuiMain_Resize1()
			return
		}
		else
			F_GuiMain_Resize2()
		return
	}
	if (ini_Sandbox) and (ini_IsSandboxMoved)
	{
		if (v_OutVarTemp2H <= LeftColumnH + HofEdit + 3 * c_ymarg)
		{
			ini_IsSandboxMoved := false
			F_GuiMain_Resize3()			
			return
		}
		else
			F_GuiMain_Resize4()
		return
	}
	;*[One]
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_SelectLibrary()
{ 
	global ;assume-global mode
	local v_TheWholeFile := "", str1 := [], v_TotalLines := 0
		,v_OutVarTemp := 0, v_OutVarTempX := 0, v_OutVarTempY := 0, v_OutVarTempW := 0, v_OutVarTempH := 0
		,key := 0, value := "", name := ""
	
	if (A_DefaultGui = "HS3")
		Gui, HS3: Submit, NoHide
	if (A_DefaultGui = "HS4")
		Gui, HS4: Submit, NoHide
	
	GuiControl, Enable, % IdButton4 ; button Delete hotstring (F8)
	
	Gui, HS3: Default			;All of the ListView function operate upon the current default GUI window.
	GuiControl, -Redraw, % IdListView1 ;The Redraw option serves as a hint to the control that allows it to allocate memory only once rather than each time a row is added, which greatly improves row-adding performance (it may also improve sorting performance). 
	LV_Delete()
	v_LibHotstringCnt := 0
	GuiControl, , % IdText13,  % v_LibHotstringCnt
	GuiControl, , % IdText13b, % v_LibHotstringCnt
	name := SubStr(v_SelectHotstringLibrary, 1, -4)
	for key, value in a_Library
	{
		if (value = name)
		{
			str1[1] := a_Triggerstring[key]
			str1[2] := a_TriggerOptions[key]
			str1[3] := a_OutputFunction[key]
			str1[4] := a_EnableDisable[key]
			str1[5] := a_Hotstring[key]
			str1[6] := a_Comment[key]
			LV_Add("", str1[1], str1[2], str1[3], str1[4], str1[5], str1[6])	
			v_LibHotstringCnt++
		}
	}
	GuiControl, , % IdText13,  % v_LibHotstringCnt
	GuiControl, , % IdText13b, % v_LibHotstringCnt
	LV_ModifyCol(1, "Sort")	;without this line content of library is loaded in the same order as it was saved last time; keep in mind that after any change (e.g. change of exiting definition) the whole file is sorted and saved again
	GuiControlGet, v_OutVarTemp, Pos, % IdListView1 ;Check position of ListView1 again after resizing
	LV_ModifyCol(1, Round(0.1 * v_OutVarTempW))
	LV_ModifyCol(2, Round(0.1 * v_OutVarTempW))
	LV_ModifyCol(3, Round(0.1 * v_OutVarTempW))	
	LV_ModifyCol(4, Round(0.1 * v_OutVarTempW))
	LV_ModifyCol(5, Round(0.4 * v_OutVarTempW))
	LV_ModifyCol(6, Round(0.2 * v_OutVarTempW) - 3)
	GuiControl, +Redraw, % IdListView1 ;Afterward, use GuiControl, +Redraw to re-enable redrawing (which also repaints the control).
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_HSLV() ; copy content of List View 1 to editable fields of HS3 Gui
{
	global ;assume-global mode
	local Options := "", Fun := "", EnDis := "", TextInsert := "", OTextMenu := "", Comment := ""
		,v_SelectedRow := 0
	
	if !(v_SelectedRow := LV_GetNext())
		return
	
	LV_GetText(v_TriggerString, 	v_SelectedRow, 1)
	GuiControl, HS3:, % IdEdit1, % v_TriggerString
	GuiControl, HS4:, % IdEdit1, % v_TriggerString
	LV_GetText(Options, 		v_SelectedRow, 2)
	if (InStr(Options, "*"))
	{
		Gui, HS3: Font, % "s" . c_FontSize . A_Space . "cGreen Norm", % c_FontType
		Gui, HS4: Font, % "s" . c_FontSize . A_Space . "cGreen Norm", % c_FontType
		GuiControl, HS3: Font, % IdCheckBox1
		GuiControl, HS4: Font, % IdCheckBox1b
		GuiControl, HS3:, % IdCheckBox1, 	1
		GuiControl, HS4:, % IdCheckBox1b, 	1
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
	}
	if (InStr(Options, "C1"))
	{
		Gui, HS3: Font, % "s" . c_FontSize . A_Space . "cGreen Norm", % c_FontType
		Gui, HS4: Font, % "s" . c_FontSize . A_Space . "cGreen Norm", % c_FontType
		GuiControl, HS3: Font, % TransA["Not Case-Conforming (C1)"]
		GuiControl, HS4: Font, % TransA["Not Case-Conforming (C1)"]
		GuiControl, HS3:, % TransA["Not Case-Conforming (C1)"], 1
		GuiControl, HS4:, % TransA["Not Case-Conforming (C1)"], 1
	}
	if (!InStr(Options, "C1")) and (!InStr(Options, "C"))
	{
		Gui, HS3: Font, % "s" . c_FontSize . A_Space . "c" . c_FontColor . A_Space . "Norm", % c_FontType
		Gui, HS4: Font, % "s" . c_FontSize . A_Space . "c" . c_FontColor . A_Space . "Norm", % c_FontType
		GuiControl, HS3: Font, % TransA["Case Sensitive (C)"]
		GuiControl, HS4: Font, % TransA["Case Sensitive (C)"]
		GuiControl, HS3: Font, % TransA["Case-Conforming"]
		GuiControl, HS4: Font, % TransA["Case-Conforming"]
		GuiControl, HS3: Font, % TransA["Not Case-Conforming (C1)"]
		GuiControl, HS4: Font, % TransA["Not Case-Conforming (C1)"]
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
	
	LV_GetText(Fun, 			v_SelectedRow, 3)
	Switch Fun
	{
		Case "SI":	;SendFun := "F_HOF_SI"
			GuiControl, HS3: Choose, v_SelectFunction, SendInput (SI)
			GuiControl, HS4: Choose, v_SelectFunction, SendInput (SI)
		Case "CL":	;SendFun := "F_HOF_CLI"
			GuiControl, HS3: Choose, v_SelectFunction, Clipboard (CL)
			GuiControl, HS4: Choose, v_SelectFunction, Clipboard (CL)
		Case "MCL":	;SendFun := "F_HOF_MCLI"
			GuiControl, HS3: Choose, v_SelectFunction, Menu & Clipboard (MCL)
			GuiControl, HS4: Choose, v_SelectFunction, Menu & Clipboard (MCL)
		Case "MSI":	;SendFun := "F_HOF_MSI"
			GuiControl, HS3: Choose, v_SelectFunction, Menu & SendInput (MSI)
			GuiControl, HS4: Choose, v_SelectFunction, Menu & SendInput (MSI)
		Case "SR":	
			GuiControl, HS3: Choose, v_SelectFunction, SendRaw (SR)
			GuiControl, HS4: Choose, v_SelectFunction, SendRaw (SR)
		Case "SP":
			GuiControl, HS3: Choose, v_SelectFunction, SendPlay (SP)
			GuiControl, HS4: Choose, v_SelectFunction, SendPlay (SP)
		Case "SE":
			GuiControl, HS3: Choose, v_SelectFunction, SendPlay (SE)
			GuiControl, HS4: Choose, v_SelectFunction, SendPlay (SE)
	}
	
	LV_GetText(EnDis, 		v_SelectedRow, 4)
	if (InStr(EnDis, "En"))
	{
		Gui, HS3: Font, % "s" . c_FontSize . A_Space . "c" . c_FontColor . A_Space . "Norm", % c_FontType
		Gui, HS4: Font, % "s" . c_FontSize . A_Space . "c" . c_FontColor . A_Space . "Norm", % c_FontType
		GuiControl, HS3: Font, % IdCheckBox6
		GuiControl, HS4: Font, % IdCheckBox6b
		GuiControl, HS3:, % IdCheckBox6,  0
		GuiControl, HS4:, % IdCheckBox6b, 0
	}
	else
	{
		Gui, HS3: Font, % "s" . c_FontSize . A_Space . "cRed Norm", % c_FontType
		Gui, HS4: Font, % "s" . c_FontSize . A_Space . "cRed Norm", % c_FontType
		GuiControl, HS3: Font, % IdCheckBox6
		GuiControl, HS4: Font, % IdCheckBox6b
		GuiControl, HS3:, % IdCheckBox6,  1
		GuiControl, HS4:, % IdCheckBox6b, 1
	}
	
	LV_GetText(TextInsert, 	v_SelectedRow, 5)
	if ((Fun = "MCL") or (Fun = "MSI"))
	{
		OTextMenu := StrSplit(TextInsert, "¦")
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
		GuiControl, HS3:, v_EnterHotstring, % TextInsert
		GuiControl, HS4:, v_EnterHotstring, % TextInsert
	}
	
	LV_GetText(Comment, 	v_SelectedRow, 6)
	GuiControl, HS3:, v_Comment, %Comment%
	GuiControl, HS4:, v_Comment, %Comment%
	
	F_SelectFunction()
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	F_SelectFunction()
	{
		global ;assume-global mode
		
		if (A_DefaultGui = "HS3")
		{
			GuiControlGet, v_SelectFunction, HS3: ;Retrieves the contents of the control. 
		}
		if (A_DefaultGui = "HS4")
		{
			GuiControlGet, v_SelectFunction, HS4: ;Retrieves the contents of the control. 
		}
		
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
		return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
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
		IniWrite, % ini_GuiReload,		% HADConfig, GraphicalUserInterface, GuiReload
		Reload
	}
	IfMsgBox, No
		return	
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_LoadFontType()
{
	global	;assume-global mode
	c_FontType := ""
	
	IniRead, c_FontType, 			% HADConfig, GraphicalUserInterface, GuiFontType, Calibri
	if (!c_FontType)
		c_FontType := "Calibri"
	
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_SaveFontType()
{
	global	;assume-global mode
	IniWrite, % c_FontType,			% HADConfig, GraphicalUserInterface, GuiFontType
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
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
		IniWrite, % ini_GuiReload,		% HADConfig, GraphicalUserInterface, GuiReload
		Reload
	}
	IfMsgBox, No
		return	
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

F_SaveSizeOfMargin()
{
	global	;assume-global mode
	IniWrite, % c_xmarg,				% HADConfig, GraphicalUserInterface, GuiSizeOfMarginX
	IniWrite, % c_ymarg,				% HADConfig, GraphicalUserInterface, GuiSizeOfMarginY
	return
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

F_LoadSizeOfMargin()
{
		global	;assume-global mode
		SizeOfMargin				:= {1: 0, 2: 5, 3: 10, 4: 15, 5: 20} ;pixels
		c_xmarg := 10	;pixels
		c_ymarg := 10	;pixels
		
		IniRead, c_xmarg, 			% HADConfig, GraphicalUserInterface, GuiSizeOfMarginX, 10
		IniRead, c_ymarg,			% HADConfig, GraphicalUserInterface, GuiSizeOfMarginY, 10
		return
	}
	
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	
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
		IniWrite, % ini_GuiReload,		% HADConfig, GraphicalUserInterface, GuiReload
		Reload
	}
	IfMsgBox, No
		return	
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_SaveFontSize()
{
	global ;assume-global mode
	IniWrite, % c_FontSize,				% HADConfig, GraphicalUserInterface, GuiFontSize
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_LoadFontSize()
{
	global ;assume-global mode
	c_FontSize 				:= 0 ;points
	
	IniRead, c_FontSize, 			% HADConfig, GraphicalUserInterface, GuiFontSize, 10
	if (!c_FontSize)
		c_FontSize := 10
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
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
		IniWrite, % ini_GuiReload,		% HADConfig, GraphicalUserInterface, GuiReload
		Reload
	}
	IfMsgBox, No
		return	
	}
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_SaveGUIstyle()
{
	global ;assume-global mode
	
	IniWrite, % c_FontColor,				% HADConfig, GraphicalUserInterface, GuiFontColor
	IniWrite, % c_FontColorHighlighted,	% HADConfig, GraphicalUserInterface, GuiFontColorHighlighted
	IniWrite, % c_WindowColor, 	  		% HADConfig, GraphicalUserInterface, GuiWindowColor
	Iniwrite, % c_ControlColor,			% HADConfig, GraphicalUserInterface, GuiControlColor	
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_LoadGUIstyle()
{
	global ;assume-global mode
	c_FontColor				:= ""
	c_FontColorHighlighted		:= ""
	c_WindowColor				:= ""
	c_ControlColor 			:= ""
	
	IniRead, c_FontColor, 			% HADConfig, GraphicalUserInterface, GuiFontColor, 		 Black
	IniRead, c_FontColorHighlighted, 	% HADConfig, GraphicalUserInterface, GuiFontColorHighlighted, Blue
	IniRead, c_WindowColor, 			% HADConfig, GraphicalUserInterface, GuiWindowColor, 		 Default
	IniRead, c_ControlColor, 		% HADConfig, GraphicalUserInterface, GuiControlColor, 		 Default
	
	if (!c_FontColor)
		c_FontColor := "Black"
	if (!c_FontColorHighlighted)
		c_FontColorHighlighted := "Blue"
	if (!c_WindowColor)
		c_WindowColor := "Default"
	if (!c_ControlColor)
		c_ControlColor := "Default"
	
	return
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

F_CompileSubmenu()
{
	local v_TempOutStr := ""
	Loop, Parse, %  A_AhkPath, "\"
	{
		if (Instr(A_LoopField, ".exe"))
			break
		v_TempOutStr .= A_LoopField . "\"
	}
	v_TempOutStr .= "Compiler" . "\" 
	
	if (FileExist(v_TempOutStr . "Ahk2Exe.exe"))
	{
		Menu, AhkBitSubmenu,	Add, 64-bit,									F_Compile
		Menu, AhkBitSubmenu,	Add,	32-bit,									F_Compile
		Menu, CompileSubmenu, 	Add, % TransA["Standard executable (Ahk2Exe.exe)"], 	:AhkBitSubmenu
		Menu,	AppSubmenu,	Add,	% TransA["Compile"],						:CompileSubmenu
	}
	if (FileExist(v_TempOutStr . "upx.exe"))
	{
		Menu, UpxBitSubmenu,	Add, 64-bit,									F_Compile
		Menu, UpxBitSubmenu,	Add, 32-bit,									F_Compile
		Menu, CompileSubmenu, 	Add, % TransA["Compressed executable (upx.exe)"], 	:UpxBitSubmenu
	}
	if (FileExist(v_TempOutStr . "mpress.exe"))
	{
		Menu, MpressBitSubmenu,	Add, 64-bit,									F_Compile
		Menu, MpressBitSubmenu,	Add, 32-bit,									F_Compile
		Menu, CompileSubmenu, 	Add, % TransA["Compressed executable (mpress.exe)"], 	:MpressBitSubmenu
	}
	if (!FileExist(A_AhkPath)) ;if AutoHotkey isn't installed
	{
		Menu, AppSubmenu,		Add,	% TransA["Compile"],						L_Compile
		Menu, AppSubmenu, 		Disable,										% TransA["Compile"]
	}
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_Compile()
{	;https://www.autohotkey.com/boards/viewtopic.php?f=86&t=90196&p=398198#p398198
	local v_TempOutStr := "" ;, v_TempOutStr2 := "", v_TempOutStr3 := ""
	
	SplitPath, A_AhkPath, ,v_TempOutStr
	v_TempOutStr .= "\" . "Compiler" . "\" 
	Switch A_ThisMenu
	{
		;Case TransA["Standard executable (Ahk2Exe.exe)"]:
		Case "AhkBitSubmenu":
		if (A_ThisMenuItem = "64-bit")
		{
			RunWait, % v_TempOutStr . "Ahk2Exe.exe" 
				. A_Space . "/in"       . A_Space . A_ScriptDir . "\" . A_ScriptName 
				. A_Space . "/out"      . A_Space . A_ScriptDir . "\" . SubStr(A_ScriptName, 1, -4) . "." . "exe"
				. A_Space . "/icon"     . A_Space . A_ScriptDir . "\" . AppIcon
				. A_Space . "/bin"      . A_Space . """" . v_TempOutStr . "Unicode 64-bit.bin" . """"
				. A_Space . "/cp"       . A_Space . "65001"	;Unicode (UTF-8)
				;. A_Space . "/ahk"      . A_Space . """" . v_TempOutStr . "\" . "AutoHotkey.exe" . """" ;not clear yet when this option should be applied
				. A_Space . "/compress" . A_Space . "0"
			if (!ErrorLevel)		
				MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["The executable file is prepared by Ahk2Exe, but not compressed:"]
					. "`n`n" . A_ScriptDir . "\" . SubStr(A_ScriptName, 1, -4) . ".exe" . "`n`n" . "/bin" . ":" . A_Space . "Unicode 64-bit.bin" . A_Space . "cp:" . A_Space . "65001" . A_Space . "(Unicode (UTF-8))"
					. "`n" . TransA["Built with Autohotkey.exe version"] . ":" . A_Space . A_AhkVersion
		}
		if (A_ThisMenuItem = "32-bit")
		{
			RunWait, % v_TempOutStr . "Ahk2Exe.exe" 
				. A_Space . "/in"       . A_Space . A_ScriptDir . "\" . A_ScriptName 
				. A_Space . "/out"      . A_Space . A_ScriptDir . "\" . SubStr(A_ScriptName, 1, -4) . "." . "exe"
				. A_Space . "/icon"     . A_Space . A_ScriptDir . "\" . AppIcon
				. A_Space . "/bin"      . A_Space . """" . v_TempOutStr . "Unicode 32-bit.bin" . """"
				. A_Space . "/cp"       . A_Space . "65001"	;Unicode (UTF-8)
				;. A_Space . "/ahk"      . A_Space . """" . v_TempOutStr . "\" . "AutoHotkey.exe" . """" ;not clear yet when this option should be applied
				. A_Space . "/compress" . A_Space . "0"
			if (!ErrorLevel)		
				MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["The executable file is prepared by Ahk2Exe, but not compressed:"]
					. "`n`n" . A_ScriptDir . "\" . SubStr(A_ScriptName, 1, -4) . ".exe" . "`n`n" . "/bin" . ":" . A_Space . "Unicode 32-bit.bin" . A_Space . "cp:" . A_Space . "65001" . A_Space . "(Unicode (UTF-8))"
					. "`n" . TransA["Built with Autohotkey.exe version"] . ":" . A_Space . A_AhkVersion
		}
		Case "UpxBitSubmenu":
		if (A_ThisMenuItem = "64-bit")
		{
			RunWait, % v_TempOutStr . "Ahk2Exe.exe" 
				. A_Space . "/in"   	. A_Space . A_ScriptDir . "\" . A_ScriptName 
				. A_Space . "/out"  	. A_Space . A_ScriptDir . "\" . SubStr(A_ScriptName, 1, -4) . "." . "exe"
				. A_Space . "/icon" 	. A_Space . A_ScriptDir . "\" . AppIcon 
				. A_Space . "/bin"      . A_Space . """" . v_TempOutStr . "Unicode 64-bit.bin" . """"
				. A_Space . "/cp"   	. A_Space . "65001"	;Unicode (UTF-8)
				;. A_Space . "/ahk"      . A_Space . """" . v_TempOutStr . "\" . "AutoHotkey.exe" . """" ;not clear yet when this option should be applied
				. A_Space . "/compress" 	. A_Space . "2" 
			if (!ErrorLevel)		
				MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"],  % TransA["The executable file is prepared by Ahk2Exe and compressed by upx.exe:"]
					. "`n`n" . A_ScriptDir . "\" . SubStr(A_ScriptName, 1, -4) . ".exe" . "`n`n" . "/bin" . ":" . A_Space . "Unicode 64-bit.bin" . A_Space . "cp:" . A_Space . "65001" . A_Space . "(Unicode (UTF-8))"
					. "`n" . TransA["Built with Autohotkey.exe version"] . ":" . A_Space . A_AhkVersion
		}
		if (A_ThisMenuItem = "32-bit")
		{
			RunWait, % v_TempOutStr . "Ahk2Exe.exe" 
				. A_Space . "/in"   	. A_Space . A_ScriptDir . "\" . A_ScriptName 
				. A_Space . "/out"  	. A_Space . A_ScriptDir . "\" . SubStr(A_ScriptName, 1, -4) . "." . "exe"
				. A_Space . "/icon" 	. A_Space . A_ScriptDir . "\" . AppIcon 
				. A_Space . "/bin"      . A_Space . """" . v_TempOutStr . "Unicode 32-bit.bin" . """"
				. A_Space . "/cp"   	. A_Space . "65001"	;Unicode (UTF-8)
				;. A_Space . "/ahk"      . A_Space . """" . v_TempOutStr . "\" . "AutoHotkey.exe" . """" ;not clear yet when this option should be applied
				. A_Space . "/compress" 	. A_Space . "2" 
			if (!ErrorLevel)		
				MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"],  % TransA["The executable file is prepared by Ahk2Exe and compressed by upx.exe:"]
					. "`n`n" . A_ScriptDir . "\" . SubStr(A_ScriptName, 1, -4) . ".exe" . "`n`n" . "/bin" . ":" . A_Space . "Unicode 32-bit.bin" . A_Space . "cp:" . A_Space . "65001" . A_Space . "(Unicode (UTF-8))"
					. "`n" . TransA["Built with Autohotkey.exe version"] . ":" . A_Space . A_AhkVersion
		}
		Case "MpressBitSubmenu":
		if (A_ThisMenuItem = "64-bit")
		{
			RunWait, % v_TempOutStr . "Ahk2Exe.exe" 
				. A_Space . "/in" . A_Space . A_ScriptDir . "\" . A_ScriptName 
				. A_Space . "/out" . A_Space . A_ScriptDir . "\" . SubStr(A_ScriptName, 1, -4) . "." . "exe"
				. A_Space . "/icon" . A_Space . A_ScriptDir . "\" . AppIcon 
				. A_Space . "/bin"      . A_Space . """" . v_TempOutStr . "Unicode 64-bit.bin" . """"
				. A_Space . "/cp"   	. A_Space . "65001"	;Unicode (UTF-8)
				;. A_Space . "/ahk"      . A_Space . """" . v_TempOutStr . "\" . "AutoHotkey.exe" . """" ;not clear yet when this option should be applied
				. A_Space . "/compress" . A_Space . "1"
			if (!ErrorLevel)
				MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["The executable file is prepared by Ahk2Exe and compressed by mpress.exe:"]
					. "`n`n" . A_ScriptDir . "\" . SubStr(A_ScriptName, 1, -4) . ".exe" . "`n`n" . "/bin" . ":" . A_Space . "Unicode 64-bit.bin" . A_Space . "cp:" . A_Space . "65001" . A_Space . "(Unicode (UTF-8))"
					. "`n" . TransA["Built with Autohotkey.exe version"] . ":" . A_Space . A_AhkVersion
		}
		if (A_ThisMenuItem = "32-bit")
		{
			RunWait, % v_TempOutStr . "Ahk2Exe.exe" 
				. A_Space . "/in" . A_Space . A_ScriptDir . "\" . A_ScriptName 
				. A_Space . "/out" . A_Space . A_ScriptDir . "\" . SubStr(A_ScriptName, 1, -4) . "." . "exe"
				. A_Space . "/icon" . A_Space . A_ScriptDir . "\" . AppIcon 
				. A_Space . "/bin"      . A_Space . """" . v_TempOutStr . "Unicode 32-bit.bin" . """"
				. A_Space . "/cp"   	. A_Space . "65001"	;Unicode (UTF-8)
				;. A_Space . "/ahk"      . A_Space . """" . v_TempOutStr . "\" . "AutoHotkey.exe" . """" ;not clear yet when this option should be applied
				. A_Space . "/compress" . A_Space . "1"
			if (!ErrorLevel)
				MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["The executable file is prepared by Ahk2Exe and compressed by mpress.exe:"]
					. "`n`n" . A_ScriptDir . "\" . SubStr(A_ScriptName, 1, -4) . ".exe" . "`n`n" . "/bin" . ":" . A_Space . "Unicode 32-bit.bin" . A_Space . "cp:" . A_Space . "65001" . A_Space . "(Unicode (UTF-8))"
					. "`n" . TransA["Built with Autohotkey.exe version"] . ":" . A_Space . A_AhkVersion			
		}
	}
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_Reload()
{
	global ;assume-global mode
	MsgBox, 36, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["question"], % TransA["Are you sure you want to reload this application now?"]
		. "`n" . TransA["(Current configuration will be saved befor reload takes place)."]
	
	IfMsgBox, Yes
	{
		if (WinExist("ahk_id" HS3GuiHwnd) or WinExist("ahk_id" HS4GuiHwnd))
		{
			F_SaveGUIPos()
			ini_GuiReload := true
			IniWrite, % ini_GuiReload,		% HADConfig, GraphicalUserInterface, GuiReload
			Switch A_ThisMenuItem
			{
				Case % TransA["Reload in default mode"]:
				Switch A_IsCompiled
				{
					Case % true:	Run, % A_ScriptFullPath 
					Case "": 		Run, % A_AhkPath . A_Space . A_ScriptFullPath 
				}
				Case % TransA["Reload in silent mode"]:
				Switch A_IsCompiled
				{
					Case % true:	Run, % A_ScriptFullPath . A_Space . "l"
					Case "": 		Run, % A_AhkPath . A_Space . A_ScriptFullPath . A_Space . "l"
				}
				Default:	;used when file was downloaded from GitHub repository
				Switch A_IsCompiled
				{
					Case % true:	Run, % A_ScriptFullPath 
					Case "": 		Run, % A_AhkPath . A_Space . A_ScriptFullPath 
				}
			}
		}
		else
			Switch A_ThisMenuItem
			{
				Case % TransA["Reload in default mode"]:
					Switch A_IsCompiled
					{
						Case % true:	Run, % A_ScriptFullPath 
						Case "": 		Run, % A_AhkPath . A_Space . A_ScriptFullPath 
					}
				Case % TransA["Reload in silent mode"]:
					Switch A_IsCompiled
					{
						Case % true:	Run, % A_ScriptFullPath . A_Space . "l"
						Case "": 		Run, % A_AhkPath . A_Space . A_ScriptFullPath . A_Space . "l"
					}
			}
	}
	IfMsgBox, No
		return
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_Exit()
{
	global ;assume-global mode
	MsgBox, 36, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["question"], % TransA["Are you sure you want to exit this application now?"]
	IfMsgBox, Yes
		ExitApp, 0 ;Zero is traditionally used to indicate success.
	IfMsgBox, No
		return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_ToggleSandbox()
{
	global ;assume-global mode
	
	Menu, ConfGUI, ToggleCheck, % TransA["Show Sandbox (F6)"]
	ini_Sandbox := !(ini_Sandbox)
	Iniwrite, %ini_Sandbox%, % HADConfig, GraphicalUserInterface, Sandbox
	
	F_GuiMain_Redraw()
	F_GuiHS4_Redraw()
	;Gui, % A_DefaultGui . ":" . A_Space . "Show", AutoSize	
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_LoadGUIPos()
{
	global ;assume-global mode
	local ini_ReadTemp := 0
	
	ini_HS3WindoPos 	:= {"X": 0, "Y": 0, "W": 0, "H": 0} ;at the moment associative arrays are not supported in AutoHotkey as parameters of Commands
	ini_ListViewPos 	:= {"X": 0, "Y": 0, "W": 0, "H": 0} ;at the moment associative arrays are not supported in AutoHotkey as parameters of Commands
	ini_WhichGui := ""
	ini_Sandbox := true
	
	IniRead, ini_ReadTemp, 						% HADConfig, GraphicalUserInterface, MainWindowPosX, 0
	ini_HS3WindoPos["X"] := ini_ReadTemp
	IniRead, ini_ReadTemp, 						% HADConfig, GraphicalUserInterface, MainWindowPosY, 0
	ini_HS3WindoPos["Y"] := ini_ReadTemp
	IniRead, ini_ReadTemp, 						% HADConfig, GraphicalUserInterface, MainWindowPosW, 0
	ini_HS3WindoPos["W"] := ini_ReadTemp
	IniRead, ini_ReadTemp, 						% HADConfig, GraphicalUserInterface, MainWindowPosH, 0
	ini_HS3WindoPos["H"] := ini_ReadTemp
	
	IniRead, ini_ReadTemp,						% HADConfig, GraphicalUserInterface, ListViewPosW, % A_Space
	ini_ListViewPos["W"] := ini_ReadTemp
	IniRead, ini_ReadTemp,						% HADConfig, GraphicalUserInterface, ListViewPosH, % A_Space
	ini_ListViewPos["H"] := ini_ReadTemp
	
	IniRead, ini_Sandbox, 						% HADConfig, GraphicalUserInterface, Sandbox,				1
	IniRead, ini_IsSandboxMoved,					% HADConfig, GraphicalUserInterface, IsSandboxMoved 
	IniRead, ini_WhichGui,						% HADConfig, GraphicalUserInterface, WhichGui, %A_Space%
	if !(ini_WhichGui)
		ini_WhichGui := "HS3"
	IniRead, ini_HS3GuiMaximized,					% HADConfig, GraphicalUserInterface, GuiMaximized, 0
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

F_CheckCreateConfigIni()
{
	global ;assume-global mode
	local ConfigIni := ""	; variable which is used as default content of Config.ini
	
	ConfigIni := "			
	(
[Configuration]
ClipBoardPasteDelay=300
HotstringUndo=1
ShowIntro=1
CheckRepo=0
DownloadRepo=0
HK_Main=#^h
HK_IntoEdit=~^c
HK_UndoLH=~^F12
[TriggerstringTips_Styling]
TriggerstringTipsBackgroundColor=white
TriggerstringTipsBackgroundColorCustom=
TriggerstringTipsTypefaceColor=black
TriggerstringTipsTypefaceColorCustom=
TriggerstringTipsTypefaceFont=Calibri
TriggerstringTipsTypefaceSize=10
[HotstringMenu_Styling]
HotstringMenuBackgroundColor=white
HotstringMenuBackgroundColorCustom=
HotstringMenuTypefaceColorCustom=
HotstringMenuTypefaceColor=black
HotstringMenuTypefaceFont=Calibri
HotstringMenuTypefaceSize=10
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
[GraphicalUserInterface]
Language=English.txt
MainWindowPosX=
MainWindowPosY=
MainWindowPosW=
MainWindowPosH=
ListViewPosW=
ListViewPosH=
Sandbox=1
IsSandboxMoved=0
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
Semicolon ;=1
Slash /=0
Space=1
Tab=1
Underscore _=1
[LoadLibraries]
[ShowTipsLibraries]
	)"
	
	if (!FileExist(HADConfig))
	{
		if (!InStr(FileExist(A_AppData . "\" . SubStr(A_ScriptName, 1, -4)), "D"))	;if there is no folder...
		{
			FileCreateDir, % A_AppData . "\" . SubStr(A_ScriptName, 1, -4)	;future: check against errors
		}
		FileAppend, %ConfigIni%, % HADConfig
		MsgBox, 48, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["warning"], % TransA["Config.ini wasn't found. The default Config.ini has now been created in location:"] . "`n`n" . HADConfig
	}
	return	
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
F_SaveGUIPos(param*) ;Save to Config.ini
{
	global ;assume-global mode
	local WinX := 0, WinY := 0
		,TempPos := 0, TempPosX := 0, TempPosY := 0, TempPosW := 0, TempPosH := 0
	
	if (param[1] = "reset") ;if AutoSize option will be used for Gui after reload
	{
		if (A_DefaultGui = "HS3")
		{
			WinGetPos, WinX, WinY, , , % "ahk_id" . HS3GuiHwnd
		}
		if (A_DefaultGui = "HS4")
		{
			WinGetPos, WinX, WinY, , , % "ahk_id" . HS4GuiHwnd
		}
		IniWrite, % WinX, 			  	% HADConfig, GraphicalUserInterface, MainWindowPosX
		IniWrite, % WinY, 			  	% HADConfig, GraphicalUserInterface, MainWindowPosY
		IniWrite, % "", 				% HADConfig, GraphicalUserInterface, MainWindowPosW
		IniWrite, % "", 				% HADConfig, GraphicalUserInterface, MainWindowPosH
		return
	}	
	
	if (A_DefaultGui = "HS3")
	{
		WinGetPos, WinX, WinY, , , % "ahk_id" . HS3GuiHwnd
		IniWrite,  HS3,			% HADConfig, GraphicalUserInterface, WhichGui
		IniWrite, % HS3_GuiWidth, 	% HADConfig, GraphicalUserInterface, MainWindowPosW
		IniWrite, % HS3_GuiHeight, 	% HADConfig, GraphicalUserInterface, MainWindowPosH
		GuiControlGet, TempPos,	Pos, % IdListView1
		IniWrite, % TempPosW,		% HADConfig, GraphicalUserInterface, ListViewPosW
		IniWrite, % TempPosH,		% HADConfig, GraphicalUserInterface, ListViewPosH
		IniWrite, % ini_HS3GuiMaximized, 	% HADConfig, GraphicalUserInterface, GuiMaximized
	}
	
	if (A_DefaultGui = "HS4")
	{
		WinGetPos, WinX, WinY, , , % "ahk_id" . HS4GuiHwnd
		IniWrite,  HS4,			% HADConfig, GraphicalUserInterface, WhichGui
		IniWrite, % HS4_GuiWidth, 	% HADConfig, GraphicalUserInterface, MainWindowPosW
		IniWrite, % HS4_GuiHeight, 	% HADConfig, GraphicalUserInterface, MainWindowPosH
	}
	
	IniWrite, % WinX, 			  % HADConfig, GraphicalUserInterface, MainWindowPosX
	IniWrite, % WinY, 			  % HADConfig, GraphicalUserInterface, MainWindowPosY
	
	IniWrite, % ini_Sandbox, 	  % HADConfig, GraphicalUserInterface, Sandbox
	IniWrite, % ini_IsSandboxMoved, % HADConfig, GraphicalUserInterface, IsSandboxMoved
	
	MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["Position of main window is saved in Config.ini."]
	return		
	
}
	
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	
F_LoadHotstringsFromLibraries()
{
	global ; assume-global mode
	local key := "", value := "", PriorityFlag := false
	a_Library 				:= []
	a_TriggerOptions 			:= []
	a_Triggerstring 			:= []
	a_OutputFunction 			:= []
	a_EnableDisable 			:= []
	a_Hotstring				:= []
	a_Comment 				:= []
	
; Prepare TrayTip message taking into account value of command line parameter.
	if (v_Param == "d")
		TrayTip, %A_ScriptName% - Debug mode, 	% TransA["Loading hotstrings from libraries..."], 1
	else if (v_Param == "l")
		TrayTip, %A_ScriptName% - Lite mode, 	% TransA["Loading hotstrings from libraries..."], 1
	else	
		TrayTip, %A_ScriptName%,				% TransA["Loading hotstrings from libraries..."], 1
	
; Load (triggerstring, hotstring) definitions if enabled and triggerstring tips if enabled.
	v_TotalHotstringCnt := 0
	
	for key, value in ini_LoadLib
	{
		if ((key != "PriorityLibrary.csv") and (value))
			F_LoadFile(key)
		if ((key == "PriorityLibrary.csv") and (value))
			PriorityFlag := true
	}
	if (PriorityFlag)
	{
		F_LoadFile("PriorityLibrary.csv")
		PriorityFlag := false
	}
	return
}
	
; ------------------------------------------------------------------------------------------------------------------------------------
	
F_UpdateSelHotLibDDL()
;Load content of DDL2 and mark disabled libraries
{
	global ;assume-global mode
	local key := "", value := "", FinalString := ""
	
	if (ini_LoadLib.Count()) ;if ini_LoadLib isn't empty
	{
		FinalString .= TransA["↓ Click here to select hotstring library ↓"] . "||"
		for key, value in ini_LoadLib
		{
			if !(value)
			{
				FinalString .= key . A_Space . TransA["DISABLED"]
				
			}
			else
			{
				FinalString .= key 
			}
			FinalString .= "|"
		}
	}
	else ;if ini_LoadLib is empty
	{
		FinalString .=  TransA["No libraries have been found!"] . "||" 
	}
	
	GuiControl, , % IdDDL2, % "|" . FinalString 	;To replace (overwrite) the list instead, include a pipe as the first character
	GuiControl, , % IdDDL2b, % "|" . FinalString	;To replace (overwrite) the list instead, include a pipe as the first character
	return
}
	
; ------------------------------------------------------------------------------------------------------------------------------------
	
F_ToggleTipsLibrary()
{
	global ;assume-global mode
	local v_LibraryFlag := 0 
	
	Menu, ToggleLibTrigTipsSubmenu, ToggleCheck, %A_ThisMenuitem%
	IniRead, v_LibraryFlag, % HADConfig, ShowTipsLibraries, %A_ThisMenuitem%
	v_LibraryFlag := !(v_LibraryFlag)
	IniWrite, %v_LibraryFlag%, % HADConfig, ShowTipsLibraries, %A_ThisMenuitem%
	
	F_ValidateIniLibSections()
	a_Triggers := []
	F_LoadHotstringsFromLibraries()
	F_Sort_a_Triggers()
	return
}
	
; ------------------------------------------------------------------------------------------------------------------------------------
F_EnDisLib() 
{
	global ;assume-global mode
	local v_LibraryFlag := 0, name := "", key := 0, value := "", FoundAmongKeys := false
	
	Menu, EnDisLib, ToggleCheck, %A_ThisMenuItem%	;future: don't ready .ini file, instead use appropriate table
	IniRead, v_LibraryFlag,	% HADConfig, LoadLibraries, %A_ThisMenuitem%
	v_LibraryFlag := !(v_LibraryFlag)
	Iniwrite, %v_LibraryFlag%,	% HADConfig, LoadLibraries, %A_ThisMenuItem%
	name := SubStr(A_ThisMenuItem, 1, -4)	;removing of file extension
	
	if (v_LibraryFlag)
	{
		for key, value in a_Library
		{
			if (value = name)
			{
				FoundAmongKeys := true
				Options := a_TriggerOptions[key]
				if (InStr(Options, "*0"))
					Options := StrReplace(Options, "*0", "*")
				if (InStr(Options, "B"))
					Options := StrReplace(Options, "B", "B0")
				if (InStr(Options, "O0"))
					Options := StrReplace(Options, "O0", "O")
				if (InStr(Options, "Z0"))
					Options := StrReplace(Options, "Z0", "Z")
				TriggerString := a_Triggerstring[key]
				TriggerString := StrReplace(TriggerString, "``n", "`n") ;theese lines are necessary to handle rear definitions of hotstrings such as those finished with `n, `r etc.
				TriggerString := StrReplace(TriggerString, "``r", "`r") ;future: add more sequences like {Esc} etc.
				TriggerString := StrReplace(TriggerString, "``t", "`t")
				TriggerString := StrReplace(TriggerString, "``", "`")
				TriggerString := StrReplace(TriggerString, "``b", "`b")
				if (a_EnableDisable[key] = "En")
				{
					Try
						Hotstring(":" . Options . ":" . TriggerString, , "On") ;Disable existing hotstring
					Catch
						MsgBox, 16, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["Error"], % A_ThisFunc . A_Space . TransA["Something went wrong with disabling of existing hotstring"] 
					. ":" . "`n`n" . "TriggerString:" . A_Space . TriggerString . "`n" . A_Space . "Options:" . A_Space . Options . "`n`n" . TransA["Library name:"] 
					. A_Space . nameoffile 				
				}
			}
		}
		if (!FoundAmongKeys)
			F_LoadFile(A_ThisMenuItem)
		MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["The (triggerstring, hotstring) definitions have been uploaded from library file"] . ":"
		. "`n`n" . A_ThisMenuItem
	}
	else
	{
		F_UnloadFile(A_ThisMenuItem)
		MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["The (triggerstring, hotstring) definitions stored in the following library file have been unloaded from memory"]
		. ":" . "`n`n" . A_ThisMenuItem
	}
	F_ValidateIniLibSections()
	F_UpdateSelHotLibDDL()
	F_Clear()
	return
}
; ------------------------------------------------------------------------------------------------------------------------------------
F_UnloadFile(nameoffile)	
{	
	global ;assume-global mode
	local	v_TheWholeFile := "",	Options := "",	TriggerString := ""
			,key := 0,	value := "", FilenameWitoutExt := ""
	
	FilenameWitoutExt := SubStr(nameoffile, 1, -4)
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
			TriggerString := StrReplace(TriggerString, "``n", "`n") ;theese lines are necessary to handle rear definitions of hotstrings such as those finished with `n, `r etc.
			TriggerString := StrReplace(TriggerString, "``r", "`r") ;future: add more sequences like {Esc} etc.
			TriggerString := StrReplace(TriggerString, "``t", "`t")
			TriggerString := StrReplace(TriggerString, "``", "`")
			TriggerString := StrReplace(TriggerString, "``b", "`b")
			if (a_EnableDisable[key] = "En")
			{
				Try
					Hotstring(":" . Options . ":" . TriggerString, , "Off") ;Disable existing hotstring
				Catch
					MsgBox, 16, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["Error"], % A_ThisFunc . A_Space . TransA["Something went wrong with disabling of existing hotstring"] 
					. ":" . "`n`n" . "TriggerString:" . A_Space . TriggerString . "`n" . A_Space . "Options:" . A_Space . Options . "`n`n" . TransA["Library name:"] 
					. A_Space . nameoffile 				
			}
		}
	}
	return
}
; ------------------------------------------------------------------------------------------------------------------------------------
F_LoadCreateTranslationTxt(decision*)
{
	global ;assume-global mode
	local TransConst := "" ; variable which is used as default content of Languages/English.ini. Join lines with `n separator and escape all ` occurrences. Thanks to that string lines where 'n is present 'aren't separated.
	,v_TheWholeFile := "", key := "", val := "", tick := false
	
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
Add comment (optional) 									= Add comment (optional)
Add hotstring (F9) 										= Add hotstring (F9)
Add library 											= Add library
Add to Autostart										= Add to Autostart
After downloading libraries aren't automaticlly loaded into memory. Would you like to upload content of libraries folder? into memory? = After downloading libraries aren't automaticlly loaded into memory. Would you like to upload content of libraries folder? into memory?
A library with that name already exists! 					= A library with that name already exists!
Alphabetically 										= Alphabetically
already exists in another library							= already exists in another library
Apostrophe ' 											= Apostrophe '
Application											= A&pplication
Application help										= Application help
Application language changed to: 							= Application language changed to:
Apply && Close											= Apply && Close
aqua													= aqua
Are you sure?											= Are you sure?
Are you sure you want to exit this application now?			= Are you sure you want to exit this application now?
Are you sure you want to reload this application now?			= Are you sure you want to reload this application now?
Background color										= Background color
Backslash \ 											= Backslash \
Basic hotstring is triggered								= Basic hotstring is triggered
black												= black
blue													= blue
Built with Autohotkey.exe version							= Built with Autohotkey.exe version
By length 											= By length
Call Graphical User Interface								= Call Graphical User Interface
Cancel 												= Cancel
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
Choose menu position 									= Choose menu position
Choose sending function! 								= Choose sending function!
Choose the method of sending the hotstring! 					= Choose the method of sending the hotstring!
Choose tips location 									= Choose tips location
Clear (F5) 											= Clear (F5)
Clipboard Delay (F7)									= Clipboard &Delay (F7)
Clipboard paste delay in [ms]:  							= Clipboard paste delay in [ms]:
Closing Curly Bracket } 									= Closing Curly Bracket }
Closing Round Bracket ) 									= Closing Round Bracket )
Closing Square Bracket ] 								= Closing Square Bracket ]
Colon : 												= Colon :
Comma , 												= Comma ,
Compile												= Compile
Compressed executable (upx.exe)							= Compressed executable (upx.exe)
Compressed executable (mpress.exe)							= Compressed executable (mpress.exe)
Config.ini wasn't found. The default Config.ini has now been created in location: = Config.ini wasn't found. The default Config.ini has now been created in location:
Configuration 											= &Configuration
Content of clipboard contain new line characters. Do you want to remove them? = Content of clipboard contain new line characters. Do you want to remove them?
Continue reading the library file? If you answer ""No"" then application will exit! = Continue reading the library file? If you answer ""No"" then application will exit!
Conversion of .ahk file into new .csv file (library) and loading of that new library = Conversion of .ahk file into new .csv file (library) and loading of that new library
Conversion of .csv library file into new .ahk file containing static (triggerstring, hotstring) definitions = Conversion of .csv library file into new .ahk file containing static (triggerstring, hotstring) definitions
Conversion of .csv library file into new .ahk file containing dynamic (triggerstring, hotstring) definitions = Conversion of .csv library file into new .ahk file containing dynamic (triggerstring, hotstring) definitions
Converted												= Converted
Copy clipboard content into ""Enter hotstring""				= Copy clipboard content into ""Enter hotstring""
Current shortcut (hotkey):								= Current shortcut (hotkey):
(Current configuration will be saved befor reload takes place).	= (Current configuration will be saved befor reload takes place).
cursor												= cursor
custom												= custom
Download if update is available on startup?					= Download if update is available on startup?
Download public libraries								= Download public libraries
Do you want to delete it?								= Do you want to delete it?
Do you want to proceed? 									= Do you want to proceed?
Dark													= Dark
Default mode											= Default mode
Delete hotstring (F8) 									= Delete hotstring (F8)
Deleting hotstring... 									= Deleting hotstring...
Deleting hotstring. Please wait... 						= Deleting hotstring. Please wait...
Disable 												= Disable
DISABLED												= DISABLED
Dot . 												= Dot .
Do you want to reload application now?						= Do you want to reload application now?
doesn't exist in application folder						= doesn't exist in application folder
Download repository version								= Download repository version
Dynamic hotstrings 										= &Dynamic hotstrings
Edit Hotstrings 										= Edit Hotstrings
Enable												= Enable
Enable/disable libraries									= Enable/disable &libraries
Enable/disable triggerstring tips 							= Enable/disable triggerstring tips	
Enables Convenient Definition 							= Enables convenient definition and use of hotstrings (triggered by shortcuts longer text strings). `nThis is 4th edition of this application, 2021 by Maciej Słojewski (🐘). `nLicense: GNU GPL ver. 3.
Enter 												= Enter 
Enter a name for the new library 							= Enter a name for the new library
Enter hotstring 										= Enter hotstring
Enter triggerstring										= Enter triggerstring
Enter triggerstring before hotstring is set					= Enter triggerstring before hotstring is set
Error												= Error
ErrorLevel was triggered by NewInput error. 					= ErrorLevel was triggered by NewInput error.
Error reading library file:								= Error reading library file:
Exclamation Mark ! 										= Exclamation Mark !
exists in the currently selected library					= exists in the currently selected library
exists in the library									= exists in the library
exists in a file and will now be replaced.					= exists in a file and will now be replaced.
Exit													= Exit
Exit application										= Exit application
Export from .csv to .ahk 								= &Export from .csv to .ahk
Export to .ahk with static definitions of hotstrings			= Export to .ahk with static definitions of hotstrings
Export to .ahk with dynamic definitions of hotstrings			= Export to .ahk with dynamic definitions of hotstrings
Exported												= Exported
Facilitate working with AutoHotkey triggerstring and hotstring concept, with GUI and libraries = Facilitate working with AutoHotkey triggerstring and hotstring concept, with GUI and libraries
F3 or Esc: Close Search hotstrings | F8: Move hotstring between libraries = F3 or Esc: Close Search hotstrings | F8: Move hotstring between libraries
file! 												= file!
file in Languages subfolder!								= file in Languages subfolder!
file is now created in the following subfolder:				= file is now created in the following subfolder:
Finite timeout?										= Finite timeout?
folder is now created									= folder is now created
Font type												= Font type
fuchsia												= fuchsia
Graphical User Interface									= Graphical User Interface
gray													= gray
green												= green
has been created. 										= has been created.
has been downloaded to the location						= has been downloaded to the location
Help: AutoHotkey Hotstrings reference guide					= Help: AutoHotkey Hotstrings reference guide
Help: Hotstrings application								= Help: Hotstrings application
Hotstring 											= Hotstring
Hotstring added to the file								= Hotstring added to the file
Hotstring has been deleted. Now application will restart itself in order to apply changes, reload the libraries (.csv) = Hotstring has been deleted. Now application will restart itself in order to apply changes, reload the libraries (.csv)
Hotstring menu styling									= Hotstring menu styling
Hotstring was triggered! 								= Hotstring was triggered!
""Hotstring was triggered"" tooltip timeout in [ms]			= ""Hotstring was triggered"" tooltip timeout in [ms]
""Undid the last hotstring!"" tooltip timeout in [ms]			= ""Undid the last hotstring!"" tooltip timeout in [ms]
Hotstring moved to the 									= Hotstring moved to the
Hotstring paste from Clipboard delay 1 s 					= Hotstring paste from Clipboard delay 1 s
Hotstring paste from Clipboard delay 						= Hotstring paste from Clipboard delay
Hotstrings have been loaded 								= Hotstrings have been loaded
HTML color RGB value, e.g. 00FF00							= HTML color RGB value, e.g. 00FF00
I wish you good work with Hotstrings and DFTBA (Don't Forget to be Awsome)! = I wish you good work with Hotstrings and DFTBA (Don't Forget to be Awsome)!
If not finite, define tooltip timeout						= If not finite, define tooltip timeout
If sound is enabled, define it							= If sound is enabled, define it
If you answer ""Yes"" it will overwritten.					= If you answer ""Yes"" it will overwritten.
If you answer ""Yes"" definition existing in another library will not be changed. = If you answer ""Yes"" definition existing in another library will not be changed.
If you answer ""Yes"", the icon file will be downloaded. If you answer ""No"", the default AutoHotkey icon will be used. = If you answer ""Yes"", the icon file will be downloaded. If you answer ""No"", the default AutoHotkey icon will be used.
If you answer ""Yes"", the existing file will be deleted. This is recommended choice. If you answer ""No"", new content will be added to existing file. = If you answer ""Yes"", the existing file will be deleted. This is recommended choice. If you answer ""No"", new content will be added to existing file.
If you answer ""No"" edition of the current definition will be interrupted. = If you answer ""No"" edition of the current definition will be interrupted.
Immediate Execute (*) 									= Immediate Execute (*)
Import from .ahk to .csv 								= &Import from .ahk to .csv
Incorrect value. Select custom RGB hex value. Please try again.	= Incorrect value. Select custom RGB hex value. Please try again.
In order to display library content please at first select hotstring library = In order to display library content please at first select hotstring library
In order to restore default configuration, the current Config.ini file will be deleted. This action cannot be undone. Next application will be reloaded and upon start the Config.ini with default settings will be created. = In order to restore default configuration, the current Config.ini file will be deleted. This action cannot be undone. Next application will be reloaded and upon start the Config.ini with default settings will be created.
information											= information
Inside Word (?) 										= Inside Word (?)
In order to aplly new font style it's necesssary to reload the application. 	= In order to aplly new font style it's necesssary to reload the application.
In order to aplly new font type it's necesssary to reload the application. 	= In order to aplly new font type it's necesssary to reload the application.
In order to aplly new size of margin it's necesssary to reload the application. = In order to aplly new size of margin it's necesssary to reload the application.
In order to aplly new style it's necesssary to reload the application. 		= In order to aplly new style it's necesssary to reload the application.
is added in section  [GraphicalUserInterface] of Config.ini		= is added in section  [GraphicalUserInterface] of Config.ini
is empty. No (triggerstring, hotstring) definition will be loaded. Do you want to create the default library file: PriorityLibrary.csv? = is empty. No (triggerstring, hotstring) definition will be loaded. Do you want to create the default library file: PriorityLibrary.csv?
Introduction											= Introduction
\Languages\`nMind that Config.ini Language variable is equal to 	= \Languages\`nMind that Config.ini Language variable is equal to
Let's make your PC personal again... 						= Let's make your PC personal again...
Libraries 											= &Libraries
Libraries folder:										= Libraries folder:
Library content (F2)									= Library content (F2)
Library 												= Library
Library name:											= Library name:
Library export. Please wait... 							= Library export. Please wait...
Library has been exported 								= Library has been exported
Library has been imported. 								= Library has been imported.
Library|Triggerstring|Trigger Options|Output Function|Enable/Disable|Hotstring|Comment = Library|Triggerstring|Trigger Options|Output Function|Enable/Disable|Hotstring|Comment
Light (default)										= Light (default)
lime													= lime
Link file (.lnk) was created in AutoStart folder				= Link file (.lnk) was created in AutoStart folder
Loading of (triggerstring, hotstring) definitions from the library file = Loading of (triggerstring, hotstring) definitions from the library file
Loading file											= Loading file
Loaded hotstrings: 										= Loaded hotstrings:
Loading hotstrings from libraries... 						= Loading hotstrings from libraries...
Loading imported library. Please wait...					= Loading imported library. Please wait...
Loaded												= Loaded
Local version:											= Local version:
maroon												= maroon
Max. no. of shown tips									= Max. no. of shown tips
Maximum number of shown triggerstring tips					= Maximum number of shown triggerstring tips
Menu hotstring is triggered								= Menu hotstring is triggered
Menu position											= Menu position
Menu position: caret									= Menu position: caret
Menu position: cursor									= Menu position: cursor
Minus - 												= Minus -
Move (F8)												= Move (F8)
navy													= navy
New shortcut (hotkey)									= New shortcut (hotkey)
No													= No
no													= no
No Backspace (B0) 										= No Backspace (B0)
No EndChar (O) 										= No EndChar (O)
No libraries have been found!								= No libraries have been found!
Not Case-Conforming (C1)									= Not Case-Conforming (C1)
Number of characters for tips 							= &Number of characters for tips
of													= of
OK													= &OK
olive												= olive
On start-up the local version of							= On start-up the local version of
Open libraries folder in Explorer							= Open libraries folder in Explorer
Opening Curly Bracket { 									= Opening Curly Bracket {
Opening Round Bracket ( 									= Opening Round Bracket (
Opening Square Bracket [ 								= Opening Square Bracket [
Please wait, uploading .csv files... 						= Please wait, uploading .csv files...
question												= question
Question Mark ? 										= Question Mark ?
Quote "" 												= Quote ""
Pause												= Pause
Pause application										= Pause application
Phrase to search for:									= Phrase to search for:
pixels												= pixels
Position of main window is saved in Config.ini.				= Position of main window is saved in Config.ini.	
Preview												= Preview
Public library:										= Public library:
purple												= purple
)"	;A continuation section cannot produce a line whose total length is greater than 16,383 characters. See documentation for workaround.
	TransConst .= "`n
(Join`n `
Recognized encoding of the script file:						= Recognized encoding of the script file:
red													= red
Reload												= Reload
Reload in default mode									= Reload in default mode
Reload in silent mode									= Reload in silent mode
Replacement text is blank. Do you want to proceed? 			= Replacement text is blank. Do you want to proceed?
Repository version:										= Repository version:
Required encoding: UTF-8 with BOM. Application will exit now.	= Required encoding: UTF-8 with BOM. Application will exit now.
Reset Recognizer (Z)									= Reset Recognizer (Z)
Restore default										= Restore default
Restore default hotkey									= Restore default hotkey
Restore default configuration								= Restore default configuration
Row													= Row
Sandbox (F6)											= Sandbox (F6)
Save hotkey											= Save hotkey
Save position of application window	 					= &Save position of application window
Saved												= Saved
Saving of sorted content into .csv file (library)				= Saving of sorted content into .csv file (library)
Search by: 											= Search by:
Search Hotstrings 										= Search Hotstrings
Search Hotstrings (F3)									= &Search Hotstrings (F3)
Select a row in the list-view, please! 						= Select a row in the list-view, please!
Select hotstring library									= Select hotstring library
Selected Hotstring will be deleted. Do you want to proceed? 	= Selected Hotstring will be deleted. Do you want to proceed?
Select hotstring output function 							= Select hotstring output function
Select the target library: 								= Select the target library:
Select triggerstring option(s)							= Select triggerstring option(s)
Semicolon ; 											= Semicolon ;
Send Raw (R)											= Send Raw (R)
Set Clipboard Delay										= Set Clipboard Delay
Set delay												= Set delay
Set ""Hotstring was triggered"" tooltip timeout				= Set ""Hotstring was triggered"" tooltip timeout
Set ""Undid the last hotstring!"" tooltip timeout				= Set ""Undid the last hotstring!"" tooltip timeout
Set maximum number of shown triggerstring tips				= Set maximum number of shown triggerstring tips
Set triggerstring tip(s) tooltip timeout					= Set triggerstring tip(s) tooltip timeout
Set parameters of menu sound								= Set parameters of menu sound
Set parameters of triggerstring sound						= Set parameters of triggerstring sound
Set sound parameters for event ""basic hotstring""			= Set sound parameters for event ""basic hotstring""
Set sound parameters for event ""hotstring menu""				= Set sound parameters for event ""hotstring menu""
Set sound parameters for event ""undo hotstring""				= Set sound parameters for event ""undo hotstring""
Shortcut (hotkey) definition								= Shortcut (hotkey) definition
Shortcut (hotkey) definitions								= Shortcut (hotkey) definitions
Show full GUI (F4)										= Show full GUI (F4)
Show intro											= Show intro
Show Introduction window after application is restarted?		= Show Introduction window after application is restarted?
Show Sandbox (F6)										= Show Sandbox (F6)
Signaling of events										= Signaling of events
Silent mode											= Silent mode
silver												= silver
Size of font											= Size of font
Size of margin:										= Size of margin:
Slash / 												= Slash /
Something went wrong during hotstring setup					= Something went wrong during hotstring setup
Something went wrong with disabling of existing hotstring		= Something went wrong with disabling of existing hotstring
Something went wrong with (triggerstring, hotstring) creation	= Something went wrong with (triggerstring, hotstring) creation
Something went wrong with hotstring deletion					= Something went wrong with hotstring deletion
Something went wrong with hotstring EndChars					= Something went wrong with hotstring EndChars
Something weng wrong with link file (.lnk) creation			= Something weng wrong with link file (.lnk) creation
Sound disable											= Sound disable
Sound duration [ms]										= Sound duration [ms]
Sound enable											= Sound enable
Sound frequency										= Sound frequency
Sound parameters										= Sound parameters
Sound test											= Sound test
Sorting order											= Sorting order
Space												= Space
Specified definition of hotstring has been deleted			= Specified definition of hotstring has been deleted
Standard executable (Ahk2Exe.exe)							= Standard executable (Ahk2Exe.exe)
Static hotstrings 										= &Static hotstrings
Style of GUI											= Style of GUI
Such file already exists									= Such file already exists
Suspend Hotkeys										= Suspend Hotkeys
Tab 													= Tab 
teal													= teal
Test styling											= Test styling
The application										= The application
The application will be reloaded with the new language file. 	= The application will be reloaded with the new language file.
The default											= The default
The default language file (English.txt) will be deleted (it will be automatically recreated after restart). However if you use localized version of language file, you'd need to download it manually. = The default language file (English.txt) will be deleted (it will be automatically recreated after restart). However if you use localized version of language file, you'd need to download it manually.
The executable file is prepared by Ahk2Exe and compressed by mpress.exe: = The executable file is prepared by Ahk2Exe and compressed by mpress.exe:
The executable file is prepared by Ahk2Exe and compressed by upx.exe: = The executable file is prepared by Ahk2Exe and compressed by upx.exe:
The executable file is prepared by Ahk2Exe, but not compressed:	= The executable file is prepared by Ahk2Exe, but not compressed:
The file which you want to download from Internet, already exists on your local harddisk. Are you sure you want to download it? = The file which you want to download from Internet, already exists on your local harddisk. Are you sure you want to download it? `n`n If you answer ""yes"", your local file will be overwritten. If you answer ""no"", download will be continued.
The icon file											= The icon file
The hostring 											= The hostring
The already imported file already existed. As a consequence some (triggerstring, hotstring) definitions could also exist and ""Total"" could be incredible. Therefore application will be now restarted in order to correctly apply the changes. = The already imported file already existed. As a consequence some (triggerstring, hotstring) definitions could also exist and ""Total"" could be incredible. Therefore application will be now restarted in order to correctly apply the changes.
The library  											= The library 
The file path is: 										= The file path is:
the following line is found:								= the following line is found:
There is no Libraries subfolder and no lbrary (*.csv) file exists! = There is no Libraries subfolder and no lbrary (*.csv) file exists!
The parameter Language in section [GraphicalUserInterface] of Config.ini is missing. = The parameter Language in section [GraphicalUserInterface] of Config.ini is missing.
The script											= The script
The selected file is empty. Process of import will be interrupted. = The selected file is empty. Process of import will be interrupted.
The (triggerstring, hotstring) definitions have been uploaded from library file = The (triggerstring, hotstring) definitions have been uploaded from library file
The (triggerstring, hotstring) definitions stored in the following library file have been unloaded from memory = The (triggerstring, hotstring) definitions stored in the following library file have been unloaded from memory
There is no											= There is no
There was no Languages subfolder, so one now is created.		= There was no Languages subfolder, so one now is created.
This is the maximum length of list displayed on the screen in form of tooltip containing triggerstring tips. = This is the maximum length of list displayed on the screen in form of tooltip containing triggerstring tips.
This library:											= This library:
This line do not comply to format required by this application.  = This line do not comply to format required by this application.
This option is valid 									= In case you observe some hotstrings aren't pasted from clipboard increase this value. `nThis option is valid for CL and MCL hotstring output functions. 
Timeout value [ms]										= Timeout value [ms]
Tilde (~) key modifier									= Tilde (~) key modifier
Tip: If you copy text from PDF file it's adviced to remove them. = Tip: If you copy text from PDF file it's adviced to remove them.
Tips are shown after no. of characters						= Tips are shown after no. of characters
Toggle EndChars	 									= &Toggle EndChars
Tooltip disable										= Tooltip disable
Tooltip enable											= Tooltip enable
Tooltip position										= Tooltip position
Tooltip position: caret									= Tooltip position: caret
Tooltip position: cursor									= Tooltip position: cursor
Tooltip test											= Tooltip test
Tooltip timeout										= Tooltip timeout
Total:												= Total:
to undo.												= to undo.
(triggerstring, hotstring) definitions						= (triggerstring, hotstring) definitions
Triggerstring 											= Triggerstring
Triggerstring / hotstring behaviour						= Triggerstring / hotstring behaviour
Triggerstring sound duration [ms]							= Triggerstring sound duration [ms]
Triggerstring sound frequency range						= Triggerstring sound frequency range
Triggerstring tip(s) tooltip timeout in [ms]					= Triggerstring tip(s) tooltip timeout in [ms]
Triggerstring tips 										= Triggerstring tips
Triggerstring tips styling								= Triggerstring tips styling
Triggerstring tips and hotstring menu styling				= Triggerstring tips and hotstring menu styling
Triggerstring tooltip timeout in [ms]						= Triggerstring tooltip timeout in [ms]
Triggerstring|Trigg Opt|Out Fun|En/Dis|Hotstring|Comment 		= Triggerstring|Trigg Opt|Out Fun|En/Dis|Hotstring|Comment
Typeface color											= Typeface color
Typeface font											= Typeface font
Typeface size											= Typeface size
Underscore _											= Underscore _
Undo the last hotstring									= Undo the last hotstring
Undo the last hotstring									= Undo the last hotstring
Undid the last hotstring 								= Undid the last hotstring
Version / Update										= Version / Update
Visit public libraries webpage							= Visit public libraries webpage
warning												= warning
Warning, code generated automatically for definitions based on menu, see documentation of Hotstrings application for further details. = Warning, code generated automatically for definitions based on menu, see documentation of Hotstrings application for further details.
was compared with repository version and difference was discovered:	= was compared with repository version and difference was discovered:
was successfully downloaded.								= was successfully downloaded.
Welcome to Hotstrings application!							= Welcome to Hotstrings application!
Windows key modifier									= Windows key modifier
When ""basic hotsring"" event takes place, sound is emitted according to the following settings. = When ""basic hotsring"" event takes place, sound is emitted according to the following settings.
When ""hotstring menu"" event takes place, sound is emitted according to the following settings. = When ""hotstring menu"" event takes place, sound is emitted according to the following settings.
When ""undo hotstring"" event takes place, sound is emitted according to the following settings. = When ""undo hotstring"" event takes place, sound is emitted according to the following settings.
When timeout is set, the tooltip ""Hotstring was triggered"" will dissapear after time reaches it. = When timeout is set, the tooltip ""Hotstring was triggered"" will dissapear after time reaches it.
When timeout is set, the tooltip ""Undid the last hotstring!"" will dissapear after time reaches it. = When timeout is set, the tooltip ""Undid the last hotstring!"" will dissapear after time reaches it.
When timeout is set, the triggerstring tip(s) will dissapear after time reaches it. = When timeout is set, the triggerstring tip(s) will dissapear after time reaches it.
When triggerstring event takes place, sound is emitted according to the following settings. = When triggerstring event takes place, sound is emitted according to the following settings.
white												= white
Would you like to download the icon file?					= Would you like to download the icon file?
Would you like now to reload it in order to run the just downloaded version? = Would you like now to reload it in order to run the just downloaded version?
yellow												= yellow
Yes													= Yes
yes													= yes
""Basic hotstring"" sound duration [ms]						= ""Basic hotstring"" sound duration [ms]
""Basic hotstring"" sound frequency						= ""Basic hotstring"" sound frequency
""Hotstring menu"" sound duration [ms]						= ""Hotstring menu"" sound duration [ms]
""Hotstring menu"" sound frequency							= ""Hotstring menu"" sound frequency
""Undo hotstring"" sound duration [ms]						= ""Undo hotstring"" sound duration [ms]
""Undo hotstring"" sound frequency							= ""Undo hotstring"" sound frequency
↓ Click here to select hotstring library ↓					= ↓ Click here to select hotstring library ↓
)"
	TransConst .= "`n
(Join`n `
ShowInfoText											= In order to display graphical user interface (GUI) of the application just press shortcut: Win + Ctrl + H. `n`nSuggested steps after installation: `n`n1. Download some libraries (files containing (triggerstring, hotstring) definitions. You can do it from application menu:  → Libraries. `n`n2. After downloading of libraries restart application to apply the changes. Again, you can do it from application menu: Application → Restart. `n`n3. Application is preconfigured on the first start. Options available to be configured area available from GUI, application menu → Configuration. `n`n4. Application runs by default in default mode. If you don't wish to modify configuration, `nmay consider to run it in simplified mode: application menu → Application → Reload → Reload in silent mode.
F_TI_ImmediateExecute									= * (asterisk): An EndChar (e.g. Space, ., or Enter) is not required to trigger the hotstring. For example:`n`n:*:j@::jsmith@somedomain.com`n`nThe example above would send its replacement the moment you type the @ character.
F_TI_InsideWord										= ? (question mark): The hotstring will be triggered even when it is inside another word; `n`nthat is, when the character typed immediately before it is alphanumeric. `nFor example, if :?:al::airline is a hotstring, `ntyping ""practical "" would produce ""practicairline "".
F_TooltipTimeoutSlider									= You may slide the control by the following means: `n`n1) dragging the bar with the mouse; `n2) clicking inside the bar's track area with the mouse; `n3) turning the mouse wheel while the control has focus or `n4) pressing the following keys while the control has focus: ↑, →, ↓, ←, PgUp, PgDn, Home, and End. `n`nPgUp / PgDn step: 500 [ms]; `nInterval:         500 [ms]; `nRange:            1000 ÷ 10 000 [ms]. `n`nWhen required value is chosen just press Esc key to close this window or close it with mouse.
F_SoundDurSliderInfo									= You may slide the control by the following means: `n`n1) dragging the bar with the mouse; `n2) clicking inside the bar's track area with the mouse; `n3) turning the mouse wheel while the control has focus or `n4) pressing the following keys while the control has focus: ↑, →, ↓, ←, PgUp, PgDn, Home, and End. `n`nPgUp / PgDn step: 50 [ms]; `nInterval:         150 [ms]; `nRange:            50 ÷ 2 000 [ms]. `n`nWhen required value is chosen just press Esc key to close this window or close it with mouse.`n`nTip: Recommended time is between 200 to 400 ms.
F_SoundFreqSliderInfo									= You may slide the control by the following means: `n`n1) dragging the bar with the mouse; `n2) clicking inside the bar's track area with the mouse; `n3) turning the mouse wheel while the control has focus or `n4) pressing the following keys while the control has focus: ↑, →, ↓, ←, PgUp, PgDn, Home, and End. `n`nPgUp / PgDn step: 50; `nInterval:         3636; `nRange:            37 ÷ 32 767. `n`nWhen required value is chosen just press Esc key to close this window or close it with mouse.`n`nTip: Recommended value is between 200 to 2000. Mind that for your spcific PC some values outside of recommended range may not produce any sound.
F_TI_NoBackSpace										= B0: Automatic backspacing is not done to erase the abbreviation you type. `n`nOne may send ← five times via {left 5}. For example, the following hotstring produces ""<em></em>"" and `nmoves the caret 5 places to the left (so that it's between the tags) `n`n::*b0:<em>::</em>{left 5}
F_TI_NoEndChar											= O: Omit the ending character of auto-replace hotstrings when the replacement is produced. `n`nThis is useful when you want a hotstring to be kept unambiguous by still requiring an ending character, `nbut don't actually want the ending character to be shown on the screen. `nFor example, if :o:ar::aristocrat is a hotstring, typing ""ar"" followed by the spacebar will produce ""aristocrat"" with no trailing space, `nwhich allows you to make the word plural or possessive without having to press Backspace.
F_TI_OptionResetRecognizer								= Z: Resets the hotstring recognizer after each triggering of the hotstring. `n`nIn other words, the script will begin waiting for an entirely new hotstring, eliminating from consideration anything you previously typed. `nThis can prevent unwanted triggerings of hotstrings. 
F_TooltipMNTTSliderInfo									= You may slide the control by the following means: `n`n1) dragging the bar with the mouse; `n2) clicking inside the bar's track area with the mouse; `n3) turning the mouse wheel while the control has focus or `n4) pressing the following keys while the control has focus: ↑, →, ↓, ←, PgUp, PgDn, Home, and End. `n`nPgUp / PgDn step: 1; `nInterval:         5; `nRange:            1 ÷ 25 `n`nWhen required value is chosen just press Esc key to close this window or close it with mouse.
F_TI_CaseConforming										= By default (if option Case-Sensitive (C) or Not-Case-Sensitive (C1) aren't set) `ncase-conforming hotstrings produce their replacement text in all caps `nif you type the triggerstring in all caps. `n`nIf you type the first letter in caps, `nthe first letter of the replacement will also be capitalized (if it is a letter). `n`nIf you type the case in any other way, the replacement is sent exactly as defined.
F_TI_CaseSensitive										= C: Case sensitive: `n`nWhen you type a triggerstring, `nit must exactly match the case defined.
F_TI_NotCaseConforming									= C1: Do not conform to typed case. `n`nUse this option to make hotstrings case insensitive `nand prevent them from conforming to the case of the characters you actually type.
F_TI_EnterTriggerstring									= Enter text of triggerstring. `n`nTip1: If you want to change capitalization in abbreviation, use no triggerstring options. `nE.g. ascii → ASCII. `n`nTip2: If you want exchange triggerstring of abbreviation into full phrase, `nend your triggerstring with ""/"" and `napply Immediate Execute (*) triggerstring option.
F_TI_OptionDisable										= Disables the hotstring. `n`nIf ticked, this option is shown in red color. `nBe aware that triggerstring tooltips (if enabled) `nare displayed even for disabled (triggerstring, hotstring) definitions.
TI_SHOF												= Select function, which will be used to show up hotstring. `n`nAvailable options: `n`nSendInput (SI): SendInput is generally the preferred method because of its superior speed and reliability. `nUnder most conditions, SendInput is nearly instantaneous, even when sending long strings. `nSince SendInput is so fast, it is also more reliable because there is less opportunity for some other window to pop up unexpectedly `nand intercept the keystrokes. Reliability is further improved by the fact `nthat anything the user types during a SendInput is postponed until afterward. `n`nClipboard (CL): hotstring is copied from clipboard. `nIn case of long hotstrings this is the fastest method. The downside of this method is delay `nrequired for operating system to paste content into specific window. `nIn order to change value of this delay see ""Clipboard Delay (F7)"" option in menu. `n`nMenu and SendInput (MSI): One triggerstring can be used to enter up to 7 hotstrings which are desplayed in form of list (menu). `nFor entering of chosen hotstring again SendInput (SI) is used. `n`nMenu & Clipboard (MCL): One triggerstring can be used to enter up to 7 hotstrings which are desplayed in form of list (menu). `nFor entering of chosen hotstring Clipboard (CL) is used. `n`nSenRaw (R): All subsequent characters, including the special characters ^+!#{}, `nto be interpreted literally rather than translating {Enter} to Enter, ^c to Ctrl+C, etc. `n`nSendPlay (SP): SendPlay's biggest advantage is its ability to ""play back"" keystrokes and mouse clicks in a broader variety of games `nthan the other modes. `nFor example, a particular game may accept hotstrings only when they have the SendPlay option. `n`nSendEvent (SE): SendEvent sends keystrokes using the same method as the pre-1.0.43 Send command.
TI_EnterHotstring										= Enter hotstring corresponding to the triggerstring. `n`nTip: You can use special key names in curved brackets. E.g.: {left 5} will move caret by 5x characters to the left.`n{Backspace 3} or {BS 3} will remove 3 characters from the end of triggerstring. `n`nTo send an extra space or tab after a replacement, include the space or tab at the end of the replacement `nbut make the last character an accent/backtick (`). `nFor example: `n:*:btw::By the way ``n`nBy default (that is, if SendRaw isn't used), the characters ^+!#{} have a special meaning. `nTo send those keys on its own, enclose the name in curly braces. `nFor example: {+}48 600 000.
TI_AddComment											= You can add optional (not mandatory) comment to new (triggerstring, hotstring) definition. `n`nThe comment can be max. 64 characters long. `n`nTip: Put here link to Wikipedia definition or any other external resource containing reference to entered definition.
TI_SelectHotstringLib									= Select .csv file containing (triggerstring, hotstring) definitions. `nBy default those files are located in C:\Users\<UserName>\Documents folder.
TI_LibraryContent										= After pressing (F2) you can move up or down in the table by pressing ↑ or ↓ arrows. `n`nEach time you select any row, options of the selected definitions are automatically loaded to the left part of this window.
TI_Sandbox											= Sandbox is used as editing field where you can test `nany (triggerstring, hotstring) definition, e.g. for testing purposes. `nThis area can be switched on/off and moves when you rescale `nthe main application window.
F_HK_CallGUIInfo										= Remark: this hotkey is operating system wide, so before changing it be sure it's not in conflict with any other system wide hotkey.`n`nIt opens Graphical User Interface (GUI) of Hotstrings, even if window is minimized or invisible.
F_HK_GeneralInfo										= You can enter any hotkey as combination of Shift, Ctrl, Alt modifier and any other keyboard key. `nIf you wish to have hotkey where Win modifier key is applied, use the checkbox separately.
F_HK_ClipCopyInfo										= Remark: this hotkey is operating system wide, so before changing it be sure it's not in conflict with any other system wide hotkey. `n`nWhen Hotstrings window exists (it could be minimized) pressing this hotkey copies content of clipboard to ""Enter hotstring"" field. `nThanks to that you can prepare new definition much quicker.
F_HK_UndoInfo											= Remark: this hotkey is operating system wide, so before changing it be sure it's not in conflict with any other system wide hotkey.`n`n When pressed, it undo the very last hotstring. Please note that result of undo depends on cursor position.
F_HK_TildeModInfo										= When the hotkey fires, its key's native function will not be blocked (hidden from the system). 
T_SBackgroundColorInfo									= Select from drop down list predefined color (one of 16 HTML colors) `nor select Custom one and then provide RGB value in HEX format (e.g. FF0000 for red). `nThe selected color will be displayed as background for on-screen menu.
T_STypefaceColor										= Select from drop down list predefined color (one of 16 HTML colors) `nor select Custom one and then provide RGB value in HEX format (e.g. FF0000 for red). `nThe selected color will be displayed as font color for on-screen menu.
T_STypefaceFont										= Select from drop down list predefined font type. `nThe selected font type will be used in on screen menu.
T_STypefaceSize										= Select from drop down list predefined size of font. `nThe selected font size will be used in on screen menu.
T_StylPreview											= Press the ""Test styling"" button to get look & feel of selected styling settings below.
T_SoundEnable											= Sound can be emitted each time when event takes place. `nOne can specify sound frequency and duration.`n`nYou may slide the control by the following means: `n`n1) dragging the bar with the mouse; `n2) clicking inside the bar's track area with the mouse; `n3) turning the mouse wheel while the control has focus or `n4) pressing the following keys while the control has focus: ↑, →, ↓, ←, PgUp, PgDn, Home, and End. `n`nPgUp / PgDn step: 50 [ms]; `nInterval:         150 [ms]; `nRange:            50 ÷ 2 000 [ms]. `n`nTip: Recommended time is between 200 to 400 ms. `n`nPgUp / PgDn step: 50 [ms]; `nInterval:         150 [ms]; `nRange:            50 ÷ 2 000 [ms]. `n`nTip: Recommended time is between 200 to 400 ms.
T_TooltipEnable										= You can enable or disable the following tooltip: ""Hotstring was triggered! [Shortcut] to undo."" `nIf enabled, this tooltip is shown each time when even of displaying hotstring upon triggering it takes place. `nNext you can set accompanying features like timeout, position and even sound. 
T_TooltipPosition										= Specify where tooltip should be displayed by default.`n`nWarning: some applications do not accept caret position. `n`nThen automatically cursor position is followed.
T_TooltipTimeout										= The finite tooltip stays displayed on a screen till next event is triggered. `nIt's adviced to set finite tooltip. `n`nYou may slide the control by the following means: `n`n1) dragging the bar with the mouse; `n2) clicking inside the bar's track area with the mouse; `n3) turning the mouse wheel while the control has focus or `n4) pressing the following keys while the control has focus: ↑, →, ↓, ←, PgUp, PgDn, Home, and End. `n`nPgUp / PgDn step: 500 [ms]; `nInterval:         500 [ms]; `nRange:            1000 ÷ 10 000 [ms].
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
	return
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
				tick := true
			}
			else
			{
				val := A_LoopField
				tick := false
			}			
			TransA[key] := val
		}
	}
	return
}
; ------------------------------------------------------------------------------------------------------------------------------------
F_LoadFile(nameoffile)
{
	global ;assume-global mode
	local name := "", FlagLoadTriggerTips := false, key := "", value := "", v_TheWholeFile := "", v_TotalLines := 0
							,HS3GuiWinX   := 0, 	HS3GuiWinY 	:= 0, 		HS3GuiWinW 	:= 0, 		HS3GuiWinH 	:= 0, 	LoadFileGuiWinW := 0, 	LoadFileGuiWinH := 0
		,v_OutVarTemp := 0, 	v_OutVarTempX := 0, 	v_OutVarTempY 	:= 0, 		v_OutVarTempW 	:= 0, 		v_OutVarTempH 	:= 0
							,v_xNext 	    := 0, 	v_yNext 		:= 0, 		v_wNext 		:= 0, 		v_hNext 		:= 0
		,v_Progress := 0
		,IdLoadFile_T1 := 0, IdLoadFile_P1 := 0, IdLoadFile_T2 := 0, BegCom := false
	
	for key, value in ini_ShowTipsLib
		if ((key == nameoffile) and (value))
			FlagLoadTriggerTips := true
	
	FileRead, v_TheWholeFile, % HADL . "\" . nameoffile
	F_WhichGui()
	if (A_DefaultGui = "HS3" or A_DefaultGui = "HS4")
	{
		Switch A_DefaultGui
		{
			Case "HS3": WinGetPos, HS3GuiWinX, HS3GuiWinY, HS3GuiWinW, HS3GuiWinH, % "ahk_id" . HS3GuiHwnd
			Case "HS4": WinGetPos, HS3GuiWinX, HS3GuiWinY, HS3GuiWinW, HS3GuiWinH, % "ahk_id" . HS4GuiHwnd 
		}
		Loop, Parse, v_TheWholeFile, `n, `r	;counter of total lines in the file
			if (A_LoopField)
				v_TotalLines++
		
		Gui, LoadFile: New, 	+Border -Resize -MaximizeBox -MinimizeBox +HwndLoadFileGuiHwnd +Owner +OwnDialogs, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["Loading file"] . ":" . A_Space . nameoffile
		Gui, LoadFile: Margin,	% c_xmarg, % c_ymarg
		Gui,	LoadFile: Color,	% c_WindowColor, % c_ControlColor
		
		Gui, LoadFile: Add, Text,		x0 y0 HwndIdLoadFile_T1, % TransA["Loading of (triggerstring, hotstring) definitions from the library file"]
		Gui, LoadFile: Add, Progress, 	x0 y0 HwndIdLoadFile_P1 cBlue, 0
		Gui, LoadFile: Add, Text, 		x0 y0 HwndIdLoadFile_T2, % TransA["Loaded"] . A_Space . v_Progress . A_Space . TransA["of"] . A_Space . v_TotalLines . A_Space . TransA["(triggerstring, hotstring) definitions"]
		. A_Space . "(" . v_Progress . A_Space . "%" . ")"
		GuiControlGet, v_OutVarTemp, Pos, % IdLoadFile_T1
		v_xNext := c_xmarg
		v_yNext := c_ymarg
		GuiControl, Move, % IdLoadFile_T1, % "x" v_xNext . A_Space . "y" v_yNext
		;Gui, Import: Show, Center AutoSize
		v_yNext += HofText + c_ymarg
		GuiControl, Move, % IdLoadFile_T2, % "x" v_xNext . A_Space . "y" v_yNext
		GuiControlGet, v_OutVarTemp, Pos, % IdLoadFile_T2
		v_wNext := v_OutVarTempW
		v_hNext := HofText
		GuiControl, Move, % IdLoadFile_P1, % "x" v_xNext . A_Space . "y" v_yNext . A_Space . "w" v_wNext . A_Space . "h" . v_hNext
		v_yNext += HofText + c_ymarg
		GuiControl, Move, % IdLoadFile_T2, % "x" v_xNext . A_Space . "y" v_yNext
		;Gui, Import: Show, Center AutoSize
		Gui, LoadFile: Show, Hide
		
		DetectHiddenWindows, On
		WinGetPos, , , LoadFileGuiWinW, LoadFileGuiWinH, % "ahk_id" . LoadFileGuiHwnd
		DetectHiddenWindows, Off
		Gui, LoadFile: Show, % "x" . HS3GuiWinX + (HS3GuiWinW - LoadFileGuiWinW) / 2 . A_Space . "y" . HS3GuiWinY + (HS3GuiWinH - LoadFileGuiWinH) / 2 . A_Space . "AutoSize"
	}
	
	name := SubStr(nameoffile, 1, -4) ;filename without extension
	Loop, Parse, v_TheWholeFile, `n, `r%A_Space%%A_Tab%
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
		Loop, Parse, A_LoopField, ‖
		{
			Switch A_Index
			{
				Case 1:	a_TriggerOptions.Push(A_LoopField)
				Case 2:	
				a_Triggerstring.Push(A_LoopField)
				if (FlagLoadTriggerTips)
					a_Triggers.Push(A_LoopField) ; a_Triggers is used in main loop of application for generating tips
				Case 3:	a_OutputFunction.Push(A_LoopField)
				Case 4:	a_EnableDisable.Push(A_LoopField)
				Case 5:	a_Hotstring.Push(A_LoopField)
				Case 6:	a_Comment.Push(A_LoopField)
			}
		}
		a_Library.Push(name) ; function Search
		++v_TotalHotstringCnt
		if (A_DefaultGui = "LoadFile")
		{
			v_Progress := Round((A_Index / v_TotalLines) * 100)
			GuiControl,, % IdLoadFile_T2, % TransA["Loaded"] . A_Space . A_Index . A_Space . TransA["of"] . A_Space . v_TotalLines . A_Space . TransA["(triggerstring, hotstring) definitions"]
						. A_Space . "(" . v_Progress . A_Space . "%" . ")"
			GuiControl,, % IdLoadFile_P1, % v_Progress
		}
		
	}	
	GuiControl, , % IdText12,  % v_TotalHotstringCnt ; Text: Puts new contents into the control.
	GuiControl, , % IdText12b, % v_TotalHotstringCnt ; Text: Puts new contents into the control.
	Gui, LoadFile: Destroy
	return
}

; ------------------------------------------------------------------------------------------------------------------------------------

F_GuiHS4_CreateObject()
{
	global ;assume-global mode
	local x0 := 0, y0 := 0
	
	v_TotalHotstringCnt 		:= 0000
	v_LibHotstringCnt			:= 0000 ;no of (triggerstring, hotstring) definitions in single library
	
;1. Definition of HS4 GUI.
	Gui, 	HS4: New, 	-Resize +HwndHS4GuiHwnd +OwnDialogs -MaximizeBox, % A_ScriptName
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
	Gui,		HS4: Add,		Radio,		x0 y0 HwndIdRadioCaseCCb AltSubmit vv_RadioCaseGroup Checked gF_RadioCaseCol,	% TransA["Case-Conforming"]
	Gui, 	HS4: Font, 	% "s" . c_FontSize + 2
	Gui,		HS4: Add,		Text,		x0 y0 HwndIdTextInfo3b,									ⓘ
	GuiControl +g, % IdTextInfo3b, % F_TI_CaseConforming
	
	Gui, 	HS4: Font, 	% "s" . c_FontSize
	Gui, 	HS4: Add,		CheckBox, 	x0 y0 HwndIdCheckBox3b gF_Checkbox vv_OptionNoBackspace,		% TransA["No Backspace (B0)"]
	Gui, 	HS4: Font, 	% "s" . c_FontSize + 2
	Gui,		HS4: Add,		Text,		x0 y0 HwndIdTextInfo4b,									ⓘ
	GuiControl +g, % IdTextInfo4b, % F_TI_NoBackSpace
	
	Gui, 	HS4: Font, 	% "s" . c_FontSize
	Gui,		HS4: Add,		Radio,		x0 y0 HWndIdRadioCaseCSb AltSubmit gF_RadioCaseCol,			% TransA["Case Sensitive (C)"]
	Gui, 	HS4: Font, 	% "s" . c_FontSize + 2
	Gui,		HS4: Add,		Text,		x0 y0 HwndIdTextInfo5b,									ⓘ
	GuiControl +g, % IdTextInfo5b, % F_TI_CaseSensitive
	
	Gui, 	HS4: Font, 	% "s" . c_FontSize
	Gui, 	HS4: Add,		CheckBox, 	x0 y0 HwndIdCheckBox4b gF_Checkbox vv_OptionInsideWord, 		% TransA["Inside Word (?)"]
	Gui, 	HS4: Font, 	% "s" . c_FontSize + 2
	Gui,		HS4: Add,		Text,		x0 y0 HwndIdTextInfo6b,									ⓘ
	GuiControl +g, % IdTextInfo6b, % F_TI_InsideWord
	
	Gui, 	HS4: Font, 	% "s" . c_FontSize
	Gui,		HS4: Add,		Radio,		x0 y0 HwndIdRadioCaseC1b AltSubmit gF_RadioCaseCol,			% TransA["Not Case-Conforming (C1)"]
	Gui, 	HS4: Font, 	% "s" . c_FontSize + 2
	Gui,		HS4: Add,		Text,		x0 y0 HwndIdTextInfo7b,									ⓘ
	GuiControl +g, % IdTextInfo7b, % F_TI_NotCaseConforming
	
	Gui, 	HS4: Font, 	% "s" . c_FontSize
	Gui, 	HS4: Add,		CheckBox, 	x0 y0 HwndIdCheckBox5b gF_Checkbox vv_OptionNoEndChar, 		% TransA["No EndChar (O)"]
	Gui, 	HS4: Font, 	% "s" . c_FontSize + 2
	Gui,		HS4: Add,		Text,		x0 y0 HwndIdTextInfo8b,									ⓘ
	GuiControl +g, % IdTextInfo8b, % F_TI_NotCaseConforming
	
	Gui, 	HS4: Font, 	% "s" . c_FontSize
	Gui,		HS4: Add,		CheckBox,		x0 y0 HwndIdCheckBox8b gF_Checkbox vv_OptionReset,			% TransA["Reset Recognizer (Z)"]
	Gui, 	HS4: Font, 	% "s" . c_FontSize + 2
	Gui,		HS4: Add,		Text,		x0 y0 HwndIdTextInfo10b,									ⓘ
	GuiControl +g, % IdTextInfo10b, % F_TI_OptionResetRecognizer
	
	Gui, 	HS4: Font, 	% "s" . c_FontSize
	Gui, 	HS4: Add, 	CheckBox, 	x0 y0 HwndIdCheckBox6b gF_Checkbox vv_OptionDisable, 			% TransA["Disable"]
	Gui, 	HS4: Font, 	% "s" . c_FontSize + 2
	Gui,		HS4: Add,		Text,		x0 y0 HwndIdTextInfo11b,									ⓘ
	GuiControl +g, % IdTextInfo11b, % F_TI_OptionDisable
	
	Gui,		HS4: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, 	HS4: Add, 	Text, 		x0 y0 HwndIdText3b,						 				% TransA["Select hotstring output function"]
	Gui, 	HS4: Font, 	% "s" . c_FontSize + 2
	Gui,		HS4: Add,		Text,		x0 y0 HwndIdTextInfo12b,									ⓘ
	GuiControl +g, % IdTextInfo12b, % TI_SHOF
	Gui,		HS4: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, 			% c_FontType
	
	Gui, 	HS4: Add, 	DropDownList, 	x0 y0 HwndIdDDL1b vv_SelectFunction gF_SelectFunction, 		SendInput (SI)||Clipboard (CL)|Menu & SendInput (MSI)|Menu & Clipboard (MCL)|SendRaw (SR)|SendPlay (SP)|SendEvent (SE)
	
	Gui,		HS4: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, 	HS4: Add, 	Text, 		x0 y0 HwndIdText4b,					 					% TransA["Enter hotstring"]
	Gui, 	HS4: Font, 	% "s" . c_FontSize + 2
	Gui,		HS4: Add,		Text,		x0 y0 HwndIdTextInfo13b,									ⓘ
	GuiControl +g, % IdTextInfo13b, % TI_EnterHotstring
	Gui,		HS4: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, 			% c_FontType
	
	Gui, 	HS4: Add, 	Edit, 		x0 y0 HwndIdEdit2b vv_EnterHotstring
	Gui, 	HS4: Add, 	Edit, 		x0 y0 HwndIdEdit3b vv_EnterHotstring1  Disabled
	Gui, 	HS4: Add, 	Edit, 		x0 y0 HwndIdEdit4b vv_EnterHotstring2  Disabled
	Gui, 	HS4: Add, 	Edit, 		x0 y0 HwndIdEdit5b vv_EnterHotstring3  Disabled
	Gui, 	HS4: Add, 	Edit, 		x0 y0 HwndIdEdit6b vv_EnterHotstring4  Disabled
	Gui, 	HS4: Add, 	Edit, 		x0 y0 HwndIdEdit7b vv_EnterHotstring5  Disabled
	Gui, 	HS4: Add, 	Edit, 		x0 y0 HwndIdEdit8b vv_EnterHotstring6  Disabled
	
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
	
	Gui, 	HS4: Add, 	Button, 		x0 y0 HwndIdButton1b gF_GuiAddLibrary, 						% TransA["Add library"]
	Gui,		HS4: Add,		DropDownList,	x0 y0 HwndIdDDL2b vv_SelectHotstringLibrary gF_SelectLibrary Sort
	
	Gui, 	HS4: Add,		Button, 		x0 y0 HwndIdButton2b gF_AddHotstring,						% TransA["Add hotstring (F9)"]
	Gui, 	HS4:Add, 		Button, 		x0 y0 HwndIdButton3b gF_Clear,							% TransA["Clear (F5)"]
	Gui, 	HS4:Add, 		Button, 		x0 y0 HwndIdButton4b gF_DeleteHotstring vv_DeleteHotstring Disabled, 	% TransA["Delete hotstring (F8)"]
	
	Gui,		HS4: Add,		Button,		x0 y0 HwndIdButton5b gF_ToggleRightColumn,					⯈`nF4
	Gui,		HS4: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, 	HS4: Add, 	Text, 		x0 y0 HwndIdText10b,			 						% TransA["Sandbox (F6)"]
	Gui, 	HS4: Font, 	% "s" . c_FontSize + 2	
	Gui,		HS4: Add,		Text,		x0 y0 HwndIdTextInfo17b,									ⓘ
	GuiControl +g, % IdTextInfo17b, % TI_Sandbox
	Gui,		HS4: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, 			% c_FontType
	
	Gui, 	HS4: Add, 	Edit, 		x0 y0 HwndIdEdit10b vv_Sandbox r3 							; r3 = 3x rows of text
	
	Gui,		HS4: Add,		Text,		x0 y0 HwndIdText11b, % TransA["This library:"] . A_Space
	Gui,		HS4: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, Consolas ;Consolas type is monospace
	Gui, 	HS4: Add, 	Text, 		x0 y0 HwndIdText13b,  % v_LibHotstringCnt ;value of Hotstrings counter
	Gui,		HS4: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, 			% c_FontType
	Gui, 	HS4: Add, 	Text, 		x0 y0 HwndIdText2b, % TransA["Total:"] . A_Space
	Gui,		HS4: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, Consolas ;Consolas type is monospace
	Gui, 	HS4: Add, 	Text, 		x0 y0 HwndIdText12b, % v_TotalHotstringCnt
	Gui,		HS4: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, 			% c_FontType
}
; ------------------------------------------------------------------------------------------------------------------------------------
F_GuiMain_CreateObject()
{
	global ;assume-global mode
	local x0 := 0, y0 := 0
	;v_OptionImmediateExecute := 0, v_OptionCaseSensitive := 0, v_OptionNoBackspace := 0, v_OptionInsideWord := 0, v_OptionNoEndChar := 0, v_OptionDisable := 0
	
	v_TotalHotstringCnt 		:= 0000
	v_LibHotstringCnt			:= 0000 ;no of (triggerstring, hotstring) definitions in single library
	HS3_GuiWidth  				:= 0
	HS3_GuiHeight 				:= 0
	
;1. Definition of HS3 GUI.
;-DPIScale doesn't work in Microsoft Windows 10
;+Border doesn't work in Microsoft Windows 10
	;Gui, 		HS3: New, 		+Resize +HwndHS3GuiHwnd +OwnDialogs -MaximizeBox, 						% A_ScriptName
	Gui, 		HS3: New, 		+Resize +HwndHS3GuiHwnd +OwnDialogs,			 						% A_ScriptName
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
	Gui, 		HS3: Add, 		Edit, 		x0 y0 HwndIdEdit1 vv_TriggerString 
	
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
	Gui, 		HS3: Font, 		% "s" . c_FontSize + 2
	Gui,			HS3: Add,			Text,		x0 y0 HwndIdTextInfo3,									ⓘ
	Gui,			HS3: Add,			Text,		x0 y0 HwndIdTextInfo5,									ⓘ
	Gui,			HS3: Add,			Text,		x0 y0 HwndIdTextInfo7,									ⓘ
	F_TI_CaseConforming 	:= func("F_ShowLongTooltip").bind(TransA["F_TI_CaseConforming"])
	F_TI_CaseSensitive		:= func("F_ShowLongTooltip").bind(TransA["F_TI_CaseSensitive"])
	F_TI_NotCaseConforming	:= func("F_ShowLongTooltip").bind(TransA["F_TI_NotCaseConforming"])
	GuiControl +g, % IdTextInfo3, % F_TI_CaseConforming
	GuiControl +g, % IdTextInfo5, % F_TI_CaseSensitive
	GuiControl +g, % IdTextInfo7, % F_TI_NotCaseConforming
	
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
	
	Gui, 		HS3: Font, 		% "s" . c_FontSize
	Gui, 		HS3: Add, 		CheckBox, 	x0 y0 HwndIdCheckBox6 gF_Checkbox vv_OptionDisable, 			% TransA["Disable"]
	Gui, 		HS3: Font, 		% "s" . c_FontSize + 2
	Gui,			HS3: Add,			Text,		x0 y0 HwndIdTextInfo11,									ⓘ
	F_TI_OptionDisable		:= func("F_ShowLongTooltip").bind(TransA["F_TI_OptionDisable"])
	GuiControl +g, % IdTextInfo11, % F_TI_OptionDisable
	
	Gui,			HS3: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, 		HS3: Add, 		Text, 		x0 y0 HwndIdText3,						 				% TransA["Select hotstring output function"]
	Gui, 		HS3: Font, 		% "s" . c_FontSize + 2
	Gui,			HS3: Add,			Text,		x0 y0 HwndIdTextInfo12,									ⓘ
	TI_SHOF				:= func("F_ShowLongTooltip").bind(TransA["TI_SHOF"])
	GuiControl +g, % IdTextInfo12, % TI_SHOF
	Gui,			HS3: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, 			% c_FontType
	
	Gui, 		HS3: Add, 		DropDownList, 	x0 y0 HwndIdDDL1 vv_SelectFunction gF_SelectFunction, 			SendInput (SI)||Clipboard (CL)|Menu & SendInput (MSI)|Menu & Clipboard (MCL)|SendRaw (SR)|SendPlay (SP)|SendEvent (SE)
	
	Gui,			HS3: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, 		HS3: Add, 		Text, 		x0 y0 HwndIdText4,					 					% TransA["Enter hotstring"]
	Gui, 		HS3: Font, 		% "s" . c_FontSize + 2	
	Gui,			HS3: Add,			Text,		x0 y0 HwndIdTextInfo13,									ⓘ
	TI_EnterHotstring		:= func("F_ShowLongTooltip").bind(TransA["TI_EnterHotstring"])
	GuiControl +g, % IdTextInfo13, % TI_EnterHotstring
	Gui,			HS3: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, 			% c_FontType
	
	Gui, 		HS3: Add, 		Edit, 		x0 y0 HwndIdEdit2 vv_EnterHotstring
	Gui, 		HS3: Add, 		Edit, 		x0 y0 HwndIdEdit3 vv_EnterHotstring1  Disabled
	Gui, 		HS3: Add, 		Edit, 		x0 y0 HwndIdEdit4 vv_EnterHotstring2  Disabled
	Gui, 		HS3: Add, 		Edit, 		x0 y0 HwndIdEdit5 vv_EnterHotstring3  Disabled
	Gui, 		HS3: Add, 		Edit, 		x0 y0 HwndIdEdit6 vv_EnterHotstring4  Disabled
	Gui, 		HS3: Add, 		Edit, 		x0 y0 HwndIdEdit7 vv_EnterHotstring5  Disabled
	Gui, 		HS3: Add, 		Edit, 		x0 y0 HwndIdEdit8 vv_EnterHotstring6  Disabled
	
	Gui,			HS3: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, 		HS3: Add, 		Text, 		x0 y0 HwndIdText5,				 						% TransA["Add comment (optional)"]
	Gui, 		HS3: Font, 		% "s" . c_FontSize + 2	
	Gui,			HS3: Add,			Text,		x0 y0 HwndIdTextInfo14,									ⓘ
	TI_AddComment			:= func("F_ShowLongTooltip").bind(TransA["TI_AddComment"])
	GuiControl +g, % IdTextInfo14, % TI_AddComment
	
	Gui,			HS3: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, 			% c_FontType
	
	Gui, 		HS3: Add, 		Edit, 		x0 y0 HwndIdEdit9 vv_Comment Limit64 
	
	Gui,			HS3: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, 		HS3: Add, 		Text, 		x0 y0 HwndIdText6,						 				% TransA["Select hotstring library"]
	Gui, 		HS3: Font, 		% "s" . c_FontSize + 2	
	Gui,			HS3: Add,			Text,		x0 y0 HwndIdTextInfo15,									ⓘ
	TI_SelectHotstringLib	:= func("F_ShowLongTooltip").bind(TransA["TI_SelectHotstringLib"])
	GuiControl +g, % IdTextInfo15, % TI_SelectHotstringLib
	
	Gui,			HS3: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, 			% c_FontType
	
	Gui, 		HS3: Add, 		Button, 		x0 y0 HwndIdButton1 gF_GuiAddLibrary, 						% TransA["Add library"]
	Gui,			HS3: Add,			DropDownList,	x0 y0 HwndIdDDL2 vv_SelectHotstringLibrary gF_SelectLibrary Sort
	
	Gui, 		HS3: Add, 		Button, 		x0 y0 HwndIdButton2 gF_AddHotstring,						% TransA["Add hotstring (F9)"]
	Gui, 		HS3: Add, 		Button, 		x0 y0 HwndIdButton3 gF_Clear,								% TransA["Clear (F5)"]
	Gui, 		HS3: Add, 		Button, 		x0 y0 HwndIdButton4 gF_DeleteHotstring vv_DeleteHotstring Disabled, 	% TransA["Delete hotstring (F8)"]
	Gui,			HS3: Add,			Button,		x0 y0 HwndIdButton5 gF_ToggleRightColumn,					⯇`nF4
	
	Gui,			HS3: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, 		HS3: Add, 		Text, 		x0 y0 HwndIdText7,		 								% TransA["Library content (F2)"]
	Gui, 		HS3: Font, 		% "s" . c_FontSize + 2	
	Gui,			HS3: Add,			Text,		x0 y0 HwndIdTextInfo16,									ⓘ
	TI_LibraryContent		:= func("F_ShowLongTooltip").bind(TransA["TI_LibraryContent"])
	GuiControl +g, % IdTextInfo16, % TI_LibraryContent
	
	Gui,			HS3:Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, % c_FontType
	
	Gui,			HS3: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, 			% c_FontType
	Gui, 		HS3: Add, 		Text, 		x0 y0 HwndIdText2, % TransA["Total:"] . A_Space 
	Gui,			HS3: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, 			Consolas ;Consolas type is monospace
	Gui, 		HS3: Add, 		Text, 		x0 y0 HwndIdText12, % v_TotalHotstringCnt
	Gui,			HS3: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, 			% c_FontType
	
	Gui,			HS3: Add, 		Text, 		x0 y0 HwndIdText9, 										% TransA["Triggerstring|Trigg Opt|Out Fun|En/Dis|Hotstring|Comment"]
	Gui, 		HS3: Add, 		ListView, 	x0 y0 HwndIdListView1 LV0x1 vv_LibraryContent AltSubmit gF_HSLV -Multi, % TransA["Triggerstring|Trigg Opt|Out Fun|En/Dis|Hotstring|Comment"]
	
	Gui,			HS3: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, 		HS3: Add, 		Text, 		x0 y0 HwndIdText10,			 							% TransA["Sandbox (F6)"]
	Gui, 		HS3: Font, 		% "s" . c_FontSize + 2	
	Gui,			HS3: Add,			Text,		x0 y0 HwndIdTextInfo17,									ⓘ
	TI_Sandbox		:= func("F_ShowLongTooltip").bind(TransA["TI_Sandbox"])
	GuiControl +g, % IdTextInfo17, % TI_Sandbox
	
	Gui,			HS3:Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, % c_FontType
	
	Gui, 		HS3:Add, 		Edit, 		x0 y0 HwndIdEdit10 vv_Sandbox r3 						; r3 = 3x rows of text
	Gui,			HS3:Add,		Text,		x0 y0 HwndIdText11, % TransA["This library:"] . A_Space
	Gui,			HS3:Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, Consolas ;Consolas type is monospace
	Gui, 		HS3:Add, 		Text, 		x0 y0 HwndIdText13,  %  v_LibHotstringCnt ;value of Hotstrings counter in the current library
	
	Gui,			HS3:Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, % c_FontType
}
	
; ------------------------------------------------------------------------------------------------------------------------------------
F_GuiMain_DefineConstants()
{
;Within a function, to create a set of variables that is local instead of global, declare OutputVar as a local variable prior to using command GuiControlGet, Pos. However, it is often also necessary to declare each variable in the set, due to a common source of confusion.	
	global ;assume-global mode
	local v_OutVarTemp := 0, v_OutVarTempX := 0, v_OutVarTempY := 0, v_OutVarTempW := 0, v_OutVarTempH := 0
	
;3. Determine weight / height of main types of text objects
	GuiControlGet, v_OutVarTemp, Pos, % IdText1
	HofText			:= v_OutVarTempH
	GuiControlGet, v_OutVarTemp, Pos, % IdEdit1
	HofEdit			:= v_OutVarTempH
	GuiControlGet, v_OutVarTemp, Pos, % IdButton1
	HofButton			:= v_OutVarTempH
	GuiControlGet, v_OutVarTemp, Pos, % IdListView1
	HofListView		:= v_OutVarTempH
	GuiControlGet, v_OutVarTemp, Pos, % IdCheckBox1
	HofCheckBox		:= v_OutVarTempH
	GuiControlGet, v_OutVarTemp, Pos, % IdDDL1
	HofDropDownList 	:= v_OutVarTempH
	GuiControlGet, v_OutVarTemp, Pos, % IdEdit10
	c_HofSandbox		:= v_OutVarTempH
	GuiControlGet, v_OutVarTemp, Pos, % IdButton5
	c_WofMiddleButton   := v_OutVarTempW
}
; ------------------------------------------------------------------------------------------------------------------------------------
F_RadioCaseCol()
{
	global ;assume-global mode
	local vOutputVar := 0
	
	Gui, HS3: Submit, NoHide	;tu jestem; pobrać aktywne gui
	Switch v_RadioCaseGroup
	{
		Case 1:
			Gui, HS3: Font, % "s" . c_FontSize . A_Space . "c" . c_FontColor . A_Space . "Norm", % c_FontType
			Gui, HS4: Font, % "s" . c_FontSize . A_Space . "c" . c_FontColor . A_Space . "Norm", % c_FontType
			GuiControl, HS3: Font, % TransA["Case Sensitive (C)"]
			GuiControl, HS4: Font, % TransA["Case Sensitive (C)"]
			GuiControl, HS3: Font, % TransA["Case-Conforming"]
			GuiControl, HS4: Font, % TransA["Case-Conforming"]
			GuiControl, HS3: Font, % TransA["Not Case-Conforming (C1)"]
			GuiControl, HS4: Font, % TransA["Not Case-Conforming (C1)"]
			GuiControl, HS3:, % TransA["Case-Conforming"], 1
			GuiControl, HS4:, % TransA["Case-Conforming"], 1
		Case 2:
			Gui, HS3: Font, % "s" . c_FontSize . A_Space . "cGreen Norm", % c_FontType
			Gui, HS4: Font, % "s" . c_FontSize . A_Space . "cGreen Norm", % c_FontType
			GuiControl, HS3: Font, % TransA["Case Sensitive (C)"]
			GuiControl, HS4: Font, % TransA["Case Sensitive (C)"]
			GuiControl, HS3:, % TransA["Case Sensitive (C)"], 1
			GuiControl, HS4:, % TransA["Case Sensitive (C)"], 1
		Case 3: 
			Gui, HS3: Font, % "s" . c_FontSize . A_Space . "cGreen Norm", % c_FontType
			Gui, HS4: Font, % "s" . c_FontSize . A_Space . "cGreen Norm", % c_FontType
			GuiControl, HS3: Font, % TransA["Not Case-Conforming (C1)"]
			GuiControl, HS4: Font, % TransA["Not Case-Conforming (C1)"]
			GuiControl, HS3:, % TransA["Not Case-Conforming (C1)"], 1
			GuiControl, HS4:, % TransA["Not Case-Conforming (C1)"], 1
	}
	return
}
; ------------------------------------------------------------------------------------------------------------------------------------

F_GuiHS4_Redraw()
{
	global ;assume-global mode
	local v_OutVarTemp := 0, 	v_OutVarTempX := 0, 	v_OutVarTempY := 0, 	v_OutVarTempW := 0, 	v_OutVarTempH := 0
		,v_xNext := 0, v_yNext := 0, v_wNext := 0
	
	if (ini_Sandbox)
	{
		v_xNext := c_xmarg
		v_yNext := LeftColumnH + c_ymarg
		GuiControl, Move, % IdText10b, % "x" . v_xNext . "y" . v_yNext
		GuiControlGet, v_OutVarTemp, Pos, % IdText10b
		v_xNext := v_OutVarTempX + v_OutVarTempW + c_xmarg
		GuiControl, Move, % IdTextInfo17b, % "x" . v_xNext . "y" . v_yNext
		v_xNext := c_xmarg
		v_yNext := LeftColumnH + c_ymarg + HofText
		v_wNext := LeftColumnW - 2 * c_ymarg
		GuiControl, Move, % IdEdit10b, % "x" . v_xNext . "y" . v_yNext . "w" . v_wNext
		GuiControl, Show, % IdText10b
		GuiControl, Show, % IdTextInfo17b
		GuiControl, Show, % IdEdit10b
		;5.2. Position of counters
		GuiControlGet, v_OutVarTemp, Pos, % IdEdit10b
		v_xNext := c_xmarg
		v_yNext := v_OutVarTempY + v_OutVarTempH + c_ymarg 
		GuiControl, Move, % IdText11b,  % "x" . v_xNext . "y" . v_yNext ;text: Hotstrings
		GuiControlGet, v_OutVarTemp, Pos, % IdText11b
		v_xNext := v_OutVarTempX + v_OutVarTempW
		GuiControl, Move, % IdText13b,  % "x" . v_xNext . "y" . v_yNext ;text: value of Hotstrings
		GuiControlGet, v_OutVarTemp, Pos, % IdText13b
		v_xNext := v_OutVarTempX + v_OutVarTempW + c_xmarg
		GuiControl, Move, % IdText2b, % "x" . v_xNext . "y" . v_yNext ;where to place text Total
		GuiControlGet, v_OutVarTemp, Pos, % IdText2
		v_xNext += v_OutVarTempW
		GuiControl, Move, % IdText12b, % "x" . v_xNext . "y" . v_yNext ;Where to place value of total counter
	}
	else
	{
		GuiControl, Hide, % IdText10b ;sandobx text
		GuiControl, Hide, % IdTextInfo17b
		GuiControl, Hide, % IdEdit10b ;sandbox edit field
		;5.3. Position of counters
		v_xNext := c_xmarg
		v_yNext := LeftColumnH
		GuiControl, Move, % IdText11b,  % "x" . v_xNext . "y" . v_yNext ;text: "This library""
		GuiControlGet, v_OutVarTemp, Pos, % IdText11b
		v_xNext := v_OutVarTempX + v_OutVarTempW
		GuiControl, Move, % IdText13b,  % "x" . v_xNext . "y" . v_yNext ;text: value displayed after "This library"
		GuiControlGet, v_OutVarTemp, Pos, % IdText13b
		v_xNext := v_OutVarTempX + v_OutVarTempW + c_xmarg
		GuiControl, Move, % IdText2b, % "x" . v_xNext . "y" . v_yNext ;where to place text "Total"
		GuiControlGet, v_OutVarTemp, Pos, % IdText2
		v_xNext += v_OutVarTempW
		GuiControl, Move, % IdText12b, % "x" . v_xNext . "y" . v_yNext ;Where to place value after "Total"
	}
	
	;5.2. Button between left and right column
	v_xNext := LeftColumnW
	v_yNext := c_ymarg
	GuiControlGet, v_OutVarTemp, Pos, % IdText2b	; Text "Total:"
	v_hNext := v_OutVarTempY + v_OutVarTempH - c_ymarg
	GuiControl, Move, % IdButton5b, % "x" . v_xNext ". y" . v_yNext . "h" . v_hNext
}
	
; ------------------------------------------------------------------------------------------------------------------------------------
	
F_GuiHS4_DetermineConstraints()
{
	;Within a function, to create a set of variables that is local instead of global, declare OutputVar as a local variable prior to using command GuiControlGet, Pos. However, it is often also necessary to declare each variable in the set, due to a common source of confusion.
	global ;assume-global mode
	local v_OutVarTemp := 0, 	v_OutVarTempX := 0, 	v_OutVarTempY := 0, 	v_OutVarTempW := 0, 	v_OutVarTempH := 0
		,v_OutVarTemp1 := 0, 	v_OutVarTemp1X := 0, 	v_OutVarTemp1Y := 0, 	v_OutVarTemp1W := 0, 	v_OutVarTemp1H := 0
		,v_OutVarTemp2 := 0, 	v_OutVarTemp2X := 0, 	v_OutVarTemp2Y := 0, 	v_OutVarTemp2W := 0, 	v_OutVarTemp2H := 0
		,v_OutVarTemp3 := 0, 	v_OutVarTemp3X := 0, 	v_OutVarTemp3Y := 0, 	v_OutVarTemp3W := 0, 	v_OutVarTemp3H := 0
		,v_OutVarTemp4 := 0, 	v_OutVarTemp4X := 0, 	v_OutVarTemp4Y := 0, 	v_OutVarTemp4W := 0, 	v_OutVarTemp4H := 0
		,v_OutVarTemp5 := 0, 	v_OutVarTemp5X := 0, 	v_OutVarTemp5Y := 0, 	v_OutVarTemp5W := 0, 	v_OutVarTemp5H := 0
		,v_OutVarTemp6 := 0, 	v_OutVarTemp6X := 0, 	v_OutVarTemp6Y := 0, 	v_OutVarTemp6W := 0, 	v_OutVarTemp6H := 0
							,v_xNext := 0, 		v_yNext := 0, 			v_wNext := 0, 			v_hNext := 0
		,WleftMiniColumn := 0,	WrightMiniColumn := 0,	SpaceBetweenColumns := 0
		,W_InfoSign := 0, 		W_C1 := 0,			W_C2 := 0,			GPB := 0
		,LeftColumnW := 0
	
;4. Determine constraints, according to mock-up
;4.1. Determine left columnt width
	GuiControlGet, v_OutVarTemp1, Pos, % IdTextInfo1b
	W_InfoSign := v_OutVarTemp1W
	
	GuiControlGet, v_OutVarTemp1, Pos, % IdCheckBox1b
	GuiControlGet, v_OutVarTemp2, Pos, % IdCheckBox3b
	GuiControlGet, v_OutVarTemp3, Pos, % IdCheckBox4b
	GuiControlGet, v_OutVarTemp4, Pos, % IdCheckBox5b
	GuiControlGet, v_OutVarTemp6, Pos, % IdCheckBox8b
	W_C1 := Max(v_OutVarTemp1W, v_OutVarTemp2W, v_OutVarTemp3W, v_OutVarTemp4W, v_OutVarTemp6W) + c_xmarg + W_InfoSign
	
	GuiControlGet, v_OutVarTemp1, Pos, % IdRadioCaseCCb
	GuiControlGet, v_OutVarTemp2, Pos, % IdRadioCaseCSb
	GuiControlGet, v_OutVarTemp3, Pos, % IdRadioCaseC1b
	GuiControlGet, v_OutVarTemp4, Pos, % IdCheckBox6b
	W_C2 := Max(v_OutVarTemp1W, v_OutVarTemp2W, v_OutVarTemp3W, v_OutVarTemp4W) + c_xmarg + W_InfoSign
	
	LeftColumnW := 2 * c_xmarg + W_C1 + c_xmarg + W_C2 + c_xmarg
	
;5. Move text objects to correct position
;5.1. Left column
;5.1.1. Enter triggerstring
	v_xNext := c_xmarg
	v_yNext := c_ymarg
	GuiControl, Move, % IdText1b, % "x" . v_xNext . "y" . v_yNext
	
	GuiControlGet, v_OutVarTemp1, Pos, % IdText1b
	v_xNext += v_OutVarTemp1W + c_xmarg
	GuiControl, Move, % IdTextInfo1b, % "x" . v_xNext . "y" . v_yNext
 	v_xNext += W_InfoSign + c_xmarg
	v_wNext := LeftColumnW - v_xNext - c_xmarg
	GuiControl, Move, % IdEdit1b, % "x" . v_xNext . "y" . v_yNext . "w" . v_wNext
	
;5.1.2. Select trigger options
	v_xNext := c_xmarg 
	v_yNext := c_ymarg + HofEdit + HofText 
	v_wNext := c_xmarg + W_C1 + c_xmarg  + W_C2
	v_hNext := HofText + c_ymarg + HofCheckBox * 5 + c_ymarg
	GuiControl, Move, % IdGroupBox1b, % "x" . v_xNext . "y" . v_yNext . "w" . v_wNext . "h" . v_hNext
;5.1.2.1. Raw 1: Immediate execute (*) + Case-Conforming
	v_xNext += c_xmarg
	v_yNext += HofText + c_ymarg
	GuiControl, Move, % IdCheckBox1b, % "x" . v_xNext . "y" . v_yNext 
	GuiControlGet, v_OutVarTemp1, Pos, % IdCheckBox1
	v_xNext += v_OutVarTemp1W
	GuiControl, Move, % IdTextInfo2b, % "x" . v_xNext . "y" . v_yNext 
	v_xNext := c_xmarg * 2 + W_C1 + c_xmarg
	GuiControl, Move, % IdRadioCaseCCb, % "x" . v_xNext . "y" . v_yNext
	GuiControlGet, v_OutVarTemp1, Pos, % IdRadioCaseCCb
	v_xNext += v_OutVarTemp1W
	GuiControl, Move, % IdTextInfo3b, % "x" . v_xNext . "y" . v_yNext
;5.1.2.2. Raw 2: No Backspace (B0)	+ Case Sensitive (C)
	v_xNext := c_xmarg * 2
	v_yNext += HofCheckBox
	GuiControl, Move, % IdCheckBox3b, % "x" . v_xNext . "y" . v_yNext
	GuiControlGet, v_OutVarTemp1, Pos, % IdCheckBox3b
	v_xNext += v_OutVarTemp1W
	GuiControl, Move, % IdTextInfo4b, % "x" . v_xNext . "y" . v_yNext 
	v_xNext := c_xmarg * 2 + W_C1 + c_xmarg
	GuiControl, Move, % IdRadioCaseCSb, % "x" . v_xNext . "y" . v_yNext
	GuiControlGet, v_OutVarTemp1, Pos, % IdRadioCaseCSb
	v_xNext += v_OutVarTemp1W
	GuiControl, Move, % IdTextInfo5b, % "x" . v_xNext . "y" . v_yNext
;5.1.2.3. Raw 3: Inside Word (?) + Not Case-Conforming (C1)
	v_xNext := c_xmarg * 2
	v_yNext += HofCheckBox
	GuiControl, Move, % IdCheckBox4b, % "x" . v_xNext . "y" . v_yNext	
	GuiControlGet, v_OutVarTemp1, Pos, % IdCheckBox4b
	v_xNext += v_OutVarTemp1W
	GuiControl, Move, % IdTextInfo6b, % "x" . v_xNext . "y" . v_yNext 
	v_xNext := c_xmarg * 2 + W_C1 + c_xmarg
	GuiControl, Move, % IdRadioCaseC1b, % "x" . v_xNext . "y" . v_yNext
	GuiControlGet, v_OutVarTemp1, Pos, % IdRadioCaseC1b
	v_xNext += v_OutVarTemp1W
	GuiControl, Move, % IdTextInfo7b, % "x" . v_xNext . "y" . v_yNext
;5.1.2.4. Raw 4: No EndChar (O)
	v_xNext := c_xmarg * 2
	v_yNext += HofCheckBox
	GuiControl, Move, % IdCheckBox5b, % "x" . v_xNext . "y" . v_yNext	
	GuiControlGet, v_OutVarTemp1, Pos, % IdCheckBox5
	v_xNext += v_OutVarTemp1W
	GuiControl, Move, % IdTextInfo8b, % "x" . v_xNext . "y" . v_yNext 
;5.1.2.6. Raw 5: Reset Recognizer (Z) + Disable
	v_xNext := c_xmarg * 2
	v_yNext += HofCheckBox
	GuiControl, Move, % IdCheckBox8b, % "x" . v_xNext . "y" . v_yNext	
	GuiControlGet, v_OutVarTemp1, Pos, % IdCheckBox8
	v_xNext += v_OutVarTemp1W
	GuiControl, Move, % IdTextInfo10b, % "x" . v_xNext . "y" . v_yNext 
	v_xNext := c_xmarg * 2 + W_C1 + c_xmarg
	GuiControl, Move, % IdCheckBox6b, % "x" . v_xNext . "y" . v_yNext
	GuiControlGet, v_OutVarTemp1, Pos, % IdCheckBox6b
	v_xNext += v_OutVarTemp1W
	GuiControl, Move, % IdTextInfo11b, % "x" . v_xNext . "y" . v_yNext
	
;5.1.3. Select hotstring output function
	v_xNext := c_xmarg
	v_yNext += HofCheckBox + c_ymarg * 2
	GuiControl, Move, % IdText3b, % "x" . v_xNext . "y" . v_yNext
	GuiControlGet, v_OutVarTemp1, Pos, % IdText3b
	v_xNext += v_OutVarTemp1W + c_xmarg
	GuiControl, Move, % IdTextInfo12b, % "x" . v_xNext . "y" . v_yNext
	v_xNext := c_xmarg
	v_yNext += HofText
	v_wNext := LeftColumnW - 2 * c_xmarg
	GuiControl, Move, % IdDDL1b, % "x" . v_xNext . "y" . v_yNext . "w" . v_wNext
	
;5.1.4. Enter hotstring
	v_yNext += HofDropDownList + c_ymarg
	v_xNext := c_xmarg
	GuiControl, Move, % IdText4b, % "x" . v_xNext . "y" . v_yNext
	GuiControlGet, v_OutVarTemp1, Pos, % IdText4b
	v_xNext += v_OutVarTemp1W + c_xmarg
	GuiControl, Move, % IdTextInfo13b, % "x" . v_xNext . "y" . v_yNext
	v_xNext := c_xmarg
	v_yNext += HofText
	v_wNext := LeftColumnW - 2 * c_xmarg
	GuiControl, Move, % IdEdit2b, % "x" . v_xNext . "y" . v_yNext . "w" . v_wNext
	v_yNext += HofEdit
	GuiControl, Move, % IdEdit3b, % "x" . v_xNext . "y" . v_yNext . "w" . v_wNext
	v_yNext += HofEdit
	GuiControl, Move, % IdEdit4b, % "x" . v_xNext . "y" . v_yNext . "w" . v_wNext
	v_yNext += HofEdit
	GuiControl, Move, % IdEdit5b, % "x" . v_xNext . "y" . v_yNext . "w" . v_wNext
	v_yNext += HofEdit
	GuiControl, Move, % IdEdit6b, % "x" . v_xNext . "y" . v_yNext . "w" . v_wNext
	v_yNext += HofEdit
	GuiControl, Move, % IdEdit7b, % "x" . v_xNext . "y" . v_yNext . "w" . v_wNext
	v_yNext += HofEdit
	GuiControl, Move, % IdEdit8b, % "x" . v_xNext . "y" . v_yNext . "w" . v_wNext
;5.1.5. Add comment (optional)	
	v_yNext += HofEdit + c_ymarg
	v_xNext := c_xmarg
	GuiControl, Move, % IdText5b, % "x" . v_xNext . "y" . v_yNext
	GuiControlGet, v_OutVarTemp1, Pos, % IdText5b
	v_xNext += v_OutVarTemp1W + c_xmarg
	GuiControl, Move, % IdTextInfo14b, % "x" . v_xNext . "y" . v_yNext
	v_xNext := c_xmarg
	v_yNext += HofText
	v_wNext := LeftColumnW - 2 * c_xmarg
	GuiControl, Move, % IdEdit9b, % "x" . v_xNext . "y" . v_yNext . "w" . v_wNext
;5.1.6. Select hotstring library 	
	v_yNext += HofEdit + c_ymarg
	v_xNext := c_xmarg
	GuiControl, Move, % IdText6b, % "x" . v_xNext . "y" . v_yNext
	GuiControlGet, v_OutVarTemp1, Pos, % IdText6b
	v_xNext += v_OutVarTemp1W + c_xmarg
	GuiControl, Move, % IdTextInfo15b, % "x" . v_xNext . "y" . v_yNext
	GuiControlGet, v_OutVarTemp2, Pos, % IdButton1b
	v_OutVarTemp := LeftColumnW - (v_OutVarTemp1W + v_OutVarTemp2W + c_xmarg)
	v_xNext := v_OutVarTemp1W + v_OutVarTemp
	v_wNext := v_OutVarTemp2W
	GuiControl, Move, % IdButton1b, % "x" . v_xNext . "y" . v_yNext . "w" . v_wNext ;Add library button
	v_yNext += HofButton
	v_xNext := c_xmarg
	v_wNext := LeftColumnW - v_xNext - c_xmarg
	GuiControl, Move, % IdDDL2b, % "x" v_xNext "y" v_yNext "w" . v_wNext
	
;5.1.7. Buttons	
	v_yNext += HofDropDownList + c_ymarg
	GuiControlGet, v_OutVarTemp1, Pos, % IdButton2b
	GuiControlGet, v_OutVarTemp2, Pos, % IdButton3b
	GuiControlGet, v_OutVarTemp3, Pos, % IdButton4b
	GPB := (LeftColumnW - (c_xmarg + v_OutVarTemp1W + v_OutVarTemp2W + v_OutVarTemp3W + c_xmarg)) // 2 ;GPB = Gap Between Buttons
	v_xNext := c_xmarg
	GuiControl, Move, % IdButton2b, % "x" . v_xNext . "y" . v_yNext
	GuiControlGet, v_OutVarTemp1, Pos, % IdButton2b
	v_xNext += v_OutVarTemp1W + GPB
	GuiControl, Move, % IdButton3b, % "x" . v_xNext . "y" . v_yNext
	GuiControlGet, v_OutVarTemp1, Pos, % IdButton3b
	v_xNext += v_OutVarTemp1W + GPB
	GuiControl, Move, % IdButton4b, % "x" . v_xNext . "y" . v_yNext
	v_yNext += HofButton
	LeftColumnH := v_yNext
;OutputDebug, % "LeftColumnH:" . A_Space . LeftColumnH
	HS4MinWidth		:= LeftColumnW 
	HS4MinHeight		:= LeftColumnH
	return
}
; ------------------------------------------------------------------------------------------------------------------------------------
F_GuiMain_Redraw()
{
	global ;assume-global mode
	local v_OutVarTemp := 0, 	v_OutVarTempX := 0, 	v_OutVarTempY := 0, 	v_OutVarTempW := 0, 	v_OutVarTempH := 0
		,v_xNext := 0, v_yNext := 0,  v_wNext := 0,	v_hNext := 0
	static b_FirstRun := true
	
	if (b_FirstRun) ;position of the List View, but only when HS3 Gui is initiated: before showing. So this code is run only once.
	{
		v_xNext := LeftColumnW + c_WofMiddleButton + c_xmarg
		v_yNext := c_ymarg + HofText
		if (!(ini_ListViewPos["W"]) or !(ini_ListViewPos["H"])) ;if HS3 Gui is generated for the very first time
		{
			v_wNext := RightColumnW
			if ((ini_Sandbox) and !(ini_IsSandboxMoved))
			{
				v_hNext := LeftColumnH - (2 * c_ymarg + 2 * HofText + c_HofSandbox)
			}
			if ((ini_Sandbox) and (ini_IsSandboxMoved))
			{
				v_hNext := LeftColumnH - (c_ymarg + c_HofSandbox)
			}
			if !(ini_Sandbox)
			{
				v_hNext := LeftColumnH - 2 * c_ymarg
				GuiControl, Hide, % IdText10
				GuiControl, Hide, % IdTextInfo17
				GuiControl, Hide, % IdEdit10
			}
			GuiControl, Move, % IdListView1, % "x" . v_xNext . "y" . v_yNext . "w" . v_wNext . "h" . v_hNext
		}
		else
			GuiControl, Move, % IdListView1, % "x" . v_xNext . "y" . v_yNext . "w" . ini_ListViewPos["W"] . "h" ini_ListViewPos["H"]
		b_FirstRun := false
	}
	else
	{
		;OutputDebug, % "Redraw" . A_Space . "The first else" . A_Tab . "ini_Sandbox" . A_Space . ini_Sandbox . A_Tab . "ini_IsSandboxMoved" . A_Space . ini_IsSandboxMoved
		GuiControlGet, v_OutVarTemp, Pos, % IdListView1
		if (ini_Sandbox)
		{
			if (v_OutVarTempH <  LeftColumnH + c_HofSandbox)
			{
				v_hNext := v_OutVarTempH - (c_HofSandbox + HofText + c_ymarg)	;decrease ListView
				GuiControl, Move, % IdListView1, % "h" . v_hNext
				ini_IsSandboxMoved := false
			}
			else
				ini_IsSandboxMoved := true
		}
		if (!ini_Sandbox)
		{
			if (v_OutVarTempH <  LeftColumnH + c_HofSandbox)
			{
				v_hNext := v_OutVarTempH + (c_HofSandbox + HofText + c_ymarg)	;increase ListView
				GuiControl, Move, % IdListView1, % "h" . v_hNext
				ini_IsSandboxMoved := false
			}
			else
				ini_IsSandboxMoved := true
		}
	}	
	;5.3.3. Text Sandbox
	;5.2.4. Sandbox edit text field
	if ((ini_Sandbox) and (ini_IsSandboxMoved))
	{
		v_xNext := c_xmarg
		v_yNext := LeftColumnH + c_ymarg
		GuiControl, Move, % IdText10, % "x" . v_xNext . "y" . v_yNext
		GuiControlGet, v_OutVarTemp, Pos, % IdText10
		v_xNext += v_OutVarTempW + c_xmarg
		GuiControl, Move, % IdTextInfo17, % "x" . v_xNext . "y" . v_yNext
		v_xNext := c_xmarg
		v_yNext += HofText
		v_wNext := LeftColumnW - 2 * c_xmarg
		GuiControl, Move, % IdEdit10, % "x" . v_xNext . "y" . v_yNext . "w" . v_wNext
		GuiControl, Show, % IdText10
		GuiControl, Show, % IdTextInfo17
		GuiControl, Show, % IdEdit10
	}
	if ((ini_Sandbox) and !(ini_IsSandboxMoved))
	{
		GuiControlGet, v_OutVarTemp, Pos, % IdListView1
		v_xNext := LeftColumnW + c_WofMiddleButton + c_xmarg
		v_yNext := v_OutVarTempY + v_OutVarTempH + c_ymarg
		GuiControl, Move, % IdText10, % "x" . v_xNext . "y" . v_yNext
		GuiControlGet, v_OutVarTemp, Pos, % IdText10
		v_xNext += v_OutVarTempW + c_xmarg
		GuiControl, Move, % IdTextInfo17, % "x" . v_xNext . "y" . v_yNext
		v_xNext := LeftColumnW + c_WofMiddleButton + c_xmarg
		v_yNext += HofText
		GuiControlGet, v_OutVarTemp, Pos, % IdListView1
		v_wNext := v_OutVarTempW
		GuiControl, Move, % IdEdit10, % "x" . v_xNext . "y" . v_yNext . "w" . v_wNext
		GuiControl, Show, % IdText10
		GuiControl, Show, % IdTextInfo17
		GuiControl, Show, % IdEdit10
	}
	if !(ini_Sandbox)
	{
		GuiControl, Hide, % IdText10
		GuiControl, Hide, % IdTextInfo17		
		GuiControl, Hide, % IdEdit10
	}
	
	;5.2. Button between left and right column
	GuiControlGet, v_OutVarTemp, Pos, % IdListView1
	if ((ini_Sandbox) and (ini_IsSandboxMoved))
	{
		v_xNext := LeftColumnW 
		v_yNext := c_ymarg
		v_hNext := HofText + v_OutVarTempH
	}
	if ((ini_Sandbox) and !(ini_IsSandboxMoved))
	{
		v_xNext := LeftColumnW 
		v_yNext := c_ymarg
		v_hNext := HofText + v_OutVarTempH + c_ymarg + HofText + c_HofSandbox
	}	
	if !(ini_Sandbox) 
	{
		v_xNext := LeftColumnW
		v_yNext := c_ymarg
		v_hNext :=  HofText + v_OutVarTempH
	}
	GuiControl, Move, % IdButton5, % "x" . v_xNext . "y" . v_yNext . "h" . v_hNext
}
; ------------------------------------------------------------------------------------------------------------------------------------
	
F_GuiMain_DetermineConstraints()
{
;Within a function, to create a set of variables that is local instead of global, declare OutputVar as a local variable prior to using command GuiControlGet, Pos. However, it is often also necessary to declare each variable in the set, due to a common source of confusion.
	global ;assume-global mode
	local v_OutVarTemp := 0, 	v_OutVarTempX := 0, 	v_OutVarTempY := 0, 	v_OutVarTempW := 0, 	v_OutVarTempH := 0
		,v_OutVarTemp1 := 0, 	v_OutVarTemp1X := 0, 	v_OutVarTemp1Y := 0, 	v_OutVarTemp1W := 0, 	v_OutVarTemp1H := 0
		,v_OutVarTemp2 := 0, 	v_OutVarTemp2X := 0, 	v_OutVarTemp2Y := 0, 	v_OutVarTemp2W := 0, 	v_OutVarTemp2H := 0
		,v_OutVarTemp3 := 0, 	v_OutVarTemp3X := 0, 	v_OutVarTemp3Y := 0, 	v_OutVarTemp3W := 0, 	v_OutVarTemp3H := 0
		,v_OutVarTemp4 := 0, 	v_OutVarTemp4X := 0, 	v_OutVarTemp4Y := 0, 	v_OutVarTemp4W := 0, 	v_OutVarTemp4H := 0
		,v_OutVarTemp5 := 0, 	v_OutVarTemp5X := 0, 	v_OutVarTemp5Y := 0, 	v_OutVarTemp5W := 0, 	v_OutVarTemp5H := 0
		,v_OutVarTemp6 := 0, 	v_OutVarTemp6X := 0, 	v_OutVarTemp6Y := 0, 	v_OutVarTemp6W := 0, 	v_OutVarTemp6H := 0
							,v_xNext := 0, 		v_yNext := 0, 			v_wNext := 0, 			v_hNext := 0
		,WleftMiniColumn := 0,	WrightMiniColumn := 0,	SpaceBetweenColumns := 0
		,W_InfoSign := 0, 		W_C1 := 0,			W_C2 := 0,			GPB := 0
	
;4. Determine constraints, according to mock-up
;4.1. Determine left columnt width
	GuiControlGet, v_OutVarTemp1, Pos, % IdTextInfo1
	W_InfoSign := v_OutVarTemp1W
	
	GuiControlGet, v_OutVarTemp1, Pos, % IdCheckBox1
	GuiControlGet, v_OutVarTemp2, Pos, % IdCheckBox3
	GuiControlGet, v_OutVarTemp3, Pos, % IdCheckBox4
	GuiControlGet, v_OutVarTemp4, Pos, % IdCheckBox5
	GuiControlGet, v_OutVarTemp6, Pos, % IdCheckBox8
	W_C1 := Max(v_OutVarTemp1W, v_OutVarTemp2W, v_OutVarTemp3W, v_OutVarTemp4W, v_OutVarTemp6W) + c_xmarg + W_InfoSign
	
	GuiControlGet, v_OutVarTemp1, Pos, % IdRadioCaseCC
	GuiControlGet, v_OutVarTemp2, Pos, % IdRadioCaseCS
	GuiControlGet, v_OutVarTemp3, Pos, % IdRadioCaseC1
	GuiControlGet, v_OutVarTemp4, Pos, % IdCheckBox6
	W_C2 := Max(v_OutVarTemp1W, v_OutVarTemp2W, v_OutVarTemp3W, v_OutVarTemp4W) + c_xmarg + W_InfoSign
	
	LeftColumnW := 2 * c_xmarg + W_C1 + c_xmarg + W_C2 + c_xmarg
	
;4.2. Determine right column width
	GuiControlGet, v_OutVarTemp2, Pos, % IdText9 ;Triggerstring|Trigg Opt|Out Fun|En/Dis|Hotstring|Comment"]
	RightColumnW := v_OutVarTemp2W
	GuiControl,	Hide,		% IdText9
	
;5. Move text objects to correct position
;5.1. Left column
;5.1.1. Enter triggerstring
	v_xNext := c_xmarg
	v_yNext := c_ymarg
	GuiControl, Move, % IdText1, % "x" . v_xNext . "y" . v_yNext
	
	GuiControlGet, v_OutVarTemp1, Pos, % IdText1
	v_xNext += v_OutVarTemp1W + c_xmarg
	GuiControl, Move, % IdTextInfo1, % "x" . v_xNext . "y" . v_yNext
 	v_xNext += W_InfoSign + c_xmarg
	v_wNext := LeftColumnW - v_xNext - c_xmarg
	GuiControl, Move, % IdEdit1, % "x" . v_xNext . "y" . v_yNext . "w" . v_wNext
	
;5.1.2. Select trigger options
	v_xNext := c_xmarg 
	v_yNext := c_ymarg + HofEdit + HofText 
	v_wNext := c_xmarg + W_C1 + c_xmarg  + W_C2
	v_hNext := HofText + c_ymarg + HofCheckBox * 5 + c_ymarg
	GuiControl, Move, % IdGroupBox1, % "x" . v_xNext . "y" . v_yNext . "w" . v_wNext . "h" . v_hNext
;5.1.2.1. Raw 1: Immediate execute (*) + Case-Conforming
	v_xNext += c_xmarg
	v_yNext += HofText + c_ymarg
	GuiControl, Move, % IdCheckBox1, % "x" . v_xNext . "y" . v_yNext 
	GuiControlGet, v_OutVarTemp1, Pos, % IdCheckBox1
	v_xNext += v_OutVarTemp1W
	GuiControl, Move, % IdTextInfo2, % "x" . v_xNext . "y" . v_yNext 
	v_xNext := c_xmarg * 2 + W_C1 + c_xmarg
	GuiControl, Move, % IdRadioCaseCC, % "x" . v_xNext . "y" . v_yNext
	GuiControlGet, v_OutVarTemp1, Pos, % IdRadioCaseCC
	v_xNext += v_OutVarTemp1W
	GuiControl, Move, % IdTextInfo3, % "x" . v_xNext . "y" . v_yNext
;5.1.2.2. Raw 2: No Backspace (B0)	+ Case Sensitive (C)
	v_xNext := c_xmarg * 2
	v_yNext += HofCheckBox
	GuiControl, Move, % IdCheckBox3, % "x" . v_xNext . "y" . v_yNext
	GuiControlGet, v_OutVarTemp1, Pos, % IdCheckBox3
	v_xNext += v_OutVarTemp1W
	GuiControl, Move, % IdTextInfo4, % "x" . v_xNext . "y" . v_yNext 
	v_xNext := c_xmarg * 2 + W_C1 + c_xmarg
	GuiControl, Move, % IdRadioCaseCS, % "x" . v_xNext . "y" . v_yNext
	GuiControlGet, v_OutVarTemp1, Pos, % IdRadioCaseCS
	v_xNext += v_OutVarTemp1W
	GuiControl, Move, % IdTextInfo5, % "x" . v_xNext . "y" . v_yNext
;5.1.2.3. Raw 3: Inside Word (?) + Not Case-Conforming (C1)
	v_xNext := c_xmarg * 2
	v_yNext += HofCheckBox
	GuiControl, Move, % IdCheckBox4, % "x" . v_xNext . "y" . v_yNext	
	GuiControlGet, v_OutVarTemp1, Pos, % IdCheckBox4
	v_xNext += v_OutVarTemp1W
	GuiControl, Move, % IdTextInfo6, % "x" . v_xNext . "y" . v_yNext 
	v_xNext := c_xmarg * 2 + W_C1 + c_xmarg
	GuiControl, Move, % IdRadioCaseC1, % "x" . v_xNext . "y" . v_yNext
	GuiControlGet, v_OutVarTemp1, Pos, % IdRadioCaseC1
	v_xNext += v_OutVarTemp1W
	GuiControl, Move, % IdTextInfo7, % "x" . v_xNext . "y" . v_yNext
;5.1.2.4. Raw 4: No EndChar (O)
	v_xNext := c_xmarg * 2
	v_yNext += HofCheckBox
	GuiControl, Move, % IdCheckBox5, % "x" . v_xNext . "y" . v_yNext	
	GuiControlGet, v_OutVarTemp1, Pos, % IdCheckBox5
	v_xNext += v_OutVarTemp1W
	GuiControl, Move, % IdTextInfo8, % "x" . v_xNext . "y" . v_yNext 
;5.1.2.6. Raw 5: Reset Recognizer (Z) + Disable
	v_xNext := c_xmarg * 2
	v_yNext += HofCheckBox
	GuiControl, Move, % IdCheckBox8, % "x" . v_xNext . "y" . v_yNext	
	GuiControlGet, v_OutVarTemp1, Pos, % IdCheckBox8
	v_xNext += v_OutVarTemp1W
	GuiControl, Move, % IdTextInfo10, % "x" . v_xNext . "y" . v_yNext 
	v_xNext := c_xmarg * 2 + W_C1 + c_xmarg
	GuiControl, Move, % IdCheckBox6, % "x" . v_xNext . "y" . v_yNext
	GuiControlGet, v_OutVarTemp1, Pos, % IdCheckBox6
	v_xNext += v_OutVarTemp1W
	GuiControl, Move, % IdTextInfo11, % "x" . v_xNext . "y" . v_yNext
	
;5.1.3. Select hotstring output function
	v_xNext := c_xmarg
	v_yNext += HofCheckBox + c_ymarg * 2
	GuiControl, Move, % IdText3, % "x" . v_xNext . "y" . v_yNext
	GuiControlGet, v_OutVarTemp1, Pos, % IdText3
	v_xNext += v_OutVarTemp1W + c_xmarg
	GuiControl, Move, % IdTextInfo12, % "x" . v_xNext . "y" . v_yNext
	v_xNext := c_xmarg
	v_yNext += HofText
	v_wNext := LeftColumnW - 2 * c_xmarg
	GuiControl, Move, % IdDDL1, % "x" . v_xNext . "y" . v_yNext . "w" . v_wNext
	
;5.1.4. Enter hotstring
	v_yNext += HofDropDownList + c_ymarg
	v_xNext := c_xmarg
	GuiControl, Move, % IdText4, % "x" . v_xNext . "y" . v_yNext
	GuiControlGet, v_OutVarTemp1, Pos, % IdText4
	v_xNext += v_OutVarTemp1W + c_xmarg
	GuiControl, Move, % IdTextInfo13, % "x" . v_xNext . "y" . v_yNext
	v_xNext := c_xmarg
	v_yNext += HofText
	v_wNext := LeftColumnW - 2 * c_xmarg
	GuiControl, Move, % IdEdit2, % "x" . v_xNext . "y" . v_yNext . "w" . v_wNext
	v_yNext += HofEdit
	GuiControl, Move, % IdEdit3, % "x" . v_xNext . "y" . v_yNext . "w" . v_wNext
	v_yNext += HofEdit
	GuiControl, Move, % IdEdit4, % "x" . v_xNext . "y" . v_yNext . "w" . v_wNext
	v_yNext += HofEdit
	GuiControl, Move, % IdEdit5, % "x" . v_xNext . "y" . v_yNext . "w" . v_wNext
	v_yNext += HofEdit
	GuiControl, Move, % IdEdit6, % "x" . v_xNext . "y" . v_yNext . "w" . v_wNext
	v_yNext += HofEdit
	GuiControl, Move, % IdEdit7, % "x" . v_xNext . "y" . v_yNext . "w" . v_wNext
	v_yNext += HofEdit
	GuiControl, Move, % IdEdit8, % "x" . v_xNext . "y" . v_yNext . "w" . v_wNext
;5.1.5. Add comment (optional)	
	v_yNext += HofEdit + c_ymarg
	v_xNext := c_xmarg
	GuiControl, Move, % IdText5, % "x" . v_xNext . "y" . v_yNext
	GuiControlGet, v_OutVarTemp1, Pos, % IdText5
	v_xNext += v_OutVarTemp1W + c_xmarg
	GuiControl, Move, % IdTextInfo14, % "x" . v_xNext . "y" . v_yNext
	v_xNext := c_xmarg
	v_yNext += HofText
	v_wNext := LeftColumnW - 2 * c_xmarg
	GuiControl, Move, % IdEdit9, % "x" . v_xNext . "y" . v_yNext . "w" . v_wNext
;5.1.6. Select hotstring library 	
	v_yNext += HofEdit + c_ymarg
	v_xNext := c_xmarg
	GuiControl, Move, % IdText6, % "x" . v_xNext . "y" . v_yNext
	GuiControlGet, v_OutVarTemp1, Pos, % IdText6
	v_xNext += v_OutVarTemp1W + c_xmarg
	GuiControl, Move, % IdTextInfo15, % "x" . v_xNext . "y" . v_yNext
	GuiControlGet, v_OutVarTemp2, Pos, % IdButton1
	v_OutVarTemp := LeftColumnW - (v_OutVarTemp1W + v_OutVarTemp2W + c_xmarg)
	v_xNext := v_OutVarTemp1W + v_OutVarTemp
	v_wNext := v_OutVarTemp2W
	GuiControl, Move, % IdButton1, % "x" . v_xNext . "y" . v_yNext . "w" . v_wNext ;Add library button
	v_yNext += HofButton
	v_xNext := c_xmarg
	v_wNext := LeftColumnW - v_xNext - c_xmarg
	GuiControl, Move, % IdDDL2, % "x" v_xNext "y" v_yNext "w" . v_wNext
	
;5.1.7. Buttons	
	v_yNext += HofDropDownList + c_ymarg
	GuiControlGet, v_OutVarTemp1, Pos, % IdButton2
	GuiControlGet, v_OutVarTemp2, Pos, % IdButton3
	GuiControlGet, v_OutVarTemp3, Pos, % IdButton4
	GPB := (LeftColumnW - (c_xmarg + v_OutVarTemp1W + v_OutVarTemp2W + v_OutVarTemp3W + c_xmarg)) // 2 ;GPB = Gap Between Buttons
	v_xNext := c_xmarg
	GuiControl, Move, % IdButton2, % "x" . v_xNext . "y" . v_yNext
	GuiControlGet, v_OutVarTemp1, Pos, % IdButton2
	v_xNext += v_OutVarTemp1W + GPB
	GuiControl, Move, % IdButton3, % "x" . v_xNext . "y" . v_yNext
	GuiControlGet, v_OutVarTemp1, Pos, % IdButton3
	v_xNext += v_OutVarTemp1W + GPB
	GuiControl, Move, % IdButton4, % "x" . v_xNext . "y" . v_yNext
	v_yNext += HofButton
	LeftColumnH := v_yNext
;OutputDebug, % "LeftColumnH:" . A_Space . LeftColumnH
	
;5.3. Right column
;5.3.1. Position the text "Library content"
	v_yNext := c_ymarg
	v_xNext := LeftColumnW + c_WofMiddleButton + c_xmarg
	GuiControl, Move, % IdText7, % "x" . v_xNext . "y" . v_yNext
	GuiControlGet, v_OutVarTemp1, Pos, % IdText7
	v_xNext += v_OutVarTemp1W + c_xmarg
	GuiControl, Move, % IdTextInfo16, % "x" . v_xNext . "y" . v_yNext
	
;5.3.2. Position of hotstring statistics (in this library: IdText11 / total: IdText2)
	GuiControlGet, v_OutVarTemp, Pos, % IdTextInfo16 ;text: Library content (F2)
	v_xNext += v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdText11, % "x" v_xNext "y" v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdText11 ;text: Hotstrings
	v_xNext += v_OutVarTempW
	GuiControl, Move, % IdText13, % "x" v_xNext "y" v_yNext ;Where to place value of Hotstrings counter
	GuiControlGet, v_OutVarTemp, Pos, % IdText13
	v_xNext += v_OutVarTempW + c_xmarg
	GuiControl, Move, % IdText2, % "x" v_xNext "y" v_yNext ;where to place text Total
	GuiControlGet, v_OutVarTemp, Pos, % IdText2
	v_xNext += v_OutVarTempW
	GuiControl, Move, % IdText12, % "x" v_xNext "y" v_yNext ;Where to place value of total counter
	HS3MinWidth		:= LeftColumnW + c_WofMiddleButton + RightColumnW
	HS3MinHeight		:= LeftColumnH + c_ymarg
	return
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
	Gui,	MyAbout: Font,		% "s" . c_FontSize . A_Space . "bold" . A_Space . "c" . c_FontColor, 					% c_FontType
	Gui, MyAbout: Add, 		Text,    x0 y0 HwndIdLine1, 													% TransA["Let's make your PC personal again..."]
	Gui,	MyAbout: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, 					% c_FontType
	Gui, MyAbout: Add, 		Text,    x0 y0 HwndIdLine2, 													% TransA["Enables Convenient Definition"]
	Gui, MyAbout: Add, 		Button,  x0 y0 HwndIdAboutOkButton gAboutOkButton,								% TransA["OK"]
	Gui, MyAbout: Add,		Picture, x0 y0 HwndIdAboutPicture w96 h96, 										% AppIcon
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_GuiAbout_DetermineConstraints()
{
	global ;assume-global mode
;Within a function, to create a set of variables that is local instead of global, declare OutputVar as a local variable prior to using command GuiControlGet, Pos. However, it is often also necessary to declare each variable in the set, due to a common source of confusion.
	local v_OutVarTemp := 0, 	v_OutVarTempX := 0, 	v_OutVarTempY := 0, 	v_OutVarTempW := 0, 	v_OutVarTempH := 0
		,v_OutVarTemp1 := 0, 	v_OutVarTemp1X := 0, 	v_OutVarTemp1Y := 0, 	v_OutVarTemp1W := 0, 	v_OutVarTemp1H := 0
		,v_OutVarTemp2 := 0, 	v_OutVarTemp2X := 0, 	v_OutVarTemp2Y := 0, 	v_OutVarTemp2W := 0, 	v_OutVarTemp2H := 0
		,v_OutVarTemp3 := 0, 	v_OutVarTemp3X := 0, 	v_OutVarTemp3Y := 0, 	v_OutVarTemp3W := 0, 	v_OutVarTemp3H := 0
							,v_xNext := 0, 		v_yNext := 0, 			v_wNext := 0, 			v_hNext := 0
		,HwndIdLongest := 0, 	IdLongest := 0
	
;4. Determine constraints, according to mock-up
	v_xNext := c_xmarg
	v_yNext := c_ymarg
	GuiControl, Move, % IdLine1, % "x" v_xNext "y" v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdLine1
	v_yNext += v_OutVarTempH + c_ymarg
	GuiControl, Move, % IdLine2, % "x" v_xNext "y" v_yNext
	
	;Find the longest substring:
	Loop, Parse, % TransA["Enables Convenient Definition"], % "`n"
	{
		v_OutVarTemp1 := StrLen(Trim(A_LoopField))
		if (v_OutVarTemp1 > v_OutVarTemp)
			v_OutVarTemp := v_OutVarTemp1
	}
	Loop, Parse, % TransA["Enables Convenient Definition"], % "`n"
	{
		if (StrLen(Trim(A_LoopField)) = v_OutVarTemp)
		{
			Gui, MyAbout: Add, Text, x0 y0 HwndIdLongest, % Trim(A_LoopField)
			GuiControlGet, v_OutVarTemp, Pos, % IdLine1
			v_xNext := c_xmarg
			v_yNext := c_ymarg + v_OutVarTempH + c_ymarg
			GuiControl, Move, % IdLongest, % "x" . v_xNext . "y" . v_yNext 
			GuiControl, Hide, % IdLongest
			Break
		}
	}
	
	GuiControlGet, v_OutVarTemp1, Pos, % IdLongest ; weight of the longest text
	GuiControlGet, v_OutVarTemp2, Pos, % IdAboutOkButton 
	v_wNext := v_OutVarTemp2W + 2 * c_xmarg
	v_xNext := (v_OutVarTemp1W // 2) - (v_wNext // 2)
	GuiControlGet, v_OutVarTemp, Pos, % IdLine2
	v_yNext := v_OutVarTempY + v_OutVarTempH + 2 * c_ymarg
	GuiControl, Move, % IdAboutOkButton, % "x" . v_xNext . "y" . v_yNext . "w" . v_wNext
	
	v_xNext := v_OutVarTemp1X + v_OutVarTemp1W - 96 ;96 = chosen size of icon
	v_yNext := v_OutVarTemp1Y + v_OutVarTemp1H
	GuiControl, Move, % IdAboutPicture, % "x" . v_xNext . "y" . v_yNext 
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
F_GuiAbout()
{
	global ;assume-global mode
	local FoundPos := ""
		,Window1X := 0, Window1Y := 0, Window1W := 0, Window1H := 0
		,Window2X := 0, Window2Y := 0, Window2W := 0, Window2H := 0
		,NewWinPosX := 0, NewWinPosY := 0
	
	if (WinExist("ahk_id" . HS3GuiHwnd) or WinExist("ahk_id" . HS3GuiHwnd) or WinExist("ahk_id" . HS4GuiHwnd) or WinExist("ahk_id" . HS4GuiHwnd))
		WinGetPos, Window1X, Window1Y, Window1W, Window1H, A
	Gui, MyAbout: Show, Hide Center AutoSize
	
	DetectHiddenWindows, On
	WinGetPos, Window2X, Window2Y, Window2W, Window2H, % "ahk_id" . MyAboutGuiHwnd
	DetectHiddenWindows, Off
	if (Window1W)
	{
		NewWinPosX := Round(Window1X + (Window1W / 2) - (Window2W / 2))
		NewWinPosY := Round(Window1Y + (Window1H / 2) - (Window2H / 2))
		Gui, MyAbout: Show, % "AutoSize" . A_Space . "x" . NewWinPosX . A_Space . "y" . NewWinPosY, % A_ScriptName . ":" . A_Space . TransA["Default mode"] . ":" . A_Space . TransA["About this application..."]
	}
	else
	{
		if (v_Param = "l")
			Gui, MyAbout: Show, Center AutoSize, % A_ScriptName . ":" . A_Space . TransA["Silent mode"] . ":" . A_Space . TransA["About this application..."]
		else
			Gui, MyAbout: Show, Center AutoSize, % A_ScriptName . ":" . A_Space . TransA["Silent mode"] . ":" . A_Space . TransA["Default mode"]
		
	}
	return  
}
	
; ------------------------------------------------------------------------------------------------------------------------------------
	
F_ValidateIniLibSections() ; Load from / to Config.ini from Libraries folder
{
	global ;assume-global mode
	local v_IsLibraryEmpty := true, v_ConfigLibrary := ""
	,o_Libraries := {}, v_LibFileName := "", key := 0, value := "", TempLoadLib := "", TempShowTipsLib := "", v_LibFlagTemp := ""
	,FlagFound := false, PriorityFlag := false, ValueTemp := 0, SectionTemp := ""
	
	ini_LoadLib := {}, ini_ShowTipsLib := {}	; this associative array is used to store information about Libraries\*.csv files to be loaded
	
	IniRead, TempLoadLib,	% HADConfig, LoadLibraries
	
;Check if Libraries subfolder exists. If not, create it and display warning.
	v_IsLibraryEmpty := true
	if (!Instr(FileExist(HADL), "D"))				; if  there is no "Libraries" subfolder 
	{
		FileCreateDir, % HADL							; Future: check against errors
		MsgBox, 48, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["warning"], % TransA["There is no Libraries subfolder and no lbrary (*.csv) file exists!"] . "`n`n" . HADL . "`n`n" . TransA["folder is now created"] . "."
	}
	else
	{
	;Check if Libraries subfolder is empty. If it does, display warning.
		Loop, Files, % HADL . "\*.csv"
		{
			v_IsLibraryEmpty := false
			break
		}
	}
	if (v_IsLibraryEmpty)
	{
		MsgBox, 52, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["warning"], % TransA["Libraries folder:"] . "`n`n" . HADL . A_Space . "`n`n"
			. TransA["is empty. No (triggerstring, hotstring) definition will be loaded. Do you want to create the default library file: PriorityLibrary.csv?"]
		IfMsgBox, Yes
		{
			FileAppend, , % HADL . "\" . "PriorityLibrary.csv", UTF-8
			F_ValidateIniLibSections()
		}
	}
	
;Read names library files (*.csv) from Library subfolder into object.
	if !(v_IsLibraryEmpty)
		Loop, Files, % HADL . "\*.csv"
			o_Libraries.Push(A_LoopFileName)
	
;Check if Config.ini contains in section [Libraries] file names which are actually in library subfolder. Synchronize [Libraries] section with content of subfolder.
;Parse the TempLoadLib.
	IniRead, TempLoadLib, % HADConfig, LoadLibraries
	for key, value in o_Libraries
	{
		FlagFound := false
		Loop, Parse, TempLoadLib, `n, `r
		{
			v_LibFileName 	:= SubStr(A_LoopField, 1, InStr(A_LoopField, "=") - 1)
			v_LibFlagTemp 	:= SubStr(A_LoopField, InStr(A_LoopField, "=",, v_LibFileName) + 1)
			if (value == v_LibFileName)
			{
				ini_LoadLib[value] := v_LibFlagTemp
				FlagFound := true
			}
		}	
		if !(FlagFound)
			ini_LoadLib[value] := 1
	}
	
;Delete and recreate [Libraries] section of Config.ini mirroring ini_LoadLib associative table. "PriorityLibrary.csv" as the last one.
	IniDelete, % HADConfig, LoadLibraries
	for key, value in ini_LoadLib
	{
		if (key != "PriorityLibrary.csv")
			SectionTemp .= key . "=" . value . "`n"
		else
		{
			PriorityFlag := true
			ValueTemp := value
		}
	}
	if (PriorityFlag)
		SectionTemp .= "PriorityLibrary.csv" . "=" . ValueTemp
	
	IniWrite, % SectionTemp, % HADConfig, LoadLibraries
	
	SectionTemp := ""
;Check if Config.ini contains in section [ShowTipsLibraries] file names which are actually in library subfolder. Synchronize [Libraries] section with content of subfolder.
;Parse the TempLoadLib.
	IniRead, TempShowTipsLib, % HADConfig, ShowTipsLibraries
	for key, value in o_Libraries
	{
		FlagFound := false
		Loop, Parse, TempShowTipsLib, `n, `r
		{
			v_LibFileName 	:= SubStr(A_LoopField, 1, InStr(A_LoopField, "=") - 1)
			v_LibFlagTemp 	:= SubStr(A_LoopField, InStr(A_LoopField, "=",, v_LibFileName) + 1)
			if (value == v_LibFileName)
			{
				ini_ShowTipsLib[value] := v_LibFlagTemp
				FlagFound := true
			}
		}	
		if !(FlagFound)
			ini_ShowTipsLib[value] := 1
	}
	
;Delete and recreate [ShowTipsLibraries] section of Config.ini mirroring ini_ShowTipsLib associative table. "PriorityLibrary.csv" as the last one.
	IniDelete, % HADConfig, ShowTipsLibraries
	for key, value in ini_ShowTipsLib
	{
		if (key != "PriorityLibrary.csv")
			SectionTemp .= key . "=" . value . "`n"
		else
		{
			PriorityFlag := true
			ValueTemp := value
		}
	}
	if (PriorityFlag)
		SectionTemp .= "PriorityLibrary.csv" . "=" . ValueTemp
	
	IniWrite, % SectionTemp, % HADConfig, ShowTipsLibraries
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_LoadLibrariesToTables()
{ 
	global	;assume-global mode
	local name := "", varSearch := "", tabSearch := ""
	a_Library 				:= []
	a_TriggerOptions 			:= []
	a_Triggerstring 			:= []
	a_OutputFunction 			:= []
	a_EnableDisable 			:= []
	a_Hotstring				:= []
	a_Comment 				:= []
	
	; Prepare TrayTip message taking into account value of command line parameter.
	if (v_Param == "d")
		TrayTip, %A_ScriptName% - Debug mode, 	% TransA["Loading hotstrings from libraries..."], 1
	else if (v_Param == "l")
		TrayTip, %A_ScriptName% - Lite mode, 	% TransA["Loading hotstrings from libraries..."], 1
	else	
		TrayTip, %A_ScriptName%,				% TransA["Loading hotstrings from libraries..."], 1
	
	;Here content of libraries is loaded into set of tables
	Loop, Files, % HADL . "\*.csv"
	{
		Loop
		{
			FileReadLine, varSearch, %A_LoopFileFullPath%, %A_Index%
			if (ErrorLevel)
				break
			name 	:= SubStr(A_LoopFileName, 1, -4)
			tabSearch := StrSplit(varSearch, "‖")
			/*
				if (InStr(tabSearch[1], "*0"))	;in case any library file (*.csv) contain option in switched off state, remove it; those lines are kept for backward compatibility and currently shouldn't be necessary.
				{
					tabSearch[1] := StrReplace(tabSearch[1], "*0")
				}
				if (InStr(tabSearch[1], "O0"))
				{
					tabSearch[1] := StrReplace(tabSearch[1], "O0")
				}
				if (InStr(tabSearch[1], "C0"))
				{
					tabSearch[1] := StrReplace(tabSearch[1], "C0")
				}
				if (InStr(tabSearch[1], "?0"))
				{
					tabSearch[1] := StrReplace(tabSearch[1], "?0")
				}
				if (InStr(tabSearch[1], "B")) and !(InStr(tabSearch[1], "B0"))
				{
					tabSearch[1] := StrReplace(tabSearch[1], "B")
				}
			*/
			a_Library.Push(name)
			a_TriggerOptions.Push(tabSearch[1])
			a_Triggerstring.Push(tabSearch[2])
			a_OutputFunction.Push(tabSearch[3])
			a_EnableDisable.Push(tabSearch[4])
			a_Hotstring.Push(tabSearch[5])
			a_Comment.Push(tabSearch[6])
		}
	}
	TrayTip, %A_ScriptName%, % TransA["Hotstrings have been loaded"], 1
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_CreateHotstring(txt, nameoffile) 
{ 
	global	;assume-global mode
	local Options := "", SendFun := "", EnDis := "", OnOff := "", TextInsert := "", Oflag := false
	
	v_TriggerString := ""
	Loop, Parse, txt, ‖
	{
		Switch A_Index
		{
			Case 1:
				Options := A_LoopField
				Oflag := false
				if (InStr(Options, "O", 0))
					Oflag := true
				else
					Oflag := false
			Case 2:
				v_Triggerstring := A_LoopField
				v_Triggerstring := StrReplace(v_Triggerstring, "``n", "`n") ;theese lines are necessary to handle rear definitions of hotstrings such as those finished with `n, `r etc.
				v_Triggerstring := StrReplace(v_Triggerstring, "``r", "`r")	;future: add more sequences like {Esc} etc.
				v_Triggerstring := StrReplace(v_Triggerstring, "``t", "`t")
				v_Triggerstring := StrReplace(v_Triggerstring, "``", "`")
				v_Triggerstring := StrReplace(v_Triggerstring, "``b", "`b")
			Case 3:
				Switch A_LoopField
				{
					Case "SI": 	SendFun := "F_HOF_SI"
					Case "CL": 	SendFun := "F_HOF_CLI"
					Case "MCL": 	SendFun := "F_HOF_MCLI"
					Case "MSI":	SendFun := "F_HOF_MSI"
					Case "SR":	SendFun := "F_HOF_SR"
					Case "SP":	SendFun := "F_HOF_SP"
					Case "SE":	SendFun := "F_HOF_SE"
				}
			Case 4: 
				Switch A_LoopField
				{
					Case "En":	OnOff := "On"
					Case "Dis":	OnOff := "Off"	
				}
			Case 5:
				TextInsert := A_LoopField
		}
	}
	
	if ((!v_TriggerString) and (Options or SendFun or OnOff or TextInsert))
	{
		MsgBox, 262420, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["Error"], % TransA["Error reading library file:"] . "`n`n" . nameoffile . "`n`n" . TransA["the following line is found:"] 
					. "`n" . txt . "`n`n" . TransA["This line do not comply to format required by this application."] . "`n`n" 
					. TransA["Continue reading the library file? If you answer ""No"" then application will exit!"]
		IfMsgBox, No
			ExitApp, 1	;error reading library file
		IfMsgBox, Yes
			return
	}
	if (v_TriggerString and (OnOff = "On"))
	{
		;OutputDebug, % "Hotstring(:" . Options . ":" . v_Triggerstring . "," . "func(" . SendFun . ").bind(" . TextInsert . "," . A_Space . Oflag . ")," . A_Space . OnOff . ")"
		Try
			Hotstring(":" . Options . ":" . v_TriggerString, func(SendFun).bind(TextInsert, Oflag), OnOff)	;tu jestem
		Catch
			MsgBox, 16, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["Error"], % A_ThisFunc . A_Space . TransA["Something went wrong with (triggerstring, hotstring) creation"] . ":" . "`n`n"
				. "Hotstring(:" . Options . ":" . v_Triggerstring . "," . "func(" . SendFun . ").bind(" . TextInsert . "," . A_Space . Oflag . ")," . A_Space . OnOff . ")"
	}
	return
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

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

F_ReplaceAHKconstants(String)
{
	String := StrReplace(String, "A_YYYY", 		A_YYYY)
	String := StrReplace(String, "A_MMMM", 		A_MMMM)
	String := StrReplace(String, "A_MMM", 		A_MMM)
	String := StrReplace(String, "A_MM", 		A_MM)
	String := StrReplace(String, "A_DDDD", 		A_DDDD)
	String := StrReplace(String, "A_DDD", 		A_DDD)
	String := StrReplace(String, "A_DD", 		A_DD)
	String := StrReplace(String, "A_WDay", 		A_WDay)
	String := StrReplace(String, "A_YDay", 		A_YDay)
	String := StrReplace(String, "A_YWeek", 	A_YWeek)
	String := StrReplace(String, "A_Hour",		A_Hour)
	String := StrReplace(String, "A_Min", 		A_Min)
	String := StrReplace(String, "A_Sec", 		A_Sec)
	String := StrReplace(String, "A_MSec", 		A_MSec)
	String := StrReplace(String, "A_Now", 		A_Now)
	String := StrReplace(String, "A_NowUTC", 	A_NowUTC)
	String := StrReplace(String, "A_TickCount", 	A_TickCount)
	String := StrReplace(String, "``n", "`n")	;https://www.autohotkey.com/docs/misc/EscapeChar.htm
	String := StrReplace(String, "``r", "`r")	;https://www.autohotkey.com/docs/misc/EscapeChar.htm
	String := StrReplace(String, "``b", "`b")	;https://www.autohotkey.com/docs/misc/EscapeChar.htm
	String := StrReplace(String, "``t", "`t")	;https://www.autohotkey.com/docs/misc/EscapeChar.htm
	String := StrReplace(String, "``v", "`v")	;https://www.autohotkey.com/docs/misc/EscapeChar.htm
	String := StrReplace(String, "``a", "`a")	;https://www.autohotkey.com/docs/misc/EscapeChar.htm
	String := StrReplace(String, "``f", "`f")	;https://www.autohotkey.com/docs/misc/EscapeChar.htm
	return String
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

F_PrepareUndo(string)
{	;this function replaces from hotstring definition all characters which aren't necessary to undo last hotstring
	;if (InStr(string, "BackSpace")) or InStr(string, "BS")
		string := RegExReplace(string, "Ui)({Backspace.*})|({BS.*})")
	if (InStr(string, "{!}")) or (InStr(string, "{^}")) or (InStr(string, "{+}")) or (InStr(string, "{#}")) or (InStr(string, "{{}")) or (InStr(string, "{}}"))
		string := RegExReplace(string, "U)({)|(})")
	if (InStr(string, "Shift", false))
		string := RegExReplace(string, "i){Shift.*?}")
	return string
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_HOF_SE(ReplacementString, Oflag)	;Hotstring Output Function _ SendEvent
{
	global	;assume-global mode
	local	ThisHotkey := A_ThisHotkey
	
	v_InputString := ""
	v_UndoHotstring := ReplacementString
	ReplacementString := F_ReplaceAHKconstants(ReplacementString)
	if (Oflag = false)
		SendEvent, % ReplacementString . A_EndChar
	else
		SendEvent, % ReplacementString
	
	v_TypedTriggerstring := ThisHotkey 
	v_HotstringFlag := true
	v_LOF := "SE"
	F_EventSigOrdHotstring()
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_HOF_SP(ReplacementString, Oflag)	;Hotstring Output Function _ SendPlay
{
	global	;assume-global mode
	local	ThisHotkey := A_ThisHotkey
	
	v_InputString := ""
	v_UndoHotstring := ReplacementString
	ReplacementString := F_ReplaceAHKconstants(ReplacementString)
	if (Oflag = false)
		SendPlay, % ReplacementString . A_EndChar
	else
		SendPlay, % ReplacementString
	
	v_TypedTriggerstring := ThisHotkey 
	v_HotstringFlag := true
	v_LOF := "SP"
	F_EventSigOrdHotstring()
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_HOF_SR(ReplacementString, Oflag)	;Hotstring Output Function _ SendRaw
{
	global	;assume-global mode
	local	ThisHotkey := A_ThisHotkey
	
	v_InputString := ""
	v_UndoHotstring := ReplacementString
	ReplacementString := F_ReplaceAHKconstants(ReplacementString)
	if (Oflag = false)
		SendRaw, % ReplacementString . A_EndChar
	else
		SendRaw, % ReplacementString
	
	v_TypedTriggerstring := ThisHotkey 
	v_HotstringFlag := true
	v_LOF := "SR"
	F_EventSigOrdHotstring()
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_HOF_SI(ReplacementString, Oflag)	;Hotstring Output Function _ SendInput
{
	global	;assume-global mode
	local	ThisHotkey := A_ThisHotkey, vFirstLetter1 := "", vFirstLetter2 := "", vOutputVar := "", NewReplacementString := "", vRestOfLetters := "", fRestOfLettersCap := false, fFirstLetterCap := false
	
	v_UndoHotstring := ReplacementString
	v_TypedTriggerstring := ThisHotkey 
	v_HotstringFlag := true
	v_LOF := "SI"	;last (active) Output Function; this variable stores information about output function. it's used by F_Undo to correctly interpret special text strings, e.g. {Enter}
	ReplacementString := F_ReplaceAHKconstants(ReplacementString)
	if (!InStr(ThisHotkey, "C"))	
	{
		vFirstLetter1 		:= SubStr(v_InputString, 1, 1)
		vRestOfLetters 	:= SubStr(v_InputString, 2)
		if vFirstLetter1 is upper
			fFirstLetterCap 	:= true
		if vRestOfLetters is upper
			fRestOfLettersCap 	:= true
		if (fFirstLetterCap and fRestOfLettersCap)
		{
			StringUpper, NewReplacementString, ReplacementString
			if (Oflag = false)
			{
				SendInput, % NewReplacementString . A_EndChar
				F_EventSigOrdHotstring()
				v_InputString := ""
				return
			}
			else
			{
				SendInput, % NewReplacementString
				F_EventSigOrdHotstring()
				v_InputString := ""
				return
			}
		}
		if (fFirstLetterCap and !fRestOfLettersCap)
		{
			vFirstLetter2 := SubStr(ReplacementString, 1, 1)
			StringUpper, vFirstLetter2, vFirstLetter2
			NewReplacementString := vFirstLetter2 . SubStr(ReplacementString, 2)
			if (Oflag = false)
			{
				SendInput, % NewReplacementString . A_EndChar
				F_EventSigOrdHotstring()
				v_InputString := ""
				return
			}
			else
			{
				SendInput, % NewReplacementString
				F_EventSigOrdHotstring()
				v_InputString := ""
				return
			}
		}
		if (!fFirstLetterCap)
		{
			if (Oflag = false)
			{
				SendInput, % ReplacementString . A_EndChar
				F_EventSigOrdHotstring()
				v_InputString := ""
				return
			}
			else
			{
				SendInput, % ReplacementString
				F_EventSigOrdHotstring()
				v_InputString := ""
				return
			}
		}
	}
	if (InStr(ThisHotkey, "C") or InStr(ThisHotkey, "C1"))	;tu jestem
	{
		if (Oflag = false)
		{
			SendInput, % ReplacementString . A_EndChar
			F_EventSigOrdHotstring()
			v_InputString := ""
			return
		}
		else
		{
			SendInput, % ReplacementString
			F_EventSigOrdHotstring()
			v_InputString := ""
			return
		}
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_HOF_CLI(ReplacementString, Oflag) ;Hotstring Output Function _ Clipboard
{
	global	;assume-global mode
	local oWord := "", ThisHotkey := A_ThisHotkey
	
	v_InputString := ""
	ToolTip,
	v_UndoHotstring := ReplacementString
	ReplacementString := F_ReplaceAHKconstants(ReplacementString)
	ClipboardBackup := ClipboardAll
	Clipboard := ReplacementString
	ClipWait
	ifWinActive,, "Microsoft Word"	;future: is it still necessary?
	{
		oWord := ComObjActive("Word.Application")
		oWord.Selection.Paste
		oWord := ""
	}
	else
		Send, ^v
	
	if (Oflag == 0)
		Send, % A_EndChar
	Sleep, %ini_CPDelay% ; this sleep is required surprisingly
	Clipboard := ClipboardBackup
	ClipboardBackup := ""
	v_TypedTriggerstring := ThisHotkey
	v_HotstringFlag := true
	F_EventSigOrdHotstring()
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_HOF_MCLI(TextOptions, Oflag)
{
	global	;assume-global mode
	local	MenuX	 := 0,	MenuY  	:= 0,	v_MouseX  := 0,	v_MouseY	:= 0
			,Window2X  := 0,	Window2Y  := 0,	Window2W  := 0,	Window2H  := 0
			,Window1X  := 0,	Window1Y  := 0,	Window1W  := 0,	Window1H  := 0
	
	v_TypedTriggerstring	:= A_ThisHotkey
	if (ini_MHSEn)		;Second beep on purpose
	{
		SoundBeep, % ini_MHSF, % ini_MHSD
		SoundBeep, % ini_MHSF, % ini_MHSD
	}
	
	v_MenuMax			 	:= 0
	TextOptions 		 := F_ReplaceAHKconstants(TextOptions)
	Loop, Parse, TextOptions, ¦
		v_MenuMax := A_Index
	ToolTip,
	Gui, HMenuCli: New, +AlwaysOnTop -Caption +ToolWindow +HwndHMenuCliHwnd
	Gui, HMenuCli: Margin, 0, 0
	if (ini_HMBgrCol = "custom")
		Gui, HMenuCli: Color,, % ini_HMBgrColCus
	else
		Gui, HMenuCli: Color,, % ini_HMBgrCol
	if (ini_HMTyFaceCol = "custom")
		Gui, HMenuCli: Font, % "s" . ini_HMTySize . A_Space . "c" . ini_HMTyFaceColCus, % ini_HMTyFaceFont
	else
		Gui, HMenuCli: Font, % "s" . ini_HMTySize . A_Space . "c" . ini_HMTyFaceCol, % ini_HMTyFaceFont
	Gui, HMenuCli: Add, Listbox, % "x0 y0 w250 HwndId_LB_HMenuCli" . A_Space . "r" . v_MenuMax . A_Space . "g" . "F_MouseMenuCli"
	Loop, Parse, TextOptions, ¦
		GuiControl,, % Id_LB_HMenuCli, % A_Index . ". " . A_LoopField . "|"
	
	if (ini_MHMP = 1)
	{
		if (A_CaretX and A_CaretY)
		{
			MenuX := A_CaretX + 20
			MenuY := A_CaretY - 20
		}
		else
		{
			MouseGetPos, v_MouseX, v_MouseY
			MenuX := v_MouseX + 20
			MenuY := v_MouseY + 20
		}
	}
	if (ini_MHMP = 2)
	{
		MouseGetPos, v_MouseX, v_MouseY
		MenuX := v_MouseX + 20
		MenuY := v_MouseY + 20
	}
	Gui, HMenuCli: Show, x%MenuX% y%MenuY% NoActivate Hide
	DetectHiddenWindows, On
	WinGetPos, Window2X, Window2Y, Window2W, Window2H, % "ahk_id" . HMenuCliHwnd
	DetectHiddenWindows, Off
	
	Loop % MonitorCoordinates.Count()
		if ((MenuX >= MonitorCoordinates[A_Index].Left) and (MenuX <= MonitorCoordinates[A_Index].Right))
		{
			Window1X := MonitorCoordinates[A_Index].Left
			Window1H := MonitorCoordinates[A_Index].Height
			Window1Y := MonitorCoordinates[A_Index].Top 
			Window1W := MonitorCoordinates[A_Index].Width
			Break
		}
	if (MenuY + Window2H > Window1Y + Window1H) ;bottom edge of a screen 
		MenuY -= Window2H
	if (MenuX + Window2W > Window1X + Window1W) ;right edge of a screen
		MenuX -= Window2W
	Gui, HMenuCli: Show, x%MenuX% y%MenuY% NoActivate
	GuiControl, Choose, % Id_LB_HMenuCli, 1
	Ovar := Oflag
	v_HotstringFlag := true
	
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_MouseMenuCli() ;The subroutine may consult the following built-in variables: A_Gui, A_GuiControl, A_GuiEvent, and A_EventInfo.
{
	global	;assume-global mode
	local	OutputVarTemp := "",	MouseCtl := 0,		ThisHotkey := A_ThisHotkey
	
	MouseGetPos, , , , MouseCtl, 2
	if ((A_GuiEvent = "Normal") and (MouseCtl = Id_LB_HMenuCli) and !(InStr(ThisHotkey, "Up")) and !(InStr(ThisHotkey, "Down"))) ;only Basic mouse left click
	{
		GuiControlGet, OutputVarTemp, , % Id_LB_HMenuCli 
		v_HotstringFlag := true
		ClipboardBack := ClipboardAll ;backup clipboard
		OutputVarTemp := SubStr(OutputVarTemp, 4)
		Gui, HMenuCli: Destroy
		Clipboard := OutputvarTemp 
		Send, ^v ;paste the text
		if (Ovar = false)
			Send, % A_EndChar
		Sleep, %ini_CPDelay% ;Remember to sleep before restoring clipboard or it will fail
		F_EventSigOrdHotstring()
		v_TypedTriggerstring := OutputVarTemp
		v_UndoHotstring 	 := OutputVarTemp
		Clipboard 		 := ClipboardBack
		;Hotstring("Reset") ;mouse click resets hotstring recognizer anyway
	}
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_GuiTrigTipsMenuDef(AmountOfRows, LongestString)
{
	global	;assume-global mode
	local vOutput := 0, vOutputX := 0, vOutputY := 0, vOutputW := 0, vOutputH := 0, OutputString := ""
	
	Loop, Parse, LongestString	;exchange all letters into "w" which is the widest letter in latin alphabet (the worst case scenario)
		OutputString .= "w"		;the widest ordinary letter in alphabet
	Gui, TMenuAHK: New, +AlwaysOnTop -Caption +ToolWindow +HwndTMenuAHKHwnd
	Gui, TMenuAHK: Margin, 0, 0
	if (ini_TTBgrCol = "custom")
		Gui, TMenuAHK: Color,, % ini_TTBgrColCus	;background of listbox
	else
		Gui, TMenuAHK: Color,, % ini_TTBgrCol	;background of listbox
	if (ini_TTTyFaceCol = "custom")		
		Gui, TMenuAHK: Font, % "s" . ini_TTTySize . A_Space . "c" . ini_TTTyFaceColCus, % ini_TTTyFaceFont
	else
		Gui, TMenuAHK: Font, % "s" . ini_TTTySize . A_Space . "c" . ini_TTTyFaceCol, % ini_TTTyFaceFont
	Gui, TMenuAHK: Add, Text, % "x0 y0 HwndId_T1_TMenuAHK", % OutputString
	GuiControlGet, vOutput, Pos, % Id_T1_TMenuAHK
	Gui, TMenuAHK: Add, Listbox, % "x0 y0 HwndId_LB_TMenuAHK" . A_Space . "r" . AmountOfRows . A_Space . "w" . vOutputW + 4
	GuiControl, Hide, % Id_T1_TMenuAHK
	GuiControl, Font, % Id_LB_TMenuAHK		;fontcolor of listbox
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_HOF_MSI(TextOptions, Oflag)	
{
	global	;assume-global mode
	local	MenuX	 := 0,	MenuY  	:= 0,	v_MouseX  := 0,	v_MouseY	:= 0
			,Window2X  := 0,	Window2Y  := 0,	Window2W  := 0,	Window2H  := 0
			,Window1X  := 0,	Window1Y  := 0,	Window1W  := 0,	Window1H  := 0
	
	v_TypedTriggerstring	:= A_ThisHotkey
	if (ini_MHSEn)		;Second beep on purpose
		SoundBeep, % ini_MHSF, % ini_MHSD
	
	v_MenuMax				:= 0
	TextOptions 			:= F_ReplaceAHKconstants(TextOptions)
	Loop, Parse, TextOptions, ¦
		v_MenuMax := A_Index
	ToolTip,
	Gui, HMenuAHK: New, +AlwaysOnTop -Caption +ToolWindow +HwndHMenuAHKHwnd
	Gui, HMenuAHK: Margin, 0, 0
	if (ini_HMBgrCol = "custom")	;Tooltip font color: c766D69
		Gui, HMenuAHK: Color,, % ini_HMBgrColCus
	else
		Gui, HMenuAHK: Color,, % ini_HMBgrCol
	if (ini_HMTyFaceCol = "custom")
		Gui, HMenuAHK: Font, % "s" . ini_HMTySize . A_Space . "c" . ini_HMTyFaceColCus, % ini_HMTyFaceFont
	else
		Gui, HMenuAHK: Font, % "s" . ini_HMTySize . A_Space . "c" . ini_HMTyFaceCol, % ini_HMTyFaceFont
	Gui, HMenuAHK: Add, Listbox, % "x0 y0 w250 HwndId_LB_HMenuAHK" . A_Space . "r" . v_MenuMax . A_Space . "g" . "F_MouseMenuAHK"
	Loop, Parse, TextOptions, ¦
		GuiControl,, % Id_LB_HMenuAHK, % A_Index . ". " . A_LoopField . "|"
	
	if (ini_MHMP = 1)
	{
		if (A_CaretX and A_CaretY)
		{
			MenuX := A_CaretX + 20
			MenuY := A_CaretY - 20
		}
		else
		{
			MouseGetPos, v_MouseX, v_MouseY
			MenuX := v_MouseX + 20
			MenuY := v_MouseY + 20
		}
	}
	if (ini_MHMP = 2) 
	{
		MouseGetPos, v_MouseX, v_MouseY
		MenuX := v_MouseX + 20
		MenuY := v_MouseY + 20
	}
	
	Gui, HMenuAHK: Show, x%MenuX% y%MenuY% NoActivate Hide
	DetectHiddenWindows, On
	WinGetPos, Window2X, Window2Y, Window2W, Window2H, % "ahk_id" . HMenuAHKHwnd
	DetectHiddenWindows, Off
	
	Loop % MonitorCoordinates.Count()
		if ((MenuX >= MonitorCoordinates[A_Index].Left) and (MenuX <= MonitorCoordinates[A_Index].Right))
		{
			Window1X := MonitorCoordinates[A_Index].Left
			Window1H := MonitorCoordinates[A_Index].Height
			Window1Y := MonitorCoordinates[A_Index].Top 
			Window1W := MonitorCoordinates[A_Index].Width
			Break
		}
	if (MenuY + Window2H > Window1Y + Window1H) ;bottom edge of a screen 
		MenuY -= Window2H
	if (MenuX + Window2W > Window1X + Window1W) ;right edge of a screen
		MenuX -= Window2W
	Gui, HMenuAHK: Show, x%MenuX% y%MenuY% NoActivate	
	
	GuiControl, Choose, % Id_LB_HMenuAHK, 1
	Ovar := Oflag
	v_HotstringFlag := true
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_MouseMenuAHK() ;The subroutine may consult the following built-in variables: A_Gui, A_GuiControl, A_GuiEvent, and A_EventInfo.
{
	global	;assume-global mode
	local	OutputVarTemp := "",	MouseCtl := 0,		ThisHotkey := A_ThisHotkey
	
	MouseGetPos, , , , MouseCtl, 2
	if ((A_GuiEvent = "Normal") and (MouseCtl = Id_LB_HMenuAHK) and !(InStr(ThisHotkey, "Up")) and !(InStr(ThisHotkey, "Down"))) ;only Basic mouse left click
	{
		GuiControlGet, OutputVarTemp, , % Id_LB_HMenuAHK 
		v_HotstringFlag := true
		OutputVarTemp := SubStr(OutputVarTemp, 4)
		Gui, HMenuAHK: Destroy
		Send, % OutputVarTemp
		if (Ovar = false)
			Send, % A_EndChar
		F_EventSigOrdHotstring()
		v_TypedTriggerstring := OutputVarTemp
		v_UndoHotstring 	 := OutputVarTemp
	}
	return
}

;Future: move this section of code to Hotkeys
#if WinExist("ahk_id" HMenuAHKHwnd)
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

F_HMenuAHK()
{
	global	;assume-global moee
	local	v_PressedKey := "",		v_Temp1 := ""
	static 	IfUpF := false,	IfDownF := false, IsCursorPressed := false, IntCnt := 1, ShiftTabIsFound := false
	
	v_PressedKey := A_ThisHotkey
	if (InStr(v_PressedKey, "+Tab"))	;the same as "up"
	{
		IsCursorPressed := true
		IntCnt--
		ControlSend, , {Up}, % "ahk_id" Id_LB_TMenuAHK
		ShiftTabIsFound := true
	}
	if (InStr(v_PressedKey, "Tab")) and (!ShiftTabIsFound)	;the same as "down"
	{
		IsCursorPressed := true
		IntCnt++
		ControlSend, , {Down}, % "ahk_id" Id_LB_TMenuAHK
	}
	if (InStr(v_PressedKey, "Up"))
	{
		IsCursorPressed := true
		IntCnt--
		ControlSend, , {Up}, % "ahk_id" Id_LB_HMenuAHK
	}
	if (InStr(v_PressedKey, "Down"))
	{
		IsCursorPressed := true
		IntCnt++
		ControlSend, , {Down}, % "ahk_id" Id_LB_HMenuAHK
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
	if (InStr(v_PressedKey, "Enter"))
	{
		v_PressedKey := IntCnt
		IsCursorPressed := false
		IntCnt := 1
	}
	if (v_PressedKey > v_MenuMax)
	{
		return
	}
	v_HotstringFlag := true
	ControlGet, v_Temp1, List, , , % "ahk_id" Id_LB_HMenuAHK
	Loop, Parse, v_Temp1, `n
	{
		if (InStr(A_LoopField, v_PressedKey . "."))
			v_Temp1 := SubStr(A_LoopField, 4)
	}
	Send, % v_Temp1 
	if (Ovar = false)
		Send, % A_EndChar
	v_UndoHotstring 	 := v_Temp1
	Hotstring("Reset")
	Gui, HMenuAHK: Destroy
	F_EventSigOrdHotstring()
	return
}

Esc::
Gui, HMenuAHK: Destroy
Send, % SubStr(v_TypedTriggerstring, InStr(v_TypedTriggerstring, ":", false, 1, 2) + 1)
v_InputString := ""	;I'm not sure if this line is necessary anymore
return
#If

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

F_LoadEndChars() ;Load from Config.ini 
{
	global	;assume-global mode
	local	vOutputVarSection := "", key := "", val := "", tick := false, LastKey := ""
	
	HotstringEndChars 	:= ""
	a_HotstringEndChars := {}
	
	IniRead, vOutputVarSection, % HADConfig, EndChars
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
	return	
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	/*
		F_SortArrayAlphabetically(a_array)
		{
			local a_TempArray, v_ActualArray, v_TempArray, flag, cnt, no
			a_TempArray := []
			Loop, % a_array.MaxIndex()
			{
				cnt := A_Index
				a_TempArray[cnt] := a_array[cnt]
				Loop, % cnt - 1
				{
					If (Asc(a_array[cnt]) < Asc(a_TempArray[A_Index]))
					{
						Loop, % cnt - A_Index
						{
							a_TempArray[cnt - (A_Index - 1)] := a_TempArray[cnt - A_Index]
						}
						a_TempArray[A_Index] := a_array[cnt]
						break
					}
					else if (Asc(a_array[cnt]) == Asc(a_TempArray[A_Index]))
					{
						flag := 0
						no := A_Index
						v_ActualArray := a_array[cnt]
						v_TempArray := a_TempArray[no]
						Loop, % Max(StrLen(v_ActualArray), StrLen(v_TempArray))
						{
							v_ActualArray := SubStr(v_ActualArray, 2)
							v_TempArray := SubStr(v_TempArray, 2)
							If (Asc(v_ActualArray) < Asc(v_TempArray))
							{
								Loop, % cnt - no
								{
									a_TempArray[cnt - A_Index + 1] := a_TempArray[cnt - A_Index]
								}
								a_TempArray[no] := a_array[cnt]
								flag := 1
								Break
							}
							else if (Asc(v_ActualArray) > Asc(v_TempArray)22)
							{
								Break
							}
						}
						if (flag)
							Break
					}
				}
			}
			return a_TempArray
		}
*/
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_SortArrayByLength(a_array)
{
	local a_TempArray, v_Length, v_ActLen
	a_TempArray := []
	v_Length := 0
	Loop, % a_array.MaxIndex()
	{
		v_Length := Max(StrLen(a_array[A_Index]),v_Length)
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
;Future: omit commented lines of a imported script
{
	global	;assume-global mode
	local IdImport_P1 := 0, IdImport_T1 := 0
	,HS3GuiWinX := 0, HS3GuiWinY := 0, HS3GuiWinW := 0, HS3GuiWinH := 0
	,ImportGuiWinW := 0, ImportGuiWinH := 0
	,v_OutputFile := "", OutNameNoExt := ""
	,v_TotalLines := 0, line := "", v_Progress := 0
	,a_Hotstring := [], v_Options := "", v_Trigger := "", v_Hotstring := ""
	,v_TheWholeFile := ""
	,v_OutVarTemp := 0, 	v_OutVarTempX := 0, 	v_OutVarTempY := 0, 	v_OutVarTempW := 0, 	v_OutVarTempH := 0
	,v_xNext := 0, 		v_yNext := 0, 			v_wNext := 0, 			v_hNext := 0
	,NewStr := "", v_LibraryName := ""
	,key := "", value := 0, f_ExistedLib := false, BegCom := false
	
	FileSelectFile, v_LibraryName, 3, %A_ScriptDir%, % TransA["Choose (.ahk) file containing (triggerstring, hotstring) definitions for import"], AutoHotkey (*.ahk)
	if (!v_LibraryName)
		return
	SplitPath, v_LibraryName, ,,, OutNameNoExt
	v_OutputFile := % HADL . "\" . OutNameNoExt . ".csv"
	
	if (FileExist(v_OutputFile))
	{
		MsgBox, 52, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["warning"], % TransA["Such file already exists"] . ":" . "`n`n" . v_OutputFile . "`n`n" . TransA["Do you want to delete it?"] . "`n`n" 
			. TransA["If you answer ""Yes"", the existing file will be deleted. This is recommended choice. If you answer ""No"", new content will be added to existing file."]
		IfMsgBox, Yes	;check if it was loaded. if yes, recommend restart of application, because "Total" counter and Hotstrings definitions will be incredible. 
		{
			for key, value in ini_LoadLib
				if (key = OutNameNoExt)
					f_ExistedLib := true
			FileDelete, % v_OutputFile
		}
	}
	
	NewStr := RegExReplace(TransA["Import from .ahk to .csv"], "&", "")
	
	Gui, Import: New, 	+Border -Resize -MaximizeBox -MinimizeBox +HwndImportGuiHwnd +Owner +OwnDialogs, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . NewStr
	Gui, Import: Margin,	% c_xmarg, % c_ymarg
	Gui,	Import: Color,	% c_WindowColor, % c_ControlColor
	Gui,	Import: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, 					% c_FontType
	
	Gui, Import: Add, Text,		x0 y0 HwndIdImport_T1, % TransA["Conversion of .ahk file into new .csv file (library) and loading of that new library"]
	Gui, Import: Add, Progress, 	x0 y0 HwndIdImport_P1 cBlue, 0
	Gui, Import: Add, Text, 		x0 y0 HwndIdImport_T2, % TransA["Converted"] . A_Space . v_Progress . A_Space . TransA["of"] . A_Space . v_TotalLines . A_Space . TransA["(triggerstring, hotstring) definitions"]
		. A_Space . "(" . v_Progress . A_Space . "%" . ")"
	
	GuiControlGet, v_OutVarTemp, Pos, % IdImport_T1
	v_xNext := c_xmarg
	v_yNext := c_ymarg
	GuiControl, Move, % IdImport_T1, % "x" v_xNext . A_Space . "y" v_yNext
;Gui, Import: Show, Center AutoSize
	v_yNext += HofText + c_ymarg
	GuiControl, Move, % IdImport_T2, % "x" v_xNext . A_Space . "y" v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdImport_T2
	v_wNext := v_OutVarTempW
	v_hNext := HofText
	GuiControl, Move, % IdImport_P1, % "x" v_xNext . A_Space . "y" v_yNext . A_Space . "w" v_wNext . A_Space . "h" . v_hNext
	v_yNext += HofText + c_ymarg
	GuiControl, Move, % IdImport_T2, % "x" v_xNext . A_Space . "y" v_yNext
;Gui, Import: Show, Center AutoSize
	Gui, Import: Show, Hide
	
	F_WhichGui()
	Switch A_DefaultGui
	{
		Case "HS3": WinGetPos, HS3GuiWinX, HS3GuiWinY, HS3GuiWinW, HS3GuiWinH, % "ahk_id" . HS3GuiHwnd
		Case "HS4": WinGetPos, HS3GuiWinX, HS3GuiWinY, HS3GuiWinW, HS3GuiWinH, % "ahk_id" . HS4GuiHwnd 
	}
	DetectHiddenWindows, On
	WinGetPos, , , ImportGuiWinW, ImportGuiWinH, % "ahk_id" . ImportGuiHwnd
	DetectHiddenWindows, Off
	Gui, % A_DefaultGui . ":" . A_Space . "+Disabled"
	Gui, Import: Show, % "x" . HS3GuiWinX + (HS3GuiWinW - ImportGuiWinW) / 2 . A_Space . "y" . HS3GuiWinY + (HS3GuiWinH - ImportGuiWinH) / 2 . A_Space . "AutoSize"
	
	FileRead, v_TheWholeFile, % v_LibraryName
	v_TotalLines := F_HowManyLines(v_TheWholeFile)
	
	if (v_TotalLines = 0)
	{
		MsgBox, 48, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["warning"], % TransA["The selected file is empty. Process of import will be interrupted."]
		return
	}
	if (A_DefaultGui = "HS4") ;in order to have access to ListView even when HS4 is active, temporarily default gui is switched to HS3.
		Gui, HS3: Default
	GuiControl, % "Count" . v_TotalLines . A_Space . "-Redraw", % IdListView1 ;This option serves as a hint to the control that allows it to allocate memory only once rather than each time a row is added, which greatly improves row-adding performance (it may also improve sorting performance). 
	LV_Delete()
	
	BegCom := false
	Loop, Parse, v_TheWholeFile, `n, `r%A_Space%%A_Tab%
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
				Case 2: v_Options := A_LoopField
				Case 3: v_Trigger := A_LoopField
				Case 5: v_Hotstring := A_LoopField
			}
		}
		LV_Add("", v_Options, v_Trigger, v_Hotstring)
		v_Progress := Round((A_Index / v_TotalLines) * 100)
		GuiControl,, % IdImport_T2, % TransA["Converted"] . A_Space . A_Index . A_Space . TransA["of"] . A_Space . v_TotalLines . A_Space . TransA["(triggerstring, hotstring) definitions"]
			. A_Space . "(" . v_Progress . A_Space . "%" . ")"
		GuiControl,, % IdImport_P1, % v_Progress
	}
	LV_ModifyCol(2, "Sort")
	v_TheWholeFile := ""
	GuiControl,, % IdImport_T1, % TransA["Saving of sorted content into .csv file (library)"]
	Loop, % LV_GetCount()
	{
		LV_GetText(v_Options, 	A_Index, 1)
		LV_GetText(v_Trigger, 	A_Index, 2)
		LV_GetText(v_Hotstring, 	A_Index, 3)
		line := v_Options . "‖" . v_Trigger . "‖SI‖En‖" . v_Hotstring . "‖"
		v_TheWholeFile .= line . "`n"
		v_Progress := Round((A_Index / v_TotalLines) * 100)
		GuiControl,, % IdImport_P1, % v_Progress
		GuiControl,, % IdImport_T2, % TransA["Saved"] . A_Space . A_Index . A_Space . TransA["of"] . A_Space . v_TotalLines . A_Space . TransA["(triggerstring, hotstring) definitions"]
		. A_Space . "(" . v_Progress . A_Space . "%" . ")"
	}	
	FileAppend, % v_TheWholeFile, % v_OutputFile, UTF-8
	
	LV_Delete()
	GuiControl, +Redraw, % IdListView1 ;Afterward, use GuiControl, +Redraw to re-enable redrawing (which also repaints the control).
	if (A_DefaultGui = "HS3")
		Gui, HS4: Default
	Gui, % A_DefaultGui . ":" . A_Space . "-Disabled"
	Gui, Import: Destroy
	
	MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["Library has been imported."]
	if (f_ExistedLib)
	{
		MsgBox, , 48, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["warning"], TransA["The already imported file already existed. As a consequence some (triggerstring, hotstring) definitions could also exist and ""Total"" could be incredible. Therefore application will be now restarted in order to correctly apply the changes."]
		F_SaveGUIPos()
		ini_GuiReload := true
		IniWrite, % ini_GuiReload,		% HADConfig, GraphicalUserInterface, GuiReload
		Reload
	}
	else	
	{
		F_ValidateIniLibSections()
		F_RefreshListOfLibraries()
		F_RefreshListOfLibraryTips()
		F_UpdateSelHotLibDDL()
		F_LoadFile(OutNameNoExt . ".csv")
		F_Searching("Reload")
	}
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_HowManyLines(v_TheWholeFile) ;how many not empty lines, not commented out, contains a file
{
	local BegCom := false
	
	Loop, Parse, v_TheWholeFile, `n, `r%A_Space%%A_Tab%
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
		v_TotalLines++
	}
	return v_TotalLines
}	
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_ExportLibraryStatic()
{
	global	;assume-global mode
	local	v_LibraryName := "", v_Progress := "100", v_TotalLines := "0000"
		,v_OutVarTemp := 0, v_OutVarTempX := 0, v_OutVarTempY := 0, v_OutVarTempW := 0, v_OutVarTempH := 0
		,HS3GuiWinX := 0, HS3GuiWinY := 0, HS3GuiWinW := 0, HS3GuiWinH := 0, ExportGuiWinW := 0, ExportGuiWinH := 0
		,OutFileName := "", OutNameNoExt := "", v_LibrariesDir := "", v_OutputFile := "", v_TheWholeFile := "", line := ""
		,v_Options := "", v_Trigger := "", v_Function := "", v_EnDis := "", v_Hotstring := "", v_Comment := "", a_MenuHotstring := []
		,v_Header := "
(
; This file is result of export from Hotstrings.ahk application (https://github.com/mslonik/Hotstrings).
#SingleInstance force 			; Only one instance of this script may run at a time!
#NoEnv  						; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  						; Enable warnings to assist with detection of common errors.
SendMode Input  				; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%		; Ensures a consistent starting directory.
FileEncoding, UTF-8		 		; Sets the default encoding for FileRead, FileReadLine, Loop Read, FileAppend, and FileOpen(). Unicode UTF-16, little endian byte order (BMP of ISO 10646). Useful for .ini files which by default are coded as UTF-16. https://docs.microsoft.com/pl-pl/windows/win32/intl/code-page-identifiers?redirectedfrom=MSDN
)"
	
	FileSelectFile, v_LibraryName, 3, % HADL . "\", % TransA["Choose library file (.csv) for export"], CSV Files (*.csv)]
	if (!v_LibraryName)
		return
	
	SplitPath, v_LibraryName, OutFileName, , , OutNameNoExt
	v_LibrariesDir := % HADL . "\ExportedLibraries"
	if !InStr(FileExist(v_LibrariesDir),"D")
		FileCreateDir, %v_LibrariesDir%
	v_OutputFile := % HADL . "\ExportedLibraries\" . OutNameNoExt . "." . "ahk"
	
	if (FileExist(v_OutputFile))
	{
		MsgBox, 52, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["warning"], % TransA["Such file already exists"] . ":" . "`n`n" . v_OutputFile . "`n`n" . TransA["Do you want to delete it?"] . "`n`n" 
		. TransA["If you answer ""Yes"", the existing file will be deleted. If you answer ""No"", the current task will be continued and new content will be added to existing file."]
		IfMsgBox, Yes
			FileDelete, % v_OutputFile
	}	
	
	Gui, Export: New, 		+Border -Resize -MaximizeBox -MinimizeBox +HwndExportGuiHwnd +Owner +OwnDialogs, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["Export to .ahk with static definitions of hotstrings"] 
	Gui, Export: Margin,	% c_xmarg, % c_ymarg
	Gui,	Export: Color,		% c_WindowColor, % c_ControlColor
	Gui,	Export: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, 					% c_FontType	
	
	Gui, Export: Add, Text,		x0 y0 HwndIdExport_T1, TransA["Conversion of .csv library file into new .ahk file containing static (triggerstring, hotstring) definitions"]
	Gui, Export: Add, Progress, 	x0 y0 HwndIdExport_P1 cBlue, 0
	Gui, Export: Add, Text, 		x0 y0 HwndIdExport_T2, % TransA["Exported"] . A_Space . v_TotalLines . A_Space . TransA["of"] . A_Space . v_TotalLines . A_Space . TransA["(triggerstring, hotstring) definitions"]
		. A_Space . "(" . v_Progress . A_Space . "%" . ")"
	
	GuiControlGet, v_OutVarTemp, Pos, % IdExport_T1
	v_xNext := c_xmarg
	v_yNext := c_ymarg
	GuiControl, Move, % IdExport_T1, % "x" v_xNext . A_Space . "y" v_yNext
	;Gui, Export: Show, Center AutoSize
	v_yNext += HofText + c_ymarg
	GuiControl, Move, % IdExport_T2, % "x" v_xNext . A_Space . "y" v_yNext
	;Gui, Export: Show, Center AutoSize
	GuiControlGet, v_OutVarTemp, Pos, % IdExport_T2
	v_wNext := v_OutVarTempW
	v_hNext := HofText
	GuiControl, Move, % IdExport_P1, % "x" v_xNext . A_Space . "y" v_yNext . A_Space . "w" v_wNext . A_Space . "h" . v_hNext
	v_yNext += HofText + c_ymarg
	GuiControl, Move, % IdExport_T2, % "x" v_xNext . A_Space . "y" v_yNext
	;Gui, Export: Show, Center AutoSize
	v_Progress   := 0
	v_TotalLines := 0
	GuiControl,, % IdExport_T2, % TransA["Exported"] . A_Space . v_TotalLines . A_Space . TransA["of"] . A_Space . v_TotalLines . A_Space . TransA["(triggerstring, hotstring) definitions"] . A_Space . "(" . v_Progress . A_Space . "%" . ")"
	;Gui, Export: Show, Center AutoSize	
	Gui, Export: Show, Hide
	
	F_WhichGui()
	Switch A_DefaultGui
	{
		Case "HS3": WinGetPos, HS3GuiWinX, HS3GuiWinY, HS3GuiWinW, HS3GuiWinH, % "ahk_id" . HS3GuiHwnd
		Case "HS4": WinGetPos, HS3GuiWinX, HS3GuiWinY, HS3GuiWinW, HS3GuiWinH, % "ahk_id" . HS4GuiHwnd 
	}
	DetectHiddenWindows, On
	WinGetPos, , , ExportGuiWinW, ExportGuiWinH, % "ahk_id" . ExportGuiHwnd
	DetectHiddenWindows, Off
	Gui, Export: Show, % "x" . HS3GuiWinX + (HS3GuiWinW - ExportGuiWinW) / 2 . A_Space . "y" . HS3GuiWinY + (HS3GuiWinH - ExportGuiWinH) / 2 . A_Space . "AutoSize"
	Gui, % A_DefaultGui . ":" . A_Space . "+Disabled"
	
	FileRead, v_TheWholeFile, % v_LibraryName
	v_TotalLines := F_HowManyLines(v_TheWholeFile)
	
	if (v_TotalLines = 0)
	{
		MsgBox, 48, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["warning"], % TransA["The selected file is empty. Process of export will be interrupted."]
		return
	}
	line .= v_Header . "`n`n"
	Loop, Parse, v_TheWholeFile, `n, `r%A_Space%%A_Tab%
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
		
		Loop, Parse, A_LoopField, ‖, %A_Space%%A_Tab%
		{
			Switch A_Index
			{
				Case 1: v_Options 	:= A_LoopField
				Case 2: v_Trigger 	:= A_LoopField
				Case 3: v_Function 	:= A_LoopField
				Case 4: v_EnDis 	:= A_LoopField
				Case 5: v_Hotstring := A_LoopField
				Case 6: v_Comment 	:= A_LoopField
			}
		}
		if (v_EnDis = "Dis")
		{
			line .= ";" . A_Space
		}
		if (InStr(v_Function, "M"))
		{
			a_MenuHotstring := StrSplit(v_Hotstring,"¦")
			Loop, % a_MenuHotstring.MaxIndex()
			{
				if (A_Index = 1)
				{
					line .= ":" v_Options . ":" . v_Trigger . "::" . a_MenuHotstring[A_Index] . A_Space
					if (v_Comment)
						line .= ";" . v_Comment . A_Space . ";" . TransA["Warning, code generated automatically for definitions based on menu, see documentation of Hotstrings application for further details."]
					else
						line .= ";" . TransA["Warning, code generated automatically for definitions based on menu, see documentation of Hotstrings application for further details."]
					line .= "`n"
				}
				else
				{
					line .=  ";" . A_Space . ":" v_Options . ":" . v_Trigger . "::" . a_MenuHotstring[A_Index] . A_Space 
					if (v_Comment)
						line .= ";" . v_Comment . A_Space . ";" . TransA["Warning, code generated automatically for definitions based on menu, see documentation of Hotstrings application for further details."]
					else
						line .= ";" . TransA["Warning, code generated automatically for definitions based on menu, see documentation of Hotstrings application for further details."]
					line .= "`n"
				}
			}
		}
		else
		{
			line .= ":" . v_Options . ":" . v_Trigger . "::" . v_Hotstring . A_Space
			if (v_Comment)
				line .= ";" . v_Comment
			line .= "`n"
		}
		
		v_Progress := Round((A_Index / v_TotalLines) * 100)
		GuiControl,, % IdExport_T2, % TransA["Exported"] . A_Space . A_Index . A_Space . TransA["of"] . A_Space . v_TotalLines . A_Space . TransA["(triggerstring, hotstring) definitions"]
			. A_Space . "(" . v_Progress . A_Space . "%" . ")"
		GuiControl,, % IdExport_P1, % v_Progress
	}
	FileAppend, % line, % v_OutputFile, UTF-8
	Gui, % A_DefaultGui . ":" . A_Space . "-Disabled"
	Gui, Export: Destroy
	MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["Library has been exported"] . ":" . "`n`n" . v_OutputFile
	return
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_ExportLibraryDynamic()
{
	global	;assume-global mode
	local	v_LibraryName := "", v_Progress := "100", v_TotalLines := "0000"
			,v_OutVarTemp := 0, v_OutVarTempX := 0, v_OutVarTempY := 0, v_OutVarTempW := 0, v_OutVarTempH := 0
			,HS3GuiWinX := 0, HS3GuiWinY := 0, HS3GuiWinW := 0, HS3GuiWinH := 0, ExportGuiWinW := 0, ExportGuiWinH := 0
			,OutFileName := "", OutNameNoExt := "", v_LibrariesDir := "", v_OutputFile := "", v_TheWholeFile := "", line := ""
			,v_Options := "", v_Trigger := "", v_Function := "", v_EnDis := "", v_Hotstring := "", v_Comment := "", a_MenuHotstring := []
			,v_Header := "
(
; This file is result of export from Hotstrings.ahk application (https://github.com/mslonik/Hotstrings).
#SingleInstance force 			; Only one instance of this script may run at a time!
#NoEnv  						; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  						; Enable warnings to assist with detection of common errors.
SendMode Input  				; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%		; Ensures a consistent starting directory.
FileEncoding, UTF-8		 		; Sets the default encoding for FileRead, FileReadLine, Loop Read, FileAppend, and FileOpen(). Unicode UTF-16, little endian byte order (BMP of ISO 10646). Useful for .ini files which by default are coded as UTF-16. https://docs.microsoft.com/pl-pl/windows/win32/intl/code-page-identifiers?redirectedfrom=MSDN
)"
	FileSelectFile, v_LibraryName, 3, % HADL, % TransA["Choose library file (.csv) for export"], CSV Files (*.csv)]
	if (!v_LibraryName)
		return
	
	SplitPath, v_LibraryName, OutFileName, , , OutNameNoExt
	v_LibrariesDir := % HADL . "\ExportedLibraries"
	if !InStr(FileExist(v_LibrariesDir),"D")
		FileCreateDir, %v_LibrariesDir%
	v_OutputFile := % HADL . "\ExportedLibraries\" . OutNameNoExt . "." . "ahk"
	
	if (FileExist(v_OutputFile))
	{
		MsgBox, 52, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["warning"], % TransA["Such file already exists"] . ":" . "`n`n" . v_OutputFile . "`n`n" . TransA["Do you want to delete it?"] . "`n`n" 
			. TransA["If you answer ""Yes"", the existing file will be deleted. If you answer ""No"", the current task will be continued and new content will be added to existing file."]
		IfMsgBox, Yes
			FileDelete, % v_OutputFile
	}	
	
	Gui, Export: New, 		+Border -Resize -MaximizeBox -MinimizeBox +HwndExportGuiHwnd +Owner +OwnDialogs, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["Export to .ahk with dynamic definitions of hotstrings"] 
	Gui, Export: Margin,	% c_xmarg, % c_ymarg
	Gui,	Export: Color,		% c_WindowColor, % c_ControlColor
	Gui,	Export: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, 					% c_FontType	
	
	Gui, Export: Add, Text,		x0 y0 HwndIdExport_T1, TransA["Conversion of .csv library file into new .ahk file containing dynamic (triggerstring, hotstring) definitions"]
	Gui, Export: Add, Progress, 	x0 y0 HwndIdExport_P1 cBlue, 0
	Gui, Export: Add, Text, 		x0 y0 HwndIdExport_T2, % TransA["Exported"] . A_Space . v_TotalLines . A_Space . TransA["of"] . A_Space . v_TotalLines . A_Space . TransA["(triggerstring, hotstring) definitions"]
		. A_Space . "(" . v_Progress . A_Space . "%" . ")"
	
	GuiControlGet, v_OutVarTemp, Pos, % IdExport_T1
	v_xNext := c_xmarg
	v_yNext := c_ymarg
	GuiControl, Move, % IdExport_T1, % "x" v_xNext . A_Space . "y" v_yNext
	;Gui, Export: Show, Center AutoSize
	v_yNext += HofText + c_ymarg
	GuiControl, Move, % IdExport_T2, % "x" v_xNext . A_Space . "y" v_yNext
	;Gui, Export: Show, Center AutoSize
	GuiControlGet, v_OutVarTemp, Pos, % IdExport_T2
	v_wNext := v_OutVarTempW
	v_hNext := HofText
	GuiControl, Move, % IdExport_P1, % "x" v_xNext . A_Space . "y" v_yNext . A_Space . "w" v_wNext . A_Space . "h" . v_hNext
	v_yNext += HofText + c_ymarg
	GuiControl, Move, % IdExport_T2, % "x" v_xNext . A_Space . "y" v_yNext
	;Gui, Export: Show, Center AutoSize
	v_Progress   := 0
	v_TotalLines := 0
	GuiControl,, % IdExport_T2, % TransA["Exported"] . A_Space . v_TotalLines . A_Space . TransA["of"] . A_Space . v_TotalLines . A_Space . TransA["(triggerstring, hotstring) definitions"] . A_Space . "(" . v_Progress . A_Space . "%" . ")"
	;Gui, Export: Show, Center AutoSize	
	Gui, Export: Show, Hide
	
	F_WhichGui()
	Switch A_DefaultGui
	{
		Case "HS3": WinGetPos, HS3GuiWinX, HS3GuiWinY, HS3GuiWinW, HS3GuiWinH, % "ahk_id" . HS3GuiHwnd
		Case "HS4": WinGetPos, HS3GuiWinX, HS3GuiWinY, HS3GuiWinW, HS3GuiWinH, % "ahk_id" . HS4GuiHwnd 
	}
	DetectHiddenWindows, On
	WinGetPos, , , ExportGuiWinW, ExportGuiWinH, % "ahk_id" . ExportGuiHwnd
	DetectHiddenWindows, Off
	Gui, Export: Show, % "x" . HS3GuiWinX + (HS3GuiWinW - ExportGuiWinW) / 2 . A_Space . "y" . HS3GuiWinY + (HS3GuiWinH - ExportGuiWinH) / 2 . A_Space . "AutoSize"
	Gui, % A_DefaultGui . ":" . A_Space . "+Disabled"
	
	FileRead, v_TheWholeFile, % v_LibraryName
	v_TotalLines := F_HowManyLines(v_TheWholeFile)
	
	if (v_TotalLines = 0)
	{
		MsgBox, 48, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["warning"], % TransA["The selected file is empty. Process of export will be interrupted."]
		return
	}
	line .= v_Header . "`n`n"
	Loop, Parse, v_TheWholeFile, `n, `r%A_Space%%A_Tab%
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
		
		Loop, Parse, A_LoopField, ‖, %A_Space%%A_Tab%
		{
			Switch A_Index
			{
				Case 1: v_Options 	:= A_LoopField
				Case 2: v_Trigger 	:= A_LoopField
				Case 3: v_Function 	:= A_LoopField
				Case 4: v_EnDis 	:= A_LoopField
				Case 5: v_Hotstring := A_LoopField
				Case 6: v_Comment 	:= A_LoopField
			}
		}
		if (v_EnDis = "Dis")
		{
			line .= ";" . A_Space
		}
		if (InStr(v_Function, "M"))
		{
			a_MenuHotstring := StrSplit(v_Hotstring,"¦")
			Loop, % a_MenuHotstring.MaxIndex()
			{
				if (A_Index = 1)
				{
						;line .= ":" v_Options . ":" . v_Trigger . "::" . a_MenuHotstring[A_Index] . A_Space
					line .= "Hotstring(" . """" . ":" . v_Options . ":" . v_Trigger . """" . "," . A_Space . """" . a_MenuHotstring[A_Index] . """" . "," . A_Space . v_EnDis . ")"
					if (v_Comment)
						line .= ";" . v_Comment . A_Space . ";" . TransA["Warning, code generated automatically for definitions based on menu, see documentation of Hotstrings application for further details."]
					else
						line .= ";" . TransA["Warning, code generated automatically for definitions based on menu, see documentation of Hotstrings application for further details."]
					line .= "`n"
				}
				else
				{
					line .=  ";" . A_Space . "Hotstring(" . """" . ":" . v_Options . ":" . v_Trigger . """" . "," . A_Space . """" . a_MenuHotstring[A_Index] . """" . "," . A_Space . v_EnDis . ")"
					if (v_Comment)
						line .= ";" . v_Comment . A_Space . ";" . TransA["Warning, code generated automatically for definitions based on menu, see documentation of Hotstrings application for further details."]
					else
						line .= ";" . TransA["Warning, code generated automatically for definitions based on menu, see documentation of Hotstrings application for further details."]
					line .= "`n"
				}
			}
		}
		else
		{
			line .= "Hotstring(" . """" . ":" . v_Options . ":" . v_Trigger . """" . "," . A_Space . """" . v_Hotstring . """" . "," . A_Space . v_EnDis . ")"
			if (v_Comment)
				line .= ";" . v_Comment
			line .= "`n"
		}
		
		v_Progress := Round((A_Index / v_TotalLines) * 100)
		GuiControl,, % IdExport_T2, % TransA["Exported"] . A_Space . A_Index . A_Space . TransA["of"] . A_Space . v_TotalLines . A_Space . TransA["(triggerstring, hotstring) definitions"]
			. A_Space . "(" . v_Progress . A_Space . "%" . ")"
		GuiControl,, % IdExport_P1, % v_Progress
	}
	FileAppend, % line, % v_OutputFile, UTF-8
	Gui, % A_DefaultGui . ":" . A_Space . "-Disabled"
	Gui, Export: Destroy
	MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["Library has been exported"] . ":" . "`n`n" . v_OutputFile
	return
}
	
; --------------------------- SECTION OF LABELS ------------------------------------------------------------------------------------------------------------------------------
	
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;v_BlockHotkeysFlag := 1 ; Block hotkeys of this application for the time when (triggerstring, hotstring) definitions are uploaded from liberaries.
#If (v_Param != "l") 
;^#h::		; Event
L_GUIInit:
	if (v_ResizingFlag) ;if run for the very first time
	{
		Gui, HS3: +MinSize%HS3MinWidth%x%HS3MinHeight%
		Gui, HS4: +MinSize%HS4MinWidth%x%HS4MinHeight%
		;OutputDebug, % "ini_GuiReload:" . A_Tab . ini_GuiReload . A_Tab . "ini_WhichGui:" . A_Tab . ini_WhichGui
		ini_GuiReload := false
		IniWrite, % ini_GuiReload,		% HADConfig, GraphicalUserInterface, GuiReload
		
		Switch ini_WhichGui
		{
			Case "HS3":
			if (!(ini_HS3WindoPos["X"]) or !(ini_HS3WindoPos["Y"]))
			{
				Gui, HS3: Show, AutoSize Center
				if (ini_ShowIntro)
					Gui, ShowIntro: Show, AutoSize Center
				v_ResizingFlag := false
				return
			}
			if (!(ini_HS3WindoPos["W"]) or !(ini_HS3WindoPos["H"]))
			{	;one of the Windows mysteries, why I need to run the following line twice if c_FontSize > 10
				Gui,	HS3: Show, % "X" . ini_HS3WindoPos["X"] . A_Space . "Y" . ini_HS3WindoPos["Y"] . A_Space . "AutoSize"
				Gui,	HS3: Show, % "X" . ini_HS3WindoPos["X"] . A_Space . "Y" . ini_HS3WindoPos["Y"] . A_Space . "AutoSize"
				if (ini_ShowIntro)
					Gui, ShowIntro: Show, AutoSize Center
				v_ResizingFlag := false
				return
			}
			if (ini_HS3GuiMaximized)
			{
				Gui, HS3: Show, % "X" . ini_HS3WindoPos["X"] . A_Space . "Y" . ini_HS3WindoPos["Y"] . A_Space . "Maximize"
			}
			else	
				Gui,	HS3: Show, % "X" . ini_HS3WindoPos["X"] . A_Space . "Y" . ini_HS3WindoPos["Y"] . A_Space . "W" . ini_HS3WindoPos["W"] . A_Space . "H" . ini_HS3WindoPos["H"]
			if (ini_ShowIntro)
				Gui, ShowIntro: Show, AutoSize Center
			v_ResizingFlag := false
			return
			Case "HS4":
			if (!(ini_HS3WindoPos["W"]) or !(ini_HS3WindoPos["H"]))
			{	;one of the Windows mysteries, why I need to run the following line twice if c_FontSize > 10
				Gui,	HS4: Show, % "X" . ini_HS3WindoPos["X"] . A_Space . "Y" . ini_HS3WindoPos["Y"] . A_Space . "AutoSize"
				Gui,	HS4: Show, % "X" . ini_HS3WindoPos["X"] . A_Space . "Y" . ini_HS3WindoPos["Y"] . A_Space . "AutoSize"
				if (ini_ShowIntro)
					Gui, ShowIntro: Show, AutoSize Center
				v_ResizingFlag := false
				return
			}
			if (!(ini_HS3WindoPos["X"]) or !(ini_HS3WindoPos["Y"]))
			{
				Gui, HS4: Show, AutoSize Center
				if (ini_ShowIntro)
					Gui, ShowIntro: Show, AutoSize Center
				v_ResizingFlag := false
				return
			}
			Gui,	HS4: Show, % "X" . ini_HS3WindoPos["X"] . A_Space . "Y" . ini_HS3WindoPos["Y"] . A_Space . "W" . ini_HS3WindoPos["W"] . A_Space . "H" . ini_HS3WindoPos["H"]
			if (ini_ShowIntro)
				Gui, ShowIntro: Show, AutoSize Center
			v_ResizingFlag := false
			return
		}		
	}
	else ;future: dodać sprawdzenie, czy odczytane współrzędne nie są poza zakresem dostępnym na tym komputerze w momencie uruchomienia
	{
		Switch ini_WhichGui
		{
			Case "HS3":
				if (ini_HS3GuiMaximized)
					Gui, HS3: Show, % "X" . ini_HS3WindoPos["X"] . A_Space . "Y" . ini_HS3WindoPos["Y"] . A_Space . "Maximize"
				else	
					Gui, HS3: Show, Restore ;Unminimizes or unmaximizes the window, if necessary. The window is also shown and activated, if necessary.
			Case "HS4":
				Gui, HS4: Show, Restore ;Unminimizes or unmaximizes the window, if necessary. The window is also shown and activated, if necessary.
		}
	}
return
#If	;#If (v_Param != "l") 
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	
ALibOK:
	Gui, ALib: Submit, NoHide
	if (v_NewLib == "")
	{
		MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["Enter a name for the new library"]
		return
	}
	v_NewLib .= ".csv"
	IfNotExist, % HADL . "\" . v_NewLib
	{
		FileAppend,, % HADL . "\" . v_NewLib, UTF-8
		MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["The library"] . A_Space . v_NewLib . A_Space . TransA["has been created."]
		Gui, ALib: Destroy
		
		F_ValidateIniLibSections()
		F_RefreshListOfLibraries()
		F_RefreshListOfLibraryTips()
		F_UpdateSelHotLibDDL()
	}
	else
		MsgBox, 48, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["warning"], % TransA["A library with that name already exists!"]
return
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -	
	ALibGuiEscape:
	ALibGuiClose:
	Gui, ALib: Destroy
	return
	
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	
GuiAboutLink1:
	Run, https://github.com/mslonik/Hotstrings
return
	
GuiAboutLink2:
	Run, https://www.autohotkey.com/docs/Hotstrings.htm
return
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
L_PublicLibraries:	
	Run, https://github.com/mslonik/Hotstrings/tree/master/Hotstrings/Libraries
return
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
AboutOkButton:
MyAboutGuiEscape:
MyAboutGuiClose: ; Showed when the window is closed by pressing its X button in the title bar.
	Gui, MyAbout: Hide
return
	
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
HS3GuiClose:
HS3GuiEscape:
	Gui,		HS3: Show, Hide
	ini_WhichGui := "HS3"
return
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
HS4GuiClose:
HS4GuiEscape:
	Gui,		HS4: Show, Hide
	ini_WhichGui := "HS4"
return
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
MSPGuiClose:	
MSPGuiEscape:
	
	Switch A_ThisMenu
	{
		Case "OrdHisTrig":
		IniWrite, % ini_OHSF, % HADConfig, Event_BasicHotstring, OHSF
		Iniwrite, % ini_OHSD, % HADConfig, Event_BasicHotstring, OHSD
		Case "MenuHisTrig":
		IniWrite, % ini_MHSF, % HADConfig, Event_MenuHotstring, MHSF
		Iniwrite, % ini_MHSD, % HADConfig, Event_MenuHotstring, MHSD
		Case "UndoOfH":
		IniWrite, % ini_UHSF, % HADConfig, Event_UndoHotstring, UHSF
		Iniwrite, % ini_UHSD, % HADConfig, Event_UndoHotstring, UHSD
	}
	Gui, MSP: Destroy
	return
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
MoveLibsGuiEscape:
CancelMove:
	Gui, MoveLibs: Destroy
return
	
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	
~^f::
~^s::
~F3::
HS3SearchGuiEscape:
HS3SearchGuiClose:
	F_WhichGui()
	Gui, HS3Search: Hide
return
	
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	
~F7::
	HSDelGuiEscape:
	HSDelGuiClose:
	IniWrite, %ini_CPDelay%, % HADConfig, Configuration, ClipBoardPasteDelay
	Gui, HSDel: Destroy
return
	
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
MonGuiEscape:
MonGuiClose:
	Gui, Mon: Destroy
return
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
ShortDefGuiEscape:
ShortDefGuiClose:
	Gui, ShortDef: Hide
return
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
VersionUpdateGuiEscape:
VersionUpdateGuiClose:
	Gui, VersionUpdate: Hide
return
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
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
		IniWrite, %ini_Language%, % HADConfig, GraphicalUserInterface, Language
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
		IniWrite, % ini_GuiReload,		% HADConfig, GraphicalUserInterface, GuiReload
		Reload
	}
	return
}
	
L_TraySuspendHotkeys:
	Suspend, Toggle
	if (A_IsSuspended)
	{
		Menu, Tray, 		Check, 	% TransA["Suspend Hotkeys"]
		Menu, AppSubmenu, 	Check, 	% TransA["Suspend Hotkeys"]
	}
	else
	{
		Menu, Tray, 		UnCheck, 	% TransA["Suspend Hotkeys"]
		Menu, AppSubmenu,	UnCheck, 	% TransA["Suspend Hotkeys"]
	}
return

L_TrayPauseScript:
	Pause, Toggle, 1
	if (A_IsPaused)
	{
		Menu, Tray, 		Check, 	% TransA["Pause application"]
		Menu, AppSubmenu,	Check, 	% TransA["Pause"]
	}
	else
	{
		Menu, Tray, 		UnCheck, 	% TransA["Pause application"]
		Menu, AppSubmenu,	UnCheck, 	% TransA["Pause"]
}
return

L_TrayReload:	;new thread starts here
F_WhichGui()
F_Reload()
return

TurnOff_OHE:
ToolTip, ,, , 4
return

TurnOff_UHE:
ToolTip, ,, , 6
return

TurnOff_Ttt:
Gui, TMenuAHK: Destroy	;ToolTip
return

L_TrayExit:
ExitApp, 2	;2 = by Tray

STDGuiClose:
STDGuiEscape:
Switch (A_ThisMenu)
{
		Case "OrdHisTrig": 	IniWrite, % ini_OHTD, % HADConfig, Event_BasicHotstring, 	OHTD
		Case "UndoOfH":	IniWrite, % ini_UHTD, % HADConfig, Event_UndoHotstring, 	UHTD
		Case "TrigTips":	IniWrite, % ini_TTTD, % HADConfig, Event_TriggerstringTips, TTTD
	}
	Gui, STD: Destroy
return
	
TMNTGuiClose:
TMNTGuiEscape:
	IniWrite, % ini_MNTT, % HADConfig, Event_TriggerstringTips, MNTT
	Gui, TMNT: Destroy
return

L_OpenLibrariesFolderInExplorer:
	Run, explore %HADL%
return

L_ShowIntro:
	F_GuiShowIntro()
	Gui, ShowIntro: Show, AutoSize Center
return

L_Compile:
return