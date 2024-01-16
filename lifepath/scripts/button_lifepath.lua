-- function onInit()
--     STAModuleManager.setModuleVisibility(self)
-- end

function handleRootNodeResponse(oobMsg)
    if oobMsg.user == Session.UserName then
        local nodeName = oobMsg.nodeName
        openWizard(nodeName)
    end
end

function openWizard(nodeName)
    Interface.openWindow("lifepath", nodeName);
end

function onButtonPress()
    if Session.IsHost then
        local node = LifePathActionHelper.createNode(LifePathActionHelper.GM_USER)
        openWizard(node.getNodeName())
    else
        LifePathActionHelper.requestRootNode(handleRootNodeResponse)
    end

end