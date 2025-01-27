----怕和其他函数冲突所有函数加入前缀“Zhu”

--- 将 Set Table 数值类型 转成 JSON 字符串 打印 方便调试 BUFF 信息
function ZhuLocalTabelToJSON(t)
  local function serialize(tbl)
    local jsonStr = "{"
    local first = true
    for k, v in pairs(tbl) do
      if not first then
        jsonStr = jsonStr .. ","
      end
      first = false
      local keyStr = '"' .. tostring(k) .. '"'
      local valueStr = ""
      if type(v) == "table" then
        valueStr = serialize(v)
      elseif type(v) == "string" then
        valueStr = '"' .. v .. '"'
      else
        valueStr = tostring(v)
      end
      jsonStr = jsonStr .. keyStr .. ":" .. valueStr
    end
    jsonStr = jsonStr .. "}"
    return jsonStr
  end
  return serialize(t)
end

----通过 SpellID 获取 法术姓名
function ZhuGetNameBySpellID(t)
  for i = 1, 40 do
    local info = C_UnitAuras.GetBuffDataByIndex("player", i, "HELPFUL")
    if info and info.spellId == t then
      print(info.name)
      return
    end
  end
end

----通过 姓名获取 法术ID
function ZhuGetSpellIDByName(t)
  for i = 1, 40 do
    local info = C_UnitAuras.GetBuffDataByIndex("player", i, "HELPFUL")
    if info and info.name == t then
      print(info.spellId)
      return
    end
  end
end

---通过ID 获取法术BUFF 信息
function ZhuGetSpellInfoByID(t)
  for i = 1, 40 do
    local info = C_UnitAuras.GetBuffDataByIndex("player", i, "HELPFUL")
    if info and info.spellId == t then
      return info -- 返回 info 本身
    end
  end
end

---根据 法术ID 打印所有关于 BUFF 的 JSON 信息
function ZhuPrintBuffPointsBySpellID(t)
  local index = nil
  for i = 1, 40 do
    local info = C_UnitAuras.GetBuffDataByIndex("player", i, "HELPFUL")
    if info and info.spellId == t then
      index = i
      if info.points then
        for k, v in pairs(info.points) do
          print("points[" .. k .. "] = " .. tostring(v))
        end
      else
        print(t .. " 找到了, 但没有 points 数据")
      end
      break
    end
  end

  if not index then
    print(t .. "该法术buffID对应的BUFF未找到")
  end
end

---根据 法术ID 打印所有关于 BUFF 中游戏鼠标浮在上面 的 提示信息 的 JSON 信息
function ZhuPrintBuffToolTip(t)
  local index = nil
  for i = 1, 40 do
    local info = C_UnitAuras.GetAuraDataByIndex("player", i, "HELPFUL")
    if info and info.spellId == t then
      index = i
      if info then
        local aura_instance_id = info.auraInstanceID;
        local tooltip_data = C_TooltipInfo.GetUnitBuffByAuraInstanceID("player", aura_instance_id);
        print(ZhuLocalTabelToJSON(tooltip_data))
      else
        print(t .. "未找到该buff")
      end
      break
    end
  end
  if not index then
    print(t .. "该法术buffID对应的BUFF未找到")
  end
end

-- 将tooltip 中数值匹配出来 然后转成数字类型 进行运算
function ExtractNumber(text)
  local number = string.match(text, "%d+")
  return tonumber(number) -- Convert the captured string to a number
end

function ZhuGetBuffToolTip(t)
  for i = 1, 40 do
    local info = C_UnitAuras.GetAuraDataByIndex("player", i, "HELPFUL")
    if info and info.spellId == t then
      local aura_instance_id = info.auraInstanceID
      local tooltip_data = C_TooltipInfo.GetUnitBuffByAuraInstanceID("player", aura_instance_id)
      return tooltip_data -- Return tooltip data if found
    end
  end
  return nil -- Return nil if the buff is not found
end

-- 处理增强萨满的 旋涡武器层数 获取当前层数，最大层数
function ZhuGetEnhancementShamanWindfuryWeaponStack()
  local spellId = 344179;
  local info = ZhuGetSpellInfoByID(spellId)
  local value = info and info.applications or 0
  local max = 10
  return value, max
end

function ZhuGetMonkPanFuryStack()
  local max = 240;
  local value = 0;
  local info = ZhuGetSpellInfoByID(470670);
  value = (info and info.points and info.points[1]) or 0
  return value, max
end

-- 处理武僧的 和谐大师 中 和谐值 返回当前和谐值
function ZhuGetMonkHarmonyCurrentValue()
  local function handle_data(data)
    if data then
      return ExtractNumber(data)
    else
      return 0
    end
  end
  local n = ZhuGetBuffToolTip(450521)
  if n and n.lines and n.lines[2] then
    local x = n.lines[2].leftText;
    return handle_data(x)
  else
    local m = ZhuGetBuffToolTip(450526)
    if m and m.lines and m.lines[2] then
      local y = m.lines[2].leftText;
      return handle_data(y);
    else
      local o = ZhuGetBuffToolTip(450531)
      if o and o.lines and o.lines[2] then
        local z = o.lines[2].leftText;
        return handle_data(z);
      else
        return 0
      end
    end
  end
end

