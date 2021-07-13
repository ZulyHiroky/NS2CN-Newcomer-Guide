local Plugin = {}

Plugin.NotifyPrefixColour = {
    0, 225, 35
}

function Plugin:SetupDataTable()

  Plugin:AddTranslatedNotify(  "SWITCHINGPLAYERS", {
        SwitchName_1 = self:GetNameNetworkField(),
        SwitchName_2 = self:GetNameNetworkField()
  } )

  Plugin:AddTranslatedNotify(   "SWITCHPLAYER", {
        SwitchName = self:GetNameNetworkField()
  } )

  Plugin:AddTranslatedNotify(   "FEEDBACKMESSAGE1", {
        RequestName = self:GetNameNetworkField()
  } )

end

Shine:RegisterExtension( "switchteams", Plugin )
