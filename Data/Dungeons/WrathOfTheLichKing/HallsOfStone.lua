-------------------------------------------------------------------------------
-- RetroRuns Data -- Halls of Stone
-- Wrath of the Lich King dungeon, Patch 3.0.2  |  instanceID: 599  |  journalInstanceID: 277
-------------------------------------------------------------------------------

RetroRuns_DungeonData = RetroRuns_DungeonData or {}

RetroRuns_DungeonData[277] = {
    kind              = "dungeon",
    instanceID        = 599,
    journalInstanceID = 277,
    name              = "Halls of Stone",
    expansion         = "Wrath of the Lich King",
    difficultyModel   = "dungeonBinary",
    availableDifficulties = { 14, 15 },
    patch             = "3.0.2",

    entrance = {
        mapID = 120,
        x     = 0.3944,
        y     = 0.2691,
    },

    gloryMeta = {
        id   = 2136,
        name = "Glory of the Hero",
        rewardItemID       = 44160,
        rewardMountSpellID = 59961,
        rewardName         = "Red Proto-Drake",
    },

    bosses = {
        {
            index              = 1,
            name               = "Krystallus",
            journalEncounterID = 604,
            achievements       = {
            },
            loot = {
                { id = 35670, slot = "Head", name = "Brann's Lost Mining Helmet", sources = { [14]=16588, [15]=16588 } },
                { id = 35672, slot = "Head", name = "Hollow Geode Helm", sources = { [14]=16589, [15]=16589 } },
                { id = 35673, slot = "Legs", name = "Leggings of Burning Gleam", sources = { [14]=16590, [15]=16590 } },
                { id = 37650, slot = "Legs", name = "Shardling Legguards", sources = { [14]=17926, [15]=17926 } },
                { id = 37652, slot = "Shoulder", name = "Spaulders of Krystallus", sources = { [14]=17927, [15]=17927 } },
                { id = 37649, slot = "Weapon", name = "Quarry Chisel", sources = { [14]=17925, [15]=17925 } },
            },
        },
        {
            index              = 2,
            name               = "Maiden of Grief",
            journalEncounterID = 605,
            achievements       = {
                { id = 1866, name = "Good Grief", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 38614, slot = "Back", name = "Embrace of Sorrow", sources = { [14]=18493, [15]=18493 } },
                { id = 38615, slot = "Hands", name = "Lightning-Charged Gloves", sources = { [14]=18494, [15]=18494 } },
                { id = 38618, slot = "Two-Hand", name = "Hammer of Grief", sources = { [14]=18496, [15]=18496 } },
                { id = 38616, slot = "Waist", name = "Maiden's Girdle", sources = { [14]=18495, [15]=18495 } },
            },
        },
        {
            index              = 3,
            name               = "Tribunal of Ages",
            journalEncounterID = 606,
            achievements       = {
                { id = 2154, name = "Brann Spankin' New", meta = true, soloable = "yes" },
            },
            loot = {
                { id = 35677, slot = "Chest", name = "Cosmos Vestments", sources = { [14]=16594, [15]=16594 } },
                { id = 35675, slot = "Chest", name = "Linked Armor of the Sphere", sources = { [14]=16592, [15]=16592 } },
                { id = 37654, slot = "Feet", name = "Sabatons of the Ages", sources = { [14]=17929, [15]=17929 } },
                { id = 35676, slot = "Legs", name = "Constellation Leggings", sources = { [14]=16593, [15]=16593 } },
                { id = 37655, slot = "Shoulder", name = "Mantle of the Tribunal", sources = { [14]=17930, [15]=17930 } },
                { id = 37653, slot = "Two-Hand", name = "Sword of Justice", sources = { [14]=17928, [15]=17928 } },
                { id = 157564, slot = "Wrist", name = "Marbled Bracers", sources = { [14]=93759, [15]=93759 } },
                { id = 37656, slot = "Wrist", name = "Raging Construct Bands", sources = { [14]=17931, [15]=17931 } },
            },
        },
        {
            index              = 4,
            name               = "Sjonnir the Ironshaper",
            journalEncounterID = 607,
            achievements       = {
                { id = 2155, name = "Abuse the Ooze", meta = true, soloable = "kinda" },
            },
            loot = {
                { id = 37658, slot = "Chest", name = "Sun-Emblazoned Chestplate", sources = { [14]=17932, [15]=17932 } },
                { id = 37666, slot = "Feet", name = "Boots of the Whirling Mist", sources = { [14]=17934, [15]=17934 } },
                { id = 35679, slot = "Head", name = "Static Cowl", sources = { [14]=16596, [15]=16596 } },
                { id = 35678, slot = "Legs", name = "Ironshaper's Legplates", sources = { [14]=16595, [15]=16595 } },
                { id = 37669, slot = "Legs", name = "Leggings of the Stone Halls", sources = { [14]=17937, [15]=17937 } },
                { id = 37670, slot = "Waist", name = "Sjonnir's Girdle", sources = { [14]=17938, [15]=17938 } },
                { id = 37667, slot = "Weapon", name = "The Fleshshaper", sources = { [14]=17935, [15]=17935 } },
                { id = 37668, slot = "Wrist", name = "Bands of the Stoneforge", sources = { [14]=17936, [15]=17936 } },
            },
        },
    },
}
