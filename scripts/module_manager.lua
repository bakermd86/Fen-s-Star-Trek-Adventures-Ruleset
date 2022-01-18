MODULE_MAIN = "Fen's Extra Star Trek Adventures Stuff"
MODULE_EXTRA = "Fen's Completely Random Alien Tables"

function checkModules()
	local loaded = true
	if needLoadMain() then
		loaded = false
		Module.activate(MODULE_MAIN)
	end
	if needLoadExtra() then
		Module.activate(MODULE_EXTRA)
	end
	return loaded
end

function needLoadMain()
	return modAvailable(MODULE_MAIN) and not(modLoaded(MODULE_MAIN))
end

function needLoadExtra()
	return modAvailable(MODULE_EXTRA) and not(modLoaded(MODULE_EXTRA))
end

-- function setModuleVisibility(control)
-- 	if not mainLoadAvailable() then
-- 		control.setEnabled(false)
-- 		control.setVisible(false)
-- 	end
-- end

-- function mainLoadAvailable()
-- 	return modAvailable(MODULE_MAIN)
-- end

-- function extraLoadAvailable()
-- 	return modAvailable(MODULE_EXTRA)
-- end

function modLoaded(module)
    return modAvailable(module) and Module.getModuleInfo(module).loaded
end

function modAvailable(module)
    return not(Module.getModuleInfo(module) == nil)
end

function getPathMain(path)
	if modAvailable(MODULE_MAIN) and modLoaded(MODULE_MAIN) then
		return path .. "@" .. MODULE_MAIN
	else
		return path
	end
end

function getPathExtra(path)
	if modAvailable(MODULE_EXTRA) and modLoaded(MODULE_EXTRA) then
		return path .. "@" .. MODULE_EXTRA
	else
		return path
	end
end