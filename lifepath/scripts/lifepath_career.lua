-- At this step:
-- Gain a value
-- Gain a talent
-- UNTAPPED_POTENTIAL = "reference.talents.untapped_potential"
-- VETERAN = "reference.talents.veteran"

function onInit()
	self.alertDefs = {
		{LifePathAlertHelper.alertSummary, {"career"}, "Roll for Career Experience", "Career Experience Selected"},
		{LifePathAlertHelper.alertVFTFrame, {self.lifepath_career_select_frame, "value"}, "Create 1 Value", "Value Created"},
		{LifePathAlertHelper.alertVFTFrame, {self.lifepath_career_select_frame, "talent"}, "Select 1 Talent", "Talent Created"}
	}
end

function statusControl()
    return "lifepath_careertab"
end

function getAlertDefs()
	return self.alertDefs
end

function getRollButton()
	return self.lifepath_career_roll_button
end


function lockTalent(talentRef)
	local button = self.lifepath_career_select_frame.talentSelect.lifepath_drop_target
	if button.selected then button.setDeselect() end
	local talentNode = DB.findNode(talentRef)
	if talentNode then
        button.setLink(talentNode)
        button.setReadOnly(true)
    end
end

function updateSummary(summary, careerLevel, talentRef)
	summary.subwindow["career"].setValue(careerLevel);
	if talentRef ~= "" then self.lockTalent(talentRef) end
--     if careerLevel == "Young Officer" then
--         self.lockTalent(STAModuleManager.getPathMain(UNTAPPED_POTENTIAL))
--     elseif careerLevel == "Veteran Officer" then
--         self.lockTalent(STAModuleManager.getPathMain(VETERAN))
--     end
end