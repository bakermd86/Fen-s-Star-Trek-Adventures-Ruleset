local _activated = false

function onClickDown(...)
    return true
end

function setActive(bActive)
    _activated = bActive
end

function onClickRelease(button, x, y)
    if _activated then
        _activated = false
    else
        local names = window.populate_actors()
        window.select_nextactor.clear()
        if #names == 0 then
            CombatManager.nextRound(1)
            names = window.populate_actors()
        end
        window.select_nextactor.addItems(names)
        _activated = true
    end
    return window.select_nextactor.activate(button)
end

function onDragStart(button, x, y, draginfo)
    draginfo.setType("combattrackernextactor");
    draginfo.setIcon("button_ctnextactor");

    return true;
end