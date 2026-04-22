-------------------------------------------------------------------------------
-- RetroRuns -- Recorder.lua
--
-- Map-click route recorder that produces complete, pasteable data entries.
--
-- WORKFLOW:
--   1. /rr record start          -- begin recording on current map
--   2. Open the World Map; SHIFT+CLICK each waypoint along the route
--   3. At a teleporter:
--        /rr record tp <n>    -- closes current segment, marks it as a
--                                  teleport. Open the new map, keep
--                                  shift-clicking; the new clicks attach
--                                  to the new map automatically.
--   4. /rr record note <text>    -- attach a travel note to the current segment
--   5. /rr record stop           -- finalise
--   6. /rr record dump           -- open a copy window with a complete,
--                                  pasteable routing entry
--                                  (also saved to RetroRunsDB.lastRecording)
--   7. /rr record reset          -- clear and start fresh
--
-- WHY SHIFT-CLICK INSTEAD OF AUTO-POSITION SAMPLING:
-- Blizzard restricts `C_Map.GetPlayerMapPosition` inside instances (it
-- returns nil), which makes auto-position recording useless for raid
-- routing. Shift-click on the World Map works in every context because
-- it reads positions FROM the map UI, not from the player's coordinates.
-------------------------------------------------------------------------------

local RR = RetroRuns

RR.recorder = {
    active   = false,
    segments = {},     -- list of completed segments
    current  = nil,    -- segment being built right now
}

-------------------------------------------------------------------------------
-- Internal helpers
-------------------------------------------------------------------------------

local function R3(v) return tonumber(("%.3f"):format(v)) end

-- Get the mapID currently displayed in the World Map. Falls back to the
-- player's best map (works outside instances; will likely fail in raids
-- where Blizzard restricts map APIs).
local function CurrentMapID()
    if WorldMapFrame and WorldMapFrame:IsShown() and WorldMapFrame:GetMapID() then
        return WorldMapFrame:GetMapID()
    end
    return C_Map and C_Map.GetBestMapForUnit and C_Map.GetBestMapForUnit("player")
end

local function NewSegment(mapID, kind)
    return {
        mapID  = mapID,
        kind   = kind or "path",
        note   = nil,
        points = {},
    }
end

-------------------------------------------------------------------------------
-- Click integration with MapOverlay
--
-- MapOverlay.lua hooks `WorldMapFrame.ScrollContainer:OnMouseUp` for the
-- entire addon and dispatches left-clicks here via RR:RecorderHandleMapClick.
-- We don't install our own hook (would duplicate MapOverlay's). Per-click
-- logic lives entirely in this method.
--
-- The method is called on EVERY left-click on the map; we only act when
-- recording is active AND shift is held. Other clicks (drag-pan, normal
-- left-clicks for navigation, etc.) pass through untouched.
-------------------------------------------------------------------------------

function RR:RecorderHandleMapClick()
    local rec = self.recorder
    if not rec.active then return end
    if not IsShiftKeyDown() then return end
    if not rec.current then return end
    if not WorldMapFrame or not WorldMapFrame.ScrollContainer then return end

    local container = WorldMapFrame.ScrollContainer

    -- Convert screen-space cursor position to map-normalized coords. Wrapped
    -- in pcall to defend against future Blizzard API changes -- if either
    -- GetCursorPosition or NormalizeUIPosition disappears or changes its
    -- signature, we want to silently no-op rather than throw a Lua error
    -- on every map click. (A previous version of this hook errored loudly
    -- because of a missing method; pcall would have prevented user-visible
    -- errors during that bug.)
    local ok, cx, cy = pcall(container.GetCursorPosition, container)
    if not ok or not cx or not cy then
        if not ok then self:Debug("RecorderHandleMapClick: GetCursorPosition failed: " .. tostring(cx)) end
        return
    end
    local ok2, nx, ny = pcall(container.NormalizeUIPosition, container, cx, cy)
    if not ok2 or not nx or not ny or nx < 0 or nx > 1 or ny < 0 or ny > 1 then
        if not ok2 then self:Debug("RecorderHandleMapClick: NormalizeUIPosition failed: " .. tostring(nx)) end
        return
    end

    -- Use the World Map's currently-displayed mapID. If the user has
    -- changed maps (e.g. after a teleport), this will reflect the new
    -- map automatically.
    local ok3, visibleMapID = pcall(WorldMapFrame.GetMapID, WorldMapFrame)
    if not ok3 or not visibleMapID then return end

    -- If the visible map differs from the current segment's map, the
    -- user is mapping a different floor/zone now. Close the current
    -- segment (if it has any points) and open a new one. This lets a
    -- multi-map raid be recorded by just changing the World Map's
    -- displayed map between clicks -- no /rr record tp needed for
    -- pure map-floor changes (only for actual teleporter usage where
    -- the segment kind needs to be "teleport").
    if rec.current.mapID ~= visibleMapID then
        if #rec.current.points > 0 then
            table.insert(rec.segments, rec.current)
        end
        rec.current = NewSegment(visibleMapID, "path")
    end

    table.insert(rec.current.points, { R3(nx), R3(ny) })
