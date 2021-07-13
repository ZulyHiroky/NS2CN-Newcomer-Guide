 function NS2Gamerules:UpdateAutoTeamBalance(dt)
    
        local wasDisabled = false
        
        -- Check if auto-team balance should be enabled or disabled.
        -- Disable automatically if cheats are on so you can play against more bots
        local autoTeamBalance = not Shared.GetCheatsEnabled() and Server.GetConfigSetting("auto_team_balance")
        --local autoTeamBalance = false -- disable for now
        if autoTeamBalance and autoTeamBalance.enabled then

        local enabledOnUnbalanceAmount = autoTeamBalance.enabled_on_unbalance_amount or 2
        -- Prevent the unbalance amount from being 0 or less.
        enabledOnUnbalanceAmount = enabledOnUnbalanceAmount > 0 and enabledOnUnbalanceAmount or 2
        local enabledAfterSeconds = autoTeamBalance.enabled_after_seconds or 10



         local team1Players = GetGamerules():GetTeam1():GetNumPlayers()
         local team2Players = GetGamerules():GetTeam2():GetNumPlayers()
         
local unbalancedAmount = math.abs(team1Players - team2Players)
            if unbalancedAmount >= enabledOnUnbalanceAmount then
            
                if not self.autoTeamBalanceEnabled then
                
                    self.teamsUnbalancedTime = self.teamsUnbalancedTime or 0
                    self.teamsUnbalancedTime = self.teamsUnbalancedTime + dt
                    
                    if self.teamsUnbalancedTime >= enabledAfterSeconds then

                        self.autoTeamBalanceEnabled = true
                        if team1Players > team2Players then
                            GetGamerules():GetTeam1():SetAutoTeamBalanceEnabled(true, unbalancedAmount)
                        else
                            GetGamerules():GetTeam2():SetAutoTeamBalanceEnabled(true, unbalancedAmount)
                        end
                        
                        SendTeamMessage(GetGamerules():GetTeam1(), kTeamMessageTypes.TeamsUnbalanced)
                        SendTeamMessage(GetGamerules():GetTeam2(), kTeamMessageTypes.TeamsUnbalanced)
                        Print("Auto-team balance enabled")
                        
                    end
                    
                end
                
            -- The autobalance system itself has turned itself off.
            elseif self.autoTeamBalanceEnabled then
                wasDisabled = true
            end
            
        -- The autobalance system was turned off by the admin.
        elseif self.autoTeamBalanceEnabled then
            wasDisabled = true
        end
        
        if wasDisabled then
        
            GetGamerules():GetTeam1():SetAutoTeamBalanceEnabled(false)
            GetGamerules():GetTeam2():SetAutoTeamBalanceEnabled(false)
            self.teamsUnbalancedTime = 0
            self.autoTeamBalanceEnabled = false
            SendTeamMessage(GetGamerules():GetTeam1(), kTeamMessageTypes.TeamsBalanced)
            SendTeamMessage(GetGamerules():GetTeam2(), kTeamMessageTypes.TeamsBalanced)
            Print("Auto-team balance disabled")

        end
        
    end
      