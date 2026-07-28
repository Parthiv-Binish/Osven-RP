Config = {}

Config.keyBind = {
    useRadio = "CAPS",
    openRadio = "F7",
    volUp1 = "PAGEUP",
    radioVolDown = "PAGEDOWN",
    RadioChannelUp = "F9",
    RadioChannelDown = "F10"
}

Config.RestrictedChannels = {
    [1] = { police = true, ambulance = true },
    [2] = { police = true, ambulance = true },
    [3] = { police = true, ambulance = true },
    [4] = { police = true, ambulance = true },
    [5] = { police = true, ambulance = true },
}

Config.MaxFrequency = 500
Config.MinFrequency = 1

Config.RadioItem = 'radio'

Config.DefaultRadioVolume = 0.7
