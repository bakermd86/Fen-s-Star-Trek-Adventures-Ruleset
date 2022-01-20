function onInit()
    self.header.subwindow.setName("Academy Track Name")
    self.name_header.subwindow.name.setValue("Step 4 - Academy")
    self.usedVals = {}
    self.disc_mode_controls = {
        self.academy_discipline_mode_select_from
    }
    self.select_controls = {
        self.discipline_define_subwindow
    }
    self.discModeMap = {
        ["Any"] = self.academy_discipline_mode_any,
        [1] = self.academy_discipline_mode_fixed,
        [2] = self.academy_discipline_mode_select_from
    }
end

function onRowLoad()
    LifePathDefineHelper.loadResult(self.discipline_define_subwindow, self.discModeMap, 2)
end