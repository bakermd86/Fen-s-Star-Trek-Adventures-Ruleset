LIFEPATH_ADD_WEAPON_REQUEST = "lifepath_add_weapon_request"
LIFEPATH_ADD_CHILD_LINK_REQUEST = "lifepath_add_child_link_request"
LIFEPATH_SET_CHILD_REQUEST = "lifepath_set_child_request"
RANK_MAP = {
	["Young Officer"]="Lt. Jg.",
	["Experienced Officer"]="Lt.",
	["Veteran Officer"]="Lt. Cmdr"
}

function onInit()
	if User.isHost() or User.isLocal() then
		OOBManager.registerOOBMsgHandler(LIFEPATH_SET_CHILD_REQUEST, requestSetChild)
		OOBManager.registerOOBMsgHandler(LIFEPATH_ADD_CHILD_LINK_REQUEST, handleAddChildLinkRequest)
		OOBManager.registerOOBMsgHandler(LIFEPATH_ADD_WEAPON_REQUEST, handleAddWeaponRequest)
	end
end


function handleAddWeaponRequest(oobMsg)
	addWeapon(oobMsg.node, oobMsg.damage, oobMsg.name, oobMsg.qualities, oobMsg.cost, oobMsg.size, oobMsg.range)
end


function addWeapon(node, damage, name, qualities, cost, size, range)
	if User.isHost() or User.isLocal() then
		local linkEntry = DB.findNode(node).createChild("weapons").createChild()
		linkEntry.createChild("name", "string").setValue(name)
		linkEntry.createChild("qualities", "string").setValue(qualities)
		linkEntry.createChild("damage", "dice").setValue(damage)
		linkEntry.createChild("cost", "string").setValue(cost)
		linkEntry.createChild("size", "string").setValue(size)
		linkEntry.createChild("range", "number").setValue(range)
	else
		local oobMsg = {
			["type"]=LIFEPATH_ADD_WEAPON_REQUEST,
			["node"]=node,
			["damage"]=damage,
			["name"]=name,
			["qualities"]=qualities,
			["cost"]=cost,
			["size"]=size,
			["range"]=range
		}
		Comm.deliverOOBMessage(oobMsg, "")
	end
end

function handleAddChildLinkRequest(oobMsg)
	addLinkToChild(oobMsg.node, oobMsg.childTag, oobMsg.label, oobMsg.class, oobMsg.recordName)
end

function addLinkToChild(node, childTag, label, class, recordName)
	if User.isHost() or User.isLocal() then
		local linkEntry = DB.findNode(node).createChild(childTag).createChild()
		linkEntry.createChild("label", "string").setValue(label)
		linkEntry.createChild("link", "windowreference").setValue(class, recordName)
	else
		local oobMsg = {
			["type"]=LIFEPATH_ADD_CHILD_LINK_REQUEST,
			["node"]=node,
			["childTag"]=childTag,
			["label"]=label,
			["class"]=class,
			["recordName"]=recordName
		}
		Comm.deliverOOBMessage(oobMsg, "")
	end
end

function requestSetChild(oobMsg)
	if User.isHost() or User.isLocal() then
		setChild(oobMsg.node, oobMsg.childTag, oobMsg.childType, oobMsg.childValue)
	end
end

function setChild(node, childTag, childType, childValue)
	if User.isHost() or User.isLocal() then
		DB.findNode(node).createChild(childTag, childType).setValue(childValue)
	else
		local oobMsg = {
			["type"]=LIFEPATH_SET_CHILD_REQUEST,
			["node"]=node,
			["childTag"]=childTag,
			["childType"]=childType,
			["childValue"]=childValue
		}
		Comm.deliverOOBMessage(oobMsg, "")
	end
end

function handleNodeCharRequest(oobMsg)
	if User.isHost() or User.isLocal() then
		local nodeChar = DB.createChild("charsheet")
		DB.setOwner(nodeChar, oobMsg.user)
		Comm.deliverOOBMessage({["type"]=oobMsg.callback, ["nodeChar"]=nodeChar.getNodeName()}, oobMsg.user)
	end
end

function handleNodeCharCallback(oobMsg)	saveCharacter(oobMsg.nodeChar) end

function handleSaveCallback(result)	if result == "yes" then requestSave() end end

function handleIdentity(result, identity) saveCharacter("charsheet."..identity) end

function requestSave()
	if User.isHost() or User.isLocal() then
		local nodeChar = DB.createChild("charsheet")
		saveCharacter(nodeChar.getNodeName())
	else
		User.requestIdentity(nil, "charsheet", "name", nil, handleIdentity)
	end
end

function checkSaveReady()
	local errorCount, error_str, fatal = unpack(LifePathAlertHelper.getErrors())
	if fatal then
		local fatal_msg = "Unable to save character until all steps have at least been rolled.\n" .. error_str
		Interface.dialogMessage(nil, fatal_msg, "Unable to proceed", "okcancel")
		return
	end
	if errorCount > 8 then
		error_str = error_str .. "+ "..(errorCount-8).." other errors\n"
	end
	if errorCount == 0 then
		requestSave()
	else
		error_str = error_str .. "Are you sure you want to proceed?"
		Interface.dialogMessage(handleSaveCallback, error_str, "Wizard not complete", "yesno")
	end
end

function saveRefText(nodeName, source, target)
	local name = source.name.getValue()
	local text = source.text.getValue()
	local node = DB.findNode(nodeName).createChild(target).createChild()
	DB.setValue(node, "name", "string", name)
	if text then DB.setValue(node, "text", "formattedtext", text) end
end

function addShipRecord(nodeName)
	if DB.getValue("crew_support.crew_vessel") then
		local node = DB.findNode(nodeName)
		node.createChild("ship_link", "windowreference").setValue("ship", DB.getValue("crew_support.crew_vessel"))
		local shipNode = DB.findNode(DB.getValue("crew_support.crew_vessel"))
		DB.setValue(node, "ship", "string", DB.getValue(shipNode, "name"))
	end
end

function saveCharacter(nodeName)
	local window = ScopeManager.getLifepathWindow()
	window.saving = true
	DB.copyNode(ScopeManager.getLpNode(), nodeName)
	if not(window.unpredictableTemperamentAttribute == "") then
		setChild(nodeName, "formattedtext", "string", "<p><b>Unpredictable Temperament: "
				..window.unpredictableTemperamentAttribute ..
		".</b> Reroll on Unpredicable Temperament table for each episode and update.</p>")
	end
	local maxStress = tonumber(ScopeManager.getSummaryVal("security")) + tonumber(ScopeManager.getSummaryVal("fitness"))
	setChild(nodeName, "maxstress", "number", maxStress)
	addShipRecord(nodeName)
	local bonusDamage = tonumber(ScopeManager.getSummaryVal("security"))
	addWeapon(nodeName, (3+bonusDamage).."d6", "Phaser Type-2", "Charge", "Standard Issue", "1H", 1)
	addWeapon(nodeName, (2+bonusDamage).."d6", "Phaser Type-1", "Charge, Hidden 1", "Standard Issue", "1H", 1)
	window.close()
	Interface.openWindow("charsheet", nodeName)
	DB.deleteNode(ScopeManager.getLpNode())
end
