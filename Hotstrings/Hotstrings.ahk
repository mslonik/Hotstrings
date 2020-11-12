/*
Author:      Jakub Masiak, Maciej Słojewski, mslonik, http://mslonik.pl
Purpose:     Facilitate normal operation for company desktop.
Description: Hotstrings for everyday professional activities and office cockpit.
License:     GNU GPL v.3
*/
Try
{
	#Requires AutoHotkey v1.1.33+
}
Catch
{
	MsgBox This script will run only on v1.1.33.00 and later v1.1.* releases.
	ExitApp
}
#SingleInstance force 			; only one instance of this script may run at a time!
#NoEnv  						; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  							; Enable warnings to assist with detecting common errors.
; #Persistent
SendMode Input  				; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%		; Ensures a consistent starting directory.
; ---------------------- HOTSTRINGS -----------------------------------

IfNotExist, Config.ini
{
	ini =
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
)
	FileAppend, %ini%, Config.ini
	MsgBox, Config.ini wasn't found. The default Config.ini is now created.
}

IfNotExist, Libraries\PersonalHotstrings.csv
	FileAppend,, Libraries\PersonalHotstrings.csv, UTF-8
IfNotExist, Libraries\New.csv
	FileAppend,, Libraries\New.csv, UTF-8

if !(A_Args[1] == "l")
{
	Menu, Tray, Add, Edit Hotstring, L_GUIInit
	Menu, Tray, Add, Search Hotstrings, L_Searching
	Menu, Tray, Default, Edit Hotstring
	Menu, Tray, Add
	Menu, Tray, NoStandard
	Menu, Tray, Standard
}
EndChars()
; ---------------------- SECTION OF GLOBAL VARIABLES ----------------------

global v_Param := A_Args[1]
global v_PreviousSection := A_Args[3]
global v_PreviousWidth := A_Args[4]
global v_PreviousHeight := A_Args[5]
global v_PreviousX := A_Args[6]
global v_PreviousY := A_Args[7]
global v_PreviousMonitor := A_Args[9]
global v_EnterHotstring := ""
global v_EnterHotstring1 := ""
global v_EnterHotstring2 := ""
global v_EnterHotstring3 := ""
global v_EnterHotstring4 := ""
global v_EnterHotstring5 := ""
global v_EnterHotstring6 := ""
global v_TriggerString := ""
global v_OptionImmediateExecute := ""
global v_OptionCaseSensitive := ""
global v_OptionNoBackspace := ""
global v_OptionInsideWord := ""
global v_OptionNoEndChar := ""
global v_OptionDisable := ""
global v_SelectFunction := ""
global v_SelectHotstringLibrary := ""
global v_DeleteHotstring := ""
global v_ShortcutsMainInterface := ""
global v_LibraryContent := ""
global v_ViewString := ""
global v_CaseSensitiveC1 := ""
global a_String := ""
global a_Hotstring := []
global a_Library := []
global a_Triggerstring := []
global a_EnableDisable := []
global a_TriggerOptions := []
global a_OutputFunction := []
global a_Comment := []
global v_SelectedRow := 0
global v_SelectedRow2 := 0
global a_Triggers := []
global v_InputString := ""
global v_TypedTriggerstring := ""
global v_UndoHotstring := ""
global v_UndoTriggerstring := ""
global ini_Tips := ""
global ini_Delay := ""
global v_ShowGui := ""
global v_MonitorFlag := ""
global ini_Cursor := ""
global ini_Caret := ""
global ini_MenuCursor := ""
global ini_MenuCaret := ""
global ini_AmountOfCharacterTips := ""
global a_SelectedTriggers := []
global v_HotstringFlag := 0
global v_TipsFlag := 0
global v_MenuMax := 0
global v_MenuMax2 := 0
global v_Tips := ""
global v_IndexLog := 1
global v_MouseX := ""
global v_MouseY := ""
global ini_MenuSound := ""
global v_FlagSound := 0
global v_SearchTerm := ""
global v_RadioGroup := ""
if !(A_Args[8])
	v_SelectedRow := 0
else
	v_SelectedRow := A_Args[8]
if !(v_PreviousMonitor)
	v_SelectedMonitor := 0
else
	v_SelectedMonitor := v_PreviousMonitor
IniRead, ini_Tips, 						Config.ini, Configuration, Tips
IniRead, ini_Cursor, 					Config.ini, Configuration, Cursor
IniRead, ini_Caret, 					Config.ini, Configuration, Caret
IniRead, ini_MenuCursor, 				Config.ini, Configuration, MenuCursor
IniRead, ini_MenuCaret, 				Config.ini, Configuration, MenuCaret
IniRead, ini_Delay, 					Config.ini, Configuration, Delay
IniRead, ini_AmountOfCharacterTips, 	Config.ini, Configuration, TipsChars
IniRead, ini_MenuSound,					Config.ini, Configuration, MenuSound
v_MonitorFlag := 0
if !(v_PreviousSection)
	v_ShowGui := 1
else
	v_ShowGui := 2
if (v_Param == "d")
	TrayTip,, %A_ScriptName% - Debug, 1
else if (v_Param == "l")
	TrayTip,, %A_ScriptName% - Lite, 1
else	
	TrayTip,, %A_ScriptName%, 1

; ---------------------------- INITIALIZATION -----------------------------

Loop, Files, Libraries\*.csv
{
	if !((A_LoopFileName == "PersonalHotstrings.csv") or (A_LoopFileName == "New.csv"))
	{
		F_LoadFiles(A_LoopFileName)
	}
}
F_LoadFiles("PersonalHotstrings.csv")
F_LoadFiles("New.csv")
; SetTimer, L_DPIScaling, 100
if(v_PreviousSection)
	gosub L_GUIInit
if (v_Param == "d")
{
	FileCreateDir, Logs
	v_LogFileName := % "Logs\Logs" . A_DD . A_MM . "_" . A_Hour . A_Min . ".txt"
	FileAppend,, %v_LogFileName%
}

Loop,
{
	Input, out,V L1, {Esc}
	if (ErrorLevel = "NewInput")
	{
		MsgBox, ErrorLevel was triggered by NewInput error.
	}
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
				If InStr(a_Triggers[A_Index], v_InputString) == 1
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
				If InStr(a_Triggers[A_Index], v_InputString) == 1
				{
				If !(v_Tips == "")
						v_Tips .= "`n"
					v_Tips .= a_Triggers[A_Index]
				}
			}
			If (v_Tips == "") and InStr(HotstringEndChars,SubStr(v_InputString,-1,1))
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
			a_SelectedTriggers := F_SortArrayAlphabetically(a_SelectedTriggers)
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
				CoordMode, Caret, Screen
				ToolTip, %v_Tips%, A_CaretX + 20, A_CaretY - 20
			}
			if (ini_Cursor)
			{
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

; -------------------------- SECTION OF HOTKEYS ---------------------------
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
			a_SelectedTriggers := F_SortArrayAlphabetically(a_SelectedTriggers)
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
				CoordMode, Caret, Screen
				ToolTip, %v_Tips%, A_CaretX + 20, A_CaretY - 20
			}
			if (ini_Cursor)
			{
				MouseGetPos, v_MouseX, v_MouseY
				ToolTip, %v_Tips%, v_MouseX + 20, v_MouseY - 20
			}
		}
		else
		if (v_Param == "d")
		{
			FileAppend, % v_IndexLog . "|" . v_InputString . "|" . ini_AmountOfCharacterTips . "|" . ini_Tips . "|" . v_Tips . "`n- - - - - - - - - - - - - - - - - - - - - - - - - -`n", %v_LogFileName%
			v_IndexLog++
		}
	}
return

