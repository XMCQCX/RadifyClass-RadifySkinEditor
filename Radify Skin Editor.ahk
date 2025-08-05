#Requires AutoHotkey v2.0
#SingleInstance

#Include Radify.ahk
#Include .\Lib\Gdip_All.ahk
#Include .\Lib\Notify.ahk
#Include .\Lib\GuiCtrlTips.ahk
#Include .\Lib\LV_GridColor.ahk
#Include .\Lib\GuiButtonIcon.ahk
#Include .\Lib\ColorPicker.ahk
#Include .\Lib\Color.ahk

;==============================================

if (!pToken := Gdip_Startup())
    MsgBox('GDI+ failed to start. Please ensure you have GDI+ on your system.',, 'Iconx'), ExitApp()

/*********************************************************************************************
 * Radify Skin Editor - Explore all customization options of the Radify class, configure settings, preview skins, and more.
 * @author Martin Chartier (XMCQCX)
 * @version 1.0.0
 * @license MIT
 * @date 2025-08-05
 * @see {@link https://github.com/XMCQCX/RadifyClass-RadifySkinEditor GitHub}
 * @see {@link https://www.autohotkey.com AHK Forum}
 ********************************************************************************************/
class RadifySkinEditor {
    static __New()
    {
        this.scriptName := 'Radify Skin Editor'
        this.scriptVersion := 'v1.0.0'
        this.linkGitHubRepo := 'https://github.com/XMCQCX/RadifyClass-RadifySkinEditor'
        this.gMainTitle := this.scriptName ' - ' this.scriptVersion
        this.debounceTimers := {}

        if (!FileExist('Icons.dll'))
            MsgBox('Missing DLL file: The application can`'t start because "Icons.dll" is missing.`n`nThe application will now exit.', this.scriptName ' - Error', 'Iconx'), ExitApp()

        if (!Radify.isValidConfiguration)
            ExitApp()

        this.defaults := {
            skin: Radify.defaults.skin,
            savedColors: ['FFA500', 'FFC0CB', 'A52A2A', 'FFD700', '40E0D0', 'FF7F50', 'E6E6FA', '4B0082'],
            soundHistory: [],
            imageHistory: [],
            trayMenuIconSize: 24,
            soundOnSelection: 0
        }

        this.arrTextRendering := this.CreateIncrementalArray(1, Radify.range.textRendering[1], Radify.range.textRendering[2])
        this.arrTextShadowOffset := this.CreateIncrementalArray(1, Radify.range.textShadowOffset[1], Radify.range.textShadowOffset[2])
        this.arrSmoothingMode := this.CreateIncrementalArray(1, Radify.range.smoothingMode[1], Radify.range.smoothingMode[2])
        this.arrInterpolationMode := this.CreateIncrementalArray(1, Radify.range.interpolationMode[1], Radify.range.interpolationMode[2])
        this.arrTextFont := this.MapToArray(this.GetFontNames())
        this.arrSkinsNoDefault := this.ObjectToArray(Radify.skins)
        this.arrSkins := this.ObjectToArray(Radify.skins)
        this.arrSkins.InsertAt(1, 'Default')
        this.arrClick := ['None', 'Close', 'CloseMenu', 'Drag']
        this.arrRightClick := ['None', 'Close', 'CloseMenu']
        this.strKeysSoundPipeDelim := this.ArrayToString(Radify.arrKeysSound, '|')
        this.arrkeysImage := this.ObjectToArray(Radify.imageKeyToFileName)
        this.strKeysImagePipeDelim := this.ArrayToString(this.arrkeysImage, '|')

        this.arrSettings := [
            ['Item Glow Image', 'itemGlowImage'],
            ['Menu Outer Rim Image', 'menuOuterRimImage'],
            ['Menu Background Image', 'menuBackgroundImage'],
            ['Item Background Image', 'itemBackgroundImage'],
            ['Center Background Image', 'centerBackgroundImage'],
            ['Center Image', 'centerImage'],
            ['Submenu Indicator Image', 'submenuIndicatorImage'],
            ['Item Size', 'itemSize'],
            ['Radius Scale', 'radiusScale'],
            ['Center Size', 'centerSize'],
            ['Center Image Scale', 'centerImageScale'],
            ['Item Image Scale', 'itemImageScale'],
            ['Item Image Y Ratio', 'itemImageYRatio'],
            ['Submenu Indicator Size', 'submenuIndicatorSize'],
            ['Submenu Indicator Y Ratio', 'submenuIndicatorYRatio'],
            ['Outer Ring Margin', 'outerRingMargin'],
            ['Outer Rim Width', 'outerRimWidth'],
            ['Menu Click', 'menuClick'],
            ['Menu Right-Click', 'menuRightClick'],
            ['Center Click', 'centerClick'],
            ['Center Right-Click', 'centerRightClick'],
            ['Close Menu Tree on Item Click', 'closeOnItemClick'],
            ['Close Menu Tree on Item Right-Click', 'closeOnItemRightClick'],
            ['Close Menu Block', 'closeMenuBlock'],
            ['Always on Top', 'alwaysOnTop'],
            ['Activate on Show', 'activateOnShow'],
            ['Enable Tooltip', 'enableTooltip'],
            ['Enable Glow', 'enableGlow'],
            ['Auto Tooltip', 'autoTooltip'],
            ['Auto-Center Mouse', 'autoCenterMouse'],
            ['Mirror Click to Right-Click', 'mirrorClickToRightClick'],
            ['Enable Item Text', 'enableItemText'],
            ['Item Background Image on Center', 'itemBackgroundImageOnCenter'],
            ['Item Background Image on Items', 'itemBackgroundImageOnItems'],
            ['Sound on Select Item', 'soundOnSelect'],
            ['Sound on Menu Show', 'soundOnShow'],
            ['Sound on Menu Close', 'soundOnClose'],
            ['Sound on Submenu Show', 'soundOnSubShow'],
            ['Sound on Submenu Close', 'soundOnSubClose'],
            ['Text Font', 'textFont'],
            ['Text Color', 'textColor'],
            ['Text Size', 'textSize'],
            ['Text Font Options', 'textFontOptions'],
            ['Text Shadow Color', 'textShadowColor'],
            ['Text Shadow Offset', 'textShadowOffset'],
            ['Text Box Scale', 'textBoxScale'],
            ['Text Y Ratio', 'textYRatio'],
            ['Text Rendering', 'textRendering'],
            ['Smoothing Mode', 'smoothingMode'],
            ['Interpolation Mode', 'interpolationMode'],
        ]

        Radify.originalDefaults.DeleteProp('guiOptions')
        this.arrSettingsBasic := ['itemGlowImage', 'menuOuterRimImage', 'menuBackgroundImage', 'itemBackgroundImage', 'centerBackgroundImage', 'submenuIndicatorImage']

        Radify.skins.default := {}

        for skinName, skinOptions in Radify.skins.OwnProps()
            for key, value in Radify.defaults.OwnProps()
                Radify.skins.%skinName%.%key% := (skinOptions.HasOwnProp(key) ? skinOptions.%key% : value)

        if (FileExist('Settings.json')) {
            fileObj := FileOpen('Settings.json', 'r', 'UTF-8')
            this.user := JSON_thqby_Radify.parse(fileObj.Read(), false, false)
            fileObj.Close()
        }
        else this.user := {}

        for key, value in this.defaults.OwnProps()
            if (!this.user.HasOwnProp(key))
                this.user.%key% := value

        if (!Radify.skins.HasOwnProp(this.user.skin))
            this.user.skin := this.defaults.skin

        this.CreateImageSoundArray(['image', 'sound'])

        this.strImageExtfilter := 'Image ('
        for value in Radify.arrImageExt
            this.strImageExtfilter .= '*.' value '; '
        this.strImageExtfilter := SubStr(this.strImageExtfilter, 1, -2) . ')'

        this.mIcons := Map(
            'mainTray', 'HICON:*' LoadPicture('Icons.dll', 'Icon1 w32', &imgType),
            'mainAbout', 'HICON:*' LoadPicture('Icons.dll', 'Icon1 w64', &imgType),
            'colorPick', 'HICON:*' LoadPicture('Icons.dll', 'Icon31 w32', &imgType),
            'colorPicker', 'HICON:*' LoadPicture('Icons.dll', 'Icon32 w32', &imgType),
            'clipBoard', 'HICON:*' LoadPicture('Icons.dll', 'Icon24 w32', &imgType),
            'font', 'HICON:*' LoadPicture('Icons.dll', 'Icon33 w32', &imgType),
            'buymeacoffee', 'HICON:*' LoadPicture('Icons.dll', 'Icon48 w32', &imgType),
            'reset', 'HICON:*' LoadPicture('Icons.dll', 'Icon30 w32', &imgType),
            'musicNote', 'HICON:*' LoadPicture('Icons.dll', 'Icon34 w32', &imgType),
            'destroy', 'HICON:*' LoadPicture('Icons.dll', 'Icon37 w64', &imgType),
            'test', 'HICON:*' LoadPicture('Icons.dll', 'Icon36 w64', &imgType),
            'delete', 'HICON:*' LoadPicture('Icons.dll', 'Icon19 w64', &imgType),
            'menuDelete', 'HICON:*' LoadPicture('Icons.dll', 'Icon19 w32', &imgType),
            'select', 'HICON:*' LoadPicture('Icons.dll', 'Icon11 w32', &imgType),
            'preview', 'HICON:*' LoadPicture('Icons.dll', 'Icon47 w32', &imgType),
            'transIcon', 'HICON:*' LoadPicture('Icons.dll', 'Icon38 w32', &imgType),
            'monInfo', 'HICON:*' LoadPicture('Icons.dll', 'Icon40 w32', &imgType),
            'gitHub', 'HICON:*' LoadPicture('Icons.dll', 'Icon28 w32', &imgType),
            'iSmall', 'HICON:*' LoadPicture('Icons.dll', 'Icon49 w24', &imgType),
            'removeList', 'HICON:*' LoadPicture('Icons.dll', 'Icon41 w32', &imgType),
            'unCheckAll', 'HICON:*' LoadPicture('Icons.dll', 'Icon13 w32', &imgType),
            'checkAll', 'HICON:*' LoadPicture('Icons.dll', 'Icon14 w32', &imgType),
            'selectAll', 'HICON:*' LoadPicture('Icons.dll', 'Icon43 w32', &imgType),
            'btn_about', 'HICON:*' LoadPicture('Icons.dll', 'Icon5 w32', &imgType),
            'btn_edit', 'HICON:*' LoadPicture('Icons.dll', 'Icon7 w32', &imgType),
            'floppy', 'HICON:*' LoadPicture('Icons.dll', 'Icon25 w32', &imgType),
            'resetSkin', 'HICON:*' LoadPicture('Icons.dll', 'Icon44 w32', &imgType),
            'checkSkin', 'HICON:*' LoadPicture('Icons.dll', 'Icon45 w32', &imgType),
            'checkBasic', 'HICON:*' LoadPicture('Icons.dll', 'Icon46 w32', &imgType),
            'clipBoard', 'HICON:*' LoadPicture('Icons.dll', 'Icon24 w64', &imgType),
            'exitBig', 'HICON:*' LoadPicture('Icons.dll', 'Icon3 w64', &imgType),
            'dark-gradient', 'HICON:*' LoadPicture('Icons.dll', 'Icon50', &imgType),
        )

        for value in ['main', 'loading', 'exit', 'reload', 'about', 'settings', 'edit', 'folder', 'tools']
            this.mIcons[value] := 'HICON:*' LoadPicture('Icons.dll', 'Icon' A_Index ' w' this.user.trayMenuIconSize, &imgType)

        this.strOpts := ''
        for key, value in Notify.mOrig_mDefaults
            if (!RegExMatch(key, 'i)^(tc|mc|bc|bdr|image|maxw|bgImg)$'))
                this.strOpts .= key '=' value ' '

        this.strOpts .= 'maxw=425 bgImg=' this.mIcons['dark-gradient'] ' '

        HotIf this.gList_lv_Active.Bind(this)
        Hotkey('Del', this.gList_lv_Remove.Bind(this))
        Hotkey('^a', this.gList_lv_SelectAll.Bind(this))
        HotIf

        this.Create_TrayMenu()
        OnExit(this.OnExit.Bind(this))
        this.gMain_Show()
    }

    ;=============================================================================================

    static OnExit(exitReason, exitCode)
    {
        this.SaveToJSON()
        Radify.DisposeResources()
        Gdip_Shutdown(pToken)
    }

    ;=============================================================================================

    static CreateImageSoundArray(arr)
    {
        if (this.HasVal('image', arr)) {
            Radify.GetImagePaths()
            this.arrImage := this.ObjectToArray(Radify.images)

            for value in ['ItemGlow', 'MenuOuterRim', 'MenuBack', 'ItemBack', 'CenterImage', 'SubmenuIndicator']
                this.arrImage.InsertAt(1, value '.png')

            this.arrImage.InsertAt(1, 'None')

            for skin, skinObj in Radify.skins.OwnProps()
                for value in Radify.imageKeyToFileName.OwnProps()
                    if (skinObj.HasOwnProp(value) && !this.HasVal(skinObj.%value%, this.arrImage))
                        this.arrImage.Push(skinObj.%value%)
        }

        ;==============================================

        if (this.HasVal('sound', arr)) {
            Radify.GetSoundPaths()
            this.arrSound := this.ObjectToArray(Radify.sounds)
            this.arrSound.InsertAt(1, 'None')

            for skin, skinObj in Radify.skins.OwnProps()
                for value in Radify.arrKeysSound
                    if (skinObj.HasOwnProp(value) && !this.HasVal(skinObj.%value%, this.arrSound))
                        this.arrSound.Push(skinObj.%value%)
        }

        ;==============================================

        for value in arr {
            this.arr%value%Radify := Array()

            for item in this.arr%value%
                this.arr%value%Radify.Push(item)

            for item in this.user.%value 'History'%
                if (!this.Hasval(item, this.%'arr' value%))
                    this.%'arr' value%.Push(item)

            this.arr%value% := this.SortArray(this.arr%value%)
        }

        for value in ['Images', 'Sounds']
            if (Radify.generals.%value 'Dir'% = Radify.rootDir '\' value)
                Radify.generals.%value 'Dir'% := 'RootDir\' value
    }

    ;=============================================================================================

    static SaveToJSON()
    {
        for value in ['image', 'sound'] {
            this.user.%value 'History'% := Array()

            for item in this.arr%value%
                if (item != 'none' && !this.HasVal(item, this.arr%value%Radify))
                    this.user.%value 'History'%.Push(item)
        }

        str := JSON_thqby_Radify.stringify(this.user, unset, '  ')
        objFile := FileOpen('Settings.json', 'w', 'UTF-8')
        objFile.Write(str)
        objFile.Close()
    }

    ;=============================================================================================

    static Create_TrayMenu()
    {
        A_TrayMenu.Delete()
        A_TrayMenu.Add('Open Application Folder', (*) => Run(A_ScriptDir))
        A_TrayMenu.Add('About', this.gAbout_Show.Bind(this))
        A_TrayMenu.Add('Reload', (*) => Reload())
        A_TrayMenu.Add('Exit', (*) => ExitApp())

        for value in ['exit', 'reload', 'about']
            A_TrayMenu.SetIcon(value, this.mIcons[value],, this.user.trayMenuIconSize)

        A_TrayMenu.SetIcon('Open Application Folder', this.mIcons['folder'],, this.user.trayMenuIconSize)
        TraySetIcon(this.mIcons['mainTray'],, true)
    }

    ;=============================================================================================

    static gMain_Show(*)
    {
        this.gMain := Gui(, this.gMainTitle)
        this.gMain.OnEvent('Close', (*) => ExitApp())
        this.gMain.OnEvent('DropFiles', this.gMain_DropFiles.Bind(this))
        this.gMain.SetFont('s10')
        this.gMain.Tips := GuiCtrlTips(this.gMain)
        this.gMain.Tips.SetDelayTime('AUTOPOP', 30000)

        btnSize := 30
        gbWidthSkin := 315
        gbHeightSkin := 55

        this.gMain.gb_skin := this.gMain.Add('GroupBox',  'w' gbWidthSkin ' h' gbHeightSkin ' cBlack', 'Skin')
        this.gMain.ddl_skins := this.gMain.Add('DropDownList', 'xp+10 yp+20 Section vskin', this.arrSkins)
        this.gMain.ddl_skins.OnEvent('Change', this.DebounceCall.Bind(this, 125, 'gMain_ddl_skins_Change', 'skin'))
        this.gMain.btn_copySkin := this.gMain.Add('Button', 'x+5 yp-3 w' btnSize ' h' btnSize)
        this.gMain.btn_copySkin.OnEvent('Click', this.CopyToClipboard.Bind(this, 'skin'))
        GuiButtonIcon(this.gMain.btn_copySkin, this.mIcons['clipBoard'], 1, 's20')
        this.gMain.btn_editSkin := this.gMain.Add('Button', 'x+5 yp w' btnSize ' h' btnSize)
        this.gMain.btn_editSkin.OnEvent('Click', this.gSkin_Show.Bind(this, 'edit'))
        GuiButtonIcon(this.gMain.btn_editSkin, this.mIcons['btn_edit'], 1, 's20')
        this.gMain.btn_saveDefaultSkin := this.gMain.Add('Button', 'x+5 yp w' btnSize ' h' btnSize)
        this.gMain.btn_saveDefaultSkin.OnEvent('Click', this.gMain_btn_saveDefaultSkin_Click.Bind(this))
        GuiButtonIcon(this.gMain.btn_saveDefaultSkin, this.mIcons['floppy'], 1, 's20')
        this.gMain.btn_resettAll := this.gMain.Add('Button', 'x+5 w' btnSize ' h' btnSize)
        this.gMain.btn_resettAll.OnEvent('Click', (*) => this.UpdateControls([this.gMain.ddl_skins.Text]))
        GuiButtonIcon(this.gMain.btn_resettAll, this.mIcons['resetSkin'], 1, 's20')

        gbWidthTop := 202
        gbHeightTop := 55

        this.gMain.gb_top := this.gMain.Add('GroupBox', 'xm+' gbWidthSkin + this.gMain.MarginX ' ym w' gbWidthTop ' h' gbHeightTop ' cBlack')
        this.gMain.btn_gList_Show := this.gMain.Add('Button', 'xp+8 yp+17 Section w' btnSize ' h' btnSize)
        this.gMain.btn_gList_Show.OnEvent('Click', this.gList_Show.Bind(this))
        GuiButtonIcon(this.gMain.btn_gList_Show, this.mIcons['removeList'], 1, 's20')
        this.gMain.btn_gDir_Show := this.gMain.Add('Button', 'x+5 w' btnSize ' h' btnSize)
        this.gMain.btn_gDir_Show.OnEvent('Click', this.gDir_Show.Bind(this))
        GuiButtonIcon(this.gMain.btn_gDir_Show, this.mIcons['folder'], 1, 's20')
        this.gMain.btn_about := this.gMain.Add('Button', 'x+18 w' btnSize ' h' btnSize)
        this.gMain.btn_about.OnEvent('Click', this.gAbout_Show.Bind(this))
        GuiButtonIcon(this.gMain.btn_about, this.mIcons['btn_about'], 1, 's20')
        this.gMain.btn_gitHub := this.gMain.Add('Button', 'x+5 w' btnSize ' h' btnSize)
        this.gMain.btn_gitHub.OnEvent('Click', (*) => Run(this.linkGitHubRepo))
        GuiButtonIcon(this.gMain.btn_gitHub, this.mIcons['gitHub'], 1, 's20')
        this.gMain.btn_donate := this.gMain.Add('Button', 'x+5 w' btnSize ' h' btnSize)
        this.gMain.btn_donate.OnEvent('Click', (*) => Run('https://buymeacoffee.com/xmcqcx'))
        GuiButtonIcon(this.gMain.btn_donate, this.mIcons['buymeacoffee'], 1, 's20')

        gbWidthMisc := (gbWidthSkin + gbWidthTop + this.gMain.MarginX)
        gbHeightMisc := 370

        this.gMain.gb_misc := this.gMain.Add('GroupBox',  'xm ym+' gbHeightSkin + this.gMain.MarginY ' w' gbWidthMisc ' h' gbHeightMisc ' cBlack', 'Misc.')
        this.gMain.txt_itemSize := this.gMain.Add('Text', 'xp+10 yp+25 Section +0x0100', this.gMain_GetDisplayName('itemSize') ':')
        this.gMain.edit_itemSize := this.gMain.Add('Edit', 'xs+170 yp-2 w50 vitemSize Number Limit' StrLen(Radify.range.itemSize[2]))
        this.gMain.Add('UpDown', 'Range' Radify.range.itemSize[1] '-' Radify.range.itemSize[2])
        this.gMain.txt_radiusScale := this.gMain.Add('Text', 'xs +0x0100', this.gMain_GetDisplayName('radiusScale') ':')
        this.gMain.edit_radiusScale := this.gMain.Add('Edit', 'xs+170 yp-2 w50 h23 -wrap vradiusScale')
        this.gMain.txt_centerSize := this.gMain.Add('Text', 'xs +0x0100', this.gMain_GetDisplayName('centerSize') ':')
        this.gMain.edit_centerSize := this.gMain.Add('Edit', 'xs+170 yp-2 w50 vcenterSize Number Limit' StrLen(Radify.range.centerSize[2]))
        this.gMain.Add('UpDown', 'Range' Radify.range.centerSize[1] '-' Radify.range.centerSize[2])
        this.gMain.txt_centerImageScale := this.gMain.Add('Text', 'xs +0x0100', this.gMain_GetDisplayName('centerImageScale') ':')
        this.gMain.edit_centerImageScale := this.gMain.Add('Edit', 'xs+170 yp-2 w50 h23 -wrap vcenterImageScale')
        this.gMain.txt_itemImageScale := this.gMain.Add('Text', 'xs +0x0100', this.gMain_GetDisplayName('itemImageScale') ':')
        this.gMain.edit_itemImageScale := this.gMain.Add('Edit', 'xs+170 yp-2 w50 h23 -wrap vitemImageScale')
        this.gMain.txt_itemImageYRatio := this.gMain.Add('Text', 'xs +0x0100', this.gMain_GetDisplayName('itemImageYRatio') ':')
        this.gMain.edit_itemImageYRatio := this.gMain.Add('Edit', 'xs+170 yp-2 w50 h23 -wrap vitemImageYRatio')
        this.gMain.txt_submenuIndicatorSize := this.gMain.Add('Text', 'xs +0x0100', this.gMain_GetDisplayName('submenuIndicatorSize') ':')
        this.gMain.edit_submenuIndicatorSize := this.gMain.Add('Edit', 'xs+170 yp-2 w50 vsubmenuIndicatorSize Number Limit' StrLen(Radify.range.submenuIndicatorSize[2]))
        this.gMain.Add('UpDown', 'Range' Radify.range.submenuIndicatorSize[1] '-' Radify.range.submenuIndicatorSize[2])
        this.gMain.txt_submenuIndicatorYRatio := this.gMain.Add('Text', 'xs +0x0100', this.gMain_GetDisplayName('submenuIndicatorYRatio') ':')
        this.gMain.edit_submenuIndicatorYRatio := this.gMain.Add('Edit', 'xs+170 yp-2 w50 h23 -wrap vsubmenuIndicatorYRatio')
        this.gMain.txt_outerRingMargin := this.gMain.Add('Text', 'xs +0x0100', this.gMain_GetDisplayName('outerRingMargin') ':')
        this.gMain.edit_outerRingMargin := this.gMain.Add('Edit', 'xs+170 yp-2 w50 vouterRingMargin Number Limit' StrLen(Radify.range.outerRingMargin[2]))
        this.gMain.Add('UpDown', 'Range' Radify.range.outerRingMargin[1] '-' Radify.range.outerRingMargin[2])
        this.gMain.edit_outerRingMargin.OnEvent('Change', this.DebounceCall.Bind(this, 125, 'gMain_ClampToMaximum_Change', 'outerRingMargin'))
        this.gMain.txt_outerRimWidth := this.gMain.Add('Text', 'xs +0x0100', this.gMain_GetDisplayName('outerRimWidth') ':')
        this.gMain.edit_outerRimWidth := this.gMain.Add('Edit', 'xs+170 yp-2 w50 vouterRimWidth Number Limit' StrLen(Radify.range.outerRimWidth[2]))
        this.gMain.Add('UpDown', 'Range' Radify.range.outerRimWidth[1] '-' Radify.range.outerRimWidth[2])
        this.gMain.edit_outerRimWidth.OnEvent('Change', this.DebounceCall.Bind(this, 125, 'gMain_ClampToMaximum_Change', 'outerRimWidth'))
        this.gMain.cb_enableTooltip := this.gMain.Add('CheckBox', 'xs venableTooltip', ' ' this.gMain_GetDisplayName('enableTooltip'))
        this.gMain.cb_enableGlow := this.gMain.Add('CheckBox', 'xs+115 yp venableGlow', ' ' this.gMain_GetDisplayName('enableGlow'))
        this.gMain.cb_autoTooltip := this.gMain.Add('CheckBox', 'xs vautoTooltip', ' ' this.gMain_GetDisplayName('autoTooltip'))
        this.gMain.cb_autoCenterMouse := this.gMain.Add('CheckBox', 'xs+115 yp vautoCenterMouse', ' ' this.gMain_GetDisplayName('autoCenterMouse'))
        this.gMain.txt_menuClick := this.gMain.Add('Text', 'xs+265 ys Section +0x0100', this.gMain_GetDisplayName('menuClick') ':')
        this.gMain.ddl_menuClick := this.gMain.Add('DropDownList', 'xs+120 yp-2 w100 vmenuClick', this.arrClick)
        this.gMain.txt_menuRightClick := this.gMain.Add('Text', 'xs +0x0100', this.gMain_GetDisplayName('menuRightClick') ':')
        this.gMain.ddl_menuRightClick := this.gMain.Add('DropDownList', 'xs+120 yp-2 w100 vmenuRightClick', this.arrRightClick)
        this.gMain.txt_centerClick := this.gMain.Add('Text', 'xs +0x0100', this.gMain_GetDisplayName('centerClick') ':')
        this.gMain.ddl_centerClick := this.gMain.Add('DropDownList', 'xs+120 yp-2 w100 vcenterClick', this.arrClick)
        this.gMain.txt_centerRightClick := this.gMain.Add('Text', 'xs +0x0100', this.gMain_GetDisplayName('centerRightClick') ':')
        this.gMain.ddl_centerRightClick := this.gMain.Add('DropDownList', 'xs+120 yp-2 w100 vcenterRightClick', this.arrRightClick)

        for setting in ['closeOnItemClick', 'closeOnItemRightClick', 'closeMenuBlock', 'mirrorClickToRightClick', 'enableItemText', 'itemBackgroundImageOnCenter',
            'itemBackgroundImageOnItems', 'alwaysOnTop', 'activateOnShow']
            this.gMain.cb_%setting% := this.gMain.Add('CheckBox', 'xs v' setting, ' ' this.gMain_GetDisplayName(setting))

        this.gMain.pic_miscInfo := this.gMain.Add('Picture', 'xs-218 ys-24 w15 h15 +0x0100', this.mIcons['iSmall'])
        this.gMain.btn_resetMisc := this.gMain.Add('Button', 'xs+224 ys-28 w22 h22')
        this.gMain.btn_resetMisc.OnEvent('Click', this.gMain_btn_resetMisc_Click.Bind(this))
        GuiButtonIcon(this.gMain.btn_resetMisc, this.mIcons['reset'], 1, 's12')

        gbWidthSound := 477
        gbHeightSound := 226

        this.gMain.gb_sound := this.gMain.Add('GroupBox',  'xm ym+' gbHeightSkin + gbHeightMisc + this.gMain.MarginY*2 ' w' gbWidthSound ' h' gbHeightSound ' cBlack', 'Sound')

        for (value in Radify.arrKeysSound) {
            strText := StrReplace(this.gMain_GetDisplayName(value), 'Sound on ', '')
            this.gMain.txt_%value% := this.gMain.Add('Text', (A_Index = 1 ? 'xp+10 yp+28 Section +0x0100' : 'xs +0x0100'), strText ':')
            this.gMain.ddl_%value% := this.gMain.Add('DropDownList', 'xs+100 yp-2 w250 v' value, this.arrSound)
            this.gMain.ddl_%value%.OnEvent('Change', this.DebounceCall.Bind(this, 125, 'gMain_ddl_sound_Change', value))
            this.gMain.btn_browse_%value% := this.gMain.Add('Button', 'x+5 yp-2 w' btnSize ' h' btnSize, '...')
            this.gMain.btn_browse_%value%.OnEvent('Click', this.gMain_btn_browse.Bind(this, value))
            this.gMain.btn_playsound_%value% := this.gMain.Add('Button', 'x+5 yp w' btnSize ' h' btnSize)
            this.gMain.btn_playsound_%value%.OnEvent('Click', this.gMain_PlaySound.Bind(this, value))
            GuiButtonIcon(this.gMain.btn_playsound_%value%, this.mIcons['musicNote'], 1, 's20')
            this.gMain.btn_copySound_%value% := this.gMain.Add('Button', 'x+5 yp w' btnSize ' h' btnSize)
            this.gMain.btn_copySound_%value%.OnEvent('Click', this.CopyToClipboard.Bind(this, 'sound', value))
            GuiButtonIcon(this.gMain.btn_copySound_%value%, this.mIcons['clipBoard'], 1, 's20')
        }

        this.gMain.cb_soundOnSelection := this.gMain.Add('CheckBox', 'xs vsoundOnSelection', ' Play the sound when selected')
        this.gMain.cb_soundOnSelection.OnEvent('Click', this.gMain_cb_soundOnSelection_Click.Bind(this))
        this.gMain.pic_soundInfo := this.gMain.Add('Picture', 'xs+50 ys-26 w15 h15 +0x0100', this.mIcons['iSmall'])
        this.gMain.btn_resetSound := this.gMain.Add('Button', 'xs+' gbWidthSound - 43 ' ys-30 w22 h22')
        this.gMain.btn_resetSound.OnEvent('Click', this.gMain_btn_resetSound_Click.Bind(this))
        GuiButtonIcon(this.gMain.btn_resetSound, this.mIcons['reset'], 1, 's12')

        gbWidthImages := 490
        gbHeightImages := 345

        this.gMain.gb_image := this.gMain.Add('GroupBox',  'xm+' gbWidthMisc + this.gMain.MarginX ' ym w' gbWidthImages ' h' gbHeightImages ' cBlack', 'Image')

        for value in ['itemGlowImage', 'menuOuterRimImage', 'menuBackgroundImage', 'itemBackgroundImage', 'centerBackgroundImage'] {
            this.gMain.pic_%value%:= this.gMain.Add('Picture', (A_Index = 1 ? 'xp+10 yp+25 Section' : 'xp+87') ' w75 h75 vpic' value ' +Border +0x0100')
            this.gMain.pic_%value%.OnEvent('DoubleClick', this.gMain_OpenSkinFolder.Bind(this))
        }

        this.gMain.pic_centerImage := this.gMain.Add('Picture', 'xp+85 yp w35 h35 vpicCenterImage +Border +0x0100')
        this.gMain.pic_submenuIndicatorImage := this.gMain.Add('Picture', 'yp+40 w35 h35 vpicSubmenuIndicatorImage +Border +0x0100')

        for value in ['itemGlowImage', 'menuOuterRimImage', 'menuBackgroundImage', 'itemBackgroundImage', 'centerBackgroundImage', 'centerImage', 'submenuIndicatorImage'] {
            strText := StrReplace(this.gMain_GetDisplayName(value), ' Image', '')
            this.gMain.txt_%value% := this.gMain.Add('Text', (A_Index = 1 ? 'xs yp+45 +0x0100' : 'xs +0x0100'), strText ':')
            this.gMain.ddl_%value% := this.gMain.Add('DropDownList', 'xs+122 yp-2 w250 v' value, this.arrImage)
            this.gMain.ddl_%value%.OnEvent('Change', this.DebounceCall.Bind(this, 125, 'gMain_ddl_image_Change', value))
            this.gMain.btn_browse_%value% := this.gMain.Add('Button', 'x+5 yp-2 w' btnSize ' h' btnSize, '...')
            this.gMain.btn_browse_%value%.OnEvent('Click', this.gMain_btn_browse.Bind(this, value))
            this.gMain.btn_copyImage_%value% := this.gMain.Add('Button', 'x+5 yp w' btnSize ' h' btnSize)
            this.gMain.btn_copyImage_%value%.OnEvent('Click', this.CopyToClipboard.Bind(this, 'image', value))
            GuiButtonIcon(this.gMain.btn_copyImage_%value%, this.mIcons['clipBoard'], 1, 's20')
            this.gMain.btn_resetImage_%value% := this.gMain.Add('Button', 'x+5 w22 h22')
            this.gMain.btn_resetImage_%value%.OnEvent('Click', this.gMain_btn_resetImage_Click.Bind(this, value))
            GuiButtonIcon(this.gMain.btn_resetImage_%value%, this.mIcons['reset'], 1, 's12')
        }

        this.gMain.pic_imageInfo := this.gMain.Add('Picture', 'xs+50 ys-23 w15 h15 +0x0100', this.mIcons['iSmall'])
        this.gMain.btn_resetImage := this.gMain.Add('Button', 'xs+' gbWidthImages - 43 ' ys-27 w22 h22')
        this.gMain.btn_resetImage.OnEvent('Click', this.gMain_btn_resetImageAll_Click.Bind(this))
        GuiButtonIcon(this.gMain.btn_resetImage, this.mIcons['reset'], 1, 's12')

        this.picWidth := 280
        this.picHeight := 65
        gbWidthText := 302
        gbHeightText := 315

        this.gMain.gb_text := this.gMain.Add('GroupBox',  'xm+' gbWidthMisc + this.gMain.MarginX ' ym+' gbHeightImages + this.gMain.MarginY ' w' gbWidthText ' h' gbHeightText ' cBlack', 'Text')
        this.gMain.pic_preview := this.gMain.Add('Picture', 'w' this.picWidth ' h' this.picHeight ' xp+10 yp+25 Section +Border')
        this.gMain.txt_textFont := this.gMain.Add('Text', 'xs +0x0100', 'Font:')
        this.gMain.ddl_textFont := this.gMain.Add('DropDownList', 'xs+40 yp-2 w240 vtextFont', this.arrTextFont)
        this.gMain.ddl_textFont.OnEvent('Change', this.gMain_UpdateTextPreview.Bind(this))
        this.gMain.txt_textColor := this.gMain.Add('Text', 'xs yp+35 +0x0100', 'Color:')
        this.gMain.edit_textColor := this.gMain.Add('Edit', 'xs+40 yp-2 w80 h23 -wrap vtextColor')
        this.gMain.edit_textColor.OnEvent('Change', this.gMain_UpdateTextPreview.Bind(this))
        this.gMain.btn_textColorSelect := this.gMain.Add('Button', 'x+5 yp-4 w' btnSize ' h' btnSize, '')
        this.gMain.btn_textColorSelect.OnEvent('Click', this.gMain_btn_colorSelect_Click.Bind(this, 'textColor'))
        GuiButtonIcon(this.gMain.btn_textColorSelect, this.mIcons['colorPick'], 1, 's20')
        this.gMain.btn_textColorPicker := this.gMain.Add('Button', 'x+5 w' btnSize ' h' btnSize)
        this.gMain.btn_textColorPicker.OnEvent('Click', this.gMain_btn_colorPicker_Click.Bind(this, 'textColor'))
        GuiButtonIcon(this.gMain.btn_textColorPicker, this.mIcons['colorPicker'], 1, 's20')
        this.gMain.btn_copyFont := this.gMain.Add('Button', 'x+60 yp w' btnSize ' h' btnSize)
        this.gMain.btn_copyFont.OnEvent('Click', this.CopyToClipboard.Bind(this, 'font'))
        GuiButtonIcon(this.gMain.btn_copyFont, this.mIcons['clipBoard'], 1, 's20')
        this.gMain.txt_textSize := this.gMain.Add('Text', 'xs +0x0100', 'Size:')
        this.gMain.edit_textSize := this.gMain.Add('Edit', 'xs+40 yp-2 w50 vtextSize Number Limit' StrLen(Radify.range.textSize[2]))
        this.gMain.Add('UpDown', 'Range' Radify.range.textSize[1] '-' Radify.range.textSize[2])

        for value in ['bold', 'italic', 'strikeout', 'underline'] {
            this.gMain.cb_%value% := this.gMain.Add('CheckBox', (A_Index = 1 ? 'xs' : 'x+10') ' v' value, Format('{:T}', value))
            this.gMain.cb_%value%.OnEvent('Click', this.gMain_UpdateTextPreview.Bind(this))
        }

        this.gMain.txt_textShadowColor := this.gMain.Add('Text', 'xs yp+30 +0x0100', 'Shadow Color:')
        this.gMain.edit_textShadowColor := this.gMain.Add('Edit', 'xs+95 yp-2 w80 h23 -wrap vtextShadowColor')
        this.gMain.edit_textShadowColor.OnEvent('Change', this.gMain_UpdateTextPreview.Bind(this))
        this.gMain.btn_textShadowColorSelect := this.gMain.Add('Button', 'x+5 yp-4 w' btnSize ' h' btnSize, '')
        this.gMain.btn_textShadowColorSelect.OnEvent('Click', this.gMain_btn_colorSelect_Click.Bind(this, 'textShadowColor'))
        GuiButtonIcon(this.gMain.btn_textShadowColorSelect, this.mIcons['colorPick'], 1, 's20')
        this.gMain.btn_shadowColorPicker := this.gMain.Add('Button', 'x+5 w' btnSize ' h' btnSize)
        this.gMain.btn_shadowColorPicker.OnEvent('Click', this.gMain_btn_colorPicker_Click.Bind(this, 'textShadowColor'))
        GuiButtonIcon(this.gMain.btn_shadowColorPicker, this.mIcons['colorPicker'], 1, 's20')
        this.gMain.txt_textShadowOffset := this.gMain.Add('Text', 'xs +0x0100', 'Shadow Offset:')
        this.gMain.ddl_textShadowOffset := this.gMain.Add('DropDownList', 'xs+95 yp-2 w50 vtextShadowOffset', this.arrTextShadowOffset)
        this.gMain.ddl_textShadowOffset.OnEvent('Change', this.gMain_UpdateTextPreview.Bind(this))
        this.gMain.txt_textBoxScale := this.gMain.Add('Text', 'xs+160 yp+2 +0x0100', 'Box Scale:')
        this.gMain.edit_textBoxScale := this.gMain.Add('Edit', 'xs+230 yp-2 w50 h23 -wrap vtextBoxScale')
        this.gMain.txt_textRendering := this.gMain.Add('Text', 'xs +0x0100', 'Rendering:')
        this.gMain.ddl_textRendering := this.gMain.Add('DropDownList', 'xs+95 yp-2 w50 vtextRendering', this.arrTextRendering)
        this.gMain.ddl_textRendering.OnEvent('Change', this.gMain_UpdateTextPreview.Bind(this))
        this.gMain.txt_textYRatio := this.gMain.Add('Text', 'xs+160 yp+2 +0x0100', 'Y Ratio:')
        this.gMain.edit_textYRatio := this.gMain.Add('Edit', 'xs+230 yp-2 w50 h23 -wrap vtextYRatio')
        this.gMain.pic_textInfo := this.gMain.Add('Picture', 'xs+38 ys-23 w15 h15 +0x0100', this.mIcons['iSmall'])
        this.gMain.btn_resetText := this.gMain.Add('Button', 'xs+' gbWidthText - 43 ' ys-27 w22 h22')
        this.gMain.btn_resetText.OnEvent('Click', this.gMain_btn_resetText_Click.Bind(this))
        GuiButtonIcon(this.gMain.btn_resetText, this.mIcons['reset'], 1, 's12')

        gbWidthRendering := 175
        gbHeightRendering := 86

        this.gMain.gb_rendering := this.gMain.Add('GroupBox',  'xm+' gbWidthMisc + gbWidthText + this.gMain.MarginX*2 ' ym+' gbHeightImages + this.gMain.MarginY
            ' w' gbWidthRendering ' h' gbHeightRendering ' cBlack', 'Rendering')
        this.gMain.txt_smoothingMode := this.gMain.Add('Text', 'xp+8 yp+28 Section +0x0100', 'Smoothing Mode:')
        this.gMain.ddl_smoothingMode := this.gMain.Add('DropDownList', 'xs+116 yp-2 w40 vsmoothingMode', this.arrSmoothingMode)
        this.gMain.txt_interpolationMode := this.gMain.Add('Text', 'xs +0x0100', 'Interpolation Mode:')
        this.gMain.ddl_interpolationMode := this.gMain.Add('DropDownList', 'xs+116 yp-2 w40 vinterpolationMode', this.arrInterpolationMode)
        this.gMain.pic_renderingInfo := this.gMain.Add('Picture', 'xs+75 ys-26 w15 h15 +0x0100', this.mIcons['iSmall'])
        this.gMain.btn_resetRendering := this.gMain.Add('Button', 'xs+' gbWidthRendering - 41 ' ys-30 w22 h22')
        this.gMain.btn_resetRendering.OnEvent('Click', this.gMain_btn_resetRendering_Click.Bind(this))
        GuiButtonIcon(this.gMain.btn_resetRendering, this.mIcons['reset'], 1, 's12')
        this.gMain.btn_exit := this.gMain.Add('Button', 'xm+' gbWidthMisc + gbWidthText + this.gMain.MarginX*5 ' ym+' gbHeightImages + gbHeightText - this.gMain.MarginY*16 ' w100 h100', 'Exit')
        this.gMain.btn_exit.SetFont('bold')
        this.gMain.btn_exit.OnEvent('Click', (*) => ExitApp())
        GuiButtonIcon(this.gMain.btn_exit, this.mIcons['exitBig'], 1, 's45 a2 t18 l2')

        this.DDLChoose(this.user.skin, this.arrSkins, this.gMain.ddl_skins)
        this.gMain['soundOnSelection'].Value := this.user.soundOnSelection

        for value in ['text', 'sound', 'image', 'skin', 'misc', 'rendering']
            this.gMain.gb_%value%.SetFont('bold')

        ;==============================================

        txt_itemGlowImage := '➤ ItemGlowImage - Glow effect image on hover.'
        txt_menuOuterRimImage := '➤ MenuOuterRimImage - Image for the outer rim of the menu.'
        txt_menuBackgroundImage := '➤ MenuBackgroundImage - Background image of the menu.'
        txt_itemBackgroundImage := '➤ ItemBackgroundImage - Background image for individual menu items.'
        txt_centerBackgroundImage := '➤ CenterBackgroundImage - Background image for the center.'
        txt_centerImage := '➤ CenterImage - Image shown in the center of the menu.'
        txt_submenuIndicatorImage := '➤ SubmenuIndicatorImage - Icon indicating a submenu.'
        txt_soundOnSelect := '➤ SoundOnSelect - Sound played when an item is selected.'
        txt_soundOnShow := '➤ SoundOnShow - Sound played when the menu opens.'
        txt_soundOnClose := '➤ SoundOnClose - Sound played when the menu closes.'
        txt_soundOnSubShow := '➤ SoundOnSubShow - Sound played when a submenu opens.'
        txt_soundOnSubClose := '➤ SoundOnSubClose - Sound played when a submenu closes.'

        tips := {
            SmoothingMode: '
            (
                ➤ SmoothingMode - Shape rendering mode:
                    • 0 - Default
                    • 1 - High Speed
                    • 2 - High Quality
                    • 3 - None
                    • 4 - AntiAlias
            )',
            InterpolationMode: '
            (
                ➤ InterpolationMode - Image scaling quality:
                    • 0 - Default
                    • 1 - Low Quality
                    • 2 - High Quality
                    • 3 - Bilinear
                    • 4 - Bicubic
                    • 5 - Nearest Neighbor
                    • 6 - High Quality Bilinear
                    • 7 - High Quality Bicubic
            )',
            textRendering: '
            (
                ➤ TextRendering - Rendering quality for text:
                    • 0 - Default
                    • 1 - SingleBitPerPixelGridFit
                    • 2 - SingleBitPerPixel
                    • 3 - AntiAliasGridFit
                    • 4 - AntiAlias
                    • 5 - ClearTypeGridFit
            )',
            predefinedActions: '
            (
                Predefined Actions:
                • Close - Closes the entire menu tree.
                • CloseMenu - Closes only the current menu.
                • Drag - Makes the menu draggable.
            )'
        }

        miscTips := [
            ['txt_ItemSize', '➤ ItemSize - Size of menu items (' Radify.range.itemSize[1] '-' Radify.range.itemSize[2] ' px).'],
            ['txt_radiusScale', '➤ RadiusScale - Spacing between rings (' Radify.range.radiusScale[1] '-' Radify.range.radiusScale[2] ').'],
            ['txt_centerSize', '➤ CenterSize - Size of center area (' Radify.range.centerSize[1] '-' Radify.range.centerSize[2] ' px).'],
            ['txt_centerImageScale', '➤ CenterImageScale - Scale of center image (' Radify.range.centerImageScale[1] '-' Radify.range.centerImageScale[2] ').'],
            ['txt_itemImageScale', '➤ ItemImageScale - Scale of item image (' Radify.range.itemImageScale[1] '-' Radify.range.itemImageScale[2] ').'],
            ['txt_itemImageYRatio', '➤ ItemImageYRatio - Y-position of item image (' Radify.range.itemImageYRatio[1] '-' Radify.range.itemImageYRatio[2] ').'],
            ['txt_submenuIndicatorSize', '➤ SubmenuIndicatorSize - Size of submenu icon (' Radify.range.submenuIndicatorSize[1] '-' Radify.range.submenuIndicatorSize[2] ' px).'],
            ['txt_submenuIndicatorYRatio', '➤ SubmenuIndicatorYRatio - Y-position of submenu icon (' Radify.range.submenuIndicatorYRatio[1] '-' Radify.range.submenuIndicatorYRatio[2] ').'],
            ['txt_outerRimWidth', '➤ OuterRimWidth - Width of outer rim (' Radify.range.outerRimWidth[1] '-' Radify.range.outerRimWidth[2] ' px).'],
            ['txt_outerRingMargin', '➤ OuterRingMargin - Margin between the outermost ring and the edge of the menu (' Radify.range.outerRingMargin[1] '-' Radify.range.outerRingMargin[2] ' px).'],
            ['cb_alwaysOnTop', '➤ AlwaysOnTop - Keeps the menu always on top.'],
            ['cb_activateOnShow', '➤ ActivateOnShow - Activates menu window on show.'],
            ['cb_enableTooltip', '➤ EnableTooltip - Enables tooltips for menu items.'],
            ['cb_enableGlow', '➤ EnableGlow - Enables glow effect on hover.'],
            ['cb_autoTooltip', '➤ AutoTooltip - Generates the tooltip text if "Tooltip" is not set, based on item text or image name.'],
            ['cb_autoCenterMouse', '➤ AutoCenterMouse - Center mouse cursor when showing menu.'],
            ['txt_menuClick', '➤ MenuClick - Action to execute when clicking the menu background.'],
            ['txt_menuRightClick', '➤ MenuRightClick - Action to execute when right-clicking the menu background.'],
            ['txt_centerClick', '➤ CenterClick - Action to execute when clicking the center area.'],
            ['txt_centerRightClick', '➤ CenterRightClick - Action to execute when right-clicking the center area.'],
            ['cb_closeOnItemClick', '➤ CloseOnItemClick - Closes the entire menu tree when a menu item is clicked.'],
            ['cb_closeOnItemRightClick', '➤ CloseOnItemRightClick - Closes the entire menu tree when a menu item is right-clicked.'],
            ['cb_mirrorClickToRightClick', '➤ MirrorClickToRightClick - Automatically assigns the "Click" function to "RightClick".'],
            ['cb_closeMenuBlock', '➤ CloseMenuBlock - Prevents the menu from closing. See the documentation for details.'],
            ['cb_enableItemText', '➤ EnableItemText - Shows text labels on menu items.'],
            ['cb_itemBackgroundImageOnCenter', '➤ ItemBackgroundImageOnCenter - Apply item background image to the center.'],
            ['cb_itemBackgroundImageOnItems', '➤ ItemBackgroundImageOnItems - Apply item background image to all menu items.'],
        ]

        textTips := [
            ['txt_textFont', '➤ TextFont - Font name.'],
            ['txt_textColor', '➤ TextColor - Font color in hex (e.g., "FFFFFF").'],
            ['txt_textSize', '➤ TextSize - Font size (' Radify.range.textSize[1] '-' Radify.range.textSize[2] ' px).'],
            ['txt_textShadowColor', '➤ TextShadowColor - Shadow color in hex (e.g., "000000").'],
            ['txt_textShadowOffset', '➤ TextShadowOffset - Shadow offset (' Radify.range.textShadowOffset[1] '-' Radify.range.textShadowOffset[2] ' px).'],
            ['txt_textBoxScale', '➤ TextBoxScale - Text box scale (' Radify.range.textBoxScale[1] '-' Radify.range.textBoxScale[2] ').'],
            ['txt_textYRatio', '➤ TextYRatio - Text Y-position (' Radify.range.textYRatio[1] '-' Radify.range.textYRatio[2] ').'],
            ['txt_textRendering', tips.textRendering],
        ]

        this.gMain.Tips.SetTip(this.gMain.btn_textColorSelect, 'Open the color selector.')
        this.gMain.Tips.SetTip(this.gMain.btn_textColorPicker, 'Pick color from screen.')
        this.gMain.Tips.SetTip(this.gMain.btn_copyFont, 'Copy font name to clipboard.')
        this.gMain.Tips.SetTip(this.gMain.btn_textShadowColorSelect, 'Open the color selector.')
        this.gMain.Tips.SetTip(this.gMain.btn_shadowColorPicker, 'Pick color from screen.')
        this.gMain.Tips.SetTip(this.gMain.btn_copySkin, 'Copy skin name to clipboard.')
        this.gMain.Tips.SetTip(this.gMain.btn_gList_Show, 'Remove media files from history (images and sounds).')
        this.gMain.Tips.SetTip(this.gMain.btn_gDir_Show, 'Set media directories for images and sounds.')
        this.gMain.Tips.SetTip(this.gMain.btn_about, 'About')
        this.gMain.Tips.SetTip(this.gMain.btn_gitHub, 'Open the GitHub repository for this project.')
        this.gMain.Tips.SetTip(this.gMain.btn_donate, 'Donate to support the project.')
        txt_btnReset := 'Reset to the skin`'s settings, or to the default settings`nif none are defined for the skin.'

        for key in ['itemGlowImage', 'menuOuterRimImage', 'menuBackgroundImage', 'itemBackgroundImage', 'centerBackgroundImage', 'centerImage', 'submenuIndicatorImage'] {
            for (value in ['pic', 'txt'])
                this.gMain.Tips.SetTip(this.gMain.%value%_%key%, txt_%key%)

            this.gMain.Tips.SetTip(this.gMain.btn_browse_%key%, 'Browse image')
            this.gMain.Tips.SetTip(this.gMain.btn_copyImage_%key%, 'Copy image to clipboard.')
            this.gMain.Tips.SetTip(this.gMain.btn_resetImage_%key%, txt_btnReset)
            strTxtImage .= txt_%key% '`n'
        }

        strTxtImage .= '`nDouble-click the image to open the skin folder.'

        for (key in Radify.arrKeysSound) {
            this.gMain.Tips.SetTip(this.gMain.btn_browse_%key%, 'Browse sound')
            this.gMain.Tips.SetTip(this.gMain.btn_playsound_%key%, 'Play sound')
            this.gMain.Tips.SetTip(this.gMain.btn_copySound_%key%, 'Copy sound to clipboard.')
            this.gMain.Tips.SetTip(this.gMain.txt_%key%, txt_%key%)
            strTxtSound .= txt_%key% '`n'
        }

        for (item in miscTips) {
            key := item[1]
            value := item[2]
            this.gMain.Tips.SetTip(this.gMain.%key%, value)
            strTxtMisc .= value '`n'
        }

        strTxtMisc .= '`n' tips.predefinedActions

        for (item in textTips) {
            key := item[1]
            value := item[2]
            this.gMain.Tips.SetTip(this.gMain.%key%, value)
            strTxtText .= value '`n'
        }

        strTxtText .= '➤ TextFontOptions - Font styles (e.g., "bold italic").'

        this.gMain.Tips.SetTip(this.gMain.pic_textInfo, strTxtText)
        this.gMain.Tips.SetTip(this.gMain.pic_imageInfo, strTxtImage)
        this.gMain.Tips.SetTip(this.gMain.pic_soundInfo, strTxtSound)
        this.gMain.Tips.SetTip(this.gMain.pic_miscInfo, strTxtMisc)
        this.gMain.Tips.SetTip(this.gMain.btn_resetMisc, txt_btnReset)
        this.gMain.Tips.SetTip(this.gMain.btn_resetImage, txt_btnReset)
        this.gMain.Tips.SetTip(this.gMain.btn_resetSound, txt_btnReset)
        this.gMain.Tips.SetTip(this.gMain.btn_resetText, txt_btnReset)
        this.gMain.Tips.SetTip(this.gMain.txt_smoothingMode, tips.SmoothingMode)
        this.gMain.Tips.SetTip(this.gMain.txt_interpolationMode, tips.InterpolationMode)
        this.gMain.Tips.SetTip(this.gMain.pic_renderingInfo, tips.SmoothingMode '`n' tips.InterpolationMode)
        this.gMain.Tips.SetTip(this.gMain.btn_resetRendering, txt_btnReset)

        this.gMain_SetTip_btn_saveDefaultSkin()

        ;==============================================

        this.UpdateControls([this.user.skin])
        this.gMain.Show()
        try ControlFocus(this.gMain.btn_exit.hwnd, this.gMain.hwnd)
    }

    ;=============================================================================================

    static UpdateControls(arrParams, *)
    {
        skin := arrParams[1]
        skinObj := Radify.skins.%skin%
        this.gMain_SetMisc(skin, skinObj)
        this.gMain_SetImage(skin, skinObj)
        this.gMain_SetSound(skinObj)
        this.gMain_SetText(skin, skinObj)
        this.gMain_UpdateTextPreview()
        this.gMain_SetRendering(skin, skinObj)
        this.gMain_SetTip_btn_resettAll(skin)
        this.gMain_SetTip_btn_editSkin(skin)
    }

    ;=============================================================================================

	static gMain_ddl_skins_Change(arrParams, *)
    {
        skinName := this.user.%arrParams[1]% := this.gMain[arrParams[1]].Text
        this.UpdateControls([skinName])
	}

    ;=============================================================================================

    static gMain_btn_resetSound_Click(*)
    {
        skinObj := this.gMain_GetSkinObject(this.gMain.ddl_skins.Text)
        this.gMain_SetSound(skinObj)
    }

    ;=============================================================================================

    static gMain_ddl_sound_Change(arrParams, *)
    {
        ctrlName := arrParams[1]
        sound := this.gMain.ddl_%ctrlName%.Text
        this.gMain_SetTip_ddl_sound(sound, ctrlName)

        if (this.user.soundOnSelection)
            this.gMain_PlaySound(ctrlName)
    }

    ;=============================================================================================

    static gMain_cb_soundOnSelection_Click(guiCtrlObj, *) => (this.user.soundOnSelection := guiCtrlObj.Value)

    ;=============================================================================================

    static gMain_SetSound(skinObj, key?, *)
    {
        keysToProcess := IsSet(key) ? [key] : Radify.arrKeysSound

        for (soundKey in keysToProcess) {
            this.DDLchoose(skinObj.%soundKey%, this.arrSound, this.gMain.ddl_%soundKey%)
            this.gMain_SetTip_ddl_sound(skinObj.%soundKey%, soundKey)
        }
    }

    ;=============================================================================================

    static gMain_SetTip_ddl_sound(txtSound, ctrlName)
    {
        this.gMain.ddl_%ctrlName%.GetPos(,, &ctrlWidth)
        txtTip := (this.ControlGetTextWidth(this.gMain.ddl_%ctrlName%.hwnd, txtSound)) > (ctrlWidth - 25) ? txtSound : 'Drag and drop wav files here.'
        this.gMain.Tips.SetTip(this.gMain.ddl_%ctrlName%, txtTip)
    }

    ;=============================================================================================

    static gMain_ddl_image_Change(arrParams, *)
    {
        ctrlName := arrParams[1]
        image := this.gMain.ddl_%ctrlName%.Text
        skin := this.gMain.ddl_skins.Text
        skinDir := Radify.rootDir '\skins\' skin '\'
        this.gMain_LoadSetImage(image, skinDir, ctrlName)
    }

    ;=============================================================================================

    static gMain_SetImage(skin, skinObj, ctrlName?)
    {
        keysToProcess := IsSet(ctrlName) ? [ctrlName] : this.arrkeysImage
        skinDir := Radify.rootDir '\skins\' skin '\'

        for (ctrlName in keysToProcess) {
            skinDir := Radify.rootDir '\skins\' skin '\'
            this.gMain_LoadSetImage(skinObj.%ctrlName%, skinDir, ctrlName)
            this.DDLchoose(skinObj.%ctrlName%, this.arrImage, this.gMain.ddl_%ctrlName%)
        }
    }

    ;=============================================================================================

    static gMain_LoadSetImage(image, skinDir, ctrlName)
    {
        this.gMain.ddl_%ctrlName%.GetPos(,, &ctrlWidth)
        txtTip := (this.ControlGetTextWidth(this.gMain.ddl_%ctrlName%.hwnd, image)) > (ctrlWidth - 25) ? image : 'Drag and drop images here.'
        this.gMain.Tips.SetTip(this.gMain.ddl_%ctrlName%, txtTip)
        pBitmap := Radify.LoadImage(image, skinDir)
        this.gMain.pic_%ctrlName%.Value := ((hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)) ? 'HBITMAP:*' hBitmap : this.mIcons['transIcon'])
        Gdip_DisposeImage(pBitmap)
        DeleteObject(hBitmap)
    }

