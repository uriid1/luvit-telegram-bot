--[[ Instruction
1) Set bot token
2) run luvit long_polling_echo_bot
--]]

-- Luvit func
local path = require("path")

-- Simple Echo Bot
-- Bot
local bot = require(path.join("..", "core", "bot")):setToken("123456789:AABBCCDDEEFFFFGGHHKKLL")
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