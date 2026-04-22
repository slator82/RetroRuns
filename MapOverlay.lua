-------------------------------------------------------------------------------
-- RetroRuns -- MapOverlay.lua
-- Draws route lines and nav icons on the World Map.
-------------------------------------------------------------------------------

local RR = RetroRuns

-------------------------------------------------------------------------------
-- Pool sizes -- sized to handle the largest expected raid routing
-------------------------------------------------------------------------------

local MAX_LINES = 80
local MAX_ICONS = 30
local MAX_DOTS  = 80

local overlay = CreateFrame(
    "Frame", "RetroRunsMapOverlay",
    WorldMapFrame.ScrollContainer.Child)
overlay:SetAllPoints(WorldMapFrame.ScrollContainer.Child)

overlay.lines = {}
overlay.icons = {}
overlay.dots  = {}

local function MakeLine(p)
    local ln = p:CreateLine(nil, "ARTWORK")
    ln:SetThickness(4)
    ln:SetColorTexture(1.0, 0.82, 0.0, 0.95)
    ln:Hide()
    return ln
end

local function MakeIcon(p)
    local tx = p:CreateTexture(nil, "ARTWORK")
    tx:SetSize(18, 18)
    tx:Hide()
    return tx
end

local function MakeDot(p)
    local tx = p:CreateTexture(nil, "ARTWORK")
    tx:SetSize(10, 10)
    tx:SetTexture("Interface\\MINIMAP\\TempleofKotmogu_ball_cyan")
    tx:Hide()
    return tx
end

for i = 1, MAX_LINES do overlay.lines[i] = MakeLine(overlay) end
for i = 1, MAX_ICONS do overlay.icons[i] = MakeIcon(overlay) end
for i = 1, MAX_DOTS  do overlay.dots[i]  = MakeDot(overlay)  end

-------------------------------------------------------------------------------
-- Helpers
-------------------------------------------------------------------------------

local function PlaceAt(el, parent, nx, ny)
    el:ClearAllPoints()
    el:SetPoint("CENTER", parent, "TOPLEFT",
        nx * parent:GetWidth(), -ny * parent:GetHeight())
end

local function ApplyIconStyle(icon, kind)
    if kind == "start" then
        icon:SetTexture("Interface\\MINIMAP\\TempleofKotmogu_ball_cyan")
        icon:SetVertexColor(0.2, 1.0, 1.0, 1.0)
        icon:SetSize(14, 14)
    else  -- "end"
        icon:SetTexture("Interface\\RaidFrame\\ReadyCheck-NotReady")
        icon:SetVertexColor(1.0, 0.85, 0.15, 1.0)
        icon:SetSize(18, 18)
    end
end

-------------------------------------------------------------------------------
-- Drawing
-------------------------------------------------------------------------------

function overlay:HideAll()
    for _, v in ipairs(self.lines) do v:Hide() end
    for _, v in ipairs(self.icons) do v:Hide() end
    for _, v in ipairs(self.dots)  do v:Hide() end
end

function overlay:DrawSegmentsForMap(mapID)
    local step = RR.state.activeStep
    if not step then return end

    local segments = RR:GetRelevantSegmentsForMap(step, mapID)
    if not segments or #segments == 0 then return end

    local W, H      = self:GetWidth(), self:GetHeight()
    local lineIdx   = 1
    local iconIdx   = 1

    for _, seg in ipairs(segments) do
        local pts        = seg.points
        local isTeleport = seg.kind == "teleport"
        if pts and #pts > 0 then

            -- Start dot: always show so the player knows where the segment begins
            local startIcon = self.icons[iconIdx]
            if startIcon then
                PlaceAt(startIcon, self, pts[1][1], pts[1][2])
                ApplyIconStyle(startIcon, "start")
                startIcon:Show()
                iconIdx = iconIdx + 1
            end

            -- Lines: all segments use the same bright thick line for visibility
            for i = 2, #pts do
                local ln = self.lines[lineIdx]
                if ln then
                    local p, c = pts[i-1], pts[i]
                    ln:SetThickness(5)
                    ln:SetColorTexture(1.0, 0.95, 0.3, 1.0)
                    ln:SetStartPoint("TOPLEFT", p[1] * W, -p[2] * H)
                    ln:SetEndPoint  ("TOPLEFT", c[1] * W, -c[2] * H)
                    ln:Show()
                    lineIdx = lineIdx + 1
                end
            end

            -- End icon: teleport icon for teleport destinations, red X for boss locations
            local dest    = seg.navPoint or pts[#pts]
            local endIcon = self.icons[iconIdx]
            if endIcon then
                PlaceAt(endIcon, self, dest[1], dest[2])
                ApplyIconStyle(endIcon, isTeleport and "teleport" or "end")
                endIcon:Show()
                iconIdx = iconIdx + 1
            end
        end
    end
end

function overlay:DrawRecorder(mapID)
    -- Support both old DB-backed recorder and new in-memory recorder
    local rec    = RR.recorder
    local active = rec and rec.active
    local points = {}

    if active and rec.current and rec.current.mapID == mapID then
        -- Draw committed segments for this map too
        for _, seg in ipairs(rec.segments) do
            if seg.mapID == mapID then
                for _, pt in ipairs(seg.points) do
                    table.insert(points, pt)
                end
            end
        end
        for _, pt in ipairs(rec.current.points) do
            table.insert(points, pt)
        end
    end

    if #points == 0 then return end

    local W, H    = self:GetWidth(), self:GetHeight()
    local lineIdx = math.floor(MAX_LINES / 2) + 1
    local dotIdx  = 1

    for i, pt in ipairs(points) do
        local dt = self.dots[dotIdx]
        if dt then
            PlaceAt(dt, self, pt[1], pt[2])
            dt:SetVertexColor(0.2, 1.0, 0.2, 1.0)
            dt:Show()
            dotIdx = dotIdx + 1
        end
        if i > 1 then
            local ln = self.lines[lineIdx]
            if ln then
                local prev = points[i-1]
                ln:SetThickness(2)
                ln:SetColorTexture(0.2, 1.0, 0.2, 0.85)
                ln:SetStartPoint("TOPLEFT", prev[1] * W, -prev[2] * H)
                ln:SetEndPoint  ("TOPLEFT", pt[1]   * W, -pt[2]   * H)
                ln:Show()
                lineIdx = lineIdx + 1
            end
        end
    end
end

function overlay:Refresh()
    self:HideAll()
    local mapID = WorldMapFrame:GetMapID()
    if not mapID then return end

    if RR.currentRaid
        and RR.state.loadedRaidKey == RR:GetRaidContextKey() then
        self:DrawSegmentsForMap(mapID)
    end

    self:DrawRecorder(mapID)
end

RetroRunsMapOverlay = overlay

-------------------------------------------------------------------------------
-- Hooks
-------------------------------------------------------------------------------

hooksecurefunc(WorldMapFrame, "OnMapChanged", function()
    overlay:Refresh()
    RR.UI.Update()
end)

WorldMapFrame:HookScript("OnShow", function()
    overlay:Refresh()
    RR.UI.Update()
end)

WorldMapFrame.ScrollContainer:HookScript("OnMouseUp", function(_, button)
    if button == "LeftButton" then
        RR:RecorderHandleMapClick()
    end
end)

C_Timer.NewTicker(1.0, function()
    if WorldMapFrame and WorldMapFrame:IsShown() then
        overlay:Refresh()
    end
end)
