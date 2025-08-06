#Requires AutoHotkey v2.0
#SingleInstance

#Include Radify.ahk
#Include .\Lib\Gdip_All.ahk

/*********************************************************************************************
 * @file Radify Menus.ahk
 * @version 1.0.0
 * @date 2025-08-05
 * @see {@link https://github.com/XMCQCX/RadifyClass-RadifySkinEditor GitHub}
 * @see {@link https://www.autohotkey.com/boards/viewtopic.php?f=83&t=138484 AHK Forum}
 ********************************************************************************************/

TraySetIcon('images\radify0.ico',, true)

if (!pToken := Gdip_Startup())
    MsgBox('GDI+ failed to start. Please ensure you have GDI+ on your system.',, 'Iconx'), ExitApp()

OnExit((*) => (Radify.DisposeResources(), Gdip_Shutdown(pToken)))

;==============================================

; Set your preferred hotkey, hotstring, mouse gesture, or other trigger to open the main menu.
MButton::Radify.Show('mainMenu')

HotIfWinExist('RadifyGui_0_0 ahk_class AutoHotkeyGUI')
Hotkey('Esc', (*) => WinClose(WinExist()))
HotIfWinExist()

;==============================================

; Configure which menu opens for each tray-click action.
trayClickActions := {
    click: 'mainMenu',
    doubleClick: 'appsMenu',
    ctrlClick: 'websitesMenu',
    shiftClick: 'aiMenu',
    altClick: 'systemPowerMenu',
}

;==============================================

websitesMenu := [
    [   ; ring 1
        {image: 'google-chrome.png', click: (*) => Run('https://www.google.com'), tooltip: 'Google Search'},
        {image: 'gmail.png', click: (*) => Run('https://mail.google.com')},
        {image: 'microsoft-outlook.png', click: (*) => Run('https://outlook.live.com/mail')},
        {image: 'x-twitter.png', click: (*) => Run('https://twitter.com')},
        {image: 'youtube.png', click: (*) => Run('https://www.youtube.com/feed/subscriptions')},
        {image: 'facebook.png', click: (*) => Run('https://www.facebook.com')},
    ],
    [   ; ring 2
        {image: 'google-drive.png', click: (*) => Run('https://drive.google.com')},
        {image: 'google-keep.png', click: (*) => Run('https://keep.google.com')},
        {image: 'google-photos.png', click: (*) => Run('https://photos.google.com')},
        {image: 'reddit.png', click: (*) => Run('https://www.reddit.com')},
        {image: 'odysee.png', click: (*) => Run('https://odysee.com')},
        {image: 'rumble.png', click: (*) => Run('https://rumble.com')},
        {image: 'bitchute.png', click: (*) => Run('https://www.bitchute.com')},
        {image: 'vimeo.png', click: (*) => Run('https://vimeo.com')},
        {image: 'twitch.png', click: (*) => Run('https://www.twitch.tv')},
        {image: 'spotify.png', click: (*) => Run('https://open.spotify.com')},
        {image: 'duckduckgo.png', click: (*) => Run('https://duckduckgo.com')},
        {image: 'dropbox.png', click: (*) => Run('https://www.dropbox.com')},
    ],
    [   ; ring 3
        {image: 'google-maps.png', click: (*) => Run('https://www.google.com/maps')},
        {image: 'google-calendar.png', click: (*) => Run('https://calendar.google.com')},
        {image: 'google-translate.png', click: (*) => Run('https://translate.google.com')},
        {image: 'google-spreadsheets.png', click: (*) => Run('https://docs.google.com/spreadsheets')},
        {image: 'google-documents.png', click: (*) => Run('https://docs.google.com/document')},
        {image: 'instagram.png', click: (*) => Run('https://www.instagram.com')},
        {image: 'tiktok.png', click: (*) => Run('https://www.tiktok.com')},
        {image: 'telegram.png', click: (*) => Run('https://web.telegram.org')},
        {image: 'whatsapp.png', click: (*) => Run('https://web.whatsapp.com')},
        {image: 'messenger.png', click: (*) => Run('https://www.messenger.com')},
        {image: 'discord.png', click: (*) => Run('https://discord.com')},
        {image: 'zoom.png', click: (*) => Run('https://zoom.us')},
        {image: 'skype.png', click: (*) => Run('https://web.skype.com')},
        {image: 'linkedin.png', click: (*) => Run('https://www.linkedin.com')},
        {image: 'paypal.png', click: (*) => Run('https://www.paypal.com')},
        {image: 'stripe.png', click: (*) => Run('https://dashboard.stripe.com')},
        {
            image: 'reddit.png',
            click: (*) => Run('https://www.reddit.com/r/AutoHotkey'),
            text: 'r/AHK',
            tooltip: 'r/AutoHotkey',
            itemImageScale: 0.35,
            itemImageYRatio: 0.25,
            textYRatio: 0.75,
        },
        {
            image: 'autohotkey.png',
            click: (*) => Run('https://www.autohotkey.com/boards'),
            text: 'Forum',
            tooltip: 'AutoHotkey Forum',
            itemImageScale: 0.35,
            itemImageYRatio: 0.25,
            textYRatio: 0.75,
        },
        {
            image: 'autohotkey.png',
            click: (*) => Run('https://www.autohotkey.com/docs/v2'),
            text: 'Doc',
            tooltip: 'AutoHotkey Documentation',
            itemImageScale: 0.35,
            itemImageYRatio: 0.25,
            textYRatio: 0.75,
        },
    ],
]

websitesMenuOptions := {mirrorClickToRightClick: true, closeOnItemRightClick: false}

Radify.CreateMenu('websitesMenu', websitesMenu, websitesMenuOptions)

;==============================================

