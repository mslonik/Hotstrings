#Requires,               AutoHotkey v1.1.35+ 	; Displays an error and quits if a version requirement is not met.    
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
FileEncoding, 			UTF-8	               ; Sets the default encoding for FileRead, FileReadLine, Loop Read, FileAppend, and FileOpen(). Unicode UTF-16, little endian byte order (BMP of ISO 10646). Useful for .ini files which by default are coded as UTF-16. https://docs.microsoft.com/pl-pl/windows/win32/intl/code-page-identifiers?redirectedfrom=MSDN Warning! UTF-16 is not recognized by Notepad++ editor (2021), which recognizes correctly UCS-2 (defined by the International Standard ISO/IEC 10646). BMP = Basic Multilingual Plane.

global    TheWholeFile   := ""
     ,    temp           := ""

FileCopy, Hotstrings.ahk, % "..\" . A_ScriptDir . "\filtering\HotstringsFree.ahk", 1

FileRead, TheWholeFile, % "..\" . A_ScriptDir . "\filtering\HotstringsFree.ahk"

Loop, Parse, TheWholeFile, `n, `r%A_Space%%A_Tab%
     Loop, 5
          temp := A_LoopField . "`n"

MsgBox, 64, % A_ScriptName, % "5 top lines:" . "`n`n"
     . temp

; Loop, Parse, TheWholeFile, `n, `r%A_Space%%A_Tab%
; {
; 	if (SubStr(A_LoopField, 1, 2) = "/*")	;ignore comments
; 	{
; 		BegCom := true
; 		Continue
; 	}
; 	if (BegCom) and (SubStr(A_LoopField, -1) = "*/") ;ignore comments
; 	{
; 		BegCom := false
; 		Continue
; 	}
; 	if (BegCom)
; 		Continue
; 	if (SubStr(A_LoopField, 1, 1) = ";")	;ignore comments
; 		Continue
; 	if (!A_LoopField)	;ignore empty lines
; 		Continue
	
;      LibFileBody .= A_LoopField . "`n"
; }
; TheWholeFile := "/*" . "`n" . LibraryHeader . "`n" . "*/" . "`n" . LibFileBody
; FileDelete, % ini_HADL . "\" . SelectedLibraryName
; FileAppend, % TheWholeFile, % ini_HADL . "\" . SelectedLibraryName, UTF-8
