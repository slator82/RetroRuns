-------------------------------------------------------------------------------
-- RetroRuns Data -- Stormstout Brewery
-- Mists of Pandaria dungeon, Patch 5.0.4  |  instanceID: 961  |  journalInstanceID: 302
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[302] = {
    kind              = "dungeon",
    instanceID        = 961,
    journalInstanceID = 302,
    name              = "Stormstout Brewery",
    expansion         = "Mists of Pandaria",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 14, 15 },
    patch             = "5.0.4",
    timewalking       = true,

    entrance = {
        mapID = 376,
        x     = 0.3612,
        y     = 0.6940,
    },

    gloryMeta = {
        id   = 6927,
        name = "Glory of the Pandaria Hero",
        rewardItemID       = 87769,
        rewardMountSpellID = 127156,
        rewardName         = "Crimson Cloud Serpent",
    },

    bosses = {
        {
            index              = 1,
            name               = "Ook-Ook",
            journalEncounterID = 668,
            -- Criterion prose reads "Ook-ook" and spells the name differently.
            scenarioCriteriaID = 19236,
            achievements       = {
                { id = 6089, name = "Keep Rollin' Rollin' Rollin'", meta = true, soloable = "kinda" },
            },
            loot = {
                { id = 143957, slot = "Chest", name = "Nimbletoe Chestguard", sources = { [14]=84292, [15]=84292 } },
                { id = 143989, slot = "Feet", name = "Barreldodger Boots", sources = { [14]=84324, [15]=84324 } },
                { id = 144084, slot = "Weapon", name = "Ook's Hozen Slicer", sources = { [14]=84390, [15]=84390 } },
                { id = 144087, slot = "Wrist", name = "Bracers of Displaced Air", sources = { [14]=84393, [15]=84393 } },
            },
        },
        {
            index              = 2,
            name               = "Hoptallus",
            journalEncounterID = 669,
            achievements       = {
            },
            loot = {
                { id = 144121, slot = "Back", name = "Cloak of Hidden Flasks", sources = { [14]=84421, [15]=84421 } },
                { id = 143975, slot = "Legs", name = "Hopping Mad Leggings", sources = { [14]=84310, [15]=84310 } },
                { id = 144092, slot = "Off-hand", name = "Bottle of Potent Potables", sources = { [14]=84398, [15]=84398 } },
                { id = 144120, slot = "Waist", name = "Belt of Brazen Inebriation", sources = { [14]=84420, [15]=84420 } },
                { id = 144088, slot = "Wrist", name = "Bubble-Breaker Bracers", sources = { [14]=84394, [15]=84394 } },
            },
        },
        {
            index              = 3,
            name               = "Yan-Zhu the Uncasked",
            journalEncounterID = 670,
            achievements       = {
                { id = 6400, name = "How Did He Get Up There?", meta = true, soloable = "yes" },
                { id = 6402, name = "Ling-Ting's Herbal Journey", meta = true, soloable = "yes" },
                { id = 6420, name = "Hopocalypse Now!", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 143958, slot = "Chest", name = "Uncasked Chestguard", sources = { [14]=84293, [15]=84293 } },
                { id = 143976, slot = "Legs", name = "Sudsy Legplates", sources = { [14]=84311, [15]=84311 } },
                { id = 144089, slot = "Ranged", name = "Yan-Zhu's Pressure Valve", sources = { [14]=84395, [15]=84395 } },
                { id = 143969, slot = "Shoulder", name = "Fizzy Spaulders", sources = { [14]=84304, [15]=84304 } },
                { id = 144124, slot = "Two-Hand", name = "Wort Stirring Rod", sources = { [14]=84422, [15]=84422 } },
                { id = 144082, slot = "Waist", name = "Fermenting Belt", sources = { [14]=84388, [15]=84388 } },
                { id = 144085, slot = "Weapon", name = "Gao's Keg Tapper", sources = { [14]=84391, [15]=84391 } },
                { id = 144217, slot = "Weapon", name = "Inelava, Spirit of Inebriation", sources = { [14]=84485, [15]=84485 } },
            },
        },
    },
}
