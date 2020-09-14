# Hotstrings
AutoHotkey oriented GUI to Hotstrings with many useful features:
- applying clipboard (useful especially for long text strings),
- one hotstring can call several strings, chosen from menu,
- overview of existing hotstrings,
- definitions of hotstrings are stored in .csv files, as many, as you like,
- ...

This application is written in AutoHotkey script language but does not require this language interpreter to be installed and can be run standalone thanks to .exe file. (Nevertheless installation of [AutoHotkey](https://www.autohotkey.com/) is greatly adviced). The concept and usage of hotstrings is based on AutoHotkey hotstring notion.

# What are the hotstrings (absolute beginner quide)
There are two notions:
**triggering abbreviation** → **hotstring**

When someone enters the triggering abbreviation, it will be automatically replaced with hotstring.

Thanks to this application one can define as many pairs (triggering abbreviation and hotstring) as she/he likes and store them in convenient way in separate .csv files. Each file can contain hotstring belonging to specific category, e.g. emojis, physical symbols, first and second names etc.

# Main window
After installation just double click on the Hotstrings icon (marked in red) in system tray ![Example of system tray](/HelpPictures/Hotstring3_SystemTray.png) or... use hotkey Ctrl + # + h (Control + Windows key + h).
Next you'll see main GUI (Graphical User Interface) window which enable you to edit hotstrings:

![Main window](/HelpPictures/Hotstring3_MainWindow.png)

## Hotstring menu
![Main menu](/HelpPictures/Hotstring3_MainMenu.png)
- Monitor
- Search Hotstrings
- Delay
- Help
- About

In order to access menu by keyboard just press the left Alt key.

### Monitor
Enable choice of the monitor where main GUI window is shown. If GUI window is closed, application continues to run (system tray icon is still accessible). When GUI window is called again (by pressing the hotkey or by clicking with mouse) it will be displayed at monitor of your choice.

### Search Hotstrings
Enable searching of hotstring in any of the categories. All .csv files (category files) are searched. This option is helpful e.g. to find duplicates of hotstrings.

### Delay
Enable change of the delay between copying of the hotstring from clipboard to specific text window from which it was triggered.
By default equal to 200 ms. Maximum value equal to 500 ms (0.5 s).

**Tip:** Sometimes when long 
