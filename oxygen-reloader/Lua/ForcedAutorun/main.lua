if SERVER then return end
require("config")

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
    local suitSlot = character.Inventory.GetItemInLimbSlot(InvSlotType.OuterClothes)
    local headSlot = character.Inventory.GetItemInLimbSlot(InvSlotType.Head)

    if suitSlot ~= nil and (suitSlot.HasTag("diving") or suitSlot.HasTag("deepdiving")) then
        ReplaceSuitTank(character, suitSlot)
    elseif headSlot ~= nil and headSlot.HasTag("diving") then
        ReplaceMaskTank(character, headSlot)
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
    elseif suit_tank.Condition >= Config.min_swap_condition then
        return
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

function ReplaceMaskTank(character, headSlot)
    local mask_tank = headSlot.OwnInventory.FindItemByTag("oxygensource", true)

    if mask_tank == nil then
        ReplaceAny(character, headSlot)
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
    headSlot.OwnInventory.TryPutItem(best_tank, 0, true, false, character)
end
