;Purpose of this script:
; 1. "Libraries" for Hotstrings app (by ATC = Academy Training Center):
; 1.1. Prepare subfolder if it do not exist in AppData subfolder (private area of specific Microsoft Windows user).
; 1.2. Do SVN checkout to this specific subfolder (once).
; 1.3. Do SVN update to this specific subfolder (run once per each restart of pc).
;
; 2. Hotstrings application:
; 2.1. Prepare subfolder if it do not exist in Program Files subfolder.
; 2.2. Do SVN checkout to this specific subfolder (once).
; 2.3. Do SVN update to this specific subfolder (run once per each restart of pc).
;
; 3. Add to Autostart link to this specific script in order to update SVN repository (application and Libraries) each restart of Microsoft Windows. 
; Prepared by Maciej S³ojewski on 2021-06-16.

#Requires AutoHotkey v1.1.33+ 	; Displays an error and quits if a version requirement is not met.    
#SingleInstance force 			; Only one instance of this script may run at a time!
#NoEnv  						; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  						; Enable warnings to assist with detecting common errors.
#LTrim						; Omits spaces and tabs at the beginning of each line. This is primarily used to allow the continuation section to be indented. Also, this option may be turned on for multiple continuation sections by specifying #LTrim on a line by itself. #LTrim is positional: it affects all continuation sections physically beneath it.
SendMode Input  				; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%		; Ensures a consistent starting directory.

ApplicationName := "Hotstrings"
LocalRepoOfLibraries := A_AppData . "\" . ApplicationName . "\" . "Libraries"
LocalRepoOfScript := A_ProgramFiles . "\" . ApplicationName
SVNlinkLibraries := "https://svn.tens.pl/CompanyTemplates/AutoHotKeyScripts/Hotstrings/Libraries"
SVNlinkScript := "https://svn.tens.pl/CompanyTemplates/AutoHotKeyScripts/Hotstrings"
LinkFile	:= A_Startup . "\" . SubStr(A_ScriptName, 1, -4) . "." . "lnk"
WorkingDir 	:= A_ScriptDir
Description 	:= "Enables automatic update of SVN repositiories on OS startup for purpose of Hotstrings app" . "."
Target 		:= A_ScriptFullPath
CheckoutToScript := "c:\temp2" ;for test purposes only


;Prepare directory for script / application
if (!Instr(FileExist(LocalRepoOfScript), "D"))				; if  there is no such folder 
{
	FileCreateDir, %LocalRepoOfScript%	;Future: check against errors
	MsgBox, 48, % SubStr(A_ScriptName, 1, -4) .  ":" . A_Space . "warning", % "There was no" . "`n" . LocalRepoOfScript . "`n" . ", so now it is created."
}

;Checkout the script / application
if (!FileExist(CheckoutTo . "\" . ApplicationName . ".ahk"))
	Run, SVN checkout --depth files %SVNlinkScript% %LocalRepoOfScript%

;Update script / application
Run, SVN update %LocalRepoOfScript%



;Prepare directory for libraries.
if (!Instr(FileExist(LocalRepoOfLibraries), "D"))				; if  there is no such folder 
{
	FileCreateDir, %LocalRepoOfLibraries%	;Future: check against errors
	MsgBox, 48, % SubStr(A_ScriptName, 1, -4) .  ":" . A_Space . "warning", % "There was no" . "`n" . LocalRepoOfLibraries . "`n" . ", so now it is created."
}
	
;Checkout the Libraries
if (!FileExist(LocalRepoOfLibraries . "\" . "Abbreviations" . ".ahk"))
	Run, SVN checkout --depth files %SVNlinkLibraries% %LocalRepoOfLibraries%

;Update libraries
Run, SVN update %LocalRepoOfLibraries%

;Add link to autostart, Libraries AND application
if (!FileExist(LinkFile))
	FileCreateShortcut, % Target, % LinkFile, , , % Description, , , , 7 ; 7 = Minimized

Exit, 0	;on success