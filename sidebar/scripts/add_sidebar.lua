
new_aRecords = {
	["talents"] = {
		bExport = true,
		aDataMap = { "talent", "reference.talent"},
		sRecordDisplayClass = "sta_talent",
		sListDisplayClass = "masterindexitem",
		sSidebarCategory = "create"
	},
	["focuses"] = {
		bExport = true,
		aDataMap = { "focuses", "reference.focuses"},
		sRecordDisplayClass = "note",
		sListDisplayClass = "masterindexitem_note",
		sSidebarCategory = "create"
	},
	["values"] = {
		bExport = true,
		aDataMap = { "values", "reference.values"},
		sRecordDisplayClass = "note",
		sListDisplayClass = "masterindexitem_note",
		sSidebarCategory = "create"
	},
	["shiptalents"] = {
		bExport = true,
		aDataMap = { "shiptalent", "reference.shiptalent"},
		sRecordDisplayClass = "sta_talent",
		sListDisplayClass = "masterindexitem",
		sSidebarCategory = "create"
	},
	["ships"] ={
		bExport = true,
		aDataMap = { "ship", "reference.ships" },
		sRecordDisplayClass = "ship",
		sListDisplayClass = "masterindexitem",
	},
	["weapons"] ={
		bExport = true,
		aDataMap = { "weapon", "reference.weapons" },
		sRecordDisplayClass = "weapon",
		sListDisplayClass = "masterindexitem",
		sSidebarCategory = "create"
	},
};

function onInit()
    if Session.IsHost then
        new_aRecords["crewmates"] ={
            aCustom = {
                tWindowMenu = { ["left"] = { "chat_speak" } },
            },
            tOptions = {
                bExport = true,
                bID = true,
                bPicture = true,
                bToken = true,
                bCustomDie = true,
            },
            aDataMap = { "crewmate", "reference.crewmates" },
            sRecordDisplayClass = "npc",
            sListDisplayClass = "masterindexitem",
        }
        new_aRecords["episodes"] = {
            bExport = true,
            aDataMap = { "episode", "reference.episodes"},
            sRecordDisplayClass = "sta_episode",
            sListDisplayClass = "masterindexitem",
        }
        new_aRecords["saved_lptableset"] = {
            bExport = true,
            aDataMap = { "saved_lptableset", "reference.saved_lptableset"},
            sRecordDisplayClass = "saved_lptableset",
            sListDisplayClass = "masterindexitem",
		    sSidebarCategory = "library"
        }
        new_aRecords["chat_helper"] = {
            aCustom = {
                tWindowMenu = { ["left"] = { "chat_speak" } },
            },
            aDataMap = { "chat_helper", "reference.chat_helper" },
            sRecordDisplayClass = "npc",
            sListDisplayClass = "masterindexitem",
            tOptions = {
                bExport = true,
                bID = true,
                bToken = true,
                bPicture = true,
                bHidden = true,
                bCustomDie = true,
            },
        }
    end
	for kRecordType,vRecordType in pairs(new_aRecords) do
		LibraryData.setRecordTypeInfo(kRecordType, vRecordType);
	end
end