


function showList()
	-- Create the list if it does not exist
	local sName = getName() or "";
	if not _ctrlList and (sName or "") ~= "" then
		local sList = sName .. "_cblist";
		local sListScroll = sName .. "_cblistscroll";
		local w,h = getSize();

		-- Create the list control
		if unsorted then
			_ctrlList = window.createControl("combobox_list", sList);
		else
			_ctrlList = window.createControl("combobox_list_sorted", sList);
		end
		_ctrlList.setTarget(sName);
		_ctrlList.setAnchor("left", sName, "left", "absolute", -(_tListOffset.x));
		_ctrlList.setAnchor("right", sName, "right", "absolute", _tListOffset.x);
		if _sListDirection == "up" then
			_ctrlList.setAnchor("bottom", sName, "top", "absolute", -(_tListOffset.y));
			_ctrlList.resetAnchor("top");
		else
			_ctrlList.setAnchor("top", sName, "bottom", "absolute", _tListOffset.y);
			_ctrlList.resetAnchor("bottom");
		end

		-- Set the list parameters
		_ctrlList.setFonts(_sListFont, _sListSelectedFont);
		_ctrlList.setFrames(_sListFrame, _sListSelectedFrame);
		_ctrlList.setMaxRows(_nListMaxSize);

		-- Populate the list
		for k,v in ipairs(_tOrderedItems) do
			_ctrlList.add(k, v, _tItems[v].text, _tItems[v].allowdelete);
		end

		-- Create list scroll bar
		_ctrlScroll = window.createControl("combobox_scrollbar", sListScroll);
		_ctrlScroll.setAnchor("left", sList, "right", "absolute", -10);
		_ctrlScroll.setAnchor("top", sList, "top");
		_ctrlScroll.setAnchor("bottom", sList, "bottom");
		_ctrlScroll.setTarget(sList);
	end

	-- Show the list if it exists
	if _ctrlList then
		_bActive = true;
		_ctrlList.setVisible(true);
		_ctrlList.setFocus(true);
		_ctrlList.scrollToSelected();
	end
	refreshButtonDisplay();
	refreshSelectionDisplay();
end

function onButtonPress()
end

function onDragStart(button, x, y, draginfo)
    draginfo.setType("combattrackernextactor");
    draginfo.setIcon("button_ctnextactor");

    return true;
end