aiMenu := [
    [
        {image: 'grok.png', click: (*) => Run('https://x.com/i/grok')},
        {image: 'claude.png', click: (*) => Run('https://claude.ai')},
        {image: 'chatgpt.png', click: (*) => Run('https://chatgpt.com')},
        {image: 'gemini.png', click: (*) => Run('https://gemini.google.com')},
        {image: 'deepseek.png', click: (*) => Run('https://chat.deepseek.com')},
        {image: 'perplexity.png', click: (*) => Run('https://www.perplexity.ai')},
    ],
    [
        {image: 'mistral.png', click: (*) => Run('https://chat.mistral.ai')},
        {image: 'microsoft-copilot.png', click: (*) => Run('https://copilot.microsoft.com')},
        {image: 'bing.png', click: (*) => Run('https://www.bing.com/images/create'), tooltip: 'Bing Image Creator'},
        {image: 'openrouter.png', click: (*) => Run('https://openrouter.ai')},
        {image: 'huggingface.png', click: (*) => Run('https://huggingface.co/chat')},
        {image: 'poe.png', click: (*) => Run('https://poe.com')},
        {image: 'character-ai.png', click: (*) => Run('https://character.ai')},
        {image: 'suno.png', click: (*) => Run('https://suno.com'), tooltip: 'Suno - AI Music'},
        {image: 'playground.png', click: (*) => Run('https://playground.com')},
        {image: 'midjourney.png', click: (*) => Run('https://midjourney.com')},
        {image: 'stable-diffusion.png', click: (*) => Run('https://stability.ai')},
        {image: 'leonardo.png', click: (*) => Run('https://leonardo.ai')},
    ],
]

aiMenuOptions := {mirrorClickToRightClick: true, closeOnItemRightClick: false}

Radify.CreateMenu('aiMenu', aiMenu, aiMenuOptions)

;==============================================

shoppingMenu := [
    [
        {text: 'Amazon', click: (*) => Run('https://www.amazon.com')},
        {text: 'Ebay', click: (*) => Run('https://www.ebay.com')},
        {text: 'Bestbuy', click: (*) => Run('https://www.bestbuy.com')},
        {text: 'Costco', click: (*) => Run('https://www.costco.com')},
        {text: 'Walmart', click: (*) => Run('https://www.walmart.com')},
        {text: 'Target', click: (*) => Run('https://www.target.com')},
    ],
    [
        {text: 'Newegg', click: (*) => Run('https://www.newegg.com')},
        {text: 'Staples', click: (*) => Run('https://www.staples.com')},
        {text: 'Ali`nExpress', click: (*) => Run('https://www.aliexpress.com')},
        {text: 'Home Depot', click: (*) => Run('https://www.homedepot.com')},
        {text: 'Lowes', click: (*) => Run('https://www.lowes.com')},
        {text: 'IKEA', click: (*) => Run('https://www.ikea.com')},
        {text: 'Wayfair', click: (*) => Run('https://www.wayfair.com')},
        {text: 'Etsy', click: (*) => Run('https://www.etsy.com')},
        {text: 'Macys', click: (*) => Run('https://www.macys.com')},
        {text: 'Under`nArmour', click: (*) => Run('https://www.underarmour.com')},
        {text: 'Nike', click: (*) => Run('https://www.nike.com')},
        {text: 'Adidas', click: (*) => Run('https://www.adidas.com')},
        {text: 'Zara', click: (*) => Run('https://www.zara.com')},
    ],
]

shoppingMenuOptions := {mirrorClickToRightClick: true, closeOnItemRightClick: false}

;==============================================

appsMenu := [
    [
        {image: 'calculator.png', click: (*) => Run('calc.exe')},
        {image: 'notepad.png', click: (*) => Run('notepad.exe')},
        {image: 'wordpad.png', click: (*) => Run('wordpad.exe')},
        {image: 'paint.png', click: (*) => Run('mspaint.exe')},
        {image: 'osk.png', click: (*) => Run('osk.exe'), tooltip: 'On-Screen Keyboard'},
    ],
]

Radify.CreateMenu('appsMenu', appsMenu)

;==============================================

foldersMenu  := [
    [
        {image: 'downloads.png', click: (*) => Run(GetFolderPath('downloads'))},
        {image: 'documents.png', click: (*) => Run(A_MyDocuments)},
        {image: 'music.png', click: (*) => Run(GetFolderPath('music'))},
        {image: 'pictures.png', click: (*) => Run(GetFolderPath('pictures'))},
        {image: 'videos.png', click: (*) => Run(GetFolderPath('videos'))},
        {image: 'desktop.png', click: (*) => Run(A_Desktop)},
    ],
    [
        {image: 'recent.png', click: (*) => Run(GetFolderPath('recent'))},
        {image: 'favorites.png', click: (*) => Run('shell:::{323CA680-C24D-4099-B94D-446DD2D7249E}')},
        {image: 'this-pc.png', click: (*) => Run('shell:::{20D04FE0-3AEA-1069-A2D8-08002B30309D}')},
        {text: 'AppData', click: (*) => Run(A_AppData), tooltip: 'AppData > Roaming'},
        {text: 'Programs', click: (*) => Run(A_Programs), tooltip: 'Start Menu > Programs'},
        {text: 'Startup', click: (*) => Run(A_Startup), tooltip: 'Start Menu > Programs > Startup'},
        {},
        {},
        {},
        {},
        {},
        {},
    ],
]

Radify.CreateMenu('foldersMenu', foldersMenu)

;==============================================

