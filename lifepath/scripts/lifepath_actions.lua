LIFEPATH_CREATE_NOTE = "lifepath_create_note"

LIFEPATH_ROOT_NODE_REQUEST = "lifepath_root_node_request"
LIFEPATH_ROOT_NODE_RESPONSE = "lifepath_root_node_response"
GM_USER = "GM"
LP_NODE_ROOT = "lp_wizard"

function onInit()
    OOBManager.registerOOBMsgHandler(LIFEPATH_CREATE_NOTE, handleCreateNote)
    OOBManager.registerOOBMsgHandler(LIFEPATH_ROOT_NODE_REQUEST, handleRootNodeRequest)
end

function handleCreateNote(oobMsg)
    if Session.IsHost then
        local node = DB.createChild("notes");
        node.createChild("name", "string").setValue(oobMsg.name)
        node.createChild("text", "formattedtext").setValue(oobMsg.text);
        DB.setOwner(node, oobMsg.user)
        local oobMsgBack = {["type"]=oobMsg.callback, ["node"]=node.getNodeName(), ["name"]=oobMsg.name}
        Comm.deliverOOBMessage(oobMsgBack, oobMsg.user);
    end
end

function createNode(user)
    local node = DB.createChild(LP_NODE_ROOT, user)
    DB.deleteChildren(node)
    if not (user==GM_USER) then DB.setOwner(node, user) end
    return node
end

function handleRootNodeRequest(oobMsg)
    if Session.IsHost then
        local node = createNode(oobMsg["user"])
        local response = {
            ["type"]=oobMsg.callback,
            ["user"]=oobMsg.user,
            ["nodeName"]=node.getNodeName()
        }
        Comm.deliverOOBMessage(response, oobMsg.user);
    end
end

function requestRootNode(callbackFunc)
    local oobMsg = {
        ["type"]=LIFEPATH_ROOT_NODE_REQUEST,
        ["user"]=Session.UserName,
        ["callback"]=LIFEPATH_ROOT_NODE_RESPONSE..Session.UserName
    }
    OOBManager.registerOOBMsgHandler(oobMsg.callback, callbackFunc)
    Comm.deliverOOBMessage(oobMsg, "");
end