local _DBLinkedFields = {}

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
