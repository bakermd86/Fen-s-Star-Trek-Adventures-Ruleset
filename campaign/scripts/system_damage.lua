function onInit()
    self.scale = 0
    self.dMaxNode = ""
    self.breachNode = ""
end

function attachDB(rootNode)
    self.dMaxNode = DB.createChild(rootNode, "damage_max", "number")
    self.breachNode = DB.createChild(rootNode, "breaches_"..window.system.getValue(), "number")
    local scaleNode = DB.getChild(rootNode, "scale")

    handleScaleChange(scaleNode)
    DB.addHandler(scaleNode.getNodeName(), "onUpdate", handleScaleChange)
    DB.addHandler(self.breachNode.getNodeName(), "onUpdate", handleNodeChange)
end

function handleScaleChange(scaleNode)
    self.scale = DB.getValue(scaleNode, "", 0)
    DB.setValue(self.dMaxNode, "", "number", self.scale + 1)
    handleNodeChange(self.breachNode)
end

function handleNodeChange(breachNode)
    local breaches = DB.getValue(breachNode, "", 0)
    local systemStatus = 0
    if breaches > self.scale then
        systemStatus = 4
    elseif breaches == self.scale then
        systemStatus = 3
    elseif breaches >= (self.scale / 2) then
        systemStatus = 2
    elseif breaches >= 1 then
        systemStatus = 1
    end
    setValue(breaches)
    window.status.setValue(systemStatus)
end