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


; 1. Prepare variables which can be used to create the default .ini files (Config.ini and English.ini).
; 2. Try to load up configuration files. If those files do not exist, create them.
; 3. Load configuration files into configuration variables. The configuration variable names start with "ini_" prefix.
; 4. Load definitions of (triggerstring, hotstring) from Library subfolder.

; 1. Prepare variables which can be used to create the default .ini files (Config.ini and English.ini).
ConfigIni = 					; variable which is used as default content of Config.ini
	(
[Configuration]
SizeOfHotstringsWindow_Width=
SizeOfHotstringsWindow_Height=
SizeOfHotstringsWindow_X=
SizeOfHotstringsWindow_Y=
UndoHotstring=1
Delay=300
Sandbox=1
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
Tips=1
Cursor=0
Caret=1
TipsChars=1
MenuCursor=0
MenuCaret=1
TipsSortAlphatebically=1
TipsSortByLength=1
Language=English.txt
[TipsLibraries]
	)

global v_Param 				:= A_Args[1] ; the only one parameter of Hotstrings app available to user
global v_PreviousSection 		:= A_Args[2]
global v_PreviousWidth 			:= A_Args[3]
global v_PreviousHeight 			:= A_Args[4]
global v_PreviousX 				:= A_Args[5]
global v_PreviousY 				:= A_Args[6]
global v_SelectedRow 			:= A_Args[7]
global v_PreviousMonitor 		:= A_Args[8]
global a_Comment 				:= []
global a_EnableDisable 			:= []
global a_Hotstring				:= []
global a_Library 				:= []
global a_LibraryCnt				:= [] ;Hotstring counter for specific libraries
global a_OutputFunction 			:= []
global a_SelectedTriggers 		:= []
global a_String 				:= ""
global a_TriggerOptions 			:= []
global a_Triggers 				:= []
global a_Triggerstring 			:= []
global ini_AmountOfCharacterTips 	:= ""
global ini_Caret 				:= ""
global ini_Cursor 				:= ""
global ini_Delay 				:= ""
global ini_MenuCaret 			:= ""
global ini_MenuCursor 			:= ""
global ini_MenuSound 			:= ""
global ini_Sandbox				:= 1	; as in new-created Config.ini
global ini_Tips 				:= ""
global ini_TipsSortAlphabetically 	:= ""
global ini_TipsSortByLength 		:= ""
global v_CaseSensitiveC1 		:= ""
global v_BlockHotkeysFlag		:= 0
global v_DeleteHotstring 		:= ""
global v_EnterHotstring 			:= ""
global v_EnterHotstring1 		:= ""
global v_EnterHotstring2 		:= ""
global v_EnterHotstring3 		:= ""
global v_EnterHotstring4 		:= ""
global v_EnterHotstring5 		:= ""
global v_EnterHotstring6 		:= ""
global v_FlagSound 				:= 0
;I couldn't find how to get system settings for size of menu font. Quick & dirty solution: manual setting of all fonts with variable c_FontSize.
global v_HotstringCnt 			:= 0
global v_HotstringFlag 			:= 0
global v_HS3ListFlag 			:= 0
global v_IndexLog 				:= 1
global v_InputString 			:= ""
global v_Language 				:= ""	; OutputVar for IniRead funtion
global v_LibraryContent 			:= ""
global v_MenuMax 				:= 0
global v_MenuMax2 				:= 0
global v_MonitorFlag 			:= 0
global v_MouseX 				:= ""
global v_MouseY 				:= ""
global v_OptionCaseSensitive 		:= 0	;The checkbox's associated output variable (if any) receives the number 1 for checked, 0 for unchecked, and -1 for gray/indeterminate
global v_OptionDisable 			:= 0 ;The checkbox's associated output variable (if any) receives the number 1 for checked, 0 for unchecked, and -1 for gray/indeterminate
global v_OptionImmediateExecute 	:= 0 ;The checkbox's associated output variable (if any) receives the number 1 for checked, 0 for unchecked, and -1 for gray/indeterminate
global v_OptionInsideWord 		:= 0 ;The checkbox's associated output variable (if any) receives the number 1 for checked, 0 for unchecked, and -1 for gray/indeterminate
global v_OptionNoBackspace 		:= 0 ;The checkbox's associated output variable (if any) receives the number 1 for checked, 0 for unchecked, and -1 for gray/indeterminate
global v_OptionNoEndChar 		:= 0 ;The checkbox's associated output variable (if any) receives the number 1 for checked, 0 for unchecked, and -1 for gray/indeterminate
global v_RadioGroup 			:= ""
global v_SearchTerm 			:= ""
global v_SelectedRow2 			:= 0
global v_SelectFunction 			:= ""
global v_SelectHotstringLibrary 	:= ""
global v_SelectedMonitor			:= 0
global v_ShortcutsMainInterface 	:= ""
;global v_ShowGui 				:= 0
global v_Tips 					:= ""
global v_TipsFlag 				:= 0
global v_TriggerString 			:= ""
global v_TypedTriggerstring 		:= ""
global v_UndoHotstring 			:= ""
global v_UndoTriggerstring 		:= ""
;global v_ViewString 			:= ""
global v_String				:= ""
global v_ConfigFlag 			:= 0

;Future: configuration parameters
global c_FontSize 				:= 10 ;points
global c_xmarg					:= 10 ;pixels
global c_ymarg					:= 10 ;pixels
global c_FontType				:= "Calibri"
global c_FontColor				:= "Black"
global c_FontColorHighlighted		:= "Blue"
global c_WindowColor			:= "Default"
global c_ControlColor 			:= "Default"

;Flags to control application
global v_ResizingFlag 			:= 1 ; when Hotstrings Gui is displayed for the very first time
global IsSandboxMoved			:= false
global CntGuiSize				:= 0
global v_ToggleRightColumn		:= false ;memory of last state of the IdButton5 (ToggleRightColumn)
global v_LibHotstringCnt			:= 0 ;no of (triggerstring, hotstring) definitions in single library


; 2. Try to load up configuration files. If those files do not exist, create them.
if (!FileExist("Config.ini"))
{
	MsgBox, 0x30, % A_ScriptName . " Warning", Config.ini wasn't found. The default Config.ini is now created in location %A_ScriptDir%.
	FileAppend, %ConfigIni%, Config.ini
}


IniRead v_Language, Config.ini, Configuration, Language				; Load from Config.ini file specific parameter: language into variable v_Language, e.g. v_Language = English.ini

