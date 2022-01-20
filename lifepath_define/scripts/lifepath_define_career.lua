function onInit()
    self.header.subwindow.setName("Career Experience")
    self.name_header.subwindow.name.setValue("Step 5 - Career")
    self.usedVals = {}
    self.talent_mode_controls = {
        self.career_talent_mode_any,
        self.career_talent_mode_fixed
    }
    self.select_controls = {}
end

function onRowLoad()
    local node = self.getDatabaseNode()
    local class, talentNodePath = DB.getValue(node.getChild("results").getChild("id-00002"), "resultlink")
    Debug.chat(class)
    Debug.chat(talentNodePath)
    if talentNodePath ~= "" then
        local talentNode = DB.findNode(talentNodePath)
        self.career_talent_mode_fixed.onButtonPress()
        self.talent_define_subwindow.subwindow.talent_select.getWindows()[1].lifepath_drop_target.setLink(talentNode)
    end
end

function saveTalent(name, class, node)
    local resNode = self.career_talent_mode_fixed.resNode
    DB.setValue(resNode, "result", "string", name)
    DB.setValue(resNode, "resultlink", "windowreference", class, node.getNodeName())
end

function deleteTalentNode()
    local resNode = self.career_talent_mode_fixed.resNode
    DB.setValue(resNode, "result", "string", "")
    DB.setValue(resNode, "resultlink", "windowreference", "", "")
end

function resetTalentSelect(window, count, resNode)
    for _, w in ipairs(self.talent_mode_controls) do
        w.setBackColor(LifePathAlertHelper.COLOR_DESELECT)
    end
    if count == 0 then
        self.talent_define_subwindow.subwindow.talent_select.getWindows()[1].lifepath_drop_target.setDeselect()
        self.talent_select_mode.setValue("any")
        DB.setValue(resNode, "result", "string", "Any")
        self.talent_define_subwindow.setVisible(false)
    else
        self.talent_select_mode.setValue("fixed")
        self.talent_define_subwindow.setVisible(true)
    end
end