function onInit()
    self.header.subwindow.setName("Environment Name")
    self.usedVals = {}
    self.att_mode_controls = nil
    self.disc_mode_controls = {
        self.upbringing_discipline_mode_select_from,
        self.upbringing_discipline_mode_fixed,
        self.upbringing_discipline_mode_any
    }
    self.select_controls = {
        self.accept_define_subwindow1,
        self.accept_define_subwindow2,
        self.reject_define_subwindow1,
        self.reject_define_subwindow2,
        self.discipline_define_subwindow
    }
    self.discModeMap = {
        ["Any"] = self.upbringing_discipline_mode_any,
        [1] = self.upbringing_discipline_mode_fixed,
        [6] = self.upbringing_discipline_mode_select_from
    }
    self.overrideResultFuncs()
end

function overrideResultFuncs()
    for i=1,4 do
        self.select_controls[i].subwindow.define_score_select.updateResultVal = self.updateResultVal
    end
end

function lockEnabledScore(control, score)
    for _, w in ipairs(control.subwindow.define_score_select.getWindows()) do
        if score == w.lifepath_attribute_select_control.attName then
            w.lifepath_attribute_select_control.toggleOn()
        end
    end
end

function onRowLoad()
    for _, control in ipairs(self.select_controls) do
        LifePathDefineHelper.clearSelectControl(control.subwindow.define_score_select)
    end
    LifePathDefineHelper.loadResult(self.discipline_define_subwindow, self.discModeMap, 4)
    local acceptStr = LifePathDefineHelper.getResName(getDatabaseNode(), 2)
    local accept1, accept2 = unpack(ScopeManager.splitColumn(string.lower(acceptStr)))
    local rejectStr = LifePathDefineHelper.getResName(getDatabaseNode(), 3)
    local reject1, reject2 = unpack(ScopeManager.splitColumn(string.lower(rejectStr)))

    self.lockEnabledScore(self.accept_define_subwindow1, accept1)
    self.lockEnabledScore(self.accept_define_subwindow2, accept2)
    self.lockEnabledScore(self.reject_define_subwindow1, reject1)
    self.lockEnabledScore(self.reject_define_subwindow2, reject2)
    LifePathDefineHelper.updateUsedVals(self, -1)
end

function getOutVal(control1, control2)
    local outVal = ""
    for score, _ in pairs(control1.subwindow.define_score_select._selectedScores) do
        outVal = string.upper(string.sub(score, 1, 1)) .. string.sub(score, 2)
    end
    if outVal == "" then return "" end
    for score, _ in pairs(control2.subwindow.define_score_select._selectedScores) do
        outVal = outVal .. ', ' .. string.upper(string.sub(score, 1, 1)) .. string.sub(score, 2)
        return outVal
    end
    return ""
end

function updateResultVal()
    local outValNodeAccept = self.accept_define_subwindow1.subwindow.define_score_select.getDBNode()
    local outValAccept = self.getOutVal(self.accept_define_subwindow1, self.accept_define_subwindow2)
    DB.setValue(outValNodeAccept, "result", "string", outValAccept)

    local outValNodeReject = self.reject_define_subwindow1.subwindow.define_score_select.getDBNode()
    local outValReject = self.getOutVal(self.reject_define_subwindow1, self.reject_define_subwindow2)
    DB.setValue(outValNodeReject, "result", "string", outValReject)
end

function resetAcceptSelect(window, count, resNode)
    self.accept_define_subwindow1.subwindow.score_selection_count.setValue(count)
    self.accept_define_subwindow2.subwindow.score_selection_count.setValue(count)
    self.reject_define_subwindow1.subwindow.score_selection_count.setValue(count)
    self.reject_define_subwindow2.subwindow.score_selection_count.setValue(count)
end
