SUPPORT_IMPROVEMENTS = {
    "Gain a value (up to 4x)"
}

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

IMPROVEMENT_TYPES = {
    {
        ["display"]="Normal Milestone",
        ["options"]={
            {
                ["type"]="swap",
                ["target"]="value",
                ["display"]="Rewrite a Challenged Value"
            },
            {
                ["type"]="swap",
                ["target"]="discipline",
                ["display"]="Move One Discipline Point"
            },
            {
                ["type"]="swap",
                ["target"]="focus",
                ["display"]="Change one Focus"
            },
            {
                ["type"]="give_support",
                ["display"]="Give to Supporting Character"
            },
            {
                ["type"]="save",
                ["display"]="Save For Later"
            },
        }
    },
    {
        ["display"]="Spotlight Milestone",
        ["options"]={
            {
                ["type"]="swap",
                ["target"]="attribute",
                ["display"]="Move One Attribute Point"
            },
            {
                ["type"]="swap",
                ["target"]="talent",
                ["display"]="Change one Talent"
            },
            {
                ["type"]="give_support",
                ["display"]="Give to Supporting Character"
            },
            {
                ["type"]="swap",
                ["target"]="system",
                ["display"]="Move One Ship System Point"
            },
            {
                ["type"]="swap",
                ["target"]="department",
                ["display"]="Move One Ship Department Point"
            },
            {
                ["type"]="swap",
                ["target"]="ship_talent",
                ["display"]="Change one Ship Talent"
            },
        }
    },
    {
        ["display"]="Arc Milestone",
        ["options"]={
            {
                ["type"]="gain",
                ["target"]="attribute",
                ["display"]="Increase one Attribute (up to 12)"
            },
            {
                ["type"]="gain",
                ["target"]="discipline",
                ["display"]="Increase one Discipline (up to 5)"
            },
            {
                ["type"]="gain",
                ["target"]="talent",
                ["display"]="Add one Talent"
            },
            {
                ["type"]="gain",
                ["target"]="focus",
                ["display"]="Add one Focus"
            },
            {
                ["type"]="gain",
                ["target"]="value",
                ["display"]="Add one Value"
            },
            {
                ["type"]="give_support",
                ["display"]="Give to Supporting Character"
            },
            {
                ["type"]="gain",
                ["target"]="system",
                ["display"]="Increase one Ship System (up to 12)"
            },
            {
                ["type"]="gain",
                ["target"]="department",
                ["display"]="Increase one Ship Department (up to 5)"
            },
            {
                ["type"]="gain",
                ["target"]="ship_talent",
                ["limit"]=1,
                ["display"]="Add one Ship Talent"
            },
        }
    },
    {
        ["display"]="Support Character Improvement",
        ["options"]={
            {
                ["type"]="gain",
                ["target"]="value",
                ["limit"]=4,
                ["display"]="Add a Value"
            },
            {
                ["type"]="gain",
                ["target"]="attribute",
                ["limit"]=1,
                ["display"]="Increase an Attribute"
            },
            {
                ["type"]="gain",
                ["target"]="discipline",
                ["limit"]=1,
                ["display"]="Increase a Discipline"
            },
            {
                ["type"]="gain",
                ["target"]="focus",
                ["limit"]=3,
                ["display"]="Add a Focus"
            },
            {
                ["type"]="gain",
                ["target"]="talent",
                ["limit"]=4,
                ["display"]="Add a Talent"
            }
        }
    }
}

function onInit()
    self.lookupTable = {}
    local items = {}
    local improve_type = self.type.getValue()+1
--     if improve_type < 4 then
--         for it=improve_type,1,-1 do
--             self.addImproveOpts(items, it)
--         end
--     else
--         self.addImproveOpts(items, improve_type)
--     end
    self.addImproveOpts(items, improve_type)
    type_select.addItems(items)
    type_select.setValue("Improvement Type");
end

function addImproveOpts(items, improve_type)
    for _, option in ipairs(IMPROVEMENT_TYPES[improve_type].options) do
        if checkLimit(option, false) then
            table.insert(items, option.display)
            self.lookupTable[option.display] = option
        end
    end
end

function getRootNode()
    return ScopeManager.getNodeAtDepth(getDatabaseNode().getNodeName(), 1)
end

function getLimitNode()
    return DB.createChild(getRootNode(), "improve_limits")
end

function checkLimit(option, increment)
    if not option.limit then
        return true
    else
        local curVal = DB.getValue(getLimitNode(), option.target, 0)
        if curVal >= option.limit then
            return false
        else
            if increment then
                DB.setValue(getLimitNode(), option.target, "number", curVal + 1)
            end
            return true
        end
    end
end


function setEntryType(type)
    type_options.closeAll()
    local definition = self.lookupTable[type]
    if not definition then return end

    local selectClass = "improvement_type_"..definition.type
    local targetClass = getTargetClass(definition.target)
    local w = type_options.createWindowWithClass(selectClass, getDatabaseNode().getNodeName())
    if targetClass then
        w.setTargetClass(targetClass)
        if targetClass == "score_toggle_button" then
            w.addScores(getTargetScores(definition.target))
        elseif targetClass == "improve_select" then
            w.setOptions(definition.target)
        end
    end
end


function changeTypeControl(type, newVal)
    type.setValue(type)
end

function getTargetClass(target)
    if (target == "discipline") or (target == "department")  or (target == "attribute") or (target == "system") then
        return "score_toggle_button"
    elseif (target == "talent") or (target == "value") or (target == "focus") or (target == "ship_talent") then
        return "improve_select"
    end
end

function getTargetScores(target)
    if target == "attribute" then
        return ScopeManager.ALL_ATTRIBUTES
    elseif (target == "discipline") or (target == "department") then
        return ScopeManager.ALL_DISCIPLINES
    elseif target == "system" then
        return ShipHelper.ALL_SYSTEMS
    end
end