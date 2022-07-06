# luvit-telegram-bot

# Exemple
```lua
-- Simple Echo Bot

-- Luvit func
local path = require("path")

-- Bot
local bot = require(path.join(module.dir, "core", "bot")):setToken("1234567:AABBDDCCSS-MMEERRFF")
bot.debug = true

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
