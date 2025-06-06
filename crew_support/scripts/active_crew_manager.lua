
TEMPLATE_NODE = "npctemplate@"
NPC_NODE_REQUEST = "npc_node_request"
NPC_CREW_REQUEST = "npc_crew_request"
NPC_CREW_RESPONSE = "npc_crew_response"
NPC_NODE_RESPONSE = "npc_node_response"
NPC_DELETE_REQUEST = "npc_delete_request"
CREW_SUPPORT_REQUEST = "crew_support_request"
SUPPORT_IMPROVE_REQUEST = "support_improve_request"
RELEASE_CHARACTERS = "release_char_request"
IMPROVEMENT_SHORTNAMES = {
    "N",
    "S",
    "A",
    "C",
    "R"
}
ACT_PEND = false
PLAYER_IDS = {}

function onInit()
    if Session.IsHost then
        OOBManager.registerOOBMsgHandler(NPC_NODE_REQUEST, handleNPCRequest)
        OOBManager.registerOOBMsgHandler(NPC_CREW_REQUEST, handleCrewRequest)
        OOBManager.registerOOBMsgHandler(NPC_DELETE_REQUEST, deleteNPCEntry)
        OOBManager.registerOOBMsgHandler(CREW_SUPPORT_REQUEST, handleCrewSupportRequest)
        OOBManager.registerOOBMsgHandler(SUPPORT_IMPROVE_REQUEST, handleSupportingCharacterImprovementRequest)
        DB.setPublic(csNode(), true)
        DB.setPublic(episodeNameNode(), true)
    end
    OOBManager.registerOOBMsgHandler(RELEASE_CHARACTERS, releaseCharacter)
    self.pendingDeleteNodes = {}
    self.pendingWindow = nil
    math.randomseed(os.time() - os.clock() * 1000);
--     Interface.onDesktopInit = self.onDesktopInit
end

function onTabletopInit()
    if Session.IsHost then return end
    User.addEventHandler("onIdentityStateChange", onIdentityStateChange)
    User.addEventHandler("onIdentityActivation", onIdentityActivation)
    local w = ChatManager.getChatWindow();
    if w then
        w.speaker.onSelect = onChatSelect
    end
end

function handleChatIdDeactivate(identity, user, activated)
    if (user == Session.UserName) and ((activated or "") == "" ) then
        local pDef = PLAYER_IDS[identity]
        if (pDef or "") ~= "" then
            replaceChatName(pDef["label"], nil)
        end
        PLAYER_IDS[identity] = {}
    end
end

function onIdentityStateChange(identityname, username, statename, state)
    if (statename ~= "current" and statename ~= "label") then return end
    if username ~= Session.UserName then return end
    local pDef = PLAYER_IDS[identityname]
    if (pDef or "") == "" then
        pDef = {}
    end
    local oVal = pDef[statename]
    pDef[statename] = state
    if (statename == "label") then
        replaceChatName(oVal, state)
    end
    if (statename == "current" and state == true) or (statename == "label" and pDef["current"] == true) then
        selectChatIdName(pDef["label"])
    end
    PLAYER_IDS[identityname] = pDef
end

function replaceChatName(oVal, nVal)
    if oVal == nVal then return end
    local w = ChatManager.getChatWindow();
    if (w or "") == "" then return end
    w.speaker.remove(oVal)
    if (nVal or "") == "" then return end
    w.speaker.add(nVal)
end

function syncChatNames()
    local w = ChatManager.getChatWindow();
    if (w or "") == "" then return end
    local activeNames = {}
    for i,v in ipairs(User.getOwnedIdentities()) do
        local sName = DB.getValue("charsheet." .. v .. ".name")
        if (sName or "") ~= "" then
            table.insert(activeNames, sName)
        end
    end
    w.speaker.clear()
    w.speaker.addItems(activeNames)
end

function selectChatIdName(sName)
    local w = ChatManager.getChatWindow();
    if (w or "") == "" then return end
    if (sName or "") == "" then return end
    w.speaker.setListValue(sName)
end

