pbzs_heatmap = {}
pbzs_timer = 0

local function pbzs_main()
    pbzs_heatmap()
    
    --spawn zombies every 4-8 hours
    math.randomseed(os.time())
    pbzs_timer = pbzs_timer + math.random(1,2)
    if pbzs_timer >= 8 then
        pbzs_timer = 0
        pbzs_spawn()
    end
end

local function pbzs_heatmap()
    --get locations of players
    local playerLocation = player:getCell()
    if playerLocation == nil then
        return
    end

    -- calculate which cells to add heat to
    local add_10, add_05, add_03, add_02, add_01 = pbzs_calculatecells(playerLocation);

    --increment the affected cells
    pbzs_heatmap[add_10] = (pbzs_heatmap[add_10] or 0) + 10
    for _, add in ipairs(add_05) do
        pbzs_heatmap[add] = (pbzs_heatmap[add] or 0) + 5
    end
    for _, add in ipairs(add_03) do
        pbzs_heatmap[add] = (pbzs_heatmap[add] or 0) + 3
    end
    for _, add in ipairs(add_02) do
        pbzs_heatmap[add] = (pbzs_heatmap[add] or 0) + 2
    end
    for _, add in ipairs(add_01) do
        pbzs_heatmap[add] = (pbzs_heatmap[add] or 0) + 1
    end
end

local function pbzs_calculatecells(playerLocation)
    local x = playerLocation[1]
    local y = playerLocation[2]
    local add_10 = playerLocation
    local add_05 = {{x+1,y},{x-1,y},{x,y+1},{x,y-1}}
    local add_03 = {{x+1,y+1},{x-1,y-1},{x-1,y+1},{x+1,y-1},{x+2,y},{x-2,y},{x,y+2},{x,y-2}}
    local add_02 = {{x+2,y+1},{x-2,y-1},{x-2,y+1},{x+2,y-1},{x-1,y+2},{x+1,y-2},{x+1,y+2},{x-1,y-2}}
    local add_01 = {{x+2,y+2},{x-2,y-2},{x-2,y+2},{x+2,y-2}}

    --create arrays with the cells that will get each level of heat increase (74 total in this configuration)
    --01,02,03,02,01
    --02,03,05,03,02
    --03,05,10,05,03
    --02,03,05,03,02
    --01,02,03,02,01
    
    return add_10, add_05, add_03, add_02, add_01;
end

local function pbzs_spawn(heat, population_multiplier, peak_multiplier, peak_day)
    --get locations of players
    local playerLocation = player:getCell()
    if playerLocation == nil then
        return
    end

    --spawn zombies where the player is based on the heat map and game settings
    --calls public variables PopulationMultiplier, PopulationPeakMultiplier, and PopulationPeakDay
    day = getDaysSinceStart()
    peak_percentage = day/PopulationPeakDay;
    peak_percentage_multiplier = math.min(unpack({1, peak_percentage}));
    for _, pbzs_hot_spots in ipairs(pbzs_heatmap) do
        --get zombie count to add
        local zombie_count = math.ceil((heat*PopulationMultiplier*PopulationPeakMultiplier*peak_percentage_multiplier)/10);

        --get grid square in each cell
        pbzs_location = pbzs_hot_spots.CellGetSquare()
        pbzs_x = pbzs_location[1]
        pbzs_y = pbzs_location[2]

        --spawn zombies
        addZombiesInOutfit(pbzs_x, pbzs_y, 0, zombie_count, outfit, 50);
    end
end

Events.EveryHours.Add(pbzs_main)