
local function pbzs_main()
	pbzs_heatmap()
    pbzs_spawn()
end

pbzs_heatmap = {}

local function pbzs_heatmap()
    --get locations of players
    local playerLocation = player:getCell()
    if playerLocation == nil then
        return
    end

    -- calculate which cells 
    local add_10, local add_05, local add_03, local add_02, local add_01 = pbzs_calculatecells(playerLocation)

    --increment the affected cells
    pbzs_heatmap[add_10] = pbzs_heatmap[add_10] + 10
    for add in add_05:
        pbzs_heatmap[add] = pbzs_heatmap[add] + 5
    end
    for add in add_03:
        pbzs_heatmap[add] = pbzs_heatmap[add] + 3
    end
    for add in add_02:
        pbzs_heatmap[add] = pbzs_heatmap[add] + 2
    end
    for add in add_01:
        pbzs_heatmap[add] = pbzs_heatmap[add] + 1
    end
end

local function pbzs_calculatecells(playerLocation)
    local x = playerLocation[0]
    local y = playerLocation[1]
    local add_10 = playerLocation
    local add_05 = {{x+1,y},{x-1,y},{x,y+1},{x,y-1}}
    local add_03 = {{x+1,y+1},{x-1,y-1},{x-1,y+1},{x+1,y-1},{x+2,y},{x-2,y},{x,y+2},{x,y-2}}
    local add_02 = {{x+2,y+1},{x-2,y-1},{x-2,y+1},{x+2,y-1},{x-1,y+2},{x+1,y-2},{x+1,y+2},{x-1,y-2}}
    local add_01 = {{x+2,y+2},{x-2,y-2},{x-2,y+2},{x+2,y-2}}
    return add_10, add_05, add_03, add_02, add_01
end

    --create arrays with the cells that will get each level of heat increase (74 total in this configuration)
    --01,02,03,02,01
    --02,03,05,03,02
    --03,05,10,05,03
    --02,03,05,03,02
    --01,02,03,02,01

local function pbzs_spawn(heat, population_multiplier, peak_multiplier, peak_day)
    --spawn zombies where the player is based on the heat map and game settings
    local zombie_count = math.ceil(heat*(population)*(peak(peak_day-day OR 1))/10)

Events.EveryHours.Add(pbzs_main)