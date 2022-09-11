local module = {}

module.Name = "BrokenHandcuffs"

module.Config = {
    Enabled = false,
    ConditionDecrease = 1.5,
}

module.OnEnable = function ()
    if CLIENT then return end

    Hook.Add("st.slowthink", "BrokenHandcuffs.Think", function ()
        for key, value in pairs(Character.CharacterList) do
            if value.IsHuman and value.IsKeyDown(InputType.Crouch) then
                local item = value.Inventory.GetItemInLimbSlot(InvSlotType.RightHand)

                if item and not item.Removed and item.Prefab.Identifier == "handcuffs" then
                    item.Condition = item.Condition - module.Config.ConditionDecrease

                    if item.Condition <= 0 then
                        Entity.Spawner.AddEntityToRemoveQueue(item)
                    end
                end
            end
        end
    end)
end

module.OnDisable = function ()
    if CLIENT then return end

    Hook.Remove("st.slowthink", "BrokenHandcuffs.Think")
end


return module