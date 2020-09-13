/*
Author:       aciej Słojewski, mslonik, http://mslonik.pl
Purpose:     Facilitate normal operation for company desktop.
Description: Hotkeys and hotstrings for my everyday professional activities and office cockpit.
License:     GNU GPL v.3
*/

#SingleInstance force 			; only one instance of this script may run at a time!
#NoEnv  						; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  							; Enable warnings to assist with detecting common errors.
#Persistent
SendMode Input  				; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%		; Ensures a consistent starting directory.
; ---------------------- HOTSTRINGS -----------------------------------
;~ The general hotstring rules:
;~ 1. Automatic changing small letters to capital letters: just press ending character (e.g. <Enter> or <Space> or <(>).
;~ 2. Automatic expansion of abbreviation: after small letters just press a </>.
;~ 2.1. If expansion contain double letters, use that letter and <2>. E.g. <c2ms> expands to <CCMS> and <c2ms/> expands to <Component Content Management System>.
;~ 3. Each hotstrings can be undone upon pressing of usual shotcuts: <Ctrl + z> or <Ctrl + BackSpace>.

IfNotExist, Categories\PersonalHotstrings.csv
	FileAppend,, Categories\PersonalHotstrings.csv, UTF-8
IfNotExist, Categories\New.csv
	FileAppend,, Categories\New.csv, UTF-8

Menu, Tray, Add, Edit Hotstring, HotstringAutoExec
Menu, Tray, Add, About, About
Menu, Tray, Default, Edit Hotstring
Menu, Tray, Add
Menu, Tray, NoStandard
Menu, Tray, Standard
; --------------- SECTION OF GLOBAL VARIABLES -----------------------------
CapCheck := ""
HotString := ""
PrevSec := A_Args[2]
PrevW := A_Args[3], PrevH := A_Args[4], PrevX := A_Args[5], PrevY := A_Args[6]
init := 0
WindowTransparency	:= 0
MyHotstring 		:= ""
English_USA 		:= 0x0409   ; see AutoHotkey help: Language Codes
SelectedRow := 0
delay := 200
; --------------- END OF GLOBAL VARIABLES SECTION ----------------------
LoadFiles("voestalpineHotstrings.csv")
LoadFiles("PhysicsHotstrings.csv")
LoadFiles("Abbreviations.csv")
LoadFiles("PolishHotstrings.csv")
LoadFiles("GermanHotstrings.csv")
LoadFiles("TimeHotstrings.csv")
LoadFiles("FirstAndSecondNames.csv")
LoadFiles("EmojiHotstrings.csv")
LoadFiles("TechnicalHotstrings.csv")
LoadFiles("AutocorrectionHotstrings.csv")
LoadFiles("CapitalLetters.csv")
LoadFiles("PersonalHotstrings.csv")
LoadFiles("New.csv")
if(PrevSec)
	gosub HotstringAutoExec
#if WinActive(, "Microsoft Word") or WinActive(, "Microsoft Outlook") or WinActive(, "Microsoft Excel") or WinActive("ahk_exe SciTe.exe") or WinActive("ahk_exe notepad.exe")
^z::			;~ Ctrl + z as in MS Word: Undo
$!BackSpace:: 	;~ Alt + Backspace as in MS Word: rolls back last Autocorrect action
	if (MyHotstring && (A_ThisHotkey != A_PriorHotkey))
		{
			
		;~ MsgBox, % "MyHotstring: " . MyHotstring . " A_ThisHotkey: " . A_ThisHotkey . " A_PriorHotkey: " . A_PriorHotkey
		ToolTip, Undo the last hotstring., % A_CaretX, % A_CaretY - 20
		Send, % "{BackSpace " . StrLen(MyHotstring) . "}" . SubStr(A_PriorHotkey, InStr(A_PriorHotkey, ":", CaseSensitive := false, StartingPos := 1, Occurrence := 2) + 1)
		SetTimer, TurnOffTooltip, -5000
		MyHotstring := ""
		}
	else
		{
		ToolTip,
		Send, !{BackSpace}
		}
return
#if
; - - - - - - - - END OF KEYBOARD HOTKEYS SECTION - - - - - - - - - - - - - - - - - - - - - 
; - - - - - - - - - - - - SECTION OF FUNCTIONS  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
ViaClipboard(ReplacementString)
{
	global MyHotstring, oWord, delay
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
	Sleep, %delay% ; this sleep is required surprisingly
	Clipboard := ClipboardBackup
	ClipboardBackup := ""
	MyHotstring := ReplacementString
	Hotstring("Reset")
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
NormalWay(ReplacementString)
{
	global MyHotstring
	Send, %ReplacementString%
	
	SetFormat, Integer, H
	InputLocaleID:=DllCall("GetKeyboardLayout", "UInt", 0, "UInt")
	Polish := Format("{:#x}", 0x415)
	InputLocaleID := InputLocaleID / 0xFFFF
	InputLocaleID := Format("{:#04x}", InputLocaleID)
	;MsgBox, % InputLocaleID . " `" . Polish
	if(InputLocaleID = Polish)
	{
		Send, {LCtrl up}
	}
	
	MyHotstring := SubStr(A_ThisHotkey, InStr(A_ThisHotkey, ":", false, 1, 2) + 1)
	;Hotstring("Reset") 
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
MenuText(TextOptions)
{
	global MyHotstring, MenuListbox
	MyHotstring := ""
	Gui, Menu:New, +LastFound +AlwaysOnTop -Caption +ToolWindow
	Gui, Menu:Margin, 0, 0
	Gui, Menu:Add, Listbox, x0 y0 h100 w250 vMenuListbox,
	for k, MenuItems in StrSplit(TextOptions,"¦") ;parse the data on the weird pipe character
	{
		GuiControl,, MenuListbox, % MenuItems
	}
	CoordMode, Mouse, Screen
	MouseGetPos, MouseX, MouseY 
	Gui, Menu:Show, x%MouseX% y%MouseY%, Hotstring listbox
	if (MyHotstring == "")
	{
		HK := StrSplit(A_ThisHotkey, ":")
		ThisHotkey := SubStr(A_ThisHotkey, StrLen(HK[2])+3, StrLen(A_ThisHotkey)-StrLen(HK[2])-2)
		Send, % ThisHotkey
	}
	GuiControl, Choose, MenuListbox, 1
return
}
#IfWinActive Hotstring listbox
Enter::
Gui, Menu:Submit, Hide
ClipboardBack:=ClipboardAll ;backup clipboard
Clipboard:=MenuListbox ;Shove what was selected into the clipboard
Send, ^v ;paste the text
sleep, %delay% ;Remember to sleep before restoring clipboard or it will fail
MyHotstring := MenuListbox
Clipboard:=ClipboardBack
Gui, Menu:Destroy
Return
#If
#IfWinExist Hotstring listbox
	Esc::
	Gui, Menu:Destroy
	Send, % SubStr(A_PriorHotkey, InStr(A_PriorHotkey, ":", CaseSensitive := false, StartingPos := 1, Occurrence := 2) + 1)
	return
#If
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
MenuTextAHK(TextOptions){
	global MyHotstring, MenuListbox
	MyHotstring := ""
	Gui, MenuAHK:New, +LastFound +AlwaysOnTop -Caption +ToolWindow
	Gui, MenuAHK:Margin, 0, 0
	Gui, MenuAHK:Add, Listbox, x0 y0 h100 w250 vMenuListbox2,
	for k, MenuItems in StrSplit(TextOptions,"¦") ;parse the data on the weird pipe character
	{
		GuiControl,, MenuListbox2, % MenuItems
	}
	CoordMode, Mouse, Screen
	MouseGetPos, MouseX, MouseY 
	Gui, MenuAHK:Show, x%MouseX% y%MouseY%, HotstringAHK listbox
if (MyHotstring == "")
{
	HK := StrSplit(A_ThisHotkey, ":")
	ThisHotkey := SubStr(A_ThisHotkey, StrLen(HK[2])+3, StrLen(A_ThisHotkey)-StrLen(HK[2])-2)
	Send, % ThisHotkey
}
	GuiControl, Choose, MenuListbox2, 1
return
}
#IfWinActive HotstringAHK listbox
Enter::
Gui, MenuAHK:Submit, Hide
Send, % MenuListbox2
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
	
	MyHotstring := SubStr(A_ThisHotkey, InStr(A_ThisHotkey, ":", false, 1, 2) + 1)
Gui, MenuAHK:Destroy
Return
#If
#IfWinExist HotstringAHK listbox
	Esc::
	Gui, MenuAHK:Destroy
	Send, % SubStr(A_PriorHotkey, InStr(A_PriorHotkey, ":", CaseSensitive := false, StartingPos := 1, Occurrence := 2) + 1)
	return
#If
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
StartHotstring(txt)
{
	static Options, NewString, OnOff, SendFun, TextInsert
	txtsp := StrSplit(txt, "‖")
	Options := txtsp[1]
	NewString := txtsp[2]
	if (txtsp[3] == "A")
		SendFun := "NormalWay"
	else if (txtsp[3] == "C") 
		SendFun := "ViaClipboard"
	else if (txtsp[3] == "MC") 
		SendFun := "MenuText"
	else if (txtsp[3] == "MA") 
		SendFun := "MenuTextAHK"
	OnOff := txtsp[4]
	TextInsert := % txtsp[5]
	Hotstring(":" . Options . ":" . NewString, func(SendFun).bind(TextInsert), OnOff)
	return
}
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
LoadFiles(nameoffile)
{
	Loop
	{
		FileReadLine, line, Categories2\%nameoffile%, %A_Index%
		if ErrorLevel
			break
		line := StrReplace(line, "A_YYYY", A_YYYY)
		line := StrReplace(line, "A_MM", A_MM)
		line := StrReplace(line, "A_DD", A_DD)
		line := StrReplace(line, "A_Hour", A_Hour)
		line := StrReplace(line, "A_Min", A_Min)
		line := StrReplace(line, "``n", "`n")
		line := StrReplace(line, "``r", "`r")
		StartHotstring(line)
	}
	return
}
; ---------------------- SECTION OF LABELS ------------------------------------
TurnOffTooltip:
	ToolTip ,
return

HotstringAutoExec:
Gui, Hotstring:New, MinSize860x743 +Resize -DPIScale
Gui, Hotstring:Font, s14 cBlue Bold , Calibri
Gui, Hotstring:Add, Text, Section vText1 , Enter Hotstring
Gui, Hotstring:Font, s12 cBlack Norm
Gui, Hotstring:Add, Edit, w100 vNewString ys,
Gui, Hotstring:Add, Slider, ys vMySlider gmySlider Range100-1000 ToolTipBottom Buddy1999, %delay%
Gui, Hotstring:Add, Text,yp+30 x285 vDelayText , Hotstring delay %delay% ms
Gui, Hotstring:Font, s14 cBlue Bold
Gui, Hotstring:Add, Text,  xs yp+5 vText2, Enter Replacement Text 
Gui, Hotstring:Font, s12 cBlack Norm
Gui, Hotstring:Add, Edit, w500 vTextInsert xs
Gui, Hotstring:Add, Edit, w500 vTextInsert1 xs Disabled
Gui, Hotstring:Add, Edit, w500 vTextInsert2 xs Disabled
Gui, Hotstring:Add, Edit, w500 vTextInsert3 xs Disabled
Gui, Hotstring:Add, Edit, w500 vTextInsert4 xs Disabled
Gui, Hotstring:Add, Edit, w500 vTextInsert5 xs Disabled
Gui, Hotstring:Add, Edit, w500 vTextInsert6 xs Disabled

Gui, Hotstring:Font, s14 cBlue Bold
Gui, Hotstring:Add, GroupBox, section w500 h150, Hotstring Options
Gui, Hotstring:Font, s12 cBlack Norm
Gui, Hotstring:Add, CheckBox, vCaseSensitive gCapsCheck xp+15 ys+25, Case Sensitive (C)
Gui, Hotstring:Add, CheckBox, vNoBackspace gCapsCheck xp+255 yp+0, No Backspace (B0)
Gui, Hotstring:Add, CheckBox, vImmediate gCapsCheck  xp-255 yp+20, Immediate Execute (*)
Gui, Hotstring:Add, CheckBox, vInsideWord gCapsCheck  xp+255 yp+0, Inside Word (?)
Gui, Hotstring:Add, CheckBox, vNoEndChar gCapsCheck  xp-255 yp+20, No End Char (O)
Gui, Hotstring:Add, CheckBox, vRaw gCapsCheck  xp+255 yp+0, Raw Text Mode (T)
Gui, Hotstring:Add, CheckBox, vExecute gCapsCheck  xp-255 yp+20, Labels/Functions (X)
Gui, Hotstring:Add, CheckBox, vDisHS gCapsCheck xp+255 yp+0, Disable
Gui, Hotstring:Add, DropDownList, xp-255 yp+25 w250 vByClip gByClip, Send by Autohotkey|Send by Clipboard|Send by Menu (Clipboard)|Send by Menu (Autohotkey)
;Gui, Hotstring:Add, CheckBox, vByClip gCapsCheck  xp-255 yp+20, Clipboard Hotstring

Gui, Hotstring:Add, Edit, w500 vStringCombo xs gViewString ReadOnly Hide,
Gui, Hotstring:Font, Bold

Gui, Hotstring:Font, s14 cBlue
Gui, Hotstring:Add, Text,  xm vText3, Hotstring Test Pad
Gui, Hotstring:Font, s12 Norm
Gui, Hotstring:Add, Edit,  xm r4 w500 vTestPad cGreen, 

Gui, Hotstring:Font, s12 cBlack Bold
Gui, Hotstring:Add, Text, xs ,Choose section:
Gui, Hotstring:Font, s12 cBlack Norm
Gui, Hotstring:Add, DropDownList, w500 vSectionCombo gSectionChoose xs ,
Loop,%A_ScriptDir%\Categories2\*.csv
  GuiControl, , SectionCombo, %A_LoopFileName%
Gui, Hotstring:Font, Bold
Gui, Hotstring:Add, Button, gAddHotstring vAddHotstring section xm, Set Hotstring
Gui, Hotstring:Add, Button, gSaveHotstrings section  ys Disabled, Save Hotstring

Gui, Hotstring:Add, Button, gEdit vEdit w60 ys Disabled, Edit

Gui, Hotstring:Font, s14 cBlue Bold , Arial
Gui, Hotstring:Add, Text, ym, Hotstrings in section
Gui, Hotstring:Font, s12 cBlack Norm
Gui, Hotstring:Add, ListView, LV0x1 0x4 yp+25 xp h510 w500 vHSList, Options|Hotstring|Fun|On/Off|Text

ShowHotstrings:
if ((PrevW != "") and (PrevH != ""))
{
	Gui, Hotstring:Show, W%PrevW% H%PrevH% X%PrevX% Y%PrevY%,Hotstrings Edition
}
else	
Gui, Hotstring:Show, ,Hotstrings Edition
if (PrevSec != "")
{
	GuiControl, Choose, ComboBox2, %PrevSec%
	gosub SectionChoose
	if(A_Args[7] > 0)
	{
		LV_Modify(A_Args[7], "Vis")
		LV_Modify(A_Args[7], "Select")
	}
}
Return

ByClip:
Gui, Hotstring:+OwnDialogs
GuiControlGet, ByClip
if InStr(ByClip, "Send by Menu")
{
	GuiControl, Enable, TextInsert1
	GuiControl, Enable, TextInsert2
	GuiControl, Enable, TextInsert3
	GuiControl, Enable, TextInsert4
	GuiControl, Enable, TextInsert5
	GuiControl, Enable, TextInsert6
}
else
{
	GuiControl, , TextInsert1,
	GuiControl, , TextInsert2,
	GuiControl, , TextInsert3,
	GuiControl, , TextInsert4,
	GuiControl, , TextInsert5,
	GuiControl, , TextInsert6,
	GuiControl, Disable, TextInsert1
	GuiControl, Disable, TextInsert2
	GuiControl, Disable, TextInsert3
	GuiControl, Disable, TextInsert4
	GuiControl, Disable, TextInsert5
	GuiControl, Disable, TextInsert6
}
return

MySlider:
	delay := MySlider
	if (delay = 1000)
		GuiControl,,DelayText, Hotstring delay 1 s
	else
		GuiControl,,DelayText, Hotstring delay %delay% ms
return

About:
	Gui, MyAbout: Font, Bold
    Gui, MyAbout: Add, Text, , Hotstrings.ahk
    Gui, MyAbout: Font
    Gui, MyAbout: Add, Text, xm, Authors: Jakub Masiak, Maciej Słojewski
	Gui, MyAbout: Add, Text, xm, The Hotstrings.ahk script allows the use of hotstrings( `
	Gui, MyAbout: Font, CBlue Underline 
    Gui, MyAbout: Add, Text, x+1, https://www.autohotkey.com/docs/Hotstrings.htm
	Gui, MyAbout: Font
	Gui, MyAbout: Add, Text, x+1, ).
	Gui, MyAbout: Add, Text, xm, The "Edit Hostrings" option allows you to add new hostings and edit existing ones using a dedicated interface.
    Gui, MyAbout: Add, Button, Default Hidden w100 gMyOK Center vOkButtonVariabl hwndOkButtonHandle, &OK
    GuiControlGet, MyGuiControlGetVariable, MyAbout: Pos, %OkButtonHandle%
    Gui, MyAbout: Show, Center, Hotstrings.ahk About
    WinGetPos, , , MyAboutWindowWidth, , Hotstrings.ahk About
    NewButtonXPosition := ( MyAboutWindowWidth - 220)/2
    GuiControl, Move, %OkButtonHandle%, % "x" NewButtonXPosition
    GuiControl, Show, %OkButtonHandle%
return    
    
MyOK:
MyAboutGuiClose: ; Launched when the window is closed by pressing its X button in the title bar
    Gui, MyAbout: Destroy
return

ViewString:
	GuiControlGet, StringCombo
	Select := StringCombo
	HotString := StrSplit(Select, """")
	HotString2 := StrSplit(HotString[2],":")
	NewStringvar := SubStr(HotString[2], StrLen( ":" . HotString2[2] . ":" ) + 1, StrLen(HotString[2])-StrLen(  ":" . HotString2[2] . ":" ))
	RText := StrSplit(Select, "bind(""")
	if InStr(RText[2], """On""")
	{
		OText := SubStr(RText[2], 1, StrLen(RText[2])-9)
	}
	else
	{    
		OText := SubStr(RText[2], 1, StrLen(RText[2])-10)
	}
	GuiControl, , NewString, % NewStringvar
	if (InStr(Select, """MenuText""") or InStr(Select, """MenuTextAHK"""))
	{
		TextInsert := OText
		OTextMenu := StrSplit(OText, "¦")
		GuiControl, , TextInsert, % OTextMenu[1]
		GuiControl, , TextInsert1, % OTextMenu[2]
		GuiControl, , TextInsert2, % OTextMenu[3]
		GuiControl, , TextInsert3, % OTextMenu[4]
		GuiControl, , TextInsert4, % OTextMenu[5]
		GuiControl, , TextInsert5, % OTextMenu[6]
		GuiControl, , TextInsert6, % OTextMenu[7]

	}
	else
	{
		GuiControl, , TextInsert, % OText
	}
	GoSub SetOptions 
	gosub byclip
	SetTestPad()
Return

AddHotstring:
	Gui, Hotstring:+OwnDialogs
	Gui, Submit, NoHide
	GuiControlGet, ByClip

	If (Trim(NewString) ="")
	{
		MsgBox Enter a Hotstring!
		Return
	}
	if InStr(ByClip,"Send by Menu")
	{
		If ((Trim(TextInsert) ="") and (Trim(TextInsert1) ="") and (Trim(TextInsert2) ="") and (Trim(TextInsert3) ="") and (Trim(TextInsert4) ="") and (Trim(TextInsert5) ="") and (Trim(TextInsert6) =""))
		{
			MsgBox, 4,, Replacement text is blank. Do you want to proceed?
			IfMsgBox, No
			Return
		}
		TextVar := ""
		If (Trim(TextInsert) !="")
			TextVar := % TextVar . "¦" . TextInsert
		If (Trim(TextInsert1) !="")
			TextVar := % TextVar . "¦" . TextInsert1
		If (Trim(TextInsert2) !="")
			TextVar := % TextVar . "¦" . TextInsert2
		If (Trim(TextInsert3) !="")
			TextVar := % TextVar . "¦" . TextInsert3
		If (Trim(TextInsert4) !="")
			TextVar := % TextVar . "¦" . TextInsert4
		If (Trim(TextInsert5) !="")
			TextVar := % TextVar . "¦" . TextInsert5
		If (Trim(TextInsert6) !="")
			TextVar := % TextVar . "¦" . TextInsert6
		TextInsert := SubStr(TextVar, 2, StrLen(TextVar)-1)
	}
	else{
		If (Trim(TextInsert) ="")
		{
			MsgBox, 4,, Replacement text is blank. Do you want to proceed?
			IfMsgBox, No
			Return
		}
	}
;GuiControl, Disable, NewString
	if SectionCombo >= 1
		GuiControl, Enable, Save Hotstring
; Trap for non-existent Label or function when using the X option.

	RegExMatch(TextInsert, "(.*)\(" , FuncMatch) 
	If (Execute = 1) and (IsLabel(TextInsert) = 0) and (IsFunc(FuncMatch1) = 0)
	{
		MsgBox, Replacement text must be a Label or function
		Return
	}
	OldOptions := ""

	GuiControlGet, StringCombo
	Select := StringCombo
	ControlGet, Items, Line,1, StringCombo

	Loop, Parse, Items, `n
	{  
		If InStr(A_LoopField, ":" . NewString . """", CaseSensitive)
		{
			HotString := StrSplit(A_LoopField, ":",,3)
			OldOptions := HotString[2]
			GuiControl,, StringCombo, ""
			Break
		}
	}

; Added this conditional to prevent Hotstrings from a file losing the C1 option caused by
; cascading ternary operators when creating the options string. CapCheck set to 1 when 
; a Hotstring from a file contains the C1 option.

	If (CapCheck = 1) and ((OldOptions = "") or (InStr(OldOptions,"C1"))) and (Instr(Hotstring[2],"C1"))
		OldOptions := StrReplace(OldOptions,"C1") . "C"
	CapCheck := 0

	GoSub OptionString   ; Writes the Hotstring options string


; Check for # in Web URL TextInsert and add curly brackets
	If (InStr(TextInsert,"{#}") = 0 
		and InStr(TextInsert,"http") 
		and (InStr(Options,"T") = 0
		or InStr(Options,"T0")))
	{
		If InStr(Options,"T0")
		{
			Options := StrReplace(Options,"T0","T")
			Options := StrReplace(Options,"O0","O")
		}
		Else
		{
			Options := Options . "O"
			Options := Options . "T"
		}
		Control, Check, , Button7, A  ; Raw Text Mode
		Control, Check, , Button6, A  ; Raw Text Mode
	}

/*
This conditional routine looks for Hotkey modifiers in the replacement
text giving you the chance to set the mode to raw.
*/

	If RegExMatch(TextInsert, "[!+#^{}]" , Modifier)
		and RegExMatch(TextInsert, "{.*}") = 0
		and (InStr(Options,"T") = 0 or InStr(Options,"T0"))
		{
			MsgBox,3,Modifier Found, Hotkey modifier %modifier% found!`rSet Raw Text Mode?
			IfMsgBox Yes
			{
				If InStr(Options,"T0")
					Options := StrReplace(Options,"T0","T")
				Else
					Options := Options . "T"
			Control, Check, , Button7, A  ; Raw Text Mode
			}
	}

; Add new/changed target item in DropDownList
	if (ByClip == "Send by Clipboard")
		SendFun := "ViaClipboard"
	else if (ByClip == "Send by Autohotkey")
		SendFun := "NormalWay"
	else if (ByClip == "Send by Menu (Clipboard)")
		SendFun := "MenuText"
	else if (ByClip == "Send by Menu (Autohotkey)")
		SendFun := "MenuTextAHK"
	else 
	{
		MsgBox, Choose the method of sending the hotstring!
		return
	}

	if (DisHS == 1)
		OnOff := "Off"
	else
		OnOff := "On"
		GuiControl,, StringCombo , % "Hotstring("":" . Options . ":" . NewString . """, func(""" . SendFun . """).bind(""" . TextInsert . """), """ . OnOff . """)"

; Select target item in list
	gosub, ViewString

; If case sensitive (C) or inside a word (?) first deactivate Hotstring
	If (CaseSensitive or InsideWord or InStr(OldOptions,"C") 
		or InStr(OldOptions,"?")) 
		Hotstring(":" . OldOptions . ":" . NewString , func(SendFun).bind(TextInsert), "Off")

; Create Hotstring and activate
	Hotstring(":" . Options . ":" . NewString, func(SendFun).bind(TextInsert), OnOff)

	MsgBox, Hotstring has been set.
; Cleans and sets cursor to Test Pad
		SetTestPad()
return

SetTestPad()
{
	GuiControl, Focus, TestPad
	GuiControl, , TestPad,
}

SetOptions:
	If InStr(Hotstring2[2],"R")
	Hotstring2[2] := StrReplace(Hotstring[2],"R","T")

	OptionSet := ((Instr(Hotstring2[2],"C0")) or (Instr(Hotstring2[2],"C1")) or (Instr(Hotstring2[2],"C") = 0)) 
		? CheckOption("No",2)  :  CheckOption("Yes",2)
	OptionSet := Instr(Hotstring2[2],"B0") ? CheckOption("Yes",3)  :  CheckOption("No",3)
	OptionSet := Instr(Hotstring2[2],"*0") or InStr(Hotstring2[2],"*") = 0 ? CheckOption("No",4)
					:  CheckOption("Yes",4)
	OptionSet := Instr(Hotstring2[2],"?") ? CheckOption("Yes",5)  :  CheckOption("No",5)
	OptionSet := (Instr(Hotstring2[2],"O0") or (InStr(Hotstring2[2],"O") = 0)) ? CheckOption("No",6)
					:  CheckOption("Yes",6)
	OptionSet := (Instr(Hotstring2[2],"T0") or (InStr(Hotstring2[2],"T") = 0)) ? CheckOption("No",7)
					:  CheckOption("Yes",7)
	OptionSet := (Instr(Hotstring2[2],"X0") or (InStr(Hotstring2[2],"X") = 0)) ? CheckOption("No",8)
					:  CheckOption("Yes",8)
	GuiControlGet, StringCombo
	Select := StringCombo
	if Select = 
		return
	OptionSet := (InStr(Select,"""On""")) ? CheckOption("No", 9) : CheckOption("Yes", 9)
	if(InStr(Select,"NormalWay"))
		GuiControl, Choose, ByClip, Send by Autohotkey
	else if(InStr(Select, "ViaClipboard"))
		GuiControl, Choose, ByClip, Send by Clipboard
	else if(InStr(Select, """MenuText"""))
		GuiControl, Choose, ByClip, Send by Menu (Clipboard)
	else if(InStr(Select, """MenuTextAHK"""))
		GuiControl, Choose, ByClip, Send by Menu (Autohotkey)
	CapCheck := 0
Return

OptionString:
	Options := ""

	Options := CaseSensitive = 1 ? Options . "C"
		: (Instr(OldOptions,"C1")) ?  Options . "C0"
		: (Instr(OldOptions,"C0")) ?  Options
		: (Instr(OldOptions,"C")) ? Options . "C1" : Options

	Options := NoBackspace = 1 ?  Options . "B0" 
		: (NoBackspace = 0) and (Instr(OldOptions,"B0"))
		? Options . "B" : Options

	Options := (Immediate = 1) ?  Options . "*" 
		: (Instr(OldOptions,"*0")) ?  Options
		: (Instr(OldOptions,"*")) ? Options . "*0" : Options

	Options := InsideWord = 1 ?  Options . "?" : Options

	Options := (NoEndChar = 1) ?  Options . "O"
		: (Instr(OldOptions,"O0")) ?  Options
		: (Instr(OldOptions,"O")) ? Options . "O0" : Options
 
	Options := Raw = 1 ?  Options . "T" 
		: (Instr(OldOptions,"T0")) ?  Options
		: (Instr(OldOptions,"T")) ? Options . "T0" : Options

	Options := Execute = 1 ?  Options . "X" : Options

; Added to ensure that Hotstring[2] contains current options
	Hotstring[2] := Options
Return

CheckOption(State,Button)
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

	CheckBoxColor(State,Button)  
}

SaveHotstrings:
	Gui, Hotstring:+OwnDialogs

	SaveFile := SectionCombo

	if SectionCombo == ""
	{
		MsgBox, Choose section before saving!
		return
	}

	SaveFile := StrReplace(SaveFile, ".csv", "")

	GuiControlGet, Items,, StringCombo
	OnOff := ""
	SendFun := ""
	if InStr(Items, """On""")
		OnOff := "On"
	else if InStr(Items, """Off""")
		OnOff := "Off"
	if InStr(Items, "ViaClipboard")
		SendFun := "C"
	else if InStr(Items, "NormalWay")
		SendFun := "A"
	else if InStr(Items, """MenuText""")
		SendFun := "MC"
	else if InStr(Items, """MenuTextAHK""")
		SendFun := "MA"
	HSSplit := StrSplit(Items, ":")
	Options := HSSplit[2]
	StrSp2 := StrSplit(HSSplit[3], """,")
	NewString := StrSp2[1]
	StrSp := StrSplit(Items, "bind(""")
	StrSp1 := StrSplit(StrSp[2], """),")
	TextInsert := StrSp1[1]
	OutputFile =% A_ScriptDir . "\Categories2\temp.csv"
	InputFile = % A_ScriptDir . "\Categories2\" . SaveFile . ".csv"
	LString := % "‖" . NewString . "‖"
	SaveFlag := 0

	Loop, Read, %InputFile%, %OutputFile%
	{
		if InStr(A_LoopReadLine, LString)
		{
			if !(SelectedRow)
			{
				MsgBox, 4,, The hostring "%NewString%" exists in a file %SaveFile%.csv. Do you want to proceed?
				IfMsgBox, No
					return
			}
			LV_Modify(A_Index, "", Options, NewString, SendFun, OnOff, TextInsert)
			SaveFlag := 1
		}
	}
	addvar := 0 ; potrzebne, bo źle pokazuje max index listy
	if (SaveFlag == 0)
	{
		LV_Add("", Options, NewString, SendFun, OnOff, TextInsert)
		addvar := 1
	}
	LV_ModifyCol(2, "Sort")
	name := SubStr(SectionCombo, 1, StrLen(SectionCombo)-4)
	name := % name . ".csv"
	FileDelete, Categories2\%name%
	Loop, % SectionList.MaxIndex()-1 + addvar
	{
		LV_GetText(txt1, A_Index, 1)
		LV_GetText(txt2, A_Index, 2)
		LV_GetText(txt3, A_Index, 3)
		LV_GetText(txt4, A_Index, 4)
		LV_GetText(txt5, A_Index, 5)
		txt := % txt1 . "‖" . txt2 . "‖" . txt3 . "‖" . txt4 . "‖" . txt5 . "`r`n"
		FileAppend, %txt%, Categories2\%name%, UTF-8
	}
	LV_GetText(txt1, SectionList.MaxIndex()+addvar, 1)
	LV_GetText(txt2, SectionList.MaxIndex()+addvar, 2)
	LV_GetText(txt3, SectionList.MaxIndex()+addvar, 3)
	LV_GetText(txt4, SectionList.MaxIndex()+addvar, 4)
	LV_GetText(txt5, SectionList.MaxIndex()+addvar, 5)
	txt := % txt1 . "‖" . txt2 . "‖" . txt3 . "‖" . txt4 . "‖" . txt5
	FileAppend, %txt%, Categories2\%name%, UTF-8
	MsgBox Hotstring added to the %SaveFile%.csv file!
	WinGetPos, PrevX, PrevY , , ,Hotstrings Edition
	Run, AutoHotkey.exe Hotstrings2.ahk EditHotstring %SectionCombo% %PrevW% %PrevH% %PrevX% %PrevY% %SelectedRow%
Return

CapsCheck:
	If (Instr(HotString[2], "C1"))
		CapCheck := 1
	GuiControlGet, OutputVar1, Focus
	GuiControlGet, OutputVar2, , %OutputVar1%
	CheckBoxColor(OutputVar2,OutputVar1)
Return

CheckBoxColor(State,Button)
{
	If (State = 1)
		Gui, Hotstring:Font, s12 cRed Norm, Calibri
	Else 
		Gui, Hotstring:Font, s12 cBlack Norm, Calibri
		GuiControl, Hotstring:Font, %Button%
}


Click1:
	Gui, Hotstring:+OwnDialogs
	MsgBox,,, Click Label!, 5
Return

Click()
{
	Gui, Hotstring:+OwnDialogs
	MsgBox,,, Click function!, 5
}

Tags:
Return

TextMenu(TextOptions)
{
	MenuItems := StrSplit(TextOptions, "`,")
	Loop % MenuItems.MaxIndex()
	{
		Item := MenuItems[A_Index]
		Menu, MyMenu, add, %Item%, MenuAction
	}
	Menu, MyMenu, Show ,%A_CaretX%,%A_CaretY%
	Menu, MyMenu, DeleteAll
}

MenuAction:
	InsertText := StrSplit(A_ThisMenuItem, "|")
	TextOut := StrReplace(RTrim(InsertText[1]), "&")
	SendInput {raw}%TextOut%%A_EndChar%
Return

Reset:
	Send, % SubStr(A_ThisHotkey,4)
	Click, %A_CaretX%, %A_CaretY%
	Send, % A_EndChar
Return

Edit:
	Gui, Hotstring:+OwnDialogs
	If !(SelectedRow := LV_GetNext()) {
		MsgBox, 0, %A_ThisLabel%, Select a row in the list-view, please!
		Return
	}
	LV_GetText(Options, SelectedRow, 1)
	LV_GetText(NewString, SelectedRow, 2)
	LV_GetText(Fun, SelectedRow, 3)
	if (Fun = "A")
	{
		SendFun := "NormalWay"
	}
	else if(Fun = "C")
	{
		SendFun := "ViaClipboard"
	}
	else if (Fun = "MC")
	{
		SendFun := "MenuText"
	}
	else if (Fun = "MA")
	{
		SendFun := "MenuTextAHK"
	}

	LV_GetText(TextInsert, SelectedRow, 5)
	LV_GetText(OnOff, SelectedRow, 4)
	Hotstring(":"Options ":" NewString,func(SendFun).bind(TextInsert),OnOff)
	HotString := % "Hotstring("":" . Options . ":" . NewString . """, func(""" . SendFun . """).bind(""" . TextInsert . """), """ . OnOff . """)"
	GuiControl,, StringCombo ,  %HotString%
	gosub, ViewString
	SetTestPad()
return

SectionChoose:
	Gui, Hotstring:Submit, NoHide
	Gui, Hotstring:+OwnDialogs

	GuiControl, Enable, Edit

	if InStr(StringCombo, "Hotstring")
		GuiControl, Enable, Save Hotstring

	LV_Delete()
	FileRead, Text, Categories2\%SectionCombo%

	SectionList := StrSplit(Text, "`r`n")
 
	Loop, % SectionList.MaxIndex()
		{
			str1 := StrSplit(SectionList[A_Index], "‖")
			LV_Add("", str1[1], str1[2], str1[3], str1[4], str1[5])
			LV_ModifyCol(2, "Sort")
		}
		LV_ModifyCol(5, "Auto")
	SendMessage, 4125, 4, 0, SysListView321
	wid := ErrorLevel
	if (wid < ColWid)
	{
		LV_ModifyCol(5, ColWid)
	}
Return

HotstringGuiSize:
	if (ErrorLevel = 1)
		return
	IniW := 1050
	IniH := 556
	LV_Width := 510
	LV_Height := 500
	LV_ModifyCol(1,70)
	LV_ModifyCol(2,100)
	LV_ModifyCol(3,40)	
	LV_ModifyCol(4,60)
	LV_ModifyCol(1,"Center")
	LV_ModifyCol(2,"Center")
	LV_ModifyCol(3,"Center")
	LV_ModifyCol(4,"Center")

	WinGetPos, PrevX, PrevY , , ,Hotstrings Edition
	PrevW := A_GuiWidth
	PrevH := A_GuiHeight

	NewHeight := LV_Height+(A_GuiHeight-IniH)
	NewWidth := LV_Width+(A_GuiWidth-IniW)
	ColWid := NewWidth-270
	LV_ModifyCol(5, "Auto")
	SendMessage, 4125, 4, 0, SysListView321
	wid := ErrorLevel
	if (wid < ColWid)
	{
		LV_ModifyCol(5, ColWid)
	}
	GuiControl, Move, HSList, W%NewWidth% H%NewHeight%

return

HotstringGuiEscape:
HotstringGuiClose:
	WinGetPos, PrevX, PrevY , , ,Hotstrings Edition
	Gui, Hotstring:Destroy
return