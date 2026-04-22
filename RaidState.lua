-------------------------------------------------------------------------------
-- RetroRuns -- RaidState.lua
-- Syncs kill state from WoW's saved-instance API.
-------------------------------------------------------------------------------

local RR = RetroRuns

-- requestRaidInfo = true  : also calls RequestRaidInfo() to ask the server
--                            for fresh data. Use on zone change / load only.
-- requestRaidInfo = false : reads current cached saved-instance data only.
--                            Use after ENCOUNTER_END where we already know
--                            the kill from the event and don't want a
--                            server round-trip that would cause a second
--                            UI refresh via UPDATE_INSTANCE_INFO.
function RR:SyncFromSavedRaidInfo(requestRaidInfo)
    if self.state.testMode then
        self:ComputeNextStep()
        return
    end

    self:ClearBossState()

    if not self.currentRaid then
        self:ComputeNextStep()
        return
    end

    if requestRaidInfo then
        RequestRaidInfo()
    end

    local numSaved = GetNumSavedInstances()
    for i = 1, numSaved do
        local _, _, _, difficultyId, _, _, _, isRaid,
              _, _, numEncounters, _, _, instanceID = GetSavedInstanceInfo(i)

        if isRaid
            and instanceID   == self.currentRaid.instanceID
            and difficultyId == self.state.currentDifficultyID then
            for e = 1, numEncounters do
                local bossName, _, isKilled = GetSavedInstanceEncounterInfo(i, e)
                if bossName and isKilled then
                    local boss = self:ResolveBoss(bossName)
                    if boss then self:MarkBossKilled(boss) end
                end
            end
        end
    end

    self:ComputeNextStep()
end
