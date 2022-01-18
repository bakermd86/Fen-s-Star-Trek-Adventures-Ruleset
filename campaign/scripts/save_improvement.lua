function onInit()
    self.oldDisplayVal = ""
    self.newDisplayVal = ""
    self.root = nil
    self.pendingRefItem = nil
end


function onButtonPress()
    local option = window.lookupTable[window.type_select.getValue()]
    for _, w in ipairs(window.type_options.getWindows()) do
        if handleSave(w, option) then
            moveToServiceHistory(option.target, option.type)
        end
    end
end

DISPLAY_FORMAT_PREFIX_MAP = {
    ["give_support"] = "Used on supporting character",
    ["save"] = "Saved for later"
}

DISPLAY_FORMAT_TARGET_MAP = {
    ["ship_talent"] = "Ship Talent",
    ["talent"] = "Talent",
    ["focus"] = "Focus",
    ["value"] = "Value",
}

function formatDisplay(target, type)
    local display = ""
    if (target == "attribute") or (target == "discipline") or
            (target == "system") or (target == "department") then
        display = "+1 "..self.newDisplayVal .."."
        if (type == "swap") then
            display = display.." -1 "..self.oldDisplayVal.."."
        end
        if (target == "system") or (target == "department") then
            display = display.." (Ship)"
        end
    elseif target and DISPLAY_FORMAT_TARGET_MAP[target] then
        display = "+ " .. DISPLAY_FORMAT_TARGET_MAP[target] .. ": "..self.newDisplayVal.."."
        if (type == "swap") then
            display = display .. " Removed: "..self.oldDisplayVal
        end
    elseif DISPLAY_FORMAT_PREFIX_MAP[type] then
        display = DISPLAY_FORMAT_PREFIX_MAP[type]
    else
        Debug.chat("Whoops. Unhandled target type: " .. target)
    end
    return display
end

function handleServiceHistoryResponse(oobMsg)
    copyServiceHistory(DB.findNode(oobMsg.node), oobMsg.display)
end

function copyServiceHistory(historyNode, display)
    local selfNode = window.getDatabaseNode()
    DB.copyNode(selfNode, historyNode)
    DB.setValue(historyNode, "used_on", "string", display)
    requestNodeDelete(selfNode)
    window.close()
end

function moveToServiceHistory(target, type)
    if DB.isOwner(window.getRootNode(), User.getUsername()) then
        local historyNode = DB.createChild(window.getRootNode(), "service_history").createChild()
        copyServiceHistory(historyNode, formatDisplay(target, type))
    else
        local oobMsg = {
            ["type"]=MilestoneCommHelper.NODE_ADD_CHILD_REQ,
            ["user"]=User.getUsername(),
            ["node"]=window.getRootNode().getNodeName(),
            ["parent"]="service_history",
            ["display"]=formatDisplay(target, type),
            ["callback"]="service_history_node_resp"..User.getUsername()
        }
        OOBManager.registerOOBMsgHandler(oobMsg.callback, self.handleServiceHistoryResponse)
        Comm.deliverOOBMessage(oobMsg, "")
    end
end

LINK_LIST_MAP = {
    ["talent"]="talents",
    ["value"]="values",
    ["focus"]="focuses",
    ["ship_talent"]="talents"
}


function refListRoot(option)
    return DB.createChild(self.root, LINK_LIST_MAP[option.target])
end

function updateRefLink(newNode, ref)
    DB.setValue(newNode, "label", "string", ref.label.getValue())
    DB.setValue(newNode, "link", "windowreference", ref.link.getValue())
    self.newDisplayVal = ref.label.getValue()
end

function updateRefText(newNode, target, ref)
    DB.setValue(newNode, "name", "string", ref.name.getValue())
    self.newDisplayVal = ref.name.getValue()
    if target == "value" then
        DB.setValue(newNode, "text", "formattedtext", ref.text.getValue())
    end
end

function handleRefLinkResponse(oobMsg)
    local node = DB.findNode(oobMsg.node)
    if (LINK_LIST_MAP[oobMsg.target] == "talents") and self.pendingRefItem then
        updateRefLink(node, self.pendingRefItem)
    elseif self.pendingRefItem then
        updateRefText(node, oobMsg.target, self.pendingRefItem)
    end
    moveToServiceHistory(oobMsg.target, oobMsg.option_type)
