function onFirstLayout()
    self.attributePoints = 0
    self.disciplinePoints = 0
    self.modifiedScores = {}
    self.scoreTweakButtons = {}
    self.alertDefs = self.getAlertDefs()
    for _, attribute in ipairs(ScopeManager.ALL_ATTRIBUTES) do
        self.addAttribute(attribute);
    end
    for _, discipline in ipairs(ScopeManager.ALL_DISCIPLINES) do
        self.addDiscipline(discipline);
    end
end

function onTabTo()
    self.addScoreTweakButtons()
    self.updateScoreStates(2)
    self.updateScoreStates(1)
end

function onTabFrom()
    self.clearTweakButtons()
end

function statusControl()
    return "lifepath_finishing_touchestab"
end

function getRollButton()
	return nil
end


function canReduce(score, scoreType)
    local limit = self.getScoreLimits()[scoreType]
    local scoreTypeStr
    if scoreType == 1 then
        scoreTypeStr = 'discipline'
    else
        scoreTypeStr = 'attribute'
    end
    return (ScopeManager.getSummaryVal(string.lower(score))> limit) or
            ((not(self.modifiedScores[score] == nil) and (self.modifiedScores[score] > 0))) or
            ((ScopeManager.getSummaryVal(string.lower(score)) == limit) and LifePathAlertHelper.scoreLimitCount(scoreTypeStr, limit, 7, 1))
end

function canRaiseAttribute(score)
    return self.canRaise(score, 2)
end

function canReduceAttribute(score)
    return self.canReduce(score, 2)
end

function canRaiseDiscipline(score)
    return self.canRaise(score, 1)
end

function canReduceDiscipline(score)
    return self.canReduce(score, 1)
end


function canRaise(score, scoreType)
    local limit = self.getScoreLimits()[scoreType]
    local scoreTypeStr
    local ptCounter
    if scoreType == 1 then
        scoreTypeStr = 'discipline'
        ptCounter = self.disciplinePoints
    else
        scoreTypeStr = 'attribute'
        ptCounter = self.attributePoints
    end
    return (ptCounter > 0) and (ScopeManager.getSummaryVal(string.lower(score)) < limit)
end
function modifyScore(score, mod)
    local oldScoreMod ;
    if self.modifiedScores[score] == nil then
        oldScoreMod = 0
    else
       oldScoreMod = self.modifiedScores[score]
    end
    self.modifiedScores[score] = oldScoreMod + mod
    ScopeManager.setSummaryVal(string.lower(score), ScopeManager.getSummaryVal(string.lower(score)) + mod)
end

function updateAttributePoints(mod)
    self.attributePoints = self.attributePoints + mod
    self.tweak_attributes_points_remain.setValue(self.tweak_attributes_points_remain.getValue() + mod)
end

function updateDisciplinePoints(mod)
    self.disciplinePoints = self.disciplinePoints + mod
    self.tweak_disciplines_points_remain.setValue(self.tweak_disciplines_points_remain.getValue() + mod)
end

function raiseAttribute(attribute)
    if self.canRaise(attribute, 2) and (self.attributePoints > 0) then
        self.modifyScore(attribute, 1)
        self.updateAttributePoints(-1)
        self.updateScoreStates(2)
    end
end

function reduceAttribute(attribute)
    if self.canReduce(attribute, 2) then
        self.modifyScore(attribute, -1)
        self.updateAttributePoints(1)
        self.updateScoreStates(2)
    end
end

function raiseDiscipline(discipline)
    if self.canRaise(discipline, 1) and (self.disciplinePoints > 0) then
        self.modifyScore(discipline, 1)
        self.updateDisciplinePoints(-1)
        self.updateScoreStates(1)
    end
end

function reduceDiscipline(discipline)
    if self.canReduce(discipline, 1) then
        self.modifyScore(discipline, -1)
        self.updateDisciplinePoints(1)
        self.updateScoreStates(1)
    end
end

