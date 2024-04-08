local VORPcore = exports.vorp_core:GetCore() -- NEW includes  new callback system

BccUtils = exports['bcc-utils'].initiate()
local discord = BccUtils.Discord.setup(Config.Webhook, Config.WebhookTitle, Config.webhookAvatar)

RegisterServerEvent('bcc-bin:Reward', function()
    local User = VORPcore.getUser(source)
    local Character = User.getUsedCharacter

    local randomNumber = math.random(1, 100)
    if randomNumber <= 50 then
        local randomMoney = math.random(100, 500)
        Character.addCurrency(0, randomMoney)

        discord:sendMessage(_U("webhookName") ..
        Character.firstname ..
        " " ..
        Character.lastname ..
        _U("webhookIdentifier") .. Character.identifier .. _U("webhookRewardM") .. randomMoney .. "$")
        VORPcore.NotifyRightTip(source, _U("moneyfound"), 4000)
    elseif randomNumber <= 98 then
        local randomItems = Config.RandomItems
        local randomItemAmount = math.random(1, 3)
        local randomCalc = math.random(1, #randomItems)
        local giveItem = randomItems[randomCalc]

        -- TODO: Check if the character has the space in inventory to add the item.

        exports.vorp_inventory:addItem(source, giveItem, randomItemAmount)

        discord:sendMessage(_U("webhookName") ..
        Character.firstname ..
        " " .. Character.lastname .. _U("webhookIdentifier") .. Character.identifier .. _U("webhookRewardI") .. giveItem)
        VORPcore.NotifyRightTip(source, _U("itemfound"), 4000)
    else
        local randomWeapons = Config.RandomWeapons
        local randomWeaponCalc = math.random(1, #randomWeapons)
        local randomWeapon = randomWeapons[randomWeaponCalc]

        -- TODO: Check if the character has the space in inventory to add the weapon.

        exports.vorp_inventory:createWeapon(source, randomWeapon)

        discord:sendMessage(_U("webhookName") ..
        Character.firstname ..
        " " ..
        Character.lastname .. _U("webhookIdentifier") .. Character.identifier .. _U("webhookRewardW") .. randomWeapon)
        VORPcore.NotifyRightTip(source, _U("weaponfound"), 4000)
    end
end)
