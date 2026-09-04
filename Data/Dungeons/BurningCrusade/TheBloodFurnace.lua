-------------------------------------------------------------------------------
-- RetroRuns Data -- The Blood Furnace
-- Burning Crusade dungeon, Patch 2.0.3  |  instanceID: 542  |  journalInstanceID: 256
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[256] = {
    kind              = "dungeon",
    instanceID        = 542,
    journalInstanceID = 256,
    name              = "The Blood Furnace",
    expansion         = "Burning Crusade",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 14, 15 },
    patch             = "2.0.3",
    timewalking       = true,

    entrance = {
        mapID = 100,
        x     = 0.4587,
        y     = 0.5193,
    },

    bosses = {
        {
            index              = 1,
            name               = "The Maker",
            journalEncounterID = 555,
            achievements       = {
            },
            loot = {
                { id = 27485, slot = "Back", name = "Embroidered Cape of Mysteries", sources = { [14]=11928, [15]=11928 } },
                { id = 24387, slot = "Hands", name = "Ironblade Gauntlets", sources = { [14]=9528, [15]=9528 } },
                { id = 27488, slot = "Head", name = "Mage-Collar of the Firestorm", sources = { [14]=11931, [15]=11931 } },
                { id = 27487, slot = "Legs", name = "Bloodlord Legplates", sources = { [14]=11930, [15]=11930 } },
                { id = 24388, slot = "Waist", name = "Girdle of the Gale Storm", sources = { [14]=9529, [15]=9529 } },
                { id = 24384, slot = "Weapon", name = "Diamond-Core Sledgemace", sources = { [14]=9527, [15]=9527 } },
                { id = 27483, slot = "Wrist", name = "Moon-Touched Bands", sources = { [14]=11927, [15]=11927 } },
            },
        },
        {
            index              = 2,
            name               = "Broggok",
            journalEncounterID = 556,
            achievements       = {
            },
            loot = {
                { id = 27848, slot = "Feet", name = "Embroidered Spellpyre Boots", sources = { [14]=12106, [15]=12106 } },
                { id = 24393, slot = "Hands", name = "Bloody Surgeon's Mitts", sources = { [14]=9533, [15]=9533 } },
                { id = 24391, slot = "Legs", name = "Kilt of the Night Strider", sources = { [14]=9531, [15]=9531 } },
                { id = 27492, slot = "Legs", name = "Moonchild Leggings", sources = { [14]=11934, [15]=11934 } },
                { id = 24389, slot = "Ranged", name = "Legion Blunderbuss", sources = { [14]=9530, [15]=9530 } },
                { id = 27490, slot = "Weapon", name = "Firebrand Battleaxe", sources = { [14]=11933, [15]=11933 } },
                { id = 24392, slot = "Wrist", name = "Arcing Bracers", sources = { [14]=9532, [15]=9532 } },
                { id = 27494, slot = "Wrist", name = "Emerald Eye Bracer", sources = { [14]=11936, [15]=11936 } },
                { id = 27489, slot = "Wrist", name = "Virtue Bearer's Vambraces", sources = { [14]=11932, [15]=11932 } },
            },
        },
        {
            index              = 3,
            name               = "Keli'dan the Breaker",
            journalEncounterID = 557,
            achievements       = {
            },
            loot = {
                { id = 24397, slot = "Chest", name = "Raiments of Divine Authority", sources = { [14]=9537, [15]=9537 } },
                { id = 27506, slot = "Chest", name = "Robe of Effervescent Light", sources = { [14]=11940, [15]=11940 } },
                { id = 24396, slot = "Chest", name = "Vest of Vengeance", sources = { [14]=9536, [15]=9536 } },
                { id = 28264, slot = "Chest", name = "Wastewalker Tunic", sources = { [14]=12362, [15]=12362 } },
                { id = 27788, slot = "Feet", name = "Bloodsworn Warboots", sources = { [14]=12064, [15]=12064 } },
                { id = 29239, slot = "Feet", name = "Eaglecrest Warboots", sources = { [14]=13034, [15]=13034 } },
                { id = 29245, slot = "Feet", name = "Wave-Crest Striders", sources = { [14]=13040, [15]=13040 } },
                { id = 27497, slot = "Hands", name = "Doomplate Gauntlets", sources = { [14]=11938, [15]=11938 } },
                { id = 27505, slot = "Head", name = "Ruby Helm of the Just", sources = { [14]=11939, [15]=11939 } },
                { id = 27514, slot = "Legs", name = "Leggings of the Unrepentant", sources = { [14]=11946, [15]=11946 } },
                { id = 27507, slot = "Ranged", name = "Adamantine Repeater", sources = { [14]=11941, [15]=11941 } },
                { id = 32080, slot = "Shoulder", name = "Mantle of Shadowy Embrace", sources = { [14]=14754, [15]=14754 } },
                { id = 24398, slot = "Shoulder", name = "Mantle of the Dusk-Dweller", sources = { [14]=9538, [15]=9538 } },
                { id = 24394, slot = "Two-Hand", name = "Warsong Howling Axe", sources = { [14]=9534, [15]=9534 } },
                { id = 24395, slot = "Waist", name = "Mindfire Waistband", sources = { [14]=9535, [15]=9535 } },
                { id = 27512, slot = "Weapon", name = "The Willbreaker", sources = { [14]=11945, [15]=11945 } },
            },
        },
    },
}
