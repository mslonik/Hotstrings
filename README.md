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
 
    &nbsp;&nbsp;1.1. [What are the hotstrings?](#what-are-the-hotstrings)
 
    &nbsp;&nbsp;1.2. [How the *Hotstrings* application work?](#how-the-Hotstrings-application-work)

    &nbsp;&nbsp;1.3. [Why somobody may want to use hotstrings?](#why-somobody-may-want-to-use-hotstrings)

    &nbsp;&nbsp;1.4. [Why somebody may want to use *Hotstrings* application?](#why-somebody-may-want-to-use-Hotstrings-application)
    
    &nbsp;&nbsp;1.5. [How to reset the hotstring recognizer?](#how-to-reset-the-hotstring-recognizer)

2. [Installation of *Hotstrings* application](#installation-of-Hotstrings-application)

3. [The first run of *Hotstrings* application](#the-first-run-of-Hotstrings-application)

4. [Main window of *Hotstrings* application](#main-window-of-Hotstrings-application)
 
   &nbsp;&nbsp;4.1. [Menu](#Menu)
  
   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;4.1.1. [Configure](#configure)
   
   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;4.1.1.1. [Undo last hotstring](#undo-last-hotstring)
   
   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;4.1.1.2. [Triggerstring tips](#triggerstring-tips)
   
   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;4.1.1.3. [Save window position](#save-window-position)
   
   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;4.1.1.4. [Launch Sandbox](#launch-sandbox)
   
   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;4.1.1.5. [Toggle EndChars](#toggle-endchars)

   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;4.1.2. [Search *Hotstrings*](#search-hotstrings)

   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;4.1.3. [About / Help](#about-/-help)

   &nbsp;&nbsp;4.2. [Hotstring definition or edition](#hotstring-definition-or-edition)

   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;4.2.1. [Triggerstring definition](#triggerstring-definition)

   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;4.2.2. [Trigger options overview](#trigger-options-overview)
   
   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;4.2.2.1. [Default (no trigger option selected)](#default-no-trigger-option-selected)
   
   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;4.2.2.2. [Immediate Execute (\*)](#immediate-execute)
   
   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;4.2.2.3. [No Backspace (B0)](#no-backspace)
   
   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;4.2.2.4. [No End Char (O)](#no-end-char)
   
   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;4.2.2.5. [Case Sensitive (C\)](#case-sensitive)
   
   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;4.2.2.6. [Inside Word (?)](#inside-word)
   
   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;4.2.2.7. [Disable](#disable)
   
   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;4.2.3. [Hotstring output method](#hotstring-output-method)

   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;4.2.4. [Enter hotstring](#enter-hotstring)

   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;4.2.5. [Add a comment](#add-a-comment)

   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;4.2.6. [Select hotstring library](#select-hotstring-library)

   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;4.2.7. [Buttons](#buttons)

   &nbsp;&nbsp;4.3. [Library content](#library-content)

   &nbsp;&nbsp;4.4. [Shortcuts](#shortcuts)

5. [Format of libraries](#format-of-libraries)

6. [Other remarks](#other-remarks)

   &nbsp;&nbsp;6.1. [Autostart of *Hotstrings* application](#autostart-of-Hotstrings-application)

   &nbsp;&nbsp;6.2. [Not always applying clipboard output function is a good idea](#not-always-applying-clipboard-output-function-is-a-good-idea)

7. [Credits](#credits)

   &nbsp;&nbsp;7.1. [Tools used to prepare this documentation](#tools-used-to-prepare-this-documentation)

8. [ToDo List](#todo-List)

---

# [FAQ: Introduction to hotstrings](#table-of-content "Return to Table of content")
(Frequently Asked Questions) about *Hotstrings* application and notion of hotstrings.

## [What are the hotstrings?](#table-of-content "Return to Table of content")
There are two corresponding notions:

- triggerstring,
- hotstring.

The relationship between these two notions is ruled by options and can be presented as follows:

user input | hostring recognizer | options | modified input
---|---|---
triggerstring | → | hotstring
alphanumeric string | alphanumeric string | alphanumeric string

So the triggerstring triggers the corresponding hotstring, taking into consideration:

* user input (what user writes pressing keys of keyboard)

* options defined for particular pair (*triggerstring*, *hotstring*)


Wording convention: usually the corresponding notions *(option(s), triggestring, hotstring)* is also called as *hotstring*.


## [How the *Hotstrings* application work?](#table-of-content "Return to Table of content")
### In short

 the *Hotstrings* application:
 
* keeps in memory definitions of hotstrings defined by user:  **(option(s), triggerstring, hotstring)* 

and 

* applies the **hotstring recognizer** to input stream of keyboard pressed keys, searching for the **triggestring** according to rules defined in **option(s)**. 

If the **triggestring** is recognized (user pressed appropriate sequence of keys) and it fits to **option(s)**: 

* the **hostring** is issued,
* the **hotstring recognizer** is reset.

The concept and usage of hotstrings is based and compatible to AutoHotkey [hotstring][] notion.

### In long 
Please carefully analyse the **Pic. 1**. From the bottom up:

1. User sits in the front of input and output devices. Let's assume for this moment that input device is just a keyboard and output device is just a computer monitor.

2. The input / output devices are connected to computer which contains: 

   i. operating system (set or universe of various applications),
   
   ii. applications (set or universe of various applications).
3. We pay special attention in: 

   i. operating system: *Input Buffer*.
   
   ii. applications: *Hotkeys* and Microsoft Word.

The operating system exchange information with input device character by character. Let's observe, what is going on (1-5 on the picture):

1. *Input*: user presses a key of keyboard. This key is send from input device to *Input Buffer*.
2. *Hotkeys* applications picks up information about new information in *Input Buffer*. It examines current content of the buffer with **hotstring recognizer**.
3. If **hotstring recognizer** recognizes one of the **triggerstrings** and conditions to trigger are met, the content of *Input Buffer* is altered accordingly (e.g. some characters are deleted, some are inserted).
4. Other applications, like Microsoft Word, get information from operating system and see altered input.
5. Next Microsoft Word do some operations if required and output is send to *Output* (e.g. computer monitor).

```
                  +---------------------------------------------------------------------------------+
                  |                                                                                 |
                  |                                                                                 |
                  |                                                                                 |
 (UNIVERSE OF)    |                                                        +------------------+     |
 APPLICATIONS     |                                                        |                  |     |
                  |                                                        |    Microsoft Word|     |
                  |+--------------------------+                            |                  |     |
                  || Hotkeys                  |                            +----^-------|-----+     |
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
**Pic. 1.** Long story about *Hotstrings* application.

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

Now *Hotstrings* application runs in its default mode: **running mode**. All the (triggerstring, hotstring) pairs are activated, operating system wide. So no matter in which text window is currently active pointer, one can already benefit from defined libraries of hostrings. Enjoy!

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

**Genuine hotstrings AutoHotkey documentation**: link [hotstring][].

## [Hotstring definition or edition](#table-of-content "Return to Table of content")
This time all 7 steps discussed in details, with examples and comments.

### [Triggerstring definition](#table-of-content "Return to Table of content")

The text edit field used to define the triggerstring.

![Enter triggerstring][]

In general the shorter triggerstring then the better. The triggerstring can be at most 40 characters long. This edit field works as any other ordinary window edit field, so it doesn't support e.g. text block operations.

The *Hotstrings* application doesn't have protection agains duplicate (**triggerstring**, **hotstring**) pairs. User can easily duplicated them. Therefore its worth to search prior to adding new definition if it doesn't exist already.

### [Trigger options overview](#table-of-content "Return to Table of content")
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

#### [Immediate Execute (\*)](#table-of-content "Return to Table of content")
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

#### [Inside Word (?)](#table-of-content "Return to Table of content")
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


## [Hotstring output method](#table-of-content "Return to Table of content")


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

### SendInput (SI)

The default output function, common with AutoHotkey SendInput. The **hotstring** is send character by character. It goes very fast, but if **hotstring** is long, is noticable for user. Therefore if long **hotstring** have to be send, one can consider *Clipboard (CL)* output function.

### Clipboard (CL)

The **hotstring** is copied to *clipboard* (part of memory, managed by operating system) and then pasted from clipboard to specific application, as requested by user. Thanks to that it is possible to enter even very long **hotstrings** "at once", in a blink of an eye.

The downside of this method is that in Microsoft Windows operating system time required to paste content of *clipboard* is neither specified nor guaranteed. The *Hotstrings* application enable change of this time by menu: Configure → Clipboard Delay. Also check description above.

### Menu & SendInput (MSI)

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

### Menu & Clipboard (MCL)
As above, with one exception: the **hotstrings** are output by clipboard, with all the consequences as described for *Clipboard (CL)* output function.

### Enter hotstring

![Enter hotstring][]

The edit text field used to display / edit the **hotstring**. The single hotstring can be up to 5000 characters long.

### Add a comment

![Add a comment][]

Optional (not mandatory) part of (**triggerstring**, **hotstring**) definition. Added to library (.csv) files and also displayed in *Library content* and *Search* window as the last column to the right.

*Tip*. Can be useful in some circumstances, for example to add a source of a **hotstring** definition in form of URL (a link).

### Select hotstring library
![shl1][]

List of text files with extenstion .csv available in *../Libraries* folder of *Hotstrings* application. 

Together with *Hotstrings* application just few files are delivered. These files can be seen as set of good practices or examples in order to aid user with management of newly created (**triggerstring**, **hotstring**) pairs.

The .csv files are chosen from *Hotstring library* drop-down list.

There is no limitation for number of .csv files stored within *../Libraries* folder. All hotstrings are uploaded on time of (re)start of *Hotstrings* application.

If user would like to create new .csv file, the **Add library** button should be pressed. Next name of the new .csv file have to be specified. The newly created file will be located within *../Libraries* folder.

*Tip*. Try to store (**triggerstring**, **hotstring**) which are somehow related to each other in separate .csv files. The files shouldn't be too long, because searching / management of them can be cumbersome at certain point.

### Buttons

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

# [Format of libraries](#table-of-content "Return to Table of content")

The CSV = Comma Separated Values, special format where "values" are separated by certain, dedicated character, e.g. comma. In case of *Hotstrings* application the  Unicode character "Double Vertical Line" is used: ‖ (U+2016). 

It is not enough for text file to have .csv extension to be recognized by *Hotstrings* application. Such file have to have also dedicated structure.

 | Section | Separator | Section | Separator | Section | Separator | Section | Separator | Section | Separator | Section
 | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
 | triggerstring options | ‖ | triggerstring | ‖ | output function | ‖ | status: Enabled / Disabled | ‖ | hotstring or group of hotstrings\* | ‖ | optional: comment |

\* group of hotstrings: if *hotstring output function* is equal to menu (Menu & Clipboard (MCL) or Menu & SendInput (MSI)) then hotstrings are separated with Unicode character "Broken Bar": ¦ (U+00A6).

*Example*:
| triggerstring options | ‖ | triggerstring | ‖ | output function | ‖ | status: Enabled / Disabled | ‖ | hotstring or group of hotstrings\* | ‖ | optional: comment |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| \* | ‖ | bom/ | ‖ | MSI | ‖ | En | ‖ | Bill of Materials¦Byte Order Mark | ‖ |


# [Other remarks](#table-of-content "Return to Table of content")
Other remarks helpful in everyday working with hotstrings.

## Order of loading AutoHotkey scripts matters. 
For example if you use *Diacritics.ahk* together with *Hotstrings.ahk*, there is potential collission. It's adviced to load *Hotstrings.ahk* before *Diacritics.ahk*.

## Autostart of *Hotstrings* application 

Create link file (.lnk) to *Hotstrings.ahk* or *Hotstrings.exe* file: from context menu in your file manager choose "create link". Move that link file to your autostart folder. In Microsoft Windows 10: *c:\users\xxxxxx\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup*. The string *xxxxxx* represents your user name.

*Tip*: You can change order of application which are started up on time of operating system automatic start (autostart) by changing of the files found in above folder e.g. by adding numbers in front of them. Example: 1_Hotstrings.lnk will guarantee that this link will be the first to be run on autostart.

## Not always applying clipboard output function is a good idea

Some forms, especially at banking web pages, do not accept pasting from clipboard. Probably there are safety reasons behind that. From the other hand the SendInput output function simulates keyboard keypressings, one by one. So to get over this limitation it's enough to edit particular hotstring and switch *Select hotstring output function* from *Clipboard (CL)* to *SendInput (SI)*.

## Overlapping triggerstrings

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
- ❎ Hotstrings export (.csv → .ahk).
    - ❎ static hotstrings (:options:triggerstring::hotstring),
    - ❎ dynamic hotstrings (Hotstring("options", "triggestring", "hotstring")).
- ❎ Hotstrings import (.ahk → .csv) from known autocorrect libraries (English mainly).
- ❎ Localization (preparation of code to translation into foreign languages).

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
