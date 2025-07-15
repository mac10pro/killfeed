# KillFeed Addon for WoW 3.3.5  
A Counter-Strike-style kill feed using the combat log

## Description

This addon replicates a kill feed similar to *Counter-Strike* in **World of Warcraft 3.3.5 (Wrath of the Lich King)**. It listens to the combat log and displays messages like:

```
Bobby [Priest] [Shadow Word: Pain] → Gronk [Warrior]
```

## Features

- PvP kill tracking
- Displays killer and victim names
- Shows class of both players
- Shows the spell or "Melee" used
- Simple on-screen text feed
- Lightweight and efficient

---

## Folder Structure

```
KillFeed/
├── KillFeed.toc
├── KillFeed.xml
└── KillFeed.lua
```

---

## KillFeed.toc

```
## Interface: 30300
## Title: KillFeed
## Notes: Counter-Strike-style kill feed for 3.3.5
## Version: 1.0
## Author: You
KillFeed.xml
KillFeed.lua
```

---

## KillFeed.xml

```
<Ui xmlns="http://www.blizzard.com/wow/ui/"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

    <Frame name="KillFeedFrame" hidden="false" movable="true" frameStrata="HIGH">
        <Size x="300" y="150"/>
        <Anchors>
            <Anchor point="TOPRIGHT">
                <Offset x="-100" y="-200"/>
            </Anchor>
        </Anchors>
        <Layers>
            <Layer level="ARTWORK">
                <FontString name="KillFeedText" inherits="GameFontNormalLarge" text="">
                    <Size x="300" y="150"/>
                    <Anchors>
                        <Anchor point="TOPLEFT"/>
                    </Anchors>
                </FontString>
            </Layer>
        </Layers>
    </Frame>
</Ui>
```

---

## KillFeed.lua

```
local frame = CreateFrame("Frame")
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

-- Get class name if player is in party or raid
local function GetUnitClass(name)
    for i = 1, GetNumRaidMembers() do
        local raidName, _, _, _, class = GetRaidRosterInfo(i)
        if raidName == name then
            return class
        end
    end
    for i = 1, GetNumPartyMembers() do
        local unit = "party"..i
        if UnitName(unit) == name then
            local _, class = UnitClass(unit)
            return class
        end
    end
    return "Unknown"
end

frame:SetScript("OnEvent", function()
    local _, eventType, _, sourceGUID, sourceName, sourceFlags, _, destGUID, destName, destFlags, _, spellID, spellName = CombatLogGetCurrentEventInfo()

    if eventType == "SPELL_DAMAGE" or eventType == "SWING_DAMAGE" then
        local destIsPlayer = bit.band(destFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0
        local sourceIsPlayer = bit.band(sourceFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0

        if sourceIsPlayer and destIsPlayer and UnitIsDeadOrGhost(destName) then
            local killerClass = GetUnitClass(sourceName)
            local victimClass = GetUnitClass(destName)
            local spell = spellName or "Melee"

            local message = string.format("%s [%s] [%s] → %s [%s]", sourceName, killerClass, spell, destName, victimClass)
            KillFeedText:SetText(message)

            C_Timer.After(5, function()
                KillFeedText:SetText("")
            end)
        end
    end
end)
```

---

## Optional Additions

- Fade-out animation instead of instant clear
- Scrolling log of recent kills (like MSBT or Parrot)
- Sound effects (with ChatSounds or custom)
- Arena/BG only mode
