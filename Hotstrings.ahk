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
CoordMode, Caret,	Screen		; Only Screen makes sense for functions prepared in this script to handle position of on screen GUIs. 
CoordMode, ToolTip,	Screen		; Only Screen makes sense for functions prepared in this script to handle position of on screen GUIs.
CoordMode, Mouse,	Screen		; Only Screen makes sense for functions prepared in this script to handle position of on screen GUIs.
; - - - - - - - - - - - - - - - - - - - - - - - G L O B A L    V A R I A B L E S - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
global AppIcon					:= "hotstrings.ico" ; Imagemagick: convert hotstrings.svg -alpha off -resize 96x96 -define icon:auto-resize="96,64,48,32,16" hotstrings.ico
;@Ahk2Exe-Let vAppIcon=%A_PriorLine~U)^(.+"){1}(.+)".*$~$2% ; Keep these lines together
global AppVersion				:= "3.6.7"
;@Ahk2Exe-Let vAppVersion=%A_PriorLine~U)^(.+"){1}(.+)".*$~$2% ; Keep these lines together
;Overrides the custom EXE icon used for compilation
;@Ahk2Exe-SetMainIcon  %U_vAppIcon%
;@Ahk2Exe-SetCopyright GNU GPL 3.x
;@Ahk2Exe-SetDescription Advanced tool for hotstring management.
;@Ahk2Exe-SetProductName Original script name: %A_ScriptName%
;@Ahk2Exe-Set OriginalScriptlocation, https://github.com/mslonik/Hotstrings/tree/master/Hotstrings
;@Ahk2Exe-SetCompanyName  http://mslonik.pl
;@Ahk2Exe-SetFileVersion %U_vAppVersion%
FileInstall, hotstrings.ico, % AppIcon, 0
FileInstall, LICENSE, LICENSE, 0
; - - - - - - - - - - - - - - - - - - - - - - - S E C T I O N    O F    G L O B A L     V A R I A B L E S - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
global	v_Param 				:= A_Args[1] ; the only one parameter of Hotstrings app available to user: l like "silent mode"
,		v_IndexLog 			:= 1			;for logging, if Hotstrings application is run with d parameter.
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
,		HDemoHwnd 			:= 0 ;This is a trick to initialize global variables in order to not get warning (#Warn) message
,		ATDemoHwnd			:= 0
,		HotstringDelay			:= 0
,		WhichMenu 			:= "" ;available values: CLI or MSI
,		v_EndChar 			:= "" ;initialization of this variable is important in case user would like to hit "Esc" and GUI TT_C4 exists.
,		AppStartTime			:= "" ;When application got started, this parameter is used for performance statistics
; - - - - - - - - - - - - - - - - - - - - - - - B E G I N N I N G    O F    I N I T I A L I Z A T I O N - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
Critical, On
F_LoadCreateTranslationTxt() 			;default set of translations (English) is loaded at the very beginning in case if Config.ini doesn't exist yet, but some MsgBox have to be shown.
F_CheckCreateConfigIni() 			;1. Try to load up configuration file. If those files do not exist, create them.
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
		MsgBox, , Error, % "ErrorLevel" . A_Tab . ErrorLevel
					. "`n`n" . "A_LastError" . A_Tab . A_LastError	;183 : Cannot create a file when that file already exists.
					. "`n`n" . "Exception" . A_Tab . e
	}
}

if ( !Instr(FileExist(A_ScriptDir . "\Languages"), "D"))				; if  there is no "Languages" subfolder 
{
	FileCreateDir, %A_ScriptDir%\Languages							; Future: check against errors
	MsgBox, 48, % SubStr(A_ScriptName, 1, -4) .  ":" . A_Space . TransA["warning"], % TransA["There was no Languages subfolder, so one now is created."] . A_Space . "`n" 
	. A_ScriptDir . "\Languages"
}

