local Translations = {
    notify = {
            ydhk = 'You do not have the keys to this vehicle',
            nonear = 'There is no one around to give the keys to',
            vlock = 'Vehicle locked!',
            vunlock = 'Vehicle open!',
            vlockpick = 'You managed to open the lock!',
            fvlockpick = 'You cant find the keys and you get frustrated',
            vgkeys = 'You have handed over the keys',
            vgetkeys = 'You have received the keys to the vehicle!',
            fpid = 'Fill the player ID and badge arguments',
            cjackfail = 'Carjacking failed!',
            vehclose = 'There is no vehicle nearby!',
            haskey = 'You already have the keys to this vehicle',
    },
    progress = {
        takekeys = 'Taking keys from body...',
        hskeys = 'Searching for the car keys...',
        acjack = 'Attempting Carjacking...',
    },
    info = {
        skeys = '~g~[H]~w~ - Search for Keys',
        tlock = 'Toggle Vehicle Locks',
        palert = 'Vehicle theft in progress. Type: ',
        engine = 'Toggle Engine',
    },
    addcom = {
        givekeys = 'Hand over the keys to someone. If no ID, gives to closest person or everyone in the vehicle.',
        givekeys_id = 'id',
        givekeys_id_help = 'Player ID',
        addkeys = 'Adds keys to a vehicle for someone.',
        addkeys_id = 'id',
        addkeys_id_help = 'Player ID',
        addkeys_plate = 'plate',
        addkeys_plate_help = 'Plate',
        rkeys = 'Remove keys to a vehicle for someone.',
        rkeys_id = 'id',
        rkeys_id_help = 'Player ID',
        rkeys_plate = 'plate',
        rkeys_plate_help = 'Plate',
    }

}

Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
