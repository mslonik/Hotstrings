| Exit codes (ExitApp) | Description                                                                 | Remarks for developers                     |
|:---------------------|:----------------------------------------------------------------------------|:-------------------------------------------|
| 0                    | Correct exit from application.                                              | –                                          |
| 1                    | Error reading library file, not-correct format of library line.             | F_CreateHotstring(txt, nameoffile)         |
| 2                    | Exit from application by (system) tray menu.                                | F_TrayExit()                               |
| 3                    | Required encoding for library files: UTF-8 with BOM.                        | F_CheckFileEncoding(FullFilePath)          |
| 4                    | Unsuccessful move of temp.exe on time of executable move.                   | F_VerUpdDownload()                         |
| 5                    | License is no longer valid / active.                                        | F_CheckCommTime()                          |
| 6                    | No license key specified on time of installation.                           | EnterLicenseGuiClose(); F_EnterLicenseB1() |
| 7                    | License activation unsuccessful. Entered license key was not found.         | F_EnterLicenseB1()                         |
| 8                    | License activation unsuccessful.                                            | F_CheckCommercialConditions()              |
| 9                    | Couldn't create "Languages" subfolder.                                      | Initialization                             |
| 10                   | License server response do not contain correct id of store or product.      | F_EnterLicenseB1()                         |
| 11                   | License instance was not found on this PC / user domain account.            | F_CheckCommercialConditions()              |
| 12                   | Registry write unsuccessful                                                 | F_EnterLicenseB1()                         |
| 13                   | "AppData\Hotstrings" subfolder wasn't created for some reason.              | F_CheckCreateConfigIni(params*)            |
| 14                   | Config.ini file couldn't be created for some reason.                        | F_CheckCreateConfigIni(params*)            |
| 15                   | Unexpected problem on time of deleting the file ""\Languages\English.txt"". | F_CheckCreateConfigIni(params*)            |
