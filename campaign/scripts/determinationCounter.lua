ADD_BONUS_DIE_BASE = " has used a point of Determination to add a natural one to the dice pool."
REMOVE_BONUS_DIE_BASE = " has cancelled the bonus die"

function createMessage(baseMsg)
    local message = ChatManager.createBaseMessage(window.getDatabaseNode().getNodeName(), Session.UserName)
    message.text = DB.getValue(window.getDatabaseNode(), "name", Session.UserName) .. baseMsg
    return message
end

function onButtonPress()
    if self.getValue() == 0 then
        local message = createMessage(REMOVE_BONUS_DIE_BASE)
        Comm.deliverChatMessage(message)
        window.determinationcounter.adjustCounter(1)
    end
    if window.determinationcounter.getCurrentValue() > 0 and self.getValue() == 1 then
        local message = createMessage(ADD_BONUS_DIE_BASE)
        Comm.deliverChatMessage(message)
        window.determinationcounter.adjustCounter(-1)
    end
end