end

-------------------------------------------------------------------------------
-- Public API
-------------------------------------------------------------------------------

function RR:StartRecording()
    local rec = self.recorder
    if rec.active then self:Print("Recorder is already running.") ; return end

    -- Pick a starting map. Prefer whatever the World Map is showing right
    -- now (the user is probably looking at the map they want to record on).
    -- Fall back to player's current map.
    local mapID = CurrentMapID()
    if not mapID then
        self:Print("Cannot determine map. Open the World Map first.")
        return
    end

    rec.active   = true
    rec.segments = {}
    rec.current  = NewSegment(mapID, "path")

    self:Print("Recording started.")
    self:Print("  Open the World Map and SHIFT+CLICK each waypoint along the route.")
    self:Print("  Switch World Map floors between clicks to record across multiple maps.")
    self:Print("  /rr record tp <name>   -- mark current segment as a teleporter use")
    self:Print("  /rr record note <text> -- attach a travel note to the current segment")
    self:Print("  /rr record stop        -- finish")
end

function RR:StopRecording()
    local rec = self.recorder
    rec.active = false

    if rec.current then
        if #rec.current.points > 0 then
            table.insert(rec.segments, rec.current)
        end
        rec.current = nil
    end

    local total = 0
    for _, s in ipairs(rec.segments) do total = total + #s.points end
    self:Print(("Stopped. %d segment(s), %d total waypoint(s)."):format(
        #rec.segments, total))
    self:Print("/rr record dump  -- to export | /rr record reset -- to clear")
end

--- Called at a teleporter. Closes the current walking segment, marks it as
--- a teleport kind, and opens a fresh segment that will pick up the new
--- map's ID on the next shift-click.
function RR:RecordTeleport(destination)
    local rec = self.recorder
    if not rec.active then
        self:Print("Recorder is not running. Use /rr record start first.")
        return
    end

    -- Finalise the current segment as a teleport segment
    if rec.current then
        rec.current.kind = "teleport"
        rec.current.destination = destination
        if not rec.current.note then
            rec.current.note = ("Use the teleporter and select %s."):format(destination)
        end
        if #rec.current.points > 0 then
            table.insert(rec.segments, rec.current)
        end
    end

    -- Open a placeholder segment with no mapID. The first shift-click on
    -- the new map will detect the mapID mismatch and rotate this segment
    -- with a properly-mapID'd one. (See RecorderHandleMapClick.)
    rec.current = NewSegment(0, "path")  -- mapID=0 is a sentinel; first click overwrites

    self:Print(("Teleport marked: %s"):format(destination))
    self:Print("  Open the new map after teleporting, then SHIFT+CLICK to continue.")
end

--- Attach a travel note to the current segment.
function RR:RecordSetNote(text)
    local rec = self.recorder
    if not rec.active then
        self:Print("Recorder is not running.")
        return
    end
    local target = rec.current or rec.segments[#rec.segments]
    if not target then
        self:Print("No segment to annotate.")
        return
    end
    target.note = text
    self:Print("Note set: " .. text)
end

function RR:ResetRecording()
    local rec = self.recorder
    rec.active, rec.segments, rec.current = false, {}, nil
    self:Print("Recorder reset.")
end

function RR:RecordingStatus()
    local rec = self.recorder
    local pts = (rec.current and #rec.current.points) or 0
    local mapStr = "(none)"
    if rec.current and rec.current.mapID and rec.current.mapID ~= 0 then
        mapStr = tostring(rec.current.mapID)
    end
    self:Print(("Recorder: %s | segments=%d | current points=%d | map=%s"):format(
        rec.active and "ACTIVE" or "stopped",
        #rec.segments, pts, mapStr))
end

-------------------------------------------------------------------------------
-- Export
--
-- Produces a complete segments = { ... } block suitable for pasting directly
-- into a raid data file's `routing[]` array. The user supplies bossIndex,
-- requires, soloTip, and achievements separately.
-------------------------------------------------------------------------------

function RR:BuildRecordingExport()
    local rec = self.recorder
    local segs = rec.segments

    -- If recording is still active and there's an in-progress segment with
    -- points, include it in the export so the user doesn't have to /rr
    -- record stop first.
    if rec.active and rec.current and #rec.current.points > 0 then
        segs = {}
        for _, s in ipairs(rec.segments) do table.insert(segs, s) end
        table.insert(segs, rec.current)
    end

    if #segs == 0 then return nil, "No segments recorded." end

    local out = {}
    table.insert(out, "-- Paste into the raid's routing[] array. Fill in TODOs.")
    table.insert(out, "{")
    table.insert(out, "    step      = TODO,")
    table.insert(out, "    priority  = TODO,")
    table.insert(out, "    bossIndex = TODO,")
    table.insert(out, "    title     = \"TODO\",")
    table.insert(out, "    requires  = { },")
    table.insert(out, "    segments  = {")

    for _, s in ipairs(segs) do
        table.insert(out, "        {")
        table.insert(out, ("            mapID = %d,"):format(s.mapID or 0))
        table.insert(out, ("            kind  = %q,"):format(s.kind or "path"))
        if s.destination then
            table.insert(out, ("            destination = %q,"):format(s.destination))
        end
        if s.note then
            table.insert(out, ("            note = %q,"):format(s.note))
        end
        table.insert(out, "            points = {")
        for _, p in ipairs(s.points) do
            table.insert(out, ("                { %.3f, %.3f },"):format(p[1], p[2]))
        end
        table.insert(out, "            },")
        table.insert(out, "        },")
    end

    table.insert(out, "    },")
    table.insert(out, "},")

    return table.concat(out, "\n")
end

function RR:DumpRecording()
    local export, err = self:BuildRecordingExport()
    if not export then
        self:Print(err)
        return
    end

    self:SetSetting("lastRecording", export)

    -- Show the copy window (defined in Harvester.lua's ShowCopyWindow helper).
    -- Single-click copy beats the previous line-by-line chat dump (which
    -- forced the user to scrollback and copy line-by-line out of chat).
    if self.ShowCopyWindow then
        self:ShowCopyWindow(
            "|cffF259C7RETRO|r|cff4DCCFFRUNS|r  |cffaaaaaaRecording Export|r",
            export)
        self:Print("Recording window opened. Click inside, Ctrl+A, Ctrl+C.")
        self:Print("(Also saved to RetroRunsDB.lastRecording.)")
    else
        -- Fallback: ShowCopyWindow not available (Harvester.lua not loaded?).
        -- Print line-by-line as before.
        self:Print("Export saved to RetroRunsDB.lastRecording")
        self:Print("-------------------------------------")
        for line in export:gmatch("[^\n]+") do
            DEFAULT_CHAT_FRAME:AddMessage("|cffaaaaaa" .. line .. "|r")
        end
        self:Print("-------------------------------------")
        self:Print("Copy the above into your data file.")
    end
end
