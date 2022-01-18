IMPROVEMENT_MAP = {
    ["attribute"]=1,
    ["discipline"]=1,
    ["value"]=4,
    ["talent"]=4,
    ["focus"]=3
}

ENTRY_CONTROLS = {
    ["Value"]={'text_entry_name', 'body_text'},
    ["Focus"]={'text_entry_name'},
    ["Attribute"]={'attribute_improve_control'},
    ["Discipline"]={'discipline_improve_control'},

}

function onInit()
    self.improve_type.setModes({"Attribute", "Discipline", "Value", "Talent", "Focus"})
    self.type = ""
    self.improve_type.setValue("Improvement Type");
    self.improve_type.setCallback(self.changeTypeControl)
end

function setDBNode(node)
    self.node = node
    self.improvements = DB.createChild(node, "improvements")
end

function addScore(score)
	local attWindow = self.lifepath_species_attribute_select.addWindow();
	attWindow.lifepath_attribute_select_control.setName(score);
	return attWindow
end

function changeTypeControl(type, newVal)
    self.type=type
    for k, v in pairs(ENTRY_CONTROLS) do
        for _, control in ipairs(v) do
            self[control].setReadOnly(not(k == type))
            self[control].setVisible(k == type)
        end
    end
end

function saveAttribute(attribute)
    local node = self.improvements.createChild("")
    DB.setValue(node, "type", "string", "attribute")
    DB.setValue(node, "name", "string", attribute)
    DB.setValue(node, "value", "number", 1)
end

function saveDiscipline(discipline)
    local node = self.improvements.createChild("")
    DB.setValue(node, "type", "string", "discipline")
    DB.setValue(node, "name", "string", discipline)
    DB.setValue(node, "value", "number", 1)
end

function saveFocus(focus)
    local node = self.improvements.createChild("")
    DB.setValue(node, "type", "string", "focus")
    DB.setValue(node, "name", "string", focus)
    DB.setValue(node, "value", "string", focus)
end

function saveLink(linkType, linkName, linkTarget)
    local node = self.improvements.createChild("")
    DB.setValue(node, "type", "string", linkType)
    DB.setValue(node, "name", "string", linkName)
    DB.setValue(node, "value", "string", linkTarget)
end

function saveImprovement(type, name, value)
    if type == "attribute" then self.saveAttribute(name)
    elseif type == "discipline" then self.saveDiscipline(name)
    elseif type == "focus" then self.saveFocus(name)
    else self.saveLink(type, name, value)
    end
end