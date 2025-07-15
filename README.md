# KillFeed (WoW 3.3.5 Addon)

A Counter-Strike-style PvP kill feed for World of Warcraft 3.3.5. Displays who killed whom, their class, and the spell used.

## 📌 Description

KillFeed listens to the combat log and shows PvP kill messages in a format like:

```
Bobby [Priest] [Shadow Word: Pain] → Gronk [Warrior]
```

This mimics the visual kill feed found in games like Counter-Strike.

---

## 🔧 Features

- Real-time PvP kill detection
- Shows:
  - Killer name and class
  - Victim name and class
  - Spell or melee used
- Clean, simple on-screen feed
- 100% local — no server messages or dependencies

---

## 📁 Folder Structure

```
KillFeed/
├── KillFeed.toc
├── KillFeed.xml
└── KillFeed.lua
```

---

## 📄 KillFeed.toc

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

## 🧱 KillFeed.xml

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

## 🧠 KillFeed.lua

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

## 🚀 Optional Ideas

- Add fade-out animations or scroll effects (like MSBT or Parrot)
- Queue recent kills in a multi-line log
- Add sound support via ChatSounds or custom audio
- Restrict feed to Battlegrounds or Arenas only

---

## ✅ Compatibility

- Works on Wrath of the Lich King (3.3.5a)
- Tested with ElvUI, Recount, Parrot, MSBT

---

## 📜 License

This project is open-source and free to use or modify.

---

## 🙋‍♂️ Contributing

Got a feature idea or bug fix? Open an issue or PR.
