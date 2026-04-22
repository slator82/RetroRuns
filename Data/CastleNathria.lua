-------------------------------------------------------------------------------
-- RetroRuns Data -- Castle Nathria
-- Shadowlands, Patch 9.0  |  instanceID: 2296  |  journalInstanceID: 1190
-------------------------------------------------------------------------------
-- Phase 2 skeleton: metadata complete; loot, achievements, and routing
-- populated opportunistically as Photek records them in-game.
--
-- CN-SPECIFIC NOTES FOR FUTURE MAINTAINERS:
--
-- 1. Weapon tokens, not armor tier sets. 9.0 predates the modern armor
--    tier-set system (that came back in 9.2 Sepulcher). Instead, CN
--    introduced 6 CLASS-RESTRICTED weapon tokens ("Anima Spherules" for
--    main-hand, "Anima Beads" for off-hand). Each token drops from a
--    specific boss and can be redeemed at the Covenant Sanctum weaponsmith
--    for a covenant-themed weapon appearance. Covenant only controls the
--    visual skin applied at redemption -- the token's class-eligibility
--    and weapon slot are both fixed by the token itself.
--
-- 2. Two ilvl tiers per token family. Each family (Mystic, Abominable,
--    Apogee, Venerated, Thaumaturgic, Zenith) has a LOWER-ilvl and
--    HIGHER-ilvl token itemID. LFR/Normal/Heroic bosses drop the lower;
--    Mythic drops the higher. This is why `tokenSources` below has 12
--    entries despite only 6 families.
--
-- 3. Spherules are NOT Blizzard-native ensembles. Confirmed in-game
--    2026-04-21 via `C_Item.GetItemLearnTransmogSet(itemID)` returning
--    nil for all 3 spherules tested (183892, 183888, plus one more).
--    That means `C_Transmog.GetAllSetAppearancesByID` can't tell us what
--    appearances a token unlocks -- we'll ship curated appearance pools
--    in a future data update (mirrored from TTT addon's CN/tokens.lua).
--
-- 4. `/rr tiersets` does NOT auto-populate CN's tokenSources. The
--    harvester's name-matching relies on slot keywords ("helm",
--    "shoulder", etc.) that don't appear in CN's weapon-token names
--    ("Anima Spherule", "Anima Bead"). tokenSources below is hand-
--    populated from TTT cross-reference + the Wowhead token table.
--    Also note that CN's tokenSources uses a list-valued variant
--    (`[itemID] = {bossA, bossB}`) because Sire Denathrius and Stone
--    Legion Generals both drop tokens as secondary sources in addition
--    to the primary-boss drops. Backwards compatible: scalar-valued
--    entries still work for single-boss tokens (e.g. Sepulcher).
--
-- 5. `/rr harvest` will still discover each boss's regular (non-tier)
--    armor loot correctly -- those are standard per-difficulty items
--    that the armor-shape detection handles.
--
-- 6. Armor items are Sanctum-shape: 4 distinct sourceIDs per item, each
--    under its own appearanceID. Verified via ATT cross-reference (60/60
--    clean). Harvester's `EnrichWithPerDifficultySources` path handles
--    this without modification.
--
-- 7. Boss order is a DAG, not linear. Shriekwing unlocks 3 parallel
--    bosses, which then gate Council (left branch) and Lady Inerva
--    (right branch), which together gate the Sludgefist/SLG/Denathrius
--    final sequence. The `routing[]` block's `requires` field needs to
--    model these gates -- see Phase 3 routing for details when it lands.
--
-- 8. specialLoot: intentionally empty on every boss. Castle Nathria's
--    two collectibles are NOT attributed to boss EJ loot tables:
--      - Mount 182596 (Sinrunner Blanchy's Reins?) is the Glory of the
--        Nathria Raider achievement reward (achID 14355). Not a boss
--        drop; granted by achievement completion.
--      - Pet 183395 is attributed by ATT to npcID 173994 within the
--        Denathrius encounter block, but doesn't appear in live 12.0.5
--        EJ loot (verified 2026-04-21 via /rr ejdiff 2424 list — 85
--        items reported, pet not among them). Likely trash drop or
--        removed.
--    Our harvester only surfaces mount/pet/toy/decor items that the EJ
--    lists as boss loot; both of CN's collectibles are out of scope for
--    that code path. If we ever add achievement-reward or trash-drop
--    tracking, revisit both. Until then: specialLoot stays empty.
-------------------------------------------------------------------------------

RetroRuns_Data = RetroRuns_Data or {}

RetroRuns_Data[2296] = {
    instanceID        = 2296,
    journalInstanceID = 1190,
    name              = "Castle Nathria",
    expansion         = "Shadowlands",
    patch             = "9.0",

    maps = {
        -- Sub-zone names TBD: populate from the in-game world-map dropdown
        -- opportunistically as Photek walks the raid. The 8 submap IDs are
        -- confirmed via ATT's Instances.lua inst(1190) block. Sanctum
        -- precedent: GetMapInfo(mapID).name returns the parent raid name
        -- for every submap, so the dropdown label is the only authoritative
        -- source. Maintain by hand.
        --
        -- Confirmed from Phase 1 recording (2026-04-21): 1735 contains
        -- Shriekwing's room (first encounter after entry dialog).
        [1734] = "TODO",
        [1735] = "The Grand Walk",       -- Shriekwing, Huntsman Altimor, Hungering Destroyer, Sludgefist (confirmed 2026-04-21)
        [1744] = "The Purloined Stores", -- Lady Inerva Darkvein (confirmed 2026-04-21)
        [1745] = "Halls of the Faithful", -- Artificer Xy'mox (confirmed 2026-04-21)
        [1746] = "Pride's Prison",       -- Sun King's Salvation (confirmed 2026-04-21)
        [1747] = "Nightcloak Sanctum",   -- Stone Legion Generals, Sire Denathrius start (confirmed 2026-04-21)
        [1748] = "The Observatorium",    -- Sire Denathrius end (auto-transition during encounter) (confirmed 2026-04-21)
        [1750] = "Feast of Arrogance",   -- Council of Blood (confirmed 2026-04-21)
    },

    -- CN weapon tokens, class-restricted. See header comment block for
    -- the full mechanic explanation. Entries sourced from:
    --   - Wowhead Castle Nathria weapon-token table
    --   - TokenTransmogTooltips addon (Raids/CastleNathria/tokens.lua)
    --
    -- Schema: `[tokenItemID] = bossIndex` for single-boss drops (most
    -- tokens), OR `[tokenItemID] = { bossIndex, bossIndex, ... }` for
    -- tokens that drop on multiple bosses. Sire Denathrius drops four
    -- main-hand tokens (Mystic/Abominable/Venerated/Zenith) as a late-
    -- raid backstop, and Stone Legion Generals drops both off-hand
    -- tokens (Apogee/Thaumaturgic). We represent those as list values
    -- so every boss that actually drops a token shows up in the
    -- transmog popup's Weapon Tokens section.
    --
    -- 12 rows total covering 6 families (lower/higher ilvl each). 8 of
    -- the 10 bosses drop weapon tokens; Shriekwing (index 1) and
    -- Sludgefist (index 8) do not.
    --
    -- Display/rendering of the weapons these tokens unlock depends on
    -- static curated data not yet in this file (see note 3 above). For
    -- now, tokenSources drives the Weapon Tokens section of the
    -- transmog popup -- one inert row per token drop per boss, with
    -- the token's item link and family/slot label.
    tierSets = {
        labels = {},  -- intentionally empty: CN weapon tokens are not
                      -- modeled via C_TransmogSets. Phase 3/4 may add a
                      -- CN-specific label if a rendering path materializes.
        tokenSources = {
            -- Main-Hand tokens
            -- Mystic (Druid, Hunter, Mage) -> Huntsman Altimor + Sire Denathrius
            [183892] = { 2, 10 },   -- Mystic Anima Spherule (lower ilvl)
            [183897] = { 2, 10 },   -- Mystic Anima Spherule (higher ilvl)
            -- Abominable (Death Knight, Demon Hunter, Warlock) -> Sun King's Salvation + Sire Denathrius
            [183893] = { 3, 10 },   -- Abominable Anima Spherule (lower)
            [183896] = { 3, 10 },   -- Abominable Anima Spherule (higher)
            -- Venerated (Paladin, Priest, Shaman) -> Hungering Destroyer + Sire Denathrius
            [183891] = { 5, 10 },   -- Venerated Anima Spherule (lower)
            [183898] = { 5, 10 },   -- Venerated Anima Spherule (higher)
            -- Zenith (Evoker, Monk, Rogue, Warrior) -> Council of Blood + Sire Denathrius
            [183890] = { 7, 10 },   -- Zenith Anima Spherule (lower)
            [183899] = { 7, 10 },   -- Zenith Anima Spherule (higher)
            -- Off-Hand tokens
            -- Apogee (Warrior, Paladin, Priest, Monk, Evoker) -> Artificer Xy'mox + Stone Legion Generals
            [183888] = { 4, 9 },    -- Apogee Anima Bead (lower)
            [183895] = { 4, 9 },    -- Apogee Anima Bead (higher)
            -- Thaumaturgic (Shaman, Mage, Warlock, Druid) -> Lady Inerva Darkvein + Stone Legion Generals
            [183889] = { 6, 9 },    -- Thaumaturgic Anima Bead (lower)
            [183894] = { 6, 9 },    -- Thaumaturgic Anima Bead (higher)
        },
    },

    -- Weapon-token appearance pools. Maps each pool to the set of
    -- transmog appearances (and their source IDs) that a player can
    -- unlock by redeeming a spherule/bead at the Covenant Sanctum
    -- weaponsmith. Two slots (Main-Hand, Off-Hand) × two ilvl tiers
    -- (lower, higher) × two difficulty contexts (non-mythic for
    -- LFR/N/H, mythic for M) = 8 pools total.
    --
    -- Important shape note: all 4 MH token families (Mystic, Zenith,
    -- Venerated, Abominable) redeem from the SAME underlying pool --
    -- class-family is cosmetic at the unlock level, only the covenant
    -- chosen at redemption time determines the weapon's visual theme.
    -- Ditto both OH families (Apogee, Thaumaturgic) sharing one OH
    -- pool. That's why we store per-slot pools rather than per-token:
    -- per-token storage would duplicate every entry 2-4 times.
    --
    -- Schema: [appearanceID] = { sourceID, sourceID, ... }. An
    -- appearance is "collected" if any listed sourceID is owned OR
    -- if C_TransmogCollection.GetAppearanceInfoBySource(sourceID).
    -- appearanceIsCollected returns true for any source (the global
    -- cross-source check, matching CIMI's pattern -- a Hunter can
    -- own a Mystic visual via a world-drop bow with the same look).
    --
    -- Pool counts (live API, 2026-04-22 harvest):
    --   mainHandLowerNonMythic:  36 appearances, 43 sources
    --   mainHandHigherNonMythic: 36 appearances, 43 sources
    --   mainHandLowerMythic:     35 appearances, 42 sources
    --   mainHandHigherMythic:    36 appearances, 44 sources
    --   offHandLowerNonMythic:    8 appearances,  8 sources
    --   offHandHigherNonMythic:   8 appearances,  8 sources
    --   offHandLowerMythic:       8 appearances,  8 sources
    --   offHandHigherMythic:      8 appearances,  8 sources
    --
    -- Data provenance: itemID seed list is derived from the
    -- TokenTransmogTooltips addon's per-raid Wowhead-URL comments
    -- (attributed in Harvester.lua:HarvestWeaponPools). The
    -- (appearanceID, sourceID) bindings were harvested via
    -- C_TransmogCollection.GetItemInfo on 2026-04-22 by /rr
    -- weaponharvest, all 203 itemIDs resolved clean. Re-run the
    -- command and cross-check against the previous output before
    -- editing by hand.
    weaponTokenPools = {
        mainHandLowerNonMythic = {
            [41247] = { 112361 },
            [41303] = { 115546, 115548 },
            [41311] = { 108552, 115595 },
            [41335] = { 115537 },
            [41487] = { 114133 },
            [41516] = { 114136, 114137 },
            [41531] = { 115526 },
            [41547] = { 108908, 115591 },
            [41601] = { 115544 },
            [41607] = { 115547 },
            [41681] = { 110998 },
            [41705] = { 108930, 115589 },
            [41746] = { 112341, 114088 },
            [41757] = { 112312 },
            [41775] = { 115540 },
            [41944] = { 109545 },
            [42169] = { 114134, 114135 },
            [42181] = { 114139 },
            [42195] = { 114140 },
            [42254] = { 115543 },
            [42263] = { 114132 },
            [42294] = { 115545 },
            [42315] = { 112282 },
            [42358] = { 115541 },
            [42368] = { 112328 },
            [42504] = { 114131 },
            [42585] = { 114138 },
            [42738] = { 111619 },
            [42848] = { 114130 },
            [42933] = { 115542 },
            [42974] = { 112825 },
            [43002] = { 112842 },
            [43010] = { 112862 },
            [43044] = { 112959 },
            [43148] = { 112964 },
            [44187] = { 115499 },
        },
        mainHandHigherNonMythic = {
            [41247] = { 112363 },
            [41303] = { 115558, 115560 },
            [41311] = { 108556, 115593 },
            [41335] = { 115549 },
            [41487] = { 114107 },
            [41516] = { 114110, 114111 },
            [41531] = { 115535 },
            [41547] = { 111013, 115585 },
            [41601] = { 115556 },
            [41607] = { 115559 },
            [41681] = { 111003 },
            [41705] = { 110997, 115587 },
            [41746] = { 112345, 115533 },
            [41757] = { 112315 },
            [41775] = { 115552 },
            [41944] = { 111008 },
            [42169] = { 114108, 114109 },
            [42181] = { 114113 },
            [42195] = { 114114 },
            [42254] = { 115555 },
            [42263] = { 114106 },
            [42294] = { 115557 },
            [42315] = { 112277 },
            [42358] = { 115553 },
            [42368] = { 112325 },
            [42504] = { 114105 },
            [42585] = { 114112 },
            [42738] = { 111621 },
            [42848] = { 114104 },
            [42933] = { 115554 },
            [42974] = { 112827 },
            [43002] = { 112841 },
            [43010] = { 112860 },
            [43044] = { 112957 },
            [43148] = { 112967 },
            [44187] = { 111020 },
        },
        mainHandLowerMythic = {
            [41247] = { 112361 },
            [41303] = { 115546, 115548 },
            [41311] = { 108552 },
            [41335] = { 115537 },
            [41487] = { 114133 },
            [41516] = { 114136, 114137 },
            [41531] = { 115526 },
            [41547] = { 108908, 115591 },
            [41601] = { 115544 },
            [41607] = { 115547 },
            [41681] = { 110998 },
            [41705] = { 108930, 115589 },
            [41746] = { 112341, 114088 },
            [41757] = { 112312 },
            [41775] = { 115540 },
            [41944] = { 109545 },
            [42169] = { 114134, 114135 },
            [42181] = { 114139 },
            [42195] = { 114140 },
            [42254] = { 115543 },
            [42263] = { 114132 },
            [42315] = { 112282 },
            [42358] = { 115541 },
            [42368] = { 112328 },
            [42504] = { 114131 },
            [42585] = { 114138 },
            [42738] = { 111619 },
            [42848] = { 114130 },
            [42933] = { 115542 },
            [42974] = { 112825 },
            [43002] = { 112842 },
            [43010] = { 112862 },
            [43044] = { 112959 },
            [43148] = { 112964 },
            [44187] = { 115499 },
        },
        mainHandHigherMythic = {
            [41247] = { 112363 },
            [41303] = { 115558, 115560 },
            [41311] = { 108556, 115593, 115595 },
            [41335] = { 115549 },
            [41487] = { 114107 },
            [41516] = { 114110, 114111 },
            [41531] = { 115535 },
            [41547] = { 111013, 115585 },
            [41601] = { 115556 },
            [41607] = { 115559 },
            [41681] = { 111003 },
            [41705] = { 110997, 115587 },
            [41746] = { 112345, 115533 },
            [41757] = { 112315 },
            [41775] = { 115552 },
            [41944] = { 111008 },
            [42169] = { 114108, 114109 },
            [42181] = { 114113 },
            [42195] = { 114114 },
            [42254] = { 115555 },
            [42263] = { 114106 },
            [42294] = { 115557 },
            [42315] = { 112277 },
            [42358] = { 115553 },
            [42368] = { 112325 },
            [42504] = { 114105 },
            [42585] = { 114112 },
            [42738] = { 111621 },
            [42848] = { 114104 },
            [42933] = { 115554 },
            [42974] = { 112827 },
            [43002] = { 112841 },
            [43010] = { 112860 },
            [43044] = { 112957 },
            [43148] = { 112967 },
            [44187] = { 111020 },
        },
        offHandLowerNonMythic = {
            [41240] = { 112394 },
            [41317] = { 108564 },
            [41491] = { 115538 },
            [41511] = { 114141 },
            [41564] = { 108910 },
            [42188] = { 114142 },
            [42308] = { 112354 },
            [42370] = { 115539 },
        },
        offHandHigherNonMythic = {
            [41240] = { 112395 },
            [41317] = { 108569 },
            [41491] = { 115550 },
            [41511] = { 114115 },
            [41564] = { 111018 },
            [42188] = { 114116 },
            [42308] = { 112350 },
            [42370] = { 115551 },
        },
        offHandLowerMythic = {
            [41240] = { 112394 },
            [41317] = { 108564 },
            [41491] = { 115538 },
            [41511] = { 114141 },
            [41564] = { 108910 },
            [42188] = { 114142 },
            [42308] = { 112354 },
            [42370] = { 115539 },
        },
        offHandHigherMythic = {
            [41240] = { 112395 },
            [41317] = { 108569 },
            [41491] = { 115550 },
            [41511] = { 114115 },
            [41564] = { 111018 },
            [42188] = { 114116 },
            [42308] = { 112350 },
            [42370] = { 115551 },
        },
    },

    -- Covenant Sanctum weapon-vendor zones. Used by the UI to hint where
    -- the player should go to redeem Anima Spherules/Beads for weapons.
    -- Keyed by C_Covenants.GetActiveCovenantID() return value:
    --   1 = Kyrian, 2 = Venthyr, 3 = Night Fae, 4 = Necrolord.
    -- We intentionally don't name specific vendor NPCs: Wowhead's vendor
    -- list had data errors (same NPC names repeated across covenants) so
    -- we stick with covenant + zone, which is authoritative. Each covenant
    -- has 4 weapon vendors (one per difficulty tier) inside the Sanctum;
    -- all 4 offer identical inventories (confirmed 2026-04-22 via /rr
    -- vendorscan on all 4 Kyrian vendors). So directing the player to
    -- the zone is sufficient.
    --
    -- Fields:
    --   covenantName    -- display name, colored with covenantColor.
    --   covenantColor   -- WoW color escape in AARRGGBB hex (no "|c" prefix).
    --                      These match the in-game covenant theme colors
    --                      (Kyrian=blue, Venthyr=red, Night Fae=purple,
    --                      Necrolord=green). Approximations; tune in-game
    --                      if they clash with Photek's expectation.
    --   zoneMain        -- zone name (Bastion, Revendreth, etc.), colored
    --                      with covenantColor.
    --   zoneSub         -- subzone/Sanctum name (Elysian Hold, Sinfall),
    --                      rendered in white for visual separation.
    weaponVendors = {
        [1] = {  -- Kyrian (blue)
            covenantName  = "Kyrian",
            covenantColor = "ff00a2ff",
            zoneMain      = "Bastion",
            zoneSub       = "Elysian Hold",
        },
        [2] = {  -- Venthyr (red)
            covenantName  = "Venthyr",
            covenantColor = "ffe50000",
            zoneMain      = "Revendreth",
            zoneSub       = "Sinfall",
        },
        [3] = {  -- Night Fae (purple)
            covenantName  = "Night Fae",
            covenantColor = "ff9b59ff",
            zoneMain      = "Ardenweald",
            zoneSub       = "Heart of the Forest",
        },
        [4] = {  -- Necrolord (green)
            covenantName  = "Necrolord",
            covenantColor = "ff34a73f",
            zoneMain      = "Maldraxxus",
            zoneSub       = "Seat of the Primus",
        },
    },

    bosses = {
        {
            index              = 1,
            name               = "Shriekwing",
            journalEncounterID = 2393,
            mapID              = 1735,
            coord              = { 0.571, 0.807 },  -- From /rr record dump 2026-04-21
            aliases            = {},
            soloTip            = "Standard Nuke",
            achievements       = {
                { id = 14293, name = "Blind as a Bat", meta = true },
            },
            loot = {
                { id = 183034, slot = "Back",  name = "Cowled Batwing Cloak",           sources = { [17]=115841, [14]=114547, [15]=115842, [16]=115843 } },
                { id = 183027, slot = "Feet",  name = "Errant Crusader's Greaves",      sources = { [17]=115263, [14]=114540, [15]=115264, [16]=115265 } },
                { id = 182979, slot = "Feet",  name = "Slippers of the Forgotten Heretic", sources = { [17]=115101, [14]=114492, [15]=115102, [16]=115129 } },
                { id = 182993, slot = "Legs",  name = "Chiropteran Leggings",           sources = { [17]=115152, [14]=114506, [15]=115153, [16]=115154 } },
                { id = 182976, slot = "Waist", name = "Double-Chained Utility Belt",    sources = { [17]=115185, [14]=114489, [15]=115186, [16]=115187 } },
            },
            specialLoot = {},
        },
        {
            index              = 2,
            name               = "Huntsman Altimor",
            journalEncounterID = 2429,
            mapID              = 1735,
            coord              = { 0.674, 0.531 },  -- From /rr record dump 2026-04-21
            aliases            = { "Altimor" },
            soloTip            = "Standard Nuke",
            achievements       = {
                { id = 14523, name = "Taking Care of Business", meta = true },
            },
            loot = {
                { id = 182988, slot = "Chest", name = "Master Huntsman's Bandolier", sources = { [17]=115197, [14]=114501, [15]=115198, [16]=115199 } },
                { id = 182995, slot = "Waist", name = "Spell-Woven Tourniquet",      sources = { [17]=115155, [14]=114508, [15]=115156, [16]=115157 } },
                { id = 182996, slot = "Wrist", name = "Grim Pursuant's Maille",      sources = { [17]=115107, [14]=114509, [15]=115108, [16]=115132 } },
                { id = 183018, slot = "Wrist", name = "Hellhound Cuffs",             sources = { [17]=115257, [14]=114531, [15]=115258, [16]=115259 } },
            },
            specialLoot = {},
        },
        {
            index              = 3,
            name               = "Sun King's Salvation",
            journalEncounterID = 2422,
            mapID              = 1746,
            coord              = { 0.528, 0.648 },  -- From /rr record dump 2026-04-21
            aliases            = { "Sun King", "Kael'thas" },
            soloTip            = "You have to heal Kael to win this fight. If you don't have an ability to heal others, you will need to bring bandages. Kill adds, and heal Kael when you get the chance.",
            achievements       = {
                { id = 14608, name = "Burning Bright", meta = true },
            },
            loot = {
                { id = 183033, slot = "Back",  name = "Mantle of Manifest Sins",    sources = { [17]=115847, [14]=114546, [15]=115848, [16]=115849 } },
                { id = 182986, slot = "Chest", name = "High Torturer's Smock",      sources = { [17]=115105, [14]=114499, [15]=115106, [16]=115131 } },
                { id = 183007, slot = "Hands", name = "Bleakwing Assassin's Grips", sources = { [17]=115161, [14]=114520, [15]=115162, [16]=115163 } },
                { id = 183025, slot = "Waist", name = "Stoic Guardsman's Belt",     sources = { [17]=115260, [14]=114538, [15]=115261, [16]=115262 } },
                { id = 182977, slot = "Wrist", name = "Bangles of Errant Pride",    sources = { [17]=115188, [14]=114490, [15]=115189, [16]=115190 } },
            },
            specialLoot = {},
        },
        {
            index              = 4,
            name               = "Artificer Xy'mox",
            journalEncounterID = 2418,
            mapID              = 1745,
            coord              = { 0.652, 0.280 },  -- From /rr record dump 2026-04-21
            aliases            = { "Xy'mox" },
            soloTip            = "Standard Nuke",
            achievements       = {
                { id = 14617, name = "Private Stock", meta = true },
            },
            loot = {
                { id = 182987, slot = "Chest", name = "Breastplate of Cautious Calculation", sources = { [17]=115233, [14]=114500, [15]=115234, [16]=115235 } },
                { id = 183012, slot = "Legs",  name = "Greaves of Enigmatic Energies",       sources = { [17]=115218, [14]=114525, [15]=115219, [16]=115220 } },
                { id = 183004, slot = "Waist", name = "Shadewarped Sash",                    sources = { [17]=115111, [14]=114517, [15]=115112, [16]=115134 } },
                { id = 183019, slot = "Wrist", name = "Precisely Calibrated Chronometer",   sources = { [17]=115170, [14]=114532, [15]=115171, [16]=115172 } },
            },
            specialLoot = {},
        },
        {
            index              = 5,
            name               = "Hungering Destroyer",
            journalEncounterID = 2428,
            mapID              = 1735,
            coord              = { 0.383, 0.348 },  -- From /rr record dump 2026-04-21
            aliases            = { "Destroyer" },
            soloTip            = "Standard Nuke",
            achievements       = {
                { id = 14376, name = "Feed the Beast", meta = true },
            },
            loot = {
                { id = 183000, slot = "Chest",    name = "Consumptive Chainmail Carapace", sources = { [17]=115206, [14]=114513, [15]=115207, [16]=115208 } },
                { id = 183009, slot = "Chest",    name = "Miasma-Lacquered Jerkin",        sources = { [17]=115164, [14]=114522, [15]=115165, [16]=115166 } },
                { id = 183001, slot = "Head",     name = "Helm of Insatiable Appetite",    sources = { [17]=115209, [14]=114514, [15]=115210, [16]=115211 } },
                { id = 182992, slot = "Legs",     name = "Endlessly Gluttonous Greaves",   sources = { [17]=115236, [14]=114505, [15]=115237, [16]=115238 } },
                { id = 183024, slot = "Legs",     name = "Volatile Shadestitch Legguards", sources = { [17]=115173, [14]=114537, [15]=115174, [16]=115175 } },
                { id = 182994, slot = "Shoulder", name = "Epaulets of Overwhelming Force", sources = { [17]=115239, [14]=114507, [15]=115240, [16]=115241 } },
                { id = 183028, slot = "Waist",    name = "Cinch of Infinite Tightness",    sources = { [17]=115127, [14]=114541, [15]=115128, [16]=115142 } },
            },
            specialLoot = {},
        },
        {
            index              = 6,
            name               = "Lady Inerva Darkvein",
            journalEncounterID = 2420,
            mapID              = 1744,
            coord              = { 0.387, 0.443 },  -- From /rr record dump 2026-04-21
            aliases            = { "Inerva", "Darkvein" },
            soloTip            = "Standard Nuke",
            achievements       = {
                { id = 14524, name = "I Don't Know What I Expected", meta = true },
            },
            loot = {
                { id = 183026, slot = "Hands", name = "Gloves of Phantom Shadows", sources = { [17]=115176, [14]=114539, [15]=115177, [16]=115178 } },
                { id = 183021, slot = "Head",  name = "Confidant's Favored Cap",   sources = { [17]=115121, [14]=114534, [15]=115122, [16]=115139 } },
                { id = 182985, slot = "Legs",  name = "Memento-Laden Cuisses",     sources = { [17]=115194, [14]=114498, [15]=115195, [16]=115196 } },
                { id = 183015, slot = "Waist", name = "Binding of Warped Desires", sources = { [17]=115254, [14]=114528, [15]=115255, [16]=115256 } },
            },
            specialLoot = {},
        },
        {
            index              = 7,
            name               = "The Council of Blood",
            journalEncounterID = 2426,
            mapID              = 1750,
            coord              = { 0.671, 0.542 },  -- From /rr record dump 2026-04-21
            aliases            = { "Council of Blood", "Council" },
            soloTip            = "Nuke down the bosses. During dance phase, run to the spotlight and get ready. Just walk in the direction of the other dancers 4-5 times and the phase will end. If you kill the bosses fast enough, you can skip the dance phase.\nMythic only: while dancing, keep jumping! You must do this to clear a debuff or you will die.",
            achievements       = {
                { id = 14619, name = "Pour Decision Making", meta = true },
            },
            loot = {
                { id = 182989, slot = "Chest", name = "Corset of the Deft Duelist",      sources = { [17]=115149, [14]=114502, [15]=115150, [16]=115151 } },
                { id = 183030, slot = "Feet",  name = "Enchanted Toe-Tappers",           sources = { [17]=115182, [14]=114543, [15]=115183, [16]=115184 } },
                { id = 183023, slot = "Feet",  name = "Sparkling Glass Slippers",        sources = { [17]=115125, [14]=114536, [15]=115126, [16]=115141 } },
                { id = 182983, slot = "Feet",  name = "Stoneguard Attendant's Boots",    sources = { [17]=115227, [14]=114496, [15]=115228, [16]=115229 } },
                { id = 183014, slot = "Hands", name = "Castellan's Chainlink Grips",     sources = { [17]=115221, [14]=114527, [15]=115222, [16]=115223 } },
                { id = 183011, slot = "Legs",  name = "Courtier's Costume Trousers",     sources = { [17]=115115, [14]=114524, [15]=115116, [16]=115136 } },
            },
            specialLoot = {},
        },
        {
            index              = 8,
            name               = "Sludgefist",
            journalEncounterID = 2394,
            mapID              = 1735,
            coord              = { 0.633, 0.806 },  -- From /rr record dump 2026-04-21
            aliases            = {},
            soloTip            = "Standard Nuke",
            achievements       = {
                { id = 14294, name = "Dirtflap's Revenge", meta = true },
            },
            loot = {
                { id = 182999, slot = "Chest", name = "Rampaging Giant's Chestplate",      sources = { [17]=115245, [14]=114512, [15]=115246, [16]=115247 } },
                { id = 183006, slot = "Feet",  name = "Stoneclas Stompers",                sources = { [17]=115215, [14]=114519, [15]=115216, [16]=115217 } },
                { id = 182984, slot = "Hands", name = "Colossal Plate Gauntlets",          sources = { [17]=115230, [14]=114497, [15]=115231, [16]=115232 } },
                { id = 183022, slot = "Hands", name = "Impossibly Oversized Mitts",        sources = { [17]=115123, [14]=114535, [15]=115124, [16]=115140 } },
                { id = 182981, slot = "Legs",  name = "Leggings of Lethal Reverberations", sources = { [17]=115103, [14]=114494, [15]=115104, [16]=115130 } },
                { id = 183005, slot = "Waist", name = "Heedless Pugilist's Harness",       sources = { [17]=115158, [14]=114518, [15]=115159, [16]=115160 } },
                { id = 183016, slot = "Waist", name = "Load-Bearing Belt",                 sources = { [17]=115224, [14]=114529, [15]=115225, [16]=115226 } },
            },
            specialLoot = {},
        },
        {
            index              = 9,
            name               = "Stone Legion Generals",
            journalEncounterID = 2425,
            mapID              = 1747,
            coord              = { 0.292, 0.482 },  -- From /rr record dump 2026-04-21
            aliases            = { "Stone Legion", "SLG", "Generals" },
            soloTip            = "Kill the trash and approach the bosses to start the encounter. Walk over anima orbs to collect them, and bring them to Prince Renathal to free him (x2). When he's free, attack the bosses. If you kill the bosses fast enough, you can skip this mechanic.",
            achievements       = {
                { id = 14525, name = "Feed Me, Seymour!", meta = true },
            },
            loot = {
                { id = 183032, slot = "Back",     name = "Crest of the Legionnaire General", sources = { [17]=115844, [14]=114545, [15]=115845, [16]=115846 } },
                { id = 182998, slot = "Chest",    name = "Robes of the Cursed Commando",     sources = { [17]=115109, [14]=114511, [15]=115110, [16]=115133 } },
                { id = 182991, slot = "Hands",    name = "Oathsworn Soldier's Gauntlets",    sources = { [17]=115203, [14]=114504, [15]=115204, [16]=115205 } },
                { id = 183002, slot = "Legs",     name = "Ceremonial Parade Legguards",      sources = { [17]=115248, [14]=114515, [15]=115249, [16]=115250 } },
                { id = 183029, slot = "Shoulder", name = "Wicked Flanker's Gorget",          sources = { [17]=115179, [14]=114542, [15]=115180, [16]=115181 } },
            },
            specialLoot = {},
        },
        {
            index              = 10,
            name               = "Sire Denathrius",
            journalEncounterID = 2424,
            mapID              = 1747,
            coord              = { 0.492, 0.520 },  -- From /rr record dump 2026-04-21
            aliases            = { "Denathrius", "Sire" },
            soloTip            = "Standard Nuke",
            achievements       = {
                { id = 14610, name = "Clear Conscience", meta = true },
            },
            -- Denathrius drops ONLY 4 armor items via the Encounter Journal
            -- (verified 2026-04-21 via /rr ejdiff 2424 list — EJ reports
            -- 85 total items, 4 armor + 4 spherules + 1 ring + 4 trinkets
            -- + 12 legendary memories + 60 conduits). ATT's Instances.lua
            -- file previously indicated 13 armor items attributed to
            -- encID 2424, but 9 of those 13 don't appear in the live EJ
            -- — ATT appears to have stale pre-patch data for this boss.
            -- The 4 below ARE the complete armor drop set. Not tracked
            -- here: the ring, trinkets, conduits, and memories — schema
            -- currently only covers per-class armor/weapons. If we ever
            -- add non-armor tracking, this boss will need to be revisited.
            loot = {
                { id = 182997, slot = "Head",     name = "Diadem of Imperious Desire", sources = { [17]=115242, [14]=114510, [15]=115243, [16]=115244 } },
                { id = 182980, slot = "Head",     name = "Sadist's Sinister Mask",     sources = { [17]=115146, [14]=114493, [15]=115147, [16]=115148 } },
                { id = 183003, slot = "Shoulder", name = "Pauldrons of Fatal Finality", sources = { [17]=115212, [14]=114516, [15]=115213, [16]=115214 } },
                { id = 183020, slot = "Shoulder", name = "Shawl of the Penitent",      sources = { [17]=115119, [14]=114533, [15]=115120, [16]=115138 } },
            },
            specialLoot = {},
        },
    },  -- bosses

    routing = {

        -- 1. Shriekwing
        -- Recorded 2026-04-21 via /rr record. Entry dialog plays on
        -- arrival in the first room; walk in, watch dialog, engage.
        {
            step      = 1,
            priority  = 1,
            bossIndex = 1,
            title     = "Shriekwing",
            requires  = {},
            segments  = {
                {
                    mapID  = 1735,
                    kind   = "path",
                    note   = "Upon zoning in, go up the stairs into the first room and watch some dialog. After that, engage Shriekwing.",
                    points = {
                        { 0.384, 0.808 },
                        { 0.571, 0.807 },
                    },
                },
            },
        },

        -- 2. Huntsman Altimor
        -- Recorded 2026-04-21 via /rr record. Linear walk north from
        -- Shriekwing's room; General Draven opens a gate after you
        -- clear trash. No teleport; all one mapID.
        {
            step      = 2,
            priority  = 2,
            bossIndex = 2,
            title     = "Huntsman Altimor",
            requires  = { 1 },
            segments  = {
                {
                    mapID  = 1735,
                    kind   = "path",
                    note   = "After killing Shriekwing, follow the north path out of the room and go down the stairs. Kill the trash, and General Draven will come open the gate. Kill a few trash mobs then engage Huntsman Altimor.",
                    points = {
                        { 0.592, 0.766 },
                        { 0.592, 0.689 },
                        { 0.616, 0.678 },
                        { 0.629, 0.642 },
                        { 0.619, 0.604 },
                        { 0.593, 0.587 },
                        { 0.567, 0.598 },
                        { 0.554, 0.632 },
                        { 0.563, 0.669 },
                        { 0.579, 0.688 },
                        { 0.617, 0.689 },
                        { 0.646, 0.660 },
                        { 0.662, 0.632 },
                        { 0.674, 0.531 },
                    },
                },
            },
        },

        -- 5. Hungering Destroyer
        -- Recorded 2026-04-21 via /rr record. Path leads to a small
        -- back room where NPCs stand next to a sewer drop; jump into
        -- the sewer to descend to the Destroyer's room.
        {
            step      = 3,
            priority  = 3,
            bossIndex = 5,
            title     = "Hungering Destroyer",
            requires  = { 2 },
            segments  = {
                {
                    mapID  = 1735,
                    kind   = "path",
                    note   = "After killing Huntsman Altimor, follow the path to a small room at the back, and jump into the sewer that the NPCs are standing next to. Make your way down the path to find Hungering Destroyer.",
                    points = {
                        { 0.675, 0.459 },
                        { 0.634, 0.435 },
                        { 0.635, 0.372 },
                        { 0.674, 0.333 },
                        { 0.637, 0.303 },
                        { 0.637, 0.160 },
                        { 0.607, 0.166 },
                        { 0.588, 0.180 },
                        { 0.586, 0.211 },
                        { 0.568, 0.237 },
                        { 0.501, 0.346 },
                        { 0.383, 0.348 },
                    },
                },
            },
        },

        -- 6. Lady Inerva Darkvein
        -- Recorded 2026-04-21 via /rr record. First multi-segment route
        -- in CN: stairs transition player from The Grand Walk (1735)
        -- to The Purloined Stores (1744). No teleport; natural floor
        -- transition as the player walks up stairs.
        {
            step      = 4,
            priority  = 4,
            bossIndex = 6,
            title     = "Lady Inerva Darkvein",
            requires  = { 5 },
            segments  = {
                {
                    mapID  = 1735,
                    kind   = "path",
                    note   = "After killing Hungering Destroyer, take the stairs going up to The Purloined Stores.",
                    points = {
                        { 0.332, 0.351 },
                        { 0.305, 0.433 },
                        { 0.304, 0.467 },
                        { 0.319, 0.498 },
                        { 0.350, 0.500 },
                    },
                },
                {
                    mapID  = 1744,
                    kind   = "path",
                    note   = "After arriving in the room with Lady Inerva Darkvein, kill all the trash to engage the boss after some NPC dialog.",
                    points = {
                        { 0.465, 0.556 },
                        { 0.449, 0.445 },
                        { 0.387, 0.443 },
                    },
                },
            },
        },

        -- 3. Sun King's Salvation
        -- Recorded 2026-04-21 via /rr record. 4-segment route spanning
        -- 4 submaps. After clearing the Catacombs wing (Altimor ->
        -- Destroyer -> Inerva), General Draven escorts the player back
        -- to the raid entrance in The Grand Walk to begin the Royal
        -- Quarters wing.
        --
        -- `requires = {6}` (Lady Inerva) rather than `{1}` (Shriekwing)
        -- per the DAG. Blizzard's encounter DAG only strictly gates Sun
        -- King on Shriekwing, so either would be "correct" vs. the game.
        -- But the Boss Progress panel colors bosses differently based
        -- on available-vs-active-vs-locked state, and a "{1}" declaration
        -- makes Sun King render as "available" (white) the entire way
        -- through the Altimor/Destroyer/Inerva clears -- which reads to
        -- the player as "you're forgetting a boss." Declaring {6}
        -- encodes our route order explicitly: Sun King becomes the
        -- next target immediately after Inerva dies, matching the
        -- physical path we've recorded. Fixed 2026-04-22 after Photek's
        -- final CN walkthrough surfaced the white-state visual.
        {
            step      = 5,
            priority  = 5,
            bossIndex = 3,
            title     = "Sun King's Salvation",
            requires  = { 6 },
            segments  = {
                {
                    mapID  = 1744,
                    kind   = "path",
                    note   = "After killing Lady Inerva Darkvein, follow the path to take the exit General Draven is standing in. He will lead you back to the main entrance of the raid in The Grand Walk.",
                    points = {
                        { 0.389, 0.444 },
                        { 0.502, 0.485 },
                        { 0.498, 0.706 },
                        { 0.516, 0.759 },
                        { 0.515, 0.921 },
                    },
                },
                {
                    mapID  = 1735,
                    kind   = "path",
                    note   = "After arriving back in The Grand Walk, follow the path up to where you killed Shriekwing. This time, take the path right/south to end up in Halls of the Faithful.",
                    points = {
                        { 0.411, 0.760 },
                        { 0.412, 0.807 },
                        { 0.557, 0.806 },
                        { 0.591, 0.876 },
                    },
                },
                {
                    mapID  = 1745,
                    kind   = "path",
                    note   = "In Halls of the Faithful, wind your way around to the room overlooking the dancers. Clear the trash, and the NPCs will enter the room and open both gates. Follow the path opened by Prince Renathal, and make your way up the stairs to Pride's Prison.",
                    points = {
                        { 0.200, 0.418 },
                        { 0.201, 0.499 },
                        { 0.241, 0.542 },
                        { 0.266, 0.539 },
                        { 0.304, 0.499 },
                        { 0.311, 0.455 },
                        { 0.388, 0.459 },
                        { 0.390, 0.692 },
                        { 0.478, 0.702 },
                        { 0.510, 0.789 },
                        { 0.540, 0.846 },
                        { 0.531, 0.860 },
                        { 0.539, 0.880 },
                    },
                },
                {
                    mapID  = 1746,
                    kind   = "path",
                    note   = "Upon reaching Pride's Prison, follow the path to engage Sun King's Salvation.",
                    points = {
                        { 0.136, 0.341 },
                        { 0.151, 0.265 },
                        { 0.209, 0.278 },
                        { 0.332, 0.202 },
                        { 0.525, 0.200 },
                        { 0.528, 0.648 },
                    },
                },
            },
        },

        -- 4. Artificer Xy'mox
        -- Recorded 2026-04-21 via /rr record. Back down the stairs from
        -- Pride's Prison, then around the Halls of the Faithful perimeter.
        -- Prince Renathal opens the gate after trash clear.
        {
            step      = 6,
            priority  = 6,
            bossIndex = 4,
            title     = "Artificer Xy'mox",
            requires  = { 3 },
            segments  = {
                {
                    mapID  = 1746,
                    kind   = "path",
                    note   = "After defeating Sun King's Salvation, go back the way you came and return down the stairs to Halls of the Faithful.",
                    points = {
                        { 0.529, 0.644 },
                        { 0.528, 0.202 },
                        { 0.263, 0.192 },
                        { 0.202, 0.282 },
                        { 0.151, 0.271 },
                        { 0.126, 0.320 },
                        { 0.137, 0.353 },
                    },
                },
                {
                    mapID  = 1745,
                    kind   = "path",
                    note   = "After arriving back in Halls of the Faithful, follow the path all the way around to Artificer Xy'mox. Kill the trash, and Prince Renathal will show up to open the gate.",
                    points = {
                        { 0.531, 0.864 },
                        { 0.560, 0.826 },
                        { 0.478, 0.756 },
                        { 0.474, 0.620 },
                        { 0.561, 0.566 },
                        { 0.651, 0.563 },
                        { 0.652, 0.280 },
                    },
                },
            },
        },

        -- 7. The Council of Blood
        -- Recorded 2026-04-21 via /rr record. Backtrack from Xy'mox's
        -- room, then stairs transition into Feast of Arrogance (1750).
        -- Final boss of the Royal Quarters wing. Gated by Sun King AND
        -- Xy'mox per the DAG.
        {
            step      = 7,
            priority  = 7,
            bossIndex = 7,
            title     = "The Council of Blood",
            requires  = { 3, 4 },
            segments  = {
                {
                    mapID  = 1745,
                    kind   = "path",
                    note   = "After defeating Artificer Xy'mox, backtrack out of the room and follow the path to the stairs leading to Feast of Arrogance.",
                    points = {
                        { 0.651, 0.284 },
                        { 0.650, 0.568 },
                        { 0.557, 0.566 },
                        { 0.531, 0.526 },
                    },
                },
                {
                    mapID  = 1750,
                    kind   = "path",
                    note   = "Once you arrive in Feast of Arrogance, follow the path to find The Council of Blood at the far end of the room.",
                    points = {
                        { 0.338, 0.162 },
                        { 0.361, 0.178 },
                        { 0.364, 0.290 },
                        { 0.456, 0.542 },
                        { 0.671, 0.542 },
                    },
                },
            },
        },

        -- 8. Sludgefist
        -- Recorded 2026-04-21 via /rr record. 3-segment route: back to
        -- Halls of the Faithful, walk to Prince Renathal's mirror
        -- teleporter (shortcut back to The Grand Walk), then to where
        -- Shriekwing was. Sludgefist jumps down after NPC dialog.
        -- Note: the mirror teleport between segments 2 and 3 is
        -- implicit (modeled as path-ending-at-mirror, path-starting-in-
        -- destination-map) rather than an explicit teleport segment,
        -- because it's a single-destination mirror, not a selector.
        {
            step      = 8,
            priority  = 8,
            bossIndex = 8,
            title     = "Sludgefist",
            requires  = { 6, 7 },
            segments  = {
                {
                    mapID  = 1750,
                    kind   = "path",
                    note   = "After killing Council of Blood, take the south stairwell out of the room and return to the Halls of the Faithful.",
                    points = {
                        { 0.667, 0.542 },
                        { 0.453, 0.540 },
                        { 0.355, 0.835 },
                        { 0.368, 0.875 },
                        { 0.348, 0.912 },
                    },
                },
                {
                    mapID  = 1745,
                    kind   = "path",
                    note   = "Upon landing back in Halls of the Faithful, follow the path to the right and Prince Renathal will guide you to a mirror portal. Take this teleport for a shortcut back to the main entrance lobby in The Grand Walk.",
                    points = {
                        { 0.525, 0.857 },
                        { 0.582, 0.826 },
                        { 0.653, 0.827 },
                        { 0.652, 0.850 },
                    },
                },
                {
                    mapID  = 1735,
                    kind   = "path",
                    note   = "After teleporting back to The Grand Walk, follow the path up to where you killed Shriekwing (again). After some dialog, Sludgefist will jump down to fight.",
                    points = {
                        { 0.411, 0.810 },
                        { 0.633, 0.806 },
                    },
                },
            },
        },

        -- 9. Stone Legion Generals
        -- Recorded 2026-04-21 via /rr record. Mirror teleport from The
        -- Grand Walk (behind Sludgefist) lands in Nightcloak Sanctum
        -- (1747), then walk to the bosses.
        {
            step      = 9,
            priority  = 9,
            bossIndex = 9,
            title     = "Stone Legion Generals",
            requires  = { 8 },
            segments  = {
                {
                    mapID  = 1735,
                    kind   = "path",
                    note   = "After killing Sludgefist, travel up the stairs behind him and walk through the mirror teleporter to land in Nightcloak Sanctum.",
                    points = {
                        { 0.631, 0.806 },
                        { 0.644, 0.754 },
                        { 0.670, 0.733 },
                        { 0.696, 0.755 },
                        { 0.700, 0.778 },
                        { 0.740, 0.811 },
                    },
                },
                {
                    mapID  = 1747,
                    kind   = "path",
                    note   = "After taking the teleporter to Nightcloak Sanctum, follow the path around to the Stone Legion Generals.",
                    points = {
                        { 0.617, 0.320 },
                        { 0.546, 0.248 },
                        { 0.448, 0.234 },
                        { 0.292, 0.482 },
                    },
                },
            },
        },

        -- 10. Sire Denathrius
        -- Recorded 2026-04-21 via /rr record. Short walk from SLG's
        -- room to Denathrius within the same submap (Nightcloak
        -- Sanctum, 1747).
        --
        -- Note: the encounter auto-transitions the player to a second
        -- submap called "The Observatorium" (mapID 1748) partway
        -- through the fight. This is not a travel step -- no player
        -- navigation needed. Recording captured one Observatorium
        -- coord post-fight ({ 0.486, 0.597 } on mapID 1748) which we
        -- retain here for reference in case future logic (e.g. the
        -- recorder's post-encounter teleport-out path) needs it.
        {
            step      = 10,
            priority  = 10,
            bossIndex = 10,
            title     = "Sire Denathrius",
            requires  = { 9 },
            segments  = {
                {
                    mapID  = 1747,
                    kind   = "path",
                    note   = "After killing Stone Legion Generals, simply walk into the room where Sire Denathrius is waiting for you.",
                    points = {
                        { 0.352, 0.518 },
                        { 0.433, 0.516 },
                        { 0.492, 0.520 },
                    },
                },
            },
        },

    },  -- routing
}
