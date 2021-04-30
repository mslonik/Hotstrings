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
global v_Param 				:= A_Args[1] ; the only one parameter of Hotstrings app available to user
global v_SelectedRow 			:= A_Args[7]
global v_PreviousMonitor 		:= A_Args[8]
global a_Comment 				:= []
global a_EnableDisable 			:= []
global a_Hotstring				:= []
global a_Library 				:= []
global v_TotalHotstringCnt 		:= 0
global v_LibHotstringCnt			:= 0 ;no of (triggerstring, hotstring) definitions in single library
global a_LibraryCnt				:= [] ;Hotstring counter for specific libraries
global a_OutputFunction 			:= []
global a_SelectedTriggers 		:= []
global a_TriggerOptions 			:= []
global a_Triggers 				:= []
global a_Triggerstring 			:= []
global ini_AmountOfCharacterTips 	:= ""
global ini_Caret 				:= ""
global ini_Cursor 				:= ""
global ini_Delay 				:= ""
global ini_MenuCaret 			:= ""
global ini_MenuCursor 			:= ""
global ini_MenuSound 			:= 1
global ini_Sandbox				:= 1	; as in new-created Config.ini
global ini_Tips 				:= ""
global ini_TipsSortAlphabetically 	:= ""
global ini_TipsSortByLength 		:= ""
;global v_CaseSensitiveC1 		:= ""
;global v_BlockHotkeysFlag		:= 0
global v_FlagSound 				:= 0
;I couldn't find how to get system settings for size of menu font. Quick & dirty solution: manual setting of all fonts with variable c_FontSize.

global v_HotstringFlag 			:= 0
global v_HS3SearchFlag 			:= 0
global v_IndexLog 				:= 1
global v_InputString 			:= ""
global v_Language 				:= ""	; OutputVar for IniRead funtion
global v_MenuMax 				:= 0
global v_MenuMax2 				:= 0
global v_MonitorFlag 			:= 0
global v_MouseX 				:= ""
global v_MouseY 				:= ""
global v_RadioGroup 			:= ""
global v_SearchTerm 			:= ""
global v_SelectedRow2 			:= 0
global v_SelectedMonitor			:= 0
global v_Tips 					:= ""
global v_TipsFlag 				:= 0
global v_TriggerString 			:= ""
global v_TypedTriggerstring 		:= ""
global v_UndoHotstring 			:= ""
global v_UndoTriggerstring 		:= ""
global v_String				:= ""
global v_ConfigFlag 			:= 0

;Flags to control application
global v_ResizingFlag 			:= true ; when Hotstrings Gui is displayed for the very first time
global v_WhichGUIisMinimzed		:= ""
global HS3_GuiWidth  := 0,	HS3_GuiHeight := 0

; - - - - - - - - - - - - - - - - - - - - - - - B E G I N N I N G    O F    I N I T I A L I Z A T I O N - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
Critical, On
F_LoadCreateTranslationTxt() ;default set of translations (English) is loaded at the very beginning in case if Config.ini doesn't exist yet, but some MsgBox have to be shown.
F_CheckCreateConfigIni() ;1. Try to load up configuration file. If those files do not exist, create them.

if ( !Instr(FileExist(A_ScriptDir . "\Languages"), "D"))				; if  there is no "Languages" subfolder 
{
	FileCreateDir, %A_ScriptDir%\Languages							; Future: check against errors
	MsgBox, 48, % SubStr(A_ScriptName, 1, -4) . A_Space . TransA["warning"], % TransA["There was no Languages subfolder, so one now is created."] . A_Space . "`n" 
	. A_ScriptDir . "\Languages"
}

