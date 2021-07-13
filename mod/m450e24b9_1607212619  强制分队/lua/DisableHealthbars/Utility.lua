kClientDamageColor = 1
kClientDamageOpacity = 1
function ApplyDamageColorSettings()
    kClientDamageColor =   Client.GetOptionInteger( "damageColor", 1 ) -- 1=default, 2=colorblind, 3=use old ugly useless colors 
    kClientDamageOpacity = Client.GetOptionFloat( "damageOpacity", 1)
end
