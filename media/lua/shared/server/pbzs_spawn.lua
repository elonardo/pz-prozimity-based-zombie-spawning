local hour = _gametime:getHour();

if hour = 12 then
    pbzs_heatmap()
    return
end

function pbzs_heatmap()
    --get locations of players
    local playerLocation = player:getCell()
    if playerLocation == nil then
        return
    end

    add_10, add_05, add_03, add_02, add_01 = pbzs_calculatecells(playerLocation)

function pbzs_calculatecells(playerLocation)
    local x = playerLocation[0]
    local y = playerLocation[1]
    add_10 = playerLocation
    add_05 = {{x+1,y},{x-1,y},{x,y+1},{x,y-1}}
    add_03 = {{x+1,y+1},{x-1,y-1},{x-1,y+1},{x+1,y-1},{x+2,y},{x-2,y},{x,y+2},{x,y-2}}
    add_02 = {{x+2,y+1},{x-2,y-1},{x-2,y+1},{x+2,y-1},{x-1,y+2},{x+1,y-2},{x+1,y+2},{x-1,y-2}}
    add_01 = {{x+2,y+2},{x-2,y-2},{x-2,y+2},{x+2,y-2}}
    return add_10, add_05, add_03, add_02, add_01

    --create arrays with the cells that will get each level of heat increase
    --01,02,03,02,01
    --02,03,05,03,02
    --03,05,10,05,03
    --02,03,05,03,02
    --01,02,03,02,01
    