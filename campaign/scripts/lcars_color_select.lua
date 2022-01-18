widgetColorMain = nil;
widgetColorAlt = nil;
bDialogShown = false;

function onInit()
    mainColor = ColorHandler.getMainColor(getDatabaseNode())
    altColor = ColorHandler.getAltColor(getDatabaseNode())
	color_main.addBitmapWidget("colorgizmo_bigbtn_base");
	widgetColorMain = color_main.addBitmapWidget("colorgizmo_bigbtn_color");
	color_main.addBitmapWidget("colorgizmo_bigbtn_effects");

	color_alt.addBitmapWidget("colorgizmo_bigbtn_base");
	widgetColorAlt = color_alt.addBitmapWidget("colorgizmo_bigbtn_color");
	color_alt.addBitmapWidget("colorgizmo_bigbtn_effects");
    updateWidgetColors()
end

function onClose()
    resetDialog()
end

function resetDialog()
    if bDialogShown then
        Interface.dialogColorClose();
        bDialogShown = false
    end
end

function colorCallback(type, sResult, sColor)
    if sResult == "ok" or sResult == "cancel" then
        bDialogShown = false;
    end
    ColorHandler.handleColorDialog(type, getDatabaseNode(), sResult, sColor)
    updateWidgetColors()
end

function mainCallback(sResult, sColor)
    mainColor = sColor
    colorCallback("main", sResult, sColor)
end

function resetColors()
    ColorHandler.resetColors(getDatabaseNode())
    mainColor = ColorHandler.getMainColor(getDatabaseNode())
    altColor = ColorHandler.getAltColor(getDatabaseNode())
    updateWidgetColors()
end

function altCallback(sResult, sColor)
    altColor = sColor
    colorCallback("alt", sResult, sColor)
end

function handleMainColor()
    resetDialog()
    bDialogShown = Interface.dialogColor(mainCallback, ColorHandler.getMainColor(getDatabaseNode()))
end

function handleAltColor()
    resetDialog()
    bDialogShown = Interface.dialogColor(altCallback, ColorHandler.getAltColor(getDatabaseNode()))
end

function updateWidgetColors()
    widgetColorMain.setColor(mainColor)
    widgetColorAlt.setColor(altColor)
end