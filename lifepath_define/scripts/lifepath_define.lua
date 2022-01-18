LIFEPATH_STEPS = {
    ["Species"] = {
            ["attributes"] = 3
        },
    ["Environment"] = {
            ["attributes"] = 1,
            ["disciplines"] = 1
        },
    ["Upbringing"] = {
            ["disciplines"] = 3,
            ["accept"] = 1,
            ["rebel"] = 1
        },
    ["Starfleet Academy"] = {
            ["majors"] = 2
        },
    ["Career Experience"] = {},
    ["Lifepath 6-Career Events"] = {
            ["attributes"] = 1,
            ["disciplines"] = 1
        },
}
STEP_NAMES = {
    "Lifepath 1-Species",
    "Lifepath 2-Environment",
    "Lifepath 3-Upbringing",
    "Lifepath 4-Starfleet Academy",
    "Lifepath 5-Career Experience",
    "Lifepath 6-Career Events"
}
TAB_MAP = {
    "subwindow_def_species",
    "subwindow_def_environment",
    "subwindow_def_upbringing",
    "subwindow_def_academy",
    "subwindow_def_career",
    "subwindow_def_career_events"
}

DB_ROOT = '.lp_tables'
TABLE_CATEGORY = "User-Created Lifepath Generation Tables"


function onInit()
    self.saving = false
    self.table_nodes = {}
    self.rowNodes = {}
    self.createTableStructure()
    self.setDataSources()
    self.populateTableDisplay(1)
end

function setDataSources()
    self.subwindow_def_species.setValue("lifepath_define_species", self.getDatabaseNode().createChild("species"))
    self.subwindow_def_environment.setValue("lifepath_define_environment", self.getDatabaseNode().createChild("environment"))
    self.subwindow_def_upbringing.setValue("lifepath_define_upbringing", self.getDatabaseNode().createChild("upbringing"))
    self.subwindow_def_academy.setValue("lifepath_define_academy", self.getDatabaseNode().createChild("academy"))
    self.subwindow_def_career.setValue("lifepath_define_career", self.getDatabaseNode().createChild("career"))
    self.subwindow_def_career_events.setValue("lifepath_define_career_events", self.getDatabaseNode().createChild("career_events"))
end

function calcColumnWidths(columns)
	local w,h = self.subwindow_table_display.subwindow.tableheaders.getSize();
	return math.floor(((w - 5) / columns) + 0.5);
end

function populateTableDisplay(stepNum)
    local stepNode = self.table_nodes[stepNum]
    self.subwindow_table_display.setValue("lifepath_table_define_display", stepNode)
    self.subwindow_table_display.subwindow.tableheaders.closeAll()
    local columns = tonumber(DB.getValue(stepNode, "resultscols", 1))
    for i=1,columns do
        local colKey = "labelcol"..i
        local colString = DB.getValue(stepNode, colKey, "")
        local w = self.subwindow_table_display.subwindow.tableheaders.createWindow()
        w.name.setValue(colString)
    end
    self.subwindow_table_display.subwindow.tableheaders.setColumnWidth(calcColumnWidths(columns))
end

function createTableStructure()
    local tablesNode = self.getDatabaseNode().createChild("tables")
    for i = 1,6 do
        local stepNode = DB.createChild(tablesNode)
        STEP_STRUCTURES[i](stepNode)
        self.table_nodes[i] = stepNode
    end
end

function createSpeciesTableStructure(stepNode)
    DB.setValue(stepNode, "resultscols", "number", 2)
    DB.setValue(stepNode, "labelcol1", "string", "Species")
    DB.setValue(stepNode, "labelcol2", "string", "Attributes")
    DB.setValue(stepNode, "locked", "number", 1)
    DB.setValue(stepNode, "name", "string", "Step 1 - Species")
    DB.createChild(stepNode, "tablerows")
end

function createEnvironmentTableStructure(stepNode)
    DB.setValue(stepNode, "resultscols", "number", 3)
    DB.setValue(stepNode, "labelcol1", "string", "Environment")
    DB.setValue(stepNode, "labelcol2", "string", "Attributes")
    DB.setValue(stepNode, "labelcol3", "string", "Disciplines")
    DB.setValue(stepNode, "locked", "number", 1)
    DB.setValue(stepNode, "name", "string", "Step 2 - Environment")
    DB.createChild(stepNode, "tablerows")
