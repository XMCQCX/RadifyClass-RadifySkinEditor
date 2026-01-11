/*********************************************************************************************
 * Radify - A radial menu launcher with multi-ring layouts, submenus and interactive items.
 * @author Martin Chartier (XMCQCX)
 * @version 1.1.0
 * @license MIT
 * @date 2025-08-28
 * @see {@link https://github.com/XMCQCX/RadifyClass-RadifySkinEditor GitHub}
 * @see {@link https://www.autohotkey.com/boards/viewtopic.php?f=83&t=138484 AHK Forum}
 ********************************************************************************************/
Class Radify {
    static __New()
    {
        this.menus := {}
        this.scriptName := 'Radify'
        this.isValidConfiguration := true
        this.lastMenuOpenInfo := {mouseX: unset, mouseY: unset, hwndUnderMouse: unset}
        this.PI := 3.141592653589793

        this.defaults := {
            skin: 'AstroGold',
            itemSize: 70,
            centerSize: 50,
            centerImageScale: 0.5,
            radiusScale: 0.85,
            itemImageScale: 0.5,
            itemImageYRatio: 0.5,
            menuBackgroundImage: 'MenuBack.png',
            itemBackgroundImage: 'ItemBack.png',
            menuOuterRimImage: 'MenuOuterRim.png',
            centerBackgroundImage: 'ItemBack.png',
            itemGlowImage: 'ItemGlow.png',
            submenuIndicatorImage: 'SubmenuIndicator.png',
            centerImage: 'CenterImage.png',
            outerRimWidth: 6,
            outerRingMargin: 25,
            submenuIndicatorSize: 12,
            submenuIndicatorYRatio: 0.08,
            itemBackgroundImageOnCenter: false,
            itemBackgroundImageOnItems: true,
            menuClick: 'Close',
            menuRightClick: 'Close',
            centerClick: 'Drag',
            centerRightClick: 'Close',
            closeOnItemClick: true,
            closeOnItemRightClick: true,
            closeMenuBlock: false,
            mirrorClickToRightClick: false,
            autoCenterMouse: true,
            alwaysOnTop: true,
            activateOnShow: false,
            hideOnLoseFocus: false,
            autoTooltip: true,
            enableTooltip: true,
            enableGlow: true,
            enableItemText: true,
            textColor: 'FFFFFF',
            textFont: 'Arial',
            textSize: 11,
            textFontOptions: 'Bold',
            textRendering: 5,
            textShadowColor: '000000',
            textShadowOffset: 1,
            textBoxScale: 0.85,
            textYRatio: 0.5,
            guiOptions: '-Caption +E0x80000 +E0x08000000',
            smoothingMode: 4,
            interpolationMode: 7,
            soundOnShow: 'None',
            soundOnClose: 'None',
            soundOnSelect: 'None',
            soundOnSubShow: 'None',
            soundOnSubClose: 'None',
        }

        this.range := {
            itemSize: [25, 250],
            centerSize: [25, 250],
            centerImageScale: [0, 1],
            itemImageScale: [0, 1],
            itemImageYRatio: [0, 1],
            outerRimWidth: [0, 25],
            outerRingMargin: [0, 75],
            interpolationMode: [0, 7],
            smoothingMode: [0, 4],
            submenuIndicatorSize: [5, 50],
            submenuIndicatorYRatio: [0, 1],
            radiusScale: [0.5, 2],
            autoCenterMouse: [0, 1],
            itemBackgroundImageOnCenter: [0, 1],
            itemBackgroundImageOnItems: [0, 1],
            closeOnItemClick: [0, 1],
            closeOnItemRightClick: [0, 1],
            closeMenuBlock: [0, 1],
            mirrorClickToRightClick: [0, 1],
            alwaysOnTop: [0, 1],
            activateOnShow: [0, 1],
            hideOnLoseFocus: [0, 1],
            enableTooltip: [0, 1],
            enableGlow: [0, 1],
            autoTooltip: [0, 1],
            enableItemText: [0, 1],
            textSize: [5, 100],
            textRendering: [0, 5],
            textShadowOffset: [0, 5],
            textBoxScale: [0.5, 1],
            textYRatio: [0, 1]
        }

        this.generals := {
            imagesDir: 'RootDir\Images',
            soundsDir: 'RootDir\Sounds',
        }

        this.imageKeyToFileName := {
            menuOuterRimImage: 'MenuOuterRim.png',
            menuBackgroundImage: 'MenuBack.png',
            itemBackgroundImage: 'ItemBack.png',
            centerBackgroundImage: 'ItemBack.png',
            itemGlowImage: 'ItemGlow.png',
            submenuIndicatorImage: 'SubmenuIndicator.png',
            centerImage: 'CenterImage.png',
        }

        this.arrKeysSound := ['soundOnSelect', 'soundOnShow', 'soundOnClose', 'soundOnSubShow', 'soundOnSubClose']

        this.originalDefaults := {}
        for key, value in this.defaults.OwnProps()
            this.originalDefaults.%key% := (this.range.HasOwnProp(key) ? this.CapDecimals(value) : value)

        this.originalGenerals := {}
        for key, value in this.generals.OwnProps()
            this.originalGenerals.%key% := value

        this.skins := {}
        this.skinRequiredImages := ['ItemBack.png']

        ;==============================================

        sourcePath := (A_IsCompiled ? A_ScriptFullPath : A_LineFile)
        SplitPath(sourcePath,, &rootDir)
        this.rootDir := rootDir
        this.skinsDir := rootDir '\skins\'

        if (DirExist(this.skinsDir)) {
            Loop Files, this.skinsDir '*', 'D' {
                skinName := A_LoopFileName
                skinDir := this.skinsDir skinName '\'
                allImagesExist := true
                for img in this.skinRequiredImages {
                    if (!FileExist(skinDir img)) {
                        allImagesExist := false
                        break
                    }
                }
                if (allImagesExist)
                    this.skins.%skinName% := {}
            }
        } else {
            this.isValidConfiguration := false
            return this.ShowErrorMsg('Skins folder not found at:`n"' this.skinsDir '"')
        }

        if (!ObjOwnPropCount(this.skins)) {
            this.isValidConfiguration := false
            return this.ShowErrorMsg('No valid skin found in skins folder:`n"' this.skinsDir '"')
        }

        ;==============================================

        this.originalSkins := {}

        for skin in this.skins.OwnProps() {
            this.originalSkins.%skin% := {}
            skinDir := this.skinsDir skin '\'

            for key in this.imageKeyToFileName.OwnProps()
                if (FileExist(skinDir this.imageKeyToFileName.%key%))
                    this.originalSkins.%skin%.%key% := this.imageKeyToFileName.%key%
        }

        ;==============================================

        if (FileExist(this.rootDir '\Preferences.json')) {
            fileObj := FileOpen(this.rootDir '\Preferences.json', 'r', 'UTF-8')
            JSONobj := JSON_thqby_Radify.parse(fileObj.Read(), false, false)
            fileObj.Close()

            for value in ['generals', 'defaults']
                if (JSONobj.HasOwnProp(value))
                    for key, val in JSONobj.%value%.OwnProps()
                        if (this.%value%.HasOwnProp(key))
                            this.%value%.%key% := val

            if (JSONobj.HasOwnProp('skins'))
                for skin, skinOptions in JSONobj.skins.OwnProps()
                    if (this.skins.HasOwnProp(skin))
                        for key, value in skinOptions.OwnProps()
                            if (this.defaults.HasOwnProp(key))
                                this.skins.%skin%.%key% := value
        }

        ;==============================================

        if (!this.skins.HasProp(this.defaults.skin)) {
            if (this.skins.HasOwnProp(this.originalDefaults.skin))
                this.defaults.skin := this.originalDefaults.skin
            else {
                for skinName in this.skins.OwnProps() {
                    this.defaults.skin := skinName
                    break
                }
            }
        }

        ;==============================================

        for skin, skinOptions in this.skins.OwnProps() {
            skinOptionKeys := []

            for key in this.imageKeyToFileName.OwnProps()
                if (!skinOptions.HasOwnProp(key) && this.originalSkins.%skin%.HasOwnProp(key))
                    skinOptions.%key% := this.imageKeyToFileName.%key%

            for key, value in skinOptions.OwnProps()
                skinOptionKeys.Push(key)

            skinOptions.skinOptionKeys := skinOptionKeys
        }

        ;==============================================

        this.GetImagePaths()
        this.GetSoundPaths()
    }

    ;=============================================================================================

    static GetImagePaths()
    {
        this.generals.imagesDir := this.ReplaceRootDir(this.generals.imagesDir)

        this.images := {}
        this.arrImageExt := ['ico', 'png', 'jpeg', 'jpg', 'gif', 'bmp', 'tif']
        this.strImageExt := this.ArrayToString(this.arrImageExt, '|')
        Loop Files this.generals.imagesDir '\*.*'
            if (RegExMatch(A_LoopFileExt, 'i)^(' this.strImageExt ')$'))
                SplitPath(A_LoopFilePath, &fileName), this.images.%fileName% := A_LoopFilePath

        for key in this.imageKeyToFileName.OwnProps()
            if (this.images.HasOwnProp(this.imageKeyToFileName.%key%))
                 this.images.DeleteProp(this.imageKeyToFileName.%key%)
    }

    ;=============================================================================================

    static GetSoundPaths()
    {
        this.generals.soundsDir := this.ReplaceRootDir(this.generals.soundsDir)

        this.sounds := {}
        for path in [A_WinDir '\Media', this.generals.soundsDir]
            Loop Files path '\*.wav'
                SplitPath(A_LoopFilePath,,,, &fileNameNoExt), this.sounds.%fileNameNoExt% := A_LoopFilePath
    }

    /*********************************************************************************************
     * Sets the directory for images, allowing image files to be referenced by filename only.
     * @param {string | undefined} dirPath - The directory path for images. If omitted, defaults to "rootDir\Images".
     * Must be called before creating a menu to change the directory.
     * The path may include the "rootDir\" prefix, which refers to the directory containing "Radify.ahk".
     *********************************************************************************************/
    static SetImageDir(dirPath?) => this.SetDirectory('image', dirPath?)

    /*********************************************************************************************
     * Sets the directory for sounds, allowing sound files to be referenced by filename only.
     * @param {string | undefined} dirPath - The directory path for sounds. If omitted, defaults to "rootDir\Sounds".
     * Must be called before creating a menu to change the directory.
     * The path may include the "rootDir\" prefix, which refers to the directory containing "Radify.ahk".
     *********************************************************************************************/
    static SetSoundDir(dirPath?) => this.SetDirectory('sound', dirPath?)

    ;=============================================================================================

    static SetDirectory(dirType, dirPath?)
    {
        if (IsSet(dirPath) && Type(dirPath) != 'String')
            return this.ShowErrorMsg('Parameter #1 of Set' StrTitle(dirType) 'Dir requires a String. Received: ' Type(dirPath) '.')

        if (!IsSet(dirPath) || dirPath = '')
            dirPath := this.originalGenerals.%dirType%sDir

        dirPath := this.ReplaceRootDir(dirPath)

        if (!DirExist(dirPath))
            return this.ShowErrorMsg('Non-existent ' StrTitle(dirType) 's directory: "' dirPath '"')

        this.generals.%dirType%sDir := dirPath
        this.Get%dirType%Paths()
        return true
    }

    ;=============================================================================================

    static ReplaceRootDir(dirPath)
    {
        if (RegExMatch(dirPath, 'i)^rootDir\\'))
            return StrReplace(dirPath, 'rootDir', this.rootDir,,, 1)
        return dirPath
    }

    /*********************************************************************************************
     * Creates a menu with the specified ID, structure, and configuration options.
     * @param {string} menuId - Unique identifier of the menu.
     * @param {array} menuItems - The menu structure: an array of one or more inner arrays (rings), each containing item objects.
     * @param {object} options - Configuration options for the menu.
     */
    static CreateMenu(menuId?, menuItems?, options := {})
    {
        if (!this.isValidConfiguration)
            return

        if (!IsSet(menuId) || menuId = '')
            return this.ShowErrorMsg('Parameter #1 of CreateMenu requires a non-empty String.')

        if (Type(menuId) != 'String')
            return this.ShowErrorMsg('Parameter #1 of CreateMenu requires a String. Received: ' Type(menuId) '.', menuId)

        if (this.menus.HasOwnProp(menuId))
            return this.ShowErrorMsg('Parameter #1 of CreateMenu must be a unique menu ID. "' menuId '" already exists.')

        if (!IsSet(menuItems) || Type(menuItems) != 'Array')
            return this.ShowErrorMsg('Parameter #2 of CreateMenu requires an Array.' (IsSet(menuItems) ? ' Received: ' Type(menuItems) '.' : ''), menuId)

        if (menuItems.Length = 0 || !this.IsArrayOfArrays(menuItems))
            return this.ShowErrorMsg('Parameter #2 of CreateMenu requires an Array of one or more inner arrays (rings), each containing item objects.', menuId)

        if (Type(options) != 'Object')
            return this.ShowErrorMsg('Parameter #3 of CreateMenu requires an Object. Received: ' Type(options) '.', menuId)

        newMenuIds := []

        try {
            this.ProcessMenu(menuId, menuItems, options, newMenuIds)

            for (mId in newMenuIds) {
                oMenu := this.menus.%mId%
                g := Gui(oMenu.options.guiOptions, 'RadifyGui_' oMenu.options.closeMenuBlock '_' oMenu.parentMenuId '_' mId)
                g.OnEvent('Close', this.Close.Bind(this, mId, false))
                g.Show('Hide')
                oMenu.gui := g
                oMenu.hwnd := g.hwnd

                if (oMenu.options.alwaysOnTop)
                    oMenu.gui.Opt('+AlwaysOnTop')

                this.LoadSkinImages(oMenu)
                this.RenderMenu(oMenu)
                this.SetupMenuClickZones(oMenu)
                this.RegisterItemKeyBindings(oMenu)
                oMenu.isFullyInitialized := true
            }

            for (mId in newMenuIds) {
                oMenu := this.menus.%mId%
                if (oMenu.parentMenuId) {
                    parentMenu := this.menus.%oMenu.parentMenuId%
                    oMenu.gui.Opt('+Owner' parentMenu.hwnd)
                }
            }
        } catch as e
            return this.OnMenuCreationFailure(menuId, e)

        return true
    }

    ;=============================================================================================

    static ShowErrorMsg(errorMsg, menuId?)
    {
        errorMsg .= '`n`nDetails:'
        errorMsg .= (IsSet(menuId) ? '`n- Menu: "' menuId '"' : '')
        errorMsg .= '`n- Script: "' A_ScriptFullPath '"'
        MsgBox(errorMsg, this.scriptName ' - Error', 'Iconx')
        return false
    }

    ;=============================================================================================

    static OnMenuCreationFailure(menuId, e)
    {
        this.CleanupMenu(menuId)
        errorMsg := 'Failed to create menu: "' menuId '". ' e.Message '`n- Script: "' A_ScriptFullPath '"'
        MsgBox(errorMsg, this.scriptName ' - Error', 'Iconx')
        return false
    }

    ;=============================================================================================

    static CleanupMenu(rootMenuId)
    {
        if (!this.menus.HasOwnProp(rootMenuId))
            return

        menuIdsToRemove := [rootMenuId]
        oMenu := this.menus.%rootMenuId%

        for submenuId in oMenu.submenuIds
            menuIdsToRemove.Push(submenuId)

        for mId in menuIdsToRemove {
            if (this.menus.HasOwnProp(mId)) {
                oMenu := this.menus.%mId%
                this.DisposeMenuResources(oMenu)
                this.menus.DeleteProp(mId)
            }
        }
    }

    ;=============================================================================================

    static ProcessMenu(menuId, menuItems, options, newMenuIds, parentMenuId := unset)
    {
        oMenu := {
            id: menuId,
            menuItems: menuItems,
            options: {},
            rings: [],
            itemList: [],
            submenuIds: [],
            maxExtent: 0,
            prevHoveredIndex: 0,
            currentTooltip: 0,
            prevTooltipX: 0,
            prevTooltipY: 0,
            isFullyInitialized: false
        }

        oMenu.parentMenuId := (parentMenuId ?? 0)
        this.menus.%menuId% := oMenu
        newMenuIds.Push(menuId)
        this.MergeMenuOptions(oMenu, options)
        this.ProcessRings(oMenu, menuItems, menuId, newMenuIds, oMenu.parentMenuId)
    }

    ;=============================================================================================

    static MergeMenuOptions(oMenu, options)
    {
        for key, value in options.OwnProps()
            oMenu.options.%key% := value

        if (!oMenu.options.HasOwnProp('skin') || !this.skins.HasOwnProp(oMenu.options.skin))
            oMenu.options.skin := this.defaults.skin

        ; Apply skin-specific options only if they haven't been set.
        if (this.skins.HasOwnProp(oMenu.options.skin))
            for key in this.skins.%oMenu.options.skin%.skinOptionKeys
                if (!oMenu.options.HasOwnProp(key))
                    oMenu.options.%key% := this.skins.%oMenu.options.skin%.%key%

        ; Apply default options for any remaining unset properties.
        for key, value in this.defaults.OwnProps()
            if (!oMenu.options.HasOwnProp(key))
                oMenu.options.%key% := value

        for key in this.range.OwnProps()
            if (oMenu.options.HasOwnProp(key))
                oMenu.options.%key% := this.ClampValue(oMenu.options.%key%, key)

        oMenu.options.textFontOptions := this.NormalizeFontOptions(oMenu.options.textFontOptions)

        for key in this.arrKeysSound
            if (oMenu.options.%key% = 'none')
                oMenu.options.%key% := ''

        for key in this.imageKeyToFileName.OwnProps()
            if (oMenu.options.%key% = 'none')
                oMenu.options.%key% := ''

        oMenu.skinDir := this.skinsDir oMenu.options.skin '\'
    }

    ;=============================================================================================

    static ProcessRings(oMenu, menuItems, menuId, newMenuIds, parentMenuId)
    {
        validRingCount := 0
        validItemCount := 0

        for ringIdx, ringItems in menuItems {
            if (!Type(ringItems) = 'Array' || ringItems.Length = 0)
                continue

            ring := {items: [], radius: 0}
            itemCount := ringItems.Length
            radius := oMenu.options.centerSize / 2 + oMenu.options.itemSize / 2 +
                      oMenu.options.itemSize * (ringIdx - 1) * oMenu.options.radiusScale + itemCount * 2
            ring.radius := Round(radius)
            ringValidItemCount := 0

            for itemIdx, menuItem in ringItems {
                item := this.CreateMenuItem(oMenu, menuItem, menuId, ringIdx, itemIdx, itemCount, radius, newMenuIds)
                ring.items.Push(item)
                ringValidItemCount++
                validItemCount++
            }

            if (ringValidItemCount > 0) {
                ringExtent := ring.radius + oMenu.options.itemSize / 2
                oMenu.maxExtent := Max(oMenu.maxExtent, ringExtent)
                oMenu.rings.Push(ring)
                validRingCount++
            }
        }

        if (validRingCount = 0 || validItemCount = 0)
            throw Error((parentMenuId ? 'One of its submenus' : 'The menu') ' contains no valid rings or items.`n`nDetails:`n- Menu: "' menuId '"')
    }

    ;=============================================================================================

    static CreateMenuItem(oMenu, menuItem, menuId, ringIdx, itemIdx, itemCount, radius, newMenuIds)
    {
        item := {
            itemSize: oMenu.options.itemSize,
            isEmpty: false,
            submenuId: 0
        }

        if (Type(menuItem) != 'Object')
            throw Error('Menu item requires an Object. Received: ' Type(menuItem) '.`n`nDetails:`n- Menu: "' menuId '"`n- Ring: ' ringIdx ', Item: ' itemIdx)

        if (ObjOwnPropCount(menuItem) = 0) {
            item.isEmpty := true
            return item
        }

        arrkeys := [
            'itemImageScale', 'itemImageYRatio', 'submenuIndicatorImage', 'submenuIndicatorSize', 'submenuIndicatorYRatio',
            'itemBackgroundImage', 'enableItemText', 'textColor', 'textFont', 'textSize', 'textFontOptions',
            'textRendering', 'textShadowColor', 'textShadowOffset', 'textBoxScale', 'textYRatio', 'soundOnSelect',
            'closeOnItemClick', 'closeOnItemRightClick', 'mirrorClickToRightClick'
        ]

        for (key in arrkeys) {
            if (menuItem.HasOwnProp(key))
                item.%key% := this.range.HasOwnProp(key) ? this.ClampValue(menuItem.%key%, key) : menuItem.%key%
            else if (oMenu.options.HasOwnProp(key))
                item.%key% := oMenu.options.%key%
        }

        for key in ['click', 'rightClick', 'shiftClick', 'altClick', 'ctrlClick']
            item.%key% := ((menuItem.HasOwnProp(key) && menuItem.%key% != 'drag') ? menuItem.%key% : '')

        for key in ['image', 'text', 'tooltip', 'hotkeyClick', 'hotkeyRightClick', 'hotkeyShiftClick', 'hotkeyAltClick', 'hotkeyCtrlClick',
                    'hotstringClick', 'hotstringRightClick', 'hotstringShiftClick', 'hotstringAltClick', 'hotstringCtrlClick']
            item.%key% := ((menuItem.HasOwnProp(key)) ? menuItem.%key% : '')

        if (item.mirrorClickToRightClick && item.click && !item.rightClick)
            item.rightClick := item.click

        if (oMenu.options.autoTooltip && !menuItem.HasOwnProp('tooltip')) {
            if (item.text)
                item.tooltip := item.text
            else if (item.image) {
                SplitPath(item.image,,,, &nameNoExt)
                item.tooltip := nameNoExt
            }
        }

        item.textFontOptions := this.NormalizeFontOptions(item.textFontOptions)

        angle := (itemIdx - 1) * (2 * this.PI / itemCount) - (this.PI / 2)
        item.relX := Round(radius * Cos(angle))
        item.relY := Round(radius * Sin(angle))

        if (menuItem.HasOwnProp('submenu')) {
            arrSubmenu := menuItem.submenu
            submenuId := menuId '_submenu_' ringIdx '_' itemIdx
            item.submenuId := submenuId
            oMenu.submenuIds.Push(submenuId)

            if (Type(arrSubmenu) != 'Array')
                throw Error('The Submenu property requires an Array. Received: ' Type(arrSubmenu) '.`n`nDetails:`n- Menu: "' menuId '"`n- Ring: ' ringIdx ', Item: ' itemIdx)

            if (arrSubmenu.Length = 0 || !this.IsArrayOfArrays(arrSubmenu))
                throw Error('The Submenu property requires an Array of one or more inner arrays (rings), each containing item objects.`n`nDetails:`n- Menu: "' menuId '"`n- Ring: ' ringIdx ', Item: ' itemIdx)

            submenuOptions := {}

            if (menuItem.HasOwnProp('submenuOptions') && Type(menuItem.submenuOptions) = 'Object')
                for key, value in menuItem.submenuOptions.OwnProps()
                    submenuOptions.%key% := value

            if (item.image && !submenuOptions.HasOwnProp('centerImage'))
                submenuOptions.centerImage := item.image

            if (!submenuOptions.HasOwnProp('skin'))
                submenuOptions.skin := oMenu.options.skin

            submenuOptions.soundOnShow := (submenuOptions.HasOwnProp('soundOnShow') ? submenuOptions.soundOnShow : oMenu.options.soundOnSubShow)
            submenuOptions.soundOnClose := (submenuOptions.HasOwnProp('soundOnClose') ? submenuOptions.soundOnClose : oMenu.options.soundOnSubClose)
            this.ProcessMenu(submenuId, arrSubmenu, submenuOptions, newMenuIds, menuId)
        }

        return item
    }

    ;=============================================================================================

    static LoadSkinImages(oMenu)
    {
        validBitmapCount := 0
        for key in this.imageKeyToFileName.OwnProps()
            if (oMenu.p%key% := this.LoadImage(oMenu.options.%key%, oMenu.skinDir))
                validBitmapCount++

        if (validBitmapCount = 0)
            throw Error('Unable to load images for skin: "' oMenu.options.skin '").`n`n'
                      . 'Possible reasons:`n1) GDI+ is included but not initialized. Make sure Gdip_Startup() has been called.`n'
                      . '2) Skin directory does not contain valid image files:`n"' oMenu.skinDir '".`n`nDetails:`n- Menu: "' oMenu.id '"')
    }

    ;=============================================================================================

    static RenderMenu(oMenu)
    {
        menuSize := Round(oMenu.maxExtent * 2 + oMenu.options.outerRingMargin * 2)
        centerPoint := Round(menuSize / 2)
        dpiScale := this.GetDpiScale(oMenu.hwnd)
        scaledMenuSize := Round(menuSize * dpiScale)
        scaledCenterPoint := Round(centerPoint * dpiScale)
        oMenu.size := menuSize
        oMenu.scaledSize := scaledMenuSize
        oMenu.centerPoint := centerPoint
        oMenu.scaledCenterPoint := scaledCenterPoint
        oMenu.dpiScale := dpiScale
        oMenu.hbm := CreateDIBSection(scaledMenuSize, scaledMenuSize)
        oMenu.hdc := CreateCompatibleDC()
        oMenu.obm := SelectObject(oMenu.hdc, oMenu.hbm)
        oMenu.G := Gdip_GraphicsFromHDC(oMenu.hdc)
        Gdip_SetSmoothingMode(oMenu.G, oMenu.options.smoothingMode)
        Gdip_SetInterpolationMode(oMenu.G, oMenu.options.interpolationMode)
        Gdip_GraphicsClear(oMenu.G, 0x00FFFFFF)
        Gdip_ScaleWorldTransform(oMenu.G, dpiScale, dpiScale)
        menuSize := oMenu.size
        centerPoint := oMenu.centerPoint

        if (!oMenu.pMenuOuterRimImage)
            oMenu.options.outerRimWidth := 0

        outerRimWidth := oMenu.options.outerRimWidth

        if (oMenu.pMenuOuterRimImage)
            Gdip_DrawImage(oMenu.G, oMenu.pMenuOuterRimImage, 0, 0, menuSize, menuSize)

        if (oMenu.pMenuBackgroundImage) {
            innerX := Round(outerRimWidth)
            innerY := Round(outerRimWidth)
            innerSize := Round(menuSize - (outerRimWidth * 2))
            Gdip_DrawImage(oMenu.G, oMenu.pMenuBackgroundImage, innerX, innerY, innerSize, innerSize)
        }

        centerSize := oMenu.options.centerSize
        centerX := Round(centerPoint - centerSize / 2)
        centerY := Round(centerPoint - centerSize / 2)

        if (oMenu.pCenterBackgroundImage && oMenu.options.itemBackgroundImageOnCenter)
            if (Gdip_DrawImage(oMenu.G, oMenu.pCenterBackgroundImage, centerX, centerY, centerSize, centerSize) = 0)
                hasCenterBgImage := true

        if (oMenu.pCenterImage) {
            imgSize := Round(centerSize * oMenu.options.centerImageScale)
            imgX := Round(centerX + (centerSize - imgSize) / 2)
            imgY := Round(centerY + (centerSize - imgSize) / 2)

            if (Gdip_DrawImage(oMenu.G, oMenu.pCenterImage, imgX, imgY, imgSize, imgSize) = 0)
                hasCenterImage := true
        }

        ; If no background image is drawn in the center, fill it with a transparent circle to ensure the region detects clicks.
        if (!IsSet(hasCenterBgImage)) {
            pBrush := Gdip_BrushCreateSolid(0x01000000)
            Gdip_FillEllipse(oMenu.G, pBrush, centerX, centerY, centerSize, centerSize)
            Gdip_DeleteBrush(pBrush)
        }

        for ringIdx, ring in oMenu.rings {
            for itemIdx, item in ring.items {
                if (item.isEmpty)
                    continue
                absX := Round(centerPoint + item.relX - item.itemSize / 2)
                absY := Round(centerPoint + item.relY - item.itemSize / 2)

                if (item.itemBackgroundImage = oMenu.options.itemBackgroundImage)
                    pItemBackgroundImage := oMenu.pItemBackgroundImage
                else
                    pItemBackgroundImage := this.LoadImage(item.itemBackgroundImage, oMenu.skinDir)

                if (pItemBackgroundImage && oMenu.options.itemBackgroundImageOnItems) {
                    Gdip_DrawImage(oMenu.G, pItemBackgroundImage, absX, absY, item.itemSize, item.itemSize)

                    if (item.itemBackgroundImage != oMenu.options.itemBackgroundImage)
                        Gdip_DisposeImage(pItemBackgroundImage)
                }

                if (item.image) {
                    item.pImage := this.LoadImage(item.image, oMenu.skinDir)

                    if (item.pImage) {
                        item.imgSize := Round(item.itemSize * item.itemImageScale)
                        item.imgX := Round(absX + (item.itemSize - item.imgSize) / 2)
                        item.imgY := Round(absY + item.itemImageYRatio * (item.itemSize - item.imgSize))
                        Gdip_DrawImage(oMenu.G, item.pImage, item.imgX, item.imgY, item.imgSize, item.imgSize)
                        Gdip_DisposeImage(item.pImage)
                    }
                }

                if (item.submenuId) {
                    if (item.submenuIndicatorImage = oMenu.options.submenuIndicatorImage)
                        pSubmenuIndicatorImage := oMenu.pSubmenuIndicatorImage
                    else
                        pSubmenuIndicatorImage := this.LoadImage(item.submenuIndicatorImage, oMenu.skinDir)

                    if (pSubmenuIndicatorImage) {
                        indicatorX := Round(absX + (item.itemSize - item.submenuIndicatorSize) / 2)
                        indicatorY := Round(absY + item.submenuIndicatorYRatio * (item.itemSize - item.submenuIndicatorSize))
                        Gdip_DrawImage(oMenu.G, pSubmenuIndicatorImage, indicatorX, indicatorY, item.submenuIndicatorSize, item.submenuIndicatorSize)

                        if (item.submenuIndicatorImage != oMenu.options.submenuIndicatorImage)
                            Gdip_DisposeImage(pSubmenuIndicatorImage)
                    }
                }

                if (item.enableItemText && item.text) {
                    textBoxWidth := Round(item.itemSize * item.textBoxScale)
                    textBoxHeight := Round(item.itemSize * item.textBoxScale)
                    argbColor := 'ff' item.textColor
                    argbShadowColor := 'ff' item.textShadowColor
                    textBoxX := Round(absX + (item.itemSize - textBoxWidth) / 2)

                    hFamily := Gdip_FontFamilyCreate(item.textFont)
                    hFont := Gdip_FontCreate(hFamily, item.textSize, 0)
                    hFormat := Gdip_StringFormatCreate(0x4000)
                    Gdip_SetStringFormatAlign(hFormat, 1)
                    Gdip_SetTextRenderingHint(oMenu.G, item.textRendering)
                    CreateRectF(&RC, 0, 0, textBoxWidth, textBoxHeight)
                    ReturnRC := Gdip_MeasureString(oMenu.G, item.text, hFont, hFormat, &RC)
                    textHeight := StrSplit(ReturnRC, '|')[4]

                    textBoxY := Round(absY + (item.itemSize - textHeight) * item.textYRatio)
                    textOptionsStr := 'x' textBoxX ' y' textBoxY ' w' textBoxWidth ' h' textBoxHeight ' Center '
                    textOptionsStr .= 'c' argbColor
                    textOptionsStr .= ' s' item.textSize
                    textOptionsStr .= ' r' item.textRendering

                    if (item.textFontOptions)
                        textOptionsStr .= ' ' item.textFontOptions

                    if (item.textShadowOffset > 0) {
                        shadowX := textBoxX + item.textShadowOffset
                        shadowY := textBoxY + item.textShadowOffset
                        shadowOptions := 'x' shadowX ' y' shadowY ' w' textBoxWidth ' h' textBoxHeight ' Center '
                        shadowOptions .= 'c' argbShadowColor
                        shadowOptions .= ' s' item.textSize
                        shadowOptions .= ' r' item.textRendering

                        if (item.textFontOptions)
                            shadowOptions .= ' ' item.textFontOptions

                        Gdip_TextToGraphics(oMenu.G, item.text, shadowOptions, item.textFont, textBoxWidth, textBoxHeight)
                    }

                    Gdip_TextToGraphics(oMenu.G, item.text, textOptionsStr, item.textFont, textBoxWidth, textBoxHeight)
                    Gdip_DeleteStringFormat(hFormat)
                    Gdip_DeleteFont(hFont)
                    Gdip_DeleteFontFamily(hFamily)
                }
            }
        }

        UpdateLayeredWindow(oMenu.hwnd, oMenu.hdc, 0, 0, oMenu.scaledSize, oMenu.scaledSize)

        if (!oMenu.pitemGlowImage)
            oMenu.options.enableGlow := false

        if (oMenu.options.enableGlow)
            this.CreateGlowGui(oMenu)

        this.DisposeMenuSkinImages(oMenu)
        return oMenu
    }

    ;=============================================================================================

    static CreateGlowGui(oMenu)
    {
        glowSize := Round(oMenu.options.itemSize * oMenu.dpiScale)
        g := Gui('-Caption +E0x80000 +E0x08000000 +E0x20 +Owner' oMenu.hwnd, 'RadifyGlowGUI_' oMenu.id)
        g.Show('Hide')
        oMenu.glowGui := g
        oMenu.glowHwnd := g.Hwnd
        oMenu.glowHdc := CreateCompatibleDC()
        oMenu.glowHbm := CreateDIBSection(glowSize, glowSize)
        oMenu.glowObm := SelectObject(oMenu.glowHdc, oMenu.glowHbm)
        oMenu.glowG := Gdip_GraphicsFromHDC(oMenu.glowHdc)
        Gdip_SetSmoothingMode(oMenu.glowG, oMenu.options.smoothingMode)
        Gdip_SetInterpolationMode(oMenu.glowG, oMenu.options.interpolationMode)
        Gdip_GraphicsClear(oMenu.glowG, 0x00FFFFFF)
        Gdip_DrawImage(oMenu.glowG, oMenu.pItemGlowImage, 0, 0, glowSize, glowSize)
        UpdateLayeredWindow(oMenu.glowHwnd, oMenu.glowHdc, 0, 0, glowSize, glowSize)
    }

    ;=============================================================================================

    static LoadImage(image, skinDir)
    {
        if (!image)
            return false

        image := Trim(image)

        SplitPath(image,,, &ext)
        if (ext && RegExMatch(ext, 'i)^(exe|dll|cpl)$'))
            image .= '|icon1'

        if (FileExist(skinDir image))
            return Gdip_CreateBitmapFromFile(skinDir image)

        if (FileExist(image))
            return Gdip_CreateBitmapFromFile(image)

        if (this.isInternalImage(image))
            return Gdip_CreateBitmapFromFile(this.images.%image%)

        if (iconRes := this.isIconResourceFile(image)) {
            if (hIcon := LoadPicture(iconRes[1], 'Icon' iconRes[2], &imgType)) {
                pBitmap := Gdip_CreateBitmapFromHICON(hIcon)
                DllCall('DestroyIcon', 'Ptr', hIcon)
                return pBitmap
            }
            return false
        }

        if (this.isHICON(image))
            return Gdip_CreateBitmapFromHICON(image)

        if (this.isHBITMAP(image))
            return Gdip_CreateBitmapFromHBITMAP(image)

        return false
    }

    ;=============================================================================================

    static isIconResourceFile(image)
    {
        if (RegExMatch(image, 'i)^(.+?\.(?:dll|exe|cpl))\|icon(\d+)$', &m) && FileExist(m[1]))
            return [m[1], m[2]]
        return false
    }

    ;=============================================================================================

    static isInternalImage(image)
    {
        return this.images.HasOwnProp(image) && FileExist(this.images.%image%)
    }

    ;=============================================================================================

    static isHBITMAP(handle)
    {
        return IsInteger(handle) && handle != 0 && DllCall('GetObjectType', 'Ptr', handle) == 7
    }

    ;=============================================================================================

    static isHICON(handle)
    {
        if (!IsInteger(handle) || handle = 0)
            return false
        iconInfo := Buffer(32 + A_PtrSize * 3, 0)
        return !!DllCall('GetIconInfo', 'Ptr', handle, 'Ptr', iconInfo)
    }

    ;=============================================================================================

    static SetupMenuClickZones(oMenu)
    {
        centerPoint := oMenu.centerPoint
        centerSize := oMenu.options.centerSize
        centerX := Round(centerPoint - centerSize / 2)
        centerY := Round(centerPoint - centerSize / 2)
        clickZoneX := Round(centerX + centerSize / 2)
        clickZoneY := Round(centerY + centerSize / 2)
        clickRadius := centerSize / 2

        centerInfo := {
            isCenter: true,
            x: clickZoneX,
            y: clickZoneY,
            radiusSquared: clickRadius ** 2,
            centerX: centerPoint,
            centerY: centerPoint
        }
        oMenu.itemList.Push(centerInfo)

        for ringIdx, ring in oMenu.rings {
            for itemIdx, item in ring.items {
                if (item.isEmpty)
                    continue
                item.absX := Round(centerPoint + item.relX - item.itemSize / 2)
                item.absY := Round(centerPoint + item.relY - item.itemSize / 2)
                item.itemClickZoneSize := item.itemSize
                itemClickRadius := item.itemSize / 2
                itemInfo := {
                    isCenter: false,
                    ringIdx: ringIdx,
                    itemIdx: itemIdx,
                    x: item.absX,
                    y: item.absY,
                    radiusSquared: itemClickRadius ** 2,
                    centerX: centerPoint + item.relX,
                    centerY: centerPoint + item.relY
                }
                oMenu.itemList.Push(itemInfo)
            }
        }

        ; Process items from last to first created to avoid hitbox conflicts due to overlapping.
        oMenu.itemList := this.ArrayReverse(oMenu.itemList)
    }

    ;=============================================================================================

    static IsPointInCircularZone(itemInfo, relX, relY)
    {
        distanceSquared := (relX - itemInfo.centerX)**2 + (relY - itemInfo.centerY)**2
        if (distanceSquared > itemInfo.radiusSquared)
            return false
        return true
    }

    ;=============================================================================================

    static FindHoveredItem(oMenu, mouseX, mouseY)
    {
        WinGetClientPos(&winX, &winY,,, oMenu.hwnd)
        relX := (mouseX - winX) / oMenu.dpiScale
        relY := (mouseY - winY) / oMenu.dpiScale

        for index, itemInfo in oMenu.itemList {
            if (this.IsPointInCircularZone(itemInfo, relX, relY)) {
                if (itemInfo.isCenter)
                    continue
                ring := oMenu.rings[itemInfo.ringIdx]
                item := ring.items[itemInfo.itemIdx]
                return {
                    index: index,
                    item: item,
                    itemInfo: itemInfo,
                    winX: winX,
                    winY: winY
                }
            }
        }
        return false
    }
		
	/*********************************************************************************************
    * Updates image for existing menu item.
    * @param {string} menuId - Unique identifier of the menu.
    * @param {string} itemText - The value of the `text` property for the item object that needs to be found in the menu.
    * @param {string} image - Full path to the new image or image filename, see {@link SetImageDir}.
    */
    static SetItemImage(menuId, itemText, image) {    
        if (!this.menus.HasOwnProp(menuId))
            return this.ShowErrorMsg(A_ThisFunc ' - Menu not found.', menuId)
        
        oMenu := this.menus.%menuId%
        
        for ring in oMenu.rings {
            for item in ring.items {
                if (item.text != itemText)
                    continue
                
                item.image  := image
                item.pImage := this.LoadImage(item.image, oMenu.SkinDir)
                
                if (!item.pImage)
                    return this.ShowErrorMsg(A_ThisFunc ' - Unable to load image: "' image '".', menuId)
                
                Gdip_DrawImage(oMenu.G, item.pImage, item.imgX, item.imgY, item.imgSize, item.imgSize)
                Gdip_DisposeImage(item.pImage)
                UpdateLayeredWindow(oMenu.hwnd, oMenu.hdc, 0, 0, oMenu.scaledSize, oMenu.scaledSize)
                
                return true
            }
        }
        return this.ShowErrorMsg(A_ThisFunc ' - Item not found: "' itemText '".', menuId)
    }
    ;=============================================================================================

    static GetMousePositionInfo(oMenu)
    {
        if (!oMenu.options.enableGlow && !oMenu.options.enableTooltip)
            return false

        CoordMode('Mouse', 'Screen')
        MouseGetPos(&mouseX, &mouseY, &hwndUnderMouse, &ctrlHwndUnderMouse, 2)

        if ((hwndUnderMouse != oMenu.hwnd && ctrlHwndUnderMouse)
        || !DllCall('IsWindowEnabled', 'Ptr', oMenu.hwnd, 'Int')
        || !DllCall('User32.dll\IsWindowVisible', 'Ptr', oMenu.hwnd)) {
            this.HideEffects(oMenu)
            return false
        }

        WinGetClientPos(&winX, &winY,,, oMenu.hwnd)
        menuCenterX := oMenu.scaledSize / 2
        menuCenterY := oMenu.scaledSize / 2
        menuRadius := oMenu.scaledSize / 2
        menuRadiusSquared := menuRadius ** 2
        distanceSquared := (mouseX - (winX + menuCenterX))**2 + (mouseY - (winY + menuCenterY))**2

        if (distanceSquared > menuRadiusSquared) {
            this.HideEffects(oMenu)
            return false
        }

        return {mouseX: mouseX, mouseY: mouseY}
    }

    ;=============================================================================================

    static HideEffects(oMenu)
    {
        if (oMenu.options.enableGlow)
            try oMenu.glowGui.Hide()

        if (oMenu.options.enableTooltip)
            this.HideTooltip(oMenu, oMenu.currentTooltip)

        oMenu.prevHoveredIndex := 0
    }

    ;=============================================================================================

    static HideTooltip(oMenu, ttHwnd)
    {
        ToolTip(,,, 20)
        oMenu.prevTooltipX := oMenu.prevTooltipY := oMenu.currentTooltip := 0
    }

    /*********************************************************************************************
     * @credits nperovic
     * @see {@link https://github.com/nperovic/ToolTipEx GitHub}
     */
    static UpdateTooltipPosition(oMenu, ttHwnd)
    {
        if (!WinExist(ttHwnd))
            return this.HideTooltip(oMenu, ttHwnd)

        SetWinDelay(-1)
        newX := newY := 0

        if (!this.CalculatePopupWindowPosition(ttHwnd, &newX, &newY))
            return this.HideTooltip(oMenu, ttHwnd)

        if (newX != oMenu.prevTooltipX || newY != oMenu.prevTooltipY) {
            try WinMove(newX, newY,,, 'ahk_id ' ttHwnd)
            oMenu.prevTooltipX := newX
            oMenu.prevTooltipY := newY
        }
    }

    ;=============================================================================================

    static UpdateMenuGlowTooltip(oMenu, *)
    {
        if (!mouseInfo := this.GetMousePositionInfo(oMenu))
            return

        if (itemInfo := this.FindHoveredItem(oMenu, mouseInfo.mouseX, mouseInfo.mouseY)) {
            if (oMenu.prevHoveredIndex != itemInfo.index) {
                oMenu.prevHoveredIndex := itemInfo.index

                if (oMenu.options.enableGlow) {
                    glowX := Round(itemInfo.winX + itemInfo.item.absX * oMenu.dpiScale)
                    glowY := Round(itemInfo.winY + itemInfo.item.absY * oMenu.dpiScale)
                    glowSize := Round(itemInfo.item.itemClickZoneSize * oMenu.dpiScale)
                    oMenu.glowGui.Show('x' glowX ' y' glowY ' w' glowSize ' h' glowSize ' NA')
                }

                if (oMenu.options.enableTooltip) {
                    this.HideTooltip(oMenu, oMenu.currentTooltip)

                    if (itemInfo.item.tooltip)
                        oMenu.currentTooltip := ToolTip(itemInfo.item.tooltip,,, 20)
                }
            }
            else if (oMenu.options.enableTooltip && oMenu.currentTooltip)
                this.UpdateTooltipPosition(oMenu, oMenu.currentTooltip)
        }
        else this.HideEffects(oMenu)
    }

    /*********************************************************************************************
     * @credits lexikos, nperovic
     * @see {@link https://www.autohotkey.com/boards/viewtopic.php?t=103459 AHK Forum}
     * @see {@link https://github.com/nperovic/ToolTipEx GitHub}
     */
    static CalculatePopupWindowPosition(hwnd, &newX, &newY)
    {
        static flags := (VerCompare(A_OSVersion, '6.2') < 0 ? 0 : 0x10000)
        try {
            winRect := Buffer(16, 0)
            DllCall('GetClientRect', 'Ptr', hwnd, 'Ptr', winRect)
            CoordMode('Mouse', 'Screen')
            MouseGetPos(&mouseX, &mouseY)
            anchorPt := Buffer(8, 0)
            NumPut('Int', mouseX + 16, 'Int', mouseY + 16, anchorPt)
            excludeRect := Buffer(16, 0)
            NumPut('Int', mouseX - 3, 'Int', mouseY - 3, 'Int', mouseX + 3, 'Int', mouseY + 3, excludeRect)
            outRect := Buffer(16, 0)
            DllCall('CalculatePopupWindowPosition', 'Ptr', anchorPt, 'Ptr', winRect.Ptr + 8, 'UInt', flags, 'Ptr', excludeRect, 'Ptr', outRect)
            newX := NumGet(outRect, 0, 'Int')
            newY := NumGet(outRect, 4, 'Int')
            return true
        }
        return false
    }

    ;=============================================================================================

    static PlaySound(sound)
    {
        if (!sound)
            return
        if (this.sounds.HasOwnProp(sound))
            sound := this.sounds.%sound%
        if (FileExist(sound))
            try this.PlayWavConcurrent(sound)
    }

    /*********************************************************************************************
     * Shows the menu at the current mouse position.
     * @param {string} menuId - Unique identifier of the menu.
     * @param {boolean} autoCenterMouse - Center mouse cursor when showing menu.
     */
    static Show(menuId, autoCenterMouse?)
    {
        if (!this.menus.HasOwnProp(menuId))
            return this.ShowErrorMsg(A_ThisFunc ' - Menu not found: "' menuId '".')

        oMenu := this.menus.%menuId%

        if (!oMenu.isFullyInitialized)
            return this.ShowErrorMsg(A_ThisFunc ' - Menu not fully initialized: "' menuId '".')

        if (DllCall('User32.dll\IsWindowVisible', 'ptr', oMenu.hwnd))
            this.Close(menuId, true)

        CoordMode('Mouse', 'Screen')
        MouseGetPos(&mouseX, &mouseY, &hwndUnderMouse)
        this.lastMenuOpenInfo := {mouseX: mouseX, mouseY: mouseY, hwndUnderMouse: hwndUnderMouse}
        this.ShowAt(oMenu, mouseX, mouseY, autoCenterMouse?)
    }

    ;=============================================================================================

    static ShowAt(oMenu, mouseX, mouseY, autoCenterMouse?)
    {
        menuSize := oMenu.scaledSize
        monIndex := this.MonitorGetMouseIsIn()
        MonitorGetWorkArea(monIndex, &waLeft, &waTop, &waRight, &waBottom)
        left := mouseX - menuSize / 2
        top := mouseY - menuSize / 2
        initialLeft := left
        initialTop := top
        left := Round(Max(waLeft, Min(left, waRight - menuSize)))
        top := Round(Max(waTop, Min(top, waBottom - menuSize)))
        shouldCenterMouse := (autoCenterMouse ?? oMenu.options.autoCenterMouse)

        if (shouldCenterMouse && (left != initialLeft || top != initialTop)) {
            menuCenterX := Round(left + menuSize / 2)
            menuCenterY := Round(top + menuSize / 2)
            CoordMode('Mouse', 'Screen')
            MouseMove(menuCenterX, menuCenterY, 0)
        }

        if (oMenu.options.enableTooltip || oMenu.options.enableGlow)
            this.RegisterHoverHandlers(oMenu)

        this.RegisterClickHandlers(oMenu)
        oMenu.gui.Opt('-Disabled')
        this.PlaySound(oMenu.options.soundOnShow)
        oMenu.gui.Show('x' left ' y' top ' ' (!oMenu.options.activateOnShow ? 'NA' : ''))
    }

    /*********************************************************************************************
     * Closes the entire menu tree of the specified menu.
     * @param {string} menuId - Unique identifier of the menu.
     * @param {boolean} suppressSound - Suppresses the menu close sound.
     */
    static Close(menuId, suppressSound := false, *)
    {
        if (!this.menus.HasOwnProp(menuId))
            return

        oMenu := this.menus.%menuId%

        if (!oMenu.isFullyInitialized || !DllCall('User32.dll\IsWindowVisible', 'ptr', oMenu.hwnd))
            return

        for submenuId in oMenu.submenuIds
            if (this.menus.HasOwnProp(submenuId))
                this.Close(submenuId, true)

        if (!suppressSound && !oMenu.parentMenuId)
            this.PlaySound(oMenu.options.soundOnClose)

        try oMenu.gui.Hide()

        if (oMenu.options.enableTooltip || oMenu.options.enableGlow)
            this.DeregisterHoverHandlers(oMenu)

        this.DeregisterClickHandlers(oMenu)
    }

    ;=============================================================================================

    static CloseMenu(menuId, suppressSound := false)
    {
        if (!this.menus.HasOwnProp(menuId))
            return

        oMenu := this.menus.%menuId%

        if (!oMenu.isFullyInitialized || !DllCall('User32.dll\IsWindowVisible', 'ptr', oMenu.hwnd))
            return

        parentMenu := (oMenu.parentMenuId ? this.menus.%oMenu.parentMenuId% : 0)

        if (!suppressSound)
            this.PlaySound(oMenu.options.soundOnClose)

        try oMenu.gui.Hide()

        if (oMenu.options.enableTooltip || oMenu.options.enableGlow)
            this.DeregisterHoverHandlers(oMenu)

        this.DeregisterClickHandlers(oMenu)

        if (parentMenu) {
            SetTimer(() => DllCall('User32.dll\EnableWindow', 'Ptr', parentMenu.hwnd, 'Int', 1), -75)
            parentMenu.gui.Opt('-Disabled')
            this.HideEffects(oMenu)

            if (parentMenu.options.enableTooltip || parentMenu.options.enableGlow)
                this.RegisterHoverHandlers(parentMenu)

            this.RegisterClickHandlers(parentMenu)
        }
    }

    ;=============================================================================================

    static ToggleSubmenu(parentMenu, submenuId, parentX, parentY, *)
    {
        if (!this.menus.%submenuId%.isFullyInitialized || !parentMenu.isFullyInitialized)
            return

        submenu := this.menus.%submenuId%
        submenuIsVisible := DllCall('User32.dll\IsWindowVisible', 'ptr', submenu.hwnd)

        if (submenuIsVisible) {
            this.CloseMenu(submenuId)
        } else {
            WinGetClientPos(&winLeft, &winTop,,, parentMenu.hwnd)
            offsetX := Round(parentX + parentMenu.options.itemSize/2)
            offsetY := Round(parentY + parentMenu.options.itemSize/2)
            screenX := Round(winLeft + (offsetX * parentMenu.dpiScale))
            screenY := Round(winTop + (offsetY * parentMenu.dpiScale))

            if (parentMenu.options.enableTooltip || parentMenu.options.enableGlow)
                this.DeregisterHoverHandlers(parentMenu)

            this.DeregisterClickHandlers(parentMenu)
            this.ShowAt(submenu, screenX, screenY)
            parentMenu.gui.Opt('+Disabled')
        }
    }

    ;=============================================================================================

    static OnLoseFocus(oMenu, wParam, lParam, msg, hwnd) {
        SetTimer(
            (*) => (WinExist('A') != oMenu.hwnd ) && this.Close(oMenu.id), 
            -100
        )
    }
    static OnClick(oMenu, clickName, wParam, lParam, msg, hwnd)
    {
        if (hwnd != oMenu.hwnd)
            return

        CoordMode('Mouse', 'Screen')
        MouseGetPos(&mouseX, &mouseY)
        WinGetClientPos(&winX, &winY,,, oMenu.hwnd)
        relX := (mouseX - winX) / oMenu.dpiScale
        relY := (mouseY - winY) / oMenu.dpiScale
        soundPlayed := false

        for (index, itemInfo in oMenu.itemList) {
            if (this.IsPointInCircularZone(itemInfo, relX, relY)) {
                if (itemInfo.isCenter) {
                    if (oMenu.parentMenuId && clickName == 'click')
                        return this.ToggleSubmenu(this.menus.%oMenu.parentMenuId%, oMenu.id, 0, 0)

                    clickName := 'center' clickName
                    action := oMenu.options.%clickName%
                    close := (action = 'close')
                } else {
                    ring := oMenu.rings[itemInfo.ringIdx]
                    item := ring.items[itemInfo.itemIdx]

                    if (clickName == 'click') {
                        switch {
                            case GetKeyState('Shift', 'P'):
                                result := GetActionAndClose(item, 'shiftClick')
                            case GetKeyState('Alt', 'P'):
                                result := GetActionAndClose(item, 'altClick')
                            case GetKeyState('Ctrl', 'P'):
                                result := (item.ctrlClick ? GetActionAndClose(item, 'ctrlClick') : {action: item.click, close: false})
                            default:
                                if (item.submenuId)
                                    return this.ToggleSubmenu(oMenu, item.submenuId, item.absX, item.absY)
                                result := GetActionAndClose(item, 'click')
                        }
                    } else result := GetActionAndClose(item, 'rightClick')

                    action := result.action
                    close := result.close

                    if (item.soundOnSelect && action)
                        this.PlaySound(item.soundOnSelect), soundPlayed := true
                }

                foundItem := true
                break
            }
        }

        if (!IsSet(foundItem)) {
            clickName := 'menu' clickName
            action := oMenu.options.%clickName%
            close := (Type(action) == 'String' && action = 'close')
        }

        if (close) {
            rootMenuId := oMenu.id
            while (this.menus.%rootMenuId%.parentMenuId)
                rootMenuId := this.menus.%rootMenuId%.parentMenuId
            this.Close(rootMenuId, soundPlayed)
        } else if (Type(action) == 'String') {
            switch action, false {
                case 'closeMenu':
                    return this.CloseMenu(oMenu.id, soundPlayed)
                case 'drag':
                    return PostMessage(0xA1, 2,,, oMenu.hwnd)
            }
        }

        this.RefreshTooltipZOrder(oMenu)

        if (action is Func)
            action.Call()

        ;==============================================

        GetActionAndClose(item, clickType) {
            action := item.%clickType%
            closeDefault := ((clickType = 'rightClick') ? item.closeOnItemRightClick : item.closeOnItemClick)

            if (Type(action) == 'String') {
                switch action, false {
                    case 'close':
                        return {action: action, close: true}
                    case 'closeMenu', 'drag':
                        return {action: action, close: false}
                    default:
                        return {action: action, close: closeDefault}
                }
            } else
                return {action: action, close: closeDefault}
        }
    }

    ;=============================================================================================

    static RegisterItemKeyBindings(oMenu)
    {
        for ringIdx, ring in oMenu.rings {
            for itemIdx, item in ring.items {
                if (item.isEmpty)
                    continue
                try {
                    for key in ['hotkeyClick', 'hotkeyRightClick', 'hotkeyShiftClick', 'hotkeyAltClick', 'hotkeyCtrlClick'] {
                        actionKey := StrReplace(key, 'hotkey', '')

                        if (Type(item.%key%) == 'String' && item.%key% && item.%actionKey% is Func)
                            Hotkey(item.%key%, item.%actionKey%, 'On')
                    }

                    for key in ['hotstringClick', 'hotstringRightClick', 'hotstringShiftClick', 'hotstringAltClick', 'hotstringCtrlClick'] {
                        actionKey := StrReplace(key, 'hotstring', '')

                        if (Type(item.%key%) == 'String' && item.%key% && item.%actionKey% is Func)
                            Hotstring(item.%key%, item.%actionKey%, 'On')
                    }
                } catch as e
                    throw Error(e.Message '`n`nDetails:`n- Menu: "' oMenu.id '"`n- Ring: ' ringIdx ', Item: ' itemIdx
                        . (e.HasOwnProp('Extra') ? '`n- Extra: ' e.Extra : ''))
            }
        }
    }

    ;=============================================================================================

    static RegisterClickHandlers(oMenu)
    {
        oMenu.boundFuncOnClick := this.OnClick.Bind(this, oMenu, 'click')
        oMenu.boundFuncOnRightClick := this.OnClick.Bind(this, oMenu, 'rightClick')
        if (oMenu.options.hideOnLoseFocus) {
            oMenu.boundFuncWmActivate := this.OnLoseFocus.Bind(this, oMenu)
            OnMessage(0x0006, oMenu.boundFuncWmActivate)  ; WM_ACTIVATE        
        }
        OnMessage(0x0201, oMenu.boundFuncOnClick) ; WM_LBUTTONDOWN
        OnMessage(0x0203, oMenu.boundFuncOnClick) ; WM_LBUTTONDBLCLK
        OnMessage(0x0204, oMenu.boundFuncOnRightClick) ; WM_RBUTTONDOWN
        OnMessage(0x0206, oMenu.boundFuncOnRightClick) ; WM_RBUTTONDBLCLK
    }

    ;=============================================================================================

    static DeregisterClickHandlers(oMenu)
    {
        if (oMenu.HasOwnProp('boundFuncOnClick'))
            OnMessage(0x0201, oMenu.boundFuncOnClick, 0)
        if (oMenu.HasOwnProp('boundFuncOnClick'))
            OnMessage(0x0203, oMenu.boundFuncOnClick, 0)
        if (oMenu.HasOwnProp('boundFuncOnRightClick'))
            OnMessage(0x0204, oMenu.boundFuncOnRightClick, 0)
        if (oMenu.HasOwnProp('boundFuncOnRightClick'))
            OnMessage(0x0206, oMenu.boundFuncOnRightClick, 0)
        if (oMenu.HasOwnProp('boundFuncWmActivate'))
            OnMessage(0x0006, oMenu.boundFuncWmActivate, 0)
    }

    ;=============================================================================================

    ; WM_MOUSEMOVE and a timer are used to ensure smooth and reliable glow and tooltip updates, while avoiding a while loop that would block the thread.
    static RegisterHoverHandlers(oMenu)
    {
        oMenu.boundFuncOnMouseMove := this.UpdateMenuGlowTooltip.Bind(this, oMenu)
        OnMessage(0x0200, oMenu.boundFuncOnMouseMove) ; WM_MOUSEMOVE
        oMenu.boundFuncTimerUpdateEffects := this.UpdateMenuGlowTooltip.Bind(this, oMenu)
        SetTimer(oMenu.boundFuncTimerUpdateEffects, 20)
    }

    ;=============================================================================================

    static DeregisterHoverHandlers(oMenu)
    {
        if (oMenu.HasOwnProp('boundFuncOnMouseMove'))
            OnMessage(0x0200, oMenu.boundFuncOnMouseMove, 0)
        if (oMenu.HasOwnProp('boundFuncTimerUpdateEffects'))
            SetTimer(oMenu.boundFuncTimerUpdateEffects, 0)
        this.HideEffects(oMenu)
    }

    ;=============================================================================================

    static RefreshTooltipZOrder(oMenu)
    {
        if (oMenu.currentTooltip && WinExist(oMenu.currentTooltip))
            WinMoveTop('ahk_id ' oMenu.currentTooltip)
    }

    ;=============================================================================================

    static ClampValue(value, key)
    {
        if (Type(value) = 'String' && RegExMatch(value, '^\s*-?\d*\.?\d+\s*$'))
            value := Number(value)

        if (!IsNumber(value))
            return this.originalDefaults.%key%

        range := this.range.%key%
        return this.CapDecimals(Max(range[1], Min(range[2], value)), 2)
    }

    ;=============================================================================================

    static CapDecimals(value, decimals := 2)
    {
        strVal := String(value)

        if (RegExMatch(strVal, '\.(\d+)', &m) && StrLen(m[1]) > decimals)
            return Round(value, decimals)

        return value
    }

    ;=============================================================================================

    static NormalizeFontOptions(str)
    {
        strFontopt := ''

        for option in ['Bold', 'Italic', 'Strikeout', 'Underline']
            if (InStr(str, option))
                strFontopt .= option ' '

        return RTrim(strFontopt)
    }

    ;=============================================================================================

    static DisposeResources()
    {
        for menuId, oMenu in this.menus.OwnProps()
            this.DisposeMenuResources(oMenu)
    }

    ;=============================================================================================

    static DisposeMenuResources(oMenu)
    {
        this.DisposeMenuSkinImages(oMenu)

        if (oMenu.HasOwnProp('G') && oMenu.G) {
            Gdip_DeleteGraphics(oMenu.G)
            oMenu.G := 0
        }

        if (oMenu.HasOwnProp('hdc') && oMenu.hdc) {
            SelectObject(oMenu.hdc, oMenu.obm)
            DeleteObject(oMenu.hbm)
            DeleteDC(oMenu.hdc)
            oMenu.hdc := 0
            oMenu.hbm := 0
        }

        if (oMenu.HasOwnProp('glowG') && oMenu.glowG) {
            Gdip_DeleteGraphics(oMenu.glowG)
            oMenu.glowG := 0
        }

        if (oMenu.HasOwnProp('glowHdc') && oMenu.glowHdc) {
            SelectObject(oMenu.glowHdc, oMenu.glowObm)
            DeleteObject(oMenu.glowHbm)
            DeleteDC(oMenu.glowHdc)
            oMenu.glowHdc := 0
            oMenu.glowHbm := 0
        }

        if (oMenu.HasOwnProp('gui') && oMenu.gui) {
            oMenu.gui.Destroy()
            oMenu.gui := 0
        }

        if (oMenu.HasOwnProp('glowGui') && oMenu.glowGui) {
            oMenu.glowGui.Destroy()
            oMenu.glowGui := 0
        }
    }

    ;=============================================================================================

    static DisposeMenuSkinImages(oMenu)
    {
        for key in this.imageKeyToFileName.OwnProps() {
            if (oMenu.HasOwnProp('p' key) && oMenu.p%key%) {
                Gdip_DisposeImage(oMenu.p%key%)
                oMenu.p%key% := 0
            }
        }
    }

    ;=============================================================================================

    static MonitorGetMouseIsIn()
    {
        CoordMode('Mouse', 'Screen')
        MouseGetPos(&mouseX, &mouseY)

        Loop MonitorGetCount() {
            MonitorGet(A_Index, &monLeft, &monTop, &monRight, &monBottom)
            if (mouseX >= monLeft && mouseX < monRight && mouseY >= monTop && mouseY < monBottom)
                return A_Index
        }
        return MonitorGetPrimary()
    }

    ;=============================================================================================

    static MonitorGetWindowIsIn(winTitle)
    {
        try WinGetPos(&posX, &posY, &winW, &winH, winTitle)
        catch
            return MonitorGetPrimary()

        centerWinX := posX + winW/2
        centerWinY := posY + winH/2

        Loop MonitorGetCount() {
            MonitorGet(A_Index, &monLeft, &monTop, &monRight, &monBottom)
            if (centerWinX >= monLeft) && (centerWinX < monRight) && (centerWinY >= monTop) && (centerWinY < monBottom)
                return A_Index
        }

        return MonitorGetPrimary()
    }

    ;=============================================================================================

    static GetDpiScale(hwnd)
    {
        dpi := DllCall('User32.dll\GetDpiForWindow', 'Ptr', hwnd, 'UInt')
        return dpi / 96.0
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

    static ArrayReverse(arr)
    {
        reversed := []
        for i, value in arr
            reversed.InsertAt(1, value)
        return reversed
    }

    ;=============================================================================================

    static ArrayToString(arr, delim)
    {
        for value in arr
            str .= value delim
        return RTrim(str, delim)
    }

    ;=============================================================================================

    static IsArrayOfArrays(arr)
    {
        if (arr.Length = 0)
            return false
        for item in arr
            if (Type(item) != 'Array')
                return false
        return true
    }

    ;=============================================================================================

    static Set_DHWindows_TMMode(dhw, tmm)
    {
        dhwPrev := A_DetectHiddenWindows
        tmmPrev := A_TitleMatchMode
        DetectHiddenWindows(dhw)
        SetTitleMatchMode(tmm)
        return {dhwPrev: dhwPrev, tmmPrev: tmmPrev}
    }

    /*********************************************************************************************
     * @credits Faddix, XMCQCX (minor modifications)
     * @see {@link https://www.autohotkey.com/boards/viewtopic.php?f=83&t=130425 AHK Forum}
     */
    static PlayWavConcurrent(fPath)
    {
        static obj := initialize()
        SplitPath(fPath,,, &ext)

        initialize() {
            if !hModule := DllCall("LoadLibrary", "Str", "XAudio2_9.dll", "Ptr")
                return false

            DllCall("XAudio2_9\XAudio2Create", "Ptr*", IXAudio2 := ComValue(13, 0), "Uint", 0, "Uint", 1)
            ComCall(7, IXAudio2, "Ptr*", &IXAudio2MasteringVoice := 0, "Uint", 0, "Uint", 0, "Uint", 0, "Ptr", 0, "Ptr", 0, "Int", 6) ; CreateMasteringVoice
            return { IXAudio2: IXAudio2, someMap: Map() }
        }

        if !obj || !RegExMatch(ext, 'i)^wav$')
            return

        ; freeing is unnecessary, but..
        XAUDIO2_VOICE_STATE := Buffer(A_PtrSize * 2 + 0x8)
        keys_to_delete := []
        for IXAudio2SourceVoice in obj.someMap {
            ComCall(25, IXAudio2SourceVoice, "Ptr", XAUDIO2_VOICE_STATE, "Uint", 0, "Int") ;GetState
            if (!NumGet(XAUDIO2_VOICE_STATE, A_PtrSize, "Uint")) { ; BuffersQueued (includes the one that is being processed)
                keys_to_delete.Push(IXAudio2SourceVoice)
            }
        }
        for IXAudio2SourceVoice in keys_to_delete {
            ComCall(20, IXAudio2SourceVoice, "Uint", 0, "Uint", 0) ;Stop
            ComCall(18, IXAudio2SourceVoice, "Int") ; void DestroyVoice
            obj.someMap.Delete(IXAudio2SourceVoice)
        }

        waveFile := FileRead(fPath, "RAW")

        if !root_tag_to_offset := get_tag_to_offset_map(0, waveFile.Size)
            return

        if !idk_tag_to_offset := get_tag_to_offset_map(root_tag_to_offset["RIFF"].ofs + 0xc, waveFile.Size)
            return

        WAVEFORMAT_ofs := idk_tag_to_offset["fmt "].ofs + 0x8
        data_ofs := idk_tag_to_offset["data"].ofs + 0x8
        data_size := idk_tag_to_offset["data"].size

        get_tag_to_offset_map(i, end) {
            tag_to_offset := Map()
            while (i + 8 <= end) { ; Ensure there's enough data for a chunk header
                tag := StrGet(waveFile.Ptr + i, 4, "UTF-8") ; RIFFChunk::tag
                size := NumGet(waveFile, i + 0x4, "Uint") ; RIFFChunk::size

                ; Stop execution and return false if chunk size exceeds file bounds
                if (i + 8 + size > end)
                    return false

                tag_to_offset[tag] := { ofs: i, size: size }
                ; Align to next 2-byte or 4-byte boundary
                i += size + 8
                if (i & 1) ; 2-byte alignment
                    i += 1
            }
            return tag_to_offset
        }

        ComCall(5, obj.IXAudio2, "Ptr*", &IXAudio2SourceVoice := 0, "Ptr", waveFile.Ptr + WAVEFORMAT_ofs, "int", 0, "float", 2.0, "Ptr", 0, "Ptr", 0, "Ptr", 0) ; CreateSourceVoice
        XAUDIO2_BUFFER := Buffer(A_PtrSize * 2 + 0x1c, 0)
        NumPut("Uint", 0x0040, XAUDIO2_BUFFER, 0x0) ; Flags=XAUDIO2_END_OF_STREAM
        NumPut("Uint", data_size, XAUDIO2_BUFFER, 0x4) ; AudioBytes
        NumPut("Ptr", waveFile.Ptr + data_ofs, XAUDIO2_BUFFER, 0x8) ; pAudioData
        ComCall(21, IXAudio2SourceVoice, "Ptr", XAUDIO2_BUFFER, "Ptr", 0) ; SubmitSourceBuffer
        ComCall(19, IXAudio2SourceVoice, "Uint", 0, "Uint", 0) ; Start
        obj.someMap[IXAudio2SourceVoice] := waveFile
    }
}

/*************************************************************************************************
 * @description: JSON格式字符串序列化和反序列化, 修改自[HotKeyIt/Yaml](https://github.com/HotKeyIt/Yaml)
 * 增加了对true/false/null类型的支持, 保留了数值的类型
 * @author thqby, HotKeyIt
 * @date 2024/02/24
 * @version 1.0.7
 ************************************************************************************************/
class JSON_thqby_Radify {
	static null := ComValue(1, 0), true := ComValue(0xB, 1), false := ComValue(0xB, 0)

	/**
	 * Converts a AutoHotkey Object Notation JSON string into an object.
	 * @param text A valid JSON string.
	 * @param keepbooltype convert true/false/null to JSON.true / JSON.false / JSON.null where it's true, otherwise 1 / 0 / ''
	 * @param as_map object literals are converted to map, otherwise to object
	 */
	static parse(text, keepbooltype := false, as_map := true) {
		keepbooltype ? (_true := this.true, _false := this.false, _null := this.null) : (_true := true, _false := false, _null := "")
		as_map ? (map_set := (maptype := Map).Prototype.Set) : (map_set := (obj, key, val) => obj.%key% := val, maptype := Object)
		NQ := "", LF := "", LP := 0, P := "", R := ""
		D := [C := (A := InStr(text := LTrim(text, " `t`r`n"), "[") = 1) ? [] : maptype()], text := LTrim(SubStr(text, 2), " `t`r`n"), L := 1, N := 0, V := K := "", J := C, !(Q := InStr(text, '"') != 1) ? text := LTrim(text, '"') : ""
		Loop Parse text, '"' {
			Q := NQ ? 1 : !Q
			NQ := Q && RegExMatch(A_LoopField, '(^|[^\\])(\\\\)*\\$')
			if !Q {
				if (t := Trim(A_LoopField, " `t`r`n")) = "," || (t = ":" && V := 1)
					continue
				else if t && (InStr("{[]},:", SubStr(t, 1, 1)) || A && RegExMatch(t, "m)^(null|false|true|-?\d+(\.\d*(e[-+]\d+)?)?)\s*[,}\]\r\n]")) {
					Loop Parse t {
						if N && N--
							continue
						if InStr("`n`r `t", A_LoopField)
							continue
						else if InStr("{[", A_LoopField) {
							if !A && !V
								throw Error("Malformed JSON - missing key.", 0, t)
							C := A_LoopField = "[" ? [] : maptype(), A ? D[L].Push(C) : map_set(D[L], K, C), D.Has(++L) ? D[L] := C : D.Push(C), V := "", A := Type(C) = "Array"
							continue
						} else if InStr("]}", A_LoopField) {
							if !A && V
								throw Error("Malformed JSON - missing value.", 0, t)
							else if L = 0
								throw Error("Malformed JSON - to many closing brackets.", 0, t)
							else C := --L = 0 ? "" : D[L], A := Type(C) = "Array"
						} else if !(InStr(" `t`r,", A_LoopField) || (A_LoopField = ":" && V := 1)) {
							if RegExMatch(SubStr(t, A_Index), "m)^(null|false|true|-?\d+(\.\d*(e[-+]\d+)?)?)\s*[,}\]\r\n]", &R) && (N := R.Len(0) - 2, R := R.1, 1) {
								if A
									C.Push(R = "null" ? _null : R = "true" ? _true : R = "false" ? _false : IsNumber(R) ? R + 0 : R)
								else if V
									map_set(C, K, R = "null" ? _null : R = "true" ? _true : R = "false" ? _false : IsNumber(R) ? R + 0 : R), K := V := ""
								else throw Error("Malformed JSON - missing key.", 0, t)
							} else {
								; Added support for comments without '"'
								if A_LoopField == '/' {
									nt := SubStr(t, A_Index + 1, 1), N := 0
									if nt == '/' {
										if nt := InStr(t, '`n', , A_Index + 2)
											N := nt - A_Index - 1
									} else if nt == '*' {
										if nt := InStr(t, '*/', , A_Index + 2)
											N := nt + 1 - A_Index
									} else nt := 0
									if N
										continue
								}
								throw Error("Malformed JSON - unrecognized character.", 0, A_LoopField " in " t)
							}
						}
					}
				} else if A || InStr(t, ':') > 1
					throw Error("Malformed JSON - unrecognized character.", 0, SubStr(t, 1, 1) " in " t)
			} else if NQ && (P .= A_LoopField '"', 1)
				continue
			else if A
				LF := P A_LoopField, C.Push(InStr(LF, "\") ? UC(LF) : LF), P := ""
			else if V
				LF := P A_LoopField, map_set(C, K, InStr(LF, "\") ? UC(LF) : LF), K := V := P := ""
			else
				LF := P A_LoopField, K := InStr(LF, "\") ? UC(LF) : LF, P := ""
		}
		return J
		UC(S, e := 1) {
			static m := Map('"', '"', "a", "`a", "b", "`b", "t", "`t", "n", "`n", "v", "`v", "f", "`f", "r", "`r")
			local v := ""
			Loop Parse S, "\"
				if !((e := !e) && A_LoopField = "" ? v .= "\" : !e ? (v .= A_LoopField, 1) : 0)
					v .= (t := m.Get(SubStr(A_LoopField, 1, 1), 0)) ? t SubStr(A_LoopField, 2) :
						(t := RegExMatch(A_LoopField, "i)^(u[\da-f]{4}|x[\da-f]{2})\K")) ?
							Chr("0x" SubStr(A_LoopField, 2, t - 2)) SubStr(A_LoopField, t) : "\" A_LoopField,
							e := A_LoopField = "" ? e : !e
			return v
		}
	}

	/**
	 * Converts a AutoHotkey Array/Map/Object to a Object Notation JSON string.
	 * @param obj A AutoHotkey value, usually an object or array or map, to be converted.
	 * @param expandlevel The level of JSON string need to expand, by default expand all.
	 * @param space Adds indentation, white space, and line break characters to the return-value JSON text to make it easier to read.
	 */
	static stringify(obj, expandlevel := unset, space := "  ") {
		expandlevel := IsSet(expandlevel) ? Abs(expandlevel) : 10000000
		return Trim(CO(obj, expandlevel))
		CO(O, J := 0, R := 0, Q := 0) {
			static M1 := "{", M2 := "}", S1 := "[", S2 := "]", N := "`n", C := ",", S := "- ", E := "", K := ":"
			if (OT := Type(O)) = "Array" {
				D := !R ? S1 : ""
				for key, value in O {
					F := (VT := Type(value)) = "Array" ? "S" : InStr("Map,Object", VT) ? "M" : E
					Z := VT = "Array" && value.Length = 0 ? "[]" : ((VT = "Map" && value.count = 0) || (VT = "Object" && ObjOwnPropCount(value) = 0)) ? "{}" : ""
					D .= (J > R ? "`n" CL(R + 2) : "") (F ? (%F%1 (Z ? "" : CO(value, J, R + 1, F)) %F%2) : ES(value)) (OT = "Array" && O.Length = A_Index ? E : C)
				}
			} else {
				D := !R ? M1 : ""
				for key, value in (OT := Type(O)) = "Map" ? (Y := 1, O) : (Y := 0, O.OwnProps()) {
					F := (VT := Type(value)) = "Array" ? "S" : InStr("Map,Object", VT) ? "M" : E
					Z := VT = "Array" && value.Length = 0 ? "[]" : ((VT = "Map" && value.count = 0) || (VT = "Object" && ObjOwnPropCount(value) = 0)) ? "{}" : ""
					D .= (J > R ? "`n" CL(R + 2) : "") (Q = "S" && A_Index = 1 ? M1 : E) ES(key) K (F ? (%F%1 (Z ? "" : CO(value, J, R + 1, F)) %F%2) : ES(value)) (Q = "S" && A_Index = (Y ? O.count : ObjOwnPropCount(O)) ? M2 : E) (J != 0 || R ? (A_Index = (Y ? O.count : ObjOwnPropCount(O)) ? E : C) : E)
					if J = 0 && !R
						D .= (A_Index < (Y ? O.count : ObjOwnPropCount(O)) ? C : E)
				}
			}
			if J > R
				D .= "`n" CL(R + 1)
			if R = 0
				D := RegExReplace(D, "^\R+") (OT = "Array" ? S2 : M2)
			return D
		}
		ES(S) {
			switch Type(S) {
				case "Float":
					if (v := '', d := InStr(S, 'e'))
						v := SubStr(S, d), S := SubStr(S, 1, d - 1)
					if ((StrLen(S) > 17) && (d := RegExMatch(S, "(99999+|00000+)\d{0,3}$")))
						S := Round(S, Max(1, d - InStr(S, ".") - 1))
					return S v
				case "Integer":
					return S
				case "String":
					S := StrReplace(S, "\", "\\")
					S := StrReplace(S, "`t", "\t")
					S := StrReplace(S, "`r", "\r")
					S := StrReplace(S, "`n", "\n")
					S := StrReplace(S, "`b", "\b")
					S := StrReplace(S, "`f", "\f")
					S := StrReplace(S, "`v", "\v")
					S := StrReplace(S, '"', '\"')
					return '"' S '"'
				default:
					return S == this.true ? "true" : S == this.false ? "false" : "null"
			}
		}
		CL(i) {
			Loop (s := "", space ? i - 1 : 0)
				s .= space
			return s
		}
	}
}
