-- LIFEPATH_NOTE_CREATED_CALLBACK = "lifepath_note_created_callback"
-- LIFEPATH_TALENT_LIST_CALLBACK = "lifepath_talent_list_callback"
-- LIFEPATH_RANDOM_TALENT_CALLBACK = "lifepath_random_talent_callback"

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
    name = node.getChild("name").getValue();
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

-- reqLinePattern = "<h>Requirement[ :]+[^<]+</h>"
reqStringPattern = "([A-Z][a-z]+[ ]*[0-9]+)"
--
function talentAllowed(talentNode, scores)
--     local body = talentNode.getChild("text").getValue()
--     local reqLine = string.match(body, reqLinePattern)
    local reqLine = talentNode.getChild("requirements").getValue()
--     local noScoreRequire = string.match(body, "<h>Requirement[ :]+([a-zA-Z]+).*</h>")
    if not reqLine or (reqLine == "") or string.find(reqLine, "None") or string.find(reqLine, "Main Character")then
        return true
    elseif (self.getSpecies() or "") ~= "" and string.find(reqLine, self.getSpecies()) then
        return true
    else
        for reqText in reqLine:gmatch(reqStringPattern) do  -- Handle requirements with 2 disciplines (Eng 2+ or Science 2+)
            local scoreName = string.lower(string.sub(reqText, 1, -3))
            local scoreMin = string.sub(reqText, -1, -1)
            if scores[scoreName] >= tonumber(scoreMin) then return true end
        end
        return false
    end
end
--
-- function formatPreviewBody(node)
--     return "<h>"..node.getChild("name").getValue().."</h>\n"..node.getChild("text").getValue()
-- end

function handleRandomTalent(talents)
    local scores = self.getScores()
    local talents = doScoreFilter(talents, scores)
    local orderedTalents = {}

    for _, tDef in pairs(talents) do
        t, __ = unpack(tDef)
        table.insert(orderedTalents, t)
    end
    local val = math.random(#orderedTalents)
    self.setLink(orderedTalents[val])
end

-- function handleFilterTalents(oobMsg)
--     local scores = self.getScores()
--     self.applyFilter(oobMsg, scores)
-- end

function doScoreFilter(talents, scores)
    local selectedTalents = {}
    for _, talent in ipairs(self.getTalents())do
        selectedTalents[talent.label.getValue()] = 1
    end
    local talentsOut = {}
    for key, node in pairs(talents) do
        if not (key == "type") then
            local talentName = node.getChild("name").getValue()
            if selectedTalents[talentName] == 1 then
            elseif self.talentAllowed(node, scores) then
                talentsOut[key]={node, 1}
            else
                talentsOut[key]={node, 0}
            end
        end
    end
    return talentsOut
end

-- function applyFilter(talents, scores)
--     self.talentSelect.talent_list.closeAll()
--     for name, node in pairs(doScoreFilter(talents, scores)) do
--         local w = self.talentSelect.talent_list.createWindow()
--         w.label.setValue(name)
--         w.add_link_button.configure(self.handleListSelect, node)
--         w.preview_button.configure(self.talentSelect.talent_preview, formatPreviewBody(node), self.talentSelect.clearSelection)
--         self.talentSelect.talent_list.getWindows(true)[1].preview_button.onButtonPress()
--     end
-- end

-- function getRand()
--     if self.selected then setDeselect() end
--     if self.source == "value" then
--         local v = CrewSupportManager.getValue()
--         local name = DB.getValue(v, "name", "")
--         self.saveTextToList(name, name)
--     elseif self.source == "focus" then
--         local f = CrewSupportManager.getFocus()
--         local name = DB.getValue(f, "name", "")
--         self.saveTextToList(name, nil)
--     elseif (self.source == "talent") or (self.source == "ship_talent") then
--         if User.isHost() or User.isLocal() then
--             self.handleRandomTalent(LifePathActionHelper.getCharacterTalents(self.source == "ship_talent"))
--         else
--             local oobMsg = {
--                 ["type"]=LifePathActionHelper.LIFEPATH_GET_TALENTS,
--                 ["user"]=User.getUsername(),
--                 ["callback"]=LIFEPATH_RANDOM_TALENT_CALLBACK,
--                 ["ship_mode"]=tostring((self.source == "ship_talent"))
--             }
--             OOBManager.registerOOBMsgHandler(LIFEPATH_RANDOM_TALENT_CALLBACK, self.handleRandomTalent)
--             Comm.deliverOOBMessage(oobMsg, "")
--         end
--     end
-- end

function formatPreviewBody(node)
    return "<h>"..node.getChild("name").getValue().."</h>\n<p><b>Requirements: "..node.getChild("requirements").getValue("None").."</b></p>\n"..node.getChild("text").getValue()
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
    local allTalents = {}
    local sourceName = "talent"
    if self.source == "ship_talent" then
        sourceName = "shiptalent"
    end
    for name, node in pairs(DB.getChildren("reference."..sourceName)) do
        allTalents[name] = node
    end
    for _, module in ipairs(Module.getModules()) do
        for name, node in pairs(DB.getChildren("reference." .. sourceName .. "@".. module)) do
            allTalents[name] = node
        end
    end
    for name, node in pairs(DB.getChildren(sourceName)) do
        allTalents[name] = node
    end
    return allTalents
end

function onTalentAdd()
    self.talentSelect = Interface.openWindow("lifepath_talent_filter_list", "");
    self.talentSelect.talent_list.closeAll()
    local scores = self.getScores()
    for _, nodeDef in pairs(doScoreFilter(getAllTalents(), scores)) do
        local node, filterKey = unpack(nodeDef)
        local w = self.talentSelect.talent_list.createWindow()
        local name = DB.getValue(node, "name")
        w.label.setValue(name)
        w.require_met.setValue(filterKey)
        w.add_link_button.configure(self.handleListSelect, node)
        w.preview_button.configure(self.talentSelect.talent_preview, formatPreviewBody(node), self.talentSelect.clearSelection)
    end
    self.talentSelect.talent_list.resetSelection()
--     local tWindows = self.talentSelect.talent_list.getWindows(true)
--     if #tWindows >= 1 then
--         tWindows[1].preview_button.onButtonPress()
--     end
end

function setDeselect()
    if self.node then
        if self.created then
            self.node.delete();
            self.created = false;
        end
        self.node = nil;
    end
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

function handleSaveFocus(noteFrame)
    local name = noteFrame.header.subwindow["name"].getValue();
    self.saveTextToList(name, nil)
end

function handleSaveNote(noteFrame)
    local name = noteFrame.header.subwindow["name"].getValue();
    local text = noteFrame.text.getValue();
    self.saveTextToList(name, text)
end
