#SingleInstance, Force
SetWorkingDir, %A_ScriptDir%

FileSelectFile, InputFilePath, 3,, Choose CSV file, CSV Files (*.csv)
if (InputFilePath == "")
    return
SplitPath, InputFilePath,Filename
FileDelete, %A_ScriptDir%\Libraries\%Filename%

flag := 1
Loop,
{
    FileReadLine, line, %InputFilePath%, %A_Index%
    if ErrorLevel
        break
    if (line != "")
    {
        strings := StrSplit(line, ",")
        trigger := strings[1]
        if (StrLen(trigger) <= 40)
        {    
            hotstring := strings[2]
            if (flag)
            {
                textline := % "‖" . trigger . "‖SI‖En‖" . hotstring . "‖"
                flag := 0
            }
            else
                textline := % "`n‖" . trigger . "‖SI‖En‖" . hotstring . "‖"
            FileAppend, %textline%, %A_ScriptDir%\Libraries\%Filename%, UTF-8
        }
    }
}
Msgbox, File has been exported to CSV file.