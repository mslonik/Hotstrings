/* 
	Author:      Jakub Masiak, Maciej Słojewski (mslonik, http://mslonik.pl)
	Purpose:     Facilitate maintenance of (triggerstring, hotstring) concept.
	Description: Hotstrings as in AutoHotkey (shortcuts), but editable with GUI and many more options.
	License:     GNU GPL v.3
*/

; -----------Beginning of auto-execute section of the script -------------------------------------------------
; After the script has been loaded, it begins executing at the top line, continuing until a Return, Exit, hotkey/hotstring label, or the physical end of the script is encountered (whichever comes first). 

#Requires AutoHotkey v1.1.33+ 	; Displays an error and quits if a version requirement is not met.    
#SingleInstance force 			; Only one instance of this script may run at a time!
#NoEnv  						; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  						; Enable warnings to assist with detecting common errors.
SendMode Input  				; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%		; Ensures a consistent starting directory.
FileEncoding, UTF-16			; Sets the default encoding for FileRead, FileReadLine, Loop Read, FileAppend, and FileOpen(). Unicode UTF-16, little endian byte order (BMP of ISO 10646). Useful for .ini files which by default are coded as UTF-16. https://docs.microsoft.com/pl-pl/windows/win32/intl/code-page-identifiers?redirectedfrom=MSDN
; Warning! UTF-16 is not recognized by Notepad++ editor (2021), which recognizes correctly UCS-2 (defined by the International Standard ISO/IEC 10646). 
; BMP = Basic Multilingual Plane.

