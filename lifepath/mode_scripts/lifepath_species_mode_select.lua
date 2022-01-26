--
-- MODES = {
-- 	"WIKI",
-- 	"GENERATED",
-- 	"MANUAL"
-- };

function onInit()
	super.onInit();
-- 	addItems(MODES);
    addItems(LifePathTableManager.getAllActiveTables())
    self.setValue(LifePathTableManager.getDefaultTable())
	onValueChanged();
end

function setManual(isManual)
	window.lifepath_species_attribute_select.closeAll();
	if isManual then
		window.lifepath_species_name_manual.setVisible(true);
		window.lifepath_species_name_manual_label.setVisible(true);
		window.lifepath_species_roll_button.setVisible(false);
		window.lifepath_species_roll_label.setVisible(false);
		for _, attribute in ipairs(ScopeManager.ALL_ATTRIBUTES) do
			window.addAttribute(attribute);
		end
	else
		window.lifepath_species_name_manual.setVisible(false);
		window.lifepath_species_name_manual.setValue('');
		window.lifepath_species_name_manual_label.setVisible(false);
		window.lifepath_species_roll_button.setVisible(true);
		window.lifepath_species_roll_label.setVisible(true);
	end
end

function onGenerateDone()
	window.lifepath_species_reroll_name_button.setVisible(true)
	window.lifepath_species_reroll_name_label.setVisible(true)
end

function onValueChanged()
	window.lifepath_species_roll_button.setMode(getValue())
	self.setManual(getValue() == "MANUAL")
end