    ;=============================================================================================

    static gMain_btn_resetImage_Click(ctrlName, *)
    {
        skin := this.gMain.ddl_skins.Text
        skinObj := Radify.skins.%skin%
        this.gMain_SetImage(skin, skinObj, ctrlName)
    }

    ;=============================================================================================

    static gMain_btn_resetImageAll_Click(*)
    {
        skin := this.gMain.ddl_skins.Text
        skinObj := Radify.skins.%skin%
        this.gMain_SetImage(skin, skinObj)
    }

    ;=============================================================================================

    static gMain_SetTip_ddl_image(image, ctrlName)
    {
        this.gMain.ddl_%ctrlName%.GetPos(,, &ctrlWidth)
        txtTip := (this.ControlGetTextWidth(this.gMain.ddl_%ctrlName%.hwnd, image)) > (ctrlWidth - 25) ? image : 'Drag and drop images here.'
        this.gMain.Tips.SetTip(this.gMain.ddl_%ctrlName%, txtTip)
    }

    ;=============================================================================================

    static gMain_btn_resetText_Click(*)
    {
        skin := this.gMain.ddl_skins.Text
        skinObj := Radify.skins.%skin%
        this.gMain_SetText(skin, skinObj)
    }

    ;=============================================================================================

    static gMain_SetText(skin, skinObj, *)
    {
        for key in ['textRendering', 'textFont', 'textShadowOffset']
            this.DDLchoose(skinObj.%key%, this.arr%key%, this.gMain.ddl_%key%)

        for key in ['textSize', 'textBoxScale', 'textYRatio', 'textShadowColor', 'textColor', 'textShadowColor']
            this.gMain[key].Value := Radify.CapDecimals(skinObj.%key%, 2)

        for value in ['bold', 'italic', 'strikeout', 'underline']
            this.gMain.cb_%value%.Value := (InStr(skinObj.textFontOptions, value) ? 1 : 0)

        this.gMain_UpdateTextPreview()
    }