function getPlayerIdByName(sValue)
    for identity, pDef in pairs(PLAYER_IDS) do
        if sValue == pDef["label"] then
            return identity;
        end
    end
end

function onChatSelect(sValue)
    UserManager.activatePlayerID(CrewSupportManager.getPlayerIdByName(sValue));
end

function releaseCharacter(oobMsg)
    if User.getIdentityOwner(oobMsg.identity) then
        User.releaseIdentity(oobMsg.identity)
    end
end

function csNode()
    return DB.getRoot().createChild("crew_support")
end

function episodeNameNode()
    return csNode().createChild("episode_name", "string")
end

function episodeLinkNode()
    return csNode().createChild("episode_link", "windowreference")
end

function getSupportingCharacterByName(name)
    for _, charsheet in pairs(DB.getChildren("charsheet")) do
        if (DB.getValue(charsheet, "dead", 0) == 0) and
                (DB.getValue(charsheet, "available", 0) == 1) and
                (DB.getValue(charsheet, "name", "") == name) then
            return charsheet
        end
    end
end

function getSupportingCharacterNames()
    local crew = {}
    for _, charsheet in pairs(DB.getChildren("charsheet")) do
        if (DB.getValue(charsheet, "dead", 0) == 0) and
                (DB.getValue(charsheet, "available", 0) == 1) then
            table.insert(crew, DB.getValue(charsheet, "name", ""))
        end
    end
    return crew
end

function playerCrewSupportMaxNode()
    return DB.findNode(DB.getValue(csNode(), "player_crew_support_max_node"))
end

function handleSupportingCharacterImprovementRequest(oobMsg)
    if Session.IsHost then
        addEpisodeUsed(oobMsg.node)
        addSupportingCharacterImprovement(oobMsg.node)
    end
end

function requestSupportingCharacterImprovement(node)
    if DB.isOwner(node, Session.UserName)  then
        addEpisodeUsed(node)
        addSupportingCharacterImprovement(node.getNodeName())
    else
        local oobMsg = {
            ["type"]=SUPPORT_IMPROVE_REQUEST,
            ["node"]=node.getNodeName()
        }
        Comm.deliverOOBMessage(oobMsg, "")
    end
end

function addSupportingCharacterImprovement(nodeName)
    local m = DB.createChild(nodeName, "saved_milestones").createChild()
    DB.setValue(m, "source", "string", DB.getValue(".crew_support.episode_name", ""))
    DB.setValue(m, "type", "number", 3)
end

function addEpisodeUsed(node)
    local usedIn = DB.createChild(node, "episodes").createChild()
    DB.setValue(usedIn, "label", "string", DB.getValue(".crew_support.episode_name", ""))
end

function activateCrewMember(identity)
    local nodeName = DB.findNode("charsheet."..identity)
    DB.setValue(nodeName, "active", "number", 1)
end

function createNPCNode(user)
    local node = DB.createChild("npc")
    return node.getNodeName()
end

function handleNPCRequest(oobMsg)
    if Session.IsHost then
        local response = {
            ["type"]=oobMsg.callback,
            ["user"]=oobMsg.user,
            ["nodeName"]=createNPCNode(oobMsg.user)
        }
        DB.setOwner(response.nodeName, oobMsg.user)
        Comm.deliverOOBMessage(response, oobMsg.user)
    end
end

function getNewNPCNode(callback)
    if Session.IsHost then
        return createNPCNode(Session.UserName)
    else
        local oobmsg = {
            ["type"]=NPC_NODE_REQUEST,
            ["user"]=Session.UserName,
            ["callback"]=NPC_NODE_RESPONSE..Session.UserName
        }
        OOBManager.registerOOBMsgHandler(oobmsg.callback, callback)
        Comm.deliverOOBMessage(oobmsg, "")
    end
    return ""
end

function filterCrewNodes()
    local crew_members = {}
    for _, npc in pairs(DB.getChildren(".npc")) do
        if DB.getValue(npc, 'is_crew', 0) == 1 then
--             table.insert(crew_members, npc.getNodeName())
            crew_members[_] = npc.getNodeName()
        end
    end
    return crew_members