F_Load_ini_Language()
if (!FileExist(A_ScriptDir . "\Languages\" . ini_Language))			; if there is no ini_language .ini file, e.g. v_langugae == Polish.txt and there is no such file in Languages folder
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
F_LoadATStyling()
F_LoadHTStyling()
F_LoadUHStyling()
F_LoadConfiguration()
F_LoadEndChars() ; Read from Config.ini values of EndChars. Modifies the set of characters used as ending characters by the hotstring recognizer.

F_ValidateIniLibSections() ;create Libraries subfolder if it doesn't exist
F_CreateLogFolder()

F_InitiateTrayMenus(v_Param)

F_GuiMain_CreateObject()
F_GuiMain_DefineConstants()
F_GuiMain_DetermineConstraints()
F_GuiMain_Redraw()
F_GuiHS4_CreateObject()
F_GuiHS4_DetermineConstraints()
F_GuiHS4_Redraw()

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
v_LibHotstringCnt := 0			;dirty trick to show initially 0 instead of 0000
GuiControl, , % IdText13,  % v_LibHotstringCnt
GuiControl, , % IdText13b, % v_LibHotstringCnt
F_LoadHotstringsFromLibraries()	;→ F_LoadDefinitionsFromFile() -> F_CreateHotstring
F_Sort_a_Triggers(a_Combined, ini_TipsSortAlphabetically, ini_TipsSortByLength)
F_GuiSearch_CreateObject()		;When all tables are full, initialize GuiSearch
F_Searching("Reload")			;prepare content of Search tables
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

Menu, ConfGUI,		Add, % TransA["Save position of application window"], 							F_SaveGUIPos
Menu, ConfGUI,		Add, % TransA["Change language"], 											:SubmenuLanguage
Menu, ConfGUI, 	Add	;To add a menu separator line, omit all three parameters.
Menu, ConfGUI, 	Add, % TransA["Show Sandbox"] . "`tF6", 									F_ToggleSandbox
if (ini_Sandbox)
	Menu, ConfGUI, Check, 	% TransA["Show Sandbox"] . "`tF6"
else
	Menu, ConfGUI, UnCheck, 	% TransA["Show Sandbox"] . "`tF6"

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
Menu, Submenu1, 		Add, % TransA["Shortcut (hotkey) definitions"],							:Submenu1Shortcuts
Menu, Submenu1, 		Add
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
Menu, Submenu1,		Add, % TransA["Events: signaling"],									% Func_GuiEventsMenu
Func_GuiEventsMenu.Call(true)		
Func_GuiStylingMenu		:= func("F_EventsStyling")		
Menu, Submenu1,		Add, % TransA["Events: styling"],										% Func_GuiStylingMenu
Func_GuiStylingMenu.Call(true)		
Menu, Submenu1,		Add, % TransA["Graphical User Interface"], 								:ConfGUI
Menu, Submenu1,		Add		
Menu, Submenu1,  	   	Add, % TransA["Toggle trigger characters (↓ or EndChars)"], 				:SubmenuEndChars
Menu, Submenu1,  	   	Add		
Menu, Submenu1,	 	Add, % TransA["Restore default configuration"],							F_RestoreDefaultConfig
Menu, Submenu1,		Add, % TransA["Open folder where Config.ini is located"],					F_OpenConfigIniLocation	
Menu, Submenu1,		Add, % TransA["Open Config.ini in your default editor"],					F_OpenConfigIniInEditor
Menu, Submenu1,		Add	;line separator		

Menu, SubmenuPath,		Add, % TransA["Libraries folder: restore it to default location"], 			F_PathLibrariesRestoreDefault
Menu, SubmenuPath,		Add, % TransA["Libraries folder: move it to new location"],					F_PathToLibraries
Menu, SubmenuPath,		Add		
Menu, SubmenuPath,		Add, % TransA["Config.ini file: restore it to default location"],			F_PathConfigIniRestoreDefault
Menu, SubmenuPath,		Add, % TransA["Config.ini file: move it to script / app location"],			F_PathConfigIni
Menu, SubmenuPath,		Add
Menu, SubmenuPath,		Add, % TransA["Script/application folder: restore it to default location"],	F_PathRestoreDefaultAppFolder
Menu, SubmenuPath,		Add, % TransA["Script/application folder: move it to new location"],			F_PathMoveAppFolder
Menu, Submenu1, 		Add, % TransA["Location of application specific data"],					:SubmenuPath

Menu, HSMenu, 			Add, % TransA["Configuration"], 										:Submenu1
Menu, HSMenu, 			Add, % TransA["Search Hotstrings (F3)"], 								F_Searching

Menu, LibrariesSubmenu,	Add, % TransA["Enable/disable libraries"], 								F_RefreshListOfLibraries
Menu, LibrariesSubmenu, 	Add, % TransA["Enable/disable triggerstring tips"], 						F_RefreshListOfLibraryTips
F_RefreshListOfLibraries()	; this function calls F_RefreshListOfLibraryTips() as both options are interrelated
; F_RefreshListOfLibraryTips()
Menu, LibrariesSubmenu,	Add	;To add a menu separator line, omit all three parameters.		
Menu, LibrariesSubmenu,	Add, % TransA["Visit public libraries webpage"],							F_PublicLibraries
Menu, LibrariesSubmenu,	Add, % TransA["Open libraries folder in Explorer"], 						F_OpenLibrariesFolderInExplorer
Menu, LibrariesSubmenu,	Add, % TransA["Download public libraries"],								F_DownloadPublicLibraries
Menu, LibrariesSubmenu,	Add	;To add a menu separator line, omit all three parameters.		
Menu, LibrariesSubmenu, 	Add, % TransA["Import from .ahk to .csv"],								F_ImportLibrary
Menu, ExportSubmenu, 	Add, % TransA["Static hotstrings"],  									F_ExportLibraryStatic
Menu, ExportSubmenu, 	Add, % TransA["Dynamic hotstrings"],  									F_ExportLibraryDynamic
Menu, LibrariesSubmenu, 	Add, % TransA["Export from .csv to .ahk"],								:ExportSubmenu
Menu, LibrariesSubmenu,	Add	;line separator
Menu, LibrariesSubmenu,	Add,	% TransA["Add new library file"],									F_GuiAddLibrary
Menu, LibrariesSubmenu,	Add, % TransA["Delete existing library file"],							F_DeleteLibrary

Menu, HSMenu, 			Add, % TransA["Libraries"], 											:LibrariesSubmenu
Menu, HSMenu, 			Add, % TransA["Clipboard Delay (F7)"], 									F_GuiHSdelay

Menu, SubmenuReload, 	Add,	% TransA["Reload in default mode"],								F_ReloadApplication
Menu, SubmenuReload, 	Add,	% TransA["Reload in silent mode"],									F_ReloadApplication
Menu, AppSubmenu, 		Add,	% TransA["Reload"],												:SubmenuReload

Menu, AppSubmenu,		Add, % TransA["Suspend Hotkeys"] . "`tF10",								F_TraySuspendHotkeys
Menu, AppSubmenu,		Add, % TransA["Pause"],												F_TrayPauseScript
Menu, AppSubmenu,		Add, % TransA["Exit"],												F_Exit
Menu, AppSubmenu,		Add	;To add a menu separator line, omit all three parameters.
Menu, AutoStartSub,		Add, % TransA["Default mode"],										F_AddToAutostart
Menu, AutoStartSub,		Add,	% TransA["Silent mode"],											F_AddToAutostart
Menu, AppSubmenu, 		Add, % TransA["Add to Autostart"],										:AutoStartSub

F_CompileSubmenu()					

Menu, AppSubmenu,		Add, % TransA["Version / Update"],										F_GuiVersionUpdate
Menu, AppSubmenu,		Add					
Menu, SubmenuLog,		Add,	% TransA["enable"],												F_MenuLogEnDis
Menu, SubmenuLog,		Add, % TransA["disable"],											F_MenuLogEnDis
Menu, AppSubmenu,		Add, % TransA["Log triggered hotstrings"],								:SubmenuLog	
Menu, AppSubmenu,		Add, % TransA["Open folder where log files are located"], 					F_OpenLogFolder
Menu, AppSubmenu,		Add
Menu, AppSubmenu,		Add, % TransA["Application statistics"],								F_AppStats

Menu,	AboutHelpSub,	Add,	% TransA["Help: Hotstrings application"] . "`tF1",					F_GuiAboutLink1
Menu,	AboutHelpSub,	Add,	% TransA["Help: AutoHotkey Hotstrings reference guide"] . "`tCtrl+F1",	F_GuiAboutLink2
Menu,	AboutHelpSub,	Add
Menu,	AboutHelpSub,	Add,	% TransA["About this application..."],								F_GuiAbout
Menu,	AboutHelpSub,	Add
Menu,	AboutHelpSub,	Add, % TransA["Show intro"],											F_GuiShowIntro

Menu, 	HSMenu,		Add, % TransA["Application"],											:AppSubmenu
Menu, 	HSMenu, 		Add, % TransA["About / Help"], 										:AboutHelpSub
Gui, 	HS3: Menu, HSMenu
Gui, 	HS4: Menu, HSMenu

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
if (ini_GuiReload) and (v_Param != "l")
	F_GUIinit()

AppStartTime := A_Now	;Date and time math can be performed with EnvAdd and EnvSub. Also, FormatTime can format the date and/or time according to your locale or preferences.
Critical, Off
; -------------------------- SECTION OF HOTKEYS ---------------------------
#if WinExist("ahk_id" TT_C1_Hwnd) or WinExist("ahk_id" TT_C2_Hwnd) or WinExist("ahk_id" TT_C3_Hwnd) or WinExist("ahk_id" TT_C4_Hwnd)
	^Tab::	;new thread starts here
	+^Tab::
	^Up::
	^Down::
	^Enter::
		Critical, On
		SetTimer, TurnOff_Ttt, Off
		; OutputDebug, % "WinExist(ahk_id TT_C1_Hwnd) or WinExist(ahk_id TT_C2_Hwnd) or WinExist(ahk_id TT_C3_Hwnd)" . "`n"
		F_TTMenu_Keyboard()
		return
	~LButton::			;if LButton is pressed outside of MenuTT then MenuTT is destroyed; but when mouse click is on/in, it runs hotstring as expected → F_TTMenu_Mouse().
		F_TTMenu_Mouse()	;the priority of g F_TTMenuStatic_Mouse is lower than this "interrupt"
		return
	LWin::
	RWin::	
	~Control::	;pressing of any modifier stops timer (triggerstring tips menu will not dissapear if time is for Triggerstring tips is limited)
	~Alt::
	~Shift::
		SetTimer, TurnOff_Ttt, Off
		return
#if
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#if WinActive("ahk_id" HS3SearchHwnd)
	^f::
	^s::
	F3::
		HS3SearchGuiEscape()
		return	;end of this thread
	F8:: ;new thread starts here
		Gui, HS3Search: +Disabled
		F_MoveList()
		return
#if

#if WinActive("ahk_id" HotstringDelay)
	F7::
		HSDelGuiClose()	;Gui event!
		HSDelGuiEscape()	;Gui event!
		return
#if

#if WinActive("ahk_id" HS3GuiHwnd) or WinActive("ahk_id" HS4GuiHwnd) ; the following hotkeys will be active only if Hotstrings windows are active at the moment. 
	F1::	;new thread starts here
		F_GuiAboutLink1()
		return

	^F1:: ;new thread starts here
		F_GuiAboutLink2()
		return

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
		F_GuiSearch_DetermineConstraints()
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
		Gui, % A_DefaultGui . ": +Disabled"	;thanks to this line user won't be able to interact with main hotstring window if TTStyling window is available
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
		v_InputString := ""	;in order to reset internal recognizer and let triggerstring tips to appear
		return
	
	F10:: ;new thread starts here
		F_TraySuspendHotkeys()
		return
#if

#if WinActive("ahk_id" MoveLibsHwnd)
	F8:: 
		F_Move()
	return	
#if

~Alt::		;if commented out, only for debugging reasons
~MButton::
~RButton::
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
	; OutputDebug, % "Regular:" . "`n"
	ToolTip,	;this line is necessary to close tooltips.
	; OutputDebug, % "Destroy..."
	Gui, Tt_HWT: Hide	;Tooltip _ Hotstring Was Triggered
	Gui, Tt_ULH: Hide	;Tooltip _ Undid the Last Hotstring
	F_DestroyTriggerstringTips(ini_TTCn)
	;OutputDebug, % "v_InputString before" . ":" . A_Space . v_InputString
	v_InputString := ""
	;OutputDebug, % "v_InputString after" . ":" . A_Space . v_InputString
	return

~LButton::	;as above, but without F_DestroyTriggerstringTips()
	ToolTip,	;this line is necessary to close tooltips.
	; OutputDebug, % "Destroy..."
	Gui, Tt_HWT: Hide	;Tooltip _ Hotstring Was Triggered
	Gui, Tt_ULH: Hide	;Tooltip _ Undid the Last Hotstring
	; OutputDebug, % "v_InputString before" . ":" . A_Space . v_InputString . "`n"
	if (!WinExist("ahk_id" HMenuCliHwnd)) and (!WinExist("ahk_id" HMenuAHKHwnd))
		v_InputString := ""
	;OutputDebug, % "v_InputString after" . ":" . A_Space . v_InputString . "`n"
	return
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#if WinExist("ahk_id" HMenuCliHwnd)	;MCLI
	Tab::
	+Tab::
	Up::
	Down::
		F_HMenuCLI_Keyboard()
		return
	1::
	2::
	3::
	4::
	5::
	6::
	7::
	Enter:: 
		; OutputDebug, % "WinExist(""ahk_id"" HMenuCliHwnd):" . A_Space . A_ThisHotkey . "`n"
		F_HMenuCLI_Keyboard()
		v_InputH.VisibleText 	:= true
,		v_InputString 			:= ""			
		return
	Esc::
		Gui, HMenuCli: Destroy
		SendRaw, % v_InputString	;SendRaw in order to correctly produce escape sequences from v_InputString ({}^!+#)
		v_InputH.VisibleText 	:= true
,		v_InputString 			:= ""	
		return
#If
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#if WinExist("ahk_id" HMenuAHKHwnd)	;MSI
	Tab::
	+Tab::
	Up::
	Down::
		F_HMenuSI_Keyboard()
		return
	1::
	2::
	3::
	4::
	5::
	6::
	7::
	Enter:: 
		F_HMenuSI_Keyboard()
		v_InputH.VisibleText 	:= true
,		v_InputString 			:= ""			
		; OutputDebug, % "WinExist(""ahk_id"" HMenuAHKHwnd)" . A_Space . A_ThisHotkey . "`n"
		return
	Esc::
		Gui, HMenuAHK: Destroy
		SendRaw, % v_InputString	;SendRaw in order to correctly produce escape sequences from v_InputString ({}^!+#)
		v_InputString 			:= ""
,		v_InputH.VisibleText 	:= true
	return
#If
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#if WinActive("ahk_id" TT_C4_Hwnd)	;Static triggerstring tips (inside separate window). User case scenario: if user decided to switch into static window (makes it active)
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
#if
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#if WinExist("ahk_id" TT_C4_Hwnd)	;Static triggerstring tips (inside separate window)
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
		GuiControl,, % IdTT_C4_LB4, |
		;OutputDebug, % "v_InputString:" . A_Tab . v_InputString . A_Tab . "v_EndChar:" . A_Tab . v_EndChar
		v_InputString 			:= ""	
		return
#If
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#If ActiveControlIsOfClass("Edit")	;https://www.autohotkey.com/docs/commands/_If.htm
	^BS::
		Send ^+{Left}{Del}	;one liner so no need to put return
		F_DestroyTriggerstringTips(ini_TTCn)
		return
	^Del::
		Send ^+{Right}{Del}
		F_DestroyTriggerstringTips(ini_TTCn)
		return
#If

; ------------------------- SECTION OF FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------------------
F_DelLibByButton()
{
	global	;assume-global mode of operation

	Gui, % A_DefaultGui . ":" . A_Space . "Submit", NoHide
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
		F_GuiMain_EnDis("Disable")	;EnDis = "Disable" or "Enable"
		F_UnloadHotstringsFromFile(v_SelectHotstringLibrary)
		FileDelete, % ini_HADL . "\" . v_SelectHotstringLibrary
		if (ErrorLevel)
			MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["Something went wrong on time of file removal."			]
		F_ValidateIniLibSections()
		F_RefreshListOfLibraries()	; this function calls F_RefreshListOfLibraryTips() as both options are interrelated
		F_UpdateSelHotLibDDL()	
		a_Combined := []				;in order to refresh arrays of triggerstring tips
		F_LoadHotstringsFromLibraries()	;in order to refresh arrays of triggerstring tips
		F_Sort_a_Triggers(a_Combined, ini_TipsSortAlphabetically, ini_TipsSortByLength)	;in order to refresh arrays of triggerstring tips
		LV_Delete()
		F_GuiMain_EnDis("Enable")	;EnDis = "Disable" or "Enable"
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
		. TransA["Logging of d(t, o, h)"] . A_Tab . A_Tab . (ini_THLog ? TransA["yes"] : TransA["no"])
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_ToggleTt()
{
	global	;assume-global mode of operation
	ini_TTTtEn := !ini_TTTtEn
	F_UpdateStateOfLockKeys(ini_HK_ToggleTt, ini_TTTtEn)	
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_Tt_ULH()
{
	global	;assume-global mode of operation
	local	TempText := TransA["Undid the last hotstring"]
,			OutputVarTemp := 0, OutputVarTempX := 0, OutputVarTempY := 0, OutputVarTempW := 0, OutputVarTempH := 0

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
F_StaticMenu_Keyboard(IsPreviousWindowIDvital*)
{
	global	;assume-global mode of operation
	local	v_PressedKey := A_ThisHotkey,	v_Temp1 := "", ShiftTabIsFound := false, ReplacementString := "", OutputVar1 := "", OutputVar2 := ""
,			NoPosInList := 0, Temp2 := "", WhichLB := "", temp := ""
	static 	IfUpF := false,	IfDownF := false, IsCursorPressed := false, IntCnt := 1

	OutputDebug, % "F_StaticMenu_Keyboard" . A_Tab . "v_PressedKey:" . A_Tab . v_PressedKey . "`n"
	GuiControlGet, OutputVar1, , % IdTT_C4_LB1	;Retrieves the contents of the control to check if static window contains any information: triggerstring tips
	GuiControlGet, OutputVar2, , % IdTT_C4_LB4	;Retrieves the contents of the control to check if static window contains any information: hotstrings
	OutputDebug, % "OutputVar1:" . A_Tab . OutputVar1 . A_Tab . "OutputVar2:" . A_Tab . OutputVar2 . "`n"
	if (!OutputVar1) and (!OutputVar2)			;if no information, leave this functionfunction
		return
	if (OutputVar1) and (!ini_ATEn)
		return
	if (OutputVar1)
	{
		if (!InStr(v_PressedKey, "^"))
			return
		WhichLB := "MTrig"
		ControlGet, Temp2, List, , , % "ahk_id" IdTT_C4_LB1
		Loop, Parse, Temp2, `n
			NoPosInList++
	}
	if (OutputVar2)
	{
		if (InStr(v_PressedKey, "^"))
			return
		WhichLB := "MHot"
		ControlGet, Temp2, List, , , % "ahk_id" IdTT_C4_LB4
		Loop, Parse, Temp2, `n
			NoPosInList++
		SetKeyDelay, 100, 100	;values (100, 100) determined experimentally
	}
	Switch WhichLB
	{
		Case "MTrig":
			if (InStr(v_PressedKey, "^Up") or InStr(v_PressedKey, "+Tab"))
			{
				IsCursorPressed := true
,				IntCnt--
				ControlSend, , {Up}, % "ahk_id" IdTT_C4_LB1
				ControlSend, , {Up}, % "ahk_id" IdTT_C4_LB2
				ControlSend, , {Up}, % "ahk_id" IdTT_C4_LB3
				ShiftTabIsFound := true
			}
			if (InStr(v_PressedKey, "^Down") or InStr(v_PressedKey, "Tab")) and (!ShiftTabIsFound)	;the same as "down"
			{
				IsCursorPressed := true
,				IntCnt++
				ControlSend, , {Down}, % "ahk_id" IdTT_C4_LB1
				ControlSend, , {Down}, % "ahk_id" IdTT_C4_LB2
				ControlSend, , {Down}, % "ahk_id" IdTT_C4_LB3
				ShiftTabIsFound := false
			}
		Case "MHot":
			if (InStr(v_PressedKey, "Up") or InStr(v_PressedKey, "+Tab"))	;the same as "up"
			{
				IsCursorPressed := true
,				IntCnt--
				ControlSend, , {Up}, % "ahk_id" IdTT_C4_LB4
				ShiftTabIsFound := true	
			}
			if (InStr(v_PressedKey, "Down") or InStr(v_PressedKey, "Tab")) and (!ShiftTabIsFound)	;the same as "down"
			{
				IsCursorPressed := true
,				IntCnt++
				ControlSend, , {Down}, % "ahk_id" IdTT_C4_LB4
				ShiftTabIsFound := false
			}		
	}

	if ((NoPosInList = 1) and IsCursorPressed)
	{
		IntCnt := 1
		return
	}
	if (IsCursorPressed)
	{
		if (IntCnt > NoPosInList)
		{
			IntCnt := NoPosInList
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
	if (InStr(v_PressedKey, "Enter")) or (InStr(v_PressedKey, "^Enter"))
	{
		v_PressedKey := IntCnt
,		IsCursorPressed := false
,		IntCnt := 1
	}
	if (v_PressedKey > NoPosInList)
		return
	Switch WhichLB
	{
		Case "MTrig":
			ControlGet, v_Temp1, List, , , % "ahk_id" IdTT_C4_LB1
			Loop, Parse, v_Temp1, `n
			{
				if (A_Index = v_PressedKey)
				{
					v_Temp1 := A_LoopField
					break
				}
			}
		Case "MHot":
			ControlGet, v_Temp1, List, , , % "ahk_id" IdTT_C4_LB4
			Loop, Parse, v_Temp1, `n
			{
				if (InStr(A_LoopField, v_PressedKey . "."))
					v_Temp1 := SubStr(A_LoopField, 4)
			}
			v_UndoHotstring 	:= v_Temp1
,			ReplacementString 	:= F_ReplaceAHKconstants(v_Temp1)
,			ReplacementString 	:= F_FollowCaseConformity(ReplacementString)
,			ReplacementString 	:= F_ConvertEscapeSequences(ReplacementString)     
	}

	if (IsPreviousWindowIDvital[1])
	{
		WinActivate, % "ahk_id" PreviousWindowID
		OutputDebug, % "PreviousWindowID 2:" . A_Tab . PreviousWindowID
	}

	Switch WhichLB
	{
		Case "MTrig":
			GuiControl,, % IdTT_C4_LB1, |
			GuiControl,, % IdTT_C4_LB2, |
			GuiControl,, % IdTT_C4_LB3, |
			; OutputDebug, % "v_InputStringOutput:" . A_Tab . v_InputString . A_Tab . "v_Temp1:" . A_Tab . v_Temp1 . A_Tab . "A_IsCritical:" . A_Tab . A_IsCritical . "`n"
			Hotstring("Reset")	;reset hotstring recognizer
			SendEvent, % "{BackSpace" . A_Space . StrLen(v_InputString) . "}"
			SendLevel, 2			;to backtrigger it must be higher than the input level of the hotstrings
			SendEvent, % v_Temp1	;If a script other than the one executing SendInput has a low-level keyboard hook installed, SendInput automatically reverts to SendEvent 
			SendLevel, 0
			v_InputString := 0
		Case "MHot":
			Switch WhichMenu
			{
				Case "SI":	F_SendIsOflag(ReplacementString, Ovar, "SendInput")
				Case "CLI":	F_ClipboardPaste(ReplacementString, Ovar)
			}
			GuiControl,, % IdTT_C4_LB4, |
			if (ini_MHSEn)
				SoundBeep, % ini_MHSF, % ini_MHSD	

			++v_LogCounter
			if (InStr(A_ThisHotkey, "?"))
				v_InputString := SubStr(A_ThisHotkey, InStr(A_ThisHotkey, ":", , 2) + 1)	;A_ThisHotkey: the most recently executed non-auto-replace hotstring (blank if none).
			temp := F_DetermineGain2(v_InputString, ReplacementString)
			v_CntCumGain += temp
			if (ini_THLog)
			{
				Switch WhichMenu
				{
					Case "SI":	FileAppend, % A_Hour . ":" . A_Min . ":" . A_Sec . "|" . v_LogCounter . "|" . "MSI" . "|" . v_InputString . "|" . v_EndChar . "|" . SubStr(v_Options, 2, -1) . "|" . v_Temp1 . "|" . temp . "|" . v_CntCumGain . "|" . "`n", % v_LogFileName
					Case "CLI":	FileAppend, % A_Hour . ":" . A_Min . ":" . A_Sec . "|" . v_LogCounter . "|" . "MCLI" . "|" . v_InputString . "|" . v_EndChar . "|" . SubStr(v_Options, 2, -1) . "|" . v_Temp1 . "|" . temp . "|" . v_CntCumGain . "|" . "`n", % v_LogFileName
				}
			}
			v_UndoTriggerstring 	:= v_InputString
,			v_InputString 			:= ""
,			v_InputH.VisibleText	:= true
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_HMenuSI_Keyboard()
{
	global	;assume-global moee
	local	v_PressedKey := A_ThisHotkey,		v_Temp1 := "", ShiftTabIsFound := false, ReplacementString := "", temp := 0
	static 	IfUpF := false,	IfDownF := false, IsCursorPressed := false, IntCnt := 1
	
	if (InStr(v_PressedKey, "Up") or InStr(v_PressedKey, "+Tab"))	;the same as "up"
	{
		IsCursorPressed := true
,		IntCnt--
		ControlSend, , {Up}, % "ahk_id" Id_LB_HMenuAHK
		ShiftTabIsFound := true
	}
	if (InStr(v_PressedKey, "Down") or InStr(v_PressedKey, "Tab")) and (!ShiftTabIsFound)	;the same as "down"
	{
		IsCursorPressed := true
,		IntCnt++
		ControlSend, , {Down}, % "ahk_id" Id_LB_HMenuAHK
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
	if (InStr(v_PressedKey, "Enter"))
	{
		v_PressedKey := IntCnt
,		IsCursorPressed := false
,		IntCnt := 1
	}
	if (v_PressedKey > v_MenuMax)
	{
		return
	}
	ControlGet, v_Temp1, List, , , % "ahk_id" Id_LB_HMenuAHK
	Loop, Parse, v_Temp1, `n
	{
		if (InStr(A_LoopField, v_PressedKey . "."))
			v_Temp1 := SubStr(A_LoopField, 4)
	}
	v_UndoHotstring 	:= v_Temp1
,	v_Temp1 			:= F_ReplaceAHKconstants(v_Temp1)
,	v_Temp1 			:= F_FollowCaseConformity(v_Temp1)
,	v_Temp1 			:= F_ConvertEscapeSequences(v_Temp1)     
	;OutputDebug, % "PreviousWindowID 2:" . A_Tab . PreviousWindowID
	if (ini_MHMP = 4)
		WinActivate, % "ahk_id" PreviousWindowID
	F_SendIsOflag(v_Temp1, Ovar, "SendInput")
	Gui, HMenuAHK: Destroy
	if (ini_MHSEn)
		SoundBeep, % ini_MHSF, % ini_MHSD	
	++v_LogCounter
	if (InStr(A_ThisHotkey, "?"))
		v_InputString := SubStr(A_ThisHotkey, InStr(A_ThisHotkey, ":", , 2) + 1)	;A_ThisHotkey: the most recently executed non-auto-replace hotstring (blank if none).
	temp := F_DetermineGain2(v_InputString, v_Temp1)
	v_CntCumGain += temp
	if (ini_THLog)
		FileAppend, % A_Hour . ":" . A_Min . ":" . A_Sec . "|" . v_LogCounter . "|" . "SI" . "|" . v_InputString . "|" . v_EndChar . "|" . SubStr(v_Options, 2, -1) . "|" . v_Temp1 . "|" . temp . "|" . v_CntCumGain . "|" . "`n", % v_LogFileName
	v_UndoTriggerstring := v_InputString
,	v_InputString 		:= ""
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
	; ToolTip, ;switch off tooltips created when Unicode symbol is clicked	2022-02-06: I'm not sure if this line is necessary
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_HMenuCLI_Keyboard()
{
	global	;assume-global mode of operation
	local	v_PressedKey := A_ThisHotkey,		v_Temp1 := "",	ShiftTabIsFound := false, ReplacementString := "", temp := 0
	static 	IfUpF := false,	IfDownF := false, IsCursorPressed := false, IntCnt := 1
;	SetKeyDelay, 100, 100	;not 100% sure if this line is necessary, but for F_StaticMenu_Keyboard it was crucial for ControlSend to run correctly
	if (InStr(v_PressedKey, "Up") or InStr(v_PressedKey, "+Tab"))	;the same as "up"
	{
		IsCursorPressed := true
		IntCnt--
		ControlSend, , {Up}, % "ahk_id" Id_LB_HMenuCli
		ShiftTabIsFound := true
	}
	if (InStr(v_PressedKey, "Down") or InStr(v_PressedKey, "Tab")) and (!ShiftTabIsFound)	;the same as "down"
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
	ControlGet, v_Temp1, List, , , % "ahk_id" Id_LB_HMenuCli
	Loop, Parse, v_Temp1, `n
	{
		if (A_Index = v_PressedKey)
			v_Temp1 := SubStr(A_LoopField, 4)
	}
	v_UndoHotstring 	:= v_Temp1
,	ReplacementString 	:= F_ReplaceAHKconstants(v_Temp1)
,	ReplacementString 	:= F_FollowCaseConformity(ReplacementString)
,	ReplacementString 	:= F_ConvertEscapeSequences(ReplacementString)     
	if (ini_MHMP = 4)
		WinActivate, % "ahk_id" PreviousWindowID
	F_ClipboardPaste(ReplacementString, Ovar)
	Gui, HMenuCli: Destroy
	if (ini_MHSEn)
		SoundBeep, % ini_MHSF, % ini_MHSD
	++v_LogCounter
	if (InStr(A_ThisHotkey, "?"))
		v_InputString := SubStr(A_ThisHotkey, InStr(A_ThisHotkey, ":", , 2) + 1)	;A_ThisHotkey: the most recently executed non-auto-replace hotstring (blank if none).
	temp := F_DetermineGain2(v_InputString, v_Temp1)
	v_CntCumGain += temp
	if (ini_THLog)
		FileAppend, % A_Hour . ":" . A_Min . ":" . A_Sec . "|" . v_LogCounter . "|" . "MCL" . "|" . v_InputString . "|" . v_EndChar . "|" . SubStr(v_Options, 2, -1) . "|" . v_Temp1 . "|" . temp . "|" . v_CntCumGain . "|" . "`n", % v_LogFileName
	v_UndoTriggerstring := v_InputString
,	v_InputString 		:= ""
	; OutputDebug, % "End of F_HMenuCLI_Keyboard:" . "`n"
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
ActiveControlIsOfClass(Class)	;https://www.autohotkey.com/docs/commands/_If.htm
{
    ControlGetFocus, FocusedControl, A
    ControlGet, FocusedControlHwnd, Hwnd,, %FocusedControl%, A
    WinGetClass, FocusedControlClass, ahk_id %FocusedControlHwnd%
    return (FocusedControlClass=Class)
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_ConvertEscapeSequences(string)	;now from file are read sequences like "`" . "t" which are 2x characters. now we have to convert this pair into single character "`t" = single Tab character
{	;theese lines are necessary to handle rear definitions of hotstrings such as those finished with `n, `r etc. https://www.autohotkey.com/docs/misc/EscapeChar.htm
	string := StrReplace(string, "``n", "`n") 
,	string := StrReplace(string, "``r", "`r")
,	string := StrReplace(string, "``b", "`b")
,	string := StrReplace(string, "``t", "`t")
,	string := StrReplace(string, "``v", "`v")
,	string := StrReplace(string, "``a", "`a")
,	string := StrReplace(string, "``f", "`f")
,	string := RegExReplace(string, "[[:blank:]].*\K``$", "")	;hottring finished with back-tick (`) prededing by blanks 
	return string
}	;future: https://www.autohotkey.com/boards/viewtopic.php?f=76&t=91953
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_DeleteLibrary()
{
	global	;assume-global mode of operation
	local	SelectedLibraryFile := "", temp := 0

	FileSelectFile, SelectedLibraryFile, 1, % ini_HADL, % TransA["Select library file to be deleted"], *.csv	;1: File Must Exist
	if (!ErrorLevel)
	{
		MsgBox, 67, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["The selected library file will be deleted. The content of this library will be unloaded from memory."]
		. "`n`n" . SelectedLibraryFile . "`n`n" . TransA["Are you sure?"]
		IfMsgBox, No
			return
		IfMsgBox, Cancel
			return
		IfMsgBox, Yes
			{
				temp := InStr(SelectedLibraryFile, "\", , 0, 1)
,				temp := SubStr(SelectedLibraryFile, temp + 1)
				F_UnloadHotstringsFromFile(temp)
				FileDelete, % SelectedLibraryFile
				if (ErrorLevel)
					MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["Something went wrong on time of file removal."	]
				F_ValidateIniLibSections()
				F_RefreshListOfLibraries()	; this function calls F_RefreshListOfLibraryTips() as both options are interrelated
				F_UpdateSelHotLibDDL()	
				a_Combined := []				;in order to refresh arrays of triggerstring tips
				F_LoadHotstringsFromLibraries()	;in order to refresh arrays of triggerstring tips
				F_Sort_a_Triggers(a_Combined, ini_TipsSortAlphabetically, ini_TipsSortByLength)	;in order to refresh arrays of triggerstring tips
			}
	}
	else
		MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["Something went wrong on time of library file selection or you've cancelled."]
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
	; IniRead, OldScriptPID, 	% ini_HADConfig, Configuration, OldScriptPID, % A_Space
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
F_PathMoveAppFolder()
{
	global	;assume-global mode of operation
	local	  OldScriptDir := A_ScriptDir, OldScriptPID := 0
			, NewScriptDir := "" 

	MsgBox, 67, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["Would you like to move ""Hotstrings"" script / application somewhere else?"]
		. A_Space . TransA["(Together with accompanying files and subfolders)."]
		. "`n`n" . TransA["Current script / application location:"]
		. "`n" . OldScriptDir	;Yes/No/Cancel + Icon Asterisk (info)
	IfMsgBox, Yes
	{		
		FileSelectFolder, NewScriptDir, % "*" . OldScriptDir, 3, % TransA["Select folder where ""Hotstrings"" folder will be moved."]	;3 = (1) a button is provided that allows the user to create new folder + (2) provide an edit field that allows the user to type the name of a folder; * = select this folder
		NewScriptDir .= "\" . SubStr(A_ScriptName, 1, -4)
		if (NewScriptDir = OldScriptDir)
		{
			MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["Nothing to do to me, Config.ini is already where you want it."]
			return
		}
		MsgBox, 35, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["question"], % TransA["Are you sure you want to move ""Hotstrings"" folder and all its content to the new location?"]
			. "`n`n" . TransA ["Old location:"] . "`n" . OldScriptDir . "`n`n" . TransA["New location:"] . "`n" . NewScriptDir	; Yes/No/Cancel + Icon Question
		IfMsgBox, Yes
		{
			FileCopyDir, % OldScriptDir, % NewScriptDir, 1				;1: Overwrite existing files
			if (!ErrorLevel)
			{
				MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["The ""Hotstrings"" folder was successfully moved to the new location:"]
					. "`n`n" . NewScriptDir
					. "`n`n" . TransA["Now application must be restarted (into default mode) in order to reload libary files from new location."]
				IniWrite, % OldScriptDir, % ini_HADConfig, Configuration, OldScriptDir
				; OldScriptPID := DllCall("GetCurrentProcessId")
				; IniWrite, % OldScriptPID, % ini_HADConfig, Configuration, OldScriptPID
				F_ReloadApplication("Run from new location", NewScriptDir)	;reload into default mode of operation
				; OutputDebug, % "ExitApp" . A_Space . "A_ScriptDir:" . A_Tab . A_ScriptDir
				try	;if no try, some warnings are still catched; with try no more warnings
					ExitApp, 0
			}
			else
			{
				MsgBox, 48, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["error"], % TransA["Something went wrong with moving of ""Hotstrings"" folder. This operation is aborted."]
				return
			}
		}
		IfMsgBox, No
			return
		IfMsgBox, Cancel
			return
	}
	IfMsgBox, No
		return
	IfMsgBox, Cancel
		return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_PathRestoreDefaultAppFolder()
{
	global	;assume-global mode of operation
	local	  OldScriptDir := A_ScriptDir
			, NewScriptDir := "C:\Program Files\Hotstrings" 

	MsgBox, 67, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["Would you like to move ""Hotstrings"" script / application to default location?"]
		. A_Space . TransA["(Together with accompanying files and subfolders)."]
		. "`n`n" . TransA["Current script / application location:"]
		. "`n" . OldScriptDir	;Yes/No/Cancel + Icon Asterisk (info)
		. "`n`n" . TransA["New location (default):"]
		. "`n" . NewScriptDir
	IfMsgBox, Yes
	{		
		if not (A_IsAdmin)
		{
			MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["To move folder into ""Program Files"" folder you must allow admin privileges to ""Hotstrings"", which will restart to move its folder."]
			try	;in order to catch any error / warning of AutoHotkey
			{
				if (A_IsCompiled)
				{
					IniWrite, % NewScriptDir, % ini_HADConfig, Configuration, OldScriptDir
					Run *RunAs "%A_ScriptFullPath%" /restart
				}
				else
				{
					IniWrite, % NewScriptDir, % ini_HADConfig, Configuration, OldScriptDir
					Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
				}
				try	;if no try, some warnings are still catched; with try no more warnings
					ExitApp, 0
			}
		}
		MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["You've cancelled this process."]
		return
	}
	IfMsgBox, No
		return
	IfMsgBox, Cancel
		return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_PathConfigIni()
{
	global	;assume-global mode of operation
	local	  Old_HADConfig 		:= ini_HADConfig	;HAD = Hotstrings Application Data
			, HADConfig_AppData  	:= A_AppData   . "\" . SubStr(A_ScriptName, 1, -4) . "\" . "Config.ini"	;Hotstrings Application Data Config .ini
			, HADConfig_App		:= A_ScriptDir . "\" . "Config.ini"

	MsgBox, 67, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["Would you like to change Config.ini file location to folder where is ""Hotstrings"" script / app?"] 
		. "`n`n" . TransA["Current Config.ini file location:"]
		. "`n" . Old_HADConfig	;Yes/No/Cancel + Icon Asterisk (info)
	IfMsgBox, Yes
	{		
		if (Old_HADConfig = HADConfig_App)
		{
			MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["Nothing to do to me, Config.ini is already where you want it."]
			return
		}
		if (Old_HADConfig = HADConfig_AppData)
		{
			FileMove, % HADConfig_AppData, *.*, Overwrite := true
			ini_HADConfig := HADConfig_App
			if (!ErrorLevel)
			{
				MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["Config.ini file was successfully moved to the new location."]
					. "`n`n" . TransA["Now application must be restarted (into default mode) in order to apply settings from new location."]
				IniWrite, % ini_HADConfig, % ini_HADConfig, Configuration, HADConfig	;HADconfig = Hotstrings Application Data Config (.ini)
				F_ReloadApplication()							;reload into default mode of operation
			}
			else
			{
				MsgBox, 48, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["error"], % TransA["Something went wrong on time of moving Config.ini file. This operation is aborted."]
				return
			}
		}
	}
	IfMsgBox, No
		return
	IfMsgBox, Cancel
		return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_PathConfigIniRestoreDefault()
{
	global	;assume-global mode of operation
	local	  Old_HADConfig := ini_HADConfig	;HAD = Hotstrings Application Data
			, HADConfig_AppData  	:= A_AppData   . "\" . SubStr(A_ScriptName, 1, -4)	;Hotstrings Application Data Config .ini
			, HADConfig_App		:= A_ScriptDir . "\" . "Config.ini"

	MsgBox, 67, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["Would you like to change Config.ini file location to default one (AppData)?"]
		. TransA["(In default folder Config.ini is protected among others against changes implied by other users)."]
		. "`n`n" . TransA["Current Config.ini file location:"]
		. "`n" . Old_HADConfig	;Yes/No/Cancel + Icon Asterisk (info)
	IfMsgBox, Yes
	{		
		if (Old_HADConfig = HADConfig_AppData)
		{
			MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["Nothing to do to me, Config.ini is already where you want it."]
			return
		}
		if (Old_HADConfig = HADConfig_App)
		{
			FileMove, % HADConfig_App, % HADConfig_AppData . "\*.*", Overwrite := true
			ini_HADConfig := HADConfig_AppData
			if (!ErrorLevel)
			{
				MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["Config.ini file was successfully moved to the new location."]
					. "`n`n" . TransA["Now application must be restarted (into default mode) in order to apply settings from new location."]
				IniWrite, % ini_HADConfig, % ini_HADConfig, Configuration, HADConfig	;HADconfig = Hotstrings Application Data Config (.ini)
				F_ReloadApplication()							;reload into default mode of operation
			}
			else
			{
				MsgBox, 48, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["error"], % TransA["Something went wrong on time of moving Config.ini file. This operation is aborted."]
				return
			}
		}
	}
	IfMsgBox, No
		return
	IfMsgBox, Cancel
		return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_PathLibrariesRestoreDefault()
{
	global	;assume-global mode
	local	HADL_DefaultLocation := A_AppData . "\" . SubStr(A_ScriptName, 1, -4) . "\" . "Libraries" 	; Hotstrings Application Data Libraries	default location ;global variable

	MsgBox, 67, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["By default library files (*.csv) are located in Users subfolder which is protected against other computer users."] 
		. "`n`n" . TransA["Would you like to move ""Libraries"" folder to this location?"]
	IfMsgBox, Yes
	{
		if (ini_HADL = HADL_DefaultLocation)
			MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["Actually the ""Libraries"" folder is already located in default location, so it won't be moved."]
				. "`n`n" . HADL_DefaultLocation
		else	
		{
			FileMoveDir, % HADL_DefaultLocation, % HADL_DefaultLocation, 2				;2: Overwrite existing files
			if (!ErrorLevel)
			{
				MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["The ""Libraries"" folder was successfully moved to the new location."] 
					. "`n`n" . TransA["Now application must be restarted (into default mode) in order to reload libary files from new location."]
				ini_HADL := HADL_DefaultLocation
				IniWrite, % ini_HADL, % ini_HADConfig, Configuration, HADL	;HAD = Hotstrings Application Data; L = Libraries 
				F_ReloadApplication()							;reload into default mode of operation
			}
			else
			{
				MsgBox, 48, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["error"], % TransA["Something went wrong with moving of ""Libraries"" folder. This operation is aborted."]
				return
			}
		}
	}
	IfMsgBox, No
		return
	IfMsgBox, Cancel
		return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_Load_ini_HADL()
{
	global	;assume-global mode
	local	LibLocation_ScriptDir := false, LibLocation_AppData := false, IsLibraryFolderEmpty1 := true, IsLibraryFolderEmpty2 := true, LibCounter1 := 0, LibCounter2 := 0

	IniRead, ini_HADL, % ini_HADConfig, Configuration, HADL, % A_Space	;Default parameter. The value to store in OutputVar (ini_HADL) if the requested key is not found. If omitted, it defaults to the word ERROR. To store a blank value (empty string), specify %A_Space%.
	if (ini_HADL = "")	;thanks to this trick existing Config.ini do not have to be erased if new configuration parameters are added.
	{	;folder Libraries can be present only in 2 locations: by default in A_AppData or in A_ScriptDir
		ini_HADL := A_AppData . "\" . SubStr(A_ScriptName, 1, -4) . "\" . "Libraries" 	; Hotstrings Application Data Libraries	default location ;global variable
		IniWrite, % ini_HADL, % ini_HADConfig, Configuration, HADL
		return
	}
	if (InStr(FileExist(A_ScriptDir . "\" . "Libraries"), "D"))
	{
		ini_HADL := A_ScriptDir . "\" . "Libraries"
		LibLocation_ScriptDir := true
		Loop, Files, % ini_HADL . "\*.csv"
		{
			IsLibraryFolderEmpty1 := false
			LibCounter1++
		}
	}
	if (InStr(FileExist(A_AppData . "\" . SubStr(A_ScriptName, 1, -4) . "\" . "Libraries"), "D"))	;if there is no folder...
	{
		ini_HADL := A_AppData . "\" . SubStr(A_ScriptName, 1, -4) . "\" . "Libraries" 	; Hotstrings Application Data Libraries	default location ;global variable
		LibLocation_AppData := true
		Loop, Files, % ini_HADL . "\*.csv"
		{
			IsLibraryFolderEmpty2 := false
			LibCounter2++
		}
	}
	if (IsLibraryFolderEmpty1) and (IsLibraryFolderEmpty2)
	{
		MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["Both optional locations for library folder are empty = do not contain any library files. The second one will be used." . "`n`n"]
			. A_ScriptDir . "\" . "Libraries" . "`n"
			. A_AppData . "\" . SubStr(A_ScriptName, 1, -4) . "\" . "Libraries"
		IniWrite, % ini_HADL, % ini_HADConfig, Configuration, HADL
		return	
	}
	if (!IsLibraryFolderEmpty1) and (IsLibraryFolderEmpty2)
	{
		ini_HADL := A_ScriptDir . "\" . "Libraries"
		IniWrite, % ini_HADL, % ini_HADConfig, Configuration, HADL
		return	
	}
	if (IsLibraryFolderEmpty1) and (!IsLibraryFolderEmpty2)
	{
		ini_HADL := A_AppData . "\" . SubStr(A_ScriptName, 1, -4) . "\" . "Libraries" 	; Hotstrings Application Data Libraries	default location ;global variable
		IniWrite, % ini_HADL, % ini_HADConfig, Configuration, HADL
		return	
	}
	if (!IsLibraryFolderEmpty1) and (!IsLibraryFolderEmpty2)
	{
		MsgBox,  % 64 + 4, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["Both optional library folder locations contain *.csv files. Would you like to use the first one?"] . A_Space
			. "(If you answer ""No"", the second one will be used)." . "`n`n"
			. A_ScriptDir . "\" . "Libraries" . "`n"
			. A_AppData . "\" . SubStr(A_ScriptName, 1, -4) . "\" . "Libraries"
		IfMsgBox, Yes
		{
			ini_HADL := A_ScriptDir . "\" . "Libraries"
			IniWrite, % ini_HADL, % ini_HADConfig, Configuration, HADL
		}
		IfMsgBox, No
		{
			ini_HADL := A_AppData . "\" . SubStr(A_ScriptName, 1, -4) . "\" . "Libraries" 	; Hotstrings Application Data Libraries	default location ;global variable
			IniWrite, % ini_HADL, % ini_HADConfig, Configuration, HADL
		}
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_PathToLibraries()
{
	global	;assume-global mode of operation
	local	Old_HADL := ini_HADL

	MsgBox, 67, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["Would you like to change the current ""Libraries"" folder location?"] 
		. A_Space . TransA["(Any existing files in destination folder will be overwritten)."] . "`n`n" . TransA["Current ""Libraries"" location:"] 
		. "`n" . Old_HADL	;Yes/No/Cancel + Icon Asterisk (info)
	IfMsgBox, Yes
	{
		FileSelectFolder, ini_HADL, % "*" . Old_HADL, 3, % TransA["Select folder where libraries (*.csv  files) will be moved."]	;3 = (1) a button is provided that allows the user to create new folder + (2) provide an edit field that allows the user to type the name of a folder; * = select this folder
		ini_HADL .= "\Libraries"
		MsgBox, 35, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["question"], % TransA["Would you like to move ""Libraries"" folder and all *.csv files to the new location?"] 
			. "`n`n" . TransA ["Old location:"] . "`n" . Old_HADL . "`n`n" . TransA["New location:"] . "`n" . ini_HADL	; Yes/No/Cancel + Icon Question
		IfMsgBox, Yes
		{
			FileMoveDir, % Old_HADL, % ini_HADL, 2				;2: Overwrite existing files
			if (!ErrorLevel)
			{
				MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["The ""Libraries"" folder was successfully moved to the new location."] 
					. "`n`n" . TransA["Now application must be restarted (into default mode) in order to reload libary files from new location."]
				IniWrite, % ini_HADL, % ini_HADConfig, Configuration, HADL	;HADconfig = Hotstrings Application Data Config (.ini)
				F_ReloadApplication()							;reload into default mode of operation
			}
			else
			{
				MsgBox, 48, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["error"], % TransA["Something went wrong with moving of ""Libraries"" folder. This operation is aborted."]
				return
			}
		}
		IfMsgBox, No
			return
		IfMsgBox, Cancel
			return
	}
	IfMsgBox, No
		return
	IfMsgBox, Cancel
		return
}
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
	local
	key := 0, value := "", ThisValue := "|"
	for key, value in a_array1
	{
		if (a_array2[key] = "En") and (InStr(value, "*"))
			ThisValue .= "✓" . "|"	
		if (a_array2[key] = "En") and (!InStr(value, "*"))						
			ThisValue .= "↓" . "|"	
		if (a_array2[key] = "Dis")
			ThisValue .= "╳" . "|"	
	}
	return ThisValue
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_ConvertArrayToString(a_array)
{
	local
	key := 0, value := "", ThisValue := "|"

	for key, value in a_array
		ThisValue .= value . "|"
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
			OutputDebug, % "A_ThisFunc:" . A_Space . A_ThisFunc . A_Tab . "return" . "`n"
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
F_OneCharPressed(ih, Char)
{	;This function is always run BEFORE the hotstring functions (eg. F_HOF_SI, F_HOF_CLI etc.). Therefore v_InputString cannot be cleared by this function.
	global	;assume-global mode of operation
	static	f_FoundTip := false, f_FoundEndChar := false

	Critical, On
	if (f_FoundEndChar) and (!f_FoundTip)		;now works undo for triggerstrings containing endchars
		v_InputString 	:= ""

	if (v_InputString = "")
	{
		f_FoundEndChar := false
,		f_FoundTip	:= false		
	}

	if (ini_MHSEn) and (WinExist("ahk_id" HMenuAHKHwnd) or WinActive("ahk_id" TT_C4_Hwnd) or WinExist("ahk_id" HMenuCliHwnd))	;Menu Hotstring Sound Enable
	{
		if (!v_InputH.VisibleText)
			SoundBeep, % ini_MHSF, % ini_MHSD	;This line will produce second beep if user presses keys on time menu is displayed.
		; OutputDebug, % "Branch Char:" . A_Tab . Char . "`n"
		return
	}
	;This is compromise: not for all triggerstrings tips will be displayed, e.g. triggerstring with option ? (question mark) and those starting with EndChar: ".ahk", "..."
	if (InStr(HotstringEndChars, Char))
	{
		if (v_InputString)	;if v_InputString is empty, do not concatenate EndChar to it.	
			v_InputString .= Char	;the global variable v_InputString is used to display triggerstring tips
		f_FoundEndChar		:= true
	}
	else	;if EndChar is found, it is not added to the v_InputString, but it is added to TrigTipsInput variable
	{
		v_InputString 		.= Char	;the global variable v_InputString is used to determine Gain parameters and to handle F_Undo functions
	}
	; OutputDebug, % "InputHookBuffer:" . A_Tab . ih.Input . "`n
	OutputDebug, % "v_InputString:" . A_Space . v_InputString . "`n"
	; OutputDebug, % "v_TrigTipsInput:" . A_Space . v_TrigTipsInput . A_Space . "v_InputString:" . A_Space . v_InputString . "`n"
	Gui, Tt_HWT: Hide	;Tooltip: Basic hotstring was triggered
	Gui, Tt_ULH: Hide	;Undid the last hotstring
	if (ini_TTTtEn) and (v_InputString)
	{
		F_PrepareTriggerstringTipsTables2(v_InputString)	;old version: F_PrepareTriggerstringTipsTables()
		if (a_Tips.Count())	;if tips are available display then
		{
			F_ShowTriggerstringTips2(a_Tips, a_TipsOpt, a_TipsEnDis, a_TipsHS, ini_TTCn)
			if (ini_TTTD > 0)
				SetTimer, TurnOff_Ttt, % "-" . ini_TTTD ;, 200 ;Priority = 200 to avoid conflicts with other threads }
		}
		else	;or destroy previously visible tips
			F_DestroyTriggerstringTips(ini_TTCn)
	}
	; OutputDebug, % "f_FoundEndChar przed:" . A_Space . f_FoundEndChar . A_Tab . "f_FoundTip:" . A_Space . f_FoundTip . "`n"
	if (f_FoundEndChar) and (v_InputString)
	{
		Loop, % a_Tips.Count()
			if (InStr(a_Tips[A_Index], v_InputString))
			{
				f_FoundTip := true
				break
			}
			else
				f_FoundTip := false	
	}
	; OutputDebug, % "f_FoundEndChar po:" . A_Space . f_FoundEndChar . A_Tab . "f_FoundTip:" . A_Space . f_FoundTip . "`n"
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_InitiateInputHook()	;why InputHook: to process triggerstring tips.
{
	global	;assume-global mode of operation
	v_InputString := "", v_TrigTipsInput := "", v_UndoHotstring := "", v_UndoTriggerstring := ""	;used by output functions: F_HOF_CLI, F_HOF_MCLI, F_HOF_MSI, F_HOF_SE, F_HOF_SI, F_HOF_SP, F_HOF_SR
,	v_InputH 			:= InputHook("V I1 L0")	;I1 by default
,	v_InputH.OnChar 	:= Func("F_OneCharPressed")
,	v_InputH.OnKeyUp 	:= Func("F_BackspaceProcessing")
,	v_InputH.OnEnd		:= Func("F_InputHookOnEnd")
	v_InputH.KeyOpt("{Backspace}", "N")
	v_InputH.Start()
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_InputHookOnEnd(ih)	;for debugging purposes
{
	global	;assume-global mode of operation
	local 	KeyName 	:= ih.EndKey, Reason	:= ih.EndReason
	
	if (ini_THLog)	
		FileAppend, % A_Hour . ":" . A_Min . ":" . A_Sec . "|" . ++v_LogCounter . "|" . "OnEnd" . "|" . KeyName 
			. "|" . "GetKeyName:" 	. "|" . GetKeyName(KeyName) 
			. "|" . "GetKeyVK:" 	. "|" . GetKeyVK(KeyName)
			. "|" . "GetKeySC:" 	. "|" . GetKeySC(KeyName)
			. "|" . "EndReason:"	. "|" . Reason
			. "|" . "`n", % v_LogFileName
	if (Reason = "Max")
		ih.Start()
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_BackspaceProcessing()
{
	global	;assume-global mode of operation
	; OutputDebug, % "F_BackspaceProcessing, beginning" . "`n"
	if (WinExist("ahk_id" HMenuCliHwnd) or WinExist("ahk_id" HMenuAHKHwnd))
	{
		if (ini_MHSEn)
		{
			SoundBeep, % ini_MHSF, % ini_MHSD
			return		
		}
	}
	else
	{
		v_InputString := SubStr(v_InputString, 1, -1)	;whole string except last character
		; OutputDebug, % "v_InputString after BS:" . A_Tab . v_InputString . "IsCritical:" . A_Tab . A_IsCritical . "`n"
		if (ini_TTTtEn) and (v_InputString)
		{
			F_PrepareTriggerstringTipsTables2(v_InputString)
			if (a_Tips.Count())
			{
				F_ShowTriggerstringTips2(a_Tips, a_TipsOpt, a_TipsEnDis, a_TipsHS, ini_TTCn)
				if ((ini_TTTtEn) and (ini_TTTD > 0))
					SetTimer, TurnOff_Ttt, % "-" . ini_TTTD ;, 200 ;Priority = 200 to avoid conflicts with other threads 
			}
		}
		if (!v_InputString)	;if v_InputString = "" = empty
			F_DestroyTriggerstringTips(ini_TTCn)
	}
	; OutputDebug, % "F_BackspaceProcessing, end" . "`n"
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_GUIinit()
{
	global	;assume-global mode
	if (f_MainGUIresizing) ;if run for the very first time
	{
		Gui, HS3: +MinSize%HS3MinWidth%x%HS3MinHeight%
		Gui, HS4: +MinSize%HS4MinWidth%x%HS4MinHeight%
		;OutputDebug, % "ini_GuiReload:" . A_Tab . ini_GuiReload . A_Tab . "ini_WhichGui:" . A_Tab . ini_WhichGui
		ini_GuiReload := false
		IniWrite, % ini_GuiReload,		% ini_HADConfig, GraphicalUserInterface, GuiReload
		
		Switch ini_WhichGui
		{
			Case "HS3":
			if (ini_HS3WindoPos["X"] = "") or (ini_HS3WindoPos["Y"] = "")
			{
				Gui, HS3: Show, AutoSize Center
				if (ini_ShowIntro)
					Gui, ShowIntro: Show, AutoSize Center
				f_MainGUIresizing := false
				return
			}
			if (ini_HS3WindoPos["W"] = "") or (ini_HS3WindoPos["H"] = "")
			{
				Gui,	HS3: Show, % "X" . ini_HS3WindoPos["X"] . A_Space . "Y" . ini_HS3WindoPos["Y"] . A_Space . "AutoSize"
				if (ini_ShowIntro)
					Gui, ShowIntro: Show, AutoSize Center
				f_MainGUIresizing := false
				return
			}
			if (ini_HS3GuiMaximized)
				Gui, HS3: Show, % "X" . ini_HS3WindoPos["X"] . A_Space . "Y" . ini_HS3WindoPos["Y"] . A_Space . "Maximize"
			else	
				Gui,	HS3: Show, % "X" . ini_HS3WindoPos["X"] . A_Space . "Y" . ini_HS3WindoPos["Y"] . A_Space . "W" . ini_HS3WindoPos["W"] . A_Space . "H" . ini_HS3WindoPos["H"]
			
			Case "HS4":
			if (ini_HS3WindoPos["W"] = "") or (ini_HS3WindoPos["H"] = "")
			{	
				Gui,	HS4: Show, % "X" . ini_HS3WindoPos["X"] . A_Space . "Y" . ini_HS3WindoPos["Y"] . A_Space . "AutoSize"
				if (ini_ShowIntro)
					Gui, ShowIntro: Show, AutoSize Center
				f_MainGUIresizing := false
				return
			}
			if (ini_HS3WindoPos["X"] = "") or !(ini_HS3WindoPos["Y"] = "")
			{
				Gui, HS4: Show, AutoSize Center
				if (ini_ShowIntro)
					Gui, ShowIntro: Show, AutoSize Center
				f_MainGUIresizing := false
				return
			}
			Gui,	HS4: Show, % "X" . ini_HS3WindoPos["X"] . A_Space . "Y" . ini_HS3WindoPos["Y"] . A_Space . "W" . ini_HS3WindoPos["W"] . A_Space . "H" . ini_HS3WindoPos["H"]
		}
		if (ini_ShowIntro)
			Gui, ShowIntro: Show, AutoSize Center
		f_MainGUIresizing := false
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
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_OpenLogFolder()
{
	Run, % "explore" . A_Space . A_AppData . "\" . SubStr(A_ScriptName, 1, -4) . "\" . "Log" 
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_OpenConfigIniLocation()
{
	Run, % "explore" . A_Space . A_AppData . "\" . SubStr(A_ScriptName, 1, -4)	
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
	Gui, ALib: Submit, NoHide
	if (v_NewLib == "")
	{
		MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["Enter a name for the new library"]
		if (WinExist("ahk_id" HS3GuiHwnd))
			Gui, HS3: -Disabled
		if (WinExist("ahk_id" HS4GuiHwnd))
			Gui, HS4: -Disabled
		return
	}
	v_NewLib .= ".csv"
	IfNotExist, % ini_HADL . "\" . v_NewLib
	{
		FileAppend,, % ini_HADL . "\" . v_NewLib, UTF-8
		MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["The library"] . A_Space . v_NewLib . A_Space . TransA["has been created."]
		if (WinExist("ahk_id" HS3GuiHwnd))
			Gui, HS3: -Disabled
		if (WinExist("ahk_id" HS4GuiHwnd))
			Gui, HS4: -Disabled
		Gui, ALib: Destroy
		
		F_ValidateIniLibSections()
		F_RefreshListOfLibraries()	; this function calls F_RefreshListOfLibraryTips() as both options are interrelated
		; F_RefreshListOfLibraryTips()
		F_UpdateSelHotLibDDL()
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
	
	if (ini_HK_IntoEdit != "~#c")
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
	F_WhichGui()
	Gui, % A_DefaultGui . ":" . A_Space . "Show"
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
F_TrayPauseScript()
{
	global	;assume  global mode
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
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_TraySuspendHotkeys()
{
	global	;assume-global mode
	Suspend, Toggle
	if (A_IsSuspended)
	{
		Menu, Tray, 		Check, 	% TransA["Suspend Hotkeys"] . "`tF10"
		Menu, AppSubmenu, 	Check, 	% TransA["Suspend Hotkeys"] . "`tF10"
	}
	else
	{
		Menu, Tray, 		UnCheck, 	% TransA["Suspend Hotkeys"] . "`tF10"
		Menu, AppSubmenu,	UnCheck, 	% TransA["Suspend Hotkeys"] . "`tF10"
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
	Gui, ShortDef: Hide
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
ShortDefGuiClose()
{
	ShortDefGuiEscape()
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
HS3SearchGuiEscape() ; Gui event!
{
	global	;assume-global mode
	;F_WhichGui()	;sets A_DefaultGui to one of the current windows
	if (WinExist("ahk_id" HS3GuiHwnd))	;activates one of the main Windows
	{
		Gui, HS3Search:	+Disabled
		Gui, HS3: -Disabled
	}
		; Gui, HS3: -Disabled
	if (WinExist("ahk_id" HS4GuiHwnd))
		Gui, HS4: -Disabled		
	Gui, HS3Search: Hide
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
	ini_SWPos["X"] := ini_ReadTemp
	IniRead, ini_ReadTemp, 						% ini_HADConfig, StaticTriggerstringHotstring, SWPosY, % A_Space
	if (ini_ReadTemp = "")	;thanks to this trick existing Config.ini do not have to be erased if new configuration parameters are added.
		IniWrite, % ini_ReadTemp, % ini_HADConfig, StaticTriggerstringHotstring, SWPosY
	ini_SWPos["Y"] := ini_ReadTemp
	IniRead, ini_ReadTemp, 						% ini_HADConfig, StaticTriggerstringHotstring, SWPosW, % A_Space
	if (ini_ReadTemp = "")	;thanks to this trick existing Config.ini do not have to be erased if new configuration parameters are added.
		IniWrite, % ini_ReadTemp, % ini_HADConfig, StaticTriggerstringHotstring, SWPosW
	ini_SWPos["W"] := ini_ReadTemp
	IniRead, ini_ReadTemp, 						% ini_HADConfig, StaticTriggerstringHotstring, SWPosH, % A_Space
	if (ini_ReadTemp = "")	;thanks to this trick existing Config.ini do not have to be erased if new configuration parameters are added.
		IniWrite, % ini_ReadTemp, % ini_HADConfig, StaticTriggerstringHotstring, SWPosH
	ini_SWPos["H"] := ini_ReadTemp
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
			GuiControl,, % IdTT_C4_LB1, |
			GuiControl,, % IdTT_C4_LB2, |
			GuiControl,, % IdTT_C4_LB3, |
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_InitiateTrayMenus(v_Param)
{
	global	;assume-global mode
	Switch v_Param
	{
		Case "l":
		Menu, Tray, NoStandard									; remove all the rest of standard tray menu
		if (!FileExist(AppIcon))
		{
			MsgBox, 68, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["Information"], % TransA["The icon file"] . ":" . "`n`n" . AppIcon . "`n`n" . TransA["doesn't exist in application folder"] . "." 
				. A_Space . TransA["Would you like to download the icon file?"] . "`n`n" . TransA["If you answer ""Yes"", the icon file will be downloaded. If you answer ""No"", the default AutoHotkey icon will be used."]
			IfMsgBox, Yes
				URLDownloadToFile, https://raw.githubusercontent.com/mslonik/Hotstrings/master/hotstrings.ico, % AppIcon	;2022-01-28
			IfMsgBox, No
				AppIcon := "*"
		}
		Menu, Tray, Icon,		% AppIcon 						;GUI window uses the tray icon that was in effect at the time the window was created. FlatIcon: https://www.flaticon.com/ Cloud Convert: https://www.cloudconvert.com/
		Menu, Tray, Add,		% SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["Silent mode"], F_GuiAbout
		Menu, Tray, Default,	% SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["Silent mode"]
		Menu, Tray, Add, 		% TransA["Reload in default mode"], 	F_ReloadApplication	;it is possible to reload, but then application will be run in default mode of operation (opposit to silent mode)
		Menu, Tray, Add										;line separator 
		Menu, Tray, Add,		% TransA["Suspend Hotkeys"] . "`tF10",	F_TraySuspendHotkeys
		Menu, Tray, Add,		% TransA["Pause application"],		F_TrayPauseScript
		Menu  Tray, Add,		% TransA["Exit application"],			F_TrayExit		

		Case "":
			Menu, Tray, NoStandard									; remove all the rest of standard tray menu
			; OutputDebug, % "AppIcon:" . AppIcon . A_Tab . "A_ScriptDir:" . A_Tab . A_ScriptDir .  A_Tab . "A_WorkingDir:" . A_Tab . A_WorkingDir . "`n"
			if (!FileExist(AppIcon))
			{
				MsgBox, 68, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["Information"], % TransA["The icon file"] . ":" . "`n`n" . AppIcon . "`n`n" . TransA["doesn't exist in application folder"] . "." 
					. A_Space . TransA["Would you like to download the icon file?"] . "`n`n" . TransA["If you answer ""Yes"", the icon file will be downloaded. If you answer ""No"", the default AutoHotkey icon will be used."]
				IfMsgBox, Yes
				{
					OutputDebug, % "AppIcon:" . A_Tab . AppIcon
					URLDownloadToFile, 	https://raw.githubusercontent.com/mslonik/Hotstrings/master/hotstrings.ico, % AppIcon	;2022-01-28
				}
				IfMsgBox, No
					AppIcon := "*"
			}
			Menu, Tray, Icon,		% AppIcon 						;GUI window uses the tray icon that was in effect at the time the window was created. FlatIcon: https://www.flaticon.com/ Cloud Convert: https://www.cloudconvert.com/
			Menu, Tray, Add,		% SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["Default mode"], 	F_GuiAbout
			Menu, Tray, Add																	;line separator 
			Menu, Tray, Add, 		% TransA["Edit Hotstrings"], 										F_GUIinit
			Menu, Tray, Default, 	% TransA["Edit Hotstrings"]
			Menu, Tray, Add																	;line separator 
			Menu, Tray, Add,		% TransA["Help: Hotstrings application"] . "`tF1",					F_GuiAboutLink1
			Menu, Tray, Add,		% TransA["Help: AutoHotkey Hotstrings reference guide"] . "`tCtrl+F1", 	F_GuiAboutLink2
			Menu, Tray, Add																	;line separator 
			Menu, SubmenuReload, 	Add,		% TransA["Reload in default mode"],						F_ReloadApplication
			Menu, SubmenuReload, 	Add,		% TransA["Reload in silent mode"],							F_ReloadApplication
			Menu, Tray, Add,		% TransA["Reload"],												:SubmenuReload
			Menu  Tray, Add																	;line separator 
			Menu, Tray, Add, 		% TransA["Application statistics"],								F_AppStats
			Menu, Tray, Add																	;line separator 
			Menu, Tray, Add,		% TransA["Suspend Hotkeys"] . "`tF10",								F_TraySuspendHotkeys
			Menu, Tray, Add,		% TransA["Pause application"],									F_TrayPauseScript
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
	IniRead ini_Language, % ini_HADConfig, GraphicalUserInterface, Language				; Load from Config.ini file specific parameter: language into variable ini_Language, e.g. ini_Language = English.txt
	if (ini_Language = "")	;thanks to this trick existing Config.ini do not have to be erased if new configuration parameters are added.
	{
		ini_Language := "English.txt"
		IniWrite, % ini_Language, % ini_HADConfig,  GraphicalUserInterface, Language
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_GuiTrigTipsMenuDefC4()
{
	global	;assume-global mode
	local  vOutput1 := 0, vOutput1X := 0, vOutput1Y := 0, vOutput1W := 0, vOutput1H := 0
		, vOutput2 := 0, vOutput2X := 0, vOutput2Y := 0, vOutput2W := 0, vOutput2H := 0
		, OutputString := ""
		, PosOutputVar := 0, PosOutputVarX := 0, PosOutputVarY := 0, PosOutputVarW := 0, PosOutputVarH := 0
	
	Gui, TT_C4: New, +AlwaysOnTop +Caption +HwndTT_C4_Hwnd +Resize, % A_ScriptName . ":" . A_Space . TransA["Static triggerstring / hotstring menus"]
	Gui, TT_C4: Margin, 0, 0
	if (ini_ATEn)
	{
		if (ini_ATBgrCol = "custom")
			Gui, TT_C4: Color,, 	% ini_ATBgrColCus	;background of listbox
		else
			Gui, TT_C4: Color,, 	% ini_ATBgrCol	;background of listbox
		if (ini_ATTyFaceCol = "custom")		
			Gui, TT_C4: Font, 		% "s" . ini_ATTySize . A_Space . "c" . ini_ATTyFaceColCus, % ini_ATTyFaceFont
		else
			Gui, TT_C4: Font, 		% "s" . ini_ATTySize . A_Space . "c" . ini_ATTyFaceCol, % ini_ATTyFaceFont
	}
	else
	{
		if (ini_TTBgrCol = "custom")
			Gui, TT_C4: Color,, 	% ini_TTBgrColCus	;background of listbox
		else
			Gui, TT_C4: Color,, 	% ini_TTBgrCol	;background of listbox
		if (ini_TTTyFaceCol = "custom")		
			Gui, TT_C4: Font, 		% "s" . ini_TTTySize . A_Space . "c" . ini_TTTyFaceColCus, % ini_TTTyFaceFont
		else
			Gui, TT_C4: Font, 		% "s" . ini_TTTySize . A_Space . "c" . ini_TTTyFaceCol, % ini_TTTyFaceFont
	}
	Gui, TT_C4: Add, Text, 		% "x0 y0 HwndIdTT_C4_T1", Whatever
	GuiControlGet, vOutput1, Pos, % IdTT_C4_T1
	Gui, TT_C4: Add, Listbox, 	% "x0 y0 HwndIdTT_C4_LB1" . A_Space . "r" . ini_MNTT . A_Space . "w" . vOutput1W + 4 . A_Space . "g" 	. "F_TTMenuStatic_Mouse"
	Gui, TT_C4: Add, Text, 		% "x0 y0 HwndIdTT_C4_T2", W	;the widest latin letter; unfortunately once set Text has width which can not be easily changed. Therefore it's easiest to add the next one to measure its width.
	GuiControlGet, vOutput2, Pos, % IdTT_C4_T2
	Gui, TT_C4: Add, Listbox, 	% "HwndIdTT_C4_LB2" . A_Space . "r" . ini_MNTT . A_Space . "w" . vOutput2W + 4 	. A_Space . "g" 		. "F_TTMenuStatic_Mouse"
	Gui, TT_C4: Add, Listbox, 	% "HwndIdTT_C4_LB3" . A_Space . "r" . ini_MNTT . A_Space . "w" . vOutput1W * 2 + 4 	. A_Space . "g" 	. "F_TTMenuStatic_Mouse"
	Gui, TT_C4: Add, Button,  	% "x0 y0 HwndIdTT_C4_B1" . A_Space . "g" . "F_TT_C4_B1", % TransA["Save window position"]
	GuiControl, Hide, % IdTT_C4_T1
	GuiControl, Hide, % IdTT_C4_T2
	GuiControl, Font, % IdTT_C4_LB1		;fontcolor of listbox
	GuiControl, Font, % IdTT_C4_LB2		;fontcolor of listbox
	GuiControl, Font, % IdTT_C4_LB3		;fontcolor of listbox
	if (ini_HMTyFaceCol = "custom")
		Gui, TT_C4: Font, % "s" . ini_HMTySize . A_Space . "c" . ini_HMTyFaceColCus, % ini_HMTyFaceFont
	else
		Gui, TT_C4: Font, % "s" . ini_HMTySize . A_Space . "c" . ini_HMTyFaceCol, % ini_HMTyFaceFont
	Gui, TT_C4: Add, Listbox, % "x0 y0 w250 HwndIdTT_C4_LB4" . A_Space . "r" . 7 . A_Space . "g" . "F_MouseMenuCombined"
	GuiControl, Font, % IdTT_C4_LB4
	
	GuiControl, Choose, % IdTT_C4_LB1, 1
	GuiControlGet, PosOutputVar, Pos, % IdTT_C4_LB1
	GuiControl, Move, % IdTT_C4_LB2, % "x" . PosOutputVarX + PosOutputVarW . A_Space . "y" . PosOutputVarY
	GuiControl, Choose, % IdTT_C4_LB2, 1
	GuiControlGet, PosOutputVar, Pos, % IdTT_C4_LB2
	GuiControl, Move, % IdTT_C4_LB3, % "x" . PosOutputVarX + PosOutputVarW . A_Space . "y" . PosOutputVarY
	GuiControl, Choose, % IdTT_C4_LB3, 1
	GuiControlGet, PosOutputVar, Pos, % IdTT_C4_LB3
	GuiControl, Move, % IdTT_C4_LB4, % "x" . PosOutputVarX + PosOutputVarW + 2 * c_xmarg . A_Space . "y" . PosOutputVarY
	GuiControlGet, PosOutputVar, Pos, % IdTT_C4_LB4
	GuiControl, Move, % IdTT_C4_B1, % "x" . PosOutputVarX . A_Space . "y" . PosOutputVarY + PosOutputVarH + c_ymarg
	
	if (ini_SWPos["X"] = "") or (ini_SWPos["Y"] = "")	
		Gui, TT_C4: Show, Center AutoSize NoActivate
	else
		Gui, TT_C4: Show, % "X" . ini_SWPos["X"] . A_Space . "Y" . ini_SWPos["Y"] . A_Space . "NoActivate" . A_Space . "AutoSize"
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
F_GuiTrigTipsMenuDefC3(AmountOfRows, LongestString)
{
	global	;assume-global mode of operation
	local  vOutput1 := 0, vOutput1X := 0, vOutput1Y := 0, vOutput1W := 0, vOutput1H := 0
		, W_LB1 := 0, W_LB2 := 0, W_LB3 := 0, X_LB2 := 0, Y_LB2 := 0, X_LB3 := 0, Y_LB3 := 0
		, OutputString := ""
	
	Loop, Parse, LongestString	;exchange all letters into "w" which is the widest letter in latin alphabet (the worst case scenario)
		OutputString .= "w"		;the widest ordinary letter in alphabet
	Gui, TT_C3: New, +AlwaysOnTop -Caption +ToolWindow +HwndTT_C3_Hwnd
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
	Gui, TT_C3: Add, Text, 		% "HwndIdTT_C3_T1 x0 y0", % OutputString
	GuiControlGet, vOutput1, Pos, % IdTT_C3_T1
	W_LB1 	:= vOutput1W
	Gui, TT_C3: Add, Listbox, 	% "HwndIdTT_C3_LB1 x0 y0" . A_Space . "r" . AmountOfRows . A_Space . "w" . W_LB1 + 4 . A_Space . "g" . "F_TTMenuStatic_Mouse"
	Gui, TT_C3: Add, Text, 		% "HwndIdTT_C3_T2 x0 y0", W	;the widest latin letter; unfortunately once set Text has width which can not be easily changed. Therefore it's easiest to add the next one to measure its width.
	GuiControlGet, vOutput1, Pos, % IdTT_C3_T2
	W_LB2 	:= vOutput1W
	GuiControlGet, vOutput1, Pos, % IdTT_C3_LB1
	X_LB2 	:= vOutput1X + vOutput1W, Y_LB2	:= vOutput1Y
	Gui, TT_C3: Add, Listbox, 	% "HwndIdTT_C3_LB2" . A_Space . "x" . X_LB2 . A_Space . "y" . Y_LB2 . A_Space . "r" . AmountOfRows . A_Space . "w" . W_LB2 + 4 . A_Space . "g" . "F_TTMenuStatic_Mouse"
	GuiControlGet, vOutput1, Pos, % IdTT_C3_LB2
	X_LB3	:= vOutput1X + vOutput1W, Y_LB3	:= Y_LB2, W_LB3	:= W_LB1
	Gui, TT_C3: Add, Listbox, 	% "HwndIdTT_C3_LB3" . A_Space . "x" . X_LB3 . A_Space . "y" . Y_LB3 . A_Space . "r" . AmountOfRows . A_Space . "w" . W_LB3 + 4 . A_Space . "g" . "F_TTMenuStatic_Mouse"
	GuiControl, Hide, % IdTT_C3_T1
	GuiControl, Hide, % IdTT_C3_T2
	GuiControl, Font, % IdTT_C3_LB1		;fontcolor of listbox
	GuiControl, Font, % IdTT_C3_LB2		;fontcolor of listbox
	GuiControl, Font, % IdTT_C3_LB3		;fontcolor of listbox
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_GuiTrigTipsMenuDefC2(AmountOfRows, LongestString)
{
	global	;assume-global mode
	local  vOutput := 0, vOutputX := 0, vOutputY := 0, vOutputW := 0, vOutputH := 0, OutputString := ""
		, W_LB1 := 0, W_LB2 := 0, X_LB2 := 0, Y_LB2 := 0
	
	Loop, Parse, LongestString	;exchange all letters into "w" which is the widest letter in latin alphabet (the worst case scenario)
		OutputString .= "w"		;the widest ordinary letter in alphabet
	Gui, TT_C2: New, +AlwaysOnTop -Caption +ToolWindow +HwndTT_C2_Hwnd
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
	W_LB1 	:= vOutputW
	Gui, TT_C2: Add, Listbox, 	% "HwndIdTT_C2_LB1 x0 y0" . A_Space . "r" . AmountOfRows . A_Space . "w" . W_LB1 + 4 . A_Space . "g" . "F_TTMenuStatic_Mouse"	;thanks to "g" it will not be a separate thread even upon mouse click
	Gui, TT_C2: Add, Text, 		% "HwndIdTT_C2_T2 x0 y0", W	;the widest latin letter; unfortunately once set Text has width which can not be easily changed. Therefore it's easiest to add the next one to measure its width.
	GuiControlGet, vOutput, Pos, % IdTT_C2_T2
	W_LB2 	:= vOutputW
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
	global	;assume-global mode
	local vOutput := 0, vOutputX := 0, vOutputY := 0, vOutputW := 0, vOutputH := 0, OutputString := ""
	
	Loop, Parse, LongestString	;exchange all letters into "w" which is the widest letter in latin alphabet (the worst case scenario)
		OutputString .= "w"		;the widest ordinary letter in alphabet
	Gui, TT_C1: New, +AlwaysOnTop -Caption +ToolWindow +HwndTT_C1_Hwnd
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
	global	;assume-global mode
	static OneTimeMemory := true
	
	if (OneTimeMemory)
	{
		if (ini_THLog)
			Menu, SubmenuLog,	Check,	% TransA["enable"]
		else
			Menu, SubmenuLog,	Check,	% TransA["disable"]
		OneTimeMemory := false
	}
	else
	{
		ini_THLog := !(ini_THLog)
		if (ini_THLog)
		{
			Menu, SubmenuLog,	Check,	% TransA["enable"]
			Menu, SubmenuLog,	UnCheck,	% TransA["disable"]
		}
		else
		{
			Menu, SubmenuLog,	Check,	% TransA["disable"]
			Menu, SubmenuLog,	UnCheck,	% TransA["enable"]
		}
		IniWrite, % ini_THLog, % ini_HADConfig, Configuration, THLog
	}
	if (ini_THLog) ;If logging is enabled, prepare new folder and create file named as specified in the following pattern.
	{	
		v_LogFileName := % HADLog . "\" . A_YYYY . A_MM . A_DD . "_" . "HotstringsLog" . ".txt"
		FileAppend, % "--------------------------------------------------------------------------------------------------------------" . "`n" ; amount of "-" characters as for mono typeface (Courier)
			. "hh:mm:ss" . "|" . "hotstring counter" . "|" . "entered triggerstring" . "|" . "trigger" . "|" . "triggerstring options" . "|" . "hotstring" . "|" . "gain" . "|" . "cumulative gain" . "|" . "`n", % v_LogFileName, UTF-8
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_TTMenu_Keyboard()	;this is separate, dedicated function to handle "interrupt" coming from "g" event
{
	global	;assume-global mode
	local	v_PressedKey := A_ThisHotkey,		v_Temp1 := "",		ClipboardBack := "", OutputVarTemp := "", ShiftTabIsFound := false
	static 	IfUpF := false,	IfDownF := false, IsCursorPressed := false, IntCnt := 0, v_MenuMax := 0

	if (!ini_ATEn)
		return
	v_MenuMax := a_Tips.Count()
	;OutputDebug, % "v_PressedKey:" . A_Tab . v_PressedKey
	Switch ini_TTCn	
	{
		Case 1:	ControlGet, v_Temp1, List, , , % "ahk_id" IdTT_C1_LB1	;check if triggerstring tips listbox is empty.
		Case 2:	ControlGet, v_Temp1, List, , , % "ahk_id" IdTT_C2_LB1	;check if triggerstring tips listbox is empty.
		Case 3:	ControlGet, v_Temp1, List, , , % "ahk_id" IdTT_C3_LB1	;check if triggerstring tips listbox is empty.
		Case 4:	ControlGet, v_Temp1, List, , , % "ahk_id" IdTT_C4_LB1	;check if triggerstring tips listbox is empty.
	}
	if (!v_Temp1)	;if it is empty and one of the special shortcuts has been pressed, give it back (let it run)
	{
		Switch v_PressedKey
		{
			Case "^Tab":	v_PressedKey := "{Ctrl down}" . "{Tab}" . "{Ctrl up}"
			Case "+^Tab":	v_PressedKey := "{Shift down}" . "{Ctrl down}" . "{Tab}" . "{Ctrl up}" . "{Shift up}"
			Case "^Up":	v_PressedKey := "{Ctrl down}" . "{Up}" . "{Ctrl up}"
			Case "^Down":	v_PressedKey := "{Ctrl down}" . "{Down}" . "{Ctrl up}"
			Case "^Enter":	v_PressedKey := "{Ctrl down}" . "{Enter}" . "{Ctrl up}"
		}
		SendInput, % v_PressedKey
		;OutputDebug, % "v_PressedKey:" . A_Tab . v_PressedKey
		return
	}
	if (InStr(v_PressedKey, "^Up") or InStr(v_PressedKey, "+^Tab"))	;the same as "up"
	{
		IsCursorPressed := true
		IntCnt--
		Switch ini_TTCn
		{
			Case 1: 
				ControlSend, , {Up}, % "ahk_id" IdTT_C1_LB1
			Case 2: 
				ControlSend, , {Up}, % "ahk_id" IdTT_C2_LB1
				ControlSend, , {Up}, % "ahk_id" IdTT_C2_LB2
			Case 3: 
				ControlSend, , {Up}, % "ahk_id" IdTT_C3_LB1
				ControlSend, , {Up}, % "ahk_id" IdTT_C3_LB2
				ControlSend, , {Up}, % "ahk_id" IdTT_C3_LB3
			Case 4:
				ControlSend, , {Up}, % "ahk_id" IdTT_C4_LB1
				ControlSend, , {Up}, % "ahk_id" IdTT_C4_LB2
				ControlSend, , {Up}, % "ahk_id" IdTT_C4_LB3
		}
		ShiftTabIsFound := true
	}
	if ((InStr(v_PressedKey, "^Down")) or (InStr(v_PressedKey, "^Tab") and (!ShiftTabIsFound)))	;the same as "down"
	{
		IsCursorPressed := true
		IntCnt++
		Switch ini_TTCn
		{
			Case 1: 
				ControlSend, , {Down}, % "ahk_id" IdTT_C1_LB1
			Case 2: 
				ControlSend, , {Down}, % "ahk_id" IdTT_C2_LB1
				ControlSend, , {Down}, % "ahk_id" IdTT_C2_LB2
			Case 3: 
				ControlSend, , {Down}, % "ahk_id" IdTT_C3_LB1
				ControlSend, , {Down}, % "ahk_id" IdTT_C3_LB2
				ControlSend, , {Down}, % "ahk_id" IdTT_C3_LB3
			Case 4:
				ControlSend, , {Down}, % "ahk_id" IdTT_C4_LB1
				ControlSend, , {Down}, % "ahk_id" IdTT_C4_LB2
				ControlSend, , {Down}, % "ahk_id" IdTT_C4_LB3
		}
	}
	if InStr(v_PressedKey, "^Enter")
	{
		v_PressedKey 		:= IntCnt
,		IsCursorPressed	:= false
,		IntCnt 			:= 0
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
	if (v_PressedKey > v_MenuMax)
		return
	Switch ini_TTCn
	{
		Case 1: ControlGet, v_Temp1, List, , , % "ahk_id" IdTT_C1_LB1
		Case 2: ControlGet, v_Temp1, List, , , % "ahk_id" IdTT_C2_LB1
		Case 3: ControlGet, v_Temp1, List, , , % "ahk_id" IdTT_C3_LB1
		Case 4: ControlGet, v_Temp1, List, , , % "ahk_id" IdTT_C4_LB1
	}
	; OutputDebug, % "v_Temp1:" . A_Space . v_Temp1 . A_Tab . "v_PressedKey:" . A_Space . v_PressedKey . "`n"
	Loop, Parse, v_Temp1, `n
	{
		if (A_Index = v_PressedKey)
		{
			v_Temp1 := A_LoopField
			break
		}	
	}
	; OutputDebug, % "v_Temp1:" . A_Space . v_Temp1 . A_Tab . "v_InputString:" . A_Space . v_InputString . "`n"
	if (ini_TTCn = 4)
		WinActivate, % "ahk_id" PreviousWindowID
	F_DestroyTriggerstringTips(ini_TTCn)
	Hotstring("Reset")
	SendEvent, % "{BackSpace" . A_Space . StrLen(v_InputString) . "}"
	SendLevel, 2	;to backtrigger it must be higher than the input level of the hotstrings
	SendEvent, % v_Temp1	;If a script other than the one executing SendInput has a low-level keyboard hook installed, SendInput automatically reverts to SendEvent 
	SendLevel, 0
	v_InputString := ""
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_LoadConfiguration()
{
	global ;assume-global mode
	ini_CPDelay 				:= 300		;1-1000 [ms], default: 300
	IniRead, ini_CPDelay, 					% ini_HADConfig, Configuration, ClipBoardPasteDelay,		% A_Space
	if (ini_CPDelay = "")	;thanks to this trick existing Config.ini do not have to be erased if new configuration parameters are added.
	{
		ini_CPDelay := 300
		IniWrite, % ini_CPDelay, % ini_HADConfig, Configuration, ClipBoardPasteDelay 
	}
	ini_HotstringUndo			:= true
	IniRead, ini_HotstringUndo,				% ini_HADConfig, Configuration, HotstringUndo,			% A_Space
	if (ini_HotstringUndo = "")	;thanks to this trick existing Config.ini do not have to be erased if new configuration parameters are added.
	{
		ini_HotstringUndo 		:= true
		Iniwrite, % ini_HotstringUndo, % ini_HADConfig, Configuration, HotstringUndo
	}
	ini_ShowIntro				:= true
	IniRead, ini_ShowIntro,					% ini_HADConfig, Configuration, ShowIntro,				% A_Space	;GUI with introduction to Hotstrings application.
	if (ini_ShowIntro = "")	;thanks to this trick existing Config.ini do not have to be erased if new configuration parameters are added.
	{
		ini_ShowIntro 			:= true
		Iniwrite, % ini_ShowIntro, % ini_HADConfig, Configuration, ShowIntro
	}
	ini_HK_Main				:= "#^h"
	IniRead, ini_HK_Main,					% ini_HADConfig, Configuration, HK_Main,				% A_Space
	if (ini_HK_Main = "")	;thanks to this trick existing Config.ini do not have to be erased if new configuration parameters are added.
	{
		ini_HK_Main 			:= "#^h"
		IniWrite, % ini_HK_Main, % ini_HADConfig, Configuration, HK_Main
	}
	if (ini_HK_Main != "none")
	{
		#If v_Param != "l"
		Hotkey, If, v_Param != "l" 
		Hotkey, % ini_HK_Main, F_GUIInit, On
		Hotkey, If			;To turn off context sensitivity (that is, to make subsequently-created hotkeys work in all windows)
	}
	
	ini_HK_IntoEdit			:= "~#c"
	IniRead, ini_HK_IntoEdit,				% ini_HADConfig, Configuration, HK_IntoEdit,		% A_Space
	if (ini_HK_IntoEdit = "")	;thanks to this trick existing Config.ini do not have to be erased if new configuration parameters are added.
	{
		ini_HK_IntoEdit := "~#c"
		IniWrite, % ini_HK_IntoEdit, % ini_HADConfig, Configuration, HK_IntoEdit
	}
	
	ini_HK_UndoLH				:= "~#z"
	IniRead, ini_HK_UndoLH,					% ini_HADConfig, Configuration, HK_UndoLH,		% A_Space
	if (ini_HK_UndoLH = "")		;thanks to this trick existing Config.ini do not have to be erased if new configuration parameters are added.
	{
		ini_HK_UndoLH 			:= "~#z"
		IniWrite, % ini_HK_UndoLH, % ini_HADConfig, Configuration, HK_UndoLH
	}
	if (ini_HK_UndoLH != "none")
		Hotkey, % ini_HK_UndoLH, F_Undo, On

	ini_HK_ToggleTt			:= "none"	;HK = HotKey, ToggleTt = Toggle Triggerstring tips
	IniRead, ini_HK_ToggleTt,				% ini_HADConfig, Configuration, HK_ToggleTt,		% A_Space
	if (ini_HK_ToggleTt = "")	;thanks to this trick existing Config.ini do not have to be erased if new configuration parameters are added.
	{
		ini_HK_ToggleTt 		:= "none"
		IniWrite, % ini_HK_ToggleTt, % ini_HADConfig, Configuration, HK_ToggleTt
	}
     
	if (ini_HK_ToggleTt != "none")
     {
		Hotkey, % ini_HK_ToggleTt, F_ToggleTt, On
          F_UpdateStateOfLockKeys(ini_HK_ToggleTt, ini_TTTtEn)
     }

	ini_THLog					:= false
	IniRead, ini_THLog,						% ini_HADConfig, Configuration, THLog,			% A_Space
	if (ini_THLog = "")			;thanks to this trick existing Config.ini do not have to be erased if new configuration parameters are added.
	{
		ini_THLog 			:= false
		IniWrite, % ini_THLog, % ini_HADConfig, Configuration, THLog
	}
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
	F_EvAT_R1R2()
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
	Gui, GuiEvents: Add,	Tab3, vEvTab3 gF_EvTab3,						% TransA["Basic hotstring is triggered"] . "||" . TransA["Menu hotstring is triggered"] . "|" 
		. TransA["Undid the last hotstring"] . "|" . TransA["Triggerstring tips"] . "|" . TransA["Active triggerstring tips"] . "|" . TransA["Static triggerstring / hotstring menus"] . "|"
	
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
	
	Gui, GuiEvents: Add,	Text,	HwndIdEvTt_T25,					% TransA["Triggerstring tips"] . A_Space . "+" . A_Space . TransA["Triggers"] . A_Space . "+" . A_Space . TransA["Hotstrings"]
	GuiControl, Hide, % IdEvTt_T25
	
	Gui, GuiEvents: Tab, 											% TransA["Active triggerstring tips"]
	Gui, GuiEvents: Font,	% "s" . c_FontSize . A_Space . "bold" . A_Space . "c" . c_FontColor, % c_FontType
	Gui, GuiEvents: Add,	Text, 	HwndIdEvAT_T1,						% TransA["Active triggerstring tips"] . ":"
	Gui, GuiEvents: Font,	% "s" . c_FontSize + 2 . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, GuiEvents: Add,	Text, 	HwndIdEvAT_T2, 					ⓘ
	T_ATT1 := func("F_ShowLongTooltip").bind(TransA["T_ATT1"])
	GuiControl, +g, % IdEvAT_T2, % T_ATT1
	Gui, GuiEvents: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, % c_FontType
	Gui, GuiEvents: Add,	Radio,	HwndIdEvAT_R1 vEvAT_R1R2 gF_EvAT_R1R2,	% TransA["enable"]
	Gui, GuiEvents: Add,	Radio, 	HwndIdEvAT_R2 gF_EvAT_R1R2,			% TransA["disable"]	
	Gui, GuiEvents: Add, 	Button, 	HwndIdEvAT_B1 gF_EvAT_B1,			% TransA["Tooltip test"]
	Gui, GuiEvents: Add,	Button,	HwndIdEvAT_B2 gF_EvAT_B2 +Default,		% TransA["Apply"]
	Gui, GuiEvents: Add,	Button,	HwndIdEvAT_B3 gF_EvAT_B3,			% TransA["Close"]
	Gui, GuiEvents: Add,	Button,	HwndIdEvAT_B4 gF_EvAT_B4,			% TransA["Cancel"]
	
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
			, PreviousEvAT_R1R2 := ""
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
		, PreviousEvAT_R1R2 := EvAT_R1R2
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
						F_EvAT_B2() ;Apply changes
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
		Case % TransA["Active triggerstring tips"]:
			GuiControl, +Default, % IdEvAT_B2	;default button Apply
			F_EvSM_R1R2()
		Case % TransA["Static triggerstring / hotstring menus"]:
			GuiControl, +Default, % IdEvSM_B2	;default button Apply
			F_EvAT_R1R2()
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
F_EvAT_B4()	;Event Active Triggerstring Tips Button Cancel
{
	global ;assume-global mode
	Gui, Tt_HWT: Hide			;Tooltip: Basic hotstring was triggered
     F_CloseSubGui(WhatGuiToDestroy := "GuiEvents")
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EvAT_B2()	;Event Active Triggerstring Tips Button Apply
{
	global ;assume-global mode
	Gui, GuiEvents: Submit, NoHide
	Switch EvAT_R1R2	;Tooltip enable
	{
		Case 1:	ini_ATEn := true
		Case 2:	ini_ATEn := false
	}
	IniWrite, % ini_ATEn, 	% ini_HADConfig, Event_ActiveTriggerstringTips, 	ATEn
	Gui, Tt_HWT: Hide		;Tooltip: Basic hotstring was triggered
	F_EvTab3(true)			;to memory that something was applied
	if (ini_TTCn = 4)		;static triggerstring / hotstring GUI 
	{
		Gui, TT_C4: Destroy
		F_GuiTrigTipsMenuDefC4()
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EvAT_B3()	;Event Active Triggerstring Tips Button Close
{
	global ;assume-global mode
	Gui, GuiEvents: Submit
	Switch EvAT_R1R2	;Tooltip enable
	{
		Case 1:	ini_ATEn := true
		Case 2:	ini_ATEn := false
	}
	IniWrite, % ini_ATEn, 	% ini_HADConfig, Event_ActiveTriggerstringTips, 	ATEn
	Gui, Tt_HWT: Hide			;Tooltip: Basic hotstring was triggered
	F_EvTab3(true)	;to memory that something was applied
     F_CloseSubGui(WhatGuiToDestroy := "GuiEvents")
	if (ini_TTCn = 4)		;static triggerstring / hotstring GUI 
	{
		Gui, TT_C4: Destroy
		F_GuiTrigTipsMenuDefC4()
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EvAT_B1()	;Event Active Triggerstring Tips Button Tooltip test
{
	global ;assume-global mode
	local BinParameter := 0, a_Tips := []
	Gui, GuiEvents: Submit, NoHide
	Switch EvAT_R1R2
	{
		Case 1: BinParameter := 1
		Case 2: BinParameter := 0
	}
	Loop, % EvTt_S2
	{
		if (A_Index = 1)
			a_Tips[A_Index] := "A" . Chr(65 + EvTt_S2 - A_Index) . A_Space . "Demo" . A_Space . A_Index
		else
			a_Tips[A_Index] := Chr(65 + EvTt_S2 - A_Index) . A_Space . "Demo" . A_Space . A_Index
	}
	F_Sort_a_Triggers(a_Tips, EvTt_C1, EvTt_C2)
	F_ShowTriggerstringTips2(a_Tips, a_TipsOpt, a_TipsEnDis, a_TipsHS, ini_TTCn)
	if ((EvTt_R1R2 = 1) and (EvTt_R3R4 = 1))
		SetTimer, TurnOff_Ttt, % "-" . EvTt_S1	 ;, 200 ;Priority = 200 to avoid conflicts with other threads 
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EvAT_R1R2()
{
	global ;assume-global mode
	Gui, GuiEvents: Submit, NoHide
	; F_TTMenu_KeyboardAHK_Hotkeys(EvAT_R1R2)
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EvTt_B1()	;Event Tooltip (is triggered) Button Tooltip test 
{
	global ;assume-global mode
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
			a_Combined[A_Index]			:= a_Tips[A_Index] . "|" . a_TipsOpt[A_Index] . "|" . a_TipsEnDis[A_Index] . "|" . a_TipsHS[A_Index]
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
	}
	if (EvUH_R5R6 = 2)
	{
		MouseGetPos, v_MouseX, v_MouseY
		Gui, Tt_ULH: Show, % "x" . v_MouseX + 20 . A_Space . "y" . v_MouseY - 20
		if (ini_UHTD > 0)
			SetTimer, TurnOff_UHE, % "-" . ini_UHTD, 60 ;Priority = 60 to avoid conflicts with other threads 
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
	v_xNext := c_xmarg, v_yNext += HofText
	GuiControl, Move, % IdEvTt_R1, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvTt_R1
	v_xNext += v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvTt_R2, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += 3 * HofText
	GuiControl, Move, % IdEvTt_T3, % "x+" . v_xNext . A_Space . "y+" . v_yNext - 2 . A_Space . "w+" . TotalWidth . A_Space . "h+" . 1
	GuiControl, Move, % IdEvTt_T4, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvTt_T4
	v_xNext += v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvTt_T5, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += HofText
	GuiControl, Move, % IdEvTt_T6, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += HofText
	GuiControl, Move, % IdEvTt_R3, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvTt_R3
	v_xNext += v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvTt_R4, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += HofText
	GuiControl, Move, % IdEvTt_T7, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += HofText, v_wNext := TheWidestText
	GuiControl, Move, % IdEvTt_S1, % "x+" . v_xNext . A_Space . "y+" . v_yNext . A_Space . "w+" . v_wNext
	v_xNext += 2 * c_xmarg + TheWidestText
	GuiControl, Move, % IdEvTt_T8, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += 3 * HofText
	GuiControl, Move, % IdEvTt_T9, % "x+" . v_xNext . A_Space . "y+" . v_yNext - 2 . A_Space . "w+" . TotalWidth . A_Space . "h+" . 1
	GuiControl, Move, % IdEvTt_T10, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvTt_T10
	v_xNext += v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvTt_T11, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += HofText
	GuiControl, Move, % IdEvTt_R5, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvTt_R5
	v_xNext += v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvTt_R6, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += 3 * HofText
	GuiControl, Move, % IdEvTt_T12, % "x+" . v_xNext . A_Space . "y+" . v_yNext - 2 . A_Space . "w+" . TotalWidth . A_Space . "h+" . 1
	GuiControl, Move, % IdEvTt_T13, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvTt_T13
	v_xNext += v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvTt_T14, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += HofText
	GuiControl, Move, % IdEvTt_C1, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvTt_C1
	v_xNext += v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvTt_C2, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += 3 * HofText
	GuiControl, Move, % IdEvTt_T15, % "x+" . v_xNext . A_Space . "y+" . v_yNext - 2 . A_Space . "w+" . TotalWidth . A_Space . "h+" . 1
	GuiControl, Move, % IdEvTt_T16, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvTt_T16
	v_xNext += v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvTt_T17, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += HofText, v_wNext := TheWidestText
	GuiControl, Move, % IdEvTt_S2, % "x+" . v_xNext . A_Space . "y+" . v_yNext . A_Space . "w+" . v_wNext
	v_xNext += 2 * c_xmarg + TheWidestText
	GuiControl, Move, % IdEvTt_T18, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += 3 * HofText
	GuiControl, Move, % IdEvTt_T19, % "x+" . v_xNext . A_Space . "y+" . v_yNext - 2 . A_Space . "w+" . TotalWidth . A_Space . "h+" . 1
	GuiControl, Move, % IdEvTt_T20, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvTt_T20
	v_xNext += v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvTt_T21, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += HofText, v_wNext := TheWidestText
	GuiControl, Move, % IdEvTt_DDL1, % "x+" . v_xNext . A_Space . "y+" . v_yNext . A_Space . "w+" . v_wNext	
	v_xNext := c_xmarg, v_yNext += 3 * HofText
	GuiControl, Move, % IdEvTt_T22, % "x+" . v_xNext . A_Space . "y+" . v_yNext - 2 . A_Space . "w+" . TotalWidth . A_Space . "h+" . 1
	GuiControl, Move, % IdEvTt_T23, % "x+" . v_xNext . A_Space . "y+" . v_yNext	
	GuiControlGet, v_OutVarTemp, Pos, % IdEvTt_T23
	v_xNext += v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvTt_T24, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvTt_T25
	v_xNext := c_xmarg, v_yNext += HofText, v_wNext := v_OutVarTempW + 3 * c_ymarg
	GuiControl, Move, % IdEvTt_DDL2, % "x+" . v_xNext . A_Space . "y+" . v_yNext . A_Space . "w+" . v_wNext
	v_xNext := c_xmarg, v_yNext += HofText
	GuiControl, Move, % IdEvTt_T25, % "x+" . v_xNext . A_Space . "y+" . v_yNext	;fake text, just to measure its width, but unfortunately as it cannot be deleted, it has to be shifted somewhere
	v_xNext := c_xmarg, v_yNext += 3 * HofText
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
	
	v_xNext := c_xmarg, v_yNext := c_ymarg
	GuiControl, Move, % IdEvAT_T1, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvAT_T1
	v_xNext += v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvAT_T2, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += HofText
	GuiControl, Move, % IdEvAT_R1, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvAT_R1
	v_xNext += v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvAT_R2, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += 3 * HofText
	GuiControl, Move, % IdEvAT_B1, % "x+" . v_xNext . A_Space . "y+" . v_yNext	
	GuiControlGet, v_OutVarTemp, Pos, % IdEvAT_B1
	v_xNext += v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvAT_B2, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvAT_B2
	v_xNext += v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvAT_B3, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvAT_B3
	v_xNext += v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvAT_B4, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	maxY5 := v_yNext
	
	v_xNext := c_xmarg, v_yNext := c_ymarg ;beginning of static triggerstring / hostring menus
	GuiControl, Move, % IdEvSM_T1, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvSM_T1
	v_xNext += v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvSM_T2, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += HofText
	GuiControl, Move, % IdEvSM_R1, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvSM_R1
	v_xNext += v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvSM_R2, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	v_xNext := c_xmarg, v_yNext += 3 * HofText
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
	
	v_xNext := c_xmarg, v_yNext := MaxY
	GuiControl, Move, % IdEvAT_B1, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvAT_B1
	v_xNext += v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvAT_B2, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvAT_B2
	v_xNext += v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvAT_B3, % "x+" . v_xNext . A_Space . "y+" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdEvAT_B3
	v_xNext += v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdEvAT_B4, % "x+" . v_xNext . A_Space . "y+" . v_yNext	
	
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
				if (EvBH_R3R4 > 0)
					SetTimer, TurnOff_OHE, % "-" . EvBH_S1, 40 ;Priority = 40 to avoid conflicts with other threads 
			}
			else
			{
				MouseGetPos, v_MouseX, v_MouseY
				Gui, Tt_HWT: Show, % "x" v_MouseX + 20 . A_Space . "y" . v_MouseY - 20 	;Tooltip _ Hotstring Was Triggered
				if (EvBH_R3R4 > 0)
					SetTimer, TurnOff_OHE, % "-" . EvBH_S1, 40 ;Priority = 40 to avoid conflicts with other threads 
			}
		}
		if (EvBH_R5R6 = 2)
		{
			MouseGetPos, v_MouseX, v_MouseY
			Gui, Tt_HWT: Show, % "x" v_MouseX + 20 . A_Space . "y" . v_MouseY - 20 	;Tooltip _ Hotstring Was Triggered
			if (EvBH_R3R4 > 0)
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
F_EvBH_B4(CloseGuiEvents)	;Events Basic Hotstring (is triggered) Button Close
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
		Case 1: 		GuiControl,, % IdEvUH_R6, 1
		Case 2: 		GuiControl,, % IdEvUH_R5, 1
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
	Switch ini_ATEn
	{
		Case true:	GuiControl,, % IdEvAT_R1, 1
		Case false:	GuiControl,, % IdEvAT_R2, 1
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_LoadATStyling()
{
	global ;assume-global mode
	ini_ATBgrCol		:= "green"
,	ini_ATTyFaceCol	:= "black"
,	ini_ATTyFaceFont	:= "Calibri"
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
	IniRead, ini_ATTyFaceFont, 		% ini_HADConfig, EvStyle_AT, ATTypefaceFont, Calibri
	if (!ini_ATTyFaceFont)
		ini_ATTyFaceFont := "Calibri"
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
,	ini_HMTyFaceFont	:= "Calibri"
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
	IniRead, ini_HMTyFaceFont, 		% ini_HADConfig, EvStyle_HM, HMTypefaceFont, Calibri
	if (!ini_HMTyFaceFont)
		ini_HMTyFaceFont := "Calibri"
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
,	ini_TTTyFaceFont	:= "Calibri"
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
	IniRead, ini_TTTyFaceFont, 		% ini_HADConfig, EvStyle_TT, TTTypefaceFont, Calibri
	if (!ini_TTTyFaceFont)
		ini_TTTyFaceFont := "Calibri"
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
,		Arial|Calibri||Comic Sans MS|Consolas|Courier|Fixedsys|Lucida Console|Microsoft Sans Serif|Script|System|Tahoma|Times New Roman|Verdana
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
		Case % TransA["Active triggerstring tips styling"]:		F_EventsStyling_DDL_TypefaceCol("AT")
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
	DynVarRef1 := "Id" . WhichItem . "TTstyling_E1"
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
		Case % TransA["Active triggerstring tips styling"]:		F_EventsStyling_DDL_BackgCol("AT")
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

		Case % TransA["Active triggerstring tips styling"]:
			ini_ATBgrCol := "green"
			GuiControl, ChooseString, % IdATstyling_DDL1, % ini_ATBgrCol
			GuiControl,, % IdATstyling_E1, % TransA["HTML color RGB value, e.g. 00FF00"] 
			GuiControl, Disable, % IdATstyling_E1
		
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

		Case % TransA["Active triggerstring tips styling"]:
			ini_ATTyFaceCol := "black"
			GuiControl, ChooseString, % IdATstyling_DDL2, % ini_ATTyFaceCol
			GuiControl,, % IdATstyling_E2, % TransA["HTML color RGB value, e.g. 00FF00"] 
			GuiControl, Disable, % IdATstyling_E2

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
			ini_TTTyFaceFont := "Calibri"
			GuiControl, ChooseString, % IdTTstyling_DDL3, % ini_TTTyFaceFont

		Case % TransA["Hotstring menu styling"]:
			ini_HMTyFaceFont := "Calibri"
			GuiControl, ChooseString, % IdHMstyling_DDL3, % ini_HMTyFaceFont

		Case % TransA["Active triggerstring tips styling"]:
			ini_ATTyFaceFont := "Calibri"
			GuiControl, ChooseString, % IdATstyling_DDL3, % ini_ATTyFaceFont

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

		Case % TransA["Active triggerstring tips styling"]:
			ini_ATTySize := 10
			GuiControl, ChooseString, % IdATstyling_DDL4, % ini_ATTySize
		
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
,			ATS_TTBgrColCus := "", ATS_TTTyFaceColCus := "" 
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

		Case % TransA["Active triggerstring tips styling"]:
			if (ATS_DDL1 = "custom")
			{
				GuiControlGet, OutputVarTemp,, % IdATstyling_E1
				if (!RegExMatch(OutputVarTemp, "^[[:xdigit:]]{6}"))
				{
					MsgBox, 48, % SubStr(A_ScriptName, 1, -4) .  ":" . A_Space . TransA["warning"], % TransA["Incorrect value. Select custom RGB hex value. Please try again."] . A_Space . "`n" 
					Gui, ATDemo: Destroy
					return
				}
				else 
					ATS_TTBgrColCus := OutputVarTemp
			}
			if (ATS_DDL2 = "custom")
			{
				GuiControlGet, OutputVarTemp,, % IdATstyling_E2
				if (!RegExMatch(OutputVarTemp, "^[[:xdigit:]]{6}"))
				{
					MsgBox, 48, % SubStr(A_ScriptName, 1, -4) .  ":" . A_Space . TransA["warning"], % TransA["Incorrect value. Select custom RGB hex value. Please try again."] . A_Space . "`n" 
					Gui, ATDemo: Destroy
					return
				}
				else 
					ATS_TTTyFaceColCus := OutputVarTemp
			}
			WinGetPos, Window1X, Window1Y, Window1W, Window1H, % "ahk_id" . EvStylingHwnd
			ControlGetPos, OutputVarTempX, OutputVarTempY, , , , ahk_id %IdATstyling_LB1%
			Gui, ATDemo: New, -Caption +ToolWindow +HwndATDemoHwnd
			Gui, ATDemo: Margin, 0, 0
			if (ATS_DDL1 = "custom")
				Gui, ATDemo: Color,, % ATS_TTBgrColCus
			else
				Gui, ATDemo: Color,, % ATS_DDL1
			if (ATS_DDL2 = "custom")		
				Gui, ATDemo: Font, % "s" . ATS_DDL4 . A_Space . "c" . ATS_TTTyFaceColCus, % ATS_DDL3
			else
				Gui, ATDemo: Font, % "s" . ATS_DDL4 . A_Space . "c" . ATS_DDL2, % ATS_DDL3
			Gui, ATDemo: Add, Listbox, HwndIdATDemo r5, % TransA["Row"] . " 1|" . TransA["Row"] . " 2|" . TransA["Row"] . " 3|" . TransA["Row"] . " 4|" . TransA["Row"] . " 5"
			Gui, ATDemo: Show, % "x" . Window1X + OutputVarTempX . A_Space . "y" . Window1Y + OutputVarTempY . A_Space "NoActivate"	;future: prevent parent window from moving: https://autohotkey.com/board/topic/17759-window-system-menu-manipulator-library-v20/

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
,			TTS_TTBgrColCus := "", TTS_TTTyFaceColCus := "" 
,			HMS_TTBgrColCus := "", HMS_TTTyFaceColCus := ""  
, 			ATS_TTBgrColCus := "", ATS_TTTyFaceColCus := ""  
, 			HTS_TTBgrColCus := "", HTS_TTTyFaceColCus := ""  
, 			UHS_TTBgrColCus := "", UHS_TTTyFaceColCus := ""  
,			OutputVarTemp   := ""

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
		Case % TransA["Active triggerstring tips styling"]:		F_EventsStyling_Apply("AT")
		Case % TransA["Tooltip: ""Hotstring was triggered"""]:		F_EventsStyling_Apply("HT")
		Case % TransA["Tooltip: ""Undid the last hotstring"""]:	F_EventsStyling_Apply("UH")
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
		Case % TransA["Active triggerstring tips styling"]:		F_EventsStyling_Close("AT")
		Case % TransA["Tooltip: ""Hotstring was triggered"""]:		F_EventsStyling_Close("HT")
		Case % TransA["Tooltip: ""Undid the last hotstring"""]:	F_EventsStyling_Close("UH")
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
		Case % TransA["Active triggerstring tips styling"]:		
			F_CloseSubGui(WhatGuiToDestroy := "ATDemo")
			F_CloseSubGui(WhatGuiToDestroy := "EventsStyling")
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
		. TransA["Active triggerstring tips styling"] . "|" 
		. TransA["Tooltip: ""Hotstring was triggered"""] . "|"
		. TransA["Tooltip: ""Undid the last hotstring"""] . "|"

	Gui, EventsStyling: Tab, 			% TransA["Triggerstring tips styling"]
	F_GuiStyling_Section(TabId := "TT")
	Gui, EventsStyling: Tab, 			% TransA["Hotstring menu styling"]
	F_GuiStyling_Section(TabId := "HM")
	Gui, EventsStyling: Tab,				% TransA["Active triggerstring tips styling"]
 	F_GuiStyling_Section(TabId := "AT")
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
		, PreviousATS_DDL1 := "", PreviousATS_DDL2 := "", PreviousATS_DDL3 := "", PreviousATS_DDL4 := ""
		, PreviousHTS_DDL1 := "", PreviousHTS_DDL2 := "", PreviousHTS_DDL3 := "", PreviousHTS_DDL4 := ""
		, PreviousUHS_DDL1 := "", PreviousUHS_DDL2 := "", PreviousUHS_DDL3 := "", PreviousUHS_DDL4 := ""
		; , PreviousTab3 := ""
		; , OneTimeTTS := true

	if (OneTime[1] = true)
	{
		;PreviousTab3 := EventsStylingTab3
		  PreviousTTS_DDL1 := TTS_DDL1, PreviousTTS_DDL2 := TTS_DDL2, PreviousTTS_DDL3 := TTS_DDL3, PreviousTTS_DDL4 := TTS_DDL4
		, PreviousHMS_DDL1 := HMS_DDL1, PreviousHMS_DDL2 := HMS_DDL2, PreviousHMS_DDL3 := HMS_DDL3, PreviousHMS_DDL4 := HMS_DDL4
		, PreviousATS_DDL1 := ATS_DDL1, PreviousATS_DDL2 := ATS_DDL2, PreviousATS_DDL3 := ATS_DDL3, PreviousATS_DDL4 := ATS_DDL4
		, PreviousHTS_DDL1 := HTS_DDL1, PreviousHTS_DDL2 := HTS_DDL2, PreviousHTS_DDL3 := HTS_DDL3, PreviousHTS_DDL4 := HTS_DDL4
		, PreviousUHS_DDL1 := UHS_DDL1, PreviousUHS_DDL2 := UHS_DDL2, PreviousUHS_DDL3 := UHS_DDL3, PreviousUHS_DDL4 := UHS_DDL4
		; , OneTimeTTS := false
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
		F_GuiStyling_LoadValues()
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
	if (WinExist("ahk_id" ATDemoHwnd))
		Gui, ATDemo: 		Destroy
	if (WinExist("ahk_id" ATDemoHwnd))
		Gui, HTDemo: 		Destroy
	if (WinExist("ahk_id" ATDemoHwnd))
		Gui, UHDemo: 		Destroy
	
	Gui, EventsStyling: Submit, NoHide
	if (EventsStylingTab3 != PreviousTab3)
	{
		Switch PreviousTab3
		{
			Case % TransA["Triggerstring tips styling"]:				F_EventsStylingTab3_Update("TT")
			Case % TransA["Hotstring menu styling"]:				F_EventsStylingTab3_Update("HM")
			Case % TransA["Active triggerstring tips styling"]:		F_EventsStylingTab3_Update("AT")
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
,	v_yNext += HofText
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
,	v_yNext += HofText
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
,	v_yNext += HofText
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
,	v_yNext += HofText
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
,	v_yNext += HofText
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
F_GuiStyling_LoadValues()
{
	global	;assume-global mode of operation

	GuiControl, ChooseString, % IdTTstyling_DDL1, % ini_TTBgrCol
	if (ini_TTBgrCol = "custom")
	{
		GuiControl,, % IdTTstyling_E1, % ini_TTBgrColCus
		GuiControl, Enable, % IdTTstyling_E1
	}

	GuiControl, ChooseString, % IdHMstyling_DDL1, % ini_HMBgrCol
	if (ini_HMBgrCol = "custom")
	{
		GuiControl,, % IdHMstyling_E1, % ini_HMBgrColCus
		GuiControl, Enable, % IdHMstyling_E1
	}

	GuiControl, ChooseString, % IdATstyling_DDL1, % ini_ATBgrCol
	if (ini_ATBgrCol = "custom")
	{
		GuiControl,, % IdATstyling_E1, % ini_ATBgrColCus
		GuiControl, Enable, % IdATstyling_E1
	}

	GuiControl, ChooseString, % IdHTstyling_DDL1, % ini_HTBgrCol
	if (ini_HTBgrCol = "custom")
	{
		GuiControl,, % IdHTstyling_E1, % ini_HTBgrColCus
		GuiControl, Enable, % IdHTstyling_E1
	}
	
	GuiControl, ChooseString, % IdUHstyling_DDL1, % ini_UHBgrCol
	if (ini_UHBgrCol = "custom")
	{
		GuiControl,, % IdUHstyling_E1, % ini_UHBgrColCus
		GuiControl, Enable, % IdUHstyling_E1
	}

	GuiControl, ChooseString, % IdTTstyling_DDL2, % ini_TTTyFaceCol
	if (ini_TTTyFaceCol = "custom")
	{
		GuiControl,, % IdTTstyling_E2, % ini_TTTyFaceColCus
		GuiControl, Enable, % IdTTstyling_E2
	}

	GuiControl, ChooseString, % IdHMstyling_DDL2, % ini_HMTyFaceCol
	if (ini_HMTyFaceCol = "custom")
	{
		GuiControl,, % IdHMstyling_E2, % ini_HMTyFaceColCus
		GuiControl, Enable, % IdHMstyling_E2
	}

	GuiControl, ChooseString, % IdATstyling_DDL2, % ini_ATTyFaceCol
	if (ini_ATTyFaceCol = "custom")
	{
		GuiControl,, % IdATstyling_E2, % ini_ATTyFaceColCus
		GuiControl, Enable, % IdATstyling_E2
	}

	GuiControl, ChooseString, % IdHTstyling_DDL2, % ini_HTTyFaceCol
	if (ini_HTTyFaceCol = "custom")
	{
		GuiControl,, % IdHTstyling_E2, % ini_HTTyFaceColCus
		GuiControl, Enable, % IdHTstyling_E2
	}

	GuiControl, ChooseString, % IdUHstyling_DDL2, % ini_UHTyFaceCol
	if (ini_UHTyFaceCol = "custom")
	{
		GuiControl,, % IdUHstyling_E2, % ini_UHTyFaceColCus
		GuiControl, Enable, % IdUHstyling_E2
	}

	GuiControl, ChooseString, % IdTTstyling_DDL3, % ini_TTTyFaceFont
	GuiControl, ChooseString, % IdHMstyling_DDL3, % ini_HMTyFaceFont
	GuiControl, ChooseString, % IdATstyling_DDL3, % ini_ATTyFaceFont
	GuiControl, ChooseString, % IdHTstyling_DDL3, % ini_HTTyFaceFont
	GuiControl, ChooseString, % IdUHstyling_DDL3, % ini_UHTyFaceFont

	GuiControl, ChooseString, % IdTTstyling_DDL4, % ini_TTTySize
	GuiControl, ChooseString, % IdHMstyling_DDL4, % ini_HMTySize
	GuiControl, ChooseString, % IdATstyling_DDL4, % ini_ATTySize
	GuiControl, ChooseString, % IdHTstyling_DDL4, % ini_HTTySize
	GuiControl, ChooseString, % IdUHstyling_DDL4, % ini_UHTySize
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_EventsStyling(OneTime*)
{
	global	;assume-global mode
	local Window1X := 0, Window1Y := 0, Window1W := 0, Window1H := 0
		,Window2X := 0, Window2Y := 0, Window2W := 0, Window2H := 0
		,NewWinPosX := 0, NewWinPosY := 0
	
	if (OneTime[3])	
		Gui, % A_Gui . ": +Disabled"	;thanks to this line user won't be able to interact with main hotstring window if TTStyling window is available
	F_GuiEventsStyling_CreateObjects()
	F_GuiEventsStyling_DetermineConstants("TT")	;TT = Triggerstring Tips
	F_GuiEventsStyling_DetermineConstants("HM")	;HM = Hotsring Menu
	F_GuiEventsStyling_DetermineConstants("AT")	;AT = Active Triggerstring
	F_GuiEventsStyling_DetermineConstants("HT")	;HT = Tooltip: Hostring is triggered
	F_GuiEventsStyling_DetermineConstants("UH")	;UH = Tooltip: Unid the last hostring
	F_GuiStyling_LoadValues()
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
		GuiControl, Hide, % IdATstyling_LB1
		GuiControl, Hide, % IdHTstyling_LB1
		GuiControl, Hide, % IdUHstyling_LB1
		Gui, TTDemo: Hide
		Gui, HMDemo: Hide
		Gui, ATDemo: Hide
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
			F_GuiTrigTipsMenuDefC2(a_Tips.Count(), F_LongestTrigTipString(a_Tips))	;Each time new list of triggerstring tips is created also new gui is created. as a consequence new set of hotkeys is created.			; GuiControl,, % IdTT_C2_LB1, ||	;make TT_C2_LB1 empty
			GuiControl,, % IdTT_C2_LB1, % F_ConvertArrayToString(a_Tips)
			GuiControl,, % IdTT_C2_LB2, % F_TrigTipsSecondColumn(a_TipsOpt, a_TipsEnDis)
			a_TTMenuPos := F_WhereDisplayMenu(ini_TTTP)
			F_FlipMenu(TT_C2_Hwnd, a_TTMenuPos[1], a_TTMenuPos[2], "TT_C2")

		Case 3: 
			Gui, TT_C3: Destroy
			F_GuiTrigTipsMenuDefC3(a_Tips.Count(), F_LongestTrigTipString(a_Tips))	;Each time new list of triggerstring tips is created also new gui is created. as a consequence new set of hotkeys is created.
			GuiControl,, % IdTT_C3_LB1, % F_ConvertArrayToString(a_Tips)
			GuiControl,, % IdTT_C3_LB2, % F_TrigTipsSecondColumn(a_TipsOpt, a_TipsEnDis)
			GuiControl,, % IdTT_C3_LB3, % F_ConvertArrayToString(a_TipsHS)
			a_TTMenuPos := F_WhereDisplayMenu(ini_TTTP)
			F_FlipMenu(TT_C3_Hwnd, a_TTMenuPos[1], a_TTMenuPos[2], "TT_C3")	

		Case 4:
			PreviousWindowID := WinExist("A")
			; OutputDebug, % "PreviousWindowID:" . A_Tab . PreviousWindowID . "`n"
			; GuiControl,, % IdTT_C4_LB1, |	;this line is necessary to display new menu each time this function is called.
			; GuiControl,, % IdTT_C4_LB2, |	;this line is necessary to display new menu each time this function is called.
			; GuiControl,, % IdTT_C4_LB3, |	;this line is necessary to display new menu each time this function is called.
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

	GuiControl,, % IdTT_C3_LB1, ||
	GuiControl,, % IdTT_C3_LB2, ||
	GuiControl,, % IdTT_C3_LB3, ||
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
		RetrievedEncoding := file.Encoding
		FilePos := file.Pos
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
	local	whr := "", URLscript := "https://raw.githubusercontent.com/mslonik/Hotstrings/master/Hotstrings/Hotstrings.ahk", ToBeFiltered := "", ServerVer := "", StartingPos := 0
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
,	v_yNext += 2 * HofText
	GuiControl, Move, % IdShortDefT2, % "x" . v_xNext . "y" . v_yNext		;Current shortcut (hotkey):
	GuiControlGet, v_OutVarTemp, Pos, % IdShortDefT2
	v_xNext := v_OutVarTempX + v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdShortDefT3, % "x" . v_xNext . "y" . v_yNext		;% ShortcutLong
	v_xNext := c_xmarg
,	v_yNext += 2 * HofText
	GuiControl, Move, % IdShortDefT5, % "x" . v_xNext . "y" . v_yNext		;New shortcut (hotkey)
	GuiControlGet, v_OutVarTemp, Pos, % IdShortDefT5
	v_xNext := v_OutVarTempX + v_OutVarTempW + c_xmarg
	GuiControl, Move, % IdShortDefT6, % "x" . v_xNext . "y" . v_yNext		;ⓘ
	v_xNext := c_xmarg
,	v_yNext += 2 * HofText
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
,	v_yNext := v_OutVarTempY + v_OutVarTempH + HofText

	GuiControl, Move, % IdShortDefCB3, % "x" . v_xNext . "y" . v_yNext	;ScrollLock
	GuiControlGet, v_OutVarTemp, Pos, % IdShortDefCB3
	v_xNext += v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdShortDefCB4, % "x" . v_xNext . "y" . v_yNext	;CapsLock
	GuiControlGet, v_OutVarTemp, Pos, % IdShortDefCB4
	v_xNext += v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdShortDefCB5, % "x" . v_xNext . "y" . v_yNext	;NumLock
	v_xNext := c_xmarg
,	v_yNext += 2 * HofText

	GuiControl, Move, % IdShortDefB1, % "x" . v_xNext . "y" . v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdShortDefB1
	v_xNext := v_OutVarTempX + v_OutVarTempW + c_xmarg
	GuiControl, Move, % IdShortDefB2, % "x" . v_xNext . "y" . v_yNext
	v_xNext := c_xmarg
,	v_yNext += HofButton + HofText
	GuiControl, Move, % IdShortDefT8, % "x" . v_xNext . "y" . v_yNext
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
	
	if (InStr(ItemName, TransA["Call Graphical User Interface"]))
		Gui, ShortDef: Add, 	Text,    	x0 y0 HwndIdShortDefT3, 	% F_ParseHotkey(ini_HK_Main, 		"space")
	if (InStr(ItemName, TransA["Copy clipboard content into ""Enter hotstring"""]))
		Gui, ShortDef: Add, 	Text,    	x0 y0 HwndIdShortDefT3, 	% F_ParseHotkey(ini_HK_IntoEdit, 	"space")
	if (InStr(ItemName, TransA["Undo the last hotstring"]))
		Gui, ShortDef: Add, 	Text,    	x0 y0 HwndIdShortDefT3, 	% F_ParseHotkey(ini_HK_UndoLH, 	"space")
	if (InStr(ItemName, TransA["Toggle triggerstring tips"]))
		Gui, ShortDef: Add,		Text,	x0 y0 HwndIdShortDefT3,	% F_ParseHotkey(ini_HK_ToggleTt, 	"space")

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
	Gui, ShortDef: Add, 	Button,  	x0 y0 HwndIdShortDefB2 gF_ShortDefB2_RestoreHotkey,				% TransA["Apply default hotkey"]
	Gui, ShortDef: Add,		Text,	x0 y0 HwndIdShortdefT8,										% TransA["Press Esc when you've finished"]
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
		ini_HK_Main := "#^h"
		GuiControl,, % IdShortDefCB3, 0
		GuiControl,, % IdShortDefCB4, 0
		GuiControl,, % IdShortDefCB5, 0
		Hotkey, If, v_Param != "l" 
		Hotkey, % ini_HK_Main, F_GUIInit, On
		Hotkey, If						;To turn off context sensitivity (that is, to make subsequently-created hotkeys work in all windows)
		GuiControl, , % IdShortDefT3, % F_ParseHotkey(ini_HK_Main, "space")
		IniWrite, % ini_HK_Main, % ini_HADConfig, Configuration, HK_Main
		Menu, Submenu1Shortcuts, Rename, % A_ThisMenuItem, % TransA["Call Graphical User Interface"] . "`t" . F_ParseHotkey(ini_HK_Main, 	"space")
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
		ini_HK_IntoEdit := "~#c"
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
			ini_HK_UndoLH := "~#z"
			Hotkey, % ini_HK_UndoLH, F_Undo, On
		}
		else
		{
			if (OldHotkey != "none")
				Hotkey, % OldHotkey, 	F_Undo, Off
			ini_HK_UndoLH := "~#z"
			Hotkey, % ini_HK_UndoLH, F_Undo, Off
		}
		GuiControl,, % IdShortDefCB3, 0
		GuiControl,, % IdShortDefCB4, 0
		GuiControl,, % IdShortDefCB5, 0
		GuiControl,, % IdShortDefT3, % F_ParseHotkey(ini_HK_UndoLH, "space")
		IniWrite, % ini_HK_UndoLH, % ini_HADConfig, Configuration, HK_UndoLH
		; OutputDebug, % "A_ThisMenuItem:" . A_Space . A_ThisMenuItem . "ini_HK_UndoLH:" . A_Space . ini_HK_UndoLH . "`n"
		Menu, Submenu1Shortcuts, Rename, % A_ThisMenuItem, % TransA["Undo the last hotstring"] . "`t" . F_ParseHotkey(ini_HK_UndoLH, 	"space")
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
			Hotkey, If, v_Param != "l" 
			Hotkey, % OldHotkey, F_GUIInit, Off
			Hotkey, % ini_HK_Main, F_GUIInit, On
			Hotkey, If				;To turn off context sensitivity (that is, to make subsequently-created hotkeys work in all windows)
		}
		Menu, Submenu1Shortcuts, Rename, % A_ThisMenuItem, % TransA["Call Graphical User Interface"] . "`t" . F_ParseHotkey(ini_HK_Main, 	"space")
	}

	if (InStr(A_ThisMenuitem, TransA["Copy clipboard content into ""Enter hotstring"""]))
	{
		GuiControl, , % IdShortDefT3, % F_ParseHotkey(ini_HK_IntoEdit, "space")
		if (ini_HK_IntoEdit != "none")
		{
			Hotkey, IfWinExist, % "ahk_id" HS3GuiHwnd
			Hotkey, % OldHotkey, F_PasteFromClipboard, Off
			Hotkey, % ini_HK_IntoEdit, F_PasteFromClipboard, On
			Hotkey, IfWinExist, % "ahk_id" HS4GuiHwnd
			Hotkey, % OldHotkey, F_PasteFromClipboard, Off
			Hotkey, % ini_HK_IntoEdit, F_PasteFromClipboard, On
			Hotkey, IfWinExist			;To turn off context sensitivity (that is, to make subsequently-created hotkeys work in all windows)
		}
		Menu, Submenu1Shortcuts, Rename, % A_ThisMenuItem, % TransA["Copy clipboard content into ""Enter hotstring"""] . "`t" . F_ParseHotkey(ini_HK_IntoEdit, "space")
	}

	if (InStr(A_ThisMenuitem, TransA["Undo the last hotstring"]))
	{
		GuiControl, , % IdShortDefT3, % F_ParseHotkey(ini_HK_UndoLH, "space")
		if (ini_HotstringUndo)
		{
			if (ini_HK_UndoLH != "none")
			{
				; OutputDebug, % "OldHotkey:" . A_Space . OldHotkey . "`n"
				Hotkey, % OldHotkey, 	F_Undo, Off
				Hotkey, % ini_HK_UndoLH, F_Undo, On
			}
		}
		else
		{
			; OutputDebug, % "OldHotkey:" . A_Space . OldHotkey . "`n"
			Hotkey, % OldHotkey, 	F_Undo, UseErrorLevel Off
			if (ini_HK_UndoLH != "none")
				Hotkey, % ini_HK_UndoLH, F_Undo, UseErrorLevel Off
		}
		Menu, Submenu1Shortcuts, Rename, % A_ThisMenuItem, % TransA["Undo the last hotstring"] . "`t" . F_ParseHotkey(ini_HK_UndoLH, 	"space")
	}

	if (InStr(A_ThisMenuitem, TransA["Toggle triggerstring tips"]))
	{
		GuiControl, , % IdShortDefT3, % F_ParseHotkey(ini_HK_ToggleTt, "space")
		if (OldHotkey != "none")
			Hotkey, % OldHotkey, F_ToggleTt, Off
		if (ini_HK_ToggleTt != "none")
		{
			Hotkey, % ini_HK_ToggleTt, F_ToggleTt, On
			F_UpdateStateOfLockKeys(ini_HK_ToggleTt, ini_TTTtEn)
			Switch ini_HK_ToggleTt
			{
				Case "ScrollLock":	SetScrollLockState, AlwaysOff
				Case "CapsLock":	SetCapsLockState, 	AlwaysOff
				Case "NumLock":	SetNumLockState, 	AlwaysOff
			}
		}
		Menu, Submenu1Shortcuts, Rename, % A_ThisMenuItem, % TransA["Toggle triggerstring tips"] . "`t" . F_ParseHotkey(ini_HK_ToggleTt, "space")
	}
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
	
	OutputDebug, % "ItemName:" . A_Space . ItemName . "`n"
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
	if (f_SortByLength)
		a_Table := F_SortArrayByLength(a_Table)
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_DownloadPublicLibraries()
{
	global	;assume-global mode
	local	ToBeFiltered := "",	Result := "",	ToBeDownloaded := [], DownloadedFile := "", whr := ""
;			,URLconst 	:= "https://gitHub.com/mslonik/Hotstrings/blob/master/Hotstrings/Libraries/", temp := ""	;https://github.com/mslonik/Hotstrings/tree/master/Hotstrings/Libraries
			,URLconst 	:= "https://github.com/mslonik/Hotstrings-Libraries/", temp := ""	
;			,URLraw 		:= "https://raw.githubusercontent.com/mslonik/Hotstrings/master/Hotstrings/Libraries/"
			,URLraw 		:= "https://raw.githubusercontent.com/mslonik/Hotstrings-Libraries/main/"
			,ExistingLibraries := "", NewLibraries := "", part := 0, key := "", value := ""
	
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
	
	Gui, DLG: New, +HwndDLGHwnd +OwnDialogs,	% A_ScriptName	;DLG: Download Libraries Gui
	Gui, DLG: Add, Text,, % TransA["Downloading public library files" . "(0 ÷ 100%):"]
	Gui, DLG: Add, Progress, w200 h20 HwndLibProgress, cBlue, 0
	Gui, DLG: Show, AutoSize
	part := (1 / ToBeDownloaded.Count()) * 100
	for key, value in ToBeDownloaded
	{
		if (value)
		{
			temp := URLraw . value
			GuiControl,, % LibProgress, % "+" . part
			if (FileExist(ini_HADL . "\" . value))
				ExistingLibraries .= value . "`n"
			else
			{
				NewLibraries  .= value . "`n"
				URLDownloadToFile, % temp, % ini_HADL . "\" . value
			}
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
		F_Sort_a_Triggers(a_Combined, ini_TipsSortAlphabetically, ini_TipsSortByLength)
		F_RefreshListOfLibraries()	; this function calls F_RefreshListOfLibraryTips() as both options are interrelated
		; F_RefreshListOfLibraryTips()
		F_UpdateSelHotLibDDL()
		F_Searching("Reload")			;prepare content of Search tables
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
	Gui, ShowIntro: Add,	Picture, x0 y0 HwndIdAboutPicture w96 h96, 							% AppIcon
	Gui, ShowIntro: Add,	CheckBox, x0 y0 HwndIdIntroCheckbox vIntroCheckbox gF_ShowIntroCheckbox,	% TransA["Show Introduction window after application is restarted?"]
	
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
	
	GuiControl,, % IdIntroCheckbox, % ini_ShowIntro	;load initial value
	if (WinExist("ahk_id" HS3GuiHwnd) or WinExist("ahk_id" HS4GuiHwnd))
		Gui, % A_Gui . ": +Disabled"	;thanks to this line user won't be able to interact with main hotstring window if TTStyling window is available
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
	
	if (v_UndoTriggerstring)
	; if (v_UndoTriggerstring and (ThisHotkey != PriorHotkey))
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
			v_UndoHotstring 	:= F_ReplaceAHKconstants(v_UndoHotstring)
,			v_UndoHotstring 	:= F_PrepareUndo(v_UndoHotstring)
,			v_UndoHotstring 	:= RegExReplace(v_UndoHotstring, "{U+.*}", " ")
			HowManyBackSpaces 	+= StrLenUnicode(v_UndoHotstring)
			Send, % "{BackSpace " . HowManyBackSpaces . "}"
			Loop, Parse, v_UndoTriggerstring
			Switch A_LoopField
			{
				Case "^", "+", "!", "#", "{", "}":	SendRaw, 	% A_LoopField
				Default:						Send, 	% A_LoopField
			}
			if (!InStr(v_Options, "*"))
				Send, % v_EndChar
		}
		v_UndoTriggerstring := ""
		F_UndoSignalling()
	}
	; else
	; {
	; 	F_DestroyTriggerstringTips(ini_TTCn)
	; 	if InStr(ThisHotkey, "^z")
	; 		SendInput, ^z
	; 	else if InStr(ThisHotkey, "!BackSpace")
	; 		SendInput, !{BackSpace}
	; }
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
				Gui, Tt_HWT: Show, % "x" v_MouseX + 20 . A_Space . "y" . v_MouseY - 20 . A_Space . "NoActivate" 	;Tooltip _ Hotstring Was Triggered
				if (ini_OHTD > 0)
					SetTimer, TurnOff_OHE, % "-" . ini_OHTD, 40 ;Priority = 40 to avoid conflicts with other threads 
			}
		}
		if (ini_OHTP = 2)
		{
			MouseGetPos, v_MouseX, v_MouseY
			Gui, Tt_HWT: Show, % "x" v_MouseX + 20 . A_Space . "y" . v_MouseY - 20 . A_Space . "NoActivate" 	;Tooltip _ Hotstring Was Triggered
			if (ini_OHTD > 0)
				SetTimer, TurnOff_OHE, % "-" . ini_OHTD, 40 ;Priority = 40 to avoid conflicts with other threads 
		}
	}
	
	if (ini_OHSEn)	;Basic Hotstring Sound Enable
		SoundBeep, % ini_OHSF, % ini_OHSD
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_PrepareTriggerstringTipsTables2(string)
{
	global	;assume-global mode of operation
	local	HitCnt := 0
	;OutputDebug, % "Length of v_InputString:" . A_Space . StrLen(v_InputString) . A_Tab . "v_InputString:" . A_Space . v_InputString
	if (StrLen(string) > ini_TASAC - 1)	;TASAC = TipsAreShownAfterNoOfCharacters
	{
		a_Tips 		:= []	;collect within global array a_Tips subset from full set a_Combined
		, a_TipsOpt	:= []	;collect withing global array a_TipsOpt subset from full set a_TriggerOptions; next it will be used to show triggering character in F_ShowTriggerstringTips2()
		, a_TipsEnDis	:= []
		, a_TipsHS	:= []	;HS = Hotstrings
		Loop, % a_Combined.MaxIndex()
		{
			if (InStr(a_Combined[A_Index], string) = 1)	;This is the reason why triggerstring tips aren't shown for triggerstring definitions containing option "?"
			{
				Switch ini_TTCn
				{
					Case 1:	;only column 1: Triggerstring Tips
					     Loop, Parse, % a_Combined[A_Index], |
					     	if (A_Index = 1)
					     		a_Tips.Push(A_LoopField)
					Case 2:	;2 columns: Triggerstring Tips + Triggerstring Trigger
					     Loop, Parse, % a_Combined[A_Index], |	
					     {
					     	if (A_Index = 1)
					     		a_Tips.Push(A_LoopField)
					     	if (A_Index = 2) 
					     		a_TipsOpt.Push(A_LoopField)
					     	if (A_Index = 3) 
					     		a_TipsEnDis.Push(A_LoopField)
					     }
					Case 3, 4:	;3 columns: Triggerstring Tips + Triggerstring Trigger + Triggerstring Hotstring
					     Loop, Parse, % a_Combined[A_Index], |
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
			MsgBox, 16, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["Error"], % A_ThisFunc . A_Space . TransA["Something went wrong with link file (.lnk) creation"] . ":" 
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
;1. Read all inputs. 
;2. Create Hotstring definition according to inputs. 
;3. Read the library file into List View. 
;4. Sort List View. 
;5. Delete library file. 
;6. Save List View into the library file.
;7. Increment library counter.
{
	global ;assume-global mode of operation
	local 	TextInsert := "", NewOptions := "", f_ChangeExistingDef := false
			,OnOff := "", EnDis := ""
			,SendFunHotstringCreate := "", SendFunFileFormat := ""
			,OldOptions := "", OldEnDis := "", TurnOffOldOptions := ""
			,v_TheWholeFile := "", v_TotalLines := 0
			,ExternalIndex := 0
			,name := "", key := 0, value := "", Counter := 0, key2 := 0, value2 := ""
			,f_T_GeneralMatch := false, f_T_CaseMatch := false, f_OldOptionsC := false, f_OldOptionsC1 := false, f_OptionsC := false, f_OptionsC1 := false
			,SelectedLibraryName := ""
			,Overwrite := "", WinHWND := "", WhichGuiEnable := ""

	;1. Read all inputs. 
	if (F_ReadUserInputs(TextInsert, NewOptions, OnOff, EnDis, SendFunHotstringCreate, SendFunFileFormat))	;return true (1) in case of any problem. 
		return
	SelectedLibraryName := SubStr(v_SelectHotstringLibrary, 1, -4)	
	;Disable all GuiControls for time of adding / editing of d(t, o, h)	
	WinGet, WinHWND, ID, % "ahk_id" HS3GuiHwnd
	if (WinHWND)
	{
		WhichGuiEnable := "HS3"
		F_GuiMain_EnDis("Disable")	;EnDis = "Disable" or "Enable"
	}
	WinGet, WinHWND, ID, % "ahk_id" HS4GuiHwnd
	if (WinHWND)
	{
		WhichGuiEnable := "HS4"
		F_GuiHS4_EnDis("Disable")
	}
	
	;2. Create or modify (triggerstring, hotstring) definition according to inputs. 
	Gui, HS3: Default			;All of the ListView function operate upon the current default GUI window.
	GuiControl, -Redraw, % IdListView1 ; -Readraw: This option serves as a hint to the control that allows it to allocate memory only once rather than each time a row is added, which greatly improves row-adding performance (it may also improve sorting performance). 
	for key, value in a_Triggerstring
	{
		f_T_GeneralMatch := false, f_T_CaseMatch := false, f_OldOptionsC := false, f_OldOptionsC1 := false, f_OptionsC := false, f_OptionsC1 := false
		if (a_Triggerstring[key] = v_Triggerstring)	;case insensitive string comparison!
		{
			f_T_GeneralMatch := true
			if (a_Triggerstring[key] == v_Triggerstring)
				f_T_CaseMatch := true
			OldOptions 	:= a_TriggerOptions[key]
,			OldEnDis		:= a_EnableDisable[key]
			if (InStr(OldOptions, "C"))
				f_OldOptionsC 	:= true
			if (InStr(NewOptions, "C"))
				f_OptionsC 	:= true

			if (a_Library[key] = SubStr(v_SelectHotstringLibrary, 1, -4))	;if matched within current library
			{
				if (f_T_CaseMatch   and f_OldOptionsC and f_OptionsC)         	or (f_T_CaseMatch and !f_OldOptionsC and !f_OptionsC) 
                    or (f_T_CaseMatch   and f_OldOptionsC and !f_OptionsC)        	or (f_T_CaseMatch and !f_OldOptionsC and f_OptionsC)
				or (f_T_GeneralMatch and !f_OldOptionsC and !f_OldOptionsC)		or (f_T_GeneralMatch and !f_OldOptionsC and f_OldOptionsC) 
				or (f_T_GeneralMatch and f_OldOptionsC and !f_OldOptionsC)
				{
					f_ChangeExistingDef := true
					break
				}
				else	;add
					break
			}
			else
			{
				MsgBox, 68, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"]
					, % "The triggerstring" . A_Space . """" .  v_Triggerstring . """" . A_Space .  TransA["already exists in another library"] . ":" . A_Space . a_Library[key] . "." . "`n`n" 
					. TransA["Do you want to proceed?"] . "`n`n" . TransA["If you answer ""No"" edition of the current definition will be interrupted."]
					. "`n" . TransA["If you answer ""Yes"" definition existing in another library will not be changed."]
				IfMsgBox, No
				{
					Switch WhichGuiEnable	;Enable all GuiControls for time of adding / editing of d(t, o, h)	
					{
						Case "HS3":	
							GuiControl, +Redraw, % IdListView1 ; -Readraw: This option serves as a hint to the control that allows it to allocate memory only once rather than each time a row is added, which greatly improves row-adding performance (it may also improve sorting performance). 
							F_GuiMain_EnDis("Enable")	;EnDis = "Disable" or "Enable"
						Case "HS4": 	F_GuiHS4_EnDis("Enable")
					}
					return
				}
			}
		}
	}
	; 3. Modify existing definition
	if (f_ChangeExistingDef)	;modify existing definition
	{
		Overwrite := F_ChangeExistingDef(OldOptions, NewOptions, a_Triggerstring[key], a_Library[key], SendFunHotstringCreate, TextInsert, OnOff)	;FoundTriggerstring = a_Triggerstring[key]; Library = a_Library[key]
		if (Overwrite = "Yes")
		{
			F_ChangeDefInArrays(key, NewOptions, SendFunFileFormat, TextInsert, EnDis, v_Comment)
			F_ModifyLV(NewOptions, SendFunFileFormat, EnDis, TextInsert)
			;7. Delete library file. 
			FileDelete, % ini_HADL . "\" . v_SelectHotstringLibrary
			;8. Save List View into the library file.
			F_SaveLVintoLibFile()
			Switch WhichGuiEnable	;Enable all GuiControls for time of adding / editing of d(t, o, h)	
			{
				Case "HS3":	F_GuiMain_EnDis("Enable")	;EnDis = "Disable" or "Enable"
				Case "HS4": 	F_GuiHS4_EnDis("Enable")
			}
			MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . A_Space . TransA["information"], % TransA["New settings are now applied."]
			return
		}
		if (Overwrite = "No")
		{
			Switch WhichGuiEnable	;Enable all GuiControls for time of adding / editing of d(t, o, h)	
			{
				Case "HS3":	
                         GuiControl, +Redraw, % IdListView1 ; -Readraw: This option serves as a hint to the control that allows it to allocate memory only once rather than each time a row is added, which greatly improves row-adding performance (it may also improve sorting performance). 
                         F_GuiMain_EnDis("Enable")	;EnDis = "Disable" or "Enable"
				Case "HS4": 	F_GuiHS4_EnDis("Enable")
			}
			return
		}	
	}

	; 4. Create new definition
	;OutputDebug, % "NewOptions:" . A_Space . NewOptions . A_Tab . "OldOptions:" . A_Space . OldOptions . A_Tab . "v_Triggerstring:" . A_Space . v_Triggerstring
	if (InStr(NewOptions, "O"))
	{
		Try
			Hotstring(":" . NewOptions . ":" . v_Triggerstring, func(SendFunHotstringCreate).bind(TextInsert, true), OnOff)
		Catch
			MsgBox, 16, % SubStr(A_ScriptName, 1, -4) . A_Space . TransA["Error"], % A_ThisFunc . A_Space . TransA["Something went wrong during hotstring setup"] . ":" . "`n`n"
			. "Hotstring(:" . NewOptions . ":" . v_Triggerstring . "," . "func(" . SendFunHotstringCreate . ").bind(" . TextInsert . "," . A_Space . true . ")," . A_Space . OnOff . ")"
	}
	else
	{
		Try
			Hotstring(":" . NewOptions . ":" . v_Triggerstring, func(SendFunHotstringCreate).bind(TextInsert, false), OnOff)
		Catch
			MsgBox, 16, % SubStr(A_ScriptName, 1, -4) . A_Space . TransA["Error"], % A_ThisFunc . A_Space . TransA["Something went wrong during hotstring setup"] . ":" . "`n`n"
			. "Hotstring(:" . NewOptions . ":" . v_Triggerstring . "," . "func(" . SendFunHotstringCreate . ").bind(" . TextInsert . "," . A_Space . false . ")," . A_Space . OnOff . ")"
	}
	; 5. Update global arrays
	F_UpdateGlobalArrays(NewOptions, SendFunFileFormat, EnDis, TextInsert)
	
	;6. Update and sort List View. ;future: gui parameter for sorting 
	LV_Add("",  v_Triggerstring, NewOptions, SendFunFileFormat, EnDis, TextInsert, v_Comment)
	LV_ModifyCol(1, "Sort")

	;7. Delete library file. 
	FileDelete, % ini_HADL . "\" . v_SelectHotstringLibrary
	
	;8. Save List View into the library file.
	F_SaveLVintoLibFile()

	;9. Increment library counter.
	++v_LibHotstringCnt
	++v_TotalHotstringCnt
	GuiControl, , % IdText13,  % v_LibHotstringCnt
	GuiControl, , % IdText13b, % v_LibHotstringCnt
	GuiControl, , % IdText12,  % v_TotalHotstringCnt
	GuiControl, , % IdText12b, % v_TotalHotstringCnt
	MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["Hotstring added to the file"] . A_Space . v_SelectHotstringLibrary . "!" 
	Switch WhichGuiEnable	;Enable all GuiControls for time of adding / editing of d(t, o, h)	
	{
		Case "HS3":	F_GuiMain_EnDis("Enable")	;EnDis = "Disable" or "Enable"
		Case "HS4": 	F_GuiHS4_EnDis("Enable")
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_SaveLVintoLibFile()
{
	global	;assume-global mode of operation
	local	txt := "", txt1 := "", txt2 := "", txt3 := "", txt4 := "", txt5 := "", txt6 := ""

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
	FileAppend, % txt, % ini_HADL . "\" . v_SelectHotstringLibrary, UTF-8
	GuiControl, +Redraw, % IdListView1 ;Afterward, use GuiControl, +Redraw to re-enable redrawing (which also repaints the control).
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_UpdateGlobalArrays(NewOptions, SendFunFileFormat, EnDis, TextInsert)
{
	global	;assume-global mode of operation
	a_Library			.Push(SubStr(v_SelectHotstringLibrary, 1, -4))
	a_Triggerstring	.Push(v_Triggerstring)
	a_TriggerOptions	.Push(NewOptions)
	a_OutputFunction	.Push(SendFunFileFormat)
	a_EnableDisable	.Push(EnDis)	;here was a bug: OnOff instead of EnDis
	a_Hotstring		.Push(TextInsert)
	a_Comment			.Push(v_Comment)
	a_Combined		.Push(v_Triggerstring . "|" . NewOptions . "|" . EnDis . "|" . TextInsert)
	; a_Gain			.Push(F_CalculateGain(v_Triggerstring, TextInsert, NewOptions))
	F_Sort_a_Triggers(a_Combined, ini_TipsSortAlphabetically, ini_TipsSortByLength)
}	
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_ChangeDefInArrays(key, NewOptions, SendFunFileFormat, TextInsert, EnDis, v_Comment)
{
	global	;assume-global mode of operation
	local	index := 0

	a_Triggerstring[key] 	:= v_Triggerstring
, 	a_TriggerOptions[key] 	:= NewOptions
, 	a_OutputFunction[key] 	:= SendFunFileFormat
, 	a_Hotstring[key] 		:= TextInsert
, 	a_EnableDisable[key] 	:= EnDis
, 	a_Comment[key] 		:= v_Comment
	for index in a_Combined	;recreate array a_Combined
		a_Combined[index] := a_Triggerstring[index] . "|" . a_TriggerOptions[index] . "|" . a_EnableDisable[index] . "|" . a_Hotstring[index]
	F_Sort_a_Triggers(a_Combined, ini_TipsSortAlphabetically, ini_TipsSortByLength)	
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_ModifyLV(NewOptions, SendFunFileFormat, EnDis, TextInsert)
{
	global	;assume-global mode of operation
	local	Temp1 := ""
	
	GuiControl, +Redraw, % IdListView1 ; -Readraw: This option serves as a hint to the control that allows it to allocate memory only once rather than each time a row is added, which greatly improves row-adding performance (it may also improve sorting performance). 
	Loop, % LV_GetCount()
	{
		LV_GetText(Temp1, A_Index)
		if (Temp1 = v_Triggerstring)	;non-case sensitive comparison
		{
			LV_Modify(A_Index, "", v_Triggerstring, NewOptions, SendFunFileFormat, EnDis, TextInsert, v_Comment)		
			Break
		}
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_ChangeExistingDef(OldOptions, NewOptions, FoundTriggerstring, Library, SendFunHotstringCreate, TextInsert, OnOff)	;FoundTriggerstring = a_Triggerstring[key]; Library = a_Library[key]
{	
	global	;assume-global mode of operation
	MsgBox, 68, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"]
		, % TransA["The triggerstring"] . A_Space . """" .  FoundTriggerstring . """" . A_Space .  TransA["exists in the currently selected library"] . ":" . A_Space . Library 
		. ".csv" . "." . "`n`n" . TransA["Do you want to proceed?"]	. "`n`n" . TransA["If you answer ""Yes"" it will overwritten with chosen settings."]
	IfMsgBox, No
		return, "No"

	IfMsgBox, Yes
	{
		if (InStr(OldOptions, "*") and !InStr(NewOptions,"*"))
			NewOptions := StrReplace(OldOptions, "*", "*0")
		if (InStr(OldOptions, "B0") and !InStr(NewOptions, "B0"))
			NewOptions := StrReplace(OldOptions, "B0", "B")
		if (InStr(OldOptions, "O") and !InStr(NewOptions, "O"))
			NewOptions := StrReplace(OldOptions, "O", "O0")
		if (InStr(OldOptions, "Z") and !InStr(NewOptions, "Z"))
			NewOptions := StrReplace(OldOptions, "Z", "Z0")
		if (InStr(NewOptions, "O"))	;Add new hotstring which replaces the old one
		{
			Try
				Hotstring(":" . NewOptions . ":" . F_ConvertEscapeSequences(v_Triggerstring), func(SendFunHotstringCreate).bind(TextInsert, true), OnOff)	;because v_Triggerstring is read from Edit field, it contains spcial sequences as 2x characters, e.g. `t = ` + t and not A_Tab. as a consequence F_ConvertEscapeSequences function have to be run
			Catch
			{
				MsgBox, 16, % SubStr(A_ScriptName, 1, -4) . A_Space . TransA["Error"], % A_ThisFunc . "`n" . TransA["Something went wrong during hotstring setup"] . ":" . "`n`n"
					. "Hotstring(:" . NewOptions . ":" . v_Triggerstring . "," . "func(" . SendFunHotstringCreate . ").bind(" . TextInsert . "," . A_Space . true . ")," 
					. A_Space . OnOff . ")"
				return "No"
			}
		}
		else
		{
			Try
				Hotstring(":" . NewOptions . ":" . F_ConvertEscapeSequences(v_Triggerstring), func(SendFunHotstringCreate).bind(TextInsert, false), OnOff)	;because v_Triggerstring is read from Edit field, it contains spcial sequences as 2x characters, e.g. `t = ` + t and not A_Tab. as a consequence F_ConvertEscapeSequences function have to be run
			Catch
			{
				MsgBox, 16, % SubStr(A_ScriptName, 1, -4) . A_Space . TransA["Error"], % A_ThisFunc . A_Space . TransA["Something went wrong during hotstring setup"] . ":" . "`n`n"
					. "Hotstring(:" . NewOptions . ":" . v_Triggerstring . "," . "func(" . SendFunHotstringCreate . ").bind(" . TextInsert . "," . A_Space . false . ")," 
					. A_Space . OnOff . ")"
				return "No"
			}
		}
		return, "Yes"	
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_ReadUserInputs(ByRef TextInsert, ByRef NewOptions, ByRef OnOff, ByRef EnDis, ByRef SendFunHotstringCreate, ByRef SendFunFileFormat)
{
	global ;assume-global mode of operation

	Gui, % A_DefaultGui . ":" A_Space . "Submit", NoHide
	Gui, % A_DefaultGui . ":" A_Space . "+OwnDialogs"

	if (Trim(v_Triggerstring) = "")
	{
		MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"],  % TransA["Triggerstring cannot be empty  if you wish to add new hotstring"] . "."
		return, 1
	}
	if InStr(v_SelectFunction, "Menu")
	{
		if ((Trim(v_EnterHotstring) = "") and (Trim(v_EnterHotstring1) = "") and (Trim(v_EnterHotstring2) = "") and (Trim(v_EnterHotstring3) = "") and (Trim(v_EnterHotstring4) = "") and (Trim(v_EnterHotstring5) = "") and (Trim(v_EnterHotstring6) = ""))
		{
			MsgBox, 324, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["Replacement text is blank. Do you want to proceed?"]
			IfMsgBox, No
				return, 1
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
				return, 1
		}
		else
		{
			TextInsert := v_EnterHotstring
		}
	}
	if (!v_SelectHotstringLibrary) or (v_SelectHotstringLibrary = TransA["↓ Click here to select hotstring library ↓"])
	{
		MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["Choose existing hotstring library file before saving new (triggerstring, hotstring) definition!"]
		return, 1
	}
	if (v_OptionImmediateExecute)
		NewOptions .= "*"
	Switch v_RadioCaseGroup
	{
		Case 2: NewOptions .= "C"
		Case 3: NewOptions .= "C1"
	}
	if (v_OptionNoBackspace)
		NewOptions .= "B0"
	if (v_OptionInsideWord)
		NewOptions .= "?"
	if (v_OptionNoEndChar)
		NewOptions .= "O"
	if (v_OptionReset)
		NewOptions .= "Z"
	if (v_OptionDisable)
	{
		OnOff := "Off", EnDis := "Dis"	
	}
	else
	{
		OnOff := "On", EnDis := "En"
	}
	Switch v_SelectFunction
	{
		Case "Clipboard (CL)":			SendFunHotstringCreate 	:= "F_HOF_CLI", 	SendFunFileFormat 	:= "CL"
		Case "SendInput (SI)": 			SendFunHotstringCreate 	:= "F_HOF_SI", 	SendFunFileFormat 	:= "SI"
		Case "Menu & Clipboard (MCL)": 	SendFunHotstringCreate 	:= "F_HOF_MCLI", 	SendFunFileFormat 	:= "MCL"
		Case "Menu & SendInput (MSI)": 	SendFunHotstringCreate 	:= "F_HOF_MSI", 	SendFunFileFormat 	:= "MSI"
		Case "SendRaw (SR)":			SendFunHotstringCreate 	:= "F_HOF_SR", 	SendFunFileFormat 	:= "SR"
		Case "SendPlay (SP)":			SendFunHotstringCreate 	:= "F_HOF_SP", 	SendFunFileFormat 	:= "SP"
		Case "SendEvent (SE)":			SendFunHotstringCreate 	:= "F_HOF_SE", 	SendFunFileFormat 	:= "SE"
	}

	if (SendFunHotstringCreate = "F_HOF_SI") or (SendFunHotstringCreate = "F_HOF_MSI") or (SendFunHotstringCreate = "F_HOF_SE")
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
		if (SendFunHotstringCreate = "F_HOF_SP")
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

	return, 0
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
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_Move()
{
	global	;assume-global mode
	local NoOnTheList := 0, v_Temp1 := "", SourceLibrary := v_SelectHotstringLibrary, DestinationLibrary := ""
		,txt := "", txt1 := "", txt2 := "", txt3 := "", txt4 := "", txt5 := "", txt6 := ""
		,v_Triggerstring := "", v_TriggOpt := "", v_OutFun := "", v_EnDis := "", v_Hotstring := "", v_Comment := ""
		,WhichRow := 0

	Gui, HS3Search:	+Disabled
	Gui, MoveLibs: 	Default
	Gui, MoveLibs: 	Submit, NoHide
	NoOnTheList := LV_GetNext()
	LV_GetText(DestinationLibrary, NoOnTheList) ;row number DestinationLibrary into OutputVar = v_SelectHotstringLibrary
	if (!DestinationLibrary) 
	{
		MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"],  % TransA["Select a row in the list-view, please!"]
		return
	}
	Gui, HS3Search:	-Disabled
	Gui, MoveLibs: 	Destroy

	Gui, HS3Search:	Default
	WhichRow := LV_GetNext(, "Focused")
	LV_GetText(v_Triggerstring, 	WhichRow, 2)
	LV_GetText(v_TriggOpt, 		WhichRow, 3)
	LV_GetText(v_OutFun, 		WhichRow, 4)
	LV_GetText(v_EnDis, 		WhichRow, 5)
	LV_GetText(v_Hotstring, 		WhichRow, 6)
	LV_GetText(v_Comment, 		WhichRow, 7)

	Gui, HS3Search: 	Hide	
	GuiControl, ChooseString, % IdDDL2, % DestinationLibrary
	Gui, HS3: 		Submit, NoHide	;this line is necessary to v_SelectHotstringLibrary <- DestinationLibrary
	F_SelectLibrary()	;DestinationLibrary 
	Loop, % LV_GetCount()
	{
		if (v_Temp1 == v_Triggerstring)
		{
			MsgBox, 308, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["warning"], % TransA["The selected triggerstring already exists in destination library file:"]
				. "`n`n" 	. v_Triggerstring
				. "`n" 	. DestinationLibrary . "`n`n"
				. TransA["Do you want to replace it with source definition?"]
			IfMsgBox, Yes
			{
				LV_Delete(A_Index)
				LV_Add("",  v_Triggerstring, v_TriggOpt, v_OutFun, v_EnDis, v_Hotstring, v_Comment)
			}
			IfMsgBox, No
			{
				Gui, HS3Search:	+Disabled
				Gui, HS3:			-Disabled
				Gui, HS3:			Default
				return
			}
		}
	}
	
	LV_Add("", v_Triggerstring, v_TriggOpt, v_OutFun, v_EnDis, v_Hotstring, v_Comment) ;add to ListView
	LV_ModifyCol(1, "Sort")
	FileDelete, % ini_HADL . "\" . DestinationLibrary	;delete the old destination file.
	
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
	FileAppend, % txt, % ini_HADL . "\" . DestinationLibrary, UTF-8
	
	GuiControl, ChooseString, % IdDDL2, % SourceLibrary
	Gui, HS3: 		Submit, NoHide	;this line is necessary to v_SelectHotstringLibrary <- SourceLibrary
	F_SelectLibrary() ;Remove the definition from source table / file.
	Loop, % LV_GetCount()
	{
		LV_GetText(v_Temp1, A_Index, 1)
		if (v_Temp1 == v_Triggerstring)
		{
			LV_Delete(A_Index)
			break
		}
	}
	FileDelete, % ini_HADL . "\" . SourceLibrary	;delete the old source filename.
	txt := ""
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
	FileAppend, % txt, % ini_HADL . "\" . SourceLibrary, UTF-8
	F_Clear()
	F_LoadLibrariesToTables()	; Hotstrings are already loaded by function F_LoadHotstringsFromLibraries(), but auxiliary tables have to be loaded again. Those (auxiliary) tables are used among others to fill in LV_ variables.
	F_Searching("ReloadAndView")
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
	
	Gui, MoveLibs: New, 	-Caption +Border -Resize +HwndMoveLibsHwnd +Owner
	Gui, MoveLibs: Margin,	% c_xmarg, % c_ymarg
	Gui,	MoveLibs: Color,	% c_WindowColor, % c_ControlColor
	Gui,	MoveLibs: Font, 	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, 	% c_FontType
	Gui, MoveLibs: Default
	
	Gui, MoveLibs: Add, Text,     x0 y0 HwndIdMoveLibs_T1, 						% TransA["Select the target library:"]
	Gui, MoveLibs: Add, ListView, x0 y0 HwndIdMoveLibs_LV LV0x1 +AltSubmit -Hdr -Multi, 	| 	;-Hdr (minus Hdr) to omit the header (the special top row that contains column titles). "|" is required!
	Gui, MoveLibs: Add, Button, 	x0 y0 HwndIdMoveLibs_B1 Default gF_Move,			% TransA["Move (F8)"]
	Gui, MoveLibs: Add, Button, 	x0 y0 HwndIdMoveLibs_B2 gMoveLibsGuiCancel,			% TransA["Cancel"]
	
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
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
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
		if (WinExist("ahk_id" MoveLibsHwnd))
			Gui, HS3: -Disabled
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
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_HSLV2() ;load content of chosen row from Search Gui into HS3 Gui
{
	global	;assume-global mode
	local v_SelectedRow2 := 0, v_Library := "", v_Triggerstring := "", v_SearchedTriggerString := ""
	static v_PreviousSelectedRow2 := 0
;The following lines protect from refreshing of ListView if user chooses the same row couple of times.
	v_PreviousSelectedRow2 := v_SelectedRow2
	v_SelectedRow2 := LV_GetNext()
	If (!v_SelectedRow2) ;if empty
		return
	if (v_PreviousSelectedRow2 == v_SelectedRow2) ;if the same
		return
	
	LV_GetText(v_Library, 		v_SelectedRow2, 1)
	LV_GetText(v_Triggerstring, 	v_SelectedRow2, 2)
	
	v_SelectHotstringLibrary := % v_Library . ".csv"
	
	GuiControl, Choose, % IdDDL2, % v_SelectHotstringLibrary
	F_SelectLibrary()
	
	v_SearchedTriggerString := v_Triggerstring
	Loop
	{
		LV_GetText(v_Triggerstring, A_Index, 1)
		if (v_Triggerstring == v_SearchedTriggerString)
		{
			LV_Modify(A_Index, "Vis +Select +Focus")
			break
		}
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_SearchPhrase()
{
	global	;assume-global mode
	local	Each := 0, FileName := ""
	
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
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_Searching(ReloadListView*)
{
	global	;assume-global mode
	local	Window1X := 0, 	Window1Y := 0, 	Window1W := 0, 	Window1H := 0
			,Window2X := 0, 	Window2Y := 0, 	Window2W := 0, 	Window2H := 0
			,NewWinPosX := 0, 	NewWinPosY := 0
			,WhichGui := "", PreviousGui := ""
	Switch ReloadListView[1]
	{
		Case "ReloadAndView":
			WinGetPos, Window1X, Window1Y, Window1W, Window1H, % "ahk_id" . HS3GuiHwnd
			Gui, HS3Search: Default
			GuiControl, % "Count" . a_Library.MaxIndex() . A_Space . "-Redraw", % IdListView1 ;This option serves as a hint to the control that allows it to allocate memory only once rather than each time a row is added, which greatly improves row-adding performance (it may also improve sorting performance). 
			LV_Delete()
			Loop, % a_Library.MaxIndex() ; Those arrays have been loaded by F_LoadLibrariesToTables()
				LV_Add("", a_Library[A_Index], a_Triggerstring[A_Index], a_TriggerOptions[A_Index], a_OutputFunction[A_Index], a_EnableDisable[A_Index], a_Hotstring[A_Index], a_Comment[A_Index])
			GuiControl, , % IdSearchE1		;start with always blanked search edit field
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
		Case "": ;new thread starts here
			WinGetPos, Window1X, Window1Y, Window1W, Window1H, A	;Retrieves the position of the active window.
			F_WhichGui()
			Gui, % A_DefaultGui . ": +Disabled"	;thanks to this line user won't be able to interact with main hotstring window if TTStyling window is available
			PreviousGui := A_DefaultGui
			Gui, HS3Search: -Disabled
			Gui, HS3Search: Default
			LV_Delete()
			Loop, % a_Library.MaxIndex() ; Those arrays have been loaded by F_LoadLibrariesToTables()
				LV_Add("", a_Library[A_Index], a_Triggerstring[A_Index], a_TriggerOptions[A_Index], a_OutputFunction[A_Index], a_EnableDisable[A_Index], a_Hotstring[A_Index], a_Comment[A_Index])
			F_SearchPhrase()
			Switch PreviousGui
			{
				Case "HS3": Gui, HS3Search: Show, % "x" . Window1X . A_Space . "y" . Window1Y . A_Space . "w" . HS3_GuiWidth . A_Space . "h" . HS3_GuiHeight
				Case "HS4": Gui, HS3Search: Show, % "x" . Window1X . A_Space . "y" . Window1Y . A_Space . "w" . HS4_GuiWidth . A_Space . "h" . HS4_GuiHeight
			}
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
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
	Gui, HS3Search: Add, Text, 		x0 y0 HwndIdSearchT4, 								% TransA["F3 or Esc: Close Search hotstrings | F8: Move hotstring between libraries"]
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
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
	GuiControlGet, v_OutVarTemp, Pos, % IdSearchT1
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
	v_wNext := HS3_GuiWidth - 2 * c_ymarg
	v_hNext := HS3_GuiHeight - (c_ymarg + HofText + v_OutVarTemp + c_ymarg + HofText * 2)
	GuiControl, MoveDraw, % IdSearchLV1, % "x" v_xNext "y" v_yNext "w" v_wNext "h" v_hNext
	
	Gui, HS3Search: Default	;in order to enable LV_ModifyCol
	GuiControlGet, v_OutVarTemp, Pos, % IdSearchLV1
	LV_ModifyCol(1, Round(0.2 * v_OutVarTempW))
	LV_ModifyCol(2, Round(0.1 * v_OutVarTempW))
	LV_ModifyCol(3, Round(0.1 * v_OutVarTempW))	
	LV_ModifyCol(4, Round(0.1 * v_OutVarTempW))
	LV_ModifyCol(5, Round(0.1 * v_OutVarTempW))
	LV_ModifyCol(6, Round(0.27 * v_OutVarTempW))
	LV_ModifyCol(7, Round(0.1 * v_OutVarTempW) - 3)
	GuiControl, +Redraw, % IdSearchLV1 ;Afterward, use GuiControl, +Redraw to re-enable redrawing (which also repaints the control).
	v_xNext := c_xmarg
	v_yNext := v_OutVarTempY + v_OutVarTempH + c_ymarg
	GuiControl, Move, % IdSearchT4, % "x" v_xNext "y" v_yNext ;information about shortcuts
	
	GuiControlGet, v_OutVarTemp, Pos, % IdSearchB1
	v_ButtonW := v_OutVarTempW + 2 * c_ymarg
	v_xNext := HS3MinWidth + c_xmarg - v_ButtonW
	v_yNext -= c_ymarg
	GuiControl, Move, % IdSearchB1, % "x" v_xNext "y" v_yNext "w" v_ButtonW
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
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
		F_CheckCreateConfigIni(ini_HADConfig)
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
	v_yNext := c_ymarg
	v_wNext := v_OutVarTempW
	GuiControl, Move, % IdHD_S1, % "x" v_xNext . A_Space . "y" v_yNext . A_Space "w" v_wNext
	GuiControl, Move, % IdHD_T1, % "x" v_xNext
	
	WinGetPos, Window1X, Window1Y, Window1W, Window1H, A
	Gui, HSDel: Show, Hide
	DetectHiddenWindows, On
	WinGetPos, Window2X, Window2Y, Window2W, Window2H, % "ahk_id" . HotstringDelay
	DetectHiddenWindows, Off
	
	NewWinPosX := Round(Window1X + (Window1W / 2) - (Window2W / 2))
	NewWinPosY := Round(Window1Y + (Window1H / 2) - (Window2H / 2))
	
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
		return
	}
	WinGet, WinHWND, ID, % "ahk_id" HS4GuiHwnd
	if (WinHWND)
	{
		Gui, HS4: Default
		return
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
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
	
	Gui, ALib: Add, Button, HwndIdButt1 Default gF_ALibOK, 	% TransA["OK"]
	Gui, ALib: Add, Button, HwndIdButt2 gALibGuiClose, 	% TransA["Cancel"]
	GuiControlGet, v_OutVarTemp1, ALib: Pos, % IdButt1
	GuiControlGet, v_OutVarTemp2, ALib: Pos, % IdButt2
	
	v_WidthButt1 := v_OutVarTemp1W + 2 * c_xmarg
	v_WidthButt2 := v_OutVarTemp2W + 2 * c_xmarg
	xButt2	   := c_xmarg + v_WidthButt1 + vTempWidth - (2 * c_xmarg + v_WidthButt1 + v_WidthButt2)
	
	GuiControl, ALib: Move, % IdButt1, % "x" c_xmarg . A_Space . "w" v_WidthButt1
	GuiControl, ALib: Move, % IdButt2, % "x" xButt2  . A_Space . "y" v_OutVarTemp1Y . A_Space . "w" v_WidthButt2
	
	WinGetPos, Window1X, Window1Y, Window1W, Window1H, A
	Gui, ALib: Show, Hide
	DetectHiddenWindows, On
	WinGetPos, Window2X, Window2Y, Window2W, Window2H, % "ahk_id" . AddLibrary
	DetectHiddenWindows, Off
	
	NewWinPosX := Round(Window1X + (Window1W / 2) - (Window2W / 2))
	NewWinPosY := Round(Window1Y + (Window1H / 2) - (Window2H / 2))
	Gui, % A_Gui . ": +Disabled"	;thanks to this line user won't be able to interact with main hotstring window if TTStyling window is available
	Gui, ALib: Show, % "x" . NewWinPosX . A_Space . "y" . NewWinPosY . A_Space . "AutoSize"
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_RefreshListOfLibraryTips()
{
	global	;assume-global
	local	key := 0, value := 0
	
	if (ini_ShowTipsLib.Count())
	{
		Menu, ToggleLibTrigTipsSubmenu, UseErrorLevel
		Menu, ToggleLibTrigTipsSubmenu, Delete	;try to delete: if it's not yet created, will return ErrorLevel = 1
		if (ErrorLevel)	;ErrorLevel = 1 = impossible to delete = do not exists yet
		{
			for key, value in ini_ShowTipsLib
			{
				Menu, ToggleLibTrigTipsSubmenu, Add, %key%, F_ToggleLibraryTips
				if (ini_LoadLib[key])
				{
					if (value)
						Menu, ToggleLibTrigTipsSubmenu, Check, %key%
					else
						Menu, ToggleLibTrigTipsSubmenu, UnCheck, %key%
				}
				else
					Menu, ToggleLibTrigTipsSubmenu, Disable, % key
			}
			Menu, % TransA["No libraries have been found!"], UseErrorLevel ;check if this menu exists
			if (!ErrorLevel)
				Menu, ToggleLibTrigTipsSubmenu, Delete, % TransA["No libraries have been found!"] ;if exists, delete it
			Menu, 	LibrariesSubmenu, 	Add, % TransA["Enable/disable triggerstring tips"], 	:ToggleLibTrigTipsSubmenu	
		}
		else		;recreate menu and shift it to correct position
		{
			for key, value in ini_ShowTipsLib
			{
				Menu, ToggleLibTrigTipsSubmenu, Add, %key%, F_ToggleLibraryTips
				if (ini_LoadLib[key])
				{
					if (value)
						Menu, ToggleLibTrigTipsSubmenu, Check, %key%
					else
						Menu, ToggleLibTrigTipsSubmenu, UnCheck, %key%
				}
				else
					Menu, ToggleLibTrigTipsSubmenu, Disable, % key
			}
			Menu, % TransA["No libraries have been found!"], UseErrorLevel ;check if this menu exists
			if (!ErrorLevel)
				Menu, ToggleLibTrigTipsSubmenu, Delete, % TransA["No libraries have been found!"] ;if exists, delete it
			
			Menu, 	LibrariesSubmenu, Delete, 2&	;delete separator line
			Menu, 	LibrariesSubmenu, Insert, % TransA["Visit public libraries webpage"], % TransA["Enable/disable triggerstring tips"], :ToggleLibTrigTipsSubmenu	
			Menu,	LibrariesSubmenu, Insert, % TransA["Visit public libraries webpage"]	;separator line
		}
	}
	else
	{
		Menu, ToggleLibTrigTipsSubmenu, 	Add, % TransA["No libraries have been found!"], 		F_ToggleLibraryTips
		Menu, LibrariesSubmenu,	Add, % TransA["Enable/disable triggerstring tips"], 	:ToggleLibTrigTipsSubmenu
	}
	Menu, ToggleLibTrigTipsSubmenu, UseErrorLevel, OFF	;This setting is global, meaning it affects all menus, not just MenuName.
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_RefreshListOfLibraries()
{
	global	;assume-global mode of operation
	local key := "", value := 0
	
	if (ini_LoadLib.Count())
	{ 
		Menu, EnDisLib, UseErrorLevel
		Menu, EnDisLib, Delete	;try to delete: if it's not yet created, will return ErrorLevel = 1
		if (ErrorLevel)	;ErrorLevel = 1 = impossible to delete = do not exists yet
		{
			for key, value in ini_LoadLib
			{
				Menu, EnDisLib, Add, %key%, F_ToggleLibrary
				if (value)
					Menu, EnDisLib, Check, %key%
				else
					Menu, EnDisLib, UnCheck, %key%	
			}
			Menu, % TransA["No libraries have been found!"], UseErrorLevel
			if (!ErrorLevel)
				Menu, EnDisLib, Delete, % TransA["No libraries have been found!"] ;if exists, delete it
			Menu,	LibrariesSubmenu,	Add, % TransA["Enable/disable libraries"],			:EnDisLib
		}
		else	;recreate menu and shift it to correct position
		{
			for key, value in ini_LoadLib
			{
				Menu, EnDisLib, Add, %key%, F_ToggleLibrary
				if (value)
					Menu, EnDisLib, Check, %key%
				else
					Menu, EnDisLib, UnCheck, %key%	
			}
			Menu, % TransA["No libraries have been found!"], UseErrorLevel
			if (!ErrorLevel)
				Menu, EnDisLib, Delete, % TransA["No libraries have been found!"] ;if exists, delete it
			Menu,	LibrariesSubmenu,	Insert, % TransA["Enable/disable triggerstring tips"], % TransA["Enable/disable libraries"],	:EnDisLib
		}
	}
	else
	{
		Menu, EnDisLib, 		Add, % TransA["No libraries have been found!"], 	F_ToggleLibrary
		Menu, LibrariesSubmenu,	Add, % TransA["Enable/disable libraries"],		:EnDisLib
	}
	Menu, EnDisLib, UseErrorLevel, OFF	;This setting is global, meaning it affects all menus, not just MenuName.
	F_RefreshListOfLibraryTips()	;if library is enabled again, enable switching of library tip (another position in menu)
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
	local 	LibraryFullPathAndName := "" 
			,txt := "", txt1 := "", txt2 := "", txt3 := "", txt4 := "", txt5 := "", txt6 := ""
			,v_SelectedRow := 0, v_Pointer := 0, index := 0
			,key := 0, val := "", options := "", triggerstring := "", EnDis := "", hotstring := ""
	
	Gui, HS3: +OwnDialogs
	
	v_SelectedRow := LV_GetNext()
	if (!v_SelectedRow) 
	{
		MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"],  % TransA["Select a row in the list-view, please!"]
		return
	}
	LV_GetText(triggerstring, 	v_SelectedRow, 1)	;triggerstring
	LV_GetText(options, 		v_SelectedRow, 2)	;options
	LV_GetText(EnDis,			v_SelectedRow, 4)	;enabled or disabled definition
	LV_GetText(hotstring, 		v_SelectedRow, 5)
	MsgBox, % 256 + 64 + 4, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["Selected definition d(t, o, h) will be deleted. Do you want to proceed?"] . "`n`n"
		. TransA["triggerstring"] . ":" . A_Space . triggerstring . A_Tab . TransA["options"] . ":" . A_Space . options . A_Tab . TransA["hotstring"] . ":" . A_Space . hotstring
	IfMsgBox, No
		return
	TrayTip, %A_ScriptName%, % TransA["Deleting hotstring..."], 1
	
	;1. Remove selected library file.
	LibraryFullPathAndName := ini_HADL . "\" . v_SelectHotstringLibrary
	FileDelete, % LibraryFullPathAndName
	
	;2. Disable selected hotstring.

	;In order to switch off, some options have to run in "reversed" state:
	if (EnDis = "En")	;only if definition is enabled, at first try to disable it (if it is disabled, just delete it)
	{
		if (InStr(options, "*"))
			options := StrReplace(options, "*", "*0")
		if (InStr(options, "B0"))
			options := StrReplace(options, "B0", "B")
		if (InStr(options, "O"))
			options := StrReplace(options, "O", "O0")
		if (InStr(options, "Z"))
			options := StrReplace(options, "Z", "Z0")
		Try
			Hotstring(":" . options . ":" . triggerstring, , "Off") 
		Catch
			MsgBox, 16, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["Error"], % "Function:" . A_ThisFunc . "`n`n" 
			. TransA["Something went wrong with hotstring deletion"] . ":" . "`n`n" 
			. "triggerstring:" . A_Space . v_Triggerstring . A_Tab . "options:" . A_Space . options . "`n" 
			. TransA["Library name:"] . A_Space . v_SelectHotstringLibrary 
	}
	
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
	FileAppend, % txt, % ini_HADL . "\" . v_SelectHotstringLibrary, UTF-8
	TrayTip, % A_ScriptName, % TransA["Specified definition of hotstring has been deleted"], 1
	
	;5. Decrement library counter.
	--v_LibHotstringCnt
	--v_TotalHotstringCnt
	GuiControl, , % IdText13,  % v_LibHotstringCnt
	GuiControl, , % IdText13b, % v_LibHotstringCnt
	GuiControl, , % IdText12,  % v_TotalHotstringCnt
	GuiControl, , % IdText12b, % v_TotalHotstringCnt
	
	;6. Remove from "Search" tables. Unfortunately index (v_SelectedRow) is sufficient only for one table, and in Searching there is "super table" containing all definitions from all available tables.
	for key, val in a_Library
		if (val = SubStr(v_SelectHotstringLibrary, 1, -4))
		{
			v_Pointer := key
			Break
		}
	v_Pointer += v_SelectedRow - 1
	
	a_Library			.RemoveAt(v_Pointer)
	a_Triggerstring	.RemoveAt(v_Pointer)
	a_TriggerOptions	.RemoveAt(v_Pointer)
	a_OutputFunction	.RemoveAt(v_Pointer)
	a_EnableDisable	.RemoveAt(v_Pointer)
	a_Hotstring		.RemoveAt(v_Pointer)
	a_Comment			.RemoveAt(v_Pointer)

	;7. Remove trigger hint. 
	for index in a_Combined	;recreate array a_Combined
		a_Combined[index] := a_Triggerstring[index] . "|" . a_TriggerOptions[index] . "|" . a_EnableDisable[index] . "|" . a_Hotstring[index]
	F_Sort_a_Triggers(a_Combined, ini_TipsSortAlphabetically, ini_TipsSortByLength)	

	;8. Update table for searching
	F_Searching("Reload")
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_ToggleRightColumn() ;Label of Button IdButton5, to toggle left part of gui 
{
	global ;assume-global mode
	local WinX := 0, WinY := 0, OutputvarTemp := 0, OutputvarTempW := 0
	
	Switch A_DefaultGui
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
		Gui, HS4: Show, % "X" WinX . A_Space . "Y" WinY . A_Space . "AutoSize"
		Gui, HS4: Show, AutoSize ;don't know why it has to be doubled to properly display...
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
		Gui, HS3: Show, AutoSize ;don't know why it has to be doubled to properly display...
		F_HS3RadioCaseGroup(v_RadioCaseGroup)
		ini_WhichGui := "HS3"
	}
	if (ini_WhichGui = "HS3")
		Menu, ConfGUI, Check, 	% TransA["Toggle main GUI"] . "`tF4"
	else
		Menu, ConfGUI, UnCheck, % TransA["Toggle main GUI"] . "`tF4"
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
HS4GuiSize() ;Gui event
{
	global ;assume-global mode
	if (A_EventInfo = 1) ; The window has been minimized.
	{
		ini_WhichGui := "HS4"
		return
	}
	HS4_GuiWidth  := A_GuiWidth
	HS4_GuiHeight := A_GuiHeight
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
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_GuiMain_Resize2()
{
	global ;assume-global mode
	local v_OutVarTemp1 := 0, v_OutVarTemp1X := 0, v_OutVarTemp1Y := 0, v_OutVarTemp1W := 0, v_OutVarTemp1H := 0 ;Within a function, to create a set of variables that is local instead of global, declare OutputVar as a local variable prior to using command GuiControlGet, Pos. However, it is often also necessary to declare each variable in the set, due to a common source of confusion.	
		,v_xNext := 0, v_yNext := 0, v_wNext := 0, v_hNext := 0
	
	v_wNext := A_GuiWidth - (2 * c_xmarg + LeftColumnW + c_WofMiddleButton)
,	v_hNext := A_GuiHeight - (c_ymarg + HofText + c_ymarg + HofText + c_HofSandbox + c_ymarg)
	GuiControl, MoveDraw, % IdListView1, % "w" . v_wNext . "h" . v_hNext
	v_xNext := LeftColumnW + c_xmarg + c_WofMiddleButton
,	v_yNext := A_GuiHeight - (c_ymarg + HofText + c_HofSandbox)
	GuiControl, MoveDraw, % IdText10, % "x" . v_xNext . "y" . v_yNext
	GuiControlGet, v_OutVarTemp1, Pos, % IdText10
	v_xNext := v_OutVarTemp1X + v_OutVarTemp1W + c_xmarg
	GuiControl, MoveDraw, % IdTextInfo17, % "x" . v_xNext . "y" . v_yNext
	v_xNext := LeftColumnW + c_WofMiddleButton + c_xmarg
,	v_yNext += HofText
,	v_wNext := A_GuiWidth - (2 * c_xmarg + LeftColumnW + c_WofMiddleButton)
	GuiControl, MoveDraw, % IdEdit10, % "x" . v_xNext . "y" . v_yNext . "w" . v_wNext
	v_hNext := A_GuiHeight - 2 * c_ymarg 
	GuiControl, MoveDraw, % IdButton5, % "h" . v_hNext 
	F_GuiMain_LVcolumnScale()
	;OutputDebug, % "Two:" 
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
	;OutputDebug, % "Four:" 
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_GuiMain_Resize1()
{
	global ;assume-global mode
	local	v_OutVarTemp1 := 0, v_OutVarTemp1X := 0, v_OutVarTemp1Y := 0, v_OutVarTemp1W := 0, v_OutVarTemp1H := 0 ;Within a function, to create a set of variables that is local instead of global, declare OutputVar as a local variable prior to using command GuiControlGet, Pos. However, it is often also necessary to declare each variable in the set, due to a common source of confusion.	
			,v_xNext := 0, v_yNext := 0, v_wNext := 0, v_hNext := 0
	
	v_wNext := A_GuiWidth - (2 * c_xmarg + LeftColumnW + c_WofMiddleButton)
,	v_hNext := A_GuiHeight - (2 * c_ymarg + HofText)
	GuiControl, MoveDraw, % IdListView1, % "w" . v_wNext . "h" . v_hNext  ;increase
	v_xNext := c_xmarg
,	v_yNext := LeftColumnH + c_ymarg
	GuiControl, MoveDraw, % IdText10, % "x" . v_xNext . "y" . v_yNext
	GuiControlGet, v_OutVarTemp1, Pos, % IdText10
	v_xNext := v_OutVarTemp1X + v_OutVarTemp1W + c_xmarg
,	v_yNext := LeftColumnH + c_ymarg
	GuiControl, MoveDraw, % IdTextInfo17, % "x" . v_xNext . "y" . v_yNext
	v_xNext := c_xmarg
,	v_yNext := LeftColumnH + c_ymarg + HofText 
,	v_wNext := LeftColumnW - 2 * c_xmarg
	GuiControl, MoveDraw, % IdEdit10, % "x" . v_xNext . "y" . v_yNext . "w" . v_wNext
	v_hNext := A_GuiHeight - (2 * c_ymarg)
	GuiControl, MoveDraw, % IdButton5, % "h" . v_hNext 
	F_GuiMain_LVcolumnScale()
	;OutputDebug, % "One:" . A_Tab . "ini_IsSandboxMoved" . A_Space . ini_IsSandboxMoved 
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
,	v_yNext := A_GuiHeight - (c_ymarg + HofText + c_HofSandbox)
	GuiControl, MoveDraw, % IdText10, % "x" . v_xNext . "y" . v_yNext
	GuiControlGet, v_OutVarTemp1, Pos, % IdText10
	v_xNext := v_OutVarTemp1X + v_OutVarTemp1W + c_xmarg
	GuiControl, MoveDraw, % IdTextInfo17, % "x" . v_xNext . "y" . v_yNext
	v_xNext := LeftColumnW + c_WofMiddleButton + c_xmarg
,	v_yNext += HofText
,	v_wNext := A_GuiWidth - (2 * c_xmarg + LeftColumnW + c_WofMiddleButton)
	GuiControl, MoveDraw, % IdEdit10, % "x" . v_xNext . "y" . v_yNext . "w" . v_wNext
	v_hNext := A_GuiHeight - 2 * c_ymarg 
	GuiControl, MoveDraw, % IdButton5, % "h" . v_hNext 
	F_GuiMain_LVcolumnScale()
	;OutputDebug, % "Three:" . A_Tab . "ini_IsSandboxMoved" . A_Space . ini_IsSandboxMoved 
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_GuiMain_Resize5()
{
	global ;assume-global mode
	local	v_xNext := 0, v_yNext := 0, v_wNext := 0, v_hNext := 0
	
	v_hNext := A_GuiHeight - (HofText + 2 * c_ymarg)
,	v_wNext := A_GuiWidth - (2 * c_xmarg + LeftColumnW + c_WofMiddleButton)
	GuiControl, MoveDraw, % IdListView1, % "w" . v_wNext . "h" . v_hNext
	v_hNext := A_GuiHeight - (2 * c_ymarg)
	GuiControl, MoveDraw, % IdButton5, % "h" . v_hNext
	F_GuiMain_LVcolumnScale()
	;OutputDebug, % "Five"
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
HS3GuiSize(GuiHwnd, EventInfo, Width, Height) ;Gui event
{	;This function toggles flag ini_IsSandboxMoved
	global ;assume-global mode of operation
	local v_OutVarTemp2 := 0, v_OutVarTemp2X := 0, v_OutVarTemp2Y := 0, v_OutVarTemp2W := 0, v_OutVarTemp2H := 0 ;Within a function, to create a set of variables that is local instead of global, declare OutputVar as a local variable prior to using command GuiControlGet, Pos. However, it is often also necessary to declare each variable in the set, due to a common source of confusion.	
		,ListViewWidth := 0
		,v_xNext := 0, v_yNext := 0, v_wNext := 0, v_hNext := 0
	
	HS3_GuiWidth  := A_GuiWidth	;used by F_SaveGUIPos()
,	HS3_GuiHeight := A_GuiHeight	;used by F_SaveGUIPos()
	if (f_MainGUIresizing)
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
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
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
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_HSLV() ; copy content of List View 1 to editable fields of HS3 Gui
{
	Critical, On
	; OutputDebug, % "A_ThisFunc:" . A_Space . A_ThisFunc . A_Tab . "A_GuiEvent:" . A_Space . A_GuiEvent . A_Tab . "A_GuiControl:" . A_Space . A_GuiControl . A_Tab . "A_EventInfo:" . A_Space . A_EventInfo . A_Tab . "ErrorLevel:" . A_Space . ErrorLevel . "`n"
	Switch A_GuiEvent
	{
		Default:
			Critical, Off
			return
		Case "Normal":		LV1_CopyContentToHS3()
	}
	Critical, Off
}	
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
LV1_CopyContentToHS3()
{
	global ;assume-global mode of operation
	local Options := "", Fun := "", EnDis := "", TextInsert := "", OTextMenu := "", Comment := ""
		,v_SelectedRow := 0

	if !(v_SelectedRow := LV_GetNext())
		return
	
	LV_GetText(v_Triggerstring, 	v_SelectedRow, 1)
	GuiControl, HS3:, % IdEdit1, % v_Triggerstring
	GuiControl, HS4:, % IdEdit1, % v_Triggerstring
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
		GuiControl, HS3: ChooseString, % IdDDL1, 	SendInput (SI)
		GuiControl, HS4: ChooseString, % IdDDL1b, 	SendInput (SI)
		Case "CL":	;SendFun := "F_HOF_CLI"
		GuiControl, HS3: ChooseString, % IdDDL1, 	Clipboard (CL)
		GuiControl, HS4: ChooseString, % IdDDL1b, 	Clipboard (CL)
		Case "MCL":	;SendFun := "F_HOF_MCLI"
		GuiControl, HS3: ChooseString, % IdDDL1, 	Menu & Clipboard (MCL)
		GuiControl, HS4: ChooseString, % IdDDL1b, 	Menu & Clipboard (MCL)
		Case "MSI":	;SendFun := "F_HOF_MSI"
		GuiControl, HS3: ChooseString, % IdDDL1, 	Menu & SendInput (MSI)
		GuiControl, HS4: ChooseString, % IdDDL1b, 	Menu & SendInput (MSI)
		Case "SR":	
		GuiControl, HS3: ChooseString, % IdDDL1, 	SendRaw (SR)
		GuiControl, HS4: ChooseString, % IdDDL1b, 	SendRaw (SR)
		Case "SP":
		GuiControl, HS3: ChooseString, % IdDDL1, 	SendPlay (SP)
		GuiControl, HS4: ChooseString, % IdDDL1b, 	SendPlay (SP)
		Case "SE":
		GuiControl, HS3: ChooseString, % IdDDL1, 	SendEvent (SE)
		GuiControl, HS4: ChooseString, % IdDDL1b, 	SendEvent (SE)
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
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
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
	c_FontType := ""
	
	IniRead, c_FontType, 			% ini_HADConfig, GraphicalUserInterface, GuiFontType, Calibri
	if (!c_FontType)
		c_FontType := "Calibri"
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
	c_xmarg := 10	;pixels
	c_ymarg := 10	;pixels
	
	IniRead, c_xmarg, 			% ini_HADConfig, GraphicalUserInterface, GuiSizeOfMarginX, 10
	IniRead, c_ymarg,			% ini_HADConfig, GraphicalUserInterface, GuiSizeOfMarginY, 10
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
	c_FontSize 				:= 0 ;points
	
	IniRead, c_FontSize, 			% ini_HADConfig, GraphicalUserInterface, GuiFontSize, 10
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
	c_FontColor				:= ""
	c_FontColorHighlighted		:= ""
	c_WindowColor				:= ""
	c_ControlColor 			:= ""
	
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
		Menu,	AppSubmenu,	Add,	% TransA["Convert to executable (.exe)"],		:CompileSubmenu
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
		Menu, AppSubmenu,		Add,	% TransA["Convert to executable (.exe)"],		F_Compile
		Menu, AppSubmenu, 		Disable,										% TransA["Convert to executable (.exe)"]
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
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
			if (FileExist(A_ScriptDir . "\" . SubStr(A_ScriptName, 1, -4) . "." . "exe"))
				FileDelete, % A_ScriptDir . "\" . SubStr(A_ScriptName, 1, -4) . "." . "exe"
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
			if (FileExist(A_ScriptDir . "\" . SubStr(A_ScriptName, 1, -4) . "." . "exe"))
				FileDelete, % A_ScriptDir . "\" . SubStr(A_ScriptName, 1, -4) . "." . "exe"
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
			if (FileExist(A_ScriptDir . "\" . SubStr(A_ScriptName, 1, -4) . "." . "exe"))
				FileDelete, % A_ScriptDir . "\" . SubStr(A_ScriptName, 1, -4) . "." . "exe"
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
			if (FileExist(A_ScriptDir . "\" . SubStr(A_ScriptName, 1, -4) . "." . "exe"))
				FileDelete, % A_ScriptDir . "\" . SubStr(A_ScriptName, 1, -4) . "." . "exe"
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
			if (FileExist(A_ScriptDir . "\" . SubStr(A_ScriptName, 1, -4) . "." . "exe"))
				FileDelete, % A_ScriptDir . "\" . SubStr(A_ScriptName, 1, -4) . "." . "exe"
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
			if (FileExist(A_ScriptDir . "\" . SubStr(A_ScriptName, 1, -4) . "." . "exe"))
				FileDelete, % A_ScriptDir . "\" . SubStr(A_ScriptName, 1, -4) . "." . "exe"
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
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_ReloadApplication(params*)	;ItemName, ItemPos, MenuName
{
	global ;assume-global mode

 	if (params[1] = "Run from new location")
	 {
		Switch A_IsCompiled
		{
			Case % true:	Run, % A_AhkPath . A_Space . """" . params[2] . """" . "\" . SubStr(A_ScriptName, 1, -4) . ".exe"
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
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_ToggleSandbox()
{
	global ;assume-global mode
	
	Menu, ConfGUI, ToggleCheck, % TransA["Show Sandbox"] . "`tF6"
	ini_Sandbox := !(ini_Sandbox)
	Iniwrite, %ini_Sandbox%, % ini_HADConfig, GraphicalUserInterface, Sandbox
	
	F_GuiMain_Redraw()
	F_GuiHS4_Redraw()
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
	;after loading values (empty by default) those parameters are further used in F_GUIinit()
	IniRead, ini_ReadTemp, 					% ini_HADConfig, GraphicalUserInterface, MainWindowPosX, 	% A_Space	;empty by default
	ini_HS3WindoPos["X"] := ini_ReadTemp
	IniRead, ini_ReadTemp, 					% ini_HADConfig, GraphicalUserInterface, MainWindowPosY, 	% A_Space	;empty by default
	ini_HS3WindoPos["Y"] := ini_ReadTemp
	IniRead, ini_ReadTemp, 					% ini_HADConfig, GraphicalUserInterface, MainWindowPosW, 	% A_Space	;empty by default
	ini_HS3WindoPos["W"] := ini_ReadTemp
	IniRead, ini_ReadTemp, 					% ini_HADConfig, GraphicalUserInterface, MainWindowPosH, 	% A_Space	;empty by default
	ini_HS3WindoPos["H"] := ini_ReadTemp
	
	IniRead, ini_ReadTemp,					% ini_HADConfig, GraphicalUserInterface, ListViewPosW, 	% A_Space
	ini_ListViewPos["W"] := ini_ReadTemp
	IniRead, ini_ReadTemp,					% ini_HADConfig, GraphicalUserInterface, ListViewPosH, 	% A_Space
	ini_ListViewPos["H"] := ini_ReadTemp
	
	IniRead, ini_Sandbox, 					% ini_HADConfig, GraphicalUserInterface, Sandbox,			1
	IniRead, ini_IsSandboxMoved,				% ini_HADConfig, GraphicalUserInterface, IsSandboxMoved, 	0 
	IniRead, ini_WhichGui,					% ini_HADConfig, GraphicalUserInterface, WhichGui, 		% A_Space
	if (ini_WhichGui = "")
		ini_WhichGui := "HS3"
	IniRead, ini_HS3GuiMaximized,				% ini_HADConfig, GraphicalUserInterface, GuiMaximized, 	0
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_CheckCreateConfigIni(params*)
{
	global ;assume-global mode
	local  ConfigIni 	:= ""	; variable which is used as default content of Config.ini
		, HADConfig_AppData  	:= A_AppData   . "\" . SubStr(A_ScriptName, 1, -4) . "\"	. "Config.ini"	;Hotstrings Application Data Config .ini
		, HADConfig_App		:= A_ScriptDir . "\" . "Config.ini"
	
	ConfigIni := "			
	(
[Configuration]
ClipBoardPasteDelay=300
HotstringUndo=1
ShowIntro=1
CheckRepo=0
DownloadRepo=0
HK_Main=#^h
HK_IntoEdit=~#c
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
TTTypefaceFont=Calibri
TTTypefaceSize=10
[EvStyle_HM]
HMBackgroundColor=white
HMBackgroundColorCustom=
HMTypefaceColorCustom=
HMTypefaceColor=black
HMTypefaceFont=Calibri
HMTypefaceSize=10
[EvStyle_AT]
ATBackgroundColor=green
ATBackgroundColorCustom=
ATTypefaceColorCustom=
ATTypefaceColor=black
ATTypefaceFont=Calibri
ATTypefaceSize=10
[EvStyle_HT]
HTBackgroundColor=green
HTBackgroundColorCustom=
HTTypefaceColorCustom=
HTTypefaceColor=black
HTTypefaceFont=Calibri
HTTypefaceSize=11
[EvStyle_UH]
UHBackgroundColor=green
UHBackgroundColorCustom=
UHTypefaceColorCustom=
UHTypefaceColor=black
UHTypefaceFont=Calibri
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
	
	if (params[1])
	{
		Switch params[1]
		{
			Case HADConfig_AppData:	FileAppend, %ConfigIni%, % HADConfig_AppData
			Case HADConfig_App:		FileAppend, %ConfigIni%, % HADConfig_App
		}
		return
	}

	if (!FileExist(HADConfig_AppData)) and (!FileExist(HADConfig_App))
	{
		OutputDebug, % "HADConfig_AppData:" . A_Tab . HADConfig_AppData . "`n" . "HADConfig_App:" . A_Tab . HADConfig_App . "`n`n"
		if (!InStr(FileExist(A_AppData . "\" . SubStr(A_ScriptName, 1, -4)), "D"))	;if there is no folder...
		{
			FileCreateDir, % A_AppData . "\" . SubStr(A_ScriptName, 1, -4)	;future: check against errors
		}
		FileAppend, %ConfigIni%, % HADConfig_AppData
		if (FileExist(A_ScriptDir . "\Languages\English.txt"))	;if there is no Config.ini, then English.txt should be recreated.
			FileDelete, % A_ScriptDir . "\Languages\English.txt"	;future: check against errors
		MsgBox, 48, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["warning"], % TransA["Config.ini wasn't found. The default Config.ini has now been created in location:"] . "`n`n" . HADConfig_AppData
		ini_HADConfig := HADConfig_AppData
		return
	}
	if (FileExist(HADConfig_AppData))
	{
		ini_HADConfig := HADConfig_AppData
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
		IniWrite, % WinX, 			  	% ini_HADConfig, GraphicalUserInterface, MainWindowPosX
		IniWrite, % WinY, 			  	% ini_HADConfig, GraphicalUserInterface, MainWindowPosY
		IniWrite, % "", 				% ini_HADConfig, GraphicalUserInterface, MainWindowPosW
		IniWrite, % "", 				% ini_HADConfig, GraphicalUserInterface, MainWindowPosH
		return
	}	
	F_WhichGui()		;This line is necessary in case when last Gui is not equal to HS3 or HS4. This is a case e.g. if Gui_VersionUpdate is active
	if (A_DefaultGui = "HS3")
	{
		WinGetPos, WinX, WinY, , , % "ahk_id" . HS3GuiHwnd
		IniWrite,  HS3,			% ini_HADConfig, GraphicalUserInterface, WhichGui
		IniWrite, % HS3_GuiWidth, 	% ini_HADConfig, GraphicalUserInterface, MainWindowPosW
		IniWrite, % HS3_GuiHeight, 	% ini_HADConfig, GraphicalUserInterface, MainWindowPosH
		GuiControlGet, TempPos,	Pos, % IdListView1
		IniWrite, % TempPosW,		% ini_HADConfig, GraphicalUserInterface, ListViewPosW
		IniWrite, % TempPosH,		% ini_HADConfig, GraphicalUserInterface, ListViewPosH
		IniWrite, % ini_HS3GuiMaximized, 	% ini_HADConfig, GraphicalUserInterface, GuiMaximized
	}
	if (A_DefaultGui = "HS4")
	{
		WinGetPos, WinX, WinY, , , % "ahk_id" . HS4GuiHwnd
		IniWrite,  HS4,			% ini_HADConfig, GraphicalUserInterface, WhichGui
		IniWrite, % HS4_GuiWidth, 	% ini_HADConfig, GraphicalUserInterface, MainWindowPosW
		IniWrite, % HS4_GuiHeight, 	% ini_HADConfig, GraphicalUserInterface, MainWindowPosH
	}
	
	IniWrite, % WinX, 			  % ini_HADConfig, GraphicalUserInterface, MainWindowPosX
	IniWrite, % WinY, 			  % ini_HADConfig, GraphicalUserInterface, MainWindowPosY
	
	IniWrite, % ini_Sandbox, 	  % ini_HADConfig, GraphicalUserInterface, Sandbox
	IniWrite, % ini_IsSandboxMoved, % ini_HADConfig, GraphicalUserInterface, IsSandboxMoved
	
	MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["Position of this window is saved in Config.ini."]
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_LoadHotstringsFromLibraries()
{
	global ; assume-global mode
	local key := "", value := "", PriorityFlag := false
	a_Library 				:= []	;initialization of global variable
	, a_TriggerOptions 			:= []
	, a_Triggerstring 			:= []
	, a_OutputFunction 			:= []
	, a_EnableDisable 			:= []
	, a_Hotstring				:= []
	, a_Comment 				:= []
	, a_Combined				:= []
	; , a_Gain					:= []
	
; Prepare TrayTip message taking into account value of command line parameter.
	if (v_Param == "l")
		TrayTip, %A_ScriptName% - Lite mode, 	% TransA["Loading hotstrings from libraries..."], 1
	else	
		TrayTip, %A_ScriptName%,				% TransA["Loading hotstrings from libraries..."], 1
	
; Load (triggerstring, hotstring) definitions if enabled and triggerstring tips if enabled.
	v_TotalHotstringCnt := 0
	
	for key, value in ini_LoadLib
	{
		if ((key != "PriorityLibrary.csv") and (value))
		{
			F_LoadDefinitionsFromFile(key)
			F_LoadTriggTipsFromFile(key)
		}
		if ((key == "PriorityLibrary.csv") and (value))
			PriorityFlag := true
	}
	if (PriorityFlag)
	{
		F_LoadDefinitionsFromFile("PriorityLibrary.csv")
		F_LoadTriggTipsFromFile("PriorityLibrary.csv")
		PriorityFlag := false
	}
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
		Loop, Parse, A_LoopField, ‖
		{
			Switch A_Index
			{
				Case 1:	tmp2 := A_LoopField
				Case 2:	tmp1 := A_LoopField
				Case 4:	tmp3 := A_LoopField
				Case 5:	tmp4 := A_LoopField
			}
		}
		a_Combined.Push(tmp1 . "|" . tmp2 . "|" . tmp3 . "|" . tmp4)
	}	
}
; ------------------------------------------------------------------------------------------------------------------------------------
F_UnloadTriggTipsFromMemory(LibraryFilename)
{
	global ;assume-global mode of operation
	local	key := 0,	value := "", LibraryName := SubStr(LibraryFilename, 1, -4)	;remove extension
	
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
	key := 0, value := ""	;recreate a_Combined
,	a_Combined := []
	for key in a_Library
		a_Combined.Push(a_Triggerstring[key] . "|" . a_TriggerOptions[key] . "|" . a_EnableDisable[key] . "|" . a_Hotstring[key])
}
; ------------------------------------------------------------------------------------------------------------------------------------
F_ToggleLibrary()	;load / unload d(t, o, h)
{
	global ;assume-global mode of operation
	local 	v_LibraryFlag := 0, name := SubStr(A_ThisMenuItem, 1, -4)	;without file extension
	
	Menu, EnDisLib, ToggleCheck, %A_ThisMenuItem%	;future: don't ready .ini file, instead use appropriate table
	IniRead, v_LibraryFlag,	% ini_HADConfig, LoadLibraries, %A_ThisMenuitem%
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
	GuiControl, , % IdText12,  % v_TotalHotstringCnt ; Text: Puts new contents into the control.
	GuiControl, , % IdText12b, % v_TotalHotstringCnt ; Text: Puts new contents into the control.
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
According to your wish the new version of application was found on the server and downloaded. = According to your wish the new version of application was found on the server and downloaded.
Active triggerstring tips								= Active triggerstring tips
Active triggerstring tips styling							= Active triggerstring tips styling
Actually the ""Libraries"" folder is already located in default location, so it won't be moved. = Actually the ""Libraries"" folder is already located in default location, so it won't be moved.
Add comment (optional) 									= Add comment (optional)
Add / Edit hotstring (F9) 								= Add / Edit hotstring (F9)
Add library 											= Add library
Add new library file									= Add new library file
Add to Autostart										= Add to Autostart
After downloading libraries aren't automaticlly loaded into memory. Would you like to upload content of libraries folder into memory? = After downloading libraries aren't automaticlly loaded into memory. Would you like to upload content of libraries folder into memory?
A library with that name already exists! 					= A library with that name already exists!
Alphabetically 										= Alphabetically
already exists in another library							= already exists in another library
Apostrophe ' 											= Apostrophe '
Application											= A&pplication
Application has been running since							= Application has been running since
Application help										= Application help
Application language changed to: 							= Application language changed to:
Application mode										= Application mode
Application statistics									= Application statistics
Apply												= &Apply
aqua													= aqua
Are you sure?											= Are you sure?
Are you sure you want to exit this application now?			= Are you sure you want to exit this application now?
Are you sure you want to move ""Hotstrings"" folder and all its content to the new location? = Are you sure you want to move ""Hotstrings"" folder and all its content to the new location?
Are you sure you want to reload this application now?			= Are you sure you want to reload this application now?
At first select library name which you intend to delete.		= At first select library name which you intend to delete.
AutoHotkey version										= AutoHotkey version
Background color										= Background color
Backslash \ 											= Backslash \
Basic hotstring is triggered								= Basic hotstring is triggered
black												= black
blue													= blue
Both optional locations for library folder are empty = do not contain any library files. The second one will be used. = Both optional locations for library folder are empty = do not contain any library files. The second one will be used.
Both optional library folder locations contain *.csv files. Would you like to use the first one? = Both optional library folder locations contain *.csv files. Would you like to use the first one?
Built with Autohotkey.exe version							= Built with Autohotkey.exe version
By default library files (*.csv) are located in Users subfolder which is protected against other computer users. = By default library files (*.csv) are located in Users subfolder which is protected against other computer users.
By length 											= By length
Call Graphical User Interface								= Call Graphical User Interface
Cancel 												= &Cancel
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
Close												= Cl&ose
Closing Curly Bracket } 									= Closing Curly Bracket }
Closing Round Bracket ) 									= Closing Round Bracket )
Closing Square Bracket ] 								= Closing Square Bracket ]
Colon : 												= Colon :
Comma , 												= Comma ,
Convert to executable (.exe)								= Convert to executable (.exe)
Composition of triggerstring tips							= Composition of triggerstring tips
Compressed executable (upx.exe)							= Compressed executable (upx.exe)
Compressed executable (mpress.exe)							= Compressed executable (mpress.exe)
Config.ini file: move it to script / app location				= Config.ini file: move it to script / app location
Config.ini file: restore it to default location				= Config.ini file: restore it to default location
Config.ini file was successfully moved to the new location.		= Config.ini file was successfully moved to the new location.
Config.ini wasn't found. The default Config.ini has now been created in location: = Config.ini wasn't found. The default Config.ini has now been created in location:
Configuration 											= &Configuration
Content of clipboard contain new line characters. Do you want to remove them? = Content of clipboard contain new line characters. Do you want to remove them?
Continue reading the library file? If you answer ""No"" then application will exit! = Continue reading the library file? If you answer ""No"" then application will exit!
Conversion of .ahk file into new .csv file (library) and loading of that new library = Conversion of .ahk file into new .csv file (library) and loading of that new library
Conversion of .csv library file into new .ahk file containing static (triggerstring, hotstring) definitions = Conversion of .csv library file into new .ahk file containing static (triggerstring, hotstring) definitions
Conversion of .csv library file into new .ahk file containing dynamic (triggerstring, hotstring) definitions = Conversion of .csv library file into new .ahk file containing dynamic (triggerstring, hotstring) definitions
Converted												= Converted
Copy clipboard content into ""Enter hotstring""				= Copy clipboard content into ""Enter hotstring""
Cumulative gain [characters]								= Cumulative gain [characters]
Current Config.ini file location:							= Current Config.ini file location:
(Current configuration will be saved befor reload takes place).	= (Current configuration will be saved befor reload takes place).
Current ""Libraries"" location:							= Current ""Libraries"" location:
Current script / application location:						= Current script / application location:
Current shortcut (hotkey):								= Current shortcut (hotkey):
Current time											= Current time
cursor												= cursor
custom												= custom
Dark													= Dark
default 												= default
Default mode											= Default mode
Del library											= Del library
Delete existing library file								= Delete existing library file
Delete hotstring (F8) 									= Delete hotstring (F8)
Deleting hotstring... 									= Deleting hotstring...
Deleting hotstring. Please wait... 						= Deleting hotstring. Please wait...
Disable 												= Disable
disable												= disable
DISABLED												= DISABLED
Do you want to replace it with source definition?				= Do you want to replace it with source definition?
Download if update is available on startup?					= Download if update is available on startup?
Download public libraries								= Download public libraries
Do you wish to apply your changes?							= Do you wish to apply your changes?
Do you want to delete it?								= Do you want to delete it?
Do you want to proceed? 									= Do you want to proceed?
Dot . 												= Dot .
Do you want to reload application now?						= Do you want to reload application now?
doesn't exist in application folder						= doesn't exist in application folder
Download repository version								= Download repository version
Downloading public library files							= Downloading public library files
Dynamic hotstrings 										= &Dynamic hotstrings
Edit Hotstrings 										= Edit Hotstrings
Enable												= Enable
enable												= enable
En/Dis												= En/Dis
Enable/disable libraries									= Enable/disable &libraries
Enable/disable triggerstring tips 							= Enable/disable triggerstring tips	
Enables Convenient Definition 							= Enables convenient definition and use of hotstrings (triggered by shortcuts longer text strings). `nThis is 4th edition of this application, 2021 by Maciej Słojewski (🐘). `nLicense: GNU GPL ver. 3.
Enter 												= Enter 
Enter a name for the new library 							= Enter a name for the new library
Enter hotstring 										= Enter hotstring
Enter triggerstring										= Enter triggerstring
Triggerstring cannot be empty  if you wish to add new hotstring	= Triggerstring cannot be empty  if you wish to add new hotstring
Error												= Error
ErrorLevel was triggered by NewInput error. 					= ErrorLevel was triggered by NewInput error.
Error reading library file:								= Error reading library file:
Exclamation Mark ! 										= Exclamation Mark !
exists in the currently selected library					= exists in the currently selected library
exists in the library									= exists in the library
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
have to be escaped in the following form:					= have to be escaped in the following form:
Help: AutoHotkey Hotstrings reference guide					= Help: AutoHotkey Hotstrings reference guide
Help: Hotstrings application								= Help: Hotstrings application
Hotstring 											= Hotstring
Hotstring added to the file								= Hotstring added to the file
Hotstring has been deleted. Now application will restart itself in order to apply changes, reload the libraries (.csv) = Hotstring has been deleted. Now application will restart itself in order to apply changes, reload the libraries (.csv)
Hotstring menu styling									= Hotstring menu styling
Hotstring was triggered! 								= Hotstring was triggered!
Hotstring moved to the 									= Hotstring moved to the
Hotstring paste from Clipboard delay 1 s 					= Hotstring paste from Clipboard delay 1 s
Hotstring paste from Clipboard delay 						= Hotstring paste from Clipboard delay
Hotstrings											= Hotstrings
Hotstrings have been loaded 								= Hotstrings have been loaded
HTML color RGB value, e.g. 00FF00							= HTML color RGB value, e.g. 00FF00
)"	;A continuation section cannot produce a line whose total length is greater than 16,383 characters. See documentation for workaround.
	TransConst .= "`n
(Join`n `
I wish you good work with Hotstrings and DFTBA (Don't Forget to be Awsome)! = I wish you good work with Hotstrings and DFTBA (Don't Forget to be Awsome)!
If not finite, define tooltip timeout						= If not finite, define tooltip timeout
If sound is enabled, define it							= If sound is enabled, define it
(Any existing files in destination folder will be overwritten). 	= (Any existing files in destination folder will be overwritten).
If you answer ""Yes"" it will overwritten.					= If you answer ""Yes"" it will overwritten.
If you answer ""Yes"" definition existing in another library will not be changed. = If you answer ""Yes"" definition existing in another library will not be changed.
If you answer ""Yes"" it will overwritten with chosen settings. = If you answer ""Yes"" it will overwritten with chosen settings.
If you answer ""Yes"", the icon file will be downloaded. If you answer ""No"", the default AutoHotkey icon will be used. = If you answer ""Yes"", the icon file will be downloaded. If you answer ""No"", the default AutoHotkey icon will be used.
If you answer ""Yes"", the existing file will be deleted. This is recommended choice. If you answer ""No"", new content will be added to existing file. = If you answer ""Yes"", the existing file will be deleted. This is recommended choice. If you answer ""No"", new content will be added to existing file.
If you answer ""Yes"", then new definition will be created, but seleced special character will not be visible. = If you answer ""Yes"", then new definition will be created, but seleced special character will not be visible.
If you answer ""No"" edition of the current definition will be interrupted. = If you answer ""No"" edition of the current definition will be interrupted.
(If you answer ""No"", the second one will be used).			= (If you answer ""No"", the second one will be used).
If you answer ""No"", then you will get a chance to fix your new created definition. = If you answer ""No"", then you will get a chance to fix your new created definition.
If you apply ""SI"" or ""MSI"" or ""SE"" output function then some characters like = If you apply ""SI"" or ""MSI"" or ""SE"" output function then some characters like
If you don't apply it, previous changes will be lost.			= If you don't apply it, previous changes will be lost.
Immediate Execute (*) 									= Immediate Execute (*)
Import from .ahk to .csv 								= &Import from .ahk to .csv
Incorrect value. Select custom RGB hex value. Please try again.	= Incorrect value. Select custom RGB hex value. Please try again.
(In default folder Config.ini is protected among others against changes implied by other users). = (In default folder Config.ini is protected among others against changes implied by other users).
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
Last hotstring undo function is currently unsuported for those characters, sorry. = Last hotstring undo function is currently unsuported for those characters, sorry.
Let's make your PC personal again... 						= Let's make your PC personal again...
Libraries folder: move it to new location					= Libraries folder: move it to new location
Libraries folder: restore it to default location				= Libraries folder: restore it to default location
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
Location of application specific data						= Location of application specific data
Loading of (triggerstring, hotstring) definitions from the library file = Loading of (triggerstring, hotstring) definitions from the library file
Loading file											= Loading file
Loaded hotstrings: 										= Loaded hotstrings:
Loading hotstrings from libraries... 						= Loading hotstrings from libraries...
Loading imported library. Please wait...					= Loading imported library. Please wait...
Loaded												= Loaded
Local version											= Local version
Logging of d(t, o, h)									= Logging of d(t, o, h)
Log triggered hotstrings									= Log triggered hotstrings
maroon												= maroon
Max. no. of shown tips									= Max. no. of shown tips
Menu hotstring is triggered								= Menu hotstring is triggered
Menu position											= Menu position
Menu position: caret									= Menu position: caret
Menu position: cursor									= Menu position: cursor
Minus - 												= Minus -
Mode of operation										= Mode of operation
Move (F8)												= Move (F8)
navy													= navy
Next the default language file (English.txt) will be deleted,	= Next the default language file (English.txt) will be deleted,
reloaded and fresh language file (English.txt) will be recreated. = reloaded and fresh language file (English.txt) will be recreated.
New location:											= New location:
New location (default):									= New location (default):
New settings are now applied.							     = New settings are now applied.
New shortcut (hotkey)									= New shortcut (hotkey)
No													= No
no													= no
No Backspace (B0) 										= No Backspace (B0)
No EndChar (O) 										= No EndChar (O)
No libraries have been found!								= No libraries have been found!
Not Case-Conforming (C1)									= Not Case-Conforming (C1)
Nothing to do to me, Config.ini is already where you want it.	= Nothing to do to me, Config.ini is already where you want it.
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
OnOff parameter is missing								= OnOff parameter is missing
On start-up the local version of application was compared with repository version and difference was discovered: = On start-up the local version of application was compared with repository version and difference was discovered:
Open Config.ini in your default editor						= Open Config.ini in your default editor
Open folder where Config.ini is located						= Open folder where Config.ini is located
Open folder where log files are located						= Open folder where log files are located
Open libraries folder in Explorer							= Open libraries folder in Explorer
Opening Curly Bracket { 									= Opening Curly Bracket {
Opening Round Bracket ( 									= Opening Round Bracket (
Opening Square Bracket [ 								= Opening Square Bracket [
options												= options	
or													= or
question												= question
Question Mark ? 										= Question Mark ?
Quote "" 												= Quote ""
Pause												= Pause
Pause application										= Pause application
Perhaps check if any other application (like File Manager) do not occupy folder to be removed. = Perhaps check if any other application (like File Manager) do not occupy folder to be removed.
Phrase to search for:									= Phrase to search for:
pixels												= pixels
Please try again.										= Please try again.
Please wait, uploading .csv files... 						= Please wait, uploading .csv files...
Position of this window is saved in Config.ini.				= Position of this window is saved in Config.ini.	
Preview												= &Preview
Press Esc when you've finished							= Press Esc when you've finished
Public library:										= Public library:
purple												= purple
question												= question
Recognized encoding of the file:							= Recognized encoding of the file:
red													= red
Reload												= Reload
Reload in default mode									= Reload in default mode
Reload in silent mode									= Reload in silent mode
Replacement text is blank. Do you want to proceed? 			= Replacement text is blank. Do you want to proceed?
Repository version										= Repository version
Required encoding: UTF-8 with BOM. Application will exit now.	= Required encoding: UTF-8 with BOM. Application will exit now.
Reset Recognizer (Z)									= Reset Recognizer (Z)
Restore default										= Restore default
Apply default hotkey									= Apply default hotkey
Restore default configuration								= Restore default configuration
Row													= Row
)"
	TransConst .= "`n
(Join`n `
Sandbox (F6)											= Sandbox (F6)
Apply new hotkey											= Apply new hotkey
Save position of application window	 					= &Save position of application window
Save window position									= Save window position
Saved												= Saved
Saving of sorted content into .csv file (library)				= Saving of sorted content into .csv file (library)
Script/application folder: move it to new location			= Script/application folder: move it to new location
Script/application folder: restore it to default location		= Script/application folder: restore it to default location
Search by: 											= Search by:
Search Hotstrings 										= Search Hotstrings
Search Hotstrings (F3)									= &Search Hotstrings (F3)
Select a row in the list-view, please! 						= Select a row in the list-view, please!
Select folder where ""Hotstrings"" folder will be moved.		= Select folder where ""Hotstrings"" folder will be moved.
Select folder where libraries (*.csv  files) will be moved.		= Select folder where libraries (*.csv  files) will be moved.
Select hotstring library									= Select hotstring library
Selected definition d(t, o, h) will be deleted. Do you want to proceed? 	= Selected definition d(t, o, h) will be deleted. Do you want to proceed?
Select hotstring output function 							= Select hotstring output function
Select library file to be deleted							= Select library file to be deleted
Select the target library: 								= Select the target library:
Select triggerstring option(s)							= Select triggerstring option(s)
Semicolon ; 											= Semicolon ;
Send Raw (R)											= Send Raw (R)
Set Clipboard Delay										= Set Clipboard Delay
Set delay												= Set delay
Set triggerstring tip(s) tooltip timeout					= Set triggerstring tip(s) tooltip timeout
Set parameters of menu sound								= Set parameters of menu sound
Set parameters of triggerstring sound						= Set parameters of triggerstring sound
Shortcut (hotkey) definition								= Shortcut (hotkey) definition
Shortcut (hotkey) definitions								= Shortcut (hotkey) definitions
Show intro											= Show intro
Show Introduction window after application is restarted?		= Show Introduction window after application is restarted?
Show Sandbox											= Show Sandbox
Events: signaling										= Events: signaling
Silent mode											= Silent mode
silver												= silver
Size of font											= Size of font
Size of margin:										= Size of margin:
Slash / 												= Slash /
Something went wrong during hotstring setup					= Something went wrong during hotstring setup
Something went wrong on time of file removal.				= Something went wrong on time of file removal.
Something went wrong on time of library file selection or you've cancelled. = Something went wrong on time of library file selection or you've cancelled.
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
""SP"" or SendPlay may have no effect at all if UAC is enabled, even if the script is running as an administrator. For more information, refer to the AutoHotkey FAQ (help). = ""SP"" or SendPlay may have no effect at all if UAC is enabled, even if the script is running as an administrator. For more information, refer to the AutoHotkey FAQ (help).
Space												= Space
Specified definition of hotstring has been deleted			= Specified definition of hotstring has been deleted
Standard executable (Ahk2Exe.exe)							= Standard executable (Ahk2Exe.exe)
Start-up time											= Start-up time
Static hotstrings 										= &Static hotstrings
Static triggerstring / hotstring menus						= Static triggerstring / hotstring menus
Style of GUI											= Style of GUI
Such file already exists									= Such file already exists
Suspend Hotkeys										= Suspend Hotkeys
Tab 													= Tab 
To move folder into ""Program Files"" folder you must allow admin privileges to ""Hotstrings"", which will restart to move its folder. = To move folder into ""Program Files"" folder you must allow admin privileges to ""Hotstrings"", which will restart to move its folder.
teal													= teal
Test styling											= Test styling
Toggle main GUI										= Toggle main GUI
The application										= The application
The application will be reloaded with the new language file. 	= The application will be reloaded with the new language file.
The default											= The default
The default language file (English.txt) will be deleted (it will be automatically recreated after restart). However if you use localized version of language file, you'd need to download it manually. = The default language file (English.txt) will be deleted (it will be automatically recreated after restart). However if you use localized version of language file, you'd need to download it manually.
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
Toggle trigger characters (↓ or EndChars)					= &Toggle trigger characters (↓ or EndChars)
Toggle triggerstring tips								= Toggle triggerstring tips
Tooltip: ""Hotstring was triggered""						= Tooltip: ""Hotstring was triggered""
Tooltip: ""Undid the last hotstring""						= Tooltip: ""Undid the last hotstring""
Tooltip disable										= Tooltip disable
Tooltip enable											= Tooltip enable
Tooltip position										= Tooltip position
Tooltip test											= Tooltip test
Tooltip timeout										= Tooltip timeout
Total:												= Total:
to undo.												= to undo.
(triggerstring, hotstring) definitions						= (triggerstring, hotstring) definitions
Triggers												= Triggers
Triggerstring 											= Triggerstring
Triggerstring / hotstring behaviour						= Triggerstring / hotstring behaviour
Triggerstring sound duration [ms]							= Triggerstring sound duration [ms]
Triggerstring sound frequency range						= Triggerstring sound frequency range
Triggerstring tips 										= Triggerstring tips
Triggerstring tips have been loaded from the following library file to memory: = Triggerstring tips have been loaded from the following library file to memory:
Triggerstring tips related to the following library file have been unloaded from memory: = Triggerstring tips related to the following library file have been unloaded from memory:
Triggerstring tips styling								= Triggerstring tips styling
Events: styling										= Events: styling
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
Version												= Version
Visit public libraries webpage							= Visit public libraries webpage
warning												= warning
Warning, code generated automatically for definitions based on menu, see documentation of Hotstrings application for further details. = Warning, code generated automatically for definitions based on menu, see documentation of Hotstrings application for further details.
was successfully downloaded.								= was successfully downloaded.
Welcome to Hotstrings application!							= Welcome to Hotstrings application!
Windows key modifier									= Windows key modifier
When triggerstring event takes place, sound is emitted according to the following settings. = When triggerstring event takes place, sound is emitted according to the following settings.
white												= white
Would you like to change the current ""Libraries"" folder location? = Would you like to change the current ""Libraries"" folder location?
Would you like to change Config.ini file location to default one (AppData)? = Would you like to change Config.ini file location to default one (AppData)?
Would you like to change Config.ini file location to folder where is ""Hotstrings"" script / app? = Would you like to change Config.ini file location to folder where is ""Hotstrings"" script / app?
Would you like to download the icon file?					= Would you like to download the icon file?
Would you like to move ""Libraries"" folder and all *.csv files to the new location? = Would you like to move ""Libraries"" folder and all *.csv files to the new location?
Would you like now to reload it in order to run the just downloaded version? = Would you like now to reload it in order to run the just downloaded version?
Would you like to move ""Hotstrings"" script / application to default location? = Would you like to move ""Hotstrings"" script / application to default location?
Would you like to move ""Hotstrings"" script / application somewhere else? = Would you like to move ""Hotstrings"" script / application somewhere else?
Would you like to move ""Libraries"" folder to this location?	= Would you like to move ""Libraries"" folder to this location?
)"
	TransConst .= "`n
(Join`n `
yellow												= yellow
Yes													= Yes
yes													= yes
You've cancelled this process.							= You've cancelled this process.
You've changed at least one configuration parameter, but didn't yet apply it. = You've changed at least one configuration parameter, but didn't yet apply it.
Your hotstring definition contain one of the following characters: = Your hotstring definition contain one of the following characters:
↓ Click here to select hotstring library ↓					= ↓ Click here to select hotstring library ↓
{Up} or {Down} or {Home} or {End} or {PgUp} or {PgDown}		= {Up} or {Down} or {Home} or {End} or {PgUp} or {PgDown}
ShowInfoText											= In order to display graphical user interface (GUI) of the application just press shortcut: Win + Ctrl + H. `n`nSuggested steps after installation: `n`n1. Download some libraries (files containing (triggerstring, hotstring) definitions. You can do it from application menu:  → Libraries. `n`n2. After downloading of libraries restart application to apply the changes. Again, you can do it from application menu: Application → Restart. `n`n3. Application is preconfigured on the first start. Options available to be configured area available from GUI, application menu → Configuration. `n`n4. Application runs by default in default mode. If you don't wish to modify configuration, `nmay consider to run it in simplified mode: application menu → Application → Reload → Reload in silent mode.
F_TI_ImmediateExecute									= * (asterisk): An EndChar (e.g. Space, ., or Enter) is not required to trigger the hotstring. For example:`n`n:*:j@::jsmith@somedomain.com`n`nThe example above would send its replacement the moment you type the @ character.
F_TI_InsideWord										= ? (question mark): The hotstring will be triggered even when it is inside another word; `n`nthat is, when the character typed immediately before it is alphanumeric. `nFor example, if :?:al::airline is a hotstring, `ntyping ""practical "" would produce ""practicairline "".
F_TI_NoBackSpace										= B0: Automatic backspacing is not done to erase the abbreviation you type. `n`nOne may send ← five times via {left 5}. For example, the following hotstring produces ""<em></em>"" and `nmoves the caret 5 places to the left (so that it's between the tags) `n`n::*b0:<em>::</em>{left 5}
F_TI_NoEndChar											= O: Omit the ending character of auto-replace hotstrings when the replacement is produced. `n`nThis is useful when you want a hotstring to be kept unambiguous by still requiring an ending character, `nbut don't actually want the ending character to be shown on the screen. `nFor example, if :o:ar::aristocrat is a hotstring, typing ""ar"" followed by the spacebar will produce ""aristocrat"" with no trailing space, `nwhich allows you to make the word plural or possessive without having to press Backspace.
F_TI_OptionResetRecognizer								= Z: Resets the hotstring recognizer after each triggering of the hotstring. `n`nIn other words, the script will begin waiting for an entirely new hotstring, eliminating from consideration anything you previously typed. `nThis can prevent unwanted triggerings of hotstrings. 
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
F_HK_ToggleTtInfo										= Toggle visibility of all triggerstring tips. Advice: use ScrollLock or CapsLock for that purpose.
T_SBackgroundColorInfo									= Select from drop down list predefined color (one of 16 HTML colors) `nor select Custom one and then provide RGB value in HEX format (e.g. FF0000 for red). `nThe selected color will be displayed as background for on-screen menu.
T_STypefaceColor										= Select from drop down list predefined color (one of 16 HTML colors) `nor select Custom one and then provide RGB value in HEX format (e.g. FF0000 for red). `nThe selected color will be displayed as font color for on-screen menu.
T_STypefaceFont										= Select from drop down list predefined font type. `nThe selected font type will be used in on screen menu.
T_STypefaceSize										= Select from drop down list predefined size of font. `nThe selected font size will be used in on screen menu.
T_StylPreview											= Press the ""Test styling"" button to get look & feel of selected styling settings below.
T_SoundEnable											= Sound can be emitted each time when event takes place. `nOne can specify sound frequency and duration.`n`nYou may slide the control by the following means: `n`n1) dragging the bar with the mouse; `n2) clicking inside the bar's track area with the mouse; `n3) turning the mouse wheel while the control has focus or `n4) pressing the following keys while the control has focus: ↑, →, ↓, ←, PgUp, PgDn, Home, and End. `n`nPgUp / PgDn step: 50 [ms]; `nInterval:         150 [ms]; `nRange:            50 ÷ 2 000 [ms]. `n`nTip: Recommended time is between 200 to 400 ms. `n`nPgUp / PgDn step: 50 [ms]; `nInterval:         150 [ms]; `nRange:            50 ÷ 2 000 [ms]. `n`nTip: Recommended time is between 200 to 400 ms.
T_TooltipEnable										= You can enable or disable the following tooltip: ""Hotstring was triggered! [Shortcut] to undo."" `nIf enabled, this tooltip is shown each time when even of displaying hotstring upon triggering it takes place. `nNext you can set accompanying features like timeout, position and even sound. 
T_TooltipPosition										= Specify where tooltip should be displayed by default.`n`nWarning: some applications do not accept caret position. `n`nThen automatically cursor position is followed.
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
,			ExternalIndex := 0
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
          ExternalIndex++
		Loop, Parse, A_LoopField, ‖
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
					if (InStr(A_LoopField, "¦"))
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
	GuiControl, , % IdText12,  % v_TotalHotstringCnt ; Text: Puts new contents into the control.
	GuiControl, , % IdText12b, % v_TotalHotstringCnt ; Text: Puts new contents into the control.
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
	Menu, HSMenu, % EnDis, % TransA["Search Hotstrings (F3)"]
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
	GuiControl, % EnDis, % IdTextInfo10b
	GuiControl, % EnDis, % IdCheckBox6b
	GuiControl, % EnDis, % IdTextInfo11b
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
	GuiControl, % EnDis, % IdButton1b
	GuiControl, % EnDis, % IdDDL2b
	GuiControl, % EnDis, % IdButton2b
	GuiControl, % EnDis, % IdButton3b
	GuiControl, % EnDis, % IdButton4b
	GuiControl, % EnDis, % IdButton5b
	GuiControl, % EnDis, % IdButton6B
	GuiControl, % EnDis, % IdText10b
	GuiControl, % EnDis, % IdTextInfo17b
	GuiControl, % EnDis, % IdEdit10b
	GuiControl, % EnDis, % IdText11b
	GuiControl, % EnDis, % IdText13b
	GuiControl, % EnDis, % IdText2b
	GuiControl, % EnDis, % IdText12b
}
; ------------------------------------------------------------------------------------------------------------------------------------
F_GuiHS4_CreateObject()
{
	global ;assume-global mode of operation
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
	Gui,		HS4: Add,		Radio,		x0 y0 HwndIdRadioCaseCCb AltSubmit vv_RadioCaseGroup Checked gF_RadioCaseCol,	% TransA["Case-Conforming"]	;these lines have to stay together in order to keep the same variable for group of radios
	Gui,		HS4: Add,		Radio,		x0 y0 HWndIdRadioCaseCSb AltSubmit gF_RadioCaseCol,			% TransA["Case Sensitive (C)"]
	Gui,		HS4: Add,		Radio,		x0 y0 HwndIdRadioCaseC1b AltSubmit gF_RadioCaseCol,			% TransA["Not Case-Conforming (C1)"]
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
	Gui, 	HS4: Add, 	Button, 		x0 y0 HwndIdButton6b gF_DelLibByButton,						% TransA["Del library"]
	Gui,		HS4: Add,		DropDownList,	x0 y0 HwndIdDDL2b vv_SelectHotstringLibrary gF_SelectLibrary Sort
	
	Gui, 	HS4: Add,		Button, 		x0 y0 HwndIdButton2b gF_AddHotstring,						% TransA["Add / Edit hotstring (F9)"]
	Gui, 	HS4: Add, 	Button, 		x0 y0 HwndIdButton3b gF_Clear,							% TransA["Clear (F5)"]
	Gui, 	HS4: Add, 	Button, 		x0 y0 HwndIdButton4b gF_DeleteHotstring vv_DeleteHotstring Disabled, 	% TransA["Delete hotstring (F8)"]
	
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
F_GuiMain_EnDis(EnDis)	;EnDis = "Disable" or "Enable"
{
	global ;assume-global mode of operation
	static	PS_IdEdit3 := false, PS_IdEdit4 := false, PS_IdEdit5 := false, PS_IdEdit6 := false, PS_IdEdit7 := false, PS_IdEdit8 := false

	Menu, HSMenu, % EnDis, % TransA["Configuration"]
	Menu, HSMenu, % EnDis, % TransA["Search Hotstrings (F3)"]
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
	GuiControl, %  EnDis, % IdTextInfo3
	GuiControl, %  EnDis, % IdTextInfo5
	GuiControl, %  EnDis, % IdTextInfo7
	GuiControl, %  EnDis, % IdCheckBox3
	GuiControl, %  EnDis, % IdCheckBox4
	GuiControl, %  EnDis, % IdCheckBox5
	GuiControl, %  EnDis, % IdTextInfo4
	GuiControl, %  EnDis, % IdTextInfo6
	GuiControl, %  EnDis, % IdTextInfo8
	GuiControl, %  EnDis, % IdCheckBox8
	GuiControl, %  EnDis, % IdTextInfo10
	GuiControl, %  EnDis, % IdCheckBox6
	GuiControl, %  EnDis, % IdTextInfo11
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
	GuiControl, % EnDis, % IdButton1
	GuiControl, % EnDis, % IdDDL2
	GuiControl, % EnDis, % IdButton2
	GuiControl, % EnDis, % IdButton3
	GuiControl, % EnDis, % IdButton4
	GuiControl, % EnDis, % IdButton5
	GuiControl, % EnDis, % IdButton6
	GuiControl, % EnDis, % IdText7
	GuiControl, % EnDis, % IdTextInfo16
	GuiControl, % EnDis, % IdText2
	GuiControl, % EnDis, % IdText12
	GuiControl, % EnDis, % IdText9
	GuiControl, % EnDis, % IdListView1
	GuiControl, % EnDis, % IdText10
	GuiControl, % EnDis, % IdTextInfo17
	GuiControl, % EnDis, % IdEdit10
	GuiControl, % EnDis, % IdText11
	GuiControl, % EnDis, % IdText13
}
; ------------------------------------------------------------------------------------------------------------------------------------
F_GuiMain_CreateObject()
{
	global ;assume-global mode of operation
	local x0 := 0, y0 := 0

	v_TotalHotstringCnt 		:= 0000
,	v_LibHotstringCnt			:= 0000 ;no of (triggerstring, hotstring) definitions in single library
,	HS3_GuiWidth  				:= 0
,	HS3_GuiHeight 				:= 0
	
;1. Definition of HS3 GUI.
;-DPIScale doesn't work in Microsoft Windows 10
;+Border doesn't work in Microsoft Windows 10
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
,	F_TI_CaseSensitive		:= func("F_ShowLongTooltip").bind(TransA["F_TI_CaseSensitive"])
,	F_TI_NotCaseConforming	:= func("F_ShowLongTooltip").bind(TransA["F_TI_NotCaseConforming"])
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
	
	Gui, 		HS3: Add, 		Edit, 		x0 y0 HwndIdEdit9 vv_Comment Limit96 
	
	Gui,			HS3: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, 		HS3: Add, 		Text, 		x0 y0 HwndIdText6,						 				% TransA["Select hotstring library"]
	Gui, 		HS3: Font, 		% "s" . c_FontSize + 2	
	Gui,			HS3: Add,			Text,		x0 y0 HwndIdTextInfo15,									ⓘ
	TI_SelectHotstringLib	:= func("F_ShowLongTooltip").bind(TransA["TI_SelectHotstringLib"])
	GuiControl +g, % IdTextInfo15, % TI_SelectHotstringLib
	
	Gui,			HS3: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, 			% c_FontType
	
	Gui, 		HS3: Add, 		Button, 		x0 y0 HwndIdButton1 gF_GuiAddLibrary, 						% TransA["Add library"]
	Gui, 		HS3: Add, 		Button, 		x0 y0 HwndIdButton6 gF_DelLibByButton, 						% TransA["Del library"]
	Gui,			HS3: Add,			DropDownList,	x0 y0 HwndIdDDL2 vv_SelectHotstringLibrary gF_SelectLibrary Sort
	
	Gui, 		HS3: Add, 		Button, 		x0 y0 HwndIdButton2 gF_AddHotstring,						% TransA["Add / Edit hotstring (F9)"]
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
	
	Gui,			HS3: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, % c_FontType
	
	Gui, 		HS3: Add, 		Edit, 		x0 y0 HwndIdEdit10 vv_Sandbox r3 						; r3 = 3x rows of text
	Gui,			HS3: Add,		Text,		x0 y0 HwndIdText11, % TransA["This library:"] . A_Space
	Gui,			HS3: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, Consolas ;Consolas type is monospace
	Gui, 		HS3: Add, 		Text, 		x0 y0 HwndIdText13,  %  v_LibHotstringCnt ;value of Hotstrings counter in the current library
	
	Gui,			HS3: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, % c_FontType
}
; ------------------------------------------------------------------------------------------------------------------------------------
F_GuiMain_DefineConstants()
{
	global ;assume-global mode
	local v_OutVarTemp := 0, v_OutVarTempX := 0, v_OutVarTempY := 0, v_OutVarTempW := 0, v_OutVarTempH := 0	;Within a function, to create a set of variables that is local instead of global, declare OutputVar as a local variable prior to using command GuiControlGet, Pos. However, it is often also necessary to declare each variable in the set, due to a common source of confusion.	
	
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
	F_WhichGui()
	Switch A_DefaultGui
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
		GuiControl, HS3:, % TransA["Case-Conforming"], 1
		Case 2:
		Gui, HS3: Font, % "s" . c_FontSize . A_Space . "cGreen Norm", % c_FontType
		GuiControl, HS3: Font, % TransA["Case Sensitive (C)"]
		GuiControl, HS3:, % TransA["Case Sensitive (C)"], 1
		Gui, HS3: Font, % "s" . c_FontSize . A_Space . "c" . c_FontColor . A_Space . "Norm", % c_FontType
		GuiControl, HS3: Font, % TransA["Case-Conforming"]
		GuiControl, HS3: Font, % TransA["Not Case-Conforming (C1)"]
		Case 3:
		Gui, HS3: Font, % "s" . c_FontSize . A_Space . "cGreen Norm", % c_FontType
		GuiControl, HS3: Font, % TransA["Not Case-Conforming (C1)"]
		GuiControl, HS3:, % TransA["Not Case-Conforming (C1)"], 1
		Gui, HS3: Font, % "s" . c_FontSize . A_Space . "c" . c_FontColor . A_Space . "Norm", % c_FontType					
		GuiControl, HS3: Font, % TransA["Case Sensitive (C)"]
		GuiControl, HS3: Font, % TransA["Case-Conforming"]
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
		GuiControl, HS4:, % TransA["Case-Conforming"], 1
		Case 2:
		Gui, HS4: Font, % "s" . c_FontSize . A_Space . "cGreen Norm", % c_FontType
		GuiControl, HS4: Font, % TransA["Case Sensitive (C)"]
		GuiControl, HS4:, % TransA["Case Sensitive (C)"], 1
		Gui, HS4: Font, % "s" . c_FontSize . A_Space . "c" . c_FontColor . A_Space . "Norm", % c_FontType
		GuiControl, HS4: Font, % TransA["Case-Conforming"]
		GuiControl, HS4: Font, % TransA["Not Case-Conforming (C1)"]
		Case 3: 
		Gui, HS4: Font, % "s" . c_FontSize . A_Space . "cGreen Norm", % c_FontType
		GuiControl, HS4: Font, % TransA["Not Case-Conforming (C1)"]
		GuiControl, HS4:, % TransA["Not Case-Conforming (C1)"], 1
		Gui, HS4: Font, % "s" . c_FontSize . A_Space . "c" . c_FontColor . A_Space . "Norm", % c_FontType
		GuiControl, HS4: Font, % TransA["Case Sensitive (C)"]
		GuiControl, HS4: Font, % TransA["Case-Conforming"]
	}
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
	global ;assume-global mode
	local v_OutVarTemp := 0, 	v_OutVarTempX := 0, 	v_OutVarTempY := 0, 	v_OutVarTempW := 0, 	v_OutVarTempH := 0 ;Within a function, to create a set of variables that is local instead of global, declare OutputVar as a local variable prior to using command GuiControlGet, Pos. However, it is often also necessary to declare each variable in the set, due to a common source of confusion.
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
	
,	LeftColumnW := 2 * c_xmarg + W_C1 + c_xmarg + W_C2 + c_xmarg
	
;5. Move text objects to correct position
;5.1. Left column
;5.1.1. Enter triggerstring
	v_xNext := c_xmarg
,	v_yNext := c_ymarg
	GuiControl, Move, % IdText1b, % "x" . v_xNext . "y" . v_yNext
	
	GuiControlGet, v_OutVarTemp1, Pos, % IdText1b
	v_xNext += v_OutVarTemp1W + c_xmarg
	GuiControl, Move, % IdTextInfo1b, % "x" . v_xNext . "y" . v_yNext
	v_xNext += W_InfoSign + c_xmarg
,	v_wNext := LeftColumnW - v_xNext - c_xmarg
	GuiControl, Move, % IdEdit1b, % "x" . v_xNext . "y" . v_yNext . "w" . v_wNext
	
;5.1.2. Select trigger options
	v_xNext := c_xmarg 
,	v_yNext := c_ymarg + HofEdit + HofText 
,	v_wNext := c_xmarg + W_C1 + c_xmarg  + W_C2
,	v_hNext := HofText + c_ymarg + HofCheckBox * 5 + c_ymarg
	GuiControl, Move, % IdGroupBox1b, % "x" . v_xNext . "y" . v_yNext . "w" . v_wNext . "h" . v_hNext
;5.1.2.1. Raw 1: Immediate execute (*) + Case-Conforming
	v_xNext += c_xmarg
,	v_yNext += HofText + c_ymarg
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
,	v_yNext += HofCheckBox
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
,	v_yNext += HofCheckBox
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
,	v_yNext += HofCheckBox
	GuiControl, Move, % IdCheckBox5b, % "x" . v_xNext . "y" . v_yNext	
	GuiControlGet, v_OutVarTemp1, Pos, % IdCheckBox5
	v_xNext += v_OutVarTemp1W
	GuiControl, Move, % IdTextInfo8b, % "x" . v_xNext . "y" . v_yNext 
;5.1.2.6. Raw 5: Reset Recognizer (Z) + Disable
	v_xNext := c_xmarg * 2
,	v_yNext += HofCheckBox
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
,	v_yNext += HofCheckBox + c_ymarg * 2
	GuiControl, Move, % IdText3b, % "x" . v_xNext . "y" . v_yNext
	GuiControlGet, v_OutVarTemp1, Pos, % IdText3b
	v_xNext += v_OutVarTemp1W + c_xmarg
	GuiControl, Move, % IdTextInfo12b, % "x" . v_xNext . "y" . v_yNext
	v_xNext := c_xmarg
,	v_yNext += HofText
,	v_wNext := LeftColumnW - 2 * c_xmarg
	GuiControl, Move, % IdDDL1b, % "x" . v_xNext . "y" . v_yNext . "w" . v_wNext
	
;5.1.4. Enter hotstring
	v_yNext += HofDropDownList + c_ymarg
,	v_xNext := c_xmarg
	GuiControl, Move, % IdText4b, % "x" . v_xNext . "y" . v_yNext
	GuiControlGet, v_OutVarTemp1, Pos, % IdText4b
	v_xNext += v_OutVarTemp1W + c_xmarg
	GuiControl, Move, % IdTextInfo13b, % "x" . v_xNext . "y" . v_yNext
	v_xNext := c_xmarg
,	v_yNext += HofText
,	v_wNext := LeftColumnW - 2 * c_xmarg
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
,	v_xNext := c_xmarg
	GuiControl, Move, % IdText5b, % "x" . v_xNext . "y" . v_yNext
	GuiControlGet, v_OutVarTemp1, Pos, % IdText5b
	v_xNext += v_OutVarTemp1W + c_xmarg
	GuiControl, Move, % IdTextInfo14b, % "x" . v_xNext . "y" . v_yNext
	v_xNext := c_xmarg
,	v_yNext += HofText
,	v_wNext := LeftColumnW - 2 * c_xmarg
	GuiControl, Move, % IdEdit9b, % "x" . v_xNext . "y" . v_yNext . "w" . v_wNext
;5.1.6. Select hotstring library 	
	v_yNext += HofEdit + c_ymarg
,	v_xNext := c_xmarg
	GuiControl, Move, % IdText6b, % "x" . v_xNext . "y" . v_yNext
	GuiControlGet, v_OutVarTemp1, Pos, % IdText6b
	v_xNext += v_OutVarTemp1W + c_xmarg
	GuiControl, Move, % IdTextInfo15b, % "x" . v_xNext . "y" . v_yNext
	GuiControlGet, v_OutVarTemp2, Pos, % IdButton1b
	v_OutVarTemp := LeftColumnW - (v_OutVarTemp1W + v_OutVarTemp2W + c_xmarg)
,	v_xNext := v_OutVarTemp1W + v_OutVarTemp
,	v_wNext := v_OutVarTemp2W
	GuiControl, Move, % IdButton1b, % "x" . v_xNext . "y" . v_yNext . "w" . v_wNext ;Add library button

	GuiControlGet, v_OutVarTemp1, Pos, % IdButton1b	;Add library button
	GuiControlGet, v_OutVarTemp2, Pos, % IdButton6b	;Del library button
	v_xNext := v_OutVarTemp1X - (c_xmarg + v_OutVarTemp2W) ; ,	v_wNext := v_OutVarTemp2W	
	GuiControl, Move, % IdButton6b, % "x" . v_xNext . "y" . v_yNext . "w" . v_wNext ;Del library button

	v_yNext += HofButton
,	v_xNext := c_xmarg
,	v_wNext := LeftColumnW - v_xNext - c_xmarg
	GuiControl, Move, % IdDDL2b, % "x" v_xNext "y" v_yNext "w" . v_wNext
	
;5.1.7. Buttons	
	v_yNext += HofDropDownList + c_ymarg
	GuiControlGet, v_OutVarTemp1, Pos, % IdButton2b
	GuiControlGet, v_OutVarTemp2, Pos, % IdButton3b
	GuiControlGet, v_OutVarTemp3, Pos, % IdButton4b
	GPB := (LeftColumnW - (c_xmarg + v_OutVarTemp1W + v_OutVarTemp2W + v_OutVarTemp3W + c_xmarg)) // 2 ;GPB = Gap Between Buttons
,	v_xNext := c_xmarg
	GuiControl, Move, % IdButton2b, % "x" . v_xNext . "y" . v_yNext
	GuiControlGet, v_OutVarTemp1, Pos, % IdButton2b
	v_xNext += v_OutVarTemp1W + GPB
	GuiControl, Move, % IdButton3b, % "x" . v_xNext . "y" . v_yNext
	GuiControlGet, v_OutVarTemp1, Pos, % IdButton3b
	v_xNext += v_OutVarTemp1W + GPB
	GuiControl, Move, % IdButton4b, % "x" . v_xNext . "y" . v_yNext
	v_yNext += HofButton
,	LeftColumnH := v_yNext
	;OutputDebug, % "LeftColumnH:" . A_Space . LeftColumnH
	HS4MinWidth		:= LeftColumnW 
,	HS4MinHeight		:= LeftColumnH
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
	global ;assume-global mode
	local v_OutVarTemp := 0, 	v_OutVarTempX := 0, 	v_OutVarTempY := 0, 	v_OutVarTempW := 0, 	v_OutVarTempH := 0 ;Within a function, to create a set of variables that is local instead of global, declare OutputVar as a local variable prior to using command GuiControlGet, Pos. However, it is often also necessary to declare each variable in the set, due to a common source of confusion.
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
	
,	LeftColumnW := 2 * c_xmarg + W_C1 + c_xmarg + W_C2 + c_xmarg
	
;4.2. Determine right column width
	GuiControlGet, v_OutVarTemp2, Pos, % IdText9 ;Triggerstring|Trigg Opt|Out Fun|En/Dis|Hotstring|Comment"]
	RightColumnW := v_OutVarTemp2W
	GuiControl,	Hide,		% IdText9
	
;5. Move text objects to correct position
;5.1. Left column
;5.1.1. Enter triggerstring
	v_xNext := c_xmarg
,	v_yNext := c_ymarg
	GuiControl, Move, % IdText1, % "x" . v_xNext . "y" . v_yNext
	
	GuiControlGet, v_OutVarTemp1, Pos, % IdText1
	v_xNext += v_OutVarTemp1W + c_xmarg
	GuiControl, Move, % IdTextInfo1, % "x" . v_xNext . "y" . v_yNext
	v_xNext += W_InfoSign + c_xmarg
,	v_wNext := LeftColumnW - v_xNext - c_xmarg
	GuiControl, Move, % IdEdit1, % "x" . v_xNext . "y" . v_yNext . "w" . v_wNext
	
;5.1.2. Select trigger options
	v_xNext := c_xmarg 
,	v_yNext := c_ymarg + HofEdit + HofText 
,	v_wNext := c_xmarg + W_C1 + c_xmarg  + W_C2
,	v_hNext := HofText + c_ymarg + HofCheckBox * 5 + c_ymarg
	GuiControl, Move, % IdGroupBox1, % "x" . v_xNext . "y" . v_yNext . "w" . v_wNext . "h" . v_hNext
;5.1.2.1. Raw 1: Immediate execute (*) + Case-Conforming
	v_xNext += c_xmarg
,	v_yNext += HofText + c_ymarg
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
,	v_yNext += HofCheckBox
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
,	v_yNext += HofCheckBox
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
,	v_yNext += HofCheckBox
	GuiControl, Move, % IdCheckBox5, % "x" . v_xNext . "y" . v_yNext	
	GuiControlGet, v_OutVarTemp1, Pos, % IdCheckBox5
	v_xNext += v_OutVarTemp1W
	GuiControl, Move, % IdTextInfo8, % "x" . v_xNext . "y" . v_yNext 
;5.1.2.6. Raw 5: Reset Recognizer (Z) + Disable
	v_xNext := c_xmarg * 2
,	v_yNext += HofCheckBox
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
,	v_yNext += HofCheckBox + c_ymarg * 2
	GuiControl, Move, % IdText3, % "x" . v_xNext . "y" . v_yNext
	GuiControlGet, v_OutVarTemp1, Pos, % IdText3
	v_xNext += v_OutVarTemp1W + c_xmarg
	GuiControl, Move, % IdTextInfo12, % "x" . v_xNext . "y" . v_yNext
	v_xNext := c_xmarg
,	v_yNext += HofText
,	v_wNext := LeftColumnW - 2 * c_xmarg
	GuiControl, Move, % IdDDL1, % "x" . v_xNext . "y" . v_yNext . "w" . v_wNext
	
;5.1.4. Enter hotstring
	v_yNext += HofDropDownList + c_ymarg
,	v_xNext := c_xmarg
	GuiControl, Move, % IdText4, % "x" . v_xNext . "y" . v_yNext
	GuiControlGet, v_OutVarTemp1, Pos, % IdText4
	v_xNext += v_OutVarTemp1W + c_xmarg
	GuiControl, Move, % IdTextInfo13, % "x" . v_xNext . "y" . v_yNext
	v_xNext := c_xmarg
,	v_yNext += HofText
,	v_wNext := LeftColumnW - 2 * c_xmarg
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
,	v_xNext := c_xmarg
	GuiControl, Move, % IdText5, % "x" . v_xNext . "y" . v_yNext
	GuiControlGet, v_OutVarTemp1, Pos, % IdText5
	v_xNext += v_OutVarTemp1W + c_xmarg
	GuiControl, Move, % IdTextInfo14, % "x" . v_xNext . "y" . v_yNext
	v_xNext := c_xmarg
,	v_yNext += HofText
,	v_wNext := LeftColumnW - 2 * c_xmarg
	GuiControl, Move, % IdEdit9, % "x" . v_xNext . "y" . v_yNext . "w" . v_wNext
;5.1.6. Select hotstring library 	
	v_yNext += HofEdit + c_ymarg
,	v_xNext := c_xmarg
	GuiControl, Move, % IdText6, % "x" . v_xNext . "y" . v_yNext
	GuiControlGet, v_OutVarTemp1, Pos, % IdText6
	v_xNext += v_OutVarTemp1W + c_xmarg
	GuiControl, Move, % IdTextInfo15, % "x" . v_xNext . "y" . v_yNext
	GuiControlGet, v_OutVarTemp2, Pos, % IdButton1
	v_OutVarTemp := LeftColumnW - (v_OutVarTemp1W + v_OutVarTemp2W + c_xmarg)
,	v_xNext := v_OutVarTemp1W + v_OutVarTemp
,	v_wNext := v_OutVarTemp2W
	GuiControl, Move, % IdButton1, % "x" . v_xNext . "y" . v_yNext . "w" . v_wNext ;Add library button

	GuiControlGet, v_OutVarTemp1, Pos, % IdButton1	;Add library button
	GuiControlGet, v_OutVarTemp2, Pos, % IdButton6	;Del library button
	v_xNext := v_OutVarTemp1X - (c_xmarg + v_OutVarTemp2W) ; ,	v_wNext := v_OutVarTemp2W	
	GuiControl, Move, % IdButton6, % "x" . v_xNext . "y" . v_yNext . "w" . v_wNext ;Del library button

	v_yNext += HofButton
,	v_xNext := c_xmarg
,	v_wNext := LeftColumnW - v_xNext - c_xmarg
	GuiControl, Move, % IdDDL2, % "x" v_xNext "y" v_yNext "w" . v_wNext
	
;5.1.7. Buttons	
	v_yNext += HofDropDownList + c_ymarg
	GuiControlGet, v_OutVarTemp1, Pos, % IdButton2
	GuiControlGet, v_OutVarTemp2, Pos, % IdButton3
	GuiControlGet, v_OutVarTemp3, Pos, % IdButton4
	GPB := (LeftColumnW - (c_xmarg + v_OutVarTemp1W + v_OutVarTemp2W + v_OutVarTemp3W + c_xmarg)) // 2 ;GPB = Gap Between Buttons
,	v_xNext := c_xmarg
	GuiControl, Move, % IdButton2, % "x" . v_xNext . "y" . v_yNext
	GuiControlGet, v_OutVarTemp1, Pos, % IdButton2
	v_xNext += v_OutVarTemp1W + GPB
	GuiControl, Move, % IdButton3, % "x" . v_xNext . "y" . v_yNext
	GuiControlGet, v_OutVarTemp1, Pos, % IdButton3
	v_xNext += v_OutVarTemp1W + GPB
	GuiControl, Move, % IdButton4, % "x" . v_xNext . "y" . v_yNext
	v_yNext += HofButton
,	LeftColumnH := v_yNext
	;OutputDebug, % "LeftColumnH:" . A_Space . LeftColumnH
	
;5.3. Right column
;5.3.1. Position the text "Library content"
	v_yNext := c_ymarg
,	v_xNext := LeftColumnW + c_WofMiddleButton + c_xmarg
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
	Gui, MyAbout: Add, 		Button,  	x0 y0 HwndIdAboutOkButton gMyAboutGuiClose,					% TransA["OK"]
	Gui, MyAbout: Add,		Picture, 	x0 y0 HwndIdAboutPicture w96 h96, 							% AppIcon
	Gui, MyAbout: Add,		Text,	x0 y0 HwndIdAboutT1,									% TransA["Version"] . ":"
	Gui, MyAbout: Add,		Text,	x0 y0 HwndIdAboutT2,									% AppVersion
	Gui, MyAbout: Add,		Text,	x0 y0 HwndIdAboutT3,									% TransA["Mode of operation"] . ":"
	Gui, MyAbout: Add,		Text,	x0 y0 HwndIdAboutT4,									% TransA["default"]
	Gui, MyAbout: Add,		Text,	x0 y0 HwndIdAboutT5,									% TransA["Application mode"] . ":"
	Gui, MyAbout: Add,		Text,	x0 y0 HwndIdAboutT6,									ahk
	Gui, MyAbout: Add,		Text,	x0 y0 HwndIdAboutT7,									% TransA["AutoHotkey version"] . ":"
	Gui, MyAbout: Add,		Text,	x0 y0 HwndIdAboutT8,									% A_AhkVersion
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
		,v_OutVarTemp4 := 0, 	v_OutVarTemp4X := 0, 	v_OutVarTemp4Y := 0, 	v_OutVarTemp4W := 0, 	v_OutVarTemp4H := 0
							,v_xNext := 0, 		v_yNext := 0, 			v_wNext := 0, 			v_hNext := 0
		,HwndIdLongest := 0, 	IdLongest := 0, MaxText := 0
	
;4. Determine constraints, according to mock-up
	v_xNext := c_xmarg, v_yNext := c_ymarg
	GuiControl, Move, % IdLine1, % "x" . v_xNext . "y"  . v_yNext
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
			v_xNext := c_xmarg, v_yNext := c_ymarg + v_OutVarTempH + c_ymarg
			GuiControl, Move, % IdLongest, % "x" . v_xNext . "y" . v_yNext 
			GuiControl, Hide, % IdLongest
			Break
		}
	}
	GuiControlGet, v_OutVarTemp1, Pos, % IdAboutT1
	GuiControlGet, v_OutVarTemp2, Pos, % IdAboutT3
	GuiControlGet, v_OutVarTemp3, Pos, % IdAboutT5
	GuiControlGet, v_OutVarTemp4, Pos, % IdAboutT7
	MaxText := Max(v_OutVarTemp1W, v_OutVarTemp2W, v_OutVarTemp3W, v_OutVarTemp4W)
	GuiControlGet, v_OutVarTemp, Pos, % IdLine2
	v_xNext := c_xmarg, v_yNext := v_OutVarTempY + v_OutVarTempH + 2 * c_ymarg
	GuiControl, Move, % IdAboutT1, % "x" . v_xNext . A_Space . "y" . v_yNext
	v_xNext := MaxText + 3 * c_xmarg
	GuiControl, Move, % IdAboutT2, % "x" . v_xNext . A_Space . "y" . v_yNext
	v_xNext := c_xmarg, v_yNext += HofText
	GuiControl, Move, % IdAboutT3, % "x" . v_xNext . A_Space . "y" . v_yNext
	v_xNext := MaxText + 3 * c_xmarg
	if (v_Param = "l")
		GuiControl, , % IdAboutT4, % TransA["silent"]
	else
		GuiControl, , % IdAboutT4, % TransA["default"]
	GuiControl, Move, % IdAboutT4, % "x" . v_xNext . A_Space . "y" . v_yNext
	v_xNext := c_xmarg, v_yNext += HofText
	GuiControl, Move, % IdAboutT5, % "x" . v_xNext . A_Space . "y" . v_yNext
	v_xNext := MaxText + 3 * c_xmarg
	if (A_IsCompiled)
		GuiControl, , % IdAboutT6, exe
	else
		GuiControl, , % IdAboutT6, ahk
	GuiControl, Move, % IdAboutT6, % "x" . v_xNext . A_Space . "y" . v_yNext
	v_xNext := c_xmarg, v_yNext += HofText
	GuiControl, Move, % IdAboutT7, % "x" . v_xNext . A_Space . "y" . v_yNext
	v_xNext := MaxText + 3 * c_xmarg
	GuiControl, Move, % IdAboutT8, % "x" . v_xNext . A_Space . "y" . v_yNext
	
	GuiControlGet, v_OutVarTemp1, Pos, % IdLongest ; weight of the longest text
	GuiControlGet, v_OutVarTemp2, Pos, % IdAboutOkButton 
	v_wNext := v_OutVarTemp2W + 2 * c_xmarg
,	v_xNext := (v_OutVarTemp1W // 2) - (v_wNext // 2)
	GuiControlGet, v_OutVarTemp, Pos, % IdLine2
	v_yNext := v_OutVarTempY + v_OutVarTempH + 2 * c_ymarg + 4 * HofText
	GuiControl, Move, % IdAboutOkButton, % "x" . v_xNext . "y" . A_Space . v_yNext . "w" . v_wNext
	
	v_xNext := v_OutVarTemp1X + v_OutVarTemp1W - 96 ;96 = chosen size of icon
,	v_yNext := v_OutVarTemp1Y + v_OutVarTemp1H
	GuiControl, Move, % IdAboutPicture, % "x" . v_xNext . A_Space . "y" . v_yNext 
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
F_ValidateIniLibSections() ; Load from / to Config.ini from Libraries folder
{
	global ;assume-global mode of operation
	local 		v_IsLibraryEmpty 	:= true
			,	v_ConfigLibrary 	:= ""
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
	;v_IsLibraryEmpty := true
	if (!InStr(FileExist(ini_HADL), "D"))				; if  there is no "Libraries" subfolder 
	{
		FileCreateDir, % ini_HADL							; Future: check against errors
		MsgBox, 48, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["warning"], % TransA["There is no Libraries subfolder and no lbrary (*.csv) file exists!"] 
			. "`n`n" . ini_HADL . "`n`n" . TransA["folder is now created"] . "."
	}
	else 	;Check if Libraries subfolder is empty. If it does, display warning.
	{
		Loop, Files, % ini_HADL . "\*.csv"
		{
			v_IsLibraryEmpty := false
			break
		}
	}
	if (v_IsLibraryEmpty)
	{
		MsgBox, 52, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["warning"], % TransA["Libraries folder:"] . "`n`n" . ini_HADL . A_Space . "`n`n"
			. TransA["is empty. No (triggerstring, hotstring) definition will be loaded. Do you want to create the default library file: PriorityLibrary.csv?"]
		IfMsgBox, Yes
		{
			FileAppend, , % ini_HADL . "\" . "PriorityLibrary.csv", UTF-8
			F_ValidateIniLibSections()
		}
	}
	;if !(v_IsLibraryEmpty)
	else	;Read names library files (*.csv) from Library subfolder into object o_Libraries
		Loop, Files, % ini_HADL . "\*.csv"
			o_Libraries.Push(A_LoopFileName)
	
;Check if Config.ini contains in section [Libraries] file names which are actually in library subfolder. Synchronize [Libraries] section with content of subfolder.
;Parse the TempLoadLib.
	IniRead, TempLoadLib, % ini_HADConfig, LoadLibraries
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
	IniDelete, % ini_HADConfig, LoadLibraries
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
	IniDelete, % ini_HADConfig, ShowTipsLibraries
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
	
	IniWrite, % SectionTemp, % ini_HADConfig, ShowTipsLibraries
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_LoadLibrariesToTables()
{ 
	global	;assume-global mode
	local name := "", varSearch := "", tabSearch := ""

		a_Library 				:= []
	,	a_TriggerOptions 			:= []
	,	a_Triggerstring 			:= []
	,	a_OutputFunction 			:= []
	,	a_EnableDisable 			:= []
	,	a_Hotstring				:= []
	,	a_Comment 				:= []
	
	; Prepare TrayTip message taking into account value of command line parameter.
	if (v_Param == "l")
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
			name 	:= SubStr(A_LoopFileName, 1, -4)
,			tabSearch := StrSplit(varSearch, "‖")
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
	local Options := "", SendFun := "", EnDis := "", OnOff := "", TextInsert := "", Oflag := false, Triggerstring := "", LenStr := 0

	Loop, Parse, txt, ‖
	{
		Switch A_Index
		{
			Case 1:
				Options 	:= A_LoopField
,				Oflag 	:= false
				if (InStr(Options, "O", 0))
					Oflag := true
				else
					Oflag := false
			Case 2:
				Triggerstring := F_ConvertEscapeSequences(A_LoopField)
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
	
	if ((!Triggerstring) and (Options or SendFun or OnOff or TextInsert))
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
	if (OnOff = "")	;This is consequence of hard lesson: mismatch of "column name". This line hopefullly protects against this kind of event in the future.
		MsgBox, 16, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["Error"], % A_ThisFunc . "`n`n" . A_Space . TransA["Something went wrong with (triggerstring, hotstring) creation"] . ":" . "`n`n"
			. "Hotstring(:" . Options . ":" . Triggerstring . "," . "func(" . SendFun . ").bind(" . TextInsert . "," . A_Space . Oflag . ")," . A_Space . OnOff . ")" . "`n"
			. TransA["OnOff parameter is missing."]
			. "`n`n" . TransA["Library name:"] . A_Tab . nameoffile
	
	if (Triggerstring and (OnOff = "On"))
	{
		;OutputDebug, % "Hotstring(:" . Options . ":" . Triggerstring . "," . "func(" . SendFun . ").bind(" . TextInsert . "," . A_Space . Oflag . ")," . A_Space . OnOff . ")"
		Try
			Hotstring(":" . Options . ":" . Triggerstring, func(SendFun).bind(TextInsert, Oflag), OnOff)
		Catch
			MsgBox, 16, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["Error"], % A_ThisFunc . A_Space . TransA["Something went wrong with (triggerstring, hotstring) creation"] . ":" . "`n`n"
				. "Hotstring(:" . Options . ":" . Triggerstring . "," . "func(" . SendFun . ").bind(" . TextInsert . "," . A_Space . Oflag . ")," . A_Space . OnOff . ")"
				. "`n`n" . TransA["Library name:"] . A_Tab . nameoffile
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
F_HOF_SE(ReplacementString, Oflag)	;Hotstring Output Function _ SendEvent
{
	global	;assume-global mode of operation
	local	temp := 0
	Critical, On
	if (InStr(A_ThisHotkey, "?"))
		v_InputString := SubStr(A_ThisHotkey, InStr(A_ThisHotkey, ":", , 2) + 1)	;A_ThisHotkey: the most recently executed non-auto-replace hotstring (blank if none).
	F_DestroyTriggerstringTips(ini_TTCn)
	F_DeterminePartStrings(ReplacementString)
	ReplacementString := F_ReplaceAHKconstants(ReplacementString)
,	ReplacementString := F_FollowCaseConformity(ReplacementString)
,	ReplacementString := F_ConvertEscapeSequences(ReplacementString)
	F_SendIsOflag(ReplacementString, Oflag, "SendEvent")
	F_EventSigOrdHotstring()
	++v_LogCounter
	temp := F_DetermineGain2(v_InputString, ReplacementString)
	v_CntCumGain += temp
	if (ini_THLog)
		FileAppend, % A_Hour . ":" . A_Min . ":" . A_Sec . "|" . v_LogCounter . "|" . "SE" . "|" . v_InputString . "|" . v_EndChar . "|" . SubStr(v_Options, 2, -1) . "|" . ReplacementString . "|" . temp . "|" . v_CntCumGain . "|" . "`n", % v_LogFileName
	v_UndoTriggerstring := v_InputString
,	v_InputString 		:= ""
	Critical, Off
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_HOF_SP(ReplacementString, Oflag)	;Hotstring Output Function _ SendPlay
{
	global	;assume-global mode of operation
	local	temp := 0
	Critical, On
	if (InStr(A_ThisHotkey, "?"))
		v_InputString := SubStr(A_ThisHotkey, InStr(A_ThisHotkey, ":", , 2) + 1)	;A_ThisHotkey: the most recently executed non-auto-replace hotstring (blank if none).
	F_DestroyTriggerstringTips(ini_TTCn)
	F_DeterminePartStrings(ReplacementString)
	ReplacementString := F_ReplaceAHKconstants(ReplacementString)
,	ReplacementString := F_FollowCaseConformity(ReplacementString)
,	ReplacementString := F_ConvertEscapeSequences(ReplacementString)
	F_SendIsOflag(ReplacementString, Oflag, "SendPlay")
	F_EventSigOrdHotstring()
	++v_LogCounter
	temp := F_DetermineGain2(v_InputString, ReplacementString)
	v_CntCumGain += temp
	if (ini_THLog)
		FileAppend, % A_Hour . ":" . A_Min . ":" . A_Sec . "|" . v_LogCounter . "|" . "SP" . "|" . v_InputString . "|" . v_EndChar . "|" . SubStr(v_Options, 2, -1) . "|" . ReplacementString . "|" . temp . "|" . v_CntCumGain . "|" . "`n", % v_LogFileName
	v_UndoTriggerstring := v_InputString
,	v_InputString 		:= ""
	Critical, Off
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_HOF_SR(ReplacementString, Oflag)	;Hotstring Output Function _ SendRaw
{
	global	;assume-global mode of operation
	local	temp := 0
	Critical, On
	if (InStr(A_ThisHotkey, "?"))
		v_InputString := SubStr(A_ThisHotkey, InStr(A_ThisHotkey, ":", , 2) + 1)	;A_ThisHotkey: the most recently executed non-auto-replace hotstring (blank if none).
	F_DestroyTriggerstringTips(ini_TTCn)
	F_DeterminePartStrings(ReplacementString)
	ReplacementString := F_ReplaceAHKconstants(ReplacementString)
,	ReplacementString := F_FollowCaseConformity(ReplacementString)
,	ReplacementString := F_ConvertEscapeSequences(ReplacementString)
	F_SendIsOflag(ReplacementString, Oflag, "SendRaw")
	F_EventSigOrdHotstring()
	++v_LogCounter
	temp := F_DetermineGain2(v_InputString, ReplacementString)
	v_CntCumGain += temp
	if (ini_THLog)
		FileAppend, % A_Hour . ":" . A_Min . ":" . A_Sec . "|" . v_LogCounter . "|" . "SR" . "|" . v_InputString . "|" . v_EndChar . "|" . SubStr(v_Options, 2, -1) . "|" . ReplacementString . "|" . temp . "|" . v_CntCumGain . "|" . "`n", % v_LogFileName
	v_UndoTriggerstring := v_InputString
,	v_InputString 		:= ""
	Critical, Off
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_SendIsOflag(OutputString, Oflag, SendFunctionName)
{
	global	;assume-global mode of operation

	SetKeyDelay, -1, -1	;Delay = -1, PressDuration = -1, -1: no delay at all; this can be necessary if SendInput is reduced to SendEvent (in case low level input hook is active in another script)
	; OutputDebug, % "A_SendLevel:" . A_Tab . A_SendLevel . "`n"
	Switch SendFunctionName
	{
		Case "SendInput":
			; OutputDebug, % "SendInput:" . OutputString . "`n"
			if (Oflag = false)
			{
				SendInput, % OutputString . A_EndChar
				; OutputDebug, % "Finished SendInput" . "`n"
			}
			else
				SendInput, % OutputString
		Case "SendEvent":
			if (Oflag = false)
				SendEvent, % OutputString . A_EndChar
			else
				SendEvent, % OutputString
		Case "SendPlay":
			if (Oflag = false)
			{
				SendPlay, % OutputString . A_EndChar
				; OutputDebug, % "SendPlay:" . A_Space . OutputString . "`n"
			}
			else
				SendPlay, % OutputString
		Case "SendRaw":
			if (Oflag = false)
				SendRaw, % OutputString . A_EndChar
			else
				SendRaw, % OutputString 
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_HOF_SI(ReplacementString, Oflag)	;Function _ Hotstring Output Function _ SendInput
{
	global	;assume-global mode of operation
	local	temp := 0

	Critical, On
	; OutputDebug, % A_ThisFunc . "`n"
	if (InStr(A_ThisHotkey, "?"))
		v_InputString := SubStr(A_ThisHotkey, InStr(A_ThisHotkey, ":", , 2) + 1)	;A_ThisHotkey: the most recently executed non-auto-replace hotstring (blank if none).
	F_DestroyTriggerstringTips(ini_TTCn)
	F_DeterminePartStrings(ReplacementString)
	ReplacementString := F_ReplaceAHKconstants(ReplacementString)
,	ReplacementString := F_FollowCaseConformity(ReplacementString)
,	ReplacementString := F_ConvertEscapeSequences(ReplacementString)
 	F_SendIsOflag(ReplacementString, Oflag, "SendInput")
 	F_EventSigOrdHotstring()
	++v_LogCounter
	temp := F_DetermineGain2(v_InputString, ReplacementString)
	v_CntCumGain += temp
	if (ini_THLog)
		FileAppend, % A_Hour . ":" . A_Min . ":" . A_Sec . "|" . v_LogCounter . "|" . "SI" . "|" . v_InputString . "|" . v_EndChar . "|" . SubStr(v_Options, 2, -1) . "|" . ReplacementString . "|" . temp . "|" . v_CntCumGain . "|" . "`n", % v_LogFileName
	v_UndoTriggerstring := v_InputString
,	v_InputString 		:= ""
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
F_DeterminePartStrings(ReplacementString)
{
	global	;assume-global mode of operation
	local	ThisHotkey := A_ThisHotkey	;This value will change if the current thread is interrupted by another hotkey, so be sure to copy it into another variable immediately if you need the original value for later use in a subroutine.
	
	v_Options 	 := SubStr(ThisHotkey, 1, InStr(ThisHotkey, ":", false, 1, 2))
,	v_UndoHotstring := ReplacementString
	if (InStr(v_Options, "*"))
		v_EndChar  := SubStr(ThisHotkey, 0) ;extracts the last character; This form is important to run correctly F_Undo 
	else
		v_EndChar  := A_EndChar
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_FollowCaseConformity(ReplacementString)
{
	global	;assume-global mode
	local vFirstLetter1 := "", vFirstLetter2 := "", NewReplacementString := "", vRestOfLetters := "", fRestOfLettersCap := false, fFirstLetterCap := false
	
	if (!InStr(v_Options, "C"))
	{
		vFirstLetter1 		:= SubStr(v_InputString, 1, 1)	;it must be v_InputString, because A_ThisHotkey do not preserve letter size!
		vRestOfLetters 	:= SubStr(v_InputString, 2)		;it must be v_InputString, because A_ThisHotkey do not preserve letter size!
		if vFirstLetter1 is upper
			fFirstLetterCap 	:= true
		if (RegExMatch(v_InputString, "^[[:punct:][:digit:][:upper:][:space:]]*$"))
			fRestOfLettersCap 	:= true

		if (fFirstLetterCap and fRestOfLettersCap)
		{
			StringUpper, NewReplacementString, ReplacementString
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
	if (InStr(v_Options, "C") or InStr(v_Options, "C1"))
		return ReplacementString
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_ClipboardPaste(string, Oflag)
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
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_HOF_CLI(ReplacementString, Oflag)	;Function _ Hotstring Output Function _ Clipboard
{
	global	;assume-global mode
	local	temp := ""
	Critical, On
	if (InStr(A_ThisHotkey, "?"))
		v_InputString := SubStr(A_ThisHotkey, InStr(A_ThisHotkey, ":", , 2) + 1)	;A_ThisHotkey: the most recently executed non-auto-replace hotstring (blank if none).
	; OutputDebug, % A_ThisFunc . "`n"
	F_DestroyTriggerstringTips(ini_TTCn)
	F_DeterminePartStrings(ReplacementString)
	ReplacementString := F_ReplaceAHKconstants(ReplacementString)
,	ReplacementString := F_FollowCaseConformity(ReplacementString)
,	ReplacementString := F_ConvertEscapeSequences(ReplacementString)
	F_ClipboardPaste(ReplacementString, Oflag)
	F_EventSigOrdHotstring()
	++v_LogCounter
	temp := F_DetermineGain2(v_InputString, ReplacementString)
	v_CntCumGain += temp
	if (ini_THLog)
		FileAppend, % A_Hour . ":" . A_Min . ":" . A_Sec . "|" . v_LogCounter . "|" . "CLI" . "|" . v_InputString . "|" . v_EndChar . "|" . SubStr(v_Options, 2, -1) . "|" . ReplacementString . "|" . temp . "|" . v_CntCumGain . "|" . "`n", % v_LogFileName
	v_UndoTriggerstring := v_InputString
,	v_InputString 		:= ""
	Critical, Off
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_MouseMenu_MCLI() ;The subroutine may consult the following built-in variables: A_Gui, A_GuiControl, A_GuiEvent, and A_EventInfo.
{
	global	;assume-global mode
	local	OutputVarTemp := "", temp := 0, ChoicePos := 0
	if (A_PriorKey = "LButton")
	{
		GuiControlGet, OutputVarTemp, , % Id_LB_HMenuCli
		ChoicePos := SubStr(OutputVarTemp, 1, 1)
,		OutputVarTemp := SubStr(OutputVarTemp, 4)
		Gui, HMenuCli: Destroy
		v_UndoHotstring 	:= OutputVarTemp
,	     ReplacementString 	:= F_ReplaceAHKconstants(OutputVarTemp)
,	     ReplacementString 	:= F_FollowCaseConformity(ReplacementString)
,	     ReplacementString 	:= F_ConvertEscapeSequences(ReplacementString)
		F_ClipboardPaste(ReplacementString, Ovar)
		if (ini_MHSEn)
			SoundBeep, % ini_MHSF, % ini_MHSD
		++v_LogCounter
		if (InStr(A_ThisHotkey, "?"))
			v_InputString := SubStr(A_ThisHotkey, InStr(A_ThisHotkey, ":", , 2) + 1)	;A_ThisHotkey: the most recently executed non-auto-replace hotstring (blank if none).
		temp := F_DetermineGain2(v_InputString, ReplacementString)
		v_CntCumGain += temp
		if (ini_THLog)
			FileAppend, % A_Hour . ":" . A_Min . ":" . A_Sec . "|" . v_LogCounter . "|" . "MCLI" . "|" . v_InputString . "|" . v_EndChar . "|" . SubStr(v_Options, 2, -1) . "|" . OutputVarTemp . "|" . temp . "|" . v_CntCumGain . "|" . "`n", % v_LogFileName
		v_UndoTriggerstring 	:= v_InputString
,		v_InputString 			:= ""
,		v_InputH.VisibleText 	:= true
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_HOF_MCLI(TextOptions, Oflag)	;Function _ Hotstring Output Function _ Menu Clipboard
{
	global	;assume-global mode
	Critical, On
	local	MenuX	 := 0,	MenuY  	:= 0,	v_MouseX  := 0,	v_MouseY	:= 0,	a_MCLIMenuPos := []

	v_InputH.VisibleText := false
	F_DestroyTriggerstringTips(ini_TTCn)
	if (ini_MHSEn)		;Second beep will be produced on purpose by main loop
		SoundBeep, % ini_MHSF, % ini_MHSD
	v_MenuMax			 := 0
,	TextOptions 		 := F_ReplaceAHKconstants(TextOptions)
	Loop, Parse, TextOptions, ¦
		v_MenuMax := A_Index
	if (ini_TTCn != 4)
	{
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
		Gui, HMenuCli: Add, Listbox, % "x0 y0 w250 HwndId_LB_HMenuCli" . A_Space . "r" . v_MenuMax . A_Space . "g" . "F_MouseMenu_MCLI"
		Loop, Parse, TextOptions, ¦
			GuiControl,, % Id_LB_HMenuCli, % A_Index . ". " . A_LoopField . "|"
		
		a_MCLIMenuPos := F_WhereDisplayMenu(ini_MHMP)
		F_FlipMenu(HMenuCliHwnd, a_MCLIMenuPos[1], a_MCLIMenuPos[2], "HMenuCli")
		GuiControl, Choose, % Id_LB_HMenuCli, 1
	}
	else	;(ini_MHMP = 4)
	{
		PreviousWindowID := WinExist("A")
		Loop, Parse, TextOptions, ¦	;second parse of the same variable, this time in order to fill in the Listbox
			GuiControl,, % IdTT_C4_LB4, % A_Index . ". " . A_LoopField . "|"
		GuiControl, Choose, % IdTT_C4_LB4, 1
		WinActivate, % "ahk_id" TT_C4_Hwnd
		Gui, TT_C4: Flash	;future: flashing (blinking) in a loop until user do not take action
		WhichMenu := "CLI"	;this parameter is used within function F_MouseMenuCombined() to handle mouse event
	}
	Ovar := Oflag
	F_DeterminePartStrings(TextOptions)
	Critical, Off
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_MouseMenu_MSI() ; Handling of mouse events for F_HOF_MSI;The subroutine may consult the following built-in variables: A_Gui, A_GuiControl, A_GuiEvent, and A_EventInfo.
{	
	global	;assume-global mode of operation
	local	OutputVarControl := 0, OutputVarTemp := "", ReplacementString := "", ChoicePos := 0, temp := 0
	if (A_PriorKey = "LButton")
	{
		MouseGetPos, , , , OutputVarControl			;to store the name (ClassNN) of the control under the mouse cursor
		SendMessage, 0x0188, 0, 0, % OutputVarControl	;retrieve the position of the selected item
		ChoicePos := (ErrorLevel<<32>>32) + 1			;Convert UInt to Int to have -1 if there is no item selected and convert from 0-based to 1-based, i.e. so that the first item is known as 1, not 0.
		GuiControl, Choose, % OutputVarControl, % ChoicePos
		GuiControlGet, OutputVarTemp, , % OutputVarControl
		OutputVarTemp := SubStr(OutputVarTemp, 4)
		Gui, HMenuAHK: Destroy
		v_UndoHotstring 	:= OutputVarTemp
,		OutputVarTemp 		:= F_ReplaceAHKconstants(OutputVarTemp)
,		OutputVarTemp 		:= F_FollowCaseConformity(OutputVarTemp)
,		OutputVarTemp 		:= F_ConvertEscapeSequences(OutputVarTemp)          
		F_SendIsOflag(OutputVarTemp, Ovar, "SendInput")
		if (ini_MHSEn)
			SoundBeep, % ini_MHSF, % ini_MHSD
		++v_LogCounter
		if (InStr(A_ThisHotkey, "?"))
			v_InputString := SubStr(A_ThisHotkey, InStr(A_ThisHotkey, ":", , 2) + 1)	;A_ThisHotkey: the most recently executed non-auto-replace hotstring (blank if none).
		temp := F_DetermineGain2(v_InputString, OutputVarTemp)
		v_CntCumGain += temp
		if (ini_THLog)
			FileAppend, % A_Hour . ":" . A_Min . ":" . A_Sec . "|" . v_LogCounter . "|" . "MSI" . "|" . v_InputString . "|" . v_EndChar . "|" . SubStr(v_Options, 2, -1) . "|" . OutputVarTemp . "|" . temp . "|" . v_CntCumGain . "|" . "`n", % v_LogFileName
		v_UndoTriggerstring 	:= v_InputString
,		v_InputString 			:= ""
,		v_InputH.VisibleText 	:= true
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_HOF_MSI(TextOptions, Oflag)	;Function _ Hotsring Output Function - Menu SendInput; This function creates only on screen menu. Events are handled by F_HMenuSI_Keyboard and F_MouseMenu_MSI.
{
	global	;assume-global mode
	Critical, On
	local	MenuX	 := 0,	MenuY  	:= 0,	v_MouseX  := 0,	v_MouseY	:= 0,	a_MCSIMenuPos := [],	TriggerChar := "", UserInput := ""
	static 	IfUpF := false,	IfDownF := false, IsCursorPressed := false, IntCnt := 1, ShiftTabIsFound := false

	v_InputH.VisibleText 	:= false
,	v_MenuMax				:= 0	;global variable used in F_HMenuAHK
,	TextOptions 			:= F_ReplaceAHKconstants(TextOptions)
	F_DestroyTriggerstringTips(ini_TTCn)
	if (ini_MHSEn)		;Second beep will be produced on purpose by main loop 
		SoundBeep, % ini_MHSF, % ini_MHSD
	Loop, Parse, TextOptions, ¦	;determine amount of rows for Listbox
		v_MenuMax := A_Index
	
	if (ini_TTCn != 4)	;if not static window, draw small simple GUI
	{
		Gui, HMenuAHK: New, +AlwaysOnTop -Caption +ToolWindow +HwndHMenuAHKHwnd
		Gui, HMenuAHK: Margin, 0, 0
		if (ini_HMBgrCol = "custom")
			Gui, HMenuAHK: Color,, % ini_HMBgrColCus
		else
			Gui, HMenuAHK: Color,, % ini_HMBgrCol
		if (ini_HMTyFaceCol = "custom")	
			Gui, HMenuAHK: Font, % "s" . ini_HMTySize . A_Space . "c" . ini_HMTyFaceColCus, % ini_HMTyFaceFont
		else
			Gui, HMenuAHK: Font, % "s" . ini_HMTySize . A_Space . "c" . ini_HMTyFaceCol, % ini_HMTyFaceFont
		Gui, HMenuAHK: Add, Listbox, % "x0 y0 w250 HwndId_LB_HMenuAHK" . A_Space . "r" . v_MenuMax . A_Space . "g" . "F_MouseMenu_MSI"
		Loop, Parse, TextOptions, ¦	;second parse of the same variable, this time in order to fill in the Listbox
			GuiControl,, % Id_LB_HMenuAHK, % A_Index . ". " . A_LoopField . "|"
		
		a_MCSIMenuPos := F_WhereDisplayMenu(ini_MHMP)
		F_FlipMenu(HMenuAHKHwnd, a_MCSIMenuPos[1], a_MCSIMenuPos[2], "HMenuAHK")
		GuiControl, Choose, % Id_LB_HMenuAHK, 1
	}
	else	;(ini_MHMP = 4)
	{
		; OutputDebug, % "PreviousWindowID:" . A_Tab . PreviousWindowID . "`n"
		Loop, Parse, TextOptions, ¦	;second parse of the same variable, this time in order to fill in the Listbox
			GuiControl,, % IdTT_C4_LB4, % A_Index . ". " . A_LoopField . "|"
		GuiControl, Choose, % IdTT_C4_LB4, 1
		Gui, TT_C4: Flash	;future: flashing (blinking) in a loop until user do not take action
		WhichMenu := "SI"	;this setting will be used within F_MouseMenuCombined() to handle mouse event
	}
	Ovar := Oflag
	F_DeterminePartStrings(TextOptions)
	Critical, Off
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_TTMenuStatic_Mouse() ;The subroutine may consult the following built-in variables: A_Gui, A_GuiControl, A_GuiEvent, and A_EventInfo.
{
	global	;assume-global mode
	local	OutputVarTemp := "",	ThisHotkey := A_PriorKey
			, OutputVarTemp2 := "", ChoicePos := 0
	if (!ini_ATEn)
		return
	; OutputDebug, % "ThisHotkey:" . A_Tab . ThisHotkey . A_Tab . "v_InputString:" . A_Tab . v_InputString . "`n"
	MouseGetPos, , , , OutputVarTemp			;to store the name (ClassNN) of the control under the mouse cursor
	SendMessage, 0x0188, 0, 0, % OutputVarTemp	;retrieve the position of the selected item
	ChoicePos := (ErrorLevel<<32>>32) + 1		;Convert UInt to Int to have -1 if there is no item selected. Convert from 0-based to 1-based, i.e. so that the first item is known as 1, not 0.
	if (InStr(ThisHotkey, "LButton"))
	{
		Critical, On
		Switch ini_TTCn
		{
			Case 1: 
				GuiControlGet, OutputVarTemp, , % IdTT_C1_LB1
				Gui, TT_C1: Destroy
			Case 2: 
				GuiControlGet, OutputVarTemp, , % IdTT_C2_LB1 
				Gui, TT_C2: Destroy
			Case 3: 
				GuiControlGet, OutputVarTemp, , % IdTT_C3_LB1 
				Gui, TT_C3: Destroy
			Case 4:
				GuiControlGet, OutputVarTemp, , % IdTT_C4_LB1 
				WinActivate, % "ahk_id" PreviousWindowID
		}
		; OutputDebug, % "ini_TTCn:" . A_Tab . ini_TTCn . "`n"
		Hotstring("Reset")			;reset hotstring recognizer
		SendEvent, % "{BackSpace" . A_Space . StrLen(v_InputString) . "}"
		SendLevel, 2				;to backtrigger it must be higher than the input level of the hotstrings
		SendEvent, % OutputVarTemp	;If a script other than the one executing SendInput has a low-level keyboard hook installed, SendInput automatically reverts to SendEvent 
		SendLevel, 0
		v_InputString := ""
		Critical, Off
	}
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_MouseMenuCombined() ;Handling of mouse events for static menus window; Valid if static triggerstring / hotstring menus GUI is available. "Combined" because it chooses between "MSI" and "MCLI".
{
	global	;assume-global mode of operation
	local	OutputVarControl := 0, OutputVarTemp := "", ReplacementString := "", ChoicePos := 0, temp := 0
	if (A_PriorKey = "LButton")
	{
		MouseGetPos, , , , OutputVarControl			;to store the name (ClassNN) of the control under the mouse cursor
		SendMessage, 0x0188, 0, 0, % OutputVarControl	;retrieve the position of the selected item
		ChoicePos := (ErrorLevel<<32>>32) + 1			;Convert UInt to Int to have -1 if there is no item selected and convert from 0-based to 1-based, i.e. so that the first item is known as 1, not 0.
		GuiControl, Choose, % OutputVarControl, % ChoicePos
		GuiControlGet, OutputVarTemp, , % OutputVarControl
		OutputVarTemp := SubStr(OutputVarTemp, 4)
		GuiControl,, % IdTT_C4_LB4, |
		WinActivate, % "ahk_id" PreviousWindowID
		v_UndoHotstring 	:= OutputVarTemp
,		ReplacementString 	:= F_ReplaceAHKconstants(OutputVarTemp)
,		ReplacementString 	:= F_FollowCaseConformity(ReplacementString)
,		ReplacementString 	:= F_ConvertEscapeSequences(ReplacementString)
		Switch WhichMenu	;this parameter is set wihin F_HOF_MSI and F_HOF_MCLI
		{
			Case "SI":	F_SendIsOflag(ReplacementString, Ovar, "SendInput")
			Case "CLI":	F_ClipboardPaste(ReplacementString, Ovar)
		}
		if (ini_MHSEn)
			SoundBeep, % ini_MHSF, % ini_MHSD
		++v_LogCounter
		if (InStr(A_ThisHotkey, "?"))
			v_InputString := SubStr(A_ThisHotkey, InStr(A_ThisHotkey, ":", , 2) + 1)	;A_ThisHotkey: the most recently executed non-auto-replace hotstring (blank if none).
		temp := F_DetermineGain2(v_InputString, ReplacementString)
		v_CntCumGain += temp
		if (ini_THLog)
			FileAppend, % A_Hour . ":" . A_Min . ":" . A_Sec . "|" . v_LogCounter . "|" . "MSI" . "|" . v_InputString . "|" . v_EndChar . "|" . SubStr(v_Options, 2, -1) . "|" . OutputVarTemp . "|" . temp . "|" . v_CntCumGain . "|" . "`n", % v_LogFileName			
		v_UndoTriggerstring 	:= v_InputString
,		v_InputString 			:= ""
,		v_InputH.VisibleText 	:= true
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
{ ;Future: omit commented lines of a imported script
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
	v_OutputFile := % ini_HADL . "\" . OutNameNoExt . ".csv"
	
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
		F_Searching("Reload")
	}
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
	
	FileSelectFile, v_LibraryName, 3, % ini_HADL . "\", % TransA["Choose library file (.csv) for export"], CSV Files (*.csv)]
	if (!v_LibraryName)
		return
	
	SplitPath, v_LibraryName, OutFileName, , , OutNameNoExt
	v_LibrariesDir := % ini_HADL . "\ExportedLibraries"
	if !InStr(FileExist(v_LibrariesDir), "D")
		FileCreateDir, %v_LibrariesDir%
	v_OutputFile := % ini_HADL . "\ExportedLibraries\" . OutNameNoExt . "." . "ahk"
	
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
	FileSelectFile, v_LibraryName, 3, % ini_HADL, % TransA["Choose library file (.csv) for export"], CSV Files (*.csv)]
	if (!v_LibraryName)
		return
	
	SplitPath, v_LibraryName, OutFileName, , , OutNameNoExt
	v_LibrariesDir := % ini_HADL . "\ExportedLibraries"
	if !InStr(FileExist(v_LibrariesDir),"D")
		FileCreateDir, %v_LibrariesDir%
	v_OutputFile := % ini_HADL . "\ExportedLibraries\" . OutNameNoExt . "." . "ahk"
	
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
