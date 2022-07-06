--[[ Instruction
1) Set bot token, url, cert, port 
2) run luvit command_anti_spam
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


-- Anti Spam settings
bot.command_anti_spam = true
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


-------------------------
-- COMMANDS
-------------------------
bot.cmd["/start"] = function(user_id, arguments, message)
    
    bot:getMe(function(res)

        if (not res.ok) then
            print("Bad Request: " .. res.description)
            return
        end

        bot:sendMessage({
            text = 
            "Hello! i'm Super Cool Bot!"
            .. "\n\nBasic info:"
            .. "\nBot Username: " .. res.result.username
            .. "\nBot Name: "     .. res.result.first_name
            
            .. "\n\nAll info: "
            .. "\nCan join groups: "             .. tostring(res.result.can_join_groups)
            .. "\nCan read all group messages: " .. tostring(res.result.can_read_all_group_messages)
            .. "\nSupports inline queries: "     .. tostring(res.result.supports_inline_queries);

            chat_id = message.chat.id;
            reply_to_message_id = message.message_id;
        })

    end)

end


-- Run bot
-- Enable webhook
bot:startWebHook({
    token       = bot.token;
    port        = PORT;
    url         = URL;
    certificate = CERT;

    -- Optional
    drop_pending_updates = true;
})