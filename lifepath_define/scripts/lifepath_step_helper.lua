_namesMap = {
    "Any",
    "Species",
    "OtherSpecies"
}

function onInit()
    self.loaded_tables = {}
    self.loadSavedLPTables()
end

function loadSavedLPTables()
    for _, node in ipairs(DB.getChildren(".saved_lptableset")) do
        Debug.chat(node)
    end
end

function clearSelectControl(control)
    for _, w in ipairs(control.getWindows()) do
        if w.lifepath_attribute_select_control.selected then
            w.lifepath_attribute_select_control.toggleOff()
        end
    end
end

function resetAttSelect(window, count, resNode)
    resetScoreSelect(window.attribute_select_mode, window.att_mode_controls, window.attribute_define_subwindow, count, resNode)
end

function resetDiscSelect(window, count, resNode)
    resetScoreSelect(window.discipline_select_mode, window.disc_mode_controls, window.discipline_define_subwindow, count, resNode)
end

function resetScoreSelect(selectMode, controlMap, scoreSubWindow, count, resNode)
    for _, w in ipairs(controlMap) do
        w.setBackColor(LifePathAlertHelper.COLOR_DESELECT)
    end
    if count <= 0 then
        local modeName = _namesMap[(count*-1)+1]
        selectMode.setValue(string.lower(modeName))
        DB.setValue(resNode, "result", "string", modeName)
        scoreSubWindow.setVisible(false)
    else
        selectMode.setValue("fixed")
        clearSelectControl(scoreSubWindow.subwindow.define_score_select)

        scoreSubWindow.subwindow.score_selection_count.setValue(count)
        scoreSubWindow.subwindow.define_score_select.updateResultVal()
        scoreSubWindow.setVisible(true)
    end
end

function clearState(stepWindow)
    stepWindow.header.subwindow["results.id-00001.result"].setValue("")
    local lowestFree = 0
    for i=1,20 do
        if not stepWindow.usedVals[i] then
            lowestFree = i
            break
        end
    end
    stepWindow.header.subwindow.fromrange.setValue(lowestFree)
    stepWindow.header.subwindow.torange.setValue(lowestFree)
    for _, selectControl in ipairs(stepWindow.select_controls) do
        clearSelectControl(selectControl.subwindow.define_score_select)
    end
    if stepWindow.att_mode_controls then
        stepWindow.att_mode_controls[1].onButtonPress()
    end
    if stepWindow.disc_mode_controls then
        stepWindow.disc_mode_controls[1].onButtonPress()
    end
    if stepWindow.talent_mode_controls then
        stepWindow.talent_mode_controls[1].onButtonPress()
    end
    stepWindow["stepNote.text"].setValue("")
    stepWindow.header.subwindow.fromrange.setFocus(true)
end

function getResName(node, colNum)
    if colNum < 10 then
        return DB.getValue(node.getChild("results").getChild("id-0000"..colNum), "result", "")
    else
        return DB.getValue(node.getChild("results").getChild("id-000"..colNum), "result", "")
    end
end

function updateUsedVals(window, markVal)
    for i=window.header.subwindow.fromrange.getValue(),window.header.subwindow.torange.getValue() do
        if window.usedVals[i] == nil then
            window.usedVals[i] = 0
        end
        window.usedVals[i] = window.usedVals[i] + markVal
        if window.usedVals[i] <= 0 then window.usedVals[i] = nil end
    end
end

function loadResult(scoreSubWindow, modeMap, colNum)
    local window = scoreSubWindow.window
    local node = window.getDatabaseNode()
    local resStr = getResName(node, colNum)
    if modeMap[resStr] ~= nil then
        modeMap[resStr].onButtonPress()
    else
        local scoreMap = {}
        local scoreCount = 0
        for _, score in ipairs(ScopeManager.splitColumn(string.lower(resStr))) do
            scoreMap[score] = true
            scoreCount = scoreCount + 1
        end
        clearSelectControl(scoreSubWindow.subwindow.define_score_select)
        if modeMap[scoreCount] ~= nil then
            modeMap[scoreCount].onButtonPress()
        else
            for k, v in pairs(modeMap) do
                local i = tonumber(k)
                if i and i >= scoreCount then
                    modeMap[k].onButtonPress()
                    break
                end
            end
        end

        for _, w in ipairs(scoreSubWindow.subwindow.define_score_select.getWindows()) do
            if scoreMap[w.lifepath_attribute_select_control.attName] then
                w.lifepath_attribute_select_control.toggleOn()
            end
        end
    end
    updateUsedVals(window, -1)
end

function saveAllTables(window)
    local categoryName = "LifePath Wizard Tables - Do Not Edit "
    local setName = window.set_name.getValue()

    local newTableSet = DB.createChild(".saved_lptableset")
    if DB.getChildCount(".saved_lptableset") == 1 then DB.setValue(newTableSet, "default", "number", 1) end
    if setName == "" then setName = "Unnamed Tableset "..DB.getChildCount(".saved_lptableset") end
    DB.setValue(newTableSet, "name", "string", setName)
    DB.setValue(newTableSet, "locked", "number", 1)
    if window.selectedTableSet ~= nil then
        DB.deleteNode(window.selectedTableSet)
    end
    for idx, tableNode in ipairs(window.table_nodes) do
        if self.loaded_tables[tableNode.getNodeName()] ~= nil then
             DB.deleteNode(DB.findNode(self.loaded_tables[tableNode.getNodeName()]))
             self.loaded_tables[tableNode.getNodeName()] = nil
        end
        local newTableNode = DB.createChild(".tables")
        DB.copyNode(tableNode, newTableNode)
        DB.setValue(newTableNode, "name", "string", window.getStepWindow(idx).name_header.subwindow.name.getValue())
        if categoryName ~= "" then newTableNode.setCategory(categoryName) end
        for _, rowNode in pairs(newTableNode.getChild("tablerows").getChildren()) do
            local textNode = rowNode.getChild("stepNote").getNodeName()
            DB.setValue(rowNode.getChild("results").getChild("id-00001"), "resultlink", "windowreference", "referencetext", textNode)
        end
        DB.setValue(newTableSet, "step_"..idx.."_name", "string", DB.getValue(newTableNode, "name"))
        DB.setValue(newTableSet, "step_"..idx.."_link", "windowreference", "table", newTableNode.getNodeName())
    end
    window.close()
end

function loadTableSet(window)
    local w = Interface.openWindow("table_load_window", ".saved_lptableset")
    w.load.setSource(window)
end

function loadTableSetCallback(window, selectedName)
    local selectedTableSet = nil
    for _, tableSet in pairs(DB.getChildren(".saved_lptableset")) do
        if DB.getValue(tableSet, "name") == selectedName then
            selectedTableSet = tableSet
            window.set_name.setValue(selectedName)
            window.selectedTableSet = selectedTableSet
            break
        end
    end
    for idx, tableNode in ipairs(window.table_nodes) do
        local _, inputTableNode = DB.getValue(selectedTableSet, "step_"..idx.."_link")
        DB.copyNode(inputTableNode, tableNode)
        window.getStepWindow(idx).name_header.subwindow.name.setValue(DB.getValue(inputTableNode..".name"))
        self.loaded_tables[tableNode.getNodeName()] = inputTableNode
    end
end
