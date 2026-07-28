-- Channel definitions
-- Each channel has: id, label, icon (emoji), accent color, timeout (seconds), maxDistance (0 = server-wide)
Config = Config or {}
Config.ChatChannels = {
    --    id       label       icon       color               timeout  maxDist
    { id = 'local',  label = 'LOCAL',   icon = '\239\130\168', color = '#EDEFF2',    timeout = 8,  maxDistance = 20.0 },
    { id = 'me',     label = '/ME',     icon = '\239\129\180', color = '#A855F7',    timeout = 10, maxDistance = 20.0 },
    { id = 'do',     label = '/DO',     icon = '\239\132\154', color = '#E8A33D',    timeout = 10, maxDistance = 20.0 },
    { id = 'ooc',    label = 'OOC',     icon = '\239\140\166', color = '#3B82F6',    timeout = 6,  maxDistance = 0 },
    { id = 'pd',     label = 'PD RADIO',icon = '\240\159\154\147', color = '#2FB6A6', timeout = 12, maxDistance = 0 },
    { id = 'ems',    label = 'EMS RADIO',icon = '\226\154\149', color = '#22C55E',   timeout = 12, maxDistance = 0 },
    { id = 'gang',   label = 'GANG',    icon = '\239\128\133', color = '#C23B3B',    timeout = 10, maxDistance = 0 },
    { id = 'dispatch',label = 'DISPATCH',icon = '\239\139\161', color = '#F97316',   timeout = 10, maxDistance = 0 },
    { id = 'ad',     label = 'AD',      icon = '\239\132\161', color = '#E8A33D',    timeout = 15, maxDistance = 0 },
    { id = 'admin',  label = 'ADMIN',   icon = '\239\154\161', color = '#FBBF24',    timeout = 20, maxDistance = 0 },
    { id = 'system', label = 'SYSTEM',  icon = '\226\154\162', color = '#8B93A1',    timeout = 8,  maxDistance = 0 },
}

Config.MaxHistoryMessages = 100
Config.DefaultTimeout = 8
