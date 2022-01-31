SET_MOMENTUM_REQ = "set_momentum"
_syncedNodes = {}

function onInit()
    self.name = node[1]
    self.node = window.getDatabaseNode().."."..string.lower(self.name)
    if (User.isHost() or User.isLocal()) and self.name == "Momentum" then
        table.insert(_syncedNodes, self.node)
        OOBManager.registerOOBMsgHandler(SET_MOMENTUM_REQ, handleMomentumSet)
        User.onLogin = onLogin
        DB.addHandler(self.node, "onUpdate", synchronizeMomentumNodes)
    end
    self.setValue(DB.getValue(self.node, 0))
    self.setVis()
end

function onLogin(username, activated)
    if activated then
        local userNode = DB.createChild("playstateusers", username)
        DB.setOwner(userNode, username)
        local momentumNode = userNode.createChild("momentum", "number")
        DB.setValue(momentumNode, "", "number", DB.getValue(self.node))
        DB.addHandler(momentumNode.getNodeName(), "onUpdate", synchronizeMomentumNodes)
        table.insert(_syncedNodes, momentumNode.getNodeName())
    else
        local momentumNode = DB.createChild("playstateusers", username).createChild("momentum", "number")
        DB.removeHandler(momentumNode.getNodeName(), "onUpdate", synchronizeMomentumNodes)
    end
end

function synchronizeMomentumNodes(nodeChanged)
    local val = nodeChanged.getValue()
    local sNodeName = nodeChanged.getNodeName()
    setValue(val)
    for _, node in ipairs(_syncedNodes) do
        if node ~= sNodeName then
            DB.setValue(node, "number", val)
        end
    end
    self.setVis()
end

function setVis()
    if DB.getValue(self.node, 0) >= 18 then
        self.setVisible(true)
        window.counter.setVisible(false)
    else
        self.setVisible(false)
        window.counter.setVisible(true)
    end
end

function handleMomentumSet(oobmsg)
    if User.isHost() or User.isLocal() then
        local val = oobmsg["val"]
        local newVal = getValue() + val
        if newVal <= 0 then return end
        set(newVal)
    end
end

function getMsgSource()
    local sourceName = ""
    if User.isHost() or User.isLocal() then
        sourceName = "GM"
    else
        local identityNode = User.getCurrentIdentity()
        if (identityNode or "") ~= "" then
            sourceName = DB.getValue("charsheet."..identityNode..".name", "")
        end
        if sourceName == "" then
            sourceName = User.getUsername()
        end
    end
    return sourceName
end

function getMomentumThreatMessage()
    local sourceName = window.control.getMsgSource()
    local message = ChatManager.createBaseMessage("", sourceName)
    message.icon = string.lower(self.name) .. "_display_mini"
    message.text = sourceName
    return message
end

_addBaseMsgStart = " has added a point of "
_addBaseMsgEnd = " to the pool "
function notifyOnAdd()
    local message = self.getMomentumThreatMessage()
    message.text = message.text .. _addBaseMsgStart .. self.name .. _addBaseMsgEnd
    Comm.deliverChatMessage(message)
end

_spendBaseMsgStart = " has used a point of "
_spendBaseMsgEnd = " from the pool "
function notifyOnUse()
    local message = self.getMomentumThreatMessage()
    message.text = message.text .. _spendBaseMsgStart .. self.name .. _spendBaseMsgEnd
    Comm.deliverChatMessage(message)
end

function onDragStart(button, x, y, draginfo)
    draginfo.setType(self.name)
    return true
end

function onDragEnd(draginfo)
    local curVal = DB.getValue(self.node, 0)
    if curVal == 0 then return end
    DB.setValue(self.node, "number", curVal - 1)
    self.notifyOnUse()
end

function onDoubleClick()
    local curVal = DB.getValue(self.node, 0)
    DB.setValue(self.node, "number", curVal + 1)
    self.notifyOnAdd()
    return true
end