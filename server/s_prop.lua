---------------------------------
-- TO CHANGE --
AddEvent("OnPlayerJoin", function(playerid)
    Player:New(playerid,{playerid = playerid, team = PLAYER_TEAM_PROP})
end)
---------------------------------


local function addPlayerObject(playerid, object)
    local player = Player:GetPlayerFromId(playerid)
    local ox,oy,oz = GetObjectLocation(object)
    local newObject = CreateObject(GetObjectModel(object), ox, oy, oz)
    if (newObject ~= false) then
        for _, id in pairs(GetAllPlayers()) do
            CallRemoteEvent(id,"HidePlayerProp", playerid)
        end
        SetObjectPropertyValue(newObject,PLAYER_PROPERTY_VALUE,playerid,true)
        CallRemoteEvent(playerid,"UpdatePlayerObject", newObject)
        player:SetObject(newObject)
    end
end
AddRemoteEvent("AddPlayerObject", addPlayerObject)


local function updatePlayerObject(playerid, playerObject, object)
    local player = Player:GetPlayerFromId(playerid)
    local updatedObject = SetObjectModel(playerObject,GetObjectModel(object))
    if (updatedObject ~= false) then
        CallRemoteEvent(playerid,"UpdatePlayerObject", playerObject)
        player:SetObject(playerObject)
    end
end
AddRemoteEvent("UpdatePlayerObject", updatePlayerObject)

local function Move( playerid, object, cameraDirection,objectHeight)
    local x,y,z = GetPlayerLocation(playerid)
    
    -- These conditions do not support objects that are positioned from their center of gravity (ex objectId: 1,2,157,340,341,...)
    -- They only work with objects that are positioned from their lowest point (ex objectId: 503,504,513,...)
    if(objectHeight <= 70)then
        SetObjectLocation(object,x,y,z-objectHeight/2-1)
    else
        SetObjectLocation(object,x,y,z-objectHeight/2+1)
    end

    SetObjectRotation(object, 0.0, cameraDirection, 0)
end
AddRemoteEvent("Move",Move)


local function resetPlayerObject(playerid)
    local player = Player:GetPlayerFromId(playerid)
    player:Reset()
end
AddRemoteEvent("ResetPlayerObject", resetPlayerObject)
AddEvent("OnPlayerDeath",resetPlayerObject)
AddEvent("OnPlayerQuit", resetPlayerObject)

AddRemoteEvent("ChangeTeam", function (playerid, team)
    local player = Player:GetPlayerFromId(playerid)
    player:Reset()
    player:SetTeam(team)
    AddPlayerChat(playerid,"You are "..team)
end)

AddEvent("OnPlayerWeaponShot", function(player, weapon, hittype, hitid)
    local playerHittedId = GetObjectPropertyValue(hitid, PLAYER_PROPERTY_VALUE)
    local playerShooter = GetPlayerPropertyValue(player, PLAYER_PROPERTY_VALUE)

    if playerShooter == nil then return true end

    -- Disallow props damages
    if playerShooter.team == PLAYER_TEAM_PROP then
        return false
    elseif playerShooter.team == PLAYER_TEAM_HUNTER then

        -- Allow Hunters to tk and deal damage on props
        if hittype == HIT_OBJECT then
            if playerHittedId == nil then
                SetPlayerHealth(player, GetPlayerHealth(player)-WEAPONS_DATA[weapon].damage)
            else
                SetPlayerHealth(playerHittedId, GetPlayerHealth(playerHittedId)-WEAPONS_DATA[weapon].damage)
            end
        end
    end
end)