settingsMenu := [
	[
        {image: 'bluetooth-settings-app.png', click: (*) => Run('ms-settings:bluetooth')},
        {image: 'system-display-settings-app.png', click: (*) => Run('ms-settings:display')},
        {image: 'sound-settings-app.png', click: (*) => Run('ms-settings:sound')},
        {image: 'sound-control-panel.png', click: (*) => Run('mmsys.cpl')},
        {image: 'devices-printers-settings-app.png', click: (*) => Run('control printers')},
        {image: 'devices-printers-control-panel.png', click: (*) => Run('shell:::{A8A91A66-3A7D-4424-8D24-04E180695C7A}')},
    ],
    [
        {image: 'power-options-settings-app.png', click: (*) => Run('ms-settings:powersleep')},
        {image: 'power-options-control-panel.png', click: (*) => Run('powercfg.cpl')},
        {image: 'installedApps-settings-app.png', click: (*) => Run('ms-settings:appsfeatures')},
        {image: 'programs-features-control-panel.png', click: (*) => Run('appwiz.cpl')},
        {image: 'system.png', click: (*) => Run('SystemPropertiesAdvanced.exe'), tooltip: 'System Properties > Advanced'},
		{image: 'network-connections.png', click: (*) => Run('shell:::{7007ACC7-3202-11D1-AAD2-00805FC1270E}')},
        {image: 'windows-defender.png', click: (*) => Run('explorer.exe windowsdefender:')},
        {image: 'folder-options.png', click: (*) => Run('shell:::{6DFD7C5C-2451-11d3-A299-00C04F8EF6AF}')},
        {image: 'control-panel.png', click: (*) => Run('shell:::{26EE0668-A00A-44D7-9371-BEB064C98683}'), tooltip: 'Control Panel'},
        {image: 'control-panel.png', click: (*) => Run('shell:::{ED7BA470-8E54-465E-825C-99712043E01C}'), tooltip: 'All Tasks'},
	],
]

Radify.CreateMenu('settingsMenu', settingsMenu)

;==============================================

toolsMenu := [
	[
        {image: 'device-manager.png', click: (*) => Run('devmgmt.msc')},
		{image: 'disk-management.png', click: (*) => Run('diskmgmt.msc')},
		{image: 'computer-management.png', click: (*) => Run('mmc.exe compmgmt.msc')},
		{image: 'system-configuration.png', click: (*) => Run('msconfig.exe')},
        {image: 'system-information.png', click: (*) => Run('msinfo32.exe')},
		{image: 'task-scheduler.png', click: (*) => Run('mmc.exe taskschd.msc')},
	],
	[
        {image: 'windows-tools.png', click: (*) => Run('shell:::{D20EA4E1-3957-11D2-A40B-0C5020524153}')},
		{image: 'services.png', click: (*) => Run('services.msc')},
		{image: 'registry-editor.png', click: (*) => Run('regedit.exe')},
		{image: 'optimize-drives.png', click: (*) => Run('dfrgui.exe')},
        {image: 'system-image.png', click: (*) => Run('sdclt.exe /BLBBACKUPWIZARD')},
        {image: 'event-viewer.png', click: (*) => Run('eventvwr.msc')},
        {image: 'windows-firewall.png', click: (*) => Run('WF.msc')},
        {
            image: 'monitor.png',
            click: (*) => Run('resmon.exe'),
            text: 'Resmon',
            tooltip: 'Resource Monitor',
            itemImageScale: 0.35,
            itemImageYRatio: 0.25,
            textYRatio: 0.75,
        },
        {
            image: 'monitor.png',
            click: (*) => Run('perfmon.exe'),
            text: 'Perfmon',
            tooltip: 'Performance Monitor',
            itemImageScale: 0.35,
            itemImageYRatio: 0.25,
            textYRatio: 0.75,
        },
	],
]

;==============================================

powerPlansMenu := [
    [
        {text: 'High', click: (*) => Run('powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c',, 'Hide'), tooltip: 'High Performance'},
        {text: 'Balanced', click: (*) => Run('powercfg -setactive 381b4222-f694-41f0-9685-ff5bb260df2e',, 'Hide'), tooltip: 'Balanced'},
        {text: 'Saver', click: (*) => Run('powercfg -setactive a1841308-3541-4fab-bc81-f71556f20b4a',, 'Hide'), tooltip: 'Power Saver'},
        {},
        {},
    ],
]

;==============================================

scriptsMenu := [
    [
        {text: 'Script 1'},
        {text: 'Script 2'},
        {text: 'Script 3'},
        {text: 'Script 4'},
        {text: 'Script 5'},
        {text: 'Script 6'},
    ],
]

;==============================================

systemCleanupMenu := [
	[
        {
            image: 'recycle-bin.png',
            rightClick: (*) => Run('Scripts\EmptyRecycleBin.ahk'),
            click: (*) => Run('shell:::{645FF040-5081-101B-9F08-00AA002F954E}'),
            tooltip: 'Click: Open Recycle Bin`nRight-Click: Empty Recycle Bin',
        },
        {image: 'disk-cleanup.png', click: (*) => Run('cleanmgr.exe')},
        {text: 'Win Temp', click: (*) => Run(A_WinDir '\Temp'), tooltip: 'Windows system Temp folder'},
        {text: 'Temp', click: (*) => Run(A_Temp), tooltip: 'User temporary files folder'},
        {text: 'Prefetch', click: (*) => Run(A_WinDir '\Prefetch'), tooltip: 'Prefetch folder'},
        {text: 'Software Distribution', click: (*) => Run(A_WinDir '\SoftwareDistribution\Download'), tooltip: 'Windows Update cache folder', textSize:9},
        {text: 'Storage Sense', click: (*) => Run('ms-settings:storagesense')},
	],
]

;==============================================

strSystemPower :=  ' - Right-Click: Execute action.`nMake sure to save your work before proceeding.'

systemPowerMenu := [
	[
        {image: 'shutdown.png', rightClick: (*) => (Sleep(1500), Shutdown(8)), tooltip: 'Shutdown' strSystemPower},
        {image: 'restart.png', rightClick: (*) => (Sleep(1500), Shutdown(2)), tooltip: 'Restart' strSystemPower},
        {image: 'sleep.png', rightClick: (*) => (Sleep(1500), DllCall('PowrProf\SetSuspendState', 'int', 0, 'int', 0, 'int', 0)), tooltip: 'Sleep' strSystemPower},
        {image: 'advanced-startup.png', rightClick: (*) => (Sleep(1500), Run('shutdown.exe /r /o /t 0')), tooltip: 'Advanced Startup' strSystemPower},
        {image: 'restart-safe-mode.png', rightClick: (*) => (Sleep(1500), Run('Scripts\RestartSafeMode.ahk')), tooltip: 'Restart to Safe Mode' strSystemPower},
	],
]

