-- Increase 3 attributes by 1 each
-- Gain 1 talent
STEP_ATTRIBUTES = 3

-- Check: attributes add to 45, 1 talent


function onInit()
	self.alertDefs = {
		{LifePathAlertHelper.alertSummary, {"species"}, "Select or roll Species", "Species Selected"},
		{LifePathAlertHelper.alertVFTFrame, {self.lifepath_species_select_frame, "talent"}, "Select 1 Talent", "Talent Selected"},
		{LifePathAlertHelper.alertAttDiscFrame, {self.attribute_selection_count}, "Increase 3 Attributes by 1 each", "Attributes allocated"}
	}
	self.randomAttributes = {}
end

function statusControl()
    return "lifepath_speciestab"
end

function getAlertDefs()
	return self.alertDefs
end

function getRollButton()
	return self.lifepath_species_roll_button
end

function addAttribute(attribute)
	local attWindow = self.lifepath_species_attribute_select.addWindow();
	attWindow.lifepath_attribute_select_control.setName(attribute);
	return attWindow
end

function updateGeneratedAttributes(speciesAttributes)
	self.lifepath_species_attribute_select.closeAll()
	local anyFound = false
	for attribute, f in pairs(speciesAttributes)do
		if attribute == "any" then
			anyFound = true
		elseif f == -1 then
			local w = self.addAttribute(attribute)
			w.lifepath_attribute_select_control.toggleOff()
			w.lifepath_attribute_select_control.setReadOnly(true)
			w.lifepath_attribute_select_control.setText("-1 "..attribute)
		elseif f >= 1 then
			local w = self.addAttribute(attribute)
			w.lifepath_attribute_select_control.setReadOnly(true)
			for i=1,f do
				w.lifepath_attribute_select_control.toggleOn()
			end
			if f > 1 then
				w.lifepath_attribute_select_control.setText("+"..f.." "..attribute)
			end
		elseif f == 0 then
			break
		else
			Debug.chat("Something unexpected happening during generated Species handling:")
			Debug.chat(attribute)
			Debug.chat(f)
		end
	end
	if anyFound then
		for _, attribute in ipairs(ScopeManager.ALL_ATTRIBUTES) do
			if speciesAttributes[attribute] == nil then
				self.addAttribute(attribute);
			end
		end
	end
end

function updateSummary(summary, speciesName, attributes)
	self.lifepath_species_attribute_select.closeAll()
	summary.subwindow["species"].setValue(speciesName);
	local parsedAttributes, locked = LifePathTableManager.populateAttributes(attributes, STEP_ATTRIBUTES)
	for _, attribute in ipairs(parsedAttributes) do
        local attWindow = self.addAttribute(attribute);
        if locked then
            attWindow.lifepath_attribute_select_control.setReadOnly(true);
            attWindow.lifepath_attribute_select_control.toggleOn();
        end
	end
	ScopeManager.updateAlerts()
end
