TYPE_MAP = {
    ["N"]=0,
    ["S"]=1,
    ["A"]=2,
    ["C"]=4,
    ["R"]=5,
}

DISPLAY_MAP= {
    [0]="Normal Milestone",
    [1]="Spotlight Milestone",
    [2]="Arc Milestone",
    [4]="Commendation",
    [5]="Reprimand"
}

function onInit()
    self.pendingType = nil
end

function onButtonPress()
    local type = TYPE_MAP[window.type.getValue()]
    if type < 3 then
        addMilestone(type)
    else
        addReputation(type)
    end
end

function getNode()
    return window.windowlist.window.getDatabaseNode()
end

function addReputation(type)
    local w = Interface.openWindow("rep_value_select", "")
    w.label.setValue(DISPLAY_MAP[type])
    w.type.setValue(type)
    w.val.setValue(0)
    w.save.setCallback(handleReputation)
end

function handleReputation(type, val, desc)
    local evt = DB.createChild(getNode(), "service_history").createChild()
    DB.setValue(evt, "source", "string", DB.getValue(".crew_support.episode_name", ""))
    DB.setValue(evt, "type", "number", type)
    DB.setValue(evt, "used_on", "string", val .. ": "..desc)
    DB.setValue(getNode(), "reputation_total", "number", DB.getValue(getNode(), "reputation_total") + val)
end


function addMilestone(type)
    self.pendingType = type
    local name = DB.getValue(getNode(), "name", "")
    Interface.dialogMessage(self.handleSaveMilestone,
            "Confirm that you want to add one "..DISPLAY_MAP[type].." for character: "..name,
            "Confirm add milestone",
            "yesno")
end

function handleSaveMilestone(res)
    if res == "yes" then
        if self.pendingType then
--             local ms = DB.createChild(getNode(), "saved_milestones").createChild()
--             DB.setValue(ms, "source", "string", DB.getValue(".crew_support.episode_name", ""))
--             DB.setValue(ms, "type", "number", self.pendingType)
            for t=self.pendingType,0,-1 do
                local ms = DB.createChild(getNode(), "saved_milestones").createChild()
                DB.setValue(ms, "source", "string", DB.getValue(".crew_support.episode_name", ""))
                DB.setValue(ms, "type", "number", t)
            end
        end
    end
end