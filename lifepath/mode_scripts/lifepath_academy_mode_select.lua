--
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
    window.setManualMode(isManual)
    window.lifepath_academy_name_manual.setValue('');
    if isManual then
		window.lifepath_academy_name_manual.setVisible(true);
		window.lifepath_academy_name_manual_label.setVisible(true);
		
		window.lifepath_academy_roll_button.setVisible(false);
		window.lifepath_academy_roll_label.setVisible(false);
		
        window.lifepath_academy_name_manual.onValueChanged()
    else
		window.lifepath_academy_name_manual.setVisible(false);
		window.lifepath_academy_name_manual_label.setVisible(false);
		window.lifepath_academy_roll_button.setVisible(true);
		window.lifepath_academy_roll_label.setVisible(true);
    end
end

function onValueChanged()
	window.lifepath_academy_roll_button.setMode(getValue())
    self.setManual(getValue() == "MANUAL")
end