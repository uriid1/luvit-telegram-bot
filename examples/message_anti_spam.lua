--[[ Instruction
1) Move this example to the luvit-telegram-bot directory
2) Set bot token, url, cert, port 
3) run luvit message_anti_spam
--]]

-- Bot
local bot = require("./core/bot"):setToken("123456789:AABBCCDDEEFFFFGGHHKKLL")

-- Options
local URL   = "https://255.255.255.255/" .. bot.TOKEN
local CERT  = "/my/cool/path/PUBLIC.pem"
local PORT  = 5000


-- Anti Spam settings
bot.anti_spam.setting.mute_second = 5  -- How many seconds to ignore
bot.anti_spam.setting.count       = 4  -- After sending how many messages per second


-------------------------
-- LIBS
-------------------------
local timer = require "timer"
local dec   = require "./extensions/html_decoration"


-------------------------
-- TIMERS
-------------------------
-- One hour time to clear anti-spam hash
timer.setInterval(1000*60*60*1, function()

    -- Current time in sec
    local current_time = os.time()

    for id,_ in pairs(bot.anti_spam.users) do
        if (current_time - bot.anti_spam.users[id].date > 300) then
            bot.anti_spam.users[id] = nil
        end
    end

    -- Garbage collect
    collectgarbage("collect")
end)


-------------------------
-- EVENTS
-------------------------
-- Event get message
bot.event.onGetMessageText = function(message)
    
    -- Anti Spam
    if bot.spam_detector(bot.anti_spam, message) then
        bot.event.onInformSpammer(message)
        return
    end

    -- Send message
    bot:sendMessage({
        text = message.text;
        chat_id = message.chat.id;
    })

end


-- Event informing the spammer
bot.event.onInformSpammer = function(message)
    
    -- Igone callback
    if message.callback_query then
        return
    end

    local chat_id    = message.chat.id
    local user_id    = message.from.id
    local first_name = message.from.first_name

    --
    if (not bot.anti_spam.users[user_id]) then
        return
    end

    if (not bot.anti_spam.users[user_id].informing) then
        bot.anti_spam.users[user_id].informing = true

        bot:sendMessage({
            text = dec.italic(dec.bold(string.format("[❕] %s please don't spam!", dec.user_url(user_id, first_name))))
            .. "\nPunishment: Ignore " .. dec.bold(bot.anti_spam.setting.mute_second) .. " second";
            
            chat_id = chat_id;
        })
    end
    
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