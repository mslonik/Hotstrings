#NoEnv  						; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  							; Enable warnings to assist with detecting common errors.
SendMode Input  				; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%		; Ensures a consistent starting directory.
#SingleInstance force 			; only one instance of this script may run at a time!

#Hotstring ?
; #Hotstring c b0 ? * 


; _BaseKey 		:= "n"
; , _Diacritic 	:= "A"

Hotstring("::nn", func("DiacriticLetter"))
; Hotstring("::" . _BaseKey . _BaseKey, func("DiacriticLetter").bind(_Diacritic))


 ;~ - - - - - - - - - - - - - - - - - - - - - - SECTION OF FUNCTIONS - - - - - - - - - - - - - - - - - - - - - - - - - - - 


;~ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

DiacriticLetter()
{
	; global _AllBeeps, _AllTooltips, _DoubleWord
	
	Send, A
	; Send, {BackSpace 2}A
}