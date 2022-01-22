
function onDrop(x,y,draginfo)
  if draginfo.isType("shortcut") then
    local class, datasource = draginfo.getShortcutData();
    if class == "referencetext" or class == "referencemanualpage" or
        class == "sta_talent" or (class == "charsheet") or (class == "npc") or (class == "sta_episode")then
      local entry = createWindow()
      entry.label.setValue(draginfo.getDatabaseNode().getChild("name").getValue())
      entry.link.setValue(class, datasource);
      entry.link.setVisible(true);
    end
  end
  return true;
end