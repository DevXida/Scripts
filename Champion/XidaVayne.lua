
-----SCRIPT CONFIG-------
local comboKey  = 0x20 --- // SPACEBAR
local harassKey = 0x43 --- // C
local clearKey  = 0x56 --- // V

require 'GeometryLib'

function OnLoad()

    if myHero.charName ~= "Vayne" then return end

    Vayne:Init()
end

function Vayne:Init()

  self.Q = {
    slot = myHero.spellbook:Spell(SpellSlot.Q),
    ready = function() return myHero.spellbook:CanUseSpell(0) == 0 end,
    range = 300,
    tumblePos = nil
  }

  self.W = {
    slot = myHero.spellbook:Spell(SpellSlot.W)
  }

  self.E = {
      slot = myHero.spellbook:Spell(SpellSlot.E),
      ready = function() return myHero.spellbook:CanUseSpell(0) == 0 end,
      range = 550
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
      for k, v in pairs(ObjectManager:GetEnemyHeroes()) do
      -- Need autoattack damage
      end
    end
  end

  if self.E.ready() then
     for k, v in pairs(ObjectManager:GetEnemyHeroes()) do
      if v.isValid and self:GetDistance(v, myHero) <= self.E.range then

        targetPos = Vector(v.position.x, v.position.y, v.position.z)
        path = v.aiManagerClient.navPath.paths[1]

        positionAfter = Vector(targetPos + (targetPos - path)):normalized() * v.characterIntermediate.movementSpeed * 0.425

          for i = 15, 475, 75 do
              pos1 = Vector(targetPos + (targetPos - myHero.position):normalized() * i)
              pos2 = Vector(positionAfter + (positionAfter - myHero.position):normalized() * i)

              if not v.aiManagerClient.navPath.isMoving then
                pos2 = nil
              end

              if self:IsWall(pos1) and self:IsWall(pos2) then
                DrawHandler:Circle3D(pos1, 100, self:Hex(255, 0, 255, 0))
                DrawHandler:Circle3D(pos2, 50, self:Hex(255, 0, 255, 0))

                myHero.spellbook:CastSpell(E, v.networkId)
              else
                 DrawHandler:Circle3D(pos1, i / 10, self:Hex(255, 255, 0, 0))
                 DrawHandler:Circle3D(pos2, i / 20, self:Hex(255, 255, 0, 0))
              end
          end
      end
     end
  end
end

function Vayne:OnDraw()
  if not self.Q.ready and self.Q.tumblePos ~= nil then
    DrawHandler:Circle3D(self.Q.tumblePos, 60, self:Hex(255, 0, 204, 255))
  end
end

function Vayne:OnBasicAttack(Source, Spell)
  if Source.networkId ~= myHero.networkId
    or not self.Q.ready then return end

  if IsKeyDown(harassKey) or IsKeyDown(comboKey) then
  for k, v in pairs(ObjectManager:GetEnemyHeroes()) do
      if v.isValid and self:GetDistance(v, myHero) <= 800 then
        self:CastQ(v, true)
      end
    end
  end
end

function Vayne:CastQ(target, toEPosition)
  toEPosition = toEPosition or false

end

function Vayne:OnBuffGain(Obj, Buff)

  if string.lower(Buff.name) ~= "vaynetumblefade" or Obj ~= myHero then return end
  self.R.invis = true
  self.R.invisStartTick = GetTickCount()
end

function Vayne:OnBuffLost(Obj, Buff)

   if string.lower(Buff.name) ~= "vaynetumblefade" or Obj ~= myHero then return end
   self.R.invis = false
end

function Vayne:IsWall(pos)
  flag = NavMesh:GetCollisionFlags(pos)
    return flag == 2 or flag == 70
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

function Vayne:Hex(a,r,g,b) -- A R G B to Hex for drawings etc | Credits to Weedle
      return format("0x%.2X%.2X%.2X%.2X",a,r,g,b)
  end
