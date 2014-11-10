#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Icon.ico
#AutoIt3Wrapper_Res_Comment=Keep a sync'd backup of your crypto currency wallets locally and optionally with a FTP server.
#AutoIt3Wrapper_Res_Description=Keep a sync'd copy of all the crypto-currency wallet.dats found in there default locations on you PC.
#AutoIt3Wrapper_Res_Fileversion=0.0.0.2
#AutoIt3Wrapper_Res_LegalCopyright=Copyright 2014 zelles
#AutoIt3Wrapper_Res_Language=1033
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
;#NoTrayIcon
#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <EditConstants.au3>
#include <FTPEx.au3>
#include <GUIConstantsEx.au3>
#include <GUIListBox.au3>
#include <Misc.au3>
#include <StaticConstants.au3>
#include <TabConstants.au3>
#include <TrayConstants.au3>
#include <WindowsConstants.au3>

_Singleton("zellesWalletSync2")

OnAutoItExitRegister("CloseSync")

Opt("TrayMenuMode", 3)

Global $SYNC_OPERATION = False

If Not FileExists(@ScriptDir & "\WalletSync_temp") Then DirCreate(@ScriptDir & "\WalletSync_temp")
FileInstall("C:\AIP\Logo.jpg", @ScriptDir & "\WalletSync_temp\Logo.jpg")
If Not FileExists(@ScriptDir & "\config.ini") Then
	IniWriteSection(@ScriptDir & "\config.ini", "config", "speed=60")
	IniWrite(@ScriptDir & "\config.ini", "config", "ftpserver", "none")
	IniWrite(@ScriptDir & "\config.ini", "config", "ftpport", "21")
	IniWrite(@ScriptDir & "\config.ini", "config", "ftpusername", "none")
	IniWrite(@ScriptDir & "\config.ini", "config", "ftppassword", "none")
EndIf

Global $SYNC_SPEED = IniRead(@ScriptDir & "\config.ini", "config", "speed", "60")
Global $SYNC_FTPSERVER = IniRead(@ScriptDir & "\config.ini", "config", "ftpserver", "none")
Global $SYNC_FTPPORT = IniRead(@ScriptDir & "\config.ini", "config", "ftpport", "21")
Global $SYNC_FTPUSER = IniRead(@ScriptDir & "\config.ini", "config", "ftpusername", "none")
Global $SYNC_FTPPASS = IniRead(@ScriptDir & "\config.ini", "config", "ftppassword", "none")

