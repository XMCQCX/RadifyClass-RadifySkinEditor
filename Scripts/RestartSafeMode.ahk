#Requires AutoHotkey v2.0
#SingleInstance
#NoTrayIcon

if (!A_IsAdmin) {
    try Run('*RunAs ' A_ScriptFullPath), ExitApp()
    catch
        ExitApp()
}

RunWait('bcdedit /set {current} safeboot minimal',, 'Hide')
Run('shutdown.exe /r /t 0')