GET_NPC_PORTRAIT = "get_npc_portrait"

function onInit()
    self.rollSourceNode = nil
    self.sourceRollWindows = {}
    self.lastRollControlWindow = nil
	GameSystem.actions["character_score"] = { };
	ActionsManager.registerResultHandler("character_score", handleScoreResult);
	ChatManager.registerDropCallback("dice", handleManualDrop)
	GameSystem.actions["damage_roll"] = { };
	ActionsManager.registerResultHandler("damage_roll", handleDamageResult);
end

function determinationUsed(window)
    if not window or (window.getClass() ~= "charsheet_rolls") then return nil end
    local detControl = window.parentcontrol.window.header.subwindow.determinationDieControl
    if detControl.getValue() == 1 then
        detControl.setValue(0)
        return "TRUE"
    end
    return nil
end

function getScoreMod(window)
    local att, attName = window.activeAttribute.getValue(), window.activeAttributeName.getValue()
    local disc, discName = window.activeDiscipline.getValue(), window.activeDisciplineName.getValue()
    local dc = window.rollDC.getValue()
    local focus ;
    if window.focuses then
        focus = window.focuses.getSelected()
    end
    return formatMod(att, attName, disc, discName, dc, focus)
end

function formatMod(att, attName, disc, discName, dc, focus)
    local desc = "[" .. attName.." ("..att..") + "..discName.." ("..disc.. ")]"
    if focus and not(focus.getValue() == "") then desc = desc .. "\n[Focus: " .. focus.getValue() .. " ]" end
    return { att, disc, dc, focus, desc, attName, discName }
end

function handleScoreSelected(sourceRollWindow)
    if self.rollSourceNode ~= sourceRollWindow.window.getDatabaseNode() then
        self.clearScoreSelect()
        self.rollSourceNode = sourceRollWindow.window.getDatabaseNode()
    end
    table.insert(self.sourceRollWindows, sourceRollWindow)
    self.lastRollControlWindow = sourceRollWindow.rollControl().window
end

function clearScoreSelect()
    for _, w in ipairs(self.sourceRollWindows) do
        if (w or "") ~= "" and (type(w) == "windowlist") then
            w.clearSelections()
        end
    end
    self.sourceRollWindows = {}
    self.rollSourceNode = nil
    if self.lastRollControlWindow ~= nil and type(self.lastRollControlWindow) == "windowlist" then
        self.lastRollControlWindow.activeAttribute.setScore("", 0)
        self.lastRollControlWindow.activeDiscipline.setScore("", 0)
    end
    self.lastRollControlWindow = nil
end

function buildSkillRoll(window, dice, scoreOverride)
    local att, disc, dc, focus, desc, attName, discName;
    if scoreOverride ~= nil then
        att, disc, dc, focus, desc, attName, discName = unpack(scoreOverride)
    else
        att, disc, dc, focus, desc, attName, discName = unpack(getScoreMod(window))
    end
    local roll = {
        ["aDice"] =dice,
        ["sType"]="character_score",
        ["desc"]=desc,
        ["nMod"]=0,
        ["att"]=att,
        ["attName"]=attName,
        ["disc"]=disc,
        ["discName"]=discName,
        ["dc"]=dc,
        ["focus"]=nil,
        ['sUser']=User.getUsername(),
        ['determination']=determinationUsed(window),
        ["sNode"]=window.getDatabaseNode().getNodeName()
    }
    if focus and not(focus.getValue() == "")then
        roll['focus'] = focus.getValue()
    end
    return roll
end

function checkRoll(rRoll)
    if not rRoll then return false
    else return (rRoll.att > 0) and (rRoll.disc > 0)
    end
end

function handleManualDrop(draginfo)
    local dice = draginfo.getDieList()
    if dice[1]['type'] ~= "d20" then return false
    elseif #self.sourceRollWindows < 2 then return false
    end
    local rRoll = buildSkillRoll(lastRollControlWindow, dice)
    buildScoreDrag(draginfo, rRoll)
end

function buildScoreDrag(draginfo, rRoll)
    if not checkRoll(rRoll) then return false end
    draginfo.setType(rRoll["sType"])
    draginfo.setDieList(rRoll["aDice"])
    for k, v in pairs(rRoll) do
        draginfo.setMetaData(k, v)
    end
    if (rRoll["sNode"] or "") ~= "" then
        draginfo.addShortcut(ActorManager.getRecordType(rRoll["sNode"]), rRoll["sNode"])
    end
    return true
end

function displayRawRoll(rSource, rTarget, rRoll)
    local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
    Comm.deliverChatMessage(rMessage);
end

