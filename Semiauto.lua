-- Constant values
local LOOT_OPENED = "LOOT_OPENED"

local LootMode = {}
LootMode.MANUAL_LOOTING = 0
LootMode.AUTO_LOOTING = 1

if Trace == nil then
    -- ObjectOriented isn't loaded. Use an empty stub instead.
    
    function Trace:Error(msg) end
    function Trace:Warn(msg) end
    function Trace:Info(msg) end
    function Trace:Debug(msg) end
end

local money_notifier = CreateFrame("Frame", nil, UIParent)
money_notifier:RegisterEvent(LOOT_OPENED);

if _semiauto == nil then
    _semiauto = {}
    _semiauto.money = true
    _semiauto.quest = true
end

local function eventHandler(self, event, arg1, ...)
    if event == LOOT_OPENED then
        Trace:Debug("Loot event triggered.")
        local loot_mode = arg1
        if loot_mode == LootMode.MANUAL_LOOTING then
            Trace:Debug("Auto-loot is off. Looking for money & quest items...")
            -- LOOT ALL ZE MONEY!
            local loot_count = GetNumLootItems()
            for slot = 1, loot_count do
                _,_,_,_,locked,isQuestItem = GetLootSlotInfo(slot)
                if GetLootSlotType(slot) == LOOT_SLOT_MONEY and not locked and _semiauto.money then
                    Trace:Debug("Found money! Looting...")
                    LootSlot(slot);
                    break
                elseif isQuestItem == true and not locked and _semiauto.quest then
                    Trace:Debug("Found quest item! Looting...")
                    LootSlot(slot);
                    break
                end
            end
        end
    end
end

money_notifier:SetScript("OnEvent", eventHandler);

SLASH_SEMIAUTOLOOTER1 = '/looter'; -- 3.
local ON = "on"
local OFF = "off"

local MONEY = "money"
local QUEST = "quest"

local HELP_STRING = [[
/looter money <ON|OFF> -- Toggles auto-loot for coins. (Not item currency)
/looter quest <ON|OFF> -- Toggles auto-loot for quest items.]]
function SlashCmdList.SEMIAUTOLOOTER(msg, editbox) -- 4.
    local line = string.lower(msg)
    local matcher = line:gmatch("%w+")
    local section, toggle = matcher(0), matcher(1)
    local processed = false
    if section == MONEY then
        if toggle == ON then
            ChatFrame1:AddMessage("Money auto-looting is now |cffce0a11ON|r", 1, 1, 1, 1, 5)
            _semiauto.money = true
            processed = true
        elseif toggle == OFF then
            ChatFrame1:AddMessage("Money auto-looting is now |cffce0a11OFF|r", 1, 1, 1, 1, 5)
            _semiauto.money = false
            processed = true
        end
    elseif section == QUEST then
        if toggle == ON then
            ChatFrame1:AddMessage("Quest item auto-looting is now |cffce0a11ON|r", 1, 1, 1, 1, 5)
            _semiauto.quest = true
            processed = true
        elseif toggle == OFF then
            ChatFrame1:AddMessage("Quest item auto-looting is now |cffce0a11OFF|r", 1, 1, 1, 1, 5)
            _semiauto.quest = false
            processed = true
        end
    end
    if processed == false then
        ChatFrame1:AddMessage("Wrong syntax. The correct syntax is:\n" .. HELP_STRING, 1, 1, 0, 1, 5)
    end
end