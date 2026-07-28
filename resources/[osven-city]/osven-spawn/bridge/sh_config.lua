-- Spawn locations available in the selector
Config = Config or {}
Config.SpawnLocations = {
    {
        id = 'last',
        label = 'Last Location',
        icon = '\240\159\148\153',
        desc = 'Logout timestamp here',
        coords = vector4(0, 0, 0, 0),  -- set dynamically
    },
    {
        id = 'pd',
        label = 'PD Lobby',
        icon = '\240\159\154\147',
        desc = 'Police Headquarters',
        coords = vector4(441.08, -982.32, 30.69, 90.0),
    },
    {
        id = 'hospital',
        label = 'Hospital Lobby',
        icon = '\226\154\149',
        desc = 'Saints General Hospital',
        coords = vector4(295.72, -584.44, 43.25, 160.0),
    },
    {
        id = 'downtown',
        label = 'Downtown Hub',
        icon = '\240\159\143\162',
        desc = 'Legion Square',
        coords = vector4(178.64, -1006.36, 29.37, 180.0),
    },
}