function clearTweakButtons()
    if ScopeManager.getLifepathWindow() and ScopeManager.getLifepathWindow().attribute_tweak_buttons then
        ScopeManager.getLifepathWindow().attribute_tweak_buttons.closeAll()
        ScopeManager.getLifepathWindow().discipline_tweak_buttons.closeAll()
    end
    self.scoreTweakButtons = {}
end

function updateScoreStates(scoreType)
    local scores;
    if scoreType == 1 then
        scores = ScopeManager.ALL_DISCIPLINES
    else
        scores = ScopeManager.ALL_ATTRIBUTES
    end
    for _, score in ipairs(scores) do
        self.updateScoreState(score, scoreType)
    end
end

function updateScoreState(score, scoreType)
    local w = self.scoreTweakButtons[score]
    w.setControlState(self.canRaise(score, scoreType), self.canReduce(score, scoreType))
end

function addScoreTweakButtons()
    self.clearTweakButtons()
    if not ScopeManager.getLifepathWindow() then return end
    local attTweakList = ScopeManager.getLifepathWindow().attribute_tweak_buttons
    for _, attribute in ipairs(ScopeManager.ALL_ATTRIBUTES) do
        local w = attTweakList.createWindow()
        w.setTarget(attribute)
        w.setCallbacks(self.raiseAttribute, self.reduceAttribute)
        self.scoreTweakButtons[attribute] = w
        self.updateScoreState(attribute, 2)
    end
    local discTweakList = ScopeManager.getLifepathWindow().discipline_tweak_buttons
    for _, discipline in ipairs(ScopeManager.ALL_DISCIPLINES) do
        local w = discTweakList.createWindow()
        w.setTarget(discipline)
        w.setCallbacks(self.raiseDiscipline, self.reduceDiscipline)
        self.scoreTweakButtons[discipline] = w
        self.updateScoreState(discipline, 1)
    end
end

function addAttribute(attribute)
	local attWindow = self.lifepath_finishing_touches_attribute_select.addWindow();
	attWindow.lifepath_attribute_select_control.setName(attribute);
	return attWindow
end

function addDiscipline(discipline)
	local attWindow = self.lifepath_finishing_touches_discipline_select.addWindow();
	attWindow.lifepath_attribute_select_control.setName(discipline);
	return attWindow
end


function getAlertDefs()
    local  discLimit, attLimit = unpack(self.getScoreLimits())
    local attAlertBody = "Attribute limit: ".. attLimit .. ". Max of 1 allowed."
    local discAlertBody = "Discipline limit: ".. discLimit .. ". Max of 1 allowed."
    local attOkBody = "Attributes within limits (max 1 at ".. attLimit..")."
    local discOkBody = "Disciplines within limits (max 1 at ".. discLimit..")."
    local alertDefs ={
		{LifePathAlertHelper.scoreLimitCount, {"attribute", attLimit, 7, 1}, attAlertBody, attOkBody},
		{LifePathAlertHelper.scoreLimitCount, {"discipline", discLimit, 7, 1}, discAlertBody, discOkBody},
        {LifePathAlertHelper.scoreSumExact, {"attribute", 56, 7}, "Attributes must add to 56", "Attributes add to 56"},
        {LifePathAlertHelper.scoreSumExact, {"discipline", 16, 7}, "Disciplines must add to 16", "Disciplines add to 16"},
		{LifePathAlertHelper.alertVFTFrame, {self.lifepath_finishing_touches_select_frame, "value"}, "Create 1 Value", "Value Created"},
		{LifePathAlertHelper.alertSummaryCount, {"values", 4}, "Must have 4 Values", "4 Values defined"},
		{LifePathAlertHelper.alertSummaryCount, {"talents", 4}, "Must have 4 Talents", "4 Talents defined"},
		{LifePathAlertHelper.alertSummaryCount, {"focuses", 6}, "Must have 6 Focuses", "6 Focuses selected"}

    }
    return alertDefs
end


function getScoreLimits()
    if ScopeManager.getSummaryVal("career") == "Young Officer" then
        return {4, 11}
    else
        return {5, 12}
    end

end