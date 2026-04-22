-------------------------------------------------------------------------------
-- RetroRuns -- Navigation.lua
-- Boss resolution, step computation, segment selection, progress tracking,
-- teleport-arrival detection. Pure logic -- no UI or frame references.
-------------------------------------------------------------------------------

local RR = RetroRuns

-------------------------------------------------------------------------------
-- Boss lookup
-------------------------------------------------------------------------------

function RR:GetBossByIndex(index)
    if not self.currentRaid then return nil end
    for _, boss in ipairs(self.currentRaid.bosses) do
        if boss.index == index then return boss end
    end
end

function RR:GetBossByName(name)
    if not self.currentRaid or not name then return nil end
    for _, boss in ipairs(self.currentRaid.bosses) do
        if boss.name == name then return boss end
    end
end

function RR:GetBossByNormalizedName(name)
    if not self.currentRaid or not name then return nil end
    local needle = self:NormalizeName(name)
    for _, boss in ipairs(self.currentRaid.bosses) do
        if self:NormalizeName(boss.name) == needle then return boss end
        if boss.aliases then
            for _, alias in ipairs(boss.aliases) do
                if self:NormalizeName(alias) == needle then return boss end
            end
        end
    end
end

function RR:ResolveBoss(name)
    return self:GetBossByName(name) or self:GetBossByNormalizedName(name)
end

-------------------------------------------------------------------------------
-- Kill state
-------------------------------------------------------------------------------

function RR:IsBossKilled(index)
    return self.state.bossesKilled[index] == true
end

function RR:MarkBossKilled(boss)
    if not boss then return end
    self.state.bossesKilled[boss.index] = true
    if self.state.manualTargetBossIndex == boss.index then
        self.state.manualTargetBossIndex = nil
    end
end

function RR:MarkBossKilledByEncounterName(encounterName)
    if not self.currentRaid or not encounterName then return end
    local boss = self:ResolveBoss(encounterName)
    if boss then
        self:MarkBossKilled(boss)
        self:ComputeNextStep()
    else
        self:Debug("No boss matched encounter: " .. encounterName)
    end
end

function RR:ClearBossState()
    wipe(self.state.bossesKilled)
    wipe(self.state.completedSegments)
end

-------------------------------------------------------------------------------
-- Segment completion  (keyed by step index + seg index -- never touches data)
-------------------------------------------------------------------------------

function RR:IsSegmentCompleted(stepIndex, segIndex)
    local s = self.state.completedSegments[stepIndex]
    return s and s[segIndex] == true
end

function RR:MarkSegmentCompleted(stepIndex, segIndex)
    self.state.completedSegments[stepIndex] =
        self.state.completedSegments[stepIndex] or {}
    self.state.completedSegments[stepIndex][segIndex] = true
end

-------------------------------------------------------------------------------
-- Step availability
-------------------------------------------------------------------------------

function RR:RequirementsMet(requirements)
    if not requirements or #requirements == 0 then return true end
    for _, idx in ipairs(requirements) do
        if not self:IsBossKilled(idx) then return false end
    end
    return true
end

function RR:GetAvailableSteps()
    local results = {}
    if not self.currentRaid or not self.currentRaid.routing then return results end
    for _, step in ipairs(self.currentRaid.routing) do
        if not self:IsBossKilled(step.bossIndex)
            and self:RequirementsMet(step.requires) then
            table.insert(results, step)
        end
    end
    table.sort(results, function(a, b)
        return (a.priority or a.step or 999) < (b.priority or b.step or 999)
    end)
    return results
end

function RR:ComputeNextStep()
    self.state.activeStep = nil
    if not self.currentRaid then return nil end
    local available = self:GetAvailableSteps()
    if self.state.manualTargetBossIndex then
        for _, step in ipairs(available) do
            if step.bossIndex == self.state.manualTargetBossIndex then
                self.state.activeStep = step
                return step
            end
        end
        self.state.manualTargetBossIndex = nil
    end
    if #available > 0 then
        self.state.activeStep = available[1]
        return available[1]
    end
    return nil
end

function RR:SetManualTarget(bossIndex)
    self.state.manualTargetBossIndex = bossIndex
    self:ComputeNextStep()
end

-------------------------------------------------------------------------------
-- Progress
-------------------------------------------------------------------------------

function RR:GetProgressText()
    if not self.currentRaid then return "0/0" end
    local total, killed = #self.currentRaid.bosses, 0
    for _, boss in ipairs(self.currentRaid.bosses) do
        if self:IsBossKilled(boss.index) then killed = killed + 1 end
    end
    return ("%d/%d"):format(killed, total)
end

