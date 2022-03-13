local INITIATIVE_TAG = "[INITIATIVE] "

local _DBLinkedFields = {}
local REQUEST_TURN_MSG = "OOB_REQUEST_TURN_MSG"
local REQUEST_TURN_MSG_RESPONSE = "OOB_REQUEST_TURN_MSG_RESPONSE"
local REQUEST_INITIATIVE_MSG = "OOB_REQUEST_INITIATIVE_MSG"
local NOTIFY_INITIATIVE_MSG = "OOB_NOTIFY_INITIATIVE_MSG"

function onInit()
    CombatManager.setCustomSort(staSortFunc)
    if Session.IsHost then
        OOBManager.registerOOBMsgHandler(REQUEST_TURN_MSG, handleTurnRequest)
        OOBManager.registerOOBMsgHandler(REQUEST_INITIATIVE_MSG, handleInitiativeRequest)
    end
end

function linkCTField(ctField)
    local sNodeName = ""
    local class, sRecordName = DB.getValue(ctField.window.getDatabaseNode(), "link")
    if (class == "charsheet") and (sRecordName or "") ~= "" then
        local sValName = ctField.getDatabaseNode().getName()
        sNodeName = sRecordName .. '.' .. sValName
        ctField.setValue(DB.getValue(sNodeName))
        DB.addHandler(sNodeName, "onUpdate", updateLinkedField)
        _DBLinkedFields[sNodeName] = ctField
    end
    return sNodeName
end

function updateLinkedField(updatedNode)
    local ctField = _DBLinkedFields[updatedNode.getNodeName()]
    if (ctField or "") ~= "" then
        ctField.setValue(DB.getValue(updatedNode, ""))
    end
end

function updateInitiativeGroup(activeNode)
    local initiativeGroup = 0
    if ((activeNode or "") ~= "") and (DB.getValue(activeNode, "friendfoe") ~= "friend") then
        initiativeGroup = 1
    end
    setInitiativeGroup(initiativeGroup)
    setInitiativeKept(0)
end

function setInitiativeGroup(group)
    DB.setValue("combattracker.initiative_group", "number", group)
end

function getInitiativeGroup()
    return DB.getValue("combattracker.initiative_group", 0)
end

function setInitiativeKept(val)
    DB.setValue("combattracker.initiative_kept", "number", val)
end

function getInitiativeKept()
    return DB.getValue("combattracker.initiative_kept", 0)
end

function requestTurn()
    local identityActiveNode = User.getCurrentIdentity();
    local ctIdentityNode = CombatManager.getCTFromNode("charsheet." .. identityActiveNode)
    if (ctIdentityNode or "") ~= "" then
        local oobMsg = {
            ["type"]=REQUEST_TURN_MSG,
            ["identity"]=ctIdentityNode.getNodeName(),
            ["user"]=User.getUsername()
        }
        Comm.deliverOOBMessage(oobMsg, "")
    end
end

function turnAllowed(identity)
    local sActorName = DB.getValue(identity..".name")
    local curActor = CombatManager.getActiveCT()
    local curFriendFoe = DB.getValue(curActor, "friendfoe", "")
    if (curActor or "") == "" then
        return true
    elseif getInitiativeGroup() == 1 then
        return false
    elseif (getInitiativeGroup() == 0) then
        if (curFriendFoe == "friend") then
            return getInitiativeKept() == 1
        end
        return (curActor.getNodeName() ~= identity) and (DB.getValue(identity..".initresult", 0) == 0)
    else
        return false
    end
end

function handleTurnRequest(oobMsg)
    if turnAllowed(oobMsg.identity) then
        CombatManager.requestActivation(DB.findNode(oobMsg.identity))
    end
end

function requestInitiative(mode)
    local oobMsg = {
        ["type"]=REQUEST_INITIATIVE_MSG,
        ["identity"]=User.getCurrentIdentity(),
        ["user"]=User.getUsername()
    }
    if mode == "Keep Initiative" then
        oobMsg.keepInitiative = "TRUE"
    else
        oobMsg.keepInitiative = "FALSE"
    end
    Comm.deliverOOBMessage(oobMsg, "")
end

function handleInitiativeRequest(oobMsg)
    local msg = {font = "narratorfont", icon = "turn_flag"};
    if (oobMsg.keepInitiative == "TRUE") and initiativeAllowed() then
        if DB.getValue("combattracker.initiative_kept") == 0 then
            msg.text = INITIATIVE_TAG .. oobMsg.user .. " has used 2 momentum to seize the initiative!"
            setInitiativeGroup(0)
            setInitiativeKept(1)
            local momCur = DB.getValue("playstate.momentum")
            DB.setValue("playstate.momentum", "number", momCur-2)
        end
    elseif oobMsg.keepInitiative == "TRUE" then
        if DB.getValue("playstate.momentum", 0) >= 2 then
            msg.text = INITIATIVE_TAG .. "The initiative cannot be seized again until the opposing side has acted."
        else
            msg.text = INITIATIVE_TAG .. "Not enough momentum, seizing the initiative costs 2 momentum."
        end
    else
        setInitiativeGroup(1)
        msg.text = INITIATIVE_TAG .. "Hostile forces have the initiative!"
    end
    if (msg.text or "") ~= "" then
        Comm.deliverChatMessage(msg);
    end
end

function gmReleaseInitiative()
    local msg = {font = "narratorfont", icon = "turn_flag"};
    setInitiativeGroup(0)
    msg.text = INITIATIVE_TAG .. "Allied forces have the initiative!"
    Comm.deliverChatMessage(msg);
end

function initiativeAllowed()
    local turnOrder = {}
    local turnsTaken = {}
    for _, v in pairs(CombatManager.getCombatantNodes()) do
        local initRes = DB.getValue(v, "initresult", 0)
        if initRes ~= 0 then
            turnOrder[initRes] = DB.getValue(v, "friendfoe")
            table.insert(turnsTaken, initRes)
        end
    end
    table.sort(turnsTaken)
    local lastActorAlign = turnOrder[turnsTaken[#turnsTaken]]
    local priorActorAlign = turnOrder[turnsTaken[#turnsTaken-1]]
    return (not ((priorActorAlign == "friend") and (lastActorAlign == "friend"))) and
                DB.getValue("playstate.momentum", 0) >= 2
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