IniRead v_Language, Config.ini, Configuration, Language				; Load from Config.ini file specific parameter: language into variable v_Language, e.g. v_Language = English.ini
if (!FileExist(A_ScriptDir . "\Languages\" . v_Language))			; else if there is no v_language .ini file, e.g. v_langugae == Polish.ini and there is no such file in Languages folder
{
	MsgBox, 48, % SubStr(A_ScriptName, 1, -4) . A_Space . TransA["warning"], % TransA["There is no"] . A_Space . v_Language . A_Space . TransA["file in Languages subfolder!"]
	. "`n" . TransA["The default"] . A_Space . v_Language . A_Space . TransA["file is now created in the following subfolder:"] . "`n"  A_ScriptDir . "\Languages\"
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


; Future: to be removed
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

; After definitions of (triggerstring, hotstring) are uploaded to memory, prepare (System)Tray icon. If Hotstrings.ahk wasn't run with "l" parameter (standing for "light / lightweight", prepare tray menu.
if !(v_Param == "l") 		;GUI window uses the tray icon that was in effect at the time the window was created, therefore this section have to be run before the first Gui, New command. 
{
	Menu, Tray, Add, 		% TransA["Edit Hotstring"], 		L_GUIInit
	Menu, Tray, Add, 		% TransA["Search Hotstrings"], 	L_Searching
	Menu, Tray, Default, 	% TransA["Edit Hotstring"]
	Menu, Tray, Add										; separator line
	Menu, Tray, NoStandard									; remove all the rest of standard tray menu
	Menu, Tray, Standard									; add it again at the bottom
	
	Menu, Tray, Icon,		% AppIcon 						;GUI window uses the tray icon that was in effect at the time the window was created. FlatIcon: https://www.flaticon.com/ Cloud Convert: https://www.cloudconvert.com/
}

F_GuiMain_CreateObject()
F_GuiMain_DefineConstants()
F_GuiMain_DetermineConstraints()
F_GuiMain_Redraw()

F_GuiHS4_CreateObject()
F_GuiHS4_DetermineConstraints()
F_GuiHS4_Redraw()

F_UpdateSelHotLibDDL()

;v_BlockHotkeysFlag := 1 ; Block hotkeys of this application for the time when (triggerstring, hotstring) definitions are uploaded from liberaries.
; 4. Load definitions of (triggerstring, hotstring) from Library subfolder.

F_LoadHotstringsFromLibraries()
;MsgBox,, A_IsCritical, % A_IsCritical
Critical, Off
;v_BlockHotkeysFlag := 0


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

Menu, Submenu1, Add, % TransA["Toggle EndChars"], :Submenu2

if (ini_Tips == 0)
	Menu, SubmenuTips, UnCheck, % TransA["Enable/Disable"]
else
	Menu, SubmenuTips, Check, % TransA["Enable/Disable"]

if (ini_Undo == 0)
	Menu, Submenu1, UnCheck, % TransA["Undo the last hotstring"]
else
	Menu, Submenu1, Check, % TransA["Undo the last hotstring"]

Loop, %A_ScriptDir%\Languages\*.txt 
{
	Menu, SubmenuLanguage, Add, %A_LoopFileName%, L_ChangeLanguage
	if (v_Language == A_LoopFileName)
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
Menu, ConfGUI, Add	;To add a menu separator line, omit all three parameters.
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

Menu, ConfGUI, Add	;To add a menu separator line, omit all three parameters.
Menu, ConfGUI,		Add, Style of GUI,								:StyleGUIsubm

for key, value in SizeOfMargin
	Menu, SizeOfMX, Add, % SizeOfMargin[key], F_SizeOfMargin
for key, value in SizeOfMargin
	Menu, SizeOfMY, Add, % SizeOfMargin[key], F_SizeOfMargin
Menu, SizeOfMX,	Check,	% c_xmarg
Menu, SizeOfMY,	Check,	% c_ymarg

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

Menu, Submenu1,		Add, % TransA["Graphical User Interface"], 		:ConfGUI

Menu, HSMenu, 			Add, % TransA["Configuration"], 				:Submenu1
Menu, HSMenu, 			Add, % TransA["Search Hotstrings (F3)"], 			L_Searching
;Menu, HSMenu,		Disable,	% TransA["Search Hotstrings"]

Menu, LibrariesSubmenu,	Add, % TransA["Enable/disable libraries"], 		F_RefreshListOfLibraries
F_RefreshListOfLibraries()
Menu, LibrariesSubmenu, 	Add, % TransA["Enable/disable triggerstring tips"], 	F_RefreshListOfLibraryTips
F_RefreshListOfLibraryTips()

Menu, LibrariesSubmenu, 	Add, % TransA["Import from .ahk to .csv"],		L_ImportLibrary
Menu, LibrariesSubmenu, Disable, % TransA["Import from .ahk to .csv"]
Menu, ExportSubmenu, 	Add, % TransA["Static hotstrings"],  			L_ExportLibraryStatic
Menu, ExportSubmenu, 	Add, % TransA["Dynamic hotstrings"],  			L_ExportLibraryDynamic
Menu, LibrariesSubmenu, 	Add, % TransA["Export from .csv to .ahk"],		:ExportSubmenu
Menu, LibrariesSubmenu, Disable, % TransA["Export from .csv to .ahk"]

Menu, 	HSMenu, 			Add, % TransA["Libraries"], 				:LibrariesSubmenu
Menu, 	HSMenu, 			Add, % TransA["Clipboard Delay (F7)"], 		F_GuiHSdelay
Menu,	ApplicationSubmenu,	Add, % TransA["Reload"],					F_Reload
Menu,	ApplicationSubmenu,	Add, % TransA["Exit"],					F_Exit
Menu,	ApplicationSubmenu, Add, % TransA["Remove Config.ini"],		F_RemoveConfigIni

F_CompileSubmenu()
Menu,	ApplicationSubmenu,	Add,	% TransA["Compile"],				:CompileSubmenu
if (!A_AhkPath) ;if AutoHotkey isn't installed
	Menu,	ApplicationSubmenu, Disable,							% TransA["Compile"]
Menu, 	HSMenu,			Add, % TransA["Application"],				:ApplicationSubmenu
Menu, 	HSMenu, 			Add, % TransA["About/Help"], 				F_GuiAbout
Gui, 	HS3: Menu, HSMenu
Gui, 	HS4: Menu, HSMenu

F_GuiAbout_CreateObjects()
F_GuiAbout_DetermineConstraints()


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

F1::	;new thread starts here
F_WhichGui()
F_GuiAbout()
return

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
Gui, HS3:Default
F_GuiHSdelay()
return

F8::	;new thread starts here
Gui, HS3:Default
;goto, Delete
F_DeleteHotstring()
return

F9::	;new thread starts here
F_WhichGui()
F_SetHotstring()
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
Gui, HS3Search:Default
goto, MoveList
#if



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
Sleep, %ini_Delay% ;Remember to sleep before restoring clipboard or it will fail
v_TypedTriggerstring := MenuListbox
v_UndoHotstring 	 := MenuListbox
Clipboard 		 := ClipboardBack
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


; ------------------------- SECTION OF FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------------------

HS3SearchGuiSize()
{
	local v_OutVarTemp1 := 0, v_OutVarTemp1X := 0, v_OutVarTemp1Y := 0, v_OutVarTemp1W := 0, v_OutVarTemp1H := 0
		,v_OutVarTemp2 := 0, v_OutVarTemp2X := 0, v_OutVarTemp2Y := 0, v_OutVarTemp2W := 0, v_OutVarTemp2H := 0
	
	if (A_EventInfo = 1) ;The window has been minimized.
		return
	if (A_EventInfo = 2)
		return
	;*[One]
	GuiControlGet, v_OutVarTemp1, Pos, % IdLV_Search 
	F_AutoXYWH("*wh", IdLV_Search)
	GuiControlGet, v_OutVarTemp2, Pos, % IdLV_Search ;Check position of ListView1 again after resizing
	if (v_OutVarTemp2W != v_OutVarTemp1W)
	{
		LV_ModifyCol(1, Round(0.1 * v_OutVarTemp2W))
		LV_ModifyCol(2, Round(0.1 * v_OutVarTemp2W))
		LV_ModifyCol(3, Round(0.1 * v_OutVarTemp2W))	
		LV_ModifyCol(4, Round(0.1 * v_OutVarTemp2W))
		LV_ModifyCol(5, Round(0.3 * v_OutVarTemp2W))
		LV_ModifyCol(6, Round(0.2 * v_OutVarTemp2W))
		LV_ModifyCol(7, Round(0.1 * v_OutVarTemp2W) - 3)
	}	
	;LV_ModifyCol(1, "100 Center")
	;LV_ModifyCol(2, "100 Center")
	;LV_ModifyCol(3, "110 Center")
	;LV_ModifyCol(4, "110 Center")
	;LV_ModifyCol(5, "110 Center")
	;LV_ModifyCol(7, "185 Center")
	/*
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
	*/
	return
}
	
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_RemoveConfigIni()
{
	global	;assume-global mode
	if (FileExist("Config.ini"))
	{
		MsgBox, 308, % SubStr(A_ScriptName, 1, -4) . A_Space . TransA["warning"], % TransA["Config.ini will be deleted. Next application will be reloaded. This action cannot be undone. Are you sure?"] 
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
	;+Owner to prevent display of a taskbar button
	Gui, HSDel: New, -MinimizeBox -MaximizeBox +Owner +HwndHotstringDelay, % TransA["Set Clipboard Delay"]
	Gui, HSDel: Margin,	% c_xmarg, % c_ymarg
	Gui,	HSDel: Color,	% c_WindowColor, % c_ControlColor
	Gui,	HSDel: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, % c_FontType
	
	Gui, HSDel: Add, Slider, w300 vMySlider gmySlider Range100-1000 ToolTipBottom Buddy1999, % ini_Delay
	
	TransA["This option is valid"] := StrReplace(TransA["This option is valid"], "``n", "`n")
	
	Gui, HSDel: Add, Text, vDelayText, % TransA["Clipboard paste delay in [ms]:"] . A_Space . ini_Delay . "`n`n" . TransA["This option is valid"]
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
{
	global	;assume-global mode
	local	WinHWND := 0
	
	WinGet, WinHWND, ID, A
	Switch WinHWND
	{
		Case HS3GuiHwnd:
		Gui, HS3: Default
		Case HS4GuiHwnd:
		Gui, HS4: Default
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

	;if menu ToggleLibTrigTipsSubmenu doesn't exist, delete it
	Menu, ToggleLibTrigTipsSubmenu, UseErrorLevel, On
	if (!ErrorLevel)
		Menu, ToggleLibTrigTipsSubmenu, Delete
	Menu, ToggleLibTrigTipsSubmenu, UseErrorLevel, Off
	
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

	;if menu EnDisLib doesn't exist, delete it
	Menu, EnDisLib, UseErrorLevel, On
	if (!ErrorLevel)
		Menu, EnDisLib, Delete
	Menu, EnDisLib, UseErrorLevel, Off
	
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
			,v_SelectedRow := 0
	
	Gui, HS3: +OwnDialogs
	
	if !(v_SelectedRow := LV_GetNext()) 
	{
		MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"],  % TransA["Select a row in the list-view, please!"]
		return
	}
	MsgBox, 324, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["Selected Hotstring will be deleted. Do you want to proceed?"]
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
	
	
	;4. Disable selected hotstring.
	LV_GetText(txt2, v_SelectedRow, 2)
	Try
		Hotstring(":" . txt2 . ":" . v_TriggerString, , "Off") 
	Catch
		MsgBox, 16, % SubStr(A_ScriptName, 1, -4) . A_Space . TransA["Error"], % A_ThisFunc . A_Space . TransA["Error, something went wrong with hotstring deletion:"] . "`n`n" . v_TriggerString 
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
		txt := % txt1 . "‖" . txt2 . "‖" . txt3 . "‖" . txt4 . "‖" . txt5 . "‖" . txt6 . "`r`n"
		if !((txt1 == "") and (txt2 == "") and (txt3 == "") and (txt4 == "") and (txt5 == "") and (txt6 == "")) ;only not empty definitions are added, not sure why
			FileAppend, %txt%, Libraries\%v_SelectHotstringLibrary%, UTF-8
	}

	;5. Remove trigger hint. Remark: All trigger hints are deleted, so if triggerstring was duplicated, then all trigger hints are deleted!
	Loop, % a_Triggers.MaxIndex()
	{
		if (InStr(a_Triggers[A_Index], v_TriggerString))
			a_Triggers.RemoveAt(A_Index)
	}
	TrayTip, % A_ScriptName, % TransA["Specified definition of hotstring has been deleted"], 1
	;Gui, ProgressDelete:Destroy
	
	;6. Decrement library counter.
	--v_LibHotstringCnt
	--v_TotalHotstringCnt
	GuiControl, Text, % IdText13,  % A_Space . v_LibHotstringCnt
	GuiControl, Text, % IdText13b, % A_Space . v_LibHotstringCnt
	GuiControl, Text, % IdText12,  % A_Space . v_TotalHotstringCnt
	GuiControl, Text, % IdText12b, % A_Space . v_TotalHotstringCnt
	
	return
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

;In AutoHotkey there is no Guicontrol, Delete sub-command. As a consequence even if specific control is hidden (Guicontrol, Hide), the Gui size isn't changed, size is not decreased, as space for hidden control is maintained. To solve this issue, the separate gui have to be prepared. This requires a lot of work and is a matter of far future.
F_ToggleRightColumn() ;Label of Button IdButton5, to toggle left part of gui 
{
	global ;assume-global mode
	local WinX := 0, WinY := 0
	local OutputvarTemp := 0, OutputvarTempW := 0
	
	Switch A_DefaultGui
	{
		Case "HS3":
			WinGetPos, WinX, WinY, , , % "ahk_id" . HS3GuiHwnd
			Gui, HS3: Submit, NoHide
			Gui, HS4: Default
			F_UpdateSelHotLibDDL()
			;F_GuiHS4_Redraw()
			GuiControl,, % IdEdit1b, % v_TriggerString
			GuiControl,, % IdEdit2b, % v_EnterHotstring
			GuiControl, ChooseString, % IdDDL2b, % v_SelectHotstringLibrary
			Gui, HS3: Show, Hide
			Gui, HS4: Show, % "X" WinX . A_Space . "Y" WinY . A_Space . "AutoSize"
			ini_WhichGui := "HS4"
			;return
		Case "HS4":
			WinGetPos, WinX, WinY, , , % "ahk_id" . HS4GuiHwnd
			Gui, HS4: Submit, NoHide
			Gui, HS3: Default
			F_UpdateSelHotLibDDL()
			;F_GuiMain_Redraw()
			GuiControl,, % IdEdit1, % v_TriggerString
			GuiControl,, % IdEdit2, % v_EnterHotstring
			GuiControl, ChooseString, % IdDDL2, % v_SelectHotstringLibrary
			Gui, HS4: Show, Hide
			Gui, HS3: Show, % "X" WinX . A_Space . "Y" WinY . A_Space . "AutoSize"
			Gui, HS3: Show, AutoSize ;don't know why it has to be doubled to properly display...
			ini_WhichGui := "HS3"
			;return
	}
	if (ini_WhichGui = "HS3")
		Menu, ConfGUI, Check, 	% TransA["Show full GUI (F4)"]
	else
		Menu, ConfGUI, UnCheck, % TransA["Show full GUI (F4)"]

}

HS4GuiSize() ;Gui event
{
	global ;assume-global mode
	
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
		return
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
	local Text := "", SectionList := [], str1 := []
	
	if (A_DefaultGui = "HS3")
	{
		Gui, HS3: Submit, NoHide
	}
	if (A_DefaultGui = "HS4")
		Gui, HS4: Submit, NoHide
	
	GuiControl, Enable, % IdButton4 ; button Delete hotstring (F8)
	Gui, HS3: Default			;All of the ListView function operate upon the current default GUI window.
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
	GuiControlGet, v_OutVarTemp2, Pos, % IdListView1 ;Check position of ListView1 again after resizing
	LV_ModifyCol(1, Round(0.1 * v_OutVarTemp2W))
	LV_ModifyCol(2, Round(0.1 * v_OutVarTemp2W))
	LV_ModifyCol(3, Round(0.1 * v_OutVarTemp2W))	
	LV_ModifyCol(4, Round(0.1 * v_OutVarTemp2W))
	LV_ModifyCol(5, Round(0.4 * v_OutVarTemp2W))
	LV_ModifyCol(6, Round(0.2 * v_OutVarTemp2W) - 3)

	if (!SectionList.MaxIndex())
		v_LibHotstringCnt := 0
	else 
		v_LibHotstringCnt := SectionList.MaxIndex()
	GuiControl, Text, % IdText13,  % A_Space . v_LibHotstringCnt
	GuiControl, Text, % IdText13b, % A_Space . v_LibHotstringCnt
	
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


F_HSLV() 
; copy content of List View 1 to editable fields of HS3 Gui
{
	global ;assume-global mode
	local Options := "", Fun := "", EnDis := "", TextInsert := "", OTextMenu := "", Comment := ""
	
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
	{ ;SendFun := "F_MenuText"
		GuiControl, HS3: Choose, v_SelectFunction, Menu & Clipboard (MCL)
		GuiControl, HS4: Choose, v_SelectFunction, Menu & Clipboard (MCL)
	}
	else if (Fun = "MSI")
	{ ;SendFun := "F_MenuTextAHK"
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
	MsgBox, 36, % SubStr(A_ScriptName, 1, -4) . A_Space . TransA["question"], % TransA["In order to aplly new font type it's necesssary to reload the application."]
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
	MsgBox, 36, % SubStr(A_ScriptName, 1, -4) . A_Space . TransA["question"], % TransA["In order to aplly new size of margin it's necesssary to reload the application."]
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
	MsgBox, 36, % SubStr(A_ScriptName, 1, -4) . A_Space . TransA["question"], % TransA["In order to aplly new font style it's necesssary to reload the application."]
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
	MsgBox, 36, % SubStr(A_ScriptName, 1, -4) . A_Space . TransA["question"], % TransA["In order to aplly new style it's necesssary to reload the application."]
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
		Menu, CompileSubmenu, Add, % TransA["Standard executable (Ahk2Exe.exe)"], F_Compile
	if (FileExist(v_TempOutStr . "upx.exe"))
		Menu, CompileSubmenu, Add, % TransA["Compressed executable (upx.exe)"], F_Compile
	if (FileExist(v_TempOutStr . "mpress.exe"))
		Menu, CompileSubmenu, Add, % TransA["Compressed executable (mpress.exe)"], F_Compile
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_Compile()
{
	local v_TempOutStr := "", v_TempOutStr2 := "", v_TempOutStr3 := ""
	Loop, Parse, %  A_AhkPath, "\"
	{
		if (Instr(A_LoopField, ".exe"))
			break
		v_TempOutStr .= A_LoopField . "\"
	}
	v_TempOutStr2 := v_TempOutStr . "Compiler" . "\" 
	
	Switch A_ThisMenuItem
	{
		Case TransA["Standard executable (Ahk2Exe.exe)"]:
			Run, % v_TempOutStr2 . "Ahk2Exe.exe" 
				. A_Space . "/in" . A_Space . A_ScriptDir . "\" . A_ScriptName 
				. A_Space . "/out" . A_Space . A_ScriptDir . "\" . SubStr(A_ScriptName, 1, -4) . "." . "exe"
				. A_Space . "/icon" . A_Space . A_ScriptDir . "\" . AppIcon 
				. A_Space . "/ahk" . A_Space . """" . v_TempOutStr . "\" . "AutoHotkey.exe" . """"
				. A_Space . "/compress" . A_Space . "0"
			MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["The executable file is prepared by Ahk2Exe, but not compressed:"]
				. "`n`n" . A_ScriptDir . "\" . SubStr(A_ScriptName, 1, -4) . ".exe"
		
		Case TransA["Compressed executable (upx.exe)"]:
			Run, % v_TempOutStr2 . "Ahk2Exe.exe" 
				. A_Space . "/in" . A_Space . A_ScriptDir . "\" . A_ScriptName 
				. A_Space . "/out" . A_Space . A_ScriptDir . "\" . SubStr(A_ScriptName, 1, -4) . "." . "exe"
				. A_Space . "/icon" . A_Space . A_ScriptDir . "\" . AppIcon 
				. A_Space . "/ahk" . A_Space . """" . v_TempOutStr . "\" . "AutoHotkey.exe" . """" 
				. A_Space . "/compress" . A_Space . "2" 
			MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"],  % TransA["The executable file is prepared by Ahk2Exe and compressed by upx.exe:"]
				. "`n`n" . A_ScriptDir . "\" . SubStr(A_ScriptName, 1, -4) . ".exe"
				
		Case TransA["Compressed executable (mpress.exe)"]:
			Run, % v_TempOutStr2 . "Ahk2Exe.exe" 
				. A_Space . "/in" . A_Space . A_ScriptDir . "\" . A_ScriptName 
				. A_Space . "/out" . A_Space . A_ScriptDir . "\" . SubStr(A_ScriptName, 1, -4) . "." . "exe"
				. A_Space . "/icon" . A_Space . A_ScriptDir . "\" . AppIcon 
				. A_Space . "/ahk" . A_Space . """" . v_TempOutStr . "\" . "AutoHotkey.exe" . """"
				. A_Space . "/compress" . A_Space . "1"
			MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["The executable file is prepared by Ahk2Exe and compressed by mpress.exe:"]
				. "`n`n" . A_ScriptDir . "\" . SubStr(A_ScriptName, 1, -4) . ".exe"
	}
	return
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
F_Reload()
{
	global ;assume-global mode
	MsgBox, 36, % SubStr(A_ScriptName, 1, -4) . A_Space . TransA["question"], % TransA["Are you sure you want to reload this application now?"]
		. "`n" . TransA["(Current configuration will be saved befor reload takes place)."]
	IfMsgBox, Yes
	{
		F_SaveGUIPos()
		Reload
	}
	IfMsgBox, No
		return
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

F_Exit()
{
	global ;assume-global mode
	MsgBox, 36, % SubStr(A_ScriptName, 1, -4) . A_Space . TransA["question"], % TransA["Are you sure you want to exit this application now?"]
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
	
; variable which is used as default content of Config.ini
	local ConfigIni := ""
	
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
		MsgBox, 48, % SubStr(A_ScriptName, 1, -4) . A_Space . TransA["warning"], % TransA["Config.ini wasn't found. The default Config.ini is now created in location:"] . "`n`n" . A_ScriptDir
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
	
	TrayTip, %A_ScriptName%, % TransA["Hotstrings have been loaded"], 1
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
	MsgBox, 68, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % "If any library was unchecked, its hotstring definitions remain active. Please reload the application." 
	. "`n`n" . "Do you want to reload application now?"
	IfMsgBox, Yes
	{
		F_SaveGUIPos()
		Reload
	}
	return
}

; ------------------------------------------------------------------------------------------------------------------------------------

F_LoadCreateTranslationTxt(decision*)
{
	
	; variable which is used as default content of Languages/English.ini. Join lines with `n separator and escape all ` occurrences. Thanks to that string lines where 'n is present 'aren't separated.
	;(Join`n `
	global ;assume-global mode
	local TransConst := ""
	
;Warning. If right side contains `n chars it's necessary to replace them with StrReplace.
	TransConst := "			
(Join`n `			
About/Help	 										= &About/Help
Add comment (optional) 									= Add comment (optional)
Add library 											= Add library
A library with that name already exists! 					= A library with that name already exists!
Apostrophe ' 											= Apostrophe '
Application											= Application
Application help 										= Application help
Application language changed to: 							= Application language changed to:
Are you sure you want to exit this application now?			= Are you sure you want to exit this application now?
Are you sure you want to reload this application now?			= Are you sure you want to reload this application now
Backslash \ 											= Backslash \
Cancel 												= Cancel
Caret 												= Caret
Case Sensitive (C) 										= Case Sensitive (C)
Change Language 										= Change Language
Choose existing hotstring library file before saving! 			= Choose existing hotstring library file before saving!
Choose library file (.ahk) for import 						= Choose library file (.ahk) for import
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
Config.ini will be deleted. Next application will be reloaded. This action cannot be undone. Are you sure? = Config.ini will be deleted. Next application will be reloaded. This action cannot be undone. Are you sure?
Configuration 											= &Configuration
Continue reading the library file? If you answer ""No"" then application will exit! = Continue reading the library file?`nIf you answer ""No"" then application will exit!
(Current configuration will be saved befor reload takes place).	= (Current configuration will be saved befor reload takes place).
Do you want to proceed? 									= Do you want to proceed?
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
Edit Hotstring 										= Edit Hotstring
Enable/Disable 										= Enable/Disable
Enable/disable libraries									= Enable/disable &libraries
Enable/disable triggerstring tips 							= Enable/disable triggerstring tips	
Enable sound if overrun 									= Enable sound if overrun
Enables Convenient Definition 							= Enables convenient definition and use of hotstrings (triggered by shortcuts longer text strings). `nThis is 3rd edition of this application, 2020 by Jakub Masiak and Maciej Słojewski (🐘). `nLicense: GNU GPL ver. 3.
Enter 												= Enter
Enter a name for the new library 							= Enter a name for the new library
Enter hotstring 										= Enter hotstring
Enter triggerstring										= Enter triggerstring
Enter triggerstring before hotstring is set					= Enter triggerstring before hotstring is set
Error												= Error
Error reading line from file:								= Error reading line from file:
Error, something went wrong with hotstring deletion:			= Error, something went wrong with hotstring deletion:
ErrorLevel was triggered by NewInput error. 					= ErrorLevel was triggered by NewInput error.
Error reading library file:								= Error reading library file:
Exclamation Mark ! 										= Exclamation Mark !
exists in a file 										= exists in a file
Exit													= Exit
Export from .csv to .ahk 								= &Export from .csv to .ahk
F3 Close Search hotstrings | F8 Move hotstring 				= F3 Close Search hotstrings | F8 Move hotstring
file! 												= file!
file in Languages subfolder!								= file in Languages subfolder!
file is now created in the following subfolder:				= file is now created in the following subfolder:
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
This library											= This library
Hotstrings have been loaded 								= Hotstrings have been loaded
Immediate Execute (*) 									= Immediate Execute (*)
Import from .ahk to .csv 								= &Import from .ahk to .csv
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
Library has been exported. 								= Library has been exported.
Library has been imported. 								= Library has been imported.
Library import. Please wait... 							= Library import. Please wait...
Library|Triggerstring|Trigger Options|Output Function|Enable/Disable|Hotstring|Comment = Library|Triggerstring|Trigger Options|Output Function|Enable/Disable|Hotstring|Comment
Light (default)										= Light (default)
Loaded hotstrings: 										= Loaded hotstrings:
Loading hotstrings from libraries... 						= Loading hotstrings from libraries...
Loading libraries. Please wait... 							= Loading libraries. Please wait...
Minus - 												= Minus -
Move 												= Move
No Backspace (B0) 										= No Backspace (B0)
No End Char (O) 										= No End Char (O)
No libraries have been found!								= No libraries have been found!
Number of characters for tips 							= &Number of characters for tips
OK													= &OK
Opening Curly Bracket { 									= Opening Curly Bracket {
Opening Round Bracket ( 									= Opening Round Bracket (
Opening Square Bracket [ 								= Opening Square Bracket [
Please wait, uploading .csv files... 						= Please wait, uploading .csv files...
question												= question
Question Mark ? 										= Question Mark ?
Quote "" 												= Quote ""
pixels												= pixels
Position of main window is saved in Config.ini.				= Position of main window is saved in Config.ini.	
Reload												= Reload
Remove Config.ini										= Remove Config.ini
Replacement text is blank. Do you want to proceed? 			= Replacement text is blank. Do you want to proceed?
Sandbox (F6)											= Sandbox (F6)
Save position of application window	 					= &Save position of application window
Search by: 											= Search by:
Search Hotstrings 										= Search Hotstrings
Search Hotstrings (F3)									= Search Hotstrings (F3)
Select a row in the list-view, please! 						= Select a row in the list-view, please!
Selected file is empty. 									= Selected file is empty.
Selected Hotstring will be deleted. Do you want to proceed? 	= Selected Hotstring will be deleted. Do you want to proceed?
Select hotstring library 								= Select hotstring library
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
Sort tips alphabetically 								= Sort tips &alphabetically
Sort tips by length 									= Sort tips by &length
Space 												= Space
Specified definition of hotstring has been deleted			= Specified definition of hotstring has been deleted
Standard executable (Ahk2Exe.exe)							= Standard executable (Ahk2Exe.exe)
Static hotstrings 										= &Static hotstrings
Tab 													= Tab
The application will be reloaded with the new language file. 	= The application will be reloaded with the new language file.
The default											= The default
The executable file is prepared by Ahk2Exe and compressed by mpress.exe: = The executable file is prepared by Ahk2Exe and compressed by mpress.exe:
The executable file is prepared by Ahk2Exe and compressed by upx.exe: = The executable file is prepared by Ahk2Exe and compressed by upx.exe:
The executable file is prepared by Ahk2Exe, but not compressed:	= The executable file is prepared by Ahk2Exe, but not compressed:
The hostring 											= The hostring
The library  											= The library 
The file path is: 										= The file path is:
the following line is found:								= the following line is found:
There is no											= There is no
There was no Languages subfolder, so one now is created.		= There was no Languages subfolder, so one now is created.
This library:											= This library:
This line do not comply to format required by this application.  = This line do not comply to format required by this application.
This option is valid 									= In case you observe some hotstrings aren't pasted from clipboard increase this value. `nThis option is valid for CL and MCL hotstring output functions. 
Toggle EndChars	 									= &Toggle EndChars
Total:												= Total:
Triggerstring 											= Triggerstring
Triggerstring tips 										= &Triggerstring tips
Triggerstring|Trigg Opt|Out Fun|En/Dis|Hotstring|Comment 		= Triggerstring|Trigg Opt|Out Fun|En/Dis|Hotstring|Comment
Underscore _											= Underscore _
Undo the last hotstring 									= &Undo the last hotstring
warning												= warning
↓ Click here to select hotstring library ↓					= ↓ Click here to select hotstring library ↓
)"
	
	TransA					:= {}	; ; this associative array is used to store translations of this application text strings
	
	local key := "", val := "", tick := false
	
	if (decision[1] = "create")
		FileAppend, %TransConst%, %A_ScriptDir%\Languages\English.txt, UTF-8 
	
	if (decision[1] = "load")
	{
		Loop, Read, %A_ScriptDir%\Languages\%v_Language%
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
	local name := "", tabSearch := "", line := "", FlagLoadTriggerTips := false
		,key := "", value := ""
	
	for key, value in ini_ShowTipsLib
		if ((key == nameoffile) and (value))
			FlagLoadTriggerTips := true
	
	name := SubStr(nameoffile, 1, -4) ;filename without extension
	Loop
	{
		FileReadLine, line, %A_ScriptDir%\Libraries\%nameoffile%, %A_Index%
		if (ErrorLevel) ;this is a trick to exit this loop when end of file is riched
			break
		
		tabSearch := StrSplit(line, "‖")	
		
		a_Library.Push(name) ; function Search
		a_TriggerOptions.Push(tabSearch[1])
		a_Triggerstring.Push(tabSearch[2]) 
		a_OutputFunction.Push(tabSearch[3])
		a_EnableDisable.Push(tabSearch[4])
		a_Hotstring.Push(tabSearch[5]) 
		a_Comment.Push(tabSearch[6])
		
		if (FlagLoadTriggerTips)
			a_Triggers.Push(tabSearch[2]) ; a_Triggers is used in main loop of application for generating tips
		
		F_ini_StartHotstring(line, nameoffile)
		
		++v_TotalHotstringCnt
		;OutputDebug, % "Content of IdText2 GuiControl:" . A_Space . v_LoadedHotstrings . A_Space . v_TotalHotstringCnt
	}
	
	GuiControl, Text, % IdText12,  % A_Space . v_TotalHotstringCnt ; Text: Puts new contents into the control.
	GuiControl, Text, % IdText12b, % A_Space . v_TotalHotstringCnt ; Text: Puts new contents into the control.
	return
}

; ------------------------------------------------------------------------------------------------------------------------------------

F_GuiHS4_CreateObject()
{
	global ;assume-global mode
	local x0 := 0, y0 := 0
	
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
		v_TextAddComment v_Comment
		v_TextSelectHotstringLibrary v_SelectHotstringLibrary
		v_DeleteHotstring 
		v_LibraryContent v_ShortcutsMainInterface v_SandString v_Sandbox v_NoOfHotstringsInLibrary
	*/
	
;1. Definition of HS4 GUI.
;-DPIScale doesn't work in Microsoft Windows 10
;+Border doesn't work in Microsoft Windows 10
;OwnDialogs
	Gui, 	HS4: New, 	-Resize +HwndHS4GuiHwnd +OwnDialogs -MaximizeBox, % SubStr(A_ScriptName, 1, -4) 
	Gui, 	HS4: Margin,	% c_xmarg, % c_ymarg
	Gui,		HS4: Color,	% c_WindowColor, % c_ControlColor
	
;2. Prepare all text objects according to mock-up.
	Gui,		HS4: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, 	HS4: Add, 		Text, 		x0 y0 HwndIdText1b, 									% TransA["Enter triggerstring"]
	Gui,		HS4: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, % c_FontType
	Gui, 	HS4: Add, 		Text, 		x0 y0 HwndIdText2b, % TransA["Total:"]
	Gui,		HS4: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, Consolas ;Consolas type is monospace
	Gui, 	HS4: Add, 		Text, 		x0 y0 HwndIdText12b, % A_Space . A_Space . A_Space . A_Space . "0"
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
	Gui, 	HS4: Add, 		Text, 		x0 y0 HwndIdText5b vv_TextAddComment, 						% TransA["Add comment (optional)"]
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
	Gui, 	HS4: Add, 		Text, 		x0 y0 HwndIdText10b vv_SandString, 						% TransA["Sandbox (F6)"]
	Gui, 	HS4: Add, 		Edit, 		x0 y0 HwndIdEdit10b vv_Sandbox r3 						; r3 = 3x rows of text
	
	Gui,		HS4: Add,			Text,		x0 y0 HwndIdText11b, % TransA["This library:"]
	Gui,		HS4: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, Consolas ;Consolas type is monospace
	Gui, 	HS4: Add, 		Text, 		x0 y0 HwndIdText13b,  % A_Space . A_Space . A_Space . "0" ;value of Hotstrings counter
	Gui,		HS4: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, % c_FontType
}

; ------------------------------------------------------------------------------------------------------------------------------------

F_GuiMain_CreateObject()
{
	global ;assume-global mode
	local x0 := 0, y0 := 0
	v_OptionImmediateExecute := 0, v_OptionCaseSensitive := 0, v_OptionNoBackspace := 0, v_OptionInsideWord := 0, v_OptionNoEndChar := 0, v_OptionDisable := 0
	
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
		v_TextAddComment v_Comment
		v_TextSelectHotstringLibrary v_SelectHotstringLibrary
		v_DeleteHotstring
		v_LibraryContent v_ShortcutsMainInterface v_SandString v_Sandbox v_NoOfHotstringsInLibrary
	*/
	
;1. Definition of HS3 GUI.
;-DPIScale doesn't work in Microsoft Windows 10
;+Border doesn't work in Microsoft Windows 10
;OwnDialogs
	Gui, 		HS3: New, 		+Resize +HwndHS3GuiHwnd +OwnDialogs -MaximizeBox, % SubStr(A_ScriptName, 1, -4)
	Gui, 		HS3: Margin,	% c_xmarg, % c_ymarg
	Gui,			HS3: Color,	% c_WindowColor, % c_ControlColor
	
;2. Prepare all text objects according to mock-up.
	Gui,			HS3: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, 		HS3: Add, 		Text, 		x0 y0 HwndIdText1, 										% TransA["Enter triggerstring"]
	;GuiControl, 	Hide, 		% IdText1
	
	Gui,			HS3: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, % c_FontType
	Gui, 		HS3: Add, 		Edit, 		x0 y0 HwndIdEdit1 vv_TriggerString 
	;GuiControl,	Hide,		% IdEdit1
	Gui,			HS3: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, % c_FontType
	Gui, 		HS3: Add, 		Text, 		x0 y0 HwndIdText2, % TransA["Total:"]
	Gui,			HS3: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, Consolas ;Consolas type is monospace
	Gui, 		HS3: Add, 		Text, 		x0 y0 HwndIdText12, % A_Space . A_Space . A_Space . A_Space . "0"
	Gui,			HS3: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, % c_FontType
	
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
	Gui,			HS3: Add,		GroupBox, 	x0 y0 HwndIdGroupBox1, 									% TransA["Select trigger option(s)"]
	Gui,			HS3: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, % c_FontType
;GuiControl,	Hide,		% IdGroupBox1
	
	Gui,			HS3: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, 		HS3: Add, 		Text, 		x0 y0 HwndIdText3 vv_TextSelectHotstringsOutFun, 			% TransA["Select hotstring output function"]
;GuiControl,	Hide,		% IdText3
	Gui,			HS3: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, % c_FontType
	
	Gui, 		HS3: Add, 		DropDownList, 	x0 y0 HwndIdDDL1 vv_SelectFunction gF_SelectFunction, 		SendInput (SI)||Clipboard (CL)|Menu & SendInput (MSI)|Menu & Clipboard (MCL)
;GuiControl,	Hide,		% IdDDL1
	
	Gui,			HS3: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, 		HS3: Add, 		Text, 		x0 y0 HwndIdText4 vv_TextEnterHotstring, 				% TransA["Enter hotstring"]
;GuiControl,	Hide,		% IdText4
	Gui,			HS3: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, % c_FontType
	
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
	Gui, 		HS3: Add, 		Text, 		x0 y0 HwndIdText5 vv_TextAddComment, 					% TransA["Add comment (optional)"]
;GuiControl,	Hide,		% IdText5
	Gui,			HS3: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, % c_FontType
	
	Gui, 		HS3: Add, 		Edit, 		x0 y0 HwndIdEdit9 vv_Comment Limit64 
;GuiControl,	Hide,		% IdEdit9
	
	Gui,			HS3: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, 		HS3: Add, 		Text, 		x0 y0 HwndIdText6 vv_TextSelectHotstringLibrary, 			% TransA["Select hotstring library"]
;GuiControl,	Hide,		% IdText6
	Gui,			HS3: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, % c_FontType
	
	Gui, 		HS3: Add, 		Button, 		x0 y0 HwndIdButton1 gF_GuiAddLibrary, 							% TransA["Add library"]
;GuiControl,	Hide,		% IdButton1
	Gui,			HS3: Add,		DropDownList,	x0 y0 HwndIdDDL2 vv_SelectHotstringLibrary gF_SelectLibrary Sort
;GuiControl,	Hide,		% IdDDL2
	
;Gui,			HS3:Font,		% "s" . c_FontSize . A_Space . "bold cBlack", % c_FontType
	Gui, 		HS3:Add, 		Button, 		x0 y0 HwndIdButton2 gF_SetHotstring,						% TransA["Set hotstring (F9)"]
;GuiControl,	HideSet% IdButton2
	Gui, 		HS3:Add, 		Button, 		x0 y0 HwndIdButton3 gF_Clear,							% TransA["Clear (F5)"]
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
	Gui, 		HS3:Add, 		ListView, 	x0 y0 HwndIdListView1 LV0x1 vv_LibraryContent AltSubmit gF_HSLV, % TransA["Triggerstring|Trigg Opt|Out Fun|En/Dis|Hotstring|Comment"]
;GuiControl,	Hide,		% IdListView1
	
	Gui,			HS3:Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, 		HS3:Add, 		Text, 		x0 y0 HwndIdText10 vv_SandString, 						% TransA["Sandbox (F6)"]
;GuiControl,	Hide,		% IdText10
	Gui,			HS3:Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, % c_FontType
	
	Gui, 		HS3:Add, 		Edit, 		x0 y0 HwndIdEdit10 vv_Sandbox r3 						; r3 = 3x rows of text
;GuiControl,	Hide,		% IdEdit10
;Gui, 		HS3:Add, 		Edit, 		HwndIdEdit11 vv_ViewString gViewString ReadOnly Hide
	Gui,			HS3:Add,		Text,		x0 y0 HwndIdText11, % TransA["This library:"]
	Gui,			HS3:Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, Consolas ;Consolas type is monospace
	Gui, 		HS3:Add, 		Text, 		x0 y0 HwndIdText13,  % A_Space . A_Space . A_Space . "0" ;value of Hotstrings counter
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
		v_yNext := LeftColumnH + c_ymarg 
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
	
	;5.2. Button between left and right column
	v_yNext := c_ymarg
	v_xNext := LeftColumnW + c_xmarg
	GuiControlGet, v_OutVarTemp, Pos, % IdText2b
	v_hNext := v_OutVarTempY 
	GuiControl, Move, % IdButton5b, % "x" v_xNext "y" v_yNext "h" v_hNext
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
	HS4MinHeight		:= LeftColumnH + c_ymarg
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
	v_hNext := HofText + 3 * HofCheckBox + c_ymarg
	GuiControl, Move, % IdGroupBox1, % "x" v_xNext "y" v_yNext "w" v_wNext "h" v_hNext
	;GuiControl, Show, % IdGroupBox1
	
	v_yNext += HofText
	v_xNext := c_xmarg * 2
	;*[Three]
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
	;tu jestem
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
	Gui, MyAbout: Add, 		Text, x0 y0 HwndIdLine1, 													% TransA["Let's make your PC personal again..."]
	Gui,	MyAbout: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, 					% c_FontType
	Gui, MyAbout: Add, 		Text, x0 y0 HwndIdLine2, 													% TransA["Enables Convenient Definition"]
	Gui,	MyAbout: Font,		% "s" . c_FontSize . A_Space . "bold underline" . A_Space . "c" . c_FontColorHighlighted, % c_FontType
	Gui, MyAbout: Add, 		Text, x0 y0 HwndIdLink1 gLink1,												% TransA["Application help"]
	Gui, MyAbout: Add, 		Text, x0 y0 HwndIdLink2 gLink2,												% TransA["Genuine hotstrings AutoHotkey documentation"]
	Gui,	MyAbout: Font,		% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, 					% c_FontType
	Gui, MyAbout: Add, 		Button, x0 y0 HwndIdAboutOkButton gAboutOkButton,									% TransA["OK"]
	
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
	
	FoundPos := Instr(TransA["About/Help"], "&")
	if (FoundPos)
	{
		if (FoundPos > 1)
			NewStr := SubStr(TransA["About/Help"], FoundPos - 1) . SubStr(TransA["About/Help"], FoundPos + 1)
		else
			NewStr := SubStr(TransA["About/Help"], FoundPos + 1)
	}
	
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
	local v_IsLibraryEmpty := true, v_ConfigLibrary := "", v_ConfigFlag := false
		,o_Libraries := {}, v_LibFileName := "", key := 0, value := "", TempLoadLib := "", TempShowTipsLib := "", v_LibFlagTemp := ""
		,FlagFound := false, PriorityFlag := false, ValueTemp := 0, SectionTemp := ""
	
	ini_LoadLib := {}, ini_ShowTipsLib := {}	; this associative array is used to store information about Libraries\*.csv files to be loaded
	
	IniRead, TempLoadLib,	Config.ini, LoadLibraries
	
	;Check if Libraries subfolder exists. If not, create it and display warning.
	v_IsLibraryEmpty := true
	if (!Instr(FileExist(A_ScriptDir . "\Libraries"), "D"))				; if  there is no "Libraries" subfolder 
	{
		MsgBox, 48, % SubStr(A_ScriptName, 1, -4) . A_Space . TransA["warning"], There is no Libraries subfolder and no lbrary (*.csv) file exist!`nThe  %A_ScriptDir%\Libraries\ folder is now created.
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
		MsgBox, 52, % SubStr(A_ScriptName, 1, -4) . A_Space . TransA["warning"], % TransA["Libraries folder:"] . "`n`n" . A_ScriptDir . "\Libraries" . A_Space . "`n`n"
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
		Loop, Parse, TempLoadLib, `n
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
		Loop, Parse, TempShowTipsLib, `n
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

F_ini_StartHotstring(txt, nameoffile) 
{ 
	global	;assume-global mode
	local txtsp := "", Options := "", SendFun := "", EnDis := "", OnOff := "", TextInsert := "", Oflag := 0
	
	v_UndoHotstring := ""
	v_TriggerString := ""
	
	txtsp 			:= StrSplit(txt, "‖")
	Options 			:= txtsp[1]
	v_TriggerString 	:= txtsp[2]
	if (!v_TriggerString) 
	{
		MsgBox, 262420, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["Error"], % TransA["Error reading library file:"] . "`n`n" . nameoffile . "`n`n" . TransA["the following line is found:"] 
		. "`n" . txt . "`n`n" . TransA["This line do not comply to format required by this application."] . "`n`n" 
		. TransA["Continue reading the library file?`nIf you answer ""No"" then application will exit!"]
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
	
	TextInsert := StrReplace(TextInsert, "``n", "`n") ;theese lines are necessary to handle rear definitions of hotstrings such as those finished with `n, `r etc.
	TextInsert := StrReplace(TextInsert, "``r", "`r")		
	TextInsert := StrReplace(TextInsert, "``t", "`t")
	TextInsert := StrReplace(TextInsert, "``", "`")
	
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
	;F_LoadHotstringsFromLibraries()
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
				FileAppend, % "`n:" . v_Options . ":" . v_Trigger . "::" . a_MenuHotstring[A_Index] . A_Space . ";" . " warning, code generated automatically for definitions based on menu, see documentation of Hotstrings app for details", %v_OutputFile%, UTF-8
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
	MsgBox, % TransA["Library has been exported."] . "`n" . TransA["The file path is:"] . A_Space . v_OutputFile
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

;Critical Off ;If the script has just resized the window, follow this example to ensure GuiSize is called immediately
;Sleep -1

if (v_ResizingFlag) ;if run for the very first time
{
	Gui, HS3: +MinSize%HS3MinWidth%x%HS3MinHeight%
	Gui, HS4: +MinSize%HS4MinWidth%x%HS4MinHeight%
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
	
	Switch v_WhichGUIisMinimzed
	{
		Case "HS3":
			Gui, HS3: Show, Restore ;Unminimizes or unmaximizes the window, if necessary. The window is also shown and activated, if necessary.
			return
		Case "HS4":
			
			Gui, HS4: Show, Restore ;Unminimizes or unmaximizes the window, if necessary. The window is also shown and activated, if necessary.
			return
	}
return
#If	;#If (v_Param != "l") 
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
F_SetHotstring()
{
	global ;assume-global mode
	local 	TextInsert := "", OldOptions := "", Options := "", SendFun := "", OnOff := "", EnDis := "", OutputFile := "", InputFile := "", LString := "", ModifiedFlag := false
			,txt := "", txt1 := "", txt2 := "", txt3 := "", txt4 := "", txt5 := "", txt6 := ""
	
	;1. Read all inputs. 
	Gui, % A_DefaultGui . ":" A_Space . "Submit", NoHide
	Gui, % A_DefaultGui . ":" A_Space . "+OwnDialogs"
	
	if (Trim(v_TriggerString) = "")
	{
		MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"],  % TransA["Enter triggerstring before hotstring is set"]
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
		TextInsert := SubStr(TextInsert, 2, StrLen(TextInsert)-1)
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
		MsgBox, 64, % SubStr(A_ScriptName, 1, -4) . ":" . A_Space . TransA["information"], % TransA["Choose existing hotstring library file before saving!"]
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
	
	;a_String[2] := Options ;???
	
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
	
	Gui, HS3: Default			;All of the ListView function operate upon the current default GUI window.
	Gui, ListView, % IdListView1	;if HS4 is active still correct ListView have to be loaded with data
	
	Loop, Read, %InputFile%, %OutputFile% ;read all definitions from this library file 
	{
		
		if (InStr(A_LoopReadLine, LString, 1) and InStr(Options, "C")) or (InStr(A_LoopReadLine, LString) and !(InStr(Options, "C")))
		{
			MsgBox, 68,, % TransA["The hostring"] . A_Space . """" .  v_TriggerString . """" . A_Space .  TransA["exists in a file"] . A_Space . v_SelectHotstringLibrary . "." . A_Space . TransA["Do you want to proceed?"]
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
		;SectionList.Push(txt)
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
		txt := % txt1 . "‖" . txt2 . "‖" . txt3 . "‖" . txt4 . "‖" . txt5 . "‖" . txt6 . "`r`n"
		if !((txt1 == "") and (txt2 == "") and (txt3 == "") and (txt4 == "") and (txt5 == "") and (txt6 == "")) ;only not empty definitions are added, not sure why
			FileAppend, %txt%, Libraries\%v_SelectHotstringLibrary%, UTF-8
	}
	
	;7. Increment library counter.
	++v_LibHotstringCnt
	++v_TotalHotstringCnt
	GuiControl, Text, % IdText13,  % A_Space . v_LibHotstringCnt
	GuiControl, Text, % IdText13b, % A_Space . v_LibHotstringCnt
	GuiControl, Text, % IdText12,  % A_Space . v_TotalHotstringCnt
	GuiControl, Text, % IdText12b, % A_Space . v_TotalHotstringCnt
	
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

HSLV2:
Gui, HS3Search:+OwnDialogs
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
F_SelectLibrary()
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

ALibOK:
Gui, ALib:Submit, NoHide
if (v_NewLib == "")
{
	MsgBox, % TransA["Enter a name for the new library"]
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
Else
	MsgBox, 48, % SubStr(A_ScriptName, 1, -4) . A_Space . TransA["warning"], % TransA["A library with that name already exists!"]
return

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
Link1:
Run, https://github.com/mslonik/Hotstrings
return

Link2:
Run, https://www.autohotkey.com/docs/Hotstrings.htm
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
v_WhichGUIisMinimzed := "HS3"
return
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
HS4GuiClose:
HS4GuiEscape:
Gui,		HS4: Show, Hide
v_WhichGUIisMinimzed := "HS4"
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; Here I use 2x GUIs: SearchLoad which shows progress on time of library loading process and HS3Search which is in fact Search GUI name.
; Not clear why v_HS3SearchFlag is used.
L_Searching:
if (v_HS3SearchFlag) 
	Gui, HS3Search: Show
else
{
	/*
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
		if (WinExist("Search Hotstring"))	; I have serious doubts if those lines are useful
		{
			Gui, HS3Search:Hide
		}
	*/
	Gui, HS3Search: New, 	% "+Resize +HwndHS3SearchHwnd +Owner +MinSize" HS3MinWidth + 3 * c_xmarg "x" HS3MinHeight, % TransA["Search Hotstrings"]
	Gui, HS3Search: Margin,	% c_xmarg, % c_ymarg
	Gui,	HS3Search: Color,	% c_WindowColor, % c_ControlColor
	Gui,	HS3Search: Font,	% "s" . c_FontSize . A_Space . "norm" . A_Space . "c" . c_FontColor, % c_FontType

	v_HS3SearchFlag := 1
	Gui, HS3Search:Add, Text, ,	Search: ;future: translate
	Gui, HS3Search:Add, Text, 		% "yp xm+" . 420, % TransA["Search by:"]
	Gui, HS3Search:Add, Edit, 		% "xm w" . 400 . " vv_SearchTerm gSearch"
	Gui, HS3Search:Add, Radio, 		% "yp xm+" . 420 . " vv_RadioGroup gSearchChange Checked", % TransA["Triggerstring"]
	Gui, HS3Search:Add, Radio, 		% "yp xm+" . 540 . " gSearchChange", % TransA["Hotstring"]
	Gui, HS3Search:Add, Radio, 		% "yp xm+" . 640 . " gSearchChange", % TransA["Library"]
	Gui, HS3Search:Add, Button, 		% "yp-2 xm+" . 720 . " w" . 100 . " gMoveList Default", % TransA["Move"]
	Gui, HS3Search:Add, ListView, 	% "HwndIdLV_Search xm grid vList +AltSubmit gHSLV2 h400" . A_Space . "w" HS3MinWidth, % TransA["Library|Triggerstring|Trigger Options|Output Function|Enable/Disable|Hotstring|Comment"]
	
	Loop, % a_Library.MaxIndex() ; Those arrays have been loaded by F_LoadLibrariesToTables()
	{
		LV_Add("", a_Library[A_Index], a_Triggerstring[A_Index], a_TriggerOptions[A_Index], a_OutputFunction[A_Index], a_EnableDisable[A_Index], a_Hotstring[A_Index], a_Comment[A_Index])
	}
	LV_ModifyCol(1, "Sort")
	/*
		ini_StartWlist := 940
		ini_StartHlist := 500
		SetTitleMatchMode, 3
		WinGetPos, ini_StartXlist, ini_StartYlist,,,Hotstrings
		if ((ini_StartXlist == "") or (ini_StartYlist == ""))
		{
			;ini_StartXlist := (Mon%v_SelectedMonitor%Left + (Abs(Mon%v_SelectedMonitor%Right - Mon%v_SelectedMonitor%Left)/2))*DPI%v_SelectedMonitor% - ini_StartWlist/2
			ini_StartXlist := 0
			;ini_StartYlist := (Mon%v_SelectedMonitor%Top + (Abs(Mon%v_SelectedMonitor%Bottom - Mon%v_SelectedMonitor%Top)/2))*DPI%v_SelectedMonitor% - ini_StartHlist/2
			ini_StartYlist := 0
		}
	*/
	Gui, HS3Search:Add, Text, x0 h1 0x7 w10 vLine2
	;Gui, HS3Search:Font, % "s" . c_FontSize . " cBlack Norm"
	Gui, HS3Search:Add, Text, xm vShortcuts2, % TransA["F3 Close Search hotstrings | F8 Move hotstring"]
	if !(v_SearchTerm == "")
		GuiControl,, v_SearchTerm, %v_SearchTerm%
	if (v_RadioGroup == 1)
		GuiControl,, Triggerstring, 1
	else if (v_RadioGroup == 2)
		GuiControl,, Hotstring, 1
	else if (v_RadioGroup == 3)
		GuiControl,, Library, 1
	;Gui, HS3Search: Show, % "w" . ini_StartWlist . " h" . ini_StartHlist . " x" . ini_StartXlist . " y" . ini_StartYlist
	Gui, HS3Search: Show, % "W" HS3MinWidth "H" HS3MinHeight
	;Gui, SearchLoad: Destroy
}

Search:
Gui, HS3Search:Default
Gui, HS3Search:Submit, NoHide
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
Gui, HS3Search:Submit, NoHide 
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
F_SelectLibrary()
	;Gosub, SectionChoose
Loop, Read, %InputFile%
{
	if InStr(A_LoopReadLine, LString)
	{
		MsgBox, 4,, % TransA["The hostring"] . A_Space . """" . Triggerstring . A_Space .  """" . TransA["exists in a file"] . A_Space . TargetLib . A_Space . TransA["Do you want to proceed?"]
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
MsgBox, % TransA["Hotstring moved to the"] . A_Space . TargetLib . A_Space . TransA["file!"]
Gui, MoveLibs:Destroy
Gui, HS3Search:Hide	

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

~^f::
~^s::
~F3::
HS3SearchGuiEscape:
HS3SearchGuiClose:
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
	MsgBox, % TransA["Application language changed to:"] . A_Space . SubStr(v_Language, 1, StrLen(v_Language)-4) . "`n" . TransA["The application will be reloaded with the new language file."]
	Reload