end

function saveRefLink(ref, option)
    if DB.isOwner(self.root) then
        local newNode = refListRoot(option).createChild()
        if LINK_LIST_MAP[option.target] == "talents" then
            updateRefLink(newNode, ref)
        else
            updateRefText(newNode, option.target, ref)
        end
        return true
    else
        self.pendingRefItem = ref
        local oobMsg = {
            ["type"]=MilestoneCommHelper.NODE_ADD_CHILD_REQ,
            ["user"]=User.getUsername(),
            ["node"]=self.root.getNodeName(),
            ["parent"]=LINK_LIST_MAP[option.target],
            ["target"]=option.target,
            ["option_type"]=option.type,
            ["callback"]="ref_link_response"..User.getUsername()
        }
        OOBManager.registerOOBMsgHandler(oobMsg.callback, self.handleRefLinkResponse)
        Comm.deliverOOBMessage(oobMsg, "")
        return false
    end
end

function requestNodeDelete(node)
    if DB.isOwner(node) then
        DB.deleteNode(node)
    else
        local oobMsg = {
            ["type"]=MilestoneCommHelper.NODE_DELETE_REQ,
            ["node"]=node.getNodeName(),
        }
        Comm.deliverOOBMessage(oobMsg, "")
    end
end

function removeRefLink(name, option)
    self.oldDisplayVal = name
    local listNode = refListRoot(option)
    for _, node in pairs(DB.getChildren(listNode)) do
        if (DB.getValue(node, "name", "") == name) or (DB.getValue(node, "label", "") == name) then
            requestNodeDelete(node)
        end
    end
end

function doRefLinkType(w, option)
    local swap = (option.type == "swap")
    if not (w.list_selectors.getWindowCount() >= 1) then
        Interface.dialogMessage(nil, "No list selection widget found, not sure how we got here... Just close this window and try again.",
                            "Milestone Error", nil)
        return false
    end
    local improve_select = w.list_selectors.getWindows()[1]
    local newVal, oldVal
    newVal = improve_select.target.getWindows()[1]
    if swap then
        oldVal = improve_select.remove_select.getValue()
    else
        oldVal = true
    end
    if assertLimit(option) then return false end
    if assertVals(oldVal, ((newVal) and not ((newVal.label.getValue() == "") and (newVal.name.getValue() == "")))) then return false end
    if swap then
        removeRefLink(oldVal, option)
    end
    window.checkLimit(option, true)
    return saveRefLink(newVal, option)
end

function getSelectedScore(score_list)
    for _, w in ipairs(score_list.getWindows()) do
        if w.score.getValue() == 1 then return w end
    end
end

function assertLimit(option)
    if not window.checkLimit(option, false) then
        Interface.dialogMessage(nil, "Improvement of type: \""..option.display.."\" may only be selected "..option.limit.." times. This limit has already been reached.",
                                "Milestone Error", nil)
        return true
    else
        return false
    end
end

SCORE_LIMIT_MAP = {
    ["swap"]= {
        ["attribute"]={7, 11},
        ["discipline"]={1, 4},
        ["system"]={6, 12},
        ["department"]={1, 4},
    },
    ["gain"]={
        ["attribute"]= { 0, 12 },
        ["discipline"]= { 0, 5 },
        ["system"]= { 0, 12 },
        ["department"]= { 0, 5 },
    }
}

function assertScoreLimit(scoreWidget, option)
    local scoreNode = DB.getChild(self.root, scoreWidget.scoreName.getValue())
    local currentScore = scoreNode.getValue()
    local modifier = scoreWidget.scoreVal.getValue()
    local lower, upper = unpack(SCORE_LIMIT_MAP[option.type][option.target])
    local newScore = currentScore + modifier
    if( newScore > upper ) or (newScore < lower) then
        Interface.dialogMessage(nil, "New score in ".. scoreWidget.scoreName.getValue() .. " would exceed the minimum/maximum limits of: " ..lower.." and "..upper..".",
                                "Milestone Error", nil)
        return true
    end
    return false
end