function RR:GetProgressLines()
    local lines = {}
    if not self.currentRaid then return lines end
    -- 3-state coloring, deliberately NOT 4-state.
    --
    -- Earlier versions distinguished "available but not active" (white)
    -- from "not yet available, prereqs unmet" (gray). The white state
    -- was removed 2026-04-22 because the visual was misleading: in
    -- raids like Castle Nathria with branching DAGs (Sun King's
    -- prereq is Shriekwing, but our recorded solo-clear route visits
    -- Sun King after Altimor/Destroyer/Inerva), a player seeing a
    -- white boss name reads it as "you can fight this next if you
    -- want" -- and going off-route breaks the guide's segment-by-
    -- segment navigation. Now every non-killed, non-active boss is
    -- uniformly "pending" (gray), regardless of prereq state. The
    -- player's only CTA is the yellow active boss.
    --
    -- Killed marker uses Blizzard's ReadyCheck-Ready texture (green
    -- check) to match the Special Loot section's "collected" glyph.
    -- Prior versions used an ASCII "x" which collided visually with
    -- Special Loot's "X" meaning "uncollected" -- same letter,
    -- opposite semantics, on the same panel. Unified glyph removes
    -- the confusion.
    local KILLED_GLYPH = "|TInterface\\RaidFrame\\ReadyCheck-Ready:12:12|t"
    for _, boss in ipairs(self.currentRaid.bosses) do
        local marker, color
        if self.state.bossesKilled[boss.index] then
            marker, color = "[" .. KILLED_GLYPH .. "]", "ff00ff00"
        elseif self.state.activeStep
            and self.state.activeStep.bossIndex == boss.index then
            marker, color = "[>]", "ffffff00"
        else
            marker, color = "[ ]", "ff9d9d9d"
        end
        table.insert(lines, ("|c%s%s %s|r"):format(color, marker, boss.name))
    end
    return lines
end

function RR:GetDisplayBossNumber(step, boss)
    if step and step.displayIndex then return step.displayIndex end
    if step and step.step         then return step.step end
    return (boss and boss.index) or (step and step.bossIndex) or 0
end

-------------------------------------------------------------------------------
-- Segment / map helpers
-------------------------------------------------------------------------------

function RR:GetPlayerMapPosition()
    if C_Map and C_Map.GetBestMapForUnit then
        local mapID = C_Map.GetBestMapForUnit("player")
        if mapID then
            local pos = C_Map.GetPlayerMapPosition(mapID, "player")
            if pos then return mapID, pos.x, pos.y end
        end
    end
    return nil, nil, nil
end

function RR:GetRelevantSegmentsForMap(step, mapID)
    local results = {}
    if not step or not step.segments or not mapID then return results end
    local stepIndex = step.step or step.priority or 0
    local matches   = {}
    for segIndex, seg in ipairs(step.segments) do
        if not self:IsSegmentCompleted(stepIndex, segIndex)
            and seg.mapID == mapID
            and seg.points and #seg.points > 0 then
            table.insert(matches, { segIndex = segIndex, seg = seg })
        end
    end
    if #matches <= 1 then
        for _, m in ipairs(matches) do table.insert(results, m.seg) end
        return results
    end
    local _, px, py = self:GetPlayerMapPosition()
    if not px then
        table.insert(results, matches[#matches].seg)
        return results
    end
    local bestSeg, bestDist
    for _, m in ipairs(matches) do
        local pt = m.seg.points[1]
        local d  = (px - pt[1])^2 + (py - pt[2])^2
        if not bestDist or d < bestDist then bestSeg, bestDist = m.seg, d end
    end
    if bestSeg then table.insert(results, bestSeg) end
    return results
end

function RR:GetStepMaps(step)
    step = step or self.state.activeStep
    local maps = {}
    if not step then return maps end
    if step.segments then
        for _, seg in ipairs(step.segments) do
            if seg.mapID then maps[seg.mapID] = true end
        end
    elseif step.mapID then
        maps[step.mapID] = true
    end
    return maps
end

function RR:GetFirstIncompleteSegment(step)
    if not step or not step.segments then return nil end
    local stepIndex = step.step or step.priority or 0
    for segIndex, seg in ipairs(step.segments) do
        if not self:IsSegmentCompleted(stepIndex, segIndex) then return seg end
    end
    return step.segments[1]
end

function RR:ShowCurrentMapForStep()
    local step = self.state.activeStep
    if not step or not WorldMapFrame then return end
    local currentMapID = WorldMapFrame.GetMapID and WorldMapFrame:GetMapID()
    local stepMaps     = self:GetStepMaps(step)
    local activeSeg    = self:GetFirstIncompleteSegment(step)
    local targetMapID  =
        (currentMapID and stepMaps[currentMapID] and currentMapID)
        or (activeSeg and activeSeg.mapID)
        or step.mapID
    if not targetMapID then return end
    if not WorldMapFrame:IsShown() then ToggleWorldMap() end
    C_Timer.After(0, function()
        WorldMapFrame:SetMapID(targetMapID)
        if RetroRunsMapOverlay then RetroRunsMapOverlay:Refresh() end
    end)
end

-------------------------------------------------------------------------------
-- Teleport-arrival detection
-------------------------------------------------------------------------------

function RR:CheckTeleportArrivalAdvance()
    local step = self.state.activeStep
    if not step or not step.segments or #step.segments < 2 then return end
    local playerMapID, px, py = self:GetPlayerMapPosition()
    if not playerMapID then return end
    local stepIndex = step.step or step.priority or 0
    for i = 1, #step.segments - 1 do
        local seg     = step.segments[i]
        local nextSeg = step.segments[i + 1]
        if seg.kind == "teleport"
            and not self:IsSegmentCompleted(stepIndex, i)
            and nextSeg.points and #nextSeg.points > 0
            and playerMapID == nextSeg.mapID then
            local arr = nextSeg.points[1]
            if (px - arr[1])^2 + (py - arr[2])^2 <= 0.06^2 then
                self:MarkSegmentCompleted(stepIndex, i)
                RR.UI.Update()
                if RetroRunsMapOverlay then RetroRunsMapOverlay:Refresh() end
                return
            end
        end
    end
end

function RR:IsPanelAllowed()
    return self:GetSetting("showPanel") and true or false
end
