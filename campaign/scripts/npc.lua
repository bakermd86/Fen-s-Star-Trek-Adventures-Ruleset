_tabButtons = {}

function onInit()
	onStateChanged();
	onIDChanged();
                registerMenuItem("Edit Colors", "categorystyle", 7)
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
	if main.subwindow then
		main.subwindow.update();
	end
	if notes.subwindow then
		notes.subwindow.update();
	end
	if combat.subwindow then
		combat.subwindow.update();
	end

	local bReadOnly = WindowManager.getReadOnlyState(getDatabaseNode());
	notes.setReadOnly(bReadOnly);
end

function onIDChanged()
	onNameUpdated();
	if header.subwindow then
		header.subwindow.updateIDState();
	end
	if Session.IsHost then
		if main.subwindow then
			main.subwindow.update();
		end
	else
		local bID = LibraryData.getIDState("npc", getDatabaseNode(), true);
		tabs.setVisibility(bID);
	end
end

function onNameUpdated()
	local nodeRecord = getDatabaseNode();
	local bID = LibraryData.getIDState("npc", nodeRecord, true);

	local sTooltip = "";
	if bID then
		sTooltip = DB.getValue(nodeRecord, "name", "");
		if sTooltip == "" then
			sTooltip = Interface.getString("library_recordtype_empty_npc")
		end
	else
		sTooltip = DB.getValue(nodeRecord, "nonid_name", "");
		if sTooltip == "" then
			sTooltip = Interface.getString("library_recordtype_empty_nonid_npc")
		end
	end
	setTooltipText(sTooltip);
	if header.subwindow and header.subwindow.link then
		header.subwindow.link.setTooltipText(sTooltip);
	end
end
