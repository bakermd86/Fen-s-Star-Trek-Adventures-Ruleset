function initControl(source, target, step)
    self.source = source;
    self.target = target;
    self.step = step
    self.selected = false;
    self.created = false;
    self.node = nil;
    self.summaryLink = nil;
    self.talentSelect = nil;
    self.pendingName = ""
end

function setLink(node)
    self.node = node
    name = DB.getValue(node, "name")
    self.saveLinkToList(name, "sta_talent")
end

function handleListSelect(node)
    if self.selected then
        self.setDeselect();
    end
    if self.talentSelect then
        self.talentSelect.close()
        self.talentSelect = nil
    end
    self.node = node
    self.setLink(self.node)
end

function onDrop(x,y,draginfo)
    if draginfo.isType("shortcut") then
        local class, datasource = draginfo.getShortcutData();
        if (((class == "sta_talent") or (class == "referencetext" )) and (self.source == "talent")) then
            if self.selected then
                self.setDeselect();
            end
            class, datasource = draginfo.getShortcutData();
            self.node = draginfo.getDatabaseNode();
            self.setLink(self.node)
        end
    end
end

reqBodyPattern = "([A-Z][a-z]+)[ ]*([0-9]+)"
function talentAllowed(talentNode, scores)
    local reqLine = DB.getValue(talentNode, "requirements", "None")
    if scores == "ALLOW_ALL" then return true
    elseif not reqLine or (reqLine == "") or string.find(reqLine, "None") or string.find(reqLine, "Main Character")then
        return true
    elseif (self.getSpecies() or "") ~= "" and string.find(reqLine, self.getSpecies()) then
        return true
    else
        for reqText, scoreMin in reqLine:gmatch(reqBodyPattern) do  -- Handle requirements with 2 disciplines (Eng 2+ or Science 2+)
            if reqText or "" ~= "" then
                local scoreName = string.lower(reqText)
                if scores[scoreName] >= tonumber(scoreMin) then return true end
            end
        end
        return false
    end
