function FindBiggestCondition(items)
	local max_ratio = items[1].Condition / items[1].MaxCondition
	local max_item = items[1]

	for i = 2, #items do
		local current_ratio = items[i].Condition / items[i].MaxCondition
		if (current_ratio > max_ratio) and (current_ratio ~= 0) then
			max_ratio = current_ratio
			max_item = items[i]
		end
	end

	return max_item
end

function FindMaxQuality(items)
	local max_quality = 0
	for _, item in ipairs(items) do
		if (item.Quality > max_quality) and (item.Condition / item.MaxCondition ~= 0) then
			max_quality = item.Quality
		end
	end

	return max_quality
end

function RemoveLowQuality(variants, max_quality)
	-- Remove all tanks of lower quality
	local i = 1
	while i <= #variants do
		if variants[i].Quality < max_quality then
			table.remove(variants, i)
		else
			i = i + 1
		end
	end
	return variants
end

function CollectAllTanks(character)
	local variants = {}
	-- Find all variants
	local iter = 1

	-- Collect all tanks from player's hotbar
	for item in character.Inventory.AllItems do
		if item.HasTag("oxygensource") then
			table.insert(variants, iter, item)
			iter = iter + 1
		end
	end

	-- Add mask tank to table if there is one
	local head_slot = character.Inventory.GetItemInLimbSlot(InvSlotType.Head)
	if head_slot ~= nil and head_slot.HasTag("diving") then
		local maskTank = head_slot.OwnInventory.FindItemByTag("oxygensource", true)
		if maskTank ~= nil then
			table.insert(variants, iter, maskTank)
			iter = iter + 1
		end
	end

	-- Add bag slot
	local bag_slot = character.Inventory.GetItemInLimbSlot(InvSlotType.Bag)
	if bag_slot ~= nil and bag_slot.HasTag("mobilecontainer") then
		for item in bag_slot.OwnInventory.AllItems do
			if item.HasTag("oxygensource") then
				table.insert(variants, iter, item)
				iter = iter + 1
			end
		end
	end

	-- Also add suit tank to the table
	local suit_slot = character.Inventory.GetItemInLimbSlot(InvSlotType.OuterClothes)
	if suit_slot ~= nil and suit_slot.HasTag("divingsuit") then
		local suit_tank = suit_slot.OwnInventory.FindItemByTag("oxygensource", true)
		if suit_tank ~= nil then
			table.insert(variants, iter, suit_tank)
		end
	end

	return variants
end
