/*
	The purpose of this script:
	1. Create necessary files and folders within user space (A_AppData).
	2. Create necessary files and folders within "Program Files" (A_ProgramFiles).
	3. Gather basic user information (A_UserName, A_ComputerName, First and Second name of user or company name).
	4. Display to user report.
	5. Log activities.
*/
#NoEnv
#SingleInstance,    Force
SendMode,           Input
SetBatchLines,      -1
SetWorkingDir, 	%A_ScriptDir%

	c_FI_Overwrite		:= 1
,	c_MsgBoxIconError	:= 16
,	c_MsgBoxIconInfo	:= 64
,	c_MsgBoxYesNo		:= 4
,	v_AppName			:= SubStr(A_ScriptName, 1, -4)	;without file extension

MsgBox, % c_MsgBoxIconInfo + c_MsgBoxYesNo, % v_AppName, % "This file will:"
	. "`n`n"
	. "1. Create necessary files and folders within user space (A_AppData)." 									. "`n"
	. "2. Create necessary files and folders within ""Program Files"" (A_ProgramFiles)." 						. "`n"
	. "3. Gather basic user information (A_UserName, A_ComputerName, First and Second name of user or company name)." 	. "`n"
	. "4. Display to user report when finished." 														. "`n"
	. "5. Log activities into text file located in the same directory."										. "`n
	. "`n`n"
	. "Do you want to proceed?"
IfMsgBox, No
	ExitApp, 0	;All is right, exiting

; FileAppend, % TransConst, % A_ScriptDir . "\Languages\English.txt", UTF-8 
FileCreateDir, % A_AppData . "\Hotstrings"
if (ErrorLevel)
{
	MsgBox, % c_MsgBoxIconError, % v_AppName . ":" . A_Space . "error", % "The directory"
		. "`n"
		. A_AppData . "\Hotstrings"
		. "`n"
		. "was not created for some reason. Exiting."
	ExitApp, 1	;A_AppData . "\Hotstrings" is not created
}
FileAppend, "Created or overwritten folder name:" . A_Space . A_AppData . "\Hotstrings" . "`n", % v_AppName . "_Log.txt"
FileCreateDir, % A_AppData . "\Hotstrings\Log"
if (ErrorLevel)
{
	MsgBox, % c_MsgBoxIconError, % v_AppName . ":" . A_Space . "error", % "The directory"
		. "`n"
		. A_AppData . "\Hotstrings\Log"
		. "`n"
		. "was not created for some reason. Exiting."
	ExitApp, 2	;A_AppData . "\Hotstrings\Log" is not created
}
FileAppend, "Created or overwritten folder name:" . A_Space . A_AppData . "\Hotstrings\Log" . "`n", % v_AppName . "_Log.txt"

FileCreateDir, % A_ProgramFiles . ""

FileCreateDir, % A_ScriptDir . "\Languages"	;tu jestem. Tu powinien powstac folder w Program Files
if (ErrorLevel)
{
	MsgBox, % c_MsgBoxIconError, % v_AppName . ":" . A_Space . "error", % "The directory"
		. "`n"
		. A_ScriptDir . "\Languages"
		. "`n"
		. "was not created for some reason. Exiting."
	ExitApp, 3	;A_ScriptDir . "\Languages" is not created
}

FileInstall, C:\Users\macie\Documents\GitHub\Hotstrings\Languages\English.txt,				% A_ScriptDir . "\Languages\English.txt",		% c_FI_Overwrite
if (ErrorLevel)
{
	MsgBox, % c_MsgBoxIconError, % v_AppName . ":" . A_Space . "error", % "The file"
		. "`n"
		. A_AppData . "\Hotstrings\Languages\English.txt"
		. "`n"
		. "was not installed for some reason. Exiting."
	ExitApp, 3	;A_AppData . "\Hotstrings\Languages\English.txt" is not created
}

