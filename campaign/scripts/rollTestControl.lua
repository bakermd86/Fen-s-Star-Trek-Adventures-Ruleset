
function createRoll(assist)
    local att, disc, dc, focus, desc, attName, discName = unpack(self.getScoreMod())
    local roll = {
        ["aDice"] =self.getDice(assist),
        ["sType"]="character_score",
        ["desc"]=desc,
        ["nMod"]=0,
        ["att"]=att,
        ["attName"]=attName,
        ["disc"]=disc,
        ["discName"]=discName,
        ["dc"]=dc,
        ["focus"]=nil,
        ['sUser']=User.getUsername(),
        ['determination']=self.determinationUsed()
    }
    if focus and not(focus.getValue() == "")then
        roll['focus'] = focus.getValue()
    end
    return roll
end

function getDice(assist)
    if assist then return {"d20"} end
    return {"d20", "d20"}
end

function determinationUsed()
    local charWindow = ScopeManager.getCharacterWindow(window.getDatabaseNode().getNodeName())
    if not charWindow then return nil end
    local detControl = charWindow.header.subwindow.determinationDieControl
    if detControl.getValue() == 1 then
        detControl.setValue(0)
        return "TRUE"
    end
    return nil
end

function onDoubleClick()
    local rRoll = createRoll(Input.isControlPressed())
    if not(checkRoll(rRoll)) then return false end
    local throw = ActionsManager.buildThrow(window.getDatabaseNode().getNodeName(), nil, rRoll, nil)
    Comm.throwDice(throw)
end

function checkRoll(rRoll)
    return (rRoll.att > 0) and (rRoll.disc > 0)
end

function onDragStart(button, x, y, draginfo)
    local rRoll = createRoll(Input.isControlPressed() or (button == 2))
    if not(checkRoll(rRoll)) then return false end
    draginfo.setType(rRoll["sType"])
    draginfo.setDieList(rRoll["aDice"])
    for k, v in pairs(rRoll) do
        draginfo.setMetaData(k, v)
    end
    local source_type = window.getDatabaseNode().getParent().getNodeName()
    if (source_type == "charsheet") then
        draginfo.addShortcut("charsheet", window.getDatabaseNode().getNodeName())
    end
    if (source_type == "crewmate") and (Extension.getExtensionInfo("Fen's NPC Portrait Workaround") ~= nil)then
        draginfo.setMetaData("crew_sender", DB.getValue(window.getDatabaseNode(), "name", "name"))
        draginfo.setMetaData("crew_token", NPCPortraitManager.formatDynamicPortraitName(window.getDatabaseNode()))
    end
    return true
end


function getScore(scoreName)
    local rootNode = ScopeManager.getNodeAtDepth(window.getDatabaseNode().getNodeName(), 1)
    return DB.getValue(rootNode, string.lower(scoreName))
end

function getWeaponType(weaponName, typeNode)
    local rootNode = ScopeManager.getNodeAtDepth(window.getDatabaseNode().getNodeName(), 1)
    local weaponType = 0
    for _, weapon in pairs(DB.getChildren(rootNode, typeNode)) do
        if DB.getValue(weapon, "name") == weaponName then
            weaponType = DB.getValue(weapon, "type", 0)
        end
    end
    return weaponType
end

function formatMod(att, attName, disc, discName, dc, focus)
    local desc = "[" .. attName.." ("..att..") + "..discName.." ("..disc.. ")]"
    if focus and not(focus.getValue() == "") then desc = desc .. "\n[Focus: " .. focus.getValue() .. " ]" end
    return { att, disc, dc, focus, desc, attName, discName }
end

function getAttackMod(attackType, weaponName, focus)
    local typeNode = "weapons"
    if window.attack_type.getValue() == 1 then type = "shipweapons" end
    local weaponType = getWeaponType(weaponName, typeNode)
    local attName, discName = "Control" , "Security"
    local dc = window.rollDC.getValue()
    if (attackType == 0) and (weaponType == 1) then  -- on-foot melee attack
        attName = "Daring"
    end
    local att = self.getScore(attName)
    local disc = self.getScore(discName)
    local desc = "Attack with " .. weaponName .. ": " .. attName .." ("..att..") + "..discName.." ("..disc.. ")"
    if not (focus.getValue() == "") then desc = desc .. ", Foc: " .. focus.getValue() end
    return { att, disc, dc, focus, desc, attName, discName}
end

function getScoreMod()
    local att, attName = window.activeAttribute.getValue(), window.activeAttributeName.getValue()
    local disc, discName = window.activeDiscipline.getValue(), window.activeDisciplineName.getValue()
    local dc = window.rollDC.getValue()
    local focus ;
    if window.focuses then
        focus = window.focuses.getSelected()
    end
    return formatMod(att, attName, disc, discName, dc, focus)
end