--[[
    ####--------------------------------####
    #--# Author:   by uriid1            #--#
    #--# License:  GNU GPLv3            #--#
    #--# Telegram: @main_moderator      #--#
    #--# E-mail:   appdurov@gmail.com   #--#
    ####--------------------------------####
--]]

-- Init
local bot = {

    -- Consts
    token      = "";
    admin_id   = 0;
    parse_mode = "HTML";

    -- Param
    debug = false;

    -- Anti Spam conf & hash
    command_anti_spam = false;
    anti_spam = {
        users = {};
        setting = {
            mute_second = 5;
            time        = 1;
            count       = 4;
        }
    };

    -- Commands table
    cmd = {}

}


-- Set the bot token
function bot:setToken(token)

    bot.token = token
    return bot

end


-------------------------
-- Power Functions
-------------------------

-- Anti spam detector
bot.spam_detector = require("extensions.command_antispam_checker").spam_detector

-- Pretty Print
local pp = require('pretty-print').prettyPrint

-- Debug Pretty Print
local dprint = function(...)

    if (bot.debug) then
        pp(...)
    end

end


-------------------------
-- Libs
-------------------------
-- Extend String
require("libs.string_extension")

-- Timer
local timer = require 'timer'

-- http(s)
local http   = require("http")
local https  = require("https")

-- Parse
local json = require('json')
local multipart_encode = require("libs.multipart-post")


-------------------------
-- BOT EVENTS
-------------------------
bot.event = {}

-- Main events
bot.event.onCallbackQuery  = function(callback)       end
bot.event.onGetMessageText = function(message)        end
bot.event.onMyChatMember   = function(my_chat_member) end
bot.event.onLeftChatMember = function(message)        end

-- Error Handling
bot.event.onCommandErrorHandle = function(error, message) end
bot.event.onEventErrorHandle   = function(error, message) end

-- Other
bot.event.onInformSpammer = function(message) end


-------------------------
-- MAKE REQUEST
-------------------------
-- With body 
local makeRequest = function(method, request_body, callback)

    -- Make multipart-data
    local body, boundary = multipart_encode(request_body)

    -- Request
    local req = https.request({

        -- Make options
        hostname = 'api.telegram.org',
        port = 443,
        path = string.format("/bot%s%s", bot.token, method),
        method = 'POST',
        headers = {
            ['Content-Type'] = "multipart/form-data; boundary=" .. boundary;
            ['Content-Length'] = string.len(body)
        }

    }, function() end)

    -- Get response
    req:on("response", function(response)

        local data = ""

        response:on("data", function(chunk)
            data = data .. chunk
        end)

        response:on("end", function()
            if callback then
                callback(json.decode(data))
            end
        end)

    end)

    req:write(body)
    req:done()

end

-- With no body
local makeRequestNoBody = function(method, callback)

    -- Request
    local req = https.request({

        -- Make options
        hostname = 'api.telegram.org',
        port = 443,
        path = string.format("/bot%s%s", bot.token, method),
        method = 'POST'

    }, function() end)

    -- Get response
    req:on("response", function(response)

        local data = ""

        response:on("data", function(chunk)
            data = data .. chunk
        end)

        response:on("end", function()
            if callback then
                callback(json.decode(data))
            end
        end)

    end)

    req:done()

end


-------------------------
-- BOT METHODS
-------------------------

-- Get basic information about the bot
function bot:getMe(callback)

    -- Send the package
    makeRequestNoBody("/getMe", callback)

end


-- Returns a Chat object on success
function bot:getChat(chat_id, callback)

    -- Send the package
    makeRequest("/getChat", {chat_id = chat_id}, callback)

end


-- Send a message text
function bot:sendMessage(options, callback)

    -- Set Default Parse Mode
    if bot.parse_mode then
        options.parse_mode = bot.parse_mode
    end

    -- Send the package
    makeRequest("/sendMessage", options, callback)

end


-- Send a message text with no default parse_mode
function bot:sendMessageDebug(options, callback)

    -- Send the package
    makeRequest("/sendMessage", options, callback)

end


-- Edit Message Text
function bot:editMessageText(options, callback)

    -- Set Default Parse Mode
    if bot.parse_mode then
        options.parse_mode = bot.parse_mode
    end

    -- Send the package
    makeRequest("/editMessageText", options, callback)

