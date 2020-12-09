# *Hotstrings* application
Written in [AutoHotkey][] script language, application *Hotstrings*  has many useful features:

- quick text replacement aka hotstrings; 
    
    *short alphanumeric strings (aka triggerstrings) are used to automatically replace long alphanumeric strings (aka hotstrings)*;
- defined hotstrings are operating system wide;

    *it means that can be triggered in any text / edit window, in any application; runs on Microsoft Windows family operating systems;*
- GUI (Graphical User Interface); 

    *for easy definition and/or edition of hotstrings*;
- clipboard ready;

    *useful especially for long text strings, as it enables entering the long hotstring in a blink of an eye*;
- one triggering abbreviation can call several different text strings of your choice;

    *chosen from menu*;
- overview of existing hotstrings with search capabilities;
- definitions of hotstrings are stored in .csv files, as many, as you like; 

    *each file can contain hotstring belonging to specific category, e.g. emojis, physical symbols, first and second names etc.*;
- undoing of hotstrings;

    *conversion of last entered hotstring again into triggering abbreviation*;

- written in AutoHotkey script language but does not require this language interpreter to be installed and can be run standalone thanks to .exe file;

    *nevertheless installation of [AutoHotkey][] is greatly adviced).*

---

# Table of content
1. [FAQ: Introduction to hotstrings](#faq-introduction-to-hotstrings)
 
  1.1. [What are the hotstrings?](#what-are-the-hotstrings)
 
  1.2. [How the *Hotstrings* application work?](#how-the-Hotstrings-application-work)

  1.3. [Why somobody may want to use hotstrings?](#why-somobody-may-want-to-use-hotstrings)

  1.4. [Why somebody may want to use *Hotstrings* application?](#why-somebody-may-want-to-use-Hotstrings-application)
    
  1.5. [How to reset the hotstring recognizer?](#how-to-reset-the-hotstring-recognizer)

2. [Installation of *Hotstrings* application](#installation-of-Hotstrings-application)

3. [The first run of *Hotstrings* application](#the-first-run-of-Hotstrings-application)

4. [Main window of *Hotstrings* application](#main-window-of-Hotstrings-application)
 
  4.1. [Menu](#Menu)
  
    4.1.1. [Configure](#configure)
   
      4.1.1.1. [Undo last hotstring](#undo-last-hotstring)
   
      4.1.1.2. [Triggerstring tips](#triggerstring-tips)
   
      4.1.1.3. [Save window position](#save-window-position)
   
      4.1.1.4. [Launch Sandbox](#launch-sandbox)
   
      4.1.1.5. [Toggle EndChars](#toggle-endchars)

    4.1.2. [Search *Hotstrings*](#search-hotstrings)

    4.1.3. [About / Help](#about-/-help)

  4.2. [Definition or edition of (triggerstring, hotstring)](#definition-or-edition-of-triggerstring-hotstring)

    4.2.1. [Enter triggerstring](#enter-triggerstring)

    4.2.2. [Select trigger option(s)](#select-trigger-options)
   
      4.2.2.1. [Default (no trigger option selected)](#default-no-trigger-option-selected)
   
      4.2.2.2. [Immediate Execute (asterisk)](#immediate-execute-asterisk)
   
      4.2.2.3. [No Backspace (B0)](#no-backspace-b0)
   
      4.2.2.4. [No End Char (O)](#no-end-char-o)
   
      4.2.2.5. [Case Sensitive (C\)](#case-sensitive-c)
   
      4.2.2.6. [Inside Word (question mark)](#inside-word-question-mark)
   
      4.2.2.7. [Disable](#disable)
   
    4.2.3. [Select hotstring output method](#select-hotstring-output-method)

      4.2.3.1. [SendInput (SI)](#sendinput-si)

      4.2.3.2. [Clipboard (CL)](#clipboard-cl)

      4.2.3.3. [Menu and SendInput (MSI)](#menu-and-sendinput-msi)

      4.2.3.4. [Menu and Clipboard (MCL)](#menu-and-clipboard-mcl)

    4.2.4. [Enter hotstring](#enter-hotstring)

    4.2.5. [Add a comment](#add-a-comment)

    4.2.6. [Select hotstring library](#select-hotstring-library)

    4.2.7. [Buttons](#buttons)

  4.3. [Library content](#library-content)

  4.4. [Shortcuts](#shortcuts)

5. [Libraries](#libraries)

  5.1. [PriorityLibrary.csv](#prioritylibrarycsv)

  5.2. [Abbreviations.csv](#abbreviationscsv)

  5.3. [AccentsDiacritics.csv](#accentsdiacriticscsv)

  5.4. [Autocorrect.csv](#autocorrectcsv)

  5.5. [CapitalLetters.csv](#capitalletterscsv)

  5.6. [EmojiHotstrings.csv](#emojihotstringscsv)

  5.7. [PhysicsHotstrings.csv](#physicshotstringscsv)

  5.8. [TimeHotstrings.csv](#timehotstringscsv)

  5.9. [Format of libraries](#format-of-libraries)

  5.10. [Import of libraries](#import-of-libraries)

  5.11. [Export of libraries](#export-of-libraries)

  5.12. [Enable or disable triggerstring tips](#enable-or-disable-triggerstring-tips)

  5.13. [Loaded hotstrings counter](#loaded-hotstrings-counter)

6. [Localization](#localization)

7. [Command line options](#command-line-options)

  7.1. [Light mode](#light-mode)

  7.2. [Debug mode](#debug-mode)

8. [Other remarks](#other-remarks)

  8.1. [Order of loading AutoHotkey scripts matter](#order-of-loading-autohotkey-scripts-matter)

  8.2. [Autostart of *Hotstrings* application](#autostart-of-Hotstrings-application)

  8.3. [Not always applying clipboard output function is a good idea](#not-always-applying-clipboard-output-function-is-a-good-idea)

  8.4. [Overlapping triggerstrings](#overlapping-triggerstrings)

9. [Credits](#credits)

  9.1. [Tools used to prepare this documentation](#tools-used-to-prepare-this-documentation)

10. [ToDo List](#todo-List)

---

# [FAQ: Introduction to hotstrings](#table-of-content "Return to Table of content")
(Frequently Asked Questions) about *Hotstrings* application and notion of hotstrings.


## [What are the hotstrings?](#table-of-content "Return to Table of content")
There are two corresponding notions:

- triggerstring,
- hotstring.

The relationship between these two notions is ruled by options and can be presented as follows:

user input | options | hostring recognizer | modified input
:---:|:---:|:---: | :---: |
triggerstring | (trigger) options | → | hotstring
alphanumeric string | alphanumeric string | → | alphanumeric string

So the *hostring recognizer* triggers the corresponding hotstring, taking into consideration:

* user input (what user writes pressing keys of keyboard)

* options defined for particular pair (*triggerstring*, *hotstring*)

Wording convention: usually the corresponding notions *(option(s), triggestring, hotstring)* are also called as *hotstring*.


## [How the *Hotstrings* application work?](#table-of-content "Return to Table of content")
### In short

 The *Hotstrings* application:
 
* keeps in memory definitions of hotstrings defined by user:  **(triggerstring, (trigger) option(s), hotstring)** 

and 

* applies the **hotstring recognizer** to input stream of keyboard pressed keys, searching for the **triggestring** according to rules defined in **option(s)**. 

If the **triggestring** is recognized (user pressed appropriate sequence of keys) and it fits to **option(s)**: 

* the **hostring** is issued,
* the **hotstring recognizer** is reset.

The concept and usage of hotstrings is based and compatible to AutoHotkey [hotstring][] notion.

### In long 
Please carefully analyse the **[Pic. 1](#picture-1)**. From the bottom up:

1. User sits in the front of input and output devices. Let's assume for this moment that input device is just a keyboard and output device is just a computer monitor.

2. The input / output devices are connected to computer which contains: 

   i. operating system (set or universe of various applications),
   ii. applications (set or universe of various applications).
   
3. We pay special attention to: 

   i. operating system: *Input Buffer*.
   ii. applications: *Hotstrings* and *Microsoft Word*.

The operating system exchange information with input device, character by character. Let's observe, what is going on (1-5 on the picture):

1. *Input*: user presses a key of keyboard. This key is send from input device to *Input Buffer*.
2. *Hotkeys* applications picks up information about new information in *Input Buffer*. It examines current content of the buffer with **hotstring recognizer**.
3. If **hotstring recognizer** recognizes one of the **triggerstrings** and conditions to trigger are met (determined by **option(s)**), the content of *Input Buffer* is altered accordingly (e.g. some characters are deleted, some are inserted).
4. Other applications, like *Microsoft Word*, get information from operating system and display / react to altered input accordingly.
5. Next *Microsoft Word* do some operations if required and output is send to *Output* (e.g. computer monitor).

```
                  +---------------------------------------------------------------------------------+
                  |                                                                                 |
                  |                                                                                 |
                  |                                                                                 |
 (UNIVERSE OF)    |                                                        +------------------+     |
 APPLICATIONS     |                                                        |                  |     |
                  |                                                        |    Microsoft Word|     |
                  |+--------------------------+                            |                  |     |
                  || Hotstrings               |                            +----^-------|-----+     |
                  ||                          |                                 |       |           |
                  ||                          |                                 |       |           |
                  ||                          |                                 |       |           |
                  |+----------^------|--------+                                 |       |           |
                  +-----------|------|------------------------------------------|-------|-----------+
                  |           |      |                                          |       |           |
                  |           |      |                                          |       |           |
                  |           |      |                                          |       |           |
                  |        2  |      | 3                                        |       |           |
 (UNIVERSE OF)    |           |      |                                          |       |           |
 OPERATING SYSTEM |           |      |                                          |       |    5      |
                  |       +---|------v---+                   4                  |       |           |
                  |       | Input Buffer ---------------------------------------|       |           |
                  |       +--------------+                                              |           |
                  |               ^                                                     |           |
                  |               |                                                     |           |
                  |               |                                                     |           |
                  +---------------|-----------------------------------------------------|-----------+
                                  |                                                     |            
                                  |                                                     |            
                                1 |                                                     |            
                                  |                                                     |            
                                  |                                                     |            
                  +---------------|---------------+                         +-----------v-----------+
                  |    INPUT                      |                         |  OUTPUT               |
                  |    e.g.                       |                         |  e.g.                 |
                  |    KEYBOARD                   |                         |  MONITOR              |
                  |                               |                         |                       |
                  |    character by character     |                         |                       |
                  |                               |                         |                       |
                  +-------------------------------+                         +-----------------------+
                                                            +-----+                                  
                                                            |     |                                  
                                                            |     |                                  
                                                        -\  +--|--+                                  
                                                          -\   |                                     
                                                            -\ |   /---                              
                                                THE USER      -----                                  
                                                               |                                     
                                                               --                                    
                                                             -/  \---                                
                                                           -/        \-                              
```
##### Picture 1

Long story about *Hotstrings* application.

## [Why somobody may want to use hotstrings?](#table-of-content "Return to Table of content")
Because they can significantly make life easier and... longer? Please see below just few supporting arguments.

* The triggestring can be short. Opposite to that the hotstring can be long in comparison to triggestring. As a consequence one can save some time when uses hotstrings.

---
*Example:* 

triggerstring | hotstring
---|---
title1 | This is very long title of technical document with lots of numeric data which are hard to remember EN 982182 : 12 and is reference in a few places in your newly edited document


* The triggerstring can be used to trigger special symbols / letters / emoji, which are not present on a keyboard. Then it can happen that the triggerstring could be longer than actual hotstring.

---
*Example:* 

triggerstring | hotstring
---|---
elephant/ | 🐘


* To correct / auto correct spelling of words or enter unique letters

---
*Example:*

triggerstring | hotstring
---|---
email | e-mail


* Nowadays we still frequently use keyboard as input device to so called personal computer. This computer is not so "personal" as you can't easily define system wide (working in any application) triggering your personal hotstrings. 

---
*Example:*
triggerstring | hotstring
---|---
fs@ | `FirstName.SecondName@yourhosting.com`


So let's make your PC really personal again. Now with use of hotstrings and Hotstring application.

## [Why somebody may want to use *Hotstrings* application?](#table-of-content "Return to Table of content")
Because it doesn't require much knowledege and text editing to run your own hotstrings. *Hotstrings* application can be run even without installation (e.g. from USB pendrive, run **Hotstrings.exe**). Thanks to GUI (Graphical User Interface) you will master defining and applying of your own hotstrings in a blink of an eye 😉.

The alternative, traditional way, is based on text edition, when hotstrings are prepared in AutoHotkey script (text file with .ahk extension), keeping attention to syntax of AutoHotkey syntax. Next such a script can be compiled into executive (.exe).


## [How to reset the hotstring recognizer?](#table-of-content "Return to Table of content")
- pressing of some keys immediately resets the **hotstring recognizer**, e.g.: \<→\>, \<←\>, \<↑\>, \<↓\>, \<PageUp\>, \<PageDown\>, \<Home\>, \<End\>;
- entering the **EndChar**;
- switching to another window;
- any click of any mouse button.


---

# [Installation of *Hotstrings* application](#table-of-content "Return to Table of content")
The *Hotstrings* application can be downloaded from [Github (Hotstrings)][]. The project structure:


| Level one      | Level two             | Comment                             |
| ---:           |  ---                  | ---                                 |
| Libraries      |                       | Folder                              |
| \|------       | Abbreviations.csv     | Examply library file                |
| \|------       | CapitalLetters.csv    | Examply library file                |
| \|------       | EmojiHotstrings.csv   | Examply library file                |
| \|------       | PhysicsHotstrings.csv | Examply library file                |
| \|------       | TimeHotstrings.csv    | Examply library file                |
| Config.ini     | ─                     | Configuration file                  |
| Hotstrings.ahk | ─                     | AutoHotkey script file              |
| Hotstrings.exe | ─                     | (Microsoft) Windows executable file |
| LICENSE        | ─                     | [GNU GPL ver. 3] license file       |

**Hint**. At the moment it's mandatory to run the *Hotstrings* application to keep above structure. It means there must be created the *Libraries* folder and *Config.ini* file must be present just aside the *Hotstrings* executable or .ahk file.

**Hint**. One can run *Hotstrings* application without installation of [AutoHotkey][] environment. In that case just run *Hotstrings.exe*. Nevertheless installation of [AutoHotkey][] environment is recommended.

# [The first run of *Hotstrings* application](#table-of-content "Return to Table of content")
In order to run the *Hotstrings* application after downloading of all the files just mark the *Hotstrings.ahk* file or *Hostrings.exe* file in your favorite file browser and hit <Enter>. Nothing special should happen as *Hotstrings* application starts in minimized form. The only visible occurrence is default icon visible in *System Tray*. (You can access the *System Tray* with your keyboard by pressing # + B shortcut and preśing <Enter>):

![Example of system tray][]

Now *Hotstrings* application runs in its default mode: **running mode**. All the (triggerstring, hotstring) pairs are activated, operating system wide. So no matter in which text window is currently active pointer, one can already benefit from loaded (if any) libraries of hostrings. Enjoy!

The second mode of operation requires GUI (Graphical User Interface) window, because then one can define new hotstrings or edit existing. When GUI window is active still all the (triggerstring, hotstring) pairs are ative, just GUI window is additionally available.


## Let's define the first hotstring
Our primary goal: we would like to define our first pair of (triggerstrin, hotstring). The **triggerstring** *btw* with the **hotstring** *by the way*, just for the sake of example: (*btw*, *by the way*).

In order to start the GUI of *Hotstrings* application just double click on the *Hotstrings* icon (capital letter *H* as *Hotstrings* on green background) in system tray:

![Example of system tray][] 

or... use hotkey **Ctrl + # + h** (Control + Windows modifier key + h).

Next you'll see main GUI (Graphical User Interface) window which enable you to edit hotstrings:

![Main window][]


At first please observe the main window again. In order to define any hotstring one have to follow top down the screen (in blue):

![Defining of hotstring][]

    1. Enter triggerstring.
    2. Select trigger option(s).
    3. Select hotstring output function.
    4. Enter hotstring.
    5. Select hotstring library.
    6. Add optional comment.
    7. Set the hotstring.


We will start by defining of *by the way* hotsring with plain *btw* triggerstring and no options.

### 1. Enter triggestring
Let's input in this text edit field triggerstring text: 
> btw

![Enter triggerstring, example][]

### 2. Select trigger option(s)
![Default trigger option][] 

By default no option is set (option string is empty). Then after **triggerstring** is entered, additionally one **trigger (endchar)** have to be entered by user in order to trigger the hotstring.

The *trigger key* is defined as one of the following *endchar*keys: -()[]{}':;"/\,.?!\`n☐\`t (note that \`n is Enter,  \`t is Tab, and there is a plain space between \`n and \`t marked as ☐ according to our convention). 

Let's leave no option set and continue to the next step.

### 3. Select hotstring output function
![Select hotstring output function][]

Select one and only one option from this list. By default *SendInput (SI)* is set. It means that the hotstring will be output by AutoHotkey SendInput function, without menu and not by Clipboard. More about *output functions* later on.

Let's leave it as it is.

### 4. Enter hotstring

Let's input our first **hotstring**:
> by the way

![Enter hotstring, example][]

### 5. Select hotstring library
This list contains all and only *.csv* files from withing folder *..\Hotstrings\Libraries*. One can have as many libraries (*.csv*) files as necessary.

Let's select the *AutocorrectionHotstring.csv* for sake of example. The new defined (**triggersring**, **hotstring**) pair will be added to this particular file.

![Select hotstring library][shl2]

### 6. Add a comment
This step is optional. User can add additional comment to new defined hotstring. It can be ueful in some situations, e.g. if some definitions are very similar to each other. For sake of this example let's leave this edit field empty.

![Add a comment][]


### 7. Set the hotstring
Select / click the *Set hostring* button. The function and meaning of two others is hopefully quite obvious. It will be explained in details later on.

![Set the hotstring][] 

### Congratulations!
You've defined your first hotstring. Have a look now into the left part of the main screen, into the *Library content*. Find there your newly defined hotstring:

![Library content][]

![Animated Gif1][]
---
---
---

Now let's dive into more detailed description of available functions

# [Main window of *Hotstrings* application](#table-of-content "Return to Table of content")

![Main window][]

The purpose of this window is enabling hotstring definition and/or edition.

It can be divided into the following parts:

    1. Menu.
    2. Hotstring definition or edition.
    3. Display of existing hotstrings: library content.
    4. Shortcuts.

![Main window parts][]

## [Menu](#table-of-content "Return to Table of content")

![Main menu][]

Available menu positions:

* Configure
* Search Hotstrings
* Clipboard Delay
* About / Help

In order to access menu by keyboard just press the left Alt key or F10 key.


### [Configure](#table-of-content "Return to Table of content")

![Menu: configure][]

The state of *Configure* menu is reflected in *Config.ini* file.

Available options:

#### [Undo last hotstring](#table-of-content "Return to Table of content")

This option can be toggled (*on* or *off*).

*If it is on:* when hotstring is triggered, user can undo it just after, by pressing usual shortcuts: **Ctrl + z** or **Ctrl + Backspace**. When shortcut is used, the **hotstring** is removed with **triggestring**: **hotstring** ← **triggestring**.

*If it is off:* when hotstring is triggered, reaction to shortcuts **Ctrl + z** or **Ctrl + Backspace** is application dependant. The *Hotstrings* application do not interfere.

*Tips*

It can be useful in numerous situations, e.g. if hotstring is very similar or identical to another word. Example: word 'can' and abbreviation 'CAN' (Controller Area Network).

This option can interfere with inbuild undo function in some application. It is known to be a problem in Inkscape application.

 **Caution:** In some applications the same hotkeys are used for undoing the last action. Then the overall result sometimes is unpredictable or unwanted. In case of some trouble use undoing hotstring several times in a raw.



#### [Triggerstring tips](#table-of-content "Return to Table of content")

This option can be toggled (*on* or *off*).

*If it is on:* when user is typing and some triggestrings are common to the actual string entered by user, additional list of available triggestrings is displayed at the tip of a cursor. Thanks to that user may consciously finish any of the available triggestrings in order to trigger on purpose any hotstring.

*If it is off:* no additional list of available triggerstrings is displayed.

Example: after entering 
>th

one can get:

![Menu: triggerstring tip][]

*Tips*

If this function is enabled, it helps to remember available triggestrings.

It starts to work after the second letter is entered.

#### [Save window position](#table-of-content "Return to Table of content")

This function is activated immediately after menu position is chosen. It saves current position of *Hotstrings* window. So when next time user will call for *Hotstrings* window (e.g. by double click over *Hotstrings* icon in system tray or pressing **Ctrl + # + h** shortcut), it will open in the last saved position (on the same screen).

#### [Launch Sandbox](#table-of-content "Return to Table of content")

This option can be toggled (*on* or *off*). The *Sanbox* stands for "safe place to play with a tool(s); the playground".

*If it is on:* the *Hotstrings* window is extended below the buttons, left column, with small editing window called *Sandbox* where user can check how actually pairs (**triggerstring**, **hotstring**) work in practice. 

*If it is off:* the *Hotstrings* window isn't extended anymore with *Sandbox* text editign window.

Example: *Sanbox* enabled.

![Menu: Launch Sandbox][]


*Tip*

Sometimes it can be helpful to check if new defined hotstring actually work as expected. In order to check it one should find any text editing window, e.g. open text editor. The *Sandbox* helps to spare some time in such situation.

#### [Toggle EndChars](#table-of-content "Return to Table of content")

This option let user to toggle each of the **EndChars** individually.

![Menu: Toggle EndChars][]

*Tip*

Let's imagine user input string, so stream of keyboard pressed keys: 

*Example☐of☐the☐sentence☐where☐user☐would☐like☐to☐exchange☐triggerstring☐e@☐with☐his☐e-mail:☐`firstname.secondname@domain.com`*

The **hostring recognizer** observes input stream which contains besides letters also other categories of characters: digits, punctuation characters, blank characters, special characters etc. Some of them belong to special group called end character or *endchar* for short. The characters belonging to the *endchar* group has the following purposes, helping to **hotstring recognizer**:

1. recognize when **triggestring** begins,
2. recognize when **triggerstring** ends,
3. reset itself.

Maybe *endchar* is not the right therm and better would be *stopchar* or *trigger separator*? For compatibility with official documentation of AutoHotkey the term *endchar* is kept in this manual.

By default **triggerstring** begins after a character belonging to *endchar* but with special **trigger option** called *Inside Word (?)* it can trigger **triggerstring** even between *endchar*, e.g. witin a word. It's done on purpose that *endchar* by default containts the following set of characters: 

-()[]{}':;"/\,.?!\`n☐\`t 

(note that \`n is Enter, \`t is Tab, and there is a plain space between \`n and \`t marked as ☐). 

These characters are usually used to separate words or sentences. So often **hotstring recognizer** starts to recognize if **triggestring** is there, word by word and resets after each *endchar*. 

User of *Hotstrings* application can change this default behavior thanks to configuration of *endchar*. 



### [Search *Hotstrings*](#table-of-content "Return to Table of content")
Enable searching of hotstring among all available libraries. New window is opened.

![Menu: Search Hotstrings][]

*Tips:*

In order to quickly close this window it is enough to press <Esc> key.

All .csv files (library files) are searched. This option is helpful e.g. to find duplicates of hotstrings.

This window is helpful for finding duplicates of hotstrings. After some time or in particular if the same set of libraries is used by group of users, it can be the case that some of the triggerstrings are duplicated. Then is is nice to have option to find them and... move them along the existing libraries. 

In order to move library in this window is available **Move** button.

In order to delete duplicated (**triggerstring**, **hotstring**) definition one can mark it, next close the *Search Hotstrings* window and then choose the **Delete hotstring** button.


### [Clipboard Delay](#table-of-content "Return to Table of content")
Enable change of the delay between copying of the hotstring from clipboard to specific text window from which it was triggered.
By default equal to 200 ms. The maximum value is equal to 500 ms (0.5 s).

The separate window is opened for that purpose:

![Menu: Clipboard Delay][]

*Tip:* Sometimes when long hotstrings are triggered and clipboard is applied to immediately enter it, strange behaviour can occurre. Instead of expected hotstring the previous content of clipboard may appear. The reason is that operating system can not gurantee the time to insert the content of clipboard into specific window / editing field. In order to support operating system, enlarge the delay. The shorter the delay than better, but if too short, mentioned behaviour can be observed.

### [About / Help](#table-of-content "Return to Table of content")
 
 ![About / Help][] 

**Hotstrings.ahk (script). Let's make your PC personal again...**. 

Displays the following text:

*Enables convenient definition and use of hotstrings (triggered by shortcuts longer text strings). This is 3rd edition of this application, 2020 by Jakub Masiak and Maciej Słojewski (🐘). License: [GNU GPL ver. 3][]. [Source code][]. [Maciej's homepage][].*

*Comments:*

**Application help**: link to this file.

**Genuine hotstrings AutoHotkey documentation**: link to [hotstring][] documentation.

## [Definition or edition of (triggerstring, hotstring)](#table-of-content "Return to Table of content")

This time all 7 steps discussed in details, with examples and comments.

### [Enter triggerstring](#table-of-content "Return to Table of content")

The text edit field used to define the triggerstring.

![Enter triggerstring][]

In general the shorter triggerstring then the better. The triggerstring can be at most 40 characters long. This edit field works as any other ordinary window edit field, so it doesn't support e.g. text block operations.

The *Hotstrings* application doesn't have protection agains duplicate (**triggerstring**, **hotstring**) pairs: user can accidently duplicate them, adding the same definition to different libraries. Therefore its worth to search prior to adding new definition if it doesn't exist already.

### [Select trigger option(s)](#table-of-content "Return to Table of content")
Trigger options controls how **hotstring recognizer** works. All these options can be used concurrently. For clarity in the following descriptions each of them is described separatedly.

![Select trigger option(s)][]

**Tab. 1.** Trigger options compatibility between AutoHotkey [hotstring] and *Hotstrings* app.
|   Option full name  | Option short name | AutoHotkey | *Hotstrings* application |     Comment     |
|:-------------------:|:-----------------:|:----------:|:------------------------:|:---------------:|
| No option (default) |                   |      X     |             X            |       GUI       |
|  Immediate Execute  |         *         |      X     |             X            |       GUI       |
|     Inside Word     |         ?         |      X     |             X            |       GUI       |
|     No Backspace    |         B0        |      X     |             X            |       GUI       |
|    Case Sensitive   |         C         |      X     |             X            |       GUI       |
|      No Endchar     |         O         |      X     |             X            |       GUI       |
|        Execute       |         X         |      X     |                          | not implemented |
|   Reset Recognizer  |         Z         |      X     |                          | not implemented |
|       Disable       |       En/Dis      |            |             X            |       GUI       |
                                                                                 
                                                    
Comments:

* GUI (Graphical User Interface) means that specified option is directly available in the GUI of this application.

**Tab. 2.** Comparison of implemented **option(s)** valid for **trigger recognizer**.
| option full name    | option shortname | previous endchar required? | triggestring erased? | separate trigger? | trigger erased? | triggerstring case sensitive? |
|---------------------|:---------:|:--------------------------:|:--------------------:|:-----------------:|:---------------:|:-----------------------------:|
| No option (default) |           |             yes            |          yes         |        yes        |        no       |               no              |
| Immediate Execute   |     \*    |             yes            |          yes         |         no        |       n.a.      |               no              |
| Inside Word         |     ?     |             no             |          yes         |        yes        |        no       |               no              |
| No Backspace        |     B0    |             yes            |          no          |        yes        |        no       |               no              |
| Case Sensitive      |     C     |             yes            |          yes         |        yes        |        no       |              yes              |
| No End Char         |     O     |             yes            |          yes         |        yes        |       yes       |               no              | 

Comments:

Please note that there are just 5 trigger conditions which represent answers to the following questions:
1. Is previous endchar required? 
   
   If answer to this question is positive (yes), then the **hotstring recognizer** starts its work only just after the last *endchar* or reset. Another words it's only able to recognize the **triggerstring** if it starts new phrase or word. 
   
   If answer to this question is negative (no), then the **hotstring recognizer** starts its work just after the last *endchar* or reset, but is able to determine presence of **triggerstring** even in a middle of a phrase or word. 
   
   By default only one option (?) let you search for **triggerstring** within the words.
   
2. Is the **triggerstring** erased after the **hotstring**?

   If answer to this question is positive (yes), then after trigger condition is met the **triggerstring** is ~~erased~~ before **hotstring** is output.
   
   If answer to this question is negative (no), the after trigger condition is met the **triggerstring** is not erased before **hotstring** is output.
   
   By default only the option (B0) let you not erase the **triggerstring** before **hotstring** is output.
   
3. Is the trigger character separated from **triggerstring**?

   If answer to this question is positive (yes), then after the **triggerstring** the *endchar* is required to output the **hotstring**.
   
   If answer to this question is negative (no), then trigger is the last character of **triggerstring**. Another words the *endchar* is not required after the **triggerstring** to output the **hotstring**.
   
   By default only the option (\*) let you use the last character of **triggerstring** as a trigger.
   
4. Is the trigger character erased after the trigger conditions are met?

   If answer to this question is positive (yes), then the trigger (*endchar*) is ~~erased~~ when triggering condition is met.
   
   If answer to this question is negative (no), then the trigger (*endchar*) is not erased when triggering condition is met.

   By default only the option (O) ~~erases~~ the trigger(*endchar*) when triggering conditions are met.
   
   The abbreviation *n.a.* in this column means *not applicable*, as for option (\*) there is no trigger character.

5. Is the **triggerstring** case sensitive?

   If answer to this question is positive (yes), then the **triggerstring** is case sensitive.
   
   If answer to this question is negative (no), then the **triggerstring** isn't case sensitive.
   
   By default only the option (C) let the **triggerstring** to be case sensitive.

---

#### [Default (no trigger option selected)](#table-of-content "Return to Table of content")
![Example, no options][] 

| triggerstring |  hotstring | option(s) |
|:-------------:|:----------:|:---------:|
|      btw      | by the way |           |

*Example, execution*
Comment: cursor position is shown as |.

| input string         | previous *endchar* | triggerstring | trigger (*endchar*) | replaced by hotstring | trigger (*endchar*) |
|----------------------|:------------------:|---------------|:-------------------:|:---------------------:|:-------------------:|
| Something,☐something |          ☐         | ~~btw~~       |        ~~☐~~        |       by☐the☐way      |          ☐\|          |

> Something,☐something☐~~btw☐~~by☐the☐way☐|

---

#### [Immediate Execute (asterisk)](#table-of-content "Return to Table of content")
![Example, immediate execute][] 

| triggerstring |  hotstring | option(s) |
|:-------------:|:----------:|:---------:|
|      btw/     | by the way |     \*    |

The option (\*) is called *immediate execute* because  entering of the last character of **triggerstring** immediately executes exchange of the **triggerstring** with the **hotstring**. Cursor position is shown as |.

*Example, execution*

| input string         | previous *endchar* | triggerstring | trigger | replaced by hotstring | trigger |
|----------------------|:------------------:|---------------|:-------:|:---------------------:|:-------:|
| Something,☐something |          ☐         | ~~btw/~~      |         |       by☐the☐way\|      |         |

> Something,☐something☐~~btw/~~ by☐the☐way|

---

#### [No Backspace (B0)](#table-of-content "Return to Table of content")
![Example, no Backspace][] 

| triggerstring |  hotstring | option(s) |
|:-------------:|:----------:|:---------:|
|      btw      | by the way |     B0    |

The **triggerstring** is not removed. The **hotstring** is placed just after the trigger (*endchar*). Cursor position is shown as |.

*Example, execution*

| input string         | previous *endchar* | triggerstring | trigger (*endchar*) | added hotstring |
|----------------------|--------------------|---------------|:-------------------:|-----------------|
| Something,☐something | ☐                  | btw           |          .          | by☐the☐way\|    |

> Something,☐something☐btw.by☐the☐way|



*Example of useful B0 hotstring*

![Example, useful B0][]

| triggerstring |    hotstring   | option(s) |
|:-------------:|:--------------:|:---------:|
|     \<em>     | \</em>{left☐5} |    B0*    |

The B0 option is useful for example to define HTML tags. In the following example the sequence {left☐5} is used to move to the left (back) cursor (shown as |) after he sequence </em> is entered. So now the cursor is in a feasible place.

| input string         | previous *endchar* | triggerstring | trigger | added hotstring |
|----------------------|--------------------|---------------|---------|-----------------|
| Something,☐something | ☐                  | \<em>         |         | \|\</em>        |

> Something,☐something☐\<em>|\</em>

---

#### [No End Char (O)](#table-of-content "Return to Table of content")

![Example No EndChar][] 

| triggerstring |  hotstring | option(s) |
|:-------------:|:----------:|:---------:|
|      btw      | by the way |     O     |

The trigger (*endchar*) is removed. Cursor position is shown as |.

*Example, execution*

|     input string     | previous *endchar* | triggerstring | trigger | replaced by hotstring |
|:--------------------:|:------------------:|:-------------:|:-------:|:---------------------:|
| Something,☐something |          ☐         |    ~~btw~~    |  ~~☐~~  |      by the way\|     |

> Something,☐something☐~~btw☐~~by☐the☐way|

---

#### [Case Sensitive (C\)](#table-of-content "Return to Table of content")
![Example Case Sensitive][] 

| triggerstring |  hotstring | option(s) |
|:-------------:|:----------:|:---------:|
|      Btw      | by the way |     C     |

Similar to default option, but this time the **triggerstring** is case sensitive. Cursor position is shown as |.


*Example, execution*

|     input string     | previous *endchar* | triggerstring | trigger | replaced by hotstring |
|:--------------------:|:------------------:|:-------------:|:-------:|:---------------------:|
| Something,☐something |          ☐         |    ~~Btw~~    |  ~~☐~~  |     by the way☐\|     |

> Something,☐something☐~~Btw☐~~by☐the☐way☐|

---

#### [Inside Word (question mark)](#table-of-content "Return to Table of content")
![Example, Inside Word][]

Similar to default option, but this time *endchar* directly before the **triggerstring** is not required.

| triggerstring |  hotstring | option(s) |
|:-------------:|:----------:|:---------:|
|      btw      | by the way |     ?     |

---
*Example, execution*

|     input string     | previous *endchar* | triggerstring | trigger | replaced by hotstring |
|:--------------------:|:------------------:|:-------------:|:-------:|:---------------------:|
| Something,☐something |                    |    ~~btw~~    |  ~~☐~~  |     by the way☐\|     |

> Something,☐something~~btw☐~~by☐the☐way☐|


---

#### [Disable](#table-of-content "Return to Table of content")
![Disable example][]

The **hotstring** definition is left in library file (.csv) in the same state as on time of last edition, but is disabled (switched off). So **hotstring recognizer** does not detects it anymore. 

The opposite action can take place upon user action: if user will edit definition of particular *hotstring* and uncheck the tick *disable*, then *hotstring* becomes active again. Next time when corresponding **triggerstring** will occurre in input stream, the **hotstring recognizer** will trigger corresponding *hotstring* according to previously defined **option(s)**.


## [Select hotstring output method](#table-of-content "Return to Table of content")


**Tab. 3.** Output method compatibility between AutoHotkey [hotstring] and *Hotstrings* app.
| Option full name | Option short name | AutoHotkey | *Hotstrings* application |                  Comment                  |
|:----------------:|:-----------------:|:----------:|:------------------------:|:-----------------------------------------:|
|    Raw output    |         R         |      X     |                          |              Not implemented              |
|     SendInput    |         SI        |      X     |             X            |            GUI           |
|     SendPlay     |         SP        |      X     |                          |              Not implemented              |
|     SendEvent    |         SE        |      X     |                          |              Not implemented              |
|     Text raw     |         T         |      X     |                          | Not implemented |
|     Clipboard    |         CL         |            |             X            |                    GUI                    |
| Menu & SendInput |        MSI       |            |             X            |                    GUI                    |
| Menu & Clipboard |        MCL        |            |             X            |                    GUI                    |

Only one ouput method is valid at a time for particular **hotstring**.

### [SendInput (SI)](#table-of-content "Return to Table of content")

The default output function, common with AutoHotkey SendInput. The **hotstring** is send character by character. It goes very fast, but if **hotstring** is long, is noticable for user. Therefore if long **hotstring** have to be send, one can consider *Clipboard (CL)* output function.

### [Clipboard (CL)](#table-of-content "Return to Table of content")

The **hotstring** is copied to *clipboard* (part of memory, managed by operating system) and then pasted from clipboard to specific application, as requested by user. Thanks to that it is possible to enter even very long **hotstrings** "at once", in a blink of an eye.

The downside of this method is that in Microsoft Windows operating system time required to paste content of *clipboard* is neither specified nor guaranteed. The *Hotstrings* application enable change of this time by menu: Configure → Clipboard Delay. Also check description above.

### [Menu and SendInput (MSI)](#table-of-content "Return to Table of content")

Sometimes it is the case that one **triggerstring** is valid for several **hotstrings**.

Example:

| Triggerstring | Hotstring |
| :---: | :---: |
| bom/ | Bill of Materials |
| bom/ | Byte Order Mark |

This output function enable convenient solution. Let's check how that particular **hotstring** definition looks like:

![Hotstring Menu Example][]

The *Hotstrings* application enable up to 7 different **hotstrings** to be triggered by one **triggerstring**. The function *Menu & SendInput (MSI)* outputs all **hotstring** by the *SendInput* (character by character). The first definition from the list is the default one.

When user enters the **triggerstring** associated with several **hotstrings**, the following menu opens on a screen close to the mouse pointer:

![Output function: menu][]

The default **hotstring** is the first one from the top. To enter it just press <Enter>. To enter any other **hotstring** use keys <↑> <↓> and press <Enter>. Clicking by mouse is not supported. In order to cancel (undo), just press <Esc> key.

*Tip*. In some languages (e.g. German, Polish) form of a noun changes depending on grammar rules called [declension]. The menu option is in particular helpful to keep correct form of a nouns for first and second names.

### [Menu and Clipboard (MCL)](#table-of-content "Return to Table of content")
As above, with one exception: the **hotstrings** are output by clipboard, with all the consequences as described for *Clipboard (CL)* output function.

### [Enter hotstring](#table-of-content "Return to Table of content")

![Enter hotstring][]

The edit text field used to display / edit the **hotstring**. The single hotstring can be up to 5000 characters long. 

When *Hotstrings* application GUI window is available (no matter in mimized state or not) and you press <Ctrl> + <c> shortcut (copy), then copied content is automatically pasted to this field.

If **hotstring** output function is set to function **SendInput (SI)** (or **Menu & SendInput (MSI)**) , then ss a consequence special characters such as {Enter} or {+} are supported. See [key names] for complete list. 

In particular Unicode characters (e.g. emojis) can be entered both ways: explicite (e.g. 🐘) or as hexadecimal Unicode character: {U+1F418}.

*Tip*: Advice: for Unicode characters it is good to keep double representation, when defining **hotstring**: if you choose explicite Unicode character as **hotstring**, add its hexadecimal version to *comment section* of the definition and other way around: if you choose hexadecimal form, add explicite version to *comment section*. This way you will never loose track of your special characters.

If **hotstring** output function is set to function **Clipboard (CL)** (or **Menu & Clipboard (MCL)**), then hotstring, including special characters is send raw, e.g. {Enter} is send with opening and closing curly bracket.

### [Add a comment](#table-of-content "Return to Table of content")

![Add a comment][]

Optional (not mandatory) part of (**triggerstring**, **hotstring**) definition. Added to library (.csv) files and also displayed in *Library content* and *Search* window as the last column to the right.

*Tip*. Can be useful in some circumstances, for example to add a source of a **hotstring** definition in form of URL (a link).

### [Select hotstring library](#table-of-content "Return to Table of content")
![shl1][]

List of text files with extenstion .csv available in *../Libraries* folder of *Hotstrings* application. 

Together with *Hotstrings* application just few files are delivered. These files can be seen as set of good practices or examples in order to aid user with management of newly created (**triggerstring**, **hotstring**) pairs.

The .csv files are chosen from *Hotstring library* drop-down list.

There is no limitation for number of .csv files stored within *../Libraries* folder. All hotstrings are uploaded on time of (re)start of *Hotstrings* application.

If user would like to create new .csv file, the **Add library** button should be pressed. Next name of the new .csv file have to be specified. The newly created file will be located within *../Libraries* folder.

*Tip*. Try to store (**triggerstring**, **hotstring**) which are somehow related to each other in separate .csv files. The files shouldn't be too long, because searching / management of them can be cumbersome at certain point.

### [Buttons](#table-of-content "Return to Table of content")

![Buttons][]

**Set hotstring**: sets configuration for (**triggerstring**, **hotstring**) pair. Also if (**triggerstring**, **hotstring**) pair is edited (changed) in any way, this button have to pressed in order to apply the change. Whenever this button is pressed, also corresponding library file (.csv) is updated.

**Clear**: when pressed, all configuration fields of (**triggerstring**, **hotstring**) pair are cleared except of hotstring library, which will be still preselected.

**Delete hotstring**: deletes selected in the right part of the screen (table: *Library content*) pair of (**triggerstring**, **hotstring**). The pair is permanently deleted, so prior to that user have to confirm her/his decision. Next, if decision is positive, the *Hotstrings* application restarts.

Comment: Restart is required as a selected (**triggerstring**, **hotstring**) pair is removed from library file (.csv). In order to just switch off (e.g. temporarily) any selected pair (**triggerstring**, **hotstring**), use *Disable* setting in *Select trigger option(s)* section.

## [Library content](#table-of-content "Return to Table of content")

![Library content][]

Right part of the *Hotstrings* window in form of a table. It can be reached e.g. by pressing <F2> shortcut. Next user can move down / up over this list with keys <↑> and <↓>. Each time user selects row of this table, the next definition of (**triggerstring**, **hotstring**) is ready to be edited.

## [Shortcuts](#table-of-content "Return to Table of content")

These are permanently visible keyboard shortcuts. 

The following keyboard shortcuts are active only if *Hotstrings* application window is active:

| Keyboard shortcut / Function | Description |
| :--- | :--- |
| F1 About/Help | see [About / Help](#About-/-Help) |
| F2 Library content | see [Library content](#Library-content) |
| F3 Search hotstrings | see [Search Hotstrings](#Search-Hotstrings) | 
| F5 Clear | see [Buttons](#Buttons) |
| F7 Delay | see [Clipboard Delay](#Clipboard-Delay) |
| F8 Delete hotstring | see [Buttons](#Buttons) |
| F9 Set hotstring | see [Buttons](#Buttons) |


The following keyboard shortcuts are active only if *Search Hotstrings* application window is active:

| Keyboard shortcut / Function | Description |
| :--- | :--- |
| F3 Close Search hotstrings | see [Search Hotstrings](#Search-Hotstrings) |
| F8 Move hotstring | see [Search Hotstrings](#Search-Hotstrings) |


---
---
---

## [Libraries](#table-of-content "Return to Table of content")

Library is just a collection of **(triggerstring, hotstring)** definitions, saved for future use in form of a file.

If *Hotstrings* application can be compared to a car, then library is a fuel to this car. 

By default *Hotstrings* application is delivered with few example libraries, listed in the following chpaters. Anytime user applies changes to existing definitions or adds new, result of her/his work is saved in any of the chosen libraries.

The *Hotstrings* application can be downloaded with just few examples of libraries. All libraries stored in */Libraries* folder are uploaded in alphabetical order, when  application starts. 

Among all libraries one plays spcific role. The *Hotstrings* application recognizes library name *PriorityLibrary.csv*. That library is uploaded as the last one in the order. See description of this library for further details. 


*Tips*:

 * The *Hotstrings* application is just the tool which makes management of big collections of **(triggerstring, hotstring)** easier. It means that it could be more useful to keep big files in form of static, native libraries (.ahk) whereas some other, which are frequently changed, in format of *Hotstrings* (.csv). Remove unwanted / not used libraries from folder */Libraries* to any other folder.

 *  Editing of files / properties of  **(triggerstring, hotstring)** is easier with *Hotstring* application then ever before. You don't have to manually edit .ahk files anymore, instead of that use full power of *Hotstrings* GUI.

 * It is advised to group definitions **(triggerstring, hotstring)** in dedicated files, and not to keep them all in one file. Maybe at the beginning it looks tempting, but in fact, from long time perspective, is a mistake. 
 
 * Reminder: one can move single definitionsbetween libraries. Look into description of *Move* function, *Search* GUI window.

 * If user of Windows 10 have enabled  *notifications & actions* for AutoHotkey scripts (*Settings → System → Notifications & actions →  Get notifications from these senders → AutoHotkey Unicode*) then the *TrayTip*  will occure on time of startup, when the first library is uploaded. And when the last library definition is uploaded, the corresponding *TrayTip* is displayed. When big in volume libraries are uploaded (~tousands of libraries), it could take several seconds to be accomplished.

![TrayTip start][]

![TrayTip finish][]

### [PriorityLibrary.csv](#table-of-content "Return to Table of content")

This library contains collection of  **(triggerstring, hotstring)** definitions which are uploaded as the last in order. Another words, all the library files (.csv) are uploaded from */Library* subfolder in alphabetical order, but then the *PriorityLibrary.csv* is uploaded as the last one. Thanks to that the definitions from that library "cover" any other existing definition. 

*Tips*:

 * This feature can be helpful if library files are centrally stored, e.g. in version control system of any kind (e.g. Git, SVN, Sharepoint etc.) and automatically managed and uploaded on start-up of your PC, what in your work environment can be a routine administered beyond your control. Nevertheless you don't like some specific definitions. Then you can rule them out thanks to this library: define your own definition of the same **triggerstring** with different **hotstring**, e.g. void.

### [Abbreviations.csv](#table-of-content "Return to Table of content")

This library contains a stub  collection of frequently used abbreviations (e.g. *ASCII*) and corresponding expansion of abbreviations (e.g. *American Standard Code for Information Interchange*). **Triggerstrings** of almost all abbreviations are defined without triggerstring options, but they can be entered without pressing <Shift> key, just with small letters and then will be automatically capitalized. It speeds up a lot process of text entering, as capital letter in fact requires two key presses instead of just one.

The convention used in this library:
 * to get existing abbreviation in capital letters, just enter it and add **EndChar**, e.g. \<Spacebar\>: *ascii☐*,
 * to get expansion of existing abbreviation just enter it and add \</\> at the very end: *ascii/ *

|     input string     | previous *endchar* | triggerstring | trigger | replaced by hotstring |
|:--------------------:|:------------------:|:-------------:|:-------:|:---------------------:|
| Something,☐something |                    |    ~~ascii~~    |  ~~☐~~  |     ASCII☐     |

> Something,☐something~~ascii☐~~ASCII☐


|     input string     | previous *endchar* | triggerstring | trigger | replaced by hotstring |
|:--------------------:|:------------------:|:-------------:|:-------:|:---------------------:|
| Something,☐something |                    |    ~~ascii~~    |  ~~/~~  |     American Standard Code for Information Interchange    |

> Something,☐something~~ascii/~~American Standard Code for Information Interchange

### [AccentsDiacritics.csv](#table-of-content "Return to Table of content")

This library contains a collection of accents (diacritic) letters, small and capital, e.g. *ä, Ä, ø, Ø, ř, Ř*.  If somebody plans to use just some accents without permanent switching to other keyboard layout, then it could be handy to quickly enter diacritics with trick available in triggerstrings of this library. In order to enter small or capital accent letter just enter latin leter and add <^> (caret) immediately after. One will get menu with choice of some available accents related to base latin letter.

**Triggerstrings** are defined with additional options:

* Immediate execute (*)

* Case sensitive (C) 

* Inside word (?)

The convention used in this library:
 * to get accented letter (diacritic)  just enter corresponding base letter and add **^**, e.g. *r^*.

|     input string     | previous *endchar* | triggerstring | trigger | replaced by hotstring |
|:--------------------:|:------------------:|:-------------:|:-------:|:---------------------:|
| Something,☐something |                    |    ~~r~~    |  ~~^~~  |     ř    |

> Something,☐something~~r^~~ř

*Tips*: There are available other AutoHotkey tools which enable entering of accented letters (diacritics). To name just two:

* [Diacritic] by mslonik (🐘): enable entering of accent / diacritic letters without touching of AltGr (right Alt key).

* [Accents] by Skrommel: press a key three times or more to apply accents.

### [Autocorrect.csv](#table-of-content "Return to Table of content")

This library containts exact representation of famous *[AutoCorrect.ahk]*. The *Autocorrect.ahk* has been imported to *Hotstrings* application, so its format was altered from .ahk to .csv. Additionally to make import possible, AutoHotkey code (the first couple of lines from this script) was stripped away before import. As a result only plain AutoHotkey hotstring definitions have been left and imported to *Hotstring* application.

Its principal purpose is as part of the spell checker to correct common spelling or typing errors, saving time for the user. 

As *Hotstring* application uses dynamic definitions only, all 4 800 definitions from *Autocorrect.csv* are dynamic, can be edited, disabled and so on at eny given moment. What can be interesting, process of uploading those definitions into computer memory is noticeable and take significant amount of time.

*Tips*:

* Use of this library could be subject of dispute as it let you repeat common typing errors without process of learning (self-improvement).

* In *Hotstrings* application by default triggerstring tips are enabled. The purpose of triggerstring tips is to support memory of user and show you which **triggerstring** are available / can be triggered. The *Autocorrect.csv* library contains literally tousends of mispellings. They take away precious space in triggerstring tip lists and also slow down a lot process of sorting triggerstring tips. Therefore it is advisable to switch off triggerstring tips for this library. Just enter menu: *Libraries configuration* →  *Enable/disable triggerstring tips* →  untick *Autocorrect.csv*.

### [CapitalLetters.csv](#table-of-content "Return to Table of content")

This library contains proper names, which uses capital letters. The purpose of this library is to let you use just small letters also for such proper names. E.g. *github* is proper name of web portal which provides hosting for software development. Proper name is not *github* but *GitHub*. The library supports memory of user and changes automatically such strings into proper names with great speed.

As proper names most of the time are unique text strings and cannot be confused with common, dictionary words, definitions are triggered with *Immediate Execute (\*)* option.

*Tip*: If company uses unique abbreviation just to name its product, it could be advisable to add its definitions as separate *Hotstrings* library.

### [EmojiHotstrings.csv](#table-of-content "Return to Table of content")

This library contains emojis and sequences of emojis in a form which supports to some degree remembering them. 

Examples: 

* if one would like to put emoji of a cat (animal), can just add one more key </> to such a word to get Unicode representation (emoji icon) of this animal: 🐈.

* sequence of emojis for flowers can be shown just adding one more key </> to the word flowers: 💐: 🌹🍀🌻🌺🌸.

*Tip*: In Microsoft Windows 10 operating system emojis are available system wide thanks to shortcut <#> + <.> where <#> stands for Windows meta key.

### [PhysicsHotstrings.csv](#table-of-content "Return to Table of content")

This library contains various abbreviations useful to enter special characters used in physics and mathematics, but not only. 

*Tip*: Big "office" suits (Microsoft Word, Libre Office) contain big collections of definitions dedicated to mathematics and physics. Please consider importing them for the same purpose.

### [TimeHotstrings.csv](#table-of-content "Return to Table of content")

This library contains  example definitions related to date/time. The AutoHotkey [Date and Time] constants can be used to define new **(triggerstring, hotstring)** definitions of this kind.

*Tip*: I like when certain file names, e.g. pictures, starts from date. To make sorting of filenames easier I abbreviate it in form "yyyymmdd_". For that purpose I have prepared definition which works good in file manager of my choice (*Total Commander*).

## [Format of libraries](#table-of-content "Return to Table of content")

The libraries are avaiłable in text format (human-readable) called CSV. All library files have therefore extension .csv. The CSV = Comma Separated Values, special format where "values" are separated by certain, dedicated character, e.g. comma. In case of *Hotstrings* application the  Unicode character "Double Vertical Line" is used: ‖ (U+2016). 

It is not enough for text file to have .csv extension to be recognized by *Hotstrings* application. Such file have to have also dedicated structure.

 | Section | Separator | Section | Separator | Section | Separator | Section | Separator | Section | Separator | Section
 | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
 | triggerstring options | ‖ | triggerstring | ‖ | output function | ‖ | status: Enabled / Disabled | ‖ | hotstring or group of hotstrings\* | ‖ | optional: comment |

\* group of hotstrings: if *hotstring output function* is equal to menu (Menu & Clipboard (MCL) or Menu & SendInput (MSI)) then hotstrings are separated with Unicode character "Broken Bar": ¦ (U+00A6).

*Example*:
| triggerstring options | ‖ | triggerstring | ‖ | output function | ‖ | status: Enabled / Disabled | ‖ | hotstring or group of hotstrings\* | ‖ | optional: comment |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| \* | ‖ | bom/ | ‖ | MSI | ‖ | En | ‖ | Bill of Materials¦Byte Order Mark | ‖ |

## [Import of libraries](#table-of-content "Return to Table of content")

Existing collections of **(trriggerstring, hotstring)** definitions in form of static auto-replace .ahk files can be imported into *Hotstrings* application. Before you start, make sure that such a file contains only definitions. It means that if .ahk file contains additionaly some lines of code, that code have to be stripped out first. A good example is process of importing [Autocorrect.ahk]. 

If the file is correctly imported (converted from .ahk to .csv format), then it is automatically loaded and added to list "Select hotstring library".

*Tips*:

 * One can find collections of existing auto-replace .ahk files on Internet. Up to now there is no central place where collections are stored, sorry.
 * In so called application office suits are autocorrect collections (*Libre Office*, *Microsoft Office*), which can be exported from those and imported to *Hotstrings* application. This can be especially useful for foreign  languages, which are not so greatly supported as it is in case of English language with [Autocorrect.ahk].
 * Big collection of autocorrect definitions for various languages in Libre Office is available at GitHub: [Libre Office dictionaries].
 

## [Export of libraries](#table-of-content "Return to Table of content")

Existing collections of **(trriggerstring, hotstring)** definitions in *Hotstrings* format (.csv) can be exported to format of AutoHotkey (.ahk). Both: static auto-replace .ahk files and dynamic auto-replace .ahk files are supported; dynamic auto-replace definitions uses *Hotsting()* AutoHotkey function.

*Warning!* The *Hotstrings* application offer few advantages over AutoHotkey format, e.g. one **triggerstring** can be associated with few **hotstrings** (so called MSI, MCL definitions). If this is a case and you would like to export such definition, only one of them will be active. The rest will be commented out for your convenience.

*Tips*:
 * Only *Hotstring* application provides additional functionalities enabling quick and easy editing of existing **(trriggerstring, hotstring)** definitions with GUI, optional hotstrings associated with the same triggerstring, triggerstring tips to name just a few. But if these options aren't necessary to you, you can convert existing collections into AutoHotkey format and upload them as any other script.

## [Enable or disable triggerstring tips](#table-of-content "Return to Table of content")

The triggerstring tips are enabled by default (see menu: *Configuration → Triggerstring tips →  Enable/Disable*) and generated / sorted dynamically on time of writing. When numerous set of libraries are uploaded, the time necessary to display triggerstring tips can significantly increase. It is possible to filter out triggerstring tips for specific libraries, just enter menu: *Libraries configuration → Enable/disable triggerstring tips* and tick out undesired library.

## [Loaded hotstrings counter](#table-of-content "Return to Table of content")

The GUI of *Hotstrings* application enable quick hint about amount of loaded hotstrings. In bottom right corner of the *Hotstrings* window is visible counter *Loaded hotstrings*.

![Loaded hotstrings counter][]


# [Localization](#table-of-content "Return to Table of content")

[Language localization] is easy in *Hotstrings* application. In folder *../Hotstrings/Languages* you can find by default file *English.ini*. This file contains definition of all *text strings* used by *Hotstrings* application in the following form:

Variable example | Equal sign | Corresponding text string example
 :---: | :---: | :---:
 ChangeLanguage | = | Change language

In order to prepare language file specific for your mother language: 

 1. prepare copy of default language file (*English.ini*) e.g. by copying and pasting it in the same folder (*Languages*),
2. change file name of copied file to name of your mother language,
3. open it in your favorite editor and translate *corresponding text strings*,
4. save the .ini file and restart *Hotstrings* application,
5. from *Hotstrings* menu choose *Configuration → Change language →* and tick your newly prepared language file.
6. application will restart in order to apply the changes.

Applied change is kept in *Configuration.ini*. Another words it is preserved between application restarts.

**Warning**: Text strings are stored within .ini file, with all consequences specific for AutoHotkey. It means that .ini files are not Unicode compliant (not UTF friendly). In order to keep your specific accents (diacritics) save .ini file in corresponding code page. The *Hotstrings* application can handle specific letters with dedicated function which translates from specific code page to Unicode.  

# [Command line options](#table-of-content "Return to Table of content")

*Hotstrings* application can be run with parameters. It means that you can start it providin name of the parameters just after name of application in command line, e.g.:

> c:\temp\Hotstrings> Hotstrings.ahk \<parameter\>

or 

> c:\temp\Hotstrings> Hotstrings \<parameter\>

*Tip*:  Running with parameter can be in particular useful when *Hotstrings* application is run as a link or from within another script file, e.g. batch file.

## [Light mode](#table-of-content "Return to Table of content")

Parameter name: **l** (small letter l as in word "light")

In this mode application is run without GUI. Another words there is no chance to change any **(triggerstring, hotstring)** or any other configuration setting. 

There is no way to change the mode of operation to default one (with GUI enabled). Just exit the application and start it over in default mode.

*Tip*: This mode can be useful in some seldom situations when it is required to limit user choices, e.g. forcing usage of specific libraries and disable altering of library content.


## [Debug mode](#table-of-content "Return to Table of content")

Parameter name: **d**

For internal use only. In this mode application creates additional folder: *../Hotstrings/Logs/* where are stored files: *LogsA_DD A_MM_A_HourA_Min .txt*. These files log information about consecutive *triggerstring tips*.

# [Other remarks](#table-of-content "Return to Table of content")

Other remarks helpful in everyday working with hotstrings.

## [Order of loading AutoHotkey scripts matter](#table-of-content "Return to Table of content")

For example if you use *[Diacritic]* (.ahk) together with *Hotstrings* (.ahk), there is potential collission. It's adviced to load *Hotstrings* prior to *Diacritic*.

## [Autostart of *Hotstrings* application](#table-of-content "Return to Table of content") 

Create link file (.lnk) to *Hotstrings.ahk* or *Hotstrings.exe* file: from context menu in your file manager choose "create link". Move that link file to your autostart folder. In Microsoft Windows 10: *c:\users\xxxxxx\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup*. The string *xxxxxx* represents your user name.

*Tip*: You can change order of application which are started up on time of operating system automatic start (autostart) by changing of the files found in above folder e.g. by adding numbers in front of them. Example: 1_Hotstrings.lnk will guarantee that this link will be the first to be run on autostart.

## [Not always applying clipboard output function is a good idea](#table-of-content "Return to Table of content")

Some forms, especially at banking web pages, do not accept pasting from clipboard. Probably there are safety reasons behind that. From the other hand the SendInput output function simulates keyboard keypressings, one by one. So to get over this limitation it's enough to edit particular hotstring and switch *Select hotstring output function* from *Clipboard (CL)* to *SendInput (SI)*.

## [Overlapping triggerstrings](#table-of-content "Return to Table of content")

The overlapping triggerstrings are two or more different triggerstring where at least the beginning is common.

---
*Example 1 of overlapping triggerstrings*

The triggestrings of the two following examples overlap but the first one is one character shorther, than the second one.

No.   | option | triggerstring     | trigger:    | hotstring
:---: | :---:  | :---:             | :---:       | :---:
1     | \*     | btw               | 2           | by the way
2     | \*     | btw2              | 2           | back to work

*Example, execution*

content stream |    triggerstring | trigger  | hotstring
:---:          |:---:             | :---:    | :---:
Something,☐something☐| btw       | ☐        | by☐the☐way


> Something,☐something☐ ~~btw~~ by☐the☐way☐

*Comment*: The second hotstring will never be triggered, as always after triggering of the first trigger (w) the **hotstring recognizer** is reset. The solutions to this issue are shown in the following examples.


---
*Example 2 of overlapping triggerstrings*

The triggestrings of the two following examples overlap, but this time both of them are of the same length.
No.   | option | triggerstring | trigger: last character | hotstring
:---: | :---:  | :---:         | :---:                   | :---:
1     |  \*    | btw1          | 1                       | by the way
2     |  \*    | btw2          | 2                       | back to work

*Example, execution*

content stream         |    triggerstring | trigger  | hotstring
:---:                  | :---:            | :---:    | :---:
Something,☐something☐ | btw              |  1       | by☐the☐way
☐                      | btw              |  2       | back☐to☐work

> Something,☐something☐ ~~btw1~~ by☐the☐way☐ ~~btw2~~ back☐to☐work

*Comment*: This solution is not very elegant, as one have to keep in mind two **triggerstrings** and corresponding **hotstrings**.


---
*Example 3 of overlapping triggerstrings*

The space itself can be a part of triggestring as well. What's is important is the length of the triggerstrings. This can be useful to distinguish the abbreviation from its phrase, as in the following example.

option | triggerstring | trigger: last character | hotstring
:---:  | :---:         | :---:                   | :---:
\*     | api☐          | ☐                      | API
\*     | api/          | /                       | Application☐Programming☐Interface

*Example, execution*

content stream         |    triggerstring | trigger  | hotstring
:---:                  | :---:            | :---:    | :---:
Something,☐something☐ | api              |  ☐       | API
☐(                     | api              |  /       | Application☐Programming☐Interface
)                      |                  |          |

> Something,☐something☐ ~~api☐~~API☐(~~api/~~Application☐Programming☐Interface)


---
*Example 4 of overlapping triggerstrings, special feature of Hotstring application: menu*

Thanks to *Hotstrings* application one triggestring can be used to trigger menu with defined list of hotstrings. The first option on the list is the default one. Selection of the hotstring is made by pressing the <↓> or <↑> keys and <Enter> key. Caution, it doesn't work with mouse clicks.

option                        | triggerstring | trigger: last character | hotstring
:---:                         | :---:         | :---:                   | :---:
\* and Menu & Clipboard (MCL) | api/          | /                       | API \| Application☐Programming☐Interface

*Example, execution*

content stream         |    triggerstring | trigger  | hotstring
:---:                  | :---:            | :---:    | :---:
Something,☐something☐ | api              |  /       | menu: API
☐(                     | api              |  /       | menu: Application☐Programming☐Interface
)                      |                  |          |

> Something,☐something☐~~api/~~ API☐(~~api/~~ Application☐Programming☐Interface)

---

Example 5 of overlapping triggerstrings, recommended

Both strings will have the same length (counting triggerstring + trigger), but different options are applied.

No.   | option | triggerstring | trigger: last character | hotstring
:---: | :---:  | :---:         | :---:                   | :---:
1     |        | api           | EndChar                 | API
2     |  \*    | api/          | /                       | Application☐Programming☐Interface

*Example, execution*

content stream         |    triggerstring | trigger  | hotstring
:---:                  | :---:            | :---:    | :---:
Something,☐something☐ | api              |  ☐       | menu: API
☐(                     | api              |  /       | menu: Application☐Programming☐Interface
)                      |                  |          |

> Something,☐something☐~~api☐~~ API☐(~~api/~~ Application☐Programming☐Interface)

*Comment*: Now after pressing of <Space> after api triggerstring the api is naturally capitalized and if on purpose trigger (/) is appended the full meaning of abbreviation is given. Just one key have to pressed additionally.
 
## Interaction of hotstrings pasted from clipboard with clipboard managers

In case if *clipboard manager* is active (e.g. [CopyQ]), each time the **hotstring** which is output by clipboard is triggered with **triggerstring** the result is copied to buffer of *clipboard manager*.

---
---
---

# [Credits](#table-of-content "Return to Table of content")

The originator and creator of the Hotstrings application is Jack Dunning aka [Jack][] who has created the very first version of *[Instant Hotstring][]* application.

People from AutoHotkey community, especially those who help at [AutoHotkey forum][].

## Tools used to prepare this documentation

* Markdown (MD) text editor: https://hackmd.io/
* Table generator: https://www.tablesgenerator.com/markdown_tables#
* ASCII diagram editor: https://textik.com/

---
---
---


# [ToDo List](#table-of-content "Return to Table of content")
- ☑ Menu: configuration and the corresponding *Configuration.ini*
    - ☑ sandbox for hotstrings,
    - ☑ enable / disable "undo" (Ctrl | z) of hotstrings,
    - ☑ setup of "Ending character",
    - ☑ *Hotstrings* window size and position, including monitor, window size.
- ☑ Automatic tooltip for triggestrings.
- ☑ GUI:
    - ☑ comments to hotstrings (stored in .csv files).
    - ☑ library content is marked, edition should be loaded automatically.
    - ☑ search window, a searched result should enable direct edition.
    - ☑ hotkeys to main functions
- ☑ Hotstrings export (.csv → .ahk).
    - ☑ static hotstrings (:options:triggerstring::hotstring),
    - ☑ dynamic hotstrings (Hotstring("options", "triggestring", "hotstring")).
- ☑ Hotstrings import (.ahk → .csv) from known autocorrect libraries (English mainly).
- ☑ Localization (preparation of code to translation into foreign languages).

[Defining of hotstring]: https://raw.githubusercontent.com/mslonik/Hotstrings/master/HelpPictures/Hotstring3_DefiningOfHotstring.png "Defining of hotstring"
[Enter triggerstring]: https://raw.githubusercontent.com/mslonik/Hotstrings/master/HelpPictures/Hotstring3_EnterTriggerstring.png "Enter triggerstring"
[Enter triggerstring, example]: https://raw.githubusercontent.com/mslonik/Hotstrings/master/HelpPictures/Hotstring3_EnterTriggerstring_btw.png "Enter triggerstring, example"
[Default trigger option]: https://raw.githubusercontent.com/mslonik/Hotstrings/master/HelpPictures/Hotstring3_SelectTriggerOption.png "Default trigger option"
[Select hotstring output function]: https://raw.githubusercontent.com/mslonik/Hotstrings/master/HelpPictures/Hotstring3_SelectHostringOutputFunction.png "Select hotstring output function"
[Enter hotstring]: https://raw.githubusercontent.com/mslonik/Hotstrings/master/HelpPictures/Hotstring3_EnterHotsring.png "Enter hotstring"
[Enter hotstring, example]: https://raw.githubusercontent.com/mslonik/Hotstrings/master/HelpPictures/Hotstring3_Example_ByTheWay.png "Enter hotstring, example"
[shl1]: https://raw.githubusercontent.com/mslonik/Hotstrings/master/HelpPictures/Hotstring3_SelectHostringLibrary.png "Select hotstring library"
[shl2]: https://raw.githubusercontent.com/mslonik/Hotstrings/master/HelpPictures/Hotstring3_Example_HotstringLibrary.png "Select hotstring library"
[Set the hotstring]: https://raw.githubusercontent.com/mslonik/Hotstrings/master/HelpPictures/Hotstring3_HostringButtons.png "Set the hotstring" 
[Animated Gif1]: https://raw.githubusercontent.com/mslonik/Hotstrings/master/HelpPictures/Hotstrings_EntryExample2.gif "Animated example"
[Library content]: https://raw.githubusercontent.com/mslonik/Hotstrings/master/HelpPictures/Hotstring3_Example_LibraryContent.png "Library content"
[Select trigger option(s)]: https://raw.githubusercontent.com/mslonik/Hotstrings/master/HelpPictures/Hotstring3_SelectTriggerOption.png "Select trigger option(s)"
[Main window parts]: https://raw.githubusercontent.com/mslonik/Hotstrings/master/HelpPictures/Hotstring3_MainWindow2.png "Main window parts"
[Main window]: https://raw.githubusercontent.com/mslonik/Hotstrings/master/HelpPictures/Hotstring3_MainWindow.png "Main window"
[Main window parts]: https://raw.githubusercontent.com/mslonik/Hotstrings/master/HelpPictures/Hotstring3_MainWindow2.png "Main window parts"
[Select trigger option(s)]: https://raw.githubusercontent.com/mslonik/Hotstrings/master/HelpPictures/Hotstring3_SelectTriggerOption.png "Select trigger option(s)"
[Default trigger option]: https://raw.githubusercontent.com/mslonik/Hotstrings/master/HelpPictures/Hotstring3_SelectTriggerOption.png "Default trigger option"
[Trigger option Immediate Execute]: https://raw.githubusercontent.com/mslonik/Hotstrings/master/HelpPictures/Hotstring3_Option_ImmediateExecute.png "Trigger option Immediate Execute"
[Example, immediate execute]: https://raw.githubusercontent.com/mslonik/Hotstrings/master/HelpPictures/Hotstring3_Example_ImmediateExecute.png "Example, immediate execute"
[Trigger option No Backspace]: https://raw.githubusercontent.com/mslonik/Hotstrings/master/HelpPictures/Hotstring3_Option_NoBackspace.png "Trigger option No Backspace" 
[Example, no Backspace]: https://raw.githubusercontent.com/mslonik/Hotstrings/master/HelpPictures/Hotstring3_Example_NoBackspace.png "Example, no Backspace"
[Example of system tray]: https://raw.githubusercontent.com/mslonik/Hotstrings/master/HelpPictures/Hotstring3_SystemTray.png "Exampe of system tray" 
[About / Help]: https://raw.githubusercontent.com/mslonik/Hotstrings/master/HelpPictures/Hotstring3_About_Help.png "About / Help"
[Main menu]:  https://raw.githubusercontent.com/mslonik/Hotstrings/master/HelpPictures/Hotstring3_MainMenu.png "Main menu"
[Trigger option No Endchar]:  https://raw.githubusercontent.com/mslonik/Hotstrings/master/HelpPictures/Hotstring3_Option_NoEndChar.png "Option: No Endchar"
[Example No EndChar]:  https://raw.githubusercontent.com/mslonik/Hotstrings/master/HelpPictures/Hotstring3_Example_NoEndChar.png "Example: No Endchar"
[Trigger option Case Sensitive]:  https://raw.githubusercontent.com/mslonik/Hotstrings/master/HelpPictures/Hotstring3_Option_CaseSensitive.png "Option: Case Sensitive"
[Example Case Sensitive]:  https://raw.githubusercontent.com/mslonik/Hotstrings/master/HelpPictures/Hotstring3_Example_CaseSensitive.png "Example: Case Sensitive"
[Trigger option Inside Word]:  https://raw.githubusercontent.com/mslonik/Hotstrings/master/HelpPictures/Hotstring3_Option_InsideWord.png "Option: Inside Word"
[Disable]: https://raw.githubusercontent.com/mslonik/Hotstrings/master/HelpPictures/Hotstring3_Option_Disable.png "Option: Disable (hotstring)"
[Disable example]: https://raw.githubusercontent.com/mslonik/Hotstrings/master/HelpPictures/Hotstring3_Example_Disable.png "Example: Disable (hotstring)"
[Example, no options]: https://raw.githubusercontent.com/mslonik/Hotstrings/master/HelpPictures/Hotstring3_Example_DefaultNoOption.png "Example: no triggerstring option is set"
[Example, Inside Word]: https://raw.githubusercontent.com/mslonik/Hotstrings/master/HelpPictures/Hotstring3_Example_InsideWord.png "Example: Inside Word"
[Example, useful B0]: https://raw.githubusercontent.com/mslonik/Hotstrings/master/HelpPictures/Hotstring3_Example_em.png "Useful example with B0"
[Add a comment]: https://raw.githubusercontent.com/mslonik/Hotstrings/master/HelpPictures/Hotstring3_AddComment.png "Add a comment"
[Menu: configure]: https://raw.githubusercontent.com/mslonik/Hotstrings/master/HelpPictures/Hotstring3_Menu_Configure.png "Menu: Configure"
[Menu: triggerstring tip]: https://raw.githubusercontent.com/mslonik/Hotstrings/master/HelpPictures/Hotstring3_Example_TriggerstringTip.png "Menu: Triggerstring Tip"
[Menu: Launch Sandbox]: https://raw.githubusercontent.com/mslonik/Hotstrings/master/HelpPictures/Hotstring3_Sandbox.png "Menu: Launch Sandbox"
[Menu: Toggle EndChars]: https://raw.githubusercontent.com/mslonik/Hotstrings/master/HelpPictures/Hotstring3_ToggleEndEchars.png "Menu: Toggle EndChars"
[Menu: Search Hotstrings]: https://raw.githubusercontent.com/mslonik/Hotstrings/master/HelpPictures/Hotstring3_Search.png "Menu: Search Hotstrings"
[Menu: Clipboard Delay]: https://raw.githubusercontent.com/mslonik/Hotstrings/master/HelpPictures/Hotstring3_ClipboardDelay.png "Menu: Clipboard Delay"
[Output function: menu]: https://raw.githubusercontent.com/mslonik/Hotstrings/master/HelpPictures/Hotstring3_OutputMenu.png "Output function: menu"
[Buttons]: https://raw.githubusercontent.com/mslonik/Hotstrings/master/HelpPictures/Hotstring3_Buttons.png "Buttons"
[Library content]: https://raw.githubusercontent.com/mslonik/Hotstrings/master/HelpPictures/Hotstring3_LibraryContent.png "Library content"
[Hotstring Menu Example]: https://raw.githubusercontent.com/mslonik/Hotstrings/master/HelpPictures/Hotstring3_Example_HotstringMenu.png "Hotstring Menu Example"
[TrayTip start]: https://raw.githubusercontent.com/mslonik/Hotstrings/master/HelpPictures/Hotstrings_TrayTip_Start.png "TrayTip when application starts uploading of libraries"
[TrayTip finish]: https://raw.githubusercontent.com/mslonik/Hotstrings/master/HelpPictures/Hotstrings_TrayTip_Finish.png "TrayTip when application finishes uploading of libraries"
[Loaded hotstrings counter]: https://raw.githubusercontent.com/mslonik/Hotstrings/master/HelpPictures/Hotstrings_LoadedHotstringsCounter.png "Loaded hotstrings counter"

[AutoHotkey]: https://www.autohotkey.com/
[hotstring]: https://www.autohotkey.com/docs/Hotstrings.htm/
[documentation of AutoHotkey]: https://www.autohotkey.com/docs/Hotstrings.htm/
[Jack]: https://jacks-autohotkey-blog.com/
[Instant Hotstring]: http://www.computoredge.com/AutoHotkey/Free_AutoHotkey_Scripts_and_Apps_for_Learning_and_Generating_Ideas.html#instanthotstrings
[AutoHotkey forum]: https://www.autohotkey.com/boards/
[GNU GPL ver. 3]: https://github.com/mslonik/Hotstrings/blob/master/LICENSE
[Source code]: https://github.com/mslonik/Hotstrings
[Maciej's homepage]: http://mslonik.pl
[Github (Hotstrings)]: https://github.com/mslonik/Hotstrings
[declension]: https://en.wikipedia.org/wiki/Declension
[CopyQ]: https://hluk.github.io/CopyQ/
[Diacritic]: https://github.com/mslonik/Autohotkey-scripts
[Accents]: https://www.dcmembers.com/skrommel/download/accents/
[Autocorrect.ahk]: https://www.autohotkey.com/download/AutoCorrect.ahk
[Date and Time]: https://www.autohotkey.com/docs/Variables.htm#date
[Libre Office dictionaries]: https://github.com/LibreOffice/dictionaries
[Language localization]: https://en.wikipedia.org/wiki/Language_localisation
[key names]: https://www.autohotkey.com/docs/commands/Send.htm#keynames