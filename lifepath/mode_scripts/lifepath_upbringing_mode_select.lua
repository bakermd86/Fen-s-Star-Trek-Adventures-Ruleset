
-- MODES = {
-- 	"MANUAL"
-- };

CUSTOM_ATTRIBUTE_LABELS = {
    {2, 2, "+2 to one Attributes"},
    {1, 1, "+1 to one Attribute"},
}

function onInit()
    super.onInit()
--     addItems(MODES)
    addItems(LifePathTableManager.getAllActiveTables())
    self.setValue(LifePathTableManager.getDefaultTable())
    onValueChanged()
end

function onClose()
    window.lifepath_manual_upbringing_attribute_select.closeAll()
end

function populateManualAttributes()
    self.attribute_selectors = {}
    for step_id, body in ipairs(CUSTOM_ATTRIBUTE_LABELS) do
        local val, count, label = unpack(body)
        local w = window.lifepath_manual_upbringing_attribute_select.createWindow()
        w.label.setValue(label)
        w.multicount.setValue(val)
        w.counter.setValue(count)
        w.step_id.setValue(step_id)
        w.att_select.setScoreType("attribute")
        w.att_select.setWindow(self)
        w.att_select.addScores(ScopeManager.ALL_ATTRIBUTES)
        table.insert(self.attribute_selectors, w)
    end
end

function incrementAttribute(name, source)
    window.parentcontrol.window.parentcontrol.window.incrementAttribute(name, source)
end

function decrementAttribute(name, source)
    window.parentcontrol.window.parentcontrol.window.decrementAttribute(name, source)
end

function scoreSelected(name, source)
    for _, w in ipairs(window.lifepath_manual_upbringing_attribute_select.getWindows()) do
        w.att_select.availableScores[string.lower(name)] = nil
        w.att_select.applyFilter()
    end
end

function scoreDeselected(name, source)
    for _, w in ipairs(window.lifepath_manual_upbringing_attribute_select.getWindows()) do
        w.att_select.availableScores[string.lower(name)] = true
        w.att_select.applyFilter()
    end
end

function setManual(isManual)
    window.lifepath_upbringing_attribute_select.closeAll()
    window.lifepath_upbringing_discipline_select.closeAll()
    window.lifepath_manual_upbringing_attribute_select.closeAll()
	if isManual then
		window.lifepath_upbringing_name_manual.setVisible(true);
		window.lifepath_upbringing_name_manual_label.setVisible(true);
		window.lifepath_manual_upbringing_attribute_select.setVisible(true);
		window.lifepath_manual_upbringing_attribute_select_frame.setVisible(true);
	    self.populateManualAttributes()

		window.lifepath_upbringing_roll_button.setVisible(false);
		window.lifepath_upbringing_roll_label.setVisible(false);
		window.lifepath_upbringing_attribute_select.setVisible(false);
		for _, score in ipairs(ScopeManager.ALL_DISCIPLINES) do
			window.addDiscipline(score);
		end
	else
		window.lifepath_upbringing_name_manual.setVisible(false);
		window.lifepath_upbringing_name_manual.setValue('');
		window.lifepath_upbringing_name_manual_label.setVisible(false);
		window.lifepath_manual_upbringing_attribute_select.setVisible(false);
		window.lifepath_manual_upbringing_attribute_select_frame.setVisible(false);

		window.lifepath_upbringing_attribute_select.setVisible(true);
		window.lifepath_upbringing_roll_button.setVisible(true);
		window.lifepath_upbringing_roll_label.setVisible(true);
	end
end

function onValueChanged()
	window.lifepath_upbringing_roll_button.setMode(getValue())
    self.setManual(getValue() == "MANUAL")
end