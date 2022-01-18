-- At this step:
-- Gain a value
-- Increase one attribute
-- Increase one discipline
STEP_ATTRIBUTES = 1
STEP_DISCIPLINES = 1

-- Check: Attributes add to 46, 1 value, 1 talent, disciplines add to 7

function onInit()
	self.alertDefs = {
		{LifePathAlertHelper.alertSummary, {"environment"}, "Roll for Environment", "Environment Selected"},
		{LifePathAlertHelper.alertVFTFrame, {self.lifepath_environment_select_frame, "value"}, "Create 1 Value", "Value Created"},
		{LifePathAlertHelper.alertAttDiscFrame, {self.attribute_selection_count}, "Increase 1 Attribute by 1", "Attributes allocated"},
		{LifePathAlertHelper.alertAttDiscFrame, {self.discipline_selection_count}, "Increase 1 Discipline by 1", "Disciplines allocated"},
	}
end

function statusControl()
    return "lifepath_environmenttab"
end

function getAlertDefs()
	return self.alertDefs
end

function getRollButton()
	return self.lifepath_environment_roll_button
end

function updateAlerts()
	local alerts = self.getAlerts()
	if alerts[1]~=nil then
		ScopeManager.getLifepathWindow().environment_alert_icon.setValue(0)
	else
		ScopeManager.getLifepathWindow().environment_alert_icon.setValue(1)
	end
end

function addAttribute(attribute)
	local attWindow = self.lifepath_environment_attribute_select.addWindow();
	attWindow.lifepath_attribute_select_control.setName(attribute);
	return attWindow
end

function addDiscipline(discipline)
	local disciplineWindow = self.lifepath_environment_discipline_select.addWindow();
	disciplineWindow.lifepath_attribute_select_control.setName(discipline);
	return disciplineWindow
end

function updateSelections(attributes, disciplines, attLock, discLock)
    self.lifepath_environment_attribute_select.closeAll()
    self.lifepath_environment_discipline_select.closeAll()
	if attributes then
		for _, attribute in ipairs(attributes) do
			local w = self.addAttribute(attribute);
			if attLock then
                w.lifepath_attribute_select_control.setReadOnly(true);
                w.lifepath_attribute_select_control.toggleOn();
			end
		end
	end
	if disciplines then
		for _, discipline in ipairs(disciplines) do
			local w = self.addDiscipline(discipline);
			if discLock then
                w.lifepath_attribute_select_control.setReadOnly(true);
                w.lifepath_attribute_select_control.toggleOn();
			end
		end
	end
end

function updateSummaryWithSpecies(summary, speciesName, attributes, disciplines)
	local environmentName = speciesName .. " Homeworld";
	self.updateSummary(summary, environmentName, attributes, disciplines)
end

function updateSummary(summary, environmentName, attributes, disciplines)
	summary.subwindow["environment"].setValue(environmentName);
	local parsedAttributes, attLock = LifePathTableManager.populateAttributes(attributes, STEP_ATTRIBUTES)
	local parsedDisciplines, discLock = LifePathTableManager.populateDisciplines(disciplines, STEP_DISCIPLINES)
	self.updateSelections(parsedAttributes, parsedDisciplines, attLock, discLock);
	ScopeManager.updateAlerts()
end