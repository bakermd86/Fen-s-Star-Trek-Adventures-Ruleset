-- At this step:
-- Gain a value
-- Add 3 attribute points (2+1 or 1, 1, 1)
-- Increase one discipline by 2, and two others by 1
-- Gain three focuses
-- Gain a talent
-- ACADEMY_TRACKS = {
--     ["Command Track"]={"Command", "Conn"},
--     ["Operations Track"]={"Engineering", "Security"},
--     ["Sciences Track"]={"Science", "Medicine"}
-- }

function onInit()
    self.major = nil
    self.minor1 = nil
    self.minor2 = nil
    self.attribute_selects = {}
    self.attribute_values = {}
    self.alertDefs = {
		{LifePathAlertHelper.alertSummary, {"academy"}, "Roll for Academy Track", "Academy Track Selected"},
		{LifePathAlertHelper.alertVFTFrame, {self.lifepath_academy_select_frame, "talent"}, "Select 1 Talent", "Talent Selected"},
		{LifePathAlertHelper.alertVFTFrame, {self.lifepath_academy_select_frame, "focus"}, "Create 3 Focuses", "Focuses Created"},
		{LifePathAlertHelper.alertVFTFrame, {self.lifepath_academy_select_frame, "value"}, "Create 1 Value", "Value Created"},
		{LifePathAlertHelper.alertAttDiscFrame, {self.discipline_selection_count}, "Pick 1 Major and 2 Minor Disciplines", "Major/Minor Disciplines allocated"},
		{LifePathAlertHelper.alertAttDiscFrame, {self.attribute_selection_count}, "Split 3 points across 2-3 Attributes", "Attributes allocated"},
		{LifePathAlertHelper.scoreLimitCount, {"discipline", 4, 4, 0}, "No Discipline may be &gt; 4 at this step", "All Disciplines &lt;= 4 at this step"}
    }
end

function statusControl()
    return "lifepath_academytab"
end

function getAlertDefs()
	return self.alertDefs
end

function getRollButton()
	return self.lifepath_academy_roll_button
end

function parentWindow()
    return ScopeManager.getLifepathWindow()
end

function updateMinorOnChange(minor, change, selected)
    if not minor then
        return
    end
    if selected then
        if minor.getValue() == change then
            minor.setValue(minor.display)
        end
        minor.remove(change)
    else
        minor.add(change, change, false)
    end
end

function handleMajorChanged(discipline, selected)
    self.updateMinorOnChange(self.minor1, discipline, selected)
    self.updateMinorOnChange(self.minor2, discipline, selected)
    if selected then
        self.parentWindow().incrementAttribute(discipline, self.lifepath_academy_discipline_select)
        self.parentWindow().incrementAttribute(discipline, self.lifepath_academy_discipline_select)
    else
        self.parentWindow().decrementAttribute(discipline, self.lifepath_academy_discipline_select)
        self.parentWindow().decrementAttribute(discipline, self.lifepath_academy_discipline_select)
    end
end

function handleMinor(other_minor, discipline, selected)
    self.updateMinorOnChange(other_minor, discipline, selected)
    if selected then
        self.parentWindow().incrementAttribute(discipline, self.lifepath_academy_discipline_select)
    else
        self.parentWindow().decrementAttribute(discipline, self.lifepath_academy_discipline_select)
    end
end

function handleMinor1(discipline, selected)
    self.handleMinor(self.minor2, discipline, selected)
end

function handleMinor2(discipline, selected)
    self.handleMinor(self.minor1, discipline, selected)
end

function updateAttributeValues(attribute, selected)
    local curVal = self.attribute_values[attribute]
    local overLimit;
    if curVal == nil then
        curVal = 0
    end
    if selected then
        self.attribute_values[attribute] = curVal + 1
    else
        self.attribute_values[attribute] = curVal - 1
    end
    overLimit = self.attribute_values[attribute]  >= 2
    for _, t in ipairs(self.attribute_selects) do
        if overLimit then
            if not (t.getValue() == attribute) then
                t.remove(attribute)
            end
        else
            if not t.hasValue(attribute) then
                t.add(attribute)
            end
        end
    end
end

function handleAttribute(attribute, selected)
    self.updateAttributeValues(attribute, selected)
    if selected then
        self.parentWindow().incrementAttribute(attribute, self.lifepath_academy_attribute_select)
    else
        self.parentWindow().decrementAttribute(attribute, self.lifepath_academy_attribute_select)
    end
end

function setManualMode(isManual, name)
    if isManual then
        self.major = self.lifepath_academy_discipline_select.addWindow(ScopeManager.ALL_DISCIPLINES, self.handleMajorChanged, "Major").combo_control
        self.minor1 = self.lifepath_academy_discipline_select.addWindow(ScopeManager.ALL_DISCIPLINES, self.handleMinor1, "Minor").combo_control
        self.minor2 = self.lifepath_academy_discipline_select.addWindow(ScopeManager.ALL_DISCIPLINES, self.handleMinor2, "Minor").combo_control
        self.attribute_selects = {
            self.lifepath_academy_attribute_select.addWindow(ScopeManager.ALL_ATTRIBUTES, self.handleAttribute, "Attribute 1").combo_control,
            self.lifepath_academy_attribute_select.addWindow(ScopeManager.ALL_ATTRIBUTES, self.handleAttribute, "Attribute 2").combo_control,
            self.lifepath_academy_attribute_select.addWindow(ScopeManager.ALL_ATTRIBUTES, self.handleAttribute, "Attribute 3").combo_control,
    }
    else
        self.lifepath_academy_attribute_select.closeAll()
        self.lifepath_academy_discipline_select.closeAll()
        self.major = nil
        self.minor1 = nil
        self.minor2 = nil
        self.attribute_selects = {}
    end
end

function updateSummary(summary, academyTrack, disciplines)
	summary.subwindow["academy"].setValue(academyTrack);
--     local disciplines = ACADEMY_TRACKS[academyTrack];
    self.major = self.lifepath_academy_discipline_select.addWindow(disciplines, self.handleMajorChanged, "Major").combo_control
    self.minor1 = self.lifepath_academy_discipline_select.addWindow(ScopeManager.ALL_DISCIPLINES, self.handleMinor1, "Minor").combo_control
    self.minor2 = self.lifepath_academy_discipline_select.addWindow(ScopeManager.ALL_DISCIPLINES, self.handleMinor2, "Minor").combo_control
    self.attribute_selects = {
        self.lifepath_academy_attribute_select.addWindow(ScopeManager.ALL_ATTRIBUTES, self.handleAttribute, "Attribute 1").combo_control,
        self.lifepath_academy_attribute_select.addWindow(ScopeManager.ALL_ATTRIBUTES, self.handleAttribute, "Attribute 2").combo_control,
        self.lifepath_academy_attribute_select.addWindow(ScopeManager.ALL_ATTRIBUTES, self.handleAttribute, "Attribute 3").combo_control,
    }
end