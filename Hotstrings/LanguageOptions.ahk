IniRead, v_Language, Config.ini, Configuration, Language
if (v_Language == "EN")
{
    v_LanguageFile := "Languages/English.ini"
}
global t_EditHotstring,t_SearchHotstrings, t_LoadingHotstringsFromLibraries, t_HotstringsHaveBeenLoaded, t_ErrorLevelWasTriggeredByNewInputError, t_UndoTheLastHotstring, t_SelectHotstringLibrary, t_LibraryImportPleaseWait, t_LoadingLibrariesPleaseWait, t_LibraryHasBeenImported, t_SelectedFileIsEmpty, t_LibraryExportPleaseWait, t_LibraryHasBeenExported, t_ThePathFileIs, t_EnterTriggerstring, t_SelectTriggerOptions, t_ImmediateExecute, t_CaseSensitive, t_NoBackspace, t_InsideWord, t_NoEndChar, t_Disable, t_SelectHotstringOutputFunction, t_EnterHotstring, t_AddAComment, t_AddLibrary, t_SetHotstring, t_Clear, t_DeleteHotstring, t_Sandbox, t_TriggerstringTriggOptOutFunEnDisHotstringComment, t_F1AboutHelpF2LibraryContentF3SearchHotstringsF5ClearF7ClipboardDelayF8DeleteHotstringF9SetHotstring, t_LoadedHotstrings, t_UndoLastHotstring, t_EnableDisable, t_Caret, t_Cursor, t_ChooseMenuPosition, t_EnableSoundIfOverrun, t_HotstringMenuMSIMCL, t_TriggerstringTips, t_ChooseTipsLocation, t_NumberOfCharactersForTips, t_SortTipsAlphabetically, t_SortTipsByLength, t_SaveWindowPosition, t_LaunchSandbox, t_Space, t_Minus, t_OpeningRoundBracket, t_ClosingRoundBracket, t_OpeningSquareBracket, t_ClosingSquareBracket, t_OpeningCurlyBracket, t_ClosingCurlyBracket, t_Colon, t_Semicolon, t_Apostrophe, t_Apostrophe, t_Quote, t_Slash, t_Backslash, t_Comma, t_Dot, t_QuestionMark, t_ExclamationMark, t_Enter, t_Tab, t_ToggleEndChars, t_Configuration, t_SearchHotstrings, t_ImportFromAhkToCsv, t_StaticHotstrings, t_DynamicHotstrings, t_ExportFromCsvToAhk, t_EnableDisableTriggerstringTips, t_LibrariesConfiguration, t_ClipboardDelay, t_AboutHelp, t_ReplacementTextIsBlankDoYouWantToProceed, t_ChooseSendingFunction, t_ChooseSectionBeforeSaving, t_ChooseTheMethodOfSendingTheHotstring, t_EnterANameForTheNewLibrary, t_Cancel, t_TheLibrary, t_HasBeenCreated, t_ALibraryWithThatNameAlreadyExists, t_TheHostring, t_ExistsInAFile, t_CsvDoYouWantToProceed, t_SelectARowInTheListViewPlease, t_SelectedHotstringWillBeDeletedDoYouWantToProceed, t_DeletingHotstring, t_DeletingHotstringPleaseWait, t_HotstringHasBeenDeletedNowApplicationWillRestartItselfInOrderToApplyChangesReloadTheLibrariesCsv, t_HotstringPasteFromClipboardDelay1s, t_HotstringPasteFromClipboardDelay, t_LetsMakeYourPCPersonalAgain, t_EnablesConvenientDefinitionAndUseOfHotstringsTriggeredByShortcutsLongerTextStringsThisIs3rdEditionOfThisApplication2020ByJakubMasiakAndMaciejSlojewskiLicenseGNUGPLVer3, t_ApplicationHelp, t_GenuineHotstringsAutoHotkeyDocumentation, t_PleaseWaitUploadingCsvFiles, t_SearchBy, t_Triggerstring, t_Hotstring, t_Library, t_Move, t_LibraryTriggerstringTriggerOptionsOutputFunctionEnableDisableHotstringComment, t_F3CloseSearchHotstringsF8MoveHotstring, t_SelectTheTargetLibrary, t_HotstringMovedToThe, t_File, t_ChooseLibraryFileAhkForImport, t_ChooseLibraryFileCsvForExport
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