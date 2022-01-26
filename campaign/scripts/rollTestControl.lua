function createRoll(assist)
    return RollManager.buildSkillRoll(window, self.getDice(assist))
end

function getDice(assist)
    if assist then return {"d20"} end
    return {"d20", "d20"}
end

function determinationUsed()
    local charWindow = ScopeManager.getCharacterWindow(window.getDatabaseNode().getNodeName())
    return RollManager.determinationUsed(charWindow)
end

function onDoubleClick()
    local rRoll = self.createRoll(Input.isControlPressed())
    if not(RollManager.checkRoll(rRoll)) then return false end
    local throw = ActionsManager.buildThrow(window.getDatabaseNode().getNodeName(), nil, rRoll, nil)
    Comm.throwDice(throw)
end

function onDragStart(button, x, y, draginfo)
    local rRoll = self.createRoll(Input.isControlPressed() or (button == 2))
    return RollManager.buildScoreDrag(draginfo, rRoll)
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
    return RollManager.getScoreMod(window)
end