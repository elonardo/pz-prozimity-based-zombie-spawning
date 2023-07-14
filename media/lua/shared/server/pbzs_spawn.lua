local hour = _gametime:getHour();

if hour = 12 then
    pbzs_heatmap()
    return
end

function pbzs_heatmap()
    --get locations of players
    local playerLocation = player:getCurrentSquare()
    if playerLocation == nil then
        return
    end

    