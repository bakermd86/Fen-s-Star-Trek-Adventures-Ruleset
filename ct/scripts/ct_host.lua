local _ct_entries = {}
local _listOnEntrySelectionToggle = nil
local enableglobaltoggle = true;

function onInit()
    self.select_nextactor.onSelect = self.onSelect
    OptionsManager.setOption("RNDS", "on")
    CombatManager.setCustomRoundStart(self.changeRound)
    CombatManager.setCustomSort(staSortFunc)
    _actOrder = 1
    for _, ct_entry in ipairs(self.list.getWindows()) do
        local initresult = ct_entry.initresult.getValue()
        _actOrder = math.max(_actOrder, initresult)
    end
    _actOrder = _actOrder + 1
    _listOnEntrySelectionToggle = list.onEntrySectionToggle
    list.onEntrySectionToggle = onEntrySectionToggle
end

function onEntrySectionToggle()
    _listOnEntrySelectionToggle()
    local anyScores = 0

	for _,v in pairs(list.getWindows()) do
		if v.activate_scores.getValue() == 1 then
			anyScores = 1;
		end
    end

	enableglobaltoggle = false;
	button_global_scores.setValue(anyScores)
	enableglobaltoggle = true;
end

function toggleScores()
	if not enableglobaltoggle then
		return;
	end

	local scoreson = button_global_scores.getValue();
	for _,v in pairs(list.getWindows()) do
		v.activate_scores.setValue(scoreson);
	end
end

function toggleDamage()
	if not enableglobaltoggle then
		return;
	end

	local scoreson = button_global_scores.getValue();
	for _,v in pairs(list.getWindows()) do
		v.activate_damage.setValue(scoreson);
	end
end

function onSelect(value)
    if (_ct_entries[value].active.getValue() == 0) and Session.IsHost then
        CombatManager.requestActivation(_ct_entries[value].getDatabaseNode(), true)
        _ct_entries[value].initresult.setValue(_actOrder)
        _actOrder = _actOrder + 1
    end
    _ct_entries = {}
end

function changeRound(roundNum)
    for _, ct_entry in ipairs(self.list.getWindows()) do
        ct_entry.initresult.setValue(0)
        ct_entry.active.setValue(0)
    end
    _actOrder = 1
end

function populate_actors()
    local names = {}
    _ct_entries = {}
    for _, ct_entry in ipairs(self.list.getWindows()) do
        local initresult = ct_entry.initresult.getValue()
        local ct_name = ct_entry.name.getValue()
        if (initresult == 0) and ((ct_name or "") ~= "") then
            local list_name = ct_name
            local copy_counter = 1
            while(_ct_entries[list_name] ~= nil) do
                list_name = ct_name .. " (".. copy_counter .. ")"
                copy_counter = copy_counter + 1
            end
            table.insert(names, list_name)
            _ct_entries[list_name] = ct_entry
        end
    end
    return names
end

_actOrder = 1
function staSortFunc(node1, node2)
	local bHost = Session.IsHost;
	local sOptCTSI = OptionsManager.getOption("CTSI");

    local nActedOrder1 = DB.getValue(node1, "initresult", 0)
    local nActedOrder2 = DB.getValue(node2, "initresult", 0)

    if (nActedOrder1 ~= nActedOrder2) then
        if nActedOrder1 == 0 then
            return false
        elseif nActedOrder2 == 0 then
            return true
        else
            return nActedOrder1 < nActedOrder2
        end
    end

	local sFaction1 = DB.getValue(node1, "friendfoe", "");
	local sFaction2 = DB.getValue(node2, "friendfoe", "");

	if (sFaction1 ~= sFaction2) then
	    if sFaction1 == "friend" then
	        return true
        elseif sFaction2 == "friend" then
            return false
        elseif sFaction1 == "neutral" then
            return true
        elseif sFaction2 == "neutral" then
            return false
        end
	end

    local nValue1 = DB.getValue(node1, "daring", 0);
    local nValue2 = DB.getValue(node2, "daring", 0);
    if nValue1 == 0 then
        local class, recordname = DB.getValue(node1, "link")
        if (recordname or "") ~= "" then
            nValue1 = DB.getValue(recordname..".daring", 0)
        end
    end
    if nValue2 == 0 then
        local class, recordname = DB.getValue(node2, "link")
        if (recordname or "") ~= "" then
            nValue2 = DB.getValue(recordname..".daring", 0)
        end
    end

    if nValue1 ~= nValue2 then
        return nValue1 > nValue2
    end

	local sValue1 = DB.getValue(node1, "name", "");
	local sValue2 = DB.getValue(node2, "name", "");
	if sValue1 ~= sValue2 then
		return sValue1 < sValue2;
	end

	return node1.getPath() < node2.getPath();
end