end


-- Delete Message
function bot:deleteMessage(chat_id, message_id, callback)

    -- Send the package
    makeRequest("/deleteMessage", { chat_id = chat_id; message_id = message_id; }, callback)

end


-- Get Chat Member rules
function bot:getChatMember(chat_id, user_id, callback)

    -- Send the package
    makeRequest("/getChatMember", {chat_id = chat_id; user_id = user_id}, callback)

end


-- Get member count in chat
function bot:getChatMemberCount(chat_id, callback)

    -- Send the package
    makeRequest("/getChatMemberCount", {chat_id = chat_id}, callback)

end


-- Answer callback query
function bot:answerCallbackQuery(options, callback)
    
    -- Send the package
    makeRequest("/answerCallbackQuery", options, callback)

end


-------------------------
-- INLINE BUTTONS
-------------------------
-- Inline init
function bot:inlineKeyboardInit()
    return {
        inline_keyboard = {}
    }
end

-- Add inline URL button
function bot:inlineUrlButton(keyboard, text, url, row)

    -- Add in line
    if (not keyboard["inline_keyboard"][row]) then
        table.insert(keyboard["inline_keyboard"],
            {
                {
                    url  = url;
                    text = text;
                }
            }
        )
        return
    end

    -- Add to row
    table.insert(keyboard["inline_keyboard"][row or 1],
        {
            url  = url;
            text = text;
        }
    )

end


-- Add inline CALLBACK button
function bot:inlineCallbackButton(keyboard, text, callback, row)

    -- Add in line
    if (not keyboard["inline_keyboard"][row]) then
        table.insert(keyboard["inline_keyboard"],
            {
                {
                    callback_data  = callback;
                    text      = text;
                }
            }
        )
        return
    end

    -- Add to row
    table.insert(keyboard["inline_keyboard"][row or 1],
        {
            callback_data  = callback;
            text      = text;
        }
    )

end


-------------------------
-- COMMAND HANDLER
-------------------------
function bot:callCommand(user_command, text, user_id, message)

    timer.setImmediate(function()

        --
        if (not bot["cmd"][user_command]) then
            return
        end

        -- Anti Spam
        if (bot.command_anti_spam) then
            if bot.spam_detector(bot.anti_spam, message) then
                bot.event.onInformSpammer(message)
                return
            end
        end

        -- Pcall
        local ok, error = pcall(bot["cmd"][user_command], user_id, text, message)

        -- Event error handling
        if (not ok) then
            bot.event.onCommandErrorHandle(error, message)
        end

    end)

end


-------------------------------
-- EVENT HANDLER
-------------------------------
local call_event = function(event, message)

    timer.setImmediate(function()
        
        -- Pcall
        local ok, error = pcall(event, message)

        -- Event error handling
        if (not ok) then
            bot.event.onEventErrorHandle(error, message)
        end

    end)

end


-------------------------
-- PARSE TG MSG
-------------------------
local parse_query = function(result)

    -- No result
    if (not result) then
        dprint("[error] Empty result")
        return "Get empty result"
    end

    --
    -- All call event
    --
    -- Add bot to chat
    if (result.my_chat_member) then
        return call_event(bot.event.onMyChatMember, result.my_chat_member)

    -- Edited Message
    elseif (result.edited_message) then
        -- Coming soon
        return
    
    -- Inline Query
    elseif (result.inline_query) then
        -- Coming soon
        return
    
    -- Callback_query
    elseif (result.callback_query) then
        return call_event(bot.event.onCallbackQuery, result)
    end


    --
    -- Message call event
    --
    -- Nil message
    if (not result.message) then
        return "Get nil message"
    end

    -- Left chat member
    if (result.message.left_chat_member) then
        return call_event(bot.event.onLeftChatMember, result.message)
    end

    -- Entities
    if (result.message.entities) then

        -- Empty entities
        if (not result.message.entities[1]) then
            return "Get empty entities"
        end

        -- For entities
        for i = 1, #result.message.entities do
            local type = result.message.entities[i].type

            -- message.entities[i].bot_command
            if (type == "bot_command") then
                -- Execute command
                return bot:callCommand(result.message.text:split(" ", 1)[1], result.message.text, result.message.from.id, result.message)

            -- message.entities[i].mention
            elseif (type == "mention") then
                return
            end
        end

    end -- message.entities

    -- message.text
    if (result.message.text) then
        return call_event(bot.event.onGetMessageText, result.message)
    end