end

function createUpbringingTableStructure(stepNode)
    DB.setValue(stepNode, "resultscols", "number", 4)
    DB.setValue(stepNode, "labelcol1", "string", "Upbringing")
    DB.setValue(stepNode, "labelcol2", "string", "Accept")
    DB.setValue(stepNode, "labelcol3", "string", "Rebel")
    DB.setValue(stepNode, "labelcol4", "string", "Disciplines")
    DB.setValue(stepNode, "locked", "number", 1)
    DB.setValue(stepNode, "name", "string", "Step 3 - Upbringing")
    DB.createChild(stepNode, "tablerows")
end

function createAcademyTableStructure(stepNode)
    DB.setValue(stepNode, "resultscols", "number", 2)
    DB.setValue(stepNode, "labelcol1", "string", "Academy Track")
    DB.setValue(stepNode, "labelcol2", "string", "Majors")
    DB.setValue(stepNode, "locked", "number", 1)
    DB.setValue(stepNode, "name", "string", "Step 4 - Academy")
    DB.createChild(stepNode, "tablerows")
end

function createCareerTableStructure(stepNode)
    DB.setValue(stepNode, "resultscols", "number", 3)
    DB.setValue(stepNode, "labelcol1", "string", "Career")
    DB.setValue(stepNode, "labelcol2", "string", "Talent")
    DB.setValue(stepNode, "labelcol3", "string", "Base Age")
    DB.setValue(stepNode, "locked", "number", 1)
    DB.setValue(stepNode, "name", "string", "Step 5 - Career")
    DB.createChild(stepNode, "tablerows")
end

function createCareerEventsTableStructure(stepNode)
    DB.setValue(stepNode, "resultscols", "number", 3)
    DB.setValue(stepNode, "labelcol1", "string", "Career Event")
    DB.setValue(stepNode, "labelcol2", "string", "Attribute")
    DB.setValue(stepNode, "labelcol3", "string", "Discipline")
    DB.setValue(stepNode, "locked", "number", 1)
    DB.setValue(stepNode, "name", "string", "Step 6 - Career Event")
    DB.createChild(stepNode, "tablerows")
end

STEP_STRUCTURES = {
    createSpeciesTableStructure,
    createEnvironmentTableStructure,
    createUpbringingTableStructure,
    createAcademyTableStructure,
    createCareerTableStructure,
    createCareerEventsTableStructure
}

function getTabWindow(tabNum)
	return self[TAB_MAP[tabNum]].subwindow
end

function deselectButtons()
    self.lifepath_speciestab.setBackColor(LifePathAlertHelper.COLOR_DESELECT)
    self.lifepath_environmenttab.setBackColor(LifePathAlertHelper.COLOR_DESELECT)
    self.lifepath_upbringingtab.setBackColor(LifePathAlertHelper.COLOR_DESELECT)
    self.lifepath_academytab.setBackColor(LifePathAlertHelper.COLOR_DESELECT)
    self.lifepath_careertab.setBackColor(LifePathAlertHelper.COLOR_DESELECT)
    self.lifepath_career_eventstab.setBackColor(LifePathAlertHelper.COLOR_DESELECT)
end

function setSelectorState(scoreSelector, selectedScores)

end

function addRow(sourceWindow, resultColumns)
    local stepNum = sourceWindow.step_num.getValue()
    local sourceNode = sourceWindow.getDatabaseNode()
    local stepNode = self.table_nodes[stepNum]
    local tableRows = DB.getChild(stepNode, "tablerows")
    local rowNode = DB.createChild(tableRows)
    DB.copyNode(sourceNode, rowNode)
    self.rowNodes[rowNode] = sourceWindow
end

function loadRow(rowNode)
    local sourceWindow = self.rowNodes[rowNode]
    local sourceNode = sourceWindow.getDatabaseNode()
    DB.copyNode(rowNode, sourceNode)
    sourceWindow.onRowLoad()
    self.rowNodes[rowNode] = nil
    DB.deleteNode(rowNode)
end

function onClose()
    if not self.saving then
        DB.deleteNode(self.getDatabaseNode())
    end
end