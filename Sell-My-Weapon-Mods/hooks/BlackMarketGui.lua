local COINS_RECEIVED = 3

local function sell_weapon_mod(data)
    managers.blackmarket:remove_item(data.global_value, "weapon_mods", data.name)
    managers.custom_safehouse:add_coins(COINS_RECEIVED)
    managers.menu_component:post_event("item_sell")
    managers.menu_component:reload_blackmarket_gui()
end

local function open_sell_weapon_mod_dialog(data)
    managers.system_menu:show({
        title = managers.localization:to_upper_text("SellMyWeaponMods_sell_title"),
        text = managers.localization:text("SellMyWeaponMods_sell_text", {
            mod = data.name_localized,
            total = COINS_RECEIVED
        }),
        button_list = {
            {
                text = managers.localization:to_upper_text("dialog_yes"),
                callback_func = function () sell_weapon_mod(data) end
            },
            {
                text = managers.localization:to_upper_text("dialog_no"),
                cancel_button = true
            }
        }
    })
end

Hooks:PostHook(BlackMarketGui, "_setup", "SellMyWeaponMods_create_button", function (self)
    local text_x = 10
    self._btns.SellMyWeaponMods_sell = BlackMarketGuiButtonItem:new(self._buttons, {
        name = "SellMyWeaponMods_sell_button",
        btn = "BTN_A",
        prio = 5,
        callback = callback(self, self, "overridable_callback", {
            button = "SellMyWeaponMods_sell",
            callback = open_sell_weapon_mod_dialog
        })
    }, text_x)

    self:show_btns(self._selected_slot)
end)

Hooks:PostHook(BlackMarketGui, "populate_mods", "SellMyWeaponMods_add_button", function (self, data)
    local prev_data = data.prev_node_data
    if not managers.blackmarket:get_crafted_category_slot(prev_data.category, prev_data.slot).previewing then
        for i = 1, #data do
            local mod = data[i]
            if not mod.free_of_charge and type(mod.unlocked) == "number" and mod.unlocked ~= 0 then
                mod[#mod + 1] = "SellMyWeaponMods_sell"
            end
        end
    end
end)
