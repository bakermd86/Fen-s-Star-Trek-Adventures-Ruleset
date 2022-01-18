STEP_DEFS = {
	{"lifepath_species", "species"},
	{"lifepath_environment", "environment"},
	{"lifepath_upbringing", "upbringing"},
	{"lifepath_academy", "academy"},
	{"lifepath_career", "career"},
	{"lifepath_career_events", "career_events"}
}
GENERATED_ALIEN_TEMPLATE = "storytemplate.alien_species@Fen's GM Resources"

TAB_MAP = {
	"gen_species",
	"genenvironment",
	"genupbringing",
	"genacademy",
	"gencareer",
	"genevents",
	"genfinish",
}

function onInit()
	self.saving = false
	self.closing = false
	self.rolledSteps = {}

	GameSystem.actions["lifepath_species"] = { };
	GameSystem.actions["lifepath_environment"] = { };
	GameSystem.actions["lifepath_environment_another_species"] = { };
	GameSystem.actions["lifepath_upbringing"] = { };
	GameSystem.actions["lifepath_academy"] = { };
	GameSystem.actions["lifepath_career"] = { };
	GameSystem.actions["lifepath_career_events"] = { };
	GameSystem.actions["lifepath_age"] = { };
	GameSystem.actions["lifepath_details"] = { };
	GameSystem.actions["lifepath_generate_species"] = { };

	ActionsManager.registerResultHandler("lifepath_species", handleSpecies);
	ActionsManager.registerResultHandler("lifepath_environment", handleEnvironment);
	ActionsManager.registerResultHandler("lifepath_environment_another_species", handleEnvironmentAnotherSpecies);
	ActionsManager.registerResultHandler("lifepath_upbringing", handleUpbringing);
	ActionsManager.registerResultHandler("lifepath_academy", handleAcademy);
	ActionsManager.registerResultHandler("lifepath_career", handleCareer);
	ActionsManager.registerResultHandler("lifepath_career_events", handleCareerEvents);
	ActionsManager.registerResultHandler("lifepath_age", handleAge);
	ActionsManager.registerResultHandler("lifepath_details", handleLifepathDetails);
	ActionsManager.registerResultHandler("lifepath_generate_species", handleRandomSpeciesResult);


	self.generatedSpeciesData = {}
	self.generatedSpeciesAttributes = {}
    self.speciesGenerated = false
	self.unpredictableTemperamentAttribute = ""
	self.statIncreases={
		{}, {}, {}, {}, {}, {}, {}
	}

	Module.onModuleLoad = onModuleLoad
	if STAModuleManager.checkModules() then
		autoRoll()
	end
end

function onModuleLoad(module)
	if module == ScopeManager.MODULE_MAIN then
		autoRoll()
	end
end

function autoRoll()
	self.rollCombinedDetails()  ---Kick off gender, height and weight rolls at this point
-- 	for i=2,6 do
-- 		self.rollStep(i)
-- 	end
	Module.onModuleLoad = nil
end

function rollSteps(steps)
	for _, i in ipairs(steps) do
		self.rollStep(i)
	end
end


function onClose()
	self.closing = true
	DB.deleteNode(ScopeManager.getLpNode())
end

function handleChangeToTabCallback(newTab)
	local w = getTabWindow(newTab)
	if w and w.onTabTo then w.onTabTo() end
end

function handleChangeFromTabCallback(oldTab)
	local w = getTabWindow(oldTab)
	if w and w.onTabFrom then w.onTabFrom() end
end

function setSaveIcon(errorCount, fatal)
	local color
	if fatal then color = LifePathAlertHelper.COLOR_FATAL
	elseif errorCount > 0 then color = LifePathAlertHelper.COLOR_ERROR
	else color = LifePathAlertHelper.COLOR_OK end
	save_button.setBackColor(color)
end

function getTabWindow(tabNum)
	return self[TAB_MAP[tabNum]].subwindow.contents.subwindow
end

function updateAlerts()
	LifePathAlertHelper.getErrors()
end

