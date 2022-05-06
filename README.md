# luvit-telegram-bot

# Examle
```lua
-- Simple Echo Bot
-- Bot
local bot = require("./core/bot"):setToken("123456789:AABBCCDDEEFFF-FGGHHKKLL")

-- Event get message
bot.event.onGetMessageText = function(message)

    -- Send message
    bot:sendMessage {
        text    = message.text;
        chat_id = message.chat.id;
    }

end

-- Run bot
-- Enable long polling
bot:startLongPolling {
    token = bot.token
}
```