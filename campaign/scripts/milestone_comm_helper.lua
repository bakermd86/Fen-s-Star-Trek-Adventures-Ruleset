NODE_DELETE_REQ = "node_delete_req"
NODE_ADD_CHILD_REQ = "node_add_child_req"
NODE_CHANGE_VALUE_REQ = "node_change_value_req"

function onInit()
    if User.isHost() then
        OOBManager.registerOOBMsgHandler(NODE_DELETE_REQ, handleDeleteNode)
        OOBManager.registerOOBMsgHandler(NODE_ADD_CHILD_REQ, handleAddChildNode)
        OOBManager.registerOOBMsgHandler(NODE_CHANGE_VALUE_REQ, handleNodeValueChange)
    end
end

function handleDeleteNode(oobMsg)
    if User.isHost() then
        DB.deleteNode(oobMsg.node)
        if oobMsg.callback then
            oobMsg["type"]=oobMsg.callback
            Comm.deliverOOBMessage(oobMsg, oobMsg.user)
        end
    end
end

function handleAddChildNode(oobMsg)
    if User.isHost() then
        local node = DB.createChild(oobMsg.node, oobMsg.parent).createChild()
        DB.setOwner(node, oobMsg.user)
        if oobMsg.callback then
            oobMsg["type"]=oobMsg.callback
            oobMsg["node"]=node.getNodeName()
            Comm.deliverOOBMessage(oobMsg, oobMsg.user)
        end
    end
end

function handleNodeValueChange(oobMsg)
    if User.isHost() then
        DB.setValue(oobMsg.node, oobMsg.node_type, oobMsg.value)
        if oobMsg.callback then
            oobMsg["type"]=oobMsg.callback
            Comm.deliverOOBMessage(oobMsg, oobMsg.user)
        end
    end
end