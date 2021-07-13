function GetShouldHitIndicatorFixedDefault()

	local ownedBadges = Badges_GetOwnedBadges()
    local hitIndicatorFixed = true
	
	-- handschuh and ironhorse dislike the pop. Everyone else seems to love it. 
	-- As a courtesy, lets disable this for the dislikers by default.
	if ownedBadges and (ownedBadges["playtester"] or ownedBadges["dev"] or ownedBadges["community_dev"]) then
		hitIndicatorFixed = false
	end
	
	return hitIndicatorFixed
	
end