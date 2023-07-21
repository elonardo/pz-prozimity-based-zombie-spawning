pbzs = pbzs
pbzs_heatmap = {}
pbzs_heatmap_y = {}
pbzs_sleeping_hours = 0

local function pbzs_spawn(pbzs_player)
    --get the days elapsed and the population peak day to calculate what percentage of the peak multiplier should be applied
    local day = GameTime.getInstance():getDaysSurvived()
    local PopulationPeakDay = SandboxOptions.getInstance():getOptionByName("ZombieConfig.PopulationPeakDay"):getValue()
    local peak_percentage = ((1 + day)/PopulationPeakDay)
    local peak_percentage_multiplier = math.min(unpack({1, peak_percentage}))

    --get the population peak multiplier and population multiplier
    local PopulationPeakMultiplier = math.max(SandboxOptions.getInstance():getOptionByName("ZombieConfig.PopulationPeakMultiplier"):getValue() - 1, 0)
    local PopulationMultiplier = SandboxOptions.getInstance():getOptionByName("ZombieConfig.PopulationMultiplier"):getValue()

    for key, value in pairs(pbzs_heatmap) do
        local x = key
        for key, value in pairs(pbzs_heatmap[x]) do
            local y = key
            local heat = pbzs_heatmap[x][y]

            --get zombie count to add. Cannot be less than 0 or more than 50 per hour
            local zombie_count = math.min(math.max(math.ceil(-4+2^(heat/24)), 0),50)
            print("zombie count: ", zombie_count)

            --spawn zombies
            if zombie_count > 0 then
                --get coordinates of a random square in the cell at which to spawn zombies
                local random1 = ZombRandBetween(1,299)
                local random2 = ZombRandBetween(1,299)
                local spawn_x = x * 300 + random1
                local spawn_y = y * 300 + random2

                for i = 1, zombie_count do
                    addZombiesInOutfit(spawn_x, spawn_y, 0, zombie_count, outfit, 50)
                    --getVirtualZombieManager():createRealZombie(spawn_x, spawn_y, 0)
                end
            end

            --reduce heat, and close out 0 value cells
            pbzs_heatmap[x][y] = pbzs_heatmap[x][y] - 1
            if pbzs_heatmap[x][y] < 1 then
                pbzs_heatmap[x][y] = nil
                table.remove(pbzs_heatmap[x], y)
                if pbzs_heatmap[x] == nil then
                    table.remove(pbzs_heatmap, x)
                end
            end
        end
    end
end

local function pbzs_get_player_xyz(pbzs_player)
    local player_cell = pbzs_player:getCell()
    local player_x = math.floor(pbzs_player:getX())
    local player_y = math.floor(pbzs_player:getY())
    local player_z = math.floor(pbzs_player:getZ())

    return player_cell, player_x, player_y, player_z
end

local function pbzs_add_heat(pbzs_player)
    local player_cell, player_x, player_y, player_z = pbzs_get_player_xyz(pbzs_player)
    
    --get cell coordinates from square
    player_x = math.floor(player_x/300)
    player_y = math.floor(player_y/300)

    --get points around the players location to add heat to
    local add_02 = {{player_x,player_y},{player_x+1,player_y},{player_x-1,player_y},{player_x,player_y+1},{player_x,player_y-1},{player_x+1,player_y+1},{player_x-1,player_y-1},{player_x-1,player_y+1},{player_x+1,player_y-1}}
    local add_01 = {{player_x+2,player_y},{player_x-2,player_y},{player_x,player_y+2},{player_x,player_y-2},{player_x+2,player_y+1},{player_x-2,player_y-1},{player_x-2,player_y+1},{player_x+2,player_y-1},{player_x-1,player_y+2},{player_x+1,player_y-2},{player_x+1,player_y+2},{player_x-1,player_y-2},{player_x+2,player_y+2},{player_x-2,player_y-2},{player_x-2,player_y+2},{player_x+2,player_y-2}}

    --adds heat in the following pattern:
    --01,01,01,01,01
    --01,02,02,02,01
    --01,02,02,02,01
    --01,02,02,02,01
    --01,01,01,01,01

    for key, value in ipairs(add_02) do
        local x = value[1]
        local y = value[2]
        --print(pbzs_heatmap[x])
        if type(pbzs_heatmap[x]) == "table" then
            if type(pbzs_heatmap[x][y]) == "number" then
                pbzs_heatmap[x][y] = pbzs_heatmap[x][y] + 200
                --print("add: ", x," ",pbzs_heatmap[x]," ",pbzs_heatmap[x][y])
            else
                table.insert(pbzs_heatmap[x],y,200)
                --print("new y: ", x," ",pbzs_heatmap[x]," ",pbzs_heatmap[x][y])
            end
        else
            pbzs_heatmap[x] = {}
            table.insert(pbzs_heatmap[x],y,200)
            --print("new xy: ", x," ",pbzs_heatmap[x]," ",pbzs_heatmap[x][y])
        end
    end

    for key, value in ipairs(add_01) do
        local x = value[1]
        local y = value[2]
        --print(pbzs_heatmap[x])
        if type(pbzs_heatmap[x]) == "table" then
            if type(pbzs_heatmap[x][y]) == "number" then
                pbzs_heatmap[x][y] = pbzs_heatmap[x][y] + 100
                --print("add: ", x," ",pbzs_heatmap[x]," ",pbzs_heatmap[x][y])
            else
                table.insert(pbzs_heatmap[x],y,100)
                --print("new y: ", x," ",pbzs_heatmap[x]," ",pbzs_heatmap[x][y])
            end
        else
            pbzs_heatmap[x] = {}
            table.insert(pbzs_heatmap[x],y,100)
            --print("new xy: ", x," ",pbzs_heatmap[x]," ",pbzs_heatmap[x][y])
        end
    end
end

local function pbzs_main()
    --every hour, get the players location, add heat to the area around the player, and spawn zombies
    for pbzs_playerindex = 0, getNumActivePlayers() - 1 do
        local pbzs_player = getSpecificPlayer(pbzs_playerindex)
        --check if the player is asleep, and if they are instead of spawning increment sleeping hours to increase the spawn rate when they wake up
        --WARNING: in multiplayer, if only one player sleeps this will cause problems TODO: add a check to see if game is multiplayer
        if pbzs_player:isAsleep() then
            pbzs_sleeping_hours = pbzs_sleeping_hours + 1
        else
            local i = 0
            while i <= pbzs_sleeping_hours do
                pbzs_add_heat(pbzs_player)
                pbzs_spawn(pbzs_player)
                i = i + 1
            end
        end
        pbzs_sleeping_hours = 0
        print("displaying heatmap\n")
        for key, value in pairs(pbzs_heatmap) do
            local x = key
            for key, value in pairs(pbzs_heatmap[x]) do
                local y = key
                local heat = pbzs_heatmap[x][y]
                print(x,", ",y,": ",heat,"\n")
            end
        end
        print("proximity based zombie spawning succesful")
    end
end

Events.EveryHours.Add(pbzs_main)