systemPowerMenuOptions := {closeOnItemClick: false}

Radify.CreateMenu('systemPowerMenu', systemPowerMenu, systemPowerMenuOptions)

;==============================================

symbolMenu := [
    [
        {text: Chr(123) Chr(125), click: (*) => ClipSend(Chr(123) Chr(125)), tooltip: 'Curly brackets'}, ; {}
        {text: Chr(125), click: (*) => ClipSend(Chr(125)), tooltip: 'Closing curly bracket'}, ; }
        {text: Chr(93), click: (*) => ClipSend(Chr(93)), tooltip: 'Closing square bracket'}, ; ]
        {text: Chr(91) Chr(93), click: (*) => ClipSend(Chr(91) Chr(93)), tooltip: 'Square brackets'}, ; []
        {text: Chr(91), click: (*) => ClipSend(Chr(91)), tooltip: 'Opening square bracket'}, ; [
        {text: Chr(123), click: (*) => ClipSend(Chr(123)), tooltip: 'Opening curly bracket'}, ; {
    ],
    [
        {text: Chr(40) Chr(41), click: (*) => ClipSend(Chr(40) Chr(41)), tooltip: 'Parentheses'}, ; ()
        {text: Chr(41), click: (*) => ClipSend(Chr(41)), tooltip: 'Closing parenthesis'}, ; )
        {text: Chr(37), click: (*) => ClipSend(Chr(37)), tooltip: 'Percent sign'}, ; %
        {text: Chr(37) Chr(37), click: (*) => ClipSend(Chr(37) Chr(37)), textSize: 20, tooltip: 'Double percent sign'}, ; %%
        {text: Chr(47), click: (*) => ClipSend(Chr(47)), tooltip: 'Forward slash'}, ; /
        {text: Chr(62), click: (*) => ClipSend(Chr(62)), tooltip: 'Greater-than sign'}, ; >
        {text: Chr(60) Chr(62), click: (*) => ClipSend(Chr(60) Chr(62)), tooltip: 'Angle brackets', textSize: 30}, ; <>
        {text: Chr(60), click: (*) => ClipSend(Chr(60)), tooltip: 'Less-than sign'}, ; <
        {text: Chr(92), click: (*) => ClipSend(Chr(92)), tooltip: 'Backslash'}, ; \
        {text: Chr(8220) Chr(8221), click: (*) => ClipSend(Chr(8220) Chr(8221)), tooltip: 'Double quotation marks'}, ; ""
        {text: Chr(8216) Chr(8217), click: (*) => ClipSend(Chr(8216) Chr(8217)), tooltip: 'Single quotation marks'}, ; ''
        {text: Chr(40), click: (*) => ClipSend(Chr(40)), tooltip: 'Opening parenthesis'}, ; (
    ],
    [
        ; — Common Symbols —
        {text: Chr(35), click: (*) => ClipSend(Chr(35)), tooltip: 'Hash sign'}, ; #
        {text: Chr(38), click: (*) => ClipSend(Chr(38)), tooltip: 'Ampersand'}, ; &
        {text: Chr(64), click: (*) => ClipSend(Chr(64)), tooltip: 'At symbol'}, ; @
        {text: Chr(176), click: (*) => ClipSend(Chr(176)), tooltip: 'Degree symbol'}, ; °

        ; — Math & Logic Symbols —
        {text: Chr(8734), click: (*) => ClipSend(Chr(8734)), tooltip: 'Infinity symbol'}, ; ∞
        {text: Chr(8730), click: (*) => ClipSend(Chr(8730)), tooltip: 'Square root'}, ; √
        {text: Chr(177), click: (*) => ClipSend(Chr(177)), tooltip: 'Plus-minus sign'}, ; ±
        {text: Chr(8709), click: (*) => ClipSend(Chr(8709)), tooltip: 'Empty set'}, ; ∅
        {text: Chr(8800), click: (*) => ClipSend(Chr(8800)), tooltip: 'Not equal to'}, ; ≠
        {text: Chr(8805), click: (*) => ClipSend(Chr(8805)), tooltip: 'Greater than or equal to'}, ; ≥
        {text: Chr(8804), click: (*) => ClipSend(Chr(8804)), tooltip: 'Less than or equal to'}, ; ≤
        {text: Chr(8658), click: (*) => ClipSend(Chr(8658)), tooltip: 'Implies'}, ; ⇒

        {text: Chr(126), click: (*) => ClipSend(Chr(126)), tooltip: 'Tilde'}, ; ~
        {text: Chr(124), click: (*) => ClipSend(Chr(124)), tooltip: 'Pipe'}, ; |
        {text: Chr(94), click: (*) => ClipSend(Chr(94)), tooltip: 'Caret'}, ; ^
        {text: '=' Chr(62), click: (*) => ClipSend('=' Chr(62)), tooltip: 'Fat arrow', textSize: 30}, ; =>
        {text: Chr(96), click: (*) => ClipSend(Chr(96)), tooltip: 'Backtick'}, ; `
        {text: '``n', click: (*) => ClipSend('``n'), tooltip: 'Line feed'}, ; `n
        {text: '``r', click: (*) => ClipSend('``r'), tooltip: 'Carriage return'}, ; `r
    ],
    [
        {text: Chr(8801), click: (*) => ClipSend(Chr(8801)), tooltip: 'Identical to'}, ; ≡
        {text: Chr(8776), click: (*) => ClipSend(Chr(8776)), tooltip: 'Approximately equal to'}, ; ≈
        {text: Chr(181), click: (*) => ClipSend(Chr(181)), tooltip: 'Micro symbol'}, ; µ
        {text: Chr(188), click: (*) => ClipSend(Chr(188)), tooltip: 'One quarter'}, ; ¼
        {text: Chr(8531), click: (*) => ClipSend(Chr(8531)), tooltip: 'One third'}, ; ⅓
        {text: Chr(189), click: (*) => ClipSend(Chr(189)), tooltip: 'One half'}, ; ½
        {text: Chr(8532), click: (*) => ClipSend(Chr(8532)), tooltip: 'Two thirds'}, ; ⅔
        {text: Chr(190), click: (*) => ClipSend(Chr(190)), tooltip: 'Three quarters'}, ; ¾

        ; — Currency Symbols —
        {text: Chr(8364), click: (*) => ClipSend(Chr(8364)), tooltip: 'Euro symbol'}, ; €
        {text: Chr(163), click: (*) => ClipSend(Chr(163)), tooltip: 'Pound symbol'}, ; £
        {text: Chr(165), click: (*) => ClipSend(Chr(165)), tooltip: 'Yen symbol'}, ; ¥
        {text: Chr(8383), click: (*) => ClipSend(Chr(8383)), tooltip: 'Bitcoin symbol'}, ; ₿
        {text: Chr(162), click: (*) => ClipSend(Chr(162)), tooltip: 'Cent symbol'}, ; ¢

        ; — Arrows & Directional —
        {text: Chr(8592), click: (*) => ClipSend(Chr(8592)), tooltip: 'Left arrow'}, ; ←
        {text: Chr(8594), click: (*) => ClipSend(Chr(8594)), tooltip: 'Right arrow'}, ; →
        {text: Chr(8593), click: (*) => ClipSend(Chr(8593)), tooltip: 'Up arrow'}, ; ↑
        {text: Chr(8595), click: (*) => ClipSend(Chr(8595)), tooltip: 'Down arrow'}, ; ↓
        {text: Chr(8596), click: (*) => ClipSend(Chr(8596)), tooltip: 'Left-right arrow'}, ; ↔
        {text: Chr(8597), click: (*) => ClipSend(Chr(8597)), tooltip: 'Up-down arrow'}, ; ↕
        {text: Chr(8656), click: (*) => ClipSend(Chr(8656)), tooltip: 'Left double arrow'}, ; ⇐
        {text: Chr(9650), click: (*) => ClipSend(Chr(9650)), tooltip: 'Up triangle'}, ; ▲
        {text: Chr(9660), click: (*) => ClipSend(Chr(9660)), tooltip: 'Down triangle'}, ; ▼

        ; — Legal & Trademark —
        {text: Chr(169), click: (*) => ClipSend(Chr(169)), tooltip: 'Copyright symbol'}, ; ©
        {text: Chr(174), click: (*) => ClipSend(Chr(174)), tooltip: 'Registered trademark'}, ; ®
        {text: Chr(8482), click: (*) => ClipSend(Chr(8482)), tooltip: 'Trademark symbol'}, ; ™
    ],
]

symbolMenuOptions := {mirrorClickToRightClick: true, closeOnItemRightClick: false, textSize:33, itemSize: 60}

;==============================================

emojisMenu := [
    [
        {image: 'emoji_face_with_tears_of_joy.png', click: (*) => ClipSend('😂'), tooltip: 'Face with tears of joy'},
        {image: 'emoji_rolling_on_the_floor_laughing.png', click: (*) => ClipSend('🤣'), tooltip: 'Rolling on the floor laughing'},
        {image: 'emoji_loudly_crying_face.png', click: (*) => ClipSend('😭'), tooltip: 'Loudly crying face'},
        {image: 'emoji_grinning_face_with_sweat.png', click: (*) => ClipSend('😅'), tooltip: 'Grinning face with sweat'},
        {image: 'emoji_winking_face.png', click: (*) => ClipSend('😉'), tooltip: 'Winking face'},
        {image: 'emoji_winking_face_with_tongue.png', click: (*) => ClipSend('😜'), tooltip: 'Winking face with tongue'},
    ],
    [
        {image: 'emoji_grinning_face.png', click: (*) => ClipSend('😀'), tooltip: 'Grinning face'},
        {image: 'emoji_beaming_face_with_smiling_eyes.png', click: (*) => ClipSend('😁'), tooltip: 'Beaming face with smiling eyes'},
        {image: 'emoji_smiling_face_with_smiling_eyes.png', click: (*) => ClipSend('😊'), tooltip: 'Smiling face with smiling eyes'},
        {image: 'emoji_smiling_face_with_sunglasses.png', click: (*) => ClipSend('😎'), tooltip: 'Smiling face with sunglasses'},
        {image: 'emoji_smirking_face.png', click: (*) => ClipSend('😏'), tooltip: 'Smirking face'},
        {image: 'emoji_crying_face.png', click: (*) => ClipSend('😢'), tooltip: 'Crying face'},
        {image: 'emoji_pleading_face.png', click: (*) => ClipSend('🥺'), tooltip: 'Pleading face'},
        {image: 'emoji_face_with_rolling_eyes.png', click: (*) => ClipSend('🙄'), tooltip: 'Face with rolling eyes'},
        {image: 'emoji_unamused_face.png', click: (*) => ClipSend('😒'), tooltip: 'Unamused face'},
        {image: 'emoji_pensive_face.png', click: (*) => ClipSend('😔'), tooltip: 'Pensive face'},
        {image: 'emoji_smiling_face_with_hearts.png', click: (*) => ClipSend('🥰'), tooltip: 'Smiling face with hearts'},
        {image: 'emoji_smiling_face_with_heart_eyes.png', click: (*) => ClipSend('😍'), tooltip: 'Smiling face with heart-eyes'},
        {image: 'emoji_face_blowing_a_kiss.png', click: (*) => ClipSend('😘'), tooltip: 'Face blowing a kiss'},
    ],
    [
        {image: 'emoji_angry_face.png', click: (*) => ClipSend('😠'), tooltip: 'Angry face'},
        {image: 'emoji_pouting_face.png', click: (*) => ClipSend('😡'), tooltip: 'Pouting face'},
        {image: 'emoji_face_with_steam_from_nose.png', click: (*) => ClipSend('😤'), tooltip: 'Face with steam from nose'},
        {image: 'emoji_exploding_head.png', click: (*) => ClipSend('🤯'), tooltip: 'Exploding head'},
        {image: 'emoji_face_with_open_mouth.png', click: (*) => ClipSend('😮'), tooltip: 'Face with open mouth'},
        {image: 'emoji_sleeping_face.png', click: (*) => ClipSend('😴'), tooltip: 'Sleeping face'},
        {image: 'emoji_thinking_face.png', click: (*) => ClipSend('🤔'), tooltip: 'Thinking face'},
        {image: 'emoji_shushing_face.png', click: (*) => ClipSend('🤫'), tooltip: 'Shushing face'},
        {image: 'emoji_thumbs_up.png', click: (*) => ClipSend('👍'), tooltip: 'Thumbs up'},
        {image: 'emoji_thumbs_down.png', click: (*) => ClipSend('👎'), tooltip: 'Thumbs down'},
        {image: 'emoji_ok_hand.png', click: (*) => ClipSend('👌'), tooltip: 'OK hand'},
        {image: 'emoji_victory_hand.png', click: (*) => ClipSend('✌️'), tooltip: 'Victory hand'},
        {image: 'emoji_raised_hand.png', click: (*) => ClipSend('✋'), tooltip: 'Raised hand'},
        {image: 'emoji_clapping_hands.png', click: (*) => ClipSend('👏'), tooltip: 'Clapping hands'},
        {image: 'emoji_waving_hand.png', click: (*) => ClipSend('👋'), tooltip: 'Waving hand'},
        {image: 'emoji_heart_hands.png', click: (*) => ClipSend('🫶'), tooltip: 'Heart hands'},
        {image: 'emoji_flexed_biceps.png', click: (*) => ClipSend('💪'), tooltip: 'Flexed biceps'},
        {image: 'emoji_folded_hands.png', click: (*) => ClipSend('🙏'), tooltip: 'Folded hands'},
        {image: 'emoji_man_shrugging.png', click: (*) => ClipSend('🤷‍♂️'), tooltip: 'Man shrugging'},
        {image: 'emoji_eyes.png', click: (*) => ClipSend('👀'), tooltip: 'Eyes'},
    ],
    [
        {image: 'emoji_hundred_points.png', click: (*) => ClipSend('💯'), tooltip: 'Hundred points'},
        {image: 'emoji_red_heart.png', click: (*) => ClipSend('❤️'), tooltip: 'Red heart'},
        {image: 'emoji_two_hearts.png', click: (*) => ClipSend('💕'), tooltip: 'Two hearts'},
        {image: 'emoji_fire.png', click: (*) => ClipSend('🔥'), tooltip: 'Fire'},
        {image: 'emoji_high_voltage.png', click: (*) => ClipSend('⚡'), tooltip: 'High voltage'},
        {image: 'emoji_dog_face.png', click: (*) => ClipSend('🐶'), tooltip: 'Dog face'},
        {image: 'emoji_cat_face.png', click: (*) => ClipSend('🐱'), tooltip: 'Cat face'},
        {image: 'emoji_clown_face.png', click: (*) => ClipSend('🤡'), tooltip: 'Clown face'},
        {image: 'emoji_robot.png', click: (*) => ClipSend('🤖'), tooltip: 'Robot face'},
        {image: 'emoji_panda.png', click: (*) => ClipSend('🐼'), tooltip: 'Panda face'},
        {image: 'emoji_alien.png', click: (*) => ClipSend('👽'), tooltip: 'Alien'},
        {image: 'emoji_skull.png', click: (*) => ClipSend('💀'), tooltip: 'Skull'},
        {image: 'emoji_pile_of_poo.png', click: (*) => ClipSend('💩'), tooltip: 'Pile of poo'},
        {image: 'emoji_bullseye.png', click: (*) => ClipSend('🎯'), tooltip: 'Bullseye'},
        {image: 'emoji_popcorn.png', click: (*) => ClipSend('🍿'), tooltip: 'Popcorn'},
        {image: 'emoji_party_popper.png', click: (*) => ClipSend('🎉'), tooltip: 'Party popper'},
        {image: 'emoji_balloon.png', click: (*) => ClipSend('🎈'), tooltip: 'Balloon'},
        {image: 'emoji_collision.png', click: (*) => ClipSend('💥'), tooltip: 'Collision'},
        {image: 'emoji_rocket.png', click: (*) => ClipSend('🚀'), tooltip: 'Rocket'},
        {image: 'emoji_stop_sign.png', click: (*) => ClipSend('🛑'), tooltip: 'Stop sign'},
        {image: 'emoji_brain.png', click: (*) => ClipSend('🧠'), tooltip: 'Brain'},
        {image: 'emoji_hamburger.png', click: (*) => ClipSend('🍔'), tooltip: 'Hamburger'},
        {image: 'emoji_pizza.png', click: (*) => ClipSend('🍕'), tooltip: 'Pizza'},
        {image: 'emoji_check_mark_button.png', click: (*) => ClipSend('✅'), tooltip: 'Check mark'},
        {image: 'emoji_light_bulb.png', click: (*) => ClipSend('💡'), tooltip: 'Light bulb'},
        {image: 'emoji_sparkles.png', click: (*) => ClipSend('✨'), tooltip: 'Sparkles'},
        {image: 'emoji_glowing_star.png', click: (*) => ClipSend('🌟'), tooltip: 'Glowing star'},
    ],
]

emojisMenuOptions := {mirrorClickToRightClick: true, closeOnItemRightClick: false, itemSize: 60}

;==============================================

Radify.CreateMenu('mainMenu', [
    [   ; ring 1
        {
            image: 'apps-settings-app.png',
            text: 'Apps',
            tooltip: '• Applications •`nRight-Click: Open Settings > Installed apps',
            rightClick: (*) => Run('ms-settings:appsfeatures'),
            itemImageScale: 0.30,
            itemImageYRatio: 0.40,
            textYRatio: 0.75,
            submenu: appsMenu,
        },
        {
            image: 'folder.png',
            text: 'Folders',
            tooltip: '• Folders •`nRight-Click: Open This PC',
            rightClick: (*) => Run('shell:::{20D04FE0-3AEA-1069-A2D8-08002B30309D}'), ; This PC
            itemImageScale: 0.30,
            itemImageYRatio: 0.40,
            textYRatio: 0.75,
            submenu: foldersMenu,
        },
        {
            image: 'google-chrome.png',
            text: 'Websites',
            itemImageScale: 0.30,
            itemImageYRatio: 0.40,
            textYRatio: 0.75,
            submenu: websitesMenu,
            submenuOptions: websitesMenuOptions,
        },
        {
            image: 'ahk-v2.png',
            text: 'Scripts',
            itemImageScale: 0.30,
            itemImageYRatio: 0.40,
            textYRatio: 0.75,
            submenu: scriptsMenu,
        },
        {
            image: 'at-sign.png',
            text: 'Symbols',
            tooltip: 'Symbol picker',
            itemImageScale: 0.30,
            itemImageYRatio: 0.40,
            textYRatio: 0.75,
            submenu: symbolMenu,
            submenuOptions: symbolMenuOptions,
        },
        {
            image: 'emoji_grinning_face.png',
            submenu: emojisMenu,
            text: 'Emojis',
            tooltip: 'Emoji picker',
            itemImageScale: 0.30,
            itemImageYRatio: 0.40,
            textYRatio: 0.75,
            submenuOptions: emojisMenuOptions,
        },
    ],
    [   ; ring 2
        {image: 'calculator.png', click: (*) => Run('calc.exe')},
        {image: 'notepad.png', click: (*) => Run('notepad.exe')},
        {image: 'downloads.png', click: (*) => Run(GetFolderPath('downloads'))},
        {image: 'documents.png', click: (*) => Run(A_MyDocuments)},
        {
            image: 'emoji_robot.png',
            text: 'AI',
            itemImageScale: 0.30,
            itemImageYRatio: 0.40,
            textYRatio: 0.78,
            submenu: aiMenu,
            submenuOptions: aiMenuOptions,
        },
        {
            image: 'shopping.png',
            text: 'Shopping',
            itemImageScale: 0.30,
            itemImageYRatio: 0.40,
            textYRatio: 0.75,
            submenu: shoppingMenu,
            submenuOptions: shoppingMenuOptions,
        },
        {
            image: 'lightning.png',
            text: 'Power',
            tooltip: '• System power options •`nShutdown, Restart, Sleep, etc.',
            itemImageScale: 0.30,
            itemImageYRatio: 0.40,
            textYRatio: 0.75,
            submenu: systemPowerMenu,
            submenuOptions: systemPowerMenuOptions,
        },
        {
            image: 'power-plans.png',
            text: 'Plans',
            tooltip: 'Switch Power Plan',
            itemImageScale: 0.30,
            itemImageYRatio: 0.40,
            textYRatio: 0.75,
            submenu: powerPlansMenu,
        },
        {
            image: 'cleaning-brush.png',
            text: 'Cleanup',
            itemImageScale: 0.35,
            itemImageYRatio: 0.40,
            textYRatio: 0.75,
            submenu: systemCleanupMenu,
        },
        {
            image: 'tool-box.png',
            text: 'Tools',
            itemImageScale: 0.35,
            itemImageYRatio: 0.40,
            textYRatio: 0.75,
            submenu: toolsMenu,
        },
        {
            image: 'settings-app.png',
            text: 'Settings',
            tooltip: '• Windows Settings •`nRight-Click: Open Windows Settings app',
            rightClick: (*) => Run('ms-settings:'),
            itemImageScale: 0.30,
            itemImageYRatio: 0.40,
            textYRatio: 0.75,
            submenu: settingsMenu,
        },
        {image: 'magnifier.png', click: (*) => Run('magnify.exe')},
    ],
    [   ; ring 3
        {image: 'snipping-tool.png', click: (*) => Run('snippingTool.exe')},
        {image: 'snip-sketch.png', click: (*) => Run('ms-screenclip:')},
        {},
        {},
        {image: 'radify-skin-editor.png', click: (*) => Run('Radify Skin Editor.ahk'), tooltip: 'Open Radify Skin Editor'},
        {image: 'folder-orange.png', click: (*) => Run(A_ScriptDir), tooltip: 'Open Script Folder'},
        {image: 'edit-orange.png', click: (*) => Edit(), tooltip: 'Edit Menu'},
        {image: 'reload-orange.png', click: (*) => Reload(), tooltip: 'Reload'},
        {image: 'close.png', click: 'close', tooltip: 'Close'},
        {},
        {},
        {},
        {},
        {image: 'power-options-control-panel.png', click: (*) => Run('powercfg.cpl')},
        {image: 'control-panel.png', click: (*) => Run('shell:::{26EE0668-A00A-44D7-9371-BEB064C98683}')},
        {image: 'task-manager.png', click: (*) => Run('taskmgr.exe')},
        {image: 'system-display-settings-app.png', click: (*) => Run('ms-settings:display'), tooltip: 'Display settings'},
        {image: 'cmd.png', click: (*) => Run('Scripts\AdminCmd.ahk'), tooltip: 'Command Prompt as Administrator'},
        {image: 'powershell.png', click: (*) => Run('Scripts\AdminPowerShell.ahk'), tooltip: 'PowerShell as Administrator'},
    ],
])

