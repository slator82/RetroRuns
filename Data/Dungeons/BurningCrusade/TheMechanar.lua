-------------------------------------------------------------------------------
-- RetroRuns Data -- The Mechanar
-- Burning Crusade dungeon, Patch 2.0.3  |  instanceID: 554  |  journalInstanceID: 258
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[258] = {
    kind              = "dungeon",
    instanceID        = 554,
    journalInstanceID = 258,
    name              = "The Mechanar",
    expansion         = "Burning Crusade",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 14, 15 },
    patch             = "2.0.3",

    entrance = {
        mapID = 109,
        x     = 0.7064,
        y     = 0.6982,
    },

    bosses = {
        {
            index              = 1,
            name               = "Mechano-Lord Capacitus",
            journalEncounterID = 563,
            achievements       = {
            },
            loot = {
                { id = 28256, slot = "Back", name = "Thoriumweave Cloak", sources = { [14]=12356, [15]=12356 } },
                { id = 28255, slot = "Shoulder", name = "Lunar-Claw Pauldrons", sources = { [14]=12355, [15]=12355 } },
                { id = 28253, slot = "Two-Hand", name = "Plasma Rat's Hyper-Scythe", sources = { [14]=12354, [15]=12354 } },
                { id = 28257, slot = "Weapon", name = "Hammer of the Penitent", sources = { [14]=12357, [15]=12357 } },
            },
        },
        {
            index              = 2,
            name               = "Nethermancer Sepethrea",
            journalEncounterID = 564,
            achievements       = {
            },
            loot = {
                { id = 28262, slot = "Chest", name = "Jade-Skull Breastplate", sources = { [14]=12360, [15]=12360 } },
                { id = 28202, slot = "Chest", name = "Moonglade Robe", sources = { [14]=12324, [15]=12324 } },
                { id = 28275, slot = "Head", name = "Beast Lord Helm", sources = { [14]=12367, [15]=12367 } },
                { id = 28260, slot = "Off-hand", name = "Manual of the Nethermancer", sources = { [14]=12359, [15]=12359 } },
                { id = 28263, slot = "Weapon", name = "Stellaris", sources = { [14]=12361, [15]=12361 } },
            },
        },
        {
            index              = 3,
            name               = "Pathaleon the Calculator",
            journalEncounterID = 565,
            achievements       = {
            },
            loot = {
                { id = 28269, slot = "Back", name = "Baba's Cloak of Arcanistry", sources = { [14]=12366, [15]=12366 } },
                { id = 28204, slot = "Chest", name = "Tunic of Assassination", sources = { [14]=12326, [15]=12326 } },
                { id = 29251, slot = "Feet", name = "Boots of the Pious", sources = { [14]=13046, [15]=13046 } },
                { id = 32076, slot = "Hands", name = "Handguards of the Steady", sources = { [14]=14751, [15]=14751 } },
                { id = 28285, slot = "Head", name = "Helm of the Righteous", sources = { [14]=12369, [15]=12369 } },
                { id = 28278, slot = "Head", name = "Incanter's Cowl", sources = { [14]=12368, [15]=12368 } },
                { id = 28266, slot = "Legs", name = "Molten Earth Kilt", sources = { [14]=12363, [15]=12363 } },
                { id = 30533, slot = "Legs", name = "Vanquisher's Legplates", sources = { [14]=13806, [15]=13806 } },
                { id = 28286, slot = "Ranged", name = "Telescopic Sharprifle", sources = { [14]=12370, [15]=12370 } },
                { id = 28267, slot = "Weapon", name = "Edge of the Cosmos", sources = { [14]=12364, [15]=12364 } },
                { id = 27899, slot = "Weapon", name = "Mana Wrath", sources = { [14]=12139, [15]=12139 } },
                { id = 29362, slot = "Weapon", name = "The Sun Eater", sources = { [14]=13104, [15]=13104 } },
            },
        },
    },
}
