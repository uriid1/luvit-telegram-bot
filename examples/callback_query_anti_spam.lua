--[[ Instruction
1) Set bot token, url, cert, port 
2) run luvit callback_query_anti_spam
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
local json  = require "json"
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
        
    -- Locals
    local chat_id    = 0
    local user_id    = 0
    local first_name = ""

    -- inline callback
    if message.callback_query then
        chat_id    = message.callback_query.message.chat.id
        user_id    = message.callback_query.from.id
        first_name = message.callback_query.from.first_name
    else
        chat_id    = message.chat.id
        user_id    = message.from.id
        first_name = message.from.first_name
    end

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

-- Event call callback query
bot.event.onCallbackQuery = function(callback)

    -- Anti spam
    if bot.anti_spam.users[callback.callback_query.from.id] then
        if (bot.anti_spam.users[callback.callback_query.from.id].mute) then

            -- Inform
            bot:answerCallbackQuery({
                text =
                    "Please don't spam!\n"
                    .. "Punishment: Ignore " .. bot.anti_spam.setting.mute_second .. " second";

                show_alert = true;
                callback_query_id = callback.callback_query.id;
            })

            -- Update info
            bot.spam_detector(bot.anti_spam, callback)

            return
        end
    end

    -- Answer
    bot:answerCallbackQuery({ callback_query_id = callback.callback_query.id })
    -- Call Command
    bot:callCommand(callback.callback_query.data:split(" ", 1)[1], callback.callback_query.data, callback.callback_query.from.id, callback)

end


-- Make buttons
local keyboard = bot:inlineKeyboardInit()
bot:inlineCallbackButton(keyboard, "🟢 RED 🟢"       ,"/query_click red")
bot:inlineCallbackButton(keyboard, "🟡 GREEN 🟡"     ,"/query_click green")
bot:inlineCallbackButton(keyboard, "🔴 YELLOW 🔴"  ,"/query_click yellow")


-- Send callback buttons
bot.cmd["/start"] = function(user_id, arguments, message)
         
    bot:sendMessage({
        text = "Simple Inline Key";
        chat_id = message.chat.id;
        reply_markup = json.encode(keyboard);
    })
    
end


-- Handling a button click
bot.cmd["/query_click"] = function(user_id, arguments, callback)

    local arguments = arguments:split(" ", 2)

    bot:sendMessage({
        text = string.format("%s is click %s button",
            dec.user_url(callback.callback_query.from.id, callback.callback_query.from.first_name),
            dec.bold(arguments[2])
        );

        chat_id = callback.callback_query.message.chat.id;
    })
    
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