#Requires,               AutoHotkey v1.1.33+ 	; Displays an error and quits if a version requirement is not met.    
#SingleInstance, 		force	               ; Only one instance of this script may run at a time!
#NoEnv  						               ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  						               ; Enable warnings to assist with detecting common errors.
#LTrim						               ; Omits spaces and tabs at the beginning of each line. This is primarily used to allow the continuation section to be indented. Also, this option may be turned on for multiple continuation sections by specifying #LTrim on a line by itself. #LTrim is positional: it affects all continuation sections physically beneath it.
#KeyHistory, 			100		               ; KeyHistory for debugging purposes 
#HotkeyInterval, 		1000		               ; Specifies the rate of hotkey activations beyond which a warning dialog will be displayed. Default value = 2000 ms.
#MaxHotkeysPerInterval, 	200		               ; Specifies the rate of hotkey activations beyond which a warning dialog will be displayed. Default value = 70.
ListLines, 			On		               ; ListLines for debugging purposes
SendMode, 			Input	               ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir, 	     % A_ScriptDir	          ; Ensures a consistent starting directory.
FileEncoding, 			UTF-8	               ; with BOM. Sets the default encoding for FileRead, FileReadLine, Loop Read, FileAppend, and FileOpen(). Unicode UTF-16, little endian byte order (BMP of ISO 10646). Useful for .ini files which by default are coded as UTF-16. https://docs.microsoft.com/pl-pl/windows/win32/intl/code-page-identifiers?redirectedfrom=MSDN Warning! UTF-16 is not recognized by Notepad++ editor (2021), which recognizes correctly UCS-2 (defined by the International Standard ISO/IEC 10646). BMP = Basic Multilingual Plane.

global    TheWholeFile   := ""
     ,    RemSemicolon	:= ""
     ,    c_IconAsterisk := 64
     ,    c_Overwrite    := true
	,	f_CommTagB	:= false
	,	f_FreeTagB	:= false
	,	CommTagB		:= ";#c/*"			;commercial tag beginning
	,	CommTagE		:= ";#c*/"			;commercial tag end
	,	FreeTagB		:= ";#f/*"			;free tag beginning
	,	FreeTagE		:= ";#f*/"			;free tag end
	,	CommTagL		:= StrLen(CommTagB)		;L = length of commercial code tag
	,	FreeTagL		:= StrLen(CommTagB)		;L = length of free code tag
	,	CurrentLine	:= ""
	,	FilteredCont	:= ""				;filtered content
	,	SourceF		:= "Hotstrings.ahk"
	,	DestinationF	:= A_ScriptDir . "\filtering\HotstringsFree.ahk"

; MsgBox, % "Your AutoHotkey version:" . A_Space . A_AhkVersion  ;for debugging purposes.

if (!InStr(FileExist(A_ScriptDir . "\filtering"), "D"))
{
	FileCreateDir, % A_ScriptDir . "\filtering"
	if (ErrorLevel)
	{
		MsgBox, % c_IconAsterisk, % A_ScriptName . A_Space . "information", % "Error on time of file create dir. Exiting with exit code 3."
		ExitApp, 3
	}
}

FileCopy, % SourceF, % DestinationF, % c_Overwrite
if (ErrorLevel)
{
     MsgBox, % c_IconAsterisk, % A_ScriptName . A_Space . "information", % "Error on time of file copy. Exiting with exit code 1."
     ExitApp, 1
}

FileRead, TheWholeFile, % DestinationF
if (ErrorLevel)
{
     MsgBox, % c_IconAsterisk, % A_ScriptName . A_Space . "information", % "Error on time of file read. Exiting with exit code 2."
     ExitApp, 2
}

FileDelete, % DestinationF
if (ErrorLevel)
{
     MsgBox, % c_IconAsterisk, % A_ScriptName . A_Space . "information", % "Error on time of destination file delete prior to filtering. Exiting with exit code 4."
     ExitApp, 4
}

; Loop, Parse, TheWholeFile, `n, `r%A_Space%%A_Tab%
; {
;      temp .= A_LoopField . "`n"
; 	if (A_Index = 5)
; 		break
; }

; MsgBox, % c_IconAsterisk, % A_ScriptName . A_Space . "information", % "5 top lines:" . "`n`n"
;      . temp

Loop, Parse, TheWholeFile, `n	;, `r%A_Space%%A_Tab%
{
	if (f_FreeTagB) and (SubStr(A_LoopField, 1, FreeTagL) = FreeTagE)
	{
		f_FreeTagB 	:= false
		FilteredCont 	.= A_LoopField . "`n"
		Continue
	}
	if (f_FreeTagB)
	{
		RemSemicolon	:= StrReplace(A_LoopField, ";", "", , Limit := 1)
		; RemSemicolon	:= RegExReplace(A_LoopField, "", Replacement := "", , Limit := 1, StartingPos := 1)
		FilteredCont 	.= RemSemicolon . "`n"
		Continue
	}
	if (SubStr(A_LoopField, 1, FreeTagL) = FreeTagB)
	{
		f_FreeTagB 	:= true
		FilteredCont 	.= A_LoopField . "`n"
		Continue
	}
	if (SubStr(A_LoopField, 1, CommTagL) = CommTagB)
	{
		f_CommTagB 	:= true
		FilteredCont 	.= A_LoopField . "`n"
	}
	if (f_CommTagB) and (SubStr(A_LoopField, 1, CommTagL) = CommTagE)
	{
		f_CommTagB 	:= false
		FilteredCont 	.= A_LoopField . "`n"
		Continue
	}
	if (!f_CommTagB)
     	FilteredCont 	.= A_LoopField . "`n"
	
}
FileAppend, % FilteredCont, % DestinationF	;follows FileEncoding setting
MsgBox, % c_IconAsterisk, % A_ScriptName . A_Space . "information", % "Filtering is finished. Result is available here:"
	. "`n`n"
	. DestinationF