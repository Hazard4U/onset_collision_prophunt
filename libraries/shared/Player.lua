PLAYER_PROPERTY_VALUE = "player"

PLAYER_TEAM_PROP = "propsTeam"
PLAYER_TEAM_HUNTER = "hunterTeam"

Player = {
    team = nil,
    playerid = nil,
    object = nil
}

-- Used only server side
function Player:New(playerid,o)
    o = o or {} 
    setmetatable(o, self)
    self.__index = self
    SetPlayerPropertyValue(playerid, PLAYER_PROPERTY_VALUE, o, true)
    return o
end

function Player:GetPlayerFromId(playerid)
    local playerO = GetPlayerPropertyValue(playerid, PLAYER_PROPERTY_VALUE)
    setmetatable(playerO, self)
    self.__index = self
    return playerO
end

-- Not currently use, but can be usefull if you change the code
function Player:GetPlayerFromProperty(playerO)
    setmetatable(playerO, self)
    self.__index = self
    return playerO
end

-- Used only server side
function Player:SetTeam(team)
    self.team = team
    SetPlayerPropertyValue(self.playerid, PLAYER_PROPERTY_VALUE, self,true)
end

-- Used only server side
function Player:SetObject(object)
    self.object = object
    SetPlayerPropertyValue(self.playerid, PLAYER_PROPERTY_VALUE, self,true)
end

-- Used only server side
function Player:Reset()
    if(self.team == PLAYER_TEAM_PROP)then
        if(self.object ~= nil)then
            CallRemoteEvent(self.playerid, "OnUpdatePlayerObject", nil)            
            DestroyObject(self.object)
            for _, id in pairs(GetAllPlayers()) do
                CallRemoteEvent(id,"ShowPlayerProp", self.playerid)
            end
        end
    end

    self.object = self:SetObject(nil)
end

function Player:ToString()
    print(tostring(self.team))
    print(tostring(self.playerid))
end


