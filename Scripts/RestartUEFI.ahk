#Requires AutoHotkey v2.0
#SingleInstance
#NoTrayIcon

if (!A_IsAdmin) {
    try Run('*RunAs ' A_ScriptFullPath), ExitApp()
    catch
        ExitApp()
}

Run('shutdown.exe /r /fw /t 0')