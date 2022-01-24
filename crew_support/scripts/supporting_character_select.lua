CUSTOM_ATTRIBUTE_LABELS = {
    {3, 3, "+3 to one Attribute"},
    {2, 4, "+2 to two Attributes"},
    {1, 2, "+1 to two Attributes"},
}
CUSTOM_DISCIPLINE_LABELS = {
    {3, 3, "+3 to one Discipline"},
    {2, 2, "+2 to one Discipline"},
    {1, 2, "+1 to two Disciplines"},
}

function onInit()
    self.mode = "available"
    available.setValue(1)
    self.filteredAttributes = {}
	GameSystem.actions["support_detail"] = { };
	ActionsManager.registerResultHandler("support_detail", handleSupportDetail);
    self.crewDefineFrames = getCrewDefineFrames()
    self.crewRollFrames = getCrewRollFrames()
    self.checkHomebrew()
end

function checkHomebrew()
    return
end

function getCrewDefineFrames()
    return {
        species_attribute_select,
        attribute_selection_count,
        focus1,
        focus2,
        focus3,
        species,
        random_focuses,
        name_select,
        species_link
    }
end

function deselectButtons()
    self.available.setBackColor(LifePathAlertHelper.COLOR_DESELECT)
    self.active.setBackColor(LifePathAlertHelper.COLOR_DESELECT)
    self.dead.setBackColor(LifePathAlertHelper.COLOR_DESELECT)
    self.custom.setBackColor(LifePathAlertHelper.COLOR_DESELECT)
end

function getCrewRollFrames()
    if STAModuleManager.modLoaded(STAModuleManager.MODULE_EXTRA) then
        table.insert(self.crewDefineFrames, roll_support_species)
        table.insert(self.crewDefineFrames, roll_support_name)
        return {
            roll_support_name,
        }
    end
    return {}
end

function onFirstLayout()
    STAModuleManager.checkModules()
end

function reTargetManifest()
    for _, w in ipairs(crew_manifest.getWindows()) do
        w.select_button.setTarget(main_frame)
    end
end

function clearManifestSelections()
    for _, w in ipairs(crew_manifest.getWindows()) do
        w.select_button.setValue(0)
    end
end

function showIdentities()
    local wChat = Interface.findWindow("chat", "");
    if wChat then
        wChat.speaker.setVisible(true)
        wChat.speakericon.setVisible(true)
    end
end

function incrementAttribute(attName, source)
	local attribute = string.lower(attName);
    local npcNode = main_frame.subwindow.getDatabaseNode()
    DB.setValue(npcNode, attribute, "number", DB.getValue(npcNode, attribute) + 1)
    --npc[attribute].setValue(npc[attribute].getValue() + 1)
    local remaining = source.getCount() - 1;
    if remaining == 0 then
        source.lock()
    end
    source.setCount(remaining);
end

function decrementAttribute(attName, source)
    if main_frame == nil then return end
	local attribute = string.lower(attName);
    local npc = main_frame.subwindow
    if not(npc == nil) then
        local npcNode = npc.getDatabaseNode()
        DB.setValue(npcNode, attribute, "number", DB.getValue(npcNode, attribute) - 1)
        --npc[attribute].setValue(npc[attribute].getValue() - 1)
    end
    local remaining = source.getCount() + 1;
    if remaining == 1 then
        source.unlock()
    end
    source.setCount(remaining);
end

function resetAttributeSelect()
    species_attribute_select.closeAll()

    for _, attribute in ipairs(ScopeManager.ALL_ATTRIBUTES) do
	    local attWindow = species_attribute_select.addWindow();
	    attWindow.lifepath_attribute_select_control.setName(attribute);
    end
    focus1.setValue("")
    focus2.setValue("")
    focus3.setValue("")
    name_select.setValue("")
end

function handleCrewFrame()
    if self.mode == "custom" then
        for _, frame in ipairs(self.crewDefineFrames) do
            frame.setVisible(true)
        end
        for _, button in ipairs(self.crewRollFrames) do button.onButtonPress() end
    end
end

function getAvailableScores(scores)
    local availableScores = {}
    for _, scoreName in ipairs(scores) do
        availableScores[string.lower(scoreName)] = (self.filteredAttributes[string.lower(scoreName)] == nil)
    end
    return availableScores
end

function updateControlScores(source)
    local availableScores = {}
    if source.scoreType == "attribute" then
        availableScores = getAvailableScores(ScopeManager.ALL_ATTRIBUTES)
    else
        availableScores = getAvailableScores(ScopeManager.ALL_DISCIPLINES)
    end
    for _, w in ipairs(custom_controls.getWindows()) do
        for __, control in ipairs(w.att_select.getWindows()) do
            if control.lifepath_attribute_select_control.selected then
                table.insert(availableScores, string.lower(control.lifepath_attribute_select_control.attName))
            end
        end
        if (w.att_select.scoreType == source.scoreType) then
            w.att_select.availableScores = availableScores
            w.att_select.applyFilter()
        end
    end
