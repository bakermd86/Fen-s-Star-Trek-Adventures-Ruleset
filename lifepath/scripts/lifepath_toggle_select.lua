function onInit()
    self.attName = "";
    self.source = nil;
    self.selected = false;
    self.count = 0
end

function setSource(source)
    self.source = source;
end

function parentWindow()
    return ScopeManager.getLifepathWindow();
end

function onClose()
    if not ScopeManager.safeToCleanup() then return end
    if self.count > 0 then
        repeat self.toggleOff() until self.count == 0
    elseif self.count < 0 then
        repeat self.toggleOn() until self.count == 0
    end
end

function setFrameState()
    self.selected = not(self.count == 0);
    if self.selected then
        self.setFrame("lcars_buttondown", 2, 1, 2, 1);
    else
        self.setFrame("lcars_buttonup", 2, 1, 2, 1);
    end
end

function toggleOn()
    self.count = self.count + 1
    self.setFrameState()
    self.parentWindow().incrementAttribute(self.attName, self.source);
    ScopeManager.updateAlerts()
end

function toggleOff()
    self.count = self.count - 1
    self.setFrameState()
    self.parentWindow().decrementAttribute(self.attName, self.source);
    if not (ScopeManager.getLifepathWindow() == nil) then
        ScopeManager.updateAlerts()
    end
end

function setName(text)
    self.attName = string.lower(text);
    self.setText(text);
end

function onButtonPress()
    if self.selected then
        self.toggleOff()
    else
        if self.source.getCount() >= 1 then
            self.toggleOn()
        end
    end
end