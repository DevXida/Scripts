
------MAIN KEYS-------
local comboKey   = 0x20 --- // SPACEBAR
local harassKey  = 0x43 --- // C
local clearKey   = 0x56 --- // V
local lasthitKey = 0x58 --- // X
----ADDITIONAL KEYS----
local insecKey   = 0x54 --- // T

require 'GeometryLib'

Vayne = {}

function OnLoad()

    if myHero.charName ~= "Vayne" then return end

    Vayne:Init()
end

function Vayne:Init()

  self.Q = {
    slot = myHero.spellbook:Spell(SpellSlot.Q),
    ready = function() return myHero.spellbook:CanUseSpell(0) == 0 end,
    range = 300,
    tumblePositions = {}
  }

  self.W = {
    slot = myHero.spellbook:Spell(SpellSlot.W)
  }

  self.E = {
      slot = myHero.spellbook:Spell(SpellSlot.E),
      ready = function() return myHero.spellbook:CanUseSpell(0) == 0 end,
      range = 550,
      condemnTable = {},
    }

    self.R = {
        slot = myHero.spellbook:Spell(SpellSlot.R),
        ready = function() return myHero.spellbook:CanUseSpell(0) == 0 end,
        invis = false, invisStartTick = 0
      }

      AddEvent(Events.OnTick, function() self:OnTick() end)
      AddEvent(Events.OnDraw, function() self:OnDraw() end)
      AddEvent(Events.OnBasicAttack, function() self:OnBasicAttack() end)
      AddEvent(Events.OnBuffGain, function(Obj, Buff) self:OnBuffGain(Obj, Buff) end)
      AddEvent(Events.OnBuffLost, function(Obj, Buff) self:OnBuffLost(Obj, Buff) end)

  PrintChat("<b><font color=\"#C70039\">Xida Vayne</font></b> <font color=\"#ffffff\">Loaded. Enjoy the mayhem</font>")
end

function Vayne:OnTick()

  if myHero.isDead then return end

  if IsKeyDown(comboKey) then

    if self.R.ready() then
      for k, v in pairs(self:GetEnemies(900)) do
          local autoattackDamage = myHero.characterIntermediate.baseAttackDamage

          if v.health <= autoattackDamage * 5 and v.health >= autoattackDamage * 3 then
            myHero.spellbook:CastSpell(SpellSlot.R, myHero.networkId)
          end
      end
    end
  end


  if self.E.ready() then
     for k, v in pairs(ObjectManager:GetEnemyHeroes()) do
      if v.isVisible
      and not v.isDead
      and v.isValid
      and self:GetDistance(myHero.position, v.position) < 550 then


        local targetPos = v.position
        local path = v.aiManagerClient.navPath

        local positionAfter = targetPos + (targetPos - Vector(path[2])):normalized() * v.characterIntermediate.movementSpeed * 0.5
          for i = 15, 475, 75 do

             local pos1 = Vector(v.position + (v.position - myHero.position):normalized() * i)
                PrintChat("1")
              --local pos2 = positionAfter + (positionAfter - myHero.position):normalized() * i
               PrintChat("2")
              if not path.isMoving then
                --pos2 = nil
              end

              if self:IsWall(pos1)  then
                DrawHandler:Circle3D(pos1, 100, 0xff00ffff)
                --DrawHandler:Circle3D(pos2, 50, self:Hex(255, 0, 255, 0))

                myHero.spellbook:CastSpell(E, v.networkId)

              end
          end
      end
     end
  end
end

function Vayne:OnDraw()
  if self.Q.tumblePositions ~= nil then

    for k, v in pairs(self.Q.tumblePositions) do
      DrawHandler:Circle3D(D3DXVECTOR3(v.x, v.y, v.z), 30, 0xff00ffff)
    end
  end
end

function Vayne:OnBasicAttack(Source, Spell)


  if not self.Q.ready then return end

  if IsKeyDown(harassKey) or IsKeyDown(comboKey) then
  for k, v in pairs(self:GetEnemies(900)) do
        self:CastQ(v, true)
    end
  end

  if IsKeyDown(lasthitKey) or IsKeyDown(clearKey) then

  end
end

