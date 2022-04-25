
--[[ Instruction
1) Move this example to the luvit-telegram-bot directory
2) 
2) run luvit echo_bot
--]]

-- Bot
local bot = require("./core/bot"):setToken("123456789:AABBCCDDEEFFFFGGHHKKLL")

-- Options
local URL   = "https://255.255.255.255/" .. bot.TOKEN
local CERT  = "/my/cool/path/PUBLIC.pem"
local PORT  = 5000


-- Event get message
bot.event.onGetMessageText = function(message)
    
    bot:sendMessage({
        text = message.text;
        chat_id = message.chat.id;
    })

end


-- Run bot
-- Enable webhook
bot:startWebHook({
    token       = bot.TOKEN;
    port        = PORT;
    url         = URL;
    certificate = CERT;

    -- Optional
    drop_pending_updates = true;
})