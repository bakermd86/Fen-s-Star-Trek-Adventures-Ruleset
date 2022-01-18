COLOR_PATTERN = "^[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]$"
COLOR_COMMAND = "lcarsColor"
COLOR_COMMAND_ALT = "lcarsColorAlt"
lcarsColorMain = "ff37c8ab"
lcarsColorAlt = "ffaa87de"
colorFrames = {}
colorFramesAlt = {}

function resetColors(node)
    updateFrames(getFrames("main", node), lcarsColorMain)
    saveColor(node, "main", lcarsColorMain)

    updateFrames(getFrames("alt", node), lcarsColorAlt)
    saveColor(node, "alt", lcarsColorAlt)
end

function saveColor(node, type, color)
    local path = "lcars_"..type.."_color"
    DB.setValue(node, path, "string", color)
end

function getColor(type, node)
    if type == "alt" then return getAltColor(node)
    else return getMainColor(node)
    end
end

function getMainColor(node)
    return DB.getValue(node, "lcars_main_color", lcarsColorMain)
end

function getAltColor(node)
    return DB.getValue(node, "lcars_alt_color", lcarsColorAlt)
end

function handleColorDialog(type, node, sResult, sColor)
    local path = "lcars_"..type.."_color"
    local frames = getFrames(type, node)

    if sResult == "cancel" then
        updateFrames(frames, getColor(type, node))
    else
        updateFrames(frames, sColor)
        if sResult == "ok" then
            saveColor(node, type, sColor)
        end
    end
end

function onAltColorDialogCallback(sResult, sColor, node)
    handleColorDialog("alt", node, sResult, sColor)
end

function onMainColorDialogCallback(sResult, sColor, node)
    handleColorDialog("main", node, sResult, sColor)
end

function getFrames(type, root)
    if type == "alt" then return colorFramesAlt[root.getNodeName()]
    else return colorFrames[root.getNodeName()]
    end
end

function registerColorFrame(frame, root)
    if not root then return end
    if colorFrames[root.getNodeName()] == nil then
        colorFrames[root.getNodeName()] = {frame}
    else
        table.insert(colorFrames[root.getNodeName()], frame)
    end
end

function unregisterColorFrame(frame, root)
    if not root then
        return
    elseif colorFrames[root.getNodeName()] == nil then
        return
    else
        for idx, exFrame in ipairs(colorFrames[root.getNodeName()]) do
           if exFrame == frame then
                table.remove(colorFrames[root.getNodeName()], idx)
                break
           end
        end
    end
end

function registerColorFrameAlt(frame, root)
    if not root then return end
    if colorFramesAlt[root.getNodeName()] == nil then
        colorFramesAlt[root.getNodeName()] = {frame}
    else
        table.insert(colorFramesAlt[root.getNodeName()], frame)
    end
end

function unregisterColorFrameAlt(frame, root)
    if not root then
        return
    elseif colorFramesAlt[root.getNodeName()] == nil then
        return
    else
        for idx, exFrame in ipairs(colorFramesAlt[root.getNodeName()]) do
           if exFrame == frame then
                table.remove(colorFramesAlt[root.getNodeName()], idx)
                break
           end
        end
    end
end

function updateFrames(frames, color)
    if frames then
        for k, frame in ipairs(frames) do
            if not frame then
                table.delete(frames, k)
            else
                pcall(function () frame.setBackColor(color) end)
            end
        end
    end
end