bitser = require 'bitser-master.bitser'
binser = require 'binser-master.binser'
DB = {}
DB.MAP = {
    PATH = "db/MAP.DAT",
}
local lfs = love.filesystem

function DB.mapInit()
    if not lfs.getInfo(DB.MAP.PATH) then
        print("!--! Generating Map file")
        TileMap = {}
        for x=-8, 8 do
            TileMap[x] = {}
            for y=-6, 6 do
                TileMap[x][y] = {}
                TileMap[x][y]["id"] = 1+math.floor(love.math.random()*2)
            end
        end

        DB.mapSave()
    end
end

function DB.mapLoad()
    DB.mapInit()
    if TileMap then TileMap = nil end -- REMOVES ANY LOADED TILEMAP DATA!!
    TileMap = binser.deserializeN(lfs.read(DB.MAP.PATH))
end
function DB.mapSave()
    local file = io.output(DB.MAP.PATH)
    file:write(binser.serialize(TileMap))
    file:close()
end


DB.mapLoad()