FileInstall, hotstrings.ico, 														hotstrings.ico, 						% c_FI_Overwrite
FileInstall, LICENSE_EULA.md, 													LICENSE_EULA.md,						% c_FI_Overwrite
; FileInstall, C:\Users\macie\AppData\Roaming\Hotstrings\Libraries\AbbreviationsEnglish.csv		, % A_AppData . "\Hotstring\Libraries\",	% c_FI_Overwrite	;1
; FileInstall, C:\Users\macie\AppData\Roaming\Hotstrings\Libraries\AutocorrectionHotstrings.csv	, % A_AppData . "\Hotstring\Libraries\",	% c_FI_Overwrite	;2	
; FileInstall, C:\Users\macie\AppData\Roaming\Hotstrings\Libraries\BoxDrawing.csv 			, % A_AppData . "\Hotstring\Libraries\",	% c_FI_Overwrite	;3
; FileInstall, C:\Users\macie\AppData\Roaming\Hotstrings\Libraries\BrandAndProperNames.csv 		, % A_AppData . "\Hotstring\Libraries\",	% c_FI_Overwrite	;4
; FileInstall, C:\Users\macie\AppData\Roaming\Hotstrings\Libraries\CapitalLetters.csv 			, % A_AppData . "\Hotstring\Libraries\",	% c_FI_Overwrite	;5
; FileInstall, C:\Users\macie\AppData\Roaming\Hotstrings\Libraries\CircledNumbers.csv 			, % A_AppData . "\Hotstring\Libraries\",	% c_FI_Overwrite	;6
; FileInstall, C:\Users\macie\AppData\Roaming\Hotstrings\Libraries\DiacriticsHotstrings.csv 	, % A_AppData . "\Hotstring\Libraries\",	% c_FI_Overwrite	;7	
; FileInstall, C:\Users\macie\AppData\Roaming\Hotstrings\Libraries\EmojiHotstrings.csv 		, % A_AppData . "\Hotstring\Libraries\",	% c_FI_Overwrite	;8
; FileInstall, C:\Users\macie\AppData\Roaming\Hotstrings\Libraries\Examples_TestLib.csv 		, % A_AppData . "\Hotstring\Libraries\",	% c_FI_Overwrite	;9
; FileInstall, C:\Users\macie\AppData\Roaming\Hotstrings\Libraries\Fileformats.csv 			, % A_AppData . "\Hotstring\Libraries\",	% c_FI_Overwrite	;10
; FileInstall, C:\Users\macie\AppData\Roaming\Hotstrings\Libraries\Finance.csv 				, % A_AppData . "\Hotstring\Libraries\",	% c_FI_Overwrite	;11
; FileInstall, C:\Users\macie\AppData\Roaming\Hotstrings\Libraries\FirstNameCapitalizer.csv 	, % A_AppData . "\Hotstring\Libraries\",	% c_FI_Overwrite	;12
; FileInstall, C:\Users\macie\AppData\Roaming\Hotstrings\Libraries\FunctionKeys.csv 			, % A_AppData . "\Hotstring\Libraries\",	% c_FI_Overwrite	;13
; FileInstall, C:\Users\macie\AppData\Roaming\Hotstrings\Libraries\Markdown.csv 				, % A_AppData . "\Hotstring\Libraries\",	% c_FI_Overwrite	;14
; FileInstall, C:\Users\macie\AppData\Roaming\Hotstrings\Libraries\PhysicsHotstrings.csv 		, % A_AppData . "\Hotstring\Libraries\",	% c_FI_Overwrite	;15
; FileInstall, C:\Users\macie\AppData\Roaming\Hotstrings\Libraries\punctuation.csv 			, % A_AppData . "\Hotstring\Libraries\",	% c_FI_Overwrite	;16
; FileInstall, C:\Users\macie\AppData\Roaming\Hotstrings\Libraries\TimeHotstrings.csv 			, % A_AppData . "\Hotstring\Libraries\",	% c_FI_Overwrite	;17

FileInstall, C:\Users\macie\AppData\Roaming\Hotstrings\Config.ini,						% A_AppData . "\Hotstrings\Config.ini",		% c_FI_Overwrite