; - - - - - - - - - - - - - - - - - - - - - - - G L O B A L    V A R I A B L E S - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
global AppIcon					:= "hotstrings.ico" ; Imagemagick: convert image.png -alpha off -resize 256x256 \ -define icon:auto-resize="256,128,96,64,48,32,16" \ hotstrings.ico
;@Ahk2Exe-Let vAppIcon=%A_PriorLine~U)^(.+"){1}(.+)".*$~$2% ; Keep these lines together
;Overrides the custom EXE icon used for compilation
;@Ahk2Exe-SetMainIcon  %U_vAppIcon%
;@Ahk2Exe-SetCopyright GNU GPL 3.x
;@Ahk2Exe-SetDescription Advanced tool for hotstring management.
;@Ahk2Exe-SetProductName Original script name: %A_ScriptName%
;@Ahk2Exe-Set OriginalScriptlocation, https://github.com/mslonik/Hotstrings/tree/master/Hotstrings
;@Ahk2Exe-SetCompanyName  http://mslonik.pl
;@Ahk2Exe-SetFileVersion 4.0
global v_Param 				:= A_Args[1] ; the only one parameter of Hotstrings app available to user: l or d

global a_SelectedTriggers 		:= []		;Main loop of application
global a_Triggers 				:= []		;Main loop of application
global v_HotstringFlag 			:= false		;Main loop of application
global v_InputString 			:= ""		;Main loop of application
global v_MouseX 				:= 0			;Main loop of application
global v_MouseY 				:= 0			;Main loop of application
global v_Tips 					:= ""		;Main loop of application
global v_TipsFlag 				:= false		;Main loop of application

global ini_AmountOfCharacterTips 	:= 1			;1-5, default: 1
global ini_Caret 				:= false
global ini_Cursor 				:= true
global ini_Delay 				:= 300		;1-1000 [ms], default: 300
global ini_MenuCaret 			:= false
global ini_MenuCursor 			:= true
global ini_MenuSound 			:= true
global ini_Sandbox				:= true		
global ini_Tips 				:= true
global ini_TipsSortAlphabetically 	:= true
global ini_TipsSortByLength 		:= true
global ini_GuiReload			:= false
global ini_Language 			:= "English.txt"

global ini_SFrequency			:= 400		;Future. The frequency of the sound. It should be a number between 37 and 32767. If omitted, the frequency will be 523.
global ini_SDuration			:= 200		;Future. The duration of the sound, in milliseconds. If omitted, the duration will be 150.

global v_IndexLog 				:= 1			;for logging, if Hotstrings application is run with d parameter.

;global v_MenuMax 				:= 0			;important for hotstring menu; future: to be investigated
;global v_MenuMax2 				:= 0			;important for hotstring menu; future: to be investigated

;global v_TriggerString 			:= ""
global v_TypedTriggerstring 		:= ""		;used by output functions
global v_UndoHotstring 			:= ""		;used by output functions
global v_UndoTriggerstring 		:= ""		;used by output functions

;Flags to control application
global v_ResizingFlag 			:= true 		;when Hotstrings Gui is displayed for the very first time
global HMenuCliHwnd				:= 0
global HMenuAHKHwnd				:= 0

; - - - - - - - - - - - - - - - - - - - - - - - B E G I N N I N G    O F    I N I T I A L I Z A T I O N - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
Critical, On
F_LoadCreateTranslationTxt() ;default set of translations (English) is loaded at the very beginning in case if Config.ini doesn't exist yet, but some MsgBox have to be shown.
F_CheckCreateConfigIni() ;1. Try to load up configuration file. If those files do not exist, create them.

if ( !Instr(FileExist(A_ScriptDir . "\Languages"), "D"))				; if  there is no "Languages" subfolder 
{
	FileCreateDir, %A_ScriptDir%\Languages							; Future: check against errors
	MsgBox, 48, % SubStr(A_ScriptName, 1, -4) .  ":" . A_Space . TransA["warning"], % TransA["There was no Languages subfolder, so one now is created."] . A_Space . "`n" 
	. A_ScriptDir . "\Languages"
}

IniRead ini_Language, Config.ini, Configuration, Language				; Load from Config.ini file specific parameter: language into variable ini_Language, e.g. ini_Language = English.ini
if (!FileExist(A_ScriptDir . "\Languages\" . ini_Language))			; else if there is no ini_language .ini file, e.g. v_langugae == Polish.ini and there is no such file in Languages folder
{
	MsgBox, 48, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["warning"], % TransA["There is no"] . A_Space . ini_Language . A_Space . TransA["file in Languages subfolder!"]
	. "`n`n" . TransA["The default"] . A_Space . ini_Language . A_Space . TransA["file is now created in the following subfolder:"] . "`n"  A_ScriptDir . "\Languages\"
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

IniRead, ini_Undo, 						Config.ini, Configuration, UndoHotstring
IniRead, ini_Delay, 					Config.ini, Configuration, Delay
IniRead, ini_MenuSound,					Config.ini, Configuration, MenuSound
IniRead, ini_Tips, 						Config.ini, Configuration, Tips
IniRead, ini_Cursor, 					Config.ini, Configuration, Cursor
IniRead, ini_Caret, 					Config.ini, Configuration, Caret
IniRead, ini_AmountOfCharacterTips, 		Config.ini, Configuration, TipsChars
IniRead, ini_MenuCursor, 				Config.ini, Configuration, MenuCursor
IniRead, ini_MenuCaret, 					Config.ini, Configuration, MenuCaret
IniRead, ini_TipsSortAlphabetically,		Config.ini, Configuration, TipsSortAlphatebically
IniRead, ini_TipsSortByLength,			Config.ini, Configuration, TipsSortByLength

F_LoadEndChars() ; Read from Config.ini values of EndChars. Modifies the set of characters used as ending characters by the hotstring recognizer.
F_ValidateIniLibSections() 

;If application wasn't run with "l" parameter (standing for "light / lightweight"), prepare tray menu.
if !(v_Param == "l") 		;GUI window uses the tray icon that was in effect at the time the window was created, therefore this section have to be run before the first Gui, New command. 
{
	Menu, Tray, Icon,		% AppIcon 						;GUI window uses the tray icon that was in effect at the time the window was created. FlatIcon: https://www.flaticon.com/ Cloud Convert: https://www.cloudconvert.com/
	Menu, Tray, Add, 		% TransA["Edit Hotstrings"], 			L_GUIInit
	Menu, Tray, Default, 	% TransA["Edit Hotstrings"]
	Menu, Tray, Add,		% TransA["Application help"],			GuiAboutLink1
	Menu, Tray, Add,		% TransA["Genuine hotstrings AutoHotkey documentation"], GuiAboutLink2
	Menu, Tray, Add										; separator line
	Menu, Tray, NoStandard									; remove all the rest of standard tray menu
	Menu, Tray, Add,		% TransA["Reload"],					L_TrayReload
	Menu, Tray, Add,		% TransA["Suspend Hotkeys"],			L_TraySuspendHotkeys
	Menu, Tray, Add,		% TransA["Pause Script"],			L_TrayPauseScript
	Menu, Tray, Add,		% TransA["Exit"],					L_TrayExit
}

F_GuiMain_CreateObject()
F_GuiMain_DefineConstants()
F_GuiMain_DetermineConstraints()
F_GuiMain_Redraw()

F_GuiHS4_CreateObject()
F_GuiHS4_DetermineConstraints()
F_GuiHS4_Redraw()

F_UpdateSelHotLibDDL()

; 4. Load definitions of (triggerstring, hotstring) from Library subfolder.
Gui, 1: Default	;this line is necessary to not show too many Guis on time of loading hotstrings from library
v_LibHotstringCnt := 0	;dirty trick to show initially 0 instead of 0000
GuiControl, , % IdText13,  % v_LibHotstringCnt
GuiControl, , % IdText13b, % v_LibHotstringCnt
F_LoadHotstringsFromLibraries()
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

; Multi monitor environment, initialization of monitor width and height parameters
/*
	SysGet, N, MonitorCount
	Loop, % N
	{
		SysGet, Mon%A_Index%, Monitor, %A_Index%
		W%A_Index% := Mon%A_Index%Right - Mon%A_Index%Left
		H%A_Index% := Mon%A_Index%Bottom - Mon%A_Index%Top
			;DPI%A_Index% := round(W%A_Index%/1920*(96/A_ScreenDPI), 2) ; original
		DPI%A_Index% := 1			; added on 2021-01-31 in order to clean up GUI sizing
	}
	SysGet, PrimMon, MonitorPrimary
	if (v_SelectedMonitor == 0)
		v_SelectedMonitor := PrimMon
*/

Menu, ConfTHB, 	Add, % TransA["Undo the last hotstring"],	L_Undo
Menu, SubmenuTips, 	Add, % TransA["Enable/Disable"], 			Tips
Menu, PositionMenu, Add, % TransA["Caret"], 					L_MenuCaretCursor
Menu, PositionMenu, Add, % TransA["Cursor"], 				L_MenuCaretCursor
Menu, SubmenuMenu, 	Add, % TransA["Choose menu position"],		:PositionMenu
Menu, SubmenuMenu, 	Add, % TransA["Enable sound if overrun"],	L_MenuSound
if (ini_MenuSound)
	Menu, SubmenuMenu, Check, % TransA["Enable sound if overrun"]
else
	Menu, SubmenuMenu, UnCheck, % TransA["Enable sound if overrun"]
Menu, ConfTHB, 	Add, % TransA["Hotstring menu (MSI, MCL)"], :SubmenuMenu
if (ini_MenuCursor)
	Menu, PositionMenu, Check, % TransA["Cursor"]
else
	Menu, PositionMenu, UnCheck, % TransA["Cursor"]
if (ini_MenuCaret)
	Menu, PositionMenu, Check, % TransA["Caret"]
else
	Menu, PositionMenu, UnCheck, % TransA["Caret"]
Menu, ConfTHB, 	Add, % TransA["Triggerstring tips"], 	:SubmenuTips
Menu, Submenu3, 	Add, % TransA["Caret"],		L_CaretCursor
Menu, Submenu3, 	Add, % TransA["Cursor"],			L_CaretCursor
if (ini_Cursor)
	Menu, Submenu3, Check, % TransA["Cursor"]
else
	Menu, Submenu3, UnCheck, % TransA["Cursor"]
if (ini_Caret)
	Menu, Submenu3, Check, % TransA["Caret"]
else
	Menu, Submenu3, UnCheck, % TransA["Caret"]
Menu, SubmenuTips, 	Add, % TransA["Choose tips location"], 	:Submenu3
If !(ini_Tips)
{
	Menu, SubmenuTips, Disable, % TransA["Choose tips location"]
}
Menu, Submenu4, 	Add, 1, 					L_AmountOfCharacterTips1
Menu, Submenu4, 	Add, 2, 					L_AmountOfCharacterTips2
Menu, Submenu4, 	Add, 3, 					L_AmountOfCharacterTips3
Menu, Submenu4, 	Add, 4, 					L_AmountOfCharacterTips4
Menu, Submenu4, 	Add, 5, 					L_AmountOfCharacterTips5
Menu, Submenu4, 	Check, 					% ini_AmountOfCharacterTips
Loop, 5
{
	if !(A_Index == ini_AmountOfCharacterTips)
		Menu, Submenu4, UnCheck, %A_Index%
}
Menu, SubmenuTips, 	Add, % TransA["Number of characters for tips"], :Submenu4
If !(ini_Tips)
{
	Menu, SubmenuTips, Disable, % TransA["Number of characters for tips"]
}
Menu, SubmenuTips, Add, % TransA["Sort tips alphabetically"], L_SortTipsAlphabetically
if (ini_TipsSortAlphabetically)
	Menu, SubmenuTips, Check, % TransA["Sort tips alphabetically"]
else
	Menu, SubmenuTips, UnCheck, % TransA["Sort tips alphabetically"]
Menu, SubmenuTips, Add, % TransA["Sort tips by length"], L_SortTipsByLength
if (ini_TipsSortByLength)
	Menu, SubmenuTips, Check, % TransA["Sort tips by length"]
else
	Menu, SubmenuTips, UnCheck, % TransA["Sort tips by length"]

Menu, Submenu2, Add, % TransA["Space"], 				EndSpace
if (EndingChar_Space)
	Menu, Submenu2, Check, % TransA["Space"]
else
	Menu, Submenu2, UnCheck, % TransA["Space"]

Menu, Submenu2, Add, % TransA["Minus -"], EndMinus
if (EndingChar_Minus)
	Menu, Submenu2, Check, % TransA["Minus -"]
else
	Menu, Submenu2, UnCheck, % TransA["Minus -"]

Menu, Submenu2, Add, % TransA["Opening Round Bracket ("], EndORoundBracket
if (EndingChar_ORoundBracket)
	Menu, Submenu2, Check, % TransA["Opening Round Bracket ("]
else
	Menu, Submenu2, UnCheck, % TransA["Opening Round Bracket ("]

Menu, Submenu2, Add, % TransA["Closing Round Bracket )"], EndCRoundBracket
if (EndingChar_CRoundBracket)
	Menu, Submenu2, Check, % TransA["Closing Round Bracket )"]
else
	Menu, Submenu2, UnCheck, % TransA["Closing Round Bracket )"]

Menu, Submenu2, Add, % TransA["Opening Square Bracket ["], EndOSquareBracket
if (EndingChar_OSquareBracket)
	Menu, Submenu2, Check, % TransA["Opening Square Bracket ["]
else
	Menu, Submenu2, UnCheck, % TransA["Opening Square Bracket ["]

Menu, Submenu2, Add, % TransA["Closing Square Bracket ]"], EndCSquareBracket
if (EndingChar_CSquareBracket)
	Menu, Submenu2, Check, % TransA["Closing Square Bracket ]"]
else
	Menu, Submenu2, UnCheck, % TransA["Closing Square Bracket ]"]

Menu, Submenu2, Add, % TransA["Opening Curly Bracket {"], EndOCurlyBracket
if (EndingChar_OCurlyBracket)
	Menu, Submenu2, Check, % TransA["Opening Curly Bracket {"]
else
	Menu, Submenu2, UnCheck, % TransA["Opening Curly Bracket {"]

Menu, Submenu2, Add, % TransA["Closing Curly Bracket }"], EndCCurlyBracket
if (EndingChar_CCurlyBracket)
	Menu, Submenu2, Check, % TransA["Closing Curly Bracket }"]
else
	Menu, Submenu2, UnCheck, % TransA["Closing Curly Bracket }"]

Menu, Submenu2, Add, % TransA["Colon :"], EndColon
if (EndingChar_Colon)
	Menu, Submenu2, Check, % TransA["Colon :"]
else
	Menu, Submenu2, UnCheck, % TransA["Colon :"]

Menu, Submenu2, Add, % TransA["Semicolon `;"], EndSemicolon
if (EndingChar_Semicolon)
	Menu, Submenu2, Check, % TransA["Semicolon `;"]
else
	Menu, Submenu2, UnCheck, % TransA["Semicolon `;"]

Menu, Submenu2, Add, % TransA["Apostrophe '"], EndApostrophe
if (EndingChar_Apostrophe)
	Menu, Submenu2, Check, % TransA["Apostrophe '"]
else
	Menu, Submenu2, UnCheck, % TransA["Apostrophe '"]

Menu, Submenu2, Add, % TransA["Quote """], EndQuote
if (EndingChar_Quote)
	Menu, Submenu2, Check, % TransA["Quote """]
else
	Menu, Submenu2, UnCheck, % TransA["Quote """]

Menu, Submenu2, Add, % TransA["Slash /"], EndSlash
if (EndingChar_Slash)
	Menu, Submenu2, Check, % TransA["Slash /"]
else
	Menu, Submenu2, UnCheck, % TransA["Slash /"]

Menu, Submenu2, Add, % TransA["Backslash \"], EndBackslash
if (EndingChar_Backslash)
	Menu, Submenu2, Check, % TransA["Backslash \"]
else
	Menu, Submenu2, UnCheck, % TransA["Backslash \"]

Menu, Submenu2, Add, % TransA["Comma ,"], EndComma
if (EndingChar_Comma)
	Menu, Submenu2, Check, % TransA["Comma ,"]
else
	Menu, Submenu2, UnCheck, % TransA["Comma ,"]

Menu, Submenu2, Add, % TransA["Dot ."], EndDot
if (EndingChar_Dot)
	Menu, Submenu2, Check, % TransA["Dot ."]
else
	Menu, Submenu2, UnCheck, % TransA["Dot ."]

Menu, Submenu2, Add, % TransA["Question Mark ?"], EndQuestionMark
if (EndingChar_QuestionMark)
	Menu, Submenu2, Check, % TransA["Question Mark ?"]
else
	Menu, Submenu2, UnCheck, % TransA["Question Mark ?"]

Menu, Submenu2, Add, % TransA["Exclamation Mark !"], EndExclamationMark
if (EndingChar_ExclamationMark)
	Menu, Submenu2, Check, % TransA["Exclamation Mark !"]
else
	Menu, Submenu2, UnCheck, % TransA["Exclamation Mark !"]

Menu, Submenu2, Add, % TransA["Underscore _"], EndUnderscore
if (EndingChar_Underscore)
	Menu, Submenu2, Check, % TransA["Underscore _"]
else
	Menu, Submenu2, UnCheck, % TransA["Underscore _"]

Menu, Submenu2, Add, % TransA["Enter"], EndEnter
if (EndingChar_Enter)
	Menu, Submenu2, Check, % TransA["Enter"]
else
	Menu, Submenu2, UnCheck, % TransA["Enter"]

Menu, Submenu2, Add, % TransA["Tab"], EndTab
if (EndingChar_Tab)
	Menu, Submenu2, Check, % TransA["Tab"]
else
	Menu, Submenu2, UnCheck, % TransA["Tab"]

Menu, ConfTHB, Add, % TransA["Toggle EndChars"], :Submenu2

if (ini_Tips == 0)
	Menu, SubmenuTips, UnCheck, % TransA["Enable/Disable"]
else
	Menu, SubmenuTips, Check, % TransA["Enable/Disable"]

if (ini_Undo == 0)
	Menu, ConfTHB, UnCheck, % TransA["Undo the last hotstring"]
else
	Menu, ConfTHB, Check, % TransA["Undo the last hotstring"]

Loop, %A_ScriptDir%\Languages\*.txt 
{
	Menu, SubmenuLanguage, Add, %A_LoopFileName%, L_ChangeLanguage
	if (ini_Language == A_LoopFileName)
		Menu, SubmenuLanguage, Check, %A_LoopFileName%
	else
		Menu, SubmenuLanguage, UnCheck, %A_LoopFileName%
}
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
Menu, ConfGUI,		Add, % TransA["Change Language"], 					:SubmenuLanguage
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
Menu, ConfGUI,		Add, Style of GUI,								:StyleGUIsubm

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

Menu, Submenu1,		Add, % TransA["Triggerstring / hotstring behaviour"], :ConfTHB
Menu, Submenu1,		Add, % TransA["Graphical User Interface"], 		:ConfGUI

Menu, HSMenu, 			Add, % TransA["Configuration"], 				:Submenu1
Menu, HSMenu, 			Add, % TransA["Search Hotstrings (F3)"], 		F_Searching

Menu, LibrariesSubmenu,	Add, % TransA["Enable/disable libraries"], 		F_RefreshListOfLibraries
F_RefreshListOfLibraries()
Menu, LibrariesSubmenu, 	Add, % TransA["Enable/disable triggerstring tips"], 	F_RefreshListOfLibraryTips
F_RefreshListOfLibraryTips()
Menu, LibrariesSubmenu,	Add	;To add a menu separator line, omit all three parameters.
Menu, LibrariesSubmenu,	Add, % TransA["Public libraries"],				L_PublicLibraries
Menu, LibrariesSubmenu,	Add	;To add a menu separator line, omit all three parameters.
Menu, LibrariesSubmenu, 	Add, % TransA["Import from .ahk to .csv"],		F_ImportLibrary
Menu, ExportSubmenu, 	Add, % TransA["Static hotstrings"],  			F_ExportLibraryStatic
Menu, ExportSubmenu, 	Add, % TransA["Dynamic hotstrings"],  			F_ExportLibraryDynamic
Menu, LibrariesSubmenu, 	Add, % TransA["Export from .csv to .ahk"],		:ExportSubmenu

Menu, 	HSMenu, 			Add, % TransA["Libraries"], 				:LibrariesSubmenu
Menu, 	HSMenu, 			Add, % TransA["Clipboard Delay (F7)"], 		F_GuiHSdelay
Menu,	ApplicationSubmenu,	Add, % TransA["Reload"],					F_Reload
Menu,	ApplicationSubmenu,	Add, % TransA["Exit"],					F_Exit
Menu,	ApplicationSubmenu, Add, % TransA["Remove Config.ini"],		F_RemoveConfigIni

F_CompileSubmenu()

if (!A_AhkPath) ;if AutoHotkey isn't installed
	Menu,	ApplicationSubmenu, Disable,							% TransA["Compile"]
Menu, 	HSMenu,			Add, % TransA["Application"],				:ApplicationSubmenu
Menu, 	HSMenu, 			Add, % TransA["About/Help (F1)"], 			F_GuiAbout
Gui, 	HS3: Menu, HSMenu
Gui, 	HS4: Menu, HSMenu

F_GuiAbout_CreateObjects()
F_GuiAbout_DetermineConstraints()

IniRead, ini_GuiReload, 						Config.ini, GraphicalUserInterface, GuiReload
if (ini_GuiReload)
	Gosub, L_GUIInit

;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; Beginning of the main loop of application.
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Loop,
{
	Input, out, V L1, {Esc} ; V = Visible, L1 = Length 1
	if (ErrorLevel = "NewInput")
		MsgBox, 16, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["Error"], % TransA["ErrorLevel was triggered by NewInput error."]
	
	; if exist window with hotstring tips, output sound
	if (WinExist("ahk_id" HMenuCliHwnd) or WinExist("HotstringAHK listbox"))
	{
		if (ini_MenuSound)
			SoundBeep, % ini_SFrequency, % ini_SDuration	;Future: configurable parameters of the sound
	}
	else
	{
		v_InputString .= out
		if (v_HotstringFlag)
		{
			v_InputString := ""
			ToolTip,
			if !(WinExist("ahk_id" HMenuCliHwnd) or WinExist("HotstringAHK listbox"))
				v_HotstringFlag := 0
		}
		if (InStr(HotstringEndChars, out))
		{
			v_TipsFlag := 0
			Loop, % a_Triggers.MaxIndex()
			{
				if (InStr(a_Triggers[A_Index], v_InputString) = 1) ;if in string a_Triggers is found v_InputString from the first position 
				{
					v_TipsFlag := 1
				}
			}
			if !(v_TipsFlag)
				v_InputString := ""
		}		  
		if (StrLen(v_InputString) > ini_AmountOfCharacterTips - 1 ) and (ini_Tips)
		{
			v_Tips := ""
			Loop, % a_Triggers.MaxIndex()
			{
				if (InStr(a_Triggers[A_Index], v_InputString) = 1) ;if in string a_Triggers is found v_InputString from the first position 
				{
					if !(v_Tips == "")
						v_Tips .= "`n"
					v_Tips .= a_Triggers[A_Index]
				}
			}
			If (v_Tips == "") and InStr(HotstringEndChars, SubStr(v_InputString, -1, 1))
			{
				v_InputString := out
				Loop, % a_Triggers.MaxIndex()
				{
					If (InStr(a_Triggers[A_Index], v_InputString) == 1)
					{
						If !(v_Tips == "")
							v_Tips .= "`n"
						v_Tips .= a_Triggers[A_Index]
					}
				}
			}
			a_SelectedTriggers := []
			a_SelectedTriggers := StrSplit(v_Tips, "`n")
			if (ini_TipsSortAlphabetically)
				;a_SelectedTriggers := F_SortArrayAlphabetically(a_SelectedTriggers)
				Sort, a_SelectedTriggers
			if (ini_TipsSortByLength)
				a_SelectedTriggers := F_SortArrayByLength(a_SelectedTriggers)
			v_Tips := ""
			Loop, % a_SelectedTriggers.MaxIndex()
			{
				If !(v_Tips == "")
					v_Tips .= "`n"
				v_Tips .= a_SelectedTriggers[A_Index]
			}
			if (ini_Caret)
			{
				;CoordMode, Caret, Screen
				CoordMode, Caret, Client
				ToolTip, %v_Tips%, A_CaretX + 20, A_CaretY - 20
			}
			if (ini_Cursor)
			{
				;CoordMode, Mouse, Screen
				;CoordMode, Mouse
				CoordMode, Mouse, Client
				MouseGetPos, v_MouseX, v_MouseY
				ToolTip, %v_Tips%, v_MouseX + 20, v_MouseY - 20
			}
		}
		else
			ToolTip, 
		
		if (v_Param == "d")
		{
			FileAppend, % v_IndexLog . "|" . v_InputString . "|" . ini_AmountOfCharacterTips . "|" . ini_Tips . "|" . v_Tips . "`n- - - - - - - - - - - - - - - - - - - - - - - - - -`n", %v_LogFileName%
			v_IndexLog++
		}
	}
}
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; The end of the main loop of application.
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -



; -------------------------- SECTION OF HOTKEYS ---------------------------

~BackSpace:: 
if (WinExist("ahk_id" HMenuCliHwnd) or WinExist("HotstringAHK listbox"))
{
	if (ini_MenuSound)
		SoundBeep, % ini_SFrequency, % ini_SDuration
}
else
{
	StringTrimRight, v_InputString, v_InputString, 1
	if (StrLen(v_InputString) > ini_AmountOfCharacterTips - 1) and (ini_Tips)
	{
		v_Tips := ""
		Loop, % a_Triggers.MaxIndex()
		{
			If InStr(a_Triggers[A_Index], v_InputString) == 1
			{
				If !(v_Tips == "")
					v_Tips .= "`n"
				v_Tips .= a_Triggers[A_Index]
			}
		}
		a_SelectedTriggers := []
		a_SelectedTriggers := StrSplit(v_Tips, "`n")
		if (ini_TipsSortAlphabetically)
			;a_SelectedTriggers := F_SortArrayAlphabetically(a_SelectedTriggers)
			Sort, a_SelectedTriggers
		if (ini_TipsSortByLength)
			a_SelectedTriggers := F_SortArrayByLength(a_SelectedTriggers)
		v_Tips := ""
		Loop, % a_SelectedTriggers.MaxIndex()
		{
			If !(v_Tips == "")
				v_Tips .= "`n"
			v_Tips .= a_SelectedTriggers[A_Index]
		}
		if (ini_Caret)
		{
				;CoordMode, Caret, Screen
			CoordMode, Caret, Client
			ToolTip, %v_Tips%, A_CaretX + 20, A_CaretY - 20
		}
		if (ini_Cursor)
		{
				;CoordMode, Mouse, Screen
			CoordMode, Mouse, Client
			MouseGetPos, v_MouseX, v_MouseY
			ToolTip, %v_Tips%, v_MouseX + 20, v_MouseY - 20
		}
	}
	else
	{
		ToolTip,
	}
	if (v_Param == "d")
	{
		FileAppend, % v_IndexLog . "|" . v_InputString . "|" . ini_AmountOfCharacterTips . "|" . ini_Tips . "|" . v_Tips . "`n- - - - - - - - - - - - - - - - - - - - - - - - - -`n", %v_LogFileName%
		v_IndexLog++
	}
}
return

$^z::			;~ Ctrl + z as in MS Word: Undo; $ prevents autotriggering as the same hotkey is send with SendInput function
$!BackSpace:: 		;~ Alt + Backspace as in MS Word: rolls back last Autocorrect action ; $ prevents autotriggering as the same hotkey is send with SendInput function
if (ini_Undo == 1) and (v_TypedTriggerstring && (A_ThisHotkey != A_PriorHotkey))
{
	ToolTip, % TransA["Undo the last hotstring"], % A_CaretX, % A_CaretY - 20
	TriggerOpt := SubStr(v_UndoTriggerstring, InStr(v_UndoTriggerstring, ":" ,, 1,1)+1 ,InStr(v_UndoTriggerstring, ":" ,, 1,2)-InStr(v_UndoTriggerstring, ":" ,, 1,1)-1)
	if (InStr(TriggerOpt, "*0") or !(InStr(TriggerOpt, "*"))) and (InStr(TriggerOpt, "O0") or !(InStr(TriggerOpt, "O")))
	{
		Send, {BackSpace}
	}
	if (v_UndoHotstring == "")
		Send, % "{BackSpace " . StrLen(v_TypedTriggerstring) . "}" . SubStr(A_PriorHotkey, InStr(A_PriorHotkey, ":", v_OptionCaseSensitive := false, StartingPos := 1, 2) + 1)
	else
		Send, % "{BackSpace " . StrLen(v_UndoHotstring) . "}" . SubStr(v_UndoTriggerstring, InStr(v_UndoTriggerstring, ":", v_OptionCaseSensitive := false, StartingPos := 1, 2) + 1)
	if (InStr(TriggerOpt, "*0") or !(InStr(TriggerOpt, "*")))  and (InStr(TriggerOpt, "O0") or !(InStr(TriggerOpt, "O")))
	{
		Send, %A_EndChar%
	}
	SetTimer, TurnOffTooltip, -5000, -1 ; Priorytet -1 sprawia, że nie będzie on psuł działanie innego timera
	v_TypedTriggerstring := ""
}
else
{
	ToolTip,
	If InStr(A_ThisHotkey, "^z")
		SendInput, ^z
	else if InStr(A_ThisHotkey, "!BackSpace")
		SendInput, !{BackSpace}
}
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

#if WinExist("ahk_id" HS3GuiHwnd) and WinExist("ahk_id" HS4GuiHwnd) ; the following hotkeys will be active only if Hotstrings windows exist at the moment.

~^c::			; copy to edit field "Enter hotstring" content of Clipboard.
Sleep, %ini_Delay%
ControlSetText, Edit2, %Clipboard%
return
#if

#if WinActive("ahk_id" HS3GuiHwnd) or WinActive("ahk_id" HS4GuiHwnd) ; the following hotkeys will be active only if Hotstrings windows are active at the moment. 

F1::	;new thread starts here
	F_WhichGui()
	F_GuiAbout()
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
	F_Searching()
return

F4::	;new thread starts here
	F_WhichGui()
	F_ToggleRightColumn()
return

F5::	;new thread starts here
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
	F_SetHotstring()
return

#if

~Alt::
;It's important to comment-out the following 3x lines (mouse buttons) in case of debugging the main loop of application.
/*
	~MButton::
	~RButton::
	~LButton::
*/
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
v_InputString := ""
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
	;OutputDebug, % "Beginning" . ":" . A_Space . A_ThisHotkey
	if (InStr(v_PressedKey, "Up"))
	{
		IsCursorPressed := true
		IntCnt--
		;OutputDebug, % "Up" . ":" . A_Space IntCnt
		ControlSend, , {Up}, % "ahk_id" HMenuCliHwnd
	}
	if (InStr(v_PressedKey, "Down"))
	{
		IsCursorPressed := true
		IntCnt++
		;OutputDebug, % "Down" . ":" . A_Space IntCnt
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
			SoundBeep, % ini_SFrequency, % ini_SDuration	;Future: configurable parameters of the sound
		}
		if (IntCnt < 1)
		{
			IntCnt := 1
			SoundBeep, % ini_SFrequency, % ini_SDuration	;Future: configurable parameters of the sound
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
	Sleep, %ini_Delay% ;Remember to sleep before restoring clipboard or it will fail
	v_TypedTriggerstring := v_Temp1
	v_UndoHotstring 	 := v_Temp1
	Clipboard 		 := ClipboardBack
	Hotstring("Reset")
	Gui, HMenuCli: Destroy
	return
}

Esc::
	Gui, HMenuCli: Destroy
	Send, % v_TriggerString
return
#If

; ------------------------- SECTION OF FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------------------

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
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

F_SetHotstring()
;1. Read all inputs. 
;2. Create Hotstring definition according to inputs. 
;3. Read the library file into List View. 
;4. Sort List View. 
;5. Delete library file. 
;6. Save List View into the library file.
;7. Increment library counter.
{
	global ;assume-global mode
	local 	TextInsert := "", OldOptions := "", Options := "", SendFun := "", OnOff := "", EnDis := "", OutputFile := "", InputFile := "", LString := "", ModifiedFlag := false
			,txt := "", txt1 := "", txt2 := "", txt3 := "", txt4 := "", txt5 := "", txt6 := ""
			,v_TheWholeFile := "", v_TotalLines := 0
	
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
	
	/*
	; Added this conditional to prevent Hotstrings from a file losing the C1 option caused by
	; cascading ternary operators when creating the options string. CapCheck set to 1 when 
	; a Hotstring from a file contains the C1 option.
		
		If (v_CaseSensitiveC1 = 1) and ((OldOptions = "") or (InStr(OldOptions,"C1"))) and (Instr(a_String[2],"C1"))
			OldOptions := StrReplace(OldOptions,"C1") . "C"
		v_CaseSensitiveC1 := 0
	*/
	
	Options := v_OptionCaseSensitive = 1 ? Options . "C"
		: (Instr(OldOptions,"C1")) ?  Options . "C0"
		: (Instr(OldOptions,"C0")) ?  Options
		: (Instr(OldOptions,"C")) ? Options . "C1" : Options
	
	Options := v_OptionNoBackspace = 1 ?  Options . "B0" 
		: (v_OptionNoBackspace = 0) and (Instr(OldOptions,"B0")) ? Options . "B" : Options
	
	Options := (v_OptionImmediateExecute = 1) ?  Options . "*" 
		: (Instr(OldOptions,"*0")) ?  Options
		: (Instr(OldOptions,"*")) ? Options . "*0" : Options
	
	Options := v_OptionInsideWord = 1 ?  Options . "?" : Options
	
	Options := (v_OptionNoEndChar = 1) ?  Options . "O"
		: (Instr(OldOptions,"O0")) ?  Options
		: (Instr(OldOptions,"O")) ? Options . "O0" : Options
	
; Add new/changed target item in DropDownList
	Switch v_SelectFunction
	{
		Case "Clipboard (CL)": 			SendFun := "F_ViaClipboard"
		Case "SendInput (SI)": 			SendFun := "F_NormalWay"
		Case "Menu & Clipboard (MCL)": 	SendFun := "F_MenuCli"
		Case "Menu & SendInput (MSI)": 	SendFun := "F_MenuAHK"
	}
	
	if (v_OptionDisable == 1)
		OnOff := "Off"
	else
		OnOff := "On"
	
	;2. Create Hotstring definition according to inputs. 
	if (InStr(Options,"O", 0))
	{
		Try
			Hotstring(":" . Options . ":" . v_TriggerString, func(SendFun).bind(TextInsert, true), OnOff)
		Catch
			MsgBox, 16, % SubStr(A_ScriptName, 1, -4) . A_Space . TransA["Error"], % A_ThisFunc . A_Space . TransA["Something went wrong with hotstring deletion:"] . "`n`n"
				. "Hotstring(:" . Options . ":" . v_Triggerstring . "," . "func(" . SendFun . ").bind(" . TextInsert . "," . A_Space . true . ")," . A_Space . OnOff . ")"
	}
	else
	{
		Try
			Hotstring(":" . Options . ":" . v_TriggerString, func(SendFun).bind(TextInsert, false), OnOff)
		Catch
			MsgBox, 16, % SubStr(A_ScriptName, 1, -4) . A_Space . TransA["Error"], % A_ThisFunc . A_Space . TransA["Something went wrong with hotstring deletion:"] . "`n`n"
				. "Hotstring(:" . Options . ":" . v_Triggerstring . "," . "func(" . SendFun . ").bind(" . TextInsert . "," . A_Space . false . ")," . A_Space . OnOff . ")"
	}
	
	Hotstring("Reset") ;reset hotstring recognizer
	
	;3. Read the library file into List View. 
	if (v_OptionDisable)
		EnDis := "Dis"
	else
		EnDis := "En"
	
	;SendFun := ""
	Switch v_SelectFunction
	{
		Case "Clipboard (CL)": 			SendFun := "CL"
		Case "SendInput (SI)": 			SendFun := "SI"
		Case "Menu & Clipboard (MCL)": 	SendFun := "MCL"
		Case "Menu & SendInput (MSI)": 	SendFun := "MSI"
	}
	
	OutputFile 	:= A_ScriptDir . "\Libraries\temp.csv"	; changed on 2021-02-13
	InputFile 	:= A_ScriptDir . "\Libraries\" . v_SelectHotstringLibrary 
	LString 		:= "‖" . v_TriggerString . "‖"
	ModifiedFlag	:= false ;if true, duplicate triggerstring definition is found, if false, definition is new
	
	Gui, HS3: Default			;All of the ListView function operate upon the current default GUI window.
	GuiControl, % "Count" . v_TotalLines . A_Space . "-Redraw", % IdListView1 ;This option serves as a hint to the control that allows it to allocate memory only once rather than each time a row is added, which greatly improves row-adding performance (it may also improve sorting performance). 
	
	FileRead, v_TheWholeFile, Libraries\%v_SelectHotstringLibrary%
	Loop, Parse, v_TheWholeFile, `n, `r
		if (A_LoopField)
			v_TotalLines++
	
	;*[One]
	Loop, Parse, v_TheWholeFile, `n, `r
	{
		if (A_LoopField)
		{
			if (InStr(A_LoopField, LString))
			{
				MsgBox, 68, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"]
					, % TransA["The hostring"] . A_Space . """" .  v_TriggerString . """" . A_Space .  TransA["exists in the file"] . A_Space . v_SelectHotstringLibrary . "." . "`n`n" 
					. TransA["Do you want to proceed?"]
					. "`n`n" . TransA["If you answer ""Yes"" it will overwritten."]
				IfMsgBox, No
					return
				LV_Modify(A_Index, "", v_TriggerString, Options, SendFun, EnDis, TextInsert, v_Comment)
				ModifiedFlag := true
			}
		}
	}
	
	if !(ModifiedFlag) 
	{
		LV_Add("",  v_TriggerString, Options, SendFun, EnDis, TextInsert, v_Comment)
		a_Triggers.Push(v_TriggerString) ;added to table of hotstring recognizer (a_Triggers)
	}
	;4. Sort List View. 
	LV_ModifyCol(1, "Sort")
	;5. Delete library file. 
	FileDelete, %InputFile%
	
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
	FileAppend, % txt, Libraries\%v_SelectHotstringLibrary%, UTF-8
	GuiControl, +Redraw, % IdListView1 ;Afterward, use GuiControl, +Redraw to re-enable redrawing (which also repaints the control).
	;7. Increment library counter.
	++v_LibHotstringCnt
	++v_TotalHotstringCnt
	GuiControl, , % IdText13,  % v_LibHotstringCnt
	GuiControl, , % IdText13b, % v_LibHotstringCnt
	GuiControl, , % IdText12,  % v_TotalHotstringCnt
	GuiControl, , % IdText12b, % v_TotalHotstringCnt
	MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["Hotstring added to the file"] . A_Space . v_SelectHotstringLibrary . A_Space . "!" 
	
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
	GuiControl, HS3: Font, % IdCheckBox2
	GuiControl, HS3:, % IdCheckBox2, 0
	GuiControl, HS3: Font, % IdCheckBox3
	GuiControl, HS3:, % IdCheckBox3, 0
	GuiControl, HS3: Font, % IdCheckBox4
	GuiControl, HS3:, % IdCheckBox4, 0
	GuiControl, HS3: Font, % IdCheckBox5
	GuiControl, HS3:, % IdCheckBox5, 0
	GuiControl, HS3: Font, % IdCheckBox6
	GuiControl, HS3:, % IdCheckBox6, 0
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
	LV_Delete()
	
	Gui,		  HS4: Font, % "c" . c_FontColor
	GuiControl, HS4:, % IdEdit1b,  				;v_TriggerString
	GuiControl, HS4: Font, % IdCheckBox1b
	GuiControl, HS4:, % IdCheckBox1b, 0
	GuiControl, HS4: Font, % IdCheckBox2b
	GuiControl, HS4:, % IdCheckBox2b, 0
	GuiControl, HS4: Font, % IdCheckBox3b
	GuiControl, HS4:, % IdCheckBox3b, 0
	GuiControl, HS4: Font, % IdCheckBox4b
	GuiControl, HS4:, % IdCheckBox4b, 0
	GuiControl, HS4: Font, % IdCheckBox5b
	GuiControl, HS4:, % IdCheckBox5b, 0
	GuiControl, HS4: Font, % IdCheckBox6b
	GuiControl, HS4:, % IdCheckBox6b, 0
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
			MsgBox, 308, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["warning"], % TransA["The hostring"] . ":" . "`n`n" . v_Triggerstring . "`n`n" . TransA["exists in a file and will be now replaced."] 
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
	FileDelete, Libraries\%v_SelectHotstringLibrary%	;delete the old destination file.
	
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
	FileAppend, % txt, Libraries\%v_SelectHotstringLibrary%, UTF-8
	
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
	FileDelete, Libraries\%v_SourceLibrary%	;delete the old source filename.
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
	FileAppend, % txt, Libraries\%v_SourceLibrary%, UTF-8
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
	if (FileExist("Config.ini"))
	{
		MsgBox, 308, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["warning"], % TransA["The current Config.ini file will be deleted. This action cannot be undone. Next application will be reloaded and new Config.ini with default settings will be created. Are you sure?"] 
		IfMsgBox, Yes
		{
			FileDelete, Config.ini
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
		Gui, HS3: Font, % "s" . c_FontSize . A_Space . "cGreen Norm", % c_FontType
		Gui, HS4: Font, % "s" . c_FontSize . A_Space . "cGreen Norm", % c_FontType
	}
	else 
	{
		Gui, HS3: Font, % "s" . c_FontSize . A_Space . "c" . c_FontColor . A_Space . "Norm", % c_FontType
		Gui, HS4: Font, % "s" . c_FontSize . A_Space . "c" . c_FontColor . A_Space . "Norm", % c_FontType
	}
	GuiControl, HS3: Font, % A_GuiControl
	GuiControl, HS4: Font, % A_GuiControl
	Switch A_Gui
	{
		Case "HS3":
		GuiControl, HS4:, % A_GuiControl, % v_OutputVar
		Case "HS4":
		GuiControl, HS3:, % A_GuiControl, % v_OutputVar
	}
	return
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
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
	
	Gui, HSDel: Add, Slider, x0 y0 HwndIdHD_S1 vMySlider gmySlider Range100-1000 ToolTipBottom Buddy1999, % ini_Delay
	TransA["This option is valid"] := StrReplace(TransA["This option is valid"], "``n", "`n")
	Gui, HSDel: Add, Text, HwndIdHD_T1 vDelayText, % TransA["Clipboard paste delay in [ms]:"] . A_Space . ini_Delay . "`n`n" . TransA["This option is valid"]
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

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
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
	LibraryFullPathAndName := A_ScriptDir . "\Libraries\" . v_SelectHotstringLibrary
	FileDelete, % LibraryFullPathAndName
	
	;4. Disable selected hotstring.
	LV_GetText(txt2, v_SelectedRow, 2)
	Try
		Hotstring(":" . txt2 . ":" . v_TriggerString, , "Off") 
	Catch
		MsgBox, 16, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["Error"], % A_ThisFunc . A_Space . TransA["Something went wrong with hotstring deletion:"] . "`n`n" . v_TriggerString 
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
	FileAppend, % txt, Libraries\%v_SelectHotstringLibrary%, UTF-8
	
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

;In AutoHotkey there is no Guicontrol, Delete sub-command. As a consequence even if specific control is hidden (Guicontrol, Hide), the Gui size isn't changed, size is not decreased, as space for hidden control is maintained. To solve this issue, the separate gui have to be prepared. This requires a lot of work and is a matter of far future.
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
{
;Within a function, to create a set of variables that is local instead of global, declare OutputVar as a local variable prior to using command GuiControlGet, Pos. However, it is often also necessary to declare each variable in the set, due to a common source of confusion.	
	global ;assume-global mode
	local v_OutVarTemp1 := 0, v_OutVarTemp1X := 0, v_OutVarTemp1Y := 0, v_OutVarTemp1W := 0, v_OutVarTemp1H := 0
		,v_OutVarTemp2 := 0, v_OutVarTemp2X := 0, v_OutVarTemp2Y := 0, v_OutVarTemp2W := 0, v_OutVarTemp2H := 0
		,deltaW := 0, deltaH := 0
	
	;OutputDebug, % "A_GuiWidth:" . A_Space . A_GuiWidth . A_Space . "A_GuiHeight:" . A_Space .  A_GuiHeight
	
	if (A_EventInfo = 1) ; The window has been minimized.
	{
		;v_WhichGUIisMinimzed := "HS3"
		ini_WhichGui := "HS3"
		return
	}
	if (v_ResizingFlag) ;Special case: FontSize set to 16 and some procedures are run twice
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
	
	if (!ini_IsSandboxMoved)
		F_AutoXYWH("*w", IdEdit10)
	
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
	
	
	deltaW := A_GuiWidth -  HS3_GuiWidth
	deltaH := A_GuiHeight - HS3_GuiHeight
	
	;OutputDebug, % "Width:" . A_Space . Width . A_Space . "A_GuiWidth:" . A_Space . A_GuiWidth . A_Space . "Height:" . A_Space . Height . A_Space . "A_GuiHeight:" . A_Space . A_GuiHeight
	
	if (ini_Sandbox) and (deltaH > 0) and !(ini_IsSandboxMoved) and (v_OutVarTemp2H + HofText > LeftColumnH) 
	{
		GuiControl, MoveDraw, % IdListView1, % "h" v_OutVarTemp2H + c_ymarg + HofText + c_HofSandbox ;increase
		GuiControl, MoveDraw, % IdText10, % "x" c_xmarg "y" LeftColumnH + c_ymarg
		GuiControl, MoveDraw, % IdEdit10, % "x" c_xmarg "y" LeftColumnH + c_ymarg + HofText "w" LeftColumnW - c_xmarg
		;GuiControl, MoveDraw, % IdText8,  % "y" v_OutVarTemp2Y + v_OutVarTemp2H + c_ymarg + HofText + c_HofSandbox + c_ymarg ;Position of the long text F1 ... F2 ...
		ini_IsSandboxMoved := true
		OutputDebug, % "Two:" . A_Space ini_IsSandboxMoved . A_Space . deltaH
		F_AutoXYWH("reset")
		F_AutoXYWH("*wh", IdListView1)
		F_AutoXYWH("*h", IdButton5)
	}
	
	;if (ini_Sandbox) and (deltaH < 0) and (ini_IsSandboxMoved) and (v_OutVarTemp2H + HofText <  LeftColumnH + c_HofSandbox)
	if (ini_Sandbox) and (deltaH < 0) and (ini_IsSandboxMoved) and (v_OutVarTemp2H <  LeftColumnH + c_HofSandbox)
	{
		GuiControl, MoveDraw, % IdListView1, % "h" v_OutVarTemp2H - (c_ymarg + HofText + c_HofSandbox) ;decrease
		GuiControl, MoveDraw, % IdText10, % "x" LeftColumnW + c_xmarg + c_WofMiddleButton + c_xmarg "y" v_OutVarTemp2Y + v_OutVarTemp2H - (HofText + c_HofSandbox)
		GuiControl, MoveDraw, % IdEdit10, % "x" LeftColumnW + c_xmarg + c_WofMiddleButton + c_xmarg "y" v_OutVarTemp2Y + v_OutVarTemp2H - c_HofSandbox "w" v_OutVarTemp2W
		;GuiControl, MoveDraw, % IdText8, % "y" v_OutVarTemp2Y + v_OutVarTemp2H + c_ymarg ;Position of the long text F1 ... F2 ...
		ini_IsSandboxMoved := false
		OutputDebug, % "One:" . A_Space ini_IsSandboxMoved . A_Space . deltaH
		F_AutoXYWH("reset")
		F_AutoXYWH("*wh", IdListView1)
		F_AutoXYWH("*h", IdButton5)
	}
	
	/*
		if ((ini_Sandbox) and (ini_IsSandboxMoved))
		{
			GuiControl, MoveDraw, % IdText8, % "y" v_OutVarTemp2Y + v_OutVarTemp2H + c_ymarg ;Position of the long text F1 ... F2 ...
			OutputDebug, % "Three" . A_Space . deltaH
		}
	*/
	if ((ini_Sandbox) and !(ini_IsSandboxMoved))
	{
		
		GuiControl, MoveDraw, % IdText10, % "y" v_OutVarTemp2Y + v_OutVarTemp2H + c_ymarg
		GuiControl, MoveDraw, % IdEdit10, % "y" v_OutVarTemp2Y + v_OutVarTemp2H + c_ymarg + HofText 
		;GuiControl, MoveDraw, % IdText8,  % "y" v_OutVarTemp2Y + v_OutVarTemp2H + c_ymarg + HofText + c_HofSandbox + c_ymarg
		OutputDebug, % "Four" . A_Space . deltaH
	}
	/*
		if (!ini_Sandbox)
		{
			GuiControl, MoveDraw, % IdText8, % "y" v_OutVarTemp2Y + v_OutVarTemp2H + c_ymarg ;Position of the long text F1 ... F2 ...
			OutputDebug, % "Five" . A_Space . deltaH
		}
	*/
	
	HS3_GuiWidth  := A_GuiWidth	;only GuiSize automatic subroutine is able to determine A_GuiWidth and A_GuiHeight, so the last value is stored in global variables.
	HS3_GuiHeight := A_GuiHeight
	;OutputDebug, % "A_GuiWidth:" . A_Space . A_GuiWidth . A_Space "A_GuiHeight" . A_Space . A_GuiHeight
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
	FileRead, v_TheWholeFile, Libraries\%v_SelectHotstringLibrary%
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

F_HSLV() 
; copy content of List View 1 to editable fields of HS3 Gui
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
	Instr(Options,"*0") or (InStr(Options,"*") = 0) 							? F_CheckOption("No", 1) 	: F_CheckOption("Yes", 1)
	((Instr(Options,"C0")) or (Instr(Options,"C1")) or (Instr(Options,"C") = 0)) 	? F_CheckOption("No", 2) 	: F_CheckOption("Yes", 2)
	Instr(Options,"B0") 												? F_CheckOption("Yes", 3) 	: F_CheckOption("No", 3)
	Instr(Options,"?") 													? F_CheckOption("Yes", 4) 	: F_CheckOption("No", 4)
	(Instr(Options,"O0") or (InStr(Options,"O") = 0)) 						? F_CheckOption("No", 5) 	: F_CheckOption("Yes", 5)
	
	LV_GetText(Fun, 			v_SelectedRow, 3)
	if (Fun = "SI")
	{ ;SendFun := "F_NormalWay"
		GuiControl, HS3: Choose, v_SelectFunction, SendInput (SI)
		GuiControl, HS4: Choose, v_SelectFunction, SendInput (SI)
	}
	else if (Fun = "CL")
	{ ;SendFun := "F_ViaClipboard"
		GuiControl, HS3: Choose, v_SelectFunction, Clipboard (CL)
		GuiControl, HS4: Choose, v_SelectFunction, Clipboard (CL)
	}
	else if (Fun = "MCL")
	{ ;SendFun := "F_MenuCli"
		GuiControl, HS3: Choose, v_SelectFunction, Menu & Clipboard (MCL)
		GuiControl, HS4: Choose, v_SelectFunction, Menu & Clipboard (MCL)
	}
	else if (Fun = "MSI")
	{ ;SendFun := "F_MenuAHK"
		GuiControl, HS3: Choose, v_SelectFunction, Menu & SendInput (MSI)
		GuiControl, HS4: Choose, v_SelectFunction, Menu & SendInput (MSI)
	}
	
	LV_GetText(EnDis, 		v_SelectedRow, 4)
	InStr(EnDis, "En") ? F_CheckOption("No", 6) : F_CheckOption("Yes", 6)
	
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
	
	IniRead, c_FontType, 			Config.ini, GraphicalUserInterface, GuiFontType, Calibri
	if (!c_FontType)
		c_FontType := "Calibri"
	
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_SaveFontType()
{
	global	;assume-global mode
	IniWrite, % c_FontType,			Config.ini, GraphicalUserInterface, GuiFontType
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
		Reload
	}
	IfMsgBox, No
		return	
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

F_SaveSizeOfMargin()
{
	global	;assume-global mode
	IniWrite, % c_xmarg,				Config.ini, GraphicalUserInterface, GuiSizeOfMarginX
	IniWrite, % c_ymarg,				Config.ini, GraphicalUserInterface, GuiSizeOfMarginY
	return
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

F_LoadSizeOfMargin()
{
	global	;assume-global mode
	SizeOfMargin				:= {1: 0, 2: 5, 3: 10, 4: 15, 5: 20} ;pixels
	c_xmarg := 10	;pixels
	c_ymarg := 10	;pixels
	
	IniRead, c_xmarg, 			Config.ini, GraphicalUserInterface, GuiSizeOfMarginX, 10
	IniRead, c_ymarg,			Config.ini, GraphicalUserInterface, GuiSizeOfMarginY, 10
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
		Reload
	}
	IfMsgBox, No
		return	
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_SaveFontSize()
{
	global ;assume-global mode
	IniWrite, % c_FontSize,				Config.ini, GraphicalUserInterface, GuiFontSize
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_LoadFontSize()
{
	global ;assume-global mode
	c_FontSize 				:= 0 ;points
	
	IniRead, c_FontSize, 			Config.ini, GraphicalUserInterface, GuiFontSize, 10
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
		c_FontColorHighlighted		:= "Navy"
		c_WindowColor				:= "Gray"
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
		Reload
	}
	IfMsgBox, No
		return	
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_SaveGUIstyle()
{
	global ;assume-global mode
	
	IniWrite, % c_FontColor,				Config.ini, GraphicalUserInterface, GuiFontColor
	IniWrite, % c_FontColorHighlighted,	Config.ini, GraphicalUserInterface, GuiFontColorHighlighted
	IniWrite, % c_WindowColor, 	  		Config.ini, GraphicalUserInterface, GuiWindowColor
	Iniwrite, % c_ControlColor,			Config.ini, GraphicalUserInterface, GuiControlColor	
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
	
	IniRead, c_FontColor, 			Config.ini, GraphicalUserInterface, GuiFontColor, 		 Black
	IniRead, c_FontColorHighlighted, 	Config.ini, GraphicalUserInterface, GuiFontColorHighlighted, Blue
	IniRead, c_WindowColor, 			Config.ini, GraphicalUserInterface, GuiWindowColor, 		 Default
	IniRead, c_ControlColor, 		Config.ini, GraphicalUserInterface, GuiControlColor, 		 Default
	
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
		Menu, TraySubmenu,	  Add, % TransA["Standard executable (Ahk2Exe.exe)"], F_Compile
	}
	if (FileExist(v_TempOutStr . "upx.exe"))
	{
		Menu, CompileSubmenu, Add, % TransA["Compressed executable (upx.exe)"], F_Compile
		Menu, TraySubmenu,	  Add, % TransA["Compressed executable (upx.exe)"], F_Compile
	}
	if (FileExist(v_TempOutStr . "mpress.exe"))
	{
		Menu, CompileSubmenu, Add, % TransA["Compressed executable (mpress.exe)"], F_Compile
		Menu, TraySubmenu,		  Add, % TransA["Compressed executable (mpress.exe)"], F_Compile
	}
	Menu,	Tray,			Add, % TransA["Compile"],				:TraySubmenu
	Menu,	ApplicationSubmenu,	Add,	% TransA["Compile"],				:CompileSubmenu
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
		Run, % v_TempOutStr . "Ahk2Exe.exe" 
				. A_Space . "/in"       . A_Space . A_ScriptDir . "\" . A_ScriptName 
				. A_Space . "/out"      . A_Space . A_ScriptDir . "\" . SubStr(A_ScriptName, 1, -4) . "." . "exe"
				. A_Space . "/icon"     . A_Space . A_ScriptDir . "\" . AppIcon
				. A_Space . "/bin"      . A_Space . """" . v_TempOutStr . "Unicode 64-bit.bin" . """"
				. A_Space . "/cp"       . A_Space . "65001"	;Unicode (UTF-8)
				;. A_Space . "/ahk"      . A_Space . """" . v_TempOutStr . "\" . "AutoHotkey.exe" . """" ;not clear yet when this option should be applied
				. A_Space . "/compress" . A_Space . "0"
		MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["The executable file is prepared by Ahk2Exe, but not compressed:"]
				. "`n`n" . A_ScriptDir . "\" . SubStr(A_ScriptName, 1, -4) . ".exe" . "`n`n" . "/bin" . ":" . A_Space . "Unicode 64-bit.bin" . A_Space . "cp:" . A_Space . "65001" . A_Space . "(Unicode (UTF-8))"
				. "`n" . TransA["Build with Autohotkey.exe version"] . ":" . A_Space . A_AhkVersion
		
		Case TransA["Compressed executable (upx.exe)"]:
		Run, % v_TempOutStr . "Ahk2Exe.exe" 
				. A_Space . "/in"   	. A_Space . A_ScriptDir . "\" . A_ScriptName 
				. A_Space . "/out"  	. A_Space . A_ScriptDir . "\" . SubStr(A_ScriptName, 1, -4) . "." . "exe"
				. A_Space . "/icon" 	. A_Space . A_ScriptDir . "\" . AppIcon 
				. A_Space . "/bin"      . A_Space . """" . v_TempOutStr . "Unicode 64-bit.bin" . """"
				. A_Space . "/cp"   	. A_Space . "65001"	;Unicode (UTF-8)
				;. A_Space . "/ahk"      . A_Space . """" . v_TempOutStr . "\" . "AutoHotkey.exe" . """" ;not clear yet when this option should be applied
				. A_Space . "/compress" 	. A_Space . "2" 
		MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"],  % TransA["The executable file is prepared by Ahk2Exe and compressed by upx.exe:"]
				. "`n`n" . A_ScriptDir . "\" . SubStr(A_ScriptName, 1, -4) . ".exe" . "`n`n" . "/bin" . ":" . A_Space . "Unicode 64-bit.bin" . A_Space . "cp:" . A_Space . "65001" . A_Space . "(Unicode (UTF-8))"
				. "`n" . TransA["Build with Autohotkey.exe version"] . ":" . A_Space . A_AhkVersion
		
		Case TransA["Compressed executable (mpress.exe)"]:
		Run, % v_TempOutStr . "Ahk2Exe.exe" 
				. A_Space . "/in" . A_Space . A_ScriptDir . "\" . A_ScriptName 
				. A_Space . "/out" . A_Space . A_ScriptDir . "\" . SubStr(A_ScriptName, 1, -4) . "." . "exe"
				. A_Space . "/icon" . A_Space . A_ScriptDir . "\" . AppIcon 
				. A_Space . "/bin"      . A_Space . """" . v_TempOutStr . "Unicode 64-bit.bin" . """"
				. A_Space . "/cp"   	. A_Space . "65001"	;Unicode (UTF-8)
				;. A_Space . "/ahk"      . A_Space . """" . v_TempOutStr . "\" . "AutoHotkey.exe" . """" ;not clear yet when this option should be applied
				. A_Space . "/compress" . A_Space . "1"
		MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["The executable file is prepared by Ahk2Exe and compressed by mpress.exe:"]
				. "`n`n" . A_ScriptDir . "\" . SubStr(A_ScriptName, 1, -4) . ".exe" . "`n`n" . "/bin" . ":" . A_Space . "Unicode 64-bit.bin" . A_Space . "cp:" . A_Space . "65001" . A_Space . "(Unicode (UTF-8))"
				. "`n" . TransA["Build with Autohotkey.exe version"] . ":" . A_Space . A_AhkVersion
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
			IniWrite, % ini_GuiReload,		Config.ini, GraphicalUserInterface, GuiReload
			Reload
		}
		else
			Reload
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
	Iniwrite, %ini_Sandbox%, Config.ini, GraphicalUserInterface, Sandbox
	
	F_GuiMain_Redraw()
	F_GuiHS4_Redraw()
	Gui, % A_DefaultGui . ":" . A_Space . "Show", AutoSize
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
	
	IniRead, ini_ReadTemp, 						Config.ini, GraphicalUserInterface, MainWindowPosX, 0
	ini_HS3WindoPos["X"] := ini_ReadTemp
	IniRead, ini_ReadTemp, 						Config.ini, GraphicalUserInterface, MainWindowPosY, 0
	ini_HS3WindoPos["Y"] := ini_ReadTemp
	IniRead, ini_ReadTemp, 						Config.ini, GraphicalUserInterface, MainWindowPosW, 0
	ini_HS3WindoPos["W"] := ini_ReadTemp
	IniRead, ini_ReadTemp, 						Config.ini, GraphicalUserInterface, MainWindowPosH, 0
	ini_HS3WindoPos["H"] := ini_ReadTemp
	
	IniRead, ini_ReadTemp,						Config.ini, GraphicalUserInterface, ListViewPosW, % A_Space
	ini_ListViewPos["W"] := ini_ReadTemp
	IniRead, ini_ReadTemp,						Config.ini, GraphicalUserInterface, ListViewPosH, % A_Space
	ini_ListViewPos["H"] := ini_ReadTemp
	
	IniRead, ini_Sandbox, 						Config.ini, GraphicalUserInterface, Sandbox
	IniRead, ini_IsSandboxMoved,					Config.ini, GraphicalUserInterface, IsSandboxMoved 
	IniRead, ini_WhichGui,						Config.ini, GraphicalUserInterface, WhichGui, %A_Space%
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
[GraphicalUserInterface]
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
GuiReload=
[Configuration]
UndoHotstring=1
Delay=300
MenuSound=1
EndingChar_Space=1
EndingChar_Minus=1
EndingChar_ORoundBracket=1
EndingChar_CRoundBracket=1
EndingChar_OSquareBracket=1
EndingChar_CSquareBracket=1
EndingChar_OCurlyBracket=1
EndingChar_CCurlyBracket=1
EndingChar_Colon=1
EndingChar_Semicolon=1
EndingChar_Apostrophe=1
EndingChar_Quote=1
EndingChar_Slash=0
EndingChar_Backslash=1
EndingChar_Comma=1
EndingChar_Dot=1
EndingChar_QuestionMark=1
EndingChar_ExclamationMark=1
EndingChar_Enter=1
EndingChar_Tab=1
EndingChar_Underscore=0
Tips=1
Cursor=0
Caret=1
TipsChars=1
MenuCursor=0
MenuCaret=1
TipsSortAlphatebically=1
TipsSortByLength=1
Language=English.txt
[LoadLibraries]
[ShowTipsLibraries]
	)"
	
	if (!FileExist("Config.ini"))
	{
		MsgBox, 48, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["warning"], % TransA["Config.ini wasn't found. The default Config.ini is now created in location:"] . "`n`n" . A_ScriptDir
		FileAppend, %ConfigIni%, Config.ini
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
		IniWrite, % WinX, 			  	Config.ini, GraphicalUserInterface, MainWindowPosX
		IniWrite, % WinY, 			  	Config.ini, GraphicalUserInterface, MainWindowPosY
		IniWrite, % "", 				Config.ini, GraphicalUserInterface, MainWindowPosW
		IniWrite, % "", 				Config.ini, GraphicalUserInterface, MainWindowPosH
		return
	}	
	
	if (A_DefaultGui = "HS3")
	{
		WinGetPos, WinX, WinY, , , % "ahk_id" . HS3GuiHwnd
		IniWrite,  HS3,			Config.ini, GraphicalUserInterface, WhichGui
		IniWrite, % HS3_GuiWidth, 	Config.ini, GraphicalUserInterface, MainWindowPosW
		IniWrite, % HS3_GuiHeight, 	Config.ini, GraphicalUserInterface, MainWindowPosH
		GuiControlGet, TempPos,	Pos, % IdListView1
		IniWrite, % TempPosW,		Config.ini, GraphicalUserInterface, ListViewPosW
		IniWrite, % TempPosH,		Config.ini, GraphicalUserInterface, ListViewPosH
	}
	
	if (A_DefaultGui = "HS4")
	{
		WinGetPos, WinX, WinY, , , % "ahk_id" . HS4GuiHwnd
		IniWrite,  HS4,			Config.ini, GraphicalUserInterface, WhichGui
		IniWrite, % HS4_GuiWidth, 	Config.ini, GraphicalUserInterface, MainWindowPosW
		IniWrite, % HS4_GuiHeight, 	Config.ini, GraphicalUserInterface, MainWindowPosH
	}
	
	IniWrite, % WinX, 			  Config.ini, GraphicalUserInterface, MainWindowPosX
	IniWrite, % WinY, 			  Config.ini, GraphicalUserInterface, MainWindowPosY
	
	IniWrite, % ini_Sandbox, 	  Config.ini, GraphicalUserInterface, Sandbox
	IniWrite, % ini_IsSandboxMoved, Config.ini, GraphicalUserInterface, IsSandboxMoved
	
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
	IniRead, v_LibraryFlag, Config.ini, ShowTipsLibraries, %A_ThisMenuitem%
	v_LibraryFlag := !(v_LibraryFlag)
	IniWrite, %v_LibraryFlag%, Config.ini, ShowTipsLibraries, %A_ThisMenuitem%
	
	F_ValidateIniLibSections()
	a_Triggers := []
	F_LoadHotstringsFromLibraries()
	return
}

; ------------------------------------------------------------------------------------------------------------------------------------

F_EnDisLib() 
{
	global ;assume-global mode
	local v_LibraryFlag := 0 ;, v_WhichLibraries := "", v_LibTemp := "", v_LibFlagTemp := ""
	
	Menu, EnDisLib, ToggleCheck, %A_ThisMenuItem%
	IniRead, v_LibraryFlag,	Config.ini, LoadLibraries, %A_ThisMenuitem%
	v_LibraryFlag := !(v_LibraryFlag)
	Iniwrite, %v_LibraryFlag%,	Config.ini, LoadLibraries, %A_ThisMenuItem%
	
	F_ValidateIniLibSections()
	F_UpdateSelHotLibDDL()
	F_LoadHotstringsFromLibraries()
	MsgBox, 68, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["If you've just unchecked any library, its hotstring definitions remain active. Please reload the application in order to deactivate it."] 
		. "`n`n" . TransA["Do you want to reload application now?"]
	IfMsgBox, Yes
	{
		F_SaveGUIPos()
		ini_GuiReload := true
		IniWrite, % ini_GuiReload,		Config.ini, GraphicalUserInterface, GuiReload
		Reload
	}
	return
}

; ------------------------------------------------------------------------------------------------------------------------------------

F_LoadCreateTranslationTxt(decision*)
{
	global ;assume-global mode
	local TransConst := "" ; variable which is used as default content of Languages/English.ini. Join lines with `n separator and escape all ` occurrences. Thanks to that string lines where 'n is present 'aren't separated.
	
;Warning. If right side contains `n chars it's necessary to replace them with StrReplace.
	TransConst := "			
(Join`n `			
About/Help (F1) 										= &About/Help (F1)
Add comment (optional) 									= Add comment (optional)
Add library 											= Add library
A library with that name already exists! 					= A library with that name already exists!
Apostrophe ' 											= Apostrophe '
Application											= A&pplication
Application help 										= Application help
Application language changed to: 							= Application language changed to:
Are you sure you want to exit this application now?			= Are you sure you want to exit this application now?
Are you sure you want to reload this application now?			= Are you sure you want to reload this application now
Backslash \ 											= Backslash \
Build with Autohotkey.exe version							= Build with Autohotkey.exe version
Cancel 												= Cancel
Caret 												= Caret
Case Sensitive (C) 										= Case Sensitive (C)
Change Language 										= Change Language
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
Config.ini wasn't found. The default Config.ini is now created in location: = Config.ini wasn't found. The default Config.ini is now created in location:
Configuration 											= &Configuration
Continue reading the library file? If you answer ""No"" then application will exit! = Continue reading the library file? If you answer ""No"" then application will exit!
Conversion of .ahk file into new .csv file (library) and loading of that new library = Conversion of .ahk file into new .csv file (library) and loading of that new library
Conversion of .csv library file into new .ahk file containing static (triggerstring, hotstring) definitions = Conversion of .csv library file into new .ahk file containing static (triggerstring, hotstring) definitions
Conversion of .csv library file into new .ahk file containing dynamic (triggerstring, hotstring) definitions = Conversion of .csv library file into new .ahk file containing dynamic (triggerstring, hotstring) definitions
Converted												= Converted
(Current configuration will be saved befor reload takes place).	= (Current configuration will be saved befor reload takes place).
Do you want to delete it?								= Do you want to delete it?
Do you want to proceed? 									= Do you want to proceed?
Do you want to reload application now?						= Do you want to reload application now?
Cursor 												= Cursor
Dark													= Dark
Delete hotstring (F8) 									= Delete hotstring (F8)
Deleting hotstring... 									= Deleting hotstring...
Deleting hotstring. Please wait... 						= Deleting hotstring. Please wait...
Disable 												= Disable
DISABLED												= DISABLED
Dot . 												= Dot .
Do you want to reload application now?						= Do you want to reload application now?
Dynamic hotstrings 										= &Dynamic hotstrings
Edit Hotstrings 										= Edit Hotstrings
Enable/Disable 										= Enable/Disable
Enable/disable libraries									= Enable/disable &libraries
Enable/disable triggerstring tips 							= Enable/disable triggerstring tips	
Enable sound if overrun 									= Enable sound if overrun
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
exists in a file and will be now replaced.					= exists in a file and will be now replaced.
Exit													= Exit
Export from .csv to .ahk 								= &Export from .csv to .ahk
Export to .ahk with static definitions of hotstrings			= Export to .ahk with static definitions of hotstrings
Export to .ahk with dynamic definitions of hotstrings			= Export to .ahk with dynamic definitions of hotstrings
Exported												= Exported
F3 or Esc: Close Search hotstrings | F8: Move hotstring between libraries = F3 or Esc: Close Search hotstrings | F8: Move hotstring between libraries
file! 												= file!
file in Languages subfolder!								= file in Languages subfolder!
file is now created in the following subfolder:				= file is now created in the following subfolder:
folder is now created							= folder is now created
Font type												= Font type
Genuine hotstrings AutoHotkey documentation 					= Genuine hotstrings AutoHotkey documentation
Graphical User Interface									= Graphical User Interface
has been created. 										= has been created.
Hotstring 											= Hotstring
Hotstring added to the file								= Hotstring added to the file
Hotstring has been deleted. Now application will restart itself in order to apply changes, reload the libraries (.csv) = Hotstring has been deleted. Now application will restart itself in order to apply changes, reload the libraries (.csv)
Hotstring menu (MSI, MCL) 								= Hotstring menu (MSI, MCL)
Hotstring moved to the 									= Hotstring moved to the
Hotstring paste from Clipboard delay 1 s 					= Hotstring paste from Clipboard delay 1 s
Hotstring paste from Clipboard delay 						= Hotstring paste from Clipboard delay
Hotstrings have been loaded 								= Hotstrings have been loaded
If you answer ""Yes"" it will overwritten.					= If you answer ""Yes"" it will overwritten.
If you answer ""Yes"", the existing file will be deleted. This is recommended choice. If you answer ""No"", new content will be added to existing file. = If you answer ""Yes"", the existing file will be deleted. This is recommended choice. If you answer ""No"", new content will be added to existing file.
If you've just unchecked any library, its hotstring definitions remain active. Please reload the application in order to deactivate it. = If you've just unchecked any library, its hotstring definitions remain active. Please reload the application in order to deactivate it.
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
Loading of (triggerstring, hotstring) definitions from the library file = Loading of (triggerstring, hotstring) definitions from the library file
Loading file											= Loading file
Loaded hotstrings: 										= Loaded hotstrings:
Loading hotstrings from libraries... 						= Loading hotstrings from libraries...
Loading imported library. Please wait...					= Loading imported library. Please wait...
Loaded												= Loaded
Minus - 												= Minus -
Move (F8)												= Move (F8)
No Backspace (B0) 										= No Backspace (B0)
No End Char (O) 										= No End Char (O)
No libraries have been found!								= No libraries have been found!
Number of characters for tips 							= &Number of characters for tips
of													= of
OK													= &OK
Opening Curly Bracket { 									= Opening Curly Bracket {
Opening Round Bracket ( 									= Opening Round Bracket (
Opening Square Bracket [ 								= Opening Square Bracket [
Please wait, uploading .csv files... 						= Please wait, uploading .csv files...
question												= question
Question Mark ? 										= Question Mark ?
Quote "" 												= Quote ""
Pause Script											= Pause Script
Phrase to search for:									= Phrase to search for:
pixels												= pixels
Position of main window is saved in Config.ini.				= Position of main window is saved in Config.ini.	
Public libraries										= Public libraries
Reload												= Reload
Remove Config.ini										= Remove Config.ini
Replacement text is blank. Do you want to proceed? 			= Replacement text is blank. Do you want to proceed?
Sandbox (F6)											= Sandbox (F6)
Save position of application window	 					= &Save position of application window
Saved												= Saved
Saving of sorted content into .csv file (library)				= Saving of sorted content into .csv file (library)
Search by: 											= Search by:
Search Hotstrings 										= Search Hotstrings
Search Hotstrings (F3)									= &Search Hotstrings (F3)
Select a row in the list-view, please! 						= Select a row in the list-view, please!
Selected Hotstring will be deleted. Do you want to proceed? 	= Selected Hotstring will be deleted. Do you want to proceed?
Select hotstring output function 							= Select hotstring output function
Select the target library: 								= Select the target library:
Select trigger option(s) 								= Select trigger option(s)
Semicolon ; 											= Semicolon ;
Set Clipboard Delay										= Set Clipboard Delay
Set hotstring (F9) 										= Set hotstring (F9)
Show full GUI (F4)										= Show full GUI (F4)
Show Sandbox (F6)										= Show Sandbox (F6)
Size of font											= Size of font
Size of margin:										= Size of margin:
Slash / 												= Slash /
Something went wrong with hotstring deletion:				= Something went wrong with hotstring deletion:
Sort tips alphabetically 								= Sort tips &alphabetically
Sort tips by length 									= Sort tips by &length
Space 												= Space
Specified definition of hotstring has been deleted			= Specified definition of hotstring has been deleted
Standard executable (Ahk2Exe.exe)							= Standard executable (Ahk2Exe.exe)
Static hotstrings 										= &Static hotstrings
Such file already exists									= Such file already exists
Suspend Hotkeys										= Suspend Hotkeys
Tab 													= Tab
The application will be reloaded with the new language file. 	= The application will be reloaded with the new language file.
The current Config.ini file will be deleted. This action cannot be undone. Next application will be reloaded and new Config.ini with default settings will be created. Are you sure? = The current Config.ini file will be deleted. This action cannot be undone. Next application will be reloaded and new Config.ini with default settings will be created. Are you sure?
The default											= The default
The executable file is prepared by Ahk2Exe and compressed by mpress.exe: = The executable file is prepared by Ahk2Exe and compressed by mpress.exe:
The executable file is prepared by Ahk2Exe and compressed by upx.exe: = The executable file is prepared by Ahk2Exe and compressed by upx.exe:
The executable file is prepared by Ahk2Exe, but not compressed:	= The executable file is prepared by Ahk2Exe, but not compressed:
The hostring 											= The hostring
The already imported file already existed. As a consequence some (triggerstring, hotstring) definitions could also exist and ""Total"" could be incredible. Therefore application will be now restarted in order to correctly apply the changes. = The already imported file already existed. As a consequence some (triggerstring, hotstring) definitions could also exist and ""Total"" could be incredible. Therefore application will be now restarted in order to correctly apply the changes.
The library  											= The library 
The file path is: 										= The file path is:
the following line is found:								= the following line is found:
There is no Libraries subfolder and no lbrary (*.csv) file exist! = There is no Libraries subfolder and no lbrary (*.csv) file exist!
The selected file is empty. Process of import will be interrupted. = The selected file is empty. Process of import will be interrupted.
There is no											= There is no
There was no Languages subfolder, so one now is created.		= There was no Languages subfolder, so one now is created.
This library:											= This library:
This line do not comply to format required by this application.  = This line do not comply to format required by this application.
This option is valid 									= In case you observe some hotstrings aren't pasted from clipboard increase this value. `nThis option is valid for CL and MCL hotstring output functions. 
Toggle EndChars	 									= &Toggle EndChars
Total:												= Total:
(triggerstring, hotstring) definitions						= (triggerstring, hotstring) definitions
Triggerstring 											= Triggerstring
Triggerstring / hotstring behaviour						= Triggerstring / hotstring behaviour
Triggerstring tips 										= &Triggerstring tips
Triggerstring|Trigg Opt|Out Fun|En/Dis|Hotstring|Comment 		= Triggerstring|Trigg Opt|Out Fun|En/Dis|Hotstring|Comment
Underscore _											= Underscore _
Undo the last hotstring 									= &Undo the last hotstring
warning												= warning
Warning, code generated automatically for definitions based on menu, see documentation of Hotstrings application for further details. = Warning, code generated automatically for definitions based on menu, see documentation of Hotstrings application for further details.
↓ Click here to select hotstring library ↓					= ↓ Click here to select hotstring library ↓
)"
	
	TransA					:= {}	;this associative array is used to store translations of this application text strings
	
	local key := "", val := "", tick := false
	
	if (decision[1] = "create")
		FileAppend, %TransConst%, %A_ScriptDir%\Languages\English.txt, UTF-8 
	
	if (decision[1] = "load")
	{
		Loop, Read, %A_ScriptDir%\Languages\%ini_Language%
		{
			tick := false
			Loop, Parse, A_LoopReadLine, =, %A_Space%%A_Tab%
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
			}
			TransA[key] := val
		}
		return
	}
	
	tick := false
	Loop, Parse, TransConst, =`n, %A_Space%%A_Tab%
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
	return
}
; ------------------------------------------------------------------------------------------------------------------------------------
;Future. Rationale: when specific library is unchecked in menu, its hotstrings should be unloaded (and triggers). What is done currently is only "loading of all libraries again", but in such
;a case all existing hotstring definitions remain not changed in memory. So currently script should be reloaded.
F_UnloadFile(nameoffile)
{
	
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
	
	FileRead, v_TheWholeFile, % A_ScriptDir . "\Libraries\" . nameoffile
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
			F_ini_StartHotstring(A_LoopField, nameoffile)
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
	
	/*
		IdText1 IdText2 IdText3 IdText4 IdText5 IdText6 IdText7 IdText8 IdText9 IdText10 IdText11 IdText12 IdText13
		IdCheckBox1 IdCheckBox2 IdCheckBox3 IdCheckBox4 IdCheckBox5 IdCheckBox6
		IdEdit1 IdEdit2 IdEdit3 IdEdit4 IdEdit5 IdEdit6 IdEdit7 IdEdit8 IdEdit9 IdEdit10
		IdGroupBox1
		IdDDL1 IdDDL2
		IdButton1 IdButton2 IdButton3 IdButton4 IdButton5
		IdListView1
		
		v_LoadedHotstrings v_TriggerString v_OptionImmediateExecute v_OptionCaseSensitive v_OptionNoBackspace v_OptionInsideWord v_OptionNoEndChar v_OptionDisable
		v_TextSelectHotstringsOutFun v_SelectFunction v_TextEnterHotstring
		v_EnterHotstring v_EnterHotstring1 v_EnterHotstring2 v_EnterHotstring3 v_EnterHotstring4 v_EnterHotstring5 v_EnterHotstring6
		v_Comment
		v_TextSelectHotstringLibrary v_SelectHotstringLibrary
		v_DeleteHotstring 
		v_LibraryContent v_ShortcutsMainInterface v_Sandbox v_NoOfHotstringsInLibrary
	*/
	
;1. Definition of HS4 GUI.
	Gui, 	HS4: New, 	-Resize +HwndHS4GuiHwnd +OwnDialogs -MaximizeBox, % SubStr(A_ScriptName, 1, -4) 
	Gui, 	HS4: Margin,	% c_xmarg, % c_ymarg
	Gui,		HS4: Color,	% c_WindowColor, % c_ControlColor
	
;2. Prepare all text objects according to mock-up.
	Gui,		HS4: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, 	HS4: Add, 		Text, 		x0 y0 HwndIdText1b, 									% TransA["Enter triggerstring"]
	Gui,		HS4: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, % c_FontType
	Gui, 	HS4: Add, 		Text, 		x0 y0 HwndIdText2b, % TransA["Total:"] . A_Space
	Gui,		HS4: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, Consolas ;Consolas type is monospace
	Gui, 	HS4: Add, 		Text, 		x0 y0 HwndIdText12b, % v_TotalHotstringCnt
	Gui,		HS4: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, % c_FontType
	
	Gui, 	HS4: Add, 		Edit, 		x0 y0 HwndIdEdit1b vv_TriggerString 
;GuiControl,	Hide,		% IdEdit1
	
	Gui, 	HS4: Add, 	CheckBox, 	x0 y0 HwndIdCheckBox1b gF_Checkbox vv_OptionImmediateExecute,	% TransA["Immediate Execute (*)"]
;GuiControl,	Hide,		% IdCheckBox1
	Gui, 	HS4: Add,		CheckBox, 	x0 y0 HwndIdCheckBox2b gF_Checkbox vv_OptionCaseSensitive,		% TransA["Case Sensitive (C)"]
;GuiControl,	Hide,		% IdCheckBox2
	Gui, 	HS4: Add,		CheckBox, 	x0 y0 HwndIdCheckBox3b gF_Checkbox vv_OptionNoBackspace,		% TransA["No Backspace (B0)"]
;GuiControl,	Hide,		% IdCheckBox3
	Gui, 	HS4: Add,		CheckBox, 	x0 y0 HwndIdCheckBox4b gF_Checkbox vv_OptionInsideWord, 		% TransA["Inside Word (?)"]
;GuiControl,	Hide,		% IdCheckBox4
	Gui, 	HS4: Add,		CheckBox, 	x0 y0 HwndIdCheckBox5b gF_Checkbox vv_OptionNoEndChar, 		% TransA["No End Char (O)"]
;GuiControl,	Hide,		% IdCheckBox5
	Gui, 	HS4: Add, 	CheckBox, 	x0 y0 HwndIdCheckBox6b gF_Checkbox vv_OptionDisable, 			% TransA["Disable"]
;GuiControl,	Hide,		% IdCheckBox6
	
	Gui,		HS4: Add,		GroupBox, 	x0 y0 HwndIdGroupBox1b, 									% TransA["Select trigger option(s)"]
;GuiControl,	Hide,		% IdGroupBox1
	
	Gui,		HS4: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, 	HS4: Add, 		Text, 		x0 y0 HwndIdText3b vv_TextSelectHotstringsOutFun, 			% TransA["Select hotstring output function"]
	;GuiControl,	Hide,		% IdText3
	Gui,		HS4: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, % c_FontType
	
	Gui, 	HS4: Add, 		DropDownList, 	x0 y0 HwndIdDDL1b vv_SelectFunction gF_SelectFunction, 		SendInput (SI)||Clipboard (CL)|Menu & SendInput (MSI)|Menu & Clipboard (MCL)
	;GuiControl,	Hide,		% IdDDL1
	
	Gui,		HS4: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, 	HS4: Add, 		Text, 		x0 y0 HwndIdText4b vv_TextEnterHotstring, 				% TransA["Enter hotstring"]
	;GuiControl,	Hide,		% IdText4
	Gui,		HS4: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, % c_FontType
	
	Gui, 	HS4: Add, 		Edit, 		x0 y0 HwndIdEdit2b vv_EnterHotstring
	;GuiControl,	Hide,		% IdEdit2
	Gui, 	HS4: Add, 		Edit, 		x0 y0 HwndIdEdit3b vv_EnterHotstring1  Disabled
	;GuiControl,	Hide,		% IdEdit3
	Gui, 	HS4: Add, 		Edit, 		x0 y0 HwndIdEdit4b vv_EnterHotstring2  Disabled
	;GuiControl,	Hide,		% IdEdit4
	Gui, 	HS4: Add, 		Edit, 		x0 y0 HwndIdEdit5b vv_EnterHotstring3  Disabled
	;GuiControl,	Hide,		% IdEdit5
	Gui, 	HS4: Add, 		Edit, 		x0 y0 HwndIdEdit6b vv_EnterHotstring4  Disabled
	;GuiControl,	Hide,		% IdEdit6
	Gui, 	HS4: Add, 		Edit, 		x0 y0 HwndIdEdit7b vv_EnterHotstring5  Disabled
	;GuiControl,	Hide,		% IdEdit7
	Gui, 	HS4: Add, 		Edit, 		x0 y0 HwndIdEdit8b vv_EnterHotstring6  Disabled
	;GuiControl,	Hide,		% IdEdit8
	
	Gui,		HS4: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, 	HS4: Add, 		Text, 		x0 y0 HwndIdText5b,				 						% TransA["Add comment (optional)"]
	;GuiControl,	Hide,		% IdText5
	Gui,		HS4: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, 			% c_FontType
	
	Gui, 	HS4: Add, 		Edit, 		x0 y0 HwndIdEdit9b vv_Comment Limit64 
	;GuiControl,	Hide,		% IdEdit9
	
	Gui,		HS4: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, 	HS4: Add, 		Text, 		x0 y0 HwndIdText6b vv_TextSelectHotstringLibrary, 			% TransA["Select hotstring library"]
	;GuiControl,	Hide,		% IdText6
	Gui,		HS4: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, 			% c_FontType
	
	Gui, 	HS4: Add, 		Button, 		x0 y0 HwndIdButton1b gF_GuiAddLibrary, 						% TransA["Add library"]
	;GuiControl,	Hide,		% IdButton1
	Gui,		HS4: Add,		DropDownList,	x0 y0 HwndIdDDL2b vv_SelectHotstringLibrary gF_SelectLibrary Sort
	;GuiControl,	Hide,		% IdDDL2
	
	;Gui,			HS3:Font,		% "s" . c_FontSize . A_Space . "bold cBlack", % c_FontType
	Gui, 	HS4: Add, 		Button, 		x0 y0 HwndIdButton2b gF_SetHotstring,						% TransA["Set hotstring (F9)"]
	;GuiControl,	HideSet% IdButton2
	Gui, 	HS4: Add, 		Button, 		x0 y0 HwndIdButton3b gF_Clear,							% TransA["Clear (F5)"]
	;GuiControl,	Hide,		% IdButton3
	Gui, 	HS4: Add, 		Button, 		x0 y0 HwndIdButton4b gF_DeleteHotstring vv_DeleteHotstring Disabled, 	% TransA["Delete hotstring (F8)"]
	;GuiControl,	Hide,		% IdButton4
	
	Gui,		HS4: Add,			Button,		x0 y0 HwndIdButton5b gF_ToggleRightColumn,			⯈`nF4
	;GuiControl,	Hide,		% IdButton5
	Gui, 	HS4: Add, 		Text, 		x0 y0 HwndIdText10b,			 						% TransA["Sandbox (F6)"]
	Gui, 	HS4: Add, 		Edit, 		x0 y0 HwndIdEdit10b vv_Sandbox r3 						; r3 = 3x rows of text
	
	Gui,		HS4: Add,			Text,		x0 y0 HwndIdText11b, % TransA["This library:"] . A_Space
	Gui,		HS4: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, Consolas ;Consolas type is monospace
	Gui, 	HS4: Add, 		Text, 		x0 y0 HwndIdText13b,  % v_LibHotstringCnt ;value of Hotstrings counter
	Gui,		HS4: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, 			% c_FontType
}

; ------------------------------------------------------------------------------------------------------------------------------------

F_GuiMain_CreateObject()
{
	global ;assume-global mode
	local x0 := 0, y0 := 0
	v_OptionImmediateExecute := 0, v_OptionCaseSensitive := 0, v_OptionNoBackspace := 0, v_OptionInsideWord := 0, v_OptionNoEndChar := 0, v_OptionDisable := 0
	
	v_TotalHotstringCnt 		:= 0000
	v_LibHotstringCnt			:= 0000 ;no of (triggerstring, hotstring) definitions in single library
	HS3_GuiWidth  				:= 0
	HS3_GuiHeight 				:= 0
	
	/*
		IdText1 IdText2 IdText3 IdText4 IdText5 IdText6 IdText7 IdText8 IdText9 IdText10 IdText11 IdText12 IdText13
		IdCheckBox1 IdCheckBox2 IdCheckBox3 IdCheckBox4 IdCheckBox5 IdCheckBox6
		IdEdit1 IdEdit2 IdEdit3 IdEdit4 IdEdit5 IdEdit6 IdEdit7 IdEdit8 IdEdit9 IdEdit10
		IdGroupBox1
		IdDDL1 IdDDL2
		IdButton1 IdButton2 IdButton3 IdButton4 IdButton5
		IdListView1
		
		v_LoadedHotstrings v_TriggerString v_OptionImmediateExecute v_OptionCaseSensitive v_OptionNoBackspace v_OptionInsideWord v_OptionNoEndChar v_OptionDisable
		v_TextSelectHotstringsOutFun v_SelectFunction v_TextEnterHotstring
		v_EnterHotstring v_EnterHotstring1 v_EnterHotstring2 v_EnterHotstring3 v_EnterHotstring4 v_EnterHotstring5 v_EnterHotstring6
		v_Comment
		v_TextSelectHotstringLibrary v_SelectHotstringLibrary
		v_DeleteHotstring
		v_LibraryContent v_ShortcutsMainInterface v_Sandbox v_NoOfHotstringsInLibrary
	*/
	
;1. Definition of HS3 GUI.
;-DPIScale doesn't work in Microsoft Windows 10
;+Border doesn't work in Microsoft Windows 10
;OwnDialogs
	Gui, 		HS3: New, 		+Resize +HwndHS3GuiHwnd +OwnDialogs -MaximizeBox, 						% SubStr(A_ScriptName, 1, -4)
	Gui, 		HS3: Margin,		% c_xmarg, % c_ymarg
	Gui,			HS3: Color,		% c_WindowColor, % c_ControlColor
	
;2. Prepare all text objects according to mock-up.
	Gui,			HS3: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, 		HS3: Add, 		Text, 		x0 y0 HwndIdText1, 										% TransA["Enter triggerstring"]
	;GuiControl, 	Hide, 		% IdText1
	
	Gui,			HS3: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, 			% c_FontType
	Gui, 		HS3: Add, 		Edit, 		x0 y0 HwndIdEdit1 vv_TriggerString 
	;GuiControl,	Hide,		% IdEdit1
	Gui,			HS3: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, 			% c_FontType
	Gui, 		HS3: Add, 		Text, 		x0 y0 HwndIdText2, % TransA["Total:"] . A_Space 
	Gui,			HS3: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, 			Consolas ;Consolas type is monospace
	Gui, 		HS3: Add, 		Text, 		x0 y0 HwndIdText12, % v_TotalHotstringCnt
	Gui,			HS3: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, 			% c_FontType
	
	Gui, 		HS3: Add, 		CheckBox, 	x0 y0 HwndIdCheckBox1 gF_Checkbox vv_OptionImmediateExecute,	% TransA["Immediate Execute (*)"]
;GuiControl,	Hide,		% IdCheckBox1
	Gui, 		HS3: Add,			CheckBox, 	x0 y0 HwndIdCheckBox2 gF_Checkbox vv_OptionCaseSensitive,		% TransA["Case Sensitive (C)"]
;GuiControl,	Hide,		% IdCheckBox2
	Gui, 		HS3: Add,			CheckBox, 	x0 y0 HwndIdCheckBox3 gF_Checkbox vv_OptionNoBackspace,		% TransA["No Backspace (B0)"]
;GuiControl,	Hide,		% IdCheckBox3
	Gui, 		HS3: Add,			CheckBox, 	x0 y0 HwndIdCheckBox4 gF_Checkbox vv_OptionInsideWord, 		% TransA["Inside Word (?)"]
;GuiControl,	Hide,		% IdCheckBox4
	Gui, 		HS3: Add,			CheckBox, 	x0 y0 HwndIdCheckBox5 gF_Checkbox vv_OptionNoEndChar, 			% TransA["No End Char (O)"]
;GuiControl,	Hide,		% IdCheckBox5
	Gui, 		HS3: Add, 		CheckBox, 	x0 y0 HwndIdCheckBox6 gF_Checkbox vv_OptionDisable, 			% TransA["Disable"]
;GuiControl,	Hide,		% IdCheckBox6
	
	Gui,			HS3: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui,			HS3: Add,		GroupBox, 	x0 y0 HwndIdGroupBox1, 										% TransA["Select trigger option(s)"]
	Gui,			HS3: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, 			% c_FontType
;GuiControl,	Hide,		% IdGroupBox1
	
	Gui,			HS3: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, 		HS3: Add, 		Text, 		x0 y0 HwndIdText3 vv_TextSelectHotstringsOutFun, 				% TransA["Select hotstring output function"]
;GuiControl,	Hide,		% IdText3
	Gui,			HS3: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, 			% c_FontType
	
	Gui, 		HS3: Add, 		DropDownList, 	x0 y0 HwndIdDDL1 vv_SelectFunction gF_SelectFunction, 			SendInput (SI)||Clipboard (CL)|Menu & SendInput (MSI)|Menu & Clipboard (MCL)
;GuiControl,	Hide,		% IdDDL1
	
	Gui,			HS3: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, 		HS3: Add, 		Text, 		x0 y0 HwndIdText4 vv_TextEnterHotstring, 					% TransA["Enter hotstring"]
;GuiControl,	Hide,		% IdText4
	Gui,			HS3: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, 			% c_FontType
	
	Gui, 		HS3: Add, 		Edit, 		x0 y0 HwndIdEdit2 vv_EnterHotstring
;GuiControl,	Hide,		% IdEdit2
	Gui, 		HS3: Add, 		Edit, 		x0 y0 HwndIdEdit3 vv_EnterHotstring1  Disabled
;GuiControl,	Hide,		% IdEdit3
	Gui, 		HS3: Add, 		Edit, 		x0 y0 HwndIdEdit4 vv_EnterHotstring2  Disabled
;GuiControl,	Hide,		% IdEdit4
	Gui, 		HS3: Add, 		Edit, 		x0 y0 HwndIdEdit5 vv_EnterHotstring3  Disabled
;GuiControl,	Hide,		% IdEdit5
	Gui, 		HS3: Add, 		Edit, 		x0 y0 HwndIdEdit6 vv_EnterHotstring4  Disabled
;GuiControl,	Hide,		% IdEdit6
	Gui, 		HS3: Add, 		Edit, 		x0 y0 HwndIdEdit7 vv_EnterHotstring5  Disabled
;GuiControl,	Hide,		% IdEdit7
	Gui, 		HS3: Add, 		Edit, 		x0 y0 HwndIdEdit8 vv_EnterHotstring6  Disabled
;GuiControl,	Hide,		% IdEdit8
	
	Gui,			HS3: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, 		HS3: Add, 		Text, 		x0 y0 HwndIdText5,				 						% TransA["Add comment (optional)"]
;GuiControl,	Hide,		% IdText5
	Gui,			HS3: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, 			% c_FontType
	
	Gui, 		HS3: Add, 		Edit, 		x0 y0 HwndIdEdit9 vv_Comment Limit64 
;GuiControl,	Hide,		% IdEdit9
	
	Gui,			HS3: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, 		HS3: Add, 		Text, 		x0 y0 HwndIdText6 vv_TextSelectHotstringLibrary, 				% TransA["Select hotstring library"]
;GuiControl,	Hide,		% IdText6
	Gui,			HS3: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, 			% c_FontType
	
	Gui, 		HS3: Add, 		Button, 		x0 y0 HwndIdButton1 gF_GuiAddLibrary, 						% TransA["Add library"]
;GuiControl,	Hide,		% IdButton1
	Gui,			HS3: Add,		DropDownList,	x0 y0 HwndIdDDL2 vv_SelectHotstringLibrary gF_SelectLibrary Sort
;GuiControl,	Hide,		% IdDDL2
	
;Gui,			HS3:Font,		% "s" . c_FontSize . A_Space . "bold cBlack", % c_FontType
	Gui, 		HS3:Add, 		Button, 		x0 y0 HwndIdButton2 gF_SetHotstring,							% TransA["Set hotstring (F9)"]
;GuiControl,	HideSet% IdButton2
	Gui, 		HS3:Add, 		Button, 		x0 y0 HwndIdButton3 gF_Clear,									% TransA["Clear (F5)"]
;GuiControl,	Hide,		% IdButton3
	Gui, 		HS3:Add, 		Button, 		x0 y0 HwndIdButton4 gF_DeleteHotstring vv_DeleteHotstring Disabled, 	% TransA["Delete hotstring (F8)"]
;GuiControl,	Hide,		% IdButton4
	
	Gui,			HS3:Add,		Button,		x0 y0 HwndIdButton5 gF_ToggleRightColumn,			⯇`nF4
;GuiControl,	Hide,		% IdButton5
	
;Gui,			HS3:Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, % c_FontType
	
	Gui,			HS3:Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, 		HS3:Add, 		Text, 		x0 y0 HwndIdText7,		 							% TransA["Library content (F2)"]
;GuiControl,	Hide,		% IdText7
	Gui,			HS3:Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, % c_FontType
	
	Gui,			HS3:Add, 		Text, 		x0 y0 HwndIdText9, 									% TransA["Triggerstring|Trigg Opt|Out Fun|En/Dis|Hotstring|Comment"]
;GuiControl,	Hide,		% IdText9
	Gui, 		HS3:Add, 		ListView, 	x0 y0 HwndIdListView1 LV0x1 vv_LibraryContent AltSubmit gF_HSLV -Multi, % TransA["Triggerstring|Trigg Opt|Out Fun|En/Dis|Hotstring|Comment"]
;GuiControl,	Hide,		% IdListView1
	
	Gui,			HS3:Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, 		HS3:Add, 		Text, 		x0 y0 HwndIdText10,			 						% TransA["Sandbox (F6)"]
;GuiControl,	Hide,		% IdText10
	Gui,			HS3:Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, % c_FontType
	
	Gui, 		HS3:Add, 		Edit, 		x0 y0 HwndIdEdit10 vv_Sandbox r3 						; r3 = 3x rows of text
;GuiControl,	Hide,		% IdEdit10
;Gui, 		HS3:Add, 		Edit, 		HwndIdEdit11 vv_ViewString gViewString ReadOnly Hide
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
	
	if (ini_Sandbox)
	{
		GuiControl, Move, % IdText10b, % "x" c_xmarg "y" LeftColumnH + c_ymarg
		GuiControl, Move, % IdEdit10b, % "x" c_xmarg "y" LeftColumnH + c_ymarg + HofText "w" LeftColumnW - c_xmarg
		GuiControl, Show, % IdText10b
		GuiControl, Show, % IdEdit10b
		;5.2. Position of counters
		GuiControlGet, v_OutVarTemp, Pos, % IdEdit10b
		v_xNext := c_xmarg
		v_yNext := v_OutVarTempY + v_OutVarTempH + c_ymarg 
		GuiControl, Move, % IdText11b,  % "x" v_xNext "y" v_yNext ;text: Hotstrings
		GuiControlGet, v_OutVarTemp, Pos, % IdText11b
		v_xNext := v_OutVarTempX + v_OutVarTempW
		GuiControl, Move, % IdText13b,  % "x" v_xNext "y" v_yNext ;text: value of Hotstrings
		GuiControlGet, v_OutVarTemp, Pos, % IdText13b
		v_xNext := v_OutVarTempX + v_OutVarTempW + c_xmarg
		GuiControl, Move, % IdText2b, % "x" v_xNext "y" v_yNext ;where to place text Total
		GuiControlGet, v_OutVarTemp, Pos, % IdText2
		v_xNext += v_OutVarTempW
		GuiControl, Move, % IdText12b, % "x" v_xNext "y" v_yNext ;Where to place value of total counter
	}
	else
	{
		GuiControl, Hide, % IdText10b ;sandobx text
		GuiControl, Hide, % IdEdit10b ;sandbox edit field
		;5.3. Position of counters
		v_xNext := c_xmarg
		v_yNext := LeftColumnH
		GuiControl, Move, % IdText11b,  % "x" v_xNext "y" v_yNext ;text: "This library""
		GuiControlGet, v_OutVarTemp, Pos, % IdText11b
		v_xNext := v_OutVarTempX + v_OutVarTempW
		GuiControl, Move, % IdText13b,  % "x" v_xNext "y" v_yNext ;text: value displayed after "This library"
		GuiControlGet, v_OutVarTemp, Pos, % IdText13b
		v_xNext := v_OutVarTempX + v_OutVarTempW + c_xmarg
		GuiControl, Move, % IdText2b, % "x" v_xNext "y" v_yNext ;where to place text "Total"
		GuiControlGet, v_OutVarTemp, Pos, % IdText2
		v_xNext += v_OutVarTempW
		GuiControl, Move, % IdText12b, % "x" v_xNext "y" v_yNext ;Where to place value after "Total"
	}
	
	;5.2. Button between left and right column
	v_xNext := LeftColumnW + c_xmarg
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
							,v_xNext := 0, 		v_yNext := 0, 			v_wNext := 0, 			v_hNext := 0
	
	;4. Determine constraints, according to mock-up
	GuiControlGet, v_OutVarTemp1, Pos, % IdButton2b
	GuiControlGet, v_OutVarTemp2, Pos, % IdButton3b
	GuiControlGet, v_OutVarTemp3, Pos, % IdButton4b
	
	LeftColumnW := c_xmarg + v_OutVarTemp1W + c_xmarg + v_OutVarTemp2W + c_xmarg + v_OutVarTemp3W
	;OutputDebug, % "IdButton2:" . A_Space . IdButton2 . A_Space . "IdButton3:" . A_Space . IdButton3 . A_Space . "IdButton4:" . A_Space . IdButton4
	;OutputDebug, % "v_OutVarTemp1W:" . A_Space . v_OutVarTemp1W  . A_Space . "v_OutVarTemp2W:" . A_Space . v_OutVarTemp2W . A_Space . "v_OutVarTemp3W:" . A_Space .  v_OutVarTemp3W  . A_Space . "c_xmarg:" . A_Space c_xmarg
	;OutputDebug, % "LeftColumnW:" . A_Space . LeftColumnW
	
	;5. Move text objects to correct position
	;5.1. Left column
	;5.1.1. Enter triggerstring
	v_yNext := c_ymarg
	v_xNext := c_xmarg
	GuiControl, Move, % IdText1b, % "x" v_xNext "y" v_yNext
	;GuiControl, Show, % IdText1
	GuiControlGet, v_OutVarTemp1, Pos, % IdText1b
	GuiControlGet, v_OutVarTemp2, Pos, % IdEdit1b
	v_xNext := c_xmarg + v_OutVarTemp1W + c_xmarg
	v_wNext := LeftColumnW - v_xNext
	
	GuiControl, Move, % IdEdit1b, % "x" v_xNext "y" v_yNext "w" v_wNext
	;GuiControl, Show, % IdEdit1
	
	;5.1.2. Trigger options
	v_yNext += Max(v_OutVarTemp1H, v_OutVarTemp2H)
	v_xNext := c_xmarg
	v_wNext := LeftColumnW - v_xNext
	v_hNext := HofText + 3 * HofCheckBox + c_ymarg
	GuiControl, Move, % IdGroupBox1b, % "x" v_xNext "y" v_yNext "w" v_wNext "h" v_hNext
	;GuiControl, Show, % IdGroupBox1
	
	v_yNext += HofText
	v_xNext := c_xmarg * 2
	GuiControlGet, v_OutVarTemp1, Pos, % IdCheckBox1b
	GuiControlGet, v_OutVarTemp2, Pos, % IdCheckBox3b
	GuiControlGet, v_OutVarTemp3, Pos, % IdCheckBox5b
	WleftMiniColumn  := Max(v_OutVarTemp1W, v_OutVarTemp2W, v_OutVarTemp3W)
	GuiControlGet, v_OutVarTemp1, Pos, % IdCheckBox2b
	GuiControlGet, v_OutVarTemp2, Pos, % IdCheckBox4b
	GuiControlGet, v_OutVarTemp3, Pos, % IdCheckBox6b
	WrightMiniColumn := Max(v_OutVarTemp1W, v_OutVarTemp2W, v_OutVarTemp3W)
	SpaceBetweenColumns := LeftColumnW - (3 * c_xmarg + WleftMiniColumn + WrightMiniColumn)
	GuiControl, Move, % IdCheckBox1b, % "x" v_xNext "y" v_yNext
	;GuiControl, Show, % IdCheckBox1
	v_xNext += SpaceBetweenColumns + WleftMiniColumn
	GuiControl, Move, % IdCheckBox2b, % "x" v_xNext "y" v_yNext
	;GuiControl, Show, % IdCheckBox2
	v_yNext += HofCheckBox
	v_xNext := c_xmarg * 2
	GuiControl, Move, % IdCheckBox3b, % "x" v_xNext "y" v_yNext
	;GuiControl, Show, % IdCheckBox3
	v_xNext += SpaceBetweenColumns + wleftminicolumn
	GuiControl, Move, % IdCheckBox4b, % "x" v_xNext "y" v_yNext
	;GuiControl, Show, % IdCheckBox4
	v_yNext += HofCheckBox
	v_xNext := c_xmarg * 2
	GuiControl, Move, % IdCheckBox5b, % "x" v_xNext "y" v_yNext
	;GuiControl, Show, % IdCheckBox5
	v_xNext += SpaceBetweenColumns + wleftminicolumn
	GuiControl, Move, % IdCheckBox6b, % "x" v_xNext "y" v_yNext
	;GuiControl, Show, % IdCheckBox6
	
	;5.1.3. Select hotstring output function
	v_yNext += HofCheckBox + c_ymarg * 2
	v_xNext := c_xmarg
	GuiControl, Move, % IdText3b, % "x" v_xNext "y" v_yNext
	v_yNext += HofText
	v_wNext := LeftColumnW - v_xNext
	GuiControl, Move, % IdDDL1b, % "x" v_xNext "y" v_yNext "w" v_wNext
	
	v_yNext += HofDropDownList + c_ymarg
	v_xNext := c_xmarg
	GuiControl, Move, % IdText4b, % "x" v_xNext "y" v_yNext
	v_yNext += HofText
	v_xNext := c_xmarg
	v_wNext := LeftColumnW - v_xNext
	GuiControl, Move, % IdEdit2b, % "x" v_xNext "y" v_yNext "w" v_wNext
	v_yNext += HofEdit
	GuiControl, Move, % IdEdit3b, % "x" v_xNext "y" v_yNext "w" v_wNext
	v_yNext += HofEdit
	GuiControl, Move, % IdEdit4b, % "x" v_xNext "y" v_yNext "w" v_wNext
	v_yNext += HofEdit
	GuiControl, Move, % IdEdit5b, % "x" v_xNext "y" v_yNext "w" v_wNext
	v_yNext += HofEdit
	GuiControl, Move, % IdEdit6b, % "x" v_xNext "y" v_yNext "w" v_wNext
	v_yNext += HofEdit
	GuiControl, Move, % IdEdit7b, % "x" v_xNext "y" v_yNext "w" v_wNext
	v_yNext += HofEdit
	GuiControl, Move, % IdEdit8b, % "x" v_xNext "y" v_yNext "w" v_wNext
	
	v_yNext += HofEdit + c_ymarg
	v_xNext := c_xmarg
	GuiControl, Move, % IdText5b, % "x" v_xNext "y" v_yNext
	v_yNext += HofText
	v_xNext := c_xmarg
	v_wNext := LeftColumnW - v_xNext
	GuiControl, Move, % IdEdit9b, % "x" v_xNext "y" v_yNext "w" v_wNext
	
	v_yNext += HofEdit + c_ymarg
	v_xNext := c_xmarg
	GuiControl, Move, % IdText6b, % "x" v_xNext "y" v_yNext
	GuiControlGet, v_OutVarTemp1, Pos, % IdText6b
	GuiControlGet, v_OutVarTemp2, Pos, % IdButton1b
	v_OutVarTemp := LeftColumnW - (v_OutVarTemp1W + v_OutVarTemp2W + 2 * c_xmarg)
	v_xNext := v_OutVarTemp1W + v_OutVarTemp
	v_wNext := v_OutVarTemp2W + 2 * c_xmarg
	GuiControl, Move, % IdButton1b, % "x" v_xNext "y" v_yNext "w" v_wNext
	v_yNext += HofButton
	v_xNext := c_xmarg
	v_wNext := LeftColumnW - v_xNext
	GuiControl, Move, % IdDDL2b, % "x" v_xNext "y" v_yNext "w" . v_wNext
	
	v_yNext += HofDropDownList + c_ymarg
	v_xNext := c_xmarg
	GuiControlGet, v_OutVarTemp1, Pos, % IdButton2b
	GuiControlGet, v_OutVarTemp2, Pos, % IdButton3b
	GuiControl, Move, % IdButton2b, % "x" v_xNext "y" v_yNext
	v_xNext += v_OutVarTemp1W + c_xmarg
	GuiControl, Move, % IdButton3b, % "x" v_xNext "y" v_yNext
	v_xNext += v_OutVarTemp2W + c_xmarg
	GuiControl, Move, % IdButton4b, % "x" v_xNext "y" v_yNext
	;OutputDebug, % "LeftColumnH:" . A_Space . LeftColumnH
	HS4MinWidth		:= LeftColumnW 
	;HS4MinHeight		:= LeftColumnH + c_ymarg
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
	
	;position of the List View, but only when HS3 Gui is initiated: before showing. So this code is run only once.
	
	if (b_FirstRun) 
	{
		v_xNext := LeftColumnW + c_xmarg + c_WofMiddleButton + c_xmarg
		v_yNext := c_ymarg + HofText
		if (!(ini_ListViewPos["W"]) or !(ini_ListViewPos["H"])) ;if HS3 Gui is generated for the very first time
		{
			v_wNext := RightColumnW
			if ((ini_Sandbox) and !(ini_IsSandboxMoved))
			{
				;v_hNext := LeftColumnH - (3 * c_ymarg + 3 * HofText + c_HofSandbox)
				v_hNext := LeftColumnH - (2 * c_ymarg + 2 * HofText + c_HofSandbox)
			}
			if ((ini_Sandbox) and (ini_IsSandboxMoved))
			{
				;v_hNext := LeftColumnH - (c_ymarg + c_HofSandbox + c_ymarg)
				v_hNext := LeftColumnH - (c_ymarg + c_HofSandbox)
			}
			if !(ini_Sandbox)
			{
				;v_hNext := LeftColumnH - (2 * c_ymarg + 2 * HofText)
				v_hNext := LeftColumnH - (c_ymarg + HofText)
				GuiControl, Hide, % IdText10
				GuiControl, Hide, % IdEdit10
			}
			GuiControl, Move, % IdListView1, % "x" v_xNext "y" v_yNext "w" v_wNext "h" v_hNext
		}
		else
			GuiControl, Move, % IdListView1, % "x" v_xNext "y" v_yNext "w" ini_ListViewPos["W"] "h" ini_ListViewPos["H"]
		
		b_FirstRun := false
	}
	else
	{
		GuiControlGet, v_OutVarTemp, Pos, % IdListView1
		
		;Increase / decrease List View 1
		if ((ini_Sandbox) and !(ini_IsSandboxMoved))
		{
			if (v_OutVarTempH + HofText > LeftColumnH)
				ini_IsSandboxMoved := true
			else
			{
				v_hNext := v_OutVarTempH - (c_HofSandbox + HofText + c_ymarg)
				GuiControl, Move, % IdListView1, % "h" v_hNext
				F_AutoXYWH("reset")	
			}
		}
		
		if (!(ini_Sandbox) and !(ini_IsSandboxMoved))
		{
			v_hNext := v_OutVarTempH + (c_HofSandbox + HofText + c_ymarg)
			GuiControl, Move, % IdListView1, % "h" v_hNext
			F_AutoXYWH("reset")	
		}
		
		if (!(ini_Sandbox) and ini_IsSandboxMoved)
			ini_IsSandboxMoved := false
	}
	
	;5.3.3. Text Sandbox
	;5.2.4. Sandbox edit text field
	;5.3.5. Position of the long text F1 ... F2 ... (IdText8)
	GuiControlGet, v_OutVarTemp, Pos, % IdListView1
	if ((ini_Sandbox) and (ini_IsSandboxMoved))
	{
		GuiControl, Move, % IdText10, % "x" c_xmarg "y" LeftColumnH + c_ymarg
		GuiControl, Move, % IdEdit10, % "x" c_xmarg "y" LeftColumnH + c_ymarg + HofText "w" LeftColumnW - c_xmarg
		GuiControl, Show, % IdText10
		GuiControl, Show, % IdEdit10
	}
	
	if ((ini_Sandbox) and !(ini_IsSandboxMoved)) ;checked
	{
		v_xNext := LeftColumnW + c_xmarg + c_WofMiddleButton + c_xmarg
		v_yNext := v_OutVarTempY + v_OutVarTempH + c_ymarg
		GuiControl, Move, % IdText10, % "x" v_xNext "y" v_yNext
		GuiControl, Show, % IdText10
		v_yNext += HofText
		v_wNext := v_OutVarTempW
		GuiControl, Move, % IdEdit10, % "x" v_xNext "y" v_yNext "w" v_wNext
		GuiControl, Show, % IdEdit10
	}
	
	if !(ini_Sandbox)
	{
		GuiControl, Hide, % IdText10
		GuiControl, Hide, % IdEdit10
	}
	;5.2. Button between left and right column
	if ((ini_Sandbox) and !(ini_IsSandboxMoved)) ;checked
	{
		v_yNext := c_ymarg
		v_xNext := LeftColumnW + c_xmarg
		v_hNext := c_ymarg + HofText + v_OutVarTempH + HofText + c_HofSandbox
	}	
	if ((ini_Sandbox) and (ini_IsSandboxMoved))
	{
		v_yNext := c_ymarg
		v_xNext := LeftColumnW + c_xmarg
		v_hNext := HofText + v_OutVarTempH
	}
	if !(ini_Sandbox)
	{
		v_yNext := c_ymarg
		v_xNext := LeftColumnW + c_xmarg
		v_hNext := HofText + v_OutVarTempH
	}
	GuiControl, Move, % IdButton5, % "x" v_xNext "y" v_yNext "h" v_hNext
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
							,v_xNext := 0, 		v_yNext := 0, 			v_wNext := 0, 			v_hNext := 0
		,WleftMiniColumn := 0,	WrightMiniColumn := 0,	SpaceBetweenColumns := 0
	
;4. Determine constraints, according to mock-up
	GuiControlGet, v_OutVarTemp1, Pos, % IdButton2
	GuiControlGet, v_OutVarTemp2, Pos, % IdButton3
	GuiControlGet, v_OutVarTemp3, Pos, % IdButton4
	
	LeftColumnW := c_xmarg + v_OutVarTemp1W + c_xmarg + v_OutVarTemp2W + c_xmarg + v_OutVarTemp3W
;OutputDebug, % "IdButton2:" . A_Space . IdButton2 . A_Space . "IdButton3:" . A_Space . IdButton3 . A_Space . "IdButton4:" . A_Space . IdButton4
;OutputDebug, % "v_OutVarTemp1W:" . A_Space . v_OutVarTemp1W  . A_Space . "v_OutVarTemp2W:" . A_Space . v_OutVarTemp2W . A_Space . "v_OutVarTemp3W:" . A_Space .  v_OutVarTemp3W  . A_Space . "c_xmarg:" . A_Space c_xmarg
;OutputDebug, % "LeftColumnW:" . A_Space . LeftColumnW
	
	GuiControlGet, v_OutVarTemp2, Pos, % IdText9 ;Triggerstring|Trigg Opt|Out Fun|En/Dis|Hotstring|Comment"]
	RightColumnW := v_OutVarTemp2W
	GuiControl,	Hide,		% IdText9
	
;5. Move text objects to correct position
;5.1. Left column
;5.1.1. Enter triggerstring
	v_xNext := c_xmarg
	v_yNext := c_ymarg
	GuiControl, Move, % IdText1, % "x" v_xNext "y" v_yNext
;GuiControl, Show, % IdText1
;Gui, 		%HS3GuiHwnd%:Show, AutoSize Center
	
	GuiControlGet, v_OutVarTemp1, Pos, % IdText1
	GuiControlGet, v_OutVarTemp2, Pos, % IdEdit1
	v_xNext := c_xmarg + v_OutVarTemp1W + c_xmarg
	v_wNext := LeftColumnW - v_xNext
	
	GuiControl, Move, % IdEdit1, % "x" v_xNext "y" v_yNext "w" v_wNext
	;GuiControl, Show, % IdEdit1
	
;5.1.2. Trigger options
	v_yNext += Max(v_OutVarTemp1H, v_OutVarTemp2H)
	v_xNext := c_xmarg
	v_wNext := LeftColumnW - v_xNext
	v_hNext := HofText + 3 * HofCheckBox + 2 * c_ymarg
	GuiControl, Move, % IdGroupBox1, % "x" v_xNext "y" v_yNext "w" v_wNext "h" v_hNext
	;GuiControl, Show, % IdGroupBox1
	
	v_yNext += HofText + c_ymarg
	v_xNext := c_xmarg * 2
	GuiControlGet, v_OutVarTemp1, Pos, % IdCheckBox1
	GuiControlGet, v_OutVarTemp2, Pos, % IdCheckBox3
	GuiControlGet, v_OutVarTemp3, Pos, % IdCheckBox5
	WleftMiniColumn  := Max(v_OutVarTemp1W, v_OutVarTemp2W, v_OutVarTemp3W)
	GuiControlGet, v_OutVarTemp1, Pos, % IdCheckBox2
	GuiControlGet, v_OutVarTemp2, Pos, % IdCheckBox4
	GuiControlGet, v_OutVarTemp3, Pos, % IdCheckBox6
	WrightMiniColumn := Max(v_OutVarTemp1W, v_OutVarTemp2W, v_OutVarTemp3W)
	SpaceBetweenColumns := LeftColumnW - (3 * c_xmarg + WleftMiniColumn + WrightMiniColumn)
	if (SpaceBetweenColumns < 0)
		SpaceBetweenColumns := 0
	if (WleftMiniColumn + WrightMiniColumn > LeftColumnW - 3 * c_xmarg)
		WleftMiniColumn := Round((LeftColumnW - 3 * c_xmarg)/ 2) 
	GuiControl, Move, % IdCheckBox1, % "x" v_xNext "y" v_yNext
	;GuiControl, Show, % IdCheckBox1
	v_xNext += SpaceBetweenColumns + WleftMiniColumn
	GuiControl, Move, % IdCheckBox2, % "x" v_xNext "y" v_yNext
	;GuiControl, Show, % IdCheckBox2
	v_yNext += HofCheckBox
	v_xNext := c_xmarg * 2
	GuiControl, Move, % IdCheckBox3, % "x" v_xNext "y" v_yNext
	;GuiControl, Show, % IdCheckBox3
	v_xNext += SpaceBetweenColumns + wleftminicolumn
	GuiControl, Move, % IdCheckBox4, % "x" v_xNext "y" v_yNext
	;GuiControl, Show, % IdCheckBox4
	v_yNext += HofCheckBox
	v_xNext := c_xmarg * 2
	GuiControl, Move, % IdCheckBox5, % "x" v_xNext "y" v_yNext
	;GuiControl, Show, % IdCheckBox5
	v_xNext += SpaceBetweenColumns + wleftminicolumn
	GuiControl, Move, % IdCheckBox6, % "x" v_xNext "y" v_yNext
	;GuiControl, Show, % IdCheckBox6
	
;5.1.3. Select hotstring output function
	v_yNext += HofCheckBox + c_ymarg * 2
	v_xNext := c_xmarg
	GuiControl, Move, % IdText3, % "x" v_xNext "y" v_yNext
	v_yNext += HofText
	v_wNext := LeftColumnW - v_xNext
	GuiControl, Move, % IdDDL1, % "x" v_xNext "y" v_yNext "w" v_wNext
	
	v_yNext += HofDropDownList + c_ymarg
	v_xNext := c_xmarg
	GuiControl, Move, % IdText4, % "x" v_xNext "y" v_yNext
	v_yNext += HofText
	v_xNext := c_xmarg
	v_wNext := LeftColumnW - v_xNext
	GuiControl, Move, % IdEdit2, % "x" v_xNext "y" v_yNext "w" v_wNext
	v_yNext += HofEdit
	GuiControl, Move, % IdEdit3, % "x" v_xNext "y" v_yNext "w" v_wNext
	v_yNext += HofEdit
	GuiControl, Move, % IdEdit4, % "x" v_xNext "y" v_yNext "w" v_wNext
	v_yNext += HofEdit
	GuiControl, Move, % IdEdit5, % "x" v_xNext "y" v_yNext "w" v_wNext
	v_yNext += HofEdit
	GuiControl, Move, % IdEdit6, % "x" v_xNext "y" v_yNext "w" v_wNext
	v_yNext += HofEdit
	GuiControl, Move, % IdEdit7, % "x" v_xNext "y" v_yNext "w" v_wNext
	v_yNext += HofEdit
	GuiControl, Move, % IdEdit8, % "x" v_xNext "y" v_yNext "w" v_wNext
	
	v_yNext += HofEdit + c_ymarg
	v_xNext := c_xmarg
	GuiControl, Move, % IdText5, % "x" v_xNext "y" v_yNext
	v_yNext += HofText
	v_xNext := c_xmarg
	v_wNext := LeftColumnW - v_xNext
	GuiControl, Move, % IdEdit9, % "x" v_xNext "y" v_yNext "w" v_wNext
	
	v_yNext += HofEdit + c_ymarg
	v_xNext := c_xmarg
	GuiControl, Move, % IdText6, % "x" v_xNext "y" v_yNext
	GuiControlGet, v_OutVarTemp1, Pos, % IdText6
	GuiControlGet, v_OutVarTemp2, Pos, % IdButton1
	v_OutVarTemp := LeftColumnW - (v_OutVarTemp1W + v_OutVarTemp2W + 2 * c_xmarg)
	v_xNext := v_OutVarTemp1W + v_OutVarTemp
	v_wNext := v_OutVarTemp2W + 2 * c_xmarg
	GuiControl, Move, % IdButton1, % "x" v_xNext "y" v_yNext "w" v_wNext
	v_yNext += HofButton
	v_xNext := c_xmarg
	v_wNext := LeftColumnW - v_xNext
	GuiControl, Move, % IdDDL2, % "x" v_xNext "y" v_yNext "w" . v_wNext
	
	
	v_yNext += HofDropDownList + c_ymarg
	v_xNext := c_xmarg
	GuiControlGet, v_OutVarTemp1, Pos, % IdButton2
	GuiControlGet, v_OutVarTemp2, Pos, % IdButton3
	GuiControl, Move, % IdButton2, % "x" v_xNext "y" v_yNext
	v_xNext += v_OutVarTemp1W + c_xmarg
	GuiControl, Move, % IdButton3, % "x" v_xNext "y" v_yNext
	v_xNext += v_OutVarTemp2W + c_xmarg
	GuiControl, Move, % IdButton4, % "x" v_xNext "y" v_yNext
	v_yNext += HofButton
	LeftColumnH := v_yNext
;OutputDebug, % "LeftColumnH:" . A_Space . LeftColumnH
	
;5.3. Right column
;5.3.1. Position the text "Library content"
	v_yNext := c_ymarg
	v_xNext := LeftColumnW + c_xmarg + c_WofMiddleButton + c_xmarg
	GuiControl, Move, % IdText7, % "x" v_xNext "y" v_yNext
	
;5.3.2. Position of hotstring statistics (in this library: IdText11 / total: IdText2)
	GuiControlGet, v_OutVarTemp, Pos, % IdText7 ;text: Library content (F2)
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
	Gui,	MyAbout: Font,		% "s" . c_FontSize . A_Space . "bold underline" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, MyAbout: Add, 		Text,    x0 y0 HwndIdLink1 gGuiAboutLink1,										% TransA["Application help"]
	Gui, MyAbout: Add, 		Text,    x0 y0 HwndIdLink2 gGuiAboutLink2,										% TransA["Genuine hotstrings AutoHotkey documentation"]
	Gui,	MyAbout: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, 					% c_FontType
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
	GuiControlGet, v_OutVarTemp, Pos, % IdLine2
	v_yNext += v_OutVarTempH + c_ymarg
	GuiControl, Move, % IdLink1, % "x" v_xNext "y" v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdLink1
	v_yNext += v_OutVarTempH + c_ymarg
	GuiControl, Move, % IdLink2, % "x" v_xNext "y" v_yNext
	
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
			GuiControl, Hide, % IdLongest
			Break
		}
	}
	
	GuiControlGet, v_OutVarTemp1, Pos, % IdLongest ; weight of the longest text
	GuiControlGet, v_OutVarTemp2, Pos, % IdAboutOkButton 
	v_wNext := v_OutVarTemp2W + 2 * c_xmarg
	v_xNext := (v_OutVarTemp1W / 2) - (v_wNext / 2)
	v_yNext += v_OutVarTemp2H + c_ymarg
	GuiControl, Move, % IdAboutOkButton, % "x" v_xNext "y" v_yNext "w" v_wNext
	
	GuiControlGet, v_OutVarTemp1, Pos, % IdLine2
	v_xNext := v_OutVarTemp1X + v_OutVarTemp1W - 96 ;96 = chosen size of icon
	v_yNext := v_OutVarTemp1Y + v_OutVarTemp1H
	GuiControl, Move, % IdAboutPicture, % "x" v_xNext "y" v_yNext 
	
	return
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_GuiAbout()
{
	global ;assume-global mode
	local FoundPos := "", NewStr := ""
		,Window1X := 0, Window1Y := 0, Window1W := 0, Window1H := 0
		,Window2X := 0, Window2Y := 0, Window2W := 0, Window2H := 0
		,NewWinPosX := 0, NewWinPosY := 0
	
	NewStr := RegExReplace(TransA["About/Help (F1)"], "&", "")
	
	WinGetPos, Window1X, Window1Y, Window1W, Window1H, A
	Gui, MyAbout: Show, Hide Center AutoSize
	
	DetectHiddenWindows, On
	WinGetPos, Window2X, Window2Y, Window2W, Window2H, % "ahk_id" . MyAboutGuiHwnd
	DetectHiddenWindows, Off
	NewWinPosX := Round(Window1X + (Window1W / 2) - (Window2W / 2))
	NewWinPosY := Round(Window1Y + (Window1H / 2) - (Window2H / 2))
	;OutputDebug, % "Window2W:" . A_Space . Window2W . A_Space . "Window2H:" . A_Space . Window2H
	;OutputDebug, % "NewWinPosX:" . A_Space . NewWinPosX . A_Space . "NewWinPosY:" . A_Space . NewWinPosY
	Gui, MyAbout: Show, % "Center" . A_Space . "AutoSize" . A_Space . "x" . NewWinPosX . A_Space . "y" . NewWinPosY, % SubStr(A_ScriptName, 1, -4) . A_Space . NewStr
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
	
	IniRead, TempLoadLib,	Config.ini, LoadLibraries
	
	;Check if Libraries subfolder exists. If not, create it and display warning.
	v_IsLibraryEmpty := true
	if (!Instr(FileExist(A_ScriptDir . "\Libraries"), "D"))				; if  there is no "Libraries" subfolder 
	{
		MsgBox, 48, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["warning"], % TransA["There is no Libraries subfolder and no lbrary (*.csv) file exist!"] . "`n`n" . A_ScriptDir . "\Libraries\" . "`n`n" . TransA["folder is now created"] . "."
		FileCreateDir, %A_ScriptDir%\Libraries							; Future: check against errors
	}
	else
	{
		;Check if Libraries subfolder is empty. If it does, display warning.
		Loop, Files, Libraries\*.csv
		{
			v_IsLibraryEmpty := false
			break
		}
	}
	if (v_IsLibraryEmpty)
	{
		MsgBox, 52, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["warning"], % TransA["Libraries folder:"] . "`n`n" . A_ScriptDir . "\Libraries" . A_Space . "`n`n"
		. TransA["is empty. No (triggerstring, hotstring) definition will be loaded. Do you want to create the default library file: PriorityLibrary.csv?"]
		IfMsgBox, Yes
		{
			FileAppend, , % A_ScriptDir . "\Libraries\PriorityLibrary.csv", UTF-8
			F_ValidateIniLibSections()
		}
	}
	
	;Read names library files (*.csv) from Library subfolder into object.
	if !(v_IsLibraryEmpty)
		Loop, Files, Libraries\*.csv
			o_Libraries.Push(A_LoopFileName)
	
	;Check if Config.ini contains in section [Libraries] file names which are actually in library subfolder. Synchronize [Libraries] section with content of subfolder.
	;Parse the TempLoadLib.
	IniRead, TempLoadLib, Config.ini, LoadLibraries
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
	IniDelete, Config.ini, LoadLibraries
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
	
	IniWrite, % SectionTemp, Config.ini, LoadLibraries
	
	SectionTemp := ""
	;Check if Config.ini contains in section [ShowTipsLibraries] file names which are actually in library subfolder. Synchronize [Libraries] section with content of subfolder.
	;Parse the TempLoadLib.
	IniRead, TempShowTipsLib, Config.ini, ShowTipsLibraries
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
	IniDelete, Config.ini, ShowTipsLibraries
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
	
	IniWrite, % SectionTemp, Config.ini, ShowTipsLibraries
	return
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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
	Loop, Files, %A_ScriptDir%\Libraries\*.csv 
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

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

F_ini_StartHotstring(txt, nameoffile) 
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
			Case 3:
			Switch A_LoopField
			{
				Case "SI": 	SendFun := "F_NormalWay"
				Case "CL": 	SendFun := "F_ViaClipboard"
				Case "MCL": 	SendFun := "F_MenuCli"
				Case "MSI":	SendFun := "F_MenuAHK"
			}
			Case 4: 
			Switch A_LoopField
			{
				Case "En":	OnOff := "On"
				Case "Dis":	OnOff := "Off"	
			}
			Case 5:
			TextInsert := A_LoopField
			TextInsert := StrReplace(TextInsert, "``n", "`n") ;theese lines are necessary to handle rear definitions of hotstrings such as those finished with `n, `r etc.
			TextInsert := StrReplace(TextInsert, "``r", "`r")		
			TextInsert := StrReplace(TextInsert, "``t", "`t")
			TextInsert := StrReplace(TextInsert, "``", "`")
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
		;if !((Options == "") and (v_TriggerString == "") and (TextInsert == "") and (OnOff == ""))
	;if (Options and v_TriggerString and TextInsert and OnOff)
	if (v_TriggerString and OnOff)
	{
		Try
			Hotstring(":" . Options . ":" . v_TriggerString, func(SendFun).bind(TextInsert, Oflag), OnOff)
		Catch
			MsgBox, 16, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["Error"], % A_ThisFunc . A_Space . TransA["Something went wrong with hotstring deletion:"] . "`n`n"
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

F_AHKVariables(String)
{
	String := StrReplace(String, "A_YYYY", A_YYYY)
	String := StrReplace(String, "A_MMMM", A_MMMM)
	String := StrReplace(String, "A_MMM", A_MMM)
	String := StrReplace(String, "A_MM", A_MM)
	String := StrReplace(String, "A_DDDD", A_DDDD)
	String := StrReplace(String, "A_DDD", A_DDD)
	String := StrReplace(String, "A_DD", A_DD)
	String := StrReplace(String, "A_WDay", A_WDay)
	String := StrReplace(String, "A_YDay", A_YDay)
	String := StrReplace(String, "A_YWeek", A_YWeek)
	String := StrReplace(String, "A_Hour", A_Hour)
	String := StrReplace(String, "A_Min", A_Min)
	String := StrReplace(String, "A_Sec", A_Sec)
	String := StrReplace(String, "A_MSec", A_MSec)
	String := StrReplace(String, "A_Now", A_Now)
	String := StrReplace(String, "A_NowUTC", A_NowUTC)
	String := StrReplace(String, "A_TickCount", A_TickCount)
	return String
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

F_ChangingBrackets(string)
{
	occ := 1
	Loop
	{
		PosStart := InStr(string,"{",0,1,occ)
		if (PosStart)
		{
			PosEnd := InStr(string, "}", 0, 1, occ)
			WBrack := SubStr(string, PosStart, PosEnd-PosStart+1)
			If InStr(WBrack, "Backspace") or InStr(WBrack, "BS")
			{
				InBrack := ""
			}
			else
			{
				InBrack := SubStr(string, PosStart+1, PosEnd-PosStart-1)
				InBrack := Trim(InBrack)
			}
			string := StrReplace(string, WBrack, InBrack,0,-1)
			occ++
		}
		else
			break
	}
	return string
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

F_NormalWay(ReplacementString, Oflag)
{
	static InputLocaleID := false
	
	v_InputString := ""
	ToolTip,
	v_HotstringFlag := 1
	v_UndoTriggerstring := A_ThisHotkey
	ReplacementString := F_AHKVariables(ReplacementString)
	if (Oflag == 0)
		Send, % ReplacementString . A_EndChar
	else
		Send, %ReplacementString%
	v_UndoHotstring := % ReplacementString
	v_UndoHotstring := F_ChangingBrackets(v_UndoHotstring)
	SetFormat, Integer, H
	if (!InputLocaleID)	;special case; future: to be investigated if it wasn't related to bug in one of the previous versions of AutoHotkey
	{
		InputLocaleID := DllCall("GetKeyboardLayout", "UInt", 0, "UInt")
		Polish := Format("{:#x}", 0x415)
		InputLocaleID := InputLocaleID / 0xFFFF
		InputLocaleID := Format("{:#04x}", InputLocaleID)
	}
	if (InputLocaleID = "Polish")
		Send, {LCtrl up}
	
	if (InStr(A_ThisHotkey, "*"))
	{
		if (InStr(A_ThisHotkey,"*0"))
			v_TypedTriggerstring := % ReplacementString . A_Space
		else
			v_TypedTriggerstring := ReplacementString
	}
	else
		v_TypedTriggerstring := % ReplacementString . A_Space
	if (InStr(v_TypedTriggerstring, "{"))
		v_TypedTriggerstring := SubStr(v_TypedTriggerstring, InStr(v_TypedTriggerstring, "}")+1 , StrLen(v_TypedTriggerstring)-InStr(v_TypedTriggerstring, "}"))
	Hotstring("Reset")
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

F_ViaClipboard(ReplacementString, Oflag)
{
	global	;assume-global mode
	local oWord := ""
	
	v_InputString := ""
	ToolTip,
	v_UndoTriggerstring := A_ThisHotkey
	ReplacementString := F_AHKVariables(ReplacementString)
	v_UndoHotstring := ReplacementString
	ClipboardBackup := ClipboardAll
	Clipboard := ReplacementString
	ClipWait
	ifWinActive,, "Microsoft Word"
	{
		oWord := ComObjActive("Word.Application")
		oWord.Selection.Paste
		oWord := ""
	}
	else
	{
		Send, ^v
	}
	if (Oflag == 0)
		Send, % A_EndChar
	Sleep, %ini_Delay% ; this sleep is required surprisingly
	Clipboard := ClipboardBackup
	ClipboardBackup := ""
	v_TypedTriggerstring := ReplacementString
	Hotstring("Reset")
	v_HotstringFlag := 1
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_MenuCli(TextOptions, Oflag)	
{
	global	;assume-global mode
	local	MenuX	 := 0,	MenuY  	:= 0,	v_MouseX  := 0,	v_MouseY	:= 0
	
	v_MenuMax			 := 0
	v_InputString 		 := ""
	TextOptions 		 := F_AHKVariables(TextOptions)
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
	if (ini_MenuCaret)
	{
		CoordMode, Caret, Client ;CoordMode, Caret, Screen
		MenuX := A_CaretX + 20
		MenuY := A_CaretY - 20
	}
	if (ini_MenuCursor) or ((MenuX == "") and (MenuY == ""))
	{
		CoordMode, Mouse, Client	;CoordMode, Mouse, Screen
		MouseGetPos, v_MouseX, v_MouseY
		MenuX := v_MouseX + 20
		MenuY := v_MouseY + 20
	}
	
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
	local	OutputVarTemp := "",	MouseCtl := 0
	
	MouseGetPos, , , , MouseCtl, 2
	if ((A_GuiEvent = "Normal") and (MouseCtl = Id_LB_HMenuCli)) ;only ordinary mouse left click
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
		Sleep, %ini_Delay% ;Remember to sleep before restoring clipboard or it will fail
		v_TypedTriggerstring := OutputVarTemp
		v_UndoHotstring 	 := OutputVarTemp
		Clipboard 		 := ClipboardBack
		Hotstring("Reset")
	}
	return
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_MenuAHK(TextOptions, Oflag)	
{
	global	;assume-global mode
	local	MenuX	 := 0,	MenuY  	:= 0,	v_MouseX  := 0,	v_MouseY	:= 0
	
	v_MenuMax			 := 0
	v_InputString 		 := ""
	TextOptions 		 := F_AHKVariables(TextOptions)
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
	if (ini_MenuCaret)
	{
		CoordMode, Caret, Client ;CoordMode, Caret, Screen
		MenuX := A_CaretX + 20
		MenuY := A_CaretY - 20
	}
	if (ini_MenuCursor) or ((MenuX == "") and (MenuY == ""))
	{
		CoordMode, Mouse, Client	;CoordMode, Mouse, Screen
		MouseGetPos, v_MouseX, v_MouseY
		MenuX := v_MouseX + 20
		MenuY := v_MouseY + 20
	}
	
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
	local	OutputVarTemp := "",	MouseCtl := 0
	
	MouseGetPos, , , , MouseCtl, 2
	if ((A_GuiEvent = "Normal") and (MouseCtl = Id_LB_HMenuAHK)) ;only ordinary mouse left click
	{
		GuiControlGet, OutputVarTemp, , % Id_LB_HMenuAHK 
		v_HotstringFlag := true
		OutputVarTemp := SubStr(OutputVarTemp, 4)
		Gui, HMenuAHK: Destroy
		Send, % OutputVarTemp
		if (Ovar = false)
			Send, % A_EndChar
		v_TypedTriggerstring := OutputVarTemp
		v_UndoHotstring 	 := OutputVarTemp
		Hotstring("Reset")
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
			SoundBeep, % ini_SFrequency, % ini_SDuration	;Future: configurable parameters of the sound
		}
		if (IntCnt < 1)
		{
			IntCnt := 1
			SoundBeep, % ini_SFrequency, % ini_SDuration	;Future: configurable parameters of the sound
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
	;ClipboardBack := ClipboardAll ;backup clipboard
	ControlGet, v_Temp1, List, , , % "ahk_id" Id_LB_HMenuAHK
	Loop, Parse, v_Temp1, `n
	{
		if (InStr(A_LoopField, v_PressedKey . "."))
			v_Temp1 := SubStr(A_LoopField, 4)
	}
	
	;Clipboard := v_Temp1 
	;Send, ^v ;paste the text
	Send, % v_Temp1 
	if (Ovar = false)
		Send, % A_EndChar
	;Sleep, %ini_Delay% ;Remember to sleep before restoring clipboard or it will fail
	v_TypedTriggerstring := v_Temp1
	v_UndoHotstring 	 := v_Temp1
	;Clipboard 		 := ClipboardBack
	Hotstring("Reset")
	Gui, HMenuAHK: Destroy
	return
}

Esc::
	Gui, HMenuAHK: Destroy
	Send, % v_TriggerString
return
#If

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

F_CheckOption(State, Button)
;This function uses trick to identify specific GuiControl:
;ControlID can be either ClassNN (the classname and instance number of the control) or the control's text, both of which can be determined via Window Spy.
;So in HS3 Gui the checkboxes ClassNN are 1...6
{
	if (State = "Yes")
	{
		State := 1
		GuiControl, HS3:, Button%Button%, 1
		GuiControl, HS4:, Button%Button%, 1
	}
	else 
	{
		State := 0
		GuiControl, HS3:, Button%Button%, 0
		GuiControl, HS4:, Button%Button%, 0
	}
	Button := "Button" . Button
	
	F_CheckBoxColor(State, Button)  
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

F_CheckBoxColor(State, Button)
{
	global ;assume-global mode
	
	if (State = 1)
	{
		Gui, HS3: Font, % "s" . c_FontSize . A_Space . "cGreen Norm", % c_FontType
		Gui, HS4: Font, % "s" . c_FontSize . A_Space . "cGreen Norm", % c_FontType
	}
	else 
	{
		Gui, HS3: Font, % "s" . c_FontSize . A_Space . "c" . c_FontColor . A_Space . "Norm", % c_FontType
		Gui, HS4: Font, % "s" . c_FontSize . A_Space . "c" . c_FontColor . A_Space . "Norm", % c_FontType
	}
	GuiControl, HS3: Font, %Button%
	GuiControl, HS4: Font, %Button%
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
/*
	F_ShowMonitorNumbers()
	{
		global
		
		Loop, %N%
		{
			SysGet, MonitorBoundingCoordinates_, Monitor, %A_Index%
			Gui, %A_Index%:-SysMenu -Caption +Border +AlwaysOnTop
			Gui, %A_Index%:Color, Black ; WindowColor, ControlColor
			Gui, %A_Index%:Font, cWhite s26 bold, Calibri
			Gui, %A_Index%:Add, Text, x150 y150 w150 h150, % A_Index
			Gui, % A_Index . ":Show", % "x" .  MonitorBoundingCoordinates_Left + (Abs(MonitorBoundingCoordinates_Left - MonitorBoundingCoordinates_Right) / 2) - (300 / 2) . "y"
		   . MonitorBoundingCoordinates_Top + (Abs(MonitorBoundingCoordinates_Top - MonitorBoundingCoordinates_Bottom) / 2) - (300 / 2) . "w300" . "h300"
		}
		return
	}
*/

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

F_LoadEndChars() ;Load from Config.ini
{
	global
	
	HotstringEndChars := ""
	IniRead, EndingChar_Space, 				Config.ini, Configuration, EndingChar_Space
	IniRead, EndingChar_Minus, 				Config.ini, Configuration, EndingChar_Minus
	IniRead, EndingChar_ORoundBracket, 		Config.ini, Configuration, EndingChar_ORoundBracket
	IniRead, EndingChar_CRoundBracket, 		Config.ini, Configuration, EndingChar_CRoundBracket
	IniRead, EndingChar_OSquareBracket, 		Config.ini, Configuration, EndingChar_OSquareBracket
	IniRead, EndingChar_CSquareBracket, 		Config.ini, Configuration, EndingChar_CSquareBracket
	IniRead, EndingChar_OCurlyBracket, 		Config.ini, Configuration, EndingChar_OCurlyBracket
	IniRead, EndingChar_CCurlyBracket, 		Config.ini, Configuration, EndingChar_CCurlyBracket
	IniRead, EndingChar_Colon, 				Config.ini, Configuration, EndingChar_Colon
	IniRead, EndingChar_Semicolon, 			Config.ini, Configuration, EndingChar_Semicolon
	IniRead, EndingChar_Apostrophe, 			Config.ini, Configuration, EndingChar_Apostrophe
	IniRead, EndingChar_Quote, 				Config.ini, Configuration, EndingChar_Quote
	IniRead, EndingChar_Slash, 				Config.ini, Configuration, EndingChar_Slash
	IniRead, EndingChar_Backslash, 			Config.ini, Configuration, EndingChar_Backslash
	IniRead, EndingChar_Comma, 				Config.ini, Configuration, EndingChar_Comma
	IniRead, EndingChar_Dot, 				Config.ini, Configuration, EndingChar_Dot
	IniRead, EndingChar_QuestionMark, 			Config.ini, Configuration, EndingChar_QuestionMark
	IniRead, EndingChar_ExclamationMark, 		Config.ini, Configuration, EndingChar_ExclamationMark
	IniRead, EndingChar_Enter, 				Config.ini, Configuration, EndingChar_Enter
	IniRead, EndingChar_Tab, 				Config.ini, Configuration, EndingChar_Tab
	IniRead, EndingChar_Underscore,			Config.ini, Configuration, EndingChar_Underscore
	if (EndingChar_Space)
		HotstringEndChars .= " "
	if (EndingChar_Minus)
		HotstringEndChars .= "-"
	if (EndingChar_ORoundBracket)
		HotstringEndChars .= "("
	if (EndingChar_CRoundBracket)
		HotstringEndChars .= ")"
	if (EndingChar_OSquareBracket)
		HotstringEndChars .= "["
	if (EndingChar_CSquareBracket)
		HotstringEndChars .= "]"
	if (EndingChar_OCurlyBracket)
		HotstringEndChars .= "{"
	if (EndingChar_CCurlyBracket)
		HotstringEndChars .= "}"
	if (EndingChar_Colon)
		HotstringEndChars .= ":"
	if (EndingChar_Semicolon)
		HotstringEndChars .= ";"
	if (EndingChar_Apostrophe)
		HotstringEndChars .= "'"
	if (EndingChar_Quote)
		HotstringEndChars .= """"
	if (EndingChar_Slash)
		HotstringEndChars .= "/"
	if (EndingChar_Backslash)
		HotstringEndChars .= "\"
	if (EndingChar_Comma)
		HotstringEndChars .= ","
	if (EndingChar_Dot)
		HotstringEndChars .= "."
	if (EndingChar_QuestionMark)
		HotstringEndChars .= "?"
	if (EndingChar_ExclamationMark)
		HotstringEndChars .= "!"
	if (EndingChar_Enter)
		HotstringEndChars .= "`n"
	if (EndingChar_Tab)
		HotstringEndChars .= "`t"
	if (EndingChar_Underscore)
		HotstringEndChars .= "_"
	Hotstring("EndChars", HotstringEndChars)
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
	v_OutputFile := % A_ScriptDir . "\Libraries\" . OutNameNoExt . ".csv"
	
	if (FileExist(v_OutputFile))
	{
		MsgBox, 52, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["warning"], % TransA["Such file already exists"] . ":" . "`n`n" . v_OutputFile . "`n`n" . TransA["Do you want to delete it?"] . "`n`n" 
			. TransA["If you answer ""Yes"", the existing file will be deleted. This is recommended choice. If you answer ""No"", new content will be added to existing file."]
		IfMsgBox, Yes	;check if it was loaded. if yes, recommend restart of application, because "Total" counter and Hotstrings definitions will be incredible. Future: at first disable existing Hotstrings definitions and then reduce total counter.
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
		IniWrite, % ini_GuiReload,		Config.ini, GraphicalUserInterface, GuiReload
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
	FileSelectFile, v_LibraryName, 3, % A_ScriptDir . "\Libraries", % TransA["Choose library file (.csv) for export"], CSV Files (*.csv)]
	if (!v_LibraryName)
		return
	
	SplitPath, v_LibraryName, OutFileName, , , OutNameNoExt
	v_LibrariesDir := % A_ScriptDir . "\ExportedLibraries"
	if !InStr(FileExist(v_LibrariesDir),"D")
		FileCreateDir, %v_LibrariesDir%
	v_OutputFile := % A_ScriptDir . "\ExportedLibraries\" . OutNameNoExt . "." . "ahk"
	
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
	FileSelectFile, v_LibraryName, 3, % A_ScriptDir . "\Libraries", % TransA["Choose library file (.csv) for export"], CSV Files (*.csv)]
	if (!v_LibraryName)
		return
	
	SplitPath, v_LibraryName, OutFileName, , , OutNameNoExt
	v_LibrariesDir := % A_ScriptDir . "\ExportedLibraries"
	if !InStr(FileExist(v_LibrariesDir),"D")
		FileCreateDir, %v_LibrariesDir%
	v_OutputFile := % A_ScriptDir . "\ExportedLibraries\" . OutNameNoExt . "." . "ahk"
	
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

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -





; --------------------------- SECTION OF LABELS ---------------------------


TurnOffTooltip:
ToolTip ,
return

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
	IniWrite, % ini_GuiReload,		Config.ini, GraphicalUserInterface, GuiReload
	
	Switch ini_WhichGui
	{
		Case "HS3":
		if (!(ini_HS3WindoPos["X"]) or !(ini_HS3WindoPos["Y"]))
		{
			Gui, HS3: Show, AutoSize Center
			v_ResizingFlag := false
			return
		}
		if (!(ini_HS3WindoPos["W"]) or !(ini_HS3WindoPos["H"]))
		{
						;one of the Windows mysteries, why I need to run the following line twice if c_FontSize > 10
			Gui,	HS3: Show, % "X" . ini_HS3WindoPos["X"] . A_Space . "Y" . ini_HS3WindoPos["Y"] . A_Space . "AutoSize"
			Gui,	HS3: Show, % "X" . ini_HS3WindoPos["X"] . A_Space . "Y" . ini_HS3WindoPos["Y"] . A_Space . "AutoSize"
			v_ResizingFlag := false
			return
		}
		Gui,	HS3: Show, % "X" . ini_HS3WindoPos["X"] . A_Space . "Y" . ini_HS3WindoPos["Y"] . A_Space . "W" . ini_HS3WindoPos["W"] . A_Space . "H" . ini_HS3WindoPos["H"]
		v_ResizingFlag := false
		return
		Case "HS4":
		if (!(ini_HS3WindoPos["W"]) or !(ini_HS3WindoPos["H"]))
		{
					;one of the Windows mysteries, why I need to run the following line twice if c_FontSize > 10
			Gui,	HS4: Show, % "X" . ini_HS3WindoPos["X"] . A_Space . "Y" . ini_HS3WindoPos["Y"] . A_Space . "AutoSize"
			Gui,	HS4: Show, % "X" . ini_HS3WindoPos["X"] . A_Space . "Y" . ini_HS3WindoPos["Y"] . A_Space . "AutoSize"
			v_ResizingFlag := false
			return
		}
		if (!(ini_HS3WindoPos["X"]) or !(ini_HS3WindoPos["Y"]))
		{
			Gui, HS4: Show, AutoSize Center
			v_ResizingFlag := false
			return
		}
		Gui,	HS4: Show, % "X" . ini_HS3WindoPos["X"] . A_Space . "Y" . ini_HS3WindoPos["Y"] . A_Space . "W" . ini_HS3WindoPos["W"] . A_Space . "H" . ini_HS3WindoPos["H"]
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
IfNotExist, Libraries\%v_NewLib%
{
	FileAppend,, Libraries\%v_NewLib%, UTF-8
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

MySlider:
ini_Delay := MySlider
GuiControl,, DelayText, % TransA["Clipboard paste delay in [ms]:"] . A_Space . ini_Delay . "`n`n" . TransA["This option is valid"]
IniWrite, %ini_Delay%, Config.ini, Configuration, Delay
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
~F1::
AboutOkButton:
MyAboutGuiEscape:
MyAboutGuiClose: ; Showed when the window is closed by pressing its X button in the title bar.
Gui, MyAbout: Hide
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; Future: save window position
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
Gui, HSDel:Destroy
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

MonGuiEscape:
MonGuiClose:
Gui, Mon:Destroy
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

L_Undo:
Menu, Submenu1, ToggleCheck, % TransA["Undo the last hotstring"]
ini_Undo := !(ini_Undo)
IniWrite, %ini_Undo%, Config.ini, Configuration, UndoHotstring
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Tips:
Menu, SubmenuTips, ToggleCheck, % TransA["Enable/Disable"]
Menu, SubmenuTips, ToggleEnable, % TransA["Choose tips location"]
Menu, SubmenuTips, ToggleEnable, % TransA["Number of characters for tips"]
ini_Tips := !(ini_Tips)
IniWrite, %ini_Tips%, Config.ini, Configuration, Tips
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

EndSpace:
Menu, Submenu2, ToggleCheck, % TransA["Space"]
EndingChar_Space := !(EndingChar_Space)
IniWrite, %EndingChar_Space%, Config.ini, Configuration, EndingChar_Space
F_LoadEndChars()
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

EndMinus:
Menu, Submenu2, ToggleCheck, % TransA["Minus -"]
EndingChar_Minus := !(EndingChar_Minus)
IniWrite, %EndingChar_Minus%, Config.ini, Configuration, EndingChar_Minus
F_LoadEndChars()
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

EndORoundBracket:
Menu, Submenu2, ToggleCheck, % TransA["Opening Round Bracket ("]
EndingChar_ORoundBracket := !(EndingChar_ORoundBracket)
IniWrite, %EndingChar_ORoundBracket%, Config.ini, Configuration, EndingChar_ORoundBracket
F_LoadEndChars()
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

EndCRoundBracket:
Menu, Submenu2, ToggleCheck, % TransA["Closing Round Bracket )"]
EndingChar_CRoundBracket := !(EndingChar_CRoundBracket)
IniWrite, %EndingChar_CRoundBracket%, Config.ini, Configuration, EndingChar_CRoundBracket
F_LoadEndChars()
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

EndOSquareBracket:
Menu, Submenu2, ToggleCheck, % TransA["Opening Square Bracket ["]
EndingChar_OSquareBracket := !(EndingChar_OSquareBracket)
IniWrite, %EndingChar_OSquareBracket%, Config.ini, Configuration, EndingChar_OSquareBracket
F_LoadEndChars()
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

EndCSquareBracket:
Menu, Submenu2, ToggleCheck, % TransA["Closing Square Bracket ]"]
EndingChar_CSquareBracket := !(EndingChar_CSquareBracket)
IniWrite, %EndingChar_CSquareBracket%, Config.ini, Configuration, EndingChar_CSquareBracket
F_LoadEndChars()
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

EndOCurlyBracket:
Menu, Submenu2, ToggleCheck, % TransA["Opening Curly Bracket {"]
EndingChar_OCurlyBracket := !(EndingChar_OCurlyBracket)
IniWrite, %EndingChar_OCurlyBracket%, Config.ini, Configuration, EndingChar_OCurlyBracket
F_LoadEndChars()
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

EndCCurlyBracket:
Menu, Submenu2, ToggleCheck, % TransA["Closing Curly Bracket }"]
EndingChar_CCurlyBracket := !(EndingChar_CCurlyBracket)
IniWrite, %EndingChar_CCurlyBracket%, Config.ini, Configuration, EndingChar_CCurlyBracket
F_LoadEndChars()
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

EndColon:
Menu, Submenu2, ToggleCheck,% TransA["Colon :"]
EndingChar_Colon := !(EndingChar_Colon)
IniWrite, %EndingChar_Colon%, Config.ini, Configuration, EndingChar_Colon
F_LoadEndChars()
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

EndSemicolon:
Menu, Submenu2, ToggleCheck, % TransA["Semicolon `;"]
EndingChar_Semicolon := !(EndingChar_Semicolon)
IniWrite, %EndingChar_Semicolon%, Config.ini, Configuration, EndingChar_Semicolon
F_LoadEndChars()
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

EndApostrophe:
Menu, Submenu2, ToggleCheck, % TransA["Apostrophe '"]
EndingChar_Apostrophe := !(EndingChar_Apostrophe)
IniWrite, %EndingChar_Apostrophe%, Config.ini, Configuration, EndingChar_Apostrophe
F_LoadEndChars()
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

EndQuote:
Menu, Submenu2, ToggleCheck, % TransA["Quote """]
EndingChar_Quote := !(EndingChar_Quote)
IniWrite, %EndingChar_Quote%, Config.ini, Configuration, EndingChar_Quote
F_LoadEndChars()
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

EndSlash:
Menu, Submenu2, ToggleCheck, % TransA["Slash /"]
EndingChar_Slash := !(EndingChar_Slash)
IniWrite, %EndingChar_Slash%, Config.ini, Configuration, EndingChar_Slash
F_LoadEndChars()
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

EndBackslash:
Menu, Submenu2, ToggleCheck, % TransA["Backslash \"]
EndingChar_Backslash := !(EndingChar_Backslash)
IniWrite, %EndingChar_Backslash%, Config.ini, Configuration, EndingChar_Backslash
F_LoadEndChars()
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

EndComma:
Menu, Submenu2, ToggleCheck, % TransA["Comma ,"]
EndingChar_Comma := !(EndingChar_Comma)
IniWrite, %EndingChar_Comma%, Config.ini, Configuration, EndingChar_Comma
F_LoadEndChars()
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

EndDot:
Menu, Submenu2, ToggleCheck, % TransA["Dot ."]
EndingChar_Dot := !(EndingChar_Dot)
IniWrite, %EndingChar_Dot%, Config.ini, Configuration, EndingChar_Dot
F_LoadEndChars()
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

EndQuestionMark:
Menu, Submenu2, ToggleCheck, % TransA["Question Mark ?"]
EndingChar_QuestionMark := !(EndingChar_QuestionMark)
IniWrite, %EndingChar_QuestionMark%, Config.ini, Configuration, EndingChar_QuestionMark
F_LoadEndChars()
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

EndExclamationMark:
Menu, Submenu2, ToggleCheck, % TransA["Exclamation Mark !"]
EndingChar_ExclamationMark := !(EndingChar_ExclamationMark)
IniWrite, %EndingChar_ExclamationMark%, Config.ini, Configuration, EndingChar_ExclamationMark
F_LoadEndChars()
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

EndEnter:
Menu, Submenu2, ToggleCheck, % TransA["Enter"]
EndingChar_Enter := !(EndingChar_Enter)
IniWrite, %EndingChar_Enter%, Config.ini, Configuration, EndingChar_Enter
F_LoadEndChars()
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

EndTab:
Menu, Submenu2, ToggleCheck, % TransA["Tab"]
EndingChar_Tab := !(EndingChar_Tab)
IniWrite, %EndingChar_Tab%, Config.ini, Configuration, EndingChar_Tab
F_LoadEndChars()
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

EndUnderscore:
Menu, Submenu2, ToggleCheck, % TransA["Underscore _"]
EndingChar_Underscore := !(EndingChar_Underscore)
Iniwrite, %EndingChar_Underscore%, Config.ini, Configuration, EndingChar_Underscore
F_LoadEndChars()
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
L_AmountOfCharacterTips1:
ini_AmountOfCharacterTips := 1
gosub, L_AmountOfCharacterTips
return

L_AmountOfCharacterTips2:
ini_AmountOfCharacterTips := 2
gosub, L_AmountOfCharacterTips
return

L_AmountOfCharacterTips3:
ini_AmountOfCharacterTips := 3
gosub, L_AmountOfCharacterTips
return

L_AmountOfCharacterTips4:
ini_AmountOfCharacterTips := 4
gosub, L_AmountOfCharacterTips
return

L_AmountOfCharacterTips5:
ini_AmountOfCharacterTips := 5
gosub, L_AmountOfCharacterTips
return

L_AmountOfCharacterTips:
IniWrite, %ini_AmountOfCharacterTips%, Config.ini, Configuration, TipsChars
Menu, Submenu4, Check, %ini_AmountOfCharacterTips%
Loop, 5
{
	if !(A_Index == ini_AmountOfCharacterTips)
		Menu, Submenu4, UnCheck, %A_Index%
}
return
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
L_CaretCursor:
Menu, Submenu3, ToggleCheck, % TransA["Caret"]
Menu, Submenu3, ToggleCheck, % TransA["Cursor"]
ini_Caret := !(ini_Caret)
ini_Cursor := !(ini_Cursor)
IniWrite, %ini_Caret%, Config.ini, Configuration, Caret
IniWrite, %ini_Cursor%, Config.ini, Configuration, Cursor
return

L_MenuCaretCursor:
Menu, PositionMenu, ToggleCheck, % TransA["Caret"]
Menu, PositionMenu, ToggleCheck, % TransA["Cursor"]
ini_MenuCaret := !(ini_MenuCaret)
ini_MenuCursor := !(ini_MenuCursor)
IniWrite, %ini_MenuCaret%, Config.ini, Configuration, MenuCaret
IniWrite, %ini_MenuCursor%, Config.ini, Configuration, MenuCursor
return

L_MenuSound:
Menu, SubmenuMenu, ToggleCheck, % TransA["Enable sound if overrun"]
ini_MenuSound := !(ini_MenuSound)
IniWrite, %ini_MenuSound%, Config.ini, Configuration, MenuSound
return


L_SortTipsAlphabetically:
Menu, SubmenuTips, ToggleCheck, % TransA["Sort tips alphabetically"]
ini_TipsSortAlphabetically := !(ini_TipsSortAlphabetically)
IniWrite, %ini_TipsSortAlphabetically%, Config.ini, Configuration, TipsSortAlphatebically
return

L_SortTipsByLength:
Menu, SubmenuTips, ToggleCheck, % TransA["Sort tips by length"]
ini_TipsSortByLength := !(ini_TipsSortByLength)
IniWrite, %ini_TipsSortByLength%, Config.ini, Configuration, TipsSortByLength
return

L_ChangeLanguage:
ini_Language := A_ThisMenuitem
IniWrite, %ini_Language%, Config.ini, Configuration, Language
Loop, %A_ScriptDir%\Languages\*.ini
{
	Menu, SubmenuLanguage, Add, %A_LoopFileName%, L_ChangeLangage
	if (ini_Language == A_LoopFileName)
		Menu, SubmenuLanguage, Check, %A_LoopFileName%
	else
		Menu, SubmenuLanguage, UnCheck, %A_LoopFileName%
}
MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"],  % TransA["Application language changed to:"] . A_Space 
		. SubStr(ini_Language, 1, -4) . "`n`n" . TransA["The application will be reloaded with the new language file."]
Reload

L_TraySuspendHotkeys:
Suspend, Toggle
if (A_IsSuspended)
	Menu, Tray, Check,   % TransA["Suspend Hotkeys"]
else
	Menu, Tray, UnCheck, % TransA["Suspend Hotkeys"]
return

L_TrayPauseScript:
Pause, Toggle, 1
if (A_IsPaused)
	Menu, Tray, Check,	 % TransA["Pause Script"]
else
	Menu, Tray, UnCheck, % TransA["Pause Script"]
return

L_TrayExit:
ExitApp, 2	;2 = by Tray

L_TrayReload:	;new thread starts here
F_WhichGui()
F_Reload()
return