ALL_ATTRIBUTES = {
	"Control",
	"Daring",
	"Fitness",
	"Insight",
	"Presence",
	"Reason"
};

ALL_DISCIPLINES = {
	"Command",
	"Conn",
	"Engineering",
	"Security",
	"Science",
	"Medicine"
};

ALL_SYSTEMS = {
    "Engines",
    "Computers",
    "Weapons",
    "Structure",
    "Sensors",
    "Communications"
};

function onInit()
	ActorManager.registerActorRecordType("ships");
	ActorManager.registerActorRecordType("crewmates");
end

function openLPDefine()
    local new_lp_table = DB.createChild(".lp_tables")
    Interface.openWindow("lifepath_table_definition_window", new_lp_table.getNodeName())
end

function getLifepathWindow()
    return Interface.findWindow("lifepath", getLpNode())
end

function getCharsheet(name)
    for _, node in pairs(DB.getChildren("charsheet")) do
        if DB.getValue(node, "name") == name then return node end
    end
end

function getNpc(name)
    for _, node in pairs(DB.getChildren("crewmate")) do
        if DB.getValue(node, "name") == name then return node end
    end
    for _, node in pairs(DB.getChildren("npc")) do
        if DB.getValue(node, "name") == name then return node end
    end
end

_matchVal = '([^, ]+)';
function splitColumn(text)
--     local text = resultCol['text']
    local valsOut = {}
    local i = 1
    for val in  string.gmatch(text, _matchVal) do
        valsOut[i] = val
        i = i + 1
    end
    return valsOut
end

function getNodeAtDepth(nodeName, depth)
    local module = DB.getModule(nodeName)
    local d = 0
    local rootNode = ""
    for elem in string.gmatch(nodeName, "([^.]+)[.]?") do
        if d == 0 then rootNode = elem
        elseif d <= depth then
            rootNode = rootNode .. "." .. elem
        end
        if d == depth then break end
        d = d + 1
    end
    if module then rootNode = rootNode .. "@" .. module end
    return DB.findNode(rootNode)
end

function getCharacterWindow(nodeName)
    return Interface.findWindow("charsheet", getNodeAtDepth(nodeName, 1))
end

function safeToCleanup()
    return not ((getLifepathWindow() == nil) or (getLifepathWindow().closing))
end

function updateAlerts()
    if getLifepathWindow() then getLifepathWindow().updateAlerts() end
end

function getSummary()
    if getLifepathWindow() then
        return getLifepathWindow().summary.subwindow
    end
end

function getLpNode()
    if User.isHost() then
        return "lp_wizard.GM"
    end
    return "lp_wizard."..User.getUsername()
end


function getSpeciesTab()
    return getLifepathWindow().gen_species.subwindow["contents"].subwindow
end

function getEnvironmentTab()
    return getLifepathWindow().genenvironment.subwindow["contents"].subwindow
end

function getUpbringingTab()
    return getLifepathWindow().genupbringing.subwindow["contents"].subwindow
end

function getAcademyTab()
    return getLifepathWindow().genacademy.subwindow["contents"].subwindow
end

function getCareerTab()
    return getLifepathWindow().gencareer.subwindow["contents"].subwindow
end

function getCareerEventsTab()
    return getLifepathWindow().genevents.subwindow["contents"].subwindow
end

function getFinishTab()
    return getLifepathWindow().genfinish.subwindow["contents"].subwindow
end

function getSummaryVal(valName) return DB.getValue(DB.findNode(getLpNode()), valName) end
function setSummaryVal(valName, value) return DB.findNode(getLpNode().."."..valName).setValue(value) end
function getSummaryList(listName)
    if getSummary() then
        return getSummary()[listName].getWindows()
    else
        return {}
    end
end
function getSummaryListSize(listName)
    if getSummary() then
        return getSummary()[listName].getWindowCount()
    else
        return 0
    end
end
