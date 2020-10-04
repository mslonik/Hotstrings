# *Hotstrings* application
Written in [AutoHotkey][] application *Hotstrings*  with many useful features:

- quick text replacement aka hotstrings; 
    
    *short alphanumeric strings (aka triggerstrings) are used to automatically replace long alphanumeric strings (aka hotstrings)*;
- defined hotstrings are operating system wide;

    *it means that can be triggered in any text / edit window, in any application*;
- GUI (Graphical User Interface); 

    *for easy definition and/or edition of hotstrings*;
- clipboard ready;

    *useful especially for long text strings, as it enables entering the long hotstring in a blink of an eye*;
- one triggering abbreviation can call several different text strings of your choice;

    *chosen from menu*;
- graphical overview of existing hotstrings with search capabilities;
- definitions of hotstrings are stored in .csv files, as many, as you like; 

    *each file can contain hotstring belonging to specific category, e.g. emojis, physical symbols, first and second names etc.*;
- undoing of hotstrings;

    *conversion of last entered hotstring again into triggering abbreviation*;
- runs on Microsoft Windows family operating systems;
- written in AutoHotkey script language but does not require this language interpreter to be installed and can be run standalone thanks to .exe file;

    *nevertheless installation of [AutoHotkey][] is greatly adviced).*

---

