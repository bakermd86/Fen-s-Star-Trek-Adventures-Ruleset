local _activated = false

function onInit()
    window.select_endturn.onSelect = CTHelper.handleEndTurnSelect
end

function onClickDown(...)
    return true
end
function onClickRelease(button, x, y)
    if _activated then
        _activated = false
    else
        window.select_endturn.clear()
        window.select_endturn.addItems({"Return Initiative", "Keep Initiative"})
        _activated = true
    end
    return window.select_endturn.activate(button)
end