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
,	v_Temp			:= ""
,	c_ASCII_NewLine 	:= "`%0A"
,	c_ASCII_HorTab 	:= "`%09"
,	c_ASCII_Space		:= "`%20"
,	v_EmailMsgBox		:= false

; - - - - - - - - - - - - - - - - - - - - - - - E X E  CONVERSION / INSTALLATOR S E C T I O N - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
global AppVersion				:= "0.9.9"
;@Ahk2Exe-Let vAppVersion=%A_PriorLine~U)^(.+"){1}(.+)".*$~$2% ; Keep these lines together
;@Ahk2Exe-SetMainIcon imageres_5303.ico
;@Ahk2Exe-SetCompanyName © by Maciej Słojewski http://mslonik.pl
;@Ahk2Exe-SetCopyright License: EULA
;@Ahk2Exe-SetDescription Preinstaller for Hotstrings application.
;@Ahk2Exe-SetFileVersion %U_vAppVersion% 
;@Ahk2Exe-SetInternalName Hotstrings Preinstaller
;@Ahk2Exe-SetLanguage 0x0409
;@Ahk2Exe-SetLegalTrademarks Personal license: Maciej Słojewski
;@Ahk2Exe-SetName Hotstrings Preinstaller
;@Ahk2Exe-SetOrigFilename Commercial release
;@Ahk2Exe-SetProductName Hotstrings Preinstaller
;@Ahk2Exe-SetProductVersion %U_vAppVersion% 
;@Ahk2Exe-SetVersion %U_vAppVersion% 


MsgBox, % c_MsgBoxIconInfo + c_MsgBoxYesNo, % v_AppName, % "This file will:"
	. "`n`n"
	. "1. Create necessary files and folders within user space (AppData)." 										. "`n`n"
	. "2. Create necessary files and folders within ""Program Files""."				 							. "`n`n"
	. "3. Gather basic user information (logon user name, computer name, First and Second name of user or company name) and composes e-mail." 	. "`n`n"
	. "4. Display on screen report when finished." 															. "`n`n"
	. "The script requires Administrative rights in order to create folder within ""Program Files"" folder."				. "`n`n"
	. "All actions are logged into text file located in the file directory."										. "`n"
	. "`n"
	. "Do you want to proceed?"
IfMsgBox, No
	ExitApp, 0	;All is right, exiting

FileDelete, % v_AppName . "_Log.txt"	;Delete any previous log file.
if (!A_IsAdmin)
	{
		MsgBox, % c_MsgBoxIconInfo + c_MsgBoxYesNo, % v_AppName, % "Application wasn't run with Administrative privileges."
			. "`n"
			. "Do you agree to restart it with administrative right?"
		IfMsgBox, Yes
		{
			try	;in order to catch exception
			{
				Run *RunAs "%A_ScriptFullPath%" /restart
			}
			ExitApp, 0	;All is right, exiting
		}
	}

;1. Create necessary files and folders within user space (AppData)
v_Temp := A_AppData . "\Hotstrings"
FileCreateDir, % v_Temp
F_CheckError("D", v_Temp, 1)
FileAppend, % A_YYYY . "-" . A_MM . "-" . A_DD . A_Space . A_Hour . ":" . A_Min . ":" . A_Sec . A_Space . "Created folder name:" . A_Space . v_Temp . "`n", % v_AppName . "_Log.txt"

v_Temp := A_AppData . "\Hotstrings\Log"
FileCreateDir, % v_Temp
F_CheckError("D", v_Temp, 2)
FileAppend, % A_YYYY . "-" . A_MM . "-" . A_DD . A_Space . A_Hour . ":" . A_Min . ":" . A_Sec . A_Space . "Created folder name:" . A_Space . v_Temp . "`n", % v_AppName . "_Log.txt"

v_Temp := A_AppData . "\Hotstrings\Libraries"
FileCreateDir, % v_Temp
F_CheckError("D", v_Temp, 3)
FileAppend, % A_YYYY . "-" . A_MM . "-" . A_DD . A_Space . A_Hour . ":" . A_Min . ":" . A_Sec . A_Space . "Created folder name:" . A_Space . v_Temp . "`n", % v_AppName . "_Log.txt"

v_Temp := A_AppData . "\Hotstrings\Libraries\AbbreviationsEnglish.csv"
FileInstall, C:\Users\macie\Documents\GitHub\Hotstrings-Libraries\AbbreviationsEnglish.csv, 	% v_Temp,		% c_FI_Overwrite	;1
F_CheckError("F", v_Temp, 4)
FileAppend, % A_YYYY . "-" . A_MM . "-" . A_DD . A_Space . A_Hour . ":" . A_Min . ":" . A_Sec . A_Space . "Created or overwritten file name:" . A_Space . v_Temp . "`n", % v_AppName . "_Log.txt"

v_Temp := A_AppData . "\Hotstrings\Libraries\AutocorrectionHotstrings.csv"
FileInstall, C:\Users\macie\Documents\GitHub\Hotstrings-Libraries\AutocorrectionHotstrings.csv, % v_Temp,	% c_FI_Overwrite	;2	
F_CheckError("F", v_Temp, 4)
FileAppend, % A_YYYY . "-" . A_MM . "-" . A_DD . A_Space . A_Hour . ":" . A_Min . ":" . A_Sec . A_Space . "Created or overwritten file name:" . A_Space . v_Temp . "`n", % v_AppName . "_Log.txt"

v_Temp := A_AppData . "\Hotstrings\Libraries\BoxDrawing.csv"
FileInstall, C:\Users\macie\Documents\GitHub\Hotstrings-Libraries\BoxDrawing.csv 			, % v_Temp, % c_FI_Overwrite	;3
F_CheckError("F", v_Temp, 4)
FileAppend, % A_YYYY . "-" . A_MM . "-" . A_DD . A_Space . A_Hour . ":" . A_Min . ":" . A_Sec . A_Space . "Created or overwritten file name:" . A_Space . v_Temp . "`n", % v_AppName . "_Log.txt"

v_Temp := A_AppData . "\Hotstrings\Libraries\BrandAndProperNames.csv"
FileInstall, C:\Users\macie\Documents\GitHub\Hotstrings-Libraries\BrandAndProperNames.csv 	, % v_Temp, % c_FI_Overwrite	;4
F_CheckError("F", v_Temp, 4)
FileAppend, % A_YYYY . "-" . A_MM . "-" . A_DD . A_Space . A_Hour . ":" . A_Min . ":" . A_Sec . A_Space . "Created or overwritten file name:" . A_Space . v_Temp . "`n", % v_AppName . "_Log.txt"

v_Temp := A_AppData . "\Hotstrings\Libraries\CapitalLetters.csv"
FileInstall, C:\Users\macie\Documents\GitHub\Hotstrings-Libraries\CapitalLetters.csv 		, % v_Temp, % c_FI_Overwrite	;5
F_CheckError("F", v_Temp, 4)
FileAppend, % A_YYYY . "-" . A_MM . "-" . A_DD . A_Space . A_Hour . ":" . A_Min . ":" . A_Sec . A_Space . "Created or overwritten file name:" . A_Space . v_Temp . "`n", % v_AppName . "_Log.txt"

v_Temp := A_AppData . "\Hotstrings\Libraries\CircledNumbers.csv"
FileInstall, C:\Users\macie\Documents\GitHub\Hotstrings-Libraries\CircledNumbers.csv 		, % v_Temp, % c_FI_Overwrite	;6
F_CheckError("F", v_Temp, 4)
FileAppend, % A_YYYY . "-" . A_MM . "-" . A_DD . A_Space . A_Hour . ":" . A_Min . ":" . A_Sec . A_Space . "Created or overwritten file name:" . A_Space . v_Temp . "`n", % v_AppName . "_Log.txt"

v_Temp := A_AppData . "\Hotstrings\Libraries\DiacriticsHotstrings.csv"
FileInstall, C:\Users\macie\Documents\GitHub\Hotstrings-Libraries\DiacriticsHotstrings.csv  	, % v_Temp, % c_FI_Overwrite	;7	
F_CheckError("F", v_Temp, 4)
FileAppend, % A_YYYY . "-" . A_MM . "-" . A_DD . A_Space . A_Hour . ":" . A_Min . ":" . A_Sec . A_Space . "Created or overwritten file name:" . A_Space . v_Temp . "`n", % v_AppName . "_Log.txt"

v_Temp := A_AppData . "\Hotstrings\Libraries\EmojiHotstrings.csv"
FileInstall, C:\Users\macie\Documents\GitHub\Hotstrings-Libraries\EmojiHotstrings.csv  		, % v_Temp, % c_FI_Overwrite	;8
F_CheckError("F", v_Temp, 4)
FileAppend, % A_YYYY . "-" . A_MM . "-" . A_DD . A_Space . A_Hour . ":" . A_Min . ":" . A_Sec . A_Space . "Created or overwritten file name:" . A_Space . v_Temp . "`n", % v_AppName . "_Log.txt"

v_Temp := A_AppData . "\Hotstrings\Libraries\Examples_TestLib.csv"
FileInstall, C:\Users\macie\Documents\GitHub\Hotstrings-Libraries\Examples_TestLib.csv  		, % v_Temp, % c_FI_Overwrite	;9
F_CheckError("F", v_Temp, 4)
FileAppend, % A_YYYY . "-" . A_MM . "-" . A_DD . A_Space . A_Hour . ":" . A_Min . ":" . A_Sec . A_Space . "Created or overwritten file name:" . A_Space . v_Temp . "`n", % v_AppName . "_Log.txt"

v_Temp := A_AppData . "\Hotstrings\Libraries\Fileformats.csv"
FileInstall, C:\Users\macie\Documents\GitHub\Hotstrings-Libraries\Fileformats.csv 			, % v_Temp, % c_FI_Overwrite	;10
F_CheckError("F", v_Temp, 4)
FileAppend, % A_YYYY . "-" . A_MM . "-" . A_DD . A_Space . A_Hour . ":" . A_Min . ":" . A_Sec . A_Space . "Created or overwritten file name:" . A_Space . v_Temp . "`n", % v_AppName . "_Log.txt"

v_Temp := A_AppData . "\Hotstrings\Libraries\Finance.csv"
FileInstall, C:\Users\macie\Documents\GitHub\Hotstrings-Libraries\Finance.csv 				, % v_Temp, % c_FI_Overwrite	;11
F_CheckError("F", v_Temp, 4)
FileAppend, % A_YYYY . "-" . A_MM . "-" . A_DD . A_Space . A_Hour . ":" . A_Min . ":" . A_Sec . A_Space . "Created or overwritten file name:" . A_Space . v_Temp . "`n", % v_AppName . "_Log.txt"

v_Temp := A_AppData . "\Hotstrings\Libraries\FirstNameCapitalizer.csv"
FileInstall, C:\Users\macie\Documents\GitHub\Hotstrings-Libraries\FirstNameCapitalizer.csv 	, % v_Temp, % c_FI_Overwrite	;12
F_CheckError("F", v_Temp, 4)
FileAppend, % A_YYYY . "-" . A_MM . "-" . A_DD . A_Space . A_Hour . ":" . A_Min . ":" . A_Sec . A_Space . "Created or overwritten file name:" . A_Space . v_Temp . "`n", % v_AppName . "_Log.txt"

v_Temp := A_AppData . "\Hotstrings\Libraries\FunctionKeys.csv"
FileInstall, C:\Users\macie\Documents\GitHub\Hotstrings-Libraries\FunctionKeys.csv 			, % v_Temp, % c_FI_Overwrite	;13
F_CheckError("F", v_Temp, 4)
FileAppend, % A_YYYY . "-" . A_MM . "-" . A_DD . A_Space . A_Hour . ":" . A_Min . ":" . A_Sec . A_Space . "Created or overwritten file name:" . A_Space . v_Temp . "`n", % v_AppName . "_Log.txt"

v_Temp := A_AppData . "\Hotstrings\Libraries\Markdown.csv"
FileInstall, C:\Users\macie\Documents\GitHub\Hotstrings-Libraries\Markdown.csv 				, % v_Temp, % c_FI_Overwrite	;14
F_CheckError("F", v_Temp, 4)
FileAppend, % A_YYYY . "-" . A_MM . "-" . A_DD . A_Space . A_Hour . ":" . A_Min . ":" . A_Sec . A_Space . "Created or overwritten file name:" . A_Space . v_Temp . "`n", % v_AppName . "_Log.txt"

v_Temp := A_AppData . "\Hotstrings\Libraries\PhysicsHotstrings.csv"
FileInstall, C:\Users\macie\Documents\GitHub\Hotstrings-Libraries\PhysicsHotstrings.csv 		, % v_Temp, % c_FI_Overwrite	;15
F_CheckError("F", v_Temp, 4)
FileAppend, % A_YYYY . "-" . A_MM . "-" . A_DD . A_Space . A_Hour . ":" . A_Min . ":" . A_Sec . A_Space . "Created or overwritten file name:" . A_Space . v_Temp . "`n", % v_AppName . "_Log.txt"

v_Temp := A_AppData . "\Hotstrings\Libraries\punctuation.csv"
FileInstall, C:\Users\macie\Documents\GitHub\Hotstrings-Libraries\punctuation.csv 			, % v_Temp, % c_FI_Overwrite	;16
F_CheckError("F", v_Temp, 4)
FileAppend, % A_YYYY . "-" . A_MM . "-" . A_DD . A_Space . A_Hour . ":" . A_Min . ":" . A_Sec . A_Space . "Created or overwritten file name:" . A_Space . v_Temp . "`n", % v_AppName . "_Log.txt"

v_Temp := A_AppData . "\Hotstrings\Libraries\TimeHotstrings.csv"
FileInstall, C:\Users\macie\Documents\GitHub\Hotstrings-Libraries\TimeHotstrings.csv 		, % v_Temp, % c_FI_Overwrite	;17
F_CheckError("F", v_Temp, 4)
FileAppend, % A_YYYY . "-" . A_MM . "-" . A_DD . A_Space . A_Hour . ":" . A_Min . ":" . A_Sec . A_Space . "Created or overwritten file name:" . A_Space . v_Temp . "`n", % v_AppName . "_Log.txt"

; 2. Create necessary files and folders within ""Program Files"".
v_Temp := A_ProgramFiles . "\Hotstrings"
FileCreateDir, % v_Temp
F_CheckError("D", v_Temp, 5)
FileAppend, % A_YYYY . "-" . A_MM . "-" . A_DD . A_Space . A_Hour . ":" . A_Min . ":" . A_Sec . A_Space . "Created folder name:" . A_Space . v_Temp . "`n", % v_AppName . "_Log.txt"

v_Temp := A_ProgramFiles . "\Hotstrings\Languages"
FileCreateDir, % v_Temp
F_CheckError("D", v_Temp, 6)
FileAppend, % A_YYYY . "-" . A_MM . "-" . A_DD . A_Space . A_Hour . ":" . A_Min . ":" . A_Sec . A_Space .  "Created folder name:" . A_Space . v_Temp . "`n", % v_AppName . "_Log.txt"

v_Temp := A_ProgramFiles . "\Hotstrings\Languages\English.txt"
FileInstall, C:\Users\macie\Documents\GitHub\Hotstrings\Languages\English.txt,				% v_Temp,	% c_FI_Overwrite
F_CheckError("F", v_Temp, 4)
FileAppend, % A_YYYY . "-" . A_MM . "-" . A_DD . A_Space . A_Hour . ":" . A_Min . ":" . A_Sec . A_Space .  "Created or overwritten file name:" . A_Space . v_Temp . "`n", % v_AppName . "_Log.txt"

v_Temp := A_ProgramFiles . "\Hotstrings\LICENSE_EULA.md"
FileInstall, LICENSE_EULA.md, 													% v_Temp,	% c_FI_Overwrite
F_CheckError("F", v_Temp, 4)
FileAppend, % A_YYYY . "-" . A_MM . "-" . A_DD . A_Space . A_Hour . ":" . A_Min . ":" . A_Sec . A_Space .  "Created or overwritten file name:" . A_Space . v_Temp . "`n", % v_AppName . "_Log.txt"

v_Temp := A_ProgramFiles . "\Hotstrings\Config.ini"
FileInstall, C:\Users\macie\AppData\Roaming\Hotstrings\Config.ini,						% v_Temp,	% c_FI_Overwrite
F_CheckError("F", v_Temp, 4)
FileAppend, % A_YYYY . "-" . A_MM . "-" . A_DD . A_Space . A_Hour . ":" . A_Min . ":" . A_Sec . A_Space .  "Created or overwritten file name:" . A_Space . v_Temp . "`n", % v_AppName . "_Log.txt"

; 3. Gather basic user information (logon user name, computer name, First and Second name of user or company name).
Run, % "mailto:service@hotstrings.com?subject=Request for Hotstrings trial version&body="
	. "Logon user name:" 	. c_ASCII_HorTab . A_UserName 	. c_ASCII_NewLine
	. "Computer name:" 		. c_ASCII_HorTab . A_ComputerName 	. c_ASCII_NewLine
	. "First and second name of license owner or company name (please fill in manually):" . c_ASCII_Space .  c_ASCII_NewLine . c_ASCII_NewLine
	. "This e-mail will be processed as soon as possible, within ~1 working day (24 hours). Nevertheless please be patient." . c_ASCII_NewLine . c_ASCII_NewLine
	. "The proud Hotstrings team and Maciej Slojewski", , UseErrorLevel
if (ErrorLevel = "ERROR")
{
	v_EmailMsgBox := true
	MsgBox, % c_MsgBoxIconError, % v_AppName . A_Space . "error", % "Something went wrong, e-mail client wasn't found?" . "`n`n"
		. "Please prepare it manually: press Ctrl + C, open your e-mail application and press Ctrl + V." . "`n`n"
		. "To:" . A_Tab . "service@hotstrings.com" 	. "`n"
		. "Logon user name:" . A_Tab . A_UserName 	. "`n"
		. "Computer name:" 	. A_Tab . A_ComputerName . "`n"
		. "First and second name of license owner or company name (please fill in manually):" . A_Space . "`n`n"
		. "This e-mail will be processed as soon as possible, within ~1 working day (24 hours). Nevertheless please be patient."
}
FileAppend, % A_YYYY . "-" . A_MM . "-" . A_DD . A_Space . A_Hour . ":" . A_Min . ":" . A_Sec . A_Space . "Logon user name:" . A_Space . A_UserName . "`n"
		.   A_YYYY . "-" . A_MM . "-" . A_DD . A_Space . A_Hour . ":" . A_Min . ":" . A_Sec . A_Space . "Computer name:" . A_Space . A_ComputerName
		, % v_AppName . "_Log.txt"

; 4. Display report.
MsgBox, % c_MsgBoxIconInfo, % v_AppName, % "Mission accomplished!"
	. "`n`n"
	. "1. Created necessary files and folders within user space (AppData): ☑"	. "`n`n"
	. "2. Created necessary files and folders within ""Program Files"": ☑"	. "`n`n"
	. "3. Gather basic user information and composed e-mail: ☑" 			. "`n`n"
	. "That's it! Please send the e-mail immediately."					. "`n`n"
	. "You can read log of activities here:"							. "`n"
	. A_ScriptDir . "\" . v_AppName . "_Log.txt"

; - - - - - - - S E C T I O N  O F  F U N C T I O N S - - - - - - - - - - - - - - - - - - - - - 
F_CheckError(FileOrDirectory, path, ErrorNo)
{
	global	;assume-global mode of operation
	local	temp := ""

	Switch FileOrDirectory
	{
		Case "D":	temp := "directory"
		Case "F":	temp := "file"
	}
	if (ErrorLevel)
	{
		MsgBox, % c_MsgBoxIconError, % v_AppName . ":" . A_Space . "error", % "The " . temp
			. "`n"
			. path
			. "`n"
			. "was not created for some reason. Exiting."
		ExitApp, % ErrorNo
	}
}