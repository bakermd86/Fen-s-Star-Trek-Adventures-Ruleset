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
    window.lifepath_career_name_manual.setValue('');
    if isManual then
		window.lifepath_career_name_manual.setVisible(true);
		window.lifepath_career_name_manual_label.setVisible(true);
		
		window.lifepath_career_roll_button.setVisible(false);
		window.lifepath_career_roll_label.setVisible(false);
		
        window.lifepath_career_name_manual.onValueChanged()
    else
		window.lifepath_career_name_manual.setVisible(false);
		window.lifepath_career_name_manual_label.setVisible(false);
		window.lifepath_career_roll_button.setVisible(true);
		window.lifepath_career_roll_label.setVisible(true);
    end
end

function onValueChanged()
	window.lifepath_career_roll_button.setMode(getValue())
    self.setManual(getValue() == "MANUAL")
end