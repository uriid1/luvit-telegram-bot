
--[[ Instruction
For a non-self-signed certificate
1) Move this example to the luvit-telegram-bot directory
2) Set bot token, url, cert, port 
3) run luvit echo_bot
--]]

-- Bot
local bot = require("./core/bot"):setToken("123456789:AABBCCDDEEFFFFGGHHKKLL")
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
    url         = URL; -- https://mysite.name/telegram_bot
    certificate = 'non-self-signed';

    -- Optional
    drop_pending_updates = true;
})