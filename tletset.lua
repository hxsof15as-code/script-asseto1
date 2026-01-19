local sim = ac.getSim()
local counter = 0
local delayTime = 8.0
local lastPress = -delayTime
local disabledCollision = false
local teleportTimer = 0
local collisionDuration = 10 -- 10 seconds no collision after teleport

function script.update(dt)
    counter = counter + dt
    ac.log("Counter: " .. counter)
    
    local campossdir = ac.getCameraForward()
    local camposs = ac.getCameraPosition()
    
    -- ═══════════════════════════════════════════════════════════
    -- التليبورت بالكاميرا
    -- ═══════════════════════════════════════════════════════════
    if ac.isKeyDown(9) and counter < delayTime then
        return
    end
    
    if ac.isKeyDown(9) and counter >= delayTime then
        -- تليبورت السيارة لموقع الكاميرا
        physics.setCarPosition(0, camposs, -campossdir)
        physics.setCarVelocity(0, vec3(0, 0, 0)) -- إيقاف السرعة
        
        -- تفعيل نظام تعطيل التصادم
        if physics.disableCarCollisions ~= nil then
            physics.disableCarCollisions(0, true)
            disabledCollision = true
            teleportTimer = 0
            ac.log("[CameraTeleport] Collisions disabled for 10 seconds")
        end
        
        counter = 0
        lastPress = counter
    end
    
    -- ═══════════════════════════════════════════════════════════
    -- نظام إعادة تفعيل التصادم
    -- ═══════════════════════════════════════════════════════════
    if disabledCollision then
        teleportTimer = teleportTimer + dt
        
        if teleportTimer >= collisionDuration then
            local tooClose = false
            local playerCar = ac.getCar(0)
            
            -- فحص المسافة من السيارات الأخرى
            for i = 1, sim.carsCount - 1 do
                local otherCar = ac.getCar(i)
                if otherCar.isConnected then
                    local distance = playerCar.position:distance(otherCar.position)
                    if distance < 10 then
                        tooClose = true
                        teleportTimer = teleportTimer - 1 -- تأخير ثانية إضافية
                        ac.log("[CameraTeleport] Too close to other cars, delaying collision enable")
                        break
                    end
                end
            end
            
            -- إعادة تفعيل التصادم إذا كانت المسافة آمنة
            if not tooClose then
                if physics.disableCarCollisions ~= nil then
                    physics.disableCarCollisions(0, false)
                    disabledCollision = false
                    ac.log("[CameraTeleport] Collisions re-enabled")
                end
            end
        end
    end
end