function handleDamageResult(rSource, rTarget, rRoll)
    local damage = 0
    local effects = 0
    for _, die in ipairs(rRoll.aDice) do
        local v = die.value
        if v == 1 then
            damage = damage + 1
        elseif v == 2 then
            damage = damage + 2
        elseif (v == 5) or (v==6) then
            die.value=1
            damage = damage + 1
            effects = effects + 1
            die.type = "dChallenger"..v
        else
            die.value=0
            die.result=0
        end
    end

    local rMessage = ChatManager.createBaseMessage(rSource, rRoll.sUser);
    rMessage.type = rRoll.sType;
    rMessage.text = rMessage.text .. " [Damage: " .. damage .. "]"
    rMessage.text = rMessage.text .. " [Effects: " .. effects .. "]"
    rMessage.text = rMessage.text .. rRoll.sDesc;
    rMessage.dice = rRoll.aDice;

    if rRoll.bSecret then
      rMessage.secret = true;
      if rRoll.bTower then
        rMessage.icon = "dicetower_icon";
      end
    elseif User.isHost() and OptionsManager.isOption("REVL", "off") then
      rMessage.secret = true;
    end
    rMessage.dicedisplay = 0;

    Comm.deliverChatMessage(rMessage);
    return true;
end

function handleScoreResult(source, target, rRoll)
    rRoll["sDesc"] = rRoll["desc"]
    local att, disc, dc = tonumber(rRoll['att']), tonumber(rRoll['disc']), tonumber(rRoll['dc'])
    local dice, focus = rRoll['aDice'], rRoll['focus']
    local successes = 0
    local detUsed = rRoll.determination
    if detUsed then
        successes = 2
    end
    local complications = 0
    for _, die in ipairs(dice) do
        local val = die['result']
        if val <= att+disc then successes = successes + 1 end
        if focus and (val <= disc) then successes = successes + 1
        elseif val == 1 then successes = successes + 1 end
        if val == 20 then complications = complications + 1 end
    end
    skillChatMessage(source, rRoll, successes, complications, dc)
    self.clearScoreSelect()
end

function sumDice(dice)
	local nTotal = 0
    for _, d in ipairs(dice) do
        nTotal = nTotal + d['result']
    end
    return nTotal
end

function handleGender(die)
    local nTotal = die['result']
	local gender;
	if nTotal == 1 then
		gender = "None/Other";
	elseif nTotal == 20 then
		gender = "2 Or More";
	elseif nTotal % 2 == 0 then
		gender = "Male";
	else
		gender = "Female";
	end
    return gender
end

function handleHeight(dice, gender)
    local nTotal = RollManager.sumDice(dice)
	local baseHeight = 135
	if gender == "Male" then
		baseHeight = 140
	elseif gender == "Female" then
		baseHeight = 130
	end
	local height = nTotal + baseHeight;
    return height
end

function handleWeight(dice, height)
    local nTotal = RollManager.sumDice(dice)
	local weight = (((nTotal + 175) * height^2) - ((nTotal + 175) * height^2) % 100000) / 100000;
    return weight
end

function skillChatMessage(rSource, rRoll, successes, complications, dc)
    local sourceName = ""
    if not rSource and (rRoll['sNode'] or "") ~= "" then
        rSource = ActorManager.resolveActor(rRoll['sNode'])
    end
    if rSource and rSource["sName"] ~= "" then sourceName = rSource["sName"] end
    local rMessage = ActionsManager.createActionMessage(rSource, rRoll)
    if sourceName == "" and (rRoll['sNode'] or "") ~= "" then
        sourceName = DB.getValue(DB.findNode(rRoll['sNode']), "name", "")
        if sourceName ~= "" then rMessage.sender = sourceName end
    end
    if NPCPortraitManager and (rRoll['sNode'] or "") ~= "" then
        local npc_node = DB.findNode(rRoll['sNode'])
        if npc_node ~= nil and npc_node.getParent().getName() ~= "charsheet" and DB.getValue(npc_node, "token", "") ~= "" then
            portraitName = NPCPortraitManager.formatDynamicPortraitName(npc_node)
            if portraitName ~= "" then
                rMessage.icon = "portrait_" .. portraitName .. "_chat"
            end
        end
    end
    rMessage.dicedisplay = 0
    rMessage.text = rMessage.text .. "\n[Successes: "..successes.."] [Complications: "..complications .. "]"
    if successes >= dc then
        rMessage.text = rMessage.text .. "\nSuccess with " .. successes - dc .. " momentum"
    else
        rMessage.text = rMessage.text .. "\nFailed on DC: " .. dc
    end
    Comm.deliverChatMessage(rMessage);
end