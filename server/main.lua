local VORPcore = exports.vorp_core:GetCore()
local BccUtils = exports['bcc-utils'].initiate()

local Discord = BccUtils.Discord.setup(Config.Webhook, Config.WebhookTitle, Config.webhookAvatar)
local InitialCoordsSet = false
local Location = {}
local CooldownData = {}

VORPcore.Callback.Register('bcc-bin:SetLocation', function(source, cb)
    local src = source
    local user = VORPcore.getUser(src)
    if not user then return cb(false) end

    if not InitialCoordsSet then
        Location = Locations[math.random(1, #Locations)]
        InitialCoordsSet = true
    end
    cb(Location)
end)

local function UpdateLocation()
    Location = Locations[math.random(1, #Locations)]
    TriggerClientEvent('bcc-bin:SpawnBin', -1, Location)
end

local function SetPlayerCooldown(type, charid)
    CooldownData[type .. tostring(charid)] = os.time()
end

RegisterServerEvent('bcc-bin:Reward', function()

    local playerLicenseKey = GetPlayerIdentifierByType(source, 'license'):gsub('license:', '')
    local playerDisocrdID = GetPlayerIdentifierByType(source, 'discord'):gsub('discord:', '')

    local src = source
    local user = VORPcore.getUser(src)
    if not user then return end
    local character = user.getUsedCharacter
    local charid = character.charIdentifier

    local randomNumber = math.random(1, 100)
    if randomNumber <= 50 then
        local randomMoney = math.random(Rewards.RandomMoney.min, Rewards.RandomMoney.max)
        character.addCurrency(0, randomMoney)

        if Config.discordlog then
            Discord:sendMessage(_U('webhookName') ..
                character.firstname ..
                ' ' ..
                character.lastname ..
                _U('webhookIdentifier') ..
                character.identifier ..
                _U('webhookRewardM') ..
                randomMoney .. '$')
        end

        if Config.grafanalog then
            lib.logger(src, 'BCC BIN Reward', "BCC Bin: Player " .. character.firstname .. ' ' .. character.lastname .. " used a bin and received money.", 'PID: ' .. source, 'Logged Discord ID: ' .. playerDisocrdID, 'Logged License Key: ' .. playerLicenseKey, 'Reward: ' .. randomMoney .. '$')
        end

        if Config.notify == 'ox' then
            lib.notify(src, {description = _U('moneyfound') .. tostring(randomMoney), duration = 4000, type = 'success', position = 'center-right'}) 
        elseif Config.notify == 'vorp' then
            VORPcore.NotifyRightTip(src, _U('moneyfound') .. tostring(randomMoney), 4000)
        end

    elseif randomNumber <= 98 then
        local randomItems = Rewards.RandomItems
        local randomItemAmount = math.random(1, 3)
        local randomCalc = math.random(1, #randomItems)
        local selectedItem = randomItems[randomCalc]
        local itemName = selectedItem.itemName
        local itemLabel = selectedItem.itemLabel

        local canCarryItem = exports.vorp_inventory:canCarryItem(src, itemName, randomItemAmount)
        if not canCarryItem then
            if Config.notify == 'ox' then
                lib.notify(src, {description = _U('noSpace'), duration = 4000, type = 'error', position = 'center-right'}) 
            elseif Config.notify == 'vorp' then
                VORPcore.NotifyRightTip(src, _U('noSpace'), 4000)
            end
            goto END
        end
        exports.vorp_inventory:addItem(src, itemName, randomItemAmount)

        if Config.discordlog then
            Discord:sendMessage(_U('webhookName') ..
                character.firstname ..
                ' ' .. character.lastname ..
                _U('webhookIdentifier') ..
                character.identifier ..
                _U('webhookRewardI') ..
                itemName)
        end

        if Config.grafanalog then
            lib.logger(src, 'BCC BIN Reward', "BCC Bin: Player " .. character.firstname .. ' ' .. character.lastname .. ' used a bin and recevied a item.', 'PID: ' .. source, 'Logged Discord ID: ' .. playerDisocrdID, 'Logged License Key: ' .. playerLicenseKey, 'Reward: ' .. itemName)
        end
        if Config.notify == 'ox' then
            lib.notify(src, {description = _U('itemfound') .. ' ' .. itemLabel, duration = 4000, type = 'success', position = 'center-right'}) 
        elseif Config.notify == 'vorp' then
            VORPcore.NotifyRightTip(src, _U('itemfound') .. ' ' .. itemLabel, 4000)
        end

    else
        local randomWeapons = Rewards.RandomWeapons
        local randomWeaponCalc = math.random(1, #randomWeapons)
        local randomWeapon = randomWeapons[randomWeaponCalc]

        local canCarryWeapon = exports.vorp_inventory:canCarryWeapons(src, 1, nil, randomWeapon)
        if not canCarryWeapon then
            if Config.notify == 'ox' then
                lib.notify(src, {description = _U('noSpace'), duration = 4000, type = 'error', position = 'center-right'}) 
            elseif Config.notify == 'vorp' then
                VORPcore.NotifyRightTip(src, _U('noSpace'), 4000)
            end
            goto END
        end
        exports.vorp_inventory:createWeapon(src, randomWeapon)

        if Config.discordlog then
            Discord:sendMessage(_U('webhookName') ..
                character.firstname ..
                ' ' ..
                character.lastname ..
                _U('webhookIdentifier')
                .. character.identifier ..
                _U('webhookRewardW') ..
                randomWeapon)
        end

        if Config.grafanalog then
            lib.logger(src, 'BCC BIN Reward', "BCC Bin: Player " .. character.firstname .. ' ' .. character.lastname .. ' used a bin and received a weapon.', 'PID: ' .. source, 'Logged Discord ID: ' .. playerDisocrdID, 'Logged License Key: ' .. playerLicenseKey, 'Reward: ' .. randomWeapon)
        end

        if Config.notify == 'ox' then
            lib.notify(src, {description = _U('weaponfound') .. randomWeapon, duration = 4000, type = 'error', position = 'center-right'}) 
        elseif Config.notify == 'vorp' then
            VORPcore.NotifyRightTip(src, _U('weaponfound') .. randomWeapon, 4000)
        end
    end
    ::END::
    SetPlayerCooldown('useBin', charid)
    UpdateLocation()
end)

VORPcore.Callback.Register('bcc-bin:CheckPlayerCooldown', function(source, cb, type)
    local src = source
    local user = VORPcore.getUser(src)
    if not user then return cb(false) end
    local character = user.getUsedCharacter
    local cooldown = Config.cooldown[type]
    local onList = false
    local typeId = type .. tostring(character.charIdentifier)

    for id, time in pairs(CooldownData) do
        if id == typeId then
            onList = true
            if os.difftime(os.time(), time) >= cooldown * 60 then
                cb(false) -- Not on Cooldown
                break
            else
                cb(true)
                break
            end
        end
    end
    if not onList then
        cb(false)
    end
end)

-- Version check
BccUtils.Versioner.checkFile(GetCurrentResourceName(), 'https://github.com/BryceCanyonCounty/bcc-bin')
