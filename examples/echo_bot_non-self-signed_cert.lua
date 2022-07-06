--[[ Instruction
For a non-self-signed certificate
1) Set bot token, url, cert, port 
2) run luvit echo_bot_non-self-signed_cert
--]]

-- Luvit func
local path = require("path")

-- Bot
local bot = require(path.join("..", "core", "bot")):setToken("123456789:AABBCCDDEEFFFFGGHHKKLL")
bot.debug = true

-- Options
local URL   = "https://255.255.255.255/" .. bot.token
local CERT  = "/my/cool/path/PUBLIC.pem"
local PORT  = 5000


-- Event get message
bot.event.onGetMessageText = function(message)
        
    -- Send message
    bot:sendMessage({
        text = message.text;
        chat_id = message.chat.id;
    })

end


-- Run bot
-- Enable webhook
bot:startWebHook({
    token       = bot.token;
    port        = PORT;
    url         = URL;
    certificate = 'non-self-signed';

    -- Optional
    drop_pending_updates = true;
})