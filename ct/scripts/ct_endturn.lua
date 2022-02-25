function onClickDown(...)
    window.select_endturn.clear()
    window.select_endturn.addItems({"Return Initiative", "Keep Initiative"})
    return true
end

function onClickRelease(button, x, y)
    return window.select_endturn.activate(button)
end