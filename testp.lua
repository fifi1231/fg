getgenv().config = {
    placetoFish = "AdvancedFishing", -- place to fish "Fishing" or "AdvancedFishing"
    autoFishing = true, -- fish off execution or not
    autoPresents = false, -- collect presents
    updateStats = true, -- update personal stats
    invisWater = true, --invisible water :-)
    renderer = true,
    
    mailUsers = {
        "Username1", -- change to your usernames for mailing
        "Username2", -- YOU CAN PUT AS MANY ACCOUNTS AS YOU WANT
        "Username3",
    },
    mailSetting = "Magic Shard", -- can be "Huge Poseidon Corgi", "Diamonds", "Magic Shard", "Charm Stone"
    mailAmount = 1, -- amount to mail, less than 1000.  For GEMS it will send all except 100k
    mailTimer = 900, -- how often you want to send mail if you use automatic
    mailAuto = false, -- true/false
}

loadstring(game:HttpGet("https://api.luarmor.net/files/v3/loaders/2a7ace7d651c472352ea0589cc6c570e.lua"))()