    ;=============================================================================================

    static gMain_SetRendering(skin, skinObj)
    {
        for key in ['smoothingMode', 'interpolationMode']
            this.DDLchoose(skinObj.%key%, this.arr%key%, this.gMain.ddl_%key%)
    }
    ;=============================================================================================

    static gMain_btn_resetRendering_Click(*)
    {
        skin := this.gMain.ddl_skins.Text
        skinObj := Radify.skins.%skin%
        this.gMain_SetRendering(skin, skinObj)
    }

    ;=============================================================================================

    static gMain_SetMisc(skin, skinObj)
    {
        for key in ['activateOnShow', 'alwaysOnTop', 'autoCenterMouse', 'autoTooltip', 'centerSize', 'closeOnItemClick',
        'closeOnItemRightClick', 'mirrorClickToRightClick', 'enableGlow', 'enableTooltip', 'itemBackgroundImageOnCenter',
        'itemBackgroundImageOnItems', 'itemSize', 'outerRingMargin', 'outerRimWidth' , 'closeMenuBlock', 'enableItemText', 'submenuIndicatorSize']
            this.gMain[key].Value := skinObj.%key%

        for key in ['menuClick', 'menuRightClick', 'centerClick', 'centerRightClick']
            this.DDLchoose(skinObj.%key%, this.arrClick, this.gMain.ddl_%key%)

        for key in ['itemImageScale', 'radiusScale', 'centerImageScale', 'itemImageYRatio', 'submenuIndicatorYRatio']
            this.gMain[key].Value := Round(skinObj.%key%, 2)
    }

