function onTabletopInit()
    table.insert(Desktop.aCoreDesktopStack["host"], {
        sIcon = "sidebar_icon_shortcut_traits",
        tooltipres = "sidebar_tooltip_scene_traits",
        class = "active_traits_window",
        path = "active_traits"
    })
    DesktopManager.rebuildSidebar()
end