end

function rollCombinedDetails()
    local roll = {["aDice"]={
        "d20", -- Gender
        "d20", "d20", "d20", -- Height
        "d20", "d20", "d20", "d20", -- Weight
        "d6", "d6", "d6" -- Age + rank
    }, ["sType"]="support_detail"}
    for _, val in ipairs({"gender", "height", "weight", "age", "rank"}) do
	    DB.setValue(DB.findNode(main_frame.npcNode), val, "string", "")
    end
	ActionsManager.roll(nil, nil, roll, nil)
end

function handleSupportDetail(_, __, rRoll)
	if not self then return end
    local dice = rRoll['aDice']
    local gender = handleSupportGender(dice[1])
    local height = handleSupportHeight({ dice[2], dice[3], dice[4] }, gender)
    handleSupportWeight({ dice[5], dice[6], dice[7], dice[8] }, height)
    handleSupportAge({ dice[9], dice[10], dice[11] })
end

function handleSupportGender(die)
    local gender = RollManager.handleGender(die)
	DB.setValue(DB.findNode(main_frame.npcNode), "gender", "string", gender)
    return gender
end

function handleSupportHeight(dice, gender)
	local height = RollManager.handleHeight(dice, gender)
	DB.setValue(DB.findNode(main_frame.npcNode), "height", "string", height .. "cm")
    return height
end

function handleSupportWeight(dice, height)
    local weight = RollManager.handleWeight(dice, height)
	DB.setValue(DB.findNode(main_frame.npcNode), "weight", "string", weight .. "kg")
end

function handleSupportAge(dice)
    local firstDie = dice[1]['result']
    local baseAge = 24 - firstDie
    local rank = "Lt. Jg."
    if firstDie == 1 then
        baseAge = 18 - firstDie
        rank = "Ensign"
    elseif (firstDie == 6 ) then
        baseAge = 30 - firstDie
        rank = "Lt."
    end
    local nTotal = RollManager.sumDice(dice) + baseAge
    if (nTotal < 22) then rank = "Ensign" end
    DB.setValue(DB.findNode(main_frame.npcNode), "age", "string", nTotal)
    DB.setValue(DB.findNode(main_frame.npcNode), "rank", "string", rank)
end


function scoreSelected(scoreName, source)
    if source.getName() == "att_select" then
        local score = string.lower(scoreName)
        self.filteredAttributes[score] = true
        self.updateControlScores(source)
    end
end

function scoreDeselected(scoreName, source)
    if source.getName() == "att_select" then
        local score = string.lower(scoreName)
        self.filteredAttributes[score] = nil
        self.updateControlScores(source)
    end
end

function checkCustom(mode)
    if mode == "custom" then
        crew_manifest.setVisible(false)
        custom_controls.closeAll()
        custom_controls.setVisible(true)
        for step_id, body in ipairs(CUSTOM_ATTRIBUTE_LABELS) do
            local val, count, label = unpack(body)
            local w = custom_controls.createWindow()
            w.label.setValue(label)
            w.multicount.setValue(val)
            w.counter.setValue(count)
            w.step_id.setValue(step_id)
            w.att_select.setScoreType("attribute")
            w.att_select.setWindow(self)
            w.att_select.addScores(ScopeManager.ALL_ATTRIBUTES)
            w.att_select.applyFilter()
        end
        for step_id, body  in ipairs(CUSTOM_DISCIPLINE_LABELS) do
            local val, count, label = unpack(body)
            local w = custom_controls.createWindow()
            w.label.setValue(label)
            w.multicount.setValue(val)
            w.counter.setValue(count)
            w.step_id.setValue(step_id+10)
            w.att_select.setScoreType("discipline")
            w.att_select.setWindow(self)
            w.att_select.addScores(ScopeManager.ALL_DISCIPLINES)
            w.att_select.applyFilter()
        end
        main_frame.addNPC()
        random_focuses.onButtonPress()
    else
        main_frame.closeAll()
        crew_manifest.setVisible(true)
        custom_controls.closeAll()
        custom_controls.setVisible(false)
    end
end

function handleMode(mode, modeControl)
    available.setValue(0)
    active.setValue(0)
    dead.setValue(0)
    custom.setValue(0)
    modeControl.setValue(1)
    if not(mode == self.mode) then
        main_frame.closeAll()
        clearManifestSelections()
    end
    self.mode = mode
    crew_manifest.setMode(mode)
    if self.crewDefineFrames then
        for _, frame in ipairs(self.crewDefineFrames) do frame.setVisible(false) end
    end
    checkCustom(mode)
    handleCrewFrame()
end
