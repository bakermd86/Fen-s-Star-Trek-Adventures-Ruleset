
new_aRecords = {
	["talents"] = {
		bExport = true,
		aDataMap = { "talent", "reference.talent"},
		sRecordDisplayClass = "sta_talent",
		sListDisplayClass = "masterindexitem",
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
    if User.isHost() or User.isLocal() then
        new_aRecords["crewmates"] ={
            bExport = true,
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
    end
	for kRecordType,vRecordType in pairs(new_aRecords) do
		LibraryData.setRecordTypeInfo(kRecordType, vRecordType);
	end
end