end


-------------------------
-- SEND SERTIFICATE
-------------------------

-- Curl example
-- curl -F "url=https://IP/bot" -F "certificate=@/etc/nginx/ssl/PUBLIC.pem" https://api.telegram.org/botTOKEN/setwebhook

local send_certificate = function(param, callback)

    -- Current test
    assert(type(param)             == "table",  "[error] In function send_certificate argument 'param' is not table.")
    assert(type(param.url)         == "string", "[error] In function send_certificate argument 'param.url' is not string.")
    assert(type(param.certificate) == "string", "[error] In function send_certificate argument 'param.certificate' is not string.")
    assert(type(param.token)       == "string", "[error] In function send_certificate argument 'param.token' is not string.")
    
    -- Make multipart-data
    local sert = io.open(param.certificate, "rb")

    local body, boundary = multipart_encode(
        {
            url = param.url;
            certificate = {
                filename = param.certificate:match("[^/]*.$");
                data = sert:read("*a");
            };

            drop_pending_updates = param.drop_pending_updates or false;
            allowed_updates = param.allowed_updates or nil
        }
    )

    --
    sert:close()

    -- Request
    local req = https.request({

        -- Make options
        hostname = 'api.telegram.org',
        port = 443,
        path = string.format("/bot%s/setwebhook", param.token),
        method = 'POST',
        headers = {
            ['content-type'] = "multipart/form-data; boundary=" .. boundary;
            ['content-length'] = string.len(body);
        }

    }, function() end)

    -- Get response
    req:on("response", function(response)

        local data = ""

        response:on("data", function(chunk)
            data = data .. chunk
        end)

        response:on("end", function()
            if callback then
                callback(json.decode(data))
            end
        end)

    end)

    req:write(body)
    req:done()

end


-------------------------
-- START WEBHOOK
-------------------------
function bot:startWebHook(options)

    -- Create Server
    http.createServer(function(req, res)
        req:on('data', function(chunk)

            -- Get data
            local result = json.decode(chunk)

            -- Parse
            parse_query(result)
            
        end)

        -- Server response
        res:finish("200")
    end)

    -- Listen localhost
    :listen(options.port, "0.0.0.0")

    -- p
    dprint("[true] HTTP Server listening at 0.0.0.0:" .. options.port)

    -- Send sert
    send_certificate(options, function(res)

        dprint(("[%s] description: %s"):format(res.ok, res.description))

        -- Exit
        if (not res.ok) then
            os.exit()
        end

        -- Get bot info
        bot:getMe(function(responce)

            -- Make bot info
            for k, v in pairs(responce.result) do
                bot[k] = v
            end

        end)

    end)

end


-------------------------
-- START LONG POLLING
-------------------------
function bot:startLongPolling(options)
    
    -- Current test
    assert(type(options)        == "table",  "[error] In function startLongPolling argument 'param' is not table.")
    assert(type(options.token)  == "string", "[error] In function startLongPolling argument 'param.token' is not string.")

    -- Options
    local update_id = 0
    local offset = options.offset or -1
    local polling_timeout = options.polling_timeout or 60
    
    --
    local getUpdates
    getUpdates = function(first_start)
        local req = https.request({
            -- Make options
            hostname = 'api.telegram.org',
            port = 443,
            path = string.format("/bot%s/getUpdates?offset=%d&timeout=%d", options.token, offset, polling_timeout),
            method = 'GET'
        }, function(res)

            res:on('data', function(chunk)
                -- Get data
                local responce = json.decode(chunk)

                -- First start
                if (first_start) then
                    first_start = false

                    if (not responce.ok) then
                        dprint(("[%s] error_code: %s | description: %s"):format(tostring(responce.ok), responce.error_code, responce.description))
                        return
                    end

                    dprint("[true] Start long polling")
                end

                --
                if (responce.ok) then
                    for i = 1, #responce.result do
                        -- Parse
                        parse_query(responce.result[i])

                        -- Inc offset
                        offset = responce.result[i].update_id + 1
                    end

                    -- Get new updates
                    getUpdates()
                end

            end) --- res:on
        end) -- https.request

        req:done()
    end

    -- Start long polling
    getUpdates(true)
end

return bot