function saveScore(scoreWidget)
    local scoreNode = DB.getChild(self.root, scoreWidget.scoreName.getValue())
    local currentScore = scoreNode.getValue()
    local modifier = scoreWidget.scoreVal.getValue()
    if modifier == 1 then
        self.newDisplayVal = scoreWidget.scoreName.getValue()
    elseif modifier == -1 then
        self.oldDisplayVal = scoreWidget.scoreName.getValue()
    end
    if DB.isOwner(scoreNode, User.getUsername()) then
        DB.setValue(scoreNode, "", "number", currentScore + modifier)
    else
        local oobMsg = {
            ["type"]=MilestoneCommHelper.NODE_CHANGE_VALUE_REQ,
            ["node"]=scoreNode.getNodeName(),
            ["value"]=currentScore + modifier,
            ["node_type"]="number"
        }
        Comm.deliverOOBMessage(oobMsg, "")
    end
    return true
end

function doScoreType(w, option)
    local swap = (option.type == "swap")
    if not ((w.increases.getWindowCount() >= 1) and ((not (swap) or (w.decreases.getWindowCount() >= 1))))then
        Interface.dialogMessage(nil, "No score selection widgets found, not sure how we got here... Just close this window and try again.",
                            "Milestone Error", nil)
        return
    end
    local oldVal
    if swap then
        oldVal = getSelectedScore(w.decreases)
    else
        oldVal = true
    end
    local newVal = getSelectedScore(w.increases)
    if assertVals(oldVal, newVal) then return false end
    if assertLimit(option) then return false end
    if (swap and assertScoreLimit(oldVal, option)) or assertScoreLimit(newVal, option) then return false end
    if swap then
        saveScore(oldVal)
    end
    window.checkLimit(option, true)
    return saveScore(newVal) 
end

function assertVals(oldVal, newVal)
    if not oldVal or oldVal == "" then
        Interface.dialogMessage(nil, "Selection incomplete, make sure to select the old option to remove/decrease",
                            "Milestone Error", nil)
        return true
    end
    if not newVal or newVal == "" then
        Interface.dialogMessage(nil, "Selection incomplete, make sure to select/enter the new improvement.",
                            "Milestone Error", nil)
        return true
    end
    return false
end

function doSaveMilestone()
    DB.setValue(window.getDatabaseNode(), "type", "number", 6)
    window.close()
    return false
end

function handleGiveSupportResponse(oobMsg)
    DB.copyNode(window.getDatabaseNode(), oobMsg.node)
    moveToServiceHistory(oobMsg.target, oobMsg.option_type)
end

function doGiveSupport(w, option)
    local crewName = w.supporting_characters.getValue()
    if crewName == "" then
        Interface.dialogMessage(nil, "Must select crewmember to be given Milestone.", "Milestone Error", nil)
        return false
    end
    local crewMember = CrewSupportManager.getSupportingCharacterByName(crewName)
    if DB.isOwner(crewMember, User.getUsername()) then
        local newMilestone = DB.createChild(crewMember, "saved_milestones").createChild()
        DB.copyNode(window.getDatabaseNode(), newMilestone)
        return true
    else
        local oobMsg = {
            ["type"]=MilestoneCommHelper.NODE_ADD_CHILD_REQ,
            ["node"]=crewMember.getNodeName(),
            ["callback"]="give_support_response"..User.getUsername(),
            ["parent"]="saved_milestones",
            ["target"]=option.target,
            ["option_type"]=option.type,
            ["user"]=User.getUsername()
        }
        OOBManager.registerOOBMsgHandler(oobMsg.callback, self.handleGiveSupportResponse)
        Comm.deliverOOBMessage(oobMsg, "")
        return false
    end
end

function doOtherType(w, option)
    if option.type == "save" then
        return doSaveMilestone()
    elseif option.type == "give_support" then
        return doGiveSupport(w, option)
    end
    return false
end

TARGET_MAP = {
    ["value"]=doRefLinkType,
    ["focus"]=doRefLinkType,
    ["talent"]=doRefLinkType,
    ["ship_talent"]=doRefLinkType,
    ["attribute"]=doScoreType,
    ["discipline"]=doScoreType,
    ["system"]=doScoreType,
    ["department"]=doScoreType
}

function handleSave(w, option)
    if (option.target == "ship_talent") or (option.target == "system") or (option.target == "department") then
        self.root = DB.findNode(DB.getValue("crew_support.crew_vessel"))
    else
        self.root = window.getRootNode()
    end
    if TARGET_MAP[option.target] then
        return TARGET_MAP[option.target](w, option)
    else
        return doOtherType(w, option)
    end
end

