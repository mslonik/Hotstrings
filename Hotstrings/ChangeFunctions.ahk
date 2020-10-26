#SingleInstance Force
SetWorkingDir %A_ScriptDir%

OutputFileTemp = % A_ScriptDir . "\Libraries\temp.csv"

Loop, Files, Libraries\*.csv
{
    InputFileTemp = % A_ScriptDir . "\Libraries\" . A_LoopFileName
    Loop
    {
        FileReadLine, lineTemp, %InputFileTemp%, %A_Index%
        if ErrorLevel
			break
        lineTemp := StrReplace(lineTemp, "‖A‖", "‖SI‖")
        lineTemp := StrReplace(lineTemp, "‖C‖", "‖CL‖")
        lineTemp := StrReplace(lineTemp, "‖MA‖", "‖MSI‖")
        lineTemp := StrReplace(lineTemp, "‖MC‖", "‖MCL‖")
        lineTemp := StrReplace(lineTemp, "‖On‖", "‖En‖")
        lineTemp := StrReplace(lineTemp, "‖Off‖", "‖Dis‖")
        If (A_Index == 1)
            FileAppend, %lineTemp%, %OutputFileTemp%, UTF-8
        Else
            FileAppend, % "`r`n" . lineTemp, %OutputFileTemp%, UTF-8
    }
    FileDelete, %InputFileTemp%
    Loop
    {
        FileReadLine, lineTemp, %OutputFileTemp%, %A_Index%
        if ErrorLevel
			break
        If (A_Index == 1)
            FileAppend, %lineTemp%, %InputFileTemp%, UTF-8
        Else
            FileAppend, % "`r`n" . lineTemp, %InputFileTemp%, UTF-8
    }
    FileDelete, %OutputFileTemp%
}