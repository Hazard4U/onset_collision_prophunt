---------------------------------
-- TO CHANGE --
OBJECT_DISTANCE_COPY = 300
---------------------------------

OBJECT = nil
Y_ROTATION_FIXED = nil

local function GetNearestObject()
        local x, y, z = GetPlayerLocation(GetPlayerId())
        local nearest_obj_distance = OBJECT_DISTANCE_COPY
        local nearest_obj = nil
        for _, obj in pairs(GetStreamedObjects()) do
                local ox, oy, oz = GetObjectLocation(obj)
                local distance = GetDistance3D(x, y, z, ox, oy, oz)
                if obj ~= OBJECT and distance < nearest_obj_distance then
                        SetObjectOutline(obj, true)
                        if nearest_obj ~= nil then
                                SetObjectOutline(nearest_obj, false)
                        end
                        nearest_obj = obj
                        nearest_obj_distance = distance
                else
                        SetObjectOutline(obj, false)
                end
        end
        return nearest_obj
end

local function OnGameTick()
        local playerData = GetPlayerPropertyValue(GetPlayerId(),"player")
        if playerData ~= nil and playerData.team == PLAYER_TEAM_PROP then
                GetNearestObject()
                if IsValidObject(OBJECT) then
                        local w,d,height = GetObjectSize(OBJECT)
        
                        -- I've written them here to avoid bugs but we can probably come up with something better
                        SetControllerOrientedMovement(true)
                        GetPlayerActor(GetPlayerId()):SetActorHiddenInGame(true)
                        GetObjectActor(OBJECT):SetActorEnableCollision(false)
                        
                        local x,yRotation,z
                        if Y_ROTATION_FIXED == nil then
                                x,yRotation,z = VectorToRotation(GetCameraForwardVector(), GetCameraRightVector(), 0)
                                CallRemoteEvent("Move",OBJECT,-yRotation,height)
                        else
                                CallRemoteEvent("Move",OBJECT,-Y_ROTATION_FIXED,height)
                        end
                end
        end
end
AddEvent("OnGameTick", OnGameTick)

local function OnKeyPress(key)

        -- Fix the rotation
        if key == "Left Ctrl" then
                if Y_ROTATION_FIXED == nil then
                        local x,yRotation,z = VectorToRotation(GetCameraForwardVector(), GetCameraRightVector(), 0)
                        Y_ROTATION_FIXED = yRotation
                else
                        Y_ROTATION_FIXED = nil
                end
        end

        -- Take an object
        if key == "Left Mouse Button" then
                local playerData = GetPlayerPropertyValue(GetPlayerId(),"player")
                AddPlayerChat(tostring(playerData.team))
                if playerData ~= nil and playerData.team == PLAYER_TEAM_PROP then
                        local objectId = GetNearestObject()
                        if objectId ~= nil then
                                -- If the targeted object is a player return
                                if(GetObjectPropertyValue(objectId,"player") ~= nil)then
                                        return
                                end
                                
                                if OBJECT == nil then
                                        -- First time create object
                                        CallRemoteEvent("AddPlayerObject", objectId)
                                else
                                        -- Next time update model object
                                        CallRemoteEvent("UpdatePlayerObject", OBJECT,objectId)
                                end
                        end
                end
        end

        if key == "F" then
                CallRemoteEvent("ResetPlayerObject")
                OBJECT = nil
        end

        if key == "Num 1" then
                CallRemoteEvent("ChangeTeam", PLAYER_TEAM_PROP)
                OBJECT = nil
        end


        if key == "Num 2" then
                CallRemoteEvent("ChangeTeam", PLAYER_TEAM_HUNTER)
                OBJECT = nil
        end
end
AddEvent("OnKeyPress", OnKeyPress)

local function updatePlayerObject(object)
        -- Delay to prevent object not already created by server
        Delay(50, function()
                OBJECT = object
                if OBJECT ~= nil and IsValidObject(OBJECT) then
                        local w,h,d = GetObjectSize(OBJECT)
                        GetObjectActor(OBJECT):SetActorEnableCollision(false)
                        
                        -- Match the player scale to the object
                        -- The constants 83.33, 77.74, 200 are precalculated coefficients
                        -- These are coefficients that I obtained by trying to match the player's mesh with a certain object.
                        GetPlayerActor(GetPlayerId()):SetActorScale3D(FVector(h/83.33,w/77.74,d/200))
                else
                        -- Reset player model
                        GetPlayerActor(GetPlayerId()):SetActorScale3D(FVector(1,1,1))
                        SetControllerOrientedMovement(false)     
                end
                
        end)
end
AddRemoteEvent("UpdatePlayerObject", updatePlayerObject)

-- playerId = player to hide
local function hidePlayerProp(playerId)
        GetPlayerActor(playerId):SetActorScale3D(FVector(0.001,0.001,0.001))
        TogglePlayerTag(playerId,  'name', false)
        TogglePlayerTag(playerId,  'health', false)
        TogglePlayerTag(playerId,  'armor', false)
        TogglePlayerTag(playerId,  'voice', false)
end
AddRemoteEvent("HidePlayerProp", hidePlayerProp)

-- playerId = player to show
local function showPlayerProp(playerId)
        GetPlayerActor(playerId):SetActorHiddenInGame(false)
        GetPlayerActor(playerId):SetActorScale3D(FVector(1,1,1))
        TogglePlayerTag(playerId,  'name', true)
        TogglePlayerTag(playerId,  'health', true)
        TogglePlayerTag(playerId,  'armor', true)
        TogglePlayerTag(playerId,  'voice', true)
end
AddRemoteEvent("ShowPlayerProp", showPlayerProp)
    
AddEvent("OnPlayerDeath",function()
        OBJECT = nil
end)