$^z::			;~ Ctrl + z as in MS Word: Undo
$!BackSpace:: 	;~ Alt + Backspace as in MS Word: rolls back last Autocorrect action
	IniRead, Undo, Config.ini, Configuration, UndoHotstring
	if (Undo == 1) and (v_TypedTriggerstring && (A_ThisHotkey != A_PriorHotkey))
	{
		ToolTip, Undo the last hotstring., % A_CaretX, % A_CaretY - 20
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

#if WinExist("Hotstrings") and WinExist("ahk_class AutoHotkeyGUI")
~^c::
	Sleep, %ini_Delay%
	ControlSetText, Edit2, %Clipboard%
return
#if

#if WinActive("Hotstrings") and WinActive("ahk_class AutoHotkeyGUI")

F1::
	Gui, HS3:Default
	goto, About
; return

F2::
	Gui, HS3:Default
	Gui, HS3:Submit, NoHide
	if (v_SelectHotstringLibrary == "")
	{
		MsgBox, Select hotstring library
		return
	}
	GuiControl, Focus, v_LibraryContent
	if (LV_GetNext(0,"Focused") == 0)
		LV_Modify(1, "+Select +Focus")
return

F3::
	Gui, HS3:Default
	goto, L_Searching
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
	goto, Delete
; return

F9::
	Gui, HS3:Default
	goto, AddHotstring
; return

#if

; ms on 2020-11-02
~Alt::
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
	; MsgBox, Tu jestem!
	ToolTip,
	v_InputString := ""
return


#if WinActive("Search Hotstrings") and WinActive("ahk_class AutoHotkeyGUI")

F8::
	Gui, HS3List:Default
	goto, MoveList
#if
; ------------------------- SECTION OF FUNCTIONS --------------------------

F_LoadFiles(nameoffile)
{
	Loop
	{
		FileReadLine, line, Libraries\%nameoffile%, %A_Index%
		if ErrorLevel
			break
		line := StrReplace(line, "``n", "`n")
		line := StrReplace(line, "``r", "`r")		
		line := StrReplace(line, "``t", "`t")
		F_StartHotstring(line)
	}
	return
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

F_StartHotstring(txt)
{
	static Options, v_TriggerString, OnOff, EnDis, SendFun, TextInsert
	v_UndoHotstring := ""
	txtsp := StrSplit(txt, "‖")
	Options := txtsp[1]
	v_TriggerString := txtsp[2]
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
		a_Triggers.Push(v_TriggerString)
	}
	return
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
	v_InputString :=
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
	v_InputString :=
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
	v_InputString :=
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
	Gui, Menu:Font, cGray s8
	Gui, Menu:Color,,FFFFEF
	Gui, Menu:Add, Listbox, x0 y0 h100 w250 vMenuListbox,
	v_MenuMax := 0
	for k, MenuItems in StrSplit(TextOptions,"¦") ;parse the data on the weird pipe character
	{
		GuiControl,, MenuListbox, % A_Index . ". " . MenuItems
		v_MenuMax++
	}
	if (ini_MenuCaret)
	{
		CoordMode, Caret, Screen
		MenuX := A_CaretX + 20
		MenuY := A_CaretY - 20
	}
	if (ini_MenuCursor) or ((MenuX == "") and (MenuY == ""))
	{
		CoordMode, Mouse, Screen
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
sleep, %ini_Delay% ;Remember to sleep before restoring clipboard or it will fail
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
	Send, % SubStr(A_PriorHotkey, InStr(A_PriorHotkey, ":", v_OptionCaseSensitive := false, StartingPos := 1, Occurrence := 2) + 1)
	return
#If

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

F_MenuTextAHK(TextOptions, Oflag){
	global MenuListbox, Ovar
	v_InputString :=
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
	Gui, MenuAHK:Font, cGray s8
	Gui, MenuAHK:Color,,FFFFEF
	Gui, MenuAHK:Add, Listbox, x0 y0 h100 w250 vMenuListbox2,
	v_MenuMax2 := 0
	for k, MenuItems in StrSplit(TextOptions,"¦") ;parse the data on the weird pipe character
	{
		GuiControl,, MenuListbox2, % A_Index . ". " . MenuItems
		v_MenuMax2++
	}
	if (ini_MenuCaret)
	{
		CoordMode, Caret, Screen
		MenuX := A_CaretX + 20
		MenuY := A_CaretY - 20
	}
	if (ini_MenuCursor) or ((MenuX == "") and (MenuY == ""))
	{
		CoordMode, Mouse, Screen
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
;MsgBox, % InputLocaleID . " `" . Polish
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
	global v_SelectedMonitor
	If (State = 1)
		Gui, HS3:Font,% "s" . 12*DPI%v_SelectedMonitor% . " cRed Norm", Calibri
	Else 
		Gui, HS3:Font,% "s" . 12*DPI%v_SelectedMonitor% . " cBlack Norm", Calibri
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

EndChars()
{
	global

	HotstringEndChars := ""
	IniRead, EndingChar_Space, 				Config.ini, Configuration, EndingChar_Space
	IniRead, EndingChar_Minus, 				Config.ini, Configuration, EndingChar_Minus
	IniRead, EndingChar_ORoundBracket, 		Config.ini, Configuration, EndingChar_ORoundBracket
	IniRead, EndingChar_CRoundBracket, 		Config.ini, Configuration, EndingChar_CRoundBracket
	IniRead, EndingChar_OSquareBracket, 	Config.ini, Configuration, EndingChar_OSquareBracket
	IniRead, EndingChar_CSquareBracket, 	Config.ini, Configuration, EndingChar_CSquareBracket
	IniRead, EndingChar_OCurlyBracket, 		Config.ini, Configuration, EndingChar_OCurlyBracket
	IniRead, EndingChar_CCurlyBracket, 		Config.ini, Configuration, EndingChar_CCurlyBracket
	IniRead, EndingChar_Colon, 				Config.ini, Configuration, EndingChar_Colon
	IniRead, EndingChar_Semicolon, 			Config.ini, Configuration, EndingChar_Semicolon
	IniRead, EndingChar_Apostrophe, 		Config.ini, Configuration, EndingChar_Apostrophe
	IniRead, EndingChar_Quote, 				Config.ini, Configuration, EndingChar_Quote
	IniRead, EndingChar_Slash, 				Config.ini, Configuration, EndingChar_Slash
	IniRead, EndingChar_Backslash, 			Config.ini, Configuration, EndingChar_Backslash
	IniRead, EndingChar_Comma, 				Config.ini, Configuration, EndingChar_Comma
	IniRead, EndingChar_Dot, 				Config.ini, Configuration, EndingChar_Dot
	IniRead, EndingChar_QuestionMark, 		Config.ini, Configuration, EndingChar_QuestionMark
	IniRead, EndingChar_ExclamationMark, 	Config.ini, Configuration, EndingChar_ExclamationMark
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
	Hotstring("EndChars",HotstringEndChars)
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

; --------------------------- SECTION OF LABELS ---------------------------

TurnOffTooltip:
	ToolTip ,
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

 #if, v_Param != "l"

^#h::
L_GUIInit:
	SysGet, N, MonitorCount
    Loop, % N
    {
        SysGet, Mon%A_Index%, Monitor, %A_Index%
        W%A_Index% := Mon%A_Index%Right - Mon%A_Index%Left
        H%A_Index% := Mon%A_Index%Bottom - Mon%A_Index%Top
        DPI%A_Index% := round(W%A_Index%/1920*(96/A_ScreenDPI),2)
    }
    SysGet, PrimMon, MonitorPrimary
    if (v_SelectedMonitor == 0)
        v_SelectedMonitor := PrimMon
    Gui, HS3:New, +Resize 
    Gui, HS3:Margin, 12.5*DPI%v_SelectedMonitor%, 7.5*DPI%v_SelectedMonitor%
    Gui, HS3:Font, % "s" . 12*DPI%v_SelectedMonitor% . " bold cBlue", Calibri
    Gui, HS3:Add, Text, % "xm+" . 9*DPI%v_SelectedMonitor%,Enter triggerstring
    Gui, HS3:Font, % "s" . 12*DPI%v_SelectedMonitor% . " norm cBlack"
    Gui, HS3:Add, Edit, % "w" . 184*DPI%v_SelectedMonitor% . " h" . 25*DPI%v_SelectedMonitor% . " xp+" . 227*DPI%v_SelectedMonitor% . " yp vv_TriggerString",
    Gui, HS3:Font, % "s" . 12*DPI%v_SelectedMonitor% . " bold cBlue"
    Gui, HS3:Add, GroupBox, % "section xm w" . 425*DPI%v_SelectedMonitor% . " h" . 106*DPI%v_SelectedMonitor%, Select trigger option(s)
    Gui, HS3:Font, % "s" . 12*DPI%v_SelectedMonitor% . " norm cBlack"
    Gui, HS3:Add, CheckBox, % "gCapsCheck vv_OptionImmediateExecute xs+" . 12*DPI%v_SelectedMonitor% . " ys+" . 25*DPI%v_SelectedMonitor%, Immediate Execute (*)
    Gui, HS3:Add, CheckBox, % "gCapsCheck vv_OptionCaseSensitive xp+" . 225*DPI%v_SelectedMonitor% . " yp+" . 0*DPI%v_SelectedMonitor%, Case Sensitive (C)
    Gui, HS3:Add, CheckBox, % "gCapsCheck vv_OptionNoBackspace xp-" . 225*DPI%v_SelectedMonitor% . " yp+" . 25*DPI%v_SelectedMonitor%, No Backspace (B0)
    Gui, HS3:Add, CheckBox, % "gCapsCheck vv_OptionInsideWord xp+" . 225*DPI%v_SelectedMonitor% . " yp+" . 0*DPI%v_SelectedMonitor%, Inside Word (?)
    Gui, HS3:Add, CheckBox, % "gCapsCheck vv_OptionNoEndChar xp-" . 225*DPI%v_SelectedMonitor% . " yp+" . 25*DPI%v_SelectedMonitor%, No End Char (O)
    Gui, HS3:Add, CheckBox, % "gCapsCheck vv_OptionDisable xp+" . 225*DPI%v_SelectedMonitor% . " yp+" . 0*DPI%v_SelectedMonitor%, Disable
	Gui, HS3:Font, % "s" . 12*DPI%v_SelectedMonitor% . " cBlue Bold"
    Gui, HS3:Add, Text,% "xm+" . 9*DPI%v_SelectedMonitor%, Select hotstring output function
    Gui, HS3:Font, % "s" . 12*DPI%v_SelectedMonitor% . " cBlack Norm"
    Gui, HS3:Add, DropDownList, % "xm w" . 424*DPI%v_SelectedMonitor% . " vv_SelectFunction gL_SelectFunction hwndddl", SendInput (SI)||Clipboard (CL)|Menu & SendInput (MSI)|Menu & Clipboard (MCL)
    PostMessage, 0x153, -1, 22*DPI%v_SelectedMonitor%,, ahk_id %ddl%
	Gui, HS3:Font, % "s" . 12*DPI%v_SelectedMonitor% . " cBlue Bold"
    Gui, HS3:Add, Text,% "xm+" . 9*DPI%v_SelectedMonitor%, Enter hotstring
    Gui, HS3:Font, % "s" . 12*DPI%v_SelectedMonitor% . " cBlack Norm"
    Gui, HS3:Add, Edit, % "w" . 424*DPI%v_SelectedMonitor% . " h" . 25*DPI%v_SelectedMonitor% . " vv_EnterHotstring xm"
    Gui, HS3:Add, Edit, % "yp+" . 31*DPI%v_SelectedMonitor% . " w" . 424*DPI%v_SelectedMonitor% . " h" . 25*DPI%v_SelectedMonitor% . " vv_EnterHotstring1 xm Disabled"
    Gui, HS3:Add, Edit, % "yp+" . 31*DPI%v_SelectedMonitor% . " w" . 424*DPI%v_SelectedMonitor% . " h" . 25*DPI%v_SelectedMonitor% . " vv_EnterHotstring2 xm Disabled"
    Gui, HS3:Add, Edit, % "yp+" . 31*DPI%v_SelectedMonitor% . " w" . 424*DPI%v_SelectedMonitor% . " h" . 25*DPI%v_SelectedMonitor% . " vv_EnterHotstring3 xm Disabled"
    Gui, HS3:Add, Edit, % "yp+" . 31*DPI%v_SelectedMonitor% . " w" . 424*DPI%v_SelectedMonitor% . " h" . 25*DPI%v_SelectedMonitor% . " vv_EnterHotstring4 xm Disabled"
    Gui, HS3:Add, Edit, % "yp+" . 31*DPI%v_SelectedMonitor% . " w" . 424*DPI%v_SelectedMonitor% . " h" . 25*DPI%v_SelectedMonitor% . " vv_EnterHotstring5 xm Disabled"
    Gui, HS3:Add, Edit, % "yp+" . 31*DPI%v_SelectedMonitor% . " w" . 424*DPI%v_SelectedMonitor% . " h" . 25*DPI%v_SelectedMonitor% . " vv_EnterHotstring6 xm Disabled"
    Gui, HS3:Font, % "s" . 12*DPI%v_SelectedMonitor% . " cBlue Bold"
    Gui, HS3:Add, Text,% "xm+" . 9*DPI%v_SelectedMonitor%, Add a comment
    Gui, HS3:Font, % "s" . 12*DPI%v_SelectedMonitor% . " cBlack Norm"
	Gui, HS3:Add, Edit, % "w" . 424*DPI%v_SelectedMonitor% . " h" . 25*DPI%v_SelectedMonitor% . " limit64 vComment xm"
	Gui, HS3:Font, % "s" . 12*DPI%v_SelectedMonitor% . " cBlue Bold"
    Gui, HS3:Add, Text,% "xm+" . 9*DPI%v_SelectedMonitor%, Select hotstring library
	Gui, HS3:Add, Button, % "gAddLib x+" . 120*DPI%v_SelectedMonitor% . " yp w" . 135*DPI%v_SelectedMonitor% . " h" . 25*DPI%v_SelectedMonitor%, Add library
    Gui, HS3:Font, % "s" . 12*DPI%v_SelectedMonitor% . " cBlack Norm"
	Gui, HS3:Add, DropDownList, % "w" . 424*DPI%v_SelectedMonitor% . " vv_SelectHotstringLibrary gSectionChoose xm hwndddl" ,
    Loop,%A_ScriptDir%\Libraries\*.csv
        GuiControl, , v_SelectHotstringLibrary, %A_LoopFileName%
    PostMessage, 0x153, -1, 22*DPI%v_SelectedMonitor%,, ahk_id %ddl%
    Gui, HS3:Font, bold

    Gui, HS3:Add, Button, % "xm yp+" . 37*DPI%v_SelectedMonitor% . " w" . 135*DPI%v_SelectedMonitor% . " gAddHotstring", Set hotstring
	Gui, HS3:Add, Button, % "x+" . 10*DPI%v_SelectedMonitor% . " yp w" . 135*DPI%v_SelectedMonitor% . " gClear", Clear
	Gui, HS3:Add, Button, % "x+" . 10*DPI%v_SelectedMonitor% . " yp w" . 135*DPI%v_SelectedMonitor% . " vv_DeleteHotstring gDelete Disabled", Delete hotstring
	Gui, HS3:Font, % "s" . 12*DPI%v_SelectedMonitor% . " cBlue Bold"
    Gui, HS3:Add, Text,% "vSandString xm+" . 9*DPI%v_SelectedMonitor%, Sandbox
	Gui, HS3:Font, % "s" . 12*DPI%v_SelectedMonitor% . " cBlack Norm"
	Gui, HS3:Add, Edit, % "xm w" . 425*DPI%v_SelectedMonitor% . " vSandbox r5"
	IniRead, Sandbox, Config.ini, Configuration, Sandbox
	If (Sandbox == 0)
	{
		Gui, % "HS3:+MinSize"  . 1350*DPI%v_SelectedMonitor% . "x" . 640*DPI%v_SelectedMonitor%+20
		GuiControl, HS3:Hide, Sandbox
		GuiControl, HS3:Hide, SandString
	}
	else
	{
		Gui, % "HS3:+MinSize"  . 1350*DPI%v_SelectedMonitor% . "x" . 640*DPI%v_SelectedMonitor%+20  + 154*DPI%v_SelectedMonitor%
	}
	gui, HS3:Add, Text, x0 h1 0x7 w10 vLine
	Gui, HS3:Font, % "s" . 12*DPI%v_SelectedMonitor% . " cBlue Bold"
    Gui, HS3:Add, Text, ym, Library content
    Gui, HS3:Font, % "s" . 12*DPI%v_SelectedMonitor% . " cBlack Norm"
    Gui, HS3:Add, ListView, % "LV0x1 0x4 yp+" . 25*DPI%v_SelectedMonitor% . " xp h" . 500*DPI%v_SelectedMonitor% . " w" . 400*DPI%v_SelectedMonitor% . " vv_LibraryContent AltSubmit gHSLV", Triggerstring|Trigg Opt|Out Fun|En/Dis|Hotstring|Comment
	Gui, HS3:Add, Edit, vv_ViewString xs gViewString ReadOnly Hide,
	Gui, HS3:Font, % "s" . 12*DPI%v_SelectedMonitor% . " cBlack Norm"
	Gui, HS3:Add, Text, xm y0 vv_ShortcutsMainInterface,F1 About/Help | F2 Library content | F3 Search hotstrings | F5 Clear |F7 Clipboard Delay | F8 Delete hotstring | F9 Set hotstring 

    ; Menu, HSMenu, Add, &Monitor, CheckMon
	Menu, Submenu1, Add, &Undo last hotstring,Undo
	Menu, SubmenuTips, Add, Enable/Disable, Tips
	Menu, PositionMenu, Add, Caret, L_MenuCaretCursor
	Menu, PositionMenu, Add, Cursor, L_MenuCaretCursor
	Menu, SubmenuMenu, Add, Choose menu position,:PositionMenu
	Menu, SubmenuMenu, Add, Enable &sound if overrun, L_MenuSound
	if (ini_MenuSound)
		Menu, SubmenuMenu, Check, Enable &sound if overrun
	else
		Menu, SubmenuMenu, UnCheck, Enable &sound if overrun
	Menu, Submenu1, Add,% "Hotstring menu (MSI, MCL)", :SubmenuMenu
	if (ini_MenuCursor)
		Menu, PositionMenu, Check, Cursor
	else
		Menu, PositionMenu, UnCheck, Cursor
	if (ini_MenuCaret)
		Menu, PositionMenu, Check, Caret
	else
		Menu, PositionMenu, UnCheck, Caret
	Menu, Submenu1, Add, &Triggerstring tips, :SubmenuTips
	Menu, Submenu3, Add, Caret,L_CaretCursor
	Menu, Submenu3, Add, Cursor,L_CaretCursor
	if (ini_Cursor)
		Menu, Submenu3, Check, Cursor
	else
		Menu, Submenu3, UnCheck, Cursor
	if (ini_Caret)
		Menu, Submenu3, Check, Caret
	else
		Menu, Submenu3, UnCheck, Caret
	Menu, SubmenuTips, Add, Choose tips location, :Submenu3
	If !(ini_Tips)
	{
		Menu, SubmenuTips,Disable, Choose tips location
	}
	Menu, Submenu4, Add, 1, L_AmountOfCharacterTips1
	Menu, Submenu4, Add, 2, L_AmountOfCharacterTips2
	Menu, Submenu4, Add, 3, L_AmountOfCharacterTips3
	Menu, Submenu4, Add, 4, L_AmountOfCharacterTips4
	Menu, Submenu4, Add, 5, L_AmountOfCharacterTips5
	Menu, Submenu4, Check, % ini_AmountOfCharacterTips ; ms on 2020-10-31
	Loop, 5
	{
		if !(A_Index == ini_AmountOfCharacterTips)
			Menu, Submenu4, UnCheck, %A_Index%
	}
	Menu, SubmenuTips, Add, &Number of characters for tips, :Submenu4
	If !(ini_Tips)
	{
		Menu, SubmenuTips,Disable, &Number of characters for tips
	}
	Menu, Submenu1, Add, &Save window position,SavePos
	Menu, Submenu1, Add, &Launch Sandbox, Sandbox
	Menu, Submenu2, Add, Space, EndSpace
	if (EndingChar_Space)
		Menu, Submenu2, Check, Space
	else
		Menu, Submenu2, UnCheck, Space
	Menu, Submenu2, Add, Minus -, EndMinus
	if (EndingChar_Minus)
		Menu, Submenu2, Check, Minus -
	else
		Menu, Submenu2, UnCheck, Minus -
	Menu, Submenu2, Add, Opening Round Bracket (, EndORoundBracket
	if (EndingChar_ORoundBracket)
		Menu, Submenu2, Check, Opening Round Bracket (
	else
		Menu, Submenu2, UnCheck, Opening Round Bracket (
	Menu, Submenu2, Add, Closing Round Bracket ), EndCRoundBracket
	if (EndingChar_CRoundBracket)
		Menu, Submenu2, Check, Closing Round Bracket )
	else
		Menu, Submenu2, UnCheck, Closing Round Bracket )
	Menu, Submenu2, Add, Opening Square Bracket [, EndOSquareBracket
	if (EndingChar_OSquareBracket)
		Menu, Submenu2, Check, Opening Square Bracket [
	else
		Menu, Submenu2, UnCheck, Opening Square Bracket [
	Menu, Submenu2, Add, Closing Square Bracket ], EndCSquareBracket
	if (EndingChar_CSquareBracket)
		Menu, Submenu2, Check, Closing Square Bracket ]
	else
		Menu, Submenu2, UnCheck, Closing Square Bracket ]
	Menu, Submenu2, Add, Opening Curly Bracket {, EndOCurlyBracket
	if (EndingChar_OCurlyBracket)
		Menu, Submenu2, Check, Opening Curly Bracket {
	else
		Menu, Submenu2, UnCheck, Opening Curly Bracket {
	Menu, Submenu2, Add, Closing Curly Bracket }, EndCCurlyBracket
	if (EndingChar_CCurlyBracket)
		Menu, Submenu2, Check, Closing Curly Bracket }
	else
		Menu, Submenu2, UnCheck, Closing Curly Bracket }
	Menu, Submenu2, Add, Colon :, EndColon
	if (EndingChar_Colon)
		Menu, Submenu2, Check, Colon :
	else
		Menu, Submenu2, UnCheck, Colon :
	Menu, Submenu2, Add, % "Semicolon `;", EndSemicolon
	if (EndingChar_Semicolon)
		Menu, Submenu2, Check, % "Semicolon `;"
	else
		Menu, Submenu2, UnCheck, % "Semicolon `;"
	Menu, Submenu2, Add, Apostrophe ', EndApostrophe
	if (EndingChar_Apostrophe)
		Menu, Submenu2, Check, Apostrophe '
	else
		Menu, Submenu2, UnCheck, Apostrophe '
	Menu, Submenu2, Add, % "Quote """, EndQuote
	if (EndingChar_Quote)
		Menu, Submenu2, Check, % "Quote """
	else
		Menu, Submenu2, UnCheck, % "Quote """
	Menu, Submenu2, Add, Slash /, EndSlash
	if (EndingChar_Slash)
		Menu, Submenu2, Check, Slash /
	else
		Menu, Submenu2, UnCheck, Slash /
	Menu, Submenu2, Add, Backslash \, EndBackslash
	if (EndingChar_Backslash)
		Menu, Submenu2, Check, Backslash \
	else
		Menu, Submenu2, UnCheck, Backslash \
	Menu, Submenu2, Add, % "Comma ,", EndComma
	if (EndingChar_Comma)
		Menu, Submenu2, Check, % "Comma ,"
	else
		Menu, Submenu2, UnCheck, % "Comma ,"
	Menu, Submenu2, Add, Dot ., EndDot
	if (EndingChar_Dot)
		Menu, Submenu2, Check, Dot .
	else
		Menu, Submenu2, UnCheck, Dot .
	Menu, Submenu2, Add, Question Mark ?, EndQuestionMark
	if (EndingChar_QuestionMark)
		Menu, Submenu2, Check, Question Mark ?
	else
		Menu, Submenu2, UnCheck, Question Mark ?
	Menu, Submenu2, Add, Exclamation Mark !, EndExclamationMark
	if (EndingChar_ExclamationMark)
		Menu, Submenu2, Check, Exclamation Mark !
	else
		Menu, Submenu2, UnCheck, Exclamation Mark !
	Menu, Submenu2, Add, Enter , EndEnter
	if (EndingChar_Enter)
		Menu, Submenu2, Check, Enter
	else
		Menu, Submenu2, UnCheck, Enter
	Menu, Submenu2, Add, Tab , EndTab
	if (EndingChar_Tab)
		Menu, Submenu2, Check, Tab
	else
		Menu, Submenu2, UnCheck, Tab
	Menu, Submenu1, Add, &Toggle EndChars, :Submenu2
	IniRead, ini_Tips, Config.ini, Configuration, Tips
	if (ini_Tips == 0)
		Menu, SubmenuTips, UnCheck, Enable/Disable
	else
		Menu, SubmenuTips, Check, Enable/Disable
	IniRead, Sandbox, Config.ini, Configuration, Sandbox
	if (Sandbox == 0)
		Menu, Submenu1, UnCheck, &Launch Sandbox
	else
		Menu, Submenu1, Check, &Launch Sandbox
	IniRead, Undo, Config.ini, Configuration, UndoHotstring
	if (Undo == 0)
		Menu, Submenu1, UnCheck, &Undo last hotstring
	else
		Menu, Submenu1, Check, &Undo last hotstring
	Menu, HSMenu, Add, &Configure, :Submenu1
	Menu, HSMenu, Add, &Search Hotstrings, L_Searching
    Menu, HSMenu, Add, Clipboard &Delay, HSdelay
	Menu, HSMenu, Add, &About/Help, About
    Gui, HS3:Menu, HSMenu
	IniRead, StartX, Config.ini, Configuration, SizeOfHotstringsWindow_X, #
	IniRead, StartY, Config.ini, Configuration, SizeOfHotstringsWindow_Y, #
	IniRead, StartW, Config.ini, Configuration, SizeOfHotstringsWindow_Width, #
	IniRead, StartH, Config.ini, Configuration, SizeOfHotstringsWindow_Height, #
	v_FlagMax := 0
	if (StartW == "") or (StartH == "")
	{
		v_FlagMax := 1
	}
	if (StartX == "")
		StartX := Mon%v_SelectedMonitor%Left + (Abs(Mon%v_SelectedMonitor%Right - Mon%v_SelectedMonitor%Left)/2) - 430*DPI%v_SelectedMonitor%
	if (StartY == "")
		StartY := Mon%v_SelectedMonitor%Top + (Abs(Mon%v_SelectedMonitor%Bottom - Mon%v_SelectedMonitor%Top)/2) - (225*DPI%v_SelectedMonitor%+31)
	if (StartW == "")
		StartW := 1350*DPI%v_SelectedMonitor%
	if (StartH == "")
		if (Sandbox)
			StartH := 640*DPI%v_SelectedMonitor%+20 + 154*DPI%v_SelectedMonitor%
		else
			StartH := 640*DPI%v_SelectedMonitor%+20
	if (Sandbox) and (StartH <640*DPI%v_SelectedMonitor%+20 + 154*DPI%v_SelectedMonitor%)
		StartH := 640*DPI%v_SelectedMonitor%+20 + 154*DPI%v_SelectedMonitor%
	Gui, HS3:Hide
	if (v_ShowGui == 1)
	{
		if (v_FlagMax)
		{
			Gui, HS3:Show, x%StartX% y%StartY% w%StartW% h%StartH% Hide, Hotstrings
			Gui, HS3:Show, Maximize, Hotstrings
		}
		else
			Gui, HS3:Show, x%StartX% y%StartY% w%StartW% h%StartH%, Hotstrings
	}
	else if (v_ShowGui == 2)
	{
		if (Sandbox) and (v_PreviousHeight <640*DPI%v_SelectedMonitor%+20 + 154*DPI%v_SelectedMonitor%)
			v_PreviousHeight := 640*DPI%v_SelectedMonitor%+20 + 154*DPI%v_SelectedMonitor%
		Gui, HS3:Show, W%v_PreviousWidth% H%v_PreviousHeight% X%v_PreviousX% Y%v_PreviousY%, Hotstrings
	}
	else if (v_ShowGui == 3)
	{
		if (v_FlagMax)
		{
			Gui, HS3:Show, x%StartX% y%StartY% w%StartW% h%StartH% Hide, Hotstrings
			Gui, HS3:Show, Maximize, Hotstrings
		}
		else
			Gui, HS3:Show, x%StartX% y%StartY% w%StartW% h%StartH%, Hotstrings
	}
	if (v_PreviousSection != "")
	{
		GuiControl, Choose, v_SelectHotstringLibrary, %v_PreviousSection%
		gosub SectionChoose
		if(A_Args[8] > 0)
		{
			LV_Modify(v_SelectedRow, "Vis")
			LV_Modify(v_SelectedRow, "+Select +Focus")
			GuiControl, Focus, v_LibraryContent
		}
	}
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

AddHotstring:
	Gui, HS3:+OwnDialogs
	Gui, Submit, NoHide
	GuiControlGet, v_SelectFunction
	If (Trim(v_TriggerString) ="")
	{
		MsgBox Enter a Hotstring!
		return
	}
	if InStr(v_SelectFunction,"Menu")
	{
		If ((Trim(v_EnterHotstring) ="") and (Trim(v_EnterHotstring1) ="") and (Trim(v_EnterHotstring2) ="") and (Trim(v_EnterHotstring3) ="") and (Trim(v_EnterHotstring4) ="") and (Trim(v_EnterHotstring5) ="") and (Trim(v_EnterHotstring6) =""))
		{
			MsgBox, 4,, Replacement text is blank. Do you want to proceed?
			IfMsgBox, No
			return
		}
		TextVar := ""
		If (Trim(v_EnterHotstring) !="")
			TextVar := % TextVar . "¦" . v_EnterHotstring
		If (Trim(v_EnterHotstring1) !="")
			TextVar := % TextVar . "¦" . v_EnterHotstring1
		If (Trim(v_EnterHotstring2) !="")
			TextVar := % TextVar . "¦" . v_EnterHotstring2
		If (Trim(v_EnterHotstring3) !="")
			TextVar := % TextVar . "¦" . v_EnterHotstring3
		If (Trim(v_EnterHotstring4) !="")
			TextVar := % TextVar . "¦" . v_EnterHotstring4
		If (Trim(v_EnterHotstring5) !="")
			TextVar := % TextVar . "¦" . v_EnterHotstring5
		If (Trim(v_EnterHotstring6) !="")
			TextVar := % TextVar . "¦" . v_EnterHotstring6
		TextInsert := SubStr(TextVar, 2, StrLen(TextVar)-1)
	}
	else{
		If (Trim(v_EnterHotstring) ="")
		{
			MsgBox, 4,, Replacement text is blank. Do you want to proceed?
			IfMsgBox, No
			Return
		}
		else
		{
			TextInsert := v_EnterHotstring
		}
	}
	if (v_SelectFunction == "")
	{
		MsgBox,0x30 ,, Choose sending function!
		return
	}
	if (v_SelectHotstringLibrary == "")
	{
		MsgBox, Choose section before saving!
		return
	}
	
	OldOptions := ""

	GuiControlGet, v_ViewString
	Select := v_ViewString
	Loop, Parse, v_ViewString, `n
	{  
		if InStr(A_LoopField, ":" . v_TriggerString . """", v_OptionCaseSensitive)
		{
			a_String := StrSplit(A_LoopField, ":",,3)
			OldOptions := a_String[2]
			GuiControl,, v_ViewString, ""
			break
		}
	}
	
; Added this conditional to prevent Hotstrings from a file losing the C1 option caused by
; cascading ternary operators when creating the options string. CapCheck set to 1 when 
; a Hotstring from a file contains the C1 option.

	If (v_CaseSensitiveC1 = 1) and ((OldOptions = "") or (InStr(OldOptions,"C1"))) and (Instr(a_String[2],"C1"))
		OldOptions := StrReplace(OldOptions,"C1") . "C"
	v_CaseSensitiveC1 := 0

	GoSub OptionString   ; Writes the Hotstring options string

; Add new/changed target item in DropDownList
	if (v_SelectFunction == "Clipboard (CL)")
		SendFun := "F_ViaClipboard"
	else if (v_SelectFunction == "SendInput (SI)")
		SendFun := "F_NormalWay"
	else if (v_SelectFunction == "Menu & Clipboard (MCL)")
		SendFun := "F_MenuText"
	else if (v_SelectFunction == "Menu & SendInput (MSI)")
		SendFun := "F_MenuTextAHK"
	else 
	{
		MsgBox, Choose the method of sending the hotstring!
		return
	}

	if (v_OptionDisable == 1)
		OnOff := "Off"
	else
		OnOff := "On"
		GuiControl,, v_ViewString , % "Hotstring("":" . Options . ":" . v_TriggerString . """, func(""" . SendFun . """).bind(""" . TextInsert . """), """ . OnOff . """)"

; Select target item in list
	gosub, ViewString

; If case sensitive (C) or inside a word (?) first deactivate Hotstring
	If (v_OptionCaseSensitive or v_OptionInsideWord or InStr(OldOptions,"C") 
		or InStr(OldOptions,"?")) 
		Hotstring(":" . OldOptions . ":" . v_TriggerString , func(SendFun).bind(TextInsert), "Off")

; Create Hotstring and activate
	Hotstring(":" . Options . ":" . v_TriggerString, func(SendFun).bind(TextInsert), OnOff)
	gosub, SaveHotstrings
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Clear:
	GuiControl,, v_ViewString,
	GuiControl,, Comment,
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
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

HSLV:
	Gui, HS3:+OwnDialogs
	v_PreviousSelectedRow := v_SelectedRow
	If !(v_SelectedRow := LV_GetNext()) {
		Return
	}
	if (v_PreviousSelectedRow == v_SelectedRow) and !(v_TriggerString == "")
	{
		return
	}
	LV_GetText(Options, v_SelectedRow, 2)
	LV_GetText(v_TriggerString, v_SelectedRow, 1)
	LV_GetText(Fun, v_SelectedRow, 3)
	if (Fun = "SI")
	{
		SendFun := "F_NormalWay"
	}
	else if (Fun = "CL")
	{
		SendFun := "F_ViaClipboard"
	}
	else if (Fun = "MSI")
	{
		SendFun := "F_MenuText"
	}
	else if (Fun = "MCL")
	{
		SendFun := "F_MenuTextAHK"
	}
	else
	{
		SendFun := "F_NormalWay"
	}
	LV_GetText(TextInsert, v_SelectedRow, 5)
	LV_GetText(Comment, v_SelectedRow, 6)
	LV_GetText(EnDis, v_SelectedRow, 4)
	If (EnDis == "En")
		OnOff := "On"
	else if (EnDis == "Dis")
		OnOff := "Off"
	v_String := % "Hotstring("":" . Options . ":" . v_TriggerString . """, func(""" . SendFun . """).bind(""" . TextInsert . """), """ . OnOff . """)"
	GuiControl,, Comment, %Comment%
	GuiControl,, v_ViewString ,  %v_String%
	gosub, ViewString
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
	else if(Fun = "CL")
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
	v_String := % "Hotstring("":" . Options . ":" . v_TriggerString . """, func(""" . SendFun . """).bind(""" . TextInsert . """), """ . OnOff . """)"
	GuiControl,, v_ViewString ,  %v_String%
	gosub, ViewString
	GuiControl, Choose, v_SelectHotstringLibrary, %ChooseSec%
	gosub, SectionChoose
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
	Gui, ALib:Add, Text,,Enter a name for the new library
	Gui, ALib:Add, Edit, % "vNewLib w" . 150*DPI%v_SelectedMonitor%,
	Gui, ALib:Add, Text, % "x+" . 10*DPI%v_SelectedMonitor%, .csv
	Gui, ALib:Add, Button, % "Default gALibOK xm w" . 70*DPI%v_SelectedMonitor%, OK
	Gui, ALib:Add, Button, % "gALibGuiClose x+" . 10*DPI%v_SelectedMonitor% . " w" . 70*DPI%v_SelectedMonitor%, Cancel
	WinGetPos, v_PreviousX, v_PreviousY , , ,Hotstrings
	Gui, ALib:Show, % "x" . ((v_PreviousX+v_PreviousWidth)/2)/DPI%v_SelectedMonitor% . " y" . ((v_PreviousY+v_PreviousHeight)/2)/DPI%v_SelectedMonitor%
return

ALibOK:
	Gui,ALib:Submit, NoHide
	if (NewLib == "")
	{
		MsgBox, Enter a name for the new library!
		return
	}
	NewLib .= ".csv"
	IfNotExist, Libraries
		FileCreateDir, Libraries
	IfNotExist, Libraries\%NewLib%
	{
		FileAppend,, Libraries\%NewLib%, UTF-8
		MsgBox, The library %NewLib% has been created.
		Gui, ALib:Destroy
		GuiControl, HS3:, v_SelectHotstringLibrary, |
		Loop,%A_ScriptDir%\Libraries\*.csv
        	GuiControl,HS3: , v_SelectHotstringLibrary, %A_LoopFileName%
	}
	Else
		MsgBox, A library with that name already exists!
return

ALibGuiEscape:
ALibGuiClose:
	Gui, ALib:Destroy
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

SectionChoose:
	Gui, HS3:Submit, NoHide
	Gui, HS3:+OwnDialogs

	GuiControl, Enable, Delete
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
			LV_ModifyCol(1, "Sort")
		}
return

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
	GuiControl, , v_EnterHotstring1,
	GuiControl, , v_EnterHotstring2,
	GuiControl, , v_EnterHotstring3,
	GuiControl, , v_EnterHotstring4,
	GuiControl, , v_EnterHotstring5,
	GuiControl, , v_EnterHotstring6,
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

SetOptions:
	OptionSet := Instr(Hotstring2[2],"*0") or InStr(Hotstring2[2],"*") = 0 ? F_CheckOption("No",2) :  F_CheckOption("Yes",2)
	OptionSet := ((Instr(Hotstring2[2],"C0")) or (Instr(Hotstring2[2],"C1")) or (Instr(Hotstring2[2],"C") = 0)) ? F_CheckOption("No",3) : F_CheckOption("Yes",3)
	OptionSet := Instr(Hotstring2[2],"B0") ? F_CheckOption("Yes",4) : F_CheckOption("No",4)
	OptionSet := Instr(Hotstring2[2],"?") ? F_CheckOption("Yes",5) : F_CheckOption("No",5)
	OptionSet := (Instr(Hotstring2[2],"O0") or (InStr(Hotstring2[2],"O") = 0)) ? F_CheckOption("No",6) : F_CheckOption("Yes",6)
	GuiControlGet, v_ViewString
	Select := v_ViewString
	if Select = 
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

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

OptionString:
	Options := ""

	Options := v_OptionCaseSensitive = 1 ? Options . "C"
		: (Instr(OldOptions,"C1")) ?  Options . "C0"
		: (Instr(OldOptions,"C0")) ?  Options
		: (Instr(OldOptions,"C")) ? Options . "C1" : Options

	Options := v_OptionNoBackspace = 1 ?  Options . "B0" 
		: (v_OptionNoBackspace = 0) and (Instr(OldOptions,"B0"))
		? Options . "B" : Options

	Options := (v_OptionImmediateExecute = 1) ?  Options . "*" 
		: (Instr(OldOptions,"*0")) ?  Options
		: (Instr(OldOptions,"*")) ? Options . "*0" : Options

	Options := v_OptionInsideWord = 1 ?  Options . "?" : Options

	Options := (v_OptionNoEndChar = 1) ?  Options . "O"
		: (Instr(OldOptions,"O0")) ?  Options
		: (Instr(OldOptions,"O")) ? Options . "O0" : Options

	a_String[2] := Options
Return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

SaveHotstrings:
	Gui, HS3:+OwnDialogs
	SaveFile := v_SelectHotstringLibrary
	SaveFile := StrReplace(SaveFile, ".csv", "")
	GuiControlGet, Items,, v_ViewString
	EnDis := ""
	SendFun := ""
	if InStr(Items, """On""")
		EnDis := "En"
	else if InStr(Items, """Off""")
		EnDis := "Dis"
	if InStr(Items, "F_ViaClipboard")
		SendFun := "CL"
	else if InStr(Items, "F_NormalWay")
		SendFun := "SI"
	else if InStr(Items, """F_MenuText""")
		SendFun := "MCL"
	else if InStr(Items, """F_MenuTextAHK""")
		SendFun := "MSI"
	HSSplit := StrSplit(Items, ":")
	HSSplit2 := StrSplit(Items, """:")
	Options := SubStr(HSSplit2[2], 1 , InStr(HSSplit2[2], ":" )-1)
	v_TriggerString := SubStr(HSSplit2[2], InStr(HSSplit2[2], ":" )+1 , InStr(HSSplit2[2], """," )-StrLen(Options)-2)
	if (InStr(Options, "*0"))
	{
		Options := StrReplace(Options, "*0")
	}
	if (InStr(Options, "O0"))
	{
		Options := StrReplace(Options, "O0")
	}
	if (InStr(Options, "C0"))
	{
		Options := StrReplace(Options, "C0")
	}
	if (InStr(Options, "?0"))
	{
		Options := StrReplace(Options, "?0")
	}
	if (InStr(Options, "B")) and !(InStr(Options, "B0"))
	{
		Options := StrReplace(Options, "B")
	}
	StrSp := StrSplit(Items, "bind(""")
	StrSp1 := StrSplit(StrSp[2], """),")
	TextInsert := StrSp1[1]
	OutputFile =% A_ScriptDir . "\Libraries\temp.csv"
	InputFile = % A_ScriptDir . "\Libraries\" . SaveFile . ".csv"
	LString := % "‖" . v_TriggerString . "‖"
	SaveFlag := 0
	Loop, Read, %InputFile%, %OutputFile%
	{
		if InStr(A_LoopReadLine, LString)
		{
			if !(v_SelectedRow)
			{
				MsgBox, 4,, The hostring "%v_TriggerString%" exists in a file %SaveFile%.csv. Do you want to proceed?
				IfMsgBox, No
					return
			}
			LV_Modify(A_Index, "", v_TriggerString, Options, SendFun, EnDis, TextInsert, Comment)
			SaveFlag := 1
		}
	}
	if (SaveFlag == 0)
	{
		LV_Add("",  v_TriggerString,Options, SendFun, EnDis, TextInsert, Comment)
		txt := % Options . "‖" . v_TriggerString . "‖" . SendFun . "‖" . EnDis . "‖" . TextInsert . "‖" . Comment
		SectionList.Push(txt)
	}
	LV_ModifyCol(1, "Sort")
	name := SubStr(v_SelectHotstringLibrary, 1, StrLen(v_SelectHotstringLibrary)-4)
	name := % name . ".csv"
	FileDelete, Libraries\%name%
	if (SectionList.MaxIndex() == "")
	{
		LV_GetText(txt1, 1, 2)
		LV_GetText(txt2, 1, 1)
		LV_GetText(txt3, 1, 3)
		LV_GetText(txt4, 1, 4)
		LV_GetText(txt5, 1, 5)
		LV_GetText(txt6, 1, 6)
		txt := % txt1 . "‖" . txt2 . "‖" . txt3 . "‖" . txt4 . "‖" . txt5 . "‖" . txt6
		FileAppend, %txt%, Libraries\%name%, UTF-8
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
				FileAppend, %txt%, Libraries\%name%, UTF-8
		}
		LV_GetText(txt1, SectionList.MaxIndex(),2)
		LV_GetText(txt2, SectionList.MaxIndex(),1)
		LV_GetText(txt3, SectionList.MaxIndex(),3)
		LV_GetText(txt4, SectionList.MaxIndex(),4)
		LV_GetText(txt5, SectionList.MaxIndex(),5)
		LV_GetText(txt6, SectionList.MaxIndex(),6)
		txt := % txt1 . "‖" . txt2 . "‖" . txt3 . "‖" . txt4 . "‖" . txt5 . "‖" . txt6
		FileAppend, %txt%, Libraries\%name%, UTF-8
	}
	MsgBox Hotstring added to the %SaveFile%.csv file!
	F_LoadFiles(name)	
Return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Delete:
	Gui, HS3:+OwnDialogs
	
	If !(v_SelectedRow := LV_GetNext()) {
		MsgBox, 0, %A_ThisLabel%, Select a row in the list-view, please!
		Return
	}
	Msgbox, 0x4,, Selected Hotstring will be deleted. Do you want to proceed?
	IfMsgBox, No
		return
	name := v_SelectHotstringLibrary
	FileDelete, Libraries\%name%
	if (v_SelectedRow == SectionList.MaxIndex())
	{
		if (SectionList.MaxIndex() == 1)
		{
			FileAppend,, Libraries\%name%, UTF-8
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
						FileAppend, %txt%, Libraries\%name%, UTF-8
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
					FileAppend, %txt%, Libraries\%name%, UTF-8
			}
		}
	}
	MsgBox, Hotstring has been deleted. Now application will restart itself in order to apply changes, reload the libraries (.csv)
	WinGetPos, v_PreviousX, v_PreviousY , , ,Hotstrings
	Run, AutoHotkey.exe Hotstrings.ahk v_Param L_GUIInit %v_SelectHotstringLibrary% %v_PreviousWidth% %v_PreviousHeight% %v_PreviousX% %v_PreviousY% %v_SelectedRow% %v_SelectedMonitor%
return
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; SaveMon:
	; v_MonitorFlag := 0
	; if (v_PreviousMonitor != v_SelectedMonitor)
		; v_ShowGui := 3
	; gosub, L_GUIInit
; return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; CheckMon:
    ; Gui, Mon:Submit, NoHide
    ; Gui, Mon:Destroy
    ; Gui, Mon:New, +AlwaysOnTop
	; if (v_MonitorFlag != 1)
	; {
		; v_PreviousMonitor := v_SelectedMonitor
		; v_MonitorFlag := 1
	; }
    ; SysGet, N, MonitorCount
    ; SysGet, PrimMon, MonitorPrimary
    ; if (v_SelectedMonitor == 0)
        ; v_SelectedMonitor := PrimMon
    ; MFS := 10*DPI%v_SelectedMonitor%
    ; Gui, Mon:Margin, 12.5*DPI%v_SelectedMonitor%, 7.5*DPI%v_SelectedMonitor%
    ; Gui, Mon:Font, s%MFS%
    ; Gui, Mon:Add, Text, % " w" . 500*DPI%v_SelectedMonitor%, Choose a monitor where GUI will be located:
    ; Loop, % N
    ; {
        ; if (A_Index == v_SelectedMonitor)
        ; {
            ; Gui, Mon:Add, Radio,%  "xm+" . 50*DPI%v_SelectedMonitor% . " h" . 25*DPI%v_SelectedMonitor% . " gCheckMon AltSubmit vv_SelectedMonitor Checked", % "Monitor #" . A_Index . (A_Index = PrimMon ? " (primary)" : "")
        ; }
        ; else
        ; {
            ; Gui, Mon:Add, Radio, % "xm+" . 50*DPI%v_SelectedMonitor% . " h" . 25*DPI%v_SelectedMonitor% . " gCheckMon AltSubmit", % "Monitor #" . A_Index . (A_Index = PrimMon ? " (primary)" : "")
        ; }
    ; }
    ; Gui, Mon:Add, Button, % "Default xm+" . 30*DPI%v_SelectedMonitor% . " y+" . 15*DPI%v_SelectedMonitor% . " h" . 30*DPI%v_SelectedMonitor% . " gCheckMonitorNumbering", &Check Monitor Numbering
    ; Gui, Mon:Add, Button, % "x+" . 30*DPI%v_SelectedMonitor% . " h" . 30*DPI%v_SelectedMonitor% . " yp gSaveMon", &Save
    ; SysGet, MonitorBoundingCoordinates_, Monitor, % v_SelectedMonitor
    ; Gui, Mon: Show
        ; , % "x" . MonitorBoundingCoordinates_Left + (Abs(MonitorBoundingCoordinates_Left - MonitorBoundingCoordinates_Right) / 2) - 200*DPI%v_SelectedMonitor%
        ; . "y" . MonitorBoundingCoordinates_Top + (Abs(MonitorBoundingCoordinates_Top - MonitorBoundingCoordinates_Bottom) / 2) - 80*DPI%v_SelectedMonitor%
        ; . "w" . 400*DPI%v_SelectedMonitor% . "h" . 150*DPI%v_SelectedMonitor%, Configure Monitor
; return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; CheckMonitorNumbering:
    ; F_ShowMonitorNumbers()
    ; SetTimer, DestroyGuis, -3000
; return

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
        GuiControl,,DelayText, Hotstring paste from Clipboard delay 1 s
    else
        GuiControl,,DelayText, Hotstring paste from Clipboard delay %ini_Delay% ms
	IniWrite, %ini_Delay%, Config.ini, Configuration, Delay
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

About:
	Gui, MyAbout: Destroy
	Gui, MyAbout: Font, % "bold s" . 11*DPI%v_SelectedMonitor%
    Gui, MyAbout: Add, Text, , Let's make your PC personal again... 
	Gui, MyAbout: Font, % "norm s" . 11*DPI%v_SelectedMonitor%
	Gui, MyAbout: Add, Text, ,Enables convenient definition and use of hotstrings (triggered by shortcuts longer text strings). `nThis is 3rd edition of this application, 2020 by Jakub Masiak and Maciej Słojewski (🐘). `nLicense: GNU GPL ver. 3.
   	Gui, MyAbout: Font, % "CBlue bold Underline s" . 12*DPI%v_SelectedMonitor%
    Gui, MyAbout: Add, Text, gLink, Application help
	Gui, MyAbout: Add, Text, gLink2, Genuine hotstrings AutoHotkey documentation
	Gui, MyAbout: Font, % "norm s" . 11*DPI%v_SelectedMonitor%
	Gui, MyAbout: Add, Button, % "Default Hidden w" . 100*DPI%v_SelectedMonitor% . " gMyOK vOkButtonVariabl hwndOkButtonHandle", &OK
    GuiControlGet, MyGuiControlGetVariable, MyAbout: Pos, %OkButtonHandle%
	WinGetPos, v_WindowX, v_WindowY ,v_WindowWidth,v_WindowHeight,Hotstrings
	Gui, MyAbout:Show,% "hide w" . 670*DPI%v_SelectedMonitor% . "h" . 220*DPI%v_SelectedMonitor%, About/Help
	DetectHiddenWindows, On
	WinGetPos, , , MyAboutWindowWidth, MyAboutWindowHeight,About/Help
	DetectHiddenWindows, Off
    NewButtonXPosition := round((( MyAboutWindowWidth- 100*DPI%v_SelectedMonitor%)/2)*DPI%v_SelectedMonitor%)
    GuiControl, Move, %OkButtonHandle%, x%NewButtonXPosition%
    GuiControl, Show, %OkButtonHandle%
	Gui, MyAbout:Show,% "x" . v_WindowX + (v_WindowWidth - MyAboutWindowWidth)/2 . " y" . v_WindowY + (v_WindowHeight - MyAboutWindowHeight)/2 ,About/Help
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
MyAboutGuiClose: ; Launched when the window is closed by pressing its X button in the title bar
    Gui, MyAbout: Destroy
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

HS3GuiSize:
	if (ErrorLevel == 1)
		return
	if (ErrorLevel == 0)
		v_ShowGui := 2
	IniW := StartW
	IniH := StartH
	LV_Width := IniW - 460*DPI%v_SelectedMonitor%
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
	NewWidth := LV_Width+(A_GuiWidth-IniW)
	ColWid := (NewWidth-620*DPI%v_SelectedMonitor%)
	LV_ModifyCol(5, "Auto")
	SendMessage, 4125, 4, 0, SysListView321
	wid := ErrorLevel
	if (wid < ColWid)
	{
		LV_ModifyCol(5, ColWid)
	}
	GuiControl, Move, v_LibraryContent, W%NewWidth% H%NewHeight%
	GuiControl, Move, v_ShortcutsMainInterface, % "y" . v_PreviousHeight - 22*DPI%v_SelectedMonitor%
	GuiControl, Move, Line, % "w" . A_GuiWidth . " y" . v_PreviousHeight - 26*DPI%v_SelectedMonitor%
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

HS3GuiEscape:
HS3GuiClose:
	WinGetPos, v_PreviousX, v_PreviousY , , ,Hotstrings
	Gui, HS3:Destroy
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

L_Searching:
WinGetPos, StartXlist, StartYlist,,,Hotstrings
Gui, SearchLoad:New, -Resize -Border
Gui, SearchLoad:Add, Text,, Please wait, uploading .csv files...
Gui, SearchLoad:Show
SysGet, N, MonitorCount
    Loop, % N
    {
        SysGet, Mon%A_Index%, Monitor, %A_Index%
        W%A_Index% := Mon%A_Index%Right - Mon%A_Index%Left
        H%A_Index% := Mon%A_Index%Bottom - Mon%A_Index%Top
        DPI%A_Index% := round(W%A_Index%/1920*(96/A_ScreenDPI),2)
    }
    SysGet, PrimMon, MonitorPrimary
    if (v_SelectedMonitor == 0)
        v_SelectedMonitor := PrimMon
If (WinExist("Search Hotstring"))
{
	Gui, HS3List:Destroy
}
	a_Hotstring := []
	a_Library := []
	a_Triggerstring := []
	a_EnableDisable := []
	a_TriggerOptions := []
	a_OutputFunction := []
	a_Comment := []


Gui, HS3List:New,% "+Resize MinSize" . 940*DPI%v_SelectedMonitor% . "x" . 500*DPI%v_SelectedMonitor%
Gui, HS3List:Add, Text, ,Search:
Gui, HS3List:Add, Text, % "yp xm+" . 420*DPI%v_SelectedMonitor%, Search by:
Gui, HS3List:Add, Edit, % "xm w" . 400*DPI%v_SelectedMonitor% . " vv_SearchTerm gSearch"
Gui, HS3List:Add, Radio, % "yp xm+" . 420*DPI%v_SelectedMonitor% . " vv_RadioGroup gSearchChange Checked", Triggerstring
Gui, HS3List:Add, Radio, % "yp xm+" . 540*DPI%v_SelectedMonitor% . " gSearchChange", Hotstring
Gui, HS3List:Add, Radio, % "yp xm+" . 640*DPI%v_SelectedMonitor% . " gSearchChange", Library
Gui, HS3List:Add, Button, % "yp-2 xm+" . 720*DPI%v_SelectedMonitor% . " w" . 100*DPI%v_SelectedMonitor% . " gMoveList", Move
Gui, HS3List:Add, ListView, % "xm grid vList +AltSubmit gHSLV2 h" . 400*DPI%v_SelectedMonitor%, Library|Triggerstring|Trigger Options|Output Function|Enable/Disable|Hotstring|Comment
Loop, Files, %A_ScriptDir%\Libraries\*.csv
{
    Loop
    {
        FileReadLine, varSearch, %A_LoopFileFullPath%, %A_Index%
        if ErrorLevel
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
        name := SubStr(A_LoopFileName,1, StrLen(A_LoopFileName)-4)
        LV_Add("", name, tabSearch[2],tabSearch[1],tabSearch[3],tabSearch[4],tabSearch[5], tabSearch[6])
		a_Library.Push(name)
        a_Hotstring.Push(tabSearch[2])
		a_TriggerOptions.Push(tabSearch[1])
		a_OutputFunction.Push(tabSearch[3])
        a_EnableDisable.Push(tabSearch[4])
		a_Comment.Push(tabSearch[6])
        a_Triggerstring.Push(tabSearch[5])
    }
}
LV_ModifyCol(1, "Sort")
StartWlist := 940*DPI%v_SelectedMonitor%
StartHlist := 500*DPI%v_SelectedMonitor%
SetTitleMatchMode, 3
WinGetPos, StartXlist, StartYlist,,,Hotstrings
if ((StartXlist == "") or (StartYlist == ""))
{
	StartXlist := (Mon%v_SelectedMonitor%Left + (Abs(Mon%v_SelectedMonitor%Right - Mon%v_SelectedMonitor%Left)/2))*DPI%v_SelectedMonitor% - StartWlist/2
	StartYlist := (Mon%v_SelectedMonitor%Top + (Abs(Mon%v_SelectedMonitor%Bottom - Mon%v_SelectedMonitor%Top)/2))*DPI%v_SelectedMonitor% - StartHlist/2
}
gui, HS3List:Add, Text, x0 h1 0x7 w10 vLine2
Gui, HS3List:Font, % "s" . 10*DPI%v_SelectedMonitor% . " cBlack Norm"
Gui, HS3List:Add, Text, xm vShortcuts2, F3 Close Search hotstrings | F8 Move hotstring
if !(v_SearchTerm == "")
	GuiControl,,v_SearchTerm,%v_SearchTerm%
if (v_RadioGroup == 1)
	GuiControl,, Triggerstring, 1
else if (v_RadioGroup == 2)
	GuiControl,, Hotstring, 1
else if (v_RadioGroup == 3)
	GuiControl,, Library, 1
Gui, HS3List:Show, % "w" . StartWlist . " h" . StartHlist . " x" . StartXlist . " y" . StartYlist, Search Hotstrings
Gui, SearchLoad:Destroy

Search:
Gui, HS3List:Submit, NoHide
if getkeystate("CapsLock","T")
return
GuiControlGet, v_SearchTerm
GuiControl, -Redraw, List
LV_Delete()
if (v_RadioGroup == 2)
{
    For Each, FileName In a_Triggerstring
    {
    If (v_SearchTerm != "")
    {
        If (InStr(FileName, v_SearchTerm) = 1) ; for matching at the start
        ; If InStr(FileName, v_SearchTerm) ; for overall matching
            LV_Add("",a_Library[A_Index], a_Hotstring[A_Index],a_TriggerOptions[A_Index],a_OutputFunction[A_Index],a_EnableDisable[A_Index],FileName,a_Comment[A_Index])
    }
    Else
         LV_Add("",a_Library[A_Index], a_Hotstring[A_Index],a_TriggerOptions[A_Index],a_OutputFunction[A_Index],a_EnableDisable[A_Index],FileName,a_Comment[A_Index])
    }
	LV_ModifyCol(6,"Sort")
}
else if (v_RadioGroup == 1)
{
    For Each, FileName In a_Hotstring
    {
    If (v_SearchTerm != "")
    {
        If (InStr(FileName, v_SearchTerm) = 1) ; for matching at the start
        ; If InStr(FileName, v_SearchTerm) ; for overall matching
			LV_Add("",a_Library[A_Index], FileName,a_TriggerOptions[A_Index],a_OutputFunction[A_Index],a_EnableDisable[A_Index],a_Triggerstring[A_Index],a_Comment[A_Index])
    }
    Else
		LV_Add("",a_Library[A_Index], FileName,a_TriggerOptions[A_Index],a_OutputFunction[A_Index],a_EnableDisable[A_Index],a_Triggerstring[A_Index],a_Comment[A_Index])
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
			LV_Add("",FileName, a_Hotstring[A_Index],a_TriggerOptions[A_Index],a_OutputFunction[A_Index],a_EnableDisable[A_Index],a_Triggerstring[A_Index],a_Comment[A_Index])
    }
    Else
        LV_Add("",FileName, a_Hotstring[A_Index],a_TriggerOptions[A_Index],a_OutputFunction[A_Index],a_EnableDisable[A_Index],a_Triggerstring[A_Index],a_Comment[A_Index])
    }
	LV_ModifyCol(1,"Sort")
}
GuiControl, +Redraw, List
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

MoveList:
	Gui, HS3List:Submit, NoHide
	If !(v_SelectedRow := LV_GetNext()) {
		MsgBox, 0, %A_ThisLabel%, Select a row in the list-view, please!
		Return
	}
	LV_GetText(FileName,v_SelectedRow,1)
	LV_GetText(Triggerstring, v_SelectedRow,2)
	LV_GetText(TriggOpt, v_SelectedRow,3)
	LV_GetText(OutFun, v_SelectedRow,4)
	LV_GetText(EnDis, v_SelectedRow,5)
	If (EnDis == "En")
		OnOff := "On"
	else if (EnDis == "Dis")
		OnOff := "Off"
	LV_GetText(HSText, v_SelectedRow,6)
	LV_GetText(Comment, v_SelectedRow,7)
	MovedHS := TriggOpt . "‖" . Triggerstring . "‖" . OutFun . "‖" . EnDis . "‖" . HSText . "‖" . Comment
	MovedNoOptHS := "‖" . Triggerstring . "‖" . OutFun . "‖" . EnDis . "‖" . HSText . "‖" . Comment
	Gui, MoveLibs:New
	cntMove := -1
	Loop, %A_ScriptDir%\Libraries\*.csv
	{
		cntMove += 1
	}
	Gui, MoveLibs:Add, Text,, Select the target library:
	Gui, MoveLibs:Add, ListView,LV0x1 -Hdr r%cntMove%,Library
	Loop, %A_ScriptDir%\Libraries\*.csv
	{
		if (SubStr(A_LoopFileName,1,StrLen(A_LoopFileName)-4) != FileName )
		{
			LV_Add("",A_LoopFileName)
		}
	}
	Gui, MoveLibs:Add, Button,% "gMove w" . 100*DPI%v_SelectedMonitor%, Move
	Gui, MoveLibs:Add, Button, % "yp x+m gCanMove w" . 100*DPI%v_SelectedMonitor%, Cancel
	Gui, MoveLibs:Show,, Select library
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

CanMove:
Gui, MoveLibs:Destroy
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Move:
Gui, MoveLibs:Submit, NoHide
If !(v_SelectedRow := LV_GetNext()) {
	MsgBox, 0, %A_ThisLabel%, Select a row in the list-view, please!
	Return
}
LV_GetText(TargetLib, v_SelectedRow)
FileRead, Text, Libraries\%TargetLib%
SectionList := StrSplit(Text, "`r`n")
InputFile = % A_ScriptDir . "\Libraries\" . TargetLib
LString := % "‖" . Triggerstring . "‖"
SaveFlag := 0
Gui, HS3:Default
GuiControl, Choose, v_SelectHotstringLibrary, %TargetLib%
gosub, SectionChoose
Loop, Read, %InputFile%
{
	if InStr(A_LoopReadLine, LString)
	{
		MsgBox, 4,, The hostring "%Triggerstring%" exists in a file %TargetLib%. Do you want to proceed?
		IfMsgBox, No
		{
			Gui, MoveLibs:Destroy
			return
		}
		LV_Modify(A_Index, "", Triggerstring, TriggOpt, OutFun, EnDis, HSText, Comment)
		SaveFlag := 1
	}
}
if (SaveFlag == 0)
	{
		LV_Add("",  Triggerstring, TriggOpt, OutFun, EnDis,  HSText, Comment)
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
InputFile := % A_ScriptDir . "\Libraries\" . FileName . ".csv"
OutputFile := % A_ScriptDir . "\Libraries\temp.csv"
cntLines := 0
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
MsgBox Hotstring moved to the %TargetLib% file!
	F_LoadFiles(TargetLib)
Gui, MoveLibs:Destroy
Gui, HS3List:Destroy
gosub, L_Searching
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

SearchChange:
GuiControl,,v_SearchTerm, %v_SearchTerm%
gosub, Search
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

HS3ListGuiSize:
	if (ErrorLevel == 1)
		return
    IniW := StartWlist
	IniH := StartHlist
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
~F3::
HS3ListGuiEscape:
HS3ListGuiClose:
	Gui, HS3List:Destroy
	v_SearchTerm := ""
	a_Hotstring := []
	a_Library := []
	a_Triggerstring := []
	a_EnableDisable := []
	v_RadioGroup := ""
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

Undo:
	Menu, Submenu1, ToggleCheck, &Undo last hotstring
	Undo := !(Undo)
	IniWrite, %Undo%, Config.ini, Configuration, UndoHotstring
return

F11::
	IniRead, Undo, Config.ini, Configuration, UndoHotstring
	Undo := !(Undo)
	IniWrite, %Undo%, Config.ini, Configuration, UndoHotstring
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Tips:
	Menu, SubmenuTips, ToggleCheck, Enable/Disable
	Menu, SubmenuTips, ToggleEnable, Choose tips location
	Menu, SubmenuTips, ToggleEnable, &Number of characters for tips
	ini_Tips := !(ini_Tips)
	IniWrite, %ini_Tips%, Config.ini, Configuration, Tips
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Sandbox:
	Menu, Submenu1, ToggleCheck, &Launch Sandbox
	Sandbox := !(Sandbox)
	If (Sandbox == 0)
	{
		Gui, % "HS3:+MinSize"  . 1350*DPI%v_SelectedMonitor% . "x" . 640*DPI%v_SelectedMonitor%+20
		GuiControl, HS3:Hide, Sandbox
		GuiControl, HS3:Hide, SandString
	}
	else
	{
		Gui, % "HS3:+MinSize"  . 1350*DPI%v_SelectedMonitor% . "x" . 640*DPI%v_SelectedMonitor%+20  + 154*DPI%v_SelectedMonitor%
		GuiControl, HS3:Show, Sandbox
		GuiControl, HS3:Show, SandString
		if v_PreviousHeight < 640*DPI%v_SelectedMonitor%+20  + 154*DPI%v_SelectedMonitor%
			Gui, HS3:Show, % "h" . 640*DPI%v_SelectedMonitor%+20  + 154*DPI%v_SelectedMonitor%
	}
	IniWrite, %Sandbox%, Config.ini, Configuration, Sandbox
return

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
	Menu, Submenu2, ToggleCheck, Space
	EndingChar_Space := !(EndingChar_Space)
	IniWrite, %EndingChar_Space%, Config.ini, Configuration, EndingChar_Space
	EndChars()
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

EndMinus:
	Menu, Submenu2, ToggleCheck, Minus -
	EndingChar_Minus := !(EndingChar_Minus)
	IniWrite, %EndingChar_Minus%, Config.ini, Configuration, EndingChar_Minus
	EndChars()
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

EndORoundBracket:
	Menu, Submenu2, ToggleCheck, Opening Round Bracket (
	EndingChar_ORoundBracket := !(EndingChar_ORoundBracket)
	IniWrite, %EndingChar_ORoundBracket%, Config.ini, Configuration, EndingChar_ORoundBracket
	EndChars()
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

EndCRoundBracket:
	Menu, Submenu2, ToggleCheck, Closing Round Bracket )
	EndingChar_CRoundBracket := !(EndingChar_CRoundBracket)
	IniWrite, %EndingChar_CRoundBracket%, Config.ini, Configuration, EndingChar_CRoundBracket
	EndChars()
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

EndOSquareBracket:
	Menu, Submenu2, ToggleCheck, Opening Square Bracket [
	EndingChar_OSquareBracket := !(EndingChar_OSquareBracket)
	IniWrite, %EndingChar_OSquareBracket%, Config.ini, Configuration, EndingChar_OSquareBracket
	EndChars()
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

EndCSquareBracket:
	Menu, Submenu2, ToggleCheck, Closing Square Bracket ]
	EndingChar_CSquareBracket := !(EndingChar_CSquareBracket)
	IniWrite, %EndingChar_CSquareBracket%, Config.ini, Configuration, EndingChar_CSquareBracket
	EndChars()
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

EndOCurlyBracket:
	Menu, Submenu2, ToggleCheck, Opening Curly Bracket {
	EndingChar_OCurlyBracket := !(EndingChar_OCurlyBracket)
	IniWrite, %EndingChar_OCurlyBracket%, Config.ini, Configuration, EndingChar_OCurlyBracket
	EndChars()
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

EndCCurlyBracket:
	Menu, Submenu2, ToggleCheck, Closing Curly Bracket }
	EndingChar_CCurlyBracket := !(EndingChar_CCurlyBracket)
	IniWrite, %EndingChar_CCurlyBracket%, Config.ini, Configuration, EndingChar_CCurlyBracket
	EndChars()
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

EndColon:
	Menu, Submenu2, ToggleCheck, Colon :
	EndingChar_Colon := !(EndingChar_Colon)
	IniWrite, %EndingChar_Colon%, Config.ini, Configuration, EndingChar_Colon
	EndChars()
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

EndSemicolon:
	Menu, Submenu2, ToggleCheck, % "Semicolon `;"
	EndingChar_Semicolon := !(EndingChar_Semicolon)
	IniWrite, %EndingChar_Semicolon%, Config.ini, Configuration, EndingChar_Semicolon
	EndChars()
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

EndApostrophe:
	Menu, Submenu2, ToggleCheck, Apostrophe '
	EndingChar_Apostrophe := !(EndingChar_Apostrophe)
	IniWrite, %EndingChar_Apostrophe%, Config.ini, Configuration, EndingChar_Apostrophe
	EndChars()
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

EndQuote:
	Menu, Submenu2, ToggleCheck, % "Quote """
	EndingChar_Quote := !(EndingChar_Quote)
	IniWrite, %EndingChar_Quote%, Config.ini, Configuration, EndingChar_Quote
	EndChars()
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

EndSlash:
	Menu, Submenu2, ToggleCheck, Slash /
	EndingChar_Slash := !(EndingChar_Slash)
	IniWrite, %EndingChar_Slash%, Config.ini, Configuration, EndingChar_Slash
	EndChars()
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

EndBackslash:
	Menu, Submenu2, ToggleCheck, Backslash \
	EndingChar_Backslash := !(EndingChar_Backslash)
	IniWrite, %EndingChar_Backslash%, Config.ini, Configuration, EndingChar_Backslash
	EndChars()
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

EndComma:
	Menu, Submenu2, ToggleCheck, % "Comma ,"
	EndingChar_Comma := !(EndingChar_Comma)
	IniWrite, %EndingChar_Comma%, Config.ini, Configuration, EndingChar_Comma
	EndChars()
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

EndDot:
	Menu, Submenu2, ToggleCheck, Dot .
	EndingChar_Dot := !(EndingChar_Dot)
	IniWrite, %EndingChar_Dot%, Config.ini, Configuration, EndingChar_Dot
	EndChars()
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

EndQuestionMark:
	Menu, Submenu2, ToggleCheck, Question Mark ?
	EndingChar_QuestionMark := !(EndingChar_QuestionMark)
	IniWrite, %EndingChar_QuestionMark%, Config.ini, Configuration, EndingChar_QuestionMark
	EndChars()
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

EndExclamationMark:
	Menu, Submenu2, ToggleCheck, Exclamation Mark !
	EndingChar_ExclamationMark := !(EndingChar_ExclamationMark)
	IniWrite, %EndingChar_ExclamationMark%, Config.ini, Configuration, EndingChar_ExclamationMark
	EndChars()
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

EndEnter:
	Menu, Submenu2, ToggleCheck, Enter
	EndingChar_Enter := !(EndingChar_Enter)
	IniWrite, %EndingChar_Enter%, Config.ini, Configuration, EndingChar_Enter
	EndChars()
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

EndTab:
	Menu, Submenu2, ToggleCheck, Tab
	EndingChar_Tab := !(EndingChar_Tab)
	IniWrite, %EndingChar_Tab%, Config.ini, Configuration, EndingChar_Tab
	EndChars()
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
	Menu, Submenu3, ToggleCheck, Caret
	Menu, Submenu3, ToggleCheck, Cursor
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
	Menu, PositionMenu, ToggleCheck, Caret
	Menu, PositionMenu, ToggleCheck, Cursor
	ini_MenuCaret := !(ini_MenuCaret)
	ini_MenuCursor := !(ini_MenuCursor)
	IniWrite, %ini_MenuCaret%, Config.ini, Configuration, MenuCaret
	IniWrite, %ini_MenuCursor%, Config.ini, Configuration, MenuCursor
return

L_MenuSound:
	Menu, SubmenuMenu, ToggleCheck, Enable &sound if overrun
	ini_MenuSound := !(ini_MenuSound)
	IniWrite, %ini_MenuSound%, Config.ini, Configuration, MenuSound
return

#if