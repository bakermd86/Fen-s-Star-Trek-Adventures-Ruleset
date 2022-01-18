COLOR_RED = "FFF2513F"
COLOR_BLANK = "00000000"

function onInit()
    self.modes = {}
    self.source = nil
    self.callback = nil
    self._bActive = false
    self.last_value = ""
    self.display = ""
end

function onClickRelease(button, x, y)
    if super.onClickRelease(button, x, y) then
        self.toggle()
        return true
    end
end

function onLoseFocus()
    self.hideList()
end

function toggle()
	if self._bActive then self.hideList() else self.showList() end
end

function hideList()
    super.hideList();
    self._bActive = false
    if not (self.source == nil) then
        self.source.setAnchoredHeight(45);
    end
end

function showList()
    super.showList();
    self._bActive = true
    if not (self.source == nil) then
        self.source.setAnchoredHeight(200)
    end
end

function setModes(modes)
    self.modes = modes
    self.addItems(self.modes)
end

function setSource(source)
    self.source = source
end

function setDisplay(display)
    self.display = display
    self.setValue(display)
end

function setCallback(callback)
    self.callback = callback
end

function onValueChanged()
    if self.getValue() == self.last_value then
        return
    elseif self.callback then
        if not (self.last_value == "") then
            self.callback(self.last_value, false)
            self.last_value = ""
        end
        if not (self.getValue() == self.display) then
            self.callback(self.getValue(), true)
            self.last_value = self.getValue()
        end
    end
    if self.getValue() == self.display then window.setBackColor(COLOR_RED)
    else window.setBackColor(COLOR_BLANK) end
	ScopeManager.updateAlerts()
end