    ;=============================================================================================

    static gMain_btn_resetMisc_Click(*)
    {
        skin := this.gMain.ddl_skins.Text
        skinObj := Radify.skins.%skin%
        this.gMain_SetMisc(skin, skinObj)
    }

    ;=============================================================================================

    static gMain_btn_saveDefaultSkin_Click(*)
    {
        skin := this.gMain.ddl_skins.Text

        if (skin = 'default' || skin = Radify.defaults.skin)
            return

        Radify.defaults.skin := Radify.skins.default.skin := skin
        this.SaveToJSONpreferences()
        title := 'Default Skin Updated'
        msg := 'The skin "' skin '" has been set as the default.'
        this.ShowNotify(title, msg)
        this.gMain_SetTip_btn_saveDefaultSkin()
    }

    ;=============================================================================================

    static gMain_btn_browse(param, *) => this.ProcessFileInput(, param,, 'btn_browse')

    ;=============================================================================================

    static gMain_DropFiles(guiObj, objCtrl, arrFile, x, y) => this.ProcessFileInput(guiObj, objCtrl, arrFile, 'dropFiles')

    ;=============================================================================================

    static ProcessFileInput(guiObj:='', param:='', arrFile := Array(), fromMethod:='')
    {
        arrSoundCtrlName := ['soundOnSelect', 'soundOnShow', 'soundOnClose', 'soundOnSubShow', 'soundOnSubClose']
        arrImageCtrlName := this.ObjectToArray(Radify.imageKeyToFileName)
        isSound := false

        switch {
            case Type(param) = 'String': paramName := param
            case Type(param) = 'Gui.DDL': paramName := param.Name
            default: paramName := ''
        }

        if (!RegExMatch(paramName, '^(' this.strKeysSoundPipeDelim '|' this.strKeysImagePipeDelim ')$'))
            return

        if (RegExMatch(paramName, '^(' this.strKeysSoundPipeDelim ')$'))
            isSound := true

        switch fromMethod {
            case 'btn_browse':
            {
                this.gMain.Opt('+OwnDialogs')
                fileFilter := (isSound ? 'Sound (*.wav)' : this.strImageExtfilter)
                arrFile := FileSelect('M3',, 'Select ' (isSound ? 'Sound' : 'Image') ' - ' this.scriptName, fileFilter)
            }
            case 'dropFiles': param := param.Name
        }

        if (arrFile.Length) {
            for index, fPath in arrFile.Clone() {
                RegExMatch(fPath, 'i)^.+\.(dll|exe|cpl)\|icon\d+$', &matchExt) ? ext := matchExt[1] : SplitPath(fPath,,, &ext)

                if (isSound && ext != 'wav') || (Radify.imageKeyToFileName.HasOwnProp(param) && !RegExMatch(ext, 'i)^(' Radify.strImageExt ')$'))
                    index := this.HasVal(fPath, arrFile), arrFile.RemoveAt(index)
            }

            if (!arrFile.Length)
                return

            strArr := (isSound ? 'sound' : 'image')

            for index, fPath in arrFile
                if (!this.Hasval(fPath, this.arr%strArr%))
                    this.arr%strArr%.Push(fPath), lastPath := fPath

            this.arr%strArr% := this.SortArray(this.arr%strArr%)

            if (idx := this.HasVal(param, arr%strArr%CtrlName))
                arr%strArr%CtrlName.RemoveAt(idx)

            for (ctrlName in arr%strArr%CtrlName) {
                txt := this.gMain.ddl_%ctrlName%.Text
                this.DDLArrayChange_Choose(txt, this.arr%strArr%, this.gMain.ddl_%ctrlName%), SetImage_SetSound(txt, ctrlName)
            }

            if (IsSet(lastPath))
                this.DDLArrayChange_Choose(lastPath, this.arr%strArr%, this.gMain.ddl_%param%), SetImage_SetSound(lastPath, param)
            else
                this.DDLchoose(arrFile[1], this.arr%strArr%, this.gMain.ddl_%param%), SetImage_SetSound(arrFile[1], param)
        }

        SetImage_SetSound(file, ctrlName) {
            if (isSound)
                this.gMain_SetTip_ddl_sound(file, ctrlName)
            else {
                skin := this.gMain.ddl_skins.Text
                skinDir := Radify.rootDir '\skins\' skin '\'
                this.gMain_LoadSetImage(file, skinDir, ctrlName)
            }
        }
    }