function Vayne:CastQ(target, toEPosition)
  local toEPosition = toEPosition or false
  local tumblePosition = nil
  self.Q.tumblePositions = {}

  --local wallPos = self:GetWallPosition(target, 140)
  --local qToEPos = self:GetWallPosition(target, 200)
  local kitePos = self:GetKitePosition(target)

  local targetPosition = Vector(target.position)
  local myPosition = Vector(myHero.position)

  if wallPos then
     PrintChat("EH")
      tumblePosition = wallPos

  elseif self.E.ready and toEPosition and qToEPos then
       PrintChat("???")

      local pos = targetPosition + (targetPosition - qToEPos):normalized() * 100
      if self:GetDistance(myHero.position, pos) < self.Q.range then
          tumblePosition = pos
      end


  elseif self:GetDistance(myPosition, targetPosition) > myHero.characterIntermediate.attackRange + 70 then
     PrintChat("?????")
      tumblePosition = targetPosition

  elseif kitePos ~= nil then
      tumblePosition = kitePos
  end


  if tumblePosition == nil then return end
   myHero.spellbook:CastSpell(SpellSlot.Q, D3DXVECTOR3(tumblePosition.x, tumblePosition.y, tumblePosition.z))
end

function Vayne:OnBuffGain(Obj, Buff)

  if Obj.networkId ~= myHero.networkId or string.lower(Buff.name) ~= "vaynetumblefade" then return end
  self.R.invis = true
  self.R.invisStartTick = GetTickCount()
end

function Vayne:OnBuffLost(Obj, Buff)

  if Obj.networkId ~= myHero.networkId or string.lower(Buff.name) ~= "vaynetumblefade" then return end
   self.R.invis = false
end

function Vayne:GetWallPosition(target, range)
    local targetPosition = target.position

    for i = 0, 360, 45 do
        local angle = i * (math.pi/180)
        local targetRotated = D3DXVECTOR3(targetPosition.x + range, targetPosition.y, targetPosition.z)
        local pos = self:RotateAroundPoint(targetRotated, targetPosition, angle)
        if self:IsWall(pos) and self:GetDistance(myHero.position, pos) < range then
            return pos
        end
    end
end

function Vayne:GetKitePosition(target)

    local playerPos = myHero.position
    local tPos  = target.position

  for i = 0, 360, 45 do

    local angle = i * (math.pi/180)

    local rot = self:RotateAroundPoint(tPos, playerPos, angle)
    local pos = Vector(playerPos + (playerPos - rot):normalized() * self.Q.range)
    table.insert(self.Q.tumblePositions, pos)

      for k,v in pairs(self:GetEnemies(900)) do
        local dist = self:GetDistance(v.position, pos) / 2

        if (dist < 350 and dist > 240) then
           return pos
         end
        end
      end
    return nil
  end

function Vayne:GetEnemies(range)
  local t = {}
  for k, v in pairs(ObjectManager:GetEnemyHeroes()) do

      if range > self:GetDistance(myHero.position, v.position) then
        table.insert(t, v)
    end
  end
  return t
end

function Vayne:RotateAroundPoint(v1,v2, angle)
     cos, sin = math.cos(angle), math.sin(angle)
     x = ((v1.x - v2.x) * cos) - ((v2.z - v1.z) * sin) + v2.x
     z = ((v2.z - v1.z) * cos) + ((v1.x - v2.x) * sin) + v2.z
    return Vector(x or 0, v1.y or 0, z or 0)
end

function Vayne:IsWall(pos)
  flag = NavMesh:GetCollisionFlags(pos) -- <-- BROKEN? (BUGSPLATS)
  return flag == 2 or flag == 70
end

function Vayne:CalculPhysicDamage(target, source, dmg)

  local result = nil
  local baseArmor = target.characterIntermediate.armor
  local Lethality = source.characterIntermediate.physicalLethality * (0.6 + 0.4 * source.experience.level / 18)
  baseArmor = baseArmor - Lethality

  if baseArmor < 0 then baseArmor = 0 end
  if (baseArmor >= 0 ) then
    local armorPenetration = source.characterIntermediate.percentArmorPenetration
    local armor = baseArmor - ((armorPenetration*baseArmor) / 100)
    result = dmg * (100 / (100 + armor))
  end

  return (result - target.attackShield)
end

function Vayne:GetDistance(p1, p2)
    return math.sqrt(self:GetDistanceSqr(p1, p2))
end

function Vayne:GetDistanceSqr(p1, p2)
  p2 = p2 or mh
  p1 = p1.position or p1
  p2 = p2.position or p2
  local dx = p1.x - p2.x
  local dz = p1.z - p2.z
  return dx*dx + dz*dz
end
