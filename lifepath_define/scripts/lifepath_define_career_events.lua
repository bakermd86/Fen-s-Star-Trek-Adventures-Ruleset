function onInit()
    self.header.subwindow.setName("Career Event Name")
    self.name_header.subwindow.name.setValue("Step 6 - Career Events")
    self.usedVals = {}
    self.att_mode_controls = {
        self.career_events_attribute_mode_fixed,
        self.career_events_attribute_mode_select_from,
        self.career_events_attribute_mode_any
    }
    self.disc_mode_controls = {
        self.career_events_discipline_mode_fixed,
        self.career_events_discipline_mode_select_from,
        self.career_events_discipline_mode_any
    }
    self.select_controls = {
        self.attribute_define_subwindow,
        self.discipline_define_subwindow
    }
    self.attModeMap = {
        ["Any"] = self.career_events_attribute_mode_any,
        [1] = self.career_events_attribute_mode_fixed,
        [6] = self.career_events_attribute_mode_select_from
    }
    self.discModeMap = {
        ["Any"] = self.career_events_discipline_mode_any,
        [1] = self.career_events_discipline_mode_fixed,
        [6] = self.career_events_discipline_mode_select_from
    }
end

function onRowLoad()
    LifePathDefineHelper.loadResult(self.attribute_define_subwindow, self.attModeMap, 2)
    LifePathDefineHelper.loadResult(self.discipline_define_subwindow, self.discModeMap, 3)
end
