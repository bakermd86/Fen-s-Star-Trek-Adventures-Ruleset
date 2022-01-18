TEST_TABLE_NAME = "LPTest1"
STEP_NAMES = {
    "species",
    "environment",
    "upbringing",
    "academy",
    "career",
    "career_events"
}

function getAllActiveTables()
    return {
        TEST_TABLE_NAME
    }
end

function getDefaultTable()
    return TEST_TABLE_NAME
end

function getActiveStepName(table_name, step_num)
    return table_name .. "-step" .. step_num .. "-" .. STEP_NAMES[step_num]
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