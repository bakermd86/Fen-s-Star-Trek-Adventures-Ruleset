local KLUDGE_NODE_ID = 'chat_helper'
local SEPARATOR = '__'

function onInit()
    if Session.IsHost then
        DB.setPublic(DB.createNode(KLUDGE_NODE_ID), true)
        cleanKludges()
        for _, child in pairs(DB.getChildren('npc')) do
            handleActorNode(child)
        end
        for _, child in pairs(DB.getChildren('crewmate')) do
            handleActorNode(child)
        end
        DB.addHandler('npc', "onChildAdded", onNewChar)
        DB.addHandler('crewmate', "onChildAdded", onNewChar)
    end
end

function onNewChar(nodeParent, nodeChildAdded)
    handleActorNode(nodeChildAdded)
end

function handleActorNode(actorNode)
    addKludgeImage(actorNode)
    DB.addHandler(DB.getPath(actorNode, "token"), "onUpdate", function (nodeChild) handleUpdateChild(nodeChild, "token") end)
    DB.addHandler(DB.getPath(actorNode, "picture"), "onUpdate", function (nodeChild) handleUpdateChild(nodeChild, "picture") end)
end

function handleUpdateChild(nodeChild, nodeName)
    storeKludge(getKludgeNameFromChild(nodeChild), nodeName, DB.getValue(nodeChild))
end

function cleanKludges()
    for _, child in pairs(DB.getChildren(KLUDGE_NODE_ID)) do
        local childName = DB.getName(child)
        local nameParts = StringManager.split(childName, SEPARATOR)
        if (#nameParts == 2) then
            local parentType = nameParts[1]
            local childId = nameParts[2]
            local childNode = DB.findNode(parentType .. '.' .. childId)
            if (childNode == nil) then
                DB.deleteNode(child)
            end
        end
    end
end

function getKludgeName(dSource)
    local nodeName = DB.getName(dSource)
    local nodeParentName = DB.getName(DB.getParent(dSource))
    return DB.createNode(KLUDGE_NODE_ID .. '.' .. nodeParentName .. SEPARATOR .. nodeName)
end

function getKludgeNameFromChild(nodeChild)
    return getKludgeName(DB.getParent(nodeChild))
end

function storeKludge(dDest, nodeName, nodeSource)
    DB.setPublic(dDest, true)
    DB.setValue(dDest, nodeName, "token", nodeSource)
end

function addKludgeImage(dSource)
    local nodeToken = DB.getValue(dSource, "token")
    local nodePicture = DB.getValue(dSource, "picture")
    local dDest = getKludgeName(dSource)
    storeKludge(dDest, "token", nodeToken)
    storeKludge(dDest, "picture", nodePicture)
end
