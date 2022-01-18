function onInit()
    self.attName = "";
    self.source = nil;
    self.selected = false;
    self.count = 0
    self.multiCount = 1
    self.pWindow = nil
end

function setSource(source)
    self.source = source;
end

function parentWindow()
    if self.pWindow then return self.pWindow else return window.windowlist end
end

function setWindow(window)
    self.pWindow = window
end

function setMultiCount(multiCount)
    self.multiCount = multiCount
end

function onClose()
    if self.count > 0 then
        repeat self.toggleOff() until self.count == 0
    elseif self.count < 0 then
        repeat self.toggleOn() until self.count == 0
    end
end

function setFrameState()
    self.selected = not(self.count == 0);
    if self.selected then
        self.setFrame("lcars_buttondown", 2,1,2,1);
    else
        self.setFrame("lcars_buttonup", 2,1,2,1);
    end
end

function toggleOn()
    self.count = self.count + 1
    self.setFrameState()
    for _=1,self.multiCount,1 do
        self.parentWindow().incrementAttribute(self.attName, self.source);
    end
    self.parentWindow().scoreSelected(self.attName, self.source)
end

function toggleOff()
    self.count = self.count - 1
    self.setFrameState()
    for _=1,self.multiCount,1 do
        self.parentWindow().decrementAttribute(self.attName, self.source);
    end
    self.parentWindow().scoreDeselected(self.attName, self.source)
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