if ( !Instr(FileExist(A_ScriptDir . "\Languages"), "D"))				; if  there is no "Languages" subfolder 
{
	MsgBox, 48, % SubStr(A_ScriptName, 1, -4) . " warning", There is no Languages subfolder and no language file exists!`nThe default %A_ScriptDir%\Languages\English.ini file is now created
	.`nMind that Config.ini Language variable is equal to %v_Language%.
	FileCreateDir, %A_ScriptDir%\Languages							; Future: check against errors
	FileAppend, %EnglishIni%, %A_ScriptDir%\Languages\English.ini		; Future: check against erros.
	F_LoadCreateTranslationTxt("create")
}
else  if (!FileExist(A_ScriptDir . "\Languages\" . v_Language))			; else if there is no v_language .ini file, e.g. v_langugae == Polish.ini and there is no such file in Languages folder
{
	MsgBox, 48, % SubStr(A_ScriptName, 1, -4) . " warning", There is no %v_Language% file in Languages subfolder!`nThe default %A_ScriptDir%\Languages\English.ini file is now created.
	FileAppend, %EnglishIni%, %A_ScriptDir%\Languages\English.ini		; Future: check against erros.
	F_LoadCreateTranslationTxt("create")
	v_Language 		:= "English.ini"					
}
else
	F_LoadCreateTranslationTxt("load")

; 3. Load configuration files into configuration variables. The configuration variable names start with "ini_" prefix.
;Read all variables from specified language .ini file. In order to distinguish GUI text from any other string or variable used in this script, the GUI strings are defined with prefix "t_".


; - - - - - - - - - - - - - - - - - - - - - - - G L O B A L    V A R I A B L E S - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

IniRead, ini_StartX, 						Config.ini, Configuration, SizeOfHotstringsWindow_X
IniRead, ini_StartY, 						Config.ini, Configuration, SizeOfHotstringsWindow_Y
IniRead, ini_StartW, 						Config.ini, Configuration, SizeOfHotstringsWindow_Width
IniRead, ini_StartH, 						Config.ini, Configuration, SizeOfHotstringsWindow_Height

IniRead, ini_Undo, 							Config.ini, Configuration, UndoHotstring
IniRead, ini_Delay, 						Config.ini, Configuration, Delay
IniRead, ini_Sandbox, 						Config.ini, Configuration, Sandbox
b_SandboxResize := ini_Sandbox
if (ini_Sandbox)
	IsSandboxMoved := false
;IniRead, ini_MenuSound,					Config.ini, Configuration, MenuSound	; Future

; Read from Config.ini values of EndChars. Modifies the set of characters used as ending characters by the hotstring recognizer.
F_LoadEndChars()

IniRead, ini_Tips, 						Config.ini, Configuration, Tips
IniRead, ini_Cursor, 					Config.ini, Configuration, Cursor
IniRead, ini_Caret, 					Config.ini, Configuration, Caret
IniRead, ini_AmountOfCharacterTips, 		Config.ini, Configuration, TipsChars
IniRead, ini_MenuCursor, 				Config.ini, Configuration, MenuCursor
IniRead, ini_MenuCaret, 					Config.ini, Configuration, MenuCaret
IniRead, ini_TipsSortAlphabetically,		Config.ini, Configuration, TipsSortAlphatebically
IniRead, ini_TipsSortByLength,			Config.ini, Configuration, TipsSortByLength

F_LoadTipsLibraries() ; load from / to Config.ini

; Hotstrings app could be reloaded by itself, (see label Delete:). In such a case 9 command line parameters are passed
;if !(A_Args[8])
if (v_SelectedRow == "")
	v_SelectedRow := 0
;else
	;v_SelectedRow := A_Args[8]
;if !(v_PreviousMonitor)
if (v_PreviousMonitor == "")
	v_SelectedMonitor := 0
else
	v_SelectedMonitor := v_PreviousMonitor


;if !(v_PreviousSection)
/*
	if (v_PreviousSection == "")
		v_ShowGui := 1
	else
		v_ShowGui := 2
*/


; 4. Load definitions of (triggerstring, hotstring) from Library subfolder.
/*
	v_BlockHotkeysFlag := 1 ; Block hotkeys of this application for the time when (triggerstring, hotstring) definitions are uploaded from liberaries.
	F_LoadHotstringsFromLibraries() 
	F_LoadLibrariesToTables() 
	v_BlockHotkeysFlag := 0
*/


F_HS3_CreateObjects()
F_HS3_DefineConstants()
F_HS3_DetermineConstraints()

	; Prepare TrayTip message taking into account value of command line parameter.
	if (v_Param == "d")
		TrayTip, %A_ScriptName% - Debug mode, 	% TransA["Loading hotstrings from libraries..."], 1
	else if (v_Param == "l")
		TrayTip, %A_ScriptName% - Lite mode, 	% TransA["Loading hotstrings from libraries..."], 1
	else	
		TrayTip, %A_ScriptName%,				% TransA["Loading hotstrings from libraries..."], 1
	

	v_HotstringCnt := 0
	Loop, Files, %A_ScriptDir%\Libraries\*.csv
	{
		if !(A_LoopFileName == "PriorityLibrary.csv")
			F_LoadFile(A_LoopFileName)
	}
	F_LoadFile("PriorityLibrary.csv")

	TrayTip, %A_ScriptName%, % TransA["Hotstrings have been loaded"], 1
	;Gui, HS3:Show
	;Pause




; After definitions of (triggerstring, hotstring) are uploaded to memory, prepare (System)Tray icon
if !(v_Param == "l") 										; if Hotstrings.ahk wasn't run with "l" parameter (standing for "light / lightweight", prepare tray menu.
{
	Menu, Tray, Add, 		% TransA["Edit Hotstring"], 		L_GUIInit
	Menu, Tray, Add, 		% TransA["Search Hotstrings"], 	L_Searching
	Menu, Tray, Default, 	% TransA["Edit Hotstring"]
	Menu, Tray, Add										; separator line
	Menu, Tray, NoStandard									; remove all the rest of standard tray menu
	Menu, Tray, Standard									; add it again at the bottom
}

/*
	if (v_PreviousSection)
		Gosub L_GUIInit 
*/

;If the script is run with command line parameter "d" like debug, prepare new folder and create file named as specified in the following pattern.
if (v_Param == "d")
{	
	FileCreateDir, Logs
	v_LogFileName := % "Logs\Logs" . A_DD . A_MM . "_" . A_Hour . A_Min . ".txt"
	FileAppend, , %v_LogFileName%, UTF-8
}

; Multi monitor environment, initialization of monitor width and height parameters
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


Loop, %A_ScriptDir%\Libraries\*.csv
	GuiControl, , v_SelectHotstringLibrary, %A_LoopFileName% ; GuiControl (Blank): Puts new contents into control


    ; Menu, HSMenu, Add, &Monitor, CheckMon
Menu, Submenu1, 	Add, % TransA["Undo the last hotstring"],	L_Undo
Menu, SubmenuTips, 	Add, % TransA["Enable/Disable"], 			Tips
Menu, PositionMenu, Add, % TransA["Caret"], 					L_MenuCaretCursor
Menu, PositionMenu, Add, % TransA["Cursor"], 				L_MenuCaretCursor
Menu, SubmenuMenu, 	Add, % TransA["Choose menu position"],		:PositionMenu
Menu, SubmenuMenu, 	Add, % TransA["Enable sound if overrun"],	L_MenuSound
if (ini_MenuSound)
	Menu, SubmenuMenu, Check, % TransA["Enable sound if overrun"]
else
	Menu, SubmenuMenu, UnCheck, % TransA["Enable sound if overrun"]
Menu, Submenu1, 	Add, % TransA["Hotstring menu (MSI, MCL)"], :SubmenuMenu
if (ini_MenuCursor)
	Menu, PositionMenu, Check, % TransA["Cursor"]
else
	Menu, PositionMenu, UnCheck, % TransA["Cursor"]
if (ini_MenuCaret)
	Menu, PositionMenu, Check, % TransA["Caret"]
else
	Menu, PositionMenu, UnCheck, % TransA["Caret"]
Menu, Submenu1, 	Add, % TransA["Triggerstring tips"], 	:SubmenuTips
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
Menu, Submenu1, Add, % TransA["Save window position"], 	SavePos
Menu, Submenu1, Add, % TransA["Launch Sandbox"], 			L_Sandbox
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
Menu, Submenu1, Add, % TransA["Toggle EndChars"], :Submenu2

if (ini_Tips == 0)
	Menu, SubmenuTips, UnCheck, % TransA["Enable/Disable"]
else
	Menu, SubmenuTips, Check, % TransA["Enable/Disable"]

if (ini_Sandbox == 0)
	Menu, Submenu1, UnCheck, % TransA["Launch Sandbox"]
else
	Menu, Submenu1, Check, % TransA["Launch Sandbox"]

if (ini_Undo == 0)
	Menu, Submenu1, UnCheck, % TransA["Undo the last hotstring"]
else
	Menu, Submenu1, Check, % TransA["Undo the last hotstring"]

Loop, %A_ScriptDir%\Languages\*.ini
{
	Menu, SubmenuLanguage, Add, %A_LoopFileName%, L_ChangeLanguage
	if (v_Language == A_LoopFileName)
		Menu, SubmenuLanguage, Check, %A_LoopFileName%
	else
		Menu, SubmenuLanguage, UnCheck, %A_LoopFileName%
}

Menu, Submenu1, 		Add, % TransA["Change Language"], 			:SubmenuLanguage
Menu, HSMenu, 			Add, % TransA["Configuration"], 			:Submenu1
Menu, HSMenu, 			Add, % TransA["Search Hotstrings"], 		L_Searching
Menu, LibrariesSubmenu, 	Add, % TransA["Import from .ahk to .csv"],	L_ImportLibrary
Menu, ExportSubmenu, 	Add, % TransA["Static hotstrings"],  		L_ExportLibraryStatic
Menu, ExportSubmenu, 	Add, % TransA["Dynamic hotstrings"],  		L_ExportLibraryDynamic
Menu, LibrariesSubmenu, 	Add, % TransA["Export from .csv to .ahk"],	:ExportSubmenu

Loop, %A_ScriptDir%\Libraries\*.csv
{
	Menu, ToggleLibrariesSubmenu, Add, %A_LoopFileName%, L_ToggleTipsLibrary
	IniRead, v_LibraryFlag, Config.ini, TipsLibraries, %A_LoopFileName%
	if (v_LibraryFlag)
		Menu, ToggleLibrariesSubmenu, Check, %A_LoopFileName%
	else
		Menu, ToggleLibrariesSubmenu, UnCheck, %A_LoopFileName%	
}
Menu, 	LibrariesSubmenu, 	Add, % TransA["Enable/disable triggerstring tips"], 	:ToggleLibrariesSubmenu 
Menu, 	HSMenu, 			Add, % TransA["Libraries configuration"], 			:LibrariesSubmenu
Menu, 	HSMenu, 			Add, % TransA["Clipboard Delay"], 					HSdelay
Menu, 	HSMenu, 			Add, % TransA["About/Help"], 						L_About
Gui, 	HS3:Menu, HSMenu



;end of defining the Hotstrings Gui


;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; Beginning of the main loop of application.
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Loop,
{
	Input, out, V L1, {Esc} ; V = Visible, L1 = Length 1
	if (ErrorLevel = "NewInput")
		MsgBox, % TransA["ErrorLevel was triggered by NewInput error."]
	
	; if exist window with hotstring tips, output sound
	if (WinExist("Hotstring listbox") or WinExist("HotstringAHK listbox"))
	{
		if (ini_MenuSound)
		{
			if (v_FlagSound == 0)
				; Future: configurable parameters of the sound
				SoundBeep, 400, 200
			v_FlagSound := 0
		}
	}
	else
	{
		v_InputString .= out
		if (v_HotstringFlag)
		{
			v_InputString := ""
			ToolTip,
			if !(WinExist("Hotstring listbox") or WinExist("HotstringAHK listbox"))
				v_HotstringFlag := 0
		}
		if InStr(HotstringEndChars, out)
		{
			v_TipsFlag := 0
			Loop, % a_Triggers.MaxIndex()
			{
				if (InStr(a_Triggers[A_Index], v_InputString))
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
				if (InStr(a_Triggers[A_Index], v_InputString))
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
					If InStr(a_Triggers[A_Index], v_InputString) == 1
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
				a_SelectedTriggers := F_SortArrayAlphabetically(a_SelectedTriggers)
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

Pause::Pause, Toggle

~BackSpace:: 
	if (WinExist("Hotstring listbox") or WinExist("HotstringAHK listbox"))
	{
		if (ini_MenuSound)
		{
			if (v_FlagSound == 0)
				SoundBeep, 400, 200
			v_FlagSound := 0
		}
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
				a_SelectedTriggers := F_SortArrayAlphabetically(a_SelectedTriggers)
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
			Send, % "{BackSpace " . StrLen(v_TypedTriggerstring) . "}" . SubStr(A_PriorHotkey, InStr(A_PriorHotkey, ":", v_OptionCaseSensitive := false, StartingPos := 1, Occurrence := 2) + 1)
		else
			Send, % "{BackSpace " . StrLen(v_UndoHotstring) . "}" . SubStr(v_UndoTriggerstring, InStr(v_UndoTriggerstring, ":", v_OptionCaseSensitive := false, StartingPos := 1, Occurrence := 2) + 1)
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

#if WinExist("Hotstrings") and WinExist("ahk_class AutoHotkeyGUI") ; the following hotkeys will be active only if Hotstrings windows exist at the moment.

~^c::			; copy to edit field "Enter hotstring" content of Clipboard.
	Sleep, %ini_Delay%
	ControlSetText, Edit2, %Clipboard%
	return
#if

#if WinActive("Hotstrings") and WinActive("ahk_class AutoHotkeyGUI") ; the following hotkeys will be active only if Hotstrings windows are active at the moment. 

F1::
	Gui, HS3:Default
	Goto, L_About
	; return
	
F2::
	Gui, HS3:Default
	Gui, HS3:Submit, NoHide
	if (v_SelectHotstringLibrary == "")
	{
		;Future: center this MsgBox on current screen.
		MsgBox, % TransA["Select hotstring library"]
		return
	}
	GuiControl, Focus, v_LibraryContent
	if (LV_GetNext(0,"Focused") == 0)
		LV_Modify(1, "+Select +Focus")
return

^f::
^s::
F3::
	Gui, HS3:Default
	Goto, L_Searching
; return

F5::
Gui, HS3:Default
goto, Clear
; return

F7::
Gui, HS3:Default
goto, HSdelay
; return

F8::
Gui, HS3:Default
;goto, Delete
F_DeleteHotstring()
return

F9::
Gui, HS3:Default
;goto, AddHotstring
F_AddHotstring()
return

#if

; ms on 2020-11-02
~Alt::
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


#if WinActive("Search Hotstrings") and WinActive("ahk_class AutoHotkeyGUI")

F8::
Gui, HS3List:Default
goto, MoveList
#if
; ------------------------- SECTION OF FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------------------

F_LoadCreateTranslationTxt(decision*)
{
	
	;EnglishIni =  	; variable which is used as default content of Languages/English.ini. Join lines with `n separator and escape all ` occurrences. Thanks to that string lines where 'n is present 'aren't separated.
	;(Join`n `
;[Strings]
	global ;assume-global mode
	
	TransA := {"About/Help"	 										: "&About/Help"
			,"Add comment (optional)" 								: "Add comment (optional)"
			,"Add library" 										: "Add library"
			,"A library with that name already exists!" 					: "A library with that name already exists!"
			,"Apostrophe '" 										: "Apostrophe '"
			,"Application help" 									: "Application help"
			,"Application language changed to:" 						: "Application language changed to:"
			,"Backslash \" 										: "Backslash \"
			,"Cancel" 											: "Cancel"
			,"Caret" 												: "Caret"
			,"Case Sensitive (C)" 									: "Case Sensitive (C)"
			,"Change Language" 										: "Change Language"
			,"Choose library file (.ahk) for import" 					: "Choose library file (.ahk) for import"
			,"Choose library file (.csv) for export" 					: "Choose library file (.csv) for export"
			,"Choose menu position" 									: "Choose menu position"
			,"Choose section before saving!" 							: "Choose section before saving!"
			,"Choose sending function!" 								: "Choose sending function!"
			,"Choose the method of sending the hotstring!" 				: "Choose the method of sending the hotstring!"
			,"Choose tips location" 									: "Choose tips location"
			,"Clear (F5)" 											: "Clear (F5)"
			,"Clipboard Delay" 										: "Clipboard &Delay"
			,"Closing Curly Bracket }" 								: "Closing Curly Bracket }"
			,"Closing Round Bracket )" 								: "Closing Round Bracket )"
			,"Closing Square Bracket ]" 								: "Closing Square Bracket ]"
			,"Colon :" 											: "Colon :"
			,"Comma ," 											: "Comma ,"
			,"Configuration" 										: "&Configuration"
			,"Do you want to proceed?" 								: "Do you want to proceed?"
			,"Cursor" 											: "Cursor"
			,"Delete hotstring (F8)" 								: "Delete hotstring (F8)"
			,"Deleting hotstring..." 								: "Deleting hotstring..."
			,"Deleting hotstring. Please wait..." 						: "Deleting hotstring. Please wait..."
			,"Disable" 											: "Disable"
			,"Dot ." 												: "Dot ."
			,". Do you want to proceed?" 								: ". Do you want to proceed?"
			,"Dynamic hotstrings" 									: "&Dynamic hotstrings"
			,"Edit Hotstring" 										: "Edit Hotstring"
			,"Enable/Disable" 										: "Enable/Disable"
			,"Enable/disable triggerstring tips" 						: "Enable/disable triggerstring tips"	
			,"Enables Convenient Definition" 							: "Enables convenient definition and use of hotstrings (triggered by shortcuts longer text strings). `nThis is 3rd edition of this application, 2020 by Jakub Masiak and Maciej Słojewski (🐘). `nLicense: GNU GPL ver. 3."
			,"Enable sound if overrun" 								: "Enable &sound if overrun"
			,"Enter" 												: "Enter"
			,"Enter a name for the new library" 						: "Enter a name for the new library"
			,"Enter hotstring" 										: "Enter hotstring"
			,"Enter triggerstring" 									: "Enter triggerstring"
			,"ErrorLevel was triggered by NewInput error." 				: "ErrorLevel was triggered by NewInput error."
			,"Exclamation Mark !" 									: "Exclamation Mark !"
			,"exists in a file" 									: "exists in a file"
			,"Export from .csv to .ahk" 								: "&Export from .csv to .ahk"
			,"F1 About/Help | F2 Library content | F3 Search hotstrings | F5 Clear | F7 Clipboard Delay | F8 Delete hotstring | F9 Set hotstring" : "F1 About/Help | F2 Library content | F3 Search hotstrings | F5 Clear | F7 Clipboard Delay | F8 Delete hotstring | F9 Set hotstring"
			,"F3 Close Search hotstrings | F8 Move hotstring" 			: "F3 Close Search hotstrings | F8 Move hotstring"
			,"file!" 												: "file!"
			,"Genuine hotstrings AutoHotkey documentation" 				: "Genuine hotstrings AutoHotkey documentation"
			,"has been created." 									: "has been created."
			,"Hotstring" 											: "Hotstring"
			,"Hotstring has been deleted. Now application will restart itself in order to apply changes, reload the libraries (.csv)" : "Hotstring has been deleted. Now application will restart itself in order to apply changes, reload the libraries (.csv)"
			,"Hotstring menu (MSI, MCL)" 								: "Hotstring menu (MSI, MCL)"
			,"Hotstring moved to the" 								: "Hotstring moved to the"
			,"Hotstring paste from Clipboard delay 1 s" 					: "Hotstring paste from Clipboard delay 1 s"
			,"Hotstring paste from Clipboard delay" 					: "Hotstring paste from Clipboard delay"
			,"Hotstrings have been loaded" 							: "Hotstrings have been loaded"
			,"Immediate Execute (*)" 								: "Immediate Execute (*)"
			,"Import from .ahk to .csv" 								: "&Import from .ahk to .csv"
			,"Inside Word (?)" 										: "Inside Word (?)"
			,"Launch Sandbox" 										: "&Launch Sandbox"
			,"Let's make your PC personal again..." 					: "Let's make your PC personal again..."
			,"Libraries configuration" 								: "&Libraries configuration"
			,"Library" 											: "Library"
			,"Library export. Please wait..." 							: "Library export. Please wait..."
			,"Library has been exported." 							: "Library has been exported."
			,"Library has been imported." 							: "Library has been imported."
			,"Library import. Please wait..." 							: "Library import. Please wait..."
			,"Library|Triggerstring|Trigger Options|Output Function|Enable/Disable|Hotstring|Comment" : "Library|Triggerstring|Trigger Options|Output Function|Enable/Disable|Hotstring|Comment"
			,"Loaded hotstrings:" 									: "Loaded hotstrings:"
			,"Loading hotstrings from libraries..." 					: "Loading hotstrings from libraries..."
			,"Loading libraries. Please wait..." 						: "Loading libraries. Please wait..."
			,"Minus -" 											: "Minus -"
			,"Move" 												: "Move"
			,"No Backspace (B0)" 									: "No Backspace (B0)"
			,"No End Char (O)" 										: "No End Char (O)"
			,"Number of characters for tips" 							: "&Number of characters for tips"
			,"Opening Curly Bracket {" 								: "Opening Curly Bracket {"
			,"Opening Round Bracket (" 								: "Opening Round Bracket ("
			,"Opening Square Bracket [" 								: "Opening Square Bracket ["
			,"Please wait, uploading .csv files..." 					: "Please wait, uploading .csv files..."
			,"Question Mark ?" 										: "Question Mark ?"
			,"Quote """ 											: "Quote """
			,"Replacement text is blank. Do you want to proceed?" 			: "Replacement text is blank. Do you want to proceed?"
			,"Sandbox" 											: "Sandbox"
			,"Save window position"	 								: "&Save window position"
			,"Search by:" 											: "Search by:"
			,"Search Hotstrings" 									: "&Search Hotstrings"
			,"Select a row in the list-view, please!" 					: "Select a row in the list-view, please!"
			,"Selected file is empty." 								: "Selected file is empty."
			,"Selected Hotstring will be deleted. Do you want to proceed?" 	: "Selected Hotstring will be deleted. Do you want to proceed?"
			,"Select hotstring library" 								: "Select hotstring library"
			,"Select hotstring output function" 						: "Select hotstring output function"
			,"Select the target library:" 							: "Select the target library:"
			,"Select trigger option(s)" 								: "Select trigger option(s)"
			,"Semicolon `;" 										: "Semicolon `;"
			,"Set hotstring (F9)" 									: "Set hotstring (F9)"
			,"Slash /" 											: "Slash /"
			,"Sort tips alphabetically" 								: "Sort tips &alphabetically"
			,"Sort tips by length" 									: "Sort tips by &length"
			,"Space" 												: "Space"
			,"Static hotstrings" 									: "&Static hotstrings"
			,"Tab" 												: "Tab"
			,"The application will be reloaded with the new language file." 	: "The application will be reloaded with the new language file."
			,"The hostring" 										: "The hostring"
			,"The library " 										: "The library "
			,"The file path is:" 									: "The file path is:"
			,"Toggle EndChars"	 									: "&Toggle EndChars"
			,"Triggerstring" 										: "Triggerstring"
			,"Triggerstring tips" 									: "&Triggerstring tips"
			,"Triggerstring|Trigg Opt|Out Fun|En/Dis|Hotstring|Comment" 	: "Triggerstring|Trigg Opt|Out Fun|En/Dis|Hotstring|Comment"
			,"Undo the last hotstring" 								: "&Undo the last hotstring"
			,"Library content (F2)"									: "Library content (F2)"}
		
	
	local key := "", val := "", tick := false
	
	
	if (decision[1] = "create")
		for key, val in TransA
			FileAppend, % key . A_Space . "=" . A_Space . val . "`n", %A_ScriptDir%\Languages\English.txt, UTF-8 
	
	;*[One]
	if (decision[1] = "load")
		Loop, Read, %A_ScriptDir%\Languages\%v_Language%
		{
			tick := false
			Loop, Parse, A_LoopReadLine, "=", %A_Space%
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
; ------------------------------------------------------------------------------------------------------------------------------------

F_LoadFile(nameoffile)
{
	global ;assume-global mode
	local name := "", tabSearch := "", line := ""
	
	Loop
	{
		FileReadLine, line, %A_ScriptDir%\Libraries\%nameoffile%, %A_Index%
		if (ErrorLevel)
			break
		tabSearch := StrSplit(line, "‖")	
		name := SubStr(A_LoopFileName, 1, -4) ;filename without extension
		
		/*			
			line := StrReplace(line, "``n", "`n")
			line := StrReplace(line, "``r", "`r")		
			line := StrReplace(line, "``t", "`t")
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
		*/			
		
		a_Library.Push(name) ; function Search
		a_TriggerOptions.Push(tabSearch[1])
		a_Triggerstring.Push(tabSearch[2]) 
		a_OutputFunction.Push(tabSearch[3])
		a_EnableDisable.Push(tabSearch[4])
		a_Hotstring.Push(tabSearch[5]) 
		a_Comment.Push(tabSearch[6])
		;a_Triggers.Push(v_TriggerString) ; a_Triggers is used in main loop of application for generating tips
		a_Triggers.Push(tabSearch[2]) ; a_Triggers is used in main loop of application for generating tips
		
		F_ini_StartHotstring(line, nameoffile)
		;v_HotstringCnt++
		GuiControl, Text, % IdText2, % v_LoadedHotstrings . A_Space . ++v_HotstringCnt ; •(Blank): Puts new contents into the control.
		;OutputDebug, % "Content of IdText2 GuiControl:" . A_Space . v_LoadedHotstrings . A_Space . v_HotstringCnt
		
	}
	a_LibraryCnt.Push(v_HotstringCnt)
	return
}

; ------------------------------------------------------------------------------------------------------------------------------------

F_HS3_CreateObjects()
{
	global ;assume-global mode
	local x0 := 0, y0 := 0
	
	
;1. Definition of HS3 GUI.
;-DPIScale doesn't work in Microsoft Windows 10
;+Border doesn't work in Microsoft Windows 10
;OwnDialogs
	Gui, 		HS3:New, 		+Resize +HwndHS3Hwnd +OwnDialogs -MaximizeBox, % SubStr(A_ScriptName, 1, -4)
	Gui, 		HS3:Margin,	% c_xmarg, % c_ymarg
	Gui,			HS3:Color,	% c_WindowColor, % c_ControlColor
	
;2. Prepare all text objects according to mock-up.
	Gui,			HS3:Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, 		HS3:Add, 		Text, 		x0 y0 HwndIdText1, 									% TransA["Enter triggerstring"]
;GuiControl, 	Hide, 		% IdText1
	Gui,			HS3:Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, % c_FontType
	
	Gui, 		HS3:Add, 		Text, 		x0 y0 HwndIdText2 vv_LoadedHotstrings, % "Total:     0" ;Future: to be translated
	
	Gui, 		HS3:Add, 		Edit, 		x0 y0 HwndIdEdit1 vv_TriggerString 
;GuiControl,	Hide,		% IdEdit1
	
	Gui, 		HS3:Add, 		CheckBox, 	x0 y0 HwndIdCheckBox1 gCapsCheck vv_OptionImmediateExecute,	% TransA["Immediate Execute (*)"]
;GuiControl,	Hide,		% IdCheckBox1
	Gui, 		HS3:Add,		CheckBox, 	x0 y0 HwndIdCheckBox2 gCapsCheck vv_OptionCaseSensitive,	% TransA["Case Sensitive (C)"]
;GuiControl,	Hide,		% IdCheckBox2
	Gui, 		HS3:Add,		CheckBox, 	x0 y0 HwndIdCheckBox3 gCapsCheck vv_OptionNoBackspace,		% TransA["No Backspace (B0)"]
;GuiControl,	Hide,		% IdCheckBox3
	Gui, 		HS3:Add,		CheckBox, 	x0 y0 HwndIdCheckBox4 gCapsCheck vv_OptionInsideWord, 		% TransA["Inside Word (?)"]
;GuiControl,	Hide,		% IdCheckBox4
	Gui, 		HS3:Add,		CheckBox, 	x0 y0 HwndIdCheckBox5 gCapsCheck vv_OptionNoEndChar, 		% TransA["No End Char (O)"]
;GuiControl,	Hide,		% IdCheckBox5
	Gui, 		HS3:Add, 		CheckBox, 	x0 y0 HwndIdCheckBox6 gCapsCheck vv_OptionDisable, 		% TransA["Disable"]
;GuiControl,	Hide,		% IdCheckBox6
	
	Gui,			HS3:Add,		GroupBox, 	x0 y0 HwndIdGroupBox1, 								% TransA["Select trigger option(s)"]
;GuiControl,	Hide,		% IdGroupBox1
	
	Gui,			HS3:Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, 		HS3:Add, 		Text, 		x0 y0 HwndIdText3 vv_TextSelectHotstringsOutFun, 			% TransA["Select hotstring output function"]
;GuiControl,	Hide,		% IdText3
	Gui,			HS3:Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, % c_FontType
	
	Gui, 		HS3:Add, 		DropDownList, 	x0 y0 HwndIdDDL1 vv_SelectFunction gL_SelectFunction, 		SendInput (SI)||Clipboard (CL)|Menu & SendInput (MSI)|Menu & Clipboard (MCL)
;GuiControl,	Hide,		% IdDDL1
	
	Gui,			HS3:Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, 		HS3:Add, 		Text, 		x0 y0 HwndIdText4 vv_TextEnterHotstring, 				% TransA["Enter hotstring"]
;GuiControl,	Hide,		% IdText4
	Gui,			HS3:Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, % c_FontType
	
	Gui, 		HS3:Add, 		Edit, 		x0 y0 HwndIdEdit2 vv_EnterHotstring
;GuiControl,	Hide,		% IdEdit2
	Gui, 		HS3:Add, 		Edit, 		x0 y0 HwndIdEdit3 vv_EnterHotstring1  Disabled
;GuiControl,	Hide,		% IdEdit3
	Gui, 		HS3:Add, 		Edit, 		x0 y0 HwndIdEdit4 vv_EnterHotstring2  Disabled
;GuiControl,	Hide,		% IdEdit4
	Gui, 		HS3:Add, 		Edit, 		x0 y0 HwndIdEdit5 vv_EnterHotstring3  Disabled
;GuiControl,	Hide,		% IdEdit5
	Gui, 		HS3:Add, 		Edit, 		x0 y0 HwndIdEdit6 vv_EnterHotstring4  Disabled
;GuiControl,	Hide,		% IdEdit6
	Gui, 		HS3:Add, 		Edit, 		x0 y0 HwndIdEdit7 vv_EnterHotstring5  Disabled
;GuiControl,	Hide,		% IdEdit7
	Gui, 		HS3:Add, 		Edit, 		x0 y0 HwndIdEdit8 vv_EnterHotstring6  Disabled
;GuiControl,	Hide,		% IdEdit8
	
	Gui,			HS3:Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, 		HS3:Add, 		Text, 		x0 y0 HwndIdText5 vv_TextAddComment, 					% TransA["Add comment (optional)"]
;GuiControl,	Hide,		% IdText5
	Gui,			HS3:Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, % c_FontType
	
	Gui, 		HS3:Add, 		Edit, 		x0 y0 HwndIdEdit9 vv_Comment Limit64 ; future: change name to vv_Comment, align with other 
;GuiControl,	Hide,		% IdEdit9
	
	Gui,			HS3:Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, 		HS3:Add, 		Text, 		x0 y0 HwndIdText6 vv_TextSelectHotstringLibrary, 			% TransA["Select hotstring library"]
;GuiControl,	Hide,		% IdText6
	Gui,			HS3:Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, % c_FontType
	
	Gui, 		HS3:Add, 		Button, 		x0 y0 HwndIdButton1 gAddLib, 							% TransA["Add library"]
;GuiControl,	Hide,		% IdButton1
	Gui,			HS3:Add,		DropDownList,	x0 y0 HwndIdDDL2 vv_SelectHotstringLibrary gF_SectionChoose
;GuiControl,	Hide,		% IdDDL2
	
;Gui,			HS3:Font,		% "s" . c_FontSize . A_Space . "bold cBlack", % c_FontType
	Gui, 		HS3:Add, 		Button, 		x0 y0 HwndIdButton2 gF_AddHotstring,						% TransA["Set hotstring (F9)"]
;GuiControl,	Hide,		% IdButton2
	Gui, 		HS3:Add, 		Button, 		x0 y0 HwndIdButton3 gClear,							% TransA["Clear (F5)"]
;GuiControl,	Hide,		% IdButton3
	Gui, 		HS3:Add, 		Button, 		x0 y0 HwndIdButton4 gF_DeleteHotstring vv_DeleteHotstring Disabled, 	% TransA["Delete hotstring (F8)"]
;GuiControl,	Hide,		% IdButton4
	
	Gui,			HS3:Add,		Button,		x0 y0 HwndIdButton5 gF_ToggleRightColumn vv_ToggleRightColumn,			⯇
;GuiControl,	Hide,		% IdButton5
	
;Gui,			HS3:Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, % c_FontType
	
	Gui,			HS3:Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, 		HS3:Add, 		Text, 		x0 y0 HwndIdText7,		 							% TransA["Library content (F2)"]
;GuiControl,	Hide,		% IdText7
	Gui,			HS3:Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, % c_FontType
	
	Gui,			HS3:Add, 		Text, 		x0 y0 HwndIdText9, 									% TransA["Triggerstring|Trigg Opt|Out Fun|En/Dis|Hotstring|Comment"]
;GuiControl,	Hide,		% IdText9
	Gui, 		HS3:Add, 		ListView, 	x0 y0 HwndIdListView1 LV0x1 vv_LibraryContent AltSubmit gHSLV, % TransA["Triggerstring|Trigg Opt|Out Fun|En/Dis|Hotstring|Comment"]
;GuiControl,	Hide,		% IdListView1
	
	Gui, 		HS3:Add, 		Text, 		x0 y0 HwndIdText8 vv_ShortcutsMainInterface, 				% TransA["F1 About/Help | F2 Library content | F3 Search hotstrings | F5 Clear | F7 Clipboard Delay | F8 Delete hotstring | F9 Set hotstring"]
;GuiControl,	Hide,		% IdText8
	
	Gui,			HS3:Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, 		HS3:Add, 		Text, 		x0 y0 HwndIdText10 vv_SandString, 						% TransA["Sandbox"]
;GuiControl,	Hide,		% IdText10
	Gui,			HS3:Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, % c_FontType
	
	Gui, 		HS3:Add, 		Edit, 		x0 y0 HwndIdEdit10 vv_Sandbox r3 						; r3 = 3x rows of text
;GuiControl,	Hide,		% IdEdit10
;Gui, 		HS3:Add, 		Edit, 		HwndIdEdit11 vv_ViewString gViewString ReadOnly Hide
	Gui,			HS3:Add,		Text,		x0 y0 HwndIdText11 vv_NoOfHotstringsInLibrary, % "Hotstrings:    0"
}

; ------------------------------------------------------------------------------------------------------------------------------------

F_HS3_DefineConstants()
{
	global ;assume-global mode
;Within a function, to create a set of variables that is local instead of global, declare OutputVar as a local variable prior to using command GuiControlGet, Pos. However, it is often also necessary to declare each variable in the set, due to a common source of confusion.	
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

F_HS3_DetermineConstraints()
{
	global ;assume-global mode
;Within a function, to create a set of variables that is local instead of global, declare OutputVar as a local variable prior to using command GuiControlGet, Pos. However, it is often also necessary to declare each variable in the set, due to a common source of confusion.
	local v_OutVarTemp := 0, 	v_OutVarTempX := 0, 	v_OutVarTempY := 0, 	v_OutVarTempW := 0, 	v_OutVarTempH := 0
		,v_OutVarTemp1 := 0, 	v_OutVarTemp1X := 0, 	v_OutVarTemp1Y := 0, 	v_OutVarTemp1W := 0, 	v_OutVarTemp1H := 0
		,v_OutVarTemp2 := 0, 	v_OutVarTemp2X := 0, 	v_OutVarTemp2Y := 0, 	v_OutVarTemp2W := 0, 	v_OutVarTemp2H := 0
		,v_OutVarTemp3 := 0, 	v_OutVarTemp3X := 0, 	v_OutVarTemp3Y := 0, 	v_OutVarTemp3W := 0, 	v_OutVarTemp3H := 0
							,v_xNext := 0, 		v_yNext := 0, 			v_wNext := 0, 			v_hNext := 0
	
	
;4. Determine constraints, according to mock-up
	
	GuiControlGet, v_OutVarTemp1, Pos, % IdButton2
	GuiControlGet, v_OutVarTemp2, Pos, % IdButton3
	GuiControlGet, v_OutVarTemp3, Pos, % IdButton4
	
	LeftColumnW := c_xmarg + v_OutVarTemp1W + c_xmarg + v_OutVarTemp2W + c_xmarg + v_OutVarTemp3W
	OutputDebug, % "IdButton2:" . A_Space . IdButton2 . A_Space . "IdButton3:" . A_Space . IdButton3 . A_Space . "IdButton4:" . A_Space . IdButton4
	OutputDebug, % "v_OutVarTemp1W:" . A_Space . v_OutVarTemp1W  . A_Space . "v_OutVarTemp2W:" . A_Space . v_OutVarTemp2W . A_Space . "v_OutVarTemp3W:" . A_Space .  v_OutVarTemp3W  . A_Space . "c_xmarg:" . A_Space c_xmarg
	OutputDebug, % "LeftColumnW:" . A_Space . LeftColumnW
	
	GuiControlGet, v_OutVarTemp1, Pos, % IdText8
	GuiControlGet, v_OutVarTemp2, Pos, % IdText9
	v_OutVarTemp3 := Max(v_OutVarTemp1W, v_OutVarTemp2W) ;longer of two texts
	RightColumnW := v_OutVarTemp3
	
	
;5. Move text objects to correct position
;5.1. Left column
;5.1.1. Enter triggerstring
	v_yNext := c_ymarg
	v_xNext := c_xmarg
	GuiControl, Move, % IdText1, % "x" v_xNext "y" v_yNext
	;GuiControl, Show, % IdText1
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
	v_hNext := HofText + 3 * HofCheckBox + c_ymarg
	GuiControl, Move, % IdGroupBox1, % "x" v_xNext "y" v_yNext "w" v_wNext "h" v_hNext
	;GuiControl, Show, % IdGroupBox1
	
	v_yNext += HofText
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
	
;Gui, 		%HS3Hwnd%:Show, AutoSize Center
	
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
	OutputDebug, % "LeftColumnH:" . A_Space . LeftColumnH
	
;5.2. Button between left and right column
	v_yNext := c_ymarg
	v_xNext := LeftColumnW + c_xmarg
	v_hNext := LeftColumnH - c_ymarg
	GuiControl, Move, % IdButton5, % "x" v_xNext "y" v_yNext "h" v_hNext
	
;5.3. Right column
;5.3.1. Position the text "Library content"
	v_yNext := c_ymarg
	v_xNext := LeftColumnW + c_xmarg + c_WofMiddleButton + c_xmarg
	GuiControl, Move, % IdText7, % "x" v_xNext "y" v_yNext
	
;5.3.2. Position of hotstring statistics (in this library: IdText11 / total: IdText2)
	GuiControlGet, v_OutVarTemp, Pos, % IdText7
	v_xNext += v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdText11, % "x" v_xNext "y" v_yNext
	GuiControlGet, v_OutVarTemp, Pos, % IdText11
	v_xNext += v_OutVarTempW + 2 * c_xmarg
	GuiControl, Move, % IdText2, % "x" v_xNext "y" v_yNext
	
;5.3.2. Position the only one List View 
	GuiControlGet, v_OutVarTemp1, Pos, % IdEdit10 ; height of Sandbox edit field
	GuiControlGet, v_OutVarTemp2, Pos, % IdListView1
	v_xNext := LeftColumnW + c_xmarg + c_WofMiddleButton + c_xmarg
	v_yNext += HofText
;v_xNext := LeftColumnW + c_xmarg
	v_wNext := RightColumnW
	if (ini_Sandbox)
		v_hNext := LeftColumnH - (v_OutVarTemp1H + HofText * 3 + c_ymarg * 3)
	else
	{
		v_hNext := LeftColumnH - (HofText * 2 + c_ymarg * 2)
		GuiControl, Hide, % IdText10
		GuiControl, Hide, % IdEdit10
	}
	GuiControl, Move, % IdListView1, % "x" v_xNext "y" v_yNext "w" v_wNext "h" v_hNext
	
	GuiControl, Hide, % IdText9
	
;5.3.3. Text Sandbox
	GuiControlGet, v_OutVarTemp, Pos, % IdListView1
	if (ini_Sandbox)
	{
		v_yNext += v_OutVarTempH + c_ymarg
	;v_xNext := LeftColumnW + c_xmarg
		GuiControl, Move, % IdText10, % "x" v_xNext "y" v_yNext
;5.2.4. Sandbox edit text field
		v_yNext += HofText
	;v_xNext := LeftColumnW + c_xmarg
		v_wNext := RightColumnW
		GuiControl, Move, % IdEdit10, % "x" v_xNext "y" v_yNext "w" v_wNext
	}
	
;5.3.5. Position of the long text F1 ... F2 ...
;v_xNext := LeftColumnW + c_xmarg
	v_yNext += c_HofSandbox + c_ymarg
	GuiControl, Move, % IdText8, % "x" v_xNext "y" v_yNext
	
	;Gui, 		%HS3Hwnd%:Show, AutoSize Center
	
;6. Counters
;6.1. Total counter:
	GuiControlGet, v_LoadedHotstrings,, % IdText2
	;OutputDebug, % "v_LoadedHotstrings from control:" . A_Space . v_LoadedHotstrings
	v_LoadedHotstrings := SubStr(v_LoadedHotstrings, 1, -4)
	;OutputDebug, % "v_LoadedHotstrings to control:" . A_Space . v_LoadedHotstrings
	GuiControl, Text, % IdText2, % v_LoadedHotstrings 
	;GuiControlGet, v_LoadedHotstrings,, % IdText2
	;OutputDebug, % "v_LoadedHotstrings from control:" . A_Space . v_LoadedHotstrings
;6.2. Counter of hotstrings in specificlibrary
	GuiControlGet, v_NoOfHotstringsInLibrary,, % IdText11
	v_NoOfHotstringsInLibrary := SubStr(v_NoOfHotstringsInLibrary, 1, -4)
	GuiControl, Text, % IdText11, % v_NoOfHotstringsInLibrary
}



; ------------------------------------------------------------------------------------------------------------------------------------

F_LoadTipsLibraries() ; Load from / to Config.ini from Libraries folder
{
	IniRead, v_TipsConfig, 					Config.ini, TipsLibraries		; Read into v_TipsConfig section TipsLibraries from the file Config.ini which is a list of library files (.csv) stored in Libraries subfolder
	
	;Check if Libraries subfolder exists. If not, create it and display warning.
	v_IsLibraryEmpty := true
	if (!Instr(FileExist(A_ScriptDir . "\Libraries"), "D"))				; if  there is no "Libraries" subfolder 
	{
		MsgBox, 48, % SubStr(A_ScriptName, 1, -4) . " warning", There is no Libraries subfolder and no lbrary (*.csv) file exist!`nThe  %A_ScriptDir%\Libraries\ folder is now created.
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
		MsgBox, 48, % SubStr(A_ScriptName, 1, -4) . " warning", % "Libraries folder: " . A_ScriptDir . "\Libraries is empty. No (triggerstring, hotstring) definition will be loaded." ;Future: prepare for translation
	
	;Check if Config.ini contains in section [TipsLibraries] file names which actually aren't present in Libraries subfolder. If it does, remove them from Config.ini
	a_TipsConfig := StrSplit(v_TipsConfig, "`n")			; Separates a string into an array of substrings using the specified delimiters.
	Loop, % a_TipsConfig.MaxIndex()					; Loop over the entire array
	{
		v_ConfigLibrary := SubStr(a_TipsConfig[A_Index], 1, InStr(a_TipsConfig[A_Index], "=") - 1)	; returns from the beginning till "=" sign
		Loop, Files, Libraries\*.csv
		{
			v_ConfigFlag := false
			if (A_LoopFileName == v_ConfigLibrary)
			{
				v_ConfigFlag := true
				break
			}
		}
		if (!v_ConfigFlag)							; if in Config.ini there is a file which is not actually present in Libraries subfolder
			IniDelete, Config.ini, TipsLibraries, %v_ConfigLibrary% ; remove such file from Conig.ini
	}
	
	; Priority library has special meaning. It is constant library filename, created if not exist.
	if (!FileExist("Libraries\PriorityLibrary.csv"))
	{
		FileAppend,, Libraries\PriorityLibrary.csv, UTF-8
		MsgBox, 48, % SubStr(A_ScriptName, 1, -4) . " warning", % "The default library file (PriorityLibrary.csv) was created in " . A_ScriptDir . "\Libraries folder." ;Future: prepare for translation
	}
	
	;Load again section [TipsLibraries] from Config.ini
	IniRead, v_TipsConfig, 					Config.ini, TipsLibraries
	
	; Look in Libraries subfolder. Check if each file found there is already present in section [TipsLibraries] of Config.ini file. If not add it to Config.ini and enable it by default.
	a_TipsConfig := StrSplit(v_TipsConfig, "`n")			; Separates a string into an array of substrings using the specified delimiters.
	Loop, Files, Libraries\*.csv
	{
		v_NewLibrary := true
		
		;MsgBox, , v_ConfigLibrary, %v_ConfigLibrary%
		Loop, % a_TipsConfig.MaxIndex()					; Loop over the entire array
		{
			v_ConfigLibrary := SubStr(a_TipsConfig[A_Index], 1, InStr(a_TipsConfig[A_Index], "=") - 1)	; returns from the beginning till "=" sign
			if (A_LoopFileName == v_ConfigLibrary)
			{
				v_NewLibrary := false
				break
			}
		}
		if (v_NewLibrary)							; if in Config.ini there is a file which is not actually present in Libraries subfolder
			Iniwrite, 1, Config.ini, TipsLibraries,  %A_LoopFileName% ;add new library file and enable tips
	}
	
	;Load again section [TipsLibraries] from Config.ini
	IniRead, v_TipsConfig, 					Config.ini, TipsLibraries
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

F_LoadLibrariesToTables()
{ 
	local name
	
	; Prepare TrayTip message taking into account value of command line parameter.
	if (v_Param == "d")
		TrayTip, %A_ScriptName% - Debug mode, 	% TransA["Loading hotstrings from libraries..."], 1
	else if (v_Param == "l")
		TrayTip, %A_ScriptName% - Lite mode, 	% TransA["Loading hotstrings from libraries..."], 1
	else	
		TrayTip, %A_ScriptName%,				% TransA["Loading hotstrings from libraries..."], 1
	
	;Here content of libraries is loaded into set of tables
	Loop, Files, %A_ScriptDir%\Libraries\*.csv ;#[Ladowanie tablic]
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

F_LoadFiles(nameoffile)
{
 	;global v_LoadedHotstrings
	;global v_HotstringCnt
	;global a_Triggers
	global 
	local line := ""
	
	IniRead, v_Library, Config.ini, TipsLibraries, %nameoffile%
	Loop
	{
		FileReadLine, line, Libraries\%nameoffile%, %A_Index%
		if (ErrorLevel)
			break
		line := StrReplace(line, "``n", "`n")
		line := StrReplace(line, "``r", "`r")		
		line := StrReplace(line, "``t", "`t")
		F_ini_StartHotstring(line, nameoffile)
		if (v_Library)
			a_Triggers.Push(v_TriggerString)
		v_HotstringCnt++
		GuiControl,, v_LoadedHotstrings, % TransA["Loaded hotstrings:"] . " " v_HotstringCnt
	}
	return
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

F_ini_StartHotstring(txt, nameoffile) 
{
	global v_TriggerString
	static Options, OnOff, EnDis, SendFun, TextInsert
	
	v_UndoHotstring := ""
	v_TriggerString := ""
	
	txtsp 			:= StrSplit(txt, "‖")
	Options 			:= txtsp[1]
	v_TriggerString 	:= txtsp[2]
	if (!v_TriggerString) ; Future: add those strings to translation.
	{
		MsgBox, 262420, % A_ScriptName . "Error reading library file", % "On time of parsing the library file:`n`n" . nameoffile . "`n`nthe following line is found:`n" . txt . "`n`nThis line do not comply to format required by this application.`n`nContinue reading the library file?`nIf you answer ""No"" then application wiłl exit!"
		IfMsgBox, No
			ExitApp, 1
		IfMsgBox, Yes
			return
	}
	if (txtsp[3] == "SI")
		SendFun := "F_NormalWay"
	else if (txtsp[3] == "CL") 
		SendFun := "F_ViaClipboard"
	else if (txtsp[3] == "MCL") 
		SendFun := "F_MenuText"
	else if (txtsp[3] == "MSI") 
		SendFun := "F_MenuTextAHK"
	EnDis := txtsp[4]
	If (EnDis == "En")
		OnOff := "On"
	else if (EnDis == "Dis")
		OnOff := "Off"
	TextInsert := txtsp[5]
	Oflag := ""
	If (InStr(Options,"O",0))
		Oflag := 1
	else
		Oflag := 0
	if !((Options == "") and (v_TriggerString == "") and (TextInsert == "") and (OnOff == ""))
	{
		Hotstring(":" . Options . ":" . v_TriggerString, func(SendFun).bind(TextInsert, Oflag), OnOff)
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
	InputLocaleID:=DllCall("GetKeyboardLayout", "UInt", 0, "UInt")
	Polish := Format("{:#x}", 0x415)
	InputLocaleID := InputLocaleID / 0xFFFF
	InputLocaleID := Format("{:#04x}", InputLocaleID)
	if(InputLocaleID = Polish)
	{
		Send, {LCtrl up}
	}
	if (InStr(A_ThisHotkey, "*"))
	{
		if (InStr(A_ThisHotkey,"*0"))
			v_TypedTriggerstring := % ReplacementString . " "
		else
			v_TypedTriggerstring := ReplacementString
	}
	else
		v_TypedTriggerstring := % ReplacementString . " "
	if (InStr(v_TypedTriggerstring, "{"))
		v_TypedTriggerstring := SubStr(v_TypedTriggerstring, InStr(v_TypedTriggerstring, "}")+1 , StrLen(v_TypedTriggerstring)-InStr(v_TypedTriggerstring, "}"))
	Hotstring("Reset")
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

F_ViaClipboard(ReplacementString, Oflag)
{
	global oWord, ini_Delay
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

F_MenuText(TextOptions, Oflag)
{
	global MenuListbox, Ovar
	v_InputString := ""
	ToolTip,
	v_UndoTriggerstring := A_ThisHotkey
	TextOptions := F_AHKVariables(TextOptions)
	WinGetPos, WinX, WinY,WinW,WinH,A
	mouseX := Round(WinX+WinW/2)
	mouseY := Round(WinY+WinH/2)
	DllCall("SetCursorPos", "int", mouseX, "int", mouseY)
	v_TypedTriggerstring := ""
	Gui, Menu:New, +LastFound +AlwaysOnTop -Caption +ToolWindow
	Gui, Menu:Margin, 0, 0
	Gui, Menu:Font, c766D69 s8
	Gui, Menu:Color,,FFFFFF
	Gui, Menu:Add, Listbox, x0 y0 h100 w250 vMenuListbox,
	v_MenuMax := 0
	for k, MenuItems in StrSplit(TextOptions,"¦") ;parse the data on the weird pipe character
	{
		GuiControl,, MenuListbox, % A_Index . ". " . MenuItems
		v_MenuMax++
	}
	if (ini_MenuCaret)
	{
		;CoordMode, Caret, Screen
		CoordMode, Caret, Client
		MenuX := A_CaretX + 20
		MenuY := A_CaretY - 20
		
		
	}
	if (ini_MenuCursor) or ((MenuX == "") and (MenuY == ""))
	{
		;CoordMode, Mouse, Screen
		CoordMode, Mouse, Client
		MouseGetPos, v_MouseX, v_MouseY
		MenuX := v_MouseX + 20
		MenuY := v_MouseY + 20
	}
	Gui, Menu:Show, x%MenuX% y%MenuY%, Hotstring listbox
	if (ini_MenuSound)
		SoundBeep, 400, 200
	v_FlagSound := 1
	if (v_TypedTriggerstring == "")
	{
		HK := StrSplit(A_ThisHotkey, ":")
		
		
		ThisHotkey := SubStr(A_ThisHotkey, StrLen(HK[2])+3, StrLen(A_ThisHotkey)-StrLen(HK[2])-2)
		Send, % ThisHotkey
	}
	GuiControl, Choose, MenuListbox, 1
	Ovar := Oflag
	v_HotstringFlag := 1
	return
}

;Future: move this section of code to Hotkeys

#IfWinActive Hotstring listbox
~1::
~2::
~3::
~4::
~5::
~6::
~7::
v_PressedKey := SubStr(A_ThisHotkey,2)
if (v_PressedKey > v_MenuMax)
	return
else
{
	GuiControl, Choose, MenuListbox, v_PressedKey
	Sleep, 100
}
Enter:: 
v_HotstringFlag := 1
Gui, Menu:Submit, Hide
ClipboardBack:=ClipboardAll ;backup clipboard
MenuListbox := SubStr(MenuListbox, InStr(MenuListbox, ".")+2)
Clipboard:=MenuListbox ;Shove what was selected into the clipboard
Send, ^v ;paste the text
if (Ovar == 0)
	Send, % A_EndChar
sleep

, %ini_Delay% ;Remember to sleep before restoring clipboard or it will fail
v_TypedTriggerstring := MenuListbox
v_UndoHotstring := MenuListbox
Clipboard:=ClipboardBack
Hotstring("Reset")
Gui, Menu:Destroy
Return
#If
#IfWinExist Hotstring listbox
Esc::
Gui, Menu:Destroy
SendRaw, % SubStr(A_PriorHotkey, InStr(A_PriorHotkey, ":", v_OptionCaseSensitive := false, StartingPos := 1, Occurrence := 2) + 1)
return
#If

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

F_MenuTextAHK(TextOptions, Oflag)
{
	global MenuListbox, Ovar
	v_InputString := ""
	ToolTip,
	v_UndoTriggerstring := A_ThisHotkey
	TextOptions := F_AHKVariables(TextOptions)
	WinGetPos, WinX, WinY,WinW,WinH,A
	mouseX := Round(WinX+WinW/2)
	mouseY := Round(WinY+WinH/2)
	DllCall("SetCursorPos", "int", mouseX, "int", mouseY)
	v_TypedTriggerstring := ""
	Gui, MenuAHK:New, +LastFound +AlwaysOnTop -Caption +ToolWindow
	Gui, MenuAHK:Margin, 0, 0
	Gui, MenuAHK:Font, c766D69 s8
	Gui, MenuAHK:Color,,FFFFFF
	Gui, MenuAHK:Add, Listbox, x0 y0 h100 w250 vMenuListbox2,
	v_MenuMax2 := 0
	for k, MenuItems in StrSplit(TextOptions,"¦") ;parse the data on the weird pipe character
	{
		GuiControl,, MenuListbox2, % A_Index . ". " . MenuItems
		v_MenuMax2++
	}
	if (ini_MenuCaret)
	{
		;CoordMode, Caret, Screen
		CoordMode, Caret, Client
		MenuX := A_CaretX + 20
		MenuY := A_CaretY - 20
	}
	if (ini_MenuCursor) or ((MenuX == "") and (MenuY == ""))
	{
		;CoordMode, Mouse, Screen
		CoordMode, Mouse, Client
		MouseGetPos, v_MouseX, v_MouseY
		MenuX := v_MouseX + 20
		MenuY := v_MouseY + 20
	}
	Gui, MenuAHK:Show, x%MenuX% y%MenuY%, HotstringAHK listbox
	if (ini_MenuSound)
		SoundBeep, 400, 200
	v_FlagSound := 1
	if (v_TypedTriggerstring == "")
	{
		HK := StrSplit(A_ThisHotkey, ":")
		ThisHotkey := SubStr(A_ThisHotkey, StrLen(HK[2])+3, StrLen(A_ThisHotkey)-StrLen(HK[2])-2)
		Send, % ThisHotkey
	}
	GuiControl, Choose, MenuListbox2, 1
	Ovar := Oflag
	v_HotstringFlag := 1
	return
}

;Future: move this section of code to Hotkeys
#IfWinActive HotstringAHK listbox
~1::
~2::
~3::
~4::
~5::
~6::
~7::
v_PressedKey := SubStr(A_ThisHotkey,2)
if (v_PressedKey > v_MenuMax2)
	return
else
{
	GuiControl, Choose, MenuListbox2, v_PressedKey
	Sleep, 100
}
Enter:: 
Gui, MenuAHK:Submit, Hide
v_HotstringFlag := 1
MenuListbox2 := SubStr(MenuListbox2, InStr(MenuListbox2, ".")+2)
Send, % MenuListbox2
if (Ovar == 0)
	Send, % A_EndChar
v_UndoHotstring := MenuListbox2
v_UndoHotstring := F_ChangingBrackets(v_UndoHotstring)
SetFormat, Integer, H
InputLocaleIDv:=DllCall("GetKeyboardLayout", "UInt", 0, "UInt")
Polishv := Format("{:#x}", 0x415)
InputLocaleIDv := InputLocaleIDv / 0xFFFF
InputLocaleIDv := Format("{:#04x}", InputLocaleIDv)
if(InputLocaleIDv = Polishv)
{
	Send, {LCtrl up}
}

v_TypedTriggerstring := SubStr(A_ThisHotkey, InStr(A_ThisHotkey, ":", false, 1, 2) + 1)
Hotstring("Reset")
Gui, MenuAHK:Destroy
Return
#If
#IfWinExist HotstringAHK listbox
Esc::
Gui, MenuAHK:Destroy
Send, % SubStr(A_PriorHotkey, InStr(A_PriorHotkey, ":", v_OptionCaseSensitive := false, StartingPos := 1, Occurrence := 2) + 1)
return
#If

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

F_CheckOption(State,Button)
{
	If (State = "Yes")
	{
		State := 1
		GuiControl, , Button%Button%, 1
	}
	Else 
	{
		State := 0
		GuiControl, , Button%Button%, 0
	}
	Button := "Button" . Button
	
	F_CheckBoxColor(State,Button)  
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

F_CheckBoxColor(State,Button)
{
	;global v_SelectedMonitor
	if (State = 1)
		;Gui, HS3:Font,% "s" . 12*DPI%v_SelectedMonitor% . " cRed Norm", Calibri
		Gui, HS3:Font, % "s" . c_FontSize . A_Space . "cRed Norm", Calibri
	else 
		;Gui, HS3:Font,% "s" . 12*DPI%v_SelectedMonitor% . " cBlack Norm", Calibri
		Gui, HS3:Font, % "s" . c_FontSize . A_Space . "c" . c_FontColor . A_Space . "Norm", Calibri
	GuiControl, HS3:Font, %Button%
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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
	Hotstring("EndChars", HotstringEndChars)
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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
					else if (Asc(v_ActualArray) > Asc(v_TempArray))
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

F_SortHotstringsAlphabetically(filename)
{
	local v_Text, v_Text2, a_TempArray, a_TriggerArray, line, v_Trigger, a_TriggerArray, a_SortedTriggers, a_SortedHotstrings, cnt, no, v_AscTrigger, v_AscArray, flag, v_ActualArray, v_TempArray
	a_TempArray := []
	a_TriggerArray := []
	a_SortedTriggers := []
	a_SortedHotstrings := []
	Loop
	{
		FileReadLine, line, %filename%, %A_Index%
		if ErrorLevel
			break
		a_TempArray.Push(line)
		a_ActualArray := StrSplit(line,"‖")
		v_Trigger := a_ActualArray[2]
		a_TriggerArray.Push(v_Trigger)
	}
	Loop, % a_TriggerArray.MaxIndex()
	{
		cnt := A_Index
		a_SortedTriggers[cnt] := a_TriggerArray[cnt]
		a_SortedHotstrings[cnt] := a_TempArray[cnt]
		Loop, % cnt - 1
		{
			v_AscTrigger := Asc(a_TriggerArray[cnt])
			if (v_AscTrigger >= 65) and (v_AscTrigger <= 90)
			{
				v_AscTrigger := v_AscTrigger+32
			}
			v_AscArray := Asc(a_SortedTriggers[A_Index])
			if (v_AscArray >= 65) and (v_AscArray <= 90)
			{
				v_AscArray := v_AscArray+32
			}
			If (v_AscTrigger < v_AscArray)
			{
				Loop, % cnt - A_Index
				{
					a_SortedTriggers[cnt - (A_Index - 1)] := a_SortedTriggers[cnt - A_Index]
					a_SortedHotstrings[cnt - (A_Index - 1)] := a_SortedHotstrings[cnt - A_Index]
				}
				a_SortedTriggers[A_Index] := a_TriggerArray[cnt]
				a_SortedHotstrings[A_Index] := a_TempArray[cnt]
				break
			}
			else if (v_AscTrigger == v_AscArray)
			{
				flag := 0
				no := A_Index
				v_ActualArray := a_TriggerArray[cnt]
				v_TempArray := a_SortedTriggers[no]
				Loop, % Max(StrLen(v_ActualArray), StrLen(v_TempArray))
				{
					v_ActualArray := SubStr(v_ActualArray, 2)
					v_TempArray := SubStr(v_TempArray, 2)
					v_AscActualArray := Asc(v_ActualArray)
					if (v_AscActualArray >= 65) and (v_AscActualArray <= 90)
					{
						v_AscActualArray := v_AscActualArray+32
					}
					v_AscTempArray := Asc(v_TempArray)
					if (v_AscTempArray >= 65) and (v_AscTempArray <= 90)
					{
						v_AscTempArray := v_AscTempArray+32
					}
					If (v_AscActualArray < v_AscTempArray)
					{
						Loop, % cnt - no
						{
							a_SortedTriggers[cnt - A_Index + 1] := a_SortedTriggers[cnt - A_Index]
							a_SortedHotstrings[cnt - A_Index + 1] := a_SortedHotstrings[cnt - A_Index]
						}
						a_SortedTriggers[no] := a_TriggerArray[cnt]
						a_SortedHotstrings[no] := a_TempArray[cnt]
						flag := 1
						Break
					}
					else if (v_AscActualArray > v_AscTempArray)
					{
						Break
					}
				}
				if (flag)
					Break
			}
		}
	}
	v_Text := a_SortedHotstrings[1]
	Loop, % a_SortedHotstrings.MaxIndex() - 1
	{
		v_Text2 := % "`n" . a_SortedHotstrings[A_Index+1]
		v_Text .= v_Text2
	}
	FileDelete, %filename%
	FileAppend, %v_Text%, %filename%, UTF-8
	return 
}

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

F_ImportLibrary(filename)
{
	static MyProgress, MyText
	;global v_WindowX, v_WindowY ,v_WindowWidth,v_WindowHeight
	global
	local line := ""
	
	Gui, Import:New, -Border
	Gui, Import:Add, Progress, w200 h20 cBlue vMyProgress, 0
	Gui, Import:Add,Text,w200 vMyText, % TransA["Library import. Please wait..."]
	Gui, Import:Show, hide, Import
	WinGetPos, v_WindowX, v_WindowY ,v_WindowWidth,v_WindowHeight,Hotstrings
	DetectHiddenWindows, On
	WinGetPos, , , ImportWindowWidth, ImportWindowHeight,Import
	DetectHiddenWindows, Off
	Gui, Import:Show,% "x" . v_WindowX + (v_WindowWidth - ImportWindowWidth)/2 . " y" . v_WindowY + (v_WindowHeight - ImportWindowHeight)/2 ,Import
	SplitPath, filename, ShortFileName
	v_OutputFile := % A_ScriptDir . "\Libraries\" . SubStr(ShortFileName, 1, StrLen(ShortFileName)-3) . "csv"
	Loop,
	{
		If FileExist(v_OutputFile) and (A_Index == 1)
			v_OutputFile := % SubStr(v_OutputFile, 1, StrLen(v_OutputFile)-4) . "_(" . A_Index . ").csv"
		else if FileExist(v_OutputFile) and (A_Index != 1)
			v_OutputFile := % SubStr(v_OutputFile, 1, InStr(v_OutputFile, "(" ,,0,1)) . A_Index . ").csv" 
		else
			break
	}
	Loop, Read, %filename%
	{
		v_TotalLines := A_Index
	}
	FileAppend,, %v_OutputFile%, UTF-8
	Loop
	{
		FileReadLine, line, %filename%, %A_Index%
		if ErrorLevel
			break  
		a_Hotstring := StrSplit(line, ":")
		v_Options := a_Hotstring[2]
		v_Trigger := a_Hotstring[3]
		v_Hotstring := a_Hotstring[5]
		if (A_Index == 1)
			FileAppend, % v_Options . "‖" . v_Trigger . "‖SI‖En‖" . v_Hotstring  . "‖", %v_OutputFile%, UTF-8
		else
			FileAppend, % "`n" . v_Options . "‖" . v_Trigger . "‖SI‖En‖" . v_Hotstring  . "‖", %v_OutputFile%, UTF-8
		v_Progress := (A_Index/v_TotalLines)*100
		GuiControl,, MyProgress, %v_Progress%
		GuiControl,, MyText, % "Imported " . A_Index . " of " . v_TotalLines . " hotstrings"
	}
	F_SortHotstringsAlphabetically(v_OutputFile)
	GuiControl,, MyText, % TransA["Loading libraries. Please wait..."]
	a_Triggers := []
	F_LoadHotstringsFromLibraries()
	Gui, HS3:Default
	GuiControl, , v_SelectHotstringLibrary, |
	Loop,%A_ScriptDir%\Libraries\*.csv
		GuiControl, , v_SelectHotstringLibrary, %A_LoopFileName%
	Gui, Import:Destroy
	MsgBox, % TransA["Library has been imported."]
	return
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

F_ExportLibraryStatic(filename)
{
	static MyProgress, MyText
	;global v_WindowX, v_WindowY ,v_WindowWidth,v_WindowHeight
	global
	local line := ""
	
	Gui, Export:New, -Border
	Gui, Export:Add, Progress, w200 h20 cBlue vMyProgress, 0
	Gui, Export:Add,Text,w200 vMyText, % TransA["Library export. Please wait..."]
	Gui, Export:Show, hide, Export
	WinGetPos, v_WindowX, v_WindowY ,v_WindowWidth,v_WindowHeight,Hotstrings
	DetectHiddenWindows, On
	WinGetPos, , , ExportWindowWidth, ExportWindowHeight,Export
	DetectHiddenWindows, Off
	Gui, Export:Show,% "x" . v_WindowX + (v_WindowWidth - ExportWindowWidth)/2 . " y" . v_WindowY + (v_WindowHeight - ExportWindowHeight)/2 ,Export
	
	SplitPath, filename, ShortFileName
	v_LibrariesDir := % A_ScriptDir . "\ExportedLibraries"
	if !InStr(FileExist(v_LibrariesDir),"D")
		FileCreateDir, %v_LibrariesDir%
	v_OutputFile := % A_ScriptDir . "\ExportedLibraries\" . SubStr(ShortFileName, 1, StrLen(ShortFileName)-3) . "ahk"
	Loop,
	{
		If FileExist(v_OutputFile) and (A_Index == 1)
			v_OutputFile := % SubStr(v_OutputFile, 1, StrLen(v_OutputFile)-4) . "_(" . A_Index . ").ahk"
		else if FileExist(v_OutputFile) and (A_Index != 1)
			v_OutputFile := % SubStr(v_OutputFile, 1, InStr(v_OutputFile, "(" ,,0,1)) . A_Index . ").ahk" 
		else
			break
	}
	v_TotalLines := 0
	Loop, Read, %filename%
	{
		v_TotalLines := A_Index
	}
	if (v_TotalLines == 0)
	{
		MsgBox, % TransA["Selected file is empty."]
		return
	}
	FileAppend, % "; This file is result of automatic export from Hotstrings.ahk application.`n#SingleInstance, Force", %v_OutputFile%, UTF-8
	Loop
	{
		FileReadLine, line, %filename%, %A_Index%
		if ErrorLevel
			break  
		a_Hotstring := StrSplit(line, "‖")
		v_Options := a_Hotstring[1]
		v_Trigger := a_Hotstring[2]
		if InStr(a_Hotstring[3],"M")
		{
			a_MenuHotstring := StrSplit(a_Hotstring[5],"¦")
			Loop, % a_MenuHotstring.MaxIndex()
			{
				FileAppend, % "`n:" . v_Options . ":" . v_Trigger . "::" . a_MenuHotstring[A_Index] . " " . ";" . " warning, code generated automatically for definitions based on menu, see documentation of Hotstrings app for details", %v_OutputFile%, UTF-8
			}
		}
		else
		{
			v_Hotstring := a_Hotstring[5]
			FileAppend, % "`n:" . v_Options . ":" . v_Trigger . "::" . v_Hotstring, %v_OutputFile%, UTF-8
		}
		v_Progress := (A_Index/v_TotalLines)*100
		GuiControl,, MyProgress, %v_Progress%
		GuiControl,, MyText, % "Exported " . A_Index . " of " . v_TotalLines . " hotstrings"
	}
	Gui, Export:Destroy
	MsgBox, % TransA["Library has been exported."] . "`n" . TransA["The file path is:"] . " " . v_OutputFile
	return
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

F_ExportLibraryDynamic(filename)
{
	static MyProgress, MyText
	;global v_WindowX, v_WindowY ,v_WindowWidth,v_WindowHeight
	global
	local line := ""
	
	Gui, Export:New, -Border
	Gui, Export:Add, Progress, w200 h20 cBlue vMyProgress, 0
	Gui, Export:Add,Text,w200 vMyText, % TransA["Library export. Please wait..."]
	Gui, Export:Show, hide, Export
	WinGetPos, v_WindowX, v_WindowY ,v_WindowWidth,v_WindowHeight,Hotstrings
	DetectHiddenWindows, On
	WinGetPos, , , ExportWindowWidth, ExportWindowHeight,Export
	DetectHiddenWindows, Off
	Gui, Export:Show,% "x" . v_WindowX + (v_WindowWidth - ExportWindowWidth)/2 . " y" . v_WindowY + (v_WindowHeight - ExportWindowHeight)/2 ,Export
	
	SplitPath, filename, ShortFileName
	v_LibrariesDir := % A_ScriptDir . "\ExportedLibraries"
	if !InStr(FileExist(v_LibrariesDir),"D")
		FileCreateDir, %v_LibrariesDir%
	v_OutputFile := % A_ScriptDir . "\ExportedLibraries\" . SubStr(ShortFileName, 1, StrLen(ShortFileName)-3) . "ahk"
	Loop,
	{
		If FileExist(v_OutputFile) and (A_Index == 1)
			v_OutputFile := % SubStr(v_OutputFile, 1, StrLen(v_OutputFile)-4) . "_(" . A_Index . ").ahk"
		else if FileExist(v_OutputFile) and (A_Index != 1)
			v_OutputFile := % SubStr(v_OutputFile, 1, InStr(v_OutputFile, "(" ,,0,1)) . A_Index . ").ahk" 
		else
			break
	}
	v_TotalLines := 0
	Loop, Read, %filename%
	{
		v_TotalLines := A_Index
	}
	if (v_TotalLines == 0)
	{
		MsgBox, % TransA["Selected file is empty."]
		return
	}
	FileAppend, % "; This file is result of automatic export from Hotstrings.ahk application.`n#SingleInstance, Force", %v_OutputFile%, UTF-8
	Loop
	{
		FileReadLine, line, %filename%, %A_Index%
		if ErrorLevel
			break  
		a_Hotstring := StrSplit(line, "‖")
		v_Options := a_Hotstring[1]
		v_Trigger := a_Hotstring[2]
		if InStr(a_Hotstring[3],"M")
		{
			a_MenuHotstring := StrSplit(a_Hotstring[5],"¦")
			Loop, % a_MenuHotstring.MaxIndex()
			{
				if (a_MenuHotstring[A_Index] != "")
					FileAppend, % "`nHotstring("":" . v_Options . ":" . v_Trigger . """, """ . a_MenuHotstring[A_Index] . """, On) " . ";" . " warning, code generated automatically for definitions based on menu, see documentation of Hotstrings app for details", %v_OutputFile%, UTF-8
			}
		}
		else
		{
			v_Hotstring := a_Hotstring[5]
			if (v_Hotstring != "")
				FileAppend, % "`nHotstring("":" . v_Options . ":" . v_Trigger . """, """ . v_Hotstring . """, On)", %v_OutputFile%, UTF-8
		}
		v_Progress := (A_Index/v_TotalLines)*100
		GuiControl,, MyProgress, %v_Progress%
		GuiControl,, MyText, % "Exported " . A_Index . " of " . v_TotalLines . " hotstrings"
	}
	Gui, Export:Destroy
	MsgBox, % TransA["Library has been exported."] . "`n" . TransA["The file path is:"] . A_Space . v_OutputFile
	return
}


/*
	F_ShowUnicodeSigns(string)
	{
		vSize := StrPut(string, "CP0")
		VarSetCapacity(vUtf8, vSize)
		vSize := StrPut(string, &vUtf8, vSize, "CP0")
		Return StrGet(&vUtf8, "UTF-8") 
	}
	
*/

/*
	F_ReadText(string)
	{
		local Key
		Key := SubStr(string, 3)		; Retrives all characters starting from 3rd position in string: omits "t_" at the beginning of each string.
		IniRead, string, Languages\%v_Language%, Strings, %Key% 
		if (InStr(string, "``n"))		; If `n string is escaped (so it equals to ``n string), convert it to normal `n string.
			string := StrReplace(string, "``n", "`n")
		;string := F_ShowUnicodeSigns(string)
		return string
	}
*/

F_LoadHotstringsFromLibraries()
{
		;global t_LoadingHotstringsFromLibraries, t_HotstringsHaveBeenLoaded, v_HotstringCnt
	
	;TrayTip, %A_ScriptName%, %t_LoadingHotstringsFromLibraries%, 1
	v_HotstringCnt := 0
	Loop, Files, Libraries\*.csv
	{
		if !(A_LoopFileName == "PriorityLibrary.csv")
		{
			F_LoadFiles(A_LoopFileName)
		}
	}
	F_LoadFiles("PriorityLibrary.csv")
	;TrayTip, %A_ScriptName%, %t_HotstringsHaveBeenLoaded%, 1
}




; --------------------------- SECTION OF LABELS ---------------------------


TurnOffTooltip:
ToolTip ,
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;v_BlockHotkeysFlag := 1 ; Block hotkeys of this application for the time when (triggerstring, hotstring) definitions are uploaded from liberaries.
#If v_Param != "l" and v_BlockHotkeysFlag == 0




; - - - - - - - - - - The Beginning - - - - - - - - - - - - 

^#h::		; Event
L_GUIInit:

if (v_ResizingFlag) ;if run for the very first time
{
	if (ini_StartX == "") or (ini_StartY == "") or (ini_StartW == "") or (ini_StartH == "")
	{
		;why double Show is necessary if FontSize == 16???
		Gui, 		%HS3Hwnd%:Show, AutoSize Center
		Gui, 		%HS3Hwnd%:Show, AutoSize Center
	}
	else
		Gui,			%HS3Hwnd%: Show, % "X" . ini_StartX . A_Space . "Y" . ini_StartY . A_Space . "W" . ini_StartW . A_Space . "H" . ini_StartH
	
	Gui, %HS3Hwnd%: Default ; this line is necessary to enable handling of List Views.
	GuiControlGet, v_OutVarTemp, Pos, % IdListView1
	LV_ModifyCol(1, Round(0.1 * v_OutVarTempW))
	LV_ModifyCol(2, Round(0.1 * v_OutVarTempW))
	LV_ModifyCol(3, Round(0.1 * v_OutVarTempW))	
	LV_ModifyCol(4, Round(0.1 * v_OutVarTempW))
	LV_ModifyCol(5, Round(0.4 * v_OutVarTempW))
	LV_ModifyCol(6, Round(0.2 * v_OutVarTempW) - 3)
	v_ResizingFlag := 0
}
else
	Gui, %HS3Hwnd%: Show, restore

if (v_PreviousSection != "") ; it means: if Hotstrings app was restarted
{
	GuiControl, Choose, v_SelectHotstringLibrary, %v_PreviousSection%
	F_SectionChoose()
	if(v_SelectedRow > 0)
	{
		LV_Modify(v_SelectedRow, "Vis")
		LV_Modify(v_SelectedRow, "+Select +Focus")
		GuiControl, Focus, v_LibraryContent
	}
}
return



/*
	v_FlagMax := 0 ;v_FlagMax is set if variables ini_StartW or ini_StartH are empty in ConfigIni 
	if (ini_StartW == "") or (ini_StartH == "")
		v_FlagMax := 1
	if (ini_StartX == "")
		;ini_StartX := Mon%v_SelectedMonitor%Left + (Abs(Mon%v_SelectedMonitor%Right - Mon%v_SelectedMonitor%Left)/2) - 430*DPI%v_SelectedMonitor%
		ini_StartX := Mon%v_SelectedMonitor%Left
	if (ini_StartY == "")
		;ini_StartY := Mon%v_SelectedMonitor%Top + (Abs(Mon%v_SelectedMonitor%Bottom - Mon%v_SelectedMonitor%Top)/2) - (225*DPI%v_SelectedMonitor%+31)
		ini_StartY := Mon%v_SelectedMonitor%Top
	if (ini_StartW == "")
		ini_StartW := 1350*DPI%v_SelectedMonitor%
	if (ini_StartH == "")
		if (ini_Sandbox)
			ini_StartH := 640*DPI%v_SelectedMonitor%+20 + 154*DPI%v_SelectedMonitor%
	else
		ini_StartH := 640*DPI%v_SelectedMonitor%+20
	
	if (ini_Sandbox) and (ini_StartH < 640*DPI%v_SelectedMonitor%+20 + 154*DPI%v_SelectedMonitor%)
		ini_StartH := 640*DPI%v_SelectedMonitor%+20 + 154*DPI%v_SelectedMonitor%
	Gui, HS3:Hide
*/
/*
	
	if (v_ShowGui == 1) ; it meaans: Hotstrings app was not restarted
	{
		if (v_FlagMax)
		{
			;Gui, HS3:Show, x%ini_StartX% y%ini_StartY% w%ini_StartW% h%ini_StartH% Hide, Hotstrings
			;Gui, HS3:Show, Maximize, Hotstrings
			Gui,	HS3: Show, AutoSize Center
			Gui,	HS3: Show, AutoSize Center
		}
		else 
			;Gui, HS3:Show, x%ini_StartX% y%ini_StartY% w%ini_StartW% h%ini_StartH%, Hotstrings
			Gui,	HS3: Show, AutoSize Center
		Gui,	HS3: Show, AutoSize Center
	}
	else if (v_ShowGui == 2) ;it means: Hotstrings aap was restarted
	{
		;if (ini_Sandbox) and (v_PreviousHeight < 640*DPI%v_SelectedMonitor%+20 + 154*DPI%v_SelectedMonitor%)
			;v_PreviousHeight := 640*DPI%v_SelectedMonitor%+20 + 154*DPI%v_SelectedMonitor%
		;Gui, HS3:Show, W%v_PreviousWidth% H%v_PreviousHeight% X%v_PreviousX% Y%v_PreviousY%, Hotstrings
		;Gui, HS3:Show, x%ini_StartX% y%ini_StartY% w%ini_StartW% h%ini_StartH%, Hotstrings
		Gui,	HS3: Show, AutoSize Center
		Gui,	HS3: Show, AutoSize Center
	}
*/


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

/*
	ViewString:
	Gui, HS3:Submit, NoHide
	GuiControlGet, v_ViewString
	Select := v_ViewString
	a_String := StrSplit(Select, """")
	HotString2 := StrSplit(a_String[2],":")
	v_TriggerStringvar := SubStr(a_String[2], StrLen( ":" . HotString2[2] . ":" ) + 1, StrLen(a_String[2])-StrLen(  ":" . HotString2[2] . ":" ))
	RText := StrSplit(Select, "bind(""")
	if InStr(RText[2], """On""")
	{
		OText := SubStr(RText[2], 1, StrLen(RText[2])-9)
	}
	else
	{    
		OText := SubStr(RText[2], 1, StrLen(RText[2])-10)
	}
	GuiControl, , v_TriggerString, % v_TriggerStringvar
	if (InStr(Select, """F_MenuText""") or InStr(Select, """F_MenuTextAHK"""))
	{
		OTextMenu := StrSplit(OText, "¦")
		GuiControl, , v_EnterHotstring, % OTextMenu[1]
		GuiControl, , v_EnterHotstring1, % OTextMenu[2]
		GuiControl, , v_EnterHotstring2, % OTextMenu[3]
		GuiControl, , v_EnterHotstring3, % OTextMenu[4]
		GuiControl, , v_EnterHotstring4, % OTextMenu[5]
		GuiControl, , v_EnterHotstring5, % OTextMenu[6]
		GuiControl, , v_EnterHotstring6, % OTextMenu[7]
		
	}
	else
	{
		GuiControl, , v_EnterHotstring, % OText
	}
	GoSub SetOptions 
	gosub L_SelectFunction
	return
	
*/
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

;#[AddHotstring]
;AddHotstring: 
;1. Read all inputs. 
;2. Create Hotstring definition according to inputs. 
;3. Read the library file into List View. 
;4. Sort List View. 
;5. Delete library file. 
;6. Save List View into the library file.
;7. Increment library counter.
F_AddHotstring()
{
	global ;assume-global mode
	local 	TextInsert := "", OldOptions := "", Options := "", SendFun := "", OnOff := "", EnDis := "", OutputFile := "", InputFile := "", LString := "", ModifiedFlag := false
			,txt := "", txt1 := "", txt2 := "", txt3 := "", txt4 := "", txt5 := "", txt6 := ""
	
	Gui, HS3:+OwnDialogs
	;1. Read all inputs. 
	Gui, Submit, NoHide
;GuiControlGet, v_SelectFunction
	
	if (Trim(v_TriggerString) = "")
	{
		MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ": information",  % TransA["Enter hotstring"] ;Future: translate "information"
		return
	}
	if InStr(v_SelectFunction, "Menu")
	{
		if ((Trim(v_EnterHotstring) = "") and (Trim(v_EnterHotstring1) = "") and (Trim(v_EnterHotstring2) = "") and (Trim(v_EnterHotstring3) = "") and (Trim(v_EnterHotstring4) = "") and (Trim(v_EnterHotstring5) = "") and (Trim(v_EnterHotstring6) = ""))
		{
			MsgBox, 324, % SubStr(A_ScriptName, 1, -4) . ": information", % TransA["Replacement text is blank. Do you want to proceed?"] ;Future: translate "information"
			IfMsgBox, No
				return
		}
		;TextInsert := ""
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
		TextInsert := SubStr(TextInsert, 2, StrLen(TextInsert)-1)
	}
	else
	{
		if (Trim(v_EnterHotstring) = "")
		{
			MsgBox, 324, % SubStr(A_ScriptName, 1, -4) . ": information", % TransA["Replacement text is blank. Do you want to proceed?"] ;Future: translate "information"
			IfMsgBox, No
				Return
		}
		else
		{
			TextInsert := v_EnterHotstring
		}
	}
	
	if (v_SelectHotstringLibrary == "")
	{
		MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ": information", % TransA["Choose section before saving!"] ;Future: translate "information"
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
	
;GoSub OptionString   ; Writes the Hotstring options string
	
	
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
	
	a_String[2] := Options ;???
	
; Add new/changed target item in DropDownList
	if (v_SelectFunction == "Clipboard (CL)")
		SendFun := "F_ViaClipboard"
	else if (v_SelectFunction == "SendInput (SI)")
		SendFun := "F_NormalWay"
	else if (v_SelectFunction == "Menu & Clipboard (MCL)")
		SendFun := "F_MenuText"
	else if (v_SelectFunction == "Menu & SendInput (MSI)")
		SendFun := "F_MenuTextAHK"
	
	if (v_OptionDisable == 1)
		OnOff := "Off"
	else
		OnOff := "On"
	
	/*
	; If case sensitive (C) or inside a word (?) first deactivate Hotstring
		If (v_OptionCaseSensitive or v_OptionInsideWord or InStr(OldOptions,"C") 
			or InStr(OldOptions,"?")) 
			Hotstring(":" . OldOptions . ":" . v_TriggerString , func(SendFun).bind(TextInsert), "Off")
	*/
	
	;2. Create Hotstring definition according to inputs. 
	if (InStr(Options,"O", 0))
		Hotstring(":" . Options . ":" . v_TriggerString, func(SendFun).bind(TextInsert, true), OnOff)
	else
		Hotstring(":" . Options . ":" . v_TriggerString, func(SendFun).bind(TextInsert, false), OnOff)
	
	Hotstring("Reset") ;reset hotstring recognizer
	
	;3. Read the library file into List View. 
	SendFun := ""
	if (v_OptionDisable)
		EnDis := "Dis"
	else
		EnDis := "En"
	
	
	if (v_SelectFunction == "Clipboard (CL)")
		SendFun := "CL"
	else if (v_SelectFunction == "SendInput (SI)")
		SendFun := "SI"
	else if (v_SelectFunction == "Menu & Clipboard (MCL)")
		SendFun := "MCL"
	else if (v_SelectFunction == "Menu & SendInput (MSI)")
		SendFun := "MSI"
	
	OutputFile 	:= A_ScriptDir . "\Libraries\temp.csv"	; changed on 2021-02-13
	InputFile 	:= A_ScriptDir . "\Libraries\" . v_SelectHotstringLibrary 
	LString 		:= "‖" . v_TriggerString . "‖"
	ModifiedFlag	:= false ;if true, duplicate triggerstring definition is found, if false, definition is new
	
	Loop, Read, %InputFile%, %OutputFile% ;read all definitions from this library file 
	{
		
		if (InStr(A_LoopReadLine, LString, 1) and InStr(Options, "C")) or (InStr(A_LoopReadLine, LString) and !(InStr(Options, "C")))
		{
			MsgBox, 4,, % TransA["The hostring"] . A_Space . """" .  v_TriggerString . """" . A_Space .  TransA["exists in a file"] . A_Space . v_SelectHotstringLibrary . "." . A_Space . TransA["Do you want to proceed?"]
			IfMsgBox, No
				return
			LV_Modify(A_Index, "", v_TriggerString, Options, SendFun, EnDis, TextInsert, v_Comment)
			ModifiedFlag := true
		}
	}
	if !(ModifiedFlag) 
	{
		LV_Add("",  v_TriggerString, Options, SendFun, EnDis, TextInsert, v_Comment)
		txt := % Options . "‖" . v_TriggerString . "‖" . SendFun . "‖" . EnDis . "‖" . TextInsert . "‖" . v_Comment ;tylko to się liczy
		SectionList.Push(txt)
		a_Triggers.Push(v_TriggerString) ;added to table of hotstring recognizer (a_Triggers)
	}
	;4. Sort List View. 
	LV_ModifyCol(1, "Sort")
	;5. Delete library file. 
	FileDelete, %InputFile%
	
	;6. Save List View into the library file.
	if (SectionList.MaxIndex() == "") ;in order to speed up it's checked if library isn't empty.
	{
		LV_GetText(txt1, 1, 2)
		LV_GetText(txt2, 1, 1)
		LV_GetText(txt3, 1, 3)
		LV_GetText(txt4, 1, 4)
		LV_GetText(txt5, 1, 5)
		LV_GetText(txt6, 1, 6)
		txt := % txt1 . "‖" . txt2 . "‖" . txt3 . "‖" . txt4 . "‖" . txt5 . "‖" . txt6
	;FileAppend, %txt%, Libraries\%name%, UTF-8
		FileAppend, %txt%, Libraries\%v_SelectHotstringLibrary%, UTF-8
	}
	else
	{ ;no idea why this is duplicated...
		Loop, % SectionList.MaxIndex()-1
		{
			LV_GetText(txt1, A_Index, 2)
			LV_GetText(txt2, A_Index, 1)
			LV_GetText(txt3, A_Index, 3)
			LV_GetText(txt4, A_Index, 4)
			LV_GetText(txt5, A_Index, 5)
			LV_GetText(txt6, A_Index, 6)
			txt := % txt1 . "‖" . txt2 . "‖" . txt3 . "‖" . txt4 . "‖" . txt5 . "‖" . txt6 . "`r`n"
			if !((txt1 == "") and (txt2 == "") and (txt3 == "") and (txt4 == "") and (txt5 == "") and (txt6 == "")) ;only not empty definitions are added, not sure why
			;FileAppend, %txt%, Libraries\%name%, UTF-8
				FileAppend, %txt%, Libraries\%v_SelectHotstringLibrary%, UTF-8
		}
	;the new added definition
		LV_GetText(txt1, SectionList.MaxIndex(), 2)
		LV_GetText(txt2, SectionList.MaxIndex(), 1)
		LV_GetText(txt3, SectionList.MaxIndex(), 3)
		LV_GetText(txt4, SectionList.MaxIndex(), 4)
		LV_GetText(txt5, SectionList.MaxIndex(), 5)
		LV_GetText(txt6, SectionList.MaxIndex(), 6)
		txt := % txt1 . "‖" . txt2 . "‖" . txt3 . "‖" . txt4 . "‖" . txt5 . "‖" . txt6
	;FileAppend, %txt%, Libraries\%name%, UTF-8
		FileAppend, %txt%, Libraries\%v_SelectHotstringLibrary%, UTF-8
	}
	;7. Increment library counter.
	GuiControl, Text, % IdText11, % v_NoOfHotstringsInLibrary . A_Space . ++v_LibHotstringCnt	
	
	MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ": information", Hotstring added to the %v_SelectHotstringLibrary% file! ; Future: add to translation.
	
	return
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Clear: 
Gui,		%HS3Hwnd%: Font, % "c" . c_FontColor
GuiControl, Font, % IdCheckBox1
GuiControl,, % IdEdit1,  				;v_TriggerString
GuiControl, Font, % IdCheckBox1
GuiControl,, % IdCheckBox1, 0
GuiControl, Font, % IdCheckBox2
GuiControl,, % IdCheckBox2, 0
GuiControl, Font, % IdCheckBox3
GuiControl,, % IdCheckBox3, 0
GuiControl, Font, % IdCheckBox4
GuiControl,, % IdCheckBox4, 0
GuiControl, Font, % IdCheckBox5
GuiControl,, % IdCheckBox5, 0
GuiControl, Font, % IdCheckBox6
GuiControl,, % IdCheckBox6, 0
GuiControl, Choose, % IdDDL1, SendInput (SI) ;v_SelectFunction 
GuiControl,, % IdEdit2,  				;v_EnterHotstring
GuiControl,, % IdEdit3, 					;v_EnterHotstring1
GuiControl, Disable, % IdEdit3 			;v_EnterHotstring1
GuiControl,, % IdEdit4, 					;v_EnterHotstring2
GuiControl, Disable, % IdEdit4 			;v_EnterHotstring2
GuiControl,, % IdEdit5, 					;v_EnterHotstring3
GuiControl, Disable, % IdEdit5 			;v_EnterHotstring3
GuiControl,, % IdEdit6, 					;v_EnterHotstring4
GuiControl, Disable, % IdEdit6 			;v_EnterHotstring4
GuiControl,, % IdEdit7, 					;v_EnterHotstring5
GuiControl, Disable, % IdEdit7 			;v_EnterHotstring5
GuiControl,, % IdEdit8, 					;v_EnterHotstring6
GuiControl, Disable, % IdEdit8 			;v_EnterHotstring6
GuiControl,, % IdEdit9,  				;Comment
GuiControl,, % IdDDL2, | 				;v_SelectHotstringLibrary o make the control empty, specify only a pipe character (|)
Loop,%A_ScriptDir%\Libraries\*.csv
	GuiControl,, % IdDDL2, %A_LoopFileName%
GuiControl, Disable, % IdButton4
LV_Delete()
GuiControl,, % IdEdit10,  				;Sandbox

/*
	GuiControl,, v_ViewString,
	GuiControl,, v_Comment,
	GuiControl,, v_EnterHotstring1,
	GuiControl,, v_EnterHotstring2,
	GuiControl,, v_EnterHotstring3,
	GuiControl,, v_EnterHotstring4,
	GuiControl,, v_EnterHotstring5,
	GuiControl,, v_EnterHotstring6,
	GuiControl,, v_SelectHotstringLibrary, |
	GuiControl, Choose, v_SelectFunction, SendInput (SI)
	Loop,%A_ScriptDir%\Libraries\*.csv
		GuiControl, , v_SelectHotstringLibrary, %A_LoopFileName%
	gosub, SectionChoose
	gosub, ViewString
*/
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

HSLV: ; copy content of List View 1 to editable fields of HS3 Gui
Gui, HS3:+OwnDialogs
/*
	v_PreviousSelectedRow := v_SelectedRow ;this line rather as finishing this label section
	If !(v_SelectedRow := LV_GetNext()) {
		Return
	}
	if (v_PreviousSelectedRow == v_SelectedRow) and !(v_TriggerString == "")
	{
		return
	}
*/
if !(v_SelectedRow := LV_GetNext())
	return


LV_GetText(v_TriggerString, 	v_SelectedRow, 1)
	;GuiControl, , v_TriggerString, % v_TriggerStringvar
GuiControl, , % IdEdit1, % v_TriggerString

LV_GetText(Options, 		v_SelectedRow, 2)
Instr(Options,"*0") or (InStr(Options,"*") = 0) 							? F_CheckOption("No", 1) 	: F_CheckOption("Yes", 1)
((Instr(Options,"C0")) or (Instr(Options,"C1")) or (Instr(Options,"C") = 0)) 	? F_CheckOption("No", 2) 	: F_CheckOption("Yes", 2)
Instr(Options,"B0") 												? F_CheckOption("Yes", 3) 	: F_CheckOption("No", 3)
Instr(Options,"?") 													? F_CheckOption("Yes", 4) 	: F_CheckOption("No", 4)
(Instr(Options,"O0") or (InStr(Options,"O") = 0)) 						? F_CheckOption("No", 5) 	: F_CheckOption("Yes", 5)

LV_GetText(Fun, 			v_SelectedRow, 3)
if (Fun = "SI")
{
	;SendFun := "F_NormalWay"
	GuiControl, Choose, v_SelectFunction, SendInput (SI)
}
else if (Fun = "CL")
{
	;SendFun := "F_ViaClipboard"
	GuiControl, Choose, v_SelectFunction, Clipboard (CL)
}
else if (Fun = "MCL")
{
	;SendFun := "F_MenuText"
	GuiControl, Choose, v_SelectFunction, Menu & Clipboard (MCL)
}
else if (Fun = "MSI")
{
	;SendFun := "F_MenuTextAHK"
	GuiControl, Choose, v_SelectFunction, Menu & SendInput (MSI)
}

LV_GetText(EnDis, 		v_SelectedRow, 4)
InStr(EnDis, "En") ? F_CheckOption("No", 6) : F_CheckOption("Yes", 6)

LV_GetText(TextInsert, 	v_SelectedRow, 5)
if ((Fun = "MCL") or (Fun = "MSI"))
{
	OTextMenu := StrSplit(TextInsert, "¦")
	GuiControl, , v_EnterHotstring,  % OTextMenu[1]
	GuiControl, , v_EnterHotstring1, % OTextMenu[2]
	GuiControl, , v_EnterHotstring2, % OTextMenu[3]
	GuiControl, , v_EnterHotstring3, % OTextMenu[4]
	GuiControl, , v_EnterHotstring4, % OTextMenu[5]
	GuiControl, , v_EnterHotstring5, % OTextMenu[6]
	GuiControl, , v_EnterHotstring6, % OTextMenu[7]
	
}
else
{
	GuiControl, , v_EnterHotstring, % TextInsert
}


LV_GetText(Comment, 	v_SelectedRow, 6)
GuiControl,, v_Comment, %Comment%

/*
	If (EnDis == "En")
		OnOff := "On"
	else if (EnDis == "Dis")
		OnOff := "Off"
	v_String := % "Hotstring("":" . Options . ":" . v_TriggerString . """, func(""" . SendFun . """).bind(""" . TextInsert . """), """ . OnOff . """)"
	
	a_String := StrSplit(v_String, """")
	HotString2 := StrSplit(a_String[2],":")
	v_TriggerStringvar := SubStr(a_String[2], StrLen( ":" . HotString2[2] . ":" ) + 1, StrLen(a_String[2])-StrLen(  ":" . HotString2[2] . ":" ))
	RText := StrSplit(v_String, "bind(""")
	if InStr(RText[2], """On""")
	{
		OText := SubStr(RText[2], 1, StrLen(RText[2])-9)
	}
	else
	{    
		OText := SubStr(RText[2], 1, StrLen(RText[2])-10)
	}
	;GuiControl, , v_TriggerString, % v_TriggerStringvar
	if (InStr(v_String, """F_MenuText""") or InStr(v_String, """F_MenuTextAHK"""))
	{
		OTextMenu := StrSplit(OText, "¦")
		GuiControl, , v_EnterHotstring,  % OTextMenu[1]
		GuiControl, , v_EnterHotstring1, % OTextMenu[2]
		GuiControl, , v_EnterHotstring2, % OTextMenu[3]
		GuiControl, , v_EnterHotstring3, % OTextMenu[4]
		GuiControl, , v_EnterHotstring4, % OTextMenu[5]
		GuiControl, , v_EnterHotstring5, % OTextMenu[6]
		GuiControl, , v_EnterHotstring6, % OTextMenu[7]
		
	}
	else
	{
		GuiControl, , v_EnterHotstring, % OText
	}
	
	
	Instr(Hotstring2[2],"*0") or (InStr(Hotstring2[2],"*") = 0) ? F_CheckOption("No", 1) :  F_CheckOption("Yes", 1)
	((Instr(Hotstring2[2],"C0")) or (Instr(Hotstring2[2],"C1")) or (Instr(Hotstring2[2],"C") = 0)) ? F_CheckOption("No", 2) : F_CheckOption("Yes", 2)
	Instr(Hotstring2[2],"B0") ? F_CheckOption("Yes", 3) : F_CheckOption("No", 3)
	Instr(Hotstring2[2],"?") ? F_CheckOption("Yes", 4) : F_CheckOption("No", 4)
	(Instr(Hotstring2[2],"O0") or (InStr(Hotstring2[2],"O") = 0)) ? F_CheckOption("No", 5) : F_CheckOption("Yes", 5)
	InStr(v_String, """On""") ? F_CheckOption("No", 6) : F_CheckOption("Yes", 6)
*/

;v_CaseSensitiveC1 := 0
gosub L_SelectFunction
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

HSLV2:
Gui, HS3List:+OwnDialogs
v_PreviousSelectedRow2 := v_SelectedRow2
If !(v_SelectedRow2 := LV_GetNext()) {
	Return
}
if (v_PreviousSelectedRow2 == v_SelectedRow2)
{
	return
}
LV_GetText(Options, v_SelectedRow2, 3)
LV_GetText(v_TriggerString, v_SelectedRow2, 2)
LV_GetText(Fun, v_SelectedRow2, 4)
if (Fun = "SI")
{
	SendFun := "F_NormalWay"
}
else if (Fun = "CL")
{
	SendFun := "F_ViaClipboard"
}
else if (Fun = "MCL")
{
	SendFun := "F_MenuText"
}
else if (Fun = "MSI")
{
	SendFun := "F_MenuTextAHK"
}
LV_GetText(TextInsert, v_SelectedRow2, 6)
LV_GetText(EnDis, v_SelectedRow2, 5)
If (EnDis == "En")
	OnOff := "On"
else if (EnDis == "Dis")
	OnOff := "Off"
LV_GetText(Library, v_SelectedRow2, 1)
Gui, HS3: Default
ChooseSec := % Library . ".csv"
;v_String := % "Hotstring("":" . Options . ":" . v_TriggerString . """, func(""" . SendFun . """).bind(""" . TextInsert . """), """ . OnOff . """)"
;GuiControl,, v_ViewString ,  %v_String%
;gosub, ViewString
GuiControl, Choose, v_SelectHotstringLibrary, %ChooseSec%
F_SectionChoose()
	;gosub, SectionChoose
v_SearchedTriggerString := v_TriggerString
Loop
{
	LV_GetText(v_TriggerString,A_Index,1)
	if (v_TriggerString == v_SearchedTriggerString)
	{
		v_SelectedRow := A_Index
		LV_Modify(v_SelectedRow, "Vis")
		LV_Modify(v_SelectedRow, "+Select +Focus")
		break
	}
}
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

AddLib:
Gui, ALib:New, -Border
Gui, ALib:Add, Text,, % TransA["Enter a name for the new library"]
Gui, ALib:Add, Edit, % "vNewLib w" . 150*DPI%v_SelectedMonitor%,
Gui, ALib:Add, Text, % "x+" . 10*DPI%v_SelectedMonitor%, .csv
Gui, ALib:Add, Button, % "Default gALibOK xm w" . 70*DPI%v_SelectedMonitor%, OK
Gui, ALib:Add, Button, % "gALibGuiClose x+" . 10*DPI%v_SelectedMonitor% . " w" . 70*DPI%v_SelectedMonitor%, % TransA["Cancel"]
WinGetPos, v_PreviousX, v_PreviousY , , ,Hotstrings
Gui, ALib:Show, % "x" . ((v_PreviousX+v_PreviousWidth)/2)/DPI%v_SelectedMonitor% . " y" . ((v_PreviousY+v_PreviousHeight)/2)/DPI%v_SelectedMonitor%
return

ALibOK:
Gui,ALib:Submit, NoHide
if (NewLib == "")
{
	MsgBox, % TransA["Enter a name for the new library"]
	return
}
NewLib .= ".csv"
IfNotExist, Libraries
	FileCreateDir, Libraries
IfNotExist, Libraries\%NewLib%
{
	FileAppend,, Libraries\%NewLib%, UTF-8
	MsgBox, % TransA["The library"] . A_Space . NewLib . A_Space . TransA["has been created."]
	Gui, ALib:Destroy
	GuiControl, HS3:, v_SelectHotstringLibrary, | ;To make the control empty, specify only a pipe character (|).
	Loop,%A_ScriptDir%\Libraries\*.csv
		GuiControl,HS3: , v_SelectHotstringLibrary, %A_LoopFileName%
}
Else
	MsgBox, % TransA["A library with that name already exists!"]
return

ALibGuiEscape:
ALibGuiClose:
Gui, ALib:Destroy
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

F_SectionChoose()
{
	global ;assume-global mode
	local str1 := []
	
	Gui, HS3:Submit, NoHide
	Gui, HS3:+OwnDialogs
	
	GuiControl, Enable, % IdButton4 ; button Delete hotstring (F8)
	Gui, ListView, % IdListView1 ; identify which ListView
	LV_Delete()
	FileRead, Text, Libraries\%v_SelectHotstringLibrary%
	
	SectionList := StrSplit(Text, "`r`n")
	
	Loop, % SectionList.MaxIndex()
	{
		str1 := StrSplit(SectionList[A_Index], "‖")
		if (InStr(str1[1], "*0"))
		{
			str1[1] := StrReplace(str1[1], "*0")
		}
		if (InStr(str1[1], "O0"))
		{
			str1[1] := StrReplace(str1[1], "O0")
		}
		if (InStr(str1[1], "C0"))
		{
			str1[1] := StrReplace(str1[1], "C0")
		}
		if (InStr(str1[1], "?0"))
		{
			str1[1] := StrReplace(str1[1], "?0")
		}
		if (InStr(str1[1], "B")) and !(InStr(str1[1], "B0"))
		{
			str1[1] := StrReplace(str1[1], "B")
		}
		LV_Add("", str1[2], str1[1], str1[3], str1[4],str1[5], str1[6])			
	}
	LV_ModifyCol(1, "Sort")
	
	v_LibHotstringCnt := LV_GetCount()
	GuiControl, Text, % IdText11, % v_NoOfHotstringsInLibrary . A_Space . v_LibHotstringCnt
	
	return
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

L_SelectFunction:
Gui, HS3:+OwnDialogs
GuiControlGet, v_SelectFunction
if InStr(v_SelectFunction, "Menu")
{
	GuiControl, Enable, v_EnterHotstring1
	GuiControl, Enable, v_EnterHotstring2
	GuiControl, Enable, v_EnterHotstring3
	GuiControl, Enable, v_EnterHotstring4
	GuiControl, Enable, v_EnterHotstring5
	GuiControl, Enable, v_EnterHotstring6
}
else
{
	GuiControl, , v_EnterHotstring1
	GuiControl, , v_EnterHotstring2
	GuiControl, , v_EnterHotstring3
	GuiControl, , v_EnterHotstring4
	GuiControl, , v_EnterHotstring5
	GuiControl, , v_EnterHotstring6
	GuiControl, Disable, v_EnterHotstring1
	GuiControl, Disable, v_EnterHotstring2
	GuiControl, Disable, v_EnterHotstring3
	GuiControl, Disable, v_EnterHotstring4
	GuiControl, Disable, v_EnterHotstring5
	GuiControl, Disable, v_EnterHotstring6
}
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

CapsCheck:
If (Instr(a_String[2], "C1"))
	v_CaseSensitiveC1 := 1
GuiControlGet, OutputVar1, Focus
GuiControlGet, OutputVar2, , %OutputVar1%
F_CheckBoxColor(OutputVar2,OutputVar1)
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

/*
	SetOptions:
	OptionSet := Instr(Hotstring2[2],"*0") or InStr(Hotstring2[2],"*") = 0 ? F_CheckOption("No",2) :  F_CheckOption("Yes",2)
	OptionSet := ((Instr(Hotstring2[2],"C0")) or (Instr(Hotstring2[2],"C1")) or (Instr(Hotstring2[2],"C") = 0)) ? F_CheckOption("No",3) : F_CheckOption("Yes",3)
	OptionSet := Instr(Hotstring2[2],"B0") ? F_CheckOption("Yes",4) : F_CheckOption("No",4)
	OptionSet := Instr(Hotstring2[2],"?") ? F_CheckOption("Yes",5) : F_CheckOption("No",5)
	OptionSet := (Instr(Hotstring2[2],"O0") or (InStr(Hotstring2[2],"O") = 0)) ? F_CheckOption("No",6) : F_CheckOption("Yes",6)
	GuiControlGet, v_ViewString
	Select := v_ViewString
	if Select = ; !!!
		return
	OptionSet := (InStr(Select,"""On""")) ? F_CheckOption("No", 7) : F_CheckOption("Yes",7)
	if(InStr(Select,"F_NormalWay"))
		GuiControl, Choose, v_SelectFunction, SendInput (SI)
	else if(InStr(Select, "F_ViaClipboard"))
		GuiControl, Choose, v_SelectFunction, Clipboard (CL)
	else if(InStr(Select, """F_MenuText"""))
		GuiControl, Choose, v_SelectFunction, Menu & Clipboard (MCL)
	else if(InStr(Select, """F_MenuTextAHK"""))
		GuiControl, Choose, v_SelectFunction, Menu & SendInput (MSI)
	v_CaseSensitiveC1 := 0
	return
*/

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

/*
	OptionString:
	Options := ""
	
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
	
	a_String[2] := Options
	Return
*/

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

/*
	SaveHotstrings:
	Gui, HS3:+OwnDialogs
	
	EnDis := ""
	SendFun := ""
	if (v_OptionDisable)
		EnDis := "Dis"
	else
		EnDis := "En"
	
	
	if (v_SelectFunction == "Clipboard (CL)")
		SendFun := "CL"
	else if (v_SelectFunction == "SendInput (SI)")
		SendFun := "SI"
	else if (v_SelectFunction == "Menu & Clipboard (MCL)")
		SendFun := "MCL"
	else if (v_SelectFunction == "Menu & SendInput (MSI)")
		SendFun := "MSI"
	
	
	;StrSp 		:= StrSplit(Items, "bind(""")
	;StrSp 		:= StrSplit(v_String, "bind(""")
	;StrSp1 		:= StrSplit(StrSp[2], """),")
	;TextInsert 	:= StrSp1[1]
	OutputFile 	:= % A_ScriptDir . "\Libraries\temp.csv"	; changed on 2021-02-13
	;InputFile 	:= % A_ScriptDir . "\Libraries\" . SaveFile . ".csv"
	InputFile 	:= % A_ScriptDir . "\Libraries\" . v_SelectHotstringLibrary 
	LString 		:= % "‖" . v_TriggerString . "‖"
	SaveFlag 		:= 0 ;true/false variable, if true, duplicate definition is found, if false, definition is new
	
	Loop, Read, %InputFile%, %OutputFile% ;read all definitions from this library file 
	{
		if (InStr(A_LoopReadLine, LString, 1) and InStr(Options, "C")) or (InStr(A_LoopReadLine, LString) and !(InStr(Options, "C")))
		{
			if !(v_SelectedRow)
			{
				;MsgBox, 4,, % t_TheHostring . " """ .  v_TriggerString . """ " .  TransA["exists in a file"] . " " . SaveFile . t_CsvDoYouWantToProceed
				MsgBox, 4,, % t_TheHostring . " """ .  v_TriggerString . """ " .  TransA["exists in a file"] . " " . v_SelectHotstringLibrary . t_CsvDoYouWantToProceed
				IfMsgBox, No
					return
			}
			LV_Modify(A_Index, "", v_TriggerString, Options, SendFun, EnDis, TextInsert, v_Comment)
			SaveFlag := 1
		}
	}
	if (SaveFlag == 0) 
	{
		LV_Add("",  v_TriggerString, Options, SendFun, EnDis, TextInsert, v_Comment)
		txt := % Options . "‖" . v_TriggerString . "‖" . SendFun . "‖" . EnDis . "‖" . TextInsert . "‖" . v_Comment ;tylko to się liczy
		SectionList.Push(txt)
	}
	LV_ModifyCol(1, "Sort")
	FileDelete, %InputFile%
	if (SectionList.MaxIndex() == "") ;in order to speed up it's checked if library isn't empty.
	{
		LV_GetText(txt1, 1, 2)
		LV_GetText(txt2, 1, 1)
		LV_GetText(txt3, 1, 3)
		LV_GetText(txt4, 1, 4)
		LV_GetText(txt5, 1, 5)
		LV_GetText(txt6, 1, 6)
		txt := % txt1 . "‖" . txt2 . "‖" . txt3 . "‖" . txt4 . "‖" . txt5 . "‖" . txt6
		;FileAppend, %txt%, Libraries\%name%, UTF-8
		FileAppend, %txt%, Libraries\%v_SelectHotstringLibrary%, UTF-8
	}
	else
	{ ;no idea why this is duplicated...
		Loop, % SectionList.MaxIndex()-1
		{
			LV_GetText(txt1, A_Index, 2)
			LV_GetText(txt2, A_Index, 1)
			LV_GetText(txt3, A_Index, 3)
			LV_GetText(txt4, A_Index, 4)
			LV_GetText(txt5, A_Index, 5)
			LV_GetText(txt6, A_Index, 6)
			txt := % txt1 . "‖" . txt2 . "‖" . txt3 . "‖" . txt4 . "‖" . txt5 . "‖" . txt6 . "`r`n"
			if !((txt1 == "") and (txt2 == "") and (txt3 == "") and (txt4 == "") and (txt5 == "") and (txt6 == "")) ;only not empty definitions are added, not sure why
				;FileAppend, %txt%, Libraries\%name%, UTF-8
				FileAppend, %txt%, Libraries\%v_SelectHotstringLibrary%, UTF-8
		}
		;the new added definition
		LV_GetText(txt1, SectionList.MaxIndex(), 2)
		LV_GetText(txt2, SectionList.MaxIndex(), 1)
		LV_GetText(txt3, SectionList.MaxIndex(), 3)
		LV_GetText(txt4, SectionList.MaxIndex(), 4)
		LV_GetText(txt5, SectionList.MaxIndex(), 5)
		LV_GetText(txt6, SectionList.MaxIndex(), 6)
		txt := % txt1 . "‖" . txt2 . "‖" . txt3 . "‖" . txt4 . "‖" . txt5 . "‖" . txt6
		;FileAppend, %txt%, Libraries\%name%, UTF-8
		FileAppend, %txt%, Libraries\%v_SelectHotstringLibrary%, UTF-8
	}
	MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ": information", Hotstring added to the %v_SelectHotstringLibrary% file! ; Future: add to translation.
	return
*/

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
	
	Gui, HS3:+OwnDialogs
	
	if !(v_SelectedRow := LV_GetNext()) 
	{
		MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ": information",  % TransA["Select a row in the list-view, please!"] ;Future: translate "information"
		;MsgBox, 0, %A_ThisLabel%, %t_SelectARowInTheListViewPlease%
		return
	}
	MsgBox, 324, % SubStr(A_ScriptName, 1, -4) . ": information", % TransA["Selected Hotstring will be deleted. Do you want to proceed?"] ;Future: translate "information"
	IfMsgBox, No
		return
	TrayTip, %A_ScriptName%, % TransA["Deleting hotstring..."], 1
	
	/*
		Gui, ProgressDelete:New, -Border -Resize
		Gui, ProgressDelete:Add, Progress, w200 h20 cBlue vProgressDelete, 0
		Gui, ProgressDelete:Add,Text,w200 vTextDelete, % TransA["Deleting hotstring. Please wait..."]
		Gui, ProgressDelete:Show, hide, ProgressDelete
		WinGetPos, v_WindowX, v_WindowY ,v_WindowWidth,v_WindowHeight,Hotstrings
		DetectHiddenWindows, On
		WinGetPos, , , DeleteWindowWidth, DeleteWindowHeight,ProgressDelete
		DetectHiddenWindows, Off
		Gui, ProgressDelete:Show,% "x" . v_WindowX + (v_WindowWidth - DeleteWindowWidth)/2 . " y" . v_WindowY + (v_WindowHeight - DeleteWindowHeight)/2 ,ProgressDelete
	*/
	
	;1. Remove selected library file.
	LibraryFullPathAndName := A_ScriptDir . "\Libraries\" . v_SelectHotstringLibrary
	FileDelete, % LibraryFullPathAndName
	;cntDelete := 0
	;Gui, HS3:Default
	
	;2. Create library file of the same name as selected. its content will contain LV but without selected row.
	if (v_SelectedRow == SectionList.MaxIndex())
	{
		if (SectionList.MaxIndex() == 1)
		{
			FileAppend,, % LibraryFullPathAndName, UTF-8
			;GuiControl,, ProgressDelete, 100
		}
		else
		{
			Loop, % SectionList.MaxIndex()-1
			{
				if !(A_Index == v_SelectedRow)
				{
					LV_GetText(txt1, A_Index, 2)
					LV_GetText(txt2, A_Index, 1)
					LV_GetText(txt3, A_Index, 3)
					LV_GetText(txt4, A_Index, 4)
					LV_GetText(txt5, A_Index, 5)
					LV_GetText(txt6, A_Index, 6)
					if (A_Index == SectionList.MaxIndex()-1)
						txt := % txt1 . "‖" . txt2 . "‖" . txt3 . "‖" . txt4 . "‖" . txt5 . "‖" . txt6
					else
						txt := % txt1 . "‖" . txt2 . "‖" . txt3 . "‖" . txt4 . "‖" . txt5 . "‖" . txt6 . "`r`n"
					if !((txt1 == "") and (txt2 == "") and (txt3 == "") and (txt4 == "") and (txt5 == "") and (txt6 == ""))
						FileAppend, %txt%, % LibraryFullPathAndName, UTF-8
					;v_DeleteProgress := (A_Index/(SectionList.MaxIndex()-1))*100
					;Gui, ProgressDelete:Default
					;GuiControl,, ProgressDelete, %v_DeleteProgress%
					;Gui, HS3:Default
				}
			}
		}
	}
	else
	{
		Loop, % SectionList.MaxIndex()
		{
			if !(A_Index == v_SelectedRow)
			{
				LV_GetText(txt1, A_Index, 2)
				LV_GetText(txt2, A_Index, 1)
				LV_GetText(txt3, A_Index, 3)
				LV_GetText(txt4, A_Index, 4)
				LV_GetText(txt5, A_Index, 5)
				LV_GetText(txt6, A_Index, 6)
				if (A_Index == SectionList.MaxIndex())
					txt := % txt1 . "‖" . txt2 . "‖" . txt3 . "‖" . txt4 . "‖" . txt5 . "‖" . txt6
				else
					txt := % txt1 . "‖" . txt2 . "‖" . txt3 . "‖" . txt4 . "‖" . txt5 . "‖" . txt6 . "`r`n"
				if !((txt1 == "") and (txt2 == "") and (txt3 == "") and (txt4 == "") and (txt5 == "") and (txt6 == ""))
					FileAppend, %txt%, % LibraryFullPathAndName, UTF-8
				;v_DeleteProgress := (A_Index/(SectionList.MaxIndex()-1))*100
				;Gui, ProgressDelete:Default
				;GuiControl,, ProgressDelete, %v_DeleteProgress%
				;Gui, HS3:Default
			}
		}
	}
	;3. Remove selected row from List View.
	LV_Delete(v_SelectedRow)
	;4. Disable selected hotstring.
	
	Try
		Hotstring(":" . Options . ":" . v_TriggerString, , "Off")
	Catch
		MsgBox, 16, % SubStr(A_ScriptName, 1, -4) . ":" . A_ThisFunc, % "Error, something went wrong with hotstring deletion:" . A_Space . v_TriggerString . A_Space . "Library name:" . A_Space . v_SelectHotstringLibrary ;Future: translate this.
	
	;5. Remove trigger hint.
	Loop, % a_Triggers.MaxIndex()
	{
		if (InStr(a_Triggers[A_Index], v_TriggerString))
			a_Triggers.RemoveAt(A_Index)
	}
	TrayTip, %A_ScriptName%, Specified definition of hotstring has been deleted, 1 ;Future: add to translate 
	;Gui, ProgressDelete:Destroy
	;MsgBox, % Hotstring has been deleted. Now application will restart itself in order to apply changes, reload the libraries (.csv)
	;WinGetPos, v_PreviousX, v_PreviousY , , ,Hotstrings
	;Run, AutoHotkey.exe Hotstrings.ahk %v_Param% %v_SelectHotstringLibrary% %v_PreviousWidth% %v_PreviousHeight% %v_PreviousX% %v_PreviousY% %v_SelectedRow% %v_SelectedMonitor%	
	
	;6. Decrement library counter.
	GuiControl, Text, % IdText11, % v_NoOfHotstringsInLibrary . A_Space . --v_LibHotstringCnt
	
	return
}

;In AutoHotkey there is no Guicontrol, Delete sub-command. As a consequence even if specific control is hidden (Guicontrol, Hide), the Gui size isn't changed, size is not decreased, as space for hidden control is maintained. To solve this issue, the separate gui have to be prepared. This requires a lot of work and is a matter of far future.
F_ToggleRightColumn() ;Label of Button IdButton5, to toggle left part of gui 
{
	global ;assume-global mode
	
	if !(v_ToggleRightColumn) ;hide
	{
		GuiControl, Hide, % IdText7		;Library content (F2)
		GuiControl, Hide, % IdListView1 	;ListView
		GuiControl, Hide, % IdText10  	;Sandbox text
		GuiControl, Hide, % IdEdit10  	;Sandbox Edit box
		GuiControl, Hide, % IdText8		;Long text
		GuiControl, Hide, % IdText2		;Total hotstring counter
		GuiControl, Hide, % IdText11		;Library hotstring counter
		GuiControl,, % IdButton5,  ⯈
	}
	else					;show
	{
		GuiControl, Show, % IdText7		;Library content (F2)
		GuiControl, Show, % IdListView1 	;ListView
		GuiControl, Show, % IdText10  	;Sandbox text
		GuiControl, Show, % IdEdit10  	;Sandbox Edit box
		GuiControl, Show, % IdText8		;Long text
		GuiControl, Show, % IdText2		;Total hotstring counter
		GuiControl, Show, % IdText11		;Library hotstring counter
		GuiControl,, % IdButton5, ⯇
	}
	v_ToggleRightColumn := !v_ToggleRightColumn
	return
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -	

DestroyGuis:
Loop, %N%
{
	Gui, %A_Index%:Destroy
}
Gui, Font ; restore the font to the system's default GUI typeface, size and colour.
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

HSdelay:
; Future: Add those strings to translations.
Gui, HSDel:New, -MinimizeBox -MaximizeBox
Gui, HSDel:Margin, 12.5*DPI%v_SelectedMonitor%, 7.5*DPI%v_SelectedMonitor%
Gui, HSDel:Font, % "s" . 12*DPI%v_SelectedMonitor% . " norm cBlack"
Gui, HSDel:Add, Slider, % "w" . 340*DPI%v_SelectedMonitor% . " vMySlider gmySlider Range100-1000 ToolTipBottom Buddy1999", %ini_Delay%
Gui, HSDel:Add, Text,% "yp+" . 62.5*DPI%v_SelectedMonitor% . " xm+" . 10*DPI%v_SelectedMonitor% . " vDelayText" , Hotstring paste from Clipboard delay %ini_Delay% ms
Gui, HSDel:Show, % "w" . 380*DPI%v_SelectedMonitor% . " h" . 112.5*DPI%v_SelectedMonitor% . " hide", Set Clipboard Delay
WinGetPos, v_WindowX, v_WindowY ,v_WindowWidth,v_WindowHeight,Hotstrings
DetectHiddenWindows, On
WinGetPos, , , DelayWindowWidth, DelayWindowHeight,Set Clipboard Delay
DetectHiddenWindows, Off
Gui, HSDel:Show,% "x" . v_WindowX + (v_WindowWidth - DelayWindowWidth)/2 . " y" . v_WindowY + (v_WindowHeight - DelayWindowHeight)/2 ,Set Clipboard Delay

return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

MySlider:
ini_Delay := MySlider
if (ini_Delay = 1000)
	GuiControl,, DelayText, % TransA["Hotstring paste from Clipboard delay 1 s"]
else
	GuiControl,, DelayText, % TransA["Hotstring paste from Clipboard delay"] . " " . ini_Delay . " ms"
IniWrite, %ini_Delay%, Config.ini, Configuration, Delay
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;tu jestem
L_About:
Gui, MyAbout: Destroy
;Gui, MyAbout: Font, % "bold s" . c_FontSize*DPI%v_SelectedMonitor%, Calibri
Gui, MyAbout: Font, % "bold s" . c_FontSize, Calibri
Gui, MyAbout: Add, Text, , % TransA["Let's make your PC personal again..."]
;Gui, MyAbout: Font, % "norm s" . c_FontSize*DPI%v_SelectedMonitor%
Gui, MyAbout: Font, % "norm s" . c_FontSize
Gui, MyAbout: Add, Text, , % TransA["Enables Convenient Definition"]
;Gui, MyAbout: Font, % "CBlue bold Underline s" . c_FontSize*DPI%v_SelectedMonitor%
Gui, MyAbout: Font, % "CBlue bold Underline s" . c_FontSize
Gui, MyAbout: Add, Text, gLink, % TransA["Application help"]
Gui, MyAbout: Add, Text, gLink2, % TransA["Genuine hotstrings AutoHotkey documentation"]
;Gui, MyAbout: Font, % "norm s" . c_FontSize*DPI%v_SelectedMonitor%
Gui, MyAbout: Font, % "norm s" . c_FontSize
;Gui, MyAbout: Add, Button, % "Default Hidden w" . 100*DPI%v_SelectedMonitor% . " gMyOK vOkButtonVariabl hwndOkButtonHandle", &OK
Gui, MyAbout: Add, Button, % "Default Hidden w" . 100 . " gMyOK vOkButtonVariabl hwndOkButtonHandle", &OK ;Future: translate
GuiControlGet, MyGuiControlGetVariable, MyAbout: Pos, %OkButtonHandle%
WinGetPos, v_WindowX, v_WindowY ,v_WindowWidth, v_WindowHeight, Hotstrings
;Gui, MyAbout:Show,% "hide w" . 670*DPI%v_SelectedMonitor% . "h" . 220*DPI%v_SelectedMonitor%, About/Help
Gui, MyAbout:Show, % "hide w" . 670 . "h" . 220, % TransA["About/Help"]
DetectHiddenWindows, On
WinGetPos, , , MyAboutWindowWidth, MyAboutWindowHeight, % TransA["About/Help"]
DetectHiddenWindows, Off
;NewButtonXPosition := round((( MyAboutWindowWidth- 100*DPI%v_SelectedMonitor%)/2)*DPI%v_SelectedMonitor%)
;NewButtonXPosition := round((MyAboutWindowWidth- 100)/2)
NewButtonXPosition := round(MyAboutWindowWidth/2)
GuiControl, Move, %OkButtonHandle%, x%NewButtonXPosition%
GuiControl, Show, %OkButtonHandle%
;Gui, MyAbout: Show, % "x" . v_WindowX + (v_WindowWidth - MyAboutWindowWidth)/2 . " y" . v_WindowY + (v_WindowHeight - MyAboutWindowHeight)/2, % TransA["About/Help"]
Gui, MyAbout: Show
return  

Link:
Run, https://github.com/mslonik/Hotstrings
return

Link2:
Run, https://www.autohotkey.com/docs/Hotstrings.htm
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
~F1::
MyOK:
MyAboutGuiEscape:
MyAboutGuiClose: ; Launched when the window is closed by pressing its X button in the title bar.
Gui, MyAbout: Destroy
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

;Future: for some reasons size of Gui window can change rapidly by 20-30 px. It could be fixed by software routine, which checks if size  wasn't changed between last F_AutoXYWH("reset") and next function call.
HS3GuiSize() ;Gui event
{
	global ;assume-global mode
;Within a function, to create a set of variables that is local instead of global, declare OutputVar as a local variable prior to using command GuiControlGet, Pos. However, it is often also necessary to declare each variable in the set, due to a common source of confusion.	
	local v_OutVarTemp1 := 0, v_OutVarTemp1X := 0, v_OutVarTemp1Y := 0, v_OutVarTemp1W := 0, v_OutVarTemp1H := 0
		,v_OutVarTemp2 := 0, v_OutVarTemp2X := 0, v_OutVarTemp2Y := 0, v_OutVarTemp2W := 0, v_OutVarTemp2H := 0
	
	OutputDebug, % "Beginning:" . A_Space . ++CntGuiSize 
	OutputDebug, % "A_GuiWidth:" . A_Space . A_GuiWidth . A_Space . "A_GuiHeight:" . A_Space .  A_GuiHeight
	
	if (A_EventInfo = 1) ; The window has been minimized.
		return
	if (v_ResizingFlag) ;Special case: FontSize set to 16 and some procedures are run twice
	{
		OutputDebug, return because of "v_ResizingFlag"
		return
	}
	if (A_EventInfo = 2)
	{
		MsgBox, , maximized
		OutputDebug, return because of "A_EventInfo = 2"
		return
	}
	
	GuiControlGet, v_OutVarTemp1, Pos, % IdListView1 ;This line will be used for "if" and "else" statement.
	
	if (b_SandboxResize != ini_Sandbox) ; if configuration of HS3 window was toggled at least once, toggle Sandbox
	{
		if (ini_Sandbox) ;reduce size of List View and draw sandbox
		{
			if (c_ymarg + HofText + v_OutVarTemp1H > LeftColumnH)
			{
				GuiControl, Show, % IdText10 ;sandobx text
				GuiControl, MoveDraw, % IdText10, % "x" c_xmarg "y" LeftColumnH + c_ymarg
				GuiControl, Show, % IdEdit10 ;sandbox edit field
				GuiControl, MoveDraw, % IdEdit10, % "x" c_xmarg "y" LeftColumnH + c_ymarg + HofText "w" LeftColumnW - c_xmarg
				IsSandboxMoved := true
			}
			if (c_ymarg + HofText + v_OutVarTemp1H <= LeftColumnH + c_ymarg + HofText + c_HofSandbox)
			{
				GuiControl, MoveDraw, % IdListView1, % "h" v_OutVarTemp1H - (HofText + c_HofSandbox + c_ymarg)
				GuiControl, Show, % IdText10 ;sandobx text
				GuiControl, MoveDraw, % IdText10, % "x" v_OutVarTemp1X  "y" v_OutVarTemp1Y + v_OutVarTemp1H - (HofText + c_HofSandbox + c_ymarg) + c_ymarg
				GuiControl, Show, % IdEdit10 ;sandbox edit field
				GuiControl, MoveDraw, % IdEdit10, % "x" v_OutVarTemp1X "y" v_OutVarTemp1Y + v_OutVarTemp1H - (HofText + c_HofSandbox + c_ymarg) + c_ymarg + HofText "w" v_OutVarTemp1W
				GuiControl, MoveDraw, % IdText8, % "y" v_OutVarTemp1Y + v_OutVarTemp1H + c_ymarg ;Position of the long text F1 ... F2 ...
				IsSandboxMoved := false
			}
		}
		else ;increase size of List View and hide sandbox
		{
			if (c_ymarg + HofText + v_OutVarTemp1H > LeftColumnH)
			{
				GuiControl, Hide, % IdText10 ;sandobx text
				GuiControl, Hide, % IdEdit10 ;sandbox edit field
			}
			if (c_ymarg + HofText + v_OutVarTemp1H <= LeftColumnH + c_ymarg + HofText + c_HofSandbox)
			{
				GuiControl, Hide, % IdText10 ;sandobx text
				GuiControl, Hide, % IdEdit10 ;sandbox edit field
				GuiControl, MoveDraw, % IdListView1, % "h" . v_OutVarTemp1H + HofText + c_HofSandbox + c_ymarg
				GuiControl, MoveDraw, % IdText8, % "y" v_OutVarTemp1Y + v_OutVarTemp1H + HofText + c_HofSandbox + c_ymarg + c_ymarg ;Position of the long text F1 ... F2 ...
			}
		}
		b_SandboxResize := ini_Sandbox
		F_AutoXYWH("reset")
		OutputDebug, return by if (ini_Sandbox)
		return
	}	
	else ;no toggling of Sandbox, continue resizing
	{
		F_AutoXYWH("*wh", IdListView1)
		F_AutoXYWH("*h", IdButton5)
		GuiControlGet, v_OutVarTemp2, Pos, % IdListView1 ;Check position of ListView1 again after resizing
		if (v_OutVarTemp2W != v_OutVarTemp1W)
		{
			LV_ModifyCol(1, Round(0.1 * v_OutVarTemp2W))
			LV_ModifyCol(2, Round(0.1 * v_OutVarTemp2W))
			LV_ModifyCol(3, Round(0.1 * v_OutVarTemp2W))	
			LV_ModifyCol(4, Round(0.1 * v_OutVarTemp2W))
			LV_ModifyCol(5, Round(0.4 * v_OutVarTemp2W))
			LV_ModifyCol(6, Round(0.2 * v_OutVarTemp2W) - 3)
		}	
		
		if (ini_Sandbox) ;no hiding and showing, only relative shifting
		{
			if (c_ymarg + HofText + v_OutVarTemp2H > LeftColumnH) and (!IsSandboxMoved) ;left <- right, increase
			{
				
				GuiControl, MoveDraw, % IdListView1, % "h" v_OutVarTemp2H + c_ymarg + HofText + c_HofSandbox
				GuiControl, MoveDraw, % IdText10, % "x" c_xmarg "y" LeftColumnH + c_ymarg
				GuiControl, MoveDraw, % IdEdit10, % "x" c_xmarg "y" LeftColumnH + c_ymarg + HofText "w" LeftColumnW - c_xmarg
				GuiControl, MoveDraw, % IdText8,  % "y" v_OutVarTemp2Y + v_OutVarTemp2H + c_ymarg + HofText + c_HofSandbox + c_ymarg ;Position of the long text F1 ... F2 ...
				IsSandboxMoved := true
				OutputDebug, % "Left:" . A_Space . c_ymarg + HofText + v_OutVarTemp2H . A_Space . "Right:" . A_Space .  LeftColumnH . A_Space . "IsSandboxMoved:" . A_Space . IsSandboxMoved . A_Space . "return"
				F_AutoXYWH("reset")	
			;Pause, On
				return 
			}
			if (c_ymarg + HofText + v_OutVarTemp2H <= LeftColumnH + c_ymarg + HofText + c_HofSandbox) and (IsSandboxMoved) ; left -> right, reduce
			{
				GuiControl, MoveDraw, % IdListView1, % "h" v_OutVarTemp2H - (c_ymarg + HofText + c_HofSandbox)
				GuiControl, MoveDraw, % IdText10, % "x" LeftColumnW + c_xmarg + c_WofMiddleButton + c_xmarg "y" v_OutVarTemp2Y + v_OutVarTemp2H - (HofText + c_HofSandbox)
				GuiControl, MoveDraw, % IdEdit10, % "x" LeftColumnW + c_xmarg + c_WofMiddleButton + c_xmarg "y" v_OutVarTemp2Y + v_OutVarTemp2H - c_HofSandbox "w" v_OutVarTemp2W
				GuiControl, MoveDraw, % IdText8, % "y" v_OutVarTemp2Y + v_OutVarTemp2H - c_HofSandbox + c_ymarg ;Position of the long text F1 ... F2 ...
				IsSandboxMoved := false
				OutputDebug, % "Left:" . A_Space . c_ymarg + HofText + v_OutVarTemp2H . A_Space . "Right:" . A_Space . LeftColumnH + c_ymarg + HofText + c_HofSandbox . A_Space . "IsSandboxMoved:" . A_Space . IsSandboxMoved . A_Space . "reset"
				F_AutoXYWH("reset")
				return
			}
			
			if (c_ymarg + HofText + v_OutVarTemp2H > LeftColumnH) and (IsSandboxMoved) ;vertical 1
			{
				GuiControl, MoveDraw, % IdText8, % "y" v_OutVarTemp2Y + v_OutVarTemp2H + c_ymarg ;Position of the long text F1 ... F2 ...
			}
			
			if (c_ymarg + HofText + v_OutVarTemp2H <= LeftColumnH + c_ymarg + HofText + c_HofSandbox) and (!IsSandboxMoved) ;vertical 2
			{
				OutputDebug, % "Left:" . A_Space . c_ymarg + HofText + v_OutVarTemp2H . A_Space . "Right:" . A_Space . LeftColumnH + c_ymarg + HofText + c_HofSandbox . A_Space . "IsSandboxMoved:" . A_Space . IsSandboxMoved . A_Space . "top -> down"
				GuiControl, MoveDraw, % IdText10, % "y" v_OutVarTemp2Y + v_OutVarTemp2H + c_ymarg
				GuiControl, MoveDraw, % IdEdit10, % "y" v_OutVarTemp2Y + v_OutVarTemp2H + c_ymarg + HofText 
				GuiControl, MoveDraw, % IdText8,  % "y" v_OutVarTemp2Y + v_OutVarTemp2H + c_ymarg + HofText + c_HofSandbox + c_ymarg
			;Pause, On
			}
		}
		else ;no sandbox, no hiding and showing, only relative shifting
		{
			GuiControl, MoveDraw, % IdText8, % "y" v_OutVarTemp2Y + v_OutVarTemp2H + c_ymarg ;Position of the long text F1 ... F2 ...
		}
	}
	
	;GuiControl,, % IdText2, % v_LoadedHotstrings . A_Space . v_HotstringCnt ; •(Blank): Puts new contents into the control.
	OutputDebug, % "End:" . A_Space . CntGuiSize 
	return
	;*[Three]
}


/*
	
	HS3GuiSize:		; Launched when the window is resized, minimized, maximized, or restored.
	if (ErrorLevel == 1)
		return
	if (ErrorLevel == 0)
		v_ShowGui := 2
	IniW := ini_StartW
	IniH := ini_StartH
	
	AutoXYWH("wh", IdListView1)
	GuiControlGet, temp2, Pos, %IdListView1%	
	
	LV_ModifyCol(1, Round(0.2 * temp2W))
	LV_ModifyCol(2, Round(0.1 * temp2W))
	LV_ModifyCol(3, Round(0.2 * temp2W))	
	LV_ModifyCol(4, Round(0.1 * temp2W))
	LV_ModifyCol(5, Round(0.1 * temp2W))
	LV_ModifyCol(6, Round(0.3 * temp2W) - 3)
	
	WinGetPos, v_PreviousX, v_PreviousY , , ,Hotstrings
	v_PreviousWidth := A_GuiWidth
	v_PreviousHeight := A_GuiHeight
	
*/

/*
	LV_Width 	:= IniW - 460*DPI%v_SelectedMonitor%
	LV_Height := IniH - 62*DPI%v_SelectedMonitor%
	LV_ModifyCol(1,100*DPI%v_SelectedMonitor%)
	LV_ModifyCol(2,80*DPI%v_SelectedMonitor%)
	LV_ModifyCol(3,70*DPI%v_SelectedMonitor%)	
	LV_ModifyCol(4,60*DPI%v_SelectedMonitor%)
	LV_ModifyCol(6,300*DPI%v_SelectedMonitor%)
	LV_ModifyCol(1,"Center")
	LV_ModifyCol(2,"Center")
	LV_ModifyCol(3,"Center")
	LV_ModifyCol(4,"Center")
	
	WinGetPos, v_PreviousX, v_PreviousY , , ,Hotstrings
	v_PreviousWidth := A_GuiWidth
	v_PreviousHeight := A_GuiHeight
	
	NewHeight := LV_Height+(A_GuiHeight-IniH)
	NewWidth 	:= LV_Width+(A_GuiWidth-IniW)
	ColWid := (NewWidth-620*DPI%v_SelectedMonitor%)
	LV_ModifyCol(5, "Auto")
	SendMessage, 4125, 4, 0, SysListView321
	wid := ErrorLevel
	if (wid < ColWid)
	{
		LV_ModifyCol(5, ColWid)
	}
*/
/*
	GuiControl, Move, v_LibraryContent, W%NewWidth% H%NewHeight%
	GuiControl, Move, v_ShortcutsMainInterface, % "y" . v_PreviousHeight - 22*DPI%v_SelectedMonitor%
	GuiControl, Move, v_LoadedHotstrings, % "y" . v_PreviousHeight - 22*DPI%v_SelectedMonitor% . " x" . v_PreviousWidth - 200*DPI%v_SelectedMonitor%
	GuiControl, Move, Line, % "w" . A_GuiWidth . " y" . v_PreviousHeight - 26*DPI%v_SelectedMonitor%
*/
;return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

HS3GuiEscape:
Gui, 		%HS3Hwnd%: Minimize
Gui,			%HS3Hwnd%: Show, Hide
return

; Future: save window position
HS3GuiClose:
WinGetPos, v_PreviousX, v_PreviousY , , ,Hotstrings
Gui, HS3:Destroy
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; Here I use 2x GUIs: SearchLoad which shows progress on time of library loading process and HS3List which is in fact Search GUI name.
; Not clear why v_HS3ListFlag is used.
L_Searching:
if (v_HS3ListFlag) 
	Gui, HS3List:Show
else
{
	WinGetPos, ini_StartXlist, ini_StartYlist,,,Hotstrings
	Gui, SearchLoad:New, -Resize -Border
	Gui, SearchLoad:Add, Text,, % TransA["Please wait, uploading .csv files..."]
	Gui, SearchLoad:Add, Progress, w300 h20 HwndhPB2 -0x1, 50
	WinSet, Style, +0x8, % "ahk_id " hPB2
	SendMessage, 0x40A, 1, 20,, % "ahk_id " hPB2		; CBEM_HASEDITCHANGED := 0x40A
	Gui, SearchLoad:Show, hide, UploadingSearch
	WinGetPos, v_WindowX, v_WindowY ,v_WindowWidth,v_WindowHeight,Hotstrings
	DetectHiddenWindows, On
	WinGetPos, , , UploadingWindowWidth, UploadingWindowHeight,UploadingSearch
	DetectHiddenWindows, Off
	Gui, SearchLoad:Show, % "x" . v_WindowX + (v_WindowWidth - UploadingWindowWidth)/2 . " y" . v_WindowY + (v_WindowHeight - UploadingWindowHeight)/2, UploadingSearch
	
	SysGet, N, MonitorCount
	Loop, % N
	{
		SysGet, Mon%A_Index%, Monitor, %A_Index%
		W%A_Index% := Mon%A_Index%Right - Mon%A_Index%Left
		H%A_Index% := Mon%A_Index%Bottom - Mon%A_Index%Top
		DPI%A_Index% := round(W%A_Index%/1920*(96/A_ScreenDPI),2)	; Future: DPI := 1
	}
	SysGet, PrimMon, MonitorPrimary
	if (v_SelectedMonitor == 0)
		v_SelectedMonitor := PrimMon
	/*
		if (WinExist("Search Hotstring"))	; I have serious doubts if those lines are useful
		{
			Gui, HS3List:Hide
		}
	*/
	Gui, HS3List:New, % "+Resize MinSize" . 940*DPI%v_SelectedMonitor% . "x" . 500*DPI%v_SelectedMonitor%
	v_HS3ListFlag := 1
	Gui, HS3List:Add, Text, ,Search:
	Gui, HS3List:Add, Text, 		% "yp xm+" . 420*DPI%v_SelectedMonitor%, % TransA["Search by:"]
	Gui, HS3List:Add, Edit, 		% "xm w" . 400*DPI%v_SelectedMonitor% . " vv_SearchTerm gSearch"
	Gui, HS3List:Add, Radio, 	% "yp xm+" . 420*DPI%v_SelectedMonitor% . " vv_RadioGroup gSearchChange Checked", % TransA["Triggerstring"]
	Gui, HS3List:Add, Radio, 	% "yp xm+" . 540*DPI%v_SelectedMonitor% . " gSearchChange", % TransA["Hotstring"]
	Gui, HS3List:Add, Radio, 	% "yp xm+" . 640*DPI%v_SelectedMonitor% . " gSearchChange", % TransA["Library"]
	Gui, HS3List:Add, Button, 	% "yp-2 xm+" . 720*DPI%v_SelectedMonitor% . " w" . 100*DPI%v_SelectedMonitor% . " gMoveList Default", % TransA["Move"]
	Gui, HS3List:Add, ListView, 	% "xm grid vList +AltSubmit gHSLV2 h" . 400*DPI%v_SelectedMonitor%, % TransA["Library|Triggerstring|Trigger Options|Output Function|Enable/Disable|Hotstring|Comment"]
	Loop, % a_Library.MaxIndex() ; Those arrays have been loaded by F_LoadLibrariesToTables()
	{
		LV_Add("", a_Library[A_Index], a_Triggerstring[A_Index],a_TriggerOptions[A_Index],a_OutputFunction[A_Index],a_EnableDisable[A_Index],a_Hotstring[A_Index], a_Comment[A_Index])
	}
	LV_ModifyCol(1, "Sort")
	ini_StartWlist := 940*DPI%v_SelectedMonitor%
	ini_StartHlist := 500*DPI%v_SelectedMonitor%
	SetTitleMatchMode, 3
	WinGetPos, ini_StartXlist, ini_StartYlist,,,Hotstrings
	if ((ini_StartXlist == "") or (ini_StartYlist == ""))
	{
		ini_StartXlist := (Mon%v_SelectedMonitor%Left + (Abs(Mon%v_SelectedMonitor%Right - Mon%v_SelectedMonitor%Left)/2))*DPI%v_SelectedMonitor% - ini_StartWlist/2
		ini_StartYlist := (Mon%v_SelectedMonitor%Top + (Abs(Mon%v_SelectedMonitor%Bottom - Mon%v_SelectedMonitor%Top)/2))*DPI%v_SelectedMonitor% - ini_StartHlist/2
	}
		;Gui, HS3List:Add, Text, x0 h1 0x7 w10 vLine2
	Gui, HS3List:Font, % "s" . c_FontSize*DPI%v_SelectedMonitor% . " cBlack Norm"
	Gui, HS3List:Add, Text, xm vShortcuts2, % TransA["F3 Close Search hotstrings | F8 Move hotstring"]
	if !(v_SearchTerm == "")
		GuiControl,, v_SearchTerm, %v_SearchTerm%
	if (v_RadioGroup == 1)
		GuiControl,, Triggerstring, 1
	else if (v_RadioGroup == 2)
		GuiControl,, Hotstring, 1
	else if (v_RadioGroup == 3)
		GuiControl,, Library, 1
	Gui, HS3List:Show, % "w" . ini_StartWlist . " h" . ini_StartHlist . " x" . ini_StartXlist . " y" . ini_StartYlist, Search Hotstrings ;Future: translate
	Gui, SearchLoad:Destroy
}

Search:
Gui, HS3List:Default
Gui, HS3List:Submit, NoHide
if getkeystate("CapsLock","T")
	return
GuiControlGet, v_SearchTerm
GuiControl, -Redraw, List
LV_Delete()
if (v_RadioGroup == 2)
{
	For Each, FileName In a_Hotstring
	{
		If (v_SearchTerm != "")
		{
		; If (InStr(FileName, v_SearchTerm) = 1) ; for matching at the start
			If InStr(FileName, v_SearchTerm) ; for overall matching
				LV_Add("",a_Library[A_Index], a_Triggerstring[A_Index],a_TriggerOptions[A_Index],a_OutputFunction[A_Index],a_EnableDisable[A_Index],FileName,a_Comment[A_Index])
		}
		Else
			LV_Add("",a_Library[A_Index], a_Triggerstring[A_Index],a_TriggerOptions[A_Index],a_OutputFunction[A_Index],a_EnableDisable[A_Index],FileName,a_Comment[A_Index])
	}
	LV_ModifyCol(6,"Sort")
}
else if (v_RadioGroup == 1)
{
	For Each, FileName In a_Triggerstring
	{
		If (v_SearchTerm != "")
		{
			If (InStr(FileName, v_SearchTerm) = 1) ; for matching at the start
		; If InStr(FileName, v_SearchTerm) ; for overall matching
				LV_Add("",a_Library[A_Index], FileName,a_TriggerOptions[A_Index],a_OutputFunction[A_Index],a_EnableDisable[A_Index],a_Hotstring[A_Index],a_Comment[A_Index])
		}
		Else
			LV_Add("",a_Library[A_Index], FileName,a_TriggerOptions[A_Index],a_OutputFunction[A_Index],a_EnableDisable[A_Index],a_Hotstring[A_Index],a_Comment[A_Index])
	}
	LV_ModifyCol(2,"Sort") 
}
else if (v_RadioGroup == 3)
{
	For Each, FileName In a_Library
	{
		If (v_SearchTerm != "")
		{
			If (InStr(FileName, v_SearchTerm) = 1) ; for matching at the start
		; If InStr(FileName, v_SearchTerm) ; for overall matching
				LV_Add("",FileName, a_Triggerstring[A_Index],a_TriggerOptions[A_Index],a_OutputFunction[A_Index],a_EnableDisable[A_Index],a_Hotstring[A_Index],a_Comment[A_Index])
		}
		Else
			LV_Add("",FileName, a_Triggerstring[A_Index],a_TriggerOptions[A_Index],a_OutputFunction[A_Index],a_EnableDisable[A_Index],a_Hotstring[A_Index],a_Comment[A_Index])
	}
	LV_ModifyCol(1,"Sort")
}
GuiControl, +Redraw, List 
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

MoveList:
Gui, HS3List:Submit, NoHide 
If !(v_SelectedRow := LV_GetNext()) {
	MsgBox, 0, %A_ThisLabel%, % TransA["Select a row in the list-view, please!"]
	Return
}
LV_GetText(FileName,		v_SelectedRow, 1)
LV_GetText(Triggerstring, 	v_SelectedRow, 2)
LV_GetText(TriggOpt, 		v_SelectedRow, 3)
LV_GetText(OutFun, 			v_SelectedRow, 4)
LV_GetText(EnDis, 			v_SelectedRow, 5)
If (EnDis == "En")
	OnOff := "On"
else if (EnDis == "Dis")
	OnOff := "Off"
LV_GetText(HSText, 			v_SelectedRow, 6)
LV_GetText(v_Comment, 		v_SelectedRow, 7)
MovedHS 		:= TriggOpt . "‖" . Triggerstring . "‖" . OutFun . "‖" . EnDis . "‖" . HSText . "‖" . v_Comment
MovedNoOptHS 	:= "‖" . Triggerstring . "‖" . OutFun . "‖" . EnDis . "‖" . HSText . "‖" . v_Comment
Gui, MoveLibs:New
cntMove := -1
Loop, %A_ScriptDir%\Libraries\*.csv
{
	cntMove += 1
}
Gui, MoveLibs:Add, Text,, % TransA["Select the target library:"]
Gui, MoveLibs:Add, ListView, LV0x1 -Hdr r%cntMove%, Library
Loop, %A_ScriptDir%\Libraries\*.csv
{
	if (SubStr(A_LoopFileName,1,StrLen(A_LoopFileName)-4) != FileName )
	{
		LV_Add("", A_LoopFileName)
	}
}
Gui, MoveLibs:Add, Button, % "Default gMove w" . 100*DPI%v_SelectedMonitor%, % TransA["Move"]
Gui, MoveLibs:Add, Button, % "yp x+m gCancelMove w" . 100*DPI%v_SelectedMonitor%, % TransA["Cancel"]
Gui, MoveLibs:Show, hide, Select library
WinGetPos, v_WindowX, v_WindowY, v_WindowWidth, v_WindowHeight, Hotstrings
DetectHiddenWindows, On
WinGetPos, , , SelectLibraryWindowWidth, SelectLibraryWindowHeight, Select library
DetectHiddenWindows, Off
Gui, MoveLibs:Show, % "x" . v_WindowX + (v_WindowWidth - SelectLibraryWindowWidth)/2 . " y" . v_WindowY + (v_WindowHeight - SelectLibraryWindowHeight)/2, Select library
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

CancelMove:
Gui, MoveLibs:Destroy
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; This function have to be further investigated.
Move:
Gui, MoveLibs:Submit, NoHide
If !(v_SelectedRow := LV_GetNext()) 
{
	MsgBox, 0, %A_ThisLabel%, % TransA["Select a row in the list-view, please!"] ; Future: center on current screen.
	return
}
LV_GetText(TargetLib, v_SelectedRow)
FileRead, Text, Libraries\%TargetLib%
SectionList := StrSplit(Text, "`r`n")
InputFile = % A_ScriptDir . "\Libraries\" . TargetLib
LString := % "‖" . Triggerstring . "‖"
SaveFlag := 0	; !!!
Gui, HS3:Default
GuiControl, Choose, v_SelectHotstringLibrary, %TargetLib%
F_SectionChoose()
	;Gosub, SectionChoose
Loop, Read, %InputFile%
{
	if InStr(A_LoopReadLine, LString)
	{
		MsgBox, 4,, % TransA["The hostring"] . " """ . Triggerstring """ " . TransA["exists in a file"] . " " . TargetLib . TransA[". Do you want to proceed?"]
		IfMsgBox, No
		{
			Gui, MoveLibs:Destroy
			return
		}
		LV_Modify(A_Index, "", Triggerstring, TriggOpt, OutFun, EnDis, HSText, v_Comment)
		SaveFlag := 1
	}
}
if (SaveFlag == 0)
{
	LV_Add("",  Triggerstring, TriggOpt, OutFun, EnDis,  HSText, v_Comment)
	SectionList.Push(MovedHS)
}
LV_ModifyCol(1, "Sort")
FileDelete, Libraries\%TargetLib%
if (SectionList.MaxIndex() == "")
{
	LV_GetText(txt1, 1, 2)
	LV_GetText(txt2, 1, 1)
	LV_GetText(txt3, 1, 3)
	LV_GetText(txt4, 1, 4)
	LV_GetText(txt5, 1, 5)
	LV_GetText(txt6, 1, 6)
	txt := % txt1 . "‖" . txt2 . "‖" . txt3 . "‖" . txt4 . "‖" . txt5 . "‖" . txt6
	FileAppend, %txt%, Libraries\%TargetLib%, UTF-8
}
else
{
	Loop, % SectionList.MaxIndex()-1
	{
		LV_GetText(txt1, A_Index, 2)
		LV_GetText(txt2, A_Index, 1)
		LV_GetText(txt3, A_Index, 3)
		LV_GetText(txt4, A_Index, 4)
		LV_GetText(txt5, A_Index, 5)
		LV_GetText(txt6, A_Index, 6)
		txt := % txt1 . "‖" . txt2 . "‖" . txt3 . "‖" . txt4 . "‖" . txt5 . "‖" . txt6 . "`r`n"
		if !((txt1 == "") and (txt2 == "") and (txt3 == "") and (txt4 == "") and (txt5 == "") and (txt6 == ""))
			FileAppend, %txt%, Libraries\%TargetLib%, UTF-8
	}
	LV_GetText(txt1, SectionList.MaxIndex(),2) 
	LV_GetText(txt2, SectionList.MaxIndex(),1) 
	LV_GetText(txt3, SectionList.MaxIndex(),3) 
	LV_GetText(txt4, SectionList.MaxIndex(),4) 
	LV_GetText(txt5, SectionList.MaxIndex(),5)
	LV_GetText(txt6, SectionList.MaxIndex(),6) 
	txt := % txt1 . "‖" . txt2 . "‖" . txt3 . "‖" . txt4 . "‖" . txt5 . "‖" . txt6
	FileAppend, %txt%, Libraries\%TargetLib%, UTF-8
}
InputFile 	:= % A_ScriptDir . "\Libraries\" . FileName . ".csv"
OutputFile 	:= % A_ScriptDir . "\Libraries\temp.csv"
cntLines 		:= 0
Loop, Read, %InputFile%
{	
	if !(InStr(A_LoopReadLine, LString))
		FileAppend, % A_LoopReadLine . "`r`n", %OutputFile%, UTF-8
	cntLines++
}
FileDelete, %InputFile%
Loop, Read, %OutputFile%
{
	if (A_Index == 1)
		FileAppend, % A_LoopReadLine, %InputFile%, UTF-8
	else
		FileAppend, % "`r`n" . A_LoopReadLine, %InputFile%, UTF-8
	
}
if (cntLines == 1)
{
	FileAppend,, %InputFile%, UTF-8
}
FileDelete, %OutputFile%
MsgBox, % TransA["Hotstring moved to the"] . " " . TargetLib . " " . TransA["file!"]
Gui, MoveLibs:Destroy
Gui, HS3List:Hide	

;Clearing of arrays before fill up by function F_LoadLibrariesToTables().
a_Triggers := [] 
a_Library			:= []
a_TriggerOptions	:= []
a_Hotstring		:= []
a_OutputFunction	:= []
a_EnableDisable	:= []
a_Triggerstring	:= []
a_Comment			:= []
F_LoadLibrariesToTables()	; Hotstrings are already loaded by function F_LoadHotstringsFromLibraries(), but auxiliary tables have to be loaded again. Those (auxiliary) tables are used among others to fill in LV_ variables.
Gosub, L_Searching 
;return ; This line will be never reached

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

SearchChange:
gosub, Search
GuiControl,, v_SearchTerm, %v_SearchTerm%
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

HS3ListGuiSize:
if (ErrorLevel == 1)
	return
IniW := ini_StartWlist
IniH := ini_StartHlist
LV_Width := IniW - 30*DPI%v_SelectedMonitor%
LV_Height := IniH - 100*DPI%v_SelectedMonitor%
LV_ModifyCol(1,100*DPI%v_SelectedMonitor%)
LV_ModifyCol(2,100*DPI%v_SelectedMonitor%)
LV_ModifyCol(3,110*DPI%v_SelectedMonitor%)
LV_ModifyCol(4,110*DPI%v_SelectedMonitor%)
LV_ModifyCol(5,110*DPI%v_SelectedMonitor%)
LV_ModifyCol(7,185*DPI%v_SelectedMonitor%)
LV_ModifyCol(1,"Center")
LV_ModifyCol(2,"Center")
LV_ModifyCol(3,"Center")
LV_ModifyCol(4,"Center")
LV_ModifyCol(5,"Center")
WinGetPos,,, ListW, ListH, Search Hotstrings
NewHeight := LV_Height+(A_GuiHeight-IniH)
NewWidth := LV_Width+(A_GuiWidth-IniW)
ColWid := (NewWidth-740*DPI%v_SelectedMonitor%)
SendMessage, 4125, 4, 0, SysListView321
wid := ErrorLevel
if (wid < ColWid)
{
	LV_ModifyCol(6, ColWid)
}
GuiControl, Move, List, W%NewWidth% H%NewHeight%
GuiControl, Move, Shortcuts2, % "y" . A_GuiHeight - 20*DPI%v_SelectedMonitor%
GuiControl, Move, Line2, % "w" . A_GuiWidth . " y" . A_GuiHeight - 25*DPI%v_SelectedMonitor%
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
~^f::
~^s::
~F3::
HS3ListGuiEscape:
HS3ListGuiClose:
Gui, HS3List:Hide
	; v_SearchTerm := ""
	; a_Hotstring := []
	; a_Library := []
	; a_Triggerstring := []
	; a_EnableDisable := []
	; v_RadioGroup := ""
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

; F11::
;	IniRead, Undo, Config.ini, Configuration, UndoHotstring
;	Undo := !(Undo)
;	IniWrite, %Undo%, Config.ini, Configuration, UndoHotstring
; return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Tips:
Menu, SubmenuTips, ToggleCheck, % TransA["Enable/Disable"]
Menu, SubmenuTips, ToggleEnable, % TransA["Choose tips location"]
Menu, SubmenuTips, ToggleEnable, % TransA["Number of characters for tips"]
ini_Tips := !(ini_Tips)
IniWrite, %ini_Tips%, Config.ini, Configuration, Tips
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

L_Sandbox:
Menu, Submenu1, ToggleCheck, % TransA["Launch Sandbox"]
	;Critical, On
ini_Sandbox := !(ini_Sandbox)
b_SandboxResize := !ini_Sandbox
Iniwrite, %ini_Sandbox%, Config.ini, Configuration, v_Sandbox
	;Goto, HS3GuiSize
HS3GuiSize()
	;Critical, Off
;return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

SavePos:
WinGetPos, HSX, HSY,,, Hotstrings
IniWrite, %HSX%, Config.ini, Configuration, SizeOfHotstringsWindow_X
IniWrite, %HSY%, Config.ini, Configuration, SizeOfHotstringsWindow_Y
IniWrite, %v_PreviousWidth%, Config.ini, Configuration, SizeOfHotstringsWindow_Width
IniWrite, %v_PreviousHeight%, Config.ini, Configuration, SizeOfHotstringsWindow_Height
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

L_DPIScaling:
	; SetTimer, L_DPIScaling, Off
if WinExist("Hotstrings") and WinExist("ahk_class AutoHotkeyGUI")
{
	
	WinGetPos, awinX, awinY,awinW,awinH,Hotstrings
	SysGet, N, MonitorCount
	Loop, % N
	{
		SysGet, Mon%A_Index%, Monitor, %A_Index%
		W%A_Index% := Mon%A_Index%Right - Mon%A_Index%Left
		H%A_Index% := Mon%A_Index%Bottom - Mon%A_Index%Top
		DPI%A_Index% := round(W%A_Index%/1920*(96/A_ScreenDPI),2)
		if (awinX >= Mon%A_Index%Left) and (awinX <= Mon%A_Index%Right)
		{
			v_SelectedMonitor := A_Index
		} 
	}
}
return

L_CaretCursor:
Menu, Submenu3, ToggleCheck, % TransA["Caret"]
Menu, Submenu3, ToggleCheck, % TransA["Cursor"]
ini_Caret := !(ini_Caret)
ini_Cursor := !(ini_Cursor)
IniWrite, %ini_Caret%, Config.ini, Configuration, Caret
IniWrite, %ini_Cursor%, Config.ini, Configuration, Cursor
return

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

L_ImportLibrary:
FileSelectFile, v_LibraryName, 3, %A_ScriptDir%, % TransA["Choose library file (.ahk) for import"], AHK Files (*.ahk)]
if !(v_LibraryName == "")
	F_ImportLibrary(v_LibraryName)
return

L_ExportLibraryStatic:
FileSelectFile, v_LibraryName, 3, % A_ScriptDir . "\Libraries",% TransA["Choose library file (.csv) for export"], CSV Files (*.csv)]
if !(v_LibraryName == "")
	F_ExportLibraryStatic(v_LibraryName)
return

L_ExportLibraryDynamic:
FileSelectFile, v_LibraryName, 3, % A_ScriptDir . "\Libraries", % TransA["Choose library file (.csv) for export"], CSV Files (*.csv)]
if !(v_LibraryName == "")
	F_ExportLibraryDynamic(v_LibraryName)
return

L_ToggleTipsLibrary:
Menu, ToggleLibrariesSubmenu, ToggleCheck, %A_ThisMenuitem%
IniRead, v_LibraryFlag, Config.ini, TipsLibraries, %A_ThisMenuitem%
v_LibraryFlag := !(v_LibraryFlag)
IniWrite, %v_LibraryFlag%, Config.ini, TipsLibraries, %A_ThisMenuitem%
a_Triggers := []
Gui, A_Gui:+Disabled
F_LoadHotstringsFromLibraries()
Gui, A_Gui:-Disabled
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
v_Language := A_ThisMenuitem
IniWrite, %v_Language%, Config.ini, Configuration, Language
Loop, %A_ScriptDir%\Languages\*.ini
{
	Menu, SubmenuLanguage, Add, %A_LoopFileName%, L_ChangeLangage
	if (v_Language == A_LoopFileName)
		Menu, SubmenuLanguage, Check, %A_LoopFileName%
	else
		Menu, SubmenuLanguage, UnCheck, %A_LoopFileName%
}
MsgBox, % TransA["Application language changed to:"] . " " . SubStr(v_Language, 1, StrLen(v_Language)-4) . "`n" . TransA["The application will be reloaded with the new language file."]
Reload
; return			; this line will not be reached
#If