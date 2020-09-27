# Hotstrings
AutoHotkey oriented GUI to Hotstrings with many useful features:
- applying clipboard instead of the classical simulation of keyboard (useful especially for long text strings),
- one triggering abbreviation can call several different text strings of your choice, chosen from menu,
- overview of existing hotstrings,
- definitions of hotstrings are stored in .csv files, as many, as you like,
- undoing of hotstrings (conversion of last entered hotstring again into triggering abbreviation),
- ...

This application is written in AutoHotkey script language but does not require this language interpreter to be installed and can be run standalone thanks to .exe file. (Nevertheless installation of [AutoHotkey](https://www.autohotkey.com/) is greatly adviced). The concept and usage of hotstrings is based on AutoHotkey [hotstring]((https://www.autohotkey.com/docs/Hotstrings.htm) notion.

The hotstrings defined in this application are operating system wide. It means that can be triggered in any text / edit window, in any application.

This application will run on Microsoft Windows family operating systems.

---

# What are the hotstrings (absolute beginner quide)
There are two notions:
- triggerstring,
- hotstring.

The relationship between these two:
**triggerstring** → **hotstring**
So the triggerstring triggers the corresponding hotstring. The triggestring is usually short. Opposite to that the hotstring usually is longer or long in comparison to triggestring. As a consequence one can save some time when uses hotstrings.

Wording convention: usually the corresponding pair of alphanumeric strings (triggestring, hotstring) is also called as hotstring. When it comes to confusing, both of them will be differentiated.

# How the AutoHotkey and hotstrings work
The AutoHotkey: 
* keeps in memory the pairs (triggerstring, hotstring) 
and 
* applies the hotstring recognizer which filters the input stream of keys pressed by the user, searching for the triggestrings. 

If the triggestring is recognized: 
* the hostring is issued,
* the hotstring recognizer is reset.

# Why somobody may want to use hotstrings?
Because they can significantly make life easier and... longer? Nowadays we still frequently use keyboard as input device to so called personal computer. This computer is not so "personal" as you can't easily define system wide (working in any application) triggering abbreviation in form of jg/ → Jane Goodall or for sake of your e-mail jg@ → jane.goodall@yourhosting.com. So let's make your PC really personal again. Now with use of hotstrings and Hotstring application.

# Why somebody may want to use *Hotstring* application?
Because it doesn't require much knowledege and text editing to run your own hotstrings. Thanks to GUI (Graphical User Interface) entering and applying of new hotstrings is a breeze.

# Main window of *Hotstring* application
After installation just double click on the Hotstrings icon (marked in red) in system tray ![Example of system tray](/HelpPictures/Hotstring3_SystemTray.png) or... use hotkey Ctrl + # + h (Control + Windows key + h).
Next you'll see main GUI (Graphical User Interface) window which enable you to edit hotstrings:

![Main window](/HelpPictures/Hotstring3_MainWindow.png)

The main window can be divided into the following parts:
- Hotstring menu,
- Hotstring definition / edition,
- Display of existing hotstrings.

# Let's begin by defining of few first hotstrings
At first please observe the main window again. In order to define any hotstring one have to follow top down the screen:
![Defining of hotstring](/HelpPictures/Hotstring3_DefiningOfHotstring.png)
- Enter triggerstring
- Select trigger option(s)
- Select hotstring output function
- Enter hotstring
- Select hotstring library
- Set the hotstring

We will start by definition of "by the way" hotsring with different triggerstrings and different options.

## Enter triggestring
Let's put in this text edit field some text: 
![Enter triggerstring](/HelpPictures/Hotstring3_EnterTriggerstring.png)
Please keep in mind that this window does not show space key, as it is blank key. But in this tutorial it will be easier to see what we're doing by using the ☐ convention from now on to show the Space (Spacebar key). So now let's put there:
```
btw
```

## Select trigger option(s)
Variants of triggering the hotstring are controlled by the options:
![Select trigger option(s)](/HelpPictures/Hotstring3_SelectTriggerOption.png)

option             | triggerstring | hotstring
-------------------|---------------|-----------
\* / B0 / O / C / ? | triggerstring |    hotstring
### By default no option is set (option string is empty)
If no option is set, then after triggerstring additionally one trigger key is required in order to get the hotstring.
option | triggestring      | hotstring
-------|-------------------|-------------------
|       | string + trigger  |        hotstring

Then the trigger key is defined as  -()[]{}':;"/\,.?!\`n☐\`t (note that \`n is Enter, \`t is Tab, and there is a plain space between \`n and \`t marked as ☐). 

At the moment Hotstring application does not allow to change the set of trigger keys. 

Let's leave no option set and continue.

## Select hotstring output function
![Select hotstring output function](/HelpPictures/Hotstring3_SelectHostringOutputFunction.png)
Select one and only one option from the list. By default *Send by AutoHotkey* is set. Let's leave it. It means that the hotstring will be output by AutoHotkey, without menu and not by Clipboard. More about *output functions* later on.

## Enter hotstring
![Enter hotstring](/HelpPictures/Hotstring3_EnterHotsring.png)
Let's do that:
```
by the way
```
## Select hotstring library
![Select hotstring library](/HelpPictures/Hotstring3_SelectHostringLibrary.png) 
This list contains all and only *.csv files from withing folder ..\Hotstrings3\Categories. One can have as many files (even empty!) as necessary.

Let's select the AutocorrectionHotstring.csv for sake of example.

## Set the hotstring
Select / click the *Set hostring* button. The function and meaning of two others is hopefully quite obvious. It will be explained in details later on.
![Set the hotstring](/HelpPictures/Hotstring3_HostringButtons.png) 

## Congratulations!
You've defined your first hotstring. Have a look now into the left part of the main screen, into the *Library content*. Find there your newly defined hotstring:
![Library content](/HelpPictures/Hotstring3_LibraryContent1.png)

---
*Example of triggerstring and hotstring definition*
option | triggerstring     | trigger: any of           | hotstring
-------|-------------------|---------------------------|-----------
 |     | btw               | -()[]{}':;"/\,.?!\`n☐ \`t  | by☐the☐way
*Example, execution*
content stream |    triggerstring + trigger  | replaced by hotstring
---------------|----------------------------------------|-----------
Something,☐something☐| ~~btw.~~ ☐ | by☐the☐way☐

Something,☐something☐ ~~btw.~~ ☐ by☐the☐way☐

---
### When the option (\*) is applied
**triggerstring** = **string**
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↑
then the 
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;**last character of that string can be a trigger**
The option (\*) is called "immediate execute".
---
*Example of triggerstring and hotstring definition*
option | triggerstring     | trigger: last character  | hotstring
-------|-------------------|---------------------------|-----------
\*     | btw/              | /                         | by☐the☐way
*Example, execution*
content stream |    triggerstring + trigger| replaced by hotstring
---------------|----------------------------------------|-----------
Something,☐something☐ | ~~btw/~~ | by☐the☐way
Something,☐something☐ ~~btw/~~ by☐the☐way

---

### When the option (B0) is applied
By default the **hotstring** replaces the **triggestring**, what was shown in the above examples by ~~crossing out~~ from the content stream the **triggerstring**. When (B0) option is applied, the **triggestring** is not replaced by the **hotstring** **AND** is still ready to trigger another **hotstring**. This option is very handy if there are more than one **triggerstrings** which partly overlap.

---
*Example of triggerstring and hotstring definition*
option | triggerstring     | trigger: any of           | hotstring
-------|-------------------|---------------------------|-----------
B0     | btw               | -()[]{}':;"/\,.?!\`n☐\`t  | by☐the☐way
*Example, execution*
content stream |    triggerstring + trigger| replaced by hotstring
---------------|----------------------------------------|-----------
Something,☐something☐ | btw. | by☐the☐way.
```
Something,☐something☐btw.by☐the☐way.
```

---
*Example of triggerstring and hotstring definition*
option | triggerstring     | trigger: last character   | hotstring
-------|-------------------|---------------------------|-----------
*B0    | btw/              | /                         | by☐the☐way
*Example, execution*
content stream |    triggerstring + trigger| replaced by hotstring
---------------|----------------------------------------|-----------
Something,☐something☐| btw/ | by☐the☐way
```
Something,☐something☐btw/by☐the☐way/
```
---
*Example of useful B0 hotstring*
The B0 option is useful for example to define HTML tags. In the following example the sequence {left☐5} is used to move to the left (back) cursor after he sequence </em> is entered.

option | triggerstring     | trigger: last character   | hotstring
-------|-------------------|---------------------------|-----------
*B0    | <em>              | >                         | </em>{left☐5}
*Example, execution*
content stream |    triggerstring + trigger  | replaced by hotstring
---------------|----------------------------------------|-----------
Something,☐something☐| <em> | </em>
```
Something,☐something☐<em></em>
```


---
*Example 1 of overlapping triggerstrings*
The triggestrings of the two following examples overlap, but the first one is shorther, then the second one.

option | triggerstring     | trigger:    | hotstring
-------|-------------------|---------------------------|-----------
|    | btw               | -()[]{}':;"/\,.?!\`n☐\`t  | by the way
*    | btw2              | 2                         | back to work
*Example, execution*
content stream |    triggerstring + trigger replaced by | hotstring
---------------|----------------------------------------|-----------
Something,☐something☐| btw☐ | by☐the☐way☐

```
Something,☐something☐ ~~btw☐~~ by☐the☐way☐
```
The second hotstring will never be triggered, as always after triggering of the first triggestring (btw) the triggerstring is reset. The solutions to this issue are shown in the following examples.


---
*Example 2 of overlapping triggerstrings*
The triggestrings of the two following examples overlap, but this time both of them are of the same length.
option | triggerstring     | trigger: last character   | hotstring
-------|-------------------|---------------------------|-----------
*    | btw1               | 1                     | by the way
*    | btw2              | 2                         | back to work
*Example, execution*
content stream |    triggerstring + trigger replaced by | hotstring
---------------|----------------------------------------|-----------
Something,☐something☐ | btw1 | by☐the☐way
☐ | btw2 | back☐to☐work
```
Something,☐something☐ ~~btw1~~ by☐the☐way☐ ~~btw2~~ back☐to☐work
```

---
*Example 3 of overlapping triggerstrings*
The space itself can be a part of triggestring as well. What's is important is the length of the triggerstrings. This can be useful to distinguish the abbreviation from its phrase, as in the following example.
option | triggerstring     | trigger: last character   | hotstring
-------|-------------------|---------------------------|-----------
*    | api☐               | ☐                     | API
*    | api/              | /                         | Application☐Programming☐Interface

---
*Example 4 of overlapping triggerstrings, special feature of Hotstring application: menu*
Thanks to Hotstrings application the one triggestring can be used to trigger menu with defined list of hotstrings. The different options are separated by "|" mark. The first option on the list is the default one. Selection of the option is made by pressing the Enter key. Cauion, it doesn't work with mouse clicks.
option | triggerstring     | trigger: last character   | hotstring
-------|-------------------|---------------------------|-----------
* and menu    | api/              | /                         | API *| Application☐Programming☐Interface


---

Thanks to this application one can define as many pairs (triggering abbreviation and hotstring) as she/he likes and store them in convenient way in separate .csv files. Each file can contain hotstring belonging to specific category, e.g. emojis, physical symbols, first and second names etc.



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

**Tip:** Sometimes when long hotstrings are triggered and clipboard is applied to immediately enter it, strange behaviour can occurre. Instead of expected hotstring the previous content of clipboard may appear. The reason is that operating system can not gurantee the time to insert the content of clipboard into specific window / editing field. In order to support operating system enlarge the delay. The shorter the delay than better, but if too short, mentioned behaviour can be observed.

### Help
Link to this file is provided.

### About
**Hotstrings.ahk (script)**. 
*Let's make your PC personal again...*
Enables convenient definition and use of hotstrings (triggered by shortcuts longer text strings). This is 3rd edition of this application, 2020 by Jakub Masiak and Maciej Słojewski (🐘). License: [GNU GPL ver. 3](https://github.com/mslonik/Hotstrings/blob/master/LICENSE). [Source code](https://github.com/mslonik/Hotstrings). [Homepage](http://mslonik.pl).

## Hotstring definition / edition
The new hotstring is defined from top to bottom of the screen. Let's see how it's made, step by step, with the following example:

**triggering abbreviation **|→| **hotstring**
------------------------|-|-------------------
btw/ | → | by the way

### Enter triggering abbreviation
This edit field enable you to enter any triggering abbreviation. In our example it will be equal to *btw/*.

**Tip:** It's worth to differentiate somehow triggering abbreviations from other words. It can be easily the case that the same word is used as the triggering abbreviation and the word itself. So to trigger on purpose it's good to add to triggering abbreviation unique sign / key, which can be easily reached and is seldomly used otherwise. The perfect candidate for that puspose is "/" (slash).

### Triggering options

The following options are described. After full name of each option, in parenthesis one can find short notation used in AutoHotkey for compatibility, if available.

#### Immediate Execute (*)
No ending sequence is required. Another words as soon as triggering abbreviation is finished, immediately it's exchanged into hotstring. 

By default hotstrings are triggered when triggering abbreviation is finished with ending character, which by default is space ( ), dot (.), coma (,) etc. Examples:

 triggering abbreviation without immediate execute: btw/( )
 triggering abbreviation with immediate execute: btw/
 
 #### No Backspace (B0)
 The triggering sequence is kept in memory and is not exchanged (erased) automatically. In order to erase the letters (but not from memory), the backspace can be used. For that purpose apply curly brackets, and within BackSpace word and number indicating how many backspaces should be applied. E.g. {BackSpace 3} ← 3x backspaces will be triggered.
 
 **Tip:** Abbreviations and conversion of lower case to uppercase. Let's follow the following example: Jane would like to use api triggering abbreviation for both purposes:
 1. to automatically convert this abbreviation lower case to uppercase.
 2. to trigger the hotstring Application Programming Interface.
 
 For that purpose Jane defined two hotstrings:
 **triggering abbreviation **|→| **hotstring**
------------------------|-|------------------
 api | Immediate Execute, No Backspace | {BackSpace 3}API
 api/ | Immediate Execute | Application Programming Interface
 
 These two hotstrings work as a pair: thanks to "No Backspace" option the triggering abbreviation is kept in memory. 
 
 If Jane writes api, this abbreviation triggers immediately hotstring API. Next, if Jane decides to add "/" to hotstring API: API/, then API/ works as next triggering abbreviation which unfold to hotstring Application Programming Interface. 
 
 **Tip:** Immediate execute is not always welcomed. It's better to use it only if chances that certain abbreviation will not occurre within other words. Good example is word led which can be used as LED (Light Emitting Diode), but is also usde in e.g. word ledge. In such a case carefully define a triggering abbreviation or use udoing method.
 
 #### No End Char (O)
 
 #### Case Sensitive (C)
 
 #### Inside Word (?)
 
 #### Disable
 
 # Undoing of the last hotsring
 The last hotstring can be easily undone by pressing Cltr + z hotkey or Ctrl + Backspace. 
 
 **Caution:** In some applications the same hotkeys are used for undoing the last action. Then the overall result sometimes is unpredictable or unwanted. In case of some trouble use undoing hotstring several times in a raw.