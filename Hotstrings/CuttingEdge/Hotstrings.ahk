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
;Overrides the custom EXE icon used for compilation
;@Ahk2Exe-SetMainIcon  %U_vAppIcon%
;@Ahk2Exe-SetCopyright GNU GPL 3.x
;@Ahk2Exe-SetDescription Advanced tool for hotstring management.
;@Ahk2Exe-SetProductName Original script name: %A_ScriptName%
;@Ahk2Exe-Set OriginalScriptlocation, https://github.com/mslonik/Hotstrings/tree/master/Hotstrings
;@Ahk2Exe-SetCompanyName  http://mslonik.pl
;@Ahk2Exe-SetFileVersion 4.0
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

; - - - - - - - - - - - - - - - - - - - - - - - B E G I N N I N G    O F    I N I T I A L I Z A T I O N - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
F_DetermineMonitors()
Critical, On
F_LoadCreateTranslationTxt() ;default set of translations (English) is loaded at the very beginning in case if Config.ini doesn't exist yet, but some MsgBox have to be shown.
F_CheckCreateConfigIni() ;1. Try to load up configuration file. If those files do not exist, create them.

if ( !Instr(FileExist(A_ScriptDir . "\Languages"), "D"))				; if  there is no "Languages" subfolder 
{
	FileCreateDir, %A_ScriptDir%\Languages							; Future: check against errors
	MsgBox, 48, % SubStr(A_ScriptName, 1, -4) .  ":" . A_Space . TransA["warning"], % TransA["There was no Languages subfolder, so one now is created."] . A_Space . "`n" 
	. A_ScriptDir . "\Languages"
}

