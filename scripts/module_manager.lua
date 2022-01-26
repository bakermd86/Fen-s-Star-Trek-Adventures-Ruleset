MODULE_EXTRA = "Fen's Completely Random Alien Tables"

function checkModules()
	local loaded = true
	if needLoadExtra() then
		Module.activate(MODULE_EXTRA)
	end
	return loaded
end

function needLoadExtra()
	return modAvailable(MODULE_EXTRA) and not(modLoaded(MODULE_EXTRA))
end
function modLoaded(module)
    return modAvailable(module) and Module.getModuleInfo(module).loaded
end

function modAvailable(module)
    return not(Module.getModuleInfo(module) == nil)
end

function getAllFromModules(path, refPath)
    local nodes = {}
    for name, node in pairs(DB.getChildren(path)) do
        table.insert(nodes, node)
    end
    for name, node in pairs(DB.getChildren(refPath)) do
        table.insert(nodes, node)
    end
    for _, module in ipairs(Module.getModules()) do
        for name, node in pairs(DB.getChildren(path .. "@" .. module)) do
            table.insert(nodes, node)
        end
        for name, node in pairs(DB.getChildren(refPath .. "@" .. module)) do
            table.insert(nodes, node)
        end
    end
    return nodes
end

function getPathExtra(path)
	if modAvailable(MODULE_EXTRA) and modLoaded(MODULE_EXTRA) then
		return path .. "@" .. MODULE_EXTRA
	else
		return path
	end
end