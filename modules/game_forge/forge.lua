local forgeWindow
local forgePanel

function init()
  connect(g_game, { onGameEnd = onGameEnd })
  ProtocolGame.registerExtendedOpcode(120, onForgeData)
  forgeWindow = g_ui.displayUI('forge.otui')
  forgeWindow:hide()
  forgePanel = forgeWindow:getChildById('forgePanel')
end

function terminate()
  disconnect(g_game, { onGameEnd = onGameEnd })
  ProtocolGame.unregisterExtendedOpcode(120)
  forgeWindow:destroy()
end

function onGameEnd()
  forgeWindow:hide()
end

function onForgeData(protocol, opcode, buffer)
  local status, data = pcall(function() return json.decode(buffer) end)
  if not status then
    g_logger.error("Failed to parse Forge data: " .. buffer)
    return
  end

  forgeWindow:show()
  forgeWindow:raise()
  forgeWindow:focus()

  local itemSlot = forgePanel:getChildById("itemSlot")
  itemSlot:setItemId(data.itemId or 2160)

  local levelLabel = forgePanel:getChildById("forgeLevel")
  levelLabel:setText("Forge Level: " .. (data.forgeLevel or 0))

  local chanceLabel = forgePanel:getChildById("successChance")
  chanceLabel:setText("Success: " .. (data.successChance or 0) .. "%")
end

function onForgeButtonClick()
  g_game.sendExtendedOpcode(121, json.encode({ action = "attemptForge" }))
end