end

function getCrewNodes(callback)
    if Session.IsHost then
        callback(CrewSupportManager.filterCrewNodes())
    else
        local oobMsg = {
            ["type"]=NPC_CREW_REQUEST,
            ["user"]=Session.UserName,
            ["callback"]=NPC_CREW_RESPONSE..Session.UserName
        }
        OOBManager.registerOOBMsgHandler(oobMsg.callback, callback)
        Comm.deliverOOBMessage(oobMsg, "")
    end
end

function handleCrewRequest(oobMsg)
    local response = CrewSupportManager.filterCrewNodes()
    response.type = oobMsg.callback
    Comm.deliverOOBMessage(response, oobMsg.user)
end

function onIdentityActivation(identity, user, activated)
    if user ~= Session.UserName then return end
    if ACT_PEND then
        handleIdentity(activated, identity)
        ACT_PEND = false
    end
    handleChatIdDeactivate(identity, user, activated)
end

function handleIdentity(result, identity)
    if (result and identity) then
        activateCrewMember(identity)
        for _, nodeName in ipairs(self.pendingDeleteNodes) do
            DB.deleteNode(nodeName)
        end
        self.pendingDeleteNodes = {}
        if self.pendingWindow then self.pendingWindow.close() end
        self.pendingWindow = nil
    end
end

function requestCrewSupport(window)
    local oobMsg = {
        ["type"]=CREW_SUPPORT_REQUEST,
        ["node"]=window.getDatabaseNode().getNodeName()
    }
    Comm.deliverOOBMessage(oobMsg, "")
end

function handleCrewSupportRequest(oobMsg)
    if Session.IsHost then
        local node = DB.findNode(oobMsg.node)
        DB.setValue(node, "current_crew_support", "number", DB.getValue(node, "current_crew_support", 1) - 1)
    end
end

function checkSupportAvailable(window)
    return (Session.IsHost) or (DB.getValue(window.getDatabaseNode(), "current_crew_support", 0) >= 1)
end

function doGMSave(node, name)
    local noteBodies = {}
    for _, fieldName in ipairs({"Species", "Rank", "Gender", "Age", "Height", "Weight"}) do
        local field = string.lower(fieldName)
        table.insert(noteBodies, "<b>"..fieldName.."</b>: "..DB.getValue(node, field, ""))
    end
    local nodeText = "<p>" .. table.concat(noteBodies, "</p><p>") .. "</p>"
    DB.setValue(node, "notes", "formattedtext", nodeText)

    DB.setCategory(node, "Crew Support")
    GmIdentityManager.addIdentity(name)
    Interface.openWindow("npc", node)
end

function doGmReuse(node)
    Interface.openWindow("charsheet", node)
end

function updateFocuses(window)
    local char_main = window.main_frame.subwindow
    if char_main then
        local node = char_main.getDatabaseNode()
        DB.deleteChildren(node, "focuses")
        addFocus(node, window.focus1.getValue())
        addFocus(node, window.focus2.getValue())
        addFocus(node, window.focus3.getValue())
    end
end

function addFocus(node, name)
    local f = DB.createChild(node, "focuses").createChild()
    DB.setValue(f, "name", "string", name)
end

function addSpeciesTrait(node, name, link)
    local _, ref= link.getValue()
    local text = DB.getValue(DB.findNode(ref), "text", "")
    local t = DB.createChild(node, "traits").createChild()
    DB.setValue(t, "name", "string", name)
    DB.setValue(t, "text", "formattedtext", text)
end