IniRead ini_Language, % HADConfig, GraphicalUserInterface, Language				; Load from Config.ini file specific parameter: language into variable ini_Language, e.g. ini_Language = English.ini
if (!FileExist(A_ScriptDir . "\Languages\" . ini_Language))			; else if there is no ini_language .ini file, e.g. v_langugae == Polish.ini and there is no such file in Languages folder
{
	MsgBox, 48, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["warning"], % TransA["There is no"] . A_Space . ini_Language . A_Space . TransA["file in Languages subfolder!"]
	. "`n`n" . TransA["The default"] . A_Space . "English.ini" . A_Space . TransA["file is now created in the following subfolder:"] . "`n`n"  A_ScriptDir . "\Languages\"
	F_LoadCreateTranslationTxt("create")
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

global ini_CPDelay 				:= 300		;1-1000 [ms], default: 300
IniRead, ini_CPDelay, 					% HADConfig, Configuration, ClipBoardPasteDelay,		300
global ini_HotstringUndo			:= true
IniRead, ini_HotstringUndo,				% HADConfig, Configuration, HotstringUndo,			1
global ini_ShowIntro			:= true
IniRead, ini_ShowIntro,					% HADConfig, Configuration, ShowIntro,				1	;GUI with introduction to Hotstrings application.
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
			MsgBox, 16, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["Error"], % TransA["The icon file"] . ":" . "`n`n" . AppIcon . "`n`n" . TransA["doesn't exist in application folder"] . "." . A_Space . TransA["Because of that the default AutoHotkey icon will be used instead"] . "."
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
			MsgBox, 16, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["Error"], % TransA["The icon file"] . ":" . "`n`n" . AppIcon . "`n`n" . TransA["doesn't exist in application folder"] . "." . A_Space . TransA["Because of that the default AutoHotkey icon will be used instead"] . "."
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
Switch c_FontColor
	{
		Case "Black": ;Light (default)
					Menu, StyleGUIsubm, Check,   % TransA["Light (default)"]
					Menu, StyleGUIsubm, UnCheck, % TransA["Dark"]
		Case "White": ;Dark
					Menu, StyleGUIsubm, UnCheck, % TransA["Light (default)"]
					Menu, StyleGUIsubm, Check,   % TransA["Dark"]
}

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

;Menu, MenuHisTrig,		Add, % TransA["Tooltip enable"],				F_EventEnDis
;Menu, MenuHisTrig,		Add, % TransA["Tooltip disable"],				F_EventEnDis
;Menu, MenuHisTrig,		Add
;Menu, MenuHisTrig,		Add, Tooltip,								F_GuiSetTooltipTimeout
Menu, MenuHisTrig,		Add, % TransA["Menu position: caret"],					F_EventTtPos
Menu, MenuHisTrig,		Add, % TransA["Menu position: cursor"],					F_EventTtPos
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
;Menu, TrigTips,		Add, % TransA["Sound enable"],				F_EventSoEn
;Menu, TrigTips,		Add, % TransA["Sound disable"],				F_EventSoEn
;Menu, TrigTips,		Add
;Menu, TrigTips,		Add, % TransA["Sound parameters"],				F_EventSoPar
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

F_SortTipsByLength()
F_SortTipsAlphabetically()
F_EventTtEn()
F_EventSoEn()
F_EventTtPos()
F_AmountOfCharacterTips()

Menu, Submenu1, Add, % TransA["Undo the last hotstring [Ctrl+F12]: enable"], 	F_MUndo
Menu, Submenu1, Add, % TransA["Undo the last hotstring [Ctrl+F12]: disable"],	F_MUndo
Menu, Submenu1, Add
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
Menu, Submenu1,		Add, % TransA["Graphical User Interface"], 		:ConfGUI
;Menu, Submenu1,		Add
;Menu, Submenu1,		Add, Mute all events sound,					F_AllMute
;Menu, Submenu1,		Add, Turn off all events tooltips,				F_AllTooltipsOff
Menu, Submenu1,		Add
Menu, Submenu1,  	   	Add, % TransA["Toggle EndChars"], 				:SubmenuEndChars

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
Menu,	AppSubmenu, 	Add, % TransA["Remove Config.ini"],			F_RemoveConfigIni
Menu,	AutoStartSub,	Add, % TransA["Default mode"],				F_AddToAutostart
Menu,	AutoStartSub,	Add,	% TransA["Silent mode"],					F_AddToAutostart
Menu,	AppSubmenu, 	Add, % TransA["Add to Autostart"],				:AutoStartSub

F_CompileSubmenu()

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
F_GuiAbout_DetermineConstraints()

IniRead, ini_GuiReload, 						% HADConfig, GraphicalUserInterface, GuiReload
if (ini_GuiReload) and (v_Param != "l")
	Gosub, L_GUIInit

;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; Beginning of the main loop of application.
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
		ToolTip,	;Triggerstring Tips tooltip
		v_HotstringFlag := false
	}
	else
	{
		v_InputString .= out
		ToolTip, ,, , 4	;Basic triggerstring was triggered
		ToolTip, ,, , 6	;Undid the last hotstring
		;OutputDebug, % "Before F_PrepareTriggerstringTipsTables:" . A_Space . v_InputString
		F_PrepareTriggerstringTipsTables()		
		F_ShowTriggerstringTips()
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

~BackSpace:: 
if (WinExist("ahk_id" HMenuCliHwnd) or WinExist("ahk_id" HMenuAHKHwnd))
{
	if (ini_MHSEn)
		SoundBeep, % ini_MHSF, % ini_MHSD
}
else
{
	v_InputString := SubStr(v_InputString, 1, -1)
	F_PrepareTriggerstringTipsTables()
	F_ShowTriggerstringTips()
	
	if (v_Param == "d")
	{
		FileAppend, % v_IndexLog . "|" . v_InputString . "|" . ini_TASAC . "|" . ini_TTTtEn . "|" . v_Tips . "`n- - - - - - - - - - - - - - - - - - - - - - - - - -`n", %v_LogFileName%
		v_IndexLog++
	}
}
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

#if WinExist("ahk_id" HS3GuiHwnd) or WinExist("ahk_id" HS4GuiHwnd) ; the following hotkeys will be active only if Hotstrings windows exist at the moment.

~^c::			; copy to edit field "Enter hotstring" content of Clipboard. 
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
			ContentOfClipboard := StrReplace(ContentOfClipboard, "`r`n", "")
		IfMsgBox, No
			ContentOfClipboard := StrReplace(ContentOfClipboard, "`r`n", "``n")
	}
	ControlSetText, Edit2, % ContentOfClipboard
	F_WhichGui()
	Gui, % A_DefaultGui . ":" . A_Space . "Show"
	return
}
#if

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
ToolTip,
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

#if WinExist("ahk_id" HMenuCliHwnd)
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
	static 	IfUpF := false,	IfDownF := false, IsCursorPressed := false, IntCnt := 1
	
	v_PressedKey := A_ThisHotkey
	;OutputDebug, % "Beginning" . ":" . A_Space . A_ThisHotkey . A_Space . "v_MenuMax" . ":" . A_Space . v_MenuMax
	if (InStr(v_PressedKey, "Up"))
	{
		IsCursorPressed := true
		IntCnt--
		;OutputDebug, % "Up" . ":" . A_Space IntCnt . A_Space . IsCursorPressed
		ControlSend, , {Up}, % "ahk_id" HMenuCliHwnd
	}
	if (InStr(v_PressedKey, "Down"))
	{
		IsCursorPressed := true
		IntCnt++
		;OutputDebug, % "Down" . ":" . A_Space IntCnt . A_Space . IsCursorPressed
		ControlSend, , {Down}, % "ahk_id" HMenuCliHwnd
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
		;OutputDebug, % "Enter" . ":" . A_Space . v_PressedKey
	}
	if (v_PressedKey > v_MenuMax)
	{
		;OutputDebug, % "v_PressedKey" . ":" . A_Space . v_PressedKey
		return
	}
	ClipboardBack := ClipboardAll ;backup clipboard
	ControlGet, v_Temp1, List, , , % "ahk_id" Id_LB_HMenuCli
	Loop, Parse, v_Temp1, `n
	{
		if (InStr(A_LoopField, v_PressedKey . "."))
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
	local	ToBeFiltered := "",	Result := "",	ToBeDownloaded := []
			,URLconst := "https://gitHub.com/mslonik/Hotstrings/blob/master/Hotstrings/Libraries/", whr := ""
	
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
		if (FileExist(HADL . "\" . value))
			MsgBox, 51, % SubStr(A_ScriptName, 1, -4) .  ":" . A_Space . TransA["warning"], % value . "`n`n" . TransA["The file which you want to download from Internet, already exists on your local harddisk. Are you sure you want to download it?"]
		IfMsgBox, Cancel
			return
		IfMsgBox, No
			Continue
		URLDownloadToFile, % URLconst, % HADL . "\" . value
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
	;*[One]
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
		ToolTip,
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
				ToolTip, % TransA["Hotstring was triggered! [Ctrl+F12] to undo."], % A_CaretX + 20, % A_CaretY - 20, 4
				if (ini_OHTD > 0)
					SetTimer, TurnOff_OHE, % "-" . ini_OHTD, 40 ;Priority = 40 to avoid conflicts with other threads 
			}
			else
			{
				MouseGetPos, v_MouseX, v_MouseY
				ToolTip, % TransA["Hotstring was triggered! [Ctrl+F12] to undo."], % v_MouseX + 20, % v_MouseY - 20, 4
				if (ini_OHTD > 0)
					SetTimer, TurnOff_OHE, % "-" . ini_OHTD, 40 ;Priority = 40 to avoid conflicts with other threads 
			}
		}
		if (ini_OHTP = 2)
		{
			;*[One]
			MouseGetPos, v_MouseX, v_MouseY
			ToolTip, % TransA["Hotstring was triggered! [Ctrl+F12] to undo."], % v_MouseX + 20, % v_MouseY - 20, 4
			if (ini_OHTD > 0)
				SetTimer, TurnOff_OHE, % "-" . ini_OHTD, 40 ;Priority = 40 to avoid conflicts with other threads 
		}
	}
	
	if (ini_OHSEn)	;Basic Hotstring Sound Enable
		SoundBeep, % ini_OHSF, % ini_OHSD
	
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
			if (HitCnt = ini_MNTT)	
				break
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
			Menu, Submenu1, UnCheck, % TransA["Undo the last hotstring [Ctrl+F12]: disable"]
			Menu, Submenu1, Check,  % TransA["Undo the last hotstring [Ctrl+F12]: enable"]
			Menu, SigOfEvents, Enable, % TransA["Undid the last hotstring"]
			Hotkey, $^F12, F_Undo, On	
		}
		else
		{
			Menu, Submenu1, Check, % TransA["Undo the last hotstring [Ctrl+F12]: disable"]
			Menu, Submenu1, UnCheck, % TransA["Undo the last hotstring [Ctrl+F12]: enable"]
			Menu, SigOfEvents, Disable, % TransA["Undid the last hotstring"]
			Hotkey, $^F12, F_Undo, Off
		}
		OneTimeMemory := false	
	}
	else
	{
		if (ini_HotstringUndo)
		{
			Menu, Submenu1, Check, % TransA["Undo the last hotstring [Ctrl+F12]: disable"]
			Menu, Submenu1, UnCheck, % TransA["Undo the last hotstring [Ctrl+F12]: enable"]
			Menu, SigOfEvents, Disable, % TransA["Undid the last hotstring"]				
			Hotkey, $^F12, F_Undo, Off
		}
		else
		{
			Menu, Submenu1, UnCheck, % TransA["Undo the last hotstring [Ctrl+F12]: disable"]
			Menu, Submenu1, Check,  % TransA["Undo the last hotstring [Ctrl+F12]: enable"]
			Menu, SigOfEvents, Enable, % TransA["Undid the last hotstring"]				
			Hotkey, $^F12, F_Undo, On
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
	
	IniRead, ini_OHTtEn, 	% HADConfig, Event_BasicHotstring, 	OHTtEn, 	1
	IniRead, ini_OHTD,		% HADConfig, Event_BasicHotstring,	OHTD,	0
	IniRead, ini_OHTP,		% HADConfig, Event_BasicHotstring,	OHTP,	1
	IniRead, ini_OHSEn, 	% HADConfig, Event_BasicHotstring,	OHSEn, 	1
	IniRead, ini_OHSF,		% HADConfig, Event_BasicHotstring,	OHSF,	500
	IniRead, ini_OHSD,		% HADConfig, Event_BasicHotstring,	OHSD,	250
	IniRead, ini_MHMP,		% HADConfig, Event_MenuHotstring,		MHMP,	1
	IniRead, ini_MHSEn,		% HADConfig, Event_MenuHotstring,		MHSEn,	1
	IniRead, ini_MHSF,		% HADConfig, Event_MenuHotstring,		MHSF,	500
	IniRead, ini_MHSD,		% HADConfig, Event_MenuHotstring,		MHSD,	250
	IniRead, ini_UHTtEn, 	% HADConfig, Event_UndoHotstring, 		UHTtEn, 	1
	IniRead, ini_UHTD,		% HADConfig, Event_UndoHotstring,		UHTD,	0
	IniRead, ini_UHTP,		% HADConfig, Event_UndoHotstring,		UHTP,	1
	IniRead, ini_UHSEn,		% HADConfig, Event_UndoHotstring,		UHSEn,	1
	IniRead, ini_UHSF,		% HADConfig, Event_UndoHotstring,		UHSF,	500
	IniRead, ini_UHSD,		% HADConfig, Event_UndoHotstring,		UHSD,	250
	IniRead, ini_TTTP,		% HADConfig, Event_TriggerstringTips,	TTTP,	1
	IniRead, ini_TTTtEn, 	% HADConfig, Event_TriggerstringTips,	TTTtEn, 	1
	IniRead, ini_TTTD,		% HADConfig, Event_TriggerstringTips,	TTTD,	0
	IniRead, ini_TipsSortAlphabetically, % HADConfig, Event_TriggerstringTips, TipsSortAlphabetically, 1
	IniRead, ini_TipsSortByLength, % HADConfig, Event_TriggerstringTips, TipsSortByLength, 1
	IniRead, ini_TASAC, 	% HADConfig, Event_TriggerstringTips, 	TipsAreShownAfterNoOfCharacters, 1
	IniRead, ini_MNTT,		% HADConfig, Event_TriggerstringTips,	MNTT,	5
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
		Case "OrdHisTrig": 	Gui, STD: Add, Slider, x0 y0 HwndIdSTD_S1 vini_OHTD gF_SetTooltipTimeout Line1 Page500 Range1000-10000 TickInterval500 ToolTipBottom Buddy1ini_OHTD, % ini_OHTD
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
	GuiControl, % "Count" . v_TotalLines . A_Space . "-Redraw", % IdListView1 ; -Readraw: This option serves as a hint to the control that allows it to allocate memory only once rather than each time a row is added, which greatly improves row-adding performance (it may also improve sorting performance). 
	
	FileRead, v_TheWholeFile, % HADL . "\" . v_SelectHotstringLibrary
	Loop, Parse, v_TheWholeFile, `n, `r
		if (A_LoopField)
			v_TotalLines++
	
	Loop, Parse, v_TheWholeFile, `n, `r	;Check in current library file if such definition do not exist. Future: Check if it exists in any file.
	{
		if (A_LoopField)
		{
			ExternalIndex := A_Index
			Loop, Parse, A_LoopField, ‖, %A_Space%%A_Tab%
			{
				Switch A_Index
				{
					Case 1:	
					if (A_LoopField)
						OldOptions := A_LoopField
					else
						OldOptions := ""
					Case 2:	
					if (InStr(A_LoopField, v_TriggerString, true) and (StrLen(A_LoopField) = StrLen(v_Triggerstring)))
					{
						MsgBox, 68, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"]
							, % TransA["The hostring"] . A_Space . """" .  v_TriggerString . """" . A_Space .  TransA["exists in the file"] . ":" . A_Space . v_SelectHotstringLibrary . "." . "`n`n" 
							. TransA["Do you want to proceed?"]
							. "`n`n" . TransA["If you answer ""Yes"" it will overwritten."]
						IfMsgBox, No
							return
						
						Try
							Hotstring(":" . OldOptions . ":" . v_TriggerString, , "Off") ;Disable existing hotstring
						Catch
							MsgBox, 16, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["Error"], % A_ThisFunc . A_Space . TransA["Something went wrong with hotstring deletion"] . ":" . "`n`n" 
								. "v_TriggerString:" . A_Space . v_TriggerString . "`n"
								. A_Space . "OldOptions:" . A_Space . OldOptions . "`n`n" . TransA["Library name:"] . A_Space . v_SelectHotstringLibrary 				
						LV_Modify(ExternalIndex, "", v_TriggerString, Options, SendFunFileFormat, EnDis, TextInsert, v_Comment)
						ModifiedFlag := true
						Break
					}
				}
			}
		}
	}	
	;OutputDebug, % "Options:" . A_Space . Options . A_Tab . "OldOptions:" . A_Space . OldOptions . A_Tab . "v_TriggerString:" . A_Space . v_TriggerString
	if (InStr(Options, "O", 0))
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
	;Hotstring("Reset") ;reset hotstring recognizer
	
	if !(ModifiedFlag) 
	{
		LV_Add("",  v_TriggerString, Options, SendFunFileFormat, EnDis, TextInsert, v_Comment)
		a_Triggers.Push(v_TriggerString) ;added to table of hotstring recognizer (a_Triggers)
		F_Sort_a_Triggers()
	}
	
	;4. Sort List View. 
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
F_RemoveConfigIni()
{
	global	;assume-global mode
	if (FileExist(HADConfig))
	{
		MsgBox, 308, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["warning"], % TransA["The current Config.ini file will be deleted. This action cannot be undone. Next application will be reloaded and new Config.ini with default settings will be created. Are you sure?"] 
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
	LV_GetText(txt2, v_SelectedRow, 2)
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
		if (InStr(a_Triggers[A_Index], v_TriggerString))
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
	
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	
HS3GuiSize(GuiHwnd, EventInfo, Width, Height) ;Gui event
{	;This function toggles flag ini_IsSandboxMoved
;Within a function, to create a set of variables that is local instead of global, declare OutputVar as a local variable prior to using command GuiControlGet, Pos. However, it is often also necessary to declare each variable in the set, due to a common source of confusion.	
	global ;assume-global mode
	local v_OutVarTemp1 := 0, v_OutVarTemp1X := 0, v_OutVarTemp1Y := 0, v_OutVarTemp1W := 0, v_OutVarTemp1H := 0
		,v_OutVarTemp2 := 0, v_OutVarTemp2X := 0, v_OutVarTemp2Y := 0, v_OutVarTemp2W := 0, v_OutVarTemp2H := 0
		,deltaW := 0, deltaH := 0
		,v_xNext := 0, v_yNext := 0, v_wNext := 0, v_hNext := 0
	
	;OutputDebug, % "HS3GuiSize" . A_Space . "A_GuiWidth:" . A_Space . A_GuiWidth . A_Space . "A_GuiHeight:" . A_Space .  A_GuiHeight
	
	if (A_EventInfo = 1) ; The window has been minimized.
	{
		ini_WhichGui := "HS3"
		return
	}
	if (v_ResizingFlag) ;Special case: some procedures are run twice (see L_GUIInit)
	{
		HS3_GuiWidth  := A_GuiWidth
		HS3_GuiHeight := A_GuiHeight
		;OutputDebug, return because of "v_ResizingFlag"
		GuiControlGet, v_OutVarTemp2, Pos, % IdListView1 ;Check position of ListView1 again after resizing
		LV_ModifyCol(1, Round(0.1 * v_OutVarTemp2W))
		LV_ModifyCol(2, Round(0.1 * v_OutVarTemp2W))
		LV_ModifyCol(3, Round(0.1 * v_OutVarTemp2W))	
		LV_ModifyCol(4, Round(0.1 * v_OutVarTemp2W))
		LV_ModifyCol(5, Round(0.4 * v_OutVarTemp2W))
		LV_ModifyCol(6, Round(0.2 * v_OutVarTemp2W) - 3)
		return
	}
	
	GuiControlGet, v_OutVarTemp1, Pos, % IdListView1 ;This line will be used for "if" and "else" statement.
	;OutputDebug, % "Before:" . A_Space . v_OutVarTemp1H
	F_AutoXYWH("*wh", IdListView1)
	F_AutoXYWH("*h",  IdButton5)
	
	if (!ini_IsSandboxMoved)	;tu jestem
	{
		;F_AutoXYWH("*w", IdEdit10)
		F_AutoXYWH("*y", IdText10)
		F_AutoXYWH("*y", IdTextInfo17)
		F_AutoXYWH("*yw", IdEdit10)
	}
	
	GuiControlGet, v_OutVarTemp2, Pos, % IdListView1 ;Check position of ListView1 again after resizing
	;OutputDebug, % "After:" . A_Space . v_OutVarTemp2H
	;OutputDebug, % "Height of ListView in rel to A_GuiHeight:" . A_Space . A_GuiHeight - v_OutVarTemp2H
	if (v_OutVarTemp2W != v_OutVarTemp1W)
	{
		LV_ModifyCol(1, Round(0.1 * v_OutVarTemp2W))
		LV_ModifyCol(2, Round(0.1 * v_OutVarTemp2W))
		LV_ModifyCol(3, Round(0.1 * v_OutVarTemp2W))	
		LV_ModifyCol(4, Round(0.1 * v_OutVarTemp2W))
		LV_ModifyCol(5, Round(0.4 * v_OutVarTemp2W))
		LV_ModifyCol(6, Round(0.2 * v_OutVarTemp2W) - 3)
	}	
	
	;OutputDebug, % "v_ResizingFlag:" . A_Space . v_ResizingFlag . A_Tab . "HS3_GuiWidth:" . A_Space . HS3_GuiWidth . A_Tab . "HS3_GuiHeight:" . A_Space . HS3_GuiHeight
	deltaW := A_GuiWidth -  HS3_GuiWidth
	deltaH := A_GuiHeight - HS3_GuiHeight
	;OutputDebug, % "deltaW:" . A_Space . deltaW . A_Tab . "deltaH:" . A_Space . deltaH 
	
	;if (ini_Sandbox) and (deltaH > 0) and !(ini_IsSandboxMoved) and (v_OutVarTemp2H + HofText > LeftColumnH) 
	if (ini_Sandbox) and !(ini_IsSandboxMoved) and (v_OutVarTemp2H + HofText > LeftColumnH) 
	{
		v_hNext := v_OutVarTemp2H + c_ymarg + HofText + c_HofSandbox
		GuiControl, MoveDraw, % IdListView1, % "h" . v_hNext  ;increase
		v_xNext := c_xmarg
		v_yNext := LeftColumnH + c_ymarg
		GuiControl, MoveDraw, % IdText10, % "x" . v_xNext . "y" . v_yNext
		GuiControlGet, v_OutVarTemp1, Pos, % IdText10
		v_xNext := v_OutVarTemp1X + v_OutVarTemp1W + c_xmarg
		v_yNext := LeftColumnH + c_ymarg
		GuiControl, MoveDraw, % IdTextInfo17, % "x" . v_xNext . "y" . v_yNext
		v_xNext := c_xmarg
		v_yNext := LeftColumnH + c_ymarg + HofText "w" LeftColumnW - 2 * c_xmarg
		GuiControl, MoveDraw, % IdEdit10, % "x" . v_xNext . "y" . v_yNext
		ini_IsSandboxMoved := true
		OutputDebug, % "One:" . A_Tab . "ini_IsSandboxMoved" . A_Space . ini_IsSandboxMoved . A_Tab . "deltaH" . A_Space . deltaH
		F_AutoXYWH("reset")
		F_AutoXYWH("*wh", IdListView1)
		F_AutoXYWH("*h", IdButton5)
	}
	;if (!ini_Sandbox) and (deltaH > 0) and !(ini_IsSandboxMoved) and (v_OutVarTemp2H + HofText > LeftColumnH)
	if (!ini_Sandbox) and !(ini_IsSandboxMoved) and (v_OutVarTemp2H + HofText > LeftColumnH)
	{
		ini_IsSandboxMoved := true
		OutputDebug, % "Two:" . A_Tab . "ini_IsSandboxMoved" . A_Space . ini_IsSandboxMoved . A_Tab . "deltaH" . A_Space . deltaH
	}
	
	;if (ini_Sandbox) and (deltaH < 0) and (ini_IsSandboxMoved) and (v_OutVarTemp2H <  LeftColumnH + c_HofSandbox)
	if (ini_Sandbox) and (ini_IsSandboxMoved) and (v_OutVarTemp2H <  LeftColumnH + c_HofSandbox)
	{
		v_hNext := v_OutVarTemp2H - (c_ymarg + HofText + c_HofSandbox)
		GuiControl, MoveDraw, % IdListView1, % "h" . v_hNext ;decrease
		v_xNext := LeftColumnW + c_xmarg + c_WofMiddleButton + c_xmarg
		v_yNext := v_OutVarTemp2Y + v_OutVarTemp2H - (HofText + c_HofSandbox)
		GuiControl, MoveDraw, % IdText10, % "x" . v_xNext . "y" . v_yNext
		GuiControlGet, v_OutVarTemp1, Pos, % IdText10
		v_xNext := v_OutVarTemp1X + v_OutVarTemp1W + c_xmarg
		v_yNext := v_OutVarTemp2Y + v_OutVarTemp2H - (HofText + c_HofSandbox)
		GuiControl, MoveDraw, % IdTextInfo17, % "x" . v_xNext . "y" . v_yNext
		v_xNext := LeftColumnW + c_WofMiddleButton + c_xmarg
		v_yNext := v_OutVarTemp2Y + v_OutVarTemp2H - c_HofSandbox "w" v_OutVarTemp2W
		GuiControl, MoveDraw, % IdEdit10, % "x" . v_xNext . "y" . v_yNext
		ini_IsSandboxMoved := false
		OutputDebug, % "Three:" . A_Tab . "ini_IsSandboxMoved" . A_Space . ini_IsSandboxMoved . A_Tab . "deltaH" . A_Space . deltaH
		F_AutoXYWH("reset")
		F_AutoXYWH("*wh", IdListView1)
		F_AutoXYWH("*h", IdButton5)
	}
	;if (ini_Sandbox) and (deltaH < 0) and (ini_IsSandboxMoved) and (v_OutVarTemp2H <  LeftColumnH + c_HofSandbox)
	if (!ini_Sandbox) and (ini_IsSandboxMoved) and (v_OutVarTemp2H <  LeftColumnH + c_HofSandbox)
	{
		ini_IsSandboxMoved := false
		OutputDebug, % "Four:" . A_Tab . "ini_IsSandboxMoved" . A_Space . ini_IsSandboxMoved . A_Tab . "deltaH" . A_Space . deltaH
	}
	
	HS3_GuiWidth  := A_GuiWidth	;only GuiSize automatic subroutine is able to determine A_GuiWidth and A_GuiHeight, so the last value is stored in global variables.
	HS3_GuiHeight := A_GuiHeight
	;OutputDebug, % "HS3_GuiWidth:" . A_Space . HS3_GuiWidth . A_Space "HS3_GuiHeight" . A_Space . HS3_GuiHeight
	;*[Two]
	return
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_SelectLibrary()
{
	global ;assume-global mode
	local v_TheWholeFile := "", str1 := [], v_TotalLines := 0
		,v_OutVarTemp := 0, v_OutVarTempX := 0, v_OutVarTempY := 0, v_OutVarTempW := 0, v_OutVarTempH := 0
	
	if (A_DefaultGui = "HS3")
		Gui, HS3: Submit, NoHide
	if (A_DefaultGui = "HS4")
		Gui, HS4: Submit, NoHide
	
	GuiControl, Enable, % IdButton4 ; button Delete hotstring (F8)
	FileRead, v_TheWholeFile, % HADL . "\" . v_SelectHotstringLibrary
	Loop, Parse, v_TheWholeFile, `n, `r
		if (A_LoopField)
			v_TotalLines++
	
	Gui, HS3: Default			;All of the ListView function operate upon the current default GUI window.
	GuiControl, % "Count" . v_TotalLines . A_Space . "-Redraw", % IdListView1 ;This option serves as a hint to the control that allows it to allocate memory only once rather than each time a row is added, which greatly improves row-adding performance (it may also improve sorting performance). 
	LV_Delete()
	v_LibHotstringCnt := 0
	GuiControl, , % IdText13,  % v_LibHotstringCnt
	GuiControl, , % IdText13b, % v_LibHotstringCnt
	
	Loop, Parse, v_TheWholeFile, `n, `r
	{
		if (A_LoopField)
		{
			Loop, Parse, A_LoopField, ‖
			{
				Switch A_Index
				{
					Case 1: str1[1] := A_LoopField
					Case 2: str1[2] := A_LoopField
					Case 3: str1[3] := A_LoopField
					Case 4: str1[4] := A_LoopField
					Case 5: str1[5] := A_LoopField
					Case 6: str1[6] := A_LoopField
				}
			}
			LV_Add("", str1[2], str1[1], str1[3], str1[4],str1[5], str1[6])	
			v_LibHotstringCnt := A_Index
			GuiControl, , % IdText13,  % v_LibHotstringCnt
			GuiControl, , % IdText13b, % v_LibHotstringCnt
		}
		else
			Break
	}	
	LV_ModifyCol(1, "Sort")
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
		Menu, CompileSubmenu, Add, % TransA["Standard executable (Ahk2Exe.exe)"], F_Compile
		Menu,	AppSubmenu,		Add,	% TransA["Compile"],				:CompileSubmenu
		;Menu, TraySubmenu,	  Add, % TransA["Standard executable (Ahk2Exe.exe)"], F_Compile
	}
	if (FileExist(v_TempOutStr . "upx.exe"))
	{
		Menu, CompileSubmenu, Add, % TransA["Compressed executable (upx.exe)"], 	F_Compile
		;Menu, TraySubmenu,	  Add, % TransA["Compressed executable (upx.exe)"], 	F_Compile
	}
	if (FileExist(v_TempOutStr . "mpress.exe"))
	{
		Menu, CompileSubmenu, Add, % TransA["Compressed executable (mpress.exe)"], F_Compile
		;Menu, TraySubmenu,	  Add, % TransA["Compressed executable (mpress.exe)"], F_Compile
	}
	if (!FileExist(A_AhkPath)) ;if AutoHotkey isn't installed
	{
		Menu, AppSubmenu,		Add,	% TransA["Compile"],			L_Compile
		Menu,	AppSubmenu, Disable,							% TransA["Compile"]
	}
	;Menu,	Tray,			Add, % TransA["Compile"],				:TraySubmenu
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_Compile()
;https://www.autohotkey.com/boards/viewtopic.php?f=86&t=90196&p=398198#p398198
{
	local v_TempOutStr := "" ;, v_TempOutStr2 := "", v_TempOutStr3 := ""
	
	SplitPath, A_AhkPath, ,v_TempOutStr
	v_TempOutStr .= "\" . "Compiler" . "\" 
	
	Switch A_ThisMenuItem
	{
		Case TransA["Standard executable (Ahk2Exe.exe)"]:
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
		
		Case TransA["Compressed executable (upx.exe)"]:
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
		
		Case TransA["Compressed executable (mpress.exe)"]:
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
	;Gui, % A_DefaultGui . ":" . A_Space . "Show", AutoSize	;tu jestem
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
WhichGui=
GuiFontColor=
GuiFontColorHighlighted= 
GuiWindowColor=
GuiControlColor=
GuiSizeOfMarginX=10
GuiSizeOfMarginY=10
GuiFontType=Calibri
GuiFontSize=10
GuiReload=
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
		MsgBox, 48, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["warning"], % TransA["Config.ini wasn't found. The default Config.ini has now been created in location:"] . "`n`n" . HADConfig
		FileAppend, %ConfigIni%, % HADConfig
	}
	return	
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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
	local v_LibraryFlag := 0 ;, v_WhichLibraries := "", v_LibTemp := "", v_LibFlagTemp := ""
	
	Menu, EnDisLib, ToggleCheck, %A_ThisMenuItem%
	IniRead, v_LibraryFlag,	% HADConfig, LoadLibraries, %A_ThisMenuitem%
	v_LibraryFlag := !(v_LibraryFlag)
	Iniwrite, %v_LibraryFlag%,	% HADConfig, LoadLibraries, %A_ThisMenuItem%
	
	if (v_LibraryFlag)
	{
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
	return
}
; ------------------------------------------------------------------------------------------------------------------------------------
F_UnloadFile(nameoffile)
{
	global ;assume-global mode
	local	v_TheWholeFile := "",	Options := "",	TriggerString := ""
	
	FileRead, v_TheWholeFile, % HADL . "\" . nameoffile
	Loop, Parse, v_TheWholeFile, `n, `r
	{
		if (A_LoopField)
		{
			Loop, Parse, A_LoopField, ‖
			{
				if (A_Index = 1)
					Options := A_LoopField
				if (A_Index = 2)
					TriggerString := A_LoopField
				if (A_Index = 3)
					Break
			}
			Try
				Hotstring(":" . Options . ":" . TriggerString, , "Off") ;Disable existing hotstring
			Catch
				MsgBox, 16, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["Error"], % A_ThisFunc . A_Space . TransA["Something went wrong with disabling of existing hotstring"] 
				. ":" . "`n`n" . "TriggerString:" . A_Space . TriggerString . "`n" . A_Space . "Options:" . A_Space . Options . "`n`n" . TransA["Library name:"] 
				. A_Space . nameoffile 				
			Options := ""		
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
A library with that name already exists! 					= A library with that name already exists!
Alphabetically 										= Alphabetically
Apostrophe ' 											= Apostrophe '
Application											= A&pplication
Application help									= Application help
Application language changed to: 							= Application language changed to:
Are you sure you want to exit this application now?			= Are you sure you want to exit this application now?
Are you sure you want to reload this application now?			= Are you sure you want to reload this application now?
Backslash \ 											= Backslash \
Basic hotstring is triggered								= Basic hotstring is triggered
Because of that the default AutoHotkey icon will be used instead = Because of that the default AutoHotkey icon will be used instead
Built with Autohotkey.exe version							= Built with Autohotkey.exe version
By length 											= By length
Cancel 												= Cancel
Case Sensitive (C) 										= Case Sensitive (C)
Case-Conforming										= Case-Conforming
Change language 										= Change language
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
(Current configuration will be saved befor reload takes place).	= (Current configuration will be saved befor reload takes place).
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
Dynamic hotstrings 										= &Dynamic hotstrings
Edit Hotstrings 										= Edit Hotstrings
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
exists in the file										= exists in the file
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
I wish you good work with Hotstrings and DFTBA (Don't Forget to be Awsome)! = I wish you good work with Hotstrings and DFTBA (Don't Forget to be Awsome)!
Graphical User Interface									= Graphical User Interface
has been created. 										= has been created.
Help: AutoHotkey Hotstrings reference guide					= Help: AutoHotkey Hotstrings reference guide
Help: Hotstrings application								= Help: Hotstrings application
Hotstring 											= Hotstring
Hotstring added to the file								= Hotstring added to the file
Hotstring has been deleted. Now application will restart itself in order to apply changes, reload the libraries (.csv) = Hotstring has been deleted. Now application will restart itself in order to apply changes, reload the libraries (.csv)
Hotstring was triggered! [Ctrl+F12] to undo.					= Hotstring was triggered! [Ctrl+F12] to undo.
""Hotstring was triggered"" tooltip timeout in [ms]			= ""Hotstring was triggered"" tooltip timeout in [ms]
""Undid the last hotstring!"" tooltip timeout in [ms]			= ""Undid the last hotstring!"" tooltip timeout in [ms]
Hotstring moved to the 									= Hotstring moved to the
Hotstring paste from Clipboard delay 1 s 					= Hotstring paste from Clipboard delay 1 s
Hotstring paste from Clipboard delay 						= Hotstring paste from Clipboard delay
Hotstrings have been loaded 								= Hotstrings have been loaded
If you answer ""Yes"" it will overwritten.					= If you answer ""Yes"" it will overwritten.
If you answer ""Yes"", the existing file will be deleted. This is recommended choice. If you answer ""No"", new content will be added to existing file. = If you answer ""Yes"", the existing file will be deleted. This is recommended choice. If you answer ""No"", new content will be added to existing file.
Immediate Execute (*) 									= Immediate Execute (*)
Import from .ahk to .csv 								= &Import from .ahk to .csv
In order to display library content please at first select hotstring library = In order to display library content please at first select hotstring library
information											= information
Inside Word (?) 										= Inside Word (?)
In order to aplly new font style it's necesssary to reload the application. 	= In order to aplly new font style it's necesssary to reload the application.
In order to aplly new font type it's necesssary to reload the application. 	= In order to aplly new font type it's necesssary to reload the application.
In order to aplly new size of margin it's necesssary to reload the application. = In order to aplly new size of margin it's necesssary to reload the application.
In order to aplly new style it's necesssary to reload the application. 		= In order to aplly new style it's necesssary to reload the application.
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
Link file (.lnk) was created in AutoStart folder				= Link file (.lnk) was created in AutoStart folder
Loading of (triggerstring, hotstring) definitions from the library file = Loading of (triggerstring, hotstring) definitions from the library file
Loading file											= Loading file
Loaded hotstrings: 										= Loaded hotstrings:
Loading hotstrings from libraries... 						= Loading hotstrings from libraries...
Loading imported library. Please wait...					= Loading imported library. Please wait...
Loaded												= Loaded
Max. no. of shown tips									= Max. no. of shown tips
Maximum number of shown triggerstring tips				= Maximum number of shown triggerstring tips
Menu hotstring is triggered								= Menu hotstring is triggered
Menu position: caret									= Menu position: caret
Menu position: cursor									= Menu position: cursor
Minus - 												= Minus -
Move (F8)												= Move (F8)
No													= No
No Backspace (B0) 										= No Backspace (B0)
No EndChar (O) 										= No EndChar (O)
No libraries have been found!								= No libraries have been found!
Not Case-Conforming (C1)									= Not Case-Conforming (C1)
Number of characters for tips 							= &Number of characters for tips
of													= of
OK													= &OK
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
Visit public libraries webpage							= Visit public libraries webpage
Reload												= Reload
Reload in default mode									= Reload in default mode
Reload in silent mode									= Reload in silent mode
Remove Config.ini										= Remove Config.ini
Replacement text is blank. Do you want to proceed? 			= Replacement text is blank. Do you want to proceed?
Reset Recognizer (Z)									= Reset Recognizer (Z)
)"	;A continuation section cannot produce a line whose total length is greater than 16,383 characters. See documentation for workaround.
	TransConst .= "`n
(Join`n `
Sandbox (F6)											= Sandbox (F6)
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
Show full GUI (F4)										= Show full GUI (F4)
Show intro											= Show intro
Show Introduction window after application is restarted?		= Show Introduction window after application is restarted?
Show Sandbox (F6)										= Show Sandbox (F6)
Signaling of events										= Signaling of events
Silent mode											= Silent mode
Size of font											= Size of font
Size of margin:										= Size of margin:
Slash / 												= Slash /
Something went wrong during hotstring setup				= Something went wrong during hotstring setup
Something went wrong with disabling of existing hotstring		= Something went wrong with disabling of existing hotstring
Something went wrong with (triggerstring, hotstring) creation	= Something went wrong with (triggerstring, hotstring) creation
Something went wrong with hotstring deletion					= Something went wrong with hotstring deletion
Something went wrong with hotstring EndChars					= Something went wrong with hotstring EndChars
Something weng wrong with link file (.lnk) creation			= Something weng wrong with link file (.lnk) creation
Sound disable											= Sound disable
Sound enable											= Sound enable
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
The application will be reloaded with the new language file. 	= The application will be reloaded with the new language file.
The current Config.ini file will be deleted. This action cannot be undone. Next application will be reloaded and new Config.ini with default settings will be created. Are you sure? = The current Config.ini file will be deleted. This action cannot be undone. Next application will be reloaded and new Config.ini with default settings will be created. Are you sure?
The default											= The default
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
The selected file is empty. Process of import will be interrupted. = The selected file is empty. Process of import will be interrupted.
The (triggerstring, hotstring) definitions have been uploaded from library file = The (triggerstring, hotstring) definitions have been uploaded from library file
The (triggerstring, hotstring) definitions stored in the following library file have been unloaded from memory = The (triggerstring, hotstring) definitions stored in the following library file have been unloaded from memory
There is no											= There is no
There was no Languages subfolder, so one now is created.		= There was no Languages subfolder, so one now is created.
This is the maximum length of list displayed on the screen in form of tooltip containing triggerstring tips. = This is the maximum length of list displayed on the screen in form of tooltip containing triggerstring tips.
This library:											= This library:
This line do not comply to format required by this application.  = This line do not comply to format required by this application.
This option is valid 									= In case you observe some hotstrings aren't pasted from clipboard increase this value. `nThis option is valid for CL and MCL hotstring output functions. 
Tip: If you copy text from PDF file it's adviced to remove them. = Tip: If you copy text from PDF file it's adviced to remove them.
Tips are shown after no. of characters						= Tips are shown after no. of characters
Toggle EndChars	 									= &Toggle EndChars
Tooltip disable										= Tooltip disable
Tooltip enable											= Tooltip enable
Tooltip position: caret									= Tooltip position: caret
Tooltip position: cursor									= Tooltip position: cursor
Tooltip timeout										= Tooltip timeout
Total:												= Total:
(triggerstring, hotstring) definitions						= (triggerstring, hotstring) definitions
Triggerstring 											= Triggerstring
Triggerstring / hotstring behaviour						= Triggerstring / hotstring behaviour
Triggerstring sound duration [ms]							= Triggerstring sound duration [ms]
Triggerstring sound frequency range						= Triggerstring sound frequency range
Triggerstring tip(s) tooltip timeout in [ms]					= Triggerstring tip(s) tooltip timeout in [ms]
Triggerstring tips 										= Triggerstring tips
Triggerstring tooltip timeout in [ms]						= Triggerstring tooltip timeout in [ms]
Triggerstring|Trigg Opt|Out Fun|En/Dis|Hotstring|Comment 		= Triggerstring|Trigg Opt|Out Fun|En/Dis|Hotstring|Comment
Underscore _											= Underscore _
Undo the last hotstring [Ctrl+F12]: disable					= Undo the last hotstring [Ctrl+F12]: disable
Undo the last hotstring [Ctrl+F12]: enable					= Undo the last hotstring [Ctrl+F12]: enable
Undid the last hotstring 								= Undid the last hotstring
warning												= warning
Warning, code generated automatically for definitions based on menu, see documentation of Hotstrings application for further details. = Warning, code generated automatically for definitions based on menu, see documentation of Hotstrings application for further details.
Welcome to Hotstrings application!							= Welcome to Hotstrings application!
When ""basic hotsring"" event takes place, sound is emitted according to the following settings. = When ""basic hotsring"" event takes place, sound is emitted according to the following settings.
When ""hotstring menu"" event takes place, sound is emitted according to the following settings. = When ""hotstring menu"" event takes place, sound is emitted according to the following settings.
When ""undo hotstring"" event takes place, sound is emitted according to the following settings. = When ""undo hotstring"" event takes place, sound is emitted according to the following settings.
When timeout is set, the tooltip ""Hotstring was triggered"" will dissapear after time reaches it. = When timeout is set, the tooltip ""Hotstring was triggered"" will dissapear after time reaches it.
When timeout is set, the tooltip ""Undid the last hotstring!"" will dissapear after time reaches it. = When timeout is set, the tooltip ""Undid the last hotstring!"" will dissapear after time reaches it.
When timeout is set, the triggerstring tip(s) will dissapear after time reaches it. = When timeout is set, the triggerstring tip(s) will dissapear after time reaches it.
When triggerstring event takes place, sound is emitted according to the following settings. = When triggerstring event takes place, sound is emitted according to the following settings.
Yes													= Yes
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
		,IdLoadFile_T1 := 0, IdLoadFile_P1 := 0, IdLoadFile_T2 := 0
	
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
	Loop, Parse, v_TheWholeFile, `n, `r
	{
		if (A_LoopField)
			F_CreateHotstring(A_LoopField, nameoffile)
		else
			Break
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
	Gui,		HS4: Add,		Radio,		x0 y0 HwndIdRadioCaseCCb AltSubmit vv_RadioCaseGroup Checked,	% TransA["Case-Conforming"]
	Gui, 	HS4: Font, 	% "s" . c_FontSize + 2
	Gui,		HS4: Add,		Text,		x0 y0 HwndIdTextInfo3b,									ⓘ
	GuiControl +g, % IdTextInfo3b, % F_TI_CaseConforming
	
	Gui, 	HS4: Font, 	% "s" . c_FontSize
	Gui, 	HS4: Add,		CheckBox, 	x0 y0 HwndIdCheckBox3b gF_Checkbox vv_OptionNoBackspace,		% TransA["No Backspace (B0)"]
	Gui, 	HS4: Font, 	% "s" . c_FontSize + 2
	Gui,		HS4: Add,		Text,		x0 y0 HwndIdTextInfo4b,									ⓘ
	GuiControl +g, % IdTextInfo4b, % F_TI_NoBackSpace
	
	Gui, 	HS4: Font, 	% "s" . c_FontSize
	Gui,		HS4: Add,		Radio,		x0 y0 HWndIdRadioCaseCSb AltSubmit,						% TransA["Case Sensitive (C)"]
	Gui, 	HS4: Font, 	% "s" . c_FontSize + 2
	Gui,		HS4: Add,		Text,		x0 y0 HwndIdTextInfo5b,									ⓘ
	GuiControl +g, % IdTextInfo5b, % F_TI_CaseSensitive
	
	Gui, 	HS4: Font, 	% "s" . c_FontSize
	Gui, 	HS4: Add,		CheckBox, 	x0 y0 HwndIdCheckBox4b gF_Checkbox vv_OptionInsideWord, 		% TransA["Inside Word (?)"]
	Gui, 	HS4: Font, 	% "s" . c_FontSize + 2
	Gui,		HS4: Add,		Text,		x0 y0 HwndIdTextInfo6b,									ⓘ
	GuiControl +g, % IdTextInfo6b, % F_TI_InsideWord
	
	Gui, 	HS4: Font, 	% "s" . c_FontSize
	Gui,		HS4: Add,		Radio,		x0 y0 HwndIdRadioCaseC1b AltSubmit,						% TransA["Not Case-Conforming (C1)"]
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
	Gui,			HS3: Add,			Radio,		x0 y0 HwndIdRadioCaseCC AltSubmit vv_RadioCaseGroup Checked,	% TransA["Case-Conforming"]
	Gui,			HS3: Add,			Radio,		x0 y0 HWndIdRadioCaseCS AltSubmit,							% TransA["Case Sensitive (C)"]
	Gui,			HS3: Add,			Radio,		x0 y0 HwndIdRadioCaseC1 AltSubmit,							% TransA["Not Case-Conforming (C1)"]
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
		OutputDebug, % "Redraw" . A_Space . "The first else" . A_Tab . "ini_Sandbox" . A_Space . ini_Sandbox . A_Tab . "ini_IsSandboxMoved" . A_Space . ini_IsSandboxMoved
		GuiControlGet, v_OutVarTemp, Pos, % IdListView1
		if (ini_Sandbox) and (!ini_IsSandboxMoved)
		{
			v_hNext := v_OutVarTempH - (c_HofSandbox + HofText + c_ymarg)	;decrease ListView
			GuiControl, Move, % IdListView1, % "h" . v_hNext
			F_AutoXYWH("reset")	
		}
		if (!ini_Sandbox) and (!ini_IsSandboxMoved)
		{
			v_hNext := v_OutVarTempH + (c_HofSandbox + HofText + c_ymarg)	;increase ListView
			GuiControl, Move, % IdListView1, % "h" . v_hNext
			F_AutoXYWH("reset")	
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

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_GuiAbout()
{
	global ;assume-global mode
	local FoundPos := ""
		,Window1X := 0, Window1Y := 0, Window1W := 0, Window1H := 0
		,Window2X := 0, Window2Y := 0, Window2W := 0, Window2H := 0
		,NewWinPosX := 0, NewWinPosY := 0
	
	if (WinExist("ahk_id" . HS3GuiHwnd) or WinExist("ahk_id" . HS3GuiHwnd))
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
	;OutputDebug, % "Window2W:" . A_Space . Window2W . A_Space . "Window2H:" . A_Space . Window2H
	;OutputDebug, % "NewWinPosX:" . A_Space . NewWinPosX . A_Space . "NewWinPosY:" . A_Space . NewWinPosY
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
		MsgBox, 48, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["warning"], % TransA["There is no Libraries subfolder and no lbrary (*.csv) file exists!"] . "`n`n" . HADL . "`n`n" . TransA["folder is now created"] . "."
		FileCreateDir, % HADL							; Future: check against errors
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
				tabSearch := StrSplit(varSearch, "‖")
				if (InStr(tabSearch[1], "*0"))
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
				name := SubStr(A_LoopFileName, 1, StrLen(A_LoopFileName)-4)
			; LV_Add("", name, tabSearch[2],tabSearch[1],tabSearch[3],tabSearch[4],tabSearch[5], tabSearch[6])
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
			ExitApp, 1
		IfMsgBox, Yes
			return
	}
	if (v_TriggerString and (OnOff = "On"))
	{
		;OutputDebug, % "Hotstring(:" . Options . ":" . v_Triggerstring . "," . "func(" . SendFun . ").bind(" . TextInsert . "," . A_Space . Oflag . ")," . A_Space . OnOff . ")"
		Try
			Hotstring(":" . Options . ":" . v_TriggerString, func(SendFun).bind(TextInsert, Oflag), OnOff)
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
	local	ThisHotkey := A_ThisHotkey
	
	v_InputString := ""
	;*[One]
	v_UndoHotstring := ReplacementString
	ReplacementString := F_ReplaceAHKconstants(ReplacementString)
	if (Oflag = false)
		SendInput, % ReplacementString . A_EndChar
	else
		SendInput, % ReplacementString
	v_TypedTriggerstring := ThisHotkey 
	v_HotstringFlag := true
	v_LOF := "SI"	;last (active) Output Function; this variable stores information about output function. it's used by F_Undo to correctly interpret special text strings, e.g. {Enter}
	F_EventSigOrdHotstring()
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
	Gui, HMenuCli: Font, c766D69 s8	;Tooltip font color
	Gui, HMenuCli: Color,, White
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
	;*[One]
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
	
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
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
	Gui, HMenuAHK: Font, c766D69 s8	;Tooltip font color
	Gui, HMenuAHK: Color,, White
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
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
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
	static 	IfUpF := false,	IfDownF := false, IsCursorPressed := false, IntCnt := 1
	
	v_PressedKey := A_ThisHotkey
;OutputDebug, % "Beginning" . ":" . A_Space . A_ThisHotkey
	if (InStr(v_PressedKey, "Up"))
	{
		IsCursorPressed := true
		IntCnt--
	;OutputDebug, % "Up" . ":" . A_Space IntCnt
		ControlSend, , {Up}, % "ahk_id" HMenuAHKHwnd
	}
	if (InStr(v_PressedKey, "Down"))
	{
		IsCursorPressed := true
		IntCnt++
	;OutputDebug, % "Down" . ":" . A_Space IntCnt
		ControlSend, , {Down}, % "ahk_id" HMenuAHKHwnd
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
		;OutputDebug, % "Enter" . ":" . A_Space . v_PressedKey
	}
	if (v_PressedKey > v_MenuMax)
	{
		;OutputDebug, % "v_PressedKey" . ":" . A_Space . v_PressedKey
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
	,key := "", value := 0, f_ExistedLib := false
	
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
	Loop, Parse, v_TheWholeFile, `n, `r
		if (A_LoopField)
			v_TotalLines++
	
	if (v_TotalLines = 0)
	{
		MsgBox, 48, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["warning"], % TransA["The selected file is empty. Process of import will be interrupted."]
		return
	}
	if (A_DefaultGui = "HS4") ;in order to have access to ListView even when HS4 is active, temporarily default gui is switched to HS3.
		Gui, HS3: Default
	GuiControl, % "Count" . v_TotalLines . A_Space . "-Redraw", % IdListView1 ;This option serves as a hint to the control that allows it to allocate memory only once rather than each time a row is added, which greatly improves row-adding performance (it may also improve sorting performance). 
	LV_Delete()
	Loop, Parse, v_TheWholeFile, `n, `r
	{
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
	
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	
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
		Loop, Parse, v_TheWholeFile, `n, `r
			if (A_LoopField)
				v_TotalLines++
		
		if (v_TotalLines = 0)
		{
			MsgBox, 48, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["warning"], % TransA["The selected file is empty. Process of export will be interrupted."]
			return
		}
		line .= v_Header . "`n`n"
		Loop, Parse, v_TheWholeFile, `n, `r
		{
			if (A_LoopField)
			{
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

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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
	Loop, Parse, v_TheWholeFile, `n, `r
		if (A_LoopField)
			v_TotalLines++
	
	if (v_TotalLines = 0)
	{
		MsgBox, 48, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["warning"], % TransA["The selected file is empty. Process of export will be interrupted."]
		return
	}
	line .= v_Header . "`n`n"
	Loop, Parse, v_TheWholeFile, `n, `r
	{
		if (A_LoopField)
		{
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
^#h::		; Event
L_GUIInit:
	
	if (v_ResizingFlag) ;if run for the very first time
	{
		Gui, HS3: +MinSize%HS3MinWidth%x%HS3MinHeight%
		Gui, HS4: +MinSize%HS4MinWidth%x%HS4MinHeight%
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
				{
							;one of the Windows mysteries, why I need to run the following line twice if c_FontSize > 10
					Gui,	HS3: Show, % "X" . ini_HS3WindoPos["X"] . A_Space . "Y" . ini_HS3WindoPos["Y"] . A_Space . "AutoSize"
					Gui,	HS3: Show, % "X" . ini_HS3WindoPos["X"] . A_Space . "Y" . ini_HS3WindoPos["Y"] . A_Space . "AutoSize"
					if (ini_ShowIntro)
						Gui, ShowIntro: Show, AutoSize Center
					v_ResizingFlag := false
					return
				}
				Gui,	HS3: Show, % "X" . ini_HS3WindoPos["X"] . A_Space . "Y" . ini_HS3WindoPos["Y"] . A_Space . "W" . ini_HS3WindoPos["W"] . A_Space . "H" . ini_HS3WindoPos["H"]
				if (ini_ShowIntro)
					Gui, ShowIntro: Show, AutoSize Center
				v_ResizingFlag := false
			return
			Case "HS4":
				if (!(ini_HS3WindoPos["W"]) or !(ini_HS3WindoPos["H"]))
				{
						;one of the Windows mysteries, why I need to run the following line twice if c_FontSize > 10
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
	Gui, Mon:Destroy
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
	ToolTip
return
	
L_TrayExit:
	ExitApp, 2	;2 = by Tray
	
STDGuiClose:
STDGuiEscape:
	Switch (A_ThisMenu)
	{
		Case "OrdHisTrig": 	IniWrite, % ini_OHTD, % HADConfig, Event_BasicHotstring, 	OHTD
		Case "UndoOfH":	IniWrite, % ini_UHTD, % HADConfig, Event_UndoHotstring, 	UHTD
		Case "TrigTips":	IniWrite, % ini_TTTD, % HADConfig, Event_TriggerstringTips, 	TTTD
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
