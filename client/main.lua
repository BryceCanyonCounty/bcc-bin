local VORPcore = exports.vorp_core:GetCore()

local BinGroup = GetRandomIntInRange(0, 0xffffff)
local progressbar = exports["feather-progressbar"]:initiate()
local Bin = 0

RegisterNetEvent('vorp:SelectedCharacter', function(charid)
    local location = VORPcore.Callback.TriggerAwait('bcc-bin:SetLocation')
    if location then
        TriggerEvent('bcc-bin:SpawnBin', location)
    end
end)

local function GetControlOfBin()
    while not NetworkHasControlOfEntity(Bin) do
        NetworkRequestControlOfEntity(Bin)
        Wait(10)
    end
end

RegisterNetEvent('bcc-bin:SpawnBin', function(location)
    if Bin ~= 0 then
        GetControlOfBin()
        DeleteObject(Bin)
        Bin = 0
    end

    Bin = Citizen.InvokeNative(0x509D5878EB39E842, joaat(Config.SetupBin.object), location.coords.x, location.coords.y, location.coords.z - 1, false, false, false, false, false) -- CreateObject
    PlaceObjectOnGroundProperly(Bin, true)

    if Config.blip.enable then
        local blip = Citizen.InvokeNative(0x23f74c2fda6e7c61, 1664425300, Bin) -- BlipAddForEntity
        SetBlipSprite(blip, Config.blip.sprite, true)
        Citizen.InvokeNative(0x9CB1A1623062F402, blip, Config.blip.name) -- SetBlipName
        Citizen.InvokeNative(0x662D364ABF16DE2F, blip, joaat(Config.BlipColors[Config.blip.color])) -- BlipAddModifier
    end

    if Config.oxtarget then
        exports.ox_target:addLocalEntity(Bin, {
            {
                name = 'search_bin',
                icon = 'fas fa-search',
                label = _U('search'),
                canInteract = function(entity)
                    return entity == Bin
                end,
                onSelect = function(data)
                    local onCooldown = VORPcore.Callback.TriggerAwait('bcc-bin:CheckPlayerCooldown', 'useBin')
                    if onCooldown then
                        if Config.notify == 'ox' then
                            lib.notify({description = _U('useCooldown'), duration = 4000, type = 'error', position = 'center-right'}) 
                        elseif Config.notify == 'vorp' then
                            VORPcore.NotifyRightTip(_U('useCooldown'), 4000)
                        end
                    else
                        ProgBar()
                        Anim()
                        TriggerServerEvent('bcc-bin:Reward')
                    end
                end
            }
        })
    end
end)

if not Config.oxtarget then
    CreateThread(function()
        StartPrompts()
    
        while true do
            local sleep = 1000
            local distance = GetEntityCoords(PlayerPedId())
            local check = Citizen.InvokeNative(0xBFA48E2FF417213F, distance.x, distance.y, distance.z, 1.5, joaat(Config.SetupBin.object), 0)
            if check then
                sleep = 0
                PromptSetActiveGroupThisFrame(BinGroup, CreateVarString(10, 'LITERAL_STRING', _U('bin')), 1, 0, 0, 0)
                if Citizen.InvokeNative(0xE0F65F0640EF0617, BinPrompt) then  -- PromptHasHoldModeCompleted
                    local onCooldown = VORPcore.Callback.TriggerAwait('bcc-bin:CheckPlayerCooldown', 'useBin')
                    if onCooldown then
                        if Config.notify == 'ox' then
                            lib.notify({description = _U('useCooldown'), duration = 4000, type = 'error', position = 'center-right'}) 
                        elseif Config.notify == 'vorp' then
                            VORPcore.NotifyRightTip(_U('useCooldown'), 4000)
                        end
                        goto END
                    end
                    ProgBar()
                    Anim()
                    TriggerServerEvent('bcc-bin:Reward')
                end
            end
            ::END::
            Wait(sleep)
        end
    end)
end

function StartPrompts()
    BinPrompt = PromptRegisterBegin()
    PromptSetControlAction(BinPrompt, Config.keys.search)
    PromptSetText(BinPrompt, CreateVarString(10, 'LITERAL_STRING', _U('search')))
    PromptSetVisible(BinPrompt, true)
    PromptSetEnabled(BinPrompt, true)
    PromptSetHoldMode(BinPrompt, 2000)
    PromptSetGroup(BinPrompt, BinGroup, 0)
    PromptRegisterEnd(BinPrompt)
end

function ProgBar()
    progressbar.start(_U('progressbar'), 6000, function() end, 'innercircle')
end

function Anim()
    local playerPed = PlayerPedId()

    RequestAnimDict('amb_work@world_human_bartender@serve_player')
    while not HasAnimDictLoaded('amb_work@world_human_bartender@serve_player') do
        Wait(100)
    end

    TaskPlayAnim(playerPed, 'amb_work@world_human_bartender@serve_player', 'take_beer_trans_pour_whiskey', 8.0, 8.0,
        -1, 1, 0, true, 0, false, 0, false)

    Wait(6000)

    ClearPedTasks(playerPed)
end

if Config.devMode then
    RegisterCommand('bin', function()
        local location = VORPcore.Callback.TriggerAwait('bcc-bin:SetLocation')
        if location then
            TriggerEvent('bcc-bin:SpawnBin', location)
        end
    end, false)
end

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    if Bin ~= 0 then
        DeleteObject(Bin)
        Bin = 0
    end
    ClearPedTasksImmediately(PlayerPedId())
end)
