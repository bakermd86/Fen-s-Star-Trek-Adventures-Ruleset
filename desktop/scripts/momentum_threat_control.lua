local SET_CURVAL_REQ = "set_cur_val"
local GET_CURVAL_REQ = "get_cur_val"
local GET_CURVAL_RESP = "get_cur_val_response"
local _syncedNodes = {}

function onFirstLayout()
    local curValName = ""
    self.node = DB.getPath(window.getDatabaseNode(), sourcefields[1].current[1])
    self.name = display[1]
    if (User.isHost() or User.isLocal()) then
        OOBManager.registerOOBMsgHandler(SET_CURVAL_REQ..string.lower(self.name), handleCurValSet)
        DB.setPublic(self.node, true)
    end
    self.padSpacing()
    ChatManager.registerDropCallback("momentum_threat_token", doNothing)
end

function doNothing()
    return true
end
function notifyClientMomentum(user, curVal)
    local oobMsg = {
        ["type"] = GET_CURVAL_RESP..string.lower(self.name),
        ["curVal"] = curVal
    }
    Comm.deliverOOBMessage(oobMsg, user)
end

function handleCurValSet(oobMsg)
    if User.isHost() or User.isLocal() then
        setCounterVal(tonumber(oobMsg.newVal), oobMsg.msgSource)
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

function getCounterVal()
    return DB.getValue(self.node, 0)
end

function setCounterVal(newVal, msgSource)
    if self.node and (User.isHost() or User.isLocal()) then
        local curVal = getCounterVal()
        if newVal < 0  and curVal <= 0 then
            return
        elseif (newVal + curVal) > getMaxValue() then
            return
        end
        DB.setValue(self.node, "number", curVal + newVal)
        notifyOnToken(newVal, msgSource)
    else
        local oobMsg = {
            ["type"] = SET_CURVAL_REQ..string.lower(self.name),
            ["newVal"] = newVal,
            ["msgSource"] = msgSource
        }
        Comm.deliverOOBMessage(oobMsg, "")
    end
end


local _addBaseOneTokenMsg = "%s has added a point of %s to the pool"
local _spendBaseOneTokenMsg = "%s has used a point of %s from the pool"

function notifyOnToken(newVal, sourceName)
    local message = ChatManager.createBaseMessage("", sourceName)
    message.icon = string.lower(self.name) .. "_token"
--     message.text = sourceName
    if newVal > 0 then
        message.text = _addBaseOneTokenMsg:format(sourceName, self.name)
    else
        message.text = _spendBaseOneTokenMsg:format(sourceName, self.name)
    end
    Comm.deliverChatMessage(message)
end

function onDragStart(button, x, y, draginfo)
    draginfo.setType("momentum_threat_token")
    draginfo.setIcon(string.lower(self.name).."_token")
    return true
end

function onDragEnd(draginfo)
    setCounterVal(-1, getMsgSource())
    return true
end

function onDoubleClick()
    setCounterVal(1, getMsgSource())
    return true
end

function padSpacing()
    for _,v in ipairs(slots) do
        local anchor, nX, nY = v.getPosition()
        local nSpacingVal = 26 - tonumber(spacing[1]) / 2
        nX = nX + nSpacingVal
        nY = nY + nSpacingVal
        v.setPosition(anchor, nX, nY)
    end
end

function onClickDown()
    return false
end

function onClickRelease()
    return true
end

function onWheel(notches)
    if not Input.isControlPressed() then
        return false;
    end
    local dir = notches / math.abs(notches)
    for i=1,math.abs(notches) do
       setCounterVal(dir, getMsgSource())
    end
    return true
end