-- MODES = {
-- 	"MANUAL"
-- };

function onInit()
    super.onInit()
--     addItems(MODES)
    addItems(LifePathTableManager.getAllActiveTables())
    self.setValue(LifePathTableManager.getDefaultTable())
    onValueChanged()
end

function setManual(isManual)
    window.lifepath_career_events1_name_manual.setValue('');
    window.lifepath_career_events2_name_manual.setValue('');
    window.lifepath_career_events_attribute_select.closeAll()
    window.lifepath_career_events_discipline_select.closeAll()
    if isManual then
		window.lifepath_career_events1_name_manual.setVisible(true);
		window.lifepath_career_events2_name_manual.setVisible(true);
		window.lifepath_career_events_name_manual_label.setVisible(true);
		
		window.lifepath_career_events_roll_button.setVisible(false);
		window.lifepath_career_events_roll_label.setVisible(false);

		for _, score in ipairs(ScopeManager.ALL_DISCIPLINES) do
			window.addDiscipline(score);
		end
		for _, score in ipairs(ScopeManager.ALL_ATTRIBUTES) do
			window.addAttribute(score);
		end
    else
		window.lifepath_career_events1_name_manual.setVisible(false);
		window.lifepath_career_events2_name_manual.setVisible(false);
		window.lifepath_career_events_name_manual_label.setVisible(false);
		window.lifepath_career_events_roll_button.setVisible(true);
		window.lifepath_career_events_roll_label.setVisible(true);
    end
end

function onValueChanged()
	window.lifepath_career_events_roll_button.setMode(getValue())
    self.setManual(getValue() == "MANUAL")
end