end
function handleRandomTalent(talents)
    local scores = self.getScores()
    local talents = doScoreFilter(talents, scores)
    local orderedTalents = {}

    for _, tDef in ipairs(talents) do
        t, __ = unpack(tDef)
        table.insert(orderedTalents, t)
    end
    local val = math.random(#orderedTalents)
    self.setLink(orderedTalents[val])
end

function doScoreFilter(talents, scores)
    local selectedTalents = {}
    for _, talent in ipairs(self.getTalents())do
        selectedTalents[talent.label.getValue()] = 1
    end
    local talentsOut = {}
    for _, node in ipairs(talents) do
        local talentName = DB.getValue(node, "name")
        if selectedTalents[talentName] == 1 then
        elseif self.talentAllowed(node, scores) then
            table.insert(talentsOut, {node, 1})
        else
            table.insert(talentsOut, {node, 0})
        end
    end
    return talentsOut
end

function getRand()
    if self.selected then setDeselect() end
    if self.source == "value" then
        local v = CrewSupportManager.getValue()
        local name = DB.getValue(v, "name", "")
        if v~= "" and (name or "") ~= "" then
            self.saveTextToList(name, DB.getValue(v, "text", ""))
        end
    elseif self.source == "focus" then
        local f = CrewSupportManager.getFocus()
        local name = DB.getValue(f, "name", "")
        if f~= "" and (name or "") ~= "" then
            self.saveTextToList(name, nil)
        end
    elseif (self.source == "talent") or (self.source == "ship_talent") then
        local scores = self.getScores()
        local t = CrewSupportManager.getTalent(doScoreFilter(getAllTalents(), scores))
        if (t or "") ~= "" then
            self.setLink(t)
        end
    end
end

function formatPreviewBody(node)
    local talentName = DB.getValue(node, "name", "")
    local reqStr = DB.getValue(node, "requirements", "None")
    local talentBody = DB.getValue(node, "text", "")
    return "<h>"..talentName.."</h>\n<p><b>Requirements: "..reqStr.."</b></p>\n"..talentBody
end

function onButtonPress()
    if not self.selected then
        if self.source == "value"then
            self.onValueAdd()
        elseif self.source == "focus" then
            self.onFocusAdd()
        elseif (self.source == "talent") or (self.source == "ship_talent") then
            self.onTalentAdd()
        end
    else
        self.setDeselect();
    end
end

function onNewTalentAdd()
    local n = Interface.openWindow("lifepath_talent_entry", "");
    n.save_control.setSaveCallback(self.handleSaveNewTalent);
end

function onValueAdd()
    local n = Interface.openWindow("lifepath_note_entry", "");
    n.save_control.setSaveCallback(self.handleSaveNote);
end

function onFocusAdd()
    local n = Interface.openWindow("lifepath_note_entry", "");
    n.save_control.setSaveCallback(self.handleSaveFocus);
    n.text.setReadOnly()
    n.text.setEnabled(false)
end

function getAllTalents()
    local sourceName = "talent"
    if self.source == "ship_talent" then
        sourceName = "shiptalent"
    end
    return STAModuleManager.getAllFromModules(sourceName, "reference."..sourceName)
end

function onTalentAdd()
    self.talentSelect = Interface.openWindow("lifepath_talent_filter_list", "");
    self.talentSelect.new_talent_button.setTalentSource(self)
    self.talentSelect.talent_list.closeAll()
    local scores = self.getScores()
    for _, nodeDef in ipairs(doScoreFilter(getAllTalents(), scores)) do
        local node, filterKey = unpack(nodeDef)
        local w = self.talentSelect.talent_list.createWindow()
        local name = DB.getValue(node, "name")
        w.label.setValue(name)
        w.require_met.setValue(filterKey)
        w.add_link_button.configure(self.handleListSelect, node)
        w.preview_button.configure(self.talentSelect.talent_preview, formatPreviewBody(node), self.talentSelect.clearSelection)
    end
    self.talentSelect.talent_list.resetSelection()
end

function setDeselect()
    self.cleanUp()
    self.setIcons("button_add", "button_add_down");
    self.selected = false;
    if self.step > 0 then
        ScopeManager.updateAlerts()
    end
end

function setSelect()
    self.setIcons("button_dialog_ok_down", "button_dialog_ok_down");
    self.selected = true;
    if self.step > 0 then
        ScopeManager.updateAlerts()
    end
end

function getTarget(targetType)
    return ScopeManager.getLifepathWindow().summary.subwindow[targetType]
end

function saveTextToList(name, text)
    self.summaryLink = self.getTarget(self.target).createWindow();
    self.summaryLink.name.setValue(name)
    if not(text == nil) then
        self.summaryLink.text.setValue(text)
    end
    self.setSelect()
end

function saveLinkToList(name, class)
    self.summaryLink = self.getTarget(self.target).createWindow();
    self.summaryLink.label.setValue(name);
    self.summaryLink.link.setValue(class, self.node.getNodeName());
    self.summaryLink.link.setVisible(true);
    self.setSelect();
end
function saveTalentToList(name, requirements, text)
    self.summaryLink = self.getTarget(self.target).createWindow();
    self.summaryLink.label.setValue(name)
    self.node = self.summaryLink.getDatabaseNode()

    DB.setValue(self.node, "name", "string", name)
    if (text or "") ~= "" then
        DB.setValue(self.node, "text", "formattedtext", text)
    end
    DB.setValue(self.node, "requirements", "string", requirements)
    DB.setValue(self.node, "link", "windowreference", "sta_talent", self.node.getNodeName())

    self.setSelect()
end

function handleSaveFocus(noteFrame)
    local name = noteFrame.header.subwindow["name"].getValue();
    self.saveTextToList(name, nil)
end

function handleSaveNote(noteFrame)
    local name = noteFrame.header.subwindow["name"].getValue();
    local text = noteFrame.text.getValue();
    self.saveTextToList(name, text)
end

function handleSaveNewTalent(talentFrame)
    local name = talentFrame.header.subwindow["name"].getValue();
    local requirements = talentFrame.requirements.getValue();
    local text = talentFrame.text.getValue();
    self.saveTalentToList(name, requirements, text)
end