;=== You can add your functions here. ========================================================

ClipSend(toSend, isClipReverted := true, untilRevert := 300) {
	if (isClipReverted)
		prevClip := ClipboardAll()

	A_Clipboard := ''
	A_Clipboard := toSend
	Send('^v')

	if (isClipReverted)
		SetTimer((*) => A_Clipboard := prevClip, -untilRevert)
}

/**********************************************
 * @credits teadrinker, XMCQCX (modifications)
 * @see {@link https://www.autohotkey.com/boards/viewtopic.php?f=76&t=66133&start=20 AHK Forum}
 */
GetFolderPath(folderName) {
    static folderGUIDs := {
        downloads: '{374DE290-123F-4565-9164-39C4925E467B}',
        music: '{4BD8D571-6D19-48D3-BE97-422220080E43}',
        videos: '{18989B1D-99B5-455B-841C-AB7C74E4DDFC}',
        pictures: '{33E28130-4E1E-4676-835A-98395C3BC3BB}',
        documents: '{FDD39AD0-238F-46AF-ADB4-6C85480369C7}',
        desktop: '{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}',
        recyclebin: '{B7534046-3ECB-4C18-BE4E-64CD4CB7D6AC}',
        recent: '{AE50C081-EBD2-438A-8655-8A092E34987A}'
    }

    if (!folderGUIDs.HasOwnProp(folderName))
        throw Error('Unknown folder name: ' folderName)

    FOLDERID := folderGUIDs.%folderName%
    CLSID := Buffer(16)
    DllCall('ole32\CLSIDFromString', 'WStr', FOLDERID, 'Ptr', CLSID.Ptr, 'Int')
    DllCall('shell32\SHGetKnownFolderPath', 'Ptr', CLSID.Ptr, 'UInt', 0, 'Ptr', 0, 'Ptr*', &ppath:=0, 'Int')
    dir := StrGet(ppath, 'UTF-16')
    DllCall('ole32\CoTaskMemFree', 'Ptr', ppath)
    expandedPath := Buffer(262 * 2)
    DllCall('ExpandEnvironmentStringsW', 'WStr', dir, 'Ptr', expandedPath.Ptr, 'UInt', 262)
    return StrGet(expandedPath.Ptr, 'UTF-16')
}

