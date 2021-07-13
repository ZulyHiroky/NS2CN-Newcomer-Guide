
kPlayerBrainTickrate = 4 -- was 10
kPlayerBrainTickFrametime = 1 / kPlayerBrainTickrate

kPlayerBrainFastTickrate = 12 -- new value
kPlayerBrainFastTickFrametimeDiff = kPlayerBrainTickFrametime - 1 / kPlayerBrainFastTickrate


function PlayerBrain:Update(bot, move)
    PROFILE("PlayerBrain:Update")

    if gBotDebug:Get("spam") then
        Log("PlayerBrain:Update")
    end

    if not bot:GetPlayer():isa( self:GetExpectedPlayerClass() )
    or bot:GetPlayer():GetTeamNumber() ~= self:GetExpectedTeamNumber() then
        bot.brain = nil
        return false
    end

    local time = Shared.GetTime()
    if self.lastAction and self.nextMoveTime and 
            (
                (self.lastAction.name ~= "attack" and self.nextMoveTime > time) or 
                self.nextMoveTime - kPlayerBrainFastTickFrametimeDiff > time
            )  then
        if bot.lastcommands then
            move.commands = bit.bor(move.commands, bot.lastcommands)
        end
        return
    end
    
    self.debug = self:GetShouldDebug(bot)

    if self.debug then
        DebugPrint("-- BEGIN BRAIN UPDATE, player name = %s --", bot:GetPlayer():GetName())
    end

    self.teamBrain = GetTeamBrain( bot:GetPlayer():GetTeamNumber() )

    local bestAction

    -- Prepare senses before action-evals use it
    assert(self:GetSenses())
    self:GetSenses():OnBeginFrame(bot)

    local actions = self:GetActions()
    for i = 1, #actions do

        if self.debug then
            self:GetSenses():ResetDebugTrace()
        end

        local actionEval = actions[i]
        local action = actionEval(bot, self)
        assert( action.weight ~= nil )

        if self.debug then
            DebugPrint("weight(%s) = %0.2f. trace = %s",
                    action.name, action.weight, self:GetSenses():GetDebugTrace())
        end

        if not bestAction or action.weight > bestAction.weight then
            bestAction = action
        end
    end

    if bestAction then
        if self.debug then
            DebugPrint("-- chose action: " .. bestAction.name)
        end

        bestAction.perform(move)
        self.lastAction = bestAction
        self.nextMoveTime = time + kPlayerBrainTickFrametime
        
        bot.lastcommands = move.commands

        if self.debug or gBotDebug:Get("debugall") then
            Shared.DebugColor( 0, 1, 0, 1 )
            Shared.DebugText( bestAction.name, bot:GetPlayer():GetEyePos()+Vector(-1,0,0), 0.0 )
        end
    end

end
