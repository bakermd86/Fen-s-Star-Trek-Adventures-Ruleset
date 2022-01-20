function onInit()
    self.header.subwindow.setName("Species Name")
    self.name_header.subwindow.name.setValue("Step 1 - Species")
    self.usedVals = {}
    self.att_mode_controls = {
        self.species_attribute_mode_fixed,
        self.species_attribute_mode_select_from,
        self.species_attribute_mode_any
    }
    self.select_controls = {
        self.attribute_define_subwindow
    }
    self.modeMap = {
        ["Any"] = self.species_attribute_mode_any,
        [3] = self.species_attribute_mode_fixed,
        [6] = self.species_attribute_mode_select_from
    }
end

function onRowLoad()
    LifePathDefineHelper.loadResult(self.attribute_define_subwindow, self.modeMap, 2)
end
