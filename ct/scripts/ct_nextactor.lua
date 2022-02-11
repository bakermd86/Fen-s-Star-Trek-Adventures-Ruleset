function onClickDown(...)
    local names = window.populate_actors()
    window.select_nextactor.clear()
    if #names == 0 then
        CombatManager.nextRound(1)
        names = window.populate_actors()
    end
    window.select_nextactor.addItems(names)
    return true
end

function onClickRelease(button, x, y)
    return window.select_nextactor.activate(button)
end

function onDragStart(button, x, y, draginfo)
    draginfo.setType("combattrackernextactor");
    draginfo.setIcon("button_ctnextactor");

    return true;
end