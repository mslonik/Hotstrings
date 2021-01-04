/*
	Author:      Jakub Masiak, Maciej Słojewski (mslonik, http://mslonik.pl)
	Purpose:     Facilitate maintenance of (triggerstring, hotstring) concept.
	Description: Hotstrings as in AutoHotkey (shortcuts), but editable with GUI and many more options.
	License:     GNU GPL v.3
*/

; -----------Beginning of auto-execute section of the script

#Requires AutoHotkey v1.1.33+ 
#SingleInstance force 			; only one instance of this script may run at a time!
#NoEnv  						; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  							; Enable warnings to assist with detecting common errors.
SendMode Input  				; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%		; Ensures a consistent starting directory.

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
TipsSortAlphatebically=1
TipsSortByLength=1
Language=English.ini
[TipsLibraries]
)
	FileAppend, %ini%, Config.ini
	MsgBox, Config.ini wasn't found. The default Config.ini is now created.
}

; - - - - - - - - LOCALIZATION OPTIONS - - - - - - -

global v_Language 		:= ""
global v_LanguageFile 	:= ""

IniRead, v_Language, Config.ini, Configuration, Language
v_LanguageFile := % "Languages/" . v_Language
if !(FileExist(v_LanguageFile))
{
    v_Language := "English.ini"
    v_LanguageFile := "Languages/English.ini"
    IniWrite, %v_Language%, Config.ini, Configuration, Language
    if !(FileExist(v_LanguageFile))
    {
        MsgBox, 0x30,, ERROR!`nThere is no English.ini file.
    }
}
global t_EditHotstring,t_SearchHotstrings, t_LoadingHotstringsFromLibraries, t_HotstringsHaveBeenLoaded, t_ErrorLevelWasTriggeredByNewInputError, t_UndoTheLastHotstring, t_SelectHotstringLibrary, t_LibraryImportPleaseWait, t_LoadingLibrariesPleaseWait, t_LibraryHasBeenImported, t_SelectedFileIsEmpty, t_LibraryExportPleaseWait, t_LibraryHasBeenExported, t_ThePathFileIs, t_EnterTriggerstring, t_SelectTriggerOptions, t_ImmediateExecute, t_CaseSensitive, t_NoBackspace, t_InsideWord, t_NoEndChar, t_Disable, t_SelectHotstringOutputFunction, t_EnterHotstring, t_AddAComment, t_AddLibrary, t_SetHotstring, t_Clear, t_DeleteHotstring, t_Sandbox, t_TriggerstringTriggOptOutFunEnDisHotstringComment, t_F1AboutHelpF2LibraryContentF3SearchHotstringsF5ClearF7ClipboardDelayF8DeleteHotstringF9SetHotstring, t_LoadedHotstrings, t_UndoLastHotstring, t_EnableDisable, t_Caret, t_Cursor, t_ChooseMenuPosition, t_EnableSoundIfOverrun, t_HotstringMenuMSIMCL, t_TriggerstringTips, t_ChooseTipsLocation, t_NumberOfCharactersForTips, t_SortTipsAlphabetically, t_SortTipsByLength, t_SaveWindowPosition, t_LaunchSandbox, t_Space, t_Minus, t_OpeningRoundBracket, t_ClosingRoundBracket, t_OpeningSquareBracket, t_ClosingSquareBracket, t_OpeningCurlyBracket, t_ClosingCurlyBracket, t_Colon, t_Semicolon, t_Apostrophe, t_Apostrophe, t_Quote, t_Slash, t_Backslash, t_Comma, t_Dot, t_QuestionMark, t_ExclamationMark, t_Enter, t_Tab, t_ToggleEndChars, t_Configuration, t_SearchHotstrings, t_ImportFromAhkToCsv, t_StaticHotstrings, t_DynamicHotstrings, t_ExportFromCsvToAhk, t_EnableDisableTriggerstringTips, t_LibrariesConfiguration, t_ClipboardDelay, t_AboutHelp, t_ReplacementTextIsBlankDoYouWantToProceed, t_ChooseSendingFunction, t_ChooseSectionBeforeSaving, t_ChooseTheMethodOfSendingTheHotstring, t_EnterANameForTheNewLibrary, t_Cancel, t_TheLibrary, t_HasBeenCreated, t_ALibraryWithThatNameAlreadyExists, t_TheHostring, t_ExistsInAFile, t_CsvDoYouWantToProceed, t_SelectARowInTheListViewPlease, t_SelectedHotstringWillBeDeletedDoYouWantToProceed, t_DeletingHotstring, t_DeletingHotstringPleaseWait, t_HotstringHasBeenDeletedNowApplicationWillRestartItselfInOrderToApplyChangesReloadTheLibrariesCsv, t_HotstringPasteFromClipboardDelay1s, t_HotstringPasteFromClipboardDelay, t_LetsMakeYourPCPersonalAgain, t_EnablesConvenientDefinitionAndUseOfHotstringsTriggeredByShortcutsLongerTextStringsThisIs3rdEditionOfThisApplication2020ByJakubMasiakAndMaciejSlojewskiLicenseGNUGPLVer3, t_ApplicationHelp, t_GenuineHotstringsAutoHotkeyDocumentation, t_PleaseWaitUploadingCsvFiles, t_SearchBy, t_Triggerstring, t_Hotstring, t_Library, t_Move, t_LibraryTriggerstringTriggerOptionsOutputFunctionEnableDisableHotstringComment, t_F3CloseSearchHotstringsF8MoveHotstring, t_SelectTheTargetLibrary, t_HotstringMovedToThe, t_File, t_ChooseLibraryFileAhkForImport, t_ChooseLibraryFileCsvForExport, t_ChangeLanguage, t_ApplicationLanguageChangedTo, t_TheApplicationWillBereloadedWithTheNewLanguageFile
t_EditHotstring := F_ReadText("t_EditHotstring")
t_SearchHotstrings := F_ReadText("t_SearchHotstrings")
t_LoadingHotstringsFromLibraries := F_ReadText("t_LoadingHotstringsFromLibraries")
t_HotstringsHaveBeenLoaded := F_ReadText("t_HotstringsHaveBeenLoaded")
t_ErrorLevelWasTriggeredByNewInputError := F_ReadText("t_ErrorLevelWasTriggeredByNewInputError")
t_UndoTheLastHotstring := F_ReadText("t_UndoTheLastHotstring")
t_SelectHotstringLibrary := F_ReadText("t_SelectHotstringLibrary")
t_LibraryImportPleaseWait := F_ReadText("t_LibraryImportPleaseWait")
t_LoadingLibrariesPleaseWait := F_ReadText("t_LoadingLibrariesPleaseWait")
t_LibraryHasBeenImported := F_ReadText("t_LibraryHasBeenImported")
t_LibraryExportPleaseWait := F_ReadText("t_LibraryExportPleaseWait")
t_LibraryHasBeenExported := F_ReadText("t_LibraryHasBeenExported")
t_SelectedFileIsEmpty := F_ReadText("t_SelectedFileIsEmpty")
t_ThePathFileIs := F_ReadText("t_ThePathFileIs")
t_EnterTriggerstring := F_ReadText("t_EnterTriggerstring")
t_SelectTriggerOptions := F_ReadText("t_SelectTriggerOptions")
t_ImmediateExecute := F_ReadText("t_ImmediateExecute")
t_CaseSensitive := F_ReadText("t_CaseSensitive")
t_NoBackspace := F_ReadText("t_NoBackspace")
t_InsideWord := F_ReadText("t_InsideWord")
t_NoEndChar := F_ReadText("t_NoEndChar")
t_Disable := F_ReadText("t_Disable")
t_SelectHotstringOutputFunction := F_ReadText("t_SelectHotstringOutputFunction")
t_EnterHotstring := F_ReadText("t_EnterHotstring")
t_AddAComment := F_ReadText("t_AddAComment")
t_AddLibrary := F_ReadText("t_AddLibrary")
t_SetHotstring := F_ReadText("t_SetHotstring")
t_Clear := F_ReadText("t_Clear")
t_DeleteHotstring := F_ReadText("t_DeleteHotstring")
t_Sandbox := F_ReadText("t_Sandbox")
t_TriggerstringTriggOptOutFunEnDisHotstringComment := F_ReadText("t_TriggerstringTriggOptOutFunEnDisHotstringComment")
t_F1AboutHelpF2LibraryContentF3SearchHotstringsF5ClearF7ClipboardDelayF8DeleteHotstringF9SetHotstring := F_ReadText("t_F1AboutHelpF2LibraryContentF3SearchHotstringsF5ClearF7ClipboardDelayF8DeleteHotstringF9SetHotstring")
t_LoadedHotstrings := F_ReadText("t_LoadedHotstrings")
t_UndoLastHotstring := F_ReadText("t_UndoLastHotstring")
t_EnableDisable := F_ReadText("t_EnableDisable")
t_Caret := F_ReadText("t_Caret")
t_Cursor := F_ReadText("t_Cursor")
t_ChooseMenuPosition := F_ReadText("t_ChooseMenuPosition")
t_EnableSoundIfOverrun := F_ReadText("t_EnableSoundIfOverrun")
t_HotstringMenuMSIMCL := F_ReadText("t_HotstringMenuMSIMCL")
t_TriggerstringTips := F_ReadText("t_TriggerstringTips")
t_ChooseTipsLocation := F_ReadText("t_ChooseTipsLocation")
t_NumberOfCharactersForTips := F_ReadText("t_NumberOfCharactersForTips")
t_SortTipsAlphabetically := F_ReadText("t_SortTipsAlphabetically")
t_SortTipsByLength := F_ReadText("t_SortTipsByLength")
t_SaveWindowPosition := F_ReadText("t_SaveWindowPosition")
t_LaunchSandbox := F_ReadText("t_LaunchSandbox")
t_Space := F_ReadText("t_Space")
t_Minus := F_ReadText("t_Minus")
t_OpeningRoundBracket := F_ReadText("t_OpeningRoundBracket")
t_ClosingRoundBracket := F_ReadText("t_ClosingRoundBracket")
t_OpeningSquareBracket := F_ReadText("t_OpeningSquareBracket")
t_ClosingSquareBracket := F_ReadText("t_ClosingSquareBracket")
t_OpeningCurlyBracket := F_ReadText("t_OpeningCurlyBracket")
t_ClosingCurlyBracket := F_ReadText("t_ClosingCurlyBracket")
t_Colon := F_ReadText("t_Colon")
t_Semicolon := F_ReadText("t_Semicolon")
t_Apostrophe := F_ReadText("t_Apostrophe")
t_Quote := F_ReadText("t_Quote")
t_Slash := F_ReadText("t_Slash")
t_Backslash := F_ReadText("t_Backslash")
t_Comma := F_ReadText("t_Comma")
t_Dot := F_ReadText("t_Dot")
t_QuestionMark := F_ReadText("t_QuestionMark")
t_ExclamationMark := F_ReadText("t_ExclamationMark")
t_Enter := F_ReadText("t_Enter")
t_Tab := F_ReadText("t_Tab")
t_ToggleEndChars := F_ReadText("t_ToggleEndChars")
t_Configuration := F_ReadText("t_Configuration")
t_SearchHotstrings := F_ReadText("t_SearchHotstrings")
t_ImportFromAhkToCsv := F_ReadText("t_ImportFromAhkToCsv")
t_StaticHotstrings := F_ReadText("t_StaticHotstrings")
t_DynamicHotstrings := F_ReadText("t_DynamicHotstrings")
t_ExportFromCsvToAhk := F_ReadText("t_ExportFromCsvToAhk")
t_EnableDisableTriggerstringTips := F_ReadText("t_EnableDisableTriggerstringTips")
t_LibrariesConfiguration := F_ReadText("t_LibrariesConfiguration")
t_ClipboardDelay := F_ReadText("t_ClipboardDelay")
t_AboutHelp := F_ReadText("t_AboutHelp")
t_ReplacementTextIsBlankDoYouWantToProceed := F_ReadText("t_ReplacementTextIsBlankDoYouWantToProceed")
t_ChooseSendingFunction := F_ReadText("t_ChooseSendingFunction")
t_ChooseSectionBeforeSaving := F_ReadText("t_ChooseSectionBeforeSaving")
t_ChooseTheMethodOfSendingTheHotstring := F_ReadText("t_ChooseTheMethodOfSendingTheHotstring")
t_EnterANameForTheNewLibrary := F_ReadText("t_EnterANameForTheNewLibrary")
t_Cancel := F_ReadText("t_Cancel")
t_TheLibrary := F_ReadText("t_TheLibrary")
t_HasBeenCreated := F_ReadText("t_HasBeenCreated")
t_ALibraryWithThatNameAlreadyExists := F_ReadText("t_ALibraryWithThatNameAlreadyExists")
t_TheHostring := F_ReadText("t_TheHostring")
t_ExistsInAFile := F_ReadText("t_ExistsInAFile")
t_CsvDoYouWantToProceed := F_ReadText("t_CsvDoYouWantToProceed")
t_SelectARowInTheListViewPlease := F_ReadText("t_SelectARowInTheListViewPlease")
t_SelectedHotstringWillBeDeletedDoYouWantToProceed := F_ReadText("t_SelectedHotstringWillBeDeletedDoYouWantToProceed")
t_DeletingHotstring := F_ReadText("t_DeletingHotstring")
t_DeletingHotstringPleaseWait := F_ReadText("t_DeletingHotstringPleaseWait")
t_HotstringHasBeenDeletedNowApplicationWillRestartItselfInOrderToApplyChangesReloadTheLibrariesCsv := F_ReadText("t_HotstringHasBeenDeletedNowApplicationWillRestartItselfInOrderToApplyChangesReloadTheLibrariesCsv")
t_HotstringPasteFromClipboardDelay1s := F_ReadText("t_HotstringPasteFromClipboardDelay1s")
t_HotstringPasteFromClipboardDelay := F_ReadText("t_HotstringPasteFromClipboardDelay")
t_LetsMakeYourPCPersonalAgain := F_ReadText("t_LetsMakeYourPCPersonalAgain")
t_EnablesConvenientDefinitionAndUseOfHotstringsTriggeredByShortcutsLongerTextStringsThisIs3rdEditionOfThisApplication2020ByJakubMasiakAndMaciejSlojewskiLicenseGNUGPLVer3 := F_ReadText("t_EnablesConvenientDefinitionAndUseOfHotstringsTriggeredByShortcutsLongerTextStringsThisIs3rdEditionOfThisApplication2020ByJakubMasiakAndMaciejSlojewskiLicenseGNUGPLVer3")
t_ApplicationHelp := F_ReadText("t_ApplicationHelp")
t_GenuineHotstringsAutoHotkeyDocumentation := F_ReadText("t_GenuineHotstringsAutoHotkeyDocumentation")
t_PleaseWaitUploadingCsvFiles := F_ReadText("t_PleaseWaitUploadingCsvFiles")
t_SearchBy := F_ReadText("t_SearchBy")
t_Triggerstring := F_ReadText("t_Triggerstring")
t_Hotstring := F_ReadText("t_Hotstring")
t_Library := F_ReadText("t_Library")
t_Move := F_ReadText("t_Move")
t_LibraryTriggerstringTriggerOptionsOutputFunctionEnableDisableHotstringComment := F_ReadText("t_LibraryTriggerstringTriggerOptionsOutputFunctionEnableDisableHotstringComment")
t_F3CloseSearchHotstringsF8MoveHotstring := F_ReadText("t_F3CloseSearchHotstringsF8MoveHotstring")
t_SelectTheTargetLibrary := F_ReadText("t_SelectTheTargetLibrary")
t_DoYouWantToProceed := F_ReadText("t_DoYouWantToProceed")
t_HotstringMovedToThe := F_ReadText("t_HotstringMovedToThe")
t_File := F_ReadText("t_File")
t_ChooseLibraryFileAhkForImport := F_ReadText("t_ChooseLibraryFileAhkForImport")
t_ChooseLibraryFileCsvForExport := F_ReadText("t_ChooseLibraryFileCsvForExport")
t_ChangeLanguage := F_ReadText("t_ChangeLanguage")
t_ApplicationLanguageChangedTo := F_ReadText("t_ApplicationLanguageChangedTo")
t_TheApplicationWillBereloadedWithTheNewLanguageFile := F_ReadText("t_TheApplicationWillBereloadedWithTheNewLanguageFile")

; - - - - - - - - - - - - - - - - - - - - - - - 


IniRead, v_TipsConfig, Config.ini, TipsLibraries
a_TipsConfig := StrSplit(v_TipsConfig, "`n")
Loop, % a_TipsConfig.MaxIndex()
{
	v_ConfigLibrary := SubStr(a_TipsConfig[A_Index],1,InStr(a_TipsConfig[A_Index],"=")-1)
	Loop, Files, Libraries\*.csv
	{
		v_ConfigFlag := 1
		if (A_LoopFileName == v_ConfigLibrary)
		{
			v_ConfigFlag := 0
			break
		}
	}
	if (v_ConfigFlag)
	{
		IniDelete, Config.ini, TipsLibraries, %v_ConfigLibrary%
	}
}
Loop, Files, Libraries\*.csv
{
	if !(InStr(v_TipsConfig,A_LoopFileName))
		IniWrite, 1, Config.ini, TipsLibraries, %A_LoopFileName%
}

IfNotExist, Libraries\PriorityLibrary.csv
	FileAppend,, Libraries\PriorityLibrary.csv, UTF-8

if !(A_Args[1] == "l")
{
	Menu, Tray, Add, %t_EditHotstring%, L_GUIInit
	Menu, Tray, Add, %t_SearchHotstrings%, L_Searching
	Menu, Tray, Default, %t_EditHotstring%
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
global ini_TipsSortAlphabetically := ""
global ini_TipsSortByLength := ""
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
global v_HotstringCnt := ""
global v_HS3ListFlag := 0
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
IniRead, ini_TipsSortAlphabetically,	Config.ini, Configuration, TipsSortAlphatebically
IniRead, ini_TipsSortByLength,			Config.ini, Configuration, TipsSortByLength
v_MonitorFlag := 0
if !(v_PreviousSection)
	v_ShowGui := 1
else
	v_ShowGui := 2
if (v_Param == "d")
	TrayTip, %A_ScriptName% - Debug,%t_LoadingHotstringsFromLibraries%, 1
else if (v_Param == "l")
	TrayTip, %A_ScriptName% - Lite,%t_LoadingHotstringsFromLibraries%, 1
else	
	TrayTip, %A_ScriptName%,%t_LoadingHotstringsFromLibraries%, 1

; ---------------------------- INITIALIZATION -----------------------------

v_HotstringCnt := 0
Loop, Files, Libraries\*.csv
{
	if !(A_LoopFileName == "PriorityLibrary.csv")
	{
		F_LoadFiles(A_LoopFileName)
	}
}
F_LoadFiles("PriorityLibrary.csv")
a_Hotstring := []
a_Library := []
a_Triggerstring := []
a_EnableDisable := []
a_TriggerOptions := []
a_OutputFunction := []
a_Comment := []
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
		; LV_Add("", name, tabSearch[2],tabSearch[1],tabSearch[3],tabSearch[4],tabSearch[5], tabSearch[6])
		a_Library.Push(name)
		a_Hotstring.Push(tabSearch[2])
		a_TriggerOptions.Push(tabSearch[1])
		a_OutputFunction.Push(tabSearch[3])
		a_EnableDisable.Push(tabSearch[4])
		a_Comment.Push(tabSearch[6])
		a_Triggerstring.Push(tabSearch[5])
	}
}
TrayTip,%A_ScriptName%, %t_HotstringsHaveBeenLoaded% ,1
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
		MsgBox, %t_ErrorLevelWasTriggeredByNewInputError%
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

$^z::			;~ Ctrl + z as in MS Word: Undo
$!BackSpace:: 	;~ Alt + Backspace as in MS Word: rolls back last Autocorrect action
	IniRead, Undo, Config.ini, Configuration, UndoHotstring
	if (Undo == 1) and (v_TypedTriggerstring && (A_ThisHotkey != A_PriorHotkey))
	{
		ToolTip, %t_UndoTheLastHotstring%, % A_CaretX, % A_CaretY - 20
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
		MsgBox, %t_SelectHotstringLibrary%
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
	global v_LoadedHotstrings
	
	Loop
	{
		FileReadLine, line, Libraries\%nameoffile%, %A_Index%
		if ErrorLevel
			break
		line := StrReplace(line, "``n", "`n")
		line := StrReplace(line, "``r", "`r")		
		line := StrReplace(line, "``t", "`t")
		F_StartHotstring(line)
		IniRead, v_Library, Config.ini, TipsLibraries, %nameoffile%
		if (v_Library)
			a_Triggers.Push(v_TriggerString)
		v_HotstringCnt++
		GuiControl,, v_LoadedHotstrings,% t_LoadedHotstrings . " " v_HotstringCnt
		}
	return
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

F_StartHotstring(txt)
{
	global v_TriggerString
	static Options, OnOff, EnDis, SendFun, TextInsert
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
	SendRaw, % SubStr(A_PriorHotkey, InStr(A_PriorHotkey, ":", v_OptionCaseSensitive := false, StartingPos := 1, Occurrence := 2) + 1)
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
	global v_WindowX, v_WindowY ,v_WindowWidth,v_WindowHeight
	Gui, Import:New, -Border
	Gui, Import:Add, Progress, w200 h20 cBlue vMyProgress, 0
	Gui, Import:Add,Text,w200 vMyText, %t_LibraryImportPleaseWait%
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
	GuiControl,, MyText, %t_LoadingLibrariesPleaseWait%
	a_Triggers := []
	TrayTip, %A_ScriptName%,%t_LoadingHotstringsFromLibraries%, 1
	v_HotstringCnt := 0
	Loop, Files, Libraries\*.csv
	{
		if !(A_LoopFileName == "PriorityLibrary.csv")
		{
			F_LoadFiles(A_LoopFileName)
		}
	}
	F_LoadFiles("PriorityLibrary.csv")
	TrayTip,%A_ScriptName%, %t_HotstringsHaveBeenLoaded%,1
	Gui, HS3:Default
	GuiControl, , v_SelectHotstringLibrary, |
	Loop,%A_ScriptDir%\Libraries\*.csv
        GuiControl, , v_SelectHotstringLibrary, %A_LoopFileName%
	Gui, Import:Destroy
    MsgBox, %t_LibraryHasBeenImported%
    return
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

F_ExportLibraryStatic(filename)
{
	static MyProgress, MyText
	global v_WindowX, v_WindowY ,v_WindowWidth,v_WindowHeight
	Gui, Export:New, -Border
	Gui, Export:Add, Progress, w200 h20 cBlue vMyProgress, 0
	Gui, Export:Add,Text,w200 vMyText, %t_LibraryExportPleaseWait%
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
		MsgBox, %t_SelectedFileIsEmpty%
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
	MsgBox, % t_LibraryHasBeenExported . "`n" . t_ThePathFileIs . " " . v_OutputFile
	return
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

F_ExportLibraryDynamic(filename)
{
	static MyProgress, MyText
	global v_WindowX, v_WindowY ,v_WindowWidth,v_WindowHeight
	Gui, Export:New, -Border
	Gui, Export:Add, Progress, w200 h20 cBlue vMyProgress, 0
	Gui, Export:Add,Text,w200 vMyText, %t_LibraryExportPleaseWait%
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
		MsgBox, %t_SelectedFileIsEmpty%
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
	MsgBox, % t_LibraryHasBeenExported . "`n" . t_ThePathFileIs . " " . v_OutputFile
	return
}


F_ShowUnicodeSigns(string)
{
    vSize := StrPut(string, "CP0")
    VarSetCapacity(vUtf8, vSize)
    vSize := StrPut(string, &vUtf8, vSize, "CP0")
    Return StrGet(&vUtf8, "UTF-8") 
}

F_ReadText(string)
{
	local Label
	LabeL := SubStr(string,3)
	IniRead, string, %v_LanguageFile%, Strings, %Label%
	string := F_ShowUnicodeSigns(string)
	return string
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
    Gui, HS3:Add, Text, % "xm+" . 9*DPI%v_SelectedMonitor%,%t_EnterTriggerstring%
    Gui, HS3:Font, % "s" . 12*DPI%v_SelectedMonitor% . " norm cBlack"
    Gui, HS3:Add, Edit, % "w" . 184*DPI%v_SelectedMonitor% . " h" . 25*DPI%v_SelectedMonitor% . " xp+" . 227*DPI%v_SelectedMonitor% . " yp vv_TriggerString",
    Gui, HS3:Font, % "s" . 12*DPI%v_SelectedMonitor% . " bold cBlue"
    Gui, HS3:Add, GroupBox, % "section xm w" . 425*DPI%v_SelectedMonitor% . " h" . 106*DPI%v_SelectedMonitor%, %t_SelectTriggerOptions%
    Gui, HS3:Font, % "s" . 12*DPI%v_SelectedMonitor% . " norm cBlack"
    Gui, HS3:Add, CheckBox, % "gCapsCheck vv_OptionImmediateExecute xs+" . 12*DPI%v_SelectedMonitor% . " ys+" . 25*DPI%v_SelectedMonitor%, %t_ImmediateExecute%
    Gui, HS3:Add, CheckBox, % "gCapsCheck vv_OptionCaseSensitive xp+" . 225*DPI%v_SelectedMonitor% . " yp+" . 0*DPI%v_SelectedMonitor%, %t_CaseSensitive%
    Gui, HS3:Add, CheckBox, % "gCapsCheck vv_OptionNoBackspace xp-" . 225*DPI%v_SelectedMonitor% . " yp+" . 25*DPI%v_SelectedMonitor%, %t_NoBackspace%
    Gui, HS3:Add, CheckBox, % "gCapsCheck vv_OptionInsideWord xp+" . 225*DPI%v_SelectedMonitor% . " yp+" . 0*DPI%v_SelectedMonitor%, %t_InsideWord%
    Gui, HS3:Add, CheckBox, % "gCapsCheck vv_OptionNoEndChar xp-" . 225*DPI%v_SelectedMonitor% . " yp+" . 25*DPI%v_SelectedMonitor%, %t_NoEndChar%
    Gui, HS3:Add, CheckBox, % "gCapsCheck vv_OptionDisable xp+" . 225*DPI%v_SelectedMonitor% . " yp+" . 0*DPI%v_SelectedMonitor%, %t_Disable%
	Gui, HS3:Font, % "s" . 12*DPI%v_SelectedMonitor% . " cBlue Bold"
    Gui, HS3:Add, Text,% "xm+" . 9*DPI%v_SelectedMonitor%, %t_SelectHotstringOutputFunction%
    Gui, HS3:Font, % "s" . 12*DPI%v_SelectedMonitor% . " cBlack Norm"
    Gui, HS3:Add, DropDownList, % "xm w" . 424*DPI%v_SelectedMonitor% . " vv_SelectFunction gL_SelectFunction hwndddl", SendInput (SI)||Clipboard (CL)|Menu & SendInput (MSI)|Menu & Clipboard (MCL)
    PostMessage, 0x153, -1, 30*DPI%v_SelectedMonitor%,, ahk_id %ddl%
	Gui, HS3:Font, % "s" . 12*DPI%v_SelectedMonitor% . " cBlue Bold"
    Gui, HS3:Add, Text,% "xm+" . 9*DPI%v_SelectedMonitor%, %t_EnterHotstring%
    Gui, HS3:Font, % "s" . 12*DPI%v_SelectedMonitor% . " cBlack Norm"
    Gui, HS3:Add, Edit, % "w" . 424*DPI%v_SelectedMonitor% . " h" . 25*DPI%v_SelectedMonitor% . " vv_EnterHotstring xm"
    Gui, HS3:Add, Edit, % "yp+" . 31*DPI%v_SelectedMonitor% . " w" . 424*DPI%v_SelectedMonitor% . " h" . 25*DPI%v_SelectedMonitor% . " vv_EnterHotstring1 xm Disabled"
    Gui, HS3:Add, Edit, % "yp+" . 31*DPI%v_SelectedMonitor% . " w" . 424*DPI%v_SelectedMonitor% . " h" . 25*DPI%v_SelectedMonitor% . " vv_EnterHotstring2 xm Disabled"
    Gui, HS3:Add, Edit, % "yp+" . 31*DPI%v_SelectedMonitor% . " w" . 424*DPI%v_SelectedMonitor% . " h" . 25*DPI%v_SelectedMonitor% . " vv_EnterHotstring3 xm Disabled"
    Gui, HS3:Add, Edit, % "yp+" . 31*DPI%v_SelectedMonitor% . " w" . 424*DPI%v_SelectedMonitor% . " h" . 25*DPI%v_SelectedMonitor% . " vv_EnterHotstring4 xm Disabled"
    Gui, HS3:Add, Edit, % "yp+" . 31*DPI%v_SelectedMonitor% . " w" . 424*DPI%v_SelectedMonitor% . " h" . 25*DPI%v_SelectedMonitor% . " vv_EnterHotstring5 xm Disabled"
    Gui, HS3:Add, Edit, % "yp+" . 31*DPI%v_SelectedMonitor% . " w" . 424*DPI%v_SelectedMonitor% . " h" . 25*DPI%v_SelectedMonitor% . " vv_EnterHotstring6 xm Disabled"
    Gui, HS3:Font, % "s" . 12*DPI%v_SelectedMonitor% . " cBlue Bold"
    Gui, HS3:Add, Text,% "xm+" . 9*DPI%v_SelectedMonitor%, %t_AddAComment%
    Gui, HS3:Font, % "s" . 12*DPI%v_SelectedMonitor% . " cBlack Norm"
	Gui, HS3:Add, Edit, % "w" . 424*DPI%v_SelectedMonitor% . " h" . 25*DPI%v_SelectedMonitor% . " limit64 vComment xm"
	Gui, HS3:Font, % "s" . 12*DPI%v_SelectedMonitor% . " cBlue Bold"
    Gui, HS3:Add, Text,% "xm+" . 9*DPI%v_SelectedMonitor%, %t_SelectHotstringLibrary%
	Gui, HS3:Add, Button, % "gAddLib x+" . 120*DPI%v_SelectedMonitor% . " yp w" . 135*DPI%v_SelectedMonitor% . " h" . 25*DPI%v_SelectedMonitor%, %t_AddLibrary%
    Gui, HS3:Font, % "s" . 12*DPI%v_SelectedMonitor% . " cBlack Norm"
	Gui, HS3:Add, DropDownList, % "w" . 424*DPI%v_SelectedMonitor% . " vv_SelectHotstringLibrary gSectionChoose xm hwndddl" ,
    Loop,%A_ScriptDir%\Libraries\*.csv
        GuiControl, , v_SelectHotstringLibrary, %A_LoopFileName%
    PostMessage, 0x153, -1, 30*DPI%v_SelectedMonitor%,, ahk_id %ddl%
    Gui, HS3:Font, bold
    Gui, HS3:Add, Button, % "xm yp+" . 37*DPI%v_SelectedMonitor% . " w" . 135*DPI%v_SelectedMonitor% . " gAddHotstring", %t_SetHotstring%
	Gui, HS3:Add, Button, % "x+" . 10*DPI%v_SelectedMonitor% . " yp w" . 135*DPI%v_SelectedMonitor% . " gClear", %t_Clear%
	Gui, HS3:Add, Button, % "x+" . 10*DPI%v_SelectedMonitor% . " yp w" . 135*DPI%v_SelectedMonitor% . " vv_DeleteHotstring gDelete Disabled", %t_DeleteHotstring%
	Gui, HS3:Font, % "s" . 12*DPI%v_SelectedMonitor% . " cBlue Bold"
    Gui, HS3:Add, Text,% "vSandString xm+" . 9*DPI%v_SelectedMonitor%, %t_Sandbox%
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
    Gui, HS3:Add, ListView, % "LV0x1 0x4 yp+" . 25*DPI%v_SelectedMonitor% . " xp h" . 500*DPI%v_SelectedMonitor% . " w" . 400*DPI%v_SelectedMonitor% . " vv_LibraryContent AltSubmit gHSLV", %t_TriggerstringTriggOptOutFunEnDisHotstringComment%
	Gui, HS3:Add, Edit, vv_ViewString xs gViewString ReadOnly Hide,
	Gui, HS3:Font, % "s" . 12*DPI%v_SelectedMonitor% . " cBlack Norm"
	Gui, HS3:Add, Text, xm y0 vv_ShortcutsMainInterface,%t_F1AboutHelpF2LibraryContentF3SearchHotstringsF5ClearF7ClipboardDelayF8DeleteHotstringF9SetHotstring%
	GUI, HS3:Add, Text, y0 x800 vv_LoadedHotstrings, % t_LoadedHotstrings . " " . v_HotstringCnt

    ; Menu, HSMenu, Add, &Monitor, CheckMon
	Menu, Submenu1, Add, %t_UndoLastHotstring%,Undo
	Menu, SubmenuTips, Add, %t_EnableDisable%, Tips
	Menu, PositionMenu, Add, %t_Caret%, L_MenuCaretCursor
	Menu, PositionMenu, Add, %t_Cursor%, L_MenuCaretCursor
	Menu, SubmenuMenu, Add, %t_ChooseMenuPosition%,:PositionMenu
	Menu, SubmenuMenu, Add, %t_EnableSoundIfOverrun%, L_MenuSound
	if (ini_MenuSound)
		Menu, SubmenuMenu, Check, %t_EnableSoundIfOverrun%
	else
		Menu, SubmenuMenu, UnCheck, %t_EnableSoundIfOverrun%
	Menu, Submenu1, Add,% t_HotstringMenuMSIMCL, :SubmenuMenu
	if (ini_MenuCursor)
		Menu, PositionMenu, Check, %t_Cursor%
	else
		Menu, PositionMenu, UnCheck, %t_Cursor%
	if (ini_MenuCaret)
		Menu, PositionMenu, Check, %t_Caret%
	else
		Menu, PositionMenu, UnCheck, %t_Caret%
	Menu, Submenu1, Add, %t_TriggerstringTips%, :SubmenuTips
	Menu, Submenu3, Add, %t_Caret%,L_CaretCursor
	Menu, Submenu3, Add, %t_Cursor%,L_CaretCursor
	if (ini_Cursor)
		Menu, Submenu3, Check, %t_Cursor%
	else
		Menu, Submenu3, UnCheck, %t_Cursor%
	if (ini_Caret)
		Menu, Submenu3, Check, %t_Caret%
	else
		Menu, Submenu3, UnCheck, %t_Caret%
	Menu, SubmenuTips, Add, %t_ChooseTipsLocation%, :Submenu3
	If !(ini_Tips)
	{
		Menu, SubmenuTips,Disable, %t_ChooseTipsLocation%
	}
	Menu, Submenu4, Add, 1, L_AmountOfCharacterTips1
	Menu, Submenu4, Add, 2, L_AmountOfCharacterTips2
	Menu, Submenu4, Add, 3, L_AmountOfCharacterTips3
	Menu, Submenu4, Add, 4, L_AmountOfCharacterTips4
	Menu, Submenu4, Add, 5, L_AmountOfCharacterTips5
	Menu, Submenu4, Check, % ini_AmountOfCharacterTips
	Loop, 5
	{
		if !(A_Index == ini_AmountOfCharacterTips)
			Menu, Submenu4, UnCheck, %A_Index%
	}
	Menu, SubmenuTips, Add, %t_NumberOfCharactersForTips%, :Submenu4
	If !(ini_Tips)
	{
		Menu, SubmenuTips,Disable, %t_NumberOfCharactersForTips%s
	}
	Menu, SubmenuTips, Add, %t_SortTipsAlphabetically%, L_SortTipsAlphabetically
	if (ini_TipsSortAlphabetically)
		Menu, SubmenuTips, Check, %t_SortTipsAlphabetically%
	else
		Menu, SubmenuTips, UnCheck, %t_SortTipsAlphabetically%
	Menu, SubmenuTips, Add, %t_SortTipsByLength%, L_SortTipsByLength
	if (ini_TipsSortByLength)
		Menu, SubmenuTips, Check, %t_SortTipsByLength%
	else
		Menu, SubmenuTips, UnCheck, %t_SortTipsByLength%
	Menu, Submenu1, Add, %t_SaveWindowPosition%,SavePos
	Menu, Submenu1, Add, %t_LaunchSandbox%, Sandbox
	Menu, Submenu2, Add, %t_Space%, EndSpace
	if (EndingChar_Space)
		Menu, Submenu2, Check, %t_Space%
	else
		Menu, Submenu2, UnCheck, %t_Space%
	Menu, Submenu2, Add, %t_Minus%, EndMinus
	if (EndingChar_Minus)
		Menu, Submenu2, Check, %t_Minus%
	else
		Menu, Submenu2, UnCheck, %t_Minus%
	Menu, Submenu2, Add, %t_OpeningRoundBracket%, EndORoundBracket
	if (EndingChar_ORoundBracket)
		Menu, Submenu2, Check, %t_OpeningRoundBracket%
	else
		Menu, Submenu2, UnCheck, %t_OpeningRoundBracket%
	Menu, Submenu2, Add, %t_ClosingRoundBracket%, EndCRoundBracket
	if (EndingChar_CRoundBracket)
		Menu, Submenu2, Check, %t_ClosingRoundBracket%
	else
		Menu, Submenu2, UnCheck, %t_ClosingRoundBracket%
	Menu, Submenu2, Add, %t_OpeningSquareBracket%, EndOSquareBracket
	if (EndingChar_OSquareBracket)
		Menu, Submenu2, Check, %t_OpeningSquareBracket%
	else
		Menu, Submenu2, UnCheck, %t_OpeningSquareBracket%
	Menu, Submenu2, Add, %t_ClosingSquareBracket%, EndCSquareBracket
	if (EndingChar_CSquareBracket)
		Menu, Submenu2, Check, %t_ClosingSquareBracket%
	else
		Menu, Submenu2, UnCheck, %t_ClosingSquareBracket%
	Menu, Submenu2, Add, %t_OpeningCurlyBracket%, EndOCurlyBracket
	if (EndingChar_OCurlyBracket)
		Menu, Submenu2, Check, %t_OpeningCurlyBracket%
	else
		Menu, Submenu2, UnCheck, %t_OpeningCurlyBracket%
	Menu, Submenu2, Add, %t_ClosingCurlyBracket%, EndCCurlyBracket
	if (EndingChar_CCurlyBracket)
		Menu, Submenu2, Check, %t_ClosingCurlyBracket%
	else
		Menu, Submenu2, UnCheck, %t_ClosingCurlyBracket%
	Menu, Submenu2, Add, %t_Colon%, EndColon
	if (EndingChar_Colon)
		Menu, Submenu2, Check, %t_Colon%
	else
		Menu, Submenu2, UnCheck, t_Colon
	Menu, Submenu2, Add, % t_Semicolon, EndSemicolon
	if (EndingChar_Semicolon)
		Menu, Submenu2, Check, % t_Semicolon
	else
		Menu, Submenu2, UnCheck, % t_Semicolon
	Menu, Submenu2, Add, %t_Apostrophe%, EndApostrophe
	if (EndingChar_Apostrophe)
		Menu, Submenu2, Check, %t_Apostrophe%
	else
		Menu, Submenu2, UnCheck, %t_Apostrophe%
	Menu, Submenu2, Add, % t_Quote, EndQuote
	if (EndingChar_Quote)
		Menu, Submenu2, Check, % t_Quote
	else
		Menu, Submenu2, UnCheck, % t_Quote
	Menu, Submenu2, Add, %t_Slash%, EndSlash
	if (EndingChar_Slash)
		Menu, Submenu2, Check, %t_Slash%
	else
		Menu, Submenu2, UnCheck, %t_Slash%
	Menu, Submenu2, Add, %t_Backslash%, EndBackslash
	if (EndingChar_Backslash)
		Menu, Submenu2, Check, %t_Backslash%
	else
		Menu, Submenu2, UnCheck, %t_Backslash%
	Menu, Submenu2, Add, % t_Comma, EndComma
	if (EndingChar_Comma)
		Menu, Submenu2, Check, % t_Comma
	else
		Menu, Submenu2, UnCheck, % t_Comma
	Menu, Submenu2, Add, %t_Dot%, EndDot
	if (EndingChar_Dot)
		Menu, Submenu2, Check, %t_Dot%
	else
		Menu, Submenu2, UnCheck, %t_Dot%
	Menu, Submenu2, Add, %t_QuestionMark%, EndQuestionMark
	if (EndingChar_QuestionMark)
		Menu, Submenu2, Check, %t_QuestionMark%
	else
		Menu, Submenu2, UnCheck, %t_QuestionMark%
	Menu, Submenu2, Add, %t_ExclamationMark%, EndExclamationMark
	if (EndingChar_ExclamationMark)
		Menu, Submenu2, Check, %t_ExclamationMark%
	else
		Menu, Submenu2, UnCheck, %t_ExclamationMark%
	Menu, Submenu2, Add, %t_Enter%, EndEnter
	if (EndingChar_Enter)
		Menu, Submenu2, Check, %t_Enter%
	else
		Menu, Submenu2, UnCheck, %t_Enter%
	Menu, Submenu2, Add, %t_Tab%, EndTab
	if (EndingChar_Tab)
		Menu, Submenu2, Check, %t_Tab%
	else
		Menu, Submenu2, UnCheck, %t_Tab%
	Menu, Submenu1, Add, %t_ToggleEndChars%, :Submenu2
	IniRead, ini_Tips, Config.ini, Configuration, Tips
	if (ini_Tips == 0)
		Menu, SubmenuTips, UnCheck, %t_EnableDisable%
	else
		Menu, SubmenuTips, Check, %t_EnableDisable%
	IniRead, Sandbox, Config.ini, Configuration, Sandbox
	if (Sandbox == 0)
		Menu, Submenu1, UnCheck, %t_LaunchSandbox%
	else
		Menu, Submenu1, Check, %t_LaunchSandbox%
	IniRead, Undo, Config.ini, Configuration, UndoHotstring
	if (Undo == 0)
		Menu, Submenu1, UnCheck, %t_UndoLastHotstring%
	else
		Menu, Submenu1, Check, %t_UndoLastHotstring%
	Loop,%A_ScriptDir%\Languages\*.ini
	{
		Menu, SubmenuLanguage, Add, %A_LoopFileName%, L_ChangeLanguage
		if (v_Language == A_LoopFileName)
			Menu, SubmenuLanguage, Check, %A_LoopFileName%
		else
			Menu, SubmenuLanguage, UnCheck, %A_LoopFileName%
	}
	Menu, Submenu1, Add, %t_ChangeLanguage%, :SubmenuLanguage
	Menu, HSMenu, Add, %t_Configuration%, :Submenu1
	Menu, HSMenu, Add, %t_SearchHotstrings%, L_Searching
	Menu, LibrariesSubmenu, Add, %t_ImportFromAhkToCsv%, L_ImportLibrary
	Menu, ExportSubmenu, Add, %t_StaticHotstrings%,  L_ExportLibraryStatic
	Menu, ExportSubmenu, Add, %t_DynamicHotstrings%,  L_ExportLibraryDynamic
	Menu, LibrariesSubmenu, Add, %t_ExportFromCsvToAhk%,:ExportSubmenu
	Loop,%A_ScriptDir%\Libraries\*.csv
	{
		Menu, ToggleLibrariesSubmenu, Add, %A_LoopFileName%, L_ToggleTipsLibrary
		IniRead, v_LibraryFlag, Config.ini, TipsLibraries, %A_LoopFileName%
		if (v_LibraryFlag)
			Menu, ToggleLibrariesSubmenu, Check, %A_LoopFileName%
		else
			Menu, ToggleLibrariesSubmenu, UnCheck, %A_LoopFileName%	
	}
	Menu, LibrariesSubmenu, Add, %t_EnableDisableTriggerstringTips%, :ToggleLibrariesSubmenu 
	Menu, HSMenu, Add, %t_LibrariesConfiguration%, :LibrariesSubmenu
    Menu, HSMenu, Add, %t_ClipboardDelay%, HSdelay
	Menu, HSMenu, Add, %t_AboutHelp%, About
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
		MsgBox, %t_EnterHotstring%
		return
	}
	if InStr(v_SelectFunction,"Menu")
	{
		If ((Trim(v_EnterHotstring) ="") and (Trim(v_EnterHotstring1) ="") and (Trim(v_EnterHotstring2) ="") and (Trim(v_EnterHotstring3) ="") and (Trim(v_EnterHotstring4) ="") and (Trim(v_EnterHotstring5) ="") and (Trim(v_EnterHotstring6) =""))
		{
			MsgBox, 4,, %t_ReplacementTextIsBlankDoYouWantToProceed%
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
			MsgBox, 4,, %t_ReplacementTextIsBlankDoYouWantToProceed%
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
		MsgBox,0x30 ,, %t_ChooseSendingFunction%
		return
	}
	if (v_SelectHotstringLibrary == "")
	{
		MsgBox, %t_ChooseSectionBeforeSaving%
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
		MsgBox, %t_ChooseTheMethodOfSendingTheHotstring%
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
	else if (Fun = "MCL")
	{
		SendFun := "F_MenuText"
	}
	else if (Fun = "MSI")
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
	Gui, ALib:Add, Text,,%t_EnterANameForTheNewLibrary%
	Gui, ALib:Add, Edit, % "vNewLib w" . 150*DPI%v_SelectedMonitor%,
	Gui, ALib:Add, Text, % "x+" . 10*DPI%v_SelectedMonitor%, .csv
	Gui, ALib:Add, Button, % "Default gALibOK xm w" . 70*DPI%v_SelectedMonitor%, OK
	Gui, ALib:Add, Button, % "gALibGuiClose x+" . 10*DPI%v_SelectedMonitor% . " w" . 70*DPI%v_SelectedMonitor%, %t_Cancel%
	WinGetPos, v_PreviousX, v_PreviousY , , ,Hotstrings
	Gui, ALib:Show, % "x" . ((v_PreviousX+v_PreviousWidth)/2)/DPI%v_SelectedMonitor% . " y" . ((v_PreviousY+v_PreviousHeight)/2)/DPI%v_SelectedMonitor%
return

ALibOK:
	Gui,ALib:Submit, NoHide
	if (NewLib == "")
	{
		MsgBox, %t_EnterANameForTheNewLibrary%
		return
	}
	NewLib .= ".csv"
	IfNotExist, Libraries
		FileCreateDir, Libraries
	IfNotExist, Libraries\%NewLib%
	{
		FileAppend,, Libraries\%NewLib%, UTF-8
		IniRead, t_TheLibraryHasBeenCreated, English.ini, Strings, TheLibraryHasBeenCreated
		MsgBox, % t_TheLibrary . " " . NewLib . " " . t_HasBeenCreated
		Gui, ALib:Destroy
		GuiControl, HS3:, v_SelectHotstringLibrary, |
		Loop,%A_ScriptDir%\Libraries\*.csv
        	GuiControl,HS3: , v_SelectHotstringLibrary, %A_LoopFileName%
	}
	Else
		MsgBox, %t_ALibraryWithThatNameAlreadyExists%
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
		}
	LV_ModifyCol(1, "Sort")
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
		if (InStr(A_LoopReadLine, LString, 1) and InStr(Options, "C")) or (InStr(A_LoopReadLine, LString) and !(InStr(Options, "C")))
		{
			if !(v_SelectedRow)
			{
				MsgBox, 4,, % t_TheHostring . " """ .  v_TriggerString . """ " .  t_ExistsInAFile . " " . SaveFile . t_CsvDoYouWantToProceed
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
	a_Triggers := []
	TrayTip, %A_ScriptName%,%t_LoadingHotstringsFromLibraries%, 1
	v_HotstringCnt := 0
	Loop, Files, Libraries\*.csv
	{
		if !(A_LoopFileName == "PriorityLibrary.csv")
		{
			F_LoadFiles(A_LoopFileName)
		}
	}
	F_LoadFiles("PriorityLibrary.csv")	
	TrayTip,%A_ScriptName%, %t_HotstringsHaveBeenLoaded% ,1
Return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Delete:
	Gui, HS3:+OwnDialogs
	
	If !(v_SelectedRow := LV_GetNext()) {
		MsgBox, 0, %A_ThisLabel%, %t_SelectARowInTheListViewPlease%
		Return
	}
	Msgbox, 0x4,, %t_SelectedHotstringWillBeDeletedDoYouWantToProceed%
	IfMsgBox, No
		return
	TrayTip, %A_ScriptName%, %t_DeletingHotstring%, 1
	Gui, ProgressDelete:New, -Border -Resize
	Gui, ProgressDelete:Add, Progress, w200 h20 cBlue vProgressDelete, 0
	Gui, ProgressDelete:Add,Text,w200 vTextDelete, %t_DeletingHotstringPleaseWait%
	Gui, ProgressDelete:Show, hide, ProgressDelete
	WinGetPos, v_WindowX, v_WindowY ,v_WindowWidth,v_WindowHeight,Hotstrings
	DetectHiddenWindows, On
	WinGetPos, , , DeleteWindowWidth, DeleteWindowHeight,ProgressDelete
	DetectHiddenWindows, Off
	Gui, ProgressDelete:Show,% "x" . v_WindowX + (v_WindowWidth - DeleteWindowWidth)/2 . " y" . v_WindowY + (v_WindowHeight - DeleteWindowHeight)/2 ,ProgressDelete
	name := v_SelectHotstringLibrary
	FileDelete, Libraries\%name%
	cntDelete := 0
	Gui, HS3:Default
	if (v_SelectedRow == SectionList.MaxIndex())
	{
		if (SectionList.MaxIndex() == 1)
		{
			FileAppend,, Libraries\%name%, UTF-8
			GuiControl,, ProgressDelete, 100
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
					v_DeleteProgress := (A_Index/(SectionList.MaxIndex()-1))*100
					Gui, ProgressDelete:Default
					GuiControl,, ProgressDelete, %v_DeleteProgress%
					Gui, HS3:Default
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
				v_DeleteProgress := (A_Index/(SectionList.MaxIndex()-1))*100
				Gui, ProgressDelete:Default
				GuiControl,, ProgressDelete, %v_DeleteProgress%
				Gui, HS3:Default
			}
		}
	}
	Gui, ProgressDelete:Destroy
	MsgBox, %t_HotstringHasBeenDeletedNowApplicationWillRestartItselfInOrderToApplyChangesReloadTheLibrariesCsv%
	WinGetPos, v_PreviousX, v_PreviousY , , ,Hotstrings
	Run, AutoHotkey.exe Hotstrings.ahk v_Param L_GUIInit %v_SelectHotstringLibrary% %v_PreviousWidth% %v_PreviousHeight% %v_PreviousX% %v_PreviousY% %v_SelectedRow% %v_SelectedMonitor%
return
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
        GuiControl,,DelayText, %t_HotstringPasteFromClipboardDelay1s%
    else
        GuiControl,,DelayText, % t_HotstringPasteFromClipboardDelay . " " . ini_Delay . " ms"
	IniWrite, %ini_Delay%, Config.ini, Configuration, Delay
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

About:
	Gui, MyAbout: Destroy
	Gui, MyAbout: Font, % "bold s" . 11*DPI%v_SelectedMonitor%
    Gui, MyAbout: Add, Text, , %t_LetsMakeYourPCPersonalAgain%
	Gui, MyAbout: Font, % "norm s" . 11*DPI%v_SelectedMonitor%
	Gui, MyAbout: Add, Text, ,%t_EnablesConvenientDefinitionAndUseOfHotstringsTriggeredByShortcutsLongerTextStringsThisIs3rdEditionOfThisApplication2020ByJakubMasiakAndMaciejSlojewskiLicenseGNUGPLVer3%
   	Gui, MyAbout: Font, % "CBlue bold Underline s" . 12*DPI%v_SelectedMonitor%
    Gui, MyAbout: Add, Text, gLink, %t_ApplicationHelp%
	Gui, MyAbout: Add, Text, gLink2, %t_GenuineHotstringsAutoHotkeyDocumentation%
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
	GuiControl, Move, v_LoadedHotstrings, % "y" . v_PreviousHeight - 22*DPI%v_SelectedMonitor% . " x" . v_PreviousWidth - 200*DPI%v_SelectedMonitor%
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
if (v_HS3ListFlag)
	GUI, HS3List:Show
else
{
	WinGetPos, StartXlist, StartYlist,,,Hotstrings
	Gui, SearchLoad:New, -Resize -Border
	Gui, SearchLoad:Add, Text,, %t_PleaseWaitUploadingCsvFiles%
	Gui, SearchLoad:Add, Progress, w300 h20 HwndhPB2 -0x1, 50
	WinSet, Style, +0x8, % "ahk_id " hPB2
	SendMessage, 0x40A, 1, 20,, % "ahk_id " hPB2
	Gui, SearchLoad:Show, hide, UploadingSearch
	WinGetPos, v_WindowX, v_WindowY ,v_WindowWidth,v_WindowHeight,Hotstrings
	DetectHiddenWindows, On
	WinGetPos, , , UploadingWindowWidth, UploadingWindowHeight,UploadingSearch
	DetectHiddenWindows, Off
	Gui, SearchLoad:Show,% "x" . v_WindowX + (v_WindowWidth - UploadingWindowWidth)/2 . " y" . v_WindowY + (v_WindowHeight - UploadingWindowHeight)/2 ,UploadingSearch
		
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
		Gui, HS3List:Hide
	}
	Gui, HS3List:New,% "+Resize MinSize" . 940*DPI%v_SelectedMonitor% . "x" . 500*DPI%v_SelectedMonitor%
	v_HS3ListFlag := 1
	Gui, HS3List:Add, Text, ,Search:
	Gui, HS3List:Add, Text, % "yp xm+" . 420*DPI%v_SelectedMonitor%, %t_SearchBy%
	Gui, HS3List:Add, Edit, % "xm w" . 400*DPI%v_SelectedMonitor% . " vv_SearchTerm gSearch"
	Gui, HS3List:Add, Radio, % "yp xm+" . 420*DPI%v_SelectedMonitor% . " vv_RadioGroup gSearchChange Checked", %t_Triggerstring%
	Gui, HS3List:Add, Radio, % "yp xm+" . 540*DPI%v_SelectedMonitor% . " gSearchChange", %t_Hotstring%
	Gui, HS3List:Add, Radio, % "yp xm+" . 640*DPI%v_SelectedMonitor% . " gSearchChange", %t_Library%
	Gui, HS3List:Add, Button, % "yp-2 xm+" . 720*DPI%v_SelectedMonitor% . " w" . 100*DPI%v_SelectedMonitor% . " gMoveList", %t_Move%
	Gui, HS3List:Add, ListView, % "xm grid vList +AltSubmit gHSLV2 h" . 400*DPI%v_SelectedMonitor%, %t_LibraryTriggerstringTriggerOptionsOutputFunctionEnableDisableHotstringComment%
	Loop, % a_Library.MaxIndex()
	{
		LV_Add("", a_Library[A_Index], a_Hotstring[A_Index],a_TriggerOptions[A_Index],a_OutputFunction[A_Index],a_EnableDisable[A_Index],a_Triggerstring[A_Index], a_Comment[A_Index])
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
	Gui, HS3List:Add, Text, xm vShortcuts2, %t_F3CloseSearchHotstringsF8MoveHotstring%
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
}

Search:
Gui, Hs3List:Default
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
        ; If (InStr(FileName, v_SearchTerm) = 1) ; for matching at the start
        If InStr(FileName, v_SearchTerm) ; for overall matching
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
		MsgBox, 0, %A_ThisLabel%, %t_SelectARowInTheListViewPlease%
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
	Gui, MoveLibs:Add, Text,, %t_SelectTheTargetLibrary%
	Gui, MoveLibs:Add, ListView,LV0x1 -Hdr r%cntMove%,Library
	Loop, %A_ScriptDir%\Libraries\*.csv
	{
		if (SubStr(A_LoopFileName,1,StrLen(A_LoopFileName)-4) != FileName )
		{
			LV_Add("",A_LoopFileName)
		}
	}
	Gui, MoveLibs:Add, Button,% "gMove w" . 100*DPI%v_SelectedMonitor%, %t_Move%
	Gui, MoveLibs:Add, Button, % "yp x+m gCanMove w" . 100*DPI%v_SelectedMonitor%, %t_Cancel%
	Gui, MoveLibs:Show,hide, Select library
	WinGetPos, v_WindowX, v_WindowY ,v_WindowWidth,v_WindowHeight,Hotstrings
	DetectHiddenWindows, On
	WinGetPos, , , SelectLibraryWindowWidth, SelectLibraryWindowHeight,Select library
	DetectHiddenWindows, Off
	Gui, MoveLibs:Show,% "x" . v_WindowX + (v_WindowWidth - SelectLibraryWindowWidth)/2 . " y" . v_WindowY + (v_WindowHeight - SelectLibraryWindowHeight)/2 ,Select library
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

CanMove:
Gui, MoveLibs:Destroy
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Move:
Gui, MoveLibs:Submit, NoHide
If !(v_SelectedRow := LV_GetNext()) {
	MsgBox, 0, %A_ThisLabel%, %t_SelectARowInTheListViewPlease%
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
		MsgBox, 4,, % t_TheHostring . " """ . Triggerstring """ " . t_ExistsInAFile . " " . TargetLib . t_DoYouWantToProceed
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
MsgBox,% t_HotstringMovedToThe . " " . TargetLib . " " . t_File
a_Triggers := []
TrayTip, %A_ScriptName%,%t_LoadingHotstringsFromLibraries%, 1
v_HotstringCnt := 0
Loop, Files, Libraries\*.csv
{
	if !(A_LoopFileName == "PriorityLibrary.csv")
	{
		F_LoadFiles(A_LoopFileName)
	}
}
F_LoadFiles("PriorityLibrary.csv")
TrayTip,%A_ScriptName%, %t_HotstringsHaveBeenLoaded% ,1
Gui, MoveLibs:Destroy
Gui, HS3List:Hide
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

Undo:
	Menu, Submenu1, ToggleCheck, %t_UndoLastHotstring%
	Undo := !(Undo)
	IniWrite, %Undo%, Config.ini, Configuration, UndoHotstring
return

; F11::
;	IniRead, Undo, Config.ini, Configuration, UndoHotstring
;	Undo := !(Undo)
;	IniWrite, %Undo%, Config.ini, Configuration, UndoHotstring
; return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Tips:
	Menu, SubmenuTips, ToggleCheck, %t_EnableDisable%
	Menu, SubmenuTips, ToggleEnable, %t_ChooseTipsLocation%
	Menu, SubmenuTips, ToggleEnable, %t_NumberOfCharactersForTips%
	ini_Tips := !(ini_Tips)
	IniWrite, %ini_Tips%, Config.ini, Configuration, Tips
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Sandbox:
	Menu, Submenu1, ToggleCheck, %t_LaunchSandbox%
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
	Menu, Submenu2, ToggleCheck, %t_Space%
	EndingChar_Space := !(EndingChar_Space)
	IniWrite, %EndingChar_Space%, Config.ini, Configuration, EndingChar_Space
	EndChars()
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

EndMinus:
	Menu, Submenu2, ToggleCheck, %t_Minus%
	EndingChar_Minus := !(EndingChar_Minus)
	IniWrite, %EndingChar_Minus%, Config.ini, Configuration, EndingChar_Minus
	EndChars()
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

EndORoundBracket:
	Menu, Submenu2, ToggleCheck, %t_OpeningRoundBracket%
	EndingChar_ORoundBracket := !(EndingChar_ORoundBracket)
	IniWrite, %EndingChar_ORoundBracket%, Config.ini, Configuration, EndingChar_ORoundBracket
	EndChars()
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

EndCRoundBracket:
	Menu, Submenu2, ToggleCheck, %t_ClosingRoundBracket%
	EndingChar_CRoundBracket := !(EndingChar_CRoundBracket)
	IniWrite, %EndingChar_CRoundBracket%, Config.ini, Configuration, EndingChar_CRoundBracket
	EndChars()
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

EndOSquareBracket:
	Menu, Submenu2, ToggleCheck, %t_OpeningSquareBracket%
	EndingChar_OSquareBracket := !(EndingChar_OSquareBracket)
	IniWrite, %EndingChar_OSquareBracket%, Config.ini, Configuration, EndingChar_OSquareBracket
	EndChars()
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

EndCSquareBracket:
	Menu, Submenu2, ToggleCheck, %t_ClosingSquareBracket%
	EndingChar_CSquareBracket := !(EndingChar_CSquareBracket)
	IniWrite, %EndingChar_CSquareBracket%, Config.ini, Configuration, EndingChar_CSquareBracket
	EndChars()
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

EndOCurlyBracket:
	Menu, Submenu2, ToggleCheck, %t_OpeningCurlyBracket%
	EndingChar_OCurlyBracket := !(EndingChar_OCurlyBracket)
	IniWrite, %EndingChar_OCurlyBracket%, Config.ini, Configuration, EndingChar_OCurlyBracket
	EndChars()
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

EndCCurlyBracket:
	Menu, Submenu2, ToggleCheck, %t_ClosingCurlyBracket%
	EndingChar_CCurlyBracket := !(EndingChar_CCurlyBracket)
	IniWrite, %EndingChar_CCurlyBracket%, Config.ini, Configuration, EndingChar_CCurlyBracket
	EndChars()
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

EndColon:
	Menu, Submenu2, ToggleCheck,%t_Colon%
	EndingChar_Colon := !(EndingChar_Colon)
	IniWrite, %EndingChar_Colon%, Config.ini, Configuration, EndingChar_Colon
	EndChars()
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

EndSemicolon:
	Menu, Submenu2, ToggleCheck, % t_Semicolon
	EndingChar_Semicolon := !(EndingChar_Semicolon)
	IniWrite, %EndingChar_Semicolon%, Config.ini, Configuration, EndingChar_Semicolon
	EndChars()
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

EndApostrophe:
	Menu, Submenu2, ToggleCheck, %t_Apostrophe%
	EndingChar_Apostrophe := !(EndingChar_Apostrophe)
	IniWrite, %EndingChar_Apostrophe%, Config.ini, Configuration, EndingChar_Apostrophe
	EndChars()
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

EndQuote:
	Menu, Submenu2, ToggleCheck, % t_Quote
	EndingChar_Quote := !(EndingChar_Quote)
	IniWrite, %EndingChar_Quote%, Config.ini, Configuration, EndingChar_Quote
	EndChars()
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

EndSlash:
	Menu, Submenu2, ToggleCheck, %t_Slash%
	EndingChar_Slash := !(EndingChar_Slash)
	IniWrite, %EndingChar_Slash%, Config.ini, Configuration, EndingChar_Slash
	EndChars()
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

EndBackslash:
	Menu, Submenu2, ToggleCheck, %t_Backslash%
	EndingChar_Backslash := !(EndingChar_Backslash)
	IniWrite, %EndingChar_Backslash%, Config.ini, Configuration, EndingChar_Backslash
	EndChars()
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

EndComma:
	Menu, Submenu2, ToggleCheck, % t_Comma
	EndingChar_Comma := !(EndingChar_Comma)
	IniWrite, %EndingChar_Comma%, Config.ini, Configuration, EndingChar_Comma
	EndChars()
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

EndDot:
	Menu, Submenu2, ToggleCheck, %t_Dot%
	EndingChar_Dot := !(EndingChar_Dot)
	IniWrite, %EndingChar_Dot%, Config.ini, Configuration, EndingChar_Dot
	EndChars()
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

EndQuestionMark:
	Menu, Submenu2, ToggleCheck, %t_QuestionMark%
	EndingChar_QuestionMark := !(EndingChar_QuestionMark)
	IniWrite, %EndingChar_QuestionMark%, Config.ini, Configuration, EndingChar_QuestionMark
	EndChars()
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

EndExclamationMark:
	Menu, Submenu2, ToggleCheck, %t_ExclamationMark%
	EndingChar_ExclamationMark := !(EndingChar_ExclamationMark)
	IniWrite, %EndingChar_ExclamationMark%, Config.ini, Configuration, EndingChar_ExclamationMark
	EndChars()
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

EndEnter:
	Menu, Submenu2, ToggleCheck, %t_Enter%
	EndingChar_Enter := !(EndingChar_Enter)
	IniWrite, %EndingChar_Enter%, Config.ini, Configuration, EndingChar_Enter
	EndChars()
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

EndTab:
	Menu, Submenu2, ToggleCheck, %t_Tab%
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
	Menu, Submenu3, ToggleCheck, %t_Caret%
	Menu, Submenu3, ToggleCheck, %t_Cursor%
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
	Menu, PositionMenu, ToggleCheck, %t_Caret%
	Menu, PositionMenu, ToggleCheck, %t_Cursor%
	ini_MenuCaret := !(ini_MenuCaret)
	ini_MenuCursor := !(ini_MenuCursor)
	IniWrite, %ini_MenuCaret%, Config.ini, Configuration, MenuCaret
	IniWrite, %ini_MenuCursor%, Config.ini, Configuration, MenuCursor
return

L_MenuSound:
	Menu, SubmenuMenu, ToggleCheck, %t_EnableSoundIfOverrun%
	ini_MenuSound := !(ini_MenuSound)
	IniWrite, %ini_MenuSound%, Config.ini, Configuration, MenuSound
return

L_ImportLibrary:
	FileSelectFile, v_LibraryName, 3, %A_ScriptDir%,%t_ChooseLibraryFileAhkForImport%, AHK Files (*.ahk)]
	if !(v_LibraryName == "")
		F_ImportLibrary(v_LibraryName)
return

L_ExportLibraryStatic:
	FileSelectFile, v_LibraryName, 3, % A_ScriptDir . "\Libraries",%t_ChooseLibraryFileCsvForExport%, CSV Files (*.csv)]
	if !(v_LibraryName == "")
		F_ExportLibraryStatic(v_LibraryName)
return

L_ExportLibraryDynamic:
	FileSelectFile, v_LibraryName, 3, % A_ScriptDir . "\Libraries",%t_ChooseLibraryFileCsvForExport%, CSV Files (*.csv)]
	if !(v_LibraryName == "")
		F_ExportLibraryDynamic(v_LibraryName)
return

L_ToggleTipsLibrary:
Menu, ToggleLibrariesSubmenu, ToggleCheck, %A_ThisMenuitem%
IniRead, v_LibraryFlag, Config.ini, TipsLibraries, %A_ThisMenuitem%
v_LibraryFlag := !(v_LibraryFlag)
IniWrite, %v_LibraryFlag%, Config.ini, TipsLibraries, %A_ThisMenuitem%
a_Triggers := []
TrayTip, %A_ScriptName%,%t_LoadingHotstringsFromLibraries%, 1
v_HotstringCnt := 0
Loop, Files, Libraries\*.csv
{
	if !(A_LoopFileName == "PriorityLibrary.csv")
	{
		F_LoadFiles(A_LoopFileName)
	}
}
F_LoadFiles("PriorityLibrary.csv")
TrayTip,%A_ScriptName%, %t_HotstringsHaveBeenLoaded% ,1
return

L_SortTipsAlphabetically:
Menu, SubmenuTips, ToggleCheck, %t_SortTipsAlphabetically%
ini_TipsSortAlphabetically := !(ini_TipsSortAlphabetically)
IniWrite, %ini_TipsSortAlphabetically%, Config.ini, Configuration, TipsSortAlphatebically
return

L_SortTipsByLength:
Menu, SubmenuTips, ToggleCheck, %t_SortTipsByLength%
ini_TipsSortByLength := !(ini_TipsSortByLength)
IniWrite, %ini_TipsSortByLength%, Config.ini, Configuration, TipsSortByLength
return

L_ChangeLanguage:
v_Language := A_ThisMenuitem
IniWrite, %v_Language%, Config.ini, Configuration, Language
Loop,%A_ScriptDir%\Languages\*.ini
{
	Menu, SubmenuLanguage, Add, %A_LoopFileName%, L_ChangeLanguage
	if (v_Language == A_LoopFileName)
		Menu, SubmenuLanguage, Check, %A_LoopFileName%
	else
		Menu, SubmenuLanguage, UnCheck, %A_LoopFileName%
}
MsgBox, % t_ApplicationLanguageChangedTo . " " . SubStr(v_Language, 1, StrLen(v_Language)-4) . "`n" . t_TheApplicationWillBereloadedWithTheNewLanguageFile
Reload
return

#if