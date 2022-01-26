TABLESET_NODE = ".saved_lptableset"
TABLESET_SETTINGS = "lptableset_settings"
MODE_MANUAL = "MANUAL"
MODE_WIKI = "WIKI"
MODE_GENERATED = "GENERATED"
STEP_NAMES = {
    "species",
    "environment",
    "upbringing",
    "academy",
    "career",
    "career_events"
}

function getAllActiveTables()
    allTables = {MODE_MANUAL}
    if STAModuleManager.modLoaded(STAModuleManager.MODULE_EXTRA) then
        if DB.getValue(TABLESET_SETTINGS..".allow_generated", 0) == 1 then
            table.insert(allTables, MODE_GENERATED)
        end
        if DB.getValue(TABLESET_SETTINGS..".allow_wiki", 0) == 1 then
            table.insert(allTables, MODE_WIKI)
        end
    end
    for _, tableNode in pairs(DB.getChildren(TABLESET_NODE)) do
        if DB.getValue(tableNode, "name", "") ~= "" then
            table.insert(allTables, DB.getValue(tableNode, "name"))
        end
    end
    return allTables
end

function getDefaultTable()
    local defaultTableSet = DB.getValue(TABLESET_SETTINGS..".default_lp_table")
    for _, tableNode in pairs(DB.getChildren(TABLESET_NODE)) do
        if DB.getValue(tableNode, "default", 0) == 1 and DB.getValue(tableNode, "name", "") ~= "" then
            defaultTableSet = DB.getValue(tableNode, "name")
        end
    end
    return defaultTableSet
end

function setDefaultTableByName(tableName)
    for _, tableNode in pairs(DB.getChildren(TABLESET_NODE)) do
        if DB.getValue(tableNode, "name") == tableName then
            DB.setValue(tableNode, "default", "number", 1)
            shareTableSet(tableNode, true)
        else
            DB.setValue(tableNode, "default", "number", 0)
            shareTableSet(tableNode, false)
        end
    end
end

function shareTableSet(tableSetNode, isShared)
    DB.setPublic(tableSetNode, isShared)
    for i=1,6 do
        local linkName = "step_"..i.."_link"
        local _, tableNode = DB.getValue(tableSetNode, linkName)
        DB.setPublic(tableNode, isShared)
    end
end

function getActiveStepName(table_name, step_num)
    local stepTable = nil
    for _, tableNode in pairs(DB.getChildren(TABLESET_NODE)) do
        if DB.getValue(tableNode, "name", "") == table_name then
            _, stepTable = DB.getChild(tableNode, "step_"..step_num.."_link").getValue()
        end
    end
    return DB.getValue(stepTable..".name"), stepTable
end

function populateAttributes(attributes, step_attributes)
    local populatedAttributes = populateScores(attributes, ScopeManager.ALL_ATTRIBUTES)
    return populatedAttributes, (#populatedAttributes == step_attributes)
end

function populateDisciplines(disciplines, step_disciplines)
    local populatedDisciplines = populateScores(disciplines, ScopeManager.ALL_DISCIPLINES)
    return populatedDisciplines, (#populatedDisciplines == step_disciplines)
end

function populateScores(scores, all_scores)
    for _, score in ipairs(scores) do
        if string.lower(score) == "any" then
            return all_scores
        end
    end
    return scores
end