function onInit()
    self.header.subwindow.setName("Environment Name")
    self.usedVals = {}
    self.att_mode_controls = {
        self.environment_attribute_mode_select_from,
        self.environment_attribute_mode_fixed,
        self.environment_attribute_mode_species,
        self.environment_attribute_mode_other_species,
        self.environment_attribute_mode_any
    }
    self.disc_mode_controls = {
        self.environment_discipline_mode_select_from,
        self.environment_discipline_mode_fixed,
        self.environment_discipline_mode_any
    }
    self.select_controls = {
        self.attribute_define_subwindow,
        self.discipline_define_subwindow
    }
    self.attModeMap = {
        ["Any"] = self.environment_attribute_mode_any,
        ["Species"] = self.environment_attribute_mode_species,
        ["OtherSpecies"] = self.environment_attribute_mode_other_species,
        [1] = self.environment_attribute_mode_fixed,
        [6] = self.environment_attribute_mode_select_from
    }
    self.discModeMap = {
        ["Any"] = self.environment_discipline_mode_any,
        [1] = self.environment_discipline_mode_fixed,
        [6] = self.environment_discipline_mode_select_from
    }
end

function onRowLoad()
    LifePathDefineHelper.loadResult(self.attribute_define_subwindow, self.attModeMap, 2)
    LifePathDefineHelper.loadResult(self.discipline_define_subwindow, self.discModeMap, 3)
end