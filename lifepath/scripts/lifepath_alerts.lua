
function onInit()
	self.scoreTypes = {
		["attribute"]={ScopeManager.ALL_ATTRIBUTES, 7},
		["discipline"]={ScopeManager.ALL_DISCIPLINES, 1}
	}
end

function alertSummary(stepName)
	return ScopeManager.getSummaryVal(stepName) == ""
end

function alertSummaryCount(stepName, size)
	return ScopeManager.getSummaryListSize(stepName) < size
end

function alertAttDiscFrame(frame)
    return frame.getValue() > 0
end

function alertVFTFrame(frame, class)
    return not(frame.allSelected(class))
end

function scoreSumExact(scoreType, scoreTarget, atStep)
	local statList, scoreDefault = unpack(self.scoreTypes[scoreType])
	local totalScores = ScopeManager.getLifepathWindow().getStatsThroughStep(statList, atStep, scoreDefault)
	local scoreSum = 0
	for _, score in pairs(totalScores) do
		scoreSum = scoreSum + score
	end
	return not(scoreSum == scoreTarget)
end

function scoreLimitCount(scoreType, scoreMax, atStep, scoreCount)
	local atLimit = 0
	local statList, scoreDefault = unpack(self.scoreTypes[scoreType])
	local totalScores = ScopeManager.getLifepathWindow().getStatsThroughStep(statList, atStep, scoreDefault)

	for _, score in pairs(totalScores) do
		if score > scoreMax then
			return true
		elseif score == scoreMax then
			atLimit = atLimit + 1
		end
	end
	return (scoreCount > 0) and (atLimit > scoreCount)
end

function getAlerts(alertDefs)
	local alerts = {}
	for _, alertDef in ipairs(alertDefs) do
		local func, args, errText, okText = unpack(alertDef);
		alerts[_] = {func(unpack(args)), errText, okText}
	end
	return alerts
end


COLOR_FATAL = "ffc86763"
COLOR_ERROR = "ffeec515"
COLOR_OK = "ff64bca4"
COLOR_DESELECT = "ff424242"
STEP_NAMES = {"Species", "Environment", "Upbringing", "Academy", "Career", "Career Events", "Finishing Touches"}
function getErrors()
	local errorCount = 0
	local error_str = "The following Lifepath errors were detected:\n"
	local fatal = false
	for stepNum, alertDef in ipairs(ScopeManager.getLifepathWindow().alertFunctions()) do
		local stepName = STEP_NAMES[stepNum]
		local alertState = 0
		local stepFatal = false
		if ((stepNum < 6 ) and (ScopeManager.getSummaryVal(string.lower(stepName)) == "")) or
				((stepNum == 6) and (ScopeManager.getSummaryListSize("career_events") < 2)) then
			error_str = error_str .. stepName .. " has not been rolled\n"
			errorCount = errorCount + 1
			fatal = true
			stepFatal = true
		end
		local alertFunc, statusControl = unpack(alertDef)
		local alerts = LifePathAlertHelper.getAlerts(alertFunc())
		for _, alert in ipairs(alerts) do
			if alert[1] then
				alertState = alertState + 1
				if errorCount < 8 then
				error_str = error_str .. "Error on step " .. stepNum .. ": " .. alert[2] .. "\n"
				end
				errorCount = errorCount + 1
				alertState = alertState + 1
			end
		end
		local color
		if stepFatal then color = COLOR_FATAL
		elseif alertState > 0 then color = COLOR_ERROR
		else color = COLOR_OK end
		statusControl.setBackColor(color)
		if stepNum == ScopeManager.getLifepathWindow().tabs.getIndex() then
			ScopeManager.getLifepathWindow().step_alert_list.setAlerts(alerts)
		end
	end
	ScopeManager.getLifepathWindow().setSaveIcon(errorCount, fatal)
	return {errorCount, error_str, fatal}
end