;==============================================

OnMessage(0x404, OnTrayClick)

A_IconTip :=
      'Click: ' trayClickActions.click '`n'
    . 'Double-Click: ' trayClickActions.doubleClick '`n'
    . 'Ctrl+Click: ' trayClickActions.ctrlClick '`n'
    . 'Shift+Click: ' trayClickActions.shiftClick '`n'
    . 'Alt+Click: ' trayClickActions.altClick

OnTrayClick(wParam, lParam, uMsg, hWnd) {
    static WM_LBUTTONDOWN := 0x201

    if (lParam = WM_LBUTTONDOWN) {
        for clickType, menuId in trayClickActions.OwnProps()
            Radify.Close(menuId)
        switch {
            case (GetKeyState('Ctrl', 'P')): Radify.Show(trayClickActions.ctrlClick, false)
            case (GetKeyState('Alt', 'P')): Radify.Show(trayClickActions.altClick, false)
            case (GetKeyState('Shift', 'P')): Radify.Show(trayClickActions.shiftClick, false)
            case (KeyWait('LButton', 'D T0.300')): Radify.Show(trayClickActions.doubleClick, false)
            default: Radify.Show(trayClickActions.click, false)
        }
    }
}

;==============================================

A_TrayMenu.Delete()
A_TrayMenu.Add('Radify Skin Editor', (*) => Run('Radify Skin Editor.ahk'))
A_TrayMenu.Add('Edit', (*) => Edit())
A_TrayMenu.Add('Open Script Folder', (*) => Run(A_ScriptDir))
A_TrayMenu.Add('Suspend Hotkeys', (*) => ToggleSuspend())
A_TrayMenu.Add('Reload', (*) => Reload())
A_TrayMenu.Add('Exit', (*) => ExitApp())

