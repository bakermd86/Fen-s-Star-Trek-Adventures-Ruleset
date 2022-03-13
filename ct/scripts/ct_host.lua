local _ct_entries = {}
local _listOnEntrySelectionToggle = nil
local enableglobaltoggle = true;
local _orgRequestActiviation = nil

function onInit()
--     self.select_nextactor.onSelect = self.onSelect
    OptionsManager.setOption("RNDS", "on")
    CombatManager.setCustomRoundStart(self.changeRound)
    _actOrder = 1
    for _, ct_entry in ipairs(self.list.getWindows()) do
        local initresult = ct_entry.initresult.getValue()
        _actOrder = math.max(_actOrder, initresult)
    end
    _actOrder = _actOrder + 1
    _listOnEntrySelectionToggle = list.onEntrySectionToggle
    list.onEntrySectionToggle = onEntrySectionToggle
    _orgRequestActiviation = CombatManager.requestActivation
    CombatManager.requestActivation = requestActivation
end

function onEntrySectionToggle()
    _listOnEntrySelectionToggle()
    local anyScores = 0
    local anyDamages = 0

	for _,v in pairs(list.getWindows()) do
		if v.activate_scores.getValue() == 1 then
			anyScores = 1;
		end
		if v.activate_damage.getValue() == 1 then
		    anyDamages = 1;
        end
    end

	enableglobaltoggle = false;
	button_global_scores.setValue(anyScores)
	button_global_damage.setValue(anyDamages)
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

	local scoreson = button_global_damage.getValue();
	for _,v in pairs(list.getWindows()) do
		v.activate_damage.setValue(scoreson);
	end
end

function requestActivation(nodeEntry, bSkipBell)
    _orgRequestActiviation(nodeEntry, bSkipBell)
    CTHelper.updateInitiativeGroup(nodeEntry)
    DB.setValue(nodeEntry, "initresult", "number", _actOrder)
    _actOrder = _actOrder + 1
end

-- function onSelect(value)
--     if (_ct_entries[value]) and ((_ct_entries[value].active.getValue() == 0) and Session.IsHost) then
--         CombatManager.requestActivation(_ct_entries[value].getDatabaseNode(), true)
--         CTHelper.updateInitiativeGroup(_ct_entries[value].getDatabaseNode())
--         _ct_entries[value].initresult.setValue(_actOrder)
--         _actOrder = _actOrder + 1
--     end
--     _ct_entries = {}
--     ct_nextactor.setActive(false)
-- end

function changeRound(roundNum)
    for _, ct_entry in ipairs(self.list.getWindows()) do
        ct_entry.initresult.setValue(0)
        ct_entry.active.setValue(0)
    end
    CTHelper.updateInitiativeGroup()
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
