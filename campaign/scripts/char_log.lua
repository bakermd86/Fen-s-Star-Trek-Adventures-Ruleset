function onInit()
    if DB.getValue(getDatabaseNode(), "available" ) == 1 then
        handleSupportingCharacter()
    end
end

function handleNewEpisode(nodeUpdated)
    episode_name.setValue(DB.getValue(nodeUpdated.getNodeName()))
end

function handleSupportingCharacter()
    saved_milestones_label.setVisible(false)
    saved_improvements_label.setVisible(true)
end