---获取法术BUFF 中 Points (一般用来存储BUFF 提示等信息 的位置)
function ZhuPrintBuffPointsBySpellIDForJson(t)
  local index = nil
  for i = 1, 40 do
    local info = C_UnitAuras.GetBuffDataByIndex("player", i, "HELPFUL")
    if info and info.spellId == t then
      index = i
      if info.points then
        print(ZhuLocalTabelToJSON(info.points))
      else
        print(t .. " 找到了, 但没有 points 数据")
      end
      break
    end
  end

  if not index then
    print(t .. "该法术buffID对应的BUFF未找到")
  end
end

-- 获取指定 BUFF Spell ID 的提示信息
function ZhuGetBuffTooltipBySpellID(spellID)
  local index = nil
  for i = 1, 40 do
    -- 获取单位的第 i 个 BUFF 的名称和 Spell ID
    local info = C_UnitAuras.GetBuffDataByIndex("player", i, "HELPFUL")
    -- 检查是否找到指定的 Spell ID
    if info and info.spellId == spellID then
      -- 设置 GameTooltip 来获取提示信息
      index = i
      GameTooltip:SetOwner(UIParent, "ANCHOR_NONE")
      GameTooltip:SetUnitBuff("player", index)
      -- 获取 Tooltip 的文本内容
      local tooltipText = GameTooltipTextLeft1:GetText()
      -- 清除 GameTooltip
      GameTooltip:Hide()
      return tooltipText -- 返回找到的提示信息
    end
  end
  -- 如果没有找到指定的 BUFF
  return nil
end

function ZhuZhuMonkLunHuiChoice()
  local currentHealth = 0 -- 默认值为 0
  -- 检查目标是否存在且存活
  if UnitExists("target") and not UnitIsDead("target") then
    currentHealth = UnitHealth("target")
  end

  local playerHealth = 0
  if UnitExists("player") and not UnitIsDead("player") then
    playerHealth = UnitHealthMax("player")
  end

  local b = not UnitIsFriend("player", "target");

  return b and playerHealth >= currentHealth and UnitAffectingCombat("player")
end

function ZhuZhuPingAssist()
  C_Ping.SendMacroPing(Enum.PingSubjectType.Assist, "none");
end

function ZhuZhuBuffCount(spellId)
  local count = 0
  for i = 1, 40 do
    local info = C_UnitAuras.GetBuffDataByIndex("player", i, "HELPFUL")
    if info and info.spellId == spellId then
      count = count + 1
    end
  end
  return count
end

function ZhuZhuTalantInfoPrint()
  local configID = C_ClassTalents.GetActiveConfigID()
  if not configID then
    print("当前没有激活的天赋配置。")
    return false
  end

  local ConfigInfo = C_Traits.GetConfigInfo(configID)
  local treeID = ConfigInfo.treeIDs[1]
  local nodeIDs = C_Traits.GetTreeNodes(treeID)

  for k, v in pairs(nodeIDs) do
    local nodeInfo = C_Traits.GetNodeInfo(configID, v)
    if nodeInfo then
      if nodeInfo.entryIDs[1] then
        for m, n in pairs(nodeInfo.entryIDsWithCommittedRanks) do
          local entryInfo = C_Traits.GetEntryInfo(configID, n)
          if entryInfo and entryInfo.definitionID then
            local definitionInfo = C_Traits.GetDefinitionInfo(entryInfo.definitionID)
            if definitionInfo then
              local spellInfo = C_Spell.GetSpellInfo(definitionInfo.spellID);
              print("spellID---->", definitionInfo.spellID, "name----->", spellInfo.name);
            end
          end
        end
      end
    end
  end
end

function ZhuZhuTalantActive(spellId)
  local cache = nil -- 用于存储计算结果
  -- 返回一个接口函数，判断是否已缓存结果，若缓存则直接返回，若未缓存则执行计算
  return function(spellIDToFind)
    -- 如果缓存中有结果，直接返回
    if cache ~= nil then
      return cache
    end

    -- 否则执行计算并缓存结果
    local configID = C_ClassTalents.GetActiveConfigID()
    if not configID then
      cache = false -- 没有激活的天赋配置，缓存为 false
      return false
    end

    local configInfo = C_Traits.GetConfigInfo(configID)
    local treeID = configInfo.treeIDs[1]
    local nodeIDs = C_Traits.GetTreeNodes(treeID)

    for _, nodeID in pairs(nodeIDs) do
      local nodeInfo = C_Traits.GetNodeInfo(configID, nodeID)
      if nodeInfo and nodeInfo.entryIDs[1] then
        for _, entryID in pairs(nodeInfo.entryIDsWithCommittedRanks) do
          local entryInfo = C_Traits.GetEntryInfo(configID, entryID)
          if entryInfo and entryInfo.definitionID then
            local definitionInfo = C_Traits.GetDefinitionInfo(entryInfo.definitionID)
            if definitionInfo and definitionInfo.spellID == spellIDToFind then
              cache = true -- 找到目标天赋，缓存为 true
              return true
            end
          end
        end
      end
    end

    -- 未找到目标天赋，缓存为 false
    cache = false
    return false
  end
end

function ZhuZhuChangeFriendTemplate()
  local frame = CreateFrame("Frame")
  frame:RegisterEvent("PLAYER_ENTERING_WORLD")
  frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
  if not frame:GetScript("OnEvent") then
    frame:SetScript("OnEvent", function(self, event)
      local inInstance, instanceType = IsInInstance()
      if inInstance then
        print("玩家已进入副本，类型为：" .. instanceType)
        SetCVar("nameplateShowFriends", 1)
        -- 在此处添加进入副本时的操作
      else
        print("玩家已离开副本")
        SetCVar("nameplateShowFriends", 0)
        -- 在此处添加离开副本时的操作
      end
    end)
  end
end
