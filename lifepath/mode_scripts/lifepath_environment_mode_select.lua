
MODES = {
	"MANUAL"
};

function onInit()
    super.onInit()
    addItems(MODES)
    addItems(LifePathTableManager.getAllActiveTables())
    self.setValue(LifePathTableManager.getDefaultTable())
    onValueChanged()
end

function setManual(isManual)
    window.lifepath_environment_discipline_select.closeAll()
	if isManual then
		window.lifepath_environment_name_manual.setVisible(true);
		window.lifepath_environment_name_manual_label.setVisible(true);
		window.lifepath_environment_roll_button.setVisible(false);
		window.lifepath_environment_roll_label.setVisible(false);
		for _, score in ipairs(ScopeManager.ALL_DISCIPLINES) do
			window.addDiscipline(score);
		end
		for _, score in ipairs(ScopeManager.ALL_ATTRIBUTES) do
			window.addAttribute(score);
		end
	else
		window.lifepath_environment_name_manual.setVisible(false);
		window.lifepath_environment_name_manual.setValue('');
		window.lifepath_environment_name_manual_label.setVisible(false);
		window.lifepath_environment_roll_button.setVisible(true);
		window.lifepath_environment_roll_label.setVisible(true);
	end
end

function onValueChanged()
    window.lifepath_environment_roll_button.setMode(getValue())
    self.setManual(getValue() == "MANUAL")
end