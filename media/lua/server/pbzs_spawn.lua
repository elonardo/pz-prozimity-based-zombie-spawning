pbzs = pbzs
pbzs_heatmap = {}

local function pbzs_spawn()    
    --get the days elapsed and the population peak day to calculate what percentage of the peak multiplier should be applied
    day = GameTime.getInstance():getDaysSurvived()
    local PopulationPeakDay = SandboxOptions.getInstance():getOptionByName("ZombieConfig.PopulationPeakDay"):getValue()
    peak_percentage = ((1 + day)/PopulationPeakDay)
    peak_percentage_multiplier = math.min(unpack({1, peak_percentage}))
    --get the population peak multiplier and population multiplier
    local PopulationPeakMultiplier = SandboxOptions.getInstance():getOptionByName("ZombieConfig.PopulationPeakMultiplier"):getValue()
    local PopulationMultiplier = SandboxOptions.getInstance():getOptionByName("ZombieConfig.PopulationMultiplier"):getValue()

    for key, value in pairs(pbzs_heatmap) do
        --get zombie count to add
        local zombie_count = math.ceil((value*PopulationMultiplier*PopulationPeakMultiplier*peak_percentage_multiplier)/10)
        print(value)
        print(zombie_count)
        print(key[1])
        print(key[2])
        
        --spawn zombies
        if ((key[1] == not nil) and (key[2] == not nil) and (zombie_count > 0)) then
            addZombiesInOutfit(key[0], key[1], 0, zombie_count, outfit, 50)
        end

        --reduce heat, and close out 0 value cells
        pbzs_heatmap[key] = pbzs_heatmap[key] - 1
        if pbzs_heatmap[key] < 1 then
            pbzs_heatmap[key] = nil
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
    
    --get points around the players location to add heat to
    local add_10 = {player_x,player_y}
    local add_05 = {{player_x+300,player_y},{player_x-300,player_y},{player_x,player_y+300},{player_x,player_y-300}}
    local add_03 = {{player_x+300,player_y+300},{player_x-300,player_y-300},{player_x-300,player_y+300},{player_x+300,player_y-300},{player_x+600,player_y},{player_x-600,player_y},{player_x,player_y+600},{player_x,player_y-600}}
    local add_02 = {{player_x+600,player_y+300},{player_x-600,player_y-300},{player_x-600,player_y+300},{player_x+600,player_y-300},{player_x-300,player_y+600},{player_x+300,player_y-600},{player_x+300,player_y+600},{player_x-300,player_y-600}}
    local add_01 = {{player_x+600,player_y+600},{player_x-600,player_y-600},{player_x-600,player_y+600},{player_x+600,player_y-600}}

    pbzs_heatmap[add_10] = 10
    for key, value in ipairs(add_05) do
        pbzs_heatmap[value] = 5
    end
    for key, value in ipairs(add_03) do
        pbzs_heatmap[value] = 3
    end
    for key, value in ipairs(add_02) do
        pbzs_heatmap[value] = 2
    end
    for key, value in ipairs(add_01) do
        pbzs_heatmap[value] = 1
    end
    return player_cell
end

local function pbzs_main()
    --every hour, get the players location, add heat to the area around the player, and spawns zombies everywhere there's heat
    for pbzs_playerindex = 0, getNumActivePlayers() - 1 do
        local pbzs_player = getSpecificPlayer(pbzs_playerindex)
        local player_cell = pbzs_add_heat(pbzs_player)
        pbzs_spawn()
    end
    print("success!")
end

Events.EveryHours.Add(pbzs_main)