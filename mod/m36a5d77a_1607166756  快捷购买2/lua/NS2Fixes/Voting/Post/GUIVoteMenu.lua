
function GUIVoteMenu:SendKeyEvent(key, down)

    local voteId = GetCurrentVoteId()
    if down and voteId > 0 and (not self.timeLastVoted or Shared.GetTime() > self.timeLastVoted + 0.5) then
    
        if GetIsBinding(key, "VoteYes") then
        
            self.votedYes = true
            self.timeLastVoted = Shared.GetTime()
            SendVoteChoice(true)
            self.lastVotedId = voteId
            
            return true
            
        elseif GetIsBinding(key, "VoteNo") then
        
            self.votedYes = false
            self.timeLastVoted = Shared.GetTime()
            SendVoteChoice(false)
            self.lastVotedId = voteId
            
            return true
            
        end
        
    end
    
    return false
    
end