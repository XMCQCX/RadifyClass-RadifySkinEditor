#Requires AutoHotkey v2.0
#SingleInstance
#NoTrayIcon

/**********************************************
 * @credits EvenAngelsNeed
 * @see {@link https://www.reddit.com/r/AutoHotkey/comments/1lsy13l/empty_recycle_bin_shortcut Reddit r/AutoHotkey}
 */
GetRecycleBinCount() {
    shell := ComObject('shell.application')
    bin := shell.Namespace(10)
    return bin.Items().Count
}

if (GetRecycleBinCount() = 0)
    ExitApp()

DllCall('shell32.dll\SHEmptyRecycleBin', 'Ptr', 0, 'Ptr', 0, 'UInt', 0)