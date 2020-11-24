#SingleInstance, Force
SetWorkingDir, %A_ScriptDir%

; If you want to export LibreOffice library to Hotstring.ahk application, you need to unzip the .dat file and select "DocumentList.xml" file

FileSelectFile, InputFilePath, 3,, Choose "DocumentList.xml" file, XML Files (DocumentList.xml)
if (InputFilePath == "")
    return
SplitPath, InputFilePath,, Path
PathSplit := StrSplit(Path, "\")
index := PathSplit.MaxIndex()
Filename := % PathSplit[index] . ".csv"
FileRead, InputFile, %InputFilePath%
Loop,
{
    StartPos := InStr(InputFile, "&#x")
    if (StartPos == 0)
        break
    EndPos := InStr(InputFile, ";",, StartPos)
    String := SubStr(InputFile, StartPos , EndPos-StartPos+1)
    UnicodeString := % "0x" . SubStr(String, 4 , StrLen(String)-4)
    InputFile := StrReplace(InputFile, String, Chr(UnicodeString))
}
InputFile := StrReplace(InputFile, "&lt;", "<")
InputFile := StrReplace(InputFile, "&gt;", ">")
FileDelete, test.xml
FileAppend, %InputFile%, test.xml, UTF-8
flag := 1
FileDelete, %A_ScriptDir%\Libraries\%Filename%
Loop,
{
    FileReadLine, line, test.xml, %A_Index%
    if ErrorLevel
        break
    if InStr(line, "block-list:abbreviated-name")
    {
        strings := StrSplit(line, """")
        trigger := strings[2]
        if (StrLen(trigger) <= 40)
        {    
            hotstring := strings[4]
            if (flag)
            {
                textline := % "*‖" . trigger . "‖SI‖En‖" . hotstring . "‖"
                flag := 0
            }
            else
                textline := % "`n*‖" . trigger . "‖SI‖En‖" . hotstring . "‖"
            FileAppend, %textline%, %A_ScriptDir%\Libraries\%Filename%, UTF-8
        }
    }
}
FileDelete, test.xml
Msgbox, File has been exported to CSV file.