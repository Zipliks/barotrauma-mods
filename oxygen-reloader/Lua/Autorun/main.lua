if SERVER then return end
local Config = require("config")

print(
    "--------\n" ..
    "Running Oxygen Reloader version: " .. Config.version ..
    "\nCurrent reload button is: " .. tostring(Config.button) ..
    "\n--------"
)

Hook.Add("keyUpdate", "AutoReplaceOxygenTank", function(keyargs)
    
    if not PlayerInput.KeyDown(Config.button) then
        return
    end
    
    if Character.DisableControls then
        return
    end
    if Character.Controlled == nil or Character.Controlled.Inventory == nil then
        return
    end
    
    local character = Character.Controlled
    local suit_slot = character.Inventory.GetItemInLimbSlot(InvSlotType.OuterClothes)
    local head_slot = character.Inventory.GetItemInLimbSlot(InvSlotType.Head)

    if suit_slot ~= nil and suit_slot.HasTag("diving") then
        ReplaceSuitTank(character, suit_slot)
    elseif head_slot ~= nil and head_slot.HasTag("diving") then
        ReplaceMaskTank(character, head_slot)
    end
end)


-- Used if there is no tank in diving suit
function ReplaceAny(character, diving_gear)
    local variants = CollectAllTanks(character)
    if #variants == 0 or variants == nil then
        return
    end

    -- Find the best quality
    local max_quality = FindMaxQuality(variants)

    -- Remove all tanks of lower quality
    local i = 1
    while i <= #variants do
        if variants[i].Quality < max_quality then
            table.remove(variants, i)
        else
            i = i + 1
        end
    end

    local best_tank = FindBiggestCondition(variants)
    diving_gear.OwnInventory.TryPutItem(best_tank, 0, true, false, character)
end

-- Replace for better tank
function ReplaceSuitTank(character, suit_slot)
    local suit_tank = suit_slot.OwnInventory.FindItemByTag("oxygensource", true)

    if suit_tank == nil then
        ReplaceAny(character, suit_slot)
    end

    local variants = CollectAllTanks(character)
    if #variants == 0 or variants == nil then
        return
    end

    -- Find the best quality
    local max_quality = FindMaxQuality(variants)
    variants = RemoveLowQuality(variants, max_quality)


    local best_tank = FindBiggestCondition(variants)
    if best_tank == suit_tank then
        return
    end
    suit_slot.OwnInventory.TryPutItem(best_tank, 0, true, false, character)
end

function ReplaceMaskTank(character, head_slot)
    local mask_tank = head_slot.OwnInventory.FindItemByTag("oxygensource", true)

    if mask_tank == nil then
        ReplaceAny(character, head_slot)
    end

    local variants = CollectAllTanks(character)
    if #variants == 0 or variants == nil then
        return
    end

    -- Find the best quality
    local max_quality = FindMaxQuality(variants)
    variants = RemoveLowQuality(variants, max_quality)


    local best_tank = FindBiggestCondition(variants)
    if best_tank == mask_tank then
        return
    end
    head_slot.OwnInventory.TryPutItem(best_tank, 0, true, false, character)
end