    ;=============================================================================================

    static gMain_btn_colorPicker_Click(param, *)
    {
        color := ColorPicker.Run(False)

        if (color) {
            hex := color.ToHex('{R}{G}{B}')
            this.gMain.edit_%param%.Value := hex.Full
            this.gMain_UpdateTextPreview()
        }
    }

    ;=============================================================================================

    static gMain_UpdateTextPreview(*)
    {
        static textSize := 30
        static sampleText := 'AaBbYyZz'
        textColor := this.gMain.edit_textColor.Value
        textFont := this.gMain.ddl_textFont.Text
        textShadowOffset := this.gMain.ddl_textShadowOffset.Value
        textShadowColor := this.gMain.edit_textShadowColor.Value
        textRendering := this.gMain.ddl_textRendering.Text
        textFontOptions := this.BuildFontOptionsString()

        pBitmap := Gdip_CreateBitmap(this.picWidth, this.picHeight)
        pGraphics := Gdip_GraphicsFromImage(pBitmap)
        Gdip_SetSmoothingMode(pGraphics, 4)
        Gdip_SetInterpolationMode(pGraphics, 7)
        pBrushWhite := Gdip_BrushCreateSolid('0xFFFFFFFF')
        Gdip_FillRectangle(pGraphics, pBrushWhite, 0, 0, this.picWidth, this.picHeight)
        Gdip_DeleteBrush(pBrushWhite)

        argbColor := 'FF' . textColor
        argbShadowColor := 'FF' . textShadowColor
        Gdip_SetTextRenderingHint(pGraphics, textRendering)

        textBoxWidth := this.picWidth - 10
        textBoxHeight := this.picHeight - 10
        textBoxX := 5
        textBoxY := 5

        hFamily := Gdip_FontFamilyCreate(textFont)
        hFont := Gdip_FontCreate(hFamily, textSize, 0)
        hFormat := Gdip_StringFormatCreate(0x4000) ; StringFormatFlagsNoWrap
        Gdip_SetStringFormatAlign(hFormat, 1)      ; Center alignment
        CreateRectF(&RC, 0, 0, textBoxWidth, textBoxHeight)
        ReturnRC := Gdip_MeasureString(pGraphics, sampleText, hFont, hFormat, &RC)
        textRC := StrSplit(ReturnRC, '|')
        textHeight := textRC[4]
        textBoxY := (this.picHeight - textHeight) / 2

        if (textShadowOffset > 0) {
            shadowX := textBoxX + textShadowOffset
            shadowY := textBoxY + textShadowOffset
            shadowOptions := 'x' . shadowX . ' y' . shadowY . ' w' . textBoxWidth . ' h' . textBoxHeight . ' Center '
            shadowOptions .= 'c' . argbShadowColor
            shadowOptions .= ' s' . textSize
            shadowOptions .= ' r' . textRendering

            if (textFontOptions)
                shadowOptions .= textFontOptions

            Gdip_TextToGraphics(pGraphics, sampleText, shadowOptions, textFont, textBoxWidth, textBoxHeight)
        }

        textOptionsStr := 'x' . textBoxX . ' y' . textBoxY . ' w' . textBoxWidth . ' h' . textBoxHeight . ' Center '
        textOptionsStr .= 'c' . argbColor
        textOptionsStr .= ' s' . textSize
        textOptionsStr .= ' r' . textRendering

        if (textFontOptions)
            textOptionsStr .= textFontOptions

        Gdip_TextToGraphics(pGraphics, sampleText, textOptionsStr, textFont, textBoxWidth, textBoxHeight)

        Gdip_DeleteStringFormat(hFormat)
        Gdip_DeleteFont(hFont)
        Gdip_DeleteFontFamily(hFamily)

        hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
        this.gMain.pic_preview.Value := 'HBITMAP:*' hBitmap

        DeleteObject(hBitmap)
        Gdip_DisposeImage(pBitmap)
        Gdip_DeleteGraphics(pGraphics)
    }

    ;=============================================================================================

    static gMain_ClampToMaximum_Change(arrParams, *)
    {
        setting := arrParams[1]

        if (txt := this.gMain.edit_%setting%.Text) = ''
            return

        if (txt > Radify.range.%setting%[2])
            this.gMain.edit_%setting%.Text := Radify.range.%setting%[2]
    }

    ;=============================================================================================

    static gMain_GetDisplayName(key)
    {
        for settings in this.arrSettings
            if (settings[2] = key)
                return settings[1]
    }

    ;=============================================================================================

    static gMain_OpenSkinFolder(*)
    {
        skin := this.gMain.ddl_skins.Text
        try Run(Radify.skinsDir skin)
        catch
            return
    }

    ;=============================================================================================

    static gMain_GetSkinObject(skin) => Radify.skins.%skin%

    ;=============================================================================================

    static gMain_SetTip_btn_saveDefaultSkin() => this.gMain.Tips.SetTip(this.gMain.btn_saveDefaultSkin, 'Set as default skin (Current: ' Radify.defaults.skin ')')

    ;=============================================================================================

    static gMain_SetTip_btn_editSkin(skin) => this.gMain.Tips.SetTip(this.gMain.btn_editSkin, skin = 'default' ? 'Edit default settings.' : 'Edit skin')

    ;=============================================================================================

    static gMain_SetTip_btn_resettAll(skin) => this.gMain.Tips.SetTip(this.gMain.btn_resettAll, 'Reset all to the current ' (skin = 'default' ? 'default' : 'skin') ' settings.')

    ;=============================================================================================

