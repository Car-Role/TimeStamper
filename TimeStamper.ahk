#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
global FortmatedCounter
Start := 0
Counter = 0
StartLabel = Start
SetTimer, GuiCounter, 100

IniRead, savedHK%A_Index%, Hotkeys.ini, Hotkeys, 1, %A_Space%
If savedHK%A_Index%                                       ;Check for saved hotkeys in INI file.
	Hotkey,% savedHK%A_Index%, Label1                 ;Activate saved hotkeys if found.

Gui, Add, Button, x22 y139 w100 h30 +Center gStart vStart, %StartLabel%
Gui, Add, Button, x142 y139 w110 h30 gStop, Edit Hotkeys
Gui, Add, Text, x176 y49 w80 h30 vCountertext, %Counter%
Gui, Add, Button, x272 y139 w100 h30 gGuiClose, Exit
Gui, Add, Text, x162 y99 w80 h30 , Default Hotkey Ctrl + Shift + V
;~ Gui, Add, Hotkey, x142 y129 w100 h30 , vHK0 gLabel, %noMods% 
Gui, Add, Button, x22 y64 w40 h30 gGuiCounterminusminus, -5s
Gui, Add, Button, x82 y64 w40 h30 gGuiCounterminus, -1s
Gui, Add, Button, x272 y64 w40 h30 gGuiCounterplus, +1s
Gui, Add, Button, x332 y64 w40 h30 gGuiCounterplusplus, +5s
Gui, Add, Button, x22 y20 w40 h30 gGuiCounterminusminusm, -5m
Gui, Add, Button, x82 y20 w40 h30 gGuiCounterminusm, -1m
Gui, Add, Button, x272 y20 w40 h30 gGuiCounterplusm, +1m
Gui, Add, Button, x332 y20 w40 h30 gGuiCounterplusplusm, +5m
Gui, Show, w397 h193, Timerstamper
;~ GuiControl,, HK0, %noMods%

Loop
 {
	Sleep, 1000
	if Start = 0
	Start := 0
	else if Start = 1
	Counter := % Counter + 1
 }

GuiClose:
	MsgBox, 4,, Are you sure you want to exit?
	IfMsgBox Yes
		ExitApp
	IfMsgBox No
		return

Start:
	if Start = 1
	{
		Start := 0
		StartLabel = Resume 
		GuiControl,,Start, %StartLabel%
	}
	else 
	{
		Start := 1
		StartLabel = Pause 
		GuiControl,,Start, %StartLabel%
	}
	return

Stop:
		SetBatchLines, -1
		ControlGet, UniqueID , Hwnd,,, Dynamic Hotkeys
		if WinExist("Dynamic Hotkeys")
			{
			WinActivate Dynamic Hotkeys
			return
			}
		Else
			{
			#ctrls = 1  ;How many Hotkey controls to add.
			Loop,% #ctrls {
				Gui, 2:Add, Text, xm, Enter Hotkey #%A_Index%:
				IniRead, savedHK%A_Index%, Hotkeys.ini, Hotkeys, %A_Index%, %A_Space%
				If savedHK%A_Index%                                       ;Check for saved hotkeys in INI file.
					Hotkey,% savedHK%A_Index%, Label%A_Index%                 ;Activate saved hotkeys if found.
				StringReplace, noMods, savedHK%A_Index%, ~                  ;Remove tilde (~) and Win (#) modifiers...
				StringReplace, noMods, noMods, #,,UseErrorLevel              ;They are incompatible with hotkey controls (cannot be shown).
				Gui, 2:Add, Hotkey, x+5 vHK%A_Index% gLabel, %noMods%           ;Add hotkey controls and show saved hotkeys.
				Gui, 2:Add, CheckBox, x+5 vCB%A_Index% Checked%ErrorLevel%, Win  ;Add checkboxes to allow the Windows key (#) as a modifier...
				}                                                                ;Check the box if Win modifier is used.
				Gui, 2:Show,,Dynamic Hotkeys
			}
		return
		
		2GuiClose:
			Gui 2:Destroy
			return

		Label:
		 If %A_GuiControl% in +,^,!,+^,+!,^!,+^!    ;If the hotkey contains only modifiers, return to wait for a key.
		  return
		 num := SubStr(A_GuiControl,3)              ;Get the index number of the hotkey control.
		 If (HK%num% != "") {                       ;If the hotkey is not blank...
		  Gui, 2:Submit, NoHide
		  If CB%num%                                ;  If the 'Win' box is checked, then add its modifier (#).
		   HK%num% := "#" HK%num%
		  If !RegExMatch(HK%num%,"[#!\^\+]")        ;  If the new hotkey has no modifiers, add the (~) modifier.
		   HK%num% := "~" HK%num%                   ;    This prevents any key from being blocked.
		  Loop,% #ctrls
		   If (HK%num% = savedHK%A_Index%) {        ;  Check for duplicate hotkey...
			dup := A_Index
			Loop,6 {
			 GuiControl,% "Disable" b:=!b, HK%dup%  ;    Flash the original hotkey to alert the user.
			 Sleep,200
			}
			GuiControl,,HK%num%,% HK%num% :=""      ;    Delete the hotkey and clear the control.
			break
		   }
		 }
		 If (savedHK%num% || HK%num%)
		  setHK(num, savedHK%num%, HK%num%)
		return

		setHK(num,INI,GUI) {
		 If INI
		  Hotkey, %INI%, Label%num%, Off
		 If GUI
		  Hotkey, %GUI%, Label%num%, On
		 IniWrite,% GUI ? GUI:null, Hotkeys.ini, Hotkeys, %num%
		 savedHK%num%  := HK%num%
		 TrayTip, Label%num%,% !INI ? GUI " ON":!GUI ? INI " OFF":GUI " ON`n" INI " OFF"
		}

		Label1:
		Send (%FortmatedCounter%)
		return

GuiCounter:
	FormateCount(Counter)
	 return
 
GuiCounterplus:
	Counter := % Counter + 1
	FormateCount(Counter)
	return


GuiCounterplusplus:
	Counter := % Counter + 5
	FormateCount(Counter)
	return
	
GuiCounterminus:
	Counter := % Counter + (-1)
	FormateCount(Counter)
	return


GuiCounterminusminus:
	Counter := % Counter + (-5)
	FormateCount(Counter)
	return
	
GuiCounterplusm:
	Counter := % Counter + 60
	FormateCount(Counter)
	return


GuiCounterplusplusm:
	Counter := % Counter + 300
	FormateCount(Counter)
	return
	
GuiCounterminusm:
	Counter := % Counter + (-60)
	FormateCount(Counter)
	return


GuiCounterminusminusm:
	Counter := % Counter + (-300)
	FormateCount(Counter)
	return

FormateCount(Time) {
	FortmatedCounter := FormatSeconds(Time)
	GuiControl,,Countertext, %FortmatedCounter%
	return FortmatedCounter
}


return

^+v::
Send (%FortmatedCounter%)



FormatSeconds(NumberOfSeconds)  ; Convert the specified number of seconds to hh:mm:ss format.
{
    time = 19990101  ; *Midnight* of an arbitrary date.
    time += %NumberOfSeconds%, seconds
    FormatTime, mmss, %time%, mm:ss
    return NumberOfSeconds//3600 ":" mmss
}