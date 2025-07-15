-- killfeed.lua

-- SavedVariables: KillFeedDB

local KillFeedMessages = {}
local MAX_MESSAGES = 5
local DISPLAY_TIME = 6 -- seconds
local killfeedEnabled = true

SLASH_KILLFEED1 = "/kf"
SlashCmdList["KILLFEED"] = function(msg)
    msg = msg:lower()
    if msg == "1" or msg == "on" then
        killfeedEnabled = true
        print("KillFeed enabled.")
    elseif msg == "0" or msg == "off" then
        killfeedEnabled = false
        print("KillFeed disabled.")
    else
        print("Usage: /kf 1 | 0")
    end
end

local function ColorName(name, class)
    local color = class and RAID_CLASS_COLORS[class]
    if not color then
        return name
    end
    return string.format("|cff%02x%02x%02x%s|r", color.r * 255, color.g * 255, color.b * 255, name)
end

local function GetClassByName(name)
    for i = 1, GetNumRaidMembers() do
        local unit, _, _, _, class = GetRaidRosterInfo(i)
        if unit == name then return class end
    end
    for i = 1, GetNumPartyMembers() do
        local unit = "party" .. i
        if UnitName(unit) == name then
            local _, class = UnitClass(unit)
            return class
        end
    end
    return nil
end

local function ReanchorMessages()
    for i, msg in ipairs(KillFeedMessages) do
        msg:ClearAllPoints()
        msg:SetPoint("TOPLEFT", 10, -((i - 1) * 20))
    end
end

local function FadeOutAndRemove(msgFrame)
    local alpha = 1
    local fader = CreateFrame("Frame")
    fader:SetScript("OnUpdate", function(self, elapsed)
        alpha = alpha - elapsed * 0.5
        if alpha <= 0 then
            msgFrame:Hide()
            msgFrame:SetParent(nil)
            for i, m in ipairs(KillFeedMessages) do
                if m == msgFrame then
                    table.remove(KillFeedMessages, i)
                    break
                end
            end
            ReanchorMessages()
            self:SetScript("OnUpdate", nil)
            self:Hide()
        else
            msgFrame:SetAlpha(alpha)
        end
    end)
end

local function CreateMessageFrame()
    local container = CreateFrame("Frame", nil, KillFeedContent)
    container:SetSize(280, 20)

    local text = container:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    text:SetJustifyH("LEFT")
    text:SetPoint("LEFT", 0, 0)
    text:SetWidth(260)

    container.text = text

    return container
end

local function AddKillMessage(killer, killerClass, spell, victim, victimClass, spellID)
    if #KillFeedMessages >= MAX_MESSAGES then
        local old = table.remove(KillFeedMessages, 1)
        old:Hide()
        old:SetParent(nil)
    end

    local msgFrame = CreateMessageFrame()
    msgFrame:SetParent(KillFeedContent)
    msgFrame:SetAlpha(1)
    msgFrame:Show()

    local formatted
    if not killerClass or not spell or not victimClass then
        formatted = string.format("%s killed %s", killer, victim)
    else
        formatted = string.format("%s {%s} %s",
            ColorName(killer, killerClass),
            spell,
            ColorName(victim, victimClass)
        )
    end

    msgFrame.text:SetText(formatted)

    table.insert(KillFeedMessages, msgFrame)
    ReanchorMessages()

    C_Timer.After(DISPLAY_TIME, function()
        FadeOutAndRemove(msgFrame)
    end)
end

-- Event handling
local frame = CreateFrame("Frame")
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

frame:SetScript("OnEvent", function()
    if not killfeedEnabled then return end

    local _, eventType, _, sourceGUID, sourceName, sourceFlags, _, destGUID, destName, destFlags, _, spellID, spellName = CombatLogGetCurrentEventInfo()

    if not (sourceName and destName) then return end

    local sourceIsPlayer = bit.band(sourceFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0
    local destIsPlayer = bit.band(destFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0

    if not (sourceIsPlayer and destIsPlayer) then return end

    if eventType == "SPELL_DAMAGE" or eventType == "SWING_DAMAGE" or eventType == "RANGE_DAMAGE" then
        local killerClass = GetClassByName(sourceName)
        local victimClass = GetClassByName(destName)
        local spell = spellName or "<melee>"

        AddKillMessage(sourceName, killerClass, spell, destName, victimClass, spellID)
    end
end)
