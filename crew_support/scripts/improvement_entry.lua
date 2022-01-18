function onInit()
    if not(self.type.getValue() == nil) then
        self.improvement_select.setValue(self.type.getValue())
    end
    if not(self.episode.getValue() ==
            DB.getRoot().createChild("crew_support").createChild("episode_name", "string").getValue()) then
        self.lockControl()
    end
    DB.addHandler(DB.getRoot().createChild("crew_support").createChild("episode_name", "string").getNodeName(), "onUpdate", self.handleNameChange)
end

function handleNameChange(node)
    if node.getValue() == self.episode.getValue() then self.unLockControl() else self.lockControl() end
end

function onClose()
    if control_state.getValue()=="pending" then
        local selectedType = self.type.getValue()
        if (selectedType == "Value") then
            local v = self.getDatabaseNode().getParent().getParent().createChild("values").createChild()
            DB.setValue(v, "label", "string", label.getValue())
            DB.setValue(v, "link", "windowreference", link.getValue())
        elseif selectedType == "Focus" then
            local f = self.getDatabaseNode().getParent().getParent().createChild("focuses")
            f.setValue(f.getValue() .. '\n'..self.label.getValue())
        elseif selectedType == "Talent" then
            local v = self.getDatabaseNode().getParent().getParent().createChild("talents").createChild()
            DB.setValue(v, "label", "string", label.getValue())
            DB.setValue(v, "link", "windowreference", link.getValue())
        end
        control_state.setValue("saved")
    end
end

function getScores()
    local scores = {}
    local charNode = self.getDatabaseNode().getParent().getParent()
    for _, score in ipairs(ScopeManager.ALL_DISCIPLINES) do
        local s = string.lower(score)
        scores[s] = DB.getValue(charNode, s, 1)
    end
    for _, score in ipairs(ScopeManager.ALL_ATTRIBUTES) do
        local s = string.lower(score)
        scores[s]=DB.getValue(charNode, s)
    end
    return scores
end

function getTalents()
    return DB.getChildren(self.getDatabaseNode().getParent().getParent().getNodeName(), "talents")
end

function getSpecies()
    return DB.getValue(self.getDatabaseNode().getParent().getParent(), "species", "")
end

function lockControl()
    self.improvement_select.setReadOnly(true)
    self.drop_target.setEnabled(false)
    self.drop_target.setReadOnly(true)
    self.score_select.setReadOnly(true)
    self.improvement_select.setEnabled(false)
    self.link.setEnabled(false)
    self.label.setEnabled(false)
    self.score_select.setEnabled(false)
end

function unLockControl()
    self.improvement_select.setReadOnly(false)
    self.drop_target.setEnabled(true)
    self.drop_target.setReadOnly(false)
    self.score_select.setReadOnly(false)
    self.improvement_select.setEnabled(true)
    self.link.setEnabled(true)
    self.label.setEnabled(true)
    self.score_select.setEnabled(true)
end

function increaseScore(score)
    local scoreNode = self.getDatabaseNode().getParent().getParent().getChild(score)
    scoreNode.setValue(scoreNode.getValue() + 1)
end

function reduceScore(score)
    local scoreNode = self.getDatabaseNode().getParent().getParent().getChild(score)
    scoreNode.setValue(scoreNode.getValue() - 1)
end

function updateScore(oldScore, newScore)
    if not((oldScore == nil) or (oldScore == "")) then self.reduceScore(string.lower(oldScore)) end
    self.increaseScore(string.lower(newScore))
end

function clearScoreSafe()
    if not((self.selected_score.getValue() == nil) or (self.selected_score.getValue() == "")) then
        local selectedScore = string.lower(self.selected_score.getValue())
        self.reduceScore(selectedScore)
    end
    self.selected_score.setValue("")
    self.score_select.clear()
    self.score_select.setVisible(false)
end

function clearSelections()
    self.link.setValue("", "")
    self.link.setVisible(false)
    self.label.setValue("")
    self.label.setVisible(false)
    if self.drop_target.selected then self.drop_target.setDeselect() end
    self.clearScoreSafe()
end

function setEntryType(type)
    local updateVal = not(type == self.type.getValue())
    if updateVal then
        self.clearSelections()
        self.type.setValue(type)
    end
    if type == "Value" or type == "Talent" then
        self.link.setVisible(true)
        self.label.setVisible(true)
        self.drop_target.setVisible(true)
        self.drop_target.initControl(string.lower(type), dummy, 0)
    elseif type == "Attribute" then
        self.score_select.setVisible(true)
        self.score_select.addItems(ScopeManager.ALL_ATTRIBUTES)
        if updateVal or self.selected_score.getValue() == nil then
            self.score_select.setValue(ScopeManager.ALL_ATTRIBUTES[1])
        else
            self.score_select.setValue(self.selected_score.getValue())
        end
    elseif type == "Discipline" then
        self.score_select.setVisible(true)
        self.score_select.addItems(ScopeManager.ALL_DISCIPLINES)
        if updateVal or self.selected_score.getValue() == nil then
            self.score_select.setValue(ScopeManager.ALL_DISCIPLINES[1])
        else
            self.score_select.setValue(self.selected_score.getValue())
        end
    else
        self.label.setVisible(true)
        self.drop_target.setVisible(true)
        self.drop_target.initControl("focus", dummy, 0)
    end
end

function setLinkVal(node)
    self.label.setValue(node.getChild("name").getValue())
end

function onDrop(x,y,draginfo)
    if not ((self.type.getValue() == "Value") or (self.type.getValue() == "Talent")) then
        return true
    end
    if draginfo.isType("shortcut") then
        local class, datasource = draginfo.getShortcutData();
        if class == "referencetext" or class == "note" or class == "sta_talent" then
            self.label.setValue(draginfo.getDatabaseNode().getChild("name").getValue());
            self.link.setValue(class, datasource);
        end
    end
    return true;
end