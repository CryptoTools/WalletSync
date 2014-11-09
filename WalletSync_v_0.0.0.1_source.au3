#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Icon.ico
#AutoIt3Wrapper_Res_Comment=Backup your crypto currency wallets every minute.
#AutoIt3Wrapper_Res_Description=Keep a sync'd copy of all the crypto-currency wallet.dats found in there default locations on you PC.
#AutoIt3Wrapper_Res_Fileversion=0.0.0.1
#AutoIt3Wrapper_Res_LegalCopyright=Copyright 2014 zelles
#AutoIt3Wrapper_Res_Language=1033
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
;#NoTrayIcon
#include <GUIConstantsEx.au3>
#include <GUIListBox.au3>
#include <Misc.au3>
#include <StaticConstants.au3>
#include <TrayConstants.au3>
#include <WindowsConstants.au3>

_Singleton("zellesWalletSync")

OnAutoItExitRegister("CloseSync")

Opt("TrayMenuMode", 3)

Global $GUI_Wallet_Sync = GUICreate("Wallet Sync", 162, 196, 258, 150)
Global $GUI_File = GUICtrlCreateMenu("&File")
Global $GUI_File_Minimize = GUICtrlCreateMenuItem("&Minimize", $GUI_File)
Global $GUI_File_Exit = GUICtrlCreateMenuItem("&Exit", $GUI_File)
Global $GUI_Help = GUICtrlCreateMenu("&Help")
Global $GUI_Help_About = GUICtrlCreateMenuItem("&About", $GUI_Help)
Local $GUI_Label1 = GUICtrlCreateLabel("Backing Up:", 8, 8, 95, 19)
GUICtrlSetFont(-1, 9, 800, 0, "Arial")
Global $GUI_Label2 = GUICtrlCreateLabel("Label2", 24, 32, 132, 17)
Local $GUI_Label3 = GUICtrlCreateLabel("Detected Wallets:", 8, 56, 104, 19)
GUICtrlSetFont(-1, 9, 800, 0, "Arial")
Global $GUI_Wallets_Found = GUICtrlCreateList("", 0, 80, 161, 95, BitOR($LBS_NOTIFY,$LBS_SORT,$WS_VSCROLL))
GUISetState(@SW_SHOW, $GUI_Wallet_Sync)

Global $GUI_Tray_Open = TrayCreateItem("Open WalletSync")
TrayCreateItem("")
Global $GUI_Tray_Exit = TrayCreateItem("Exit")
TraySetState($TRAY_ICONSTATE_SHOW)

Global $SyncAdded = "||"
Global $SyncScan = FileFindFirstFile(@AppDataDir & "\*.*")
While 1
	GUI_Events()
	Local $SyncScanResult = FileFindNextFile($SyncScan)
	If @error Then SyncReset()
	If @extended = 1 Then
		If FileExists(@AppDataDir & "\" & $SyncScanResult & "\wallet.dat") Then
			GUICtrlSetData($GUI_Label2, $SyncScanResult)
			If Not StringInStr($SyncAdded, "||" & $SyncScanResult & "||") Then
				$SyncAdded &= $SyncScanResult & "||"
				GUICtrlSetData($GUI_Wallets_Found, $SyncScanResult)
			EndIf
			If Not FileExists(@ScriptDir & "\SyncData") Then DirCreate(@ScriptDir & "\SyncData")
			If Not FileExists(@ScriptDir & "\SyncData\" & $SyncScanResult) Then DirCreate(@ScriptDir & "\SyncData\" & $SyncScanResult)
			FileCopy(@AppDataDir & "\" & $SyncScanResult & "\wallet.dat", @ScriptDir & "\SyncData\" & $SyncScanResult & "\wallet.dat", 1)
		EndIf
	EndIf
WEnd

Func SyncReset()
	GUICtrlSetData($GUI_Label2, "Sleeping...")
	FileClose($SyncScan)
	Local $SyncTimer = TimerInit()
	Do
		GUI_Events()
		Sleep(10)
	Until Round(TimerDiff($SyncTimer)/1000, 0) > 60
	Global $SyncScan = FileFindFirstFile(@AppDataDir & "\*.*")
EndFunc

Func GUI_Events()
	Switch TrayGetMsg()
		Case $GUI_Tray_Open
			GUISetState(@SW_SHOW, $GUI_Wallet_Sync)
			WinSetState($GUI_Wallet_Sync, "", @SW_RESTORE)
		Case $GUI_Tray_Exit
			CloseSync()
	EndSwitch
	Switch GUIGetMsg()
		Case $GUI_EVENT_CLOSE
			CloseSync()
		Case $GUI_EVENT_MINIMIZE
			GUISetState(@SW_Hide, $GUI_Wallet_Sync)
			TrayTip("WalletSync", "Minimized to the system tray...", 4)
		Case $GUI_File_Exit
			CloseSync()
		Case $GUI_File_Minimize
			GUISetState(@SW_Hide, $GUI_Wallet_Sync)
			TrayTip("WalletSync", "Minimized to the system tray...", 4)
		Case $GUI_Help_About
			MsgBox(0, "WalletSync", "A simple tools to sync all your crypto-currencies wallet.dat" & @CRLF & "files to a folder for backup purposes. Created by zelles")
	EndSwitch
EndFunc

Func CloseSync()
	FileClose($SyncScan)
	Exit
EndFunc
