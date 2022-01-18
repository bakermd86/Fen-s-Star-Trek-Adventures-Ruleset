
function onInit()
    self.root = ScopeManager.getNodeAtDepth(window.windowlist.window.getDatabaseNode().getNodeName(), 1)
end

function setType(type)
    if type == "ship_talent" then
        self.root = DB.findNode(DB.getValue("crew_support.crew_vessel"))
        window.remove_select.setTalents(getTalents())
    elseif type == "talent" then
        window.remove_select.setTalents(getTalents())
    elseif type == "focus" then
        window.remove_select.addItems(getTypeNames("focuses"))
    elseif type == "value" then
        window.remove_select.addItems(getTypeNames("values"))
    end
    self.initControl(type, window.target, 0);
end

function getScores()
    local scores = {}
    for _, score in ipairs(ScopeManager.ALL_ATTRIBUTES) do
        scores[string.lower(score)] = DB.getValue(self.root, string.lower(score), 7)
    end
    for _, score in ipairs(ScopeManager.ALL_DISCIPLINES) do
        scores[string.lower(score)] = DB.getValue(self.root, string.lower(score), 1)
    end
    return scores
end

function getTarget()
    return window.target
end

function getTypeNames(type)
    local names = {}
    for _, node in pairs(DB.getChildren(root, type)) do
        table.insert(names, DB.getValue(node, "name", ""))
    end
    return names
end

function getTalents()
    local talentTable = {}
    for _, talent in pairs(DB.getChildren(root, "talents")) do
        local tStruct = {["label"]=talent.getChild("label")}
        table.insert(talentTable, tStruct)
    end
    return talentTable
end

function getSpecies()
    return DB.getValue(root, "species")
end
function cleanUp()
    window.target.closeAll()
end