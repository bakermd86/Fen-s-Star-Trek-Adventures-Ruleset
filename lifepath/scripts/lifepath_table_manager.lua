TEST_TABLE_NAME = "LPTest1"
TABLESET_NODE = ".saved_lptableset"
STEP_NAMES = {
    "species",
    "environment",
    "upbringing",
    "academy",
    "career",
    "career_events"
}

function getAllActiveTables()
    allTables = {}
    for _, tableNode in pairs(DB.getChildren(TABLESET_NODE)) do
        if DB.getValue(tableNode, "name", "") ~= "" then
            table.insert(allTables, DB.getValue(tableNode, "name"))
        end
    end
    return allTables
end

function getDefaultTable()
    for _, tableNode in pairs(DB.getChildren(TABLESET_NODE)) do
        if DB.getValue(tableNode, "default", 0) == 1 and DB.getValue(tableNode, "name", "") ~= "" then
            return DB.getValue(tableNode, "name")
        end
    end
    return "MANUAL"
end

function getActiveStepName(table_name, step_num)
    local stepTable = nil
    for _, tableNode in pairs(DB.getChildren(TABLESET_NODE)) do
        if DB.getValue(tableNode, "name", "") == table_name then
            _, stepTable = DB.getChild(tableNode, "step_"..step_num.."_link").getValue()
        end
    end
    return DB.getValue(stepTable..".name")
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