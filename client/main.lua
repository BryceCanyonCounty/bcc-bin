VORPutils = {}
TriggerEvent("getUtils", function(utils)
    VORPutils = utils
end)

local progressbar = exports.vorp_progressbar:initiate()
local currentIndex = 1

RegisterNetEvent("vorp:SelectedCharacter")
AddEventHandler("vorp:SelectedCharacter", function()
    SpawnBin()
end)



CreateThread(function()
    local PromptGroup = VORPutils.Prompts:SetupPromptGroup()
    local firstprompt = PromptGroup:RegisterPrompt(_U("search"), 0x760A9C6F, 1, 1, true, 'hold',
        { timedeventhash = "SHORT_TIMED_EVENT_MP" })

    while true do
        Wait(1)
        local sleep = true
        local distance = GetEntityCoords(PlayerPedId())
        local check = Citizen.InvokeNative(0xBFA48E2FF417213F, distance.x, distance.y, distance.z, 1.5,
            GetHashKey(Config.SetupBin.object), 0)
        if check then
            sleep = false
            PromptGroup:ShowGroup(_U("bin"))
            if firstprompt:HasCompleted() then
                ProgBar()
                Anim()
                TriggerServerEvent('bcc-bin:Reward')
                firstprompt:TogglePrompt(false)
                Wait(Config.SetupBin.BinDuration)
                firstprompt:TogglePrompt(true)
            end
        end
        if sleep then
            Wait(1500)
        end
    end
end)

function SpawnBin()
    local model = GetHashKey(Config.SetupBin.object)
    local data = Config.RandomLocations[currentIndex]

    if data then
        local obj = VORPutils.Objects:Create(model, data.coords.x, data.coords.y, data.coords.z, 0, true, 'standard')

        Wait(Config.SetupBin.BinDuration)
        obj:Remove()

        currentIndex = currentIndex % #Config.RandomLocations + 1
        SpawnBin()
    end
end

function ProgBar()
    progressbar.start(_U("progressbar"), 6000, function()
    end, 'innercircle')
end

function Anim()
    RequestAnimDict("amb_work@world_human_bartender@serve_player")
    while not HasAnimDictLoaded("amb_work@world_human_bartender@serve_player") do
        Wait(100)
    end
    TaskPlayAnim(PlayerPedId(), "amb_work@world_human_bartender@serve_player", "take_beer_trans_pour_whiskey", 8.0, 8.0,
        100000000000000, 1, 0, true, 0, false, 0, false)
    Wait(6000)
    StopAnimTask(PlayerPedId(), "amb_work@world_human_bartender@serve_player", "take_beer_trans_pour_whiskey")
end
