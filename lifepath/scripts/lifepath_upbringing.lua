-- At this step:
-- increase one attribute by 2, and another by 1
-- Increase one discipline
-- Gain a focus
-- Gain one talent

function onFirstLayout()
	self.alertDefs = {
		{LifePathAlertHelper.alertSummary, {"upbringing"}, "Roll for Upbringing", "Upbringing Selected"},
		{LifePathAlertHelper.alertAttDiscFrame, {self.attribute_selection_count}, "Choose Attributes (see notes)", "Upbringing Accepted/Rejected"},
		{LifePathAlertHelper.alertVFTFrame, {self.lifepath_upbringing_select_frame, "focus"}, "Select 1 Focus", "Focus Selected"},
		{LifePathAlertHelper.alertVFTFrame, {self.lifepath_upbringing_select_frame, "talent"}, "Select 1 Talent", "Talent Selected"},
		{LifePathAlertHelper.alertAttDiscFrame, {self.discipline_selection_count}, "Increase 1 Discipline by 1", "Discipline allocated"},
	}
end

function statusControl()
    return "lifepath_upbringingtab"
end

function getAlertDefs()
	return self.alertDefs
end

function getRollButton()
	return self.lifepath_upbringing_roll_button
end

function addAccept(acceptAttrs)
    local major, minor = unpack(acceptAttrs)
	local attWindow = self.lifepath_upbringing_attribute_select.addWindow();
	attWindow.lifepath_attribute_select_control.setName("Accept");
	attWindow.lifepath_attribute_select_control.setMajor(major);
	attWindow.lifepath_attribute_select_control.setMinor(minor);
	return attWindow
end

function addRebel(rebelAttrs)
    local major, minor = unpack(rebelAttrs)
	local attWindow = self.lifepath_upbringing_attribute_select.addWindow();
	attWindow.lifepath_attribute_select_control.setName("Rebel");
	attWindow.lifepath_attribute_select_control.setMajor(major);
	attWindow.lifepath_attribute_select_control.setMinor(minor);
	return attWindow
end

function addDiscipline(discipline)
	local disciplineWindow = self.lifepath_upbringing_discipline_select.addWindow();
	disciplineWindow.lifepath_attribute_select_control.setName(discipline);
	return disciplineWindow
end

function updateSummary(summary, upbringingName, acceptAttrs, rebelAttrs, disciplines)
	summary.subwindow["upbringing"].setValue(upbringingName);
	self.addAccept(acceptAttrs)
	self.addRebel(rebelAttrs)
    for _, discipline in ipairs(LifePathTableManager.populateDisciplines(disciplines, 1)) do
        self.addDiscipline(discipline);
    end
end