Global $GUI_Wallet_Sync = GUICreate("WalletSync, created by zelles", 370, 189, 245, 163)
GUISetBkColor(0xFFFFFF)
Global $GUI_Tab1 = GUICtrlCreateTab(5, 5, 361, 177)
Global $GUI_TabSheet1 = GUICtrlCreateTabItem("Overview")
Global $GUI_Logo = GUICtrlCreatePic(@ScriptDir & "\WalletSync_temp\Logo.jpg", 17, 46, 100, 100)
Global $GUI_Group1 = GUICtrlCreateGroup("Sync Options", 119, 55, 233, 89)
GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
Global $GUI_CheckboxLocal = GUICtrlCreateCheckbox("Local", 135, 79, 57, 17)
GUICtrlSetState($GUI_CheckboxLocal, $GUI_CHECKED)
GUICtrlSetState($GUI_CheckboxLocal, $GUI_DISABLE)
Global $GUI_CheckboxFTP = GUICtrlCreateCheckbox("FTP", 135, 111, 57, 17)
Global $GUI_CheckboxOther1 = GUICtrlCreateCheckbox("Other", 199, 79, 57, 17)
GUICtrlSetState($GUI_CheckboxOther1, $GUI_DISABLE)
Global $GUI_CheckboxOther2 = GUICtrlCreateCheckbox("Other", 199, 111, 57, 17)
GUICtrlSetState($GUI_CheckboxOther2, $GUI_DISABLE)
Global $GUI_ButtonStart = GUICtrlCreateButton("Start", 266, 75, 75, 25)
Global $GUI_ButtonStop = GUICtrlCreateButton("Stop", 266, 107, 75, 25)
GUICtrlSetState($GUI_ButtonStop, $GUI_DISABLE)
GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $GUI_TabSheet2 = GUICtrlCreateTabItem("Status")
Global $GUI_Group6 = GUICtrlCreateGroup("Current Sync Status", 21, 65, 329, 73)
GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
Global $GUI_SyncStatus = GUICtrlCreateLabel("Sync is turned off...", 40, 96, 294, 17)
GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $GUI_TabSheet3 = GUICtrlCreateTabItem("Local")
Global $GUI_Group2 = GUICtrlCreateGroup("Local Output", 22, 64, 329, 73)
GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
Global $GUI_InputLocalOutput = GUICtrlCreateInput(@ScriptDir & "\SyncData", 35, 92, 305, 21, BitOR($GUI_SS_DEFAULT_INPUT,$ES_READONLY))
GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $GUI_TabSheet4 = GUICtrlCreateTabItem("FTP")
Global $GUI_Group5 = GUICtrlCreateGroup("FTP Settings", 21, 49, 329, 105)
GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
Global $GUI_Label2 = GUICtrlCreateLabel("Server:", 37, 73, 38, 17)
Global $GUI_Label3 = GUICtrlCreateLabel("Port:", 37, 97, 26, 17)
Global $GUI_Label1 = GUICtrlCreateLabel("Username:", 189, 73, 55, 17)
Global $GUI_Label4 = GUICtrlCreateLabel("Password:", 189, 97, 53, 17)
Global $GUI_InputFTPServer = GUICtrlCreateInput($SYNC_FTPSERVER, 79, 70, 105, 21)
Global $GUI_InputFTPPort = GUICtrlCreateInput($SYNC_FTPPORT, 79, 94, 105, 21)
Global $GUI_InputFTPUsername = GUICtrlCreateInput($SYNC_FTPUSER, 247, 70, 89, 21)
Global $GUI_InputFTPPassword = GUICtrlCreateInput($SYNC_FTPPASS, 247, 94, 89, 21, BitOR($GUI_SS_DEFAULT_INPUT,$ES_PASSWORD))
Global $GUI_ButtonFTPUpdate = GUICtrlCreateButton("Update", 264, 120, 75, 25)
GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $GUI_TabSheet6 = GUICtrlCreateTabItem("Scanner")
Global $GUI_Group4 = GUICtrlCreateGroup("Sync Scanner", 21, 33, 329, 137)
GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
Global $GUI_ComboSpeed = GUICtrlCreateCombo("1 minute", 40, 56, 209, 25, BitOR($CBS_DROPDOWN,$CBS_AUTOHSCROLL))
GUICtrlSetData($GUI_ComboSpeed, "5 minutes|10 minutes|30 minutes|1 hour", "1 minute")
Global $GUI_ButtonUpdateSpeed = GUICtrlCreateButton("Update", 256, 56, 75, 21)
Global $GUI_Wallets_Found = GUICtrlCreateList("", 120, 88, 209, 69, BitOR($LBS_NOTIFY,$LBS_SORT,$WS_VSCROLL))
Global $GUI_Label5 = GUICtrlCreateLabel("Wallets Found:", 40, 86, 75, 17)
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUICtrlCreateTabItem("")
GUISetState(@SW_SHOW, $GUI_Wallet_Sync)

Global $GUI_Tray_Open = TrayCreateItem("Open WalletSync")
TrayCreateItem("")
Global $GUI_Tray_Exit = TrayCreateItem("Exit")
TraySetState($TRAY_ICONSTATE_SHOW)