function activateSupportingCharacter(window)
    if not(checkSupportAvailable(window)) and not(window.mode == "active") then
        Interface.dialogMessage(nil, "Crew Support cap exceeded, unable to activate any more supporting characters for this episode.",
                "Unable to proceed", "okcancel")
        return
    end
    if window.mode == "dead" then return end
    window.main_frame.saving = (window.mode == "custom")
    local charWindow = window.main_frame.subwindow
    local node = charWindow.getDatabaseNode()
    DB.deleteChild(node, "token")
    local name = DB.getValue(node, "name")
    if Session.IsHost then
        if window.main_frame.saving then
            doGMSave(node, name)
        else
            doGmReuse(node)
        end
        window.close()
    else
        self.pendingWindow = window
        local newActivation = (not (window.mode == "active"))
        if newActivation then requestCrewSupport(window) end
        if window.main_frame.saving then
            addSpeciesTrait(node, window.species.getValue(), window.species_link)
            LifePathSaveHelper.addShipRecord(node.getNodeName())
            DB.setValue(node, "available", "number", 1)
            DB.setValue(node, "maxstress", "number", DB.getValue(node, "fitness", 7) + DB.getValue(node, "security", 1))
            User.requestIdentity("", "charsheet", "name", node, handleIdentity)
            table.insert(self.pendingDeleteNodes, node.getNodeName())
            addEpisodeUsed(node)
        else
--             User.onIdentityActivation = onIdentityActivation -- For some reason the callback is not being invoked below
            ACT_PEND = true
            User.requestIdentity(node.getName(), "charsheet", "name", node, handleIdentity)
            if newActivation then
                requestSupportingCharacterImprovement(node)
            end
        end
    end
end

function getRandFromNodes(nodes)
    local val = math.random(#nodes)
    return nodes[val]
end

function getFocus()
    local focuses = STAModuleManager.getAllFromModules("focuses", "reference.focuses")
    if #focuses >= 1 then return getRandFromNodes(focuses) else
    return "" end
end

function getValue()
    local values = STAModuleManager.getAllFromModules("values", "reference.values")
    if #values >= 1 then return getRandFromNodes(values) else
    return "" end
end

function getTalent(scoreFilteredTalents)
    local allowedTalents = {}
    for _, nodeDef in ipairs(scoreFilteredTalents) do
        local node, filterKey = unpack(nodeDef)
        if filterKey == 1 then table.insert(allowedTalents, node) end
    end
    if #allowedTalents >= 1 then return getRandFromNodes(allowedTalents) else
    return "" end
end

function releaseCrew(node)
    DB.removeAllHolders(node)
    DB.setPublic(node, "true")
    DB.setValue(node, "active", "number", 0)
    Comm.deliverOOBMessage({
        ["type"]=RELEASE_CHARACTERS,
        ["identity"]=node.getName()
    }, User.getIdentityOwner(node.getName()))
end

function changeEpisode(episodeNode)
    local episodeName = DB.getValue(episodeNode, "name", "Untitled Episode")
    episodeNameNode().setValue(episodeName)
    episodeLinkNode().setValue("sta_episode", episodeNode.getNodeName())
    for nodeName, node in pairs(DB.getChildren("charsheet")) do
        local state = crewState(node)
        if (state == "available") or (state == "dead") or (state == "active") then
            releaseCrew(node)
        end
    end
    for nodeName, node in pairs(DB.getChildren("ship")) do
        DB.setValue(node, "current_crew_support", "number", DB.getValue(node, "max_crew_support", 0))
    end
end

function crewIsDead(crewNode)
    return DB.getValue(crewNode, "dead", 0) == 1
end

function crewIsAvailable(crewNode)
    return (DB.getValue(crewNode, "dead", 0) == 0) and
            (DB.getValue(crewNode, "available", 0) == 1)
end

-- function crewIsTemplate(crewNode)
--     return crewNode.getParent().getNodeName() == TEMPLATE_NODE..STAModuleManager.MODULE_MAIN
-- end

function crewIsActive(crewNode)
    return (DB.getValue(crewNode, "active", 0) == 1) and
            (DB.getValue(crewNode, "available", 0) == 1)
end

function isSheetPc(crewNode)
    return not (crewIsDead(crewNode) or crewIsActive(crewNode) or crewIsAvailable(crewNode))
end

function crewState(crewNode)
    if crewIsDead(crewNode) then return "dead"
    elseif crewIsActive(crewNode) then return "active"
    elseif crewIsAvailable(crewNode) then return "available"
    end
    return ""
end

function npcIsCrewNpc(npcNode)
    return DB.getValue(npcNode, "is_crew", 0) == 1
end