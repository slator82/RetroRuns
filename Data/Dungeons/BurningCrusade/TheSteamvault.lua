-------------------------------------------------------------------------------
-- RetroRuns Data -- The Steamvault
-- Burning Crusade dungeon, Patch 2.0.3  |  instanceID: 545  |  journalInstanceID: 261
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[261] = {
    kind              = "dungeon",
    instanceID        = 545,
    journalInstanceID = 261,
    name              = "The Steamvault",
    expansion         = "Burning Crusade",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 14, 15 },
    patch             = "2.0.3",

    entrance = {
        mapID = 102,
        x     = 0.5020,
        y     = 0.3332,
    },

    bosses = {
        {
            index              = 1,
            name               = "Hydromancer Thespia",
            journalEncounterID = 573,
            achievements       = {
            },
            loot = {
                { id = 27789, slot = "Back", name = "Cloak of Whispering Shells", sources = { [14]=12065, [15]=12065 } },
                { id = 27806, slot = "Hands", name = "Fathomheart Gauntlets", sources = { [14]=12080, [15]=12080 } },
                { id = 27475, slot = "Hands", name = "Gauntlets of the Bold", sources = { [14]=11923, [15]=11923 } },
                { id = 27508, slot = "Hands", name = "Incanter's Gloves", sources = { [14]=11942, [15]=11942 } },
                { id = 27783, slot = "Waist", name = "Moonrage Girdle", sources = { [14]=12062, [15]=12062 } },
            },
        },
        {
            index              = 2,
            name               = "Mekgineer Steamrigger",
            journalEncounterID = 574,
            achievements       = {
            },
            loot = {
                { id = 27787, slot = "Chest", name = "Chestguard of No Remorse", sources = { [14]=12063, [15]=12063 } },
                { id = 27793, slot = "Hands", name = "Earth Mantle Handwraps", sources = { [14]=12068, [15]=12068 } },
                { id = 27790, slot = "Head", name = "Mask of Penance", sources = { [14]=12066, [15]=12066 } },
                { id = 27794, slot = "Ranged", name = "Recoilless Rocket Ripper X-54", sources = { [14]=12069, [15]=12069 } },
                { id = 27791, slot = "Two-Hand", name = "Serpentcrest Life-Staff", sources = { [14]=12067, [15]=12067 } },
                { id = 27795, slot = "Waist", name = "Sash of Serpentra", sources = { [14]=12070, [15]=12070 } },
            },
        },
        {
            index              = 3,
            name               = "Warlord Kalithresh",
            journalEncounterID = 575,
            achievements       = {
            },
            loot = {
                { id = 27804, slot = "Back", name = "Devilshark Cape", sources = { [14]=12079, [15]=12079 } },
                { id = 28203, slot = "Chest", name = "Breastplate of the Righteous", sources = { [14]=12325, [15]=12325 } },
                { id = 27799, slot = "Chest", name = "Vermillion Robes of the Dominant", sources = { [14]=12074, [15]=12074 } },
                { id = 27510, slot = "Hands", name = "Tidefury Gauntlets", sources = { [14]=11944, [15]=11944 } },
                { id = 27874, slot = "Legs", name = "Beast Lord Leggings", sources = { [14]=12119, [15]=12119 } },
                { id = 30543, slot = "Legs", name = "Pontifex Kilt", sources = { [14]=13812, [15]=13812 } },
                { id = 29351, slot = "Ranged", name = "Wrathtide Longbow", sources = { [14]=13096, [15]=13096 } },
                { id = 27801, slot = "Shoulder", name = "Beast Lord Mantle", sources = { [14]=12076, [15]=12076 } },
                { id = 27738, slot = "Shoulder", name = "Incanter's Pauldrons", sources = { [14]=12029, [15]=12029 } },
                { id = 27737, slot = "Shoulder", name = "Moonglade Shoulders", sources = { [14]=12028, [15]=12028 } },
                { id = 29463, slot = "Wrist", name = "Amber Bands of the Aggressor", sources = { [14]=13156, [15]=13156 } },
                { id = 29243, slot = "Wrist", name = "Wave-Fury Vambraces", sources = { [14]=13038, [15]=13038 } },
            },
        },
    },
}
