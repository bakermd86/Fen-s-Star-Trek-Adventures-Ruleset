function onInit()
	GameSystem.actions["character_score"] = { };
	ActionsManager.registerResultHandler("character_score", handleScoreResult);
	GameSystem.actions["damage_roll"] = { };
	ActionsManager.registerResultHandler("damage_roll", handleDamageResult);
    if User.isLocal() or User.isHost() then
        ChatManager.registerDeliverMessageCallback(insertNpcPortraits)
        -- Call change handler for all existing NPCs and charsheets at startup to create the dummy portraits (for NPCs) and map the names (for both)
        if Extension.getExtensionInfo("Fen's NPC Portrait Workaround") ~= nil then
            for _, npc_node in pairs(DB.getChildren("crewmate")) do
                NPCPortraitManager.handleNPCAdded(npc_node.getParent(), npc_node)
            end
        end
    end
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
    skillChatMessage(source, rRoll, successes, complications, dc, rRoll['crew_sender'], rRoll['crew_token'])
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
		gender = "None";
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

function skillChatMessage(rSource, rRoll, successes, complications, dc, crew_sender, crew_token)
    local rMessage = ActionsManager.createActionMessage(rSource, rRoll)
    if not(crew_sender == nil) then
        rMessage.sender = crew_sender .. " (" .. rRoll.sUser .. ")"
    end
    if not(crew_token == nil) then
        rMessage.icon = "portrait_" .. crew_token .. "_chat"
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