# Table of content
1. [FAQ](#FAQ)

2. [Let's begin by defining of few first hotstrings](#Lets-begin-by-defining-of-few-first-hotstrings)

3. [Main window of *Hotstring* application](#Main-window-of-Hotstring-application)

4. [Hotstring definition or edition](#Hotstring-definition-or-edition)

---

# FAQ 
(Frequently Asked Questions) about *Hotstrings*:

[What are the hotstrings?](#What-are-the-hotstrings)

[How the AutoHotkey and hotstrings work?](#How-the-AutoHotkey-and-hotstrings-work)

[Why somobody may want to use hotstrings?](#Why-somobody-may-want-to-use-hotstrings)

[Why somebody may want to use *Hotstring* application?](#Why-somebody-may-want-to-use-Hotstring-application)

## What are the hotstrings?
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


## How the *Hotstrings* application work?
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
The *Hotstrings* application: (...)

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


## Why somobody may want to use hotstrings?
Because they can significantly make life easier and... longer? 

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

## Why somebody may want to use *Hotstrings* application?
Because it doesn't require much knowledege and text editing to run your own hotstrings. *Hotstrings* application can be run even without installation (e.g. from USB pendrive, run **Hotstrings.exe**). Thanks to GUI (Graphical User Interface) you will master defining and applying of your own hotstrings in a blink of an eye 😉.

The alternative, traditional way, is based on text edition, when hotstrings are prepared in AutoHotkey script (text file with .ahk extension), keeping attention to syntax of AutoHotkey syntax. Next such a script can be compiled into executive (.exe).


## How to reset the hotstring recognizer?
(...)

---
---
---

# Let's begin defining of few first hotstrings
Just double click on the Hotstrings icon (capital letter *H* as *Hotstrings* on green background) in system tray:

![Example of system tray][]

or... use hotkey *Ctrl | # | h* (Control | Windows key | h).

Next you'll see main GUI (Graphical User Interface) window which enable you to edit hotstrings:

At first please observe the main window again. In order to define any hotstring one have to follow top down the screen (in blue):

1. Enter triggerstring.
2. Select trigger option(s).
3. Select hotstring output function.
4. Enter hotstring.
5. Select hotstring library.
6. Set the hotstring.

![Defining of hotstring][]

We will start by defining of *by the way* hotsring with plain *btw* triggerstring and no options.

## Enter triggestring
Let's input in this text edit field some text: 

![Enter triggerstring][]

Please keep in mind that this edit window does not show space key, as it is blank key. But in this tutorial it will be easier to see what we're doing by using the ☐ convention from now on to show the Space (Spacebar key). So now let's input 

![Enter triggerstring, example][]

## Select trigger option(s)
![Default trigger option][] 

By default no option is set (option string is empty). Then after **triggerstring** is entered, additionally one **trigger key* have to be pressed by user in order to trigger the hotstring.

The *trigger key* is defined as one of the following *endchar*keys: -()[]{}':;"/\,.?!\`n☐\`t (note that \`n is Enter,  \`t is Tab, and there is a plain space between \`n and \`t marked as ☐ according to our convention). 

Let's leave no option set and continue.

## Select hotstring output function
![Select hotstring output function][]

Select one and only one option from the list. By default *Send by AutoHotkey* is set. It means that the hotstring will be output by AutoHotkey, without menu and not by Clipboard. More about *output functions* later on.

Let's leave it as it is.

## Enter hotstring
![Enter hotstring][]

Let's input our first *hotstring*:

![Enter hotstring, example][]

## Select hotstring library
![Select hotstring library][shl1] 

This list contains all and only *.csv* files from withing folder *..\Hotstrings3\Categories*. One can have as many libraries (*.csv*) files as necessary.

Let's select the *AutocorrectionHotstring.csv* for sake of example.
![Select hotstring library][shl2]

## Set the hotstring
Select / click the *Set hostring* button. The function and meaning of two others is hopefully quite obvious. It will be explained in details later on.

![Set the hotstring][] 

## Congratulations!
You've defined your first hotstring. Have a look now into the left part of the main screen, into the *Library content*. Find there your newly defined hotstring:

![Library content][]

---
---
---

Now let's dive into more detailed description of available functions

# Main window of *Hotstring* application

![Main window][]

The purpose of this window is enabling hotstring definition and/or edition.

It can be divided into the following parts:

1. Menu.
2. Hotstring definition / edition.
3. Display of existing hotstrings.

![Main window parts][]

## Menu
![Main menu][]

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

**Tip:** Sometimes when long hotstrings are triggered and clipboard is applied to immediately enter it, strange behaviour can occurre. Instead of expected hotstring the previous content of clipboard may appear. The reason is that operating system can not gurantee the time to insert the content of clipboard into specific window / editing field. In order to support operating system enlarge the delay. The shorter the delay than better, but if too short, mentioned behaviour can be observed.

### About / Help
 ![About / Help][] 

**Hotstrings.ahk (script). Let's make your PC personal again...**. 

Enables convenient definition and use of hotstrings (triggered by shortcuts longer text strings). This is 3rd edition of this application, 2020 by Jakub Masiak and Maciej Słojewski (🐘). License: [GNU GPL ver. 3][]. [Source code][]. [Maciej's homepage][].

Help, link to this file.

# Hotstring definition or edition 
This time all 6 steps discussed in details, with examples and comments.

## Triggerstring definition
(...)

## Trigger options overview
Trigger options controls how **hotstring recognizer** works.

![Select trigger option(s)][]

**Tab. 1.** Trigger options compatibility between AutoHotkey and *Hotstrings* app.
| Option full name    | Option short name | AutoHotkey | *Hotstrings* application |     Comment     |
|---------------------|:-----------------:|:----------:|:------------------------:|:---------------:|
| No option (default) |                   |      X     |             X            |       GUI       |
| Immediate Execute   |         *         |      X     |             X            |       GUI       |
| Inside Word         |         ?         |      X     |             X            |       GUI       |
| No Backspace        |         B0        |      X     |             X            |       GUI       |
| Case Sensitive      |         C         |      X     |             X            |       GUI       |
| No Endchar          |         O         |      X     |             X            |       GUI       |
| Execut              |         X         |      X     |                          | not implemented |
| Reset Recognizer    |         Z         |      X     |                          | not implemented |
                                                                                 
                                                                                 
                                                                                 
                                                                                 
                                                                                 


**Tab. 2.** Output options compatibility between AutoHotkey and *Hotstrings* app.
| Option full name | Option short name | AutoHotkey | *Hotstrings* application | Comment                                   |
|------------------|:-----------------:|:----------:|:------------------------:|-------------------------------------------|
| Raw output       |         R         |      X     |                          | Not implemented                           |
| SendInput        |         SI        |      X     |             X            |                                           |
| SendPlay         |         SP        |      X     |                          | Not implemented                           |
| SendEvent        |         SE        |      X     |                          | Not implemented                           |
| Text raw         |         T         |      X     |                          | ??? implemented but not accessible in GUI |
| Disable          |                   |            |             X            | GUI                                       |
Comments:

* GUI (Graphical User Interface) means that specified option is directly available in the GUI of this application.
*  For details regarding SI / SP / SE modes see [documentation of AutoHotkey][]. Only SI mode is implemented.

**Tab. 3.** Comparison of **option(s)** (valid for **trigger recognizer**).
| option full name    | option id | previous endchar required? | triggestring erased? | separate trigger? | trigger erased? | triggerstring case sensitive? |
|---------------------|:---------:|:--------------------------:|:--------------------:|:-----------------:|:---------------:|:-----------------------------:|
| No option (default) |           |             yes            |          yes         |        yes        |        no       |               no              |
| Immediate Execute   |     \*    |             yes            |          yes         |         no        |       n.a.      |               no              |
| Inside Word         |     ?     |             no             |          yes         |        yes        |        no       |               no              |
| No Backspace        |     B0    |             yes            |          no          |        yes        |        no       |               no              |
| Case Sensitive      |     C     |             yes            |          yes         |        yes        |        no       |              yes              |
| No End Char         |     O     |             yes            |          yes         |        yes        |       yes       |               no              | 

#### Default (no trigger option selected)
![Default trigger option][] 

By default for new **hotstrings** no trigger option is set, what means: 

1. The **hotstring recognizer** starts only just after *endchar* is detected. So the *endchar* is required directly before the **triggersting**.
2. **Triggerstring** is not case sensitive.
3. After **triggerstring** additionally one **trigger** key have to be pressed by user in order to trigger the hotstring. *Trigger* key is defined by default set of *endchar*.
4. **Triggerstring** is ~~erased~~ and exchanged with **hotstring**. 
5. **Trigger** is not erased.


---
*Example of triggerstring and hotstring definition*

option(s) | triggerstring     | trigger: last character  | hotstring
-------|-------------------|---------------------------|-----------
|     | ~~btw~~        | *endchar*                   | by☐the☐way

![Example, no options][] 


*Example, execution*

option |    triggerstring | trigger | replaced by hotstring
----------|--------------------|----------|-------------------------------
Something,☐something☐ | ~~btw~~ | ☐ | by☐the☐way

> Something,☐something☐ ~~btw~~ | ☐ | by☐the☐way☐



#### Immediate Execute (\*)
![Trigger option Immediate Execute][] 

The option (\*) is called *immediate execute* because  entering of the last character of **triggerstring** immediately executes exchange of the **triggerstring** with the **hotstring**.:

1. The **hotstring recognizer** starts only just after *endchar* is detected. So the *endchar* is required directly before the **triggersting**.
2. **Triggerstring** is not case sensitive.
3. After **triggerstring** no **trigger** key have to be pressed by user in order to trigger the hotstring. The last character of **triggerstring** is the **trigger**.

> **triggerstring** 
>
> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↑
>
> then the 
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;**last character of that string is a trigger**

4. **Triggerstring** is ~~erased~~ and exchanged with **hotstring**.  As a consequence **trigger** (the last key of triggerstring) is erased.

option | endchar required? | triggestring                          | trigger    | hotstring
----------|--------------------------|-----------------------------------|-------------|---
?           | yes                              |~~alphanumeric string~~  | ~~last character of triggerstring~~ | alphanumeric string


---
*Example of triggerstring and hotstring definition*

option | triggerstring     | trigger: last character  | hotstring
-------|-------------------|---------------------------|-----------
\*     | ~~btw/~~        | ~~/~~                   | by☐the☐way

![Example, immediate execute][] 


*Example, execution*

input stream |    triggerstring | trigger| replaced by hotstring
---------------|---------------------------|-------------|-----------
Something,☐something☐ | ~~btw~~ | ~~/~~ | by☐the☐way

> Something,☐something☐ ~~btw/~~ by☐the☐way

Comment: the triggerstring, including the last character, is erased, what is shown by ~~strikethrough~~.

---

#### No Backspace (B0)
![Trigger option No Backspace][] 

By default the **hotstring** replaces the **triggestring**, what was shown in the above examples by ~~strikethrough~~ from the content stream the **triggerstring**. When (B0) option is applied, the **triggestring** is not replaced (no backspace = no erasing) by the **hotstring** but is followed by the **hotstring**:

1. The **hotstring recognizer** starts only just after *endchar* is detected. So the *endchar* is required directly before the **triggersting**.
2. **Triggerstring** is not case sensitive.
3. After **triggerstring** additionally one **trigger** key have to be pressed by user in order to trigger the hotstring. *Trigger* key is defined by default set of *endchar*.
4. **Triggerstring** is not erased but followed by **hotstring**. 
5. **Trigger** is not erased.

option | endchar required? | triggestring                          | trigger    | hotstring
----------|--------------------------|-----------------------------------|-------------|---
?           | yes                              |~~alphanumeric string~~  | *endchar* | alphanumeric string


---
*Example of triggerstring and hotstring definition*

![Example, no Backspace][] 

*Example, execution*

input stream |    triggerstring | trigger| replaced by hotstring
---------------|---------------|-------------------------|-----------
Something,☐something☐ | btw | . | by☐the☐way.

> Something,☐something☐btw.by☐the☐way.


---
*Example of useful B0 hotstring*
The B0 option is useful for example to define HTML tags. In the following example the sequence {left☐5} is used to move to the left (back) cursor after he sequence </em> is entered.

option | triggerstring     | trigger: last character   | hotstring
-------|-------------------|---------------------------|-----------
\*B0    | <em              | >                         | </em>{left☐5}

*Example, execution*

input stream |    triggerstring | trigger  | replaced by hotstring
---------------|----------------------------|------------|-----------
Something,☐something☐| \<em | > | \</em>

> Something,☐something☐\<em>|\</em>


Comment: The cursor (shown as |) has been moved backward by 5 characters and now is between the HTML tags.

---

#### No End Char (O)
![Trigger option No Endchar][] 

Similar to default option, but this time the **trigger** is erased together with **triggerstring**:

1. The **hotstring recognizer** starts only just after *endchar* is detected. So the *endchar* is required directly before the **triggersting**.
2. **Triggerstring** is not case sensitive.
3. After **triggerstring** additionally one **trigger** key have to be pressed by user in order to trigger the hotstring. *Trigger* key is defined by default set of *endchar*.
4. **Triggerstring** is ~~erased~~ and exchanged with **hotstring**. 
5. **Trigger** is also  ~~erased~~.

option | endchar required? | triggestring                          | trigger    | hotstring
----------|--------------------------|-----------------------------------|-------------|---
?           | no                              |~~alphanumeric string~~  | ~~*endchar*~~ | alphanumeric string

---
*Example of triggerstring and hotstring definition*

![Example No EndChar][] 

*Example, execution*

input stream |    triggerstring |  trigger| replaced by hotstring
---------------|-----------------------|-----------------|-----------
Something,☐something☐ | ~~btw~~ | ~~.~~ | by☐the☐way.

> Something,☐something☐ ~~btw.~~ by☐the☐way

---

#### Case Sensitive (`C)
![Trigger option Case Sensitive][] 

Similar to default option, but this time the **triggerstring** is case sensitive:

1. The **hotstring recognizer** starts only just after *endchar* is detected. So the *endchar* is required directly before the **triggersting**.
2. **Triggerstring** is case sensitive.
3. After **triggerstring** additionally one **trigger** key have to be pressed by user in order to trigger the hotstring. *Trigger* key is defined by default set of *endchar*.
4. **Triggerstring** is ~~erased~~ and exchanged with **hotstring**. 
5. **Trigger** is not erased.

option | endchar required? | triggestring                          | trigger    | hotstring
----------|--------------------------|-----------------------------------|-------------|---
?           | yes                              |~~alphanumeric string~~  | *endchar* | alphanumeric string

---
*Example of triggerstring and hotstring definition*

![Example Case Sensitive][] 

---
*Example, execution*

input stream |    triggerstring |  trigger| replaced by hotstring
---------------|-----------------------|-----------------|-----------
Something,☐something☐ | ~~Btw~~ | . | by☐the☐way.

> Something,☐something☐ ~~btw~~ . by☐the☐way.

---

#### Inside Word (?)
![Trigger option Inside Word][]

Similar to default option, but this time *endchar* directly before the **triggerstring** is not required:

1. The **hotstring recognizer** observes input stream after the last *endchar* is detected. So the *endchar* is not required directly before the **triggersting**. The **triggerstring** can be triggered at any time after the last *endchar*.
2. **Triggerstring** is not case sensitive.
3. After **triggerstring** additionally one **trigger** key have to be pressed by user in order to trigger the hotstring. *Trigger* key is defined by default set of *endchar*.
4. **Triggerstring** is ~~erased~~ and exchanged with **hotstring**. 
5. **Trigger** is not erased.

option | endchar required? | triggestring                          | trigger    | hotstring
----------|--------------------------|-----------------------------------|-------------|---
?           | no                              |~~alphanumeric string~~  | *endchar*  | alphanumeric string


---
*Example, execution*

input stream | endchar required? |    triggerstring |  trigger| replaced by hotstring
------------------|---------------------------|--------------------|----------|-----------------------------
                        |               no                 |                           |              |             
Something,☐something | | ~~btw~~ | . | by☐the☐way.

> Something,☐something~~btw~~ . by☐the☐way.


---

#### Disable
![Disable][]

The **hotstring* definition is left as on time of last edition, but switched off. So **hotstring recognizer** do not detect it anymore. The definition is left in corresponding library file (.csv). 

The opposite action can take place: if user will edit definition of particular *hotstring* and uncheck the tick *disable*, then *hotstring* become active again. Next time when corresponding **triggerstring** will occurre in input stream, the **hotstring recognizer** will trigger corresponding **hotstring** according to previously defined **option(s)**.

![Disable example][]

---


## Overlapping hotstrings
One of the useful options (...) are overlapping hotstrings.

---
*Example 1 of overlapping triggerstrings*
The triggestrings of the two following examples overlap, but the first one is shorther, then the second one.

option | triggerstring     | trigger:    | hotstring
-------|-------------------|---------------------------|-----------
|    | btw               | -()[]{}':;"/\,.?!\`n☐\`t  | by the way
\*    | btw2              | 2                         | back to work

*Example, execution*
content stream |    triggerstring | trigger replaced by | hotstring
---------------|----------------------------------------|-----------
Something,☐something☐| btw☐ | by☐the☐way☐


> Something,☐something☐ ~~btw☐~~ by☐the☐way☐

The second hotstring will never be triggered, as always after triggering of the first triggestring (btw) the triggerstring is reset. The solutions to this issue are shown in the following examples.


---
*Example 2 of overlapping triggerstrings*
The triggestrings of the two following examples overlap, but this time both of them are of the same length.
option | triggerstring     | trigger: last character   | hotstring
-------|-------------------|---------------------------|-----------
\*    | btw1               | 1                     | by the way
\*    | btw2              | 2                         | back to work

*Example, execution*
content stream |    triggerstring | trigger replaced by | hotstring
---------------|----------------------------------------|-----------
Something,☐something☐ | btw1 | by☐the☐way
☐ | btw2 | back☐to☐work

> Something,☐something☐ ~~btw1~~ by☐the☐way☐ ~~btw2~~ back☐to☐work


---
*Example 3 of overlapping triggerstrings*
The space itself can be a part of triggestring as well. What's is important is the length of the triggerstrings. This can be useful to distinguish the abbreviation from its phrase, as in the following example.
option | triggerstring     | trigger: last character   | hotstring
-------|-------------------|---------------------------|-----------
\*    | api☐               | ☐                     | API
\*    | api/              | /                         | Application☐Programming☐Interface

---
*Example 4 of overlapping triggerstrings, special feature of Hotstring application: menu*
Thanks to Hotstrings application the one triggestring can be used to trigger menu with defined list of hotstrings. The different options are separated by "|" mark. The first option on the list is the default one. Selection of the option is made by pressing the Enter key. Cauion, it doesn't work with mouse clicks.
option | triggerstring     | trigger: last character   | hotstring
-------|-------------------|---------------------------|-----------
\* and menu    | api/              | /                         | API *| Application☐Programming☐Interface


---

# Configuration

## Endchar

Let's imagine user input string, so stream of keyboard pressed keys: 

*Example☐of☐the☐sentence☐where☐user☐would☐like☐to☐exchange☐triggerstring☐e@☐with☐his☐e-mail:☐`firstname.secondname@domain.com`*

The **hostring recognizer** observes input stream which contains besides letters also other categories of characters: digits, punctuation characters, blank characters, special characters etc. Some of them belong to special group called end character or *endchar* for short. The characters belonging to the *endchar* group has the following purposes, helping to **hotstring recognizer**:

1. recognize when **triggestring** begins,
2. recognize when **triggerstring** ends,
3. reset itself.

Maybe *endchar* is not the right therm and better would be *stopchar* or *trigger separator*? For compatibility with official documentation of AutoHotkey the term *endchar* is kept in this manual.

By default **triggerstring** begins after a character belonging to *endchar* but with special **option** called *inside word (?)* it can trigger **triggerstring** even between *endchar*, e.g. witin a word. It's done on purpose that *endchar* by default containts the following set of characters: 

-()[]{}':;"/\,.?!\`n☐\`t 

(note that \`n is Enter, \`t is Tab, and there is a plain space between \`n and \`t marked as ☐). 

These characters are usually used to separate words or sentences. So often **hotstring recognizer** starts to recognize if **triggestring** is there, word by word and resets after each *endchar*. 

User of *Hotstrings* application can change this default behavior thanks to configuration of *endchar*. 


---

# Hostrings libraries
(...)


 
 # Undoing of the last hotsring
 The last hotstring can be easily undone by pressing Cltr | z hotkey or Ctrl | Backspace. 
 
 **Caution:** In some applications the same hotkeys are used for undoing the last action. Then the overall result sometimes is unpredictable or unwanted. In case of some trouble use undoing hotstring several times in a raw.

# Credits

The originator and creator of the Hotstrings application is Jack Dunning aka [Jack][] who has created the very first version of *[Instant Hotstring][]* application.

People from AutoHotkey community, especially those who help at [AutoHotkey forum][].

Tools:

* Markdown (MD) text editor: https://hackmd.io/
* Table generator: https://www.tablesgenerator.com/markdown_tables#

# Other remarks
Other remarks helpful in everyday working with hotstrings.

## Order of loading AutoHotkey scripts matters. 
For example if you use *Diacritics.ahk* together with *Hotstrings.ahk*, there is potential collission. (...)

## Not always applying clipboard output function is a good idea
Some forms, especially at bank web pages, do not accept pasting from clipboard. Probably there are safety reasons behind that. From the other hand keep in mind that AutoHotkey itself simulates keyboard keypressing. So to get over this limitation it's enough edidt particular hotstring and switch *Select hotstring output function* from *Send by Clipboard* to *Send by AutoHotkey*.

## Interaction of hotstrings pasted from clipboard with clipboard managers
(...)

# ToDo List
- ❎ Menu: configuration and the corresponding *Configuration.ini*
    - ❎ sandbox for hotstrings,
    - ❎ enable / disable "undo" (Ctrl | z) of hotstrings,
    - ☑ setup of "Ending character",
    - ❎ *Hotstrings* window size and position, including monitor, window size.
- ❎ Automatic tooltip for triggestrings.
- ❎ GUI:
    - ❎ comments to hotstrings (stored in .csv files).
    - ❎ library content is marked, edition should be loaded automatically.
    - ❎ search window, a searched result should enable direct edition.
    - ❎ hotkeys to main functions
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

[AutoHotkey]: https://www.autohotkey.com/
[hotstring]: https://www.autohotkey.com/docs/Hotstrings.htm/
[documentation of AutoHotkey]: https://www.autohotkey.com/docs/Hotstrings.htm/
[Jack]: https://jacks-autohotkey-blog.com/
[Instant Hotstring]: http://www.computoredge.com/AutoHotkey/Free_AutoHotkey_Scripts_and_Apps_for_Learning_and_Generating_Ideas.html#instanthotstrings
[AutoHotkey forum]: https://www.autohotkey.com/boards/
[GNU GPL ver. 3]: https://github.com/mslonik/Hotstrings/blob/master/LICENSE
[Source code]: https://github.com/mslonik/Hotstrings
[Maciej's homepage]: http://mslonik.pl