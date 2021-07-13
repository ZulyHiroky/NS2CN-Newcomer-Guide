Cyst.kInfestationGrowRateMultiplier = 3
Cyst.kInfestationRecideRateMultiplier = 3

local networkVars = {}

function Cyst:GetIsFlameableMultiplier()
    return 4
end

function Cyst:GetInfestationRateMultiplier(shrinking)
    if shrinking then
        return self:GetIsCatalysted() and Cyst.kInfestationRecideRateMultiplier * 0.25 or Cyst.kInfestationRecideRateMultiplier
    end

    return Cyst.kInfestationGrowRateMultiplier * (GetHasTech(self, kTechId.ShiftHive) and 1.25 or 1)
end

function Cyst:ModifyDamageTaken(damageTable, attacker, doer, damageType, hitPoint, weapon)
    
    if doer and doer:GetClassName() == "Grenade" then
        damageTable.damage = damageTable.damage * 0.5
    end
    
end

function Cyst:GetAutoBuildRateMultiplier()
    if GetHasTech(self, kTechId.ShiftHive) then
        return 1.33
    end

    return 1
end

function Cyst:GetMatureMaxArmor()
    if GetHasTech(self, kTechId.CragHive) then
        return 50
    end

    return kMatureCystArmor

end 

Shared.LinkClassToMap("Cyst", Cyst.kMapName, networkVars)