hiconsObj := {
    radifySkinEditor: 'hIcon:' LoadPicture('images\radify-skin-editor.ico', 'w32', &imgType),
    edit: 'hIcon:' LoadPicture('images\edit-orange.ico', 'w32', &imgType),
    openFolder: 'hIcon:' LoadPicture('images\folder-orange.ico', 'w32', &imgType),
    reload: 'hIcon:' LoadPicture('images\reload-orange.ico', 'w32', &imgType),
    exit: 'hIcon:' LoadPicture('images\exit-orange.ico', 'w32', &imgType),
    radify0: 'hIcon:*' LoadPicture('images\radify0.ico', 'w32', &imgType),
    radify1: 'hIcon:*' LoadPicture('images\radify1.ico', 'w32', &imgType)
}

A_TrayMenu.SetIcon('Radify Skin Editor', hiconsObj.radifySkinEditor)
A_TrayMenu.SetIcon('Edit', hiconsObj.edit)
A_TrayMenu.SetIcon('Open Script Folder', hiconsObj.openFolder)
A_TrayMenu.SetIcon('Reload', hiconsObj.reload)
A_TrayMenu.SetIcon('Exit', hiconsObj.exit)

TraySetIcon(hiconsObj.radify1,, true)

ToggleSuspend() {
    Suspend(-1)
    TraySetIcon(A_IsSuspended ? hiconsObj.radify0 : hiconsObj.radify1)
    A_TrayMenu.%(A_IsSuspended ? 'Check' : 'Uncheck')%('Suspend Hotkeys')
}


;==============================================

