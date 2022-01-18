-- At this step (x2):
-- Inrease one attribute by 1
-- Increase one discipline by 1
-- Gain a focus

function onInit()
    self.event1 = nil
    self.attribute1 = ""
    self.attribute2 = ""
    self.event2 = nil
    self.discipline1 = ""
    self.discipline2 = ""
end

function onFirstLayout()
	self.alertDefs = {
		{LifePathAlertHelper.alertSummaryCount, {"career_events", 2}, "Roll for Career Events", "Both Career Events Selected"},
		{LifePathAlertHelper.alertVFTFrame, {self.lifepath_career_events_select_frame, "focus"}, "Create 2 Focuses", "Focus Created"},
		{LifePathAlertHelper.alertAttDiscFrame, {self.attribute_selection_count}, "Increase 2 Attributes by 1 each", "Attributes allocated"},
		{LifePathAlertHelper.alertAttDiscFrame, {self.discipline_selection_count}, "Increase 2 Disciplines by 1 each", "Disciplines allocated"},
	}
end

function statusControl()
    return "lifepath_career_eventtab"
end

function getAlertDefs()
	return self.alertDefs
end

function getRollButton()
	return self.lifepath_career_events_roll_button
end

function addVal(attribute, readOnly, target)
    local attWindow = target.addWindow();
    attWindow.lifepath_attribute_select_control.setName(attribute);
    if readOnly then
        attWindow.lifepath_attribute_select_control.setReadOnly(true);
        attWindow.lifepath_attribute_select_control.toggleOn();
    end
	return attWindow
end


function commitVals(val1, val2, all, target)
    if not (val1 == "Any")  then
        self.addVal(val1, true, target)
    end
    if not (val2 == "Any")  then
        self.addVal(val2, true, target)
    end
    if (val1 == "Any") or (val2 == "Any") then
        for _, att in ipairs(all) do
            if not ((att == val1) or att == val2) then
                self.addVal(att, false, target)
            end
        end
    end
end

function updateManualEvents()
    if not (ScopeManager.getSummary() and ScopeManager.getSummary().career_events) then return end
    for _, w in ipairs(ScopeManager.getSummary().career_events.getWindows()) do
        if (w.getDatabaseNode() or "") ~= "" then
            DB.deleteNode(w.getDatabaseNode())
        end
    end
    if self.lifepath_career_events1_name_manual.getValue() ~= "" then
        self.addEventLink(self.lifepath_career_events1_name_manual.getValue(), nil)
    end
    if self.lifepath_career_events2_name_manual.getValue() ~= "" then
        self.addEventLink(self.lifepath_career_events2_name_manual.getValue(), nil)
    end
end

function addDiscipline(discipline)
	local disciplineWindow = self.lifepath_career_events_discipline_select.addWindow();
	disciplineWindow.lifepath_attribute_select_control.setName(discipline);
	return disciplineWindow
end

function addAttribute(attribute)
	local attributeWindow = self.lifepath_career_events_attribute_select.addWindow();
	attributeWindow.lifepath_attribute_select_control.setName(attribute);
	return attributeWindow
end

function addEventLink(careerEvent, eventRef)
    local entry = ScopeManager.getSummary().career_events.createWindow()
    entry.label.setValue(careerEvent)
    if not (eventRef == nil) then
        entry.link.setValue("referencetext", eventRef)
        entry.link.setVisible(true);
    end
end

function updateSummary(summary, careerEvent, eventRef, attribute, discipline)
    local eventBody = DB.findNode(eventRef).getChild("text").getValue()
    if not self.event1 then
        self.event1 = careerEvent
        ScopeManager.getLifepathWindow().rollStep(6, self.lifepath_career_events_roll_button)
        self.discipline1 = discipline
        self.attribute1 = attribute
        self.addEventLink(careerEvent, eventRef)
        return true
    elseif self.event1 == careerEvent then
        ScopeManager.getLifepathWindow().rollStep(6, self.lifepath_career_events_roll_button)
        return false
    else
        self.event2 = careerEvent
        self.discipline2 = discipline
        self.attribute2 = attribute
        self.addEventLink(careerEvent, eventRef)
        self.commitVals(self.attribute1, self.attribute2, ScopeManager.ALL_ATTRIBUTES, self.lifepath_career_events_attribute_select)
        self.commitVals(self.discipline1, self.discipline2, ScopeManager.ALL_DISCIPLINES, self.lifepath_career_events_discipline_select)
        return true
    end
end