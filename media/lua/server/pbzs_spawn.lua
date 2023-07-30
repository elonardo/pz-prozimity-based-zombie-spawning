pbzs = pbzs
pbzs_heatmap = {}
pbzs_heatmap_y = {}
pbzs_sleeping_hours = 0
pbzs_cooldown = 2
pbzs_last_pos = {1,1,1}

local function pbzs_get_player_xyz(pbzs_player)
    local player_cell = pbzs_player:getCell()
    local player_x = math.floor(pbzs_player:getX())
    local player_y = math.floor(pbzs_player:getY())
    local player_z = math.floor(pbzs_player:getZ())

    --RV interiors fix. If player is in the area of the map where the RV interiors are, their location will be set to their last location
    if player_x > 73 then
        player_x = pbzs_last_pos[0]
        player_y = pbzs_last_pos[1]
        player_z = pbzs_last_pos[2]
    else
        pbzs_last_pos[0] = player_x
        pbzs_last_pos[1] = player_y
        pbzs_last_pos[2] = player_z
    end

    return player_cell, player_x, player_y, player_z
end

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
            local player_cell, player_x, player_y, player_z = pbzs_get_player_xyz(pbzs_player)
            --get cell coordinates from square
            local player_cell_x = math.floor(player_x/300)
            local player_cell_y = math.floor(player_y/300)

            --get zombie count to add. Cannot be less than 0 or more than 50 per hour
            local zombie_count = math.min(math.max(math.ceil(-4+(2+peak_percentage_multiplier)*2^(1+heat/240)), 0),50)
            print("zombie count: ", zombie_count)

            --spawn zombies
            if zombie_count > 0 and x == player_cell_x and y == player_cell_y then
                --get coordinates of a random square in the cell at which to spawn zombies
                local random1 = ZombRandBetween(10,50)
                local random2 = ZombRandBetween(10,50)
                local spawn_x = player_x - 90
                local spawn_y = player_y - 90
                local spawn_x2 = spawn_x + random1
                local spawn_y2 = spawn_y + random2

                spawnHorde(spawn_x, spawn_y, spawn_x2, spawn_y2, 0, zombie_count)
                print("spawned ", zombie_count, " zombies")
            end

            --reduce heat, and close out 0 value cells
            pbzs_heatmap[x][y] = pbzs_heatmap[x][y] - pbzs_cooldown
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

local function pbzs_add_heat(pbzs_player)
    local player_cell, player_x, player_y, player_z = pbzs_get_player_xyz(pbzs_player)
    
    --get cell coordinates from square
    player_x = math.floor(player_x/300)
    player_y = math.floor(player_y/300)

    --get points around the players location to add heat to
    local add_02 = {{player_x,player_y},{player_x+1,player_y},{player_x-1,player_y},{player_x,player_y+1},{player_x,player_y-1},{player_x+1,player_y+1},{player_x-1,player_y-1},{player_x-1,player_y+1},{player_x+1,player_y-1}}
    local add_01 = {{player_x+2,player_y},{player_x-2,player_y},{player_x,player_y+2},{player_x,player_y-2},{player_x+2,player_y+1},{player_x-2,player_y-1},{player_x-2,player_y+1},{player_x+2,player_y-1},{player_x-1,player_y+2},{player_x+1,player_y-2},{player_x+1,player_y+2},{player_x-1,player_y-2},{player_x+2,player_y+2},{player_x-2,player_y-2},{player_x-2,player_y+2},{player_x+2,player_y-2}}
    local add_00 = {{player_x+3,player_y},{player_x-3,player_y},{player_x,player_y+3},{player_x,player_y-3},{player_x+3,player_y+1},{player_x-3,player_y-1},{player_x-1,player_y+3},{player_x+1,player_y-3},{player_x+3,player_y+2},{player_x-3,player_y+2},{player_x+2,player_y+3},{player_x+2,player_y-3},{player_x+3,player_y-2},{player_x-3,player_y-2},{player_x-2,player_y+3},{player_x-2,player_y-3},{player_x+3,player_y-3},{player_x-3,player_y-3},{player_x+3,player_y+3},{player_x-3,player_y+3},{player_x+3,player_y+3},{player_x+3,player_y-3},{player_x-3,player_y+3},{player_x-3,player_y-3}}

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
                pbzs_heatmap[x][y] = pbzs_heatmap[x][y] + 20
                --print("add: ", x," ",pbzs_heatmap[x]," ",pbzs_heatmap[x][y])
            else
                table.insert(pbzs_heatmap[x],y,2)
                --print("new y: ", x," ",pbzs_heatmap[x]," ",pbzs_heatmap[x][y])
            end
        else
            pbzs_heatmap[x] = {}
            table.insert(pbzs_heatmap[x],y,2)
            --print("new xy: ", x," ",pbzs_heatmap[x]," ",pbzs_heatmap[x][y])
        end
    end

    for key, value in ipairs(add_01) do
        local x = value[1]
        local y = value[2]
        --print(pbzs_heatmap[x])
        if type(pbzs_heatmap[x]) == "table" then
            if type(pbzs_heatmap[x][y]) == "number" then
                pbzs_heatmap[x][y] = pbzs_heatmap[x][y] + 10
                --print("add: ", x," ",pbzs_heatmap[x]," ",pbzs_heatmap[x][y])
            else
                table.insert(pbzs_heatmap[x],y,1)
                --print("new y: ", x," ",pbzs_heatmap[x]," ",pbzs_heatmap[x][y])
            end
        else
            pbzs_heatmap[x] = {}
            table.insert(pbzs_heatmap[x],y,1)
            --print("new xy: ", x," ",pbzs_heatmap[x]," ",pbzs_heatmap[x][y])
        end
    end

    for key, value in ipairs(add_00) do
        local x = value[1]
        local y = value[2]
        --print(pbzs_heatmap[x])
        if type(pbzs_heatmap[x]) == "table" then
            if type(pbzs_heatmap[x][y]) == "number" then
                pbzs_heatmap[x][y] = pbzs_heatmap[x][y] + pbzs_cooldown
                --print("add: ", x," ",pbzs_heatmap[x]," ",pbzs_heatmap[x][y])
            else
                table.insert(pbzs_heatmap[x],y,1)
                --print("new y: ", x," ",pbzs_heatmap[x]," ",pbzs_heatmap[x][y])
            end
        else
            pbzs_heatmap[x] = {}
            table.insert(pbzs_heatmap[x],y,1)
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