Global $SyncAdded = "||"
Global $SyncScan = FileFindFirstFile(@AppDataDir & "\*.*")
While 1
	GUI_Events()
	If $SYNC_OPERATION = False Then ContinueLoop
	Local $SyncScanResult = FileFindNextFile($SyncScan)
	If @error Then SyncReset()
	If @extended = 1 Then
		If FileExists(@AppDataDir & "\" & $SyncScanResult & "\wallet.dat") Then
			GUICtrlSetData($GUI_SyncStatus, $SyncScanResult)
			If Not StringInStr($SyncAdded, "||" & $SyncScanResult & "||") Then
				$SyncAdded &= $SyncScanResult & "||"
				GUICtrlSetData($GUI_Wallets_Found, $SyncScanResult)
			EndIf
			If GUICtrlRead($GUI_CheckboxLocal) = $GUI_CHECKED Then
				If Not FileExists(@ScriptDir & "\SyncData") Then DirCreate(@ScriptDir & "\SyncData")
				If Not FileExists(@ScriptDir & "\SyncData\" & $SyncScanResult) Then DirCreate(@ScriptDir & "\SyncData\" & $SyncScanResult)
				FileCopy(@AppDataDir & "\" & $SyncScanResult & "\wallet.dat", @ScriptDir & "\SyncData\" & $SyncScanResult & "\wallet.dat", 1)
			EndIf
		EndIf
	EndIf
WEnd

Func SyncReset()
	If $SYNC_OPERATION = True Then
		If GUICtrlRead($GUI_CheckboxFTP) = $GUI_CHECKED Then
			GUICtrlSetData($GUI_SyncStatus, "Sending to FTP server...")
			$SyncFTPOpen = _FTP_Open('FTP')
			$SyncFTPConn = _FTP_Connect($SyncFTPOpen, $SYNC_FTPSERVER, $SYNC_FTPUSER, $SYNC_FTPPASS, "1", $SYNC_FTPPORT)
			_FTP_DirPutContents($SyncFTPConn, @ScriptDir & "\SyncData", "", 1)
			_FTP_Close($SyncFTPOpen)
			_FTP_Close($SyncFTPConn)
		EndIf
		GUICtrlSetData($GUI_SyncStatus, "Sleeping...")
	EndIf
	FileClose($SyncScan)
	Local $SyncTimer = TimerInit()
	Do
		GUI_Events()
		Sleep(10)
	Until Round(TimerDiff($SyncTimer)/1000, 0) > $SYNC_SPEED
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
		Case $GUI_ButtonStart
			GUICtrlSetState($GUI_ButtonStart, $GUI_DISABLE)
			GUICtrlSetState($GUI_ButtonStop, $GUI_ENABLE)
			$SYNC_OPERATION = True
		Case $GUI_ButtonStop
			GUICtrlSetState($GUI_ButtonStop, $GUI_DISABLE)
			GUICtrlSetState($GUI_ButtonStart, $GUI_ENABLE)
			GUICtrlSetData($GUI_SyncStatus, "Sync is turned off...")
			$SYNC_OPERATION = False
		Case $GUI_ButtonUpdateSpeed
			Switch GUICtrlRead($GUI_ComboSpeed)
				Case "5 minutes"
					$SYNC_SPEED = 300
					IniDelete(@ScriptDir & "\config.ini", "config", "speed")
					IniWrite(@ScriptDir & "\config.ini", "config", "speed", $SYNC_SPEED)
					MsgBox(0, "WalletSync Response", "The speed was updated to 5 minute intervals.")
				Case "10 minutes"
					$SYNC_SPEED = 600
					IniDelete(@ScriptDir & "\config.ini", "config", "speed")
					IniWrite(@ScriptDir & "\config.ini", "config", "speed", $SYNC_SPEED)
					MsgBox(0, "WalletSync Response", "The speed was updated to 10 minute intervals.")
				Case "30 minutes"
					$SYNC_SPEED = 1800
					IniDelete(@ScriptDir & "\config.ini", "config", "speed")
					IniWrite(@ScriptDir & "\config.ini", "config", "speed", $SYNC_SPEED)
					MsgBox(0, "WalletSync Response", "The speed was updated to 30 minute intervals.")
				Case "1 hour"
					$SYNC_SPEED = 3600
					IniDelete(@ScriptDir & "\config.ini", "config", "speed")
					IniWrite(@ScriptDir & "\config.ini", "config", "speed", $SYNC_SPEED)
					MsgBox(0, "WalletSync Response", "The speed was updated to 1 hour intervals.")
				Case Else
					$SYNC_SPEED = 60
					IniDelete(@ScriptDir & "\config.ini", "config", "speed")
					IniWrite(@ScriptDir & "\config.ini", "config", "speed", $SYNC_SPEED)
					MsgBox(0, "WalletSync Response", "The speed was updated to 1 minute intervals.")
			EndSwitch
		Case $GUI_ButtonFTPUpdate
			$SYNC_FTPSERVER = GUICtrlRead($GUI_InputFTPServer)
			$SYNC_FTPPORT = GUICtrlRead($GUI_InputFTPPort)
			$SYNC_FTPUSER = GUICtrlRead($GUI_InputFTPUsername)
			$SYNC_FTPPASS = GUICtrlRead($GUI_InputFTPPassword)
			IniDelete(@ScriptDir & "\config.ini", "config", "ftpserver")
			IniDelete(@ScriptDir & "\config.ini", "config", "ftpport")
			IniDelete(@ScriptDir & "\config.ini", "config", "ftpusername")
			IniDelete(@ScriptDir & "\config.ini", "config", "ftppassword")
			IniWrite(@ScriptDir & "\config.ini", "config", "ftpserver", $SYNC_FTPSERVER)
			IniWrite(@ScriptDir & "\config.ini", "config", "ftpport", $SYNC_FTPPORT)
			IniWrite(@ScriptDir & "\config.ini", "config", "ftpusername", $SYNC_FTPUSER)
			IniWrite(@ScriptDir & "\config.ini", "config", "ftppassword", $SYNC_FTPPASS)
			MsgBox(0, "WalletSync Response", "The ftp credentials were updated.")
	EndSwitch
EndFunc

Func CloseSync()
	FileClose($SyncScan)
	If FileExists(@ScriptDir & "\WalletSync_temp") Then DirRemove(@ScriptDir & "\WalletSync_temp", 1)
	Exit
EndFunc