function alertFunctions()
	local alerts = {}
	for i=1,7 do
		local w = getTabWindow(i)
		table.insert(alerts, {w.getAlertDefs, self[w.statusControl()]})
	end
	return alerts
end

function splitTableString(inString)
	local fields = {}
	local pattern = "([^;]+)"
	local cleanString = inString:gsub("[ ]*[;][ ]+", ";")
	cleanString:gsub(pattern, function(c) fields[#fields+1] = c end)
	return fields
end

function getNestedBonus(inString)
	local words = getWords(inString)
	return {words[1], words[#words-1], words[#words] }
end

function parseBonusString(bonusVals, bonusString, columns)
	if string.sub(bonusString, 1, 3) == "+1 " then
		if string.lower(string.sub(bonusString, 4, 6)) == "any" then
			bonusVals["any"]=1
			return true
		end
		bonusVals[string.sub(bonusString, 4)]=1
		return true
	elseif string.sub(bonusString, 1, 3) == "+2 " then
		local res1, val1, bonus1 = unpack(getNestedBonus(columns[2]))
		local res2, val2, bonus2 = unpack(getNestedBonus(columns[4]))
		if ((res1 == res2) or (bonus1 == bonus2)) then
			return false
		elseif not((val1 == "+1") and (val2 == "+1")) then
			return false
		else
			bonusVals[bonus1]=2
			bonusVals[bonus2]=-1
			return  true
		end
	elseif string.lower(string.sub(bonusString, 1, 30)) == "roll unpredictable temperament" then
		local w = Interface.openWindow("storytemplate", "")
		self.unpredictableTemperamentAttribute = w.generate.performTableLookups("[Unpredictable Temperament]")
		bonusVals[self.unpredictableTemperamentAttribute]=1
		w.close()
		return true
	else
		Debug.chat("Special case bonus string: " .. bonusString)
		Debug.chat(table.concat(columns, ";"))
		return false
	end
end

function getWords(inString)
	local fields = {}
	local pattern = "([^ ,]+)"
	inString:gsub(pattern, function(c) fields[#fields+1] = c end)
	return fields
end

function getFirstWord(inString)
	return getWords(inString)[1]
end

function parseSpeciesColumns(tableName)
	local columns = self.splitTableString(self.generatedSpeciesData[tableName.."_text"])
	local textDesc;
	if #columns == 1 then
		textDesc = columns[1]
	elseif #columns == 5 then
		textDesc = columns[1] .. getFirstWord(columns[2]) .. columns[3] ..getFirstWord(columns[4]) .. columns[5]
	else
		Debug.chat("Bad column length, probably got nested redirects. Reroll: " .. #columns)
		return false
	end

	local bonusVals = {}
	if not self.parseBonusString(bonusVals, self.generatedSpeciesData[tableName.."_bonus"], columns) then return false end
	self.generatedSpeciesData[tableName.."_text"] = textDesc
	for k, v in pairs(bonusVals) do
		if not(self.generatedSpeciesAttributes[k] == nil) then
			self.generatedSpeciesAttributes[k] = self.generatedSpeciesAttributes[k] + v
		else
			self.generatedSpeciesAttributes[k] = v
		end
	end
	return true
end

function formatBonusDisplay(bonus)
	local output = {}
	for k, v in pairs(bonus) do
		local sVal ;
		if v > 0 then
			sVal = "+"..v.." "..k
		else
			sVal = v.." "..k
		end
		table.insert(output, sVal)
	end
	return table.concat(output, ", ")
end

function newRandomSpeciesName()
	self.setRandomSpeciesName()
	ScopeManager.setSummaryVal("species", self.generatedSpeciesData["name"] )
	ScopeManager.getSummary().traits.getWindows()[1].name.setValue(self.generatedSpeciesData["name"])
end

function setRandomSpeciesName()
	local w = Interface.openWindow("storytemplate", "")
	self.generatedSpeciesData["name"] = w.generate.performTableLookups("[SpeciesNameTable]")
	w.close()
end

function setRandomSpeciesData(tableName)
	local w = Interface.openWindow("storytemplate", "")
	repeat
		self.generatedSpeciesData[string.lower(tableName)] = w.generate.performTableLookupsStorage("["..tableName.."]", tableName)
		self.generatedSpeciesData[string.lower(tableName).."_name"] = w.generate.performCalloutStorageReferences("{#"..tableName.."|1#}")
		self.generatedSpeciesData[string.lower(tableName).."_text"] = w.generate.performCalloutStorageReferences("{#"..tableName.."|2#}")
		self.generatedSpeciesData[string.lower(tableName).."_bonus"] = w.generate.performCalloutStorageReferences("{#"..tableName.."|3#}")
	until(parseSpeciesColumns(string.lower(tableName)))
	w.close()
end

function getSpeciesTrait()
	local traits = ScopeManager.getSummary().traits
	local w
	if traits.getWindowCount() > 0 then
		w = traits.getWindows()[1]
	else
		w = traits.createWindowWithClass("ref_note_item", true)
	end
	return w
end

function saveRandomSpeciesResult()
	self.setRandomSpeciesData("Temperament")
	self.setRandomSpeciesData("Biology")
	self.setRandomSpeciesData("Ideology")
	local tab = ScopeManager.getSpeciesTab()
	tab.lifepath_species_genmethod.onGenerateDone()
	tab.lifepath_species_genmethod.onGenerateDone()
	local w = getSpeciesTrait()
	w.name.setValue(self.generatedSpeciesData["name"])
	w.text.setValue(self.formatSpeciesDataBody())
	ScopeManager.setSummaryVal("species", self.generatedSpeciesData["name"] )
	tab.lifepath_species_ref.closeAll();
	tab.lifepath_species_ref.createWindow(w.getDatabaseNode().getNodeName());
	tab.updateGeneratedAttributes(self.generatedSpeciesAttributes);
    _species_attributes_backref = {}
    for attribute, p in pairs(self.generatedSpeciesAttributes) do
        if p >= 1 then
            table.insert(_species_attributes_backref, attribute)
        end
    end
	if _environment_species_callback then
        ScopeManager.getEnvironmentTab().updateSummary(summary, _environment_species_backname, _species_attributes_backref, _environment_disciplines_backref);
	end
end

function formatSpeciesDataBody()
	local outStr = "<h>Biology: "..self.generatedSpeciesData["biology_name"]..
			"</h><p><b>"..self.generatedSpeciesData["biology_bonus"].."</b>"..
			self.generatedSpeciesData["biology_text"].."</p>"..
			"<h>Temperament: "..self.generatedSpeciesData["temperament_name"]..
			"</h><p><b>"..self.generatedSpeciesData["temperament_bonus"].."</b> - "..
			self.generatedSpeciesData["temperament_text"].."</p>"..
			"<h>Ideology: "..self.generatedSpeciesData["ideology_name"]..
			"</h><p><b>"..self.generatedSpeciesData["ideology_bonus"].."</b> - "..
			self.generatedSpeciesData["ideology_text"].."</p>"
	return outStr
end

function rollRandomSpecies()
	local w = Interface.openWindow("storytemplate", "")
	self.generatedSpeciesData = {}
	self.generatedSpeciesAttributes = {}
	self.unpredictableTemperamentAttribute = ""
	self.generatedSpeciesData["name"] = w.generate.performTableLookups("[SpeciesNameTable]")
	w.close()
	self.saveRandomSpeciesResult()
end

function rollRandomName()
	local w = Interface.openWindow("storytemplate", "")
	self.name.setValue(w.generate.performTableLookups("[IndividualNameTable]"))
	w.close()
end

function rollStep(stepNum, rollButton)
	if rollButton.mode == "MANUAL" then
		return
	elseif (stepNum == 1) and (rollButton.mode == "GENERATED") then
		self.rolledSteps[stepNum] = stepNum
		rollRandomSpecies()
		return
	end
	local rollType, summaryField = unpack(STEP_DEFS[stepNum])
	local rollWiki = ((stepNum == 1) and (rollButton.mode == "WIKI"))
	local tableName = "";
	if rollWiki then
		tableName = "Memory Alpha Weighted Species";
	elseif rollButton then
		rollButton.setEnabled(false);
		rollButton.setIcons("d20ricon", "d20ricon");
	    tableName = LifePathTableManager.getActiveStepName(rollButton.mode, stepNum)
	else
	    return
	end
	if (ScopeManager.getSummaryVal(summaryField) == '') or rollWiki
		or ((summaryField == "career_events") and (ScopeManager.getSummaryListSize("career_events") <= 1))
	then
		self.rolledSteps[stepNum] = tableName
		rollSimple(tableName, rollType)
	else
		Interface.dialogMessage(nil, tableName .. " already rolled", "Lifepath Error", nil)
	end
end

function updateSummary(step)
	for attribute, value in pairs(self.getStatsThroughStep(ScopeManager.ALL_ATTRIBUTES, step, 7)) do
		ScopeManager.setSummaryVal(attribute, value)
	end
	for discipline, value in pairs(self.getStatsThroughStep(ScopeManager.ALL_DISCIPLINES, step, 1)) do
		ScopeManager.setSummaryVal(discipline, value)
	end
end

function getStatsThroughStep(stats, step, default)
	local totalStats = {}
	for _, attributeName in ipairs(stats) do
		local attribute = string.lower(attributeName);
		if step == 7 then
			totalStats[attribute] = ScopeManager.getSummaryVal(attribute)
		else
			totalStats[attribute] = default
			for i = 1, step, 1 do
				totalStats[attribute] = totalStats[attribute] + self.getStatAtStep(attribute, i);
			end

		end
	end
	return totalStats
end

function getStatAtStep(stat, step)
	if self.statIncreases[step][stat] == nil then
		return 0
	else
		return self.statIncreases[step][stat]
	end
end


function handleStepStatChange(stat, step, value)
	if self.statIncreases[step][stat] == nil then
		self.statIncreases[step][stat] = value
	else
		self.statIncreases[step][stat] = self.statIncreases[step][stat] + value
	end
end

function incrementAttribute(attributeName, source)
    if self.closing then return end
	local attribute = string.lower(attributeName);
	if summary then ScopeManager.setSummaryVal(attribute, ScopeManager.getSummaryVal(attribute) + 1) end
	if source then
		local step = source.getStep()
		self.handleStepStatChange(attribute, step, 1)
		local remaining = source.getCount() - 1;
		if remaining == 0 then
			source.lock()
		end
		source.setCount(remaining);
	end
end

function decrementAttribute(attributeName, source)
    if self.closing then return end
	if not summary then
		return
	end
	local attribute = string.lower(attributeName);
	if summary then ScopeManager.setSummaryVal(attribute, ScopeManager.getSummaryVal(attribute) - 1) end
	if source then
		local step = source.getStep()
		self.handleStepStatChange(attribute, step, -1)
		local remaining = source.getCount() + 1;
		if remaining == 1 then
			source.unlock()
		end
		source.setCount(remaining);
	end
end

function rollCombinedDetails()
    local roll = {["aDice"]={
        "d20", -- Gender
        "d20", "d20", "d20", -- Height
        "d20", "d20", "d20", "d20" -- Weight
    }, ["sType"]="lifepath_details"}  -- Age is rolled separately based on Career Experience level
	ActionsManager.roll(nil, nil, roll, nil)
end

function rollAge()
	local ageRoll = {["aDice"]={"d6", "d6"}, ["sType"]="lifepath_age"};
	ActionsManager.roll(nil, nil, ageRoll, nil)
end

function handleLifepathDetails(_, __, rRoll)
	if not self then return end
    local dice = rRoll['aDice']
    local gender = handleGender(dice[1])
    local height = handleHeight({ dice[2], dice[3], dice[4] }, gender)
    handleWeight({ dice[5], dice[6], dice[7], dice[8] }, height)
end


function handleWeight(dice, height)
    local weight = RollManager.handleWeight(dice, height)
	ScopeManager.setSummaryVal("weight", weight)
end

function handleHeight(dice, gender)
	local height = RollManager.handleHeight(dice, gender)
	ScopeManager.setSummaryVal("height", height)
	return height
end

function handleGender(die)
    local gender = RollManager.handleGender(die)
	ScopeManager.setSummaryVal("gender", gender)
	return gender
end

function handleAge(rSource, rTarget, rRoll)
	if not self then return end
	local nTotal = ActionsManager.total(rRoll);
	ScopeManager.setSummaryVal("age", nTotal + _careerBaseAgeCallback);
end

function handleNestedTable(name, rollType)
	if string.sub(name, 1, 1) == "[" then
		rollSimple(string.sub(name, 2, -2), rollType);
		return true
	end
	return false
end

function getAttributesSafe(attributes)
	if attributes ~= nil and attributes['text'] ~= "" then
	    return ScopeManager.splitColumn(attributes['text'])
	else
	    return {"Any"}
    end
end

_species_name_backref = ""
_species_attributes_backref = {}
function handleSpecies(rSource, rTarget, rRoll)
	if not self then return end
	local name, ref, result_cols = handleLifePathResult(rSource, rTarget, rRoll)
    local rollType, __ = unpack(STEP_DEFS[1])
	if handleNestedTable(name, rollType) then return end
	_species_name_backref = name
	local attributes = unpack(result_cols)
	_species_attributes_backref = getAttributesSafe(attributes)
	local w = getSpeciesTrait()
	w.name.setValue(name)
	if (ref or "") ~= "" then
	    local text = DB.getValue(DB.findNode(ref), "text", "")
	    w.text.setValue(text)
    end
	local tab = ScopeManager.getSpeciesTab()
	tab.lifepath_species_ref.closeAll();
	tab.lifepath_species_ref.createWindow(w.getDatabaseNode().getNodeName());
	tab.updateSummary(summary, name, _species_attributes_backref);
	if _environment_species_callback then
        ScopeManager.getEnvironmentTab().updateSummary(summary, _environment_species_backname, _species_attributes_backref, _environment_disciplines_backref);
        _environment_species_callback = false;
	end
	ScopeManager.updateAlerts()
end

_environment_species_backname = "";
_environment_species_backref = "";
_environment_species_callback = false;
_environment_other_species_callback = false;
_environment_disciplines_backref = {}
function handleEnvironment(rSource, rTarget, rRoll)
	if not self then return end
	local name, ref, result_cols = handleLifePathResult(rSource, rTarget, rRoll)
	local attributes, disciplines = unpack(result_cols)
	_environment_disciplines_backref = ScopeManager.splitColumn(disciplines['text'])
	attributes = ScopeManager.splitColumn(attributes['text'])
	if #attributes == 1 and attributes[1] == "OtherSpecies" then
	    _environment_species_backref = ref
	    _environment_species_backname = name
	    if not ((self.rolledSteps[1] == nil) or (self.rolledSteps[1] == 1))  then
		    rollSimple(self.rolledSteps[1], "lifepath_environment_another_species")
		else
		    local tableName = LifePathTableManager.getActiveStepName(LifePathTableManager.getDefaultTable(), 1)
		    rollSimple(tableName, "lifepath_environment_another_species")
		end
	else
		ScopeManager.getEnvironmentTab().lifepath_environment_ref.createWindow(ref);
		if #attributes == 1 and attributes[1] == "Species" then
		    if #_species_attributes_backref > 0 then
		        ScopeManager.getEnvironmentTab().updateSummary(summary, name, _species_attributes_backref, _environment_disciplines_backref);
		        _species_attributes_backref = {}
		    else
	            _environment_species_backname = name
		        _environment_species_callback = true;
            end
		else
		    ScopeManager.getEnvironmentTab().updateSummary(summary, name, attributes, _environment_disciplines_backref);
        end
	end
	ScopeManager.updateAlerts()
end

function handleUpbringing(rSource, rTarget, rRoll)
	if not self then return end
	local name, ref, result_cols = handleLifePathResult(rSource, rTarget, rRoll)
	local acceptCol, rebelCol, disciplineCol = unpack(result_cols)
	local acceptAttrs = ScopeManager.splitColumn(acceptCol['text'])
	local rebelAttrs = ScopeManager.splitColumn(rebelCol['text'])
	local disciplines = ScopeManager.splitColumn(disciplineCol['text'])
	ScopeManager.getUpbringingTab()["lifepath_upbringing_ref"].createWindow(ref);
	ScopeManager.getUpbringingTab().updateSummary(summary, name, acceptAttrs, rebelAttrs, disciplines);
	ScopeManager.updateAlerts()
end

function handleEnvironmentAnotherSpecies(rSource, rTarget, rRoll)
	if not self then return end
	local name, ref, result_cols = handleLifePathResult(rSource, rTarget, rRoll)
	if handleNestedTable(name, "lifepath_environment_another_species") then return end
	local attributes = unpack(result_cols)
	attributes = getAttributesSafe(attributes)
	ScopeManager.getEnvironmentTab().lifepath_environment_ref.createWindow(_environment_species_backref);
	ScopeManager.getEnvironmentTab().updateSummaryWithSpecies(summary, name, attributes, _environment_disciplines_backref);
	ScopeManager.updateAlerts()
end

function handleAcademy(rSource, rTarget, rRoll)
	if not self then return end
	local name, ref, result_cols = handleLifePathResult(rSource, rTarget, rRoll)
	local disciplines = ScopeManager.splitColumn(result_cols[1]['text'])
	ScopeManager.getAcademyTab()["lifepath_academy_ref"].createWindow(ref);
	ScopeManager.getAcademyTab().updateSummary(summary, name, disciplines);
	ScopeManager.updateAlerts()
end

_careerBaseAgeCallback = 25
function handleCareer(rSource, rTarget, rRoll)
	if not self then return end
	local name, ref, result_cols = handleLifePathResult(rSource, rTarget, rRoll)
	local expCol, ageCol = unpack(result_cols)
	if tonumber(ageCol['text']) then
	    _careerBaseAgeCallback = tonumber(ageCol['text']) - 2
    end
	ScopeManager.getCareerTab()["lifepath_career_ref"].createWindow(ref);
	ScopeManager.getCareerTab().updateSummary(summary, name, expCol['ref']);
	self.rollAge()
	ScopeManager.updateAlerts()
end

function handleCareerEvents(rSource, rTarget, rRoll)
	if not self then return end
	local name, ref, result_cols = handleLifePathResult(rSource, rTarget, rRoll)
	local attCol, discCol = unpack(result_cols)
	local attributes = ScopeManager.splitColumn(attCol['text'])
	local disciplines = ScopeManager.splitColumn(discCol['text'])
	if ScopeManager.getCareerEventsTab().updateSummary(summary, name, ref, attributes[1], disciplines[1]) then
		ScopeManager.getCareerEventsTab()["lifepath_career_events_ref"].createWindow(ref);
		ScopeManager.updateAlerts()
	end
end

function rollSimple(tableName, rollType )
	local nodeTable = TableManager.findTable(tableName);
	local rollData = {
		["sNodeTable"]=nodeTable.getPath(),
		["sType"]=rollType,
		['sOutput']="",
		['bSecret']=false,
		['sDesc']="["..tableName.."]"
	}
	rollData.aDice, rollData.nMod = TableManager.getTableDice(nodeTable);
	ActionsManager.performAction(nil, summary, rollData);
end

function parseResultColumn(column_val)
	local text = column_val["sText"];
	local ref = column_val["sRecord"];
	return text, ref
end

function handleLifePathResult(rSource, rTarget, rRoll)
	local nTotal = ActionsManager.total(rRoll);
	local result = TableManager.getResults(DB.findNode(rRoll.sNodeTable), nTotal, 0);
	local name, ref = parseResultColumn(result[1])
	local result_cols = {}
	local ref_cols = {}
	for i = 2, #result, 1 do
	    local t, r = parseResultColumn(result[i])
	    result_cols[i-1] = {
	        ["text"]=t,
	        ["ref"]=r
	    }
	end
	return name, ref, result_cols
end
