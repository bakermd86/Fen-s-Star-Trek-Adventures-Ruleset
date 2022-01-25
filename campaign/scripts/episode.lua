_tabButtons = {}

function onInit()
	onStateChanged();
    registerMenuItem("Edit Colors", "categorystyle", 7)
    local cold_open = DB.getValue(getDatabaseNode(), "cold_open", "")
    if cold_open == "<p />" then
        DB.setValue(getDatabaseNode(), "cold_open", "formattedtext", "<frame>Captains Log, Stardate...</frame>")
    end
end

function onMenuSelection(selectNum)
    if selectNum == 7 then
        local w = Interface.openWindow("lcars_color_select", getDatabaseNode())
    end
end

function registerTabButton(tab, pageNum)
    _tabButtons[pageNum] = tab
end

function setTabColors(pageNum)
    for p, button in ipairs(_tabButtons) do
        local color = LifePathAlertHelper.COLOR_DESELECT
        if p == pageNum then
            color = ColorHandler.getMainColor(getDatabaseNode())
        elseif p == self.activeTab then
            ColorHandler.unregisterColorFrame(button, getDatabaseNode())
        end
        button.setBackColor(color)
    end
    self.activeTab = pageNum
end

function onLockChanged()
	onStateChanged();
end

function onStateChanged()
	if header.subwindow then
		header.subwindow.update();
	end
-- 	if main.subwindow then
-- 		main.subwindow.update();
-- 	end
	if notes.subwindow then
		notes.subwindow.update();
	end

	local bReadOnly = WindowManager.getReadOnlyState(getDatabaseNode());
	notes.setReadOnly(bReadOnly);
end