    static gSkin_Show(*)
    {
        skin := this.gMain.ddl_skins.Text
        strTitle := (skin = 'default' ? 'Edit Default Settings' : 'Edit Skin')

        this.gSkin := Gui('-MinimizeBox', strTitle ' - ' this.scriptName)
        this.gSkin.Opt('+Resize +MinSize540x525')
        this.gSkin.OnEvent('Size', this.gSkin_Size.Bind(this))
        this.gSkin.SetFont('s10')
        this.gSkin.BackColor := 'White'
        this.gSkin.Tips := GuiCtrlTips(this.gSkin)
        this.gSkin.Tips.SetDelayTime('AUTOPOP', 30000)
        try this.gMain.Opt('+Disabled')
        try this.gSkin.Opt('+Owner' this.gMain.hwnd)

        lvWidth := 675
        this.gSkin.lvHeight := 500
        btnSize := 30
        gbWidth := (skin = 'default' ? 500 : 328)
        this.gSkin.gbHeight := 60

        this.gSkin.gb_skin := this.gSkin.Add('GroupBox',  'w' gbWidth ' h' this.gSkin.gbHeight ' cBlack', (skin = 'default' ? '' : '    Skin'))
        skin = 'default' ? (picPos := 'xp+8 yp+25', editPos := 'x+6 yp-2') : (picPos := 'xs+6 ys+1', editPos := 'xp+6 yp+22')
        this.gSkin.pic_edit := this.gSkin.Add('Picture', picPos ' w16 h16 ' (skin = 'default' ? 'Section': '') , this.mIcons['btn_edit'])
        this.gSkin.edit_skinName := this.gSkin.Add('Edit', editPos ' w165 h23 -wrap', skin)

        if (skin != 'default')
        {
            this.gSkin.btn_checkAll := this.gSkin.Add('Button', 'x+5 yp-3 w' btnSize ' h' btnSize)
            this.gSkin.btn_checkAll.OnEvent('Click', this.gSkin_CheckAll_UncheckAll.Bind(this, skin, 'checkAll'))
            GuiButtonIcon(this.gSkin.btn_checkAll, this.mIcons['checkAll'], 1, 's20')
            this.gSkin.btn_checkBasic := this.gSkin.Add('Button', 'x+5 w' btnSize ' h' btnSize)
            this.gSkin.btn_checkBasic.OnEvent('Click', this.gSkin_Check_Basic_Skin.Bind(this, skin, 'basic'))
    		GuiButtonIcon(this.gSkin.btn_checkBasic, this.mIcons['checkBasic'], 1, 's20')
            this.gSkin.Tips.SetTip(this.gSkin.btn_checkAll, 'Check All')
            this.gSkin.Tips.SetTip(this.gSkin.btn_checkBasic, 'Check basic skin settings.')
            this.gSkin.btn_checkSkin := this.gSkin.Add('Button', 'x+5 w' btnSize ' h' btnSize)
            this.gSkin.btn_checkSkin.OnEvent('Click', this.gSkin_Check_Basic_Skin.Bind(this, skin, 'skin'))
    		GuiButtonIcon(this.gSkin.btn_checkSkin, this.mIcons['checkSkin'], 1, 's20')
            this.gSkin.Tips.SetTip(this.gSkin.btn_checkSkin, 'Check the current skin`'s settings.')
            this.gSkin.btn_resetSkinOrig := this.gSkin.Add('Button', 'x+5 w' btnSize ' h' btnSize)
            this.gSkin.btn_resetSkinOrig.OnEvent('Click', this.gSkin_btn_resetOriginalsSkin_Click.Bind(this, skin))
            this.gSkin.txt_resetSkinOrig := this.gSkin.AddText('xp yp wp hp BackgroundTrans +0x100')
    		GuiButtonIcon(this.gSkin.btn_resetSkinOrig, this.mIcons['resetSkin'], 1, 's20')

            for value in ['txt', 'btn']
                this.gSkin.Tips.SetTip(this.gSkin.%value%_resetSkinOrig, 'Reset skin to its original settings.')
        }
        else {
            this.gSkin.txt_defSkin := this.gSkin.Add('Text', 'x+15 yp+2', 'Default skin:')
            this.gSkin.ddl_defSkin := this.gSkin.Add('DropDownList', 'x+8 yp-2 vdefSkin', this.arrSkinsNoDefault)
            this.gSkin.ddl_defSkin.OnEvent('Change', this.DebounceCall.Bind(this, 125, 'gSkin_ddl_defSkin_Change'))
            this.DDLchoose(Radify.defaults.skin, this.arrSkinsNoDefault, this.gSkin.ddl_defSkin)
            this.gSkin.btn_resetDefOrig := this.gSkin.Add('Button', 'x+8 yp-2 w' btnSize ' h' btnSize)
            this.gSkin.btn_resetDefOrig.OnEvent('Click', this.gSkin_btn_resetOriginalDefaults_Click.Bind(this, skin))
            this.gSkin.txt_resetDefOrig := this.gSkin.AddText('xp yp wp hp BackgroundTrans +0x100') ; to show the tooltip even if the control is disabled.
            GuiButtonIcon(this.gSkin.btn_resetDefOrig, this.mIcons['resetSkin'], 1, 's20')

            for value in ['txt', 'btn']
                this.gSkin.Tips.SetTip(this.gSkin.%value%_resetDefOrig, 'Reset to original settings.')
        }

        arrHeader := (skin = 'default' ? ['Setting', 'User', 'Current Default', 'Original Default'] : ['Setting', 'User', 'Current Skin', 'Original Skin', 'Current Default'])
        this.gSkin.lv := this.gSkin.Add('ListView', 'xm w' lvWidth ' h' this.gSkin.lvHeight ' Grid ' (skin = 'default' ? '' : 'Checked') ' NoSort +BackgroundEAF4FB', arrHeader)
        this.gSkin.lv.OnEvent('ItemCheck', this.gSkin_lv_ItemCheck.Bind(this, skin))

        this.gSkin.btnOCAwidth := 120
        this.gSkin.btnOCAheight := 35
        this.gSkin.cntbtns := 3
        this.gSkin.btnsOCAwidth := this.gSkin.btnOCAwidth*this.gSkin.cntbtns + this.gSkin.MarginX*(this.gSkin.cntbtns-1)
        btnOCAPos := lvWidth - this.gSkin.btnsOCAwidth + this.gSkin.MarginX
        this.gSkin.btn_ok := this.gSkin.Add('Button', 'x' btnOCAPos ' y' this.gSkin.gbHeight + this.gSkin.lvHeight + this.gSkin.MarginY*4.5
            ' w' this.gSkin.btnOCAwidth ' h' this.gSkin.btnOCAheight ' Default', 'OK')
        this.gSkin.btn_ok.OnEvent('Click', this.gSkin_btnOK_btnApply_Click.Bind(this, skin))
        this.gSkin.btn_cancel := this.gSkin.Add('Button', 'x+m w' this.gSkin.btnOCAwidth ' h' this.gSkin.btnOCAheight, 'Cancel')
        this.gSkin.btn_cancel.OnEvent('Click', this.GUI_Close.Bind(this, 'gSkin'))
        this.gSkin.OnEvent('Close', this.GUI_Close.Bind(this, 'gSkin'))
        this.gSkin.btn_apply := this.gSkin.Add('Button', 'x+m w' this.gSkin.btnOCAwidth ' h' this.gSkin.btnOCAheight, 'Apply')
        this.gSkin.btn_apply.OnEvent('Click', this.gSkin_btnOK_btnApply_Click.Bind(this, skin))

        ;==============================================

        guiValues := this.gMain.Submit(false)

        for settings in this.arrSettings {
            switch settings[2], false {
                case 'textFontOptions': user := this.BuildFontOptionsString()
                default: user := Radify.range.HasOwnProp(settings[2]) ? Radify.ClampValue(guiValues.%settings[2]%, settings[2]) : guiValues.%settings[2]%
            }
            if (skin = 'default') {
                col3 := Radify.CapDecimals(Radify.defaults.%settings[2]%)
                col4 := Radify.originalDefaults.%settings[2]%
            } else {
                col3 := this.HasVal(settings[2], Radify.skins.%skin%.skinOptionKeys) ? Radify.skins.%skin%.%settings[2]% : ''
                col4 := Radify.originalSkins.%skin%.HasOwnProp(settings[2]) ? Radify.originalSkins.%skin%.%settings[2]% : ''
                col5 := Radify.CapDecimals(Radify.defaults.%settings[2]%)
            }

            this.gSkin.lv.Add('', settings[1], user, col3, col4 ?? '', col5 ?? '')
        }

        Loop 4
            this.gSkin.lv.ModifyCol(A_Index, 'AutoHdr')

        ;==============================================

        this.skinCurrent := {}, this.skinTemp := {}

        for settings in this.arrSettings {
            key := settings[2]
            rowTxt := this.gSkin.lv.GetText(A_Index, 2)

            if (skin = 'default') {
                this.skinCurrent.%key% := Radify.defaults.%key%
                this.skinTemp.%key% := Radify.CapDecimals(rowTxt)
            }
            else {
                if (this.HasVal(key, Radify.skins.%skin%.skinOptionKeys)) {
                    this.skinCurrent.%key% := Radify.skins.%skin%.%key%
                    this.skinTemp.%key% := rowTxt
                    this.gSkin.lv.Modify(A_Index, 'Check')
                }
            }
        }

        if (skin = 'default')
            this.skinCurrent.skin := this.skinTemp.skin := Radify.defaults.skin

        this.gSkin.edit_skinName.Enabled := false
        this.gSkin.gb_skin.SetFont('bold')
        this.gSkin_EnableDisable_Btns([skin])
        LV_GridColor(this.gSkin.lv, '0xcbcbcb')
        try ControlFocus(this.gSkin.btn_ok.hwnd, this.gSkin.hwnd)
        this.ShowGUIRelativeToOwner(this.gMainTitle, 'gSkin')
    }

    ;=============================================================================================

    static gSkin_Size(guiObj, minMax, width, height)
    {
        if (minMax = -1)
            return

        cntbtns := this.gSkin.cntbtns

        this.MoveControls(
            {Control:this.gSkin.lv, h:height - this.gSkin.gbHeight - this.gSkin.btnOCAheight - this.gSkin.MarginY*6, w:width - this.gSkin.MarginX*2},
            {Control:this.gSkin.btn_ok, x:width - this.gSkin.btnOCAwidth*cntbtns - this.gMain.MarginX*cntbtns, y:height - this.gSkin.btnOCAheight - this.gSkin.MarginY*2},
            {Control:this.gSkin.btn_cancel, x:width - this.gSkin.btnOCAwidth*(cntbtns-1) - this.gMain.MarginX*(cntbtns-1), y:height - this.gSkin.btnOCAheight - this.gSkin.MarginY*2},
            {Control:this.gSkin.btn_apply, x:width - this.gSkin.btnOCAwidth - this.gMain.MarginX, y:height - this.gSkin.btnOCAheight - this.gSkin.MarginY*2}
        )

        DllCall('RedrawWindow', 'ptr', this.gSkin.hwnd, 'ptr', 0, 'ptr', 0, 'uint', 0x0081)
    }

    ;=============================================================================================

    static gSkin_btnOK_btnApply_Click(skin, ctrlObj, *)
    {
        if (ctrlObj.Text == 'OK' && !this.gSkin.btn_apply.Enabled) {
            this.GUI_Close('gSkin')
            return
        }

        Radify.skins.%skin% := {}
        skinObj := Radify.skins.%skin%

        if (skin = 'default') {
            for (settings in this.arrSettings) {
                key := settings[2]
                rowTxt := this.gSkin.lv.GetText(A_Index, 2)
                this.skinTemp.%key% := this.skinCurrent.%key% := Radify.defaults.%key% := rowTxt

                if (ctrlObj.Text == 'Apply')
                    this.gSkin.lv.Modify(A_Index, 'Col3', rowTxt)
            }

            this.skinCurrent.skin := Radify.defaults.skin := this.gSkin.ddl_defSkin.Text
        }
        else {
            skinObj.skinOptionKeys := Array()
            this.skinCurrent := {}

            for key, value in this.skinTemp.OwnProps() {
                skinObj.%key% := value
                skinObj.skinOptionKeys.Push(key)
                this.skinCurrent.%key% := value
            }

            for (settings in this.arrSettings) {
                key := settings[2]
                rowTxt := this.gSkin.lv.GetText(A_Index, 2)

                if (this.skinTemp.HasOwnProp(key)) {
                    if (ctrlObj.Text == 'Apply')
                        this.gSkin.lv.Modify(A_Index, 'Col3', rowTxt)
                } else if (ctrlObj.Text == 'Apply')
                    this.gSkin.lv.Modify(A_Index,,, Radify.CapDecimals(Radify.defaults.%key%), '')
            }
        }

        for key in Radify.imageKeyToFileName.OwnProps()
            if (this.skinCurrent.HasOwnProp(key) && !this.Hasval(this.skinCurrent.%key%, this.arrImageRadify))
                this.arrImageRadify.Push(this.skinCurrent.%key%)

        for key in Radify.arrKeysSound
            if (this.skinCurrent.HasOwnProp(key) && !this.Hasval(this.skinCurrent.%key%, this.arrSoundRadify))
                this.arrSoundRadify.Push(this.skinCurrent.%key%)

        this.ResetValues(skinObj, skin, ctrlObj.Text)
        this.SaveToJSONpreferences()
        this.gMain_SetTip_btn_saveDefaultSkin()
        this.gSkin.btn_apply.Enabled := false

        if (ctrlObj.Text == 'OK')
            this.GUI_Close('gSkin')
    }

    ;=============================================================================================

    static SaveToJSONpreferences()
    {
        m := {skins: {}, defaults: {}, generals: {soundsDir: Radify.generals.soundsDir, imagesDir: Radify.generals.imagesDir}}

        for skin, skinObj in Radify.skins.OwnProps() {
            switch skin, false {
                case 'default':
                    for key, value in skinObj.OwnProps()
                        m.defaults.%key% := value
                default:
                    m.skins.%skin% := {}
                    for k in skinObj.skinOptionKeys
                        m.skins.%skin%.%k% := skinObj.%k%
            }
        }

        for skin, skinObj in m.skins.Clone().OwnProps()
            if (!ObjOwnPropCount(skinObj))
                m.skins.DeleteProp(skin)

        if (!ObjOwnPropCount(m.skins))
            m.DeleteProp('skins')

        str := JSON_thqby_Radify.stringify(m, unset, '  ')
        objFile := FileOpen('Preferences.json', 'w', 'UTF-8')
        objFile.Write(str)
        objFile.Close()
    }

    ;=============================================================================================

    static ResetValues(skinObj, skin, txtBtn)
    {
        if (skin = 'default') {
            for key, skinObj in Radify.skins.OwnProps() {
                for k, v in skinObj.Clone().OwnProps()
                    if (!this.HasVal(k, skinObj.skinOptionKeys) && k != 'skinOptionKeys')
                        skinObj.DeleteProp(k)
                SetVariousValues(skinObj)
            }
        } else SetVariousValues(skinObj)

        this.UpdateControls([skin])

        if (txtBtn == 'Apply')
            Loop 4
                this.gSkin.lv.ModifyCol(A_Index, 'AutoHdr')

        ;==============================================

        SetVariousValues(skinObj) {
            for key, value in Radify.defaults.OwnProps()
                if (!skinObj.HasOwnProp(key))
                    skinObj.%key% := value
        }
    }

    ;=============================================================================================

    static gSkin_CheckAll_UncheckAll(skin, check, *)
    {
        this.skinTemp := {}
        this.gSkin.lv.Modify(0, (check = 'checkAll') ? 'Check' : '-Check')

        if (check == 'checkAll') {
            for (settings in this.arrSettings) {
                rowTxt := this.gSkin.lv.GetText(A_Index, 2)
                key := settings[2]
                this.skinTemp.%key% := rowTxt
            }
        }

        this.gSkin_EnableDisable_Btns([skin])
    }

    ;=============================================================================================

    static gSkin_Check_Basic_Skin(skin, param, *)
    {
        this.skinTemp := {}

        for (settings in this.arrSettings) {
            key := settings[2]
            rowTxt := this.gSkin.lv.GetText(A_Index, 2)

            if (this.HasVal(key, param = 'skin' ? Radify.skins.%skin%.skinOptionKeys : this.arrSettingsBasic))
                this.skinTemp.%key% := rowTxt

            this.gSkin.lv.Modify(A_Index, this.HasVal(key, param = 'skin' ? Radify.skins.%skin%.skinOptionKeys : this.arrSettingsBasic) ? 'Check' : '-Check')
        }

        this.gSkin_EnableDisable_Btns([skin])
    }

    ;=============================================================================================

    static gSkin_lv_ItemCheck(skin, objCtrl, item, checked, *)
    {
        key := this.arrSettings[item][2]
        rowTxt := this.gSkin.lv.GetText(item, 2)

        if (Radify.originalSkins.%skin%.HasOwnProp(key)) {
            this.gSkin.lv.Modify(item, 'Check')
            title := 'Cannot Uncheck Skin Image Setting'
            msg := 'If the image file exists in the skin folder, you cannot uncheck the corresponding skin image setting. To remove the image, set its value to "None".'
            Notify.Show(title, msg, 'none',,, this.strOpts 'theme=iDark dur=15 dg=5 tag=infoItemCheck pos=bc mali=center tali=center')
            return
        }

        checked ? this.skinTemp.%key% := rowTxt : this.skinTemp.DeleteProp(key)
        this.gSkin_EnableDisable_Btns([skin])
    }

    ;=============================================================================================

    static gSkin_ddl_defSkin_Change(*)
    {
        this.skinTemp.skin := this.gSkin.ddl_defSkin.Text
        this.gSkin_EnableDisable_Btns(['default'])
    }

    ;=============================================================================================

    static gSkin_btn_resetOriginalsSkin_Click(skin, *)
    {
        this.skinTemp := {}
        this.gSkin.lv.Modify(0, '-Check')

        for i, setting in this.arrSettings {
            key := setting[2]

            if (Radify.originalSkins.%skin%.HasOwnProp(key)) {
                fileName := Radify.imageKeyToFileName.%key%
                this.gSkin.lv.Modify(i, '+Check',, fileName, fileName)
                this.skinTemp.%key% := fileName
            } else
                this.gSkin.lv.Modify(i,,, Radify.CapDecimals(Radify.defaults.%key%), '')
        }

        this.gSkin.lv.ModifyCol(2, 'AutoHdr')
        this.gSkin.lv.ModifyCol(3, 'AutoHdr')
        this.gSkin_EnableDisable_Btns([skin])
        try ControlFocus(this.gSkin.btn_ok.hwnd, this.gSkin.hwnd)
    }

    ;=============================================================================================

    static gSkin_btn_resetOriginalDefaults_Click(skin, *)
    {
        this.skinTemp := {}

        for settings in this.arrSettings
            this.skinTemp.%settings[2]% := Radify.originalDefaults.%settings[2]%

        this.skinTemp.skin := Radify.originalDefaults.skin
        this.DDLchoose(Radify.originalDefaults.skin, this.arrSkinsNoDefault, this.gSkin.ddl_defSkin)

        if (skin = 'default')
            for settings in this.arrSettings
                this.gSkin.lv.Modify(A_Index, 'Col2', Radify.originalDefaults.%settings[2]%)

        this.gSkin.lv.ModifyCol(2, 'AutoHdr')
        this.gSkin.lv.ModifyCol(3, 'AutoHdr')
        this.gSkin_EnableDisable_Btns([skin])
        try ControlFocus(this.gSkin.btn_ok.hwnd, this.gSkin.hwnd)
    }

    ;=============================================================================================

    static gSkin_EnableDisable_Btns(arrParams, *)
    {
        skin := arrParams[1]
        this.Button_EnableDisable('gSkin', 'btn_apply', this.skinTemp, this.skinCurrent)

        if (this.ControlExist('gSkin', 'btn_resetDefOrig'))
            this.Button_EnableDisable('gSkin', 'btn_resetDefOrig', this.skinTemp, Radify.originalDefaults)

        if (this.ControlExist('gSkin', 'btn_resetSkinOrig'))
            this.Button_EnableDisable('gSkin', 'btn_resetSkinOrig', this.skinTemp, Radify.originalSkins.%skin%)
    }

    ;=============================================================================================

    static Button_EnableDisable(guiName, ctrlName, objTemp, objCurrent)
    {
        if (!this.isObjectIdentical(objTemp, objCurrent))
            enabled := true

        this.%guiName%.%ctrlName%.Enabled := enabled ?? false
    }

    ;=============================================================================================

    static gDir_Show(*)
    {
        this.gDir := Gui('-MinimizeBox', 'Directory Settings - ' this.scriptName)
        this.gDir.OnEvent('Close', this.GUI_Close.Bind(this, 'gDir'))
        this.gDir.SetFont('s10')
        this.gDir.Tips := GuiCtrlTips(this.gDir)
        this.gDir.Tips.SetDelayTime('AUTOPOP', 30000)
        try this.gMain.Opt('+Disabled')
        try this.gDir.Opt('+Owner' this.gMain.hwnd)

        btnSize := 30
        gbWidthDir := 393
        gbHeightDir := 93

        this.gDir.gb_dir := this.gDir.Add('GroupBox',  'w' gbWidthDir ' h' gbHeightDir ' cBlack Section')
        this.gDir.gb_dir.SetFont('bold')
        this.gDir.Add('Text', 'xs xp+10 yp+25 Section', 'Images:')
        this.gDir.edit_imagesDir := this.gDir.Add('Edit', 'xs+60 yp-2 w250 h23 -wrap vimagesDir', Radify.generals.imagesDir)
        this.gDir['imagesDir'].OnEvent('Change', this.DebounceCall.Bind(this, 125, 'gDir_EnableDisable_Btn'))
        this.gDir.btn_browse_imagesDir := this.gDir.Add('Button', 'x+5 yp-2 w' btnSize ' h' btnSize, '...')
        this.gDir.btn_browse_imagesDir.OnEvent('Click', this.gDir_btn_browseDir_Click.Bind(this, 'images'))
        this.gDir.btn_reset_imagesDir := this.gDir.Add('Button', 'x+5  w22 h22')
        this.gDir.btn_reset_imagesDir.OnEvent('Click', this.gDir_btn_ResetDir_Click.Bind(this, 'imagesDir'))
        GuiButtonIcon(this.gDir.btn_reset_imagesDir, this.mIcons['reset'], 1, 's12')
        this.gDir.Add('Text', 'xs', 'Sounds:')
        this.gDir.edit_soundsDir := this.gDir.Add('Edit', 'xs+60 yp-2 w250 h23 -wrap vsoundsDir', Radify.generals.soundsDir)
        this.gDir['soundsDir'].OnEvent('Change', this.DebounceCall.Bind(this, 125, 'gDir_EnableDisable_Btn'))
        this.gDir.btn_browse_soundsDir := this.gDir.Add('Button', 'x+5 yp-2 w' btnSize ' h' btnSize, '...')
        this.gDir.btn_browse_soundsDir.OnEvent('Click', this.gDir_btn_browseDir_Click.Bind(this, 'sounds'))
        this.gDir.btn_reset_soundsDir := this.gDir.Add('Button', 'x+5 w22 h22')
        this.gDir.btn_reset_soundsDir.OnEvent('Click', this.gDir_btn_ResetDir_Click.Bind(this, 'soundsDir'))
        GuiButtonIcon(this.gDir.btn_reset_soundsDir, this.mIcons['reset'], 1, 's12')
        this.gDir.pic_dirInfo := this.gDir.Add('Picture', 'xs+8 ys-24 w15 h15 +0x0100', this.mIcons['iSmall'])
        this.gDir.btnOCAwidth := 120
        this.gDir.btnOCAheight := 35
        this.gDir.cntbtns := 2
        this.gDir.btnsOCAwidth := this.gDir.btnOCAwidth*this.gDir.cntbtns + this.gDir.MarginX*(this.gDir.cntbtns-1)
        btnOCAPos := gbWidthDir - this.gDir.btnsOCAwidth + this.gDir.MarginX
        this.gDir.btn_save := this.gDir.Add('Button', 'x' btnOCAPos ' w' this.gDir.btnOCAwidth ' h' this.gDir.btnOCAheight ' Default', 'Save')
        this.gDir.btn_save.OnEvent('Click', this.gDir_btn_save_Click.Bind(this))
        this.gDir.btn_cancel := this.gDir.Add('Button', 'x+m w' this.gDir.btnOCAwidth ' h' this.gDir.btnOCAheight, 'Cancel')
        this.gDir.btn_cancel.OnEvent('Click', this.GUI_Close.Bind(this, 'gDir'))
        this.gDir.OnEvent('Close', this.GUI_Close.Bind(this, 'gDir'))

        this.gDir.gb_dir.SetFont('bold')
        this.gDir.btn_save.Enabled := false

        for (value in ['soundsDir', 'imagesDir']) {
            this.gDir.Tips.SetTip(this.gDir.btn_browse_%value%, 'Browse')
            this.gDir.Tips.SetTip(this.gDir.btn_reset_%value%, 'Reset to Default.')
        }

        this.gDir.Tips.SetTip(this.gDir.pic_dirInfo, '
        (
            Files in these folders can be referenced by filename only.
            The "rootDir" placeholder refers to the directory containing "Radify.ahk".
            These folders can also be configured using the "SetImageDir" and "SetSoundDir" methods before creating a menu.

            • Include the file extension when referencing image files (e.g., "downloads.png").
            • Omit the ".wav" extension when referencing sound files (e.g., "tada").
        )')

        try ControlFocus(this.gDir.btn_cancel.hwnd, this.gDir.hwnd)
        this.ShowGUIRelativeToOwner(this.gMainTitle, 'gDir')
    }

    ;=============================================================================================

    static gDir_btn_save_Click(*)
    {
        prevImagesDir := Radify.generals.imagesDir
        prevSoundsDir := Radify.generals.soundsDir

        for value in ['soundsDir', 'imagesDir']
            Radify.generals.%value% := this.gDir.edit_%value%.Value

        if (prevImagesDir != Radify.generals.imagesDir) {
            this.CreateImageSoundArray(['image'])
            this.UpdateDDL_SetImagePreview()
        }

        if (prevSoundsDir != Radify.generals.soundsDir) {
            this.CreateImageSoundArray(['sound'])
            this.UpdateDDL_Sound()
        }

        this.SaveToJSONpreferences()
        this.GUI_Close('gDir')
    }

    ;=============================================================================================

	static gDir_btn_browseDir_Click(param, *)
	{
		this.gDir.Opt('+OwnDialogs')
        selectedDir := FileSelect('D',, 'Select Folder - ' this.scriptName)

		if (selectedDir) {
            this.gDir.edit_%param%Dir.Value := selectedDir
            this.gDir_EnableDisable_Btn()
        }
	}

    ;=============================================================================================

    static gDir_btn_ResetDir_Click(param, *)
    {
        this.gDir.edit_%param%.Value := Radify.originalGenerals.%param%
        this.gDir_EnableDisable_Btn()
	}

    ;=============================================================================================

	static gDir_EnableDisable_Btn(*)
	{
        dirsTemp := {imagesDir: this.gDir.edit_imagesDir.Value, soundsDir: this.gDir.edit_soundsDir.Value}
        dirsCurrent := {imagesDir: Radify.generals.imagesDir, soundsDir: Radify.generals.soundsDir}
        this.Button_EnableDisable('gDir', 'btn_save', dirsTemp, dirsCurrent)
	}

    ;=============================================================================================

    static gList_Show(*)
    {
        this.gList := Gui('+Resize +MinSize400x400 -MinimizeBox', 'Remove Items from History - ' this.scriptName)
        this.gList.OnEvent('Size', this.gList_Size.Bind(this))
        this.gList.SetFont('s10')
        this.gList.Tips := GuiCtrlTips(this.gList)
        this.gList.Tips.SetDelayTime('AUTOPOP', 30000)
        try this.gMain.Opt('+Disabled')
        try this.gList.Opt('+Owner' this.gMain.hwnd)

        this.gList.lvWidth := 575
        this.gList.btnSize := 30
        this.gList.btn_delete := this.gList.Add('Button',  'w100 h' this.gList.btnSize, 'Remove')
        this.gList.btn_delete.OnEvent('Click', this.gList_lv_Remove.Bind(this))
        GuiButtonIcon(this.gList.btn_delete, this.mIcons['delete'], 1, 's18 a0 l12')
        this.gList.Tips.SetTip(this.gList.btn_delete, 'Remove selected items.')
        this.gList.btn_checkAll := this.gList.Add('Button', 'x+5 w' this.gList.btnSize ' h' this.gList.btnSize)
        this.gList.btn_checkAll.OnEvent('Click', (*) => this.gList.lv_%this.gList_GetRadioEventType()%.Modify(0, '+Select'))
        GuiButtonIcon(this.gList.btn_checkAll, this.mIcons['selectAll'], 1, 's20')
        this.gList.Tips.SetTip(this.gList.btn_checkAll, 'Select All')
        this.gList.radio_image := this.gList.Add('Radio','x+m ym+5 -Wrap Checked', ' Image')
        this.gList.radio_sound := this.gList.Add('Radio','x+m yp -Wrap', ' Sound')
        this.gList.lvOpt := 'xm w' this.gList.lvWidth ' h500 Grid Sort Hidden Section +BackgroundEAF4FB'

        for (value in ['image', 'sound']) {
            this.gList.radio_%value%.OnEvent('Click', this.gList_radio_eventType_Click.Bind(this, value))
            this.gList.lv_%value% := this.gList.Add('ListView',  (A_Index = 2 ? 'ys ' : '') this.gList.lvOpt, ['Item'])
            this.gList.lv_%value%.OnEvent('ContextMenu', this.gList_ContextMenu.Bind(this, value))
            LV_GridColor(this.gList.lv_%value%, '0xcbcbcb')
        }

        gListWidth := this.gList.lvWidth + this.gList.MarginX*2
        this.gList.btnHeight := 35
        this.gList.btnWidth := 120
        btnPosX := gListWidth/2 - this.gList.btnWidth/2
        this.gList.btn_close := this.gList.Add('Button', 'x' btnPosX ' w' this.gList.btnWidth ' h' this.gList.btnHeight ' Default', 'Close')
        this.gList.btn_close.OnEvent('Click', this.GUI_Close.Bind(this, 'gList'))
        this.gList.OnEvent('Close', this.GUI_Close.Bind(this, 'gList'))

        this.gList.lv_image.Visible := true
        this.gList_CreateListViewItems()
        this.RemoveNonExistentFiles(['image', 'sound'])
        this.ShowGUIRelativeToOwner(this.gMainTitle, 'gList')
    }

    ;=============================================================================================

    static gList_CreateListViewItems(*)
    {
        this.gList.Opt('+Disabled')
        eventType := this.gList_GetRadioEventType()
        imageList := IL_Create()
        this.gList.lv_image.SetImageList(imageList)

        for (item in this.arrImage) {
            if (item != 'None' && !this.HasVal(item, this.arrImageRadify)) {
                switch {
                    case RegExMatch(item, 'i)^(.+?\.(?:dll|exe|cpl))\|icon(\d+)$', &iconRes) && FileExist(iconRes[1]):
                    {
                        hIcon := LoadPicture(iconRes[1], 'Icon' iconRes[2], &imgType)
                        this.gList.lv_image.Add('Icon' IL_Add(imageList, 'HICON:*' hIcon), item)
                        DllCall('DestroyIcon', 'Ptr', hIcon)
                    }
                    case FileExist(item):
                    {
                        pBitmap := Gdip_CreateBitmapFromFile(item)
                        hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
                        this.gList.lv_image.Add('Icon' IL_Add(imageList, 'HBITMAP:*' hBitmap), item)
                        Gdip_DisposeImage(pBitmap)
                        DeleteObject(hBitmap)
                    }
                }
            }
        }

        for (item in this.arrSound)
            if (item != 'None' && !this.HasVal(item, this.arrSoundRadify))
                this.gList.lv_sound.Add('', item)

        this.gList.lv_image.ModifyCol(1, 'AutoHdr')
        this.gList.lv_sound.ModifyCol(1, 'AutoHdr')
        this.gList.Opt('-Disabled')
    }

    ;============================================================================================

    static gList_GetRadioEventType()
    {
        for value in ['image', 'sound']
            if (this.gList.radio_%value%.Value = 1)
                return value
    }

    ;============================================================================================

    static gList_radio_eventType_Click(eventType, *)
	{
        this.gList.lv_%eventType%.Visible := true
        aEventType := ['image', 'sound']
        aEventType.RemoveAt(this.HasVal(eventType, aEventType))
        this.gList.lv_%aEventType[1]%.Visible := false
    }

    ;============================================================================================

    static gList_Size(guiObj, minMax, width, height)
    {
        if (minMax = -1)
            return

        this.MoveControls(
            {Control:this.gList.lv_image, h:height - this.gList.btnSize - this.gList.btnHeight - this.gList.MarginY*5, w:width - this.gList.MarginX*2},
            {Control:this.gList.lv_sound, h:height - this.gList.btnSize - this.gList.btnHeight - this.gList.MarginY*5, w:width - this.gList.MarginX*2},
            {Control:this.gList.btn_close, x:width - width/2 - this.gList.btnWidth/2, y:height - this.gList.btnHeight - this.gList.MarginY*1.5},
        )

        this.gList.lv_image.ModifyCol(1, width - this.gList.MarginX*2 - 5)
        this.gList.lv_sound.ModifyCol(1, width - this.gList.MarginX*2 - 5)
        DllCall('RedrawWindow', 'ptr', this.gList.hwnd, 'ptr', 0, 'ptr', 0, 'uint', 0x0081)
    }

    ;============================================================================================

    static gList_ContextMenu(param, objCtrl, item, isRightClick, x, y)
    {
        MouseGetPos(,,, &mouseOverClassNN)
        if (item = 0 || InStr(mouseOverClassNN, 'SysHeader'))
            return

        ctxMenu := Menu()
        ctxMenu.Add('Remove', this.gList_lv_Remove.Bind(this))
        ctxMenu.SetIcon('Remove', this.mIcons['menuDelete'])
        ctxMenu.Show(x, y)
    }

    ;============================================================================================

    static gList_lv_Active(*)
    {
        if (!this.ControlExist('gList', 'lv_image') && !this.ControlExist('gList', 'lv_sound'))
            return false

        mDhwTmm := Radify.Set_DHWindows_TMMode(0, 2)

        if (WinActive('- ' this.scriptName ' ahk_class AutoHotkeyGUI'))
            flag := true

        Radify.Set_DHWindows_TMMode(mDhwTmm.dhwPrev, mDhwTmm.tmmPrev)
        return flag ?? false
    }

    ;============================================================================================

    static gList_lv_SelectAll(*)
    {
        eventType := this.gList_GetRadioEventType()
        this.gList.lv_%eventType%.Modify(0, '+Select')
    }

    ;============================================================================================

    static gList_lv_Remove(*)
    {
        eventType := this.gList_GetRadioEventType()

        if (!selectedContent := ListViewGetContent('Col1 Selected', this.gList.lv_%eventType%.hwnd))
            return

        if (StrSplit(selectedContent, '`n').Length > 1) {
			this.gList.Opt('+OwnDialogs')
			try {
				if (MsgBox('Are you sure you want to remove all selected ' eventType 's from the history?', 'Remove Confirmation - ' this.scriptName, 'OKCancel Icon?') == 'OK')
                    this.DeleteEntry_ClickYes(selectedContent, eventType)
            } catch
				return
		}
        else
            this.DeleteEntry_ClickYes(selectedContent, eventType)
    }

    ;============================================================================================

    static DeleteEntry_ClickYes(selectedContent, param, *)
    {
		Loop Parse, selectedContent, '`n'
			if (index := this.HasVal(A_LoopField, this.arr%param%))
                this.arr%param%.RemoveAt(index)

        guiObj := this.gList.lv_%param%

		Loop guiObj.GetCount('Selected')
            guiObj.Delete(guiObj.GetNext(0))

        guiObj.ModifyCol(1, 'AutoHdr')
        param == 'sound' ? this.UpdateDDL_Sound() : this.UpdateDDL_SetImagePreview()
    }

    ;============================================================================================

    static RemoveNonExistentFiles(arr)
    {
        if (this.HasVal('image', arr)) {
            for image in this.arrImage.Clone() {
                if !this.HasVal(image, this.arrImageRadify)
                && ((RegExMatch(image, 'i)^(.+?\.(?:dll|exe|cpl))\|icon(\d+)$', &match) && !FileExist(match[1]))
                || (RegExMatch(image, 'i)^(.+?\.(?:' Radify.strImageExt '))$') && !FileExist(image)))
                    (index := this.HasVal(image, this.arrImage)) && this.arrImage.RemoveAt(index)
            }

            this.UpdateDDL_SetImagePreview()
        }

        if (this.HasVal('sound', arr)) {
            for sound in this.arrSound.Clone()
                if (!this.HasVal(sound, this.arrSoundRadify) && !FileExist(sound) && (index := this.HasVal(sound, this.arrSound)))
                    this.arrSound.RemoveAt(index)

            this.UpdateDDL_Sound()
        }
    }

    ;============================================================================================

    static UpdateDDL_SetImagePreview()
    {
        skin := this.gMain.ddl_skins.Text
        skinDir := Radify.rootDir '\skins\' skin '\'

        for ctrlName, displayName in Radify.imageKeyToFileName.OwnProps() {
            image := this.gMain.ddl_%ctrlName%.Text
            targetValue := (this.HasVal(image, this.arrImage) ? image : displayName)
            this.DDLArrayChange_Choose(targetValue, this.arrImage, this.gMain.ddl_%ctrlName%)
            this.gMain_LoadSetImage(targetValue, skinDir, ctrlName)
        }
    }

    ;============================================================================================

    static UpdateDDL_Sound()
    {
        for (value in Radify.arrKeysSound) {
            sound := this.gMain.ddl_%value%.Text
            targetValue := (this.HasVal(sound, this.arrSound) ? sound : 'none')
            this.DDLArrayChange_Choose(targetValue, this.arrSound, this.gMain.ddl_%value%)
        }
    }

    ;============================================================================================

    static gMain_PlaySound(param, *) => SetTimer(Radify.PlaySound.Bind(Radify, this.gMain.ddl_%param%.Text), -1)

    ;=============================================================================================

    static CopyToClipboard(param, ctrlName := '', strOpts:='', *)
    {
        strClip := ' copied to clipboard'

        switch param {
            case 'skin': title := 'Skin name' strClip, msg := this.gMain.ddl_skins.Text
            case 'font': title := 'Font name' strClip, msg := this.gMain.ddl_textFont.Text
            case 'sound', 'image', 'bgImg':
            {
                title := (param == 'bgImg' ? 'Background Image' : StrTitle(param)) strClip

                if (msg := this.gMain.ddl_%ctrlName%.Text) = 'none'
                    return
            }
            default: title := 'Content' strClip, msg := param
        }

        A_Clipboard := '', A_Clipboard := msg
        this.ShowNotify(title, msg)
    }

    ;=============================================================================================

    static ShowNotify(title, msg, dur?)
    {
        Notify.Show(title, msg,,,, this.strOpts 'dg=5 tag=copyToClip theme=okDark dur=' (dur ?? Notify.mOrig_mDefaults['dur']) ' pos=bc mali=center tali=center')
    }

    ;=============================================================================================

    static gMain_btn_colorSelect_Click(param, *)
    {
        color := this.ColorSelect(this.gMain.edit_%param%.Text , this.gMain.hwnd, 1)
        if (color = -1)
            return

        this.gMain.edit_%param%.Value := color
        this.gMain_UpdateTextPreview()
    }

    /********************************************************************************************
     * Win32 Color Picker for AHK v2.
     * @credits Maestrith, TheArkive (v2 conversion), XMCQCX (minor modifications).
     * @see {@link https://www.autohotkey.com/board/topic/94083-ahk-11-font-and-color-dialogs Font and Color Dialogs - AHK Forum}
     * @see {@link https://github.com/TheArkive/ColorPicker_ahk2 ColorPicker_ahk2 - GitHub}
     * @param {number} Color - Start color (0 = black) - Format = 0xRRGGBB
     * @param {number} hwnd - Parent window
     * @param {number} disp - 1=full / 0=basic ... full displays custom colors panel, basic does not.
     */
    static ColorSelect(color := 0, hwnd := 0, disp:=false)
    {
        Static p := A_PtrSize
        disp := disp ? 0x3 : 0x1 ; init disp / 0x3 = full panel / 0x1 = basic panel
        color := this.NormHexClrCode(color)

        If (this.user.savedColors.Length > 16)
            throw Error('Too many custom colors. The maximum allowed values is 16.')

        Loop (16 - this.user.savedColors.Length)
            this.user.savedColors.Push(0) ; fill out this.user['savedColors'] to 16 values

        CUSTOM := Buffer(16 * 4, 0) ; init custom colors obj
        CHOOSECOLOR := Buffer((p=4)?36:72,0) ; init dialog

        If (Type(this.user.savedColors) = 'Array') {
            Loop 16 {
                ; Convert string to number before passing to RGB_BGR
                custColor := RGB_BGR(Number('0x' . this.user.savedColors[A_Index]))
                NumPut 'UInt', custColor, CUSTOM, (A_Index-1) * 4
            }
        }

        NumPut 'UInt', CHOOSECOLOR.size, CHOOSECOLOR, 0             ; lStructSize
        NumPut 'UPtr', hwnd,             CHOOSECOLOR, p             ; hwndOwner
        NumPut 'UInt', RGB_BGR(color),   CHOOSECOLOR, 3 * p         ; rgbResult
        NumPut 'UPtr', CUSTOM.ptr,       CHOOSECOLOR, 4 * p         ; lpCustColors
        NumPut 'UInt', disp,             CHOOSECOLOR, 5 * p         ; Flags

        if !DllCall('comdlg32\ChooseColor', 'UPtr', CHOOSECOLOR.ptr, 'UInt')
            return -1

        this.user.savedColors := Array()
        Loop 16 {
            newCustCol := NumGet(CUSTOM, (A_Index-1) * 4, 'UInt')
            this.user.savedColors.InsertAt(A_Index, Format('{:06X}', RGB_BGR(newCustCol))) ; Store as string
        }

        color := NumGet(CHOOSECOLOR, 3 * A_PtrSize, 'UInt')
        return Format('{:06X}', RGB_BGR(color))

        RGB_BGR(c) => ((c & 0xFF) << 16 | c & 0xFF00 | c >> 16)
    }

    ;=============================================================================================

    static NormHexClrCode(color)
    {
        if (RegExMatch(Color, '^[0-9A-Fa-f]{1,6}$') && SubStr(color, 1, 2) != '0x')
            color := '0x' color

        if (RegExMatch(color, '^0x[0-9A-Fa-f]{1,6}$')) {
            hexPart := SubStr(color, 3)
            while StrLen(hexPart) < 6
                hexPart := '0' hexPart
            color := '0x' hexPart
        }
        else color := '0xFFFFFF'

        return color
    }

    ;=============================================================================================

    static gAbout_Show(*)
    {
        if (this.GuiExist(['gAbout']) || (this.GuiExist(['gMain']) && !DllCall('User32\IsWindowEnabled', 'Ptr', this.gMain.hwnd, 'Int')))
            return

        this.gAbout := Gui('-MinimizeBox', 'About - ' this.scriptName)
        this.gAbout.SetFont('s10')
        this.gAbout.BackColor := 'White'
        try this.gMain.Opt('+Disabled')
        try this.gAbout.Opt('+Owner' this.gMain.hwnd)

        this.gAbout.Add('Picture', 'y15 w50 h50', this.mIcons['mainAbout'])
        this.gAbout.SetFont('s16')
        this.gAbout.Add('Text', 'x+m w350 h50 Section', this.scriptName).SetFont('bold')
        this.gAbout.SetFont('s10')
        this.gAbout.Add('Text', 'yp+40', 'Version: ' this.scriptVersion)
        this.gAbout.Add('Text', 'yp+25', 'Author:')
        this.gAbout.Add('Link', 'x+10', '<a href="https://github.com/XMCQCX">Martin Chartier (XMCQCX)</a>')
        this.gAbout.Add('Text', 'xs yp+25', 'MIT license' )
        this.gAbout.Add('Text', 'xs yp+35 w125', 'Credits').SetFont('s12 bold')
        this.gAbout.SetFont('s10')
        this.gAbout.Add('Text', 'xs yp+40', 'Steve Gray, Chris Mallett, portions of AutoIt Team and various others.')
        this.gAbout.Add('Link', 'yp+20', '<a href="https://www.autohotkey.com">https://www.autohotkey.com</a>')
        this.gAbout.Add('Text', 'xs yp+15', '_____________________________')
        this.gAbout.Add('Link', 'xs yp+25', '<a href="https://github.com/thqby/ahk2_lib/blob/master/JSON.ahk">JSON</a>')
        this.gAbout.Add('Text', 'x+5', 'by thqby, HotKeyIt.')
        this.gAbout.Add('Link', 'xs yp+30', '<a href="https://github.com/AHK-just-me/AHKv2_GuiCtrlTips">GuiCtrlTips</a>')
        this.gAbout.Add('Text', 'x+5', 'by just me.')
        this.gAbout.Add('Link', 'xs yp+30', '<a href="https://www.autohotkey.com/boards/viewtopic.php?f=83&t=125259">LVGridColor</a>')
        this.gAbout.Add('Text', 'x+5', 'by just me.')
        this.gAbout.Add('Link', 'xs yp+30', '<a href="https://www.autohotkey.com/boards/viewtopic.php?f=83&t=115871">GuiButtonIcon</a>')
        this.gAbout.Add('Text', 'x+5', 'by FanaticGuru.')
        this.gAbout.Add('Link', 'xs yp+30', '<a href="https://github.com/tylerjcw/YACS">YACS - Yet Another Color Selector</a>')
        this.gAbout.Add('Text', 'x+5', 'by Komrad Toast.')
        this.gAbout.Add('Link', 'xs yp+30', '<a href="https://github.com/TheArkive/ColorPicker_ahk2">ColorPicker</a>')
        this.gAbout.Add('Text', 'x+5', 'by Maestrith, TheArkive (v2 conversion).')
        this.gAbout.Add('Link', 'xs yp+30', '<a href="https://www.autohotkey.com/boards/viewtopic.php?t=66000">GetFontNames</a>')
        this.gAbout.Add('Text', 'x+5', 'by teadrinker.')
        this.gAbout.Add('Link', 'xs yp+30', '<a href="https://github.com/Descolada/UIA-v2">MoveControls</a>')
        this.gAbout.Add('Text', 'x+5', 'by Descolada. (from UIATreeInspector.ahk)')
        this.gAbout.Add('Link', 'xs yp+30', '<a href="https://www.autohotkey.com/board/topic/66235-retrieving-the-fontname-and-fontsize-of-a-gui-control">Control_GetFont</a>')
        this.gAbout.Add('Text', 'x+5', 'by SKAN, swagfag.')

        gAboutWidth := 550, btnWidth := 120, btnHeight := 35
        btnPosX := gAboutWidth/2 - btnWidth/2
        this.gAbout.btn_close := this.gAbout.Add('Button', 'x' btnPosX ' yp+30 w' btnWidth ' h' btnHeight ' Default', 'Close')
        this.gAbout.btn_close.OnEvent('Click', this.GUI_Close.Bind(this, 'gAbout'))
        this.gAbout.OnEvent('Close', this.GUI_Close.Bind(this, 'gAbout'))
        this.gAbout.MarginY := 15

        try ControlFocus(this.gAbout.btn_close.hwnd, this.gAbout.hwnd)
        this.ShowGUIRelativeToOwner(this.gMainTitle, 'gAbout', 'w550')
    }

    /********************************************************************************************
     * @credits Descolada
     * @see {@link https://github.com/Descolada/UIA-v2 GitHub}
     */
    static MoveControls(ctrls*)
    {
        for ctrl in ctrls
            ctrl.Control.Move(ctrl.HasOwnProp('x') ? ctrl.x : unset, ctrl.HasOwnProp('y') ? ctrl.y : unset, ctrl.HasOwnProp('w') ? ctrl.w : unset, ctrl.HasOwnProp('h') ? ctrl.h : unset)
    }

    ;=============================================================================================

    static GUI_Close(objGui, *)
    {
        try this.gMain.Opt('-Disabled')
        this.%objGui%.Destroy()
    }

    ;=============================================================================================

    static ShowGUIRelativeToOwner(title, gName, width:='')
    {
        if (WinExist(this.gMainTitle ' ahk_class AutoHotkeyGUI')) {
            if (Radify.MonitorGetWindowIsIn(title ' ahk_class AutoHotkeyGUI') = 1) {
                this.%gName%.Show(width)
            } else {
                WinGetClientPos(&posMainX, &posMainY,,, title ' ahk_class AutoHotkeyGUI')
                this.%gName%.Show('x' posMainX ' y' posMainY ' ' width)
            }
        } else this.%gName%.Show(width)
    }

    ;=============================================================================================

    static GuiExist(arrGUIs)
    {
        for (guiName in arrGUIs) {
            try {
                hwnd := this.%guiName%.hwnd
                return true
            }
        }

        dhwTmm := Radify.Set_DHWindows_TMMode(0, 'RegEx')

        if (this.HasVal('fileDialog', arrGUIs) && WinExist('^Select (Image|Sound) - ' this.scriptName '$ ahk_class #32770'))
            guiExist := true

        Radify.Set_DHWindows_TMMode(dhwTmm.dhwPrev, dhwTmm.tmmPrev)
        return guiExist ?? false
    }

    ;=============================================================================================

    static ControlExist(gName, ctrlName)
    {
        try
            return ControlGetHwnd(this.%gName%.%ctrlName%)
        catch
            return false
    }

    ;=============================================================================================

    static HasVal(needle, haystack, caseSensitive := false)
    {
        for index, value in haystack
            if (caseSensitive && value == needle) || (!caseSensitive && value = needle)
                return index

        return false
    }

    ;=============================================================================================

    static CreateIncrementalArray(interval, minimum, maximum)
    {
        arr := Array()
        Loop ((maximum - minimum) // interval) + 1
            arr.Push(minimum + (A_Index - 1) * interval)
        return arr
    }

    ;=============================================================================================

    static ObjectToArray(obj)
    {
        arr := Array()
        for key, value in obj.OwnProps()
            arr.Push(key)
        return arr
    }

    ;=============================================================================================

    static MapToArray(mapObj)
    {
        arr := Array()
        for key, value in mapObj
            arr.Push(key)
        return arr
    }

    ;=============================================================================================

    static isObjectIdentical(m1, m2)
    {
        if (ObjOwnPropCount(m1) != ObjOwnPropCount(m2))
            return false

        for key, value in m1.OwnProps()
            if (!m2.HasOwnProp(key) || m2.%key% != value)
                return false

        return true
    }

    ;=============================================================================================

    static DDLchoose(choice, arr, objCtrl, caseSensitive := false)
    {
        for index, value in arr {
            if (caseSensitive && value == choice) || (!caseSensitive && value = choice) {
                objCtrl.Choose(index)
                valueFound := true
                break
            }
        }
        return valueFound ?? false
    }

    ;=============================================================================================

    static DDLArrayChange_Choose(choice, arr, objCtrl, caseSensitive := false)
    {
        objCtrl.Delete()
        objCtrl.Add(arr)
        this.DDLchoose(choice, arr, objCtrl, caseSensitive)
    }

    ;=============================================================================================

    static DebounceCall(arrParams*)
    {
        delay := arrParams[1]
        funcName := arrParams[2]
        arrParams.RemoveAt(1)
        arrParams.RemoveAt(1)

        if (this.debounceTimers.HasOwnProp(funcName))
            SetTimer(this.debounceTimers.%funcName%, 0)

        boundFunc := this.%funcName%.Bind(this, arrParams)
        this.debounceTimers.%funcName% := boundFunc
        SetTimer(boundFunc, -delay)
    }

    ;=============================================================================================

    static BuildFontOptionsString()
    {
        strFontOptions := ''

        for option in ['Bold', 'Italic', 'Strikeout', 'Underline']
            if (this.gMain.cb_%option%.Value = 1)
                strFontOptions .= ' ' option

        return LTrim(strFontOptions)
    }

    ;=============================================================================================

    static SortArray(arr)
    {
        if (!arr.Length)
            return arr

        sortedArray := Array()
        delimiter := Chr(31)

        for value in arr
            listValues .= value delimiter

        sortedListValues := Sort(RTrim(listValues, delimiter), 'D' delimiter)

        for value in StrSplit(sortedListValues, delimiter)
            sortedArray.Push(value)

        for value in ['SubmenuIndicator.png', 'CenterImage.png', 'ItemBack.png', 'MenuBack.png', 'MenuOuterRim.png', 'ItemGlow.png', 'None', 'Default']
            if (index := this.HasVal(value, sortedArray))
                sortedArray.RemoveAt(index), sortedArray.InsertAt(1, value)

        return sortedArray
    }

    ;=============================================================================================

    static ArrayToString(arr, delim)
    {
        for value in arr
            str .= value delim

        return RTrim(str, delim)
    }

    ;=============================================================================================

    static GetTextWidth(str:='', font:='', fontSize:='', fontOption:='', monWALeft:='', monWATop:='')
    {
        g := Gui()
        g.SetFont('s' fontSize ' ' fontOption, font)
        g.txt := g.Add('Text',, str)
        g.Show('x' monWALeft ' y' monWATop ' Hide')
        g.txt.GetPos(,, &ctrlW)
        g.Destroy()
        return ctrlW
    }

    ;=============================================================================================

    static ControlGetTextWidth(hwnd, txt)
    {
        mon := Radify.MonitorGetWindowIsIn('A')
        MonitorGetWorkArea(mon, &monWALeft, &monWATop, &monWARight, &monWABottom)
        mFI := this.ControlGetFontInfo(hwnd)
        return this.GetTextWidth(txt, mFI['fontName'], mFI['fontSize'],, monWALeft, monWATop)
    }

    /********************************************************************************************
     * Retrieves the font name and font size of a GUI control.
     * @credits SKAN, swagfag
     * @see {@link https://www.autohotkey.com/board/topic/66235-retrieving-the-fontname-and-fontsize-of-a-gui-control/ AHK Forum}
     * @see {@link https://www.autohotkey.com/boards/viewtopic.php?t=113540 AHK Forum}
     */
    static ControlGetFontInfo(hwnd)
    {
        hFont := SendMessage(0x31, 0, 0, hwnd) ; WM_GETFONT
        LOGFONTW := Buffer(92) ; sizeof LOGFONTW

        if !DllCall('GetObject', 'Ptr', hFont, 'Int', LOGFONTW.Size, 'Ptr', LOGFONTW)
            throw OSError('GetObject LOGFONTW failed')

        hDC := DllCall('GetDC', 'Ptr', hwnd, 'Ptr')
        DPI := DllCall('GetDeviceCaps', 'Ptr', hDC, 'Int', 90) ; LOGPIXELSY
        DllCall('ReleaseDC', 'Ptr', hwnd, 'Ptr', hDC)
        lfHeight := NumGet(LOGFONTW, 0, 'Int')
        fontSize := Round((-lfHeight * 72) / DPI)
        fontName := StrGet(LOGFONTW.Ptr + 28, 32, 'UTF-16')
        return Map('fontName', fontName, 'fontSize', fontSize)
    }

    /********************************************************************************************
     * Get the names of all fonts currently installed on the system.
     * @credits teadrinker, XMCQCX (v2 conversion).
     * @see {@link https://www.autohotkey.com/boards/viewtopic.php?t=66000 AHK Forum}
     */
    static GetFontNames()
    {
        static excludeList := ['8514oem', 'Roman', 'Script', 'Courier', 'Fixedsys', 'MS Sans Serif', 'MS Serif', 'Modern', 'Small Fonts', 'System', 'Terminal']
        hDC := DllCall('GetDC', 'Ptr', 0, 'Ptr')
        LOGFONT := Buffer(92, 0)
        NumPut('UChar', 1, LOGFONT, 23) ; DEFAULT_CHARSET := 1

        DllCall('EnumFontFamiliesEx'
            , 'Ptr', hDC
            , 'Ptr', LOGFONT
            , 'Ptr', EnumFontFamExProc := CallbackCreate(EnumFontFamExProcFunc, 'F', 4)
            , 'Ptr', ObjPtr(oFonts := Map())
            , 'UInt', 0)

        CallbackFree(EnumFontFamExProc)
        DllCall('ReleaseDC', 'Ptr', 0, 'Ptr', hDC)
        return oFonts

        EnumFontFamExProcFunc(lpelfe, lpntme, FontType, lParam) {
            font := StrGet(lpelfe + 28, 'UTF-16')
            if (SubStr(font, 1, 1) != '@') && !this.HasVal(font, excludeList)
                ObjFromPtrAddRef(lParam)[font] := ''
            return true
        }
    }

}
