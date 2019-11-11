local addonname = ...
local f = CreateFrame("Frame")

local function OnEvent(self, event, ...)
    local arg1 = ...
    if event == "ADDON_LOADED" and arg1 == addonname then
        DoInit()
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = CombatLogGetCurrentEventInfo()
        if sourceName == UnitName("player") and (subevent == "SPELL_DAMAGE" or subevent == "SPELL_PERIODIC_DAMAGE" or subevent == "RANGE_DAMAGE") then
           local _, subevent, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, destRaidFlags, _, spellName, _, amount, overkill = CombatLogGetCurrentEventInfo()
           if overkill ~= nil and overkill > 0 and bit.band(destFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0 then
               AddKill(spellName)
           end
       elseif sourceName == UnitName("player") and subevent == "SWING_DAMAGE" then
           local _, subevent, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, destRaidFlags, amount, overkill = CombatLogGetCurrentEventInfo()
           if overkill ~= nil and overkill > 0 and bit.band(destFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0 then
               AddKill("Attack")
           end
        end
    end
end

SLASH_KILLCOUNTERS1 = "/killcount"
SlashCmdList["KILLCOUNTERS"] = function(msg)
    --if msg == "debug" then
        --print("Debug Print")
    --end
    local printDetails = msg == "detailed"
    local x = 0
    for k, v in pairs(KillCounts) do
        x = x+v
        if printDetails then
            print("|cFF00FF00["..k.."]|r - "..v)
        end
    end
    print("Total Killing Blows Tracked: "..x)
end

local function SetTooltip(tt)
    local title = _G[tt:GetName().."TextLeft1"]
    local actionName = title:GetText()
    if KillCounts[actionName] then
        local kbs = KillCounts[actionName]
        local det = "|cFFFFFFFFKilling Blows:|r "..kbs
        tt:AddLine(" ")
        tt:AddLine(det)
        tt:Show()
    end
end

function KillCounters_OnUpdate()

end

function AddKill(actionName)
    if not KillCounts[actionName] then
        KillCounts[actionName] = 0
    end
    KillCounts[actionName] = KillCounts[actionName]+1
end

function DoInit()
    if not KillCounts then
        KillCounts = {}
    end
end

hooksecurefunc(GameTooltip,"SetSpellBookItem",function(self)
  SetTooltip(self)
end)

hooksecurefunc(GameTooltip,"SetAction",function(self)
  SetTooltip(self)
end)

f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", OnEvent)
print("Loaded |cFFFF4400[KillCounters]|r by Blueteak. /killcount for details")
